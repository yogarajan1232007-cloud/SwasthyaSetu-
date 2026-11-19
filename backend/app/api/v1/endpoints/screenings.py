from typing import Optional

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.database.session import get_db

from app.schemas.screening import (
    ScreeningCreate,
    ScreeningUpdate,
    ScreeningResponse
)

from app.services.screening_service import (
    create_screening,
    get_screenings,
    get_screening_by_id,
    update_screening
)


router = APIRouter(
    prefix="/screenings",
    tags=["Screening Management"]
)


@router.post("/", response_model=ScreeningResponse)
def create_new_screening(
    data: ScreeningCreate,
    db: Session = Depends(get_db)
):
    return create_screening(db, data)


@router.get("/", response_model=list[ScreeningResponse])
def list_screenings(
    individual_id: Optional[int] = None,
    worker_id: Optional[int] = None,
    db: Session = Depends(get_db)
):
    return get_screenings(
        db,
        individual_id=individual_id,
        worker_id=worker_id
    )


@router.get("/{screening_id}", response_model=ScreeningResponse)
def get_screening(
    screening_id: int,
    db: Session = Depends(get_db)
):
    return get_screening_by_id(db, screening_id)


@router.put("/{screening_id}", response_model=ScreeningResponse)
def update_existing_screening(
    screening_id: int,
    data: ScreeningUpdate,
    db: Session = Depends(get_db)
):
    return update_screening(db, screening_id, data)