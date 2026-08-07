# Primer 3: Flask Authentication & Security Primer

Welcome to Primer 3! This foundational primer is designed for beginners who want to understand how to add user authentication and security to their Flask applications. Building on the basics from Primers 1 and 2, you'll learn how to protect your application and manage users.

---

## Table of Contents

1. [Why Authentication Matters](#1-why-authentication-matters)
2. [Understanding Authentication vs Authorization](#2-understanding-authentication-vs-authorization)
3. [Setting Up User Models](#3-setting-up-user-models)
4. [Password Security](#4-password-security)
5. [User Registration](#5-user-registration)
6. [User Login & Logout](#6-user-login--logout)
7. [Protecting Routes](#7-protecting-routes)
8. [Session Management](#8-session-management)
9. [Flash Messages & User Feedback](#9-flash-messages--user-feedback)
10. [Security Best Practices](#10-security-best-practices)

---

## 1. Why Authentication Matters

### The Problem: Anonymous Access

Without authentication, anyone can access everything:

```python
# ❌ Without authentication - anyone can do anything
@app.route('/admin')
def admin_panel():
    # Anyone can access this, even if they're not an admin!
    return 'Super secret admin panel'

@app.route('/delete-all-tasks', methods=['POST'])
def delete_all_tasks():
    # Anyone can delete everything!
    Task.query.delete()
    db.session.commit()
    return 'All tasks deleted!'
```

### The Solution: Authentication & Authorization

Authentication answers: "Who are you?"
Authorization answers: "What can you do?"

```
User visits website
     ↓
"Who are you?" (Authentication)
     ↓
User logs in with username/password
     ↓
"Here's who you are" (User identity established)
     ↓
"What can you do?" (Authorization)
     ↓
User gets access to their own tasks, not others'
```

### Real-World Analogy

Think of authentication like a security badge at a building:

```
Without Badge: Anyone can walk in anywhere
    ↓
With Badge (Authentication): You prove who you are
    ↓
Access Level (Authorization): You can access certain floors
    - Regular employee: Access to floors 1-3
    - Manager: Access to floors 1-5
    - Admin: Access to all floors
```

---

## 2. Understanding Authentication vs Authorization

### Authentication: Who Are You?

```python
# Authentication = Login process
@app.route('/login', methods=['POST'])
def login():
    username = request.form.get('username')
    password = request.form.get('password')
    
    # Verify user exists and password matches
    user = User.query.filter_by(username=username).first()
    if user and user.check_password(password):
        # User is authenticated!
        login_user(user)
        return 'Logged in!'
    else:
        return 'Invalid credentials!'
```

### Authorization: What Can You Do?

```python
# Authorization = What you're allowed to do
@app.route('/admin')
def admin_panel():
    # Check if user is authorized (has admin role)
    if not current_user.is_admin:
        return 'You are not authorized!', 403
    return 'Welcome to the admin panel!'

@app.route('/task/<int:task_id>/delete')
def delete_task(task_id):
    task = Task.query.get(task_id)
    
    # Check if user is authorized to delete this task
    if task.user_id != current_user.id:
        return 'You can only delete your own tasks!', 403
    
    # User is authorized!
    db.session.delete(task)
    db.session.commit()
    return 'Task deleted!'
```

### The Three Types of Users

```
┌─────────────────────────────────────────────────────────────┐
│                    Types of Users                           │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1. Anonymous/Visitor                                       │
│     - Not logged in                                         │
│     - Can view public pages only                            │
│     - Cannot create tasks                                   │
│                                                             │
│  2. Regular User                                            │
│     - Logged in                                             │
│     - Can create and manage own tasks                       │
│     - Can view own profile                                  │
│                                                             │
│  3. Admin User                                              │
│     - Logged in with special privileges                     │
│     - Can manage all users                                  │
│     - Can view all tasks                                    │
│     - Can access admin panel                                │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 3. Setting Up User Models

### Installing Flask-Login

```bash
pip install flask-login
```

### Creating the User Model

```python
from datetime import datetime
from flask_login import UserMixin
from flask_sqlalchemy import SQLAlchemy

db = SQLAlchemy()

class User(db.Model, UserMixin):
    """User model with authentication support."""
    
    __tablename__ = 'users'
    
    # Basic fields
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(50), unique=True, nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=False)
    password_hash = db.Column(db.String(128), nullable=False)
    
    # Profile fields
    first_name = db.Column(db.String(50))
    last_name = db.Column(db.String(50))
    bio = db.Column(db.Text)
    
    # Status fields
    is_active = db.Column(db.Boolean, default=True)
    is_admin = db.Column(db.Boolean, default=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    last_login = db.Column(db.DateTime)
    
    # Relationships
    tasks = db.relationship('Task', backref='user', lazy='dynamic')
    
    def __repr__(self):
        return f'<User {self.username}>'
```

### Understanding UserMixin

`UserMixin` provides default implementations for Flask-Login:

```python
# What UserMixin gives you:

class UserMixin:
    @property
    def is_authenticated(self):
        """Returns True if user is authenticated."""
        return True
    
    @property
    def is_active(self):
        """Returns True if user account is active."""
        return True
    
    @property
    def is_anonymous(self):
        """Returns True if user is anonymous."""
        return False
    
    def get_id(self):
        """Returns user ID as string."""
        return str(self.id)

# You can override these if needed
class User(db.Model, UserMixin):
    # Override is_active to use your own logic
    @property
    def is_active(self):
        return self.is_active_column  # Your custom field
```

### Setting Up Flask-Login

```python
from flask import Flask
from flask_login import LoginManager

app = Flask(__name__)
app.config['SECRET_KEY'] = 'your-secret-key'  # Required for sessions

# Initialize LoginManager
login_manager = LoginManager()
login_manager.init_app(app)

# Configure login behavior
login_manager.login_view = 'login'  # Where to redirect if not logged in
login_manager.login_message = 'Please log in to access this page.'
login_manager.login_message_category = 'warning'

# User loader function
@login_manager.user_loader
def load_user(user_id):
    """Load a user from the database."""
    return User.query.get(int(user_id))
```

### Complete Setup Example

```python
# app.py - Complete authentication setup

from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_login import LoginManager, UserMixin
from datetime import datetime

app = Flask(__name__)
app.config['SECRET_KEY'] = 'your-secret-key-here'
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///app.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

db = SQLAlchemy(app)
login_manager = LoginManager(app)
login_manager.login_view = 'login'

class User(db.Model, UserMixin):
    __tablename__ = 'users'
    
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(50), unique=True, nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=False)
    password_hash = db.Column(db.String(128), nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

@login_manager.user_loader
def load_user(user_id):
    return User.query.get(int(user_id))

# Create tables
with app.app_context():
    db.create_all()
```

---

## 4. Password Security

### Why Password Security Matters

```
❌ BAD: Storing passwords in plain text
password = 'password123'  # Database stores: 'password123'

✅ GOOD: Storing hashed passwords
password_hash = 'hashed_version_of_password'  # Database stores: 'hashed_string'

If someone gets the database:
- Plain text: They have all passwords!
- Hashed: They have gibberish they can't use
```

### How Password Hashing Works

```python
# Password hashing is one-way encryption

Plain Password: "password123"
     ↓ [Hash Function]
Hashed Password: "7c6a180b36896a0a8c02787eeafb0e4c"
     ↓ [Can't reverse!]

# To check a password:
Entered: "password123"
     ↓ [Hash Function]
Hashed: "7c6a180b36896a0a8c02787eeafb0e4c"
     ↓ [Compare with stored hash]
Match? ✅ Yes! Password is correct.
```

### Using Werkzeug for Password Hashing

Flask's Werkzeug provides secure password hashing:

```python
from werkzeug.security import generate_password_hash, check_password_hash

class User(db.Model, UserMixin):
    # ... existing fields ...
    password_hash = db.Column(db.String(128), nullable=False)
    
    def set_password(self, password):
        """Hash and set the password."""
        self.password_hash = generate_password_hash(password)
    
    def check_password(self, password):
        """Check if the password matches."""
        return check_password_hash(self.password_hash, password)

# Usage
user = User(username='john')
user.set_password('my_secure_password')  # Hashes and stores
db.session.add(user)
db.session.commit()

# Verify password
user = User.query.filter_by(username='john').first()
if user.check_password('my_secure_password'):
    print('Password is correct!')
```

### Password Requirements

```python
def validate_password(password):
    """Validate password strength."""
    
    # Minimum length
    if len(password) < 8:
        return False, 'Password must be at least 8 characters'
    
    # Uppercase letter
    if not any(c.isupper() for c in password):
        return False, 'Password must contain an uppercase letter'
    
    # Lowercase letter
    if not any(c.islower() for c in password):
        return False, 'Password must contain a lowercase letter'
    
    # Number
    if not any(c.isdigit() for c in password):
        return False, 'Password must contain a number'
    
    # Special character
    if not any(c in '!@#$%^&*()_+-=' for c in password):
        return False, 'Password must contain a special character'
    
    return True, 'Password is valid'

# Usage in registration
@app.route('/register', methods=['POST'])
def register():
    password = request.form.get('password')
    valid, message = validate_password(password)
    
    if not valid:
        flash(message, 'danger')
        return render_template('register.html')
    
    # Create user with valid password
    user = User(username=username, email=email)
    user.set_password(password)
    db.session.add(user)
    db.session.commit()
```

---

## 5. User Registration

### Registration Form

```html
<!-- templates/register.html -->
{% extends "base.html" %}

{% block content %}
<div class="row justify-content-center">
    <div class="col-md-6">
        <div class="card">
            <div class="card-header">
                <h3>Create Account</h3>
            </div>
            <div class="card-body">
                <form method="POST" action="/register">
                    <div class="mb-3">
                        <label for="username" class="form-label">Username</label>
                        <input type="text" class="form-control" id="username" name="username" required>
                    </div>
                    
                    <div class="mb-3">
                        <label for="email" class="form-label">Email</label>
                        <input type="email" class="form-control" id="email" name="email" required>
                    </div>
                    
                    <div class="mb-3">
                        <label for="password" class="form-label">Password</label>
                        <input type="password" class="form-control" id="password" name="password" required>
                        <div class="form-text">
                            Password must be at least 8 characters with uppercase, lowercase, number, and special character.
                        </div>
                    </div>
                    
                    <div class="mb-3">
                        <label for="confirm_password" class="form-label">Confirm Password</label>
                        <input type="password" class="form-control" id="confirm_password" name="confirm_password" required>
                    </div>
                    
                    <button type="submit" class="btn btn-primary">Register</button>
                </form>
                
                <hr>
                
                <p class="text-center">
                    Already have an account? <a href="/login">Login here</a>
                </p>
            </div>
        </div>
    </div>
</div>
{% endblock %}
```

### Registration Route

```python
from flask import render_template, request, flash, redirect, url_for

@app.route('/register', methods=['GET', 'POST'])
def register():
    if request.method == 'GET':
        return render_template('register.html')
    
    # Get form data
    username = request.form.get('username')
    email = request.form.get('email')
    password = request.form.get('password')
    confirm_password = request.form.get('confirm_password')
    
    # Validate input
    if not username or not email or not password:
        flash('All fields are required', 'danger')
        return render_template('register.html')
    
    if password != confirm_password:
        flash('Passwords do not match', 'danger')
        return render_template('register.html')
    
    # Validate password strength
    valid, message = validate_password(password)
    if not valid:
        flash(message, 'danger')
        return render_template('register.html')
    
    # Check if username exists
    if User.query.filter_by(username=username).first():
        flash('Username already taken', 'danger')
        return render_template('register.html')
    
    # Check if email exists
    if User.query.filter_by(email=email).first():
        flash('Email already registered', 'danger')
        return render_template('register.html')
    
    # Create user
    user = User(
        username=username,
        email=email
    )
    user.set_password(password)
    
    db.session.add(user)
    db.session.commit()
    
    flash('Registration successful! Please log in.', 'success')
    return redirect(url_for('login'))
```

### Using Flask-WTF for Better Forms

```bash
pip install flask-wtf email-validator
```

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
        EqualTo('password', message='Passwords must match')
    ])
    submit = SubmitField('Register')

@app.route('/register', methods=['GET', 'POST'])
def register():
    form = RegistrationForm()
    
    if form.validate_on_submit():
        # All validation passed!
        user = User(
            username=form.username.data,
            email=form.email.data
        )
        user.set_password(form.password.data)
        
        db.session.add(user)
        db.session.commit()
        
        flash('Registration successful!', 'success')
        return redirect(url_for('login'))
    
    return render_template('register.html', form=form)
```

---

## 6. User Login & Logout

### Login Form

```html
<!-- templates/login.html -->
{% extends "base.html" %}

{% block content %}
<div class="row justify-content-center">
    <div class="col-md-6">
        <div class="card">
            <div class="card-header">
                <h3>Login</h3>
            </div>
            <div class="card-body">
                <form method="POST" action="/login">
                    <div class="mb-3">
                        <label for="email" class="form-label">Email</label>
                        <input type="email" class="form-control" id="email" name="email" required>
                    </div>
                    
                    <div class="mb-3">
                        <label for="password" class="form-label">Password</label>
                        <input type="password" class="form-control" id="password" name="password" required>
                    </div>
                    
                    <div class="mb-3 form-check">
                        <input type="checkbox" class="form-check-input" id="remember" name="remember">
                        <label class="form-check-label" for="remember">Remember me</label>
                    </div>
                    
                    <button type="submit" class="btn btn-primary">Login</button>
                </form>
                
                <hr>
                
                <p class="text-center">
                    Don't have an account? <a href="/register">Register here</a>
                </p>
            </div>
        </div>
    </div>
</div>
{% endblock %}
```

### Login Route

```python
from flask_login import login_user, logout_user, login_required, current_user

@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'GET':
        return render_template('login.html')
    
    email = request.form.get('email')
    password = request.form.get('password')
    remember = request.form.get('remember') == 'on'
    
    # Find user by email
    user = User.query.filter_by(email=email).first()
    
    # Check credentials
    if user and user.check_password(password):
        # Log the user in
        login_user(user, remember=remember)
        
        # Update last login
        user.last_login = datetime.utcnow()
        db.session.commit()
        
        flash('Login successful!', 'success')
        
        # Redirect to the page they were trying to access
        next_page = request.args.get('next')
        if next_page:
            return redirect(next_page)
        return redirect(url_for('dashboard'))
    else:
        flash('Invalid email or password', 'danger')
        return render_template('login.html')
```

### Logout Route

```python
@app.route('/logout')
@login_required
def logout():
    logout_user()
    flash('You have been logged out.', 'info')
    return redirect(url_for('home'))
```

### Complete Authentication Flow

```python
# Full authentication example

from flask import Flask, render_template, request, flash, redirect, url_for
from flask_sqlalchemy import SQLAlchemy
from flask_login import LoginManager, UserMixin, login_user, logout_user, login_required, current_user
from werkzeug.security import generate_password_hash, check_password_hash
from datetime import datetime

app = Flask(__name__)
app.config['SECRET_KEY'] = 'your-secret-key'
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///app.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

db = SQLAlchemy(app)
login_manager = LoginManager(app)
login_manager.login_view = 'login'
login_manager.login_message = 'Please log in to continue.'

class User(db.Model, UserMixin):
    __tablename__ = 'users'
    
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(50), unique=True, nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=False)
    password_hash = db.Column(db.String(128), nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    last_login = db.Column(db.DateTime)
    
    def set_password(self, password):
        self.password_hash = generate_password_hash(password)
    
    def check_password(self, password):
        return check_password_hash(self.password_hash, password)

@login_manager.user_loader
def load_user(user_id):
    return User.query.get(int(user_id))

@app.route('/')
def home():
    return render_template('home.html')

@app.route('/register', methods=['GET', 'POST'])
def register():
    if request.method == 'GET':
        return render_template('register.html')
    
    username = request.form.get('username')
    email = request.form.get('email')
    password = request.form.get('password')
    confirm = request.form.get('confirm_password')
    
    if password != confirm:
        flash('Passwords do not match', 'danger')
        return render_template('register.html')
    
    if User.query.filter_by(username=username).first():
        flash('Username already taken', 'danger')
        return render_template('register.html')
    
    if User.query.filter_by(email=email).first():
        flash('Email already registered', 'danger')
        return render_template('register.html')
    
    user = User(username=username, email=email)
    user.set_password(password)
    
    db.session.add(user)
    db.session.commit()
    
    flash('Registration successful!', 'success')
    return redirect(url_for('login'))

@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'GET':
        return render_template('login.html')
    
    email = request.form.get('email')
    password = request.form.get('password')
    remember = request.form.get('remember') == 'on'
    
    user = User.query.filter_by(email=email).first()
    
    if user and user.check_password(password):
        login_user(user, remember=remember)
        user.last_login = datetime.utcnow()
        db.session.commit()
        
        flash('Login successful!', 'success')
        return redirect(url_for('dashboard'))
    
    flash('Invalid email or password', 'danger')
    return render_template('login.html')

@app.route('/logout')
@login_required
def logout():
    logout_user()
    flash('Logged out.', 'info')
    return redirect(url_for('home'))

@app.route('/dashboard')
@login_required
def dashboard():
    return f'Welcome, {current_user.username}!'

if __name__ == '__main__':
    with app.app_context():
        db.create_all()
    app.run(debug=True)
```

---

## 7. Protecting Routes

### Using @login_required

```python
from flask_login import login_required, current_user

# Basic protection
@app.route('/dashboard')
@login_required
def dashboard():
    return render_template('dashboard.html', user=current_user)

# Protected with redirect to login
@app.route('/settings')
@login_required
def settings():
    # Only logged-in users can access this
    return render_template('settings.html')
```

### Checking User Roles

```python
# Add role field to User model
class User(db.Model, UserMixin):
    # ... existing fields ...
    role = db.Column(db.String(20), default='user')  # 'user', 'admin'

# Role-based protection
@app.route('/admin')
@login_required
def admin_panel():
    if current_user.role != 'admin':
        flash('You need admin access for this page.', 'danger')
        return redirect(url_for('home'))
    return render_template('admin.html')

# Custom decorator for role checking
from functools import wraps

def admin_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        if not current_user.is_authenticated:
            flash('Please log in.', 'warning')
            return redirect(url_for('login'))
        if current_user.role != 'admin':
            flash('You need admin access.', 'danger')
            return redirect(url_for('home'))
        return f(*args, **kwargs)
    return decorated

@app.route('/admin')
@admin_required
def admin_panel():
    return render_template('admin.html')
```

### Resource-Level Authorization

```python
# Check if user owns a resource
@app.route('/task/<int:task_id>/edit')
@login_required
def edit_task(task_id):
    task = Task.query.get_or_404(task_id)
    
    # Check if current user owns this task
    if task.user_id != current_user.id and current_user.role != 'admin':
        flash('You can only edit your own tasks.', 'danger')
        return redirect(url_for('tasks'))
    
    return render_template('edit_task.html', task=task)

# Multiple permission checks
def can_edit_task(task, user):
    """Check if a user can edit a task."""
    if user.role == 'admin':
        return True
    if task.user_id == user.id:
        return True
    return False

@app.route('/task/<int:task_id>/edit')
@login_required
def edit_task(task_id):
    task = Task.query.get_or_404(task_id)
    
    if not can_edit_task(task, current_user):
        abort(403)  # Forbidden
    
    return render_template('edit_task.html', task=task)
```

### Protecting API Routes

```python
@app.route('/api/tasks')
@login_required
def api_tasks():
    """API endpoint that requires authentication."""
    tasks = Task.query.filter_by(user_id=current_user.id).all()
    return jsonify([task.to_dict() for task in tasks])

# Token-based API authentication
from flask import request, jsonify
from functools import wraps

def token_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        token = request.headers.get('Authorization')
        
        if not token or token != 'your-secret-token':
            return jsonify({'error': 'Invalid token'}), 401
        
        return f(*args, **kwargs)
    return decorated

@app.route('/api/secure')
@token_required
def secure_api():
    return jsonify({'message': 'You have access!'})
```

---

## 8. Session Management

### Understanding Sessions

A session is like a temporary ID badge:

```
User logs in
    ↓
Server creates a session (ID badge)
    ↓
Server stores user ID in session
    ↓
Server gives session ID to browser (in cookie)
    ↓
Browser sends session ID with every request
    ↓
Server looks up user from session ID
    ↓
Server knows who the user is!
```

### Flask Session Configuration

```python
# Session configuration
app.config['SECRET_KEY'] = 'your-secret-key'  # Required for sessions

# Session settings
app.config['SESSION_COOKIE_HTTPONLY'] = True   # Prevent JavaScript access
app.config['SESSION_COOKIE_SECURE'] = False    # True in production with HTTPS
app.config['SESSION_COOKIE_SAMESITE'] = 'Lax'  # CSRF protection
app.config['PERMANENT_SESSION_LIFETIME'] = 3600  # 1 hour (in seconds)
```

### Remember Me Functionality

```python
# Login with remember me
@app.route('/login', methods=['POST'])
def login():
    user = User.query.filter_by(email=email).first()
    
    if user and user.check_password(password):
        remember = request.form.get('remember') == 'on'
        login_user(user, remember=remember)
        return redirect(url_for('dashboard'))

# Configure remember me
app.config['REMEMBER_COOKIE_DURATION'] = timedelta(days=30)
app.config['REMEMBER_COOKIE_HTTPONLY'] = True
app.config['REMEMBER_COOKIE_SECURE'] = True
```

### Session Security

```python
# Session expiration
@app.before_request
def check_session():
    """Check if session is expired."""
    if current_user.is_authenticated:
        # Check if session has been active too long
        if hasattr(current_user, 'last_activity'):
            inactive_time = datetime.utcnow() - current_user.last_activity
            if inactive_time > timedelta(hours=1):
                logout_user()
                flash('Session expired. Please log in again.', 'warning')
                return redirect(url_for('login'))
        
        # Update last activity
        current_user.last_activity = datetime.utcnow()
        db.session.commit()

# Clearing session data
@app.route('/logout')
@login_required
def logout():
    # Clear session data
    session.clear()
    logout_user()
    flash('You have been logged out.', 'info')
    return redirect(url_for('home'))
```

### Session Data (Custom)

```python
from flask import session

# Storing custom data in session
@app.route('/set-preference', methods=['POST'])
def set_preference():
    theme = request.form.get('theme')
    session['theme'] = theme  # Store in session
    return 'Preference saved!'

@app.route('/get-preference')
def get_preference():
    theme = session.get('theme', 'light')  # Default to 'light'
    return f'Your theme is: {theme}'

# Session messages (shopping cart example)
@app.route('/cart/add', methods=['POST'])
def add_to_cart():
    item_id = request.form.get('item_id')
    
    if 'cart' not in session:
        session['cart'] = []
    
    session['cart'].append(item_id)
    session.modified = True  # Important for mutable objects
    
    return f'Item {item_id} added to cart!'
```

---

## 9. Flash Messages & User Feedback

### Using Flash Messages

```python
from flask import flash

# Success messages
flash('Task created successfully!', 'success')
flash('Profile updated!', 'success')

# Error messages
flash('Invalid email address.', 'danger')
flash('Something went wrong.', 'error')

# Warning messages
flash('Your session will expire soon.', 'warning')
flash('Please verify your email.', 'warning')

# Info messages
flash('Welcome back!', 'info')
flash('New features available.', 'info')
```

### Displaying Flash Messages

```html
<!-- templates/base.html -->
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
```

### Different Message Categories

```html
<!-- Bootstrap 5 alert classes -->
<div class="alert alert-success">Success!</div>   <!-- Green -->
<div class="alert alert-danger">Error!</div>      <!-- Red -->
<div class="alert alert-warning">Warning!</div>   <!-- Yellow -->
<div class="alert alert-info">Information!</div>  <!-- Blue -->

<!-- Matching flash categories -->
flash('Success!', 'success')    → alert-success
flash('Error!', 'danger')       → alert-danger
flash('Warning!', 'warning')    → alert-warning
flash('Info!', 'info')          → alert-info
```

### Auto-Dismissing Flash Messages

```javascript
// static/js/main.js
document.addEventListener('DOMContentLoaded', function() {
    // Auto-dismiss flash messages after 5 seconds
    const alerts = document.querySelectorAll('.alert');
    alerts.forEach(function(alert) {
        setTimeout(function() {
            const bsAlert = new bootstrap.Alert(alert);
            bsAlert.close();
        }, 5000);
    });
});
```

---

## 10. Security Best Practices

### The Security Checklist

```yaml
# Authentication Security Checklist

# 1. Password Security
- [ ] Use strong password hashing (werkzeug)
- [ ] Enforce password requirements (length, complexity)
- [ ] Never store passwords in plain text
- [ ] Never log passwords

# 2. Session Security
- [ ] Use a strong SECRET_KEY (32+ random characters)
- [ ] Set SESSION_COOKIE_HTTPONLY = True
- [ ] Set SESSION_COOKIE_SECURE = True (in production)
- [ ] Set SESSION_COOKIE_SAMESITE = 'Lax' or 'Strict'

# 3. Login Security
- [ ] Implement rate limiting on login attempts
- [ ] Use HTTPS in production
- [ ] Consider CAPTCHA after failed attempts
- [ ] Implement "Remember me" with caution

# 4. Authorization
- [ ] Always check permissions on the server side
- [ ] Never trust client-side checks
- [ ] Use role-based access control (RBAC)
- [ ] Implement resource-level authorization

# 5. Input Validation
- [ ] Validate all user input
- [ ] Use Flask-WTF for form validation
- [ ] Sanitize output (auto-escaping in templates)

# 6. Other Security
- [ ] Keep dependencies updated
- [ ] Use security headers (HSTS, CSP, etc.)
- [ ] Log security events
- [ ] Regular security audits
```

### Secure Password Policy

```python
def validate_password(password):
    """Comprehensive password validation."""
    # Length requirement
    if len(password) < 8:
        return False, 'Password must be at least 8 characters'
    
    # Uppercase letter
    if not any(c.isupper() for c in password):
        return False, 'Password must contain an uppercase letter'
    
    # Lowercase letter
    if not any(c.islower() for c in password):
        return False, 'Password must contain a lowercase letter'
    
    # Digit
    if not any(c.isdigit() for c in password):
        return False, 'Password must contain a number'
    
    # Special character
    special_chars = '!@#$%^&*()_+-=[]{}|;:,.<>?'
    if not any(c in special_chars for c in password):
        return False, 'Password must contain a special character'
    
    # Common passwords check
    common_passwords = ['password123', 'admin123', 'qwerty123']
    if password.lower() in common_passwords:
        return False, 'Password is too common'
    
    return True, 'Password is valid'
```

### Rate Limiting Login Attempts

```bash
pip install flask-limiter
```

```python
from flask_limiter import Limiter
from flask_limiter.util import get_remote_address

limiter = Limiter(
    app=app,
    key_func=get_remote_address,
    default_limits=["200 per day", "50 per hour"]
)

@app.route('/login', methods=['POST'])
@limiter.limit("5 per minute", error_message="Too many login attempts. Please try again later.")
def login():
    # Login logic...
```

### Security Headers

```python
@app.after_request
def add_security_headers(response):
    """Add security headers to all responses."""
    response.headers['X-Frame-Options'] = 'SAMEORIGIN'
    response.headers['X-Content-Type-Options'] = 'nosniff'
    response.headers['X-XSS-Protection'] = '1; mode=block'
    response.headers['Referrer-Policy'] = 'strict-origin-when-cross-origin'
    
    # HSTS (only in production with HTTPS)
    if app.config.get('ENV') == 'production':
        response.headers['Strict-Transport-Security'] = 'max-age=31536000; includeSubDomains'
    
    return response
```

### Complete Security Example

```python
# security.py - Complete security configuration

from flask import Flask, session
from flask_limiter import Limiter
from flask_limiter.util import get_remote_address
from datetime import timedelta

def configure_security(app):
    """Configure all security settings."""
    
    # Session security
    app.config['SECRET_KEY'] = app.config.get('SECRET_KEY', 'dev-key-change-me')
    app.config['SESSION_COOKIE_HTTPONLY'] = True
    app.config['SESSION_COOKIE_SECURE'] = app.config.get('ENV') == 'production'
    app.config['SESSION_COOKIE_SAMESITE'] = 'Lax'
    app.config['PERMANENT_SESSION_LIFETIME'] = timedelta(hours=1)
    
    # Rate limiting
    limiter = Limiter(
        app=app,
        key_func=get_remote_address,
        default_limits=["200 per day", "50 per hour"]
    )
    
    # Security headers
    @app.after_request
    def add_security_headers(response):
        response.headers['X-Frame-Options'] = 'SAMEORIGIN'
        response.headers['X-Content-Type-Options'] = 'nosniff'
        response.headers['X-XSS-Protection'] = '1; mode=block'
        response.headers['Referrer-Policy'] = 'strict-origin-when-cross-origin'
        
        if app.config.get('ENV') == 'production':
            response.headers['Strict-Transport-Security'] = 'max-age=31536000; includeSubDomains'
            response.headers['Content-Security-Policy'] = "default-src 'self'"
        
        return response
    
    return app
```

---

## Summary

This primer has introduced you to authentication and security in Flask:

1. **Authentication** = Who you are (login)
2. **Authorization** = What you can do (permissions)
3. **User models** store user data and credentials
4. **Password hashing** protects passwords from theft
5. **Registration** creates new user accounts
6. **Login/Logout** manages user sessions
7. **Route protection** restricts access to authenticated users
8. **Session management** tracks user state
9. **Flash messages** provide user feedback
10. **Security best practices** protect your application

### Quick Reference

```python
# User model with authentication
class User(db.Model, UserMixin):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(50), unique=True)
    password_hash = db.Column(db.String(128))
    
    def set_password(self, password):
        self.password_hash = generate_password_hash(password)
    
    def check_password(self, password):
        return check_password_hash(self.password_hash, password)

# Login setup
login_manager = LoginManager(app)
login_manager.login_view = 'login'

@login_manager.user_loader
def load_user(user_id):
    return User.query.get(int(user_id))

# Protect routes
@login_required
def protected_route():
    return 'Only logged-in users see this'

# Check permissions
if current_user.is_authenticated:
    # User is logged in
    if current_user.role == 'admin':
        # User is admin

# Flash messages
flash('Success message', 'success')
flash('Error message', 'danger')

# Session
session['key'] = 'value'
value = session.get('key', 'default')
```

**Next Steps**:
- Build a complete authentication system
- Add "Remember me" functionality
- Implement password reset via email
- Add role-based access control
- Deploy with HTTPS
