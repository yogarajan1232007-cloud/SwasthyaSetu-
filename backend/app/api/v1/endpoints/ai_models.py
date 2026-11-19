from typing import Optional

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.database.session import get_db

from app.schemas.ai_model_version import (
    AIModelCreate,
    AIModelUpdate,
    AIModelApproval,
    AIModelResponse
)

from app.services.ai_model_service import (
    create_ai_model,
    get_ai_models,
    get_ai_model_by_id,
    update_ai_model,
    approve_ai_model,
    activate_ai_model,
    deactivate_ai_model
)


router = APIRouter(
    prefix="/ai-models",
    tags=["AI Model Management"]
)


@router.post("/", response_model=AIModelResponse)
def register_model(
    data: AIModelCreate,
    db: Session = Depends(get_db)
):
    return create_ai_model(db, data)


@router.get("/", response_model=list[AIModelResponse])
def list_models(
    model_type: Optional[str] = None,
    db: Session = Depends(get_db)
):
    return get_ai_models(db, model_type)


@router.get("/{model_id}", response_model=AIModelResponse)
def get_model(
    model_id: int,
    db: Session = Depends(get_db)
):
    return get_ai_model_by_id(db, model_id)


@router.put("/{model_id}", response_model=AIModelResponse)
def update_model(
    model_id: int,
    data: AIModelUpdate,
    db: Session = Depends(get_db)
):
    return update_ai_model(db, model_id, data)


@router.patch("/{model_id}/approval", response_model=AIModelResponse)
def approve_model(
    model_id: int,
    data: AIModelApproval,
    db: Session = Depends(get_db)
):
    return approve_ai_model(db, model_id, data)


@router.patch("/{model_id}/activate", response_model=AIModelResponse)
def activate_model(
    model_id: int,
    db: Session = Depends(get_db)
):
    return activate_ai_model(db, model_id)


@router.patch("/{model_id}/deactivate", response_model=AIModelResponse)
def deactivate_model(
    model_id: int,
    db: Session = Depends(get_db)
):
    return deactivate_ai_model(db, model_id)