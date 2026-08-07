# Master Modern Flask 3.x: Comprehensive Slide Deck Outline

## Complete Teaching Presentation for the Entire Series

---

# PART 0: INTRODUCTION
## Setting the Stage

### Slide 0.1: Title Slide
**Master Modern Flask 3.x**
*From Beginner to Production-Ready Applications*

**Subtitle:** A Comprehensive 8-Part Journey to Flask Mastery

**Presented by:** [Your Name/Organization]

**Date:** [Presentation Date]

---

### Slide 0.2: The Problem We're Solving

**The Challenge:**
```
"I know Python, but web development seems overwhelming."

"Django is too opinionated, but I need structure."

"All tutorials show small scripts, not real applications."

"How do I deploy to production securely?"
```

**The Solution:**
```
Flask's Minimalist Philosophy + Professional Patterns =
Your Path to Production-Ready Web Apps
```

---

### Slide 0.3: What You Will Build - TaskFlow

**Application Features:**
```
┌─────────────────────────────────────────────────────────┐
│  🏗️ TaskFlow - Complete Task Management System         │
├─────────────────────────────────────────────────────────┤
│  ✅ Professional Project Architecture                   │
│  ✅ User Registration & Authentication                  │
│  ✅ Role-Based Access Control                          │
│  ✅ Full CRUD Task Management                          │
│  ✅ Categories & Tags                                 │
│  ✅ RESTful API Endpoints                             │
│  ✅ Background Task Processing                        │
│  ✅ Email Notifications                               │
│  ✅ Comprehensive Testing Suite                       │
│  ✅ Dockerized Production Deployment                  │
│  ✅ Production Monitoring & Logging                   │
└─────────────────────────────────────────────────────────┘
```

---

### Slide 0.4: The Learning Journey

**8-Phase Roadmap:**

```
┌─────────────────────────────────────────────────────────────┐
│ Phase 1: Foundations & Architecture                        │
│ Phase 2: Routing, Requests & Templating                    │
│ Phase 3: Databases & ORM                                  │
│ Phase 4: Authentication & Security                        │
│ Phase 5: RESTful APIs                                     │
│ Phase 6: Async Programming & Background Processing        │
│ Phase 7: Testing & Quality Assurance                     │
│ Phase 8: Production Deployment & DevOps                   │
└─────────────────────────────────────────────────────────────┘

+ 10 Comprehensive Primers for Beginners
+ 10 Advanced Appendices for Experts
```

---

### Slide 0.5: The Technology Stack

**Modern Tools & Libraries:**

| Category | Technology | Version |
|----------|------------|---------|
| **Language** | Python | 3.13+ |
| **Web Framework** | Flask | 3.x |
| **ORM** | SQLAlchemy | 2.x |
| **Database** | PostgreSQL | Latest |
| **Migrations** | Alembic | Latest |
| **Templating** | Jinja | 3.x |
| **Authentication** | Flask-Login | Latest |
| **API** | Flask-RESTful | Latest |
| **Async** | Celery + Redis | Latest |
| **Testing** | Pytest | Latest |
| **Production** | Gunicorn + Nginx + Docker | Latest |

---

### Slide 0.6: Prerequisites

**What You Should Know:**

**Already Know:**
- ✅ Basic Python syntax
- ✅ Functions and classes
- ✅ Fundamental HTML/CSS
- ✅ Basic SQL concepts
- ✅ Command line basics

**Will Learn:**
- 🆕 Flask internals and patterns
- 🆕 Professional web development
- 🆕 Database design with SQLAlchemy
- 🆕 Security and authentication
- 🆕 API design and development
- 🆕 Testing and quality assurance
- 🆕 Production deployment

---

### Slide 0.7: Learning Outcomes

**By the End of This Course:**

1. 🏗️ Design professional Flask applications using the Application Factory Pattern

2. 🔐 Build secure authentication systems with Flask-Login

3. 📊 Create robust database models with SQLAlchemy 2.x

4. 🌐 Develop RESTful APIs with proper versioning

5. ⚡ Implement async programming and background tasks

6. 🧪 Write comprehensive tests with Pytest

7. 🚀 Deploy production applications with Docker and Gunicorn

8. 🔍 Monitor, log, and troubleshoot deployed applications

---

### Slide 0.8: Teaching Methodology

**How We Learn Together:**

```
┌─────────────────────────────────────────────────────────────┐
│                   Hands-On Learning                         │
├─────────────────────────────────────────────────────────────┤
│  1. Target: What are we building?                          │
│  2. Concept: Why does it matter?                          │
│  3. Implementation: Complete, unabbreviated code          │
│  4. Verification: Test it works before moving on          │
└─────────────────────────────────────────────────────────────┘

✅ Code-Heavy: No placeholders, copy-paste ready
✅ Beginner-Friendly: Clear explanations with analogies
✅ Expert Inside: Production-grade code quality
✅ Logical Progression: Each step builds on the last
```

---

# PART 1: FLASK FOUNDATIONS
## Building Your Architecture

### Slide 1.0: Part 1 Overview

**Flask Foundations & Modern Project Architecture**

**What You'll Learn:**
- Flask's philosophy and internal architecture
- Setting up Python 3.13+ with virtual environments
- The Application Factory Pattern
- Environment-specific configuration
- Blueprint-based modular design
- Code quality tools (Ruff, Black, isort, mypy)

**What You'll Build:**
- Complete project skeleton
- Application Factory with environment-aware settings
- Logging configuration
- Development server setup

---

### Slide 1.1: What is Flask?

**The Minimalist Web Framework:**

```
Flask = Microframework + Extensions

Microframework Philosophy:
- Core is simple and small
- Features are opt-in
- You control the architecture

Unlike Django:
- No built-in admin
- No ORM requirement
- No project structure rules
- Maximum flexibility

Analogy: Flask is a food truck, Django is a full restaurant chain.
```

**The Success Formula:**
```
Flask + Extensions + Your Code = Anything You Want to Build
```

---

### Slide 1.2: Flask vs Django vs FastAPI

**Framework Comparison:**

| Aspect | Flask | Django | FastAPI |
|--------|-------|--------|---------|
| **Philosophy** | Minimalist | Batteries-included | Modern async |
| **Database** | Any (SQLAlchemy) | Built-in ORM | Any |
| **Admin** | Optional | Built-in | Optional |
| **Async** | Native | Limited | Native |
| **Learning Curve** | Gentle | Steep | Moderate |
| **Best For** | Small-medium, APIs | Large, content-heavy | APIs, real-time |

**Flask's Sweet Spot:**
```
✅ When you want control
✅ When you're learning
✅ When building APIs
✅ When you need flexibility
✅ When you want to understand web development deeply
```

---

### Slide 1.3: Flask's Internal Architecture

**The Three Pillars of Flask:**

```
┌─────────────────────────────────────────────────────────────┐
│                    Flask Architecture                        │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1. Werkzeug: The WSGI Toolkit                            │
│     - Request/Response objects                             │
│     - URL routing                                          │
│     - Development server                                   │
│                                                             │
│  2. Jinja2: The Templating Engine                         │
│     - Template inheritance                                 │
│     - Auto-escaping                                        │
│     - Extensible filters and macros                        │
│                                                             │
│  3. Click: The CLI Framework                              │
│     - Command-line interface                               │
│     - Custom commands                                      │
│     - Development utilities                                │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Analogy: Werkzeug = Engine, Jinja = Interior, Click = Dashboard**

---

### Slide 1.4: Development Environment Setup

**Step-by-Step Setup:**

```bash
# 1. Create project directory
mkdir taskflow
cd taskflow

# 2. Create virtual environment
python3.13 -m venv venv

# 3. Activate environment
source venv/bin/activate  # macOS/Linux
# venv\Scripts\activate    # Windows

# 4. Create pyproject.toml (dependency management)
# 5. Install Flask and dependencies
pip install flask flask-sqlalchemy flask-migrate

# 6. Create .gitignore for Python
# 7. Set up development tools
pip install ruff black isort mypy pre-commit
```

**Virtual Environment Analogy:**
*Like having a separate kitchen for each project - tools don't get mixed up!*

---

### Slide 1.5: Project Structure

**Professional Flask Project Layout:**

```
taskflow/
├── app/
│   ├── __init__.py              # Application factory
│   ├── config.py                # Configuration classes
│   ├── extensions.py            # Extension initialization
│   ├── logging_config.py        # Logging setup
│   │
│   ├── blueprints/              # Route modules
│   │   ├── main/               # Public pages
│   │   ├── auth/               # Authentication
│   │   ├── tasks/              # Task management
│   │   ├── admin/              # Admin dashboard
│   │   └── api/                # REST API
│   │
│   ├── models/                  # Database models
│   ├── forms/                   # WTForms
│   ├── services/                # Business logic
│   ├── templates/               # Jinja templates
│   ├── static/                  # CSS, JS, images
│   └── utils/                   # Utilities
│
├── tests/                       # Test suite
├── migrations/                  # Alembic migrations
├── docker/                      # Docker configuration
├── scripts/                     # Deployment scripts
└── run.py                       # Development entry point
```

---

### Slide 1.6: The Application Factory Pattern

**Why Application Factory Matters:**

```python
# ❌ Without Factory Pattern (Global App)
app = Flask(__name__)

@app.route('/')
def home():
    return 'Hello'

if __name__ == '__main__':
    app.run()

# Problems:
# - Can't use different configs
# - Hard to test
# - Circular imports
```

```python
# ✅ With Factory Pattern
def create_app(config_class=None):
    app = Flask(__name__)
    
    if config_class:
        app.config.from_object(config_class)
    
    # Initialize extensions
    db.init_app(app)
    login_manager.init_app(app)
    
    # Register blueprints
    app.register_blueprint(main_bp)
    app.register_blueprint(auth_bp, url_prefix='/auth')
    
    return app

# Benefits:
# - Multiple configurations
# - Easy testing
# - Extension control
# - No global state
```

**Analogy: Like having a restaurant kitchen that can be set up for different menus!**

---

### Slide 1.7: Configuration Management

**Environment-Specific Configuration:**

```python
class Config:
    """Base configuration."""
    SECRET_KEY = os.environ.get('SECRET_KEY')
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
    SESSION_COOKIE_SECURE = True
    SESSION_COOKIE_HTTPONLY = True

config_by_name = {
    'development': DevelopmentConfig,
    'testing': TestingConfig,
    'production': ProductionConfig,
}

# Use environment variable to select config
env = os.environ.get('FLASK_ENV', 'development')
app.config.from_object(config_by_name[env])
```

**Analogy: Different tools for different jobs (like a chef's knife set)!**

---

### Slide 1.8: Blueprints - Modular Routes

**Why Blueprints?**

```
Without Blueprints:
app/__init__.py → All routes in one file
      ↓
Problem: 1000+ lines, hard to maintain

With Blueprints:
app/blueprints/
    ├── main.py    → Public pages (50 lines)
    ├── auth.py    → Authentication (100 lines)
    ├── tasks.py   → Task management (200 lines)
    └── admin.py   → Admin panel (150 lines)
      ↓
Benefit: Each feature is separate and maintainable
```

**Blueprint Example:**

```python
# app/blueprints/auth.py
from flask import Blueprint

auth_bp = Blueprint('auth', __name__, url_prefix='/auth')

@auth_bp.route('/login')
def login():
    return render_template('auth/login.html')

@auth_bp.route('/logout')
@login_required
def logout():
    logout_user()
    return redirect(url_for('main.index'))

# Register in app factory
app.register_blueprint(auth_bp)
```

---

### Slide 1.9: Code Quality Tools

**Professional Development Toolkit:**

```
┌─────────────────────────────────────────────────────────────┐
│                    Code Quality Tools                       │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Ruff: The Fast Linter                                     │
│  - Catches bugs and style issues                           │
│  - 10-100x faster than traditional linters                 │
│                                                             │
│  Black: The Uncompromising Formatter                       │
│  - Automatic code formatting                               │
│  - No configuration needed                                 │
│                                                             │
│  isort: Import Organizer                                   │
│  - Sorts imports consistently                              │
│  - Groups by type                                          │
│                                                             │
│  mypy: Type Checker                                        │
│  - Catches type errors                                     │
│  - Improves code quality                                   │
│                                                             │
│  pre-commit: Git Hooks                                     │
│  - Runs checks before commit                               │
│  - Prevents bad code from being committed                  │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

### Slide 1.10: Part 1 Summary

**What You've Built:**

```
✅ Project Structure: Professional folder layout
✅ Application Factory: Configurable app creation
✅ Configuration: Environment-specific settings
✅ Blueprints: Modular route organization
✅ Logging: Production-ready logging setup
✅ Code Quality: Ruff, Black, isort, mypy

You Now Have:
- A production-ready foundation
- Clean, maintainable code
- Professional development practices
```

**Next: Part 2 - Routing, Requests & Templating**

---

# PART 2: ROUTING, REQUESTS & TEMPLATING
## Building the User Interface

### Slide 2.0: Part 2 Overview

**Routing, Requests & Jinja Templating**

**What You'll Learn:**
- URL routing with dynamic variables
- Request object handling
- Custom URL converters
- Jinja template inheritance
- Form handling with Flask-WTF
- Error handling and flash messages

**What You'll Build:**
- Complete page structure
- Dynamic routes with parameters
- Form validation and handling
- Custom error pages
- Flash messaging system

---

### Slide 2.1: URL Routing Fundamentals

**How Flask Maps URLs to Functions:**

```python
# Basic Routes
@app.route('/')
def home(): ...

# Dynamic Routes
@app.route('/user/<username>')
def profile(username): ...

# Type Converters
@app.route('/user/<int:user_id>')
def get_user(user_id): ...

# Multiple Routes
@app.route('/')
@app.route('/index')
def index(): ...

# HTTP Methods
@app.route('/task', methods=['GET', 'POST'])
def handle_task():
    if request.method == 'GET':
        return show_task()
    return create_task()
```

**Analogy: The URL is like a street address, Flask is the mail carrier delivering mail to the right house (function)!**

---

### Slide 2.2: URL Converters

**Built-in and Custom Converters:**

**Built-in Converters:**
```
string   → /user/john          → 'john'
int      → /user/123           → 123
float    → /product/19.99      → 19.99
path     → /files/dir/file.txt → 'dir/file.txt'
uuid     → /user/uuid123       → UUID object
```

**Custom Converter Example:**
```python
class UUIDConverter(BaseConverter):
    regex = r'[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}'
    
    def to_python(self, value):
        return UUID(value)
    
    def to_url(self, value):
        return str(value)

app.url_map.converters['uuid'] = UUIDConverter

# Usage
@app.route('/user/<uuid:user_id>')
def get_user(user_id):
    # user_id is already a UUID object
    return User.query.get(user_id)
```

---

### Slide 2.3: The Request Object

**Accessing All Request Data:**

```python
from flask import request

# URL Parameters (GET)
# /search?q=flask&page=2
query = request.args.get('q')
page = request.args.get('page', 1, type=int)

# Form Data (POST)
username = request.form.get('username')
password = request.form.get('password')

# JSON Data (API)
data = request.get_json()
title = data.get('title')

# Headers
user_agent = request.headers.get('User-Agent')
content_type = request.headers.get('Content-Type')

# Files
file = request.files.get('file')

# Cookies
session_id = request.cookies.get('session_id')

# Full URL
full_url = request.url
path = request.path
```

**Analogy: The request is like a package with many compartments - each compartment has different information!**

---

### Slide 2.4: Jinja Templating Engine

**Template Inheritance - The Power of Jinja:**

```
┌─────────────────────────────────────────────────────────────┐
│                    base.html                                 │
│  <!DOCTYPE html>                                            │
│  <html>                                                     │
│  <head>                                                     │
│      <title>{% block title %}Site{% endblock %}</title>     │
│  </head>                                                    │
│  <body>                                                     │
│      <nav>Navigation</nav>                                  │
│      {% block content %}{% endblock %}                     │
│      <footer>Footer</footer>                                │
│  </body>                                                    │
│  </html>                                                    │
└─────────────────────┬───────────────────────────────────────┘
                      │
          ┌───────────┼───────────┐
          ▼           ▼           ▼
┌─────────────┐ ┌─────────────┐ ┌─────────────┐
│  home.html  │ │ about.html  │ │  task.html  │
│ {extends}   │ │ {extends}   │ │  {extends}  │
│ {block      │ │ {block      │ │ {block      │
│  title}     │ │  title}     │ │  content}   │
│  Home       │ │  About      │ │  Task       │
└─────────────┘ └─────────────┘ └─────────────┘
```

**Analogy: Like a magazine layout - same header/footer, different content in the middle!**

---

### Slide 2.5: Jinja Syntax Reference

**Core Template Features:**

```html
{# Variables - Display data #}
<h1>{{ title }}</h1>
<p>{{ user.name }}</p>

{# Conditions - Control flow #}
{% if user.is_admin %}
    <a href="/admin">Admin Panel</a>
{% elif user.is_manager %}
    <a href="/team">Team Dashboard</a>
{% else %}
    <a href="/tasks">My Tasks</a>
{% endif %}

{# Loops - Iterate collections #}
<ul>
{% for task in tasks %}
    <li>{{ task.title }}</li>
{% endfor %}
</ul>

{# Filters - Transform data #}
<p>{{ text|truncate(100) }}</p>
<p>{{ date|datetime('%Y-%m-%d') }}</p>
<p>{{ html|safe }}</p>

{# Comments - Not rendered #}
{# This is a comment, not shown to users #}
```

---

### Slide 2.6: Forms with Flask-WTF

**Why Flask-WTF?**

```
Manual Form Handling:
❌ No CSRF protection
❌ No validation
❌ Repetitive code
❌ Security risks

Flask-WTF:
✅ Automatic CSRF protection
✅ Built-in validators
✅ Clean declarative syntax
✅ Secure by default
```

**Example Form Definition:**

```python
from flask_wtf import FlaskForm
from wtforms import StringField, PasswordField, SubmitField
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

---

### Slide 2.7: Form Handling in Routes

**Complete Form Flow:**

```python
@app.route('/register', methods=['GET', 'POST'])
def register():
    form = RegistrationForm()
    
    # GET request: Show empty form
    if request.method == 'GET':
        return render_template('register.html', form=form)
    
    # POST request: Process form
    if form.validate_on_submit():
        # Form is valid!
        user = User(
            username=form.username.data,
            email=form.email.data
        )
        user.set_password(form.password.data)
        db.session.add(user)
        db.session.commit()
        
        flash('Registration successful!', 'success')
        return redirect(url_for('auth.login'))
    
    # Form is invalid: Show with errors
    return render_template('register.html', form=form)
```

**Template Rendering:**
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
    
    {{ form.submit(class="btn btn-primary") }}
</form>
```

---

### Slide 2.8: Flash Messages

**User Feedback Made Easy:**

```python
from flask import flash

# In routes
@app.route('/login', methods=['POST'])
def login():
    if login_success:
        flash('Welcome back!', 'success')
        return redirect(url_for('dashboard'))
    else:
        flash('Invalid credentials', 'danger')
        return render_template('login.html')

# Categories for styling
flash('Success message', 'success')    # Green
flash('Error message', 'danger')       # Red
flash('Warning message', 'warning')    # Yellow
flash('Info message', 'info')          # Blue
```

**Template Display:**
```html
{% with messages = get_flashed_messages(with_categories=true) %}
    {% if messages %}
        {% for category, message in messages %}
            <div class="alert alert-{{ category }} alert-dismissible">
                {{ message }}
                <button type="button" class="btn-close" data-dismiss="alert"></button>
            </div>
        {% endfor %}
    {% endif %}
{% endwith %}
```

**Analogy: Like a notification system - different colors for different messages!**

---

### Slide 2.9: Error Handling

**Custom Error Pages:**

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

# 404 Template
{% extends "base.html" %}
{% block content %}
<div class="text-center">
    <h1 class="display-1">404</h1>
    <h2>Page Not Found</h2>
    <p>The page you're looking for doesn't exist.</p>
    <a href="{{ url_for('main.index') }}" class="btn btn-primary">
        Return Home
    </a>
</div>
{% endblock %}
```

---

### Slide 2.10: Part 2 Summary

**What You've Learned:**

```
✅ URL Routing: Dynamic routes with type converters
✅ Request Handling: Accessing all request data
✅ Template System: Inheritance and reusable components
✅ Form Handling: Flask-WTF with CSRF protection
✅ Flash Messages: User feedback with categories
✅ Error Handling: Custom error pages

You Can Now:
- Build dynamic web pages
- Handle user input securely
- Display data beautifully
- Guide users with feedback
```

**Next: Part 3 - Databases, ORM & Data Modeling**

---

# PART 3: DATABASES, ORM & DATA MODELING
## Building the Data Layer

### Slide 3.0: Part 3 Overview

**Databases, ORM & Data Modeling**

**What You'll Learn:**
- SQLAlchemy 2.x ORM architecture
- Database models and relationships
- CRUD operations
- Advanced querying techniques
- Alembic migrations
- Performance optimization

**What You'll Build:**
- Complete database models for TaskFlow
- One-to-many and many-to-many relationships
- Migration system
- Repository pattern for data access

---

### Slide 3.1: SQLAlchemy ORM Architecture

**Understanding the ORM:**

```
┌─────────────────────────────────────────────────────────────┐
│                    Application Code                         │
│                  (Python Objects)                           │
└─────────────────────┬───────────────────────────────────────┘
                      │
┌─────────────────────▼───────────────────────────────────────┐
│                   SQLAlchemy ORM                           │
│  - Maps Python classes to tables                          │
│  - Manages relationships                                  │
│  - Tracks changes                                         │
└─────────────────────┬───────────────────────────────────────┘
                      │
┌─────────────────────▼───────────────────────────────────────┐
│                  SQLAlchemy Core                           │
│  - SQL expression language                                 │
│  - Connection pooling                                      │
│  - Dialect system                                          │
└─────────────────────┬───────────────────────────────────────┘
                      │
┌─────────────────────▼───────────────────────────────────────┐
│                 Database Driver                            │
│              (psycopg2, sqlite3)                           │
└─────────────────────┬───────────────────────────────────────┘
                      │
┌─────────────────────▼───────────────────────────────────────┐
│                   Database                                 │
│            (PostgreSQL/MySQL/SQLite)                       │
└─────────────────────────────────────────────────────────────┘
```

**Analogy: SQLAlchemy is like a translator between Python and SQL!**

---

### Slide 3.2: Defining Models

**Python to Database Mapping:**

```python
from app.extensions import db

class User(db.Model):
    __tablename__ = 'users'
    
    # Columns → Database Fields
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(50), unique=True, nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=False)
    password_hash = db.Column(db.String(128), nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    # Relationships → Connections to other tables
    tasks = db.relationship('Task', back_populates='user')

class Task(db.Model):
    __tablename__ = 'tasks'
    
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(200), nullable=False)
    status = db.Column(db.String(20), default='pending')
    
    # Foreign Key → Links to User
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'))
    
    # Relationship → Access from both sides
    user = db.relationship('User', back_populates='tasks')
```

**Column Types Reference:**
```
Integer      → Whole numbers
String(50)   → Limited text
Text         → Unlimited text
Boolean      → True/False
DateTime     → Date and time
Float        → Decimal numbers
JSON         → JSON data
```

---

### Slide 3.3: Relationships

**One-to-Many Relationship:**

```
┌─────────────┐     ┌─────────────┐
│    User     │     │    Task     │
├─────────────┤     ├─────────────┤
│ id (PK)     │───>│ id (PK)     │
│ username    │     │ title       │
│ email       │     │ user_id (FK)│
└─────────────┘     └─────────────┘

One User → Many Tasks
Many Tasks → One User
```

**Implementation:**
```python
class User(db.Model):
    tasks = db.relationship('Task', back_populates='user')

class Task(db.Model):
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'))
    user = db.relationship('User', back_populates='tasks')

# Usage
user = User.query.get(1)
tasks = user.tasks  # All tasks for this user

task = Task.query.get(1)
user = task.user   # User who owns this task
```

---

### Slide 3.4: Many-to-Many Relationship

**Implementation with Association Table:**

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│    Task     │     │ task_tags   │     │    Tag      │
├─────────────┤     ├─────────────┤     ├─────────────┤
│ id (PK)     │───>│ task_id (FK)│     │ id (PK)     │
│ title       │     │ tag_id (FK) │<────│ name        │
└─────────────┘     └─────────────┘     └─────────────┘

Task ←→ Tag (Many-to-Many)
```

**Code:**
```python
task_tags = db.Table('task_tags',
    db.Column('task_id', db.Integer, db.ForeignKey('tasks.id')),
    db.Column('tag_id', db.Integer, db.ForeignKey('tags.id'))
)

class Task(db.Model):
    tags = db.relationship('Tag', secondary=task_tags, back_populates='tasks')

class Tag(db.Model):
    tasks = db.relationship('Task', secondary=task_tags, back_populates='tags')

# Usage
task = Task.query.get(1)
task.tags.append(tag)
db.session.commit()
```

---

### Slide 3.5: CRUD Operations

**Create, Read, Update, Delete:**

```python
# CREATE - Add new records
user = User(username='john', email='john@example.com')
user.set_password('password123')
db.session.add(user)
db.session.commit()

# READ - Retrieve records
user = User.query.get(1)                        # By ID
users = User.query.filter_by(is_active=True).all()  # Filter
users = User.query.order_by(User.created_at.desc()).all()  # Sort
count = User.query.count()                     # Count

# UPDATE - Modify records
user = User.query.get(1)
user.username = 'newusername'
user.last_login = datetime.utcnow()
db.session.commit()

# DELETE - Remove records
user = User.query.get(1)
db.session.delete(user)
db.session.commit()
```

**Analogy: CRUD is like a filing cabinet - Create files, Read files, Update files, Delete files!**

---

### Slide 3.6: Advanced Querying

**Powerful SQLAlchemy Queries:**

```python
from sqlalchemy import or_, and_, func, desc

# Complex Filters
tasks = Task.query.filter(
    or_(
        Task.status == 'pending',
        Task.priority == 'high'
    ),
    Task.due_date > datetime.utcnow()
).all()

# Aggregations
task_count = db.session.query(
    Task.status,
    func.count(Task.id).label('count')
).group_by(Task.status).all()

# Joins
tasks = db.session.query(Task).join(User).filter(
    User.username == 'john'
).all()

# Subqueries
subquery = db.session.query(Task.user_id).filter(
    Task.status == 'completed'
).subquery()
users = User.query.filter(User.id.in_(subquery)).all()
```

**Performance Tip: Use EXPLAIN to analyze queries!**

---

### Slide 3.7: Database Migrations

**Managing Schema Changes with Alembic:**

```bash
# Initialize migrations (first time)
flask db init

# Generate migration from model changes
flask db migrate -m "Add phone number to users"

# Apply migrations
flask db upgrade

# Rollback
flask db downgrade -1
```

**Migration File Example:**
```python
def upgrade():
    op.add_column('users', sa.Column('phone', sa.String(20)))
    op.add_column('users', sa.Column('is_active', sa.Boolean, server_default='true'))

def downgrade():
    op.drop_column('users', 'is_active')
    op.drop_column('users', 'phone')
```

**Best Practices:**
- Always backup before migrations
- Test migrations on staging first
- Use batch mode for large tables
- Include both upgrade and downgrade

---

### Slide 3.8: Repository Pattern

**Clean Data Access Layer:**

```python
class TaskRepository:
    """Data access layer for tasks."""
    
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
    def create(task_data):
        task = Task(**task_data)
        db.session.add(task)
        db.session.commit()
        return task
    
    @staticmethod
    def update(task, data):
        for key, value in data.items():
            setattr(task, key, value)
        db.session.commit()
        return task

class TaskService:
    """Business logic layer."""
    
    @staticmethod
    def get_user_tasks(user, filters=None):
        return TaskRepository.get_user_tasks(user.id, filters)
    
    @staticmethod
    def create_task(user, data):
        data['user_id'] = user.id
        return TaskRepository.create(data)
```

**Benefits:**
- Separates business logic from data access
- Makes testing easier
- Provides a clean API
- Easy to swap implementations

---

### Slide 3.9: Performance Optimization

**Common Performance Issues & Solutions:**

```
┌─────────────────────────────────────────────────────────────┐
│  Performance Problem: N+1 Queries                          │
├─────────────────────────────────────────────────────────────┤
│  ❌ Bad:                                                   │
│  tasks = Task.query.all()                                 │
│  for task in tasks:                                       │
│      print(task.user.name)   # N+1 queries!              │
│                                                             │
│  ✅ Good:                                                  │
│  tasks = Task.query.options(joinedload(Task.user)).all()  │
│  for task in tasks:                                       │
│      print(task.user.name)   # No extra queries           │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│  Performance Problem: No Indexing                          │
├─────────────────────────────────────────────────────────────┤
│  ❌ Bad: No index on status                               │
│  Task.query.filter_by(status='pending').all()             │
│                                                             │
│  ✅ Good: Add index                                        │
│  status = db.Column(db.String(20), index=True)             │
└─────────────────────────────────────────────────────────────┘
```

---

### Slide 3.10: Part 3 Summary

**What You've Learned:**

```
✅ SQLAlchemy ORM: Pythonic database access
✅ Models: Table definitions with relationships
✅ CRUD: Create, Read, Update, Delete operations
✅ Queries: Filtering, sorting, joins, aggregation
✅ Migrations: Alembic schema version control
✅ Repository Pattern: Clean data access

You Can Now:
- Design database schemas
- Write complex queries
- Manage schema changes
- Optimize database performance
```

**Next: Part 4 - Authentication, Authorization & Security**

---

# PART 4: AUTHENTICATION, AUTHORIZATION & SECURITY
## Protecting Your Application

### Slide 4.0: Part 4 Overview

**Authentication, Authorization & Security**

**What You'll Learn:**
- User registration, login, logout
- Password hashing and security
- Flask-Login session management
- Role-based access control (RBAC)
- CSRF protection
- Security headers and HTTPS

**What You'll Build:**
- Complete authentication system
- Role-based permissions
- Profile management
- Secure session handling

---

### Slide 4.1: Authentication vs Authorization

**Two Different Concepts:**

```
┌─────────────────────────────────────────────────────────────┐
│                 Authentication                              │
│              "Who are you?"                                 │
├─────────────────────────────────────────────────────────────┤
│  Process: Logging in                                       │
│  Verifies identity                                         │
│  Examples:                                                 │
│  - Login with email/password                               │
│  - Fingerprint scan                                        │
│  - Security badge                                          │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                 Authorization                               │
│              "What can you do?"                             │
├─────────────────────────────────────────────────────────────┤
│  Process: Checking permissions                             │
│  Verifies access rights                                    │
│  Examples:                                                 │
│  - View tasks only                                         │
│  - Delete any task                                         │
│  - Admin dashboard                                         │
└─────────────────────────────────────────────────────────────┘

Analogy: Authentication = ID card, Authorization = Security clearance
```

---

### Slide 4.2: Flask-Login Setup

**Flask-Login Architecture:**

```python
from flask_login import LoginManager, UserMixin

# 1. Initialize LoginManager
login_manager = LoginManager()
login_manager.init_app(app)

# 2. Configure
login_manager.login_view = 'auth.login'
login_manager.login_message = 'Please log in to access this page.'

# 3. User Loader
@login_manager.user_loader
def load_user(user_id):
    return User.query.get(int(user_id))

# 4. User Model (with UserMixin)
class User(db.Model, UserMixin):
    # UserMixin provides:
    # - is_authenticated
    # - is_active
    # - is_anonymous
    # - get_id()
    
    id = db.Column(db.Integer, primary_key=True)
    # ... other fields
```

**Analogy: LoginManager is like a security guard at the entrance!**

---

### Slide 4.3: Password Security

**Hashing vs Encryption:**

```
┌─────────────────────────────────────────────────────────────┐
│                   Password Storage                          │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ❌ PLAIN TEXT (NEVER!)                                    │
│  password = 'mypassword123'                                │
│  → If database is compromised, all passwords are exposed   │
│                                                             │
│  ❌ MD5/SHA1 (WEAK)                                        │
│  hash = md5('mypassword123')                               │
│  → Crackable with rainbow tables                           │
│                                                             │
│  ✅ BCrypt/SHA256 with Salt (STRONG)                       │
│  hash = generate_password_hash('mypassword123')            │
│  → Secure, salted, computationally expensive              │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Implementation:**
```python
from werkzeug.security import generate_password_hash, check_password_hash

class User(db.Model):
    password_hash = db.Column(db.String(128))
    
    def set_password(self, password):
        self.password_hash = generate_password_hash(password)
    
    def check_password(self, password):
        return check_password_hash(self.password_hash, password)

# Usage
user = User()
user.set_password('secure_password')
# password_hash is now hashed, not plain text

# Verification
if user.check_password(input_password):
    login_user(user)
```

---

### Slide 4.4: Registration Flow

**Complete Registration Process:**

```
1. User visits /register (GET)
   ↓
2. Form displayed
   ↓
3. User submits data (POST)
   ↓
4. Validate input
   - Username available?
   - Email valid?
   - Password strong?
   ↓
5. Create user
   - Hash password
   - Set default role
   ↓
6. Save to database
   ↓
7. Send welcome email (async)
   ↓
8. Redirect to login
```

**Implementation:**
```python
@app.route('/register', methods=['GET', 'POST'])
def register():
    form = RegistrationForm()
    
    if form.validate_on_submit():
        # Check if username exists
        if User.query.filter_by(username=form.username.data).first():
            flash('Username taken', 'danger')
            return render_template('register.html', form=form)
        
        # Create user
        user = User(
            username=form.username.data,
            email=form.email.data
        )
        user.set_password(form.password.data)
        
        db.session.add(user)
        db.session.commit()
        
        flash('Registration successful!', 'success')
        return redirect(url_for('auth.login'))
    
    return render_template('register.html', form=form)
```

---

### Slide 4.5: Login Flow

**Login Process:**

```python
@app.route('/login', methods=['GET', 'POST'])
def login():
    form = LoginForm()
    
    if form.validate_on_submit():
        # Find user by email
        user = User.query.filter_by(email=form.email.data).first()
        
        # Check credentials
        if user and user.check_password(form.password.data):
            # Log in
            login_user(user, remember=form.remember.data)
            
            # Update last login
            user.last_login = datetime.utcnow()
            db.session.commit()
            
            # Redirect to next page or dashboard
            next_page = request.args.get('next')
            return redirect(next_page or url_for('main.index'))
        
        flash('Invalid email or password', 'danger')
    
    return render_template('auth/login.html', form=form)

@app.route('/logout')
@login_required
def logout():
    logout_user()
    flash('You have been logged out.', 'info')
    return redirect(url_for('main.index'))
```

**Remember Me:**
- `remember=True` creates a long-lasting cookie
- Secure, encrypted, and http-only
- Can be configured with `REMEMBER_COOKIE_DURATION`

---

### Slide 4.6: Protecting Routes

**Multiple Levels of Protection:**

```python
# 1. Basic Login Required
@app.route('/dashboard')
@login_required
def dashboard():
    return render_template('dashboard.html')

# 2. Role-Based Protection
def admin_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        if not current_user.is_authenticated:
            return redirect(url_for('auth.login'))
        if not current_user.is_admin:
            abort(403)
        return f(*args, **kwargs)
    return decorated

@app.route('/admin')
@admin_required
def admin_panel():
    return render_template('admin.html')

# 3. Permission-Based Protection
def permission_required(permission):
    def decorator(f):
        @wraps(f)
        def decorated(*args, **kwargs):
            if not current_user.has_permission(permission):
                abort(403)
            return f(*args, **kwargs)
        return decorated
    return decorator

@app.route('/tasks/create')
@permission_required('create_task')
def create_task():
    return render_template('tasks/create.html')
```

---

### Slide 4.7: Role-Based Access Control (RBAC)

**User Roles System:**

```python
class UserRole(str, Enum):
    USER = 'user'
    MANAGER = 'manager'
    ADMIN = 'admin'

class User(db.Model):
    role = db.Column(db.Enum(UserRole), default=UserRole.USER)
    
    @property
    def is_admin(self):
        return self.role == UserRole.ADMIN
    
    @property
    def is_manager(self):
        return self.role in [UserRole.MANAGER, UserRole.ADMIN]
    
    def has_permission(self, permission):
        if self.role == UserRole.ADMIN:
            return True
        
        permissions = {
            UserRole.USER: ['view_tasks', 'create_task'],
            UserRole.MANAGER: ['view_tasks', 'create_task', 'assign_tasks', 'view_reports'],
        }
        return permission in permissions.get(self.role, [])
```

**Permission Matrix:**
```
┌─────────────┬──────────┬──────────┬──────────┐
│ Permission  │  User    │ Manager  │  Admin   │
├─────────────┼──────────┼──────────┼──────────┤
│ View Tasks  │    ✅     │    ✅     │    ✅     │
│ Create Task │    ✅     │    ✅     │    ✅     │
│ Assign Task │    ❌     │    ✅     │    ✅     │
│ View Reports│    ❌     │    ✅     │    ✅     │
│ Manage Users│    ❌     │    ❌     │    ✅     │
└─────────────┴──────────┴──────────┴──────────┘
```

---

### Slide 4.8: CSRF Protection

**Cross-Site Request Forgery Protection:**

```
Without CSRF Protection:
┌────────────┐     ┌────────────┐
│  Attacker  │────>│  Victim's  │
│   Website  │     │   Bank     │
└────────────┘     └────────────┘
      │                  │
      │  Tells browser   │
      │  to transfer     │
      └───> money ───────┘

With CSRF Protection:
┌────────────┐     ┌────────────┐
│  Attacker  │────>│  Victim's  │
│   Website  │     │   Bank     │
└────────────┘     └────────────┘
      │                  │
      │  Tells browser   │
      │  to transfer     │
      └───> money ───────┘
           ❌ Invalid CSRF token!
```

**Implementation:**
```python
from flask_wtf.csrf import CSRFProtect

csrf = CSRFProtect(app)

# In forms (automatic)
<form method="POST">
    {{ form.csrf_token }}
    <!-- form fields -->
</form>

# In AJAX requests
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

---

### Slide 4.9: Security Headers

**Protecting Against Common Attacks:**

```python
@app.after_request
def add_security_headers(response):
    # HTTPS Enforcement (HSTS)
    response.headers['Strict-Transport-Security'] = \
        'max-age=31536000; includeSubDomains; preload'
    
    # Prevent Clickjacking
    response.headers['X-Frame-Options'] = 'SAMEORIGIN'
    
    # Prevent MIME Sniffing
    response.headers['X-Content-Type-Options'] = 'nosniff'
    
    # XSS Protection
    response.headers['X-XSS-Protection'] = '1; mode=block'
    
    # Referrer Policy
    response.headers['Referrer-Policy'] = 'strict-origin-when-cross-origin'
    
    # Content Security Policy
    response.headers['Content-Security-Policy'] = (
        "default-src 'self'; "
        "script-src 'self' https://cdn.jsdelivr.net; "
        "style-src 'self' https://cdn.jsdelivr.net; "
        "img-src 'self' data: https:"
    )
    
    return response
```

**Security Headers Explained:**
```
HSTS: Forces HTTPS
X-Frame-Options: Prevents clickjacking
X-Content-Type-Options: Stops MIME sniffing
X-XSS-Protection: Legacy XSS protection
Referrer-Policy: Controls referrer info
CSP: Prevents XSS and data injection
```

---

### Slide 4.10: Part 4 Summary

**What You've Learned:**

```
✅ Authentication: Registration, login, logout
✅ Password Security: Hashing with Werkzeug
✅ Session Management: Flask-Login
✅ RBAC: Role-based permissions
✅ CSRF Protection: Flask-WTF
✅ Security Headers: Multiple layers of protection

You Can Now:
- Build secure authentication systems
- Implement role-based access control
- Protect against common attacks
- Create professional security features
```

**Next: Part 5 - Building RESTful APIs**

---

# PART 5: BUILDING RESTFUL APIS
## Creating Programmable Interfaces

### Slide 5.0: Part 5 Overview

**Building RESTful APIs with Flask**

**What You'll Learn:**
- REST API design principles
- Resource modeling and URL structure
- HTTP methods and status codes
- JSON serialization with Marshmallow
- API authentication and security
- API documentation with Swagger

**What You'll Build:**
- Complete REST API for TaskFlow
- Versioned API endpoints
- Token-based authentication
- API documentation
- Rate limiting

---

### Slide 5.1: REST API Principles

**REST in a Nutshell:**

```
REST = Representational State Transfer

Key Principles:

1. Resources (Nouns)
   ✅ /users, /tasks, /categories
   ❌ /getUsers, /createTask

2. HTTP Methods (Verbs)
   GET    → Read
   POST   → Create
   PUT    → Replace
   PATCH  → Update
   DELETE → Delete

3. Stateless
   - Each request has all info needed
   - No session state on server

4. JSON (Standard Format)
   - Lightweight
   - Language-agnostic
   - Easy to parse
```

**Analogy: REST API is like a restaurant menu!**

---

### Slide 5.2: Resource Design

**Designing RESTful URLs:**

```
┌─────────────────────────────────────────────────────────────┐
│                    Resource Design                          │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Collection:  GET    /tasks                                │
│  Create:      POST   /tasks                                │
│  Individual:  GET    /tasks/{id}                           │
│  Update:      PUT    /tasks/{id}                           │
│  Delete:      DELETE /tasks/{id}                          │
│                                                             │
│  Nested:      GET    /users/{id}/tasks                    │
│  Filtering:   GET    /tasks?status=pending                │
│  Sorting:     GET    /tasks?sort=created_at&order=desc    │
│  Pagination:  GET    /tasks?page=2&per_page=20            │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Best Practices:**
```
✅ Use plural nouns: /tasks, /users
✅ Use hyphens: /user-profiles
✅ Be consistent: always use same patterns
✅ Keep it simple: avoid deep nesting
✅ Use query params for filtering, not URL path
```

---

### Slide 5.3: HTTP Methods & Status Codes

**Methods Reference:**

```
GET    → Read data          (Safe, Cacheable)
POST   → Create data        (Not safe, Not cacheable)
PUT    → Full update        (Idempotent)
PATCH  → Partial update     (Not idempotent)
DELETE → Delete data        (Idempotent)
```

**Status Codes Reference:**

```
2xx Success
200 OK                   ✓ Everything worked
201 Created              ✓ Resource created
204 No Content           ✓ Success, no body

3xx Redirection
301 Moved Permanently    → Resource moved
304 Not Modified         → Cache hit

4xx Client Errors
400 Bad Request          ❌ Invalid request
401 Unauthorized         ❌ Not logged in
403 Forbidden            ❌ Not authorized
404 Not Found            ❌ Resource doesn't exist
422 Unprocessable        ❌ Validation failed
429 Too Many Requests    ❌ Rate limited

5xx Server Errors
500 Internal Error       💥 Server error
503 Service Unavailable  💥 Server overloaded
```

---

### Slide 5.4: JSON Serialization with Marshmallow

**Serialization vs Deserialization:**

```python
from marshmallow import Schema, fields

class TaskSchema(Schema):
    """Serialization schema for tasks."""
    id = fields.Int(dump_only=True)
    title = fields.Str(required=True)
    description = fields.Str(allow_none=True)
    status = fields.Str()
    priority = fields.Str()
    created_at = fields.DateTime(dump_only=True)
    user_id = fields.Int()
    
    # Nested relationships
    user = fields.Nested('UserSchema', dump_only=True, only=('id', 'username'))

# Serialize (Model → JSON)
task = Task.query.get(1)
schema = TaskSchema()
json_data = schema.dump(task)  # Returns dict

# Deserialize (JSON → Model)
json_data = {'title': 'New Task', 'user_id': 1}
schema = TaskSchema()
validated_data = schema.load(json_data)  # Returns dict

# With validation
try:
    validated = TaskSchema().load(json_data)
except ValidationError as err:
    return {'errors': err.messages}, 400
```

**Analogy: Marshmallow is like a translator between Python and JSON!**

---

### Slide 5.5: API Endpoints Implementation

**Complete CRUD API:**

```python
from flask import Blueprint, request, jsonify
from app.models.task import Task
from app.schemas.task_schema import TaskSchema

api_bp = Blueprint('api', __name__, url_prefix='/api')

@api_bp.route('/tasks', methods=['GET'])
def list_tasks():
    tasks = Task.query.all()
    schema = TaskSchema(many=True)
    return jsonify(schema.dump(tasks))

@api_bp.route('/tasks/<int:task_id>', methods=['GET'])
def get_task(task_id):
    task = Task.query.get_or_404(task_id)
    schema = TaskSchema()
    return jsonify(schema.dump(task))

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

@api_bp.route('/tasks/<int:task_id>', methods=['DELETE'])
def delete_task(task_id):
    task = Task.query.get_or_404(task_id)
    db.session.delete(task)
    db.session.commit()
    return '', 204
```

---

### Slide 5.6: API Authentication

**Token-Based Authentication:**

```python
import jwt
from functools import wraps
from flask import request, jsonify, g

SECRET_KEY = os.environ.get('JWT_SECRET_KEY')

def generate_token(user_id):
    payload = {
        'user_id': user_id,
        'exp': datetime.utcnow() + timedelta(hours=1)
    }
    return jwt.encode(payload, SECRET_KEY, algorithm='HS256')

def token_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        auth_header = request.headers.get('Authorization')
        
        if not auth_header or not auth_header.startswith('Bearer '):
            return jsonify({'error': 'Token required'}), 401
        
        token = auth_header[7:]  # Remove 'Bearer '
        
        try:
            payload = jwt.decode(token, SECRET_KEY, algorithms=['HS256'])
            g.user_id = payload['user_id']
        except jwt.ExpiredSignatureError:
            return jsonify({'error': 'Token expired'}), 401
        except jwt.InvalidTokenError:
            return jsonify({'error': 'Invalid token'}), 401
        
        return f(*args, **kwargs)
    return decorated

@app.route('/api/login', methods=['POST'])
def api_login():
    data = request.get_json()
    user = User.query.filter_by(email=data['email']).first()
    
    if not user or not user.check_password(data['password']):
        return jsonify({'error': 'Invalid credentials'}), 401
    
    token = generate_token(user.id)
    return jsonify({'token': token})

@app.route('/api/tasks')
@token_required
def api_get_tasks():
    tasks = Task.query.filter_by(user_id=g.user_id).all()
    schema = TaskSchema(many=True)
    return jsonify(schema.dump(tasks))
```

---

### Slide 5.7: Rate Limiting

**Protecting Against Abuse:**

```python
from flask_limiter import Limiter
from flask_limiter.util import get_remote_address

limiter = Limiter(
    app=app,
    key_func=get_remote_address,
    default_limits=["200 per day", "50 per hour"]
)

@app.route('/api/tasks', methods=['GET'])
@limiter.limit("100 per minute")
def list_tasks():
    # 100 requests per minute per IP
    return jsonify(tasks)

@app.route('/api/tasks', methods=['POST'])
@limiter.limit("30 per minute")
def create_task():
    # Stricter limit for write operations
    return jsonify(task), 201

@app.route('/api/login', methods=['POST'])
@limiter.limit("5 per minute", error_message="Too many login attempts")
def login():
    # Very strict for auth endpoints
    return jsonify(token)

# User-based rate limiting
def get_user_key():
    if current_user.is_authenticated:
        return f"user:{current_user.id}"
    return get_remote_address()

@app.route('/api/user-data')
@limiter.limit("60 per minute", key_func=get_user_key)
def user_data():
    return jsonify(data)
```

---

### Slide 5.8: API Versioning

**Managing API Changes:**

```python
# URL Versioning (Recommended)
v1_bp = Blueprint('api_v1', __name__, url_prefix='/api/v1')
v2_bp = Blueprint('api_v2', __name__, url_prefix='/api/v2')

@v1_bp.route('/tasks')
def v1_tasks():
    tasks = Task.query.all()
    return jsonify([{
        'id': t.id,
        'title': t.title,
        'status': t.status
    } for t in tasks])

@v2_bp.route('/tasks')
def v2_tasks():
    tasks = Task.query.all()
    return jsonify([{
        'id': t.id,
        'title': t.title,
        'description': t.description,
        'status': t.status,
        'priority': t.priority
    } for t in tasks])

# Register both versions
app.register_blueprint(v1_bp)
app.register_blueprint(v2_bp)

# Version Strategy:
# v1: Basic task info
# v2: Additional fields
# v3: Completely different format (if needed)
```

**Versioning Strategies:**
```
1. URL: /api/v1/tasks      ← Simple, clear
2. Header: API-Version: 1.0 ← Clean URLs
3. Query: ?version=1.0    ← Easy to test
4. Content Negotiation    ← RESTful but complex
```

---

### Slide 5.9: API Documentation with Swagger

**Interactive Documentation:**

```python
from flask_swagger_ui import get_swaggerui_blueprint
from apispec import APISpec
from apispec.ext.marshmallow import MarshmallowPlugin

# OpenAPI Specification
spec = APISpec(
    title='TaskFlow API',
    version='1.0.0',
    openapi_version='3.0.2',
    plugins=[MarshmallowPlugin()]
)

# Define schemas
spec.components.schema('Task', {
    'type': 'object',
    'properties': {
        'id': {'type': 'integer'},
        'title': {'type': 'string'},
        'status': {'type': 'string', 'enum': ['pending', 'in_progress', 'completed']},
        'priority': {'type': 'string', 'enum': ['low', 'medium', 'high']}
    }
})

# Define endpoints
spec.path(
    path='/api/tasks',
    operations={
        'get': {
            'summary': 'List all tasks',
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

swagger_ui = get_swaggerui_blueprint(
    SWAGGER_URL,
    API_URL,
    config={'app_name': 'TaskFlow API'}
)
app.register_blueprint(swagger_ui, url_prefix=SWAGGER_URL)

@app.route('/api/docs/spec.json')
def swagger_spec():
    return jsonify(spec.to_dict())
```

---

### Slide 5.10: Part 5 Summary

**What You've Learned:**

```
✅ REST Principles: Resources, methods, stateless
✅ API Design: Proper URL structure and endpoints
✅ HTTP: Methods and status codes
✅ Serialization: Marshmallow for JSON
✅ Authentication: JWT tokens
✅ Rate Limiting: Protecting against abuse
✅ Versioning: Managing API changes
✅ Documentation: Swagger/OpenAPI

You Can Now:
- Design professional REST APIs
- Build secure, documented APIs
- Manage API versions
- Scale APIs with rate limiting
```

**Next: Part 6 - Async Programming & Background Processing**

---

# PART 6: ASYNC PROGRAMMING & BACKGROUND PROCESSING
## Building Responsive Applications

### Slide 6.0: Part 6 Overview

**Async Programming & Background Processing**

**What You'll Learn:**
- Asynchronous programming in Python
- Async view functions in Flask 3.x
- Celery for background tasks
- Redis as a message broker
- Scheduled tasks with Celery Beat

**What You'll Build:**
- Async API endpoints
- Background email delivery
- Scheduled reports
- File processing in the background

---

### Slide 6.1: Async vs Sync Programming

**Understanding the Difference:**

```
Synchronous (Blocking):
┌────────────┐     ┌────────────┐     ┌────────────┐
│  Request 1 │────>│  Database  │────>│  Response  │
└────────────┘     └────────────┘     └────────────┘
      │
      │ Wait...
      │
┌────────────┐     ┌────────────┐     ┌────────────┐
│  Request 2 │────>│  Database  │────>│  Response  │
└────────────┘     └────────────┘     └────────────┘

Asynchronous (Non-blocking):
┌────────────┐     ┌────────────┐
│  Request 1 │────>│  Database  │
└────────────┘     └────────────┘
      │                   │
      │                   │ Processing...
      ▼                   ▼
┌────────────┐     ┌────────────┐
│  Request 2 │────>│  Database  │
└────────────┘     └────────────┘
      │                   │
      │                   │ Done!
      ▼                   ▼
┌────────────┐     ┌────────────┐
│  Response  │<────│  Response  │
└────────────┘     └────────────┘
```

**Analogy: Sync = Waiting in line, Async = Ordering at multiple counters!**

---

### Slide 6.2: Flask 3.x Async Views

**Building Async Endpoints:**

```python
import asyncio
import httpx

@app.route('/api/async-example')
async def async_example():
    # Async code runs in event loop
    await asyncio.sleep(1)
    return jsonify({'message': 'Async response'})

@app.route('/api/external-data')
async def fetch_external():
    # Fetch multiple APIs concurrently
    async with httpx.AsyncClient() as client:
        tasks = [
            client.get('https://api1.example.com/data'),
            client.get('https://api2.example.com/data'),
            client.get('https://api3.example.com/data')
        ]
        results = await asyncio.gather(*tasks)
    
    return jsonify({
        'api1': results[0].json(),
        'api2': results[1].json(),
        'api3': results[2].json()
    })

@app.route('/api/async-search')
async def async_search():
    query = request.args.get('q')
    
    # Search multiple sources concurrently
    results = await asyncio.gather(
        search_database(query),
        search_elasticsearch(query),
        search_cache(query)
    )
    
    return jsonify({'results': results})

async def search_database(query):
    # Non-blocking database query
    await asyncio.sleep(0.1)  # Simulate DB query
    return {'source': 'database', 'results': [...]}
```

**Benefits:**
- Handles more concurrent requests
- Improved I/O performance
- Faster external API calls
- Better resource utilization

---

### Slide 6.3: Celery Setup

**Celery Architecture:**

```
┌─────────────────────────────────────────────────────────────┐
│                    Flask Application                        │
│                     (Producer)                              │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      │ Submits tasks
                      ▼
┌─────────────────────────────────────────────────────────────┐
│                    Redis (Broker)                           │
│                  Task Queue                                 │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      │ Tasks picked up
                      ▼
┌─────────────────────────────────────────────────────────────┐
│                  Celery Workers                             │
│               (Task Executors)                              │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      │ Results stored
                      ▼
┌─────────────────────────────────────────────────────────────┐
│                  Redis (Backend)                            │
│                  Task Results                               │
└─────────────────────────────────────────────────────────────┘
```

**Setup:**
```python
# celery_worker.py
from celery import Celery

celery = Celery(
    'taskflow',
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

# Start Celery Worker
# celery -A app.celery_worker.celery worker --loglevel=info
```

---

### Slide 6.4: Creating Tasks

**Defining Background Tasks:**

```python
from app.celery_worker import celery

@celery.task
def send_email(recipient, subject, body):
    """Send email asynchronously."""
    try:
        mail.send_message(subject, recipients=[recipient], body=body)
        return {'status': 'sent', 'recipient': recipient}
    except Exception as e:
        return {'status': 'failed', 'error': str(e)}

@celery.task(bind=True, max_retries=3)
def process_document(self, document_id):
    """Process a document with retry logic."""
    try:
        doc = Document.query.get(document_id)
        # Process document...
        return {'status': 'processed', 'id': document_id}
    except Exception as e:
        # Retry with exponential backoff
        self.retry(exc=e, countdown=60 * (2 ** self.request.retries))

@celery.task
def generate_report(user_id, report_type):
    """Generate a report in the background."""
    user = User.query.get(user_id)
    # Generate report...
    return {'status': 'complete', 'report_id': report_id}

@celery.task
def process_batch(items):
    """Process a batch of items."""
    results = []
    for item in items:
        result = process_item(item)
        results.append(result)
    return {'processed': len(results), 'results': results}
```

**Analogy: Tasks are like jobs in a to-do list for workers!**

---

### Slide 6.5: Using Tasks in Routes

**Integrating Background Processing:**

```python
from app.tasks.email import send_email
from app.tasks.reports import generate_report

@app.route('/register', methods=['POST'])
def register():
    # Create user...
    db.session.commit()
    
    # Send welcome email in background
    send_email.delay(
        recipient=user.email,
        subject='Welcome to TaskFlow!',
        body='Thank you for registering...'
    )
    
    flash('Registration successful! Check your email.', 'success')
    return redirect(url_for('auth.login'))

@app.route('/tasks/export')
@login_required
def export_tasks():
    # Start export task
    task = generate_report.delay(current_user.id, 'csv')
    
    return jsonify({
        'task_id': task.id,
        'status': 'started',
        'status_url': url_for('task_status', task_id=task.id)
    })

@app.route('/tasks/status/<task_id>')
@login_required
def task_status(task_id):
    from celery.result import AsyncResult
    
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
            'progress': result.info if result.info else 0
        })
```

---

### Slide 6.6: Scheduled Tasks (Celery Beat)

**Automated Tasks:**

```python
from celery.schedules import crontab

celery.conf.beat_schedule = {
    # Daily report at 8 AM
    'generate-daily-report': {
        'task': 'app.tasks.reports.generate_daily_report',
        'schedule': crontab(hour=8, minute=0),
        'kwargs': {'user_id': None}  # All users
    },
    
    # Weekly cleanup on Sunday at midnight
    'cleanup-old-tasks': {
        'task': 'app.tasks.cleanup.archive_old_tasks',
        'schedule': crontab(day_of_week=0, hour=0, minute=0),
        'args': (30,)  # Delete tasks older than 30 days
    },
    
    # Send weekly digest on Monday at 9 AM
    'weekly-digest': {
        'task': 'app.tasks.emails.send_weekly_digest',
        'schedule': crontab(day_of_week=1, hour=9, minute=0)
    },
    
    # Database backup every day at 2 AM
    'backup-database': {
        'task': 'app.tasks.backup.backup_database',
        'schedule': crontab(hour=2, minute=0)
    },
    
    # Health check every 5 minutes
    'health-check': {
        'task': 'app.tasks.monitoring.health_check',
        'schedule': crontab(minute='*/5')
    }
}
```

**Running Celery Beat:**
```bash
# Start Celery Beat (scheduler)
celery -A app.celery_worker.celery beat --loglevel=info

# Start both worker and beat
celery -A app.celery_worker.celery worker --beat --loglevel=info
```

---

### Slide 6.7: Task Monitoring with Flower

**Visual Celery Monitoring:**

```bash
# Install Flower
pip install flower

# Start Flower
celery -A app.celery_worker.celery flower --port=5555
```

**Flower Features:**
```
✅ Real-time task monitoring
✅ View task results
✅ Retry/revoke tasks
✅ Worker statistics
✅ Task history
✅ Broker monitoring
```

**Configuration:**
```python
# In celery_worker.py
celery.conf.update(
    # Enable Flower monitoring
    task_send_sent_event=True,
    worker_send_task_events=True
)

# Access Flower at: http://localhost:5555
```

---

### Slide 6.8: Common Background Tasks

**Real-World Use Cases:**

```
┌─────────────────────────────────────────────────────────────┐
│              Background Task Examples                       │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  📧 Email Notifications                                    │
│  - Welcome emails                                           │
│  - Password reset                                           │
│  - Weekly digests                                           │
│                                                             │
│  📊 Report Generation                                      │
│  - CSV exports                                              │
│  - PDF reports                                              │
│  - Analytics summaries                                      │
│                                                             │
│  🖼️ Image Processing                                       │
│  - Resize images                                            │
│  - Generate thumbnails                                      │
│  - Format conversion                                        │
│                                                             │
│  🗄️ Data Processing                                       │
│  - Database cleanup                                         │
│  - Data migration                                           │
│  - Batch updates                                            │
│                                                             │
│  🔄 External API Calls                                     │
│  - Webhooks                                                 │
│  - Third-party integration                                  │
│  - Data synchronization                                     │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

### Slide 6.9: Performance Considerations

**Async vs Celery:**

```
┌─────────────────────────────────────────────────────────────┐
│                    When to Use Each                         │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Use Async Views (Flask 3.x):                               │
│  ✅ Short I/O operations (< 1 second)                       │
│  ✅ External API calls                                      │
│  ✅ Multiple concurrent requests                            │
│  ❌ Long-running operations                                 │
│  ❌ CPU-intensive work                                     │
│                                                             │
│  Use Celery (Background Tasks):                             │
│  ✅ Long-running operations (> 1 second)                   │
│  ✅ CPU-intensive work                                     │
│  ✅ Email sending                                           │
│  ✅ Report generation                                       │
│  ✅ Scheduled tasks                                         │
│  ❌ Short, frequent operations                              │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Best Practices:**
1. Use async for I/O-bound operations
2. Use Celery for CPU-bound operations
3. Monitor task queue length
4. Set appropriate timeouts
5. Implement retry logic
6. Handle failures gracefully

---

### Slide 6.10: Part 6 Summary

**What You've Learned:**

```
✅ Async Views: Flask 3.x async support
✅ Celery: Background task processing
✅ Task Creation: Email, reports, processing
✅ Task Scheduling: Automated recurring tasks
✅ Monitoring: Flower for task tracking
✅ Use Cases: Real-world background jobs

You Can Now:
- Build responsive applications
- Process tasks in the background
- Schedule automated jobs
- Monitor task execution
```

**Next: Part 7 - Testing, Debugging & Quality Assurance**

---

# PART 7: TESTING, DEBUGGING & QUALITY ASSURANCE
## Ensuring Application Quality

### Slide 7.0: Part 7 Overview

**Testing, Debugging & Quality Assurance**

**What You'll Learn:**
- Unit testing with Pytest
- Integration testing
- Functional testing
- Test coverage
- Debugging techniques
- Code quality tools

**What You'll Build:**
- Complete test suite
- Factory fixtures
- Coverage reports
- CI/CD pipeline

---

### Slide 7.1: The Testing Pyramid

**Understanding Test Types:**

```
          ┌─────────────┐
          │   E2E Tests │   ← Few (slow, comprehensive)
         ┌┴─────────────┴┐
         │ Integration   │   ← Some (medium speed)
        ┌┴───────────────┴┐
        │   Unit Tests     │   ← Many (fast, focused)
        └──────────────────┘

Unit Tests: Test individual functions
Integration Tests: Test components together
End-to-End Tests: Test complete workflows

Testing Philosophy:
- Write more unit tests (cheap, fast)
- Write fewer integration tests (more expensive)
- Write even fewer E2E tests (most expensive)
```

**Analogy: Testing Pyramid is like building a house - strong foundation (unit tests) is essential!**

---

### Slide 7.2: Unit Testing with Pytest

**Writing Unit Tests:**

```python
# tests/test_models.py
import pytest
from app.models.user import User

class TestUserModel:
    def test_create_user(self, db_session):
        user = User(
            username='testuser',
            email='test@example.com'
        )
        user.set_password('password123')
        db_session.add(user)
        db_session.commit()
        
        assert user.id is not None
        assert user.username == 'testuser'
    
    def test_password_hashing(self, db_session):
        user = User(username='test')
        user.set_password('mypassword')
        
        assert user.password_hash != 'mypassword'
        assert user.check_password('mypassword') is True
        assert user.check_password('wrong') is False
    
    def test_username_required(self, db_session):
        with pytest.raises(Exception):
            user = User(email='test@example.com')
            db_session.add(user)
            db_session.commit()
```

**Key Features:**
```
✅ Simple assert syntax
✅ Fixtures for setup
✅ Automatic test discovery
✅ Detailed error messages
✅ Parallel execution
```

---

### Slide 7.3: Test Fixtures

**Reusable Test Setup:**

```python
# tests/conftest.py
import pytest
from app import create_app
from app.extensions import db

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

@pytest.fixture
def test_task(db_session, test_user):
    """Create test task."""
    task = Task(
        title='Test Task',
        user_id=test_user.id
    )
    db_session.add(task)
    db_session.commit()
    return task
```

---

### Slide 7.4: Integration Tests

**Testing Components Together:**

```python
# tests/integration/test_routes.py

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
    
    def test_register_success(self, client, db_session):
        response = client.post('/auth/register', data={
            'username': 'newuser',
            'email': 'new@example.com',
            'password': 'Password123!',
            'confirm_password': 'Password123!'
        }, follow_redirects=True)
        assert response.status_code == 200
        assert b'Registration successful' in response.data
        
        user = User.query.filter_by(username='newuser').first()
        assert user is not None

class TestTaskRoutes:
    def test_create_task(self, auth_client):
        response = auth_client.post('/tasks/create', data={
            'title': 'Test Task',
            'description': 'Test description'
        }, follow_redirects=True)
        assert response.status_code == 200
        assert b'Task created' in response.data
    
    def test_task_ownership(self, auth_client, test_user, db_session):
        other_user = User(username='other', email='other@example.com')
        other_user.set_password('password123')
        db_session.add(other_user)
        db_session.commit()
        
        task = Task(title='Other Task', user_id=other_user.id)
        db_session.add(task)
        db_session.commit()
        
        response = auth_client.get(f'/tasks/{task.id}/edit')
        assert response.status_code == 403
```

---

### Slide 7.5: Functional Tests

**Testing Complete Workflows:**

```python
# tests/functional/test_workflows.py

class TestUserWorkflow:
    def test_registration_login_flow(self, client):
        # 1. Register
        response = client.post('/auth/register', data={
            'username': 'workflow_user',
            'email': 'workflow@example.com',
            'password': 'Password123!',
            'confirm_password': 'Password123!'
        }, follow_redirects=True)
        assert b'Registration successful' in response.data
        
        # 2. Login
        response = client.post('/auth/login', data={
            'email': 'workflow@example.com',
            'password': 'Password123!'
        }, follow_redirects=True)
        assert b'Dashboard' in response.data
        
        # 3. Create task
        response = client.post('/tasks/create', data={
            'title': 'Workflow Test Task',
            'description': 'Testing complete workflow'
        }, follow_redirects=True)
        assert b'Task created' in response.data
        
        # 4. Complete task
        task = Task.query.filter_by(title='Workflow Test Task').first()
        response = client.post(f'/tasks/{task.id}/complete', follow_redirects=True)
        assert b'Task completed' in response.data
        
        # 5. Logout
        response = client.get('/auth/logout', follow_redirects=True)
        assert b'logged out' in response.data
        
        # 6. Try to access protected page
        response = client.get('/tasks')
        assert response.status_code == 302
```

---

### Slide 7.6: Test Coverage

**Measuring Test Completeness:**

```bash
# Install coverage
pip install pytest-cov

# Run with coverage
pytest --cov=app --cov-report=html --cov-report=term

# Coverage report
=================================== coverage ===================================
Name                    Stmts   Miss  Cover
-----------------------------------------------
app/__init__.py            50      0   100%
app/models/user.py         40      2    95%
app/models/task.py         35      1    97%
app/routes/auth.py         45      3    93%
-----------------------------------------------
TOTAL                     170      6    96%
```

**Coverage Configuration:**
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
    if __name__ == .__main__.:
    raise NotImplementedError

fail_under = 90
```

**Coverage Goals:**
- Minimum 80% coverage
- 90%+ for critical paths
- 100% for core models

---

### Slide 7.7: API Testing

**Testing REST APIs:**

```python
# tests/test_api.py
import json

class TestAPI:
    def test_get_tasks(self, auth_client, test_task):
        response = auth_client.get('/api/tasks')
        assert response.status_code == 200
        data = response.json
        assert len(data) >= 1
        assert data[0]['title'] == 'Test Task'
    
    def test_create_task(self, auth_client):
        response = auth_client.post('/api/tasks', 
            json={'title': 'API Test', 'description': 'Created via API'}
        )
        assert response.status_code == 201
        data = response.json
        assert data['title'] == 'API Test'
        assert 'id' in data
    
    def test_update_task(self, auth_client, test_task):
        response = auth_client.put(f'/api/tasks/{test_task.id}',
            json={'title': 'Updated Task', 'status': 'completed'}
        )
        assert response.status_code == 200
        data = response.json
        assert data['title'] == 'Updated Task'
        assert data['status'] == 'completed'
    
    def test_delete_task(self, auth_client, test_task):
        response = auth_client.delete(f'/api/tasks/{test_task.id}')
        assert response.status_code == 204
        
        # Verify deletion
        response = auth_client.get(f'/api/tasks/{test_task.id}')
        assert response.status_code == 404
    
    def test_api_authentication(self, client):
        # Without auth token
        response = client.get('/api/tasks')
        assert response.status_code == 302  # Redirects to login
```

---

### Slide 7.8: Debugging Techniques

**Debugging Toolkit:**

```
┌─────────────────────────────────────────────────────────────┐
│                   Debugging Methods                         │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1. Print Debugging                                        │
│  print(f"DEBUG: variable = {variable}")                    │
│                                                             │
│  2. Logging                                                │
│  app.logger.debug(f"User ID: {user.id}")                   │
│                                                             │
│  3. Python Debugger (pdb)                                  │
│  import pdb; pdb.set_trace()                              │
│                                                             │
│  4. Flask Debugger                                         │
│  app.run(debug=True)                                       │
│                                                             │
│  5. Browser Developer Tools                                │
│  Console, Network, Sources                                 │
│                                                             │
│  6. Database Query Debugging                               │
│  app.config['SQLALCHEMY_ECHO'] = True                      │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Using pdb:**
```python
def complex_function(data):
    import pdb; pdb.set_trace()  # Execution stops here
    result = process(data)
    return result

# pdb Commands:
# n (next) - execute next line
# s (step) - step into function
# c (continue) - continue execution
# p variable - print variable value
# l (list) - show code
# q (quit) - quit debugger
```

---

### Slide 7.9: Code Quality Tools

**Maintaining Code Quality:**

```
┌─────────────────────────────────────────────────────────────┐
│                    Code Quality Tools                       │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Ruff: Fast Python Linter                                  │
│  ruff check app/                                           │
│  ❌ Finds bugs and style issues                            │
│                                                             │
│  Black: Code Formatter                                     │
│  black app/                                                │
│  ✅ Formats code consistently                              │
│                                                             │
│  isort: Import Organizer                                   │
│  isort app/                                                │
│  ✅ Sorts imports consistently                             │
│                                                             │
│  mypy: Static Type Checker                                 │
│  mypy app/                                                 │
│  ✅ Catches type errors                                    │
│                                                             │
│  pre-commit: Git Hooks                                     │
│  pre-commit run --all-files                                │
│  ✅ Runs checks before commit                              │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Pre-commit Configuration:**
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
  
  - repo: https://github.com/astral-sh/ruff-pre-commit
    rev: v0.2.2
    hooks:
      - id: ruff
        args: ['--fix']
```

---

### Slide 7.10: Part 7 Summary

**What You've Learned:**

```
✅ Testing Pyramid: Unit, Integration, Functional
✅ Unit Tests: Pytest for individual components
✅ Integration Tests: Testing components together
✅ Functional Tests: Complete workflows
✅ Test Coverage: Measuring test completeness
✅ API Testing: Testing REST endpoints
✅ Debugging: Tools and techniques
✅ Code Quality: Linters and formatters

You Can Now:
- Write comprehensive tests
- Debug issues effectively
- Maintain code quality
- Build reliable applications
```

**Next: Part 8 - Production Deployment, DevOps & Monitoring**

---

# PART 8: PRODUCTION DEPLOYMENT, DEVOPS & MONITORING
## Taking Your Application Live

### Slide 8.0: Part 8 Overview

**Production Deployment, DevOps & Monitoring**

**What You'll Learn:**
- Production server setup (Gunicorn)
- Reverse proxy configuration (Nginx)
- Docker containerization
- Cloud deployment
- CI/CD pipelines
- Monitoring and logging
- Security hardening

**What You'll Build:**
- Production-ready Docker setup
- Nginx configuration
- Deployment pipeline
- Monitoring infrastructure

---

### Slide 8.1: Production Architecture

**Complete Production Stack:**

```
┌─────────────────────────────────────────────────────────────┐
│                         Users                               │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────┐
│                    Internet                                 │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────┐
│                  Nginx (Reverse Proxy)                      │
│  - SSL Termination                                          │
│  - Static File Serving                                      │
│  - Load Balancing                                           │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────┐
│                Gunicorn (WSGI Server)                       │
│  - Multiple Workers                                         │
│  - Process Management                                       │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────┐
│              Flask Application (Your Code)                  │
└─────────────────────┬───────────────────────────────────────┘
                      │
          ┌───────────┼───────────┐
          ▼           ▼           ▼
┌─────────────┐ ┌─────────────┐ ┌─────────────┐
│ PostgreSQL  │ │    Redis    │ │   Celery    │
│ (Database)  │ │   (Cache)   │ │  (Workers)  │
└─────────────┘ └─────────────┘ └─────────────┘
```

---

### Slide 8.2: Gunicorn Configuration

**Production WSGI Server:**

```python
# gunicorn.conf.py
import multiprocessing
import os

# Server socket
bind = os.environ.get('GUNICORN_BIND', '0.0.0.0:8000')
backlog = 2048

# Worker processes
workers = multiprocessing.cpu_count() * 2 + 1
worker_class = 'sync'
threads = 2

# Worker timeouts
timeout = 120
graceful_timeout = 30
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

**Starting Gunicorn:**
```bash
# Using config file
gunicorn -c gunicorn.conf.py run:app

# With custom settings
gunicorn --workers=4 --bind=0.0.0.0:8000 run:app

# With UNIX socket
gunicorn --bind=unix:/tmp/taskflow.sock run:app
```

---

### Slide 8.3: Nginx Configuration

**Reverse Proxy Setup:**

```nginx
# /etc/nginx/sites-available/taskflow

upstream taskflow_app {
    server unix:/tmp/taskflow.sock fail_timeout=0;
}

server {
    listen 443 ssl http2;
    server_name taskflow.com;
    
    # SSL Configuration
    ssl_certificate /etc/ssl/certs/taskflow.crt;
    ssl_certificate_key /etc/ssl/private/taskflow.key;
    ssl_protocols TLSv1.2 TLSv1.3;
    
    # Security Headers
    add_header Strict-Transport-Security "max-age=31536000" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    
    # Static Files
    location /static/ {
        alias /var/www/taskflow/static/;
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
    
    # Main Application
    location / {
        proxy_pass http://taskflow_app;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }
    
    # Health Check
    location /health {
        proxy_pass http://taskflow_app;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
    }
}
```

---

### Slide 8.4: Docker Containerization

**Dockerfile:**

```dockerfile
# Dockerfile
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

**Docker Compose:**
```yaml
version: '3.8'

services:
  web:
    build: .
    ports:
      - "8000:8000"
    environment:
      - FLASK_ENV=production
      - DATABASE_URL=postgresql://taskflow:password@db:5432/taskflow
      - CELERY_BROKER_URL=redis://redis:6379/0
    depends_on:
      - db
      - redis
    volumes:
      - ./logs:/app/logs
  
  db:
    image: postgres:15
    environment:
      - POSTGRES_USER=taskflow
      - POSTGRES_PASSWORD=password
      - POSTGRES_DB=taskflow
    volumes:
      - postgres_data:/var/lib/postgresql/data
  
  redis:
    image: redis:7-alpine

volumes:
  postgres_data:
```

---

### Slide 8.5: Deployment Strategies

**Blue-Green Deployment:**

```
Blue Environment (Live)
    ↓
Deploy to Green
    ↓
Test Green
    ↓
Switch Traffic to Green
    ↓
Blue becomes Backup
```

**Implementation:**
```bash
#!/bin/bash
# blue-green-deploy.sh

# Deploy to green
docker-compose -f docker-compose.green.yml up -d

# Wait for health check
sleep 30
curl -f http://localhost:8001/health || exit 1

# Switch traffic
docker-compose -f docker-compose.blue.yml down
docker-compose -f docker-compose.green.yml down

# Update load balancer
# Nginx upstream to point to green
```

**Canary Deployment:**
```
Start with 10% traffic to canary
   ↓
Monitor metrics
   ↓
Increase to 25%
   ↓
Monitor metrics
   ↓
Increase to 50%
   ↓
Monitor metrics
   ↓
Increase to 100% (full deployment)
```

---

### Slide 8.6: CI/CD Pipeline

**GitHub Actions Workflow:**

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

  build:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Build Docker image
        run: docker build -t taskflow:latest .
      - name: Push to registry
        run: |
          docker tag taskflow:latest ${{ secrets.REGISTRY }}/taskflow:latest
          docker push ${{ secrets.REGISTRY }}/taskflow:latest

  deploy:
    needs: build
    runs-on: ubuntu-latest
    steps:
      - name: Deploy to production
        run: |
          ssh user@server "cd /app && docker-compose pull && docker-compose up -d"
```

**Pipeline Stages:**
```
1. Test    → Run tests, linters, security checks
2. Build   → Build Docker image
3. Deploy  → Deploy to staging
4. Smoke   → Run smoke tests
5. Promote → Deploy to production
```

---

### Slide 8.7: Monitoring & Logging

**Health Check Endpoint:**

```python
@app.route('/health')
def health_check():
    # Check database
    db_healthy = True
    try:
        db.session.execute('SELECT 1')
    except Exception:
        db_healthy = False
    
    # Check Redis
    redis_healthy = True
    try:
        redis_client.ping()
    except Exception:
        redis_healthy = False
    
    status = 'healthy' if (db_healthy and redis_healthy) else 'unhealthy'
    
    return jsonify({
        'status': status,
        'timestamp': datetime.utcnow().isoformat(),
        'database': 'connected' if db_healthy else 'disconnected',
        'redis': 'connected' if redis_healthy else 'disconnected'
    }), 200 if status == 'healthy' else 503
```

**Logging Configuration:**
```python
import logging
from logging.handlers import RotatingFileHandler

def setup_production_logging(app):
    file_handler = RotatingFileHandler(
        'logs/taskflow.log',
        maxBytes=10*1024*1024,
        backupCount=5
    )
    file_handler.setLevel(logging.INFO)
    
    formatter = logging.Formatter(
        '%(asctime)s %(levelname)s: %(message)s [in %(pathname)s:%(lineno)d]'
    )
    file_handler.setFormatter(formatter)
    
    app.logger.addHandler(file_handler)
    app.logger.setLevel(logging.INFO)
```

---

### Slide 8.8: Monitoring Tools

**Complete Monitoring Stack:**

```
┌─────────────────────────────────────────────────────────────┐
│                      Monitoring Tools                       │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  📊 Metrics & Alerting                                     │
│  - Prometheus: Collect metrics                             │
│  - Grafana: Visualize metrics                              │
│  - AlertManager: Send alerts                               │
│                                                             │
│  📝 Logging                                                │
│  - ELK Stack: Elasticsearch, Logstash, Kibana             │
│  - Papertrail: Cloud logging                               │
│  - Loggly: Log management                                  │
│                                                             │
│  📈 Application Performance                                │
│  - New Relic: APM                                          │
│  - Datadog: Monitoring                                     │
│  - Sentry: Error tracking                                  │
│                                                             │
│  🎯 Uptime Monitoring                                      │
│  - UptimeRobot: Website monitoring                         │
│  - Pingdom: Performance monitoring                         │
│  - StatusCake: Uptime monitoring                           │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Prometheus Metrics:**
```python
from prometheus_client import Counter, Histogram, generate_latest

REQUEST_COUNT = Counter('http_requests_total', 'Total HTTP requests')
REQUEST_DURATION = Histogram('http_request_duration_seconds', 'HTTP request duration')

@app.after_request
def record_metrics(response):
    REQUEST_COUNT.inc()
    REQUEST_DURATION.observe(time.time() - g.start_time)
    return response

@app.route('/metrics')
def metrics():
    return Response(generate_latest(), mimetype='text/plain')
```

---

### Slide 8.9: Security Hardening

**Production Security Checklist:**

```
┌─────────────────────────────────────────────────────────────┐
│               Production Security Checklist                 │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ✅ Environment Variables                                   │
│  □ SECRET_KEY is strong (32+ chars)                        │
│  □ SECRET_KEY not in code                                  │
│  □ DEBUG=False                                            │
│                                                             │
│  ✅ HTTPS                                                  │
│  □ SSL certificate installed                               │
│  □ HTTP redirects to HTTPS                                 │
│  □ HSTS headers enabled                                   │
│                                                             │
│  ✅ Database                                               │
│  □ Strong password                                         │
│  □ Connection pooling configured                           │
│  □ Regular backups                                         │
│                                                             │
│  ✅ Security Headers                                       │
│  □ HSTS                                                    │
│  □ X-Frame-Options                                        │
│  □ X-Content-Type-Options                                 │
│  □ Content-Security-Policy                                │
│                                                             │
│  ✅ Monitoring                                             │
│  □ Health checks                                          │
│  □ Logging configured                                      │
│  □ Alerts configured                                      │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

### Slide 8.10: Part 8 Summary

**What You've Learned:**

```
✅ Production Stack: Gunicorn, Nginx, PostgreSQL, Redis
✅ Gunicorn: WSGI server configuration
✅ Nginx: Reverse proxy setup
✅ Docker: Containerization
✅ Deployment: Blue-green and canary
✅ CI/CD: Automated pipelines
✅ Monitoring: Health checks and logging
✅ Security: Production hardening

You Can Now:
- Deploy Flask applications to production
- Configure production servers
- Implement CI/CD pipelines
- Monitor application health
- Secure production environments
```

---

# COURSE CONCLUSION

### Slide C.1: Course Journey Summary

**What You've Accomplished:**

```
┌─────────────────────────────────────────────────────────────┐
│                 Your Learning Journey                       │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ✅ Part 1: Foundations & Architecture                     │
│     Professional project structure                         │
│                                                             │
│  ✅ Part 2: Routing, Requests & Templating                 │
│     Dynamic web pages and forms                            │
│                                                             │
│  ✅ Part 3: Databases & ORM                                │
│     Data modeling and querying                             │
│                                                             │
│  ✅ Part 4: Authentication & Security                      │
│     Secure user management                                 │
│                                                             │
│  ✅ Part 5: RESTful APIs                                   │
│     Programmable interfaces                                │
│                                                             │
│  ✅ Part 6: Async & Background Processing                  │
│     Responsive applications                                │
│                                                             │
│  ✅ Part 7: Testing & Quality                              │
│     Reliable, tested code                                  │
│                                                             │
│  ✅ Part 8: Production Deployment                           │
│     Live applications                                      │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

### Slide C.2: Skills Gained

**Your New Skills:**

```
┌─────────────────────────────────────────────────────────────┐
│                      Skills Gained                          │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  🏗️ Architecture Design                                    │
│  - Application Factory Pattern                              │
│  - Blueprint organization                                   │
│  - Service layer separation                                 │
│                                                             │
│  🔧 Development Tools                                       │
│  - Ruff, Black, isort, mypy                                │
│  - Flask extensions                                         │
│  - Development environment                                  │
│                                                             │
│  🗄️ Data Management                                        │
│  - SQLAlchemy ORM                                           │
│  - Database migrations                                      │
│  - Query optimization                                       │
│                                                             │
│  🔐 Security                                                │
│  - Authentication                                           │
│  - Authorization                                            │
│  - Security headers                                         │
│                                                             │
│  🌐 APIs                                                    │
│  - REST design                                              │
│  - JSON serialization                                       │
│  - API documentation                                        │
│                                                             │
│  ⚡ Performance                                             │
│  - Async programming                                        │
│  - Background tasks                                         │
│  - Caching                                                  │
│                                                             │
│  🧪 Quality                                                 │
│  - Testing with Pytest                                     │
│  - Debugging                                                │
│  - Code quality                                             │
│                                                             │
│  🚀 DevOps                                                  │
│  - Docker                                                   │
│  - CI/CD                                                    │
│  - Monitoring                                               │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

### Slide C.3: Next Steps

**Where to Go From Here:**

```
┌─────────────────────────────────────────────────────────────┐
│                      Next Steps                             │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  📚 Continue Learning                                      │
│  - Flask documentation                                      │
│  - Advanced extensions                                      │
│  - Community resources                                      │
│                                                             │
│  🏗️ Build Projects                                         │
│  - Start your own project                                   │
│  - Contribute to open source                               │
│  - Build a portfolio                                        │
│                                                             │
│  🚀 Deploy Applications                                     │
│  - Deploy TaskFlow                                         │
│  - Experiment with different providers                     │
│  - Scale your applications                                 │
│                                                             │
│  🔧 Specialize                                             │
│  - API design                                               │
│  - Frontend frameworks                                      │
│  - Cloud architecture                                       │
│  - Security                                                 │
│                                                             │
│  💼 Career Paths                                            │
│  - Backend developer                                        │
│  - Full-stack developer                                     │
│  - DevOps engineer                                         │
│  - Solutions architect                                     │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

### Slide C.4: Resources

**Continue Your Learning:**

```
┌─────────────────────────────────────────────────────────────┐
│                      Resources                              │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  📖 Official Documentation                                 │
│  - Flask: https://flask.palletsprojects.com                │
│  - SQLAlchemy: https://www.sqlalchemy.org                  │
│  - Jinja: https://jinja.palletsprojects.com                │
│                                                             │
│  🎓 Learning Resources                                     │
│  - Flask Mega-Tutorial                                      │
│  - Real Python Flask Tutorials                             │
│  - Test-Driven Development with Flask                      │
│                                                             │
│  🛠️ Tools                                                  │
│  - VS Code: Flask extensions                               │
│  - Postman: API testing                                    │
│  - Docker: Containerization                                │
│                                                             │
│  💬 Community                                               │
│  - Flask Discord                                            │
│  - Stack Overflow                                           │
│  - Reddit r/flask                                          │
│                                                             │
│  📚 Books                                                   │
│  - Flask Web Development                                   │
│  - SQLAlchemy Definitive Guide                             │
│  - REST API Design                                          │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

### Slide C.5: Thank You!

**Congratulations on Completing:**

# Master Modern Flask 3.x

*From Beginner to Production-Ready Applications*

**You now have the skills to:**
- ✅ Build professional Flask applications
- ✅ Design secure authentication systems
- ✅ Create RESTful APIs
- ✅ Deploy to production
- ✅ Monitor and maintain applications

**Thank you for learning with us!**

---

**Contact & Follow-Up:**
- 📧 Email: [Your Email]
- 🐦 Twitter: [Your Twitter]
- 💻 GitHub: [Your GitHub]
- 📝 Blog: [Your Blog]

**Happy Coding!** 🚀
