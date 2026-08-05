# APPENDIX G — Security Implementation Guide

## Complete Security Framework for ScaleCart

---

## G.1 Introduction

This appendix provides a comprehensive security implementation guide for the ScaleCart platform, covering:

1. **Authentication & Authorization** – JWT, RBAC, OAuth2
2. **Data Protection** – Encryption, masking, secure storage
3. **API Security** – Rate limiting, input validation, CORS
4. **Database Security** – Encryption, audit logging, RLS
5. **Infrastructure Security** – Network, container, secrets management
6. **Compliance** – GDPR, PCI-DSS, SOC2 readiness
7. **Security Testing** – Vulnerability scanning, penetration testing

---

## G.2 Authentication & Authorization

### G.2.1 JWT Implementation

```python
# File: src/security/auth.py
import jwt
from datetime import datetime, timedelta
from typing import Optional, Dict, Any
from passlib.context import CryptContext
from fastapi import HTTPException, Security, Depends
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
import os

# Password hashing context
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

# JWT configuration
SECRET_KEY = os.getenv("SECRET_KEY", "your-secret-key-here")
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30
REFRESH_TOKEN_EXPIRE_DAYS = 7

security = HTTPBearer()

class SecurityManager:
    """Centralized security management."""
    
    @staticmethod
    def verify_password(plain_password: str, hashed_password: str) -> bool:
        """Verify a password against its hash."""
        return pwd_context.verify(plain_password, hashed_password)
    
    @staticmethod
    def get_password_hash(password: str) -> str:
        """Hash a password."""
        return pwd_context.hash(password)
    
    @staticmethod
    def create_access_token(data: Dict[str, Any], expires_delta: Optional[timedelta] = None) -> str:
        """Create a JWT access token."""
        to_encode = data.copy()
        if expires_delta:
            expire = datetime.utcnow() + expires_delta
        else:
            expire = datetime.utcnow() + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
        
        to_encode.update({"exp": expire, "type": "access"})
        encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
        return encoded_jwt
    
    @staticmethod
    def create_refresh_token(data: Dict[str, Any]) -> str:
        """Create a JWT refresh token."""
        to_encode = data.copy()
        expire = datetime.utcnow() + timedelta(days=REFRESH_TOKEN_EXPIRE_DAYS)
        to_encode.update({"exp": expire, "type": "refresh"})
        encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
        return encoded_jwt
    
    @staticmethod
    def decode_token(token: str) -> Dict[str, Any]:
        """Decode and validate a JWT token."""
        try:
            payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
            return payload
        except jwt.ExpiredSignatureError:
            raise HTTPException(status_code=401, detail="Token has expired")
        except jwt.InvalidTokenError:
            raise HTTPException(status_code=401, detail="Invalid token")
    
    @staticmethod
    def refresh_access_token(refresh_token: str) -> Dict[str, str]:
        """Refresh an access token using a refresh token."""
        payload = SecurityManager.decode_token(refresh_token)
        
        if payload.get("type") != "refresh":
            raise HTTPException(status_code=401, detail="Invalid token type")
        
        # Create new access token
        new_access_token = SecurityManager.create_access_token(
            data={"sub": payload.get("sub"), "role": payload.get("role")}
        )
        
        return {
            "access_token": new_access_token,
            "token_type": "bearer",
            "expires_in": ACCESS_TOKEN_EXPIRE_MINUTES * 60
        }

# Token validation dependency
async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Security(security)
) -> Dict[str, Any]:
    """Get current user from JWT token."""
    token = credentials.credentials
    payload = SecurityManager.decode_token(token)
    
    # Check token type
    if payload.get("type") != "access":
        raise HTTPException(status_code=401, detail="Invalid token type")
    
    # Extract user information
    user_id = payload.get("sub")
    role = payload.get("role", "customer")
    
    if not user_id:
        raise HTTPException(status_code=401, detail="Invalid token")
    
    return {
        "user_id": int(user_id),
        "role": role,
        "email": payload.get("email")
    }

# Role-based access control
def require_role(required_role: str):
    """Dependency for role-based access control."""
    async def role_checker(current_user: Dict = Depends(get_current_user)):
        if current_user["role"] != required_role and current_user["role"] != "admin":
            raise HTTPException(
                status_code=403,
                detail=f"Role {required_role} required"
            )
        return current_user
    return role_checker

# Example usage in FastAPI
from fastapi import FastAPI, Depends

app = FastAPI()

@app.post("/api/v1/auth/login")
async def login(email: str, password: str):
    """Login endpoint."""
    # Verify credentials (pseudo-code)
    user = authenticate_user(email, password)
    if not user:
        raise HTTPException(status_code=401, detail="Invalid credentials")
    
    # Create tokens
    access_token = SecurityManager.create_access_token(
        data={"sub": str(user.id), "role": user.role, "email": user.email}
    )
    refresh_token = SecurityManager.create_refresh_token(
        data={"sub": str(user.id), "role": user.role}
    )
    
    return {
        "access_token": access_token,
        "refresh_token": refresh_token,
        "token_type": "bearer",
        "expires_in": ACCESS_TOKEN_EXPIRE_MINUTES * 60
    }

@app.get("/api/v1/admin/users")
async def admin_only_endpoint(current_user: Dict = Depends(require_role("admin"))):
    """Admin-only endpoint."""
    return {"message": "Admin access granted"}

@app.get("/api/v1/customers/me")
async def get_my_profile(current_user: Dict = Depends(get_current_user)):
    """Get current user profile."""
    # Use current_user["user_id"] to fetch profile
    return {"user_id": current_user["user_id"], "role": current_user["role"]}
```

### G.2.2 OAuth2 Integration

```python
# File: src/security/oauth.py
from authlib.integrations.starlette_client import OAuth
from starlette.config import Config
from starlette.requests import Request
from starlette.responses import RedirectResponse
import os

# OAuth configuration
config = Config(".env")
oauth = OAuth(config)

# Configure OAuth providers
oauth.register(
    name="google",
    client_id=os.getenv("GOOGLE_CLIENT_ID"),
    client_secret=os.getenv("GOOGLE_CLIENT_SECRET"),
    server_metadata_url="https://accounts.google.com/.well-known/openid-configuration",
    client_kwargs={"scope": "openid email profile"}
)

oauth.register(
    name="github",
    client_id=os.getenv("GITHUB_CLIENT_ID"),
    client_secret=os.getenv("GITHUB_CLIENT_SECRET"),
    access_token_url="https://github.com/login/oauth/access_token",
    authorize_url="https://github.com/login/oauth/authorize",
    api_base_url="https://api.github.com/",
    client_kwargs={"scope": "user:email"}
)

class OAuthManager:
    """OAuth authentication manager."""
    
    @staticmethod
    async def login_with_oauth(provider: str, request: Request):
        """Initiate OAuth login."""
        redirect_uri = request.url_for("oauth_callback", provider=provider)
        return await oauth[provider].authorize_redirect(request, redirect_uri)
    
    @staticmethod
    async def handle_oauth_callback(provider: str, request: Request):
        """Handle OAuth callback."""
        token = await oauth[provider].authorize_access_token(request)
        user_info = await oauth[provider].parse_id_token(request, token)
        
        # Extract user information
        email = user_info.get("email")
        name = user_info.get("name", email.split("@")[0])
        
        # Find or create user in database
        user = await find_or_create_user(email, name, provider)
        
        # Create JWT tokens
        access_token = SecurityManager.create_access_token(
            data={"sub": str(user.id), "role": user.role, "email": user.email}
        )
        refresh_token = SecurityManager.create_refresh_token(
            data={"sub": str(user.id), "role": user.role}
        )
        
        return {
            "access_token": access_token,
            "refresh_token": refresh_token,
            "token_type": "bearer",
            "user": {
                "id": user.id,
                "email": user.email,
                "name": user.full_name
            }
        }

# FastAPI routes
@app.get("/api/v1/auth/oauth/{provider}")
async def oauth_login(provider: str, request: Request):
    """Initiate OAuth login."""
    return await OAuthManager.login_with_oauth(provider, request)

@app.get("/api/v1/auth/oauth/callback/{provider}")
async def oauth_callback(provider: str, request: Request):
    """Handle OAuth callback."""
    return await OAuthManager.handle_oauth_callback(provider, request)
```

---

## G.3 Data Protection

### G.3.1 Encryption at Rest

```python
# File: src/security/encryption.py
from cryptography.fernet import Fernet
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.kdf.pbkdf2 import PBKDF2HMAC
import base64
import os
import json

class DataEncryption:
    """Data encryption utilities."""
    
    def __init__(self, key: str = None):
        if key:
            self.key = key.encode()
        else:
            # Generate or load key from environment
            env_key = os.getenv("ENCRYPTION_KEY")
            if env_key:
                self.key = env_key.encode()
            else:
                self.key = Fernet.generate_key()
                # In production, store this securely, not here!
        
        self.cipher = Fernet(self.key)
    
    @classmethod
    def derive_key_from_password(cls, password: str, salt: bytes = None) -> bytes:
        """Derive encryption key from password."""
        if salt is None:
            salt = os.urandom(16)
        
        kdf = PBKDF2HMAC(
            algorithm=hashes.SHA256(),
            length=32,
            salt=salt,
            iterations=100000,
        )
        key = base64.urlsafe_b64encode(kdf.derive(password.encode()))
        return key, salt
    
    def encrypt(self, data: dict) -> str:
        """Encrypt dictionary data."""
        json_data = json.dumps(data)
        encrypted = self.cipher.encrypt(json_data.encode())
        return encrypted.decode()
    
    def decrypt(self, encrypted_data: str) -> dict:
        """Decrypt data back to dictionary."""
        decrypted = self.cipher.decrypt(encrypted_data.encode())
        return json.loads(decrypted)
    
    def encrypt_field(self, value: str) -> str:
        """Encrypt a single string field."""
        encrypted = self.cipher.encrypt(value.encode())
        return encrypted.decode()
    
    def decrypt_field(self, encrypted_value: str) -> str:
        """Decrypt a single string field."""
        decrypted = self.cipher.decrypt(encrypted_value.encode())
        return decrypted.decode()

# Data masking utilities
class DataMasker:
    """Data masking utilities for PII protection."""
    
    @staticmethod
    def mask_email(email: str) -> str:
        """Mask email address."""
        if not email or "@" not in email:
            return email
        local, domain = email.split("@")
        if len(local) <= 2:
            masked_local = local[0] + "*" * (len(local) - 1)
        else:
            masked_local = local[0] + "*" * (len(local) - 2) + local[-1]
        return f"{masked_local}@{domain}"
    
    @staticmethod
    def mask_phone(phone: str) -> str:
        """Mask phone number."""
        if not phone or len(phone) < 4:
            return phone
        visible = 4
        masked = "*" * (len(phone) - visible)
        return f"{masked}{phone[-visible:]}"
    
    @staticmethod
    def mask_credit_card(card: str) -> str:
        """Mask credit card number."""
        if not card or len(card) < 4:
            return card
        visible = 4
        masked = "*" * (len(card) - visible)
        return f"{masked}{card[-visible:]}"
    
    @staticmethod
    def mask_name(name: str) -> str:
        """Mask name (show first letter only)."""
        if not name:
            return name
        parts = name.split()
        masked_parts = []
        for part in parts:
            if len(part) <= 1:
                masked_parts.append(part)
            else:
                masked_parts.append(part[0] + "*" * (len(part) - 1))
        return " ".join(masked_parts)

# Usage example in API responses
class SecureResponse:
    @staticmethod
    def sanitize_customer_data(customer: dict) -> dict:
        """Sanitize customer data for API responses."""
        data = customer.copy()
        if "email" in data:
            data["email"] = DataMasker.mask_email(data["email"])
        if "phone" in data:
            data["phone"] = DataMasker.mask_phone(data["phone"])
        if "full_name" in data:
            data["full_name"] = DataMasker.mask_name(data["full_name"])
        if "credit_card" in data:
            data["credit_card"] = DataMasker.mask_credit_card(data["credit_card"])
        return data
```

### G.3.2 Database Encryption with pgcrypto

```sql
-- File: security/pgcrypto_setup.sql
-- Enable pgcrypto extension
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Create table with encrypted fields
CREATE TABLE customer_sensitive_data (
    id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
    ssn_encrypted BYTEA,
    driver_license_encrypted BYTEA,
    passport_encrypted BYTEA,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Create function to encrypt data on insert
CREATE OR REPLACE FUNCTION encrypt_sensitive_data()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.ssn_encrypted IS NOT NULL AND encode(NEW.ssn_encrypted, 'escape') NOT LIKE '\\x%' THEN
        NEW.ssn_encrypted = pgp_sym_encrypt(
            NEW.ssn_encrypted::text,
            current_setting('app.encryption_key')
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger
CREATE TRIGGER encrypt_sensitive_data_trigger
BEFORE INSERT OR UPDATE ON customer_sensitive_data
FOR EACH ROW EXECUTE FUNCTION encrypt_sensitive_data();

-- Decryption function
CREATE OR REPLACE FUNCTION decrypt_sensitive_data(encrypted_data BYTEA)
RETURNS TEXT AS $$
BEGIN
    RETURN pgp_sym_decrypt(
        encrypted_data,
        current_setting('app.encryption_key')
    );
END;
$$ LANGUAGE plpgsql;

-- Encryption key management
-- Set key in session (should come from secure vault)
SELECT set_config('app.encryption_key', 'your-encryption-key-here', false);
```

---

## G.4 API Security

### G.4.1 Input Validation

```python
# File: src/security/validation.py
from pydantic import BaseModel, EmailStr, validator, Field
from typing import Optional, List
import re

class SecurityValidator:
    """Input validation and sanitization."""
    
    @staticmethod
    def sanitize_input(text: str) -> str:
        """Sanitize input to prevent XSS and SQL injection."""
        if not text:
            return text
        # Remove dangerous characters
        dangerous_chars = ["'", '"', ';', '--', '/*', '*/', 'xp_', 'exec', 'union']
        for char in dangerous_chars:
            text = text.replace(char, '')
        # Escape HTML
        html_escape_table = {
            "&": "&amp;",
            '"': "&quot;",
            "'": "&apos;",
            ">": "&gt;",
            "<": "&lt;",
        }
        return "".join(html_escape_table.get(c, c) for c in text)
    
    @staticmethod
    def validate_password(password: str) -> bool:
        """Validate password strength."""
        if len(password) < 8:
            return False
        if not re.search(r"[A-Z]", password):
            return False
        if not re.search(r"[a-z]", password):
            return False
        if not re.search(r"\d", password):
            return False
        if not re.search(r"[!@#$%^&*(),.?\":{}|<>]", password):
            return False
        return True

# Pydantic models with validation
class UserRegistration(BaseModel):
    email: EmailStr
    password: str
    full_name: str = Field(..., min_length=2, max_length=100)
    phone: Optional[str] = None
    
    @validator('password')
    def validate_password(cls, v):
        if not SecurityValidator.validate_password(v):
            raise ValueError(
                "Password must be at least 8 characters and contain "
                "uppercase, lowercase, number, and special character"
            )
        return v
    
    @validator('full_name')
    def sanitize_name(cls, v):
        return SecurityValidator.sanitize_input(v)

class ProductCreate(BaseModel):
    name: str = Field(..., min_length=1, max_length=255)
    description: Optional[str] = None
    price: float = Field(..., gt=0)
    category_id: int = Field(..., gt=0)
    sku: Optional[str] = None
    
    @validator('name')
    def sanitize_name(cls, v):
        return SecurityValidator.sanitize_input(v)
    
    @validator('description')
    def sanitize_description(cls, v):
        if v:
            return SecurityValidator.sanitize_input(v)
        return v

class OrderCreate(BaseModel):
    customer_id: int = Field(..., gt=0)
    items: List[dict]
    shipping_address_id: int = Field(..., gt=0)
    billing_address_id: int = Field(..., gt=0)
    payment_method: str
    
    @validator('items')
    def validate_items(cls, v):
        if not v:
            raise ValueError("Order must contain at least one item")
        for item in v:
            if item.get('quantity', 0) <= 0:
                raise ValueError("Quantity must be positive")
            if item.get('product_id', 0) <= 0:
                raise ValueError("Invalid product ID")
        return v
    
    @validator('payment_method')
    def validate_payment_method(cls, v):
        allowed_methods = ['credit_card', 'paypal', 'bank_transfer']
        if v not in allowed_methods:
            raise ValueError(f"Invalid payment method. Allowed: {allowed_methods}")
        return v
```

### G.4.2 Rate Limiting

```python
# File: src/security/rate_limiter.py
import time
from typing import Dict, Optional
from collections import defaultdict
from functools import wraps
from fastapi import HTTPException, Request
import redis
import os

class RateLimiter:
    """Distributed rate limiter using Redis."""
    
    def __init__(self, redis_client: redis.Redis = None):
        self.redis = redis_client or redis.Redis(
            host=os.getenv("REDIS_HOST", "localhost"),
            port=int(os.getenv("REDIS_PORT", 6379)),
            password=os.getenv("REDIS_PASSWORD"),
            decode_responses=True
        )
    
    def check_rate_limit(
        self, 
        key: str, 
        limit: int, 
        window: int
    ) -> tuple:
        """
        Check if rate limit is exceeded.
        Returns: (allowed, remaining, reset_time)
        """
        current_time = int(time.time())
        window_start = current_time - window
        
        # Using Redis sorted set for sliding window
        redis_key = f"rate_limit:{key}"
        
        # Remove old entries
        self.redis.zremrangebyscore(redis_key, 0, window_start)
        
        # Count current requests
        current_count = self.redis.zcard(redis_key)
        
        if current_count >= limit:
            # Get oldest timestamp to calculate reset time
            oldest = self.redis.zrange(redis_key, 0, 0, withscores=True)
            reset_time = int(oldest[0][1]) + window if oldest else current_time + window
            return False, 0, reset_time
        
        # Add current request
        self.redis.zadd(redis_key, {current_time: current_time})
        self.redis.expire(redis_key, window + 60)
        
        remaining = limit - current_count - 1
        reset_time = current_time + window
        
        return True, remaining, reset_time
    
    def rate_limit_decorator(self, limit: int = 100, window: int = 60, key_prefix: str = "api"):
        """Decorator for rate limiting endpoints."""
        def decorator(func):
            @wraps(func)
            async def wrapper(*args, **kwargs):
                # Extract client identifier
                request = None
                for arg in args:
                    if isinstance(arg, Request):
                        request = arg
                        break
                    elif hasattr(arg, "request"):
                        request = arg.request
                        break
                
                if request:
                    client_ip = request.client.host
                    user_id = request.headers.get("X-User-ID", "anonymous")
                    key = f"{key_prefix}:{user_id}:{client_ip}"
                    
                    allowed, remaining, reset_time = self.check_rate_limit(
                        key=key,
                        limit=limit,
                        window=window
                    )
                    
                    # Add rate limit headers
                    request.state.rate_limit = {
                        "limit": limit,
                        "remaining": remaining,
                        "reset": reset_time
                    }
                    
                    if not allowed:
                        raise HTTPException(
                            status_code=429,
                            detail="Rate limit exceeded",
                            headers={
                                "X-RateLimit-Limit": str(limit),
                                "X-RateLimit-Remaining": str(0),
                                "X-RateLimit-Reset": str(reset_time)
                            }
                        )
                
                return await func(*args, **kwargs)
            return wrapper
        return decorator
    
    @staticmethod
    def add_rate_limit_headers(response, rate_limit_data: Dict):
        """Add rate limit headers to response."""
        if rate_limit_data:
            response.headers["X-RateLimit-Limit"] = str(rate_limit_data["limit"])
            response.headers["X-RateLimit-Remaining"] = str(rate_limit_data["remaining"])
            response.headers["X-RateLimit-Reset"] = str(rate_limit_data["reset"])
        return response

# Usage in FastAPI
from fastapi import FastAPI, Request, Response

app = FastAPI()
rate_limiter = RateLimiter()

@app.get("/api/v1/products")
@rate_limiter.rate_limit_decorator(limit=100, window=60)
async def get_products(request: Request, response: Response):
    """Get products with rate limiting."""
    # Your logic here
    rate_limiter.add_rate_limit_headers(response, getattr(request.state, "rate_limit", {}))
    return {"products": []}

# Different limits for different endpoints
@app.post("/api/v1/orders")
@rate_limiter.rate_limit_decorator(limit=20, window=60, key_prefix="orders")
async def create_order(request: Request, response: Response):
    """Create order with stricter rate limiting."""
    # Your logic here
    rate_limiter.add_rate_limit_headers(response, getattr(request.state, "rate_limit", {}))
    return {"order_id": 123}

@app.post("/api/v1/auth/login")
@rate_limiter.rate_limit_decorator(limit=5, window=60, key_prefix="auth")
async def login(request: Request, response: Response):
    """Login with strict rate limiting to prevent brute force."""
    # Your logic here
    rate_limiter.add_rate_limit_headers(response, getattr(request.state, "rate_limit", {}))
    return {"access_token": "token"}
```

---

## G.5 Database Security

### G.5.1 Row Level Security (RLS)

```sql
-- File: security/rls.sql
-- Enable RLS on all tables with sensitive data
ALTER TABLE customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE addresses ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;

-- Customer policy: Can only see their own data
CREATE POLICY customer_self_access ON customers
    USING (id = current_setting('app.current_user_id')::INTEGER);

-- Customer policy for orders
CREATE POLICY customer_order_access ON orders
    USING (customer_id = current_setting('app.current_user_id')::INTEGER);

-- Admin policy: Full access
CREATE POLICY admin_access ON customers
    USING (current_setting('app.current_role') = 'admin');

-- Policy for employees (limited access)
CREATE POLICY employee_access ON customers
    USING (current_setting('app.current_role') IN ('admin', 'support'));

-- Combining policies
CREATE POLICY customer_view_own_orders ON orders
    FOR SELECT
    USING (
        customer_id = current_setting('app.current_user_id')::INTEGER
        OR current_setting('app.current_role') = 'admin'
    );

-- Policy for order management
CREATE POLICY employee_update_orders ON orders
    FOR UPDATE
    USING (current_setting('app.current_role') IN ('admin', 'support'))
    WITH CHECK (true);

-- Set current user/role in application
-- In each request:
SELECT set_config('app.current_user_id', '42', false);
SELECT set_config('app.current_role', 'customer', false);
```

### G.5.2 Audit Logging Implementation

```python
# File: src/security/audit.py
import json
from datetime import datetime
from typing import Optional, Dict, Any
from sqlalchemy import text
import logging
import inspect

class AuditLogger:
    """Audit logging for all data modifications."""
    
    def __init__(self, db_session):
        self.session = db_session
        self.logger = logging.getLogger("audit")
    
    def log_operation(
        self,
        table_name: str,
        record_id: int,
        action: str,
        old_data: Optional[Dict] = None,
        new_data: Optional[Dict] = None,
        changed_by: Optional[int] = None,
        client_ip: Optional[str] = None,
        user_agent: Optional[str] = None
    ):
        """Log an operation to audit_log table."""
        try:
            self.session.execute(
                text("""
                    INSERT INTO audit_log (
                        table_name, record_id, action, 
                        old_data, new_data, changed_by,
                        client_ip, user_agent
                    ) VALUES (
                        :table_name, :record_id, :action,
                        :old_data, :new_data, :changed_by,
                        :client_ip, :user_agent
                    )
                """),
                {
                    "table_name": table_name,
                    "record_id": record_id,
                    "action": action,
                    "old_data": json.dumps(old_data) if old_data else None,
                    "new_data": json.dumps(new_data) if new_data else None,
                    "changed_by": changed_by,
                    "client_ip": client_ip,
                    "user_agent": user_agent
                }
            )
            self.session.commit()
        except Exception as e:
            self.logger.error(f"Failed to audit log: {e}")
            self.session.rollback()
    
    def log_user_activity(
        self,
        user_id: int,
        action: str,
        metadata: Optional[Dict] = None
    ):
        """Log user activity for analytics and security."""
        self.logger.info(
            f"User {user_id}: {action}",
            extra={"user_id": user_id, "action": action, "metadata": metadata}
        )

# Decorator for automatic audit logging
def audit_log(table_name: str):
    """Decorator to automatically audit database operations."""
    def decorator(func):
        def wrapper(self, *args, **kwargs):
            # Get current user ID from context
            current_user = kwargs.get('current_user', {}).get('id')
            
            # Get client information from request context
            request = kwargs.get('request')
            client_ip = request.client.host if request else None
            user_agent = request.headers.get('user-agent') if request else None
            
            # Execute the function
            result = func(self, *args, **kwargs)
            
            # Log the operation
            if hasattr(self, 'audit_logger'):
                self.audit_logger.log_operation(
                    table_name=table_name,
                    record_id=result.get('id') if result else None,
                    action=func.__name__.upper(),
                    new_data=result,
                    changed_by=current_user,
                    client_ip=client_ip,
                    user_agent=user_agent
                )
            
            return result
        return wrapper
    return decorator

# Usage in services
from src.utils.db import get_db
from src.security.audit import AuditLogger

class OrderService:
    def __init__(self, db_session):
        self.session = db_session
        self.audit_logger = AuditLogger(db_session)
    
    @audit_log('orders')
    def create_order(self, customer_id, items, **kwargs):
        """Create order with automatic audit logging."""
        # Create order logic
        order = {"id": 123, "customer_id": customer_id, "status": "pending"}
        return order
    
    def update_order_status(self, order_id, new_status, current_user, request):
        """Update order status with manual audit logging."""
        # Get old data
        old_order = self.get_order(order_id)
        
        # Update logic
        updated_order = {"id": order_id, "status": new_status}
        
        # Manual audit log
        self.audit_logger.log_operation(
            table_name='orders',
            record_id=order_id,
            action='UPDATE',
            old_data=old_order,
            new_data=updated_order,
            changed_by=current_user.get('id'),
            client_ip=request.client.host,
            user_agent=request.headers.get('user-agent')
        )
        
        return updated_order
```

---

## G.6 Infrastructure Security

### G.6.1 Secrets Management

```python
# File: src/security/secrets.py
import os
from typing import Optional, Dict, Any
import boto3
from google.cloud import secretmanager
import json

class SecretsManager:
    """Multi-cloud secrets management."""
    
    def __init__(self, provider: str = "env"):
        self.provider = provider
        self._secrets = {}
        
        if provider == "aws":
            self.client = boto3.client('secretsmanager')
        elif provider == "gcp":
            self.client = secretmanager.SecretManagerServiceClient()
        elif provider == "azure":
            # Azure Key Vault client
            pass
    
    def get_secret(self, secret_name: str) -> Optional[str]:
        """Get a secret from the configured provider."""
        if self.provider == "env":
            return os.getenv(secret_name)
        
        if self.provider == "aws":
            try:
                response = self.client.get_secret_value(SecretId=secret_name)
                return response['SecretString']
            except Exception as e:
                print(f"Error fetching secret {secret_name}: {e}")
                return None
        
        if self.provider == "gcp":
            try:
                project_id = os.getenv("GCP_PROJECT_ID")
                name = f"projects/{project_id}/secrets/{secret_name}/versions/latest"
                response = self.client.access_secret_version(request={"name": name})
                return response.payload.data.decode('UTF-8')
            except Exception as e:
                print(f"Error fetching secret {secret_name}: {e}")
                return None
        
        return None
    
    def set_secret(self, secret_name: str, secret_value: str) -> bool:
        """Set a secret in the configured provider."""
        if self.provider == "env":
            # Cannot set environment variables programmatically
            return False
        
        if self.provider == "aws":
            try:
                self.client.create_secret(
                    Name=secret_name,
                    SecretString=secret_value
                )
                return True
            except Exception as e:
                print(f"Error setting secret {secret_name}: {e}")
                return False
        
        return False
    
    def get_secrets_batch(self, secret_names: list) -> Dict[str, str]:
        """Get multiple secrets at once."""
        results = {}
        for name in secret_names:
            results[name] = self.get_secret(name)
        return results

# Secrets configuration
class AppSecrets:
    """Centralized secrets configuration."""
    
    def __init__(self):
        self.manager = SecretsManager(
            provider=os.getenv("SECRETS_PROVIDER", "env")
        )
        self._load_secrets()
    
    def _load_secrets(self):
        """Load all required secrets."""
        self.DATABASE_URL = self.manager.get_secret("DATABASE_URL")
        self.REDIS_URL = self.manager.get_secret("REDIS_URL")
        self.MONGODB_URI = self.manager.get_secret("MONGODB_URI")
        self.NEO4J_URI = self.manager.get_secret("NEO4J_URI")
        self.SECRET_KEY = self.manager.get_secret("SECRET_KEY")
        self.JWT_SECRET = self.manager.get_secret("JWT_SECRET")
        self.ENCRYPTION_KEY = self.manager.get_secret("ENCRYPTION_KEY")
        self.OPENAI_API_KEY = self.manager.get_secret("OPENAI_API_KEY")
        self.STRIPE_SECRET_KEY = self.manager.get_secret("STRIPE_SECRET_KEY")
        self.AWS_ACCESS_KEY = self.manager.get_secret("AWS_ACCESS_KEY_ID")
        self.AWS_SECRET_KEY = self.manager.get_secret("AWS_SECRET_ACCESS_KEY")
    
    def get(self, key: str, default: Any = None) -> Any:
        """Get a secret by key."""
        return getattr(self, key, default)

# Usage in application
secrets = AppSecrets()
db_url = secrets.get("DATABASE_URL")
```

### G.6.2 TLS/SSL Configuration

```python
# File: src/security/tls.py
import ssl
import os
from pathlib import Path

class TLSConfig:
    """TLS/SSL configuration for secure connections."""
    
    @staticmethod
    def get_ssl_context() -> ssl.SSLContext:
        """Get SSL context for secure connections."""
        context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
        
        # Load certificate and key
        cert_path = os.getenv("SSL_CERT_PATH", "/etc/ssl/certs/server.crt")
        key_path = os.getenv("SSL_KEY_PATH", "/etc/ssl/private/server.key")
        
        if os.path.exists(cert_path) and os.path.exists(key_path):
            context.load_cert_chain(cert_path, key_path)
        else:
            # Development fallback - generate self-signed
            context = ssl.create_default_context(ssl.Purpose.CLIENT_AUTH)
            context.load_cert_chain(
                Path(__file__).parent / "dev-certs" / "server.crt",
                Path(__file__).parent / "dev-certs" / "server.key"
            )
        
        # Security settings
        context.minimum_version = ssl.TLSVersion.TLSv1_2
        context.set_ciphers('ECDHE+AESGCM:ECDHE+CHACHA20:DHE+AESGCM')
        context.options |= ssl.OP_NO_TICKET
        
        return context
    
    @staticmethod
    def configure_uvicorn():
        """Configure Uvicorn with SSL."""
        return {
            "ssl_keyfile": os.getenv("SSL_KEY_PATH", "/etc/ssl/private/server.key"),
            "ssl_certfile": os.getenv("SSL_CERT_PATH", "/etc/ssl/certs/server.crt"),
            "ssl_keyfile_password": os.getenv("SSL_KEY_PASSWORD"),
            "ssl_ca_certs": os.getenv("SSL_CA_CERTS"),
            "ssl_cert_reqs": ssl.CERT_REQUIRED if os.getenv("SSL_VERIFY_CLIENT") else ssl.CERT_NONE,
        }

# FastAPI SSL middleware
from fastapi import FastAPI
from fastapi.middleware.httpsredirect import HTTPSRedirectMiddleware

app = FastAPI()

# Force HTTPS in production
if os.getenv("APP_ENV") == "production":
    app.add_middleware(HTTPSRedirectMiddleware)
```

---

## G.7 Security Testing

### G.7.1 Vulnerability Scanning

```python
# File: tests/security/test_vulnerabilities.py
import pytest
import requests
from typing import List, Dict
import json

class TestVulnerabilities:
    """Security vulnerability tests."""
    
    @pytest.mark.security
    def test_sql_injection_vulnerabilities(self, base_url: str):
        """Test for SQL injection vulnerabilities."""
        malicious_payloads = [
            "' OR '1'='1",
            "'; DROP TABLE users; --",
            "1' UNION SELECT * FROM customers --",
            "' AND 1=1 --",
            "' OR 1=1#",
            "admin'--"
        ]
        
        for payload in malicious_payloads:
            # Test login endpoint
            response = requests.post(
                f"{base_url}/api/v1/auth/login",
                json={"email": f"user{payload}@example.com", "password": "password"}
            )
            # Should not return sensitive data
            assert "password" not in response.text.lower()
            assert "credit_card" not in response.text.lower()
            
            # Test search endpoint
            response = requests.get(
                f"{base_url}/api/v1/products?search={payload}"
            )
            # Should not throw error or reveal database structure
            assert response.status_code != 500
            
            # Test order endpoint
            response = requests.get(
                f"{base_url}/api/v1/orders?customer_id={payload}"
            )
            assert response.status_code in [400, 401, 403, 404]
    
    @pytest.mark.security
    def test_xss_vulnerabilities(self, base_url: str):
        """Test for XSS vulnerabilities."""
        xss_payloads = [
            "<script>alert('XSS')</script>",
            "<img src=x onerror=alert('XSS')>",
            "javascript:alert('XSS')",
            "<svg/onload=alert('XSS')>",
            "'';!--\"<XSS>=&{()}"
        ]
        
        for payload in xss_payloads:
            # Test product creation
            response = requests.post(
                f"{base_url}/api/v1/products",
                json={
                    "name": payload,
                    "description": payload,
                    "price": 10.00,
                    "category_id": 1
                },
                headers={"Authorization": "Bearer admin_token"}
            )
            
            if response.status_code == 201:
                product_id = response.json()["id"]
                
                # Get product and verify encoding
                get_response = requests.get(
                    f"{base_url}/api/v1/products/{product_id}"
                )
                data = get_response.json()
                # Check that scripts are escaped, not executed
                assert "<script>" not in data.get("name", "")
                assert "alert" not in data.get("description", "")
    
    @pytest.mark.security
    def test_csrf_protection(self, base_url: str):
        """Test CSRF protection."""
        response = requests.post(
            f"{base_url}/api/v1/orders",
            json={"customer_id": 1, "items": []},
            headers={"Origin": "https://evil.com"}
        )
        # Should reject cross-origin requests
        assert response.status_code in [401, 403, 400]
    
    @pytest.mark.security
    def test_security_headers(self, base_url: str):
        """Test security headers are present and correct."""
        response = requests.get(f"{base_url}/")
        
        required_headers = {
            "X-Frame-Options": ["DENY", "SAMEORIGIN"],
            "X-Content-Type-Options": ["nosniff"],
            "X-XSS-Protection": ["1", "1; mode=block"],
            "Strict-Transport-Security": ["max-age=", "includeSubDomains"],
            "Content-Security-Policy": ["default-src", "script-src"]
        }
        
        for header, valid_values in required_headers.items():
            assert header in response.headers, f"Missing header: {header}"
            assert any(v in response.headers[header] for v in valid_values), \
                f"Invalid {header} value: {response.headers[header]}"
    
    @pytest.mark.security
    def test_sensitive_data_exposure(self, base_url: str, api_token: str):
        """Test that sensitive data is not exposed."""
        headers = {"Authorization": f"Bearer {api_token}"}
        
        # Test customer endpoint
        response = requests.get(
            f"{base_url}/api/v1/customers/me",
            headers=headers
        )
        data = response.json()
        
        # Should not expose passwords
        assert "password" not in data
        assert "password_hash" not in data
        
        # Test order endpoint
        response = requests.get(
            f"{base_url}/api/v1/orders",
            headers=headers
        )
        if response.status_code == 200:
            for order in response.json().get("data", []):
                # Should not expose payment details
                assert "credit_card" not in str(order)
                assert "cvv" not in str(order)
                assert "card_number" not in str(order)
    
    @pytest.mark.security
    def test_brute_force_protection(self, base_url: str):
        """Test brute force protection on login."""
        import time
        
        # Rapid login attempts
        failed_attempts = 0
        for i in range(20):
            response = requests.post(
                f"{base_url}/api/v1/auth/login",
                json={"email": "user@example.com", "password": "wrong_password"}
            )
            if response.status_code == 429:
                # Rate limiting kicked in
                failed_attempts += 1
                break
            time.sleep(0.1)
        
        assert failed_attempts > 0, "Brute force protection not triggered"
        assert "X-RateLimit-Reset" in response.headers
    
    @pytest.mark.security
    def test_jwt_security(self, base_url: str):
        """Test JWT token security."""
        # Test with invalid token
        response = requests.get(
            f"{base_url}/api/v1/customers/me",
            headers={"Authorization": "Bearer invalid.token.here"}
        )
        assert response.status_code == 401
        
        # Test with expired token (simulated)
        expired_token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxIiwiaWF0IjoxNTE2MjM5MDIyLCJleHAiOjB9.invalid"
        response = requests.get(
            f"{base_url}/api/v1/customers/me",
            headers={"Authorization": f"Bearer {expired_token}"}
        )
        assert response.status_code == 401
        
        # Test with wrong algorithm
        wrong_algo_token = "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.invalid"
        response = requests.get(
            f"{base_url}/api/v1/customers/me",
            headers={"Authorization": f"Bearer {wrong_algo_token}"}
        )
        assert response.status_code == 401
```

---

## G.8 Compliance Framework

### G.8.1 GDPR Compliance

```python
# File: src/security/gdpr.py
from datetime import datetime, timedelta
from typing import Optional, Dict, Any
import hashlib
import json

class GDPRCompliance:
    """GDPR compliance utilities."""
    
    @staticmethod
    def anonymize_user_data(customer_id: int, db_session) -> bool:
        """Anonymize user data for GDPR right to erasure."""
        try:
            # Anonymize customer record
            db_session.execute(
                text("""
                    UPDATE customers
                    SET 
                        email = CONCAT('deleted_', id, '@deleted.com'),
                        password_hash = 'ANONYMIZED',
                        full_name = 'Deleted User',
                        phone = NULL,
                        is_active = false
                    WHERE id = :customer_id
                """),
                {"customer_id": customer_id}
            )
            
            # Anonymize order history (keep for financial records)
            db_session.execute(
                text("""
                    UPDATE orders
                    SET 
                        customer_id = NULL,
                        shipping_address_id = NULL,
                        billing_address_id = NULL,
                        notes = 'Order anonymized for GDPR'
                    WHERE customer_id = :customer_id
                """),
                {"customer_id": customer_id}
            )
            
            # Anonymize reviews
            db_session.execute(
                text("""
                    UPDATE reviews
                    SET 
                        customer_id = NULL,
                        comment = 'Review removed for GDPR'
                    WHERE customer_id = :customer_id
                """),
                {"customer_id": customer_id}
            )
            
            db_session.commit()
            return True
        except Exception as e:
            db_session.rollback()
            print(f"GDPR anonymization failed: {e}")
            return False
    
    @staticmethod
    def export_user_data(customer_id: int, db_session) -> Dict[str, Any]:
        """Export user data for GDPR right to portability."""
        # Get customer data
        customer = db_session.execute(
            text("SELECT * FROM customers WHERE id = :customer_id"),
            {"customer_id": customer_id}
        ).fetchone()
        
        # Get orders
        orders = db_session.execute(
            text("SELECT * FROM orders WHERE customer_id = :customer_id"),
            {"customer_id": customer_id}
        ).fetchall()
        
        # Get addresses
        addresses = db_session.execute(
            text("SELECT * FROM addresses WHERE customer_id = :customer_id"),
            {"customer_id": customer_id}
        ).fetchall()
        
        # Get reviews
        reviews = db_session.execute(
            text("SELECT * FROM reviews WHERE customer_id = :customer_id"),
            {"customer_id": customer_id}
        ).fetchall()
        
        return {
            "customer": dict(customer) if customer else None,
            "orders": [dict(order) for order in orders],
            "addresses": [dict(address) for address in addresses],
            "reviews": [dict(review) for review in reviews],
            "export_date": datetime.utcnow().isoformat(),
            "format": "JSON"
        }
    
    @staticmethod
    def pseudonymize_data(data: Dict) -> Dict:
        """Pseudonymize data (replace identifiers with pseudonyms)."""
        # Use deterministic hashing for consistent pseudonyms
        def pseudonymize(value: str) -> str:
            if not value:
                return value
            return hashlib.sha256(value.encode()).hexdigest()[:16]
        
        # Identify PII fields
        pii_fields = ["email", "phone", "full_name", "street", "city", "postal_code"]
        
        for field in pii_fields:
            if field in data and data[field]:
                data[field] = pseudonymize(str(data[field]))
        
        return data

# GDPR middleware for data access
from fastapi import FastAPI, Request

app = FastAPI()

@app.middleware("http")
async def gdpr_middleware(request: Request, call_next):
    """Middleware to enforce GDPR compliance."""
    response = await call_next(request)
    
    # Add GDPR headers
    response.headers["X-GDPR-Compliance"] = "enforced"
    response.headers["X-Data-Retention"] = "30-days"
    response.headers["X-Data-Retention-Sensitive"] = "7-years"
    
    # Log data access for GDPR audit
    if request.method in ["GET", "POST", "PUT", "PATCH"]:
        # Log the access for audit trail
        pass
    
    return response
```

### G.8.2 PCI-DSS Compliance (Payment Security)

```python
# File: src/security/pci.py
import re
import json
from typing import Dict, Any, Optional

class PCIDSSCompliance:
    """PCI-DSS compliance utilities for payment processing."""
    
    @staticmethod
    def mask_payment_data(payment_data: Dict) -> Dict:
        """Mask sensitive payment data."""
        masked_data = payment_data.copy()
        
        # Mask card numbers
        if "card_number" in masked_data:
            card = masked_data["card_number"]
            if len(card) >= 4:
                masked_data["card_number"] = "*" * (len(card) - 4) + card[-4:]
        
        # Mask CVV (never store)
        if "cvv" in masked_data:
            masked_data["cvv"] = "***"
        
        # Mask expiration date (partially)
        if "expiry" in masked_data:
            masked_data["expiry"] = f"**/{masked_data['expiry'][-2:]}"
        
        return masked_data
    
    @staticmethod
    def validate_card_number(card_number: str) -> bool:
        """Validate credit card number using Luhn algorithm."""
        card_number = card_number.replace(" ", "").replace("-", "")
        if not card_number.isdigit():
            return False
        
        # Luhn algorithm
        total = 0
        reverse_digits = card_number[::-1]
        for i, digit in enumerate(reverse_digits):
            n = int(digit)
            if i % 2 == 1:
                n *= 2
                if n > 9:
                    n -= 9
            total += n
        
        return total % 10 == 0
    
    @staticmethod
    def validate_cvv(cvv: str, card_type: str = "visa") -> bool:
        """Validate CVV based on card type."""
        if not cvv or not cvv.isdigit():
            return False
        
        if card_type in ["visa", "mastercard", "discover", "jcb"]:
            return len(cvv) == 3
        elif card_type == "amex":
            return len(cvv) == 4
        return False
    
    @staticmethod
    def tokenize_card(card_data: Dict) -> str:
        """Tokenize card data (create reference token)."""
        # In production, use a PCI-compliant tokenization service
        import uuid
        token = str(uuid.uuid4())
        return token

# Payment service with PCI compliance
class SecurePaymentService:
    """Secure payment processing with PCI compliance."""
    
    def __init__(self, db_session):
        self.session = db_session
        self.pci = PCIDSSCompliance()
    
    def process_payment(self, payment_data: Dict) -> Dict:
        """Process payment with PCI compliance."""
        # Validate card data
        if not self.pci.validate_card_number(payment_data.get("card_number", "")):
            raise ValueError("Invalid card number")
        
        if not self.pci.validate_cvv(
            payment_data.get("cvv", ""),
            payment_data.get("card_type", "visa")
        ):
            raise ValueError("Invalid CVV")
        
        # Tokenize card
        token = self.pci.tokenize_card(payment_data)
        
        # Mask data for storage
        masked_data = self.pci.mask_payment_data(payment_data)
        
        # Store only token and masked data
        result = {
            "payment_id": 12345,
            "token": token,
            "masked_data": masked_data,
            "status": "processed"
        }
        
        return result
    
    def get_payment_history(self, customer_id: int) -> Dict:
        """Get masked payment history."""
        # Get payment records from database
        payments = self.session.execute(
            text("""
                SELECT 
                    id,
                    amount,
                    method,
                    status,
                    payment_date,
                    metadata
                FROM payments
                WHERE customer_id = :customer_id
            """),
            {"customer_id": customer_id}
        ).fetchall()
        
        # Mask sensitive data
        for payment in payments:
            if payment.metadata and "card_number" in payment.metadata:
                payment.metadata["card_number"] = "*" * 12 + payment.metadata["card_number"][-4:]
        
        return {"payments": [dict(p) for p in payments]}
```

---

## G.9 Security Monitoring & Incident Response

### G.9.1 Security Monitoring

```python
# File: src/security/monitoring.py
import logging
import json
from datetime import datetime
from typing import Dict, Any
import requests

class SecurityMonitor:
    """Security monitoring and alerting."""
    
    def __init__(self, webhook_url: str = None):
        self.webhook_url = webhook_url
        self.logger = logging.getLogger("security")
    
    def log_security_event(
        self,
        event_type: str,
        severity: str,
        details: Dict[str, Any],
        user_id: int = None,
        ip_address: str = None
    ):
        """Log a security event."""
        event_data = {
            "timestamp": datetime.utcnow().isoformat(),
            "event_type": event_type,
            "severity": severity,
            "details": details,
            "user_id": user_id,
            "ip_address": ip_address
        }
        
        # Log to file
        self.logger.warning(json.dumps(event_data))
        
        # Send alert for critical events
        if severity in ["critical", "high"]:
            self.send_alert(event_data)
    
    def send_alert(self, event_data: Dict):
        """Send security alert to configured webhook."""
        if self.webhook_url:
            try:
                requests.post(
                    self.webhook_url,
                    json={
                        "text": f"🚨 Security Alert: {event_data['event_type']}",
                        "blocks": [
                            {
                                "type": "section",
                                "fields": [
                                    {"type": "mrkdwn", "text": f"*Severity:* {event_data['severity']}"},
                                    {"type": "mrkdwn", "text": f"*Time:* {event_data['timestamp']}"},
                                    {"type": "mrkdwn", "text": f"*Details:* {json.dumps(event_data['details'], indent=2)}"}
                                ]
                            }
                        ]
                    },
                    timeout=5
                )
            except Exception as e:
                self.logger.error(f"Failed to send security alert: {e}")
    
    def detect_suspicious_activity(self, request, user_id: int = None):
        """Detect suspicious activity patterns."""
        suspicious_patterns = []
        
        # Multiple failed logins
        # Check in Redis for failed login attempts
        
        # Suspicious user agent
        user_agent = request.headers.get("user-agent", "")
        suspicious_uas = ["sqlmap", "nmap", "masscan", "wpscan"]
        if any(ua in user_agent.lower() for ua in suspicious_uas):
            suspicious_patterns.append(f"Suspicious user agent: {user_agent}")
        
        # Suspicious IP (check against threat intelligence)
        client_ip = request.client.host
        if self.is_suspicious_ip(client_ip):
            suspicious_patterns.append(f"Suspicious IP: {client_ip}")
        
        # Unusual request patterns
        if self.is_unusual_request(request):
            suspicious_patterns.append(f"Unusual request pattern: {request.url}")
        
        if suspicious_patterns:
            self.log_security_event(
                event_type="suspicious_activity_detected",
                severity="high",
                details={"patterns": suspicious_patterns},
                user_id=user_id,
                ip_address=client_ip
            )
        
        return suspicious_patterns
    
    def is_suspicious_ip(self, ip: str) -> bool:
        """Check if IP is suspicious (tor, known bad actors)."""
        # Check against threat intelligence (simplified)
        # In production, use a service like VirusTotal, AbuseIPDB
        suspicious_ips = [
            "127.0.0.1",  # Example only
        ]
        return ip in suspicious_ips
    
    def is_unusual_request(self, request) -> bool:
        """Check if request pattern is unusual."""
        # Very large request body
        if request.headers.get("content-length", 0) > 1024 * 1024 * 10:  # 10MB
            return True
        
        # Suspicious query parameters
        suspicious_params = ["union", "select", "insert", "drop", "exec"]
        for param in suspicious_params:
            if param in str(request.url).lower():
                return True
        
        return False

# Security middleware
from fastapi import FastAPI, Request

app = FastAPI()
security_monitor = SecurityMonitor(os.getenv("SECURITY_WEBHOOK"))

@app.middleware("http")
async def security_middleware(request: Request, call_next):
    """Security monitoring middleware."""
    # Check for suspicious activity
    user_id = request.headers.get("X-User-ID")
    suspicious = security_monitor.detect_suspicious_activity(request, user_id)
    
    if suspicious:
        # Block request for critical issues
        return {"status": "blocked", "reason": "Suspicious activity detected"}
    
    response = await call_next(request)
    
    # Log security headers
    if response.status_code in [401, 403, 429]:
        security_monitor.log_security_event(
            event_type="unauthorized_access_attempt",
            severity="medium",
            details={"status": response.status_code, "path": request.url.path},
            user_id=user_id,
            ip_address=request.client.host
        )
    
    return response
```

---

## G.10 Security Quick Reference

### G.10.1 Security Checklist

```markdown
# Security Implementation Checklist

## Authentication
- [ ] Password hashing using bcrypt/Argon2
- [ ] JWT tokens with short expiration (15-30 minutes)
- [ ] Refresh token rotation
- [ ] Multi-factor authentication (MFA) ready
- [ ] OAuth2/OIDC integration for third-party auth
- [ ] Session management with secure cookies

## Authorization
- [ ] Role-based access control (RBAC) implemented
- [ ] Permission checking on all endpoints
- [ ] Row-level security for data isolation
- [ ] Principle of least privilege enforced

## Data Protection
- [ ] Encryption at rest for sensitive data
- [ ] TLS/SSL for all network traffic
- [ ] Data masking for PII in logs/APIs
- [ ] Secure key management (AWS KMS, Vault)
- [ ] Database field-level encryption for sensitive fields

## API Security
- [ ] Input validation and sanitization
- [ ] Rate limiting on all endpoints
- [ ] CORS properly configured
- [ ] Security headers (HSTS, CSP, X-Frame-Options)
- [ ] API keys for external services

## Infrastructure Security
- [ ] Secrets management (not in code)
- [ ] Firewall rules configured
- [ ] Network segmentation (VPC, subnets)
- [ ] Container security (non-root user, read-only filesystem)
- [ ] Regular security updates/patching

## Monitoring & Response
- [ ] Security event logging
- [ ] Intrusion detection/prevention
- [ ] Incident response plan documented
- [ ] Regular security audits
- [ ] Vulnerability scanning (weekly)
- [ ] Penetration testing (quarterly)

## Compliance
- [ ] GDPR compliance (data portability, right to erasure)
- [ ] PCI-DSS compliance (payment data handling)
- [ ] SOC2 readiness
- [ ] Data retention policies
- [ ] Privacy policy and terms of service
```

---

**[END OF APPENDIX G]**

*This comprehensive security implementation guide provides everything needed to secure the ScaleCart platform. Use it to implement a defense-in-depth security strategy across all layers of the application.*
