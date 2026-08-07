# Part 6: Advanced Django Architecture and Application Design

## Welcome to Part 6!

You've built a full-featured blog with authentication, CRUD operations, and a professional user interface. Now it's time to take a step back and understand **how Django actually works** and how to structure larger applications.

In this part, we'll:

1. **Deep dive into the Django request lifecycle**
2. **Create custom middleware** for cross-cutting concerns
3. **Implement context processors** for global template variables
4. **Work with Django signals** for decoupled functionality
5. **Build a service layer** for clean business logic
6. **Organize a maintainable application structure**

By the end of this part, you'll understand Django at a deeper level and be able to architect larger, more complex applications.

Let's begin!

---

## Target 6.1: Understanding Django's Request Lifecycle

### The Concept

When a request comes into Django, it goes through a well-defined pipeline. Understanding this pipeline is crucial for debugging and for knowing where to add custom functionality.

### The Complete Request Lifecycle

```
1. Browser makes HTTP request
   ↓
2. Django creates an HttpRequest object
   ↓
3. Request passes through all MIDDLEWARE (in order)
   ↓
4. URL dispatcher finds matching view
   ↓
5. View executes business logic
   ↓
6. View returns an HttpResponse object
   ↓
7. Response passes through all MIDDLEWARE (in reverse order)
   ↓
8. Django returns the response to the browser
```

### Detailed Breakdown

**Step 1: Browser Request**

```
GET /blog/django-tutorial/ HTTP/1.1
Host: localhost:8000
User-Agent: Mozilla/5.0 ...
Accept: text/html,application/xhtml+xml
Cookie: sessionid=abc123...
```

**Step 2: HttpRequest Object**

Django creates a Python object containing:
- `request.method`: "GET", "POST", etc.
- `request.GET`: Query parameters
- `request.POST`: POST data
- `request.COOKIES`: Cookie data
- `request.user`: Authenticated user (if any)
- `request.session`: Session data
- `request.META`: Headers and server metadata

**Step 3: Middleware Processing (Request Phase)**

Each middleware can:
- Process the request
- Add to `request` object
- Short-circuit and return a response (bypassing later steps)

```python
# Example: Authentication middleware adds user
def process_request(self, request):
    request.user = get_user(request)
    return None  # Continue processing
```

**Step 4: URL Resolution**

Django checks each URL pattern in order:

```python
# config/urls.py
urlpatterns = [
    path('admin/', admin.site.urls),
    path('', include('blog.urls')),
]

# blog/urls.py
urlpatterns = [
    path('blog/<slug:slug>/', views.PostDetailView.as_view()),
]
```

Matching: `/blog/django-tutorial/` → `PostDetailView`

**Step 5: View Execution**

The view:
1. Gets the post from the database
2. Builds context data
3. Renders the template
4. Returns an HttpResponse

**Step 6: HttpResponse Object**

Django creates a response with:
- Status code (200 OK, 404, etc.)
- Headers (Content-Type, Cache-Control, etc.)
- Content (HTML, JSON, etc.)

**Step 7: Middleware Processing (Response Phase)**

Middleware can:
- Modify the response
- Add headers
- Log the response
- Compress content

**Step 8: Response Returned**

Django converts the HttpResponse to HTTP and sends it back to the browser.

---

## Target 6.2: Creating Custom Middleware

### The Concept

**Middleware** is code that runs on every request/response. It's perfect for:
- Authentication checks
- Request logging
- Performance monitoring
- Adding security headers
- Rate limiting
- CORS handling

### The Implementation

**File: `blog/middleware.py`** (create new file)

```python
import logging
import time
from django.http import HttpResponse
from django.urls import reverse

logger = logging.getLogger(__name__)


class RequestLoggingMiddleware:
    """
    Middleware to log all requests with timing information.
    
    This helps with debugging and performance monitoring.
    """
    
    def __init__(self, get_response):
        self.get_response = get_response
    
    def __call__(self, request):
        # Request phase
        start_time = time.time()
        
        # Process the request
        response = self.get_response(request)
        
        # Response phase
        duration = time.time() - start_time
        
        # Log the request
        logger.info(
            f"Request: {request.method} {request.path} "
            f"User: {request.user.username if request.user.is_authenticated else 'Anonymous'} "
            f"Duration: {duration:.3f}s "
            f"Status: {response.status_code}"
        )
        
        return response


class MaintenanceModeMiddleware:
    """
    Middleware to put the site in maintenance mode.
    
    When enabled, shows a maintenance page instead of the actual site.
    """
    
    MAINTENANCE_MODE = False  # Set to True to enable
    ALLOWED_IPS = ['127.0.0.1', '::1']  # IPs that can bypass maintenance
    
    def __init__(self, get_response):
        self.get_response = get_response
    
    def __call__(self, request):
        # Check if maintenance mode is enabled
        if self.MAINTENANCE_MODE:
            # Allow staff users and specific IPs
            if (request.user.is_staff or 
                request.META.get('REMOTE_ADDR') in self.ALLOWED_IPS):
                return self.get_response(request)
            
            # Check if this is an admin or login request
            if (request.path.startswith('/admin/') or 
                request.path == reverse('login')):
                return self.get_response(request)
            
            # Show maintenance page
            return HttpResponse(
                '<html><body><h1>Under Maintenance</h1>'
                '<p>We\'ll be back soon!</p></body></html>',
                status=503
            )
        
        return self.get_response(request)


class SecurityHeadersMiddleware:
    """
    Middleware to add security headers to all responses.
    
    This helps protect against common web vulnerabilities.
    """
    
    def __init__(self, get_response):
        self.get_response = get_response
    
    def __call__(self, request):
        response = self.get_response(request)
        
        # Add security headers
        response['X-Content-Type-Options'] = 'nosniff'
        response['X-Frame-Options'] = 'DENY'
        response['X-XSS-Protection'] = '1; mode=block'
        
        # Content Security Policy (CSP)
        response['Content-Security-Policy'] = (
            "default-src 'self'; "
            "img-src 'self' data: https:; "
            "style-src 'self' 'unsafe-inline'; "
            "script-src 'self' 'unsafe-inline';"
        )
        
        # Referrer Policy
        response['Referrer-Policy'] = 'strict-origin-when-cross-origin'
        
        return response


class QueryCountMiddleware:
    """
    Middleware to log the number of database queries per request.
    
    This helps identify performance issues.
    """
    
    def __init__(self, get_response):
        self.get_response = get_response
    
    def __call__(self, request):
        # Reset query count before request
        from django.db import connection
        connection.queries_log.clear()
        
        response = self.get_response(request)
        
        # Log query count
        query_count = len(connection.queries)
        if query_count > 10:  # Warn if more than 10 queries
            logger.warning(
                f"Path: {request.path} - "
                f"Query count: {query_count} - "
                f"User: {request.user.username if request.user.is_authenticated else 'Anonymous'}"
            )
        
        return response
```

### Adding Middleware to Settings

**File: `config/settings.py`** (update MIDDLEWARE)

```python
# config/settings.py

MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
    
    # Custom middleware
    'blog.middleware.RequestLoggingMiddleware',
    'blog.middleware.SecurityHeadersMiddleware',
    'blog.middleware.QueryCountMiddleware',
    # 'blog.middleware.MaintenanceModeMiddleware',  # Uncomment to enable
]
```

---

## Target 6.3: Implementing Context Processors

### The Concept

**Context Processors** are functions that add variables to EVERY template's context. This is perfect for:
- Site-wide settings
- User information
- Navigation menus
- Global constants

### The Implementation

**File: `blog/context_processors.py`** (create/update)

```python
from django.conf import settings
from django.db.models import Q, Count
from datetime import datetime
from .models import Category, Post


def global_context(request):
    """
    Add global variables to all templates.
    
    This runs for every request and adds these variables
    to every template's context.
    """
    context = {}
    
    # Site information
    context['site_name'] = 'Django Blog'
    context['site_description'] = 'A Django blog built from scratch'
    context['current_year'] = datetime.now().year
    
    # Navigation - get all categories with post counts
    categories = Category.objects.annotate(
        post_count=Count('posts', filter=Q(posts__status=Post.Status.PUBLISHED))
    ).filter(post_count__gt=0)
    context['categories_nav'] = categories
    
    # User information (if authenticated)
    if hasattr(request, 'user') and request.user.is_authenticated:
        context['user_is_authenticated'] = True
        context['user_username'] = request.user.username
        context['user_full_name'] = request.user.get_full_name()
        context['user_avatar_url'] = request.user.profile.get_avatar_url()
        context['user_post_count'] = request.user.blog_posts.count()
        context['user_comment_count'] = request.user.blog_comments.count()
    
    # Debug information (only in development)
    if settings.DEBUG:
        context['debug_mode'] = True
    
    return context
```

### Registering Context Processors

**File: `config/settings.py`** (update TEMPLATES)

```python
# config/settings.py

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [
            BASE_DIR / 'templates',
        ],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.debug',
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
                
                # Our custom context processors
                'blog.context_processors.global_context',
            ],
        },
    },
]
```

---

## Target 6.4: Working with Django Signals

### The Concept

**Signals** allow different parts of your application to communicate without being directly coupled. Think of them like a notification system.

### The Implementation

**File: `blog/signals.py`** (create new file)

```python
from django.db.models.signals import post_save, pre_save, post_delete, m2m_changed
from django.contrib.auth.models import User
from django.dispatch import receiver
from django.utils import timezone
from django.core.mail import send_mail
from django.conf import settings
from .models import Profile, Post, Comment


@receiver(post_save, sender=User)
def create_user_profile(sender, instance, created, **kwargs):
    """
    Create a profile for every new user.
    
    This is called whenever a User is saved.
    If it's a new user (created=True), create a profile.
    """
    if created:
        Profile.objects.get_or_create(user=instance)


@receiver(post_save, sender=User)
def send_welcome_email(sender, instance, created, **kwargs):
    """
    Send a welcome email to new users.
    """
    if created:
        subject = 'Welcome to Django Blog!'
        message = f'''
        Hello {instance.username},
        
        Welcome to Django Blog! We're excited to have you join our community.
        
        Here are some things you can do:
        - Create and publish your own blog posts
        - Comment on other posts
        - Connect with other developers
        
        Get started by visiting your dashboard:
        {settings.SITE_URL}/dashboard/
        
        Best regards,
        The Django Blog Team
        '''
        
        send_mail(
            subject,
            message,
            settings.DEFAULT_FROM_EMAIL,
            [instance.email],
            fail_silently=True,
        )


@receiver(post_save, sender=Post)
def handle_post_publication(sender, instance, created, **kwargs):
    """
    Perform actions when a post is saved.
    
    If a post is published, send notifications.
    """
    if not created:
        try:
            old = Post.objects.get(id=instance.id)
            
            if (old.status != Post.Status.PUBLISHED and 
                instance.status == Post.Status.PUBLISHED):
                
                send_mail(
                    f'Your post "{instance.title}" has been published!',
                    f'''
                    Hello {instance.author.username},
                    
                    Your post "{instance.title}" is now live and visible to everyone!
                    
                    View it here: {settings.SITE_URL}{instance.get_absolute_url()}
                    
                    Congratulations on publishing your post!
                    
                    The Django Blog Team
                    ''',
                    settings.DEFAULT_FROM_EMAIL,
                    [instance.author.email],
                    fail_silently=True,
                )
        except Post.DoesNotExist:
            pass


@receiver(post_save, sender=Comment)
def handle_comment_creation(sender, instance, created, **kwargs):
    """
    Handle comment creation and send notifications.
    """
    if created:
        post_author = instance.post.author
        
        if post_author != instance.author:
            send_mail(
                f'New comment on your post "{instance.post.title}"',
                f'''
                Hello {post_author.username},
                
                {instance.author.username} has commented on your post "{instance.post.title}":
                
                "{instance.content}"
                
                View the comment here:
                {settings.SITE_URL}{instance.post.get_absolute_url()}
                
                The Django Blog Team
                ''',
                settings.DEFAULT_FROM_EMAIL,
                [post_author.email],
                fail_silently=True,
            )
```

### Registering Signals

**File: `blog/apps.py`** (update)

```python
from django.apps import AppConfig


class BlogConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'blog'
    
    def ready(self):
        """
        Import signals when the app is ready.
        
        This ensures signals are registered when Django starts.
        """
        import blog.signals  # noqa
```

---

## Target 6.5: Building a Service Layer

### The Concept

As your application grows, putting all logic in views becomes messy. A **service layer** provides a clean separation between controllers (views) and business logic.

### The Implementation

**File: `blog/services/post_service.py`** (create new directory and file)

First, create the services directory:

```bash
mkdir -p blog/services
touch blog/services/__init__.py
```

Now create the post service:

**File: `blog/services/post_service.py`**

```python
from django.db import transaction
from django.contrib.auth.models import User
from django.utils import timezone
from django.core.exceptions import ValidationError
from typing import List, Optional, Dict, Any
from datetime import datetime, timedelta

from ..models import Post, Category, Tag, Comment
from ..forms import PostForm, CommentForm


class PostService:
    """
    Service layer for post-related business logic.
    
    This encapsulates all complex operations involving posts,
    keeping views clean and focused on request/response handling.
    """
    
    @staticmethod
    def create_post(data: Dict[str, Any], author: User) -> Post:
        """
        Create a new post with validation.
        
        Args:
            data: Dictionary containing post data
            author: The user creating the post
            
        Returns:
            Post: The created post instance
            
        Raises:
            ValidationError: If the data is invalid
        """
        form = PostForm(data, data.get('files', {}))
        
        if not form.is_valid():
            raise ValidationError(form.errors)
        
        post = form.save(commit=False)
        post.author = author
        
        if post.status == Post.Status.PUBLISHED:
            post.published_at = timezone.now()
        
        post.save()
        form.save_m2m()  # Save many-to-many relationships
        
        return post
    
    @staticmethod
    def update_post(post: Post, data: Dict[str, Any], user: User) -> Post:
        """
        Update an existing post.
        
        Args:
            post: The post to update
            data: Dictionary containing updated data
            user: The user making the change
            
        Returns:
            Post: The updated post instance
            
        Raises:
            PermissionError: If user doesn't own the post
            ValidationError: If the data is invalid
        """
        if post.author != user:
            raise PermissionError("You don't have permission to edit this post")
        
        form = PostForm(data, data.get('files', {}), instance=post)
        
        if not form.is_valid():
            raise ValidationError(form.errors)
        
        updated_post = form.save(commit=False)
        
        if updated_post.status == Post.Status.PUBLISHED and post.status != Post.Status.PUBLISHED:
            updated_post.published_at = timezone.now()
        
        updated_post.save()
        form.save_m2m()
        
        return updated_post
    
    @staticmethod
    def delete_post(post: Post, user: User) -> bool:
        """
        Delete a post.
        
        Args:
            post: The post to delete
            user: The user making the deletion
            
        Returns:
            bool: True if deleted successfully
            
        Raises:
            PermissionError: If user doesn't own the post
        """
        if post.author != user:
            raise PermissionError("You don't have permission to delete this post")
        
        post.delete()
        return True
    
    @staticmethod
    def get_published_posts() -> List[Post]:
        """Get all published posts."""
        return Post.objects.filter(
            status=Post.Status.PUBLISHED,
            published_at__lte=timezone.now()
        ).select_related('author', 'category')
    
    @staticmethod
    def get_user_posts(user: User) -> List[Post]:
        """Get all posts by a specific user."""
        return Post.objects.filter(author=user)
    
    @staticmethod
    def search_posts(query: str) -> List[Post]:
        """Search posts by title, content, or excerpt."""
        from django.db.models import Q
        
        return Post.objects.filter(
            Q(title__icontains=query) |
            Q(content__icontains=query) |
            Q(excerpt__icontains=query)
        ).filter(
            status=Post.Status.PUBLISHED
        ).order_by('-published_at')
    
    @staticmethod
    def get_post_stats(user: User) -> Dict[str, Any]:
        """Get statistics for a user's posts."""
        posts = Post.objects.filter(author=user)
        
        return {
            'total': posts.count(),
            'published': posts.filter(status=Post.Status.PUBLISHED).count(),
            'draft': posts.filter(status=Post.Status.DRAFT).count(),
            'archived': posts.filter(status=Post.Status.ARCHIVED).count(),
            'total_comments': Comment.objects.filter(post__author=user).count(),
        }
```

---

## The Verification

### Step 1: Test Middleware

```bash
# Start the server
python manage.py runserver

# Visit any page and check the console
# You should see log messages like:
# INFO: Request: GET /blog/ User: admin Duration: 0.045s Status: 200

# Check response headers
curl -I http://127.0.0.1:8000/
# You should see security headers:
# X-Content-Type-Options: nosniff
# X-Frame-Options: DENY
# X-XSS-Protection: 1; mode=block
```

### Step 2: Test Context Processors

```bash
# Edit any template and add:
# {{ site_name }}
# {{ current_year }}
# {{ categories_nav }}

# Reload the page
# You should see these variables populated
```

### Step 3: Test Signals

```bash
# Create a new user
# Check console for welcome email

# Create a new post and publish it
# Check console for publication notification
```

### Step 4: Test Service Layer

```bash
# In Django shell:
python manage.py shell

from blog.services.post_service import PostService
from django.contrib.auth.models import User

user = User.objects.first()
stats = PostService.get_post_stats(user)
print(stats)
```

---

## What You've Learned in Part 6

### ✅ Skills Acquired
- Understanding Django's request lifecycle
- Creating custom middleware
- Implementing context processors
- Working with Django signals
- Building a service layer
- Organizing large Django applications

### ✅ What You've Built
- Request logging middleware
- Security headers middleware
- Global context processors
- Signal handlers for user creation
- Signal handlers for post publication
- Service layer for business logic
