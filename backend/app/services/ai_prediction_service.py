
from sqlalchemy.orm import Session
from fastapi import HTTPException

from app.models.ai_prediction import AIPrediction
from app.models.ai_model_version import AIModelVersion
from app.models.individual import Individual
from app.models.screening import Screening


def create_prediction(db: Session, prediction_data):

    individual = db.query(Individual).filter(
        Individual.id == prediction_data.individual_id
    ).first()

    if not individual:
        raise HTTPException(
            status_code=404,
            detail="Individual not found"
        )

    model = db.query(AIModelVersion).filter(
        AIModelVersion.id == prediction_data.model_version_id
    ).first()

    if not model:
        raise HTTPException(
            status_code=404,
            detail="AI model not found"
        )

    if model.model_type.lower() != prediction_data.prediction_type.lower():
        raise HTTPException(
            status_code=400,
            detail="Prediction type does not match AI model type"
        )

    if prediction_data.screening_id is not None:

        screening = db.query(Screening).filter(
            Screening.id == prediction_data.screening_id
        ).first()

        if not screening:
            raise HTTPException(
                status_code=404,
                detail="Screening not found"
            )

        if screening.individual_id != prediction_data.individual_id:
            raise HTTPException(
                status_code=400,
                detail="Screening does not belong to this individual"
            )

    prediction = AIPrediction(
        individual_id=prediction_data.individual_id,
        screening_id=prediction_data.screening_id,
        model_version_id=prediction_data.model_version_id,
        prediction_type=prediction_data.prediction_type,
        risk_level=prediction_data.risk_level,
        prediction_value=prediction_data.prediction_value,
        confidence_score=prediction_data.confidence_score,
        result_data=prediction_data.result_data,
        is_experimental=True
    )

    db.add(prediction)
    db.commit()
    db.refresh(prediction)

    return prediction


def get_predictions(
    db: Session,
    individual_id=None,
    screening_id=None,
    prediction_type=None
):

    query = db.query(AIPrediction)

    if individual_id is not None:
        query = query.filter(
            AIPrediction.individual_id == individual_id
        )

    if screening_id is not None:
        query = query.filter(
            AIPrediction.screening_id == screening_id
        )

    if prediction_type is not None:
        query = query.filter(
            AIPrediction.prediction_type == prediction_type
        )

    return query.order_by(
        AIPrediction.created_at.desc()
    ).all()


def get_prediction_by_id(db: Session, prediction_id: int):

    prediction = db.query(AIPrediction).filter(
        AIPrediction.id == prediction_id
    ).first()

    if not prediction:
        raise HTTPException(
            status_code=404,
            detail="AI prediction not found"
        )

    return prediction
