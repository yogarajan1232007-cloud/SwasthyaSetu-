from datetime import date, datetime

import pandas as pd
from fastapi import HTTPException
from sqlalchemy.orm import Session

from app.models.individual import Individual
from app.models.screening import Screening
from app.models.measurement import Measurement


# Exact feature order used during model training

DIABETES_FEATURES = [
    "age",
    "bmi",
    "waist_cm",
    "fasting_glucose",
    "post_meal_glucose",
    "hba1c"
]


CVD_FEATURES = [
    "age",
    "gender",
    "bmi",
    "waist_cm",
    "systolic_bp",
    "diastolic_bp",
    "pulse_rate",
    "total_cholesterol",
    "hdl",
    "ldl",
    "triglycerides"
]


def calculate_age(date_of_birth, reference_date):

    if not date_of_birth or not reference_date:
        return None

    if isinstance(date_of_birth, datetime):
        date_of_birth = date_of_birth.date()

    if isinstance(reference_date, datetime):
        reference_date = reference_date.date()

    age = reference_date.year - date_of_birth.year

    if (
        reference_date.month,
        reference_date.day
    ) < (
        date_of_birth.month,
        date_of_birth.day
    ):
        age -= 1

    if age < 0:
        return None

    return age


def get_screening_data(
    db: Session,
    screening_id: int
):

    screening = (
        db.query(Screening)
        .filter(Screening.id == screening_id)
        .first()
    )

    if not screening:
        raise HTTPException(
            status_code=404,
            detail="Screening not found"
        )

    if screening.status != "completed":
        raise HTTPException(
            status_code=400,
            detail="AI prediction requires a completed screening"
        )

    individual = (
        db.query(Individual)
        .filter(
            Individual.id == screening.individual_id,
            Individual.is_active.is_(True)
        )
        .first()
    )

    if not individual:
        raise HTTPException(
            status_code=404,
            detail="Active individual not found"
        )

    measurement = (
        db.query(Measurement)
        .filter(
            Measurement.screening_id == screening.id,
            Measurement.individual_id == individual.id
        )
        .order_by(
            Measurement.id.desc()
        )
        .first()
    )

    if not measurement:
        raise HTTPException(
            status_code=404,
            detail="No measurements found for this screening"
        )

    reference_date = (
        screening.screening_date
        or measurement.measured_at
        or measurement.created_at
    )

    age = calculate_age(
        individual.date_of_birth,
        reference_date
    )

    if age is None:
        raise HTTPException(
            status_code=422,
            detail="Valid date of birth is required"
        )

    return individual, screening, measurement, age


def extract_features(
    db: Session,
    screening_id: int,
    prediction_type: str
):

    individual, screening, measurement, age = (
        get_screening_data(
            db,
            screening_id
        )
    )

    if prediction_type == "diabetes":

        feature_values = {
            "age": age,
            "bmi": measurement.bmi,
            "waist_cm": measurement.waist_cm,
            "fasting_glucose": measurement.fasting_glucose,
            "post_meal_glucose": measurement.post_meal_glucose,
            "hba1c": measurement.hba1c
        }

        required_features = DIABETES_FEATURES

    elif prediction_type == "cardiovascular":

        feature_values = {
            "age": age,
            "gender": individual.gender,
            "bmi": measurement.bmi,
            "waist_cm": measurement.waist_cm,
            "systolic_bp": measurement.systolic_bp,
            "diastolic_bp": measurement.diastolic_bp,
            "pulse_rate": measurement.pulse_rate,
            "total_cholesterol": measurement.total_cholesterol,
            "hdl": measurement.hdl,
            "ldl": measurement.ldl,
            "triglycerides": measurement.triglycerides
        }

        required_features = CVD_FEATURES

    else:
        raise HTTPException(
            status_code=400,
            detail="Unsupported prediction type"
        )

    missing_features = [
        feature
        for feature in required_features
        if feature_values.get(feature) is None
    ]

    if missing_features:
        raise HTTPException(
            status_code=422,
            detail={
                "message": "Required measurements are missing",
                "prediction_type": prediction_type,
                "missing_features": missing_features
            }
        )

    # Preserve exact feature order and column names.
    feature_frame = pd.DataFrame(
        [
            {
                feature: feature_values[feature]
                for feature in required_features
            }
        ],
        columns=required_features
    )

    return {
        "individual": individual,
        "screening": screening,
        "measurement": measurement,
        "features": feature_frame,
        "feature_values": feature_values
    }