"""Attendance database models"""

from sqlalchemy import Column, String, DateTime, Float, ForeignKey, Enum as SQLEnum
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.sql import func
import uuid
import enum

from app.core.database import Base


class AttendanceMethod(str, enum.Enum):
    """Attendance marking methods"""
    FACE = "face"
    MANUAL = "manual"
    RFID = "rfid"


class AttendanceEvent(Base):
    """Attendance event model"""
    __tablename__ = "attendance_events"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False, index=True)
    camera_id = Column(String(100))
    
    # Recognition data
    confidence = Column(Float, default=0.0)
    method = Column(SQLEnum(AttendanceMethod), default=AttendanceMethod.FACE)
    
    # Media
    photo_url = Column(String(500))
    
    # Timestamp
    timestamp = Column(DateTime(timezone=True), server_default=func.now(), index=True)
    
    def __repr__(self):
        return f"<AttendanceEvent {self.user_id} at {self.timestamp}>"


class UnknownFace(Base):
    """Unknown face detection model"""
    __tablename__ = "unknown_faces"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    camera_id = Column(String(100), nullable=False)
    
    # Media
    image_url = Column(String(500))
    clip_url = Column(String(500))
    
    # Status
    handled = Column(Boolean, default=False)
    notified = Column(Boolean, default=False)
    
    # Timestamps
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    def __repr__(self):
        return f"<UnknownFace {self.camera_id} at {self.created_at}>"
