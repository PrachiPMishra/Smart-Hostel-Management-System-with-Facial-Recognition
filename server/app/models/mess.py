"""Mess management database models"""

from sqlalchemy import Column, String, DateTime, Float, ForeignKey, Enum as SQLEnum
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.sql import func
import uuid
import enum

from app.core.database import Base


class MealType(str, enum.Enum):
    """Meal types"""
    BREAKFAST = "breakfast"
    LUNCH = "lunch"
    DINNER = "dinner"
    SNACK = "snack"


class MessRecord(Base):
    """Mess record model"""
    __tablename__ = "mess_records"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False, index=True)
    
    # Meal details
    meal_type = Column(SQLEnum(MealType), nullable=False)
    amount = Column(Float, default=0.0)
    
    # Timestamp
    timestamp = Column(DateTime(timezone=True), server_default=func.now(), index=True)
    
    def __repr__(self):
        return f"<MessRecord {self.user_id} {self.meal_type}>"


class MessBalance(Base):
    """Mess balance model"""
    __tablename__ = "mess_balances"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), unique=True, nullable=False)
    
    # Balance
    balance = Column(Float, default=0.0)
    
    # Timestamps
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    
    def __repr__(self):
        return f"<MessBalance {self.user_id}: {self.balance}>"
