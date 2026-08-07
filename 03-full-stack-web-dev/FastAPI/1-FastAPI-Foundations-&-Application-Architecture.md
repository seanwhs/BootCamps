# Part 1: FastAPI Foundations & Application Architecture

Welcome to the hands-on portion of our journey! In this first technical module, we'll build a complete FastAPI application from scratch. By the end of this part, you'll have a fully functional API with proper architecture, automatic documentation, data validation, dependency injection, configuration management, and robust error handling.

## Learning Objectives

By the end of Part 1, you will be able to:
- Set up a FastAPI project with proper structure
- Create RESTful endpoints with path, query, and body parameters
- Validate data using Pydantic models with custom validators
- Implement dependency injection for clean, testable code
- Manage configuration with Pydantic Settings across environments
- Handle errors with standardized responses
- Understand ASGI vs WSGI and why FastAPI is different

## Key Concepts Before We Begin

### What is ASGI?
Think of **ASGI** (Asynchronous Server Gateway Interface) as a high-speed highway that lets your web application handle multiple requests simultaneously. Unlike **WSGI** (Web Server Gateway Interface), which is like a single-lane road where requests wait in line, ASGI supports asynchronous processing—perfect for modern applications that need to handle many users at once.

```
WSGI (Synchronous):
Request 1 ──► Wait ──► Process ──► Response
Request 2 ────────► Wait ──► Process ──► Response
Request 3 ──────────────────► Wait ──► Process ──► Response

ASGI (Asynchronous):
Request 1 ──► Process (async) ──► Response
Request 2 ──► Process (async) ──► Response
Request 3 ──► Process (async) ──► Response
         (All requests handled concurrently)
```

### Why FastAPI?
FastAPI combines the best of:
- **Starlette** (web framework) - handles routing, middleware, requests
- **Pydantic** (data validation) - ensures data correctness
- **ASGI** - enables high performance and async support
- **OpenAPI** - generates interactive API documentation automatically

## Step 1: Project Setup & Structure

### The Target
Set up our project directory structure with virtual environment and initial dependencies.

### The Concept
Before writing code, we need a solid foundation. Think of this as preparing your workspace—organizing tools and materials before building a house. We'll create a clean, maintainable structure that scales with our application.

### The Implementation

**Create project directory and virtual environment:**

```bash
# Create and navigate to project directory
mkdir fastapi-masterclass
cd fastapi-masterclass

# Create virtual environment
python3 -m venv venv

# Activate virtual environment
# On macOS/Linux:
source venv/bin/activate
# On Windows:
# venv\Scripts\activate

# Upgrade pip
pip install --upgrade pip
```

**Create the project structure:**

```bash
# Create the directory structure
mkdir -p app/{api/{v1/endpoints},core,models,schemas,services,crud,utils}
mkdir -p tests
mkdir -p alembic/versions
mkdir -p scripts
mkdir -p nginx
mkdir -p .github/workflows

# Create initial files
touch app/main.py
touch app/core/config.py
touch app/core/dependencies.py
touch app/core/exceptions.py
touch app/core/security.py
touch app/api/v1/__init__.py
touch app/api/v1/api.py
touch app/api/v1/endpoints/__init__.py
touch app/models/__init__.py
touch app/schemas/__init__.py
touch app/services/__init__.py
touch app/crud/__init__.py
touch app/utils/__init__.py
touch .env
touch .env.example
touch .gitignore
touch requirements.txt
touch docker-compose.yml
touch Dockerfile
touch Makefile
touch README.md
```

**Create `.gitignore` to keep our repository clean:**

```gitignore
# .gitignore - Files to exclude from version control

# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
env/
venv/
ENV/
dist/
build/
*.egg-info/
*.egg
.pytest_cache/
.coverage
htmlcov/
.tox/
.mypy_cache/
.dmypy.json
dmypy.json

# Environment variables
.env
.env.local
.env.*.local

# IDE
.vscode/
.idea/
*.swp
*.swo
*~
.DS_Store

# Database
*.db
*.sqlite
*.sqlite3

# Logs
*.log
logs/

# Docker
*.pid
docker-compose.override.yml

# Node (for any frontend)
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Generated files
alembic/versions/*.py
!alembic/versions/.gitkeep

# Coverage
coverage.xml
*.cover
```

**Create `.env.example` with environment variables template:**

```env
# .env.example - Template for environment variables
# Copy this to .env and fill in your values

# Application
APP_NAME=FastAPI Masterclass
APP_VERSION=1.0.0
APP_ENV=development
DEBUG=True
SECRET_KEY=CHANGE_THIS_TO_RANDOM_SECRET_KEY
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30
REFRESH_TOKEN_EXPIRE_DAYS=7

# Database
DATABASE_URL=postgresql+asyncpg://user:password@localhost:5432/fastapi_db
DATABASE_POOL_SIZE=20
DATABASE_MAX_OVERFLOW=40

# Redis
REDIS_URL=redis://localhost:6379/0
REDIS_CACHE_EXPIRE=3600

# Security
CORS_ORIGINS=["http://localhost:3000", "http://localhost:8000"]
ALLOWED_HOSTS=["localhost", "127.0.0.1"]

# Rate Limiting
RATE_LIMIT_REQUESTS=100
RATE_LIMIT_PERIOD=60

# Email (for notifications)
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your-email@gmail.com
SMTP_PASSWORD=your-app-password

# File Storage
STORAGE_TYPE=local
S3_BUCKET_NAME=fastapi-uploads
S3_REGION=us-east-1
S3_ACCESS_KEY=your-access-key
S3_SECRET_KEY=your-secret-key
```

**Create `requirements.txt` with all initial dependencies:**

```txt
# requirements.txt - Core dependencies for development and production

# FastAPI Core
fastapi==0.104.1
uvicorn[standard]==0.24.0
pydantic==2.4.2
pydantic-settings==2.0.3

# Database
sqlalchemy==2.0.23
alembic==1.12.1
asyncpg==0.29.0
psycopg2-binary==2.9.9

# Security
python-jose[cryptography]==3.3.0
passlib[bcrypt]==1.7.4
python-multipart==0.0.6
email-validator==2.1.0

# Caching & Queues
redis==5.0.1
celery==5.3.4

# Monitoring & Logging
loguru==0.7.2
prometheus-fastapi-instrumentator==6.1.0

# Utils
python-dotenv==1.0.0
httpx==0.25.1
aiofiles==23.2.1
python-slugify==8.0.1
tenacity==8.2.3

# Development & Testing
pytest==7.4.3
pytest-asyncio==0.21.1
pytest-cov==4.1.0
black==23.11.0
flake8==6.1.0
mypy==1.7.0
isort==5.12.0
pre-commit==3.5.0

# Production Server
gunicorn==21.2.0
```

**Install dependencies:**

```bash
pip install -r requirements.txt
```

## Step 2: Configuration Management

### The Target
Create a robust configuration system using Pydantic Settings that manages environment variables across development, testing, and production environments.

### The Concept
Instead of hardcoding configuration values (like database URLs or secret keys), we'll use environment variables. This is like having different keys for different doors—your development, staging, and production environments each have their own settings, but the system knows which key to use automatically.

### The Implementation

**Create `app/core/config.py`:**

```python
"""
app/core/config.py
Configuration management using Pydantic Settings.
Handles environment variables and provides type-safe access to settings.
"""

from typing import List, Optional
from pydantic_settings import BaseSettings
from pydantic import Field, field_validator, ValidationError
from functools import lru_cache
import os
from pathlib import Path


class Settings(BaseSettings):
    """
    Application settings loaded from environment variables.
    
    Uses Pydantic's built-in validation to ensure all required
    configuration is present and correctly typed.
    """
    
    # ────────────────────────────────────────────────────────────────
    # Application Settings
    # ────────────────────────────────────────────────────────────────
    APP_NAME: str = Field(
        default="FastAPI Masterclass",
        description="Name of the application"
    )
    APP_VERSION: str = Field(
        default="1.0.0",
        description="Version of the application"
    )
    APP_ENV: str = Field(
        default="development",
        description="Environment (development, testing, production)"
    )
    DEBUG: bool = Field(
        default=True,
        description="Enable debug mode"
    )
    
    # ────────────────────────────────────────────────────────────────
    # Security Settings
    # ────────────────────────────────────────────────────────────────
    SECRET_KEY: str = Field(
        ...,
        min_length=32,
        description="Secret key for JWT signing (must be at least 32 chars)"
    )
    ALGORITHM: str = Field(
        default="HS256",
        description="Algorithm for JWT token signing"
    )
    ACCESS_TOKEN_EXPIRE_MINUTES: int = Field(
        default=30,
        description="Access token expiration in minutes"
    )
    REFRESH_TOKEN_EXPIRE_DAYS: int = Field(
        default=7,
        description="Refresh token expiration in days"
    )
    
    # ────────────────────────────────────────────────────────────────
    # Database Settings
    # ────────────────────────────────────────────────────────────────
    DATABASE_URL: str = Field(
        ...,
        description="PostgreSQL database URL (asyncpg format)"
    )
    DATABASE_POOL_SIZE: int = Field(
        default=20,
        description="Maximum database connection pool size"
    )
    DATABASE_MAX_OVERFLOW: int = Field(
        default=40,
        description="Maximum overflow connections beyond pool size"
    )
    DATABASE_ECHO: bool = Field(
        default=False,
        description="Echo SQL queries (useful for debugging)"
    )
    
    # ────────────────────────────────────────────────────────────────
    # Redis Settings
    # ────────────────────────────────────────────────────────────────
    REDIS_URL: str = Field(
        default="redis://localhost:6379/0",
        description="Redis connection URL"
    )
    REDIS_CACHE_EXPIRE: int = Field(
        default=3600,
        description="Default cache expiration in seconds"
    )
    
    # ────────────────────────────────────────────────────────────────
    # CORS Settings
    # ────────────────────────────────────────────────────────────────
    CORS_ORIGINS: List[str] = Field(
        default=["http://localhost:8000", "http://localhost:3000"],
        description="Allowed CORS origins"
    )
    CORS_CREDENTIALS: bool = Field(
        default=True,
        description="Allow credentials in CORS requests"
    )
    CORS_METHODS: List[str] = Field(
        default=["GET", "POST", "PUT", "DELETE", "OPTIONS", "PATCH"],
        description="Allowed HTTP methods for CORS"
    )
    CORS_HEADERS: List[str] = Field(
        default=["*"],
        description="Allowed HTTP headers for CORS"
    )
    
    # ────────────────────────────────────────────────────────────────
    # Rate Limiting Settings
    # ────────────────────────────────────────────────────────────────
    RATE_LIMIT_REQUESTS: int = Field(
        default=100,
        description="Number of requests allowed per period"
    )
    RATE_LIMIT_PERIOD: int = Field(
        default=60,
        description="Rate limiting period in seconds"
    )
    
    # ────────────────────────────────────────────────────────────────
    # Email Settings (Optional)
    # ────────────────────────────────────────────────────────────────
    SMTP_HOST: Optional[str] = Field(
        default=None,
        description="SMTP server hostname"
    )
    SMTP_PORT: Optional[int] = Field(
        default=587,
        description="SMTP server port"
    )
    SMTP_USER: Optional[str] = Field(
        default=None,
        description="SMTP username"
    )
    SMTP_PASSWORD: Optional[str] = Field(
        default=None,
        description="SMTP password"
    )
    EMAIL_FROM: Optional[str] = Field(
        default=None,
        description="Default from email address"
    )
    
    # ────────────────────────────────────────────────────────────────
    # File Storage Settings
    # ────────────────────────────────────────────────────────────────
    STORAGE_TYPE: str = Field(
        default="local",
        description="Storage type: local, s3"
    )
    STORAGE_PATH: str = Field(
        default="./uploads",
        description="Local storage path for uploaded files"
    )
    S3_BUCKET_NAME: Optional[str] = Field(
        default=None,
        description="S3 bucket name for cloud storage"
    )
    S3_REGION: Optional[str] = Field(
        default="us-east-1",
        description="S3 bucket region"
    )
    S3_ACCESS_KEY: Optional[str] = Field(
        default=None,
        description="S3 access key"
    )
    S3_SECRET_KEY: Optional[str] = Field(
        default=None,
        description="S3 secret key"
    )
    
    # ────────────────────────────────────────────────────────────────
    # Logging Settings
    # ────────────────────────────────────────────────────────────────
    LOG_LEVEL: str = Field(
        default="INFO",
        description="Logging level (DEBUG, INFO, WARNING, ERROR, CRITICAL)"
    )
    LOG_FILE: Optional[str] = Field(
        default=None,
        description="Log file path (logs to stdout if not set)"
    )
    LOG_FORMAT: str = Field(
        default="json",
        description="Log format (json, text)"
    )
    
    # ────────────────────────────────────────────────────────────────
    # Validation Methods
    # ────────────────────────────────────────────────────────────────
    
    @field_validator("SECRET_KEY")
    @classmethod
    def validate_secret_key(cls, v: str) -> str:
        """
        Ensure the secret key is sufficiently long for security.
        
        Args:
            v: The secret key string
            
        Returns:
            The validated secret key
            
        Raises:
            ValueError: If the secret key is too short
        """
        if len(v) < 32:
            raise ValueError(
                "SECRET_KEY must be at least 32 characters long "
                "for security. Generate one using: "
                "openssl rand -hex 32"
            )
        return v
    
    @field_validator("DATABASE_URL")
    @classmethod
    def validate_database_url(cls, v: str) -> str:
        """
        Ensure the database URL uses the correct async driver.
        
        Args:
            v: The database URL string
            
        Returns:
            The validated database URL
            
        Raises:
            ValueError: If the URL doesn't use asyncpg driver
        """
        if "asyncpg" not in v:
            raise ValueError(
                "DATABASE_URL must use asyncpg driver. "
                "Example: postgresql+asyncpg://user:pass@localhost/db"
            )
        return v
    
    @field_validator("CORS_ORIGINS", mode="before")
    @classmethod
    def parse_cors_origins(cls, v) -> List[str]:
        """
        Parse CORS origins from string or list.
        
        Args:
            v: CORS origins (string or list)
            
        Returns:
            List of CORS origins
        """
        if isinstance(v, str):
            # Handle the case where it's a JSON-like string
            if v.startswith("[") and v.endswith("]"):
                import json
                return json.loads(v)
            # Handle comma-separated list
            return [origin.strip() for origin in v.split(",") if origin.strip()]
        return v
    
    class Config:
        """
        Pydantic configuration for loading environment variables.
        """
        # Load from .env file if present
        env_file = ".env"
        env_file_encoding = "utf-8"
        
        # Case sensitivity
        case_sensitive = True
        
        # Extra fields are ignored
        extra = "ignore"


# ────────────────────────────────────────────────────────────────
# Settings Singleton
# ────────────────────────────────────────────────────────────────

@lru_cache()
def get_settings() -> Settings:
    """
    Get cached settings instance.
    
    Uses lru_cache to ensure settings are loaded only once,
    which improves performance and ensures consistency.
    
    Returns:
        Settings: Application settings instance
    """
    try:
        return Settings()
    except ValidationError as e:
        # Print validation errors clearly for debugging
        print("❌ Configuration validation failed:")
        for error in e.errors():
            print(f"  • {error['loc'][0]}: {error['msg']}")
        raise


# Create a singleton settings instance
settings = get_settings()


# ────────────────────────────────────────────────────────────────
# Helper Functions
# ────────────────────────────────────────────────────────────────

def is_development() -> bool:
    """Check if we're in development environment."""
    return settings.APP_ENV.lower() == "development"


def is_testing() -> bool:
    """Check if we're in testing environment."""
    return settings.APP_ENV.lower() == "testing"


def is_production() -> bool:
    """Check if we're in production environment."""
    return settings.APP_ENV.lower() == "production"


def get_database_url_for_env(env: str = None) -> str:
    """
    Get database URL for specific environment.
    
    Can be overridden for testing to use a separate database.
    
    Args:
        env: Environment name (development, testing, production)
        
    Returns:
        str: Database URL
    """
    if env == "testing":
        # Use a separate database for testing
        return settings.DATABASE_URL.replace("/fastapi_db", "/fastapi_test")
    return settings.DATABASE_URL
```

**Create `app/core/__init__.py` to export key components:**

```python
"""
app/core/__init__.py
Core module exports.
"""

from app.core.config import (
    settings,
    get_settings,
    is_development,
    is_testing,
    is_production,
)

__all__ = [
    "settings",
    "get_settings",
    "is_development",
    "is_testing",
    "is_production",
]
```

### The Verification

Let's test our configuration system:

```bash
# Create a .env file with a valid secret key
echo "SECRET_KEY=$(openssl rand -hex 32)" >> .env
echo "DATABASE_URL=postgresql+asyncpg://test:test@localhost:5432/fastapi_db" >> .env

# Test the configuration
python -c "from app.core.config import settings; print(f'App: {settings.APP_NAME}'); print(f'Secret Key: {settings.SECRET_KEY[:8]}...')"
```

Expected output:
```
App: FastAPI Masterclass
Secret Key: 8f7e3c2a...
```

If you see validation errors, make sure your `.env` file contains at least `SECRET_KEY` and `DATABASE_URL`.

## Step 3: Custom Exception Handlers

### The Target
Create standardized error responses that provide consistent, informative error messages to API clients.

### The Concept
When something goes wrong, we want to tell the user what happened, not just return a cryptic error. Think of this as a helpful customer service representative—instead of just saying "Error 500," they explain what went wrong and suggest how to fix it.

### The Implementation

**Create `app/core/exceptions.py`:**

```python
"""
app/core/exceptions.py
Custom exception classes and handlers for consistent error responses.
"""

from typing import Any, Dict, List, Optional, Union
from fastapi import FastAPI, Request, status
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse
from pydantic import ValidationError
from starlette.exceptions import HTTPException as StarletteHTTPException
import logging

logger = logging.getLogger(__name__)


# ────────────────────────────────────────────────────────────────
# Base Exception Class
# ────────────────────────────────────────────────────────────────

class APIException(Exception):
    """
    Base API exception class.
    
    All custom exceptions should inherit from this class.
    
    Attributes:
        status_code: HTTP status code to return
        detail: Human-readable error message
        error_code: Machine-readable error code
        data: Additional data to include in the response
    """
    
    def __init__(
        self,
        status_code: int = status.HTTP_500_INTERNAL_SERVER_ERROR,
        detail: str = "An unexpected error occurred",
        error_code: str = "INTERNAL_ERROR",
        data: Optional[Dict[str, Any]] = None,
    ):
        self.status_code = status_code
        self.detail = detail
        self.error_code = error_code
        self.data = data or {}
        super().__init__(detail)


# ────────────────────────────────────────────────────────────────
# HTTP Exception Classes
# ────────────────────────────────────────────────────────────────

class BadRequestException(APIException):
    """400 Bad Request - Invalid request parameters or data."""
    
    def __init__(
        self,
        detail: str = "Invalid request",
        error_code: str = "BAD_REQUEST",
        data: Optional[Dict[str, Any]] = None,
    ):
        super().__init__(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=detail,
            error_code=error_code,
            data=data,
        )


class UnauthorizedException(APIException):
    """401 Unauthorized - Authentication required."""
    
    def __init__(
        self,
        detail: str = "Authentication required",
        error_code: str = "UNAUTHORIZED",
        data: Optional[Dict[str, Any]] = None,
    ):
        super().__init__(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=detail,
            error_code=error_code,
            data=data,
        )


class ForbiddenException(APIException):
    """403 Forbidden - Insufficient permissions."""
    
    def __init__(
        self,
        detail: str = "Insufficient permissions",
        error_code: str = "FORBIDDEN",
        data: Optional[Dict[str, Any]] = None,
    ):
        super().__init__(
            status_code=status.HTTP_403_FORBIDDEN,
            detail=detail,
            error_code=error_code,
            data=data,
        )


class NotFoundException(APIException):
    """404 Not Found - Resource does not exist."""
    
    def __init__(
        self,
        detail: str = "Resource not found",
        error_code: str = "NOT_FOUND",
        data: Optional[Dict[str, Any]] = None,
    ):
        super().__init__(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=detail,
            error_code=error_code,
            data=data,
        )


class ConflictException(APIException):
    """409 Conflict - Resource conflict (e.g., duplicate entry)."""
    
    def __init__(
        self,
        detail: str = "Resource conflict",
        error_code: str = "CONFLICT",
        data: Optional[Dict[str, Any]] = None,
    ):
        super().__init__(
            status_code=status.HTTP_409_CONFLICT,
            detail=detail,
            error_code=error_code,
            data=data,
        )


class ValidationException(APIException):
    """422 Unprocessable Entity - Data validation failed."""
    
    def __init__(
        self,
        detail: str = "Validation error",
        error_code: str = "VALIDATION_ERROR",
        data: Optional[Dict[str, Any]] = None,
    ):
        super().__init__(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail=detail,
            error_code=error_code,
            data=data,
        )


class TooManyRequestsException(APIException):
    """429 Too Many Requests - Rate limit exceeded."""
    
    def __init__(
        self,
        detail: str = "Rate limit exceeded",
        error_code: str = "TOO_MANY_REQUESTS",
        data: Optional[Dict[str, Any]] = None,
    ):
        super().__init__(
            status_code=status.HTTP_429_TOO_MANY_REQUESTS,
            detail=detail,
            error_code=error_code,
            data=data,
        )


class InternalServerException(APIException):
    """500 Internal Server Error - Unexpected server error."""
    
    def __init__(
        self,
        detail: str = "Internal server error",
        error_code: str = "INTERNAL_ERROR",
        data: Optional[Dict[str, Any]] = None,
    ):
        super().__init__(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=detail,
            error_code=error_code,
            data=data,
        )


# ────────────────────────────────────────────────────────────────
# Exception Handlers
# ────────────────────────────────────────────────────────────────

def create_error_response(
    status_code: int,
    detail: str,
    error_code: str = "ERROR",
    data: Optional[Dict[str, Any]] = None,
    trace_id: Optional[str] = None,
) -> JSONResponse:
    """
    Create a standardized error response.
    
    Args:
        status_code: HTTP status code
        detail: Human-readable error message
        error_code: Machine-readable error code
        data: Additional data to include
        trace_id: Request trace ID for debugging
        
    Returns:
        JSONResponse: Standardized error response
    """
    response_data = {
        "success": False,
        "error": {
            "status_code": status_code,
            "detail": detail,
            "error_code": error_code,
        },
    }
    
    if data:
        response_data["error"]["data"] = data
    
    if trace_id:
        response_data["error"]["trace_id"] = trace_id
    
    return JSONResponse(
        status_code=status_code,
        content=response_data,
    )


async def api_exception_handler(request: Request, exc: APIException) -> JSONResponse:
    """
    Handler for custom API exceptions.
    
    Args:
        request: FastAPI request object
        exc: API exception instance
        
    Returns:
        JSONResponse: Standardized error response
    """
    # Get trace_id from request state if available
    trace_id = getattr(request.state, "trace_id", None)
    
    logger.warning(
        f"API Exception: {exc.error_code} - {exc.detail}",
        extra={
            "error_code": exc.error_code,
            "status_code": exc.status_code,
            "path": request.url.path,
            "method": request.method,
        },
    )
    
    return create_error_response(
        status_code=exc.status_code,
        detail=exc.detail,
        error_code=exc.error_code,
        data=exc.data if exc.data else None,
        trace_id=trace_id,
    )


async def http_exception_handler(
    request: Request, exc: StarletteHTTPException
) -> JSONResponse:
    """
    Handler for Starlette HTTP exceptions.
    
    Args:
        request: FastAPI request object
        exc: Starlette HTTP exception
        
    Returns:
        JSONResponse: Standardized error response
    """
    trace_id = getattr(request.state, "trace_id", None)
    
    return create_error_response(
        status_code=exc.status_code,
        detail=str(exc.detail),
        error_code="HTTP_ERROR",
        trace_id=trace_id,
    )


async def validation_exception_handler(
    request: Request, exc: RequestValidationError
) -> JSONResponse:
    """
    Handler for Pydantic validation errors.
    
    Formats validation errors in a user-friendly way.
    
    Args:
        request: FastAPI request object
        exc: Request validation error
        
    Returns:
        JSONResponse: Standardized error response with validation details
    """
    trace_id = getattr(request.state, "trace_id", None)
    
    # Extract validation error details
    errors = []
    for error in exc.errors():
        # Pydantic v2 error format
        field = ".".join(str(loc) for loc in error["loc"])
        error_detail = {
            "field": field,
            "message": error["msg"],
            "type": error["type"],
        }
        # Add input value if available and not sensitive
        if "input" in error and error["input"] is not None:
            # Don't include sensitive data in logs
            if field.lower() not in ["password", "token", "secret", "key"]:
                error_detail["value"] = str(error["input"])
        errors.append(error_detail)
    
    logger.info(
        f"Validation error: {len(errors)} errors",
        extra={
            "errors": errors,
            "path": request.url.path,
            "method": request.method,
        },
    )
    
    return create_error_response(
        status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
        detail="Validation error in request",
        error_code="VALIDATION_ERROR",
        data={"validation_errors": errors},
        trace_id=trace_id,
    )


async def generic_exception_handler(
    request: Request, exc: Exception
) -> JSONResponse:
    """
    Catch-all handler for unexpected exceptions.
    
    In development, includes the exception details for debugging.
    In production, logs the error and returns a generic message.
    
    Args:
        request: FastAPI request object
        exc: Exception instance
        
    Returns:
        JSONResponse: Standardized error response
    """
    trace_id = getattr(request.state, "trace_id", None)
    
    # Log the full exception for debugging
    logger.exception(
        f"Unhandled exception: {str(exc)}",
        extra={
            "path": request.url.path,
            "method": request.method,
            "trace_id": trace_id,
        },
    )
    
    from app.core.config import settings
    
    # In development, include the error details
    if settings.DEBUG:
        return create_error_response(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=str(exc),
            error_code="UNHANDLED_ERROR",
            data={
                "type": type(exc).__name__,
                "file": getattr(exc, "__file__", None),
                "line": getattr(exc, "__line__", None),
            },
            trace_id=trace_id,
        )
    
    # In production, return a generic message
    return create_error_response(
        status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
        detail="An internal server error occurred",
        error_code="INTERNAL_ERROR",
        trace_id=trace_id,
    )


# ────────────────────────────────────────────────────────────────
# Setup Function
# ────────────────────────────────────────────────────────────────

def setup_exception_handlers(app: FastAPI) -> None:
    """
    Register all exception handlers with the FastAPI application.
    
    Args:
        app: FastAPI application instance
    """
    app.add_exception_handler(APIException, api_exception_handler)
    app.add_exception_handler(StarletteHTTPException, http_exception_handler)
    app.add_exception_handler(RequestValidationError, validation_exception_handler)
    app.add_exception_handler(Exception, generic_exception_handler)
    
    logger.info("✅ Exception handlers configured")
```

## Step 4: Creating the Main Application

### The Target
Build the main FastAPI application with proper middleware configuration and health check endpoints.

### The Concept
The main application is like the central nervous system—it brings together all components, configures middleware, and routes requests to the right handlers.

### The Implementation

**Create `app/main.py`:**

```python
"""
app/main.py
Main FastAPI application entry point.
"""

from contextlib import asynccontextmanager
from fastapi import FastAPI, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.trustedhost import TrustedHostMiddleware
from fastapi.responses import JSONResponse
from starlette.middleware.base import BaseHTTPMiddleware
import uuid
import logging
from datetime import datetime
import time

from app.core.config import settings
from app.core.exceptions import setup_exception_handlers
from app.api.v1.api import api_router

# Configure logging
logging.basicConfig(
    level=getattr(logging, settings.LOG_LEVEL),
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
)
logger = logging.getLogger(__name__)


# ────────────────────────────────────────────────────────────────
# Custom Middleware
# ────────────────────────────────────────────────────────────────

class RequestLoggingMiddleware(BaseHTTPMiddleware):
    """
    Middleware to log all requests with timing information.
    
    Adds a trace_id to each request for distributed tracing.
    """
    
    async def dispatch(self, request, call_next):
        # Generate a unique trace ID for this request
        trace_id = str(uuid.uuid4())
        request.state.trace_id = trace_id
        
        # Record start time
        start_time = time.time()
        
        # Log the request
        logger.info(
            f"Request: {request.method} {request.url.path}",
            extra={
                "trace_id": trace_id,
                "method": request.method,
                "path": request.url.path,
                "query": str(request.query_params),
                "client": request.client.host if request.client else None,
            },
        )
        
        # Process the request
        try:
            response = await call_next(request)
            
            # Calculate request duration
            duration = time.time() - start_time
            
            # Add trace_id to response headers
            response.headers["X-Trace-ID"] = trace_id
            
            # Log the response
            logger.info(
                f"Response: {request.method} {request.url.path} - {response.status_code}",
                extra={
                    "trace_id": trace_id,
                    "status_code": response.status_code,
                    "duration_ms": round(duration * 1000, 2),
                },
            )
            
            return response
            
        except Exception as e:
            # Log error
            logger.error(
                f"Error processing request: {str(e)}",
                extra={"trace_id": trace_id},
                exc_info=True,
            )
            raise


class PerformanceMiddleware(BaseHTTPMiddleware):
    """
    Middleware to track and log performance metrics.
    """
    
    async def dispatch(self, request, call_next):
        start_time = time.time()
        response = await call_next(request)
        duration = time.time() - start_time
        
        # Warn about slow requests (>1 second)
        if duration > 1.0:
            logger.warning(
                f"Slow request: {request.method} {request.url.path} "
                f"took {duration:.2f}s",
                extra={
                    "trace_id": getattr(request.state, "trace_id", None),
                    "duration": duration,
                },
            )
        
        # Add performance header
        response.headers["X-Response-Time"] = f"{duration:.3f}s"
        return response


# ────────────────────────────────────────────────────────────────
# Application Lifecycle
# ────────────────────────────────────────────────────────────────

@asynccontextmanager
async def lifespan(app: FastAPI):
    """
    Application lifespan manager.
    
    Handles startup and shutdown events.
    
    Args:
        app: FastAPI application instance
    """
    # ──────────────── STARTUP ────────────────
    logger.info("🚀 Starting FastAPI application...")
    logger.info(f"📝 Application: {settings.APP_NAME} v{settings.APP_VERSION}")
    logger.info(f"🌍 Environment: {settings.APP_ENV}")
    logger.info(f"🐛 Debug mode: {settings.DEBUG}")
    
    # Initialize database connection pool
    # (We'll add this in Part 2)
    
    # Initialize Redis connection pool
    # (We'll add this in Part 4)
    
    yield  # Application runs here
    
    # ───────────────── SHUTDOWN ──────────────
    logger.info("🛑 Shutting down FastAPI application...")
    
    # Close database connections
    # (We'll add this in Part 2)
    
    # Close Redis connections
    # (We'll add this in Part 4)


# ────────────────────────────────────────────────────────────────
# Create FastAPI Application
# ────────────────────────────────────────────────────────────────

def create_application() -> FastAPI:
    """
    Application factory for creating the FastAPI app.
    
    Returns:
        FastAPI: Configured FastAPI application instance
    """
    # Create the FastAPI app with metadata
    app = FastAPI(
        title=settings.APP_NAME,
        version=settings.APP_VERSION,
        description="""
        ## 🚀 FastAPI Masterclass API
        
        This is a production-ready FastAPI application built as part of the
        FastAPI Masterclass series.
        
        ### Features:
        - ✅ Async database operations with SQLAlchemy 2.0
        - ✅ JWT-based authentication and authorization
        - ✅ Comprehensive data validation with Pydantic V2
        - ✅ Automatic OpenAPI documentation
        - ✅ Health checks and monitoring
        - ✅ Rate limiting and security features
        - ✅ CORS support for web applications
        
        ### Authentication:
        To access protected endpoints, obtain a JWT token via `/api/v1/auth/login`.
        Include the token in the `Authorization` header as:
        ```
        Bearer <your_token>
        ```
        """,
        docs_url="/docs" if settings.DEBUG else "/docs",
        redoc_url="/redoc" if settings.DEBUG else "/redoc",
        openapi_url="/openapi.json" if settings.DEBUG else "/openapi.json",
        lifespan=lifespan,
        # OpenAPI tags for better organization
        openapi_tags=[
            {
                "name": "health",
                "description": "Health check and monitoring endpoints",
            },
            {
                "name": "auth",
                "description": "Authentication and user management",
            },
            {
                "name": "users",
                "description": "User profile management",
            },
            {
                "name": "tasks",
                "description": "Task management operations",
            },
            {
                "name": "projects",
                "description": "Project management operations",
            },
        ],
    )
    
    # ──────────────── MIDDLEWARE ──────────────────
    
    # Request logging middleware (add first to log everything)
    app.add_middleware(RequestLoggingMiddleware)
    
    # Performance monitoring middleware
    app.add_middleware(PerformanceMiddleware)
    
    # CORS middleware (enable cross-origin requests)
    app.add_middleware(
        CORSMiddleware,
        allow_origins=settings.CORS_ORIGINS,
        allow_credentials=settings.CORS_CREDENTIALS,
        allow_methods=settings.CORS_METHODS,
        allow_headers=settings.CORS_HEADERS,
    )
    
    # Trusted host middleware (security)
    app.add_middleware(
        TrustedHostMiddleware,
        allowed_hosts=settings.ALLOWED_HOSTS if hasattr(settings, "ALLOWED_HOSTS") else ["*"],
    )
    
    # ──────────────── EXCEPTION HANDLERS ──────────────
    setup_exception_handlers(app)
    
    # ──────────────── ROUTES ──────────────────────────
    app.include_router(api_router, prefix="/api/v1")
    
    # ──────────────── ROOT ENDPOINT ───────────────────
    @app.get("/", tags=["health"])
    async def root():
        """
        Root endpoint providing basic API information.
        """
        return {
            "name": settings.APP_NAME,
            "version": settings.APP_VERSION,
            "environment": settings.APP_ENV,
            "status": "operational",
            "documentation": "/docs" if settings.DEBUG else "/docs",
        }
    
    # ──────────────── HEALTH CHECK ───────────────────
    @app.get("/health", tags=["health"])
    async def health_check():
        """
        Health check endpoint for monitoring and load balancers.
        
        Returns:
            JSONResponse: Health status information
        """
        return {
            "status": "healthy",
            "timestamp": datetime.utcnow().isoformat() + "Z",
            "service": settings.APP_NAME,
            "version": settings.APP_VERSION,
            "environment": settings.APP_ENV,
        }
    
    # ──────────────── READINESS PROBE ────────────────
    @app.get("/ready", tags=["health"])
    async def readiness_check():
        """
        Readiness probe for Kubernetes and other orchestrators.
        
        Checks if the application is ready to serve traffic.
        """
        # Check database connectivity
        # (We'll add this in Part 2)
        
        return {
            "status": "ready",
            "timestamp": datetime.utcnow().isoformat() + "Z",
        }
    
    logger.info("✅ Application created successfully")
    return app


# ────────────────────────────────────────────────────────────────
# Create the application instance
# ────────────────────────────────────────────────────────────────

app = create_application()


# ────────────────────────────────────────────────────────────────
# Direct execution handler
# ────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    import uvicorn
    
    uvicorn.run(
        "app.main:app",
        host="0.0.0.0",
        port=8000,
        reload=settings.DEBUG,
        log_level=settings.LOG_LEVEL.lower(),
    )
```

## Step 5: API Router Setup

### The Target
Create the router structure that organizes all API endpoints.

### The Concept
Think of routers as filing cabinets—each cabinet (router) organizes related documents (endpoints). This keeps our code clean and maintainable as the API grows.

### The Implementation

**Create `app/api/v1/api.py`:**

```python
"""
app/api/v1/api.py
Main API router that includes all v1 endpoints.
"""

from fastapi import APIRouter

# Import endpoint routers
# (We'll create these in the next steps)
from app.api.v1.endpoints import (
    health,
    # auth,  # Part 3
    # users, # Part 3
    # tasks, # Part 2
    # projects, # Part 2
)

api_router = APIRouter()

# Include health endpoints (always available)
api_router.include_router(
    health.router,
    prefix="/health",
    tags=["health"],
)

# Include authentication endpoints
# api_router.include_router(
#     auth.router,
#     prefix="/auth",
#     tags=["auth"],
# )

# Include user endpoints
# api_router.include_router(
#     users.router,
#     prefix="/users",
#     tags=["users"],
# )

# Include task endpoints
# api_router.include_router(
#     tasks.router,
#     prefix="/tasks",
#     tags=["tasks"],
# )

# Include project endpoints
# api_router.include_router(
#     projects.router,
#     prefix="/projects",
#     tags=["projects"],
# )

# Health endpoint at root of v1
@api_router.get("/", tags=["health"])
async def api_root():
    """
    API v1 root endpoint.
    """
    return {
        "version": "v1",
        "status": "operational",
        "endpoints": [
            "/health",
            "/auth",
            "/users",
            "/tasks",
            "/projects",
        ],
    }
```

**Create `app/api/v1/endpoints/health.py`:**

```python
"""
app/api/v1/endpoints/health.py
Health check endpoints for monitoring.
"""

from fastapi import APIRouter, status
from datetime import datetime
import psutil
import os

router = APIRouter()


@router.get("/", status_code=status.HTTP_200_OK)
async def get_health():
    """
    Comprehensive health check with system metrics.
    
    Returns:
        dict: Health status with system metrics
    """
    # Get system metrics
    memory = psutil.virtual_memory()
    cpu_percent = psutil.cpu_percent(interval=0.1)
    disk = psutil.disk_usage("/")
    
    return {
        "status": "healthy",
        "timestamp": datetime.utcnow().isoformat() + "Z",
        "system": {
            "cpu_percent": cpu_percent,
            "memory_percent": memory.percent,
            "memory_available_mb": memory.available // (1024 * 1024),
            "disk_percent": disk.percent,
            "disk_free_gb": disk.free // (1024 * 1024 * 1024),
        },
        "process": {
            "pid": os.getpid(),
            "memory_mb": psutil.Process().memory_info().rss // (1024 * 1024),
            "cpu_percent": psutil.Process().cpu_percent(),
        },
    }


@router.get("/ping", status_code=status.HTTP_200_OK)
async def ping():
    """
    Simple ping endpoint for basic connectivity checks.
    
    Returns:
        dict: Simple pong response
    """
    return {
        "ping": "pong",
        "timestamp": datetime.utcnow().isoformat() + "Z",
    }
```

**Create `app/api/v1/endpoints/__init__.py`:**

```python
"""
app/api/v1/endpoints/__init__.py
Endpoints module exports.
"""

from app.api.v1.endpoints import health

__all__ = ["health"]
```

### The Verification

Let's run the application and test our endpoints:

```bash
# Make sure you're in the project root and virtual environment is activated
# Run the application
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

You should see output like:
```
INFO:     Uvicorn running on http://0.0.0.0:8000
INFO:     Application created successfully
```

**Test the health endpoint:**

```bash
# In a new terminal, test the health endpoint
curl http://localhost:8000/health
```

Expected output:
```json
{
  "status": "healthy",
  "timestamp": "2024-01-15T10:30:00.123456Z",
  "system": {
    "cpu_percent": 12.5,
    "memory_percent": 45.2,
    "memory_available_mb": 8192,
    "disk_percent": 35.0,
    "disk_free_gb": 150
  },
  "process": {
    "pid": 12345,
    "memory_mb": 89.2,
    "cpu_percent": 2.3
  }
}
```

**Test the root endpoint:**

```bash
curl http://localhost:8000/
```

Expected output:
```json
{
  "name": "FastAPI Masterclass",
  "version": "1.0.0",
  "environment": "development",
  "status": "operational",
  "documentation": "/docs"
}
```

**Check the automatic API documentation:**

Open your browser and go to:
- **Swagger UI**: http://localhost:8000/docs
- **ReDoc**: http://localhost:8000/redoc

You should see interactive API documentation generated automatically from your code!

## Step 6: Creating Your First Endpoint with Pydantic Validation

### The Target
Create a fully-featured endpoint that demonstrates Pydantic validation, proper HTTP methods, and typed responses.

### The Concept
Pydantic acts like a bouncer at a club—it checks every piece of data that comes in, ensures it meets all requirements, and rejects anything that doesn't fit. This protects your application from invalid data and makes your code more reliable.

### The Implementation

**Create `app/schemas/task.py`:**

```python
"""
app/schemas/task.py
Pydantic schemas for task-related data validation.
"""

from pydantic import BaseModel, Field, field_validator, ConfigDict
from datetime import datetime
from typing import Optional, List
from enum import Enum


class TaskStatus(str, Enum):
    """Task status enumeration."""
    TODO = "todo"
    IN_PROGRESS = "in_progress"
    REVIEW = "review"
    DONE = "done"
    ARCHIVED = "archived"


class TaskPriority(str, Enum):
    """Task priority enumeration."""
    LOW = "low"
    MEDIUM = "medium"
    HIGH = "high"
    CRITICAL = "critical"


# ────────────────────────────────────────────────────────────────
# Base Task Schema
# ────────────────────────────────────────────────────────────────

class TaskBase(BaseModel):
    """
    Base task schema with common fields.
    
    All task schemas inherit from this to maintain consistency.
    """
    
    title: str = Field(
        ...,
        min_length=1,
        max_length=200,
        description="Task title (1-200 characters)",
        examples=["Build the authentication system"]
    )
    
    description: Optional[str] = Field(
        default=None,
        max_length=2000,
        description="Detailed task description (max 2000 characters)",
        examples=["Implement OAuth2 with JWT and refresh tokens"]
    )
    
    status: TaskStatus = Field(
        default=TaskStatus.TODO,
        description="Current task status"
    )
    
    priority: TaskPriority = Field(
        default=TaskPriority.MEDIUM,
        description="Task priority level"
    )
    
    due_date: Optional[datetime] = Field(
        default=None,
        description="Optional due date for the task",
        examples=["2024-12-31T23:59:59"]
    )
    
    project_id: Optional[int] = Field(
        default=None,
        description="ID of the project this task belongs to",
        examples=[1]
    )
    
    assignee_id: Optional[int] = Field(
        default=None,
        description="ID of the user assigned to this task",
        examples=[42]
    )
    
    tags: List[str] = Field(
        default=[],
        description="List of tags for categorizing the task",
        examples=[["backend", "security", "jwt"]]
    )
    
    estimated_hours: Optional[float] = Field(
        default=None,
        ge=0,
        le=1000,
        description="Estimated hours to complete (0-1000)",
        examples=[8.5]
    )
    
    actual_hours: Optional[float] = Field(
        default=None,
        ge=0,
        le=10000,
        description="Actual hours spent (0-10000)",
        examples=[12.0]
    )
    
    # ────────────────────────────────────────────────────────────────
    # Validators
    # ────────────────────────────────────────────────────────────────
    
    @field_validator("title")
    @classmethod
    def validate_title(cls, v: str) -> str:
        """
        Clean and validate title.
        
        Args:
            v: Title string
            
        Returns:
            str: Cleaned title
            
        Raises:
            ValueError: If title contains invalid characters
        """
        # Remove extra whitespace
        v = " ".join(v.split())
        
        # Check for invalid characters (example)
        if any(char in v for char in ["<", ">", "&", '"', "'"]):
            raise ValueError("Title contains invalid characters")
        
        return v
    
    @field_validator("due_date", mode="after")
    @classmethod
    def validate_due_date(cls, v: Optional[datetime]) -> Optional[datetime]:
        """
        Ensure due date is in the future.
        
        Args:
            v: Due date datetime
            
        Returns:
            Optional[datetime]: Validated due date
            
        Raises:
            ValueError: If due date is in the past
        """
        if v is not None:
            if v < datetime.utcnow():
                raise ValueError("Due date cannot be in the past")
        return v
    
    @field_validator("tags")
    @classmethod
    def validate_tags(cls, v: List[str]) -> List[str]:
        """
        Clean and validate tags.
        
        Args:
            v: List of tags
            
        Returns:
            List[str]: Cleaned tags
            
        Raises:
            ValueError: If tags contain invalid characters
        """
        # Remove empty tags and strip whitespace
        cleaned = [tag.strip().lower() for tag in v if tag.strip()]
        
        # Limit number of tags
        if len(cleaned) > 10:
            raise ValueError("Maximum 10 tags allowed")
        
        # Validate tag characters (alphanumeric, underscore, hyphen)
        import re
        for tag in cleaned:
            if not re.match(r"^[a-z0-9\-_]+$", tag):
                raise ValueError(
                    f"Tag '{tag}' contains invalid characters. "
                    "Use only letters, numbers, hyphens, and underscores."
                )
        
        return cleaned
    
    model_config = ConfigDict(
        json_schema_extra={
            "example": {
                "title": "Implement JWT authentication",
                "description": "Add OAuth2 with JWT tokens and refresh flow",
                "status": "in_progress",
                "priority": "high",
                "due_date": "2024-12-31T23:59:59",
                "tags": ["backend", "security", "jwt"],
                "estimated_hours": 8.5,
                "project_id": 1,
                "assignee_id": 42,
            }
        }
    )


# ────────────────────────────────────────────────────────────────
# Request Schemas
# ────────────────────────────────────────────────────────────────

class TaskCreate(TaskBase):
    """
    Schema for creating a new task.
    
    All fields from TaskBase are required except those with defaults.
    """
    pass


class TaskUpdate(BaseModel):
    """
    Schema for updating an existing task.
    
    All fields are optional to support partial updates.
    """
    
    title: Optional[str] = Field(
        default=None,
        min_length=1,
        max_length=200,
        description="Task title (1-200 characters)"
    )
    
    description: Optional[str] = Field(
        default=None,
        max_length=2000,
        description="Detailed task description (max 2000 characters)"
    )
    
    status: Optional[TaskStatus] = Field(
        default=None,
        description="Current task status"
    )
    
    priority: Optional[TaskPriority] = Field(
        default=None,
        description="Task priority level"
    )
    
    due_date: Optional[datetime] = Field(
        default=None,
        description="Optional due date for the task"
    )
    
    project_id: Optional[int] = Field(
        default=None,
        description="ID of the project this task belongs to"
    )
    
    assignee_id: Optional[int] = Field(
        default=None,
        description="ID of the user assigned to this task"
    )
    
    tags: Optional[List[str]] = Field(
        default=None,
        description="List of tags for categorizing the task"
    )
    
    estimated_hours: Optional[float] = Field(
        default=None,
        ge=0,
        le=1000,
        description="Estimated hours to complete (0-1000)"
    )
    
    actual_hours: Optional[float] = Field(
        default=None,
        ge=0,
        le=10000,
        description="Actual hours spent (0-10000)"
    )
    
    # Validators for optional fields
    @field_validator("title", mode="after")
    @classmethod
    def validate_title_optional(cls, v: Optional[str]) -> Optional[str]:
        """Validate title if provided."""
        if v is not None:
            # Remove extra whitespace
            v = " ".join(v.split())
            if any(char in v for char in ["<", ">", "&", '"', "'"]):
                raise ValueError("Title contains invalid characters")
        return v
    
    @field_validator("due_date", mode="after")
    @classmethod
    def validate_due_date_optional(cls, v: Optional[datetime]) -> Optional[datetime]:
        """Validate due date if provided."""
        if v is not None and v < datetime.utcnow():
            raise ValueError("Due date cannot be in the past")
        return v
    
    @field_validator("tags", mode="after")
    @classmethod
    def validate_tags_optional(cls, v: Optional[List[str]]) -> Optional[List[str]]:
        """Validate tags if provided."""
        if v is not None:
            import re
            cleaned = [tag.strip().lower() for tag in v if tag.strip()]
            if len(cleaned) > 10:
                raise ValueError("Maximum 10 tags allowed")
            for tag in cleaned:
                if not re.match(r"^[a-z0-9\-_]+$", tag):
                    raise ValueError(f"Tag '{tag}' contains invalid characters")
            return cleaned
        return v
    
    model_config = ConfigDict(
        json_schema_extra={
            "example": {
                "title": "Updated: JWT authentication with refresh tokens",
                "status": "review",
                "priority": "critical",
                "tags": ["backend", "security", "jwt", "refresh"],
                "estimated_hours": 10.0,
                "assignee_id": 43,
            }
        }
    )


# ────────────────────────────────────────────────────────────────
# Response Schemas
# ────────────────────────────────────────────────────────────────

class TaskResponse(TaskBase):
    """
    Schema for task response data.
    
    Includes all database fields that should be exposed to the client.
    """
    
    id: int = Field(..., description="Unique task ID")
    created_at: datetime = Field(..., description="Creation timestamp")
    updated_at: datetime = Field(..., description="Last update timestamp")
    created_by_id: int = Field(..., description="ID of the user who created the task")
    
    model_config = ConfigDict(
        from_attributes=True,  # Enable ORM mode for SQLAlchemy
        json_schema_extra={
            "example": {
                "id": 1,
                "title": "Implement JWT authentication",
                "description": "Add OAuth2 with JWT tokens and refresh flow",
                "status": "in_progress",
                "priority": "high",
                "due_date": "2024-12-31T23:59:59",
                "tags": ["backend", "security", "jwt"],
                "estimated_hours": 8.5,
                "actual_hours": 12.0,
                "project_id": 1,
                "assignee_id": 42,
                "created_by_id": 1,
                "created_at": "2024-01-15T10:00:00Z",
                "updated_at": "2024-01-15T10:30:00Z",
            }
        }
    )


class TaskListResponse(BaseModel):
    """
    Schema for paginated task list response.
    """
    
    items: List[TaskResponse] = Field(..., description="List of tasks")
    total: int = Field(..., description="Total number of tasks")
    page: int = Field(..., description="Current page number")
    size: int = Field(..., description="Number of items per page")
    pages: int = Field(..., description="Total number of pages")
    
    model_config = ConfigDict(
        json_schema_extra={
            "example": {
                "items": [
                    {
                        "id": 1,
                        "title": "Implement JWT authentication",
                        # ... (full task example)
                    }
                ],
                "total": 42,
                "page": 1,
                "size": 10,
                "pages": 5,
            }
        }
    )


# ────────────────────────────────────────────────────────────────
# Query Parameters Schema
# ────────────────────────────────────────────────────────────────

class TaskQueryParams(BaseModel):
    """
    Schema for task list query parameters.
    """
    
    status: Optional[TaskStatus] = Field(
        default=None,
        description="Filter by task status"
    )
    
    priority: Optional[TaskPriority] = Field(
        default=None,
        description="Filter by task priority"
    )
    
    project_id: Optional[int] = Field(
        default=None,
        description="Filter by project ID"
    )
    
    assignee_id: Optional[int] = Field(
        default=None,
        description="Filter by assignee ID"
    )
    
    created_by_id: Optional[int] = Field(
        default=None,
        description="Filter by creator ID"
    )
    
    tag: Optional[str] = Field(
        default=None,
        description="Filter by tag"
    )
    
    search: Optional[str] = Field(
        default=None,
        description="Search in title and description"
    )
    
    due_before: Optional[datetime] = Field(
        default=None,
        description="Filter tasks due before this date"
    )
    
    due_after: Optional[datetime] = Field(
        default=None,
        description="Filter tasks due after this date"
    )
    
    page: int = Field(
        default=1,
        ge=1,
        description="Page number (starting from 1)"
    )
    
    size: int = Field(
        default=10,
        ge=1,
        le=100,
        description="Number of items per page (max 100)"
    )
    
    sort_by: str = Field(
        default="created_at",
        description="Sort field (created_at, updated_at, due_date, title, priority)"
    )
    
    sort_order: str = Field(
        default="desc",
        description="Sort order (asc or desc)"
    )
    
    @field_validator("sort_by")
    @classmethod
    def validate_sort_by(cls, v: str) -> str:
        """Validate sort field."""
        allowed = ["created_at", "updated_at", "due_date", "title", "priority", "status"]
        if v not in allowed:
            raise ValueError(f"sort_by must be one of: {', '.join(allowed)}")
        return v
    
    @field_validator("sort_order")
    @classmethod
    def validate_sort_order(cls, v: str) -> str:
        """Validate sort order."""
        if v.lower() not in ["asc", "desc"]:
            raise ValueError("sort_order must be 'asc' or 'desc'")
        return v.lower()
```

**Create `app/api/v1/endpoints/tasks.py`** (for demonstration of a complete endpoint):

```python
"""
app/api/v1/endpoints/tasks.py
Task management endpoints.
"""

from fastapi import APIRouter, Depends, Query, status, Request
from typing import List, Optional
from datetime import datetime

from app.schemas.task import (
    TaskCreate,
    TaskUpdate,
    TaskResponse,
    TaskListResponse,
    TaskQueryParams,
)
from app.core.exceptions import (
    NotFoundException,
    BadRequestException,
    ForbiddenException,
)
from app.core.dependencies import get_current_user, get_user_permissions

router = APIRouter()


# ────────────────────────────────────────────────────────────────
# Endpoint: Create Task
# ────────────────────────────────────────────────────────────────

@router.post(
    "/",
    response_model=TaskResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Create a new task",
    description="""
    Creates a new task with the provided data.
    
    **Required permissions**: `task:create`
    
    **Example Request Body**:
    ```json
    {
        "title": "Implement JWT authentication",
        "description": "Add OAuth2 with JWT tokens and refresh flow",
        "status": "todo",
        "priority": "high",
        "due_date": "2024-12-31T23:59:59",
        "tags": ["backend", "security"],
        "estimated_hours": 8.5,
        "project_id": 1,
        "assignee_id": 42
    }
    ```
    """
)
async def create_task(
    request: Request,
    task_data: TaskCreate,
    # current_user: dict = Depends(get_current_user),  # Part 3
    # permissions: dict = Depends(get_user_permissions),  # Part 3
):
    """
    Create a new task.
    
    Args:
        request: FastAPI request object
        task_data: Validated task creation data
        
    Returns:
        TaskResponse: Created task data
    """
    # For now, we'll return a mock response
    # In Part 2, we'll implement the actual database logic
    
    # Mock response
    return TaskResponse(
        id=1,
        title=task_data.title,
        description=task_data.description,
        status=task_data.status,
        priority=task_data.priority,
        due_date=task_data.due_date,
        project_id=task_data.project_id,
        assignee_id=task_data.assignee_id,
        tags=task_data.tags,
        estimated_hours=task_data.estimated_hours,
        actual_hours=task_data.actual_hours,
        created_by_id=1,  # Will come from current_user
        created_at=datetime.utcnow(),
        updated_at=datetime.utcnow(),
    )


# ────────────────────────────────────────────────────────────────
# Endpoint: Get Tasks
# ────────────────────────────────────────────────────────────────

@router.get(
    "/",
    response_model=TaskListResponse,
    summary="Get list of tasks",
    description="""
    Retrieves a paginated list of tasks with optional filtering.
    
    **Required permissions**: `task:read`
    
    **Filtering Examples**:
    - `/tasks?status=in_progress` - Get all in-progress tasks
    - `/tasks?assignee_id=42` - Get tasks assigned to user 42
    - `/tasks?tag=security` - Get tasks tagged with 'security'
    - `/tasks?search=authentication` - Search in title and description
    
    **Sorting Examples**:
    - `/tasks?sort_by=due_date&sort_order=asc` - Sort by due date ascending
    - `/tasks?sort_by=priority&sort_order=desc` - Sort by priority descending
    """
)
async def get_tasks(
    # current_user: dict = Depends(get_current_user),  # Part 3
    # permissions: dict = Depends(get_user_permissions),  # Part 3
    status: Optional[str] = Query(None, description="Filter by status"),
    priority: Optional[str] = Query(None, description="Filter by priority"),
    project_id: Optional[int] = Query(None, description="Filter by project ID"),
    assignee_id: Optional[int] = Query(None, description="Filter by assignee ID"),
    created_by_id: Optional[int] = Query(None, description="Filter by creator ID"),
    tag: Optional[str] = Query(None, description="Filter by tag"),
    search: Optional[str] = Query(None, description="Search in title and description"),
    due_before: Optional[datetime] = Query(None, description="Tasks due before this date"),
    due_after: Optional[datetime] = Query(None, description="Tasks due after this date"),
    page: int = Query(1, ge=1, description="Page number"),
    size: int = Query(10, ge=1, le=100, description="Items per page"),
    sort_by: str = Query("created_at", description="Sort field"),
    sort_order: str = Query("desc", description="Sort order (asc/desc)"),
):
    """
    Get paginated list of tasks with filters.
    
    Returns:
        TaskListResponse: Paginated task list
    """
    # Parse query parameters into a validated object
    params = TaskQueryParams(
        status=status,
        priority=priority,
        project_id=project_id,
        assignee_id=assignee_id,
        created_by_id=created_by_id,
        tag=tag,
        search=search,
        due_before=due_before,
        due_after=due_after,
        page=page,
        size=size,
        sort_by=sort_by,
        sort_order=sort_order,
    )
    
    # Mock response for now
    # In Part 2, we'll implement the actual database query
    
    mock_task = TaskResponse(
        id=1,
        title="Implement JWT authentication",
        description="Add OAuth2 with JWT tokens and refresh flow",
        status="in_progress",
        priority="high",
        due_date=datetime(2024, 12, 31, 23, 59, 59),
        project_id=1,
        assignee_id=42,
        tags=["backend", "security", "jwt"],
        estimated_hours=8.5,
        actual_hours=12.0,
        created_by_id=1,
        created_at=datetime(2024, 1, 15, 10, 0, 0),
        updated_at=datetime(2024, 1, 15, 10, 30, 0),
    )
    
    return TaskListResponse(
        items=[mock_task] * min(size, 10),  # Repeat for demonstration
        total=42,
        page=page,
        size=size,
        pages=5,
    )


# ────────────────────────────────────────────────────────────────
# Endpoint: Get Task by ID
# ────────────────────────────────────────────────────────────────

@router.get(
    "/{task_id}",
    response_model=TaskResponse,
    summary="Get task by ID",
    description="Retrieves a specific task by its ID."
)
async def get_task(
    task_id: int,
    # current_user: dict = Depends(get_current_user),  # Part 3
    # permissions: dict = Depends(get_user_permissions),  # Part 3
):
    """
    Get a single task by ID.
    
    Args:
        task_id: Task ID
        
    Returns:
        TaskResponse: Task data
        
    Raises:
        NotFoundException: If task does not exist
    """
    # Mock response for demonstration
    # In Part 2, we'll fetch from the database
    
    if task_id != 1:
        raise NotFoundException(
            detail=f"Task with ID {task_id} not found",
            error_code="TASK_NOT_FOUND",
        )
    
    return TaskResponse(
        id=1,
        title="Implement JWT authentication",
        description="Add OAuth2 with JWT tokens and refresh flow",
        status="in_progress",
        priority="high",
        due_date=datetime(2024, 12, 31, 23, 59, 59),
        project_id=1,
        assignee_id=42,
        tags=["backend", "security", "jwt"],
        estimated_hours=8.5,
        actual_hours=12.0,
        created_by_id=1,
        created_at=datetime(2024, 1, 15, 10, 0, 0),
        updated_at=datetime(2024, 1, 15, 10, 30, 0),
    )


# ────────────────────────────────────────────────────────────────
# Endpoint: Update Task
# ────────────────────────────────────────────────────────────────

@router.put(
    "/{task_id}",
    response_model=TaskResponse,
    summary="Update a task",
    description="Updates an existing task with the provided data."
)
async def update_task(
    task_id: int,
    task_update: TaskUpdate,
    # current_user: dict = Depends(get_current_user),  # Part 3
    # permissions: dict = Depends(get_user_permissions),  # Part 3
):
    """
    Update an existing task.
    
    Args:
        task_id: Task ID
        task_update: Update data
        
    Returns:
        TaskResponse: Updated task data
        
    Raises:
        NotFoundException: If task does not exist
    """
    # Mock response for demonstration
    # In Part 2, we'll update in the database
    
    if task_id != 1:
        raise NotFoundException(
            detail=f"Task with ID {task_id} not found",
            error_code="TASK_NOT_FOUND",
        )
    
    # Get current task (mock)
    current_task = TaskResponse(
        id=1,
        title="Implement JWT authentication",
        description="Add OAuth2 with JWT tokens and refresh flow",
        status="in_progress",
        priority="high",
        due_date=datetime(2024, 12, 31, 23, 59, 59),
        project_id=1,
        assignee_id=42,
        tags=["backend", "security", "jwt"],
        estimated_hours=8.5,
        actual_hours=12.0,
        created_by_id=1,
        created_at=datetime(2024, 1, 15, 10, 0, 0),
        updated_at=datetime(2024, 1, 15, 10, 30, 0),
    )
    
    # Update only provided fields
    update_data = task_update.model_dump(exclude_unset=True)
    updated_task = current_task.model_copy(update=update_data)
    updated_task.updated_at = datetime.utcnow()
    
    return updated_task


# ────────────────────────────────────────────────────────────────
# Endpoint: Delete Task
# ────────────────────────────────────────────────────────────────

@router.delete(
    "/{task_id}",
    status_code=status.HTTP_204_NO_CONTENT,
    summary="Delete a task",
    description="Permanently deletes a task by its ID."
)
async def delete_task(
    task_id: int,
    # current_user: dict = Depends(get_current_user),  # Part 3
    # permissions: dict = Depends(get_user_permissions),  # Part 3
):
    """
    Delete a task.
    
    Args:
        task_id: Task ID
        
    Raises:
        NotFoundException: If task does not exist
    """
    # Mock implementation
    # In Part 2, we'll delete from the database
    
    if task_id != 1:
        raise NotFoundException(
            detail=f"Task with ID {task_id} not found",
            error_code="TASK_NOT_FOUND",
        )
    
    # No content response
    return None
```

**Update `app/api/v1/api.py` to include task endpoints:**

```python
"""
app/api/v1/api.py
Main API router that includes all v1 endpoints.
"""

from fastapi import APIRouter

from app.api.v1.endpoints import health, tasks

api_router = APIRouter()

# Include health endpoints
api_router.include_router(
    health.router,
    prefix="/health",
    tags=["health"],
)

# Include task endpoints
api_router.include_router(
    tasks.router,
    prefix="/tasks",
    tags=["tasks"],
)

# Root endpoint for v1
@api_router.get("/", tags=["health"])
async def api_root():
    """
    API v1 root endpoint.
    """
    return {
        "version": "v1",
        "status": "operational",
        "endpoints": [
            "/health",
            "/tasks",
        ],
    }
```

### The Verification

Let's test our task endpoints:

**Create a task:**

```bash
curl -X POST http://localhost:8000/api/v1/tasks/ \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Implement JWT authentication",
    "description": "Add OAuth2 with JWT tokens and refresh flow",
    "status": "todo",
    "priority": "high",
    "due_date": "2024-12-31T23:59:59",
    "tags": ["backend", "security", "jwt"],
    "estimated_hours": 8.5
  }'
```

Expected output (mock response):
```json
{
  "id": 1,
  "title": "Implement JWT authentication",
  "description": "Add OAuth2 with JWT tokens and refresh flow",
  "status": "todo",
  "priority": "high",
  "due_date": "2024-12-31T23:59:59",
  "project_id": null,
  "assignee_id": null,
  "tags": ["backend", "security", "jwt"],
  "estimated_hours": 8.5,
  "actual_hours": null,
  "created_by_id": 1,
  "created_at": "2024-01-15T10:30:00.123456",
  "updated_at": "2024-01-15T10:30:00.123456"
}
```

**Get tasks with filters:**

```bash
curl "http://localhost:8000/api/v1/tasks/?status=in_progress&tag=security&page=1&size=5"
```

**Get task by ID:**

```bash
curl http://localhost:8000/api/v1/tasks/1
```

**Test validation error:**

```bash
curl -X POST http://localhost:8000/api/v1/tasks/ \
  -H "Content-Type: application/json" \
  -d '{
    "title": "<script>alert(\"xss\")</script>",
    "status": "invalid_status"
  }'
```

Expected output (validation error):
```json
{
  "success": false,
  "error": {
    "status_code": 422,
    "detail": "Validation error in request",
    "error_code": "VALIDATION_ERROR",
    "data": {
      "validation_errors": [
        {
          "field": "title",
          "message": "Title contains invalid characters",
          "type": "value_error"
        },
        {
          "field": "status",
          "message": "Input should be 'todo', 'in_progress', 'review', 'done' or 'archived'",
          "type": "enum"
        }
      ]
    }
  }
}
```

## Deep Dive: Pydantic Validation in Detail

Pydantic V2 provides powerful validation capabilities. Here's a comprehensive reference:

### Built-in Validators

Pydantic includes many built-in validators for common use cases:

```python
from pydantic import BaseModel, Field, EmailStr, HttpUrl, constr, conint

class User(BaseModel):
    # String validation
    username: constr(min_length=3, max_length=50, pattern=r"^[a-zA-Z0-9_]+$")
    email: EmailStr  # Validates email format
    website: HttpUrl  # Validates URL format
    
    # Number validation
    age: conint(ge=0, le=150)  # Validates integer range
    
    # With Field for more control
    bio: str = Field(
        default="",
        max_length=500,
        description="User biography"
    )
```

### Custom Validators

Use `@field_validator` for field-specific validation:

```python
from pydantic import BaseModel, field_validator

class User(BaseModel):
    password: str
    confirm_password: str
    
    @field_validator("password")
    @classmethod
    def validate_password(cls, v: str) -> str:
        """Ensure password meets complexity requirements."""
        if len(v) < 8:
            raise ValueError("Password must be at least 8 characters")
        if not any(c.isupper() for c in v):
            raise ValueError("Password must contain at least one uppercase letter")
        if not any(c.islower() for c in v):
            raise ValueError("Password must contain at least one lowercase letter")
        if not any(c.isdigit() for c in v):
            raise ValueError("Password must contain at least one number")
        return v
    
    @field_validator("confirm_password", mode="after")
    @classmethod
    def validate_confirm_password(cls, v: str, info) -> str:
        """Ensure password confirmation matches."""
        if "password" in info.data and v != info.data["password"]:
            raise ValueError("Passwords do not match")
        return v
```

### Nested Models

Models can be nested for complex data structures:

```python
class Address(BaseModel):
    street: str
    city: str
    country: str
    postal_code: str

class User(BaseModel):
    name: str
    addresses: List[Address]  # List of nested models
    primary_address: Optional[Address] = None  # Optional nested model
```

### Model Configuration

Control model behavior with `model_config`:

```python
from pydantic import BaseModel, ConfigDict

class User(BaseModel):
    name: str
    email: str
    
    model_config = ConfigDict(
        # Enable ORM mode for SQLAlchemy
        from_attributes=True,
        # Add example for documentation
        json_schema_extra={
            "example": {
                "name": "John Doe",
                "email": "john@example.com"
            }
        },
        # Extra fields handling
        extra="forbid",  # Reject unknown fields
        # Or:
        # extra="allow",  # Accept unknown fields
        # extra="ignore",  # Ignore unknown fields
    )
```

## What We Accomplished

✅ Set up a complete FastAPI project with proper structure
✅ Created a configuration system with Pydantic Settings
✅ Implemented custom exception handlers with standardized responses
✅ Built the main application with middleware and lifecycle management
✅ Created health check endpoints for monitoring
✅ Implemented task endpoints with full Pydantic validation
✅ Set up automatic OpenAPI documentation
✅ Created comprehensive schemas with validators

## Key Takeaways

1. **Configuration**: Use Pydantic Settings for type-safe, environment-aware configuration
2. **Error Handling**: Standardize error responses for better client experience
3. **Validation**: Pydantic provides powerful, declarative data validation
4. **Structure**: Organize code by domain (models, schemas, services, endpoints)
5. **Documentation**: FastAPI generates interactive API docs automatically
6. **Testing**: Always verify each component works before moving on

## What's Next?

In **[Part 2: Database Integration & Data Persistence]** , we'll:
- Set up SQLAlchemy 2.0 with async PostgreSQL
- Create database models for users, tasks, and projects
- Implement Alembic migrations
- Build the Repository pattern for data access
- Create Service layers for business logic

You're ready for the next step. Let's persist data!
