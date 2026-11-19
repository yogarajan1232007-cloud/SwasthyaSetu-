from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session

from app.database.session import get_db

from app.schemas.assignment import (
    AssignmentCreate,
    AssignmentUpdate,
    AssignmentResponse
)

from app.services import assignment_service


router = APIRouter(
    prefix="/assignments",
    tags=["Household Assignments"]
)


@router.post("/", response_model=AssignmentResponse, status_code=201)
def create_assignment(
    data: AssignmentCreate,
    db: Session = Depends(get_db)
):
    try:
        return assignment_service.create_assignment(db, data)

    except ValueError as error:
        raise HTTPException(status_code=400, detail=str(error))


@router.get("/", response_model=list[AssignmentResponse])
def list_assignments(
    skip: int = Query(0, ge=0),
    limit: int = Query(20, ge=1, le=100),
    db: Session = Depends(get_db)
):
    return assignment_service.get_all_assignments(
        db, skip, limit
    )


@router.get("/worker/{worker_id}", response_model=list[AssignmentResponse])
def list_worker_assignments(
    worker_id: int,
    db: Session = Depends(get_db)
):
    return assignment_service.get_worker_assignments(
        db, worker_id
    )


@router.get("/{assignment_id}", response_model=AssignmentResponse)
def get_assignment(
    assignment_id: int,
    db: Session = Depends(get_db)
):
    assignment = assignment_service.get_assignment(
        db, assignment_id
    )

    if not assignment:
        raise HTTPException(
            status_code=404,
            detail="Assignment not found"
        )

    return assignment


@router.patch("/{assignment_id}", response_model=AssignmentResponse)
def update_assignment(
    assignment_id: int,
    data: AssignmentUpdate,
    db: Session = Depends(get_db)
):
    assignment = assignment_service.get_assignment(
        db, assignment_id
    )

    if not assignment:
        raise HTTPException(
            status_code=404,
            detail="Assignment not found"
        )

    try:
        return assignment_service.update_assignment(
            db, assignment, data
        )

    except ValueError as error:
        raise HTTPException(status_code=400, detail=str(error))