from datetime import datetime, timezone

from fastapi import HTTPException
from sqlalchemy.orm import Session
from sqlalchemy import desc

from app.models.ai_model_version import AIModelVersion
from app.models.user import User

from app.schemas.ai_model_version import (
    AIModelCreate,
    AIModelUpdate,
    AIModelApproval
)


def create_ai_model(db: Session, data: AIModelCreate):

    existing = db.query(AIModelVersion).filter(
        AIModelVersion.model_name == data.model_name,
        AIModelVersion.version == data.version
    ).first()

    if existing:
        raise HTTPException(
            status_code=400,
            detail="This model version already exists"
        )

    model = AIModelVersion(
        model_name=data.model_name,
        model_type=data.model_type,
        version=data.version,
        framework=data.framework,
        model_path=data.model_path,
        dataset_type=data.dataset_type,
        performance_metrics=data.performance_metrics,
        validation_status="experimental",
        approval_status="pending",
        is_active=False
    )

    try:
        db.add(model)
        db.commit()
        db.refresh(model)

        return model

    except Exception:
        db.rollback()
        raise HTTPException(
            status_code=500,
            detail="Failed to register AI model"
        )


def get_ai_models(
    db: Session,
    model_type: str = None
):

    query = db.query(AIModelVersion)

    if model_type:
        query = query.filter(
            AIModelVersion.model_type == model_type
        )

    return query.order_by(
        desc(AIModelVersion.id)
    ).all()


def get_ai_model_by_id(
    db: Session,
    model_id: int
):

    model = db.query(AIModelVersion).filter(
        AIModelVersion.id == model_id
    ).first()

    if not model:
        raise HTTPException(
            status_code=404,
            detail="AI model not found"
        )

    return model


def update_ai_model(
    db: Session,
    model_id: int,
    data: AIModelUpdate
):

    model = get_ai_model_by_id(db, model_id)

    if model.is_active:
        raise HTTPException(
            status_code=400,
            detail="Deactivate the model before editing it"
        )

    update_data = data.model_dump(
        exclude_unset=True
    )

    for field, value in update_data.items():
        setattr(model, field, value)

    try:
        db.commit()
        db.refresh(model)
        return model

    except Exception:
        db.rollback()
        raise HTTPException(
            status_code=500,
            detail="Failed to update AI model"
        )


def approve_ai_model(
    db: Session,
    model_id: int,
    data: AIModelApproval
):

    model = get_ai_model_by_id(db, model_id)

    if data.approval_status == "approved":

        if data.validation_status != "validated":
            raise HTTPException(
                status_code=400,
                detail="Only validated models can be approved"
            )

        if not data.approved_by:
            raise HTTPException(
                status_code=400,
                detail="Approver ID is required"
            )

        approver = db.query(User).filter(
            User.id == data.approved_by,
            User.is_active == True
        ).first()

        if not approver:
            raise HTTPException(
                status_code=404,
                detail="Approver not found or inactive"
            )

        model.approved_by = approver.id
        model.approved_at = datetime.now(timezone.utc)

    else:
        model.approved_by = None
        model.approved_at = None

    model.approval_status = data.approval_status
    model.validation_status = data.validation_status

    if data.approval_status != "approved":
        model.is_active = False

    try:
        db.commit()
        db.refresh(model)
        return model

    except Exception:
        db.rollback()
        raise HTTPException(
            status_code=500,
            detail="Failed to update model approval"
        )


def activate_ai_model(
    db: Session,
    model_id: int
):

    model = get_ai_model_by_id(db, model_id)

    if model.approval_status != "approved":
        raise HTTPException(
            status_code=400,
            detail="Only approved models can be activated"
        )

    if model.validation_status != "validated":
        raise HTTPException(
            status_code=400,
            detail="Only validated models can be activated"
        )

    # Deactivate existing active model of the same type
    db.query(AIModelVersion).filter(
        AIModelVersion.model_type == model.model_type,
        AIModelVersion.is_active == True
    ).update(
        {"is_active": False},
        synchronize_session=False
    )

    model.is_active = True

    try:
        db.commit()
        db.refresh(model)
        return model

    except Exception:
        db.rollback()
        raise HTTPException(
            status_code=500,
            detail="Failed to activate AI model"
        )


def deactivate_ai_model(
    db: Session,
    model_id: int
):

    model = get_ai_model_by_id(db, model_id)

    model.is_active = False

    try:
        db.commit()
        db.refresh(model)
        return model

    except Exception:
        db.rollback()
        raise HTTPException(
            status_code=500,
            detail="Failed to deactivate AI model"
        )