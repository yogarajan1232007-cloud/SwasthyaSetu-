from sqlalchemy.orm import Session

from app.models.user import User
from app.models.worker import Worker


def create_worker(db: Session, data):

    existing_user = db.query(User).filter(
        User.employee_id == data.employee_id
    ).first()

    if existing_user:
        raise ValueError("Employee ID already exists")

    if data.mobile_number:
        existing_mobile = db.query(User).filter(
            User.mobile_number == data.mobile_number
        ).first()

        if existing_mobile:
            raise ValueError("Mobile number already exists")

    if data.email:
        existing_email = db.query(User).filter(
            User.email == data.email
        ).first()

        if existing_email:
            raise ValueError("Email already exists")

    existing_code = db.query(Worker).filter(
        Worker.employee_code == data.employee_code
    ).first()

    if existing_code:
        raise ValueError("Worker employee code already exists")

    try:
        user = User(
            employee_id=data.employee_id,
            full_name=data.full_name,
            mobile_number=data.mobile_number,
            email=data.email,
            hashed_password="NOT_USED_FRONTEND_AUTH",
            role="health_worker",
            is_active=True
        )

        db.add(user)
        db.flush()

        worker = Worker(
            user_id=user.id,
            designation=data.designation,
            area=data.area,
            employee_code=data.employee_code,
            is_available=True
        )

        db.add(worker)
        db.commit()

        db.refresh(worker)
        return worker

    except Exception:
        db.rollback()
        raise


def get_all_workers(db: Session, skip=0, limit=20):

    return db.query(Worker).join(
        User,
        Worker.user_id == User.id
    ).order_by(
        Worker.id.desc()
    ).offset(skip).limit(limit).all()


def get_worker(db: Session, worker_id: int):

    return db.query(Worker).filter(
        Worker.id == worker_id
    ).first()


def update_worker(db: Session, worker, data):

    update_data = data.model_dump(exclude_unset=True)

    user_fields = {
        "full_name",
        "mobile_number",
        "email"
    }

    worker_fields = {
        "designation",
        "area",
        "is_available"
    }

    for field, value in update_data.items():

        if field in user_fields:
            setattr(worker.user, field, value)

        elif field in worker_fields:
            setattr(worker, field, value)

    try:
        db.commit()
        db.refresh(worker)
        return worker

    except Exception:
        db.rollback()
        raise