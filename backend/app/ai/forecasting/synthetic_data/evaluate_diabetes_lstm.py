import json
from pathlib import Path

import joblib
import numpy as np
import pandas as pd
import torch
import matplotlib.pyplot as plt

from sklearn.metrics import (
    mean_absolute_error,
    mean_squared_error,
    r2_score,
)

from app.ai.forecasting.synthetic_data.train_diabetes_lstm import (
    DiabetesLSTM,
)


# --------------------------------------------------
# CONFIGURATION
# --------------------------------------------------

BASE_DIR = Path(__file__).resolve().parent

DATA_DIR = BASE_DIR / "prepared"

MODEL_DIR = BASE_DIR / "trained_models"

OUTPUT_DIR = BASE_DIR / "evaluation"

OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

DATA_FILE = DATA_DIR / "diabetes_sequences.npz"

MODEL_FILE = MODEL_DIR / "diabetes_lstm_best.pt"

TARGET_SCALER_FILE = (
    DATA_DIR / "diabetes_target_scaler.joblib"
)

TARGET_FEATURES = [
    "fasting_glucose",
    "post_meal_glucose",
    "hba1c",
]

DEVICE = torch.device("cpu")


# --------------------------------------------------
# LOAD TEST DATA
# --------------------------------------------------

def load_test_data():

    if not DATA_FILE.exists():
        raise FileNotFoundError(DATA_FILE)

    if not MODEL_FILE.exists():
        raise FileNotFoundError(MODEL_FILE)

    if not TARGET_SCALER_FILE.exists():
        raise FileNotFoundError(TARGET_SCALER_FILE)

    data = np.load(DATA_FILE)

    X_test = data["X_test"]

    y_test = data["y_test"]

    target_scaler = joblib.load(
        TARGET_SCALER_FILE
    )

    return X_test, y_test, target_scaler


# --------------------------------------------------
# LOAD TRAINED MODEL
# --------------------------------------------------

def load_model():

    model = DiabetesLSTM().to(DEVICE)

    state_dict = torch.load(
        MODEL_FILE,
        map_location=DEVICE,
        weights_only=True,
    )

    model.load_state_dict(state_dict)

    model.eval()

    return model


# --------------------------------------------------
# GENERATE PREDICTIONS
# --------------------------------------------------

def generate_predictions(model, X_test):

    X_tensor = torch.tensor(
        X_test,
        dtype=torch.float32,
    ).to(DEVICE)

    with torch.no_grad():

        predictions = model(
            X_tensor
        ).cpu().numpy()

    return predictions


# --------------------------------------------------
# CALCULATE METRICS
# --------------------------------------------------

def calculate_metrics(y_true, y_pred):

    results = {}

    for index, feature in enumerate(TARGET_FEATURES):

        actual = y_true[:, index]

        predicted = y_pred[:, index]

        results[feature] = {
            "MAE": float(
                mean_absolute_error(actual, predicted)
            ),
            "RMSE": float(
                np.sqrt(
                    mean_squared_error(actual, predicted)
                )
            ),
            "R2": float(
                r2_score(actual, predicted)
            ),
            "actual_mean": float(np.mean(actual)),
            "predicted_mean": float(np.mean(predicted)),
            "actual_min": float(np.min(actual)),
            "actual_max": float(np.max(actual)),
            "predicted_min": float(np.min(predicted)),
            "predicted_max": float(np.max(predicted)),
        }

    return results


# --------------------------------------------------
# SAVE PREDICTIONS
# --------------------------------------------------

def save_predictions(y_true, y_pred):

    data = {}

    for index, feature in enumerate(TARGET_FEATURES):

        data[f"actual_{feature}"] = y_true[:, index]

        data[f"predicted_{feature}"] = y_pred[:, index]

        data[f"error_{feature}"] = (
            y_true[:, index] - y_pred[:, index]
        )

    df = pd.DataFrame(data)

    output_file = (
        OUTPUT_DIR / "diabetes_test_predictions.csv"
    )

    df.to_csv(output_file, index=False)

    print("\nPredictions saved:", output_file)


# --------------------------------------------------
# ACTUAL VS PREDICTED GRAPHS
# --------------------------------------------------

def plot_actual_vs_predicted(y_true, y_pred):

    for index, feature in enumerate(TARGET_FEATURES):

        plt.figure(figsize=(8, 6))

        plt.scatter(
            y_true[:, index],
            y_pred[:, index],
            alpha=0.35,
        )

        min_value = min(
            y_true[:, index].min(),
            y_pred[:, index].min(),
        )

        max_value = max(
            y_true[:, index].max(),
            y_pred[:, index].max(),
        )

        plt.plot(
            [min_value, max_value],
            [min_value, max_value],
            linestyle="--",
        )

        plt.xlabel("Actual Values")

        plt.ylabel("Predicted Values")

        plt.title(
            f"Actual vs Predicted: {feature}"
        )

        plt.grid(True)

        plt.tight_layout()

        plt.savefig(
            OUTPUT_DIR
            / f"{feature}_actual_vs_predicted.png"
        )

        plt.close()


# --------------------------------------------------
# RESIDUAL ANALYSIS
# --------------------------------------------------

def plot_residuals(y_true, y_pred):

    for index, feature in enumerate(TARGET_FEATURES):

        residuals = (
            y_true[:, index] - y_pred[:, index]
        )

        plt.figure(figsize=(8, 6))

        plt.hist(residuals, bins=40)

        plt.axvline(0, linestyle="--")

        plt.xlabel("Residual Error")

        plt.ylabel("Frequency")

        plt.title(
            f"Residual Distribution: {feature}"
        )

        plt.grid(True)

        plt.tight_layout()

        plt.savefig(
            OUTPUT_DIR
            / f"{feature}_residual_distribution.png"
        )

        plt.close()


# --------------------------------------------------
# PREDICTION VALIDATION
# --------------------------------------------------

def check_predictions(y_pred):

    checks = {}

    for index, feature in enumerate(TARGET_FEATURES):

        values = y_pred[:, index]

        checks[feature] = {
            "all_finite": bool(
                np.isfinite(values).all()
            ),
            "negative_predictions": int(
                np.sum(values < 0)
            ),
            "minimum_prediction": float(values.min()),
            "maximum_prediction": float(values.max()),
        }

    return checks


# --------------------------------------------------
# MAIN
# --------------------------------------------------

def main():

    print("\nSWASTHYASETHU DIABETES LSTM EVALUATION")

    print("=" * 50)

    # Load test dataset.
    X_test, y_test_scaled, target_scaler = (
        load_test_data()
    )

    print("Test samples:", len(X_test))

    # Load trained model.
    model = load_model()

    # Generate predictions.
    predictions_scaled = generate_predictions(
        model,
        X_test,
    )

    # Convert values back to original units.
    y_true = target_scaler.inverse_transform(
        y_test_scaled
    )

    y_pred = target_scaler.inverse_transform(
        predictions_scaled
    )

    # Metrics.
    metrics = calculate_metrics(
        y_true,
        y_pred,
    )

    print("\nDETAILED TEST METRICS")

    print(json.dumps(metrics, indent=4))

    # Validate predictions.
    checks = check_predictions(y_pred)

    print("\nPREDICTION VALIDATION")

    print(json.dumps(checks, indent=4))

    # Save predictions.
    save_predictions(y_true, y_pred)

    # Generate graphs.
    plot_actual_vs_predicted(
        y_true,
        y_pred,
    )

    plot_residuals(
        y_true,
        y_pred,
    )

    # Save evaluation report.
    report = {
        "model_name": "SwasthyaSetu Diabetes LSTM",
        "dataset_type": "synthetic",
        "is_real_patient_data": False,
        "test_samples": len(X_test),
        "metrics": metrics,
        "prediction_checks": checks,
        "disclaimer": (
            "Experimental forecasting model evaluated "
            "using synthetic test data. "
            "Not clinically validated."
        ),
    }

    report_file = (
        OUTPUT_DIR / "diabetes_evaluation_report.json"
    )

    with open(
        report_file,
        "w",
        encoding="utf-8",
    ) as file:

        json.dump(report, file, indent=4)

    print("\nEVALUATION COMPLETED")

    print("Evaluation folder:", OUTPUT_DIR)

    print("Report:", report_file)


if __name__ == "__main__":
    main()