from sqlalchemy import (
    Column, Integer, String, DateTime, ForeignKey, Text
)
from sqlalchemy.sql import func

from app.database.base import Base


class ImagingFile(Base):
    __tablename__ = "imaging_files"

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

    modality = Column(
        String(30),
        nullable=False
    )
    # ECG, XRAY, CT, MRI, ULTRASOUND

    body_region = Column(String(100), nullable=True)

    file_path = Column(String(500), nullable=False)

    file_format = Column(String(20), nullable=True)

    study_date = Column(DateTime(timezone=True), nullable=True)

    status = Column(String(30), default="uploaded")

    notes = Column(Text, nullable=True)

    created_at = Column(
        DateTime(timezone=True),
        server_default=func.now()
    )