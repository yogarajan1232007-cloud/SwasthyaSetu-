from sqlalchemy.orm import Session
from sqlalchemy import desc
from fastapi import HTTPException

from app.models.measurement import Measurement
from app.models.screening import Screening

from app.schemas.measurement import (
    MeasurementCreate,
    MeasurementUpdate
)


def calculate_bmi(height_cm, weight_kg):
    if height_cm and weight_kg:
        height_m = height_cm / 100
        return round(weight_kg / (height_m ** 2), 2)

    return None


def create_measurement(db: Session, data: MeasurementCreate):

    # 1. Verify screening
    screening = db.query(Screening).filter(
        Screening.id == data.screening_id
    ).first()

    if not screening:
        raise HTTPException(
            status_code=404,
            detail="Screening not found"
        )

    if screening.status != "in_progress":
        raise HTTPException(
            status_code=400,
            detail="Measurements can only be added to an in-progress screening"
        )

    # 2. Calculate BMI
    bmi = calculate_bmi(
        data.height_cm,
        data.weight_kg
    )

    # 3. Create measurement
    measurement = Measurement(
        screening_id=screening.id,
        individual_id=screening.individual_id,
        height_cm=data.height_cm,
        weight_kg=data.weight_kg,
        bmi=bmi,
        waist_cm=data.waist_cm,
        pulse_rate=data.pulse_rate,
        systolic_bp=data.systolic_bp,
        diastolic_bp=data.diastolic_bp,
        fasting_glucose=data.fasting_glucose,
        post_meal_glucose=data.post_meal_glucose,
        glucose_context=data.glucose_context,
        hba1c=data.hba1c,
        total_cholesterol=data.total_cholesterol,
        hdl=data.hdl,
        ldl=data.ldl,
        triglycerides=data.triglycerides,
        spo2=data.spo2,
        measurement_notes=data.measurement_notes
    )

    try:
        db.add(measurement)
        db.commit()
        db.refresh(measurement)

        return measurement

    except Exception:
        db.rollback()
        raise HTTPException(
            status_code=500,
            detail="Failed to save measurements"
        )


def get_measurements(
    db: Session,
    screening_id: int = None,
    individual_id: int = None
):

    query = db.query(Measurement)

    if screening_id is not None:
        query = query.filter(
            Measurement.screening_id == screening_id
        )

    if individual_id is not None:
        query = query.filter(
            Measurement.individual_id == individual_id
        )

    return query.order_by(
        desc(Measurement.id)
    ).all()


def get_measurement_by_id(db: Session, measurement_id: int):

    measurement = db.query(Measurement).filter(
        Measurement.id == measurement_id
    ).first()

    if not measurement:
        raise HTTPException(
            status_code=404,
            detail="Measurement not found"
        )

    return measurement


def update_measurement(
    db: Session,
    measurement_id: int,
    data: MeasurementUpdate
):

    measurement = get_measurement_by_id(
        db,
        measurement_id
    )

    # Only allow updates while screening is in progress
    screening = db.query(Screening).filter(
        Screening.id == measurement.screening_id
    ).first()

    if not screening or screening.status != "in_progress":
        raise HTTPException(
            status_code=400,
            detail="Measurements can only be updated while screening is in progress"
        )

    update_data = data.model_dump(exclude_unset=True)

    # Update supplied fields
    for field, value in update_data.items():
        setattr(measurement, field, value)

    # Recalculate BMI using updated and existing values
    measurement.bmi = calculate_bmi(
        measurement.height_cm,
        measurement.weight_kg
    )

    try:
        db.commit()
        db.refresh(measurement)

        return measurement

    except Exception:
        db.rollback()
        raise HTTPException(
            status_code=500,
            detail="Failed to update measurements"
        )