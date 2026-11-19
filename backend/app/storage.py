import os
from pathlib import Path


# Backend project directory
BACKEND_DIR = Path(__file__).resolve().parents[1]


# Local default: backend directory
# Render production: /var/data
STORAGE_ROOT = Path(
    os.getenv(
        "STORAGE_ROOT",
        str(BACKEND_DIR)
    )
).resolve()


# Persistent upload directories
UPLOADS_ROOT = STORAGE_ROOT / "uploads"

IMAGING_UPLOAD_DIR = UPLOADS_ROOT / "imaging"

MEDICAL_REPORT_UPLOAD_DIR = UPLOADS_ROOT / "medical_reports"


# Ensure storage directories exist
IMAGING_UPLOAD_DIR.mkdir(
    parents=True,
    exist_ok=True
)

MEDICAL_REPORT_UPLOAD_DIR.mkdir(
    parents=True,
    exist_ok=True
)