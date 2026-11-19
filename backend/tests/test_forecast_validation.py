import pytest

from app.ai.forecasting.data_validator import validate_visit


def create_diabetes_visit():

    return {
        "screening_id": 1,
        "screening_date": "2026-01-01",
        "age": 45,
        "bmi": 25.5,
        "waist_cm": 85,
        "fasting_glucose": 95,
        "post_meal_glucose": 130,
        "hba1c": 5.6,
    }


def create_cvd_visit():

    return {
        "screening_id": 1,
        "screening_date": "2026-01-01",
        "age": 45,
        "gender": "Male",
        "bmi": 25.5,
        "waist_cm": 85,
        "systolic_bp": 120,
        "diastolic_bp": 80,
        "pulse_rate": 75,
        "total_cholesterol": 190,
        "hdl": 50,
        "ldl": 110,
        "triglycerides": 140,
    }


def test_valid_diabetes_visit():

    result = validate_visit(
        create_diabetes_visit(),
        "diabetes"
    )

    assert result["is_valid"] is True


def test_missing_hba1c():

    visit = create_diabetes_visit()

    visit["hba1c"] = None

    result = validate_visit(
        visit,
        "diabetes"
    )

    assert result["is_valid"] is False

    assert "hba1c" in result["missing_features"]


def test_negative_glucose():

    visit = create_diabetes_visit()

    visit["fasting_glucose"] = -10

    result = validate_visit(
        visit,
        "diabetes"
    )

    assert result["is_valid"] is False

    assert "fasting_glucose" in result["invalid_features"]


def test_nan_glucose():

    visit = create_diabetes_visit()

    visit["fasting_glucose"] = float("nan")

    result = validate_visit(
        visit,
        "diabetes"
    )

    assert result["is_valid"] is False


def test_valid_cardiovascular_visit():

    result = validate_visit(
        create_cvd_visit(),
        "cardiovascular"
    )

    assert result["is_valid"] is True


def test_missing_systolic_bp():

    visit = create_cvd_visit()

    visit["systolic_bp"] = None

    result = validate_visit(
        visit,
        "cardiovascular"
    )

    assert result["is_valid"] is False

    assert "systolic_bp" in result["missing_features"]


def test_invalid_gender():

    visit = create_cvd_visit()

    visit["gender"] = "Unknown"

    result = validate_visit(
        visit,
        "cardiovascular"
    )

    assert result["is_valid"] is False

    assert "gender" in result["invalid_features"]


def test_infinite_measurement():

    visit = create_cvd_visit()

    visit["systolic_bp"] = float("inf")

    result = validate_visit(
        visit,
        "cardiovascular"
    )

    assert result["is_valid"] is False