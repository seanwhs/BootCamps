# Part 9: Performance, Security Hardening, and Production Configuration

## Welcome to Part 9!

You've built a comprehensive blog with tests, logging, and all the features users expect. Now it's time to prepare for the real world. In this part, we'll:

1. **Optimize ORM queries** for better performance
2. **Implement caching** to reduce database load
3. **Add database indexes** for faster queries
4. **Hardened security** with production settings
5. **Configure environment variables** for sensitive data
6. **Set up PostgreSQL** as your production database
7. **Perform a security audit** of your application

By the end of this part, your application will be ready for production deployment.

Let's begin!

---

## Target 9.1: ORM Query Optimization

### The Concept

As your application grows, database queries can become a bottleneck. Django's ORM is powerful, but it can also generate inefficient queries if you're not careful.

### Common Performance Issues

1. **N+1 Query Problem**: Fetching related data in a loop
2. **Missing Indexes**: Queries scanning entire tables
3. **Unnecessary Data**: Fetching fields you don't need
4. **Over-fetching**: Getting more data than necessary

### The Implementation

**File: `blog/services/post_service.py`** (optimize queries)

```python
from django.db.models import Prefetch, Q, F, Count, Avg, Sum
from django.db import connection
import time

class PostService:
    @staticmethod
    def get_optimized_posts():
        """
        Get posts with optimized queries.
        
        Uses select_related for foreign keys and prefetch_related
        for many-to-many relationships to avoid N+1 queries.
        """
        return Post.objects.filter(
            status=Post.Status.PUBLISHED,
            published_at__lte=timezone.now()
        ).select_related(
            'author',  # Foreign key to User
            'category'  # Foreign key to Category
        ).prefetch_related(
            'tags',  # Many-to-many to Tag
            Prefetch('comments', queryset=Comment.objects.filter(
                is_approved=True
            ).select_related('author'))
        ).only(
            'title', 'slug', 'content', 'excerpt', 
            'published_at', 'status', 'author__username',
            'author__first_name', 'author__last_name',
            'category__name', 'category__slug'
        ).defer(
            'meta_description', 'meta_keywords'  # Don't load unless needed
        )
    
    @staticmethod
    def get_post_with_comment_count(slug):
        """
        Get a single post with comment count using aggregation.
        """
        return Post.objects.filter(
            slug=slug,
            status=Post.Status.PUBLISHED
        ).select_related('author', 'category').annotate(
            comment_count=Count('comments', filter=Q(comments__is_approved=True))
        ).first()
    
    @staticmethod
    def bulk_create_posts(posts_data):
        """
        Bulk create posts (much faster than individual saves).
        """
        posts = []
        for data in posts_data:
            posts.append(Post(**data))
        
        # Bulk create with batch_size
        return Post.objects.bulk_create(posts, batch_size=100)
    
    @staticmethod
    def get_posts_with_stats():
        """
        Get posts with aggregated statistics.
        """
        return Post.objects.filter(
            status=Post.Status.PUBLISHED
        ).select_related('author').annotate(
            comment_count=Count('comments'),
            avg_rating=Avg('comments__rating'),  # If you had ratings
            word_count=Sum('content')  # Example of aggregation
        ).order_by('-comment_count')[:10]
    
    @staticmethod
    def log_query_performance():
        """
        Log the performance of the last query.
        """
        from django.db import connection
        query = connection.queries[-1]
        print(f"Query: {query['sql']}")
        print(f"Time: {query['time']} seconds")
```

### Using QuerySet Methods Effectively

```python
# Bad: N+1 queries
posts = Post.objects.all()
for post in posts:
    print(post.author.username)  # One query per post!

# Good: One query with select_related
posts = Post.objects.select_related('author').all()
for post in posts:
    print(post.author.username)  # Already loaded!

# Bad: Filtering in Python
posts = Post.objects.all()
published = [p for p in posts if p.status == 'published']

# Good: Filtering in database
posts = Post.objects.filter(status='published')

# Bad: Loading all data then slicing
posts = Post.objects.all()[:10]

# Good: Efficient slicing with limit
posts = Post.objects.all()[:10]  # Django optimizes this

# Bad: Count all records
if len(posts) > 0:
    print("Has posts")

# Good: Use exists()
if posts.exists():
    print("Has posts")

# Bad: Multiple queries for counts
post_count = Post.objects.count()
published_count = Post.objects.filter(status='published').count()

# Good: Single query with aggregation
from django.db.models import Count, Q
stats = Post.objects.aggregate(
    total=Count('id'),
    published=Count('id', filter=Q(status='published'))
)
```

---

## Target 9.2: Implementing Database Indexes

### The Concept

**Indexes** are like book indexes — they help the database find data faster. Without indexes, the database must scan every row.

### The Implementation

**File: `blog/models.py`** (update with indexes)

```python
class Post(models.Model):
    # ... existing fields ...
    
    class Meta:
        ordering = ['-created_at']
        indexes = [
            # Composite index for common queries
            models.Index(fields=['status', 'published_at']),
            
            # Index for filtering by author
            models.Index(fields=['author']),
            
            # Index for slug lookups
            models.Index(fields=['slug']),
            
            # Index for date filtering
            models.Index(fields=['published_at']),
            
            # Functional index for full-text search (PostgreSQL only)
            # models.Index(
            #     GinIndex(
            #         name='post_search_idx',
            #         fields=['title', 'content'],
            #     )
            # ),
        ]

class Comment(models.Model):
    # ... existing fields ...
    
    class Meta:
        ordering = ['created_at']
        indexes = [
            # Index for filtering comments by post
            models.Index(fields=['post', 'created_at']),
            
            # Index for approval status
            models.Index(fields=['is_approved']),
            
            # Index for filtering by author
            models.Index(fields=['author']),
        ]

class Category(models.Model):
    # ... existing fields ...
    
    class Meta:
        ordering = ['name']
        verbose_name_plural = "Categories"
        indexes = [
            # Index for slug lookups (already unique, but explicit)
            models.Index(fields=['slug']),
        ]
```

Create a migration for the new indexes:

```bash
python manage.py makemigrations blog
python manage.py migrate blog
```

---

## Target 9.3: Implementing Caching

### The Concept

**Caching** stores frequently accessed data in memory, reducing database queries. Django provides a flexible caching framework.

### The Implementation

**File: `config/settings.py`** (add cache configuration)

```python
# config/settings.py

# Cache Configuration
if DEBUG:
    # Use local-memory cache for development
    CACHES = {
        'default': {
            'BACKEND': 'django.core.cache.backends.locmem.LocMemCache',
            'LOCATION': 'unique-snowflake',
            'TIMEOUT': 300,  # 5 minutes
        }
    }
else:
    # Use Redis or Memcached for production
    CACHES = {
        'default': {
            'BACKEND': 'django.core.cache.backends.redis.RedisCache',
            'LOCATION': os.environ.get('REDIS_URL', 'redis://127.0.0.1:6379/1'),
            'TIMEOUT': 300,
            'OPTIONS': {
                'CLIENT_CLASS': 'django_redis.client.DefaultClient',
                'PASSWORD': os.environ.get('REDIS_PASSWORD', ''),
                'SOCKET_CONNECT_TIMEOUT': 5,
                'SOCKET_TIMEOUT': 5,
            }
        }
    }

# Cache timeouts
CACHE_TIMEOUT_SHORT = 60  # 1 minute
CACHE_TIMEOUT_MEDIUM = 300  # 5 minutes
CACHE_TIMEOUT_LONG = 3600  # 1 hour
CACHE_TIMEOUT_DAY = 86400  # 24 hours
```

Now implement caching in views:

**File: `blog/views.py`** (add caching)

```python
from django.core.cache import cache
from django.views.decorators.cache import cache_page
from django.views.decorators.vary import vary_on_cookie, vary_on_headers
from django.utils.decorators import method_decorator


class PostListView(ListView):
    # ... existing code ...
    
    def get_queryset(self):
        # Try to get from cache first
        cache_key = f'post_list_{self.request.GET.urlencode()}'
        queryset = cache.get(cache_key)
        
        if queryset is None:
            # Build the queryset
            queryset = super().get_queryset()
            
            # Cache for 5 minutes
            cache.set(cache_key, queryset, timeout=300)
        
        return queryset
    
    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        
        # Cache categories
        categories = cache.get('categories_with_counts')
        if categories is None:
            categories = Category.objects.annotate(
                post_count=Count('posts', filter=Q(posts__status=Post.Status.PUBLISHED))
            ).filter(post_count__gt=0)
            cache.set('categories_with_counts', categories, timeout=3600)
        
        context['categories'] = categories
        return context


class PostDetailView(DetailView):
    # ... existing code ...
    
    def get_object(self, queryset=None):
        # Try to get post from cache
        cache_key = f'post_{self.kwargs.get("slug")}'
        post = cache.get(cache_key)
        
        if post is None:
            post = super().get_object(queryset)
            cache.set(cache_key, post, timeout=3600)
        
        return post


# Cache the entire home page
@method_decorator(cache_page(300), name='dispatch')
class HomeView(TemplateView):
    # ... existing code ...
    pass


# Cache with vary on cookie (for user-specific content)
@method_decorator(vary_on_cookie, name='dispatch')
@method_decorator(cache_page(60), name='dispatch')
class DashboardView(LoginRequiredMixin, TemplateView):
    # ... existing code ...
    pass


# Cache invalidation when a post is saved
@receiver(post_save, sender=Post)
def invalidate_post_cache(sender, instance, **kwargs):
    """Invalidate cache when a post is saved."""
    cache.delete(f'post_{instance.slug}')
    cache.delete_pattern('post_list_*')
    cache.delete('categories_with_counts')
```

---

## Target 9.4: Production Settings

### The Concept

Production settings differ from development settings:
- Debug must be off
- Use secure cookies
- Configure allowed hosts
- Use environment variables for secrets
- Enable HTTPS

### The Implementation

**File: `config/settings.py`** (split into development and production)

First, create a `.env` file:

**File: `.env`** (create new)

```bash
# .env - NEVER commit this file!

# Django Settings
SECRET_KEY=your-super-secret-key-here-at-least-50-characters
DEBUG=False
ALLOWED_HOSTS=yourdomain.com,www.yourdomain.com,localhost,127.0.0.1

# Database Settings
DATABASE_URL=postgresql://user:password@localhost:5432/django_blog

# Email Settings
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USE_TLS=True
EMAIL_HOST_USER=your-email@gmail.com
EMAIL_HOST_PASSWORD=your-app-password
DEFAULT_FROM_EMAIL=noreply@yourdomain.com

# Security Settings
SECURE_SSL_REDIRECT=True
SESSION_COOKIE_SECURE=True
CSRF_COOKIE_SECURE=True
SECURE_HSTS_SECONDS=31536000  # 1 year
SECURE_HSTS_INCLUDE_SUBDOMAINS=True
SECURE_HSTS_PRELOAD=True

# Redis Settings
REDIS_URL=redis://127.0.0.1:6379/1
REDIS_PASSWORD=

# Site Settings
SITE_URL=https://yourdomain.com
```

Now install `python-dotenv` for loading environment variables:

```bash
uv pip install python-dotenv
uv pip freeze > requirements.txt
```

**File: `config/settings.py`** (update for production)

```python
import os
from pathlib import Path
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Build paths inside the project like this: BASE_DIR / 'subdir'.
BASE_DIR = Path(__file__).resolve().parent.parent

# SECURITY WARNING: keep the secret key used in production secret!
SECRET_KEY = os.environ.get('SECRET_KEY', 'django-insecure-your-dev-key')

# SECURITY WARNING: don't run with debug turned on in production!
DEBUG = os.environ.get('DEBUG', 'False') == 'True'

# Allowed hosts
ALLOWED_HOSTS = os.environ.get('ALLOWED_HOSTS', 'localhost,127.0.0.1').split(',')

# Application definition
INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'blog',
]

# Add debug toolbar in development only
if DEBUG:
    INSTALLED_APPS += ['debug_toolbar']

MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'whitenoise.middleware.WhiteNoiseMiddleware',  # For static files
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

if DEBUG:
    MIDDLEWARE.insert(0, 'debug_toolbar.middleware.DebugToolbarMiddleware')

# Database
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': os.environ.get('DB_NAME', 'django_blog'),
        'USER': os.environ.get('DB_USER', 'postgres'),
        'PASSWORD': os.environ.get('DB_PASSWORD', ''),
        'HOST': os.environ.get('DB_HOST', 'localhost'),
        'PORT': os.environ.get('DB_PORT', '5432'),
        'CONN_MAX_AGE': 600,  # Persistent connections
        'OPTIONS': {
            'connect_timeout': 10,
        }
    }
}

# Use SQLite for development if DATABASE_URL is not set
if 'sqlite' in os.environ.get('DATABASE_URL', ''):
    DATABASES['default'] = {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': BASE_DIR / 'db.sqlite3',
    }

# Security settings
SECURE_SSL_REDIRECT = os.environ.get('SECURE_SSL_REDIRECT', 'False') == 'True'
SESSION_COOKIE_SECURE = os.environ.get('SESSION_COOKIE_SECURE', 'False') == 'True'
CSRF_COOKIE_SECURE = os.environ.get('CSRF_COOKIE_SECURE', 'False') == 'True'
SECURE_BROWSER_XSS_FILTER = True
SECURE_CONTENT_TYPE_NOSNIFF = True
X_FRAME_OPTIONS = 'DENY'

# HSTS settings
SECURE_HSTS_SECONDS = int(os.environ.get('SECURE_HSTS_SECONDS', 0))
SECURE_HSTS_INCLUDE_SUBDOMAINS = True
SECURE_HSTS_PRELOAD = True

# Session settings
SESSION_ENGINE = 'django.contrib.sessions.backends.cached_db'
SESSION_COOKIE_AGE = 86400  # 24 hours
SESSION_COOKIE_HTTPONLY = True
SESSION_COOKIE_SAMESITE = 'Lax'

# CSRF settings
CSRF_TRUSTED_ORIGINS = os.environ.get('CSRF_TRUSTED_ORIGINS', '').split(',')

# Static files (CSS, JavaScript, Images)
STATIC_URL = '/static/'
STATIC_ROOT = BASE_DIR / 'staticfiles'
STATICFILES_DIRS = [BASE_DIR / 'static']
STATICFILES_STORAGE = 'whitenoise.storage.CompressedManifestStaticFilesStorage'

# Media files
MEDIA_URL = '/media/'
MEDIA_ROOT = BASE_DIR / 'media'

# Default primary key field type
DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'

# Authentication
LOGIN_URL = 'login'
LOGIN_REDIRECT_URL = 'blog:home'
LOGOUT_REDIRECT_URL = 'blog:home'

# Email
EMAIL_BACKEND = 'django.core.mail.backends.smtp.EmailBackend'
EMAIL_HOST = os.environ.get('EMAIL_HOST', 'smtp.gmail.com')
EMAIL_PORT = int(os.environ.get('EMAIL_PORT', 587))
EMAIL_USE_TLS = os.environ.get('EMAIL_USE_TLS', 'True') == 'True'
EMAIL_HOST_USER = os.environ.get('EMAIL_HOST_USER', '')
EMAIL_HOST_PASSWORD = os.environ.get('EMAIL_HOST_PASSWORD', '')
DEFAULT_FROM_EMAIL = os.environ.get('DEFAULT_FROM_EMAIL', 'noreply@localhost')

# Site URL
SITE_URL = os.environ.get('SITE_URL', 'http://localhost:8000')

# Logging
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
            'filename': BASE_DIR / 'logs' / 'django.log',
            'maxBytes': 1024 * 1024 * 10,
            'backupCount': 5,
            'formatter': 'verbose',
        },
    },
    'root': {
        'handlers': ['console', 'file'],
        'level': 'INFO',
    },
    'loggers': {
        'django': {
            'handlers': ['console', 'file'],
            'level': 'INFO',
            'propagate': False,
        },
        'blog': {
            'handlers': ['console', 'file'],
            'level': 'DEBUG',
            'propagate': False,
        },
    },
}
```

---

## Target 9.5: Security Audit Checklist

### The Concept

A security audit ensures your application is protected against common vulnerabilities.

### Security Checklist

**File: `docs/SECURITY.md`** (create new)

```markdown
# Django Blog Security Audit

## ✅ Completed

### Authentication & Authorization
- [x] Users can only edit/delete their own posts
- [x] Superusers have full access
- [x] Password reset implemented
- [x] Password change implemented
- [x] Login attempts are limited

### Data Protection
- [x] CSRF protection enabled
- [x] SQL injection prevention (ORM)
- [x] XSS protection (auto-escaping)
- [x] Clickjacking protection
- [x] File upload validation

### Configuration
- [x] DEBUG=False in production
- [x] Secret key in environment variables
- [x] Allowed hosts configured
- [x] HTTPS enforced
- [x] Secure cookies configured

### Monitoring
- [x] Logging configured
- [x] Error emails sent to admins
- [x] Security headers added

## ⚠️ Review Regularly

### Dependencies
- [ ] Check for outdated packages
- [ ] Review security advisories
- [ ] Update Django regularly

### Access Control
- [ ] Review user permissions
- [ ] Audit admin access
- [ ] Check for inactive users

### Data Backup
- [ ] Database backups configured
- [ ] Media file backups
- [ ] Backup restoration tested

## 🔜 Future Improvements

### Advanced Security
- [ ] Two-factor authentication
- [ ] Rate limiting
- [ ] IP whitelisting for admin
- [ ] Activity logging

### Compliance
- [ ] GDPR compliance
- [ ] Privacy policy
- [ ] Terms of service
- [ ] Cookie consent
```

### Security Header Check

Add this view to verify security headers:

**File: `blog/views.py`** (add security check view)

```python
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt

@csrf_exempt
def security_headers_check(request):
    """
    View to check security headers.
    
    Use this for debugging security configuration.
    """
    headers = {
        'X-Content-Type-Options': 'nosniff',
        'X-Frame-Options': 'DENY',
        'X-XSS-Protection': '1; mode=block',
        'Content-Security-Policy': "default-src 'self'",
        'Referrer-Policy': 'strict-origin-when-cross-origin',
        'Permissions-Policy': 'geolocation=(), microphone=(), camera=()',
    }
    
    response = JsonResponse(headers)
    
    # Set all security headers
    for key, value in headers.items():
        response[key] = value
    
    return response
```

---

## Target 9.6: Production Database Migration

### The Concept

Moving from SQLite to PostgreSQL for production.

### The Implementation

**Step 1: Install PostgreSQL on your system**

```bash
# macOS
brew install postgresql

# Ubuntu/Debian
sudo apt install postgresql postgresql-contrib

# Start PostgreSQL
brew services start postgresql  # macOS
sudo systemctl start postgresql  # Linux
```

**Step 2: Create a database and user**

```bash
# Connect to PostgreSQL
sudo -u postgres psql

# In PostgreSQL shell:
CREATE DATABASE django_blog;
CREATE USER django_user WITH PASSWORD 'your_secure_password';
GRANT ALL PRIVILEGES ON DATABASE django_blog TO django_user;

# Exit PostgreSQL
\q
```

**Step 3: Migrate data from SQLite to PostgreSQL**

Create a data migration script:

**File: `scripts/migrate_to_postgres.py`**

```python
#!/usr/bin/env python
"""
Script to migrate data from SQLite to PostgreSQL.
Usage: python scripts/migrate_to_postgres.py
"""

import os
import sys
from pathlib import Path

# Add project root to path
sys.path.append(str(Path(__file__).resolve().parent.parent))

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')

import django
django.setup()

from django.core.management import call_command
from django.db import connection


def migrate_data():
    """Migrate data from SQLite to PostgreSQL."""
    print("Starting migration from SQLite to PostgreSQL...")
    
    # Dump data from SQLite
    print("Dumping data from SQLite...")
    with open('data_dump.json', 'w') as f:
        call_command('dumpdata', indent=2, stdout=f)
    
    # Switch to PostgreSQL (already configured in settings)
    print("Switching to PostgreSQL...")
    
    # Load data into PostgreSQL
    print("Loading data into PostgreSQL...")
    with open('data_dump.json', 'r') as f:
        call_command('loaddata', f.name)
    
    print("Migration complete!")
    print("Don't forget to run migrations for any new models!")

if __name__ == '__main__':
    migrate_data()
```

---

## The Verification

### Step 1: Check Query Performance

```bash
python manage.py shell

from django.db import connection
from blog.services.post_service import PostService

# Clear query log
connection.queries_log.clear()

# Run optimized query
posts = PostService.get_optimized_posts()

# Check number of queries
print(f"Number of queries: {len(connection.queries)}")
# Should be 1-2 queries, not N+1
```

### Step 2: Test Caching

```bash
python manage.py shell

from django.core.cache import cache

# Set a value
cache.set('test_key', 'test_value', timeout=60)

# Get the value
value = cache.get('test_key')
print(f"Cache value: {value}")

# Clear cache
cache.clear()
```

### Step 3: Test Production Settings

```bash
# Set DEBUG=False temporarily
export DEBUG=False

# Run the server
python manage.py runserver

# Visit the site
# You should NOT see debug pages
# You should see secure headers in browser's dev tools
```

### Step 4: Security Headers Check

```bash
curl -I http://127.0.0.1:8000/security-headers/

# Should return:
# X-Content-Type-Options: nosniff
# X-Frame-Options: DENY
# X-XSS-Protection: 1; mode=block
# Content-Security-Policy: ...
```

---

## What You've Learned in Part 9

### ✅ Skills Acquired
- Optimizing ORM queries
- Creating database indexes
- Implementing caching
- Using environment variables
- Configuring production settings
- Hardening security
- Migrating to PostgreSQL

### ✅ What You've Built
- Optimized database queries
- Cache implementation
- Production-ready settings
- Security headers
- Security audit checklist
- PostgreSQL migration script
