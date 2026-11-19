from datetime import date, datetime, timezone

from sqlalchemy.orm import Session
from sqlalchemy import func

from app.models.individual import Individual
from app.models.household import Household
from app.models.worker import Worker
from app.models.screening import Screening
from app.models.assignment import Assignment
from app.models.ai_prediction import AIPrediction
from app.models.alert import Alert
from app.models.referral import Referral
from app.models.followup import FollowUp
from app.models.notification import Notification
from app.models.user import User
from app.models.measurement import Measurement
from app.models.medical_report import MedicalReport
from app.models.followup import FollowUp
from app.models.reminder import Reminder
from app.models.notification import Notification
from app.models.consent import Consent


def get_government_dashboard(db: Session):

    today = date.today()

    # ==========================================
    # 1. POPULATION STATISTICS
    # ==========================================

    individuals = db.query(Individual).all()

    total_population = len(individuals)

    active_population = sum(
        1 for person in individuals if person.is_active
    )

    male_population = sum(
        1 for person in individuals
        if (person.gender or "").strip().lower() == "male"
    )

    female_population = sum(
        1 for person in individuals
        if (person.gender or "").strip().lower() == "female"
    )

    senior_citizens = 0
    children = 0

    for person in individuals:

        if not person.date_of_birth:
            continue

        age = today.year - person.date_of_birth.year

        if (
            (today.month, today.day)
            < (person.date_of_birth.month, person.date_of_birth.day)
        ):
            age -= 1

        if age >= 60:
            senior_citizens += 1

        elif age < 18:
            children += 1

    # ==========================================
    # 2. HOUSEHOLD STATISTICS
    # ==========================================

    total_households = db.query(Household).count()

    assigned_households = db.query(Household).filter(
        Household.assigned_worker_id.isnot(None)
    ).count()

    unassigned_households = db.query(Household).filter(
        Household.assigned_worker_id.is_(None)
    ).count()

    # ==========================================
    # 3. HEALTH WORKER STATISTICS
    # ==========================================

    total_workers = db.query(Worker).count()

    available_workers = db.query(Worker).filter(
        Worker.is_available == True
    ).count()

    unavailable_workers = db.query(Worker).filter(
        Worker.is_available == False
    ).count()

    # ==========================================
    # 4. SCREENING STATISTICS
    # ==========================================

    total_screenings = db.query(Screening).count()

    completed_screenings = db.query(Screening).filter(
        Screening.status == "completed"
    ).count()
    unique_individuals_screened = (
        db.query(func.count(func.distinct(Screening.individual_id)))
        .filter(Screening.status == "completed")
        .scalar()
        or 0
    )

    in_progress_screenings = db.query(Screening).filter(
        Screening.status == "in_progress"
    ).count()

    # ==========================================
    # 5. ASSIGNMENT STATISTICS
    # ==========================================

    total_assignments = db.query(Assignment).count()

    pending_assignments = db.query(Assignment).filter(
        Assignment.status == "pending"
    ).count()

    completed_assignments = db.query(Assignment).filter(
        Assignment.status == "completed"
    ).count()

    overdue_assignments = db.query(Assignment).filter(
        Assignment.due_date < today,
        Assignment.status.notin_(["completed", "cancelled"])
    ).count()

    # ==========================================
    # 6. AI PREDICTION STATISTICS
    # ==========================================

    total_predictions = db.query(AIPrediction).count()

    experimental_predictions = db.query(AIPrediction).filter(
        AIPrediction.is_experimental == True
    ).count()

    non_experimental_predictions = db.query(AIPrediction).filter(
        AIPrediction.is_experimental == False
    ).count()

    diabetes_predictions = db.query(AIPrediction).filter(
        AIPrediction.prediction_type == "diabetes"
    ).count()

    cardiovascular_predictions = db.query(AIPrediction).filter(
        AIPrediction.prediction_type == "cardiovascular"
    ).count()

    low_risk_predictions = db.query(AIPrediction).filter(
        func.lower(AIPrediction.risk_level) == "low"
    ).count()

    medium_risk_predictions = db.query(AIPrediction).filter(
        func.lower(AIPrediction.risk_level) == "medium"
    ).count()

    high_risk_predictions = db.query(AIPrediction).filter(
        func.lower(AIPrediction.risk_level) == "high"
    ).count()

    # ==========================================
    # 7. ALERT STATISTICS
    # ==========================================

    total_alerts = db.query(Alert).count()

    open_alerts = db.query(Alert).filter(
        Alert.status == "open"
    ).count()

    critical_alerts = db.query(Alert).filter(
        func.lower(Alert.severity) == "critical"
    ).count()

    resolved_alerts = db.query(Alert).filter(
        Alert.status == "resolved"
    ).count()

    # ==========================================
    # 8. REFERRAL STATISTICS
    # ==========================================

    total_referrals = db.query(Referral).count()

    pending_referrals = db.query(Referral).filter(
        Referral.status == "pending"
    ).count()

    scheduled_referrals = db.query(Referral).filter(
        Referral.status == "scheduled"
    ).count()

    completed_referrals = db.query(Referral).filter(
        Referral.status == "completed"
    ).count()

    # ==========================================
    # 9. RETURN DASHBOARD DATA
    # ==========================================

    return {
        # Population
        "total_population": total_population,
        "male_population": male_population,
        "female_population": female_population,
        "senior_citizens": senior_citizens,
        "children": children,
        "active_population": active_population,

        # Households
        "total_households": total_households,
        "assigned_households": assigned_households,
        "unassigned_households": unassigned_households,

        # Workers
        "total_workers": total_workers,
        "available_workers": available_workers,
        "unavailable_workers": unavailable_workers,

        # Screenings
        "total_screenings": total_screenings,
        "completed_screenings": completed_screenings,
        "unique_individuals_screened": unique_individuals_screened,
        "in_progress_screenings": in_progress_screenings,

        # Assignments
        "total_assignments": total_assignments,
        "pending_assignments": pending_assignments,
        "completed_assignments": completed_assignments,
        "overdue_assignments": overdue_assignments,

        # AI Predictions
        "total_predictions": total_predictions,
        "experimental_predictions": experimental_predictions,
        "non_experimental_predictions": non_experimental_predictions,
        "diabetes_predictions": diabetes_predictions,
        "cardiovascular_predictions": cardiovascular_predictions,
        "low_risk_predictions": low_risk_predictions,
        "medium_risk_predictions": medium_risk_predictions,
        "high_risk_predictions": high_risk_predictions,

        # Alerts
        "total_alerts": total_alerts,
        "open_alerts": open_alerts,
        "critical_alerts": critical_alerts,
        "resolved_alerts": resolved_alerts,

        # Referrals
        "total_referrals": total_referrals,
        "pending_referrals": pending_referrals,
        "scheduled_referrals": scheduled_referrals,
        "completed_referrals": completed_referrals,

        "generated_at": datetime.now(timezone.utc)
    }
def get_health_worker_dashboard(db: Session, worker_id: int):

    today = date.today()

    # ==========================================
    # 1. VALIDATE HEALTH WORKER
    # ==========================================

    worker = db.query(Worker).filter(
        Worker.id == worker_id
    ).first()

    if not worker:
        from fastapi import HTTPException

        raise HTTPException(
            status_code=404,
            detail="Health worker not found"
        )

    user = db.query(User).filter(
        User.id == worker.user_id
    ).first()

    if not user:
        from fastapi import HTTPException

        raise HTTPException(
            status_code=404,
            detail="Worker user not found"
        )

    # ==========================================
    # 2. HOUSEHOLD STATISTICS
    # ==========================================

    assigned_households = db.query(Household).filter(
        Household.assigned_worker_id == worker_id
    ).count()

    total_individuals = db.query(Individual).join(
        Household,
        Individual.household_id == Household.id
    ).filter(
        Household.assigned_worker_id == worker_id,
        Individual.is_active == True
    ).count()

    # ==========================================
    # 3. ASSIGNMENT STATISTICS
    # ==========================================

    assignments = db.query(Assignment).filter(
        Assignment.worker_id == worker_id
    )

    total_assignments = assignments.count()

    pending_assignments = db.query(Assignment).filter(
        Assignment.worker_id == worker_id,
        Assignment.status == "pending"
    ).count()

    completed_assignments = db.query(Assignment).filter(
        Assignment.worker_id == worker_id,
        Assignment.status == "completed"
    ).count()

    overdue_assignments = db.query(Assignment).filter(
        Assignment.worker_id == worker_id,
        Assignment.due_date < today,
        Assignment.status.notin_(["completed", "cancelled"])
    ).count()

    # ==========================================
    # 4. SCREENING STATISTICS
    # ==========================================

    total_screenings = db.query(Screening).filter(
        Screening.worker_id == worker_id
    ).count()

    completed_screenings = db.query(Screening).filter(
        Screening.worker_id == worker_id,
        Screening.status == "completed"
    ).count()

    in_progress_screenings = db.query(Screening).filter(
        Screening.worker_id == worker_id,
        Screening.status == "in_progress"
    ).count()

    # ==========================================
    # 5. TODAY'S VISITS
    # ==========================================

    todays_visits = db.query(Assignment).filter(
        Assignment.worker_id == worker_id,
        Assignment.due_date == today,
        Assignment.status.notin_(["completed", "cancelled"])
    ).count()

    # ==========================================
    # 6. FOLLOW-UP STATISTICS
    # ==========================================

    total_followups = db.query(FollowUp).filter(
        FollowUp.worker_id == worker_id
    ).count()

    pending_followups = db.query(FollowUp).filter(
        FollowUp.worker_id == worker_id,
        FollowUp.status == "pending"
    ).count()

    due_today_followups = db.query(FollowUp).filter(
        FollowUp.worker_id == worker_id,
        FollowUp.due_date == today,
        FollowUp.status == "pending"
    ).count()

    completed_followups = db.query(FollowUp).filter(
        FollowUp.worker_id == worker_id,
        FollowUp.status == "completed"
    ).count()

    # ==========================================
    # 7. NOTIFICATION STATISTICS
    # ==========================================

    total_notifications = db.query(Notification).filter(
        Notification.user_id == worker.user_id
    ).count()

    unread_notifications = db.query(Notification).filter(
        Notification.user_id == worker.user_id,
        Notification.is_read == False
    ).count()

    read_notifications = db.query(Notification).filter(
        Notification.user_id == worker.user_id,
        Notification.is_read == True
    ).count()

    # ==========================================
    # 8. RETURN DASHBOARD DATA
    # ==========================================

    return {
        "worker_id": worker.id,
        "worker_name": user.full_name,
        "area": worker.area,

        "assigned_households": assigned_households,
        "total_individuals": total_individuals,

        "total_assignments": total_assignments,
        "pending_assignments": pending_assignments,
        "completed_assignments": completed_assignments,
        "overdue_assignments": overdue_assignments,

        "total_screenings": total_screenings,
        "completed_screenings": completed_screenings,
        "in_progress_screenings": in_progress_screenings,

        "todays_visits": todays_visits,

        "total_followups": total_followups,
        "pending_followups": pending_followups,
        "due_today_followups": due_today_followups,
        "completed_followups": completed_followups,

        "total_notifications": total_notifications,
        "unread_notifications": unread_notifications,
        "read_notifications": read_notifications,

        "generated_at": datetime.now(timezone.utc)
    }
def get_citizen_dashboard(db: Session, individual_id: int):

    from fastapi import HTTPException

    today = date.today()
    now = datetime.now(timezone.utc).replace(tzinfo=None)

    # ==========================================
    # 1. VALIDATE CITIZEN
    # ==========================================

    individual = db.query(Individual).filter(
        Individual.id == individual_id,
        Individual.is_active == True
    ).first()

    if not individual:
        raise HTTPException(
            status_code=404,
            detail="Active individual not found"
        )

    # Calculate age
    age = None

    if individual.date_of_birth:
        age = today.year - individual.date_of_birth.year

        if (today.month, today.day) < (
            individual.date_of_birth.month,
            individual.date_of_birth.day
        ):
            age -= 1

    # ==========================================
    # 2. CHECK LATEST CONSENT
    # ==========================================

    consent = db.query(Consent).filter(
        Consent.individual_id == individual_id
    ).order_by(
        Consent.id.desc()
    ).first()

    consent_status = (
        consent.consent_status if consent else "not_recorded"
    )

    # ==========================================
    # 3. INITIALIZE HEALTH DATA
    # ==========================================

    result = {
        "individual_id": individual.id,
        "individual_code": individual.individual_code,
        "full_name": individual.full_name,
        "age": age,
        "gender": individual.gender,
        "blood_group": individual.blood_group,

        "consent_status": consent_status,

        "total_screenings": 0,
        "latest_screening_date": None,
        "latest_screening_status": None,

        "height_cm": None,
        "weight_kg": None,
        "bmi": None,
        "systolic_bp": None,
        "diastolic_bp": None,
        "pulse_rate": None,
        "spo2": None,
        "fasting_glucose": None,
        "hba1c": None,

        "diabetes_risk": None,
        "cardiovascular_risk": None,
        "experimental_predictions": False,

        "total_reports": 0,
        "pending_reports": 0,
        "verified_reports": 0,
        "rejected_reports": 0,

        "total_referrals": 0,
        "pending_referrals": 0,
        "scheduled_referrals": 0,
        "completed_referrals": 0,

        "total_followups": 0,
        "pending_followups": 0,
        "completed_followups": 0,
        "upcoming_followups": 0,

        "total_reminders": 0,
        "pending_reminders": 0,
        "upcoming_reminders": 0,

        "total_notifications": 0,
        "unread_notifications": 0,
        "read_notifications": 0,

        "generated_at": datetime.now(timezone.utc)
    }

    # ==========================================
    # 4. HEALTH DATA - CONSENT REQUIRED
    # ==========================================

    if consent_status.strip().lower() != "granted":
        return result

    # ==========================================
    # 5. SCREENING STATISTICS
    # ==========================================

    screenings = db.query(Screening).filter(
        Screening.individual_id == individual_id
    ).order_by(
        Screening.screening_date.desc(),
        Screening.id.desc()
    ).all()

    result["total_screenings"] = len(screenings)

    if screenings:
        result["latest_screening_date"] = (
            screenings[0].screening_date
        )

        result["latest_screening_status"] = (
            screenings[0].status
        )

    # ==========================================
    # 6. LATEST MEASUREMENTS
    # ==========================================

    measurement = db.query(Measurement).filter(
        Measurement.individual_id == individual_id
    ).order_by(
        Measurement.measured_at.desc(),
        Measurement.id.desc()
    ).first()

    if measurement:

        result.update({
            "height_cm": measurement.height_cm,
            "weight_kg": measurement.weight_kg,
            "bmi": measurement.bmi,
            "systolic_bp": measurement.systolic_bp,
            "diastolic_bp": measurement.diastolic_bp,
            "pulse_rate": measurement.pulse_rate,
            "spo2": measurement.spo2,
            "fasting_glucose": measurement.fasting_glucose,
            "hba1c": measurement.hba1c
        })

    # ==========================================
    # 7. LATEST AI PREDICTIONS
    # ==========================================

    predictions = db.query(AIPrediction).filter(
        AIPrediction.individual_id == individual_id
    ).order_by(
        AIPrediction.created_at.desc(),
        AIPrediction.id.desc()
    ).all()

    latest_diabetes = next(
        (
            p for p in predictions
            if p.prediction_type.lower() == "diabetes"
        ),
        None
    )

    latest_cardiovascular = next(
        (
            p for p in predictions
            if p.prediction_type.lower() == "cardiovascular"
        ),
        None
    )

    if latest_diabetes:
        result["diabetes_risk"] = latest_diabetes.risk_level

    if latest_cardiovascular:
        result["cardiovascular_risk"] = (
            latest_cardiovascular.risk_level
        )

    result["experimental_predictions"] = any(
        p.is_experimental
        for p in [latest_diabetes, latest_cardiovascular]
        if p is not None
    )

    # ==========================================
    # 8. MEDICAL REPORT STATISTICS
    # ==========================================

    reports = db.query(MedicalReport).filter(
        MedicalReport.individual_id == individual_id
    )

    result["total_reports"] = reports.count()

    result["pending_reports"] = reports.filter(
        MedicalReport.verification_status == "pending"
    ).count()

    result["verified_reports"] = reports.filter(
        MedicalReport.verification_status == "verified"
    ).count()

    result["rejected_reports"] = reports.filter(
        MedicalReport.verification_status == "rejected"
    ).count()

    # ==========================================
    # 9. REFERRAL STATISTICS
    # ==========================================

    referrals = db.query(Referral).filter(
        Referral.individual_id == individual_id
    )

    result["total_referrals"] = referrals.count()

    result["pending_referrals"] = referrals.filter(
        Referral.status == "pending"
    ).count()

    result["scheduled_referrals"] = referrals.filter(
        Referral.status == "scheduled"
    ).count()

    result["completed_referrals"] = referrals.filter(
        Referral.status == "completed"
    ).count()

    # ==========================================
    # 10. FOLLOW-UP STATISTICS
    # ==========================================

    followups = db.query(FollowUp).filter(
        FollowUp.individual_id == individual_id
    )

    result["total_followups"] = followups.count()

    result["pending_followups"] = followups.filter(
        FollowUp.status == "pending"
    ).count()

    result["completed_followups"] = followups.filter(
        FollowUp.status == "completed"
    ).count()

    result["upcoming_followups"] = followups.filter(
        FollowUp.due_date >= today,
        FollowUp.status == "pending"
    ).count()

    # ==========================================
    # 11. REMINDER STATISTICS
    # ==========================================

    reminders = db.query(Reminder).filter(
        Reminder.individual_id == individual_id
    )

    result["total_reminders"] = reminders.count()

    result["pending_reminders"] = reminders.filter(
        Reminder.status == "pending"
    ).count()

    result["upcoming_reminders"] = reminders.filter(
        Reminder.scheduled_at >= now,
        Reminder.status == "pending"
    ).count()

    # ==========================================
    # 12. NOTIFICATION STATISTICS
    # ==========================================

    notifications = db.query(Notification).filter(
        Notification.individual_id == individual_id
    )

    result["total_notifications"] = notifications.count()

    result["unread_notifications"] = notifications.filter(
        Notification.is_read == False
    ).count()

    result["read_notifications"] = notifications.filter(
        Notification.is_read == True
    ).count()

    return result