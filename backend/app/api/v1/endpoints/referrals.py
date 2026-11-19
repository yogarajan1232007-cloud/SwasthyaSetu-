from typing import Optional

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.database.session import get_db

from app.schemas.referral import (
    ReferralCreate,
    ReferralUpdate,
    ReferralResponse
)

from app.services.referral_service import (
    create_referral,
    get_referrals,
    get_referral_by_id,
    update_referral
)


router = APIRouter()


@router.post(
    "/",
    response_model=ReferralResponse
)
def register_referral(
    referral_data: ReferralCreate,
    db: Session = Depends(get_db)
):

    return create_referral(db, referral_data)


@router.get(
    "/",
    response_model=list[ReferralResponse]
)
def list_referrals(
    individual_id: Optional[int] = None,
    screening_id: Optional[int] = None,
    status: Optional[str] = None,
    urgency: Optional[str] = None,
    created_by: Optional[int] = None,
    db: Session = Depends(get_db)
):

    return get_referrals(
        db,
        individual_id,
        screening_id,
        status,
        urgency,
        created_by
    )


@router.get(
    "/{referral_id}",
    response_model=ReferralResponse
)
def retrieve_referral(
    referral_id: int,
    db: Session = Depends(get_db)
):

    return get_referral_by_id(db, referral_id)


@router.patch(
    "/{referral_id}",
    response_model=ReferralResponse
)
def modify_referral(
    referral_id: int,
    update_data: ReferralUpdate,
    db: Session = Depends(get_db)
):

    return update_referral(
        db,
        referral_id,
        update_data
    )