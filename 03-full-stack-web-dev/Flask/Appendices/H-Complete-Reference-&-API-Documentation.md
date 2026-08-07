# Appendix H: Complete Reference & API Documentation

Welcome to Appendix H! This is the final comprehensive reference for the TaskFlow application. It serves as a complete API reference, command reference, troubleshooting guide, and quick-start cheat sheet. Use this appendix as your go-to resource when building, deploying, and maintaining Flask applications.

---

## Table of Contents

1. [Application Architecture Reference](#1-application-architecture-reference)
2. [Configuration Reference](#2-configuration-reference)
3. [Database Schema Reference](#3-database-schema-reference)
4. [API Endpoint Reference](#4-api-endpoint-reference)
5. [CLI Command Reference](#5-cli-command-reference)
6. [Deployment Commands Reference](#6-deployment-commands-reference)
7. [Troubleshooting Guide](#7-troubleshooting-guide)
8. [Performance Tuning Cheat Sheet](#8-performance-tuning-cheat-sheet)
9. [Quick Start Checklist](#9-quick-start-checklist)

---

## 1. Application Architecture Reference

### Directory Structure Map

```
taskflow/
├── app/
│   ├── __init__.py              # Application factory
│   ├── config.py                # Configuration classes
│   ├── extensions.py            # Extension initialization
│   ├── logging_config.py        # Logging setup
│   ├── celery_worker.py         # Celery configuration
│   ├── monitoring.py            # Monitoring utilities
│   │
│   ├── blueprints/              # Route modules
│   │   ├── __init__.py
│   │   ├── main/               # Public routes
│   │   │   ├── __init__.py
│   │   │   └── routes.py
│   │   ├── auth/               # Authentication
│   │   │   ├── __init__.py
│   │   │   └── routes.py
│   │   ├── tasks/              # Task management
│   │   │   ├── __init__.py
│   │   │   └── routes.py
│   │   ├── admin/              # Admin dashboard
│   │   │   ├── __init__.py
│   │   │   └── routes.py
│   │   └── api/                # REST API
│   │       ├── __init__.py
│   │       ├── routes.py
│   │       ├── v1/
│   │       │   ├── __init__.py
│   │       │   └── routes.py
│   │       └── v2/
│   │           ├── __init__.py
│   │           └── routes.py
│   │
│   ├── models/                  # Database models
│   │   ├── __init__.py
│   │   ├── user.py
│   │   ├── task.py
│   │   ├── category.py
│   │   ├── tag.py
│   │   └── comment.py
│   │
│   ├── schemas/                 # Serialization schemas
│   │   ├── __init__.py
│   │   ├── task_schema.py
│   │   ├── user_schema.py
│   │   └── auth_schema.py
│   │
│   ├── forms/                   # WTForms
│   │   ├── __init__.py
│   │   ├── auth.py
│   │   ├── task.py
│   │   ├── admin.py
│   │   └── validators.py
│   │
│   ├── services/                # Business logic
│   │   ├── __init__.py
│   │   ├── user_service.py
│   │   ├── task_service.py
│   │   └── category_service.py
│   │
│   ├── tasks/                   # Celery tasks
│   │   ├── __init__.py
│   │   ├── email_tasks.py
│   │   ├── report_tasks.py
│   │   └── process_tasks.py
│   │
│   ├── utils/                   # Utilities
│   │   ├── __init__.py
│   │   ├── converters.py
│   │   ├── decorators.py
│   │   ├── security.py
│   │   ├── tokens.py
│   │   ├── email.py
│   │   └── async_helpers.py
│   │
│   ├── templates/               # Jinja templates
│   │   ├── base.html
│   │   ├── main/
│   │   ├── auth/
│   │   ├── tasks/
│   │   ├── admin/
│   │   ├── errors/
│   │   └── email/
│   │
│   ├── static/                  # Static assets
│   │   ├── css/
│   │   │   └── style.css
│   │   ├── js/
│   │   │   └── main.js
│   │   └── images/
│   │
│   └── cli/                     # CLI commands
│       ├── __init__.py
│       ├── commands.py
│       └── seed.py
│
├── tests/                       # Test suite
│   ├── __init__.py
│   ├── conftest.py
│   ├── fixtures/
│   │   ├── __init__.py
│   │   ├── factories.py
│   │   └── data.py
│   ├── unit/
│   ├── integration/
│   └── functional/
│
├── docker/                      # Docker configuration
│   ├── app/
│   │   └── Dockerfile
│   ├── nginx/
│   │   └── nginx.conf
│   ├── postgres/
│   │   └── init.sql
│   └── docker-compose.yml
│
├── scripts/                     # Scripts
│   ├── deploy.sh
│   ├── db_backup.sh
│   ├── db_restore.sh
│   └── run_celery.sh
│
├── migrations/                  # Alembic migrations
│   └── versions/
│
├── .env.example
├── .flaskenv
├── .gitignore
├── .pre-commit-config.yaml
├── requirements.txt
├── requirements-dev.txt
├── pyproject.toml
├── pytest.ini
├── gunicorn.conf.py
├── Makefile
├── README.md
└── run.py
```

### Service Layer Architecture

```python
# Service Layer Pattern Reference
class ServiceArchitecture:
    """
    Service Layer Architecture Pattern
    
    ┌─────────────────────────────────────────────────────┐
    │                  View Layer                         │
    │  (Routes, Blueprints, API Endpoints)                │
    └─────────────────────┬───────────────────────────────┘
                          │
    ┌─────────────────────▼───────────────────────────────┐
    │                Service Layer                        │
    │  (Business Logic, Data Access, Validation)          │
    └─────────────────────┬───────────────────────────────┘
                          │
    ┌─────────────────────▼───────────────────────────────┐
    │               Data Access Layer                     │
    │  (SQLAlchemy ORM, Models, Repositories)             │
    └─────────────────────┬───────────────────────────────┘
                          │
    ┌─────────────────────▼───────────────────────────────┐
    │                 Database                            │
    │  (PostgreSQL/SQLite)                                │
    └─────────────────────────────────────────────────────┘
    """
    pass
```

---

## 2. Configuration Reference

### Environment Variables

```bash
# Flask Core
FLASK_APP=run.py                    # Entry point
FLASK_ENV=development               # development, production, testing
FLASK_DEBUG=1                       # Enable debug mode
FLASK_HOST=127.0.0.1               # Development server host
FLASK_PORT=5000                    # Development server port

# Security
SECRET_KEY=your-secret-key          # Session encryption (32+ chars)
WTF_CSRF_SECRET_KEY=your-csrf-key   # CSRF protection key
SESSION_COOKIE_SECURE=False         # HTTPS only (True in production)
SESSION_COOKIE_HTTPONLY=True        # JavaScript inaccessible
SESSION_COOKIE_SAMESITE=Lax         # CSRF protection

# Database
DATABASE_URL=postgresql://user:pass@localhost:5432/taskflow
# Alternative SQLite:
# DATABASE_URL=sqlite:///instance/taskflow.db

# Redis/Celery
CELERY_BROKER_URL=redis://localhost:6379/0
CELERY_RESULT_BACKEND=redis://localhost:6379/1
REDIS_PASSWORD=your-redis-password

# Email (SMTP)
MAIL_SERVER=smtp.gmail.com
MAIL_PORT=587
MAIL_USE_TLS=True
MAIL_USERNAME=your-email@gmail.com
MAIL_PASSWORD=your-app-password
MAIL_DEFAULT_SENDER=noreply@taskflow.com

# AWS (for S3 uploads)
AWS_ACCESS_KEY=your-access-key
AWS_SECRET_KEY=your-secret-key
AWS_REGION=us-east-1
S3_BUCKET=taskflow-uploads

# Monitoring
SENTRY_DSN=your-sentry-dsn
NEW_RELIC_LICENSE_KEY=your-license-key
DATADOG_API_KEY=your-api-key

# Performance
GUNICORN_WORKERS=4
GUNICORN_THREADS=2
GUNICORN_WORKER_CLASS=sync
CACHE_TYPE=redis
CACHE_REDIS_URL=redis://localhost:6379/2

# Feature Flags
FEATURE_FLAGS_JSON={"new_ui": true, "api_v2": false}
```

### Configuration Classes Reference

```python
# app/config.py - Configuration Class Reference

class Config:
    """Base Configuration"""
    SECRET_KEY: str
    DEBUG: bool = False
    TESTING: bool = False
    SQLALCHEMY_DATABASE_URI: str
    SQLALCHEMY_TRACK_MODIFICATIONS: bool = False
    SQLALCHEMY_ECHO: bool = False
    SQLALCHEMY_ENGINE_OPTIONS: dict = {
        "pool_size": 10,
        "pool_recycle": 3600,
        "pool_pre_ping": True,
        "max_overflow": 20,
    }
    SESSION_COOKIE_SECURE: bool = False
    SESSION_COOKIE_HTTPONLY: bool = True
    SESSION_COOKIE_SAMESITE: str = "Lax"
    PERMANENT_SESSION_LIFETIME: timedelta = timedelta(days=7)
    WTF_CSRF_ENABLED: bool = True
    WTF_CSRF_SECRET_KEY: str
    WTF_CSRF_TIME_LIMIT: int = 3600
    MAX_CONTENT_LENGTH: int = 16 * 1024 * 1024
    ALLOWED_EXTENSIONS: set = {"jpg", "jpeg", "png", "gif", "pdf", "doc", "docx"}
    DEFAULT_PER_PAGE: int = 20
    CELERY_BROKER_URL: str
    CELERY_RESULT_BACKEND: str

class DevelopmentConfig(Config):
    """Development Configuration"""
    DEBUG: bool = True
    SQLALCHEMY_ECHO: bool = True
    SQLALCHEMY_DATABASE_URI: str = "sqlite:///instance/taskflow_dev.db"
    SESSION_COOKIE_SECURE: bool = False

class TestingConfig(Config):
    """Testing Configuration"""
    TESTING: bool = True
    DEBUG: bool = False
    SQLALCHEMY_DATABASE_URI: str = "sqlite:///:memory:"
    WTF_CSRF_ENABLED: bool = False
    PERMANENT_SESSION_LIFETIME: timedelta = timedelta(seconds=30)

class ProductionConfig(Config):
    """Production Configuration"""
    DEBUG: bool = False
    TESTING: bool = False
    SECRET_KEY: str = os.environ.get("SECRET_KEY")
    SESSION_COOKIE_SECURE: bool = True
    SESSION_COOKIE_SAMESITE: str = "Strict"
    SQLALCHEMY_DATABASE_URI: str = os.environ.get("DATABASE_URL")
    SQLALCHEMY_ENGINE_OPTIONS: dict = {
        "pool_size": 20,
        "pool_recycle": 3600,
        "pool_pre_ping": True,
        "max_overflow": 40,
    }
```

---

## 3. Database Schema Reference

### ER Diagram

```
┌───────────────┐     ┌───────────────┐     ┌───────────────┐
│     users     │     │    tasks      │     │  categories   │
├───────────────┤     ├───────────────┤     ├───────────────┤
│ id (PK)       │────<│ user_id (FK)  │     │ id (PK)       │
│ username      │     │ id (PK)       │──┐  │ name          │
│ email         │     │ title         │  │  │ description   │
│ password_hash │     │ description   │  │  │ color         │
│ first_name    │     │ status        │  │  │ created_at    │
│ last_name     │     │ priority      │  │  │ updated_at    │
│ bio           │     │ due_date      │  │  │               │
│ role          │     │ completed_at  │  └──│ task_count*   │
│ is_active     │     │ created_at    │     └───────────────┘
│ email_verified│     │ updated_at    │
│ created_at    │     │ assigned_to_id│  ┌───────────────┐
│ updated_at    │     │ category_id   │  │     tags      │
│ last_login    │     │               │  ├───────────────┤
└───────────────┘     └───────────────┘  │ id (PK)       │
      │                                    │ name          │
      │     ┌───────────────┐              │ color         │
      └────>│   comments    │              │ created_at    │
            ├───────────────┤              │ updated_at    │
            │ id (PK)       │              └───────────────┘
            │ text          │                    │
            │ created_at    │                    │
            │ updated_at    │    ┌───────────────┐
            │ user_id (FK)  │    │  task_tags    │
            │ task_id (FK)  │    ├───────────────┤
            └───────────────┘    │ task_id (FK)  │
                                 │ tag_id (FK)   │
                                 └───────────────┘
```

### Model Reference

```python
# app/models/user.py
class User(db.Model, UserMixin):
    """User Model"""
    # Primary Key
    id = db.Column(db.Integer, primary_key=True)
    
    # Authentication
    username = db.Column(db.String(50), unique=True, nullable=False, index=True)
    email = db.Column(db.String(120), unique=True, nullable=False, index=True)
    password_hash = db.Column(db.String(128), nullable=False)
    
    # Profile
    first_name = db.Column(db.String(50))
    last_name = db.Column(db.String(50))
    bio = db.Column(db.Text)
    
    # Authorization
    role = db.Column(db.Enum(UserRole), default=UserRole.USER)
    is_active = db.Column(db.Boolean, default=True)
    email_verified = db.Column(db.Boolean, default=False)
    
    # Timestamps
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    last_login = db.Column(db.DateTime)
    
    # Relationships
    tasks = db.relationship('Task', back_populates='user', lazy='dynamic')
    assigned_tasks = db.relationship('Task', back_populates='assigned_to_user', foreign_keys='Task.assigned_to_id')
    comments = db.relationship('Comment', back_populates='user', lazy='dynamic')
    
    # Methods
    def set_password(self, password): ...
    def check_password(self, password): ...
    def has_permission(self, permission): ...
    @property def full_name(self): ...
    @property def is_admin(self): ...

# app/models/task.py
class Task(db.Model):
    """Task Model"""
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(200), nullable=False)
    description = db.Column(db.Text)
    status = db.Column(db.Enum(TaskStatus), default=TaskStatus.PENDING)
    priority = db.Column(db.Enum(TaskPriority), default=TaskPriority.MEDIUM)
    due_date = db.Column(db.DateTime)
    completed_at = db.Column(db.DateTime)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Foreign Keys
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    assigned_to_id = db.Column(db.Integer, db.ForeignKey('users.id'))
    category_id = db.Column(db.Integer, db.ForeignKey('categories.id'))
    
    # Relationships
    user = db.relationship('User', back_populates='tasks', foreign_keys=[user_id])
    assigned_to_user = db.relationship('User', back_populates='assigned_tasks', foreign_keys=[assigned_to_id])
    category = db.relationship('Category', back_populates='tasks')
    tags = db.relationship('Tag', secondary='task_tags', back_populates='tasks')
    comments = db.relationship('Comment', back_populates='task', lazy='dynamic')
    
    # Methods
    def complete(self): ...
    def archive(self): ...
    def reopen(self): ...
    def add_tag(self, tag): ...
    @property def is_completed(self): ...
    @property def is_overdue(self): ...

# app/models/category.py
class Category(db.Model):
    """Category Model"""
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(50), unique=True, nullable=False)
    description = db.Column(db.String(200))
    color = db.Column(db.String(7), default="#6c757d")
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    tasks = db.relationship('Task', back_populates='category', lazy='dynamic')

# app/models/tag.py
class Tag(db.Model):
    """Tag Model"""
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(50), unique=True, nullable=False)
    color = db.Column(db.String(7), default="#6c757d")
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    tasks = db.relationship('Task', secondary='task_tags', back_populates='tags')

# app/models/comment.py
class Comment(db.Model):
    """Comment Model"""
    id = db.Column(db.Integer, primary_key=True)
    text = db.Column(db.Text, nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    task_id = db.Column(db.Integer, db.ForeignKey('tasks.id'), nullable=False)
    user = db.relationship('User', back_populates='comments')
    task = db.relationship('Task', back_populates='comments')
```

### Enum Reference

```python
from enum import Enum

class UserRole(str, Enum):
    USER = "user"
    MANAGER = "manager"
    ADMIN = "admin"

class TaskStatus(str, Enum):
    PENDING = "pending"
    IN_PROGRESS = "in_progress"
    REVIEW = "review"
    COMPLETED = "completed"
    ARCHIVED = "archived"

class TaskPriority(str, Enum):
    LOW = "low"
    MEDIUM = "medium"
    HIGH = "high"
    URGENT = "urgent"
```

---

## 4. API Endpoint Reference

### API Overview

```
Base URL: https://api.taskflow.com/api/v1/

Authentication: Bearer Token or Session Cookie
Rate Limits: 100 req/min (GET), 30 req/min (POST), 5 req/min (Auth)
```

### Authentication Endpoints

```http
POST /auth/login
Request Body:
{
    "email": "user@example.com",
    "password": "password123"
}
Response:
{
    "access_token": "eyJhbGciOiJIUzI1NiIs...",
    "token_type": "Bearer",
    "expires_in": 3600,
    "user": {
        "id": 1,
        "username": "johndoe",
        "email": "user@example.com",
        "full_name": "John Doe",
        "role": "user"
    }
}

POST /auth/logout
Headers: Authorization: Bearer <token>
Response: {"message": "Logged out successfully"}

POST /auth/refresh
Headers: Authorization: Bearer <refresh_token>
Response: {"access_token": "new_token", "expires_in": 3600}

POST /auth/register
Request Body:
{
    "username": "johndoe",
    "email": "user@example.com",
    "password": "Password123!",
    "confirm_password": "Password123!",
    "accept_terms": true
}
Response: {"message": "Registration successful", "user_id": 1}
```

### Task Endpoints

```http
GET /tasks
Headers: Authorization: Bearer <token>
Query Parameters:
    status: pending|in_progress|review|completed|archived
    priority: low|medium|high|urgent
    category_id: int
    assigned_to_id: int
    search: string
    page: int (default: 1)
    per_page: int (default: 20)
Response:
{
    "tasks": [...],
    "metadata": {
        "total": 100,
        "page": 1,
        "per_page": 20,
        "pages": 5
    }
}

POST /tasks
Request Body:
{
    "title": "New Task",
    "description": "Task description",
    "priority": "high",
    "status": "pending",
    "due_date": "2024-12-31T23:59:59Z",
    "assigned_to_id": 2,
    "category_id": 3,
    "tags": ["important", "urgent"]
}
Response:
{
    "id": 1,
    "title": "New Task",
    "created_at": "2024-01-01T00:00:00Z"
}

GET /tasks/{id}
Response: Task object

PUT /tasks/{id}
Request Body: (all fields optional)
{
    "title": "Updated Title",
    "status": "completed",
    "priority": "urgent"
}
Response: Updated task object

DELETE /tasks/{id}
Response: 204 No Content

POST /tasks/{id}/assign
Request Body: {"user_id": 2}
Response: {"message": "Task assigned"}

POST /tasks/{id}/status/{status}
Response: {"message": "Status updated"}

POST /tasks/{id}/comments
Request Body: {"comment": "Comment text"}
Response: {"id": 1, "text": "Comment text", "created_at": "..."}
```

### User Endpoints

```http
GET /users
Headers: Authorization: Bearer <token>
Query Parameters:
    page: int (default: 1)
    per_page: int (default: 20)
Response:
{
    "users": [...],
    "metadata": {
        "total": 100,
        "page": 1,
        "per_page": 20,
        "pages": 5
    }
}

GET /users/{id}
Response: User object

GET /users/me
Response: Current user object

PUT /users/me
Request Body:
{
    "first_name": "John",
    "last_name": "Doe",
    "bio": "Software Developer"
}
Response: Updated user object
```

### Admin Endpoints

```http
GET /admin/users
Headers: Authorization: Bearer <token>
Response: List of all users

POST /admin/users/{id}/toggle
Response: {"is_active": false}

POST /admin/users/{id}/role
Request Body: {"role": "manager"}
Response: {"role": "manager"}

GET /admin/stats
Response:
{
    "users": {
        "total": 100,
        "active": 95,
        "admins": 5,
        "managers": 10
    },
    "tasks": {
        "total": 1000,
        "pending": 200,
        "completed": 600
    }
}
```

### Category & Tag Endpoints

```http
GET /categories
Response: List of categories

POST /categories
Request Body: {"name": "Work", "description": "Work tasks", "color": "#667eea"}
Response: Created category

GET /tags
Response: List of tags

POST /tags
Request Body: {"name": "important", "color": "#ff0000"}
Response: Created tag
```

### Error Response Format

```http
HTTP/1.1 400 Bad Request
{
    "error": "Validation Error",
    "message": "One or more fields failed validation",
    "status": 400,
    "errors": {
        "title": ["Title is required"],
        "priority": ["Invalid priority value"]
    }
}

HTTP/1.1 401 Unauthorized
{
    "error": "Unauthorized",
    "message": "Authentication required",
    "status": 401,
    "path": "/api/tasks"
}

HTTP/1.1 403 Forbidden
{
    "error": "Forbidden",
    "message": "You don't have permission to access this resource",
    "status": 403,
    "path": "/api/admin/users"
}

HTTP/1.1 404 Not Found
{
    "error": "Not Found",
    "message": "Task not found",
    "status": 404,
    "path": "/api/tasks/999"
}

HTTP/1.1 429 Too Many Requests
{
    "error": "Too Many Requests",
    "message": "Rate limit exceeded. Please try again later.",
    "status": 429,
    "path": "/api/tasks",
    "retry_after": 60
}
```

---

## 5. CLI Command Reference

### Flask CLI Commands

```bash
# Application Management
flask run                          # Run development server
flask shell                        # Open Flask shell
flask routes                       # Show all registered routes

# Database Management
flask db init                      # Initialize migrations
flask db migrate -m "message"      # Generate migration
flask db upgrade                   # Apply migrations
flask db downgrade                 # Rollback migration
flask db current                   # Show current version
flask db history                   # Show migration history

# User Management
flask create-user                  # Create a new user
flask create-admin                 # Create admin user
flask reset-user-password          # Reset user password
flask list-users                   # List all users

# Data Management
flask seed-db                      # Seed database with test data
flask seed-users                   # Create test users
flask seed-tasks                   # Create test tasks
flask seed-categories              # Create test categories

# Utility
flask show-routes                  # Display all routes
flask clear-cache                  # Clear application cache

# Custom CLI Commands
flask create-admin --email admin@example.com --username admin --password admin123
flask seed-db --users 10 --tasks-per-user 20 --categories 5
```

### Celery Commands

```bash
# Start Celery worker
celery -A app.celery_worker.celery worker --loglevel=info
celery -A app.celery_worker.celery worker -Q high,default,low --loglevel=info
celery -A app.celery_worker.celery worker --concurrency=4 --loglevel=info

# Start Celery Beat (scheduler)
celery -A app.celery_worker.celery beat --loglevel=info

# Start Flower (monitoring)
celery -A app.celery_worker.celery flower --port=5555

# Celery Utility Commands
celery -A app.celery_worker.celery inspect active        # Show active tasks
celery -A app.celery_worker.celery inspect registered   # Show registered tasks
celery -A app.celery_worker.celery inspect stats        # Show worker stats
celery -A app.celery_worker.celery purge               # Clear all tasks
celery -A app.celery_worker.celery status              # Check worker status
```

### Gunicorn Commands

```bash
# Start Gunicorn
gunicorn -c gunicorn.conf.py run:app

# With custom workers
gunicorn --workers=4 --threads=2 --bind=0.0.0.0:8000 run:app

# With UNIX socket
gunicorn --bind=unix:/tmp/taskflow.sock run:app

# With logging
gunicorn --access-logfile logs/access.log --error-logfile logs/error.log run:app

# Reload on code changes (development)
gunicorn --reload --workers=2 run:app

# Production recommended
gunicorn -c gunicorn.conf.py --preload --workers=4 run:app
```

### Testing Commands

```bash
# Run all tests
pytest

# Run specific test file
pytest tests/unit/test_models.py

# Run with coverage
pytest --cov=app --cov-report=html --cov-report=term

# Run only unit tests
pytest -m unit

# Run only integration tests
pytest -m integration

# Run only functional tests
pytest -m functional

# Run with verbose output
pytest -v

# Run specific test
pytest tests/unit/test_models.py::TestUserModel::test_create_user

# Skip slow tests
pytest -m "not slow"
```

---

## 6. Deployment Commands Reference

### Docker Commands

```bash
# Build Docker image
docker build -f docker/app/Dockerfile -t taskflow:latest .

# Start with Docker Compose
docker-compose -f docker/docker-compose.yml up -d

# Stop containers
docker-compose -f docker/docker-compose.yml down

# View logs
docker-compose -f docker/docker-compose.yml logs -f
docker-compose -f docker/docker-compose.yml logs -f web
docker-compose -f docker/docker-compose.yml logs --tail=100

# Execute commands in container
docker-compose -f docker/docker-compose.yml exec web flask shell
docker-compose -f docker/docker-compose.yml exec web flask db upgrade
docker-compose -f docker/docker-compose.yml exec postgres psql -U taskflow

# Container management
docker ps                                 # List running containers
docker stop taskflow_web                  # Stop specific container
docker rm taskflow_web                    # Remove container
docker images                             # List images
docker rmi taskflow:latest                # Remove image
docker system prune -f                    # Clean up unused resources
```

### Kubernetes Commands

```bash
# Deploy to Kubernetes
kubectl apply -f kubernetes/namespace.yaml
kubectl apply -f kubernetes/secret.yaml
kubectl apply -f kubernetes/configmap.yaml
kubectl apply -f kubernetes/deployment.yaml
kubectl apply -f kubernetes/service.yaml
kubectl apply -f kubernetes/ingress.yaml

# Update deployment
kubectl set image deployment/taskflow-web web=taskflow:latest -n taskflow
kubectl rollout status deployment/taskflow-web -n taskflow

# Rollback
kubectl rollout undo deployment/taskflow-web -n taskflow

# Check status
kubectl get pods -n taskflow
kubectl get deployments -n taskflow
kubectl get services -n taskflow
kubectl get ingress -n taskflow

# View logs
kubectl logs -f deployment/taskflow-web -n taskflow
kubectl logs -f pod/taskflow-web-xxx -n taskflow -c web

# Scale deployment
kubectl scale deployment taskflow-web --replicas=5 -n taskflow

# Port forward (for debugging)
kubectl port-forward service/taskflow-web 8080:80 -n taskflow

# Delete resources
kubectl delete -f kubernetes/deployment.yaml
kubectl delete namespace taskflow
```

### Database Commands

```bash
# PostgreSQL Commands
psql -U taskflow -d taskflow          # Connect to database
psql -U taskflow -d taskflow -c "SELECT * FROM users;"

# Backup Database
pg_dump -U taskflow -h localhost -Fc taskflow > backup.dump

# Restore Database
pg_restore -U taskflow -h localhost -d taskflow backup.dump

# Run migrations
flask db upgrade
flask db downgrade -1                 # Rollback one migration

# Seed database
flask seed-db --users 50 --tasks-per-user 20

# Shell access
flask shell

# Query examples
# Get all users
User.query.all()

# Get tasks for user
User.query.get(1).tasks.all()

# Count tasks by status
Task.query.filter_by(status='completed').count()

# Get overdue tasks
from datetime import datetime
Task.query.filter(Task.due_date < datetime.utcnow(), Task.status != 'completed').all()
```

---

## 7. Troubleshooting Guide

### Common Issues & Solutions

#### Application Won't Start

```bash
# Check for port conflicts
lsof -i :5000  # Check if port 5000 is in use
# Stop process or use different port
export FLASK_PORT=5001

# Check dependencies
pip install -r requirements.txt

# Check environment variables
python -c "import os; print(os.environ.get('FLASK_ENV'))"

# Run with verbose output
flask run --debugger --reload

# Check for syntax errors
python -m compileall app/
```

#### Database Connection Issues

```python
# Check connection
from app.extensions import db
db.engine.connect()

# Check pool status
from app import create_app
app = create_app()
with app.app_context():
    print(db.engine.pool.status())

# Reset connection pool
db.engine.pool.dispose()

# Check database URL
import os
print(os.environ.get('DATABASE_URL'))

# PostgreSQL specific
# Check if database exists
psql -l
# Create database if needed
createdb -U postgres taskflow
```

#### Migration Issues

```bash
# Reset migrations (development only)
rm -rf migrations/
flask db init
flask db migrate -m "fresh_start"
flask db upgrade

# Fix migration conflicts
flask db stamp head    # Mark current state as latest
flask db migrate -m "fix_merge"  # Generate new migration

# Rollback specific migration
flask db downgrade -1
# or specific revision
flask db downgrade abc123

# Show migration history
flask db history
```

#### Celery Issues

```bash
# Check Redis connection
redis-cli ping

# Check Celery status
celery -A app.celery_worker.celery status

# Clear all tasks
celery -A app.celery_worker.celery purge -f

# Reset Celery queues
celery -A app.celery_worker.celery purge -Q default

# Check broker connection
celery -A app.celery_worker.celery inspect ping

# View task results
python -c "from celery.result import AsyncResult; print(AsyncResult('task_id').result)"

# Debug with worker loggingcelery -A app.celery_worker.celery worker --loglevel=debug
```

#### Performance Issues

```python
# Profile slow requests
@app.route('/debug/profile')
@login_required
def profile():
    import cProfile
    import pstats
    import io
    
    profiler = cProfile.Profile()
    profiler.enable()
    
    # Run the code you want to profile
    result = expensive_operation()
    
    profiler.disable()
    
    s = io.StringIO()
    ps = pstats.Stats(profiler, stream=s).sort_stats('cumtime')
    ps.print_stats(20)
    
    return s.getvalue()

# Check database queries
import logging
logging.basicConfig()
logging.getLogger('sqlalchemy.engine').setLevel(logging.INFO)

# Enable query debugging
app.config['SQLALCHEMY_ECHO'] = True

# Check N+1 queries
from app.models.task import Task
from sqlalchemy.orm import joinedload

# Bad (N+1)
tasks = Task.query.all()
for task in tasks:
    print(task.user.name)

# Good (eager load)
tasks = Task.query.options(joinedload(Task.user)).all()
for task in tasks:
    print(task.user.name)

# Monitor connection pool
from sqlalchemy import event
@event.listens_for(db.engine, "checkout")
def on_checkout(dbapi_conn, connection_record, connection_proxy):
    print(f"Pool size: {db.engine.pool.size()}, checkedout: {db.engine.pool.checkedout()}")
```

#### Docker Issues

```bash
# View container logs
docker logs -f taskflow_web

# Clean Docker
docker system prune -f --volumes
docker volume prune -f

# Rebuild without cache
docker build --no-cache -f docker/app/Dockerfile -t taskflow:latest .

# Debug running container
docker exec -it taskflow_web bash
docker exec -it taskflow_web flask shell

# Check container health
docker inspect taskflow_web | grep -A 5 Health

# Resource usage
docker stats

# Port conflicts
docker ps --format "table {{.Names}}\t{{.Ports}}"
```

### Debugging Checklist

```bash
# 1. Check Environment
python --version
pip freeze | grep Flask
echo $FLASK_ENV

# 2. Check Application
flask routes
curl http://localhost:5000/health

# 3. Check Database
flask db current
flask shell -c "from app.models.user import User; print(User.query.count())"

# 4. Check Cache
redis-cli ping
redis-cli --scan --pattern "taskflow:*"

# 5. Check Celery
celery -A app.celery_worker.celery status
celery -A app.celery_worker.celery inspect active

# 6. Check Logs
tail -f logs/taskflow.log
tail -f logs/access.log

# 7. Check System
top
df -h
free -m
```

---

## 8. Performance Tuning Cheat Sheet

### Gunicorn Tuning

```python
# Optimal worker count
# (2 x CPU cores) + 1
# Example for 4-core CPU: 9 workers

# Worker types
# sync: Default, good for CPU-bound apps
# gevent: Good for I/O-bound apps
# tornado: Good for WebSocket
# gthread: Good for mixed workloads

# Recommended production config
gunicorn_config = {
    'bind': '0.0.0.0:8000',
    'workers': 9,                # (2 x CPU) + 1
    'worker_class': 'gthread',   # or 'gevent'
    'threads': 4,                # Per worker
    'timeout': 120,
    'keepalive': 5,
    'max_requests': 1000,
    'max_requests_jitter': 100,
    'preload_app': True,
    'graceful_timeout': 30,
}
```

### Database Tuning

```sql
-- PostgreSQL tuning for Flask apps

-- Connection pool size: (max_connections = max_connections - 10)
-- With 100 max connections, use 90 for app

-- Query optimization
CREATE INDEX idx_tasks_user_id_status ON tasks(user_id, status);
CREATE INDEX idx_tasks_due_date ON tasks(due_date);
CREATE INDEX idx_tasks_priority ON tasks(priority);

-- Full-text search index
CREATE INDEX idx_tasks_search ON tasks USING GIN(to_tsvector('english', title || ' ' || COALESCE(description, '')));

-- Performance monitoring
SELECT * FROM pg_stat_activity WHERE state = 'active';
SELECT * FROM pg_stat_database WHERE datname = 'taskflow';

-- Vacuum maintenance
VACUUM ANALYZE tasks;
ANALYZE users;
```

### Application Tuning

```python
# 1. Caching configuration
app.config.update({
    'CACHE_TYPE': 'redis',
    'CACHE_DEFAULT_TIMEOUT': 300,
    'CACHE_KEY_PREFIX': 'taskflow:',
})

# 2. Template caching
app.jinja_env.cache_size = 500  # Cache up to 500 templates

# 3. Session configuration
app.config.update({
    'SESSION_COOKIE_HTTPONLY': True,
    'SESSION_COOKIE_SECURE': True,
    'SESSION_COOKIE_SAMESITE': 'Strict',
})

# 4. Compression
app.config.update({
    'COMPRESS_MIMETYPES': ['application/json', 'text/html'],
    'COMPRESS_LEVEL': 6,
})

# 5. Static file optimization
app.config.update({
    'SEND_FILE_MAX_AGE_DEFAULT': 31536000,  # 1 year
})
```

### Redis Tuning

```bash
# redis.conf optimization
maxmemory 256mb
maxmemory-policy allkeys-lru
save 900 1
save 300 10
save 60 10000

# Monitor Redis
redis-cli info stats
redis-cli info memory
redis-cli monitor

# Clear cache
redis-cli --scan --pattern "taskflow:*" | xargs redis-cli del
```

### Nginx Tuning

```nginx
# Optimize Nginx for Flask
worker_processes auto;
worker_rlimit_nofile 65535;

events {
    worker_connections 4096;
    use epoll;
    multi_accept on;
}

http {
    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_comp_level 6;
    gzip_types text/plain text/css application/json application/javascript;

    # Caching
    open_file_cache max=1000 inactive=20s;
    open_file_cache_valid 30s;
    open_file_cache_min_uses 2;

    # Keep alive
    keepalive_timeout 65;
    keepalive_requests 100;

    # Buffers
    client_body_buffer_size 128k;
    client_max_body_size 20M;
    large_client_header_buffers 4 8k;
}
```

---

## 9. Quick Start Checklist

### New Project Setup

```bash
# 1. Clone repository
git clone https://github.com/yourusername/taskflow.git
cd taskflow

# 2. Create virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# 3. Install dependencies
pip install -r requirements.txt
pip install -r requirements-dev.txt

# 4. Configure environment
cp .env.example .env
# Edit .env with your settings

# 5. Initialize database
flask db init
flask db migrate -m "Initial migration"
flask db upgrade

# 6. Seed database
flask seed-db --users 10 --tasks-per-user 5

# 7. Start development server
python run.py
# Or: flask run

# 8. Run tests
pytest

# 9. Run code quality checks
make format
make lint
make type-check
```

### Production Deployment Checklist

```bash
# 1. Pre-deployment checks
□ All tests passing
□ Environment variables set
□ Database migrations ready
□ Static files collected

# 2. Security checks
□ SECRET_KEY set and strong
□ DEBUG=False
□ SESSION_COOKIE_SECURE=True
□ HTTPS configured
□ Database password changed
□ Redis password set

# 3. Performance checks
□ Gunicorn workers configured
□ Redis cache enabled
□ Database connection pool sized
□ Static files optimized
□ Caching headers set

# 4. Monitoring checks
□ Logging configured
□ Health check endpoint working
□ Metrics endpoint exposed
□ Sentry/Datadog configured
□ Alerting set up

# 5. Deployment commands
make test
docker build -t taskflow:latest .
docker-compose up -d
flask db upgrade
```

### Daily Operations Checklist

```bash
# 1. Morning checks
□ Application health: curl https://taskflow.com/health
□ Database health: flask db current
□ Redis health: redis-cli ping
□ Celery health: celery status
□ Check recent errors: tail -f logs/taskflow_errors.log

# 2. Deployment steps
□ Pull latest code
□ Run database migrations
□ Deploy application
□ Run smoke tests
□ Monitor metrics

# 3. Monitoring
□ Check error rates
□ Check response times
□ Check system resources
□ Check backup status

# 4. Weekly tasks
□ Review security logs
□ Check SSL certificate expiry
□ Review performance metrics
□ Update dependencies
□ Check disk space

# 5. Monthly tasks
□ Disaster recovery test
□ Security audit
□ Performance review
□ Architecture review
□ Security patches
```

---

## Summary

This appendix has provided a complete reference for the TaskFlow application:

1. **Architecture Reference**: Directory structure and service layer pattern
2. **Configuration Reference**: Environment variables and config classes
3. **Database Schema Reference**: Complete ER diagram and model definitions
4. **API Endpoint Reference**: All endpoints with request/response formats
5. **CLI Command Reference**: Flask, Celery, Gunicorn, and test commands
6. **Deployment Commands**: Docker, Kubernetes, and database commands
7. **Troubleshooting Guide**: Common issues and solutions
8. **Performance Tuning Cheat Sheet**: Optimization configurations
9. **Quick Start Checklist**: Setup, deployment, and operations checklists

**Use this reference as your go-to guide for building, deploying, and maintaining Flask applications!**
