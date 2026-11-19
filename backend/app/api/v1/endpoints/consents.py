from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.database.session import get_db

from app.schemas.consent import (
    ConsentCreate,
    ConsentResponse
)

from app.services import consent_service


router = APIRouter(
    prefix="/consents",
    tags=["Consent Management"]
)


@router.post(
    "/",
    response_model=ConsentResponse,
    status_code=status.HTTP_201_CREATED
)
def create_consent(
    data: ConsentCreate,
    db: Session = Depends(get_db)
):

    try:
        return consent_service.create_consent(db, data)

    except ValueError as error:
        raise HTTPException(
            status_code=400,
            detail=str(error)
        )


@router.get(
    "/individual/{individual_id}",
    response_model=ConsentResponse
)
def get_individual_consent(
    individual_id: int,
    db: Session = Depends(get_db)
):

    consent = consent_service.get_latest_consent(
        db,
        individual_id
    )

    if not consent:
        raise HTTPException(
            status_code=404,
            detail="No consent record found"
        )

    return consent


@router.post(
    "/{consent_id}/revoke",
    response_model=ConsentResponse
)
def revoke_consent(
    consent_id: int,
    db: Session = Depends(get_db)
):

    try:
        return consent_service.revoke_consent(
            db,
            consent_id
        )

    except ValueError as error:
        raise HTTPException(
            status_code=400,
            detail=str(error)
        )