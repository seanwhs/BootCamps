# Master Modern Flask 3.x: Trainer Guide

## Comprehensive Instructor's Manual for Teaching Flask Development

---

# HOW TO USE THIS TRAINER GUIDE

This trainer guide is designed to support instructors delivering the "Master Modern Flask 3.x" course. It provides:

1. **Course Planning** - Curriculum structure and scheduling
2. **Teaching Strategies** - Effective instructional approaches
3. **Lesson Plans** - Detailed session-by-session guides
4. **Assessment Tools** - Evaluation methods and rubrics
5. **Troubleshooting** - Common issues and solutions
6. **Resources** - Supplementary teaching materials

---

# PART 1: COURSE OVERVIEW

## 1.1 Course Description

**Course Title:** Master Modern Flask 3.x: From Beginner to Production-Ready Applications

**Duration:** 8 sessions (4-6 hours each) or 16 sessions (2-3 hours each)

**Target Audience:**
- Python developers transitioning to web development
- Beginners seeking structured Flask learning
- Professionals building production applications

**Prerequisites:**
- Basic Python programming (functions, classes, OOP)
- Fundamental HTML and CSS
- Basic SQL concepts
- Command line comfort

**Learning Outcomes:**
By the end of this course, students will be able to:
- Design professional Flask applications using the Application Factory pattern
- Build secure authentication systems with Flask-Login
- Create robust database models with SQLAlchemy 2.x
- Develop RESTful APIs with proper versioning
- Implement async programming and background tasks
- Write comprehensive tests with Pytest
- Deploy production applications with Docker and Gunicorn

---

## 1.2 Course Schedule

### Option A: Intensive (8 sessions × 6 hours)

| Session | Topic | Duration |
|---------|-------|----------|
| 1 | Flask Foundations & Architecture | 6 hours |
| 2 | Routing, Requests & Templating | 6 hours |
| 3 | Databases, ORM & Data Modeling | 6 hours |
| 4 | Authentication & Security | 6 hours |
| 5 | RESTful APIs | 6 hours |
| 6 | Async Programming & Background Processing | 6 hours |
| 7 | Testing & Quality Assurance | 6 hours |
| 8 | Production Deployment & DevOps | 6 hours |

### Option B: Extended (16 sessions × 3 hours)

| Week | Sessions | Topics |
|------|----------|--------|
| 1 | 1-2 | Flask Foundations & Architecture |
| 2 | 3-4 | Routing, Requests & Templating |
| 3 | 5-6 | Databases, ORM & Data Modeling |
| 4 | 7-8 | Authentication & Security |
| 5 | 9-10 | RESTful APIs |
| 6 | 11-12 | Async Programming & Background Processing |
| 7 | 13-14 | Testing & Quality Assurance |
| 8 | 15-16 | Production Deployment & DevOps |

### Option C: Self-Paced

Each part should take approximately 8-12 hours of self-study, including:
- 2-3 hours of video/content review
- 3-4 hours of hands-on coding
- 1-2 hours of exercises
- 1-2 hours of review and practice

---

## 1.3 Required Materials

### Software Requirements
```
- Python 3.13+
- VS Code (recommended) or PyCharm
- Git
- Docker Desktop
- PostgreSQL (production)
- Redis
- Postman (for API testing)
- SQLite (development)
```

### Extensions for VS Code
```
- Python (Microsoft)
- Pylance
- Ruff
- GitLens
- Docker
- SQLite Viewer
- Prettier
- Thunder Client (API testing)
```

### Student Prerequisites
```
Before the course, students should:
- Install Python 3.13+
- Install VS Code with Python extension
- Install Git
- Create a GitHub account
- Basic terminal/command line knowledge
```

---

# PART 2: TEACHING STRATEGIES

## 2.1 Instructional Approach

### The Four-Phase Learning Cycle

```
┌─────────────────────────────────────────────────────────────┐
│                 Four-Phase Learning Cycle                   │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1. CONCEPT: Explain the "what" and "why"                  │
│     - Use analogies and real-world comparisons            │
│     - Show the big picture first                          │
│     - Define key terminology                              │
│                                                             │
│  2. DEMONSTRATION: Show how it works                      │
│     - Live coding with explanation                        │
│     - Step-by-step walkthrough                            │
│     - Show both correct and incorrect approaches          │
│                                                             │
│  3. APPLICATION: Students do it themselves                │
│     - Hands-on exercises                                  │
│     - Build on previous knowledge                         │
│     - Pair programming encouraged                         │
│                                                             │
│  4. VERIFICATION: Check understanding                     │
│     - Testing and debugging                               │
│     - Review of common mistakes                           │
│     - Q&A session                                         │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Teaching Philosophy

```
┌─────────────────────────────────────────────────────────────┐
│                     Teaching Principles                     │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ✅ Code-Heavy: No placeholders, always complete code      │
│  ✅ Beginner-Friendly: Clear explanations with analogies    │
│  ✅ Expert Inside: Production-grade code quality           │
│  ✅ Logical Progression: Each step builds on the last      │
│  ✅ Hands-On: Students code alongside instructor           │
│  ✅ Real-World: Build actual applications                  │
│  ✅ Incremental: Start simple, add complexity             │
│  ✅ Iterative: Refactor and improve code                   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Engagement Strategies

```yaml
Pair Programming:
  - Driver/Navigator roles
  - Switch every 20-30 minutes
  - Encourages collaboration and learning

Think-Pair-Share:
  1. Think: Students think individually
  2. Pair: Discuss with a partner
  3. Share: Present to class

Live Debugging:
  - Deliberately create bugs
  - Walk through debugging process
  - Teach problem-solving skills

Show and Tell:
  - Students present their work
  - Share different approaches
  - Learn from peers
```

---

## 2.2 Common Misconceptions

### Misconception 1: Flask is for small projects only

**The Truth:** Flask is used by large companies like LinkedIn, Netflix, and Reddit. The framework's minimalism allows you to choose the right tools for your needs.

**Teaching Strategy:** Show examples of large Flask applications and microservice architectures.

### Misconception 2: The development server is production-ready

**The Truth:** The Flask development server is single-threaded, slow, and insecure. Always use Gunicorn or uWSGI in production.

**Teaching Strategy:** Demonstrate the development server's limitations and show Gunicorn's capabilities.

### Misconception 3: SQLAlchemy is too complex

**The Truth:** SQLAlchemy has a learning curve, but its power and flexibility are worth the investment. The ORM makes database work easier and safer.

**Teaching Strategy:** Start with simple models and gradually introduce advanced features.

### Misconception 4: Testing is a waste of time

**The Truth:** Tests prevent regressions, document code, and increase confidence. The time invested in testing is repaid many times over.

**Teaching Strategy:** Show how tests catch bugs and save time in the long run.

### Misconception 5: Security can be added later

**The Truth:** Security must be built in from the start. Adding security later is harder, more expensive, and less effective.

**Teaching Strategy:** Demonstrate security vulnerabilities and their impact.

---

## 2.3 Classroom Management

### Setting Up the Learning Environment

```yaml
Before the Course:
  - Send setup instructions (Python, VS Code, Git)
  - Create a shared repository
  - Set up a class communication channel

During the Course:
  - Start each session with a review
  - Check student progress regularly
  - Encourage questions
  - Keep the pace appropriate
  - Use the "3 before me" rule

End of Course:
  - Review learning objectives
  - Collect feedback
  - Provide next steps
  - Offer additional resources
```

### Handling Different Skill Levels

```yaml
For Fast Learners:
  - Challenge problems
  - Additional reading
  - Peer mentoring

For Slower Learners:
  - Extra practice time
  - One-on-one support
  - Simplified examples

For Mixed Groups:
  - Pair programming
  - Differentiated assignments
  - Peer learning
```

---

# PART 3: LESSON PLANS

## 3.1 Session 1: Flask Foundations & Architecture

### Session Overview
**Duration:** 6 hours (or 2 × 3-hour sessions)

**Learning Objectives:**
- Understand Flask's philosophy and architecture
- Set up a professional development environment
- Implement the Application Factory pattern
- Create configuration management
- Organize with Blueprints
- Set up code quality tools

---

### Lesson Plan

#### Part 1: Introduction (1 hour)

**Topics:**
1. What is Flask and why use it
2. Flask vs Django vs FastAPI
3. The Python ecosystem
4. Course overview

**Teaching Activities:**
```
1. Welcome and introductions (15 min)
2. Course overview and objectives (15 min)
3. What is Flask? (15 min)
4. Framework comparison discussion (15 min)
```

**Key Points:**
- Flask is a microframework, not a full-stack framework
- Flask's philosophy: minimal core, extensible
- Flask provides: Werkzeug (WSGI), Jinja2 (templating), Click (CLI)

**Discussion Questions:**
1. What web frameworks have you used before?
2. Why might you choose Flask over Django?
3. What type of project would you build with Flask?

---

#### Part 2: Development Environment (1.5 hours)

**Topics:**
1. Virtual environments
2. Installing Flask
3. Project structure
4. Configuration

**Teaching Activities:**
```
1. Live demonstration: Setting up a virtual environment (30 min)
2. Hands-on: Students create their environment (30 min)
3. Live demonstration: Project structure and configuration (30 min)
```

**Code Demo:**
```bash
# Setting up environment
mkdir taskflow
cd taskflow
python -m venv venv
source venv/bin/activate
pip install flask

# Project structure
mkdir app
mkdir app/blueprints app/models app/forms app/templates
touch app/__init__.py app/config.py app/extensions.py
```

**Hands-On Exercise:**
- Create a virtual environment
- Install Flask
- Set up the project structure
- Create configuration classes

**Common Issues:**
- Virtual environment not activating
- Wrong Python version
- Permission issues

---

#### Part 3: Application Factory (1.5 hours)

**Topics:**
1. The Application Factory pattern
2. Configuration management
3. Extension initialization
4. Blueprints

**Teaching Activities:**
```
1. Explain Application Factory pattern (30 min)
2. Live coding: create_app() (30 min)
3. Hands-on: implement Application Factory (30 min)
```

**Code Demo:**
```python
# app/__init__.py
def create_app():
    app = Flask(__name__)
    app.config.from_object(get_config())
    init_extensions(app)
    register_blueprints(app)
    return app

# app/config.py
class Config:
    SECRET_KEY = os.environ.get('SECRET_KEY')

class DevelopmentConfig(Config):
    DEBUG = True

class ProductionConfig(Config):
    DEBUG = False
```

**Hands-On Exercise:**
- Create the Application Factory
- Register Blueprints
- Test the application

---

#### Part 4: Code Quality Tools (1.5 hours)

**Topics:**
1. Ruff for linting
2. Black for formatting
3. isort for imports
4. mypy for type checking
5. pre-commit hooks

**Teaching Activities:**
```
1. Explain code quality tools (30 min)
2. Live demonstration (30 min)
3. Hands-on setup (30 min)
```

**Code Demo:**
```toml
[tool.black]
line-length = 100

[tool.ruff]
target-version = "py313"
select = ["E", "F", "I", "N"]
```

**Hands-On Exercise:**
- Install code quality tools
- Configure pyproject.toml
- Set up pre-commit hooks
- Run the tools

---

#### Part 5: Wrap-Up (30 min)

**Activities:**
1. Review key concepts
2. Address questions
3. Preview next session
4. Homework assignment

**Homework:**
- Complete the project skeleton
- Add logging configuration
- Add a health check endpoint

---

## 3.2 Session 2: Routing, Requests & Templating

### Session Overview
**Duration:** 6 hours (or 2 × 3-hour sessions)

**Learning Objectives:**
- Create dynamic routes with URL parameters
- Handle HTTP requests
- Use Jinja2 templates
- Implement forms with Flask-WTF
- Add flash messages
- Create custom error pages

---

### Lesson Plan

#### Part 1: Routing (1.5 hours)

**Topics:**
1. Basic routing
2. Dynamic routes
3. URL converters
4. HTTP methods
5. URL building with url_for

**Teaching Activities:**
```
1. Live coding: Basic routes (30 min)
2. Live coding: Dynamic routes and converters (30 min)
3. Hands-on exercise (30 min)
```

**Code Demo:**
```python
@app.route('/')
def index():
    return 'Hello!'

@app.route('/user/<username>')
def profile(username):
    return f'User: {username}'

@app.route('/post/<int:post_id>')
def post(post_id):
    return f'Post: {post_id}'
```

**Hands-On Exercise:**
- Create routes for: home, about, contact
- Create a dynamic route with URL parameters
- Use url_for() in templates

---

#### Part 2: Requests & Responses (1.5 hours)

**Topics:**
1. Request object
2. Query parameters
3. Form data
4. JSON data
5. Response handling
6. Redirects

**Teaching Activities:**
```
1. Live demo: Request handling (30 min)
2. Live demo: Response generation (30 min)
3. Hands-on exercise (30 min)
```

**Code Demo:**
```python
from flask import request, jsonify, redirect

@app.route('/search')
def search():
    query = request.args.get('q', '')
    return f'Searching for: {query}'

@app.route('/api/data')
def api_data():
    return jsonify({'data': 'Hello'})
```

**Hands-On Exercise:**
- Create a search route
- Create a JSON API endpoint
- Create a redirect route

---

#### Part 3: Jinja2 Templates (1.5 hours)

**Topics:**
1. Template inheritance
2. Template syntax
3. Filters and macros
4. Context processors

**Teaching Activities:**
```
1. Live coding: Base template (30 min)
2. Live coding: Child templates (30 min)
3. Hands-on exercise (30 min)
```

**Code Demo:**
```html
<!-- base.html -->
<!DOCTYPE html>
<html>
<head>
    <title>{% block title %}App{% endblock %}</title>
</head>
<body>
    {% block content %}{% endblock %}
</body>
</html>

<!-- index.html -->
{% extends "base.html" %}
{% block title %}Home{% endblock %}
{% block content %}
    <h1>Welcome!</h1>
{% endblock %}
```

**Hands-On Exercise:**
- Create a base template
- Create child templates
- Add context processors

---

#### Part 4: Forms & Flash Messages (1.5 hours)

**Topics:**
1. Flask-WTF forms
2. Form validation
3. Flash messages
4. Error handling

**Teaching Activities:**
```
1. Live coding: Creating forms (30 min)
2. Live coding: Form handling (30 min)
3. Hands-on exercise (30 min)
```

**Code Demo:**
```python
class LoginForm(FlaskForm):
    email = StringField('Email', validators=[DataRequired(), Email()])
    password = PasswordField('Password', validators=[DataRequired()])
    submit = SubmitField('Login')

@app.route('/login', methods=['GET', 'POST'])
def login():
    form = LoginForm()
    if form.validate_on_submit():
        flash('Login successful!', 'success')
        return redirect(url_for('index'))
    return render_template('login.html', form=form)
```

**Hands-On Exercise:**
- Create a login form
- Add validation
- Implement flash messages
- Create error pages

---

## 3.3 Session 3: Databases & ORM

### Session Overview
**Duration:** 6 hours (or 2 × 3-hour sessions)

**Learning Objectives:**
- Define SQLAlchemy models
- Create relationships
- Perform CRUD operations
- Write complex queries
- Use Alembic migrations
- Implement the Repository pattern

---

### Lesson Plan

#### Part 1: SQLAlchemy Setup (1.5 hours)

**Topics:**
1. SQLAlchemy architecture
2. Flask-SQLAlchemy setup
3. Defining models
4. Database configuration

**Teaching Activities:**
```
1. Explain SQLAlchemy (30 min)
2. Live coding: Setup and models (30 min)
3. Hands-on exercise (30 min)
```

**Code Demo:**
```python
# app/config.py
SQLALCHEMY_DATABASE_URI = 'sqlite:///app.db'

# app/models/user.py
class User(db.Model):
    __tablename__ = 'users'
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(50), unique=True)
    email = db.Column(db.String(120), unique=True)
```

**Hands-On Exercise:**
- Configure SQLAlchemy
- Create User model
- Create Task model

---

#### Part 2: Relationships (1.5 hours)

**Topics:**
1. One-to-many relationships
2. Many-to-many relationships
3. Relationship configuration
4. Backrefs and lazy loading

**Teaching Activities:**
```
1. Explain relationships (30 min)
2. Live coding: Relationships (30 min)
3. Hands-on exercise (30 min)
```

**Code Demo:**
```python
class User(db.Model):
    tasks = db.relationship('Task', back_populates='user')

class Task(db.Model):
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'))
    user = db.relationship('User', back_populates='tasks')
```

**Hands-On Exercise:**
- Add relationships between User and Task
- Create a many-to-many relationship for tags
- Query using relationships

---

#### Part 3: CRUD Operations (1.5 hours)

**Topics:**
1. Create operations
2. Read operations
3. Update operations
4. Delete operations
5. Advanced queries

**Teaching Activities:**
```
1. Live coding: CRUD operations (30 min)
2. Live coding: Queries (30 min)
3. Hands-on exercise (30 min)
```

**Code Demo:**
```python
# CREATE
user = User(username='john', email='john@example.com')
db.session.add(user)
db.session.commit()

# READ
users = User.query.all()
user = User.query.filter_by(username='john').first()

# UPDATE
user = User.query.get(1)
user.username = 'new_username'
db.session.commit()

# DELETE
user = User.query.get(1)
db.session.delete(user)
db.session.commit()
```

**Hands-On Exercise:**
- Implement CRUD for tasks
- Write complex queries
- Use filters and sorting

---

#### Part 4: Migrations & Repository Pattern (1.5 hours)

**Topics:**
1. Alembic migrations
2. Migration commands
3. Repository pattern
4. Service layer

**Teaching Activities:**
```
1. Explain migrations (30 min)
2. Live coding: Repository pattern (30 min)
3. Hands-on exercise (30 min)
```

**Code Demo:**
```bash
flask db init
flask db migrate -m "Initial migration"
flask db upgrade
```

```python
class TaskRepository:
    @staticmethod
    def get_by_id(task_id):
        return Task.query.get(task_id)
    
    @staticmethod
    def get_user_tasks(user_id):
        return Task.query.filter_by(user_id=user_id).all()
```

**Hands-On Exercise:**
- Set up migrations
- Implement Repository pattern
- Create Service layer

---

## 3.4 Session 4: Authentication & Security

### Session Overview
**Duration:** 6 hours (or 2 × 3-hour sessions)

**Learning Objectives:**
- Implement user registration
- Implement login and logout
- Hash passwords securely
- Manage sessions with Flask-Login
- Implement role-based access control
- Add CSRF protection
- Configure security headers

---

### Lesson Plan

#### Part 1: User Authentication (1.5 hours)

**Topics:**
1. Flask-Login setup
2. User model with authentication
3. Registration
4. Login and logout

**Teaching Activities:**
```
1. Explain Flask-Login (30 min)
2. Live coding: Authentication (30 min)
3. Hands-on exercise (30 min)
```

**Code Demo:**
```python
from flask_login import LoginManager, UserMixin
from werkzeug.security import generate_password_hash, check_password_hash

class User(db.Model, UserMixin):
    password_hash = db.Column(db.String(128))
    
    def set_password(self, password):
        self.password_hash = generate_password_hash(password)
    
    def check_password(self, password):
        return check_password_hash(self.password_hash, password)

@login_manager.user_loader
def load_user(user_id):
    return User.query.get(int(user_id))
```

**Hands-On Exercise:**
- Set up Flask-Login
- Create registration form
- Create login form
- Implement logout

---

#### Part 2: Password Security (1.5 hours)

**Topics:**
1. Password hashing
2. Password policies
3. Password reset
4. Email verification

**Teaching Activities:**
```
1. Explain password security (30 min)
2. Live coding: Password reset (30 min)
3. Hands-on exercise (30 min)
```

**Code Demo:**
```python
def validate_password(password):
    if len(password) < 8:
        return False
    if not any(c.isupper() for c in password):
        return False
    if not any(c.islower() for c in password):
        return False
    if not any(c.isdigit() for c in password):
        return False
    return True
```

**Hands-On Exercise:**
- Implement password validation
- Add password reset
- Implement email verification

---

#### Part 3: Authorization (1.5 hours)

**Topics:**
1. Role-based access control (RBAC)
2. Permission checking
3. Route protection
4. Decorators

**Teaching Activities:**
```
1. Explain RBAC (30 min)
2. Live coding: Authorization (30 min)
3. Hands-on exercise (30 min)
```

**Code Demo:**
```python
def role_required(role):
    def decorator(f):
        @wraps(f)
        def decorated(*args, **kwargs):
            if not current_user.is_authenticated:
                abort(401)
            if current_user.role != role and not current_user.is_admin:
                abort(403)
            return f(*args, **kwargs)
        return decorated
    return decorator

@app.route('/admin')
@role_required('admin')
def admin_panel():
    return render_template('admin.html')
```

**Hands-On Exercise:**
- Add role field to User model
- Create role-based decorators
- Protect admin routes

---

#### Part 4: Security Best Practices (1.5 hours)

**Topics:**
1. CSRF protection
2. Security headers
3. Session security
4. HTTPS configuration

**Teaching Activities:**
```
1. Explain security concepts (30 min)
2. Live coding: Security headers (30 min)
3. Hands-on exercise (30 min)
```

**Code Demo:**
```python
from flask_wtf.csrf import CSRFProtect

csrf = CSRFProtect(app)

@app.after_request
def security_headers(response):
    response.headers['X-Frame-Options'] = 'SAMEORIGIN'
    response.headers['X-Content-Type-Options'] = 'nosniff'
    response.headers['X-XSS-Protection'] = '1; mode=block'
    response.headers['Strict-Transport-Security'] = 'max-age=31536000'
    return response
```

**Hands-On Exercise:**
- Enable CSRF protection
- Add security headers
- Configure secure session cookies

---

## 3.5 Session 5: RESTful APIs

### Session Overview
**Duration:** 6 hours (or 2 × 3-hour sessions)

**Learning Objectives:**
- Design RESTful API endpoints
- Use Marshmallow for serialization
- Implement token-based authentication
- Add rate limiting
- Create API documentation

---

### Lesson Plan

#### Part 1: API Design (1.5 hours)

**Topics:**
1. REST principles
2. Resource naming
3. HTTP methods and status codes
4. API structure

**Teaching Activities:**
```
1. Explain REST (30 min)
2. Live coding: API structure (30 min)
3. Hands-on exercise (30 min)
```

**Code Demo:**
```python
api_bp = Blueprint('api', __name__, url_prefix='/api')

@api_bp.route('/tasks', methods=['GET'])
def list_tasks():
    tasks = Task.query.all()
    return jsonify([t.to_dict() for t in tasks])

@api_bp.route('/tasks', methods=['POST'])
def create_task():
    data = request.get_json()
    task = Task(**data)
    db.session.add(task)
    db.session.commit()
    return jsonify(task.to_dict()), 201
```

**Hands-On Exercise:**
- Create API blueprint
- Implement task endpoints
- Use proper status codes

---

#### Part 2: Marshmallow Serialization (1.5 hours)

**Topics:**
1. Marshmallow schemas
2. Serialization and deserialization
3. Validation
4. Nested schemas

**Teaching Activities:**
```
1. Explain Marshmallow (30 min)
2. Live coding: Schemas (30 min)
3. Hands-on exercise (30 min)
```

**Code Demo:**
```python
from marshmallow import Schema, fields, validate

class TaskSchema(Schema):
    id = fields.Int(dump_only=True)
    title = fields.Str(required=True, validate=validate.Length(min=1, max=200))
    status = fields.Str(validate=validate.OneOf(['pending', 'in_progress', 'completed']))
    created_at = fields.DateTime(dump_only=True)

schema = TaskSchema()
task = Task.query.get(1)
result = schema.dump(task)
```

**Hands-On Exercise:**
- Create schemas for User and Task
- Implement serialization
- Add validation

---

#### Part 3: Authentication (1.5 hours)

**Topics:**
1. JWT tokens
2. Token generation and validation
3. Protected endpoints
4. Token refresh

**Teaching Activities:**
```
1. Explain JWT (30 min)
2. Live coding: Token authentication (30 min)
3. Hands-on exercise (30 min)
```

**Code Demo:**
```python
import jwt

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
        token = request.headers.get('Authorization', '').replace('Bearer ', '')
        try:
            payload = jwt.decode(token, SECRET_KEY, algorithms=['HS256'])
            g.user_id = payload['user_id']
        except:
            return jsonify({'error': 'Invalid token'}), 401
        return f(*args, **kwargs)
    return decorated
```

**Hands-On Exercise:**
- Implement JWT authentication
- Create login endpoint
- Protect API endpoints

---

#### Part 4: Rate Limiting & Documentation (1.5 hours)

**Topics:**
1. Rate limiting
2. API documentation with Swagger
3. Error handling
4. Versioning

**Teaching Activities:**
```
1. Explain rate limiting (30 min)
2. Live coding: Swagger (30 min)
3. Hands-on exercise (30 min)
```

**Code Demo:**
```python
from flask_limiter import Limiter
from flask_limiter.util import get_remote_address

limiter = Limiter(app, key_func=get_remote_address)

@api_bp.route('/tasks')
@limiter.limit("100 per minute")
def list_tasks():
    # ...

# Swagger UI
from flask_swagger_ui import get_swaggerui_blueprint
SWAGGER_URL = '/api/docs'
swagger_ui = get_swaggerui_blueprint(SWAGGER_URL, '/api/docs/spec.json')
```

**Hands-On Exercise:**
- Add rate limiting
- Create API documentation
- Implement error handling

---

## 3.6 Session 6: Async & Background Processing

### Session Overview
**Duration:** 6 hours (or 2 × 3-hour sessions)

**Learning Objectives:**
- Write async view functions
- Set up Celery
- Create background tasks
- Schedule periodic tasks
- Monitor task execution

---

### Lesson Plan

#### Part 1: Async Views (1.5 hours)

**Topics:**
1. Async concepts
2. Flask async views
3. HTTPX for async HTTP
4. Concurrent operations

**Teaching Activities:**
```
1. Explain async (30 min)
2. Live coding: Async views (30 min)
3. Hands-on exercise (30 min)
```

**Code Demo:**
```python
import asyncio
import httpx

@app.route('/api/async-example')
async def async_example():
    await asyncio.sleep(1)
    return jsonify({'message': 'Async response'})

@app.route('/api/external-data')
async def external_data():
    async with httpx.AsyncClient() as client:
        results = await asyncio.gather(
            client.get('https://api1.example.com'),
            client.get('https://api2.example.com')
        )
    return jsonify([r.json() for r in results])
```

**Hands-On Exercise:**
- Create an async view
- Make concurrent API calls
- Handle errors in async code

---

#### Part 2: Celery Setup (1.5 hours)

**Topics:**
1. Celery architecture
2. Redis setup
3. Celery configuration
4. Starting workers

**Teaching Activities:**
```
1. Explain Celery (30 min)
2. Live coding: Setup (30 min)
3. Hands-on exercise (30 min)
```

**Code Demo:**
```python
# celery_worker.py
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
    enable_utc=True
)

celery.autodiscover_tasks(['app.tasks'])
```

```bash
# Start worker
celery -A app.celery_worker.celery worker --loglevel=info
```

**Hands-On Exercise:**
- Set up Celery
- Configure Redis
- Start a worker

---

#### Part 3: Creating Tasks (1.5 hours)

**Topics:**
1. Defining tasks
2. Task parameters
3. Task results
4. Retry logic

**Teaching Activities:**
```
1. Explain tasks (30 min)
2. Live coding: Tasks (30 min)
3. Hands-on exercise (30 min)
```

**Code Demo:**
```python
@celery.task
def send_email(recipient, subject, body):
    # Send email
    return {'status': 'sent'}

@celery.task(bind=True, max_retries=3)
def process_document(self, document_id):
    try:
        # Process document
        return {'status': 'processed'}
    except Exception as e:
        self.retry(exc=e, countdown=60)
```

**Hands-On Exercise:**
- Create email task
- Create report task
- Add retry logic

---

#### Part 4: Scheduling & Monitoring (1.5 hours)

**Topics:**
1. Celery Beat
2. Scheduled tasks
3. Task monitoring
4. Flower

**Teaching Activities:**
```
1. Explain scheduling (30 min)
2. Live coding: Scheduled tasks (30 min)
3. Hands-on exercise (30 min)
```

**Code Demo:**
```python
from celery.schedules import crontab

celery.conf.beat_schedule = {
    'daily-report': {
        'task': 'app.tasks.generate_report',
        'schedule': crontab(hour=8, minute=0)
    }
}

# Flower monitoring
celery -A app.celery_worker.celery flower --port=5555
```

**Hands-On Exercise:**
- Schedule a daily report
- Monitor tasks with Flower
- View task history

---

## 3.7 Session 7: Testing & Quality Assurance

### Session Overview
**Duration:** 6 hours (or 2 × 3-hour sessions)

**Learning Objectives:**
- Write unit tests with Pytest
- Create integration tests
- Write functional tests
- Measure test coverage
- Use debugging tools

---

### Lesson Plan

#### Part 1: Testing Fundamentals (1.5 hours)

**Topics:**
1. Testing pyramid
2. Pytest setup
3. Writing unit tests
4. Fixtures

**Teaching Activities:**
```
1. Explain testing (30 min)
2. Live coding: Unit tests (30 min)
3. Hands-on exercise (30 min)
```

**Code Demo:**
```python
# tests/test_models.py
def test_create_user(db_session):
    user = User(username='test', email='test@example.com')
    user.set_password('password123')
    db_session.add(user)
    db_session.commit()
    assert user.id is not None

# fixtures
@pytest.fixture
def test_user(db_session):
    user = User(username='testuser')
    db_session.add(user)
    db_session.commit()
    return user
```

**Hands-On Exercise:**
- Write tests for User model
- Write tests for Task model
- Use fixtures

---

#### Part 2: Integration Tests (1.5 hours)

**Topics:**
1. Integration testing
2. Test client
3. Authentication in tests
4. Database testing

**Teaching Activities:**
```
1. Explain integration tests (30 min)
2. Live coding: Route tests (30 min)
3. Hands-on exercise (30 min)
```

**Code Demo:**
```python
def test_login(client, test_user):
    response = client.post('/auth/login', data={
        'email': 'test@example.com',
        'password': 'password123'
    })
    assert response.status_code == 302

def test_protected_route(client):
    response = client.get('/dashboard')
    assert response.status_code == 302  # Redirect to login
```

**Hands-On Exercise:**
- Write tests for auth routes
- Write tests for task routes
- Test authentication

---

#### Part 3: Functional Tests (1.5 hours)

**Topics:**
1. Functional testing
2. Complete workflows
3. API testing
4. Test data factories

**Teaching Activities:**
```
1. Explain functional tests (30 min)
2. Live coding: Workflow tests (30 min)
3. Hands-on exercise (30 min)
```

**Code Demo:**
```python
def test_user_workflow(client):
    # Register
    client.post('/auth/register', data={
        'username': 'newuser',
        'email': 'new@example.com',
        'password': 'Password123!'
    })
    
    # Login
    response = client.post('/auth/login', data={
        'email': 'new@example.com',
        'password': 'Password123!'
    })
    assert response.status_code == 302
    
    # Create task
    response = client.post('/tasks/create', data={
        'title': 'Test Task'
    })
    assert response.status_code == 302
```

**Hands-On Exercise:**
- Write registration/login workflow
- Write task CRUD workflow
- Write API tests

---

#### Part 4: Coverage & Quality (1.5 hours)

**Topics:**
1. Test coverage
2. Coverage reporting
3. Debugging techniques
4. Code quality tools

**Teaching Activities:**
```
1. Explain coverage (30 min)
2. Live coding: Coverage setup (30 min)
3. Hands-on exercise (30 min)
```

**Code Demo:**
```bash
# Run with coverage
pytest --cov=app --cov-report=html --cov-report=term

# Debugging
import pdb
pdb.set_trace()
```

**Hands-On Exercise:**
- Generate coverage report
- Improve test coverage
- Practice debugging

---

## 3.8 Session 8: Production Deployment & DevOps

### Session Overview
**Duration:** 6 hours (or 2 × 3-hour sessions)

**Learning Objectives:**
- Configure Gunicorn
- Set up Nginx
- Containerize with Docker
- Implement CI/CD
- Set up monitoring

---

### Lesson Plan

#### Part 1: Gunicorn & Nginx (1.5 hours)

**Topics:**
1. Production architecture
2. Gunicorn configuration
3. Nginx setup
4. Process management

**Teaching Activities:**
```
1. Explain production stack (30 min)
2. Live coding: Gunicorn (30 min)
3. Hands-on exercise (30 min)
```

**Code Demo:**
```python
# gunicorn.conf.py
workers = multiprocessing.cpu_count() * 2 + 1
bind = '0.0.0.0:8000'
timeout = 120
```

```nginx
# nginx.conf
upstream app {
    server unix:/tmp/app.sock;
}

server {
    listen 80;
    location / {
        proxy_pass http://app;
    }
}
```

**Hands-On Exercise:**
- Configure Gunicorn
- Set up Nginx
- Test the setup

---

#### Part 2: Docker (1.5 hours)

**Topics:**
1. Docker fundamentals
2. Dockerfile
3. Docker Compose
4. Container management

**Teaching Activities:**
```
1. Explain Docker (30 min)
2. Live coding: Dockerfile (30 min)
3. Hands-on exercise (30 min)
```

**Code Demo:**
```dockerfile
FROM python:3.13-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
CMD ["gunicorn", "-c", "gunicorn.conf.py", "run:app"]
```

```yaml
version: '3.8'
services:
  web:
    build: .
    ports:
      - "8000:8000"
  db:
    image: postgres:15
```

**Hands-On Exercise:**
- Create Dockerfile
- Set up Docker Compose
- Build and run containers

---

#### Part 3: CI/CD (1.5 hours)

**Topics:**
1. CI/CD concepts
2. GitHub Actions
3. Testing in CI
4. Deployment automation

**Teaching Activities:**
```
1. Explain CI/CD (30 min)
2. Live coding: GitHub Actions (30 min)
3. Hands-on exercise (30 min)
```

**Code Demo:**
```yaml
name: CI/CD
on:
  push:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run tests
        run: pytest

  deploy:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - name: Deploy
        run: ssh deploy@server "docker-compose up -d"
```

**Hands-On Exercise:**
- Set up GitHub Actions
- Add test step
- Add deployment step

---

#### Part 4: Monitoring & Logging (1.5 hours)

**Topics:**
1. Health checks
2. Application logging
3. Metrics
4. Alerting

**Teaching Activities:**
```
1. Explain monitoring (30 min)
2. Live coding: Health checks (30 min)
3. Hands-on exercise (30 min)
```

**Code Demo:**
```python
@app.route('/health')
def health():
    return jsonify({
        'status': 'healthy',
        'database': check_db(),
        'redis': check_redis()
    })

# Logging
import logging
from logging.handlers import RotatingFileHandler

handler = RotatingFileHandler('logs/app.log', maxBytes=10*1024*1024, backupCount=5)
handler.setLevel(logging.INFO)
app.logger.addHandler(handler)
```

**Hands-On Exercise:**
- Add health check
- Set up logging
- Monitor metrics

---

# PART 4: ASSESSMENT

## 4.1 Formative Assessment

### Quick Checks (Ongoing)

```yaml
Exit Tickets:
  - 3 things you learned today
  - 2 things you want to learn more about
  - 1 question you still have

Concept Checks:
  - Brief quiz at start of each session
  - Review previous session's key concepts
  - Address misconceptions immediately

Code Reviews:
  - Review student code
  - Provide feedback
  - Highlight best practices

Pair Programming:
  - Observe pairs
  - Offer guidance
  - Assess collaboration skills
```

### Weekly Quizzes

**Week 1: Flask Foundations**
- 10 multiple choice questions
- 5 short answer questions
- 1 coding problem

**Week 2: Routing & Templating**
- 10 multiple choice questions
- 5 short answer questions
- 1 coding problem

**Week 3: Databases & ORM**
- 10 multiple choice questions
- 5 short answer questions
- 1 coding problem

---

## 4.2 Summative Assessment

### Project Evaluation Rubric

| Criteria | Excellent (90-100%) | Good (70-89%) | Needs Improvement (<70%) |
|----------|---------------------|---------------|-------------------------|
| **Architecture** | Clear, modular, follows patterns | Mostly organized | Disorganized |
| **Functionality** | All features work | Most features work | Major issues |
| **Code Quality** | Clean, documented, type-hinted | Mostly clean | Inconsistent |
| **Testing** | >80% coverage | >50% coverage | <50% coverage |
| **Documentation** | Complete, clear | Partial | Minimal |
| **Deployment** | Working, monitored | Partially working | Not working |

### Final Project Rubric

| Component | Points | Description |
|-----------|--------|-------------|
| Application Factory | 10 | Proper implementation |
| Models & Database | 15 | Complete models with relationships |
| Authentication | 15 | Registration, login, protection |
| Features | 20 | Task CRUD, categories, tags |
| API | 15 | RESTful endpoints, authentication |
| Testing | 10 | Unit, integration, functional |
| Deployment | 10 | Docker, Gunicorn, Nginx |
| Code Quality | 5 | Formatting, linting, types |
| **Total** | **100** | |

---

## 4.3 Grading Scale

| Grade | Percentage | Description |
|-------|------------|-------------|
| A | 90-100% | Excellent: Exceeds expectations |
| B | 80-89% | Good: Meets expectations |
| C | 70-79% | Satisfactory: Meets minimum |
| D | 60-69% | Needs Improvement |
| F | <60% | Unsatisfactory |

---

# PART 5: TROUBLESHOOTING

## 5.1 Common Issues & Solutions

### Environment Setup Issues

| Issue | Solution |
|-------|----------|
| Virtual environment not activating | Check path, use full path to activate |
| Python version mismatch | Install Python 3.13+, use `python3.13` |
| pip not found | Upgrade Python, use `python -m pip` |
| Permission denied | Use `--user` flag or virtual environment |

### Code Issues

| Issue | Solution |
|-------|----------|
| Circular imports | Move imports inside functions, use `import` at bottom |
| Template not found | Check template paths, folder structure |
| 404 errors | Check route decorators, URL format |
| 500 errors | Check logs, enable debug mode |

### Database Issues

| Issue | Solution |
|-------|----------|
| Migration conflicts | Reset migrations, `flask db stamp head` |
| Connection errors | Check database URL, service running |
| Query errors | Check syntax, use parameterized queries |

### Deployment Issues

| Issue | Solution |
|-------|----------|
| Gunicorn not starting | Check gunicorn.conf.py, logs |
| Nginx 502 error | Check upstream, socket permissions |
| Docker build fails | Check Dockerfile, dependencies |
| CORS issues | Configure CORS headers |

---

## 5.2 Frequently Asked Questions

### Q1: Can I use Flask with React?
Yes! Flask can serve as a backend API while React handles the frontend. This is a common architecture for modern web applications.

### Q2: How do I handle file uploads?
Use `request.files`, validate file type and size, and use `secure_filename()` from Werkzeug.

### Q3: What's the best way to handle errors?
Use try/except blocks, return appropriate HTTP status codes, and use Flask's error handlers.

### Q4: How do I debug a Flask application?
Use debug mode (`debug=True`), logging, pdb, and the Werkzeug debugger.

### Q5: How do I optimize database queries?
Use eager loading (`joinedload`), add indexes, and limit data returned.

---

# PART 6: RESOURCES

## 6.1 Student Resources

### Official Documentation
- Flask: https://flask.palletsprojects.com
- SQLAlchemy: https://www.sqlalchemy.org
- Jinja: https://jinja.palletsprojects.com
- Pytest: https://docs.pytest.org

### Learning Resources
- Flask Mega-Tutorial by Miguel Grinberg
- Real Python Flask Tutorials
- Test-Driven Development with Flask

### Tools
- VS Code: https://code.visualstudio.com
- Postman: https://www.postman.com
- Docker: https://www.docker.com
- GitHub: https://github.com

---

## 6.2 Instructor Resources

### Supplementary Materials
- Slide decks
- Code examples
- Exercise solutions
- Project starter files

### Teaching Tools
- Kahoot for quizzes
- Slack/Discord for communication
- GitHub Classroom for assignments
- Zoom/Microsoft Teams for remote teaching

### Recommended Reading
- "Flask Web Development" by Miguel Grinberg
- "The Flask Mega-Tutorial" (Online)
- "SQLAlchemy: The Definitive Guide"
- "RESTful API Design" (API Academy)

---

## 6.3 Templates

### Session Template

```yaml
Session [#]: [Title]
Date: [Date]
Duration: [Time]

Learning Objectives:
  - Objective 1
  - Objective 2

Agenda:
  - Topic 1 (time)
  - Topic 2 (time)
  - Topic 3 (time)

Key Concepts:
  - Concept 1
  - Concept 2

Activities:
  1. Activity 1
  2. Activity 2

Homework:
  - Task 1
  - Task 2
```

### Assessment Template

```yaml
Quiz [#]: [Title]
Date: [Date]

Questions:
  1. Question
     Answer: Answer

  2. Question
     Answer: Answer

Student Performance:
  - Average: XX%
  - High: XX%
  - Low: XX%

Concepts Needing Review:
  - Concept 1
  - Concept 2
```

---

# PART 7: COURSE EVALUATION

## 7.1 Student Feedback Form

**Course:** Master Modern Flask 3.x

**Date:** _______________

**Instructor:** _______________

### Rate the Following (1-5):

| Question | 1 (Poor) | 2 | 3 | 4 | 5 (Excellent) |
|----------|----------|---|---|---|----------------|
| Course organization | □ | □ | □ | □ | □ |
| Instructor knowledge | □ | □ | □ | □ | □ |
| Quality of materials | □ | □ | □ | □ | □ |
| Hands-on exercises | □ | □ | □ | □ | □ |
| Pace of instruction | □ | □ | □ | □ | □ |
| Relevance to job | □ | □ | □ | □ | □ |
| Overall satisfaction | □ | □ | □ | □ | □ |

### Open-Ended Questions:

1. What was the most valuable part of this course?
```
```

2. What could be improved?
```
```

3. Would you recommend this course to others? Why?
```
```

4. Additional comments or suggestions:
```
```

---

## 7.2 Instructor Self-Evaluation

### Reflection Questions

1. Did I meet the learning objectives?
```
```

2. What teaching strategies were most effective?
```
```

3. What could I improve?
```
```

4. Were students engaged and participating?
```
```

5. What adjustments should I make for next time?
```
```

---

# PART 8: CERTIFICATION

## 8.1 Certificate of Completion

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│              CERTIFICATE OF COMPLETION                      │
│                                                             │
│                  Master Modern Flask 3.x                   │
│      From Beginner to Production-Ready Applications        │
│                                                             │
│                                                             │
│  This certifies that                                        │
│                                                             │
│  ____________________                                       │
│        [Student Name]                                       │
│                                                             │
│  has successfully completed the Master Modern Flask 3.x    │
│  course, demonstrating proficiency in:                     │
│                                                             │
│  ✅ Flask Architecture & Design                             │
│  ✅ Routing, Requests & Templating                          │
│  ✅ Database Modeling & ORM                                 │
│  ✅ Authentication & Security                               │
│  ✅ RESTful API Development                                 │
│  ✅ Async Programming & Background Processing              │
│  ✅ Testing & Quality Assurance                             │
│  ✅ Production Deployment & DevOps                         │
│                                                             │
│  Date: _________________                                    │
│                                                             │
│  Signature: _________________                              │
│  [Instructor Name]                                          │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 8.2 Skills Checklist

### Graduated Skills

**Flask Core:**
- [ ] Create Flask applications with Application Factory
- [ ] Configure environment-specific settings
- [ ] Organize code with Blueprints
- [ ] Implement routing with URL parameters
- [ ] Handle HTTP requests and responses

**Templating:**
- [ ] Use Jinja2 template inheritance
- [ ] Create custom filters and macros
- [ ] Implement forms with Flask-WTF
- [ ] Add flash messages

**Database:**
- [ ] Define SQLAlchemy models
- [ ] Create relationships
- [ ] Perform CRUD operations
- [ ] Write complex queries
- [ ] Use Alembic migrations

**Authentication:**
- [ ] Implement user registration
- [ ] Implement login/logout
- [ ] Secure passwords
- [ ] Implement RBAC
- [ ] Add CSRF protection

**API Development:**
- [ ] Design RESTful endpoints
- [ ] Use Marshmallow schemas
- [ ] Implement token authentication
- [ ] Add rate limiting
- [ ] Create API documentation

**Async & Background:**
- [ ] Write async views
- [ ] Set up Celery
- [ ] Create background tasks
- [ ] Schedule periodic tasks
- [ ] Monitor task execution

**Testing:**
- [ ] Write unit tests with Pytest
- [ ] Create integration tests
- [ ] Write functional tests
- [ ] Measure test coverage

**Deployment:**
- [ ] Configure Gunicorn
- [ ] Set up Nginx
- [ ] Containerize with Docker
- [ ] Implement CI/CD
- [ ] Set up monitoring

---

**End of Trainer Guide**
