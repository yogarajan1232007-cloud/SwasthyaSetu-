import os
from pathlib import Path

from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from app.database.base import Base


# Backend directory
BASE_DIR = Path(__file__).resolve().parents[2]

# Environment-specific SQLite database path
DATABASE_PATH = Path(
    os.getenv(
        "DATABASE_PATH",
        str(BASE_DIR / "swasthya_setu.db")
    )
)

# Ensure database directory exists
DATABASE_PATH.parent.mkdir(parents=True, exist_ok=True)

# SQLite connection URL
DATABASE_URL = f"sqlite:///{DATABASE_PATH.as_posix()}"


# Database engine
engine = create_engine(
    DATABASE_URL,
    connect_args={"check_same_thread": False}
)


# Database session
SessionLocal = sessionmaker(
    autocommit=False,
    autoflush=False,
    bind=engine
)


# Database dependency
def get_db():
    db = SessionLocal()

    try:
        yield db
    finally:
        db.close()