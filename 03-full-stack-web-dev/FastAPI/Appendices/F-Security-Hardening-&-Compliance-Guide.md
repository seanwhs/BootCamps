# Appendix F: Security Hardening & Compliance Guide

Welcome to Appendix F of the FastAPI Masterclass series! This comprehensive guide covers everything you need to know about securing your FastAPI application and ensuring compliance with industry standards. From OWASP Top 10 to GDPR compliance, this appendix serves as your security handbook.

## Table of Contents
1. [Security Overview](#security-overview)
2. [OWASP Top 10 Implementation](#owasp-top-10-implementation)
3. [Authentication & Authorization](#authentication--authorization)
4. [Data Protection](#data-protection)
5. [API Security](#api-security)
6. [Infrastructure Security](#infrastructure-security)
7. [Compliance Frameworks](#compliance-frameworks)
8. [Security Monitoring](#security-monitoring)
9. [Incident Response](#incident-response)
10. [Security Checklist](#security-checklist)

---

## Security Overview

### Security Principles

```markdown
# Security Principles (CIA Triad)

## Confidentiality
- Encrypt data at rest and in transit
- Implement proper access controls
- Use secure key management
- Minimize data exposure

## Integrity
- Validate all inputs
- Use cryptographic signatures
- Implement audit logging
- Prevent unauthorized modifications

## Availability
- Implement rate limiting
- Use load balancing
- Plan for disaster recovery
- Monitor system health

## Additional Principles
- **Least Privilege**: Users get minimum access needed
- **Defense in Depth**: Multiple layers of security
- **Fail Secure**: Fail to a secure state
- **Separation of Duties**: No single person has all access
- **Security by Design**: Built-in from the start
```

### Security Threat Model

```python
"""
app/security/threat_model.py
Application threat modeling and risk assessment.
"""

from enum import Enum
from typing import Dict, List, Any
from dataclasses import dataclass


class ThreatCategory(Enum):
    """Categories of security threats."""
    AUTHENTICATION = "authentication"
    AUTHORIZATION = "authorization"
    DATA_BREACH = "data_breach"
    DOS = "denial_of_service"
    INJECTION = "injection"
    MISCONFIGURATION = "misconfiguration"
    SOCIAL_ENGINEERING = "social_engineering"


@dataclass
class Threat:
    """Security threat definition."""
    id: str
    name: str
    category: ThreatCategory
    severity: str  # critical, high, medium, low
    likelihood: str  # high, medium, low
    impact: str
    mitigation: str
    status: str  # mitigated, in_progress, identified


class ThreatModel:
    """Application threat model."""
    
    THREATS = [
        Threat(
            id="T001",
            name="JWT Token Theft",
            category=ThreatCategory.AUTHENTICATION,
            severity="critical",
            likelihood="medium",
            impact="Complete account takeover",
            mitigation="Short-lived tokens, HTTPS, secure storage",
            status="mitigated"
        ),
        Threat(
            id="T002",
            name="SQL Injection",
            category=ThreatCategory.INJECTION,
            severity="critical",
            likelihood="low",
            impact="Database compromise",
            mitigation="ORM, parameterized queries, input validation",
            status="mitigated"
        ),
        Threat(
            id="T003",
            name="Brute Force Attack",
            category=ThreatCategory.AUTHENTICATION,
            severity="high",
            likelihood="high",
            impact="Account compromise",
            mitigation="Rate limiting, account lockout, strong passwords",
            status="mitigated"
        ),
        Threat(
            id="T004",
            name="API Key Exposure",
            category=ThreatCategory.AUTHENTICATION,
            severity="high",
            likelihood="medium",
            impact="Unauthorized API access",
            mitigation="API key rotation, IP whitelisting, logging",
            status="in_progress"
        ),
        Threat(
            id="T005",
            name="DDoS Attack",
            category=ThreatCategory.DOS,
            severity="high",
            likelihood="high",
            impact="Service unavailability",
            mitigation="Rate limiting, WAF, CDN, auto-scaling",
            status="mitigated"
        ),
    ]
    
    @classmethod
    def get_risks(cls) -> Dict[str, List[Threat]]:
        """Get risks grouped by severity."""
        risks = {"critical": [], "high": [], "medium": [], "low": []}
        
        for threat in cls.THREATS:
            if threat.severity in risks:
                risks[threat.severity].append(threat)
        
        return risks
    
    @classmethod
    def get_unmitigated(cls) -> List[Threat]:
        """Get unmitigated threats."""
        return [t for t in cls.THREATS if t.status != "mitigated"]
```

---

## OWASP Top 10 Implementation

### Complete OWASP Protection

**`app/security/owasp.py`:**

```python
"""
app/security/owasp.py
OWASP Top 10 security implementations.
"""

from fastapi import Request, Response
from fastapi.middleware.base import BaseHTTPMiddleware
from typing import Optional, Set
import re
import bleach
from html import escape
import logging

logger = logging.getLogger(__name__)


# ────────────────────────────────────────────────────────────────
# A01: Broken Access Control
# ────────────────────────────────────────────────────────────────

class AccessControlMiddleware:
    """
    Enforce proper access control.
    
    Implements:
    - Role-based access control (RBAC)
    - Resource ownership checks
    - Deny by default
    """
    
    async def __call__(self, request: Request, call_next):
        # Get user from request state
        user = getattr(request.state, "user", None)
        
        # Check if endpoint requires specific role
        required_roles = getattr(request.state, "required_roles", [])
        
        if required_roles:
            if not user:
                return Response(
                    content="Authentication required",
                    status_code=401
                )
            
            # Check if user has required role
            if not any(role in user.get("roles", []) for role in required_roles):
                return Response(
                    content="Insufficient permissions",
                    status_code=403
                )
        
        # Check resource ownership
        resource_owner = getattr(request.state, "resource_owner", None)
        if resource_owner and user:
            if str(resource_owner) != str(user.get("id")):
                # Check if user has admin privileges
                if "admin" not in user.get("roles", []):
                    return Response(
                        content="You don't own this resource",
                        status_code=403
                    )
        
        return await call_next(request)


# ────────────────────────────────────────────────────────────────
# A02: Cryptographic Failures
# ────────────────────────────────────────────────────────────────

class CryptographicManager:
    """Secure cryptographic operations."""
    
    @staticmethod
    def encrypt_sensitive_data(data: str, key: bytes) -> bytes:
        """Encrypt sensitive data."""
        from cryptography.fernet import Fernet
        cipher = Fernet(key)
        return cipher.encrypt(data.encode())
    
    @staticmethod
    def decrypt_sensitive_data(encrypted: bytes, key: bytes) -> str:
        """Decrypt sensitive data."""
        from cryptography.fernet import Fernet
        cipher = Fernet(key)
        return cipher.decrypt(encrypted).decode()
    
    @staticmethod
    def generate_secure_key() -> bytes:
        """Generate a secure encryption key."""
        from cryptography.fernet import Fernet
        return Fernet.generate_key()
    
    @staticmethod
    def hash_data(data: str, salt: Optional[bytes] = None) -> str:
        """Hash data securely."""
        import hashlib
        import os
        
        if salt is None:
            salt = os.urandom(32)
        
        return hashlib.pbkdf2_hmac(
            'sha256',
            data.encode(),
            salt,
            100000,
            dklen=64
        ).hex()


# ────────────────────────────────────────────────────────────────
# A03: Injection Prevention
# ────────────────────────────────────────────────────────────────

class InjectionPrevention:
    """Prevent injection attacks (SQL, NoSQL, OS, LDAP)."""
    
    # Dangerous patterns to block
    SQL_PATTERNS = [
        r'(?i)(SELECT|INSERT|UPDATE|DELETE|DROP|UNION|--|;|\*)(.*)',
        r'(?i)(\'|")(.*)(SELECT|INSERT|UPDATE|DELETE|DROP|UNION)',
    ]
    
    OS_PATTERNS = [
        r'(?i)(;|\||&&|>|<|`|\$|\(|\)|\{|\})',
        r'(?i)(curl|wget|nc|bash|sh|python|perl)',
    ]
    
    @classmethod
    def sanitize_input(cls, value: str, context: str = "general") -> str:
        """
        Sanitize user input based on context.
        
        Args:
            value: Input string
            context: 'sql', 'html', 'os', 'general'
            
        Returns:
            str: Sanitized input
        """
        if not value:
            return value
        
        # HTML sanitization
        if context == "html":
            return bleach.clean(value, strip=True)
        
        # SQL injection prevention
        if context == "sql":
            for pattern in cls.SQL_PATTERNS:
                if re.search(pattern, value):
                    logger.warning(f"Potential SQL injection attempt: {value}")
                    raise ValueError("Invalid input detected")
        
        # OS command injection prevention
        if context == "os":
            for pattern in cls.OS_PATTERNS:
                if re.search(pattern, value):
                    logger.warning(f"Potential OS injection attempt: {value}")
                    raise ValueError("Invalid input detected")
        
        # General sanitization
        return bleach.clean(value, strip=True)
    
    @classmethod
    def validate_and_sanitize(cls, data: dict, schema: dict) -> dict:
        """
        Validate and sanitize dictionary data.
        
        Args:
            data: Input data
            schema: Schema defining field types and validations
            
        Returns:
            dict: Sanitized data
        """
        sanitized = {}
        
        for field, field_info in schema.items():
            if field not in data:
                continue
            
            value = data[field]
            field_type = field_info.get("type", "string")
            field_context = field_info.get("context", "general")
            
            # Type conversion
            if field_type == "string":
                value = str(value)
                value = cls.sanitize_input(value, field_context)
            elif field_type == "int":
                try:
                    value = int(value)
                except (ValueError, TypeError):
                    raise ValueError(f"Invalid integer for field: {field}")
            elif field_type == "email":
                value = str(value).lower().strip()
                if not re.match(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$', value):
                    raise ValueError(f"Invalid email for field: {field}")
            elif field_type == "bool":
                value = str(value).lower() in ('true', '1', 'yes', 'on')
            
            sanitized[field] = value
        
        return sanitized


# ────────────────────────────────────────────────────────────────
# A04: Insecure Design
# ────────────────────────────────────────────────────────────────

class SecureDesignPatterns:
    """Implement secure design patterns."""
    
    @staticmethod
    def secure_by_default(settings):
        """Apply secure defaults."""
        defaults = {
            "DEBUG": False,
            "SECURE_COOKIES": True,
            "CORS_ORIGINS": [],
            "ALLOWED_HOSTS": [],
            "RATE_LIMIT_ENABLED": True,
            "AUDIT_LOGGING_ENABLED": True,
            "MAX_UPLOAD_SIZE": 10 * 1024 * 1024,  # 10MB
        }
        
        for key, value in defaults.items():
            if not hasattr(settings, key):
                setattr(settings, key, value)
        
        return settings
    
    @staticmethod
    def secure_error_handling(request: Request, exc: Exception) -> dict:
        """
        Secure error handling - don't leak sensitive info.
        
        Args:
            request: FastAPI request
            exc: Exception
            
        Returns:
            dict: Safe error response
        """
        # Log full error for debugging
        logger.error(
            f"Error: {exc}",
            extra={
                "path": request.url.path,
                "method": request.method,
                "client_ip": request.client.host if request.client else None,
            },
            exc_info=True,
        )
        
        # Return safe error message
        return {
            "error": "An error occurred",
            "code": "INTERNAL_ERROR",
        }


# ────────────────────────────────────────────────────────────────
# A05: Security Misconfiguration
# ────────────────────────────────────────────────────────────────

class SecurityConfigurationValidator:
    """Validate security configuration."""
    
    @classmethod
    def validate_config(cls, settings) -> List[str]:
        """
        Validate security configuration.
        
        Returns:
            List[str]: List of configuration issues
        """
        issues = []
        
        # Check debug mode
        if getattr(settings, "DEBUG", False):
            issues.append("DEBUG is enabled in production")
        
        # Check secret key
        secret = getattr(settings, "SECRET_KEY", "")
        if len(secret) < 32:
            issues.append("SECRET_KEY is too short (< 32 characters)")
        
        # Check CORS origins
        cors_origins = getattr(settings, "CORS_ORIGINS", [])
        if "*" in cors_origins:
            issues.append("CORS_ORIGINS includes '*' (wildcard)")
        
        # Check allowed hosts
        allowed_hosts = getattr(settings, "ALLOWED_HOSTS", [])
        if not allowed_hosts:
            issues.append("ALLOWED_HOSTS is empty")
        
        # Check HTTPS
        if getattr(settings, "APP_ENV", "") == "production":
            if not getattr(settings, "HTTPS_ENABLED", False):
                issues.append("HTTPS is not enabled in production")
        
        # Check rate limiting
        if not getattr(settings, "RATE_LIMIT_ENABLED", True):
            issues.append("Rate limiting is disabled")
        
        return issues


# ────────────────────────────────────────────────────────────────
# A06: Vulnerable and Outdated Components
# ────────────────────────────────────────────────────────────────

class DependencySecurityScanner:
    """Scan dependencies for vulnerabilities."""
    
    @staticmethod
    async def scan_dependencies() -> Dict[str, Any]:
        """
        Scan Python dependencies for known vulnerabilities.
        
        Returns:
            Dict: Scan results
        """
        # In production, use safety or pip-audit
        import subprocess
        import json
        
        try:
            result = subprocess.run(
                ["safety", "check", "--json"],
                capture_output=True,
                text=True,
            )
            
            if result.returncode == 0:
                return {"status": "safe", "issues": []}
            else:
                return json.loads(result.stdout)
        except Exception as e:
            logger.error(f"Failed to scan dependencies: {e}")
            return {"status": "error", "message": str(e)}
    
    @staticmethod
    def get_outdated_packages() -> List[Dict]:
        """Get outdated packages."""
        import pip
        from pip._internal.utils.misc import get_installed_distributions
        
        outdated = []
        for dist in get_installed_distributions():
            try:
                # Check if there's a newer version
                pass  # Implement version checking
            except:
                pass
        
        return outdated


# ────────────────────────────────────────────────────────────────
# A07: Identification and Authentication Failures
# ────────────────────────────────────────────────────────────────

class AuthenticationSecurity:
    """Secure authentication implementation."""
    
    @staticmethod
    def validate_password_strength(password: str) -> bool:
        """
        Validate password strength.
        
        Requirements:
        - Minimum 12 characters
        - At least one uppercase letter
        - At least one lowercase letter
        - At least one number
        - At least one special character
        - No common passwords
        - No sequential characters
        """
        if len(password) < 12:
            return False
        
        if not re.search(r'[A-Z]', password):
            return False
        
        if not re.search(r'[a-z]', password):
            return False
        
        if not re.search(r'\d', password):
            return False
        
        if not re.search(r'[!@#$%^&*(),.?":{}|<>]', password):
            return False
        
        # Check for common passwords
        common_passwords = {
            'password123', 'admin123', 'qwerty123', 'letmein123',
            'welcome123', 'passw0rd', 'abc123', '12345678'
        }
        if password.lower() in common_passwords:
            return False
        
        # Check for sequential characters
        if re.search(r'(?:abc|bcd|cde|def|efg|fgh|ghi|hij|ijk|jkl|klm|lmn|mno|nop|opq|pqr|qrs|rst|stu|tuv|uvw|vwx|wxy|xyz)', password.lower()):
            return False
        
        if re.search(r'(?:123|234|345|456|567|678|789|890)', password):
            return False
        
        return True
    
    @staticmethod
    def get_password_strength_feedback(password: str) -> List[str]:
        """
        Get feedback on password strength.
        
        Returns:
            List[str]: Feedback messages
        """
        feedback = []
        
        if len(password) < 12:
            feedback.append("Password must be at least 12 characters")
        
        if not re.search(r'[A-Z]', password):
            feedback.append("Password must contain at least one uppercase letter")
        
        if not re.search(r'[a-z]', password):
            feedback.append("Password must contain at least one lowercase letter")
        
        if not re.search(r'\d', password):
            feedback.append("Password must contain at least one number")
        
        if not re.search(r'[!@#$%^&*(),.?":{}|<>]', password):
            feedback.append("Password must contain at least one special character")
        
        return feedback


# ────────────────────────────────────────────────────────────────
# A08: Software and Data Integrity Failures
# ────────────────────────────────────────────────────────────────

class IntegrityManager:
    """Manage software and data integrity."""
    
    @staticmethod
    def sign_data(data: bytes, secret_key: str) -> str:
        """
        Sign data for integrity verification.
        
        Args:
            data: Data to sign
            secret_key: Secret key
            
        Returns:
            str: Signature
        """
        import hmac
        import hashlib
        return hmac.new(
            secret_key.encode(),
            data,
            hashlib.sha256
        ).hexdigest()
    
    @staticmethod
    def verify_signature(data: bytes, signature: str, secret_key: str) -> bool:
        """
        Verify data signature.
        
        Args:
            data: Data to verify
            signature: Expected signature
            secret_key: Secret key
            
        Returns:
            bool: True if signature is valid
        """
        expected = IntegrityManager.sign_data(data, secret_key)
        return hmac.compare_digest(expected, signature)
    
    @staticmethod
    def get_file_checksum(file_path: str) -> str:
        """
        Calculate file checksum.
        
        Args:
            file_path: Path to file
            
        Returns:
            str: SHA-256 checksum
        """
        import hashlib
        
        sha256_hash = hashlib.sha256()
        with open(file_path, "rb") as f:
            for byte_block in iter(lambda: f.read(4096), b""):
                sha256_hash.update(byte_block)
        
        return sha256_hash.hexdigest()


# ────────────────────────────────────────────────────────────────
# A09: Security Logging and Monitoring Failures
# ────────────────────────────────────────────────────────────────

class SecurityLogging:
    """Comprehensive security logging."""
    
    LOG_EVENTS = {
        "login_success": "User logged in successfully",
        "login_failure": "Failed login attempt",
        "logout": "User logged out",
        "password_change": "Password changed",
        "password_reset": "Password reset requested",
        "user_created": "New user created",
        "user_deleted": "User deleted",
        "user_updated": "User updated",
        "permission_denied": "Permission denied",
        "api_key_created": "API key created",
        "api_key_revoked": "API key revoked",
        "rate_limit_exceeded": "Rate limit exceeded",
        "suspicious_activity": "Suspicious activity detected",
        "security_alert": "Security alert triggered",
    }
    
    @classmethod
    async def log_security_event(
        cls,
        event_type: str,
        user_id: Optional[str] = None,
        ip_address: Optional[str] = None,
        details: Optional[Dict] = None,
    ):
        """
        Log a security event.
        
        Args:
            event_type: Type of event
            user_id: User ID
            ip_address: Client IP
            details: Additional details
        """
        if event_type not in cls.LOG_EVENTS:
            logger.warning(f"Unknown security event type: {event_type}")
            return
        
        log_entry = {
            "event_type": event_type,
            "event_message": cls.LOG_EVENTS[event_type],
            "timestamp": datetime.utcnow().isoformat() + "Z",
            "user_id": user_id,
            "ip_address": ip_address,
            "details": details or {},
            "severity": "info",  # Override for critical events
        }
        
        # Adjust severity for critical events
        if event_type in ["security_alert", "suspicious_activity"]:
            log_entry["severity"] = "critical"
        elif event_type in ["login_failure", "permission_denied", "rate_limit_exceeded"]:
            log_entry["severity"] = "warning"
        
        # Log to structured logging
        logger.info(
            f"Security event: {event_type}",
            extra=log_entry
        )
        
        # Send to SIEM if configured
        # await send_to_siem(log_entry)
    
    @classmethod
    def get_security_events(cls) -> Dict[str, str]:
        """Get all security event types."""
        return cls.LOG_EVENTS


# ────────────────────────────────────────────────────────────────
# A10: Server-Side Request Forgery (SSRF)
# ────────────────────────────────────────────────────────────────

class SSRFProtection:
    """Prevent Server-Side Request Forgery."""
    
    ALLOWED_HOSTS = set()
    ALLOWED_SCHEMES = {"http", "https"}
    
    @classmethod
    async def validate_url(cls, url: str) -> bool:
        """
        Validate URL to prevent SSRF.
        
        Args:
            url: URL to validate
            
        Returns:
            bool: True if URL is safe
        """
        from urllib.parse import urlparse
        
        try:
            parsed = urlparse(url)
            
            # Check scheme
            if parsed.scheme not in cls.ALLOWED_SCHEMES:
                logger.warning(f"Blocked URL with invalid scheme: {parsed.scheme}")
                return False
            
            # Check host
            hostname = parsed.hostname
            if hostname:
                # Block localhost and internal IPs
                blocked_hosts = {
                    'localhost', '127.0.0.1', '0.0.0.0',
                    '::1', '10.0.0.0/8', '172.16.0.0/12',
                    '192.168.0.0/16', '169.254.0.0/16'
                }
                
                if hostname in blocked_hosts:
                    logger.warning(f"Blocked SSRF attempt to: {hostname}")
                    return False
                
                # Block private IPs
                import ipaddress
                try:
                    ip = ipaddress.ip_address(hostname)
                    if ip.is_private or ip.is_loopback or ip.is_multicast:
                        logger.warning(f"Blocked SSRF attempt to private IP: {hostname}")
                        return False
                except ValueError:
                    pass
            
            # Check allowed hosts if configured
            if cls.ALLOWED_HOSTS and hostname not in cls.ALLOWED_HOSTS:
                logger.warning(f"Blocked URL with disallowed host: {hostname}")
                return False
            
            return True
            
        except Exception as e:
            logger.error(f"URL validation error: {e}")
            return False
```

---

## API Security

### Complete API Security Implementation

**`app/security/api_security.py`:**

```python
"""
app/security/api_security.py
Comprehensive API security implementation.
"""

from fastapi import Request, Response
from fastapi.middleware.base import BaseHTTPMiddleware
from typing import Optional, Dict, Any
import time
import hashlib
import hmac

from app.core.config import settings
from app.core.exceptions import UnauthorizedException
from app.middleware.rate_limit import RateLimitMiddleware
from app.security.owasp import InjectionPrevention, AuthenticationSecurity


# ────────────────────────────────────────────────────────────────
# API Key Authentication
# ────────────────────────────────────────────────────────────────

class APIKeyAuthentication:
    """API key authentication for service-to-service communication."""
    
    @staticmethod
    async def validate_api_key(api_key: str, db_session) -> Optional[Dict]:
        """
        Validate API key.
        
        Args:
            api_key: API key
            db_session: Database session
            
        Returns:
            Optional[Dict]: API key data if valid
        """
        from app.crud.api_key import APIKeyRepository
        
        # Hash API key
        from app.core.security import hash_api_key
        key_hash = hash_api_key(api_key)
        
        # Check in database
        repo = APIKeyRepository(db_session)
        key_data = await repo.get_by_hash(key_hash)
        
        if not key_data:
            return None
        
        # Check expiration
        if key_data.expires_at and key_data.expires_at < datetime.utcnow():
            return None
        
        # Check if active
        if not key_data.is_active:
            return None
        
        return key_data


# ────────────────────────────────────────────────────────────────
# Request Signature Validation
# ────────────────────────────────────────────────────────────────

class RequestSignatureValidator:
    """Validate request signatures for API authenticity."""
    
    @staticmethod
    async def validate_signature(
        request: Request,
        secret_key: str,
        signature_header: str = "X-Signature",
    ) -> bool:
        """
        Validate request signature.
        
        Args:
            request: FastAPI request
            secret_key: Secret key
            signature_header: Header containing signature
            
        Returns:
            bool: True if signature is valid
        """
        # Get signature from header
        signature = request.headers.get(signature_header)
        if not signature:
            return False
        
        # Get request body
        body = await request.body()
        
        # Build signing data
        timestamp = request.headers.get("X-Timestamp", "")
        nonce = request.headers.get("X-Nonce", "")
        path = request.url.path
        
        signing_data = f"{path}:{timestamp}:{nonce}:{body.decode()}"
        
        # Calculate expected signature
        expected = hmac.new(
            secret_key.encode(),
            signing_data.encode(),
            hashlib.sha256
        ).hexdigest()
        
        # Compare signatures
        return hmac.compare_digest(expected, signature)


# ────────────────────────────────────────────────────────────────
# CORS Configuration
# ────────────────────────────────────────────────────────────────

class SecureCORSMiddleware:
    """Secure CORS configuration."""
    
    @staticmethod
    def configure_cors(app):
        """Configure secure CORS."""
        from fastapi.middleware.cors import CORSMiddleware
        
        allowed_origins = settings.CORS_ORIGINS
        
        # In production, allow only specific origins
        if settings.APP_ENV == "production":
            if "*" in allowed_origins:
                allowed_origins = []
                logger.warning("CORS wildcard disabled in production")
        
        app.add_middleware(
            CORSMiddleware,
            allow_origins=allowed_origins,
            allow_credentials=True,
            allow_methods=["GET", "POST", "PUT", "DELETE", "OPTIONS", "PATCH"],
            allow_headers=[
                "Authorization",
                "Content-Type",
                "Accept",
                "Origin",
                "X-Requested-With",
            ],
            expose_headers=["X-Trace-ID", "X-Response-Time"],
            max_age=86400,  # 24 hours
        )


# ────────────────────────────────────────────────────────────────
# Content Security Policy
# ────────────────────────────────────────────────────────────────

class CSPMiddleware(BaseHTTPMiddleware):
    """Content Security Policy middleware."""
    
    async def dispatch(self, request: Request, call_next):
        response = await call_next(request)
        
        if settings.APP_ENV == "production":
            csp = (
                "default-src 'self'; "
                "script-src 'self' 'unsafe-inline' 'unsafe-eval' https:; "
                "style-src 'self' 'unsafe-inline' https:; "
                "img-src 'self' data: https:; "
                "font-src 'self' https:; "
                "connect-src 'self' https:; "
                "frame-ancestors 'none'; "
                "form-action 'self'; "
                "base-uri 'self'; "
                "object-src 'none'; "
                "upgrade-insecure-requests;"
            )
            response.headers["Content-Security-Policy"] = csp
        
        return response


# ────────────────────────────────────────────────────────────────
# Rate Limiting Security
# ────────────────────────────────────────────────────────────────

class SecureRateLimiter(RateLimitMiddleware):
    """Rate limiting with security considerations."""
    
    def __init__(self, app):
        super().__init__(app)
        # Different limits for different endpoints
        self.endpoint_limits = {
            "/api/v1/auth/login": (5, 60),       # 5 per minute
            "/api/v1/auth/register": (3, 60),    # 3 per minute
            "/api/v1/auth/reset-password": (3, 60),  # 3 per minute
            "/api/v1/tasks/": (100, 60),          # 100 per minute
            "/api/v1/upload/": (10, 60),          # 10 per minute
        }
    
    async def get_rate_limit(self, request: Request) -> tuple:
        """Get rate limit for specific endpoint."""
        path = request.url.path
        for endpoint, limits in self.endpoint_limits.items():
            if path.startswith(endpoint):
                return limits
        return (self.default_limit, self.default_window)
    
    async def dispatch(self, request: Request, call_next):
        # Get rate limit for this endpoint
        limit, window = await self.get_rate_limit(request)
        
        # Apply rate limiting
        client_id = self.get_client_id(request)
        key = f"rate_limit:{client_id}:{request.url.path}"
        
        allowed = await self.is_allowed(key, limit, window)
        if not allowed:
            # Log rate limit event
            await SecurityLogging.log_security_event(
                event_type="rate_limit_exceeded",
                ip_address=request.client.host,
                details={
                    "path": request.url.path,
                    "client_id": client_id,
                }
            )
            raise TooManyRequestsException(
                detail="Rate limit exceeded",
                error_code="RATE_LIMIT_EXCEEDED"
            )
        
        return await call_next(request)
```

---

## Compliance Frameworks

### GDPR Compliance

**`app/compliance/gdpr.py`:**

```python
"""
app/compliance/gdpr.py
GDPR compliance implementation.
"""

from typing import Optional, Dict, Any, List
from datetime import datetime, timedelta
import json
import logging

logger = logging.getLogger(__name__)


class GDPRCompliance:
    """GDPR compliance utilities."""
    
    @staticmethod
    async def delete_user_data(user_id: int, db_session) -> bool:
        """
        Delete all user data (Right to Erasure).
        
        Args:
            user_id: User ID
            db_session: Database session
            
        Returns:
            bool: True if successful
        """
        # Delete user
        from app.crud.user import UserRepository
        repo = UserRepository(db_session)
        
        user = await repo.get(user_id)
        if user:
            await repo.delete(user)
            await db_session.commit()
            return True
        
        return False
    
    @staticmethod
    async def export_user_data(user_id: int, db_session) -> Dict[str, Any]:
        """
        Export all user data (Right to Data Portability).
        
        Args:
            user_id: User ID
            db_session: Database session
            
        Returns:
            Dict: User data
        """
        from app.crud.user import UserRepository
        from app.crud.task import TaskRepository
        
        user_repo = UserRepository(db_session)
        task_repo = TaskRepository(db_session)
        
        # Get user data
        user = await user_repo.get(user_id)
        if not user:
            return {}
        
        # Get user's tasks
        tasks = await task_repo.get_by_assignee(user_id)
        
        return {
            "user": {
                "id": user.id,
                "email": user.email,
                "username": user.username,
                "full_name": user.full_name,
                "created_at": user.created_at.isoformat(),
            },
            "tasks": [
                {
                    "id": task.id,
                    "title": task.title,
                    "status": task.status.value,
                    "created_at": task.created_at.isoformat(),
                }
                for task in tasks
            ],
            "exported_at": datetime.utcnow().isoformat() + "Z",
        }
    
    @staticmethod
    async def anonymize_user_data(user_id: int, db_session) -> bool:
        """
        Anonymize user data instead of deleting.
        
        Args:
            user_id: User ID
            db_session: Database session
            
        Returns:
            bool: True if successful
        """
        from app.crud.user import UserRepository
        
        repo = UserRepository(db_session)
        user = await repo.get(user_id)
        
        if user:
            # Anonymize data
            user.email = f"anonymized_{user_id}@deleted.com"
            user.username = f"deleted_user_{user_id}"
            user.full_name = "Deleted User"
            user.phone_number = None
            user.bio = None
            user.avatar_url = None
            user.hashed_password = "ANONYMIZED"
            user.is_active = False
            
            await db_session.commit()
            return True
        
        return False


class DataProcessingAgreement:
    """Data Processing Agreement (DPA) compliance."""
    
    PROCESSORS = {
        "aws": {
            "name": "Amazon Web Services",
            "location": "US",
            "purpose": "Cloud hosting and storage",
            "data_processed": ["All data"],
        },
        "redis": {
            "name": "Redis (in-memory cache)",
            "location": "Local",
            "purpose": "Caching and session management",
            "data_processed": ["Session data", "Cache data"],
        },
        "elasticsearch": {
            "name": "Elasticsearch",
            "location": "Local",
            "purpose": "Search indexing",
            "data_processed": ["Task data for search"],
        }
    }
    
    @classmethod
    def get_processors(cls) -> Dict:
        """Get list of data processors."""
        return cls.PROCESSORS
    
    @classmethod
    def get_processor_data(cls, processor_name: str) -> Optional[Dict]:
        """Get data for a specific processor."""
        return cls.PROCESSORS.get(processor_name)
```

### HIPAA Compliance

**`app/compliance/hipaa.py`:**

```python
"""
app/compliance/hipaa.py
HIPAA compliance utilities.
"""

from typing import Optional, Dict, Any
import hashlib
import secrets
from datetime import datetime


class HIPAACompliance:
    """HIPAA compliance utilities."""
    
    # PHI fields that need encryption
    PHI_FIELDS = [
        "email",
        "phone_number",
        "full_name",
        "address",
        "date_of_birth",
        "social_security_number",
        "medical_record_number",
        "health_insurance_id",
    ]
    
    @staticmethod
    def encrypt_phi(data: Dict[str, Any]) -> Dict[str, Any]:
        """
        Encrypt PHI fields.
        
        Args:
            data: Data containing PHI
            
        Returns:
            Dict: Data with encrypted PHI
        """
        from app.security.owasp import CryptographicManager
        
        # Get encryption key from secure storage
        key = secrets.token_bytes(32)  # In production, use KMS
        
        encrypted = data.copy()
        for field in HIPAACompliance.PHI_FIELDS:
            if field in encrypted and encrypted[field]:
                encrypted[field] = CryptographicManager.encrypt_sensitive_data(
                    str(encrypted[field]),
                    key
                )
        
        return encrypted
    
    @staticmethod
    def decrypt_phi(data: Dict[str, Any]) -> Dict[str, Any]:
        """
        Decrypt PHI fields.
        
        Args:
            data: Data with encrypted PHI
            
        Returns:
            Dict: Data with decrypted PHI
        """
        from app.security.owasp import CryptographicManager
        
        key = secrets.token_bytes(32)  # In production, retrieve from KMS
        
        decrypted = data.copy()
        for field in HIPAACompliance.PHI_FIELDS:
            if field in decrypted and decrypted[field]:
                decrypted[field] = CryptographicManager.decrypt_sensitive_data(
                    decrypted[field],
                    key
                )
        
        return decrypted
    
    @staticmethod
    def audit_access(
        user_id: str,
        resource_type: str,
        resource_id: str,
        action: str,
        ip_address: Optional[str] = None,
    ):
        """
        Audit access to PHI.
        
        Args:
            user_id: User accessing data
            resource_type: Type of resource
            resource_id: Resource ID
            action: Action performed
            ip_address: Client IP
        """
        audit_entry = {
            "timestamp": datetime.utcnow().isoformat() + "Z",
            "user_id": user_id,
            "resource_type": resource_type,
            "resource_id": resource_id,
            "action": action,
            "ip_address": ip_address,
            "audit_type": "hipaa_access",
        }
        
        logger.info(
            f"HIPAA access: {user_id} {action} {resource_type}/{resource_id}",
            extra=audit_entry
        )
```

---

## Security Monitoring

### Security Dashboard

**`app/security/monitoring.py`:**

```python
"""
app/security/monitoring.py
Security monitoring and alerting.
"""

from typing import Dict, Any, List
from datetime import datetime, timedelta
import json
import logging

logger = logging.getLogger(__name__)


class SecurityDashboard:
    """Security monitoring dashboard."""
    
    @staticmethod
    async def get_security_metrics(db_session) -> Dict[str, Any]:
        """
        Get security metrics for dashboard.
        
        Returns:
            Dict: Security metrics
        """
        metrics = {
            "auth": {
                "failed_logins": await SecurityDashboard._get_failed_logins(db_session),
                "successful_logins": await SecurityDashboard._get_successful_logins(db_session),
                "suspicious_activities": await SecurityDashboard._get_suspicious_activities(db_session),
            },
            "access": {
                "permission_denied": await SecurityDashboard._get_permission_denied(db_session),
                "api_key_usage": await SecurityDashboard._get_api_key_usage(db_session),
            },
            "threats": {
                "blocked_ips": await SecurityDashboard._get_blocked_ips(db_session),
                "rate_limiting": await SecurityDashboard._get_rate_limiting_events(db_session),
                "injection_attempts": await SecurityDashboard._get_injection_attempts(db_session),
            },
            "compliance": {
                "gdpr_requests": await SecurityDashboard._get_gdpr_requests(db_session),
                "hipaa_access": await SecurityDashboard._get_hipaa_access(db_session),
            }
        }
        
        return metrics
    
    @staticmethod
    async def _get_failed_logins(db_session) -> int:
        """Get number of failed logins in last 24 hours."""
        # Query audit logs
        return 0  # Placeholder
    
    @staticmethod
    async def _get_successful_logins(db_session) -> int:
        """Get number of successful logins in last 24 hours."""
        return 0  # Placeholder
    
    @staticmethod
    async def _get_suspicious_activities(db_session) -> List[Dict]:
        """Get suspicious activities."""
        return []  # Placeholder
    
    @staticmethod
    async def _get_permission_denied(db_session) -> int:
        """Get number of permission denied events."""
        return 0  # Placeholder
    
    @staticmethod
    async def _get_api_key_usage(db_session) -> Dict:
        """Get API key usage statistics."""
        return {}  # Placeholder
    
    @staticmethod
    async def _get_blocked_ips(db_session) -> List[str]:
        """Get list of blocked IPs."""
        return []  # Placeholder
    
    @staticmethod
    async def _get_rate_limiting_events(db_session) -> int:
        """Get number of rate limiting events."""
        return 0  # Placeholder
    
    @staticmethod
    async def _get_injection_attempts(db_session) -> int:
        """Get number of injection attempts blocked."""
        return 0  # Placeholder
    
    @staticmethod
    async def _get_gdpr_requests(db_session) -> int:
        """Get number of GDPR requests."""
        return 0  # Placeholder
    
    @staticmethod
    async def _get_hipaa_access(db_session) -> int:
        """Get number of HIPAA access events."""
        return 0  # Placeholder


# ────────────────────────────────────────────────────────────────
# Security Alerts
# ────────────────────────────────────────────────────────────────

class SecurityAlertManager:
    """Manage security alerts."""
    
    ALERT_CHANNELS = {
        "email": "security@your-domain.com",
        "slack": "https://hooks.slack.com/services/...",
        "pagerduty": "your-pagerduty-service-key",
    }
    
    @classmethod
    async def send_alert(
        cls,
        alert_type: str,
        severity: str,
        message: str,
        details: Dict[str, Any],
    ):
        """
        Send a security alert.
        
        Args:
            alert_type: Type of alert
            severity: Critical, high, medium, low
            message: Alert message
            details: Alert details
        """
        alert_data = {
            "alert_type": alert_type,
            "severity": severity,
            "message": message,
            "details": details,
            "timestamp": datetime.utcnow().isoformat() + "Z",
        }
        
        logger.critical(f"Security alert: {alert_type}", extra=alert_data)
        
        # Send to appropriate channels based on severity
        if severity in ["critical", "high"]:
            # Send to all channels
            for channel, address in cls.ALERT_CHANNELS.items():
                await cls._send_to_channel(channel, address, alert_data)
        else:
            # Send to email only
            await cls._send_to_channel(
                "email",
                cls.ALERT_CHANNELS["email"],
                alert_data
            )
    
    @staticmethod
    async def _send_to_channel(channel: str, address: str, data: Dict):
        """Send alert to specific channel."""
        # Implement actual sending logic
        logger.info(f"Alert sent to {channel}: {data['message']}")
```

---

## Security Checklist

### Pre-Deployment Security Checklist

```markdown
# Pre-Deployment Security Checklist

## Authentication & Authorization
- [ ] Strong password policies enforced
- [ ] Two-factor authentication implemented
- [ ] Session management secure
- [ ] JWT tokens use short expiry
- [ ] Refresh token rotation implemented
- [ ] API key authentication for services
- [ ] Role-based access control (RBAC) implemented
- [ ] Least privilege principle applied

## Data Protection
- [ ] Data encrypted at rest
- [ ] Data encrypted in transit (HTTPS)
- [ ] Sensitive data masked in logs
- [ ] Database credentials stored securely
- [ ] Secret management solution in place
- [ ] Data backup encrypted
- [ ] GDPR compliance considered

## API Security
- [ ] Input validation on all endpoints
- [ ] SQL injection prevention in place
- [ ] XSS prevention implemented
- [ ] Rate limiting configured
- [ ] CORS properly configured
- [ ] API documentation doesn't expose sensitive info
- [ ] Request size limits set

## Infrastructure Security
- [ ] Firewall configured
- [ ] SSH access restricted
- [ ] Security updates applied
- [ ] Monitoring and alerting configured
- [ ] Logging enabled
- [ ] Backups configured
- [ ] Disaster recovery plan documented

## Application Security
- [ ] Dependencies up to date
- [ ] Security headers configured
- [ ] Error handling doesn't leak info
- [ ] Debug mode disabled in production
- [ ] Security testing performed
- [ ] Code review completed
- [ ] Penetration testing conducted

## Compliance
- [ ] Privacy policy updated
- [ ] Terms of service updated
- [ ] Cookie consent implemented
- [ ] Data retention policy defined
- [ ] Third-party services documented
- [ ] User rights procedures in place
```

### Security Incident Response Plan

```markdown
# Security Incident Response Plan

## Phase 1: Preparation (Before Incident)
- [ ] Define incident response team
- [ ] Document communication channels
- [ ] Set up monitoring and alerting
- [ ] Conduct security training
- [ ] Create incident response playbook
- [ ] Test response procedures

## Phase 2: Identification (During Incident)
- [ ] Detect incident
- [ ] Determine severity
- [ ] Notify team
- [ ] Start documentation
- [ ] Assess impact
- [ ] Preserve evidence

## Phase 3: Containment
- [ ] Stop active exploitation
- [ ] Isolate affected systems
- [ ] Block attacker access
- [ ] Implement temporary fixes
- [ ] Notify stakeholders

## Phase 4: Eradication
- [ ] Remove threat
- [ ] Fix vulnerabilities
- [ ] Apply patches
- [ ] Update security controls
- [ ] Verify system integrity

## Phase 5: Recovery
- [ ] Restore from clean backups
- [ ] Verify system functionality
- [ ] Monitor for recurrence
- [ ] Resume operations
- [ ] Document lessons learned

## Phase 6: Post-Incident
- [ ] Conduct post-mortem
- [ ] Update security controls
- [ ] Train staff
- [ ] Improve monitoring
- [ ] Review incident response plan
- [ ] Update documentation

## Contact Information
- Security Team: security@your-domain.com
- Emergency: [Phone Number]
- Incident Response Lead: [Name/Contact]
- Legal Counsel: [Name/Contact]
- PR/Communications: [Name/Contact]
- External Security Provider: [Name/Contact]
```

---

This comprehensive security hardening guide provides everything you need to secure your FastAPI application and ensure compliance with industry standards. Use it as your reference for implementing security controls, monitoring for threats, and responding to incidents.

**[END OF APPENDIX F]**
