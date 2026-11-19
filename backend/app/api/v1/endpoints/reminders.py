from typing import Optional

from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session

from app.database.session import get_db
from app.schemas.reminder import (
    ReminderCreate,
    ReminderUpdate,
    ReminderResponse
)
from app.services.reminder_service import (
    create_reminder,
    get_reminders,
    get_reminder_by_id,
    update_reminder
)

router = APIRouter(
    prefix="/reminders",
    tags=["Reminder Management"]
)


# Create Reminder
@router.post("/", response_model=ReminderResponse)
def create_new_reminder(
    reminder_data: ReminderCreate,
    db: Session = Depends(get_db)
):
    return create_reminder(db, reminder_data)


# Get All Reminders with Optional Filters
@router.get("/", response_model=list[ReminderResponse])
def list_reminders(
    individual_id: Optional[int] = Query(None),
    status_filter: Optional[str] = Query(None, alias="status"),
    db: Session = Depends(get_db)
):
    return get_reminders(
        db,
        individual_id=individual_id,
        status_filter=status_filter
    )


# Get Reminder by ID
@router.get("/{reminder_id}", response_model=ReminderResponse)
def retrieve_reminder(
    reminder_id: int,
    db: Session = Depends(get_db)
):
    return get_reminder_by_id(db, reminder_id)


# Update Reminder
@router.put("/{reminder_id}", response_model=ReminderResponse)
def modify_reminder(
    reminder_id: int,
    reminder_data: ReminderUpdate,
    db: Session = Depends(get_db)
):
    return update_reminder(
        db,
        reminder_id,
        reminder_data
    )