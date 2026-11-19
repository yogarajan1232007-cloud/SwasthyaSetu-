
import json
import random
from pathlib import Path

import joblib
import numpy as np
import torch
import torch.nn as nn

from torch.utils.data import TensorDataset, DataLoader

from sklearn.metrics import (
    mean_absolute_error,
    mean_squared_error,
)


# --------------------------------------------------
# CONFIGURATION
# --------------------------------------------------

BASE_DIR = Path(__file__).resolve().parent

DATA_DIR = BASE_DIR / "prepared"

OUTPUT_DIR = BASE_DIR / "trained_models"

OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

DATA_FILE = DATA_DIR / "cvd_sequences.npz"

INPUT_SCALER_FILE = (
    DATA_DIR / "cvd_input_scaler.joblib"
)

TARGET_SCALER_FILE = (
    DATA_DIR / "cvd_target_scaler.joblib"
)

SEQUENCE_LENGTH = 6

INPUT_SIZE = 11

OUTPUT_SIZE = 6

HIDDEN_SIZE_1 = 64

HIDDEN_SIZE_2 = 32

DROPOUT = 0.2

BATCH_SIZE = 256

LEARNING_RATE = 0.001

MAX_EPOCHS = 100

PATIENCE = 10

RANDOM_SEED = 42

DEVICE = torch.device("cpu")


INPUT_FEATURES = [
    "age",
    "gender",
    "bmi",
    "waist_cm",
    "systolic_bp",
    "diastolic_bp",
    "pulse_rate",
    "total_cholesterol",
    "hdl",
    "ldl",
    "triglycerides",
]

TARGET_FEATURES = [
    "systolic_bp",
    "diastolic_bp",
    "total_cholesterol",
    "hdl",
    "ldl",
    "triglycerides",
]


# --------------------------------------------------
# REPRODUCIBILITY
# --------------------------------------------------

def set_seed():

    random.seed(RANDOM_SEED)

    np.random.seed(RANDOM_SEED)

    torch.manual_seed(RANDOM_SEED)


# --------------------------------------------------
# CVD LSTM MODEL
# --------------------------------------------------

class CardiovascularLSTM(nn.Module):

    def __init__(self):

        super().__init__()

        self.lstm1 = nn.LSTM(
            input_size=INPUT_SIZE,
            hidden_size=HIDDEN_SIZE_1,
            batch_first=True,
        )

        self.dropout = nn.Dropout(DROPOUT)

        self.lstm2 = nn.LSTM(
            input_size=HIDDEN_SIZE_1,
            hidden_size=HIDDEN_SIZE_2,
            batch_first=True,
        )

        self.fc = nn.Linear(
            HIDDEN_SIZE_2,
            OUTPUT_SIZE,
        )

    def forward(self, x):

        output, _ = self.lstm1(x)

        output = self.dropout(output)

        output, _ = self.lstm2(output)

        last_output = output[:, -1, :]

        predictions = self.fc(last_output)

        return predictions


# --------------------------------------------------
# LOAD DATA
# --------------------------------------------------

def load_data():

    if not DATA_FILE.exists():

        raise FileNotFoundError(DATA_FILE)

    if not INPUT_SCALER_FILE.exists():

        raise FileNotFoundError(INPUT_SCALER_FILE)

    if not TARGET_SCALER_FILE.exists():

        raise FileNotFoundError(TARGET_SCALER_FILE)

    data = np.load(DATA_FILE)

    X_train = data["X_train"]

    y_train = data["y_train"]

    X_val = data["X_val"]

    y_val = data["y_val"]

    X_test = data["X_test"]

    y_test = data["y_test"]

    input_scaler = joblib.load(INPUT_SCALER_FILE)

    target_scaler = joblib.load(TARGET_SCALER_FILE)

    print("\nDATASET LOADED")

    print("Training:", X_train.shape, y_train.shape)

    print("Validation:", X_val.shape, y_val.shape)

    print("Testing:", X_test.shape, y_test.shape)

    return (
        X_train,
        y_train,
        X_val,
        y_val,
        X_test,
        y_test,
        input_scaler,
        target_scaler,
    )


# --------------------------------------------------
# DATALOADERS
# --------------------------------------------------

def create_dataloaders(
    X_train,
    y_train,
    X_val,
    y_val,
):

    train_dataset = TensorDataset(
        torch.tensor(X_train, dtype=torch.float32),
        torch.tensor(y_train, dtype=torch.float32),
    )

    val_dataset = TensorDataset(
        torch.tensor(X_val, dtype=torch.float32),
        torch.tensor(y_val, dtype=torch.float32),
    )

    generator = torch.Generator()

    generator.manual_seed(RANDOM_SEED)

    train_loader = DataLoader(
        train_dataset,
        batch_size=BATCH_SIZE,
        shuffle=True,
        generator=generator,
    )

    val_loader = DataLoader(
        val_dataset,
        batch_size=BATCH_SIZE,
        shuffle=False,
    )

    return train_loader, val_loader


# --------------------------------------------------
# TRAIN MODEL
# --------------------------------------------------

def train_model(
    model,
    train_loader,
    val_loader,
):

    criterion = nn.MSELoss()

    optimizer = torch.optim.Adam(
        model.parameters(),
        lr=LEARNING_RATE,
    )

    best_val_loss = float("inf")

    patience_counter = 0

    best_model_path = (
        OUTPUT_DIR / "cvd_lstm_best.pt"
    )

    history = []

    for epoch in range(1, MAX_EPOCHS + 1):

        # TRAINING

        model.train()

        train_losses = []

        for X_batch, y_batch in train_loader:

            X_batch = X_batch.to(DEVICE)

            y_batch = y_batch.to(DEVICE)

            optimizer.zero_grad()

            predictions = model(X_batch)

            loss = criterion(
                predictions,
                y_batch,
            )

            loss.backward()

            optimizer.step()

            train_losses.append(loss.item())

        train_loss = float(np.mean(train_losses))

        # VALIDATION

        model.eval()

        val_losses = []

        with torch.no_grad():

            for X_batch, y_batch in val_loader:

                X_batch = X_batch.to(DEVICE)

                y_batch = y_batch.to(DEVICE)

                predictions = model(X_batch)

                loss = criterion(
                    predictions,
                    y_batch,
                )

                val_losses.append(loss.item())

        val_loss = float(np.mean(val_losses))

        history.append({
            "epoch": epoch,
            "train_loss": train_loss,
            "validation_loss": val_loss,
        })

        print(
            f"Epoch [{epoch:03d}/{MAX_EPOCHS}] "
            f"Train Loss: {train_loss:.6f} "
            f"Validation Loss: {val_loss:.6f}"
        )

        if val_loss < best_val_loss:

            best_val_loss = val_loss

            patience_counter = 0

            torch.save(
                model.state_dict(),
                best_model_path,
            )

        else:

            patience_counter += 1

        if patience_counter >= PATIENCE:

            print(
                f"\nEarly stopping at epoch {epoch}"
            )

            break

    print("\nBest validation loss:", best_val_loss)

    return best_model_path, history


# --------------------------------------------------
# EVALUATION METRICS
# --------------------------------------------------

def calculate_metrics(y_true, y_pred):

    results = {}

    for index, feature in enumerate(TARGET_FEATURES):

        mae = mean_absolute_error(
            y_true[:, index],
            y_pred[:, index],
        )

        rmse = np.sqrt(
            mean_squared_error(
                y_true[:, index],
                y_pred[:, index],
            )
        )

        results[feature] = {
            "MAE": float(mae),
            "RMSE": float(rmse),
        }

    return results


# --------------------------------------------------
# BASELINE MODELS
# --------------------------------------------------

def calculate_baselines(
    X_test_scaled,
    y_test_scaled,
    input_scaler,
    target_scaler,
):

    X_raw = input_scaler.inverse_transform(
        X_test_scaled.reshape(-1, INPUT_SIZE)
    ).reshape(
        -1, SEQUENCE_LENGTH, INPUT_SIZE
    )

    y_true = target_scaler.inverse_transform(
        y_test_scaled
    )

    # Input positions:
    # systolic BP = 4
    # diastolic BP = 5
    # total cholesterol = 7
    # HDL = 8
    # LDL = 9
    # triglycerides = 10

    target_positions = [4, 5, 7, 8, 9, 10]

    # PERSISTENCE BASELINE

    persistence_predictions = (
        X_raw[:, -1, target_positions]
    )

    # LINEAR TREND BASELINE

    visit_indices = np.arange(SEQUENCE_LENGTH)

    future_index = SEQUENCE_LENGTH

    linear_predictions = []

    for sequence in X_raw:

        predictions = []

        for position in target_positions:

            slope, intercept = np.polyfit(
                visit_indices,
                sequence[:, position],
                1,
            )

            prediction = (
                slope * future_index + intercept
            )

            predictions.append(prediction)

        linear_predictions.append(predictions)

    linear_predictions = np.asarray(
        linear_predictions
    )

    print("\nBASELINE RESULTS")

    print("\nPersistence:")

    persistence_metrics = calculate_metrics(
        y_true,
        persistence_predictions,
    )

    print(json.dumps(persistence_metrics, indent=4))

    print("\nLinear Trend:")

    linear_metrics = calculate_metrics(
        y_true,
        linear_predictions,
    )

    print(json.dumps(linear_metrics, indent=4))

    return persistence_metrics, linear_metrics


# --------------------------------------------------
# MAIN
# --------------------------------------------------

def main():

    set_seed()

    print("\nSWASTHYASETHU CARDIOVASCULAR LSTM TRAINING")

    print("Device:", DEVICE)

    (
        X_train,
        y_train,
        X_val,
        y_val,
        X_test,
        y_test,
        input_scaler,
        target_scaler,
    ) = load_data()

    train_loader, val_loader = create_dataloaders(
        X_train,
        y_train,
        X_val,
        y_val,
    )

    model = CardiovascularLSTM().to(DEVICE)

    print("\nMODEL ARCHITECTURE")

    print(model)

    # TRAIN

    best_model_path, history = train_model(
        model,
        train_loader,
        val_loader,
    )

    # LOAD BEST MODEL

    state_dict = torch.load(
        best_model_path,
        map_location=DEVICE,
        weights_only=True,
    )

    model.load_state_dict(state_dict)

    model.eval()

    # TEST

    X_test_tensor = torch.tensor(
        X_test,
        dtype=torch.float32,
    ).to(DEVICE)

    with torch.no_grad():

        predictions_scaled = model(
            X_test_tensor
        ).cpu().numpy()

    y_true = target_scaler.inverse_transform(
        y_test
    )

    predictions = target_scaler.inverse_transform(
        predictions_scaled
    )

    lstm_metrics = calculate_metrics(
        y_true,
        predictions,
    )

    print("\nLSTM TEST RESULTS")

    print(json.dumps(lstm_metrics, indent=4))

    # BASELINES

    (
        persistence_metrics,
        linear_metrics,
    ) = calculate_baselines(
        X_test,
        y_test,
        input_scaler,
        target_scaler,
    )

    # SAVE RESULTS

    results = {
        "model_name": "SwasthyaSetu Cardiovascular LSTM",
        "dataset_type": "synthetic",
        "is_real_patient_data": False,
        "sequence_length": SEQUENCE_LENGTH,
        "input_features": INPUT_FEATURES,
        "target_features": TARGET_FEATURES,
        "device": str(DEVICE),
        "epochs_configured": MAX_EPOCHS,
        "early_stopping_patience": PATIENCE,
        "lstm_metrics": lstm_metrics,
        "persistence_metrics": persistence_metrics,
        "linear_trend_metrics": linear_metrics,
        "training_history": history,
        "disclaimer": (
            "Experimental cardiovascular forecasting model "
            "trained using synthetic longitudinal data. "
            "Not clinically validated."
        ),
    }

    with open(
        OUTPUT_DIR / "cvd_lstm_results.json",
        "w",
        encoding="utf-8",
    ) as file:

        json.dump(
            results,
            file,
            indent=4,
        )

    # SAVE CONFIGURATION

    config = {
        "input_size": INPUT_SIZE,
        "hidden_size_1": HIDDEN_SIZE_1,
        "hidden_size_2": HIDDEN_SIZE_2,
        "output_size": OUTPUT_SIZE,
        "dropout": DROPOUT,
        "sequence_length": SEQUENCE_LENGTH,
        "target_features": TARGET_FEATURES,
    }

    with open(
        OUTPUT_DIR / "cvd_lstm_config.json",
        "w",
        encoding="utf-8",
    ) as file:

        json.dump(
            config,
            file,
            indent=4,
        )

    print("\nTRAINING COMPLETED")

    print("Best model:", best_model_path)

    print(
        "Results:",
        OUTPUT_DIR / "cvd_lstm_results.json"
    )

    print("\nSynthetic CVD forecasting experiment completed.")


if __name__ == "__main__":
    main()
