import json

from app.database.session import SessionLocal

from app.ai.prediction.prediction_engine import run_prediction


def main():

    db = SessionLocal()

    try:
        screening_id = 3

        print("\n================================")
        print("SWASTHYASETHU AI INFERENCE TEST")
        print("================================")

        # Diabetes prediction
        print("\n1. DIABETES MODEL")
        print("-----------------------------")

        diabetes_result = run_prediction(
            db=db,
            screening_id=screening_id,
            prediction_type="diabetes"
        )

        print(json.dumps(
            diabetes_result,
            indent=4,
            default=str
        ))

        # CVD prediction
        print("\n2. CARDIOVASCULAR MODEL")
        print("-----------------------------")

        cvd_result = run_prediction(
            db=db,
            screening_id=screening_id,
            prediction_type="cardiovascular"
        )

        print(json.dumps(
            cvd_result,
            indent=4,
            default=str
        ))

        print("\n================================")
        print("BOTH INFERENCE TESTS COMPLETED")
        print("================================")

    except Exception as error:

        print("\nINFERENCE TEST FAILED")
        print(type(error).__name__, ":", str(error))

        raise

    finally:
        db.close()


if __name__ == "__main__":
    main()