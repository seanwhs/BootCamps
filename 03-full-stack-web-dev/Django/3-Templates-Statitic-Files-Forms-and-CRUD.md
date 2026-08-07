# Part 3: Templates, Static Files, Forms, and CRUD

## Welcome to Part 3!

You now have a database-driven blog with an admin interface. But right now, only administrators can create content. In this part, we'll build **CRUD** (Create, Read, Update, Delete) operations that regular users can use through the web interface.

By the end of this part, authenticated users will be able to:
- Create new blog posts
- Edit their own posts
- Delete their own posts
- Upload images with their posts
- View all published posts

We'll learn about:
- Django Forms and ModelForms
- Handling GET and POST requests
- CSRF protection
- File uploads
- User authentication in views
- Messages framework

Let's begin!

---

## Target 3.1: Understanding Django Forms

### The Concept

**Django Forms** handle HTML form generation, validation, and data processing. They're like a bridge between your HTML forms and your models.

Think of forms as a bouncer at a club:
1. They check if the input is valid (validation)
2. They clean the input (sanitization)
3. They reject invalid input with helpful messages
4. They only let valid data through

There are two types of Django forms:

1. **Form**: Manual form definition (for forms that don't map directly to models)
2. **ModelForm**: Auto-generated from a model (for forms that map to models)

We'll use **ModelForm** for creating and editing blog posts.

### Real-World Analogy

Imagine you're filling out a job application:

- **HTML Form**: The paper application you fill out
- **Django Form**: The HR person checking your application
- **Validation**: Checking you filled all required fields
- **Clean Data**: Making sure your email is formatted correctly
- **Save**: Filing your application in the system

---

## Target 3.2: Creating Our First Forms

### The Concept

We'll create forms for:
1. **PostForm**: Create and edit blog posts
2. **CommentForm**: Add comments to posts

These forms will handle validation and data cleaning automatically.

### The Implementation

**File: `blog/forms.py`** (create new file)

```python
from django import forms
from django.core.exceptions import ValidationError
from django.utils.text import slugify
from .models import Post, Comment, Category, Tag


class PostForm(forms.ModelForm):
    """
    Form for creating and editing blog posts.
    
    This ModelForm automatically generates fields from the Post model,
    but we customize it to improve the user experience.
    """
    
    # Add a field for tags as a comma-separated string (easier for users)
    tags_input = forms.CharField(
        required=False,
        help_text="Enter tags separated by commas (e.g., 'Python, Django, Web')",
        widget=forms.TextInput(attrs={
            'class': 'form-control',
            'placeholder': 'python, django, web-development'
        })
    )
    
    class Meta:
        model = Post
        # Fields to include in the form
        fields = [
            'title',
            'slug',
            'category',
            'content',
            'excerpt',
            'featured_image',
            'status',
            'meta_description',
            'meta_keywords',
        ]
        # Widgets customize how fields are rendered in HTML
        widgets = {
            'title': forms.TextInput(attrs={
                'class': 'form-control',
                'placeholder': 'Enter post title'
            }),
            'slug': forms.TextInput(attrs={
                'class': 'form-control',
                'placeholder': 'URL-friendly title (auto-generated if blank)'
            }),
            'category': forms.Select(attrs={
                'class': 'form-control'
            }),
            'content': forms.Textarea(attrs={
                'class': 'form-control',
                'rows': 15,
                'placeholder': 'Write your post content here...'
            }),
            'excerpt': forms.Textarea(attrs={
                'class': 'form-control',
                'rows': 3,
                'placeholder': 'Short summary (auto-generated if blank)'
            }),
            'featured_image': forms.FileInput(attrs={
                'class': 'form-control'
            }),
            'status': forms.Select(attrs={
                'class': 'form-control'
            }),
            'meta_description': forms.TextInput(attrs={
                'class': 'form-control',
                'placeholder': 'SEO description (150-160 characters)'
            }),
            'meta_keywords': forms.TextInput(attrs={
                'class': 'form-control',
                'placeholder': 'SEO keywords, comma-separated'
            }),
        }
        # Help texts for fields
        help_texts = {
            'slug': 'Leave blank to auto-generate from title.',
            'excerpt': 'Leave blank to auto-generate from content.',
            'featured_image': 'Upload an image to display with your post.',
        }
    
    def __init__(self, *args, **kwargs):
        """
        Override __init__ to customize the form instance.
        
        We filter categories to only show those that exist.
        """
        super().__init__(*args, **kwargs)
        
        # Filter categories to only show those with posts (or all if admin)
        # For simplicity, show all categories
        self.fields['category'].queryset = Category.objects.all()
        
        # Make slug optional (we'll auto-generate if blank)
        self.fields['slug'].required = False
        
        # Set initial values for status choices
        self.fields['status'].initial = Post.Status.DRAFT
        
        # Add CSS classes to all fields
        for field_name, field in self.fields.items():
            if 'class' not in field.widget.attrs:
                field.widget.attrs['class'] = 'form-control'
    
    def clean_slug(self):
        """
        Validate and clean the slug field.
        
        If no slug is provided, generate one from the title.
        Ensure the slug is unique.
        """
        slug = self.cleaned_data.get('slug')
        title = self.cleaned_data.get('title')
        
        if not slug and title:
            # Auto-generate slug from title
            slug = slugify(title)
        
        if slug:
            # Check if slug already exists (excluding this instance if editing)
            instance_id = self.instance.id if self.instance else None
            if Post.objects.filter(slug=slug).exclude(id=instance_id).exists():
                raise ValidationError(f'A post with the slug "{slug}" already exists.')
        
        return slug
    
    def clean_featured_image(self):
        """
        Validate the uploaded image.
        
        Check file size and type.
        """
        image = self.cleaned_data.get('featured_image')
        
        if image:
            # Check file size (max 5MB)
            if image.size > 5 * 1024 * 1024:
                raise ValidationError('Image file size must be under 5MB.')
            
            # Check file type
            allowed_types = ['image/jpeg', 'image/png', 'image/gif', 'image/webp']
            if image.content_type not in allowed_types:
                raise ValidationError('Only JPEG, PNG, GIF, and WebP images are allowed.')
        
        return image
    
    def save(self, commit=True):
        """
        Override save to handle tag processing.
        
        When saving, process the tags_input field and create/get tags.
        """
        instance = super().save(commit=False)
        
        # Get tags from the input
        tags_input = self.cleaned_data.get('tags_input', '')
        
        if commit:
            instance.save()
            
            # Process tags
            if tags_input:
                # Split by comma, strip whitespace, and remove empty strings
                tag_names = [tag.strip().lower() for tag in tags_input.split(',') if tag.strip()]
                
                # Clear existing tags
                instance.tags.clear()
                
                # Add tags
                for tag_name in tag_names:
                    tag, created = Tag.objects.get_or_create(
                        name=tag_name,
                        defaults={'slug': slugify(tag_name)}
                    )
                    instance.tags.add(tag)
        
        return instance


class CommentForm(forms.ModelForm):
    """
    Form for adding comments to posts.
    """
    
    class Meta:
        model = Comment
        fields = ['content']
        widgets = {
            'content': forms.Textarea(attrs={
                'class': 'form-control',
                'rows': 4,
                'placeholder': 'Write your comment here...'
            })
        }
        labels = {
            'content': 'Your Comment'
        }
    
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.fields['content'].required = True
```

---

## Target 3.3: Creating CRUD Views for Posts

### The Concept

**CRUD** stands for Create, Read, Update, Delete. We already have Read (our blog list and detail views). Now we'll add Create, Update, and Delete functionality.

For each operation, we'll handle:
- **Create**: GET (show form) → POST (save data)
- **Update**: GET (show form with existing data) → POST (update data)
- **Delete**: GET (show confirmation) → POST (delete data)

### The Implementation

**File: `blog/views.py`** (add these new views)

```python
from django.shortcuts import render, get_object_or_404, redirect
from django.contrib.auth.decorators import login_required
from django.contrib import messages
from django.db.models import Q, Count
from django.utils import timezone
from django.http import HttpResponseRedirect
from django.urls import reverse
from .models import Post, Category, Tag, Comment
from .forms import PostForm, CommentForm


# ... (keep your existing views: home, about, blog_list, post_detail, category_detail, tag_detail)


@login_required
def post_create(request):
    """
    Create a new blog post.
    
    Only authenticated users can create posts.
    """
    if request.method == 'POST':
        # User submitted the form
        form = PostForm(request.POST, request.FILES)
        
        if form.is_valid():
            # Save the post but don't commit to database yet
            post = form.save(commit=False)
            
            # Set the author to the current user
            post.author = request.user
            
            # If status is published, set published_at
            if post.status == Post.Status.PUBLISHED:
                post.published_at = timezone.now()
            
            # Save the post
            post.save()
            
            # Save many-to-many relationships (tags)
            form.save_m2m()
            
            # Show success message
            messages.success(request, f'Your post "{post.title}" has been created successfully!')
            
            # Redirect to the post detail page
            return redirect('blog:post_detail', slug=post.slug)
        else:
            # Form has errors
            messages.error(request, 'Please correct the errors below.')
    else:
        # User is viewing the form for the first time
        form = PostForm()
    
    context = {
        'form': form,
        'title': 'Create New Post',
        'submit_text': 'Create Post',
        'year': timezone.now().year,
    }
    
    return render(request, 'blog/post_form.html', context)


@login_required
def post_edit(request, slug):
    """
    Edit an existing blog post.
    
    Only the author of the post can edit it.
    """
    # Get the post or return 404
    post = get_object_or_404(Post, slug=slug)
    
    # Check if the current user is the author
    if post.author != request.user:
        messages.error(request, 'You do not have permission to edit this post.')
        return redirect('blog:post_detail', slug=post.slug)
    
    if request.method == 'POST':
        # User submitted the form with updated data
        form = PostForm(request.POST, request.FILES, instance=post)
        
        if form.is_valid():
            # Save the updated post
            updated_post = form.save(commit=False)
            
            # If status changed to published, set published_at
            if updated_post.status == Post.Status.PUBLISHED and post.status != Post.Status.PUBLISHED:
                updated_post.published_at = timezone.now()
            
            # Save the post
            updated_post.save()
            
            # Save many-to-many relationships (tags)
            form.save_m2m()
            
            # Show success message
            messages.success(request, f'Your post "{updated_post.title}" has been updated!')
            
            # Redirect to the post detail page
            return redirect('blog:post_detail', slug=updated_post.slug)
        else:
            messages.error(request, 'Please correct the errors below.')
    else:
        # User is viewing the form with existing data
        form = PostForm(instance=post)
        
        # Pre-populate tags_input with existing tags
        if post.tags.exists():
            tags_list = [tag.name for tag in post.tags.all()]
            form.fields['tags_input'].initial = ', '.join(tags_list)
    
    context = {
        'form': form,
        'title': f'Edit Post: {post.title}',
        'submit_text': 'Update Post',
        'post': post,
        'year': timezone.now().year,
    }
    
    return render(request, 'blog/post_form.html', context)


@login_required
def post_delete(request, slug):
    """
    Delete a blog post.
    
    Only the author of the post can delete it.
    """
    # Get the post or return 404
    post = get_object_or_404(Post, slug=slug)
    
    # Check if the current user is the author
    if post.author != request.user:
        messages.error(request, 'You do not have permission to delete this post.')
        return redirect('blog:post_detail', slug=post.slug)
    
    if request.method == 'POST':
        # User confirmed deletion
        post_title = post.title
        
        # Delete the post
        post.delete()
        
        # Show success message
        messages.success(request, f'Your post "{post_title}" has been deleted.')
        
        # Redirect to blog list
        return redirect('blog:blog_list')
    
    # GET request - show confirmation page
    context = {
        'post': post,
        'year': timezone.now().year,
    }
    
    return render(request, 'blog/post_confirm_delete.html', context)


@login_required
def comment_create(request, post_slug):
    """
    Add a comment to a post.
    
    Only authenticated users can comment.
    """
    # Get the post or return 404
    post = get_object_or_404(Post, slug=post_slug, status=Post.Status.PUBLISHED)
    
    if request.method == 'POST':
        form = CommentForm(request.POST)
        
        if form.is_valid():
            # Create comment but don't save yet
            comment = form.save(commit=False)
            
            # Set the comment's post and author
            comment.post = post
            comment.author = request.user
            
            # Save the comment
            comment.save()
            
            # Show success message
            messages.success(request, 'Your comment has been added and is awaiting moderation.')
        else:
            messages.error(request, 'Please enter a valid comment.')
    else:
        # GET request - redirect to post detail
        pass
    
    # Redirect back to the post detail page
    return redirect('blog:post_detail', slug=post.slug)
```

---

## Target 3.4: Creating Templates for CRUD Operations

### The Concept

We need templates for:
1. **Post Form**: Create and edit posts (shared template)
2. **Post Delete**: Confirmation page for deletion

These templates will use the forms we created and display validation errors.

### The Implementation

**File: `blog/templates/blog/post_form.html`** (create new)

```html
{% extends 'blog/base.html' %}
{% load static %}

{% block title %}
    {{ title }} — Django Blog
{% endblock %}

{% block content %}
<div class="page-header">
    <h1>{{ title }}</h1>
</div>

<div class="content">
    <form method="post" enctype="multipart/form-data" novalidate>
        {% csrf_token %}
        
        {% if form.errors %}
            <div style="background: #f8d7da; color: #721c24; padding: 1rem; border-radius: 4px; margin-bottom: 1rem; border: 1px solid #f5c6cb;">
                <strong>Please correct the following errors:</strong>
                <ul style="margin-top: 0.5rem; margin-bottom: 0; padding-left: 1.5rem;">
                    {% for field, errors in form.errors.items %}
                        {% for error in errors %}
                            <li>{{ field|capfirst }}: {{ error }}</li>
                        {% endfor %}
                    {% endfor %}
                </ul>
            </div>
        {% endif %}
        
        <!-- Title -->
        <div style="margin-bottom: 1.5rem;">
            <label for="{{ form.title.id_for_label }}" style="display: block; font-weight: bold; margin-bottom: 0.25rem;">
                {{ form.title.label }}
                <span style="color: #e74c3c;">*</span>
            </label>
            {{ form.title }}
            {% if form.title.help_text %}
                <small style="color: #7f8c8d; display: block; margin-top: 0.25rem;">
                    {{ form.title.help_text }}
                </small>
            {% endif %}
            {% if form.title.errors %}
                <div style="color: #e74c3c; font-size: 0.9rem; margin-top: 0.25rem;">
                    {{ form.title.errors }}
                </div>
            {% endif %}
        </div>
        
        <!-- Slug -->
        <div style="margin-bottom: 1.5rem;">
            <label for="{{ form.slug.id_for_label }}" style="display: block; font-weight: bold; margin-bottom: 0.25rem;">
                {{ form.slug.label }}
            </label>
            {{ form.slug }}
            {% if form.slug.help_text %}
                <small style="color: #7f8c8d; display: block; margin-top: 0.25rem;">
                    {{ form.slug.help_text }}
                </small>
            {% endif %}
            {% if form.slug.errors %}
                <div style="color: #e74c3c; font-size: 0.9rem; margin-top: 0.25rem;">
                    {{ form.slug.errors }}
                </div>
            {% endif %}
        </div>
        
        <!-- Category -->
        <div style="margin-bottom: 1.5rem;">
            <label for="{{ form.category.id_for_label }}" style="display: block; font-weight: bold; margin-bottom: 0.25rem;">
                {{ form.category.label }}
                <span style="color: #e74c3c;">*</span>
            </label>
            {{ form.category }}
            {% if form.category.help_text %}
                <small style="color: #7f8c8d; display: block; margin-top: 0.25rem;">
                    {{ form.category.help_text }}
                </small>
            {% endif %}
            {% if form.category.errors %}
                <div style="color: #e74c3c; font-size: 0.9rem; margin-top: 0.25rem;">
                    {{ form.category.errors }}
                </div>
            {% endif %}
        </div>
        
        <!-- Tags Input -->
        <div style="margin-bottom: 1.5rem;">
            <label for="{{ form.tags_input.id_for_label }}" style="display: block; font-weight: bold; margin-bottom: 0.25rem;">
                Tags
            </label>
            {{ form.tags_input }}
            {% if form.tags_input.help_text %}
                <small style="color: #7f8c8d; display: block; margin-top: 0.25rem;">
                    {{ form.tags_input.help_text }}
                </small>
            {% endif %}
        </div>
        
        <!-- Content -->
        <div style="margin-bottom: 1.5rem;">
            <label for="{{ form.content.id_for_label }}" style="display: block; font-weight: bold; margin-bottom: 0.25rem;">
                {{ form.content.label }}
                <span style="color: #e74c3c;">*</span>
            </label>
            {{ form.content }}
            {% if form.content.help_text %}
                <small style="color: #7f8c8d; display: block; margin-top: 0.25rem;">
                    {{ form.content.help_text }}
                </small>
            {% endif %}
            {% if form.content.errors %}
                <div style="color: #e74c3c; font-size: 0.9rem; margin-top: 0.25rem;">
                    {{ form.content.errors }}
                </div>
            {% endif %}
        </div>
        
        <!-- Excerpt -->
        <div style="margin-bottom: 1.5rem;">
            <label for="{{ form.excerpt.id_for_label }}" style="display: block; font-weight: bold; margin-bottom: 0.25rem;">
                {{ form.excerpt.label }}
            </label>
            {{ form.excerpt }}
            {% if form.excerpt.help_text %}
                <small style="color: #7f8c8d; display: block; margin-top: 0.25rem;">
                    {{ form.excerpt.help_text }}
                </small>
            {% endif %}
            {% if form.excerpt.errors %}
                <div style="color: #e74c3c; font-size: 0.9rem; margin-top: 0.25rem;">
                    {{ form.excerpt.errors }}
                </div>
            {% endif %}
        </div>
        
        <!-- Featured Image -->
        <div style="margin-bottom: 1.5rem;">
            <label for="{{ form.featured_image.id_for_label }}" style="display: block; font-weight: bold; margin-bottom: 0.25rem;">
                {{ form.featured_image.label }}
            </label>
            {% if form.instance.featured_image %}
                <div style="margin-bottom: 0.5rem;">
                    <img src="{{ form.instance.featured_image.url }}" alt="Current featured image" style="max-width: 200px; max-height: 200px; border-radius: 4px;">
                    <br>
                    <small style="color: #7f8c8d;">Current image</small>
                </div>
            {% endif %}
            {{ form.featured_image }}
            {% if form.featured_image.help_text %}
                <small style="color: #7f8c8d; display: block; margin-top: 0.25rem;">
                    {{ form.featured_image.help_text }}
                </small>
            {% endif %}
            {% if form.featured_image.errors %}
                <div style="color: #e74c3c; font-size: 0.9rem; margin-top: 0.25rem;">
                    {{ form.featured_image.errors }}
                </div>
            {% endif %}
        </div>
        
        <!-- Status -->
        <div style="margin-bottom: 1.5rem;">
            <label for="{{ form.status.id_for_label }}" style="display: block; font-weight: bold; margin-bottom: 0.25rem;">
                {{ form.status.label }}
                <span style="color: #e74c3c;">*</span>
            </label>
            {{ form.status }}
            {% if form.status.help_text %}
                <small style="color: #7f8c8d; display: block; margin-top: 0.25rem;">
                    {{ form.status.help_text }}
                </small>
            {% endif %}
            {% if form.status.errors %}
                <div style="color: #e74c3c; font-size: 0.9rem; margin-top: 0.25rem;">
                    {{ form.status.errors }}
                </div>
            {% endif %}
        </div>
        
        <!-- SEO Meta Description -->
        <div style="margin-bottom: 1.5rem;">
            <label for="{{ form.meta_description.id_for_label }}" style="display: block; font-weight: bold; margin-bottom: 0.25rem;">
                {{ form.meta_description.label }}
            </label>
            {{ form.meta_description }}
            {% if form.meta_description.help_text %}
                <small style="color: #7f8c8d; display: block; margin-top: 0.25rem;">
                    {{ form.meta_description.help_text }}
                </small>
            {% endif %}
            {% if form.meta_description.errors %}
                <div style="color: #e74c3c; font-size: 0.9rem; margin-top: 0.25rem;">
                    {{ form.meta_description.errors }}
                </div>
            {% endif %}
        </div>
        
        <!-- SEO Meta Keywords -->
        <div style="margin-bottom: 1.5rem;">
            <label for="{{ form.meta_keywords.id_for_label }}" style="display: block; font-weight: bold; margin-bottom: 0.25rem;">
                {{ form.meta_keywords.label }}
            </label>
            {{ form.meta_keywords }}
            {% if form.meta_keywords.help_text %}
                <small style="color: #7f8c8d; display: block; margin-top: 0.25rem;">
                    {{ form.meta_keywords.help_text }}
                </small>
            {% endif %}
            {% if form.meta_keywords.errors %}
                <div style="color: #e74c3c; font-size: 0.9rem; margin-top: 0.25rem;">
                    {{ form.meta_keywords.errors }}
                </div>
            {% endif %}
        </div>
        
        <!-- Submit Buttons -->
        <div style="display: flex; gap: 1rem; margin-top: 2rem;">
            <button type="submit" style="background: #3498db; color: white; border: none; padding: 0.75rem 2rem; border-radius: 4px; cursor: pointer; font-size: 1rem;">
                {{ submit_text }}
            </button>
            
            {% if post %}
                <a href="{% url 'blog:post_detail' post.slug %}" style="background: #95a5a6; color: white; padding: 0.75rem 2rem; border-radius: 4px; text-decoration: none; display: inline-block;">
                    Cancel
                </a>
            {% else %}
                <a href="{% url 'blog:blog_list' %}" style="background: #95a5a6; color: white; padding: 0.75rem 2rem; border-radius: 4px; text-decoration: none; display: inline-block;">
                    Cancel
                </a>
            {% endif %}
        </div>
    </form>
</div>
{% endblock %}
```

**File: `blog/templates/blog/post_confirm_delete.html`** (create new)

```html
{% extends 'blog/base.html' %}
{% load static %}

{% block title %}
    Delete Post — Django Blog
{% endblock %}

{% block content %}
<div class="page-header">
    <h1>Delete Post</h1>
</div>

<div class="content" style="text-align: center;">
    <p style="font-size: 1.2rem; margin-bottom: 1rem;">
        Are you sure you want to delete the post 
        <strong>"{{ post.title }}"</strong>?
    </p>
    
    <p style="color: #e74c3c; margin-bottom: 2rem;">
        <strong>Warning:</strong> This action cannot be undone.
        All comments associated with this post will also be deleted.
    </p>
    
    <form method="post">
        {% csrf_token %}
        <div style="display: flex; gap: 1rem; justify-content: center;">
            <button type="submit" style="background: #e74c3c; color: white; border: none; padding: 0.75rem 2rem; border-radius: 4px; cursor: pointer; font-size: 1rem;">
                Yes, Delete This Post
            </button>
            <a href="{% url 'blog:post_detail' post.slug %}" style="background: #95a5a6; color: white; padding: 0.75rem 2rem; border-radius: 4px; text-decoration: none; display: inline-block;">
                No, Take Me Back
            </a>
        </div>
    </form>
</div>
{% endblock %}
```

---

## Target 3.5: Updating URLs for CRUD Operations

### The Concept

We need to add URL patterns for our new CRUD views.

### The Implementation

**File: `blog/urls.py`** (update)

```python
from django.urls import path
from . import views

# Application namespace
app_name = 'blog'

# URL patterns for the blog app
urlpatterns = [
    # Public views
    path('', views.home, name='home'),
    path('about/', views.about, name='about'),
    path('blog/', views.blog_list, name='blog_list'),
    path('blog/<slug:slug>/', views.post_detail, name='post_detail'),
    path('category/<slug:slug>/', views.category_detail, name='category_detail'),
    path('tag/<slug:slug>/', views.tag_detail, name='tag_detail'),
    
    # CRUD views (authenticated users only)
    path('post/create/', views.post_create, name='post_create'),
    path('post/<slug:slug>/edit/', views.post_edit, name='post_edit'),
    path('post/<slug:slug>/delete/', views.post_delete, name='post_delete'),
    
    # Comment views
    path('post/<slug:post_slug>/comment/', views.comment_create, name='comment_create'),
]
```

---

## Target 3.6: Updating Templates with CRUD Links

### The Concept

Now we need to update existing templates to include links to the CRUD operations:
- Add "Create New Post" button
- Add "Edit" and "Delete" buttons on post detail pages (for authors only)

### The Implementation

**File: `blog/templates/blog/base.html`** (update navigation)

```html
{% load static %}
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{% block title %}Django Blog{% endblock %}</title>
    <link rel="stylesheet" href="{% static 'blog/css/style.css' %}">
</head>
<body>
    <!-- Updated navigation with user authentication -->
    <nav>
        <div class="container">
            <a href="{% url 'blog:home' %}" class="nav-brand">Django Blog</a>
            <ul class="nav-links">
                <li><a href="{% url 'blog:home' %}">Home</a></li>
                <li><a href="{% url 'blog:blog_list' %}">Blog</a></li>
                <li><a href="{% url 'blog:about' %}">About</a></li>
                
                {% if user.is_authenticated %}
                    <li><a href="{% url 'blog:post_create' %}">New Post</a></li>
                    <li>
                        <span style="color: #ecf0f1;">
                            Welcome, {{ user.username }}
                        </span>
                    </li>
                    <li>
                        <form method="post" action="{% url 'logout' %}" style="display: inline;">
                            {% csrf_token %}
                            <button type="submit" style="background: none; border: none; color: #ecf0f1; cursor: pointer; padding: 0.5rem 0;">
                                Logout
                            </button>
                        </form>
                    </li>
                {% else %}
                    <li><a href="{% url 'login' %}">Login</a></li>
                    <li><a href="{% url 'register' %}">Register</a></li>
                {% endif %}
            </ul>
        </div>
    </nav>
    
    <!-- Messages Display -->
    {% if messages %}
        <div class="container" style="margin-top: 1rem;">
            {% for message in messages %}
                <div style="padding: 1rem; border-radius: 4px; margin-bottom: 0.5rem; 
                    {% if message.tags == 'success' %}background: #d4edda; color: #155724; border: 1px solid #c3e6cb;
                    {% elif message.tags == 'error' %}background: #f8d7da; color: #721c24; border: 1px solid #f5c6cb;
                    {% elif message.tags == 'warning' %}background: #fff3cd; color: #856404; border: 1px solid #ffeeba;
                    {% else %}background: #d1ecf1; color: #0c5460; border: 1px solid #bee5eb;{% endif %}">
                    {{ message }}
                </div>
            {% endfor %}
        </div>
    {% endif %}
    
    <!-- Main Content -->
    <main>
        <div class="container">
            {% block content %}
            {% endblock %}
        </div>
    </main>
    
    <!-- Footer -->
    <footer>
        <div class="container">
            <p>&copy; {{ current_year }} Django Blog. Built with ❤️ using Django 6.</p>
        </div>
    </footer>
</body>
</html>
```

**File: `blog/templates/blog/post_detail.html`** (update with edit/delete buttons)

```html
{% extends 'blog/base.html' %}
{% load static %}

{% block title %}
    {{ post.title }} — Django Blog
{% endblock %}

{% block content %}
<div class="page-header">
    <h1>{{ post.title }}</h1>
    <p class="subtitle">
        By {{ post.author.get_full_name|default:post.author.username }}
        on {{ post.published_at|date:"F j, Y" }}
        {% if post.category %}
            in <a href="{{ post.category.get_absolute_url }}" style="color: #3498db; text-decoration: none;">
                {{ post.category.name }}
            </a>
        {% endif %}
    </p>
    {% if post.tags.all %}
        <p>
            Tags:
            {% for tag in post.tags.all %}
                <a href="{{ tag.get_absolute_url }}" style="background: #ecf0f1; padding: 0.2rem 0.6rem; border-radius: 12px; color: #2c3e50; text-decoration: none; font-size: 0.85rem;">
                    {{ tag.name }}
                </a>
                {% if not forloop.last %} {% endif %}
            {% endfor %}
        </p>
    {% endif %}
    
    <!-- Author actions -->
    {% if user == post.author %}
        <div style="margin-top: 1rem; display: flex; gap: 0.5rem;">
            <a href="{% url 'blog:post_edit' post.slug %}" style="background: #3498db; color: white; padding: 0.4rem 1rem; border-radius: 4px; text-decoration: none; font-size: 0.9rem;">
                Edit Post
            </a>
            <a href="{% url 'blog:post_delete' post.slug %}" style="background: #e74c3c; color: white; padding: 0.4rem 1rem; border-radius: 4px; text-decoration: none; font-size: 0.9rem;">
                Delete Post
            </a>
        </div>
    {% endif %}
</div>

<div class="content">
    {% if post.featured_image %}
        <div style="margin-bottom: 2rem;">
            <img src="{{ post.featured_image.url }}" alt="{{ post.title }}" style="max-width: 100%; border-radius: 8px;">
        </div>
    {% endif %}
    
    <div style="line-height: 1.8;">
        {{ post.content|linebreaks }}
    </div>
    
    <!-- Comments section -->
    <div style="margin-top: 3rem; padding-top: 2rem; border-top: 2px solid #eee;">
        <h3>Comments ({{ post.get_comment_count }})</h3>
        
        {% with comments=post.comments.filter|dictsort:"created_at" %}
            {% for comment in comments %}
                <div style="background: #f8f9fa; padding: 1rem; border-radius: 8px; margin-bottom: 1rem;">
                    <p><strong>{{ comment.author.get_full_name|default:comment.author.username }}</strong>
                    <span style="color: #7f8c8d; font-size: 0.9rem;">— {{ comment.created_at|date:"F j, Y g:i a" }}</span></p>
                    <p>{{ comment.content|linebreaks }}</p>
                </div>
            {% empty %}
                <p style="color: #7f8c8d;">No comments yet. Be the first to comment!</p>
            {% endfor %}
        {% endwith %}
        
        <!-- Comment form -->
        {% if user.is_authenticated %}
            <div style="margin-top: 2rem; padding-top: 1.5rem; border-top: 1px solid #eee;">
                <h4>Add a Comment</h4>
                <form method="post" action="{% url 'blog:comment_create' post.slug %}">
                    {% csrf_token %}
                    <div style="margin-bottom: 1rem;">
                        <textarea name="content" rows="4" style="width: 100%; padding: 0.5rem; border: 1px solid #ddd; border-radius: 4px;" placeholder="Write your comment here..."></textarea>
                    </div>
                    <button type="submit" style="background: #3498db; color: white; border: none; padding: 0.5rem 1.5rem; border-radius: 4px; cursor: pointer;">
                        Submit Comment
                    </button>
                </form>
            </div>
        {% else %}
            <p style="margin-top: 1rem; color: #7f8c8d;">
                <a href="{% url 'login' %}" style="color: #3498db;">Log in</a> to leave a comment.
            </p>
        {% endif %}
    </div>
</div>

<!-- Back link -->
<div style="margin-top: 1.5rem;">
    <a href="{% url 'blog:blog_list' %}" style="color: #3498db; text-decoration: none;">
        ← Back to all posts
    </a>
</div>
{% endblock %}
```

**File: `blog/templates/blog/blog_list.html`** (update with actions)

```html
{% extends 'blog/base.html' %}
{% load static %}

{% block title %}
    {{ page_title }} — Django Blog
{% endblock %}

{% block content %}
<div class="page-header">
    <h1>{{ page_title }}</h1>
    <p class="subtitle">All blog posts</p>
</div>

<div class="content">
    {% if posts %}
        {% for post in posts %}
            <div style="margin-bottom: 2rem; padding-bottom: 2rem; border-bottom: 1px solid #eee;">
                <h2 style="margin-bottom: 0.25rem;">
                    <a href="{{ post.get_absolute_url }}" style="color: #2c3e50; text-decoration: none;">
                        {{ post.title }}
                    </a>
                </h2>
                <p style="color: #7f8c8d; font-size: 0.9rem;">
                    By {{ post.author.get_full_name|default:post.author.username }}
                    on {{ post.published_at|date:"F j, Y" }}
                    {% if post.category %}
                        in <a href="{{ post.category.get_absolute_url }}" style="color: #3498db; text-decoration: none;">
                            {{ post.category.name }}
                        </a>
                    {% endif %}
                    
                    <!-- Show status badge -->
                    {% if post.status != 'published' %}
                        <span style="background: #f39c12; color: white; padding: 0.1rem 0.5rem; border-radius: 12px; font-size: 0.75rem; margin-left: 0.5rem;">
                            {{ post.get_status_display }}
                        </span>
                    {% endif %}
                    
                    <!-- Edit/Delete links for author -->
                    {% if user == post.author %}
                        <span style="margin-left: 0.5rem;">
                            <a href="{% url 'blog:post_edit' post.slug %}" style="color: #3498db; text-decoration: none; font-size: 0.85rem;">Edit</a>
                            |
                            <a href="{% url 'blog:post_delete' post.slug %}" style="color: #e74c3c; text-decoration: none; font-size: 0.85rem;">Delete</a>
                        </span>
                    {% endif %}
                </p>
                <p>{{ post.excerpt|truncatewords:30 }}</p>
                {% if post.tags.all %}
                    <p style="margin-top: 0.5rem;">
                        Tags:
                        {% for tag in post.tags.all %}
                            <a href="{{ tag.get_absolute_url }}" style="background: #ecf0f1; padding: 0.2rem 0.6rem; border-radius: 12px; color: #2c3e50; text-decoration: none; font-size: 0.85rem;">
                                {{ tag.name }}
                            </a>
                            {% if not forloop.last %} {% endif %}
                        {% endfor %}
                    </p>
                {% endif %}
            </div>
        {% endfor %}
    {% else %}
        <p>No blog posts available yet.</p>
    {% endif %}
</div>
{% endblock %}
```

---

## Target 3.7: Setting Up User Authentication

### The Concept

Before our CRUD operations work, we need user authentication. Django's built-in `django.contrib.auth` handles:
- User registration
- Login/Logout
- Password management
- Session handling

We need to:
1. Enable authentication in settings
2. Create login and registration templates
3. Add URL patterns for authentication

### The Implementation

First, ensure authentication apps are enabled in settings:

**File: `config/settings.py`** (already configured, but verify)

```python
# config/settings.py

INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',        # Authentication
    'django.contrib.contenttypes',
    'django.contrib.sessions',     # Session management
    'django.contrib.messages',     # Messages framework
    'django.contrib.staticfiles',
    'blog',
]

MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',  # Sessions
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',  # Auth
    'django.contrib.messages.middleware.MessageMiddleware',  # Messages
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

# Authentication settings
LOGIN_URL = 'login'  # Where to redirect if @login_required fails
LOGIN_REDIRECT_URL = 'blog:home'  # Where to redirect after login
LOGOUT_REDIRECT_URL = 'blog:home'  # Where to redirect after logout
```

Now create authentication templates:

```bash
mkdir -p blog/templates/registration
```

**File: `blog/templates/registration/login.html`** (create new)

```html
{% extends 'blog/base.html' %}
{% load static %}

{% block title %}
    Login — Django Blog
{% endblock %}

{% block content %}
<div class="page-header">
    <h1>Login</h1>
</div>

<div class="content" style="max-width: 500px; margin: 0 auto;">
    <form method="post">
        {% csrf_token %}
        
        {% if form.errors %}
            <div style="background: #f8d7da; color: #721c24; padding: 1rem; border-radius: 4px; margin-bottom: 1rem; border: 1px solid #f5c6cb;">
                <strong>Please correct the following errors:</strong>
                <ul style="margin-top: 0.5rem; margin-bottom: 0; padding-left: 1.5rem;">
                    <li>Invalid username or password. Please try again.</li>
                </ul>
            </div>
        {% endif %}
        
        <div style="margin-bottom: 1.5rem;">
            <label for="id_username" style="display: block; font-weight: bold; margin-bottom: 0.25rem;">
                Username
                <span style="color: #e74c3c;">*</span>
            </label>
            <input type="text" name="username" id="id_username" class="form-control" style="width: 100%; padding: 0.5rem; border: 1px solid #ddd; border-radius: 4px;" required>
        </div>
        
        <div style="margin-bottom: 1.5rem;">
            <label for="id_password" style="display: block; font-weight: bold; margin-bottom: 0.25rem;">
                Password
                <span style="color: #e74c3c;">*</span>
            </label>
            <input type="password" name="password" id="id_password" class="form-control" style="width: 100%; padding: 0.5rem; border: 1px solid #ddd; border-radius: 4px;" required>
        </div>
        
        <div style="display: flex; gap: 1rem; margin-top: 2rem;">
            <button type="submit" style="background: #3498db; color: white; border: none; padding: 0.75rem 2rem; border-radius: 4px; cursor: pointer; font-size: 1rem;">
                Login
            </button>
            <a href="{% url 'register' %}" style="background: #95a5a6; color: white; padding: 0.75rem 2rem; border-radius: 4px; text-decoration: none; display: inline-block;">
                Register
            </a>
        </div>
        
        <input type="hidden" name="next" value="{{ next }}">
    </form>
    
    <p style="margin-top: 1.5rem; color: #7f8c8d;">
        <a href="{% url 'password_reset' %}" style="color: #3498db; text-decoration: none;">
            Forgot your password?
        </a>
    </p>
</div>
{% endblock %}
```

**File: `blog/templates/registration/register.html`** (create new)

```html
{% extends 'blog/base.html' %}
{% load static %}

{% block title %}
    Register — Django Blog
{% endblock %}

{% block content %}
<div class="page-header">
    <h1>Create an Account</h1>
</div>

<div class="content" style="max-width: 500px; margin: 0 auto;">
    <form method="post">
        {% csrf_token %}
        
        {% if form.errors %}
            <div style="background: #f8d7da; color: #721c24; padding: 1rem; border-radius: 4px; margin-bottom: 1rem; border: 1px solid #f5c6cb;">
                <strong>Please correct the following errors:</strong>
                <ul style="margin-top: 0.5rem; margin-bottom: 0; padding-left: 1.5rem;">
                    {% for field, errors in form.errors.items %}
                        {% for error in errors %}
                            <li>{{ field|capfirst }}: {{ error }}</li>
                        {% endfor %}
                    {% endfor %}
                </ul>
            </div>
        {% endif %}
        
        <div style="margin-bottom: 1.5rem;">
            <label for="id_username" style="display: block; font-weight: bold; margin-bottom: 0.25rem;">
                Username
                <span style="color: #e74c3c;">*</span>
            </label>
            <input type="text" name="username" id="id_username" class="form-control" style="width: 100%; padding: 0.5rem; border: 1px solid #ddd; border-radius: 4px;" value="{{ form.username.value|default:'' }}" required>
            <small style="color: #7f8c8d;">Required. 150 characters or fewer. Letters, digits and @/./+/-/_ only.</small>
        </div>
        
        <div style="margin-bottom: 1.5rem;">
            <label for="id_email" style="display: block; font-weight: bold; margin-bottom: 0.25rem;">
                Email Address
                <span style="color: #e74c3c;">*</span>
            </label>
            <input type="email" name="email" id="id_email" class="form-control" style="width: 100%; padding: 0.5rem; border: 1px solid #ddd; border-radius: 4px;" value="{{ form.email.value|default:'' }}" required>
        </div>
        
        <div style="margin-bottom: 1.5rem;">
            <label for="id_password1" style="display: block; font-weight: bold; margin-bottom: 0.25rem;">
                Password
                <span style="color: #e74c3c;">*</span>
            </label>
            <input type="password" name="password1" id="id_password1" class="form-control" style="width: 100%; padding: 0.5rem; border: 1px solid #ddd; border-radius: 4px;" required>
            <small style="color: #7f8c8d;">
                Your password must contain at least 8 characters, not be commonly used, and not be entirely numeric.
            </small>
        </div>
        
        <div style="margin-bottom: 1.5rem;">
            <label for="id_password2" style="display: block; font-weight: bold; margin-bottom: 0.25rem;">
                Confirm Password
                <span style="color: #e74c3c;">*</span>
            </label>
            <input type="password" name="password2" id="id_password2" class="form-control" style="width: 100%; padding: 0.5rem; border: 1px solid #ddd; border-radius: 4px;" required>
        </div>
        
        <div style="display: flex; gap: 1rem; margin-top: 2rem;">
            <button type="submit" style="background: #2ecc71; color: white; border: none; padding: 0.75rem 2rem; border-radius: 4px; cursor: pointer; font-size: 1rem;">
                Register
            </button>
            <a href="{% url 'login' %}" style="background: #95a5a6; color: white; padding: 0.75rem 2rem; border-radius: 4px; text-decoration: none; display: inline-block;">
                Back to Login
            </a>
        </div>
    </form>
</div>
{% endblock %}
```

Now create a registration view:

**File: `blog/views.py`** (add registration view)

```python
from django.contrib.auth.forms import UserCreationForm
from django.contrib.auth import login

# ... (keep all existing imports and views)

def register(request):
    """
    User registration view.
    
    Creates a new user account and logs them in automatically.
    """
    if request.method == 'POST':
        form = UserCreationForm(request.POST)
        
        if form.is_valid():
            # Create the user
            user = form.save()
            
            # Log the user in
            login(request, user)
            
            # Show success message
            messages.success(request, f'Welcome, {user.username}! Your account has been created.')
            
            # Redirect to home page
            return redirect('blog:home')
    else:
        form = UserCreationForm()
    
    context = {
        'form': form,
        'year': timezone.now().year,
    }
    
    return render(request, 'registration/register.html', context)
```

Update `blog/urls.py` with authentication URLs:

**File: `blog/urls.py`** (update)

```python
from django.urls import path, include
from django.contrib.auth import views as auth_views
from . import views

app_name = 'blog'

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
    
    # Authentication views
    path('login/', auth_views.LoginView.as_view(), name='login'),
    path('logout/', auth_views.LogoutView.as_view(), name='logout'),
    path('register/', views.register, name='register'),
    
    # Password management
    path('password-reset/', 
         auth_views.PasswordResetView.as_view(), 
         name='password_reset'),
    path('password-reset/done/', 
         auth_views.PasswordResetDoneView.as_view(), 
         name='password_reset_done'),
    path('password-reset/<uidb64>/<token>/', 
         auth_views.PasswordResetConfirmView.as_view(), 
         name='password_reset_confirm'),
    path('password-reset/complete/', 
         auth_views.PasswordResetCompleteView.as_view(), 
         name='password_reset_complete'),
]
```

---

## The Verification

Let's test our complete CRUD workflow:

### Step 1: Create a User

1. Visit **http://127.0.0.1:8000/register/**
2. Register a new user account
3. You should be automatically logged in

### Step 2: Create a Post

1. Click "New Post" in the navigation
2. Fill in the form:
   - Title: "My First Blog Post"
   - Category: Select a category (create one in admin if needed)
   - Tags: "django, tutorial, web-development"
   - Content: Write some sample content
   - Status: "Draft" or "Published"
3. Click "Create Post"
4. You should see a success message and the post detail page

### Step 3: Edit the Post

1. On the post detail page, click "Edit Post"
2. Change the title to "My Updated Blog Post"
3. Click "Update Post"
4. Verify the changes are saved

### Step 4: Delete the Post

1. On the post detail page, click "Delete Post"
2. Confirm deletion on the confirmation page
3. Verify the post is removed from the blog list

### Step 5: Test Access Control

1. Try to edit or delete a post that belongs to another user
2. You should be redirected with an error message

### Step 6: Add a Comment

1. On a published post, scroll to the comments section
2. Add a comment
3. Verify the comment appears (or shows "awaiting moderation")

---

## Understanding Form Validation

### How Validation Works

When a form is submitted, Django runs these steps:

1. **Field-level validation**: Each field validates its own data
2. **clean() method**: Cross-field validation (e.g., start date < end date)
3. **Model validation**: Model-level validation rules
4. **Save**: Data is saved to the database

### Validation Flow

```python
# forms.py
class PostForm(forms.ModelForm):
    def clean_title(self):
        """Field-level validation for title."""
        title = self.cleaned_data.get('title')
        if len(title) < 5:
            raise ValidationError('Title must be at least 5 characters.')
        return title
    
    def clean(self):
        """Cross-field validation."""
        cleaned_data = super().clean()
        title = cleaned_data.get('title')
        slug = cleaned_data.get('slug')
        
        # If slug is provided, ensure it matches title
        if slug and title:
            if slugify(title) != slug:
                self.add_error('slug', 'Slug should match the title slug.')
        return cleaned_data
```

### Custom Validators

You can also create reusable validators:

```python
# validators.py
from django.core.exceptions import ValidationError

def validate_positive_number(value):
    if value < 0:
        raise ValidationError('Value must be positive.')

# models.py
class MyModel(models.Model):
    quantity = models.IntegerField(validators=[validate_positive_number])
```

---

## Common Errors and Troubleshooting

### Error: "CSRF token missing or incorrect"
**Cause**: Missing `{% csrf_token %}` in form
**Fix**: Add `{% csrf_token %}` inside every POST form

### Error: "This field is required"
**Cause**: Required field left empty
**Fix**: Fill in the field or make it optional with `required=False`

### Error: "403 Forbidden: CSRF verification failed"
**Cause**: CSRF token not submitted correctly
**Fix**: Check that the form includes `{% csrf_token %}`

### Error: "You do not have permission"
**Cause**: User not authorized for the action
**Fix**: Check `@login_required` and authorization checks in views

### Error: "File upload failed: The submitted data was not a file"
**Cause**: Form missing `enctype="multipart/form-data"`
**Fix**: Add `enctype="multipart/form-data"` to form tag

---

## Challenge: Extend CRUD Functionality

### Challenge 1: Add a Dashboard
Create a user dashboard that shows:
- List of user's posts with edit/delete links
- Comment moderation queue
- User profile information

### Challenge 2: Add Category Management
Allow authenticated users to:
- Create new categories
- Edit existing categories
- Delete categories (only if no posts exist)

### Challenge 3: Add Comment Moderation
Create a moderation view for post authors to:
- View all comments on their posts
- Approve or reject comments
- Delete spam comments

### Challenge 4: Add Draft Preview
Allow authors to preview their drafts before publishing.

---

## What You've Learned in Part 3

### ✅ Skills Acquired
- Creating Django ModelForms
- Handling GET and POST requests
- Validating form data
- Processing file uploads
- Implementing CRUD operations
- Using the `@login_required` decorator
- Restricting access to object owners
- Using the messages framework
- Setting up user authentication

### ✅ What You've Built
- Complete post creation workflow
- Post editing with pre-filled data
- Post deletion with confirmation
- Comment creation on posts
- User registration and login
- Access control for user-owned data

---

## What's Coming in Part 4

In Part 4, we'll:
- Implement class-based views (CBVs)
- Add search functionality
- Add filtering and sorting
- Implement pagination
- Use Django's messages framework more extensively
