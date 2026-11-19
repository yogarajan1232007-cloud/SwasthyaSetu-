from datetime import datetime

from fastapi import HTTPException
from sqlalchemy.orm import Session

from app.ai.forecasting.historical_data import (
    get_individual_historical_data
)

from app.ai.forecasting.data_validator import (
    validate_visit
)

from app.ai.forecasting.forecast_engine import (
    run_forecast
)


MINIMUM_FORECAST_VISITS = 6


def generate_individual_forecast(
    db: Session,
    individual_id: int,
    prediction_type: str
):

    # 1. Validate prediction type.
    if prediction_type not in [
        "diabetes",
        "cardiovascular"
    ]:

        raise HTTPException(
            status_code=400,
            detail="Unsupported forecasting type."
        )

    # 2. Retrieve actual patient history.
    historical_data = get_individual_historical_data(
        db=db,
        individual_id=individual_id
    )

    visits = historical_data.get("visits", [])

    # 3. Require six historical visits.
    if len(visits) < MINIMUM_FORECAST_VISITS:

        raise HTTPException(
            status_code=409,
            detail={
                "message": (
                    "Insufficient historical data for forecasting."
                ),
                "individual_id": individual_id,
                "available_visits": len(visits),
                "required_visits": MINIMUM_FORECAST_VISITS,
            }
        )

    # 4. Select the latest six visits.
    latest_visits = visits[-MINIMUM_FORECAST_VISITS:]

    # 5. Check unique screening IDs.
    screening_ids = [
        visit.get("screening_id")
        for visit in latest_visits
    ]

    if (
        None in screening_ids
        or len(set(screening_ids)) != MINIMUM_FORECAST_VISITS
    ):

        raise HTTPException(
            status_code=422,
            detail="Historical screening IDs are invalid or duplicated."
        )

    # 6. Require six distinct screening dates.
    screening_dates = []

    for visit in latest_visits:

        screening_date = visit.get("screening_date")

        if not screening_date:

            raise HTTPException(
                status_code=422,
                detail="A historical screening date is missing."
            )

        try:

            parsed_date = datetime.fromisoformat(
                screening_date.replace("Z", "+00:00")
            )

            screening_dates.append(
                parsed_date.date()
            )

        except (ValueError, TypeError, AttributeError):

            raise HTTPException(
                status_code=422,
                detail="Invalid historical screening date."
            )

    if len(set(screening_dates)) != MINIMUM_FORECAST_VISITS:

        raise HTTPException(
            status_code=422,
            detail=(
                "Six distinct screening dates are required. "
                "Multiple screenings on the same date do not "
                "count as separate longitudinal visits."
            )
        )

    # 7. Validate every selected visit.
    invalid_visits = []

    for visit in latest_visits:

        validation = validate_visit(
            visit,
            prediction_type
        )

        if not validation["is_valid"]:

            invalid_visits.append({
                "screening_id": visit.get("screening_id"),
                "missing_features": validation["missing_features"],
                "invalid_features": validation["invalid_features"],
            })

    if invalid_visits:

        raise HTTPException(
            status_code=422,
            detail={
                "message": (
                    "Some of the latest six visits contain "
                    "missing or invalid forecasting features."
                ),
                "invalid_visits": invalid_visits,
            }
        )

    # 8. Generate forecast.
    forecast = run_forecast(
        visits=latest_visits,
        prediction_type=prediction_type
    )

    # 9. Prepare final response.
    return {
        "individual_id": individual_id,
        "individual_code": historical_data.get(
            "individual_code"
        ),
        "prediction_type": prediction_type,
        "historical_visits_used": len(latest_visits),
        "historical_screening_ids": screening_ids,
        "historical_screening_dates": [
            date.isoformat()
            for date in screening_dates
        ],
        "forecast": forecast,
        "status": "experimental",
        "is_clinically_validated": False,
    }