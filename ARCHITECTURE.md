# System Architecture

## Overview

The Hostel Management System is a microservices-based application with facial recognition for automated attendance tracking.

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                       Flutter Client                         │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐       │
│  │Attendance│ │   Mess   │ │  Leave   │ │Emergency │       │
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘       │
│       │             │             │             │            │
└───────┼─────────────┼─────────────┼─────────────┼───────────┘
        │             │             │             │
        └─────────────┴─────────────┴─────────────┘
                          │
                     HTTP/REST
                          │
┌─────────────────────────▼─────────────────────────────────┐
│                   FastAPI Backend                          │
│  ┌──────────────────────────────────────────────────────┐ │
│  │ API Endpoints (Auth, Users, Attendance, Mess, etc.)  │ │
│  └──────────────────────────────────────────────────────┘ │
│  ┌──────────────┐  ┌──────────────┐  ┌────────────────┐  │
│  │ Auth Service │  │   Business   │  │  Recognition   │  │
│  │   (JWT)      │  │    Logic     │  │   Integration  │  │
│  └──────────────┘  └──────────────┘  └────────────────┘  │
└────────┬────────────────┬────────────────┬────────────────┘
         │                │                │
    ┌────▼────┐      ┌────▼────┐     ┌────▼─────┐
    │PostgreSQL│      │  Redis  │     │ MinIO/S3 │
    │(pgvector)│      │ (Cache) │     │ (Media)  │
    └──────────┘      └─────────┘     └──────────┘
         ▲
         │
    ┌────┴────────────────────────────────────────────┐
    │          Recognition Worker                     │
    │  ┌──────────────────────────────────────────┐  │
    │  │  Camera Stream Processor                 │  │
    │  │  ┌─────────┐  ┌────────┐  ┌──────────┐  │  │
    │  │  │  RTSP   │  │  Face  │  │ Embedding│  │  │
    │  │  │ Capture │→ │Detection│→ │Extraction│  │  │
    │  │  └─────────┘  └────────┘  └──────────┘  │  │
    │  └──────────────────────────────────────────┘  │
    │  ┌──────────────────────────────────────────┐  │
    │  │  Recognition Adapter (User Model)        │  │
    │  └──────────────────────────────────────────┘  │
    └─────────────────────────────────────────────────┘
              ▲
              │
         RTSP Streams
              │
    ┌─────────┴──────────┐
    │  CCTV Cameras      │
    │  (Entrance, Mess,  │
    │   Corridors, etc.) │
    └────────────────────┘
```

## Components

### 1. Flutter Client (Mobile App)

**Technology**: Flutter/Dart
**Purpose**: Cross-platform mobile application for students, parents, and staff

**Features**:
- User authentication with JWT
- Face enrollment with camera integration
- Real-time attendance viewing
- Mess balance management
- Leave request submission
- Complaint filing
- Emergency SOS alerts
- Parent monitoring portal

**Key Libraries**:
- `flutter_riverpod` - State management
- `go_router` - Navigation
- `dio` - HTTP client
- `camera` - Camera access
- `google_mlkit_face_detection` - Face detection

### 2. FastAPI Backend

**Technology**: Python FastAPI
**Purpose**: RESTful API server handling business logic

**Responsibilities**:
- User authentication and authorization
- CRUD operations for all entities
- Database transactions
- File storage coordination
- API documentation (OpenAPI)
- Business rule enforcement

**Architecture Patterns**:
- Repository pattern for data access
- Dependency injection
- Async/await for concurrency
- Pydantic for validation

**Database Models**:
- Users, Embeddings, Attendance
- Leave Requests, Mess Records
- Complaints, Emergency Alerts

### 3. Recognition Worker

**Technology**: Python with OpenCV
**Purpose**: Process CCTV streams for facial recognition

**Pipeline**:
1. **Stream Capture**: Connect to RTSP camera feeds
2. **Face Detection**: Detect faces in frames
3. **Embedding Extraction**: Generate face embeddings
4. **Matching**: Compare against database
5. **Reporting**: Send results to backend

**Recognition Adapter**:
- Standardized interface for custom models
- Support for PyTorch, TensorFlow, ONNX
- Pluggable architecture

### 4. Database Layer

**PostgreSQL with pgvector**:
- Relational data (users, attendance, etc.)
- Vector embeddings for face matching
- ACID transactions
- Full-text search

**Redis**:
- Session caching
- Rate limiting
- Job queues
- Real-time pub/sub

**MinIO/S3**:
- Face images
- Unknown face clips
- Profile pictures
- Document attachments

## Data Flow

### Face Enrollment Flow

```
User → Flutter App → Backend API → Database
  1. Give consent
  2. Capture 5 face images
  3. Upload to backend
  4. Extract embeddings
  5. Store in pgvector
  6. Mark user as enrolled
```

### Attendance Recognition Flow

```
CCTV Camera → Worker → Backend → Database → Flutter App
  1. Camera streams RTSP
  2. Worker detects face
  3. Extract embedding
  4. Match in database
  5. Report attendance
  6. User sees in app
```

### Unknown Face Flow

```
CCTV Camera → Worker → Backend → Alert System
  1. Detect unknown face
  2. Save image/clip
  3. Flag for review
  4. Notify warden
  5. Manual verification
```

## Security Architecture

### Authentication Flow

```
Client → Login → Backend → JWT Token → Client
                    ↓
              Verify Password
                    ↓
              Generate Token
              (access + refresh)
                    ↓
              Return to Client
                    ↓
         Store in Secure Storage
```

### Data Encryption

- **At Rest**: Face embeddings encrypted in database
- **In Transit**: TLS 1.3 for all connections
- **Tokens**: JWT with HMAC-SHA256
- **Passwords**: bcrypt with salt

### Privacy Compliance

- Explicit consent required
- Data deletion API (GDPR)
- Audit logging
- Retention policies
- Opt-out mechanisms

## Scalability

### Horizontal Scaling

- **Backend**: Stateless, scale with load balancer
- **Worker**: Multi-instance for multiple cameras
- **Database**: Read replicas, connection pooling
- **Cache**: Redis cluster

### Performance Optimizations

- Database indexing on frequent queries
- Redis caching for hot data
- Image compression and CDN
- Batch processing for embeddings
- Async I/O throughout stack

## Deployment

### Local Development
- Docker Compose orchestration
- Hot reload for rapid iteration
- Mock data generators

### Production (Kubernetes)
- Horizontal Pod Autoscaling
- Rolling updates
- Health checks and readiness probes
- Persistent volumes for data
- Ingress with SSL termination

## Monitoring & Observability

### Metrics
- Prometheus for metrics collection
- Grafana dashboards
- Custom business metrics

### Logging
- Structured JSON logging
- ELK stack (Elasticsearch, Logstash, Kibana)
- Log aggregation from all services

### Tracing
- OpenTelemetry for distributed tracing
- Request correlation IDs

### Alerts
- Recognition accuracy drops
- High unknown face rate
- System resource exhaustion
- Failed authentication attempts

## Disaster Recovery

### Backup Strategy
- Daily database backups
- S3 cross-region replication
- Point-in-time recovery
- Configuration as code

### High Availability
- Multi-zone deployment
- Database failover
- Circuit breakers
- Graceful degradation

## Future Enhancements

1. **AI Improvements**
   - Liveness detection
   - Age verification
   - Emotion recognition
   - Better low-light performance

2. **Features**
   - Visitor management
   - Room allocation
   - Fee management
   - Inventory tracking

3. **Integrations**
   - Biometric devices
   - Access control systems
   - Payment gateways
   - SMS/Email notifications

4. **Analytics**
   - Attendance patterns
   - Mess usage analytics
   - Predictive models
   - Dashboard insights
