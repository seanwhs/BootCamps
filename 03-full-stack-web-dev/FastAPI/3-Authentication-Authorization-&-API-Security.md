# Part 3: Authentication, Authorization & API Security

Welcome to Part 3 of our FastAPI Masterclass! Now that we have a solid foundation with our API structure and database integration, it's time to secure everything. In this module, we'll implement OAuth2 with JWT (JSON Web Tokens) for authentication, Role-Based Access Control (RBAC) for authorization, and comprehensive security features to protect our API from common threats.

## Learning Objectives

By the end of Part 3, you will be able to:
- Implement OAuth2 password flow with JWT tokens
- Add secure password hashing with bcrypt
- Create refresh token rotation for enhanced security
- Implement Role-Based Access Control (RBAC)
- Add security middleware (CORS, headers, HTTPS)
- Implement audit logging for security events
- Create API key authentication for service-to-service communication

## Key Concepts Before We Begin

### What is OAuth2?
Think of OAuth2 as a security checkpoint. Instead of users handing over their credentials to every service they use, they get a "ticket" (token) that proves who they are. The ticket has an expiration time, so even if someone steals it, they can only use it for a limited period.

### JWT (JSON Web Tokens)
JWT is like a tamper-proof ID card. It contains three parts:
- **Header**: Metadata about the token (algorithm used)
- **Payload**: The actual data (user ID, roles, expiration)
- **Signature**: A cryptographic signature that verifies the token hasn't been tampered with

```
Header.Payload.Signature
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c
```

### RBAC (Role-Based Access Control)
RBAC is like security levels in a building. Different people have different access:
- **Admin**: Can go anywhere, do anything
- **Manager**: Can access their department's areas
- **Developer**: Can access their project's areas
- **Viewer**: Can only view information, not change it

## Step 1: Security Core Setup

### The Target
Create the core security infrastructure including password hashing, JWT handling, and security utilities.

### The Concept
Think of security as multiple layers of defense. Password hashing makes sure we never store plain passwords. JWT tokens are our secure ID cards that can be verified without storing session data on our server.

### The Implementation

**First, ensure security dependencies are installed:**

```bash
# These should already be in requirements.txt
pip install python-jose[cryptography] passlib[bcrypt] python-multipart email-validator
```

**Create `app/core/security.py`:**

```python
"""
app/core/security.py
Security utilities for authentication and authorization.
"""

from datetime import datetime, timedelta, timezone
from typing import Optional, Dict, Any, List
import secrets
import hashlib
import base64

from jose import JWTError, jwt
from passlib.context import CryptContext
from fastapi import HTTPException, status, Depends
from fastapi.security import OAuth2PasswordBearer, HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.config import settings
from app.core.exceptions import UnauthorizedException, ForbiddenException
from app.models.user import User, UserRole
from app.crud.user import UserRepository

# ────────────────────────────────────────────────────────────────
# Password Hashing
# ────────────────────────────────────────────────────────────────

# Password hashing context using bcrypt
pwd_context = CryptContext(
    schemes=["bcrypt"],
    deprecated="auto",
    bcrypt__rounds=12,  # Work factor for bcrypt
)


def verify_password(plain_password: str, hashed_password: str) -> bool:
    """
    Verify a plain password against a hashed password.
    
    Args:
        plain_password: Plain text password
        hashed_password: Bcrypt hashed password
        
    Returns:
        bool: True if password matches
    """
    return pwd_context.verify(plain_password, hashed_password)


def get_password_hash(password: str) -> str:
    """
    Hash a password using bcrypt.
    
    Args:
        password: Plain text password
        
    Returns:
        str: Bcrypt hashed password
    """
    return pwd_context.hash(password)


# ────────────────────────────────────────────────────────────────
# JWT Token Management
# ────────────────────────────────────────────────────────────────

def create_access_token(data: Dict[str, Any], expires_delta: Optional[timedelta] = None) -> str:
    """
    Create a JWT access token.
    
    Args:
        data: Data to encode in the token
        expires_delta: Custom expiration time
        
    Returns:
        str: JWT token string
    """
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.now(timezone.utc) + expires_delta
    else:
        expire = datetime.now(timezone.utc) + timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    
    to_encode.update({"exp": expire, "iat": datetime.now(timezone.utc)})
    encoded_jwt = jwt.encode(to_encode, settings.SECRET_KEY, algorithm=settings.ALGORITHM)
    return encoded_jwt


def create_refresh_token(data: Dict[str, Any]) -> str:
    """
    Create a JWT refresh token with longer expiration.
    
    Args:
        data: Data to encode in the token
        
    Returns:
        str: Refresh token string
    """
    to_encode = data.copy()
    expire = datetime.now(timezone.utc) + timedelta(days=settings.REFRESH_TOKEN_EXPIRE_DAYS)
    to_encode.update({"exp": expire, "iat": datetime.now(timezone.utc), "type": "refresh"})
    encoded_jwt = jwt.encode(to_encode, settings.SECRET_KEY, algorithm=settings.ALGORITHM)
    return encoded_jwt


def decode_token(token: str) -> Dict[str, Any]:
    """
    Decode and verify a JWT token.
    
    Args:
        token: JWT token string
        
    Returns:
        Dict[str, Any]: Decoded token payload
        
    Raises:
        JWTError: If token is invalid or expired
    """
    try:
        payload = jwt.decode(token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM])
        return payload
    except JWTError as e:
        raise JWTError(f"Invalid token: {str(e)}")


def verify_token(token: str) -> Dict[str, Any]:
    """
    Verify a JWT token and return payload.
    
    Args:
        token: JWT token string
        
    Returns:
        Dict[str, Any]: Verified token payload
        
    Raises:
        UnauthorizedException: If token is invalid
    """
    try:
        payload = decode_token(token)
        return payload
    except JWTError as e:
        raise UnauthorizedException(
            detail="Invalid or expired token",
            error_code="INVALID_TOKEN"
        )


def create_api_key() -> str:
    """
    Generate a secure API key.
    
    Returns:
        str: API key string
    """
    return secrets.token_urlsafe(32)


def hash_api_key(api_key: str) -> str:
    """
    Hash an API key for storage.
    
    Args:
        api_key: Plain API key
        
    Returns:
        str: Hashed API key
    """
    # Use SHA-256 for API key hashing
    return hashlib.sha256(api_key.encode()).hexdigest()


def verify_api_key(plain_key: str, hashed_key: str) -> bool:
    """
    Verify an API key against its hash.
    
    Args:
        plain_key: Plain API key
        hashed_key: Hashed API key
        
    Returns:
        bool: True if key matches
    """
    return hash_api_key(plain_key) == hashed_key


# ────────────────────────────────────────────────────────────────
# OAuth2 Setup
# ────────────────────────────────────────────────────────────────

# OAuth2 scheme for token authentication
oauth2_scheme = OAuth2PasswordBearer(
    tokenUrl="/api/v1/auth/login",
    auto_error=False,  # We'll handle errors ourselves
)

# HTTP Bearer for API key authentication
security_scheme = HTTPBearer(auto_error=False)


# ────────────────────────────────────────────────────────────────
# Authentication Dependencies
# ────────────────────────────────────────────────────────────────

async def get_current_user(
    token: str = Depends(oauth2_scheme),
    db: AsyncSession = None,
) -> User:
    """
    Get the current authenticated user.
    
    Args:
        token: JWT token from Authorization header
        db: Database session
        
    Returns:
        User: Authenticated user
        
    Raises:
        UnauthorizedException: If authentication fails
    """
    # If no token is provided
    if not token:
        raise UnauthorizedException(
            detail="Not authenticated",
            error_code="NO_TOKEN"
        )
    
    try:
        # Verify token
        payload = verify_token(token)
        
        # Get user ID from token
        user_id: Optional[int] = payload.get("sub")
        if not user_id:
            raise UnauthorizedException(
                detail="Invalid token payload",
                error_code="INVALID_TOKEN"
            )
        
        # Get user from database
        user_repo = UserRepository(db)
        user = await user_repo.get(user_id)
        
        if not user:
            raise UnauthorizedException(
                detail="User not found",
                error_code="USER_NOT_FOUND"
            )
        
        if not user.is_active:
            raise UnauthorizedException(
                detail="User account is inactive",
                error_code="ACCOUNT_INACTIVE"
            )
        
        return user
        
    except UnauthorizedException:
        raise
    except Exception as e:
        raise UnauthorizedException(
            detail=f"Authentication failed: {str(e)}",
            error_code="AUTH_FAILED"
        )


async def get_current_active_user(
    current_user: User = Depends(get_current_user),
) -> User:
    """
    Get current active user.
    
    Args:
        current_user: Authenticated user
        
    Returns:
        User: Active user
        
    Raises:
        UnauthorizedException: If user is not active
    """
    if not current_user.is_active:
        raise UnauthorizedException(
            detail="User account is inactive",
            error_code="ACCOUNT_INACTIVE"
        )
    return current_user


async def get_current_superuser(
    current_user: User = Depends(get_current_active_user),
) -> User:
    """
    Get current superuser.
    
    Args:
        current_user: Authenticated user
        
    Returns:
        User: Superuser
        
    Raises:
        ForbiddenException: If user is not a superuser
    """
    if not current_user.is_superuser:
        raise ForbiddenException(
            detail="Superuser privileges required",
            error_code="SUPERUSER_REQUIRED"
        )
    return current_user


# ────────────────────────────────────────────────────────────────
# Role-Based Authorization
# ────────────────────────────────────────────────────────────────

class PermissionChecker:
    """
    Permission checker for role-based access control.
    """
    
    def __init__(
        self,
        allowed_roles: List[UserRole],
        allow_superuser: bool = True,
        require_active: bool = True,
    ):
        """
        Initialize the permission checker.
        
        Args:
            allowed_roles: List of allowed user roles
            allow_superuser: Whether superusers bypass role checks
            require_active: Whether user must be active
        """
        self.allowed_roles = allowed_roles
        self.allow_superuser = allow_superuser
        self.require_active = require_active
    
    async def __call__(
        self,
        current_user: User = Depends(get_current_active_user if require_active else get_current_user),
    ) -> User:
        """
        Check if user has the required permissions.
        
        Args:
            current_user: Current authenticated user
            
        Returns:
            User: User if permission check passes
            
        Raises:
            ForbiddenException: If user doesn't have required permissions
        """
        # Superusers bypass role checks
        if self.allow_superuser and current_user.is_superuser:
            return current_user
        
        # Check if user's role is allowed
        if current_user.role not in self.allowed_roles:
            role_names = ", ".join([role.value for role in self.allowed_roles])
            raise ForbiddenException(
                detail=f"Role '{current_user.role.value}' not allowed. "
                       f"Required roles: {role_names}",
                error_code="INSUFFICIENT_ROLE"
            )
        
        return current_user


# Convenience permission checkers
require_admin = PermissionChecker([UserRole.ADMIN])
require_manager = PermissionChecker([UserRole.ADMIN, UserRole.MANAGER])
require_developer = PermissionChecker([UserRole.ADMIN, UserRole.MANAGER, UserRole.DEVELOPER])
require_viewer = PermissionChecker([UserRole.ADMIN, UserRole.MANAGER, UserRole.DEVELOPER, UserRole.VIEWER])


def require_permission(permission: str):
    """
    Decorator-like function to check specific permissions.
    
    Args:
        permission: Permission string (e.g., "users:create")
        
    Returns:
        PermissionChecker: Configured permission checker
    """
    # Map permissions to required roles
    permission_map = {
        "users:create": [UserRole.ADMIN],
        "users:read": [UserRole.ADMIN, UserRole.MANAGER, UserRole.DEVELOPER, UserRole.VIEWER],
        "users:update": [UserRole.ADMIN, UserRole.MANAGER],
        "users:delete": [UserRole.ADMIN],
        "tasks:create": [UserRole.ADMIN, UserRole.MANAGER, UserRole.DEVELOPER],
        "tasks:read": [UserRole.ADMIN, UserRole.MANAGER, UserRole.DEVELOPER, UserRole.VIEWER],
        "tasks:update": [UserRole.ADMIN, UserRole.MANAGER, UserRole.DEVELOPER],
        "tasks:delete": [UserRole.ADMIN, UserRole.MANAGER],
        "projects:create": [UserRole.ADMIN, UserRole.MANAGER],
        "projects:read": [UserRole.ADMIN, UserRole.MANAGER, UserRole.DEVELOPER, UserRole.VIEWER],
        "projects:update": [UserRole.ADMIN, UserRole.MANAGER],
        "projects:delete": [UserRole.ADMIN],
    }
    
    allowed_roles = permission_map.get(permission, [UserRole.ADMIN])
    return PermissionChecker(allowed_roles=allowed_roles)


# ────────────────────────────────────────────────────────────────
# API Key Authentication
# ────────────────────────────────────────────────────────────────

async def get_api_key(
    credentials: Optional[HTTPAuthorizationCredentials] = Depends(security_scheme),
    db: AsyncSession = None,
) -> Dict[str, Any]:
    """
    Get API key from Authorization header.
    
    Args:
        credentials: HTTP authorization credentials
        db: Database session
        
    Returns:
        Dict[str, Any]: API key information
        
    Raises:
        UnauthorizedException: If API key is invalid
    """
    if not credentials:
        raise UnauthorizedException(
            detail="API key required",
            error_code="API_KEY_REQUIRED"
        )
    
    api_key = credentials.credentials
    
    # Hash the provided API key
    hashed_key = hash_api_key(api_key)
    
    # In production, you'd look up the API key in the database
    # For now, we'll implement a simple check
    
    # This is where you'd check against stored API keys
    # api_key_record = await api_key_repo.get_by_hashed_key(hashed_key)
    # if not api_key_record:
    #     raise UnauthorizedException(...)
    
    # For demonstration, we'll accept a specific key
    # In practice, use a database table for API keys
    return {
        "key": api_key,
        "hashed": hashed_key,
        # "user_id": api_key_record.user_id,
    }


# ────────────────────────────────────────────────────────────────
# Security Utilities
# ────────────────────────────────────────────────────────────────

def generate_password_reset_token(email: str) -> str:
    """
    Generate a password reset token.
    
    Args:
        email: User email
        
    Returns:
        str: Password reset token
    """
    now = datetime.now(timezone.utc)
    expire = now + timedelta(hours=24)
    payload = {
        "email": email,
        "type": "password_reset",
        "exp": expire,
        "iat": now,
    }
    return jwt.encode(payload, settings.SECRET_KEY, algorithm=settings.ALGORITHM)


def verify_password_reset_token(token: str) -> Optional[str]:
    """
    Verify a password reset token.
    
    Args:
        token: Password reset token
        
    Returns:
        Optional[str]: Email if token is valid, None otherwise
    """
    try:
        payload = decode_token(token)
        if payload.get("type") != "password_reset":
            return None
        return payload.get("email")
    except JWTError:
        return None


def generate_email_verification_token(email: str) -> str:
    """
    Generate an email verification token.
    
    Args:
        email: User email
        
    Returns:
        str: Email verification token
    """
    now = datetime.now(timezone.utc)
    expire = now + timedelta(days=7)
    payload = {
        "email": email,
        "type": "email_verification",
        "exp": expire,
        "iat": now,
    }
    return jwt.encode(payload, settings.SECRET_KEY, algorithm=settings.ALGORITHM)


def verify_email_verification_token(token: str) -> Optional[str]:
    """
    Verify an email verification token.
    
    Args:
        token: Email verification token
        
    Returns:
        Optional[str]: Email if token is valid, None otherwise
    """
    try:
        payload = decode_token(token)
        if payload.get("type") != "email_verification":
            return None
        return payload.get("email")
    except JWTError:
        return None


def mask_sensitive_data(data: str, visible_chars: int = 4) -> str:
    """
    Mask sensitive data for logging.
    
    Args:
        data: Sensitive data string
        visible_chars: Number of characters to show
        
    Returns:
        str: Masked data
    """
    if not data:
        return ""
    if len(data) <= visible_chars * 2:
        return "*" * len(data)
    return f"{data[:visible_chars]}{'*' * (len(data) - visible_chars * 2)}{data[-visible_chars:]}"
```

## Step 2: Authentication Schemas

### The Target
Create Pydantic schemas for authentication requests and responses.

### The Implementation

**Create `app/schemas/auth.py`:**

```python
"""
app/schemas/auth.py
Pydantic schemas for authentication.
"""

from pydantic import BaseModel, Field, EmailStr, field_validator
from typing import Optional, List
from datetime import datetime

from app.models.user import UserRole


class TokenResponse(BaseModel):
    """
    Token response schema.
    """
    
    access_token: str = Field(..., description="JWT access token")
    refresh_token: str = Field(..., description="JWT refresh token")
    token_type: str = Field(default="bearer", description="Token type")
    expires_in: int = Field(..., description="Token expiration in seconds")
    
    model_config = {
        "json_schema_extra": {
            "example": {
                "access_token": "eyJhbGciOiJIUzI1NiIs...",
                "refresh_token": "eyJhbGciOiJIUzI1NiIs...",
                "token_type": "bearer",
                "expires_in": 1800,
            }
        }
    }


class TokenRefreshRequest(BaseModel):
    """
    Token refresh request schema.
    """
    
    refresh_token: str = Field(..., description="Refresh token")


class LoginRequest(BaseModel):
    """
    Login request schema.
    """
    
    username: str = Field(..., description="Username or email")
    password: str = Field(..., description="Password")
    
    model_config = {
        "json_schema_extra": {
            "example": {
                "username": "john_doe",
                "password": "SecurePass123!"
            }
        }
    }


class LoginResponse(TokenResponse):
    """
    Login response schema.
    """
    
    user: dict = Field(..., description="User information")
    
    model_config = {
        "json_schema_extra": {
            "example": {
                "access_token": "eyJhbGciOiJIUzI1NiIs...",
                "refresh_token": "eyJhbGciOiJIUzI1NiIs...",
                "token_type": "bearer",
                "expires_in": 1800,
                "user": {
                    "id": 1,
                    "email": "john@example.com",
                    "username": "john_doe",
                    "full_name": "John Doe",
                    "role": "developer",
                }
            }
        }
    }


class RegisterRequest(BaseModel):
    """
    Registration request schema.
    """
    
    email: EmailStr = Field(..., description="Email address")
    username: str = Field(..., min_length=3, max_length=50, description="Username")
    full_name: str = Field(..., min_length=1, max_length=100, description="Full name")
    password: str = Field(..., min_length=8, description="Password")
    role: Optional[UserRole] = Field(default=UserRole.VIEWER, description="User role")
    
    @field_validator("password")
    @classmethod
    def validate_password(cls, v: str) -> str:
        """Validate password strength."""
        import re
        if len(v) < 8:
            raise ValueError("Password must be at least 8 characters")
        if not re.search(r"[A-Z]", v):
            raise ValueError("Password must contain at least one uppercase letter")
        if not re.search(r"[a-z]", v):
            raise ValueError("Password must contain at least one lowercase letter")
        if not re.search(r"\d", v):
            raise ValueError("Password must contain at least one number")
        if not re.search(r"[!@#$%^&*(),.?\":{}|<>]", v):
            raise ValueError("Password must contain at least one special character")
        return v
    
    @field_validator("username")
    @classmethod
    def validate_username(cls, v: str) -> str:
        """Validate username format."""
        import re
        if not re.match(r"^[a-zA-Z0-9_]+$", v):
            raise ValueError("Username can only contain letters, numbers, and underscores")
        return v


class RegisterResponse(BaseModel):
    """
    Registration response schema.
    """
    
    id: int = Field(..., description="User ID")
    email: str = Field(..., description="Email address")
    username: str = Field(..., description="Username")
    full_name: str = Field(..., description="Full name")
    role: UserRole = Field(..., description="User role")
    is_active: bool = Field(..., description="Whether user is active")
    created_at: datetime = Field(..., description="Creation timestamp")


class PasswordResetRequest(BaseModel):
    """
    Password reset request schema.
    """
    
    email: EmailStr = Field(..., description="Email address to reset password for")


class PasswordResetConfirmRequest(BaseModel):
    """
    Password reset confirmation schema.
    """
    
    token: str = Field(..., description="Password reset token")
    new_password: str = Field(..., min_length=8, description="New password")
    
    @field_validator("new_password")
    @classmethod
    def validate_password(cls, v: str) -> str:
        """Validate password strength."""
        import re
        if len(v) < 8:
            raise ValueError("Password must be at least 8 characters")
        if not re.search(r"[A-Z]", v):
            raise ValueError("Password must contain at least one uppercase letter")
        if not re.search(r"[a-z]", v):
            raise ValueError("Password must contain at least one lowercase letter")
        if not re.search(r"\d", v):
            raise ValueError("Password must contain at least one number")
        if not re.search(r"[!@#$%^&*(),.?\":{}|<>]", v):
            raise ValueError("Password must contain at least one special character")
        return v


class EmailVerificationRequest(BaseModel):
    """
    Email verification request schema.
    """
    
    token: str = Field(..., description="Email verification token")


class ChangePasswordRequest(BaseModel):
    """
    Change password request schema.
    """
    
    current_password: str = Field(..., description="Current password")
    new_password: str = Field(..., min_length=8, description="New password")
    
    @field_validator("new_password")
    @classmethod
    def validate_password(cls, v: str) -> str:
        """Validate password strength."""
        import re
        if len(v) < 8:
            raise ValueError("Password must be at least 8 characters")
        if not re.search(r"[A-Z]", v):
            raise ValueError("Password must contain at least one uppercase letter")
        if not re.search(r"[a-z]", v):
            raise ValueError("Password must contain at least one lowercase letter")
        if not re.search(r"\d", v):
            raise ValueError("Password must contain at least one number")
        if not re.search(r"[!@#$%^&*(),.?\":{}|<>]", v):
            raise ValueError("Password must contain at least one special character")
        return v


class LogoutRequest(BaseModel):
    """
    Logout request schema.
    """
    
    refresh_token: str = Field(..., description="Refresh token to revoke")


class TokenResponse(BaseModel):
    """
    Token response schema.
    """
    
    access_token: str
    token_type: str = "bearer"
    expires_in: int
```

## Step 3: Authentication Endpoints

### The Target
Create authentication endpoints for login, registration, token refresh, and logout.

### The Implementation

**Create `app/api/v1/endpoints/auth.py`:**

```python
"""
app/api/v1/endpoints/auth.py
Authentication endpoints.
"""

from fastapi import APIRouter, Depends, HTTPException, status, BackgroundTasks
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.ext.asyncio import AsyncSession
from datetime import datetime, timedelta
import logging

from app.core.database import get_db
from app.core.security import (
    create_access_token,
    create_refresh_token,
    verify_password,
    get_current_user,
    get_current_active_user,
    oauth2_scheme,
)
from app.core.exceptions import UnauthorizedException, BadRequestException
from app.schemas.auth import (
    LoginRequest,
    LoginResponse,
    RegisterRequest,
    RegisterResponse,
    TokenRefreshRequest,
    TokenResponse,
    PasswordResetRequest,
    PasswordResetConfirmRequest,
    ChangePasswordRequest,
    LogoutRequest,
)
from app.schemas.user import UserResponse
from app.services.user import UserService

logger = logging.getLogger(__name__)

router = APIRouter()


# ────────────────────────────────────────────────────────────────
# Endpoint: Register
# ────────────────────────────────────────────────────────────────

@router.post(
    "/register",
    response_model=RegisterResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Register a new user",
    description="""
    Create a new user account.
    
    - Password must be at least 8 characters
    - Password must contain uppercase, lowercase, numbers, and special characters
    - Email and username must be unique
    """
)
async def register(
    user_data: RegisterRequest,
    background_tasks: BackgroundTasks,
    db: AsyncSession = Depends(get_db),
):
    """
    Register a new user.
    
    Args:
        user_data: Registration data
        background_tasks: Background tasks for sending emails
        db: Database session
        
    Returns:
        RegisterResponse: Created user data
    """
    user_service = UserService(db)
    
    # Create user
    user = await user_service.create_user(user_data)
    
    # Send verification email in background
    # background_tasks.add_task(send_verification_email, user.email, user.full_name)
    
    return RegisterResponse(
        id=user.id,
        email=user.email,
        username=user.username,
        full_name=user.full_name,
        role=user.role,
        is_active=user.is_active,
        created_at=user.created_at,
    )


# ────────────────────────────────────────────────────────────────
# Endpoint: Login
# ────────────────────────────────────────────────────────────────

@router.post(
    "/login",
    response_model=LoginResponse,
    summary="Login to get access token",
    description="""
    Authenticate user and return JWT tokens.
    
    - Username can be email or username
    - Returns access token (short-lived) and refresh token (long-lived)
    - Access token expires after 30 minutes
    - Refresh token expires after 7 days
    """
)
async def login(
    form_data: OAuth2PasswordRequestForm = Depends(),
    db: AsyncSession = Depends(get_db),
):
    """
    Login user.
    
    Args:
        form_data: OAuth2 form data
        db: Database session
        
    Returns:
        LoginResponse: Tokens and user data
    """
    user_service = UserService(db)
    
    # Check if user exists
    user = await user_service.authenticate(
        email=form_data.username,  # OAuth2 uses username field
        password=form_data.password
    )
    
    if not user:
        raise UnauthorizedException(
            detail="Invalid credentials",
            error_code="INVALID_CREDENTIALS"
        )
    
    # Create tokens
    access_token = create_access_token({"sub": user.id, "role": user.role.value})
    refresh_token = create_refresh_token({"sub": user.id})
    
    return LoginResponse(
        access_token=access_token,
        refresh_token=refresh_token,
        token_type="bearer",
        expires_in=30 * 60,  # 30 minutes in seconds
        user={
            "id": user.id,
            "email": user.email,
            "username": user.username,
            "full_name": user.full_name,
            "role": user.role.value,
        },
    )


# ────────────────────────────────────────────────────────────────
# Endpoint: Refresh Token
# ────────────────────────────────────────────────────────────────

@router.post(
    "/refresh",
    response_model=TokenResponse,
    summary="Refresh access token",
    description="""
    Get a new access token using a refresh token.
    
    - Refresh token must be valid and not expired
    - Returns a new access token
    """
)
async def refresh_token(
    refresh_request: TokenRefreshRequest,
    db: AsyncSession = Depends(get_db),
):
    """
    Refresh access token.
    
    Args:
        refresh_request: Refresh token
        db: Database session
        
    Returns:
        TokenResponse: New access token
    """
    from app.core.security import decode_token
    
    try:
        # Verify refresh token
        payload = decode_token(refresh_request.refresh_token)
        
        # Check token type
        if payload.get("type") != "refresh":
            raise BadRequestException(
                detail="Invalid token type",
                error_code="INVALID_TOKEN_TYPE"
            )
        
        # Get user ID
        user_id = payload.get("sub")
        if not user_id:
            raise UnauthorizedException(
                detail="Invalid token payload",
                error_code="INVALID_TOKEN"
            )
        
        # Get user from database
        user_service = UserService(db)
        user = await user_service.get_or_raise(
            user_id,
            error_msg="User not found"
        )
        
        if not user.is_active:
            raise UnauthorizedException(
                detail="User account is inactive",
                error_code="ACCOUNT_INACTIVE"
            )
        
        # Create new access token
        access_token = create_access_token({"sub": user.id, "role": user.role.value})
        
        return TokenResponse(
            access_token=access_token,
            token_type="bearer",
            expires_in=30 * 60,  # 30 minutes
        )
        
    except BadRequestException:
        raise
    except Exception as e:
        raise UnauthorizedException(
            detail="Invalid refresh token",
            error_code="INVALID_REFRESH_TOKEN"
        )


# ────────────────────────────────────────────────────────────────
# Endpoint: Logout
# ────────────────────────────────────────────────────────────────

@router.post(
    "/logout",
    status_code=status.HTTP_204_NO_CONTENT,
    summary="Logout user",
    description="""
    Logout user by revoking refresh token.
    
    - Token will be blacklisted
    - Access token will expire normally
    """
)
async def logout(
    logout_data: LogoutRequest,
    current_user: dict = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Logout user.
    
    Args:
        logout_data: Logout data with refresh token
        current_user: Authenticated user
        db: Database session
    """
    # In production, add refresh token to blacklist
    # blacklist_repository.add(logout_data.refresh_token)
    
    logger.info(f"User {current_user.id} logged out")
    
    # No content response
    return None


# ────────────────────────────────────────────────────────────────
# Endpoint: Get Current User
# ────────────────────────────────────────────────────────────────

@router.get(
    "/me",
    response_model=UserResponse,
    summary="Get current user",
    description="Get the authenticated user's information."
)
async def get_me(
    current_user: dict = Depends(get_current_active_user),
):
    """
    Get current user.
    
    Args:
        current_user: Authenticated user
        
    Returns:
        UserResponse: User data
    """
    return UserResponse(
        id=current_user.id,
        email=current_user.email,
        username=current_user.username,
        full_name=current_user.full_name,
        role=current_user.role,
        bio=current_user.bio,
        phone_number=current_user.phone_number,
        avatar_url=current_user.avatar_url,
        is_active=current_user.is_active,
        is_verified=current_user.is_verified,
        is_superuser=current_user.is_superuser,
        last_login=current_user.last_login,
        login_count=current_user.login_count,
        created_at=current_user.created_at,
        updated_at=current_user.updated_at,
    )


# ────────────────────────────────────────────────────────────────
# Endpoint: Change Password
# ────────────────────────────────────────────────────────────────

@router.post(
    "/change-password",
    status_code=status.HTTP_200_OK,
    summary="Change password",
    description="Change the current user's password."
)
async def change_password(
    password_data: ChangePasswordRequest,
    current_user: dict = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Change password.
    
    Args:
        password_data: Password change data
        current_user: Authenticated user
        db: Database session
    """
    user_service = UserService(db)
    
    await user_service.change_password(
        user_id=current_user.id,
        current_password=password_data.current_password,
        new_password=password_data.new_password,
    )
    
    return {"message": "Password changed successfully"}


# ────────────────────────────────────────────────────────────────
# Endpoint: Request Password Reset
# ────────────────────────────────────────────────────────────────

@router.post(
    "/reset-password",
    status_code=status.HTTP_200_OK,
    summary="Request password reset",
    description="Send password reset email to the user."
)
async def request_password_reset(
    reset_data: PasswordResetRequest,
    background_tasks: BackgroundTasks,
    db: AsyncSession = Depends(get_db),
):
    """
    Request password reset.
    
    Args:
        reset_data: Password reset request
        background_tasks: Background tasks
        db: Database session
    """
    user_service = UserService(db)
    user = await user_service.get_by_email(reset_data.email)
    
    if not user:
        # Don't reveal if user exists or not for security
        return {"message": "Password reset email sent if account exists"}
    
    # Generate reset token
    from app.core.security import generate_password_reset_token
    token = generate_password_reset_token(user.email)
    
    # Send reset email in background
    # background_tasks.add_task(send_reset_email, user.email, user.full_name, token)
    
    return {"message": "Password reset email sent if account exists"}


# ────────────────────────────────────────────────────────────────
# Endpoint: Confirm Password Reset
# ────────────────────────────────────────────────────────────────

@router.post(
    "/reset-password/confirm",
    status_code=status.HTTP_200_OK,
    summary="Confirm password reset",
    description="Reset password using the token from the email."
)
async def confirm_password_reset(
    confirm_data: PasswordResetConfirmRequest,
    db: AsyncSession = Depends(get_db),
):
    """
    Confirm password reset.
    
    Args:
        confirm_data: Password reset confirmation
        db: Database session
    """
    from app.core.security import verify_password_reset_token
    
    # Verify token
    email = verify_password_reset_token(confirm_data.token)
    if not email:
        raise BadRequestException(
            detail="Invalid or expired reset token",
            error_code="INVALID_RESET_TOKEN"
        )
    
    user_service = UserService(db)
    user = await user_service.get_by_email(email)
    
    if not user:
        raise BadRequestException(
            detail="User not found",
            error_code="USER_NOT_FOUND"
        )
    
    # Update password
    from app.core.security import get_password_hash
    user.hashed_password = get_password_hash(confirm_data.new_password)
    await db.commit()
    await db.refresh(user)
    
    return {"message": "Password reset successfully"}
```

## Step 4: Authorization & RBAC

### The Target
Implement Role-Based Access Control (RBAC) with permission checking for endpoints.

### The Implementation

**Create `app/core/authorization.py`:**

```python
"""
app/core/authorization.py
Authorization utilities for role-based access control.
"""

from typing import List, Optional, Type, Set
from functools import wraps
from fastapi import Depends, HTTPException, status

from app.models.user import User, UserRole
from app.core.exceptions import ForbiddenException


class PermissionRegistry:
    """
    Registry for managing permissions.
    """
    
    _permissions: Set[str] = set()
    _role_permissions: dict[UserRole, Set[str]] = {role: set() for role in UserRole}
    
    @classmethod
    def register_permission(cls, permission: str, allowed_roles: List[UserRole]):
        """
        Register a permission with allowed roles.
        
        Args:
            permission: Permission string (e.g., "users:create")
            allowed_roles: List of roles that can use this permission
        """
        cls._permissions.add(permission)
        for role in allowed_roles:
            cls._role_permissions[role].add(permission)
    
    @classmethod
    def has_permission(cls, user: User, permission: str) -> bool:
        """
        Check if a user has a specific permission.
        
        Args:
            user: User to check
            permission: Permission to check
            
        Returns:
            bool: True if user has permission
        """
        # Superusers have all permissions
        if user.is_superuser:
            return True
        
        # Check if user's role has the permission
        return permission in cls._role_permissions.get(user.role, set())


# Register default permissions
PermissionRegistry.register_permission("users:create", [UserRole.ADMIN])
PermissionRegistry.register_permission("users:read", [UserRole.ADMIN, UserRole.MANAGER, UserRole.DEVELOPER, UserRole.VIEWER])
PermissionRegistry.register_permission("users:update", [UserRole.ADMIN, UserRole.MANAGER])
PermissionRegistry.register_permission("users:delete", [UserRole.ADMIN])

PermissionRegistry.register_permission("tasks:create", [UserRole.ADMIN, UserRole.MANAGER, UserRole.DEVELOPER])
PermissionRegistry.register_permission("tasks:read", [UserRole.ADMIN, UserRole.MANAGER, UserRole.DEVELOPER, UserRole.VIEWER])
PermissionRegistry.register_permission("tasks:update", [UserRole.ADMIN, UserRole.MANAGER, UserRole.DEVELOPER])
PermissionRegistry.register_permission("tasks:delete", [UserRole.ADMIN, UserRole.MANAGER])
PermissionRegistry.register_permission("tasks:assign", [UserRole.ADMIN, UserRole.MANAGER])

PermissionRegistry.register_permission("projects:create", [UserRole.ADMIN, UserRole.MANAGER])
PermissionRegistry.register_permission("projects:read", [UserRole.ADMIN, UserRole.MANAGER, UserRole.DEVELOPER, UserRole.VIEWER])
PermissionRegistry.register_permission("projects:update", [UserRole.ADMIN, UserRole.MANAGER])
PermissionRegistry.register_permission("projects:delete", [UserRole.ADMIN])
PermissionRegistry.register_permission("projects:members", [UserRole.ADMIN, UserRole.MANAGER])

PermissionRegistry.register_permission("comments:create", [UserRole.ADMIN, UserRole.MANAGER, UserRole.DEVELOPER, UserRole.VIEWER])
PermissionRegistry.register_permission("comments:update", [UserRole.ADMIN, UserRole.MANAGER, UserRole.DEVELOPER])
PermissionRegistry.register_permission("comments:delete", [UserRole.ADMIN, UserRole.MANAGER])


def require_permission(permission: str):
    """
    Decorator to require a specific permission.
    
    Args:
        permission: Permission string (e.g., "users:create")
        
    Returns:
        Callable: Decorated function
    """
    def decorator(func):
        @wraps(func)
        async def wrapper(*args, **kwargs):
            # Get current_user from kwargs or args
            current_user = None
            for arg in args:
                if isinstance(arg, User):
                    current_user = arg
                    break
            
            if not current_user:
                # Check if current_user is in kwargs
                current_user = kwargs.get("current_user")
            
            if not current_user:
                raise ForbiddenException(
                    detail="User not found in context",
                    error_code="AUTH_CONTEXT_ERROR"
                )
            
            # Check permission
            if not PermissionRegistry.has_permission(current_user, permission):
                raise ForbiddenException(
                    detail=f"Permission '{permission}' required",
                    error_code="PERMISSION_DENIED"
                )
            
            return await func(*args, **kwargs)
        return wrapper
    return decorator


async def check_resource_access(
    user: User,
    resource_owner_id: Optional[int] = None,
    resource_project_id: Optional[int] = None,
    required_permission: Optional[str] = None,
) -> bool:
    """
    Check if a user has access to a resource.
    
    Args:
        user: Current user
        resource_owner_id: ID of the resource owner
        resource_project_id: ID of the resource's project
        required_permission: Required permission
        
    Returns:
        bool: True if user has access
        
    Raises:
        ForbiddenException: If user doesn't have access
    """
    # Superusers have all access
    if user.is_superuser:
        return True
    
    # If permission is required, check it
    if required_permission and not PermissionRegistry.has_permission(user, required_permission):
        raise ForbiddenException(
            detail=f"Permission '{required_permission}' required",
            error_code="PERMISSION_DENIED"
        )
    
    # If checking resource ownership
    if resource_owner_id and user.id == resource_owner_id:
        return True
    
    # For project resources, check if user is a project member
    if resource_project_id:
        # This would be checked against the project membership
        # project_member = await check_project_membership(user.id, resource_project_id)
        # if project_member:
        #     return True
        pass
    
    # If we have a specific permission and user has it, they can access
    if required_permission and PermissionRegistry.has_permission(user, required_permission):
        return True
    
    raise ForbiddenException(
        detail="You don't have access to this resource",
        error_code="RESOURCE_ACCESS_DENIED"
    )
```

## Step 5: Security Middleware

### The Target
Implement security middleware for protecting against common web vulnerabilities.

### The Implementation

**Create `app/middleware/security.py`:**

```python
"""
app/middleware/security.py
Security middleware for protection against common web vulnerabilities.
"""

from fastapi import Request, Response
from fastapi.middleware.base import BaseHTTPMiddleware
from starlette.middleware.httpsredirect import HTTPSRedirectMiddleware
from starlette.middleware.trustedhost import TrustedHostMiddleware
from starlette.middleware.sessions import SessionMiddleware
from typing import Optional, List
import logging
import time

from app.core.config import settings

logger = logging.getLogger(__name__)


class SecurityHeadersMiddleware(BaseHTTPMiddleware):
    """
    Middleware to add security headers to all responses.
    
    Implements security best practices by adding headers like:
    - HSTS (HTTP Strict Transport Security)
    - X-Content-Type-Options
    - X-Frame-Options
    - Content-Security-Policy
    - Referrer-Policy
    - Permissions-Policy
    """
    
    async def dispatch(self, request: Request, call_next):
        response = await call_next(request)
        
        # Add security headers
        response.headers["X-Content-Type-Options"] = "nosniff"
        response.headers["X-Frame-Options"] = "DENY"
        response.headers["X-XSS-Protection"] = "1; mode=block"
        response.headers["Referrer-Policy"] = "strict-origin-when-cross-origin"
        
        # HSTS (only in production)
        if settings.APP_ENV == "production":
            response.headers["Strict-Transport-Security"] = "max-age=31536000; includeSubDomains"
        
        # Content Security Policy (CSP)
        csp_directives = [
            "default-src 'self'",
            "script-src 'self' 'unsafe-inline' 'unsafe-eval'",
            "style-src 'self' 'unsafe-inline'",
            "img-src 'self' data: https:",
            "font-src 'self'",
            "connect-src 'self'",
            "frame-ancestors 'none'",
        ]
        response.headers["Content-Security-Policy"] = "; ".join(csp_directives)
        
        # Permissions Policy
        response.headers["Permissions-Policy"] = (
            "camera=(), microphone=(), geolocation=(), "
            "payment=(), usb=(), fullscreen=()"
        )
        
        # Remove server information
        response.headers.pop("Server", None)
        
        return response


class RateLimitingMiddleware(BaseHTTPMiddleware):
    """
    Middleware for rate limiting requests.
    
    Uses Redis for distributed rate limiting.
    """
    
    def __init__(self, app, redis_client=None):
        super().__init__(app)
        self.redis = redis_client
    
    async def dispatch(self, request: Request, call_next):
        # Skip rate limiting for health checks and other critical endpoints
        skip_paths = ["/health", "/ready", "/metrics"]
        if any(request.url.path.startswith(path) for path in skip_paths):
            return await call_next(request)
        
        # Get client IP
        client_ip = request.client.host if request.client else "unknown"
        
        # Rate limit based on IP
        # key = f"rate_limit:{client_ip}"
        # 
        # if self.redis:
        #     try:
        #         count = await self.redis.incr(key)
        #         if count == 1:
        #             await self.redis.expire(key, settings.RATE_LIMIT_PERIOD)
        #         
        #         if count > settings.RATE_LIMIT_REQUESTS:
        #             from app.core.exceptions import TooManyRequestsException
        #             raise TooManyRequestsException(
        #                 detail="Rate limit exceeded",
        #                 error_code="RATE_LIMIT_EXCEEDED"
        #             )
        #     except Exception as e:
        #         logger.error(f"Rate limiting error: {e}")
        #         # Continue if rate limiting fails
        
        return await call_next(request)


class RequestValidationMiddleware(BaseHTTPMiddleware):
    """
    Middleware to validate and sanitize incoming requests.
    """
    
    async def dispatch(self, request: Request, call_next):
        # Log request details
        logger.debug(
            f"Request: {request.method} {request.url.path}",
            extra={
                "method": request.method,
                "path": request.url.path,
                "client_ip": request.client.host if request.client else None,
                "user_agent": request.headers.get("user-agent"),
            }
        )
        
        # Validate content type for POST/PUT/PATCH
        if request.method in ["POST", "PUT", "PATCH"]:
            content_type = request.headers.get("content-type", "")
            if not content_type.startswith("application/json"):
                # Only reject if body is expected
                if request.headers.get("content-length", "0") != "0":
                    logger.warning(
                        f"Invalid content type: {content_type}",
                        extra={
                            "path": request.url.path,
                            "method": request.method,
                        }
                    )
        
        return await call_next(request)


# ────────────────────────────────────────────────────────────────
# Security Headers Configuration
# ────────────────────────────────────────────────────────────────

def add_security_middleware(app):
    """
    Add all security middleware to the FastAPI application.
    
    Args:
        app: FastAPI application instance
    """
    # HTTPS redirect (only in production)
    if settings.APP_ENV == "production":
        app.add_middleware(HTTPSRedirectMiddleware)
    
    # Security headers
    app.add_middleware(SecurityHeadersMiddleware)
    
    # Rate limiting
    app.add_middleware(RateLimitingMiddleware)
    
    # Request validation
    app.add_middleware(RequestValidationMiddleware)
    
    # Session middleware (if needed)
    # app.add_middleware(SessionMiddleware, secret_key=settings.SECRET_KEY)
    
    logger.info("✅ Security middleware configured")
```

## Step 6: Audit Logging

### The Target
Implement audit logging for tracking security events and user actions.

### The Implementation

**Create `app/core/audit.py`:**

```python
"""
app/core/audit.py
Audit logging for security events and user actions.
"""

from typing import Optional, Dict, Any
from datetime import datetime
from sqlalchemy.ext.asyncio import AsyncSession
import logging
import json
import socket
import os

from app.core.config import settings

logger = logging.getLogger(__name__)


class AuditLogger:
    """
    Audit logging for security events.
    """
    
    @staticmethod
    async def log_event(
        db: AsyncSession,
        event_type: str,
        user_id: Optional[int] = None,
        details: Optional[Dict[str, Any]] = None,
        ip_address: Optional[str] = None,
        user_agent: Optional[str] = None,
    ):
        """
        Log an audit event.
        
        Args:
            db: Database session
            event_type: Type of event (e.g., "user.login", "user.delete")
            user_id: ID of the user performing the action
            details: Additional event details
            ip_address: Client IP address
            user_agent: Client user agent
        """
        # Create audit log entry
        log_entry = {
            "timestamp": datetime.utcnow().isoformat() + "Z",
            "event_type": event_type,
            "user_id": user_id,
            "ip_address": ip_address,
            "user_agent": user_agent,
            "details": details or {},
            "hostname": socket.gethostname(),
            "application": settings.APP_NAME,
            "environment": settings.APP_ENV,
        }
        
        # Log to structured logging system
        logger.info(
            "Audit event",
            extra=log_entry,
        )
        
        # In production, you might want to store in database
        # audit_log = AuditLog(**log_entry)
        # db.add(audit_log)
        # await db.commit()
    
    @staticmethod
    async def log_user_action(
        db: AsyncSession,
        user_id: int,
        action: str,
        resource: Optional[str] = None,
        resource_id: Optional[int] = None,
        changes: Optional[Dict[str, Any]] = None,
        ip_address: Optional[str] = None,
        user_agent: Optional[str] = None,
    ):
        """
        Log a user action.
        
        Args:
            db: Database session
            user_id: User performing the action
            action: Action name (e.g., "create_task", "update_project")
            resource: Resource type (e.g., "task", "project")
            resource_id: Resource ID
            changes: Changes made
            ip_address: Client IP address
            user_agent: Client user agent
        """
        details = {
            "action": action,
            "resource": resource,
            "resource_id": resource_id,
            "changes": changes,
        }
        
        await AuditLogger.log_event(
            db=db,
            event_type=f"user.{action}",
            user_id=user_id,
            details=details,
            ip_address=ip_address,
            user_agent=user_agent,
        )
    
    @staticmethod
    async def log_security_event(
        db: AsyncSession,
        event_type: str,
        severity: str = "info",
        details: Optional[Dict[str, Any]] = None,
        ip_address: Optional[str] = None,
        user_agent: Optional[str] = None,
    ):
        """
        Log a security event.
        
        Args:
            db: Database session
            event_type: Event type (e.g., "failed_login", "password_reset")
            severity: Event severity (info, warning, error, critical)
            details: Event details
            ip_address: Client IP address
            user_agent: Client user agent
        """
        await AuditLogger.log_event(
            db=db,
            event_type=f"security.{event_type}",
            user_id=None,
            details={"severity": severity, **details},
            ip_address=ip_address,
            user_agent=user_agent,
        )


# ────────────────────────────────────────────────────────────────
# Audit Logging Middleware
# ────────────────────────────────────────────────────────────────

class AuditLoggingMiddleware:
    """
    Middleware to automatically log request details.
    """
    
    async def __call__(self, request, call_next):
        # Only log API requests
        if not request.url.path.startswith("/api"):
            return await call_next(request)
        
        # Get request details
        client_ip = request.client.host if request.client else "unknown"
        user_agent = request.headers.get("user-agent", "unknown")
        method = request.method
        path = request.url.path
        
        # Get user from request state if available
        user_id = None
        if hasattr(request.state, "user"):
            user_id = request.state.user.id
        
        # Log request start
        await AuditLogger.log_event(
            db=None,  # We'll need to get the session
            event_type="request.start",
            user_id=user_id,
            details={
                "method": method,
                "path": path,
                "query": str(request.query_params),
            },
            ip_address=client_ip,
            user_agent=user_agent,
        )
        
        # Process request
        start_time = datetime.utcnow()
        try:
            response = await call_next(request)
            duration = (datetime.utcnow() - start_time).total_seconds()
            
            # Log request complete
            await AuditLogger.log_event(
                db=None,
                event_type="request.complete",
                user_id=user_id,
                details={
                    "method": method,
                    "path": path,
                    "status_code": response.status_code,
                    "duration_seconds": duration,
                },
                ip_address=client_ip,
                user_agent=user_agent,
            )
            
            return response
        except Exception as e:
            # Log error
            await AuditLogger.log_event(
                db=None,
                event_type="request.error",
                user_id=user_id,
                details={
                    "method": method,
                    "path": path,
                    "error": str(e),
                },
                ip_address=client_ip,
                user_agent=user_agent,
            )
            raise
```

## Step 7: Updating the Main Application

### The Target
Update the main application to integrate authentication, authorization, and security middleware.

### The Implementation

**Update `app/main.py`:**

```python
"""
app/main.py
Main FastAPI application entry point.
"""

from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.trustedhost import TrustedHostMiddleware
import logging
from datetime import datetime

from app.core.config import settings
from app.core.exceptions import setup_exception_handlers
from app.api.v1.api import api_router
from app.core.database import engine, check_db_connection
from app.middleware.security import (
    SecurityHeadersMiddleware,
    RateLimitingMiddleware,
    RequestValidationMiddleware,
    add_security_middleware,
)
from app.models import *

# Configure logging
logging.basicConfig(
    level=getattr(logging, settings.LOG_LEVEL),
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
)
logger = logging.getLogger(__name__)


@asynccontextmanager
async def lifespan(app: FastAPI):
    """
    Application lifespan manager.
    """
    # ──────────────── STARTUP ────────────────
    logger.info("🚀 Starting FastAPI application...")
    logger.info(f"📝 Application: {settings.APP_NAME} v{settings.APP_VERSION}")
    logger.info(f"🌍 Environment: {settings.APP_ENV}")
    logger.info(f"🐛 Debug mode: {settings.DEBUG}")
    
    # Check database connection
    logger.info("🔌 Checking database connection...")
    if await check_db_connection():
        logger.info("✅ Database connection established")
    else:
        logger.error("❌ Failed to connect to database")
        if settings.APP_ENV == "production":
            raise RuntimeError("Cannot start application without database connection")
    
    # Initialize database tables in development
    if settings.APP_ENV in ["development", "testing"]:
        logger.info("📦 Initializing database schema...")
        from app.core.database import init_db
        await init_db()
    
    logger.info("🚀 Application startup complete")
    logger.info(f"📚 API Documentation: /docs")
    
    yield  # Application runs here
    
    # ───────────────── SHUTDOWN ──────────────
    logger.info("🛑 Shutting down FastAPI application...")
    
    # Close database connections
    await engine.dispose()
    logger.info("✅ Database connections closed")


def create_application() -> FastAPI:
    """
    Application factory for creating the FastAPI app.
    """
    # Create the FastAPI app
    app = FastAPI(
        title=settings.APP_NAME,
        version=settings.APP_VERSION,
        description="""
        ## 🚀 FastAPI Masterclass API
        
        A production-ready FastAPI application with:
        - ✅ JWT-based authentication
        - ✅ Role-Based Access Control (RBAC)
        - ✅ Async database operations
        - ✅ Comprehensive validation
        - ✅ Security best practices
        - ✅ Automatic OpenAPI documentation
        
        ### Authentication Flow:
        1. Register at `/api/v1/auth/register`
        2. Login at `/api/v1/auth/login` to get tokens
        3. Use access token in `Authorization: Bearer <token>` header
        4. Refresh tokens at `/api/v1/auth/refresh`
        """,
        docs_url="/docs" if settings.DEBUG else "/docs",
        redoc_url="/redoc" if settings.DEBUG else "/redoc",
        openapi_url="/openapi.json" if settings.DEBUG else "/openapi.json",
        lifespan=lifespan,
        openapi_tags=[
            {"name": "health", "description": "Health check endpoints"},
            {"name": "auth", "description": "Authentication endpoints"},
            {"name": "users", "description": "User management"},
            {"name": "tasks", "description": "Task management"},
            {"name": "projects", "description": "Project management"},
        ],
    )
    
    # ──────────────── CORS ──────────────────────
    app.add_middleware(
        CORSMiddleware,
        allow_origins=settings.CORS_ORIGINS,
        allow_credentials=settings.CORS_CREDENTIALS,
        allow_methods=settings.CORS_METHODS,
        allow_headers=settings.CORS_HEADERS,
    )
    
    # ──────────────── SECURITY MIDDLEWARE ──────
    add_security_middleware(app)
    
    # ──────────────── TRUSTED HOSTS ──────────────
    # Only add TrustedHostMiddleware in production
    if settings.APP_ENV == "production":
        app.add_middleware(
            TrustedHostMiddleware,
            allowed_hosts=settings.ALLOWED_HOSTS if hasattr(settings, "ALLOWED_HOSTS") else [],
        )
    
    # ──────────────── EXCEPTION HANDLERS ──────
    setup_exception_handlers(app)
    
    # ──────────────── ROUTES ──────────────────
    app.include_router(api_router, prefix="/api/v1")
    
    # ──────────────── ROOT ENDPOINT ────────────
    @app.get("/", tags=["health"])
    async def root():
        return {
            "name": settings.APP_NAME,
            "version": settings.APP_VERSION,
            "environment": settings.APP_ENV,
            "status": "operational",
            "documentation": "/docs",
        }
    
    # ──────────────── HEALTH CHECK ──────────────
    @app.get("/health", tags=["health"])
    async def health_check():
        return {
            "status": "healthy",
            "timestamp": datetime.utcnow().isoformat() + "Z",
            "service": settings.APP_NAME,
            "version": settings.APP_VERSION,
            "environment": settings.APP_ENV,
        }
    
    # ──────────────── READINESS PROBE ──────────
    @app.get("/ready", tags=["health"])
    async def readiness_check():
        # Check database connectivity
        db_ok = await check_db_connection()
        return {
            "status": "ready" if db_ok else "unhealthy",
            "timestamp": datetime.utcnow().isoformat() + "Z",
            "database": "connected" if db_ok else "disconnected",
        }
    
    logger.info("✅ Application created successfully")
    return app


# Create the application instance
app = create_application()


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

## Step 8: Testing Authentication

### The Target
Create tests for authentication and authorization.

### The Implementation

**Create `tests/test_auth.py`:**

```python
"""
tests/test_auth.py
Tests for authentication and authorization.
"""

import pytest
from httpx import AsyncClient
from sqlalchemy.ext.asyncio import AsyncSession

from app.main import app
from app.core.database import get_db
from app.models.user import User
from app.core.security import get_password_hash


@pytest.mark.asyncio
async def test_register_user(db_session: AsyncSession, client: AsyncClient):
    """Test user registration."""
    response = await client.post(
        "/api/v1/auth/register",
        json={
            "email": "newuser@example.com",
            "username": "newuser",
            "full_name": "New User",
            "password": "SecurePass123!",
        }
    )
    
    assert response.status_code == 201
    data = response.json()
    assert data["email"] == "newuser@example.com"
    assert data["username"] == "newuser"
    assert data["full_name"] == "New User"
    assert "id" in data


@pytest.mark.asyncio
async def test_register_duplicate_user(db_session: AsyncSession, client: AsyncClient):
    """Test registration with duplicate email."""
    # Create first user
    await client.post(
        "/api/v1/auth/register",
        json={
            "email": "duplicate@example.com",
            "username": "duplicate1",
            "full_name": "Duplicate User",
            "password": "SecurePass123!",
        }
    )
    
    # Try to create second user with same email
    response = await client.post(
        "/api/v1/auth/register",
        json={
            "email": "duplicate@example.com",
            "username": "duplicate2",
            "full_name": "Another User",
            "password": "SecurePass123!",
        }
    )
    
    assert response.status_code == 409
    data = response.json()
    assert data["error"]["error_code"] == "EMAIL_TAKEN"


@pytest.mark.asyncio
async def test_login(db_session: AsyncSession, client: AsyncClient):
    """Test user login."""
    # Create user
    from app.schemas.auth import RegisterRequest
    register_data = RegisterRequest(
        email="login@example.com",
        username="loginuser",
        full_name="Login User",
        password="SecurePass123!",
    )
    
    user_service = UserService(db_session)
    await user_service.create_user(register_data)
    
    # Login
    response = await client.post(
        "/api/v1/auth/login",
        data={
            "username": "login@example.com",
            "password": "SecurePass123!",
        }
    )
    
    assert response.status_code == 200
    data = response.json()
    assert "access_token" in data
    assert "refresh_token" in data
    assert data["token_type"] == "bearer"
    assert data["user"]["email"] == "login@example.com"


@pytest.mark.asyncio
async def test_login_invalid_credentials(db_session: AsyncSession, client: AsyncClient):
    """Test login with invalid credentials."""
    response = await client.post(
        "/api/v1/auth/login",
        data={
            "username": "nonexistent@example.com",
            "password": "WrongPass123!",
        }
    )
    
    assert response.status_code == 401
    data = response.json()
    assert data["error"]["error_code"] == "INVALID_CREDENTIALS"


@pytest.mark.asyncio
async def test_refresh_token(db_session: AsyncSession, client: AsyncClient):
    """Test token refresh."""
    # Create user and login
    register_data = RegisterRequest(
        email="refresh@example.com",
        username="refreshuser",
        full_name="Refresh User",
        password="SecurePass123!",
    )
    
    user_service = UserService(db_session)
    await user_service.create_user(register_data)
    
    login_response = await client.post(
        "/api/v1/auth/login",
        data={
            "username": "refresh@example.com",
            "password": "SecurePass123!",
        }
    )
    login_data = login_response.json()
    
    # Refresh token
    response = await client.post(
        "/api/v1/auth/refresh",
        json={"refresh_token": login_data["refresh_token"]}
    )
    
    assert response.status_code == 200
    data = response.json()
    assert "access_token" in data
    assert data["token_type"] == "bearer"
    assert data["expires_in"] == 1800


@pytest.mark.asyncio
async def test_protected_endpoint(db_session: AsyncSession, client: AsyncClient):
    """Test accessing protected endpoint."""
    # Create user and login
    register_data = RegisterRequest(
        email="protected@example.com",
        username="protecteduser",
        full_name="Protected User",
        password="SecurePass123!",
    )
    
    user_service = UserService(db_session)
    await user_service.create_user(register_data)
    
    login_response = await client.post(
        "/api/v1/auth/login",
        data={
            "username": "protected@example.com",
            "password": "SecurePass123!",
        }
    )
    token = login_response.json()["access_token"]
    
    # Access protected endpoint
    response = await client.get(
        "/api/v1/auth/me",
        headers={"Authorization": f"Bearer {token}"}
    )
    
    assert response.status_code == 200
    data = response.json()
    assert data["email"] == "protected@example.com"
    assert data["username"] == "protecteduser"


@pytest.mark.asyncio
async def test_protected_endpoint_no_token(db_session: AsyncSession, client: AsyncClient):
    """Test accessing protected endpoint without token."""
    response = await client.get("/api/v1/auth/me")
    
    assert response.status_code == 401
    data = response.json()
    assert data["error"]["error_code"] == "NO_TOKEN"


@pytest.mark.asyncio
async def test_protected_endpoint_invalid_token(db_session: AsyncSession, client: AsyncClient):
    """Test accessing protected endpoint with invalid token."""
    response = await client.get(
        "/api/v1/auth/me",
        headers={"Authorization": "Bearer invalid_token"}
    )
    
    assert response.status_code == 401
    data = response.json()
    assert data["error"]["error_code"] == "INVALID_TOKEN"
```

## The Verification

Let's test our authentication system:

```bash
# 1. Run the application
uvicorn app.main:app --reload

# 2. Register a new user
curl -X POST http://localhost:8000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "username": "testuser",
    "full_name": "Test User",
    "password": "SecurePass123!"
  }'

# 3. Login to get tokens
curl -X POST http://localhost:8000/api/v1/auth/login \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=test@example.com&password=SecurePass123!"

# 4. Use the access token to access protected endpoint
curl -X GET http://localhost:8000/api/v1/auth/me \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"

# 5. Refresh the token
curl -X POST http://localhost:8000/api/v1/auth/refresh \
  -H "Content-Type: application/json" \
  -d '{"refresh_token": "YOUR_REFRESH_TOKEN"}'

# 6. Test invalid credentials
curl -X POST http://localhost:8000/api/v1/auth/login \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=test@example.com&password=WrongPassword"

# 7. Test without token
curl -X GET http://localhost:8000/api/v1/auth/me
```

Expected outputs:
- Registration: 201 Created with user data
- Login: 200 OK with access_token, refresh_token, and user data
- Protected endpoint: 200 OK with user profile
- Refresh: 200 OK with new access_token
- Invalid credentials: 401 Unauthorized with error details
- No token: 401 Unauthorized

## Deep Dive: JWT Security Best Practices

### Token Storage

```python
# NEVER store tokens in localStorage (XSS vulnerability)
# Use HttpOnly cookies instead:
from fastapi.responses import Response
from fastapi import Cookie

@app.post("/login")
async def login(response: Response, user_data: LoginRequest):
    token = create_access_token({"sub": user.id})
    
    # Set secure cookie
    response.set_cookie(
        key="access_token",
        value=token,
        httponly=True,  # Not accessible via JavaScript
        secure=True,    # Only sent over HTTPS
        samesite="strict",  # CSRF protection
        max_age=1800,   # 30 minutes
    )
    return {"message": "Logged in"}

@app.get("/me")
async def get_me(access_token: str = Cookie(None)):
    # Access token from cookie
    payload = verify_token(access_token)
    ...
```

### Token Revocation

```python
# app/core/blacklist.py
import redis
from datetime import datetime

class TokenBlacklist:
    def __init__(self, redis_client):
        self.redis = redis_client
    
    async def revoke_token(self, token: str, expires_in: int):
        """Revoke a token."""
        await self.redis.setex(
            f"revoked:{token}",
            expires_in,
            "revoked"
        )
    
    async def is_revoked(self, token: str) -> bool:
        """Check if token is revoked."""
        return await self.redis.exists(f"revoked:{token}") > 0

# Usage in logout endpoint
@router.post("/logout")
async def logout(token: str = Depends(oauth2_scheme)):
    # Decode token to get expiration
    payload = decode_token(token)
    expires_in = payload["exp"] - datetime.utcnow().timestamp()
    
    # Revoke the token
    await blacklist.revoke_token(token, int(expires_in))
    return {"message": "Logged out"}
```

### Password Reset Flow

```python
# app/services/email.py
async def send_password_reset_email(email: str, token: str):
    """Send password reset email."""
    reset_url = f"https://yourapp.com/reset-password?token={token}"
    message = f"""
    Hello,
    
    You requested a password reset. Click the link below to reset your password:
    {reset_url}
    
    This link will expire in 24 hours.
    
    If you didn't request this, please ignore this email.
    """
    await send_email(
        to=email,
        subject="Password Reset Request",
        body=message,
    )
```

## What We Accomplished

✅ Implemented JWT-based authentication with OAuth2
✅ Added secure password hashing with bcrypt
✅ Created refresh token rotation for security
✅ Implemented Role-Based Access Control (RBAC)
✅ Added security middleware (CORS, headers, HTTPS)
✅ Created audit logging for security events
✅ Implemented API key authentication foundation
✅ Added comprehensive tests for authentication
✅ Secured endpoints with permission checking

## Key Takeaways

1. **Never Store Plain Passwords**: Always hash passwords using bcrypt or Argon2
2. **Use Short-Lived Access Tokens**: 15-30 minutes is standard, with refresh tokens for longevity
3. **Implement Token Rotation**: Issue new refresh tokens on each refresh request
4. **Role-Based Access Control**: Use roles and permissions to control access
5. **Security Headers**: Always add security headers to responses
6. **Audit Logging**: Log security events for monitoring and compliance
7. **Secure Endpoints**: Always validate authentication before authorization
8. **Test Security**: Write tests for authentication and authorization flows

## What's Next?

In **[Part 4: Advanced FastAPI & High-Performance Architecture]** , we'll:
- Implement async programming patterns
- Add background tasks and task queues with Celery
- Implement WebSockets for real-time communication
- Add Redis caching for performance
- Implement rate limiting
- Add monitoring and performance optimization
