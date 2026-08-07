# Mastering Django 6: Student Notes

## Full-Stack Web Development with Python

---

# Welcome!

These student notes are designed to accompany the **Mastering Django 6** video series. Use them to follow along, take additional notes, and track your progress through the course.

**How to use these notes:**
1. Watch the video for each section
2. Fill in the blanks as you watch
3. Complete the exercises at the end of each part
4. Use the key terms and commands for review

---

# Part 0: Introduction

## 0.1 What is Django?

**Django** is a high-level Python web framework that encourages rapid development and clean, pragmatic design.

**Key characteristics:**
- "Batteries included" — comes with many built-in features
- Secure — protects against common vulnerabilities
- Scalable — used by large sites like Instagram and Pinterest
- Fast — helps you build applications quickly

**The "Simple Stack" Philosophy:**
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

---

## 0.2 Setting Up Your Environment

**Prerequisites:**
- Python 3.14 or later
- Basic Python knowledge (variables, functions, classes)
- Basic HTML and CSS
- Command-line comfort

**Installation Steps:**

```bash
# Create project directory
mkdir django_blog_project
cd django_blog_project

# Create virtual environment (using uv)
uv venv

# Activate (macOS/Linux)
source .venv/bin/activate

# Activate (Windows)
.venv\Scripts\activate

# Install Django
uv pip install django==6.0

# Create requirements file
uv pip freeze > requirements.txt
```

**Verification:**
```bash
python --version
python -m django --version
```

---

**My Additional Notes:**

_________________________________________________

_________________________________________________

_________________________________________________

---

# Part 1: Django Fundamentals

## 1.1 Creating Your First Project

**Project vs. App:**
- **Project**: The entire web application (settings, configurations, URLs)
- **App**: A specific feature within a project (e.g., blog, accounts)

**Commands:**
```bash
# Create project
django-admin startproject config .

# Create app
python manage.py startapp blog

# Run server
python manage.py runserver
```

**Project Structure:**
```
django_blog_project/
├── manage.py              # Command center
├── requirements.txt       # Dependencies
├── config/
│   ├── __init__.py
│   ├── settings.py        # ALL settings
│   ├── urls.py            # URL routing
│   └── wsgi.py            # Production entry
└── blog/
    ├── __init__.py
    ├── admin.py           # Admin config
    ├── apps.py            # App config
    ├── models.py          # Database models
    ├── tests.py           # Tests
    ├── urls.py            # App URLs
    └── views.py           # Views
```

---

## 1.2 Understanding MVT

**The Request-Response Cycle:**
```
1. User visits URL (e.g., /blog/)
   ↓
2. Django's URL dispatcher finds the view for the URL
   ↓
3. The view executes business logic
   ↓
4. If needed, the view queries the database
   ↓
5. The view renders a template with data
   ↓
6. Django sends HTML back to the browser
   ↓
7. Browser displays the rendered page
```

**MVT vs MVC:**

| Django (MVT) | Traditional (MVC) | Responsibility |
|--------------|-------------------|----------------|
| **M**odel | **M**odel | Data & business logic |
| **V**iew | **C**ontroller | Request handling & logic |
| **T**emplate | **V**iew | Presentation (HTML) |

**Analogy: Restaurant**
- **URLs** = Menu board
- **View** = Chef
- **Model** = Kitchen inventory
- **Template** = Plate presentation

---

## 1.3 Views and URLs

**Creating a View:**
```python
from django.shortcuts import render
from django.http import HttpResponse

def home(request):
    context = {
        'page_title': 'Welcome to My Django Blog',
        'welcome_message': 'This is the beginning of your Django journey!',
    }
    return render(request, 'blog/home.html', context)
```

**URL Routing:**
```python
# blog/urls.py
from django.urls import path
from . import views

app_name = 'blog'

urlpatterns = [
    path('', views.home, name='home'),
    path('about/', views.about, name='about'),
    path('blog/', views.blog_list, name='blog_list'),
]

# config/urls.py
urlpatterns = [
    path('admin/', admin.site.urls),
    path('', include('blog.urls')),
]
```

---

## 1.4 Templates

**Template Inheritance:**
```html
<!-- base.html -->
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

<!-- home.html -->
{% extends 'blog/base.html' %}

{% block title %}
    {{ page_title }} — Django Blog
{% endblock %}

{% block content %}
    <h1>{{ welcome_message }}</h1>
{% endblock %}
```

**Template Tags and Filters:**

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

---

## 1.5 Exercise: Build a Contact Page

**Instructions:**
1. Create a view called `contact`
2. Add a URL pattern `/contact/`
3. Create a template `contact.html` that extends base
4. Add a link in the navigation

**Solution:**
```python
# views.py
def contact(request):
    context = {
        'page_title': 'Contact Us',
        'email': 'contact@example.com',
        'phone': '555-1234',
    }
    return render(request, 'blog/contact.html', context)

# urls.py
path('contact/', views.contact, name='contact'),
```

```html
<!-- contact.html -->
{% extends 'blog/base.html' %}

{% block title %}{{ page_title }} — Django Blog{% endblock %}

{% block content %}
    <h1>{{ page_title }}</h1>
    <p>Email: {{ email }}</p>
    <p>Phone: {{ phone }}</p>
{% endblock %}
```

---

**My Additional Notes:**

_________________________________________________

_________________________________________________

_________________________________________________

---

# Part 2: Models and Databases

## 2.1 Designing Database Models

**Model Relationships:**

| Relationship | Django Field | Example |
|--------------|--------------|---------|
| One-to-One | `OneToOneField` | User → Profile |
| One-to-Many | `ForeignKey` | User → Posts |
| Many-to-Many | `ManyToManyField` | Posts → Tags |

**Common Field Types:**

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

**Example Model:**
```python
from django.db import models
from django.contrib.auth.models import User

class Post(models.Model):
    class Status(models.TextChoices):
        DRAFT = 'draft', 'Draft'
        PUBLISHED = 'published', 'Published'
        ARCHIVED = 'archived', 'Archived'
    
    title = models.CharField(max_length=200)
    slug = models.SlugField(max_length=220, unique=True)
    content = models.TextField()
    author = models.ForeignKey(User, on_delete=models.CASCADE)
    status = models.CharField(max_length=10, choices=Status.choices, default=Status.DRAFT)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    def __str__(self):
        return self.title
    
    def get_absolute_url(self):
        return reverse('blog:post_detail', args=[self.slug])
```

---

## 2.2 Migrations

**Migration Workflow:**
```
1. Make changes to models.py
   ↓
2. Create migration files: makemigrations
   ↓
3. Apply migrations: migrate
   ↓
4. Verify changes: showmigrations
```

**Commands:**
```bash
python manage.py makemigrations      # Create migrations
python manage.py migrate             # Apply migrations
python manage.py showmigrations      # Check status
python manage.py sqlmigrate blog 0001  # View SQL
```

---

## 2.3 Django Admin

**Registering Models:**
```python
# admin.py
from django.contrib import admin
from .models import Post, Category

@admin.register(Post)
class PostAdmin(admin.ModelAdmin):
    list_display = ['title', 'author', 'status', 'created_at']
    list_filter = ['status', 'category']
    search_fields = ['title', 'content']
    prepopulated_fields = {'slug': ('title',)}
    list_editable = ['status']
    ordering = ['-created_at']
```

**Admin Customization Options:**

| Option | Purpose |
|--------|---------|
| `list_display` | Columns shown in list view |
| `list_filter` | Filters in sidebar |
| `search_fields` | Searchable fields |
| `prepopulated_fields` | Auto-populate fields |
| `list_editable` | Editable in list view |
| `ordering` | Default sort order |

---

## 2.4 Django ORM

**CRUD Operations:**

| Operation | Django ORM |
|-----------|------------|
| Create | `Post.objects.create(title='Hello')` |
| Read All | `Post.objects.all()` |
| Filter | `Post.objects.filter(status='published')` |
| Update | `post.save()` or `Post.objects.update()` |
| Delete | `post.delete()` or `Post.objects.delete()` |

**Common ORM Methods:**
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
posts = Post.objects.order_by('-created_at')

# Limit
posts = Post.objects.all()[:5]

# Values
titles = Post.objects.values_list('title', flat=True)

# Aggregation
from django.db.models import Count, Sum, Avg
stats = Post.objects.aggregate(
    total=Count('id'),
    avg_views=Avg('view_count')
)
```

---

## 2.5 Exercise: Add a Comment Model

**Instructions:**
Add a Comment model with:
- Foreign key to Post
- Foreign key to User (author)
- Content (TextField)
- Created timestamp
- `is_approved` boolean field

**Solution:**
```python
class Comment(models.Model):
    post = models.ForeignKey(Post, on_delete=models.CASCADE, related_name='comments')
    author = models.ForeignKey(User, on_delete=models.CASCADE, related_name='comments')
    content = models.TextField()
    is_approved = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Comment by {self.author.username} on {self.post.title}"
```

```bash
python manage.py makemigrations blog
python manage.py migrate blog
```

```python
# admin.py
@admin.register(Comment)
class CommentAdmin(admin.ModelAdmin):
    list_display = ['author', 'post', 'is_approved', 'created_at']
    list_filter = ['is_approved', 'created_at']
    list_editable = ['is_approved']
```

---

**My Additional Notes:**

_________________________________________________

_________________________________________________

_________________________________________________

---

# Part 3: Forms and CRUD

## 3.1 Django Forms

**ModelForm vs Form:**

| Feature | Form | ModelForm |
|---------|------|-----------|
| Fields defined in code | ✅ | ❌ (auto-generated) |
| Integrates with model | ❌ | ✅ |
| Save method | Manual | ✅ |

**Creating a ModelForm:**
```python
# forms.py
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
        slug = self.cleaned_data.get('slug')
        if Post.objects.filter(slug=slug).exists():
            raise forms.ValidationError('This slug already exists.')
        return slug
```

---

## 3.2 CRUD Views

**Create View Pattern:**
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
    
    return render(request, 'blog/post_form.html', {'form': form})
```

**Edit View Pattern:**
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
    
    return render(request, 'blog/post_form.html', {'form': form, 'post': post})
```

**Delete View Pattern:**
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

---

## 3.3 Form Template

```html
<form method="post" enctype="multipart/form-data">
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

---

## 3.4 Exercise: Add Post Scheduling

**Instructions:**
Add a `scheduled_publish_at` field and a management command to publish scheduled posts.

**Solution:**
```python
# models.py
class Post(models.Model):
    # ... existing fields ...
    scheduled_publish_at = models.DateTimeField(blank=True, null=True)

    def save(self, *args, **kwargs):
        if not self.slug:
            self.slug = slugify(self.title)
        if self.scheduled_publish_at and self.status == self.Status.PUBLISHED:
            self.status = self.Status.DRAFT
        super().save(*args, **kwargs)

# management/commands/publish_scheduled_posts.py
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

---

**My Additional Notes:**

_________________________________________________

_________________________________________________

_________________________________________________

---

# Part 4: Class-Based Views

## 4.1 Understanding CBVs

**FBV vs CBV Comparison:**

| Feature | Function-Based | Class-Based |
|---------|----------------|-------------|
| Syntax | Simple functions | Classes with methods |
| Reusability | Limited | High (inheritance) |
| Built-in Features | Minimal | Many |
| Best For | Simple views | Complex, repetitive views |

**Common CBV Types:**

| CBV | Purpose |
|-----|---------|
| `View` | Basic class-based view |
| `TemplateView` | Render a template |
| `ListView` | Display a list of objects |
| `DetailView` | Display a single object |
| `CreateView` | Create a new object |
| `UpdateView` | Edit an existing object |
| `DeleteView` | Delete an object |

---

## 4.2 ListView and DetailView

**ListView Pattern:**
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
        return queryset.filter(status='published')
```

**DetailView Pattern:**
```python
from django.views.generic import DetailView

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

---

## 4.3 CreateView, UpdateView, DeleteView

**CreateView Pattern:**
```python
from django.views.generic import CreateView
from django.contrib.auth.mixins import LoginRequiredMixin

class PostCreateView(LoginRequiredMixin, CreateView):
    model = Post
    form_class = PostForm
    template_name = 'blog/post_form.html'
    success_url = reverse_lazy('blog:blog_list')
    
    def form_valid(self, form):
        form.instance.author = self.request.user
        return super().form_valid(form)
```

**UpdateView Pattern:**
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
```

**DeleteView Pattern:**
```python
class PostDeleteView(LoginRequiredMixin, UserPassesTestMixin, DeleteView):
    model = Post
    template_name = 'blog/post_confirm_delete.html'
    success_url = reverse_lazy('blog:blog_list')
    
    def test_func(self):
        post = self.get_object()
        return self.request.user == post.author
```

---

## 4.4 Search and Filtering

**Search Implementation:**
```python
from django.db.models import Q

class PostListView(ListView):
    # ... existing attributes ...
    
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

**Filtering Template:**
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

---

## 4.5 Exercise: Add Category Filtering

**Solution:**
```python
class PostListView(ListView):
    # ... existing attributes ...
    
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

---

**My Additional Notes:**

_________________________________________________

_________________________________________________

_________________________________________________

---

# Part 5: Authentication and Users

## 5.1 User Registration

**Registration View:**
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

**Registration Template:**
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

---

## 5.2 Login and Logout

**URL Configuration:**
```python
from django.contrib.auth import views as auth_views

urlpatterns = [
    path('login/', auth_views.LoginView.as_view(), name='login'),
    path('logout/', auth_views.LogoutView.as_view(), name='logout'),
    # ... other URLs
]
```

**Settings:**
```python
LOGIN_URL = 'login'
LOGIN_REDIRECT_URL = 'blog:home'
LOGOUT_REDIRECT_URL = 'blog:home'
```

**Protecting Views:**
```python
from django.contrib.auth.decorators import login_required

@login_required
def post_create(request):
    # Only authenticated users can access
    pass
```

---

## 5.3 User Profiles

**Profile Model:**
```python
from django.contrib.auth.models import User

class Profile(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    bio = models.TextField(max_length=500, blank=True)
    location = models.CharField(max_length=100, blank=True)
    avatar = models.ImageField(upload_to='avatars/', blank=True)
```

**Auto-Create Profile with Signals:**
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

---

## 5.4 Password Reset

**URL Configuration:**
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

**Email Configuration:**
```python
# Development (print to console)
EMAIL_BACKEND = 'django.core.mail.backends.console.EmailBackend'

# Production (SMTP)
EMAIL_BACKEND = 'django.core.mail.backends.smtp.EmailBackend'
EMAIL_HOST = 'smtp.gmail.com'
EMAIL_PORT = 587
EMAIL_USE_TLS = True
EMAIL_HOST_USER = 'your-email@gmail.com'
EMAIL_HOST_PASSWORD = 'your-app-password'
DEFAULT_FROM_EMAIL = 'noreply@yourapp.com'
```

---

## 5.5 Exercise: Add a User Dashboard

**Solution:**
```python
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

```html
<!-- dashboard.html -->
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

---

**My Additional Notes:**

_________________________________________________

_________________________________________________

_________________________________________________

---

# Part 6: Advanced Architecture

## 6.1 Middleware

**What is Middleware?**
Middleware is code that runs on every request and every response.

```
Request → Middleware → View → Middleware → Response
```

**Creating Custom Middleware:**
```python
# middleware.py
import time
import logging

logger = logging.getLogger(__name__)

class RequestLoggingMiddleware:
    def __init__(self, get_response):
        self.get_response = get_response
    
    def __call__(self, request):
        start_time = time.time()
        response = self.get_response(request)
        duration = time.time() - start_time
        logger.info(f"{request.method} {request.path} - {duration:.3f}s")
        return response
```

**Registering Middleware:**
```python
# settings.py
MIDDLEWARE = [
    # ... built-in middleware ...
    'blog.middleware.RequestLoggingMiddleware',
]
```

---

## 6.2 Context Processors

**What is a Context Processor?**
A context processor adds variables to every template's context.

**Creating a Context Processor:**
```python
# context_processors.py
from datetime import datetime
from .models import Category

def global_context(request):
    return {
        'current_year': datetime.now().year,
        'site_name': 'Django Blog',
        'categories_nav': Category.objects.all(),
    }
```

**Registering Context Processors:**
```python
# settings.py
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

---

## 6.3 Signals

**What are Signals?**
Signals allow different parts of your application to communicate when something happens.

```
Event happens → Signal sent → Receiver(s) process
```

**Common Use Cases:**

| Signal | Use Case |
|--------|----------|
| `post_save` | Auto-create profile when user registers |
| `post_delete` | Delete files when model is deleted |
| `m2m_changed` | Update counts when many-to-many changes |

**Creating a Signal:**
```python
# signals.py
from django.db.models.signals import post_save
from django.contrib.auth.models import User
from django.dispatch import receiver
from .models import Profile

@receiver(post_save, sender=User)
def create_user_profile(sender, instance, created, **kwargs):
    if created:
        Profile.objects.create(user=instance)
```

**Registering Signals:**
```python
# apps.py
class BlogConfig(AppConfig):
    def ready(self):
        import blog.signals  # noqa
```

---

## 6.4 Service Layer

**What is a Service Layer?**
A service layer moves business logic out of views and into separate service classes.

```
View → Service → Model
```

**Benefits:**
- Separation of concerns
- Reusability
- Testability
- Maintainability

**Creating a Service:**
```python
# services/post_service.py
from django.core.exceptions import PermissionDenied
from .models import Post

class PostService:
    @staticmethod
    def create_post(data, author):
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
        return Post.objects.filter(author=user)
```

---

## 6.5 Exercise: Create Custom Middleware

**Instructions:**
Create a maintenance mode middleware.

**Solution:**
```python
# middleware.py
from django.http import HttpResponse
from django.urls import reverse

class MaintenanceModeMiddleware:
    MAINTENANCE_MODE = False
    ALLOWED_IPS = ['127.0.0.1']
    
    def __init__(self, get_response):
        self.get_response = get_response
    
    def __call__(self, request):
        if self.MAINTENANCE_MODE:
            if request.user.is_staff or request.META.get('REMOTE_ADDR') in self.ALLOWED_IPS:
                return self.get_response(request)
            
            if request.path.startswith('/admin/') or request.path == reverse('login'):
                return self.get_response(request)
            
            return HttpResponse(
                '<h1>Under Maintenance</h1><p>We\'ll be back soon!</p>',
                status=503
            )
        
        return self.get_response(request)
```

---

**My Additional Notes:**

_________________________________________________

_________________________________________________

_________________________________________________

---

# Part 7: Real-World Features

## 7.1 File Uploads

**Configuring Media Files:**
```python
# settings.py
MEDIA_URL = '/media/'
MEDIA_ROOT = BASE_DIR / 'media'

# urls.py (development only)
from django.conf import settings
from django.conf.urls.static import static

if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
```

**Model with ImageField:**
```python
class Post(models.Model):
    # ... fields ...
    featured_image = models.ImageField(
        upload_to='posts/%Y/%m/%d/',
        blank=True,
        null=True,
        help_text="Optional image for the post"
    )
```

**Form Handling:**
```html
<form method="post" enctype="multipart/form-data">
    {% csrf_token %}
    {{ form.as_p }}
    <button type="submit">Upload</button>
</form>
```

---

## 7.2 Email Notifications

**Sending Email:**
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

**HTML Email with Template:**
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

---

## 7.3 Sessions

**What are Sessions?**
Sessions store temporary data about a user between requests.

**Using Sessions:**
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

**Example: Recent Posts**
```python
class PostDetailView(DetailView):
    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        post = self.get_object()
        
        recent_posts = self.request.session.get('recent_posts', [])
        if post.id not in recent_posts:
            recent_posts.insert(0, post.id)
            recent_posts = recent_posts[:5]
            self.request.session['recent_posts'] = recent_posts
        
        context['recently_viewed'] = Post.objects.filter(id__in=recent_posts)
        return context
```

---

## 7.4 Database Transactions

**What are Transactions?**
Transactions ensure that a group of database operations either all succeed or all fail.

**Using Transactions:**
```python
from django.db import transaction

# As a context manager
with transaction.atomic():
    post = Post.objects.create(title='My Post', content='Content')
    Tag.objects.create(name='python', post=post)

# As a decorator
@transaction.atomic
def create_post_with_tags(title, content, author, tags):
    post = Post.objects.create(title=title, content=content, author=author)
    for tag_name in tags:
        Tag.objects.create(name=tag_name, post=post)
    return post
```

**Savepoints:**
```python
with transaction.atomic():
    post = Post.objects.create(title='My Post')
    
    sid = transaction.savepoint()
    try:
        Tag.objects.create(name='python', post=post)
    except Exception:
        transaction.savepoint_rollback(sid)
```

---

## 7.5 Exercise: Add Post Scheduling

**Instructions:**
Add a `scheduled_publish_at` field and a management command to publish scheduled posts.

**Solution:**
```python
# models.py
class Post(models.Model):
    # ... existing fields ...
    scheduled_publish_at = models.DateTimeField(blank=True, null=True)

    def save(self, *args, **kwargs):
        if not self.slug:
            self.slug = slugify(self.title)
        if self.scheduled_publish_at and self.status == self.Status.PUBLISHED:
            self.status = self.Status.DRAFT
        super().save(*args, **kwargs)

# management/commands/publish_scheduled_posts.py
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

---

**My Additional Notes:**

_________________________________________________

_________________________________________________

_________________________________________________

---

# Part 8: Testing and Quality

## 8.1 Testing Models

**TestCase Class:**
```python
from django.test import TestCase
from django.contrib.auth.models import User
from blog.models import Post

class PostModelTest(TestCase):
    def setUp(self):
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
        self.assertEqual(self.post.title, 'Test Post')
        self.assertEqual(self.post.author.username, 'testuser')
    
    def test_post_str_method(self):
        self.assertEqual(str(self.post), 'Test Post')
    
    def test_post_get_absolute_url(self):
        url = self.post.get_absolute_url()
        self.assertEqual(url, f'/blog/{self.post.slug}/')
```

**Running Tests:**
```bash
python manage.py test                  # All tests
python manage.py test blog             # Specific app
python manage.py test blog.tests.test_models  # Specific file
```

---

## 8.2 Testing Forms

```python
from django.test import TestCase
from blog.forms import PostForm

class PostFormTest(TestCase):
    def test_valid_post_form(self):
        form_data = {
            'title': 'Test Post',
            'content': 'Test content',
            'status': 'published',
        }
        form = PostForm(data=form_data)
        self.assertTrue(form.is_valid())
    
    def test_empty_title_form(self):
        form_data = {
            'title': '',
            'content': 'Test content',
            'status': 'published',
        }
        form = PostForm(data=form_data)
        self.assertFalse(form.is_valid())
        self.assertIn('title', form.errors)
    
    def test_form_slug_auto_generation(self):
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

---

## 8.3 Testing Views

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
        response = self.client.get(reverse('blog:blog_list'))
        self.assertEqual(response.status_code, 200)
        self.assertTemplateUsed(response, 'blog/blog_list.html')
        self.assertContains(response, 'Test Post')
    
    def test_post_detail_view(self):
        response = self.client.get(
            reverse('blog:post_detail', kwargs={'slug': self.post.slug})
        )
        self.assertEqual(response.status_code, 200)
        self.assertTemplateUsed(response, 'blog/post_detail.html')
        self.assertContains(response, 'Test Post')
    
    def test_post_detail_404(self):
        response = self.client.get(
            reverse('blog:post_detail', kwargs={'slug': 'non-existent'})
        )
        self.assertEqual(response.status_code, 404)
```

---

## 8.4 Logging

**Configuring Logging:**
```python
# settings.py
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

**Using Logging:**
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

---

## 8.5 Exercise: Write Tests for Your App

**Instructions:**
Write tests for the Post model, PostForm, and PostListView.

**Solution:**
```python
# test_models.py
class PostModelTest(TestCase):
    def setUp(self):
        self.user = User.objects.create_user(username='testuser', password='testpass')
    
    def test_post_creation(self):
        post = Post.objects.create(
            title='Test Post',
            content='Test content',
            author=self.user
        )
        self.assertEqual(str(post), 'Test Post')
        self.assertTrue(post.slug.startswith('test-post'))

# test_forms.py
class PostFormTest(TestCase):
    def test_valid_form(self):
        data = {'title': 'Test', 'content': 'Content', 'status': 'draft'}
        form = PostForm(data=data)
        self.assertTrue(form.is_valid())

# test_views.py
class PostListViewTest(TestCase):
    def test_list_view(self):
        client = Client()
        response = client.get(reverse('blog:blog_list'))
        self.assertEqual(response.status_code, 200)
        self.assertTemplateUsed(response, 'blog/blog_list.html')
```

---

**My Additional Notes:**

_________________________________________________

_________________________________________________

_________________________________________________

---

# Part 9: Production Readiness

## 9.1 Query Optimization

**The N+1 Problem:**
```python
# Bad: N+1 queries
posts = Post.objects.all()
for post in posts:
    print(post.author.username)  # 1 query per post

# Good: 1 query
posts = Post.objects.select_related('author').all()
for post in posts:
    print(post.author.username)  # Already loaded
```

**Using select_related and prefetch_related:**
```python
# For ForeignKey (JOIN in SQL)
posts = Post.objects.select_related('author', 'category').all()

# For ManyToMany (separate query)
posts = Post.objects.prefetch_related('tags').all()

# Both
posts = Post.objects.select_related('author').prefetch_related('tags').all()
```

**Using only() and defer():**
```python
# Load only specific fields
posts = Post.objects.only('title', 'slug', 'created_at')

# Defer loading heavy fields
posts = Post.objects.defer('content', 'meta_description')
```

---

## 9.2 Caching

**Cache Configuration:**
```python
# settings.py
CACHES = {
    'default': {
        'BACKEND': 'django.core.cache.backends.locmem.LocMemCache',
        'LOCATION': 'unique-snowflake',
        'TIMEOUT': 300,  # 5 minutes
    }
}

# Production (Redis)
CACHES = {
    'default': {
        'BACKEND': 'django.core.cache.backends.redis.RedisCache',
        'LOCATION': 'redis://127.0.0.1:6379/1',
        'TIMEOUT': 300,
    }
}
```

**Using the Cache:**
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

**Caching Views:**
```python
from django.views.decorators.cache import cache_page

@cache_page(300)  # Cache for 5 minutes
def home(request):
    return render(request, 'home.html', context)
```

---

## 9.3 Security Hardening

**Production Security Checklist:**
- [ ] `DEBUG = False`
- [ ] `SECRET_KEY` in environment variables
- [ ] `ALLOWED_HOSTS` configured
- [ ] HTTPS enabled (`SECURE_SSL_REDIRECT = True`)
- [ ] Secure cookies (`SESSION_COOKIE_SECURE = True`)
- [ ] Security headers configured

**Security Headers:**
```python
SECURE_BROWSER_XSS_FILTER = True
SECURE_CONTENT_TYPE_NOSNIFF = True
X_FRAME_OPTIONS = 'DENY'
SECURE_HSTS_SECONDS = 31536000  # 1 year
SECURE_HSTS_INCLUDE_SUBDOMAINS = True
SECURE_HSTS_PRELOAD = True
```

**Environment Variables:**
```bash
# .env
SECRET_KEY=your-super-secret-key
DEBUG=False
ALLOWED_HOSTS=yourdomain.com,www.yourdomain.com
```

```python
# settings.py
from dotenv import load_dotenv
import os

load_dotenv()

SECRET_KEY = os.environ.get('SECRET_KEY')
DEBUG = os.environ.get('DEBUG') == 'True'
ALLOWED_HOSTS = os.environ.get('ALLOWED_HOSTS', '').split(',')
```

---

## 9.4 Environment Variables

**Why Use Environment Variables?**
- Security: Secrets aren't in code
- Flexibility: Different settings for different environments
- CI/CD: Easy to change without code changes

**Environment Variables Reference:**

| Variable | Purpose | Example |
|----------|---------|---------|
| `SECRET_KEY` | Django secret key | `django-insecure-xyz` |
| `DEBUG` | Debug mode | `False` |
| `ALLOWED_HOSTS` | Allowed domains | `example.com,www.example.com` |
| `DATABASE_URL` | Database connection | `postgresql://user:pass@localhost/db` |
| `EMAIL_HOST` | SMTP server | `smtp.gmail.com` |
| `EMAIL_HOST_USER` | Email user | `your-email@gmail.com` |
| `EMAIL_HOST_PASSWORD` | Email password | `your-app-password` |

---

## 9.5 Exercise: Optimize Your Queries

**Instructions:**
Identify and fix N+1 query problems in your blog application.

**Steps:**
1. Enable query logging
2. Identify N+1 queries
3. Add `select_related` and `prefetch_related`
4. Use `only()` and `defer()`

```python
# Identify N+1 queries
from django.db import connection

connection.queries_log.clear()
posts = Post.objects.all()
for post in posts:
    print(post.author.username)
print(f"Number of queries: {len(connection.queries)}")

# Optimize
posts = Post.objects.select_related('author', 'category').all()
posts = Post.objects.prefetch_related('tags').all()
posts = Post.objects.only('title', 'slug').all()
```

---

**My Additional Notes:**

_________________________________________________

_________________________________________________

_________________________________________________

---

# Part 10: Deployment

## 10.1 Docker

**What is Docker?**
Docker packages your application and all its dependencies into a container.

```
Application → Docker Image → Docker Container → Run Anywhere
```

**Dockerfile:**
```dockerfile
FROM python:3.14-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .

RUN python manage.py collectstatic --noinput

CMD ["gunicorn", "config.wsgi:application", "--bind", "0.0.0.0:8000"]
```

**Building and Running:**
```bash
docker build -t django-blog .
docker run -p 8000:8000 django-blog
```

---

## 10.2 Gunicorn

**What is Gunicorn?**
Gunicorn is a WSGI HTTP server for Python applications.

**Configuration:**
```python
# gunicorn.conf.py
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

**Running Gunicorn:**
```bash
# Development
gunicorn config.wsgi:application --reload

# Production
gunicorn config.wsgi:application --config gunicorn.conf.py
```

---

## 10.3 Nginx

**What is Nginx?**
Nginx is a web server that serves as a reverse proxy for Gunicorn.

```
Browser → Nginx (Port 80/443) → Gunicorn (Port 8000) → Django
```

**Nginx Configuration:**
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

---

## 10.4 Docker Compose

**What is Docker Compose?**
Docker Compose runs multiple containers together.

**docker-compose.yml:**
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
  
  web:
    build: .
    volumes:
      - ./media:/app/media
      - ./staticfiles:/app/staticfiles
    environment:
      - DB_HOST=db
    depends_on:
      - db
  
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

**Running Docker Compose:**
```bash
docker-compose up -d          # Start services
docker-compose down           # Stop services
docker-compose logs -f        # View logs
docker-compose up -d --build  # Rebuild and start
```

---

## 10.5 Exercise: Deploy Your Application

**Instructions:**
Deploy your Django application using Docker, Gunicorn, and Nginx.

**Steps:**
1. Create Dockerfile
2. Create docker-compose.yml
3. Create Nginx config
4. Build and run
5. Test deployment

```bash
# Build and run
docker-compose build
docker-compose up -d

# Test
docker-compose ps
docker-compose logs web
open http://localhost
```

---

**My Additional Notes:**

_________________________________________________

_________________________________________________

_________________________________________________

---

# Appendix A: Command Reference

## Django Commands

```bash
python manage.py runserver              # Start development server
python manage.py runserver 8001         # On different port
python manage.py check                  # Check for issues
python manage.py shell                  # Interactive shell
python manage.py makemigrations         # Create migrations
python manage.py migrate                # Apply migrations
python manage.py showmigrations         # Show migration status
python manage.py sqlmigrate blog 0001   # Show SQL
python manage.py createsuperuser        # Create admin user
python manage.py test                   # Run all tests
python manage.py test blog              # Test specific app
python manage.py collectstatic          # Collect static files
```

## Docker Commands

```bash
docker build -t image_name .            # Build image
docker images                           # List images
docker rmi image_name                   # Remove image
docker run -p 8000:8000 image_name      # Run container
docker ps                               # List running containers
docker ps -a                            # List all containers
docker stop container_id                # Stop container
docker rm container_id                  # Remove container
docker-compose up -d                    # Start services
docker-compose down                     # Stop services
docker-compose logs -f                  # View logs
docker-compose build                    # Rebuild services
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

**Solution:**
```bash
source .venv/bin/activate  # Activate virtual environment
pip install django         # Install Django
```

## Error: "TemplateDoesNotExist at /"

**Solution:**
1. Check template exists at correct path
2. Check `APP_DIRS=True` in settings
3. Check template name in `render()`

## Error: "OperationalError: no such table: blog_post"

**Solution:**
```bash
python manage.py makemigrations
python manage.py migrate
```

## Error: "NoReverseMatch: Reverse for 'home' not found"

**Solution:**
1. Check URL name in `urls.py`
2. Check namespace in template: `{% url 'blog:home' %}`
3. Check `app_name` in `urls.py`

## Error: "CSRF token missing or incorrect"

**Solution:**
```html
<form method="post">
    {% csrf_token %}
    <!-- form fields -->
</form>
```

## Error: "Port 8000 already in use"

**Solution:**
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

# Congratulations!

You've completed the Mastering Django 6 Student Notes! You now have:

1. Comprehensive notes on all Django concepts
2. Completed exercises for each part
3. Reference material for common tasks
4. Troubleshooting guides for common errors
5. Checklists for project completion

**What's Next?**

- Build your own Django project
- Explore Django REST Framework
- Add a frontend framework (React, Vue)
- Contribute to open source Django projects
- Continue learning with the Django documentation

---

**[END OF STUDENT NOTES]**
