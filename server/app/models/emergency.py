"""Emergency alert database models"""

from sqlalchemy import Column, String, DateTime, Text, ForeignKey, Boolean
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.sql import func
import uuid

from app.core.database import Base


class EmergencyAlert(Base):
    """Emergency alert model"""
    __tablename__ = "emergency_alerts"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False, index=True)
    
    # Location
    location = Column(String(500))
    
    # Status
    resolved = Column(Boolean, default=False)
    resolved_at = Column(DateTime(timezone=True))
    resolved_by = Column(UUID(as_uuid=True), ForeignKey("users.id"))
    notes = Column(Text)
    
    # Timestamp
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    def __repr__(self):
        return f"<EmergencyAlert {self.user_id} at {self.created_at}>"


class EmergencyContact(Base):
    """Emergency contact model"""
    __tablename__ = "emergency_contacts"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False, index=True)
    
    # Contact details
    name = Column(String(255), nullable=False)
    relationship = Column(String(100))
    phone = Column(String(20), nullable=False)
    email = Column(String(255))
    
    # Timestamps
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    def __repr__(self):
        return f"<EmergencyContact {self.name}>"
