from sqlalchemy import Column, Integer, String, DateTime, ForeignKey
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship

from app.database.base import Base


class Household(Base):
    __tablename__ = "households"

    id = Column(Integer, primary_key=True, index=True)

    household_code = Column(
        String(50),
        unique=True,
        nullable=False,
        index=True
    )

    head_of_family = Column(String(150), nullable=False)

    address = Column(String(500), nullable=False)

    area = Column(String(150), nullable=False)

    pincode = Column(String(10), nullable=True)

    assigned_worker_id = Column(
        Integer,
        ForeignKey("workers.id"),
        nullable=True
    )

    created_at = Column(
        DateTime(timezone=True),
        server_default=func.now()
    )

    members = relationship(
        "Individual",
        back_populates="household"
    )

    assigned_worker = relationship("Worker")