import logging

import numpy as np
import torch

from fastapi import HTTPException

from app.ai.forecasting.model_loader import (
    load_forecasting_model,
    SEQUENCE_LENGTH,
)


logger = logging.getLogger(__name__)


# --------------------------------------------------
# FEATURE CONFIGURATION
# --------------------------------------------------

DIABETES_INPUT_FEATURES = [
    "age",
    "bmi",
    "waist_cm",
    "fasting_glucose",
    "post_meal_glucose",
    "hba1c",
]

DIABETES_TARGET_FEATURES = [
    "fasting_glucose",
    "post_meal_glucose",
    "hba1c",
]


CARDIOVASCULAR_INPUT_FEATURES = [
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

CARDIOVASCULAR_TARGET_FEATURES = [
    "systolic_bp",
    "diastolic_bp",
    "total_cholesterol",
    "hdl",
    "ldl",
    "triglycerides",
]


FEATURE_CONFIG = {
    "diabetes": {
        "input_features": DIABETES_INPUT_FEATURES,
        "target_features": DIABETES_TARGET_FEATURES,
    },
    "cardiovascular": {
        "input_features": CARDIOVASCULAR_INPUT_FEATURES,
        "target_features": CARDIOVASCULAR_TARGET_FEATURES,
    },
}


# --------------------------------------------------
# VALIDATE INPUT
# --------------------------------------------------

def prepare_input_sequence(
    visits,
    prediction_type,
):

    if prediction_type not in FEATURE_CONFIG:

        raise HTTPException(
            status_code=400,
            detail="Unsupported forecasting type."
        )

    if not isinstance(visits, list):

        raise HTTPException(
            status_code=422,
            detail="Historical visits must be a list."
        )

    if len(visits) != SEQUENCE_LENGTH:

        raise HTTPException(
            status_code=422,
            detail=(
                f"Exactly {SEQUENCE_LENGTH} historical visits "
                "are required."
            )
        )

    feature_names = FEATURE_CONFIG[
        prediction_type
    ]["input_features"]

    sequence = []

    for visit_index, visit in enumerate(visits):

        row = []

        for feature in feature_names:

            if feature not in visit:

                raise HTTPException(
                    status_code=422,
                    detail=(
                        f"Missing feature '{feature}' "
                        f"in historical visit {visit_index + 1}."
                    )
                )

            value = visit[feature]

            if feature == "gender":

                if value == "Female":
                    value = 0.0

                elif value == "Male":
                    value = 1.0

                else:
                    raise HTTPException(
                        status_code=422,
                        detail=(
                            "Gender must be Male or Female "
                            "for the experimental CVD model."
                        )
                    )

            try:

                value = float(value)

            except (TypeError, ValueError):

                raise HTTPException(
                    status_code=422,
                    detail=(
                        f"Invalid value for '{feature}' "
                        f"in historical visit {visit_index + 1}."
                    )
                )

            if not np.isfinite(value):

                raise HTTPException(
                    status_code=422,
                    detail=(
                        f"Non-finite value for '{feature}'."
                    )
                )

            if feature != "gender" and value <= 0:

                raise HTTPException(
                    status_code=422,
                    detail=(
                        f"'{feature}' must be greater than zero."
                    )
                )

            row.append(value)

        sequence.append(row)

    sequence = np.asarray(
        sequence,
        dtype=np.float32
    )

    expected_features = len(feature_names)

    if sequence.shape != (
        SEQUENCE_LENGTH,
        expected_features
    ):

        raise HTTPException(
            status_code=422,
            detail="Historical sequence dimensions are invalid."
        )

    return sequence


# --------------------------------------------------
# RUN FORECAST
# --------------------------------------------------

def run_forecast(
    visits,
    prediction_type,
):

    if prediction_type not in FEATURE_CONFIG:

        raise HTTPException(
            status_code=400,
            detail="Unsupported forecasting type."
        )

    # Load trained model and scalers.
    artifacts = load_forecasting_model(
        prediction_type
    )

    model = artifacts["model"]

    input_scaler = artifacts["input_scaler"]

    target_scaler = artifacts["target_scaler"]

    device = artifacts["device"]

    # Prepare historical sequence.
    sequence = prepare_input_sequence(
        visits,
        prediction_type
    )

    # Scale historical inputs using the training scaler.
    scaled_sequence = input_scaler.transform(
        sequence
    )

    if not np.isfinite(scaled_sequence).all():

        raise HTTPException(
            status_code=422,
            detail="Scaled historical data contains invalid values."
        )

    # Shape: (1, 6, input_features)
    model_input = torch.tensor(
        scaled_sequence,
        dtype=torch.float32
    ).unsqueeze(0).to(device)

    # Model inference.
    model.eval()

    try:

        with torch.inference_mode():

            scaled_prediction = model(
                model_input
            ).cpu().numpy()

    except Exception:

        logger.exception(
            "Forecast inference failed: %s",
            prediction_type
        )

        raise HTTPException(
            status_code=500,
            detail="Unable to generate health forecast."
        )

    # Inverse transform into original measurement units.
    prediction = target_scaler.inverse_transform(
        scaled_prediction
    )[0]

    if not np.isfinite(prediction).all():

        raise HTTPException(
            status_code=500,
            detail="Forecast generated invalid numerical values."
        )

    # Do not silently modify negative predictions.
    if np.any(prediction < 0):

        raise HTTPException(
            status_code=500,
            detail=(
                "Forecast generated an invalid negative measurement. "
                "Clinical review is required."
            )
        )

    target_features = FEATURE_CONFIG[
        prediction_type
    ]["target_features"]

    forecast_values = {}

    for feature, value in zip(
        target_features,
        prediction
    ):

        forecast_values[feature] = round(
            float(value),
            3
        )

    return {
        "prediction_type": prediction_type,
        "forecast_horizon": "next_visit",
        "historical_visits_used": SEQUENCE_LENGTH,
        "forecasted_measurements": forecast_values,
        "dataset_type": "synthetic",
        "is_experimental": True,
        "is_clinically_validated": False,
        "disclaimer": (
            "Experimental forecast generated using an LSTM "
            "trained on synthetic longitudinal data. "
            "It is not a medical diagnosis or clinically "
            "validated prediction. Do not use it for "
            "treatment decisions."
        ),
    }