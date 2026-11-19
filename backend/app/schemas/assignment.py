from datetime import date, datetime
from typing import Optional

from pydantic import BaseModel, ConfigDict, Field


class AssignmentCreate(BaseModel):
    worker_id: int
    household_id: int
    assigned_by: int
    assignment_date: date
    due_date: Optional[date] = None
    remarks: Optional[str] = Field(default=None, max_length=500)


class AssignmentUpdate(BaseModel):
    due_date: Optional[date] = None
    status: Optional[str] = None
    remarks: Optional[str] = Field(default=None, max_length=500)


class AssignmentResponse(BaseModel):
    id: int
    worker_id: int
    household_id: int
    assigned_by: int
    assignment_date: date
    due_date: Optional[date]
    status: str
    remarks: Optional[str]
    created_at: Optional[datetime]

    model_config = ConfigDict(from_attributes=True)