import os
import pandas as pd


BASE_DIR = os.path.join(
    "app",
    "ai",
    "forecasting",
    "synthetic_data",
    "generated"
)

DIABETES_FILE = os.path.join(
    BASE_DIR,
    "diabetes_longitudinal_synthetic.csv"
)

CVD_FILE = os.path.join(
    BASE_DIR,
    "cardiovascular_longitudinal_synthetic.csv"
)


def audit_dataset(df, name):

    print(f"\n========== {name} AUDIT ==========")

    print("Total records:", len(df))

    print(
        "Unique individuals:",
        df["individual_id"].nunique()
    )

    print("\nMissing values:")

    print(df.isnull().sum())

    print(
        "\nDuplicate individual visits:",
        df.duplicated(
            subset=["individual_id", "visit_number"]
        ).sum()
    )

    visits_per_individual = (
        df.groupby("individual_id")["visit_number"]
        .agg(["count", "nunique"])
    )

    print("\nVisit count distribution:")

    print(visits_per_individual["count"].value_counts())

    print(
        "\nIndividuals with exactly 12 visits:",
        (
            visits_per_individual["count"] == 12
        ).sum()
    )

    # Check visit chronology
    df = df.sort_values(
        ["individual_id", "visit_number"]
    )

    df["visit_date"] = pd.to_datetime(
        df["visit_date"]
    )

    date_differences = (
        df.groupby("individual_id")["visit_date"]
        .diff()
        .dt.days
        .dropna()
    )

    print("\nVisit interval distribution:")

    print(date_differences.value_counts().sort_index())

    print(
        "\nNon-chronological intervals:",
        (date_differences <= 0).sum()
    )

    # Numerical feature summary
    numeric_columns = df.select_dtypes(
        include="number"
    ).columns

    print("\nNumerical feature statistics:")

    print(
        df[numeric_columns].describe().round(2)
    )

    return df


def main():

    print("Starting longitudinal dataset audit...")

    diabetes_df = pd.read_csv(DIABETES_FILE)

    cardiovascular_df = pd.read_csv(CVD_FILE)

    diabetes_df = audit_dataset(
        diabetes_df,
        "DIABETES"
    )

    cardiovascular_df = audit_dataset(
        cardiovascular_df,
        "CARDIOVASCULAR"
    )

    # Cross-dataset consistency check
    print("\n========== CROSS DATASET AUDIT ==========")

    diabetes_keys = set(
        zip(
            diabetes_df["individual_id"],
            diabetes_df["visit_number"],
            diabetes_df["visit_date"]
        )
    )

    cardiovascular_keys = set(
        zip(
            cardiovascular_df["individual_id"],
            cardiovascular_df["visit_number"],
            cardiovascular_df["visit_date"]
        )
    )

    print(
        "Matching individual visits:",
        diabetes_keys == cardiovascular_keys
    )

    print(
        "Diabetes-only visits:",
        len(diabetes_keys - cardiovascular_keys)
    )

    print(
        "Cardiovascular-only visits:",
        len(cardiovascular_keys - diabetes_keys)
    )

    # Synthetic data verification
    print("\n========== SYNTHETIC DATA CHECK ==========")

    print(
        "Diabetes source:",
        diabetes_df["dataset_source"].unique()
    )

    print(
        "CVD source:",
        cardiovascular_df["dataset_source"].unique()
    )

    print(
        "All diabetes records synthetic:",
        (
            diabetes_df["is_real_patient_data"] == False
        ).all()
    )

    print(
        "All CVD records synthetic:",
        (
            cardiovascular_df["is_real_patient_data"] == False
        ).all()
    )

    print("\nDataset audit completed.")


if __name__ == "__main__":
    main()
