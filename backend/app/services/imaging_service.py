from pathlib import Path
from uuid import uuid4

from fastapi import HTTPException, UploadFile
from sqlalchemy.orm import Session
from sqlalchemy import desc

from app.models.imaging_file import ImagingFile
from app.models.individual import Individual
from app.models.screening import Screening
from app.models.user import User

from app.schemas.imaging_file import ImagingFileUpdate
from app.storage import STORAGE_ROOT, IMAGING_UPLOAD_DIR


UPLOAD_DIR = IMAGING_UPLOAD_DIR

ALLOWED_EXTENSIONS = {
    ".pdf": ("application/pdf", "pdf"),
    ".jpg": ("image/jpeg", "jpeg"),
    ".jpeg": ("image/jpeg", "jpeg"),
    ".png": ("image/png", "png"),
}

MAX_FILE_SIZE = 10 * 1024 * 1024

ALLOWED_MODALITIES = {
    "ECG",
    "XRAY",
    "CT",
    "MRI",
    "ULTRASOUND"
}


def validate_file_content(content, extension):

    if extension == ".pdf":
        return content.startswith(b"%PDF-")

    if extension == ".png":
        return content.startswith(b"\x89PNG\r\n\x1a\n")

    if extension in [".jpg", ".jpeg"]:
        return content.startswith(b"\xff\xd8\xff")

    return False


async def upload_imaging_file(
    db: Session,
    individual_id: int,
    modality: str,
    file: UploadFile,
    screening_id: int = None,
    uploaded_by: int = None,
    body_region: str = None,
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

    # 2. Verify screening
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

    # 3. Verify uploader
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

    # 4. Validate modality
    modality = modality.upper()

    if modality not in ALLOWED_MODALITIES:
        raise HTTPException(
            status_code=400,
            detail="Unsupported imaging modality"
        )

    # 5. Validate extension
    extension = Path(file.filename or "").suffix.lower()

    if extension not in ALLOWED_EXTENSIONS:
        raise HTTPException(
            status_code=400,
            detail="Only PDF, JPG, JPEG and PNG files are allowed"
        )

    expected_type, file_format = ALLOWED_EXTENSIONS[extension]

    if file.content_type != expected_type:
        raise HTTPException(
            status_code=400,
            detail="File content type does not match its extension"
        )

    # 6. Validate content and size
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

    if not validate_file_content(content, extension):
        raise HTTPException(
            status_code=400,
            detail="Invalid file content"
        )

    # 7. Create upload directory
    UPLOAD_DIR.mkdir(
        parents=True,
        exist_ok=True
    )

    filename = f"{uuid4().hex}{extension}"

    file_path = UPLOAD_DIR / filename

    relative_path = (
        Path("uploads") / "imaging" / filename
    ).as_posix()

    try:

        # 8. Save physical file
        file_path.write_bytes(content)

        # 9. Save database record
        imaging = ImagingFile(
            individual_id=individual_id,
            screening_id=screening_id,
            uploaded_by=uploaded_by,
            modality=modality,
            body_region=body_region,
            file_path=relative_path,
            file_format=file_format,
            status="uploaded",
            notes=notes
        )

        db.add(imaging)
        db.commit()
        db.refresh(imaging)

        return imaging

    except Exception:

        db.rollback()

        if file_path.exists():
            file_path.unlink()

        raise HTTPException(
            status_code=500,
            detail="Failed to upload imaging file"
        )


def get_imaging_files(
    db: Session,
    individual_id: int = None,
    screening_id: int = None,
    modality: str = None
):

    query = db.query(ImagingFile)

    if individual_id is not None:
        query = query.filter(
            ImagingFile.individual_id == individual_id
        )

    if screening_id is not None:
        query = query.filter(
            ImagingFile.screening_id == screening_id
        )

    if modality is not None:
        query = query.filter(
            ImagingFile.modality == modality.upper()
        )

    return query.order_by(
        desc(ImagingFile.id)
    ).all()


def get_imaging_by_id(
    db: Session,
    imaging_id: int
):

    imaging = db.query(ImagingFile).filter(
        ImagingFile.id == imaging_id
    ).first()

    if not imaging:
        raise HTTPException(
            status_code=404,
            detail="Imaging record not found"
        )

    return imaging


def get_imaging_file(
    db: Session,
    imaging_id: int
):

    imaging = get_imaging_by_id(
        db,
        imaging_id
    )

    file_path = (
        STORAGE_ROOT / imaging.file_path
    ).resolve()

    if not file_path.is_relative_to(UPLOAD_DIR.resolve()):
        raise HTTPException(
            status_code=400,
            detail="Invalid file path"
        )

    if not file_path.is_file():
        raise HTTPException(
            status_code=404,
            detail="Imaging file not found"
        )

    return imaging, file_path


def update_imaging_file(
    db: Session,
    imaging_id: int,
    data: ImagingFileUpdate
):

    imaging = get_imaging_by_id(
        db,
        imaging_id
    )

    update_data = data.model_dump(
        exclude_unset=True
    )

    for field, value in update_data.items():
        setattr(imaging, field, value)

    try:

        db.commit()
        db.refresh(imaging)

        return imaging

    except Exception:

        db.rollback()

        raise HTTPException(
            status_code=500,
            detail="Failed to update imaging record"
        )