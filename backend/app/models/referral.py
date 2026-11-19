from sqlalchemy import Column, Integer, String, Text, DateTime, ForeignKey
from sqlalchemy.sql import func

from app.database.base import Base


class Referral(Base):
    __tablename__ = "referrals"

    id = Column(Integer, primary_key=True, index=True)

    # Relationships through foreign keys
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

    created_by = Column(
        Integer,
        ForeignKey("users.id"),
        nullable=False
    )

    # Referral information
    facility_name = Column(String(200), nullable=False)
    clinician_name = Column(String(150), nullable=True)
    reason = Column(Text, nullable=False)

    # Referral classification
    urgency = Column(String(30), default="routine", nullable=False)

    # Referral workflow:
    # pending, referred, scheduled, in_progress,
    # completed, cancelled
    status = Column(String(30), default="pending", nullable=False)

    # Dates
    referred_at = Column(
        DateTime(timezone=True),
        server_default=func.now()
    )

    appointment_at = Column(
        DateTime(timezone=True),
        nullable=True
    )

    # Additional information
    notes = Column(Text, nullable=True)

    # Outcome after referral completion
    outcome = Column(Text, nullable=True)