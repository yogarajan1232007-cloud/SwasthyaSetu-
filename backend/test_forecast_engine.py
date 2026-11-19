from app.ai.forecasting.forecast_engine import run_forecast


diabetes_visits = []

for i in range(6):

    diabetes_visits.append({
        "age": 45 + i,
        "bmi": 24.0 + (i * 0.2),
        "waist_cm": 85 + i,
        "fasting_glucose": 95 + i,
        "post_meal_glucose": 130 + i,
        "hba1c": 5.2 + (i * 0.05),
    })


cvd_visits = []

for i in range(6):

    cvd_visits.append({
        "age": 45 + i,
        "gender": "Male",
        "bmi": 24.0 + (i * 0.2),
        "waist_cm": 85 + i,
        "systolic_bp": 120 + i,
        "diastolic_bp": 80 + i,
        "pulse_rate": 72 + i,
        "total_cholesterol": 180 + i,
        "hdl": 45 + i,
        "ldl": 110 + i,
        "triglycerides": 130 + i,
    })


if __name__ == "__main__":

    print("\nDIABETES FORECAST TEST")

    diabetes_result = run_forecast(
        diabetes_visits,
        "diabetes"
    )

    print(diabetes_result)


    print("\nCARDIOVASCULAR FORECAST TEST")

    cvd_result = run_forecast(
        cvd_visits,
        "cardiovascular"
    )

    print(cvd_result)