from sqlalchemy.orm import Session
from sqlalchemy import desc
from fastapi import HTTPException

from app.models.screening import Screening
from app.models.individual import Individual
from app.models.worker import Worker
from app.models.household import Household
from app.models.assignment import Assignment
from app.models.consent import Consent
from app.models.measurement import Measurement

from app.schemas.screening import ScreeningCreate, ScreeningUpdate


def create_screening(db: Session, data: ScreeningCreate):

    # 1. Verify individual
    individual = db.query(Individual).filter(
        Individual.id == data.individual_id
    ).first()

    if not individual or not individual.is_active:
        raise HTTPException(
            status_code=404,
            detail="Individual not found or inactive"
        )

    # 2. Verify latest consent
    consent = db.query(Consent).filter(
        Consent.individual_id == individual.id
    ).order_by(desc(Consent.id)).first()

    if not consent or consent.consent_status != "granted":
        raise HTTPException(
            status_code=403,
            detail="Valid consent is required before screening"
        )

    # 3. Verify worker
    worker = db.query(Worker).filter(
        Worker.id == data.worker_id
    ).first()

    if not worker or not worker.user or not worker.user.is_active:
        raise HTTPException(
            status_code=404,
            detail="Worker not found or inactive"
        )

    # 4. Verify household
    household = db.query(Household).filter(
        Household.id == individual.household_id
    ).first()

    if not household:
        raise HTTPException(
            status_code=404,
            detail="Individual's household not found"
        )

    # 5. Verify assignment
    if data.assignment_id is not None:

        assignment = db.query(Assignment).filter(
            Assignment.id == data.assignment_id
        ).first()

        if not assignment:
            raise HTTPException(
                status_code=404,
                detail="Assignment not found"
            )

        if assignment.worker_id != worker.id:
            raise HTTPException(
                status_code=400,
                detail="Assignment does not belong to this worker"
            )

        if assignment.household_id != household.id:
            raise HTTPException(
                status_code=400,
                detail="Assignment does not belong to this individual's household"
            )

        if assignment.status not in ["pending", "in_progress"]:
            raise HTTPException(
                status_code=400,
                detail="Assignment is not available for screening"
            )

    else:
        if household.assigned_worker_id != worker.id:
            raise HTTPException(
                status_code=400,
                detail="This household is not assigned to this worker"
            )

    # 6. Create screening
    screening = Screening(
        individual_id=data.individual_id,
        worker_id=data.worker_id,
        assignment_id=data.assignment_id,
        screening_type=data.screening_type,
        medical_history=data.medical_history,
        remarks=data.remarks,
        status="in_progress"
    )

    try:
        db.add(screening)
        db.commit()
        db.refresh(screening)
        return screening

    except Exception:
        db.rollback()
        raise HTTPException(
            status_code=500,
            detail="Failed to create screening"
        )


def get_screenings(
    db: Session,
    individual_id: int = None,
    worker_id: int = None
):
    query = db.query(Screening)

    if individual_id is not None:
        query = query.filter(
            Screening.individual_id == individual_id
        )

    if worker_id is not None:
        query = query.filter(
            Screening.worker_id == worker_id
        )

    return query.order_by(desc(Screening.id)).all()


def get_screening_by_id(db: Session, screening_id: int):

    screening = db.query(Screening).filter(
        Screening.id == screening_id
    ).first()

    if not screening:
        raise HTTPException(
            status_code=404,
            detail="Screening not found"
        )

    return screening


def update_screening(
    db: Session,
    screening_id: int,
    data: ScreeningUpdate
):

    screening = get_screening_by_id(db, screening_id)

    update_data = data.model_dump(exclude_unset=True)

    # Validate before completing screening
    if update_data.get("status") == "completed":

        if screening.status == "cancelled":
            raise HTTPException(
                status_code=400,
                detail="Cancelled screening cannot be completed"
            )

        measurement = db.query(Measurement).filter(
            Measurement.screening_id == screening_id,
            Measurement.individual_id == screening.individual_id
        ).first()

        if not measurement:
            raise HTTPException(
                status_code=400,
                detail="At least one measurement is required to complete screening"
            )

    for field, value in update_data.items():
        setattr(screening, field, value)

    try:
        db.commit()
        db.refresh(screening)
        return screening

    except Exception:
        db.rollback()
        raise HTTPException(
            status_code=500,
            detail="Failed to update screening"
        )