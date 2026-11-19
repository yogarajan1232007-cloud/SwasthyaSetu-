from typing import Optional

from fastapi import (
    APIRouter,
    Depends,
    UploadFile,
    File,
    Form
)

from fastapi.responses import FileResponse
from sqlalchemy.orm import Session

from app.database.session import get_db

from app.schemas.imaging_file import (
    ImagingFileResponse,
    ImagingFileUpdate
)

from app.services.imaging_service import (
    upload_imaging_file,
    get_imaging_files,
    get_imaging_by_id,
    get_imaging_file,
    update_imaging_file
)


router = APIRouter(
    prefix="/imaging",
    tags=["Imaging Management"]
)


@router.post(
    "/upload",
    response_model=ImagingFileResponse
)
async def upload_imaging(
    individual_id: int = Form(...),
    modality: str = Form(...),
    body_region: Optional[str] = Form(None),
    screening_id: Optional[int] = Form(None),
    uploaded_by: Optional[int] = Form(None),
    notes: Optional[str] = Form(None),
    file: UploadFile = File(...),
    db: Session = Depends(get_db)
):

    return await upload_imaging_file(
        db=db,
        individual_id=individual_id,
        modality=modality,
        file=file,
        screening_id=screening_id,
        uploaded_by=uploaded_by,
        body_region=body_region,
        notes=notes
    )


@router.get(
    "/",
    response_model=list[ImagingFileResponse]
)
def list_imaging(
    individual_id: Optional[int] = None,
    screening_id: Optional[int] = None,
    modality: Optional[str] = None,
    db: Session = Depends(get_db)
):

    return get_imaging_files(
        db,
        individual_id=individual_id,
        screening_id=screening_id,
        modality=modality
    )


@router.get(
    "/{imaging_id}",
    response_model=ImagingFileResponse
)
def get_imaging(
    imaging_id: int,
    db: Session = Depends(get_db)
):

    return get_imaging_by_id(
        db,
        imaging_id
    )


@router.get("/{imaging_id}/download")
def download_imaging(
    imaging_id: int,
    db: Session = Depends(get_db)
):

    imaging, file_path = get_imaging_file(
        db,
        imaging_id
    )

    return FileResponse(
        path=file_path,
        filename=f"{imaging.modality}_{imaging.id}{file_path.suffix}",
        media_type="application/octet-stream"
    )


@router.patch(
    "/{imaging_id}",
    response_model=ImagingFileResponse
)
def update_imaging(
    imaging_id: int,
    data: ImagingFileUpdate,
    db: Session = Depends(get_db)
):

    return update_imaging_file(
        db,
        imaging_id,
        data
    )