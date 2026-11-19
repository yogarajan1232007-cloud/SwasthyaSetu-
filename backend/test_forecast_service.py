from fastapi import HTTPException

from app.database.session import SessionLocal

from app.services.forecast_service import (
    generate_individual_forecast
)


def main():

    db = SessionLocal()

    try:

        individual_id = 1

        print("\nTESTING REAL PATIENT FORECAST SERVICE")

        print("Individual ID:", individual_id)

        for prediction_type in [
            "diabetes",
            "cardiovascular"
        ]:

            print(f"\nTesting {prediction_type}...")

            try:

                result = generate_individual_forecast(
                    db=db,
                    individual_id=individual_id,
                    prediction_type=prediction_type
                )

                print(result)

            except HTTPException as error:

                print("HTTP Status:", error.status_code)
                print("Detail:", error.detail)

    finally:

        db.close()


if __name__ == "__main__":

    main()