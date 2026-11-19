from pathlib import Path

import numpy as np
import pandas as pd


# --------------------------------------------------
# CONFIGURATION
# --------------------------------------------------

RANDOM_SEED = 43
NUMBER_OF_RECORDS = 10_000
NOISE_STD = 0.20

OUTPUT_PATH = (
    Path(__file__).resolve().parents[3]
    / "datasets"
    / "experiments"
    / "cvd_experiment_b.csv"
)


# --------------------------------------------------
# HELPERS
# --------------------------------------------------

def standardize(values, center, scale):
    """Standardize a feature using fixed simulation reference values."""
    return (np.asarray(values, dtype=float) - center) / scale


def assign_demo_categories(score):
    """Create relative synthetic labels, not clinical categories."""
    low_threshold = np.quantile(score, 0.30)
    high_threshold = np.quantile(score, 0.70)

    return np.select(
        [score <= low_threshold, score <= high_threshold],
        ["Low", "Medium"],
        default="High",
    )


# --------------------------------------------------
# DATASET GENERATION - EXPERIMENT B
# --------------------------------------------------

def generate_cvd_dataset():
    rng = np.random.default_rng(RANDOM_SEED)
    n = NUMBER_OF_RECORDS

    age = rng.integers(18, 86, n)
    gender = rng.choice(["Male", "Female"], n)

    # Latent factors generate correlated measurements only.
    # Labels are calculated from observable features plus noise.
    metabolic_factor = rng.normal(0, 1, n)
    lipid_factor = rng.normal(0, 1, n)
    pressure_factor = rng.normal(0, 1, n)

    age_factor = (age - 50) / 20

    bmi = np.clip(
        26.5 + 4.0 * metabolic_factor + rng.normal(0, 2.0, n),
        15,
        50,
    )

    waist_base = np.where(gender == "Male", 92, 82)
    waist_cm = np.clip(
        waist_base
        + 1.5 * (bmi - 26)
        + 7 * metabolic_factor
        + rng.normal(0, 6, n),
        55,
        145,
    )

    systolic_bp = np.clip(
        120
        + 7 * age_factor
        + 7 * pressure_factor
        + 3 * metabolic_factor
        + rng.normal(0, 9, n),
        85,
        220,
    )

    diastolic_bp = np.clip(
        78
        + 3 * pressure_factor
        + 2 * metabolic_factor
        + rng.normal(0, 7, n),
        50,
        140,
    )

    pulse_rate = np.clip(
        75 + 3 * pressure_factor + rng.normal(0, 10, n),
        45,
        130,
    ).astype(int)

    hdl = np.clip(
        52
        - 6 * metabolic_factor
        - 3 * lipid_factor
        + rng.normal(0, 8, n),
        20,
        100,
    )

    ldl = np.clip(
        110
        + 23 * lipid_factor
        + 4 * metabolic_factor
        + rng.normal(0, 18, n),
        30,
        250,
    )

    triglycerides = np.clip(
        140
        + 35 * metabolic_factor
        + 25 * lipid_factor
        + rng.normal(0, 30, n),
        40,
        500,
    )

    # Total cholesterol remains a model feature. Its contribution is
    # excluded from the synthetic target score, as in Experiment A.
    total_cholesterol = np.clip(
        ldl + hdl + (triglycerides / 5) + rng.normal(0, 8, n),
        100,
        350,
    )

    # Experiment B changes only label-score noise from 0.30 to 0.20.
    cvd_score = (
        0.20 * standardize(age, 50, 20)
        + 0.25 * standardize(systolic_bp, 120, 20)
        + 0.10 * standardize(diastolic_bp, 80, 12)
        + 0.18 * standardize(ldl, 110, 40)
        + 0.08 * standardize(triglycerides, 150, 80)
        - 0.08 * standardize(hdl, 50, 15)
        + 0.02 * standardize(bmi, 26, 6)
        + 0.01 * standardize(waist_cm, 88, 18)
        + rng.normal(0, NOISE_STD, n)
    )

    category = assign_demo_categories(cvd_score)

    return pd.DataFrame({
        "age": age,
        "gender": gender,
        "bmi": bmi.round(1),
        "waist_cm": waist_cm.round(1),
        "systolic_bp": systolic_bp.round(1),
        "diastolic_bp": diastolic_bp.round(1),
        "pulse_rate": pulse_rate,
        "total_cholesterol": total_cholesterol.round(1),
        "hdl": hdl.round(1),
        "ldl": ldl.round(1),
        "triglycerides": triglycerides.round(1),
        "synthetic_demo_category": category,
    })


# --------------------------------------------------
# DATASET VALIDATION
# --------------------------------------------------

def validate_dataset(dataset):
    assert len(dataset) == NUMBER_OF_RECORDS, "Incorrect record count"
    assert not dataset.isnull().any().any(), "Missing values detected"
    assert not dataset.duplicated().any(), "Duplicate records detected"

    assert dataset["age"].between(18, 85).all()
    assert dataset["bmi"].between(15, 50).all()
    assert dataset["waist_cm"].between(55, 145).all()
    assert dataset["systolic_bp"].between(85, 220).all()
    assert dataset["diastolic_bp"].between(50, 140).all()
    assert dataset["pulse_rate"].between(45, 130).all()
    assert dataset["total_cholesterol"].between(100, 350).all()
    assert dataset["hdl"].between(20, 100).all()
    assert dataset["ldl"].between(30, 250).all()
    assert dataset["triglycerides"].between(40, 500).all()

    assert set(dataset["gender"].unique()) == {"Male", "Female"}
    assert set(dataset["synthetic_demo_category"].unique()) == {
        "Low", "Medium", "High"
    }

    calculated_tc = (
        dataset["ldl"]
        + dataset["hdl"]
        + dataset["triglycerides"] / 5
    )
    residual = (
        dataset["total_cholesterol"] - calculated_tc
    ).abs()

    return {
        "duplicate_count": int(dataset.duplicated().sum()),
        "mean_lipid_formula_deviation": float(residual.mean()),
        "max_lipid_formula_deviation": float(residual.max()),
    }


# --------------------------------------------------
# REPORT
# --------------------------------------------------

def main():
    print("\nGenerating CVD synthetic dataset - Experiment B...")
    print("Random seed:", RANDOM_SEED)
    print("Label noise standard deviation:", NOISE_STD)

    dataset = generate_cvd_dataset()
    validation = validate_dataset(dataset)

    OUTPUT_PATH.parent.mkdir(parents=True, exist_ok=True)
    dataset.to_csv(OUTPUT_PATH, index=False)

    print("\n" + "=" * 60)
    print("SWASTHYASETHU - CVD SYNTHETIC DATASET - EXPERIMENT B")
    print("=" * 60)
    print("Records:", len(dataset))
    print("Columns:", len(dataset.columns))
    print("Missing values:", int(dataset.isnull().sum().sum()))
    print("Duplicate records:", validation["duplicate_count"])

    print("\nCategory distribution:")
    print(dataset["synthetic_demo_category"].value_counts())

    print("\nCategory percentages:")
    print(
        dataset["synthetic_demo_category"]
        .value_counts(normalize=True)
        .mul(100)
        .round(2)
    )

    print("\nFeature correlations:")
    print(dataset.select_dtypes(include="number").corr().round(2))

    print("\nLipid relationship check:")
    print(
        "Mean absolute deviation:",
        round(validation["mean_lipid_formula_deviation"], 2),
    )
    print(
        "Maximum absolute deviation:",
        round(validation["max_lipid_formula_deviation"], 2),
    )

    print("\nDataset preview:")
    print(dataset.head(10).to_string(index=False))

    print("\nEXPERIMENT B CHANGE")
    print("Label-score noise standard deviation:", NOISE_STD)
    print("Total cholesterol remains a feature, not a score contribution.")
    print(
        "Low/Medium/High are relative synthetic demonstration categories, "
        "not diagnoses or clinically validated risk levels."
    )

    print("\nVALIDATION: PASSED")
    print("Output:", OUTPUT_PATH)
    print("=" * 60)


if __name__ == "__main__":
    main()
