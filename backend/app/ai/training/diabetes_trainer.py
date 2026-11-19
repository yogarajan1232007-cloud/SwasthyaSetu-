from pathlib import Path
import json
import warnings

import joblib
import numpy as np
import pandas as pd

from sklearn.ensemble import RandomForestClassifier, GradientBoostingClassifier
from sklearn.inspection import permutation_importance
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import (
    accuracy_score, balanced_accuracy_score, classification_report,
    confusion_matrix, f1_score, precision_score, recall_score,
    roc_auc_score, log_loss,
)
from sklearn.model_selection import (
    RandomizedSearchCV, StratifiedKFold, train_test_split,
)
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import StandardScaler

warnings.filterwarnings("ignore")

RANDOM_SEED = 42
TARGET_COLUMN = "synthetic_demo_category"
CLASS_LABELS = ["Low", "Medium", "High"]

FEATURE_COLUMNS = [
    "age", "bmi", "waist_cm", "fasting_glucose",
    "post_meal_glucose", "hba1c",
]

BASE_DIR = Path(__file__).resolve().parents[3]
DATASET_PATH = BASE_DIR / "datasets" / "diabetes_synthetic.csv"
MODEL_DIR = BASE_DIR / "trained_models" / "diabetes"
MODEL_DIR.mkdir(parents=True, exist_ok=True)


def load_dataset():
    if not DATASET_PATH.exists():
        raise FileNotFoundError(f"Dataset not found: {DATASET_PATH}")

    dataset = pd.read_csv(DATASET_PATH)
    required_columns = FEATURE_COLUMNS + [TARGET_COLUMN]
    missing_columns = [c for c in required_columns if c not in dataset.columns]
    if missing_columns:
        raise ValueError(f"Missing columns: {missing_columns}")

    dataset = dataset[required_columns].copy()
    original_count = len(dataset)
    dataset = dataset.drop_duplicates().reset_index(drop=True)
    removed_duplicates = original_count - len(dataset)

    if dataset.isnull().any().any():
        raise ValueError("Dataset contains missing values.")

    actual_labels = set(dataset[TARGET_COLUMN].unique())
    if actual_labels != set(CLASS_LABELS):
        raise ValueError(
            f"Expected categories {CLASS_LABELS}, found {sorted(actual_labels)}"
        )

    print("\\nDATASET INFORMATION")
    print("-" * 45)
    print("Original records:", original_count)
    print("Records after duplicate removal:", len(dataset))
    print("Duplicates removed:", removed_duplicates)
    print("Features:", len(FEATURE_COLUMNS))
    print("\\nCategory distribution:")
    print(dataset[TARGET_COLUMN].value_counts())
    return dataset


def prepare_data(dataset):
    X = dataset[FEATURE_COLUMNS]
    y = dataset[TARGET_COLUMN]

    X_train, X_temp, y_train, y_temp = train_test_split(
        X, y, test_size=0.30, random_state=RANDOM_SEED, stratify=y
    )
    X_validation, X_test, y_validation, y_test = train_test_split(
        X_temp, y_temp, test_size=0.50,
        random_state=RANDOM_SEED, stratify=y_temp
    )

    print("\\nDATA SPLIT")
    print("-" * 45)
    print("Training:", len(X_train))
    print("Validation:", len(X_validation))
    print("Final test:", len(X_test))

    return X_train, X_validation, X_test, y_train, y_validation, y_test


def get_model_searches():
    cv = StratifiedKFold(
        n_splits=5, shuffle=True, random_state=RANDOM_SEED
    )

    logistic_pipeline = Pipeline([
        ("scaler", StandardScaler()),
        ("classifier", LogisticRegression(
            max_iter=3000, random_state=RANDOM_SEED
        )),
    ])

    random_forest = RandomForestClassifier(
        random_state=RANDOM_SEED, n_jobs=1, class_weight="balanced"
    )
    gradient_boosting = GradientBoostingClassifier(
        random_state=RANDOM_SEED
    )

    configurations = {
        "Logistic Regression": (
            logistic_pipeline,
            {
                "classifier__C": [0.01, 0.1, 1.0, 10.0],
                "classifier__solver": ["lbfgs"],
            },
        ),
        "Random Forest": (
            random_forest,
            {
                "n_estimators": [150, 250, 350],
                "max_depth": [8, 12, 16, None],
                "min_samples_split": [2, 5, 10],
                "min_samples_leaf": [1, 2, 4],
            },
        ),
        "Gradient Boosting": (
            gradient_boosting,
            {
                "n_estimators": [100, 150, 200],
                "learning_rate": [0.03, 0.05, 0.1],
                "max_depth": [2, 3, 4],
                "subsample": [0.8, 1.0],
            },
        ),
    }

    return {
        name: RandomizedSearchCV(
            estimator=estimator,
            param_distributions=params,
            n_iter=5,
            scoring="f1_macro",
            cv=cv,
            random_state=RANDOM_SEED,
            n_jobs=-1,
            refit=True,
            error_score="raise",
        )
        for name, (estimator, params) in configurations.items()
    }


def evaluate_model(model, X, y):
    predictions = model.predict(X)
    probabilities = model.predict_proba(X)

    # predict_proba columns are ordered exactly as model.classes_.
    # Keep labels and probability columns in that same order.
    model_classes = list(model.classes_)
    if len(model_classes) != len(CLASS_LABELS):
        raise ValueError(
            f"Expected {len(CLASS_LABELS)} classes, got {model_classes}"
        )

    class_to_index = {
        label: index for index, label in enumerate(model_classes)
    }
    y_encoded = np.asarray([class_to_index[label] for label in y])
    one_hot = np.eye(len(model_classes))[y_encoded]

    metrics = {
        "accuracy": float(accuracy_score(y, predictions)),
        "balanced_accuracy": float(balanced_accuracy_score(y, predictions)),
        "precision_macro": float(precision_score(
            y, predictions, average="macro", zero_division=0
        )),
        "recall_macro": float(recall_score(
            y, predictions, average="macro", zero_division=0
        )),
        "f1_macro": float(f1_score(
            y, predictions, average="macro", zero_division=0
        )),
        "roc_auc_ovr_macro": float(roc_auc_score(
            y, probabilities, labels=model_classes,
            multi_class="ovr", average="macro"
        )),
        "log_loss": float(log_loss(
            y, probabilities, labels=model_classes
        )),
        "multiclass_brier_score": float(
            np.mean(np.sum((probabilities - one_hot) ** 2, axis=1))
        ),
        "confusion_matrix": confusion_matrix(
            y, predictions, labels=CLASS_LABELS
        ).tolist(),
        "classification_report": classification_report(
            y, predictions, labels=CLASS_LABELS,
            output_dict=True, zero_division=0
        ),
    }
    return metrics


def train_models(X_train, X_validation, y_train, y_validation):
    searches = get_model_searches()
    trained_models = {}
    validation_results = {}
    cross_validation_results = {}

    for model_name, search in searches.items():
        print("\\n" + "=" * 60)
        print("HYPERPARAMETER TUNING:", model_name)
        print("=" * 60)

        search.fit(X_train, y_train)
        best_model = search.best_estimator_
        cv_score = float(search.best_score_)
        metrics = evaluate_model(best_model, X_validation, y_validation)

        trained_models[model_name] = best_model
        validation_results[model_name] = metrics
        cross_validation_results[model_name] = {
            "mean_macro_f1": cv_score,
            "best_parameters": search.best_params_,
        }

        print("\\nCross-validation mean macro F1:", round(cv_score, 4))
        print("Best parameters:")
        print(search.best_params_)
        print("\\nValidation metrics:")
        for metric, value in metrics.items():
            if isinstance(value, (int, float)):
                print(f"{metric}: {value:.4f}")

    return trained_models, validation_results, cross_validation_results


def select_best_model(validation_results):
    comparison = pd.DataFrame([
        {
            "model": name,
            "accuracy": m["accuracy"],
            "balanced_accuracy": m["balanced_accuracy"],
            "precision_macro": m["precision_macro"],
            "recall_macro": m["recall_macro"],
            "f1_macro": m["f1_macro"],
            "roc_auc_ovr_macro": m["roc_auc_ovr_macro"],
            "log_loss": m["log_loss"],
            "multiclass_brier_score": m["multiclass_brier_score"],
        }
        for name, m in validation_results.items()
    ]).sort_values(by="f1_macro", ascending=False)

    best_model_name = comparison.iloc[0]["model"]
    print("\\n" + "=" * 60)
    print("VALIDATION MODEL COMPARISON")
    print("=" * 60)
    print(comparison.to_string(index=False))
    print("\\nSelected model:", best_model_name)
    return best_model_name, comparison


def calculate_feature_importance(model, X, y):
    result = permutation_importance(
        model, X, y, scoring="f1_macro", n_repeats=5,
        random_state=RANDOM_SEED, n_jobs=-1
    )
    importance = pd.DataFrame({
        "feature": FEATURE_COLUMNS,
        "importance_mean": result.importances_mean,
        "importance_std": result.importances_std,
    })
    return importance.sort_values(
        by="importance_mean", ascending=False
    )


def evaluate_age_groups(model, X_test, y_test):
    test_data = X_test.copy()
    test_data["actual"] = y_test.to_numpy()
    test_data["predicted"] = model.predict(X_test)
    test_data["age_group"] = pd.cut(
        test_data["age"],
        bins=[17, 39, 59, 100],
        labels=["18-39", "40-59", "60+"],
    )

    results = {}
    for group, subset in test_data.groupby(
        "age_group", observed=False
    ):
        if subset.empty:
            continue
        results[str(group)] = {
            "records": int(len(subset)),
            "accuracy": float(accuracy_score(
                subset["actual"], subset["predicted"]
            )),
            "macro_f1": float(f1_score(
                subset["actual"], subset["predicted"],
                average="macro", zero_division=0
            )),
        }
    return results


def evaluate_final_model(model, X_test, y_test):
    print("\\n" + "=" * 60)
    print("FINAL UNTOUCHED TEST EVALUATION")
    print("=" * 60)

    metrics = evaluate_model(model, X_test, y_test)
    print("\\nFinal test metrics:")
    for metric, value in metrics.items():
        if isinstance(value, (int, float)):
            print(f"{metric}: {value:.4f}")

    print("\\nClassification report:")
    print(classification_report(
        y_test, model.predict(X_test),
        labels=CLASS_LABELS, zero_division=0
    ))
    print("Confusion matrix:")
    print(metrics["confusion_matrix"])
    return metrics


def save_results(
    best_model_name, best_model, comparison, validation_results,
    cross_validation_results, test_metrics, feature_importance,
    age_group_results
):
    model_path = MODEL_DIR / "diabetes_best_model.joblib"
    report_path = MODEL_DIR / "evaluation_report.json"

    joblib.dump(best_model, model_path)
    comparison.to_csv(MODEL_DIR / "model_comparison.csv", index=False)
    feature_importance.to_csv(
        MODEL_DIR / "feature_importance.csv", index=False
    )

    report = {
        "model_type": "diabetes_classification",
        "dataset_type": "synthetic",
        "validation_status": "experimental",
        "approval_status": "pending",
        "is_active": False,
        "selected_model": best_model_name,
        "selection_metric": "validation_macro_f1",
        "feature_columns": FEATURE_COLUMNS,
        "target_column": TARGET_COLUMN,
        "split": {
            "training": 0.70,
            "validation": 0.15,
            "testing": 0.15,
        },
        "cross_validation": cross_validation_results,
        "validation_results": validation_results,
        "final_test_metrics": test_metrics,
        "feature_importance": feature_importance.to_dict(
            orient="records"
        ),
        "age_group_evaluation": age_group_results,
        "clinical_validation": False,
        "warning": (
            "Metrics measure agreement with synthetic demonstration "
            "labels and do not establish clinical accuracy."
        ),
    }

    with open(report_path, "w", encoding="utf-8") as file:
        json.dump(report, file, indent=4)

    print("\\n" + "=" * 60)
    print("MODEL AND REPORTS SAVED")
    print("=" * 60)
    print("Selected model:", best_model_name)
    print("Model:", model_path)
    print("Evaluation:", report_path)
    print("Feature importance:", MODEL_DIR / "feature_importance.csv")


def main():
    print("\\n" + "=" * 65)
    print(" SWASTHYASETHU - IMPROVED DIABETES MODEL EVALUATION")
    print("=" * 65)

    dataset = load_dataset()
    (
        X_train, X_validation, X_test,
        y_train, y_validation, y_test,
    ) = prepare_data(dataset)

    (
        trained_models, validation_results, cross_validation_results,
    ) = train_models(
        X_train, X_validation, y_train, y_validation
    )

    best_model_name, comparison = select_best_model(validation_results)
    best_model = trained_models[best_model_name]

    # Final test data is evaluated only after model selection.
    test_metrics = evaluate_final_model(best_model, X_test, y_test)

    feature_importance = calculate_feature_importance(
        best_model, X_validation, y_validation
    )
    age_group_results = evaluate_age_groups(
        best_model, X_test, y_test
    )

    save_results(
        best_model_name,
        best_model,
        comparison,
        validation_results,
        cross_validation_results,
        test_metrics,
        feature_importance,
        age_group_results,
    )

    print("\\n" + "=" * 65)
    print("DIABETES EVALUATION COMPLETED")
    print("=" * 65)
    print("Selected model:", best_model_name)
    print("\\nIMPORTANT:")
    print("Training uses synthetic demonstration data.")
    print("Metrics do not establish clinical accuracy.")
    print("Model remains experimental and inactive.")


if __name__ == "__main__":
    main()
