from sqlalchemy import Column, Integer, String, Boolean, ForeignKey
from sqlalchemy.orm import relationship

from app.database.base import Base


class Worker(Base):
    __tablename__ = "workers"

    id = Column(Integer, primary_key=True, index=True)

    user_id = Column(
        Integer,
        ForeignKey("users.id"),
        unique=True,
        nullable=False
    )

    designation = Column(String(100), nullable=True)
    area = Column(String(150), nullable=False)
    employee_code = Column(String(50), unique=True, nullable=False)
    is_available = Column(Boolean, default=True)

    user = relationship("User", backref="worker_profile")