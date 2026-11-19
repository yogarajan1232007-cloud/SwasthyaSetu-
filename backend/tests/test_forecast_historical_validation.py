from app.ai.forecasting.data_validator import (
    validate_historical_data
)


def create_six_diabetes_visits():

    visits = []

    for i in range(6):

        visits.append({
            "screening_id": i + 1,
            "screening_date": f"2026-0{i+1}-01",
            "age": 45,
            "bmi": 25.5,
            "waist_cm": 85,
            "fasting_glucose": 95,
            "post_meal_glucose": 130,
            "hba1c": 5.6,
        })

    return visits


def test_six_valid_visits():

    data = {
        "individual_id": 1,
        "visits": create_six_diabetes_visits()
    }

    result = validate_historical_data(
        data,
        "diabetes"
    )

    assert result["sequence_ready"] is True
    assert result["valid_visits"] == 6


def test_duplicate_screening_ids():

    visits = create_six_diabetes_visits()

    visits[1]["screening_id"] = visits[0]["screening_id"]

    result = validate_historical_data(
        {"individual_id": 1, "visits": visits},
        "diabetes"
    )

    assert result["sequence_ready"] is False
    assert len(result["duplicate_screening_ids"]) == 1


def test_incorrect_chronology():

    visits = create_six_diabetes_visits()

    visits[3]["screening_date"] = "2025-01-01"

    result = validate_historical_data(
        {"individual_id": 1, "visits": visits},
        "diabetes"
    )

    assert result["sequence_ready"] is False
    assert len(result["chronology_errors"]) > 0


def test_missing_measurement():

    visits = create_six_diabetes_visits()

    visits[2]["hba1c"] = None

    result = validate_historical_data(
        {"individual_id": 1, "visits": visits},
        "diabetes"
    )

    assert result["sequence_ready"] is False
    assert result["invalid_visits"] == 1


def test_duplicate_screening_dates():

    visits = create_six_diabetes_visits()

    visits[1]["screening_date"] = visits[0]["screening_date"]

    result = validate_historical_data(
        {"individual_id": 1, "visits": visits},
        "diabetes"
    )

    # The general historical validator currently checks
    # chronology, but does not reject duplicate dates.
    # The forecasting service performs this stricter check.

    assert result["sequence_ready"] is True