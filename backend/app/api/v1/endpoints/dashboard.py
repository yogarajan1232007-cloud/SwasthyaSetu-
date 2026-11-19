from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.database.session import get_db
from app.schemas.dashboard import GovernmentDashboardResponse
from app.services.dashboard_service import get_government_dashboard

router = APIRouter(
    prefix="/dashboard",
    tags=["Dashboard & Analytics"]
)


@router.get(
    "/government",
    response_model=GovernmentDashboardResponse
)
def government_dashboard(
    db: Session = Depends(get_db)
):
    return get_government_dashboard(db)
from app.schemas.dashboard import HealthWorkerDashboardResponse
from app.services.dashboard_service import get_health_worker_dashboard


# Health Worker Dashboard
@router.get(
    "/worker/{worker_id}",
    response_model=HealthWorkerDashboardResponse
)
def health_worker_dashboard(
    worker_id: int,
    db: Session = Depends(get_db)
):
    return get_health_worker_dashboard(db, worker_id)
from app.schemas.dashboard import CitizenDashboardResponse
from app.services.dashboard_service import get_citizen_dashboard


# Citizen Dashboard
@router.get(
    "/citizen/{individual_id}",
    response_model=CitizenDashboardResponse
)
def citizen_dashboard(
    individual_id: int,
    db: Session = Depends(get_db)
):
    return get_citizen_dashboard(db, individual_id)