from datetime import date, datetime
from typing import Optional

from pydantic import BaseModel, ConfigDict, Field


class FollowUpCreate(BaseModel):
    individual_id: int = Field(gt=0)
    worker_id: Optional[int] = Field(default=None, gt=0)
    screening_id: Optional[int] = Field(default=None, gt=0)

    followup_type: str = Field(min_length=1, max_length=100)
    due_date: date

    notes: Optional[str] = None


class FollowUpUpdate(BaseModel):
    worker_id: Optional[int] = Field(default=None, gt=0)
    followup_type: Optional[str] = Field(default=None, min_length=1)
    due_date: Optional[date] = None
    status: Optional[str] = None
    notes: Optional[str] = None


class FollowUpResponse(BaseModel):
    id: int
    individual_id: int
    worker_id: Optional[int]
    screening_id: Optional[int]

    followup_type: str
    due_date: date
    status: Optional[str]
    notes: Optional[str]

    completed_at: Optional[datetime]
    created_at: Optional[datetime]

    model_config = ConfigDict(from_attributes=True)