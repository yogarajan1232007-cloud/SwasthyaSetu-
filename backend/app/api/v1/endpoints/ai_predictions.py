
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from typing import Optional

from app.database.session import get_db

from app.schemas.ai_prediction import (
    AIPredictionCreate,
    AIPredictionResponse
)

from app.services.ai_prediction_service import (
    create_prediction,
    get_predictions,
    get_prediction_by_id
)
from app.services.ai_inference_service import (
    run_and_save_prediction
)


router = APIRouter()


@router.post(
    "/",
    response_model=AIPredictionResponse
)
def register_prediction(
    prediction_data: AIPredictionCreate,
    db: Session = Depends(get_db)
):

    return create_prediction(db, prediction_data)


@router.get(
    "/",
    response_model=list[AIPredictionResponse]
)
def list_predictions(
    individual_id: Optional[int] = None,
    screening_id: Optional[int] = None,
    prediction_type: Optional[str] = None,
    db: Session = Depends(get_db)
):

    return get_predictions(
        db,
        individual_id,
        screening_id,
        prediction_type
    )
@router.post(
    "/run/{screening_id}/{prediction_type}",
    response_model=AIPredictionResponse
)
def execute_ai_prediction(
    screening_id: int,
    prediction_type: str,
    db: Session = Depends(get_db)
):
    return run_and_save_prediction(
        db=db,
        screening_id=screening_id,
        prediction_type=prediction_type
    )


@router.get(
    "/{prediction_id}",
    response_model=AIPredictionResponse
)
def retrieve_prediction(
    prediction_id: int,
    db: Session = Depends(get_db)
):

    return get_prediction_by_id(db, prediction_id)
