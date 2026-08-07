# Master Modern Flask 3.x: Student Notes

## Comprehensive Note-Taking Guide & Lecture Notes

---

# HOW TO USE THESE NOTES

These notes are designed to accompany the "Master Modern Flask 3.x" tutorial series. Each section includes:

1. **Key Concepts** - The most important ideas to remember
2. **Code Snippets** - Essential code examples
3. **Definitions** - Technical terms explained simply
4. **Diagrams** - Visual representations of concepts
5. **Summary Points** - Quick review of each topic
6. **My Notes** - Space for your personal notes

**Study Tips:**
- Review these notes before watching the tutorial
- Add your own notes and examples
- Create flashcards from the key concepts
- Practice writing code without looking at the notes

---

# PART 1: FLASK FOUNDATIONS & PROJECT ARCHITECTURE

---

## 1.1 Introduction to Flask

### What is Flask?
Flask is a **microframework** for building web applications in Python. It's designed to be simple, flexible, and extensible.

### Key Characteristics
| Feature | Description |
|---------|-------------|
| **Microframework** | Provides only essential features |
| **Extensible** | Add features through extensions |
| **Flexible** | No imposed project structure |
| **Lightweight** | Minimal overhead |
| **Python-based** | Uses Python 3.x |

### When to Use Flask
- ✅ Small to medium applications
- ✅ REST APIs
- ✅ Prototypes
- ✅ Learning web development
- ❌ Large applications with strict structure (use Django)

### Flask vs Django vs FastAPI

```
┌────────────────────────────────────────────────────────────────────┐
│                         Framework Comparison                       │
├──────────────┬─────────────────┬─────────────────┬─────────────────┤
│   Aspect     │     Flask       │     Django      │    FastAPI      │
├──────────────┼─────────────────┼─────────────────┼─────────────────┤
│ Philosophy   │   Minimalist    │  Batteries-incl │    Modern       │
├──────────────┼─────────────────┼─────────────────┼─────────────────┤
│ Learning     │    Gentle       │     Steep       │   Moderate      │
├──────────────┼─────────────────┼─────────────────┼─────────────────┤
│ Database     │     Any         │    Built-in     │     Any         │
├──────────────┼─────────────────┼─────────────────┼─────────────────┤
│ Admin        │   Optional      │    Built-in     │   Optional      │
├──────────────┼─────────────────┼─────────────────┼─────────────────┤
│ Async        │   Native (3.x)  │   Limited       │   Native        │
└──────────────┴─────────────────┴─────────────────┴─────────────────┘
```

---

## 1.2 Flask Core Components

### Werkzeug
The **WSGI toolkit** that handles:
- HTTP request/response objects
- URL routing
- Development server
- Debugging tools

```
Werkzeug = Flask's engine
```

### Jinja2
The **templating engine** that provides:
- Dynamic HTML rendering
- Template inheritance
- Auto-escaping for security
- Custom filters and macros

### Click
The **command-line interface** that provides:
- Flask CLI commands
- Custom command creation
- Development utilities

### Flask's Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                         Flask Application                          │
├─────────────────────────────────────────────────────────────────────┤
│   ┌─────────────────────────────────────────────────────────────┐  │
│   │                    Application Factory                      │  │
│   └─────────────────────────────────────────────────────────────┘  │
│   ┌───────────────┐  ┌───────────────┐  ┌───────────────┐       │
│   │   Blueprints  │  │   Extensions  │  │   Config      │       │
│   └───────────────┘  └───────────────┘  └───────────────┘       │
│   ┌─────────────────────────────────────────────────────────────┐  │
│   │                       Routes & Views                        │  │
│   └─────────────────────────────────────────────────────────────┘  │
│   ┌─────────────────────────────────────────────────────────────┐  │
│   │                      Templates & Static                     │  │
│   └─────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────┘
```

**My Notes:**
```
```

---

## 1.3 Development Environment

### Virtual Environment
**Purpose:** Isolates project dependencies

```bash
# Create virtual environment
python -m venv venv

# Activate (macOS/Linux)
source venv/bin/activate

# Activate (Windows)
venv\Scripts\activate

# Deactivate
deactivate
```

### Why Virtual Environments?
```
Without venv:
- Python packages installed globally
- Version conflicts between projects
- Can't test different package versions
- Permission issues

With venv:
- Isolated package installations
- No version conflicts
- Can easily recreate environment
- Clean project dependencies
```

### Installing Flask
```bash
# Install Flask
pip install flask

# Install with specific version
pip install flask==3.0.0

# Create requirements file
pip freeze > requirements.txt

# Install from requirements file
pip install -r requirements.txt
```

### Development vs Production

| Aspect | Development | Production |
|--------|-------------|------------|
| **Server** | Flask built-in | Gunicorn/uWSGI |
| **Debug** | ON | OFF |
| **Reload** | ON | OFF |
| **Security** | Minimal | Maximum |
| **Database** | SQLite | PostgreSQL |
| **HTTPS** | No | Yes |
| **Logging** | Console | File/Cloud |

**My Notes:**
```
```

---

## 1.4 Application Factory Pattern

### What is Application Factory?
A design pattern that creates Flask application instances in a function rather than globally.

### Why Use It?
```
┌─────────────────────────────────────────────────────────────────────┐
│                    Benefits of Application Factory                  │
├─────────────────────────────────────────────────────────────────────┤
│  ✅ Multiple configurations (dev, test, prod)                      │
│  ✅ Easy testing (create app per test)                             │
│  ✅ No global state                                                 │
│  ✅ Extension initialization control                                │
│  ✅ Clean separation of concerns                                    │
│  ✅ Blueprint registration in one place                            │
└─────────────────────────────────────────────────────────────────────┘
```

### Basic Implementation
```python
# app/__init__.py
from flask import Flask
from app.config import Config

def create_app(config_class=Config):
    """Application factory."""
    app = Flask(__name__)
    
    # Configuration
    app.config.from_object(config_class)
    
    # Extensions
    from app.extensions import db
    db.init_app(app)
    
    # Blueprints
    from app.blueprints.main import main_bp
    app.register_blueprint(main_bp)
    
    return app
```

### With Multiple Configurations
```python
# app/config.py
import os

class Config:
    SECRET_KEY = os.environ.get('SECRET_KEY', 'dev-key')
    SQLALCHEMY_TRACK_MODIFICATIONS = False

class DevelopmentConfig(Config):
    DEBUG = True
    SQLALCHEMY_DATABASE_URI = 'sqlite:///dev.db'

class TestingConfig(Config):
    TESTING = True
    SQLALCHEMY_DATABASE_URI = 'sqlite:///:memory:'

class ProductionConfig(Config):
    DEBUG = False
    SQLALCHEMY_DATABASE_URI = os.environ.get('DATABASE_URL')
```

### Using the Factory
```python
# run.py
from app import create_app
from app.config import ProductionConfig

app = create_app(ProductionConfig)

if __name__ == '__main__':
    app.run()
```

**My Notes:**
```
```

---

## 1.5 Configuration Management

### Configuration Sources
1. **Environment variables** (`os.environ`)
2. **Python files** (`config.py`)
3. **JSON files** (`config.json`)
4. **Object-based** (Config classes)

### Best Practices
```python
# ✅ GOOD: Load from environment
SECRET_KEY = os.environ.get('SECRET_KEY')

# ❌ BAD: Hardcode sensitive values
SECRET_KEY = 'hardcoded-secret'

# ✅ GOOD: Use defaults for dev
SECRET_KEY = os.environ.get('SECRET_KEY', 'dev-secret')

# ✅ GOOD: Validate in production
if os.environ.get('FLASK_ENV') == 'production':
    if not os.environ.get('SECRET_KEY'):
        raise ValueError("SECRET_KEY must be set in production")
```

### Configuration Hierarchy
```
Environment Variables (Highest Priority)
         ↓
Local Configuration File
         ↓
Environment-Specific Config
         ↓
Base Config (Lowest Priority)
```

### Security Best Practices
- Never commit secrets to version control
- Use `.env` files (add to `.gitignore`)
- Use different secrets for each environment
- Rotate secrets regularly
- Use a secrets manager in production

**My Notes:**
```
```

---

## 1.6 Blueprints

### What are Blueprints?
Blueprints are **modular components** that group related routes, templates, and static files.

### Why Use Blueprints?
```
┌─────────────────────────────────────────────────────────────────────┐
│                    Benefits of Blueprints                          │
├─────────────────────────────────────────────────────────────────────┤
│  ✅ Organize code by feature                                       │
│  ✅ Reusable components                                            │
│  ✅ Separate URL prefixes                                          │
│  ✅ Isolated templates and static files                            │
│  ✅ Easier testing                                                 │
│  ✅ Cleaner code                                                   │
└─────────────────────────────────────────────────────────────────────┘
```

### Blueprint Structure
```
blueprints/
├── __init__.py
├── main/
│   ├── __init__.py
│   └── routes.py
├── auth/
│   ├── __init__.py
│   └── routes.py
└── api/
    ├── __init__.py
    └── routes.py
```

### Creating a Blueprint
```python
# app/blueprints/main/__init__.py
from flask import Blueprint

main_bp = Blueprint('main', __name__)

from app.blueprints.main import routes
```

```python
# app/blueprints/main/routes.py
from flask import render_template
from app.blueprints.main import main_bp

@main_bp.route('/')
def index():
    return render_template('index.html')

@main_bp.route('/about')
def about():
    return render_template('about.html')
```

### Registering Blueprints
```python
# app/__init__.py
def create_app():
    app = Flask(__name__)
    
    from app.blueprints.main import main_bp
    from app.blueprints.auth import auth_bp
    from app.blueprints.api import api_bp
    
    app.register_blueprint(main_bp)                        # /
    app.register_blueprint(auth_bp, url_prefix='/auth')    # /auth/*
    app.register_blueprint(api_bp, url_prefix='/api')      # /api/*
    
    return app
```

### URL Building with Blueprints
```python
# Without blueprint prefix
url_for('index')         # → '/'
url_for('about')         # → '/about'

# With blueprint prefix
url_for('auth.login')    # → '/auth/login'
url_for('auth.logout')   # → '/auth/logout'

# With blueprint and endpoint
url_for('api.get_task', task_id=1)  # → '/api/task/1'
```

**My Notes:**
```
```

---

## 1.7 Code Quality Tools

### Essential Tools

| Tool | Purpose | Command |
|------|---------|---------|
| **Ruff** | Linting (fast) | `ruff check app/` |
| **Black** | Code formatting | `black app/` |
| **isort** | Import sorting | `isort app/` |
| **mypy** | Type checking | `mypy app/` |
| **pre-commit** | Git hooks | `pre-commit run` |

### pyproject.toml Configuration
```toml
[tool.black]
line-length = 100
target-version = ['py313']

[tool.isort]
profile = "black"
line_length = 100

[tool.ruff]
target-version = "py313"
line-length = 100
select = ["E", "F", "I", "N"]

[tool.mypy]
python_version = "3.13"
warn_return_any = true
warn_unused_configs = true
```

### Pre-commit Configuration
```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.5.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml

  - repo: https://github.com/psf/black
    rev: 24.2.0
    hooks:
      - id: black

  - repo: https://github.com/charliermarsh/ruff-pre-commit
    rev: v0.2.2
    hooks:
      - id: ruff
        args: ['--fix']
```

### Makefile for Common Tasks
```makefile
.PHONY: help format lint test

format:
    black app/ tests/
    isort app/ tests/

lint:
    ruff check app/ tests/

type-check:
    mypy app/

test:
    pytest tests/

all: format lint type-check test
```

**My Notes:**
```
```

---

# PART 2: ROUTING, REQUESTS & TEMPLATING

---

## 2.1 URL Routing

### Basic Routing
```python
@app.route('/')                     # Root URL
def home():
    return 'Home Page'

@app.route('/about')                # /about
def about():
    return 'About Page'

@app.route('/contact')              # /contact
def contact():
    return 'Contact Page'
```

### Dynamic Routes
```python
# String variable
@app.route('/user/<username>')
def profile(username):
    return f'User: {username}'

# Integer variable
@app.route('/post/<int:post_id>')
def post(post_id):
    return f'Post ID: {post_id}'

# Multiple variables
@app.route('/user/<username>/post/<int:post_id>')
def user_post(username, post_id):
    return f'{username}\'s post: {post_id}'

# Optional variable
@app.route('/page/<path:page>')
@app.route('/page')
def show_page(page='home'):
    return f'Page: {page}'
```

### URL Converters

| Converter | Type | Example |
|-----------|------|---------|
| `string` | Any text without slashes | `/user/john` |
| `int` | Integer numbers | `/post/123` |
| `float` | Floating point numbers | `/price/19.99` |
| `path` | Text with slashes | `/files/dir/file` |
| `uuid` | UUID format | `/user/123e4567-e89b-12d3-a456-426614174000` |

### Custom Converter
```python
from werkzeug.routing import BaseConverter

class UUIDConverter(BaseConverter):
    regex = r'[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}'
    
    def to_python(self, value):
        return str(value)
    
    def to_url(self, value):
        return str(value)

app.url_map.converters['uuid'] = UUIDConverter

@app.route('/user/<uuid:user_id>')
def user(user_id):
    return f'User ID: {user_id}'
```

**My Notes:**
```
```

---

## 2.2 HTTP Methods

### Method Types
```
GET     → Read data (safe, cacheable)
POST    → Create data (unsafe, not cacheable)
PUT     → Replace data (idempotent)
PATCH   → Update partial data (not idempotent)
DELETE  → Remove data (idempotent)
```

### Handling Methods
```python
# Single method
@app.route('/login', methods=['GET'])
def show_login():
    return render_template('login.html')

@app.route('/login', methods=['POST'])
def process_login():
    return redirect(url_for('dashboard'))

# Multiple methods
@app.route('/task', methods=['GET', 'POST'])
def task():
    if request.method == 'GET':
        return render_template('task.html')
    else:
        return redirect(url_for('list_tasks'))

# All methods
@app.route('/api/data', methods=['GET', 'POST', 'PUT', 'DELETE'])
def api_data():
    method = request.method
    if method == 'GET':
        return get_data()
    elif method == 'POST':
        return create_data()
    # ... etc
```

### Method Checking
```python
from flask import request

if request.method == 'GET':
    # Show form
    pass
elif request.method == 'POST':
    # Process form
    pass

# Check with is()
if request.is_json:
    data = request.get_json()
```

**My Notes:**
```
```

---

## 2.3 Request Object

### Accessing Request Data
```python
from flask import request

# URL Parameters (GET)
# /search?q=flask&page=2
query = request.args.get('q')
page = request.args.get('page', 1, type=int)  # with default and type

# Form Data (POST)
username = request.form.get('username')
password = request.form.get('password')

# JSON Data (API)
data = request.get_json()
title = data.get('title')

# Headers
user_agent = request.headers.get('User-Agent')
auth = request.headers.get('Authorization')

# Files
file = request.files.get('file')
filename = file.filename

# Cookies
session_cookie = request.cookies.get('session')

# Full URL
full_url = request.url
path = request.path
base_url = request.base_url
```

### Request Information
```python
# Request metadata
method = request.method
path = request.path
url = request.url
host = request.host
remote_addr = request.remote_addr

# Query string
query_string = request.query_string
args = request.args  # Full dict

# Form data
form = request.form  # Full dict
data = request.data  # Raw data

# File uploads
files = request.files  # All files

# Environment
environ = request.environ  # WSGI environ
```

### Request Validation
```python
# Check content type
if request.is_json:
    data = request.get_json()
else:
    data = request.form

# Check method
if request.method in ['POST', 'PUT', 'DELETE']:
    # Write operation
    pass

# Get with validation
user_id = request.args.get('user_id', type=int)
if user_id is None:
    abort(400, 'user_id required')
```

**My Notes:**
```
```

---

## 2.4 URL Building (url_for)

### Purpose of url_for
`url_for()` generates URLs dynamically, making your code more maintainable.

### Basic Usage
```python
from flask import url_for

# Simple routes
url_for('home')              # → '/'
url_for('about')             # → '/about'
url_for('contact')           # → '/contact'

# Dynamic routes
url_for('profile', username='john')     # → '/user/john'
url_for('post', post_id=123)            # → '/post/123'

# Multiple parameters
url_for('user_post', username='john', post_id=123)  # → '/user/john/post/123'

# Query parameters
url_for('search', q='flask', page=2)    # → '/search?q=flask&page=2'

# With blueprint
url_for('auth.login')      # → '/auth/login'
url_for('auth.logout')     # → '/auth/logout'

# External URL
url_for('home', _external=True)     # → 'http://localhost:5000/'
```

### Why Use url_for?
```
✅ Changes automatically when routes change
✅ Handles URL escaping
✅ Supports query parameters
✅ Works with blueprints
✅ Type-safe
✅ Avoids hardcoded strings
```

### Redirect with url_for
```python
from flask import redirect, url_for

@app.route('/login')
def login():
    # Redirect to dashboard
    return redirect(url_for('dashboard'))

@app.route('/dashboard')
def dashboard():
    return 'Dashboard'

# With parameters
@app.route('/user/<username>')
def profile(username):
    if username == 'admin':
        return redirect(url_for('admin_panel'))
    return f'Profile: {username}'
```

**My Notes:**
```
```

---

## 2.5 Jinja2 Templating

### Template Inheritance
```
┌─────────────────────────────────────────────────────────────────────┐
│                           base.html                                 │
│   <!DOCTYPE html>                                                  │
│   <html>                                                           │
│   <head>                                                           │
│       <title>{% block title %}Site{% endblock %}</title>           │
│   </head>                                                          │
│   <body>                                                           │
│       <nav>Navigation</nav>                                        │
│       {% block content %}{% endblock %}                           │
│       <footer>Footer</footer>                                      │
│   </body>                                                          │
│   </html>                                                          │
└─────────────────────────────────────────────────────────────────────┘
                              │
          ┌───────────────────┼───────────────────┐
          ▼                   ▼                   ▼
┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐
│   index.html    │ │   about.html    │ │   contact.html  │
│ {% extends      │ │ {% extends      │ │ {% extends      │
│  "base.html" %} │ │  "base.html" %} │ │  "base.html" %} │
│ {% block        │ │ {% block        │ │ {% block        │
│  title %}       │ │  title %}       │ │  title %}       │
│  Home           │ │  About          │ │  Contact        │
│ {% endblock %}  │ │ {% endblock %}  │ │ {% endblock %}  │
└─────────────────┘ └─────────────────┘ └─────────────────┘
```

### Template Syntax
```html
{# Variables #}
<h1>{{ title }}</h1>
<p>{{ user.name }}</p>
<p>{{ user.email | lower }}</p>

{# Conditions #}
{% if user.is_admin %}
    <a href="/admin">Admin</a>
{% elif user.is_manager %}
    <a href="/manager">Manager</a>
{% else %}
    <a href="/user">User</a>
{% endif %}

{# Loops #}
<ul>
{% for task in tasks %}
    <li>{{ task.title }}</li>
{% endfor %}
</ul>

{# Filters #}
<p>{{ text | truncate(100) }}</p>
<p>{{ date | datetime('%Y-%m-%d') }}</p>
<p>{{ html_content | safe }}</p>

{# Comments #}
{# This is a comment, not displayed #}

{# Include #}
{% include "_sidebar.html" %}

{# Macro #}
{% macro render_task(task) %}
    <div class="task">
        <h3>{{ task.title }}</h3>
        <p>{{ task.description }}</p>
    </div>
{% endmacro %}
```

### Template Filters

| Filter | Description | Example |
|--------|-------------|---------|
| `upper` | Convert to uppercase | `{{ name | upper }}` |
| `lower` | Convert to lowercase | `{{ name | lower }}` |
| `capitalize` | Capitalize first letter | `{{ name | capitalize }}` |
| `title` | Capitalize each word | `{{ name | title }}` |
| `truncate` | Truncate text | `{{ text | truncate(100) }}` |
| `safe` | Mark as safe HTML | `{{ html | safe }}` |
| `escape` | Escape HTML | `{{ html | escape }}` |
| `join` | Join list elements | `{{ list | join(', ') }}` |
| `length` | Get length | `{{ list | length }}` |
| `default` | Default value | `{{ value | default('N/A') }}` |

### Custom Template Filter
```python
# In app/__init__.py
@app.template_filter('datetime')
def format_datetime(value, format='%B %d, %Y'):
    if value is None:
        return ''
    return value.strftime(format)

# In template
{{ created_at | datetime }}
{{ created_at | datetime('%Y-%m-%d') }}
```

**My Notes:**
```
```

---

## 2.6 Forms with Flask-WTF

### Setup
```bash
pip install flask-wtf email-validator
```

### Form Definition
```python
from flask_wtf import FlaskForm
from wtforms import StringField, PasswordField, SubmitField, TextAreaField
from wtforms.validators import DataRequired, Email, Length, EqualTo

class RegistrationForm(FlaskForm):
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
```

### Form Field Types
```
StringField     → Text input
PasswordField   → Password input
TextAreaField   → Multi-line text
EmailField      → Email input
SelectField     → Dropdown
RadioField      → Radio buttons
BooleanField    → Checkbox
FileField       → File upload
HiddenField     → Hidden input
SubmitField     → Submit button
```

### Form in Template
```html
<form method="POST">
    {{ form.csrf_token }}
    
    <div class="form-group">
        {{ form.username.label }}
        {{ form.username(class="form-control") }}
        {% for error in form.username.errors %}
            <span class="text-danger">{{ error }}</span>
        {% endfor %}
    </div>
    
    <div class="form-group">
        {{ form.password.label }}
        {{ form.password(class="form-control") }}
        {% for error in form.password.errors %}
            <span class="text-danger">{{ error }}</span>
        {% endfor %}
    </div>
    
    {{ form.submit(class="btn btn-primary") }}
</form>
```

### Form Handling
```python
@app.route('/register', methods=['GET', 'POST'])
def register():
    form = RegistrationForm()
    
    if form.validate_on_submit():
        # Form is valid!
        username = form.username.data
        email = form.email.data
        password = form.password.data
        
        # Create user...
        return redirect(url_for('login'))
    
    # Form is invalid or GET request
    return render_template('register.html', form=form)
```

### Custom Validators
```python
from wtforms.validators import ValidationError

def validate_username(form, field):
    if not field.data.isalnum():
        raise ValidationError('Username must be alphanumeric')

class RegistrationForm(FlaskForm):
    username = StringField('Username', validators=[
        DataRequired(),
        validate_username
    ])

# Field-specific validator
def validate_username(form, field):
    user = User.query.filter_by(username=field.data).first()
    if user:
        raise ValidationError('Username already taken')
```

**My Notes:**
```
```

---

## 2.7 Flash Messages

### What are Flash Messages?
Flash messages are temporary messages displayed to users after actions (form submission, login, etc.)

### Usage
```python
from flask import flash, redirect, url_for

# Success message
flash('Task created successfully!', 'success')

# Error message
flash('Invalid credentials', 'danger')

# Warning message
flash('Your session will expire soon', 'warning')

# Info message
flash('Welcome back!', 'info')
```

### Displaying Flash Messages
```html
{% with messages = get_flashed_messages(with_categories=true) %}
    {% if messages %}
        {% for category, message in messages %}
            <div class="alert alert-{{ category }} alert-dismissible">
                {{ message }}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        {% endfor %}
    {% endif %}
{% endwith %}
```

### Message Categories
```
success  → Green (Bootstrap: alert-success)
danger   → Red (Bootstrap: alert-danger)
warning  → Yellow (Bootstrap: alert-warning)
info     → Blue (Bootstrap: alert-info)
```

### With Redirect
```python
@app.route('/login', methods=['POST'])
def login():
    if success:
        flash('Welcome back!', 'success')
        return redirect(url_for('dashboard'))
    else:
        flash('Invalid credentials', 'danger')
        return redirect(url_for('login'))

# Flash before redirect works automatically
```

**My Notes:**
```
```

---

## 2.8 Error Handling

### Custom Error Pages
```python
@app.errorhandler(404)
def not_found(error):
    return render_template('errors/404.html'), 404

@app.errorhandler(403)
def forbidden(error):
    return render_template('errors/403.html'), 403

@app.errorhandler(500)
def internal_error(error):
    return render_template('errors/500.html'), 500

@app.errorhandler(405)
def method_not_allowed(error):
    return render_template('errors/405.html'), 405
```

### Error Template Example
```html
<!-- errors/404.html -->
{% extends "base.html" %}

{% block content %}
<div class="text-center py-5">
    <h1 class="display-1 text-muted">404</h1>
    <h2>Page Not Found</h2>
    <p>The page you're looking for doesn't exist.</p>
    <a href="{{ url_for('main.index') }}" class="btn btn-primary">
        <i class="fas fa-home"></i> Return Home
    </a>
</div>
{% endblock %}
```

### Aborting with Custom Status
```python
from flask import abort

@app.route('/user/<int:user_id>')
def get_user(user_id):
    user = User.query.get(user_id)
    if not user:
        abort(404, description='User not found')
    return render_template('user.html', user=user)

@app.route('/admin')
@login_required
def admin_panel():
    if not current_user.is_admin:
        abort(403)
    return render_template('admin.html')
```

### Custom Error Handler with Context
```python
@app.errorhandler(Exception)
def handle_exception(error):
    app.logger.error(f"Unhandled error: {error}")
    return render_template('errors/500.html'), 500
```

**My Notes:**
```
```

---

# PART 3: DATABASES, ORM & DATA MODELING

---

## 3.1 SQLAlchemy Overview

### What is SQLAlchemy?
SQLAlchemy is a **SQL toolkit and ORM** for Python that provides:
- Object-Relational Mapping (ORM)
- SQL expression language
- Connection pooling
- Database abstraction

### ORM Benefits
```
┌─────────────────────────────────────────────────────────────────────┐
│                     Benefits of ORM                                 │
├─────────────────────────────────────────────────────────────────────┤
│  ✅ Write Python instead of SQL                                   │
│  ✅ Automatic SQL generation                                      │
│  ✅ Database abstraction (switch databases easily)                │
│  ✅ Relationship management                                       │
│  ✅ Query building                                                │
│  ✅ Type safety                                                   │
│  ✅ Lazy/eager loading                                            │
│  ✅ Connection pooling                                            │
└─────────────────────────────────────────────────────────────────────┘
```

### Setup
```bash
pip install flask-sqlalchemy psycopg2-binary
```

### Database URI Formats
```
SQLite:   sqlite:///path/to/database.db
PostgreSQL: postgresql://user:password@localhost/dbname
MySQL:    mysql://user:password@localhost/dbname
```

### Configuration
```python
# app/config.py
import os

class Config:
    SQLALCHEMY_DATABASE_URI = os.environ.get('DATABASE_URL', 'sqlite:///app.db')
    SQLALCHEMY_TRACK_MODIFICATIONS = False

# Production
class ProductionConfig(Config):
    SQLALCHEMY_DATABASE_URI = os.environ.get('DATABASE_URL')
    SQLALCHEMY_ENGINE_OPTIONS = {
        'pool_size': 10,
        'pool_recycle': 3600,
        'pool_pre_ping': True,
        'max_overflow': 20,
    }
```

**My Notes:**
```
```

---

## 3.2 Defining Models

### Basic Model
```python
from app.extensions import db
from datetime import datetime

class User(db.Model):
    __tablename__ = 'users'
    
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(50), unique=True, nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=False)
    password_hash = db.Column(db.String(128), nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    def __repr__(self):
        return f'<User {self.username}>'
    
    def to_dict(self):
        return {
            'id': self.id,
            'username': self.username,
            'email': self.email,
            'created_at': self.created_at.isoformat()
        }
```

### Column Types
| Type | Python | SQL | Description |
|------|--------|-----|-------------|
| `db.Integer` | `int` | INTEGER | Whole numbers |
| `db.String(50)` | `str` | VARCHAR(50) | Limited text |
| `db.Text` | `str` | TEXT | Unlimited text |
| `db.Boolean` | `bool` | BOOLEAN | True/False |
| `db.DateTime` | `datetime` | DATETIME | Date and time |
| `db.Date` | `date` | DATE | Date only |
| `db.Float` | `float` | FLOAT | Decimal numbers |
| `db.JSON` | `dict` | JSON | JSON data |

### Column Options
```python
# Primary key
id = db.Column(db.Integer, primary_key=True)

# Unique
email = db.Column(db.String(120), unique=True)

# Not Null
username = db.Column(db.String(50), nullable=False)

# Default value
created_at = db.Column(db.DateTime, default=datetime.utcnow)
is_active = db.Column(db.Boolean, default=True)

# Index
status = db.Column(db.String(20), index=True)

# Server default (database-side)
status = db.Column(db.String(20), server_default='pending')

# Auto-increment (automatic for Integer primary key)
id = db.Column(db.Integer, primary_key=True)
```

**My Notes:**
```
```

---

## 3.3 Relationships

### One-to-Many
```
┌─────────────┐     ┌─────────────┐
│    User     │     │    Task     │
├─────────────┤     ├─────────────┤
│ id (PK)     │────>│ id (PK)     │
│ username    │     │ title       │
│ email       │     │ user_id (FK)│
└─────────────┘     └─────────────┘
One User → Many Tasks
```

```python
class User(db.Model):
    __tablename__ = 'users'
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(50))
    
    # One-to-Many: User has many tasks
    tasks = db.relationship('Task', back_populates='user', lazy='dynamic')

class Task(db.Model):
    __tablename__ = 'tasks'
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(200))
    
    # Many-to-One: Task belongs to a User
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'))
    user = db.relationship('User', back_populates='tasks')
```

### Many-to-Many
```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│    Task     │     │  task_tags  │     │    Tag      │
├─────────────┤     ├─────────────┤     ├─────────────┤
│ id (PK)     │────>│ task_id (FK)│     │ id (PK)     │
│ title       │     │ tag_id (FK) │<────│ name        │
└─────────────┘     └─────────────┘     └─────────────┘
Task ←→ Tag (Many-to-Many)
```

```python
task_tags = db.Table('task_tags',
    db.Column('task_id', db.Integer, db.ForeignKey('tasks.id'), primary_key=True),
    db.Column('tag_id', db.Integer, db.ForeignKey('tags.id'), primary_key=True),
    db.Column('created_at', db.DateTime, default=datetime.utcnow)
)

class Task(db.Model):
    __tablename__ = 'tasks'
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(200))
    
    tags = db.relationship('Tag', secondary=task_tags, back_populates='tasks')

class Tag(db.Model):
    __tablename__ = 'tags'
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(50), unique=True)
    
    tasks = db.relationship('Task', secondary=task_tags, back_populates='tags')
```

### One-to-One
```python
class User(db.Model):
    __tablename__ = 'users'
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(50))
    
    profile = db.relationship('Profile', back_populates='user', uselist=False)

class Profile(db.Model):
    __tablename__ = 'profiles'
    id = db.Column(db.Integer, primary_key=True)
    bio = db.Column(db.Text)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'))
    
    user = db.relationship('User', back_populates='profile')
```

### Self-Referential Relationship
```python
class Comment(db.Model):
    __tablename__ = 'comments'
    id = db.Column(db.Integer, primary_key=True)
    text = db.Column(db.Text)
    parent_id = db.Column(db.Integer, db.ForeignKey('comments.id'))
    
    replies = db.relationship('Comment', backref=db.backref('parent', remote_side=[id]))
```

**My Notes:**
```
```

---

## 3.4 CRUD Operations

### CREATE
```python
# Single record
user = User(username='john', email='john@example.com')
user.set_password('password123')
db.session.add(user)
db.session.commit()

# Multiple records
users = [
    User(username='jane', email='jane@example.com'),
    User(username='bob', email='bob@example.com')
]
db.session.add_all(users)
db.session.commit()

# With relationships
user = User.query.first()
task = Task(title='Learn Flask', user=user)  # user_id auto-set
db.session.add(task)
db.session.commit()
```

### READ
```python
# All records
users = User.query.all()
tasks = Task.query.all()

# First record
first_user = User.query.first()

# Get by ID
user = User.query.get(1)

# Get or 404
user = User.query.get_or_404(1)

# Filter (equals)
users = User.query.filter_by(role='admin').all()

# Filter (condition)
users = User.query.filter(User.age >= 18).all()

# Multiple conditions
users = User.query.filter(
    User.age >= 18,
    User.is_active == True
).all()

# OR condition
from sqlalchemy import or_
users = User.query.filter(
    or_(User.role == 'admin', User.role == 'manager')
).all()

# LIKE
users = User.query.filter(User.username.like('%john%')).all()

# Order by
users = User.query.order_by(User.username.asc()).all()
users = User.query.order_by(User.created_at.desc()).all()

# Limit and offset
users = User.query.limit(10).offset(20).all()

# Count
count = User.query.count()
active_count = User.query.filter_by(is_active=True).count()
```

### UPDATE
```python
# Single record
user = User.query.get(1)
user.username = 'newusername'
user.email = 'newemail@example.com'
db.session.commit()

# Multiple fields
task = Task.query.get(1)
task.title = 'Updated Title'
task.status = 'completed'
db.session.commit()

# Bulk update
Task.query.filter_by(status='pending').update({'priority': 'high'})
db.session.commit()
```

### DELETE
```python
# Single record
user = User.query.get(1)
db.session.delete(user)
db.session.commit()

# With condition
Task.query.filter_by(status='archived').delete()
db.session.commit()
```

**My Notes:**
```
```

---

## 3.5 Advanced Queries

### Joins
```python
# Inner join
tasks = db.session.query(Task).join(User).filter(
    User.username == 'john'
).all()

# Left outer join
users = db.session.query(User).outerjoin(Task).filter(
    Task.id.is_(None)
).all()

# Multiple joins
tasks = db.session.query(Task).join(User).join(Category).all()

# Join with condition
tasks = db.session.query(Task).join(
    User, Task.user_id == User.id
).all()
```

### Aggregations
```python
from sqlalchemy import func

# Count
count = db.session.query(func.count(User.id)).scalar()

# Count with group
counts = db.session.query(
    User.role,
    func.count(User.id)
).group_by(User.role).all()

# Average
avg_age = db.session.query(func.avg(User.age)).scalar()

# Sum
total_tasks = db.session.query(func.sum(Task.id)).scalar()

# Min/Max
max_date = db.session.query(func.max(Task.created_at)).scalar()
```

### Subqueries
```python
# IN clause
subquery = db.session.query(Task.user_id).filter(
    Task.status == 'completed'
).subquery()
users = User.query.filter(User.id.in_(subquery)).all()

# EXISTS
from sqlalchemy import exists
subquery = db.session.query(Task).filter(
    Task.user_id == User.id
).exists()
users = User.query.filter(subquery).all()

# Correlated subquery
subquery = db.session.query(func.count(Task.id)).filter(
    Task.user_id == User.id
).correlate(User).scalar_subquery()
users = User.query.add_columns(subquery).all()
```

### Eager Loading
```python
from sqlalchemy.orm import joinedload, selectinload

# Avoid N+1 queries
tasks = Task.query.options(joinedload(Task.user)).all()

# Many-to-many
tasks = Task.query.options(selectinload(Task.tags)).all()

# Nested
users = User.query.options(
    joinedload(User.profile),
    selectinload(User.tasks)
).all()

# Multiple
tasks = Task.query.options(
    joinedload(Task.user),
    selectinload(Task.tags)
).all()
```

**My Notes:**
```
```

---

## 3.6 Database Migrations

### What are Migrations?
Migrations track changes to your database schema, allowing you to:
- Update schema without losing data
- Rollback changes
- Sync across environments

### Setup
```bash
pip install flask-migrate
```

```python
from flask_migrate import Migrate

migrate = Migrate(app, db)
```

### Commands
```bash
# Initialize migrations folder (first time only)
flask db init

# Create migration from model changes
flask db migrate -m "Add phone number to users"

# Apply migrations
flask db upgrade

# Rollback one migration
flask db downgrade -1

# Rollback to specific version
flask db downgrade abc123

# Show current version
flask db current

# Show history
flask db history

# Stamp without running
flask db stamp head
```

### Migration File Structure
```python
# migrations/versions/abc123_add_phone.py

def upgrade():
    op.add_column('users', sa.Column('phone', sa.String(20), nullable=True))
    op.add_column('users', sa.Column('is_active', sa.Boolean, server_default='true'))

def downgrade():
    op.drop_column('users', 'phone')
    op.drop_column('users', 'is_active')
```

### Best Practices
```
✅ Always backup before migrations
✅ Test migrations on staging first
✅ Use batch mode for large tables
✅ Include both upgrade and downgrade
✅ Test rollback before production
✅ Never edit migration files manually
✅ Commit migration files to version control
```

**My Notes:**
```
```

---

# PART 4: AUTHENTICATION, AUTHORIZATION & SECURITY

---

## 4.1 Authentication Setup

### Flask-Login Installation
```bash
pip install flask-login
```

### Configuration
```python
from flask_login import LoginManager

login_manager = LoginManager()
login_manager.init_app(app)

# Redirect to login page
login_manager.login_view = 'auth.login'
login_manager.login_message = 'Please log in to access this page.'
login_manager.login_message_category = 'warning'

# Session protection
login_manager.session_protection = 'strong'

# User loader
@login_manager.user_loader
def load_user(user_id):
    return User.query.get(int(user_id))
```

### User Model with Flask-Login
```python
from flask_login import UserMixin
from werkzeug.security import generate_password_hash, check_password_hash

class User(db.Model, UserMixin):
    __tablename__ = 'users'
    
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(50), unique=True, nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=False)
    password_hash = db.Column(db.String(128), nullable=False)
    is_active = db.Column(db.Boolean, default=True)
    
    def set_password(self, password):
        self.password_hash = generate_password_hash(password)
    
    def check_password(self, password):
        return check_password_hash(self.password_hash, password)
```

### UserMixin Provides
```
is_authenticated  → True for logged-in users
is_active        → True if account is active
is_anonymous     → False for logged-in users
get_id()         → Returns user ID
```

**My Notes:**
```
```

---

## 4.2 Password Security

### Hashing vs Encryption
```
Encryption (2-way):
  "password123" → encrypt → "xYz123!"
  ↓ Can be decrypted back to "password123"

Hashing (1-way):
  "password123" → hash → "7c6a180b36896a0a8c02787eeafb0e4c"
  ↓ Cannot be reversed!
  → Compare hashes to verify
```

### Werkzeug Password Hashing
```python
from werkzeug.security import generate_password_hash, check_password_hash

# Hash password
password_hash = generate_password_hash('mypassword')
# → 'pbkdf2:sha256:600000$...'

# Check password
is_valid = check_password_hash(password_hash, 'mypassword')
# → True if correct

# In User model
def set_password(self, password):
    self.password_hash = generate_password_hash(password)

def check_password(self, password):
    return check_password_hash(self.password_hash, password)
```

### Password Policy
```python
def validate_password(password):
    """Validate password strength."""
    if len(password) < 8:
        return False, 'Password must be at least 8 characters'
    
    if not any(c.isupper() for c in password):
        return False, 'Password must contain uppercase letter'
    
    if not any(c.islower() for c in password):
        return False, 'Password must contain lowercase letter'
    
    if not any(c.isdigit() for c in password):
        return False, 'Password must contain a number'
    
    if not any(c in '!@#$%^&*()_+-=' for c in password):
        return False, 'Password must contain a special character'
    
    return True, 'Password is valid'
```

### Common Password Mistakes
```
❌ Storing passwords in plain text
❌ Using weak hashing (MD5, SHA1)
❌ Not salting passwords
❌ Short passwords
❌ Common passwords
❌ Password reuse
❌ Not validating password strength
```

**My Notes:**
```
```

---

## 4.3 Registration & Login

### Registration
```python
from flask import render_template, redirect, url_for, flash, request
from flask_login import login_user, logout_user, login_required, current_user

@app.route('/register', methods=['GET', 'POST'])
def register():
    if current_user.is_authenticated:
        return redirect(url_for('dashboard'))
    
    form = RegistrationForm()
    
    if form.validate_on_submit():
        # Check if user exists
        if User.query.filter_by(email=form.email.data).first():
            flash('Email already registered', 'danger')
            return render_template('register.html', form=form)
        
        # Create user
        user = User(
            username=form.username.data,
            email=form.email.data
        )
        user.set_password(form.password.data)
        
        db.session.add(user)
        db.session.commit()
        
        flash('Registration successful! Please log in.', 'success')
        return redirect(url_for('login'))
    
    return render_template('register.html', form=form)
```

### Login
```python
@app.route('/login', methods=['GET', 'POST'])
def login():
    if current_user.is_authenticated:
        return redirect(url_for('dashboard'))
    
    form = LoginForm()
    
    if form.validate_on_submit():
        user = User.query.filter_by(email=form.email.data).first()
        
        if user and user.check_password(form.password.data):
            login_user(user, remember=form.remember.data)
            
            # Update last login
            user.last_login = datetime.utcnow()
            db.session.commit()
            
            # Redirect to next page
            next_page = request.args.get('next')
            if next_page:
                return redirect(next_page)
            
            flash('Login successful!', 'success')
            return redirect(url_for('dashboard'))
        
        flash('Invalid email or password', 'danger')
    
    return render_template('login.html', form=form)
```

### Logout
```python
@app.route('/logout')
@login_required
def logout():
    logout_user()
    flash('You have been logged out.', 'info')
    return redirect(url_for('home'))
```

### Login Form
```python
class LoginForm(FlaskForm):
    email = StringField('Email', validators=[DataRequired(), Email()])
    password = PasswordField('Password', validators=[DataRequired()])
    remember = BooleanField('Remember Me')
    submit = SubmitField('Login')
```

**My Notes:**
```
```

---

## 4.4 Authorization (RBAC)

### Role-Based Access Control
```python
# Role types
class UserRole:
    USER = 'user'
    MANAGER = 'manager'
    ADMIN = 'admin'

class User(db.Model):
    # ... existing fields ...
    role = db.Column(db.String(20), default=UserRole.USER)
    
    @property
    def is_admin(self):
        return self.role == UserRole.ADMIN
    
    @property
    def is_manager(self):
        return self.role in [UserRole.MANAGER, UserRole.ADMIN]

# Role-required decorator
from functools import wraps
from flask import abort

def role_required(role):
    def decorator(f):
        @wraps(f)
        def decorated(*args, **kwargs):
            if not current_user.is_authenticated:
                return redirect(url_for('login'))
            if current_user.role != role and current_user.role != UserRole.ADMIN:
                abort(403)
            return f(*args, **kwargs)
        return decorated
    return decorator

# Usage
@app.route('/admin')
@login_required
@role_required(UserRole.ADMIN)
def admin_panel():
    return render_template('admin.html')
```

### Permission System
```python
class Permission:
    VIEW_TASKS = 'view_tasks'
    CREATE_TASK = 'create_task'
    EDIT_TASK = 'edit_task'
    DELETE_TASK = 'delete_task'
    ASSIGN_TASK = 'assign_task'
    MANAGE_USERS = 'manage_users'
    VIEW_REPORTS = 'view_reports'

# Role-based permissions
ROLE_PERMISSIONS = {
    UserRole.USER: [
        Permission.VIEW_TASKS,
        Permission.CREATE_TASK,
        Permission.EDIT_TASK,
        Permission.DELETE_TASK,
    ],
    UserRole.MANAGER: [
        Permission.VIEW_TASKS,
        Permission.CREATE_TASK,
        Permission.EDIT_TASK,
        Permission.DELETE_TASK,
        Permission.ASSIGN_TASK,
        Permission.VIEW_REPORTS,
    ],
    UserRole.ADMIN: [
        # All permissions
    ]
}

def has_permission(permission):
    if current_user.is_admin:
        return True
    return permission in ROLE_PERMISSIONS.get(current_user.role, [])

def permission_required(permission):
    def decorator(f):
        @wraps(f)
        def decorated(*args, **kwargs):
            if not current_user.is_authenticated:
                return redirect(url_for('login'))
            if not has_permission(permission):
                abort(403)
            return f(*args, **kwargs)
        return decorated
    return decorator
```

**My Notes:**
```
```

---

## 4.5 CSRF Protection

### What is CSRF?
**Cross-Site Request Forgery** = Attack where malicious website tricks user's browser into making unauthorized requests.

### Flask-WTF CSRF
```python
from flask_wtf.csrf import CSRFProtect

csrf = CSRFProtect()
csrf.init_app(app)

# In forms (automatic)
<form method="POST">
    {{ form.csrf_token }}
    <!-- ... -->
</form>

# AJAX requests
<meta name="csrf-token" content="{{ csrf_token() }}">

<script>
fetch('/api/data', {
    method: 'POST',
    headers: {
        'X-CSRFToken': document.querySelector('meta[name="csrf-token"]').content
    }
})
</script>
```

### CSRF Exemptions
```python
@csrf.exempt
@app.route('/api/webhook', methods=['POST'])
def webhook():
    # CSRF protection disabled
    return 'OK'
```

**My Notes:**
```
```

---

## 4.6 Security Headers

### Essential Headers
```python
@app.after_request
def security_headers(response):
    # HSTS - Force HTTPS (1 year)
    response.headers['Strict-Transport-Security'] = 'max-age=31536000; includeSubDomains; preload'
    
    # Prevent clickjacking
    response.headers['X-Frame-Options'] = 'SAMEORIGIN'
    
    # Prevent MIME sniffing
    response.headers['X-Content-Type-Options'] = 'nosniff'
    
    # XSS protection (legacy)
    response.headers['X-XSS-Protection'] = '1; mode=block'
    
    # Referrer policy
    response.headers['Referrer-Policy'] = 'strict-origin-when-cross-origin'
    
    # CSP - Content Security Policy
    response.headers['Content-Security-Policy'] = (
        "default-src 'self'; "
        "script-src 'self' https://cdn.jsdelivr.net; "
        "style-src 'self' https://cdn.jsdelivr.net; "
        "img-src 'self' data: https:; "
        "font-src 'self'; "
        "connect-src 'self'"
    )
    
    return response
```

### CSP Explained
```
default-src 'self'          → Only load from same origin
script-src 'self'           → Only scripts from same origin
style-src 'self'            → Only styles from same origin
img-src 'self' data: https: → Images from same origin, data URIs, HTTPS
font-src 'self'             → Fonts from same origin
connect-src 'self'          → AJAX connections to same origin
```

**My Notes:**
```
```

---

# PART 5: BUILDING RESTFUL APIS

---

## 5.1 REST API Principles

### REST Architecture
```
┌─────────────────────────────────────────────────────────────────────┐
│                        REST Principles                              │
├─────────────────────────────────────────────────────────────────────┤
│                                                                    │
│  1. Resources (Nouns)                                              │
│     /users, /tasks, /categories                                   │
│                                                                    │
│  2. HTTP Methods (Verbs)                                          │
│     GET    → Read                                                  │
│     POST   → Create                                                │
│     PUT    → Replace                                               │
│     PATCH  → Update                                                │
│     DELETE → Delete                                                │
│                                                                    │
│  3. Stateless                                                      │
│     Each request contains all needed info                         │
│                                                                    │
│  4. Cacheable                                                      │
│     Responses explicitly marked cacheable or not                  │
│                                                                    │
│  5. Uniform Interface                                              │
│     Consistent patterns across resources                          │
│                                                                    │
│  6. Layered System                                                 │
│     Client doesn't know if it's talking to end server            │
│                                                                    │
└─────────────────────────────────────────────────────────────────────┘
```

### REST URL Structure
```
GET    /tasks                    → List all tasks
GET    /tasks/123                → Get specific task
POST   /tasks                    → Create new task
PUT    /tasks/123                → Update task (full)
PATCH  /tasks/123                → Update task (partial)
DELETE /tasks/123                → Delete task

GET    /users/123/tasks          → Tasks for user 123
GET    /tasks?status=pending     → Filter tasks
GET    /tasks?page=2&per_page=20 → Paginate tasks
```

**My Notes:**
```
```

---

## 5.2 Marshmallow Serialization

### Setup
```bash
pip install marshmallow marshmallow-sqlalchemy
```

### Basic Schema
```python
from marshmallow import Schema, fields, validate

class TaskSchema(Schema):
    id = fields.Int(dump_only=True)
    title = fields.Str(required=True, validate=validate.Length(min=1, max=200))
    description = fields.Str(allow_none=True)
    status = fields.Str(validate=validate.OneOf(['pending', 'in_progress', 'completed']))
    priority = fields.Str(validate=validate.OneOf(['low', 'medium', 'high']))
    created_at = fields.DateTime(dump_only=True)
    user_id = fields.Int(required=True)
```

### SQLAlchemy Auto Schema
```python
from marshmallow_sqlalchemy import SQLAlchemyAutoSchema

class TaskSchema(SQLAlchemyAutoSchema):
    class Meta:
        model = Task
        load_instance = True
        include_relationships = True
        include_fk = True
    
    # Custom fields
    user_name = fields.String(dump_only=True)
```

### Using Schemas
```python
# Serialize (Model → JSON)
schema = TaskSchema()
task = Task.query.get(1)
result = schema.dump(task)  # → dict

# Serialize multiple
schema = TaskSchema(many=True)
tasks = Task.query.all()
result = schema.dump(tasks)  # → list of dicts

# Deserialize (JSON → Model)
data = {'title': 'New Task', 'user_id': 1}
schema = TaskSchema()
validated = schema.load(data)  # → dict

# With validation
try:
    validated = schema.load(invalid_data)
except ValidationError as err:
    return {'errors': err.messages}, 400
```

**My Notes:**
```
```

---

## 5.3 API Endpoints

### Basic CRUD API
```python
from flask import Blueprint, request, jsonify
from app.schemas import TaskSchema
from app.models.task import Task

api_bp = Blueprint('api', __name__, url_prefix='/api')

# List
@api_bp.route('/tasks', methods=['GET'])
def list_tasks():
    tasks = Task.query.all()
    schema = TaskSchema(many=True)
    return jsonify(schema.dump(tasks))

# Create
@api_bp.route('/tasks', methods=['POST'])
def create_task():
    data = request.get_json()
    schema = TaskSchema()
    
    try:
        validated = schema.load(data)
        task = Task(**validated)
        db.session.add(task)
        db.session.commit()
        return jsonify(schema.dump(task)), 201
    except ValidationError as err:
        return jsonify({'errors': err.messages}), 400

# Read
@api_bp.route('/tasks/<int:task_id>', methods=['GET'])
def get_task(task_id):
    task = Task.query.get_or_404(task_id)
    schema = TaskSchema()
    return jsonify(schema.dump(task))

# Update
@api_bp.route('/tasks/<int:task_id>', methods=['PUT'])
def update_task(task_id):
    task = Task.query.get_or_404(task_id)
    data = request.get_json()
    schema = TaskSchema()
    
    try:
        validated = schema.load(data, partial=True)
        for key, value in validated.items():
            setattr(task, key, value)
        db.session.commit()
        return jsonify(schema.dump(task))
    except ValidationError as err:
        return jsonify({'errors': err.messages}), 400

# Delete
@api_bp.route('/tasks/<int:task_id>', methods=['DELETE'])
def delete_task(task_id):
    task = Task.query.get_or_404(task_id)
    db.session.delete(task)
    db.session.commit()
    return '', 204
```

### Filtering & Pagination
```python
@api_bp.route('/tasks', methods=['GET'])
def list_tasks():
    # Filtering
    query = Task.query
    
    if request.args.get('status'):
        query = query.filter_by(status=request.args['status'])
    
    if request.args.get('priority'):
        query = query.filter_by(priority=request.args['priority'])
    
    # Pagination
    page = request.args.get('page', 1, type=int)
    per_page = request.args.get('per_page', 20, type=int)
    
    paginated = query.paginate(page=page, per_page=per_page)
    
    schema = TaskSchema(many=True)
    return jsonify({
        'items': schema.dump(paginated.items),
        'pagination': {
            'page': page,
            'per_page': per_page,
            'total': paginated.total,
            'pages': paginated.pages
        }
    })
```

**My Notes:**
```
```

---

## 5.4 JWT Authentication

### Setup
```bash
pip install pyjwt
```

### Token Generation & Validation
```python
import jwt
from datetime import datetime, timedelta
from functools import wraps
from flask import request, jsonify, g

SECRET_KEY = os.environ.get('JWT_SECRET_KEY')

def generate_token(user_id):
    payload = {
        'user_id': user_id,
        'exp': datetime.utcnow() + timedelta(hours=1),
        'iat': datetime.utcnow()
    }
    return jwt.encode(payload, SECRET_KEY, algorithm='HS256')

def verify_token(token):
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=['HS256'])
        return payload['user_id']
    except jwt.ExpiredSignatureError:
        return None
    except jwt.InvalidTokenError:
        return None

def token_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        auth_header = request.headers.get('Authorization')
        
        if not auth_header or not auth_header.startswith('Bearer '):
            return jsonify({'error': 'Token required'}), 401
        
        token = auth_header[7:]  # Remove 'Bearer '
        user_id = verify_token(token)
        
        if not user_id:
            return jsonify({'error': 'Invalid or expired token'}), 401
        
        g.user_id = user_id
        return f(*args, **kwargs)
    return decorated
```

### Login Endpoint
```python
@api_bp.route('/login', methods=['POST'])
def api_login():
    data = request.get_json()
    email = data.get('email')
    password = data.get('password')
    
    user = User.query.filter_by(email=email).first()
    
    if user and user.check_password(password):
        token = generate_token(user.id)
        return jsonify({
            'token': token,
            'user': {
                'id': user.id,
                'username': user.username,
                'email': user.email
            }
        })
    
    return jsonify({'error': 'Invalid credentials'}), 401
```

### Protected Endpoint
```python
@api_bp.route('/tasks', methods=['GET'])
@token_required
def list_tasks():
    tasks = Task.query.filter_by(user_id=g.user_id).all()
    schema = TaskSchema(many=True)
    return jsonify(schema.dump(tasks))
```

**My Notes:**
```
```

---

## 5.5 Rate Limiting

### Setup
```bash
pip install flask-limiter
```

### Configuration
```python
from flask_limiter import Limiter
from flask_limiter.util import get_remote_address

limiter = Limiter(
    app=app,
    key_func=get_remote_address,
    default_limits=["200 per day", "50 per hour"]
)
```

### Usage
```python
# General rate limit
@api_bp.route('/tasks', methods=['GET'])
@limiter.limit("100 per minute")
def list_tasks():
    return jsonify(tasks)

# Stricter for write operations
@api_bp.route('/tasks', methods=['POST'])
@limiter.limit("30 per minute")
def create_task():
    return jsonify(task), 201

# Very strict for auth
@api_bp.route('/login', methods=['POST'])
@limiter.limit("5 per minute", error_message="Too many login attempts")
def login():
    return jsonify(token)

# User-based rate limiting
def get_user_key():
    if current_user.is_authenticated:
        return f"user:{current_user.id}"
    return get_remote_address()

@api_bp.route('/user-data')
@limiter.limit("60 per minute", key_func=get_user_key)
def user_data():
    return jsonify(data)
```

**My Notes:**
```
```

---

# PART 6: ASYNC PROGRAMMING & BACKGROUND PROCESSING

---

## 6.1 Async Fundamentals

### Sync vs Async
```
Synchronous (Blocking):
┌────────────┐     ┌────────────┐     ┌────────────┐
│  Request   │────>│  Database  │────>│  Response  │
└────────────┘     └────────────┘     └────────────┘
      │                  │
      │    Wait...       │ Processing...
      ▼                  ▼
      ⏱️                 ⏱️

Asynchronous (Non-blocking):
┌────────────┐     ┌────────────┐
│  Request 1 │────>│  Database  │
└────────────┘     └────────────┘
      │                  │
      ▼                  │
┌────────────┐           │
│  Request 2 │────>      │
└────────────┘           │
      │                  ▼
      ▼             ┌────────────┐
┌────────────┐     │  Response  │
│  Response  │<────│            │
└────────────┘     └────────────┘
```

### Flask 3.x Async Views
```python
import asyncio
import httpx

@app.route('/api/async-example')
async def async_example():
    await asyncio.sleep(1)
    return jsonify({'message': 'Async response'})

@app.route('/api/multiple-apis')
async def multiple_apis():
    async with httpx.AsyncClient() as client:
        tasks = [
            client.get('https://api1.example.com'),
            client.get('https://api2.example.com'),
            client.get('https://api3.example.com')
        ]
        results = await asyncio.gather(*tasks)
    
    return jsonify([r.json() for r in results])
```

### When to Use Async
```
✅ Good for Async:
  - External API calls
  - Database queries (with async drivers)
  - Multiple I/O operations
  - Long-running I/O

❌ Not for Async:
  - CPU-intensive operations
  - Simple database queries
  - Short operations (< 1ms)
```

**My Notes:**
```
```

---

## 6.2 Celery Setup

### What is Celery?
Celery is a **distributed task queue** for running background tasks.

### Architecture
```
┌─────────────────────────────────────────────────────────────────────┐
│                    Celery Architecture                              │
├─────────────────────────────────────────────────────────────────────┤
│                                                                    │
│   Flask App (Producer)                                             │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  @celery.task                                                │ │
│   │  def send_email():                                           │ │
│   │      # ...                                                   │ │
│   │                                                              │ │
│   │  send_email.delay(args)   ←── Enqueues task                │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                         │                                         │
│                         ▼                                         │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  Redis (Message Broker)                                     │ │
│   │  ┌────────────┐ ┌────────────┐ ┌────────────┐              │ │
│   │  │   Task 1   │ │   Task 2   │ │   Task 3   │              │ │
│   │  └────────────┘ └────────────┘ └────────────┘              │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                         │                                         │
│                         ▼                                         │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  Celery Workers                                             │ │
│   │  ┌────────────┐ ┌────────────┐ ┌────────────┐              │ │
│   │  │  Worker 1  │ │  Worker 2  │ │  Worker 3  │              │ │
│   │  └────────────┘ └────────────┘ └────────────┘              │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                         │                                         │
│                         ▼                                         │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  Redis (Result Backend)                                     │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                    │
└─────────────────────────────────────────────────────────────────────┘
```

### Setup
```bash
pip install celery redis
```

```python
# app/celery_worker.py
from celery import Celery

celery = Celery(
    'app',
    broker='redis://localhost:6379/0',
    backend='redis://localhost:6379/1'
)

celery.conf.update(
    task_serializer='json',
    accept_content=['json'],
    result_serializer='json',
    timezone='UTC',
    enable_utc=True,
    task_track_started=True,
    task_time_limit=30 * 60,
    task_soft_time_limit=25 * 60
)

celery.autodiscover_tasks(['app.tasks'])
```

### Starting Workers
```bash
# Start worker
celery -A app.celery_worker.celery worker --loglevel=info

# Start with multiple workers
celery -A app.celery_worker.celery worker --concurrency=4 --loglevel=info

# Start Beat (scheduler)
celery -A app.celery_worker.celery beat --loglevel=info

# Start both
celery -A app.celery_worker.celery worker --beat --loglevel=info
```

**My Notes:**
```
```

---

## 6.3 Creating Celery Tasks

### Basic Task
```python
from app.celery_worker import celery

@celery.task
def send_email(recipient, subject, body):
    """Send email asynchronously."""
    try:
        # Email sending logic
        mail.send_message(subject, recipients=[recipient], body=body)
        return {'status': 'sent', 'recipient': recipient}
    except Exception as e:
        return {'status': 'failed', 'error': str(e)}
```

### Task with Retry
```python
@celery.task(bind=True, max_retries=3)
def process_document(self, document_id):
    """Process document with retry logic."""
    try:
        doc = Document.query.get(document_id)
        # Process document...
        return {'status': 'processed', 'id': document_id}
    except Exception as e:
        # Retry with exponential backoff
        self.retry(
            exc=e,
            countdown=60 * (2 ** self.request.retries)
        )

@celery.task(bind=True, max_retries=5, default_retry_delay=60)
def call_external_api(self, url, data):
    try:
        response = requests.post(url, json=data, timeout=30)
        return response.json()
    except requests.exceptions.Timeout:
        self.retry(exc=Exception('Timeout'))
    except requests.exceptions.ConnectionError:
        self.retry(exc=Exception('Connection error'))
```

### Task with Progress
```python
@celery.task(bind=True)
def process_items(self, items):
    """Process items with progress tracking."""
    total = len(items)
    
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
        process_item(item)
    
    return {'processed': total, 'status': 'complete'}
```

**My Notes:**
```
```

---

## 6.4 Using Tasks in Routes

### Basic Usage
```python
from app.tasks.email import send_email

@app.route('/register', methods=['POST'])
def register():
    # Create user...
    db.session.commit()
    
    # Send email in background
    send_email.delay(
        recipient=user.email,
        subject='Welcome!',
        body='Thank you for registering.'
    )
    
    flash('Registration successful! Check your email.', 'success')
    return redirect(url_for('login'))

@app.route('/api/export')
@login_required
def export_data():
    task = generate_report.delay(current_user.id)
    
    return jsonify({
        'task_id': task.id,
        'status': 'started',
        'url': url_for('task_status', task_id=task.id)
    })
```

### Task Status Tracking
```python
from celery.result import AsyncResult

@app.route('/api/task/<task_id>')
@login_required
def task_status(task_id):
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
            'progress': result.info.get('percent', 0) if result.info else 0
        })
```

### Task with Callback
```python
@celery.task
def process_data(data):
    # Process data...
    return result

@app.route('/process', methods=['POST'])
def start_processing():
    data = request.get_json()
    
    # Chain tasks
    chain = (
        process_data.s(data) |
        send_notification.s('completed')
    )
    
    result = chain.apply_async()
    return jsonify({'task_id': result.id})
```

**My Notes:**
```
```

---

## 6.5 Scheduled Tasks

### Celery Beat Configuration
```python
from celery.schedules import crontab

celery.conf.beat_schedule = {
    # Daily at 8:00 AM
    'daily-report': {
        'task': 'app.tasks.generate_daily_report',
        'schedule': crontab(hour=8, minute=0),
        'kwargs': {'user_id': None}
    },
    
    # Monday at 9:00 AM
    'weekly-report': {
        'task': 'app.tasks.generate_weekly_report',
        'schedule': crontab(day_of_week=1, hour=9, minute=0)
    },
    
    # Every hour
    'cleanup': {
        'task': 'app.tasks.cleanup_old_files',
        'schedule': crontab(minute=0)
    },
    
    # Every 30 minutes
    'sync': {
        'task': 'app.tasks.sync_external',
        'schedule': crontab(minute='*/30')
    },
    
    # Custom interval
    'heartbeat': {
        'task': 'app.tasks.heartbeat',
        'schedule': 60.0  # Seconds
    }
}
```

### Crontab Syntax
```
┌───────────── minute (0 - 59)
│ ┌───────────── hour (0 - 23)
│ │ ┌───────────── day of month (1 - 31)
│ │ │ ┌───────────── month (1 - 12)
│ │ │ │ ┌───────────── day of week (0 - 6, Sunday=0)
│ │ │ │ │
* * * * * command to execute

Examples:
0 8 * * *     → Daily at 8:00 AM
0 9 * * 1     → Monday at 9:00 AM
*/15 * * * *  → Every 15 minutes
0 0 * * 0     → Sunday at midnight
30 2 * * *    → Daily at 2:30 AM
0 0 1 * *     → First of every month
```

**My Notes:**
```
```

---

# PART 7: TESTING, DEBUGGING & QUALITY ASSURANCE

---

## 7.1 Testing Fundamentals

### The Testing Pyramid
```
          ┌─────────────┐
          │   E2E Tests │   ← Few (slow, comprehensive)
         ┌┴─────────────┴┐
         │ Integration   │   ← Some (medium)
        ┌┴───────────────┴┐
        │   Unit Tests     │   ← Many (fast, focused)
        └──────────────────┘
```

### Test Types
| Type | What | Speed | Count |
|------|------|-------|-------|
| **Unit** | Individual functions | Fast | Many |
| **Integration** | Component interactions | Medium | Some |
| **Functional** | Feature workflows | Slow | Few |

### Pytest Installation
```bash
pip install pytest pytest-cov factory-boy faker
```

### Basic Test
```python
# tests/test_example.py
def test_addition():
    result = 2 + 2
    assert result == 4

def test_string_contains():
    text = "Hello World"
    assert "World" in text

def test_list_length():
    items = [1, 2, 3]
    assert len(items) == 3
    assert 1 in items
```

**My Notes:**
```
```

---

## 7.2 Pytest Fixtures

### Fixture Basics
```python
# tests/conftest.py
import pytest
from app import create_app
from app.extensions import db

@pytest.fixture
def app():
    """Create test application."""
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
        email='test@example.com'
    )
    user.set_password('password123')
    db_session.add(user)
    db_session.commit()
    return user

@pytest.fixture
def auth_client(client, test_user):
    """Create authenticated client."""
    client.post('/auth/login', data={
        'email': 'test@example.com',
        'password': 'password123'
    })
    return client
```

### Using Fixtures
```python
def test_user_creation(db_session, test_user):
    """Test using fixtures."""
    assert test_user.id is not None
    assert test_user.username == 'testuser'

def test_auth_page(auth_client):
    """Test authenticated route."""
    response = auth_client.get('/dashboard')
    assert response.status_code == 200
```

### Factory Fixtures
```python
from factory import Factory
from faker import Faker
faker = Faker()

class UserFactory(Factory):
    class Meta:
        model = User
    
    username = faker.user_name()
    email = faker.email()
    
    @factory.post_generation
    def set_password(self, create, extracted, **kwargs):
        self.set_password('password123')

@pytest.fixture
def user_factory(db_session):
    """Create user factory."""
    def create(**kwargs):
        user = UserFactory.build(**kwargs)
        db_session.add(user)
        db_session.commit()
        return user
    return create
```

**My Notes:**
```
```

---

## 7.3 Writing Tests

### Model Tests
```python
# tests/test_models.py
class TestUserModel:
    def test_create_user(self, db_session):
        user = User(username='john', email='john@example.com')
        user.set_password('password123')
        db_session.add(user)
        db_session.commit()
        
        assert user.id is not None
        assert user.username == 'john'
        assert user.check_password('password123') is True
    
    def test_unique_email(self, db_session):
        user1 = User(username='user1', email='test@example.com')
        user2 = User(username='user2', email='test@example.com')
        db_session.add(user1)
        db_session.commit()
        
        with pytest.raises(Exception):
            db_session.add(user2)
            db_session.commit()
```

### Route Tests
```python
# tests/test_routes.py
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
        assert b'Dashboard' in response.data

class TestProtectedRoutes:
    def test_dashboard_requires_login(self, client):
        response = client.get('/dashboard')
        assert response.status_code == 302
        assert '/auth/login' in response.headers['Location']
```

### API Tests
```python
# tests/test_api.py
class TestAPI:
    def test_get_tasks(self, auth_client, test_task):
        response = auth_client.get('/api/tasks')
        assert response.status_code == 200
        data = response.json
        assert len(data) >= 1
    
    def test_create_task(self, auth_client):
        response = auth_client.post('/api/tasks', 
            json={'title': 'API Test'}
        )
        assert response.status_code == 201
        assert response.json['title'] == 'API Test'
```

**My Notes:**
```
```

---

## 7.4 Coverage Reports

### Running Coverage
```bash
# Install coverage
pip install pytest-cov

# Run with coverage
pytest --cov=app --cov-report=html --cov-report=term

# Open HTML report
open htmlcov/index.html
```

### Coverage Configuration
```ini
# .coveragerc
[run]
source = app
omit = 
    app/__init__.py
    app/extensions.py
    */migrations/*
    */tests/*
    */venv/*

[report]
exclude_lines =
    pragma: no cover
    def __repr__
    def __str__
    if __name__ == .__main__.:
    raise NotImplementedError

fail_under = 80
```

### Coverage Goals
```
Minimum: 80%
Good: 90%
Excellent: 95%+

Focus coverage on:
- Critical paths
- Business logic
- Authentication
- Error handling
- Edge cases
```

**My Notes:**
```
```

---

## 7.5 Debugging

### Print Debugging
```python
# Simple print
print(f"DEBUG: user_id = {user_id}")
print(f"DEBUG: result = {result}")

# Pretty print
import pprint
pprint.pprint(data)

# Logging (better)
app.logger.debug(f"Processing user {user_id}")
app.logger.info(f"Task {task_id} completed")
app.logger.error(f"Error: {e}")
```

### Python Debugger (pdb)
```python
import pdb

def complex_function(data):
    pdb.set_trace()  # Breakpoint
    result = process(data)
    return result

# pdb Commands:
# n  → next line
# s  → step into function
# c  → continue execution
# p variable → print variable
# l  → list code
# ll → list more code
# q  → quit debugger
```

### Flask Debugger
```python
# Enable in development
app.run(debug=True)

# When error occurs:
# - Interactive debugger in browser
# - Can execute code
# - Shows stack trace
# - NEVER use in production!
```

### Debugging Database Queries
```python
# Log all queries
import logging
logging.getLogger('sqlalchemy.engine').setLevel(logging.INFO)

# In config
app.config['SQLALCHEMY_ECHO'] = True

# Profile query
from sqlalchemy import event
@event.listens_for(db.engine, "before_execute")
def before_execute(conn, clause, multiparams, params):
    print(f"Query: {clause}")
    print(f"Params: {params}")
```

**My Notes:**
```
```

---

# PART 8: PRODUCTION DEPLOYMENT, DEVOPS & MONITORING

---

## 8.1 Production Stack

### Architecture
```
┌─────────────────────────────────────────────────────────────────────┐
│                         Users                                       │
└─────────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────────┐
│                      Internet                                       │
└─────────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    Load Balancer                                    │
│              (AWS ELB, Nginx, HAProxy)                             │
└─────────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    Nginx (Reverse Proxy)                            │
│  - SSL Termination                                                  │
│  - Static File Serving                                              │
│  - Load Balancing                                                   │
└─────────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    Gunicorn (WSGI Server)                           │
│  - Multiple Workers                                                 │
│  - Process Management                                               │
└─────────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────────┐
│                Flask Application (Your Code)                        │
└─────────────────────────────────────────────────────────────────────┘
                              │
          ┌───────────────────┼───────────────────┐
          ▼                   ▼                   ▼
┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐
│   PostgreSQL    │ │     Redis       │ │    Celery       │
│   (Database)    │ │    (Cache)      │ │   (Workers)     │
└─────────────────┘ └─────────────────┘ └─────────────────┘
```

### Development vs Production

| Aspect | Development | Production |
|--------|-------------|------------|
| **Server** | Flask built-in | Gunicorn |
| **Debug** | ON | OFF |
| **Database** | SQLite | PostgreSQL |
| **Cache** | None | Redis |
| **HTTPS** | No | Yes (Nginx) |
| **Static Files** | Flask serves | Nginx serves |
| **Workers** | 1 | Multiple |
| **Logging** | Console | File/Cloud |

**My Notes:**
```
```

---

## 8.2 Gunicorn

### Installation
```bash
pip install gunicorn
```

### Configuration
```python
# gunicorn.conf.py
import multiprocessing

# Server socket
bind = '0.0.0.0:8000'
backlog = 2048

# Workers (2 * CPU + 1)
workers = multiprocessing.cpu_count() * 2 + 1
worker_class = 'sync'
threads = 2

# Timeouts
timeout = 120
graceful_timeout = 30
keepalive = 5

# Max requests before restart
max_requests = 1000
max_requests_jitter = 100

# Performance
preload_app = True
worker_tmp_dir = '/dev/shm'

# Logging
accesslog = '-'
errorlog = '-'
loglevel = 'info'
```

### Running Gunicorn
```bash
# Using config file
gunicorn -c gunicorn.conf.py run:app

# With custom settings
gunicorn --workers=4 --bind=0.0.0.0:8000 run:app

# With UNIX socket
gunicorn --bind=unix:/tmp/taskflow.sock run:app

# With logging
gunicorn --access-logfile logs/access.log --error-logfile logs/error.log run:app
```

### Worker Types
```
sync     → Default, good for CPU-bound
gevent   → Good for I/O-bound
eventlet → Good for I/O-bound
tornado  → Good for WebSocket
gthread  → Good for mixed workloads
```

**My Notes:**
```
```

---

## 8.3 Nginx

### Configuration
```nginx
# /etc/nginx/sites-available/taskflow

upstream taskflow_app {
    server unix:/tmp/taskflow.sock fail_timeout=0;
    # server 127.0.0.1:8000 fail_timeout=0;  # TCP alternative
}

server {
    listen 80;
    server_name your-domain.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name your-domain.com;
    
    # SSL
    ssl_certificate /etc/ssl/certs/your-domain.crt;
    ssl_certificate_key /etc/ssl/private/your-domain.key;
    ssl_protocols TLSv1.2 TLSv1.3;
    
    # Security Headers
    add_header Strict-Transport-Security "max-age=31536000" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    
    # Static Files
    location /static/ {
        alias /var/www/taskflow/static/;
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
    
    # Uploads
    location /uploads/ {
        alias /var/www/taskflow/uploads/;
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
    
    # Health Check
    location /health {
        proxy_pass http://taskflow_app;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    # Main Application
    location / {
        proxy_pass http://taskflow_app;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }
}
```

### Starting Nginx
```bash
# Test configuration
sudo nginx -t

# Start/reload
sudo systemctl start nginx
sudo systemctl reload nginx
sudo systemctl restart nginx
```

**My Notes:**
```
```

---

## 8.4 Docker

### Dockerfile
```dockerfile
FROM python:3.13-slim

WORKDIR /app

# Install dependencies
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

### Docker Compose
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
  
  worker:
    build: .
    command: celery -A app.celery_worker.celery worker --loglevel=info
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
  
  redis:
    image: redis:7-alpine

volumes:
  postgres_data:
```

### Docker Commands
```bash
# Build image
docker build -t taskflow:latest .

# Start services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down

# Rebuild and restart
docker-compose up -d --build
```

**My Notes:**
```
```

---

## 8.5 CI/CD

### GitHub Actions Workflow
```yaml
name: Deploy TaskFlow

on:
  push:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.13'
      
      - name: Install dependencies
        run: |
          pip install -r requirements.txt
          pip install -r requirements-dev.txt
      
      - name: Run tests
        run: pytest --cov=app
  
  deploy:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - name: Deploy to server
        run: |
          ssh user@server "cd /app && git pull && docker-compose up -d --build"
```

### CI/CD Pipeline Stages
```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│    Test     │────>│    Build    │────>│   Deploy    │────>│   Verify    │
└─────────────┘     └─────────────┘     └─────────────┘     └─────────────┘
  • Run tests       • Build Docker    • Deploy to         • Health check
  • Lint code       • Push to         • staging/          • Smoke tests
  • Security scan   • registry        • production        • Rollback if
                                                          • needed
```

**My Notes:**
```
```

---

## 8.6 Monitoring

### Health Check
```python
@app.route('/health')
def health_check():
    # Check database
    db_healthy = True
    try:
        db.session.execute('SELECT 1')
    except:
        db_healthy = False
    
    # Check Redis
    redis_healthy = True
    try:
        redis_client.ping()
    except:
        redis_healthy = False
    
    status = 'healthy' if (db_healthy and redis_healthy) else 'unhealthy'
    
    return jsonify({
        'status': status,
        'timestamp': datetime.utcnow().isoformat(),
        'database': 'connected' if db_healthy else 'disconnected',
        'redis': 'connected' if redis_healthy else 'disconnected'
    }), 200 if status == 'healthy' else 503
```

### Logging
```python
import logging
from logging.handlers import RotatingFileHandler

def setup_production_logging(app):
    # Create logs directory
    os.makedirs('logs', exist_ok=True)
    
    # File handler with rotation
    file_handler = RotatingFileHandler(
        'logs/app.log',
        maxBytes=10*1024*1024,  # 10MB
        backupCount=5
    )
    file_handler.setLevel(logging.INFO)
    
    # Error handler
    error_handler = RotatingFileHandler(
        'logs/errors.log',
        maxBytes=10*1024*1024,
        backupCount=10
    )
    error_handler.setLevel(logging.ERROR)
    
    # Format
    formatter = logging.Formatter(
        '%(asctime)s %(levelname)s: %(message)s [in %(pathname)s:%(lineno)d]'
    )
    file_handler.setFormatter(formatter)
    error_handler.setFormatter(formatter)
    
    app.logger.addHandler(file_handler)
    app.logger.addHandler(error_handler)
    app.logger.setLevel(logging.INFO)
```

### Metrics with Prometheus
```python
from prometheus_client import Counter, Histogram, generate_latest, REGISTRY

REQUEST_COUNT = Counter('http_requests_total', 'Total HTTP requests')
REQUEST_DURATION = Histogram('http_request_duration_seconds', 'HTTP request duration')
ERROR_COUNT = Counter('http_errors_total', 'Total HTTP errors')

@app.before_request
def before_request():
    g.start_time = time.time()

@app.after_request
def after_request(response):
    duration = time.time() - g.start_time
    
    REQUEST_COUNT.inc()
    REQUEST_DURATION.observe(duration)
    
    if response.status_code >= 400:
        ERROR_COUNT.inc()
    
    return response

@app.route('/metrics')
def metrics():
    return Response(generate_latest(REGISTRY), mimetype='text/plain')
```

**My Notes:**
```
```

---

# FINAL NOTES

## Key Concepts Summary

### Flask Fundamentals
- Application Factory Pattern
- Blueprints for modularity
- Environment-based configuration
- Code quality tools (Ruff, Black, isort, mypy)

### Web Development
- URL routing with dynamic parameters
- Jinja2 templating with inheritance
- Form handling with Flask-WTF
- Flash messages and error handling

### Database & ORM
- SQLAlchemy models and relationships
- CRUD operations
- Alembic migrations
- Repository pattern
- Query optimization

### Authentication & Security
- Password hashing with Werkzeug
- Session management with Flask-Login
- Role-based access control
- CSRF protection
- Security headers

### API Development
- REST principles
- Marshmallow serialization
- Token authentication
- Rate limiting
- API documentation

### Async & Background
- Async views
- Celery tasks
- Scheduled jobs
- Task monitoring

### Testing
- Unit tests with Pytest
- Integration tests
- Functional tests
- Coverage reporting

### Deployment
- Gunicorn WSGI server
- Nginx reverse proxy
- Docker containerization
- CI/CD pipelines
- Monitoring and logging

## Important Commands

```bash
# Development
flask run
flask shell
flask routes

# Migrations
flask db init
flask db migrate -m "message"
flask db upgrade
flask db downgrade

# Testing
pytest
pytest --cov=app

# Production
gunicorn -c gunicorn.conf.py run:app
docker-compose up -d
docker-compose logs -f

# Celery
celery -A app.celery_worker.celery worker --loglevel=info
celery -A app.celery_worker.celery beat --loglevel=info

# Code Quality
black app/
ruff check app/
mypy app/
```

---

**Happy Coding! 🚀**
