from datetime import datetime, timezone

from sqlalchemy.orm import Session

from app.models.consent import Consent
from app.models.individual import Individual
from app.models.worker import Worker


def create_consent(db: Session, data):

    individual = db.query(Individual).filter(
        Individual.id == data.individual_id
    ).first()

    if not individual:
        raise ValueError("Individual does not exist")

    if not individual.is_active:
        raise ValueError("Individual is inactive")

    if data.worker_id is not None:
        worker = db.query(Worker).filter(
            Worker.id == data.worker_id
        ).first()

        if not worker:
            raise ValueError("Worker does not exist")

    consent = Consent(
        individual_id=data.individual_id,
        worker_id=data.worker_id,
        consent_status=data.consent_status,
        consent_version=data.consent_version,
        consent_method=data.consent_method,
        remarks=data.remarks,
        granted_at=(
            datetime.now(timezone.utc)
            if data.consent_status == "granted"
            else None
        )
    )

    db.add(consent)
    db.commit()
    db.refresh(consent)

    return consent


def get_latest_consent(db: Session, individual_id: int):

    return db.query(Consent).filter(
        Consent.individual_id == individual_id
    ).order_by(
        Consent.id.desc()
    ).first()


def revoke_consent(db: Session, consent_id: int):

    consent = db.query(Consent).filter(
        Consent.id == consent_id
    ).first()

    if not consent:
        raise ValueError("Consent record does not exist")

    if consent.consent_status != "granted":
        raise ValueError("Only granted consent can be revoked")

    consent.consent_status = "revoked"
    consent.revoked_at = datetime.now(timezone.utc)

    db.commit()
    db.refresh(consent)

    return consent