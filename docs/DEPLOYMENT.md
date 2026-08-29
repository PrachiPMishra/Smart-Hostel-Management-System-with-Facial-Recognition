# Deployment Guide

## Prerequisites

- Docker and Docker Compose
- Kubernetes cluster (for production)
- PostgreSQL 14+ with pgvector extension
- MinIO or S3 for object storage
- Domain name and SSL certificate

## Local Development

### 1. Clone Repository

```bash
git clone <repository-url>
cd hostel-management-app
```

### 2. Start Services with Docker Compose

```bash
docker-compose up -d
```

This starts:
- PostgreSQL with pgvector
- Redis
- MinIO (S3-compatible storage)
- Backend API
- Recognition Worker

### 3. Run Migrations

```bash
cd server
python -m alembic upgrade head
```

### 4. Run Flutter App

```bash
cd client
flutter pub get
flutter run
```

## Production Deployment

### Kubernetes Deployment

#### 1. Create Namespace

```bash
kubectl apply -f infra/kubernetes/namespace.yaml
```

#### 2. Configure Secrets

```bash
# Create secrets
kubectl create secret generic postgres-secret \
  --from-literal=POSTGRES_PASSWORD=<strong-password> \
  -n hostel-management

kubectl create secret generic backend-secret \
  --from-literal=JWT_SECRET=<jwt-secret> \
  --from-literal=S3_SECRET_KEY=<s3-secret> \
  -n hostel-management
```

#### 3. Deploy Database

```bash
kubectl apply -f infra/kubernetes/postgres.yaml
kubectl apply -f infra/kubernetes/redis.yaml
```

#### 4. Deploy Backend

```bash
kubectl apply -f infra/kubernetes/backend.yaml
```

#### 5. Deploy Worker

```bash
kubectl apply -f infra/kubernetes/worker.yaml
```

#### 6. Verify Deployment

```bash
kubectl get pods -n hostel-management
kubectl logs -f deployment/backend -n hostel-management
```

### DNS and SSL

Configure Ingress with cert-manager for automatic SSL:

```bash
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.0/cert-manager.yaml
```

## Security Checklist

- [ ] Change all default passwords
- [ ] Generate strong JWT secret
- [ ] Configure S3 bucket policies
- [ ] Enable TLS for all connections
- [ ] Set up firewall rules
- [ ] Configure CORS properly
- [ ] Enable rate limiting
- [ ] Set up monitoring and alerting
- [ ] Regular security scans
- [ ] Backup strategy in place

## Monitoring

Recommended tools:
- Prometheus for metrics
- Grafana for dashboards
- ELK stack for logs
- Sentry for error tracking

## Backup Strategy

```bash
# Database backup
kubectl exec -it postgres-pod -n hostel-management -- \
  pg_dump -U hostel_user hostel_db > backup.sql

# S3 backup
aws s3 sync s3://hostel-media s3://hostel-media-backup
```
