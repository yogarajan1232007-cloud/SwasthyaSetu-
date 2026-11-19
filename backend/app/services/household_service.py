from uuid import uuid4

from sqlalchemy.orm import Session

from app.models.household import Household
from app.models.worker import Worker


def generate_household_code(db: Session):
    while True:
        code = f"HH-{uuid4().hex[:8].upper()}"

        existing = db.query(Household).filter(
            Household.household_code == code
        ).first()

        if not existing:
            return code


def create_household(db: Session, data):

    if data.assigned_worker_id is not None:
        worker = db.query(Worker).filter(
            Worker.id == data.assigned_worker_id
        ).first()

        if not worker:
            raise ValueError("Assigned worker does not exist")

    household = Household(
        household_code=generate_household_code(db),
        head_of_family=data.head_of_family,
        address=data.address,
        area=data.area,
        pincode=data.pincode,
        assigned_worker_id=data.assigned_worker_id
    )

    db.add(household)
    db.commit()
    db.refresh(household)

    return household


def get_all_households(
    db: Session,
    skip: int = 0,
    limit: int = 20,
    search: str | None = None
):

    query = db.query(Household)

    if search:
        search_term = f"%{search.strip()}%"

        query = query.filter(
            (Household.household_code.ilike(search_term)) |
            (Household.head_of_family.ilike(search_term)) |
            (Household.area.ilike(search_term))
        )

    return query.order_by(
        Household.id.desc()
    ).offset(skip).limit(limit).all()


def get_household(db: Session, household_id: int):

    return db.query(Household).filter(
        Household.id == household_id
    ).first()


def update_household(db: Session, household, data):

    update_data = data.model_dump(exclude_unset=True)

    if (
        "assigned_worker_id" in update_data
        and update_data["assigned_worker_id"] is not None
    ):
        worker = db.query(Worker).filter(
            Worker.id == update_data["assigned_worker_id"]
        ).first()

        if not worker:
            raise ValueError("Assigned worker does not exist")

    for field, value in update_data.items():
        setattr(household, field, value)

    db.commit()
    db.refresh(household)

    return household


def delete_household(db: Session, household):

    if household.members:
        raise ValueError(
            "Cannot delete a household that contains registered individuals"
        )

    db.delete(household)
    db.commit()

    return True