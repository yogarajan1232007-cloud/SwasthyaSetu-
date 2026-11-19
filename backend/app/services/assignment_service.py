from sqlalchemy.orm import Session

from app.models.assignment import Assignment
from app.models.worker import Worker
from app.models.household import Household
from app.models.user import User


def create_assignment(db: Session, data):

    worker = db.query(Worker).filter(
        Worker.id == data.worker_id
    ).first()

    if not worker:
        raise ValueError("Worker does not exist")

    if not worker.user.is_active:
        raise ValueError("Worker is inactive")

    household = db.query(Household).filter(
        Household.id == data.household_id
    ).first()

    if not household:
        raise ValueError("Household does not exist")

    officer = db.query(User).filter(
        User.id == data.assigned_by
    ).first()

    if not officer:
        raise ValueError("Assigning officer does not exist")

    if not officer.is_active:
        raise ValueError("Assigning officer is inactive")

    if household.assigned_worker_id not in (None, data.worker_id):
        raise ValueError(
            "Household is already assigned to another worker"
        )

    existing = db.query(Assignment).filter(
        Assignment.household_id == data.household_id,
        Assignment.status.in_(["pending", "in_progress"])
    ).first()

    if existing:
        raise ValueError(
            "Household already has an active assignment"
        )

    if data.due_date and data.due_date < data.assignment_date:
        raise ValueError("Due date cannot be before assignment date")

    try:
        assignment = Assignment(
            worker_id=data.worker_id,
            household_id=data.household_id,
            assigned_by=data.assigned_by,
            assignment_date=data.assignment_date,
            due_date=data.due_date,
            status="pending",
            remarks=data.remarks
        )

        db.add(assignment)

        household.assigned_worker_id = data.worker_id

        db.commit()
        db.refresh(assignment)

        return assignment

    except Exception:
        db.rollback()
        raise


def get_all_assignments(db: Session, skip=0, limit=20):

    return db.query(Assignment).order_by(
        Assignment.id.desc()
    ).offset(skip).limit(limit).all()


def get_assignment(db: Session, assignment_id: int):

    return db.query(Assignment).filter(
        Assignment.id == assignment_id
    ).first()


def get_worker_assignments(db: Session, worker_id: int):

    return db.query(Assignment).filter(
        Assignment.worker_id == worker_id
    ).order_by(Assignment.id.desc()).all()


def update_assignment(db: Session, assignment, data):

    update_data = data.model_dump(exclude_unset=True)

    allowed_statuses = {
        "pending",
        "in_progress",
        "completed",
        "cancelled"
    }

    if "status" in update_data:
        if update_data["status"] not in allowed_statuses:
            raise ValueError("Invalid assignment status")

    if (
        update_data.get("due_date")
        and update_data["due_date"] < assignment.assignment_date
    ):
        raise ValueError("Due date cannot be before assignment date")

    try:
        for field, value in update_data.items():
            setattr(assignment, field, value)

        db.commit()
        db.refresh(assignment)

        return assignment

    except Exception:
        db.rollback()
        raise