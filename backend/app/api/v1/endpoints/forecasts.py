from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.database.session import get_db

from app.services.forecast_service import (
    generate_individual_forecast
)


router = APIRouter()


# --------------------------------------------------
# DIABETES FORECAST
# --------------------------------------------------

@router.post("/diabetes/{individual_id}")
def generate_diabetes_forecast(
    individual_id: int,
    db: Session = Depends(get_db)
):

    return generate_individual_forecast(
        db=db,
        individual_id=individual_id,
        prediction_type="diabetes"
    )


# --------------------------------------------------
# CARDIOVASCULAR FORECAST
# --------------------------------------------------

@router.post("/cardiovascular/{individual_id}")
def generate_cardiovascular_forecast(
    individual_id: int,
    db: Session = Depends(get_db)
):

    return generate_individual_forecast(
        db=db,
        individual_id=individual_id,
        prediction_type="cardiovascular"
    )