"""
SwasthyaSetu synthetic demo-data seeder.
Run from backend/ with DATABASE_PATH pointing to swasthya_setu_demo_test.db.
Only fictional demo data is created. Original database is not touched.
"""

import json
import random
from datetime import date, datetime, timedelta

from sqlalchemy import inspect
from app.database.session import SessionLocal
from app.models import (
    User, Worker, Household, Individual, Consent, Assignment, Screening,
    Measurement, AIModelVersion, FollowUp, Referral, Alert, Notification,
)
from app.services.ai_inference_service import run_and_save_prediction

TAG = "DEMO-SEED-2026"
rng = random.Random(20261120)
MODEL_PATHS = {
    "diabetes": "trained_models/diabetes/diabetes_best_model.joblib",
    "cardiovascular": "trained_models/cvd_experiment_b/cvd_best_model.joblib",
}
AREAS = ["North Zone", "South Zone", "East Zone", "West Zone", "Central Zone", "River Side"]
FACILITIES = [
    "Government Primary Health Centre",
    "Urban Community Health Centre",
    "District Government Hospital",
]


def add(db, model, **values):
    # Keep only real mapped columns; avoids passing unsupported optional fields.
    mapper = inspect(model)
    columns = {column.key for column in mapper.column_attrs}
    row = model(**{key: value for key, value in values.items() if key in columns})
    db.add(row)
    db.flush()
    return row


def bmi(height, weight):
    return round(weight / ((height / 100) ** 2), 1)


def seed(db):
    # Idempotency guard: never duplicate a prior run of this seed.
    if db.query(User).filter(User.employee_id.like(f"{TAG}%")).first():
        print(f"{TAG} already exists. No records added.")
        return

    # Fictional user rows are only for foreign-key relationships.
    # This backend has no login/authentication implementation.
    officer = add(
        db, User, employee_id=f"{TAG}-OFFICER",
        full_name="Demo Health Officer", mobile_number="9000000001",
        email="demo.officer@example.invalid",
        hashed_password="DEMO-ONLY-NOT-A-REAL-PASSWORD",
        role="health_officer", is_active=True,
    )
    supervisor = add(
        db, User, employee_id=f"{TAG}-SUPERVISOR",
        full_name="Demo Medical Supervisor", mobile_number="9000000002",
        email="demo.supervisor@example.invalid",
        hashed_password="DEMO-ONLY-NOT-A-REAL-PASSWORD",
        role="health_officer", is_active=True,
    )
    add(
        db, User, employee_id=f"{TAG}-ADMIN",
        full_name="Demo System Administrator", mobile_number="9000000003",
        email="demo.admin@example.invalid",
        hashed_password="DEMO-ONLY-NOT-A-REAL-PASSWORD",
        role="admin", is_active=True,
    )

    workers = []
    for i in range(1, 7):
        worker_user = add(
            db, User, employee_id=f"{TAG}-USER-{i:02d}",
            full_name=f"Demo Health Worker {i:02d}",
            mobile_number=f"900001{i:04d}",
            email=f"demo.worker{i:02d}@example.invalid",
            hashed_password="DEMO-ONLY-NOT-A-REAL-PASSWORD",
            role="health_worker", is_active=True,
        )
        workers.append(add(
            db, Worker, user_id=worker_user.id,
            designation="Community Health Worker",
            area=AREAS[(i - 1) % len(AREAS)],
            employee_code=f"{TAG}-WORKER-{i:02d}",
            is_available=True,
        ))

    # Register existing trusted artifacts as experimental/inactive.
    model_rows = {}
    for kind, path in MODEL_PATHS.items():
        model = (
            db.query(AIModelVersion)
            .filter(
                AIModelVersion.model_type == kind,
                AIModelVersion.model_path == path,
                AIModelVersion.dataset_type == "synthetic",
                AIModelVersion.validation_status == "experimental",
                AIModelVersion.approval_status == "pending",
                AIModelVersion.is_active.is_(False),
            )
            .order_by(AIModelVersion.id.desc()).first()
        )
        if model is None:
            model = add(
                db, AIModelVersion,
                model_name=f"SwasthyaSetu {kind.title()} Risk Model",
                model_type=kind, version="demo-1.0",
                framework="scikit-learn", model_path=path,
                dataset_type="synthetic", validation_status="experimental",
                approval_status="pending", is_active=False,
                performance_metrics=json.dumps({
                    "purpose": "synthetic demonstration",
                    "not_for_clinical_decision": True,
                }),
            )
        model_rows[kind] = model

    today = date.today()
    individuals, screenings = [], []

    # 20 households Ã— 3 adults = 60 individuals and complete screenings.
    for h in range(1, 21):
        worker = workers[(h - 1) % len(workers)]
        household = add(
            db, Household,
            household_code=f"{TAG}-HH-{h:03d}",
            head_of_family=f"Demo Household Head {h:02d}",
            address=f"{h}, Demo Street, Sample Nagar",
            area=AREAS[(h - 1) % len(AREAS)],
            pincode="641000", assigned_worker_id=worker.id,
        )
        assignment = add(
            db, Assignment,
            worker_id=worker.id, household_id=household.id,
            assigned_by=officer.id,
            assignment_date=datetime.combine(today - timedelta(days=12), datetime.min.time()),
            due_date=today - timedelta(days=2),
            status="completed",
            remarks=f"{TAG}: fictional completed household visit",
        )

        for p in range(1, 4):
            n = (h - 1) * 3 + p
            age = rng.randint(30, 75)
            dob = date(today.year - age, rng.randint(1, 12), rng.randint(1, 28))
            gender = "Male" if n % 2 else "Female"
            person = add(
                db, Individual,
                individual_code=f"{TAG}-IND-{n:03d}",
                household_id=household.id,
                full_name=f"Demo Resident {n:03d}",
                date_of_birth=dob, gender=gender,
                mobile_number=f"91000{n:05d}",
                blood_group=["A+", "B+", "O+", "AB+", "A-", "O-"][n % 6],
                is_active=True,
            )
            individuals.append(person)

            add(
                db, Consent, individual_id=person.id, worker_id=worker.id,
                consent_status="granted", consent_version="demo-v1",
                consent_method="in_person",
                remarks=f"{TAG}: fictional consent",
                granted_at=datetime.utcnow(),
            )

            screening_date = datetime.combine(
                today - timedelta(days=10 + n % 5), datetime.min.time()
            )
            screening = add(
                db, Screening,
                individual_id=person.id, worker_id=worker.id,
                assignment_id=assignment.id, screening_type="monthly",
                screening_date=screening_date, status="completed",
                medical_history="Synthetic demonstration history",
                remarks=f"{TAG}: synthetic screening",
            )
            screenings.append(screening)

            height = round(rng.uniform(150, 185), 1)
            weight = round(rng.uniform(48, 96), 1)
            add(
                db, Measurement,
                screening_id=screening.id, individual_id=person.id,
                height_cm=height, weight_kg=weight, bmi=bmi(height, weight),
                waist_cm=round(rng.uniform(68, 112), 1),
                pulse_rate=rng.randint(60, 105),
                systolic_bp=rng.randint(105, 165),
                diastolic_bp=rng.randint(65, 105),
                fasting_glucose=round(rng.uniform(82, 155), 1),
                post_meal_glucose=round(rng.uniform(105, 230), 1),
                glucose_context="fasting_and_post_meal",
                hba1c=round(rng.uniform(4.8, 7.8), 1),
                total_cholesterol=rng.randint(145, 265),
                hdl=rng.randint(30, 75),
                ldl=rng.randint(75, 180),
                triglycerides=rng.randint(75, 260),
                spo2=rng.randint(95, 100),
                measurement_notes=f"{TAG}: synthetic values; not clinical data",
                measured_at=screening_date,
            )

    db.commit()

    # Run real inference through the existing application service.
    counts = {"diabetes": 0, "cardiovascular": 0}
    errors = []
    for screening in screenings:
        for kind in ("diabetes", "cardiovascular"):
            try:
                prediction = run_and_save_prediction(db, screening.id, kind)
                counts[kind] += 1
                if (prediction.risk_level or "").lower() == "high":
                    add(
                        db, Alert,
                        individual_id=screening.individual_id,
                        prediction_id=prediction.id,
                        assigned_to=officer.id, severity="high",
                        title=f"{kind.title()} risk flagged (demo)",
                        message=f"{TAG}: model returned high risk. Synthetic demo only; not a diagnosis.",
                        status="open",
                    )
                db.commit()
            except Exception as exc:
                db.rollback()
                errors.append(f"screening {screening.id}, {kind}: {exc}")

    # Follow-ups and referrals.
    for i, person in enumerate(individuals[:15]):
        add(
            db, FollowUp, individual_id=person.id,
            worker_id=workers[i % len(workers)].id,
            screening_id=screenings[i].id,
            followup_type="routine_review",
            due_date=today + timedelta(days=7 + i % 14),
            status="pending", notes=f"{TAG}: synthetic follow-up",
        )

    for i in range(10):
        person_index = i * 6
        add(
            db, Referral,
            individual_id=individuals[person_index].id,
            screening_id=screenings[person_index].id,
            created_by=officer.id,
            facility_name=FACILITIES[i % len(FACILITIES)],
            clinician_name="Demo Medical Officer",
            reason="Synthetic demonstration referral for review",
            urgency="routine", status="pending",
            referred_at=datetime.utcnow(),
            notes=f"{TAG}: not a real patient referral",
        )

    for i in range(20):
        add(
            db, Notification,
            user_id=officer.id if i % 2 == 0 else supervisor.id,
            individual_id=individuals[i].id,
            title="Demo screening record available",
            message=f"{TAG}: synthetic screening data added.",
            notification_type="system", is_read=False,
        )

    db.commit()

    print("\n===== SWASTHYASETU DEMO SEED SUMMARY =====")
    for label, model in [
        ("Users", User), ("Workers", Worker), ("Households", Household),
        ("Individuals", Individual), ("Consents", Consent),
        ("Assignments", Assignment), ("Screenings", Screening),
        ("Measurements", Measurement), ("AI model registrations", AIModelVersion),
        ("AI predictions", __import__("app.models", fromlist=["AIPrediction"]).AIPrediction),
        ("Alerts", Alert), ("Follow-ups", FollowUp),
        ("Referrals", Referral), ("Notifications", Notification),
    ]:
        print(f"{label}: {db.query(model).count()}")
    print(f"New diabetes predictions: {counts['diabetes']}")
    print(f"New cardiovascular predictions: {counts['cardiovascular']}")
    if errors:
        print("\nPrediction errors:")
        for error in errors:
            print(" -", error)
    else:
        print("All AI inference calls succeeded.")
    print("All generated records are fictional and not for clinical use.")


def main():
    db = SessionLocal()
    try:
        seed(db)
    except Exception:
        db.rollback()
        raise
    finally:
        db.close()


if __name__ == "__main__":
    main()

