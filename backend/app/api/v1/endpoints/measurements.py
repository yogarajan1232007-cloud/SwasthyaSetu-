from typing import Optional

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.database.session import get_db

from app.schemas.measurement import (
    MeasurementCreate,
    MeasurementUpdate,
    MeasurementResponse
)

from app.services.measurement_service import (
    create_measurement,
    get_measurements,
    get_measurement_by_id,
    update_measurement
)


router = APIRouter(
    prefix="/measurements",
    tags=["Measurement Management"]
)


@router.post("/", response_model=MeasurementResponse)
def create_new_measurement(
    data: MeasurementCreate,
    db: Session = Depends(get_db)
):
    return create_measurement(db, data)


@router.get("/", response_model=list[MeasurementResponse])
def list_measurements(
    screening_id: Optional[int] = None,
    individual_id: Optional[int] = None,
    db: Session = Depends(get_db)
):
    return get_measurements(
        db,
        screening_id=screening_id,
        individual_id=individual_id
    )


@router.get("/{measurement_id}", response_model=MeasurementResponse)
def get_measurement(
    measurement_id: int,
    db: Session = Depends(get_db)
):
    return get_measurement_by_id(
        db,
        measurement_id
    )


@router.put("/{measurement_id}", response_model=MeasurementResponse)
def update_existing_measurement(
    measurement_id: int,
    data: MeasurementUpdate,
    db: Session = Depends(get_db)
):
    return update_measurement(
        db,
        measurement_id,
        data
    )