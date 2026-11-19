from datetime import datetime
from typing import Optional

from pydantic import BaseModel, ConfigDict, Field


class AIModelCreate(BaseModel):
    model_name: str = Field(min_length=2, max_length=100)

    model_type: str = Field(
        min_length=2,
        max_length=50
    )

    version: str = Field(
        min_length=1,
        max_length=50
    )

    framework: Optional[str] = None

    model_path: Optional[str] = None

    dataset_type: str = Field(
        default="synthetic",
        pattern="^(synthetic|real_world|mixed)$"
    )

    performance_metrics: Optional[str] = None


class AIModelUpdate(BaseModel):
    model_name: Optional[str] = None
    framework: Optional[str] = None
    model_path: Optional[str] = None
    performance_metrics: Optional[str] = None


class AIModelApproval(BaseModel):
    approval_status: str = Field(
        pattern="^(approved|rejected|pending)$"
    )

    validation_status: str = Field(
        pattern="^(experimental|validated|failed)$"
    )

    approved_by: Optional[int] = None


class AIModelResponse(BaseModel):
    id: int
    model_name: str
    model_type: str
    version: str
    framework: Optional[str]
    model_path: Optional[str]

    dataset_type: Optional[str]
    validation_status: Optional[str]
    approval_status: Optional[str]

    is_active: Optional[bool]
    approved_by: Optional[int]
    approved_at: Optional[datetime]

    performance_metrics: Optional[str]
    created_at: Optional[datetime]

    model_config = ConfigDict(from_attributes=True)