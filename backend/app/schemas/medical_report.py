from datetime import datetime
from typing import Optional

from pydantic import BaseModel, ConfigDict, Field


class MedicalReportCreate(BaseModel):
    individual_id: int
    screening_id: Optional[int] = None
    uploaded_by: Optional[int] = None

    report_type: str = Field(min_length=2, max_length=50)
    report_name: str = Field(min_length=2, max_length=200)

    file_path: str = Field(min_length=1, max_length=500)
    file_format: Optional[str] = Field(default=None, max_length=20)

    report_date: Optional[datetime] = None
    notes: Optional[str] = None


class MedicalReportUpdate(BaseModel):
    verification_status: Optional[str] = Field(
        default=None,
        pattern="^(pending|verified|rejected)$"
    )

    notes: Optional[str] = None


class MedicalReportResponse(BaseModel):
    id: int
    individual_id: int
    screening_id: Optional[int]
    uploaded_by: Optional[int]

    report_type: str
    report_name: str

    file_path: str
    file_format: Optional[str]

    report_date: Optional[datetime]
    verification_status: Optional[str]
    notes: Optional[str]

    created_at: Optional[datetime]

    model_config = ConfigDict(from_attributes=True)