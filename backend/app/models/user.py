from sqlalchemy import Column, Integer, String, Boolean, DateTime
from sqlalchemy.sql import func

from app.database.base import Base


class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)

    employee_id = Column(
        String(50),
        unique=True,
        nullable=False,
        index=True
    )

    full_name = Column(String(150), nullable=False)

    mobile_number = Column(
        String(15),
        unique=True,
        nullable=True
    )

    email = Column(
        String(150),
        unique=True,
        nullable=True
    )

    hashed_password = Column(String(255), nullable=False)

    role = Column(String(30), nullable=False)

    is_active = Column(Boolean, default=True)

    created_at = Column(
        DateTime(timezone=True),
        server_default=func.now()
    )