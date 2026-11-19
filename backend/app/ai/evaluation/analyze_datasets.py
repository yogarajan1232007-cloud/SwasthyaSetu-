from pathlib import Path

import pandas as pd


BASE_DIR = Path(__file__).resolve().parents[3]
DATASET_DIR = BASE_DIR / "datasets"


FILES = {
    "DIABETES": DATASET_DIR / "diabetes_synthetic.csv",
    "CVD": DATASET_DIR / "cvd_synthetic.csv",
}


def analyze_dataset(name, file_path):

    print("\n" + "=" * 60)
    print(f"{name} DATASET ANALYSIS")
    print("=" * 60)

    if not file_path.exists():
        print("Dataset not found:", file_path)
        return

    df = pd.read_csv(file_path)

    print("\n1. Dataset Shape")
    print("Rows:", df.shape[0])
    print("Columns:", df.shape[1])

    print("\n2. Missing Values")
    print(df.isnull().sum())

    print("\n3. Duplicate Records")
    print(df.duplicated().sum())

    print("\n4. Category Distribution")

    target = "synthetic_demo_category"

    counts = df[target].value_counts()
    percentages = df[target].value_counts(normalize=True) * 100

    distribution = pd.DataFrame({
        "Count": counts,
        "Percentage": percentages.round(2)
    })

    print(distribution)

    print("\n5. Numerical Feature Statistics")

    print(
        df.select_dtypes(include="number").describe().round(2)
    )

    print("\n6. Feature Correlations")

    correlations = (
        df.select_dtypes(include="number")
        .corr()
        .round(2)
    )

    print(correlations)

    print("\n7. Dataset Validation")

    print("Missing values:", df.isnull().sum().sum())
    print("Duplicate rows:", df.duplicated().sum())

    print("\nAnalysis completed.")


def main():

    for name, path in FILES.items():
        analyze_dataset(name, path)


if __name__ == "__main__":
    main()