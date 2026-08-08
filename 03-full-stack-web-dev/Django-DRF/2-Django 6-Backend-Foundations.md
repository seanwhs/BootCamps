# Part 2: Django 6 Backend Foundations

## Building Your Django Backend

Welcome to **Part 2** of the Django REST Framework & Next.js 16 masterclass. Now that we understand REST architecture and HTTP fundamentals, it's time to start building our Django backend.

In this part, we'll:
- Set up our Django project with proper configuration
- Configure PostgreSQL as our database
- Create our data models (User, Project, Task, Comment)
- Set up relationships between models
- Run migrations to create our database schema
- Create initial data with fixtures

Think of this as laying the foundation of a house. We're building the structure that everything else will sit on. A solid foundation ensures the rest of our application is stable, maintainable, and performant.

---

## The Target

We'll build a Django 6.x backend with:

```
project-root/
├── backend/
│   ├── config/                    # Django project settings
│   │   ├── __init__.py
│   │   ├── settings.py
│   │   ├── urls.py
│   │   ├── wsgi.py
│   │   └── asgi.py
│   ├── apps/                      # Django applications
│   │   ├── users/                 # Custom user management
│   │   │   ├── __init__.py
│   │   │   ├── admin.py
│   │   │   ├── apps.py
│   │   │   ├── models.py
│   │   │   └── managers.py
│   │   ├── projects/              # Project management
│   │   │   ├── __init__.py
│   │   │   ├── admin.py
│   │   │   ├── apps.py
│   │   │   └── models.py
│   │   ├── tasks/                 # Task management
│   │   │   ├── __init__.py
│   │   │   ├── admin.py
│   │   │   ├── apps.py
│   │   │   └── models.py
│   │   └── comments/              # Comments on tasks
│   │       ├── __init__.py
│   │       ├── admin.py
│   │       ├── apps.py
│   │       └── models.py
│   ├── requirements/
│   │   ├── base.txt
│   │   └── development.txt
│   ├── manage.py
│   └── .env
```

---

## The Concept

### Why Django?

Django is a high-level Python web framework that encourages rapid development and clean, pragmatic design. It comes with:

- **ORM** (Object-Relational Mapping) - Python objects for database tables
- **Admin interface** - Built-in CRUD interface for your models
- **Authentication** - Built-in user authentication system
- **Security** - Protection against common vulnerabilities (XSS, CSRF, SQL injection)
- **Scalability** - Can handle high-traffic applications

### Why Custom User Model?

Django provides a built-in User model, but we'll create a custom one for flexibility:
- Add custom fields (e.g., bio, profile picture, role)
- Use email as the username field
- Easily extend in the future
- Better control over authentication

### The Data Model

Our application has a clear domain model:

```
User
 ├── Projects (created_by)
 │    └── Tasks
 │         └── Comments
 └── Tasks (assigned_to)
      └── Comments
```

#### Relationships:
- **User → Projects**: One-to-Many (a user can create many projects)
- **User → Tasks**: One-to-Many (a user can create many tasks)
- **Project → Tasks**: One-to-Many (a project has many tasks)
- **Task → Comments**: One-to-Many (a task has many comments)
- **User → Comments**: One-to-Many (a user can write many comments)

#### Model Fields:

**User** (extended from AbstractUser):
- username, email, first_name, last_name
- bio (optional)
- role (choices: admin, manager, member, viewer)
- created_at, updated_at

**Project**:
- name, description
- created_by (ForeignKey to User)
- created_at, updated_at

**Task**:
- title, description
- status (choices: todo, in_progress, review, done)
- priority (choices: low, medium, high, urgent)
- due_date (optional)
- project (ForeignKey to Project)
- assigned_to (ForeignKey to User, optional)
- created_by (ForeignKey to User)
- created_at, updated_at

**Comment**:
- content
- task (ForeignKey to Task)
- author (ForeignKey to User)
- created_at, updated_at

---

## The Implementation

### Step 1: Set Up Python Environment

Open your terminal and create a new project directory:

```bash
# Create project directory
mkdir django-nextjs-masterclass
cd django-nextjs-masterclass

# Create backend directory
mkdir backend
cd backend

# Create and activate virtual environment
python -m venv venv

# On macOS/Linux:
source venv/bin/activate

# On Windows:
# venv\Scripts\activate
```

### Step 2: Install Django and Dependencies

Create the requirements files:

**backend/requirements/base.txt**
```txt
# Django 6.x and core dependencies
Django>=6.0,<6.1
psycopg2-binary>=2.9.0
django-environ>=0.11.0
python-dotenv>=1.0.0

# Django REST Framework
djangorestframework>=3.15.0

# Database and caching
django-redis>=5.4.0

# CORS headers
django-cors-headers>=4.3.0

# Filtering
django-filter>=24.0.0
```

**backend/requirements/development.txt**
```txt
-r base.txt

# Development tools
django-debug-toolbar>=4.3.0
ipython>=8.22.0
pytest>=8.0.0
pytest-django>=4.8.0
factory-boy>=3.3.0
```

Install the dependencies:

```bash
# Install base requirements
pip install -r requirements/base.txt

# Install development requirements
pip install -r requirements/development.txt
```

### Step 3: Create Django Project

```bash
# Create the Django project
django-admin startproject config .

# The period (.) at the end creates the project in the current directory
```

Your structure should now look like:

```
backend/
├── config/
│   ├── __init__.py
│   ├── settings.py
│   ├── urls.py
│   ├── wsgi.py
│   └── asgi.py
├── requirements/
│   ├── base.txt
│   └── development.txt
└── manage.py
```

### Step 4: Configure Django Settings

Let's set up our Django settings with environment variables for security.

**backend/config/settings.py**
```python
"""
Django settings for the backend project.
This configuration uses environment variables for all sensitive settings.
"""

import os
from pathlib import Path

# Import environment variables
import environ

# Build paths inside the project like this: BASE_DIR / 'subdir'
BASE_DIR = Path(__file__).resolve().parent.parent

# Initialize environment variables
env = environ.Env(
    # Set casting types and default values
    DEBUG=(bool, False),
    SECRET_KEY=(str, 'django-insecure-default-key-for-dev'),
    DATABASE_URL=(str, 'sqlite:///db.sqlite3'),
    ALLOWED_HOSTS=(list, []),
    REDIS_URL=(str, 'redis://localhost:6379/0'),
)

# Read the .env file
environ.Env.read_env(os.path.join(BASE_DIR, '.env'))

# SECURITY WARNING: keep the secret key used in production secret!
SECRET_KEY = env('SECRET_KEY')

# SECURITY WARNING: don't run with debug turned on in production!
DEBUG = env('DEBUG')

ALLOWED_HOSTS = env('ALLOWED_HOSTS')

# Application definition
INSTALLED_APPS = [
    # Django built-in apps
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',

    # Third-party apps
    'rest_framework',           # Django REST Framework
    'corsheaders',              # CORS headers support
    'django_filters',           # Advanced filtering
    'django_redis',             # Redis cache backend

    # Local apps (created by us)
    'apps.users',
    'apps.projects',
    'apps.tasks',
    'apps.comments',
]

MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'corsheaders.middleware.CorsMiddleware',  # CORS middleware - should be high
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

ROOT_URLCONF = 'config.urls'

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [],
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

WSGI_APPLICATION = 'config.wsgi.application'

# Database
# https://docs.djangoproject.com/en/6.0/ref/settings/#databases

DATABASES = {
    'default': env.db(),
}

# If using sqlite for development (default), add these settings
# DATABASES['default']['OPTIONS'] = {
#     'timeout': 20,
# }

# Password validation
# https://docs.djangoproject.com/en/6.0/ref/settings/#auth-password-validators

AUTH_PASSWORD_VALIDATORS = [
    {
        'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator',
        'OPTIONS': {
            'min_length': 8,
        }
    },
    {
        'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator',
    },
]

# Internationalization
# https://docs.djangoproject.com/en/6.0/topics/i18n/

LANGUAGE_CODE = 'en-us'

TIME_ZONE = 'UTC'

USE_I18N = True

USE_TZ = True

# Static files (CSS, JavaScript, Images)
# https://docs.djangoproject.com/en/6.0/howto/static-files/

STATIC_URL = 'static/'
STATIC_ROOT = BASE_DIR / 'staticfiles'

# Media files (User uploads)
MEDIA_URL = 'media/'
MEDIA_ROOT = BASE_DIR / 'media'

# Default primary key field type
# https://docs.djangoproject.com/en/6.0/ref/settings/#default-auto-field

DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'

# Custom User Model
AUTH_USER_MODEL = 'users.User'

# Django REST Framework settings
REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': [
        # We'll add JWT authentication in Phase 3
        'rest_framework.authentication.SessionAuthentication',
    ],
    'DEFAULT_PERMISSION_CLASSES': [
        'rest_framework.permissions.AllowAny',  # Temporarily allow all
    ],
    'DEFAULT_RENDERER_CLASSES': [
        'rest_framework.renderers.JSONRenderer',
    ],
    'DEFAULT_PARSER_CLASSES': [
        'rest_framework.parsers.JSONParser',
    ],
    'DEFAULT_FILTER_BACKENDS': [
        'django_filters.rest_framework.DjangoFilterBackend',
    ],
    'DEFAULT_PAGINATION_CLASS': 'rest_framework.pagination.PageNumberPagination',
    'PAGE_SIZE': 20,
    'DEFAULT_VERSIONING_CLASS': 'rest_framework.versioning.URLPathVersioning',
    'DEFAULT_VERSION': 'v1',
    'ALLOWED_VERSIONS': ['v1'],
    'VERSION_PARAM': 'version',
}

# CORS settings - For development, we'll allow all origins
# In production, restrict to your domain
CORS_ALLOW_ALL_ORIGINS = True  # Only for development!
CORS_ALLOW_CREDENTIALS = True
CORS_ALLOW_METHODS = [
    'DELETE',
    'GET',
    'OPTIONS',
    'PATCH',
    'POST',
    'PUT',
]
CORS_ALLOW_HEADERS = [
    'accept',
    'accept-encoding',
    'authorization',
    'content-type',
    'dnt',
    'origin',
    'user-agent',
    'x-csrftoken',
    'x-requested-with',
]

# Cache settings (will use Redis in Phase 4)
CACHES = {
    'default': {
        'BACKEND': 'django.core.cache.backends.locmem.LocMemCache',
        'LOCATION': 'unique-snowflake',
    }
}

# Redis cache (for Phase 4)
REDIS_URL = env('REDIS_URL')

# Logging configuration
LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'formatters': {
        'verbose': {
            'format': '{levelname} {asctime} {module} {process:d} {thread:d} {message}',
            'style': '{',
        },
        'simple': {
            'format': '{levelname} {message}',
            'style': '{',
        },
    },
    'handlers': {
        'console': {
            'level': 'DEBUG',
            'class': 'logging.StreamHandler',
            'formatter': 'verbose',
        },
    },
    'root': {
        'handlers': ['console'],
        'level': 'INFO',
    },
    'loggers': {
        'django': {
            'handlers': ['console'],
            'level': 'INFO',
            'propagate': False,
        },
        'apps': {
            'handlers': ['console'],
            'level': 'DEBUG',
            'propagate': False,
        },
    },
}
```

### Step 5: Create Environment File

**backend/.env**
```bash
# Django settings
SECRET_KEY=django-insecure-@x9b#1v8$2n*p3q4r5s6t7u8v9w0x1y2z3a4b5c6d7e8f9g0h1i2j3k4l5m6n7o8p9
DEBUG=True
DATABASE_URL=sqlite:///db.sqlite3
ALLOWED_HOSTS=localhost,127.0.0.1

# Redis (will use later)
REDIS_URL=redis://localhost:6379/0
```

> **Security Note:** In production, never commit your .env file to version control. We'll add it to .gitignore shortly.

### Step 6: Create the Custom User Model

Let's create a custom User model with an extra `bio` field and `role` choices.

First, create the users app:

```bash
# Create the users app
cd backend
python manage.py startapp users apps/users
```

**backend/apps/users/managers.py**
```python
"""
Custom user manager for the User model.
This extends Django's BaseUserManager with additional functionality.
"""

from django.contrib.auth.base_user import BaseUserManager
from django.utils.translation import gettext_lazy as _


class UserManager(BaseUserManager):
    """
    Custom user manager where email is the unique identifier
    for authentication instead of username.
    """

    def create_user(self, email, password=None, **extra_fields):
        """
        Create and save a user with the given email and password.
        """
        if not email:
            raise ValueError(_('The Email must be set'))
        email = self.normalize_email(email)
        user = self.model(email=email, **extra_fields)
        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_superuser(self, email, password=None, **extra_fields):
        """
        Create and save a superuser with the given email and password.
        """
        extra_fields.setdefault('is_staff', True)
        extra_fields.setdefault('is_superuser', True)
        extra_fields.setdefault('is_active', True)
        extra_fields.setdefault('role', 'admin')

        if extra_fields.get('is_staff') is not True:
            raise ValueError(_('Superuser must have is_staff=True.'))
        if extra_fields.get('is_superuser') is not True:
            raise ValueError(_('Superuser must have is_superuser=True.'))
        return self.create_user(email, password, **extra_fields)
```

**backend/apps/users/models.py**
```python
"""
Custom User model extending Django's AbstractUser.
This allows us to add custom fields and behaviors.
"""

from django.contrib.auth.models import AbstractUser
from django.db import models
from django.utils.translation import gettext_lazy as _

from .managers import UserManager


class User(AbstractUser):
    """
    Custom User model with additional fields:
    - bio: User's biography
    - role: User's role in the system (admin, manager, member, viewer)
    - created_at, updated_at: Timestamps
    """
    
    # User role choices
    class Roles(models.TextChoices):
        ADMIN = 'admin', _('Administrator')
        MANAGER = 'manager', _('Manager')
        MEMBER = 'member', _('Member')
        VIEWER = 'viewer', _('Viewer')

    # Use email as the unique identifier
    email = models.EmailField(_('email address'), unique=True)
    
    # Additional fields
    bio = models.TextField(_('bio'), blank=True, null=True)
    role = models.CharField(
        _('role'),
        max_length=20,
        choices=Roles.choices,
        default=Roles.MEMBER,
    )
    created_at = models.DateTimeField(_('created at'), auto_now_add=True)
    updated_at = models.DateTimeField(_('updated at'), auto_now=True)

    # Use our custom manager
    objects = UserManager()

    # Set the field used for authentication
    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = ['username']

    class Meta:
        db_table = 'users'
        verbose_name = _('user')
        verbose_name_plural = _('users')
        ordering = ['-created_at']

    def __str__(self):
        """String representation of the user"""
        return self.email

    def get_full_name(self):
        """Return the user's full name or email if not set"""
        if self.first_name and self.last_name:
            return f"{self.first_name} {self.last_name}"
        return self.email

    @property
    def is_admin(self):
        """Check if user is an administrator"""
        return self.role == self.Roles.ADMIN or self.is_superuser

    @property
    def is_manager(self):
        """Check if user is a manager or higher"""
        return self.role in [self.Roles.ADMIN, self.Roles.MANAGER]

    def has_project_access(self, project):
        """
        Check if user has access to a project.
        Users can access projects they created or projects they have tasks in.
        """
        if self.is_admin:
            return True
        # User created the project
        if project.created_by == self:
            return True
        # User has tasks in the project
        if project.tasks.filter(assigned_to=self).exists():
            return True
        return False
```

**backend/apps/users/admin.py**
```python
"""
Admin configuration for the User model.
"""

from django.contrib import admin
from django.contrib.auth.admin import UserAdmin as BaseUserAdmin
from django.utils.translation import gettext_lazy as _

from .models import User


@admin.register(User)
class UserAdmin(BaseUserAdmin):
    """
    Custom admin interface for the User model.
    """
    fieldsets = (
        (None, {'fields': ('email', 'password')}),
        (_('Personal info'), {'fields': ('username', 'first_name', 'last_name', 'bio')}),
        (_('Permissions'), {
            'fields': ('is_active', 'is_staff', 'is_superuser', 'role', 'groups', 'user_permissions'),
        }),
        (_('Important dates'), {'fields': ('last_login', 'date_joined', 'created_at', 'updated_at')}),
    )
    add_fieldsets = (
        (None, {
            'classes': ('wide',),
            'fields': ('email', 'username', 'password1', 'password2', 'role'),
        }),
    )
    list_display = ('email', 'username', 'role', 'is_active', 'is_staff', 'created_at')
    list_filter = ('role', 'is_active', 'is_staff', 'is_superuser')
    search_fields = ('email', 'username', 'first_name', 'last_name')
    ordering = ('-created_at',)
```

**backend/apps/users/apps.py**
```python
from django.apps import AppConfig


class UsersConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'apps.users'
    verbose_name = 'Users'
```

### Step 7: Create the Projects App

```bash
python manage.py startapp projects apps/projects
```

**backend/apps/projects/models.py**
```python
"""
Models for the Projects app.
"""

from django.conf import settings
from django.db import models
from django.utils.translation import gettext_lazy as _


class Project(models.Model):
    """
    Project model representing a collection of tasks.
    Each project is created by a user and can have many tasks.
    """
    
    name = models.CharField(_('name'), max_length=255)
    description = models.TextField(_('description'), blank=True, null=True)
    created_by = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='projects',
        verbose_name=_('created by'),
    )
    created_at = models.DateTimeField(_('created at'), auto_now_add=True)
    updated_at = models.DateTimeField(_('updated at'), auto_now=True)

    class Meta:
        db_table = 'projects'
        verbose_name = _('project')
        verbose_name_plural = _('projects')
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['created_by', 'created_at']),
            models.Index(fields=['name']),
        ]

    def __str__(self):
        """String representation of the project"""
        return self.name

    @property
    def task_count(self):
        """Get the number of tasks in this project"""
        return self.tasks.count()

    @property
    def completed_task_count(self):
        """Get the number of completed tasks in this project"""
        from apps.tasks.models import Task
        return self.tasks.filter(status=Task.Status.DONE).count()
```

**backend/apps/projects/apps.py**
```python
from django.apps import AppConfig


class ProjectsConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'apps.projects'
    verbose_name = 'Projects'
```

**backend/apps/projects/admin.py**
```python
from django.contrib import admin
from .models import Project


@admin.register(Project)
class ProjectAdmin(admin.ModelAdmin):
    list_display = ('name', 'created_by', 'created_at', 'task_count')
    list_filter = ('created_by', 'created_at')
    search_fields = ('name', 'description')
    readonly_fields = ('task_count',)
```

### Step 8: Create the Tasks App

```bash
python manage.py startapp tasks apps/tasks
```

**backend/apps/tasks/models.py**
```python
"""
Models for the Tasks app.
"""

from django.conf import settings
from django.db import models
from django.utils.translation import gettext_lazy as _


class Task(models.Model):
    """
    Task model representing work items within a project.
    Tasks have status, priority, and can be assigned to users.
    """
    
    # Status choices
    class Status(models.TextChoices):
        TODO = 'todo', _('To Do')
        IN_PROGRESS = 'in_progress', _('In Progress')
        REVIEW = 'review', _('In Review')
        DONE = 'done', _('Done')

    # Priority choices
    class Priority(models.TextChoices):
        LOW = 'low', _('Low')
        MEDIUM = 'medium', _('Medium')
        HIGH = 'high', _('High')
        URGENT = 'urgent', _('Urgent')

    title = models.CharField(_('title'), max_length=255)
    description = models.TextField(_('description'), blank=True, null=True)
    status = models.CharField(
        _('status'),
        max_length=20,
        choices=Status.choices,
        default=Status.TODO,
    )
    priority = models.CharField(
        _('priority'),
        max_length=20,
        choices=Priority.choices,
        default=Priority.MEDIUM,
    )
    due_date = models.DateTimeField(_('due date'), blank=True, null=True)
    
    # Relationships
    project = models.ForeignKey(
        'projects.Project',
        on_delete=models.CASCADE,
        related_name='tasks',
        verbose_name=_('project'),
    )
    assigned_to = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='assigned_tasks',
        verbose_name=_('assigned to'),
    )
    created_by = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='created_tasks',
        verbose_name=_('created by'),
    )
    
    created_at = models.DateTimeField(_('created at'), auto_now_add=True)
    updated_at = models.DateTimeField(_('updated at'), auto_now=True)

    class Meta:
        db_table = 'tasks'
        verbose_name = _('task')
        verbose_name_plural = _('tasks')
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['project', 'status']),
            models.Index(fields=['assigned_to', 'status']),
            models.Index(fields=['due_date']),
            models.Index(fields=['priority']),
        ]
        # Ensure a task has a unique title within a project (optional)
        unique_together = [['project', 'title']]

    def __str__(self):
        """String representation of the task"""
        return f"{self.title} ({self.project.name})"

    @property
    def is_overdue(self):
        """Check if the task is overdue and not completed"""
        if self.due_date and self.status != self.Status.DONE:
            from django.utils import timezone
            return self.due_date < timezone.now()
        return False

    @property
    def comment_count(self):
        """Get the number of comments on this task"""
        return self.comments.count()
```

**backend/apps/tasks/apps.py**
```python
from django.apps import AppConfig


class TasksConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'apps.tasks'
    verbose_name = 'Tasks'
```

**backend/apps/tasks/admin.py**
```python
from django.contrib import admin
from .models import Task


@admin.register(Task)
class TaskAdmin(admin.ModelAdmin):
    list_display = ('title', 'project', 'status', 'priority', 'assigned_to', 'due_date', 'is_overdue')
    list_filter = ('status', 'priority', 'project', 'assigned_to')
    search_fields = ('title', 'description')
    readonly_fields = ('comment_count', 'is_overdue')
```

### Step 9: Create the Comments App

```bash
python manage.py startapp comments apps/comments
```

**backend/apps/comments/models.py**
```python
"""
Models for the Comments app.
"""

from django.conf import settings
from django.db import models
from django.utils.translation import gettext_lazy as _


class Comment(models.Model):
    """
    Comment model for discussions on tasks.
    Each comment belongs to a task and is written by a user.
    """
    
    content = models.TextField(_('content'))
    task = models.ForeignKey(
        'tasks.Task',
        on_delete=models.CASCADE,
        related_name='comments',
        verbose_name=_('task'),
    )
    author = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='comments',
        verbose_name=_('author'),
    )
    created_at = models.DateTimeField(_('created at'), auto_now_add=True)
    updated_at = models.DateTimeField(_('updated at'), auto_now=True)

    class Meta:
        db_table = 'comments'
        verbose_name = _('comment')
        verbose_name_plural = _('comments')
        ordering = ['created_at']
        indexes = [
            models.Index(fields=['task', 'created_at']),
            models.Index(fields=['author', 'created_at']),
        ]

    def __str__(self):
        """String representation of the comment"""
        return f"Comment by {self.author.email} on {self.task.title}"
```

**backend/apps/comments/apps.py**
```python
from django.apps import AppConfig


class CommentsConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'apps.comments'
    verbose_name = 'Comments'
```

**backend/apps/comments/admin.py**
```python
from django.contrib import admin
from .models import Comment


@admin.register(Comment)
class CommentAdmin(admin.ModelAdmin):
    list_display = ('task', 'author', 'created_at')
    list_filter = ('author', 'created_at')
    search_fields = ('content',)
```

### Step 10: Register Apps and Run Migrations

First, register the apps in our Django settings (we already added them to INSTALLED_APPS in Step 4).

Now, create and run migrations:

```bash
# Create migrations for all apps
python manage.py makemigrations

# You should see output like:
# Migrations for 'users':
#   apps/users/migrations/0001_initial.py
#     - Create model User
# Migrations for 'projects':
#   apps/projects/migrations/0001_initial.py
#     - Create model Project
# Migrations for 'tasks':
#   apps/tasks/migrations/0001_initial.py
#     - Create model Task
# Migrations for 'comments':
#   apps/comments/migrations/0001_initial.py
#     - Create model Comment

# Apply migrations to the database
python manage.py migrate

# You should see output like:
# Applying users.0001_initial... OK
# Applying projects.0001_initial... OK
# Applying tasks.0001_initial... OK
# Applying comments.0001_initial... OK
```

### Step 11: Create a Superuser

```bash
python manage.py createsuperuser

# Follow the prompts:
# Email: admin@example.com
# Username: admin
# Password: (choose a strong password)
# Password (again): (confirm)
```

### Step 12: Create Initial Data with Fixtures

Let's create some initial data to work with. Create a fixtures directory and add sample data.

**backend/fixtures/initial_data.json**
```json
[
    {
        "model": "users.user",
        "pk": 1,
        "fields": {
            "username": "admin",
            "email": "admin@example.com",
            "first_name": "Admin",
            "last_name": "User",
            "role": "admin",
            "is_superuser": true,
            "is_staff": true,
            "is_active": true
        }
    },
    {
        "model": "users.user",
        "pk": 2,
        "fields": {
            "username": "manager",
            "email": "manager@example.com",
            "first_name": "Manager",
            "last_name": "User",
            "role": "manager",
            "is_superuser": false,
            "is_staff": false,
            "is_active": true
        }
    },
    {
        "model": "users.user",
        "pk": 3,
        "fields": {
            "username": "member",
            "email": "member@example.com",
            "first_name": "Member",
            "last_name": "User",
            "role": "member",
            "is_superuser": false,
            "is_staff": false,
            "is_active": true
        }
    },
    {
        "model": "projects.project",
        "pk": 1,
        "fields": {
            "name": "Masterclass Project",
            "description": "The main project for the Django/Next.js masterclass",
            "created_by": 1
        }
    },
    {
        "model": "projects.project",
        "pk": 2,
        "fields": {
            "name": "API Development",
            "description": "Building the Django REST API",
            "created_by": 1
        }
    },
    {
        "model": "tasks.task",
        "pk": 1,
        "fields": {
            "title": "Set up Django project",
            "description": "Create the initial Django project structure",
            "status": "done",
            "priority": "high",
            "project": 1,
            "assigned_to": 1,
            "created_by": 1
        }
    },
    {
        "model": "tasks.task",
        "pk": 2,
        "fields": {
            "title": "Create data models",
            "description": "Design and implement all database models",
            "status": "done",
            "priority": "high",
            "project": 1,
            "assigned_to": 2,
            "created_by": 1
        }
    },
    {
        "model": "tasks.task",
        "pk": 3,
        "fields": {
            "title": "Build DRF serializers",
            "description": "Create serializers for all models",
            "status": "in_progress",
            "priority": "high",
            "project": 1,
            "assigned_to": 2,
            "created_by": 1
        }
    },
    {
        "model": "tasks.task",
        "pk": 4,
        "fields": {
            "title": "Implement JWT authentication",
            "description": "Add JWT authentication to the API",
            "status": "todo",
            "priority": "high",
            "project": 2,
            "assigned_to": 3,
            "created_by": 1
        }
    },
    {
        "model": "comments.comment",
        "pk": 1,
        "fields": {
            "content": "Great start! Looking forward to the API development.",
            "task": 1,
            "author": 2
        }
    },
    {
        "model": "comments.comment",
        "pk": 2,
        "fields": {
            "content": "I'll handle the serializers and views.",
            "task": 2,
            "author": 2
        }
    }
]
```

Load the fixtures:

```bash
python manage.py loaddata fixtures/initial_data.json
```

### Step 13: Create .gitignore

**backend/.gitignore**
```gitignore
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
env/
venv/
ENV/
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
*.egg-info/
.installed.cfg
*.egg

# Django
*.log
*.pot
*.pyc
*.pyo
local_settings.py
db.sqlite3
db.sqlite3-journal
media/
staticfiles/

# Environment variables
.env
.env.local
.env.*.local

# IDE
.vscode/
.idea/
*.swp
*.swo
.DS_Store

# Testing
.coverage
htmlcov/
.pytest_cache/
.tox/
.mypy_cache/
.ruff_cache/

# Docker
*.pid
docker-compose.override.yml
```

---

## The Verification

Let's verify our Django backend is working correctly.

### Step 1: Start the Development Server```bash
python manage.py runserver
```

You should see output like:
```
Watching for file changes with StatReloader
Performing system checks...

System check identified no issues (0 silenced).
January 15, 2026 - 12:00:00
Django version 6.0, using settings 'config.settings'
Starting development server at http://127.0.0.1:8000/
Quit the server with CONTROL-C.
```

### Step 2: Check the Admin Interface

Open your browser and go to: http://127.0.0.1:8000/admin/

Log in with the superuser credentials you created.

You should see:
- Users: Your user and the fixture users
- Projects: The projects from the fixtures
- Tasks: The tasks from the fixtures
- Comments: The comments from the fixtures

### Step 3: Verify Models Through Django Shell

Open a Django shell:

```bash
python manage.py shell
```

Run these commands to verify your models:

```python
# Import models
from apps.users.models import User
from apps.projects.models import Project
from apps.tasks.models import Task
from apps.comments.models import Comment

# Check users
print("Users:", User.objects.count())
for user in User.objects.all():
    print(f"  - {user.email} ({user.role})")

# Check projects
print("\nProjects:", Project.objects.count())
for project in Project.objects.all():
    print(f"  - {project.name} (Tasks: {project.task_count})")

# Check tasks
print("\nTasks:", Task.objects.count())
for task in Task.objects.all():
    print(f"  - {task.title} [{task.status}]")

# Check comments
print("\nComments:", Comment.objects.count())
for comment in Comment.objects.all():
    print(f"  - {comment.content[:30]}... by {comment.author.email}")

# Test model methods
project = Project.objects.first()
print(f"\nProject '{project.name}' has {project.completed_task_count} completed tasks")

# Test user access method
user = User.objects.get(email='admin@example.com')
print(f"User {user.email} has access to project: {user.has_project_access(project)}")

# Exit shell
exit()
```

### Step 4: Verify Database Schema

You can check the database schema with:

```bash
python manage.py showmigrations
```

You should see all migrations applied with an [X] next to them.

### Step 5: Test with cURL

Test the admin API (requires authentication):

```bash
# This will redirect to login
curl -v http://localhost:8000/admin/

# Expected: 302 redirect to login page
```

---

## Key Takeaways

1. **Django is our backend framework.** It provides the ORM, admin interface, and security features.

2. **We use a custom User model** for flexibility and to use email as the username field.

3. **Our data model has clear relationships:**
   - Users create Projects
   - Projects contain Tasks
   - Tasks have Comments
   - Users can be assigned to Tasks

4. **Migrations** translate our Python models into database tables.

5. **Environment variables** keep sensitive data out of our code.

6. **The admin interface** gives us a quick way to manage data.

---

## What's Next

In **Part 3**, we'll create DRF serializers for our models. You'll learn:

- What serializers do and why we need them
- How to create ModelSerializers
- How to handle relationships between models
- How to add validation to serializers
- How to customize create and update methods

Serializers are the bridge between our Django models and the JSON data our API sends and receives.

---

**End of Part 2**

*Next: Part 3 - DRF Serializers*
