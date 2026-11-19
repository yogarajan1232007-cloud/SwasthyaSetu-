from uuid import uuid4

from sqlalchemy.orm import Session

from app.models.individual import Individual
from app.models.household import Household


def generate_individual_code(db: Session):

    while True:
        code = f"IND-{uuid4().hex[:8].upper()}"

        existing = db.query(Individual).filter(
            Individual.individual_code == code
        ).first()

        if not existing:
            return code


def create_individual(db: Session, data):

    household = db.query(Household).filter(
        Household.id == data.household_id
    ).first()

    if not household:
        raise ValueError("Household does not exist")

    individual = Individual(
        individual_code=generate_individual_code(db),
        household_id=data.household_id,
        full_name=data.full_name,
        date_of_birth=data.date_of_birth,
        gender=data.gender,
        mobile_number=data.mobile_number,
        blood_group=data.blood_group
    )

    db.add(individual)
    db.commit()
    db.refresh(individual)

    return individual


def get_all_individuals(
    db: Session,
    skip: int = 0,
    limit: int = 20,
    search: str | None = None
):

    query = db.query(Individual)

    if search:
        term = f"%{search.strip()}%"

        query = query.filter(
            (Individual.full_name.ilike(term)) |
            (Individual.individual_code.ilike(term))
        )

    return query.order_by(
        Individual.id.desc()
    ).offset(skip).limit(limit).all()


def get_individual(db: Session, individual_id: int):

    return db.query(Individual).filter(
        Individual.id == individual_id
    ).first()


def update_individual(db: Session, individual, data):

    update_data = data.model_dump(exclude_unset=True)

    for field, value in update_data.items():
        setattr(individual, field, value)

    db.commit()
    db.refresh(individual)

    return individual