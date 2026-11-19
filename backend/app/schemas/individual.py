from datetime import date, datetime
from typing import Optional
from pydantic import BaseModel, ConfigDict, Field


class IndividualCreate(BaseModel):
    household_id: int

    full_name: str = Field(min_length=2, max_length=150)
    date_of_birth: Optional[date] = None
    gender: Optional[str] = None
    mobile_number: Optional[str] = Field(default=None, max_length=15)
    blood_group: Optional[str] = Field(default=None, max_length=5)


class IndividualUpdate(BaseModel):
    full_name: Optional[str] = Field(default=None, max_length=150)
    date_of_birth: Optional[date] = None
    gender: Optional[str] = None
    mobile_number: Optional[str] = Field(default=None, max_length=15)
    blood_group: Optional[str] = Field(default=None, max_length=5)
    is_active: Optional[bool] = None


class IndividualResponse(BaseModel):
    id: int
    individual_code: str
    household_id: int
    full_name: str
    date_of_birth: Optional[date]
    gender: Optional[str]
    mobile_number: Optional[str]
    blood_group: Optional[str]
    is_active: bool
    created_at: Optional[datetime]

    model_config = ConfigDict(from_attributes=True)