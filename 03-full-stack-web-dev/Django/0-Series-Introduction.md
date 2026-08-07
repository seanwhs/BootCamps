# Mastering Django 6: A Practical Guide to Modern Web Development
## From Fundamentals to Production-Ready Applications

---

# Part 0: Introduction

## Welcome to the Journey

Hello and welcome to **Mastering Django 6**! This comprehensive tutorial series is designed to transform you from a Django beginner into a confident developer capable of building production-ready web applications using the latest features of **Django 6** and **Python 3.14**.

Whether you're transitioning from another web framework, looking to modernize your Django skills, or starting fresh with web development, this series will guide you through every step of building a complete application—from the first `pip install` to deploying on cloud infrastructure.

## Why This Series?

The web development landscape evolves rapidly, and Django 6 brings powerful new capabilities while maintaining the framework's legendary stability and "batteries-included" philosophy. However, many tutorials either:

- Focus on isolated framework features without showing how they work together in a real application
- Abstract away complexity with placeholders like "write your code here" 
- Skip critical topics like security, testing, and deployment
- Assume prior knowledge of complex concepts without proper introduction

**This series takes a different approach.** We'll build a complete, production-grade application incrementally, with every line of code explained, every dependency justified, and every step verifiable. By the end, you won't just understand Django—you'll have built a real application that you can deploy, show in your portfolio, and extend for your own projects.

## The Architecture: What We're Building

Before we write a single line of code, let's understand the complete system we'll build over this series. Visualizing the final architecture helps orient every decision we make along the way.

### High-Level System Architecture

Our application is a modern **SaaS (Software as a Service)** platform called **"TaskFlow"** —a collaborative project management tool that demonstrates enterprise-grade features while remaining simple enough to understand completely.

```
┌────────────────────────────────────────────────────────────────────────────────┐
│                              CLIENT LAYER                                     │
│  ┌─────────────────────────┐  ┌──────────────────────────────────────────┐  │
│  │  React SPA (Web Client) │  │  Mobile/Third-Party API Clients         │  │
│  │  - React 19             │  │  - REST API Endpoints                   │  │
│  │  - TypeScript           │  │  - JWT Authentication                  │  │
│  │  - Tailwind CSS         │  │  - JSON Responses                       │  │
│  │  - React Router         │  │  - API Rate Limiting                   │  │
│  │  - Axios for API Calls  │  │  - OpenAPI/Swagger Docs                │  │
│  └────────────┬────────────┘  └──────────────┬───────────────────────────┘  │
│               │                               │                               │
└───────────────┼───────────────────────────────┼───────────────────────────────┘
                │                               │
                ▼                               ▼
┌────────────────────────────────────────────────────────────────────────────────┐
│                        APPLICATION LAYER (Django 6)                           │
│                                                                              │
│  ┌──────────────────────────────────────────────────────────────────────┐   │
│  │                     HTTP/HTTPS REQUEST HANDLING                      │   │
│  │              URL Router → Middleware Stack → Security Layer         │   │
│  └────────────────────────────┬─────────────────────────────────────────┘   │
│                               │                                              │
│                               ▼                                              │
│  ┌────────────────────────────┴────────────────────────────────────────────┐│
│  │                                                                         ││
│  │                      VIEW LAYER (Presentation)                          ││
│  │  ┌─────────────────────┐  ┌─────────────────────┐  ┌───────────────┐  ││
│  │  │  API Views (DRF)    │  │  React SSR/SSG      │  │  Admin Views  │  ││
│  │  │  - ViewSets         │  │  (Django-React)     │  │  (Django Admin)│  ││
│  │  │  - Serializers      │  │  - REST API Calls   │  └───────────────┘  ││
│  │  └─────────────────────┘  └─────────────────────┘                    ││
│  └────────────────────────────┬────────────────────────────────────────────┘│
│                               │                                              │
│                               ▼                                              │
│  ┌────────────────────────────┴────────────────────────────────────────────┐│
│  │                                                                         ││
│  │                   BUSINESS LOGIC LAYER (Services)                       ││
│  │  ┌─────────────────────┐  ┌─────────────────────┐  ┌───────────────┐  ││
│  │  │  Authentication     │  │  Task Management    │  │  Team/Project │  ││
│  │  │  & Authorization    │  │  Services           │  │  Services     │  ││
│  │  └─────────────────────┘  └─────────────────────┘  └───────────────┘  ││
│  └────────────────────────────┬────────────────────────────────────────────┘│
│                               │                                              │
│                               ▼                                              │
│  ┌────────────────────────────┴────────────────────────────────────────────┐│
│  │                                                                         ││
│  │                     DATA LAYER (ORM)                                    ││
│  │  ┌─────────────────────┐  ┌─────────────────────┐  ┌───────────────┐  ││
│  │  │  Models             │  │  Managers/QuerySets  │  │  Migrations   │  ││
│  │  │  (Database Tables)  │  │  (Custom Queries)    │  │  (Schema      │  ││
│  │  └─────────────────────┘  └─────────────────────┘  │  Evolution)   │  ││
│  │                                                    └───────────────┘  ││
│  └────────────────────────────┬────────────────────────────────────────────┘│
│                               │                                              │
└───────────────────────────────┼──────────────────────────────────────────────┘
                                │
                                ▼
┌────────────────────────────────────────────────────────────────────────────────┐
│                        DATA STORAGE LAYER                                     │
│                                                                              │
│  ┌─────────────────────────────────┐  ┌──────────────────────────────────┐  │
│  │     PostgreSQL (Primary DB)     │  │     Redis (Cache/Queue)         │  │
│  │  - User Data                    │  │  - Session Storage               │  │
│  │  - Project/Task Data            │  │  - API Rate Limiting             │  │
│  │  - Relationships                │  │  - Celery Broker/Backend         │  │
│  │  - Full-Text Search             │  │  - Cache Invalidation            │  │
│  └─────────────────────────────────┘  └──────────────────────────────────┘  │
│                                                                              │
│  ┌─────────────────────────────────┐                                         │
│  │     Object Storage (Media)      │                                         │
│  │  - User Avatars                 │                                         │
│  │  - Project Attachments          │                                         │
│  └─────────────────────────────────┘                                         │
│                                                                              │
└────────────────────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌────────────────────────────────────────────────────────────────────────────────┐
│                    ASYNCHRONOUS TASK LAYER                                    │
│                                                                              │
│  ┌─────────────────────────────────┐  ┌──────────────────────────────────┐  │
│  │     Celery Workers              │  │     Async Views (Django 6)      │  │
│  │  - Background Email             │  │  - Long-running HTTP Requests   │  │
│  │  - Report Generation            │  │  - Webhook Handling             │  │
│  │  - Scheduled Tasks (Celery Beat)│  │  - Real-time Notifications      │  │
│  └─────────────────────────────────┘  └──────────────────────────────────┘  │
│                                                                              │
└────────────────────────────────────────────────────────────────────────────────┘
```

### TaskFlow Application Features

Throughout this series, TaskFlow will include:

1. **User Management**
   - Registration, login, and password reset with email confirmation
   - User profiles with avatar upload
   - Role-based permissions (Admin, Project Manager, Team Member)
   - JWT-based authentication for API access

2. **Project Management**
   - Create and manage projects with team assignments
   - Project timelines and status tracking
   - Activity logging and audit trails
   - Real-time updates via WebSocket (optional, Part 5)

3. **Task Management**
   - Create, assign, and track tasks
   - Hierarchical task structures (subtasks)
   - Due dates, priorities, and labels
   - Task comments and attachments

4. **Collaboration Features**
   - Real-time notifications (using async tasks)
   - Team dashboards and activity feeds
   - Comment threads on tasks and projects
   - User presence indicators

5. **React Frontend Features**
   - Responsive, modern UI with React 19 and Tailwind CSS
   - State management with React Context and Redux Toolkit
   - Protected routes and authentication flows
   - Optimistic updates for better UX
   - Form validation with React Hook Form
   - Real-time updates via WebSocket/Socket.IO

6. **API Access**
   - Full REST API for React frontend and mobile apps
   - API documentation with OpenAPI/Swagger
   - API versioning and rate limiting
   - JWT authentication

7. **Administration**
   - Django Admin for superuser management
   - Custom admin interfaces for moderators
   - System monitoring and health checks

### Technology Stack

Here's the complete stack we'll use, organized by layer:

| Layer | Technology | Purpose |
|-------|------------|---------|
| **Backend Language** | Python 3.14 | Core programming language |
| **Backend Framework** | Django 6 | Web framework |
| **Database** | PostgreSQL 16 | Production database (with full-text search) |
| **Cache/Queue** | Redis 7 | Caching, session storage, Celery broker |
| **Task Queue** | Celery 5 | Background task processing |
| **API Framework** | Django REST Framework 3.15 | RESTful API development |
| **API Documentation** | drf-spectacular + OpenAPI 3 | API docs and schema |
| **Authentication** | Django JWT (Simple JWT) | API authentication |
| **Frontend Language** | TypeScript 5 | Typed JavaScript |
| **Frontend Framework** | React 19 | UI Library |
| **State Management** | Redux Toolkit 2 | Global state management |
| **API Client** | Axios 1 | HTTP requests |
| **Routing** | React Router 7 | Client-side routing |
| **Styling** | Tailwind CSS 4 | Utility-first CSS |
| **Frontend Tooling** | Vite 6 | Build tool and dev server |
| **Testing** | pytest 9 + Coverage | Backend testing |
| **Frontend Testing** | Vitest + React Testing Library | Frontend testing |
| **Deployment** | Docker, Gunicorn, Nginx | Containerization and production serving |
| **CI/CD** | GitHub Actions | Automated testing and deployment |
| **Monitoring** | Sentry + Django Debug Toolbar | Error tracking and performance |
| **Real-time** | Django Channels + WebSockets | Real-time updates (Optional) |

## Target Audience and Prerequisites

### Who This Series Is For

This series is designed for **developers who are new to Django but comfortable with Python**. If you fit any of these profiles, you're in the right place:

- **Python developers** who want to learn web development with Django
- **Full-stack developers** transitioning from other frameworks (Flask, Express, Rails, etc.)
- **Frontend developers** who want to add backend skills with Django
- **Students and bootcamp graduates** looking to build production-grade applications
- **Self-taught programmers** who want to learn industry best practices
- **Experienced Django developers** who want to update their skills to Django 6 and React

### What You Should Know Before Starting

While we explain everything with care, you'll get the most out of this series if you have:

**Backend Prerequisites:**
- **Basic Python knowledge**: Variables, functions, classes, modules, list comprehensions, and decorators at a fundamental level
- **Command line comfort**: Using terminal/command prompt, navigating directories, running commands
- **Version control basics**: Installing Git and running basic commands (clone, commit, push) - we'll use GitHub

**Frontend Prerequisites:**
- **Basic JavaScript/TypeScript**: Variables, functions, arrays, objects, and ES6 syntax
- **Basic React concepts**: Components, props, state, and hooks (we'll review these)
- **HTML/CSS fundamentals**: Understanding basic HTML structure and CSS classes (we use Tailwind CSS)

**Don't worry if you're rusty or missing some prerequisites!** We'll review concepts as we need them, and I'll provide resources for catching up. The React portion starts in Part 4, giving you time to prepare.

### What You'll Learn

By the end of this series, you'll be able to:

1. **Build complete Django applications** from scratch with proper architecture
2. **Design database schemas** using Django's ORM with advanced features
3. **Implement secure authentication** and role-based authorization
4. **Create REST APIs** with Django REST Framework
5. **Build modern React frontends** with TypeScript and Tailwind CSS
6. **Connect React and Django** effectively for full-stack development
7. **Handle asynchronous processing** with background tasks and async views
8. **Write comprehensive tests** for all application components
9. **Optimize performance** using caching, query optimization, and profiling
10. **Secure applications** following OWASP best practices
11. **Deploy applications** to production using Docker and cloud infrastructure

## Series Structure and Learning Path

### How the Series Is Organized

The series follows a **project-based, incremental approach**. We'll build TaskFlow step by step across six parts, with each part building on the previous one:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           SERIES PROGRESSION                               │
│                                                                             │
│  Part 1                Part 2                Part 3                         │
│  Foundations           Advanced ORM          Auth & Security               │
│  ┌───────────────┐    ┌───────────────┐    ┌───────────────┐              │
│  │ Project Setup  │ -> │ Models Design │ -> │ User Auth     │              │
│  │ Dev Environment│    │ Relationships │    │ Permissions   │              │
│  │ Basic Models   │    │ Optimizations │    │ Forms & Vars  │              │
│  └───────────────┘    └───────────────┘    └───────────────┘              │
│         │                     │                     │                      │
│         ▼                     ▼                     ▼                      │
│  ┌──────────────────────────────────────────────────────────────┐         │
│  │                 CORE APPLICATION FOUNDATION                  │         │
│  └──────────────────────────────────────────────────────────────┘         │
│                                                                             │
│  Part 4                Part 5                Part 6                         │
│  REST APIs & React     Frontend Advanced     Production                     │
│  ┌───────────────┐    ┌───────────────┐    ┌───────────────┐              │
│  │ DRF API Setup  │ -> │ State Mgmt    │ -> │ Testing       │              │
│  │ React Setup    │    │ Async/WebSockets│  │ Security      │              │
│  │ API Integration│    │ Performance   │    │ Docker/CICD   │              │
│  └───────────────┘    └───────────────┘    └───────────────┘              │
│         │                     │                     │                      │
│         ▼                     ▼                     ▼                      │
│  ┌──────────────────────────────────────────────────────────────┐         │
│  │             COMPLETE PRODUCTION APPLICATION                  │         │
│  └──────────────────────────────────────────────────────────────┘         │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Part-by-Part Breakdown

**Part 1: Foundations and Project Architecture**
> We set up our development environment, create the Django project, understand Django's architecture, and build the foundation for TaskFlow. We'll configure settings, create initial models for users and projects, set up the admin interface, and get our development server running.

**Part 2: Advanced ORM and Database Design**
> We dive deep into Django's ORM to design sophisticated database schemas. We'll create the complete data model for TaskFlow including projects, tasks, comments, attachments, and team relationships. We'll learn about optimization, indexing, custom managers, and zero-downtime migrations.

**Part 3: Forms, Authentication, and Authorization**
> We implement secure authentication with a custom user model, registration, login, password reset, and email confirmation. We'll build user profiles and implement role-based permissions and object-level authorization for projects and tasks. We'll also set up JWT authentication for API access.

**Part 4: Building Modern APIs and React Frontend**
> We transform our application into a robust backend by building RESTful APIs with Django REST Framework. We'll create serializers, ViewSets, and routers. Then we'll set up a React 19 + TypeScript frontend using Vite, connect it to our API, and implement user authentication flows.

**Part 5: Advanced Frontend and Asynchronous Processing**
> We build the complete React frontend with Redux Toolkit for state management, React Router for navigation, and Tailwind CSS for styling. We implement background task processing with Celery, email delivery, caching, and real-time notifications with WebSockets.

**Part 6: Testing, Security, and Production Deployment**
> We harden our application with comprehensive testing (both Django and React), implement security best practices, containerize with Docker, set up CI/CD pipelines, and deploy to production with Gunicorn, Nginx, and PostgreSQL.

### What Makes This Series Different

1. **Complete, Working Code**: Every code block is complete and tested. No "implementation omitted" or "// your code here."

2. **Clear Progression**: Each step builds on the previous one. We never introduce something without explaining why.

3. **Production Focus**: We don't just build "toy" apps. Everything we do is aimed at creating software ready for real users.

4. **Verification Steps**: Every section includes specific ways to verify your work, reducing frustration and debugging time.

5. **Security Mindset**: Security isn't an afterthought—we integrate it throughout the development process.

6. **Modern Stack**: We use the latest stable versions of all tools and follow current best practices.

7. **Full-Stack Approach**: Unlike many Django tutorials that focus only on backend, we build a complete React SPA with TypeScript.

## Setting Up Your Development Environment

Before we start Part 1, let's ensure you have everything ready. I'll guide you through setting up your development environment now so you can code along without interruptions.

### System Requirements

**Operating Systems**: This series works on:
- macOS (10.15+)
- Windows (10/11) with WSL2 (recommended) or PowerShell
- Linux (Ubuntu 20.04+, Debian, Fedora)

**Hardware Recommendations**:
- 8GB RAM minimum (16GB recommended)
- 10GB free disk space
- Stable internet connection for downloading packages

### Required Software

| Software | Version | Purpose | Installation Link |
|----------|---------|---------|-------------------|
| Python | 3.14 | Backend programming language | [python.org](https://python.org) |
| Node.js | 20+ | Frontend runtime | [nodejs.org](https://nodejs.org) |
| npm/yarn | Latest | Frontend package manager | Comes with Node |
| pip | Latest | Package installer | Comes with Python |
| Git | 2.40+ | Version control | [git-scm.com](https://git-scm.com) |
| PostgreSQL | 16 | Production database | [postgresql.org](https://postgresql.org) |
| Redis | 7 | Cache and queue | [redis.io](https://redis.io) |
| Docker | 24+ | Containerization | [docker.com](https://docker.com) |
| VS Code/IDE | Latest | Code editor | [code.visualstudio.com](https://code.visualstudio.com) |
| uv | Latest | Python package/venv manager | [docs.astral.sh/uv](https://docs.astral.sh/uv) |

**Important**: If you prefer not to install all these tools immediately, we'll use Docker for the complete stack starting in Part 2. For Part 1, you'll just need Python, Node.js, and a basic IDE.

### Installation Quick Guide

#### macOS (using Homebrew)

```bash
# Install Homebrew if you don't have it
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install Python 3.14
brew install python@3.14

# Install Node.js 20
brew install node@20

# Install uv (modern Python package manager)
curl -LsSf https://astral.sh/uv/install.sh | sh

# Install PostgreSQL
brew install postgresql@16
brew services start postgresql@16

# Install Redis
brew install redis
brew services start redis

# Install Git
brew install git

# Install Docker Desktop (from website) or via brew
brew install --cask docker
```

#### Windows (using WSL2)

**Option 1: Use WSL2 (Recommended)**

```bash
# In PowerShell (as Administrator)
wsl --install -d Ubuntu

# Then in Ubuntu WSL terminal:
sudo apt update
sudo apt install python3.14 python3-pip git postgresql redis-server

# Install Node.js 20
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs
```

**Option 2: Native Windows**

Download Python, Node.js, PostgreSQL, Redis, and Git from their official websites. Consider using chocolatey:

```powershell
# In PowerShell (as Administrator)
choco install python git postgresql redis docker-desktop nodejs
```

#### Linux (Ubuntu/Debian)

```bash
# Update package list
sudo apt update

# Install Python 3.14 (may require a PPA)
sudo add-apt-repository ppa:deadsnakes/ppa
sudo apt update
sudo apt install python3.14 python3-pip git postgresql redis-server

# Install Node.js 20
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs

# Install uv
curl -LsSf https://astral.sh/uv/install.sh | sh
```

### Verifying Your Installation

Run these commands to confirm everything is working:

```bash
# Check Python
python3.14 --version
# Should output: Python 3.14.x

# Check pip
python3.14 -m pip --version
# Should show pip version

# Check uv
uv --version
# Should show uv version

# Check Node.js
node --version
# Should show: v20.x.x

# Check npm
npm --version
# Should show npm version

# Check Git
git --version
# Should show Git version

# Check PostgreSQL (should be running)
pg_isready
# Should show: /var/run/postgresql:5432 - accepting connections

# Check Redis (should be running)
redis-cli ping
# Should show: PONG
```

### Setting Up Your IDE

**VS Code Extensions** (Recommended):

**Backend Extensions:**
- Python (Microsoft) - Django support
- Django (Baptiste Darthenay)
- Prettier (code formatting)
- Docker (Microsoft)
- Remote - Containers (for Docker development)
- GitLens (Git integration)

**Frontend Extensions:**
- Tailwind CSS IntelliSense
- ES7+ React/Redux snippets
- TypeScript and JavaScript Language Features
- React Developer Tools (browser extension also needed)
- Prettier - Code formatter
- ESLint

**PyCharm Professional** (Alternative):
- Has excellent Django support built-in
- Professional version required for Django features
- Community edition works but with limited Django support

### Creating Your First Virtual Environment

We'll use `uv` as our Python package and virtual environment manager. It's faster and more modern than traditional `pip` and `venv`:

```bash
# Create a new directory for our project
mkdir taskflow
cd taskflow

# Initialize a new Python project with uv
uv init
# This creates pyproject.toml and README.md

# Create a virtual environment
uv venv
# This creates a .venv directory

# Activate the environment
# On macOS/Linux:
source .venv/bin/activate
# On Windows:
.venv\Scripts\activate

# Install Django 6
uv add django==6.0

# Verify Django installation
python -m django --version
# Should show: 6.0.x
```

### Troubleshooting Common Issues

**Problem**: "Command not found" for Python 3.14
- **Solution**: Try `python3` instead. On some systems, Python 3.14 is aliased to `python3`. Check with `python3 --version`.

**Problem**: PostgreSQL service not starting
- **macOS**: `brew services restart postgresql@16`
- **Linux**: `sudo systemctl restart postgresql`
- **Windows**: Check Services (services.msc) and start PostgreSQL

**Problem**: "uv: command not found"
- **Solution**: Run `curl -LsSf https://astral.sh/uv/install.sh | sh` and restart your terminal.

**Problem**: Permission denied when installing packages
- **Solution**: Never use `sudo` with Python package installations. Use a virtual environment instead. If you're outside a venv, create one first.

**Problem**: Node.js version issues
- **Solution**: Use `nvm` (Node Version Manager) for managing Node versions:
  ```bash
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
  nvm install 20
  nvm use 20
  ```

## Code and Resource Access

### How to Follow Along

Each part of this series includes complete, tested code that you can copy and paste. However, I strongly recommend **typing the code yourself**—this builds muscle memory and helps you understand the syntax more deeply.

When you encounter code blocks like this:

```python
# taskflow/settings.py
# At the top of the file
import os
from pathlib import Path

# Build paths inside the project like this: BASE_DIR / 'subdir'.
BASE_DIR = Path(__file__).resolve().parent.parent
```

The comment at the top (`# taskflow/settings.py`) indicates the file path relative to the project root. The code block contains the complete, exact contents for that file at that step.

For frontend code, the file paths will be relative to the frontend directory:

```typescript
// frontend/src/App.tsx
import React from 'react';

function App() {
    return <h1>TaskFlow</h1>;
}

export default App;
```

### Project Repository

The complete project will be available in a GitHub repository:

**Repository**: `https://github.com/yourusername/taskflow`

**Note**: The repository will be populated incrementally, with branches for each part. If you get stuck, you can check the repository for the completed code at each phase.

**Recommended Workflow**:
1. Create your own GitHub repository for TaskFlow
2. Commit your code at the end of each major section
3. Use git tags or branches to mark milestones
4. This way, you can always return to a known working state

### Getting Help

If you get stuck, you have several options:

1. **Check the Verification Steps** - Each section includes explicit tests
2. **Read the Comments** - Code comments explain tricky parts
3. **Search for Error Messages** - Copy the error message into your browser
4. **Check the Repository** - Compare your code with the reference implementation
5. **Use the Django Documentation** - [docs.djangoproject.com](https://docs.djangoproject.com)
6. **Use the React Documentation** - [react.dev](https://react.dev)

## Series Expectations

### Time Investment

This series is comprehensive—it will take time to work through. Here's a realistic estimate:

| Part | Estimated Time |
|------|---------------|
| Part 1: Foundations | 5-7 hours |
| Part 2: Advanced ORM | 5-8 hours |
| Part 3: Auth & Security | 5-7 hours |
| Part 4: REST APIs & React | 8-12 hours |
| Part 5: Frontend Advanced | 7-10 hours |
| Part 6: Production | 6-9 hours |
| **Total** | **36-53 hours** |

**Remember**: This is a learning journey, not a race. Take breaks, experiment with the code, and enjoy the process.

### Pacing Strategy

- **New to Django and React**: Plan to spend 3-4 hours per day, 3-5 days per part
- **Some Django experience**: 2-3 hours per day, complete a part per week
- **Experienced developer**: You might finish parts in a few hours each, focusing on what's new
- **Frontend focus**: If you're more interested in React, you can spend extra time on Parts 4-5

### What to Skip (And What Not to Skip)

- **Don't skip**: Security sections, testing, deployment, and database design—these are what make production-ready applications
- **Can skim**: Deep API breakdowns if you're familiar with the concept
- **Must do**: Every code implementation, even if it seems repetitive—this builds practical skill
- **React parts**: If you're a backend developer, consider doing the React parts anyway—understanding the frontend makes you a better full-stack developer

## Series Conventions

### Typography Conventions

Throughout the series, I'll use these conventions:

- **File paths**: `taskflow/settings.py` (monospace for file names)
- **Commands**: `python manage.py runserver` (preceded by `$` for terminal)
- **Code**: Syntax-highlighted blocks with file comments
- **Important concepts**: **Bold text** for key terms
- **URLs**: `http://localhost:8000` (monospace for URLs)
- **Keyboard shortcuts**: **Ctrl+C** (bold for key combinations)

### Code Style

We'll follow Django, Python, and React best practices:

**Backend:**
- **PEP 8** for Python code style
- **4 spaces** for indentation (no tabs)
- **Descriptive variable names**
- **Docstrings** for public functions and classes
- **Type hints** where beneficial for readability

**Frontend:**
- **ESLint** with recommended React rules
- **Prettier** for consistent formatting
- **TypeScript** strict mode enabled
- **Functional components** with hooks
- **2 spaces** for indentation

### Terminology Clarifications

Let me define some key terms you'll encounter frequently:

**Backend Terms:**
- **Project**: The top-level Django container (`django-admin startproject taskflow`)
- **App**: A modular component within the project (`python manage.py startapp tasks`)
- **Model**: A Python class that represents a database table
- **View**: A function or class that handles HTTP requests and returns responses
- **Migration**: A file that describes changes to the database schema
- **Middleware**: Code that runs before and after view processing (e.g., authentication)
- **ORM**: Object-Relational Mapper—Django's way of working with databases using Python
- **Serializers**: DRF classes that convert Django models to/from JSON
- **ViewSets**: DRF classes that group related views

**Frontend Terms:**
- **Component**: A reusable React function that returns UI
- **Props**: Data passed from parent to child components
- **State**: Data that changes over time within a component
- **Hooks**: React functions that let you use state and lifecycle features (useState, useEffect)
- **Context**: React's way of sharing data across components without props
- **Redux**: A state management library for complex applications
- **SPA**: Single Page Application—a web app that loads a single HTML page
- **Vite**: Modern build tool for frontend development

## Tools We'll Use

### Django 6 New Features

Django 6 introduces several exciting features we'll leverage:

| Feature | Description | When We'll Use It |
|---------|-------------|-------------------|
| **Generated Fields** | Database columns computed at read time | Part 2 (computed project metrics) |
| **Composite Primary Keys** | Multi-column primary keys | Part 2 (complex relationships) |
| **Pre-fetching Improvements** | Better `prefetch_related` performance | Part 2, Part 5 |
| **Async Views** | Native async support in views | Part 5 (long-running operations) |
| **Enhanced Mailer Framework** | `MAILERS` configuration | Part 5 (email notifications) |
| **New Field Fetch Modes** | `FETCH_ONE`, `FETCH_PEERS`, `FETCH_RAISE` | Part 2 (optimization) |
| **DB-Level CASCADE** | More deletion strategies | Part 2 (data integrity) |

### Additional Libraries

We'll also use these essential libraries:

**Backend:**
| Library | Purpose | Introduced In |
|---------|---------|---------------|
| `django-environ` | Environment variable management | Part 1 |
| `psycopg2` | PostgreSQL adapter | Part 1 |
| `django-cors-headers` | CORS for API | Part 4 |
| `djangorestframework` | REST APIs | Part 4 |
| `djangorestframework-simplejwt` | JWT authentication | Part 4 |
| `drf-spectacular` | OpenAPI/Swagger docs | Part 4 |
| `django-celery-beat` | Scheduled tasks | Part 5 |
| `channels` | WebSocket support | Part 5 (optional) |
| `pytest-django` | Testing framework | Part 6 |

**Frontend:**
| Library | Purpose | Introduced In |
|---------|---------|---------------|
| `react` | UI Library | Part 4 |
| `react-dom` | React rendering | Part 4 |
| `typescript` | Type checking | Part 4 |
| `vite` | Build tool | Part 4 |
| `react-router-dom` | Routing | Part 4 |
| `axios` | HTTP client | Part 4 |
| `@reduxjs/toolkit` | State management | Part 5 |
| `react-redux` | React bindings for Redux | Part 5 |
| `@tailwindcss/vite` | Tailwind integration | Part 4 |
| `tailwindcss` | CSS framework | Part 4 |
| `react-hook-form` | Form validation | Part 5 |
| `zod` | Schema validation | Part 5 |

## Final Words Before We Begin

You're about to embark on an exciting journey building modern web applications with Django 6 and React. This series will push you, challenge you, and ultimately make you a more confident and capable full-stack developer.

**Remember**: Every expert was once a beginner. The code you're learning today is the foundation of tomorrow's expertise. Don't be afraid to make mistakes, ask questions, and experiment.

**A Personal Note**: I designed this series to be the tutorial I wish I had when I was learning Django and React together. It's comprehensive, practical, and focused on building real applications. Take your time, enjoy the process, and don't forget to celebrate each milestone—from your first "Hello World" to your first successful deployment.

### Next Steps

When you're ready, proceed to **Part 1: Foundations and Project Architecture**. We'll begin by setting up our TaskFlow project, creating our first models, and getting everything running.

**Before moving on**, take a moment to:
1. ✅ Ensure Python 3.14 is installed (`python --version`)
2. ✅ Ensure Node.js 20+ is installed (`node --version`)
3. ✅ Install uv (`uv --version`)
4. ✅ Create a directory for TaskFlow
5. ✅ Set up a GitHub account (if you don't have one)
6. ✅ Install and configure your IDE with recommended extensions


---

[GENERATED: Part 0: Introduction (
