# Mastering Django 6: Student Workbook

## Full-Stack Web Development with Python

---

# Welcome!

This workbook is designed to accompany the **Mastering Django 6** video series. It provides a structured way to follow along, take notes, complete exercises, and track your progress.

**How to use this workbook:**

1. **Before each video:** Review the learning objectives and key concepts
2. **During each video:** Fill in the blanks and take notes
3. **After each video:** Complete the coding exercises and self-assessment
4. **Throughout the series:** Use the quick reference sections for review

---

# Table of Contents

**Part 0: Introduction** 
- 0.1: Welcome to Django
- 0.2: Setting Up Your Learning Environment

**Part 1: Django Fundamentals**
- 1.1: Your First Django Project
- 1.2: Understanding MVT
- 1.3: Views and URLs
- 1.4: Templates
- 1.5: Exercise: Build a Contact Page

**Part 2: Models and Databases**
- 2.1: Designing Database Models
- 2.2: Migrations
- 2.3: Django Admin
- 2.4: Django ORM
- 2.5: Exercise: Add a Comment Model

**Part 3: Forms and CRUD**
- 3.1: Django Forms
- 3.2: Creating Posts
- 3.3: Editing and Deleting Posts
- 3.4: Exercise: Add Post Scheduling

**Part 4: Class-Based Views**
- 4.1: Understanding CBVs
- 4.2: ListView and DetailView
- 4.3: CreateView, UpdateView, DeleteView
- 4.4: Search and Filtering
- 4.5: Exercise: Add Category Filtering

**Part 5: Authentication and Users**
- 5.1: User Registration
- 5.2: Login and Logout
- 5.3: User Profiles
- 5.4: Password Reset
- 5.5: Exercise: Add a User Dashboard

**Part 6: Advanced Architecture**
- 6.1: Middleware
- 6.2: Context Processors
- 6.3: Signals
- 6.4: Service Layer
- 6.5: Exercise: Create Custom Middleware

**Part 7: Real-World Features**
- 7.1: File Uploads
- 7.2: Email Notifications
- 7.3: Sessions
- 7.4: Database Transactions
- 7.5: Exercise: Add Post Scheduling

**Part 8: Testing and Quality**
- 8.1: Testing Models
- 8.2: Testing Forms
- 8.3: Testing Views
- 8.4: Logging
- 8.5: Exercise: Write Tests for Your App

**Part 9: Production Readiness**
- 9.1: Query Optimization
- 9.2: Caching
- 9.3: Security Hardening
- 9.4: Environment Variables
- 9.5: Exercise: Optimize Your Queries

**Part 10: Deployment**
- 10.1: Docker
- 10.2: Gunicorn
- 10.3: Nginx
- 10.4: Docker Compose
- 10.5: Exercise: Deploy Your Application

**Appendices**
- A. Command Reference
- B. Common Errors
- C. Code Snippets
- D. Project Checklist

---

# Part 0: Introduction

## 0.1: Welcome to Django

### What is Django?

Django is a **high-level Python web framework** that encourages rapid development and clean, pragmatic design.

**Key Characteristics:**
- "Batteries included" — comes with many built-in features
- **Secure** — protects against common vulnerabilities
- **Scalable** — used by large sites like Instagram and Pinterest
- **Fast** — helps you build applications quickly

### The "Simple Stack" Philosophy

This course builds a **traditional server-rendered monolith**:

```
Python 3.14 + Django 6
        ↓
Django Templates (HTML/CSS/JS)
        ↓
PostgreSQL (Production) / SQLite (Development)
        ↓
Docker + Gunicorn + Nginx (Production)
```

**Why this approach?**
- Simplicity: One framework, not ten
- Correctness: Django's built-in security
- Performance: Server-rendered pages are SEO-friendly
- Real-world value: Many companies still use this architecture

### My Notes:

```
Write down what you hope to learn from this course:

1. _________________________________________________

2. _________________________________________________

3. _________________________________________________
```

---

## 0.2: Setting Up Your Learning Environment

### System Requirements

- **Operating System**: Windows 10/11, macOS 10.15+, or Linux (Ubuntu 20.04+)
- **Python**: 3.14 or later
- **Code Editor**: VS Code (recommended) or PyCharm
- **Disk Space**: ~2GB
- **RAM**: 8GB recommended

### Installation Checklist

Check off each item as you complete it:

- [ ] **Python 3.14+** installed 
- [ ] **Virtual environment** created (`uv venv` or `python -m venv .venv`)
- [ ] **Virtual environment** activated (`source .venv/bin/activate` or `.venv\Scripts\activate`)
- [ ] **Django 6** installed (`uv pip install django==6.0`)
- [ ] **VS Code** installed with Python extension
- [ ] **Git** installed (optional but recommended)
- [ ] **Docker Desktop** installed (for Part 10)

### Verification Commands

Run these commands to verify your setup:

```bash
# Check Python version
python --version
# Expected: Python 3.14.x or higher

# Check Django version
python -m django --version
# Expected: 6.0

# Check if virtual environment is active
echo $VIRTUAL_ENV  # macOS/Linux
echo %VIRTUAL_ENV%  # Windows
# Should show your project path
```

### My Environment Setup:

```
Python version: ___________________________________

Django version: ___________________________________

Code Editor: ___________________________________

Virtual environment path: ___________________________________
```

---

# Part 1: Django Fundamentals

## 1.1: Your First Django Project

### Key Vocabulary

| Term | Definition |
|------|------------|
| **Django Project** | The entire web application (settings, configurations, URLs) |
| **Django App** | A specific feature within a project (e.g., blog, accounts) |
| **manage.py** | Django's command-line utility |
| **settings.py** | All configuration for your project |
| **urls.py** | URL routing for your project |

### Creating a Project

```bash
# Create project directory
mkdir django_blog_project
cd django_blog_project

# Create virtual environment
uv venv  # or python -m venv .venv

# Activate
source .venv/bin/activate  # macOS/Linux
.venv\Scripts\activate     # Windows

# Install Django
uv pip install django==6.0

# Create Django project
django-admin startproject config .

# Create Django app
python manage.py startapp blog
```

### Project Structure Diagram

```
django_blog_project/
├── manage.py              ← Command center
├── requirements.txt       ← Dependencies
├── config/
│   ├── __init__.py
│   ├── settings.py        ← ALL settings
│   ├── urls.py            ← URL routing
│   └── wsgi.py            ← Production entry
├── blog/
│   ├── __init__.py
│   ├── admin.py           ← Admin config
│   ├── apps.py            ← App config
│   ├── models.py          ← Database models
│   ├── tests.py           ← Tests
│   ├── urls.py            ← App URLs
│   └── views.py           ← Views
└── templates/
```

### My Notes:

```
What is the difference between a project and an app?

_________________________________________________

_________________________________________________

Why do we use virtual environments?

_________________________________________________

_________________________________________________
```

---

## 1.2: Understanding MVT

### The Request-Response Cycle

Fill in the steps:

```
1. User visits URL (e.g., /blog/)
   ↓
2. Django's __________ finds the view for the URL
   ↓
3. The __________ executes business logic
   ↓
4. If needed, the view queries the __________
   ↓
5. The view renders a __________ with data
   ↓
6. Django sends HTML back to the __________
   ↓
7. Browser displays the rendered page
```

### MVT vs MVC

| Django (MVT) | Traditional (MVC) | Responsibility |
|--------------|-------------------|----------------|
| **M**odel | **M**odel | Data & business logic |
| **V**iew | **C**ontroller | Request handling & logic |
| **T**emplate | **V**iew | Presentation (HTML) |

**Analogy:** Restaurant

- **URLs** = Menu board
- **View** = Chef
- **Model** = Kitchen inventory
- **Template** = Plate presentation

### My Notes:

```
Explain MVT in your own words:

_________________________________________________

_________________________________________________

_________________________________________________
```

---

## 1.3: Views and URLs

### Creating Your First View

**File: `blog/views.py`**

```python
from django.shortcuts import render
from django.http import HttpResponse

def home(request):
    """Homepage view."""
    context = {
        'page_title': 'Welcome to My Django Blog',
        'welcome_message': 'This is the beginning of your Django journey!',
    }
    return render(request, 'blog/home.html', context)
```

### URL Routing

**File: `blog/urls.py`**

```python
from django.urls import path
from . import views

app_name = 'blog'

urlpatterns = [
    path('', views.home, name='home'),
    path('about/', views.about, name='about'),
    path('blog/', views.blog_list, name='blog_list'),
]
```

**File: `config/urls.py`**

```python
from django.urls import path, include

urlpatterns = [
    path('admin/', admin.site.urls),
    path('', include('blog.urls')),
]
```

### URL Patterns Reference

| Pattern | Example URL | Purpose |
|---------|-------------|---------|
| `path('')` | `/` | Root/home page |
| `path('about/')` | `/about/` | About page |
| `path('blog/')` | `/blog/` | Blog list |
| `path('blog/<slug:slug>/')` | `/blog/my-post/` | Single post |
| `path('post/create/')` | `/post/create/` | Create form |

### My Notes:

```
What is the purpose of `app_name`?

_________________________________________________

_________________________________________________

How do you create a URL that accepts a parameter?

_________________________________________________

_________________________________________________
```

---

## 1.4: Templates

### Template Inheritance

**Base Template (`base.html`)**

```html
<!DOCTYPE html>
<html>
<head>
    <title>{% block title %}Django Blog{% endblock %}</title>
</head>
<body>
    <header>{% block header %}Default Header{% endblock %}</header>
    <main>{% block content %}{% endblock %}</main>
    <footer>{% block footer %}Default Footer{% endblock %}</footer>
</body>
</html>
```

**Child Template (`home.html`)**

```html
{% extends 'blog/base.html' %}

{% block title %}
    {{ page_title }} — Django Blog
{% endblock %}

{% block content %}
    <h1>{{ welcome_message }}</h1>
    <p>This is the homepage.</p>
{% endblock %}
```

### Template Tags and Filters

| Tag/Filter | Example | Purpose |
|------------|---------|---------|
| `{{ variable }}` | `{{ user.username }}` | Display variable |
| `{% if %}` | `{% if user.is_authenticated %}` | Conditional |
| `{% for %}` | `{% for post in posts %}` | Loop |
| `{% url %}` | `{% url 'blog:home' %}` | Generate URL |
| `{% include %}` | `{% include 'header.html' %}` | Include template |
| `|truncatewords` | `{{ text|truncatewords:30 }}` | Limit words |
| `|date` | `{{ date|date:"F j, Y" }}` | Format date |
| `|default` | `{{ value|default:"N/A" }}` | Default value |

### My Notes:

```
What is the difference between `{% include %}` and `{% extends %}`?

_________________________________________________

_________________________________________________

How do you pass data from a view to a template?

_________________________________________________

_________________________________________________
```

---

## 1.5: Exercise — Build a Contact Page

### Instructions

Create a "Contact" page for your blog with:

1. A view called `contact`
2. A URL pattern `/contact/`
3. A template `contact.html` that extends the base template
4. A link in the navigation

### Steps

**Step 1: Create the View**

In `blog/views.py`:

```python
def contact(request):
    """Contact page view."""
    context = {
        'page_title': 'Contact Us',
        'email': 'contact@example.com',
        'phone': '555-1234',
        'address': '123 Django Street, Python City'
    }
    return render(request, 'blog/contact.html', context)
```

**Step 2: Add the URL**

In `blog/urls.py`:

```python
urlpatterns = [
    # ... existing patterns ...
    path('contact/', views.contact, name='contact'),
]
```

**Step 3: Create the Template**

Create `blog/templates/blog/contact.html`:

```html
{% extends 'blog/base.html' %}

{% block title %}
    {{ page_title }} — Django Blog
{% endblock %}

{% block content %}
    <h1>{{ page_title }}</h1>
    <p>Email: {{ email }}</p>
    <p>Phone: {{ phone }}</p>
    <p>Address: {{ address }}</p>
{% endblock %}
```

**Step 4: Update Navigation**

In `blog/templates/blog/base.html`:

```html
<nav>
    <a href="{% url 'blog:home' %}">Home</a>
    <a href="{% url 'blog:blog_list' %}">Blog</a>
    <a href="{% url 'blog:about' %}">About</a>
    <a href="{% url 'blog:contact' %}">Contact</a>
</nav>
```

### Self-Check

- [ ] Does the `/contact/` URL work?
- [ ] Does the navigation link appear?
- [ ] Does the page extend the base template?
- [ ] Are the email, phone, and address displayed?

---

# Part 2: Models and Databases

## 2.1: Designing Database Models

### Model Relationships

Fill in the blanks:

```
┌─────────────┐         ┌─────────────┐
│   Category  │         │    Post     │
│             │         │             │
│ id          │◄────────│ category_id │  ← __________ to __________
│ name        │   Many  │ title       │
│ slug        │   To    │ slug        │
└─────────────┘   One   │ content     │
                        │ status      │
          ┌─────────────│ author_id   │
          │             │ created_at  │
          │             └─────────────┘
          │
          │
          ▼
┌─────────────┐
│   Comment   │
│             │
│ id          │
│ post_id     │  ← __________ to __________
│ author_id   │
│ content     │
└─────────────┘
```

### Model Field Types

| Field | Python Type | Use Case |
|-------|-------------|----------|
| `CharField` | `str` | Short text (titles, names) |
| `TextField` | `str` | Long text (blog content) |
| `IntegerField` | `int` | Whole numbers |
| `DecimalField` | `Decimal` | Prices, financial values |
| `BooleanField` | `bool` | True/False flags |
| `DateField` | `date` | Calendar dates |
| `DateTimeField` | `datetime` | Dates with times |
| `EmailField` | `str` | Email addresses |
| `SlugField` | `str` | URL-friendly strings |
| `ImageField` | `str` | Image file paths |
| `ForeignKey` | Model instance | Many-to-one relationship |
| `ManyToManyField` | QuerySet | Many-to-many relationship |

### My Notes:

```
What is the difference between `blank=True` and `null=True`?

_________________________________________________

_________________________________________________

What does `on_delete=models.CASCADE` do?

_________________________________________________

_________________________________________________
```

---

## 2.2: Migrations

### The Migration Workflow

Fill in the steps:

```
1. Make changes to models.py
   ↓
2. Create migration files: ____________________
   ↓
3. Apply migrations: ____________________
   ↓
4. Verify changes: ____________________
```

### Migration Commands

| Command | Purpose |
|---------|---------|
| `python manage.py makemigrations` | Create migration files |
| `python manage.py makemigrations blog` | Create migrations for a specific app |
| `python manage.py migrate` | Apply all migrations |
| `python manage.py migrate blog` | Apply migrations for a specific app |
| `python manage.py showmigrations` | Show migration status |
| `python manage.py sqlmigrate blog 0001` | Show SQL for a migration |

### Check Your Understanding

**True or False:**

- [ ] Migrations are automatically applied when you save models.py
- [ ] Each migration file is like a "version" of your database schema
- [ ] You can roll back migrations
- [ ] SQLite and PostgreSQL use the same migration files

### My Notes:

```
What should you do if a migration fails?

_________________________________________________

_________________________________________________

How can you see what SQL a migration will run?

_________________________________________________

_________________________________________________
```

---

## 2.3: Django Admin

### Registering Models

**File: `blog/admin.py`**

```python
from django.contrib import admin
from .models import Post, Category, Comment

@admin.register(Post)
class PostAdmin(admin.ModelAdmin):
    list_display = ['title', 'author', 'status', 'created_at']
    list_filter = ['status', 'category']
    search_fields = ['title', 'content']
    prepopulated_fields = {'slug': ('title',)}
    list_editable = ['status']
    ordering = ['-created_at']
```

### Admin Customization Reference

| Option | Purpose |
|--------|---------|
| `list_display` | Columns shown in list view |
| `list_filter` | Filters in sidebar |
| `search_fields` | Searchable fields |
| `prepopulated_fields` | Auto-populate fields |
| `list_editable` | Editable in list view |
| `ordering` | Default sort order |
| `fieldsets` | Group fields in form |
| `readonly_fields` | Read-only fields |
| `actions` | Custom bulk actions |

### My Notes:

```
How do you create a superuser?

_________________________________________________

_________________________________________________

What is the purpose of `prepopulated_fields`?

_________________________________________________

_________________________________________________
```

---

## 2.4: Django ORM

### CRUD Operations

Fill in the ORM equivalents:

| Operation | SQL | Django ORM |
|-----------|-----|------------|
| Create | `INSERT INTO posts (title) VALUES ('Hello')` | `Post.objects.__________(title='Hello')` |
| Read All | `SELECT * FROM posts` | `Post.objects._____()` |
| Filter | `SELECT * FROM posts WHERE status='published'` | `Post.objects.___________(status='published')` |
| Update | `UPDATE posts SET title='New' WHERE id=1` | `post._______()` or `.update()` |
| Delete | `DELETE FROM posts WHERE id=1` | `post._______()` |

### ORM Query Reference

```python
# Get all objects
all_posts = Post.objects.all()

# Filter
published = Post.objects.filter(status='published')

# Get single object
post = Post.objects.get(id=1)

# First/Last
first = Post.objects.first()
last = Post.objects.last()

# Count
count = Post.objects.count()

# Exists
has_posts = Post.objects.filter(status='published').exists()

# Order by
posts = Post.objects.order_by('-created_at')  # Newest first

# Limit
posts = Post.objects.all()[:5]  # First 5

# Values
titles = Post.objects.values_list('title', flat=True)

# Aggregation
from django.db.models import Count, Sum, Avg
stats = Post.objects.aggregate(
    total=Count('id'),
    avg_views=Avg('view_count')
)
```

### My Notes:

```
What is the difference between `get()` and `filter()`?

_________________________________________________

_________________________________________________

How do you filter with OR conditions?

_________________________________________________

_________________________________________________
```

---

## 2.5: Exercise — Add a Comment Model

### Instructions

Add a Comment model to the blog. Each comment should have:

- A foreign key to Post
- A foreign key to User (author)
- Content (TextField)
- Created timestamp (auto_now_add)
- An `is_approved` boolean field (default=False)

### Steps

**Step 1: Update models.py**

Add to `blog/models.py`:

```python
class Comment(models.Model):
    """Comment model for user discussions."""
    post = models.ForeignKey(Post, on_delete=models.CASCADE, related_name='comments')
    author = models.ForeignKey(User, on_delete=models.CASCADE, related_name='comments')
    content = models.TextField()
    is_approved = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Comment by {self.author.username} on {self.post.title}"
```

**Step 2: Create Migration**

```bash
python manage.py makemigrations blog
python manage.py migrate blog
```

**Step 3: Register in Admin**

In `blog/admin.py`:

```python
@admin.register(Comment)
class CommentAdmin(admin.ModelAdmin):
    list_display = ['author', 'post', 'is_approved', 'created_at']
    list_filter = ['is_approved', 'created_at']
    search_fields = ['author__username', 'content']
    list_editable = ['is_approved']
```

### Self-Check

- [ ] Does the Comment model exist in the database?
- [ ] Can you add comments via Admin?
- [ ] Can you approve comments via Admin?
- [ ] Does the `is_approved` filter work?

---

# Part 3: Forms and CRUD

## 3.1: Django Forms

### ModelForm vs Form

| Feature | Form | ModelForm |
|---------|------|-----------|
| Fields defined in code | ✅ | ❌ (auto-generated) |
| Requires manual definition | ✅ | ❌ |
| Integrates with model | ❌ | ✅ |
| Validation | Manual | Auto from model |
| Save method | Manual | ✅ |

### Creating a ModelForm

**File: `blog/forms.py`**

```python
from django import forms
from .models import Post

class PostForm(forms.ModelForm):
    class Meta:
        model = Post
        fields = ['title', 'slug', 'category', 'content', 'status']
        widgets = {
            'title': forms.TextInput(attrs={'class': 'form-control'}),
            'content': forms.Textarea(attrs={'class': 'form-control', 'rows': 10}),
        }
    
    def clean_slug(self):
        """Validate that slug is unique."""
        slug = self.cleaned_data.get('slug')
        if Post.objects.filter(slug=slug).exists():
            raise forms.ValidationError('This slug already exists.')
        return slug
```

### My Notes:

```
What is the purpose of the `clean_` method in forms?

_________________________________________________

_________________________________________________

How do you customize form widgets?

_________________________________________________

_________________________________________________
```

---

## 3.2: Creating Posts

### The Create View Pattern

```python
@login_required
def post_create(request):
    if request.method == 'POST':
        form = PostForm(request.POST, request.FILES)
        if form.is_valid():
            post = form.save(commit=False)
            post.author = request.user
            post.save()
            messages.success(request, 'Post created!')
            return redirect('blog:post_detail', slug=post.slug)
    else:
        form = PostForm()
    
    return render(request, 'blog/post_form.html', {
        'form': form,
        'title': 'Create New Post'
    })
```

### Template Pattern

```html
<form method="post" enctype="multipart/form-data">
    {% csrf_token %}
    
    {% if form.errors %}
        <div class="form-errors">
            <strong>Please correct the errors below:</strong>
            {{ form.errors }}
        </div>
    {% endif %}
    
    {% for field in form %}
        <div class="form-group">
            <label for="{{ field.id_for_label }}">
                {{ field.label }}
                {% if field.field.required %}<span class="required">*</span>{% endif %}
            </label>
            {{ field }}
            {% if field.help_text %}
                <small class="help-text">{{ field.help_text }}</small>
            {% endif %}
            {{ field.errors }}
        </div>
    {% endfor %}
    
    <button type="submit">Create Post</button>
</form>
```

### My Notes:

```
Why do we need `{% csrf_token %}` in forms?

_________________________________________________

_________________________________________________

What does `commit=False` do?

_________________________________________________

_________________________________________________
```

---

## 3.3: Editing and Deleting Posts

### The Edit View Pattern

```python
@login_required
def post_edit(request, slug):
    post = get_object_or_404(Post, slug=slug)
    
    if post.author != request.user:
        messages.error(request, 'You cannot edit this post.')
        return redirect('blog:post_detail', slug=post.slug)
    
    if request.method == 'POST':
        form = PostForm(request.POST, request.FILES, instance=post)
        if form.is_valid():
            form.save()
            messages.success(request, 'Post updated!')
            return redirect('blog:post_detail', slug=post.slug)
    else:
        form = PostForm(instance=post)
    
    return render(request, 'blog/post_form.html', {
        'form': form,
        'title': 'Edit Post',
        'post': post
    })
```

### The Delete Pattern

```python
@login_required
def post_delete(request, slug):
    post = get_object_or_404(Post, slug=slug)
    
    if post.author != request.user:
        messages.error(request, 'You cannot delete this post.')
        return redirect('blog:post_detail', slug=post.slug)
    
    if request.method == 'POST':
        post.delete()
        messages.success(request, 'Post deleted!')
        return redirect('blog:blog_list')
    
    return render(request, 'blog/post_confirm_delete.html', {'post': post})
```

### My Notes:

```
How do you restrict editing to the post's author?

_________________________________________________

_________________________________________________

What is the purpose of the confirmation page for deletion?

_________________________________________________

_________________________________________________
```

---

## 3.4: Exercise — Add Post Scheduling

### Instructions

Add a `scheduled_publish_at` field to the Post model that allows authors to schedule posts for future publication.

### Steps

**Step 1: Update models.py**

```python
class Post(models.Model):
    # ... existing fields ...
    scheduled_publish_at = models.DateTimeField(
        blank=True,
        null=True,
        help_text="If set, the post will be published at this date and time."
    )
```

**Step 2: Create Migration**

```bash
python manage.py makemigrations blog
python manage.py migrate blog
```

**Step 3: Update forms.py**

```python
class PostForm(forms.ModelForm):
    class Meta:
        model = Post
        fields = ['title', 'slug', 'category', 'content', 
                  'status', 'scheduled_publish_at']
        widgets = {
            'scheduled_publish_at': forms.DateTimeInput(
                attrs={'type': 'datetime-local', 'class': 'form-control'}
            ),
        }
```

**Step 4: Update model save method**

```python
def save(self, *args, **kwargs):
    if not self.slug:
        self.slug = slugify(self.title)
    
    # If scheduled, mark as draft
    if self.scheduled_publish_at and self.status == self.Status.PUBLISHED:
        self.status = self.Status.DRAFT
    
    super().save(*args, **kwargs)
```

**Step 5: Create Management Command**

Create `blog/management/commands/publish_scheduled_posts.py`:

```python
from django.core.management.base import BaseCommand
from django.utils import timezone
from blog.models import Post

class Command(BaseCommand):
    help = 'Publish scheduled posts'

    def handle(self, *args, **options):
        now = timezone.now()
        posts = Post.objects.filter(
            status=Post.Status.DRAFT,
            scheduled_publish_at__lte=now
        )
        
        for post in posts:
            post.status = Post.Status.PUBLISHED
            post.published_at = now
            post.save()
            self.stdout.write(f'Published: {post.title}')
```

### Self-Check

- [ ] Does the scheduled publish field appear in the form?
- [ ] Does a draft post with a scheduled date become published when the command runs?
- [ ] Does the command work: `python manage.py publish_scheduled_posts`?

---

# Part 4: Class-Based Views

## 4.1: Understanding CBVs

### FBV vs CBV Comparison

| Feature | Function-Based View | Class-Based View |
|---------|--------------------|------------------|
| **Syntax** | Simple functions | Classes with methods |
| **Flexibility** | Very flexible | Structured |
| **Reusability** | Limited | High (inheritance) |
| **Built-in Features** | Minimal | Many |
| **Best For** | Simple views | Complex, repetitive views |

### Common CBV Types

| CBV | Purpose | When to Use |
|-----|---------|-------------|
| `View` | Basic class-based view | Custom logic |
| `TemplateView` | Render a template | Static pages |
| `ListView` | Display a list of objects | Blog list, product list |
| `DetailView` | Display a single object | Post detail, product detail |
| `CreateView` | Create a new object | Form to create |
| `UpdateView` | Edit an existing object | Form to edit |
| `DeleteView` | Delete an object | Confirmation page |

### My Notes:

```
Why would you choose a CBV over an FBV?

_________________________________________________

_________________________________________________

What is the purpose of `as_view()`?

_________________________________________________

_________________________________________________
```

---

## 4.2: ListView and DetailView

### ListView Pattern

```python
from django.views.generic import ListView
from blog.models import Post

class PostListView(ListView):
    model = Post
    template_name = 'blog/blog_list.html'
    context_object_name = 'posts'
    paginate_by = 10
    ordering = ['-created_at']
    
    def get_queryset(self):
        queryset = super().get_queryset()
        # Custom filtering
        return queryset.filter(status='published')
```

### DetailView Pattern

```python
from django.views.generic import DetailView
from blog.models import Post

class PostDetailView(DetailView):
    model = Post
    template_name = 'blog/post_detail.html'
    context_object_name = 'post'
    slug_field = 'slug'
    slug_url_kwarg = 'slug'
    
    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        context['recent_posts'] = Post.objects.filter(status='published')[:5]
        return context
```

### URL Configuration

```python
from django.urls import path
from .views import PostListView, PostDetailView

urlpatterns = [
    path('', PostListView.as_view(), name='blog_list'),
    path('<slug:slug>/', PostDetailView.as_view(), name='post_detail'),
]
```

### My Notes:

```
What does `context_object_name` do?

_________________________________________________

_________________________________________________

How do you add extra context to a DetailView?

_________________________________________________

_________________________________________________
```

---

## 4.3: CreateView, UpdateView, DeleteView

### CreateView Pattern

```python
from django.views.generic import CreateView
from django.contrib.auth.mixins import LoginRequiredMixin
from blog.models import Post
from blog.forms import PostForm

class PostCreateView(LoginRequiredMixin, CreateView):
    model = Post
    form_class = PostForm
    template_name = 'blog/post_form.html'
    success_url = reverse_lazy('blog:blog_list')
    
    def form_valid(self, form):
        form.instance.author = self.request.user
        return super().form_valid(form)
```

### UpdateView Pattern

```python
from django.views.generic import UpdateView
from django.contrib.auth.mixins import LoginRequiredMixin, UserPassesTestMixin

class PostUpdateView(LoginRequiredMixin, UserPassesTestMixin, UpdateView):
    model = Post
    form_class = PostForm
    template_name = 'blog/post_form.html'
    
    def test_func(self):
        post = self.get_object()
        return self.request.user == post.author
    
    def get_success_url(self):
        return reverse_lazy('blog:post_detail', kwargs={'slug': self.object.slug})
```

### DeleteView Pattern

```python
from django.views.generic import DeleteView
from django.contrib.auth.mixins import LoginRequiredMixin, UserPassesTestMixin

class PostDeleteView(LoginRequiredMixin, UserPassesTestMixin, DeleteView):
    model = Post
    template_name = 'blog/post_confirm_delete.html'
    success_url = reverse_lazy('blog:blog_list')
    
    def test_func(self):
        post = self.get_object()
        return self.request.user == post.author
```

### My Notes:

```
What is the purpose of `LoginRequiredMixin`?

_________________________________________________

_________________________________________________

How does `UserPassesTestMixin` work?

_________________________________________________

_________________________________________________
```

---

## 4.4: Search and Filtering

### Implementing Search

```python
from django.db.models import Q

class PostListView(ListView):
    model = Post
    template_name = 'blog/blog_list.html'
    context_object_name = 'posts'
    paginate_by = 10
    
    def get_queryset(self):
        queryset = super().get_queryset().filter(status='published')
        search_query = self.request.GET.get('q')
        
        if search_query:
            queryset = queryset.filter(
                Q(title__icontains=search_query) |
                Q(content__icontains=search_query) |
                Q(author__username__icontains=search_query)
            )
        
        return queryset
```

### Filtering by Category

```python
def get_queryset(self):
    queryset = super().get_queryset().filter(status='published')
    
    category_slug = self.request.GET.get('category')
    if category_slug:
        queryset = queryset.filter(category__slug=category_slug)
    
    return queryset
```

### Template for Search

```html
<form method="get" class="search-form">
    <input type="text" name="q" placeholder="Search posts..." value="{{ request.GET.q }}">
    <select name="category">
        <option value="">All Categories</option>
        {% for category in categories %}
            <option value="{{ category.slug }}" {% if request.GET.category == category.slug %}selected{% endif %}>
                {{ category.name }}
            </option>
        {% endfor %}
    </select>
    <button type="submit">Search</button>
</form>
```

### My Notes:

```
What is the purpose of `Q` objects?

_________________________________________________

_________________________________________________

How do you preserve filter parameters when paginating?

_________________________________________________

_________________________________________________
```

---

## 4.5: Exercise — Add Category Filtering

### Instructions

Add category filtering to the blog list page using a dropdown menu in the template.

### Steps

**Step 1: Update ListView**

```python
class PostListView(ListView):
    # ... existing code ...
    
    def get_queryset(self):
        queryset = super().get_queryset().filter(status='published')
        
        category_slug = self.request.GET.get('category')
        if category_slug:
            queryset = queryset.filter(category__slug=category_slug)
        
        return queryset
    
    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        context['categories'] = Category.objects.filter(posts__isnull=False).distinct()
        context['selected_category'] = self.request.GET.get('category', '')
        return context
```

**Step 2: Update Template**

```html
<form method="get" class="filter-form">
    <select name="category">
        <option value="">All Categories</option>
        {% for category in categories %}
            <option value="{{ category.slug }}" 
                    {% if selected_category == category.slug %}selected{% endif %}>
                {{ category.name }}
            </option>
        {% endfor %}
    </select>
    <button type="submit">Filter</button>
</form>
```

**Step 3: Test**

- Visit `/blog/`
- Select a category from the dropdown
- Click "Filter"
- Verify only posts in that category are shown

### Self-Check

- [ ] Does the category dropdown appear?
- [ ] Does filtering by category work?
- [ ] Are the filter parameters preserved when paginating?
- [ ] Does selecting "All Categories" show all posts?

---

# Part 5: Authentication and Users

## 5.1: User Registration

### Registration View

```python
from django.contrib.auth.forms import UserCreationForm
from django.contrib.auth import login

def register(request):
    if request.method == 'POST':
        form = UserCreationForm(request.POST)
        if form.is_valid():
            user = form.save()
            login(request, user)
            messages.success(request, 'Registration successful!')
            return redirect('blog:home')
    else:
        form = UserCreationForm()
    
    return render(request, 'registration/register.html', {'form': form})
```

### Registration Template

```html
{% extends 'blog/base.html' %}

{% block content %}
    <h1>Register</h1>
    <form method="post">
        {% csrf_token %}
        {{ form.as_p }}
        <button type="submit">Register</button>
    </form>
    <p>Already have an account? <a href="{% url 'login' %}">Login</a></p>
{% endblock %}
```

### My Notes:

```
What does `UserCreationForm` provide?

_________________________________________________

_________________________________________________

Why do we auto-login after registration?

_________________________________________________

_________________________________________________
```

---

## 5.2: Login and Logout

### Login View

Django provides built-in login views:

```python
from django.contrib.auth import views as auth_views

urlpatterns = [
    path('login/', auth_views.LoginView.as_view(), name='login'),
    path('logout/', auth_views.LogoutView.as_view(), name='logout'),
    # ... other URLs
]
```

### Login Template

Create `registration/login.html`:

```html
{% extends 'blog/base.html' %}

{% block content %}
    <h1>Login</h1>
    <form method="post">
        {% csrf_token %}
        {{ form.as_p }}
        <button type="submit">Login</button>
    </form>
    <p>Don't have an account? <a href="{% url 'register' %}">Register</a></p>
{% endblock %}
```

### Settings

```python
# config/settings.py
LOGIN_URL = 'login'
LOGIN_REDIRECT_URL = 'blog:home'
LOGOUT_REDIRECT_URL = 'blog:home'
```

### Protecting Views

```python
from django.contrib.auth.decorators import login_required

@login_required
def post_create(request):
    # Only authenticated users can access
    pass
```

### My Notes:

```
What is the purpose of `LOGIN_URL`?

_________________________________________________

_________________________________________________

What does `@login_required` do?

_________________________________________________

_________________________________________________
```

---

## 5.3: User Profiles

### The Profile Model

```python
from django.contrib.auth.models import User

class Profile(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    bio = models.TextField(max_length=500, blank=True)
    location = models.CharField(max_length=100, blank=True)
    avatar = models.ImageField(upload_to='avatars/', blank=True)
    website = models.URLField(blank=True)
    
    def __str__(self):
        return f"{self.user.username}'s Profile"
```

### Auto-Create Profile with Signals

```python
from django.db.models.signals import post_save
from django.dispatch import receiver

@receiver(post_save, sender=User)
def create_user_profile(sender, instance, created, **kwargs):
    if created:
        Profile.objects.create(user=instance)

@receiver(post_save, sender=User)
def save_user_profile(sender, instance, **kwargs):
    instance.profile.save()
```

### Profile View

```python
from django.views.generic import DetailView
from django.contrib.auth.models import User

class ProfileDetailView(DetailView):
    model = User
    template_name = 'blog/profile_detail.html'
    context_object_name = 'profile_user'
    slug_field = 'username'
    slug_url_kwarg = 'username'
```

### My Notes:

```
Why do we use a OneToOneField for profiles?

_________________________________________________

_________________________________________________

What are Django signals and why are they useful here?

_________________________________________________

_________________________________________________
```

---

## 5.4: Password Reset

### Built-in Password Reset Views

```python
urlpatterns = [
    path('password-reset/', 
         auth_views.PasswordResetView.as_view(
             template_name='registration/password_reset_form.html',
             email_template_name='registration/password_reset_email.html',
         ), 
         name='password_reset'),
    path('password-reset/done/', 
         auth_views.PasswordResetDoneView.as_view(
             template_name='registration/password_reset_done.html'
         ), 
         name='password_reset_done'),
    path('password-reset/<uidb64>/<token>/', 
         auth_views.PasswordResetConfirmView.as_view(
             template_name='registration/password_reset_confirm.html'
         ), 
         name='password_reset_confirm'),
    path('password-reset/complete/', 
         auth_views.PasswordResetCompleteView.as_view(
             template_name='registration/password_reset_complete.html'
         ), 
         name='password_reset_complete'),
]
```

### Email Configuration

```python
# config/settings.py

# For development (print to console)
EMAIL_BACKEND = 'django.core.mail.backends.console.EmailBackend'

# For production (SMTP)
EMAIL_BACKEND = 'django.core.mail.backends.smtp.EmailBackend'
EMAIL_HOST = 'smtp.gmail.com'
EMAIL_PORT = 587
EMAIL_USE_TLS = True
EMAIL_HOST_USER = 'your-email@gmail.com'
EMAIL_HOST_PASSWORD = 'your-app-password'
DEFAULT_FROM_EMAIL = 'noreply@yourapp.com'
```

### My Notes:

```
What happens during the password reset flow?

_________________________________________________

_________________________________________________

How do you test email functionality in development?

_________________________________________________

_________________________________________________
```

---

## 5.5: Exercise — Add a User Dashboard

### Instructions

Create a dashboard that shows authenticated users:
- Statistics (total posts, published, drafts)
- Recent posts
- Quick action buttons (new post, edit profile)

### Steps

**Step 1: Create Dashboard View**

```python
from django.contrib.auth.decorators import login_required

@login_required
def dashboard(request):
    user = request.user
    posts = Post.objects.filter(author=user)
    
    context = {
        'total_posts': posts.count(),
        'published_posts': posts.filter(status='published').count(),
        'draft_posts': posts.filter(status='draft').count(),
        'recent_posts': posts.order_by('-created_at')[:5],
    }
    return render(request, 'blog/dashboard.html', context)
```

**Step 2: Create Template**

```html
{% extends 'blog/base.html' %}

{% block content %}
    <h1>Dashboard</h1>
    
    <div class="stats">
        <div class="stat">
            <h3>Total Posts</h3>
            <p>{{ total_posts }}</p>
        </div>
        <div class="stat">
            <h3>Published</h3>
            <p>{{ published_posts }}</p>
        </div>
        <div class="stat">
            <h3>Drafts</h3>
            <p>{{ draft_posts }}</p>
        </div>
    </div>
    
    <h2>Recent Posts</h2>
    <ul>
        {% for post in recent_posts %}
            <li>
                <a href="{{ post.get_absolute_url }}">{{ post.title }}</a>
                <span class="status">{{ post.get_status_display }}</span>
            </li>
        {% empty %}
            <li>No posts yet. <a href="{% url 'blog:post_create' %}">Create one!</a></li>
        {% endfor %}
    </ul>
{% endblock %}
```

**Step 3: Add URL**

```python
path('dashboard/', views.dashboard, name='dashboard'),
```

**Step 4: Add Navigation Link**

```html
{% if user.is_authenticated %}
    <a href="{% url 'blog:dashboard' %}">Dashboard</a>
{% endif %}
```

### Self-Check

- [ ] Does the dashboard only show for authenticated users?
- [ ] Are the statistics correct?
- [ ] Do recent posts appear correctly?
- [ ] Does the "Create One" link work?

---

# Part 6: Advanced Architecture

## 6.1: Middleware

### What is Middleware?

Middleware is code that runs on **every request** and **every response**. It's like a "filter" that can modify requests/responses.

```
Request → Middleware → View → Middleware → Response
```

### Creating Custom Middleware

**File: `blog/middleware.py`**

```python
import time
import logging

logger = logging.getLogger(__name__)

class RequestLoggingMiddleware:
    """Logs request timing and details."""
    
    def __init__(self, get_response):
        self.get_response = get_response
    
    def __call__(self, request):
        # Request phase
        start_time = time.time()
        
        # Process the request
        response = self.get_response(request)
        
        # Response phase
        duration = time.time() - start_time
        logger.info(f"{request.method} {request.path} - {duration:.3f}s")
        
        return response
```

### Registering Middleware

```python
# config/settings.py
MIDDLEWARE = [
    # ... built-in middleware ...
    'blog.middleware.RequestLoggingMiddleware',
]
```

### My Notes:

```
What are some use cases for custom middleware?

_________________________________________________

_________________________________________________

How does middleware differ from a context processor?

_________________________________________________

_________________________________________________
```

---

## 6.2: Context Processors

### What is a Context Processor?

A context processor adds variables to **every template's context**. It runs automatically for every request.

### Creating a Context Processor

**File: `blog/context_processors.py`**

```python
from datetime import datetime
from .models import Category

def global_context(request):
    """Adds global variables to all templates."""
    return {
        'current_year': datetime.now().year,
        'site_name': 'Django Blog',
        'categories_nav': Category.objects.all(),
        'user_is_authenticated': request.user.is_authenticated,
    }
```

### Registering the Context Processor

```python
# config/settings.py
TEMPLATES = [
    {
        'OPTIONS': {
            'context_processors': [
                # ... built-in ...
                'blog.context_processors.global_context',
            ],
        },
    },
]
```

### My Notes:

```
What is the difference between a context processor and passing context manually?

_________________________________________________

_________________________________________________

When would you use a context processor vs a template tag?

_________________________________________________

_________________________________________________
```

---

## 6.3: Signals

### What are Signals?

Signals allow different parts of your application to communicate when something happens. They're like a "notification system."

```
Event happens → Signal sent → Receiver(s) process
```

### Common Use Cases

| Signal | Use Case |
|--------|----------|
| `post_save` | Auto-create profile when user registers |
| `post_delete` | Delete files when model is deleted |
| `m2m_changed` | Update counts when many-to-many changes |

### Creating a Signal

**File: `blog/signals.py`**

```python
from django.db.models.signals import post_save
from django.contrib.auth.models import User
from django.dispatch import receiver
from .models import Profile

@receiver(post_save, sender=User)
def create_user_profile(sender, instance, created, **kwargs):
    """Auto-create profile when a user is created."""
    if created:
        Profile.objects.create(user=instance)
```

### Registering Signals

**File: `blog/apps.py`**

```python
from django.apps import AppConfig

class BlogConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'blog'
    
    def ready(self):
        import blog.signals  # noqa
```

### My Notes:

```
Why are signals useful for decoupling code?

_________________________________________________

_________________________________________________

What happens if a signal handler raises an exception?

_________________________________________________

_________________________________________________
```

---

## 6.4: Service Layer

### What is a Service Layer?

A service layer is a pattern where you move business logic out of views and into separate service classes.

```
View → Service → Model
```

### Benefits
- **Separation of concerns**: Views handle HTTP, services handle logic
- **Reusability**: Business logic can be used in multiple places
- **Testability**: Services are easier to test without HTTP
- **Maintainability**: Logic is organized and focused

### Creating a Service

**File: `blog/services/post_service.py`**

```python
from django.core.exceptions import PermissionDenied
from .models import Post

class PostService:
    @staticmethod
    def create_post(data, author):
        """Create a new post with business logic."""
        from .forms import PostForm
        
        form = PostForm(data)
        if not form.is_valid():
            return None, form.errors
        
        post = form.save(commit=False)
        post.author = author
        
        if post.status == Post.Status.PUBLISHED:
            post.published_at = timezone.now()
        
        post.save()
        form.save_m2m()
        return post, None
    
    @staticmethod
    def get_user_posts(user):
        """Get all posts by a user with permission checks."""
        return Post.objects.filter(author=user)
```

### Using the Service

```python
def post_create(request):
    if request.method == 'POST':
        post, errors = PostService.create_post(request.POST, request.user)
        if post:
            return redirect('blog:post_detail', slug=post.slug)
        else:
            messages.error(request, errors)
```

### My Notes:

```
Why separate logic from views?

_________________________________________________

_________________________________________________

What are the trade-offs of using a service layer?

_________________________________________________

_________________________________________________
```

---

## 6.5: Exercise — Create Custom Middleware

### Instructions

Create a maintenance mode middleware that shows a maintenance page when enabled.

### Steps

**Step 1: Create Middleware**

```python
# blog/middleware.py
from django.http import HttpResponse
from django.urls import reverse

class MaintenanceModeMiddleware:
    MAINTENANCE_MODE = False
    ALLOWED_IPS = ['127.0.0.1']
    
    def __init__(self, get_response):
        self.get_response = get_response
    
    def __call__(self, request):
        if self.MAINTENANCE_MODE:
            # Allow staff and whitelisted IPs
            if request.user.is_staff or request.META.get('REMOTE_ADDR') in self.ALLOWED_IPS:
                return self.get_response(request)
            
            # Allow admin and login pages
            if request.path.startswith('/admin/') or request.path == reverse('login'):
                return self.get_response(request)
            
            # Show maintenance page
            return HttpResponse(
                '<h1>Under Maintenance</h1><p>We\'ll be back soon!</p>',
                status=503
            )
        
        return self.get_response(request)
```

**Step 2: Register Middleware**

```python
# config/settings.py
MIDDLEWARE = [
    # ... existing ...
    'blog.middleware.MaintenanceModeMiddleware',
]
```

**Step 3: Test**

- Set `MAINTENANCE_MODE = True`
- Visit the site as a regular user → see maintenance page
- Visit the site as staff/admin → see normal site

### Self-Check

- [ ] Does the maintenance page appear for regular users?
- [ ] Can staff users bypass maintenance mode?
- [ ] Are admin and login pages accessible during maintenance?

---

# Part 7: Real-World Features

## 7.1: File Uploads

### Configuring Media Files

```python
# config/settings.py
MEDIA_URL = '/media/'
MEDIA_ROOT = BASE_DIR / 'media'

# config/urls.py
from django.conf import settings
from django.conf.urls.static import static

urlpatterns = [
    # ... existing URLs
]

if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
```

### Model with ImageField

```python
class Post(models.Model):
    # ... fields ...
    featured_image = models.ImageField(
        upload_to='posts/%Y/%m/%d/',  # Organize by date
        blank=True,
        null=True,
        help_text="Optional image for the post"
    )
```

### Handling File Uploads in Forms

```html
<form method="post" enctype="multipart/form-data">
    {% csrf_token %}
    {{ form.as_p }}
    <button type="submit">Upload</button>
</form>
```

### My Notes:

```
Why use `enctype="multipart/form-data"`?

_________________________________________________

_________________________________________________

How do you validate file uploads (size, type)?

_________________________________________________

_________________________________________________
```

---

## 7.2: Email Notifications

### Sending Email

```python
from django.core.mail import send_mail

def send_notification(user, subject, message):
    send_mail(
        subject,
        message,
        settings.DEFAULT_FROM_EMAIL,
        [user.email],
        fail_silently=True,
    )
```

### HTML Email with Template

```python
from django.template.loader import render_to_string
from django.core.mail import EmailMultiAlternatives

def send_html_email(user, subject, template, context):
    html_content = render_to_string(template, context)
    text_content = strip_tags(html_content)
    
    email = EmailMultiAlternatives(
        subject,
        text_content,
        settings.DEFAULT_FROM_EMAIL,
        [user.email]
    )
    email.attach_alternative(html_content, "text/html")
    email.send()
```

### Email Template

```html
<!-- templates/email/welcome.html -->
<h1>Welcome, {{ username }}!</h1>
<p>Thank you for joining Django Blog.</p>
<p><a href="{{ site_url }}/dashboard/">Visit your dashboard</a></p>
```

### My Notes:

```
What is the difference between `send_mail` and `EmailMultiAlternatives`?

_________________________________________________

_________________________________________________

How do you test email in development?

_________________________________________________

_________________________________________________
```

---

## 7.3: Sessions

### What are Sessions?

Sessions store temporary data about a user between requests. They're like a "shopping cart" for data.

```
User visits site → Session created → Data stored → Next request → Data retrieved
```

### Using Sessions

```python
# Setting session data
request.session['recent_posts'] = [1, 2, 3]

# Getting session data
recent_posts = request.session.get('recent_posts', [])

# Checking if key exists
if 'recent_posts' in request.session:
    # Do something

# Deleting session data
del request.session['recent_posts']

# Clearing all session data
request.session.clear()
```

### Example: Recent Posts

```python
class PostDetailView(DetailView):
    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        post = self.get_object()
        
        # Track recent posts
        recent_posts = self.request.session.get('recent_posts', [])
        if post.id not in recent_posts:
            recent_posts.insert(0, post.id)
            recent_posts = recent_posts[:5]  # Keep only 5
            self.request.session['recent_posts'] = recent_posts
        
        # Get actual post objects
        context['recently_viewed'] = Post.objects.filter(id__in=recent_posts)
        return context
```

### My Notes:

```
Where is session data stored?

_________________________________________________

_________________________________________________

What is the difference between sessions and cookies?

_________________________________________________

_________________________________________________
```

---

## 7.4: Database Transactions

### What are Transactions?

Transactions ensure that a group of database operations either all succeed or all fail. They prevent data inconsistency.

```
Start transaction → Operation 1 → Operation 2 → Commit (if both succeed)
                                              → Rollback (if either fails)
```

### Using Transactions

```python
from django.db import transaction

# As a context manager
with transaction.atomic():
    post = Post.objects.create(title='My Post', content='Content')
    Tag.objects.create(name='python', post=post)
    # If Tag creation fails, Post creation is rolled back

# As a decorator
@transaction.atomic
def create_post_with_tags(title, content, author, tags):
    post = Post.objects.create(title=title, content=content, author=author)
    for tag_name in tags:
        Tag.objects.create(name=tag_name, post=post)
    return post
```

### Savepoints

```python
with transaction.atomic():
    # Outer transaction
    post = Post.objects.create(title='My Post')
    
    # Inner transaction (savepoint)
    sid = transaction.savepoint()
    try:
        Tag.objects.create(name='python', post=post)
    except Exception:
        transaction.savepoint_rollback(sid)  # Rollback only inner
```

### My Notes:

```
When should you use transactions?

_________________________________________________

_________________________________________________

What is the difference between a transaction and a savepoint?

_________________________________________________

_________________________________________________
```

---

## 7.5: Exercise — Add Post Scheduling

### Instructions

Add the ability for authors to schedule posts for future publication using a `scheduled_publish_at` field. Then create a management command to publish scheduled posts.

### Steps

**Step 1: Add Model Field**

```python
class Post(models.Model):
    # ... existing fields ...
    scheduled_publish_at = models.DateTimeField(
        blank=True,
        null=True,
        help_text="If set, the post will be published at this date and time."
    )
```

**Step 2: Update Form**

```python
class PostForm(forms.ModelForm):
    class Meta:
        model = Post
        fields = ['title', 'slug', 'category', 'content', 
                  'status', 'scheduled_publish_at']
        widgets = {
            'scheduled_publish_at': forms.DateTimeInput(
                attrs={'type': 'datetime-local', 'class': 'form-control'}
            ),
        }
```

**Step 3: Update Save Method**

```python
def save(self, *args, **kwargs):
    if not self.slug:
        self.slug = slugify(self.title)
    
    # If scheduled, keep as draft
    if self.scheduled_publish_at and self.status == self.Status.PUBLISHED:
        self.status = self.Status.DRAFT
    
    super().save(*args, **kwargs)
```

**Step 4: Create Management Command**

`blog/management/commands/publish_scheduled_posts.py`:

```python
from django.core.management.base import BaseCommand
from django.utils import timezone
from blog.models import Post

class Command(BaseCommand):
    help = 'Publish scheduled posts'

    def handle(self, *args, **options):
        now = timezone.now()
        posts = Post.objects.filter(
            status=Post.Status.DRAFT,
            scheduled_publish_at__lte=now
        )
        
        count = 0
        for post in posts:
            post.status = Post.Status.PUBLISHED
            post.published_at = now
            post.save()
            count += 1
            self.stdout.write(f'Published: {post.title}')
        
        self.stdout.write(self.style.SUCCESS(f'Published {count} post(s)'))
```

### Self-Check

- [ ] Does the scheduled publish field appear in the form?
- [ ] Does the command publish scheduled posts?
- [ ] Does the command show success messages?

---

# Part 8: Testing and Quality

## 8.1: Testing Models

### The TestCase Class

```python
from django.test import TestCase
from django.contrib.auth.models import User
from blog.models import Post

class PostModelTest(TestCase):
    def setUp(self):
        """Set up test data."""
        self.user = User.objects.create_user(
            username='testuser',
            password='testpass'
        )
        self.post = Post.objects.create(
            title='Test Post',
            content='Test content',
            author=self.user,
            status='published'
        )
    
    def test_post_creation(self):
        """Test that a post is created correctly."""
        self.assertEqual(self.post.title, 'Test Post')
        self.assertEqual(self.post.author.username, 'testuser')
        self.assertEqual(self.post.status, 'published')
    
    def test_post_str_method(self):
        """Test the __str__ method."""
        self.assertEqual(str(self.post), 'Test Post')
    
    def test_post_get_absolute_url(self):
        """Test get_absolute_url method."""
        url = self.post.get_absolute_url()
        self.assertEqual(url, f'/blog/{self.post.slug}/')
```

### Running Tests

```bash
# Run all tests
python manage.py test

# Run tests for a specific app
python manage.py test blog

# Run a specific test file
python manage.py test blog.tests.test_models

# Run a specific test
python manage.py test blog.tests.test_models.PostModelTest.test_post_creation
```

### My Notes:

```
What is the purpose of `setUp()`?

_________________________________________________

_________________________________________________

How do you test model relationships?

_________________________________________________

_________________________________________________
```

---

## 8.2: Testing Forms

### Form Test Example

```python
from django.test import TestCase
from blog.forms import PostForm

class PostFormTest(TestCase):
    def test_valid_post_form(self):
        """Test that a valid form passes validation."""
        form_data = {
            'title': 'Test Post',
            'content': 'Test content',
            'status': 'published',
        }
        form = PostForm(data=form_data)
        self.assertTrue(form.is_valid())
    
    def test_empty_title_form(self):
        """Test that empty title is invalid."""
        form_data = {
            'title': '',
            'content': 'Test content',
            'status': 'published',
        }
        form = PostForm(data=form_data)
        self.assertFalse(form.is_valid())
        self.assertIn('title', form.errors)
    
    def test_form_slug_auto_generation(self):
        """Test that slug is auto-generated."""
        form_data = {
            'title': 'Test Post',
            'content': 'Test content',
            'status': 'published',
        }
        form = PostForm(data=form_data)
        self.assertTrue(form.is_valid())
        cleaned_data = form.clean()
        self.assertEqual(cleaned_data.get('slug'), 'test-post')
```

### My Notes:

```
What is the difference between `assertTrue` and `assertFalse`?

_________________________________________________

_________________________________________________

How do you test form validation errors?

_________________________________________________

_________________________________________________
```

---

## 8.3: Testing Views

### View Test Example

```python
from django.test import TestCase, Client
from django.urls import reverse
from django.contrib.auth.models import User
from blog.models import Post

class PostViewTest(TestCase):
    def setUp(self):
        self.client = Client()
        self.user = User.objects.create_user(
            username='testuser',
            password='testpass'
        )
        self.post = Post.objects.create(
            title='Test Post',
            content='Test content',
            author=self.user,
            status='published'
        )
    
    def test_blog_list_view(self):
        """Test the blog list page."""
        response = self.client.get(reverse('blog:blog_list'))
        self.assertEqual(response.status_code, 200)
        self.assertTemplateUsed(response, 'blog/blog_list.html')
        self.assertContains(response, 'Test Post')
    
    def test_post_detail_view(self):
        """Test the post detail page."""
        response = self.client.get(
            reverse('blog:post_detail', kwargs={'slug': self.post.slug})
        )
        self.assertEqual(response.status_code, 200)
        self.assertTemplateUsed(response, 'blog/post_detail.html')
        self.assertContains(response, 'Test Post')
    
    def test_post_detail_404(self):
        """Test non-existent post returns 404."""
        response = self.client.get(
            reverse('blog:post_detail', kwargs={'slug': 'non-existent'})
        )
        self.assertEqual(response.status_code, 404)
```

### My Notes:

```
What is the Django test client?

_________________________________________________

_________________________________________________

How do you test authenticated views?

_________________________________________________

_________________________________________________
```

---

## 8.4: Logging

### Configuring Logging

```python
# config/settings.py
LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'formatters': {
        'verbose': {
            'format': '{levelname} {asctime} {name} {message}',
            'style': '{',
        },
    },
    'handlers': {
        'console': {
            'class': 'logging.StreamHandler',
            'formatter': 'verbose',
        },
        'file': {
            'class': 'logging.handlers.RotatingFileHandler',
            'filename': BASE_DIR / 'logs/django.log',
            'maxBytes': 1024 * 1024 * 10,
            'backupCount': 5,
            'formatter': 'verbose',
        },
    },
    'loggers': {
        'blog': {
            'handlers': ['console', 'file'],
            'level': 'DEBUG',
        },
    },
}
```

### Using Logging

```python
import logging
logger = logging.getLogger(__name__)

def my_view(request):
    logger.info(f"User {request.user} accessed this view")
    try:
        result = risky_operation()
    except Exception as e:
        logger.error(f"Error in my_view: {e}")
        raise
```

### My Notes:

```
What log levels are available?

_________________________________________________

_________________________________________________

Why use `__name__` in `getLogger()`?

_________________________________________________

_________________________________________________
```

---

## 8.5: Exercise — Write Tests for Your App

### Instructions

Write tests for the Post model, PostForm, and PostListView.

### Steps

**Step 1: Test the Post Model**

```python
# blog/tests/test_models.py
from django.test import TestCase
from django.contrib.auth.models import User
from blog.models import Post

class PostModelTest(TestCase):
    def setUp(self):
        self.user = User.objects.create_user(
            username='testuser',
            password='testpass'
        )
    
    def test_post_creation(self):
        post = Post.objects.create(
            title='Test Post',
            content='Test content',
            author=self.user
        )
        self.assertEqual(str(post), 'Test Post')
        self.assertTrue(post.slug.startswith('test-post'))
```

**Step 2: Test the PostForm**

```python
# blog/tests/test_forms.py
from django.test import TestCase
from blog.forms import PostForm

class PostFormTest(TestCase):
    def test_valid_form(self):
        data = {'title': 'Test', 'content': 'Content', 'status': 'draft'}
        form = PostForm(data=data)
        self.assertTrue(form.is_valid())
```

**Step 3: Test the PostListView**

```python
# blog/tests/test_views.py
from django.test import TestCase, Client
from django.urls import reverse

class PostListViewTest(TestCase):
    def test_list_view(self):
        client = Client()
        response = client.get(reverse('blog:blog_list'))
        self.assertEqual(response.status_code, 200)
        self.assertTemplateUsed(response, 'blog/blog_list.html')
```

### Self-Check

- [ ] Do all tests pass?
- [ ] Is the test coverage report showing good coverage?
- [ ] Are there tests for edge cases?

---

# Part 9: Production Readiness

## 9.1: Query Optimization

### The N+1 Problem

The N+1 problem occurs when you query related objects in a loop.

**Bad: N+1 Queries**
```python
posts = Post.objects.all()
for post in posts:
    print(post.author.username)  # 1 query per post
```

**Good: 1 Query**
```python
posts = Post.objects.select_related('author').all()
for post in posts:
    print(post.author.username)  # Already loaded
```

### Using `select_related` and `prefetch_related`

```python
# For ForeignKey (JOIN in SQL)
posts = Post.objects.select_related('author', 'category').all()

# For ManyToMany (separate query)
posts = Post.objects.prefetch_related('tags').all()

# Both
posts = Post.objects.select_related('author').prefetch_related('tags').all()
```

### Using `only()` and `defer()`

```python
# Load only specific fields
posts = Post.objects.only('title', 'slug', 'created_at')

# Defer loading heavy fields
posts = Post.objects.defer('content', 'meta_description')
```

### My Notes:

```
What is the N+1 query problem?

_________________________________________________

_________________________________________________

When should you use `select_related` vs `prefetch_related`?

_________________________________________________

_________________________________________________
```

---

## 9.2: Caching

### Cache Configuration

```python
# config/settings.py
CACHES = {
    'default': {
        'BACKEND': 'django.core.cache.backends.locmem.LocMemCache',
        'LOCATION': 'unique-snowflake',
        'TIMEOUT': 300,  # 5 minutes
    }
}

# For production (Redis)
CACHES = {
    'default': {
        'BACKEND': 'django.core.cache.backends.redis.RedisCache',
        'LOCATION': 'redis://127.0.0.1:6379/1',
        'TIMEOUT': 300,
    }
}
```

### Using the Cache

```python
from django.core.cache import cache

# Set cache
cache.set('categories', categories, timeout=3600)

# Get cache
categories = cache.get('categories')

# Check if exists
if categories is None:
    categories = Category.objects.all()
    cache.set('categories', categories, timeout=3600)

# Delete cache
cache.delete('categories')
cache.clear()  # Clear all
```

### Caching in Views

```python
from django.views.decorators.cache import cache_page

@cache_page(300)  # Cache for 5 minutes
def home(request):
    # Expensive computation
    return render(request, 'home.html', context)
```

### My Notes:

```
What is the difference between caching and static files?

_________________________________________________

_________________________________________________

When should you use `cache_page` vs manual caching?

_________________________________________________

_________________________________________________
```

---

## 9.3: Security Hardening

### Production Security Checklist

- [ ] `DEBUG = False`
- [ ] `SECRET_KEY` in environment variables
- [ ] `ALLOWED_HOSTS` configured
- [ ] HTTPS enabled (`SECURE_SSL_REDIRECT = True`)
- [ ] Secure cookies (`SESSION_COOKIE_SECURE = True`)
- [ ] Security headers configured
- [ ] Password hashing (Django's default is fine)

### Security Headers

```python
# config/settings.py
SECURE_BROWSER_XSS_FILTER = True
SECURE_CONTENT_TYPE_NOSNIFF = True
X_FRAME_OPTIONS = 'DENY'
SECURE_HSTS_SECONDS = 31536000  # 1 year
SECURE_HSTS_INCLUDE_SUBDOMAINS = True
SECURE_HSTS_PRELOAD = True
```

### Environment Variables

```bash
# .env
SECRET_KEY=your-super-secret-key
DEBUG=False
ALLOWED_HOSTS=yourdomain.com,www.yourdomain.com
```

```python
# config/settings.py
import os
from dotenv import load_dotenv

load_dotenv()

SECRET_KEY = os.environ.get('SECRET_KEY')
DEBUG = os.environ.get('DEBUG') == 'True'
ALLOWED_HOSTS = os.environ.get('ALLOWED_HOSTS', '').split(',')
```

### My Notes:

```
Why is `DEBUG=False` important for production?

_________________________________________________

_________________________________________________

What security headers should you use?

_________________________________________________

_________________________________________________
```

---

## 9.4: Environment Variables

### Why Use Environment Variables?

- **Security**: Secrets aren't in code
- **Flexibility**: Different settings for different environments
- **CI/CD**: Easy to change without code changes

### Using `python-dotenv`

```bash
# Install
uv pip install python-dotenv
```

```python
# config/settings.py
from dotenv import load_dotenv
import os

load_dotenv()  # Load .env file

SECRET_KEY = os.environ.get('SECRET_KEY')
DEBUG = os.environ.get('DEBUG') == 'True'
DATABASE_URL = os.environ.get('DATABASE_URL')
```

### Environment Variables Reference

| Variable | Purpose | Example |
|----------|---------|---------|
| `SECRET_KEY` | Django secret key | `django-insecure-xyz` |
| `DEBUG` | Debug mode | `False` |
| `ALLOWED_HOSTS` | Allowed domains | `example.com,www.example.com` |
| `DATABASE_URL` | Database connection | `postgresql://user:pass@localhost/db` |
| `EMAIL_HOST` | SMTP server | `smtp.gmail.com` |
| `EMAIL_HOST_USER` | Email user | `your-email@gmail.com` |
| `EMAIL_HOST_PASSWORD` | Email password | `your-app-password` |

### My Notes:

```
What is the difference between `.env` and `settings.py`?

_________________________________________________

_________________________________________________

What variables should you never commit to Git?

_________________________________________________

_________________________________________________
```

---

## 9.5: Exercise — Optimize Your Queries

### Instructions

Identify and fix N+1 query problems in your blog application. Use `select_related`, `prefetch_related`, and `only()` to optimize.

### Steps

**Step 1: Identify N+1 Queries**

Enable Django Debug Toolbar or print SQL queries:

```python
from django.db import connection

# Enable query logging
connection.queries_log.clear()

# Run your code
posts = Post.objects.all()
for post in posts:
    print(post.author.username)

# Check query count
print(f"Number of queries: {len(connection.queries)}")
```

**Step 2: Optimize with select_related**

```python
# Before
posts = Post.objects.all()

# After
posts = Post.objects.select_related('author', 'category').all()
```

**Step 3: Optimize with prefetch_related**

```python
# Before
posts = Post.objects.all()
for post in posts:
    for tag in post.tags.all():
        print(tag.name)

# After
posts = Post.objects.prefetch_related('tags').all()
```

**Step 4: Use only() and defer()**

```python
# Load only needed fields
posts = Post.objects.only('title', 'slug').all()
```

### Self-Check

- [ ] Are N+1 queries identified?
- [ ] Are `select_related` and `prefetch_related` used correctly?
- [ ] Is the query count reduced?

---

# Part 10: Deployment

## 10.1: Docker

### What is Docker?

Docker packages your application and all its dependencies into a **container**. Think of it like a virtual machine but lightweight and portable.

```
Application → Docker Image → Docker Container → Run Anywhere
```

### Dockerfile

```dockerfile
# Dockerfile
FROM python:3.14-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .

RUN python manage.py collectstatic --noinput

CMD ["gunicorn", "config.wsgi:application", "--bind", "0.0.0.0:8000"]
```

### Building and Running

```bash
# Build the image
docker build -t django-blog .

# Run the container
docker run -p 8000:8000 django-blog

# Stop the container
docker stop <container_id>
```

### My Notes:

```
What is the difference between an image and a container?

_________________________________________________

_________________________________________________

Why use Docker for deployment?

_________________________________________________

_________________________________________________
```

---

## 10.2: Gunicorn

### What is Gunicorn?

Gunicorn is a WSGI HTTP server for Python applications. It handles concurrent requests and serves your Django application.

```
Nginx → Gunicorn → Django
```

### Gunicorn Configuration

**File: `gunicorn.conf.py`**

```python
import multiprocessing

bind = "0.0.0.0:8000"
workers = multiprocessing.cpu_count() * 2 + 1
worker_class = "sync"
timeout = 30
max_requests = 1000
max_requests_jitter = 100

accesslog = "/app/logs/gunicorn-access.log"
errorlog = "/app/logs/gunicorn-error.log"
loglevel = "info"
```

### Running Gunicorn

```bash
# Development
gunicorn config.wsgi:application --reload

# Production
gunicorn config.wsgi:application --config gunicorn.conf.py
```

### My Notes:

```
Why use Gunicorn instead of the development server?

_________________________________________________

_________________________________________________

What does the `workers` setting do?

_________________________________________________

_________________________________________________
```

---

## 10.3: Nginx

### What is Nginx?

Nginx is a web server that serves as a **reverse proxy** for Gunicorn.

```
Browser → Nginx (Port 80/443) → Gunicorn (Port 8000) → Django
```

### Nginx Configuration

**File: `/etc/nginx/sites-available/django_blog`**

```nginx
server {
    listen 80;
    server_name yourdomain.com;
    
    location /static/ {
        alias /var/www/django_blog/staticfiles/;
        expires 30d;
    }
    
    location /media/ {
        alias /var/www/django_blog/media/;
        expires 30d;
    }
    
    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### My Notes:

```
Why use Nginx in front of Gunicorn?

_________________________________________________

_________________________________________________

What is the purpose of `proxy_pass`?

_________________________________________________

_________________________________________________
```

---

## 10.4: Docker Compose

### What is Docker Compose?

Docker Compose runs multiple containers together. It defines services, networks, and volumes in a single file.

### docker-compose.yml

```yaml
version: '3.8'

services:
  db:
    image: postgres:16-alpine
    volumes:
      - postgres_data:/var/lib/postgresql/data
    environment:
      POSTGRES_DB: ${DB_NAME}
      POSTGRES_USER: ${DB_USER}
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${DB_USER}"]
  
  web:
    build: .
    volumes:
      - ./media:/app/media
      - ./staticfiles:/app/staticfiles
    environment:
      - DB_HOST=db
    depends_on:
      db:
        condition: service_healthy
  
  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf:ro
      - ./staticfiles:/app/staticfiles:ro
      - ./media:/app/media:ro
    depends_on:
      - web

volumes:
  postgres_data:
```

### Running Docker Compose

```bash
# Start services
docker-compose up -d

# Stop services
docker-compose down

# View logs
docker-compose logs -f

# Rebuild and start
docker-compose up -d --build
```

### My Notes:

```
Why use Docker Compose instead of running containers manually?

_________________________________________________

_________________________________________________

What are volumes and why are they important?

_________________________________________________

_________________________________________________
```

---

## 10.5: Exercise — Deploy Your Application

### Instructions

Deploy your Django application using Docker, Gunicorn, and Nginx.

### Steps

**Step 1: Create Dockerfile**

```dockerfile
FROM python:3.14-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .

RUN python manage.py collectstatic --noinput

CMD ["gunicorn", "--config", "gunicorn.conf.py", "config.wsgi:application"]
```

**Step 2: Create docker-compose.yml**

```yaml
version: '3.8'

services:
  web:
    build: .
    volumes:
      - ./media:/app/media
      - ./staticfiles:/app/staticfiles
    ports:
      - "8000:8000"
    environment:
      - DEBUG=False
```

**Step 3: Create Nginx Config**

```nginx
events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    
    upstream django {
        server web:8000;
    }
    
    server {
        listen 80;
        
        location /static/ {
            alias /app/staticfiles/;
        }
        
        location /media/ {
            alias /app/media/;
        }
        
        location / {
            proxy_pass http://django;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
        }
    }
}
```

**Step 4: Build and Run**

```bash
docker-compose build
docker-compose up -d
```

**Step 5: Test Deployment**

```bash
# Check if running
docker-compose ps

# Check logs
docker-compose logs web

# Visit in browser
open http://localhost
```

### Self-Check

- [ ] Does the application run in Docker?
- [ ] Are static files served correctly?
- [ ] Does Nginx proxy correctly?
- [ ] Is the database persistent?

---

# Appendix A: Command Reference

## Django Commands

```bash
# Project Management
python manage.py runserver              # Start development server
python manage.py runserver 8001         # On different port
python manage.py check                  # Check for issues
python manage.py shell                  # Interactive shell

# Database
python manage.py makemigrations         # Create migrations
python manage.py migrate                # Apply migrations
python manage.py showmigrations         # Show migration status
python manage.py sqlmigrate blog 0001   # Show SQL

# Admin
python manage.py createsuperuser        # Create admin user

# Testing
python manage.py test                   # Run all tests
python manage.py test blog              # Test specific app

# Static Files
python manage.py collectstatic          # Collect static files

# Utilities
python manage.py shell_plus             # With ipython
python manage.py dbshell                # Database shell
```

## Docker Commands

```bash
# Images
docker build -t image_name .            # Build image
docker images                           # List images
docker rmi image_name                   # Remove image

# Containers
docker run -p 8000:8000 image_name      # Run container
docker ps                               # List running containers
docker ps -a                            # List all containers
docker stop container_id                # Stop container
docker rm container_id                  # Remove container

# Docker Compose
docker-compose up -d                    # Start services
docker-compose down                     # Stop services
docker-compose logs -f                  # View logs
docker-compose build                    # Rebuild services
docker-compose exec web bash            # Execute command
```

## Git Commands

```bash
git init                                # Initialize repository
git add .                               # Add all files
git commit -m "Message"                 # Commit
git push origin main                    # Push to remote
git pull origin main                    # Pull from remote
git status                              # Check status
git log                                 # View history
git branch                              # List branches
git checkout -b branch_name             # Create branch
git merge branch_name                   # Merge branch
```

---

# Appendix B: Common Errors

## Error: "ModuleNotFoundError: No module named 'django'"

**Cause**: Django not installed or virtual environment not activated

**Solution**:
```bash
source .venv/bin/activate  # Activate virtual environment
pip install django         # Install Django
```

## Error: "TemplateDoesNotExist at /"

**Cause**: Template file missing or path incorrect

**Solution**:
1. Check template exists at correct path
2. Check `APP_DIRS=True` in settings
3. Check template name in `render()`

## Error: "OperationalError: no such table: blog_post"

**Cause**: Migrations not applied

**Solution**:
```bash
python manage.py makemigrations
python manage.py migrate
```

## Error: "NoReverseMatch: Reverse for 'home' not found"

**Cause**: URL name incorrect or namespace missing

**Solution**:
1. Check URL name in `urls.py`
2. Check namespace in template: `{% url 'blog:home' %}`
3. Check `app_name` in `urls.py`

## Error: "CSRF token missing or incorrect"

**Cause**: Missing `{% csrf_token %}` in form

**Solution**:
```html
<form method="post">
    {% csrf_token %}
    <!-- form fields -->
</form>
```

## Error: "Port 8000 already in use"

**Cause**: Another process is using port 8000

**Solution**:
```bash
# Find process
lsof -i :8000  # macOS/Linux
netstat -ano | findstr :8000  # Windows

# Kill process
kill -9 PID  # macOS/Linux
taskkill /PID PID /F  # Windows

# Use different port
python manage.py runserver 8001
```

---

# Appendix C: Code Snippets

## Base Template

```html
{% load static %}
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{% block title %}Django Blog{% endblock %}</title>
    <link rel="stylesheet" href="{% static 'css/style.css' %}">
    {% block extra_head %}{% endblock %}
</head>
<body>
    {% include 'includes/navigation.html' %}
    
    {% if messages %}
        <div class="messages">
            {% for message in messages %}
                <div class="message {{ message.tags }}">{{ message }}</div>
            {% endfor %}
        </div>
    {% endif %}
    
    <main>
        {% block content %}{% endblock %}
    </main>
    
    {% include 'includes/footer.html' %}
    
    <script src="{% static 'js/main.js' %}"></script>
    {% block scripts %}{% endblock %}
</body>
</html>
```

## Form Template

```html
<form method="post" enctype="multipart/form-data" novalidate>
    {% csrf_token %}
    
    {% if form.errors %}
        <div class="form-errors">
            <ul>
                {% for field, errors in form.errors.items %}
                    {% for error in errors %}
                        <li>{{ field|capfirst }}: {{ error }}</li>
                    {% endfor %}
                {% endfor %}
            </ul>
        </div>
    {% endif %}
    
    {% for field in form %}
        <div class="form-group">
            <label for="{{ field.id_for_label }}">
                {{ field.label }}
                {% if field.field.required %}<span class="required">*</span>{% endif %}
            </label>
            {{ field }}
            {% if field.help_text %}
                <small class="help-text">{{ field.help_text }}</small>
            {% endif %}
            {{ field.errors }}
        </div>
    {% endfor %}
    
    <button type="submit">Submit</button>
</form>
```

## Pagination Template

```html
{% if page_obj.has_other_pages %}
    <div class="pagination">
        {% if page_obj.has_previous %}
            <a href="?page=1">&laquo; First</a>
            <a href="?page={{ page_obj.previous_page_number }}">Previous</a>
        {% endif %}
        
        <span>Page {{ page_obj.number }} of {{ page_obj.paginator.num_pages }}</span>
        
        {% if page_obj.has_next %}
            <a href="?page={{ page_obj.next_page_number }}">Next</a>
            <a href="?page={{ page_obj.paginator.num_pages }}">Last &raquo;</a>
        {% endif %}
    </div>
{% endif %}
```

---

# Appendix D: Project Checklist

## Completed Features

- [ ] Django project setup
- [ ] Virtual environment configured
- [ ] Database models (Category, Tag, Post, Comment)
- [ ] Migrations applied
- [ ] Django Admin configured
- [ ] Views (home, blog_list, post_detail, category_detail, tag_detail)
- [ ] URL routing
- [ ] Templates (base, home, blog_list, post_detail)
- [ ] Static files (CSS, JS, images)
- [ ] Authentication (registration, login, logout)
- [ ] User profiles
- [ ] CRUD operations (create, edit, delete)
- [ ] Search functionality
- [ ] Filtering
- [ ] Pagination
- [ ] File uploads (images)
- [ ] Email notifications
- [ ] Sessions
- [ ] Class-based views
- [ ] Middleware
- [ ] Context processors
- [ ] Signals
- [ ] Service layer
- [ ] Tests (models, forms, views)
- [ ] Logging
- [ ] Query optimization
- [ ] Caching
- [ ] Security hardening
- [ ] Environment variables
- [ ] Docker
- [ ] Gunicorn
- [ ] Nginx
- [ ] Docker Compose

## Final Deployment Checklist

- [ ] `DEBUG = False`
- [ ] `SECRET_KEY` in environment
- [ ] `ALLOWED_HOSTS` configured
- [ ] SSL/HTTPS enabled
- [ ] Database set to PostgreSQL
- [ ] Static files collected
- [ ] Media files backed up
- [ ] Gunicorn configured
- [ ] Nginx configured
- [ ] Docker containerized
- [ ] Health check endpoint
- [ ] Monitoring set up
- [ ] Backups configured
- [ ] Error tracking (Sentry)
- [ ] Logging configured
- [ ] Security headers enabled

---

# Congratulations!

You've completed the Mastering Django 6 Student Workbook! You now have:

1. **Comprehensive notes** on all Django concepts
2. **Completed exercises** for each part
3. **Reference material** for common tasks
4. **Troubleshooting guides** for common errors
5. **Checklists** for project completion

**What's Next?**

- Build your own Django project
- Explore Django REST Framework
- Add a frontend framework (React, Vue)
- Contribute to open source Django projects
- Continue learning with the Django documentation

---

**[END OF STUDENT WORKBOOK]**
