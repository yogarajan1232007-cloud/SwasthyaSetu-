from typing import Any

from app.ai.forecasting.data_validator import (
    validate_historical_data
)


DIABETES_FEATURES = [
    "age",
    "bmi",
    "waist_cm",
    "fasting_glucose",
    "post_meal_glucose",
    "hba1c",
]


CARDIOVASCULAR_FEATURES = [
    "age",
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


def build_health_sequence(
    historical_data: dict[str, Any],
    prediction_type: str
):
    """
    Convert validated historical screening visits into
    chronological numerical sequences.

    This module prepares data only. It does not train
    models or generate future health predictions.
    """

    if prediction_type not in [
        "diabetes",
        "cardiovascular"
    ]:
        raise ValueError(
            "prediction_type must be diabetes or cardiovascular"
        )

    # 1. Validate historical data
    validation = validate_historical_data(
        historical_data=historical_data,
        prediction_type=prediction_type
    )

    # 2. Select features
    if prediction_type == "diabetes":
        selected_features = DIABETES_FEATURES

    else:
        selected_features = CARDIOVASCULAR_FEATURES

    visits = historical_data.get("visits", [])

    # 3. Stop if there is insufficient history
    if not validation["sequence_ready"]:

        return {
            "individual_id": historical_data.get(
                "individual_id"
            ),
            "prediction_type": prediction_type,
            "sequence_ready": False,
            "total_visits": len(visits),
            "valid_visits": validation["valid_visits"],
            "required_features": selected_features,
            "sequences": [],
            "status": "insufficient_historical_data",
            "message": (
                "Insufficient valid historical screening visits. "
                "At least three distinct valid visits are required "
                "for preliminary sequence preparation."
            )
        }

    # 4. Create chronological sequences
    sequences = []

    for visit in visits:

        feature_values = [
            float(visit[feature])
            for feature in selected_features
        ]

        sequences.append({
            "screening_id": visit["screening_id"],
            "screening_date": visit["screening_date"],
            "features": feature_values
        })

    # 5. Return prepared sequence
    return {
        "individual_id": historical_data.get(
            "individual_id"
        ),
        "prediction_type": prediction_type,
        "sequence_ready": True,
        "total_visits": len(sequences),
        "feature_count": len(selected_features),
        "required_features": selected_features,
        "sequences": sequences,
        "status": "sequence_prepared",
        "message": (
            "Historical screening sequence prepared successfully."
        ),
        "disclaimer": (
            "This is a data preparation result, not a medical "
            "diagnosis or future health prediction."
        )
    }
