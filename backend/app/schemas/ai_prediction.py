
from datetime import datetime
from typing import Optional

from pydantic import BaseModel, ConfigDict, Field


class AIPredictionCreate(BaseModel):
    individual_id: int = Field(gt=0)
    screening_id: Optional[int] = Field(default=None, gt=0)
    model_version_id: int = Field(gt=0)

    prediction_type: str = Field(min_length=1, max_length=50)

    risk_level: Optional[str] = None
    prediction_value: Optional[float] = None
    confidence_score: Optional[float] = Field(
        default=None,
        ge=0,
        le=1
    )

    result_data: Optional[str] = None
    is_experimental: bool = True


class AIPredictionResponse(BaseModel):
    id: int
    individual_id: int
    screening_id: Optional[int]
    model_version_id: int

    prediction_type: str
    risk_level: Optional[str]
    prediction_value: Optional[float]
    confidence_score: Optional[float]

    result_data: Optional[str]
    is_experimental: bool
    created_at: Optional[datetime]

    model_config = ConfigDict(from_attributes=True)
