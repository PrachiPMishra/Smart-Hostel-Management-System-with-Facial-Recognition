"""Mess management endpoints"""

from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func, and_
from datetime import datetime
from typing import List

from app.core.database import get_db
from app.core.security import get_current_active_user
from app.models.user import User
from app.models.mess import MessRecord, MessBalance
from pydantic import BaseModel

router = APIRouter()


class MessRecordResponse(BaseModel):
    id: str
    meal_type: str
    amount: float
    timestamp: datetime
    
    class Config:
        from_attributes = True


class MessStatsResponse(BaseModel):
    balance: float
    monthly_spent: float
    meals_count: int


@router.get("/records", response_model=List[MessRecordResponse])
async def get_mess_records(
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """Get mess records"""
    result = await db.execute(
        select(MessRecord)
        .where(MessRecord.user_id == current_user.id)
        .order_by(MessRecord.timestamp.desc())
        .limit(50)
    )
    records = result.scalars().all()
    
    return [
        MessRecordResponse(
            id=str(record.id),
            meal_type=record.meal_type.value,
            amount=record.amount,
            timestamp=record.timestamp
        )
        for record in records
    ]


@router.get("/stats", response_model=MessStatsResponse)
async def get_mess_stats(
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """Get mess statistics"""
    # Get balance
    result = await db.execute(
        select(MessBalance).where(MessBalance.user_id == current_user.id)
    )
    balance_record = result.scalar_one_or_none()
    balance = balance_record.balance if balance_record else 0.0
    
    # Get monthly spending
    now = datetime.utcnow()
    start_of_month = datetime(now.year, now.month, 1)
    
    result = await db.execute(
        select(func.sum(MessRecord.amount), func.count(MessRecord.id))
        .where(
            and_(
                MessRecord.user_id == current_user.id,
                MessRecord.timestamp >= start_of_month
            )
        )
    )
    row = result.one()
    monthly_spent = float(row[0] or 0)
    meals_count = int(row[1] or 0)
    
    return MessStatsResponse(
        balance=balance,
        monthly_spent=monthly_spent,
        meals_count=meals_count
    )
