from sqlalchemy import (
    Column, Integer, String, DateTime, ForeignKey, Float, Text
)
from sqlalchemy.sql import func

from app.database.base import Base
from sqlalchemy import Column, Integer, String, Float, ForeignKey, Text, DateTime, Boolean


class AIPrediction(Base):
    __tablename__ = "ai_predictions"

    id = Column(Integer, primary_key=True, index=True)

    individual_id = Column(
        Integer,
        ForeignKey("individuals.id"),
        nullable=False
    )

    screening_id = Column(
        Integer,
        ForeignKey("screenings.id"),
        nullable=True
    )

    model_version_id = Column(
        Integer,
        ForeignKey("ai_model_versions.id"),
        nullable=False
    )

    prediction_type = Column(
        String(50),
        nullable=False
    )

    risk_level = Column(String(30), nullable=True)

    prediction_value = Column(Float, nullable=True)

    confidence_score = Column(Float, nullable=True)

    result_data = Column(Text, nullable=True)

    is_experimental = Column(
        Boolean,
        default=True
    )

    created_at = Column(
        DateTime(timezone=True),
        server_default=func.now()
    )