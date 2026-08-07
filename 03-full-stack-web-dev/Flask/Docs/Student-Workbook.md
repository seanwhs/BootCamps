# Master Modern Flask 3.x: Student Workbook

## Comprehensive Hands-On Exercises & Activities

---

# WORKBOOK INTRODUCTION

## How to Use This Workbook

This workbook is designed to accompany the "Master Modern Flask 3.x" tutorial series. Each section corresponds to a part of the main tutorial and contains:

1. **Learning Objectives** - What you should know after completing the section
2. **Key Concepts Review** - Summary of important ideas
3. **Hands-On Exercises** - Practical coding activities
4. **Challenge Problems** - Advanced exercises to test your skills
5. **Self-Assessment Quiz** - Check your understanding
6. **Project Milestones** - Progress checkpoints for your TaskFlow application

**Tips for Success:**
- Complete exercises in order
- Write code yourself (don't just copy-paste)
- Experiment with modifications
- Use the main tutorial as a reference
- Track your progress in the workbook

---

# PART 1: FLASK FOUNDATIONS & PROJECT ARCHITECTURE

## Learning Objectives

By the end of this section, you will be able to:
- Set up a professional Flask development environment
- Create a Flask application using the Application Factory pattern
- Organize your project with Blueprints
- Configure environment-specific settings
- Use code quality tools (Ruff, Black, isort)

---

## Key Concepts Review

### Fill in the Blanks

1. Flask follows a ___________ philosophy, meaning it provides only the essentials.

2. The ___________ pattern allows you to create multiple Flask application instances with different configurations.

3. __________ are modular components that help organize routes in a Flask application.

4. A __________ environment isolates Python packages for different projects.

5. __________ automatically formats Python code to follow consistent style rules.

### True or False

1. [ ] The Flask development server should be used in production.
2. [ ] Blueprints allow you to reuse code across multiple Flask applications.
3. [ ] The Application Factory pattern makes it harder to test Flask applications.
4. [ ] Environment variables should be hardcoded in your application code.
5. [ ] Ruff is a Python code formatter.

---

## Hands-On Exercises

### Exercise 1.1: Setting Up Your Environment

**Objective:** Create a virtual environment and install Flask.

```bash
# Step 1: Create project directory
mkdir my_flask_project
cd my_flask_project

# Step 2: Create virtual environment
python -m venv venv

# Step 3: Activate the environment
# On macOS/Linux:
source venv/bin/activate
# On Windows:
venv\Scripts\activate

# Step 4: Install Flask
pip install flask

# Step 5: Verify installation
python -c "import flask; print(flask.__version__)"
```

**Your Task:**
1. Create a new project directory called `flask_practice`
2. Set up a virtual environment
3. Install Flask and create a `requirements.txt` file
4. Verify Flask is installed correctly

**Write your steps and output here:**
```
# Your response:
```

---

### Exercise 1.2: Your First Flask Application

**Objective:** Create a simple Flask application with multiple routes.

```python
# app.py
from flask import Flask

app = Flask(__name__)

@app.route('/')
def home():
    return '<h1>Welcome to Flask!</h1>'

@app.route('/about')
def about():
    return '<h1>About This App</h1><p>Learning Flask is fun!</p>'

if __name__ == '__main__':
    app.run(debug=True)
```

**Your Task:**
1. Create the above application
2. Add a new route `/contact` that returns a contact message
3. Add a route `/user/<name>` that displays "Hello, {name}!"

**Write your code here:**
```python
# Your code
```

---

### Exercise 1.3: Application Factory Pattern

**Objective:** Convert your application to use the Application Factory pattern.

```python
# app/__init__.py
from flask import Flask

def create_app():
    app = Flask(__name__)
    
    @app.route('/')
    def home():
        return '<h1>Hello from Application Factory!</h1>'
    
    return app

# run.py
from app import create_app

app = create_app()

if __name__ == '__main__':
    app.run(debug=True)
```

**Your Task:**
1. Create the directory structure:
   ```
   my_app/
   ├── app/
   │   └── __init__.py
   └── run.py
   ```
2. Implement the Application Factory pattern
3. Add a configuration class with a `DEBUG` setting
4. Modify `create_app()` to accept a config object

**Write your code here:**
```python
# app/config.py

# app/__init__.py

# run.py
```

---

### Exercise 1.4: Blueprints

**Objective:** Organize routes using Blueprints.

```python
# app/blueprints/main.py
from flask import Blueprint

main_bp = Blueprint('main', __name__)

@main_bp.route('/')
def home():
    return '<h1>Home Page</h1>'

@main_bp.route('/about')
def about():
    return '<h1>About Page</h1>'

# app/blueprints/auth.py
from flask import Blueprint

auth_bp = Blueprint('auth', __name__, url_prefix='/auth')

@auth_bp.route('/login')
def login():
    return '<h1>Login Page</h1>'

@auth_bp.route('/register')
def register():
    return '<h1>Register Page</h1>'
```

**Your Task:**
1. Create the main and auth blueprints
2. Register them in the application factory
3. Add a new blueprint called `api` with a `/api` prefix
4. Add a route `/api/data` that returns JSON

**Write your code here:**
```python
# Your code
```

---

### Exercise 1.5: Configuration Management

**Objective:** Implement environment-specific configuration.

```python
# app/config.py
import os

class Config:
    SECRET_KEY = os.environ.get('SECRET_KEY', 'dev-secret-key')
    DEBUG = False
    TESTING = False

class DevelopmentConfig(Config):
    DEBUG = True
    DATABASE_URL = 'sqlite:///dev.db'

class ProductionConfig(Config):
    DATABASE_URL = os.environ.get('DATABASE_URL')
    SECRET_KEY = os.environ.get('SECRET_KEY')

class TestingConfig(Config):
    TESTING = True
    DATABASE_URL = 'sqlite:///:memory:'

config = {
    'development': DevelopmentConfig,
    'production': ProductionConfig,
    'testing': TestingConfig,
    'default': DevelopmentConfig
}
```

**Your Task:**
1. Implement the configuration classes above
2. Modify the application factory to use the correct config based on `FLASK_ENV`
3. Create a `.env.example` file with required environment variables
4. Add a route that displays the current environment

**Write your code here:**
```python
# Your code
```

---

### Exercise 1.6: Code Quality Tools

**Objective:** Set up code quality tools for your project.

```bash
# Install tools
pip install ruff black isort mypy pre-commit

# Create .pre-commit-config.yaml
# Create pyproject.toml with tool configurations
```

**Your Task:**
1. Install Ruff, Black, isort, and mypy
2. Create a `pyproject.toml` with configurations for all tools
3. Set up pre-commit hooks
4. Run the tools on your code

**Write your configurations here:**
```toml
# pyproject.toml
```

---

## Challenge Problems

### Challenge 1.1: Dynamic Blueprint Registration

Create a function that automatically discovers and registers all blueprints in a directory without explicitly importing each one.

**Hint:** Use `importlib` or `pkgutil` to discover modules.

**Write your solution here:**
```python
# Your solution
```

---

### Challenge 1.2: Configuration Validation

Implement a configuration validation system that checks:
1. All required variables are set
2. SECRET_KEY is at least 32 characters long
3. DATABASE_URL is properly formatted

**Write your solution here:**
```python
# Your solution
```

---

## Self-Assessment Quiz

1. What is the Application Factory pattern and why is it useful?

2. How do Blueprints help organize a Flask application?

3. What is the difference between `development`, `testing`, and `production` configurations?

4. Why should you use a virtual environment?

5. What does the `@app.route()` decorator do?

6. How do you access URL parameters in Flask?

7. What is the purpose of `url_for()`?

8. How do you handle different HTTP methods in Flask?

9. What is the role of `__name__` when creating a Flask app?

10. Why is it important to use environment variables for configuration?

---

## Project Milestone: TaskFlow Setup

**By the end of this section, you should have:**

- [ ] Created a virtual environment for TaskFlow
- [ ] Installed all required packages
- [ ] Set up the Application Factory pattern
- [ ] Created configuration classes (Development, Testing, Production)
- [ ] Implemented at least three Blueprints
- [ ] Configured code quality tools
- [ ] Added a `.env.example` file
- [ ] Created a `run.py` entry point
- [ ] Verified the app runs with `python run.py`

**Notes/Questions:**
```
```

---

# PART 2: ROUTING, REQUESTS & TEMPLATING

## Learning Objectives

By the end of this section, you will be able to:
- Create dynamic routes with URL parameters
- Use custom URL converters
- Build Jinja templates with inheritance
- Handle form data securely
- Implement flash messages
- Create custom error pages

---

## Key Concepts Review

### Fill in the Blanks

1. The __________ object contains all data sent in an HTTP request.

2. ___________ are reusable HTML components in Jinja2.

3. __________ provide a secure way to handle user input in Flask forms.

4. The __________ function is used to generate URLs dynamically.

5. ___________ messages provide feedback to users after form submissions.

### True or False

1. [ ] Flask routes can only handle GET requests.
2. [ ] Jinja templates automatically escape HTML to prevent XSS attacks.
3. [ ] You can create custom URL converters in Flask.
4. [ ] Flask-WTF is required to handle form data.
5. [ ] Flash messages persist across requests.

---

## Hands-On Exercises

### Exercise 2.1: Dynamic Routes

**Objective:** Create routes with dynamic URL parameters.

```python
@app.route('/user/<username>')
def profile(username):
    return f'<h1>Profile: {username}</h1>'

@app.route('/post/<int:post_id>')
def show_post(post_id):
    return f'<h1>Post #{post_id}</h1>'
```

**Your Task:**
1. Create a route that accepts a username and displays a profile
2. Create a route that accepts an integer post ID
3. Add a route `/search` that accepts a query parameter
4. Create a custom UUID converter

**Write your code here:**
```python
# Your code
```

---

### Exercise 2.2: Template Inheritance

**Objective:** Create a template hierarchy using Jinja2.

**base.html:**
```html
<!DOCTYPE html>
<html>
<head>
    <title>{% block title %}My Site{% endblock %}</title>
</head>
<body>
    <nav>
        <a href="/">Home</a>
        <a href="/about">About</a>
    </nav>
    <main>
        {% block content %}{% endblock %}
    </main>
    <footer>
        &copy; 2024 My Site
    </footer>
</body>
</html>
```

**index.html:**
```html
{% extends "base.html" %}

{% block title %}Home{% endblock %}

{% block content %}
    <h1>Welcome!</h1>
    <p>This is the homepage.</p>
{% endblock %}
```

**Your Task:**
1. Create a base template with navigation and footer
2. Create child templates for home, about, and contact pages
3. Add a block for additional CSS/JS
4. Create a macro for rendering form fields

**Write your code here:**
```html
<!-- Your templates -->
```

---

### Exercise 2.3: Form Handling

**Objective:** Create and process forms with Flask-WTF.

```python
# forms.py
from flask_wtf import FlaskForm
from wtforms import StringField, PasswordField, SubmitField
from wtforms.validators import DataRequired, Email, Length

class LoginForm(FlaskForm):
    email = StringField('Email', validators=[DataRequired(), Email()])
    password = PasswordField('Password', validators=[DataRequired()])
    submit = SubmitField('Login')

# routes.py
from forms import LoginForm

@app.route('/login', methods=['GET', 'POST'])
def login():
    form = LoginForm()
    if form.validate_on_submit():
        # Process login
        return redirect(url_for('dashboard'))
    return render_template('login.html', form=form)
```

**Your Task:**
1. Create a registration form with username, email, password, and confirm password
2. Add password strength validation
3. Create a task creation form
4. Handle form submission and display errors

**Write your code here:**
```python
# Your code
```

---

### Exercise 2.4: Flash Messages

**Objective:** Implement flash messages for user feedback.

```python
from flask import flash, redirect, url_for

@app.route('/submit', methods=['POST'])
def submit():
    flash('Form submitted successfully!', 'success')
    return redirect(url_for('home'))

@app.route('/error')
def error_example():
    flash('Something went wrong!', 'danger')
    return redirect(url_for('home'))
```

**Your Task:**
1. Add flash messages to the login and registration routes
2. Create a template that displays flash messages with Bootstrap styling
3. Auto-dismiss flash messages after 5 seconds
4. Add different message categories (success, danger, warning, info)

**Write your code here:**
```html
<!-- Your template code -->
```

---

### Exercise 2.5: Error Handling

**Objective:** Create custom error pages.

```python
@app.errorhandler(404)
def not_found(error):
    return render_template('errors/404.html'), 404

@app.errorhandler(500)
def internal_error(error):
    return render_template('errors/500.html'), 500

@app.errorhandler(403)
def forbidden(error):
    return render_template('errors/403.html'), 403
```

**Your Task:**
1. Create error templates for 404, 403, and 500
2. Add helpful messages and navigation links
3. Test that error pages work
4. Add logging for errors

**Write your code here:**
```html
<!-- Your error templates -->
```

---

## Challenge Problems

### Challenge 2.1: Custom Validator

Create a custom WTForms validator that checks if a username contains only alphanumeric characters and underscores.

**Write your solution here:**
```python
# Your solution
```

---

### Challenge 2.2: Template Filter

Create a custom Jinja2 filter that formats dates in a specific pattern (e.g., "January 1, 2024").

**Write your solution here:**
```python
# Your solution
```

---

## Self-Assessment Quiz

1. What are the different ways to pass data from routes to templates?

2. How does template inheritance work in Jinja2?

3. What is the purpose of `url_for()` and why is it preferred over hardcoding URLs?

4. How does Flask-WTF protect against CSRF attacks?

5. What are flash messages and when should you use them?

6. How do you create a custom error page?

7. What is the difference between `request.args` and `request.form`?

8. How do you create a custom URL converter?

---

## Project Milestone: TaskFlow UI

**By the end of this section, you should have:**

- [ ] Created dynamic routes for TaskFlow (tasks, users, profiles)
- [ ] Implemented template inheritance with a base template
- [ ] Created templates for all main pages
- [ ] Added forms for task creation and editing
- [ ] Implemented flash messages for user feedback
- [ ] Created custom error pages
- [ ] Added Bootstrap for styling
- [ ] Created custom template filters

**Notes/Questions:**
```
```

---

# PART 3: DATABASES, ORM & DATA MODELING

## Learning Objectives

By the end of this section, you will be able to:
- Define SQLAlchemy models
- Implement relationships (one-to-many, many-to-many)
- Perform CRUD operations
- Write complex queries
- Manage database migrations

---

## Key Concepts Review

### Fill in the Blanks

1. __________ is a SQLAlchemy pattern where each database row is represented by at most one Python object.

2. The __________ pattern separates data access logic from business logic.

3. __________ are used to manage database schema changes over time.

4. The ___________ pattern helps avoid N+1 query problems.

5. __________ provides a way to write raw SQL queries safely.

### True or False

1. [ ] SQLAlchemy automatically creates database tables from models.
2. [ ] The N+1 query problem occurs when you make multiple queries instead of using joins.
3. [ ] Alembic is used for database migrations.
4. [ ] You cannot use raw SQL with SQLAlchemy.
5. [ ] The session object tracks changes to models.

---

## Hands-On Exercises

### Exercise 3.1: Defining Models

**Objective:** Create database models for a blog application.

```python
from app.extensions import db
from datetime import datetime

class User(db.Model):
    __tablename__ = 'users'
    
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(50), unique=True, nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

class Post(db.Model):
    __tablename__ = 'posts'
    
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(200), nullable=False)
    content = db.Column(db.Text, nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'))
    
    user = db.relationship('User', backref='posts')
```

**Your Task:**
1. Create User and Post models
2. Add a Category model with a one-to-many relationship with Post
3. Add a Tag model with a many-to-many relationship with Post
4. Add timestamps (created_at, updated_at) to all models

**Write your code here:**
```python
# Your models
```

---

### Exercise 3.2: CRUD Operations

**Objective:** Implement CRUD operations for the blog models.

```python
# CREATE
user = User(username='john', email='john@example.com')
db.session.add(user)
db.session.commit()

# READ
users = User.query.all()
user = User.query.get(1)
users = User.query.filter_by(username='john').first()

# UPDATE
user = User.query.get(1)
user.email = 'newemail@example.com'
db.session.commit()

# DELETE
user = User.query.get(1)
db.session.delete(user)
db.session.commit()
```

**Your Task:**
1. Create a user with posts
2. Query all posts by a specific user
3. Update a post's content
4. Delete a post

**Write your code here:**
```python
# Your CRUD operations
```

---

### Exercise 3.3: Relationships

**Objective:** Work with model relationships.

```python
# One-to-Many
class User(db.Model):
    posts = db.relationship('Post', back_populates='user', lazy='dynamic')

class Post(db.Model):
    user = db.relationship('User', back_populates='posts')

# Many-to-Many
post_tags = db.Table('post_tags',
    db.Column('post_id', db.Integer, db.ForeignKey('posts.id')),
    db.Column('tag_id', db.Integer, db.ForeignKey('tags.id'))
)

class Post(db.Model):
    tags = db.relationship('Tag', secondary=post_tags, back_populates='posts')

class Tag(db.Model):
    posts = db.relationship('Post', secondary=post_tags, back_populates='tags')
```

**Your Task:**
1. Create the many-to-many relationship between Post and Tag
2. Add a post with multiple tags
3. Find all posts with a specific tag
4. Use eager loading to fetch posts with their authors

**Write your code here:**
```python
# Your relationship code
```

---

### Exercise 3.4: Advanced Queries

**Objective:** Write complex queries using SQLAlchemy.

```python
from sqlalchemy import func, desc, and_, or_

# Count posts by user
posts_by_user = db.session.query(
    User.username,
    func.count(Post.id).label('post_count')
).join(Post).group_by(User.id).all()

# Find recent posts
recent_posts = Post.query.order_by(desc(Post.created_at)).limit(10).all()

# Search posts
search = 'python'
posts = Post.query.filter(
    or_(
        Post.title.ilike(f'%{search}%'),
        Post.content.ilike(f'%{search}%')
    )
).all()
```

**Your Task:**
1. Find all posts by a specific user in the last 30 days
2. Get the average number of posts per user
3. Search for posts containing a keyword
4. Get the most recent 5 posts with their authors

**Write your code here:**
```python
# Your queries
```

---

### Exercise 3.5: Database Migrations

**Objective:** Manage schema changes with Alembic.

```bash
# Initialize migrations
flask db init

# Create migration
flask db migrate -m "Add user profile fields"

# Apply migration
flask db upgrade

# Rollback
flask db downgrade -1
```

**Your Task:**
1. Initialize migrations for your blog app
2. Add a `bio` field to the User model
3. Generate and apply the migration
4. Add a `published_at` field to Post
5. Generate and apply another migration

**Write your commands and output here:**
```
# Your migration commands
```

---

### Exercise 3.6: Repository Pattern

**Objective:** Implement the Repository pattern.

```python
class PostRepository:
    @staticmethod
    def get_by_id(post_id):
        return Post.query.get(post_id)
    
    @staticmethod
    def get_user_posts(user_id):
        return Post.query.filter_by(user_id=user_id).order_by(Post.created_at.desc()).all()
    
    @staticmethod
    def create(data):
        post = Post(**data)
        db.session.add(post)
        db.session.commit()
        return post
    
    @staticmethod
    def update(post, data):
        for key, value in data.items():
            setattr(post, key, value)
        db.session.commit()
        return post

class PostService:
    @staticmethod
    def get_recent_posts(limit=10):
        return Post.query.order_by(desc(Post.created_at)).limit(limit).all()
    
    @staticmethod
    def create_post(user, data):
        data['user_id'] = user.id
        return PostRepository.create(data)
```

**Your Task:**
1. Implement the Repository pattern for your models
2. Create a Service layer for business logic
3. Use the service in your routes instead of direct database access

**Write your code here:**
```python
# Your repository and service code
```

---

## Challenge Problems

### Challenge 3.1: Recursive Relationship

Create a self-referencing relationship for comments (comments can have replies).

**Write your solution here:**
```python
# Your solution
```

---

### Challenge 3.2: Query Optimization

Write a query that retrieves posts with their authors and the count of comments each post has, optimized to avoid N+1 queries.

**Write your solution here:**
```python
# Your solution
```

---

## Self-Assessment Quiz

1. What is the difference between `lazy='select'` and `lazy='joined'`?

2. How does the session track changes to models?

3. What is the purpose of `db.create_all()`?

4. When would you use `selectinload()` versus `joinedload()`?

5. How do you handle database migrations in production?

6. What is the N+1 query problem and how do you solve it?

7. How do you write a raw SQL query with SQLAlchemy?

8. What is the difference between `query` and `session`?

---

## Project Milestone: TaskFlow Database

**By the end of this section, you should have:**

- [ ] Created User, Task, Category, and Tag models
- [ ] Implemented all relationships (one-to-many, many-to-many)
- [ ] Set up database migrations
- [ ] Created the Repository pattern for data access
- [ ] Implemented the Service layer
- [ ] Written complex queries for the dashboard
- [ ] Added indexes for performance
- [ ] Seeded the database with test data

**Notes/Questions:**
```
```

---

# PART 4: AUTHENTICATION, AUTHORIZATION & SECURITY

## Learning Objectives

By the end of this section, you will be able to:
- Implement user registration and login
- Use password hashing for security
- Manage user sessions with Flask-Login
- Implement role-based access control
- Protect against CSRF attacks
- Add security headers

---

## Key Concepts Review

### Fill in the Blanks

1. __________ is the process of verifying a user's identity.

2. __________ determines what authenticated users can do.

3. Password hashing uses a __________ to make brute-force attacks more difficult.

4. The __________ pattern manages user sessions.

5. __________ tokens protect against cross-site request forgery attacks.

### True or False

1. [ ] Password hashing is reversible.
2. [ ] Flask-Login automatically handles user sessions.
3. [ ] CSRF protection is only needed for GET requests.
4. [ ] Role-based access control uses permissions to authorize users.
5. [ ] Security headers should only be added in production.

---

## Hands-On Exercises

### Exercise 4.1: User Model with Authentication

**Objective:** Create a User model with password hashing.

```python
from werkzeug.security import generate_password_hash, check_password_hash
from flask_login import UserMixin
from app.extensions import db

class User(db.Model, UserMixin):
    __tablename__ = 'users'
    
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(50), unique=True, nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=False)
    password_hash = db.Column(db.String(128), nullable=False)
    
    def set_password(self, password):
        self.password_hash = generate_password_hash(password)
    
    def check_password(self, password):
        return check_password_hash(self.password_hash, password)
```

**Your Task:**
1. Create the User model with password hashing
2. Add fields for first_name, last_name, and bio
3. Add is_active and is_admin boolean fields
4. Create test users in the database

**Write your code here:**
```python
# Your User model
```

---

### Exercise 4.2: Registration & Login

**Objective:** Implement user registration and login.

```python
from flask_login import login_user, logout_user, login_required, current_user
from forms import RegistrationForm, LoginForm

@app.route('/register', methods=['GET', 'POST'])
def register():
    form = RegistrationForm()
    if form.validate_on_submit():
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

@app.route('/login', methods=['GET', 'POST'])
def login():
    form = LoginForm()
    if form.validate_on_submit():
        user = User.query.filter_by(email=form.email.data).first()
        if user and user.check_password(form.password.data):
            login_user(user, remember=form.remember.data)
            return redirect(url_for('dashboard'))
        flash('Invalid credentials', 'danger')
    return render_template('login.html', form=form)
```

**Your Task:**
1. Implement the registration and login routes
2. Add form validation
3. Add flash messages for success and error states
4. Implement logout

**Write your code here:**
```python
# Your authentication code
```

---

### Exercise 4.3: Role-Based Access Control

**Objective:** Implement RBAC for your application.

```python
from functools import wraps
from flask import abort

class UserRole:
    USER = 'user'
    ADMIN = 'admin'
    MANAGER = 'manager'

def role_required(role):
    def decorator(f):
        @wraps(f)
        def decorated(*args, **kwargs):
            if not current_user.is_authenticated:
                return redirect(url_for('login'))
            if current_user.role != role and current_user.role != 'admin':
                abort(403)
            return f(*args, **kwargs)
        return decorated
    return decorator

@app.route('/admin')
@role_required(UserRole.ADMIN)
def admin_panel():
    return render_template('admin.html')
```

**Your Task:**
1. Add role field to the User model
2. Create the role_required decorator
3. Protect admin routes
4. Add permission checking for task operations (view, edit, delete)

**Write your code here:**
```python
# Your RBAC implementation
```

---

### Exercise 4.4: CSRF Protection

**Objective:** Implement CSRF protection for forms.

```python
from flask_wtf.csrf import CSRFProtect

csrf = CSRFProtect(app)

# Forms automatically include CSRF token
class LoginForm(FlaskForm):
    email = StringField('Email', validators=[DataRequired()])
    password = PasswordField('Password', validators=[DataRequired()])

# For AJAX requests
# In template:
# <meta name="csrf-token" content="{{ csrf_token() }}">

# In JavaScript:
# fetch('/api/data', {
#     method: 'POST',
#     headers: {
#         'X-CSRFToken': document.querySelector('meta[name="csrf-token"]').content
#     }
# })
```

**Your Task:**
1. Enable CSRF protection for your application
2. Add CSRF tokens to all forms
3. Implement CSRF protection for AJAX requests
4. Test CSRF protection

**Write your code here:**
```python
# Your CSRF implementation
```

---

### Exercise 4.5: Security Headers

**Objective:** Add security headers to your application.

```python
@app.after_request
def add_security_headers(response):
    response.headers['Strict-Transport-Security'] = 'max-age=31536000; includeSubDomains'
    response.headers['X-Frame-Options'] = 'SAMEORIGIN'
    response.headers['X-Content-Type-Options'] = 'nosniff'
    response.headers['X-XSS-Protection'] = '1; mode=block'
    response.headers['Referrer-Policy'] = 'strict-origin-when-cross-origin'
    response.headers['Content-Security-Policy'] = "default-src 'self'"
    return response
```

**Your Task:**
1. Add security headers to all responses
2. Configure CSP for your specific needs
3. Add HSTS header
4. Test headers with browser dev tools

**Write your code here:**
```python
# Your security headers
```

---

## Challenge Problems

### Challenge 4.1: Two-Factor Authentication

Implement two-factor authentication for user login.

**Write your solution here:**
```python
# Your 2FA implementation
```

---

### Challenge 4.2: Password Reset

Implement a password reset flow with email tokens.

**Write your solution here:**
```python
# Your password reset implementation
```

---

## Self-Assessment Quiz

1. What is the difference between `generate_password_hash` and `check_password_hash`?

2. How does Flask-Login manage user sessions?

3. What is the purpose of CSRF protection?

4. How do you protect routes that require admin access?

5. What security headers should you add to a Flask application?

6. How do you handle "remember me" functionality?

7. What is the difference between authentication and authorization?

---

## Project Milestone: TaskFlow Security

**By the end of this section, you should have:**

- [ ] User model with password hashing
- [ ] Registration and login functionality
- [ ] Session management with Flask-Login
- [ ] Role-based access control (User, Manager, Admin)
- [ ] CSRF protection for all forms
- [ ] Security headers implemented
- [ ] User profile management
- [ ] Password reset functionality

**Notes/Questions:**
```
```

---

# PART 5: BUILDING RESTFUL APIS

## Learning Objectives

By the end of this section, you will be able to:
- Design RESTful API endpoints
- Use Marshmallow for serialization
- Implement token-based authentication
- Add rate limiting
- Create API documentation
- Version APIs

---

## Key Concepts Review

### Fill in the Blanks

1. REST stands for __________.

2. __________ is used for serializing Python objects to JSON.

3. __________ authentication uses tokens instead of sessions.

4. The HTTP method __________ is used to update resources partially.

5. __________ is a specification for describing REST APIs.

### True or False

1. [ ] REST APIs should use nouns for resources.
2. [ ] The PUT method should be idempotent.
3. [ ] API versioning is optional in REST APIs.
4. [ ] Rate limiting helps prevent API abuse.
5. [ ] 404 status code means "Not Found".

---

## Hands-On Exercises

### Exercise 5.1: API Endpoints

**Objective:** Create REST API endpoints for your models.

```python
from flask import Blueprint, request, jsonify
from app.schemas import TaskSchema
from app.services import TaskService

api_bp = Blueprint('api', __name__, url_prefix='/api')

@api_bp.route('/tasks', methods=['GET'])
def list_tasks():
    tasks = TaskService.get_all()
    schema = TaskSchema(many=True)
    return jsonify(schema.dump(tasks))

@api_bp.route('/tasks', methods=['POST'])
def create_task():
    data = request.get_json()
    task = TaskService.create(data)
    schema = TaskSchema()
    return jsonify(schema.dump(task)), 201
```

**Your Task:**
1. Create API endpoints for CRUD operations on tasks
2. Add filtering and pagination to list endpoint
3. Implement proper HTTP status codes
4. Add error handling

**Write your code here:**
```python
# Your API endpoints
```

---

### Exercise 5.2: Serialization with Marshmallow

**Objective:** Create schemas for your models.

```python
from marshmallow import Schema, fields, validate

class TaskSchema(Schema):
    id = fields.Int(dump_only=True)
    title = fields.Str(required=True, validate=validate.Length(min=1, max=200))
    description = fields.Str(allow_none=True)
    status = fields.Str(validate=validate.OneOf(['pending', 'in_progress', 'completed']))
    priority = fields.Str(validate=validate.OneOf(['low', 'medium', 'high']))
    created_at = fields.DateTime(dump_only=True)
    updated_at = fields.DateTime(dump_only=True)
    user_id = fields.Int(required=True)
```

**Your Task:**
1. Create schemas for User, Task, and Category
2. Add validation rules
3. Handle nested relationships
4. Add custom fields (e.g., full_name for User)

**Write your code here:**
```python
# Your schemas
```

---

### Exercise 5.3: Token Authentication

**Objective:** Implement JWT authentication for your API.

```python
import jwt
from functools import wraps
from flask import request, jsonify, g

SECRET_KEY = 'your-secret-key'

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
        
        token = auth_header[7:]
        try:
            payload = jwt.decode(token, SECRET_KEY, algorithms=['HS256'])
            g.user_id = payload['user_id']
        except:
            return jsonify({'error': 'Invalid token'}), 401
        
        return f(*args, **kwargs)
    return decorated

@api_bp.route('/login', methods=['POST'])
def api_login():
    data = request.get_json()
    user = User.query.filter_by(email=data.get('email')).first()
    if user and user.check_password(data.get('password')):
        token = generate_token(user.id)
        return jsonify({'token': token})
    return jsonify({'error': 'Invalid credentials'}), 401
```

**Your Task:**
1. Implement JWT token generation
2. Add token verification decorator
3. Protect API endpoints with token authentication
4. Implement token refresh

**Write your code here:**
```python
# Your authentication implementation
```

---

### Exercise 5.4: Rate Limiting

**Objective:** Add rate limiting to your API.

```python
from flask_limiter import Limiter
from flask_limiter.util import get_remote_address

limiter = Limiter(app, key_func=get_remote_address)

@api_bp.route('/tasks')
@limiter.limit("100 per minute")
def list_tasks():
    # ...

@api_bp.route('/tasks', methods=['POST'])
@limiter.limit("30 per minute")
def create_task():
    # ...

@api_bp.route('/login', methods=['POST'])
@limiter.limit("5 per minute", error_message="Too many login attempts")
def api_login():
    # ...
```

**Your Task:**
1. Configure rate limiting for your API
2. Set different limits for different endpoints
3. Add user-based rate limiting
4. Handle rate limit errors gracefully

**Write your code here:**
```python
# Your rate limiting implementation
```

---

### Exercise 5.5: API Documentation

**Objective:** Document your API with Swagger/OpenAPI.

```python
from flask_swagger_ui import get_swaggerui_blueprint
from apispec import APISpec

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
    spec = APISpec(
        title='TaskFlow API',
        version='1.0.0',
        openapi_version='3.0.2'
    )
    # Add schemas and endpoints
    return jsonify(spec.to_dict())
```

**Your Task:**
1. Set up Swagger UI
2. Create OpenAPI specification
3. Document all endpoints
4. Add request/response examples

**Write your code here:**
```python
# Your documentation implementation
```

---

## Challenge Problems

### Challenge 5.1: Bulk Operations

Implement bulk create, update, and delete operations for your API.

**Write your solution here:**
```python
# Your bulk operations
```

---

### Challenge 5.2: API Versioning

Implement URL-based versioning for your API.

**Write your solution here:**
```python
# Your versioning implementation
```

---

## Self-Assessment Quiz

1. What are the key principles of REST API design?

2. What is the difference between PUT and PATCH?

3. Why is statelessness important in REST APIs?

4. How do you handle validation errors in an API?

5. What is the purpose of API versioning?

6. How does token-based authentication work?

7. Why do you need rate limiting?

8. What is HATEOAS and why is it important?

---

## Project Milestone: TaskFlow API

**By the end of this section, you should have:**

- [ ] Complete CRUD API for tasks
- [ ] Authentication with JWT tokens
- [ ] Rate limiting implemented
- [ ] API documentation with Swagger
- [ ] Input validation with Marshmallow
- [ ] Proper error handling
- [ ] Versioned API endpoints
- [ ] API tests

**Notes/Questions:**
```
```

---

# PART 6: ASYNC PROGRAMMING & BACKGROUND PROCESSING

## Learning Objectives

By the end of this section, you will be able to:
- Write async view functions in Flask 3.x
- Set up Celery for background tasks
- Use Redis as a message broker
- Create and schedule background tasks
- Monitor task execution

---

## Key Concepts Review

### Fill in the Blanks

1. __________ allows multiple operations to run concurrently without blocking.

2. __________ is a distributed task queue for Python.

3. __________ is used as a message broker for Celery.

4. The __________ pattern sends tasks to be processed in the background.

5. __________ is a monitoring tool for Celery.

### True or False

1. [ ] Async views in Flask can improve performance for I/O-bound operations.
2. [ ] Celery tasks are executed immediately when called.
3. [ ] Redis can be used as both a broker and a result backend.
4. [ ] Scheduled tasks in Celery are called periodic tasks.
5. [ ] Async views should be used for CPU-intensive operations.

---

## Hands-On Exercises

### Exercise 6.1: Async Views

**Objective:** Implement async view functions.

```python
import asyncio
import httpx

@app.route('/api/async-example')
async def async_example():
    await asyncio.sleep(1)
    return jsonify({'message': 'Async response'})

@app.route('/api/external-data')
async def fetch_external():
    async with httpx.AsyncClient() as client:
        tasks = [
            client.get('https://api1.example.com/data'),
            client.get('https://api2.example.com/data')
        ]
        results = await asyncio.gather(*tasks)
    return jsonify([r.json() for r in results])
```

**Your Task:**
1. Create an async view that fetches data from multiple APIs
2. Add error handling for failed requests
3. Implement a timeout for external requests
4. Combine async and sync code safely

**Write your code here:**
```python
# Your async views
```

---

### Exercise 6.2: Celery Setup

**Objective:** Configure Celery for background tasks.

```python
# celery_worker.py
from celery import Celery

celery = Celery(
    'myapp',
    broker='redis://localhost:6379/0',
    backend='redis://localhost:6379/1'
)

celery.conf.update(
    task_serializer='json',
    accept_content=['json'],
    result_serializer='json',
    timezone='UTC',
    enable_utc=True
)

celery.autodiscover_tasks(['app.tasks'])
```

**Your Task:**
1. Set up Celery configuration
2. Create a celery_worker.py file
3. Configure Redis connection
4. Start the Celery worker

**Write your code here:**
```python
# Your Celery configuration
```

---

### Exercise 6.3: Creating Tasks

**Objective:** Define and use Celery tasks.

```python
# app/tasks/email.py
from app.celery_worker import celery

@celery.task
def send_email(recipient, subject, body):
    # Send email
    return {'status': 'sent', 'recipient': recipient}

@celery.task(bind=True, max_retries=3)
def process_document(self, document_id):
    try:
        # Process document
        return {'status': 'processed'}
    except Exception as e:
        self.retry(exc=e, countdown=60)
```

**Your Task:**
1. Create email sending task
2. Create a report generation task
3. Add retry logic
4. Handle task failures

**Write your code here:**
```python
# Your tasks
```

---

### Exercise 6.4: Using Tasks in Routes

**Objective:** Integrate background tasks with routes.

```python
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
    
    return redirect(url_for('home'))

@app.route('/tasks/export')
@login_required
def export_tasks():
    task = generate_report.delay(current_user.id)
    return jsonify({
        'task_id': task.id,
        'status': 'started'
    })

@app.route('/tasks/status/<task_id>')
def task_status(task_id):
    from celery.result import AsyncResult
    result = AsyncResult(task_id, app=celery)
    return jsonify({
        'status': result.status,
        'result': result.result if result.ready() else None
    })
```

**Your Task:**
1. Use tasks in routes
2. Add task status tracking
3. Implement a task queue for export operations
4. Add task cancellation

**Write your code here:**
```python
# Your route integration
```

---

### Exercise 6.5: Scheduled Tasks

**Objective:** Implement scheduled tasks with Celery Beat.

```python
from celery.schedules import crontab

celery.conf.beat_schedule = {
    'daily-report': {
        'task': 'app.tasks.generate_report',
        'schedule': crontab(hour=8, minute=0),
        'kwargs': {'user_id': None}
    },
    'cleanup': {
        'task': 'app.tasks.cleanup_old_data',
        'schedule': crontab(day_of_week=0, hour=0, minute=0)
    }
}
```

**Your Task:**
1. Configure Celery Beat
2. Create a daily report task
3. Create a weekly cleanup task
4. Monitor scheduled task execution

**Write your code here:**
```python
# Your scheduled tasks
```

---

## Challenge Problems

### Challenge 6.1: Task Chaining

Create a chain of tasks where the output of one task feeds into the next.

**Write your solution here:**
```python
# Your task chain
```

---

### Challenge 6.2: Task Progress Tracking

Implement a task with progress tracking that updates the user on the status.

**Write your solution here:**
```python
# Your progress tracking
```

---

## Self-Assessment Quiz

1. When should you use async views vs Celery tasks?

2. What is the role of Redis in Celery?

3. How do you retry a failed Celery task?

4. What is the difference between `task.delay()` and `task.apply_async()`?

5. How do you schedule recurring tasks in Celery?

6. What is the purpose of Celery Beat?

7. How do you monitor Celery tasks?

8. What are the limitations of async views in Flask?

---

## Project Milestone: TaskFlow Background Tasks

**By the end of this section, you should have:**

- [ ] Async views for API endpoints
- [ ] Celery configured with Redis
- [ ] Email sending as background task
- [ ] Report generation as background task
- [ ] Task status tracking
- [ ] Scheduled tasks (daily reports, cleanup)
- [ ] Task monitoring with Flower
- [ ] Error handling and retries

**Notes/Questions:**
```
```

---

# PART 7: TESTING, DEBUGGING & QUALITY ASSURANCE

## Learning Objectives

By the end of this section, you will be able to:
- Write unit tests with Pytest
- Create integration tests
- Write functional tests
- Measure test coverage
- Use debugging tools
- Maintain code quality

---

## Key Concepts Review

### Fill in the Blanks

1. __________ tests verify individual components in isolation.

2. __________ tests verify that components work together.

3. __________ tests verify complete user workflows.

4. __________ measures the percentage of code covered by tests.

5. __________ is a Python debugger.

### True or False

1. [ ] Unit tests should be fast and isolated.
2. [ ] Integration tests require a real database.
3. [ ] Coverage should always be 100%.
4. [ ] Debugging tools should not be used in production.
5. [ ] Pre-commit hooks run automatically before commits.

---

## Hands-On Exercises

### Exercise 7.1: Writing Unit Tests

**Objective:** Write unit tests for your models.

```python
# tests/test_models.py
import pytest
from app.models.user import User

class TestUserModel:
    def test_create_user(self, db_session):
        user = User(username='testuser', email='test@example.com')
        user.set_password('password123')
        db_session.add(user)
        db_session.commit()
        
        assert user.id is not None
        assert user.username == 'testuser'
        assert user.check_password('password123') is True
    
    def test_unique_username(self, db_session):
        user1 = User(username='testuser', email='test1@example.com')
        user2 = User(username='testuser', email='test2@example.com')
        db_session.add(user1)
        db_session.commit()
        
        with pytest.raises(Exception):
            db_session.add(user2)
            db_session.commit()
```

**Your Task:**
1. Write tests for the User model
2. Write tests for the Task model
3. Test model relationships
4. Test validations and constraints

**Write your code here:**
```python
# Your unit tests
```

---

### Exercise 7.2: Testing Forms

**Objective:** Write tests for form validation.

```python
# tests/test_forms.py
from app.forms.auth import RegistrationForm

class TestRegistrationForm:
    def test_valid_form(self):
        form = RegistrationForm(
            username='testuser',
            email='test@example.com',
            password='Password123!',
            confirm_password='Password123!'
        )
        assert form.validate() is True
    
    def test_password_mismatch(self):
        form = RegistrationForm(
            username='testuser',
            email='test@example.com',
            password='Password123!',
            confirm_password='Different!'
        )
        assert form.validate() is False
        assert 'confirm_password' in form.errors
```

**Your Task:**
1. Write tests for login form
2. Write tests for registration form
3. Write tests for task form
4. Test custom validators

**Write your code here:**
```python
# Your form tests
```

---

### Exercise 7.3: Testing Routes

**Objective:** Write integration tests for routes.

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

**Your Task:**
1. Write tests for public routes
2. Write tests for protected routes
3. Test authentication flow
4. Test error handling

**Write your code here:**
```python
# Your route tests
```

---

### Exercise 7.4: Testing APIs

**Objective:** Write tests for API endpoints.

```python
# tests/test_api.py
class TestAPI:
    def test_get_tasks(self, auth_client, test_task):
        response = auth_client.get('/api/tasks')
        assert response.status_code == 200
        data = response.json
        assert len(data) >= 1
        assert data[0]['title'] == 'Test Task'
    
    def test_create_task(self, auth_client):
        response = auth_client.post('/api/tasks', 
            json={'title': 'API Test'}
        )
        assert response.status_code == 201
        assert response.json['title'] == 'API Test'
    
    def test_api_authentication(self, client):
        response = client.get('/api/tasks')
        assert response.status_code == 302
```

**Your Task:**
1. Write tests for all API endpoints
2. Test authentication
3. Test validation
4. Test error responses

**Write your code here:**
```python
# Your API tests
```

---

### Exercise 7.5: Debugging

**Objective:** Practice debugging techniques.

```python
import pdb

def debug_example(data):
    pdb.set_trace()  # Breakpoint
    result = process(data)
    return result

# pdb Commands:
# n - next line
# s - step into
# c - continue
# p variable - print variable
# l - list code
# q - quit
```

**Your Task:**
1. Use print debugging
2. Use the Python debugger (pdb)
3. Use logging for debugging
4. Analyze SQLAlchemy queries

**Write your debugging notes here:**
```
# Your debugging examples
```

---

### Exercise 7.6: Code Quality

**Objective:** Use code quality tools.

```bash
# Format code
black app/ tests/

# Sort imports
isort app/ tests/

# Lint code
ruff check app/ tests/

# Type check
mypy app/

# Run pre-commit
pre-commit run --all-files
```

**Your Task:**
1. Configure Black, Ruff, and isort
2. Run tools on your code
3. Fix any issues
4. Set up pre-commit hooks

**Write your configurations here:**
```toml
# pyproject.toml
```

---

## Challenge Problems

### Challenge 7.1: Mocking External Services

Write tests that mock external API calls.

**Write your solution here:**
```python
# Your mocking implementation
```

---

### Challenge 7.2: End-to-End Testing

Write an end-to-end test that simulates a complete user workflow.

**Write your solution here:**
```python
# Your E2E test
```

---

## Self-Assessment Quiz

1. What is the difference between a unit test and an integration test?

2. Why should tests be isolated from each other?

3. What is test coverage and why does it matter?

4. How do you mock external services in tests?

5. What are the benefits of pre-commit hooks?

6. How do you debug a Flask application?

7. What is the role of fixtures in Pytest?

8. How do you test database operations?

---

## Project Milestone: TaskFlow Testing

**By the end of this section, you should have:**

- [ ] Unit tests for all models
- [ ] Unit tests for all forms
- [ ] Integration tests for routes
- [ ] Integration tests for APIs
- [ ] Functional tests for user workflows
- [ ] Test coverage above 80%
- [ ] Pre-commit hooks configured
- [ ] CI/CD pipeline with tests

**Notes/Questions:**
```
```

---

# PART 8: PRODUCTION DEPLOYMENT, DEVOPS & MONITORING

## Learning Objectives

By the end of this section, you will be able to:
- Configure Gunicorn for production
- Set up Nginx as a reverse proxy
- Containerize applications with Docker
- Deploy to cloud platforms
- Implement CI/CD pipelines
- Monitor and log applications

---

## Key Concepts Review

### Fill in the Blanks

1. __________ is a production WSGI server for Python applications.

2. __________ is used as a reverse proxy to serve static files and handle SSL.

3. __________ packages applications with their dependencies in containers.

4. __________ automates the testing and deployment process.

5. __________ collects and visualizes application metrics.

### True or False

1. [ ] The Flask development server is suitable for production.
2. [ ] Docker ensures consistent environments across development and production.
3. [ ] Gunicorn can handle multiple requests concurrently.
4. [ ] Nginx should handle SSL termination.
5. [ ] CI/CD pipelines should run tests before deployment.

---

## Hands-On Exercises

### Exercise 8.1: Gunicorn Configuration

**Objective:** Configure Gunicorn for production.

```python
# gunicorn.conf.py
import multiprocessing

bind = '0.0.0.0:8000'
workers = multiprocessing.cpu_count() * 2 + 1
worker_class = 'sync'
threads = 2
timeout = 120
preload_app = True
max_requests = 1000
```

**Your Task:**
1. Create a gunicorn.conf.py file
2. Configure workers based on CPU count
3. Set appropriate timeouts
4. Enable preloading

**Write your configuration here:**
```python
# Your gunicorn.conf.py
```

---

### Exercise 8.2: Docker Setup

**Objective:** Containerize your application with Docker.

```dockerfile
# Dockerfile
FROM python:3.13-slim

WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .

EXPOSE 8000
CMD ["gunicorn", "-c", "gunicorn.conf.py", "run:app"]
```

```yaml
# docker-compose.yml
version: '3.8'

services:
  web:
    build: .
    ports:
      - "8000:8000"
    environment:
      - FLASK_ENV=production
    depends_on:
      - db
      - redis
  
  db:
    image: postgres:15
    environment:
      - POSTGRES_USER=taskflow
      - POSTGRES_PASSWORD=password
  
  redis:
    image: redis:7-alpine
```

**Your Task:**
1. Create a Dockerfile
2. Create a docker-compose.yml file
3. Build and run your containers
4. Test the application in containers

**Write your configuration here:**
```dockerfile
# Your Dockerfile
```

---

### Exercise 8.3: CI/CD Pipeline

**Objective:** Set up a CI/CD pipeline with GitHub Actions.

```yaml
# .github/workflows/deploy.yml
name: Deploy

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
        run: pip install -r requirements.txt
      - name: Run tests
        run: pytest

  deploy:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - name: Deploy to server
        run: |
          ssh user@server "cd /app && git pull && docker-compose up -d --build"
```

**Your Task:**
1. Create a GitHub Actions workflow
2. Add test steps
3. Add build steps
4. Add deployment steps

**Write your configuration here:**
```yaml
# Your workflow file
```

---

### Exercise 8.4: Monitoring & Logging

**Objective:** Implement monitoring and logging.

```python
# Health check endpoint
@app.route('/health')
def health():
    return jsonify({
        'status': 'healthy',
        'timestamp': datetime.utcnow().isoformat()
    })

# Logging setup
import logging
from logging.handlers import RotatingFileHandler

file_handler = RotatingFileHandler(
    'logs/app.log',
    maxBytes=10*1024*1024,
    backupCount=5
)
file_handler.setLevel(logging.INFO)
app.logger.addHandler(file_handler)
```

**Your Task:**
1. Add a health check endpoint
2. Configure logging
3. Add performance metrics
4. Set up monitoring alerts

**Write your code here:**
```python
# Your monitoring implementation
```

---

### Exercise 8.5: Deployment Scripts

**Objective:** Create deployment scripts.

```bash
#!/bin/bash
# deploy.sh

set -e

echo "Deploying application..."

# Pull latest code
git pull origin main

# Install dependencies
source venv/bin/activate
pip install -r requirements.txt

# Run migrations
flask db upgrade

# Restart application
sudo systemctl restart taskflow

# Verify deployment
curl -f http://localhost:8000/health

echo "Deployment complete!"
```

**Your Task:**
1. Create a deployment script
2. Add migration steps
3. Add verification steps
4. Create a rollback script

**Write your scripts here:**
```bash
# Your deployment scripts
```

---

## Challenge Problems

### Challenge 8.1: Blue-Green Deployment

Implement a blue-green deployment strategy.

**Write your solution here:**
```bash
# Your blue-green deployment
```

---

### Challenge 8.2: Auto-Scaling

Configure auto-scaling based on CPU or request load.

**Write your solution here:**
```
# Your auto-scaling configuration
```

---

## Self-Assessment Quiz

1. Why is Gunicorn preferred over the Flask development server in production?

2. What is the role of Nginx in a production setup?

3. How does Docker help with deployment?

4. What are the benefits of CI/CD?

5. Why do you need health checks?

6. What should be included in a production checklist?

7. How do you handle database migrations in production?

8. What is the difference between blue-green and canary deployments?

---

## Project Milestone: TaskFlow Production

**By the end of this section, you should have:**

- [ ] Gunicorn configured for production
- [ ] Nginx configuration for reverse proxy
- [ ] Docker containerization
- [ ] CI/CD pipeline configured
- [ ] Health check endpoint
- [ ] Production logging
- [ ] Deployment scripts
- [ ] Backup and recovery plan

**Notes/Questions:**
```
```

---

# FINAL PROJECT: TASKFLOW COMPLETE

## Project Overview

**Task:** Build a complete task management application called TaskFlow.

**Requirements:**
- User authentication (register, login, logout)
- User profiles
- Task CRUD operations
- Categories and tags
- Task search and filtering
- RESTful API
- Background tasks (email notifications)
- Testing suite
- Production deployment

---

## Project Milestones

### Milestone 1: Project Setup (Week 1)
- [ ] Create project directory structure
- [ ] Set up virtual environment
- [ ] Install dependencies
- [ ] Configure Application Factory
- [ ] Set up Blueprints
- [ ] Configure code quality tools

### Milestone 2: Models & Database (Week 1-2)
- [ ] Create User model
- [ ] Create Task model
- [ ] Create Category model
- [ ] Create Tag model
- [ ] Set up relationships
- [ ] Configure migrations

### Milestone 3: Authentication (Week 2)
- [ ] User registration
- [ ] User login/logout
- [ ] Password hashing
- [ ] Session management
- [ ] Role-based access control

### Milestone 4: Core Features (Week 2-3)
- [ ] Task CRUD
- [ ] Category management
- [ ] Tag management
- [ ] Task search and filtering
- [ ] User profiles

### Milestone 5: API Development (Week 3)
- [ ] RESTful endpoints
- [ ] JSON serialization
- [ ] Token authentication
- [ ] Rate limiting
- [ ] API documentation

### Milestone 6: Background Tasks (Week 3-4)
- [ ] Celery configuration
- [ ] Email tasks
- [ ] Report generation
- [ ] Scheduled tasks
- [ ] Task monitoring

### Milestone 7: Testing (Week 4)
- [ ] Unit tests
- [ ] Integration tests
- [ ] Functional tests
- [ ] API tests
- [ ] Coverage report

### Milestone 8: Deployment (Week 4)
- [ ] Gunicorn configuration
- [ ] Docker containerization
- [ ] CI/CD pipeline
- [ ] Production deployment
- [ ] Monitoring setup

---

## Final Checklist

**Before submission, ensure:**

- [ ] All features work correctly
- [ ] All tests pass
- [ ] Code is formatted and linted
- [ ] Documentation is complete
- [ ] Deployment works
- [ ] Security best practices followed
- [ ] Performance is optimized

---

## Self-Reflection

What was the most challenging part of building TaskFlow?

```
```

What part did you enjoy the most?

```
```

What would you do differently next time?

```
```

What new skills did you gain?

```
```

What are your next steps in your Flask journey?

```
```

---

**Congratulations on completing the Master Modern Flask 3.x course!**

*You now have the skills to build, test, and deploy production-ready Flask applications.*
