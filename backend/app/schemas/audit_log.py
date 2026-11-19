from datetime import datetime
from typing import Optional

from pydantic import BaseModel, ConfigDict, Field


class AuditLogCreate(BaseModel):
    user_id: Optional[int] = None

    action: str = Field(..., min_length=1, max_length=100)
    entity_type: str = Field(..., min_length=1, max_length=100)
    entity_id: Optional[int] = None

    details: Optional[str] = None
    ip_address: Optional[str] = Field(None, max_length=50)


class AuditLogResponse(BaseModel):
    id: int
    user_id: Optional[int] = None

    action: str
    entity_type: str
    entity_id: Optional[int] = None

    details: Optional[str] = None
    ip_address: Optional[str] = None

    created_at: Optional[datetime] = None

    model_config = ConfigDict(from_attributes=True)