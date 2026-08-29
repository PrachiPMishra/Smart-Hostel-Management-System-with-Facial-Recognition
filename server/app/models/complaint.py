"""Complaint database models"""

from sqlalchemy import Column, String, DateTime, Text, ForeignKey, Enum as SQLEnum
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.sql import func
import uuid
import enum

from app.core.database import Base


class ComplaintCategory(str, enum.Enum):
    """Complaint categories"""
    MAINTENANCE = "maintenance"
    CLEANLINESS = "cleanliness"
    FOOD = "food"
    SECURITY = "security"
    OTHER = "other"


class ComplaintStatus(str, enum.Enum):
    """Complaint statuses"""
    PENDING = "pending"
    IN_PROGRESS = "in_progress"
    RESOLVED = "resolved"
    CLOSED = "closed"


class Complaint(Base):
    """Complaint model"""
    __tablename__ = "complaints"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False, index=True)
    
    # Complaint details
    category = Column(SQLEnum(ComplaintCategory), nullable=False)
    title = Column(String(255), nullable=False)
    description = Column(Text, nullable=False)
    
    # Status
    status = Column(SQLEnum(ComplaintStatus), default=ComplaintStatus.PENDING, index=True)
    
    # Resolution
    assigned_to = Column(UUID(as_uuid=True), ForeignKey("users.id"))
    resolved_at = Column(DateTime(timezone=True))
    resolution_notes = Column(Text)
    
    # Timestamps
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    
    def __repr__(self):
        return f"<Complaint {self.title} {self.status}>"
