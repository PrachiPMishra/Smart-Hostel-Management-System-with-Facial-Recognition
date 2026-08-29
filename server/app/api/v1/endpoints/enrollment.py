"""Face enrollment endpoints"""

from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, status
from sqlalchemy.ext.asyncio import AsyncSession
from datetime import datetime
from sqlalchemy import select

from app.core.database import get_db
from app.core.security import get_current_active_user
from app.models.user import User
from app.models.embedding import FaceEmbedding

router = APIRouter()


@router.post("/consent")
async def give_consent(
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """Give consent for facial recognition"""
    current_user.consent_given_at = datetime.utcnow()
    await db.commit()
    
    return {"message": "Consent recorded", "consent_given_at": current_user.consent_given_at}


@router.post("/face")
async def enroll_face(
    image: UploadFile = File(...),
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """Enroll face image"""
    # Check consent
    if not current_user.consent_given_at:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Consent not given. Please give consent first."
        )
    
    # TODO: Process image and extract embedding
    # This would call the recognition model
    # For now, just mark as enrolled
    
    # Save image to S3/MinIO
    # Extract face embedding
    # Store embedding in database
    
    # Placeholder: Mark user as enrolled
    current_user.enrolled_face = True
    await db.commit()
    
    return {
        "message": "Face enrolled successfully",
        "enrolled_face": True
    }


@router.get("/status")
async def get_enrollment_status(
    current_user: User = Depends(get_current_active_user)
):
    """Get enrollment status"""
    return {
        "consent_given": current_user.consent_given_at is not None,
        "consent_given_at": current_user.consent_given_at,
        "enrolled_face": current_user.enrolled_face
    }


@router.delete("/revoke")
async def revoke_consent_and_delete_data(
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """Revoke consent and delete all face data (GDPR compliance)"""
    # Delete all embeddings
    result = await db.execute(
        select(FaceEmbedding).where(FaceEmbedding.user_id == current_user.id)
    )
    embeddings = result.scalars().all()
    
    for embedding in embeddings:
        await db.delete(embedding)
    
    # Reset user enrollment status
    current_user.enrolled_face = False
    current_user.consent_given_at = None
    
    await db.commit()
    
    return {
        "message": "Consent revoked and face data deleted",
        "deleted_embeddings": len(embeddings)
    }
