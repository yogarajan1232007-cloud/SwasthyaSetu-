from fastapi import HTTPException
from sqlalchemy.orm import Session

from app.models.referral import Referral
from app.models.individual import Individual
from app.models.screening import Screening
from app.models.user import User


VALID_URGENCIES = [
    "routine",
    "urgent",
    "emergency"
]

VALID_STATUSES = [
    "pending",
    "referred",
    "scheduled",
    "in_progress",
    "completed",
    "cancelled"
]

def create_referral(db: Session, referral_data):

    individual = db.query(Individual).filter(
        Individual.id == referral_data.individual_id
    ).first()

    if not individual:
        raise HTTPException(
            status_code=404,
            detail="Individual not found"
        )

    if referral_data.screening_id is not None:

        screening = db.query(Screening).filter(
            Screening.id == referral_data.screening_id
        ).first()

        if not screening:
            raise HTTPException(
                status_code=404,
                detail="Screening not found"
            )

        if screening.individual_id != referral_data.individual_id:
            raise HTTPException(
                status_code=400,
                detail="Screening does not belong to this individual"
            )

    user = db.query(User).filter(
        User.id == referral_data.created_by,
        User.is_active == True
    ).first()

    if not user:
        raise HTTPException(
            status_code=404,
            detail="Active referring user not found"
        )

    urgency = referral_data.urgency.strip().lower()

    if urgency not in VALID_URGENCIES:
        raise HTTPException(
            status_code=400,
            detail="Invalid urgency. Use routine, urgent or emergency"
        )

    referral = Referral(
        individual_id=referral_data.individual_id,
        screening_id=referral_data.screening_id,
        created_by=referral_data.created_by,
        facility_name=referral_data.facility_name,
        clinician_name=referral_data.clinician_name,
        reason=referral_data.reason,
        urgency=urgency,
        status="pending",
        appointment_at=referral_data.appointment_at,
        notes=referral_data.notes
    )

    db.add(referral)
    db.commit()
    db.refresh(referral)

    return referral


def get_referrals(
    db: Session,
    individual_id=None,
    screening_id=None,
    status=None,
    urgency=None,
    created_by=None
):

    query = db.query(Referral)

    if individual_id is not None:
        query = query.filter(
            Referral.individual_id == individual_id
        )

    if screening_id is not None:
        query = query.filter(
            Referral.screening_id == screening_id
        )

    if status is not None:
        query = query.filter(
            Referral.status == status.lower()
        )

    if urgency is not None:
        query = query.filter(
            Referral.urgency == urgency.lower()
        )

    if created_by is not None:
        query = query.filter(
            Referral.created_by == created_by
        )

    return query.order_by(
        Referral.referred_at.desc()
    ).all()


def get_referral_by_id(db: Session, referral_id: int):

    referral = db.query(Referral).filter(
        Referral.id == referral_id
    ).first()

    if not referral:
        raise HTTPException(
            status_code=404,
            detail="Referral not found"
        )

    return referral


def update_referral(
    db: Session,
    referral_id: int,
    update_data
):

    referral = get_referral_by_id(db, referral_id)

    data = update_data.model_dump(exclude_unset=True)

    if "status" in data and data["status"] is not None:

        status = data["status"].strip().lower()

        if status not in VALID_STATUSES:
            raise HTTPException(
                status_code=400,
                detail="Invalid referral status"
            )

        data["status"] = status

    if "urgency" in data and data["urgency"] is not None:

        urgency = data["urgency"].strip().lower()

        if urgency not in VALID_URGENCIES:
            raise HTTPException(
                status_code=400,
                detail="Invalid referral urgency"
            )

        data["urgency"] = urgency

    for field, value in data.items():
        setattr(referral, field, value)

    db.commit()
    db.refresh(referral)

    return referral