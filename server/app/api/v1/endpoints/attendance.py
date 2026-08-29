"""Attendance endpoints"""

from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func, and_
from datetime import datetime, timedelta
from typing import List, Optional

from app.core.database import get_db
from app.core.security import get_current_active_user
from app.models.user import User
from app.models.attendance import AttendanceEvent
from pydantic import BaseModel

router = APIRouter()


class AttendanceResponse(BaseModel):
    id: str
    timestamp: datetime
    method: str
    confidence: float
    photo_url: Optional[str]
    
    class Config:
        from_attributes = True


class AttendanceStats(BaseModel):
    percentage: float
    present: int
    total: int


@router.get("/history", response_model=List[AttendanceResponse])
async def get_attendance_history(
    start_date: Optional[str] = Query(None),
    end_date: Optional[str] = Query(None),
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """Get attendance history"""
    query = select(AttendanceEvent).where(AttendanceEvent.user_id == current_user.id)
    
    if start_date:
        query = query.where(AttendanceEvent.timestamp >= datetime.fromisoformat(start_date))
    if end_date:
        query = query.where(AttendanceEvent.timestamp <= datetime.fromisoformat(end_date))
    
    query = query.order_by(AttendanceEvent.timestamp.desc())
    
    result = await db.execute(query)
    events = result.scalars().all()
    
    return [
        AttendanceResponse(
            id=str(event.id),
            timestamp=event.timestamp,
            method=event.method.value,
            confidence=event.confidence,
            photo_url=event.photo_url
        )
        for event in events
    ]


@router.get("/stats", response_model=AttendanceStats)
async def get_attendance_stats(
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """Get attendance statistics"""
    # Calculate for current month
    now = datetime.utcnow()
    start_of_month = datetime(now.year, now.month, 1)
    
    # Count present days
    result = await db.execute(
        select(func.count(func.distinct(func.date(AttendanceEvent.timestamp))))
        .where(
            and_(
                AttendanceEvent.user_id == current_user.id,
                AttendanceEvent.timestamp >= start_of_month
            )
        )
    )
    present = result.scalar() or 0
    
    # Total days in month so far
    total = (now - start_of_month).days + 1
    
    percentage = (present / total * 100) if total > 0 else 0.0
    
    return AttendanceStats(
        percentage=percentage,
        present=present,
        total=total
    )
