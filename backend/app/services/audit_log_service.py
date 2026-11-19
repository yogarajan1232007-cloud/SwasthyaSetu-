from sqlalchemy.orm import Session
from fastapi import HTTPException, status

from app.models.audit_log import AuditLog
from app.models.user import User
from app.schemas.audit_log import AuditLogCreate


# Create Audit Log
def create_audit_log(
    db: Session,
    audit_data: AuditLogCreate
):
    # Validate user if provided
    if audit_data.user_id is not None:
        user = db.query(User).filter(
            User.id == audit_data.user_id
        ).first()

        if not user:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User not found"
            )

    audit_log = AuditLog(
        user_id=audit_data.user_id,
        action=audit_data.action,
        entity_type=audit_data.entity_type,
        entity_id=audit_data.entity_id,
        details=audit_data.details,
        ip_address=audit_data.ip_address
    )

    db.add(audit_log)
    db.commit()
    db.refresh(audit_log)

    return audit_log


# Get Audit Logs with Optional Filters
def get_audit_logs(
    db: Session,
    user_id: int = None,
    action: str = None,
    entity_type: str = None,
    entity_id: int = None
):
    query = db.query(AuditLog)

    if user_id is not None:
        query = query.filter(
            AuditLog.user_id == user_id
        )

    if action:
        query = query.filter(
            AuditLog.action == action
        )

    if entity_type:
        query = query.filter(
            AuditLog.entity_type == entity_type
        )

    if entity_id is not None:
        query = query.filter(
            AuditLog.entity_id == entity_id
        )

    return query.order_by(
        AuditLog.created_at.desc()
    ).all()


# Get Audit Log by ID
def get_audit_log_by_id(
    db: Session,
    audit_log_id: int
):
    audit_log = db.query(AuditLog).filter(
        AuditLog.id == audit_log_id
    ).first()

    if not audit_log:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Audit log not found"
        )

    return audit_log