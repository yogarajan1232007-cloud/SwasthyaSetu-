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

from app.schemas.medical_report import (
    MedicalReportResponse,
    MedicalReportUpdate
)

from app.services.medical_report_service import (
    upload_medical_report,
    get_medical_reports,
    get_medical_report_by_id,
    get_report_file,
    update_medical_report
)


router = APIRouter(
    prefix="/medical-reports",
    tags=["Medical Report Management"]
)


@router.post(
    "/upload",
    response_model=MedicalReportResponse
)
async def upload_report(
    individual_id: int = Form(...),
    report_type: str = Form(...),
    report_name: str = Form(...),
    screening_id: Optional[int] = Form(None),
    uploaded_by: Optional[int] = Form(None),
    notes: Optional[str] = Form(None),
    file: UploadFile = File(...),
    db: Session = Depends(get_db)
):

    return await upload_medical_report(
        db=db,
        individual_id=individual_id,
        report_type=report_type,
        report_name=report_name,
        file=file,
        screening_id=screening_id,
        uploaded_by=uploaded_by,
        notes=notes
    )


@router.get(
    "/",
    response_model=list[MedicalReportResponse]
)
def list_reports(
    individual_id: Optional[int] = None,
    screening_id: Optional[int] = None,
    db: Session = Depends(get_db)
):

    return get_medical_reports(
        db,
        individual_id=individual_id,
        screening_id=screening_id
    )


@router.get(
    "/{report_id}",
    response_model=MedicalReportResponse
)
def get_report(
    report_id: int,
    db: Session = Depends(get_db)
):

    return get_medical_report_by_id(
        db,
        report_id
    )


@router.get("/{report_id}/download")
def download_report(
    report_id: int,
    db: Session = Depends(get_db)
):

    report, file_path = get_report_file(
        db,
        report_id
    )

    return FileResponse(
        path=file_path,
        filename=f"{report.report_name}{file_path.suffix}",
        media_type="application/octet-stream"
    )


@router.patch(
    "/{report_id}",
    response_model=MedicalReportResponse
)
def update_report(
    report_id: int,
    data: MedicalReportUpdate,
    db: Session = Depends(get_db)
):

    return update_medical_report(
        db,
        report_id,
        data
    )