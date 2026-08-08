# Appendix Q: Django REST Framework & Next.js 16 Project Templates

## Quick-Start Templates for Common Scenarios

Welcome to **Appendix Q** of the Django REST Framework & Next.js 16 masterclass. This appendix provides complete project templates for common scenarios, allowing you to quickly bootstrap new projects with best practices already configured.

---

## Section 1: Minimal DRF API Template

A minimal Django REST Framework API setup for building RESTful APIs quickly.

### 1.1 Project Structure

```
api-project/
├── backend/
│   ├── config/
│   │   ├── __init__.py
│   │   ├── settings.py
│   │   ├── urls.py
│   │   └── wsgi.py
│   ├── apps/
│   │   ├── api/
│   │   │   ├── __init__.py
│   │   │   ├── serializers.py
│   │   │   ├── views.py
│   │   │   └── urls.py
│   │   └── core/
│   │       ├── __init__.py
│   │       ├── models.py
│   │       └── admin.py
│   ├── requirements/
│   │   ├── base.txt
│   │   └── development.txt
│   ├── manage.py
│   └── .env
├── .gitignore
└── README.md
```

### 1.2 Requirements

**backend/requirements/base.txt:**
```txt
Django>=6.0,<6.1
djangorestframework>=3.15.0
django-environ>=0.11.0
psycopg2-binary>=2.9.0
django-cors-headers>=4.3.0
```

### 1.3 Settings

**backend/config/settings.py:**
```python
import os
from pathlib import Path
import environ

BASE_DIR = Path(__file__).resolve().parent.parent
env = environ.Env()
environ.Env.read_env(os.path.join(BASE_DIR, '.env'))

SECRET_KEY = env('SECRET_KEY', default='django-insecure-dev-key')
DEBUG = env.bool('DEBUG', default=True)
ALLOWED_HOSTS = env.list('ALLOWED_HOSTS', default=['localhost', '127.0.0.1'])

INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'rest_framework',
    'corsheaders',
    'apps.api',
    'apps.core',
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

DATABASES = {
    'default': env.db(default='sqlite:///db.sqlite3')
}

AUTH_PASSWORD_VALIDATORS = [
    {
        'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator',
    },
]

LANGUAGE_CODE = 'en-us'
TIME_ZONE = 'UTC'
USE_I18N = True
USE_TZ = True

STATIC_URL = 'static/'
DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'

# CORS
CORS_ALLOW_ALL_ORIGINS = DEBUG
CORS_ALLOWED_ORIGINS = env.list('CORS_ALLOWED_ORIGINS', default=[])

# DRF
REST_FRAMEWORK = {
    'DEFAULT_PERMISSION_CLASSES': [
        'rest_framework.permissions.AllowAny',
    ],
    'DEFAULT_RENDERER_CLASSES': [
        'rest_framework.renderers.JSONRenderer',
    ],
}
```

### 1.4 API Example

**backend/apps/api/views.py:**
```python
from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status
from apps.core.models import Item
from .serializers import ItemSerializer

@api_view(['GET', 'POST'])
def item_list(request):
    if request.method == 'GET':
        items = Item.objects.all()
        serializer = ItemSerializer(items, many=True)
        return Response(serializer.data)
    
    elif request.method == 'POST':
        serializer = ItemSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

@api_view(['GET', 'PUT', 'DELETE'])
def item_detail(request, pk):
    try:
        item = Item.objects.get(pk=pk)
    except Item.DoesNotExist:
        return Response({'error': 'Item not found'}, status=status.HTTP_404_NOT_FOUND)
    
    if request.method == 'GET':
        serializer = ItemSerializer(item)
        return Response(serializer.data)
    
    elif request.method == 'PUT':
        serializer = ItemSerializer(item, data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    elif request.method == 'DELETE':
        item.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)
```

---

## Section 2: Full Stack Template (Django + Next.js)

A complete full-stack template with Django DRF backend and Next.js frontend.

### 2.1 Backend Setup

**backend/requirements/base.txt:**
```txt
Django>=6.0,<6.1
djangorestframework>=3.15.0
djangorestframework-simplejwt>=5.3.0
django-environ>=0.11.0
psycopg2-binary>=2.9.0
django-cors-headers>=4.3.0
django-filter>=24.0.0
django-redis>=5.4.0
drf-spectacular>=0.27.0
```

**backend/requirements/development.txt:**
```txt
-r base.txt
django-debug-toolbar>=4.3.0
pytest>=8.0.0
pytest-django>=4.8.0
factory-boy>=3.3.0
ipython>=8.22.0
```

### 2.2 Backend Settings (Production)

**backend/config/settings/production.py:**
```python
from .base import *

DEBUG = False
SECRET_KEY = env('SECRET_KEY')
ALLOWED_HOSTS = env.list('ALLOWED_HOSTS')
CSRF_TRUSTED_ORIGINS = env.list('CSRF_TRUSTED_ORIGINS', default=[])

# Security
SECURE_SSL_REDIRECT = True
SECURE_PROXY_SSL_HEADER = ('HTTP_X_FORWARDED_PROTO', 'https')
SESSION_COOKIE_SECURE = True
CSRF_COOKIE_SECURE = True
SESSION_COOKIE_HTTPONLY = True
CSRF_COOKIE_HTTPONLY = True
SESSION_COOKIE_SAMESITE = 'Lax'
SECURE_HSTS_SECONDS = 31536000
SECURE_HSTS_INCLUDE_SUBDOMAINS = True
SECURE_HSTS_PRELOAD = True

# CORS
CORS_ALLOWED_ORIGINS = env.list('CORS_ALLOWED_ORIGINS')
CORS_ALLOW_CREDENTIALS = True

# Database
DATABASES = {
    'default': env.db()
}
DATABASES['default']['CONN_MAX_AGE'] = 600

# Cache
CACHES = {
    'default': {
        'BACKEND': 'django_redis.cache.RedisCache',
        'LOCATION': env('REDIS_URL'),
        'OPTIONS': {
            'CLIENT_CLASS': 'django_redis.client.DefaultClient',
        },
    }
}

# Logging
LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'handlers': {
        'file': {
            'level': 'INFO',
            'class': 'logging.handlers.RotatingFileHandler',
            'filename': '/app/logs/app.log',
            'maxBytes': 10485760,
            'backupCount': 5,
        },
    },
    'loggers': {
        'django': {
            'handlers': ['file'],
            'level': 'INFO',
        },
    },
}
```

### 2.3 Frontend Setup

**frontend/package.json:**
```json
{
    "name": "taskflow-frontend",
    "version": "1.0.0",
    "private": true,
    "scripts": {
        "dev": "next dev",
        "build": "next build",
        "start": "next start",
        "lint": "next lint",
        "test": "jest"
    },
    "dependencies": {
        "next": "16.0.0",
        "react": "19.0.0",
        "react-dom": "19.0.0",
        "@tanstack/react-query": "^5.0.0",
        "axios": "^1.6.0",
        "tailwindcss": "^3.4.0",
        "lucide-react": "^0.309.0"
    },
    "devDependencies": {
        "@types/node": "^20.0.0",
        "@types/react": "^19.0.0",
        "@types/react-dom": "^19.0.0",
        "@testing-library/react": "^14.0.0",
        "@testing-library/jest-dom": "^6.0.0",
        "jest": "^29.0.0",
        "typescript": "^5.0.0"
    }
}
```

### 2.4 Frontend API Client

**frontend/lib/api/client.ts:**
```typescript
import axios from 'axios';

const API_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000/api/v1';

const api = axios.create({
    baseURL: API_URL,
    headers: {
        'Content-Type': 'application/json',
    },
});

// Request interceptor - add token
api.interceptors.request.use((config) => {
    const token = localStorage.getItem('access_token');
    if (token) {
        config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
});

// Response interceptor - handle errors
api.interceptors.response.use(
    (response) => response,
    async (error) => {
        const originalRequest = error.config;
        if (error.response?.status === 401 && !originalRequest._retry) {
            originalRequest._retry = true;
            try {
                const refresh = localStorage.getItem('refresh_token');
                const response = await axios.post(`${API_URL}/token/refresh/`, {
                    refresh,
                });
                const { access } = response.data;
                localStorage.setItem('access_token', access);
                originalRequest.headers.Authorization = `Bearer ${access}`;
                return api(originalRequest);
            } catch (refreshError) {
                // Redirect to login
                window.location.href = '/login';
                return Promise.reject(refreshError);
            }
        }
        return Promise.reject(error);
    }
);

export default api;
```

---

## Section 3: Microservice Template

A template for building microservices with Django and DRF.

### 3.1 Project Structure

```
microservice-project/
├── services/
│   ├── user-service/
│   │   ├── Dockerfile
│   │   ├── requirements.txt
│   │   └── app/
│   ├── task-service/
│   │   ├── Dockerfile
│   │   ├── requirements.txt
│   │   └── app/
│   └── notification-service/
│       ├── Dockerfile
│       ├── requirements.txt
│       └── app/
├── docker-compose.yml
└── .env
```

### 3.2 Service Template

**services/user-service/Dockerfile:**
```dockerfile
FROM python:3.12-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

CMD ["gunicorn", "--bind", "0.0.0.0:8000", "app.wsgi"]
```

**services/user-service/app/settings.py:**
```python
import os
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent.parent

SECRET_KEY = os.environ.get('SECRET_KEY')
DEBUG = os.environ.get('DEBUG', 'False') == 'True'

ALLOWED_HOSTS = os.environ.get('ALLOWED_HOSTS', 'localhost').split(',')

INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'rest_framework',
    'corsheaders',
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
]

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': os.environ.get('DB_NAME'),
        'USER': os.environ.get('DB_USER'),
        'PASSWORD': os.environ.get('DB_PASSWORD'),
        'HOST': os.environ.get('DB_HOST'),
        'PORT': os.environ.get('DB_PORT'),
    }
}

REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': [
        'rest_framework_simplejwt.authentication.JWTAuthentication',
    ],
}

CORS_ALLOWED_ORIGINS = os.environ.get('CORS_ALLOWED_ORIGINS', '').split(',')
```

### 3.3 Docker Compose

**docker-compose.yml:**
```yaml
version: '3.8'

services:
  user-service:
    build: ./services/user-service
    environment:
      - SECRET_KEY=${SECRET_KEY}
      - DB_NAME=${USER_DB_NAME}
      - DB_USER=${USER_DB_USER}
      - DB_PASSWORD=${USER_DB_PASSWORD}
      - DB_HOST=user-db
    ports:
      - "8001:8000"
    networks:
      - microservices
    depends_on:
      - user-db

  user-db:
    image: postgres:15-alpine
    environment:
      - POSTGRES_DB=${USER_DB_NAME}
      - POSTGRES_USER=${USER_DB_USER}
      - POSTGRES_PASSWORD=${USER_DB_PASSWORD}
    volumes:
      - user_db_data:/var/lib/postgresql/data
    networks:
      - microservices

  task-service:
    build: ./services/task-service
    environment:
      - SECRET_KEY=${SECRET_KEY}
      - DB_NAME=${TASK_DB_NAME}
      - DB_USER=${TASK_DB_USER}
      - DB_PASSWORD=${TASK_DB_PASSWORD}
      - DB_HOST=task-db
      - USER_SERVICE_URL=http://user-service:8000
    ports:
      - "8002:8000"
    networks:
      - microservices
    depends_on:
      - task-db
      - user-service

  task-db:
    image: postgres:15-alpine
    environment:
      - POSTGRES_DB=${TASK_DB_NAME}
      - POSTGRES_USER=${TASK_DB_USER}
      - POSTGRES_PASSWORD=${TASK_DB_PASSWORD}
    volumes:
      - task_db_data:/var/lib/postgresql/data
    networks:
      - microservices

networks:
  microservices:
    driver: bridge

volumes:
  user_db_data:
  task_db_data:
```

---

## Section 4: Serverless Template (Django on AWS Lambda)

A template for running Django on AWS Lambda using Zappa.

### 4.1 Requirements

**requirements.txt:**
```txt
Django>=6.0,<6.1
djangorestframework>=3.15.0
zappa>=0.54.0
psycopg2-binary>=2.9.0
django-environ>=0.11.0
```

### 4.2 Zappa Configuration

**zappa_settings.json:**
```json
{
    "production": {
        "app_function": "config.wsgi.application",
        "aws_region": "us-east-1",
        "project_name": "taskflow-api",
        "runtime": "python3.12",
        "s3_bucket": "taskflow-zappa",
        "domain": "api.taskflow.com",
        "certificate_arn": "arn:aws:acm:us-east-1:123456789:certificate/xxxxx",
        "environment_variables": {
            "DJANGO_SETTINGS_MODULE": "config.settings"
        },
        "manage_roles": true,
        "lambda_description": "TaskFlow API Lambda",
        "memory_size": 512,
        "timeout_seconds": 30
    }
}
```

### 4.3 Serverless Configuration

**serverless.yml:**
```yaml
service: taskflow-api

provider:
  name: aws
  runtime: python3.12
  region: us-east-1
  environment:
    DJANGO_SETTINGS_MODULE: config.settings
  iamRoleStatements:
    - Effect: Allow
      Action:
        - dynamodb:*
      Resource: "arn:aws:dynamodb:${self:provider.region}:*:table/taskflow-*"

functions:
  api:
    handler: config.wsgi.handler
    events:
      - http: ANY /
      - http: ANY /{proxy+}
    timeout: 30
    memorySize: 512

plugins:
  - serverless-wsgi
  - serverless-python-requirements
```

---

## Section 5: Quick Start Commands

### Django Backend

```bash
# Create virtual environment
python -m venv venv
source venv/bin/activate

# Install dependencies
pip install -r requirements/development.txt

# Create .env file
cp .env.example .env

# Run migrations
python manage.py migrate

# Create superuser
python manage.py createsuperuser

# Run server
python manage.py runserver
```

### Next.js Frontend

```bash
# Install dependencies
npm install

# Create .env.local
cp .env.local.example .env.local

# Run development server
npm run dev

# Build for production
npm run build

# Run production server
npm start
```

### Docker

```bash
# Build images
docker-compose build

# Start services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down

# Stop and remove volumes
docker-compose down -v
```

### Deployment

```bash
# Deploy with Zappa
zappa deploy production

# Update deployment
zappa update production

# Rollback
zappa rollback production

# Deploy with Serverless
serverless deploy

# Deploy with Docker to ECS
docker build -t taskflow-backend .
docker tag taskflow-backend:latest ecr-repo/taskflow-backend:latest
docker push ecr-repo/taskflow-backend:latest
```

---

*This concludes Appendix Q. Use these templates to quickly bootstrap new projects with best practices already configured.*
