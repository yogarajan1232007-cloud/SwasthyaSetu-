from sqlalchemy import Column, Integer, String, DateTime, ForeignKey, Text
from sqlalchemy.sql import func

from app.database.base import Base


class Screening(Base):
    __tablename__ = "screenings"

    id = Column(Integer, primary_key=True, index=True)

    individual_id = Column(
        Integer,
        ForeignKey("individuals.id"),
        nullable=False
    )

    worker_id = Column(
        Integer,
        ForeignKey("workers.id"),
        nullable=False
    )

    assignment_id = Column(
        Integer,
        ForeignKey("assignments.id"),
        nullable=True
    )

    screening_type = Column(String(50), default="monthly")

    screening_date = Column(DateTime(timezone=True), server_default=func.now())

    status = Column(String(30), default="completed")

    medical_history = Column(Text, nullable=True)

    remarks = Column(Text, nullable=True)

    created_at = Column(
        DateTime(timezone=True),
        server_default=func.now()
    )