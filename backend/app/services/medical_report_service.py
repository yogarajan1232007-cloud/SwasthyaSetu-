from pathlib import Path
from uuid import uuid4

from fastapi import HTTPException, UploadFile
from sqlalchemy.orm import Session
from sqlalchemy import desc

from app.models.medical_report import MedicalReport
from app.models.individual import Individual
from app.models.screening import Screening
from app.models.user import User

from app.schemas.medical_report import MedicalReportUpdate

from app.storage import STORAGE_ROOT, MEDICAL_REPORT_UPLOAD_DIR


UPLOAD_DIR = MEDICAL_REPORT_UPLOAD_DIR

ALLOWED_EXTENSIONS = {
    ".pdf": "application/pdf",
    ".jpg": "image/jpeg",
    ".jpeg": "image/jpeg",
    ".png": "image/png"
}

MAX_FILE_SIZE = 10 * 1024 * 1024  # 10 MB


def validate_file_content(content, extension):

    if extension == ".pdf":
        return content.startswith(b"%PDF-")

    if extension == ".png":
        return content.startswith(b"\x89PNG\r\n\x1a\n")

    if extension in [".jpg", ".jpeg"]:
        return content.startswith(b"\xff\xd8\xff")

    return False


async def upload_medical_report(
    db: Session,
    individual_id: int,
    report_type: str,
    report_name: str,
    file: UploadFile,
    screening_id: int = None,
    uploaded_by: int = None,
    notes: str = None
):

    # 1. Verify individual
    individual = db.query(Individual).filter(
        Individual.id == individual_id,
        Individual.is_active == True
    ).first()

    if not individual:
        raise HTTPException(
            status_code=404,
            detail="Individual not found or inactive"
        )

    # 2. Verify screening if provided
    if screening_id is not None:

        screening = db.query(Screening).filter(
            Screening.id == screening_id
        ).first()

        if not screening:
            raise HTTPException(
                status_code=404,
                detail="Screening not found"
            )

        if screening.individual_id != individual_id:
            raise HTTPException(
                status_code=400,
                detail="Screening does not belong to this individual"
            )

    # 3. Verify uploader if provided
    if uploaded_by is not None:

        user = db.query(User).filter(
            User.id == uploaded_by,
            User.is_active == True
        ).first()

        if not user:
            raise HTTPException(
                status_code=404,
                detail="Uploader not found or inactive"
            )

    # 4. Validate extension
    extension = Path(file.filename or "").suffix.lower()

    if extension not in ALLOWED_EXTENSIONS:
        raise HTTPException(
            status_code=400,
            detail="Only PDF, JPG, JPEG and PNG files are allowed"
        )

    # 5. Validate MIME type
    expected_content_type = ALLOWED_EXTENSIONS[extension]

    if file.content_type != expected_content_type:
        raise HTTPException(
            status_code=400,
            detail="File content type does not match its extension"
        )

    # 6. Read and validate file size
    content = await file.read(MAX_FILE_SIZE + 1)

    if not content:
        raise HTTPException(
            status_code=400,
            detail="Uploaded file is empty"
        )

    if len(content) > MAX_FILE_SIZE:
        raise HTTPException(
            status_code=413,
            detail="Maximum file size is 10 MB"
        )

    # 7. Validate actual file signature
    if not validate_file_content(content, extension):
        raise HTTPException(
            status_code=400,
            detail="Invalid or unsupported file content"
        )

    # 8. Create upload directory
    UPLOAD_DIR.mkdir(
        parents=True,
        exist_ok=True
    )

    # 9. Generate safe unique filename
    filename = f"{uuid4().hex}{extension}"

    file_path = UPLOAD_DIR / filename

    # Preserve existing relative database path format
    relative_path = (
        Path("uploads") / "medical_reports" / filename
    ).as_posix()

    try:

        # 10. Save physical file
        file_path.write_bytes(content)

        # 11. Save database record
        report = MedicalReport(
            individual_id=individual_id,
            screening_id=screening_id,
            uploaded_by=uploaded_by,
            report_type=report_type,
            report_name=report_name,
            file_path=relative_path,
            file_format=extension.lstrip("."),
            verification_status="pending",
            notes=notes
        )

        db.add(report)
        db.commit()
        db.refresh(report)

        return report

    except Exception:

        db.rollback()

        if file_path.exists():
            file_path.unlink()

        raise HTTPException(
            status_code=500,
            detail="Failed to upload medical report"
        )


def get_medical_reports(
    db: Session,
    individual_id: int = None,
    screening_id: int = None
):

    query = db.query(MedicalReport)

    if individual_id is not None:
        query = query.filter(
            MedicalReport.individual_id == individual_id
        )

    if screening_id is not None:
        query = query.filter(
            MedicalReport.screening_id == screening_id
        )

    return query.order_by(
        desc(MedicalReport.id)
    ).all()


def get_medical_report_by_id(
    db: Session,
    report_id: int
):

    report = db.query(MedicalReport).filter(
        MedicalReport.id == report_id
    ).first()

    if not report:
        raise HTTPException(
            status_code=404,
            detail="Medical report not found"
        )

    return report


def get_report_file(
    db: Session,
    report_id: int
):

    report = get_medical_report_by_id(
        db,
        report_id
    )

    # Resolve the stored relative path against the configured storage root
    file_path = (
        STORAGE_ROOT / report.file_path
    ).resolve()

    # Prevent access outside the medical reports directory
    if not file_path.is_relative_to(UPLOAD_DIR.resolve()):
        raise HTTPException(
            status_code=400,
            detail="Invalid report file path"
        )

    if not file_path.is_file():
        raise HTTPException(
            status_code=404,
            detail="Report file not found"
        )

    return report, file_path


def update_medical_report(
    db: Session,
    report_id: int,
    data: MedicalReportUpdate
):

    report = get_medical_report_by_id(
        db,
        report_id
    )

    update_data = data.model_dump(
        exclude_unset=True
    )

    for field, value in update_data.items():
        setattr(report, field, value)

    try:

        db.commit()
        db.refresh(report)

        return report

    except Exception:

        db.rollback()

        raise HTTPException(
            status_code=500,
            detail="Failed to update medical report"
        )