from typing import Optional

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.database.session import get_db

from app.schemas.alert import (
    AlertCreate,
    AlertStatusUpdate,
    AlertResponse
)

from app.services.alert_service import (
    create_alert,
    get_alerts,
    get_alert_by_id,
    update_alert_status
)


router = APIRouter()


@router.post(
    "/",
    response_model=AlertResponse
)
def register_alert(
    alert_data: AlertCreate,
    db: Session = Depends(get_db)
):

    return create_alert(db, alert_data)


@router.get(
    "/",
    response_model=list[AlertResponse]
)
def list_alerts(
    individual_id: Optional[int] = None,
    prediction_id: Optional[int] = None,
    severity: Optional[str] = None,
    status: Optional[str] = None,
    assigned_to: Optional[int] = None,
    db: Session = Depends(get_db)
):

    return get_alerts(
        db,
        individual_id,
        prediction_id,
        severity,
        status,
        assigned_to
    )


@router.get(
    "/{alert_id}",
    response_model=AlertResponse
)
def retrieve_alert(
    alert_id: int,
    db: Session = Depends(get_db)
):

    return get_alert_by_id(db, alert_id)


@router.patch(
    "/{alert_id}/status",
    response_model=AlertResponse
)
def change_alert_status(
    alert_id: int,
    status_data: AlertStatusUpdate,
    db: Session = Depends(get_db)
):

    return update_alert_status(
        db,
        alert_id,
        status_data.status
    )


@router.patch(
    "/{alert_id}/resolve",
    response_model=AlertResponse
)
def resolve_alert(
    alert_id: int,
    db: Session = Depends(get_db)
):

    return update_alert_status(
        db,
        alert_id,
        "resolved"
    )