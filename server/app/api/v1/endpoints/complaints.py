"""Complaint endpoints"""

from fastapi import APIRouter, Depends, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from datetime import datetime
from typing import List

from app.core.database import get_db
from app.core.security import get_current_active_user
from app.models.user import User
from app.models.complaint import Complaint, ComplaintCategory, ComplaintStatus
from pydantic import BaseModel

router = APIRouter()


class ComplaintCreate(BaseModel):
    category: str
    title: str
    description: str


class ComplaintResponse(BaseModel):
    id: str
    category: str
    title: str
    description: str
    status: str
    created_at: datetime
    
    class Config:
        from_attributes = True


@router.get("", response_model=List[ComplaintResponse])
async def get_complaints(
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """Get complaints"""
    result = await db.execute(
        select(Complaint)
        .where(Complaint.user_id == current_user.id)
        .order_by(Complaint.created_at.desc())
    )
    complaints = result.scalars().all()
    
    return [
        ComplaintResponse(
            id=str(complaint.id),
            category=complaint.category.value,
            title=complaint.title,
            description=complaint.description,
            status=complaint.status.value,
            created_at=complaint.created_at
        )
        for complaint in complaints
    ]


@router.post("", response_model=ComplaintResponse, status_code=status.HTTP_201_CREATED)
async def create_complaint(
    complaint_data: ComplaintCreate,
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """Create complaint"""
    complaint = Complaint(
        user_id=current_user.id,
        category=ComplaintCategory(complaint_data.category),
        title=complaint_data.title,
        description=complaint_data.description,
        status=ComplaintStatus.PENDING
    )
    
    db.add(complaint)
    await db.commit()
    await db.refresh(complaint)
    
    return ComplaintResponse(
        id=str(complaint.id),
        category=complaint.category.value,
        title=complaint.title,
        description=complaint.description,
        status=complaint.status.value,
        created_at=complaint.created_at
    )
