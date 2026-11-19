from typing import Optional

from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session

from app.database.session import get_db

from app.schemas.notification import (
    NotificationCreate,
    NotificationUpdate,
    NotificationResponse
)

from app.services.notification_service import (
    create_notification,
    get_notifications,
    get_notification_by_id,
    update_notification,
    mark_notification_as_read
)

router = APIRouter(
    prefix="/notifications",
    tags=["Notification Management"]
)


# Create Notification
@router.post("/", response_model=NotificationResponse)
def create_new_notification(
    notification_data: NotificationCreate,
    db: Session = Depends(get_db)
):
    return create_notification(db, notification_data)


# List Notifications
@router.get("/", response_model=list[NotificationResponse])
def list_notifications(
    user_id: Optional[int] = Query(None),
    individual_id: Optional[int] = Query(None),
    is_read: Optional[bool] = Query(None),
    notification_type: Optional[str] = Query(None),
    db: Session = Depends(get_db)
):
    return get_notifications(
        db,
        user_id=user_id,
        individual_id=individual_id,
        is_read=is_read,
        notification_type=notification_type
    )


# Retrieve Notification
@router.get("/{notification_id}", response_model=NotificationResponse)
def retrieve_notification(
    notification_id: int,
    db: Session = Depends(get_db)
):
    return get_notification_by_id(db, notification_id)


# Update Notification
@router.put("/{notification_id}", response_model=NotificationResponse)
def modify_notification(
    notification_id: int,
    notification_data: NotificationUpdate,
    db: Session = Depends(get_db)
):
    return update_notification(
        db,
        notification_id,
        notification_data
    )


# Mark Notification as Read
@router.patch("/{notification_id}/read", response_model=NotificationResponse)
def mark_as_read(
    notification_id: int,
    db: Session = Depends(get_db)
):
    return mark_notification_as_read(db, notification_id)