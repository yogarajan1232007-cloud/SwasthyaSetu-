from datetime import datetime
from typing import Optional

from pydantic import BaseModel, ConfigDict, Field


class HouseholdCreate(BaseModel):
    head_of_family: str = Field(min_length=2, max_length=150)
    address: str = Field(min_length=5, max_length=500)
    area: str = Field(min_length=2, max_length=150)
    pincode: Optional[str] = Field(default=None, max_length=10)
    assigned_worker_id: Optional[int] = None


class HouseholdUpdate(BaseModel):
    head_of_family: Optional[str] = Field(default=None, max_length=150)
    address: Optional[str] = Field(default=None, max_length=500)
    area: Optional[str] = Field(default=None, max_length=150)
    pincode: Optional[str] = Field(default=None, max_length=10)
    assigned_worker_id: Optional[int] = None


class HouseholdResponse(BaseModel):
    id: int
    household_code: str
    head_of_family: str
    address: str
    area: str
    pincode: Optional[str]
    assigned_worker_id: Optional[int]
    created_at: Optional[datetime]

    model_config = ConfigDict(from_attributes=True)