# Primer 1: Python & Django Fundamentals

## Essential Python and Django Knowledge for the Masterclass

Welcome to **Primer 1** of the Django REST Framework & Next.js 16 masterclass. This primer is designed for developers who need a quick refresh or introduction to Python and Django fundamentals before diving into the main series.

---

## Section 1: Python Fundamentals

### 1.1 Variables and Data Types

```python
# Strings
name = "John Doe"
email = 'john@example.com'
multiline = """This is a
multi-line string"""

# Numbers
age = 30                # Integer
price = 19.99           # Float
complex_num = 3 + 4j    # Complex

# Booleans
is_active = True
is_deleted = False

# Lists (mutable)
tasks = ["Task 1", "Task 2", "Task 3"]
tasks.append("Task 4")
tasks[0] = "Updated Task"
first_task = tasks[0]

# Tuples (immutable)
coordinates = (10, 20)
x, y = coordinates  # Unpacking

# Dictionaries (key-value pairs)
user = {
    "id": 1,
    "name": "John",
    "email": "john@example.com"
}
user["age"] = 30
name = user.get("name")

# Sets (unique values)
tags = {"python", "django", "api"}
tags.add("rest")

# None (null)
result = None
```

### 1.2 Control Flow

```python
# If statements
age = 18
if age >= 18:
    print("Adult")
elif age >= 13:
    print("Teenager")
else:
    print("Child")

# For loops
for i in range(5):
    print(i)  # 0, 1, 2, 3, 4

for task in tasks:
    print(task)

for key, value in user.items():
    print(f"{key}: {value}")

# While loops
count = 0
while count < 5:
    print(count)
    count += 1

# Break and continue
for i in range(10):
    if i == 5:
        break  # Stop at 5
    if i % 2 == 0:
        continue  # Skip even numbers
    print(i)
```

### 1.3 Functions

```python
# Basic function
def greet(name):
    return f"Hello, {name}!"

# Default parameters
def greet_user(name, greeting="Hello"):
    return f"{greeting}, {name}!"

# Multiple parameters
def calculate(a, b, operation="add"):
    if operation == "add":
        return a + b
    elif operation == "subtract":
        return a - b
    elif operation == "multiply":
        return a * b
    else:
        return None

# Variable arguments
def sum_all(*args):
    return sum(args)

def print_user_info(**kwargs):
    for key, value in kwargs.items():
        print(f"{key}: {value}")

# Lambda functions
square = lambda x: x ** 2
result = square(5)  # 25

# Decorators
def timer(func):
    import time
    def wrapper(*args, **kwargs):
        start = time.time()
        result = func(*args, **kwargs)
        end = time.time()
        print(f"{func.__name__} took {end - start} seconds")
        return result
    return wrapper

@timer
def slow_function():
    import time
    time.sleep(1)
    return "Done"
```

### 1.4 Classes and OOP

```python
class User:
    # Class variable
    user_count = 0
    
    # Constructor
    def __init__(self, name, email):
        self.name = name
        self.email = email
        self._id = User.user_count + 1
        User.user_count += 1
    
    # Instance method
    def get_full_name(self):
        return self.name
    
    # Property (getter)
    @property
    def id(self):
        return self._id
    
    # Setter
    @id.setter
    def id(self, value):
        raise AttributeError("ID cannot be changed")
    
    # String representation
    def __str__(self):
        return f"User: {self.name}"
    
    def __repr__(self):
        return f"User(name='{self.name}', email='{self.email}')"

# Inheritance
class AdminUser(User):
    def __init__(self, name, email, permissions):
        super().__init__(name, email)
        self.permissions = permissions
    
    def can_delete(self):
        return "delete" in self.permissions

# Usage
user = User("John Doe", "john@example.com")
print(user.name)
print(user.id)

admin = AdminUser("Admin", "admin@example.com", ["delete", "edit"])
print(admin.can_delete())
```

### 1.5 Modules and Imports

```python
# Import entire module
import math
print(math.sqrt(16))

# Import specific functions
from datetime import datetime, timedelta
now = datetime.now()
tomorrow = now + timedelta(days=1)

# Import with alias
import json as js
data = js.dumps({"key": "value"})

# Import from package
from django.db import models
from .models import Task
from ..utils import helpers

# __init__.py makes a directory a Python package
```

### 1.6 Exception Handling

```python
# Try-except
try:
    result = 10 / 0
except ZeroDivisionError:
    print("Cannot divide by zero")
except Exception as e:
    print(f"Error: {e}")
else:
    print("No error occurred")
finally:
    print("This always runs")

# Custom exceptions
class ValidationError(Exception):
    pass

def validate_age(age):
    if age < 0:
        raise ValidationError("Age cannot be negative")
    return age

# Context managers (with statement)
with open("file.txt", "r") as file:
    content = file.read()
```

---

## Section 2: Django Fundamentals

### 2.1 Django Project Structure

```
myproject/
├── manage.py                 # Command-line utility
├── myproject/               # Project package
│   ├── __init__.py
│   ├── settings.py          # Project settings
│   ├── urls.py              # URL routing
│   ├── wsgi.py              # WSGI entry point
│   └── asgi.py              # ASGI entry point
└── myapp/                   # Application
    ├── __init__.py
    ├── admin.py             # Admin configuration
    ├── apps.py              # App configuration
    ├── models.py            # Database models
    ├── views.py             # View functions/classes
    ├── urls.py              # App-specific URLs
    └── tests.py             # Tests
```

### 2.2 Creating a Django Project

```bash
# Create virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install Django
pip install Django

# Create project
django-admin startproject myproject

# Create app
cd myproject
python manage.py startapp myapp

# Run development server
python manage.py runserver

# Create migrations
python manage.py makemigrations

# Run migrations
python manage.py migrate

# Create superuser
python manage.py createsuperuser
```

### 2.3 Django Models

```python
from django.db import models
from django.contrib.auth.models import User

class Task(models.Model):
    # Field types
    title = models.CharField(max_length=200)
    description = models.TextField(blank=True, null=True)
    
    # Choices
    class Status(models.TextChoices):
        TODO = 'todo', 'To Do'
        IN_PROGRESS = 'in_progress', 'In Progress'
        DONE = 'done', 'Done'
    
    status = models.CharField(
        max_length=20,
        choices=Status.choices,
        default=Status.TODO
    )
    
    # Foreign key
    created_by = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name='tasks'
    )
    
    # Many-to-many
    # tags = models.ManyToManyField(Tag)
    
    # Date fields
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    # Meta class
    class Meta:
        ordering = ['-created_at']
        verbose_name = 'Task'
        verbose_name_plural = 'Tasks'
        indexes = [
            models.Index(fields=['status']),
            models.Index(fields=['created_by', 'status']),
        ]
    
    # String representation
    def __str__(self):
        return self.title
    
    # Custom methods
    def mark_done(self):
        self.status = self.Status.DONE
        self.save()
```

### 2.4 Django ORM Queries

```python
# Create
task = Task.objects.create(
    title="Complete project",
    description="Finish the Django project",
    created_by=user
)

# Get all
tasks = Task.objects.all()

# Filter
done_tasks = Task.objects.filter(status='done')
user_tasks = Task.objects.filter(created_by=user)

# Exclude
not_done = Task.objects.exclude(status='done')

# Get single
task = Task.objects.get(id=1)

# First/Last
task = Task.objects.first()
task = Task.objects.last()

# Order
tasks = Task.objects.order_by('-created_at')

# Count
count = Task.objects.count()
user_count = Task.objects.filter(created_by=user).count()

# Exists
has_tasks = Task.objects.filter(created_by=user).exists()

# Update
Task.objects.filter(status='todo').update(status='in_progress')

# Delete
Task.objects.filter(status='archived').delete()

# Values
task_data = Task.objects.values('id', 'title', 'status')

# Related queries
tasks = Task.objects.select_related('created_by')
tasks = Task.objects.prefetch_related('comments')
```

### 2.5 Django Views

```python
# Function-based view
from django.shortcuts import render, get_object_or_404
from django.http import HttpResponse, JsonResponse

def task_list(request):
    tasks = Task.objects.all()
    return render(request, 'tasks/list.html', {'tasks': tasks})

# Class-based view
from django.views.generic import ListView, DetailView, CreateView

class TaskListView(ListView):
    model = Task
    template_name = 'tasks/list.html'
    context_object_name = 'tasks'
    ordering = ['-created_at']
    
    def get_queryset(self):
        queryset = super().get_queryset()
        status = self.request.GET.get('status')
        if status:
            queryset = queryset.filter(status=status)
        return queryset

class TaskDetailView(DetailView):
    model = Task
    template_name = 'tasks/detail.html'
    context_object_name = 'task'

class TaskCreateView(CreateView):
    model = Task
    fields = ['title', 'description', 'status']
    template_name = 'tasks/create.html'
    success_url = '/tasks/'
    
    def form_valid(self, form):
        form.instance.created_by = self.request.user
        return super().form_valid(form)
```

### 2.6 Django URLs

```python
# myproject/urls.py
from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path('admin/', admin.site.urls),
    path('tasks/', include('tasks.urls')),
]

# myapp/urls.py
from django.urls import path
from . import views

urlpatterns = [
    path('', views.task_list, name='task-list'),
    path('<int:pk>/', views.task_detail, name='task-detail'),
    path('create/', views.task_create, name='task-create'),
]

# URL patterns with parameters
path('tasks/<int:pk>/', views.task_detail)  # tasks/1/
path('tasks/<slug:slug>/', views.task_detail)  # tasks/my-task/
path('tasks/<uuid:uuid>/', views.task_detail)  # tasks/123e4567-e89b-12d3-a456-426614174000/

# Named URLs
from django.urls import reverse
url = reverse('task-detail', kwargs={'pk': 1})  # /tasks/1/

# URL parameters in templates
<a href="{% url 'task-detail' pk=task.id %}">{{ task.title }}</a>
```

### 2.7 Django Templates

```html
<!-- Base template -->
<!-- templates/base.html -->
<!DOCTYPE html>
<html>
<head>
    <title>{% block title %}TaskFlow{% endblock %}</title>
</head>
<body>
    <nav>
        <a href="{% url 'task-list' %}">Tasks</a>
        {% if user.is_authenticated %}
            <a href="{% url 'logout' %}">Logout</a>
        {% endif %}
    </nav>
    
    <main>
        {% block content %}{% endblock %}
    </main>
</body>
</html>

<!-- Child template -->
<!-- templates/tasks/list.html -->
{% extends 'base.html' %}

{% block title %}Tasks - TaskFlow{% endblock %}

{% block content %}
    <h1>Tasks</h1>
    
    <form method="get">
        <select name="status">
            <option value="">All</option>
            <option value="todo">To Do</option>
            <option value="in_progress">In Progress</option>
            <option value="done">Done</option>
        </select>
        <button type="submit">Filter</button>
    </form>
    
    <ul>
        {% for task in tasks %}
            <li>
                <a href="{% url 'task-detail' pk=task.id %}">
                    {{ task.title }}
                </a>
                <span class="status">{{ task.get_status_display }}</span>
            </li>
        {% empty %}
            <li>No tasks yet</li>
        {% endfor %}
    </ul>
    
    <a href="{% url 'task-create' %}">Create Task</a>
    
    {% if is_paginated %}
        <div class="pagination">
            {% if page_obj.has_previous %}
                <a href="?page=1">First</a>
                <a href="?page={{ page_obj.previous_page_number }}">Previous</a>
            {% endif %}
            <span>Page {{ page_obj.number }} of {{ page_obj.paginator.num_pages }}</span>
            {% if page_obj.has_next %}
                <a href="?page={{ page_obj.next_page_number }}">Next</a>
                <a href="?page={{ page_obj.paginator.num_pages }}">Last</a>
            {% endif %}
        </div>
    {% endif %}
{% endblock %}
```

### 2.8 Django Forms

```python
# forms.py
from django import forms
from .models import Task

class TaskForm(forms.ModelForm):
    class Meta:
        model = Task
        fields = ['title', 'description', 'status']
        widgets = {
            'description': forms.Textarea(attrs={'rows': 4}),
            'status': forms.Select(choices=Task.Status.choices),
        }

# views.py
from django.views.generic.edit import CreateView, UpdateView
from django.urls import reverse_lazy

class TaskCreateView(CreateView):
    model = Task
    form_class = TaskForm
    template_name = 'tasks/form.html'
    success_url = reverse_lazy('task-list')
    
    def form_valid(self, form):
        form.instance.created_by = self.request.user
        return super().form_valid(form)
```

### 2.9 Django Admin

```python
# admin.py
from django.contrib import admin
from .models import Task

@admin.register(Task)
class TaskAdmin(admin.ModelAdmin):
    list_display = ['title', 'status', 'created_by', 'created_at']
    list_filter = ['status', 'created_at']
    search_fields = ['title', 'description']
    date_hierarchy = 'created_at'
    ordering = ['-created_at']
    readonly_fields = ['created_at', 'updated_at']
    
    fieldsets = (
        ('Task Information', {
            'fields': ('title', 'description', 'status')
        }),
        ('User Information', {
            'fields': ('created_by',)
        }),
        ('Timestamps', {
            'fields': ('created_at', 'updated_at'),
            'classes': ('collapse',)
        }),
    )
```

### 2.10 Django Settings

```python
# settings.py
import os
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent.parent

SECRET_KEY = 'django-insecure-...'
DEBUG = True
ALLOWED_HOSTS = ['localhost', '127.0.0.1']

INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'myapp',
]

MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

ROOT_URLCONF = 'myproject.urls'

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [BASE_DIR / 'templates'],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.debug',
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': BASE_DIR / 'db.sqlite3',
    }
}

AUTH_PASSWORD_VALIDATORS = [
    {
        'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator',
    },
]

STATIC_URL = 'static/'
DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'
```

---

## Quick Reference Cards

### Python Cheat Sheet

```python
# List comprehensions
squares = [x**2 for x in range(10)]
even_numbers = [x for x in range(10) if x % 2 == 0]

# Dictionary comprehensions
square_dict = {x: x**2 for x in range(10)}

# Map, Filter, Reduce
doubled = list(map(lambda x: x * 2, numbers))
filtered = list(filter(lambda x: x > 5, numbers))

# Context managers
with open('file.txt', 'r') as f:
    content = f.read()

# Generators
def fibonacci():
    a, b = 0, 1
    while True:
        yield a
        a, b = b, a + b
```

### Django Cheat Sheet

```bash
# Commands
python manage.py runserver
python manage.py makemigrations
python manage.py migrate
python manage.py createsuperuser
python manage.py shell
python manage.py test
python manage.py collectstatic

# Common imports
from django.db import models
from django.shortcuts import render, get_object_or_404
from django.urls import path, reverse
from django.views.generic import ListView, DetailView, CreateView
from django.contrib.auth.models import User
from django.contrib.auth.decorators import login_required
```

---

*This concludes Primer 1. You now have the essential Python and Django knowledge needed for the masterclass.*
