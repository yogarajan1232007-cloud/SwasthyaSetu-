from pathlib import Path

import numpy as np
import pandas as pd


# --------------------------------------------------
# CONFIGURATION
# --------------------------------------------------

RANDOM_SEED = 42
NUMBER_OF_RECORDS = 10_000

OUTPUT_PATH = (
    Path(__file__).resolve().parents[3]
    / "datasets"
    / "diabetes_synthetic.csv"
)


# --------------------------------------------------
# HELPERS
# --------------------------------------------------

def standardize(values, center, scale):
    """Standardize a feature using fixed simulation reference values."""
    return (np.asarray(values, dtype=float) - center) / scale


def assign_demo_categories(score):
    """
    Assign relative synthetic categories.
    These are not clinical thresholds or diagnoses.
    """
    low_threshold = np.quantile(score, 0.30)
    high_threshold = np.quantile(score, 0.70)

    return np.select(
        [score <= low_threshold, score <= high_threshold],
        ["Low", "Medium"],
        default="High",
    )


# --------------------------------------------------
# DATASET GENERATION
# --------------------------------------------------

def generate_diabetes_dataset():
    rng = np.random.default_rng(RANDOM_SEED)
    n = NUMBER_OF_RECORDS

    # Demographic information
    age = rng.integers(18, 86, n)

    # Shared simulation factors create correlated measurements.
    # These latent factors are used only to generate measurements;
    # they are NOT used directly to create the target label.
    metabolic_factor = rng.normal(0, 1, n)
    glucose_factor = rng.normal(0, 1, n)

    age_factor = (age - 45) / 20

    bmi = np.clip(
        26 + 4 * metabolic_factor + rng.normal(0, 2, n),
        15,
        50,
    )

    waist_cm = np.clip(
        85
        + 1.5 * (bmi - 25)
        + 7 * metabolic_factor
        + rng.normal(0, 6, n),
        55,
        145,
    )

    fasting_glucose = np.clip(
        95
        + 10 * age_factor
        + 8 * metabolic_factor
        + 17 * glucose_factor
        + rng.normal(0, 10, n),
        65,
        250,
    )

    post_meal_glucose = np.clip(
        fasting_glucose
        + 40
        + 12 * glucose_factor
        + rng.normal(0, 20, n),
        80,
        350,
    )

    hba1c = np.clip(
        5.2
        + 0.025 * (fasting_glucose - 100)
        + 0.20 * glucose_factor
        + rng.normal(0, 0.35, n),
        4.0,
        14.0,
    )

    # --------------------------------------------------
    # OBSERVABLE-FEATURE DEMONSTRATION SCORE
    # --------------------------------------------------
    # The label is now calculated from columns available to the ML model.
    # Fixed centers/scales are simulation choices, NOT diagnostic cutoffs.
    diabetes_score = (
        0.28 * standardize(fasting_glucose, 100, 25)
        + 0.24 * standardize(hba1c, 5.5, 1.2)
        + 0.16 * standardize(post_meal_glucose, 140, 55)
        + 0.12 * standardize(age, 45, 20)
        + 0.12 * standardize(bmi, 25, 6)
        + 0.08 * standardize(waist_cm, 90, 15)
        + rng.normal(0, 0.25, n)
    )

    category = assign_demo_categories(diabetes_score)

    dataset = pd.DataFrame({
        "age": age,
        "bmi": bmi.round(1),
        "waist_cm": waist_cm.round(1),
        "fasting_glucose": fasting_glucose.round(1),
        "post_meal_glucose": post_meal_glucose.round(1),
        "hba1c": hba1c.round(1),
        "synthetic_demo_category": category,
    })

    return dataset


# --------------------------------------------------
# DATASET VALIDATION
# --------------------------------------------------

def validate_dataset(dataset):
    assert len(dataset) == NUMBER_OF_RECORDS, "Incorrect record count"
    assert not dataset.isnull().any().any(), "Missing values detected"

    assert dataset["age"].between(18, 85).all()
    assert dataset["bmi"].between(15, 50).all()
    assert dataset["waist_cm"].between(55, 145).all()
    assert dataset["fasting_glucose"].between(65, 250).all()
    assert dataset["post_meal_glucose"].between(80, 350).all()
    assert dataset["hba1c"].between(4, 14).all()

    expected = {"Low", "Medium", "High"}
    assert set(dataset["synthetic_demo_category"].unique()) == expected

    return int(dataset.duplicated().sum())


# --------------------------------------------------
# DATASET REPORT
# --------------------------------------------------

def display_dataset_report(dataset, duplicate_count):
    print("\n" + "=" * 60)
    print("SWASTHYASETHU - REVISED DIABETES SYNTHETIC DATASET")
    print("=" * 60)

    print("\nGENERAL INFORMATION")
    print("Total records:", len(dataset))
    print("Total columns:", len(dataset.columns))
    print("Duplicate records:", duplicate_count)
    print("Missing values:", int(dataset.isnull().sum().sum()))

    print("\nCATEGORY DISTRIBUTION")
    print(dataset["synthetic_demo_category"].value_counts())

    print("\nCATEGORY PERCENTAGES")
    print(
        dataset["synthetic_demo_category"]
        .value_counts(normalize=True)
        .mul(100)
        .round(2)
    )

    print("\nFEATURE STATISTICS")
    print(dataset.select_dtypes(include="number").describe().round(2))

    print("\nFEATURE CORRELATIONS")
    print(dataset.select_dtypes(include="number").corr().round(2))

    print("\nDATASET PREVIEW")
    print(dataset.head(10).to_string(index=False))

    print("\nLABEL NOTE")
    print(
        "Low/Medium/High are relative synthetic demonstration categories. "
        "They are NOT diagnoses or clinically validated risk levels."
    )

    print("\nVALIDATION STATUS: PASSED")
    print("=" * 60)


# --------------------------------------------------
# MAIN
# --------------------------------------------------

def main():
    print("\nGenerating revised diabetes synthetic dataset...")

    dataset = generate_diabetes_dataset()
    duplicate_count = validate_dataset(dataset)

    OUTPUT_PATH.parent.mkdir(parents=True, exist_ok=True)
    dataset.to_csv(OUTPUT_PATH, index=False)

    display_dataset_report(dataset, duplicate_count)

    print("\nDATASET SAVED SUCCESSFULLY")
    print("Location:", OUTPUT_PATH)


if __name__ == "__main__":
    main()
