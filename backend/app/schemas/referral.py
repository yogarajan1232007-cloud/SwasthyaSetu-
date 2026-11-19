from datetime import datetime
from typing import Optional

from pydantic import BaseModel, ConfigDict, Field, field_validator


VALID_URGENCIES = ["routine", "urgent", "emergency"]

VALID_STATUSES = [
    "pending",
    "referred",
    "scheduled",
    "in_progress",
    "completed",
    "cancelled"
]


class ReferralCreate(BaseModel):

    individual_id: int = Field(gt=0)
    screening_id: Optional[int] = Field(default=None, gt=0)
    created_by: int = Field(gt=0)

    facility_name: str = Field(min_length=1, max_length=200)
    clinician_name: Optional[str] = Field(default=None, max_length=150)
    reason: str = Field(min_length=1)

    urgency: str = "routine"
    appointment_at: Optional[datetime] = None

    notes: Optional[str] = None

    @field_validator("facility_name", "reason")
    @classmethod
    def validate_required_text(cls, value):
        value = value.strip()

        if not value:
            raise ValueError("This field cannot be empty")

        return value

    @field_validator("urgency")
    @classmethod
    def validate_urgency(cls, value):
        value = value.strip().lower()

        if value not in VALID_URGENCIES:
            raise ValueError(
                "Urgency must be routine, urgent or emergency"
            )

        return value

    @field_validator("clinician_name", "notes")
    @classmethod
    def clean_optional_text(cls, value):
        if value is not None:
            value = value.strip()
            return value or None

        return value


class ReferralUpdate(BaseModel):

    status: Optional[str] = None
    urgency: Optional[str] = None

    appointment_at: Optional[datetime] = None

    clinician_name: Optional[str] = Field(
        default=None,
        max_length=150
    )

    notes: Optional[str] = None
    outcome: Optional[str] = None

    @field_validator("status")
    @classmethod
    def validate_status(cls, value):
        if value is not None:
            value = value.strip().lower()

            if value not in VALID_STATUSES:
                raise ValueError(
                    "Invalid status. Use pending, referred, scheduled, "
                    "in_progress, completed or cancelled"
                )

        return value

    @field_validator("urgency")
    @classmethod
    def validate_urgency(cls, value):
        if value is not None:
            value = value.strip().lower()

            if value not in VALID_URGENCIES:
                raise ValueError(
                    "Urgency must be routine, urgent or emergency"
                )

        return value

    @field_validator("clinician_name", "notes", "outcome")
    @classmethod
    def clean_optional_text(cls, value):
        if value is not None:
            value = value.strip()
            return value or None

        return value


class ReferralResponse(BaseModel):

    id: int

    individual_id: int
    screening_id: Optional[int]
    created_by: int

    facility_name: str
    clinician_name: Optional[str]
    reason: str

    urgency: Optional[str]
    status: Optional[str]

    referred_at: Optional[datetime]
    appointment_at: Optional[datetime]

    notes: Optional[str]
    outcome: Optional[str]

    model_config = ConfigDict(from_attributes=True)