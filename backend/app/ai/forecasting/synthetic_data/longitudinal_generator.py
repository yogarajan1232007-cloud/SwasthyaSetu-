import os

import numpy as np
import pandas as pd


# ==========================================
# CONFIGURATION
# ==========================================

RANDOM_SEED = 42

NUM_INDIVIDUALS = 10000

VISITS_PER_INDIVIDUAL = 12

VISIT_INTERVAL_DAYS = 90

OUTPUT_DIR = os.path.join(
    "app",
    "ai",
    "forecasting",
    "synthetic_data",
    "generated"
)


# ==========================================
# DATA GENERATOR
# ==========================================

def generate_longitudinal_dataset():

    rng = np.random.default_rng(RANDOM_SEED)

    diabetes_records = []

    cardiovascular_records = []

    print("Starting synthetic longitudinal dataset generation...")

    for individual_number in range(
        NUM_INDIVIDUALS
    ):

        individual_id = (
            f"SYNTH-{individual_number + 1:06d}"
        )

        # ----------------------------------
        # Individual baseline characteristics
        # ----------------------------------

        gender = rng.choice(
            ["Male", "Female"]
        )

        base_age = rng.integers(20, 76)

        base_bmi = np.clip(
            rng.normal(25, 4),
            17,
            42
        )

        base_waist = np.clip(
            rng.normal(
                88 if gender == "Male" else 82,
                11
            ),
            60,
            140
        )

        # Latent synthetic trajectory factors.
        # These are simulation parameters, not
        # clinical risk classifications.

        diabetes_trajectory = rng.normal(0, 1)

        cardiovascular_trajectory = rng.normal(0, 1)

        bmi_trend = rng.normal(0, 0.08)

        glucose_trend = (
            diabetes_trajectory * 0.7
            + rng.normal(0, 0.15)
        )

        bp_trend = (
            cardiovascular_trajectory * 0.8
            + rng.normal(0, 0.15)
        )

        cholesterol_trend = (
            cardiovascular_trajectory * 1.5
            + rng.normal(0, 0.3)
        )

        # ----------------------------------
        # Generate 12 chronological visits
        # ----------------------------------

        for visit_number in range(
            VISITS_PER_INDIVIDUAL
        ):

            days_elapsed = (
                visit_number * VISIT_INTERVAL_DAYS
            )

            visit_date = (
                pd.Timestamp("2026-01-01")
                + pd.Timedelta(days=days_elapsed)
            )

            time_step = visit_number

            age = base_age + (
                time_step * VISIT_INTERVAL_DAYS / 365.25
            )

            # ----------------------------------
            # Shared longitudinal features
            # ----------------------------------

            bmi = np.clip(
                base_bmi
                + bmi_trend * time_step
                + rng.normal(0, 0.25),
                16,
                45
            )

            waist_cm = np.clip(
                base_waist
                + (bmi - base_bmi) * 1.5
                + rng.normal(0, 0.7),
                55,
                150
            )

            # ----------------------------------
            # DIABETES FEATURES
            # ----------------------------------

            fasting_glucose = np.clip(
                88
                + (bmi - 25) * 1.4
                + glucose_trend * time_step
                + rng.normal(0, 3),
                65,
                220
            )

            post_meal_glucose = np.clip(
                fasting_glucose
                + 35
                + diabetes_trajectory * 2
                + rng.normal(0, 5),
                85,
                350
            )

            hba1c = np.clip(
                5.1
                + (fasting_glucose - 90) * 0.025
                + diabetes_trajectory * 0.04 * time_step
                + rng.normal(0, 0.08),
                4,
                12
            )

            diabetes_records.append({

                "individual_id": individual_id,

                "visit_number": visit_number + 1,

                "visit_date": visit_date.date().isoformat(),

                "age": round(age, 2),

                "bmi": round(float(bmi), 2),

                "waist_cm": round(float(waist_cm), 2),

                "fasting_glucose": round(
                    float(fasting_glucose), 2
                ),

                "post_meal_glucose": round(
                    float(post_meal_glucose), 2
                ),

                "hba1c": round(float(hba1c), 2),

                "dataset_source": "synthetic",

                "is_real_patient_data": False

            })

            # ----------------------------------
            # CARDIOVASCULAR FEATURES
            # ----------------------------------

            systolic_bp = np.clip(
                116
                + (bmi - 25) * 0.8
                + bp_trend * time_step
                + rng.normal(0, 3),
                85,
                210
            )

            diastolic_bp = np.clip(
                76
                + (bmi - 25) * 0.35
                + bp_trend * 0.45 * time_step
                + rng.normal(0, 2),
                50,
                130
            )

            pulse_rate = np.clip(
                72
                + (bmi - 25) * 0.4
                + rng.normal(0, 3),
                45,
                130
            )

            total_cholesterol = np.clip(
                175
                + cholesterol_trend * time_step
                + rng.normal(0, 5),
                100,
                350
            )

            hdl = np.clip(
                55
                - (bmi - 25) * 0.5
                + rng.normal(0, 2),
                20,
                100
            )

            ldl = np.clip(
                total_cholesterol * 0.62
                + rng.normal(0, 4),
                30,
                250
            )

            triglycerides = np.clip(
                125
                + (bmi - 25) * 2
                + cholesterol_trend * time_step
                + rng.normal(0, 7),
                40,
                500
            )

            cardiovascular_records.append({

                "individual_id": individual_id,

                "visit_number": visit_number + 1,

                "visit_date": visit_date.date().isoformat(),

                "age": round(age, 2),

                "gender": gender,

                "bmi": round(float(bmi), 2),

                "waist_cm": round(float(waist_cm), 2),

                "systolic_bp": round(
                    float(systolic_bp), 2
                ),

                "diastolic_bp": round(
                    float(diastolic_bp), 2
                ),

                "pulse_rate": round(
                    float(pulse_rate), 2
                ),

                "total_cholesterol": round(
                    float(total_cholesterol), 2
                ),

                "hdl": round(float(hdl), 2),

                "ldl": round(float(ldl), 2),

                "triglycerides": round(
                    float(triglycerides), 2
                ),

                "dataset_source": "synthetic",

                "is_real_patient_data": False

            })

    # ==========================================
    # CREATE DATAFRAMES
    # ==========================================

    diabetes_df = pd.DataFrame(
        diabetes_records
    )

    cardiovascular_df = pd.DataFrame(
        cardiovascular_records
    )

    # ==========================================
    # CREATE OUTPUT DIRECTORY
    # ==========================================

    os.makedirs(
        OUTPUT_DIR,
        exist_ok=True
    )

    diabetes_path = os.path.join(
        OUTPUT_DIR,
        "diabetes_longitudinal_synthetic.csv"
    )

    cardiovascular_path = os.path.join(
        OUTPUT_DIR,
        "cardiovascular_longitudinal_synthetic.csv"
    )

    # ==========================================
    # SAVE DATASETS
    # ==========================================

    diabetes_df.to_csv(
        diabetes_path,
        index=False
    )

    cardiovascular_df.to_csv(
        cardiovascular_path,
        index=False
    )

    # ==========================================
    # GENERATION SUMMARY
    # ==========================================

    print("\n========== GENERATION COMPLETED ==========")

    print("\nDIABETES DATASET")

    print("Total records:", len(diabetes_df))

    print(
        "Unique individuals:",
        diabetes_df["individual_id"].nunique()
    )

    print(
        "Visits per individual:",
        VISITS_PER_INDIVIDUAL
    )

    print("\nCARDIOVASCULAR DATASET")

    print(
        "Total records:",
        len(cardiovascular_df)
    )

    print(
        "Unique individuals:",
        cardiovascular_df["individual_id"].nunique()
    )

    print("\nOUTPUT FILES")

    print(diabetes_path)

    print(cardiovascular_path)

    print("\nIMPORTANT: These are synthetic demonstration datasets.")

    return diabetes_df, cardiovascular_df


# ==========================================
# MAIN EXECUTION
# ==========================================

if __name__ == "__main__":

    generate_longitudinal_dataset()
