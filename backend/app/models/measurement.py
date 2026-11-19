from sqlalchemy import (
    Column,
    Integer,
    Float,
    String,
    DateTime,
    ForeignKey,
    Text
)
from sqlalchemy.sql import func

from app.database.base import Base


class Measurement(Base):
    __tablename__ = "measurements"

    id = Column(Integer, primary_key=True, index=True)

    screening_id = Column(
        Integer,
        ForeignKey("screenings.id"),
        nullable=False
    )

    individual_id = Column(
        Integer,
        ForeignKey("individuals.id"),
        nullable=False
    )

    height_cm = Column(Float, nullable=True)

    weight_kg = Column(Float, nullable=True)

    bmi = Column(Float, nullable=True)

    waist_cm = Column(Float, nullable=True)

    pulse_rate = Column(Integer, nullable=True)

    systolic_bp = Column(Float, nullable=True)

    diastolic_bp = Column(Float, nullable=True)

    fasting_glucose = Column(Float, nullable=True)

    post_meal_glucose = Column(Float, nullable=True)

    glucose_context = Column(String(50), nullable=True)

    hba1c = Column(Float, nullable=True)

    total_cholesterol = Column(Float, nullable=True)

    hdl = Column(Float, nullable=True)

    ldl = Column(Float, nullable=True)

    triglycerides = Column(Float, nullable=True)

    spo2 = Column(Float, nullable=True)

    measurement_notes = Column(Text, nullable=True)

    measured_at = Column(
        DateTime(timezone=True),
        server_default=func.now()
    )

    created_at = Column(
        DateTime(timezone=True),
        server_default=func.now()
    )