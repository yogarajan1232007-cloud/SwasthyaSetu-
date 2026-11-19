
import json

from fastapi import HTTPException
from sqlalchemy.orm import Session

from app.ai.prediction.prediction_engine import run_prediction
from app.models.ai_prediction import AIPrediction
from app.schemas.ai_prediction import AIPredictionCreate
from app.services.ai_prediction_service import create_prediction


def run_and_save_prediction(
    db: Session,
    screening_id: int,
    prediction_type: str
):
    """
    Execute experimental ML inference and save the result.

    Demonstration records created using synthetic_test are ignored
    during duplicate checking.

    Actual ML prediction records cannot be duplicated for the
    same screening, model version and prediction type.
    """

    try:
        # 1. Execute actual ML inference
        result = run_prediction(
            db=db,
            screening_id=screening_id,
            prediction_type=prediction_type
        )

        model_id = result["model"]["model_id"]

        # 2. Retrieve existing records for this screening and model
        existing_records = (
            db.query(AIPrediction)
            .filter(
                AIPrediction.screening_id == screening_id,
                AIPrediction.model_version_id == model_id,
                AIPrediction.prediction_type == prediction_type
            )
            .all()
        )

        # 3. Ignore demonstration records.
        # Block only if an actual ML prediction already exists.
        for record in existing_records:

            try:
                stored_result = json.loads(
                    record.result_data or "{}"
                )
            except (json.JSONDecodeError, TypeError):
                stored_result = {}

            if stored_result.get("source") != "synthetic_test":
                raise HTTPException(
                    status_code=409,
                    detail=(
                        "An actual prediction already exists "
                        "for this screening and model version."
                    )
                )

        # 4. Prepare actual ML prediction data
        prediction_data = AIPredictionCreate(
            individual_id=result["individual_id"],
            screening_id=screening_id,
            model_version_id=model_id,
            prediction_type=prediction_type,
            risk_level=result["predicted_category"],
            prediction_value=None,
            confidence_score=result["max_class_probability"],
            result_data=json.dumps(result),
            is_experimental=True
        )

        # 5. Save using existing prediction service
        saved_prediction = create_prediction(
            db,
            prediction_data
        )

        return saved_prediction

    except HTTPException:
        raise

    except Exception:
        db.rollback()
        raise
