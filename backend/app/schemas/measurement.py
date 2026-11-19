from datetime import datetime
from typing import Optional

from pydantic import BaseModel, ConfigDict, Field


class MeasurementCreate(BaseModel):
    screening_id: int

    height_cm: Optional[float] = Field(default=None, gt=0)
    weight_kg: Optional[float] = Field(default=None, gt=0)
    waist_cm: Optional[float] = Field(default=None, gt=0)

    pulse_rate: Optional[int] = Field(default=None, gt=0)

    systolic_bp: Optional[float] = Field(default=None, gt=0)
    diastolic_bp: Optional[float] = Field(default=None, gt=0)

    fasting_glucose: Optional[float] = Field(default=None, gt=0)
    post_meal_glucose: Optional[float] = Field(default=None, gt=0)
    glucose_context: Optional[str] = None
    hba1c: Optional[float] = Field(default=None, gt=0)

    total_cholesterol: Optional[float] = Field(default=None, gt=0)
    hdl: Optional[float] = Field(default=None, gt=0)
    ldl: Optional[float] = Field(default=None, gt=0)
    triglycerides: Optional[float] = Field(default=None, gt=0)

    spo2: Optional[float] = Field(default=None, gt=0, le=100)

    measurement_notes: Optional[str] = None


class MeasurementUpdate(BaseModel):
    height_cm: Optional[float] = Field(default=None, gt=0)
    weight_kg: Optional[float] = Field(default=None, gt=0)
    waist_cm: Optional[float] = Field(default=None, gt=0)

    pulse_rate: Optional[int] = Field(default=None, gt=0)

    systolic_bp: Optional[float] = Field(default=None, gt=0)
    diastolic_bp: Optional[float] = Field(default=None, gt=0)

    fasting_glucose: Optional[float] = Field(default=None, gt=0)
    post_meal_glucose: Optional[float] = Field(default=None, gt=0)
    glucose_context: Optional[str] = None
    hba1c: Optional[float] = Field(default=None, gt=0)

    total_cholesterol: Optional[float] = Field(default=None, gt=0)
    hdl: Optional[float] = Field(default=None, gt=0)
    ldl: Optional[float] = Field(default=None, gt=0)
    triglycerides: Optional[float] = Field(default=None, gt=0)

    spo2: Optional[float] = Field(default=None, gt=0, le=100)

    measurement_notes: Optional[str] = None


class MeasurementResponse(BaseModel):
    id: int
    screening_id: int
    individual_id: int

    height_cm: Optional[float] = None
    weight_kg: Optional[float] = None
    bmi: Optional[float] = None
    waist_cm: Optional[float] = None

    pulse_rate: Optional[int] = None
    systolic_bp: Optional[float] = None
    diastolic_bp: Optional[float] = None

    fasting_glucose: Optional[float] = None
    post_meal_glucose: Optional[float] = None
    glucose_context: Optional[str] = None
    hba1c: Optional[float] = None

    total_cholesterol: Optional[float] = None
    hdl: Optional[float] = None
    ldl: Optional[float] = None
    triglycerides: Optional[float] = None

    spo2: Optional[float] = None
    measurement_notes: Optional[str] = None

    measured_at: Optional[datetime] = None
    created_at: Optional[datetime] = None

    model_config = ConfigDict(from_attributes=True)