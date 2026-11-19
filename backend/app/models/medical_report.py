from sqlalchemy import (
    Column, Integer, String, DateTime, ForeignKey, Text
)
from sqlalchemy.sql import func

from app.database.base import Base


class MedicalReport(Base):
    __tablename__ = "medical_reports"

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

    uploaded_by = Column(
        Integer,
        ForeignKey("users.id"),
        nullable=True
    )

    report_type = Column(String(50), nullable=False)

    report_name = Column(String(200), nullable=False)

    file_path = Column(String(500), nullable=False)

    file_format = Column(String(20), nullable=True)

    report_date = Column(DateTime(timezone=True), nullable=True)

    verification_status = Column(
        String(30),
        default="pending"
    )

    notes = Column(Text, nullable=True)

    created_at = Column(
        DateTime(timezone=True),
        server_default=func.now()
    )