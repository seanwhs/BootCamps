# Part 4: Class-Based Views, Search, Filtering, Pagination, and Messaging

## Welcome to Part 4!

You've built a fully functional CRUD application with user authentication. But as your application grows, you might notice that your views are becoming repetitive. In this part, we'll:

1. **Refactor** our function-based views to **class-based views** (CBVs) — making our code more reusable and organized
2. **Add search** functionality so users can find posts by title or content
3. **Implement filtering** by category, author, status, and date
4. **Add pagination** to handle large numbers of posts
5. **Enhance messaging** for better user feedback

By the end of this part, your blog will be more professional, scalable, and maintainable.

Let's begin!

---

## Target 4.1: Understanding Class-Based Views

### The Concept

**Class-Based Views (CBVs)** are an alternative to function-based views. Instead of writing functions, you write classes that inherit from Django's built-in view classes.

Think of CBVs like LEGO blocks:
- **Function-Based Views**: You build everything from scratch each time
- **Class-Based Views**: You snap together pre-built blocks and customize as needed

### Why Use Class-Based Views?

1. **Reusability**: Inherit common functionality
2. **Organization**: Related logic is grouped together
3. **DRY Principle**: Don't repeat yourself
4. **Built-in Features**: Django provides many generic CBVs

### The CBV Hierarchy

```
View
  ├── TemplateView
  ├── RedirectView
  ├── FormView
  ├── ListView
  ├── DetailView
  ├── CreateView
  ├── UpdateView
  └── DeleteView
```

### Function-Based vs Class-Based Comparison

| Feature | Function-Based | Class-Based |
|---------|---------------|-------------|
| **Syntax** | Simple functions | Classes with methods |
| **Flexibility** | Very flexible | Somewhat rigid |
| **Reusability** | Limited | High (inheritance) |
| **Complexity** | Less complex | More complex initially |
| **Built-in Features** | Minimal | Many (pagination, etc.) |
| **Best For** | Simple views | Complex, repetitive views |

### When to Use Each

**Use Function-Based Views when:**
- The view is very simple
- You're new to Django
- You need very specific custom behavior

**Use Class-Based Views when:**
- You have repetitive CRUD operations
- You need built-in features (pagination, form handling)
- You want clean, maintainable code

---

## Target 4.2: Refactoring Blog List to Class-Based

### The Concept

We'll start by refactoring our `blog_list` view to a `ListView`. This is one of the simplest CBVs — it just displays a list of objects.

### The Implementation

**File: `blog/views.py`** (replace blog_list with class-based view)

First, let's add the necessary imports at the top:

```python
from django.views.generic import ListView, DetailView, CreateView, UpdateView, DeleteView
from django.contrib.auth.mixins import LoginRequiredMixin, UserPassesTestMixin
from django.urls import reverse_lazy
from django.db.models import Q
from django.contrib import messages

# ... keep your existing imports ...

# Now replace the blog_list function with:

class PostListView(ListView):
    """
    Class-based view for displaying a list of blog posts.
    
    This view handles:
    - Displaying all published posts
    - Search functionality
    - Filtering by category, author, status
    - Pagination
    - Sorting
    """
    model = Post
    template_name = 'blog/blog_list.html'
    context_object_name = 'posts'  # Name used in the template
    paginate_by = 10  # Number of posts per page
    ordering = ['-published_at']  # Default ordering
    
    def get_queryset(self):
        """
        Customize the queryset based on URL parameters.
        
        This is where we implement search and filtering.
        """
        queryset = super().get_queryset()
        
        # Base query: only show published posts
        queryset = queryset.filter(
            status=Post.Status.PUBLISHED,
            published_at__lte=timezone.now()
        ).select_related('author', 'category').prefetch_related('tags')
        
        # Get URL parameters
        search_query = self.request.GET.get('q')
        category_slug = self.request.GET.get('category')
        author_id = self.request.GET.get('author')
        status_filter = self.request.GET.get('status')
        sort_by = self.request.GET.get('sort')
        
        # Search functionality
        if search_query:
            queryset = queryset.filter(
                Q(title__icontains=search_query) |
                Q(content__icontains=search_query) |
                Q(excerpt__icontains=search_query) |
                Q(author__username__icontains=search_query)
            )
        
        # Category filtering
        if category_slug:
            queryset = queryset.filter(category__slug=category_slug)
        
        # Author filtering
        if author_id:
            queryset = queryset.filter(author_id=author_id)
        
        # Status filtering (only for staff)
        if status_filter and self.request.user.is_staff:
            queryset = queryset.filter(status=status_filter)
        
        # Sorting
        if sort_by:
            if sort_by == 'title':
                queryset = queryset.order_by('title')
            elif sort_by == '-title':
                queryset = queryset.order_by('-title')
            elif sort_by == 'created_at':
                queryset = queryset.order_by('created_at')
            elif sort_by == '-created_at':
                queryset = queryset.order_by('-created_at')
            elif sort_by == 'published_at':
                queryset = queryset.order_by('published_at')
            elif sort_by == '-published_at':
                queryset = queryset.order_by('-published_at')
            elif sort_by == 'author':
                queryset = queryset.order_by('author__username')
            elif sort_by == '-author':
                queryset = queryset.order_by('-author__username')
        
        return queryset
    
    def get_context_data(self, **kwargs):
        """
        Add extra context data to the template.
        
        This includes categories with post counts and filter parameters.
        """
        context = super().get_context_data(**kwargs)
        
        # Get all categories with published post count
        categories = Category.objects.annotate(
            post_count=Count('posts', filter=Q(posts__status=Post.Status.PUBLISHED))
        ).filter(post_count__gt=0)
        
        # Get all authors with published posts
        authors = User.objects.filter(
            blog_posts__status=Post.Status.PUBLISHED
        ).distinct().order_by('username')
        
        # Add to context
        context['categories'] = categories
        context['authors'] = authors
        context['page_title'] = 'Blog Posts'
        context['year'] = timezone.now().year
        
        # Add current filter parameters for the template
        context['current_filters'] = {
            'q': self.request.GET.get('q', ''),
            'category': self.request.GET.get('category', ''),
            'author': self.request.GET.get('author', ''),
            'sort': self.request.GET.get('sort', ''),
        }
        
        return context
```

Now let's update the blog_list template to work with the class-based view:

**File: `blog/templates/blog/blog_list.html`** (updated for pagination)

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

<!-- Search and Filter Bar -->
<div class="content" style="margin-bottom: 2rem;">
    <form method="get" style="display: flex; flex-wrap: wrap; gap: 1rem; align-items: end;">
        <!-- Search -->
        <div style="flex: 2; min-width: 200px;">
            <label style="display: block; font-weight: bold; margin-bottom: 0.25rem;">Search</label>
            <input type="text" name="q" value="{{ current_filters.q }}" 
                   style="width: 100%; padding: 0.5rem; border: 1px solid #ddd; border-radius: 4px;"
                   placeholder="Search posts...">
        </div>
        
        <!-- Category Filter -->
        <div style="flex: 1; min-width: 150px;">
            <label style="display: block; font-weight: bold; margin-bottom: 0.25rem;">Category</label>
            <select name="category" style="width: 100%; padding: 0.5rem; border: 1px solid #ddd; border-radius: 4px;">
                <option value="">All Categories</option>
                {% for category in categories %}
                    <option value="{{ category.slug }}" {% if current_filters.category == category.slug %}selected{% endif %}>
                        {{ category.name }} ({{ category.post_count }})
                    </option>
                {% endfor %}
            </select>
        </div>
        
        <!-- Author Filter -->
        <div style="flex: 1; min-width: 150px;">
            <label style="display: block; font-weight: bold; margin-bottom: 0.25rem;">Author</label>
            <select name="author" style="width: 100%; padding: 0.5rem; border: 1px solid #ddd; border-radius: 4px;">
                <option value="">All Authors</option>
                {% for author in authors %}
                    <option value="{{ author.id }}" {% if current_filters.author == author.id|stringformat:"s" %}selected{% endif %}>
                        {{ author.get_full_name|default:author.username }}
                    </option>
                {% endfor %}
            </select>
        </div>
        
        <!-- Sort -->
        <div style="flex: 1; min-width: 150px;">
            <label style="display: block; font-weight: bold; margin-bottom: 0.25rem;">Sort By</label>
            <select name="sort" style="width: 100%; padding: 0.5rem; border: 1px solid #ddd; border-radius: 4px;">
                <option value="-published_at" {% if current_filters.sort == '-published_at' %}selected{% endif %}>Newest First</option>
                <option value="published_at" {% if current_filters.sort == 'published_at' %}selected{% endif %}>Oldest First</option>
                <option value="title" {% if current_filters.sort == 'title' %}selected{% endif %}>Title A-Z</option>
                <option value="-title" {% if current_filters.sort == '-title' %}selected{% endif %}>Title Z-A</option>
                <option value="-created_at" {% if current_filters.sort == '-created_at' %}selected{% endif %}>Recently Created</option>
                <option value="author" {% if current_filters.sort == 'author' %}selected{% endif %}>Author A-Z</option>
            </select>
        </div>
        
        <!-- Submit Button -->
        <div style="flex: 0 0 auto;">
            <button type="submit" style="background: #3498db; color: white; border: none; padding: 0.5rem 1.5rem; border-radius: 4px; cursor: pointer;">
                Apply Filters
            </button>
            <a href="{% url 'blog:blog_list' %}" style="background: #95a5a6; color: white; padding: 0.5rem 1.5rem; border-radius: 4px; text-decoration: none; display: inline-block;">
                Clear
            </a>
        </div>
    </form>
</div>

<!-- Posts List -->
<div class="content">
    {% if page_obj %}
        {% for post in page_obj %}
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
                        in <a href="{% url 'blog:category_detail' post.category.slug %}" style="color: #3498db; text-decoration: none;">
                            {{ post.category.name }}
                        </a>
                    {% endif %}
                    
                    <!-- Author actions -->
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
                            <a href="{% url 'blog:tag_detail' tag.slug %}" style="background: #ecf0f1; padding: 0.2rem 0.6rem; border-radius: 12px; color: #2c3e50; text-decoration: none; font-size: 0.85rem;">
                                {{ tag.name }}
                            </a>
                            {% if not forloop.last %} {% endif %}
                        {% endfor %}
                    </p>
                {% endif %}
            </div>
        {% endfor %}
        
        <!-- Pagination -->
        {% if is_paginated %}
            <div style="display: flex; justify-content: center; gap: 0.5rem; margin-top: 2rem; padding-top: 1rem; border-top: 1px solid #eee;">
                {% if page_obj.has_previous %}
                    <a href="?page=1{% for key, value in request.GET.items %}{% if key != 'page' %}&{{ key }}={{ value }}{% endif %}{% endfor %}" 
                       style="padding: 0.5rem 1rem; background: #3498db; color: white; text-decoration: none; border-radius: 4px;">
                        First
                    </a>
                    <a href="?page={{ page_obj.previous_page_number }}{% for key, value in request.GET.items %}{% if key != 'page' %}&{{ key }}={{ value }}{% endif %}{% endfor %}" 
                       style="padding: 0.5rem 1rem; background: #3498db; color: white; text-decoration: none; border-radius: 4px;">
                        Previous
                    </a>
                {% endif %}
                
                <span style="padding: 0.5rem 1rem;">
                    Page {{ page_obj.number }} of {{ page_obj.paginator.num_pages }}
                </span>
                
                {% if page_obj.has_next %}
                    <a href="?page={{ page_obj.next_page_number }}{% for key, value in request.GET.items %}{% if key != 'page' %}&{{ key }}={{ value }}{% endif %}{% endfor %}" 
                       style="padding: 0.5rem 1rem; background: #3498db; color: white; text-decoration: none; border-radius: 4px;">
                        Next
                    </a>
                    <a href="?page={{ page_obj.paginator.num_pages }}{% for key, value in request.GET.items %}{% if key != 'page' %}&{{ key }}={{ value }}{% endif %}{% endfor %}" 
                       style="padding: 0.5rem 1rem; background: #3498db; color: white; text-decoration: none; border-radius: 4px;">
                        Last
                    </a>
                {% endif %}
            </div>
        {% endif %}
        
    {% else %}
        <p>No blog posts available. Check back later!</p>
    {% endif %}
</div>
{% endblock %}
```

---

## Target 4.3: Refactoring Post Detail to Class-Based

### The Concept

Next, we'll refactor `post_detail` to a `DetailView`. This is even simpler than ListView.

### The Implementation

**File: `blog/views.py`** (replace post_detail with class-based view)

```python
class PostDetailView(DetailView):
    """
    Class-based view for displaying a single blog post.
    
    This view handles:
    - Displaying the post content
    - Showing related posts
    - Displaying comments
    """
    model = Post
    template_name = 'blog/post_detail.html'
    context_object_name = 'post'
    slug_field = 'slug'
    slug_url_kwarg = 'slug'
    
    def get_queryset(self):
        """
        Only show published posts (or drafts for authors).
        """
        queryset = super().get_queryset()
        
        # If user is authenticated, allow them to see their own drafts
        if self.request.user.is_authenticated:
            return queryset.filter(
                Q(status=Post.Status.PUBLISHED) |
                Q(author=self.request.user)
            )
        else:
            return queryset.filter(status=Post.Status.PUBLISHED)
    
    def get_context_data(self, **kwargs):
        """
        Add extra context: recent posts and comments.
        """
        context = super().get_context_data(**kwargs)
        post = self.get_object()
        
        # Get recent posts (excluding current)
        recent_posts = Post.objects.filter(
            status=Post.Status.PUBLISHED
        ).exclude(id=post.id).order_by('-published_at')[:5]
        
        # Get approved comments
        comments = post.comments.filter(is_approved=True).order_by('created_at')
        
        # Add to context
        context['recent_posts'] = recent_posts
        context['comments'] = comments
        context['year'] = timezone.now().year
        
        return context
```

Now let's update the post_detail template:

**File: `blog/templates/blog/post_detail.html`** (updated for class-based view)

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

<div style="display: grid; grid-template-columns: 2fr 1fr; gap: 2rem;">
    <!-- Main Content -->
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
            <h3>Comments ({{ comments|length }})</h3>
            
            {% for comment in comments %}
                <div style="background: #f8f9fa; padding: 1rem; border-radius: 8px; margin-bottom: 1rem;">
                    <p><strong>{{ comment.author.get_full_name|default:comment.author.username }}</strong>
                    <span style="color: #7f8c8d; font-size: 0.9rem;">— {{ comment.created_at|date:"F j, Y g:i a" }}</span></p>
                    <p>{{ comment.content|linebreaks }}</p>
                </div>
            {% empty %}
                <p style="color: #7f8c8d;">No comments yet. Be the first to comment!</p>
            {% endfor %}
            
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
    
    <!-- Sidebar -->
    <div>
        <div style="background: #f8f9fa; padding: 1.5rem; border-radius: 8px; margin-bottom: 2rem;">
            <h3 style="margin-bottom: 1rem;">Recent Posts</h3>
            {% if recent_posts %}
                <ul style="list-style: none; padding: 0;">
                    {% for recent in recent_posts %}
                        <li style="margin-bottom: 0.75rem; padding-bottom: 0.75rem; border-bottom: 1px solid #eee;">
                            <a href="{{ recent.get_absolute_url }}" style="color: #2c3e50; text-decoration: none;">
                                {{ recent.title }}
                            </a>
                            <br>
                            <small style="color: #7f8c8d;">{{ recent.published_at|date:"F j, Y" }}</small>
                        </li>
                    {% endfor %}
                </ul>
            {% else %}
                <p style="color: #7f8c8d;">No recent posts.</p>
            {% endif %}
        </div>
        
        <div style="background: #f8f9fa; padding: 1.5rem; border-radius: 8px;">
            <h3 style="margin-bottom: 1rem;">About</h3>
            <p style="color: #7f8c8d; font-size: 0.9rem;">
                A Django blog built from scratch as part of the
                Mastering Django 6 tutorial series.
            </p>
            <p style="margin-top: 0.5rem;">
                <a href="{% url 'blog:about' %}" style="color: #3498db; text-decoration: none;">
                    Learn more →
                </a>
            </p>
        </div>
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

---

## Target 4.4: Refactoring CRUD Views to Class-Based

### The Concept

Now we'll refactor our CRUD views to use Django's generic editing views. These views handle forms, validation, and saving automatically.

### The Implementation

**File: `blog/views.py`** (replace CRUD functions with class-based views)

```python
class PostCreateView(LoginRequiredMixin, CreateView):
    """
    Class-based view for creating new blog posts.
    
    LoginRequiredMixin ensures only authenticated users can access.
    """
    model = Post
    form_class = PostForm
    template_name = 'blog/post_form.html'
    
    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        context['title'] = 'Create New Post'
        context['submit_text'] = 'Create Post'
        context['year'] = timezone.now().year
        return context
    
    def form_valid(self, form):
        """
        Set the author to the current user before saving.
        """
        form.instance.author = self.request.user
        
        # If status is published, set published_at
        if form.instance.status == Post.Status.PUBLISHED:
            form.instance.published_at = timezone.now()
        
        # Save the form
        response = super().form_valid(form)
        
        # Show success message
        messages.success(self.request, f'Your post "{form.instance.title}" has been created successfully!')
        
        return response
    
    def get_success_url(self):
        """
        Redirect to the post detail page after successful creation.
        """
        return reverse_lazy('blog:post_detail', kwargs={'slug': self.object.slug})


class PostUpdateView(LoginRequiredMixin, UserPassesTestMixin, UpdateView):
    """
    Class-based view for editing blog posts.
    
    UserPassesTestMixin ensures the user is the author of the post.
    """
    model = Post
    form_class = PostForm
    template_name = 'blog/post_form.html'
    slug_field = 'slug'
    slug_url_kwarg = 'slug'
    
    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        context['title'] = f'Edit Post: {self.object.title}'
        context['submit_text'] = 'Update Post'
        context['year'] = timezone.now().year
        
        # Pre-populate tags_input
        if self.object.tags.exists():
            tags_list = [tag.name for tag in self.object.tags.all()]
            context['form'].fields['tags_input'].initial = ', '.join(tags_list)
        
        return context
    
    def form_valid(self, form):
        """
        Handle status changes and save.
        """
        # Check if status changed to published
        old_status = self.get_object().status
        new_status = form.instance.status
        
        if new_status == Post.Status.PUBLISHED and old_status != Post.Status.PUBLISHED:
            form.instance.published_at = timezone.now()
        
        # Save the form
        response = super().form_valid(form)
        
        # Show success message
        messages.success(self.request, f'Your post "{form.instance.title}" has been updated!')
        
        return response
    
    def test_func(self):
        """
        Check that the current user is the author of the post.
        """
        post = self.get_object()
        return self.request.user == post.author
    
    def get_success_url(self):
        return reverse_lazy('blog:post_detail', kwargs={'slug': self.object.slug})


class PostDeleteView(LoginRequiredMixin, UserPassesTestMixin, DeleteView):
    """
    Class-based view for deleting blog posts.
    """
    model = Post
    template_name = 'blog/post_confirm_delete.html'
    slug_field = 'slug'
    slug_url_kwarg = 'slug'
    success_url = reverse_lazy('blog:blog_list')
    
    def test_func(self):
        """
        Check that the current user is the author of the post.
        """
        post = self.get_object()
        return self.request.user == post.author
    
    def delete(self, request, *args, **kwargs):
        """
        Override delete to add a success message.
        """
        post = self.get_object()
        post_title = post.title
        response = super().delete(request, *args, **kwargs)
        messages.success(request, f'Your post "{post_title}" has been deleted.')
        return response
    
    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        context['year'] = timezone.now().year
        return context
```

---

## Target 4.5: Refactoring Home Page to Class-Based

### The Concept

Even the home page can benefit from a class-based approach, though it's simpler than the others.

### The Implementation

**File: `blog/views.py`** (add TemplateView for home)

```python
from django.views.generic import TemplateView

class HomeView(TemplateView):
    """
    Class-based view for the homepage.
    """
    template_name = 'blog/home.html'
    
    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        
        # Get recent posts
        recent_posts = Post.objects.filter(
            status=Post.Status.PUBLISHED,
            published_at__lte=timezone.now()
        ).order_by('-published_at')[:5]
        
        # Get categories with post counts
        categories = Category.objects.annotate(
            post_count=Count('posts', filter=Q(posts__status=Post.Status.PUBLISHED))
        ).filter(post_count__gt=0)
        
        context['recent_posts'] = recent_posts
        context['categories'] = categories
        context['year'] = timezone.now().year
        
        return context
```

Now update the URLs to use the class-based views:

**File: `blog/urls.py`** (update)

```python
from django.urls import path
from . import views

app_name = 'blog'

urlpatterns = [
    # Public views (class-based)
    path('', views.HomeView.as_view(), name='home'),
    path('about/', views.about, name='about'),  # Keep function-based for now
    path('blog/', views.PostListView.as_view(), name='blog_list'),
    path('blog/<slug:slug>/', views.PostDetailView.as_view(), name='post_detail'),
    path('category/<slug:slug>/', views.category_detail, name='category_detail'),  # Keep function-based
    path('tag/<slug:slug>/', views.tag_detail, name='tag_detail'),  # Keep function-based
    
    # CRUD views (class-based)
    path('post/create/', views.PostCreateView.as_view(), name='post_create'),
    path('post/<slug:slug>/edit/', views.PostUpdateView.as_view(), name='post_edit'),
    path('post/<slug:slug>/delete/', views.PostDeleteView.as_view(), name='post_delete'),
    
    # Comment views (function-based)
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

## Target 4.6: Understanding Mixins and Method Order

### The Concept

**Mixins** are classes that provide reusable functionality. Django's `LoginRequiredMixin` and `UserPassesTestMixin` are examples.

### Mixin Order Matters!

When using multiple mixins, the order matters. The general rule:
1. **Put mixins first**
2. **Then put the base view class**

### The Implementation Example

```python
# Correct order
class PostUpdateView(LoginRequiredMixin, UserPassesTestMixin, UpdateView):
    pass

# WRONG order (LoginRequiredMixin won't work properly)
class PostUpdateView(UpdateView, LoginRequiredMixin, UserPassesTestMixin):
    pass
```

### Common Mixins

| Mixin | Purpose |
|-------|---------|
| `LoginRequiredMixin` | Require user to be logged in |
| `UserPassesTestMixin` | Require a custom test to pass |
| `PermissionRequiredMixin` | Require specific permissions |
| `FormMixin` | Add form handling functionality |
| `ContextMixin` | Add context data |
| `SingleObjectMixin` | Add single object fetching |

---

## Target 4.7: Deep Dive into Pagination

### The Concept

**Pagination** splits a large list of items across multiple pages. Django's `Paginator` class handles this for you.

### How Pagination Works

```
All Posts (100)
    │
    ▼
Paginator (10 per page)
    │
    ├── Page 1 (items 1-10)
    ├── Page 2 (items 11-20)
    ├── Page 3 (items 21-30)
    ├── Page 4 (items 31-40)
    └── ...
```

### Manual Pagination (if you need it)

```python
from django.core.paginator import Paginator

def my_view(request):
    posts = Post.objects.all()
    paginator = Paginator(posts, 10)  # Show 10 per page
    
    page_number = request.GET.get('page')
    page_obj = paginator.get_page(page_number)
    
    return render(request, 'template.html', {'page_obj': page_obj})
```

### Pagination in Templates

```html
{% if page_obj.has_previous %}
    <a href="?page=1">&laquo; First</a>
    <a href="?page={{ page_obj.previous_page_number }}">Previous</a>
{% endif %}

<span>Page {{ page_obj.number }} of {{ page_obj.paginator.num_pages }}</span>

{% if page_obj.has_next %}
    <a href="?page={{ page_obj.next_page_number }}">Next</a>
    <a href="?page={{ page_obj.paginator.num_pages }}">Last &raquo;</a>
{% endif %}
```

---

## The Verification

Let's test our refactored application:

### Step 1: Test the Blog List with Filters

1. Visit **http://127.0.0.1:8000/blog/**
2. Try the search: type "Django" and click "Apply Filters"
3. Filter by category: select a category from the dropdown
4. Filter by author: select a specific author
5. Try different sort options
6. Verify pagination works (create more than 10 posts if needed)

### Step 2: Test Post Creation

1. Click "New Post" (you must be logged in)
2. Fill in the form
3. Submit and verify the post is created
4. Check that you receive a success message

### Step 3: Test Post Editing

1. Click "Edit" on one of your posts
2. Make changes and submit
3. Verify the changes are saved
4. Check that you receive a success message

### Step 4: Test Post Deletion

1. Click "Delete" on one of your posts
2. Confirm deletion
3. Verify the post is removed
4. Check that you receive a success message

### Step 5: Test Access Control

1. Try to edit a post that belongs to another user
2. You should be redirected with an error message

---

## Summary: Function-Based vs Class-Based Comparison

| View | Function-Based | Class-Based |
|------|---------------|-------------|
| **Home** | `def home(request):` | `class HomeView(TemplateView):` |
| **Blog List** | `def blog_list(request):` | `class PostListView(ListView):` |
| **Post Detail** | `def post_detail(request, slug):` | `class PostDetailView(DetailView):` |
| **Post Create** | `def post_create(request):` | `class PostCreateView(CreateView):` |
| **Post Edit** | `def post_edit(request, slug):` | `class PostUpdateView(UpdateView):` |
| **Post Delete** | `def post_delete(request, slug):` | `class PostDeleteView(DeleteView):` |

---

## Common Errors and Troubleshooting

### Error: "AttributeError: 'PostListView' object has no attribute 'paginator'"
**Cause**: Missing `paginate_by` attribute
**Fix**: Add `paginate_by = 10` to the view

### Error: "Reverse for 'post_detail' not found"
**Cause**: Missing `get_success_url` or `get_absolute_url`
**Fix**: Define `get_success_url()` in the view or `get_absolute_url()` in the model

### Error: "You don't have permission to edit this post"
**Cause**: `UserPassesTestMixin` test failed
**Fix**: Check that `test_func()` correctly checks permissions

### Error: "Page not found (404)"
**Cause**: Slug doesn't exist or post is not published
**Fix**: Check the query in `get_queryset()` is filtering correctly

---

## Challenge: Extend the Class-Based Views

### Challenge 1: Add Author Statistics
Add a method to `PostListView` that calculates:
- Total number of posts by each author
- Average comments per post
- Most recent post date

### Challenge 2: Create a Comment Moderation View
Create a class-based view for moderating comments:
- Show comments pending approval
- Allow bulk approve/delete actions
- Use `UserPassesTestMixin` to restrict to staff or post authors

### Challenge 3: Add a Search Results Page
Create a dedicated search results page that:
- Shows comprehensive search results
- Highlights matching text
- Includes advanced search options

### Challenge 4: Implement AJAX Filtering
Add JavaScript to load filtered results without page refresh.

---

## What You've Learned in Part 4

### ✅ Skills Acquired
- Understanding class-based views
- Refactoring function views to class views
- Implementing search with Q objects
- Adding filtering with URL parameters
- Using pagination
- Working with mixins
- Handling form validation in class-based views
- Using reverse_lazy for URL resolution

### ✅ What You've Built
- A searchable blog listing
- Filterable posts by category, author, and status
- Pagination for large post lists
- Clean, maintainable class-based views
- Consistent message handling

---

## What's Coming in Part 5

In Part 5, we'll:
- Implement user profiles
- Add user dashboards
- Implement password reset functionality
- Add user permissions and groups
- Enhance security with proper authorization
- Add user account management features

Your blog will become a full-featured multi-user platform!
