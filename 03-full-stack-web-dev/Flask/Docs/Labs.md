# Master Modern Flask 3.x: Lab Book

## Comprehensive Hands-On Laboratory Exercises

---

# HOW TO USE THIS LAB BOOK

This lab book provides structured, hands-on laboratory exercises to accompany the "Master Modern Flask 3.x" tutorial series. Each lab includes:

1. **Lab Objectives** - What you will learn
2. **Prerequisites** - What you need before starting
3. **Estimated Time** - How long the lab should take
4. **Step-by-Step Instructions** - Detailed procedures
5. **Code Examples** - Complete, working code
6. **Verification Steps** - How to check your work
7. **Troubleshooting** - Common issues and solutions
8. **Lab Report** - Space for your observations

**Lab Safety Rules:**
- Always work in a virtual environment
- Never commit secrets to version control
- Document your work as you go
- Clean up resources when done
- Ask for help when stuck

---

# LAB 1: FLASK FOUNDATIONS

## Setting Up Your Development Environment

### Lab Objectives
- Create a professional Flask development environment
- Set up a virtual environment
- Install Flask and development tools
- Create your first Flask application
- Configure code quality tools

### Prerequisites
- Python 3.13+ installed
- Basic command line knowledge
- A code editor (VS Code recommended)

### Estimated Time: 45 minutes

---

## Step 1: Create Project Structure

### Instructions:

```bash
# 1. Create project directory
mkdir flask_lab
cd flask_lab

# 2. Create virtual environment
python -m venv venv

# 3. Activate virtual environment
# On macOS/Linux:
source venv/bin/activate
# On Windows:
venv\Scripts\activate

# 4. Create project structure
mkdir -p app/{blueprints,models,forms,templates,static,utils}
mkdir tests
mkdir logs
mkdir instance
touch app/__init__.py
touch app/config.py
touch app/extensions.py
touch run.py
touch requirements.txt
touch .env
touch .gitignore
```

### Verification:
```bash
# Check directory structure
ls -la
# Should show: app/ tests/ logs/ instance/ run.py requirements.txt .env .gitignore
```

### Lab Report:
**Questions:**
1. Why do we use a virtual environment?
```
Your answer:
```

2. What is the purpose of each directory in the structure?
```
Your answer:
```

---

## Step 2: Create Requirements File

### Instructions:

Create `requirements.txt`:

```txt
# Core Framework
Flask==3.0.0
Flask-SQLAlchemy==3.0.5
Flask-Migrate==4.0.5
Flask-Login==0.6.2
Flask-WTF==1.1.1
Flask-Caching==2.1.0

# Database
psycopg2-binary==2.9.9
SQLAlchemy==2.0.23

# Development Tools
pytest==7.4.3
pytest-cov==4.1.0
ruff==0.1.6
black==23.11.0
isort==5.12.0
mypy==1.7.0
python-dotenv==1.0.0
pre-commit==3.5.0

# Production
gunicorn==21.2.0
```

Install dependencies:
```bash
pip install -r requirements.txt
```

### Verification:
```bash
pip list | grep Flask
# Should show Flask 3.0.0
```

---

## Step 3: Create Configuration

### Instructions:

Create `app/config.py`:

```python
import os
from datetime import timedelta

class Config:
    """Base configuration."""
    
    # Security
    SECRET_KEY = os.environ.get('SECRET_KEY', 'dev-secret-key-change-in-production')
    
    # Database
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    SQLALCHEMY_DATABASE_URI = os.environ.get(
        'DATABASE_URL',
        'sqlite:///instance/app.db'
    )
    
    # Session
    SESSION_COOKIE_SECURE = os.environ.get('SESSION_COOKIE_SECURE', 'False') == 'True'
    SESSION_COOKIE_HTTPONLY = True
    SESSION_COOKIE_SAMESITE = 'Lax'
    PERMANENT_SESSION_LIFETIME = timedelta(days=7)
    
    # File Uploads
    MAX_CONTENT_LENGTH = 16 * 1024 * 1024  # 16MB
    UPLOAD_FOLDER = 'app/static/uploads'
    ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg', 'gif', 'pdf'}
    
    # Pagination
    DEFAULT_PER_PAGE = 20
    
    # Logging
    LOG_LEVEL = os.environ.get('LOG_LEVEL', 'INFO')

class DevelopmentConfig(Config):
    """Development configuration."""
    DEBUG = True
    TESTING = False
    SESSION_COOKIE_SECURE = False
    SQLALCHEMY_ECHO = True

class TestingConfig(Config):
    """Testing configuration."""
    DEBUG = False
    TESTING = True
    SESSION_COOKIE_SECURE = False
    SQLALCHEMY_DATABASE_URI = 'sqlite:///:memory:'
    WTF_CSRF_ENABLED = False
    LOG_LEVEL = 'WARNING'

class ProductionConfig(Config):
    """Production configuration."""
    DEBUG = False
    TESTING = False
    SESSION_COOKIE_SECURE = True
    SQLALCHEMY_ECHO = False
    LOG_LEVEL = 'WARNING'
    
    @classmethod
    def init_app(cls, app):
        # Validate critical settings
        if not app.config.get('SECRET_KEY') or \
           app.config['SECRET_KEY'] == 'dev-secret-key-change-in-production':
            raise ValueError("SECRET_KEY must be set in production")
        if not app.config.get('SQLALCHEMY_DATABASE_URI'):
            raise ValueError("DATABASE_URL must be set in production")

# Configuration mapping
config = {
    'development': DevelopmentConfig,
    'testing': TestingConfig,
    'production': ProductionConfig,
    'default': DevelopmentConfig
}

def get_config():
    env = os.environ.get('FLASK_ENV', 'development')
    return config.get(env, DevelopmentConfig)
```

### Verification:
```python
# Test configuration
python -c "from app.config import get_config; print(get_config().__name__)"
# Should print: DevelopmentConfig
```

### Lab Report:
**Questions:**
1. What is the purpose of environment-specific configuration?
```
Your answer:
```

2. Why should `SECRET_KEY` not be hardcoded?
```
Your answer:
```

---

## Step 4: Create Application Factory

### Instructions:

Create `app/__init__.py`:

```python
from flask import Flask
from app.config import get_config
from app.extensions import init_extensions
import os

def create_app(config_name=None):
    """Application factory."""
    
    # Create Flask instance
    app = Flask(
        __name__,
        instance_path=os.path.abspath('instance'),
        instance_relative_config=True
    )
    
    # Load configuration
    if config_name is None:
        config_name = os.environ.get('FLASK_ENV', 'development')
    
    app.config.from_object(get_config())
    
    # Initialize extensions
    init_extensions(app)
    
    # Register blueprints
    register_blueprints(app)
    
    # Register error handlers
    register_error_handlers(app)
    
    # Register context processors
    register_context_processors(app)
    
    return app

def register_blueprints(app):
    """Register all blueprints."""
    # Will be implemented in future labs
    @app.route('/')
    def index():
        return '<h1>Flask Lab App</h1><p>Welcome to the Flask Lab!</p>'
    
    @app.route('/health')
    def health():
        return {
            'status': 'healthy',
            'environment': app.config.get('ENV', 'development')
        }

def register_error_handlers(app):
    """Register error handlers."""
    @app.errorhandler(404)
    def not_found(error):
        return {'error': 'Resource not found'}, 404
    
    @app.errorhandler(500)
    def internal_error(error):
        app.logger.error(f"Internal error: {error}")
        return {'error': 'Internal server error'}, 500

def register_context_processors(app):
    """Register context processors."""
    @app.context_processor
    def inject_globals():
        return {
            'app_name': 'Flask Lab',
            'environment': app.config.get('ENV', 'development')
        }
```

Create `app/extensions.py`:

```python
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate
from flask_login import LoginManager

db = SQLAlchemy()
migrate = Migrate()
login_manager = LoginManager()

def init_extensions(app):
    """Initialize all extensions."""
    db.init_app(app)
    migrate.init_app(app, db)
    login_manager.init_app(app)
    
    # Configure login manager
    login_manager.login_view = 'auth.login'
    login_manager.login_message = 'Please log in to access this page.'
    login_manager.login_message_category = 'warning'
    
    @login_manager.user_loader
    def load_user(user_id):
        from app.models.user import User
        return User.query.get(int(user_id))
```

### Verification:

Create `run.py`:

```python
from app import create_app

app = create_app()

if __name__ == '__main__':
    app.run(debug=True)
```

Run the application:
```bash
python run.py
```

Open browser to `http://localhost:5000` - Should see "Welcome to the Flask Lab!"

### Lab Report:
**Questions:**
1. What is the Application Factory pattern and why is it beneficial?
```
Your answer:
```

2. What does `instance_relative_config=True` do?
```
Your answer:
```

---

# LAB 2: ROUTING & TEMPLATES

## Building Dynamic Pages

### Lab Objectives
- Create dynamic routes with URL parameters
- Implement Jinja2 templates with inheritance
- Handle form data
- Implement flash messages
- Create custom error pages

### Prerequisites
- Completed Lab 1
- Basic HTML knowledge

### Estimated Time: 60 minutes

---

## Step 1: Create Blueprint Structure

### Instructions:

Create blueprint directories:

```bash
mkdir -p app/blueprints/main
mkdir -p app/blueprints/auth
touch app/blueprints/__init__.py
touch app/blueprints/main/__init__.py
touch app/blueprints/main/routes.py
touch app/blueprints/auth/__init__.py
touch app/blueprints/auth/routes.py
```

Create `app/blueprints/main/__init__.py`:

```python
from flask import Blueprint

main_bp = Blueprint('main', __name__)

from app.blueprints.main import routes
```

Create `app/blueprints/main/routes.py`:

```python
from flask import render_template, request, abort
from app.blueprints.main import main_bp

@main_bp.route('/')
def index():
    return render_template('main/index.html')

@main_bp.route('/about')
def about():
    return render_template('main/about.html')

@main_bp.route('/user/<username>')
def profile(username):
    users = {
        'john': {'name': 'John Doe', 'email': 'john@example.com'},
        'jane': {'name': 'Jane Smith', 'email': 'jane@example.com'}
    }
    user = users.get(username)
    if not user:
        abort(404)
    return render_template('main/profile.html', user=user, username=username)

@main_bp.route('/search')
def search():
    query = request.args.get('q', '')
    return render_template('main/search.html', query=query)
```

Create `app/blueprints/auth/__init__.py`:

```python
from flask import Blueprint

auth_bp = Blueprint('auth', __name__, url_prefix='/auth')

from app.blueprints.auth import routes
```

Create `app/blueprints/auth/routes.py`:

```python
from flask import render_template, request, redirect, url_for, flash
from app.blueprints.auth import auth_bp

@auth_bp.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        username = request.form.get('username')
        password = request.form.get('password')
        
        # Mock login (lab demo)
        if username == 'demo' and password == 'password':
            flash('Login successful!', 'success')
            return redirect(url_for('main.index'))
        else:
            flash('Invalid credentials', 'danger')
    
    return render_template('auth/login.html')

@auth_bp.route('/logout')
def logout():
    flash('You have been logged out.', 'info')
    return redirect(url_for('main.index'))
```

### Verification:
Update `app/__init__.py` to register blueprints:

```python
def register_blueprints(app):
    """Register all blueprints."""
    from app.blueprints.main import main_bp
    from app.blueprints.auth import auth_bp
    
    app.register_blueprint(main_bp)
    app.register_blueprint(auth_bp)
```

---

## Step 2: Create Templates

### Instructions:

Create template directory:

```bash
mkdir -p app/templates/main
mkdir -p app/templates/auth
```

Create `app/templates/base.html`:

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{% block title %}{{ app_name }}{% endblock %}</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        body { min-height: 100vh; display: flex; flex-direction: column; }
        main { flex: 1; }
        .footer { margin-top: auto; }
    </style>
    {% block extra_css %}{% endblock %}
</head>
<body>
    <!-- Navigation -->
    <nav class="navbar navbar-expand-lg navbar-dark bg-dark">
        <div class="container">
            <a class="navbar-brand" href="{{ url_for('main.index') }}">
                <i class="fas fa-flask"></i> Flask Lab
            </a>
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="navbarNav">
                <ul class="navbar-nav me-auto">
                    <li class="nav-item">
                        <a class="nav-link" href="{{ url_for('main.index') }}">Home</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="{{ url_for('main.about') }}">About</a>
                    </li>
                </ul>
                <ul class="navbar-nav">
                    <li class="nav-item">
                        <a class="nav-link" href="{{ url_for('auth.login') }}">
                            <i class="fas fa-sign-in-alt"></i> Login
                        </a>
                    </li>
                </ul>
            </div>
        </div>
    </nav>

    <!-- Flash Messages -->
    <div class="container mt-3">
        {% with messages = get_flashed_messages(with_categories=true) %}
            {% if messages %}
                {% for category, message in messages %}
                    <div class="alert alert-{{ category }} alert-dismissible fade show">
                        {{ message }}
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                {% endfor %}
            {% endif %}
        {% endwith %}
    </div>

    <!-- Main Content -->
    <main class="container mt-4">
        {% block content %}{% endblock %}
    </main>

    <!-- Footer -->
    <footer class="footer bg-light py-3 mt-4">
        <div class="container text-center">
            <span class="text-muted">
                &copy; {{ current_year }} Flask Lab - Environment: {{ environment }}
            </span>
        </div>
    </footer>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    {% block extra_js %}{% endblock %}
</body>
</html>
```

Create `app/templates/main/index.html`:

```html
{% extends "base.html" %}

{% block title %}Home - {{ app_name }}{% endblock %}

{% block content %}
<div class="jumbotron">
    <h1 class="display-4">Welcome to Flask Lab!</h1>
    <p class="lead">
        This is a hands-on laboratory for learning Flask development.
        You're running in <strong>{{ environment }}</strong> mode.
    </p>
    <hr class="my-4">
    <p>Explore the features of this application:</p>
    <div class="row">
        <div class="col-md-4">
            <div class="card">
                <div class="card-body">
                    <h5 class="card-title"><i class="fas fa-route"></i> Dynamic Routes</h5>
                    <p class="card-text">Try visiting <code>/user/username</code></p>
                    <a href="{{ url_for('main.profile', username='john') }}" class="btn btn-primary">
                        View Profile
                    </a>
                </div>
            </div>
        </div>
        <div class="col-md-4">
            <div class="card">
                <div class="card-body">
                    <h5 class="card-title"><i class="fas fa-search"></i> Search</h5>
                    <p class="card-text">Try searching for something</p>
                    <a href="{{ url_for('main.search') }}?q=flask" class="btn btn-primary">
                        Search Example
                    </a>
                </div>
            </div>
        </div>
        <div class="col-md-4">
            <div class="card">
                <div class="card-body">
                    <h5 class="card-title"><i class="fas fa-user"></i> Authentication</h5>
                    <p class="card-text">Try the login system (demo/password)</p>
                    <a href="{{ url_for('auth.login') }}" class="btn btn-primary">
                        Login
                    </a>
                </div>
            </div>
        </div>
    </div>
</div>
{% endblock %}
```

Create `app/templates/main/about.html`:

```html
{% extends "base.html" %}

{% block title %}About - {{ app_name }}{% endblock %}

{% block content %}
<h1>About Flask Lab</h1>
<div class="row">
    <div class="col-md-8">
        <p class="lead">
            This laboratory is designed to teach Flask development through 
            hands-on exercises.
        </p>
        <h3>Technologies Used</h3>
        <ul>
            <li>Flask 3.x - Web framework</li>
            <li>SQLAlchemy 2.x - ORM</li>
            <li>Jinja2 - Template engine</li>
            <li>Bootstrap 5 - Frontend framework</li>
        </ul>
        <h3>Lab Exercises</h3>
        <ol>
            <li>Flask Foundations</li>
            <li>Routing & Templates</li>
            <li>Databases & ORM</li>
            <li>Authentication & Security</li>
            <li>REST APIs</li>
            <li>Async & Background Tasks</li>
            <li>Testing</li>
            <li>Deployment</li>
        </ol>
    </div>
</div>
{% endblock %}
```

Create `app/templates/main/profile.html`:

```html
{% extends "base.html" %}

{% block title %}Profile - {{ app_name }}{% endblock %}

{% block content %}
<div class="row">
    <div class="col-md-6 offset-md-3">
        <div class="card">
            <div class="card-header">
                <h3>User Profile</h3>
            </div>
            <div class="card-body">
                <dl class="row">
                    <dt class="col-sm-3">Username</dt>
                    <dd class="col-sm-9">{{ username }}</dd>
                    
                    <dt class="col-sm-3">Name</dt>
                    <dd class="col-sm-9">{{ user.name }}</dd>
                    
                    <dt class="col-sm-3">Email</dt>
                    <dd class="col-sm-9">{{ user.email }}</dd>
                </dl>
                <a href="{{ url_for('main.index') }}" class="btn btn-secondary">
                    <i class="fas fa-arrow-left"></i> Back Home
                </a>
            </div>
        </div>
    </div>
</div>
{% endblock %}
```

Create `app/templates/main/search.html`:

```html
{% extends "base.html" %}

{% block title %}Search - {{ app_name }}{% endblock %}

{% block content %}
<div class="row">
    <div class="col-md-8 offset-md-2">
        <h1>Search</h1>
        <form method="GET" action="{{ url_for('main.search') }}">
            <div class="input-group mb-3">
                <input type="text" class="form-control" name="q" placeholder="Search..." value="{{ query }}">
                <button class="btn btn-primary" type="submit">
                    <i class="fas fa-search"></i> Search
                </button>
            </div>
        </form>
        
        {% if query %}
            <div class="alert alert-info">
                You searched for: <strong>"{{ query }}"</strong>
            </div>
            <p>Search results would appear here...</p>
        {% endif %}
    </div>
</div>
{% endblock %}
```

Create `app/templates/auth/login.html`:

```html
{% extends "base.html" %}

{% block title %}Login - {{ app_name }}{% endblock %}

{% block content %}
<div class="row justify-content-center">
    <div class="col-md-6">
        <div class="card">
            <div class="card-header">
                <h3>Login</h3>
            </div>
            <div class="card-body">
                <form method="POST" action="{{ url_for('auth.login') }}">
                    <div class="mb-3">
                        <label for="username" class="form-label">Username</label>
                        <input type="text" class="form-control" id="username" name="username" 
                               placeholder="Enter username (demo)" required>
                    </div>
                    <div class="mb-3">
                        <label for="password" class="form-label">Password</label>
                        <input type="password" class="form-control" id="password" name="password" 
                               placeholder="Enter password (password)" required>
                    </div>
                    <div class="mb-3 form-check">
                        <input type="checkbox" class="form-check-input" id="remember" name="remember">
                        <label class="form-check-label" for="remember">Remember me</label>
                    </div>
                    <button type="submit" class="btn btn-primary w-100">
                        <i class="fas fa-sign-in-alt"></i> Login
                    </button>
                </form>
                <hr>
                <p class="text-center text-muted">
                    <small>Demo credentials: demo / password</small>
                </p>
            </div>
        </div>
    </div>
</div>
{% endblock %}
```

---

## Step 3: Test the Application

### Instructions:

Start the application:
```bash
python run.py
```

### Verification Tests:

1. **Home Page**: `http://localhost:5000/`
   - Should show the home page with cards

2. **About Page**: `http://localhost:5000/about`
   - Should show the about page

3. **Profile Page**: `http://localhost:5000/user/john`
   - Should show John's profile
   - Try `http://localhost:5000/user/jane` for Jane's profile
   - Try `http://localhost:5000/user/unknown` for 404 error

4. **Search**: `http://localhost:5000/search?q=flask`
   - Should show search results

5. **Login**: `http://localhost:5000/auth/login`
   - Try demo/password
   - Should redirect to home with success message
   - Try wrong credentials for error message

### Troubleshooting:

| Issue | Solution |
|-------|----------|
| Template not found | Check template paths and folder names |
| Blueprint not registered | Check `app/__init__.py` registration |
| 404 error | Check route URLs and decorators |
| No flash messages | Check template has flash message block |

### Lab Report:
**Questions:**
1. How does template inheritance work in Jinja2?
```
Your answer:
```

2. What is the difference between `request.args` and `request.form`?
```
Your answer:
```

3. How do flash messages persist across requests?
```
Your answer:
```

---

# LAB 3: DATABASES & ORM

## Working with SQLAlchemy

### Lab Objectives
- Define database models
- Create relationships between models
- Perform CRUD operations
- Use Alembic for migrations
- Write complex queries

### Prerequisites
- Completed Labs 1-2
- Basic SQL knowledge

### Estimated Time: 75 minutes

---

## Step 1: Create Models

### Instructions:

Create model files:

```bash
touch app/models/__init__.py
touch app/models/user.py
touch app/models/task.py
```

Create `app/models/user.py`:

```python
from datetime import datetime
from flask_login import UserMixin
from werkzeug.security import generate_password_hash, check_password_hash
from app.extensions import db

class User(db.Model, UserMixin):
    __tablename__ = 'users'
    
    # Columns
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(50), unique=True, nullable=False, index=True)
    email = db.Column(db.String(120), unique=True, nullable=False, index=True)
    password_hash = db.Column(db.String(128), nullable=False)
    first_name = db.Column(db.String(50))
    last_name = db.Column(db.String(50))
    is_active = db.Column(db.Boolean, default=True)
    is_admin = db.Column(db.Boolean, default=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    last_login = db.Column(db.DateTime)
    
    # Relationships
    tasks = db.relationship('Task', back_populates='user', lazy='dynamic')
    
    def set_password(self, password):
        """Hash and set password."""
        self.password_hash = generate_password_hash(password)
    
    def check_password(self, password):
        """Check password against hash."""
        return check_password_hash(self.password_hash, password)
    
    @property
    def full_name(self):
        """Get full name."""
        if self.first_name and self.last_name:
            return f"{self.first_name} {self.last_name}"
        return self.username
    
    def to_dict(self):
        """Convert to dictionary."""
        return {
            'id': self.id,
            'username': self.username,
            'email': self.email,
            'full_name': self.full_name,
            'is_active': self.is_active,
            'is_admin': self.is_admin,
            'created_at': self.created_at.isoformat()
        }
    
    def __repr__(self):
        return f'<User {self.username}>'
```

Create `app/models/task.py`:

```python
from datetime import datetime
from app.extensions import db

class Task(db.Model):
    __tablename__ = 'tasks'
    
    # Columns
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(200), nullable=False)
    description = db.Column(db.Text)
    status = db.Column(db.String(20), default='pending', index=True)
    priority = db.Column(db.String(20), default='medium', index=True)
    due_date = db.Column(db.DateTime)
    completed_at = db.Column(db.DateTime)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Foreign Keys
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    
    # Relationships
    user = db.relationship('User', back_populates='tasks')
    
    @property
    def is_completed(self):
        return self.status == 'completed'
    
    @property
    def is_overdue(self):
        if not self.due_date or self.is_completed:
            return False
        return datetime.utcnow() > self.due_date
    
    def complete(self):
        """Mark task as completed."""
        self.status = 'completed'
        self.completed_at = datetime.utcnow()
    
    def archive(self):
        """Archive task."""
        self.status = 'archived'
    
    def to_dict(self):
        return {
            'id': self.id,
            'title': self.title,
            'description': self.description,
            'status': self.status,
            'priority': self.priority,
            'due_date': self.due_date.isoformat() if self.due_date else None,
            'created_at': self.created_at.isoformat(),
            'is_completed': self.is_completed,
            'is_overdue': self.is_overdue
        }
    
    def __repr__(self):
        return f'<Task {self.title}>'
```

Create `app/models/__init__.py`:

```python
from app.models.user import User
from app.models.task import Task

__all__ = ['User', 'Task']
```

---

## Step 2: Set Up Migrations

### Instructions:

Initialize migrations:

```bash
# Install Flask-Migrate
pip install Flask-Migrate

# Initialize migrations (first time only)
flask db init

# Create initial migration
flask db migrate -m "Initial migration with User and Task models"

# Apply migration
flask db upgrade
```

### Verification:

Check database tables:
```bash
# Open SQLite shell
sqlite3 instance/app.db

# Show tables
.tables
# Should show: users, tasks, alembic_version

# Show schema
.schema users
.schema tasks
```

---

## Step 3: Create Database Operations

### Instructions:

Create seed script:

```python
# app/cli/seed.py
import click
from flask.cli import with_appcontext
from app.extensions import db
from app.models.user import User
from app.models.task import Task
from datetime import datetime, timedelta
import random

@click.command('seed-db')
@with_appcontext
def seed_db():
    """Seed the database with test data."""
    click.echo('🌱 Seeding database...')
    
    # Create users
    admin = User(
        username='admin',
        email='admin@example.com',
        first_name='Admin',
        last_name='User',
        is_admin=True
    )
    admin.set_password('admin123')
    db.session.add(admin)
    
    user = User(
        username='john',
        email='john@example.com',
        first_name='John',
        last_name='Doe'
    )
    user.set_password('password123')
    db.session.add(user)
    
    user2 = User(
        username='jane',
        email='jane@example.com',
        first_name='Jane',
        last_name='Smith'
    )
    user2.set_password('password123')
    db.session.add(user2)
    
    db.session.commit()
    click.echo(f'✅ Created {User.query.count()} users')
    
    # Create tasks
    statuses = ['pending', 'in_progress', 'completed']
    priorities = ['low', 'medium', 'high', 'urgent']
    
    for user in User.query.all():
        for i in range(3):
            due_date = datetime.utcnow() + timedelta(days=random.randint(1, 30))
            task = Task(
                title=f'Task {i+1} for {user.username}',
                description=f'Description for task {i+1}',
                status=random.choice(statuses),
                priority=random.choice(priorities),
                due_date=due_date,
                user_id=user.id
            )
            if task.status == 'completed':
                task.completed_at = datetime.utcnow()
            db.session.add(task)
    
    db.session.commit()
    click.echo(f'✅ Created {Task.query.count()} tasks')
    click.echo('🎉 Seeding complete!')
```

Register CLI command in `app/__init__.py`:

```python
# In create_app function
@app.cli.command('seed')
def seed_command():
    """Seed the database with test data."""
    from app.cli.seed import seed_db
    seed_db()
```

### Verification:

```bash
# Run seed
flask seed

# Check data
flask shell
>>> from app.models.user import User
>>> User.query.count()
# Should show 3

>>> from app.models.task import Task
>>> Task.query.count()
# Should show 9 (3 tasks per user)
```

---

## Step 4: Create Service Layer

### Instructions:

Create service files:

```bash
mkdir -p app/services
touch app/services/__init__.py
touch app/services/user_service.py
touch app/services/task_service.py
```

Create `app/services/user_service.py`:

```python
from app.extensions import db
from app.models.user import User

class UserService:
    """Service for user operations."""
    
    @staticmethod
    def create_user(data):
        """Create a new user."""
        user = User(
            username=data['username'],
            email=data['email'],
            first_name=data.get('first_name'),
            last_name=data.get('last_name')
        )
        user.set_password(data['password'])
        db.session.add(user)
        db.session.commit()
        return user
    
    @staticmethod
    def get_by_id(user_id):
        return User.query.get(user_id)
    
    @staticmethod
    def get_by_email(email):
        return User.query.filter_by(email=email).first()
    
    @staticmethod
    def get_all():
        return User.query.all()
    
    @staticmethod
    def update_user(user, data):
        for key, value in data.items():
            if hasattr(user, key) and key not in ['id', 'password_hash']:
                setattr(user, key, value)
        db.session.commit()
        return user
    
    @staticmethod
    def delete_user(user):
        db.session.delete(user)
        db.session.commit()
```

Create `app/services/task_service.py`:

```python
from app.extensions import db
from app.models.task import Task
from datetime import datetime

class TaskService:
    """Service for task operations."""
    
    @staticmethod
    def create_task(user_id, data):
        """Create a new task."""
        task = Task(
            title=data['title'],
            description=data.get('description'),
            priority=data.get('priority', 'medium'),
            status=data.get('status', 'pending'),
            due_date=data.get('due_date'),
            user_id=user_id
        )
        db.session.add(task)
        db.session.commit()
        return task
    
    @staticmethod
    def get_by_id(task_id):
        return Task.query.get(task_id)
    
    @staticmethod
    def get_user_tasks(user_id, filters=None):
        query = Task.query.filter_by(user_id=user_id)
        if filters:
            if filters.get('status'):
                query = query.filter_by(status=filters['status'])
            if filters.get('priority'):
                query = query.filter_by(priority=filters['priority'])
        return query.order_by(Task.created_at.desc()).all()
    
    @staticmethod
    def update_task(task, data):
        for key, value in data.items():
            if hasattr(task, key) and key not in ['id', 'user_id']:
                setattr(task, key, value)
        if data.get('status') == 'completed' and not task.completed_at:
            task.completed_at = datetime.utcnow()
        db.session.commit()
        return task
    
    @staticmethod
    def delete_task(task):
        db.session.delete(task)
        db.session.commit()
```

Create `app/services/__init__.py`:

```python
from app.services.user_service import UserService
from app.services.task_service import TaskService

__all__ = ['UserService', 'TaskService']
```

---

## Step 5: Test Database Operations

### Instructions:

Create a test script:

```python
# test_db.py
from app import create_app
from app.extensions import db
from app.services import UserService, TaskService

app = create_app()

with app.app_context():
    # Test user creation
    user = UserService.create_user({
        'username': 'testuser',
        'email': 'test@example.com',
        'password': 'password123',
        'first_name': 'Test',
        'last_name': 'User'
    })
    print(f"Created user: {user.username}")
    
    # Test task creation
    task = TaskService.create_task(user.id, {
        'title': 'Test Task',
        'description': 'This is a test task',
        'priority': 'high'
    })
    print(f"Created task: {task.title}")
    
    # Test querying
    tasks = TaskService.get_user_tasks(user.id)
    print(f"User has {len(tasks)} tasks")
    
    # Test update
    TaskService.update_task(task, {'status': 'completed'})
    print(f"Task completed: {task.status}")
```

Run the test:
```bash
python test_db.py
```

### Lab Report:
**Questions:**
1. What is the difference between `db.Model` and `db.Column`?
```
Your answer:
```

2. Why do we use a service layer?
```
Your answer:
```

3. What is the purpose of database migrations?
```
Your answer:
```

---

# LAB 4: AUTHENTICATION & SECURITY

## Implementing User Authentication

### Lab Objectives
- Implement user registration
- Implement login with session management
- Add password reset functionality
- Implement role-based access control
- Add CSRF protection

### Prerequisites
- Completed Labs 1-3

### Estimated Time: 90 minutes

---

## Step 1: Create Authentication Forms

### Instructions:

Create `app/forms/auth.py`:

```python
from flask_wtf import FlaskForm
from wtforms import StringField, PasswordField, BooleanField, SubmitField
from wtforms.validators import DataRequired, Email, Length, EqualTo, ValidationError
from app.models.user import User

class RegistrationForm(FlaskForm):
    """Registration form."""
    username = StringField('Username', validators=[
        DataRequired(),
        Length(min=3, max=50)
    ])
    email = StringField('Email', validators=[
        DataRequired(),
        Email()
    ])
    password = PasswordField('Password', validators=[
        DataRequired(),
        Length(min=8)
    ])
    confirm_password = PasswordField('Confirm Password', validators=[
        DataRequired(),
        EqualTo('password')
    ])
    submit = SubmitField('Register')
    
    def validate_username(self, field):
        if User.query.filter_by(username=field.data).first():
            raise ValidationError('Username already taken')
    
    def validate_email(self, field):
        if User.query.filter_by(email=field.data).first():
            raise ValidationError('Email already registered')

class LoginForm(FlaskForm):
    """Login form."""
    email = StringField('Email', validators=[
        DataRequired(),
        Email()
    ])
    password = PasswordField('Password', validators=[
        DataRequired()
    ])
    remember = BooleanField('Remember Me')
    submit = SubmitField('Login')

class PasswordResetRequestForm(FlaskForm):
    """Password reset request form."""
    email = StringField('Email', validators=[
        DataRequired(),
        Email()
    ])
    submit = SubmitField('Request Password Reset')

class PasswordResetForm(FlaskForm):
    """Password reset form."""
    password = PasswordField('New Password', validators=[
        DataRequired(),
        Length(min=8)
    ])
    confirm_password = PasswordField('Confirm Password', validators=[
        DataRequired(),
        EqualTo('password')
    ])
    submit = SubmitField('Reset Password')
```

### Verification:
```bash
# Test form creation
flask shell
>>> from app.forms.auth import RegistrationForm
>>> form = RegistrationForm()
>>> form.username.label
# Should show field label
```

---

## Step 2: Update Authentication Routes

### Instructions:

Update `app/blueprints/auth/routes.py`:

```python
from flask import render_template, request, redirect, url_for, flash
from flask_login import login_user, logout_user, login_required, current_user
from app.blueprints.auth import auth_bp
from app.forms.auth import RegistrationForm, LoginForm, PasswordResetRequestForm, PasswordResetForm
from app.services import UserService
from app.extensions import db

@auth_bp.route('/register', methods=['GET', 'POST'])
def register():
    if current_user.is_authenticated:
        return redirect(url_for('main.index'))
    
    form = RegistrationForm()
    if form.validate_on_submit():
        user = UserService.create_user({
            'username': form.username.data,
            'email': form.email.data,
            'password': form.password.data
        })
        flash('Registration successful! Please log in.', 'success')
        return redirect(url_for('auth.login'))
    
    return render_template('auth/register.html', form=form)

@auth_bp.route('/login', methods=['GET', 'POST'])
def login():
    if current_user.is_authenticated:
        return redirect(url_for('main.index'))
    
    form = LoginForm()
    if form.validate_on_submit():
        user = UserService.get_by_email(form.email.data)
        if user and user.check_password(form.password.data):
            login_user(user, remember=form.remember.data)
            user.last_login = datetime.utcnow()
            db.session.commit()
            
            next_page = request.args.get('next')
            flash(f'Welcome back, {user.username}!', 'success')
            return redirect(next_page or url_for('main.index'))
        else:
            flash('Invalid email or password.', 'danger')
    
    return render_template('auth/login.html', form=form)

@auth_bp.route('/logout')
@login_required
def logout():
    logout_user()
    flash('You have been logged out.', 'info')
    return redirect(url_for('main.index'))

@auth_bp.route('/profile')
@login_required
def profile():
    return render_template('auth/profile.html')
```

---

## Step 3: Create Registration Template

### Instructions:

Create `app/templates/auth/register.html`:

```html
{% extends "base.html" %}

{% block title %}Register - {{ app_name }}{% endblock %}

{% block content %}
<div class="row justify-content-center">
    <div class="col-md-6">
        <div class="card">
            <div class="card-header">
                <h3>Create Account</h3>
            </div>
            <div class="card-body">
                <form method="POST" action="{{ url_for('auth.register') }}">
                    {{ form.csrf_token }}
                    
                    <div class="mb-3">
                        {{ form.username.label(class="form-label") }}
                        {{ form.username(class="form-control" + (" is-invalid" if form.username.errors else "")) }}
                        {% for error in form.username.errors %}
                            <div class="invalid-feedback">{{ error }}</div>
                        {% endfor %}
                    </div>
                    
                    <div class="mb-3">
                        {{ form.email.label(class="form-label") }}
                        {{ form.email(class="form-control" + (" is-invalid" if form.email.errors else "")) }}
                        {% for error in form.email.errors %}
                            <div class="invalid-feedback">{{ error }}</div>
                        {% endfor %}
                    </div>
                    
                    <div class="mb-3">
                        {{ form.password.label(class="form-label") }}
                        {{ form.password(class="form-control" + (" is-invalid" if form.password.errors else "")) }}
                        <div class="form-text">Must be at least 8 characters.</div>
                        {% for error in form.password.errors %}
                            <div class="invalid-feedback">{{ error }}</div>
                        {% endfor %}
                    </div>
                    
                    <div class="mb-3">
                        {{ form.confirm_password.label(class="form-label") }}
                        {{ form.confirm_password(class="form-control" + (" is-invalid" if form.confirm_password.errors else "")) }}
                        {% for error in form.confirm_password.errors %}
                            <div class="invalid-feedback">{{ error }}</div>
                        {% endfor %}
                    </div>
                    
                    {{ form.submit(class="btn btn-primary w-100") }}
                </form>
                <hr>
                <p class="text-center">
                    Already have an account? <a href="{{ url_for('auth.login') }}">Login here</a>
                </p>
            </div>
        </div>
    </div>
</div>
{% endblock %}
```

---

## Step 4: Update Login Template

### Instructions:

Update `app/templates/auth/login.html`:

```html
{% extends "base.html" %}

{% block title %}Login - {{ app_name }}{% endblock %}

{% block content %}
<div class="row justify-content-center">
    <div class="col-md-6">
        <div class="card">
            <div class="card-header">
                <h3>Login</h3>
            </div>
            <div class="card-body">
                <form method="POST" action="{{ url_for('auth.login') }}">
                    {{ form.csrf_token }}
                    
                    <div class="mb-3">
                        {{ form.email.label(class="form-label") }}
                        {{ form.email(class="form-control" + (" is-invalid" if form.email.errors else "")) }}
                        {% for error in form.email.errors %}
                            <div class="invalid-feedback">{{ error }}</div>
                        {% endfor %}
                    </div>
                    
                    <div class="mb-3">
                        {{ form.password.label(class="form-label") }}
                        {{ form.password(class="form-control" + (" is-invalid" if form.password.errors else "")) }}
                        {% for error in form.password.errors %}
                            <div class="invalid-feedback">{{ error }}</div>
                        {% endfor %}
                    </div>
                    
                    <div class="mb-3 form-check">
                        {{ form.remember(class="form-check-input") }}
                        {{ form.remember.label(class="form-check-label") }}
                    </div>
                    
                    {{ form.submit(class="btn btn-primary w-100") }}
                </form>
                <hr>
                <p class="text-center">
                    <a href="{{ url_for('auth.reset_password_request') }}">Forgot password?</a>
                </p>
                <p class="text-center">
                    Don't have an account? <a href="{{ url_for('auth.register') }}">Register here</a>
                </p>
            </div>
        </div>
    </div>
</div>
{% endblock %}
```

---

## Step 5: Add CSRF Protection

### Instructions:

Update `app/extensions.py`:

```python
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate
from flask_login import LoginManager
from flask_wtf.csrf import CSRFProtect

db = SQLAlchemy()
migrate = Migrate()
login_manager = LoginManager()
csrf = CSRFProtect()

def init_extensions(app):
    """Initialize all extensions."""
    db.init_app(app)
    migrate.init_app(app, db)
    login_manager.init_app(app)
    csrf.init_app(app)
    
    login_manager.login_view = 'auth.login'
    login_manager.login_message = 'Please log in to access this page.'
    login_manager.login_message_category = 'warning'
    
    @login_manager.user_loader
    def load_user(user_id):
        from app.models.user import User
        return User.query.get(int(user_id))
```

### Verification:
```bash
# Test CSRF protection
python run.py
# Try submitting login form without CSRF token
# Should get 400 Bad Request error
```

---

## Step 6: Role-Based Access Control

### Instructions:

Add role decorator:

Create `app/utils/decorators.py`:

```python
from functools import wraps
from flask import abort
from flask_login import current_user

def role_required(*roles):
    """Decorator for role-based access control."""
    def decorator(f):
        @wraps(f)
        def decorated(*args, **kwargs):
            if not current_user.is_authenticated:
                abort(401)
            if current_user.is_admin:
                return f(*args, **kwargs)
            if current_user.role not in roles:
                abort(403)
            return f(*args, **kwargs)
        return decorated
    return decorator

def admin_required(f):
    """Decorator for admin-only routes."""
    @wraps(f)
    def decorated(*args, **kwargs):
        if not current_user.is_authenticated:
            abort(401)
        if not current_user.is_admin:
            abort(403)
        return f(*args, **kwargs)
    return decorated

def permission_required(permission):
    """Decorator for permission-based access."""
    def decorator(f):
        @wraps(f)
        def decorated(*args, **kwargs):
            if not current_user.is_authenticated:
                abort(401)
            if not current_user.has_permission(permission):
                abort(403)
            return f(*args, **kwargs)
        return decorated
    return decorator
```

### Lab Report:
**Questions:**
1. How does password hashing work?
```
Your answer:
```

2. What is the purpose of CSRF protection?
```
Your answer:
```

3. How does role-based access control work?
```
Your answer:
```

---

# LAB 5: REST API

## Building a RESTful API

### Lab Objectives
- Create RESTful API endpoints
- Implement token-based authentication
- Use Marshmallow for serialization
- Add rate limiting
- Document API with Swagger

### Prerequisites
- Completed Labs 1-4

### Estimated Time: 90 minutes

---

## Step 1: Set Up API Blueprint

### Instructions:

Create API files:

```bash
mkdir -p app/blueprints/api/v1
touch app/blueprints/api/__init__.py
touch app/blueprints/api/v1/__init__.py
touch app/blueprints/api/v1/routes.py
```

Create `app/blueprints/api/__init__.py`:

```python
from flask import Blueprint

api_bp = Blueprint('api', __name__, url_prefix='/api')

# Import and register versioned blueprints
from app.blueprints.api.v1 import v1_bp
api_bp.register_blueprint(v1_bp, url_prefix='/v1')
```

Create `app/blueprints/api/v1/__init__.py`:

```python
from flask import Blueprint

v1_bp = Blueprint('api_v1', __name__)

from app.blueprints.api.v1 import routes
```

---

## Step 2: Create Marshmallow Schemas

### Instructions:

Install Marshmallow:
```bash
pip install marshmallow marshmallow-sqlalchemy
```

Create `app/schemas/__init__.py`:

```python
from app.schemas.task_schema import TaskSchema
from app.schemas.user_schema import UserSchema

__all__ = ['TaskSchema', 'UserSchema']
```

Create `app/schemas/task_schema.py`:

```python
from marshmallow import fields, validate
from marshmallow_sqlalchemy import SQLAlchemyAutoSchema
from app.models.task import Task

class TaskSchema(SQLAlchemyAutoSchema):
    class Meta:
        model = Task
        load_instance = True
        include_fk = True
    
    # Custom validation
    title = fields.Str(required=True, validate=validate.Length(min=1, max=200))
    description = fields.Str(allow_none=True)
    status = fields.Str(validate=validate.OneOf(['pending', 'in_progress', 'completed', 'archived']))
    priority = fields.Str(validate=validate.OneOf(['low', 'medium', 'high', 'urgent']))
    due_date = fields.DateTime(allow_none=True)
    
    # Read-only fields
    id = fields.Int(dump_only=True)
    created_at = fields.DateTime(dump_only=True)
    updated_at = fields.DateTime(dump_only=True)
    is_completed = fields.Bool(dump_only=True)
    is_overdue = fields.Bool(dump_only=True)
```

Create `app/schemas/user_schema.py`:

```python
from marshmallow import fields, validate
from marshmallow_sqlalchemy import SQLAlchemyAutoSchema
from app.models.user import User

class UserSchema(SQLAlchemyAutoSchema):
    class Meta:
        model = User
        load_instance = True
        exclude = ('password_hash',)
    
    username = fields.Str(required=True, validate=validate.Length(min=3, max=50))
    email = fields.Email(required=True)
    first_name = fields.Str(allow_none=True)
    last_name = fields.Str(allow_none=True)
    
    # Read-only fields
    id = fields.Int(dump_only=True)
    full_name = fields.Str(dump_only=True)
    is_active = fields.Bool(dump_only=True)
    is_admin = fields.Bool(dump_only=True)
    created_at = fields.DateTime(dump_only=True)
    last_login = fields.DateTime(dump_only=True)
```

---

## Step 3: Implement API Routes

### Instructions:

Create `app/blueprints/api/v1/routes.py`:

```python
from flask import request, jsonify, abort
from flask_login import login_required, current_user
from app.blueprints.api.v1 import v1_bp
from app.services import TaskService, UserService
from app.schemas import TaskSchema, UserSchema
from app.extensions import db
from marshmallow import ValidationError

@v1_bp.route('/tasks', methods=['GET'])
@login_required
def list_tasks():
    """List all tasks for the current user."""
    filters = {}
    if request.args.get('status'):
        filters['status'] = request.args['status']
    if request.args.get('priority'):
        filters['priority'] = request.args['priority']
    
    tasks = TaskService.get_user_tasks(current_user.id, filters)
    schema = TaskSchema(many=True)
    return jsonify(schema.dump(tasks))

@v1_bp.route('/tasks', methods=['POST'])
@login_required
def create_task():
    """Create a new task."""
    data = request.get_json()
    if not data:
        return jsonify({'error': 'No data provided'}), 400
    
    schema = TaskSchema()
    try:
        validated = schema.load(data)
    except ValidationError as err:
        return jsonify({'errors': err.messages}), 400
    
    task = TaskService.create_task(current_user.id, validated)
    return jsonify(schema.dump(task)), 201

@v1_bp.route('/tasks/<int:task_id>', methods=['GET'])
@login_required
def get_task(task_id):
    """Get a specific task."""
    task = TaskService.get_by_id(task_id)
    if not task or task.user_id != current_user.id:
        abort(404)
    schema = TaskSchema()
    return jsonify(schema.dump(task))

@v1_bp.route('/tasks/<int:task_id>', methods=['PUT'])
@login_required
def update_task(task_id):
    """Update a task."""
    task = TaskService.get_by_id(task_id)
    if not task or task.user_id != current_user.id:
        abort(404)
    
    data = request.get_json()
    if not data:
        return jsonify({'error': 'No data provided'}), 400
    
    schema = TaskSchema()
    try:
        validated = schema.load(data, partial=True)
    except ValidationError as err:
        return jsonify({'errors': err.messages}), 400
    
    TaskService.update_task(task, validated)
    return jsonify(schema.dump(task))

@v1_bp.route('/tasks/<int:task_id>', methods=['DELETE'])
@login_required
def delete_task(task_id):
    """Delete a task."""
    task = TaskService.get_by_id(task_id)
    if not task or task.user_id != current_user.id:
        abort(404)
    
    TaskService.delete_task(task)
    return '', 204

@v1_bp.route('/tasks/<int:task_id>/complete', methods=['POST'])
@login_required
def complete_task(task_id):
    """Mark a task as completed."""
    task = TaskService.get_by_id(task_id)
    if not task or task.user_id != current_user.id:
        abort(404)
    
    task.complete()
    db.session.commit()
    
    schema = TaskSchema()
    return jsonify(schema.dump(task))
```

---

## Step 4: Add Token Authentication

### Instructions:

Create `app/utils/auth.py`:

```python
import jwt
from datetime import datetime, timedelta
from functools import wraps
from flask import request, jsonify, g
from app.services import UserService

SECRET_KEY = 'your-secret-key-change-in-production'

def generate_token(user_id):
    """Generate JWT token."""
    payload = {
        'user_id': user_id,
        'exp': datetime.utcnow() + timedelta(hours=24),
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

def token_required(f):
    """Decorator for token authentication."""
    @wraps(f)
    def decorated(*args, **kwargs):
        auth_header = request.headers.get('Authorization')
        if not auth_header or not auth_header.startswith('Bearer '):
            return jsonify({'error': 'Token required'}), 401
        
        token = auth_header[7:]  # Remove 'Bearer '
        user_id = verify_token(token)
        if not user_id:
            return jsonify({'error': 'Invalid or expired token'}), 401
        
        user = UserService.get_by_id(user_id)
        if not user:
            return jsonify({'error': 'User not found'}), 401
        
        g.current_user = user
        return f(*args, **kwargs)
    return decorated
```

Add authentication endpoints:

```python
# In app/blueprints/api/v1/routes.py
from app.utils.auth import generate_token, token_required

@v1_bp.route('/auth/login', methods=['POST'])
def api_login():
    """API login endpoint."""
    data = request.get_json()
    if not data or not data.get('email') or not data.get('password'):
        return jsonify({'error': 'Email and password required'}), 400
    
    user = UserService.get_by_email(data['email'])
    if not user or not user.check_password(data['password']):
        return jsonify({'error': 'Invalid credentials'}), 401
    
    token = generate_token(user.id)
    return jsonify({
        'token': token,
        'user': UserSchema().dump(user)
    })

@v1_bp.route('/protected', methods=['GET'])
@token_required
def protected():
    """Protected endpoint example."""
    return jsonify({
        'message': 'You have access!',
        'user': UserSchema().dump(g.current_user)
    })
```

---

## Step 5: Add Rate Limiting

### Instructions:

Install Flask-Limiter:
```bash
pip install flask-limiter
```

Update `app/extensions.py`:

```python
from flask_limiter import Limiter
from flask_limiter.util import get_remote_address

limiter = Limiter(
    key_func=get_remote_address,
    default_limits=["200 per day", "50 per hour"]
)

def init_extensions(app):
    # ... existing initialization ...
    limiter.init_app(app)
```

Add rate limiting to API routes:

```python
# In app/blueprints/api/v1/routes.py
from app.extensions import limiter

@v1_bp.route('/tasks', methods=['GET'])
@login_required
@limiter.limit("100 per minute")
def list_tasks():
    # ...

@v1_bp.route('/tasks', methods=['POST'])
@login_required
@limiter.limit("30 per minute")
def create_task():
    # ...

@v1_bp.route('/auth/login', methods=['POST'])
@limiter.limit("5 per minute", error_message="Too many login attempts")
def api_login():
    # ...
```

---

## Step 6: Test the API

### Instructions:

Create test script:

```python
# test_api.py
import requests
import json

BASE_URL = 'http://localhost:5000/api/v1'

# 1. Login
login_response = requests.post(f'{BASE_URL}/auth/login', json={
    'email': 'john@example.com',
    'password': 'password123'
})
print('Login:', login_response.json())

# Get token
token = login_response.json()['token']
headers = {'Authorization': f'Bearer {token}'}

# 2. List tasks
tasks_response = requests.get(f'{BASE_URL}/tasks', headers=headers)
print('Tasks:', tasks_response.json())

# 3. Create task
create_response = requests.post(f'{BASE_URL}/tasks', 
    headers=headers,
    json={'title': 'API Test Task', 'priority': 'high'}
)
print('Create:', create_response.json())

# 4. Get specific task
if create_response.status_code == 201:
    task_id = create_response.json()['id']
    get_response = requests.get(f'{BASE_URL}/tasks/{task_id}', headers=headers)
    print('Get:', get_response.json())

# 5. Complete task
if 'task_id' in locals():
    complete_response = requests.post(f'{BASE_URL}/tasks/{task_id}/complete', headers=headers)
    print('Complete:', complete_response.json())
```

### Verification:
```bash
# Run API test
python test_api.py
```

### Lab Report:
**Questions:**
1. What is the difference between REST API and web application routes?
```
Your answer:
```

2. Why use Marshmallow for serialization?
```
Your answer:
```

3. How does token authentication work?
```
Your answer:
```

---

# LAB 6: BACKGROUND TASKS

## Async Programming & Celery

### Lab Objectives
- Set up Celery with Redis
- Create background tasks
- Schedule periodic tasks
- Monitor task execution

### Prerequisites
- Completed Labs 1-5
- Redis installed

### Estimated Time: 60 minutes

---

## Step 1: Install Redis

### Instructions:

**macOS:**
```bash
brew install redis
brew services start redis
```

**Ubuntu/Debian:**
```bash
sudo apt update
sudo apt install redis-server
sudo systemctl start redis
```

**Windows (WSL):**
```bash
sudo apt update
sudo apt install redis-server
```

**Verify Redis:**
```bash
redis-cli ping
# Should respond: PONG
```

---

## Step 2: Set Up Celery

### Instructions:

Install Celery and Redis:
```bash
pip install celery redis
```

Create `app/celery_worker.py`:

```python
from celery import Celery
import os

def make_celery(app_name=__name__):
    celery = Celery(
        app_name,
        broker=os.environ.get('CELERY_BROKER_URL', 'redis://localhost:6379/0'),
        backend=os.environ.get('CELERY_RESULT_BACKEND', 'redis://localhost:6379/1')
    )
    celery.conf.update(
        task_serializer='json',
        accept_content=['json'],
        result_serializer='json',
        timezone='UTC',
        enable_utc=True,
        task_track_started=True,
        task_time_limit=30 * 60,
        task_soft_time_limit=25 * 60,
        worker_prefetch_multiplier=1
    )
    celery.autodiscover_tasks(['app.tasks'])
    return celery

celery = make_celery()
```

---

## Step 3: Create Tasks

### Instructions:

Create task directory:

```bash
mkdir -p app/tasks
touch app/tasks/__init__.py
touch app/tasks/email.py
touch app/tasks/reports.py
```

Create `app/tasks/email.py`:

```python
from app.celery_worker import celery
import time

@celery.task
def send_email(recipient, subject, body):
    """Simulate sending an email."""
    # Simulate network delay
    time.sleep(2)
    
    # Log the email
    print(f"📧 Sending email to {recipient}")
    print(f"Subject: {subject}")
    print(f"Body: {body}")
    
    return {
        'status': 'sent',
        'recipient': recipient,
        'sent_at': time.time()
    }

@celery.task(bind=True, max_retries=3)
def send_notification(self, user_id, message):
    """Send notification with retry logic."""
    from app.models.user import User
    from app.extensions import db
    
    try:
        user = User.query.get(user_id)
        if not user:
            return {'error': 'User not found'}
        
        # Simulate notification
        print(f"🔔 Notification for {user.username}: {message}")
        return {'status': 'sent', 'user': user.username}
        
    except Exception as e:
        # Retry with exponential backoff
        self.retry(exc=e, countdown=60 * (2 ** self.request.retries))
```

Create `app/tasks/reports.py`:

```python
from app.celery_worker import celery
from app.services import TaskService
from datetime import datetime
import json

@celery.task
def generate_user_report(user_id):
    """Generate a report for a user."""
    from app.models.user import User
    
    user = User.query.get(user_id)
    if not user:
        return {'error': 'User not found'}
    
    tasks = TaskService.get_user_tasks(user_id)
    
    report = {
        'user': {
            'id': user.id,
            'username': user.username,
            'email': user.email
        },
        'generated_at': datetime.utcnow().isoformat(),
        'stats': {
            'total_tasks': len(tasks),
            'completed': sum(1 for t in tasks if t.is_completed),
            'pending': sum(1 for t in tasks if t.status == 'pending'),
            'overdue': sum(1 for t in tasks if t.is_overdue)
        }
    }
    
    return report

@celery.task(bind=True)
def process_batch(self, items):
    """Process a batch of items with progress tracking."""
    total = len(items)
    results = []
    
    for i, item in enumerate(items):
        # Update progress
        self.update_state(
            state='PROGRESS',
            meta={
                'current': i + 1,
                'total': total,
                'percent': (i + 1) / total * 100
            }
        )
        
        # Process item
        processed = process_item(item)
        results.append(processed)
    
    return {
        'processed': total,
        'results': results,
        'status': 'complete'
    }

def process_item(item):
    """Simulate processing an item."""
    time.sleep(0.5)
    return {'id': item, 'processed': True}
```

Create `app/tasks/__init__.py`:

```python
from app.tasks.email import send_email, send_notification
from app.tasks.reports import generate_user_report, process_batch

__all__ = ['send_email', 'send_notification', 'generate_user_report', 'process_batch']
```

---

## Step 4: Schedule Periodic Tasks

### Instructions:

Update `app/celery_worker.py`:

```python
from celery.schedules import crontab

celery.conf.beat_schedule = {
    'cleanup-orphaned-tasks': {
        'task': 'app.tasks.cleanup.cleanup_orphaned',
        'schedule': crontab(hour=2, minute=0)
    },
    'generate-daily-reports': {
        'task': 'app.tasks.reports.generate_daily_reports',
        'schedule': crontab(hour=8, minute=0)
    },
    'send-weekly-digest': {
        'task': 'app.tasks.email.send_weekly_digest',
        'schedule': crontab(day_of_week=1, hour=9, minute=0)
    }
}
```

Add cleanup task:

```python
# app/tasks/cleanup.py
from app.celery_worker import celery
from app.extensions import db
from app.models.task import Task
from datetime import datetime, timedelta

@celery.task
def cleanup_orphaned():
    """Clean up orphaned tasks."""
    cutoff = datetime.utcnow() - timedelta(days=30)
    tasks = Task.query.filter(
        Task.status == 'archived',
        Task.updated_at < cutoff
    ).all()
    
    count = len(tasks)
    for task in tasks:
        db.session.delete(task)
    db.session.commit()
    
    return {'deleted': count}
```

---

## Step 5: Use Tasks in Routes

### Instructions:

Update `app/blueprints/api/v1/routes.py`:

```python
from app.tasks import generate_user_report, send_notification

@v1_bp.route('/tasks/<int:task_id>/export', methods=['POST'])
@login_required
def export_task_report(task_id):
    """Export a task report (async)."""
    task = TaskService.get_by_id(task_id)
    if not task or task.user_id != current_user.id:
        abort(404)
    
    # Start background task
    result = generate_user_report.delay(current_user.id)
    
    return jsonify({
        'task_id': result.id,
        'status': 'started',
        'status_url': url_for('api_v1.get_task_status', task_id=result.id, _external=True)
    })

@v1_bp.route('/task-status/<task_id>', methods=['GET'])
@login_required
def get_task_status(task_id):
    """Get status of a background task."""
    from celery.result import AsyncResult
    from app.celery_worker import celery
    
    result = AsyncResult(task_id, app=celery)
    
    if result.ready():
        if result.successful():
            return jsonify({
                'status': 'completed',
                'result': result.result
            })
        else:
            return jsonify({
                'status': 'failed',
                'error': str(result.result)
            })
    else:
        return jsonify({
            'status': 'pending',
            'progress': result.info.get('percent', 0) if result.info else None
        })

@v1_bp.route('/batch-process', methods=['POST'])
@login_required
def batch_process():
    """Process a batch of items."""
    data = request.get_json()
    if not data or 'items' not in data:
        return jsonify({'error': 'Items required'}), 400
    
    from app.tasks import process_batch
    result = process_batch.delay(data['items'])
    
    return jsonify({
        'task_id': result.id,
        'status': 'started'
    })
```

---

## Step 6: Run Celery

### Instructions:

Start Celery:

```bash
# Terminal 1: Start Celery worker
celery -A app.celery_worker.celery worker --loglevel=info

# Terminal 2: Start Celery Beat (for scheduled tasks)
celery -A app.celery_worker.celery beat --loglevel=info

# OR combine (for development)
celery -A app.celery_worker.celery worker --beat --loglevel=info
```

Test tasks:

```bash
# In Python shell
flask shell
>>> from app.tasks import send_email
>>> result = send_email.delay('test@example.com', 'Test', 'Hello')
>>> result.id
# Check worker output
```

### Verification:

1. Start Celery worker
2. Send a task
3. Check Celery logs
4. Check task status

### Lab Report:
**Questions:**
1. What is the purpose of a message broker?
```
Your answer:
```

2. Why use Celery instead of async/await?
```
Your answer:
```

3. How do you monitor Celery tasks?
```
Your answer:
```

---

# LAB 7: TESTING

## Writing Comprehensive Tests

### Lab Objectives
- Write unit tests with Pytest
- Create integration tests
- Write functional tests
- Measure test coverage
- Use test fixtures

### Prerequisites
- Completed Labs 1-6

### Estimated Time: 60 minutes

---

## Step 1: Set Up Testing

### Instructions:

Install testing dependencies:
```bash
pip install pytest pytest-cov factory-boy faker
```

Create `pytest.ini`:

```ini
[pytest]
minversion = 7.0
addopts = -ra -q --strict-markers --tb=short
testpaths = tests
python_files = test_*.py
python_classes = Test*
python_functions = test_*

markers =
    unit: Unit tests
    integration: Integration tests
    functional: Functional tests
    slow: Slow tests

filterwarnings =
    ignore::DeprecationWarning
```

Create test directory:
```bash
mkdir -p tests/unit tests/integration tests/functional tests/fixtures
touch tests/__init__.py
touch tests/conftest.py
touch tests/fixtures/__init__.py
```

---

## Step 2: Create Test Fixtures

### Instructions:

Create `tests/conftest.py`:

```python
import pytest
from app import create_app
from app.extensions import db
from app.models.user import User
from app.models.task import Task

@pytest.fixture
def app():
    """Create application for testing."""
    app = create_app('testing')
    with app.app_context():
        db.create_all()
        yield app
        db.drop_all()

@pytest.fixture
def client(app):
    """Create test client."""
    return app.test_client()

@pytest.fixture
def db_session(app):
    """Create database session."""
    with app.app_context():
        yield db.session

@pytest.fixture
def test_user(db_session):
    """Create test user."""
    user = User(
        username='testuser',
        email='test@example.com',
        first_name='Test',
        last_name='User'
    )
    user.set_password('password123')
    db_session.add(user)
    db_session.commit()
    return user

@pytest.fixture
def test_task(db_session, test_user):
    """Create test task."""
    task = Task(
        title='Test Task',
        description='Test description',
        priority='high',
        user_id=test_user.id
    )
    db_session.add(task)
    db_session.commit()
    return task

@pytest.fixture
def auth_client(client, test_user):
    """Create authenticated client."""
    client.post('/auth/login', data={
        'email': 'test@example.com',
        'password': 'password123'
    })
    return client

@pytest.fixture
def admin_user(db_session):
    """Create admin user."""
    user = User(
        username='admin',
        email='admin@example.com',
        first_name='Admin',
        last_name='User',
        is_admin=True
    )
    user.set_password('admin123')
    db_session.add(user)
    db_session.commit()
    return user
```

---

## Step 3: Write Unit Tests

### Instructions:

Create `tests/unit/test_models.py`:

```python
import pytest
from app.models.user import User
from app.models.task import Task
from datetime import datetime, timedelta

class TestUserModel:
    def test_create_user(self, db_session):
        user = User(
            username='john',
            email='john@example.com'
        )
        user.set_password('password123')
        db_session.add(user)
        db_session.commit()
        
        assert user.id is not None
        assert user.username == 'john'
        assert user.check_password('password123') is True
        assert user.check_password('wrong') is False
    
    def test_unique_username(self, db_session, test_user):
        user = User(
            username='testuser',
            email='another@example.com'
        )
        db_session.add(user)
        with pytest.raises(Exception):
            db_session.commit()
    
    def test_full_name(self, db_session, test_user):
        assert test_user.full_name == 'Test User'
        
        test_user.first_name = 'John'
        test_user.last_name = ''
        assert test_user.full_name == 'John'
        
        test_user.first_name = ''
        test_user.last_name = ''
        assert test_user.full_name == 'testuser'

class TestTaskModel:
    def test_create_task(self, db_session, test_user):
        task = Task(
            title='Test Task',
            description='Description',
            priority='high',
            user_id=test_user.id
        )
        db_session.add(task)
        db_session.commit()
        
        assert task.id is not None
        assert task.title == 'Test Task'
        assert task.user_id == test_user.id
    
    def test_complete_task(self, db_session, test_task):
        assert test_task.is_completed is False
        
        test_task.complete()
        db_session.commit()
        
        assert test_task.is_completed is True
        assert test_task.completed_at is not None
    
    def test_is_overdue(self, db_session, test_user):
        # Future date - not overdue
        task = Task(
            title='Future Task',
            due_date=datetime.utcnow() + timedelta(days=7),
            user_id=test_user.id
        )
        assert task.is_overdue is False
        
        # Past date - overdue
        task = Task(
            title='Past Task',
            due_date=datetime.utcnow() - timedelta(days=1),
            user_id=test_user.id
        )
        assert task.is_overdue is True
```

Create `tests/unit/test_services.py`:

```python
import pytest
from app.services import UserService, TaskService

class TestUserService:
    def test_create_user(self, db_session):
        user = UserService.create_user({
            'username': 'newuser',
            'email': 'new@example.com',
            'password': 'password123',
            'first_name': 'New',
            'last_name': 'User'
        })
        
        assert user.id is not None
        assert user.username == 'newuser'
        assert user.check_password('password123') is True
    
    def test_get_by_email(self, db_session, test_user):
        user = UserService.get_by_email('test@example.com')
        assert user is not None
        assert user.id == test_user.id
    
    def test_duplicate_username(self, db_session, test_user):
        with pytest.raises(Exception):
            UserService.create_user({
                'username': 'testuser',
                'email': 'different@example.com',
                'password': 'password123'
            })

class TestTaskService:
    def test_create_task(self, db_session, test_user):
        task = TaskService.create_task(test_user.id, {
            'title': 'Service Test Task',
            'description': 'Created by service',
            'priority': 'high'
        })
        
        assert task.id is not None
        assert task.title == 'Service Test Task'
        assert task.user_id == test_user.id
    
    def test_get_user_tasks(self, db_session, test_user, test_task):
        tasks = TaskService.get_user_tasks(test_user.id)
        assert len(tasks) >= 1
        assert tasks[0].id == test_task.id
    
    def test_update_task(self, db_session, test_user, test_task):
        updated = TaskService.update_task(test_task, {
            'title': 'Updated Title',
            'status': 'completed'
        })
        
        assert updated.title == 'Updated Title'
        assert updated.status == 'completed'
```

---

## Step 4: Write Integration Tests

### Instructions:

Create `tests/integration/test_routes.py`:

```python
class TestAuthRoutes:
    def test_login_page(self, client):
        response = client.get('/auth/login')
        assert response.status_code == 200
        assert b'Login' in response.data
    
    def test_login_success(self, client, test_user):
        response = client.post('/auth/login', data={
            'email': 'test@example.com',
            'password': 'password123'
        }, follow_redirects=True)
        assert response.status_code == 200
        assert b'Welcome' in response.data
    
    def test_login_failure(self, client):
        response = client.post('/auth/login', data={
            'email': 'wrong@example.com',
            'password': 'wrongpassword'
        })
        assert response.status_code == 200
        assert b'Invalid' in response.data
    
    def test_register_page(self, client):
        response = client.get('/auth/register')
        assert response.status_code == 200
        assert b'Register' in response.data
    
    def test_register_success(self, client, db_session):
        response = client.post('/auth/register', data={
            'username': 'newuser',
            'email': 'new@example.com',
            'password': 'Password123!',
            'confirm_password': 'Password123!'
        }, follow_redirects=True)
        assert response.status_code == 200
        assert b'Registration successful' in response.data

class TestTaskRoutes:
    def test_list_tasks_authenticated(self, auth_client):
        response = auth_client.get('/api/v1/tasks')
        assert response.status_code == 200
        assert response.json is not None
    
    def test_create_task(self, auth_client):
        response = auth_client.post('/api/v1/tasks', json={
            'title': 'Integration Test Task',
            'priority': 'high'
        })
        assert response.status_code == 201
        assert response.json['title'] == 'Integration Test Task'
    
    def test_get_task(self, auth_client, test_task):
        response = auth_client.get(f'/api/v1/tasks/{test_task.id}')
        assert response.status_code == 200
        assert response.json['id'] == test_task.id
```

---

## Step 5: Run Tests

### Instructions:

Run tests:
```bash
# Run all tests
pytest

# Run with coverage
pytest --cov=app --cov-report=html

# Run specific test file
pytest tests/unit/test_models.py

# Run specific test
pytest tests/unit/test_models.py::TestUserModel::test_create_user

# Run by marker
pytest -m unit
pytest -m "not slow"

# Run with verbose output
pytest -v
```

### Verification:
```bash
# Should show test results
# ====================== 10 passed, 0 failed ======================
```

### Lab Report:
**Questions:**
1. What is the difference between unit and integration tests?
```
Your answer:
```

2. Why use fixtures in testing?
```
Your answer:
```

3. What is test coverage and why does it matter?
```
Your answer:
```

---

# LAB 8: DEPLOYMENT

## Production Deployment

### Lab Objectives
- Configure Gunicorn
- Set up Nginx
- Create Docker container
- Configure deployment scripts
- Set up monitoring

### Prerequisites
- Completed Labs 1-7
- Docker installed

### Estimated Time: 90 minutes

---

## Step 1: Configure Gunicorn

### Instructions:

Create `gunicorn.conf.py`:

```python
import os
import multiprocessing

# Server socket
bind = os.environ.get('GUNICORN_BIND', '0.0.0.0:8000')
backlog = 2048

# Worker processes
workers = int(os.environ.get('GUNICORN_WORKERS', multiprocessing.cpu_count() * 2 + 1))
worker_class = 'sync'
threads = int(os.environ.get('GUNICORN_THREADS', 2))

# Worker timeouts
timeout = 120
graceful_timeout = 30
keepalive = 5

# Max requests before restart
max_requests = 1000
max_requests_jitter = 100

# Process management
preload_app = True
worker_tmp_dir = '/dev/shm'

# Logging
accesslog = '-'
errorlog = '-'
loglevel = 'info'

# Access log format
access_log_format = '%(h)s %(l)s %(u)s %(t)s "%(r)s" %(s)s %(b)s "%(f)s" "%(a)s"'
```

### Verification:
```bash
# Test Gunicorn
pip install gunicorn
gunicorn -c gunicorn.conf.py run:app
```

---

## Step 2: Create Dockerfile

### Instructions:

Create `Dockerfile`:

```dockerfile
FROM python:3.13-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application
COPY . .

# Create non-root user
RUN adduser --disabled-password --no-create-home appuser
USER appuser

# Health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

EXPOSE 8000

CMD ["gunicorn", "-c", "gunicorn.conf.py", "run:app"]
```

---

## Step 3: Create Docker Compose

### Instructions:

Create `docker-compose.yml`:

```yaml
version: '3.8'

services:
  web:
    build: .
    ports:
      - "8000:8000"
    environment:
      - FLASK_ENV=production
      - SECRET_KEY=${SECRET_KEY}
      - DATABASE_URL=postgresql://${DB_USER}:${DB_PASSWORD}@db:5432/${DB_NAME}
      - CELERY_BROKER_URL=redis://redis:6379/0
    depends_on:
      - db
      - redis
    volumes:
      - ./logs:/app/logs
      - ./uploads:/app/static/uploads
  
  worker:
    build: .
    command: celery -A app.celery_worker.celery worker --loglevel=info
    environment:
      - DATABASE_URL=postgresql://${DB_USER}:${DB_PASSWORD}@db:5432/${DB_NAME}
      - CELERY_BROKER_URL=redis://redis:6379/0
    depends_on:
      - db
      - redis
  
  beat:
    build: .
    command: celery -A app.celery_worker.celery beat --loglevel=info
    environment:
      - DATABASE_URL=postgresql://${DB_USER}:${DB_PASSWORD}@db:5432/${DB_NAME}
      - CELERY_BROKER_URL=redis://redis:6379/0
    depends_on:
      - db
      - redis
  
  db:
    image: postgres:15
    environment:
      - POSTGRES_USER=${DB_USER}
      - POSTGRES_PASSWORD=${DB_PASSWORD}
      - POSTGRES_DB=${DB_NAME}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"
  
  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data

volumes:
  postgres_data:
  redis_data:
```

---

## Step 4: Create Environment File

### Instructions:

Create `.env.production`:

```bash
# Flask
FLASK_ENV=production
SECRET_KEY=your-very-secure-secret-key-change-this

# Database
DB_USER=taskflow
DB_PASSWORD=secure-password
DB_NAME=taskflow

# Redis
REDIS_PASSWORD=
```

---

## Step 5: Create Deployment Script

### Instructions:

Create `scripts/deploy.sh`:

```bash
#!/bin/bash
set -e

echo "🚀 Starting deployment..."

# Load environment
source .env.production

# Pull latest code
echo "📦 Pulling latest code..."
git pull origin main

# Build containers
echo "🏗️ Building containers..."
docker-compose build

# Run migrations
echo "🗄️ Running migrations..."
docker-compose run --rm web flask db upgrade

# Start services
echo "🚀 Starting services..."
docker-compose up -d

# Health check
echo "✅ Running health check..."
sleep 10
curl -f http://localhost:8000/health || exit 1

echo "🎉 Deployment complete!"
```

Make executable:
```bash
chmod +x scripts/deploy.sh
```

---

## Step 6: Create Monitoring

### Instructions:

Add health check to `app/__init__.py`:

```python
# In create_app function
@app.route('/health')
def health():
    """Health check endpoint."""
    # Check database
    db_healthy = True
    try:
        from app.extensions import db
        db.session.execute('SELECT 1')
    except Exception:
        db_healthy = False
    
    # Check Redis
    redis_healthy = True
    try:
        import redis
        r = redis.Redis.from_url(app.config.get('CELERY_BROKER_URL', 'redis://localhost:6379/0'))
        r.ping()
    except Exception:
        redis_healthy = False
    
    status = 'healthy' if (db_healthy and redis_healthy) else 'unhealthy'
    
    return {
        'status': status,
        'timestamp': datetime.utcnow().isoformat(),
        'database': 'connected' if db_healthy else 'disconnected',
        'redis': 'connected' if redis_healthy else 'disconnected',
        'environment': app.config.get('ENV', 'unknown')
    }, 200 if status == 'healthy' else 503
```

---

## Step 7: Test Deployment

### Instructions:

Build and deploy:

```bash
# Build
docker-compose build

# Start
docker-compose up -d

# Check logs
docker-compose logs -f web

# Check health
curl http://localhost:8000/health

# Stop
docker-compose down
```

### Verification:
```bash
# Check containers
docker-compose ps

# Check logs
docker-compose logs web --tail=50

# Test API
curl http://localhost:8000/api/v1/tasks
```

### Lab Report:
**Questions:**
1. What is the role of Gunicorn in production?
```
Your answer:
```

2. Why use Docker for deployment?
```
Your answer:
```

3. What is the purpose of health checks?
```
Your answer:
```

---

# FINAL PROJECT

## Complete TaskFlow Application

### Project Requirements

**Objective:** Build a complete task management application called TaskFlow.

**Requirements:**

1. **User Management**
   - User registration with email verification
   - User login with session management
   - Password reset functionality
   - User profile management

2. **Task Management**
   - Create, read, update, delete tasks
   - Task categories and tags
   - Task search and filtering
   - Task assignment to users
   - Task status tracking

3. **API**
   - RESTful API endpoints
   - Token-based authentication
   - API documentation with Swagger
   - Rate limiting

4. **Background Processing**
   - Email notifications
   - Report generation
   - Scheduled tasks (daily, weekly)

5. **Testing**
   - Unit tests (>80% coverage)
   - Integration tests
   - Functional tests

6. **Deployment**
   - Docker containerization
   - Production configuration
   - Monitoring and logging

---

## Lab Report Template

**Student Name:** _________________

**Date:** _________________

**Lab Number:** _________________

**Lab Title:** _________________

**Objectives:**
```
```

**Observations:**
```
```

**Results:**
```
```

**Challenges Encountered:**
```
```

**Solutions Applied:**
```
```

**What I Learned:**
```
```

**Lab Verification:**
- [ ] All steps completed
- [ ] Code works as expected
- [ ] Tests pass
- [ ] Documentation updated

---

# APPENDIX: COMMAND REFERENCE

## Flask Commands
```bash
flask run                  # Run development server
flask shell                # Open Flask shell
flask routes               # Show all routes
flask db init              # Initialize migrations
flask db migrate -m "msg"  # Create migration
flask db upgrade           # Apply migrations
flask db downgrade         # Rollback migration
flask db current           # Show current version
flask seed                 # Seed database (custom)
```

## Python Virtual Environment
```bash
python -m venv venv                     # Create venv
source venv/bin/activate                # Activate (Unix)
venv\Scripts\activate                   # Activate (Windows)
deactivate                              # Deactivate
pip install -r requirements.txt         # Install dependencies
pip freeze > requirements.txt           # Export dependencies
```

## Testing
```bash
pytest                                  # Run all tests
pytest -v                               # Verbose output
pytest -x                               # Stop on first failure
pytest --cov=app                        # Coverage report
pytest --cov=app --cov-report=html      # HTML coverage report
pytest -m unit                          # Run unit tests only
pytest tests/test_models.py             # Run specific file
```

## Docker
```bash
docker build -t app:latest .            # Build image
docker run -p 8000:8000 app:latest      # Run container
docker-compose up -d                    # Start services
docker-compose logs -f                  # View logs
docker-compose down                     # Stop services
docker-compose build                    # Rebuild
docker system prune -f                  # Clean up
```

## Celery
```bash
celery -A app.celery_worker.celery worker --loglevel=info
celery -A app.celery_worker.celery beat --loglevel=info
celery -A app.celery_worker.celery worker --beat --loglevel=info
celery -A app.celery_worker.celery flower --port=5555
```

## Gunicorn
```bash
gunicorn -c gunicorn.conf.py run:app
gunicorn --workers=4 --bind=0.0.0.0:8000 run:app
gunicorn --bind=unix:/tmp/app.sock run:app
```

## Git
```bash
git init                                # Initialize repo
git add .                               # Stage changes
git commit -m "message"                 # Commit changes
git push origin main                    # Push to remote
git pull origin main                    # Pull from remote
git branch                              # Show branches
git checkout -b feature                 # Create branch
git merge feature                       # Merge branch
```

---

**End of Lab Book**
