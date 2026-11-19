import pytest
import torch

from app.ai.forecasting.model_loader import (
    load_forecasting_model
)


@pytest.mark.parametrize(
    "model_type",
    ["diabetes", "cardiovascular"]
)
def test_model(model_type):

    print(f"\nTesting {model_type} model...")

    artifacts = load_forecasting_model(model_type)

    model = artifacts["model"]
    input_scaler = artifacts["input_scaler"]
    target_scaler = artifacts["target_scaler"]

    input_size = input_scaler.n_features_in_
    output_size = target_scaler.n_features_in_

    test_input = torch.zeros(
        (1, 6, input_size),
        dtype=torch.float32
    )

    model.eval()

    with torch.no_grad():
        prediction = model(test_input)

    print("Input shape:", tuple(test_input.shape))
    print("Output shape:", tuple(prediction.shape))
    print("Input scaler features:", input_size)
    print("Target scaler features:", output_size)

    assert prediction.shape == (1, output_size)

    assert torch.isfinite(prediction).all()

    print("PASSED")