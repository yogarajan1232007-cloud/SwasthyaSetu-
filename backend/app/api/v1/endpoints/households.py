from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session

from app.database.session import get_db
from app.schemas.household import (
    HouseholdCreate,
    HouseholdUpdate,
    HouseholdResponse
)
from app.services import household_service


router = APIRouter(
    prefix="/households",
    tags=["Household Management"]
)


@router.post(
    "/",
    response_model=HouseholdResponse,
    status_code=status.HTTP_201_CREATED
)
def create_household(
    data: HouseholdCreate,
    db: Session = Depends(get_db)
):

    try:
        return household_service.create_household(db, data)

    except ValueError as error:
        raise HTTPException(
            status_code=400,
            detail=str(error)
        )


@router.get("/", response_model=list[HouseholdResponse])
def list_households(
    skip: int = Query(0, ge=0),
    limit: int = Query(20, ge=1, le=100),
    search: str | None = None,
    db: Session = Depends(get_db)
):

    return household_service.get_all_households(
        db,
        skip=skip,
        limit=limit,
        search=search
    )


@router.get("/{household_id}", response_model=HouseholdResponse)
def get_household(
    household_id: int,
    db: Session = Depends(get_db)
):

    household = household_service.get_household(
        db,
        household_id
    )

    if not household:
        raise HTTPException(
            status_code=404,
            detail="Household not found"
        )

    return household


@router.put("/{household_id}", response_model=HouseholdResponse)
def update_household(
    household_id: int,
    data: HouseholdUpdate,
    db: Session = Depends(get_db)
):

    household = household_service.get_household(
        db,
        household_id
    )

    if not household:
        raise HTTPException(
            status_code=404,
            detail="Household not found"
        )

    try:
        return household_service.update_household(
            db,
            household,
            data
        )

    except ValueError as error:
        raise HTTPException(
            status_code=400,
            detail=str(error)
        )


@router.delete("/{household_id}")
def remove_household(
    household_id: int,
    db: Session = Depends(get_db)
):

    household = household_service.get_household(
        db,
        household_id
    )

    if not household:
        raise HTTPException(
            status_code=404,
            detail="Household not found"
        )

    try:
        household_service.delete_household(db, household)

        return {
            "message": "Household deleted successfully"
        }

    except ValueError as error:
        raise HTTPException(
            status_code=400,
            detail=str(error)
        )