# API Documentation

Hostel Management System REST API v1.0

## Base URL

```
http://localhost:8000/api/v1
```

## Authentication

All protected endpoints require a Bearer token in the Authorization header:

```
Authorization: Bearer <access_token>
```

## Endpoints

### Authentication

#### POST /auth/login
Login with email and password.

**Request:**
```json
{
  "username": "user@example.com",
  "password": "password123"
}
```

**Response:**
```json
{
  "access_token": "eyJhbG...",
  "refresh_token": "eyJhbG...",
  "token_type": "bearer"
}
```

#### POST /auth/refresh
Refresh access token.

**Request:**
```json
{
  "refresh_token": "eyJhbG..."
}
```

#### POST /auth/register
Register new user.

**Request:**
```json
{
  "email": "user@example.com",
  "name": "John Doe",
  "password": "password123",
  "role": "student"
}
```

### Users

#### GET /users/me
Get current user profile.

**Response:**
```json
{
  "id": "uuid",
  "email": "user@example.com",
  "name": "John Doe",
  "role": "student",
  "enrolled_face": true,
  "hostel_id": "uuid",
  "room_no": "101"
}
```

#### PUT /users/me
Update current user profile.

**Request:**
```json
{
  "name": "John Updated",
  "phone": "+1234567890"
}
```

### Enrollment

#### POST /enrollment/consent
Give consent for facial recognition.

**Response:**
```json
{
  "message": "Consent recorded",
  "consent_given_at": "2025-10-29T16:08:00Z"
}
```

#### POST /enrollment/face
Enroll face image (multipart/form-data).

**Request:**
- `image`: Image file

**Response:**
```json
{
  "message": "Face enrolled successfully",
  "enrolled_face": true
}
```

#### DELETE /enrollment/revoke
Revoke consent and delete all face data (GDPR compliance).

### Attendance

#### GET /attendance/history
Get attendance history.

**Query Parameters:**
- `start_date`: ISO datetime (optional)
- `end_date`: ISO datetime (optional)

**Response:**
```json
[
  {
    "id": "uuid",
    "timestamp": "2025-10-29T09:00:00Z",
    "method": "face",
    "confidence": 0.95,
    "photo_url": "https://..."
  }
]
```

#### GET /attendance/stats
Get attendance statistics.

**Response:**
```json
{
  "percentage": 95.5,
  "present": 20,
  "total": 21
}
```

### Mess

#### GET /mess/records
Get mess meal records.

**Response:**
```json
[
  {
    "id": "uuid",
    "meal_type": "breakfast",
    "amount": 50.0,
    "timestamp": "2025-10-29T08:30:00Z"
  }
]
```

#### GET /mess/stats
Get mess statistics.

**Response:**
```json
{
  "balance": 450.00,
  "monthly_spent": 1200.00,
  "meals_count": 45
}
```

### Leave

#### GET /leave/requests
Get leave requests.

**Response:**
```json
[
  {
    "id": "uuid",
    "start_date": "2025-11-01T00:00:00Z",
    "end_date": "2025-11-03T23:59:59Z",
    "reason": "Family emergency",
    "status": "pending",
    "created_at": "2025-10-29T10:00:00Z"
  }
]
```

#### POST /leave/requests
Create leave request.

**Request:**
```json
{
  "start_date": "2025-11-01T00:00:00Z",
  "end_date": "2025-11-03T23:59:59Z",
  "reason": "Family emergency"
}
```

#### DELETE /leave/requests/{id}
Cancel leave request.

### Complaints

#### GET /complaints
Get complaints.

**Response:**
```json
[
  {
    "id": "uuid",
    "category": "maintenance",
    "title": "Broken AC",
    "description": "AC not working in room 101",
    "status": "pending",
    "created_at": "2025-10-29T14:00:00Z"
  }
]
```

#### POST /complaints
Create complaint.

**Request:**
```json
{
  "category": "maintenance",
  "title": "Broken AC",
  "description": "AC not working in room 101"
}
```

### Emergency

#### POST /emergency/alert
Trigger emergency alert.

**Request:**
```json
{
  "location": "Room 101",
  "timestamp": "2025-10-29T16:00:00Z"
}
```

#### GET /emergency/contacts
Get emergency contacts.

### Recognition

#### POST /recognition/face-crop
Recognize face from image (used by worker).

**Request (multipart/form-data):**
- `camera_id`: Camera identifier
- `image`: Face image

**Response:**
```json
{
  "matched": true,
  "user_id": "uuid",
  "confidence": 0.92,
  "embedding_id": "uuid"
}
```

#### GET /recognition/unknown-faces
Get unknown faces detected (admin/warden only).

## Error Responses

All endpoints may return the following error responses:

### 400 Bad Request
```json
{
  "detail": "Invalid input data"
}
```

### 401 Unauthorized
```json
{
  "detail": "Could not validate credentials"
}
```

### 403 Forbidden
```json
{
  "detail": "Insufficient permissions"
}
```

### 404 Not Found
```json
{
  "detail": "Resource not found"
}
```

### 500 Internal Server Error
```json
{
  "detail": "Internal server error"
}
```

## Rate Limiting

API endpoints are rate-limited to:
- 100 requests per minute for authenticated users
- 20 requests per minute for unauthenticated requests

## Webhooks

The system can send webhooks for the following events:
- `attendance.marked`: When attendance is recorded
- `leave.approved`: When leave is approved
- `emergency.triggered`: When emergency alert is triggered
- `unknown_face.detected`: When unknown face is detected

Configure webhooks in the admin panel.
