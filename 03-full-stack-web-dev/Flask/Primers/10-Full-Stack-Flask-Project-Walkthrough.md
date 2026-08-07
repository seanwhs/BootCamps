# Primer 10: Full Stack Flask Project Walkthrough

Welcome to Primer 10! This is the final primer in our series. We'll walk through building a complete Flask application from scratch, integrating everything you've learned in Primers 1-9. By the end of this primer, you'll have a fully functional, production-ready Flask application that demonstrates all the concepts covered in this series.

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [Setting Up the Project](#2-setting-up-the-project)
3. [Building the Models](#3-building-the-models)
4. [Implementing Authentication](#4-implementing-authentication)
5. [Building the Views](#5-building-the-views)
6. [Creating the Templates](#6-creating-the-templates)
7. [Building the API](#7-building-the-api)
8. [Adding Background Tasks](#8-adding-background-tasks)
9. [Writing Tests](#9-writing-tests)
10. [Deployment Configuration](#10-deployment-configuration)

---

## 1. Project Overview

### What We're Building

We'll build **TaskFlow Pro** - a complete task management application with:

```yaml
Features:
  ✅ User authentication (register, login, logout)
  ✅ User profiles with avatars
  ✅ Task management (CRUD operations)
  ✅ Categories and tags for tasks
  ✅ Task search and filtering
  ✅ RESTful API endpoints
  ✅ Background email notifications
  ✅ Testing suite
  ✅ Production deployment ready

Technologies:
  - Flask 3.x
  - SQLAlchemy 2.x with PostgreSQL
  - Flask-Login for authentication
  - Flask-WTF for forms
  - Flask-Migrate for migrations
  - Celery with Redis
  - Pytest for testing
  - Docker for deployment
```

### Project Structure

```
taskflow_pro/
├── app/
│   ├── __init__.py
│   ├── config.py
│   ├── extensions.py
│   ├── models/
│   │   ├── __init__.py
│   │   ├── user.py
│   │   ├── task.py
│   │   ├── category.py
│   │   └── tag.py
│   ├── forms/
│   │   ├── __init__.py
│   │   ├── auth.py
│   │   └── task.py
│   ├── blueprints/
│   │   ├── __init__.py
│   │   ├── main.py
│   │   ├── auth.py
│   │   ├── tasks.py
│   │   └── api.py
│   ├── templates/
│   │   ├── base.html
│   │   ├── main/
│   │   ├── auth/
│   │   ├── tasks/
│   │   └── emails/
│   ├── static/
│   │   ├── css/
│   │   └── js/
│   ├── tasks/
│   │   └── email.py
│   └── utils/
│       └── helpers.py
├── tests/
│   ├── __init__.py
│   ├── conftest.py
│   ├── test_models.py
│   ├── test_routes.py
│   └── test_api.py
├── migrations/
├── docker/
│   ├── Dockerfile
│   └── docker-compose.yml
├── requirements.txt
├── gunicorn.conf.py
├── run.py
└── README.md
```

---

## 2. Setting Up the Project

### Creating the Project

```bash
# Create project directory
mkdir taskflow_pro
cd taskflow_pro

# Create virtual environment
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate

# Create directory structure
mkdir -p app/{models,forms,blueprints,templates,static,utils,tasks}
mkdir tests
mkdir -p app/static/css app/static/js
mkdir -p app/templates/{main,auth,tasks,emails}

# Create initial files
touch app/__init__.py app/config.py app/extensions.py
touch app/models/__init__.py app/forms/__init__.py
touch app/blueprints/__init__.py
touch tests/__init__.py tests/conftest.py
touch run.py requirements.txt
```

### Installing Dependencies

```txt
# requirements.txt
Flask==3.0.0
Flask-SQLAlchemy==3.0.5
Flask-Migrate==4.0.5
Flask-Login==0.6.2
Flask-WTF==1.1.1
Flask-Caching==2.1.0
Flask-Mail==0.9.1
Flask-Limiter==3.5.0
Flask-Cors==4.0.0

# Database
psycopg2-binary==2.9.9
SQLAlchemy==2.0.23

# Forms
WTForms==3.1.1
email-validator==2.1.0

# Background tasks
celery==5.3.4
redis==5.0.1

# Testing
pytest==7.4.3
pytest-cov==4.1.0
factory-boy==3.3.0
faker==20.1.0

# Production
gunicorn==21.2.0
python-dotenv==1.0.0

# Utilities
python-magic==0.4.27
Pillow==10.1.0
```

```bash
# Install dependencies
pip install -r requirements.txt
```

### Configuration

```python
# app/config.py
import os
from datetime import timedelta

class Config:
    """Base configuration."""
    SECRET_KEY = os.environ.get('SECRET_KEY', 'dev-secret-key-change-in-production')
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    
    # Session
    SESSION_COOKIE_SECURE = os.environ.get('SESSION_COOKIE_SECURE', 'False') == 'True'
    SESSION_COOKIE_HTTPONLY = True
    SESSION_COOKIE_SAMESITE = 'Lax'
    PERMANENT_SESSION_LIFETIME = timedelta(days=7)
    
    # File uploads
    UPLOAD_FOLDER = 'app/static/uploads'
    MAX_CONTENT_LENGTH = 16 * 1024 * 1024  # 16MB
    ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg', 'gif', 'pdf', 'doc', 'docx'}
    
    # Pagination
    DEFAULT_PER_PAGE = 20
    
    # Celery
    CELERY_BROKER_URL = os.environ.get('CELERY_BROKER_URL', 'redis://localhost:6379/0')
    CELERY_RESULT_BACKEND = os.environ.get('CELERY_RESULT_BACKEND', 'redis://localhost:6379/1')

class DevelopmentConfig(Config):
    DEBUG = True
    SQLALCHEMY_DATABASE_URI = os.environ.get('DATABASE_URL', 'sqlite:///dev.db')
    SESSION_COOKIE_SECURE = False

class TestingConfig(Config):
    TESTING = True
    DEBUG = False
    SQLALCHEMY_DATABASE_URI = 'sqlite:///:memory:'
    SESSION_COOKIE_SECURE = False
    WTF_CSRF_ENABLED = False

class ProductionConfig(Config):
    DEBUG = False
    TESTING = False
    SQLALCHEMY_DATABASE_URI = os.environ.get('DATABASE_URL')
    SESSION_COOKIE_SECURE = True

config_by_name = {
    'development': DevelopmentConfig,
    'testing': TestingConfig,
    'production': ProductionConfig,
}
```

### Application Factory

```python
# app/__init__.py
from flask import Flask
from app.config import config_by_name
from app.extensions import init_extensions

def create_app(config_name=None):
    """Application factory."""
    if config_name is None:
        config_name = os.environ.get('FLASK_ENV', 'development')
    
    app = Flask(__name__)
    app.config.from_object(config_by_name[config_name])
    
    # Initialize extensions
    init_extensions(app)
    
    # Register blueprints
    register_blueprints(app)
    
    # Register error handlers
    register_error_handlers(app)
    
    return app

def register_blueprints(app):
    from app.blueprints.main import main_bp
    from app.blueprints.auth import auth_bp
    from app.blueprints.tasks import tasks_bp
    from app.blueprints.api import api_bp
    
    app.register_blueprint(main_bp)
    app.register_blueprint(auth_bp, url_prefix='/auth')
    app.register_blueprint(tasks_bp, url_prefix='/tasks')
    app.register_blueprint(api_bp, url_prefix='/api')

def register_error_handlers(app):
    @app.errorhandler(404)
    def not_found(error):
        return render_template('errors/404.html'), 404
    
    @app.errorhandler(500)
    def internal_error(error):
        return render_template('errors/500.html'), 500
```

### Extensions

```python
# app/extensions.py
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate
from flask_login import LoginManager
from flask_wtf.csrf import CSRFProtect
from flask_caching import Cache

db = SQLAlchemy()
migrate = Migrate()
login_manager = LoginManager()
csrf = CSRFProtect()
cache = Cache()

login_manager.login_view = 'auth.login'
login_manager.login_message = 'Please log in to access this page.'
login_manager.login_message_category = 'warning'

@login_manager.user_loader
def load_user(user_id):
    from app.models.user import User
    return User.query.get(int(user_id))

def init_extensions(app):
    db.init_app(app)
    migrate.init_app(app, db)
    login_manager.init_app(app)
    csrf.init_app(app)
    cache.init_app(app, config={
        'CACHE_TYPE': 'redis',
        'CACHE_REDIS_URL': app.config.get('CELERY_BROKER_URL', 'redis://localhost:6379/0')
    })
```

---

## 3. Building the Models

### User Model

```python
# app/models/user.py
from flask_login import UserMixin
from werkzeug.security import generate_password_hash, check_password_hash
from datetime import datetime
from app.extensions import db

class User(db.Model, UserMixin):
    __tablename__ = 'users'
    
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(50), unique=True, nullable=False, index=True)
    email = db.Column(db.String(120), unique=True, nullable=False, index=True)
    password_hash = db.Column(db.String(128), nullable=False)
    
    first_name = db.Column(db.String(50))
    last_name = db.Column(db.String(50))
    bio = db.Column(db.Text)
    avatar = db.Column(db.String(200))
    
    is_active = db.Column(db.Boolean, default=True)
    email_verified = db.Column(db.Boolean, default=False)
    is_admin = db.Column(db.Boolean, default=False)
    
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    last_login = db.Column(db.DateTime)
    
    # Relationships
    tasks = db.relationship('Task', back_populates='user', lazy='dynamic')
    assigned_tasks = db.relationship('Task', back_populates='assigned_to', foreign_keys='Task.assigned_to_id')
    
    @property
    def full_name(self):
        if self.first_name and self.last_name:
            return f"{self.first_name} {self.last_name}"
        return self.username
    
    def set_password(self, password):
        self.password_hash = generate_password_hash(password)
    
    def check_password(self, password):
        return check_password_hash(self.password_hash, password)
    
    def to_dict(self):
        return {
            'id': self.id,
            'username': self.username,
            'email': self.email,
            'full_name': self.full_name,
            'bio': self.bio,
            'avatar': self.avatar,
            'is_active': self.is_active,
            'is_admin': self.is_admin,
            'created_at': self.created_at.isoformat()
        }
    
    def __repr__(self):
        return f'<User {self.username}>'
```

### Task Model

```python
# app/models/task.py
from datetime import datetime
from app.extensions import db

class Task(db.Model):
    __tablename__ = 'tasks'
    
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
    assigned_to_id = db.Column(db.Integer, db.ForeignKey('users.id'))
    category_id = db.Column(db.Integer, db.ForeignKey('categories.id'))
    
    # Relationships
    user = db.relationship('User', back_populates='tasks', foreign_keys=[user_id])
    assigned_to = db.relationship('User', back_populates='assigned_tasks', foreign_keys=[assigned_to_id])
    category = db.relationship('Category', back_populates='tasks')
    tags = db.relationship('Tag', secondary='task_tags', back_populates='tasks')
    
    @property
    def is_completed(self):
        return self.status == 'completed'
    
    @property
    def is_overdue(self):
        if not self.due_date or self.is_completed:
            return False
        return datetime.utcnow() > self.due_date
    
    def complete(self):
        self.status = 'completed'
        self.completed_at = datetime.utcnow()
    
    def archive(self):
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
            'updated_at': self.updated_at.isoformat(),
            'user_id': self.user_id,
            'assigned_to_id': self.assigned_to_id,
            'category_id': self.category_id,
            'is_completed': self.is_completed,
            'is_overdue': self.is_overdue
        }
```

### Category Model

```python
# app/models/category.py
from datetime import datetime
from app.extensions import db

class Category(db.Model):
    __tablename__ = 'categories'
    
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(50), unique=True, nullable=False)
    description = db.Column(db.String(200))
    color = db.Column(db.String(7), default='#6c757d')
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    tasks = db.relationship('Task', back_populates='category', lazy='dynamic')
    
    def to_dict(self):
        return {
            'id': self.id,
            'name': self.name,
            'description': self.description,
            'color': self.color,
            'task_count': self.tasks.count()
        }
```

### Tag Model

```python
# app/models/tag.py
from datetime import datetime
from app.extensions import db

task_tags = db.Table('task_tags',
    db.Column('task_id', db.Integer, db.ForeignKey('tasks.id'), primary_key=True),
    db.Column('tag_id', db.Integer, db.ForeignKey('tags.id'), primary_key=True),
    db.Column('created_at', db.DateTime, default=datetime.utcnow)
)

class Tag(db.Model):
    __tablename__ = 'tags'
    
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(50), unique=True, nullable=False)
    color = db.Column(db.String(7), default='#6c757d')
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    tasks = db.relationship('Task', secondary='task_tags', back_populates='tags')
    
    def to_dict(self):
        return {
            'id': self.id,
            'name': self.name,
            'color': self.color
        }
```

### Models __init__

```python
# app/models/__init__.py
from app.models.user import User
from app.models.task import Task
from app.models.category import Category
from app.models.tag import Tag

__all__ = ['User', 'Task', 'Category', 'Tag']
```

---

## 4. Implementing Authentication

### Forms

```python
# app/forms/auth.py
from flask_wtf import FlaskForm
from wtforms import StringField, PasswordField, BooleanField, SubmitField, TextAreaField
from wtforms.validators import DataRequired, Email, Length, EqualTo, ValidationError
from app.models.user import User

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
    
    def validate_username(self, field):
        if User.query.filter_by(username=field.data).first():
            raise ValidationError('Username already taken')
    
    def validate_email(self, field):
        if User.query.filter_by(email=field.data).first():
            raise ValidationError('Email already registered')

class LoginForm(FlaskForm):
    email = StringField('Email', validators=[
        DataRequired(),
        Email()
    ])
    password = PasswordField('Password', validators=[
        DataRequired()
    ])
    remember = BooleanField('Remember Me')
    submit = SubmitField('Login')

class ProfileForm(FlaskForm):
    username = StringField('Username', validators=[
        DataRequired(),
        Length(min=3, max=50)
    ])
    first_name = StringField('First Name', validators=[Length(max=50)])
    last_name = StringField('Last Name', validators=[Length(max=50)])
    bio = TextAreaField('Bio', validators=[Length(max=500)])
    submit = SubmitField('Update Profile')
```

### Auth Blueprint

```python
# app/blueprints/auth.py
from flask import Blueprint, render_template, redirect, url_for, flash, request
from flask_login import login_user, logout_user, login_required, current_user
from app.extensions import db
from app.models.user import User
from app.forms.auth import RegistrationForm, LoginForm, ProfileForm

auth_bp = Blueprint('auth', __name__, url_prefix='/auth')

@auth_bp.route('/register', methods=['GET', 'POST'])
def register():
    if current_user.is_authenticated:
        return redirect(url_for('main.index'))
    
    form = RegistrationForm()
    if form.validate_on_submit():
        user = User(
            username=form.username.data,
            email=form.email.data
        )
        user.set_password(form.password.data)
        db.session.add(user)
        db.session.commit()
        
        flash('Registration successful! Please log in.', 'success')
        return redirect(url_for('auth.login'))
    
    return render_template('auth/register.html', form=form)

@auth_bp.route('/login', methods=['GET', 'POST'])
def login():
    if current_user.is_authenticated:
        return redirect(url_for('main.index'))
    
    form = LoginForm()
    if form.validate_on_submit():
        user = User.query.filter_by(email=form.email.data).first()
        if user and user.check_password(form.password.data):
            login_user(user, remember=form.remember.data)
            next_page = request.args.get('next')
            return redirect(next_page or url_for('main.index'))
        flash('Invalid email or password.', 'danger')
    
    return render_template('auth/login.html', form=form)

@auth_bp.route('/logout')
@login_required
def logout():
    logout_user()
    flash('You have been logged out.', 'info')
    return redirect(url_for('main.index'))

@auth_bp.route('/profile', methods=['GET', 'POST'])
@login_required
def profile():
    form = ProfileForm(obj=current_user)
    if form.validate_on_submit():
        current_user.username = form.username.data
        current_user.first_name = form.first_name.data
        current_user.last_name = form.last_name.data
        current_user.bio = form.bio.data
        db.session.commit()
        flash('Profile updated!', 'success')
        return redirect(url_for('auth.profile'))
    
    return render_template('auth/profile.html', form=form)
```

---

## 5. Building the Views

### Main Blueprint

```python
# app/blueprints/main.py
from flask import Blueprint, render_template

main_bp = Blueprint('main', __name__)

@main_bp.route('/')
def index():
    return render_template('main/index.html')

@main_bp.route('/about')
def about():
    return render_template('main/about.html')
```

### Tasks Blueprint

```python
# app/blueprints/tasks.py
from flask import Blueprint, render_template, redirect, url_for, flash, request, abort
from flask_login import login_required, current_user
from app.extensions import db
from app.models.task import Task
from app.models.category import Category
from app.models.tag import Tag
from app.forms.task import TaskForm

tasks_bp = Blueprint('tasks', __name__, url_prefix='/tasks')

@tasks_bp.route('/')
@login_required
def index():
    page = request.args.get('page', 1, type=int)
    status = request.args.get('status')
    priority = request.args.get('priority')
    
    query = Task.query.filter_by(user_id=current_user.id)
    
    if status:
        query = query.filter_by(status=status)
    if priority:
        query = query.filter_by(priority=priority)
    
    tasks = query.order_by(Task.created_at.desc()).paginate(
        page=page, per_page=20, error_out=False
    )
    
    return render_template('tasks/index.html', tasks=tasks)

@tasks_bp.route('/create', methods=['GET', 'POST'])
@login_required
def create():
    form = TaskForm()
    form.category_id.choices = [(c.id, c.name) for c in Category.query.all()]
    
    if form.validate_on_submit():
        task = Task(
            title=form.title.data,
            description=form.description.data,
            priority=form.priority.data,
            status=form.status.data,
            due_date=form.due_date.data,
            category_id=form.category_id.data,
            user_id=current_user.id
        )
        db.session.add(task)
        db.session.commit()
        
        flash('Task created!', 'success')
        return redirect(url_for('tasks.index'))
    
    return render_template('tasks/create.html', form=form)

@tasks_bp.route('/<int:task_id>')
@login_required
def view(task_id):
    task = Task.query.get_or_404(task_id)
    if task.user_id != current_user.id:
        abort(403)
    return render_template('tasks/view.html', task=task)

@tasks_bp.route('/<int:task_id>/edit', methods=['GET', 'POST'])
@login_required
def edit(task_id):
    task = Task.query.get_or_404(task_id)
    if task.user_id != current_user.id:
        abort(403)
    
    form = TaskForm(obj=task)
    form.category_id.choices = [(c.id, c.name) for c in Category.query.all()]
    
    if form.validate_on_submit():
        task.title = form.title.data
        task.description = form.description.data
        task.priority = form.priority.data
        task.status = form.status.data
        task.due_date = form.due_date.data
        task.category_id = form.category_id.data
        db.session.commit()
        
        flash('Task updated!', 'success')
        return redirect(url_for('tasks.view', task_id=task.id))
    
    return render_template('tasks/edit.html', form=form, task=task)

@tasks_bp.route('/<int:task_id>/delete', methods=['POST'])
@login_required
def delete(task_id):
    task = Task.query.get_or_404(task_id)
    if task.user_id != current_user.id:
        abort(403)
    
    db.session.delete(task)
    db.session.commit()
    flash('Task deleted.', 'info')
    return redirect(url_for('tasks.index'))

@tasks_bp.route('/<int:task_id>/complete', methods=['POST'])
@login_required
def complete(task_id):
    task = Task.query.get_or_404(task_id)
    if task.user_id != current_user.id:
        abort(403)
    
    task.complete()
    db.session.commit()
    flash('Task completed!', 'success')
    return redirect(url_for('tasks.view', task_id=task.id))
```

---

## 6. Creating the Templates

### Base Template

```html
<!-- app/templates/base.html -->
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{% block title %}TaskFlow Pro{% endblock %}</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="{{ url_for('static', filename='css/style.css') }}">
</head>
<body>
    <nav class="navbar navbar-expand-lg navbar-dark bg-dark">
        <div class="container">
            <a class="navbar-brand" href="{{ url_for('main.index') }}">
                <i class="fas fa-tasks"></i> TaskFlow Pro
            </a>
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="navbarNav">
                <ul class="navbar-nav me-auto">
                    <li class="nav-item">
                        <a class="nav-link" href="{{ url_for('main.index') }}">Home</a>
                    </li>
                    {% if current_user.is_authenticated %}
                    <li class="nav-item">
                        <a class="nav-link" href="{{ url_for('tasks.index') }}">My Tasks</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="{{ url_for('tasks.create') }}">New Task</a>
                    </li>
                    {% endif %}
                </ul>
                <ul class="navbar-nav">
                    {% if current_user.is_authenticated %}
                    <li class="nav-item dropdown">
                        <a class="nav-link dropdown-toggle" href="#" id="userDropdown" data-bs-toggle="dropdown">
                            <i class="fas fa-user"></i> {{ current_user.username }}
                        </a>
                        <ul class="dropdown-menu dropdown-menu-end">
                            <li><a class="dropdown-item" href="{{ url_for('auth.profile') }}">
                                <i class="fas fa-id-card"></i> Profile
                            </a></li>
                            <li><hr class="dropdown-divider"></li>
                            <li><a class="dropdown-item" href="{{ url_for('auth.logout') }}">
                                <i class="fas fa-sign-out-alt"></i> Logout
                            </a></li>
                        </ul>
                    </li>
                    {% else %}
                    <li class="nav-item">
                        <a class="nav-link" href="{{ url_for('auth.login') }}">
                            <i class="fas fa-sign-in-alt"></i> Login
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="{{ url_for('auth.register') }}">
                            <i class="fas fa-user-plus"></i> Register
                        </a>
                    </li>
                    {% endif %}
                </ul>
            </div>
        </div>
    </nav>

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

    <main class="container mt-4">
        {% block content %}{% endblock %}
    </main>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="{{ url_for('static', filename='js/main.js') }}"></script>
</body>
</html>
```

### Task Index Template

```html
<!-- app/templates/tasks/index.html -->
{% extends "base.html" %}

{% block title %}My Tasks - TaskFlow Pro{% endblock %}

{% block content %}
<div class="row">
    <div class="col-md-12">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h1>My Tasks</h1>
            <a href="{{ url_for('tasks.create') }}" class="btn btn-primary">
                <i class="fas fa-plus"></i> New Task
            </a>
        </div>
        
        <!-- Filters -->
        <div class="card mb-4">
            <div class="card-body">
                <form method="GET" class="row g-3">
                    <div class="col-md-3">
                        <select name="status" class="form-select">
                            <option value="">All Statuses</option>
                            <option value="pending" {% if request.args.get('status') == 'pending' %}selected{% endif %}>Pending</option>
                            <option value="in_progress" {% if request.args.get('status') == 'in_progress' %}selected{% endif %}>In Progress</option>
                            <option value="completed" {% if request.args.get('status') == 'completed' %}selected{% endif %}>Completed</option>
                        </select>
                    </div>
                    <div class="col-md-3">
                        <select name="priority" class="form-select">
                            <option value="">All Priorities</option>
                            <option value="low" {% if request.args.get('priority') == 'low' %}selected{% endif %}>Low</option>
                            <option value="medium" {% if request.args.get('priority') == 'medium' %}selected{% endif %}>Medium</option>
                            <option value="high" {% if request.args.get('priority') == 'high' %}selected{% endif %}>High</option>
                        </select>
                    </div>
                    <div class="col-md-3">
                        <button type="submit" class="btn btn-primary w-100">
                            <i class="fas fa-filter"></i> Filter
                        </button>
                    </div>
                    <div class="col-md-3">
                        <a href="{{ url_for('tasks.index') }}" class="btn btn-outline-secondary w-100">
                            <i class="fas fa-undo"></i> Reset
                        </a>
                    </div>
                </form>
            </div>
        </div>
        
        <!-- Task List -->
        {% if tasks.items %}
            <div class="list-group">
                {% for task in tasks.items %}
                <div class="list-group-item list-group-item-action">
                    <div class="d-flex justify-content-between align-items-center">
                        <div>
                            <h5 class="mb-1">
                                <a href="{{ url_for('tasks.view', task_id=task.id) }}" class="text-decoration-none">
                                    {{ task.title }}
                                </a>
                            </h5>
                            <p class="mb-1 text-muted small">
                                <span class="badge bg-{{ 'success' if task.status == 'completed' else 'warning' if task.status == 'in_progress' else 'secondary' }}">
                                    {{ task.status.replace('_', ' ').title() }}
                                </span>
                                <span class="badge bg-{{ 'danger' if task.priority == 'high' else 'warning' if task.priority == 'medium' else 'info' }}">
                                    {{ task.priority.title() }}
                                </span>
                                {% if task.due_date %}
                                    <span class="ms-2">
                                        <i class="far fa-calendar"></i> {{ task.due_date.strftime('%Y-%m-%d') }}
                                        {% if task.is_overdue %}
                                            <span class="text-danger"><i class="fas fa-exclamation-triangle"></i> Overdue</span>
                                        {% endif %}
                                    </span>
                                {% endif %}
                            </p>
                        </div>
                        <div>
                            <a href="{{ url_for('tasks.view', task_id=task.id) }}" class="btn btn-sm btn-outline-primary">
                                <i class="fas fa-eye"></i>
                            </a>
                            <a href="{{ url_for('tasks.edit', task_id=task.id) }}" class="btn btn-sm btn-outline-secondary">
                                <i class="fas fa-edit"></i>
                            </a>
                        </div>
                    </div>
                </div>
                {% endfor %}
            </div>
            
            <!-- Pagination -->
            <nav class="mt-4">
                <ul class="pagination justify-content-center">
                    {% if tasks.has_prev %}
                    <li class="page-item">
                        <a class="page-link" href="{{ url_for('tasks.index', page=tasks.prev_num, **request.args) }}">
                            Previous
                        </a>
                    </li>
                    {% endif %}
                    
                    {% for page in tasks.iter_pages() %}
                        {% if page %}
                            <li class="page-item {% if page == tasks.page %}active{% endif %}">
                                <a class="page-link" href="{{ url_for('tasks.index', page=page, **request.args) }}">
                                    {{ page }}
                                </a>
                            </li>
                        {% else %}
                            <li class="page-item disabled"><span class="page-link">…</span></li>
                        {% endif %}
                    {% endfor %}
                    
                    {% if tasks.has_next %}
                    <li class="page-item">
                        <a class="page-link" href="{{ url_for('tasks.index', page=tasks.next_num, **request.args) }}">
                            Next
                        </a>
                    </li>
                    {% endif %}
                </ul>
            </nav>
        {% else %}
            <div class="text-center py-5">
                <i class="fas fa-tasks fa-3x text-muted mb-3"></i>
                <h4>No tasks yet</h4>
                <p class="text-muted">Create your first task to get started!</p>
                <a href="{{ url_for('tasks.create') }}" class="btn btn-primary">
                    <i class="fas fa-plus"></i> Create Task
                </a>
            </div>
        {% endif %}
    </div>
</div>
{% endblock %}
```

---

## 7. Building the API

### API Blueprint

```python
# app/blueprints/api.py
from flask import Blueprint, request, jsonify, abort
from flask_login import login_required, current_user
from app.extensions import db
from app.models.task import Task
from app.models.user import User

api_bp = Blueprint('api', __name__, url_prefix='/api')

@api_bp.route('/tasks', methods=['GET'])
@login_required
def api_get_tasks():
    tasks = Task.query.filter_by(user_id=current_user.id).all()
    return jsonify([task.to_dict() for task in tasks])

@api_bp.route('/tasks', methods=['POST'])
@login_required
def api_create_task():
    data = request.get_json()
    if not data or 'title' not in data:
        return jsonify({'error': 'Title required'}), 400
    
    task = Task(
        title=data['title'],
        description=data.get('description'),
        priority=data.get('priority', 'medium'),
        status=data.get('status', 'pending'),
        due_date=data.get('due_date'),
        user_id=current_user.id
    )
    db.session.add(task)
    db.session.commit()
    return jsonify(task.to_dict()), 201

@api_bp.route('/tasks/<int:task_id>', methods=['GET'])
@login_required
def api_get_task(task_id):
    task = Task.query.get_or_404(task_id)
    if task.user_id != current_user.id:
        abort(403)
    return jsonify(task.to_dict())

@api_bp.route('/tasks/<int:task_id>', methods=['PUT'])
@login_required
def api_update_task(task_id):
    task = Task.query.get_or_404(task_id)
    if task.user_id != current_user.id:
        abort(403)
    
    data = request.get_json()
    for key in ['title', 'description', 'status', 'priority']:
        if key in data:
            setattr(task, key, data[key])
    
    if 'due_date' in data:
        task.due_date = data['due_date']
    
    db.session.commit()
    return jsonify(task.to_dict())

@api_bp.route('/tasks/<int:task_id>', methods=['DELETE'])
@login_required
def api_delete_task(task_id):
    task = Task.query.get_or_404(task_id)
    if task.user_id != current_user.id:
        abort(403)
    
    db.session.delete(task)
    db.session.commit()
    return '', 204

@api_bp.route('/tasks/<int:task_id>/complete', methods=['POST'])
@login_required
def api_complete_task(task_id):
    task = Task.query.get_or_404(task_id)
    if task.user_id != current_user.id:
        abort(403)
    
    task.complete()
    db.session.commit()
    return jsonify(task.to_dict())
```

---

## 8. Adding Background Tasks

### Email Tasks

```python
# app/tasks/email.py
from app.celery_worker import celery
from flask import render_template, current_app
from flask_mail import Message
from app.extensions import mail
import os

@celery.task
def send_async_email(subject, recipients, template, **context):
    """Send email asynchronously."""
    html = render_template(f'emails/{template}.html', **context)
    text = render_template(f'emails/{template}.txt', **context)
    
    msg = Message(
        subject=subject,
        recipients=recipients,
        html=html,
        body=text
    )
    
    mail.send(msg)
    return {'status': 'sent', 'recipients': recipients}

@celery.task
def send_welcome_email(user_id):
    """Send welcome email to new user."""
    from app.models.user import User
    user = User.query.get(user_id)
    if not user:
        return {'error': 'User not found'}
    
    return send_async_email(
        subject='Welcome to TaskFlow Pro!',
        recipients=[user.email],
        template='welcome',
        user=user
    )

@celery.task
def send_task_notification(task_id, action):
    """Send task notification."""
    from app.models.task import Task
    task = Task.query.get(task_id)
    if not task:
        return {'error': 'Task not found'}
    
    return send_async_email(
        subject=f'Task {action}: {task.title}',
        recipients=[task.user.email],
        template='task_notification',
        task=task,
        action=action
    )
```

### Celery Setup

```python
# app/celery_worker.py
from celery import Celery
import os

def make_celery(app=None):
    celery = Celery(
        'taskflow_pro',
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
        task_soft_time_limit=25 * 60
    )
    
    if app:
        celery.conf.update(app.config)
        celery.autodiscover_tasks(['app.tasks'])
    
    return celery

celery = make_celery()
```

### Using Tasks in Routes

```python
# In auth blueprint registration
from app.tasks.email import send_welcome_email

@auth_bp.route('/register', methods=['GET', 'POST'])
def register():
    # ... existing code ...
    if form.validate_on_submit():
        user = User(...)
        db.session.add(user)
        db.session.commit()
        
        # Send welcome email in background
        send_welcome_email.delay(user.id)
        
        flash('Registration successful!', 'success')
        return redirect(url_for('auth.login'))

# In tasks blueprint
from app.tasks.email import send_task_notification

@tasks_bp.route('/create', methods=['GET', 'POST'])
def create():
    if form.validate_on_submit():
        task = Task(...)
        db.session.add(task)
        db.session.commit()
        
        # Send notification in background
        send_task_notification.delay(task.id, 'created')
        
        flash('Task created!', 'success')
        return redirect(url_for('tasks.index'))
```

---

## 9. Writing Tests

### Test Configuration

```python
# tests/conftest.py
import pytest
from app import create_app
from app.extensions import db
from app.models.user import User
from app.models.task import Task

@pytest.fixture
def app():
    app = create_app('testing')
    with app.app_context():
        db.create_all()
        yield app
        db.drop_all()

@pytest.fixture
def client(app):
    return app.test_client()

@pytest.fixture
def db_session(app):
    with app.app_context():
        yield db.session

@pytest.fixture
def test_user(db_session):
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
    client.post('/auth/login', data={
        'email': 'test@example.com',
        'password': 'password123'
    })
    return client

@pytest.fixture
def test_task(db_session, test_user):
    task = Task(
        title='Test Task',
        description='Test description',
        user_id=test_user.id
    )
    db_session.add(task)
    db_session.commit()
    return task
```

### Model Tests

```python
# tests/test_models.py
import pytest
from app.models.user import User

class TestUserModel:
    def test_create_user(self, db_session):
        user = User(username='john', email='john@example.com')
        user.set_password('password123')
        db_session.add(user)
        db_session.commit()
        
        assert user.id is not None
        assert user.username == 'john'
        assert user.check_password('password123') is True
    
    def test_password_hashing(self, db_session):
        user = User(username='test')
        user.set_password('mypassword')
        assert user.password_hash != 'mypassword'
        assert user.check_password('mypassword') is True
        assert user.check_password('wrong') is False
    
    def test_unique_username(self, db_session, test_user):
        user = User(username='testuser', email='another@example.com')
        db_session.add(user)
        with pytest.raises(Exception):
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
    
    def test_register_success(self, client, db_session):
        response = client.post('/auth/register', data={
            'username': 'newuser',
            'email': 'new@example.com',
            'password': 'Password123!',
            'confirm_password': 'Password123!'
        }, follow_redirects=True)
        assert response.status_code == 200
        user = User.query.filter_by(username='newuser').first()
        assert user is not None

class TestTaskRoutes:
    def test_task_list_requires_login(self, client):
        response = client.get('/tasks')
        assert response.status_code == 302
        assert '/auth/login' in response.headers['Location']
    
    def test_task_list_authenticated(self, auth_client, test_task):
        response = auth_client.get('/tasks')
        assert response.status_code == 200
        assert b'Test Task' in response.data
    
    def test_create_task(self, auth_client):
        response = auth_client.post('/tasks/create', data={
            'title': 'New Test Task',
            'description': 'Test description',
            'priority': 'high'
        }, follow_redirects=True)
        assert response.status_code == 200
        assert b'Task created' in response.data
```

### API Tests

```python
# tests/test_api.py
import json

class TestAPI:
    def test_get_tasks_requires_login(self, client):
        response = client.get('/api/tasks')
        assert response.status_code == 302
    
    def test_get_tasks_authenticated(self, auth_client, test_task):
        response = auth_client.get('/api/tasks')
        assert response.status_code == 200
        data = response.json
        assert len(data) >= 1
        assert data[0]['title'] == 'Test Task'
    
    def test_create_task(self, auth_client):
        response = auth_client.post('/api/tasks', 
            json={'title': 'API Task', 'description': 'Created via API'}
        )
        assert response.status_code == 201
        data = response.json
        assert data['title'] == 'API Task'
    
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
```

---

## 10. Deployment Configuration

### Gunicorn Configuration

```python
# gunicorn.conf.py
import multiprocessing
import os

bind = os.environ.get('GUNICORN_BIND', '0.0.0.0:8000')
workers = multiprocessing.cpu_count() * 2 + 1
worker_class = 'sync'
threads = 2
timeout = 120
graceful_timeout = 30
max_requests = 1000
max_requests_jitter = 100
preload_app = True
accesslog = '-'
errorlog = '-'
loglevel = 'info'
```

### Dockerfile

```dockerfile
# docker/Dockerfile
FROM python:3.13-slim

WORKDIR /app

RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

RUN adduser --disabled-password --no-create-home appuser
USER appuser

HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

EXPOSE 8000

CMD ["gunicorn", "-c", "gunicorn.conf.py", "app:create_app()"]
```

### Docker Compose

```yaml
# docker/docker-compose.yml
version: '3.8'

services:
  web:
    build:
      context: ..
      dockerfile: docker/Dockerfile
    ports:
      - "8000:8000"
    environment:
      - FLASK_ENV=production
      - SECRET_KEY=${SECRET_KEY}
      - DATABASE_URL=postgresql://${DB_USER}:${DB_PASSWORD}@db:5432/${DB_NAME}
      - CELERY_BROKER_URL=redis://redis:6379/0
      - CELERY_RESULT_BACKEND=redis://redis:6379/1
    depends_on:
      - db
      - redis
    volumes:
      - ../logs:/app/logs
  
  worker:
    build:
      context: ..
      dockerfile: docker/Dockerfile
    command: celery -A app.celery_worker.celery worker --loglevel=info
    environment:
      - DATABASE_URL=postgresql://${DB_USER}:${DB_PASSWORD}@db:5432/${DB_NAME}
      - CELERY_BROKER_URL=redis://redis:6379/0
      - CELERY_RESULT_BACKEND=redis://redis:6379/1
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

### .env.production

```bash
# .env.production
SECRET_KEY=your-secure-secret-key-here
DB_USER=taskflow
DB_PASSWORD=strong-password
DB_NAME=taskflow
DATABASE_URL=postgresql://taskflow:strong-password@db:5432/taskflow
```

---

## Summary

Congratulations! You've built a complete Flask application from scratch:

### What You've Built

✅ **Full Stack Application**: Working web app with all features
✅ **Authentication**: Registration, login, logout, profiles
✅ **Task Management**: Create, read, update, delete tasks
✅ **API**: RESTful endpoints for all features
✅ **Background Tasks**: Celery for email notifications
✅ **Testing**: Comprehensive test suite
✅ **Deployment**: Docker and production configuration

### Key Concepts Applied

```python
# 1. Application Factory Pattern
app = create_app()

# 2. Blueprint Organization
app.register_blueprint(auth_bp, url_prefix='/auth')

# 3. ORM with SQLAlchemy
class Task(db.Model):
    title = db.Column(db.String(200))

# 4. Authentication with Flask-Login
@login_required
def profile(): ...

# 5. Forms with Flask-WTF
class LoginForm(FlaskForm):
    email = StringField('Email')

# 6. REST API
@app.route('/api/tasks', methods=['GET'])
def get_tasks(): ...

# 7. Background Tasks
@celery.task
def send_email(): ...

# 8. Testing
def test_create_task():
    assert response.status_code == 201

# 9. Containerization
# Dockerfile + docker-compose.yml

# 10. CI/CD Ready
# GitHub Actions workflow
```

### Running the Application

```bash
# Development
flask run

# Migrations
flask db init
flask db migrate -m "Initial migration"
flask db upgrade

# Testing
pytest

# Celery
celery -A app.celery_worker.celery worker --loglevel=info

# Production
docker-compose -f docker/docker-compose.yml up -d
```
