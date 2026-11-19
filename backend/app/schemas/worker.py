from typing import Optional
from datetime import datetime

from pydantic import BaseModel, ConfigDict, Field


class WorkerCreate(BaseModel):
    full_name: str = Field(min_length=2, max_length=150)
    employee_id: str = Field(min_length=2, max_length=50)
    mobile_number: Optional[str] = Field(default=None, max_length=15)
    email: Optional[str] = None

    designation: Optional[str] = "Health Worker"
    area: str = Field(min_length=2, max_length=150)
    employee_code: str = Field(min_length=2, max_length=50)


class WorkerUpdate(BaseModel):
    full_name: Optional[str] = Field(default=None, max_length=150)
    mobile_number: Optional[str] = Field(default=None, max_length=15)
    email: Optional[str] = None
    designation: Optional[str] = None
    area: Optional[str] = None
    is_available: Optional[bool] = None


class WorkerResponse(BaseModel):
    id: int
    user_id: int
    employee_code: str
    designation: Optional[str]
    area: str
    is_available: bool

    full_name: str
    employee_id: str
    mobile_number: Optional[str]
    email: Optional[str]
    is_active: bool

    model_config = ConfigDict(from_attributes=True)