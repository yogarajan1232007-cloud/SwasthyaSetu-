from sqlalchemy import (
    Column, Integer, String, DateTime, ForeignKey, Boolean, Text
)
from sqlalchemy.sql import func

from app.database.base import Base


class AIModelVersion(Base):
    __tablename__ = "ai_model_versions"

    id = Column(Integer, primary_key=True, index=True)

    model_name = Column(String(100), nullable=False)

    model_type = Column(String(50), nullable=False)

    version = Column(String(50), nullable=False)

    framework = Column(String(50), nullable=True)

    model_path = Column(String(500), nullable=True)

    dataset_type = Column(
        String(30),
        default="synthetic"
    )

    validation_status = Column(
        String(30),
        default="experimental"
    )

    approval_status = Column(
        String(30),
        default="pending"
    )

    is_active = Column(Boolean, default=False)

    approved_by = Column(
        Integer,
        ForeignKey("users.id"),
        nullable=True
    )

    approved_at = Column(DateTime(timezone=True), nullable=True)

    performance_metrics = Column(Text, nullable=True)

    created_at = Column(
        DateTime(timezone=True),
        server_default=func.now()
    )