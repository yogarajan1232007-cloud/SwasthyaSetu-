from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session

from app.database.session import get_db

from app.schemas.individual import (
    IndividualCreate,
    IndividualUpdate,
    IndividualResponse
)

from app.services import individual_service


router = APIRouter(
    prefix="/individuals",
    tags=["Individual Management"]
)


@router.post(
    "/",
    response_model=IndividualResponse,
    status_code=status.HTTP_201_CREATED
)
def create_individual(
    data: IndividualCreate,
    db: Session = Depends(get_db)
):

    try:
        return individual_service.create_individual(db, data)

    except ValueError as error:
        raise HTTPException(status_code=400, detail=str(error))


@router.get("/", response_model=list[IndividualResponse])
def list_individuals(
    skip: int = Query(0, ge=0),
    limit: int = Query(20, ge=1, le=100),
    search: str | None = None,
    db: Session = Depends(get_db)
):

    return individual_service.get_all_individuals(
        db,
        skip=skip,
        limit=limit,
        search=search
    )


@router.get("/{individual_id}", response_model=IndividualResponse)
def get_individual(
    individual_id: int,
    db: Session = Depends(get_db)
):

    individual = individual_service.get_individual(
        db,
        individual_id
    )

    if not individual:
        raise HTTPException(
            status_code=404,
            detail="Individual not found"
        )

    return individual


@router.put("/{individual_id}", response_model=IndividualResponse)
def update_individual(
    individual_id: int,
    data: IndividualUpdate,
    db: Session = Depends(get_db)
):

    individual = individual_service.get_individual(
        db,
        individual_id
    )

    if not individual:
        raise HTTPException(
            status_code=404,
            detail="Individual not found"
        )

    return individual_service.update_individual(
        db,
        individual,
        data
    )