# Primer 6: Virtual Environments and Package Management

## Welcome to the Python Environment Primer!

This primer explains how Python manages packages and why virtual environments are essential for Django development. Understanding these concepts will help you avoid common pitfalls and keep your projects organized.

By the end of this primer, you'll understand what virtual environments are, why you need them, and how to use them effectively.

---

## P.1: What are Python Packages?

### The Simple Answer

Python packages are reusable code libraries that add functionality to Python. Think of them like apps on your phone — you install them to add new features.

### How Packages Work

```
┌─────────────────────────────────────────────────────────┐
│                    Your Python Code                     │
│                                                         │
│  import django                                          │
│  from django.shortcuts import render                    │
│                                                         │
│  ╔═══════════════════════════════════════════════════╗  │
│  ║             Python Packages                       ║  │
│  ║  ┌─────────────┐  ┌─────────────┐  ┌─────────┐  ║  │
│  ║  │   Django     │  │   Pillow    │  │  Psycopg2│  ║  │
│  ║  │  (Web)       │  │  (Images)   │  │ (Database)║  │  │
│  ║  └─────────────┘  └─────────────┘  └─────────┘  ║  │
│  ╚═══════════════════════════════════════════════════╝  │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### Common Python Packages for Django

| Package | Purpose | Installation |
|---------|---------|--------------|
| `django` | Web framework | `pip install django` |
| `pillow` | Image processing | `pip install pillow` |
| `psycopg2` | PostgreSQL adapter | `pip install psycopg2-binary` |
| `gunicorn` | Production server | `pip install gunicorn` |
| `django-debug-toolbar` | Debugging | `pip install django-debug-toolbar` |
| `django-cors-headers` | CORS handling | `pip install django-cors-headers` |
| `celery` | Task queue | `pip install celery` |
| `django-redis` | Redis integration | `pip install django-redis` |
| `sentry-sdk` | Error tracking | `pip install sentry-sdk` |
| `python-dotenv` | Environment variables | `pip install python-dotenv` |

---

## P.2: The Problem with Global Packages

### The "Global" Issue

When you install packages globally (without a virtual environment), they go to a central location on your computer. This creates several problems:

```
┌─────────────────────────────────────────────────────────┐
│              Global Python Environment                  │
│                                                         │
│  ┌─────────────────────────────────────────────────────┐│
│  │  Package A (v1.0)                                  ││
│  │  Package B (v2.0)                                  ││
│  │  Package C (v3.0)                                  ││
│  │  Package D (v1.5)                                  ││
│  └─────────────────────────────────────────────────────┘│
│                                                         │
│  All projects share these packages!                     │
│                                                         │
│  Project 1 needs Package A v1.0                        │
│  Project 2 needs Package A v2.0 ← CONFLICT!           │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### The Three Main Problems

**1. Version Conflicts**
```
Project A: Requires Django 4.2
Project B: Requires Django 5.0
→ You can't have both installed globally!
```

**2. Permission Issues**
```
# Installing packages globally often requires admin rights
sudo pip install django
# ↑ This can be dangerous and messy
```

**3. Dependency Chaos**
```
Project A depends on Package X (v1.0)
Project A also depends on Package Y (v2.0)
Package Y depends on Package X (v1.5)
→ Which version of X is used?
```

### Real-World Example

```python
# Project 1: Blog (uses Django 4.2)
import django
print(django.VERSION)  # (4, 2, 0)

# Project 2: New App (needs Django 5.0)
import django
print(django.VERSION)  # (4, 2, 0) → Not 5.0!

# Both projects would use the same Django version,
# causing one of them to break!
```

---

## P.3: What are Virtual Environments?

### The Simple Answer

A virtual environment is an isolated Python environment for a single project. Each project gets its own copy of Python and its own packages.

```
┌─────────────────────────────────────────────────────────┐
│                     Your Computer                       │
│                                                         │
│  ┌─────────────────────────────────────────────────────┐│
│  │  System Python (Global)                           ││
│  │  • Python 3.12                                    ││
│  │  • No project packages                            ││
│  └─────────────────────────────────────────────────────┘│
│                                                         │
│  ┌─────────────────────────────────────────────────────┐│
│  │  Project 1 Virtual Environment                     ││
│  │  • Python 3.12                                    ││
│  │  • Django 4.2                                     ││
│  │  • Pillow 10.0                                    ││
│  └─────────────────────────────────────────────────────┘│
│                                                         │
│  ┌─────────────────────────────────────────────────────┐│
│  │  Project 2 Virtual Environment                     ││
│  │  • Python 3.12                                    ││
│  │  • Django 5.0                                     ││
│  │  • Psycopg2 2.9                                   ││
│  └─────────────────────────────────────────────────────┘│
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### How Virtual Environments Work

```
┌─────────────────────────────────────────────────────────┐
│              Virtual Environment (Project 1)            │
│                                                         │
│  Location: ~/projects/blog/.venv/                      │
│                                                         │
│  ┌─────────────────────────────────────────────────────┐│
│  │  bin/ (or Scripts/ on Windows)                    ││
│  │  ├── python                                        ││
│  │  ├── pip                                           ││
│  │  └── django-admin                                  ││
│  ├─────────────────────────────────────────────────────┤│
│  │  lib/                                              ││
│  │  └── python3.12/                                   ││
│  │      └── site-packages/                           ││
│  │          ├── django/                               ││
│  │          ├── pillow/                               ││
│  │          └── psycopg2/                             ││
│  └─────────────────────────────────────────────────────┘│
│                                                         │
│  When activated:                                       │
│  • PYTHONPATH points to lib/                          │
│  • PATH includes bin/                                 │
│  • All Python commands use this environment           │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

---

## P.4: Virtual Environment Tools

### Option 1: venv (Built-in)

`venv` is built into Python (3.3+). It's simple and reliable.

```bash
# Create virtual environment
python -m venv .venv

# Activate (macOS/Linux)
source .venv/bin/activate

# Activate (Windows Command Prompt)
.venv\Scripts\activate

# Activate (Windows PowerShell)
.venv\Scripts\Activate.ps1

# Deactivate
deactivate

# Delete virtual environment
rm -rf .venv  # macOS/Linux
rmdir /s .venv  # Windows
```

### Option 2: uv (Modern, Fast)

`uv` is a modern, blazing-fast package manager from the creators of Ruff.

```bash
# Install uv
curl -LsSf https://astral.sh/uv/install.sh | sh  # macOS/Linux
powershell -c "irm https://astral.sh/uv/install.ps1 | iex"  # Windows

# Create virtual environment
uv venv

# Activate (same as venv)
source .venv/bin/activate

# Install packages
uv pip install django
uv pip install pillow

# Requirements file
uv pip freeze > requirements.txt
uv pip install -r requirements.txt
```

### Option 3: Poetry (Full Featured)

Poetry is a full-featured package manager with dependency resolution.

```bash
# Install Poetry
curl -sSL https://install.python-poetry.org | python3 -

# Create new project
poetry new myproject

# Initialize in existing project
poetry init

# Install packages
poetry add django
poetry add pillow

# Install development packages
poetry add --dev pytest

# Activate virtual environment
poetry shell

# Export to requirements.txt
poetry export -f requirements.txt -o requirements.txt
```

### Comparison

| Feature | venv | uv | Poetry |
|---------|------|----|--------|
| Built-in | ✅ | ❌ | ❌ |
| Speed | 🐢 | 🚀 | 🐢 |
| Dependency resolution | ❌ | ❌ | ✅ |
| Lock file | ❌ | ✅ | ✅ |
| Easy to use | ✅ | ✅ | ✅ |
| Learning curve | Low | Low | Medium |
| Best for | Simple projects | All projects | Complex projects |

---

## P.5: Working with Virtual Environments

### Typical Workflow

```bash
# 1. Create project directory
mkdir my_django_project
cd my_django_project

# 2. Create virtual environment
python -m venv .venv

# 3. Activate virtual environment
source .venv/bin/activate

# 4. Install Django
pip install django==6.0

# 5. Create Django project
django-admin startproject config .

# 6. Work on your project
# ... write code ...

# 7. Save dependencies
pip freeze > requirements.txt

# 8. Deactivate when done
deactivate
```

### Later, Coming Back to Your Project

```bash
# 1. Navigate to project
cd my_django_project

# 2. Activate virtual environment
source .venv/bin/activate

# 3. Install dependencies (if needed)
pip install -r requirements.txt

# 4. Continue working
python manage.py runserver
```

### Sharing Your Project

```bash
# On your machine:
# 1. Create requirements.txt
pip freeze > requirements.txt

# 2. Share: project folder + requirements.txt
# (Don't share the .venv folder!)

# On another machine:
# 1. Clone/download project
# 2. Create virtual environment
python -m venv .venv

# 3. Activate virtual environment
source .venv/bin/activate

# 4. Install dependencies
pip install -r requirements.txt

# 5. Run the project
python manage.py runserver
```

### Git Workflow

```bash
# .gitignore - Don't commit virtual environment
echo ".venv/" >> .gitignore
echo "__pycache__/" >> .gitignore
echo "*.pyc" >> .gitignore
echo "db.sqlite3" >> .gitignore
echo ".env" >> .gitignore

# Commit requirements and code
git add requirements.txt
git add config/ blog/
git commit -m "Initial Django project"
git push
```

---

## P.6: Requirements Files

### What is requirements.txt?

A `requirements.txt` file lists all packages your project needs with their specific versions.

### Creating requirements.txt

```bash
# After installing all packages
pip freeze > requirements.txt
```

### Example requirements.txt

```txt
# requirements.txt
Django==6.0.0
pillow==10.2.0
psycopg2-binary==2.9.9
gunicorn==21.2.0
python-dotenv==1.0.0
django-debug-toolbar==4.2.0
```

### Installing from requirements.txt

```bash
pip install -r requirements.txt
```

### Version Specifiers

| Specifier | Meaning | Example |
|-----------|---------|---------|
| `package==1.2.3` | Exact version | `Django==6.0.0` |
| `package>=1.2.3` | Minimum version | `Django>=6.0` |
| `package<=1.2.3` | Maximum version | `Django<=6.0` |
| `package~=1.2.3` | Compatible version | `Django~=6.0` |
| `package` | Latest version | `Django` |

### Two Types of Dependencies

```txt
# Production dependencies
Django==6.0.0
pillow==10.2.0
psycopg2-binary==2.9.9
gunicorn==21.2.0

# Development dependencies
pytest==8.1.0
black==24.2.0
flake8==7.0.0
django-debug-toolbar==4.2.0
```

### Separate Requirements Files

```bash
# Create separate files
pip freeze > requirements.txt  # Production
pip freeze > requirements-dev.txt  # Development

# Or use sections
# requirements.txt:
Django==6.0.0
pillow==10.2.0

# -r requirements.txt  # Include production
pytest==8.1.0
black==24.2.0
```

---

## P.7: Common Problems and Solutions

### Problem: Virtual Environment Not Activated

**Symptom**: Packages not found even though they're installed

```
$ python manage.py runserver
Traceback (most recent call last):
  File "manage.py", line 8, in <module>
    from django.core.management import execute_from_command_line
ModuleNotFoundError: No module named 'django'
```

**Solution**:
```bash
# Check if virtual environment is activated
echo $VIRTUAL_ENV  # Should show path, or nothing

# If not activated, activate it
source .venv/bin/activate
```

### Problem: Wrong Python Version

**Symptom**: Using system Python instead of virtual environment Python

```bash
# Check which Python is being used
which python
# Should show: /path/to/project/.venv/bin/python
```

**Solution**: Recreate virtual environment with correct Python version

```bash
# Delete and recreate
rm -rf .venv
python3.12 -m venv .venv
```

### Problem: Permission Denied

**Symptom**: Can't install packages globally

```bash
$ pip install django
ERROR: Could not install packages due to an EnvironmentError: [Errno 13] Permission denied
```

**Solution**:
```bash
# Use virtual environment (no sudo needed)
source .venv/bin/activate
pip install django

# OR install globally with sudo (not recommended)
sudo pip install django
```

### Problem: Package Not Found

**Symptom**: Package name is wrong

```
$ pip install djangoo
ERROR: Could not find a version that satisfies the requirement djangoo
```

**Solution**: Check the package name and try again

```bash
# Search for packages
pip search django  # Find correct package name
pip install django  # Correct package name
```

### Problem: Version Conflict

**Symptom**: Multiple packages require conflicting versions

```
ERROR: django 6.0.0 has requirement asgiref~=3.7, but you'll have asgiref 3.6.0
```

**Solution**:
```bash
# Install specific compatible versions
pip install asgiref~=3.7
pip install django==6.0.0

# Or let pip resolve conflicts
pip install --upgrade django

# In the future, use constraints
echo "asgiref~=3.7" > constraints.txt
pip install -c constraints.txt django
```

---

## P.8: Best Practices

### 1. Always Use Virtual Environments

```bash
# DO
python -m venv .venv
source .venv/bin/activate
pip install django

# DON'T
pip install django  # Installs globally
```

### 2. Keep Requirements Up to Date

```bash
# After installing any new package
pip freeze > requirements.txt

# Check for outdated packages
pip list --outdated

# Update packages
pip install --upgrade django
```

### 3. Use .gitignore Properly

```bash
# Add to .gitignore
.venv/
__pycache__/
*.pyc
*.pyo
db.sqlite3
.env
.DS_Store
*.log
media/
staticfiles/
```

### 4. Pin Exact Versions

```txt
# Good: Exact versions
Django==6.0.0
pillow==10.2.0

# Bad: No version specified
Django
pillow
```

### 5. Document Your Setup

```bash
# README.md
## Setup

1. Create virtual environment:
   python -m venv .venv

2. Activate virtual environment:
   source .venv/bin/activate

3. Install dependencies:
   pip install -r requirements.txt

4. Run migrations:
   python manage.py migrate

5. Start the server:
   python manage.py runserver
```

### 6. Use Development and Production Dependencies

```txt
# requirements.txt (Production)
Django==6.0.0
pillow==10.2.0
psycopg2-binary==2.9.9
gunicorn==21.2.0

# requirements-dev.txt (Development)
-r requirements.txt
pytest==8.1.0
black==24.2.0
flake8==7.0.0
django-debug-toolbar==4.2.0
```

---

## P.9: Quick Reference

### Virtual Environment Commands

| Command | Purpose |
|---------|---------|
| `python -m venv .venv` | Create virtual environment |
| `source .venv/bin/activate` | Activate (macOS/Linux) |
| `.venv\Scripts\activate` | Activate (Windows) |
| `deactivate` | Deactivate |
| `rm -rf .venv` | Delete (macOS/Linux) |
| `rmdir /s .venv` | Delete (Windows) |
| `pip install package` | Install package |
| `pip uninstall package` | Uninstall package |
| `pip freeze` | List installed packages |
| `pip freeze > requirements.txt` | Create requirements |
| `pip install -r requirements.txt` | Install from requirements |
| `pip list` | List installed packages (with info) |
| `pip list --outdated` | Check for updates |
| `pip install --upgrade package` | Update a package |
| `pip show package` | Show package info |

### uv Commands

| Command | Purpose |
|---------|---------|
| `uv venv` | Create virtual environment |
| `uv pip install package` | Install package |
| `uv pip freeze` | List installed packages |
| `uv pip freeze > requirements.txt` | Create requirements |
| `uv pip install -r requirements.txt` | Install from requirements |
| `uv pip list` | List installed packages |
| `uv pip install --upgrade package` | Update a package |

### Poetry Commands

| Command | Purpose |
|---------|---------|
| `poetry new project` | Create new project |
| `poetry init` | Initialize existing project |
| `poetry install` | Install dependencies |
| `poetry add package` | Add package |
| `poetry remove package` | Remove package |
| `poetry shell` | Activate virtual environment |
| `poetry run` | Run command in virtual environment |
| `poetry export` | Export to requirements.txt |

---

This primer gives you everything you need to manage Python packages and virtual environments effectively. Mastering these concepts is essential for professional Django development!
