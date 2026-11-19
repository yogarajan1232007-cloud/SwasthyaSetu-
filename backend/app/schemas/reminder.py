from datetime import datetime
from typing import Optional, Literal

from pydantic import BaseModel, ConfigDict, Field


class ReminderCreate(BaseModel):
    individual_id: int
    reminder_type: str = Field(..., min_length=1, max_length=50)
    title: str = Field(..., min_length=1, max_length=200)
    message: str = Field(..., min_length=1)
    scheduled_at: datetime


class ReminderUpdate(BaseModel):
    reminder_type: Optional[str] = Field(None, min_length=1, max_length=50)
    title: Optional[str] = Field(None, min_length=1, max_length=200)
    message: Optional[str] = Field(None, min_length=1)
    scheduled_at: Optional[datetime] = None
    status: Optional[
        Literal["pending", "sent", "completed", "cancelled"]
    ] = None


class ReminderResponse(BaseModel):
    id: int
    individual_id: int
    reminder_type: str
    title: str
    message: str
    scheduled_at: datetime
    status: str
    created_at: Optional[datetime] = None

    model_config = ConfigDict(from_attributes=True)