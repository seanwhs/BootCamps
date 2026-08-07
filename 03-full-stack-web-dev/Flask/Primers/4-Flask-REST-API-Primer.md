# Primer 4: Flask REST API Primer

Welcome to Primer 4! This foundational primer is designed for beginners who want to understand how to build REST APIs with Flask. Building on the basics from Primers 1-3, you'll learn how to create APIs that allow other applications to interact with your Flask application programmatically.

---

## Table of Contents

1. [What is a REST API?](#1-what-is-a-rest-api)
2. [Understanding HTTP Methods](#2-understanding-http-methods)
3. [Setting Up Your First API](#3-setting-up-your-first-api)
4. [Working with JSON](#4-working-with-json)
5. [API Routes & Endpoints](#5-api-routes--endpoints)
6. [Request & Response Handling](#6-request--response-handling)
7. [API Authentication](#7-api-authentication)
8. [Error Handling](#8-error-handling)
9. [API Versioning](#9-api-versioning)
10. [Testing Your API](#10-testing-your-api)

---

## 1. What is a REST API?

### Understanding APIs

**API** = Application Programming Interface. It's like a menu at a restaurant:

```
Restaurant Menu (API):
- What you can order (endpoints)
- How to order it (HTTP methods)
- What you'll get (responses)

Without API: You must go into the kitchen
With API: You order from the menu
```

### What Makes an API "RESTful"?

**REST** = Representational State Transfer. Key principles:

```
1. Resources (nouns, not verbs)
   ✅ /users     (good)
   ✅ /tasks     (good)
   ❌ /getUsers  (bad)

2. HTTP Methods (verbs)
   GET    → Read
   POST   → Create
   PUT    → Update (full)
   PATCH  → Update (partial)
   DELETE → Delete

3. Stateless
   - Each request contains all needed info
   - No session data stored on server

4. Standard Response Formats
   - Usually JSON
   - Consistent structure
```

### API Analogy: The Library

```
Library Catalog System = REST API

- Books = Resources (users, tasks, posts)
- ISBN = Resource ID (/books/123)
- Search = GET /books?author=tolkien
- Borrow = POST /books/123/borrow
- Return = DELETE /books/123/borrow
- Catalog = GET /books
```

### Flask vs Flask-RESTful

```python
# Basic Flask (you build everything)
from flask import Flask, jsonify, request

@app.route('/api/users', methods=['GET'])
def get_users():
    users = User.query.all()
    return jsonify([u.to_dict() for u in users])

@app.route('/api/users', methods=['POST'])
def create_user():
    data = request.get_json()
    user = User(username=data['username'])
    db.session.add(user)
    db.session.commit()
    return jsonify(user.to_dict()), 201

# Flask-RESTful (more structured)
from flask_restful import Api, Resource

api = Api(app)

class UserResource(Resource):
    def get(self):
        users = User.query.all()
        return [u.to_dict() for u in users]
    
    def post(self):
        data = request.get_json()
        user = User(username=data['username'])
        db.session.add(user)
        db.session.commit()
        return user.to_dict(), 201

api.add_resource(UserResource, '/api/users')
```

---

## 2. Understanding HTTP Methods

### The Five Main HTTP Methods

```python
# GET - Read data
# Like: "Show me the menu"
@app.route('/api/tasks', methods=['GET'])
def get_tasks():
    tasks = Task.query.all()
    return jsonify([task.to_dict() for task in tasks])

# POST - Create data
# Like: "I'd like to order this"
@app.route('/api/tasks', methods=['POST'])
def create_task():
    data = request.get_json()
    task = Task(title=data['title'])
    db.session.add(task)
    db.session.commit()
    return jsonify(task.to_dict()), 201

# PUT - Update (replace everything)
# Like: "Change my entire order"
@app.route('/api/tasks/<int:task_id>', methods=['PUT'])
def update_task(task_id):
    task = Task.query.get_or_404(task_id)
    data = request.get_json()
    task.title = data['title']
    task.description = data['description']
    db.session.commit()
    return jsonify(task.to_dict())

# PATCH - Update (partial)
# Like: "Change just the drink in my order"
@app.route('/api/tasks/<int:task_id>', methods=['PATCH'])
def patch_task(task_id):
    task = Task.query.get_or_404(task_id)
    data = request.get_json()
    if 'title' in data:
        task.title = data['title']
    if 'description' in data:
        task.description = data['description']
    db.session.commit()
    return jsonify(task.to_dict())

# DELETE - Remove
# Like: "Cancel my order"
@app.route('/api/tasks/<int:task_id>', methods=['DELETE'])
def delete_task(task_id):
    task = Task.query.get_or_404(task_id)
    db.session.delete(task)
    db.session.commit()
    return '', 204
```

### HTTP Status Codes

```python
# Success Codes (2xx)
200 OK                      # Everything worked
201 Created                 # New resource created
204 No Content              # Successful but nothing to return

# Client Error Codes (4xx)
400 Bad Request             # Invalid request
401 Unauthorized            # Not authenticated
403 Forbidden               # Not authorized
404 Not Found               # Resource doesn't exist
405 Method Not Allowed      # Wrong HTTP method
422 Unprocessable Entity    # Validation failed

# Server Error Codes (5xx)
500 Internal Server Error   # Server error
502 Bad Gateway             # Server is down
503 Service Unavailable     # Server overloaded

# Usage in Flask
@app.route('/api/users/<int:user_id>')
def get_user(user_id):
    user = User.query.get(user_id)
    if not user:
        return jsonify({'error': 'User not found'}), 404
    
    return jsonify(user.to_dict()), 200
```

---

## 3. Setting Up Your First API

### Basic API Setup

```python
# app.py - First API

from flask import Flask, jsonify, request
from flask_sqlalchemy import SQLAlchemy
from datetime import datetime

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///api.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

db = SQLAlchemy(app)

# Model
class Task(db.Model):
    __tablename__ = 'tasks'
    
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(200), nullable=False)
    completed = db.Column(db.Boolean, default=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    def to_dict(self):
        return {
            'id': self.id,
            'title': self.title,
            'completed': self.completed,
            'created_at': self.created_at.isoformat()
        }

# API Routes
@app.route('/api/tasks', methods=['GET'])
def get_tasks():
    tasks = Task.query.all()
    return jsonify([task.to_dict() for task in tasks])

@app.route('/api/tasks', methods=['POST'])
def create_task():
    data = request.get_json()
    
    if not data or 'title' not in data:
        return jsonify({'error': 'Title is required'}), 400
    
    task = Task(title=data['title'])
    db.session.add(task)
    db.session.commit()
    
    return jsonify(task.to_dict()), 201

@app.route('/api/tasks/<int:task_id>', methods=['GET'])
def get_task(task_id):
    task = Task.query.get(task_id)
    if not task:
        return jsonify({'error': 'Task not found'}), 404
    return jsonify(task.to_dict())

@app.route('/api/tasks/<int:task_id>', methods=['PUT'])
def update_task(task_id):
    task = Task.query.get(task_id)
    if not task:
        return jsonify({'error': 'Task not found'}), 404
    
    data = request.get_json()
    if 'title' in data:
        task.title = data['title']
    if 'completed' in data:
        task.completed = data['completed']
    
    db.session.commit()
    return jsonify(task.to_dict())

@app.route('/api/tasks/<int:task_id>', methods=['DELETE'])
def delete_task(task_id):
    task = Task.query.get(task_id)
    if not task:
        return jsonify({'error': 'Task not found'}), 404
    
    db.session.delete(task)
    db.session.commit()
    return '', 204

if __name__ == '__main__':
    with app.app_context():
        db.create_all()
    app.run(debug=True)
```

### Testing with curl

```bash
# Create database
python app.py

# In another terminal:

# GET all tasks
curl http://localhost:5000/api/tasks

# POST new task
curl -X POST http://localhost:5000/api/tasks \
  -H "Content-Type: application/json" \
  -d '{"title": "Learn Flask API"}'

# GET specific task
curl http://localhost:5000/api/tasks/1

# PUT update task
curl -X PUT http://localhost:5000/api/tasks/1 \
  -H "Content-Type: application/json" \
  -d '{"title": "Learn Flask API", "completed": true}'

# DELETE task
curl -X DELETE http://localhost:5000/api/tasks/1
```

### Using Flask-RESTful

```bash
pip install flask-restful
```

```python
# app_restful.py - Using Flask-RESTful

from flask import Flask, request
from flask_restful import Api, Resource, reqparse, fields, marshal_with
from flask_sqlalchemy import SQLAlchemy

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///api.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

db = SQLAlchemy(app)
api = Api(app)

class Task(db.Model):
    __tablename__ = 'tasks'
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(200), nullable=False)
    completed = db.Column(db.Boolean, default=False)

# Response formatting
task_fields = {
    'id': fields.Integer,
    'title': fields.String,
    'completed': fields.Boolean
}

# Request parsing
task_parser = reqparse.RequestParser()
task_parser.add_argument('title', type=str, required=True, help='Title is required')
task_parser.add_argument('completed', type=bool)

class TaskResource(Resource):
    @marshal_with(task_fields)
    def get(self, task_id):
        task = Task.query.get(task_id)
        if not task:
            return {'error': 'Task not found'}, 404
        return task
    
    @marshal_with(task_fields)
    def put(self, task_id):
        task = Task.query.get(task_id)
        if not task:
            return {'error': 'Task not found'}, 404
        
        args = task_parser.parse_args()
        task.title = args['title']
        if args['completed'] is not None:
            task.completed = args['completed']
        db.session.commit()
        return task
    
    def delete(self, task_id):
        task = Task.query.get(task_id)
        if not task:
            return {'error': 'Task not found'}, 404
        db.session.delete(task)
        db.session.commit()
        return '', 204

class TaskListResource(Resource):
    @marshal_with(task_fields)
    def get(self):
        tasks = Task.query.all()
        return tasks
    
    @marshal_with(task_fields)
    def post(self):
        args = task_parser.parse_args()
        task = Task(title=args['title'])
        db.session.add(task)
        db.session.commit()
        return task, 201

api.add_resource(TaskListResource, '/api/tasks')
api.add_resource(TaskResource, '/api/tasks/<int:task_id>')

if __name__ == '__main__':
    with app.app_context():
        db.create_all()
    app.run(debug=True)
```

---

## 4. Working with JSON

### What is JSON?

JSON = JavaScript Object Notation. It's like a universal language for data:

```python
# Python Dictionary
user = {
    'id': 1,
    'username': 'john',
    'email': 'john@example.com',
    'is_active': True
}

# Same data as JSON
{
    "id": 1,
    "username": "john",
    "email": "john@example.com",
    "is_active": true
}

# JSON is text, but it looks like Python!
# JSON uses double quotes, Python uses single or double
```

### JSON vs XML

```python
# JSON (Modern, lighter)
{
    "user": {
        "id": 1,
        "name": "John"
    }
}

# XML (Older, heavier)
<user>
    <id>1</id>
    <name>John</name>
</user>
```

### Working with JSON in Flask

```python
from flask import jsonify, request

# Returning JSON
@app.route('/api/user')
def get_user():
    user = {'id': 1, 'name': 'John'}
    
    # Method 1: jsonify (recommended)
    return jsonify(user)
    
    # Method 2: Flask automatically converts dicts
    # return user  # Works if you use flask.json (not always)

# Receiving JSON
@app.route('/api/user', methods=['POST'])
def create_user():
    # Get JSON from request body
    data = request.get_json()
    
    if not data:
        return jsonify({'error': 'No JSON provided'}), 400
    
    name = data.get('name')
    email = data.get('email')
    
    # Process data...
    return jsonify({'message': 'User created'}), 201
```

### Serializing Models to JSON

```python
# Manual serialization
class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(50))
    email = db.Column(db.String(120))
    created_at = db.Column(db.DateTime)
    
    def to_dict(self):
        return {
            'id': self.id,
            'username': self.username,
            'email': self.email,
            'created_at': self.created_at.isoformat() if self.created_at else None
        }

# Usage
@app.route('/api/users')
def get_users():
    users = User.query.all()
    return jsonify([user.to_dict() for user in users])

# Using marshmallow (more powerful)
from marshmallow import Schema, fields

class UserSchema(Schema):
    id = fields.Integer()
    username = fields.String()
    email = fields.String()
    created_at = fields.DateTime(format='iso')

user_schema = UserSchema()
users_schema = UserSchema(many=True)

@app.route('/api/users')
def get_users():
    users = User.query.all()
    return jsonify(users_schema.dump(users))
```

### JSON Response Patterns

```python
# ✅ Good: Consistent response format

# Success Response
{
    "status": "success",
    "data": {
        "id": 1,
        "name": "John"
    }
}

# Error Response
{
    "status": "error",
    "message": "User not found",
    "code": 404
}

# List Response
{
    "status": "success",
    "data": {
        "items": [...],
        "total": 100,
        "page": 1,
        "pages": 10
    }
}

# Implementation
def success_response(data, status_code=200):
    return jsonify({
        'status': 'success',
        'data': data
    }), status_code

def error_response(message, code=400):
    return jsonify({
        'status': 'error',
        'message': message,
        'code': code
    }), code

# Usage
@app.route('/api/users/<int:user_id>')
def get_user(user_id):
    user = User.query.get(user_id)
    if not user:
        return error_response('User not found', 404)
    return success_response(user.to_dict())
```

---

## 5. API Routes & Endpoints

### Resource Naming

```python
# ✅ Good RESTful naming (nouns)
/api/users
/api/tasks
/api/comments
/api/users/1/tasks

# ❌ Bad naming (verbs)
/api/getUsers
/api/createTask
/api/deleteComment

# ✅ Nested resources
/api/users/1/tasks           # Tasks belonging to user 1
/api/tasks/1/comments        # Comments on task 1

# ✅ Query parameters for filtering
/api/tasks?status=pending
/api/users?role=admin
```

### Complete REST Endpoint Structure

```python
# User endpoints

# GET /api/users
# GET /api/users?page=1&limit=10
# POST /api/users
# GET /api/users/1
# PUT /api/users/1
# DELETE /api/users/1
# GET /api/users/1/tasks

# Implementation
@app.route('/api/users', methods=['GET'])
def list_users():
    page = request.args.get('page', 1, type=int)
    limit = request.args.get('limit', 20, type=int)
    
    users = User.query.paginate(page=page, per_page=limit)
    
    return jsonify({
        'items': [u.to_dict() for u in users.items],
        'total': users.total,
        'page': page,
        'pages': users.pages
    })

@app.route('/api/users', methods=['POST'])
def create_user():
    data = request.get_json()
    user = User(username=data['username'], email=data['email'])
    db.session.add(user)
    db.session.commit()
    return jsonify(user.to_dict()), 201

@app.route('/api/users/<int:user_id>', methods=['GET'])
def get_user(user_id):
    user = User.query.get_or_404(user_id)
    return jsonify(user.to_dict())

@app.route('/api/users/<int:user_id>', methods=['PUT'])
def update_user(user_id):
    user = User.query.get_or_404(user_id)
    data = request.get_json()
    user.username = data.get('username', user.username)
    user.email = data.get('email', user.email)
    db.session.commit()
    return jsonify(user.to_dict())

@app.route('/api/users/<int:user_id>', methods=['DELETE'])
def delete_user(user_id):
    user = User.query.get_or_404(user_id)
    db.session.delete(user)
    db.session.commit()
    return '', 204

@app.route('/api/users/<int:user_id>/tasks', methods=['GET'])
def get_user_tasks(user_id):
    user = User.query.get_or_404(user_id)
    tasks = user.tasks.all()
    return jsonify([t.to_dict() for t in tasks])
```

### Route Organization

```python
# Organize API routes with Blueprints
from flask import Blueprint

api_bp = Blueprint('api', __name__, url_prefix='/api')

@api_bp.route('/users')
def list_users():
    # ... implementation
    pass

@api_bp.route('/tasks')
def list_tasks():
    # ... implementation
    pass

# Register blueprint
app.register_blueprint(api_bp)

# Versioned APIs
v1_bp = Blueprint('api_v1', __name__, url_prefix='/api/v1')
v2_bp = Blueprint('api_v2', __name__, url_prefix='/api/v2')

app.register_blueprint(v1_bp)
app.register_blueprint(v2_bp)
```

---

## 6. Request & Response Handling

### Accessing Request Data

```python
from flask import request

# Query Parameters (URL)
# GET /api/tasks?status=pending&page=2
status = request.args.get('status')
page = request.args.get('page', 1, type=int)

# Path Parameters
# GET /api/tasks/123
@app.route('/api/tasks/<int:task_id>')
def get_task(task_id):
    # task_id comes from URL
    pass

# Request Body (JSON)
# POST /api/tasks with {"title": "New Task"}
data = request.get_json()
title = data.get('title')

# Form Data (traditional forms)
# POST /api/tasks with title=New+Task
title = request.form.get('title')

# Headers
auth_token = request.headers.get('Authorization')
content_type = request.headers.get('Content-Type')
```

### Response Formats

```python
# JSON Response
@app.route('/api/data')
def json_response():
    return jsonify({'message': 'Hello'})

# Status Code
@app.route('/api/create')
def create():
    return jsonify({'id': 1}), 201  # Created

# Custom Headers
@app.route('/api/response')
def custom_response():
    response = jsonify({'message': 'Hello'})
    response.headers['X-Custom-Header'] = 'Value'
    response.status_code = 202
    return response

# File Response
@app.route('/api/download')
def download():
    return send_file('report.pdf', as_attachment=True)

# Stream Response (for large data)
@app.route('/api/stream')
def stream():
    def generate():
        for i in range(100):
            yield f"data: {i}\n\n"
    return Response(stream_with_context(generate()), mimetype='text/event-stream')
```

### Request Validation

```python
from marshmallow import Schema, fields, validate, ValidationError

class TaskSchema(Schema):
    title = fields.String(required=True, validate=validate.Length(min=1, max=200))
    description = fields.String(allow_none=True)
    priority = fields.String(validate=validate.OneOf(['low', 'medium', 'high']))
    due_date = fields.DateTime(allow_none=True)

task_schema = TaskSchema()

@app.route('/api/tasks', methods=['POST'])
def create_task():
    try:
        # Validate request data
        data = task_schema.load(request.get_json())
    except ValidationError as err:
        return jsonify({'errors': err.messages}), 400
    
    # Data is valid
    task = Task(**data)
    db.session.add(task)
    db.session.commit()
    return jsonify(task.to_dict()), 201

# Custom validation
def validate_task_data(data):
    errors = {}
    
    if not data.get('title'):
        errors['title'] = ['Title is required']
    
    if len(data.get('title', '')) < 3:
        errors['title'] = ['Title must be at least 3 characters']
    
    if data.get('priority') not in ['low', 'medium', 'high']:
        errors['priority'] = ['Invalid priority value']
    
    return errors

@app.route('/api/tasks', methods=['POST'])
def create_task():
    data = request.get_json()
    errors = validate_task_data(data)
    
    if errors:
        return jsonify({'errors': errors}), 400
    
    task = Task(**data)
    db.session.add(task)
    db.session.commit()
    return jsonify(task.to_dict()), 201
```

---

## 7. API Authentication

### Token-Based Authentication

```python
import secrets
from functools import wraps
from flask import request, jsonify

# Simple token authentication
API_TOKENS = {
    'secret-token-123': 'user1',
    'secret-token-456': 'user2'
}

def token_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        token = request.headers.get('Authorization')
        
        if not token:
            return jsonify({'error': 'Token required'}), 401
        
        # Remove 'Bearer ' prefix if present
        if token.startswith('Bearer '):
            token = token[7:]
        
        if token not in API_TOKENS:
            return jsonify({'error': 'Invalid token'}), 401
        
        # Set current user
        g.user_id = API_TOKENS[token]
        return f(*args, **kwargs)
    return decorated

@app.route('/api/secure')
@token_required
def secure_endpoint():
    return jsonify({'message': 'You have access!'})

# Usage
curl -H "Authorization: Bearer secret-token-123" http://localhost:5000/api/secure
```

### JWT Authentication

```bash
pip install pyjwt
```

```python
import jwt
from datetime import datetime, timedelta
from flask import request, jsonify

SECRET_KEY = 'your-secret-key'

def generate_token(user_id):
    """Generate JWT token."""
    payload = {
        'user_id': user_id,
        'exp': datetime.utcnow() + timedelta(hours=1),
        'iat': datetime.utcnow()
    }
    return jwt.encode(payload, SECRET_KEY, algorithm='HS256')

def verify_token(token):
    """Verify JWT token."""
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=['HS256'])
        return payload['user_id']
    except jwt.ExpiredSignatureError:
        return None
    except jwt.InvalidTokenError:
        return None

@app.route('/api/login', methods=['POST'])
def login():
    data = request.get_json()
    username = data.get('username')
    password = data.get('password')
    
    user = User.query.filter_by(username=username).first()
    
    if not user or not user.check_password(password):
        return jsonify({'error': 'Invalid credentials'}), 401
    
    token = generate_token(user.id)
    return jsonify({'token': token})

def jwt_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        token = request.headers.get('Authorization')
        
        if not token:
            return jsonify({'error': 'Token required'}), 401
        
        if token.startswith('Bearer '):
            token = token[7:]
        
        user_id = verify_token(token)
        
        if not user_id:
            return jsonify({'error': 'Invalid or expired token'}), 401
        
        g.user_id = user_id
        return f(*args, **kwargs)
    return decorated

@app.route('/api/protected')
@jwt_required
def protected():
    return jsonify({'message': f'Hello user {g.user_id}'})
```

### API Key Authentication

```python
class APIKey(db.Model):
    __tablename__ = 'api_keys'
    
    id = db.Column(db.Integer, primary_key=True)
    key = db.Column(db.String(64), unique=True, nullable=False)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'))
    name = db.Column(db.String(100))
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    last_used = db.Column(db.DateTime)
    is_active = db.Column(db.Boolean, default=True)

def generate_api_key():
    """Generate a secure API key."""
    return secrets.token_urlsafe(32)

def api_key_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        api_key = request.headers.get('X-API-Key')
        
        if not api_key:
            return jsonify({'error': 'API key required'}), 401
        
        key = APIKey.query.filter_by(key=api_key, is_active=True).first()
        
        if not key:
            return jsonify({'error': 'Invalid API key'}), 401
        
        # Update last used
        key.last_used = datetime.utcnow()
        db.session.commit()
        
        g.user = User.query.get(key.user_id)
        return f(*args, **kwargs)
    return decorated

@app.route('/api/create-key', methods=['POST'])
def create_api_key():
    """Create a new API key."""
    name = request.json.get('name')
    
    key = APIKey(
        key=generate_api_key(),
        user_id=current_user.id,
        name=name
    )
    db.session.add(key)
    db.session.commit()
    
    return jsonify({
        'key': key.key,
        'name': key.name
    })
```

---

## 8. Error Handling

### Consistent Error Responses

```python
class APIError(Exception):
    """Custom API exception."""
    
    def __init__(self, message, status_code=400, payload=None):
        self.message = message
        self.status_code = status_code
        self.payload = payload
    
    def to_dict(self):
        result = {
            'error': self.message,
            'status_code': self.status_code
        }
        if self.payload:
            result['payload'] = self.payload
        return result

@app.errorhandler(APIError)
def handle_api_error(error):
    response = jsonify(error.to_dict())
    response.status_code = error.status_code
    return response

# Usage
@app.route('/api/tasks/<int:task_id>')
def get_task(task_id):
    task = Task.query.get(task_id)
    if not task:
        raise APIError('Task not found', 404)
    return jsonify(task.to_dict())

# Global error handlers
@app.errorhandler(404)
def not_found(error):
    return jsonify({'error': 'Resource not found'}), 404

@app.errorhandler(405)
def method_not_allowed(error):
    return jsonify({'error': 'Method not allowed'}), 405

@app.errorhandler(500)
def internal_error(error):
    return jsonify({'error': 'Internal server error'}), 500

@app.errorhandler(ValidationError)
def validation_error(error):
    return jsonify({'errors': error.messages}), 422
```

### Validation Error Responses

```python
# Structured validation errors
@app.route('/api/tasks', methods=['POST'])
def create_task():
    data = request.get_json()
    errors = {}
    
    # Validate title
    if not data.get('title'):
        errors['title'] = ['Title is required']
    elif len(data['title']) < 3:
        errors['title'] = ['Title must be at least 3 characters']
    
    # Validate priority
    if data.get('priority') not in ['low', 'medium', 'high']:
        errors['priority'] = ['Invalid priority. Must be low, medium, or high']
    
    if errors:
        return jsonify({
            'error': 'Validation failed',
            'details': errors
        }), 422
    
    # Create task...
    return jsonify(task.to_dict()), 201

# Response:
{
    "error": "Validation failed",
    "details": {
        "title": ["Title must be at least 3 characters"],
        "priority": ["Invalid priority"]
    }
}
```

---

## 9. API Versioning

### URL Versioning

```python
# Version 1 API
@v1_bp.route('/tasks')
def v1_tasks():
    tasks = Task.query.all()
    return jsonify([{
        'id': t.id,
        'title': t.title,
        'status': t.status
    } for t in tasks])

# Version 2 API (more fields)
@v2_bp.route('/tasks')
def v2_tasks():
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
app.register_blueprint(v1_bp, url_prefix='/api/v1')
app.register_blueprint(v2_bp, url_prefix='/api/v2')
```

### Header Versioning

```python
@app.route('/api/tasks')
def get_tasks():
    version = request.headers.get('API-Version', '1.0')
    
    if version == '2.0':
        return get_tasks_v2()
    else:
        return get_tasks_v1()

def get_tasks_v1():
    tasks = Task.query.all()
    return jsonify([{
        'id': t.id,
        'title': t.title
    } for t in tasks])

def get_tasks_v2():
    tasks = Task.query.all()
    return jsonify([{
        'id': t.id,
        'title': t.title,
        'description': t.description,
        'status': t.status
    } for t in tasks])
```

### Content Negotiation Versioning

```python
@app.route('/api/tasks')
def get_tasks():
    best = request.accept_mimetypes.best_match([
        'application/vnd.taskflow.v1+json',
        'application/vnd.taskflow.v2+json'
    ])
    
    if best == 'application/vnd.taskflow.v2+json':
        return get_tasks_v2()
    else:
        return get_tasks_v1()
```

---

## 10. Testing Your API

### Manual Testing with curl

```bash
# GET request
curl http://localhost:5000/api/tasks

# POST with JSON
curl -X POST http://localhost:5000/api/tasks \
  -H "Content-Type: application/json" \
  -d '{"title": "Test Task"}'

# GET specific
curl http://localhost:5000/api/tasks/1

# PUT update
curl -X PUT http://localhost:5000/api/tasks/1 \
  -H "Content-Type: application/json" \
  -d '{"title": "Updated Task", "completed": true}'

# DELETE
curl -X DELETE http://localhost:5000/api/tasks/1

# With authentication
curl -H "Authorization: Bearer your-token" http://localhost:5000/api/protected
```

### Testing with Postman

```python
# Postman collection structure

# Collection: TaskFlow API
#   ├── Folder: Authentication
#   │   ├── POST /api/login
#   │   └── POST /api/register
#   ├── Folder: Tasks
#   │   ├── GET /api/tasks
#   │   ├── POST /api/tasks
#   │   ├── GET /api/tasks/{id}
#   │   ├── PUT /api/tasks/{id}
#   │   └── DELETE /api/tasks/{id}
#   └── Folder: Users
#       ├── GET /api/users
#       └── GET /api/users/{id}

# Postman environment variables
# {{base_url}} = http://localhost:5000
# {{auth_token}} = JWT token
```

### Automated Testing with pytest

```python
# tests/test_api.py

import pytest
from app import app, db
from models import Task

@pytest.fixture
def client():
    app.config['TESTING'] = True
    app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///:memory:'
    
    with app.test_client() as client:
        with app.app_context():
            db.create_all()
        yield client
        with app.app_context():
            db.drop_all()

def test_get_tasks(client):
    # Create test data
    with app.app_context():
        task = Task(title='Test Task')
        db.session.add(task)
        db.session.commit()
    
    # Test API
    response = client.get('/api/tasks')
    assert response.status_code == 200
    data = response.json
    assert len(data) == 1
    assert data[0]['title'] == 'Test Task'

def test_create_task(client):
    response = client.post('/api/tasks', 
        json={'title': 'New Task'},
        content_type='application/json'
    )
    assert response.status_code == 201
    data = response.json
    assert data['title'] == 'New Task'

def test_get_task_not_found(client):
    response = client.get('/api/tasks/999')
    assert response.status_code == 404
    assert response.json['error'] == 'Task not found'

def test_update_task(client):
    with app.app_context():
        task = Task(title='Old Title')
        db.session.add(task)
        db.session.commit()
        task_id = task.id
    
    response = client.put(f'/api/tasks/{task_id}',
        json={'title': 'New Title', 'completed': True},
        content_type='application/json'
    )
    assert response.status_code == 200
    assert response.json['title'] == 'New Title'
    assert response.json['completed'] == True

def test_delete_task(client):
    with app.app_context():
        task = Task(title='To Delete')
        db.session.add(task)
        db.session.commit()
        task_id = task.id
    
    response = client.delete(f'/api/tasks/{task_id}')
    assert response.status_code == 204
    
    # Verify it's deleted
    response = client.get(f'/api/tasks/{task_id}')
    assert response.status_code == 404
```

---

## Summary

This primer has introduced you to building REST APIs with Flask:

1. **REST APIs** are like menus for your application
2. **HTTP Methods** map to CRUD operations (GET, POST, PUT, DELETE)
3. **JSON** is the standard data format for APIs
4. **Endpoints** are organized by resources (nouns)
5. **Authentication** protects your API (tokens, JWT, API keys)
6. **Error Handling** provides consistent error responses
7. **Versioning** allows API evolution
8. **Testing** ensures API reliability

### Quick Reference

```python
# Basic API Setup
from flask import Flask, jsonify, request

app = Flask(__name__)

@app.route('/api/items', methods=['GET'])
def get_items():
    return jsonify({'items': []})

@app.route('/api/items', methods=['POST'])
def create_item():
    data = request.get_json()
    return jsonify(data), 201

# Common Patterns
@token_required                    # Authentication
@marshal_with(schema)              # Serialization
error_response('Message', 404)     # Error handling

# Status Codes
200 OK       # Success
201 Created  # Resource created
400 Bad      # Invalid request
401 Unauthorized
403 Forbidden
404 Not Found
500 Error

# Testing
curl -X GET http://localhost:5000/api/items
curl -X POST -H "Content-Type: application/json" -d '{"key":"value"}' http://localhost:5000/api/items
```

**Next Steps**:
- Build a complete API for your application
- Add authentication with JWT
- Implement pagination and filtering
- Add API documentation (Swagger/OpenAPI)
- Deploy your API to production
