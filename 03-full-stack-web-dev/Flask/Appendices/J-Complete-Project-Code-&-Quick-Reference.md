# Appendix J: Complete Project Code & Quick Reference

Welcome to Appendix J! This is the final appendix, serving as a comprehensive quick reference and complete code listing for the TaskFlow application. Use this as a cheatsheet for common operations, a complete code reference, and a quick-start guide for any Flask project.

---

## Table of Contents

1. [Project Structure Quick Reference](#1-project-structure-quick-reference)
2. [Complete Code Snippets](#2-complete-code-snippets)
3. [Common Operations Cheatsheet](#3-common-operations-cheatsheet)
4. [SQLAlchemy Query Reference](#4-sqlalchemy-query-reference)
5. [Flask-WTF Form Reference](#5-flask-wtf-form-reference)
6. [Testing Quick Reference](#6-testing-quick-reference)
7. [Security Checklist](#7-security-checklist)
8. [Environment Setup Quick Start](#8-environment-setup-quick-start)

---

## 1. Project Structure Quick Reference

### Directory Tree

```
taskflow/
├── app/
│   ├── __init__.py              # Application factory
│   ├── config.py                # Configuration
│   ├── extensions.py            # Extension initialization
│   ├── logging_config.py        # Logging setup
│   ├── celery_worker.py         # Celery configuration
│   │
│   ├── blueprints/              # Route modules
│   │   ├── main/               # Public routes
│   │   ├── auth/               # Authentication
│   │   ├── tasks/              # Task management
│   │   ├── admin/              # Admin dashboard
│   │   └── api/                # REST API (v1, v2)
│   │
│   ├── models/                  # Database models
│   │   ├── user.py
│   │   ├── task.py
│   │   ├── category.py
│   │   ├── tag.py
│   │   └── comment.py
│   │
│   ├── schemas/                 # Marshmallow schemas
│   │   ├── task_schema.py
│   │   ├── user_schema.py
│   │   └── auth_schema.py
│   │
│   ├── forms/                   # WTForms
│   │   ├── auth.py
│   │   ├── task.py
│   │   └── validators.py
│   │
│   ├── services/                # Business logic
│   │   ├── user_service.py
│   │   ├── task_service.py
│   │   └── category_service.py
│   │
│   ├── tasks/                   # Celery tasks
│   │   ├── email_tasks.py
│   │   ├── report_tasks.py
│   │   └── process_tasks.py
│   │
│   ├── utils/                   # Utilities
│   │   ├── decorators.py
│   │   ├── security.py
│   │   ├── tokens.py
│   │   └── email.py
│   │
│   ├── templates/               # Jinja templates
│   │   ├── base.html
│   │   ├── main/
│   │   ├── auth/
│   │   ├── tasks/
│   │   ├── admin/
│   │   ├── errors/
│   │   └── email/
│   │
│   ├── static/                  # Static assets
│   │   ├── css/
│   │   ├── js/
│   │   └── images/
│   │
│   └── cli/                     # CLI commands
│       ├── commands.py
│       └── seed.py
│
├── tests/                       # Test suite
│   ├── unit/
│   ├── integration/
│   ├── functional/
│   └── fixtures/
│
├── docker/                      # Docker configuration
│   ├── app/Dockerfile
│   ├── nginx/nginx.conf
│   └── docker-compose.yml
│
├── scripts/                     # Scripts
├── migrations/                  # Alembic migrations
├── instance/                    # Instance folder
├── logs/                        # Log files
│
├── requirements.txt
├── requirements-dev.txt
├── pyproject.toml
├── gunicorn.conf.py
├── Makefile
├── run.py
└── README.md
```

### Key Files Reference

| File | Purpose | Key Content |
|------|---------|-------------|
| `app/__init__.py` | Application factory | `create_app()`, blueprint registration, error handlers |
| `app/config.py` | Configuration | `Config`, `DevelopmentConfig`, `ProductionConfig` |
| `app/extensions.py` | Extensions | `db`, `migrate`, `login_manager`, `csrf`, `limiter` |
| `app/models/` | Database models | SQLAlchemy model definitions |
| `app/services/` | Business logic | Service classes with repository pattern |
| `app/blueprints/` | Routes | Modular route definitions |
| `app/templates/` | Views | Jinja2 templates |
| `run.py` | Entry point | Development server |
| `gunicorn.conf.py` | Production server | Gunicorn configuration |

---

## 2. Complete Code Snippets

### Application Factory (`app/__init__.py`)

```python
from flask import Flask
from app.config import get_config
from app.extensions import init_extensions

def create_app(config_class=None):
    app = Flask(__name__, instance_relative_config=True)
    
    # Configuration
    if config_class is None:
        config_class = get_config()
    app.config.from_object(config_class)
    
    # Extensions
    init_extensions(app)
    
    # Blueprints
    register_blueprints(app)
    
    # Error handlers
    register_error_handlers(app)
    
    # Context processors
    register_context_processors(app)
    
    # CLI commands
    register_commands(app)
    
    return app

def register_blueprints(app):
    from app.blueprints.main import main_bp
    from app.blueprints.auth import auth_bp
    from app.blueprints.tasks import tasks_bp
    from app.blueprints.admin import admin_bp
    from app.blueprints.api import api_bp
    
    app.register_blueprint(main_bp)
    app.register_blueprint(auth_bp, url_prefix='/auth')
    app.register_blueprint(tasks_bp, url_prefix='/tasks')
    app.register_blueprint(admin_bp, url_prefix='/admin')
    app.register_blueprint(api_bp, url_prefix='/api')
```

### Model Definition (`app/models/task.py`)

```python
from datetime import datetime
from app.extensions import db

class Task(db.Model):
    __tablename__ = 'tasks'
    
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(200), nullable=False)
    description = db.Column(db.Text)
    status = db.Column(db.String(50), default='pending')
    priority = db.Column(db.String(50), default='medium')
    due_date = db.Column(db.DateTime)
    completed_at = db.Column(db.DateTime)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    assigned_to_id = db.Column(db.Integer, db.ForeignKey('users.id'))
    category_id = db.Column(db.Integer, db.ForeignKey('categories.id'))
    
    user = db.relationship('User', back_populates='tasks', foreign_keys=[user_id])
    assigned_to = db.relationship('User', back_populates='assigned_tasks', foreign_keys=[assigned_to_id])
    category = db.relationship('Category', back_populates='tasks')
    tags = db.relationship('Tag', secondary='task_tags', back_populates='tasks')
    comments = db.relationship('Comment', back_populates='task', lazy='dynamic')
    
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
            'is_completed': self.status == 'completed'
        }
    
    def complete(self):
        self.status = 'completed'
        self.completed_at = datetime.utcnow()
    
    def archive(self):
        self.status = 'archived'
```

### Service Class (`app/services/task_service.py`)

```python
from app.extensions import db
from app.models.task import Task
from app.models.tag import Tag

class TaskService:
    
    @staticmethod
    def get_user_tasks(user, filters=None):
        query = Task.query.filter_by(user_id=user.id)
        if filters:
            if filters.get('status'):
                query = query.filter_by(status=filters['status'])
            if filters.get('priority'):
                query = query.filter_by(priority=filters['priority'])
            if filters.get('search'):
                query = query.filter(Task.title.ilike(f"%{filters['search']}%"))
        return query.order_by(Task.created_at.desc()).all()
    
    @staticmethod
    def create_task(user, data):
        task = Task(
            title=data['title'],
            description=data.get('description'),
            priority=data.get('priority', 'medium'),
            status=data.get('status', 'pending'),
            user_id=user.id,
            assigned_to_id=data.get('assigned_to_id'),
            category_id=data.get('category_id'),
            due_date=data.get('due_date')
        )
        db.session.add(task)
        
        # Add tags if provided
        if data.get('tags'):
            for tag_name in data['tags']:
                tag = Tag.query.filter_by(name=tag_name).first()
                if not tag:
                    tag = Tag(name=tag_name)
                    db.session.add(tag)
                task.tags.append(tag)
        
        db.session.commit()
        return task
    
    @staticmethod
    def update_task(task, data):
        for key, value in data.items():
            if hasattr(task, key) and key not in ['id', 'created_at']:
                setattr(task, key, value)
        task.updated_at = datetime.utcnow()
        db.session.commit()
        return task
    
    @staticmethod
    def delete_task(task):
        db.session.delete(task)
        db.session.commit()
```

### API Endpoint (`app/blueprints/api/v1/routes.py`)

```python
from flask import jsonify, request, abort
from flask_jwt_extended import jwt_required, get_jwt_identity
from app.blueprints.api.v1 import v1_bp
from app.services import TaskService

@v1_bp.route('/tasks', methods=['GET'])
@jwt_required
def list_tasks():
    user_id = get_jwt_identity()
    filters = {
        'status': request.args.get('status'),
        'priority': request.args.get('priority'),
        'search': request.args.get('search')
    }
    tasks = TaskService.get_user_tasks(user_id, filters)
    return jsonify([task.to_dict() for task in tasks])

@v1_bp.route('/tasks', methods=['POST'])
@jwt_required
def create_task():
    user_id = get_jwt_identity()
    data = request.json
    if not data.get('title'):
        return jsonify({'error': 'Title required'}), 400
    task = TaskService.create_task(user_id, data)
    return jsonify(task.to_dict()), 201

@v1_bp.route('/tasks/<int:task_id>', methods=['GET'])
@jwt_required
def get_task(task_id):
    task = Task.query.get_or_404(task_id)
    return jsonify(task.to_dict())

@v1_bp.route('/tasks/<int:task_id>', methods=['PUT'])
@jwt_required
def update_task(task_id):
    task = Task.query.get_or_404(task_id)
    data = request.json
    TaskService.update_task(task, data)
    return jsonify(task.to_dict())

@v1_bp.route('/tasks/<int:task_id>', methods=['DELETE'])
@jwt_required
def delete_task(task_id):
    task = Task.query.get_or_404(task_id)
    TaskService.delete_task(task)
    return '', 204
```

### Template Base (`app/templates/base.html`)

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{% block title %}{{ app_name }}{% endblock %}</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="{{ url_for('static', filename='css/style.css') }}">
    {% block extra_css %}{% endblock %}
</head>
<body>
    <nav class="navbar navbar-expand-lg navbar-dark bg-dark">
        <div class="container">
            <a class="navbar-brand" href="{{ url_for('main.index') }}">TaskFlow</a>
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
                            <a class="nav-link" href="{{ url_for('tasks.dashboard') }}">Dashboard</a>
                        </li>
                    {% endif %}
                </ul>
                <ul class="navbar-nav">
                    {% if current_user.is_authenticated %}
                        <li class="nav-item dropdown">
                            <a class="nav-link dropdown-toggle" href="#" data-bs-toggle="dropdown">
                                {{ current_user.username }}
                            </a>
                            <ul class="dropdown-menu dropdown-menu-end">
                                <li><a class="dropdown-item" href="{{ url_for('auth.profile') }}">Profile</a></li>
                                <li><hr class="dropdown-divider"></li>
                                <li><a class="dropdown-item" href="{{ url_for('auth.logout') }}">Logout</a></li>
                            </ul>
                        </li>
                    {% else %}
                        <li class="nav-item">
                            <a class="nav-link" href="{{ url_for('auth.login') }}">Login</a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="{{ url_for('auth.register') }}">Register</a>
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

    <main>
        {% block content %}{% endblock %}
    </main>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="{{ url_for('static', filename='js/main.js') }}"></script>
    {% block extra_js %}{% endblock %}
</body>
</html>
```

---

## 3. Common Operations Cheatsheet

### Model Operations

```python
# Create
user = User(username='john', email='john@example.com')
user.set_password('password123')
db.session.add(user)
db.session.commit()

# Read (Query)
user = User.query.get(1)  # By ID
users = User.query.filter_by(role='admin').all()  # By field
users = User.query.filter(User.email.like('%@example.com')).all()  # Like
users = User.query.order_by(User.created_at.desc()).limit(10).all()  # Order & Limit

# Update
user = User.query.get(1)
user.username = 'johndoe'
db.session.commit()

# Delete
user = User.query.get(1)
db.session.delete(user)
db.session.commit()

# Relationships
user = User.query.get(1)
tasks = user.tasks.all()  # Dynamic relationship
task = Task.query.get(1)
user = task.user  # Backref

# Aggregation
count = User.query.count()
avg_priority = db.session.query(db.func.avg(Task.priority)).scalar()
tasks_by_status = db.session.query(Task.status, db.func.count(Task.id)).group_by(Task.status).all()
```

### Service Operations

```python
# User Service
user = UserService.create_user(
    username='john',
    email='john@example.com',
    password='password123'
)
user = UserService.authenticate_user('john@example.com', 'password123')
user = UserService.update_user(user, first_name='John', last_name='Doe')
UserService.change_password(user, 'oldpass', 'newpass')
UserService.toggle_active(user)
UserService.delete_user(user)

# Task Service
task = TaskService.create_task(
    user=current_user,
    title='Complete project',
    description='Finish the Flask tutorial',
    priority='high',
    status='pending'
)
tasks = TaskService.get_user_tasks(
    current_user,
    status='pending',
    priority='high'
)
TaskService.update_task(task, {'status': 'completed'})
TaskService.delete_task(task)
```

### Blueprint Operations

```python
# Create blueprint
bp = Blueprint('example', __name__, url_prefix='/example')

# Routes
@bp.route('/')
def index(): ...

@bp.route('/<int:id>')
def get(id): ...

@bp.route('/create', methods=['GET', 'POST'])
def create(): ...

# Register blueprint
app.register_blueprint(bp)

# URL building
url_for('example.index')
url_for('example.get', id=1)
url_for('example.create')
```

### Form Operations

```python
# Define form
class TaskForm(FlaskForm):
    title = StringField('Title', validators=[DataRequired()])
    description = TextAreaField('Description')
    priority = SelectField('Priority', choices=[
        ('low', 'Low'), ('medium', 'Medium'), ('high', 'High')
    ])
    status = SelectField('Status', choices=[
        ('pending', 'Pending'), ('in_progress', 'In Progress'), ('completed', 'Completed')
    ])
    submit = SubmitField('Save')

# Use form
@app.route('/task/new', methods=['GET', 'POST'])
def new_task():
    form = TaskForm()
    if form.validate_on_submit():
        # Process form
        task = Task(title=form.title.data, description=form.description.data)
        db.session.add(task)
        db.session.commit()
        flash('Task created!', 'success')
        return redirect(url_for('tasks.index'))
    return render_template('task_form.html', form=form)
```

---

## 4. SQLAlchemy Query Reference

### Basic Queries

```python
# Get all
users = User.query.all()

# Get first
user = User.query.first()

# Get by ID
user = User.query.get(1)

# Filter (equals)
users = User.query.filter_by(role='admin').all()

# Filter (condition)
users = User.query.filter(User.age >= 18).all()

# Filter (multiple conditions)
users = User.query.filter(User.role == 'admin', User.active == True).all()

# Filter (OR)
from sqlalchemy import or_
users = User.query.filter(or_(User.role == 'admin', User.role == 'manager')).all()

# Filter (IN)
users = User.query.filter(User.role.in_(['admin', 'manager'])).all()

# Filter (NOT)
from sqlalchemy import not_
users = User.query.filter(not_(User.role == 'admin')).all()

# Like
users = User.query.filter(User.username.like('%john%')).all()

# ILike (case-insensitive)
users = User.query.filter(User.username.ilike('%john%')).all()

# Between
users = User.query.filter(User.id.between(1, 10)).all()

# Is NULL
tasks = Task.query.filter(Task.due_date.is_(None)).all()

# Is NOT NULL
tasks = Task.query.filter(Task.due_date.isnot(None)).all()
```

### Advanced Queries

```python
# Order By
users = User.query.order_by(User.username.asc()).all()
users = User.query.order_by(User.created_at.desc()).all()
users = User.query.order_by(User.username.asc(), User.id.desc()).all()

# Limit / Offset
users = User.query.limit(10).offset(20).all()

# Count
count = User.query.count()
count = User.query.filter_by(role='admin').count()

# Pagination
page = 2
per_page = 20
users = User.query.paginate(page=page, per_page=per_page)
# users.items - list of users
# users.total - total count
# users.pages - total pages
# users.has_prev, users.has_next

# Aggregation
from sqlalchemy import func
count = db.session.query(func.count(User.id)).scalar()
avg = db.session.query(func.avg(User.age)).scalar()
max = db.session.query(func.max(User.created_at)).scalar()

# Group By
users_by_role = db.session.query(User.role, func.count(User.id)).group_by(User.role).all()

# Having
result = db.session.query(
    User.role, func.count(User.id)
).group_by(User.role).having(func.count(User.id) > 5).all()

# Distinct
roles = db.session.query(User.role).distinct().all()
```

### Joins

```python
# Inner Join
tasks = db.session.query(Task).join(User).filter(User.username == 'john').all()

# Left Outer Join
users = db.session.query(User).outerjoin(Task).filter(Task.id.is_(None)).all()

# Multiple Joins
tasks = db.session.query(Task).join(User).join(Category).all()

# Join with conditions
tasks = db.session.query(Task).join(User, Task.user_id == User.id).all()

# Aliased Joins
from sqlalchemy.orm import aliased
manager = aliased(User)
tasks = db.session.query(Task).join(manager, Task.assigned_to_id == manager.id).filter(manager.username == 'jane').all()

# Eager Loading
tasks = Task.query.options(joinedload(Task.user)).all()
tasks = Task.query.options(selectinload(Task.tags)).all()
tasks = Task.query.options(joinedload(Task.user).joinedload(User.profile)).all()
```

### Subqueries

```python
# Subquery in WHERE
subquery = db.session.query(Task.user_id).filter(Task.status == 'completed').subquery()
users = User.query.filter(User.id.in_(subquery)).all()

# Subquery in SELECT
subquery = db.session.query(Task.user_id, func.count(Task.id).label('task_count')).group_by(Task.user_id).subquery()
users = db.session.query(User, subquery.c.task_count).outerjoin(subquery, User.id == subquery.c.user_id).all()

# EXISTS
from sqlalchemy import exists
subquery = db.session.query(Task).filter(Task.user_id == User.id).exists()
users = User.query.filter(subquery).all()

# Correlated Subquery
subquery = db.session.query(func.count(Task.id)).filter(Task.user_id == User.id).correlate(User).scalar_subquery()
users = User.query.add_columns(subquery).all()
```

### Bulk Operations

```python
# Bulk Insert
users = [User(username=f'user{i}') for i in range(100)]
db.session.bulk_save_objects(users)
db.session.commit()

# Bulk Insert (faster)
users = [{'username': f'user{i}'} for i in range(100)]
db.session.bulk_insert_mappings(User, users)
db.session.commit()

# Bulk Update
db.session.bulk_update_mappings(Task, [
    {'id': 1, 'status': 'completed'},
    {'id': 2, 'status': 'completed'},
])
db.session.commit()

# Bulk Delete
db.session.query(Task).filter(Task.status == 'archived').delete()
db.session.commit()
```

---

## 5. Flask-WTF Form Reference

### Form Field Types

```python
from wtforms import *
from wtforms.validators import *

# Text fields
StringField('Username', validators=[DataRequired(), Length(min=3, max=50)])
TextAreaField('Description', validators=[Length(max=1000)])
PasswordField('Password', validators=[DataRequired(), Length(min=8)])
EmailField('Email', validators=[DataRequired(), Email()])
URLField('Website', validators=[URL()])
TelField('Phone', validators=[Length(max=20)])

# Numeric fields
IntegerField('Age', validators=[NumberRange(min=0, max=150)])
FloatField('Price', validators=[NumberRange(min=0)])
DecimalField('Amount', places=2)

# Choice fields
SelectField('Status', choices=[('pending', 'Pending'), ('active', 'Active')])
SelectMultipleField('Tags', choices=[('1', 'Tag 1'), ('2', 'Tag 2')])
RadioField('Gender', choices=[('m', 'Male'), ('f', 'Female')])
BooleanField('Agree to terms')
DateField('Birthday', format='%Y-%m-%d')
DateTimeField('Timestamp', format='%Y-%m-%d %H:%M:%S')
TimeField('Start time')
FileField('Upload file')
HiddenField('ID')
SubmitField('Submit')
```

### Common Validators

```python
from wtforms.validators import *

DataRequired()                 # Field must be filled
Email()                        # Valid email format
Length(min=3, max=50)         # String length
NumberRange(min=0, max=100)   # Numeric range
URL()                          # Valid URL
EqualTo('field')               # Must equal another field
Optional()                     # Field is optional
Regexp(r'^[A-Z]+$')          # Match regex
AnyOf(['a', 'b'])             # Must be in list
NoneOf(['bad', 'words'])      # Cannot be in list
IPAddress()                    # Valid IP address
MACAddress()                   # Valid MAC address
UUID()                         # Valid UUID
DateTime(format='%Y-%m-%d')   # Valid datetime
```

### Custom Validators

```python
def validate_username(form, field):
    if field.data and not field.data.isalnum():
        raise ValidationError('Username must be alphanumeric')

def unique_email(form, field):
    user = User.query.filter_by(email=field.data).first()
    if user:
        raise ValidationError('Email already registered')

class Unique:
    def __init__(self, model, field, message=None):
        self.model = model
        self.field = field
        self.message = message or f'{field} already exists'
    
    def __call__(self, form, field):
        query = self.model.query.filter(getattr(self.model, self.field) == field.data)
        if form._obj:
            query = query.filter(self.model.id != form._obj.id)
        if query.first():
            raise ValidationError(self.message)

class PasswordStrength:
    def __init__(self, min_length=8):
        self.min_length = min_length
    
    def __call__(self, form, field):
        password = field.data
        if len(password) < self.min_length:
            raise ValidationError(f'Password must be at least {self.min_length} characters')
        if not re.search(r'[A-Z]', password):
            raise ValidationError('Password must contain uppercase letter')
        if not re.search(r'[a-z]', password):
            raise ValidationError('Password must contain lowercase letter')
        if not re.search(r'\d', password):
            raise ValidationError('Password must contain a number')
```

---

## 6. Testing Quick Reference

### Pytest Fixtures

```python
# conftest.py

@pytest.fixture
def app():
    app = create_app(TestingConfig)
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
    user = User(username='test', email='test@example.com')
    user.set_password('password')
    db_session.add(user)
    db_session.commit()
    return user

@pytest.fixture
def auth_client(client, test_user):
    client.post('/auth/login', data={
        'email': 'test@example.com',
        'password': 'password'
    })
    return client
```

### Test Examples

```python
# Unit Test
class TestTaskModel:
    def test_task_complete(self):
        task = Task(title='Test')
        assert task.status == 'pending'
        task.complete()
        assert task.status == 'completed'
        assert task.completed_at is not None

# Integration Test
class TestTaskService:
    def test_create_task(self, db_session, test_user):
        task = TaskService.create_task(
            user=test_user,
            title='Integration Test'
        )
        assert task.id is not None
        assert task.user_id == test_user.id

# API Test
class TestTaskAPI:
    def test_create_task(self, auth_client):
        response = auth_client.post('/api/tasks', json={
            'title': 'API Test'
        })
        assert response.status_code == 201
        assert response.json['title'] == 'API Test'
```

### Common Test Commands

```bash
# Run all tests
pytest

# Run specific test file
pytest tests/unit/test_models.py

# Run specific test
pytest tests/unit/test_models.py::TestUserModel::test_create_user

# Run with coverage
pytest --cov=app --cov-report=html

# Run only unit tests
pytest -m unit

# Run with verbose output
pytest -v

# Run without capturing output
pytest -s

# Stop on first failure
pytest -x

# Run tests with print statements
pytest --capture=no
```

---

## 7. Security Checklist

### Application Security

```yaml
# Checklist
- [ ] SECRET_KEY set to strong random value (32+ chars)
- [ ] SECRET_KEY not in version control
- [ ] DEBUG=False in production
- [ ] SESSION_COOKIE_SECURE=True in production
- [ ] SESSION_COOKIE_HTTPONLY=True
- [ ] SESSION_COOKIE_SAMESITE='Strict'
- [ ] WTF_CSRF_ENABLED=True
- [ ] HTTPS enforced (redirect HTTP to HTTPS)
- [ ] Password hashing with strong algorithm (bcrypt/scrypt)
- [ ] Password policy enforced (length, complexity)
- [ ] Rate limiting on login endpoints
- [ ] Account lockout after failed attempts
- [ ] Email verification for new accounts
- [ ] Role-based access control (RBAC)
- [ ] CSRF protection on all forms
- [ ] XSS protection (auto-escaping)
- [ ] SQL injection protection (parameterized queries)
- [ ] File upload validation (type, size, content)
- [ ] Secure file storage (outside web root)
- [ ] Security headers (HSTS, CSP, X-Frame-Options)
- [ ] Logging of security events
- [ ] Session timeout configured
- [ ] CORS properly configured (if API)
- [ ] Dependencies scanned for vulnerabilities
- [ ] Regular security updates
```

### Security Headers

```python
@app.after_request
def security_headers(response):
    response.headers['Strict-Transport-Security'] = 'max-age=31536000; includeSubDomains'
    response.headers['X-Frame-Options'] = 'SAMEORIGIN'
    response.headers['X-Content-Type-Options'] = 'nosniff'
    response.headers['X-XSS-Protection'] = '1; mode=block'
    response.headers['Referrer-Policy'] = 'strict-origin-when-cross-origin'
    response.headers['Content-Security-Policy'] = "default-src 'self'"
    return response
```

---

## 8. Environment Setup Quick Start

### Development Setup

```bash
# 1. Clone repository
git clone https://github.com/yourusername/taskflow.git
cd taskflow

# 2. Create virtual environment
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate

# 3. Install dependencies
pip install -r requirements.txt
pip install -r requirements-dev.txt

# 4. Configure environment
cp .env.example .env
# Edit .env with your settings

# 5. Initialize database
flask db init
flask db migrate -m "Initial migration"
flask db upgrade

# 6. Seed database
flask seed-db

# 7. Run development server
python run.py
# Or: flask run

# 8. Run tests
pytest

# 9. Format code
make format

# 10. Lint code
make lint
```

### Production Setup

```bash
# 1. Configure environment
cp .env.production.example .env.production
# Edit .env.production with production settings

# 2. Build Docker image
docker build -f docker/app/Dockerfile -t taskflow:latest .

# 3. Start services
docker-compose -f docker/docker-compose.yml up -d

# 4. Run migrations
docker-compose -f docker/docker-compose.yml exec web flask db upgrade

# 5. Check health
curl http://localhost:8000/health

# 6. View logs
docker-compose -f docker/docker-compose.yml logs -f web

# 7. Stop services
docker-compose -f docker/docker-compose.yml down
```

### Quick Commands Reference

```bash
# Application
python run.py                    # Development server
flask run                        # Flask CLI server
flask routes                     # Show routes
flask shell                      # Flask shell

# Database
flask db init                    # Initialize migrations
flask db migrate -m "message"    # Generate migration
flask db upgrade                 # Apply migrations
flask db downgrade               # Rollback migration

# Data
flask seed-db                    # Seed database
flask create-admin               # Create admin user
flask list-users                 # List all users

# Testing
pytest                           # Run all tests
pytest --cov=app                 # Run with coverage
make test                        # Run tests with coverage

# Code Quality
make format                      # Format code (Black)
make lint                        # Lint code (Ruff)
make type-check                  # Type check (mypy)

# Docker
docker-compose up -d             # Start services
docker-compose down              # Stop services
docker-compose logs -f           # View logs

# Celery
celery -A app.celery_worker.celery worker --loglevel=info
celery -A app.celery_worker.celery beat --loglevel=info
celery -A app.celery_worker.celery flower --port=5555
```

---

## Summary

This appendix has provided a complete quick reference for the TaskFlow application:

1. **Project Structure**: Complete directory tree with file purposes
2. **Code Snippets**: Key implementations for all layers
3. **Common Operations**: Model, service, blueprint, form operations
4. **SQLAlchemy Queries**: All query types with examples
5. **WTForms Reference**: Field types, validators, custom validators
6. **Testing Reference**: Fixtures, tests, commands
7. **Security Checklist**: Complete security configuration
8. **Environment Setup**: Development and production setup

**Final Tips**:
- Keep this reference handy during development
- Use the cheatsheet for quick lookups
- Follow the security checklist for production
- Refer to the environment setup for new projects
