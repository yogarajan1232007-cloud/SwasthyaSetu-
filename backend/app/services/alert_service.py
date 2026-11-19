from datetime import datetime, timezone

from fastapi import HTTPException
from sqlalchemy.orm import Session

from app.models.alert import Alert
from app.models.individual import Individual
from app.models.ai_prediction import AIPrediction
from app.models.user import User


VALID_SEVERITIES = ["low", "medium", "high", "critical"]

VALID_STATUSES = ["open", "in_progress", "resolved"]


def create_alert(db: Session, alert_data):

    individual = db.query(Individual).filter(
        Individual.id == alert_data.individual_id
    ).first()

    if not individual:
        raise HTTPException(
            status_code=404,
            detail="Individual not found"
        )

    if alert_data.prediction_id is not None:

        prediction = db.query(AIPrediction).filter(
            AIPrediction.id == alert_data.prediction_id
        ).first()

        if not prediction:
            raise HTTPException(
                status_code=404,
                detail="AI prediction not found"
            )

        if prediction.individual_id != alert_data.individual_id:
            raise HTTPException(
                status_code=400,
                detail="Prediction does not belong to this individual"
            )

    if alert_data.assigned_to is not None:

        user = db.query(User).filter(
            User.id == alert_data.assigned_to,
            User.is_active == True
        ).first()

        if not user:
            raise HTTPException(
                status_code=404,
                detail="Active assigned user not found"
            )

    severity = alert_data.severity.strip().lower()

    if severity not in VALID_SEVERITIES:
        raise HTTPException(
            status_code=400,
            detail="Invalid severity. Use low, medium, high or critical"
        )

    alert = Alert(
        individual_id=alert_data.individual_id,
        prediction_id=alert_data.prediction_id,
        assigned_to=alert_data.assigned_to,
        severity=severity,
        title=alert_data.title,
        message=alert_data.message,
        status="open"
    )

    db.add(alert)
    db.commit()
    db.refresh(alert)

    return alert


def get_alerts(
    db: Session,
    individual_id=None,
    prediction_id=None,
    severity=None,
    status=None,
    assigned_to=None
):

    query = db.query(Alert)

    if individual_id is not None:
        query = query.filter(
            Alert.individual_id == individual_id
        )

    if prediction_id is not None:
        query = query.filter(
            Alert.prediction_id == prediction_id
        )

    if severity is not None:
        query = query.filter(
            Alert.severity == severity.lower()
        )

    if status is not None:
        query = query.filter(
            Alert.status == status.lower()
        )

    if assigned_to is not None:
        query = query.filter(
            Alert.assigned_to == assigned_to
        )

    return query.order_by(
        Alert.created_at.desc()
    ).all()


def get_alert_by_id(db: Session, alert_id: int):

    alert = db.query(Alert).filter(
        Alert.id == alert_id
    ).first()

    if not alert:
        raise HTTPException(
            status_code=404,
            detail="Alert not found"
        )

    return alert


def update_alert_status(
    db: Session,
    alert_id: int,
    new_status: str
):

    alert = get_alert_by_id(db, alert_id)

    new_status = new_status.strip().lower()

    if new_status not in VALID_STATUSES:
        raise HTTPException(
            status_code=400,
            detail="Invalid status. Use open, in_progress or resolved"
        )

    if alert.status == "resolved" and new_status != "resolved":
        raise HTTPException(
            status_code=400,
            detail="Resolved alerts cannot be reopened through this endpoint"
        )

    alert.status = new_status

    if new_status == "resolved":
        alert.resolved_at = datetime.now(timezone.utc)

    db.commit()
    db.refresh(alert)

    return alert