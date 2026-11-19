
import json

from app.database.session import SessionLocal

from app.ai.forecasting.historical_data import (
    get_individual_historical_data
)

from app.ai.forecasting.sequence_builder import (
    build_health_sequence
)


db = SessionLocal()

try:

    historical_data = get_individual_historical_data(
        db=db,
        individual_id=1
    )

    diabetes_sequence = build_health_sequence(
        historical_data,
        prediction_type="diabetes"
    )

    cardiovascular_sequence = build_health_sequence(
        historical_data,
        prediction_type="cardiovascular"
    )

    print("\n========== DIABETES SEQUENCE ==========")

    print(json.dumps(
        diabetes_sequence,
        indent=4
    ))

    print("\n========== CARDIOVASCULAR SEQUENCE ==========")

    print(json.dumps(
        cardiovascular_sequence,
        indent=4
    ))

finally:
    db.close()
