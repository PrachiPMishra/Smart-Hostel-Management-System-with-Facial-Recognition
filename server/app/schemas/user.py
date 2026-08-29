"""User schemas for request/response validation"""

from pydantic import BaseModel, EmailStr, Field
from typing import Optional, List
from datetime import datetime
from uuid import UUID

from app.models.user import UserRole


class UserBase(BaseModel):
    """Base user schema"""
    email: EmailStr
    name: str
    phone: Optional[str] = None
    role: UserRole = UserRole.STUDENT


class UserCreate(UserBase):
    """User creation schema"""
    password: str = Field(..., min_length=6)


class UserUpdate(BaseModel):
    """User update schema"""
    name: Optional[str] = None
    phone: Optional[str] = None
    parent_contacts: Optional[List[dict]] = None


class UserResponse(UserBase):
    """User response schema"""
    id: UUID
    hostel_id: Optional[UUID] = None
    room_no: Optional[str] = None
    enrolled_face: bool = False
    consent_given_at: Optional[datetime] = None
    last_seen_at: Optional[datetime] = None
    is_active: bool
    created_at: datetime
    
    class Config:
        from_attributes = True


class Token(BaseModel):
    """Token response schema"""
    access_token: str
    refresh_token: str
    token_type: str = "bearer"


class TokenData(BaseModel):
    """Token data schema"""
    user_id: Optional[UUID] = None
