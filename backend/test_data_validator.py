import json

from app.database.session import SessionLocal

from app.ai.forecasting.historical_data import (
    get_individual_historical_data
)

from app.ai.forecasting.data_validator import (
    validate_historical_data
)


db = SessionLocal()

try:

    # Retrieve historical records
    historical_data = get_individual_historical_data(
        db=db,
        individual_id=1
    )

    # Validate Diabetes features
    diabetes_result = validate_historical_data(
        historical_data,
        prediction_type="diabetes"
    )

    # Validate Cardiovascular features
    cardiovascular_result = validate_historical_data(
        historical_data,
        prediction_type="cardiovascular"
    )

    print("\n========== DIABETES VALIDATION ==========")

    print(
        json.dumps(
            diabetes_result,
            indent=4
        )
    )

    print("\n========== CARDIOVASCULAR VALIDATION ==========")

    print(
        json.dumps(
            cardiovascular_result,
            indent=4
        )
    )

finally:
    db.close()
