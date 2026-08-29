"""Face embedding database models"""

from sqlalchemy import Column, String, DateTime, ForeignKey
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.sql import func
from pgvector.sqlalchemy import Vector
import uuid

from app.core.database import Base


class FaceEmbedding(Base):
    """Face embedding model with pgvector support"""
    __tablename__ = "embeddings"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False, index=True)
    
    # Vector embedding (512 dimensions - adjust based on your model)
    vector = Column(Vector(512))
    
    # Model metadata
    model_version = Column(String(50), default="v1.0")
    
    # Encrypted embedding (if encryption enabled)
    encrypted_vector = Column(String(5000))
    
    # Timestamps
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    def __repr__(self):
        return f"<FaceEmbedding {self.user_id}>"
