# Part 30: Production Configuration

## Preparing Your Application for the Real World

Welcome to **Part 30** of the Django REST Framework & Next.js 16 masterclass. Now that we have our complete Docker Compose setup, it's time to configure everything for production. We'll optimize settings, implement security measures, set up logging, and prepare for deployment.

In this part, we'll:
- Create production-specific Django settings
- Configure secure cookies and sessions
- Set up structured logging
- Implement performance optimizations
- Configure environment-specific settings
- Prepare for SSL/HTTPS

Think of this as the **final inspection** before your application goes live. Just as a building undergoes a final inspection before occupancy, your application needs one last review before serving real users.

---

## The Target

We'll create production-ready configurations:

```
backend/
├── config/
│   └── settings/
│       ├── __init__.py
│       ├── base.py              # Shared settings
│       ├── development.py       # Development overrides
│       └── production.py        # Production settings
├── logs/                        # Log directory
│   ├── app.log
│   ├── api.log
│   └── security.log
└── .env.production              # Production environment variables
```

---

## The Concept

### Production vs Development

| Aspect | Development | Production |
|--------|-------------|------------|
| **Debug** | True | False |
| **SECRET_KEY** | Hardcoded | Environment variable |
| **Database** | SQLite/Dev PostgreSQL | Production PostgreSQL |
| **Static Files** | Served by Django | Served by Nginx/CDN |
| **Logging** | Console, DEBUG level | File, INFO/WARNING level |
| **CORS** | All origins allowed | Restricted origins |
| **HTTPS** | Not enforced | Enforced |
| **Performance** | Not optimized | Optimized |

### Security Checklist

1. **Secret Key**: Use environment variable, not in code
2. **Debug**: Must be False in production
3. **Allowed Hosts**: Restrict to your domains
4. **CORS**: Restrict to your frontend domains
5. **HTTPS**: Enforce secure connections
6. **Cookies**: Secure and HTTP-only
7. **Rate Limiting**: Enabled
8. **Sensitive Data**: Not logged

---

## The Implementation

### Step 1: Restructure Django Settings

**backend/config/settings/__init__.py** (create)

```python
"""
Settings module for the backend project.
"""

import os
from split_settings.tools import include

# Determine environment
ENVIRONMENT = os.environ.get('DJANGO_ENV', 'development')

# Include base settings
include(
    'base.py',
)

# Include environment-specific settings
if ENVIRONMENT == 'production':
    include('production.py')
elif ENVIRONMENT == 'development':
    include('development.py')
```

**backend/config/settings/base.py** (create)

```python
"""
Base settings shared across all environments.
"""

import os
from pathlib import Path
import environ
from datetime import timedelta

# Build paths inside the project
BASE_DIR = Path(__file__).resolve().parent.parent.parent

# Initialize environment
env = environ.Env()
environ.Env.read_env(os.path.join(BASE_DIR, '.env'))

# Application definition
INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',

    # Third-party
    'rest_framework',
    'corsheaders',
    'django_filters',
    'django_redis',
    'drf_spectacular',

    # Local apps
    'apps.users',
    'apps.projects',
    'apps.tasks',
    'apps.comments',
]

MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'corsheaders.middleware.CorsMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
    'apps.api.middleware.PerformanceMiddleware',
]

ROOT_URLCONF = 'config.urls'

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.debug',
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]

WSGI_APPLICATION = 'config.wsgi.application'

# Database
DATABASES = {
    'default': env.db(default='sqlite:///db.sqlite3'),
}
DATABASES['default']['CONN_MAX_AGE'] = 600
DATABASES['default']['CONN_HEALTH_CHECKS'] = True

# Password validation
AUTH_PASSWORD_VALIDATORS = [
    {
        'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator',
        'OPTIONS': {'min_length': 8},
    },
    {
        'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator',
    },
]

# Internationalization
LANGUAGE_CODE = 'en-us'
TIME_ZONE = 'UTC'
USE_I18N = True
USE_TZ = True

# Static files
STATIC_URL = '/static/'
STATIC_ROOT = BASE_DIR / 'staticfiles'
STATICFILES_STORAGE = 'django.contrib.staticfiles.storage.ManifestStaticFilesStorage'

# Media files
MEDIA_URL = '/media/'
MEDIA_ROOT = BASE_DIR / 'media'

# Default primary key field type
DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'

# Custom User Model
AUTH_USER_MODEL = 'users.User'

# Cache
CACHES = {
    'default': {
        'BACKEND': 'django_redis.cache.RedisCache',
        'LOCATION': env('REDIS_URL', default='redis://localhost:6379/1'),
        'OPTIONS': {
            'CLIENT_CLASS': 'django_redis.client.DefaultClient',
            'PARSER_CLASS': 'redis.connection.HiredisParser',
            'CONNECTION_POOL_CLASS': 'redis.BlockingConnectionPool',
            'CONNECTION_POOL_CLASS_KWARGS': {
                'max_connections': 50,
                'timeout': 20,
            },
            'SERIALIZER': 'django_redis.serializers.json.JSONSerializer',
        },
        'KEY_PREFIX': 'taskflow',
    }
}

# Cache TTLs
CACHE_TTL = {
    'short': 60,
    'medium': 300,
    'long': 3600,
    'very_long': 86400,
}

# Django REST Framework
REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': [
        'rest_framework_simplejwt.authentication.JWTAuthentication',
        'rest_framework.authentication.SessionAuthentication',
    ],
    'DEFAULT_PERMISSION_CLASSES': [
        'rest_framework.permissions.IsAuthenticated',
    ],
    'DEFAULT_RENDERER_CLASSES': [
        'rest_framework.renderers.JSONRenderer',
    ],
    'DEFAULT_PARSER_CLASSES': [
        'rest_framework.parsers.JSONParser',
    ],
    'DEFAULT_FILTER_BACKENDS': [
        'django_filters.rest_framework.DjangoFilterBackend',
        'rest_framework.filters.SearchFilter',
        'rest_framework.filters.OrderingFilter',
    ],
    'DEFAULT_PAGINATION_CLASS': 'apps.api.pagination.OptimizedPageNumberPagination',
    'PAGE_SIZE': 20,
    'DEFAULT_VERSIONING_CLASS': 'rest_framework.versioning.URLPathVersioning',
    'DEFAULT_VERSION': 'v1',
    'ALLOWED_VERSIONS': ['v1'],
    'VERSION_PARAM': 'version',
    'DEFAULT_SCHEMA_CLASS': 'drf_spectacular.openapi.AutoSchema',
}

# JWT Settings
SIMPLE_JWT = {
    'ACCESS_TOKEN_LIFETIME': timedelta(minutes=15),
    'REFRESH_TOKEN_LIFETIME': timedelta(days=7),
    'ROTATE_REFRESH_TOKENS': True,
    'BLACKLIST_AFTER_ROTATION': True,
    'UPDATE_LAST_LOGIN': True,
    'ALGORITHM': 'HS256',
    'SIGNING_KEY': env('SECRET_KEY'),
    'AUTH_HEADER_TYPES': ('Bearer',),
    'USER_ID_FIELD': 'id',
    'USER_ID_CLAIM': 'user_id',
}

# Spectacular (OpenAPI)
SPECTACULAR_SETTINGS = {
    'TITLE': 'TaskFlow API',
    'DESCRIPTION': 'A modern task management platform API',
    'VERSION': '1.0.0',
    'SERVE_INCLUDE_SCHEMA': False,
    'COMPONENT_SPLIT_REQUEST': True,
}

# CORS settings (will be overridden in production)
CORS_ALLOW_CREDENTIALS = True

# Security settings (overridden in production)
SECURE_BROWSER_XSS_FILTER = True
SECURE_CONTENT_TYPE_NOSNIFF = True
X_FRAME_OPTIONS = 'DENY'
```

**backend/config/settings/development.py** (create)

```python
"""
Development settings - overrides base settings for local development.
"""

from .base import *

# Debug
DEBUG = True

# Secret Key (fallback for development)
SECRET_KEY = env('SECRET_KEY', default='django-insecure-dev-key-12345')

# Allowed Hosts
ALLOWED_HOSTS = ['localhost', '127.0.0.1', 'backend']

# CORS
CORS_ALLOW_ALL_ORIGINS = True

# Email backend (console for development)
EMAIL_BACKEND = 'django.core.mail.backends.console.EmailBackend'

# Django Debug Toolbar
INSTALLED_APPS += [
    'debug_toolbar',
    'silk',
]

MIDDLEWARE += [
    'debug_toolbar.middleware.DebugToolbarMiddleware',
    'silk.middleware.SilkyMiddleware',
]

INTERNAL_IPS = ['127.0.0.1']

# Logging
LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'formatters': {
        'verbose': {
            'format': '{levelname} {asctime} {module} {process:d} {thread:d} {message}',
            'style': '{',
        },
        'simple': {
            'format': '{levelname} {message}',
            'style': '{',
        },
    },
    'handlers': {
        'console': {
            'level': 'DEBUG',
            'class': 'logging.StreamHandler',
            'formatter': 'verbose',
        },
    },
    'loggers': {
        'django': {
            'handlers': ['console'],
            'level': 'INFO',
            'propagate': False,
        },
        'django.db.backends': {
            'handlers': ['console'],
            'level': 'DEBUG',
            'propagate': False,
        },
    },
}
```

**backend/config/settings/production.py** (create)

```python
"""
Production settings - overrides base settings for production.
"""

import os
from .base import *

# Debug - MUST be False in production
DEBUG = False

# Secret Key - MUST be set in environment
SECRET_KEY = env('SECRET_KEY')
if not SECRET_KEY:
    raise ValueError("SECRET_KEY must be set in production")

# Allowed Hosts
ALLOWED_HOSTS = env.list('ALLOWED_HOSTS', default=['localhost'])

# CSRF Trusted Origins
CSRF_TRUSTED_ORIGINS = env.list('CSRF_TRUSTED_ORIGINS', default=[])

# Security settings
SECURE_SSL_REDIRECT = True
SECURE_PROXY_SSL_HEADER = ('HTTP_X_FORWARDED_PROTO', 'https')
SESSION_COOKIE_SECURE = True
CSRF_COOKIE_SECURE = True
SESSION_COOKIE_HTTPONLY = True
CSRF_COOKIE_HTTPONLY = True
SESSION_COOKIE_SAMESITE = 'Lax'
CSRF_COOKIE_SAMESITE = 'Lax'

# HSTS
SECURE_HSTS_SECONDS = 31536000  # 1 year
SECURE_HSTS_INCLUDE_SUBDOMAINS = True
SECURE_HSTS_PRELOAD = True

# CORS - Restrict to frontend domains
CORS_ALLOWED_ORIGINS = env.list('CORS_ALLOWED_ORIGINS', default=[])
CORS_ALLOW_CREDENTIALS = True

# Cache - Use Redis
CACHES = {
    'default': {
        'BACKEND': 'django_redis.cache.RedisCache',
        'LOCATION': env('REDIS_URL'),
        'OPTIONS': {
            'CLIENT_CLASS': 'django_redis.client.DefaultClient',
            'SERIALIZER': 'django_redis.serializers.json.JSONSerializer',
        },
        'KEY_PREFIX': 'taskflow',
    }
}

# Static files - Use Manifest storage
STATICFILES_STORAGE = 'django.contrib.staticfiles.storage.ManifestStaticFilesStorage'

# Email
EMAIL_BACKEND = 'django.core.mail.backends.smtp.EmailBackend'
EMAIL_HOST = env('EMAIL_HOST')
EMAIL_PORT = env.int('EMAIL_PORT', default=587)
EMAIL_HOST_USER = env('EMAIL_HOST_USER')
EMAIL_HOST_PASSWORD = env('EMAIL_HOST_PASSWORD')
EMAIL_USE_TLS = True

# Logging
LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'formatters': {
        'verbose': {
            'format': '{levelname} {asctime} {name} {message}',
            'style': '{',
        },
        'json': {
            'format': '{{"timestamp": "{asctime}", "level": "{levelname}", "logger": "{name}", "message": "{message}"}}',
            'style': '{',
        },
    },
    'handlers': {
        'file': {
            'level': 'INFO',
            'class': 'logging.handlers.RotatingFileHandler',
            'filename': '/app/logs/app.log',
            'maxBytes': 10485760,  # 10MB
            'backupCount': 10,
            'formatter': 'json',
        },
        'security': {
            'level': 'INFO',
            'class': 'logging.handlers.RotatingFileHandler',
            'filename': '/app/logs/security.log',
            'maxBytes': 10485760,
            'backupCount': 10,
            'formatter': 'json',
        },
        'api': {
            'level': 'INFO',
            'class': 'logging.handlers.RotatingFileHandler',
            'filename': '/app/logs/api.log',
            'maxBytes': 10485760,
            'backupCount': 10,
            'formatter': 'json',
        },
    },
    'loggers': {
        'django': {
            'handlers': ['file'],
            'level': 'INFO',
            'propagate': False,
        },
        'django.security': {
            'handlers': ['security'],
            'level': 'INFO',
            'propagate': False,
        },
        'api': {
            'handlers': ['api'],
            'level': 'INFO',
            'propagate': False,
        },
    },
}

# Rate limiting (if using django-ratelimit)
RATELIMIT_ENABLE = True

# Security headers middleware
MIDDLEWARE.insert(1, 'django.middleware.security.SecurityMiddleware')
```

### Step 2: Create Production Environment File

**backend/.env.production** (create)

```bash
# Django settings
DJANGO_ENV=production
SECRET_KEY=your-production-secret-key-here
DEBUG=False
ALLOWED_HOSTS=api.taskflow.com,www.api.taskflow.com
CSRF_TRUSTED_ORIGINS=https://api.taskflow.com,https://www.taskflow.com

# Database
DB_NAME=taskflow_db
DB_USER=taskflow_user
DB_PASSWORD=your-db-password
DB_HOST=db
DB_PORT=5432

# Redis
REDIS_URL=redis://redis:6379/1
REDIS_PASSWORD=your-redis-password

# CORS
CORS_ALLOWED_ORIGINS=https://app.taskflow.com,https://www.taskflow.com

# JWT
JWT_SECRET_KEY=your-jwt-secret-key

# Email
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_HOST_USER=your-email@gmail.com
EMAIL_HOST_PASSWORD=your-app-password

# Gunicorn
GUNICORN_WORKERS=4
```

### Step 3: Create Frontend Production Environment

**frontend/.env.production** (create)

```bash
NEXT_PUBLIC_API_URL=https://api.taskflow.com/api/v1
NEXT_PUBLIC_APP_URL=https://app.taskflow.com
```

### Step 4: Create Security Audit Script

**backend/scripts/security_audit.py** (create)

```python
"""
Security audit script for production deployment.
"""

import os
import sys
import django
from django.conf import settings

# Set up Django environment
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()


def audit_security():
    """Run security audits on production settings."""
    issues = []
    warnings = []
    
    print("🔍 Running security audit...")
    print("=" * 50)
    
    # Check DEBUG
    if settings.DEBUG:
        issues.append("DEBUG is True - must be False in production")
    else:
        print("✅ DEBUG is False")
    
    # Check SECRET_KEY
    if hasattr(settings, 'SECRET_KEY') and settings.SECRET_KEY:
        if 'django-insecure' in settings.SECRET_KEY:
            issues.append("SECRET_KEY contains 'django-insecure' - use a secure key")
        else:
            print("✅ SECRET_KEY is set and secure")
    else:
        issues.append("SECRET_KEY is not set")
    
    # Check ALLOWED_HOSTS
    if settings.ALLOWED_HOSTS and '*' not in settings.ALLOWED_HOSTS:
        print("✅ ALLOWED_HOSTS is configured")
    else:
        warnings.append("ALLOWED_HOSTS is empty or contains '*'")
    
    # Check CORS
    if hasattr(settings, 'CORS_ALLOWED_ORIGINS'):
        if settings.CORS_ALLOWED_ORIGINS and '*' not in settings.CORS_ALLOWED_ORIGINS:
            print("✅ CORS_ALLOWED_ORIGINS is configured")
        else:
            warnings.append("CORS_ALLOWED_ORIGINS is empty or contains '*'")
    
    # Check HTTPS settings
    if settings.SECURE_SSL_REDIRECT:
        print("✅ SECURE_SSL_REDIRECT is enabled")
    else:
        warnings.append("SECURE_SSL_REDIRECT is not enabled")
    
    if settings.SESSION_COOKIE_SECURE:
        print("✅ SESSION_COOKIE_SECURE is enabled")
    else:
        warnings.append("SESSION_COOKIE_SECURE is not enabled")
    
    if settings.CSRF_COOKIE_SECURE:
        print("✅ CSRF_COOKIE_SECURE is enabled")
    else:
        warnings.append("CSRF_COOKIE_SECURE is not enabled")
    
    # Check HSTS
    if settings.SECURE_HSTS_SECONDS > 0:
        print("✅ HSTS is enabled")
    else:
        warnings.append("HSTS is not enabled")
    
    # Report
    print("=" * 50)
    
    if issues:
        print("\n❌ Issues found:")
        for issue in issues:
            print(f"  • {issue}")
    
    if warnings:
        print("\n⚠️ Warnings:")
        for warning in warnings:
            print(f"  • {warning}")
    
    if not issues and not warnings:
        print("\n✅ All security checks passed!")
    
    return issues, warnings


if __name__ == '__main__':
    audit_security()
```

### Step 5: Create Monitoring Script

**backend/scripts/monitor.py** (create)

```python
"""
Production monitoring script.
"""

import os
import sys
import requests
import time
from datetime import datetime

API_URL = os.getenv('API_URL', 'http://localhost:8000')
HEALTH_ENDPOINT = f"{API_URL}/health/"


def check_health():
    """Check if the application is healthy."""
    try:
        response = requests.get(HEALTH_ENDPOINT, timeout=10)
        if response.status_code == 200:
            data = response.json()
            timestamp = datetime.now().isoformat()
            print(f"[{timestamp}] ✅ Health check passed")
            print(f"  Status: {data.get('status')}")
            print(f"  Database: {data.get('services', {}).get('database')}")
            print(f"  Redis: {data.get('services', {}).get('redis')}")
            return True
        else:
            print(f"❌ Health check failed: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ Health check error: {e}")
        return False


def monitor():
    """Run continuous monitoring."""
    print("📊 Starting monitoring...")
    print(f"🔍 Checking {HEALTH_ENDPOINT}")
    print("=" * 50)
    
    while True:
        check_health()
        print("-" * 50)
        time.sleep(30)


if __name__ == '__main__':
    monitor()
```

---

## The Verification

### Step 1: Run Security Audit

```bash
cd backend
python scripts/security_audit.py
```

### Step 2: Test Production Settings

```bash
# Set environment to production
export DJANGO_ENV=production

# Run migrations
python manage.py migrate

# Collect static files
python manage.py collectstatic --noinput

# Check settings
python manage.py shell -c "
from django.conf import settings
print(f'DEBUG: {settings.DEBUG}')
print(f'ALLOWED_HOSTS: {settings.ALLOWED_HOSTS}')
"
```

### Step 3: Start Production Containers

```bash
docker-compose -f docker-compose.prod.yml up -d
```

### Step 4: Test Health Check

```bash
curl http://localhost/health/
```

### Step 5: Monitor

```bash
python scripts/monitor.py
```

---

## Key Takeaways

1. **Environment-specific settings** separate development and production.

2. **Security settings** must be properly configured for production.

3. **Logging** should be structured and stored appropriately.

4. **HTTPS** must be enforced in production.

5. **Secret management** requires environment variables.

6. **Security audits** verify production readiness.

7. **Monitoring** ensures application health.

---

## What's Next

In **Part 31**, we'll implement the reverse proxy and networking:

- Nginx configuration details
- SSL/TLS setup
- Load balancing
- Network security

---

**End of Part 30**

*Next: Part 31 - Reverse Proxy & Networking*
