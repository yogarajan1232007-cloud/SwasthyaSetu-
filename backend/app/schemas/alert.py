from datetime import datetime
from typing import Optional

from pydantic import BaseModel, ConfigDict, Field


class AlertCreate(BaseModel):
    individual_id: int = Field(gt=0)
    prediction_id: Optional[int] = Field(default=None, gt=0)
    assigned_to: Optional[int] = Field(default=None, gt=0)

    severity: str = Field(min_length=1, max_length=30)
    title: str = Field(min_length=1, max_length=200)
    message: str = Field(min_length=1)


class AlertStatusUpdate(BaseModel):
    status: str


class AlertResponse(BaseModel):
    id: int
    individual_id: int
    prediction_id: Optional[int]
    assigned_to: Optional[int]

    severity: str
    title: str
    message: str

    status: Optional[str]
    created_at: Optional[datetime]
    resolved_at: Optional[datetime]

    model_config = ConfigDict(from_attributes=True)