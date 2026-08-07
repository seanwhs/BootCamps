# Part 1: Django Fundamentals, Environment Setup, and Your First Application

## Welcome to Part 1!

You've completed the introduction. Now it's time to get your hands dirty and build something real. In this part, we'll:

1. Set up a professional Python development environment
2. Install Django 6
3. Create your first Django project
4. Understand the project structure
5. Build your first views and templates
6. Create a working website with navigation

By the end of this part, you'll have a **functional multi-page website** running on your computer. This isn't just a "hello world" — you'll have a real website with a homepage, an about page, a blog page, and a shared navigation that works across all pages.

Let's begin!

---

## Target 1.1: Setting Up Your Python Environment

### The Concept

Before we can write Django code, we need to set up a clean Python environment. Think of this like preparing a clean workspace before starting a craft project — you want to keep your tools organized and separated from other projects.

In Python, we use **virtual environments** to isolate project dependencies. This means:
- Each project can have its own packages and versions
- You don't accidentally break one project when updating another
- You can easily reproduce your environment on other computers

We'll use **uv** — a modern, fast Python package manager — or **pip** if you prefer the traditional approach. I'll show you both.

### The Implementation

#### Option 1: Using uv (Recommended)

**uv** is a new Python package manager that's significantly faster than pip. If you're starting fresh, I recommend this approach.

**Step 1: Install uv**

```bash
# On macOS/Linux
curl -LsSf https://astral.sh/uv/install.sh | sh

# On Windows (PowerShell)
powershell -c "irm https://astral.sh/uv/install.ps1 | iex"

# Verify installation
uv --version
```

**Step 2: Create Your Project Directory**

```bash
# Navigate to where you want your project
cd ~/DjangoProjects  # or C:\Users\YourName\DjangoProjects

# Create the project folder
mkdir django_blog_project
cd django_blog_project
```

**Step 3: Create a Virtual Environment with uv**

```bash
# uv creates a virtual environment automatically when you install packages
# But let's explicitly create one:
uv venv

# This creates a .venv directory with your isolated Python environment
```

**Step 4: Activate the Virtual Environment**

```bash
# On macOS/Linux
source .venv/bin/activate

# On Windows (Command Prompt)
.venv\Scripts\activate

# On Windows (PowerShell)
.venv\Scripts\Activate.ps1
```

You should see `(.venv)` appear at the beginning of your terminal prompt, indicating the virtual environment is active.

**Step 5: Install Django with uv**

```bash
uv pip install django==6.0
```

**Step 6: Create requirements.txt**

```bash
uv pip freeze > requirements.txt
```

This creates a file listing all installed packages with their exact versions. Anyone can recreate your environment using this file.

#### Option 2: Using pip (Traditional)

If you prefer using standard pip, here's the equivalent approach:

```bash
# Create your project directory
mkdir django_blog_project
cd django_blog_project

# Create virtual environment
python -m venv .venv

# Activate it
# On macOS/Linux:
source .venv/bin/activate
# On Windows Command Prompt:
.venv\Scripts\activate
# On Windows PowerShell:
.venv\Scripts\Activate.ps1

# Install Django
pip install django==6.0

# Create requirements.txt
pip freeze > requirements.txt
```

### The Verification

Let's verify everything installed correctly:

```bash
# Check Python version (should be 3.14 or similar)
python --version

# Check Django version
python -m django --version
```

You should see something like:
```
Python 3.14.0
6.0
```

If you see version numbers, your environment is ready!

---

## Target 1.2: Creating Your First Django Project

### The Concept

Now that we have Django installed, we need to create a **Django project**. A Django project is the entire web application — it includes settings, configurations, and multiple applications.

Think of a Django project like a house:
- The **project** is the house itself (foundation, roof, wiring)
- **Applications** are the rooms inside (kitchen, bedroom, bathroom)
- Each application handles a specific feature

We'll create a project called `config` (the Django default is to use your project name, but we'll keep it clear).

### The Implementation

```bash
# Make sure you're in the django_blog_project directory
# and your virtual environment is activated

# Create the Django project
django-admin startproject config .

# The "." at the end means "create the project in the current directory"
# instead of creating a nested folder structure
```

Let's break down what this command created:

```
django_blog_project/
│
├── config/                    ← Your project configuration
│   ├── __init__.py            ← Marks this as a Python package
│   ├── settings.py            ← ALL your Django settings
│   ├── urls.py                ← URL routing for the entire project
│   ├── asgi.py                ← ASGI configuration (for async)
│   └── wsgi.py                ← WSGI configuration (for production)
│
├── manage.py                  ← Django's command-line utility
├── .venv/                     ← Your virtual environment
└── requirements.txt           ← Your dependencies
```

**Important Files Explained:**

- **manage.py**: This is your command center. You run all Django commands through it (starting the server, creating migrations, running tests).
- **settings.py**: This contains every configuration for your project — databases, security, installed apps, middleware, templates, and more.
- **urls.py**: This is your website's map. It tells Django which view to show when a user visits a specific URL.
- **wsgi.py**: Web Server Gateway Interface — this is how production servers (like Gunicorn) talk to your Django application.

### The Verification

Let's test that our project works:

```bash
# Run the development server
python manage.py runserver
```

You should see output like:
```
Watching for file changes with StatReloader
Performing system checks...

System check identified no issues (0 silenced).

You have 18 unapplied migration(s). Your project may not work properly until you apply the migrations for app(s): admin, auth, contenttypes, sessions.
Run 'python manage.py migrate' to apply them.

March 15, 2026 - 14:32:10
Django version 6.0, using settings 'config.settings'
Starting development server at http://127.0.0.1:8000/
Quit the server with CONTROL-C.
```

Now open your browser and visit: **http://127.0.0.1:8000/**

You should see the Django welcome page with the rocket ship. Congratulations — you have a working Django project!

> **Note about migrations**: The warning about unapplied migrations is normal. We'll apply them in Part 2 when we set up the database. For now, just leave it.

Press `CTRL+C` in your terminal to stop the server.

---

## Target 1.3: Understanding Django's MVT Architecture

### The Concept

Before we build our first feature, you need to understand Django's architectural pattern. Django follows a pattern called **MVT** (Model-View-Template), which is slightly different from the more common MVC (Model-View-Controller).

Here's how Django handles a request:

```
┌─────────────┐
│   Browser   │
└──────┬──────┘
       │ 1. User visits /blog/
       ▼
┌─────────────┐
│   URLs      │ 2. Django looks at urls.py to find which view
│  (urls.py)  │    should handle this URL
└──────┬──────┘
       │
       ▼
┌─────────────┐
│   View      │ 3. The view function runs. It might query the database,
│  (views.py) │    process forms, or do other business logic.
└──────┬──────┘
       │
       ▼
┌─────────────┐
│   Model     │ 4. If needed, the view queries the database through
│  (models.py)│    the ORM (Object-Relational Mapping)
└──────┬──────┘
       │
       ▼
┌─────────────┐
│   Template  │ 5. The view renders a template with data
│  (.html)    │    and returns HTML to the browser
└──────┬──────┘
       │
       ▼
┌─────────────┐
│   Browser   │ 6. User sees the rendered page
└─────────────┘
```

The key insight: **The view is the brain**. It decides what data to show and which template to use.

### Real-World Analogy

Imagine you're running a restaurant:

- **URLs** = The menu board at the front (shows what's available)
- **View** = The chef (takes orders, prepares food, coordinates everything)
- **Model** = The kitchen inventory (ingredients, recipes, storage)
- **Template** = The plate presentation (how the food looks when served)

When a customer (browser) wants a pizza (blog post), they look at the menu (URL), the chef (view) checks inventory (model), makes the pizza, plates it (template), and serves it.

---

## Target 1.4: Creating Your First Django Application

### The Concept

Now we'll create our first Django **application** (app). Remember: a Django project is the whole website, and apps are specific features within that website.

For our blog, we'll create a `blog` app that handles all blog-related functionality.

**Why separate apps?**
- Modular code is easier to maintain
- Apps can be reused in other projects
- It keeps the code organized as your project grows

### The Implementation

```bash
# Create the blog app
python manage.py startapp blog
```

This creates a `blog/` folder with this structure:

```
blog/
├── migrations/              ← Database change scripts
│   └── __init__.py
├── __init__.py              ← Makes it a Python package
├── admin.py                 ← Django admin configuration
├── apps.py                  ← App configuration
├── models.py                ← Database models (we'll fill this later)
├── tests.py                 ← Tests for this app
└── views.py                 ← Views for this app
```

Now we need to tell Django that this app exists. We do this in `config/settings.py`:

**File: `config/settings.py`** (partial — find the `INSTALLED_APPS` list)

```python
# config/settings.py

INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    
    # Custom apps
    'blog',  # <- Add our blog app here
]
```

### The Verification

We can verify the app is installed by running:

```bash
python manage.py check
```

You should see:
```
System check identified no issues (0 silenced).
```

This means Django recognizes your app without any errors.

---

## Target 1.5: Creating Your First Views

### The Concept

A **view** is a Python function (or class) that takes a web request and returns a web response. It's the heart of your application.

Think of a view as a "request handler" — when someone visits a URL, the view:
1. Receives the request
2. Does whatever work is needed
3. Returns a response (usually HTML)

We'll create three views to start:
- `home`: The homepage
- `about`: An about page
- `blog`: A page that will eventually show blog posts

### The Implementation

**File: `blog/views.py`**

```python
from django.shortcuts import render
from django.http import HttpResponse

# Create your views here.

def home(request):
    """
    Homepage view.
    
    This view renders the homepage template with a simple context.
    The 'request' parameter contains all information about the HTTP request.
    """
    # Context data that will be available in the template
    context = {
        'page_title': 'Welcome to My Django Blog',
        'welcome_message': 'This is the beginning of your Django journey!',
        'year': 2026,
    }
    
    # render() combines the template with the context data
    # and returns an HttpResponse containing the rendered HTML
    return render(request, 'blog/home.html', context)


def about(request):
    """
    About page view.
    
    Renders a simple about page with information about the blog.
    """
    context = {
        'page_title': 'About This Blog',
        'description': 'This blog is built using Django 6, a powerful Python web framework.',
        'technologies': ['Django 6', 'Python 3.14', 'HTML5', 'CSS3'],
        'year': 2026,
    }
    
    return render(request, 'blog/about.html', context)


def blog_list(request):
    """
    Blog listing view.
    
    For now, this displays a placeholder page.
    In Part 2, this will show actual database content.
    """
    context = {
        'page_title': 'Blog Posts',
        'posts': [],  # Empty for now - we'll fill this in Part 2
        'year': 2026,
    }
    
    return render(request, 'blog/blog_list.html', context)
```

Let's understand what's happening:

1. **`render(request, template, context)`**: This Django shortcut function:
   - Takes the request object
   - Finds the template file
   - Merges the context data into the template
   - Returns an HTTP response with the rendered HTML

2. **Context**: The `context` dictionary contains data passed to the template. In Django templates, you can use `{{ variable_name }}` to display this data.

3. **HttpResponse**: While we're using `render()`, under the hood it returns an `HttpResponse` object. Sometimes you might return an `HttpResponse` directly:

```python
def simple_view(request):
    return HttpResponse("Hello, World!")
```

---

## Target 1.6: Creating Your First Templates

### The Concept

**Templates** are HTML files with special Django template syntax that allows you to inject dynamic content. They're what the user actually sees in their browser.

Think of templates like a form letter — you have a fixed structure, and you fill in the blanks with specific information.

We'll create:
1. A **base template** (`base.html`) that all pages inherit from
2. **Page templates** (`home.html`, `about.html`, `blog_list.html`) that extend the base

### The Implementation

First, create the templates directory structure:

```bash
# Create template directories
mkdir -p blog/templates/blog
```

Now create the base template (this will be the "skeleton" for all pages):

**File: `blog/templates/blog/base.html`**

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{% block title %}Django Blog{% endblock %}</title>
    
    <!-- We'll add CSS later -->
    <style>
        /* Basic reset and styling */
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, sans-serif;
            line-height: 1.6;
            color: #333;
            background-color: #f8f9fa;
        }
        
        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 0 20px;
        }
        
        /* Navigation styles */
        nav {
            background-color: #2c3e50;
            color: white;
            padding: 1rem 0;
            margin-bottom: 2rem;
        }
        
        nav .container {
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        nav .nav-brand {
            font-size: 1.5rem;
            font-weight: bold;
            text-decoration: none;
            color: white;
        }
        
        nav .nav-links {
            display: flex;
            gap: 1.5rem;
            list-style: none;
        }
        
        nav .nav-links a {
            color: #ecf0f1;
            text-decoration: none;
            padding: 0.5rem 0;
            transition: color 0.3s ease;
        }
        
        nav .nav-links a:hover {
            color: #3498db;
        }
        
        /* Main content */
        main {
            min-height: 70vh;
            padding: 2rem 0;
        }
        
        /* Footer */
        footer {
            background-color: #2c3e50;
            color: #ecf0f1;
            text-align: center;
            padding: 1.5rem 0;
            margin-top: 3rem;
        }
        
        footer a {
            color: #3498db;
            text-decoration: none;
        }
        
        footer a:hover {
            text-decoration: underline;
        }
        
        /* Utilities */
        .page-header {
            margin-bottom: 2rem;
        }
        
        .page-header h1 {
            font-size: 2.5rem;
            color: #2c3e50;
        }
        
        .page-header .subtitle {
            color: #7f8c8d;
            font-size: 1.1rem;
        }
        
        .content {
            background: white;
            padding: 2rem;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
    </style>
</head>
<body>
    <!-- Navigation -->
    <nav>
        <div class="container">
            <a href="{% url 'home' %}" class="nav-brand">Django Blog</a>
            <ul class="nav-links">
                <li><a href="{% url 'home' %}">Home</a></li>
                <li><a href="{% url 'blog_list' %}">Blog</a></li>
                <li><a href="{% url 'about' %}">About</a></li>
            </ul>
        </div>
    </nav>
    
    <!-- Main Content -->
    <main>
        <div class="container">
            {% block content %}
            <!-- This is where page-specific content goes -->
            {% endblock %}
        </div>
    </main>
    
    <!-- Footer -->
    <footer>
        <div class="container">
            <p>&copy; {{ year }} Django Blog. Built with ❤️ using Django 6.</p>
        </div>
    </footer>
</body>
</html>
```

Now create the homepage template:

**File: `blog/templates/blog/home.html`**

```html
{% extends 'blog/base.html' %}

{% block title %}
    {{ page_title }} — Django Blog
{% endblock %}

{% block content %}
<div class="page-header">
    <h1>{{ welcome_message }}</h1>
    <p class="subtitle">Learn Django by building a real application.</p>
</div>

<div class="content">
    <h2>Welcome to Your Django Journey</h2>
    <p>This blog is being built step by step as part of the Mastering Django 6 series.</p>
    <p>Here's what you'll build:</p>
    <ul>
        <li>✅ A fully functional Django website</li>
        <li>✅ Database-driven content</li>
        <li>✅ User authentication and accounts</li>
        <li>✅ Search and filtering</li>
        <li>✅ File uploads and image management</li>
        <li>✅ Testing and debugging</li>
        <li>✅ Production deployment with Docker</li>
    </ul>
    <p style="margin-top: 1rem;">
        <a href="{% url 'blog_list' %}" style="color: #3498db; text-decoration: none;">
            View Blog Posts →
        </a>
    </p>
</div>
{% endblock %}
```

Create the about page template:

**File: `blog/templates/blog/about.html`**

```html
{% extends 'blog/base.html' %}

{% block title %}
    {{ page_title }} — Django Blog
{% endblock %}

{% block content %}
<div class="page-header">
    <h1>{{ page_title }}</h1>
    <p class="subtitle">Learn more about this project</p>
</div>

<div class="content">
    <h2>{{ description }}</h2>
    <p>This blog is built using:</p>
    <ul>
        {% for tech in technologies %}
            <li>{{ tech }}</li>
        {% empty %}
            <li>No technologies listed</li>
        {% endfor %}
    </ul>
    
    <h3 style="margin-top: 2rem;">Why Server-Rendered Monolith?</h3>
    <p>
        This blog uses Django's traditional server-rendered architecture.
        It's simpler, more secure, and easier to maintain than modern
        API-based approaches for most applications.
    </p>
    
    <p style="margin-top: 1rem;">
        <a href="{% url 'home' %}" style="color: #3498db; text-decoration: none;">
            ← Back to Home
        </a>
    </p>
</div>
{% endblock %}
```

Create the blog listing template:

**File: `blog/templates/blog/blog_list.html`**

```html
{% extends 'blog/base.html' %}

{% block title %}
    {{ page_title }} — Django Blog
{% endblock %}

{% block content %}
<div class="page-header">
    <h1>{{ page_title }}</h1>
    <p class="subtitle">Coming soon: Blog posts with database integration</p>
</div>

<div class="content">
    {% if posts %}
        <!-- This will display real posts in Part 2 -->
        {% for post in posts %}
            <div class="post-item">
                <h3>{{ post.title }}</h3>
                <p>{{ post.content|truncatewords:30 }}</p>
                <p><small>Published on {{ post.created_at }}</small></p>
            </div>
        {% endfor %}
    {% else %}
        <p style="color: #7f8c8d;">
            No blog posts available yet. Check back later!
        </p>
        <p>
            <em>Note: Database integration is coming in Part 2.</em>
        </p>
    {% endif %}
    
    <p style="margin-top: 2rem;">
        <a href="{% url 'home' %}" style="color: #3498db; text-decoration: none;">
            ← Back to Home
        </a>
    </p>
</div>
{% endblock %}
```

---

## Target 1.7: Creating URLs to Connect Views and Templates

### The Concept

**URLs** connect the URL a user visits to the view that handles it. In Django, you define these in `urls.py` files.

We need two levels of URL configuration:
1. **Project-level**: In `config/urls.py` — includes app URLs
2. **App-level**: In `blog/urls.py` — app-specific URL patterns

### The Implementation

First, create the blog app's URL file:

**File: `blog/urls.py`** (create this new file)

```python
from django.urls import path
from . import views

# Application namespace - helps Django identify URLs when multiple apps have the same name
app_name = 'blog'

# URL patterns for the blog app
urlpatterns = [
    # Home page - /blog/ or / (if included at root)
    path('', views.home, name='home'),
    
    # About page - /about/
    path('about/', views.about, name='about'),
    
    # Blog list page - /blog/
    path('blog/', views.blog_list, name='blog_list'),
]
```

Now update the project's main URL file:

**File: `config/urls.py`**

```python
from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    # Django admin interface - /admin/
    path('admin/', admin.site.urls),
    
    # Include the blog app's URLs at the root
    # All blog URLs will be accessible from the root path
    path('', include('blog.urls')),
]
```

Let's understand what this does:

1. **`path('', include('blog.urls'))`**: This tells Django to include all blog app URLs at the root (empty path) of your website.
2. **`app_name = 'blog'`**: This sets a namespace for reverse URL lookups (we use `{% url 'home' %}` in templates).
3. **Named URLs**: Each URL gets a `name` like `'home'`, `'about'`, `'blog_list'` — these names can be used in templates to generate URLs.

### The Verification

Now let's test everything works:

```bash
# Start the development server
python manage.py runserver
```

Now visit these URLs in your browser:

1. **http://127.0.0.1:8000/** → Should show the homepage
2. **http://127.0.0.1:8000/blog/** → Should show the blog list
3. **http://127.0.0.1:8000/about/** → Should show the about page

You should see the navigation working between all pages. Click the links in the navigation to verify they work.

If you see the pages with proper styling, congratulations! You've built a functional Django website.

---

## Understanding Template Tags and Filters

### The Concept

Django templates use **tags** and **filters** to add logic and formatting to your HTML:

- **Tags**: `{% tag %}` — Control flow (if, for, include, extends)
- **Filters**: `{{ variable|filter }}` — Transform data (uppercase, truncate, date format)

### Common Template Tags

| Tag | Purpose | Example |
|-----|---------|---------|
| `{% extends %}` | Inherit from another template | `{% extends 'base.html' %}` |
| `{% block %}` | Define a block to be filled | `{% block content %}{% endblock %}` |
| `{% include %}` | Insert another template | `{% include 'header.html' %}` |
| `{% if %}` | Conditional rendering | `{% if user.is_authenticated %}` |
| `{% for %}` | Loop over a list | `{% for post in posts %}` |
| `{% url %}` | Generate a URL by name | `{% url 'blog:home' %}` |
| `{% load %}` | Load template tags | `{% load static %}` |
| `{% comment %}` | Comments | `{% comment %}This won't be shown{% endcomment %}` |

### Common Template Filters

| Filter | Purpose | Example |
|--------|---------|---------|
| `lower` | Convert to lowercase | `{{ name|lower }}` |
| `upper` | Convert to uppercase | `{{ name|upper }}` |
| `title` | Title case | `{{ name|title }}` |
| `length` | Get length | `{{ list|length }}` |
| `default` | Provide default value | `{{ value|default:"Nothing" }}` |
| `truncatewords` | Cut off after N words | `{{ text|truncatewords:30 }}` |
| `date` | Format a date | `{{ date|date:"Y-m-d" }}` |
| `linebreaks` | Convert newlines to `<br>` | `{{ text|linebreaks }}` |
| `safe` | Mark HTML as safe | `{{ html|safe }}` |

---

## The Complete Project So Far

Here's what your project structure looks like after Part 1:

```
django_blog_project/
├── manage.py
├── requirements.txt
├── .venv/
│
├── config/
│   ├── __init__.py
│   ├── settings.py
│   ├── urls.py
│   └── wsgi.py
│
└── blog/
    ├── migrations/
    │   └── __init__.py
    ├── templates/
    │   └── blog/
    │       ├── base.html
    │       ├── home.html
    │       ├── about.html
    │       └── blog_list.html
    ├── __init__.py
    ├── admin.py
    ├── apps.py
    ├── models.py
    ├── tests.py
    ├── urls.py
    └── views.py
```

---

## The Verification - Final Comprehensive Test

Let's do a final comprehensive test:

```bash
# Make sure you're in the project root with virtual environment activated
python manage.py runserver
```

Now visit each page and verify:

1. **http://127.0.0.1:8000/** → Homepage displays with welcome message and list of features
2. **http://127.0.0.1:8000/blog/** → Blog page shows "No blog posts available yet"
3. **http://127.0.0.1:8000/about/** → About page displays technologies list
4. **Navigation** → Click Home, Blog, About — all links work
5. **Styling** → Pages have clean, professional styling with proper colors and spacing

If everything works, congratulations! You've built your first Django website.

---

## Common Errors and Troubleshooting

### Error: "No module named 'django'"
**Cause**: Virtual environment not activated or Django not installed
**Fix**:
```bash
# Activate virtual environment
source .venv/bin/activate  # macOS/Linux
.venv\Scripts\activate     # Windows

# Install Django if needed
uv pip install django==6.0
```

### Error: "TemplateDoesNotExist at /"
**Cause**: Template file missing or path incorrect
**Fix**: Check that:
- File exists at `blog/templates/blog/home.html`
- You're using the correct path in `render()`
- `'APP_DIRS': True` is set in settings

### Error: "NoReverseMatch at /"
**Cause**: URL name doesn't exist or namespace is wrong
**Fix**: Check:
- URL names in `blog/urls.py` match template `{% url %}`
- You're using the correct namespace (e.g., `blog:home`)

### Error: "AttributeError: module 'blog.views' has no attribute 'home'"
**Cause**: View function not defined or has a typo
**Fix**: Check that the view function name matches what's in `blog/urls.py`

---

## Challenge: Extend Your Website

Try these exercises to reinforce what you've learned:

### Challenge 1: Add a New Page
Create a "Contact" page:
1. Add a new view in `views.py`: `def contact(request):`
2. Create a new template: `contact.html`
3. Add the URL in `blog/urls.py`
4. Add a link in the navigation

### Challenge 2: Add a Footer Include
1. Create `blog/templates/blog/includes/footer.html`
2. Move the footer HTML from base.html to the new file
3. Use `{% include 'blog/includes/footer.html' %}` in base.html

### Challenge 3: Customize the Styling
1. Change the primary color in the `<style>` block
2. Add a background gradient
3. Add hover effects to navigation items

### Challenge 4: Add a Current Year Context Processor
Instead of passing `year` to every view, create a context processor that adds the current year globally.

---

## What You've Learned in Part 1

### ✅ Skills Acquired
- Setting up Python virtual environments
- Installing Django 6
- Creating Django projects and applications
- Understanding Django's MVT architecture
- Writing function-based views
- Creating templates with template inheritance
- Configuring URLs at project and app level
- Understanding the request/response cycle
- Using `{% url %}` for dynamic URL generation

### ✅ What You've Built
- A working Django project with proper structure
- Three pages (home, about, blog) with navigation
- A shared base template with inheritance
- Professional CSS styling

---

## Quick Reference: Commands Used in Part 1

```bash
# Environment Setup
uv venv                      # Create virtual environment
source .venv/bin/activate   # Activate (macOS/Linux)
.venv\Scripts\activate      # Activate (Windows)
uv pip install django==6.0  # Install Django
uv pip freeze > requirements.txt  # Create requirements file

# Django Commands
django-admin startproject config .  # Create project
python manage.py startapp blog      # Create app
python manage.py runserver          # Start development server
python manage.py check              # Verify project
```

---

## Quick Reference: Django Template Syntax

```html
{# Comments #}

{% block content %}{% endblock %}    {# Define a block #}
{% extends 'base.html' %}            {# Inherit from base #}
{% include 'includes/header.html' %} {# Include a template #}
{% load static %}                    {# Load static tags #}

{% if condition %}
    <!-- Show if true -->
{% elif other_condition %}
    <!-- Show if first false and second true -->
{% else %}
    <!-- Show if all false -->
{% endif %}

{% for item in list %}
    {{ item }}
{% empty %}
    <!-- Show if list is empty -->
{% endfor %}

{{ variable }}               {# Display a variable #}
{{ variable|default:"N/A" }} {# Apply a filter #}
{{ variable|truncatewords:30 }} {# Limit words #}

{% url 'app_name:view_name' %}  {# Generate a URL #}
```

---

## Ready for Part 2?

You've built a strong foundation. Take a moment to appreciate what you've accomplished — you've gone from zero to a working Django website in one part!

When you're ready, proceed to Part 2, where we'll bring your blog to life with real data.
