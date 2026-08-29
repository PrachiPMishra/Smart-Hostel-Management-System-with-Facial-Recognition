"""Worker configuration"""

import os
from typing import Dict


class Settings:
    """Worker settings"""
    
    # Backend API
    BACKEND_URL: str = os.getenv("BACKEND_URL", "http://localhost:8000")
    
    # Redis
    REDIS_URL: str = os.getenv("REDIS_URL", "redis://localhost:6379/0")
    
    # Model
    MODEL_PATH: str = os.getenv("MODEL_PATH", "/models/recognition_model.pkl")
    CONFIDENCE_THRESHOLD: float = 0.7
    
    # Camera streams (RTSP URLs)
    # Format: {"camera_id": "rtsp://url"}
    CAMERA_STREAMS: Dict[str, str] = {
        "entrance": os.getenv("CAMERA_ENTRANCE", "rtsp://admin:password@192.168.1.100:554/stream"),
        "mess_hall": os.getenv("CAMERA_MESS", "rtsp://admin:password@192.168.1.101:554/stream"),
        # Add more cameras as needed
    }
    
    # Processing
    PROCESSING_INTERVAL: int = 5  # Process frame every N seconds
    MAX_FACE_SIZE: int = 800  # Maximum face dimension for processing
    MIN_FACE_SIZE: int = 50   # Minimum face dimension to process
    
    # Debug
    DEBUG: bool = os.getenv("DEBUG", "False").lower() == "true"
    
    # Logging
    LOG_LEVEL: str = os.getenv("LOG_LEVEL", "INFO")


settings = Settings()
