# Appendix I: Advanced Flask Patterns & Anti-Patterns

Welcome to Appendix I! This comprehensive reference provides an expert-level exploration of advanced design patterns, architectural decisions, and common anti-patterns in Flask development. Understanding these patterns and pitfalls will help you write cleaner, more maintainable, and more scalable Flask applications.

---

## Table of Contents

1. [Design Patterns in Flask](#1-design-patterns-in-flask)
2. [Application Architecture Patterns](#2-application-architecture-patterns)
3. [Database Patterns](#3-database-patterns)
4. [API Design Patterns](#4-api-design-patterns)
5. [Authentication & Authorization Patterns](#5-authentication--authorization-patterns)
6. [Testing Patterns](#6-testing-patterns)
7. [Common Anti-Patterns & Solutions](#7-common-anti-patterns--solutions)
8. [Refactoring Strategies](#8-refactoring-strategies)

---

## 1. Design Patterns in Flask

### Singleton Pattern in Flask

Flask's application and request contexts inherently implement the Singleton pattern, ensuring only one instance exists per request.

```python
# The Singleton pattern in Flask
# Flask's `current_app` and `request` are thread-local singletons

from flask import current_app, request, g

# ❌ Bad: Passing app around everywhere
def some_function(app):
    app.config['SETTING'] = 'value'
    return app.config['SETTING']

# ✅ Good: Using current_app singleton
def some_function():
    current_app.config['SETTING'] = 'value'
    return current_app.config['SETTING']

# Singleton for services
class DatabaseService:
    """Singleton database service."""
    _instance = None
    _initialized = False
    
    def __new__(cls):
        if cls._instance is None:
            cls._instance = super().__new__(cls)
        return cls._instance
    
    def __init__(self):
        if not self._initialized:
            self._init_db()
            self._initialized = True
    
    def _init_db(self):
        self.engine = create_engine(current_app.config['DATABASE_URL'])
        self.Session = sessionmaker(bind=self.engine)

# Using the Singleton
db_service = DatabaseService()  # Single instance throughout application
```

### Factory Pattern

The Application Factory pattern is the most important pattern in Flask development.

```python
# Application Factory Pattern - Best Practice
def create_app(config_class=None):
    """Application factory for creating Flask instances."""
    app = Flask(__name__)
    
    # Configure
    if config_class:
        app.config.from_object(config_class)
    else:
        app.config.from_envvar('FLASK_CONFIG', silent=True)
    
    # Initialize extensions
    db.init_app(app)
    migrate.init_app(app, db)
    login_manager.init_app(app)
    
    # Register blueprints
    app.register_blueprint(main_bp)
    app.register_blueprint(auth_bp, url_prefix='/auth')
    
    # Register error handlers
    register_error_handlers(app)
    
    # Register context processors
    register_context_processors(app)
    
    return app

# Multiple app instances for testing
def create_test_app():
    """Create app specifically for testing."""
    app = create_app(TestingConfig)
    with app.app_context():
        db.create_all()
    return app
```

### Repository Pattern

Separating data access logic from business logic.

```python
# Repository Pattern - Data Access Layer
class TaskRepository:
    """Repository for task data access."""
    
    @staticmethod
    def get_by_id(task_id):
        return Task.query.get(task_id)
    
    @staticmethod
    def get_user_tasks(user_id, filters=None):
        query = Task.query.filter_by(user_id=user_id)
        
        if filters:
            if 'status' in filters:
                query = query.filter_by(status=filters['status'])
            if 'priority' in filters:
                query = query.filter_by(priority=filters['priority'])
        
        return query.all()
    
    @staticmethod
    def create(data):
        task = Task(**data)
        db.session.add(task)
        db.session.commit()
        return task
    
    @staticmethod
    def update(task, data):
        for key, value in data.items():
            setattr(task, key, value)
        db.session.commit()
        return task
    
    @staticmethod
    def delete(task):
        db.session.delete(task)
        db.session.commit()

# Service Layer using Repository
class TaskService:
    """Business logic layer."""
    
    @staticmethod
    def get_user_tasks(user, status=None):
        filters = {}
        if status:
            filters['status'] = status
        return TaskRepository.get_user_tasks(user.id, filters)
    
    @staticmethod
    def create_task(user, data):
        data['user_id'] = user.id
        return TaskRepository.create(data)
```

### Observer Pattern (Signals)

Flask's signal system implements the Observer pattern.

```python
from flask import signals, g, request
from flask.signals import Namespace

# Create custom signals
task_signals = Namespace()
task_created = task_signals.signal('task-created')
task_updated = task_signals.signal('task-updated')
task_deleted = task_signals.signal('task-deleted')

# Observers (signal handlers)
def on_task_created(sender, **extra):
    """Handle task creation events."""
    task = extra.get('task')
    user = extra.get('user')
    
    # Log the creation
    current_app.logger.info(f"Task {task.id} created by {user.id}")
    
    # Send notification
    send_task_notification.delay(task.id, user.id, 'created')
    
    # Invalidate cache
    cache.delete(f"user_tasks:{user.id}")

def on_task_updated(sender, **extra):
    """Handle task update events."""
    task = extra.get('task')
    user = extra.get('user')
    
    # Clear related caches
    cache.delete(f"task:{task.id}")
    cache.delete(f"user_tasks:{user.id}")

# Register observers
task_created.connect(on_task_created)
task_updated.connect(on_task_updated)

# Sending signals
def create_task(user, data):
    task = TaskService.create_task(user, data)
    task_created.send(
        current_app._get_current_object(),
        task=task,
        user=user
    )
    return task
```

### Decorator Pattern

Using decorators for cross-cutting concerns.

```python
# Decorator Pattern - Cross-cutting concerns

# Timing decorator
def timeit(f):
    """Measure function execution time."""
    @wraps(f)
    def decorated(*args, **kwargs):
        start = time.time()
        result = f(*args, **kwargs)
        duration = time.time() - start
        current_app.logger.info(f"{f.__name__} took {duration:.3f}s")
        return result
    return decorated

# Retry decorator
def retry(max_retries=3, delay=1, exceptions=(Exception,)):
    """Retry function on failure."""
    def decorator(f):
        @wraps(f)
        def decorated(*args, **kwargs):
            last_exception = None
            for attempt in range(max_retries):
                try:
                    return f(*args, **kwargs)
                except exceptions as e:
                    last_exception = e
                    if attempt < max_retries - 1:
                        time.sleep(delay * (2 ** attempt))  # Exponential backoff
            raise last_exception
        return decorated
    return decorator

# Transaction decorator
def transactional(f):
    """Run function in a database transaction."""
    @wraps(f)
    def decorated(*args, **kwargs):
        try:
            result = f(*args, **kwargs)
            db.session.commit()
            return result
        except Exception:
            db.session.rollback()
            raise
    return decorated

# Usage
@timeit
@retry(max_retries=3)
@transactional
def process_task(task_id):
    """Process a task with retry and transaction support."""
    task = Task.query.get(task_id)
    # Process task...
    return task
```

---

## 2. Application Architecture Patterns

### Modular Monolith

A modular monolith balances the simplicity of a monolith with the modularity of microservices.

```python
# Modular Monolith Architecture
"""
app/
├── modules/
│   ├── __init__.py
│   ├── tasks/
│   │   ├── __init__.py
│   │   ├── models.py          # Task models
│   │   ├── services.py        # Task business logic
│   │   ├── repositories.py    # Task data access
│   │   ├── views.py           # Task routes
│   │   ├── api.py             # Task API endpoints
│   │   └── events.py          # Task events
│   ├── users/
│   │   ├── __init__.py
│   │   ├── models.py
│   │   ├── services.py
│   │   ├── repositories.py
│   │   ├── views.py
│   │   └── api.py
│   └── notifications/
│       ├── __init__.py
│       ├── services.py
│       └── listeners.py
└── shared/
    ├── __init__.py
    ├── database.py            # Shared DB utils
    ├── cache.py              # Shared cache
    ├── events.py             # Shared event bus
    └── utils.py             # Shared utilities
"""

# Module registration
class ModuleRegistry:
    """Register and manage modules."""
    
    _modules = {}
    
    @classmethod
    def register(cls, name, module):
        cls._modules[name] = module
    
    @classmethod
    def get_module(cls, name):
        return cls._modules.get(name)
    
    @classmethod
    def get_all(cls):
        return cls._modules.items()

# Shared event bus
class EventBus:
    """Central event bus for module communication."""
    
    _handlers = {}
    
    @classmethod
    def subscribe(cls, event, handler):
        if event not in cls._handlers:
            cls._handlers[event] = []
        cls._handlers[event].append(handler)
    
    @classmethod
    def publish(cls, event, data):
        if event in cls._handlers:
            for handler in cls._handlers[event]:
                handler(data)
```

### Hexagonal Architecture (Ports & Adapters)

Separating the core domain logic from external dependencies.

```python
# Hexagonal Architecture Example

# Domain Layer (Core)
class Task:
    """Domain entity - no external dependencies."""
    
    def __init__(self, title, description, priority):
        self.id = None
        self.title = title
        self.description = description
        self.priority = priority
        self.status = 'pending'
        self.created_at = datetime.utcnow()
    
    def complete(self):
        """Domain logic."""
        self.status = 'completed'
        self.completed_at = datetime.utcnow()
    
    def archive(self):
        self.status = 'archived'

# Ports (Interfaces)
class TaskRepositoryPort:
    """Interface for task persistence."""
    
    def save(self, task):
        raise NotImplementedError
    
    def get(self, task_id):
        raise NotImplementedError
    
    def delete(self, task_id):
        raise NotImplementedError

class NotificationPort:
    """Interface for notifications."""
    
    def send(self, recipient, message):
        raise NotImplementedError

# Adapters (Implementations)
class SQLAlchemyTaskRepository(TaskRepositoryPort):
    """SQLAlchemy implementation of task repository."""
    
    def save(self, task):
        db.session.add(task)
        db.session.commit()
    
    def get(self, task_id):
        return Task.query.get(task_id)
    
    def delete(self, task_id):
        task = self.get(task_id)
        if task:
            db.session.delete(task)
            db.session.commit()

class EmailNotificationAdapter(NotificationPort):
    """Email notification implementation."""
    
    def send(self, recipient, message):
        send_email(recipient, "Task Notification", message)

class SlackNotificationAdapter(NotificationPort):
    """Slack notification implementation."""
    
    def send(self, recipient, message):
        send_slack_message(recipient, message)

# Application Service
class TaskService:
    """Application service using ports."""
    
    def __init__(self, repository, notification):
        self.repository = repository
        self.notification = notification
    
    def complete_task(self, task_id, user):
        task = self.repository.get(task_id)
        task.complete()
        self.repository.save(task)
        self.notification.send(
            user.email,
            f"Task {task.title} completed"
        )
        return task

# Dependency Injection
def configure_services():
    """Configure services with dependencies."""
    repository = SQLAlchemyTaskRepository()
    notification = EmailNotificationAdapter()
    task_service = TaskService(repository, notification)
    return task_service
```

### Command-Query Responsibility Segregation (CQRS)

Separating read and write operations.

```python
# CQRS Pattern

# Commands (Write operations)
class CreateTaskCommand:
    def __init__(self, title, description, user_id):
        self.title = title
        self.description = description
        self.user_id = user_id

class CompleteTaskCommand:
    def __init__(self, task_id):
        self.task_id = task_id

# Command Handlers
class CreateTaskHandler:
    def handle(self, command):
        task = Task(
            title=command.title,
            description=command.description,
            user_id=command.user_id
        )
        db.session.add(task)
        db.session.commit()
        return task.id

class CompleteTaskHandler:
    def handle(self, command):
        task = Task.query.get(command.task_id)
        task.status = 'completed'
        db.session.commit()

# Queries (Read operations)
class GetUserTasksQuery:
    def __init__(self, user_id, filters=None):
        self.user_id = user_id
        self.filters = filters or {}

class GetTaskQuery:
    def __init__(self, task_id):
        self.task_id = task_id

# Query Handlers
class GetUserTasksHandler:
    def handle(self, query):
        tasks = Task.query.filter_by(user_id=query.user_id)
        if query.filters.get('status'):
            tasks = tasks.filter_by(status=query.filters['status'])
        return tasks.all()

class GetTaskHandler:
    def handle(self, query):
        return Task.query.get(query.task_id)

# Command/Query Bus
class Bus:
    """Simple command/query bus."""
    
    def __init__(self):
        self.command_handlers = {}
        self.query_handlers = {}
    
    def register_command(self, command_class, handler):
        self.command_handlers[command_class] = handler
    
    def register_query(self, query_class, handler):
        self.query_handlers[query_class] = handler
    
    def execute(self, command_or_query):
        handler = self.command_handlers.get(type(command_or_query))
        if handler:
            return handler().handle(command_or_query)
        
        handler = self.query_handlers.get(type(command_or_query))
        if handler:
            return handler().handle(command_or_query)
        
        raise ValueError(f"No handler found for {type(command_or_query)}")

# Usage in route
@app.route('/tasks', methods=['POST'])
def create_task():
    command = CreateTaskCommand(
        title=request.json['title'],
        description=request.json.get('description'),
        user_id=current_user.id
    )
    task_id = bus.execute(command)
    return jsonify({'id': task_id}), 201

@app.route('/tasks')
def list_tasks():
    query = GetUserTasksQuery(
        user_id=current_user.id,
        filters={'status': request.args.get('status')}
    )
    tasks = bus.execute(query)
    return jsonify([task.to_dict() for task in tasks])
```

---

## 3. Database Patterns

### Active Record vs Data Mapper

```python
# Active Record Pattern (Flask-SQLAlchemy default)
class Task(db.Model):
    """Active Record - object manages its own persistence."""
    
    __tablename__ = 'tasks'
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(200))
    
    def save(self):
        db.session.add(self)
        db.session.commit()
    
    def delete(self):
        db.session.delete(self)
        db.session.commit()
    
    @classmethod
    def find_by_title(cls, title):
        return cls.query.filter_by(title=title).first()

# Usage
task = Task(title="My Task")
task.save()
task = Task.find_by_title("My Task")

# Data Mapper Pattern (Clean architecture)
class TaskMapper:
    """Data Mapper - separates domain objects from persistence."""
    
    @staticmethod
    def to_domain(model):
        """Convert SQLAlchemy model to domain object."""
        return TaskDomain(
            id=model.id,
            title=model.title,
            description=model.description,
            status=model.status
        )
    
    @staticmethod
    def to_model(domain):
        """Convert domain object to SQLAlchemy model."""
        model = Task.query.get(domain.id) or Task()
        model.title = domain.title
        model.description = domain.description
        model.status = domain.status
        return model

# Domain object (no persistence logic)
class TaskDomain:
    def __init__(self, id=None, title='', description='', status='pending'):
        self.id = id
        self.title = title
        self.description = description
        self.status = status
    
    def complete(self):
        self.status = 'completed'

# Usage in service
def update_task(task_id, data):
    # Load domain object
    model = Task.query.get(task_id)
    domain = TaskMapper.to_domain(model)
    
    # Apply business logic
    if data.get('complete'):
        domain.complete()
    
    # Save back
    model = TaskMapper.to_model(domain)
    db.session.commit()
```

### Specification Pattern

Encapsulating business rules.

```python
class Specification:
    """Base specification class."""
    
    def is_satisfied_by(self, candidate):
        raise NotImplementedError
    
    def and_(self, other):
        return AndSpecification(self, other)
    
    def or_(self, other):
        return OrSpecification(self, other)
    
    def not_(self):
        return NotSpecification(self)

class AndSpecification(Specification):
    def __init__(self, left, right):
        self.left = left
        self.right = right
    
    def is_satisfied_by(self, candidate):
        return self.left.is_satisfied_by(candidate) and self.right.is_satisfied_by(candidate)

class OrSpecification(Specification):
    def __init__(self, left, right):
        self.left = left
        self.right = right
    
    def is_satisfied_by(self, candidate):
        return self.left.is_satisfied_by(candidate) or self.right.is_satisfied_by(candidate)

class NotSpecification(Specification):
    def __init__(self, spec):
        self.spec = spec
    
    def is_satisfied_by(self, candidate):
        return not self.spec.is_satisfied_by(candidate)

# Concrete specifications
class TaskIsCompletedSpecification(Specification):
    def is_satisfied_by(self, task):
        return task.status == 'completed'

class TaskIsOverdueSpecification(Specification):
    def is_satisfied_by(self, task):
        return task.due_date and task.due_date < datetime.utcnow()

class TaskIsHighPrioritySpecification(Specification):
    def is_satisfied_by(self, task):
        return task.priority == 'high'

# Usage with Query
class TaskSpecification:
    """Convert specifications to SQLAlchemy queries."""
    
    @staticmethod
    def to_query(spec):
        if isinstance(spec, TaskIsCompletedSpecification):
            return Task.status == 'completed'
        elif isinstance(spec, TaskIsOverdueSpecification):
            return Task.due_date < datetime.utcnow()
        elif isinstance(spec, TaskIsHighPrioritySpecification):
            return Task.priority == 'high'
        elif isinstance(spec, AndSpecification):
            return and_(
                TaskSpecification.to_query(spec.left),
                TaskSpecification.to_query(spec.right)
            )
        elif isinstance(spec, OrSpecification):
            return or_(
                TaskSpecification.to_query(spec.left),
                TaskSpecification.to_query(spec.right)
            )
        elif isinstance(spec, NotSpecification):
            return not_(TaskSpecification.to_query(spec.spec))
        else:
            raise ValueError(f"Unknown specification: {spec}")

# Usage
completed = TaskIsCompletedSpecification()
overdue = TaskIsOverdueSpecification()
high_priority = TaskIsHighPrioritySpecification()

# Complex rule: (Completed OR Overdue) AND NOT HighPriority
spec = (completed.or_(overdue)).and_(high_priority.not_())

# Apply to query
query = Task.query.filter(TaskSpecification.to_query(spec))
results = query.all()
```

### Unit of Work Pattern

Managing transactions and change tracking.

```python
class UnitOfWork:
    """Unit of Work for managing transactions."""
    
    def __init__(self):
        self.session = db.session
    
    def __enter__(self):
        return self
    
    def __exit__(self, exc_type, exc_val, exc_tb):
        if exc_type is None:
            self.commit()
        else:
            self.rollback()
    
    def commit(self):
        self.session.commit()
    
    def rollback(self):
        self.session.rollback()
    
    def mark_dirty(self, obj):
        self.session.add(obj)
    
    def get_repository(self):
        return TaskUnitOfWorkRepository(self)

class TaskUnitOfWorkRepository:
    """Repository using Unit of Work."""
    
    def __init__(self, uow):
        self.uow = uow
    
    def add(self, task):
        self.uow.session.add(task)
        self.uow.session.flush()
    
    def get(self, task_id):
        return Task.query.get(task_id)
    
    def update(self, task):
        self.uow.session.merge(task)
    
    def delete(self, task):
        self.uow.session.delete(task)

# Usage
def transfer_task(user_id, task_id, new_owner_id):
    with UnitOfWork() as uow:
        repo = uow.get_repository()
        
        # Get tasks
        task = repo.get(task_id)
        if not task or task.user_id != user_id:
            raise ValueError("Task not found")
        
        # Update ownership
        old_owner = task.user
        task.user_id = new_owner_id
        repo.update(task)
        
        # Log ownership change
        audit = AuditLog(
            action='transfer',
            details=f"Task {task_id} moved from {old_owner.id} to {new_owner_id}"
        )
        repo.add(audit)
        
        # Commit all changes atomically
        uow.commit()
```

---

## 4. API Design Patterns

### Versioning Strategies

```python
# URL Versioning (Most Common)
api_bp = Blueprint('api', __name__, url_prefix='/api')
api_bp.register_blueprint(v1_bp, url_prefix='/v1')
api_bp.register_blueprint(v2_bp, url_prefix='/v2')

# Header Versioning
@app.route('/api/tasks')
def get_tasks():
    version = request.headers.get('API-Version', '1.0')
    if version == '2.0':
        return handle_v2_tasks()
    return handle_v1_tasks()

# Query Parameter Versioning
@app.route('/api/tasks')
def get_tasks():
    version = request.args.get('version', '1.0')
    if version == '2.0':
        return handle_v2_tasks()
    return handle_v1_tasks()

# Content Negotiation (Accept header)
@app.route('/api/tasks')
def get_tasks():
    best = request.accept_mimetypes.best_match(['application/vnd.taskflow.v1+json', 'application/vnd.taskflow.v2+json'])
    if best == 'application/vnd.taskflow.v2+json':
        return handle_v2_tasks()
    return handle_v1_tasks()
```

### HATEOAS Implementation

```python
class HATEOASResponse:
    """HATEOAS response builder."""
    
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
    response.add_link('collection', url_for('list_tasks'))
    response.add_link('update', url_for('update_task', task_id=task.id), method='PUT')
    response.add_link('delete', url_for('delete_task', task_id=task.id), method='DELETE')
    response.add_link('user', url_for('get_user', user_id=task.user_id))
    
    return jsonify(response.to_dict())
```

### Bulk Operations Pattern

```python
class BulkOperation:
    """Handles bulk operations on resources."""
    
    def __init__(self, resource_class):
        self.resource_class = resource_class
    
    def create(self, items):
        """Bulk create."""
        results = []
        for item in items:
            try:
                obj = self.resource_class(**item)
                db.session.add(obj)
                results.append({'status': 'success', 'id': obj.id})
            except Exception as e:
                results.append({'status': 'error', 'error': str(e)})
        db.session.commit()
        return results
    
    def update(self, items):
        """Bulk update."""
        results = []
        for item in items:
            try:
                obj = self.resource_class.query.get(item['id'])
                if obj:
                    for key, value in item.items():
                        if key != 'id':
                            setattr(obj, key, value)
                    results.append({'status': 'success', 'id': obj.id})
                else:
                    results.append({'status': 'error', 'id': item['id'], 'error': 'Not found'})
            except Exception as e:
                results.append({'status': 'error', 'id': item.get('id'), 'error': str(e)})
        db.session.commit()
        return results
    
    def delete(self, ids):
        """Bulk delete."""
        results = []
        for id in ids:
            try:
                obj = self.resource_class.query.get(id)
                if obj:
                    db.session.delete(obj)
                    results.append({'status': 'success', 'id': id})
                else:
                    results.append({'status': 'error', 'id': id, 'error': 'Not found'})
            except Exception as e:
                results.append({'status': 'error', 'id': id, 'error': str(e)})
        db.session.commit()
        return results

# Usage
@app.route('/api/tasks/bulk', methods=['POST'])
def bulk_tasks():
    operation = request.json.get('operation')
    data = request.json.get('data')
    
    bulk = BulkOperation(Task)
    
    if operation == 'create':
        results = bulk.create(data)
    elif operation == 'update':
        results = bulk.update(data)
    elif operation == 'delete':
        results = bulk.delete(data)
    else:
        return jsonify({'error': 'Invalid operation'}), 400
    
    return jsonify({'results': results})
```

---

## 5. Authentication & Authorization Patterns

### Role-Based Access Control (RBAC)

```python
# RBAC Implementation
class Role:
    """Role definition."""
    
    def __init__(self, name, permissions=None):
        self.name = name
        self.permissions = permissions or set()
    
    def has_permission(self, permission):
        return permission in self.permissions

class User:
    """User with roles."""
    
    def __init__(self, username):
        self.username = username
        self.roles = set()
    
    def add_role(self, role):
        self.roles.add(role)
    
    def has_permission(self, permission):
        return any(role.has_permission(permission) for role in self.roles)

# Define roles
admin_role = Role('admin', {'create', 'read', 'update', 'delete', 'manage_users'})
manager_role = Role('manager', {'create', 'read', 'update', 'delete'})
user_role = Role('user', {'create', 'read', 'update'})
viewer_role = Role('viewer', {'read'})

# Permission decorator
def permission_required(permission):
    """Decorator to check permissions."""
    def decorator(f):
        @wraps(f)
        def decorated(*args, **kwargs):
            if not hasattr(g, 'user') or not g.user.has_permission(permission):
                abort(403)
            return f(*args, **kwargs)
        return decorated
    return decorator

# Usage
@app.route('/api/tasks')
@permission_required('read')
def list_tasks():
    return jsonify(Task.query.all())

@app.route('/api/tasks', methods=['POST'])
@permission_required('create')
def create_task():
    return jsonify({'message': 'Task created'})

@app.route('/api/admin/users')
@permission_required('manage_users')
def manage_users():
    return jsonify(User.query.all())
```

### Access Control List (ACL)

```python
# ACL Implementation
class ACL:
    """Access Control List."""
    
    def __init__(self):
        self.rules = {}
    
    def add_rule(self, resource, user, permission):
        if resource not in self.rules:
            self.rules[resource] = {}
        if user not in self.rules[resource]:
            self.rules[resource][user] = set()
        self.rules[resource][user].add(permission)
    
    def check_permission(self, resource, user, permission):
        if resource not in self.rules:
            return False
        if user not in self.rules[resource]:
            return False
        return permission in self.rules[resource][user]

# Resource-based authorization
class TaskACL:
    """Task-specific ACL."""
    
    @staticmethod
    def can_view(user, task):
        """Check if user can view task."""
        if user.is_admin:
            return True
        if task.user_id == user.id:
            return True
        if task.assigned_to_id == user.id:
            return True
        return False
    
    @staticmethod
    def can_edit(user, task):
        """Check if user can edit task."""
        if user.is_admin:
            return True
        if task.user_id == user.id:
            return True
        return False
    
    @staticmethod
    def can_delete(user, task):
        """Check if user can delete task."""
        if user.is_admin:
            return True
        return task.user_id == user.id

# Usage in routes
@app.route('/tasks/<int:task_id>')
@login_required
def view_task(task_id):
    task = Task.query.get_or_404(task_id)
    if not TaskACL.can_view(current_user, task):
        abort(403)
    return render_template('task.html', task=task)
```

### Policy-Based Access Control (PBAC)

```python
# Policy-Based Access Control
class Policy:
    """Policy definition."""
    
    def __init__(self, name, condition, effect):
        self.name = name
        self.condition = condition  # Function that returns boolean
        self.effect = effect  # 'allow' or 'deny'

class PolicyEnforcer:
    """Enforce policies."""
    
    def __init__(self):
        self.policies = []
    
    def add_policy(self, policy):
        self.policies.append(policy)
    
    def evaluate(self, context):
        """Evaluate all policies."""
        for policy in self.policies:
            if policy.condition(context):
                return policy.effect == 'allow'
        return False  # Default deny

# Define policies
def create_task_policies():
    policies = [
        Policy(
            'user_can_create_task',
            lambda ctx: ctx['user'].is_authenticated,
            'allow'
        ),
        Policy(
            'admin_can_do_anything',
            lambda ctx: ctx['user'].is_admin,
            'allow'
        ),
        Policy(
            'manager_can_create_for_team',
            lambda ctx: ctx['user'].is_manager and ctx.get('assigned_to') in ctx['user'].team,
            'allow'
        ),
        Policy(
            'deny_guest_create',
            lambda ctx: not ctx['user'].is_authenticated,
            'deny'
        ),
    ]
    return policies

# Usage
enforcer = PolicyEnforcer()
for policy in create_task_policies():
    enforcer.add_policy(policy)

@app.route('/tasks', methods=['POST'])
@login_required
def create_task():
    context = {
        'user': current_user,
        'assigned_to': request.json.get('assigned_to_id'),
        'priority': request.json.get('priority'),
    }
    
    if not enforcer.evaluate(context):
        abort(403, description="Policy violation")
    
    # Create task...
```

---

## 6. Testing Patterns

### Test Data Builders

```python
class TaskBuilder:
    """Builder pattern for test data."""
    
    def __init__(self):
        self.task = {
            'title': 'Default Task',
            'description': 'Default description',
            'priority': 'medium',
            'status': 'pending',
            'user_id': 1,
        }
    
    def with_title(self, title):
        self.task['title'] = title
        return self
    
    def with_description(self, description):
        self.task['description'] = description
        return self
    
    def with_priority(self, priority):
        self.task['priority'] = priority
        return self
    
    def with_status(self, status):
        self.task['status'] = status
        return self
    
    def with_user(self, user_id):
        self.task['user_id'] = user_id
        return self
    
    def with_due_date(self, due_date):
        self.task['due_date'] = due_date
        return self
    
    def build(self):
        return self.task
    
    def create(self):
        """Create and save the task."""
        task = Task(**self.task)
        db.session.add(task)
        db.session.commit()
        return task

# Usage in tests
def test_task_creation():
    task = TaskBuilder() \
        .with_title("Test Task") \
        .with_priority("high") \
        .with_status("pending") \
        .create()
    
    assert task.title == "Test Task"
    assert task.priority == "high"
```

### Mock Patterns

```python
# Using pytest-mock
def test_task_service(mocker):
    # Mock repository
    mock_repo = mocker.Mock()
    mock_repo.get.return_value = Task(title="Test", user_id=1)
    
    # Mock notification
    mock_notify = mocker.Mock()
    
    # Create service with mocks
    service = TaskService(mock_repo, mock_notify)
    
    # Execute
    result = service.complete_task(1, User(id=1))
    
    # Verify
    assert result.status == "completed"
    mock_repo.save.assert_called_once()
    mock_notify.send.assert_called_once()

# Patch with context manager
def test_external_api():
    import requests
    from unittest.mock import patch
    
    with patch('requests.get') as mock_get:
        mock_get.return_value.status_code = 200
        mock_get.return_value.json.return_value = {'data': 'test'}
        
        result = call_external_api()
        assert result == {'data': 'test'}
```

### Testing Pyramid Patterns

```python
# Unit Test (fast, isolated)
class TestTaskModel:
    def test_task_complete(self):
        task = Task(title="Test")
        task.complete()
        assert task.status == "completed"
        assert task.completed_at is not None

# Integration Test (database, services)
class TestTaskService:
    def test_create_task(self, db_session, test_user):
        service = TaskService()
        task = service.create_task(
            user=test_user,
            title="Integration Test"
        )
        assert task.id is not None
        assert task.title == "Integration Test"

# Functional Test (full stack)
class TestTaskAPI:
    def test_create_task_endpoint(self, client, auth_headers):
        response = client.post('/api/tasks', 
            json={'title': 'API Test'},
            headers=auth_headers
        )
        assert response.status_code == 201
        data = response.json
        assert data['title'] == 'API Test'

# End-to-End Test (complete workflow)
class TestTaskWorkflow:
    def test_complete_workflow(self, client):
        # Login
        login_response = client.post('/auth/login', json={
            'email': 'test@example.com',
            'password': 'password'
        })
        token = login_response.json['access_token']
        headers = {'Authorization': f'Bearer {token}'}
        
        # Create task
        create_response = client.post('/api/tasks', 
            json={'title': 'E2E Test'},
            headers=headers
        )
        task_id = create_response.json['id']
        
        # Get task
        get_response = client.get(f'/api/tasks/{task_id}', headers=headers)
        assert get_response.json['title'] == 'E2E Test'
        
        # Complete task
        client.put(f'/api/tasks/{task_id}', 
            json={'status': 'completed'},
            headers=headers
        )
        
        # Verify completion
        get_response = client.get(f'/api/tasks/{task_id}', headers=headers)
        assert get_response.json['status'] == 'completed'
```

---

## 7. Common Anti-Patterns & Solutions

### Anti-Pattern: Fat Models

```python
# ❌ Anti-Pattern: Fat Model (too much logic)
class Task(db.Model):
    def validate(self):
        # 50 lines of validation
        
    def clean(self):
        # 30 lines of cleaning
        
    def format_for_api(self):
        # 40 lines of formatting
        
    def generate_report(self):
        # 100 lines of report generation
        
    def send_notification(self):
        # 50 lines of email logic
        
    def calculate_score(self):
        # 30 lines of business logic
        
    def export_to_csv(self):
        # 50 lines of CSV generation
        
    # Total: 350+ lines of logic in a model!

# ✅ Solution: Extract to services
class TaskValidator:
    @staticmethod
    def validate(task):
        # Validation logic

class TaskCleaner:
    @staticmethod
    def clean(task):
        # Cleaning logic

class TaskFormatter:
    @staticmethod
    def format_for_api(task):
        # Formatting logic

class TaskReportService:
    @staticmethod
    def generate_report(task):
        # Report generation

class NotificationService:
    @staticmethod
    def send_notification(task):
        # Notification logic

class TaskCalculator:
    @staticmethod
    def calculate_score(task):
        # Business logic

class TaskExporter:
    @staticmethod
    def export_to_csv(tasks):
        # CSV generation
```

### Anti-Pattern: View Containing Business Logic

```python
# ❌ Anti-Pattern: Business logic in routes
@app.route('/tasks/<int:task_id>/complete', methods=['POST'])
def complete_task(task_id):
    task = Task.query.get_or_404(task_id)
    
    # Business logic in route!
    if task.status == 'completed':
        flash('Task already completed')
        return redirect(url_for('tasks.view', task_id=task.id))
    
    if task.user_id != current_user.id and not current_user.is_admin:
        abort(403)
    
    task.status = 'completed'
    task.completed_at = datetime.utcnow()
    db.session.commit()
    
    # Email logic in route!
    user = User.query.get(task.user_id)
    send_email(user.email, 'Task Completed', f'Task {task.title} completed')
    
    # Logging in route!
    app.logger.info(f'Task {task.id} completed by {current_user.id}')
    
    # Audit in route!
    audit = AuditLog(action='complete', task_id=task.id)
    db.session.add(audit)
    db.session.commit()
    
    return jsonify({'message': 'Task completed'})

# ✅ Solution: Use service layer
@app.route('/tasks/<int:task_id>/complete', methods=['POST'])
def complete_task(task_id):
    try:
        TaskCompletionService.complete(task_id, current_user)
        return jsonify({'message': 'Task completed'})
    except PermissionError:
        abort(403)
    except ValueError as e:
        return jsonify({'error': str(e)}), 400

class TaskCompletionService:
    @staticmethod
    def complete(task_id, user):
        task = Task.query.get_or_404(task_id)
        
        if task.status == 'completed':
            raise ValueError('Task already completed')
        
        if task.user_id != user.id and not user.is_admin:
            raise PermissionError('Not authorized')
        
        task.status = 'completed'
        task.completed_at = datetime.utcnow()
        db.session.commit()
        
        # All side effects moved to services
        NotificationService.send_task_completed(task)
        LoggingService.log_task_action(task, user, 'complete')
        AuditService.record_action('complete', task_id, user)
```

### Anti-Pattern: Magic Numbers & Strings

```python
# ❌ Anti-Pattern: Magic values everywhere
def calculate_task_score(task):
    if task.priority == 1:  # Magic number: 1
        score = 100
    elif task.priority == 2:  # Magic number: 2
        score = 80
    elif task.priority == 3:  # Magic number: 3
        score = 60
    
    if task.status == 'active':  # Magic string
        score += 20
    
    return score

# ✅ Solution: Use constants/enums
class PriorityLevel:
    URGENT = 1
    HIGH = 2
    MEDIUM = 3
    LOW = 4
    
    WEIGHTS = {
        URGENT: 100,
        HIGH: 80,
        MEDIUM: 60,
        LOW: 40,
    }

class TaskStatus:
    PENDING = 'pending'
    IN_PROGRESS = 'in_progress'
    COMPLETED = 'completed'
    
    BONUS = {
        PENDING: 0,
        IN_PROGRESS: 20,
        COMPLETED: 30,
    }

def calculate_task_score(task):
    score = PriorityLevel.WEIGHTS.get(task.priority, 0)
    score += TaskStatus.BONUS.get(task.status, 0)
    return score
```

### Anti-Pattern: God Object

```python
# ❌ Anti-Pattern: God Object
class TaskManager:
    """Does everything - a God Object."""
    
    def __init__(self):
        self.tasks = []
    
    def create_task(self, title, description):
        pass
    
    def update_task(self, task_id, data):
        pass
    
    def delete_task(self, task_id):
        pass
    
    def get_tasks(self, filters):
        pass
    
    def generate_report(self, task_ids):
        pass
    
    def export_to_csv(self, task_ids):
        pass
    
    def send_notifications(self, task_ids):
        pass
    
    def calculate_statistics(self, tasks):
        pass
    
    def import_from_csv(self, file):
        pass
    
    def archive_old_tasks(self, days):
        pass
    
    def sync_with_calendar(self, task_ids):
        pass
    
    # 30+ methods!

# ✅ Solution: Single Responsibility Principle
class TaskRepository:
    """Manages task data access."""
    pass

class TaskService:
    """Manages task business logic."""
    pass

class TaskReportGenerator:
    """Generates task reports."""
    pass

class TaskExporter:
    """Exports task data."""
    pass

class NotificationService:
    """Sends task notifications."""
    pass

class TaskAnalytics:
    """Calculates task analytics."""
    pass

class TaskImporter:
    """Imports task data."""
    pass

class TaskArchiver:
    """Archives old tasks."""
    pass

class CalendarService:
    """Syncs with calendar."""
    pass
```

### Anti-Pattern: Premature Optimization

```python
# ❌ Anti-Pattern: Premature optimization
def get_user_tasks(user_id):
    # Starting with complex caching even though not needed
    cache_key = f"user_tasks_{user_id}"
    cached = redis.get(cache_key)
    if cached:
        return json.loads(cached)
    
    # Complex query optimization for 10 users
    tasks = Task.query \
        .options(joinedload(Task.user)) \
        .options(joinedload(Task.category)) \
        .options(joinedload(Task.tags)) \
        .filter_by(user_id=user_id) \
        .all()
    
    redis.setex(cache_key, 300, json.dumps([t.to_dict() for t in tasks]))
    return tasks

# ✅ Solution: Simple and clean, optimize when needed
def get_user_tasks(user_id):
    return Task.query.filter_by(user_id=user_id).all()

# Later, when needed:
def get_user_tasks_optimized(user_id):
    # Add caching only when performance becomes an issue
    # Add eager loading only when N+1 queries are detected
    pass
```

---

## 8. Refactoring Strategies

### Extract Service Layer

```python
# Before: Monolithic view
@app.route('/api/tasks', methods=['POST'])
def create_task():
    data = request.json
    # Validation
    if not data.get('title'):
        return jsonify({'error': 'Title required'}), 400
    
    # Create task
    task = Task(
        title=data['title'],
        description=data.get('description'),
        priority=data.get('priority', 'medium'),
        user_id=current_user.id
    )
    db.session.add(task)
    db.session.commit()
    
    # Process
    if data.get('assign_to'):
        task.assigned_to_id = data['assign_to']
        db.session.commit()
        # Send notification
        notify_user(task.assigned_to_id, task)
    
    # Return
    return jsonify(task.to_dict()), 201

# After: Service Layer
@app.route('/api/tasks', methods=['POST'])
def create_task():
    schema = TaskCreateSchema()
    try:
        data = schema.load(request.json)
        task = TaskService.create_task(current_user, data)
        return jsonify(TaskSchema().dump(task)), 201
    except ValidationError as e:
        return jsonify({'errors': e.messages}), 400
    except ValueError as e:
        return jsonify({'error': str(e)}), 400
```

### Extract Repository Layer

```python
# Before: Direct database access in service
class TaskService:
    @staticmethod
    def get_user_tasks(user_id):
        return Task.query.filter_by(user_id=user_id).all()
    
    @staticmethod
    def create_task(data):
        task = Task(**data)
        db.session.add(task)
        db.session.commit()
        return task

# After: Repository pattern
class TaskRepository:
    @staticmethod
    def get_user_tasks(user_id):
        return Task.query.filter_by(user_id=user_id).all()
    
    @staticmethod
    def create(data):
        task = Task(**data)
        db.session.add(task)
        db.session.commit()
        return task

class TaskService:
    def __init__(self, repository=None):
        self.repository = repository or TaskRepository()
    
    def get_user_tasks(self, user_id):
        return self.repository.get_user_tasks(user_id)
    
    def create_task(self, data):
        return self.repository.create(data)
```

### Extract Configuration

```python
# Before: Hardcoded config in code
class TaskService:
    def process_task(self, task):
        if task.priority == 'high':
            deadline = 24  # hours
        else:
            deadline = 72
        
        if len(task.title) > 100:
            task.title = task.title[:97] + '...'

# After: Configuration object
class TaskConfig:
    PRIORITY_DEADLINES = {
        'urgent': 12,
        'high': 24,
        'medium': 48,
        'low': 72,
    }
    TITLE_MAX_LENGTH = 100
    TITLE_SUFFIX = '...'

class TaskService:
    def __init__(self, config=None):
        self.config = config or TaskConfig()
    
    def process_task(self, task):
        deadline = self.config.PRIORITY_DEADLINES.get(task.priority, 72)
        
        if len(task.title) > self.config.TITLE_MAX_LENGTH:
            max_len = self.config.TITLE_MAX_LENGTH - len(self.config.TITLE_SUFFIX)
            task.title = task.title[:max_len] + self.config.TITLE_SUFFIX
```

---

## Summary

This appendix has covered advanced patterns and anti-patterns in Flask development:

1. **Design Patterns**: Singleton, Factory, Repository, Observer, Decorator
2. **Architecture Patterns**: Modular Monolith, Hexagonal, CQRS
3. **Database Patterns**: Active Record, Data Mapper, Specification, Unit of Work
4. **API Patterns**: Versioning, HATEOAS, Bulk Operations
5. **Auth Patterns**: RBAC, ACL, PBAC
6. **Testing Patterns**: Builders, Mocks, Testing Pyramid
7. **Anti-Patterns**: Fat Models, God Objects, Magic Numbers, Premature Optimization
8. **Refactoring**: Extract Service Layer, Repository, Configuration

**Key Takeaways**:
- Design patterns solve common problems
- Anti-patterns are traps to avoid
- Refactoring improves code quality
- Testing patterns ensure reliability
- Architecture patterns guide structure
