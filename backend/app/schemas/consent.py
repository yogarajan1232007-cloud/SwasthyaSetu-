from datetime import datetime
from typing import Optional

from pydantic import BaseModel, ConfigDict, Field


class ConsentCreate(BaseModel):
    individual_id: int
    worker_id: Optional[int] = None

    consent_status: str = Field(
        pattern="^(granted|declined)$"
    )

    consent_version: Optional[str] = None
    consent_method: Optional[str] = None
    remarks: Optional[str] = None


class ConsentResponse(BaseModel):
    id: int
    individual_id: int
    worker_id: Optional[int]
    consent_status: str
    consent_version: Optional[str]
    consent_method: Optional[str]
    remarks: Optional[str]
    granted_at: Optional[datetime]
    revoked_at: Optional[datetime]
    created_at: Optional[datetime]

    model_config = ConfigDict(from_attributes=True)