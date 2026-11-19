from datetime import datetime, timezone

from fastapi import HTTPException
from sqlalchemy.orm import Session

from app.models.followup import FollowUp
from app.models.individual import Individual
from app.models.worker import Worker
from app.models.screening import Screening
from app.models.user import User


VALID_STATUSES = [
    "pending",
    "in_progress",
    "completed",
    "cancelled"
]


# ============================================================
# VALIDATE WORKER
# ============================================================

def validate_worker(db: Session, worker_id: int):

    worker = (
        db.query(Worker)
        .join(User, Worker.user_id == User.id)
        .filter(
            Worker.id == worker_id,
            Worker.is_available.is_(True),
            User.is_active.is_(True)
        )
        .first()
    )

    if not worker:
        raise HTTPException(
            status_code=404,
            detail="Available and active worker not found"
        )

    return worker


# ============================================================
# CREATE FOLLOW-UP
# ============================================================

def create_followup(db: Session, followup_data):

    # Validate individual
    individual = db.query(Individual).filter(
        Individual.id == followup_data.individual_id
    ).first()

    if not individual:
        raise HTTPException(
            status_code=404,
            detail="Individual not found"
        )

    # Validate assigned worker
    if followup_data.worker_id is not None:

        validate_worker(
            db,
            followup_data.worker_id
        )

    # Validate screening
    if followup_data.screening_id is not None:

        screening = db.query(Screening).filter(
            Screening.id == followup_data.screening_id
        ).first()

        if not screening:
            raise HTTPException(
                status_code=404,
                detail="Screening not found"
            )

        if screening.individual_id != followup_data.individual_id:
            raise HTTPException(
                status_code=400,
                detail="Screening does not belong to this individual"
            )

    followup_type = followup_data.followup_type.strip()

    if not followup_type:
        raise HTTPException(
            status_code=400,
            detail="Follow-up type cannot be empty"
        )

    followup = FollowUp(
        individual_id=followup_data.individual_id,
        worker_id=followup_data.worker_id,
        screening_id=followup_data.screening_id,
        followup_type=followup_type,
        due_date=followup_data.due_date,
        status="pending",
        notes=followup_data.notes
    )

    try:
        db.add(followup)
        db.commit()
        db.refresh(followup)

        return followup

    except Exception:
        db.rollback()
        raise


# ============================================================
# GET ALL FOLLOW-UPS
# ============================================================

def get_followups(
    db: Session,
    individual_id=None,
    worker_id=None,
    screening_id=None,
    status=None
):

    query = db.query(FollowUp)

    if individual_id is not None:
        query = query.filter(
            FollowUp.individual_id == individual_id
        )

    if worker_id is not None:
        query = query.filter(
            FollowUp.worker_id == worker_id
        )

    if screening_id is not None:
        query = query.filter(
            FollowUp.screening_id == screening_id
        )

    if status is not None:

        normalized_status = status.strip().lower()

        if normalized_status not in VALID_STATUSES:
            raise HTTPException(
                status_code=400,
                detail="Invalid follow-up status"
            )

        query = query.filter(
            FollowUp.status == normalized_status
        )

    return query.order_by(
        FollowUp.due_date.asc(),
        FollowUp.id.desc()
    ).all()


# ============================================================
# GET FOLLOW-UP BY ID
# ============================================================

def get_followup_by_id(
    db: Session,
    followup_id: int
):

    followup = db.query(FollowUp).filter(
        FollowUp.id == followup_id
    ).first()

    if not followup:
        raise HTTPException(
            status_code=404,
            detail="Follow-up not found"
        )

    return followup


# ============================================================
# UPDATE FOLLOW-UP
# ============================================================

def update_followup(
    db: Session,
    followup_id: int,
    update_data
):

    followup = get_followup_by_id(
        db,
        followup_id
    )

    # Completed follow-ups cannot be modified
    if followup.status == "completed":
        raise HTTPException(
            status_code=400,
            detail="Completed follow-ups cannot be modified"
        )

    data = update_data.model_dump(
        exclude_unset=True
    )

    # Validate worker if worker_id is being updated
    if "worker_id" in data and data["worker_id"] is not None:

        validate_worker(
            db,
            data["worker_id"]
        )

    # Validate follow-up type
    if "followup_type" in data and data["followup_type"] is not None:

        followup_type = data["followup_type"].strip()

        if not followup_type:
            raise HTTPException(
                status_code=400,
                detail="Follow-up type cannot be empty"
            )

        data["followup_type"] = followup_type

    # Validate status
    if "status" in data and data["status"] is not None:

        status = data["status"].strip().lower()

        if status not in VALID_STATUSES:
            raise HTTPException(
                status_code=400,
                detail="Invalid follow-up status"
            )

        data["status"] = status

        if status == "completed":
            followup.completed_at = datetime.now(timezone.utc)

    # Apply updates
    for field, value in data.items():
        setattr(followup, field, value)

    try:
        db.commit()
        db.refresh(followup)

        return followup

    except Exception:
        db.rollback()
        raise


# ============================================================
# COMPLETE FOLLOW-UP
# ============================================================

def complete_followup(
    db: Session,
    followup_id: int
):

    followup = get_followup_by_id(
        db,
        followup_id
    )

    # Already completed: return existing record
    if followup.status == "completed":
        return followup

    followup.status = "completed"

    followup.completed_at = datetime.now(
        timezone.utc
    )

    try:
        db.commit()
        db.refresh(followup)

        return followup

    except Exception:
        db.rollback()
        raise