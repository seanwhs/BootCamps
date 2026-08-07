# Mastering Django 6: References and Resources

This comprehensive reference guide provides all the resources you need to continue your Django journey beyond the course. From official documentation to recommended books, community channels, and essential tools, this guide will serve as your ongoing companion as you build Django applications.

---

## Official Documentation

### Primary Django Resources

| Resource | URL | Description |
|----------|-----|-------------|
| **Django Project Website** | [djangoproject.com](https://www.djangoproject.com/) | Official homepage with downloads, documentation, and news. Note that Django 6.1 was released on August 5, 2026, and Django 6.0 has reached the end of mainstream support . |
| **Django Documentation** | [docs.djangoproject.com](https://docs.djangoproject.com/) | Complete reference for all Django features, including tutorials, topic guides, and API reference. The official tutorial is an excellent companion to this course . |
| **Django 6.0 Release Notes** | [docs.djangoproject.com/en/6.0/releases/6.0/](https://docs.djangoproject.com/en/6.0/releases/6.0/) | Detailed changes in Django 6.0, including new features like `forloop.length` in templates, improved JSONField support on SQLite, and the new `AnyValue` aggregate . |
| **Django Topics Guide** | [docs.djangoproject.com/en/6.0/topics/](https://docs.djangoproject.com/en/6.0/topics/) | Deep dives into specific Django areas: models, views, forms, templates, authentication, caching, signals, and more . |

### Python Documentation

| Resource | URL | Description |
|----------|-----|-------------|
| **Python 3.14 Documentation** | [docs.python.org/3](https://docs.python.org/3/) | Complete Python standard library reference. Python 3.14 introduced major features including PEP 779 (free-threaded Python support), PEP 750 (template string literals), and PEP 784 (Zstandard compression) . |
| **Python Tutorial** | [docs.python.org/3/tutorial/](https://docs.python.org/3/tutorial/) | Beginner-friendly introduction to Python programming . |
| **Python Language Reference** | [docs.python.org/3/reference/](https://docs.python.org/3/reference/) | Comprehensive language syntax and semantics documentation. |

---

## Essential Books

### Django Books

| Book | Author | Description |
|------|--------|-------------|
| **Web Development with Django 6, Third Edition** | Various | A hands-on guide to building modern web applications with Django 6, covering async features, updated templates, forms, REST APIs, and deployment. Builds a book-review site called "Bookr" through realistic case studies . |
| **Two Scoops of Django** | Daniel Roy Greenfeld & Audrey Roy Greenfeld | Best practices for Django development, covering project structure, patterns, and optimization. Essential for moving from beginner to intermediate. |
| **Django for Beginners** | William S. Vincent | Step-by-step guide to building Django applications from scratch, ideal for those new to web development. |
| **Django 4 By Example** | Antonio Mele | Practical projects that demonstrate Django's capabilities, including e-commerce, CMS, and social networking applications. |

### General Web Development

| Book | Description |
|------|-------------|
| **HTML and CSS: Design and Build Websites** | Visual introduction to frontend fundamentals |
| **JavaScript: The Good Parts** | Essential JavaScript concepts for frontend development |
| **Learning SQL** | Comprehensive introduction to SQL and relational databases |

---

## Online Learning Platforms

| Platform | Description | Django Content |
|----------|-------------|----------------|
| **Real Python** | [realpython.com](https://realpython.com/) | High-quality Python and Django tutorials, including async Django, testing, and deployment guides. |
| **Django Girls Tutorial** | [tutorial.djangogirls.org](https://tutorial.djangogirls.org/) | Free, beginner-friendly Django tutorial covering fundamentals. |
| **MDN Django Tutorial** | [developer.mozilla.org](https://developer.mozilla.org/en-US/docs/Learn_web_development/Extensions/Server-side/Django) | Comprehensive tutorial covering deployment, including PythonAnywhere and Railway guides . |
| **Test-Driven Development with Django** | Various | Books and courses on TDD practices for Django applications. |

---

## Deployment Guides and Hosting

### Production Checklist

The Django documentation provides a comprehensive **Deployment Checklist** that covers critical settings for production :

| Setting | Action |
|---------|--------|
| `manage.py check --deploy` | Run this command against your production settings to catch security issues . |
| `SECRET_KEY` | Use environment variables; never hardcode. Consider using `SECRET_KEY_FALLBACKS` for key rotation . |
| `DEBUG` | Must be `False` in production to prevent information leakage . |
| `ALLOWED_HOSTS` | Required when `DEBUG=False`. Use specific domain names, not wildcards . |
| `CSRF_TRUSTED_ORIGINS` | Include your domain for CSRF protection . |

**Security Headers** - Essential for production :

```python
SECURE_BROWSER_XSS_FILTER = True
SECURE_CONTENT_TYPE_NOSNIFF = True
X_FRAME_OPTIONS = 'DENY'
CSRF_COOKIE_SECURE = True
SESSION_COOKIE_SECURE = True
SECURE_SSL_REDIRECT = True
SECURE_HSTS_SECONDS = 31536000  # 1 year
SECURE_HSTS_INCLUDE_SUBDOMAINS = True
SECURE_HSTS_PRELOAD = True
```

**Static and Media Files** :

```python
STATIC_URL = '/static/'
STATIC_ROOT = '/var/www/myproject/static/'
MEDIA_URL = '/media/'
MEDIA_ROOT = '/var/www/myproject/media/'
```

### Hosting Providers

| Provider | Description | Django Support |
|----------|-------------|----------------|
| **PythonAnywhere** | Beginner-friendly hosting with Django-specific guides. Environment variables are set via Bash commands and an `.env` file . | Excellent |
| **Railway** | Modern container-based platform with good Django support. Uses `runtime.txt`, `requirements.txt`, `Procfile`, and `wsgi.py` . | Good |
| **Heroku** | Popular PaaS with Django deployment support. | Good |
| **DigitalOcean** | VPS hosting with Django droplet options. | Excellent |
| **AWS (EC2, Elastic Beanstalk)** | Cloud hosting with Django-specific guides. | Good |
| **Fly.io** | Modern platform for containerized applications. | Good |

### Environment Variables 

```bash
# .env file for PythonAnywhere
DJANGO_DEBUG=False
DJANGO_SECRET_KEY=your-secret-key
DATABASE_URL=postgresql://user:pass@host:port/dbname
DB_NAME=myproject
DB_USER=myuser
DB_PASSWORD=secure_password
DB_HOST=localhost
DB_PORT=5432
```

---

## Development Tools

### Essential Tools

| Tool | Purpose | URL |
|------|---------|-----|
| **VS Code** | Primary code editor with excellent Python/Django support | [code.visualstudio.com](https://code.visualstudio.com/) |
| **PyCharm Professional** | Django-specific IDE with built-in tools | [jetbrains.com/pycharm](https://www.jetbrains.com/pycharm/) |
| **Django Debug Toolbar** | Debugging panel showing SQL queries, cache, headers | [github.com/jazzband/django-debug-toolbar](https://github.com/jazzband/django-debug-toolbar) |
| **Postman** | API testing and development | [postman.com](https://www.postman.com/) |
| **DBeaver** | Universal database management tool | [dbeaver.io](https://dbeaver.io/) |
| **Git** | Version control | [git-scm.com](https://git-scm.com/) |
| **Docker** | Containerization for deployment | [docker.com](https://www.docker.com/) |

### VS Code Extensions for Django

| Extension | Purpose |
|-----------|---------|
| **Python** (Microsoft) | Python language support, debugging |
| **Django** | Syntax highlighting, autocomplete |
| **Django Template** | Template tag/filter support |
| **Prettier** | Code formatting |
| **ESLint** | JavaScript linting |
| **SQLTools** | Database integration |
| **GitLens** | Git history and annotations |

---

## Production Server Configuration

### Gunicorn Setup

Gunicorn is the recommended WSGI server for production :

```python
# gunicorn.conf.py
import multiprocessing

# Bind to a Unix socket for performance
bind = 'unix:/run/gunicorn/myproject.sock'

# Rule of thumb: (2 x CPU cores) + 1
workers = multiprocessing.cpu_count() * 2 + 1

worker_class = 'sync'
timeout = 30

# Restart workers to prevent memory leaks
max_requests = 1000
max_requests_jitter = 50

accesslog = '/var/log/gunicorn/access.log'
errorlog = '/var/log/gunicorn/error.log'
loglevel = 'warning'

user = 'www-data'
group = 'www-data'
```

### Nginx Configuration Example

```nginx
server {
    listen 80;
    server_name yourdomain.com;

    location /static/ {
        alias /var/www/myproject/static/;
        expires 30d;
    }

    location /media/ {
        alias /var/www/myproject/media/;
        expires 30d;
    }

    location / {
        proxy_pass http://unix:/run/gunicorn/myproject.sock;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### Systemd Service File

```ini
# /etc/systemd/system/gunicorn-myproject.service
[Unit]
Description=Gunicorn daemon for myproject
After=network.target

[Service]
User=www-data
Group=www-data
WorkingDirectory=/var/www/myproject
Environment="PATH=/var/www/myproject/venv/bin"
Environment="DJANGO_SETTINGS_MODULE=config.settings.production"
ExecStart=/var/www/myproject/venv/bin/gunicorn --config gunicorn.conf.py config.wsgi:application
Restart=always

[Install]
WantedBy=multi-user.target
```

---

## Community and Support

### Official Channels

| Resource | URL | Description |
|----------|-----|-------------|
| **Django Discord** | [discord.com/invite/django](https://discord.com/invite/django) | Official Discord server for Django developers |
| **Django Subreddit** | [reddit.com/r/django](https://www.reddit.com/r/django/) | Active community with news, questions, and resources |
| **Django Forum** | [forum.djangoproject.com](https://forum.djangoproject.com/) | Official Django discussion forum |
| **Stack Overflow** | [stackoverflow.com/questions/tagged/django](https://stackoverflow.com/questions/tagged/django) | Django Q&A with comprehensive archives |

### News and Updates

| Resource | Description |
|----------|-------------|
| **Django Weblog** | [djangoproject.com/weblog/](https://www.djangoproject.com/weblog/) | Official Django release announcements and news |
| **Django Weekly** | [djangoweekly.com](https://djangoweekly.com/) | Weekly newsletter with Django news, packages, and tutorials |
| **Python Insider** | [python.org/blogs/](https://www.python.org/blogs/) | Python release announcements and major updates |

---

## Key Django 6.0 Features

### Major Updates

Django 6.0 includes several important changes and new features :

**Template Improvements**:
- New `forloop.length` variable available in `for` loops
- Enhanced `querystring` template tag with better query string handling

**Database and ORM**:
- JSONField supports negative array indexing on SQLite
- New `AnyValue` aggregate returns arbitrary non-null values
- `StringAgg` aggregate now supported on backends other than PostgreSQL
- `Model.NotUpdated` exception for failed forced updates

**Backend and API Changes**:
- `DEFAULT_AUTO_FIELD` now defaults to `BigAutoField`
- Support for MariaDB 10.6+ (dropped 10.5 support)
- **Minimum Python version: Python 3.12**
- Multiple Cookie headers supported for HTTP/2 requests with ASGI

**Testing**:
- `DiscoverRunner` supports parallel test execution with forkserver

### Django 6.1 Updates

Released on August 5, 2026, Django 6.1 introduces :
- Model field fetch modes for configuring on-demand fetching
- Database-level delete options for `ForeignKey.on_delete`
- Dictionary-based email settings

> **Note**: Django 6.0 has reached end of mainstream support (as of August 5, 2026). It will receive security and data loss fixes until April 2027. Upgrade to Django 6.1 for continued support .

### Python 3.14 Compatibility

Python 3.14 is the minimum supported version for Django 6.0. Key Python features include :
- PEP 779: Free-threaded Python officially supported
- PEP 750: Template string literals (t-strings)
- PEP 784: Zstandard compression support in `compression.zstd`
- PEP 734: Multiple interpreters in the standard library
- Improved error messages and syntax highlighting in PyREPL

---

## Appendix: Quick Reference

### Essential Django Commands

```bash
# Project Setup
django-admin startproject config .
python manage.py startapp blog

# Development
python manage.py runserver
python manage.py shell

# Database
python manage.py makemigrations
python manage.py migrate
python manage.py showmigrations

# Admin
python manage.py createsuperuser

# Testing
python manage.py test
python manage.py test blog --verbosity=2

# Production
python manage.py check --deploy
python manage.py collectstatic
```

### Common Environment Variables

```bash
SECRET_KEY=your-super-secret-key
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
DEFAULT_FROM_EMAIL=noreply@yourdomain.com
SITE_URL=https://yourdomain.com
REDIS_URL=redis://localhost:6379/1
```

---

## Conclusion

This references and resources guide provides a comprehensive foundation for continued learning and professional Django development. Keep these resources accessible as you build, deploy, and maintain Django applications.

**Next Steps After This Course:**

1. Build your own Django project (capstone)
2. Explore Django REST Framework for API development
3. Learn advanced topics: async views, WebSocket support, microservices
4. Contribute to open source Django projects
5. Stay updated with Django releases and community news
