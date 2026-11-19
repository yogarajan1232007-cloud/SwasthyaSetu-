import logging
from pathlib import Path
from functools import lru_cache

import joblib
from fastapi import HTTPException
from sqlalchemy.orm import Session

from app.models.ai_model_version import AIModelVersion


logger = logging.getLogger(__name__)

# Project root directory
PROJECT_ROOT = Path(__file__).resolve().parents[3]


# Trusted model artifact paths
# Keys must match the existing database model_type values.
ALLOWED_MODEL_PATHS = {
    "diabetes": (
        PROJECT_ROOT
        / "trained_models"
        / "diabetes"
        / "diabetes_best_model.joblib"
    ),

    "cardiovascular": (
        PROJECT_ROOT
        / "trained_models"
        / "cvd_experiment_b"
        / "cvd_best_model.joblib"
    ),
}


@lru_cache(maxsize=4)
def load_model_artifact(model_type: str):

    if model_type not in ALLOWED_MODEL_PATHS:
        raise ValueError(
            f"Unsupported AI model type: {model_type}"
        )

    model_path = ALLOWED_MODEL_PATHS[model_type]

    if not model_path.is_file():
        raise FileNotFoundError(
            f"Model artifact not found: {model_path}"
        )

    try:
        model = joblib.load(model_path)

        if not hasattr(model, "predict"):
            raise ValueError("Invalid prediction model")

        if not hasattr(model, "predict_proba"):
            raise ValueError(
                "Model does not support predict_proba"
            )

        logger.info(
            "Successfully loaded model: %s",
            model_type
        )

        return model

    except Exception:
        logger.exception(
            "Failed to load model: %s",
            model_type
        )
        raise


def get_experimental_model(
    db: Session,
    model_type: str
):

    if model_type not in ALLOWED_MODEL_PATHS:
        raise HTTPException(
            status_code=400,
            detail="Unsupported AI model type"
        )

    registered_model = (
        db.query(AIModelVersion)
        .filter(
            AIModelVersion.model_type == model_type,
            AIModelVersion.dataset_type == "synthetic",
            AIModelVersion.validation_status == "experimental",
            AIModelVersion.approval_status == "pending",
            AIModelVersion.is_active.is_(False)
        )
        .order_by(AIModelVersion.id.desc())
        .first()
    )

    if not registered_model:
        raise HTTPException(
            status_code=404,
            detail=f"No experimental model registered for {model_type}"
        )

    if not registered_model.model_path:
        raise HTTPException(
            status_code=400,
            detail="Registered model path is missing"
        )

    expected_path = ALLOWED_MODEL_PATHS[model_type]

    stored_path = Path(registered_model.model_path)

    if not stored_path.is_absolute():
        stored_path = PROJECT_ROOT / stored_path

    try:
        stored_path = stored_path.resolve()
        expected_path = expected_path.resolve()

    except OSError:
        raise HTTPException(
            status_code=400,
            detail="Invalid registered model path"
        )

    if stored_path != expected_path:
        raise HTTPException(
            status_code=400,
            detail="Registered model path does not match trusted artifact"
        )

    try:
        artifact = load_model_artifact(model_type)

    except Exception:
        logger.exception("Experimental model loading failed")

        raise HTTPException(
            status_code=500,
            detail="Unable to load experimental AI model"
        )

    return registered_model, artifact