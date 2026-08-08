# Part 26: API Documentation with OpenAPI

## Creating Professional API Documentation

Welcome to **Part 26** of the Django REST Framework & Next.js 16 masterclass. Now that we have a fully tested application, it's time to create professional API documentation. We'll use OpenAPI (formerly Swagger) to generate interactive documentation that makes our API easy to understand and consume.

In this part, we'll:
- Install and configure drf-spectacular
- Generate OpenAPI schema
- Add schema annotations to views
- Customize the documentation
- Deploy interactive documentation
- Generate client SDKs

Think of API documentation as your **API's user manual**. Just as a car comes with a manual explaining all its features and how to use them, your API needs documentation that explains endpoints, parameters, responses, and authentication.

---

## The Target

We'll build a complete API documentation system:

```
Documentation Features:
┌─────────────────────────────────────────────────────────────────────┐
│                                                                     │
│  Interactive API Documentation                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │  Swagger UI / ReDoc                                        │   │
│  │  ├── Authentication: Bearer Token                         │   │
│  │  ├── Endpoints:                                           │   │
│  │  │   ├── GET /api/v1/tasks/                              │   │
│  │  │   ├── POST /api/v1/tasks/                             │   │
│  │  │   └── ...                                             │   │
│  │  └── Try It Out: Interactive testing                     │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  Export Formats                                                    │
│  ├── OpenAPI JSON                                                 │
│  ├── OpenAPI YAML                                                 │
│  └── Postman Collection                                          │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## The Concept

### What is OpenAPI?

OpenAPI (formerly Swagger) is a specification for describing REST APIs. It provides:
- **Machine-readable format**: JSON or YAML
- **Human-readable documentation**: Interactive UI
- **Client generation**: Generate SDKs in multiple languages
- **Validation**: Validate API requests/responses

### drf-spectacular

drf-spectacular is a Django REST Framework library that:
- **Generates OpenAPI schema** from your code
- **Extracts information** from views, serializers, and models
- **Provides custom annotations** for fine-tuning
- **Supports OpenAPI 3.0+** (latest specification)

### Documentation Sections

| Section | Purpose |
|---------|---------|
| **Info** | API title, description, version |
| **Servers** | Base URLs (development, production) |
| **Security** | Authentication requirements |
| **Paths** | All endpoints with parameters |
| **Schemas** | Request/response models |
| **Tags** | Grouping of endpoints |

---

## The Implementation

### Step 1: Install drf-spectacular

```bash
cd backend
source venv/bin/activate
pip install drf-spectacular
echo "drf-spectacular>=0.27.0" >> requirements/base.txt
```

### Step 2: Configure drf-spectacular

**backend/config/settings.py** (update)

```python
# Add to INSTALLED_APPS
INSTALLED_APPS = [
    # ...
    'drf_spectacular',
    # ...
]

# DRF settings update
REST_FRAMEWORK = {
    # ...
    'DEFAULT_SCHEMA_CLASS': 'drf_spectacular.openapi.AutoSchema',
    # ...
}

# Spectacular settings
SPECTACULAR_SETTINGS = {
    'TITLE': 'TaskFlow API',
    'DESCRIPTION': '''
    ## TaskFlow API Documentation
    
    TaskFlow is a modern task management platform built with Django REST Framework.
    
    ### Features
    - User management with roles (Admin, Manager, Member, Viewer)
    - Project management
    - Task management with status and priority
    - Comments on tasks
    - Advanced filtering, search, and pagination
    
    ### Authentication
    This API uses JWT (JSON Web Token) authentication.
    
    **To authenticate:**
    1. Obtain a token pair via `/api/v1/token/`
    2. Use the access token in the `Authorization` header
    3. Refresh the token via `/api/v1/token/refresh/`
    
    ### Rate Limiting
    - 100 requests per hour for general API endpoints
    - 10 requests per minute for authentication endpoints
    
    ### Version
    This is version 1 of the API.
    ''',
    'VERSION': '1.0.0',
    'SERVE_INCLUDE_SCHEMA': False,
    'COMPONENT_SPLIT_REQUEST': True,
    'SCHEMA_PATH_PREFIX': '/api/v1/',
    'SECURITY': [
        {
            'BearerAuth': {
                'type': 'http',
                'scheme': 'bearer',
                'bearerFormat': 'JWT',
            }
        }
    ],
    'TAGS': [
        {'name': 'Authentication', 'description': 'Authentication endpoints'},
        {'name': 'Users', 'description': 'User management endpoints'},
        {'name': 'Projects', 'description': 'Project management endpoints'},
        {'name': 'Tasks', 'description': 'Task management endpoints'},
        {'name': 'Comments', 'description': 'Comment management endpoints'},
    ],
    'EXTENSIONS': {
        'x-logo': {
            'url': 'https://your-domain.com/logo.png',
            'backgroundColor': '#FFFFFF',
        },
    },
    'SERVE_PERMISSIONS': ['rest_framework.permissions.AllowAny'],
    'SWAGGER_UI_SETTINGS': {
        'deepLinking': True,
        'persistAuthorization': True,
        'displayOperationId': False,
        'filter': True,
        'docExpansion': 'none',
        'defaultModelsExpandDepth': 1,
        'defaultModelExpandDepth': 1,
    },
    'REDOC_SETTINGS': {
        'hideHostname': False,
        'theme': {
            'colors': {
                'primary': {
                    'main': '#3b82f6',
                },
            },
        },
    },
}
```

### Step 3: Add Schema Annotations to Views

**backend/apps/tasks/views.py** (add annotations)

```python
from drf_spectacular.utils import (
    extend_schema,
    extend_schema_view,
    OpenApiParameter,
    OpenApiTypes,
    OpenApiExample,
    OpenApiResponse,
    inline_serializer,
)
from drf_spectacular.types import OpenApiTypes
from rest_framework import serializers

@extend_schema_view(
    list=extend_schema(
        summary="List tasks",
        description="Get a list of tasks with optional filtering, search, and ordering.",
        parameters=[
            OpenApiParameter(name='status', description='Filter by status', type=str, enum=['todo', 'in_progress', 'review', 'done']),
            OpenApiParameter(name='priority', description='Filter by priority', type=str, enum=['low', 'medium', 'high', 'urgent']),
            OpenApiParameter(name='search', description='Search in title and description', type=str),
            OpenApiParameter(name='ordering', description='Order by fields (prefix with - for descending)', type=str),
            OpenApiParameter(name='page', description='Page number', type=int),
            OpenApiParameter(name='page_size', description='Number of items per page', type=int),
        ],
        responses={
            200: OpenApiResponse(
                description='List of tasks',
                response=inline_serializer(
                    name='TaskListResponse',
                    fields={
                        'results': serializers.ListField(child=TaskSerializer()),
                        'count': serializers.IntegerField(),
                        'next': serializers.URLField(allow_null=True),
                        'previous': serializers.URLField(allow_null=True),
                    }
                )
            ),
            401: OpenApiResponse(description='Authentication required'),
        },
        examples=[
            OpenApiExample(
                name='Filter by status',
                value={'status': 'in_progress'},
                request_only=True,
            ),
        ],
    ),
    create=extend_schema(
        summary="Create task",
        description="Create a new task. Requires authentication.",
        request=TaskCreateSerializer,
        responses={
            201: TaskSerializer,
            400: OpenApiResponse(description='Validation error'),
            401: OpenApiResponse(description='Authentication required'),
        },
    ),
    retrieve=extend_schema(
        summary="Get task details",
        description="Get detailed information about a specific task.",
        responses={
            200: TaskSerializer,
            404: OpenApiResponse(description='Task not found'),
        },
    ),
    update=extend_schema(
        summary="Update task",
        description="Update a task. Requires ownership or admin access.",
    ),
    partial_update=extend_schema(
        summary="Partial update task",
        description="Partially update a task. Requires ownership or admin access.",
    ),
    destroy=extend_schema(
        summary="Delete task",
        description="Delete a task. Requires ownership or admin access.",
        responses={
            204: OpenApiResponse(description='Task deleted'),
            403: OpenApiResponse(description='Permission denied'),
            404: OpenApiResponse(description='Task not found'),
        },
    ),
)
class TaskViewSet(viewsets.ModelViewSet):
    # ... existing code ...
```

**backend/apps/projects/views.py** (add annotations)

```python
from drf_spectacular.utils import extend_schema, OpenApiParameter, OpenApiResponse
from drf_spectacular.types import OpenApiTypes

class ProjectViewSet(viewsets.ModelViewSet):
    # ... existing code ...
    
    @extend_schema(
        summary="Get project stats",
        description="Get statistics for a specific project.",
        responses={
            200: inline_serializer(
                name='ProjectStats',
                fields={
                    'total_tasks': serializers.IntegerField(),
                    'completed': serializers.IntegerField(),
                    'in_progress': serializers.IntegerField(),
                    'todo': serializers.IntegerField(),
                    'review': serializers.IntegerField(),
                    'completion_rate': serializers.FloatField(),
                    'by_priority': serializers.DictField(),
                }
            ),
        },
    )
    @action(detail=True, methods=['get'])
    def stats(self, request, pk=None):
        # ... existing code ...
```

### Step 4: Add URL Routes for Documentation

**backend/config/urls.py** (update)

```python
from django.contrib import admin
from django.urls import path, include
from drf_spectacular.views import (
    SpectacularAPIView,
    SpectacularRedocView,
    SpectacularSwaggerView,
)

urlpatterns = [
    path('admin/', admin.site.urls),
    
    # API endpoints
    path('api/v1/', include('apps.api.urls')),
    
    # API documentation
    path('api/schema/', SpectacularAPIView.as_view(), name='schema'),
    path('api/docs/', SpectacularSwaggerView.as_view(url_name='schema'), name='swagger-ui'),
    path('api/redoc/', SpectacularRedocView.as_view(url_name='schema'), name='redoc'),
    
    # API auth for browsable API
    path('api-auth/', include('rest_framework.urls')),
]
```

### Step 5: Create Documentation Generator Command

**backend/apps/api/management/commands/generate_docs.py** (create)

```python
"""
Django management command to generate API documentation.
"""

import os
import json
import yaml
from django.core.management.base import BaseCommand
from django.core.management import call_command
from django.conf import settings


class Command(BaseCommand):
    help = 'Generate API documentation in multiple formats'

    def add_arguments(self, parser):
        parser.add_argument(
            '--format',
            type=str,
            choices=['json', 'yaml', 'all'],
            default='all',
            help='Output format (json, yaml, or all)',
        )
        parser.add_argument(
            '--output',
            type=str,
            help='Output directory',
            default='api_docs',
        )

    def handle(self, *args, **options):
        output_dir = options['output']
        format = options['format']
        
        # Create output directory
        os.makedirs(output_dir, exist_ok=True)
        
        self.stdout.write('Generating API documentation...')
        
        # Generate schema
        schema_file = os.path.join(output_dir, 'schema.json')
        call_command('spectacular', file=schema_file, format='json', verbosity=0)
        
        if format in ['yaml', 'all']:
            # Convert to YAML
            yaml_file = os.path.join(output_dir, 'schema.yaml')
            with open(schema_file, 'r') as f:
                data = json.load(f)
            with open(yaml_file, 'w') as f:
                yaml.dump(data, f, default_flow_style=False)
            self.stdout.write(self.style.SUCCESS(f'✅ YAML schema saved to {yaml_file}'))
        
        if format in ['json', 'all']:
            self.stdout.write(self.style.SUCCESS(f'✅ JSON schema saved to {schema_file}'))
        
        # Generate Postman collection
        if format in ['all']:
            self.generate_postman_collection(output_dir)
        
        self.stdout.write(self.style.SUCCESS('✅ Documentation generation complete!'))
    
    def generate_postman_collection(self, output_dir):
        """Generate a Postman collection from the schema."""
        # This is a placeholder - in production you could use
        # a tool like `openapi-to-postman` or `postman-generate`
        self.stdout.write('💡 To generate a Postman collection:')
        self.stdout.write('   Use: npm install -g openapi-to-postmanv2')
        self.stdout.write('   Then: openapi-to-postmanv2 -s schema.yaml -o collection.json')
```

### Step 6: Create Documentation View

**backend/apps/api/views.py** (add documentation info)

```python
from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status
from django.conf import settings


@api_view(['GET'])
def api_info(request):
    """
    Get general information about the API.
    """
    return Response({
        'name': 'TaskFlow API',
        'version': '1.0.0',
        'description': 'A modern task management platform',
        'documentation': '/api/docs/',
        'redoc': '/api/redoc/',
        'schema': '/api/schema/',
        'base_url': '/api/v1/',
        'authentication': {
            'type': 'JWT',
            'token_url': '/api/v1/token/',
            'refresh_url': '/api/v1/token/refresh/',
        },
        'rate_limits': {
            'general': '100 requests per hour',
            'auth': '10 requests per minute',
        },
    })
```

### Step 7: Add Documentation URL to API

**backend/apps/api/urls.py** (update)

```python
# Add to urlpatterns
urlpatterns = [
    # ...
    path('info/', api_info, name='api-info'),
    # ...
]
```

### Step 8: Create Markdown Documentation

**backend/api_docs/README.md** (create)

```markdown
# TaskFlow API Documentation

## Overview

TaskFlow is a modern task management platform built with Django REST Framework. This API provides comprehensive task and project management capabilities with role-based access control.

## Authentication

The API uses JWT (JSON Web Token) authentication.

### Obtaining a Token

```bash
POST /api/v1/token/
Content-Type: application/json

{
    "email": "user@example.com",
    "password": "yourpassword"
}
```

### Using the Token

Include the token in the Authorization header:

```
Authorization: Bearer your_access_token
```

### Refreshing a Token

```bash
POST /api/v1/token/refresh/
Content-Type: application/json

{
    "refresh": "your_refresh_token"
}
```

## Base URL

```
https://api.taskflow.com/api/v1/
```

## Rate Limiting

- General API: 100 requests per hour
- Authentication: 10 requests per minute

## Endpoints

### Users

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/users/` | List users |
| POST | `/users/register/` | Register new user |
| GET | `/users/profile/` | Get current user profile |
| GET | `/users/{id}/` | Get user details |
| POST | `/users/{id}/set_role/` | Set user role |

### Projects

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/projects/` | List projects |
| POST | `/projects/` | Create project |
| GET | `/projects/{id}/` | Get project details |
| PUT/PATCH | `/projects/{id}/` | Update project |
| DELETE | `/projects/{id}/` | Delete project |
| GET | `/projects/{id}/tasks/` | Get project tasks |
| POST | `/projects/{id}/add_task/` | Add task to project |
| GET | `/projects/{id}/stats/` | Get project statistics |

### Tasks

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/tasks/` | List tasks (with filters) |
| POST | `/tasks/` | Create task |
| GET | `/tasks/{id}/` | Get task details |
| PUT/PATCH | `/tasks/{id}/` | Update task |
| DELETE | `/tasks/{id}/` | Delete task |
| PATCH | `/tasks/{id}/status/` | Update task status |
| GET | `/tasks/{id}/comments/` | Get task comments |
| GET | `/tasks/stats/` | Get task statistics |

### Comments

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/comments/` | List comments |
| POST | `/comments/` | Create comment |
| GET | `/comments/{id}/` | Get comment details |
| PUT/PATCH | `/comments/{id}/` | Update comment |
| DELETE | `/comments/{id}/` | Delete comment |
| GET | `/comments/by_task/` | Get comments by task |

## Interactive Documentation

- Swagger UI: `/api/docs/`
- ReDoc: `/api/redoc/`
- Schema: `/api/schema/`

## Error Codes

| Code | Meaning |
|------|---------|
| 200 | Success |
| 201 | Created |
| 204 | No Content |
| 400 | Bad Request |
| 401 | Unauthorized |
| 403 | Forbidden |
| 404 | Not Found |
| 429 | Too Many Requests |
| 500 | Internal Server Error |

## Examples

### Create a Task

```bash
POST /api/v1/tasks/
Authorization: Bearer your_token
Content-Type: application/json

{
    "title": "Complete API documentation",
    "description": "Write comprehensive API docs",
    "status": "in_progress",
    "priority": "high",
    "project": 1
}
```

### Filter Tasks

```bash
GET /api/v1/tasks/?status=in_progress&priority=high&search=documentation
```

## Support

For issues or questions, please contact support@taskflow.com.
```

### Step 9: Create Documentation Health Check

**backend/apps/api/views.py** (add docs health check)

```python
@api_view(['GET'])
def docs_health(request):
    """
    Check if API documentation is available.
    """
    try:
        # Check if schema endpoint is available
        from django.urls import reverse
        from django.test import Client
        
        client = Client()
        response = client.get(reverse('schema'))
        
        if response.status_code == 200:
            return Response({
                'status': 'healthy',
                'message': 'API documentation is available',
                'schema_url': reverse('schema'),
                'swagger_url': reverse('swagger-ui'),
                'redoc_url': reverse('redoc'),
            })
        else:
            return Response({
                'status': 'unhealthy',
                'message': 'Schema generation failed',
            }, status=500)
    except Exception as e:
        return Response({
            'status': 'unhealthy',
            'error': str(e),
        }, status=500)
```

---

## The Verification

### Step 1: Start the Server

```bash
cd backend
source venv/bin/activate
python manage.py runserver
```

### Step 2: Generate the Schema

```bash
python manage.py spectacular --file schema.json --format json
```

### Step 3: View Swagger UI

Open your browser and go to: http://localhost:8000/api/docs/

You should see:
- ✅ All endpoints listed
- ✅ Authentication configuration
- ✅ Models/schemas
- ✅ Try it out functionality

### Step 4: View ReDoc

Open your browser and go to: http://localhost:8000/api/redoc/

You should see:
- ✅ Clean, organized documentation
- ✅ Authentication section
- ✅ All endpoints with descriptions

### Step 5: Export Documentation

```bash
python manage.py generate_docs --format all --output api_docs
```

Check the `api_docs` folder for:
- ✅ schema.json
- ✅ schema.yaml

### Step 6: Test Swagger Authentication

1. In Swagger UI, click the "Authorize" button
2. Enter your JWT token
3. Make a request to a protected endpoint
4. ✅ Should work with authentication

---

## Key Takeaways

1. **OpenAPI** provides a standard way to document REST APIs.

2. **drf-spectacular** generates OpenAPI schemas from DRF code.

3. **Swagger UI** provides interactive API exploration.

4. **ReDoc** provides clean, readable API documentation.

5. **Schema annotations** improve documentation quality.

6. **Export formats** enable integration with other tools.

7. **Postman collections** can be generated from OpenAPI schemas.

8. **Authentication documentation** helps users get started.

---

## What's Next

In **Part 27**, we'll Dockerize Django:

- Dockerfile for Django
- Docker Compose configuration
- Environment variables
- Development vs production builds

---

**End of Part 26**

*Next: Part 27 - Dockerizing Django*
