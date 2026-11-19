from datetime import datetime
from typing import Optional

from pydantic import BaseModel, ConfigDict, Field


class ScreeningCreate(BaseModel):
    individual_id: int
    worker_id: int
    assignment_id: Optional[int] = None
    screening_type: str = Field(default="monthly", max_length=50)
    medical_history: Optional[str] = None
    remarks: Optional[str] = None


class ScreeningUpdate(BaseModel):
    status: Optional[str] = Field(
        default=None,
        pattern="^(pending|in_progress|completed|cancelled)$"
    )
    medical_history: Optional[str] = None
    remarks: Optional[str] = None


class ScreeningResponse(BaseModel):
    id: int
    individual_id: int
    worker_id: int
    assignment_id: Optional[int]
    screening_type: Optional[str]
    screening_date: Optional[datetime]
    status: Optional[str]
    medical_history: Optional[str]
    remarks: Optional[str]
    created_at: Optional[datetime]

    model_config = ConfigDict(from_attributes=True)