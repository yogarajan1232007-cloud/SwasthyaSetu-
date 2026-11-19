from fastapi import HTTPException
from sqlalchemy.orm import Session

from app.models.ai_explanation import AIExplanation
from app.models.ai_prediction import AIPrediction


def create_explanation(db: Session, explanation_data):

    prediction = db.query(AIPrediction).filter(
        AIPrediction.id == explanation_data.prediction_id
    ).first()

    if not prediction:
        raise HTTPException(
            status_code=404,
            detail="AI prediction not found"
        )

    explanation = AIExplanation(
        prediction_id=explanation_data.prediction_id,
        explanation=explanation_data.explanation,
        language=explanation_data.language,
        generated_by=explanation_data.generated_by
    )

    db.add(explanation)
    db.commit()
    db.refresh(explanation)

    return explanation


def get_explanations(
    db: Session,
    prediction_id=None
):

    query = db.query(AIExplanation)

    if prediction_id is not None:
        query = query.filter(
            AIExplanation.prediction_id == prediction_id
        )

    return query.order_by(
        AIExplanation.created_at.desc()
    ).all()


def get_explanation_by_id(db: Session, explanation_id: int):

    explanation = db.query(AIExplanation).filter(
        AIExplanation.id == explanation_id
    ).first()

    if not explanation:
        raise HTTPException(
            status_code=404,
            detail="AI explanation not found"
        )

    return explanation