import math
from typing import Optional


# Reference: MoHFW NP-NCD Operational Guidelines 2023-2030

MINIMUM_SCREENING_AGE = 30

FASTING_REVIEW_THRESHOLD = 110
FASTING_ASSESSMENT_THRESHOLD = 126

POST_MEAL_REVIEW_THRESHOLD = 140
POST_MEAL_ASSESSMENT_THRESHOLD = 200

HBA1C_REVIEW_THRESHOLD = 5.7
HBA1C_ASSESSMENT_THRESHOLD = 6.5


def validate_measurement(
    value: Optional[float],
    field_name: str
):
    if value is None:
        return

    if isinstance(value, bool):
        raise ValueError(f"{field_name} must be numeric")

    if not isinstance(value, (int, float)):
        raise ValueError(f"{field_name} must be numeric")

    if not math.isfinite(value) or value <= 0:
        raise ValueError(f"{field_name} must be a positive finite value")


def evaluate_diabetes_screening(
    age: Optional[int],
    fasting_plasma_glucose: Optional[float] = None,
    post_meal_plasma_glucose: Optional[float] = None,
    hba1c: Optional[float] = None
):
    """
    Evaluate adult diabetes screening measurements.

    This function identifies readings requiring clinical review.
    It does not diagnose diabetes or prescribe treatment.

    Glucose inputs must represent plasma glucose measurements.
    HbA1c must represent a laboratory HbA1c result.
    """

    if age is None:
        return {
            "status": "not_evaluated",
            "reason": "Date of birth is unavailable.",
            "alerts": [],
            "is_diagnosis": False
        }

    if isinstance(age, bool) or not isinstance(age, int) or age < 0:
        raise ValueError("Age must be a non-negative integer")

    if age < MINIMUM_SCREENING_AGE:
        return {
            "status": "outside_population_screening_scope",
            "reason": (
                "The adult NP-NCD population screening "
                "rule applies to individuals aged 30 and above."
            ),
            "alerts": [],
            "is_diagnosis": False
        }

    validate_measurement(
        fasting_plasma_glucose,
        "Fasting plasma glucose"
    )

    validate_measurement(
        post_meal_plasma_glucose,
        "Post-meal plasma glucose"
    )

    validate_measurement(
        hba1c,
        "HbA1c"
    )

    alerts = []

    # Fasting plasma glucose evaluation
    if fasting_plasma_glucose is not None:

        if fasting_plasma_glucose >= FASTING_ASSESSMENT_THRESHOLD:
            alerts.append({
                "rule": "FASTING_GLUCOSE_ASSESSMENT",
                "parameter": "fasting_plasma_glucose",
                "value": fasting_plasma_glucose,
                "unit": "mg/dL",
                "message": (
                    "Fasting plasma glucose is at or above "
                    "the reference threshold. Further "
                    "medical assessment is required."
                )
            })

        elif fasting_plasma_glucose >= FASTING_REVIEW_THRESHOLD:
            alerts.append({
                "rule": "FASTING_GLUCOSE_REVIEW",
                "parameter": "fasting_plasma_glucose",
                "value": fasting_plasma_glucose,
                "unit": "mg/dL",
                "message": (
                    "Fasting plasma glucose is in the "
                    "impaired fasting glucose range. "
                    "Clinical review is recommended."
                )
            })

    # Two-hour post-meal plasma glucose evaluation
    if post_meal_plasma_glucose is not None:

        if post_meal_plasma_glucose >= POST_MEAL_ASSESSMENT_THRESHOLD:
            alerts.append({
                "rule": "POST_MEAL_GLUCOSE_ASSESSMENT",
                "parameter": "post_meal_plasma_glucose",
                "value": post_meal_plasma_glucose,
                "unit": "mg/dL",
                "message": (
                    "Two-hour post-meal plasma glucose is "
                    "at or above the reference threshold. "
                    "Further medical assessment is required."
                )
            })

        elif post_meal_plasma_glucose >= POST_MEAL_REVIEW_THRESHOLD:
            alerts.append({
                "rule": "POST_MEAL_GLUCOSE_REVIEW",
                "parameter": "post_meal_plasma_glucose",
                "value": post_meal_plasma_glucose,
                "unit": "mg/dL",
                "message": (
                    "Two-hour post-meal plasma glucose is "
                    "in the impaired glucose tolerance range. "
                    "Clinical review is recommended."
                )
            })

    # HbA1c evaluation
    if hba1c is not None:

        if hba1c >= HBA1C_ASSESSMENT_THRESHOLD:
            alerts.append({
                "rule": "HBA1C_ASSESSMENT",
                "parameter": "hba1c",
                "value": hba1c,
                "unit": "%",
                "message": (
                    "HbA1c is at or above the reference "
                    "threshold. Further medical assessment "
                    "is required."
                )
            })

        elif hba1c >= HBA1C_REVIEW_THRESHOLD:
            alerts.append({
                "rule": "HBA1C_REVIEW",
                "parameter": "hba1c",
                "value": hba1c,
                "unit": "%",
                "message": (
                    "HbA1c is in the prediabetes range. "
                    "Clinical review is recommended."
                )
            })

    return {
        "status": "review_required" if alerts else "no_flagged_result",
        "age": age,
        "alerts": alerts,
        "alert_count": len(alerts),
        "is_diagnosis": False,
        "disclaimer": (
            "Screening support only. These results do not "
            "establish a diabetes diagnosis. Medical "
            "confirmation is required."
        )
    }