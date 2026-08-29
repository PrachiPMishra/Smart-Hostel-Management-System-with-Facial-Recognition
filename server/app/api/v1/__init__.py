"""API v1 router"""

from fastapi import APIRouter

from app.api.v1.endpoints import auth, users, enrollment, attendance, mess, leave, complaints, emergency, recognition

api_router = APIRouter()

api_router.include_router(auth.router, prefix="/auth", tags=["Authentication"])
api_router.include_router(users.router, prefix="/users", tags=["Users"])
api_router.include_router(enrollment.router, prefix="/enrollment", tags=["Enrollment"])
api_router.include_router(attendance.router, prefix="/attendance", tags=["Attendance"])
api_router.include_router(mess.router, prefix="/mess", tags=["Mess"])
api_router.include_router(leave.router, prefix="/leave", tags=["Leave"])
api_router.include_router(complaints.router, prefix="/complaints", tags=["Complaints"])
api_router.include_router(emergency.router, prefix="/emergency", tags=["Emergency"])
api_router.include_router(recognition.router, prefix="/recognition", tags=["Recognition"])
