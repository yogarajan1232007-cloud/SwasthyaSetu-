from sqlalchemy import (
    Column,
    Integer,
    String,
    Date,
    DateTime,
    ForeignKey,
    Boolean
)
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship

from app.database.base import Base


class Individual(Base):
    __tablename__ = "individuals"

    id = Column(Integer, primary_key=True, index=True)

    individual_code = Column(
        String(50),
        unique=True,
        nullable=False,
        index=True
    )

    household_id = Column(
        Integer,
        ForeignKey("households.id"),
        nullable=False
    )

    full_name = Column(String(150), nullable=False)

    date_of_birth = Column(Date, nullable=True)

    gender = Column(String(30), nullable=True)

    mobile_number = Column(String(15), nullable=True)

    blood_group = Column(String(5), nullable=True)

    is_active = Column(Boolean, default=True)

    created_at = Column(
        DateTime(timezone=True),
        server_default=func.now()
    )

    household = relationship(
        "Household",
        back_populates="members"
    )