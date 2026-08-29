"""User database models"""

from sqlalchemy import Column, String, Boolean, DateTime, JSON, Enum as SQLEnum
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.sql import func
import uuid
import enum

from app.core.database import Base


class UserRole(str, enum.Enum):
    """User roles"""
    STUDENT = "student"
    PARENT = "parent"
    WARDEN = "warden"
    ADMIN = "admin"


class User(Base):
    """User model"""
    __tablename__ = "users"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    role = Column(SQLEnum(UserRole), nullable=False, default=UserRole.STUDENT)
    
    # Basic info
    name = Column(String(255), nullable=False)
    email = Column(String(255), unique=True, nullable=False, index=True)
    phone = Column(String(20))
    password_hash = Column(String(255), nullable=False)
    
    # Hostel info
    hostel_id = Column(UUID(as_uuid=True))
    room_no = Column(String(50))
    
    # Parent contacts (JSON array)
    parent_contacts = Column(JSON, default=list)
    
    # Face enrollment
    enrolled_face = Column(Boolean, default=False)
    consent_given_at = Column(DateTime(timezone=True))
    
    # Activity tracking
    last_seen_at = Column(DateTime(timezone=True))
    
    # Account status
    is_active = Column(Boolean, default=True)
    
    # Timestamps
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())

    def __repr__(self):
        return f"<User {self.email}>"
