# Appendix I: Security Best Practices

## Comprehensive Security Reference Guide

Welcome to **Appendix I** of the Django REST Framework & Next.js 16 masterclass. This appendix provides a comprehensive reference for security best practices, covering everything from application security to infrastructure hardening.

---

## Section 1: Django Security Best Practices

### 1.1 Core Security Settings

```python
# settings.py - MUST be set in production
DEBUG = False
SECRET_KEY = os.environ.get('SECRET_KEY')  # NOT in code
ALLOWED_HOSTS = ['yourdomain.com', 'www.yourdomain.com']

# Security middleware
MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    # ... other middleware
]

# Security headers
SECURE_BROWSER_XSS_FILTER = True
SECURE_CONTENT_TYPE_NOSNIFF = True
SECURE_HSTS_SECONDS = 31536000  # 1 year
SECURE_HSTS_INCLUDE_SUBDOMAINS = True
SECURE_HSTS_PRELOAD = True
SECURE_SSL_REDIRECT = True
SESSION_COOKIE_SECURE = True
CSRF_COOKIE_SECURE = True
SESSION_COOKIE_HTTPONLY = True
CSRF_COOKIE_HTTPONLY = True
SESSION_COOKIE_SAMESITE = 'Lax'
CSRF_COOKIE_SAMESITE = 'Lax'

# Password validation (strong passwords)
AUTH_PASSWORD_VALIDATORS = [
    {
        'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator',
        'OPTIONS': {
            'min_length': 12,
        },
    },
    {
        'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator',
    },
]

# Password hashing (bcrypt recommended)
PASSWORD_HASHERS = [
    'django.contrib.auth.hashers.BCryptSHA256PasswordHasher',
    'django.contrib.auth.hashers.BCryptPasswordHasher',
    'django.contrib.auth.hashers.PBKDF2PasswordHasher',
]
```

### 1.2 Protecting Against Common Vulnerabilities

**Cross-Site Scripting (XSS):**
```python
# Always escape output (Django does this automatically in templates)
# {{ variable }} is auto-escaped
# Use safe only when absolutely necessary

# For JSON responses, ensure proper encoding
from django.utils.html import escape, mark_safe
from django.core.serializers.json import DjangoJSONEncoder

# Sanitize user input
from django.utils.html import strip_tags

def sanitize_input(text):
    return strip_tags(text)  # Remove HTML tags
```

**Cross-Site Request Forgery (CSRF):**
```python
# Enable CSRF middleware (default)
MIDDLEWARE = [
    'django.middleware.csrf.CsrfViewMiddleware',
]

# For API endpoints using JWT, CSRF may not be needed
# But ensure you're using safe methods for destructive operations

# In templates, use {% csrf_token %}
<form method="post">
    {% csrf_token %}
    <!-- form fields -->
</form>
```

**SQL Injection:**
```python
# Django ORM automatically escapes parameters
# NEVER use raw SQL with string interpolation
# ❌ Bad
User.objects.raw(f"SELECT * FROM users_user WHERE id = {user_id}")

# ✅ Good
User.objects.raw("SELECT * FROM users_user WHERE id = %s", [user_id])

# ✅ Best - use ORM
User.objects.get(id=user_id)
```

### 1.3 Django Security Middleware

```python
# Custom security middleware
class SecurityHeadersMiddleware:
    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        response = self.get_response(request)
        
        # Add security headers
        response['X-Frame-Options'] = 'DENY'
        response['X-Content-Type-Options'] = 'nosniff'
        response['X-XSS-Protection'] = '1; mode=block'
        response['Referrer-Policy'] = 'strict-origin-when-cross-origin'
        response['Permissions-Policy'] = 'geolocation=(), microphone=(), camera=()'
        
        return response
```

### 1.4 API Security

```python
# Rate limiting (using django-ratelimit)
from django_ratelimit.decorators import ratelimit

@ratelimit(key='ip', rate='10/m')
def login_view(request):
    # Limited to 10 requests per minute per IP
    pass

@ratelimit(key='user', rate='100/h')
def api_view(request):
    # Limited to 100 requests per hour per user
    pass

# Input validation
from rest_framework import serializers

class TaskSerializer(serializers.ModelSerializer):
    def validate_title(self, value):
        if len(value) < 3:
            raise serializers.ValidationError("Title too short")
        return value

    def validate(self, data):
        if data.get('due_date') and data['due_date'] < timezone.now():
            raise serializers.ValidationError("Due date must be in future")
        return data
```

---

## Section 2: JWT Security Best Practices

### 2.1 JWT Configuration

```python
# settings.py
from datetime import timedelta

SIMPLE_JWT = {
    'ACCESS_TOKEN_LIFETIME': timedelta(minutes=15),  # Short-lived
    'REFRESH_TOKEN_LIFETIME': timedelta(days=7),
    'ROTATE_REFRESH_TOKENS': True,  # New refresh token on each refresh
    'BLACKLIST_AFTER_ROTATION': True,  # Invalidate old refresh tokens
    'UPDATE_LAST_LOGIN': True,
    'ALGORITHM': 'HS256',
    'SIGNING_KEY': SECRET_KEY,  # Use strong key
    'AUTH_HEADER_TYPES': ('Bearer',),
    'USER_ID_FIELD': 'id',
    'USER_ID_CLAIM': 'user_id',
    'AUTH_TOKEN_CLASSES': ('rest_framework_simplejwt.tokens.AccessToken',),
}
```

### 2.2 Token Management

```python
# Secure token storage
# ❌ Bad: Store in localStorage
localStorage.setItem('token', token);

# ✅ Better: Store in memory (React state)
// In React
const [token, setToken] = useState(null);

# ✅ Best: HTTP-only cookies (recommended)
# Set in Django backend
response.set_cookie(
    'access_token',
    access_token,
    httponly=True,
    secure=True,
    samesite='Lax',
    max_age=900  # 15 minutes
)

# Automatic token refresh (frontend)
function refreshToken() {
    const refresh = getRefreshToken();
    if (!refresh) return Promise.reject('No refresh token');

    return fetch('/api/v1/token/refresh/', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ refresh }),
    })
    .then(res => res.json())
    .then(data => {
        setAccessToken(data.access);
        return data.access;
    });
}
```

### 2.3 Token Revocation

```python
from rest_framework_simplejwt.token_blacklist.models import BlacklistedToken
from rest_framework_simplejwt.tokens import RefreshToken

def revoke_user_tokens(user):
    """Revoke all tokens for a user."""
    from rest_framework_simplejwt.models import OutstandingToken
    tokens = OutstandingToken.objects.filter(user=user)
    for token in tokens:
        BlacklistedToken.objects.get_or_create(token=token)

def revoke_specific_token(refresh_token):
    """Revoke a specific refresh token."""
    try:
        token = RefreshToken(refresh_token)
        token.blacklist()
        return True
    except:
        return False
```

### 2.4 Logout & Token Blacklisting

```python
@api_view(['POST'])
def logout(request):
    """Logout user by blacklisting refresh token."""
    try:
        refresh_token = request.data.get('refresh')
        if refresh_token:
            token = RefreshToken(refresh_token)
            token.blacklist()
        
        # Clear cookies
        response = Response({'detail': 'Logged out successfully'})
        response.delete_cookie('access_token')
        response.delete_cookie('refresh_token')
        return response
        
    except Exception as e:
        return Response(
            {'detail': 'Invalid token'},
            status=status.HTTP_400_BAD_REQUEST
        )
```

---

## Section 3: Next.js Security Best Practices

### 3.1 Environment Variables

```javascript
// next.config.js
/** @type {import('next').NextConfig} */
module.exports = {
    // Public env vars (exposed to browser)
    env: {
        NEXT_PUBLIC_API_URL: process.env.NEXT_PUBLIC_API_URL,
    },
    // Private env vars (server only)
    // Use process.env directly in server components
}

// .env.local
NEXT_PUBLIC_API_URL=https://api.example.com
SECRET_KEY=server-only-variable
```

### 3.2 Security Headers (Next.js)

```javascript
// next.config.js
module.exports = {
    async headers() {
        return [
            {
                source: '/:path*',
                headers: [
                    {
                        key: 'X-Frame-Options',
                        value: 'DENY',
                    },
                    {
                        key: 'X-Content-Type-Options',
                        value: 'nosniff',
                    },
                    {
                        key: 'X-XSS-Protection',
                        value: '1; mode=block',
                    },
                    {
                        key: 'Referrer-Policy',
                        value: 'strict-origin-when-cross-origin',
                    },
                    {
                        key: 'Permissions-Policy',
                        value: 'geolocation=(), microphone=(), camera=()',
                    },
                    {
                        key: 'Content-Security-Policy',
                        value: "default-src 'self'; " +
                                "img-src 'self' data: https:; " +
                                "style-src 'self' 'unsafe-inline'; " +
                                "script-src 'self' 'unsafe-inline' 'unsafe-eval'; " +
                                "font-src 'self' data:; " +
                                "connect-src 'self' https://api.example.com;",
                    },
                ],
            },
        ];
    },
};
```

### 3.3 CSRF Protection in Next.js

```javascript
// CSRF token handling
// 1. Get token from cookie
function getCsrfToken() {
    const name = 'csrf_token=';
    const cookies = document.cookie.split(';');
    for (let cookie of cookies) {
        cookie = cookie.trim();
        if (cookie.startsWith(name)) {
            return cookie.substring(name.length);
        }
    }
    return null;
}

// 2. Include in requests
const csrfToken = getCsrfToken();
fetch('/api/action', {
    method: 'POST',
    headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': csrfToken,
    },
    body: JSON.stringify(data),
});
```

### 3.4 Route Protection (Middleware)

```javascript
// middleware.ts
import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';

export function middleware(request: NextRequest) {
    const token = request.cookies.get('access_token');
    const isAuthenticated = !!token;

    // Protected routes
    const protectedPaths = ['/dashboard', '/projects', '/tasks'];
    const isProtected = protectedPaths.some(path => 
        request.nextUrl.pathname.startsWith(path)
    );

    // Auth pages
    const authPaths = ['/login', '/register'];
    const isAuthPage = authPaths.some(path => 
        request.nextUrl.pathname.startsWith(path)
    );

    if (isProtected && !isAuthenticated) {
        return NextResponse.redirect(new URL('/login', request.url));
    }

    if (isAuthPage && isAuthenticated) {
        return NextResponse.redirect(new URL('/dashboard', request.url));
    }

    return NextResponse.next();
}

export const config = {
    matcher: ['/((?!_next/static|_next/image|favicon.ico|public).*)'],
};
```

---

## Section 4: Docker Security Best Practices

### 4.1 Dockerfile Security

```dockerfile
# Use specific base image tag (not latest)
FROM python:3.12-slim

# Run as non-root user
RUN addgroup --system --gid 1001 appuser && \
    adduser --system --uid 1001 --gid 1001 appuser

# Set secure file permissions
RUN chown -R appuser:appuser /app

# Copy with proper permissions
COPY --chown=appuser:appuser . .

# Switch to non-root user
USER appuser

# Use read-only filesystem when possible
RUN chmod -R 444 /app
RUN chmod 755 /app/static /app/media

# Don't expose unnecessary ports
EXPOSE 8000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD curl -f http://localhost:8000/health/ || exit 1
```

### 4.2 Docker Compose Security

```yaml
services:
  backend:
    # Resource limits
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 2G
    # Read-only root filesystem
    read_only: true
    # Drop unnecessary capabilities
    cap_drop:
      - ALL
    cap_add:
      - NET_BIND_SERVICE
    # Security options
    security_opt:
      - no-new-privileges:true
    # Use secrets for sensitive data
    secrets:
      - db_password
      - secret_key
    # Never run as root
    user: "1001:1001"

secrets:
  db_password:
    file: ./secrets/db_password.txt
  secret_key:
    file: ./secrets/secret_key.txt
```

---

## Section 5: Database Security

### 5.1 PostgreSQL Security

```sql
-- Create user with limited privileges
CREATE USER app_user WITH PASSWORD 'strong_password';
GRANT CONNECT ON DATABASE app_db TO app_user;
GRANT USAGE ON SCHEMA public TO app_user;

-- Grant minimal required permissions
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO app_user;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO app_user;

-- Row-level security
CREATE POLICY user_data_policy ON tasks_task
    USING (created_by = current_user)
    WITH CHECK (created_by = current_user);

ALTER TABLE tasks_task ENABLE ROW LEVEL SECURITY;

-- Audit triggers
CREATE OR REPLACE FUNCTION audit_trigger()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO audit_log (table_name, action, user_id, data)
    VALUES (TG_TABLE_NAME, TG_OP, current_user, row_to_json(NEW));
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tasks_audit_trigger
    AFTER INSERT OR UPDATE OR DELETE ON tasks_task
    FOR EACH ROW EXECUTE FUNCTION audit_trigger();
```

### 5.2 Redis Security

```bash
# Set password
CONFIG SET requirepass "strong_redis_password"

# Bind to localhost or specific IP
CONFIG SET bind "127.0.0.1"

# Disable dangerous commands
CONFIG SET rename-command CONFIG ""
CONFIG SET rename-command FLUSHALL ""
CONFIG SET rename-command FLUSHDB ""
CONFIG SET rename-command KEYS ""

# Set memory limit
CONFIG SET maxmemory 1GB
CONFIG SET maxmemory-policy allkeys-lru

# Protect against attacks
CONFIG SET protected-mode yes
```

---

## Section 6: Cloud Security Best Practices

### 6.1 AWS Security

```bash
# IAM Best Practices
# 1. Use IAM roles, not access keys
# 2. Principle of least privilege
# 3. Enable MFA
# 4. Use AWS Organizations

# S3 Security
# 1. Enable server-side encryption
aws s3api put-bucket-encryption \
    --bucket my-bucket \
    --server-side-encryption-configuration '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'

# 2. Block public access
aws s3api put-public-access-block \
    --bucket my-bucket \
    --public-access-block-configuration "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"

# 3. Enable versioning
aws s3api put-bucket-versioning --bucket my-bucket --versioning-configuration Status=Enabled

# RDS Security
# 1. Enable encryption at rest
# 2. Use VPC security groups
# 3. Enable automated backups
# 4. Enable deletion protection
# 5. Use SSL/TLS for connections
```

### 6.2 SSL/TLS Configuration

```nginx
# Nginx SSL configuration
server {
    listen 443 ssl http2;
    server_name example.com;

    # SSL certificates
    ssl_certificate /etc/nginx/ssl/cert.pem;
    ssl_certificate_key /etc/nginx/ssl/key.pem;

    # SSL settings
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;

    # HSTS
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
}
```

---

## Section 7: Security Checklist

### Pre-Deployment Checklist

- [ ] All environment variables are set securely
- [ ] Secret key is not in code (environment variable)
- [ ] DEBUG=False in production
- [ ] ALLOWED_HOSTS configured
- [ ] CORS allowed origins restricted
- [ ] HTTPS/SSL is enabled
- [ ] Security headers are configured
- [ ] CSRF protection is enabled
- [ ] XSS protection is enabled
- [ ] SQL injection protection (ORM)
- [ ] Rate limiting is configured
- [ ] JWT tokens are short-lived (15-60 minutes)
- [ ] Refresh token rotation is enabled
- [ ] Logout invalidates tokens
- [ ] Database passwords are strong
- [ ] Redis has password protection
- [ ] Docker runs as non-root user
- [ ] Container permissions are minimal
- [ ] Audit logging is enabled
- [ ] Dependency scanning is running
- [ ] Vulnerability scanning is configured

### Ongoing Security Practices

- [ ] Regular dependency updates
- [ ] Security patches applied promptly
- [ ] Regular penetration testing
- [ ] Security incident response plan
- [ ] Access review quarterly
- [ ] Log monitoring and alerting
- [ ] Security training for team
- [ ] Code review for security issues
- [ ] Automated security scanning in CI/CD

---

## Quick Reference Cards

### Security Headers

| Header | Value | Purpose |
|--------|-------|---------|
| Strict-Transport-Security | max-age=31536000 | Enforce HTTPS |
| X-Frame-Options | DENY | Prevent clickjacking |
| X-Content-Type-Options | nosniff | Prevent MIME sniffing |
| X-XSS-Protection | 1; mode=block | XSS protection |
| Content-Security-Policy | default-src 'self' | Resource restrictions |
| Referrer-Policy | strict-origin-when-cross-origin | Referrer control |
| Permissions-Policy | geolocation=() | Feature restrictions |

### Security Scanner Tools

| Tool | Purpose |
|------|---------|
| Safety | Python dependencies |
| npm audit | Node dependencies |
| Bandit | Python code security |
| Snyk | Vulnerability scanning |
| OWASP ZAP | Web application scanning |
| Trivy | Container scanning |
| Clair | Container scanning |
| SonarQube | Code quality & security |

---

*This concludes Appendix I. Use this security reference to build and maintain secure applications.*
