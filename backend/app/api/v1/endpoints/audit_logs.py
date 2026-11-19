from typing import Optional

from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session

from app.database.session import get_db

from app.schemas.audit_log import (
    AuditLogCreate,
    AuditLogResponse
)

from app.services.audit_log_service import (
    create_audit_log,
    get_audit_logs,
    get_audit_log_by_id
)

router = APIRouter(
    prefix="/audit-logs",
    tags=["Audit Log Management"]
)


# Create Audit Log
@router.post("/", response_model=AuditLogResponse)
def create_new_audit_log(
    audit_data: AuditLogCreate,
    db: Session = Depends(get_db)
):
    return create_audit_log(db, audit_data)


# List Audit Logs with Filters
@router.get("/", response_model=list[AuditLogResponse])
def list_audit_logs(
    user_id: Optional[int] = Query(None),
    action: Optional[str] = Query(None),
    entity_type: Optional[str] = Query(None),
    entity_id: Optional[int] = Query(None),
    db: Session = Depends(get_db)
):
    return get_audit_logs(
        db,
        user_id=user_id,
        action=action,
        entity_type=entity_type,
        entity_id=entity_id
    )


# Retrieve Audit Log by ID
@router.get("/{audit_log_id}", response_model=AuditLogResponse)
def retrieve_audit_log(
    audit_log_id: int,
    db: Session = Depends(get_db)
):
    return get_audit_log_by_id(db, audit_log_id)