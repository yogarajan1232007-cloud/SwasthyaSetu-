from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session

from app.database.session import get_db

from app.schemas.worker import (
    WorkerCreate,
    WorkerUpdate,
    WorkerResponse
)

from app.services import worker_service


router = APIRouter(
    prefix="/workers",
    tags=["Worker Management"]
)


@router.post("/", response_model=WorkerResponse, status_code=201)
def create_worker(
    data: WorkerCreate,
    db: Session = Depends(get_db)
):
    try:
        worker = worker_service.create_worker(db, data)

        return {
            **worker.__dict__,
            "full_name": worker.user.full_name,
            "employee_id": worker.user.employee_id,
            "mobile_number": worker.user.mobile_number,
            "email": worker.user.email,
            "is_active": worker.user.is_active,
        }

    except ValueError as error:
        raise HTTPException(
            status_code=400,
            detail=str(error)
        )

@router.get("/", response_model=list[WorkerResponse])
def list_workers(
    skip: int = Query(0, ge=0),
    limit: int = Query(20, ge=1, le=100),
    db: Session = Depends(get_db)
):

    workers = worker_service.get_all_workers(
        db,
        skip=skip,
        limit=limit
    )

    return [
        {
            **worker.__dict__,
            "full_name": worker.user.full_name,
            "employee_id": worker.user.employee_id,
            "mobile_number": worker.user.mobile_number,
            "email": worker.user.email,
            "is_active": worker.user.is_active
        }
        for worker in workers
    ]


@router.get("/{worker_id}", response_model=WorkerResponse)
def get_worker(
    worker_id: int,
    db: Session = Depends(get_db)
):

    worker = worker_service.get_worker(db, worker_id)

    if not worker:
        raise HTTPException(status_code=404, detail="Worker not found")

    return {
        **worker.__dict__,
        "full_name": worker.user.full_name,
        "employee_id": worker.user.employee_id,
        "mobile_number": worker.user.mobile_number,
        "email": worker.user.email,
        "is_active": worker.user.is_active
    }


@router.put("/{worker_id}", response_model=WorkerResponse)
def update_worker(
    worker_id: int,
    data: WorkerUpdate,
    db: Session = Depends(get_db)
):

    worker = worker_service.get_worker(db, worker_id)

    if not worker:
        raise HTTPException(status_code=404, detail="Worker not found")

    try:
        worker = worker_service.update_worker(db, worker, data)

        return {
            **worker.__dict__,
            "full_name": worker.user.full_name,
            "employee_id": worker.user.employee_id,
            "mobile_number": worker.user.mobile_number,
            "email": worker.user.email,
            "is_active": worker.user.is_active
        }

    except Exception:
        raise HTTPException(status_code=400, detail="Worker update failed")


@router.patch("/{worker_id}/availability")
def update_worker_availability(
    worker_id: int,
    is_available: bool,
    db: Session = Depends(get_db)
):

    worker = worker_service.get_worker(db, worker_id)

    if not worker:
        raise HTTPException(status_code=404, detail="Worker not found")

    worker.is_available = is_available
    db.commit()

    return {
        "message": "Worker availability updated",
        "worker_id": worker.id,
        "is_available": worker.is_available
    }