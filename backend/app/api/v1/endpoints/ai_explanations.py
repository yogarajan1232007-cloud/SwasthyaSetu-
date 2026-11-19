from typing import Optional

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.database.session import get_db

from app.schemas.ai_explanation import (
    AIExplanationCreate,
    AIExplanationResponse
)

from app.services.ai_explanation_service import (
    create_explanation,
    get_explanations,
    get_explanation_by_id
)


router = APIRouter()


@router.post(
    "/",
    response_model=AIExplanationResponse
)
def register_explanation(
    explanation_data: AIExplanationCreate,
    db: Session = Depends(get_db)
):

    return create_explanation(db, explanation_data)


@router.get(
    "/",
    response_model=list[AIExplanationResponse]
)
def list_explanations(
    prediction_id: Optional[int] = None,
    db: Session = Depends(get_db)
):

    return get_explanations(
        db,
        prediction_id
    )


@router.get(
    "/{explanation_id}",
    response_model=AIExplanationResponse
)
def retrieve_explanation(
    explanation_id: int,
    db: Session = Depends(get_db)
):

    return get_explanation_by_id(
        db,
        explanation_id
    )