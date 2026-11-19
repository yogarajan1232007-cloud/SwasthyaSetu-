from datetime import datetime
from typing import Optional

from pydantic import BaseModel, ConfigDict, Field


class NotificationCreate(BaseModel):
    user_id: int
    individual_id: Optional[int] = None

    title: str = Field(..., min_length=1, max_length=200)
    message: str = Field(..., min_length=1)

    notification_type: str = Field(
        ..., min_length=1, max_length=50
    )


class NotificationUpdate(BaseModel):
    is_read: Optional[bool] = None


class NotificationResponse(BaseModel):
    id: int
    user_id: int
    individual_id: Optional[int] = None

    title: str
    message: str
    notification_type: str

    is_read: bool
    created_at: Optional[datetime] = None

    model_config = ConfigDict(from_attributes=True)