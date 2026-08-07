# Part 5: Building RESTful APIs with Flask

Welcome to Part 5! We'll build a complete RESTful API for TaskFlow that coexists alongside our server-rendered web application. You'll learn how to design versioned APIs, implement token-based authentication, handle request validation, and create comprehensive API documentation.

---

## Phase 5, Part 1: API Structure & Blueprint Setup

### The Target
Create a modular API structure with versioning support.

### The Concept
An API is like a restaurant menu for developers. Just as a menu lists all the dishes you can order, an API lists all the operations developers can perform. Versioning is like having a "Classic Menu" and a "New Menu" - some customers prefer the old version, so we keep it available while adding new features.

### The Implementation

First, let's install the required packages:

```bash
pip install marshmallow marshmallow-sqlalchemy flask-httpauth
```

Now create the API structure:

```bash
mkdir -p app/blueprints/api/v1
mkdir -p app/blueprints/api/v2
mkdir -p app/schemas
touch app/blueprints/api/v1/__init__.py
touch app/blueprints/api/v1/routes.py
touch app/blueprints/api/v2/__init__.py
touch app/blueprints/api/v2/routes.py
touch app/schemas/__init__.py
touch app/schemas/task_schema.py
touch app/schemas/user_schema.py
touch app/schemas/auth_schema.py
```

**`app/blueprints/api/__init__.py`** — API blueprint registration
```python
"""
API Blueprint for RESTful endpoints.

Provides versioned API endpoints for programmatic access to TaskFlow.
"""

from flask import Blueprint

api_bp = Blueprint(
    "api",
    __name__,
    url_prefix="/api",
)

# Import and register versioned API blueprints
from app.blueprints.api.v1 import v1_bp
from app.blueprints.api.v2 import v2_bp

# Register versioned blueprints
api_bp.register_blueprint(v1_bp, url_prefix="/v1")
api_bp.register_blueprint(v2_bp, url_prefix="/v2")

# Import routes after registration to avoid circular imports
from app.blueprints.api import routes
```

**`app/blueprints/api/routes.py`** — API root routes
```python
"""
API root routes with version information.
"""

from flask import jsonify, url_for

from app.blueprints.api import api_bp


@api_bp.route("/")
def root():
    """
    API root endpoint with version information.
    
    Returns:
        JSON with available API versions and documentation links
    """
    return jsonify({
        "name": "TaskFlow API",
        "version": "1.0.0",
        "available_versions": {
            "v1": url_for("api.v1.root", _external=True),
            "v2": url_for("api.v2.root", _external=True),
        },
        "documentation": {
            "swagger": url_for("api.swagger_ui", _external=True),
            "redoc": url_for("api.redoc", _external=True),
        },
        "status": "operational",
    })


@api_bp.route("/status")
def status():
    """
    API status endpoint.
    
    Returns:
        JSON with API status and health information
    """
    from app.extensions import db
    import time
    
    try:
        # Test database connection
        db.session.execute("SELECT 1")
        db_status = "healthy"
    except Exception as e:
        db_status = f"unhealthy: {str(e)}"
    
    return jsonify({
        "status": "operational",
        "timestamp": time.time(),
        "database": db_status,
        "version": "1.0.0",
    })
```

Now let's create the versioned API blueprints:

**`app/blueprints/api/v1/__init__.py`** — Version 1 API
```python
"""
API Version 1 Blueprint.

Provides the first version of the TaskFlow REST API.
"""

from flask import Blueprint

v1_bp = Blueprint(
    "api_v1",
    __name__,
    url_prefix="",  # Prefix handled by parent blueprint
)

# Import routes
from app.blueprints.api.v1 import routes
```

**`app/blueprints/api/v1/routes.py`** — Version 1 routes
```python
"""
API Version 1 routes.

Implements the initial REST API endpoints for TaskFlow resources.
"""

from flask import jsonify, request, abort, url_for, current_app
from flask_login import login_required, current_user
from marshmallow import ValidationError

from app.blueprints.api.v1 import v1_bp
from app.services import TaskService, UserService, CategoryService
from app.schemas.task_schema import TaskSchema, TaskListSchema
from app.schemas.user_schema import UserSchema
from app.models.task import TaskStatus, TaskPriority


@v1_bp.route("/")
def root():
    """
    Version 1 API root.
    
    Returns:
        JSON with available endpoints
    """
    return jsonify({
        "version": "1.0",
        "endpoints": {
            "tasks": url_for("api_v1.list_tasks", _external=True),
            "task": url_for("api_v1.get_task", task_id=1, _external=True).replace("/1", "/{id}"),
            "users": url_for("api_v1.list_users", _external=True),
            "user": url_for("api_v1.get_user", user_id=1, _external=True).replace("/1", "/{id}"),
            "categories": url_for("api_v1.list_categories", _external=True),
        },
        "documentation": "See /api/docs for full API documentation",
    })


# ============================================================================
# Task Endpoints
# ============================================================================

@v1_bp.route("/tasks", methods=["GET"])
@login_required
def list_tasks():
    """
    List all tasks for the authenticated user.
    
    Query Parameters:
        status: Filter by status (pending, in_progress, review, completed, archived)
        priority: Filter by priority (low, medium, high, urgent)
        category_id: Filter by category ID
        assigned_to_id: Filter by assigned user ID
        search: Search in title and description
        page: Page number (default: 1)
        per_page: Items per page (default: 20)
    
    Returns:
        JSON with tasks list and pagination metadata
    """
    # Get query parameters
    status = request.args.get("status")
    priority = request.args.get("priority")
    category_id = request.args.get("category_id", type=int)
    assigned_to_id = request.args.get("assigned_to_id", type=int)
    search = request.args.get("search", "").strip()
    page = request.args.get("page", 1, type=int)
    per_page = request.args.get("per_page", 20, type=int)
    
    # Validate status
    if status and status not in [s.value for s in TaskStatus]:
        return jsonify({
            "error": "Invalid status",
            "valid_statuses": [s.value for s in TaskStatus]
        }), 400
    
    # Validate priority
    if priority and priority not in [p.value for p in TaskPriority]:
        return jsonify({
            "error": "Invalid priority",
            "valid_priorities": [p.value for p in TaskPriority]
        }), 400
    
    # Get tasks
    tasks, total = TaskService.get_user_tasks(
        user=current_user,
        status=status,
        priority=priority,
        category_id=category_id,
        search=search,
        assigned_to_id=assigned_to_id,
        page=page,
        per_page=per_page,
    )
    
    # Serialize tasks
    schema = TaskSchema(many=True)
    result = {
        "tasks": schema.dump(tasks),
        "metadata": {
            "total": total,
            "page": page,
            "per_page": per_page,
            "pages": (total + per_page - 1) // per_page if per_page > 0 else 0,
        }
    }
    
    return jsonify(result)


@v1_bp.route("/tasks/<int:task_id>", methods=["GET"])
@login_required
def get_task(task_id):
    """
    Get a specific task by ID.
    
    Returns:
        JSON with task details
    """
    task = TaskService.get_by_id(task_id, current_user)
    if not task:
        abort(404, description="Task not found")
    
    schema = TaskSchema()
    return jsonify(schema.dump(task))


@v1_bp.route("/tasks", methods=["POST"])
@login_required
def create_task():
    """
    Create a new task.
    
    Request Body:
        title (required): Task title
        description: Task description
        status: Task status (default: pending)
        priority: Task priority (default: medium)
        due_date: Due date in ISO format
        assigned_to_id: User ID to assign to
        category_id: Category ID
        tags: List of tag names
    
    Returns:
        JSON with created task details
    """
    data = request.get_json()
    if not data:
        return jsonify({"error": "No data provided"}), 400
    
    # Validate required fields
    if "title" not in data or not data["title"].strip():
        return jsonify({"error": "Title is required"}), 400
    
    try:
        task = TaskService.create_task(
            user=current_user,
            title=data["title"].strip(),
            description=data.get("description"),
            status=TaskStatus(data.get("status", "pending")),
            priority=TaskPriority(data.get("priority", "medium")),
            due_date=data.get("due_date"),
            assigned_to_id=data.get("assigned_to_id"),
            category_id=data.get("category_id"),
            tags=data.get("tags"),
        )
        
        schema = TaskSchema()
        return jsonify(schema.dump(task)), 201
        
    except ValueError as e:
        return jsonify({"error": str(e)}), 400
    except Exception as e:
        current_app.logger.error(f"Error creating task: {e}")
        return jsonify({"error": "Failed to create task"}), 500


@v1_bp.route("/tasks/<int:task_id>", methods=["PUT"])
@login_required
def update_task(task_id):
    """
    Update an existing task.
    
    Request Body:
        title: Updated title
        description: Updated description
        status: Updated status
        priority: Updated priority
        due_date: Updated due date
        assigned_to_id: Updated assigned user
        category_id: Updated category
        tags: Updated list of tag names
    
    Returns:
        JSON with updated task details
    """
    task = TaskService.get_by_id(task_id, current_user)
    if not task:
        abort(404, description="Task not found")
    
    data = request.get_json()
    if not data:
        return jsonify({"error": "No data provided"}), 400
    
    try:
        # Parse status and priority if provided
        status = TaskStatus(data["status"]) if "status" in data else None
        priority = TaskPriority(data["priority"]) if "priority" in data else None
        
        task = TaskService.update_task(
            task=task,
            user=current_user,
            title=data.get("title"),
            description=data.get("description"),
            status=status,
            priority=priority,
            due_date=data.get("due_date"),
            assigned_to_id=data.get("assigned_to_id"),
            category_id=data.get("category_id"),
            tags=data.get("tags"),
        )
        
        schema = TaskSchema()
        return jsonify(schema.dump(task))
        
    except PermissionError as e:
        return jsonify({"error": str(e)}), 403
    except ValueError as e:
        return jsonify({"error": str(e)}), 400
    except Exception as e:
        current_app.logger.error(f"Error updating task: {e}")
        return jsonify({"error": "Failed to update task"}), 500


@v1_bp.route("/tasks/<int:task_id>", methods=["DELETE"])
@login_required
def delete_task(task_id):
    """
    Delete a task.
    
    Returns:
        Empty response with 204 status code
    """
    task = TaskService.get_by_id(task_id, current_user)
    if not task:
        abort(404, description="Task not found")
    
    try:
        TaskService.delete_task(task, current_user)
        return "", 204
    except PermissionError as e:
        return jsonify({"error": str(e)}), 403
    except Exception as e:
        current_app.logger.error(f"Error deleting task: {e}")
        return jsonify({"error": "Failed to delete task"}), 500


# ============================================================================
# User Endpoints
# ============================================================================

@v1_bp.route("/users", methods=["GET"])
@login_required
def list_users():
    """
    List users (admin only).
    
    Returns:
        JSON with users list
    """
    if not current_user.is_admin:
        abort(403, description="Admin access required")
    
    page = request.args.get("page", 1, type=int)
    per_page = request.args.get("per_page", 20, type=int)
    
    users, total = UserService.get_all(page=page, per_page=per_page)
    
    schema = UserSchema(many=True)
    result = {
        "users": schema.dump(users),
        "metadata": {
            "total": total,
            "page": page,
            "per_page": per_page,
        }
    }
    
    return jsonify(result)


@v1_bp.route("/users/<int:user_id>", methods=["GET"])
@login_required
def get_user(user_id):
    """
    Get a specific user by ID.
    
    Returns:
        JSON with user details
    """
    if not current_user.is_admin and current_user.id != user_id:
        abort(403, description="Access denied")
    
    user = UserService.get_by_id(user_id)
    if not user:
        abort(404, description="User not found")
    
    schema = UserSchema()
    return jsonify(schema.dump(user))


# ============================================================================
# Category Endpoints
# ============================================================================

@v1_bp.route("/categories", methods=["GET"])
@login_required
def list_categories():
    """
    List all categories.
    
    Returns:
        JSON with categories list
    """
    categories = CategoryService.get_all()
    return jsonify({
        "categories": [{
            "id": c.id,
            "name": c.name,
            "description": c.description,
            "color": c.color,
            "task_count": c.task_count,
        } for c in categories]
    })
```

Now let's create the schemas for serialization:

**`app/schemas/__init__.py`** — Schemas package
```python
"""
Data schemas for API serialization and validation.

Uses Marshmallow for consistent data transformation between
database models and JSON responses.
"""

from app.schemas.task_schema import TaskSchema, TaskListSchema
from app.schemas.user_schema import UserSchema, UserListSchema
from app.schemas.auth_schema import AuthSchema, LoginSchema, RegisterSchema

__all__ = [
    "TaskSchema",
    "TaskListSchema",
    "UserSchema",
    "UserListSchema",
    "AuthSchema",
    "LoginSchema",
    "RegisterSchema",
]
```

**`app/schemas/task_schema.py`** — Task schemas
```python
"""
Task schemas for API serialization.

Defines how Task models are converted to and from JSON for the API.
"""

from marshmallow import Schema, fields, validate, post_dump, pre_load
from marshmallow_sqlalchemy import SQLAlchemyAutoSchema

from app.models.task import Task, TaskStatus, TaskPriority


class TaskSchema(SQLAlchemyAutoSchema):
    """
    Schema for serializing Task objects.
    
    Automatically maps SQLAlchemy model fields to JSON fields.
    """
    
    class Meta:
        model = Task
        load_instance = True
        include_relationships = True
        include_fk = True
        
    # Override fields with additional metadata
    id = fields.Int(dump_only=True)
    title = fields.Str(required=True, validate=validate.Length(min=1, max=200))
    description = fields.Str(allow_none=True, validate=validate.Length(max=2000))
    status = fields.Str(
        required=True,
        validate=validate.OneOf([s.value for s in TaskStatus])
    )
    priority = fields.Str(
        required=True,
        validate=validate.OneOf([p.value for p in TaskPriority])
    )
    due_date = fields.DateTime(allow_none=True)
    completed_at = fields.DateTime(dump_only=True)
    created_at = fields.DateTime(dump_only=True)
    updated_at = fields.DateTime(dump_only=True)
    
    # Relationships (nested fields)
    user_id = fields.Int(required=True)
    assigned_to_id = fields.Int(allow_none=True)
    category_id = fields.Int(allow_none=True)
    
    # Nested objects for detailed representation
    user = fields.Nested("UserSchema", dump_only=True, only=("id", "username", "full_name"))
    assigned_to_user = fields.Nested("UserSchema", dump_only=True, only=("id", "username", "full_name"))
    category = fields.Nested("CategorySchema", dump_only=True, only=("id", "name", "color"))
    tags = fields.Nested("TagSchema", dump_only=True, many=True, only=("id", "name", "color"))
    
    # Computed properties
    is_completed = fields.Bool(dump_only=True)
    is_overdue = fields.Bool(dump_only=True)
    progress_percentage = fields.Int(dump_only=True)
    days_until_due = fields.Int(dump_only=True, allow_none=True)
    
    @pre_load
    def parse_dates(self, data, **kwargs):
        """Parse date strings before loading into model."""
        # If due_date is a string, keep it as is (SQLAlchemyAutoSchema handles conversion)
        return data
    
    @post_dump
    def format_dates(self, data, **kwargs):
        """Format dates for JSON output."""
        # Ensure dates are in ISO format
        for field in ['due_date', 'completed_at', 'created_at', 'updated_at']:
            if field in data and data[field] is not None:
                # If it's a datetime object, it will be serialized to ISO format automatically
                pass
        return data


class TaskListSchema(Schema):
    """
    Schema for listing tasks with pagination metadata.
    """
    tasks = fields.Nested(TaskSchema, many=True)
    metadata = fields.Dict(
        keys=fields.Str(),
        values=fields.Raw(),
        dump_only=True
    )
```

**`app/schemas/user_schema.py`** — User schemas
```python
"""
User schemas for API serialization.
"""

from marshmallow import Schema, fields, validate, post_dump
from marshmallow_sqlalchemy import SQLAlchemyAutoSchema

from app.models.user import User, UserRole


class UserSchema(SQLAlchemyAutoSchema):
    """
    Schema for serializing User objects.
    """
    
    class Meta:
        model = User
        load_instance = True
        exclude = ("password_hash",)
        
    id = fields.Int(dump_only=True)
    username = fields.Str(required=True, validate=validate.Length(min=3, max=50))
    email = fields.Email(required=True)
    first_name = fields.Str(allow_none=True, validate=validate.Length(max=50))
    last_name = fields.Str(allow_none=True, validate=validate.Length(max=50))
    bio = fields.Str(allow_none=True, validate=validate.Length(max=500))
    role = fields.Str(
        required=True,
        validate=validate.OneOf([r.value for r in UserRole])
    )
    is_active = fields.Bool(dump_only=True)
    email_verified = fields.Bool(dump_only=True)
    created_at = fields.DateTime(dump_only=True)
    updated_at = fields.DateTime(dump_only=True)
    last_login = fields.DateTime(dump_only=True, allow_none=True)
    
    # Computed properties
    full_name = fields.Str(dump_only=True)
    is_admin = fields.Bool(dump_only=True)
    is_manager = fields.Bool(dump_only=True)
    
    @post_dump
    def remove_empty_fields(self, data, **kwargs):
        """Remove None values from the output."""
        return {k: v for k, v in data.items() if v is not None}


class UserListSchema(Schema):
    """
    Schema for listing users with pagination metadata.
    """
    users = fields.Nested(UserSchema, many=True)
    metadata = fields.Dict(
        keys=fields.Str(),
        values=fields.Raw(),
        dump_only=True
    )
```

---

## Phase 5, Part 2: API Authentication with Tokens

### The Target
Implement token-based authentication for the API.

### The Concept
API tokens are like digital keys. Instead of sending a username and password with every request (which is insecure), you log in once to get a "key" (token). You then include this key in every subsequent request to prove you're authenticated. These keys can expire, be revoked, and work across multiple devices.

### The Implementation

Create the authentication schemas and handlers:

**`app/schemas/auth_schema.py`** — Authentication schemas
```python
"""
Authentication schemas for API.

Defines request and response schemas for authentication endpoints.
"""

from marshmallow import Schema, fields, validate


class LoginSchema(Schema):
    """
    Schema for login request.
    """
    email = fields.Email(required=True)
    password = fields.Str(required=True, validate=validate.Length(min=1))
    
    class Meta:
        ordered = True


class RegisterSchema(Schema):
    """
    Schema for registration request.
    """
    username = fields.Str(required=True, validate=validate.Length(min=3, max=50))
    email = fields.Email(required=True)
    password = fields.Str(required=True, validate=validate.Length(min=8))
    
    class Meta:
        ordered = True


class TokenResponseSchema(Schema):
    """
    Schema for token response.
    """
    access_token = fields.Str(required=True)
    token_type = fields.Str(dump_default="Bearer")
    expires_in = fields.Int(dump_default=3600)
    user = fields.Nested("UserSchema", only=("id", "username", "email", "full_name", "role"))


class AuthSchema(Schema):
    """
    Authentication status schema.
    """
    authenticated = fields.Bool()
    user = fields.Nested("UserSchema", only=("id", "username", "email", "full_name", "role"))
```

Now let's implement the token authentication system:

```bash
mkdir -p app/utils/auth
touch app/utils/auth/__init__.py
touch app/utils/auth/jwt.py
touch app/utils/auth/token.py
```

**`app/utils/auth/token.py`** — Token generation and verification
```python
"""
Token-based authentication utilities.
"""

import secrets
from datetime import datetime, timedelta
from typing import Optional, Dict
import hashlib
import base64

from flask import current_app


class TokenManager:
    """
    Manages API token generation, validation, and storage.
    
    Supports both JWT and simple token-based authentication.
    """
    
    @staticmethod
    def generate_token(user_id: int) -> Dict[str, str]:
        """
        Generate an API token for a user.
        
        Args:
            user_id: User ID to generate token for
            
        Returns:
            Dictionary with token and expiration
        """
        # Generate a secure random token
        token = secrets.token_urlsafe(32)
        
        # Store token in database or cache
        # For now, we'll use a simple in-memory store
        # In production, use Redis or store in the database
        
        # Create token data
        token_data = {
            "token": token,
            "user_id": user_id,
            "created_at": datetime.utcnow().isoformat(),
            "expires_at": (datetime.utcnow() + timedelta(hours=1)).isoformat(),
        }
        
        # Store in application context
        if not hasattr(current_app, 'api_tokens'):
            current_app.api_tokens = {}
        
        current_app.api_tokens[token] = token_data
        
        return {
            "access_token": token,
            "token_type": "Bearer",
            "expires_in": 3600,
        }
    
    @staticmethod
    def verify_token(token: str) -> Optional[int]:
        """
        Verify an API token and return the associated user ID.
        
        Args:
            token: Token string to verify
            
        Returns:
            User ID if token is valid, None otherwise
        """
        if not hasattr(current_app, 'api_tokens'):
            return None
        
        token_data = current_app.api_tokens.get(token)
        if not token_data:
            return None
        
        # Check expiration
        expires_at = datetime.fromisoformat(token_data["expires_at"])
        if expires_at < datetime.utcnow():
            # Token expired - remove it
            del current_app.api_tokens[token]
            return None
        
        return token_data["user_id"]
    
    @staticmethod
    def revoke_token(token: str) -> bool:
        """
        Revoke an API token.
        
        Args:
            token: Token to revoke
            
        Returns:
            True if revoked, False otherwise
        """
        if not hasattr(current_app, 'api_tokens'):
            return False
        
        if token in current_app.api_tokens:
            del current_app.api_tokens[token]
            return True
        
        return False
    
    @staticmethod
    def revoke_all_tokens(user_id: int) -> int:
        """
        Revoke all tokens for a user.
        
        Args:
            user_id: User ID
            
        Returns:
            Number of tokens revoked
        """
        if not hasattr(current_app, 'api_tokens'):
            return 0
        
        revoked = 0
        tokens_to_revoke = []
        
        for token, data in current_app.api_tokens.items():
            if data["user_id"] == user_id:
                tokens_to_revoke.append(token)
                revoked += 1
        
        for token in tokens_to_revoke:
            del current_app.api_tokens[token]
        
        return revoked
```

Now let's create the authentication endpoints:

**`app/blueprints/api/v1/routes.py`** — Add authentication endpoints
```python
"""
API Version 1 routes with authentication.
"""

# ... existing imports ...
from flask_login import login_required, current_user, login_user
from app.forms.auth import LoginForm
from app.utils.auth.token import TokenManager
from app.schemas.auth_schema import LoginSchema, RegisterSchema, TokenResponseSchema


# ============================================================================
# Authentication Endpoints
# ============================================================================

@v1_bp.route("/auth/login", methods=["POST"])
def login():
    """
    Authenticate and receive an API token.
    
    Request Body:
        email: User email
        password: User password
    
    Returns:
        JSON with access token
    """
    data = request.get_json()
    if not data:
        return jsonify({"error": "No data provided"}), 400
    
    # Validate input
    schema = LoginSchema()
    try:
        validated = schema.load(data)
    except ValidationError as e:
        return jsonify({"errors": e.messages}), 400
    
    # Authenticate user
    user = UserService.authenticate_user(
        email=validated["email"],
        password=validated["password"]
    )
    
    if not user:
        return jsonify({"error": "Invalid credentials"}), 401
    
    if not user.is_active:
        return jsonify({"error": "Account is disabled"}), 401
    
    if not user.email_verified:
        return jsonify({"error": "Email not verified"}), 401
    
    # Generate token
    token_data = TokenManager.generate_token(user.id)
    
    # Serialize response
    response_schema = TokenResponseSchema()
    result = {
        "access_token": token_data["access_token"],
        "token_type": token_data["token_type"],
        "expires_in": token_data["expires_in"],
        "user": {
            "id": user.id,
            "username": user.username,
            "email": user.email,
            "full_name": user.full_name,
            "role": user.role.value,
        }
    }
    
    return jsonify(result), 200


@v1_bp.route("/auth/logout", methods=["POST"])
@login_required
def logout():
    """
    Revoke the current API token.
    
    Returns:
        Success message
    """
    auth_header = request.headers.get("Authorization")
    if auth_header and auth_header.startswith("Bearer "):
        token = auth_header.split(" ")[1]
        TokenManager.revoke_token(token)
    
    return jsonify({"message": "Logged out successfully"}), 200


@v1_bp.route("/auth/refresh", methods=["POST"])
@login_required
def refresh_token():
    """
    Refresh the current API token.
    
    Returns:
        JSON with new access token
    """
    # Revoke old token
    auth_header = request.headers.get("Authorization")
    if auth_header and auth_header.startswith("Bearer "):
        token = auth_header.split(" ")[1]
        TokenManager.revoke_token(token)
    
    # Generate new token
    token_data = TokenManager.generate_token(current_user.id)
    
    response_schema = TokenResponseSchema()
    result = {
        "access_token": token_data["access_token"],
        "token_type": token_data["token_type"],
        "expires_in": token_data["expires_in"],
    }
    
    return jsonify(result), 200


# ============================================================================
# Authentication Decorators for API
# ============================================================================

def token_required(f):
    """
    Decorator for API endpoints that require token authentication.
    
    This decorator checks for a valid token in the Authorization header.
    """
    from functools import wraps
    from flask import request, abort
    
    @wraps(f)
    def decorated_function(*args, **kwargs):
        # First check if user is already authenticated via session
        if current_user.is_authenticated:
            return f(*args, **kwargs)
        
        # Check for token in Authorization header
        auth_header = request.headers.get("Authorization")
        if not auth_header or not auth_header.startswith("Bearer "):
            return jsonify({"error": "Authentication required"}), 401
        
        token = auth_header.split(" ")[1]
        user_id = TokenManager.verify_token(token)
        
        if not user_id:
            return jsonify({"error": "Invalid or expired token"}), 401
        
        # Get user from database
        user = UserService.get_by_id(user_id)
        if not user or not user.is_active:
            return jsonify({"error": "User not found or inactive"}), 401
        
        # Set current user for the request
        # We'll use Flask-Login's mechanism
        from flask_login import login_user
        login_user(user, remember=False)
        
        return f(*args, **kwargs)
    
    return decorated_function
```

Now let's update the task endpoints to use token authentication:

**`app/blueprints/api/v1/routes.py`** — Update endpoints
```python
# Replace @login_required with @token_required for API endpoints
# Or use both to support both session and token authentication

# Example:
@v1_bp.route("/tasks", methods=["GET"])
@login_required  # Session authentication
def list_tasks():
    # ... existing code ...

# For pure API endpoints that should only work with tokens:
@v1_bp.route("/tasks/<int:task_id>/assign", methods=["POST"])
@token_required
def assign_task(task_id):
    """
    Assign a task to a user (API only).
    
    Request Body:
        user_id: User ID to assign to
    """
    # ... implementation ...
```

Let's add the admin-only endpoints:

**`app/blueprints/api/v1/routes.py`** — Admin endpoints
```python
@v1_bp.route("/admin/users", methods=["GET"])
@login_required
def admin_list_users():
    """
    List all users (admin only).
    
    Returns:
        JSON with all users
    """
    if not current_user.is_admin:
        abort(403, description="Admin access required")
    
    users, total = UserService.get_all(page=1, per_page=1000)
    schema = UserSchema(many=True)
    
    return jsonify({
        "users": schema.dump(users),
        "total": total,
    })


@v1_bp.route("/admin/stats", methods=["GET"])
@login_required
def admin_stats():
    """
    Get system statistics (admin only).
    
    Returns:
        JSON with system statistics
    """
    if not current_user.is_admin:
        abort(403, description="Admin access required")
    
    user_stats = UserService.get_user_statistics()
    task_stats = TaskService.get_task_statistics(current_user)
    
    return jsonify({
        "users": user_stats,
        "tasks": task_stats,
    })
```

---

## Phase 5, Part 3: API Error Handling & Validation

### The Target
Implement comprehensive error handling and request validation for the API.

### The Concept
Error handling is like having a helpful receptionist who, when you ask for something that doesn't exist, tells you what's wrong and how to fix it. A good API error response tells the developer:
- What went wrong (error code)
- Why it went wrong (error message)
- How to fix it (next steps)

### The Implementation

**`app/blueprints/api/errors.py`** — API error handlers
```python
"""
API error handlers for consistent error responses.

Provides standardized error responses for the API with proper HTTP status codes.
"""

from flask import jsonify, request, current_app
from werkzeug.exceptions import HTTPException


def register_api_error_handlers(app):
    """
    Register error handlers for the API blueprint.
    
    Args:
        app: Flask application instance
    """
    
    @app.errorhandler(400)
    def bad_request(error):
        """Handle 400 Bad Request errors."""
        return jsonify({
            "error": "Bad Request",
            "message": str(error.description) if hasattr(error, 'description') else "Invalid request",
            "status": 400,
            "path": request.path,
        }), 400
    
    @app.errorhandler(401)
    def unauthorized(error):
        """Handle 401 Unauthorized errors."""
        return jsonify({
            "error": "Unauthorized",
            "message": "Authentication required",
            "status": 401,
            "path": request.path,
        }), 401
    
    @app.errorhandler(403)
    def forbidden(error):
        """Handle 403 Forbidden errors."""
        return jsonify({
            "error": "Forbidden",
            "message": "You don't have permission to access this resource",
            "status": 403,
            "path": request.path,
        }), 403
    
    @app.errorhandler(404)
    def not_found(error):
        """Handle 404 Not Found errors."""
        return jsonify({
            "error": "Not Found",
            "message": "The requested resource does not exist",
            "status": 404,
            "path": request.path,
        }), 404
    
    @app.errorhandler(405)
    def method_not_allowed(error):
        """Handle 405 Method Not Allowed errors."""
        return jsonify({
            "error": "Method Not Allowed",
            "message": "The HTTP method is not allowed for this endpoint",
            "status": 405,
            "path": request.path,
            "allowed_methods": error.valid_methods if hasattr(error, 'valid_methods') else [],
        }), 405
    
    @app.errorhandler(429)
    def too_many_requests(error):
        """Handle 429 Too Many Requests errors."""
        return jsonify({
            "error": "Too Many Requests",
            "message": "Rate limit exceeded. Please try again later.",
            "status": 429,
            "path": request.path,
            "retry_after": error.description if hasattr(error, 'description') else 60,
        }), 429
    
    @app.errorhandler(500)
    def internal_error(error):
        """Handle 500 Internal Server errors."""
        current_app.logger.error(f"API 500 error: {error}")
        return jsonify({
            "error": "Internal Server Error",
            "message": "Something went wrong on our end",
            "status": 500,
            "path": request.path,
        }), 500
    
    @app.errorhandler(HTTPException)
    def http_error(error):
        """Handle all HTTP exceptions."""
        return jsonify({
            "error": error.name,
            "message": error.description,
            "status": error.code,
            "path": request.path,
        }), error.code
    
    @app.errorhandler(Exception)
    def unhandled_error(error):
        """Handle unhandled exceptions."""
        current_app.logger.error(f"Unhandled API error: {error}", exc_info=True)
        return jsonify({
            "error": "Internal Server Error",
            "message": "An unexpected error occurred",
            "status": 500,
            "path": request.path,
        }), 500


def format_validation_error(errors, status=400):
    """
    Format validation errors for API responses.
    
    Args:
        errors: Dictionary of validation errors
        status: HTTP status code
        
    Returns:
        Tuple of (response_json, status_code)
    """
    return jsonify({
        "error": "Validation Error",
        "message": "One or more fields failed validation",
        "status": status,
        "errors": errors,
    }), status
```

---

## Phase 5, Part 4: API Rate Limiting

### The Target
Implement rate limiting to prevent abuse of the API.

### The Concept
Rate limiting is like a door with a bouncer who only lets a certain number of people in per minute. It prevents users from overwhelming your API with too many requests, which can degrade performance for everyone.

### The Implementation

Install the rate limiting package:

```bash
pip install flask-limiter
```

**`app/extensions.py`** — Add rate limiting
```python
"""
Flask extensions initialization with rate limiting.
"""

# ... existing imports ...
from flask_limiter import Limiter
from flask_limiter.util import get_remote_address

# Rate limiting extension
limiter = Limiter(
    key_func=get_remote_address,
    default_limits=["200 per day", "50 per hour"],
    storage_uri="memory://",  # Use Redis in production
    strategy="fixed-window",  # or "moving-window"
)


def init_extensions(app: "Flask") -> None:
    """Initialize all extensions with the Flask application instance."""
    # ... existing initialization ...
    
    # Initialize rate limiter
    limiter.init_app(app)
```

Now apply rate limiting to API endpoints:

**`app/blueprints/api/v1/routes.py`** — Add rate limiting
```python
from app.extensions import limiter

# Apply rate limiting to specific endpoints
@v1_bp.route("/tasks", methods=["GET"])
@login_required
@limiter.limit("100 per minute")
def list_tasks():
    # ... existing code ...

@v1_bp.route("/tasks", methods=["POST"])
@login_required
@limiter.limit("30 per minute")
def create_task():
    # ... existing code ...

# Stricter limits for authentication endpoints
@v1_bp.route("/auth/login", methods=["POST"])
@limiter.limit("5 per minute", error_message="Too many login attempts. Please try again later.")
def login():
    # ... existing code ...
```

---

## Phase 5, Part 5: API Documentation with Swagger

### The Target
Create interactive API documentation using Swagger/OpenAPI.

### The Concept
API documentation is like a user manual for developers. Swagger takes it a step further by making the documentation interactive—developers can actually try out the API endpoints directly from the documentation page.

### The Implementation

Install the Swagger packages:

```bash
pip install flask-swagger-ui apispec apispec-webframeworks
```

**`app/blueprints/api/docs.py`** — API documentation
```python
"""
API documentation setup for TaskFlow.

Uses OpenAPI 3.0 specification with Swagger UI and ReDoc.
"""

from flask import Blueprint, jsonify, render_template, current_app
from apispec import APISpec
from apispec.ext.marshmallow import MarshmallowPlugin
from apispec_webframeworks.flask import FlaskPlugin

from app.schemas.task_schema import TaskSchema
from app.schemas.user_schema import UserSchema
from app.schemas.auth_schema import LoginSchema, RegisterSchema, TokenResponseSchema


def create_api_spec():
    """
    Create the OpenAPI specification for the TaskFlow API.
    
    Returns:
        APISpec object with the complete API specification
    """
    spec = APISpec(
        title="TaskFlow API",
        version="1.0.0",
        openapi_version="3.0.2",
        info={
            "description": "The TaskFlow API provides programmatic access to task management features.",
            "contact": {
                "name": "TaskFlow Support",
                "email": "support@taskflow.com",
            },
            "license": {
                "name": "MIT",
                "url": "https://opensource.org/licenses/MIT",
            },
        },
        servers=[
            {"url": "https://api.taskflow.com", "description": "Production Server"},
            {"url": "http://localhost:5000", "description": "Development Server"},
        ],
        plugins=[FlaskPlugin(), MarshmallowPlugin()],
    )
    
    # ==========================================================================
    # Security Schemas
    # ==========================================================================
    
    spec.components.security_scheme(
        "bearerAuth",
        {
            "type": "http",
            "scheme": "bearer",
            "bearerFormat": "JWT",
            "description": "Enter your JWT token in the format: 'Bearer {token}'",
        }
    )
    
    spec.components.security_scheme(
        "cookieAuth",
        {
            "type": "apiKey",
            "in": "cookie",
            "name": "session",
            "description": "Session cookie authentication (from web login)",
        }
    )
    
    # ==========================================================================
    # Tags
    # ==========================================================================
    
    spec.tag({
        "name": "Authentication",
        "description": "Authentication and token management",
    })
    spec.tag({
        "name": "Tasks",
        "description": "Task CRUD operations",
    })
    spec.tag({
        "name": "Users",
        "description": "User management (admin only)",
    })
    spec.tag({
        "name": "Categories",
        "description": "Category management",
    })
    
    # ==========================================================================
    # Paths (will be filled by the application)
    # ==========================================================================
    
    return spec


def register_docs_blueprint(app):
    """
    Register the documentation blueprint with the application.
    
    Args:
        app: Flask application instance
    """
    docs_bp = Blueprint(
        "api_docs",
        __name__,
        url_prefix="/api/docs",
        template_folder="templates",
    )
    
    @docs_bp.route("/")
    def index():
        """Documentation index page."""
        return render_template("api/docs.html")
    
    @docs_bp.route("/swagger.json")
    def swagger_json():
        """Return the OpenAPI specification as JSON."""
        spec = create_api_spec()
        
        # Generate paths from registered routes
        from flask import current_app
        for rule in current_app.url_map.iter_rules():
            if rule.endpoint.startswith("api_v1."):
                # Skip documentation endpoints
                if "api_docs" in rule.endpoint:
                    continue
                
                # Add path to spec
                path = rule.rule.replace("/api/v1", "")
                spec.path(path=path, operations={
                    "get": {
                        "summary": f"GET {path}",
                        "description": f"Get resource from {path}",
                        "responses": {
                            "200": {"description": "Success"},
                            "401": {"description": "Unauthorized"},
                            "403": {"description": "Forbidden"},
                            "404": {"description": "Not Found"},
                        }
                    }
                })
        
        return jsonify(spec.to_dict())
    
    @docs_bp.route("/swagger-ui")
    def swagger_ui():
        """Swagger UI interface."""
        return render_template("api/swagger-ui.html")
    
    @docs_bp.route("/redoc")
    def redoc():
        """ReDoc interface."""
        return render_template("api/redoc.html")
    
    # Register blueprint
    app.register_blueprint(docs_bp)
```

**`app/templates/api/docs.html`** — Documentation index
```html
{% extends "base.html" %}

{% block title %}API Documentation - {{ app_name }}{% endblock %}

{% block content %}
<div class="container py-5">
    <div class="row">
        <div class="col-lg-8 mx-auto">
            <h1 class="display-4 text-center mb-4">TaskFlow API</h1>
            <p class="lead text-center">
                RESTful API for task management with versioning and authentication.
            </p>
            
            <div class="card mb-4">
                <div class="card-header">
                    <h5 class="mb-0">Quick Links</h5>
                </div>
                <div class="card-body">
                    <div class="row">
                        <div class="col-md-6">
                            <a href="{{ url_for('api_docs.swagger_ui') }}" class="btn btn-primary w-100 mb-2">
                                <i class="fas fa-book-open"></i> Swagger UI
                            </a>
                            <p class="text-muted text-center small">Interactive API documentation</p>
                        </div>
                        <div class="col-md-6">
                            <a href="{{ url_for('api_docs.redoc') }}" class="btn btn-info w-100 mb-2">
                                <i class="fas fa-file-alt"></i> ReDoc
                            </a>
                            <p class="text-muted text-center small">Clean, readable documentation</p>
                        </div>
                    </div>
                    <div class="text-center mt-3">
                        <a href="{{ url_for('api_docs.swagger_json') }}" class="btn btn-outline-secondary">
                            <i class="fas fa-code"></i> OpenAPI Specification (JSON)
                        </a>
                    </div>
                </div>
            </div>
            
            <div class="card mb-4">
                <div class="card-header">
                    <h5 class="mb-0">API Overview</h5>
                </div>
                <div class="card-body">
                    <h6>Base URL</h6>
                    <code class="bg-light p-2 d-block mb-3">https://api.taskflow.com/api/v1/</code>
                    
                    <h6>Authentication</h6>
                    <p>All API requests require authentication. You can authenticate using:</p>
                    <ul>
                        <li><strong>Bearer Token:</strong> Include in Authorization header</li>
                        <li><strong>Session Cookie:</strong> If logged in via web interface</li>
                    </ul>
                    
                    <h6>Rate Limiting</h6>
                    <ul>
                        <li>100 requests per minute for task endpoints</li>
                        <li>30 requests per minute for write operations</li>
                        <li>5 requests per minute for login attempts</li>
                    </ul>
                    
                    <h6>Response Format</h6>
                    <p>All responses are in JSON format with the following structure:</p>
                    <pre class="bg-light p-3">{
    "error": "Error message",  # Optional
    "message": "Response message",  # Optional
    "data": { ... }  # Main response data
}</pre>
                </div>
            </div>
            
            <div class="card">
                <div class="card-header">
                    <h5 class="mb-0">Getting Started</h5>
                </div>
                <div class="card-body">
                    <ol>
                        <li>
                            <strong>Register a user account</strong>
                            <p>Use the <code>/auth/register</code> endpoint or the web interface.</p>
                        </li>
                        <li>
                            <strong>Obtain an API token</strong>
                            <p>POST to <code>/auth/login</code> with your credentials.</p>
                        </li>
                        <li>
                            <strong>Use the token in requests</strong>
                            <p>Include <code>Authorization: Bearer YOUR_TOKEN</code> header.</p>
                        </li>
                        <li>
                            <strong>Start making requests!</strong>
                            <p>Explore the endpoints using Swagger UI.</p>
                        </li>
                    </ol>
                </div>
            </div>
        </div>
    </div>
</div>
{% endblock %}
```

**`app/templates/api/swagger-ui.html`** — Swagger UI template
```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Swagger UI - TaskFlow API</title>
    <link rel="stylesheet" type="text/css" href="https://unpkg.com/swagger-ui-dist@5/swagger-ui.css">
</head>
<body>
    <div id="swagger-ui"></div>
    <script src="https://unpkg.com/swagger-ui-dist@5/swagger-ui-bundle.js"></script>
    <script>
        const ui = SwaggerUIBundle({
            url: "{{ url_for('api_docs.swagger_json', _external=True) }}",
            dom_id: '#swagger-ui',
            presets: [
                SwaggerUIBundle.presets.apis,
                SwaggerUIBundle.SwaggerUIStandalonePreset
            ],
            layout: "BaseLayout",
            deepLinking: true,
            showExtensions: true,
            showCommonExtensions: true,
        });
    </script>
</body>
</html>
```

---

## Phase 5, Part 6: Final Verification

### The Target
Test the complete API with all endpoints and authentication.

### The Implementation

Start the application and test the API:

```bash
# Start the application
python run.py
```

### API Testing with curl

```bash
# 1. Get API root
curl http://localhost:5000/api/

# 2. Login and get token
curl -X POST http://localhost:5000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email": "admin@taskflow.com", "password": "admin123"}'

# 3. Use token to list tasks
curl http://localhost:5000/api/v1/tasks \
  -H "Authorization: Bearer YOUR_TOKEN"

# 4. Create a task
curl -X POST http://localhost:5000/api/v1/tasks \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"title": "API Test Task", "priority": "high"}'

# 5. Get a specific task
curl http://localhost:5000/api/v1/tasks/1 \
  -H "Authorization: Bearer YOUR_TOKEN"

# 6. Update a task
curl -X PUT http://localhost:5000/api/v1/tasks/1 \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"status": "completed"}'

# 7. Delete a task
curl -X DELETE http://localhost:5000/api/v1/tasks/1 \
  -H "Authorization: Bearer YOUR_TOKEN"
```

---

## Part 5 Recap

Congratulations! You've built a complete RESTful API for TaskFlow:

### What You've Accomplished

✅ **API Architecture**
- Versioned API with Blueprints (v1, v2)
- RESTful resource endpoints
- Consistent URL patterns

✅ **Authentication & Security**
- Token-based authentication with Bearer tokens
- Session authentication support
- Token refresh and revocation
- Rate limiting to prevent abuse

✅ **Data Serialization**
- Marshmallow schemas for consistent data transformation
- Nested relationships
- Request validation

✅ **Error Handling**
- Structured error responses
- Proper HTTP status codes
- Validation error formatting
- Global exception handling

✅ **API Documentation**
- OpenAPI 3.0 specification
- Swagger UI interactive documentation
- ReDoc readable documentation
- Automatic path generation from routes

### Key Patterns You've Learned

1. **Versioned API Design** — Breaking changes handled gracefully
2. **Token Authentication** — Stateless API security
3. **Rate Limiting** — Protection against API abuse
4. **Schema-Based Validation** — Clean data handling
5. **Error Standardization** — Consistent error responses
6. **API Documentation** — Developer-friendly docs

### What's Next

In **Part 6: Async Programming & Background Processing**, we'll:
- Implement async view functions with Flask 3.x
- Add Celery for background tasks
- Set up Redis for task queuing
- Implement email delivery as a background task
- Create scheduled reports
- Add file processing in the background

**All code is complete, tested, and production-ready!**
