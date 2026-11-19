import json
import logging
from functools import lru_cache
from pathlib import Path

import joblib
import torch
import torch.nn as nn

from fastapi import HTTPException


logger = logging.getLogger(__name__)

# --------------------------------------------------
# CONFIGURATION
# --------------------------------------------------

PROJECT_ROOT = Path(__file__).resolve().parents[3]

ARTIFACT_DIR = (
    PROJECT_ROOT
    / "app"
    / "ai"
    / "forecasting"
    / "synthetic_data"
)

MODEL_DIR = ARTIFACT_DIR / "trained_models"
SCALER_DIR = ARTIFACT_DIR / "prepared"

DEVICE = torch.device("cpu")

SEQUENCE_LENGTH = 6
HIDDEN_SIZE_1 = 64
HIDDEN_SIZE_2 = 32
DROPOUT = 0.2


# --------------------------------------------------
# DIABETES LSTM
# --------------------------------------------------

class DiabetesLSTM(nn.Module):

    def __init__(self):

        super().__init__()

        self.lstm1 = nn.LSTM(
            input_size=6,
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
            3,
        )

    def forward(self, x):

        output, _ = self.lstm1(x)

        output = self.dropout(output)

        output, _ = self.lstm2(output)

        last_output = output[:, -1, :]

        return self.fc(last_output)


# --------------------------------------------------
# CARDIOVASCULAR LSTM
# --------------------------------------------------

class CardiovascularLSTM(nn.Module):

    def __init__(self):

        super().__init__()

        self.lstm1 = nn.LSTM(
            input_size=11,
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
            6,
        )

    def forward(self, x):

        output, _ = self.lstm1(x)

        output = self.dropout(output)

        output, _ = self.lstm2(output)

        last_output = output[:, -1, :]

        return self.fc(last_output)


# --------------------------------------------------
# MODEL CONFIGURATIONS
# --------------------------------------------------

MODEL_CONFIGS = {

    "diabetes": {
        "model_class": DiabetesLSTM,
        "checkpoint": MODEL_DIR / "diabetes_lstm_best.pt",
        "config": MODEL_DIR / "diabetes_lstm_config.json",
        "input_scaler": SCALER_DIR / "diabetes_input_scaler.joblib",
        "target_scaler": SCALER_DIR / "diabetes_target_scaler.joblib",
        "input_size": 6,
        "output_size": 3,
    },

    "cardiovascular": {
        "model_class": CardiovascularLSTM,
        "checkpoint": MODEL_DIR / "cvd_lstm_best.pt",
        "config": MODEL_DIR / "cvd_lstm_config.json",
        "input_scaler": SCALER_DIR / "cvd_input_scaler.joblib",
        "target_scaler": SCALER_DIR / "cvd_target_scaler.joblib",
        "input_size": 11,
        "output_size": 6,
    },

}


# --------------------------------------------------
# LOAD FORECASTING MODEL
# --------------------------------------------------

@lru_cache(maxsize=2)
def load_forecasting_model(model_type: str):

    if model_type not in MODEL_CONFIGS:

        raise HTTPException(
            status_code=400,
            detail="Unsupported forecasting model type."
        )

    config = MODEL_CONFIGS[model_type]

    required_files = [
        config["checkpoint"],
        config["config"],
        config["input_scaler"],
        config["target_scaler"],
    ]

    for file_path in required_files:

        if not file_path.is_file():

            logger.error(
                "Forecasting artifact missing: %s",
                file_path
            )

            raise HTTPException(
                status_code=500,
                detail="Required forecasting model artifact is missing."
            )

    try:

        # Load model configuration.
        with open(
            config["config"],
            "r",
            encoding="utf-8"
        ) as file:

            model_config = json.load(file)

        # Validate architecture configuration.
        if (
            model_config.get("input_size") != config["input_size"]
            or model_config.get("output_size") != config["output_size"]
            or model_config.get("hidden_size_1") != HIDDEN_SIZE_1
            or model_config.get("hidden_size_2") != HIDDEN_SIZE_2
            or model_config.get("sequence_length") != SEQUENCE_LENGTH
        ):

            raise ValueError(
                "Forecasting model configuration mismatch."
            )

        # Initialize architecture.
        model = config["model_class"]().to(DEVICE)

        # Load trusted local checkpoint.
        state_dict = torch.load(
            config["checkpoint"],
            map_location=DEVICE,
            weights_only=True,
        )

        model.load_state_dict(state_dict)

        model.eval()

        # Load scalers.
        input_scaler = joblib.load(
            config["input_scaler"]
        )

        target_scaler = joblib.load(
            config["target_scaler"]
        )

        # Validate scaler dimensions.
        if (
            input_scaler.n_features_in_ != config["input_size"]
            or target_scaler.n_features_in_ != config["output_size"]
        ):

            raise ValueError(
                "Forecasting scaler dimensions do not match model."
            )

        logger.info(
            "Loaded %s forecasting model successfully.",
            model_type
        )

        return {
            "model": model,
            "input_scaler": input_scaler,
            "target_scaler": target_scaler,
            "config": model_config,
            "device": DEVICE,
        }

    except HTTPException:
        raise

    except Exception:

        logger.exception(
            "Failed to load %s forecasting model.",
            model_type
        )

        raise HTTPException(
            status_code=500,
            detail="Unable to load forecasting model."
        )