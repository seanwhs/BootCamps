# Mastering Django 6: Lab Book

## Full-Stack Web Development with Python

---

# Welcome to Your Lab Book!

This lab book is designed to be your hands-on companion for the Mastering Django 6 series. Unlike the notes (which are for reference) or the workbook (which has structured exercises), this lab book contains:

1. **Practical labs** for each part of the series
2. **Lab-specific code** you'll write and modify
3. **Checkpoints** to verify your work
4. **Troubleshooting logs** to track issues you encounter
5. **Reflection space** to solidify your learning

**How to use this lab book:**
1. For each lab, you'll write code directly in the spaces provided
2. Fill in the blanks and complete the challenges
3. Use the "Lab Log" at the end to track bugs, solutions, and new discoveries
4. This is YOUR book — make it messy, make notes, make it work!

**Pro Tip:** Keep this lab book open alongside your code editor. Write your code here first if it helps you think, or use it to document your code after.

---

# Lab 0: Environment Setup

## Lab Objective

Set up your development environment and verify everything works.

## Task 0.1: Create Project Directory

```bash
# Write the command to create your project directory:
# (Fill in the missing parts)

________ django_blog_project
________ django_blog_project

# Expected result: You should be in the django_blog_project folder
```

**Checkpoint:** ⬜ I am in the correct directory

## Task 0.2: Create Virtual Environment

```bash
# Write the command to create a virtual environment using uv:
________ ________

# Write the command to activate it (macOS/Linux):
________ ________/________/________

# Write the command to activate it (Windows):
________\________\________
```

**Checkpoint:** ⬜ The prompt shows `(.venv)` before my cursor

## Task 0.3: Install Django

```bash
# Write the command to install Django 6:
________ ________ ________==________
```

**Checkpoint:** ⬜ `python -m django --version` shows 6.0

## Task 0.4: Create Requirements File

```bash
# Write the command to save dependencies:
________ ________ > ________
```

**Checkpoint:** ⬜ `requirements.txt` exists in my project folder

---

## Lab 0 Reflection

**What was the most challenging part of setup?**

_________________________________________________

_________________________________________________

**What did you learn?**

_________________________________________________

_________________________________________________

---

# Lab 1: Your First Django Project

## Lab Objective

Create your first Django project, understand its structure, and build a simple website.

## Task 1.1: Create the Project

```bash
# Write the command to create your Django project:
________-________ startproject ________ .
```

**Expected Structure:**
```
django_blog_project/
├── manage.py
├── requirements.txt
├── .venv/
└── config/
    ├── __init__.py
    ├── settings.py
    ├── urls.py
    ├── asgi.py
    └── wsgi.py
```

**Checkpoint:** ⬜ All these files exist

## Task 1.2: Create the Blog App

```bash
# Write the command to create your blog app:
python manage.py ________ blog
```

**Checkpoint:** ⬜ A `blog/` folder exists

## Task 1.3: Register the App

**File: `config/settings.py`** (fill in the missing line)

```python
INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    
    # Custom apps
    '________',  # <-- Add your app here
]
```

**Checkpoint:** ⬜ `python manage.py check` shows no issues

---

## Task 1.4: Create Your First View

**File: `blog/views.py`** (fill in the missing parts)

```python
from django.shortcuts import render
from django.http import HttpResponse

def home(request):
    """Homepage view."""
    context = {
        'page_title': 'Welcome to My Django Blog',
        'welcome_message': 'This is the beginning of your Django journey!',
        'year': 2026,
    }
    return ________(request, 'blog/home.html', context)


def about(request):
    """About page view."""
    context = {
        'page_title': 'About This Blog',
        'description': 'This blog is built using Django 6.',
        'technologies': ['Django 6', 'Python 3.14', 'HTML5', 'CSS3'],
        'year': 2026,
    }
    return render(request, 'blog/about.html', context)


def blog_list(request):
    """Blog listing view."""
    context = {
        'page_title': 'Blog Posts',
        'posts': [],  # Empty for now
        'year': 2026,
    }
    return render(request, 'blog/blog_list.html', context)
```

**Checkpoint:** ⬜ The view functions are defined

## Task 1.5: Create Templates

**File: `blog/templates/blog/base.html`** (fill in the template tags)

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{% ________ title %}Django Blog{% ________ %}</title>
    <style>
        /* CSS here... */
    </style>
</head>
<body>
    <nav>
        <div class="container">
            <a href="{% ________ 'home' %}" class="nav-brand">Django Blog</a>
            <ul class="nav-links">
                <li><a href="{% ________ 'home' %}">Home</a></li>
                <li><a href="{% ________ 'blog_list' %}">Blog</a></li>
                <li><a href="{% ________ 'about' %}">About</a></li>
            </ul>
        </div>
    </nav>
    
    <main>
        <div class="container">
            {% ________ content %}
            <!-- This is where page-specific content goes -->
            {% ________ %}
        </div>
    </main>
    
    <footer>
        <div class="container">
            <p>&copy; {{ ________ }} Django Blog. Built with ❤️ using Django 6.</p>
        </div>
    </footer>
</body>
</html>
```

**File: `blog/templates/blog/home.html`** (fill in the missing parts)

```html
{% ________ 'blog/base.html' %}

{% ________ title %}
    {{ page_title }} — Django Blog
{% ________ %}

{% ________ content %}
<div class="page-header">
    <h1>{{ ________ }}</h1>
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
        <a href="{% ________ 'blog_list' %}" style="color: #3498db; text-decoration: none;">
            View Blog Posts →
        </a>
    </p>
</div>
{% ________ %}
```

**Checkpoint:** ⬜ All template files are created

---

## Task 1.6: Configure URLs

**File: `blog/urls.py`** (fill in the missing parts)

```python
from django.urls import path
from . import views

# Application namespace
app_name = '________'

# URL patterns for the blog app
urlpatterns = [
    path('', views.home, name='________'),
    path('about/', views.about, name='________'),
    path('blog/', views.blog_list, name='________'),
]
```

**File: `config/urls.py`** (fill in the missing parts)

```python
from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path('admin/', admin.site.urls),
    path('', include('________.urls')),
]
```

**Checkpoint:** ⬜ All URLs are configured

## Task 1.7: Run the Server

```bash
# Write the command to run the server:
________ manage.py ________
```

**Checkpoint:** ⬜ The server runs at http://127.0.0.1:8000/

---

## Lab 1 Challenge: Add a Contact Page

**Instructions:** Create a contact page with a view, URL, template, and navigation link.

**View Code:**
```python
# Write your contact view here:

def contact(request):
    context = {
        'page_title': '________',
        'email': '________',
        'phone': '________',
        'address': '________',
    }
    return render(request, 'blog/contact.html', context)
```

**URL Code:**
```python
# Add to blog/urls.py:
path('________/', views.contact, name='________'),
```

**Template Code:**
```html
<!-- Create contact.html -->
{% extends 'blog/base.html' %}

{% block title %}
    {{ ________ }} — Django Blog
{% endblock %}

{% block content %}
    <h1>{{ page_title }}</h1>
    <p>Email: {{ ________ }}</p>
    <p>Phone: {{ ________ }}</p>
    <p>Address: {{ ________ }}</p>
{% endblock %}
```

**Navigation Update:**
```html
<!-- Add to base.html navigation -->
<li><a href="{% ________ 'contact' %}">Contact</a></li>
```

**Checkpoint:** ⬜ The contact page loads and displays correctly

---

## Lab 1 Troubleshooting Log

| Error | Solution |
|-------|----------|
| | |
| | |
| | |

---

## Lab 1 Reflection

**What did you learn about Django's structure?**

_________________________________________________

_________________________________________________

**What was the most confusing part?**

_________________________________________________

_________________________________________________

**What questions do you still have?**

_________________________________________________

_________________________________________________

---

# Lab 2: Models and Databases

## Lab Objective

Design database models, create migrations, use Django Admin, and work with the ORM.

## Task 2.1: Create the Models

**File: `blog/models.py`** (fill in the missing fields)

```python
from django.db import models
from django.contrib.auth.models import User
from django.utils.text import slugify
from django.urls import reverse


class Category(models.Model):
    name = models.CharField(max_length=100, unique=True)
    slug = models.SlugField(max_length=120, unique=True)
    description = models.TextField(blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['name']
        verbose_name_plural = "Categories"

    def save(self, *args, **kwargs):
        if not self.slug:
            self.slug = slugify(self.name)
        super().save(*args, **kwargs)

    def __str__(self):
        return self.name

    def get_absolute_url(self):
        return reverse('blog:category_detail', args=[self.slug])


class Tag(models.Model):
    # Fill in the fields for Tag:
    # name (CharField, max_length=50, unique=True)
    # slug (SlugField, max_length=60, unique=True)
    # created_at (DateTimeField, auto_now_add=True)
    
    ________ = models.CharField(max_length=50, unique=True)
    ________ = models.SlugField(max_length=60, unique=True)
    ________ = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['name']

    def save(self, *args, **kwargs):
        if not self.slug:
            self.slug = slugify(self.name)
        super().save(*args, **kwargs)

    def __str__(self):
        return self.name

    def get_absolute_url(self):
        return reverse('blog:tag_detail', args=[self.slug])


class Post(models.Model):
    class Status(models.TextChoices):
        DRAFT = 'draft', 'Draft'
        PUBLISHED = 'published', 'Published'
        ARCHIVED = 'archived', 'Archived'
    
    # Fill in the fields for Post:
    # title (CharField, max_length=200)
    # slug (SlugField, max_length=220, unique=True)
    # content (TextField)
    # excerpt (TextField, max_length=500, blank=True)
    # author (ForeignKey to User)
    # category (ForeignKey to Category, SET_NULL)
    # tags (ManyToManyField to Tag, blank=True)
    # status (CharField, max_length=10, choices=Status.choices, default=Status.DRAFT)
    # created_at (DateTimeField, auto_now_add=True)
    # updated_at (DateTimeField, auto_now=True)
    # published_at (DateTimeField, null=True, blank=True)
    
    ________ = models.CharField(max_length=200)
    ________ = models.SlugField(max_length=220, unique=True)
    ________ = models.TextField()
    ________ = models.TextField(max_length=500, blank=True)
    ________ = models.ForeignKey(User, on_delete=models.CASCADE, related_name='blog_posts')
    ________ = models.ForeignKey(Category, on_delete=models.SET_NULL, null=True, blank=True, related_name='posts')
    ________ = models.ManyToManyField(Tag, blank=True, related_name='posts')
    ________ = models.CharField(max_length=10, choices=Status.choices, default=Status.DRAFT)
    ________ = models.DateTimeField(auto_now_add=True)
    ________ = models.DateTimeField(auto_now=True)
    ________ = models.DateTimeField(null=True, blank=True)

    class Meta:
        ordering = ['-created_at']

    def save(self, *args, **kwargs):
        if not self.slug:
            self.slug = slugify(self.title)
        if not self.excerpt and self.content:
            self.excerpt = self.content[:200]
        if self.status == self.Status.PUBLISHED and not self.published_at:
            self.published_at = timezone.now()
        super().save(*args, **kwargs)

    def __str__(self):
        return self.title

    def get_absolute_url(self):
        return reverse('blog:post_detail', args=[self.slug])

    def get_comment_count(self):
        return self.comments.filter(is_approved=True).count()

    def is_published(self):
        return self.status == self.Status.PUBLISHED


class Comment(models.Model):
    # Fill in the fields for Comment:
    # post (ForeignKey to Post)
    # author (ForeignKey to User)
    # content (TextField)
    # is_approved (BooleanField, default=False)
    # created_at (DateTimeField, auto_now_add=True)
    # updated_at (DateTimeField, auto_now=True)
    
    ________ = models.ForeignKey(Post, on_delete=models.CASCADE, related_name='comments')
    ________ = models.ForeignKey(User, on_delete=models.CASCADE, related_name='blog_comments')
    ________ = models.TextField()
    ________ = models.BooleanField(default=False)
    ________ = models.DateTimeField(auto_now_add=True)
    ________ = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['created_at']

    def __str__(self):
        return f"Comment by {self.author.username} on {self.post.title}"
```

**Checkpoint:** ⬜ All models are defined

## Task 2.2: Create Migrations

```bash
# Create migration files
python manage.py ________

# Check migration status
python manage.py ________

# Apply migrations
python manage.py ________
```

**Checkpoint:** ⬜ `showmigrations` shows `[X]` for all migrations

## Task 2.3: Create Superuser

```bash
# Create an admin user
python manage.py ________
```

**Credentials:**
- Username: ________
- Email: ________
- Password: ________

**Checkpoint:** ⬜ Can log in to admin at http://127.0.0.1:8000/admin/

---

## Task 2.4: Register Models with Admin

**File: `blog/admin.py`** (fill in the missing parts)

```python
from django.contrib import admin
from django.utils.html import format_html
from .models import Category, Tag, Post, Comment


@admin.register(Category)
class CategoryAdmin(admin.ModelAdmin):
    list_display = ['________', '________', 'post_count', '________']
    list_filter = ['________']
    search_fields = ['________', '________']
    prepopulated_fields = {'slug': ('name',)}
    ordering = ['name']
    
    def post_count(self, obj):
        return obj.posts.count()
    post_count.short_description = 'Number of Posts'


@admin.register(Tag)
class TagAdmin(admin.ModelAdmin):
    list_display = ['________', '________', 'post_count', '________']
    search_fields = ['________']
    prepopulated_fields = {'slug': ('name',)}
    
    def post_count(self, obj):
        return obj.posts.count()
    post_count.short_description = 'Number of Posts'


@admin.register(Post)
class PostAdmin(admin.ModelAdmin):
    list_display = ['________', '________', 'category', '________', 'created_at', 'published_at']
    list_filter = ['status', 'category', 'tags', 'author', 'created_at']
    search_fields = ['title', 'content', 'excerpt', 'author__username']
    prepopulated_fields = {'slug': ('title',)}
    list_editable = ['status']
    ordering = ['-created_at']
    
    fieldsets = (
        ('Basic Information', {
            'fields': ('title', 'slug', 'author', 'category')
        }),
        ('Content', {
            'fields': ('content', 'excerpt', 'featured_image')
        }),
        ('Taxonomy', {
            'fields': ('tags',),
            'classes': ('collapse',)
        }),
        ('Status & Dates', {
            'fields': ('status', 'created_at', 'updated_at', 'published_at'),
            'classes': ('collapse',)
        }),
    )
    readonly_fields = ['created_at', 'updated_at', 'published_at']


@admin.register(Comment)
class CommentAdmin(admin.ModelAdmin):
    list_display = ['author', 'post', 'is_approved', 'created_at']
    list_filter = ['is_approved', 'created_at', 'post']
    search_fields = ['author__username', 'content', 'post__title']
    list_editable = ['is_approved']
    ordering = ['-created_at']
```

**Checkpoint:** ⬜ Models are registered in admin

## Task 2.5: Create Test Data

**Use the admin interface or shell to create:**

**Categories:**
1. Technology
2. Python
3. Web Development

**Tags:**
1. django
2. python
3. web
4. tutorial

**Post:**
- Title: "My First Blog Post"
- Author: admin
- Category: Technology
- Tags: django, python
- Status: Published
- Content: "This is my first blog post content..."

**Checkpoint:** ⬜ Test data is created

---

## Task 2.6: Update Views to Use Database

**File: `blog/views.py`** (update the views)

```python
from django.shortcuts import render, get_object_or_404
from django.db.models import Q, Count
from django.utils import timezone
from .models import Post, Category, Tag, Comment


def home(request):
    # Get 5 most recent published posts
    recent_posts = Post.objects.filter(
        status=Post.Status.PUBLISHED,
        published_at__lte=timezone.now()
    ).order_by('-published_at')[:5]
    
    # Get categories with post counts
    categories = Category.objects.annotate(
        post_count=Count('posts', filter=Q(posts__status=Post.Status.PUBLISHED))
    ).filter(post_count__gt=0)
    
    context = {
        'recent_posts': recent_posts,
        'categories': categories,
        'year': timezone.now().year,
    }
    return render(request, 'blog/home.html', context)


def blog_list(request):
    posts = Post.objects.filter(
        status=Post.Status.PUBLISHED,
        published_at__lte=timezone.now()
    ).select_related('author', 'category')
    
    context = {
        'page_title': 'Blog Posts',
        'posts': posts,
        'year': timezone.now().year,
    }
    return render(request, 'blog/blog_list.html', context)


def post_detail(request, slug):
    post = get_object_or_404(
        Post.objects.select_related('author', 'category').prefetch_related('tags'),
        slug=slug,
        status=Post.Status.PUBLISHED
    )
    
    recent_posts = Post.objects.filter(
        status=Post.Status.PUBLISHED
    ).exclude(id=post.id).order_by('-published_at')[:5]
    
    context = {
        'post': post,
        'recent_posts': recent_posts,
        'year': timezone.now().year,
    }
    return render(request, 'blog/post_detail.html', context)


def category_detail(request, slug):
    category = get_object_or_404(Category, slug=slug)
    
    posts = Post.objects.filter(
        category=category,
        status=Post.Status.PUBLISHED,
        published_at__lte=timezone.now()
    ).select_related('author').order_by('-published_at')
    
    context = {
        'category': category,
        'posts': posts,
        'year': timezone.now().year,
    }
    return render(request, 'blog/category_detail.html', context)


def tag_detail(request, slug):
    tag = get_object_or_404(Tag, slug=slug)
    
    posts = Post.objects.filter(
        tags=tag,
        status=Post.Status.PUBLISHED,
        published_at__lte=timezone.now()
    ).select_related('author', 'category').order_by('-published_at')
    
    context = {
        'tag': tag,
        'posts': posts,
        'year': timezone.now().year,
    }
    return render(request, 'blog/tag_detail.html', context)
```

**Checkpoint:** ⬜ Views are updated to use the database

---

## Task 2.7: Update URLs

**File: `blog/urls.py`** (add the detail URLs)

```python
urlpatterns = [
    path('', views.home, name='home'),
    path('about/', views.about, name='about'),
    path('blog/', views.blog_list, name='blog_list'),
    path('blog/<slug:slug>/', views.post_detail, name='post_detail'),
    path('category/<slug:slug>/', views.category_detail, name='category_detail'),
    path('tag/<slug:slug>/', views.tag_detail, name='tag_detail'),
]
```

**Checkpoint:** ⬜ Detail URLs are configured

---

## Lab 2 Challenge: Add Author Bio

**Instructions:** Extend the User model with a Profile model that includes bio, location, and avatar.

**Profile Model:**
```python
# Add to blog/models.py
from django.db.models.signals import post_save
from django.dispatch import receiver

class Profile(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='profile')
    bio = models.TextField(max_length=500, blank=True)
    location = models.CharField(max_length=100, blank=True)
    avatar = models.ImageField(upload_to='avatars/', blank=True)
    website = models.URLField(blank=True)
    
    def __str__(self):
        return f"{self.user.username}'s Profile"
    
    def get_avatar_url(self):
        if self.avatar:
            return self.avatar.url
        return '/static/blog/images/default-avatar.png'

# Signal to auto-create profile
@receiver(post_save, sender=User)
def create_user_profile(sender, instance, created, **kwargs):
    if created:
        Profile.objects.create(user=instance)

@receiver(post_save, sender=User)
def save_user_profile(sender, instance, **kwargs):
    instance.profile.save()
```

**Checkpoint:** ⬜ Profile model works and auto-creates

---

## Lab 2 Troubleshooting Log

| Error | Solution |
|-------|----------|
| | |
| | |
| | |

---

## Lab 2 Reflection

**What did you learn about database design?**

_________________________________________________

_________________________________________________

**What was the most challenging part of migrations?**

_________________________________________________

_________________________________________________

**What questions do you still have about the ORM?**

_________________________________________________

_________________________________________________

---

# Lab 3: Forms and CRUD

## Lab Objective

Build forms, implement CRUD operations, and handle user authentication.

## Task 3.1: Create Forms

**File: `blog/forms.py`** (fill in the missing parts)

```python
from django import forms
from django.core.exceptions import ValidationError
from django.utils.text import slugify
from .models import Post, Comment, Category, Tag


class PostForm(forms.ModelForm):
    # Add a tags_input field (CharField, required=False)
    ________ = forms.CharField(required=False, help_text="Enter tags separated by commas")
    
    class Meta:
        model = Post
        fields = ['title', 'slug', 'category', 'content', 'excerpt', 'status']
        widgets = {
            'title': forms.TextInput(attrs={'class': 'form-control'}),
            'slug': forms.TextInput(attrs={'class': 'form-control'}),
            'category': forms.Select(attrs={'class': 'form-control'}),
            'content': forms.Textarea(attrs={'class': 'form-control', 'rows': 10}),
            'excerpt': forms.Textarea(attrs={'class': 'form-control', 'rows': 3}),
            'status': forms.Select(attrs={'class': 'form-control'}),
        }
        help_texts = {
            'slug': 'Leave blank to auto-generate from title.',
        }
    
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.fields['slug'].required = False
        self.fields['status'].initial = Post.Status.DRAFT
    
    def clean_slug(self):
        slug = self.cleaned_data.get('slug')
        title = self.cleaned_data.get('title')
        
        if not slug and title:
            slug = slugify(title)
        
        if slug:
            instance_id = self.instance.id if self.instance else None
            if Post.objects.filter(slug=slug).exclude(id=instance_id).exists():
                raise ValidationError(f'A post with the slug "{slug}" already exists.')
        
        return slug
    
    def save(self, commit=True):
        instance = super().save(commit=False)
        
        tags_input = self.cleaned_data.get('tags_input', '')
        
        if commit:
            instance.save()
            
            if tags_input:
                tag_names = [tag.strip().lower() for tag in tags_input.split(',') if tag.strip()]
                instance.tags.clear()
                for tag_name in tag_names:
                    tag, created = Tag.objects.get_or_create(
                        name=tag_name,
                        defaults={'slug': slugify(tag_name)}
                    )
                    instance.tags.add(tag)
        
        return instance


class CommentForm(forms.ModelForm):
    class Meta:
        model = Comment
        fields = ['content']
        widgets = {
            'content': forms.Textarea(attrs={'class': 'form-control', 'rows': 4})
        }
```

**Checkpoint:** ⬜ Forms are defined

---

## Task 3.2: Create CRUD Views

**File: `blog/views.py`** (add these views)

```python
from django.contrib.auth.decorators import login_required
from django.contrib import messages
from django.shortcuts import redirect
from .forms import PostForm, CommentForm


@login_required
def post_create(request):
    if request.method == 'POST':
        form = PostForm(request.POST, request.FILES)
        if form.is_valid():
            post = form.save(commit=False)
            post.author = request.user
            if post.status == Post.Status.PUBLISHED:
                post.published_at = timezone.now()
            post.save()
            form.save_m2m()
            messages.success(request, f'Your post "{post.title}" has been created!')
            return redirect('blog:post_detail', slug=post.slug)
        else:
            messages.error(request, 'Please correct the errors below.')
    else:
        form = PostForm()
    
    context = {
        'form': form,
        'title': 'Create New Post',
        'submit_text': 'Create Post',
    }
    return render(request, 'blog/post_form.html', context)


@login_required
def post_edit(request, slug):
    post = get_object_or_404(Post, slug=slug)
    
    if post.author != request.user:
        messages.error(request, 'You do not have permission to edit this post.')
        return redirect('blog:post_detail', slug=post.slug)
    
    if request.method == 'POST':
        form = PostForm(request.POST, request.FILES, instance=post)
        if form.is_valid():
            updated_post = form.save(commit=False)
            if updated_post.status == Post.Status.PUBLISHED and post.status != Post.Status.PUBLISHED:
                updated_post.published_at = timezone.now()
            updated_post.save()
            form.save_m2m()
            messages.success(request, f'Your post "{updated_post.title}" has been updated!')
            return redirect('blog:post_detail', slug=updated_post.slug)
        else:
            messages.error(request, 'Please correct the errors below.')
    else:
        form = PostForm(instance=post)
        if post.tags.exists():
            tags_list = [tag.name for tag in post.tags.all()]
            form.fields['tags_input'].initial = ', '.join(tags_list)
    
    context = {
        'form': form,
        'title': f'Edit Post: {post.title}',
        'submit_text': 'Update Post',
        'post': post,
    }
    return render(request, 'blog/post_form.html', context)


@login_required
def post_delete(request, slug):
    post = get_object_or_404(Post, slug=slug)
    
    if post.author != request.user:
        messages.error(request, 'You do not have permission to delete this post.')
        return redirect('blog:post_detail', slug=post.slug)
    
    if request.method == 'POST':
        post_title = post.title
        post.delete()
        messages.success(request, f'Your post "{post_title}" has been deleted.')
        return redirect('blog:blog_list')
    
    context = {'post': post}
    return render(request, 'blog/post_confirm_delete.html', context)


@login_required
def comment_create(request, post_slug):
    post = get_object_or_404(Post, slug=post_slug, status=Post.Status.PUBLISHED)
    
    if request.method == 'POST':
        form = CommentForm(request.POST)
        if form.is_valid():
            comment = form.save(commit=False)
            comment.post = post
            comment.author = request.user
            comment.save()
            messages.success(request, 'Your comment has been added.')
        else:
            messages.error(request, 'Please enter a valid comment.')
    
    return redirect('blog:post_detail', slug=post.slug)
```

**Checkpoint:** ⬜ CRUD views are defined

---

## Task 3.3: Create Templates

**File: `blog/templates/blog/post_form.html`** (fill in the missing parts)

```html
{% extends 'blog/base.html' %}

{% block title %}
    {{ title }} — Django Blog
{% endblock %}

{% block content %}
<div class="page-header">
    <h1>{{ title }}</h1>
</div>

<div class="content">
    <form method="post" enctype="multipart/form-data" novalidate>
        {% ________ %}
        
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
        
        <button type="submit">{{ submit_text }}</button>
        {% if post %}
            <a href="{% url 'blog:post_detail' post.slug %}">Cancel</a>
        {% else %}
            <a href="{% url 'blog:blog_list' %}">Cancel</a>
        {% endif %}
    </form>
</div>
{% endblock %}
```

**File: `blog/templates/blog/post_confirm_delete.html`**

```html
{% extends 'blog/base.html' %}

{% block title %}
    Delete Post — Django Blog
{% endblock %}

{% block content %}
<div class="page-header">
    <h1>Delete Post</h1>
</div>

<div class="content" style="text-align: center;">
    <p>Are you sure you want to delete the post <strong>"{{ post.title }}"</strong>?</p>
    <p style="color: #e74c3c;"><strong>Warning:</strong> This action cannot be undone.</p>
    
    <form method="post">
        {% csrf_token %}
        <button type="submit">Yes, Delete This Post</button>
        <a href="{% url 'blog:post_detail' post.slug %}">No, Take Me Back</a>
    </form>
</div>
{% endblock %}
```

**Checkpoint:** ⬜ Templates are created

---

## Task 3.4: Update URLs

**File: `blog/urls.py`** (add CRUD URLs)

```python
urlpatterns = [
    # Public views
    path('', views.home, name='home'),
    path('about/', views.about, name='about'),
    path('blog/', views.blog_list, name='blog_list'),
    path('blog/<slug:slug>/', views.post_detail, name='post_detail'),
    path('category/<slug:slug>/', views.category_detail, name='category_detail'),
    path('tag/<slug:slug>/', views.tag_detail, name='tag_detail'),
    
    # CRUD views
    path('post/create/', views.post_create, name='post_create'),
    path('post/<slug:slug>/edit/', views.post_edit, name='post_edit'),
    path('post/<slug:slug>/delete/', views.post_delete, name='post_delete'),
    
    # Comment views
    path('post/<slug:post_slug>/comment/', views.comment_create, name='comment_create'),
]
```

**Checkpoint:** ⬜ CRUD URLs are configured

---

## Task 3.5: Set Up Authentication

**File: `config/settings.py`** (add)

```python
LOGIN_URL = 'login'
LOGIN_REDIRECT_URL = 'blog:home'
LOGOUT_REDIRECT_URL = 'blog:home'
```

**File: `blog/views.py`** (add registration view)

```python
from django.contrib.auth.forms import UserCreationForm
from django.contrib.auth import login

def register(request):
    if request.method == 'POST':
        form = UserCreationForm(request.POST)
        if form.is_valid():
            user = form.save()
            login(request, user)
            messages.success(request, f'Welcome, {user.username}!')
            return redirect('blog:home')
    else:
        form = UserCreationForm()
    return render(request, 'registration/register.html', {'form': form})
```

**File: `blog/urls.py`** (add auth URLs)

```python
from django.contrib.auth import views as auth_views

urlpatterns = [
    # ... existing URLs ...
    
    # Authentication views
    path('login/', auth_views.LoginView.as_view(), name='login'),
    path('logout/', auth_views.LogoutView.as_view(), name='logout'),
    path('register/', views.register, name='register'),
]
```

**Checkpoint:** ⬜ Authentication is set up

---

## Lab 3 Challenge: Add Comment Moderation

**Instructions:** Add a moderation system for comments. Use the `is_approved` field and create a moderation view.

**View:**
```python
# Add to views.py
@login_required
def moderate_comments(request):
    pending_comments = Comment.objects.filter(is_approved=False).select_related('post', 'author')
    return render(request, 'blog/moderate_comments.html', {'comments': pending_comments})

@login_required
def approve_comment(request, comment_id):
    comment = get_object_or_404(Comment, id=comment_id)
    comment.is_approved = True
    comment.save()
    messages.success(request, 'Comment approved!')
    return redirect('blog:moderate_comments')

@login_required
def delete_comment(request, comment_id):
    comment = get_object_or_404(Comment, id=comment_id)
    comment.delete()
    messages.success(request, 'Comment deleted!')
    return redirect('blog:moderate_comments')
```

**Checkpoint:** ⬜ Comment moderation works

---

## Lab 3 Troubleshooting Log

| Error | Solution |
|-------|----------|
| | |
| | |
| | |

---

## Lab 3 Reflection

**What did you learn about forms and CRUD?**

_________________________________________________

_________________________________________________

**What was the most challenging part of implementing CRUD?**

_________________________________________________

_________________________________________________

**What questions do you still have about forms?**

_________________________________________________

_________________________________________________

---

# Lab 4: Class-Based Views

## Lab Objective

Refactor function-based views to class-based views and implement search, filtering, and pagination.

## Task 4.1: Refactor to ListView

**File: `blog/views.py`** (replace blog_list with this)

```python
from django.views.generic import ListView, DetailView, CreateView, UpdateView, DeleteView
from django.contrib.auth.mixins import LoginRequiredMixin, UserPassesTestMixin
from django.urls import reverse_lazy
from django.db.models import Q, Count


class PostListView(ListView):
    model = Post
    template_name = 'blog/blog_list.html'
    context_object_name = 'posts'
    paginate_by = 10
    ordering = ['-published_at']
    
    def get_queryset(self):
        queryset = super().get_queryset().filter(
            status=Post.Status.PUBLISHED,
            published_at__lte=timezone.now()
        ).select_related('author', 'category').prefetch_related('tags')
        
        search_query = self.request.GET.get('q')
        if search_query:
            queryset = queryset.filter(
                Q(title__icontains=search_query) |
                Q(content__icontains=search_query) |
                Q(excerpt__icontains=search_query)
            )
        
        category_slug = self.request.GET.get('category')
        if category_slug:
            queryset = queryset.filter(category__slug=category_slug)
        
        return queryset
    
    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        categories = Category.objects.annotate(
            post_count=Count('posts', filter=Q(posts__status=Post.Status.PUBLISHED))
        ).filter(post_count__gt=0)
        context['categories'] = categories
        context['page_title'] = 'Blog Posts'
        context['current_filters'] = {
            'q': self.request.GET.get('q', ''),
            'category': self.request.GET.get('category', ''),
        }
        return context
```

**Checkpoint:** ⬜ ListView works

---

## Task 4.2: Refactor to DetailView

```python
class PostDetailView(DetailView):
    model = Post
    template_name = 'blog/post_detail.html'
    context_object_name = 'post'
    slug_field = 'slug'
    slug_url_kwarg = 'slug'
    
    def get_queryset(self):
        queryset = super().get_queryset()
        if self.request.user.is_authenticated:
            return queryset.filter(
                Q(status=Post.Status.PUBLISHED) |
                Q(author=self.request.user)
            )
        return queryset.filter(status=Post.Status.PUBLISHED)
    
    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        post = self.get_object()
        context['recent_posts'] = Post.objects.filter(
            status=Post.Status.PUBLISHED
        ).exclude(id=post.id).order_by('-published_at')[:5]
        context['comments'] = post.comments.filter(is_approved=True).order_by('created_at')
        return context
```

**Checkpoint:** ⬜ DetailView works

---

## Task 4.3: Refactor CRUD to CreateView

```python
class PostCreateView(LoginRequiredMixin, CreateView):
    model = Post
    form_class = PostForm
    template_name = 'blog/post_form.html'
    
    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        context['title'] = 'Create New Post'
        context['submit_text'] = 'Create Post'
        return context
    
    def form_valid(self, form):
        form.instance.author = self.request.user
        if form.instance.status == Post.Status.PUBLISHED:
            form.instance.published_at = timezone.now()
        messages.success(self.request, f'Your post "{form.instance.title}" has been created!')
        return super().form_valid(form)
    
    def get_success_url(self):
        return reverse_lazy('blog:post_detail', kwargs={'slug': self.object.slug})
```

**Checkpoint:** ⬜ CreateView works

---

## Task 4.4: Refactor to UpdateView

```python
class PostUpdateView(LoginRequiredMixin, UserPassesTestMixin, UpdateView):
    model = Post
    form_class = PostForm
    template_name = 'blog/post_form.html'
    slug_field = 'slug'
    slug_url_kwarg = 'slug'
    
    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        context['title'] = f'Edit Post: {self.object.title}'
        context['submit_text'] = 'Update Post'
        if self.object.tags.exists():
            tags_list = [tag.name for tag in self.object.tags.all()]
            context['form'].fields['tags_input'].initial = ', '.join(tags_list)
        return context
    
    def form_valid(self, form):
        old_status = self.get_object().status
        new_status = form.instance.status
        if new_status == Post.Status.PUBLISHED and old_status != Post.Status.PUBLISHED:
            form.instance.published_at = timezone.now()
        messages.success(self.request, f'Your post "{form.instance.title}" has been updated!')
        return super().form_valid(form)
    
    def test_func(self):
        post = self.get_object()
        return self.request.user == post.author
    
    def get_success_url(self):
        return reverse_lazy('blog:post_detail', kwargs={'slug': self.object.slug})
```

**Checkpoint:** ⬜ UpdateView works

---

## Task 4.5: Refactor to DeleteView

```python
class PostDeleteView(LoginRequiredMixin, UserPassesTestMixin, DeleteView):
    model = Post
    template_name = 'blog/post_confirm_delete.html'
    slug_field = 'slug'
    slug_url_kwarg = 'slug'
    success_url = reverse_lazy('blog:blog_list')
    
    def test_func(self):
        post = self.get_object()
        return self.request.user == post.author
    
    def delete(self, request, *args, **kwargs):
        post = self.get_object()
        messages.success(request, f'Your post "{post.title}" has been deleted.')
        return super().delete(request, *args, **kwargs)
```

**Checkpoint:** ⬜ DeleteView works

---

## Task 4.6: Update URLs

**File: `blog/urls.py`** (update to use CBVs)

```python
urlpatterns = [
    # Public views (now class-based)
    path('', views.PostListView.as_view(), name='blog_list'),
    path('blog/<slug:slug>/', views.PostDetailView.as_view(), name='post_detail'),
    # ... other URLs ...
    
    # CRUD views (now class-based)
    path('post/create/', views.PostCreateView.as_view(), name='post_create'),
    path('post/<slug:slug>/edit/', views.PostUpdateView.as_view(), name='post_edit'),
    path('post/<slug:slug>/delete/', views.PostDeleteView.as_view(), name='post_delete'),
]
```

**Checkpoint:** ⬜ URLs are updated

---

## Lab 4 Challenge: Add Pagination Template

**Instructions:** Add pagination controls to the blog_list.html template.

**Template Code:**
```html
<!-- Add after the post loop -->
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
```

**Checkpoint:** ⬜ Pagination appears and works

---

## Lab 4 Troubleshooting Log

| Error | Solution |
|-------|----------|
| | |
| | |
| | |

---

## Lab 4 Reflection

**What did you learn about class-based views?**

_________________________________________________

_________________________________________________

**What was the most confusing part of CBVs?**

_________________________________________________

_________________________________________________

**What questions do you still have about CBVs?**

_________________________________________________

_________________________________________________

---

# Lab 5: Authentication and Users

## Lab Objective

Implement user profiles, dashboards, and password management.

## Task 5.1: Create Profile Model

**Add to `blog/models.py`:**

```python
class Profile(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='profile')
    bio = models.TextField(max_length=500, blank=True)
    location = models.CharField(max_length=100, blank=True)
    avatar = models.ImageField(upload_to='avatars/%Y/%m/%d/', blank=True)
    website = models.URLField(blank=True)
    twitter = models.CharField(max_length=50, blank=True)
    github = models.CharField(max_length=50, blank=True)
    
    def __str__(self):
        return f"{self.user.username}'s Profile"
    
    def get_avatar_url(self):
        if self.avatar:
            return self.avatar.url
        return '/static/blog/images/default-avatar.png'

# Signals
@receiver(post_save, sender=User)
def create_user_profile(sender, instance, created, **kwargs):
    if created:
        Profile.objects.create(user=instance)

@receiver(post_save, sender=User)
def save_user_profile(sender, instance, **kwargs):
    instance.profile.save()
```

**Checkpoint:** ⬜ Profile model exists

---

## Task 5.2: Create Profile Form

**File: `blog/forms.py`** (add ProfileForm)

```python
class ProfileForm(forms.ModelForm):
    class Meta:
        model = Profile
        fields = ['bio', 'location', 'avatar', 'website', 'twitter', 'github']
        widgets = {
            'bio': forms.Textarea(attrs={'class': 'form-control', 'rows': 5}),
            'location': forms.TextInput(attrs={'class': 'form-control'}),
            'website': forms.URLInput(attrs={'class': 'form-control'}),
            'twitter': forms.TextInput(attrs={'class': 'form-control'}),
            'github': forms.TextInput(attrs={'class': 'form-control'}),
            'avatar': forms.FileInput(attrs={'class': 'form-control'}),
        }
```

**Checkpoint:** ⬜ ProfileForm exists

---

## Task 5.3: Create Profile Views

**File: `blog/views.py`** (add)

```python
from django.views.generic import DetailView
from django.contrib.auth.models import User
from .forms import ProfileForm
from .models import Profile

class ProfileDetailView(DetailView):
    model = User
    template_name = 'blog/profile_detail.html'
    context_object_name = 'profile_user'
    slug_field = 'username'
    slug_url_kwarg = 'username'
    
    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        user = self.get_object()
        posts = Post.objects.filter(
            author=user,
            status=Post.Status.PUBLISHED
        ).order_by('-published_at')[:10]
        context['posts'] = posts
        context['post_count'] = user.blog_posts.filter(status=Post.Status.PUBLISHED).count()
        context['comment_count'] = Comment.objects.filter(author=user, is_approved=True).count()
        return context

@login_required
def profile_edit(request):
    profile, created = Profile.objects.get_or_create(user=request.user)
    
    if request.method == 'POST':
        form = ProfileForm(request.POST, request.FILES, instance=profile)
        if form.is_valid():
            form.save()
            messages.success(request, 'Profile updated!')
            return redirect('blog:profile_detail', username=request.user.username)
    else:
        form = ProfileForm(instance=profile)
    
    return render(request, 'blog/profile_edit.html', {'form': form})

@login_required
def dashboard(request):
    user = request.user
    posts = Post.objects.filter(author=user)
    
    context = {
        'total_posts': posts.count(),
        'published_posts': posts.filter(status=Post.Status.PUBLISHED).count(),
        'draft_posts': posts.filter(status=Post.Status.DRAFT).count(),
        'recent_posts': posts.order_by('-created_at')[:5],
        'comments': Comment.objects.filter(author=user).order_by('-created_at')[:5],
    }
    return render(request, 'blog/dashboard.html', context)
```

**Checkpoint:** ⬜ Profile views exist

---

## Task 5.4: Create Profile Templates

**File: `blog/templates/blog/profile_detail.html`**

```html
{% extends 'blog/base.html' %}

{% block title %}
    {{ profile_user.get_full_name|default:profile_user.username }} — Django Blog
{% endblock %}

{% block content %}
<div class="page-header">
    <h1>{{ profile_user.get_full_name|default:profile_user.username }}</h1>
</div>

<div style="display: grid; grid-template-columns: 1fr 2fr; gap: 2rem;">
    <div>
        <img src="{{ profile_user.profile.get_avatar_url }}" 
             alt="{{ profile_user.username }}" 
             style="width: 150px; height: 150px; border-radius: 50%;">
        
        {% if profile_user.profile.bio %}
            <h3>About</h3>
            <p>{{ profile_user.profile.bio }}</p>
        {% endif %}
        
        {% if profile_user.profile.location %}
            <p>📍 {{ profile_user.profile.location }}</p>
        {% endif %}
        
        <div class="stats">
            <p>Posts: {{ post_count }}</p>
            <p>Comments: {{ comment_count }}</p>
        </div>
        
        {% if user == profile_user %}
            <a href="{% url 'blog:profile_edit' %}">Edit Profile</a>
        {% endif %}
    </div>
    
    <div>
        <h2>Recent Posts</h2>
        {% for post in posts %}
            <div>
                <h3><a href="{{ post.get_absolute_url }}">{{ post.title }}</a></h3>
                <p>{{ post.published_at|date:"F j, Y" }}</p>
            </div>
        {% empty %}
            <p>No posts yet.</p>
        {% endfor %}
    </div>
</div>
{% endblock %}
```

**Checkpoint:** ⬜ Profile templates exist

---

## Task 5.5: Update URLs

**File: `blog/urls.py`** (add)

```python
urlpatterns = [
    # ... existing URLs ...
    
    # Profile views
    path('profile/<str:username>/', views.ProfileDetailView.as_view(), name='profile_detail'),
    path('profile/edit/', views.profile_edit, name='profile_edit'),
    path('dashboard/', views.dashboard, name='dashboard'),
    
    # Password management
    path('password-change/', auth_views.PasswordChangeView.as_view(
        template_name='registration/password_change_form.html',
        success_url='/password-change/done/'
    ), name='password_change'),
    path('password-change/done/', auth_views.PasswordChangeDoneView.as_view(
        template_name='registration/password_change_done.html'
    ), name='password_change_done'),
    # ... password reset URLs ...
]
```

**Checkpoint:** ⬜ Profile URLs work

---

## Lab 5 Challenge: Add User Dashboard

**Instructions:** Enhance the dashboard with more statistics and recent activity.

**Dashboard Template:**
```html
{% extends 'blog/base.html' %}

{% block content %}
    <h1>Dashboard</h1>
    
    <div style="display: grid; grid-template-columns: repeat(4, 1fr); gap: 1rem;">
        <div class="stat-card">
            <h3>{{ total_posts }}</h3>
            <p>Total Posts</p>
        </div>
        <div class="stat-card">
            <h3>{{ published_posts }}</h3>
            <p>Published</p>
        </div>
        <div class="stat-card">
            <h3>{{ draft_posts }}</h3>
            <p>Drafts</p>
        </div>
        <div class="stat-card">
            <h3>{{ comments|length }}</h3>
            <p>Recent Comments</p>
        </div>
    </div>
    
    <h2>Recent Posts</h2>
    <!-- list posts -->
    
    <h2>Recent Comments</h2>
    <!-- list comments -->
    
    <a href="{% url 'blog:post_create' %}">+ New Post</a>
{% endblock %}
```

**Checkpoint:** ⬜ Dashboard displays correctly

---

## Lab 5 Troubleshooting Log

| Error | Solution |
|-------|----------|
| | |
| | |
| | |

---

## Lab 5 Reflection

**What did you learn about authentication and profiles?**

_________________________________________________

_________________________________________________

**What was the most challenging part of user management?**

_________________________________________________

_________________________________________________

**What questions do you still have about authentication?**

_________________________________________________

_________________________________________________

---

# Lab 6: Advanced Architecture

## Lab Objective

Implement middleware, context processors, signals, and a service layer.

## Task 6.1: Create Middleware

**File: `blog/middleware.py`** (create new)

```python
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
        logger.info(f"{request.method} {request.path} - {duration:.3f}s - {response.status_code}")
        return response

class SecurityHeadersMiddleware:
    def __init__(self, get_response):
        self.get_response = get_response
    
    def __call__(self, request):
        response = self.get_response(request)
        response['X-Content-Type-Options'] = 'nosniff'
        response['X-Frame-Options'] = 'DENY'
        response['X-XSS-Protection'] = '1; mode=block'
        return response
```

**Register Middleware:**
```python
# settings.py
MIDDLEWARE = [
    # ... built-in ...
    'blog.middleware.RequestLoggingMiddleware',
    'blog.middleware.SecurityHeadersMiddleware',
]
```

**Checkpoint:** ⬜ Middleware works

---

## Task 6.2: Create Context Processor

**File: `blog/context_processors.py`** (create new)

```python
from datetime import datetime
from .models import Category

def global_context(request):
    return {
        'current_year': datetime.now().year,
        'site_name': 'Django Blog',
        'categories_nav': Category.objects.filter(posts__isnull=False).distinct(),
        'is_authenticated': request.user.is_authenticated,
    }
```

**Register Context Processor:**
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

**Checkpoint:** ⬜ Context processor works

---

## Task 6.3: Create Signals

**File: `blog/signals.py`** (create new)

```python
from django.db.models.signals import post_save
from django.contrib.auth.models import User
from django.dispatch import receiver
from django.core.mail import send_mail
from django.conf import settings
from .models import Profile, Post

@receiver(post_save, sender=User)
def send_welcome_email(sender, instance, created, **kwargs):
    if created and instance.email:
        send_mail(
            'Welcome to Django Blog!',
            f'Hello {instance.username}, welcome to Django Blog!',
            settings.DEFAULT_FROM_EMAIL,
            [instance.email],
            fail_silently=True,
        )

@receiver(post_save, sender=Post)
def notify_post_published(sender, instance, created, **kwargs):
    if not created:
        try:
            old = Post.objects.get(id=instance.id)
            if old.status != Post.Status.PUBLISHED and instance.status == Post.Status.PUBLISHED:
                send_mail(
                    f'Your post "{instance.title}" is published!',
                    f'Your post is now live!',
                    settings.DEFAULT_FROM_EMAIL,
                    [instance.author.email],
                    fail_silently=True,
                )
        except Post.DoesNotExist:
            pass
```

**Register Signals:**
```python
# apps.py
class BlogConfig(AppConfig):
    def ready(self):
        import blog.signals  # noqa
```

**Checkpoint:** ⬜ Signals work

---

## Task 6.4: Create Service Layer

**File: `blog/services/post_service.py`** (create new)

```python
from django.core.exceptions import ValidationError, PermissionDenied
from django.utils import timezone
from ..models import Post, Tag
from ..forms import PostForm

class PostService:
    @staticmethod
    def create_post(data, author):
        form = PostForm(data)
        if not form.is_valid():
            raise ValidationError(form.errors)
        
        post = form.save(commit=False)
        post.author = author
        
        if post.status == Post.Status.PUBLISHED:
            post.published_at = timezone.now()
        
        post.save()
        form.save_m2m()
        return post
    
    @staticmethod
    def update_post(post, data, user):
        if post.author != user:
            raise PermissionDenied("You don't have permission to edit this post.")
        
        form = PostForm(data, instance=post)
        if not form.is_valid():
            raise ValidationError(form.errors)
        
        updated_post = form.save(commit=False)
        if updated_post.status == Post.Status.PUBLISHED and post.status != Post.Status.PUBLISHED:
            updated_post.published_at = timezone.now()
        
        updated_post.save()
        form.save_m2m()
        return updated_post
    
    @staticmethod
    def delete_post(post, user):
        if post.author != user:
            raise PermissionDenied("You don't have permission to delete this post.")
        post.delete()
        return True
    
    @staticmethod
    def get_user_stats(user):
        posts = Post.objects.filter(author=user)
        return {
            'total': posts.count(),
            'published': posts.filter(status=Post.Status.PUBLISHED).count(),
            'draft': posts.filter(status=Post.Status.DRAFT).count(),
            'archived': posts.filter(status=Post.Status.ARCHIVED).count(),
        }
```

**Checkpoint:** ⬜ Service layer exists

---

## Lab 6 Challenge: Add Maintenance Mode Middleware

**Instructions:** Create a maintenance mode middleware that shows a maintenance page when enabled.

**Solution:**
```python
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

**Checkpoint:** ⬜ Maintenance mode works

---

## Lab 6 Troubleshooting Log

| Error | Solution |
|-------|----------|
| | |
| | |
| | |

---

## Lab 6 Reflection

**What did you learn about Django's architecture?**

_________________________________________________

_________________________________________________

**What was the most challenging part of implementing middleware?**

_________________________________________________

_________________________________________________

**What questions do you still have about architecture?**

_________________________________________________

_________________________________________________

---

# Lab 7: Real-World Features

## Lab Objective

Implement file uploads, email, sessions, and database transactions.

## Task 7.1: Configure Media Files

**File: `config/settings.py`** (add)

```python
MEDIA_URL = '/media/'
MEDIA_ROOT = BASE_DIR / 'media'
```

**File: `config/urls.py`** (add for development)

```python
from django.conf import settings
from django.conf.urls.static import static

if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
```

**Checkpoint:** ⬜ Media files are configured

---

## Task 7.2: Update Models with ImageField

**File: `blog/models.py`** (update Post model)

```python
class Post(models.Model):
    # ... existing fields ...
    featured_image = models.ImageField(
        upload_to='posts/%Y/%m/%d/',
        blank=True,
        null=True,
        help_text="Optional featured image for the post"
    )
```

**Create migration:**
```bash
python manage.py makemigrations blog
python manage.py migrate blog
```

**Checkpoint:** ⬜ ImageField exists

---

## Task 7.3: Update Forms for Images

**File: `blog/forms.py`** (update PostForm Meta)

```python
class Meta:
    model = Post
    fields = ['title', 'slug', 'category', 'content', 'excerpt', 'featured_image', 'status']
    widgets = {
        # ... existing widgets ...
        'featured_image': forms.FileInput(attrs={'class': 'form-control'}),
    }
```

**Checkpoint:** ⬜ Form handles file uploads

---

## Task 7.4: Configure Email

**File: `config/settings.py`** (add)

```python
# Email Configuration
if DEBUG:
    EMAIL_BACKEND = 'django.core.mail.backends.console.EmailBackend'
else:
    EMAIL_BACKEND = 'django.core.mail.backends.smtp.EmailBackend'
    EMAIL_HOST = os.environ.get('EMAIL_HOST', 'smtp.gmail.com')
    EMAIL_PORT = int(os.environ.get('EMAIL_PORT', 587))
    EMAIL_USE_TLS = os.environ.get('EMAIL_USE_TLS', 'True') == 'True'
    EMAIL_HOST_USER = os.environ.get('EMAIL_HOST_USER', '')
    EMAIL_HOST_PASSWORD = os.environ.get('EMAIL_HOST_PASSWORD', '')
    DEFAULT_FROM_EMAIL = os.environ.get('DEFAULT_FROM_EMAIL', 'noreply@localhost')
```

**Checkpoint:** ⬜ Email is configured

---

## Task 7.5: Implement Sessions

**File: `blog/views.py`** (update PostDetailView)

```python
class PostDetailView(DetailView):
    # ... existing code ...
    
    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        post = self.get_object()
        
        # Track recently viewed posts
        recent_posts = self.request.session.get('recent_posts', [])
        if post.id not in recent_posts:
            recent_posts.insert(0, post.id)
            recent_posts = recent_posts[:5]  # Keep only 5
            self.request.session['recent_posts'] = recent_posts
        
        # Get actual post objects
        recent_post_objects = []
        for post_id in recent_posts[:5]:
            try:
                recent_post = Post.objects.get(id=post_id, status=Post.Status.PUBLISHED)
                recent_post_objects.append(recent_post)
            except Post.DoesNotExist:
                pass
        
        context['recently_viewed'] = recent_post_objects
        # ... existing context ...
        return context
```

**Add clear recent posts view:**
```python
@login_required
def clear_recent_posts(request):
    if 'recent_posts' in request.session:
        del request.session['recent_posts']
        messages.success(request, 'Recent posts cleared.')
    return redirect('blog:dashboard')
```

**Checkpoint:** ⬜ Sessions work

---

## Task 7.6: Implement Transactions

**File: `blog/services/post_service.py`** (update)

```python
from django.db import transaction

class PostService:
    @staticmethod
    @transaction.atomic
    def create_post_with_tags(data, author):
        """Create a post and tags atomically."""
        post = PostService.create_post(data, author)
        
        tags_input = data.get('tags_input', '')
        if tags_input:
            tag_names = [tag.strip().lower() for tag in tags_input.split(',') if tag.strip()]
            for tag_name in tag_names:
                tag, created = Tag.objects.get_or_create(
                    name=tag_name,
                    defaults={'slug': slugify(tag_name)}
                )
                post.tags.add(tag)
        
        return post
```

**Checkpoint:** ⬜ Transactions work

---

## Lab 7 Challenge: Add Post Scheduling

**Instructions:** Add a scheduled_publish_at field and a management command.

**Add field to Post model:**
```python
scheduled_publish_at = models.DateTimeField(blank=True, null=True)
```

**Update save method:**
```python
def save(self, *args, **kwargs):
    # ... existing code ...
    if self.scheduled_publish_at and self.status == self.Status.PUBLISHED:
        self.status = self.Status.DRAFT
    # ...
```

**Create management command:**
```python
# blog/management/commands/publish_scheduled.py
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

**Checkpoint:** ⬜ Post scheduling works

---

## Lab 7 Troubleshooting Log

| Error | Solution |
|-------|----------|
| | |
| | |
| | |

---

## Lab 7 Reflection

**What did you learn about real-world features?**

_________________________________________________

_________________________________________________

**What was the most challenging part of implementing file uploads?**

_________________________________________________

_________________________________________________

**What questions do you still have about sessions or transactions?**

_________________________________________________

_________________________________________________

---

# Lab 8: Testing and Quality

## Lab Objective

Write comprehensive tests and implement logging.

## Task 8.1: Write Model Tests

**File: `blog/tests/test_models.py`** (create new)

```python
from django.test import TestCase
from django.contrib.auth.models import User
from blog.models import Post, Category

class PostModelTest(TestCase):
    def setUp(self):
        self.user = User.objects.create_user(
            username='testuser',
            password='testpass'
        )
        self.category = Category.objects.create(
            name='Test Category',
            slug='test-category'
        )
    
    def test_post_creation(self):
        post = Post.objects.create(
            title='Test Post',
            content='Test content',
            author=self.user,
            category=self.category,
            status='draft'
        )
        self.assertEqual(str(post), 'Test Post')
        self.assertEqual(post.slug, 'test-post')
        self.assertEqual(len(post.excerpt), 12)  # First 200 chars

    def test_post_published_status(self):
        post = Post.objects.create(
            title='Published Post',
            content='Content',
            author=self.user,
            status='published'
        )
        self.assertTrue(post.is_published())

    def test_post_draft_status(self):
        post = Post.objects.create(
            title='Draft Post',
            content='Content',
            author=self.user,
            status='draft'
        )
        self.assertFalse(post.is_published())
```

**Checkpoint:** ⬜ Model tests pass

---

## Task 8.2: Write Form Tests

**File: `blog/tests/test_forms.py`** (create new)

```python
from django.test import TestCase
from blog.forms import PostForm

class PostFormTest(TestCase):
    def test_valid_form(self):
        data = {
            'title': 'Test Post',
            'content': 'Test content',
            'status': 'draft'
        }
        form = PostForm(data=data)
        self.assertTrue(form.is_valid())

    def test_empty_title_form(self):
        data = {
            'title': '',
            'content': 'Test content',
            'status': 'draft'
        }
        form = PostForm(data=data)
        self.assertFalse(form.is_valid())
        self.assertIn('title', form.errors)

    def test_slug_auto_generation(self):
        data = {
            'title': 'Test Post With Spaces',
            'content': 'Content',
            'status': 'draft'
        }
        form = PostForm(data=data)
        self.assertTrue(form.is_valid())
        cleaned = form.clean()
        self.assertEqual(cleaned.get('slug'), 'test-post-with-spaces')
```

**Checkpoint:** ⬜ Form tests pass

---

## Task 8.3: Write View Tests

**File: `blog/tests/test_views.py`** (create new)

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

    def test_blog_list_status(self):
        response = self.client.get(reverse('blog:blog_list'))
        self.assertEqual(response.status_code, 200)
        self.assertTemplateUsed(response, 'blog/blog_list.html')

    def test_blog_list_contains_post(self):
        response = self.client.get(reverse('blog:blog_list'))
        self.assertContains(response, 'Test Post')

    def test_post_detail_status(self):
        response = self.client.get(
            reverse('blog:post_detail', kwargs={'slug': self.post.slug})
        )
        self.assertEqual(response.status_code, 200)
        self.assertTemplateUsed(response, 'blog/post_detail.html')

    def test_post_detail_404(self):
        response = self.client.get(
            reverse('blog:post_detail', kwargs={'slug': 'non-existent'})
        )
        self.assertEqual(response.status_code, 404)
```

**Checkpoint:** ⬜ View tests pass

---

## Task 8.4: Configure Logging

**File: `config/settings.py`** (add)

```python
LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'formatters': {
        'verbose': {
            'format': '{levelname} {asctime} {name} {message}',
            'style': '{',
        },
        'simple': {
            'format': '{levelname} {message}',
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
        'django': {
            'handlers': ['console', 'file'],
            'level': 'INFO',
        },
        'blog': {
            'handlers': ['console', 'file'],
            'level': 'DEBUG',
        },
    },
}
```

**Checkpoint:** ⬜ Logging is configured

---

## Lab 8 Challenge: Write Integration Tests

**Instructions:** Write an integration test that tests the complete user flow: registration → login → post creation → post editing → post deletion.

```python
class UserFlowTest(TestCase):
    def test_complete_user_flow(self):
        # Register
        response = self.client.post(reverse('register'), {
            'username': 'newuser',
            'password1': 'testpass123',
            'password2': 'testpass123',
        })
        self.assertRedirects(response, reverse('blog:home'))
        
        # Create post
        self.client.login(username='newuser', password='testpass123')
        response = self.client.post(reverse('blog:post_create'), {
            'title': 'Integration Test Post',
            'content': 'Integration test content',
            'status': 'published'
        })
        self.assertRedirects(response, reverse('blog:post_detail', kwargs={'slug': 'integration-test-post'}))
        
        # Verify post exists
        post = Post.objects.get(slug='integration-test-post')
        self.assertEqual(post.title, 'Integration Test Post')
        
        # Edit post
        response = self.client.post(reverse('blog:post_edit', kwargs={'slug': post.slug}), {
            'title': 'Updated Integration Test Post',
            'content': 'Updated content',
            'status': 'published'
        })
        self.assertRedirects(response, reverse('blog:post_detail', kwargs={'slug': 'updated-integration-test-post'}))
        
        # Delete post
        post = Post.objects.get(slug='updated-integration-test-post')
        response = self.client.post(reverse('blog:post_delete', kwargs={'slug': post.slug}))
        self.assertRedirects(response, reverse('blog:blog_list'))
        self.assertFalse(Post.objects.filter(slug='updated-integration-test-post').exists())
```

**Checkpoint:** ⬜ Integration tests pass

---

## Lab 8 Troubleshooting Log

| Error | Solution |
|-------|----------|
| | |
| | |
| | |

---

## Lab 8 Reflection

**What did you learn about testing?**

_________________________________________________

_________________________________________________

**What was the most challenging part of writing tests?**

_________________________________________________

_________________________________________________

**What questions do you still have about testing?**

_________________________________________________

_________________________________________________

---

# Lab 9: Production Readiness

## Lab Objective

Optimize queries, implement caching, and harden security.

## Task 9.1: Identify N+1 Queries

**Use Django Debug Toolbar or query logging:**

```python
from django.db import connection

connection.queries_log.clear()
posts = Post.objects.all()
for post in posts:
    print(post.author.username)
print(f"Queries: {len(connection.queries)}")
```

**Checkpoint:** ⬜ N+1 queries are identified

---

## Task 9.2: Optimize with select_related

```python
# Before
posts = Post.objects.all()
for post in posts:
    print(post.author.username)

# After
posts = Post.objects.select_related('author', 'category').all()
for post in posts:
    print(post.author.username)
```

**Checkpoint:** ⬜ Query count is reduced

---

## Task 9.3: Configure Caching

**File: `config/settings.py`** (add)

```python
CACHES = {
    'default': {
        'BACKEND': 'django.core.cache.backends.locmem.LocMemCache',
        'LOCATION': 'unique-snowflake',
        'TIMEOUT': 300,  # 5 minutes
    }
}
```

**Implement caching in views:**
```python
from django.core.cache import cache

class PostListView(ListView):
    def get_queryset(self):
        cache_key = f'posts_{self.request.GET.urlencode()}'
        queryset = cache.get(cache_key)
        if queryset is None:
            queryset = super().get_queryset()
            cache.set(cache_key, queryset, 300)
        return queryset
```

**Checkpoint:** ⬜ Caching works

---

## Task 9.4: Harden Security

**File: `config/settings.py`** (production settings)

```python
# Security settings
SECURE_SSL_REDIRECT = True
SESSION_COOKIE_SECURE = True
CSRF_COOKIE_SECURE = True
SECURE_BROWSER_XSS_FILTER = True
SECURE_CONTENT_TYPE_NOSNIFF = True
X_FRAME_OPTIONS = 'DENY'

# HSTS
SECURE_HSTS_SECONDS = 31536000  # 1 year
SECURE_HSTS_INCLUDE_SUBDOMAINS = True
SECURE_HSTS_PRELOAD = True

# Allowed hosts
ALLOWED_HOSTS = os.environ.get('ALLOWED_HOSTS', '').split(',')

# Debug must be False in production
DEBUG = os.environ.get('DEBUG', 'False') == 'True'
```

**Checkpoint:** ⬜ Security settings are configured

---

## Task 9.5: Configure Environment Variables

**File: `.env`** (create, never commit!)

```bash
SECRET_KEY=your-super-secret-key-here
DEBUG=False
ALLOWED_HOSTS=yourdomain.com,www.yourdomain.com
DB_NAME=django_blog
DB_USER=django_user
DB_PASSWORD=secure_password
DB_HOST=localhost
DB_PORT=5432
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USE_TLS=True
EMAIL_HOST_USER=your-email@gmail.com
EMAIL_HOST_PASSWORD=your-app-password
```

**Update settings.py:**
```python
from dotenv import load_dotenv
load_dotenv()

SECRET_KEY = os.environ.get('SECRET_KEY')
DEBUG = os.environ.get('DEBUG', 'False') == 'True'
ALLOWED_HOSTS = os.environ.get('ALLOWED_HOSTS', '').split(',')
```

**Checkpoint:** ⬜ Environment variables work

---

## Lab 9 Challenge: Database Indexes

**Instructions:** Add indexes to optimize common queries.

```python
class Post(models.Model):
    # ... fields ...
    class Meta:
        indexes = [
            models.Index(fields=['status', 'published_at']),
            models.Index(fields=['author']),
            models.Index(fields=['slug']),
        ]
```

**Create migration:**
```bash
python manage.py makemigrations blog
python manage.py migrate blog
```

**Checkpoint:** ⬜ Indexes are created

---

## Lab 9 Troubleshooting Log

| Error | Solution |
|-------|----------|
| | |
| | |
| | |

---

## Lab 9 Reflection

**What did you learn about performance and security?**

_________________________________________________

_________________________________________________

**What was the most challenging part of optimization?**

_________________________________________________

_________________________________________________

**What questions do you still have about production readiness?**

_________________________________________________

_________________________________________________

---

# Lab 10: Deployment

## Lab Objective

Containerize the application and deploy to production.

## Task 10.1: Create Dockerfile

**File: `Dockerfile`** (create new)

```dockerfile
FROM python:3.14-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application
COPY . .

# Collect static files
RUN python manage.py collectstatic --noinput

# Create a non-root user
RUN adduser --system --group django
USER django

# Expose port
EXPOSE 8000

# Run gunicorn
CMD ["gunicorn", "--config", "gunicorn.conf.py", "config.wsgi:application"]
```

**Checkpoint:** ⬜ Dockerfile exists

---

## Task 10.2: Create Gunicorn Config

**File: `gunicorn.conf.py`** (create new)

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

**Checkpoint:** ⬜ Gunicorn config exists

---

## Task 10.3: Create Docker Compose

**File: `docker-compose.yml`** (create new)

```yaml
version: '3.8'

services:
  db:
    image: postgres:16-alpine
    volumes:
      - postgres_data:/var/lib/postgresql/data
    environment:
      POSTGRES_DB: ${DB_NAME:-django_blog}
      POSTGRES_USER: ${DB_USER:-django_user}
      POSTGRES_PASSWORD: ${DB_PASSWORD:-secure_password}
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${DB_USER:-django_user}"]
  
  web:
    build: .
    volumes:
      - ./media:/app/media
      - ./staticfiles:/app/staticfiles
      - ./logs:/app/logs
    environment:
      - DB_HOST=db
      - DB_NAME=${DB_NAME:-django_blog}
      - DB_USER=${DB_USER:-django_user}
      - DB_PASSWORD=${DB_PASSWORD:-secure_password}
    depends_on:
      db:
        condition: service_healthy
    ports:
      - "8000:8000"

volumes:
  postgres_data:
```

**Checkpoint:** ⬜ Docker Compose exists

---

## Task 10.4: Build and Run

```bash
# Build the images
docker-compose build

# Start the containers
docker-compose up -d

# Check status
docker-compose ps

# View logs
docker-compose logs -f

# Stop the containers
docker-compose down
```

**Checkpoint:** ⬜ Application runs in Docker

---

## Task 10.5: Test Production

```bash
# Check health endpoint
curl http://localhost:8000/health/

# Check static files
curl -I http://localhost:8000/static/css/style.css

# Check database connection
docker-compose exec web python manage.py check
```

**Checkpoint:** ⬜ Application is production-ready

---

## Lab 10 Challenge: Nginx Reverse Proxy

**Instructions:** Add an Nginx service to Docker Compose as a reverse proxy.

**Add to docker-compose.yml:**
```yaml
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
```

**nginx.conf:**
```nginx
events {
    worker_connections 1024;
}

http {
    server {
        listen 80;
        
        location /static/ {
            alias /app/staticfiles/;
        }
        
        location /media/ {
            alias /app/media/;
        }
        
        location / {
            proxy_pass http://web:8000;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
        }
    }
}
```

**Checkpoint:** ⬜ Nginx reverse proxy works

---

## Lab 10 Troubleshooting Log

| Error | Solution |
|-------|----------|
| | |
| | |
| | |

---

## Lab 10 Reflection

**What did you learn about deployment?**

_________________________________________________

_________________________________________________

**What was the most challenging part of containerization?**

_________________________________________________

_________________________________________________

**What questions do you still have about production deployment?**

_________________________________________________

_________________________________________________

---

# Final Project Log

## Project Overview

**Project Name:** _________________________________

**Description:** _________________________________

_________________________________

**Technologies Used:** _________________________________

## Development Timeline

| Date | Hours | What I Accomplished | Challenges |
|------|-------|--------------------|------------|
| | | | |
| | | | |
| | | | |
| | | | |
| | | | |
| | | | |

## Final Project Checklist

- [ ] Models are designed and migrated
- [ ] Admin interface is configured
- [ ] CRUD operations work
- [ ] Search and filtering work
- [ ] User authentication works
- [ ] User profiles work
- [ ] File uploads work
- [ ] Email notifications work
- [ ] Tests pass
- [ ] Code is optimized
- [ ] Security is hardened
- [ ] Docker deployment works
- [ ] Application is deployed

## Key Learnings from This Project

_________________________________________________

_________________________________________________

_________________________________________________

_________________________________________________

_________________________________________________

## Skills I Want to Learn Next

_________________________________________________

_________________________________________________

_________________________________________________

_________________________________________________

---

# Mastery Checklist

## Part 1: Fundamentals
- [ ] I can create a Django project and app
- [ ] I understand the MVT architecture
- [ ] I can create views and URL patterns
- [ ] I can use template inheritance
- [ ] I can serve static files

## Part 2: Models and Databases
- [ ] I can design database models
- [ ] I can create and apply migrations
- [ ] I can use Django Admin
- [ ] I can query data with the ORM

## Part 3: Forms and CRUD
- [ ] I can create ModelForms
- [ ] I can implement CRUD operations
- [ ] I can handle file uploads
- [ ] I can use Django messages

## Part 4: Class-Based Views
- [ ] I can use ListView and DetailView
- [ ] I can use CreateView, UpdateView, DeleteView
- [ ] I can implement search and filtering
- [ ] I can add pagination

## Part 5: Authentication and Users
- [ ] I can implement user registration
- [ ] I can implement login/logout
- [ ] I can create user profiles
- [ ] I can implement password reset

## Part 6: Advanced Architecture
- [ ] I can create custom middleware
- [ ] I can implement context processors
- [ ] I can use Django signals
- [ ] I can build a service layer

## Part 7: Real-World Features
- [ ] I can handle file uploads
- [ ] I can send email notifications
- [ ] I can use sessions
- [ ] I can use database transactions

## Part 8: Testing and Quality
- [ ] I can write model tests
- [ ] I can write form tests
- [ ] I can write view tests
- [ ] I can configure logging

## Part 9: Production Readiness
- [ ] I can optimize queries
- [ ] I can implement caching
- [ ] I can harden security
- [ ] I can use environment variables

## Part 10: Deployment
- [ ] I can create a Dockerfile
- [ ] I can configure Gunicorn
- [ ] I can use Docker Compose
- [ ] I can deploy my application

---

# Lab Book Wrap-Up

## Overall Reflection

**What was the most valuable thing you learned in this course?**

_________________________________________________

_________________________________________________

_________________________________________________

**What was the most difficult concept to understand?**

_________________________________________________

_________________________________________________

_________________________________________________

**What would you do differently if you started again?**

_________________________________________________

_________________________________________________

_________________________________________________

**What are your goals for your next Django project?**

_________________________________________________

_________________________________________________

_________________________________________________

**Any final thoughts or feedback?**

_________________________________________________

_________________________________________________

_________________________________________________

---

**Congratulations on completing the Mastering Django 6 Lab Book!**

You now have a comprehensive record of your hands-on learning journey. Keep this lab book as a reference for your future Django projects.

---

**[END OF LAB BOOK]**
