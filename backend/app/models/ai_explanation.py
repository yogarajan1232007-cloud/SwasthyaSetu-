from sqlalchemy import (
    Column, Integer, String, DateTime, ForeignKey, Text
)
from sqlalchemy.sql import func

from app.database.base import Base


class AIExplanation(Base):
    __tablename__ = "ai_explanations"

    id = Column(Integer, primary_key=True, index=True)

    prediction_id = Column(
        Integer,
        ForeignKey("ai_predictions.id"),
        nullable=False
    )

    explanation = Column(Text, nullable=False)

    language = Column(String(30), default="English")

    generated_by = Column(String(100), nullable=True)

    created_at = Column(
        DateTime(timezone=True),
        server_default=func.now()
    )