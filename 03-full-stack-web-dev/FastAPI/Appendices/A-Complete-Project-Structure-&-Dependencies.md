# Appendix A: Complete Project Structure & Dependencies

Welcome to Appendix A of the FastAPI Masterclass series! This comprehensive reference provides the complete project structure, all dependency specifications, and a detailed file-by-file breakdown of the entire codebase. Use this as your roadmap and reference as you build the application.

## Complete Project Structure

Here's the full directory tree of the finished application:

```
fastapi-masterclass/
├── .github/
│   └── workflows/
│       └── ci-cd.yml                    # GitHub Actions CI/CD pipeline
├── app/
│   ├── api/
│   │   └── v1/
│   │       ├── __init__.py
│   │       ├── api.py                   # Main v1 router
│   │       └── endpoints/
│   │           ├── __init__.py
│   │           ├── auth.py              # Authentication endpoints
│   │           ├── health.py            # Health check endpoints
│   │           ├── tasks.py             # Task management endpoints
│   │           ├── users.py             # User management endpoints
│   │           ├── projects.py          # Project management endpoints
│   │           └── upload.py            # File upload endpoints
│   ├── application/                     # Clean Architecture - Application Layer
│   │   ├── __init__.py
│   │   ├── dtos/
│   │   │   ├── __init__.py
│   │   │   └── task_dtos.py             # Task Data Transfer Objects
│   │   ├── interfaces/
│   │   │   ├── __init__.py
│   │   │   ├── repositories.py          # Repository interfaces
│   │   │   └── message_bus.py           # Message bus interface
│   │   ├── services/
│   │   │   ├── __init__.py
│   │   │   └── task_service.py          # Task application service
│   │   └── use_cases/
│   │       ├── __init__.py
│   │       └── task_use_cases.py        # Task use cases
│   ├── core/
│   │   ├── __init__.py
│   │   ├── config.py                    # Pydantic settings
│   │   ├── database.py                  # SQLAlchemy setup
│   │   ├── security.py                  # Authentication utilities
│   │   ├── exceptions.py                # Custom exceptions
│   │   ├── dependencies.py              # FastAPI dependencies
│   │   ├── celery_app.py                # Celery configuration
│   │   ├── redis.py                     # Redis client
│   │   ├── logging.py                   # Structured logging setup
│   │   └── audit.py                     # Audit logging
│   ├── crud/                            # Repository implementations
│   │   ├── __init__.py
│   │   ├── base.py                      # Base repository
│   │   ├── user.py                      # User repository
│   │   ├── task.py                      # Task repository
│   │   └── project.py                   # Project repository
│   ├── domain/                          # Clean Architecture - Domain Layer
│   │   ├── __init__.py
│   │   ├── entities/
│   │   │   ├── __init__.py
│   │   │   ├── task.py                  # Task domain entity
│   │   │   ├── user.py                  # User domain entity
│   │   │   ├── project.py               # Project domain entity
│   │   │   └── comment.py               # Comment domain entity
│   │   ├── value_objects/
│   │   │   ├── __init__.py
│   │   │   ├── task_status.py           # TaskStatus & TaskPriority enums
│   │   │   ├── email.py                 # Email value object
│   │   │   └── money.py                 # Money value object
│   │   └── events/
│   │       ├── __init__.py
│   │       └── task_events.py           # Domain events
│   ├── infrastructure/                  # Clean Architecture - Infrastructure Layer
│   │   ├── __init__.py
│   │   ├── persistence/
│   │   │   ├── __init__.py
│   │   │   ├── repositories/            # Repository implementations
│   │   │   │   ├── __init__.py
│   │   │   │   └── task_repository.py
│   │   │   └── models/                  # SQLAlchemy models
│   │   │       ├── __init__.py
│   │   │       ├── user.py
│   │   │       ├── task.py
│   │   │       ├── project.py
│   │   │       └── comment.py
│   │   └── external/
│   │       ├── __init__.py
│   │       ├── message_bus.py           # RabbitMQ implementation
│   │       ├── storage.py               # S3/local storage
│   │       └── elasticsearch.py         # Search implementation
│   ├── interfaces/                      # Clean Architecture - Interface Layer
│   │   ├── __init__.py
│   │   ├── api/
│   │   │   ├── __init__.py
│   │   │   ├── v1/
│   │   │   │   ├── __init__.py
│   │   │   │   ├── auth_controller.py
│   │   │   │   └── task_controller.py
│   │   │   └── middleware/
│   │   │       ├── __init__.py
│   │   │       ├── auth.py
│   │   │       ├── rate_limit.py
│   │   │       └── metrics.py
│   │   ├── schemas/                     # Pydantic schemas
│   │   │   ├── __init__.py
│   │   │   ├── auth.py
│   │   │   ├── user.py
│   │   │   ├── task.py
│   │   │   └── project.py
│   │   └── webhooks/
│   │       ├── __init__.py
│   │       └── task_webhooks.py
│   ├── middleware/
│   │   ├── __init__.py
│   │   ├── security.py                  # Security headers
│   │   ├── logging.py                   # Request logging
│   │   ├── metrics.py                   # Prometheus metrics
│   │   └── rate_limit.py                # Rate limiting
│   ├── models/                          # SQLAlchemy models (legacy)
│   │   ├── __init__.py
│   │   ├── base.py
│   │   ├── user.py
│   │   ├── task.py
│   │   ├── project.py
│   │   └── comment.py
│   ├── schemas/                         # Pydantic schemas (legacy)
│   │   ├── __init__.py
│   │   ├── auth.py
│   │   ├── user.py
│   │   └── task.py
│   ├── services/                        # Service layer (legacy)
│   │   ├── __init__.py
│   │   ├── base.py
│   │   ├── user.py
│   │   ├── task.py
│   │   ├── background.py
│   │   └── notification.py
│   ├── tasks/                           # Celery tasks
│   │   ├── __init__.py
│   │   ├── background.py
│   │   └── scheduled.py
│   ├── utils/
│   │   ├── __init__.py
│   │   ├── async_utils.py
│   │   └── validators.py
│   ├── websocket/
│   │   ├── __init__.py
│   │   ├── manager.py
│   │   └── handlers.py
│   └── main.py                          # FastAPI application entry point
├── alembic/                             # Database migrations
│   ├── versions/
│   │   └── [migration_files].py
│   ├── env.py
│   └── script.py.mako
├── tests/
│   ├── __init__.py
│   ├── conftest.py                      # Pytest fixtures
│   ├── test_unit/
│   │   ├── __init__.py
│   │   ├── test_models.py
│   │   ├── test_security.py
│   │   └── test_services.py
│   ├── test_integration/
│   │   ├── __init__.py
│   │   ├── test_api.py
│   │   └── test_database.py
│   ├── test_e2e/
│   │   ├── __init__.py
│   │   └── test_workflows.py
│   └── fixtures/
│       ├── __init__.py
│       └── test_data.py
├── scripts/
│   ├── deploy.sh                        # Deployment script
│   ├── health_check.py                  # Health check script
│   └── init-db.sql                      # Database initialization
├── nginx/
│   ├── nginx.conf
│   ├── conf.d/
│   │   └── fastapi.conf
│   └── ssl/
│       ├── cert.pem
│       └── key.pem
├── prometheus/
│   └── prometheus.yml
├── grafana/
│   ├── dashboards/
│   │   └── fastapi-dashboard.json
│   └── datasources/
│       └── prometheus.yaml
├── k8s/                                 # Kubernetes manifests
│   ├── namespace.yaml
│   ├── configmap.yaml
│   ├── secret.yaml
│   ├── postgres.yaml
│   ├── redis.yaml
│   ├── rabbitmq.yaml
│   ├── app.yaml
│   ├── celery.yaml
│   ├── ingress.yaml
│   └── hpa.yaml
├── .env.example                         # Environment variables template
├── .gitignore
├── .dockerignore
├── .pre-commit-config.yaml
├── Dockerfile                           # Multi-stage Docker build
├── docker-compose.yml                   # Development compose
├── docker-compose.prod.yml              # Production compose
├── requirements.txt                     # Python dependencies
├── requirements-dev.txt                 # Development dependencies
├── pyproject.toml                       # Python project configuration
├── pytest.ini                           # Pytest configuration
├── Makefile                             # Make commands
├── README.md
└── LICENSE
```

## Complete Dependency List

### requirements.txt - Production Dependencies

```txt
# ────────────────────────────────────────────────────────────────
# Core Framework
# ────────────────────────────────────────────────────────────────
fastapi==0.104.1
uvicorn[standard]==0.24.0
pydantic==2.4.2
pydantic-settings==2.0.3
python-multipart==0.0.6

# ────────────────────────────────────────────────────────────────
# Database
# ────────────────────────────────────────────────────────────────
sqlalchemy==2.0.23
alembic==1.12.1
asyncpg==0.29.0
psycopg2-binary==2.9.9

# ────────────────────────────────────────────────────────────────
# Security
# ────────────────────────────────────────────────────────────────
python-jose[cryptography]==3.3.0
passlib[bcrypt]==1.7.4
email-validator==2.1.0
oauthlib==3.2.2

# ────────────────────────────────────────────────────────────────
# Message Queue & Tasks
# ────────────────────────────────────────────────────────────────
celery==5.3.4
redis==5.0.1
aio-pika==9.3.1

# ────────────────────────────────────────────────────────────────
# Storage
# ────────────────────────────────────────────────────────────────
boto3==1.34.0
aiofiles==23.2.1
Pillow==10.1.0

# ────────────────────────────────────────────────────────────────
# Search
# ────────────────────────────────────────────────────────────────
elasticsearch==8.11.0

# ────────────────────────────────────────────────────────────────
# Monitoring & Logging
# ────────────────────────────────────────────────────────────────
prometheus-client==0.19.0
prometheus-fastapi-instrumentator==6.1.0
loguru==0.7.2
sentry-sdk==1.38.0

# ────────────────────────────────────────────────────────────────
# Utilities
# ────────────────────────────────────────────────────────────────
python-dotenv==1.0.0
httpx==0.25.1
tenacity==8.2.3
python-slugify==8.0.1
pytz==2023.3

# ────────────────────────────────────────────────────────────────
# Production Server
# ────────────────────────────────────────────────────────────────
gunicorn==21.2.0
```

### requirements-dev.txt - Development Dependencies

```txt
# ────────────────────────────────────────────────────────────────
# Testing
# ────────────────────────────────────────────────────────────────
pytest==7.4.3
pytest-asyncio==0.21.1
pytest-cov==4.1.0
pytest-mock==3.12.0
pytest-xdist==3.5.0
httpx==0.25.1
factory-boy==3.3.0
faker==20.1.0

# ────────────────────────────────────────────────────────────────
# Code Quality
# ────────────────────────────────────────────────────────────────
black==23.11.0
flake8==6.1.0
mypy==1.7.0
isort==5.12.0
pre-commit==3.5.0
pylint==3.0.2

# ────────────────────────────────────────────────────────────────
# Development Tools
# ────────────────────────────────────────────────────────────────
ipython==8.17.2
jupyter==1.0.0
notebook==7.0.6
watchfiles==0.21.0
python-lsp-server==1.9.0

# ────────────────────────────────────────────────────────────────
# Debugging
# ────────────────────────────────────────────────────────────────
debugpy==1.8.0
ptvsd==4.3.2

# ────────────────────────────────────────────────────────────────
# Documentation
# ────────────────────────────────────────────────────────────────
mkdocs==1.5.3
mkdocs-material==9.5.0
mkdocstrings==0.24.0

# ────────────────────────────────────────────────────────────────
# Code Analysis
# ────────────────────────────────────────────────────────────────
bandit==1.7.5
safety==2.3.5
radon==6.0.1
```

## Complete File-by-File Reference

### Core Files

**`app/core/config.py`** - Complete configuration with all settings:

```python
from typing import List, Optional
from pydantic_settings import BaseSettings
from pydantic import Field, field_validator
from functools import lru_cache

class Settings(BaseSettings):
    # Application
    APP_NAME: str = "FastAPI Masterclass"
    APP_VERSION: str = "1.0.0"
    APP_ENV: str = "development"
    DEBUG: bool = True
    
    # Security
    SECRET_KEY: str = Field(..., min_length=32)
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    REFRESH_TOKEN_EXPIRE_DAYS: int = 7
    
    # Database
    DATABASE_URL: str = Field(...)
    DATABASE_POOL_SIZE: int = 10
    DATABASE_MAX_OVERFLOW: int = 20
    DATABASE_ECHO: bool = False
    
    # Redis
    REDIS_URL: str = "redis://localhost:6379/0"
    REDIS_CACHE_EXPIRE: int = 3600
    
    # RabbitMQ
    RABBITMQ_URL: Optional[str] = None
    
    # Elasticsearch
    ELASTICSEARCH_URL: Optional[str] = None
    
    # Storage
    STORAGE_TYPE: str = "local"
    STORAGE_PATH: str = "./uploads"
    S3_BUCKET_NAME: Optional[str] = None
    S3_REGION: str = "us-east-1"
    S3_ACCESS_KEY: Optional[str] = None
    S3_SECRET_KEY: Optional[str] = None
    
    # CORS
    CORS_ORIGINS: List[str] = ["http://localhost:8000", "http://localhost:3000"]
    CORS_CREDENTIALS: bool = True
    CORS_METHODS: List[str] = ["GET", "POST", "PUT", "DELETE", "OPTIONS", "PATCH"]
    CORS_HEADERS: List[str] = ["*"]
    
    # Rate Limiting
    RATE_LIMIT_REQUESTS: int = 100
    RATE_LIMIT_PERIOD: int = 60
    
    # Email
    SMTP_HOST: Optional[str] = None
    SMTP_PORT: Optional[int] = 587
    SMTP_USER: Optional[str] = None
    SMTP_PASSWORD: Optional[str] = None
    EMAIL_FROM: Optional[str] = None
    
    # Logging
    LOG_LEVEL: str = "INFO"
    LOG_FILE: Optional[str] = None
    LOG_FORMAT: str = "json"
    
    # Sentry
    SENTRY_DSN: Optional[str] = None
    
    @field_validator("SECRET_KEY")
    @classmethod
    def validate_secret_key(cls, v: str) -> str:
        if len(v) < 32:
            raise ValueError("SECRET_KEY must be at least 32 characters")
        return v
    
    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"
        case_sensitive = True
        extra = "ignore"

@lru_cache()
def get_settings() -> Settings:
    return Settings()

settings = get_settings()
```

**`app/core/database.py`** - Database connection management:

```python
from sqlalchemy.ext.asyncio import (
    AsyncSession,
    async_sessionmaker,
    create_async_engine,
    AsyncEngine
)
from sqlalchemy.orm import declarative_base, declared_attr
from sqlalchemy import MetaData, text
from typing import AsyncGenerator
import logging

from app.core.config import settings

logger = logging.getLogger(__name__)

# Naming convention
convention = {
    "ix": "ix_%(column_0_label)s",
    "uq": "uq_%(table_name)s_%(column_0_name)s",
    "ck": "ck_%(table_name)s_%(constraint_name)s",
    "fk": "fk_%(table_name)s_%(column_0_name)s_%(referred_table_name)s",
    "pk": "pk_%(table_name)s",
}
metadata = MetaData(naming_convention=convention)

class CustomBase:
    @declared_attr
    def __tablename__(cls):
        import re
        name = re.sub(r'(?<!^)(?=[A-Z])', '_', cls.__name__).lower()
        return f"{name}s"

Base = declarative_base(cls=CustomBase, metadata=metadata)

def create_database_engine() -> AsyncEngine:
    return create_async_engine(
        settings.DATABASE_URL,
        echo=settings.DATABASE_ECHO,
        pool_size=settings.DATABASE_POOL_SIZE,
        max_overflow=settings.DATABASE_MAX_OVERFLOW,
        pool_pre_ping=True,
        pool_recycle=3600,
        pool_timeout=30,
        future=True,
        connect_args={
            "server_settings": {
                "application_name": "fastapi_app",
                "timezone": "UTC",
            }
        },
    )

engine = create_database_engine()
AsyncSessionLocal = async_sessionmaker(
    engine,
    class_=AsyncSession,
    expire_on_commit=False,
    autocommit=False,
    autoflush=False,
)

async def get_db() -> AsyncGenerator[AsyncSession, None]:
    async with AsyncSessionLocal() as session:
        try:
            yield session
        except Exception:
            await session.rollback()
            raise
        finally:
            await session.close()

async def check_db_connection() -> bool:
    try:
        async with engine.connect() as conn:
            await conn.execute(text("SELECT 1"))
        return True
    except Exception as e:
        logger.error(f"Database connection failed: {e}")
        return False
```

**`app/main.py`** - Application entry point:

```python
from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import logging
from datetime import datetime

from app.core.config import settings
from app.core.database import engine, check_db_connection
from app.core.exceptions import setup_exception_handlers
from app.api.v1.api import api_router
from app.middleware.security import add_security_middleware
from app.middleware.metrics import PrometheusMiddleware, metrics_endpoint
from app.middleware.rate_limit import RateLimitMiddleware

logger = logging.getLogger(__name__)

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup
    logger.info(f"🚀 Starting {settings.APP_NAME} v{settings.APP_VERSION}")
    if await check_db_connection():
        logger.info("✅ Database connected")
    yield
    # Shutdown
    await engine.dispose()
    logger.info("🛑 Shutdown complete")

def create_application() -> FastAPI:
    app = FastAPI(
        title=settings.APP_NAME,
        version=settings.APP_VERSION,
        lifespan=lifespan,
        docs_url="/docs" if settings.DEBUG else "/docs",
        redoc_url="/redoc" if settings.DEBUG else "/redoc",
    )
    
    # CORS
    app.add_middleware(
        CORSMiddleware,
        allow_origins=settings.CORS_ORIGINS,
        allow_credentials=settings.CORS_CREDENTIALS,
        allow_methods=settings.CORS_METHODS,
        allow_headers=settings.CORS_HEADERS,
    )
    
    # Security middleware
    add_security_middleware(app)
    
    # Rate limiting
    app.add_middleware(RateLimitMiddleware)
    
    # Prometheus metrics
    app.add_middleware(PrometheusMiddleware)
    app.add_route("/metrics", metrics_endpoint)
    
    # Exception handlers
    setup_exception_handlers(app)
    
    # Routers
    app.include_router(api_router, prefix="/api/v1")
    
    # Health checks
    @app.get("/health", tags=["health"])
    async def health():
        return {
            "status": "healthy",
            "timestamp": datetime.utcnow().isoformat() + "Z",
            "service": settings.APP_NAME,
        }
    
    @app.get("/ready", tags=["health"])
    async def ready():
        db_ok = await check_db_connection()
        return {
            "status": "ready" if db_ok else "unhealthy",
            "database": "connected" if db_ok else "disconnected",
        }
    
    return app

app = create_application()
```

## Environment Variables Reference

### Complete `.env.example`

```env
# ────────────────────────────────────────────────────────────────
# APPLICATION
# ────────────────────────────────────────────────────────────────
APP_NAME=FastAPI Masterclass
APP_VERSION=1.0.0
APP_ENV=development
DEBUG=True

# ────────────────────────────────────────────────────────────────
# SECURITY
# ────────────────────────────────────────────────────────────────
SECRET_KEY=generate_me_with_openssl_rand_hex_32
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30
REFRESH_TOKEN_EXPIRE_DAYS=7

# ────────────────────────────────────────────────────────────────
# DATABASE
# ────────────────────────────────────────────────────────────────
DATABASE_URL=postgresql+asyncpg://postgres:postgres@localhost:5432/fastapi_db
DATABASE_POOL_SIZE=10
DATABASE_MAX_OVERFLOW=20
DATABASE_ECHO=False

# ────────────────────────────────────────────────────────────────
# REDIS
# ────────────────────────────────────────────────────────────────
REDIS_URL=redis://localhost:6379/0
REDIS_CACHE_EXPIRE=3600

# ────────────────────────────────────────────────────────────────
# RABBITMQ (Optional - for event-driven architecture)
# ────────────────────────────────────────────────────────────────
RABBITMQ_URL=amqp://guest:guest@localhost:5672/

# ────────────────────────────────────────────────────────────────
# ELASTICSEARCH (Optional - for search)
# ────────────────────────────────────────────────────────────────
ELASTICSEARCH_URL=http://localhost:9200

# ────────────────────────────────────────────────────────────────
# STORAGE
# ────────────────────────────────────────────────────────────────
STORAGE_TYPE=local
STORAGE_PATH=./uploads
S3_BUCKET_NAME=my-bucket
S3_REGION=us-east-1
S3_ACCESS_KEY=your-access-key
S3_SECRET_KEY=your-secret-key

# ────────────────────────────────────────────────────────────────
# CORS
# ────────────────────────────────────────────────────────────────
CORS_ORIGINS=["http://localhost:3000", "http://localhost:8000"]
CORS_CREDENTIALS=True
CORS_METHODS=["GET", "POST", "PUT", "DELETE", "OPTIONS", "PATCH"]
CORS_HEADERS=["*"]

# ────────────────────────────────────────────────────────────────
# RATE LIMITING
# ────────────────────────────────────────────────────────────────
RATE_LIMIT_REQUESTS=100
RATE_LIMIT_PERIOD=60

# ────────────────────────────────────────────────────────────────
# EMAIL
# ────────────────────────────────────────────────────────────────
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your-email@gmail.com
SMTP_PASSWORD=your-app-password
EMAIL_FROM=noreply@yourapp.com

# ────────────────────────────────────────────────────────────────
# LOGGING
# ────────────────────────────────────────────────────────────────
LOG_LEVEL=INFO
LOG_FORMAT=json
LOG_FILE=/var/log/app.log

# ────────────────────────────────────────────────────────────────
# SENTRY (Optional - error tracking)
# ────────────────────────────────────────────────────────────────
SENTRY_DSN=https://your-sentry-dsn@sentry.io/12345
```

## Docker Configuration Reference

### Complete Dockerfile

```dockerfile
# ──────────────── BUILD STAGE ────────────────
FROM python:3.11-slim as builder

WORKDIR /app

RUN apt-get update && apt-get install -y \
    gcc g++ libpq-dev \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir --user -r requirements.txt

# ──────────────── DEVELOPMENT ────────────────
FROM python:3.11-slim as development

WORKDIR /app

RUN apt-get update && apt-get install -y \
    libpq-dev curl \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /root/.local /root/.local
COPY . .

ENV PYTHONPATH=/app
ENV PATH=/root/.local/bin:$PATH

EXPOSE 8000

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000", "--reload"]

# ──────────────── PRODUCTION ────────────────
FROM development as production

ENV APP_ENV=production
ENV DEBUG=False

RUN pip uninstall -y pytest pytest-asyncio pytest-cov || true

CMD ["gunicorn", "app.main:app", "--worker-class", "uvicorn.workers.UvicornWorker", \
     "--workers", "4", "--bind", "0.0.0.0:8000", "--timeout", "120"]

# ──────────────── CELERY WORKER ──────────────
FROM development as celery_worker

CMD ["celery", "-A", "app.core.celery_app", "worker", "--loglevel=info"]

# ──────────────── CELERY BEAT ────────────────
FROM development as celery_beat

CMD ["celery", "-A", "app.core.celery_app", "beat", "--loglevel=info"]
```

## Makefile Commands

```makefile
# Makefile
.PHONY: help install dev test lint format migrate docker-up docker-down clean

help:
	@echo "Available commands:"
	@echo "  install      Install dependencies"
	@echo "  dev          Run development server"
	@echo "  test         Run tests"
	@echo "  lint         Run linters"
	@echo "  format       Format code"
	@echo "  migrate      Run database migrations"
	@echo "  docker-up    Start Docker services"
	@echo "  docker-down  Stop Docker services"
	@echo "  clean        Clean cache and temporary files"

install:
	pip install -r requirements.txt
	pip install -r requirements-dev.txt

dev:
	uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

test:
	pytest tests/ -v --cov=app --cov-report=html

lint:
	flake8 app tests
	mypy app
	black --check app tests
	isort --check-only --profile black app tests

format:
	black app tests
	isort --profile black app tests

migrate:
	alembic upgrade head

docker-up:
	docker-compose up -d

docker-down:
	docker-compose down

clean:
	find . -type d -name "__pycache__" -exec rm -rf {} +
	find . -type f -name "*.pyc" -delete
	find . -type f -name "*.pyo" -delete
	find . -type f -name ".coverage" -delete
	find . -type d -name "htmlcov" -exec rm -rf {} +
	find . -type d -name ".pytest_cache" -exec rm -rf {} +
	find . -type d -name ".mypy_cache" -exec rm -rf {} +
```

## Quick Reference: Common Commands

### Development Commands

```bash
# Setup
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# Run
uvicorn app.main:app --reload

# Database
alembic revision --autogenerate -m "Migration message"
alembic upgrade head

# Tests
pytest
pytest tests/test_unit/ -v
pytest tests/test_integration/ -v
pytest --cov=app --cov-report=html

# Docker
docker-compose up -d
docker-compose logs -f app
docker-compose down

# Celery
celery -A app.core.celery_app worker --loglevel=info
celery -A app.core.celery_app beat --loglevel=info

# Kubernetes
kubectl apply -f k8s/
kubectl get pods -n fastapi-app
kubectl logs -f deployment/fastapi-app -n fastapi-app
kubectl port-forward service/fastapi-app 8000:8000 -n fastapi-app

# Code Quality
black app tests
isort --profile black app tests
flake8 app tests
mypy app

# Production
docker build --target production -t fastapi-prod .
docker run -p 8000:8000 fastapi-prod
```

---

This appendix serves as your complete reference for the entire FastAPI Masterclass application. Use it to understand the full scope of the project, navigate the codebase, and quickly set up your development environment.

**[END OF APPENDIX A]**
