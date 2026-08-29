"""Leave management endpoints"""

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from datetime import datetime
from typing import List
from uuid import UUID

from app.core.database import get_db
from app.core.security import get_current_active_user
from app.models.user import User
from app.models.leave import LeaveRequest, LeaveStatus
from pydantic import BaseModel

router = APIRouter()


class LeaveRequestCreate(BaseModel):
    start_date: datetime
    end_date: datetime
    reason: str


class LeaveRequestResponse(BaseModel):
    id: str
    start_date: datetime
    end_date: datetime
    reason: str
    status: str
    created_at: datetime
    
    class Config:
        from_attributes = True


@router.get("/requests", response_model=List[LeaveRequestResponse])
async def get_leave_requests(
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """Get leave requests"""
    result = await db.execute(
        select(LeaveRequest)
        .where(LeaveRequest.user_id == current_user.id)
        .order_by(LeaveRequest.created_at.desc())
    )
    requests = result.scalars().all()
    
    return [
        LeaveRequestResponse(
            id=str(req.id),
            start_date=req.start_date,
            end_date=req.end_date,
            reason=req.reason,
            status=req.status.value,
            created_at=req.created_at
        )
        for req in requests
    ]


@router.post("/requests", response_model=LeaveRequestResponse, status_code=status.HTTP_201_CREATED)
async def create_leave_request(
    leave_data: LeaveRequestCreate,
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """Create leave request"""
    # Validate dates
    if leave_data.start_date >= leave_data.end_date:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="End date must be after start date"
        )
    
    leave_request = LeaveRequest(
        user_id=current_user.id,
        start_date=leave_data.start_date,
        end_date=leave_data.end_date,
        reason=leave_data.reason,
        status=LeaveStatus.PENDING
    )
    
    db.add(leave_request)
    await db.commit()
    await db.refresh(leave_request)
    
    return LeaveRequestResponse(
        id=str(leave_request.id),
        start_date=leave_request.start_date,
        end_date=leave_request.end_date,
        reason=leave_request.reason,
        status=leave_request.status.value,
        created_at=leave_request.created_at
    )


@router.delete("/requests/{request_id}")
async def cancel_leave_request(
    request_id: UUID,
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """Cancel leave request"""
    result = await db.execute(
        select(LeaveRequest).where(
            LeaveRequest.id == request_id,
            LeaveRequest.user_id == current_user.id
        )
    )
    leave_request = result.scalar_one_or_none()
    
    if not leave_request:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Leave request not found"
        )
    
    if leave_request.status != LeaveStatus.PENDING:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Can only cancel pending requests"
        )
    
    leave_request.status = LeaveStatus.CANCELLED
    await db.commit()
    
    return {"message": "Leave request cancelled"}
