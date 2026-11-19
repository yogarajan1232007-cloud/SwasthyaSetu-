from sqlalchemy.orm import Session
from fastapi import HTTPException, status

from app.models.reminder import Reminder
from app.models.individual import Individual
from app.schemas.reminder import ReminderCreate, ReminderUpdate


def create_reminder(db: Session, reminder_data: ReminderCreate):

    # Check whether the individual exists
    individual = db.query(Individual).filter(
        Individual.id == reminder_data.individual_id
    ).first()

    if not individual:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Individual not found"
        )

    reminder = Reminder(
        individual_id=reminder_data.individual_id,
        reminder_type=reminder_data.reminder_type,
        title=reminder_data.title,
        message=reminder_data.message,
        scheduled_at=reminder_data.scheduled_at,
        status="pending"
    )

    db.add(reminder)
    db.commit()
    db.refresh(reminder)

    return reminder


def get_reminders(
    db: Session,
    individual_id: int = None,
    status_filter: str = None
):

    query = db.query(Reminder)

    if individual_id is not None:
        query = query.filter(
            Reminder.individual_id == individual_id
        )

    if status_filter:
        query = query.filter(
            Reminder.status == status_filter
        )

    return query.order_by(Reminder.scheduled_at.asc()).all()


def get_reminder_by_id(db: Session, reminder_id: int):

    reminder = db.query(Reminder).filter(
        Reminder.id == reminder_id
    ).first()

    if not reminder:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Reminder not found"
        )

    return reminder


def update_reminder(
    db: Session,
    reminder_id: int,
    reminder_data: ReminderUpdate
):

    reminder = get_reminder_by_id(db, reminder_id)

    if reminder.status in ["completed", "cancelled"]:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Completed or cancelled reminders cannot be modified"
        )

    update_data = reminder_data.model_dump(exclude_unset=True)

    for field, value in update_data.items():
        setattr(reminder, field, value)

    db.commit()
    db.refresh(reminder)

    return reminder