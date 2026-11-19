import pytest

from fastapi import HTTPException

from app.services import forecast_service


def create_six_diabetes_visits():

    visits = []

    for i in range(6):
        visits.append({
            "screening_id": i + 1,
            "screening_date": f"2026-0{i+1}-01",
            "age": 45,
            "gender": "Male",
            "bmi": 25.5,
            "waist_cm": 85,
            "fasting_glucose": 95,
            "post_meal_glucose": 130,
            "hba1c": 5.6,
        })

    return visits


def mock_historical_data(visits):

    return {
        "individual_id": 1,
        "individual_code": "TEST001",
        "visits": visits,
    }


def test_invalid_prediction_type():

    with pytest.raises(HTTPException) as exc:

        forecast_service.generate_individual_forecast(
            db=None,
            individual_id=1,
            prediction_type="invalid",
        )

    assert exc.value.status_code == 400


def test_invalid_individual(monkeypatch):

    def mock_get_history(db, individual_id):

        raise HTTPException(
            status_code=404,
            detail="Active individual not found",
        )

    monkeypatch.setattr(
        forecast_service,
        "get_individual_historical_data",
        mock_get_history,
    )

    with pytest.raises(HTTPException) as exc:

        forecast_service.generate_individual_forecast(
            db=None,
            individual_id=999999,
            prediction_type="diabetes",
        )

    assert exc.value.status_code == 404


def test_insufficient_history(monkeypatch):

    monkeypatch.setattr(
        forecast_service,
        "get_individual_historical_data",
        lambda db, individual_id: mock_historical_data(
            create_six_diabetes_visits()[:1]
        ),
    )

    with pytest.raises(HTTPException) as exc:

        forecast_service.generate_individual_forecast(
            db=None,
            individual_id=1,
            prediction_type="diabetes",
        )

    assert exc.value.status_code == 409


def test_missing_measurement(monkeypatch):

    visits = create_six_diabetes_visits()

    visits[2]["hba1c"] = None

    monkeypatch.setattr(
        forecast_service,
        "get_individual_historical_data",
        lambda db, individual_id: mock_historical_data(visits),
    )

    with pytest.raises(HTTPException) as exc:

        forecast_service.generate_individual_forecast(
            db=None,
            individual_id=1,
            prediction_type="diabetes",
        )

    assert exc.value.status_code == 422


def test_duplicate_screening_ids(monkeypatch):

    visits = create_six_diabetes_visits()

    visits[1]["screening_id"] = visits[0]["screening_id"]

    monkeypatch.setattr(
        forecast_service,
        "get_individual_historical_data",
        lambda db, individual_id: mock_historical_data(visits),
    )

    with pytest.raises(HTTPException) as exc:

        forecast_service.generate_individual_forecast(
            db=None,
            individual_id=1,
            prediction_type="diabetes",
        )

    assert exc.value.status_code == 422


def test_duplicate_screening_dates(monkeypatch):

    visits = create_six_diabetes_visits()

    visits[1]["screening_date"] = visits[0]["screening_date"]

    monkeypatch.setattr(
        forecast_service,
        "get_individual_historical_data",
        lambda db, individual_id: mock_historical_data(visits),
    )

    with pytest.raises(HTTPException) as exc:

        forecast_service.generate_individual_forecast(
            db=None,
            individual_id=1,
            prediction_type="diabetes",
        )

    assert exc.value.status_code == 422


def test_successful_forecast(monkeypatch):

    visits = create_six_diabetes_visits()

    expected_forecast = {
        "prediction_type": "diabetes",
        "forecast_horizon": "next_visit",
        "is_experimental": True,
        "is_clinically_validated": False,
    }

    monkeypatch.setattr(
        forecast_service,
        "get_individual_historical_data",
        lambda db, individual_id: mock_historical_data(visits),
    )

    monkeypatch.setattr(
        forecast_service,
        "run_forecast",
        lambda visits, prediction_type: expected_forecast,
    )

    result = forecast_service.generate_individual_forecast(
        db=None,
        individual_id=1,
        prediction_type="diabetes",
    )

    assert result["individual_id"] == 1
    assert result["prediction_type"] == "diabetes"
    assert result["historical_visits_used"] == 6
    assert result["status"] == "experimental"
    assert result["is_clinically_validated"] is False
    assert result["forecast"] == expected_forecast