from datetime import datetime
from typing import Optional

from pydantic import BaseModel, ConfigDict, Field


class AIExplanationCreate(BaseModel):
    prediction_id: int = Field(gt=0)
    explanation: str = Field(min_length=1)
    language: str = "English"
    generated_by: Optional[str] = None


class AIExplanationResponse(BaseModel):
    id: int
    prediction_id: int
    explanation: str
    language: Optional[str]
    generated_by: Optional[str]
    created_at: Optional[datetime]

    model_config = ConfigDict(from_attributes=True)