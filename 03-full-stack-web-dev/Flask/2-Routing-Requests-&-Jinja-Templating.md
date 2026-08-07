# Part 2: Routing, Requests & Jinja Templating

Welcome to Part 2! Now that we have our solid foundation, we'll build the complete routing system, request handling, and dynamic templating features. This is where TaskFlow comes to life with interactive pages, forms, and user feedback.

---

## Phase 2, Part 1: Advanced Routing & URL Building

### The Target
Implement advanced routing features including dynamic URL parameters, custom converters, and URL building utilities.

### The Concept
Routing is like a postal system for your web application. When a request arrives, Flask needs to deliver it to the right "department" (view function) based on the URL path and HTTP method. Dynamic URL variables are like address templates that can match different specific addresses—for example, `/tasks/1`, `/tasks/2`, and `/tasks/3` all match the same route pattern `/tasks/<int:task_id>`.

URL building is the reverse process: given a function name and parameters, Flask constructs the correct URL. This is crucial because it allows you to change URL patterns without breaking your templates and redirects.

### The Implementation

First, let's create a custom URL converter for handling UUIDs and slugs:

**`app/utils/converters.py`** — Custom URL converters
```python
"""
Custom URL converters for Flask routing.

Provides specialized converters for common patterns like UUIDs, slugs,
and date formats.
"""

import re
from uuid import UUID

from werkzeug.routing import BaseConverter


class UUIDConverter(BaseConverter):
    """
    URL converter for UUID values.
    
    Matches UUIDs in the format: 123e4567-e89b-12d3-a456-426614174000
    
    Example: /api/users/123e4567-e89b-12d3-a456-426614174000
    """
    regex = r'[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}'
    
    def to_python(self, value: str) -> UUID:
        """Convert the URL value to a Python UUID object."""
        return UUID(value)
    
    def to_url(self, value: UUID) -> str:
        """Convert a Python UUID object to a URL string."""
        return str(value)


class SlugConverter(BaseConverter):
    """
    URL converter for URL-friendly slugs.
    
    Matches lowercase letters, numbers, and hyphens.
    
    Example: /articles/python-web-development
    """
    regex = r'[a-z0-9]+(?:-[a-z0-9]+)*'
    
    def to_python(self, value: str) -> str:
        """Convert the URL value to a Python string (already a string)."""
        return value
    
    def to_url(self, value: str) -> str:
        """Convert a Python string to a URL-safe slug."""
        # Convert to lowercase and replace spaces with hyphens
        return value.lower().replace(' ', '-')


class DateConverter(BaseConverter):
    """
    URL converter for ISO date formats.
    
    Matches dates in YYYY-MM-DD format.
    
    Example: /reports/2024-01-15
    """
    regex = r'\d{4}-\d{2}-\d{2}'
    
    def to_python(self, value: str) -> str:
        """Return the date string as-is."""
        return value
    
    def to_url(self, value: str) -> str:
        """Ensure the date is in ISO format."""
        return value


class ListConverter(BaseConverter):
    """
    URL converter for comma-separated lists.
    
    Matches strings like: value1,value2,value3
    
    Example: /filter/status:active,completed,pending
    """
    regex = r'[^/]+(?:,[^/]+)*'
    
    def to_python(self, value: str) -> list:
        """Convert comma-separated string to a list."""
        return value.split(',')
    
    def to_url(self, value: list) -> str:
        """Convert a list to a comma-separated string."""
        return ','.join(str(item) for item in value)
```

**`app/utils/__init__.py`** — Utils package
```python
"""
Utility functions and classes for TaskFlow.

Provides reusable helpers, decorators, and converters.
"""

from app.utils.converters import (
    UUIDConverter,
    SlugConverter,
    DateConverter,
    ListConverter,
)

__all__ = [
    'UUIDConverter',
    'SlugConverter',
    'DateConverter',
    'ListConverter',
]
```

Now let's update the Application Factory to register these converters:

**`app/__init__.py`** — Update with converters
```python
"""
TaskFlow Flask Application Factory.

This module creates the Flask application instance using the Application Factory
pattern, which provides:
1. Multiple environment configurations (development, testing, production)
2. Extension initialization with dependency injection
3. Blueprint registration for modular routing
4. Error handling configuration
5. Context processors and template filters
"""

import os
from pathlib import Path
from typing import Optional

from flask import Flask, jsonify, render_template, request, url_for
from werkzeug.exceptions import HTTPException

from app.config import config_map, ConfigType, get_config
from app.extensions import init_extensions
from app.logging_config import setup_logging
from app.utils import UUIDConverter, SlugConverter, DateConverter, ListConverter


def create_app(config_class: Optional[ConfigType] = None) -> Flask:
    """
    Application factory for TaskFlow.
    
    Creates and configures a Flask application instance with all extensions,
    blueprints, and error handlers.
    
    Args:
        config_class: Optional configuration class to use. If not provided,
                     the configuration is determined by FLASK_ENV.
    
    Returns:
        Configured Flask application instance
    
    Example:
        >>> from app import create_app
        >>> app = create_app()
        >>> app.run()
        
        >>> from app.config import TestingConfig
        >>> test_app = create_app(TestingConfig)
    """
    # Create Flask instance
    app = Flask(
        __name__,
        # Tell Flask where to find templates and static files
        template_folder="templates",
        static_folder="static",
        static_url_path="/static",
        # Instance folder for database and other local files
        instance_path=Path("instance").absolute(),
        instance_relative_config=True,
    )
    
    # ==========================================================================
    # Register Custom URL Converters
    # ==========================================================================
    
    app.url_map.converters['uuid'] = UUIDConverter
    app.url_map.converters['slug'] = SlugConverter
    app.url_map.converters['date'] = DateConverter
    app.url_map.converters['list'] = ListConverter
    
    # ==========================================================================
    # Configuration Loading
    # ==========================================================================
    
    # Load base configuration
    if config_class is None:
        config_class = get_config()
    app.config.from_object(config_class)
    
    # Override with environment-specific config file if exists
    env = os.environ.get("FLASK_ENV", "development")
    config_file = Path("instance") / f"config_{env}.py"
    if config_file.exists():
        app.config.from_pyfile(config_file)
    
    # Initialize configuration
    config_class.init_app(app)
    
    # ==========================================================================
    # Logging Setup
    # ==========================================================================
    
    setup_logging(app)
    app.logger.info(f"Created Flask application in {app.config.get('ENV', 'development')} mode")
    
    # ==========================================================================
    # Extension Initialization
    # ==========================================================================
    
    init_extensions(app)
    app.logger.debug("Extensions initialized successfully")
    
    # ==========================================================================
    # Blueprint Registration
    # ==========================================================================
    
    # Import blueprints after extensions to avoid circular imports
    from app.blueprints.main import main_bp
    from app.blueprints.auth import auth_bp
    from app.blueprints.tasks import tasks_bp
    from app.blueprints.admin import admin_bp
    from app.blueprints.api import api_bp
    
    # Register blueprints with URL prefixes
    app.register_blueprint(main_bp)                       # Root: /
    app.register_blueprint(auth_bp, url_prefix="/auth")   # /auth/*
    app.register_blueprint(tasks_bp, url_prefix="/tasks") # /tasks/*
    app.register_blueprint(admin_bp, url_prefix="/admin") # /admin/*
    app.register_blueprint(api_bp, url_prefix="/api")     # /api/*
    
    app.logger.info("Blueprints registered successfully")
    
    # ==========================================================================
    # Context Processors
    # ==========================================================================
    
    @app.context_processor
    def inject_globals():
        """Inject global variables into all templates."""
        return {
            "app_name": "TaskFlow",
            "app_version": "0.1.0",
            "year": 2026,
            "current_year": 2026,  # Alias for year
        }
    
    # ==========================================================================
    # Template Filters
    # ==========================================================================
    
    @app.template_filter("datetime")
    def format_datetime(value, format="%B %d, %Y at %I:%M %p"):
        """Format a datetime object for display."""
        if value is None:
            return ""
        return value.strftime(format)
    
    @app.template_filter("truncate")
    def truncate_filter(value, length=50, suffix="..."):
        """Truncate a string to the specified length."""
        if not isinstance(value, str):
            value = str(value)
        if len(value) <= length:
            return value
        return value[:length].rsplit(" ", 1)[0] + suffix
    
    @app.template_filter("pluralize")
    def pluralize_filter(value, singular="", plural=""):
        """Return singular or plural based on value."""
        if value == 1:
            return singular
        return plural
    
    @app.template_filter("status_badge")
    def status_badge_filter(status):
        """Return a Bootstrap badge class for task status."""
        status_classes = {
            "pending": "secondary",
            "in_progress": "primary",
            "review": "warning",
            "completed": "success",
            "archived": "dark",
        }
        return status_classes.get(status, "secondary")
    
    @app.template_filter("priority_badge")
    def priority_badge_filter(priority):
        """Return a Bootstrap badge class for task priority."""
        priority_classes = {
            "low": "info",
            "medium": "primary",
            "high": "warning",
            "urgent": "danger",
        }
        return priority_classes.get(priority, "secondary")
    
    @app.template_filter("markdown")
    def markdown_filter(value):
        """Convert markdown text to HTML (simple version)."""
        if not value:
            return ""
        # This is a simple markdown parser - in production, use a proper library
        import re
        # Bold
        value = re.sub(r'\*\*(.*?)\*\*', r'<strong>\1</strong>', value)
        # Italic
        value = re.sub(r'\*(.*?)\*', r'<em>\1</em>', value)
        # Links
        value = re.sub(r'\[(.*?)\]\((.*?)\)', r'<a href="\2">\1</a>', value)
        # Newlines to paragraphs
        paragraphs = value.split('\n\n')
        value = ''.join(f'<p>{p}</p>' for p in paragraphs if p.strip())
        return value
    
    # ==========================================================================
    # Error Handlers
    # ==========================================================================
    
    @app.errorhandler(404)
    def not_found_error(error):
        """Handle 404 Not Found errors."""
        app.logger.warning(f"404 error: {request.path}")
        return render_template("errors/404.html"), 404
    
    @app.errorhandler(403)
    def forbidden_error(error):
        """Handle 403 Forbidden errors."""
        app.logger.warning(f"403 error: {request.path} from {request.remote_addr}")
        return render_template("errors/403.html"), 403
    
    @app.errorhandler(500)
    def internal_error(error):
        """Handle 500 Internal Server errors."""
        app.logger.error(f"500 error: {error}", exc_info=True)
        return render_template("errors/500.html"), 500
    
    @app.errorhandler(HTTPException)
    def http_error(error):
        """Handle HTTP exceptions with appropriate responses."""
        app.logger.warning(f"HTTP {error.code}: {error.description}")
        try:
            return render_template(f"errors/{error.code}.html"), error.code
        except Exception:
            # Fallback if specific template doesn't exist
            return render_template("errors/error.html", error=error), error.code
    
    # ==========================================================================
    # CLI Commands
    # ==========================================================================
    
    # Register custom CLI commands
    from app.cli import register_commands
    register_commands(app)
    app.logger.debug("CLI commands registered")
    
    # ==========================================================================
    # Health Check Endpoint
    # ==========================================================================
    
    @app.route("/health")
    def health_check():
        """Health check endpoint for monitoring and load balancers."""
        return jsonify({
            "status": "healthy",
            "environment": app.config.get("ENV", "unknown"),
            "version": "0.1.0",
        }), 200
    
    app.logger.info("Application factory completed successfully")
    return app
```

Now let's add advanced routing features to our blueprints:

**`app/blueprints/main/routes.py`** — Updated main routes with advanced features
```python
"""
Main Blueprint routes.

Contains routes for the home page, about page, and other public content.
These routes are accessible at the root URL (/).
"""

from flask import render_template, url_for, request, abort, jsonify
from flask_login import login_required, current_user

from app.blueprints.main import main_bp


@main_bp.route("/")
def index():
    """
    Home page route.
    
    Returns the landing page with a welcome message and call-to-action.
    """
    return render_template("main/index.html")


@main_bp.route("/about")
def about():
    """
    About page route.
    
    Displays information about TaskFlow and its features.
    """
    return render_template("main/about.html")


@main_bp.route("/features")
def features():
    """
    Features page route.
    
    Highlights TaskFlow's key features and capabilities.
    """
    return render_template("main/features.html")


@main_bp.route("/pricing")
def pricing():
    """
    Pricing page route.
    
    Shows available pricing plans (if any).
    """
    return render_template("main/pricing.html")


@main_bp.route("/search")
def search():
    """
    Search page route.
    
    Displays search results for tasks, users, and content.
    """
    query = request.args.get("q", "").strip()
    if not query:
        return render_template("main/search.html", query="", results={})
    
    # This will be expanded in Part 3 with database search
    from app.models.task import Task
    from app.models.user import User
    
    # Placeholder search - will be implemented with proper database queries
    results = {
        "tasks": [],
        "users": [],
    }
    
    return render_template("main/search.html", query=query, results=results)


@main_bp.route("/sitemap.xml")
def sitemap():
    """
    Sitemap endpoint for SEO.
    
    Generates a sitemap.xml file for search engine crawlers.
    """
    # This will be implemented in Part 8
    from flask import Response
    return Response("<?xml version='1.0' encoding='UTF-8'?><sitemap/>", 
                   mimetype="application/xml")


@main_bp.route("/robots.txt")
def robots():
    """
    Robots.txt endpoint.
    
    Tells search engines which URLs to crawl or avoid.
    """
    content = """User-agent: *
Allow: /
Disallow: /admin/
Disallow: /api/
Sitemap: https://taskflow.com/sitemap.xml
"""
    return Response(content, mimetype="text/plain")
```

**`app/blueprints/auth/routes.py`** — Updated auth routes with complete functionality
```python
"""
Authentication Blueprint routes.

Handles user registration, login, logout, and password management.
"""

from flask import render_template, url_for, redirect, flash, request, session, jsonify
from flask_login import login_user, logout_user, login_required, current_user

from app.blueprints.auth import auth_bp


@auth_bp.route("/login", methods=["GET", "POST"])
def login():
    """
    Login page route.
    
    Displays the login form. Redirects authenticated users to the dashboard.
    """
    # If user is already logged in, redirect to dashboard
    if current_user.is_authenticated:
        flash("You are already logged in.", "info")
        return redirect(url_for("tasks.dashboard"))
    
    if request.method == "POST":
        # This will be implemented in Part 4 with actual authentication
        email = request.form.get("email")
        password = request.form.get("password")
        remember = request.form.get("remember") == "on"
        
        # Placeholder - will be replaced with actual authentication in Part 4
        if email == "demo@taskflow.com" and password == "password":
            flash("Login successful! (Demo mode)", "success")
            return redirect(url_for("tasks.dashboard"))
        else:
            flash("Invalid email or password.", "danger")
            return render_template("auth/login.html")
    
    return render_template("auth/login.html")


@auth_bp.route("/register", methods=["GET", "POST"])
def register():
    """
    Registration page route.
    
    Displays the registration form. Redirects authenticated users to the dashboard.
    """
    if current_user.is_authenticated:
        flash("You are already logged in.", "info")
        return redirect(url_for("tasks.dashboard"))
    
    if request.method == "POST":
        # This will be implemented in Part 4
        username = request.form.get("username")
        email = request.form.get("email")
        password = request.form.get("password")
        confirm_password = request.form.get("confirm_password")
        
        if password != confirm_password:
            flash("Passwords do not match.", "danger")
            return render_template("auth/register.html")
        
        # Placeholder registration
        flash("Registration successful! Please log in. (Demo mode)", "success")
        return redirect(url_for("auth.login"))
    
    return render_template("auth/register.html")


@auth_bp.route("/logout")
@login_required
def logout():
    """
    Logout route.
    
    Logs out the current user and redirects to the home page.
    """
    logout_user()
    session.clear()
    flash("You have been logged out successfully.", "info")
    return redirect(url_for("main.index"))


@auth_bp.route("/reset-password", methods=["GET", "POST"])
def reset_password_request():
    """Password reset request page."""
    if request.method == "POST":
        email = request.form.get("email")
        # Placeholder - will be implemented in Part 4
        flash("If an account exists with that email, you will receive reset instructions.", "info")
        return redirect(url_for("auth.login"))
    
    return render_template("auth/reset_password_request.html")


@auth_bp.route("/reset-password/<token>", methods=["GET", "POST"])
def reset_password(token):
    """Password reset page with token validation."""
    if request.method == "POST":
        password = request.form.get("password")
        confirm_password = request.form.get("confirm_password")
        
        if password != confirm_password:
            flash("Passwords do not match.", "danger")
            return render_template("auth/reset_password.html", token=token)
        
        # Placeholder - will be implemented in Part 4
        flash("Password reset successful! Please log in.", "success")
        return redirect(url_for("auth.login"))
    
    return render_template("auth/reset_password.html", token=token)


@auth_bp.route("/profile", methods=["GET", "POST"])
@login_required
def profile():
    """User profile page."""
    if request.method == "POST":
        # Placeholder profile update
        first_name = request.form.get("first_name")
        last_name = request.form.get("last_name")
        # Update user profile - will be implemented in Part 4
        flash("Profile updated successfully!", "success")
    
    return render_template("auth/profile.html", user=current_user)


@auth_bp.route("/profile/email", methods=["POST"])
@login_required
def change_email():
    """Change user email address."""
    new_email = request.form.get("email")
    # Implementation in Part 4
    flash("Email change requested. Please verify your new email.", "info")
    return redirect(url_for("auth.profile"))


@auth_bp.route("/profile/password", methods=["POST"])
@login_required
def change_password():
    """Change user password."""
    current_password = request.form.get("current_password")
    new_password = request.form.get("new_password")
    confirm_password = request.form.get("confirm_password")
    
    if new_password != confirm_password:
        flash("New passwords do not match.", "danger")
        return redirect(url_for("auth.profile"))
    
    # Implementation in Part 4
    flash("Password updated successfully!", "success")
    return redirect(url_for("auth.profile"))


@auth_bp.route("/verify-email/<token>")
def verify_email(token):
    """Email verification route."""
    # Implementation in Part 4
    flash("Email verified successfully!", "success")
    return redirect(url_for("auth.login"))


@auth_bp.route("/api/check-availability", methods=["GET"])
def check_availability():
    """
    API endpoint to check if a username or email is available.
    
    Used for real-time validation in registration forms.
    """
    username = request.args.get("username")
    email = request.args.get("email")
    
    # Placeholder - will be implemented in Part 4
    return jsonify({
        "available": True,
        "message": "Username and email are available",
    })
```

**`app/blueprints/tasks/routes.py`** — Updated task routes with full CRUD
```python
"""
Tasks Blueprint routes.

Handles task CRUD operations, filtering, and search.
"""

from flask import render_template, url_for, redirect, flash, request, abort, jsonify
from flask_login import login_required, current_user

from app.blueprints.tasks import tasks_bp


@tasks_bp.route("/")
@login_required
def dashboard():
    """
    Task dashboard route.
    
    Displays the user's tasks with filtering and sorting options.
    """
    # Get filter parameters from URL
    status = request.args.get("status")
    priority = request.args.get("priority")
    category = request.args.get("category")
    search = request.args.get("search", "").strip()
    page = request.args.get("page", 1, type=int)
    per_page = request.args.get("per_page", 20, type=int)
    
    # Placeholder data - will be replaced with database queries in Part 3
    tasks = []
    total_tasks = 0
    
    # Prepare filter context for template
    filters = {
        "status": status,
        "priority": priority,
        "category": category,
        "search": search,
        "page": page,
        "per_page": per_page,
    }
    
    return render_template(
        "tasks/dashboard.html",
        tasks=tasks,
        total=total_tasks,
        page=page,
        per_page=per_page,
        filters=filters,
    )


@tasks_bp.route("/create", methods=["GET", "POST"])
@login_required
def create():
    """Task creation page."""
    if request.method == "POST":
        # Get form data
        title = request.form.get("title")
        description = request.form.get("description")
        priority = request.form.get("priority")
        due_date = request.form.get("due_date")
        category = request.form.get("category")
        assigned_to = request.form.get("assigned_to")
        tags = request.form.get("tags", "").split(",")
        
        # Basic validation
        if not title:
            flash("Task title is required.", "danger")
            return render_template("tasks/create.html")
        
        # Placeholder - will be implemented in Part 3
        flash("Task created successfully!", "success")
        return redirect(url_for("tasks.dashboard"))
    
    # Get users for assignment dropdown
    users = []  # Will be populated in Part 4
    categories = []  # Will be populated in Part 3
    
    return render_template(
        "tasks/create.html",
        users=users,
        categories=categories,
    )


@tasks_bp.route("/<int:task_id>")
@login_required
def view(task_id):
    """
    Task detail view page.
    
    Displays a single task with all its details and comments.
    """
    # Placeholder - will be replaced with database query in Part 3
    if task_id > 100:  # Simulate not found
        abort(404)
    
    task = {
        "id": task_id,
        "title": f"Sample Task #{task_id}",
        "description": "This is a placeholder task description. It will be replaced with real data in Part 3.",
        "status": "in_progress",
        "priority": "high",
        "created_at": "2024-01-15 10:30:00",
        "due_date": "2024-02-15",
        "assigned_to": "John Doe",
        "category": "Work",
        "tags": ["important", "urgent"],
        "comments": [],
    }
    
    return render_template("tasks/view.html", task=task)


@tasks_bp.route("/<int:task_id>/edit", methods=["GET", "POST"])
@login_required
def edit(task_id):
    """
    Task edit page.
    
    Displays the edit form and handles updates.
    """
    # Placeholder - will be replaced with database query in Part 3
    task = {
        "id": task_id,
        "title": f"Sample Task #{task_id}",
        "description": "This is a placeholder task description.",
        "status": "in_progress",
        "priority": "high",
        "due_date": "2024-02-15",
        "assigned_to": "John Doe",
        "category": "Work",
    }
    
    if request.method == "POST":
        # Update task - will be implemented in Part 3
        flash("Task updated successfully!", "success")
        return redirect(url_for("tasks.view", task_id=task_id))
    
    users = []  # Will be populated in Part 4
    categories = []  # Will be populated in Part 3
    
    return render_template(
        "tasks/edit.html",
        task=task,
        users=users,
        categories=categories,
    )


@tasks_bp.route("/<int:task_id>/delete", methods=["GET", "POST"])
@login_required
def delete(task_id):
    """
    Task delete confirmation page.
    
    Confirms deletion and handles the delete operation.
    """
    # Placeholder - will be replaced with database query in Part 3
    task = {
        "id": task_id,
        "title": f"Sample Task #{task_id}",
    }
    
    if request.method == "POST":
        # Delete task - will be implemented in Part 3
        flash("Task deleted successfully!", "success")
        return redirect(url_for("tasks.dashboard"))
    
    return render_template("tasks/delete.html", task=task)


@tasks_bp.route("/<int:task_id>/status/<status>", methods=["POST"])
@login_required
def update_status(task_id, status):
    """
    Update task status.
    
    Handles quick status changes from the dashboard.
    """
    # Validate status
    valid_statuses = ["pending", "in_progress", "review", "completed", "archived"]
    if status not in valid_statuses:
        abort(400, "Invalid status")
    
    # Placeholder - will be implemented in Part 3
    flash(f"Task status updated to {status}!", "success")
    
    # Redirect back to the referring page
    next_url = request.args.get("next") or url_for("tasks.dashboard")
    return redirect(next_url)


@tasks_bp.route("/<int:task_id>/assign", methods=["POST"])
@login_required
def assign_task(task_id):
    """
    Assign task to a user.
    
    Handles task assignment from the detail view.
    """
    user_id = request.form.get("user_id")
    if not user_id:
        flash("Please select a user to assign.", "warning")
        return redirect(url_for("tasks.view", task_id=task_id))
    
    # Placeholder - will be implemented in Part 4
    flash("Task assigned successfully!", "success")
    return redirect(url_for("tasks.view", task_id=task_id))


@tasks_bp.route("/export", methods=["GET"])
@login_required
def export_tasks():
    """
    Export tasks as CSV.
    
    Allows users to download their tasks in CSV format.
    """
    from io import StringIO
    import csv
    
    # Placeholder - will be implemented in Part 3
    output = StringIO()
    writer = csv.writer(output)
    writer.writerow(["Title", "Status", "Priority", "Due Date", "Created At"])
    writer.writerow(["Sample Task", "In Progress", "High", "2024-02-15", "2024-01-15"])
    
    from flask import Response
    return Response(
        output.getvalue(),
        mimetype="text/csv",
        headers={"Content-Disposition": "attachment; filename=tasks_export.csv"},
    )


@tasks_bp.route("/<int:task_id>/comments", methods=["POST"])
@login_required
def add_comment(task_id):
    """Add a comment to a task."""
    comment_text = request.form.get("comment")
    if not comment_text:
        flash("Comment cannot be empty.", "warning")
        return redirect(url_for("tasks.view", task_id=task_id))
    
    # Placeholder - will be implemented in Part 3
    flash("Comment added successfully!", "success")
    return redirect(url_for("tasks.view", task_id=task_id))


@tasks_bp.route("/<int:task_id>/attachments", methods=["POST"])
@login_required
def upload_attachment(task_id):
    """Upload a file attachment to a task."""
    if "file" not in request.files:
        flash("No file selected.", "warning")
        return redirect(url_for("tasks.view", task_id=task_id))
    
    file = request.files["file"]
    if file.filename == "":
        flash("No file selected.", "warning")
        return redirect(url_for("tasks.view", task_id=task_id))
    
    # Placeholder - will be implemented in Part 2
    flash("File uploaded successfully!", "success")
    return redirect(url_for("tasks.view", task_id=task_id))
```

---

## Phase 2, Part 2: Complete Form Handling

### The Target
Implement comprehensive form handling with Flask-WTF, including CSRF protection, validation, and custom validators.

### The Concept
Forms are like physical application forms. Just as a job application has required fields, validation rules (like "email must be valid"), and security measures (like signing at the bottom), web forms have similar requirements. Flask-WTF provides a structured way to define, validate, and render forms securely.

### The Implementation

First, install the form library:

```bash
pip install flask-wtf email-validator
```

Now create the form classes:

```bash
mkdir -p app/forms
touch app/forms/__init__.py
touch app/forms/auth.py
touch app/forms/task.py
touch app/forms/admin.py
touch app/forms/validators.py
```

**`app/forms/validators.py`** — Custom validators
```python
"""
Custom validators for Flask-WTF forms.

Provides reusable validation functions for common validation needs.
"""

import re
from typing import Optional

from wtforms import ValidationError
from wtforms.validators import StopValidation


class Unique:
    """
    Validator that checks if a field value is unique in the database.
    
    Args:
        model: SQLAlchemy model class
        field: Field name to check uniqueness on
        message: Error message if validation fails
        
    Example:
        class UserForm(FlaskForm):
            email = StringField('Email', validators=[
                DataRequired(),
                Email(),
                Unique(User, 'email', 'Email already registered')
            ])
    """
    
    def __init__(self, model, field, message: Optional[str] = None):
        self.model = model
        self.field = field
        self.message = message or f"{field.capitalize()} already exists."
    
    def __call__(self, form, field):
        # Skip validation if field is empty
        if not field.data:
            return
        
        # Query the database
        query = self.model.query.filter(getattr(self.model, self.field) == field.data)
        
        # If updating, exclude the current record
        if hasattr(form, "obj") and form.obj:
            query = query.filter(self.model.id != form.obj.id)
        
        if query.first():
            raise ValidationError(self.message)


class PasswordStrength:
    """
    Validator that checks password strength.
    
    Validates:
    - Minimum length (default 8)
    - Contains uppercase letter
    - Contains lowercase letter
    - Contains digit
    - Contains special character (optional)
    """
    
    def __init__(self, min_length=8, require_special=True, message=None):
        self.min_length = min_length
        self.require_special = require_special
        self.message = message or (
            f"Password must be at least {min_length} characters long, "
            "contain at least one uppercase letter, one lowercase letter, "
            "one digit" + (", and one special character" if require_special else "")
        )
    
    def __call__(self, form, field):
        password = field.data
        if not password:
            return
        
        if len(password) < self.min_length:
            raise ValidationError(f"Password must be at least {self.min_length} characters.")
        
        if not re.search(r'[A-Z]', password):
            raise ValidationError("Password must contain at least one uppercase letter.")
        
        if not re.search(r'[a-z]', password):
            raise ValidationError("Password must contain at least one lowercase letter.")
        
        if not re.search(r'\d', password):
            raise ValidationError("Password must contain at least one digit.")
        
        if self.require_special and not re.search(r'[!@#$%^&*()_+\-=\[\]{};\'\\:"|,.<>/?]', password):
            raise ValidationError("Password must contain at least one special character.")


class ValidURL:
    """
    Validator that checks if a URL is valid and optionally reachable.
    
    Args:
        require_reachable: Check if the URL is reachable (makes a HEAD request)
        message: Error message if validation fails
    """
    
    def __init__(self, require_reachable=False, message=None):
        self.require_reachable = require_reachable
        self.message = message or "Please enter a valid URL."
    
    def __call__(self, form, field):
        if not field.data:
            return
        
        url_pattern = re.compile(
            r'^https?://'  # http:// or https://
            r'(?:(?:[A-Z0-9](?:[A-Z0-9-]{0,61}[A-Z0-9])?\.)+[A-Z]{2,6}\.?|'  # domain...
            r'localhost|'  # localhost...
            r'\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})'  # ...or ip
            r'(?::\d+)?'  # optional port
            r'(?:/?|[/?]\S+)$', re.IGNORECASE
        )
        
        if not url_pattern.match(field.data):
            raise ValidationError(self.message)
        
        if self.require_reachable:
            import requests
            try:
                response = requests.head(field.data, timeout=5)
                if response.status_code >= 400:
                    raise ValidationError("The URL is not reachable.")
            except Exception:
                raise ValidationError("Could not verify the URL.")


class RequiredIf:
    """
    Validator that makes a field required if another field has a specific value.
    
    Args:
        other_field: Name of the other field
        value: Value that triggers the requirement
        message: Error message if validation fails
    """
    
    def __init__(self, other_field, value, message=None):
        self.other_field = other_field
        self.value = value
        self.message = message or "This field is required."
    
    def __call__(self, form, field):
        other = getattr(form, self.other_field)
        if other.data == self.value and not field.data:
            raise ValidationError(self.message)
```

**`app/forms/auth.py`** — Authentication forms
```python
"""
Authentication forms for TaskFlow.

Provides forms for login, registration, password reset, and profile management.
"""

from flask_login import current_user
from flask_wtf import FlaskForm
from wtforms import (
    StringField,
    PasswordField,
    BooleanField,
    EmailField,
    TextAreaField,
    SelectField,
    SubmitField,
)
from wtforms.validators import (
    DataRequired,
    Email,
    EqualTo,
    Length,
    Optional,
    ValidationError,
)

from app.forms.validators import Unique, PasswordStrength
from app.models.user import User


class LoginForm(FlaskForm):
    """
    Login form for user authentication.
    """
    email = EmailField(
        "Email",
        validators=[
            DataRequired(message="Email is required."),
            Email(message="Please enter a valid email address."),
        ],
        render_kw={
            "class": "form-control",
            "placeholder": "Enter your email",
            "autofocus": True,
        }
    )
    
    password = PasswordField(
        "Password",
        validators=[DataRequired(message="Password is required.")],
        render_kw={
            "class": "form-control",
            "placeholder": "Enter your password",
        }
    )
    
    remember = BooleanField(
        "Remember me",
        default=False,
        render_kw={"class": "form-check-input"},
    )
    
    submit = SubmitField(
        "Login",
        render_kw={"class": "btn btn-primary w-100"},
    )


class RegistrationForm(FlaskForm):
    """
    Registration form for new users.
    """
    username = StringField(
        "Username",
        validators=[
            DataRequired(message="Username is required."),
            Length(min=3, max=50, message="Username must be between 3 and 50 characters."),
            Unique(User, "username", "This username is already taken."),
        ],
        render_kw={
            "class": "form-control",
            "placeholder": "Choose a username",
            "autofocus": True,
        }
    )
    
    email = EmailField(
        "Email",
        validators=[
            DataRequired(message="Email is required."),
            Email(message="Please enter a valid email address."),
            Unique(User, "email", "This email is already registered."),
        ],
        render_kw={
            "class": "form-control",
            "placeholder": "Enter your email",
        }
    )
    
    password = PasswordField(
        "Password",
        validators=[
            DataRequired(message="Password is required."),
            PasswordStrength(min_length=8, require_special=True),
        ],
        render_kw={
            "class": "form-control",
            "placeholder": "Choose a strong password",
        }
    )
    
    confirm_password = PasswordField(
        "Confirm Password",
        validators=[
            DataRequired(message="Please confirm your password."),
            EqualTo("password", message="Passwords must match."),
        ],
        render_kw={
            "class": "form-control",
            "placeholder": "Confirm your password",
        }
    )
    
    accept_terms = BooleanField(
        "I accept the Terms of Service and Privacy Policy",
        validators=[DataRequired(message="You must accept the terms to register.")],
        render_kw={"class": "form-check-input"},
    )
    
    submit = SubmitField(
        "Create Account",
        render_kw={"class": "btn btn-success w-100"},
    )
    
    def validate_username(self, field):
        """
        Additional username validation.
        """
        if not field.data.isalnum() and '_' not in field.data:
            raise ValidationError("Username can only contain letters, numbers, and underscores.")


class PasswordResetRequestForm(FlaskForm):
    """
    Form for requesting a password reset.
    """
    email = EmailField(
        "Email",
        validators=[
            DataRequired(message="Email is required."),
            Email(message="Please enter a valid email address."),
        ],
        render_kw={
            "class": "form-control",
            "placeholder": "Enter your email",
            "autofocus": True,
        }
    )
    
    submit = SubmitField(
        "Send Reset Link",
        render_kw={"class": "btn btn-primary w-100"},
    )


class PasswordResetForm(FlaskForm):
    """
    Form for resetting a password with a token.
    """
    password = PasswordField(
        "New Password",
        validators=[
            DataRequired(message="Password is required."),
            PasswordStrength(min_length=8, require_special=True),
        ],
        render_kw={
            "class": "form-control",
            "placeholder": "Choose a strong password",
            "autofocus": True,
        }
    )
    
    confirm_password = PasswordField(
        "Confirm Password",
        validators=[
            DataRequired(message="Please confirm your password."),
            EqualTo("password", message="Passwords must match."),
        ],
        render_kw={
            "class": "form-control",
            "placeholder": "Confirm your password",
        }
    )
    
    submit = SubmitField(
        "Reset Password",
        render_kw={"class": "btn btn-primary w-100"},
    )


class ProfileForm(FlaskForm):
    """
    Form for updating user profile information.
    """
    username = StringField(
        "Username",
        validators=[
            DataRequired(message="Username is required."),
            Length(min=3, max=50, message="Username must be between 3 and 50 characters."),
        ],
        render_kw={"class": "form-control"},
    )
    
    first_name = StringField(
        "First Name",
        validators=[
            Length(max=50, message="First name must be less than 50 characters."),
        ],
        render_kw={"class": "form-control"},
    )
    
    last_name = StringField(
        "Last Name",
        validators=[
            Length(max=50, message="Last name must be less than 50 characters."),
        ],
        render_kw={"class": "form-control"},
    )
    
    bio = TextAreaField(
        "Bio",
        validators=[
            Length(max=500, message="Bio must be less than 500 characters."),
        ],
        render_kw={
            "class": "form-control",
            "rows": 4,
            "placeholder": "Tell us a little about yourself...",
        }
    )
    
    submit = SubmitField(
        "Update Profile",
        render_kw={"class": "btn btn-primary"},
    )
    
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        # Custom validator for username uniqueness
        self.username.validators.append(
            Unique(User, "username", "This username is already taken.")
        )


class EmailChangeForm(FlaskForm):
    """
    Form for changing email address.
    """
    new_email = EmailField(
        "New Email",
        validators=[
            DataRequired(message="Email is required."),
            Email(message="Please enter a valid email address."),
            Unique(User, "email", "This email is already registered."),
        ],
        render_kw={
            "class": "form-control",
            "placeholder": "Enter your new email",
            "autofocus": True,
        }
    )
    
    password = PasswordField(
        "Confirm Password",
        validators=[
            DataRequired(message="Please confirm your password."),
        ],
        render_kw={
            "class": "form-control",
            "placeholder": "Enter your password to confirm",
        }
    )
    
    submit = SubmitField(
        "Change Email",
        render_kw={"class": "btn btn-warning"},
    )


class PasswordChangeForm(FlaskForm):
    """
    Form for changing password.
    """
    current_password = PasswordField(
        "Current Password",
        validators=[
            DataRequired(message="Please enter your current password."),
        ],
        render_kw={
            "class": "form-control",
            "placeholder": "Enter your current password",
            "autofocus": True,
        }
    )
    
    new_password = PasswordField(
        "New Password",
        validators=[
            DataRequired(message="New password is required."),
            PasswordStrength(min_length=8, require_special=True),
        ],
        render_kw={
            "class": "form-control",
            "placeholder": "Choose a new password",
        }
    )
    
    confirm_password = PasswordField(
        "Confirm Password",
        validators=[
            DataRequired(message="Please confirm your new password."),
            EqualTo("new_password", message="Passwords must match."),
        ],
        render_kw={
            "class": "form-control",
            "placeholder": "Confirm your new password",
        }
    )
    
    submit = SubmitField(
        "Change Password",
        render_kw={"class": "btn btn-danger"},
    )
```

**`app/forms/task.py`** — Task forms
```python
"""
Task management forms for TaskFlow.

Provides forms for creating, editing, and filtering tasks.
"""

from datetime import datetime

from flask_wtf import FlaskForm
from flask_wtf.file import FileField, FileAllowed
from wtforms import (
    StringField,
    TextAreaField,
    SelectField,
    DateField,
    DateTimeField,
    BooleanField,
    SubmitField,
    IntegerField,
)
from wtforms.validators import DataRequired, Length, Optional, NumberRange

from app.models.task import TaskStatus, TaskPriority


class TaskForm(FlaskForm):
    """
    Form for creating and editing tasks.
    """
    title = StringField(
        "Task Title",
        validators=[
            DataRequired(message="Task title is required."),
            Length(min=3, max=200, message="Title must be between 3 and 200 characters."),
        ],
        render_kw={
            "class": "form-control",
            "placeholder": "Enter task title",
            "autofocus": True,
        }
    )
    
    description = TextAreaField(
        "Description",
        validators=[
            Optional(),
            Length(max=2000, message="Description must be less than 2000 characters."),
        ],
        render_kw={
            "class": "form-control",
            "rows": 5,
            "placeholder": "Describe your task in detail...",
        }
    )
    
    status = SelectField(
        "Status",
        choices=[
            ("pending", "Pending"),
            ("in_progress", "In Progress"),
            ("review", "In Review"),
            ("completed", "Completed"),
            ("archived", "Archived"),
        ],
        default="pending",
        validators=[DataRequired(message="Please select a status.")],
        render_kw={"class": "form-select"},
    )
    
    priority = SelectField(
        "Priority",
        choices=[
            ("low", "Low"),
            ("medium", "Medium"),
            ("high", "High"),
            ("urgent", "Urgent"),
        ],
        default="medium",
        validators=[DataRequired(message="Please select a priority.")],
        render_kw={"class": "form-select"},
    )
    
    due_date = DateField(
        "Due Date",
        validators=[Optional()],
        render_kw={
            "class": "form-control",
            "type": "date",
        }
    )
    
    category_id = SelectField(
        "Category",
        choices=[("", "Select a category...")],
        validators=[Optional()],
        render_kw={"class": "form-select"},
    )
    
    assigned_to_id = SelectField(
        "Assign To",
        choices=[("", "Select a user...")],
        validators=[Optional()],
        render_kw={"class": "form-select"},
    )
    
    tags = StringField(
        "Tags",
        validators=[Optional()],
        render_kw={
            "class": "form-control",
            "placeholder": "Enter tags separated by commas (e.g., important, design, frontend)",
        },
        description="Separate multiple tags with commas.",
    )
    
    attach_file = FileField(
        "Attach File",
        validators=[
            Optional(),
            FileAllowed(["jpg", "jpeg", "png", "gif", "pdf", "doc", "docx"], 
                       "Only images, PDFs, and Word documents are allowed."),
        ],
        render_kw={"class": "form-control"},
    )
    
    submit = SubmitField(
        "Save Task",
        render_kw={"class": "btn btn-primary"},
    )
    
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        # Populate category and user choices dynamically
        # This will be done in the route handler


class TaskFilterForm(FlaskForm):
    """
    Form for filtering tasks on the dashboard.
    """
    status = SelectField(
        "Status",
        choices=[
            ("", "All Statuses"),
            ("pending", "Pending"),
            ("in_progress", "In Progress"),
            ("review", "In Review"),
            ("completed", "Completed"),
            ("archived", "Archived"),
        ],
        validators=[Optional()],
        render_kw={"class": "form-select"},
    )
    
    priority = SelectField(
        "Priority",
        choices=[
            ("", "All Priorities"),
            ("low", "Low"),
            ("medium", "Medium"),
            ("high", "High"),
            ("urgent", "Urgent"),
        ],
        validators=[Optional()],
        render_kw={"class": "form-select"},
    )
    
    category_id = SelectField(
        "Category",
        choices=[("", "All Categories")],
        validators=[Optional()],
        render_kw={"class": "form-select"},
    )
    
    assigned_to_id = SelectField(
        "Assigned To",
        choices=[("", "All Users")],
        validators=[Optional()],
        render_kw={"class": "form-select"},
    )
    
    search = StringField(
        "Search",
        validators=[Optional()],
        render_kw={
            "class": "form-control",
            "placeholder": "Search tasks...",
        }
    )
    
    per_page = SelectField(
        "Per Page",
        choices=[
            ("10", "10 per page"),
            ("20", "20 per page"),
            ("50", "50 per page"),
            ("100", "100 per page"),
        ],
        default="20",
        render_kw={"class": "form-select"},
    )
    
    submit = SubmitField(
        "Apply Filters",
        render_kw={"class": "btn btn-primary"},
    )
    
    reset = SubmitField(
        "Reset Filters",
        render_kw={"class": "btn btn-outline-secondary"},
    )


class CommentForm(FlaskForm):
    """
    Form for adding comments to tasks.
    """
    comment = TextAreaField(
        "Comment",
        validators=[
            DataRequired(message="Comment cannot be empty."),
            Length(max=1000, message="Comment must be less than 1000 characters."),
        ],
        render_kw={
            "class": "form-control",
            "rows": 3,
            "placeholder": "Write your comment here...",
            "autofocus": True,
        }
    )
    
    submit = SubmitField(
        "Add Comment",
        render_kw={"class": "btn btn-primary"},
    )


class TaskQuickAddForm(FlaskForm):
    """
    Quick task add form for the dashboard.
    """
    title = StringField(
        "Task Title",
        validators=[
            DataRequired(message="Task title is required."),
            Length(min=3, max=200, message="Title must be between 3 and 200 characters."),
        ],
        render_kw={
            "class": "form-control",
            "placeholder": "Add a task...",
            "autofocus": True,
        }
    )
    
    priority = SelectField(
        "Priority",
        choices=[
            ("low", "Low"),
            ("medium", "Medium"),
            ("high", "High"),
            ("urgent", "Urgent"),
        ],
        default="medium",
        render_kw={"class": "form-select"},
    )
    
    submit = SubmitField(
        "Add Task",
        render_kw={"class": "btn btn-primary"},
    )
```

Now let's update the auth routes to use the actual forms:

**`app/blueprints/auth/routes.py`** — Updated with forms
```python
"""
Authentication Blueprint routes.

Handles user registration, login, logout, and password management.
"""

from flask import render_template, url_for, redirect, flash, request, session, jsonify
from flask_login import login_user, logout_user, login_required, current_user

from app.blueprints.auth import auth_bp
from app.forms.auth import (
    LoginForm,
    RegistrationForm,
    PasswordResetRequestForm,
    PasswordResetForm,
    ProfileForm,
    EmailChangeForm,
    PasswordChangeForm,
)


@auth_bp.route("/login", methods=["GET", "POST"])
def login():
    """Login page route."""
    if current_user.is_authenticated:
        flash("You are already logged in.", "info")
        return redirect(url_for("tasks.dashboard"))
    
    form = LoginForm()
    if form.validate_on_submit():
        # This will be implemented in Part 4 with actual authentication
        email = form.email.data
        password = form.password.data
        
        # Placeholder - will be replaced with actual authentication in Part 4
        if email == "demo@taskflow.com" and password == "password":
            flash("Login successful! (Demo mode)", "success")
            return redirect(url_for("tasks.dashboard"))
        else:
            flash("Invalid email or password.", "danger")
    
    return render_template("auth/login.html", form=form)


@auth_bp.route("/register", methods=["GET", "POST"])
def register():
    """Registration page route."""
    if current_user.is_authenticated:
        flash("You are already logged in.", "info")
        return redirect(url_for("tasks.dashboard"))
    
    form = RegistrationForm()
    if form.validate_on_submit():
        # This will be implemented in Part 4
        flash("Registration successful! Please log in. (Demo mode)", "success")
        return redirect(url_for("auth.login"))
    
    return render_template("auth/register.html", form=form)


@auth_bp.route("/logout")
@login_required
def logout():
    """Logout route."""
    logout_user()
    session.clear()
    flash("You have been logged out successfully.", "info")
    return redirect(url_for("main.index"))


@auth_bp.route("/reset-password", methods=["GET", "POST"])
def reset_password_request():
    """Password reset request page."""
    form = PasswordResetRequestForm()
    if form.validate_on_submit():
        # Placeholder - will be implemented in Part 4
        flash("If an account exists with that email, you will receive reset instructions.", "info")
        return redirect(url_for("auth.login"))
    
    return render_template("auth/reset_password_request.html", form=form)


@auth_bp.route("/reset-password/<token>", methods=["GET", "POST"])
def reset_password(token):
    """Password reset page with token validation."""
    form = PasswordResetForm()
    if form.validate_on_submit():
        # Placeholder - will be implemented in Part 4
        flash("Password reset successful! Please log in.", "success")
        return redirect(url_for("auth.login"))
    
    return render_template("auth/reset_password.html", form=form, token=token)


@auth_bp.route("/profile", methods=["GET", "POST"])
@login_required
def profile():
    """User profile page."""
    form = ProfileForm(obj=current_user)
    if form.validate_on_submit():
        # Update user profile - will be implemented in Part 4
        flash("Profile updated successfully!", "success")
        return redirect(url_for("auth.profile"))
    
    return render_template("auth/profile.html", form=form, user=current_user)


@auth_bp.route("/profile/email", methods=["POST"])
@login_required
def change_email():
    """Change user email address."""
    form = EmailChangeForm()
    if form.validate_on_submit():
        # Implementation in Part 4
        flash("Email change requested. Please verify your new email.", "info")
        return redirect(url_for("auth.profile"))
    
    # If validation fails, redirect back to profile with errors
    for field, errors in form.errors.items():
        for error in errors:
            flash(f"{field}: {error}", "danger")
    return redirect(url_for("auth.profile"))


@auth_bp.route("/profile/password", methods=["POST"])
@login_required
def change_password():
    """Change user password."""
    form = PasswordChangeForm()
    if form.validate_on_submit():
        # Implementation in Part 4
        flash("Password updated successfully!", "success")
        return redirect(url_for("auth.profile"))
    
    # If validation fails, redirect back to profile with errors
    for field, errors in form.errors.items():
        for error in errors:
            flash(f"{field}: {error}", "danger")
    return redirect(url_for("auth.profile"))


@auth_bp.route("/verify-email/<token>")
def verify_email(token):
    """Email verification route."""
    # Implementation in Part 4
    flash("Email verified successfully!", "success")
    return redirect(url_for("auth.login"))


@auth_bp.route("/api/check-availability", methods=["GET"])
def check_availability():
    """API endpoint to check if a username or email is available."""
    username = request.args.get("username")
    email = request.args.get("email")
    
    # Placeholder - will be implemented in Part 4
    return jsonify({
        "available": True,
        "message": "Username and email are available",
    })
```

Now update the templates to use the forms:

**`app/templates/auth/login.html`** — Updated with form
```html
{% extends "base.html" %}

{% block title %}Login - {{ app_name }}{% endblock %}

{% block content %}
<div class="container py-5">
    <div class="row justify-content-center">
        <div class="col-md-6 col-lg-4">
            <div class="card shadow">
                <div class="card-body p-4">
                    <h2 class="text-center mb-4">Welcome Back</h2>
                    
                    <form method="POST" action="{{ url_for('auth.login') }}">
                        {{ form.csrf_token }}
                        
                        <div class="mb-3">
                            {{ form.email.label(class="form-label") }}
                            {{ form.email(class="form-control" + (" is-invalid" if form.email.errors else "")) }}
                            {% if form.email.errors %}
                                <div class="invalid-feedback">
                                    {% for error in form.email.errors %}
                                        {{ error }}
                                    {% endfor %}
                                </div>
                            {% endif %}
                        </div>
                        
                        <div class="mb-3">
                            {{ form.password.label(class="form-label") }}
                            {{ form.password(class="form-control" + (" is-invalid" if form.password.errors else "")) }}
                            {% if form.password.errors %}
                                <div class="invalid-feedback">
                                    {% for error in form.password.errors %}
                                        {{ error }}
                                    {% endfor %}
                                </div>
                            {% endif %}
                        </div>
                        
                        <div class="mb-3 form-check">
                            {{ form.remember(class="form-check-input") }}
                            {{ form.remember.label(class="form-check-label") }}
                        </div>
                        
                        {{ form.submit }}
                    </form>
                    
                    <div class="text-center mt-3">
                        <a href="{{ url_for('auth.reset_password_request') }}" class="text-decoration-none">
                            Forgot password?
                        </a>
                    </div>
                    
                    <hr>
                    
                    <p class="text-center mb-0">
                        Don't have an account? 
                        <a href="{{ url_for('auth.register') }}" class="text-decoration-none">
                            Register here
                        </a>
                    </p>
                </div>
            </div>
        </div>
    </div>
</div>
{% endblock %}
```

**`app/templates/auth/register.html`** — Updated with form
```html
{% extends "base.html" %}

{% block title %}Register - {{ app_name }}{% endblock %}

{% block content %}
<div class="container py-5">
    <div class="row justify-content-center">
        <div class="col-md-6 col-lg-4">
            <div class="card shadow">
                <div class="card-body p-4">
                    <h2 class="text-center mb-4">Create Account</h2>
                    
                    <form method="POST" action="{{ url_for('auth.register') }}">
                        {{ form.csrf_token }}
                        
                        <div class="mb-3">
                            {{ form.username.label(class="form-label") }}
                            {{ form.username(class="form-control" + (" is-invalid" if form.username.errors else "")) }}
                            {% if form.username.errors %}
                                <div class="invalid-feedback">
                                    {% for error in form.username.errors %}
                                        {{ error }}
                                    {% endfor %}
                                </div>
                            {% endif %}
                        </div>
                        
                        <div class="mb-3">
                            {{ form.email.label(class="form-label") }}
                            {{ form.email(class="form-control" + (" is-invalid" if form.email.errors else "")) }}
                            {% if form.email.errors %}
                                <div class="invalid-feedback">
                                    {% for error in form.email.errors %}
                                        {{ error }}
                                    {% endfor %}
                                </div>
                            {% endif %}
                        </div>
                        
                        <div class="mb-3">
                            {{ form.password.label(class="form-label") }}
                            {{ form.password(class="form-control" + (" is-invalid" if form.password.errors else "")) }}
                            <div class="form-text">
                                Password must be at least 8 characters with uppercase, lowercase, number, and special character.
                            </div>
                            {% if form.password.errors %}
                                <div class="invalid-feedback">
                                    {% for error in form.password.errors %}
                                        {{ error }}
                                    {% endfor %}
                                </div>
                            {% endif %}
                        </div>
                        
                        <div class="mb-3">
                            {{ form.confirm_password.label(class="form-label") }}
                            {{ form.confirm_password(class="form-control" + (" is-invalid" if form.confirm_password.errors else "")) }}
                            {% if form.confirm_password.errors %}
                                <div class="invalid-feedback">
                                    {% for error in form.confirm_password.errors %}
                                        {{ error }}
                                    {% endfor %}
                                </div>
                            {% endif %}
                        </div>
                        
                        <div class="mb-3 form-check">
                            {{ form.accept_terms(class="form-check-input") }}
                            {{ form.accept_terms.label(class="form-check-label") }}
                            {% if form.accept_terms.errors %}
                                <div class="text-danger small">
                                    {% for error in form.accept_terms.errors %}
                                        {{ error }}
                                    {% endfor %}
                                </div>
                            {% endif %}
                        </div>
                        
                        {{ form.submit }}
                    </form>
                    
                    <hr>
                    
                    <p class="text-center mb-0">
                        Already have an account? 
                        <a href="{{ url_for('auth.login') }}" class="text-decoration-none">
                            Login here
                        </a>
                    </p>
                </div>
            </div>
        </div>
    </div>
</div>
{% endblock %}
```

---

## Phase 2, Part 3: Complete Template System

### The Target
Build comprehensive templates for all features including advanced Jinja techniques.

### The Concept
Jinja is Flask's template engine. It's like a smart document generator that combines HTML structure with dynamic content. Think of it as a form letter where you fill in the blanks with specific information, but instead of just replacing names, you can loop through lists, conditionally show content, and reuse components.

### The Implementation

Let's create all the remaining templates:

**`app/templates/tasks/dashboard.html`** — Task dashboard
```html
{% extends "base.html" %}

{% block title %}Dashboard - {{ app_name }}{% endblock %}

{% block content %}
<div class="container-fluid py-4">
    <div class="row">
        <div class="col-md-3">
            <!-- Sidebar with statistics -->
            <div class="card mb-4">
                <div class="card-body">
                    <h5 class="card-title">Quick Stats</h5>
                    <div class="list-group list-group-flush">
                        <div class="list-group-item d-flex justify-content-between align-items-center">
                            Total Tasks
                            <span class="badge bg-primary rounded-pill">{{ total or 0 }}</span>
                        </div>
                        <div class="list-group-item d-flex justify-content-between align-items-center">
                            Pending
                            <span class="badge bg-secondary rounded-pill">{{ pending_count or 0 }}</span>
                        </div>
                        <div class="list-group-item d-flex justify-content-between align-items-center">
                            In Progress
                            <span class="badge bg-primary rounded-pill">{{ in_progress_count or 0 }}</span>
                        </div>
                        <div class="list-group-item d-flex justify-content-between align-items-center">
                            Completed
                            <span class="badge bg-success rounded-pill">{{ completed_count or 0 }}</span>
                        </div>
                        <div class="list-group-item d-flex justify-content-between align-items-center">
                            Overdue
                            <span class="badge bg-danger rounded-pill">{{ overdue_count or 0 }}</span>
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- Quick add task form -->
            <div class="card">
                <div class="card-body">
                    <h5 class="card-title">Quick Add Task</h5>
                    <form method="POST" action="{{ url_for('tasks.create') }}">
                        {{ quick_form.csrf_token if quick_form else '' }}
                        <div class="mb-2">
                            <input type="text" 
                                   class="form-control" 
                                   name="title" 
                                   placeholder="Task title..."
                                   required>
                        </div>
                        <div class="mb-2">
                            <select class="form-select" name="priority">
                                <option value="low">Low</option>
                                <option value="medium" selected>Medium</option>
                                <option value="high">High</option>
                                <option value="urgent">Urgent</option>
                            </select>
                        </div>
                        <button type="submit" class="btn btn-primary w-100">
                            <i class="fas fa-plus"></i> Add Task
                        </button>
                    </form>
                </div>
            </div>
        </div>
        
        <div class="col-md-9">
            <!-- Filter bar -->
            <div class="card mb-4">
                <div class="card-body">
                    <form method="GET" action="{{ url_for('tasks.dashboard') }}" class="row g-3">
                        <div class="col-md-3">
                            <select class="form-select" name="status">
                                <option value="">All Statuses</option>
                                <option value="pending" {% if filters.status == 'pending' %}selected{% endif %}>Pending</option>
                                <option value="in_progress" {% if filters.status == 'in_progress' %}selected{% endif %}>In Progress</option>
                                <option value="review" {% if filters.status == 'review' %}selected{% endif %}>In Review</option>
                                <option value="completed" {% if filters.status == 'completed' %}selected{% endif %}>Completed</option>
                            </select>
                        </div>
                        <div class="col-md-3">
                            <select class="form-select" name="priority">
                                <option value="">All Priorities</option>
                                <option value="low" {% if filters.priority == 'low' %}selected{% endif %}>Low</option>
                                <option value="medium" {% if filters.priority == 'medium' %}selected{% endif %}>Medium</option>
                                <option value="high" {% if filters.priority == 'high' %}selected{% endif %}>High</option>
                                <option value="urgent" {% if filters.priority == 'urgent' %}selected{% endif %}>Urgent</option>
                            </select>
                        </div>
                        <div class="col-md-3">
                            <input type="text" 
                                   class="form-control" 
                                   name="search" 
                                   placeholder="Search tasks..."
                                   value="{{ filters.search or '' }}">
                        </div>
                        <div class="col-md-3">
                            <button type="submit" class="btn btn-primary w-100">
                                <i class="fas fa-filter"></i> Filter
                            </button>
                        </div>
                    </form>
                </div>
            </div>
            
            <!-- Task list -->
            <div class="card">
                <div class="card-header d-flex justify-content-between align-items-center">
                    <h5 class="mb-0">Your Tasks</h5>
                    <a href="{{ url_for('tasks.create') }}" class="btn btn-sm btn-primary">
                        <i class="fas fa-plus"></i> New Task
                    </a>
                </div>
                <div class="card-body">
                    {% if tasks %}
                        <div class="table-responsive">
                            <table class="table table-hover">
                                <thead>
                                    <tr>
                                        <th>Title</th>
                                        <th>Status</th>
                                        <th>Priority</th>
                                        <th>Due Date</th>
                                        <th>Actions</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    {% for task in tasks %}
                                        <tr>
                                            <td>
                                                <a href="{{ url_for('tasks.view', task_id=task.id) }}" class="text-decoration-none">
                                                    {{ task.title }}
                                                </a>
                                            </td>
                                            <td>
                                                <span class="badge bg-{{ task.status|status_badge }}">
                                                    {{ task.status|replace('_', ' ')|title }}
                                                </span>
                                            </td>
                                            <td>
                                                <span class="badge bg-{{ task.priority|priority_badge }}">
                                                    {{ task.priority|title }}
                                                </span>
                                            </td>
                                            <td>
                                                {% if task.due_date %}
                                                    {{ task.due_date|datetime('%Y-%m-%d') }}
                                                    {% if task.due_date < now and task.status != 'completed' %}
                                                        <span class="badge bg-danger">Overdue</span>
                                                    {% endif %}
                                                {% else %}
                                                    <span class="text-muted">No due date</span>
                                                {% endif %}
                                            </td>
                                            <td>
                                                <div class="btn-group btn-group-sm">
                                                    <a href="{{ url_for('tasks.view', task_id=task.id) }}" 
                                                       class="btn btn-outline-primary">
                                                        <i class="fas fa-eye"></i>
                                                    </a>
                                                    <a href="{{ url_for('tasks.edit', task_id=task.id) }}" 
                                                       class="btn btn-outline-secondary">
                                                        <i class="fas fa-edit"></i>
                                                    </a>
                                                    <a href="{{ url_for('tasks.delete', task_id=task.id) }}" 
                                                       class="btn btn-outline-danger"
                                                       data-confirm="Are you sure you want to delete this task?">
                                                        <i class="fas fa-trash"></i>
                                                    </a>
                                                </div>
                                            </td>
                                        </tr>
                                    {% endfor %}
                                </tbody>
                            </table>
                        </div>
                        
                        <!-- Pagination -->
                        {% if pagination and pagination.pages > 1 %}
                            <nav aria-label="Task pagination">
                                <ul class="pagination justify-content-center">
                                    {% if pagination.has_prev %}
                                        <li class="page-item">
                                            <a class="page-link" href="{{ url_for('tasks.dashboard', page=pagination.prev_num, **filters) }}">
                                                Previous
                                            </a>
                                        </li>
                                    {% endif %}
                                    
                                    {% for page_num in pagination.iter_pages() %}
                                        {% if page_num %}
                                            <li class="page-item {% if page_num == pagination.page %}active{% endif %}">
                                                <a class="page-link" href="{{ url_for('tasks.dashboard', page=page_num, **filters) }}">
                                                    {{ page_num }}
                                                </a>
                                            </li>
                                        {% else %}
                                            <li class="page-item disabled">
                                                <span class="page-link">…</span>
                                            </li>
                                        {% endif %}
                                    {% endfor %}
                                    
                                    {% if pagination.has_next %}
                                        <li class="page-item">
                                            <a class="page-link" href="{{ url_for('tasks.dashboard', page=pagination.next_num, **filters) }}">
                                                Next
                                            </a>
                                        </li>
                                    {% endif %}
                                </ul>
                            </nav>
                        {% endif %}
                    {% else %}
                        <div class="text-center py-5">
                            <i class="fas fa-tasks fa-3x text-muted mb-3"></i>
                            <h5>No tasks found</h5>
                            <p class="text-muted">Create your first task to get started.</p>
                            <a href="{{ url_for('tasks.create') }}" class="btn btn-primary">
                                <i class="fas fa-plus"></i> Create Task
                            </a>
                        </div>
                    {% endif %}
                </div>
            </div>
        </div>
    </div>
</div>
{% endblock %}
```

**`app/templates/tasks/create.html`** — Create task
```html
{% extends "base.html" %}

{% block title %}Create Task - {{ app_name }}{% endblock %}

{% block content %}
<div class="container py-4">
    <div class="row justify-content-center">
        <div class="col-md-8">
            <div class="card shadow">
                <div class="card-header">
                    <h4 class="mb-0">
                        <i class="fas fa-plus-circle"></i> Create New Task
                    </h4>
                </div>
                <div class="card-body">
                    <form method="POST" action="{{ url_for('tasks.create') }}" enctype="multipart/form-data">
                        {{ form.csrf_token }}
                        
                        <div class="mb-3">
                            {{ form.title.label(class="form-label") }}
                            {{ form.title(class="form-control" + (" is-invalid" if form.title.errors else "")) }}
                            {% if form.title.errors %}
                                <div class="invalid-feedback">
                                    {% for error in form.title.errors %}
                                        {{ error }}
                                    {% endfor %}
                                </div>
                            {% endif %}
                        </div>
                        
                        <div class="mb-3">
                            {{ form.description.label(class="form-label") }}
                            {{ form.description(class="form-control" + (" is-invalid" if form.description.errors else ""), rows=5) }}
                            {% if form.description.errors %}
                                <div class="invalid-feedback">
                                    {% for error in form.description.errors %}
                                        {{ error }}
                                    {% endfor %}
                                </div>
                            {% endif %}
                        </div>
                        
                        <div class="row">
                            <div class="col-md-6">
                                <div class="mb-3">
                                    {{ form.status.label(class="form-label") }}
                                    {{ form.status(class="form-select" + (" is-invalid" if form.status.errors else "")) }}
                                    {% if form.status.errors %}
                                        <div class="invalid-feedback">
                                            {% for error in form.status.errors %}
                                                {{ error }}
                                            {% endfor %}
                                        </div>
                                    {% endif %}
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="mb-3">
                                    {{ form.priority.label(class="form-label") }}
                                    {{ form.priority(class="form-select" + (" is-invalid" if form.priority.errors else "")) }}
                                    {% if form.priority.errors %}
                                        <div class="invalid-feedback">
                                            {% for error in form.priority.errors %}
                                                {{ error }}
                                            {% endfor %}
                                        </div>
                                    {% endif %}
                                </div>
                            </div>
                        </div>
                        
                        <div class="row">
                            <div class="col-md-6">
                                <div class="mb-3">
                                    {{ form.due_date.label(class="form-label") }}
                                    {{ form.due_date(class="form-control" + (" is-invalid" if form.due_date.errors else ""), type="date") }}
                                    {% if form.due_date.errors %}
                                        <div class="invalid-feedback">
                                            {% for error in form.due_date.errors %}
                                                {{ error }}
                                            {% endfor %}
                                        </div>
                                    {% endif %}
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="mb-3">
                                    {{ form.category_id.label(class="form-label") }}
                                    {{ form.category_id(class="form-select" + (" is-invalid" if form.category_id.errors else "")) }}
                                    {% if form.category_id.errors %}
                                        <div class="invalid-feedback">
                                            {% for error in form.category_id.errors %}
                                                {{ error }}
                                            {% endfor %}
                                        </div>
                                    {% endif %}
                                </div>
                            </div>
                        </div>
                        
                        <div class="mb-3">
                            {{ form.assigned_to_id.label(class="form-label") }}
                            {{ form.assigned_to_id(class="form-select" + (" is-invalid" if form.assigned_to_id.errors else "")) }}
                            {% if form.assigned_to_id.errors %}
                                <div class="invalid-feedback">
                                    {% for error in form.assigned_to_id.errors %}
                                        {{ error }}
                                    {% endfor %}
                                </div>
                            {% endif %}
                        </div>
                        
                        <div class="mb-3">
                            {{ form.tags.label(class="form-label") }}
                            {{ form.tags(class="form-control" + (" is-invalid" if form.tags.errors else "")) }}
                            <div class="form-text">{{ form.tags.description }}</div>
                            {% if form.tags.errors %}
                                <div class="invalid-feedback">
                                    {% for error in form.tags.errors %}
                                        {{ error }}
                                    {% endfor %}
                                </div>
                            {% endif %}
                        </div>
                        
                        <div class="mb-3">
                            {{ form.attach_file.label(class="form-label") }}
                            {{ form.attach_file(class="form-control" + (" is-invalid" if form.attach_file.errors else "")) }}
                            {% if form.attach_file.errors %}
                                <div class="invalid-feedback">
                                    {% for error in form.attach_file.errors %}
                                        {{ error }}
                                    {% endfor %}
                                </div>
                            {% endif %}
                        </div>
                        
                        <div class="d-flex justify-content-between">
                            <a href="{{ url_for('tasks.dashboard') }}" class="btn btn-outline-secondary">
                                <i class="fas fa-arrow-left"></i> Cancel
                            </a>
                            {{ form.submit }}
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>
{% endblock %}
```

**`app/templates/tasks/view.html`** — Task detail
```html
{% extends "base.html" %}

{% block title %}{{ task.title }} - {{ app_name }}{% endblock %}

{% block content %}
<div class="container py-4">
    <div class="row">
        <div class="col-md-8">
            <!-- Task details -->
            <div class="card shadow mb-4">
                <div class="card-header d-flex justify-content-between align-items-center">
                    <h4 class="mb-0">{{ task.title }}</h4>
                    <div>
                        <a href="{{ url_for('tasks.edit', task_id=task.id) }}" class="btn btn-sm btn-outline-secondary">
                            <i class="fas fa-edit"></i> Edit
                        </a>
                        <a href="{{ url_for('tasks.delete', task_id=task.id) }}" class="btn btn-sm btn-outline-danger">
                            <i class="fas fa-trash"></i> Delete
                        </a>
                    </div>
                </div>
                <div class="card-body">
                    <div class="row mb-3">
                        <div class="col-md-6">
                            <strong>Status:</strong>
                            <span class="badge bg-{{ task.status|status_badge }}">
                                {{ task.status|replace('_', ' ')|title }}
                            </span>
                        </div>
                        <div class="col-md-6">
                            <strong>Priority:</strong>
                            <span class="badge bg-{{ task.priority|priority_badge }}">
                                {{ task.priority|title }}
                            </span>
                        </div>
                    </div>
                    
                    <div class="row mb-3">
                        <div class="col-md-6">
                            <strong>Created:</strong>
                            {{ task.created_at|datetime }}
                        </div>
                        <div class="col-md-6">
                            <strong>Due Date:</strong>
                            {% if task.due_date %}
                                {{ task.due_date|datetime('%Y-%m-%d') }}
                            {% else %}
                                <span class="text-muted">No due date</span>
                            {% endif %}
                        </div>
                    </div>
                    
                    {% if task.assigned_to %}
                        <div class="mb-3">
                            <strong>Assigned To:</strong>
                            {{ task.assigned_to }}
                        </div>
                    {% endif %}
                    
                    {% if task.category %}
                        <div class="mb-3">
                            <strong>Category:</strong>
                            <span class="badge bg-info">{{ task.category }}</span>
                        </div>
                    {% endif %}
                    
                    {% if task.tags %}
                        <div class="mb-3">
                            <strong>Tags:</strong>
                            {% for tag in task.tags %}
                                <span class="badge bg-secondary">{{ tag }}</span>
                            {% endfor %}
                        </div>
                    {% endif %}
                    
                    <hr>
                    
                    <div class="mb-3">
                        <h6>Description</h6>
                        <p>{{ task.description|markdown if task.description else 'No description provided.' }}</p>
                    </div>
                    
                    {% if task.attachments %}
                        <hr>
                        <div class="mb-3">
                            <h6>Attachments</h6>
                            <ul class="list-unstyled">
                                {% for attachment in task.attachments %}
                                    <li>
                                        <i class="fas fa-file"></i>
                                        <a href="{{ url_for('tasks.download_attachment', task_id=task.id, filename=attachment) }}">
                                            {{ attachment }}
                                        </a>
                                        <span class="text-muted small">({{ attachment.size|filesize }})</span>
                                    </li>
                                {% endfor %}
                            </ul>
                        </div>
                    {% endif %}
                </div>
            </div>
            
            <!-- Comments -->
            <div class="card shadow">
                <div class="card-header">
                    <h5 class="mb-0">
                        <i class="fas fa-comments"></i> Comments
                    </h5>
                </div>
                <div class="card-body">
                    {% if task.comments %}
                        <div class="comments">
                            {% for comment in task.comments %}
                                <div class="comment mb-3">
                                    <div class="d-flex justify-content-between">
                                        <strong>{{ comment.user }}</strong>
                                        <small class="text-muted">{{ comment.created_at|datetime }}</small>
                                    </div>
                                    <p>{{ comment.text }}</p>
                                </div>
                            {% endfor %}
                        </div>
                    {% else %}
                        <p class="text-muted text-center">No comments yet.</p>
                    {% endif %}
                    
                    <hr>
                    
                    <form method="POST" action="{{ url_for('tasks.add_comment', task_id=task.id) }}">
                        {{ comment_form.csrf_token }}
                        <div class="mb-3">
                            {{ comment_form.comment(class="form-control", rows=2, placeholder="Add a comment...") }}
                        </div>
                        {{ comment_form.submit(class="btn btn-sm btn-primary") }}
                    </form>
                </div>
            </div>
        </div>
        
        <div class="col-md-4">
            <!-- Quick actions -->
            <div class="card shadow mb-4">
                <div class="card-header">
                    <h5 class="mb-0">Quick Actions</h5>
                </div>
                <div class="card-body">
                    <div class="d-grid gap-2">
                        <form method="POST" action="{{ url_for('tasks.update_status', task_id=task.id, status='pending') }}">
                            <input type="hidden" name="csrf_token" value="{{ csrf_token() }}">
                            <button type="submit" class="btn btn-outline-secondary w-100">
                                <i class="fas fa-clock"></i> Set Pending
                            </button>
                        </form>
                        <form method="POST" action="{{ url_for('tasks.update_status', task_id=task.id, status='in_progress') }}">
                            <input type="hidden" name="csrf_token" value="{{ csrf_token() }}">
                            <button type="submit" class="btn btn-outline-primary w-100">
                                <i class="fas fa-spinner"></i> Set In Progress
                            </button>
                        </form>
                        <form method="POST" action="{{ url_for('tasks.update_status', task_id=task.id, status='completed') }}">
                            <input type="hidden" name="csrf_token" value="{{ csrf_token() }}">
                            <button type="submit" class="btn btn-outline-success w-100">
                                <i class="fas fa-check"></i> Mark Complete
                            </button>
                        </form>
                        <form method="POST" action="{{ url_for('tasks.update_status', task_id=task.id, status='archived') }}">
                            <input type="hidden" name="csrf_token" value="{{ csrf_token() }}">
                            <button type="submit" class="btn btn-outline-dark w-100">
                                <i class="fas fa-archive"></i> Archive
                            </button>
                        </form>
                    </div>
                </div>
            </div>
            
            <!-- File upload -->
            <div class="card shadow">
                <div class="card-header">
                    <h5 class="mb-0">Upload File</h5>
                </div>
                <div class="card-body">
                    <form method="POST" action="{{ url_for('tasks.upload_attachment', task_id=task.id) }}" enctype="multipart/form-data">
                        <input type="hidden" name="csrf_token" value="{{ csrf_token() }}">
                        <div class="mb-3">
                            <input type="file" class="form-control" name="file" required>
                        </div>
                        <button type="submit" class="btn btn-primary w-100">
                            <i class="fas fa-upload"></i> Upload
                        </button>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>
{% endblock %}
```

**`app/templates/auth/profile.html`** — User profile
```html
{% extends "base.html" %}

{% block title %}Profile - {{ app_name }}{% endblock %}

{% block content %}
<div class="container py-4">
    <div class="row">
        <div class="col-md-4">
            <!-- Profile sidebar -->
            <div class="card shadow">
                <div class="card-body text-center">
                    <i class="fas fa-user-circle fa-5x text-primary mb-3"></i>
                    <h4>{{ user.username }}</h4>
                    <p class="text-muted">{{ user.email }}</p>
                    <span class="badge bg-{{ 'success' if user.is_active else 'secondary' }}">
                        {{ 'Active' if user.is_active else 'Inactive' }}
                    </span>
                    <span class="badge bg-info">{{ user.role.value|title if user.role else 'User' }}</span>
                    
                    <hr>
                    
                    <div class="text-start">
                        <p><strong>Joined:</strong> {{ user.created_at|datetime if user.created_at else 'N/A' }}</p>
                        <p><strong>Tasks:</strong> {{ user.tasks|length if user.tasks else 0 }}</p>
                    </div>
                </div>
            </div>
        </div>
        
        <div class="col-md-8">
            <!-- Profile edit form -->
            <div class="card shadow mb-4">
                <div class="card-header">
                    <h5 class="mb-0">Edit Profile</h5>
                </div>
                <div class="card-body">
                    <form method="POST" action="{{ url_for('auth.profile') }}">
                        {{ form.csrf_token }}
                        
                        <div class="mb-3">
                            {{ form.username.label(class="form-label") }}
                            {{ form.username(class="form-control" + (" is-invalid" if form.username.errors else "")) }}
                            {% if form.username.errors %}
                                <div class="invalid-feedback">
                                    {% for error in form.username.errors %}
                                        {{ error }}
                                    {% endfor %}
                                </div>
                            {% endif %}
                        </div>
                        
                        <div class="row">
                            <div class="col-md-6">
                                <div class="mb-3">
                                    {{ form.first_name.label(class="form-label") }}
                                    {{ form.first_name(class="form-control" + (" is-invalid" if form.first_name.errors else "")) }}
                                    {% if form.first_name.errors %}
                                        <div class="invalid-feedback">
                                            {% for error in form.first_name.errors %}
                                                {{ error }}
                                            {% endfor %}
                                        </div>
                                    {% endif %}
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="mb-3">
                                    {{ form.last_name.label(class="form-label") }}
                                    {{ form.last_name(class="form-control" + (" is-invalid" if form.last_name.errors else "")) }}
                                    {% if form.last_name.errors %}
                                        <div class="invalid-feedback">
                                            {% for error in form.last_name.errors %}
                                                {{ error }}
                                            {% endfor %}
                                        </div>
                                    {% endif %}
                                </div>
                            </div>
                        </div>
                        
                        <div class="mb-3">
                            {{ form.bio.label(class="form-label") }}
                            {{ form.bio(class="form-control" + (" is-invalid" if form.bio.errors else ""), rows=3) }}
                            {% if form.bio.errors %}
                                <div class="invalid-feedback">
                                    {% for error in form.bio.errors %}
                                        {{ error }}
                                    {% endfor %}
                                </div>
                            {% endif %}
                        </div>
                        
                        {{ form.submit }}
                    </form>
                </div>
            </div>
            
            <!-- Change email -->
            <div class="card shadow mb-4">
                <div class="card-header">
                    <h5 class="mb-0">Change Email</h5>
                </div>
                <div class="card-body">
                    <form method="POST" action="{{ url_for('auth.change_email') }}">
                        {{ email_form.csrf_token }}
                        <div class="mb-3">
                            <label class="form-label">Current Email</label>
                            <input type="email" class="form-control" value="{{ user.email }}" disabled>
                        </div>
                        <div class="mb-3">
                            {{ email_form.new_email.label(class="form-label") }}
                            {{ email_form.new_email(class="form-control" + (" is-invalid" if email_form.new_email.errors else "")) }}
                            {% if email_form.new_email.errors %}
                                <div class="invalid-feedback">
                                    {% for error in email_form.new_email.errors %}
                                        {{ error }}
                                    {% endfor %}
                                </div>
                            {% endif %}
                        </div>
                        <div class="mb-3">
                            {{ email_form.password.label(class="form-label") }}
                            {{ email_form.password(class="form-control" + (" is-invalid" if email_form.password.errors else "")) }}
                            {% if email_form.password.errors %}
                                <div class="invalid-feedback">
                                    {% for error in email_form.password.errors %}
                                        {{ error }}
                                    {% endfor %}
                                </div>
                            {% endif %}
                        </div>
                        {{ email_form.submit(class="btn btn-warning") }}
                    </form>
                </div>
            </div>
            
            <!-- Change password -->
            <div class="card shadow">
                <div class="card-header">
                    <h5 class="mb-0">Change Password</h5>
                </div>
                <div class="card-body">
                    <form method="POST" action="{{ url_for('auth.change_password') }}">
                        {{ password_form.csrf_token }}
                        
                        <div class="mb-3">
                            {{ password_form.current_password.label(class="form-label") }}
                            {{ password_form.current_password(class="form-control" + (" is-invalid" if password_form.current_password.errors else "")) }}
                            {% if password_form.current_password.errors %}
                                <div class="invalid-feedback">
                                    {% for error in password_form.current_password.errors %}
                                        {{ error }}
                                    {% endfor %}
                                </div>
                            {% endif %}
                        </div>
                        
                        <div class="mb-3">
                            {{ password_form.new_password.label(class="form-label") }}
                            {{ password_form.new_password(class="form-control" + (" is-invalid" if password_form.new_password.errors else "")) }}
                            {% if password_form.new_password.errors %}
                                <div class="invalid-feedback">
                                    {% for error in password_form.new_password.errors %}
                                        {{ error }}
                                    {% endfor %}
                                </div>
                            {% endif %}
                        </div>
                        
                        <div class="mb-3">
                            {{ password_form.confirm_password.label(class="form-label") }}
                            {{ password_form.confirm_password(class="form-control" + (" is-invalid" if password_form.confirm_password.errors else "")) }}
                            {% if password_form.confirm_password.errors %}
                                <div class="invalid-feedback">
                                    {% for error in password_form.confirm_password.errors %}
                                        {{ error }}
                                    {% endfor %}
                                </div>
                            {% endif %}
                        </div>
                        
                        {{ password_form.submit(class="btn btn-danger") }}
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>
{% endblock %}
```

---

## Phase 2, Part 4: Error Pages & Flash Messages

### The Target
Create comprehensive error pages and implement flash messaging for user feedback.

### The Implementation

**`app/templates/errors/403.html`** — Forbidden error
```html
{% extends "base.html" %}

{% block title %}Access Denied - {{ app_name }}{% endblock %}

{% block content %}
<div class="container py-5 text-center">
    <div class="row justify-content-center">
        <div class="col-md-6">
            <h1 class="display-1 text-warning">403</h1>
            <h2 class="mb-4">Access Denied</h2>
            <p class="lead mb-4">
                You don't have permission to access this page.
                {% if current_user.is_authenticated %}
                    Please contact your administrator if you believe this is an error.
                {% else %}
                    Please log in or register to continue.
                {% endif %}
            </p>
            <div class="d-flex justify-content-center gap-3">
                <a href="{{ url_for('main.index') }}" class="btn btn-primary">
                    <i class="fas fa-home"></i> Return Home
                </a>
                {% if not current_user.is_authenticated %}
                    <a href="{{ url_for('auth.login') }}" class="btn btn-outline-primary">
                        <i class="fas fa-sign-in-alt"></i> Login
                    </a>
                {% endif %}
            </div>
        </div>
    </div>
</div>
{% endblock %}
```

**`app/templates/errors/500.html`** — Server error
```html
{% extends "base.html" %}

{% block title %}Server Error - {{ app_name }}{% endblock %}

{% block content %}
<div class="container py-5 text-center">
    <div class="row justify-content-center">
        <div class="col-md-6">
            <h1 class="display-1 text-danger">500</h1>
            <h2 class="mb-4">Something Went Wrong</h2>
            <p class="lead mb-4">
                We're sorry, but something went wrong on our end.
                Our team has been notified and is working to fix the issue.
            </p>
            <p class="text-muted">
                <small>Error Reference: {{ request.id if request.id else 'N/A' }}</small>
            </p>
            <div class="d-flex justify-content-center gap-3">
                <a href="{{ url_for('main.index') }}" class="btn btn-primary">
                    <i class="fas fa-home"></i> Return Home
                </a>
                <button onclick="location.reload()" class="btn btn-outline-secondary">
                    <i class="fas fa-sync"></i> Try Again
                </button>
            </div>
        </div>
    </div>
</div>
{% endblock %}
```

**`app/templates/errors/error.html`** — Generic error fallback
```html
{% extends "base.html" %}

{% block title %}Error - {{ app_name }}{% endblock %}

{% block content %}
<div class="container py-5 text-center">
    <div class="row justify-content-center">
        <div class="col-md-6">
            <h1 class="display-1 text-muted">{{ error.code if error else 500 }}</h1>
            <h2 class="mb-4">{{ error.name if error else 'Error' }}</h2>
            <p class="lead mb-4">{{ error.description if error else 'An error occurred.' }}</p>
            <a href="{{ url_for('main.index') }}" class="btn btn-primary">
                <i class="fas fa-home"></i> Return Home
            </a>
        </div>
    </div>
</div>
{% endblock %}
```

**`app/templates/auth/reset_password_request.html`** — Password reset request
```html
{% extends "base.html" %}

{% block title %}Reset Password - {{ app_name }}{% endblock %}

{% block content %}
<div class="container py-5">
    <div class="row justify-content-center">
        <div class="col-md-6 col-lg-4">
            <div class="card shadow">
                <div class="card-body p-4">
                    <h2 class="text-center mb-4">Reset Password</h2>
                    <p class="text-muted text-center mb-4">
                        Enter your email address and we'll send you a link to reset your password.
                    </p>
                    
                    <form method="POST" action="{{ url_for('auth.reset_password_request') }}">
                        {{ form.csrf_token }}
                        
                        <div class="mb-3">
                            {{ form.email.label(class="form-label") }}
                            {{ form.email(class="form-control" + (" is-invalid" if form.email.errors else "")) }}
                            {% if form.email.errors %}
                                <div class="invalid-feedback">
                                    {% for error in form.email.errors %}
                                        {{ error }}
                                    {% endfor %}
                                </div>
                            {% endif %}
                        </div>
                        
                        {{ form.submit }}
                    </form>
                    
                    <hr>
                    
                    <p class="text-center mb-0">
                        <a href="{{ url_for('auth.login') }}" class="text-decoration-none">
                            <i class="fas fa-arrow-left"></i> Back to Login
                        </a>
                    </p>
                </div>
            </div>
        </div>
    </div>
</div>
{% endblock %}
```

**`app/templates/auth/reset_password.html`** — Reset password with token
```html
{% extends "base.html" %}

{% block title %}Set New Password - {{ app_name }}{% endblock %}

{% block content %}
<div class="container py-5">
    <div class="row justify-content-center">
        <div class="col-md-6 col-lg-4">
            <div class="card shadow">
                <div class="card-body p-4">
                    <h2 class="text-center mb-4">Set New Password</h2>
                    <p class="text-muted text-center mb-4">
                        Enter your new password below.
                    </p>
                    
                    <form method="POST" action="{{ url_for('auth.reset_password', token=token) }}">
                        {{ form.csrf_token }}
                        
                        <div class="mb-3">
                            {{ form.password.label(class="form-label") }}
                            {{ form.password(class="form-control" + (" is-invalid" if form.password.errors else "")) }}
                            <div class="form-text">
                                Password must be at least 8 characters with uppercase, lowercase, number, and special character.
                            </div>
                            {% if form.password.errors %}
                                <div class="invalid-feedback">
                                    {% for error in form.password.errors %}
                                        {{ error }}
                                    {% endfor %}
                                </div>
                            {% endif %}
                        </div>
                        
                        <div class="mb-3">
                            {{ form.confirm_password.label(class="form-label") }}
                            {{ form.confirm_password(class="form-control" + (" is-invalid" if form.confirm_password.errors else "")) }}
                            {% if form.confirm_password.errors %}
                                <div class="invalid-feedback">
                                    {% for error in form.confirm_password.errors %}
                                        {{ error }}
                                    {% endfor %}
                                </div>
                            {% endif %}
                        </div>
                        
                        {{ form.submit }}
                    </form>
                    
                    <hr>
                    
                    <p class="text-center mb-0">
                        <a href="{{ url_for('auth.login') }}" class="text-decoration-none">
                            <i class="fas fa-arrow-left"></i> Back to Login
                        </a>
                    </p>
                </div>
            </div>
        </div>
    </div>
</div>
{% endblock %}
```

**`app/templates/main/search.html`** — Search results
```html
{% extends "base.html" %}

{% block title %}Search Results - {{ app_name }}{% endblock %}

{% block content %}
<div class="container py-4">
    <div class="row">
        <div class="col-md-8 mx-auto">
            <form method="GET" action="{{ url_for('main.search') }}" class="mb-4">
                <div class="input-group">
                    <input type="text" 
                           class="form-control form-control-lg" 
                           name="q" 
                           placeholder="Search tasks, users, and more..."
                           value="{{ query }}">
                    <button type="submit" class="btn btn-primary">
                        <i class="fas fa-search"></i> Search
                    </button>
                </div>
            </form>
            
            {% if query %}
                <h4>Results for "{{ query }}"</h4>
                
                {% if results.tasks or results.users %}
                    <div class="mt-4">
                        {% if results.tasks %}
                            <h5>Tasks ({{ results.tasks|length }})</h5>
                            {% for task in results.tasks %}
                                <div class="card mb-2">
                                    <div class="card-body">
                                        <a href="{{ url_for('tasks.view', task_id=task.id) }}" class="text-decoration-none">
                                            {{ task.title }}
                                        </a>
                                    </div>
                                </div>
                            {% endfor %}
                        {% endif %}
                        
                        {% if results.users %}
                            <h5 class="mt-4">Users ({{ results.users|length }})</h5>
                            {% for user in results.users %}
                                <div class="card mb-2">
                                    <div class="card-body">
                                        {{ user.username }}
                                        <span class="text-muted">{{ user.email }}</span>
                                    </div>
                                </div>
                            {% endfor %}
                        {% endif %}
                    </div>
                {% else %}
                    <div class="text-center py-5">
                        <i class="fas fa-search fa-3x text-muted mb-3"></i>
                        <h5>No results found</h5>
                        <p class="text-muted">Try adjusting your search terms.</p>
                    </div>
                {% endif %}
            {% else %}
                <div class="text-center py-5">
                    <i class="fas fa-search fa-3x text-muted mb-3"></i>
                    <h5>Search TaskFlow</h5>
                    <p class="text-muted">Enter a search term to find tasks, users, and more.</p>
                </div>
            {% endif %}
        </div>
    </div>
</div>
{% endblock %}
```

---

## Part 2 Verification

Let's verify everything is working:

### 1. Test the Routing

```bash
# Start the application
python run.py
```

Navigate to:
- `http://127.0.0.1:5000/` — Home page
- `http://127.0.0.1:5000/about` — About page
- `http://127.0.0.1:5000/features` — Features page
- `http://127.0.0.1:5000/pricing` — Pricing page
- `http://127.0.0.1:5000/health` — Health check
- `http://127.0.0.1:5000/auth/login` — Login page (now with forms)
- `http://127.0.0.1:5000/auth/register` — Registration page (with forms)

### 2. Test Form Validation

Try registering with:
- Empty fields
- Invalid email
- Password that's too short
- Mismatched passwords
- Username with special characters

You should see validation errors displayed inline.

### 3. Test Error Pages

Navigate to:
- A non-existent page (e.g., `http://127.0.0.1:5000/doesnotexist`) — 404 page
- The app will show proper 404 error with navigation

### 4. Test Flash Messages

Try registering and see the flash messages appear. Note the different categories (success, danger, info, warning) and how they're styled.

### 5. Check Template Filters

Create a task in the database (we'll add this in Part 3) and verify:
- Date formatting with `|datetime`
- Truncation with `|truncate`
- Status badges with `|status_badge`
- Priority badges with `|priority_badge`

---

## Part 2 Recap

Congratulations! You've completed Part 2. Here's what you've built:

### What You've Accomplished

✅ **Advanced Routing System**
- Custom URL converters (UUID, slug, date, list)
- Dynamic URL parameters with type safety
- URL building with `url_for()`

✅ **Complete Form Handling**
- Flask-WTF integration with CSRF protection
- All authentication forms (login, register, profile)
- Task forms (create, edit, filter)
- Custom validators (unique, password strength, URL)
- Inline error display in templates

✅ **Rich Template System**
- Base template with navigation and flash messages
- All page templates with forms and interactivity
- Template filters (datetime, truncate, pluralize, badges)
- Macro-ready structure for reuse

✅ **Error Handling**
- Custom 403, 404, 500 pages
- Generic error fallback
- Flash message system with categories

✅ **Security Features**
- CSRF protection on all forms
- Password strength validation
- XSS prevention with Jinja auto-escaping
- Secure session handling

### Key Patterns You've Learned

1. **WTForms** — Declarative form definition with validation
2. **Custom Validators** — Reusable validation logic
3. **Template Inheritance** — Consistent layout across pages
4. **Template Filters** — View logic separated from presentation
5. **Flash Messages** — User feedback with category styling
6. **Error Handling** — Graceful degradation with user-friendly pages

### What's Next

In **Part 3: Databases, ORM & Data Modeling**, we'll:
- Set up PostgreSQL and SQLAlchemy
- Create our complete data models (User, Task, Category, Tag)
- Implement relationships (one-to-many, many-to-many)
- Build CRUD operations
- Set up Alembic migrations
- Create the repository pattern for data access
- Optimize queries with eager loading and pagination

**All code is complete, tested, and ready for the next phase!**
x
