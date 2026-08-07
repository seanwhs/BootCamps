# Primer 2: Flask Database & ORM Primer

Welcome to Primer 2! This foundational primer is designed for beginners who want to understand how Flask applications work with databases. Building on the basics from Primer 1, you'll learn how to store, retrieve, and manage data in your Flask applications.

---

## Table of Contents

1. [Why Databases Matter](#1-why-databases-matter)
2. [Understanding Databases](#2-understanding-databases)
3. [SQLAlchemy ORM Basics](#3-sqlalchemy-orm-basics)
4. [Working with Models](#4-working-with-models)
5. [CRUD Operations](#5-crud-operations)
6. [Relationships Between Models](#6-relationships-between-models)
7. [Querying Data](#7-querying-data)
8. [Database Migrations](#8-database-migrations)
9. [Putting It All Together](#9-putting-it-all-together)
10. [Next Steps](#10-next-steps)

---

## 1. Why Databases Matter

### The Problem: Ephemeral Data

Without a database, your application's data disappears when the server restarts:

```python
# ❌ Without a database - data is lost
tasks = []  # This list is empty every time the app starts

@app.route('/add-task', methods=['POST'])
def add_task():
    title = request.form.get('title')
    tasks.append(title)  # Data only exists in memory
    return 'Task added!'
    
# If the server restarts, all tasks are gone!
```

### The Solution: Persistent Storage

A database stores data permanently:

```
┌─────────────────────────────────────────────────────────────┐
│                    Flask Application                        │
│  - Handles requests                                        │
│  - Processes data                                          │
│  - Renders templates                                       │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────┐
│                    Database                                 │
│  - Stores data permanently                                 │
│  - Survives server restarts                                │
│  - Can be backed up                                        │
│  - Handles large amounts of data                           │
└─────────────────────────────────────────────────────────────┘
```

### Why Flask + SQLAlchemy?

Flask doesn't have a built-in database. Instead, we use **SQLAlchemy**:

```
SQLAlchemy = A translator between Python and databases

Your Python Code
       ↓
SQLAlchemy (Translator)
       ↓
Database (SQL)
```

**Analogy**: SQLAlchemy is like an interpreter. You speak Python (your code), SQLAlchemy translates it to SQL (the database's language), and the database understands.

---

## 2. Understanding Databases

### What is a Database?

A database is an organized collection of data. Think of it like a digital filing cabinet:

```
Database = The entire filing cabinet
  Table = A drawer in the cabinet (e.g., "Users")
    Row = A single file (e.g., one user)
      Column = Information in the file (e.g., name, email)
```

### Database Types

```python
# Two main types of databases:

# 1. SQL Databases (Relational)
#    - Data organized in tables with relationships
#    - Examples: SQLite, PostgreSQL, MySQL
#    - Best for: Structured data, complex queries

# 2. NoSQL Databases (Non-relational)
#    - Data stored as documents or key-value pairs
#    - Examples: MongoDB, Redis
#    - Best for: Unstructured data, high scale

# Flask typically uses SQL databases (PostgreSQL for production, SQLite for development)
```

### Tables and Relationships

```python
# Example: Task Management System

# Users Table
# ┌────┬──────────┬─────────────────┐
# │ id │ username │     email       │
# ├────┼──────────┼─────────────────┤
# │ 1  │ john     │ john@email.com  │
# │ 2  │ jane     │ jane@email.com  │
# └────┴──────────┴─────────────────┘

# Tasks Table
# ┌────┬───────────────┬──────────┬─────────┐
# │ id │    title      │  status  │ user_id │
# ├────┼───────────────┼──────────┼─────────┤
# │ 1  │ Learn Flask   │ pending  │    1    │
# │ 2  │ Build app     │ complete │    1    │
# │ 3  │ Write tests   │ pending  │    2    │
# └────┴───────────────┴──────────┴─────────┘

# Relationships:
# - A User can have many Tasks (One-to-Many)
# - Each Task belongs to one User (Many-to-One)
```

### Setting Up SQLAlchemy

```bash
# Install Flask-SQLAlchemy
pip install flask-sqlalchemy
```

```python
from flask import Flask
from flask_sqlalchemy import SQLAlchemy

app = Flask(__name__)

# Configure database
# SQLite (development) - file-based database
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///database.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

# Create database object
db = SQLAlchemy(app)
```

---

## 3. SQLAlchemy ORM Basics

### What is ORM?

**ORM** (Object-Relational Mapping) = Mapping Python objects to database tables

```
Python Object (Model)    ↔    Database Table
User(username='john')    ↔    INSERT INTO users (username) VALUES ('john')
```

### Creating a Model

A model is a Python class that represents a database table:

```python
from datetime import datetime

class User(db.Model):
    # Table name
    __tablename__ = 'users'
    
    # Columns = attributes
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(50), unique=True, nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    # Optional: string representation
    def __repr__(self):
        return f'<User {self.username}>'
```

### Understanding Column Types

```python
# Common Column Types

# Numeric
id = db.Column(db.Integer)      # Whole numbers
age = db.Column(db.Integer)
price = db.Column(db.Float)     # Decimal numbers
rating = db.Column(db.Float)

# String
name = db.Column(db.String(50))  # Limited text (50 characters)
bio = db.Column(db.Text)         # Unlimited text

# Boolean
is_active = db.Column(db.Boolean)

# Date/Time
created_at = db.Column(db.DateTime)
birthday = db.Column(db.Date)

# Relationships
user_id = db.Column(db.Integer, db.ForeignKey('users.id'))
```

### Column Options

```python
# Important Column Options

# Primary Key
id = db.Column(db.Integer, primary_key=True)

# Unique (no duplicates)
email = db.Column(db.String(120), unique=True)

# Not Null (must have a value)
username = db.Column(db.String(50), nullable=False)

# Default Value
created_at = db.Column(db.DateTime, default=datetime.utcnow)
is_active = db.Column(db.Boolean, default=True)

# Auto-increment (automatic for primary keys)
id = db.Column(db.Integer, primary_key=True)
```

### Creating the Database

```python
# Create all tables
with app.app_context():
    db.create_all()
    print("Database created!")

# Check if tables exist
# You should see: users table created
```

---

## 4. Working with Models

### Defining a Task Model

Let's create a complete model for tasks:

```python
# models.py
from datetime import datetime
from flask_sqlalchemy import SQLAlchemy

db = SQLAlchemy()

class User(db.Model):
    __tablename__ = 'users'
    
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(50), unique=True, nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    def __repr__(self):
        return f'<User {self.username}>'
    
    def to_dict(self):
        """Convert user to dictionary for API responses"""
        return {
            'id': self.id,
            'username': self.username,
            'email': self.email,
            'created_at': self.created_at.isoformat()
        }

class Task(db.Model):
    __tablename__ = 'tasks'
    
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(200), nullable=False)
    description = db.Column(db.Text)
    status = db.Column(db.String(20), default='pending')
    priority = db.Column(db.String(20), default='medium')
    due_date = db.Column(db.DateTime)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Foreign Key - Links to User
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    
    # Relationship - Access user from task
    user = db.relationship('User', backref='tasks')
    
    def __repr__(self):
        return f'<Task {self.title}>'
    
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
            'username': self.user.username if self.user else None
        }
```

### Register Models with App

```python
# app.py
from flask import Flask
from models import db, User, Task

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///database.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

db.init_app(app)

# Create tables
with app.app_context():
    db.create_all()
```

---

## 5. CRUD Operations

### What is CRUD?

CRUD = **C**reate, **R**ead, **U**pdate, **D**elete

These are the four basic operations you can perform on data:

```
CREATE  → Insert new data
READ    → Retrieve data
UPDATE  → Modify existing data
DELETE  → Remove data
```

### CREATE - Adding Data

```python
# Creating a single user
user = User(username='john', email='john@example.com')
db.session.add(user)
db.session.commit()

# Creating multiple users
users = [
    User(username='jane', email='jane@example.com'),
    User(username='bob', email='bob@example.com')
]
db.session.add_all(users)
db.session.commit()

# Creating a task for a user
user = User.query.first()  # Get first user
task = Task(
    title='Learn Flask',
    description='Complete the Flask tutorial',
    user_id=user.id
)
db.session.add(task)
db.session.commit()

# Creating with relationship
user = User.query.first()
task = Task(title='Build a web app', user=user)  # Automatic user_id
db.session.add(task)
db.session.commit()
```

### READ - Retrieving Data

```python
# Get all records
users = User.query.all()
tasks = Task.query.all()

# Get first record
first_user = User.query.first()

# Get by ID (returns None if not found)
user = User.query.get(1)

# Get by ID or 404 (raises 404 if not found)
user = User.query.get_or_404(1)

# Filter by condition
users = User.query.filter_by(username='john').all()

# Filter with conditions
users = User.query.filter(User.username == 'john').all()
tasks = Task.query.filter(Task.status == 'pending').all()

# Multiple conditions
tasks = Task.query.filter(
    Task.status == 'pending',
    Task.priority == 'high'
).all()

# Order by
users = User.query.order_by(User.username.asc()).all()
users = User.query.order_by(User.created_at.desc()).all()

# Limit and offset
users = User.query.limit(10).offset(20).all()

# Count
user_count = User.query.count()
pending_tasks = Task.query.filter_by(status='pending').count()

# Check if exists
has_users = User.query.first() is not None
```

### UPDATE - Modifying Data

```python
# Update a single record
user = User.query.get(1)
user.username = 'john_doe'
db.session.commit()

# Update multiple fields
task = Task.query.get(1)
task.status = 'completed'
task.priority = 'high'
db.session.commit()

# Bulk update
Task.query.filter_by(status='pending').update({'priority': 'urgent'})
db.session.commit()

# Update using data from request
@app.route('/user/<int:user_id>/update', methods=['POST'])
def update_user(user_id):
    user = User.query.get_or_404(user_id)
    user.username = request.form.get('username', user.username)
    user.email = request.form.get('email', user.email)
    db.session.commit()
    return 'User updated!'
```

### DELETE - Removing Data

```python
# Delete a single record
user = User.query.get(1)
db.session.delete(user)
db.session.commit()

# Delete with condition
Task.query.filter_by(status='archived').delete()
db.session.commit()

# Delete all records (use with caution!)
User.query.delete()
db.session.commit()

# Delete with cascade (automatically deletes related records)
# If you have cascade=True on a relationship:
task = Task.query.get(1)
db.session.delete(task)  # Deletes task and all related comments
db.session.commit()
```

### Complete CRUD Example

```python
# app.py - Complete CRUD for tasks

from flask import Flask, request, render_template, redirect, flash
from models import db, Task, User

app = Flask(__name__)
app.secret_key = 'your-secret-key'

# CREATE
@app.route('/tasks/create', methods=['GET', 'POST'])
def create_task():
    if request.method == 'POST':
        title = request.form.get('title')
        description = request.form.get('description')
        user_id = request.form.get('user_id')
        
        task = Task(
            title=title,
            description=description,
            user_id=user_id
        )
        db.session.add(task)
        db.session.commit()
        
        flash('Task created successfully!', 'success')
        return redirect('/tasks')
    
    users = User.query.all()
    return render_template('create_task.html', users=users)

# READ (List)
@app.route('/tasks')
def list_tasks():
    # Get filter from URL
    status = request.args.get('status')
    
    if status:
        tasks = Task.query.filter_by(status=status).all()
    else:
        tasks = Task.query.all()
    
    return render_template('tasks.html', tasks=tasks)

# READ (Single)
@app.route('/tasks/<int:task_id>')
def view_task(task_id):
    task = Task.query.get_or_404(task_id)
    return render_template('task_detail.html', task=task)

# UPDATE
@app.route('/tasks/<int:task_id>/edit', methods=['GET', 'POST'])
def edit_task(task_id):
    task = Task.query.get_or_404(task_id)
    
    if request.method == 'POST':
        task.title = request.form.get('title', task.title)
        task.description = request.form.get('description', task.description)
        task.status = request.form.get('status', task.status)
        task.priority = request.form.get('priority', task.priority)
        
        db.session.commit()
        flash('Task updated!', 'success')
        return redirect(f'/tasks/{task.id}')
    
    return render_template('edit_task.html', task=task)

# DELETE
@app.route('/tasks/<int:task_id>/delete', methods=['POST'])
def delete_task(task_id):
    task = Task.query.get_or_404(task_id)
    db.session.delete(task)
    db.session.commit()
    
    flash('Task deleted!', 'success')
    return redirect('/tasks')
```

---

## 6. Relationships Between Models

### Understanding Relationships

Relationships connect different tables together:

```
One-to-Many: One User → Many Tasks
Many-to-One: Many Tasks → One User
Many-to-Many: Many Users → Many Projects (through a join table)
One-to-One: One User → One Profile
```

### One-to-Many Relationship

```python
class User(db.Model):
    __tablename__ = 'users'
    
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(50), unique=True)
    
    # One-to-Many: A user has many tasks
    tasks = db.relationship('Task', back_populates='user')

class Task(db.Model):
    __tablename__ = 'tasks'
    
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(200))
    
    # Many-to-One: A task belongs to one user
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'))
    user = db.relationship('User', back_populates='tasks')

# Usage
user = User(username='john')
task1 = Task(title='Task 1', user=user)
task2 = Task(title='Task 2', user=user)

# Access tasks from user
user.tasks  # → [Task('Task 1'), Task('Task 2')]

# Access user from task
task1.user  # → User('john')
```

### Many-to-Many Relationship

```python
# Association table (links tasks and tags)
task_tags = db.Table('task_tags',
    db.Column('task_id', db.Integer, db.ForeignKey('tasks.id')),
    db.Column('tag_id', db.Integer, db.ForeignKey('tags.id'))
)

class Task(db.Model):
    __tablename__ = 'tasks'
    
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(200))
    
    # Many-to-Many: A task can have many tags
    tags = db.relationship('Tag', secondary=task_tags, back_populates='tasks')

class Tag(db.Model):
    __tablename__ = 'tags'
    
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(50), unique=True)
    
    # Many-to-Many: A tag can belong to many tasks
    tasks = db.relationship('Task', secondary=task_tags, back_populates='tags')

# Usage
task = Task(title='Web Development')
tag1 = Tag(name='python')
tag2 = Tag(name='flask')

task.tags.append(tag1)
task.tags.append(tag2)

# Access tags from task
task.tags  # → [Tag('python'), Tag('flask')]

# Access tasks from tag
tag1.tasks  # → [Task('Web Development')]
```

### Relationship Options

```python
# Useful options for relationships

# Cascade - automatically handle related records
tasks = db.relationship('Task', cascade='all, delete-orphan')

# Lazy Loading - when to load related data
# lazy='select' (default) - load when accessed
# lazy='joined' - load immediately with join
# lazy='dynamic' - returns a query object
tasks = db.relationship('Task', lazy='dynamic')

# Backref - creates reverse relationship
tasks = db.relationship('Task', backref='user')

# On Delete
user_id = db.Column(db.Integer, db.ForeignKey('users.id', ondelete='CASCADE'))

# Useful examples
class User(db.Model):
    # Tasks will be deleted when user is deleted
    tasks = db.relationship('Task', cascade='all, delete-orphan')
    
    # Dynamic relationship for filtered queries
    tasks_query = db.relationship('Task', lazy='dynamic')

# Dynamic relationship usage
user = User.query.get(1)
pending_tasks = user.tasks_query.filter_by(status='pending').all()
```

---

## 7. Querying Data

### Basic Queries

```python
# All records
users = User.query.all()

# First record
user = User.query.first()

# Get by ID
user = User.query.get(1)

# Filter by exact match
users = User.query.filter_by(username='john').all()

# Filter with conditions
from sqlalchemy import or_, and_, not_

# OR condition
users = User.query.filter(
    or_(User.username == 'john', User.username == 'jane')
).all()

# AND condition (default)
users = User.query.filter(
    User.username == 'john',
    User.is_active == True
).all()

# NOT condition
users = User.query.filter(
    not_(User.username == 'john')
).all()

# Contains / Like
users = User.query.filter(User.username.like('%jo%')).all()

# Case-insensitive contains
users = User.query.filter(User.username.ilike('%jo%')).all()

# In list
users = User.query.filter(User.username.in_(['john', 'jane', 'bob'])).all()

# Is null / Is not null
tasks = Task.query.filter(Task.due_date.is_(None)).all()
tasks = Task.query.filter(Task.due_date.isnot(None)).all()
```

### Sorting and Limiting

```python
# Order by (ascending)
users = User.query.order_by(User.username.asc()).all()

# Order by (descending)
users = User.query.order_by(User.created_at.desc()).all()

# Multiple sorts
users = User.query.order_by(
    User.username.asc(),
    User.created_at.desc()
).all()

# Limit results
users = User.query.limit(10).all()

# Offset (skip)
users = User.query.offset(20).all()

# Limit and offset (pagination)
users = User.query.limit(10).offset(20).all()
```

### Joins

```python
# Join tasks with users
tasks = db.session.query(Task).join(User).all()

# Join with condition
tasks = db.session.query(Task).join(User, Task.user_id == User.id).all()

# Get tasks with user data
results = db.session.query(Task, User).join(User).all()
for task, user in results:
    print(task.title, user.username)

# Left outer join (include tasks without users)
tasks = db.session.query(Task).outerjoin(User).all()

# Multiple joins
tasks = db.session.query(Task).join(User).join(Tag).all()
```

### Aggregations

```python
from sqlalchemy import func

# Count
total_users = db.session.query(func.count(User.id)).scalar()
pending_tasks = db.session.query(func.count(Task.id)).filter(Task.status == 'pending').scalar()

# Sum, Avg, Min, Max
total_priority = db.session.query(func.sum(Task.priority)).scalar()
avg_priority = db.session.query(func.avg(Task.priority)).scalar()
max_priority = db.session.query(func.max(Task.priority)).scalar()

# Group By
tasks_by_status = db.session.query(
    Task.status,
    func.count(Task.id)
).group_by(Task.status).all()
# → [('pending', 10), ('completed', 5)]

# Having (filter on grouped results)
tasks_by_status = db.session.query(
    Task.status,
    func.count(Task.id)
).group_by(Task.status).having(
    func.count(Task.id) > 5
).all()
```

### Advanced Query Examples

```python
# Get users with their task count
from sqlalchemy import func

users = db.session.query(
    User,
    func.count(Task.id).label('task_count')
).outerjoin(Task).group_by(User.id).all()

for user, count in users:
    print(f"{user.username}: {count} tasks")

# Get overdue tasks
from datetime import datetime

overdue_tasks = Task.query.filter(
    Task.due_date < datetime.utcnow(),
    Task.status != 'completed'
).all()

# Search tasks
search_term = 'flask'
tasks = Task.query.filter(
    or_(
        Task.title.ilike(f'%{search_term}%'),
        Task.description.ilike(f'%{search_term}%')
    )
).all()

# Complex filter
tasks = Task.query.filter(
    and_(
        Task.status == 'pending',
        or_(
            Task.priority == 'high',
            Task.priority == 'urgent'
        ),
        Task.due_date < datetime.utcnow() + timedelta(days=7)
    )
).all()
```

---

## 8. Database Migrations

### Why Migrations?

As your application grows, your database schema changes:

```
Version 1: User has name and email
Version 2: User adds phone number
Version 3: User adds address

Migrations = Version control for your database!
```

### Setting Up Migrations

```bash
# Install Flask-Migrate
pip install flask-migrate
```

```python
from flask_migrate import Migrate

# Setup
migrate = Migrate(app, db)

# Initialize migrations (first time only)
# flask db init

# Create a migration
# flask db migrate -m "Add phone number to users"

# Apply migration
# flask db upgrade

# Rollback migration
# flask db downgrade
```

### Migration Commands

```bash
# Initialize migrations folder
flask db init

# Create migration from model changes
flask db migrate -m "Add phone number"

# Apply migrations
flask db upgrade

# Rollback one migration
flask db downgrade -1

# Rollback to specific migration
flask db downgrade abc123

# Show current migration version
flask db current

# Show migration history
flask db history

# Stamp database as current without running migrations
flask db stamp head
```

### Migration Example

```python
# Step 1: Add a column to your model
class User(db.Model):
    # Existing columns...
    phone = db.Column(db.String(20))  # New column

# Step 2: Generate migration
# flask db migrate -m "Add phone number"

# Step 3: Apply migration
# flask db upgrade

# Migration file (auto-generated)
# migrations/versions/abc123_add_phone_number.py

def upgrade():
    op.add_column('users', sa.Column('phone', sa.String(length=20), nullable=True))

def downgrade():
    op.drop_column('users', 'phone')
```

---

## 9. Putting It All Together

### Complete Example: Task Manager

```python
# app.py - Complete Flask app with database

from flask import Flask, request, render_template, redirect, flash, jsonify
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate
from datetime import datetime

# Initialize app
app = Flask(__name__)
app.secret_key = 'your-secret-key'
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///tasks.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

# Initialize database
db = SQLAlchemy(app)
migrate = Migrate(app, db)

# Models
class User(db.Model):
    __tablename__ = 'users'
    
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(50), unique=True, nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    # One-to-Many: User has many tasks
    tasks = db.relationship('Task', backref='owner', lazy='dynamic')

class Task(db.Model):
    __tablename__ = 'tasks'
    
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(200), nullable=False)
    description = db.Column(db.Text)
    status = db.Column(db.String(20), default='pending')
    priority = db.Column(db.String(20), default='medium')
    due_date = db.Column(db.DateTime)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Foreign Key
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)

# Routes
@app.route('/')
def home():
    return render_template('home.html')

@app.route('/users')
def list_users():
    users = User.query.all()
    return render_template('users.html', users=users)

@app.route('/users/create', methods=['GET', 'POST'])
def create_user():
    if request.method == 'POST':
        username = request.form.get('username')
        email = request.form.get('email')
        
        user = User(username=username, email=email)
        db.session.add(user)
        db.session.commit()
        
        flash('User created!', 'success')
        return redirect('/users')
    
    return render_template('create_user.html')

@app.route('/tasks')
def list_tasks():
    status = request.args.get('status')
    if status:
        tasks = Task.query.filter_by(status=status).all()
    else:
        tasks = Task.query.all()
    
    return render_template('tasks.html', tasks=tasks)

@app.route('/tasks/<int:task_id>')
def view_task(task_id):
    task = Task.query.get_or_404(task_id)
    return render_template('task_detail.html', task=task)

@app.route('/tasks/create', methods=['GET', 'POST'])
def create_task():
    if request.method == 'POST':
        title = request.form.get('title')
        description = request.form.get('description')
        priority = request.form.get('priority')
        user_id = request.form.get('user_id')
        
        task = Task(
            title=title,
            description=description,
            priority=priority,
            user_id=user_id
        )
        db.session.add(task)
        db.session.commit()
        
        flash('Task created!', 'success')
        return redirect('/tasks')
    
    users = User.query.all()
    return render_template('create_task.html', users=users)

@app.route('/tasks/<int:task_id>/edit', methods=['GET', 'POST'])
def edit_task(task_id):
    task = Task.query.get_or_404(task_id)
    
    if request.method == 'POST':
        task.title = request.form.get('title')
        task.description = request.form.get('description')
        task.status = request.form.get('status')
        task.priority = request.form.get('priority')
        db.session.commit()
        
        flash('Task updated!', 'success')
        return redirect(f'/tasks/{task.id}')
    
    return render_template('edit_task.html', task=task)

@app.route('/tasks/<int:task_id>/delete', methods=['POST'])
def delete_task(task_id):
    task = Task.query.get_or_404(task_id)
    db.session.delete(task)
    db.session.commit()
    
    flash('Task deleted!', 'success')
    return redirect('/tasks')

# API Routes
@app.route('/api/tasks')
def api_tasks():
    tasks = Task.query.all()
    return jsonify([{
        'id': t.id,
        'title': t.title,
        'status': t.status,
        'priority': t.priority,
        'user_id': t.user_id,
        'username': t.owner.username
    } for t in tasks])

@app.route('/api/users')
def api_users():
    users = User.query.all()
    return jsonify([{
        'id': u.id,
        'username': u.username,
        'email': u.email,
        'task_count': u.tasks.count()
    } for u in users])

# Initialize database
if __name__ == '__main__':
    with app.app_context():
        db.create_all()
    app.run(debug=True)
```

### Template Examples

```html
<!-- templates/base.html -->
<!DOCTYPE html>
<html>
<head>
    <title>Task Manager</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
    <nav class="navbar navbar-expand-lg navbar-dark bg-dark">
        <div class="container">
            <a class="navbar-brand" href="/">Task Manager</a>
        </div>
    </nav>
    
    <div class="container mt-4">
        {% with messages = get_flashed_messages(with_categories=true) %}
            {% if messages %}
                {% for category, message in messages %}
                    <div class="alert alert-{{ category }}">{{ message }}</div>
                {% endfor %}
            {% endif %}
        {% endwith %}
        
        {% block content %}{% endblock %}
    </div>
</body>
</html>

<!-- templates/tasks.html -->
{% extends "base.html" %}

{% block content %}
<h1>Tasks</h1>
<a href="/tasks/create" class="btn btn-primary mb-3">New Task</a>

<table class="table">
    <thead>
        <tr>
            <th>Title</th>
            <th>Status</th>
            <th>Priority</th>
            <th>User</th>
            <th>Actions</th>
        </tr>
    </thead>
    <tbody>
        {% for task in tasks %}
        <tr>
            <td>{{ task.title }}</td>
            <td><span class="badge bg-{{ 'success' if task.status == 'completed' else 'warning' }}">{{ task.status }}</span></td>
            <td>{{ task.priority }}</td>
            <td>{{ task.owner.username }}</td>
            <td>
                <a href="/tasks/{{ task.id }}" class="btn btn-sm btn-info">View</a>
                <a href="/tasks/{{ task.id }}/edit" class="btn btn-sm btn-warning">Edit</a>
                <form method="POST" action="/tasks/{{ task.id }}/delete" style="display:inline">
                    <button type="submit" class="btn btn-sm btn-danger">Delete</button>
                </form>
            </td>
        </tr>
        {% endfor %}
    </tbody>
</table>
{% endblock %}
```

---

## 10. Next Steps

### What You've Learned

✅ Why databases are essential for web applications
✅ How SQLAlchemy ORM works as a translator
✅ How to create models (database tables)
✅ How to perform CRUD operations
✅ How to create relationships between models
✅ How to query data with filters and sorting
✅ How to manage database migrations
✅ How to build a complete Task Manager application

### Continue Your Journey

1. **Practice with Exercises**:
   - Add a "Category" model and link it to Tasks
   - Add comments to tasks (One-to-Many relationship)
   - Add user authentication (login/register)
   - Build a REST API for your Task Manager

2. **Common Next Steps**:
   - Switch from SQLite to PostgreSQL
   - Add data validation (Flask-WTF)
   - Implement user authentication
   - Add search functionality
   - Build a dashboard with statistics

3. **Key Resources**:
   - SQLAlchemy Documentation: https://www.sqlalchemy.org
   - Flask-SQLAlchemy Docs: https://flask-sqlalchemy.palletsprojects.com
   - Flask-Migrate Docs: https://flask-migrate.readthedocs.io

### Quick Reference Card

```python
# Model Definition
class Model(db.Model):
    __tablename__ = 'table_name'
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(50))

# CRUD Operations
# CREATE
obj = Model(name='value')
db.session.add(obj); db.session.commit()

# READ
all = Model.query.all()
one = Model.query.get(1)
filtered = Model.query.filter_by(name='value').all()

# UPDATE
obj = Model.query.get(1)
obj.name = 'new_value'
db.session.commit()

# DELETE
obj = Model.query.get(1)
db.session.delete(obj)
db.session.commit()

# Relationships
class Parent(db.Model):
    children = db.relationship('Child', backref='parent')

class Child(db.Model):
    parent_id = db.Column(db.Integer, db.ForeignKey('parents.id'))
    parent = db.relationship('Parent', backref='children')

# Queries
filter = Model.query.filter(Model.field == value).all()
order = Model.query.order_by(Model.field.desc()).all()
limit = Model.query.limit(10).all()
count = Model.query.count()

# Migrations
flask db init
flask db migrate -m "message"
flask db upgrade
flask db downgrade
```

---

## Summary

This primer has introduced you to databases and SQLAlchemy in Flask:

1. **Databases store data permanently** beyond server restarts
2. **SQLAlchemy ORM** maps Python objects to database tables
3. **Models** define the structure of your data
4. **CRUD operations** let you create, read, update, and delete data
5. **Relationships** connect different tables together
6. **Queries** let you search and filter data
7. **Migrations** track changes to your database schema

You now have the foundation to build data-driven Flask applications. The main tutorial series will expand on these concepts and take you to the next level!

**Happy coding!** 🚀
