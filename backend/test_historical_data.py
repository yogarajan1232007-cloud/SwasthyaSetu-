from app.database.session import SessionLocal
from app.ai.forecasting.historical_data import (
    get_individual_historical_data
)


db = SessionLocal()

try:
    result = get_individual_historical_data(
        db=db,
        individual_id=1
    )

    import json

    print(json.dumps(result, indent=4))

finally:
    db.close()