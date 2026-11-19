import pytest

from app.clinical.rules.diabetes_rules import (
    evaluate_diabetes_screening
)


def test_normal_measurements():
    result = evaluate_diabetes_screening(
        age=35,
        fasting_plasma_glucose=95,
        post_meal_plasma_glucose=125,
        hba1c=5.2
    )

    assert result["status"] == "no_flagged_result"
    assert result["alert_count"] == 0


def test_intermediate_measurements():
    result = evaluate_diabetes_screening(
        age=35,
        fasting_plasma_glucose=115,
        post_meal_plasma_glucose=150,
        hba1c=6.0
    )

    assert result["status"] == "review_required"
    assert result["alert_count"] == 3


def test_higher_measurements():
    result = evaluate_diabetes_screening(
        age=45,
        fasting_plasma_glucose=130,
        post_meal_plasma_glucose=220,
        hba1c=7.0
    )

    assert result["status"] == "review_required"
    assert result["alert_count"] == 3

    rule_names = [
        alert["rule"] for alert in result["alerts"]
    ]

    assert "FASTING_GLUCOSE_ASSESSMENT" in rule_names
    assert "POST_MEAL_GLUCOSE_ASSESSMENT" in rule_names
    assert "HBA1C_ASSESSMENT" in rule_names


def test_age_below_30():
    result = evaluate_diabetes_screening(
        age=20,
        fasting_plasma_glucose=130
    )

    assert result["status"] == "outside_population_screening_scope"
    assert result["alerts"] == []


def test_missing_age():
    result = evaluate_diabetes_screening(
        age=None,
        fasting_plasma_glucose=130
    )

    assert result["status"] == "not_evaluated"


def test_missing_measurements():
    result = evaluate_diabetes_screening(age=35)

    assert result["status"] == "no_flagged_result"
    assert result["alert_count"] == 0


@pytest.mark.parametrize(
    "value",
    [-10, 0, float("nan"), float("inf"), float("-inf")]
)
def test_invalid_fasting_glucose(value):
    with pytest.raises(ValueError):
        evaluate_diabetes_screening(
            age=35,
            fasting_plasma_glucose=value
        )


def test_fasting_glucose_boundary():
    result = evaluate_diabetes_screening(
        age=35,
        fasting_plasma_glucose=126
    )

    assert result["alerts"][0]["rule"] == (
        "FASTING_GLUCOSE_ASSESSMENT"
    )


def test_hba1c_boundary():
    result = evaluate_diabetes_screening(
        age=35,
        hba1c=6.5
    )

    assert result["alerts"][0]["rule"] == "HBA1C_ASSESSMENT"


def test_result_is_not_diagnosis():
    result = evaluate_diabetes_screening(
        age=45,
        fasting_plasma_glucose=140
    )

    assert result["is_diagnosis"] is False