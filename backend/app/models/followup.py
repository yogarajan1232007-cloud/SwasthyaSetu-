from sqlalchemy import Column, Integer, String, Text, Date, DateTime, ForeignKey
from sqlalchemy.sql import func
from app.database.base import Base


class FollowUp(Base):
    __tablename__ = "follow_ups"

    id = Column(Integer, primary_key=True, index=True)

    individual_id = Column(Integer, ForeignKey("individuals.id"), nullable=False)
    worker_id = Column(Integer, ForeignKey("workers.id"), nullable=True)
    screening_id = Column(Integer, ForeignKey("screenings.id"), nullable=True)

    followup_type = Column(String(100), nullable=False)
    due_date = Column(Date, nullable=False)

    status = Column(String(30), default="pending")
    notes = Column(Text, nullable=True)

    completed_at = Column(DateTime(timezone=True), nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())