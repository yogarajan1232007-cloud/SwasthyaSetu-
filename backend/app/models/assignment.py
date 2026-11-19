from sqlalchemy import Column, Integer, String, Date, DateTime, ForeignKey
from sqlalchemy.sql import func

from app.database.base import Base


class Assignment(Base):
    __tablename__ = "assignments"

    id = Column(Integer, primary_key=True, index=True)

    worker_id = Column(
        Integer,
        ForeignKey("workers.id"),
        nullable=False
    )

    household_id = Column(
        Integer,
        ForeignKey("households.id"),
        nullable=False
    )

    assigned_by = Column(
        Integer,
        ForeignKey("users.id"),
        nullable=False
    )

    assignment_date = Column(Date, nullable=False)

    due_date = Column(Date, nullable=True)

    status = Column(String(30), default="pending")

    remarks = Column(String(500), nullable=True)

    created_at = Column(
        DateTime(timezone=True),
        server_default=func.now()
    )