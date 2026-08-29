"""Face recognition endpoints"""

from fastapi import APIRouter, Depends, UploadFile, File
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from typing import List

from app.core.database import get_db
from app.core.security import get_current_active_user
from app.models.user import User
from app.models.attendance import UnknownFace
from pydantic import BaseModel

router = APIRouter()


class RecognitionResult(BaseModel):
    matched: bool
    user_id: str | None
    confidence: float
    embedding_id: str | None


class UnknownFaceResponse(BaseModel):
    id: str
    camera_id: str
    image_url: str | None
    handled: bool
    created_at: str
    
    class Config:
        from_attributes = True


@router.post("/face-crop", response_model=RecognitionResult)
async def recognize_face(
    camera_id: str,
    image: UploadFile = File(...),
    db: AsyncSession = Depends(get_db)
):
    """Recognize face from image crop
    
    This endpoint is called by the recognition worker to match faces
    against enrolled embeddings.
    """
    # TODO: Extract embedding from image
    # TODO: Search for matching embedding in database
    # TODO: If match found, return user_id
    # TODO: If no match, store as unknown face
    
    # Placeholder response
    return RecognitionResult(
        matched=False,
        user_id=None,
        confidence=0.0,
        embedding_id=None
    )


@router.get("/unknown-faces", response_model=List[UnknownFaceResponse])
async def get_unknown_faces(
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """Get list of unknown faces detected (admin/warden only)"""
    # TODO: Add role-based access control
    
    result = await db.execute(
        select(UnknownFace)
        .where(UnknownFace.handled == False)
        .order_by(UnknownFace.created_at.desc())
        .limit(50)
    )
    faces = result.scalars().all()
    
    return [
        UnknownFaceResponse(
            id=str(face.id),
            camera_id=face.camera_id,
            image_url=face.image_url,
            handled=face.handled,
            created_at=face.created_at.isoformat()
        )
        for face in faces
    ]
