from typing import Optional

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.database.session import get_db

from app.schemas.followup import (
    FollowUpCreate,
    FollowUpUpdate,
    FollowUpResponse
)

from app.services.followup_service import (
    create_followup,
    get_followups,
    get_followup_by_id,
    update_followup,
    complete_followup
)

router = APIRouter()


@router.post(
    "/",
    response_model=FollowUpResponse
)
def register_followup(
    followup_data: FollowUpCreate,
    db: Session = Depends(get_db)
):

    return create_followup(db, followup_data)


@router.get(
    "/",
    response_model=list[FollowUpResponse]
)
def list_followups(
    individual_id: Optional[int] = None,
    worker_id: Optional[int] = None,
    screening_id: Optional[int] = None,
    status: Optional[str] = None,
    db: Session = Depends(get_db)
):

    return get_followups(
        db,
        individual_id,
        worker_id,
        screening_id,
        status
    )


@router.get(
    "/{followup_id}",
    response_model=FollowUpResponse
)
def retrieve_followup(
    followup_id: int,
    db: Session = Depends(get_db)
):

    return get_followup_by_id(db, followup_id)


@router.patch(
    "/{followup_id}",
    response_model=FollowUpResponse
)
def modify_followup(
    followup_id: int,
    update_data: FollowUpUpdate,
    db: Session = Depends(get_db)
):

    return update_followup(
        db,
        followup_id,
        update_data
    )
@router.patch(
    "/{followup_id}/complete",
    response_model=FollowUpResponse
)
def complete_followup_endpoint(
    followup_id: int,
    db: Session = Depends(get_db)
):

    return complete_followup(db, followup_id)