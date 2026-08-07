# Primer 8: Flask REST API Design & Best Practices Primer

Welcome to Primer 8! This foundational primer is designed for beginners who want to understand how to design well-structured, maintainable, and user-friendly REST APIs with Flask. Building on the basics from Primers 1-7, you'll learn the principles and best practices that make APIs intuitive, scalable, and professional.

---

## Table of Contents

1. [What Makes a Good API?](#1-what-makes-a-good-api)
2. [RESTful Design Principles](#2-restful-design-principles)
3. [Resource Naming & URL Structure](#3-resource-naming--url-structure)
4. [HTTP Methods & Status Codes](#4-http-methods--status-codes)
5. [Request & Response Formats](#5-request--response-formats)
6. [Error Handling & Validation](#6-error-handling--validation)
7. [API Versioning Strategies](#7-api-versioning-strategies)
8. [API Documentation](#8-api-documentation)
9. [API Security Best Practices](#9-api-security-best-practices)
10. [API Performance Optimization](#10-api-performance-optimization)

---

## 1. What Makes a Good API?

### The User Experience of APIs

```python
# ❌ BAD API: Confusing, inconsistent, hard to use

# GET /getAllUsers
# GET /get_user_by_id/123
# POST /createNewUser
# POST /updateUser/123
# GET /deleteUser/123

# ✅ GOOD API: Consistent, intuitive, predictable

# GET /users
# GET /users/123
# POST /users
# PUT /users/123
# DELETE /users/123
```

### The Golden Rules of API Design

```yaml
1. Intuitive and Consistent:
   - Same patterns throughout
   - Predictable behavior
   - Clear naming

2. Simple and Focused:
   - Do one thing well
   - Minimal complexity
   - Clear purpose

3. Well-Documented:
   - Clear examples
   - All endpoints described
   - Error responses explained

4. Secure:
   - Proper authentication
   - Input validation
   - Rate limiting

5. Performant:
   - Fast responses
   - Efficient queries
   - Proper pagination
```

### API Analogy: A Well-Organized Library

```
A good API is like a well-organized library:

Library = API
- Books = Resources (users, tasks, posts)
- Dewey Decimal System = URL Structure (/users, /tasks)
- Borrowing a Book = GET /books/123
- Adding a Book = POST /books
- Returning a Book = DELETE /books/123
- Finding Books = GET /books?author=tolkien

The librarian (API) always knows where things are
and how to help you find what you need.
```

---

## 2. RESTful Design Principles

### The Six REST Constraints

```python
# 1. Uniform Interface
# - Resources identified in requests
# - Resources manipulated through representations
# - Self-descriptive messages
# - Hypermedia as the engine of application state (HATEOAS)

# 2. Stateless
# - Each request contains all needed information
# - No client state stored on server
# - Session data NOT used in REST APIs

# 3. Cacheable
# - Responses explicitly labeled as cacheable or not
# - Improves performance for repeated requests

# 4. Client-Server
# - Separation of concerns
# - Client handles UI, Server handles data

# 5. Layered System
# - Client doesn't know if it's talking to the end server or a proxy
# - Allows for load balancers, caching layers

# 6. Code on Demand (optional)
# - Server can send executable code to client
# - Rarely used in practice
```

### REST Resource Model

```python
# Resources = Nouns (things)
# /users          → Collection of users
# /users/123      → Single user
# /users/123/tasks → Tasks belonging to user 123
# /tasks/456      → Single task
# /tasks/456/comments → Comments on task 456

# Operations = Verbs (actions) through HTTP methods
# GET     → Read
# POST    → Create
# PUT     → Replace/Update (full)
# PATCH   → Partial Update
# DELETE  → Delete
```

### HATEOAS (Hypermedia as the Engine of Application State)

```python
# HATEOAS - API responses include links to related resources

# ✅ GOOD: HATEOAS Response
{
    "data": {
        "id": 123,
        "title": "Learn Flask API",
        "status": "pending"
    },
    "_links": {
        "self": {
            "href": "/api/tasks/123",
            "method": "GET"
        },
        "update": {
            "href": "/api/tasks/123",
            "method": "PUT"
        },
        "delete": {
            "href": "/api/tasks/123",
            "method": "DELETE"
        },
        "user": {
            "href": "/api/users/456",
            "method": "GET"
        }
    }
}

# Implementation
class HATEOASResponse:
    def __init__(self, data):
        self.data = data
        self.links = []
    
    def add_link(self, rel, href, method='GET', title=None):
        self.links.append({
            'rel': rel,
            'href': href,
            'method': method,
            'title': title
        })
        return self
    
    def to_dict(self):
        return {
            'data': self.data,
            '_links': self.links
        }

@app.route('/api/tasks/<int:task_id>')
def get_task(task_id):
    task = Task.query.get_or_404(task_id)
    
    response = HATEOASResponse(task.to_dict())
    response.add_link('self', url_for('get_task', task_id=task.id))
    response.add_link('update', url_for('update_task', task_id=task.id), method='PUT')
    response.add_link('delete', url_for('delete_task', task_id=task.id), method='DELETE')
    response.add_link('user', url_for('get_user', user_id=task.user_id))
    response.add_link('collection', url_for('list_tasks'))
    
    return jsonify(response.to_dict())
```

---

## 3. Resource Naming & URL Structure

### URL Naming Conventions

```python
# ✅ GOOD: Nouns (resources)
GET    /users
GET    /users/123
POST   /users
PUT    /users/123
DELETE /users/123

# ❌ BAD: Verbs (actions)
GET    /get-users
POST   /create-user
POST   /update-user
POST   /delete-user

# ✅ GOOD: Collection + ID pattern
/users              # Collection
/users/123          # Individual resource
/users/123/tasks    # Nested collection

# ❌ BAD: Inconsistent patterns
/user/123
/users-list
/user-detail/123
```

### Plural vs Singular

```python
# Always use plural for collections

# ✅ GOOD
GET /users
GET /users/123
GET /tasks
GET /tasks/456

# ❌ BAD
GET /user
GET /user/123
GET /task
GET /task/456
```

### Nested Resources

```python
# Nested resources for relationships

# GET /users/123/tasks
# → All tasks belonging to user 123

# GET /tasks/456/comments
# → All comments on task 456

# GET /users/123/tasks/456
# → Task 456 belonging to user 123

# Implementation
@app.route('/api/users/<int:user_id>/tasks')
def get_user_tasks(user_id):
    user = User.query.get_or_404(user_id)
    tasks = Task.query.filter_by(user_id=user_id).all()
    return jsonify([task.to_dict() for task in tasks])

@app.route('/api/tasks/<int:task_id>/comments')
def get_task_comments(task_id):
    task = Task.query.get_or_404(task_id)
    comments = Comment.query.filter_by(task_id=task_id).all()
    return jsonify([comment.to_dict() for comment in comments])
```

### Query Parameters for Filtering

```python
# Use query parameters for filtering, sorting, pagination

# ✅ GOOD
GET /tasks?status=pending
GET /tasks?priority=high
GET /tasks?status=pending&priority=high
GET /tasks?sort=created_at&order=desc
GET /tasks?page=2&per_page=20
GET /tasks?search=flask

# ❌ BAD (don't use for filtering)
GET /tasks/pending
GET /tasks/high-priority
GET /tasks/sort-by-created-at

# Implementation
@app.route('/api/tasks')
def list_tasks():
    # Filtering
    status = request.args.get('status')
    priority = request.args.get('priority')
    
    query = Task.query
    
    if status:
        query = query.filter_by(status=status)
    if priority:
        query = query.filter_by(priority=priority)
    
    # Sorting
    sort_by = request.args.get('sort', 'created_at')
    order = request.args.get('order', 'desc')
    
    if order == 'desc':
        query = query.order_by(getattr(Task, sort_by).desc())
    else:
        query = query.order_by(getattr(Task, sort_by).asc())
    
    # Pagination
    page = request.args.get('page', 1, type=int)
    per_page = request.args.get('per_page', 20, type=int)
    
    paginated = query.paginate(page=page, per_page=per_page)
    
    return jsonify({
        'items': [task.to_dict() for task in paginated.items],
        'pagination': {
            'page': page,
            'per_page': per_page,
            'total': paginated.total,
            'pages': paginated.pages,
            'has_next': paginated.has_next,
            'has_prev': paginated.has_prev
        }
    })
```

---

## 4. HTTP Methods & Status Codes

### HTTP Methods Reference

```python
# GET - Read (safe, idempotent)
# ✅ Returns resource(s)
# ✅ Does not change server state
# ✅ Can be cached

@app.route('/api/users', methods=['GET'])
def list_users():
    users = User.query.all()
    return jsonify([u.to_dict() for u in users])

# POST - Create (unsafe, non-idempotent)
# ✅ Creates new resource
# ✅ Returns 201 Created with location header
# ✅ Body contains new resource data

@app.route('/api/users', methods=['POST'])
def create_user():
    data = request.get_json()
    user = User(**data)
    db.session.add(user)
    db.session.commit()
    
    response = jsonify(user.to_dict())
    response.headers['Location'] = url_for('get_user', user_id=user.id)
    return response, 201

# PUT - Replace/Update (unsafe, idempotent)
# ✅ Replaces entire resource
# ✅ Requires full resource representation
# ✅ Returns 200 or 204

@app.route('/api/users/<int:user_id>', methods=['PUT'])
def update_user(user_id):
    user = User.query.get_or_404(user_id)
    data = request.get_json()
    
    # Replace all fields
    user.username = data['username']
    user.email = data['email']
    db.session.commit()
    
    return jsonify(user.to_dict())

# PATCH - Partial Update (unsafe, non-idempotent)
# ✅ Updates partial resource
# ✅ Only sends changed fields
# ✅ Returns 200

@app.route('/api/users/<int:user_id>', methods=['PATCH'])
def partial_update_user(user_id):
    user = User.query.get_or_404(user_id)
    data = request.get_json()
    
    # Update only provided fields
    for key, value in data.items():
        if hasattr(user, key):
            setattr(user, key, value)
    
    db.session.commit()
    return jsonify(user.to_dict())

# DELETE - Delete (unsafe, idempotent)
# ✅ Removes resource
# ✅ Returns 204 No Content

@app.route('/api/users/<int:user_id>', methods=['DELETE'])
def delete_user(user_id):
    user = User.query.get_or_404(user_id)
    db.session.delete(user)
    db.session.commit()
    return '', 204
```

### HTTP Status Codes Reference

```python
# 2xx Success
# 200 OK                          - Everything worked
# 201 Created                     - Resource created
# 202 Accepted                    - Request accepted, processing async
# 204 No Content                  - Success, no content to return

# 3xx Redirection
# 301 Moved Permanently           - Resource moved permanently
# 302 Found                       - Temporary redirect
# 304 Not Modified                - Cache hit

# 4xx Client Errors
# 400 Bad Request                 - Invalid request
# 401 Unauthorized                - Not authenticated
# 403 Forbidden                   - Not authorized
# 404 Not Found                   - Resource doesn't exist
# 405 Method Not Allowed          - Wrong HTTP method
# 409 Conflict                    - Conflict with existing resource
# 422 Unprocessable Entity        - Validation failed
# 429 Too Many Requests           - Rate limit exceeded

# 5xx Server Errors
# 500 Internal Server Error       - Generic server error
# 502 Bad Gateway                 - Bad gateway/proxy
# 503 Service Unavailable         - Server overloaded

# Usage in Flask
@app.route('/api/tasks', methods=['POST'])
def create_task():
    # 400 Bad Request
    if not request.json or 'title' not in request.json:
        return jsonify({'error': 'Title is required'}), 400
    
    # 201 Created
    task = Task(title=request.json['title'])
    db.session.add(task)
    db.session.commit()
    return jsonify(task.to_dict()), 201

@app.route('/api/tasks/<int:task_id>')
def get_task(task_id):
    # 404 Not Found
    task = Task.query.get(task_id)
    if not task:
        return jsonify({'error': 'Task not found'}), 404
    
    # 200 OK
    return jsonify(task.to_dict())
```

---

## 5. Request & Response Formats

### Consistent JSON Structure

```python
# ✅ GOOD: Consistent response format
{
    "status": "success",
    "data": {
        "id": 123,
        "title": "Learn Flask API"
    },
    "meta": {
        "timestamp": "2024-01-01T00:00:00Z"
    }
}

# ✅ GOOD: Error response format
{
    "status": "error",
    "error": {
        "code": "VALIDATION_ERROR",
        "message": "Invalid input data",
        "details": {
            "title": ["Title is required"]
        }
    }
}

# ✅ GOOD: Paginated response
{
    "status": "success",
    "data": {
        "items": [...],
        "pagination": {
            "page": 1,
            "per_page": 20,
            "total": 100,
            "pages": 5
        }
    }
}

# Implementation
class APIResponse:
    @staticmethod
    def success(data, status_code=200, meta=None):
        response = {
            'status': 'success',
            'data': data
        }
        if meta:
            response['meta'] = meta
        response['meta']['timestamp'] = datetime.utcnow().isoformat()
        return jsonify(response), status_code
    
    @staticmethod
    def error(message, code='UNKNOWN_ERROR', status_code=400, details=None):
        response = {
            'status': 'error',
            'error': {
                'code': code,
                'message': message
            }
        }
        if details:
            response['error']['details'] = details
        return jsonify(response), status_code
    
    @staticmethod
    def paginated(items, pagination):
        return APIResponse.success({
            'items': items,
            'pagination': pagination
        })

# Usage
@app.route('/api/tasks')
def list_tasks():
    tasks = Task.query.all()
    return APIResponse.success([task.to_dict() for task in tasks])

@app.route('/api/tasks', methods=['POST'])
def create_task():
    try:
        task = Task(title=request.json['title'])
        db.session.add(task)
        db.session.commit()
        return APIResponse.success(task.to_dict(), 201)
    except ValidationError as e:
        return APIResponse.error(
            'Invalid input data',
            'VALIDATION_ERROR',
            422,
            e.messages
        )
```

### Content Negotiation

```python
# Support multiple response formats
from flask import request, make_response
import json

@app.route('/api/tasks/<int:task_id>')
def get_task(task_id):
    task = Task.query.get_or_404(task_id)
    
    # Check Accept header
    best_match = request.accept_mimetypes.best_match([
        'application/json',
        'application/xml',
        'text/html'
    ])
    
    if best_match == 'application/xml':
        # Return XML
        xml = f'<task><id>{task.id}</id><title>{task.title}</title></task>'
        response = make_response(xml)
        response.headers['Content-Type'] = 'application/xml'
        return response
    
    elif best_match == 'text/html':
        # Return HTML
        html = f'<h1>{task.title}</h1><p>ID: {task.id}</p>'
        response = make_response(html)
        response.headers['Content-Type'] = 'text/html'
        return response
    
    else:
        # Default to JSON
        return jsonify(task.to_dict())
```

---

## 6. Error Handling & Validation

### Global Error Handling

```python
from werkzeug.exceptions import HTTPException

class APIError(Exception):
    """Custom API error."""
    def __init__(self, message, code='UNKNOWN_ERROR', status_code=400, details=None):
        self.message = message
        self.code = code
        self.status_code = status_code
        self.details = details

@app.errorhandler(APIError)
def handle_api_error(error):
    response = {
        'status': 'error',
        'error': {
            'code': error.code,
            'message': error.message
        }
    }
    if error.details:
        response['error']['details'] = error.details
    return jsonify(response), error.status_code

@app.errorhandler(HTTPException)
def handle_http_error(error):
    response = {
        'status': 'error',
        'error': {
            'code': error.code,
            'message': error.description
        }
    }
    return jsonify(response), error.code

@app.errorhandler(ValidationError)
def handle_validation_error(error):
    return APIResponse.error(
        'Validation failed',
        'VALIDATION_ERROR',
        422,
        error.messages
    )

# Usage
def get_user(user_id):
    user = User.query.get(user_id)
    if not user:
        raise APIError(
            'User not found',
            'RESOURCE_NOT_FOUND',
            404
        )
    return user

@app.route('/api/users/<int:user_id>')
def get_user_api(user_id):
    user = get_user(user_id)
    return APIResponse.success(user.to_dict())
```

### Request Validation

```python
from marshmallow import Schema, fields, validate, ValidationError
from functools import wraps

class TaskSchema(Schema):
    title = fields.Str(
        required=True,
        validate=[
            validate.Length(min=1, max=200)
        ]
    )
    description = fields.Str(allow_none=True)
    priority = fields.Str(
        validate=validate.OneOf(['low', 'medium', 'high', 'urgent'])
    )
    due_date = fields.DateTime(allow_none=True)

def validate_request(schema_class):
    """Decorator for request validation."""
    def decorator(f):
        @wraps(f)
        def decorated(*args, **kwargs):
            schema = schema_class()
            try:
                data = schema.load(request.get_json())
                # Store validated data in request context
                g.validated_data = data
                return f(*args, **kwargs)
            except ValidationError as err:
                return APIResponse.error(
                    'Validation failed',
                    'VALIDATION_ERROR',
                    422,
                    err.messages
                )
            except Exception as e:
                return APIResponse.error(
                    'Invalid request',
                    'INVALID_REQUEST',
                    400
                )
        return decorated
    return decorator

# Usage
@app.route('/api/tasks', methods=['POST'])
@validate_request(TaskSchema)
def create_task():
    data = g.validated_data
    task = Task(**data)
    db.session.add(task)
    db.session.commit()
    return APIResponse.success(task.to_dict(), 201)
```

---

## 7. API Versioning Strategies

### URL Versioning (Recommended)

```python
# Version 1 API
v1_bp = Blueprint('api_v1', __name__, url_prefix='/api/v1')

@v1_bp.route('/tasks')
def v1_list_tasks():
    tasks = Task.query.all()
    return jsonify([{
        'id': t.id,
        'title': t.title,
        'status': t.status
    } for t in tasks])

# Version 2 API (more fields)
v2_bp = Blueprint('api_v2', __name__, url_prefix='/api/v2')

@v2_bp.route('/tasks')
def v2_list_tasks():
    tasks = Task.query.all()
    return jsonify([{
        'id': t.id,
        'title': t.title,
        'description': t.description,
        'status': t.status,
        'priority': t.priority,
        'created_at': t.created_at.isoformat()
    } for t in tasks])

# Register both versions
app.register_blueprint(v1_bp)
app.register_blueprint(v2_bp)

# Default version redirect
@app.route('/api')
def api_root():
    return redirect(url_for('api_v1.root'))
```

### Header Versioning

```python
@app.route('/api/tasks')
def list_tasks():
    version = request.headers.get('API-Version', '1.0')
    
    if version == '2.0':
        return list_tasks_v2()
    elif version == '1.5':
        return list_tasks_v1_5()
    else:
        return list_tasks_v1()

def list_tasks_v1():
    tasks = Task.query.all()
    return jsonify([{
        'id': t.id,
        'title': t.title,
        'status': t.status
    } for t in tasks])

def list_tasks_v2():
    tasks = Task.query.all()
    return jsonify([{
        'id': t.id,
        'title': t.title,
        'description': t.description,
        'status': t.status,
        'priority': t.priority
    } for t in tasks])
```

### Content Negotiation Versioning

```python
@app.route('/api/tasks')
def list_tasks():
    best = request.accept_mimetypes.best_match([
        'application/vnd.taskflow.v1+json',
        'application/vnd.taskflow.v2+json'
    ])
    
    if best == 'application/vnd.taskflow.v2+json':
        return list_tasks_v2()
    else:
        return list_tasks_v1()

# Client request:
# Accept: application/vnd.taskflow.v2+json
```

### Versioning Strategy Comparison

```yaml
URL Versioning:
  Pros: Simple, clear, cache-friendly
  Cons: Changes URLs
  Best For: Public APIs, long-term versions

Header Versioning:
  Pros: Clean URLs, easy to test
  Cons: Requires custom headers
  Best For: Internal APIs

Query Parameter Versioning:
  Pros: Easy to implement
  Cons: Clutters URLs, can be cached incorrectly
  Best For: Temporary testing

Content Negotiation:
  Pros: RESTful, clean
  Cons: Complex, requires header understanding
  Best For: REST purists
```

---

## 8. API Documentation

### OpenAPI/Swagger Setup

```bash
pip install flask-swagger-ui apispec apispec-webframeworks
```

```python
from apispec import APISpec
from apispec.ext.marshmallow import MarshmallowPlugin
from apispec_webframeworks.flask import FlaskPlugin
from flask_swagger_ui import get_swaggerui_blueprint

# Create OpenAPI spec
spec = APISpec(
    title='TaskFlow API',
    version='1.0.0',
    openapi_version='3.0.2',
    plugins=[FlaskPlugin(), MarshmallowPlugin()],
    info={
        'description': 'Task management API',
        'contact': {
            'name': 'TaskFlow Support',
            'email': 'support@taskflow.com'
        }
    }
)

# Define components
spec.components.security_scheme(
    'bearerAuth',
    {
        'type': 'http',
        'scheme': 'bearer',
        'bearerFormat': 'JWT'
    }
)

# Define schemas
task_schema = {
    'type': 'object',
    'properties': {
        'id': {'type': 'integer'},
        'title': {'type': 'string'},
        'status': {'type': 'string', 'enum': ['pending', 'in_progress', 'completed']},
        'priority': {'type': 'string', 'enum': ['low', 'medium', 'high']},
        'created_at': {'type': 'string', 'format': 'date-time'}
    }
}
spec.components.schema('Task', task_schema)

# Define endpoints
spec.path(
    path='/api/tasks',
    operations={
        'get': {
            'summary': 'List tasks',
            'tags': ['Tasks'],
            'security': [{'bearerAuth': []}],
            'responses': {
                '200': {
                    'description': 'List of tasks',
                    'content': {
                        'application/json': {
                            'schema': {
                                'type': 'array',
                                'items': {'$ref': '#/components/schemas/Task'}
                            }
                        }
                    }
                }
            }
        }
    }
)

# Swagger UI
SWAGGER_URL = '/api/docs'
API_URL = '/api/docs/spec.json'

swagger_ui_blueprint = get_swaggerui_blueprint(
    SWAGGER_URL,
    API_URL,
    config={
        'app_name': 'TaskFlow API'
    }
)
app.register_blueprint(swagger_ui_blueprint, url_prefix=SWAGGER_URL)

@app.route('/api/docs/spec.json')
def api_spec():
    return jsonify(spec.to_dict())
```

### Manual Documentation

```python
@app.route('/api/docs')
def api_documentation():
    return render_template('api_docs.html')

# templates/api_docs.html
"""
<!DOCTYPE html>
<html>
<head>
    <title>TaskFlow API Documentation</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
    <div class="container mt-5">
        <h1>TaskFlow API Documentation</h1>
        
        <h2>Authentication</h2>
        <p>All API requests require authentication.</p>
        <pre>Authorization: Bearer &lt;token&gt;</pre>
        
        <h2>Endpoints</h2>
        
        <h3>GET /api/tasks</h3>
        <p>List all tasks</p>
        <pre>GET /api/tasks?status=pending</pre>
        <p>Response:</p>
        <pre>{
    "tasks": [
        {
            "id": 1,
            "title": "Learn Flask",
            "status": "pending"
        }
    ]
}</pre>
        
        <h3>POST /api/tasks</h3>
        <p>Create a new task</p>
        <pre>POST /api/tasks
{
    "title": "Learn Flask API",
    "description": "Complete the tutorial",
    "priority": "high"
}</pre>
        
        <h3>PUT /api/tasks/{id}</h3>
        <p>Update a task</p>
        <pre>PUT /api/tasks/1
{
    "title": "Updated title",
    "status": "completed"
}</pre>
        
        <h3>DELETE /api/tasks/{id}</h3>
        <p>Delete a task</p>
        <pre>DELETE /api/tasks/1</pre>
    </div>
</body>
</html>
"""
```

---

## 9. API Security Best Practices

### Comprehensive API Security

```python
from flask_jwt_extended import JWTManager, jwt_required, get_jwt_identity
from flask_limiter import Limiter
from flask_limiter.util import get_remote_address

# JWT Setup
app.config['JWT_SECRET_KEY'] = os.environ.get('JWT_SECRET_KEY')
app.config['JWT_ACCESS_TOKEN_EXPIRES'] = timedelta(hours=1)
jwt = JWTManager(app)

# Rate Limiting
limiter = Limiter(app, key_func=get_remote_address)

# Custom Rate Limiting by user
def get_user_limit_key():
    if hasattr(g, 'user_id'):
        return f"user:{g.user_id}"
    return get_remote_address()

@app.route('/api/tasks', methods=['GET'])
@jwt_required()
@limiter.limit("100 per minute", key_func=get_user_limit_key)
def api_get_tasks():
    user_id = get_jwt_identity()
    tasks = Task.query.filter_by(user_id=user_id).all()
    return jsonify([task.to_dict() for task in tasks])

@app.route('/api/tasks', methods=['POST'])
@jwt_required()
@limiter.limit("30 per minute", key_func=get_user_limit_key)
def api_create_task():
    user_id = get_jwt_identity()
    data = request.get_json()
    task = Task(**data, user_id=user_id)
    db.session.add(task)
    db.session.commit()
    return jsonify(task.to_dict()), 201

# Input Validation
@app.route('/api/tasks', methods=['POST'])
@jwt_required()
@validate_request(TaskSchema)
@limiter.limit("30 per minute")
def api_create_task_with_validation():
    user_id = get_jwt_identity()
    data = g.validated_data
    task = Task(**data, user_id=user_id)
    db.session.add(task)
    db.session.commit()
    return jsonify(task.to_dict()), 201

# SQL Injection Prevention
# Always use parameterized queries!

# XSS Prevention
# Sanitize output, use jsonify for JSON responses

# CORS Configuration
from flask_cors import CORS

# ❌ BAD: Allow everything
# CORS(app)

# ✅ GOOD: Restrict origins
CORS(app, origins=['https://myapp.com', 'https://app.myapp.com'])
```

### API Key Authentication

```python
class APIKeyManager:
    """API Key management."""
    
    @staticmethod
    def generate_key():
        return secrets.token_urlsafe(32)
    
    @staticmethod
    def verify_key(api_key):
        key = APIKey.query.filter_by(
            key=api_key,
            is_active=True
        ).first()
        
        if key:
            # Update last used
            key.last_used = datetime.utcnow()
            db.session.commit()
            return key.user_id
        return None

def api_key_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        api_key = request.headers.get('X-API-Key')
        
        if not api_key:
            return APIResponse.error('API key required', 'API_KEY_REQUIRED', 401)
        
        user_id = APIKeyManager.verify_key(api_key)
        if not user_id:
            return APIResponse.error('Invalid API key', 'INVALID_API_KEY', 401)
        
        g.user_id = user_id
        return f(*args, **kwargs)
    return decorated

@app.route('/api/secure', methods=['GET'])
@api_key_required
def secure_endpoint():
    return APIResponse.success({'message': 'Access granted'})
```

---

## 10. API Performance Optimization

### Database Optimization

```python
# 1. Eager Loading (avoid N+1 queries)
# ❌ BAD: N+1 queries
@app.route('/api/tasks')
def list_tasks():
    tasks = Task.query.all()
    return jsonify([{
        'title': task.title,
        'username': task.user.username  # N+1 query!
    } for task in tasks])

# ✅ GOOD: Eager loading
@app.route('/api/tasks')
def list_tasks():
    tasks = Task.query.options(joinedload(Task.user)).all()
    return jsonify([{
        'title': task.title,
        'username': task.user.username  # No additional query
    } for task in tasks])

# 2. Pagination (don't return everything)
@app.route('/api/tasks')
def list_tasks():
    page = request.args.get('page', 1, type=int)
    per_page = request.args.get('per_page', 20, type=int)
    
    paginated = Task.query.paginate(page=page, per_page=per_page)
    return APIResponse.paginated(
        [t.to_dict() for t in paginated.items],
        {
            'page': page,
            'per_page': per_page,
            'total': paginated.total,
            'pages': paginated.pages
        }
    )
```

### Response Caching

```python
from flask_caching import Cache

cache = Cache(app, config={
    'CACHE_TYPE': 'redis',
    'CACHE_REDIS_URL': 'redis://localhost:6379/0'
})

@app.route('/api/tasks')
@cache.cached(timeout=60, query_string=True)  # Cache for 60 seconds
def list_tasks():
    tasks = Task.query.all()
    return jsonify([task.to_dict() for task in tasks])

# Cache invalidation on updates
@app.route('/api/tasks', methods=['POST'])
def create_task():
    task = Task(title=request.json['title'])
    db.session.add(task)
    db.session.commit()
    
    # Invalidate cache
    cache.delete('list_tasks')
    
    return jsonify(task.to_dict()), 201

# Conditional GET (ETag)
from hashlib import md5

@app.route('/api/tasks/<int:task_id>')
def get_task(task_id):
    task = Task.query.get_or_404(task_id)
    
    # Generate ETag from data
    data = task.to_dict()
    etag = md5(json.dumps(data, sort_keys=True).encode()).hexdigest()
    
    # Check If-None-Match header
    if request.headers.get('If-None-Match') == etag:
        return '', 304
    
    response = jsonify(data)
    response.headers['ETag'] = etag
    return response
```

### Compression

```python
from flask_compress import Compress

compress = Compress()
compress.init_app(app)

app.config['COMPRESS_MIMETYPES'] = [
    'application/json',
    'text/html',
    'text/css',
    'text/javascript'
]

# Large responses automatically compressed
```

---

## Summary

This primer has introduced you to REST API design best practices:

1. **Good APIs**: Intuitive, consistent, well-documented
2. **REST Principles**: Resources, stateless, cacheable
3. **URL Structure**: Nouns, plural, nested resources
4. **HTTP Methods**: GET, POST, PUT, PATCH, DELETE
5. **Response Formats**: Consistent JSON structure
6. **Error Handling**: Clear error responses, proper status codes
7. **Versioning**: URL versioning, header versioning
8. **Documentation**: Swagger, OpenAPI, manual docs
9. **Security**: Authentication, rate limiting, validation
10. **Performance**: Optimization, caching, compression

### API Design Quick Reference

```yaml
URL Patterns:
  GET    /resources
  GET    /resources/{id}
  POST   /resources
  PUT    /resources/{id}
  PATCH  /resources/{id}
  DELETE /resources/{id}

Status Codes:
  200: Success
  201: Created
  400: Bad Request
  401: Unauthorized
  403: Forbidden
  404: Not Found
  500: Server Error

Response Format:
  {
    "status": "success|error",
    "data": {...},
    "meta": {...}
  }

Error Format:
  {
    "status": "error",
    "error": {
      "code": "ERROR_CODE",
      "message": "Error message",
      "details": {...}
    }
  }
```

**Next Steps**:
- Design your API before coding
- Document all endpoints
- Implement consistent error handling
- Add authentication and rate limiting
- Test your API thoroughly
- Monitor API performance
