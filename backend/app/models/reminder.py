from sqlalchemy import Column, Integer, String, Text, DateTime, ForeignKey
from sqlalchemy.sql import func
from app.database.base import Base


class Reminder(Base):
    __tablename__ = "reminders"

    id = Column(Integer, primary_key=True, index=True)

    individual_id = Column(Integer, ForeignKey("individuals.id"), nullable=False)

    reminder_type = Column(String(50), nullable=False)
    title = Column(String(200), nullable=False)
    message = Column(Text, nullable=False)

    scheduled_at = Column(DateTime(timezone=True), nullable=False)
    status = Column(String(30), default="pending")

    created_at = Column(DateTime(timezone=True), server_default=func.now())