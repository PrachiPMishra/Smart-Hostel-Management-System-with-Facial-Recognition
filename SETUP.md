# Hostel Management App - Quick Setup Guide

## 🚀 Quick Start (5 minutes)

### Prerequisites
- Docker Desktop installed
- Flutter SDK 3.0+ (for mobile app)
- Git

### Step 1: Clone and Start Services

```bash
cd C:\Users\nagar\CascadeProjects\hostel-management-app

# Start all backend services
docker-compose up -d

# Wait for services to be healthy (30 seconds)
docker-compose ps
```

### Step 2: Initialize Database

```bash
cd server

# Install Python dependencies
pip install -r requirements.txt

# Run migrations
python -m alembic upgrade head

# Create test user
python -c "
from app.core.database import AsyncSessionLocal
from app.models.user import User
from app.core.security import get_password_hash
import asyncio

async def create_user():
    async with AsyncSessionLocal() as db:
        user = User(
            email='admin@hostel.com',
            name='Admin User',
            password_hash=get_password_hash('admin123'),
            role='admin',
            is_active=True
        )
        db.add(user)
        await db.commit()
        print('Test user created: admin@hostel.com / admin123')

asyncio.run(create_user())
"
```

### Step 3: Run Flutter App

```bash
cd client

# Get dependencies
flutter pub get

# Run on emulator/device
flutter run
```

### Step 4: Test Login

Open the Flutter app and login with:
- **Email**: `admin@hostel.com`
- **Password**: `admin123`

## 📱 What You Get

### Flutter Mobile App
- **Login & Authentication** with JWT
- **Face Enrollment** with consent flow
- **Attendance Tracking** with history and stats
- **Mess Management** with balance and records
- **Leave Requests** creation and tracking
- **Complaints** submission and status
- **Emergency Alerts** with SOS button
- **Parent Portal** for student monitoring
- **Profile Management**

### FastAPI Backend
- RESTful API with OpenAPI docs at `http://localhost:8000/api/docs`
- PostgreSQL with pgvector for embeddings
- JWT authentication
- S3/MinIO for media storage
- Redis for caching
- Full CRUD for all features

### Recognition Worker
- RTSP camera stream processing
- Face detection and recognition
- Attendance automation
- Unknown face detection
- Configurable recognition adapter for your model

### Infrastructure
- Docker Compose for local dev
- Kubernetes manifests for production
- CI/CD pipeline with GitHub Actions
- Monitoring and logging setup

## 🔑 Default Credentials

| Service | URL | Username | Password |
|---------|-----|----------|----------|
| Backend API | http://localhost:8000 | admin@hostel.com | admin123 |
| API Docs | http://localhost:8000/api/docs | - | - |
| PostgreSQL | localhost:5432 | hostel_user | hostel_pass_dev |
| Redis | localhost:6379 | - | - |
| MinIO Console | http://localhost:9001 | minioadmin | minioadmin |

## 📂 Project Structure

```
hostel-management-app/
├── client/                 # Flutter mobile app
│   ├── lib/
│   │   ├── core/          # Core utilities, theme, routing
│   │   ├── features/      # Feature modules
│   │   └── main.dart
│   └── pubspec.yaml
│
├── server/                # FastAPI backend
│   ├── app/
│   │   ├── api/          # API endpoints
│   │   ├── core/         # Config, security, database
│   │   ├── models/       # Database models
│   │   └── main.py
│   └── requirements.txt
│
├── worker/               # Recognition worker
│   ├── worker.py
│   ├── recognition_adapter.py
│   └── config.py
│
├── infra/               # Infrastructure
│   └── kubernetes/      # K8s manifests
│
├── docs/                # Documentation
│   ├── API.md
│   └── DEPLOYMENT.md
│
├── docker-compose.yml   # Local dev environment
└── Makefile            # Helper commands
```

## 🎯 Next Steps

### 1. Implement Recognition Model

The recognition adapter at `worker/recognition_adapter.py` is a template. Implement it with your trained model:

```python
class RecognitionAdapter:
    def load(self, model_path: str):
        # Load your model (PyTorch, TensorFlow, etc.)
        pass
    
    def predict(self, image_bytes: np.ndarray):
        # Extract embedding and match against database
        pass
```

### 2. Configure Cameras

Edit `worker/config.py` with your RTSP camera URLs:

```python
CAMERA_STREAMS = {
    "entrance": "rtsp://admin:pass@192.168.1.100:554/stream",
    "mess_hall": "rtsp://admin:pass@192.168.1.101:554/stream",
}
```

### 3. Customize Features

- Modify Flutter screens in `client/lib/features/`
- Add new API endpoints in `server/app/api/v1/endpoints/`
- Adjust database schema in `server/app/models/`

### 4. Deploy to Production

See `docs/DEPLOYMENT.md` for:
- Kubernetes deployment
- SSL/TLS setup
- Security hardening
- Monitoring configuration

## 🛠️ Development Commands

```bash
# Start all services
make start

# Stop all services
make stop

# Run tests
make test

# Run migrations
make migrate

# Code formatting
make lint

# Clean build artifacts
make clean
```

## 📊 Database Schema

The system includes these main tables:

- **users** - User accounts with roles
- **embeddings** - Face embeddings (pgvector)
- **attendance_events** - Attendance records
- **unknown_faces** - Unrecognized faces
- **leave_requests** - Leave applications
- **mess_records** - Meal tracking
- **mess_balances** - User balances
- **complaints** - Issue tracking
- **emergency_alerts** - SOS alerts
- **emergency_contacts** - Contact information

## 🔒 Security Features

✅ **Privacy & Consent**
- Explicit consent required before face enrollment
- GDPR-compliant data deletion
- Encrypted embeddings at rest
- TLS for all connections

✅ **Authentication & Authorization**
- JWT-based authentication
- Role-based access control (RBAC)
- Secure password hashing (bcrypt)
- Token refresh mechanism

✅ **Data Protection**
- Encrypted face embeddings
- Secure S3 storage
- Audit logging
- Data retention policies

## 🐛 Troubleshooting

### Docker services not starting
```bash
docker-compose down -v
docker-compose up -d --force-recreate
```

### Database connection errors
```bash
# Check PostgreSQL is running
docker-compose ps postgres

# Check logs
docker-compose logs postgres
```

### Flutter build errors
```bash
cd client
flutter clean
flutter pub get
flutter pub upgrade
```

### Worker camera connection issues
```bash
# Test RTSP stream
ffplay rtsp://your-camera-url

# Check worker logs
docker-compose logs worker
```

## 📞 Support

- **Issues**: Create a GitHub issue
- **Documentation**: Check `/docs` folder
- **API Reference**: http://localhost:8000/api/docs

## 📝 License

MIT License - See LICENSE file

---

**Generated by AI Model v1.0.0** | Timestamp: 2025-10-29T16:08:00Z
