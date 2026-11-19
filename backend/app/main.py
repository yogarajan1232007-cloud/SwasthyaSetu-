from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.api.v1.endpoints.households import router as household_router
from app.api.v1.endpoints.individuals import router as individual_router
from app.api.v1.endpoints.workers import router as worker_router
from app.api.v1.endpoints.assignments import router as assignment_router
from app.api.v1.endpoints.consents import router as consent_router
from app.api.v1.endpoints.screenings import router as screening_router
from app.api.v1.endpoints.measurements import router as measurement_router
from app.api.v1.endpoints.medical_reports import router as medical_report_router
from app.api.v1.endpoints.imaging import router as imaging_router
from app.api.v1.endpoints.ai_models import router as ai_model_router
from app.api.v1.endpoints import ai_predictions
from app.api.v1.endpoints import ai_explanations
from app.api.v1.endpoints import alerts
from app.api.v1.endpoints import referrals
from app.api.v1.endpoints import followups
from app.api.v1.endpoints import reminders
from app.api.v1.endpoints import notifications
from app.api.v1.endpoints import audit_logs
from app.api.v1.endpoints import dashboard
from app.api.v1.endpoints import forecasts
import os



app = FastAPI(
    title="SwasthyaSetu API",
    description="Community Health Screening and Monitoring System",
    version="1.0.0"
)
# CORS configuration
cors_origins = [
    origin.strip().rstrip("/")
    for origin in os.getenv("CORS_ORIGINS", "").split(",")
    if origin.strip()
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=cors_origins,
    allow_origin_regex=r"^http://(localhost|127\.0\.0\.1)(:\d+)?$",
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(
    household_router,
    prefix="/api/v1"
)

app.include_router(
    individual_router,
    prefix="/api/v1"
)

app.include_router(
    worker_router,
    prefix="/api/v1"
)

app.include_router(
    assignment_router,
    prefix="/api/v1"
)

app.include_router(
    consent_router,
    prefix="/api/v1"
)

app.include_router(
    audit_logs.router,
    prefix="/api/v1"
)

app.include_router(screening_router, prefix="/api/v1")
app.include_router(measurement_router, prefix="/api/v1")
app.include_router(medical_report_router, prefix="/api/v1")
app.include_router(imaging_router, prefix="/api/v1")
app.include_router(ai_model_router, prefix="/api/v1")
app.include_router(
    ai_predictions.router,
    prefix="/api/v1/ai-predictions",
    tags=["AI Prediction Management"]
)
app.include_router(
    ai_explanations.router,
    prefix="/api/v1/ai-explanations",
    tags=["AI Explanation Management"]
)
app.include_router(
    alerts.router,
    prefix="/api/v1/alerts",
    tags=["Alert Management"]
)
app.include_router(
    referrals.router,
    prefix="/api/v1/referrals",
    tags=["Referral Management"]
)
app.include_router(
    followups.router,
    prefix="/api/v1/followups",
    tags=["Follow-up Management"]
)

app.include_router(
    reminders.router,
    prefix="/api/v1"
)
app.include_router(
    notifications.router,
    prefix="/api/v1"
)
app.include_router(
    dashboard.router,
    prefix="/api/v1"
)

app.include_router(
    forecasts.router,
    prefix="/api/v1/forecasts",
    tags=["Health Forecasting"]
)

@app.get("/")
def root():
    return {
        "message": "Welcome to SwasthyaSetu API",
        "status": "running"
    }


@app.get("/health")
def health_check():
    return {
        "status": "healthy"
    }
