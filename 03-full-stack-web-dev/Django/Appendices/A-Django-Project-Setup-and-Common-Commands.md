# Appendix A: Django Project Setup and Common Commands

## Welcome to Appendix A!

This appendix serves as your quick reference guide for setting up Django projects and running common commands. Bookmark this page — you'll refer to it often as you build Django applications.

---

## A.1: Complete Project Setup Checklist

### Initial Setup Steps

```bash
# 1. Create project directory
mkdir my_django_project
cd my_django_project

# 2. Create virtual environment
# Using uv (recommended)
uv venv

# Using pip
python -m venv .venv

# 3. Activate virtual environment
# macOS/Linux
source .venv/bin/activate

# Windows Command Prompt
.venv\Scripts\activate

# Windows PowerShell
.venv\Scripts\Activate.ps1

# 4. Install Django
uv pip install django==6.0
# or
pip install django==6.0

# 5. Create Django project
django-admin startproject config .

# 6. Create Django app
python manage.py startapp myapp

# 7. Install additional packages (as needed)
uv pip install pillow  # For image handling
uv pip install psycopg2-binary  # For PostgreSQL
uv pip install django-debug-toolbar  # For debugging
uv pip install python-dotenv  # For environment variables

# 8. Save dependencies
uv pip freeze > requirements.txt
# or
pip freeze > requirements.txt

# 9. Create .gitignore
echo ".venv/" > .gitignore
echo "__pycache__/" >> .gitignore
echo "*.pyc" >> .gitignore
echo "db.sqlite3" >> .gitignore
echo ".env" >> .gitignore
echo "media/" >> .gitignore
echo "staticfiles/" >> .gitignore
echo "logs/" >> .gitignore

# 10. Initialize Git
git init
git add .
git commit -m "Initial commit"

# 11. Run development server
python manage.py runserver
```

---

## A.2: Essential Django Management Commands

### Development Commands

| Command | Purpose | Example |
|---------|---------|---------|
| `runserver` | Start development server | `python manage.py runserver` |
| `runserver 8080` | Start on specific port | `python manage.py runserver 8080` |
| `runserver 0.0.0.0:8000` | Allow external access | `python manage.py runserver 0.0.0.0:8000` |
| `shell` | Open Django interactive shell | `python manage.py shell` |
| `shell_plus` | Shell with auto-imports (with django-extensions) | `python manage.py shell_plus` |
| `check` | Check project for issues | `python manage.py check` |
| `showmigrations` | Show migration status | `python manage.py showmigrations` |
| `diffsettings` | Show settings differences | `python manage.py diffsettings` |

### Database Commands

| Command | Purpose | Example |
|---------|---------|---------|
| `makemigrations` | Create new migrations | `python manage.py makemigrations` |
| `makemigrations myapp` | Create migrations for specific app | `python manage.py makemigrations myapp` |
| `makemigrations --name` | Name migration file | `python manage.py makemigrations --name initial` |
| `migrate` | Apply migrations | `python manage.py migrate` |
| `migrate myapp` | Apply migrations for specific app | `python manage.py migrate myapp` |
| `migrate --fake` | Mark migrations as applied | `python manage.py migrate --fake` |
| `sqlmigrate` | Show SQL for migration | `python manage.py sqlmigrate myapp 0001` |
| `flush` | Reset database (clear all data) | `python manage.py flush` |
| `dbshell` | Open database shell | `python manage.py dbshell` |

### User and Authentication Commands

| Command | Purpose | Example |
|---------|---------|---------|
| `createsuperuser` | Create admin user | `python manage.py createsuperuser` |
| `changepassword` | Change user password | `python manage.py changepassword username` |
| `createsuperuser --username` | Specify username | `python manage.py createsuperuser --username admin` |

### Static and Media Files

| Command | Purpose | Example |
|---------|---------|---------|
| `collectstatic` | Collect static files | `python manage.py collectstatic` |
| `collectstatic --noinput` | Skip confirmation | `python manage.py collectstatic --noinput` |
| `findstatic` | Find static file | `python manage.py findstatic css/style.css` |

### Testing Commands

| Command | Purpose | Example |
|---------|---------|---------|
| `test` | Run all tests | `python manage.py test` |
| `test myapp` | Test specific app | `python manage.py test myapp` |
| `test myapp.tests` | Test specific test file | `python manage.py test myapp.tests` |
| `test --verbosity` | Set detail level (0-3) | `python manage.py test --verbosity=2` |
| `test --keepdb` | Keep test database | `python manage.py test --keepdb` |
| `test --parallel` | Run tests in parallel | `python manage.py test --parallel` |
| `test --failfast` | Stop at first failure | `python manage.py test --failfast` |

### Utility Commands

| Command | Purpose | Example |
|---------|---------|---------|
| `startapp` | Create new app | `python manage.py startapp myapp` |
| `startproject` | Create new project | `python manage.py startproject config .` |
| `sendtestemail` | Test email configuration | `python manage.py sendtestemail admin@example.com` |
| `shell --command` | Run single command | `python manage.py shell --command="print('hello')"` |
| `dumpdata` | Export data to JSON | `python manage.py dumpdata myapp > data.json` |
| `loaddata` | Import data from JSON | `python manage.py loaddata data.json` |
| `makemessages` | Create translation files | `python manage.py makemessages -l fr` |
| `compilemessages` | Compile translations | `python manage.py compilemessages` |

---

## A.3: Common Development Workflows

### Workflow 1: Creating a New App

```bash
# 1. Create the app
python manage.py startapp myapp

# 2. Add app to INSTALLED_APPS in settings.py
# Edit config/settings.py
INSTALLED_APPS = [
    # ... Django default apps ...
    'myapp',
]

# 3. Create models in myapp/models.py
# 4. Create migrations
python manage.py makemigrations myapp

# 5. Apply migrations
python manage.py migrate

# 6. Register models in admin
# Edit myapp/admin.py

# 7. Create views and templates
# 8. Define URLs
# 9. Test the app
```

### Workflow 2: Adding a New Model

```bash
# 1. Edit models.py
# Add new model class

# 2. Create migration
python manage.py makemigrations

# 3. Review migration (optional)
python manage.py sqlmigrate myapp 0002

# 4. Apply migration
python manage.py migrate

# 5. Register with admin
# Edit admin.py

# 6. Create test data
python manage.py shell
# Create test objects
```

### Workflow 3: Debugging

```bash
# 1. Enable debug mode in settings.py
DEBUG = True

# 2. Check for syntax errors
python manage.py check

# 3. Run the server with increased verbosity
python manage.py runserver --verbosity 3

# 4. Use Django Debug Toolbar (if installed)
# Install: pip install django-debug-toolbar
# Add to settings and urls

# 5. Check logs
tail -f logs/django.log

# 6. Use shell for debugging
python manage.py shell
>>> from myapp.models import MyModel
>>> MyModel.objects.all()
```

---

## A.4: Useful One-Liners and Snippets

### Shell Snippets

```python
# Create a superuser from shell
from django.contrib.auth.models import User
User.objects.create_superuser('admin', 'admin@example.com', 'password')

# Delete all objects
MyModel.objects.all().delete()

# Bulk create
MyModel.objects.bulk_create([
    MyModel(name='Item 1'),
    MyModel(name='Item 2'),
])

# Get or create
obj, created = MyModel.objects.get_or_create(name='Test')

# Update or create
obj, created = MyModel.objects.update_or_create(
    name='Test',
    defaults={'description': 'Updated'}
)

# Get count without loading objects
count = MyModel.objects.count()

# Check if exists
exists = MyModel.objects.filter(name='Test').exists()

# Chain filters
items = MyModel.objects.filter(
    field1='value'
).exclude(
    field2='bad'
).order_by(
    '-created_at'
)[:10]

# Annotate with count
from django.db.models import Count
items = MyModel.objects.annotate(
    related_count=Count('related_objects')
)

# Select related (foreign keys)
items = MyModel.objects.select_related('foreign_key_field').all()

# Prefetch related (many-to-many)
items = MyModel.objects.prefetch_related('many_to_many_field').all()

# Debug queries
from django.db import connection
print(connection.queries)
```

### View Snippets

```python
# Function-based view with form
def my_view(request):
    if request.method == 'POST':
        form = MyForm(request.POST)
        if form.is_valid():
            # Process form
            return redirect('success')
    else:
        form = MyForm()
    return render(request, 'template.html', {'form': form})

# Class-based view
class MyListView(ListView):
    model = MyModel
    template_name = 'app/list.html'
    context_object_name = 'objects'
    paginate_by = 20

# API endpoint (JSON)
from django.http import JsonResponse
def api_view(request):
    data = {'key': 'value'}
    return JsonResponse(data)

# Redirect with message
from django.contrib import messages
def my_view(request):
    messages.success(request, 'Success message')
    return redirect('home')
```

### Template Snippets

```html
<!-- Looping with index -->
{% for item in items %}
    {{ forloop.counter }}: {{ item.name }}
{% endfor %}

<!-- Conditionals -->
{% if user.is_authenticated %}
    Welcome, {{ user.username }}
{% else %}
    <a href="{% url 'login' %}">Login</a>
{% endif %}

<!-- URL with parameters -->
<a href="{% url 'post_detail' slug=post.slug %}">View Post</a>

<!-- Include with variables -->
{% include 'includes/header.html' with title=page_title %}

<!-- Date formatting -->
{{ date_field|date:"F j, Y g:i a" }}

<!-- Default value -->
{{ value|default:"Nothing" }}

<!-- Truncate -->
{{ long_text|truncatechars:50 }}
{{ long_text|truncatewords:30 }}

<!-- Safe HTML -->
{{ html_content|safe }}

<!-- Line breaks -->
{{ text|linebreaks }}
```

---

## A.5: Environment Setup Cheat Sheet

### Virtual Environment Commands

```bash
# uv (modern, fast)
uv venv                      # Create
source .venv/bin/activate    # Activate (macOS/Linux)
.venv\Scripts\activate       # Activate (Windows)
uv pip install package       # Install
uv pip freeze                # List installed
uv pip freeze > requirements.txt  # Export
uv pip install -r requirements.txt  # Install from file
deactivate                   # Deactivate

# pip (traditional)
python -m venv .venv         # Create
source .venv/bin/activate    # Activate (macOS/Linux)
.venv\Scripts\activate       # Activate (Windows)
pip install package          # Install
pip freeze                   # List installed
pip freeze > requirements.txt  # Export
pip install -r requirements.txt  # Install from file
deactivate                   # Deactivate
```

### Django Version Commands

```bash
# Check Django version
python -m django --version

# Check Python version
python --version

# Check all installed packages
pip list

# Check Django installation location
python -c "import django; print(django.__path__)"
```

---

## A.6: Common Error Solutions

### Error: "ModuleNotFoundError: No module named 'django'"

```bash
# Solution: Activate virtual environment and install Django
source .venv/bin/activate
uv pip install django==6.0
# or
pip install django==6.0
```

### Error: "django.core.exceptions.ImproperlyConfigured: Set the SECRET_KEY..."

```bash
# Solution: Set SECRET_KEY in environment or settings.py
export SECRET_KEY='your-secret-key'
# or in settings.py
SECRET_KEY = 'your-secret-key'
```

### Error: "OperationalError: no such table: myapp_mymodel"

```bash
# Solution: Run migrations
python manage.py makemigrations
python manage.py migrate
```

### Error: "TemplateDoesNotExist: app/template.html"

```bash
# Solution: Check template directory and naming
# Ensure template exists in correct location:
# myapp/templates/myapp/template.html
# Or check TEMPLATES settings:
# 'APP_DIRS': True
```

### Error: "NoReverseMatch: Reverse for 'myview' not found"

```bash
# Solution: Check URL name in urls.py
# Check namespace in template
# Check parameters match
{% url 'app_name:view_name' param1=value %}
```

### Error: "CSRF token missing or incorrect"

```bash
# Solution: Add CSRF token to form
<form method="post">
    {% csrf_token %}
    <!-- form fields -->
</form>

# Or ensure middleware is included
MIDDLEWARE = [
    'django.middleware.csrf.CsrfViewMiddleware',
]
```

### Error: "Permission denied: /media/..." (File upload)

```bash
# Solution: Set correct permissions
chmod -R 755 media/
# Or check MEDIA_ROOT path
```

### Error: "Port 8000 already in use"

```bash
# Solution: Use different port
python manage.py runserver 8001

# Or kill existing process
# Find process using port 8000
lsof -i :8000  # macOS/Linux
netstat -ano | findstr :8000  # Windows

# Kill process
kill -9 PID  # macOS/Linux
taskkill /PID PID /F  # Windows
```

---

## A.7: Quick Reference: Django Settings Structure

```python
# config/settings.py

# Paths
BASE_DIR = Path(__file__).resolve().parent.parent

# Security
SECRET_KEY = os.environ.get('SECRET_KEY')
DEBUG = os.environ.get('DEBUG', 'False') == 'True'
ALLOWED_HOSTS = os.environ.get('ALLOWED_HOSTS', '').split(',')

# Applications
INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    # Custom apps
    'myapp',
]

# Middleware
MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

# Database
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': BASE_DIR / 'db.sqlite3',
    }
}

# Templates
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

# Static files
STATIC_URL = '/static/'
STATIC_ROOT = BASE_DIR / 'staticfiles'
STATICFILES_DIRS = [BASE_DIR / 'static']

# Media files
MEDIA_URL = '/media/'
MEDIA_ROOT = BASE_DIR / 'media'

# Authentication
LOGIN_URL = 'login'
LOGIN_REDIRECT_URL = 'home'
LOGOUT_REDIRECT_URL = 'home'

# Internationalization
LANGUAGE_CODE = 'en-us'
TIME_ZONE = 'UTC'
USE_I18N = True
USE_TZ = True

# Default field
DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'
```

---

## A.8: Directory Structure Reference

### Standard Django Project Structure

```
project_root/
├── manage.py
├── requirements.txt
├── .env
├── .gitignore
├── README.md
│
├── config/
│   ├── __init__.py
│   ├── settings.py
│   ├── urls.py
│   ├── asgi.py
│   ├── wsgi.py
│   └── settings/
│       ├── base.py
│       ├── development.py
│       └── production.py
│
├── apps/
│   ├── __init__.py
│   ├── myapp/
│   │   ├── __init__.py
│   │   ├── admin.py
│   │   ├── apps.py
│   │   ├── forms.py
│   │   ├── models.py
│   │   ├── urls.py
│   │   ├── views.py
│   │   ├── tests.py
│   │   ├── validators.py
│   │   ├── signals.py
│   │   ├── middleware.py
│   │   ├── context_processors.py
│   │   ├── migrations/
│   │   │   └── __init__.py
│   │   ├── templates/
│   │   │   └── myapp/
│   │   ├── static/
│   │   │   └── myapp/
│   │   │       ├── css/
│   │   │       ├── js/
│   │   │       └── images/
│   │   └── services/
│   │       ├── __init__.py
│   │       └── my_service.py
│   └── another_app/
│
├── templates/
│   ├── base.html
│   ├── includes/
│   │   ├── header.html
│   │   └── footer.html
│   └── registration/
│       ├── login.html
│       └── register.html
│
├── static/
│   ├── css/
│   │   └── style.css
│   ├── js/
│   │   └── main.js
│   └── images/
│
├── media/
│   ├── posts/
│   └── avatars/
│
├── logs/
│   └── django.log
│
├── scripts/
│   ├── deploy.sh
│   └── backup.py
│
├── docker/
│   ├── Dockerfile
│   ├── docker-compose.yml
│   └── nginx/
│       ├── nginx.conf
│       └── conf.d/
│
├── docs/
│   ├── API.md
│   └── DEPLOYMENT.md
│
└── tests/
    ├── test_models.py
    ├── test_views.py
    └── test_forms.py
```

---

## A.9: Useful Third-Party Packages

### Development Tools

| Package | Purpose | Installation |
|---------|---------|--------------|
| `django-debug-toolbar` | Debugging panel | `pip install django-debug-toolbar` |
| `django-extensions` | Additional management commands | `pip install django-extensions` |
| `ipython` | Better interactive shell | `pip install ipython` |
| `werkzeug` | Debugger for development | `pip install werkzeug` |
| `coverage` | Test coverage | `pip install coverage` |
| `pytest-django` | Better testing | `pip install pytest-django` |
| `pre-commit` | Git hooks | `pip install pre-commit` |
| `black` | Code formatter | `pip install black` |
| `flake8` | Linter | `pip install flake8` |
| `isort` | Import sorter | `pip install isort` |

### Production Packages

| Package | Purpose | Installation |
|---------|---------|--------------|
| `gunicorn` | WSGI server | `pip install gunicorn` |
| `psycopg2-binary` | PostgreSQL adapter | `pip install psycopg2-binary` |
| `django-redis` | Redis cache backend | `pip install django-redis` |
| `whitenoise` | Static file serving | `pip install whitenoise` |
| `django-cors-headers` | CORS handling | `pip install django-cors-headers` |
| `django-allauth` | Social authentication | `pip install django-allauth` |
| `django-ckeditor` | Rich text editor | `pip install django-ckeditor` |
| `pillow` | Image processing | `pip install pillow` |
| `boto3` | AWS S3 storage | `pip install boto3` |

### Utilities

| Package | Purpose | Installation |
|---------|---------|--------------|
| `python-dotenv` | Environment variables | `pip install python-dotenv` |
| `celery` | Task queue | `pip install celery` |
| `django-celery-beat` | Celery scheduling | `pip install django-celery-beat` |
| `sentry-sdk` | Error tracking | `pip install sentry-sdk` |
| `django-storages` | Custom file storage | `pip install django-storages` |
| `django-import-export` | Data import/export | `pip install django-import-export` |
| `django-filter` | Advanced filtering | `pip install django-filter` |
| `django-taggit` | Tagging system | `pip install django-taggit` |
| `django-mptt` | Tree structures | `pip install django-mptt` |
| `django-summernote` | WYSIWYG editor | `pip install django-summernote` |

---

## A.10: Environment Variables Reference

### Essential Environment Variables

```bash
# Django Core
DJANGO_SETTINGS_MODULE=config.settings
SECRET_KEY=your-super-secret-key
DEBUG=True|False
ALLOWED_HOSTS=localhost,127.0.0.1,domain.com

# Database
DB_NAME=django_db
DB_USER=django_user
DB_PASSWORD=secure_password
DB_HOST=localhost
DB_PORT=5432
DATABASE_URL=postgresql://user:pass@host:port/dbname

# Static/Media
STATIC_URL=/static/
MEDIA_URL=/media/
STATIC_ROOT=/path/to/staticfiles
MEDIA_ROOT=/path/to/media

# Email
EMAIL_BACKEND=smtp|console|file
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USE_TLS=True
EMAIL_HOST_USER=your_email@gmail.com
EMAIL_HOST_PASSWORD=your_password
DEFAULT_FROM_EMAIL=noreply@domain.com

# Cache
REDIS_URL=redis://localhost:6379/1
CACHE_URL=redis://localhost:6379/1
MEMCACHED_HOST=localhost

# Security
SECURE_SSL_REDIRECT=True
SESSION_COOKIE_SECURE=True
CSRF_COOKIE_SECURE=True
SECURE_HSTS_SECONDS=31536000

# Site
SITE_URL=https://yourdomain.com
SITE_NAME=My Django Site

# Sentry (error tracking)
SENTRY_DSN=https://your-sentry-dsn

# Celery
CELERY_BROKER_URL=redis://localhost:6379/0
CELERY_RESULT_BACKEND=redis://localhost:6379/0
```

---

This appendix provides a comprehensive reference for all the common tasks, commands, and configurations you'll need as you continue your Django journey. Keep it handy!
**[APPENDIX B — Django Model Field Reference]**
