from sqlalchemy import Column, Integer, String, Boolean, DateTime, ForeignKey, Text
from sqlalchemy.sql import func

from app.database.base import Base


class Consent(Base):
    __tablename__ = "consent_records"

    id = Column(Integer, primary_key=True, index=True)

    individual_id = Column(
        Integer,
        ForeignKey("individuals.id"),
        nullable=False
    )

    worker_id = Column(
        Integer,
        ForeignKey("workers.id"),
        nullable=True
    )

    consent_status = Column(String(30), nullable=False)

    consent_version = Column(String(30), nullable=True)

    consent_method = Column(String(30), nullable=True)

    remarks = Column(Text, nullable=True)

    granted_at = Column(DateTime(timezone=True), nullable=True)

    revoked_at = Column(DateTime(timezone=True), nullable=True)

    created_at = Column(
        DateTime(timezone=True),
        server_default=func.now()
    )