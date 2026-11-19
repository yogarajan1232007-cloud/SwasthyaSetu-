from datetime import date, datetime
from typing import Optional

from fastapi import HTTPException
from sqlalchemy.orm import Session

from app.models.individual import Individual
from app.models.screening import Screening
from app.models.measurement import Measurement


# Minimum number of distinct visits for preparing
# an exploratory longitudinal sequence.
MINIMUM_SEQUENCE_VISITS = 3


# Features required for Diabetes forecasting
DIABETES_FEATURES = [
    "age",
    "bmi",
    "waist_cm",
    "fasting_glucose",
    "post_meal_glucose",
    "hba1c",
]


# Features required for Cardiovascular forecasting
CARDIOVASCULAR_FEATURES = [
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
    "triglycerides",
]


def calculate_age(
    date_of_birth: Optional[date],
    reference_date: Optional[date] = None
):
    """
    Calculate an individual's age using date of birth.
    """

    if not date_of_birth:
        return None

    reference_date = reference_date or date.today()

    age = reference_date.year - date_of_birth.year

    if (
        reference_date.month,
        reference_date.day
    ) < (
        date_of_birth.month,
        date_of_birth.day
    ):
        age -= 1

    return age


def serialize_datetime(value):
    """
    Convert datetime objects into ISO format.
    """

    if value is None:
        return None

    return value.isoformat()


def get_individual_historical_data(
    db: Session,
    individual_id: int
):
    """
    Retrieve historical health measurements for an individual.

    Rules:
    1. Only completed screenings are included.
    2. Each screening contributes at most one measurement record.
    3. The latest measurement is selected for each screening.
    4. Visits are sorted chronologically.
    5. Missing measurements are preserved as None.
    """

    # 1. Verify individual exists
    individual = (
        db.query(Individual)
        .filter(
            Individual.id == individual_id,
            Individual.is_active.is_(True)
        )
        .first()
    )

    if not individual:
        raise HTTPException(
            status_code=404,
            detail="Active individual not found"
        )

    # 2. Retrieve all completed screenings
    completed_screenings = (
        db.query(Screening)
        .filter(
            Screening.individual_id == individual_id,
            Screening.status == "completed"
        )
        .order_by(
            Screening.screening_date.asc(),
            Screening.id.asc()
        )
        .all()
    )

    visits = []

    # 3. Process each distinct screening
    for screening in completed_screenings:

        # Retrieve all measurements belonging to this screening
        measurements = (
            db.query(Measurement)
            .filter(
                Measurement.screening_id == screening.id,
                Measurement.individual_id == individual_id
            )
            .order_by(
                Measurement.measured_at.desc(),
                Measurement.id.desc()
            )
            .all()
        )

        # Skip screenings without measurements
        if not measurements:
            continue

        # Select latest measurement for this screening
        measurement = measurements[0]

        screening_date = screening.screening_date

        reference_date = (
            screening_date.date()
            if isinstance(screening_date, datetime)
            else screening_date
        )

        age = calculate_age(
            individual.date_of_birth,
            reference_date
        )

        visit = {
            "screening_id": screening.id,
            "screening_date": serialize_datetime(
                screening.screening_date
            ),
            "measured_at": serialize_datetime(
                measurement.measured_at
            ),
            "age": age,
            "gender": individual.gender,

            # General measurements
            "height_cm": measurement.height_cm,
            "weight_kg": measurement.weight_kg,
            "bmi": measurement.bmi,
            "waist_cm": measurement.waist_cm,

            # Diabetes measurements
            "fasting_glucose": measurement.fasting_glucose,
            "post_meal_glucose": measurement.post_meal_glucose,
            "glucose_context": measurement.glucose_context,
            "hba1c": measurement.hba1c,

            # Cardiovascular measurements
            "systolic_bp": measurement.systolic_bp,
            "diastolic_bp": measurement.diastolic_bp,
            "pulse_rate": measurement.pulse_rate,
            "total_cholesterol": measurement.total_cholesterol,
            "hdl": measurement.hdl,
            "ldl": measurement.ldl,
            "triglycerides": measurement.triglycerides,
            "spo2": measurement.spo2,

            # Number of raw records represented by this visit
            "measurement_records_in_screening": len(measurements),
        }

        visits.append(visit)

    # 4. Sort visits chronologically
    visits.sort(
        key=lambda visit: (
            visit["screening_date"] or "",
            visit["screening_id"]
        )
    )

    # 5. Calculate historical statistics
    total_completed_screenings = len(
        completed_screenings
    )

    visits_with_measurements = len(visits)

    distinct_screening_dates = len({
        visit["screening_date"][:10]
        for visit in visits
        if visit["screening_date"]
    })

    has_multiple_visits = (
        visits_with_measurements >= 2
    )

    sequence_ready = (
        visits_with_measurements >= MINIMUM_SEQUENCE_VISITS
    )

    # 6. Prepare response
    return {
        "individual_id": individual.id,

        "individual_code": individual.individual_code,

        "total_completed_screenings": (
            total_completed_screenings
        ),

        "visits_with_measurements": (
            visits_with_measurements
        ),

        "distinct_screening_dates": (
            distinct_screening_dates
        ),

        "has_multiple_visits": has_multiple_visits,

        "sequence_ready": sequence_ready,

        "minimum_sequence_visits": (
            MINIMUM_SEQUENCE_VISITS
        ),

        "forecasting_status": (
            "historical_data_available"
            if sequence_ready
            else "insufficient_historical_visits"
        ),

        "visits": visits,

        "disclaimer": (
            "Historical health measurements are retrieved "
            "from completed screenings. This endpoint does "
            "not generate medical diagnoses or forecasts."
        ),
    }