from datetime import datetime

from pydantic import BaseModel


class GovernmentDashboardResponse(BaseModel):

    # Population
    total_population: int
    male_population: int
    female_population: int
    senior_citizens: int
    children: int
    active_population: int

    # Households
    total_households: int
    assigned_households: int
    unassigned_households: int

    # Workers
    total_workers: int
    available_workers: int
    unavailable_workers: int

    # Screenings
    total_screenings: int
    completed_screenings: int
    unique_individuals_screened: int
    in_progress_screenings: int

    # Assignments
    total_assignments: int
    pending_assignments: int
    completed_assignments: int
    overdue_assignments: int

    # AI Predictions
    total_predictions: int
    experimental_predictions: int
    non_experimental_predictions: int
    diabetes_predictions: int
    cardiovascular_predictions: int
    low_risk_predictions: int
    medium_risk_predictions: int
    high_risk_predictions: int

    # Alerts
    total_alerts: int
    open_alerts: int
    critical_alerts: int
    resolved_alerts: int

    # Referrals
    total_referrals: int
    pending_referrals: int
    scheduled_referrals: int
    completed_referrals: int

    generated_at: datetime
class HealthWorkerDashboardResponse(BaseModel):

    worker_id: int
    worker_name: str
    area: str

    # Households
    assigned_households: int
    total_individuals: int

    # Assignments
    total_assignments: int
    pending_assignments: int
    completed_assignments: int
    overdue_assignments: int

    # Screenings
    total_screenings: int
    completed_screenings: int
    in_progress_screenings: int

    # Today's Visits
    todays_visits: int

    # Follow-ups
    total_followups: int
    pending_followups: int
    due_today_followups: int
    completed_followups: int

    # Notifications
    total_notifications: int
    unread_notifications: int
    read_notifications: int

    generated_at: datetime
class CitizenDashboardResponse(BaseModel):

    # Profile
    individual_id: int
    individual_code: str
    full_name: str
    age: int | None
    gender: str | None
    blood_group: str | None

    # Consent
    consent_status: str

    # Screening
    total_screenings: int
    latest_screening_date: datetime | None
    latest_screening_status: str | None

    # Measurements
    height_cm: float | None
    weight_kg: float | None
    bmi: float | None
    systolic_bp: float | None
    diastolic_bp: float | None
    pulse_rate: int | None
    spo2: float | None
    fasting_glucose: float | None
    hba1c: float | None

    # AI Risk Assessments
    diabetes_risk: str | None
    cardiovascular_risk: str | None
    experimental_predictions: bool

    # Medical Reports
    total_reports: int
    pending_reports: int
    verified_reports: int
    rejected_reports: int

    # Referrals
    total_referrals: int
    pending_referrals: int
    scheduled_referrals: int
    completed_referrals: int

    # Follow-ups
    total_followups: int
    pending_followups: int
    completed_followups: int
    upcoming_followups: int

    # Reminders
    total_reminders: int
    pending_reminders: int
    upcoming_reminders: int

    # Notifications
    total_notifications: int
    unread_notifications: int
    read_notifications: int

    generated_at: datetime