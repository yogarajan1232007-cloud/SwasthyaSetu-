from sqlalchemy.orm import Session
from fastapi import HTTPException, status

from app.models.notification import Notification
from app.models.user import User
from app.models.individual import Individual
from app.schemas.notification import (
    NotificationCreate,
    NotificationUpdate
)


# Create Notification
def create_notification(
    db: Session,
    notification_data: NotificationCreate
):
    # Validate recipient user
    user = db.query(User).filter(
        User.id == notification_data.user_id,
        User.is_active == True
    ).first()

    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Active recipient user not found"
        )

    # Validate individual if provided
    if notification_data.individual_id is not None:
        individual = db.query(Individual).filter(
            Individual.id == notification_data.individual_id
        ).first()

        if not individual:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Individual not found"
            )

    notification = Notification(
        user_id=notification_data.user_id,
        individual_id=notification_data.individual_id,
        title=notification_data.title,
        message=notification_data.message,
        notification_type=notification_data.notification_type,
        is_read=False
    )

    db.add(notification)
    db.commit()
    db.refresh(notification)

    return notification


# Get Notifications with Optional Filters
def get_notifications(
    db: Session,
    user_id: int = None,
    individual_id: int = None,
    is_read: bool = None,
    notification_type: str = None
):
    query = db.query(Notification)

    if user_id is not None:
        query = query.filter(
            Notification.user_id == user_id
        )

    if individual_id is not None:
        query = query.filter(
            Notification.individual_id == individual_id
        )

    if is_read is not None:
        query = query.filter(
            Notification.is_read == is_read
        )

    if notification_type:
        query = query.filter(
            Notification.notification_type == notification_type
        )

    return query.order_by(
        Notification.created_at.desc()
    ).all()


# Get Notification by ID
def get_notification_by_id(
    db: Session,
    notification_id: int
):
    notification = db.query(Notification).filter(
        Notification.id == notification_id
    ).first()

    if not notification:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Notification not found"
        )

    return notification


# Update Notification
def update_notification(
    db: Session,
    notification_id: int,
    notification_data: NotificationUpdate
):
    notification = get_notification_by_id(
        db,
        notification_id
    )

    update_data = notification_data.model_dump(
        exclude_unset=True
    )

    for field, value in update_data.items():
        setattr(notification, field, value)

    db.commit()
    db.refresh(notification)

    return notification


# Mark Notification as Read
def mark_notification_as_read(
    db: Session,
    notification_id: int
):
    notification = get_notification_by_id(
        db,
        notification_id
    )

    if not notification.is_read:
        notification.is_read = True
        db.commit()
        db.refresh(notification)

    return notification