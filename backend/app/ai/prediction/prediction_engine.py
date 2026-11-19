from fastapi import HTTPException
from sqlalchemy.orm import Session

from app.ai.prediction.model_loader import (
    get_experimental_model
)

from app.ai.prediction.feature_extractor import (
    extract_features
)


SUPPORTED_PREDICTIONS = {
    "diabetes",
    "cardiovascular"
}


def run_prediction(
    db: Session,
    screening_id: int,
    prediction_type: str
):
    """
    Run an experimental ML prediction using a completed
    screening and its actual saved measurements.

    This function does not save prediction records.
    """

    if prediction_type not in SUPPORTED_PREDICTIONS:
        raise HTTPException(
            status_code=400,
            detail="Unsupported prediction type"
        )

    # 1. Retrieve registered experimental model
    registered_model, model = get_experimental_model(
        db,
        prediction_type
    )

    # 2. Extract actual screening features
    extracted = extract_features(
        db,
        screening_id,
        prediction_type
    )

    features = extracted["features"]

    # 3. Generate prediction
    try:
        predicted_class = model.predict(features)[0]

        probabilities = model.predict_proba(features)[0]

        classes = model.classes_

    except Exception as exc:
        raise HTTPException(
            status_code=500,
            detail=f"AI inference failed: {str(exc)}"
        )

    # 4. Map probabilities to their correct class labels
    class_probabilities = {
        str(label): float(probability)
        for label, probability in zip(classes, probabilities)
    }

    predicted_class = str(predicted_class)

    if predicted_class not in class_probabilities:
        raise HTTPException(
            status_code=500,
            detail="Model returned an unexpected prediction class"
        )

    # 5. Calculate maximum class probability
    max_class_probability = max(
        class_probabilities.values()
    )

    # 6. Return structured result
    return {
        "screening_id": screening_id,
        "individual_id": extracted["individual"].id,

        "prediction_type": prediction_type,

        "predicted_category": predicted_class,

        "class_probabilities": class_probabilities,

        "max_class_probability": max_class_probability,

        "model": {
            "model_id": registered_model.id,
            "model_name": registered_model.model_name,
            "version": registered_model.version,
            "dataset_type": registered_model.dataset_type,
            "validation_status": registered_model.validation_status,
            "approval_status": registered_model.approval_status,
            "is_active": registered_model.is_active
        },

        "features_used": extracted["feature_values"],

        "is_experimental": True,

        "disclaimer": (
            "This is an experimental prediction generated using "
            "synthetic training data. It is not a clinical diagnosis "
            "or a clinically validated risk assessment."
        )
    }