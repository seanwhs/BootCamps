# Part 20: API Security

## Securing Your Application with Best Practices

Welcome to **Part 20** of the Django REST Framework & Next.js 16 masterclass. This is the final part of Phase 3, where we'll implement comprehensive API security measures. We'll protect our application against common attacks and ensure data is transmitted and stored securely.

In this part, we'll:
- Implement rate limiting
- Configure CORS properly
- Add input validation and sanitization
- Implement security headers
- Protect against common vulnerabilities
- Set up environment-based security configurations

Think of this as building the **complete security system** for your application. Just as a bank has multiple layers of security (vaults, guards, cameras, alarms), your application needs multiple layers of security to protect user data.

---

## The Target

We'll implement comprehensive API security:

```
Security Layers:
┌─────────────────────────────────────────────────────────────────────┐
│                    Security Architecture                            │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  1. Network Layer                                                   │
│     ├── HTTPS (production)                                         │
│     ├── CORS Configuration                                         │
│     └── Rate Limiting                                              │
│                                                                     │
│  2. Application Layer                                               │
│     ├── JWT Authentication                                         │
│     ├── Permission Checks                                          │
│     ├── Input Validation                                           │
│     └── SQL Injection Protection                                   │
│                                                                     │
│  3. Data Layer                                                      │
│     ├── Encryption (passwords)                                     │
│     ├── Data Sanitization                                          │
│     └── Audit Logging                                              │
│                                                                     │
│  4. Infrastructure Layer                                            │
│     ├── Environment Variables                                      │
│     ├── Secure Headers                                             │
│     └── Error Handling                                             │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## The Concept

### Common Web Vulnerabilities

| Vulnerability | Description | Prevention |
|---------------|-------------|------------|
| **SQL Injection** | Malicious SQL queries | ORM, parameterized queries |
| **XSS** | Cross-site scripting | Output encoding, CSP |
| **CSRF** | Cross-site request forgery | CSRF tokens, SameSite cookies |
| **CORS** | Cross-origin resource sharing | Proper CORS configuration |
| **Rate Limiting** | Brute force attacks | Request throttling |
| **Data Exposure** | Sensitive data leaks | Proper serialization |

### Security Best Practices

1. **Defense in Depth**: Multiple layers of security
2. **Least Privilege**: Users get minimum necessary access
3. **Secure by Default**: Start secure, opt-in for less secure
4. **Validate Everything**: All input is untrusted
5. **Log Everything**: Monitor for suspicious activity
6. **Keep Secrets Secret**: Environment variables, not code

---

## The Implementation

### Step 1: Install Rate Limiting Package

```bash
cd backend
source venv/bin/activate
pip install django-ratelimit
echo "django-ratelimit>=4.1.0" >> requirements/base.txt
```

### Step 2: Configure Rate Limiting

**backend/config/settings.py** (add rate limiting settings)

```python
# Rate limiting settings
RATELIMIT_ENABLE = True
RATELIMIT_USE_CACHE = 'default'
RATELIMIT_VIEW = 'apps.api.views.rate_limit_exceeded'

# Rate limit configurations
RATELIMIT_GLOBAL = {
    'rate': '100/h',  # 100 requests per hour
    'method': ['GET', 'POST', 'PUT', 'PATCH', 'DELETE'],
}

# Specific rate limits for different endpoints
RATELIMIT_AUTH = {
    'rate': '10/m',  # 10 requests per minute for auth endpoints
    'method': ['POST'],
}

RATELIMIT_API = {
    'rate': '1000/h',  # 1000 requests per hour for general API
    'method': ['GET', 'POST', 'PUT', 'PATCH', 'DELETE'],
}
```

### Step 3: Create Rate Limiting Decorators

**backend/apps/api/decorators.py** (create)

```python
"""
Rate limiting decorators for API views.
"""

from functools import wraps
from django.core.cache import cache
from django.http import JsonResponse
from django.utils.timezone import now
from django.conf import settings


def rate_limit(rate='100/h', key_prefix='api'):
    """
    Rate limiting decorator.
    Rate format: '10/m' = 10 requests per minute, '100/h' = 100 per hour
    """
    def decorator(view_func):
        @wraps(view_func)
        def wrapped_view(request, *args, **kwargs):
            # Skip rate limiting if disabled
            if not getattr(settings, 'RATELIMIT_ENABLE', True):
                return view_func(request, *args, **kwargs)
            
            # Get client identifier (IP address)
            client_ip = get_client_ip(request)
            
            # Create cache key
            cache_key = f'ratelimit:{key_prefix}:{client_ip}'
            
            # Get current count
            current_count = cache.get(cache_key, 0)
            
            # Parse rate
            count, period = parse_rate(rate)
            
            # Check if limit exceeded
            if current_count >= count:
                return JsonResponse(
                    {
                        'detail': f'Rate limit exceeded. Please try again later.',
                        'limit': count,
                        'period': period,
                    },
                    status=429
                )
            
            # Increment count
            cache.set(cache_key, current_count + 1, timeout=period)
            
            return view_func(request, *args, **kwargs)
        return wrapped_view
    return decorator


def get_client_ip(request):
    """
    Get client IP address from request.
    """
    x_forwarded_for = request.META.get('HTTP_X_FORWARDED_FOR')
    if x_forwarded_for:
        ip = x_forwarded_for.split(',')[0]
    else:
        ip = request.META.get('REMOTE_ADDR')
    return ip


def parse_rate(rate):
    """
    Parse rate string like '10/m' or '100/h'.
    Returns (count, seconds)
    """
    count_str, period_char = rate.split('/')
    count = int(count_str)
    
    period_map = {
        's': 1,
        'm': 60,
        'h': 3600,
        'd': 86400,
    }
    
    period = period_map.get(period_char, 60)
    return count, period
```

### Step 4: Apply Rate Limiting to Views

**backend/apps/api/views.py** (create)

```python
"""
API views with rate limiting.
"""

from django.http import JsonResponse
from rest_framework import status
from rest_framework.decorators import api_view
from rest_framework.response import Response
from .decorators import rate_limit


def rate_limit_exceeded(request, exception):
    """
    View for rate limit exceeded response.
    """
    return JsonResponse(
        {
            'detail': 'Rate limit exceeded. Please try again later.',
            'error': 'RATE_LIMIT_EXCEEDED',
        },
        status=429
    )


@api_view(['POST'])
@rate_limit('10/m', 'auth_login')
def login_rate_limited(request):
    """
    Login view with rate limiting.
    """
    # This is a wrapper that applies rate limiting to the login view
    # The actual login logic is in the token view
    pass


@api_view(['POST'])
@rate_limit('5/m', 'auth_register')
def register_rate_limited(request):
    """
    Registration view with rate limiting.
    """
    pass
```

### Step 5: Update Authentication Views with Rate Limiting

**backend/apps/api/urls.py** (update with rate limiting)

```python
"""
API v1 URL configuration.
"""

from rest_framework.routers import DefaultRouter
from django.urls import path, include
from rest_framework_simplejwt.views import (
    TokenObtainPairView,
    TokenRefreshView,
    TokenVerifyView,
)

from apps.users.views import UserViewSet
from apps.projects.views import ProjectViewSet
from apps.tasks.views import TaskViewSet
from apps.comments.views import CommentViewSet
from .decorators import rate_limit

# Create a root router
router = DefaultRouter()

# Register all ViewSets
router.register(r'users', UserViewSet, basename='user')
router.register(r'projects', ProjectViewSet, basename='project')
router.register(r'tasks', TaskViewSet, basename='task')
router.register(r'comments', CommentViewSet, basename='comment')

# Wrapped token views with rate limiting
class RateLimitedTokenObtainPairView(TokenObtainPairView):
    @rate_limit('10/m', 'auth_token')
    def post(self, request, *args, **kwargs):
        return super().post(request, *args, **kwargs)

# Authentication URLs with rate limiting
auth_urls = [
    path('token/', RateLimitedTokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('token/verify/', TokenVerifyView.as_view(), name='token_verify'),
]

urlpatterns = [
    path('', include(auth_urls)),
    path('', include(router.urls)),
]
```

### Step 6: Update CORS Settings

**backend/config/settings.py** (update CORS)

```python
# CORS settings
CORS_ALLOWED_ORIGINS = [
    "http://localhost:3000",  # Next.js development
    "http://127.0.0.1:3000",
    # Add production domains
    # "https://yourdomain.com",
]

# Allow credentials (cookies, authorization headers)
CORS_ALLOW_CREDENTIALS = True

# Allow methods
CORS_ALLOW_METHODS = [
    'DELETE',
    'GET',
    'OPTIONS',
    'PATCH',
    'POST',
    'PUT',
]

# Allow headers
CORS_ALLOW_HEADERS = [
    'accept',
    'accept-encoding',
    'authorization',
    'content-type',
    'dnt',
    'origin',
    'user-agent',
    'x-csrftoken',
    'x-requested-with',
    'x-request-id',
]

# Preflight max age (cache CORS preflight response)
CORS_PREFLIGHT_MAX_AGE = 86400  # 24 hours

# If you need to allow subdomains:
# CORS_ALLOWED_ORIGIN_REGEXES = [
#     r"^https://\w+\.yourdomain\.com$",
# ]
```

### Step 7: Add Security Middleware

**backend/config/settings.py** (update middleware)

```python
# Security Middleware settings
SECURE_BROWSER_XSS_FILTER = True
SECURE_CONTENT_TYPE_NOSNIFF = True
SECURE_HSTS_SECONDS = 31536000  # 1 year, set to 0 in development
SECURE_HSTS_INCLUDE_SUBDOMAINS = True
SECURE_HSTS_PRELOAD = True
SECURE_SSL_REDIRECT = False  # Set to True in production with HTTPS
SESSION_COOKIE_SECURE = True  # Set to True in production with HTTPS
CSRF_COOKIE_SECURE = True  # Set to True in production with HTTPS
SESSION_COOKIE_HTTPONLY = True
CSRF_COOKIE_HTTPONLY = True
SESSION_COOKIE_SAMESITE = 'Lax'

# Security headers middleware (add to MIDDLEWARE list)
# 'django.middleware.security.SecurityMiddleware' should be first

MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'corsheaders.middleware.CorsMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
    # Custom security middleware
    'apps.api.middleware.SecurityHeadersMiddleware',
]
```

### Step 8: Create Custom Security Middleware

**backend/apps/api/middleware.py** (create)

```python
"""
Custom security middleware for additional security headers.
"""

from django.utils.deprecation import MiddlewareMixin
from django.http import JsonResponse
import re


class SecurityHeadersMiddleware(MiddlewareMixin):
    """
    Add additional security headers to responses.
    """
    
    def process_response(self, request, response):
        # Security headers
        response['X-Content-Type-Options'] = 'nosniff'
        response['X-Frame-Options'] = 'DENY'
        response['X-XSS-Protection'] = '1; mode=block'
        response['Referrer-Policy'] = 'strict-origin-when-cross-origin'
        response['Permissions-Policy'] = 'geolocation=(), microphone=(), camera=()'
        
        # Content Security Policy (adjust based on your needs)
        csp = [
            "default-src 'self'",
            "img-src 'self' data:",
            "style-src 'self' 'unsafe-inline'",
            "script-src 'self' 'unsafe-inline' 'unsafe-eval'",
            "font-src 'self'",
            "connect-src 'self'",
        ]
        response['Content-Security-Policy'] = '; '.join(csp)
        
        return response


class RequestLoggingMiddleware(MiddlewareMixin):
    """
    Log API requests for auditing.
    """
    
    def process_request(self, request):
        # Skip logging for health checks and static files
        if request.path.startswith('/health/') or request.path.startswith('/static/'):
            return
        
        # Log request
        import logging
        logger = logging.getLogger('api')
        logger.info(
            f"API Request: {request.method} {request.path} "
            f"from {self.get_client_ip(request)}"
        )
    
    def get_client_ip(self, request):
        x_forwarded_for = request.META.get('HTTP_X_FORWARDED_FOR')
        if x_forwarded_for:
            ip = x_forwarded_for.split(',')[0]
        else:
            ip = request.META.get('REMOTE_ADDR')
        return ip


class SQLInjectionProtectionMiddleware(MiddlewareMixin):
    """
    Basic SQL injection protection for query parameters.
    """
    
    SQL_PATTERNS = [
        r'\bSELECT\b.*?\bFROM\b',
        r'\bINSERT\b.*?\bINTO\b',
        r'\bUPDATE\b.*?\bSET\b',
        r'\bDELETE\b.*?\bFROM\b',
        r'\bDROP\b.*?\bTABLE\b',
        r'\bUNION\b.*?\bSELECT\b',
        r'\b--',
        r'\b;\s*DROP\b',
        r'\bOR\s+1=1\b',
    ]
    
    def process_request(self, request):
        # Check query parameters
        for key, value in request.GET.items():
            if self.is_suspicious(value):
                return JsonResponse(
                    {'detail': 'Suspicious input detected.'},
                    status=400
                )
        
        # Check POST data
        if request.method in ['POST', 'PUT', 'PATCH']:
            for key, value in request.POST.items():
                if self.is_suspicious(value):
                    return JsonResponse(
                        {'detail': 'Suspicious input detected.'},
                        status=400
                    )
    
    def is_suspicious(self, value):
        if not isinstance(value, str):
            return False
        
        for pattern in self.SQL_PATTERNS:
            if re.search(pattern, value, re.IGNORECASE):
                return True
        return False
```

### Step 9: Update Frontend with Security Headers

**frontend/next.config.js** (update)

```javascript
/** @type {import('next').NextConfig} */
const nextConfig = {
  images: {
    domains: ['localhost'],
    remotePatterns: [
      {
        protocol: 'http',
        hostname: 'localhost',
        port: '8000',
        pathname: '/media/**',
      },
    ],
  },
  async rewrites() {
    return [
      {
        source: '/api/:path*',
        destination: `${process.env.NEXT_PUBLIC_API_URL}/:path*`,
      },
    ];
  },
  // Security headers
  async headers() {
    return [
      {
        source: '/(.*)',
        headers: [
          {
            key: 'X-Content-Type-Options',
            value: 'nosniff',
          },
          {
            key: 'X-Frame-Options',
            value: 'DENY',
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
            key: 'Content-Security-Policy',
            value: "default-src 'self'; img-src 'self' data: https:; style-src 'self' 'unsafe-inline'; script-src 'self' 'unsafe-inline' 'unsafe-eval'; font-src 'self' data:; connect-src 'self' http://localhost:8000 https://api.example.com;",
          },
        ],
      },
    ];
  },
};

module.exports = nextConfig;
```

### Step 10: Add Environment-Based Security Configuration

**backend/config/settings.py** (add environment-specific settings)

```python
# Security settings based on environment
if env('DEBUG', default=False):
    # Development settings
    SECURE_SSL_REDIRECT = False
    SESSION_COOKIE_SECURE = False
    CSRF_COOKIE_SECURE = False
    CORS_ALLOW_ALL_ORIGINS = True
else:
    # Production settings
    SECURE_SSL_REDIRECT = True
    SESSION_COOKIE_SECURE = True
    CSRF_COOKIE_SECURE = True
    SECURE_HSTS_SECONDS = 31536000  # 1 year
    SECURE_HSTS_INCLUDE_SUBDOMAINS = True
    SECURE_HSTS_PRELOAD = True
    CORS_ALLOW_ALL_ORIGINS = False
```

---

## The Verification

### Step 1: Start the Servers

```bash
# Terminal 1 - Backend
cd backend
source venv/bin/activate
python manage.py runserver

# Terminal 2 - Frontend
cd frontend
npm run dev
```

### Step 2: Test Rate Limiting

```bash
# Make many requests in quick succession
for i in {1..15}; do
  curl -X POST http://localhost:8000/api/v1/token/ \
    -H "Content-Type: application/json" \
    -d '{"email": "test@example.com", "password": "wrong"}' &
done

# Wait for responses
# After 10 requests, you should see 429 Too Many Requests
```

### Step 3: Test CORS Configuration

```bash
# OPTIONS request (preflight)
curl -X OPTIONS http://localhost:8000/api/v1/tasks/ \
  -H "Origin: http://localhost:3000" \
  -H "Access-Control-Request-Method: POST" \
  -v

# Should return CORS headers
```

### Step 4: Test Security Headers

```bash
# Check security headers
curl -I http://localhost:8000/api/v1/tasks/

# Should include:
# X-Content-Type-Options: nosniff
# X-Frame-Options: DENY
# X-XSS-Protection: 1; mode=block
# Content-Security-Policy: ...
```

### Step 5: Test SQL Injection Protection

```bash
# Test with suspicious input
curl -X GET "http://localhost:8000/api/v1/tasks/?search=SELECT%20*%20FROM%20users"

# Should return 400 Bad Request
```

---

## Key Takeaways

1. **Rate limiting** prevents abuse and brute force attacks.

2. **CORS configuration** controls which domains can access your API.

3. **Security headers** protect against common web vulnerabilities.

4. **Input validation** prevents injection attacks.

5. **Environment-specific configuration** ensures security in production.

6. **Multiple layers of security** provide defense in depth.

---

## Phase 3 Complete!

You've now completed Phase 3! You've built:

✅ JWT authentication with SimpleJWT
✅ User registration and login
✅ Role-based permissions
✅ Custom permission classes
✅ Object-level permissions
✅ Next.js authentication
✅ Request interception
✅ API security (rate limiting, CORS, headers)

In **Phase 4**, we'll move to production:
- Testing
- Documentation
- Performance optimization
- Docker and deployment
- CI/CD

---

**End of Part 20**

*Next: Phase 4 - Performance, Testing, Documentation & Production*
