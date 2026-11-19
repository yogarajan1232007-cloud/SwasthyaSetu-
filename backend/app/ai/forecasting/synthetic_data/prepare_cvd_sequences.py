import json
from pathlib import Path

import joblib
import numpy as np
import pandas as pd

from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler


# --------------------------------------------------
# CONFIGURATION
# --------------------------------------------------

BASE_DIR = Path(__file__).resolve().parent

INPUT_FILE = (
    BASE_DIR
    / "generated"
    / "cardiovascular_longitudinal_synthetic.csv"
)

OUTPUT_DIR = BASE_DIR / "prepared"
OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

RANDOM_STATE = 42

SEQUENCE_LENGTH = 6
EXPECTED_VISITS = 12

GENDER_MAPPING = {
    "Female": 0,
    "Male": 1,
}

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
# LOAD DATASET
# --------------------------------------------------

def load_dataset():

    if not INPUT_FILE.exists():
        raise FileNotFoundError(
            f"Dataset not found: {INPUT_FILE}"
        )

    df = pd.read_csv(INPUT_FILE)

    required_columns = [
        "individual_id",
        "visit_number",
        "visit_date",
        *INPUT_FEATURES,
    ]

    missing = [
        col for col in required_columns
        if col not in df.columns
    ]

    if missing:
        raise ValueError(
            f"Missing columns: {missing}"
        )

    # Validate gender values before encoding.
    unknown_gender = (
        set(df["gender"].dropna().unique())
        - set(GENDER_MAPPING.keys())
    )

    if unknown_gender:
        raise ValueError(
            f"Unknown gender values: {unknown_gender}"
        )

    df["gender"] = df["gender"].map(
        GENDER_MAPPING
    )

    df["visit_date"] = pd.to_datetime(
        df["visit_date"],
        errors="raise"
    )

    df = df.sort_values(
        ["individual_id", "visit_date", "visit_number"]
    ).reset_index(drop=True)

    if df[required_columns].isnull().any().any():
        raise ValueError(
            "Dataset contains missing required values."
        )

    if df.duplicated(
        subset=["individual_id", "visit_number"]
    ).any():
        raise ValueError(
            "Duplicate individual/visit records found."
        )

    # Ensure every individual has 12 visits.
    visit_counts = df.groupby(
        "individual_id"
    ).size()

    if not (visit_counts == EXPECTED_VISITS).all():
        raise ValueError(
            "Some individuals do not have exactly 12 visits."
        )

    # Verify synthetic dataset markers.
    if not (df["dataset_source"] == "synthetic").all():
        raise ValueError(
            "Dataset contains non-synthetic source records."
        )

    if df["is_real_patient_data"].astype(bool).any():
        raise ValueError(
            "Real patient records detected. "
            "Expected synthetic data only."
        )

    print("\nCVD dataset validation passed.")

    return df


# --------------------------------------------------
# SPLIT INDIVIDUALS
# --------------------------------------------------

def split_individuals(df):

    individual_ids = np.asarray(
        df["individual_id"].unique().tolist()
    )

    train_ids, remaining_ids = train_test_split(
        individual_ids,
        test_size=0.30,
        random_state=RANDOM_STATE,
    )

    val_ids, test_ids = train_test_split(
        remaining_ids,
        test_size=0.50,
        random_state=RANDOM_STATE,
    )

    # Verify no individual overlap.
    assert len(set(train_ids) & set(val_ids)) == 0
    assert len(set(train_ids) & set(test_ids)) == 0
    assert len(set(val_ids) & set(test_ids)) == 0

    print("\nINDIVIDUAL SPLIT")
    print("-------------------------")
    print("Training:", len(train_ids))
    print("Validation:", len(val_ids))
    print("Testing:", len(test_ids))

    return train_ids, val_ids, test_ids


# --------------------------------------------------
# GENERATE SEQUENCES
# --------------------------------------------------

def generate_sequences(df, individual_ids):

    X = []
    y = []

    selected_df = df[
        df["individual_id"].isin(individual_ids)
    ]

    for individual_id, group in selected_df.groupby(
        "individual_id"
    ):

        group = group.sort_values(
            ["visit_date", "visit_number"]
        )

        values = group[
            INPUT_FEATURES
        ].to_numpy(dtype=np.float32)

        targets = group[
            TARGET_FEATURES
        ].to_numpy(dtype=np.float32)

        if len(group) != EXPECTED_VISITS:
            raise ValueError(
                f"Individual {individual_id} "
                "does not have exactly 12 visits."
            )

        for start in range(
            len(group) - SEQUENCE_LENGTH
        ):

            end = start + SEQUENCE_LENGTH

            input_sequence = values[start:end]

            next_visit_target = targets[end]

            X.append(input_sequence)
            y.append(next_visit_target)

    if not X:
        raise ValueError(
            "No CVD sequences generated."
        )

    return (
        np.asarray(X, dtype=np.float32),
        np.asarray(y, dtype=np.float32),
    )


# --------------------------------------------------
# SCALE INPUT SEQUENCES
# --------------------------------------------------

def scale_input_sequences(X, scaler):

    original_shape = X.shape

    X_reshaped = X.reshape(
        -1,
        len(INPUT_FEATURES)
    )

    X_scaled = scaler.transform(X_reshaped)

    return X_scaled.reshape(
        original_shape
    ).astype(np.float32)


# --------------------------------------------------
# MAIN PREPARATION PIPELINE
# --------------------------------------------------

def prepare_data():

    print("\nLoading Cardiovascular dataset...")

    df = load_dataset()

    total_individuals = df[
        "individual_id"
    ].nunique()

    print("Total records:", len(df))
    print("Total individuals:", total_individuals)

    print("\nGender encoding:")
    print("Female = 0")
    print("Male = 1")

    train_ids, val_ids, test_ids = split_individuals(df)

    # --------------------------------------------------
    # FIT INPUT SCALER ON TRAINING INDIVIDUALS ONLY
    # --------------------------------------------------

    train_raw = df[
        df["individual_id"].isin(train_ids)
    ][INPUT_FEATURES].to_numpy(dtype=np.float32)

    input_scaler = StandardScaler()

    input_scaler.fit(train_raw)

    # --------------------------------------------------
    # GENERATE SEQUENCES
    # --------------------------------------------------

    print("\nGenerating training sequences...")

    X_train, y_train = generate_sequences(
        df, train_ids
    )

    print("Generating validation sequences...")

    X_val, y_val = generate_sequences(
        df, val_ids
    )

    print("Generating testing sequences...")

    X_test, y_test = generate_sequences(
        df, test_ids
    )

    # --------------------------------------------------
    # FIT TARGET SCALER ON TRAINING TARGETS ONLY
    # --------------------------------------------------

    target_scaler = StandardScaler()

    target_scaler.fit(y_train)

    # --------------------------------------------------
    # SCALE INPUT DATA
    # --------------------------------------------------

    X_train = scale_input_sequences(
        X_train, input_scaler
    )

    X_val = scale_input_sequences(
        X_val, input_scaler
    )

    X_test = scale_input_sequences(
        X_test, input_scaler
    )

    # --------------------------------------------------
    # SCALE TARGET DATA
    # --------------------------------------------------

    y_train = target_scaler.transform(
        y_train
    ).astype(np.float32)

    y_val = target_scaler.transform(
        y_val
    ).astype(np.float32)

    y_test = target_scaler.transform(
        y_test
    ).astype(np.float32)

    # --------------------------------------------------
    # VALIDATE SHAPES
    # --------------------------------------------------

    expected_train = len(train_ids) * 6
    expected_val = len(val_ids) * 6
    expected_test = len(test_ids) * 6

    assert X_train.shape == (
        expected_train,
        SEQUENCE_LENGTH,
        len(INPUT_FEATURES)
    )

    assert X_val.shape == (
        expected_val,
        SEQUENCE_LENGTH,
        len(INPUT_FEATURES)
    )

    assert X_test.shape == (
        expected_test,
        SEQUENCE_LENGTH,
        len(INPUT_FEATURES)
    )

    assert y_train.shape == (
        expected_train,
        len(TARGET_FEATURES)
    )

    assert y_val.shape == (
        expected_val,
        len(TARGET_FEATURES)
    )

    assert y_test.shape == (
        expected_test,
        len(TARGET_FEATURES)
    )

    # --------------------------------------------------
    # SAVE PREPARED DATA
    # --------------------------------------------------

    np.savez_compressed(
        OUTPUT_DIR / "cvd_sequences.npz",
        X_train=X_train,
        y_train=y_train,
        X_val=X_val,
        y_val=y_val,
        X_test=X_test,
        y_test=y_test,
    )

    # --------------------------------------------------
    # SAVE SCALERS
    # --------------------------------------------------

    joblib.dump(
        input_scaler,
        OUTPUT_DIR / "cvd_input_scaler.joblib"
    )

    joblib.dump(
        target_scaler,
        OUTPUT_DIR / "cvd_target_scaler.joblib"
    )

    # --------------------------------------------------
    # SAVE METADATA
    # --------------------------------------------------

    metadata = {
        "model_name": "SwasthyaSetu Cardiovascular LSTM",
        "dataset_type": "synthetic",
        "is_real_patient_data": False,
        "total_records": len(df),
        "total_individuals": int(total_individuals),
        "sequence_length": SEQUENCE_LENGTH,
        "expected_visits_per_individual": EXPECTED_VISITS,
        "gender_mapping": GENDER_MAPPING,
        "input_features": INPUT_FEATURES,
        "target_features": TARGET_FEATURES,
        "train_individuals": len(train_ids),
        "validation_individuals": len(val_ids),
        "test_individuals": len(test_ids),
        "train_sequences": len(X_train),
        "validation_sequences": len(X_val),
        "test_sequences": len(X_test),
        "random_state": RANDOM_STATE,
        "disclaimer": (
            "Experimental synthetic cardiovascular "
            "forecasting data. Not clinically validated."
        ),
    }

    with open(
        OUTPUT_DIR / "cvd_metadata.json",
        "w",
        encoding="utf-8"
    ) as file:

        json.dump(
            metadata,
            file,
            indent=4
        )

    # --------------------------------------------------
    # RESULTS
    # --------------------------------------------------

    print("\n" + "=" * 50)
    print("CVD SEQUENCE PREPARATION RESULTS")
    print("=" * 50)

    print("\nTraining:")
    print("X:", X_train.shape)
    print("y:", y_train.shape)

    print("\nValidation:")
    print("X:", X_val.shape)
    print("y:", y_val.shape)

    print("\nTesting:")
    print("X:", X_test.shape)
    print("y:", y_test.shape)

    print("\nSaved files:")
    print(OUTPUT_DIR)

    print("\nAll validations passed!")
    print("CVD sequence preparation completed.")


if __name__ == "__main__":
    prepare_data()