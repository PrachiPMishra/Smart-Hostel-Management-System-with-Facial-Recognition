"""Emergency endpoints"""

from fastapi import APIRouter, Depends, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from typing import List

from app.core.database import get_db
from app.core.security import get_current_active_user
from app.models.user import User
from app.models.emergency import EmergencyAlert, EmergencyContact
from pydantic import BaseModel

router = APIRouter()


class EmergencyAlertCreate(BaseModel):
    location: str
    timestamp: str


class EmergencyContactResponse(BaseModel):
    id: str
    name: str
    relationship: str
    phone: str
    email: str | None
    
    class Config:
        from_attributes = True


@router.post("/alert", status_code=status.HTTP_201_CREATED)
async def trigger_emergency_alert(
    alert_data: EmergencyAlertCreate,
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """Trigger emergency alert"""
    alert = EmergencyAlert(
        user_id=current_user.id,
        location=alert_data.location,
        resolved=False
    )
    
    db.add(alert)
    await db.commit()
    
    # TODO: Send notifications to emergency contacts, wardens, security
    
    return {"message": "Emergency alert triggered", "alert_id": str(alert.id)}


@router.get("/contacts", response_model=List[EmergencyContactResponse])
async def get_emergency_contacts(
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """Get emergency contacts"""
    result = await db.execute(
        select(EmergencyContact).where(EmergencyContact.user_id == current_user.id)
    )
    contacts = result.scalars().all()
    
    return [
        EmergencyContactResponse(
            id=str(contact.id),
            name=contact.name,
            relationship=contact.relationship or "",
            phone=contact.phone,
            email=contact.email
        )
        for contact in contacts
    ]
