from datetime import datetime
from typing import Optional

from pydantic import BaseModel, ConfigDict, Field


class ImagingFileUpdate(BaseModel):
    status: Optional[str] = Field(
        default=None,
        pattern="^(uploaded|processing|processed|rejected)$"
    )

    notes: Optional[str] = None


class ImagingFileResponse(BaseModel):
    id: int
    individual_id: int
    screening_id: Optional[int]
    uploaded_by: Optional[int]

    modality: str
    body_region: Optional[str]

    file_path: str
    file_format: Optional[str]

    study_date: Optional[datetime]
    status: Optional[str]
    notes: Optional[str]

    created_at: Optional[datetime]

    model_config = ConfigDict(from_attributes=True)