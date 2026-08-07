# Primer 1: Flask Fundamentals Primer

Welcome to Primer 1! This is a foundational primer designed for absolute beginners who want to understand the core concepts of Flask before diving into the main tutorial series. If you're new to web development or Flask, start here to build a solid understanding of the fundamentals.

---

## Table of Contents

1. [What is Flask?](#1-what-is-flask)
2. [Understanding Web Applications](#2-understanding-web-applications)
3. [Flask Core Concepts](#3-flask-core-concepts)
4. [Setting Up Your First Flask App](#4-setting-up-your-first-flask-app)
5. [Understanding Routes & Views](#5-understanding-routes--views)
6. [Working with Templates](#6-working-with-templates)
7. [Handling Requests & Responses](#7-handling-requests--responses)
8. [Forms & User Input](#8-forms--user-input)
9. [Database Basics](#9-database-basics)
10. [Next Steps](#10-next-steps)

---

## 1. What is Flask?

### Flask in Simple Terms

**Flask** is a web framework for Python. Think of it as a toolkit that helps you build websites and web applications using Python. It's like having a set of pre-built Lego pieces that you can assemble to create your own custom creation.

### Why Flask?

```python
# Flask is like a restaurant kitchen:

# Without Flask (cooking from scratch):
# You need to build everything yourself:
# - The stove (web server)
# - The pots and pans (request handling)
# - The recipes (routing)
# - Everything from scratch!

# With Flask (using a kitchen):
# Flask provides:
# - A stove (built-in development server)
# - Pots and pans (request/response handling)
# - Basic recipes (routing system)
# - You focus on cooking your food (your application logic)

# A simple Flask app:
from flask import Flask
app = Flask(__name__)

@app.route('/')
def hello():
    return 'Hello, World!'
```

### Flask vs Other Frameworks

| Framework | Analogy | Best For |
|-----------|---------|----------|
| **Flask** | A food truck - has the essentials, flexible | Small to medium projects, beginners |
| **Django** | A full restaurant chain - has everything built-in | Large projects, content-heavy sites |
| **FastAPI** | A modern food delivery service - fast, efficient | APIs, real-time applications |
| **Pyramid** | A catering company - very flexible | Complex applications |

### When to Use Flask

Choose Flask when:
- You're learning web development
- You want to build a simple API
- You need flexibility and control
- You're building a prototype
- You want a lightweight application

---

## 2. Understanding Web Applications

### How the Web Works

Think of the web like a restaurant:

```
Client (Browser) = Customer
Internet = The road
Web Server = The restaurant building
Flask Application = The kitchen
Database = The storage room
```

### The Request-Response Cycle

```
1. Customer (Browser) walks to restaurant (makes a request)
   ↓
2. Waiter (Internet) takes the order
   ↓
3. Kitchen (Flask) prepares the food
   ↓
4. Waiter (Internet) delivers the food
   ↓
5. Customer (Browser) receives the food (response)
```

### HTTP Basics

**HTTP** (Hypertext Transfer Protocol) is the language that browsers and servers use to talk to each other.

```python
# Common HTTP Methods (Actions)

# GET = "Can I see the menu?"
# POST = "I'd like to order this"
# PUT = "I want to change my order"
# DELETE = "I want to cancel my order"

# Example URL:
# https://taskflow.com/tasks/123
# 
# Parts of a URL:
# https://    = Protocol (the method of communication)
# taskflow.com = Domain (the restaurant name)
# /tasks/123  = Path (what you're asking for)
```

### Web Applications vs Websites

```
Website (Static):
- Always shows the same content
- Like a brochure
- Example: A company info page

Web Application (Dynamic):
- Content changes based on user interaction
- Like a calculator or a game
- Example: TaskFlow (tasks change based on user input)

Flask can build BOTH static websites and dynamic web applications!
```

---

## 3. Flask Core Concepts

### The WSGI Server

**WSGI** (Web Server Gateway Interface) is a standard that allows Flask to talk to web servers.

```
┌─────────────────────────────────────────────────────────────┐
│                      Browser                                │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────┐
│              Web Server (Gunicorn/uWSGI)                    │
│  - Speaks HTTP to browsers                                 │
│  - Talks WSGI to Flask                                     │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────┐
│               Flask Application                             │
│  - Handles requests                                         │
│  - Returns responses                                        │
└─────────────────────────────────────────────────────────────┘
```

### The Application Object

The `Flask` object is the heart of your application:

```python
from flask import Flask

# Create the application
app = Flask(__name__)

# App is the "boss" that coordinates everything:
# - Routes (where to send requests)
# - Templates (how to show pages)
# - Extensions (extra features)
```

### The Request Object

Flask creates a `request` object for each request:

```python
from flask import request

@app.route('/hello')
def hello():
    # Get information from the request
    name = request.args.get('name', 'World')
    return f'Hello, {name}!'

# Request object contains:
# - URL parameters (args)
# - Form data (form)
# - JSON data (json)
# - Headers (headers)
# - And more...
```

### The Response Object

Flask automatically creates a `response` from what you return:

```python
@app.route('/greeting')
def greeting():
    # Flask automatically turns this into a response
    return 'Hello!'  # String -> Response with status 200

# You can also explicitly create responses:
from flask import make_response

@app.route('/custom')
def custom_response():
    response = make_response('Hello!', 200)
    response.headers['Custom-Header'] = 'Value'
    return response
```

---

## 4. Setting Up Your First Flask App

### Step 1: Install Python

Make sure Python is installed:

```bash
# Check Python version
python --version
# Should be Python 3.8 or higher
```

### Step 2: Create a Project Folder

```bash
# Create a folder for your project
mkdir my_first_flask_app
cd my_first_flask_app
```

### Step 3: Create a Virtual Environment

A virtual environment is like a separate workspace for your project:

```bash
# Create virtual environment
python -m venv venv

# Activate it (Windows)
venv\Scripts\activate

# Activate it (Mac/Linux)
source venv/bin/activate

# You'll see (venv) in your terminal
```

### Step 4: Install Flask

```bash
# Install Flask
pip install flask
```

### Step 5: Create Your First App

Create a file called `app.py`:

```python
# app.py
from flask import Flask

# Create the Flask application
app = Flask(__name__)

# Define a route (URL path)
@app.route('/')
def home():
    return 'Welcome to my first Flask app!'

# Run the app
if __name__ == '__main__':
    app.run(debug=True)
```

### Step 6: Run Your App

```bash
python app.py
```

You should see:
```
 * Running on http://127.0.0.1:5000
 * Debug mode: on
```

Open your browser and go to `http://127.0.0.1:5000`. You should see "Welcome to my first Flask app!"

### Understanding the Code

```python
# 1. Import Flask
from flask import Flask
# This imports the Flask class that we'll use

# 2. Create the Flask app
app = Flask(__name__)
# __name__ tells Flask where to look for files

# 3. Define a route
@app.route('/')
# This is a decorator - it tells Flask what URL triggers this function

def home():
    # This is a view function
    return 'Welcome to my first Flask app!'
    # This is returned to the browser

# 4. Run the app
if __name__ == '__main__':
    app.run(debug=True)
    # debug=True means auto-reload on changes
```

---

## 5. Understanding Routes & Views

### What are Routes?

Routes are the different pages or endpoints of your application:

```
URLs:
https://taskflow.com/          → Home page
https://taskflow.com/about     → About page
https://taskflow.com/tasks     → Tasks page
https://taskflow.com/login     → Login page

Each of these is a route!
```

### Defining Routes

```python
@app.route('/')           # Root URL
def home():
    return 'Home Page'

@app.route('/about')      # /about URL
def about():
    return 'About Page'

@app.route('/contact')    # /contact URL
def contact():
    return 'Contact Page'
```

### Dynamic Routes

Routes can have variables:

```python
# Variable in URL (must be an integer)
@app.route('/user/<int:user_id>')
def user_profile(user_id):
    return f'User ID: {user_id}'

# Variable in URL (string)
@app.route('/post/<slug>')
def show_post(slug):
    return f'Post: {slug}'

# Multiple variables
@app.route('/category/<category>/item/<int:item_id>')
def show_item(category, item_id):
    return f'Category: {category}, Item: {item_id}'

# Examples:
# /user/123 → "User ID: 123"
# /post/hello-world → "Post: hello-world"
# /category/books/item/42 → "Category: books, Item: 42"
```

### HTTP Methods

Routes can handle different HTTP methods:

```python
from flask import request

# GET: Show a page
@app.route('/tasks')
def list_tasks():
    return 'Show all tasks'

# POST: Create something
@app.route('/tasks', methods=['POST'])
def create_task():
    return 'Task created!'

# Both GET and POST
@app.route('/task/new', methods=['GET', 'POST'])
def new_task():
    if request.method == 'POST':
        return 'Creating task...'
    else:
        return 'Show task form...'
```

### The URL Building

Generate URLs dynamically:

```python
from flask import url_for

# In your code:
url_for('home')          # → '/'
url_for('user_profile', user_id=123)  # → '/user/123'
url_for('show_post', slug='hello')    # → '/post/hello'

# In templates:
# <a href="{{ url_for('home') }}">Home</a>
```

---

## 6. Working with Templates

### What are Templates?

Templates are HTML files that can contain dynamic content:

```
Without Templates:
return '<html><body><h1>Hello ' + name + '!</h1></body></html>'

With Templates:
return render_template('hello.html', name=name)
```

### Creating Templates

1. Create a `templates` folder:

```bash
mkdir templates
```

2. Create `templates/hello.html`:

```html
<!DOCTYPE html>
<html>
<head>
    <title>Hello</title>
</head>
<body>
    <h1>Hello, {{ name }}!</h1>
    <p>Welcome to my Flask app.</p>
</body>
</html>
```

3. Use the template:

```python
from flask import render_template

@app.route('/hello/<name>')
def hello(name):
    return render_template('hello.html', name=name)
```

### Template Variables

Pass data from Flask to templates:

```python
@app.route('/user/<username>')
def show_user(username):
    user = {
        'username': username,
        'email': 'user@example.com',
        'is_admin': True
    }
    return render_template('user.html', user=user)
```

In `user.html`:

```html
<h1>User: {{ user.username }}</h1>
<p>Email: {{ user.email }}</p>

{% if user.is_admin %}
    <p>This user is an admin!</p>
{% endif %}
```

### Template Tags

```html
<!-- Variables -->
<p>{{ variable }}</p>

<!-- Conditions -->
{% if condition %}
    <p>This shows if condition is true</p>
{% else %}
    <p>This shows if condition is false</p>
{% endif %}

<!-- Loops -->
<ul>
{% for item in items %}
    <li>{{ item }}</li>
{% endfor %}
</ul>

<!-- Comments -->
{# This is a comment, not shown in the page #}
```

### Template Inheritance

Create a base template:

```html
<!-- templates/base.html -->
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

Use it in child templates:

```html
<!-- templates/home.html -->
{% extends "base.html" %}

{% block title %}Home{% endblock %}

{% block content %}
    <h1>Welcome to My Site!</h1>
    <p>This is the home page.</p>
{% endblock %}
```

---

## 7. Handling Requests & Responses

### Accessing Request Data

```python
from flask import request

@app.route('/search')
def search():
    # Get query parameter from URL
    # /search?q=flask&page=1
    query = request.args.get('q', '')
    page = request.args.get('page', 1, type=int)
    return f'Searching for: {query}, Page: {page}'

@app.route('/login', methods=['POST'])
def login():
    # Get form data from POST
    username = request.form.get('username')
    password = request.form.get('password')
    return f'Login: {username}'

@app.route('/api/data', methods=['POST'])
def api_data():
    # Get JSON data
    data = request.json
    return {'received': data}
```

### Working with Responses

```python
from flask import jsonify, make_response, redirect, abort

@app.route('/json')
def json_response():
    # Return JSON
    return jsonify({'message': 'Hello', 'status': 'success'})

@app.route('/custom')
def custom_response():
    # Custom status code and headers
    response = make_response('Custom response', 201)
    response.headers['X-Custom-Header'] = 'Value'
    return response

@app.route('/redirect')
def redirect_example():
    # Redirect to another page
    return redirect('/home')

@app.route('/not-found')
def not_found():
    # Return 404 error
    abort(404)
```

### Error Handling

```python
@app.errorhandler(404)
def page_not_found(error):
    return render_template('404.html'), 404

@app.errorhandler(500)
def internal_error(error):
    return render_template('500.html'), 500

@app.errorhandler(403)
def forbidden(error):
    return render_template('403.html'), 403
```

---

## 8. Forms & User Input

### Basic HTML Form

```html
<!-- templates/login.html -->
<form method="POST" action="/login">
    <input type="text" name="username" placeholder="Username">
    <input type="password" name="password" placeholder="Password">
    <button type="submit">Login</button>
</form>
```

### Handling Form Data

```python
from flask import request, render_template

@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        username = request.form.get('username')
        password = request.form.get('password')
        
        if username == 'admin' and password == 'secret':
            return 'Login successful!'
        else:
            return 'Invalid credentials!'
    
    return render_template('login.html')
```

### Using Flask-WTF (Better Forms)

Install Flask-WTF:

```bash
pip install flask-wtf
```

Define a form:

```python
from flask_wtf import FlaskForm
from wtforms import StringField, PasswordField, SubmitField
from wtforms.validators import DataRequired, Email, Length

class LoginForm(FlaskForm):
    username = StringField('Username', validators=[DataRequired()])
    password = PasswordField('Password', validators=[DataRequired()])
    submit = SubmitField('Login')
```

Use the form:

```python
from flask import render_template, flash, redirect

@app.route('/login', methods=['GET', 'POST'])
def login():
    form = LoginForm()
    
    if form.validate_on_submit():
        # Form is valid
        username = form.username.data
        password = form.password.data
        
        if username == 'admin' and password == 'secret':
            flash('Login successful!', 'success')
            return redirect('/dashboard')
        else:
            flash('Invalid credentials!', 'danger')
    
    return render_template('login.html', form=form)
```

Template with form:

```html
<!-- templates/login.html -->
<form method="POST">
    {{ form.csrf_token }}
    
    <div>
        {{ form.username.label }}
        {{ form.username }}
    </div>
    
    <div>
        {{ form.password.label }}
        {{ form.password }}
    </div>
    
    {{ form.submit }}
</form>
```

### Flash Messages

```python
from flask import flash

@app.route('/message')
def message_example():
    flash('This is a success message!', 'success')
    flash('This is an error message!', 'danger')
    flash('This is a warning message!', 'warning')
    return render_template('messages.html')
```

In template:

```html
{% with messages = get_flashed_messages(with_categories=true) %}
    {% if messages %}
        {% for category, message in messages %}
            <div class="alert alert-{{ category }}">
                {{ message }}
            </div>
        {% endfor %}
    {% endif %}
{% endwith %}
```

---

## 9. Database Basics

### What is a Database?

A database is like a digital filing cabinet where you store information:

```
Tables = Filing cabinets
Rows = Individual files
Columns = Information fields in each file
```

### SQLite (Simple Database)

SQLite is perfect for learning:

```python
# Connect to SQLite database
import sqlite3

# Create connection
conn = sqlite3.connect('database.db')
cursor = conn.cursor()

# Create table
cursor.execute('''
    CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        email TEXT NOT NULL
    )
''')

# Insert data
cursor.execute(
    'INSERT INTO users (username, email) VALUES (?, ?)',
    ('john', 'john@example.com')
)
conn.commit()

# Query data
cursor.execute('SELECT * FROM users')
users = cursor.fetchall()
for user in users:
    print(user)

# Close connection
conn.close()
```

### SQLAlchemy (Better Database)

SQLAlchemy is the recommended way to work with databases in Flask:

```bash
pip install flask-sqlalchemy
```

Setup:

```python
from flask_sqlalchemy import SQLAlchemy

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///database.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

db = SQLAlchemy(app)
```

Define a model:

```python
class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(50), unique=True, nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    def __repr__(self):
        return f'<User {self.username}>'
```

Create the database:

```python
with app.app_context():
    db.create_all()
```

CRUD operations:

```python
# CREATE
user = User(username='john', email='john@example.com')
db.session.add(user)
db.session.commit()

# READ
users = User.query.all()  # Get all users
user = User.query.get(1)  # Get by ID
user = User.query.filter_by(username='john').first()  # Filter

# UPDATE
user = User.query.get(1)
user.email = 'newemail@example.com'
db.session.commit()

# DELETE
user = User.query.get(1)
db.session.delete(user)
db.session.commit()
```

### Using Database with Routes

```python
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
```

---

## 10. Next Steps

### What You've Learned

✅ What Flask is and why to use it
✅ How web applications work
✅ Core Flask concepts (routes, templates, requests)
✅ How to create your first Flask app
✅ How to work with routes and views
✅ How to use templates with dynamic content
✅ How to handle requests and responses
✅ How to work with forms and user input
✅ Database basics with SQLAlchemy

### Continue Your Journey

1. **Practice**: Build small applications:
   - A blog
   - A to-do list
   - A contact form
   - A simple API

2. **Explore the Main Tutorial Series**:
   - Part 1: Flask Foundations & Architecture
   - Part 2: Routing, Requests & Templating
   - Part 3: Databases & ORM
   - Part 4: Authentication & Security
   - Part 5: RESTful APIs
   - Part 6: Async Programming
   - Part 7: Testing
   - Part 8: Production Deployment

3. **Key Resources**:
   - Flask Documentation: https://flask.palletsprojects.com
   - Flask Mega-Tutorial: https://blog.miguelgrinberg.com/post/the-flask-mega-tutorial
   - Flask Community: https://flask.palletsprojects.com/community

4. **Common Next Steps**:
   - Add authentication (login/register)
   - Connect to PostgreSQL instead of SQLite
   - Deploy to a cloud platform
   - Add a frontend framework (React, Vue)
   - Build a REST API

### Quick Reference Card

```python
# Creating a Flask app
from flask import Flask
app = Flask(__name__)

# Routes
@app.route('/')
def home():
    return 'Hello!'

# Templates
from flask import render_template
return render_template('page.html', data=data)

# Request data
from flask import request
query = request.args.get('q')
form_data = request.form.get('field')
json_data = request.json

# Responses
from flask import jsonify, redirect
return jsonify({'key': 'value'})
return redirect('/other-page')

# Database
from flask_sqlalchemy import SQLAlchemy
db = SQLAlchemy(app)

class Model(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100))

# CRUD
db.session.add(object)
db.session.commit()
Model.query.all()
Model.query.get(id)
```

---

## Summary

This primer has introduced you to the fundamental concepts of Flask:

1. **Flask is a web framework** for building web applications in Python
2. **Routes** connect URLs to functions
3. **Templates** separate HTML from logic
4. **Requests** contain data from users
5. **Responses** are what you send back
6. **Forms** handle user input
7. **Databases** store persistent data

You now have the foundation to start building Flask applications. The main tutorial series will build on these concepts and take you from beginner to production-ready developer!

**Happy coding!** 🚀
