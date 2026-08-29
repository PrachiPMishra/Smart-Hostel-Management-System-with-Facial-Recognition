"""Application configuration"""

from pydantic_settings import BaseSettings
from typing import List
import os


class Settings(BaseSettings):
    """Application settings"""
    
    # App
    APP_NAME: str = "Hostel Management API"
    DEBUG: bool = True
    
    # Database
    DATABASE_URL: str = os.getenv(
        "DATABASE_URL",
        "postgresql://hostel_user:hostel_pass_dev@localhost:5432/hostel_db"
    )
    
    # Redis
    REDIS_URL: str = os.getenv("REDIS_URL", "redis://localhost:6379/0")
    
    # Security
    SECRET_KEY: str = os.getenv("SECRET_KEY", "dev_secret_key_change_in_production")
    JWT_SECRET: str = os.getenv("JWT_SECRET", "dev_jwt_secret_change_in_production")
    JWT_ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24  # 24 hours
    REFRESH_TOKEN_EXPIRE_DAYS: int = 7
    
    # CORS
    CORS_ORIGINS: List[str] = [
        "http://localhost:3000",
        "http://localhost:8080",
        "http://localhost:5000",
    ]
    
    # S3/MinIO
    S3_ENDPOINT: str = os.getenv("S3_ENDPOINT", "http://localhost:9000")
    S3_ACCESS_KEY: str = os.getenv("S3_ACCESS_KEY", "minioadmin")
    S3_SECRET_KEY: str = os.getenv("S3_SECRET_KEY", "minioadmin")
    S3_BUCKET_NAME: str = "hostel-media"
    S3_USE_SSL: bool = False
    
    # Face Recognition
    FACE_CONFIDENCE_THRESHOLD: float = 0.7
    MIN_FACE_CAPTURES_FOR_ENROLLMENT: int = 5
    
    # Data Retention
    ATTENDANCE_RETENTION_DAYS: int = 365
    UNKNOWN_FACE_RETENTION_DAYS: int = 30
    
    # Encryption
    ENCRYPT_EMBEDDINGS: bool = True
    
    class Config:
        env_file = ".env"
        case_sensitive = True


settings = Settings()
