
import math
from datetime import datetime


# Features required for Diabetes forecasting
DIABETES_FEATURES = [
    "age",
    "bmi",
    "waist_cm",
    "fasting_glucose",
    "post_meal_glucose",
    "hba1c",
]


# Features required for Cardiovascular forecasting
CARDIOVASCULAR_FEATURES = [
    "age",
    "gender",
    "bmi",
    "waist_cm",
    "systolic_bp",
    "diastolic_bp",
    "pulse_rate",
    "total_cholesterol",
    "hdl",
    "ldl",
    "triglycerides",
]


def is_valid_numeric(value):
    """
    Check whether a value is numeric and finite.
    Does not apply clinical reference ranges.
    """

    if value is None:
        return False

    if isinstance(value, bool):
        return False

    if not isinstance(value, (int, float)):
        return False

    return math.isfinite(value)


def validate_visit(visit, prediction_type):
    """
    Validate the required features for one historical visit.
    """

    if prediction_type == "diabetes":
        required_features = DIABETES_FEATURES

    elif prediction_type == "cardiovascular":
        required_features = CARDIOVASCULAR_FEATURES

    else:
        raise ValueError(
            "prediction_type must be diabetes or cardiovascular"
        )

    missing_features = []
    invalid_features = []

    for feature in required_features:

        value = visit.get(feature)

        if value is None:
            missing_features.append(feature)
            continue

        if feature == "gender":
            if value not in ["Male", "Female"]:
                invalid_features.append(feature)

        elif not is_valid_numeric(value):
            invalid_features.append(feature)

        elif value <= 0:
            invalid_features.append(feature)

    return {
        "screening_id": visit.get("screening_id"),
        "screening_date": visit.get("screening_date"),
        "is_valid": (
            len(missing_features) == 0
            and len(invalid_features) == 0
        ),
        "missing_features": missing_features,
        "invalid_features": invalid_features,
    }


def validate_historical_data(
    historical_data,
    prediction_type
):
    """
    Validate historical health records for forecasting preparation.

    This validator checks data structure and feature availability.
    It does not establish clinical validity or model readiness.
    """

    if prediction_type not in [
        "diabetes",
        "cardiovascular"
    ]:
        raise ValueError(
            "prediction_type must be diabetes or cardiovascular"
        )

    visits = historical_data.get("visits", [])

    valid_visits = []
    invalid_visits = []

    seen_screening_ids = set()
    duplicate_screenings = []

    previous_date = None
    chronology_errors = []

    # Validate each visit
    for visit in visits:

        screening_id = visit.get("screening_id")

        # Check duplicate screening IDs
        if screening_id in seen_screening_ids:
            duplicate_screenings.append(screening_id)

        seen_screening_ids.add(screening_id)

        # Check chronological order
        screening_date = visit.get("screening_date")

        if screening_date:
            try:
                current_date = datetime.fromisoformat(
                    screening_date.replace("Z", "+00:00")
                )

                if (
                    previous_date is not None
                    and current_date < previous_date
                ):
                    chronology_errors.append(screening_id)

                previous_date = current_date

            except (ValueError, TypeError, AttributeError):
                chronology_errors.append(screening_id)

        result = validate_visit(
            visit,
            prediction_type
        )

        if result["is_valid"]:
            valid_visits.append(result)
        else:
            invalid_visits.append(result)

    total_visits = len(visits)

    valid_count = len(valid_visits)

    invalid_count = len(invalid_visits)

    # Three visits are only a preliminary
    # sequence preparation threshold.
    sequence_ready = (
        total_visits >= 3
        and valid_count == total_visits
        and len(duplicate_screenings) == 0
        and len(chronology_errors) == 0
    )

    return {
        "individual_id": historical_data.get(
            "individual_id"
        ),

        "prediction_type": prediction_type,

        "total_visits": total_visits,

        "valid_visits": valid_count,

        "invalid_visits": invalid_count,

        "valid_visit_details": valid_visits,

        "invalid_visit_details": invalid_visits,

        "duplicate_screening_ids": duplicate_screenings,

        "chronology_errors": chronology_errors,

        "sequence_ready": sequence_ready,

        "validation_status": (
            "ready_for_sequence_preparation"
            if sequence_ready
            else "insufficient_or_invalid_historical_data"
        ),

        "disclaimer": (
            "This validation checks data structure, missing "
            "features and chronological ordering only. "
            "It does not establish clinical validity, "
            "forecasting accuracy or readiness for clinical use."
        )
    }
