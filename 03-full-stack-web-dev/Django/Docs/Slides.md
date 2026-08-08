# Mastering Django 6: Full-Stack Web Development
## Comprehensive Slide Deck Outline — Extended Edition

---

# PART 0: INTRODUCTION — YOUR JOURNEY FROM ZERO TO PRODUCTION-READY DJANGO

---

## Slide 0.1: Title Slide

**Mastering Django 6: Full-Stack Web Development**

*From Zero to Production-Ready in 10 Parts*

**Subtitle:** Build a Complete Blog Publishing Platform

**Presented by:** [Your Name/Organization]

**Date:** [Presentation Date]

**Django Version:** 6.0 | **Python Version:** 3.14+

---

## Slide 0.2: What is Django?

**The "Batteries-Included" Framework**

```
┌─────────────────────────────────────────────────────────────┐
│                       DJANGO                                │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  "The web framework for perfectionists with         │   │
│  │   deadlines."                                       │   │
│  │                                                     │   │
│  │  - High-level Python web framework                  │   │
│  │  - Encourages rapid development                     │   │
│  │  - Clean, pragmatic design                          │   │
│  │  - "Batteries-included" philosophy                  │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Who Uses Django?                                          │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Instagram  │  Pinterest  │  The Washington Post   │   │
│  │  Spotify   │  Dropbox   │  Mozilla                │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

**Why Django?**

- **Secure:** Protection against XSS, CSRF, SQL injection, clickjacking
- **Scalable:** Powers some of the world's largest sites
- **Versatile:** From content management to APIs to data science dashboards
- **Well-documented:** Comprehensive, accessible, and always up-to-date
- **Community-driven:** Active development, extensive third-party packages

---

## Slide 0.3: Course Philosophy

**Keep It Simple. Build Real Things.**

```
┌─────────────────────────────────────────────────────────────┐
│                   OUR PHILOSOPHY                            │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                                                     │   │
│  │   "We reject unnecessary complexity."               │   │
│  │                                                     │   │
│  │   ❌ No separate frontend framework required         │   │
│  │   ❌ No separate API layer required                  │   │
│  │   ❌ No complex build pipeline required              │   │
│  │   ❌ No state management libraries required          │   │
│  │                                                     │   │
│  │   ✅ Django does it all.                            │   │
│  │   ✅ One framework, deeply understood.              │   │
│  │   ✅ One application, continuously evolved.          │   │
│  │                                                     │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  The BUILD → UNDERSTAND → REFACTOR → TEST → DEPLOY Cycle   │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Build First   →   See results immediately          │   │
│  │  Understand    →   Break down working code          │   │
│  │  Refactor      →   Improve with better practices    │   │
│  │  Test          →   Prove it works correctly         │   │
│  │  Deploy        →   Put it in front of real users    │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 0.4: The Simple Stack — Architecture Overview

**Traditional Server-Rendered Monolith — Production**

```
┌─────────────────────────────────────────────────────────────┐
│                         USER                                │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                       BROWSER                               │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Renders HTML, CSS, JavaScript                      │   │
│  │  Sends HTTP requests                               │   │
│  └─────────────────────────────────────────────────────┘   │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                      NGINX (Production)                     │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  HTTPS Termination                                 │   │
│  │  Static File Serving (CSS, JS, Images)             │   │
│  │  Reverse Proxy to Gunicorn                         │   │
│  └─────────────────────────────────────────────────────┘   │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                    GUNICORN (Production)                    │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  WSGI HTTP Server                                  │   │
│  │  Multi-worker Processing                           │   │
│  │  Concurrent Request Handling                       │   │
│  └─────────────────────────────────────────────────────┘   │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                    DJANGO APPLICATION                       │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Middleware Stack (Security, Session, Auth, CSRF)  │   │
│  │  URL Dispatcher → Views → Business Logic           │   │
│  │  Django ORM → Template Engine → Response           │   │
│  └─────────────────────────────────────────────────────┘   │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                       DATABASE                              │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  PostgreSQL (Production)   │   SQLite (Development) │   │
│  │  ┌─────────────────────────┐│  ┌─────────────────┐ │   │
│  │  │  All Application Data   ││  │  File-based DB  │ │   │
│  │  │  ACID Compliance        ││  │  Fast Dev       │ │   │
│  │  │  Full-Text Search       ││  └─────────────────┘ │   │
│  │  └─────────────────────────┘│                     │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

**Development Architecture:** Browser → Django Development Server → SQLite → Browser (Simpler!)

---

## Slide 0.5: Who This Series Is For

**Prerequisites — What You Need to Know**

```
┌─────────────────────────────────────────────────────────────┐
│                    PREREQUISITES                            │
│                                                             │
│  ✅ Basic Python Knowledge                                 │
│     ┌─────────────────────────────────────────────────┐   │
│     │  Variables, functions, classes, lists, dicts   │   │
│     │  Written a few small Python scripts             │   │
│     └─────────────────────────────────────────────────┘   │
│                                                             │
│  ✅ Command-Line Comfort                                   │
│     ┌─────────────────────────────────────────────────┐   │
│     │  Navigate directories, run commands, edit files │   │
│     └─────────────────────────────────────────────────┘   │
│                                                             │
│  ✅ Basic HTML/CSS                                         │
│     ┌─────────────────────────────────────────────────┐   │
│     │  Tags, attributes, selectors, simple layouts    │   │
│     └─────────────────────────────────────────────────┘   │
│                                                             │
│  ✅ Eagerness to Learn                                      │
│     ┌─────────────────────────────────────────────────┐   │
│     │  Ready to build something real and get hands-on │   │
│     └─────────────────────────────────────────────────┘   │
│                                                             │
│  ❌ You DON'T Need:                                        │
│     ┌─────────────────────────────────────────────────┐   │
│     │  Any previous Django experience                 │   │
│     │  JavaScript frameworks                          │   │
│     │  Database experience                            │   │
│     │  DevOps experience                              │   │
│     │  A computer science degree                     │   │
│     └─────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 0.6: The 10-Part Roadmap

**Your Journey Through the Series**

```
┌─────────────────────────────────────────────────────────────┐
│                  10-PART ROADMAP                            │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Part 1: Django Fundamentals                       │   │
│  │  → Static pages with navigation, MVT architecture   │   │
│  └─────────────────────────────────────────────────────┘   │
│                           ▼                                 │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Part 2: Models & Database                         │   │
│  │  → Database-backed content with Django Admin       │   │
│  └─────────────────────────────────────────────────────┘   │
│                           ▼                                 │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Part 3: Forms & CRUD                              │   │
│  │  → Create, edit, delete blog posts via web forms   │   │
│  └─────────────────────────────────────────────────────┘   │
│                           ▼                                 │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Part 4: Advanced Views                            │   │
│  │  → Class-Based Views, search, filtering, pagination │   │
│  └─────────────────────────────────────────────────────┘   │
│                           ▼                                 │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Part 5: Authentication & Security                 │   │
│  │  → User accounts, profiles, permissions, security   │   │
│  └─────────────────────────────────────────────────────┘   │
│                           ▼                                 │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Part 6: Advanced Architecture                     │   │
│  │  → Middleware, signals, context processors          │   │
│  └─────────────────────────────────────────────────────┘   │
│                           ▼                                 │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Part 7: Real-World Features                       │   │
│  │  → Images, email, sessions, transactions            │   │
│  └─────────────────────────────────────────────────────┘   │
│                           ▼                                 │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Part 8: Testing & Quality                         │   │
│  │  → Comprehensive test suite, logging, debugging     │   │
│  └─────────────────────────────────────────────────────┘   │
│                           ▼                                 │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Part 9: Production Readiness                       │   │
│  │  → Performance, caching, security hardening         │   │
│  └─────────────────────────────────────────────────────┘   │
│                           ▼                                 │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Part 10: Deployment                               │   │
│  │  → Docker, Gunicorn, Nginx, CI/CD, production       │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 0.7: The Final Project — Mockup

**What You'll Build by the End of Part 10**

```
┌─────────────────────────────────────────────────────────────┐
│  ┌───────────────────────────────────────────────────────┐ │
│  │  Django Blog            [Home] [Blog] [About] [Login] │ │
│  └───────────────────────────────────────────────────────┘ │
│  ┌───────────────────────────────────────────────────────┐ │
│  │                                                     │ │
│  │  📰 Welcome to Django Blog                          │ │
│  │  Learn Django by building a real application.       │ │
│  │                                                     │ │
│  │  ┌─────────────────────┐  ┌─────────────────────┐ │ │
│  │  │  Recent Posts       │  │  Categories         │ │ │
│  │  │  ┌─────────────────┐│  │  ┌─────────────────┐│ │ │
│  │  │  │  Post Title 1   ││  │  │  Technology (3) ││ │ │
│  │  │  │  By John Doe    ││  │  │  Python (2)     ││ │ │
│  │  │  │  Mar 15, 2026   ││  │  │  Django (4)     ││ │ │
│  │  │  └─────────────────┘│  │  └─────────────────┘│ │ │
│  │  │  ┌─────────────────┐│  └─────────────────────┘ │ │
│  │  │  │  Post Title 2   ││                           │ │
│  │  │  │  By Jane Smith  ││  ┌─────────────────────┐ │ │
│  │  │  │  Mar 14, 2026   ││  │  About              │ │ │
│  │  │  └─────────────────┘│  │  Built with Django 6│ │ │
│  │  └─────────────────────┘  └─────────────────────┘ │ │
│  │                                                     │ │
│  └───────────────────────────────────────────────────────┘ │
│  ┌───────────────────────────────────────────────────────┐ │
│  │  © 2026 Django Blog. Built with ❤️ using Django 6.  │ │
│  └───────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘

Features:
┌─────────────────────────────────────────────────────────────┐
│  ✅ Database-backed content    ✅ User authentication       │
│  ✅ CRUD operations            ✅ Search & filtering        │
│  ✅ File uploads               ✅ Email notifications       │
│  ✅ Comments                   ✅ User profiles             │
│  ✅ Pagination                 ✅ Caching                   │
│  ✅ Docker deployment          ✅ CI/CD pipeline            │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 0.8: Setup Instructions

**Preparing Your Development Environment**

```
┌─────────────────────────────────────────────────────────────┐
│                SETUP INSTRUCTIONS                           │
│                                                             │
│  Step 1: Install Python 3.14+                              │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Windows: python.org/downloads (check "Add to PATH")│   │
│  │  macOS:   brew install python@3.14                  │   │
│  │  Linux:   sudo apt install python3.14               │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Step 2: Choose Your Code Editor                            │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  VS Code (Recommended)  │  PyCharm  │  Sublime Text │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Step 3: Install Git                                        │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Windows: git-scm.com                              │   │
│  │  macOS:   brew install git                         │   │
│  │  Linux:   sudo apt install git                     │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Step 4: Create Project Folder                              │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  mkdir ~/DjangoProjects                             │   │
│  │  cd ~/DjangoProjects                                │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Step 5: Install uv (Fast Python Package Manager)          │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  curl -LsSf https://astral.sh/uv/install.sh | sh   │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 0.9: The Request/Response Cycle — Mental Model

**Understanding How Django Works**

```
┌─────────────────────────────────────────────────────────────┐
│           DJANGO REQUEST/RESPONSE CYCLE                     │
│                                                             │
│  1. User requests /blog/ in their browser                  │
│     ┌─────────────────────────────────────────────────────┐│
│     │  GET /blog/ HTTP/1.1                               ││
│     │  Host: localhost:8000                              ││
│     │  User-Agent: Mozilla/5.0 ...                      ││
│     └─────────────────────────────────────────────────────┘│
│                           ▼                                 │
│  2. Django's URL dispatcher finds the view for '/blog/'    │
│     ┌─────────────────────────────────────────────────────┐│
│     │  path('blog/', views.blog_list, name='blog_list')  ││
│     └─────────────────────────────────────────────────────┘│
│                           ▼                                 │
│  3. Django runs the view function                          │
│     ┌─────────────────────────────────────────────────────┐│
│     │  def blog_list(request):                           ││
│     │      posts = Post.objects.filter(status='published')││
│     │      return render(request, 'blog/list.html', ...) ││
│     └─────────────────────────────────────────────────────┘│
│                           ▼                                 │
│  4. The view queries the database for blog posts           │
│     ┌─────────────────────────────────────────────────────┐│
│     │  SELECT * FROM blog_post WHERE status = 'published'││
│     └─────────────────────────────────────────────────────┘│
│                           ▼                                 │
│  5. The view renders a template with the post data         │
│     ┌─────────────────────────────────────────────────────┐│
│     │  <h1>{{ post.title }}</h1>                         ││
│     │  <p>{{ post.content }}</p>                         ││
│     └─────────────────────────────────────────────────────┘│
│                           ▼                                 │
│  6. Django sends the HTML back to the browser              │
│     ┌─────────────────────────────────────────────────────┐│
│     │  HTTP/1.1 200 OK                                   ││
│     │  Content-Type: text/html                           ││
│     │  <!DOCTYPE html><html>...                         ││
│     └─────────────────────────────────────────────────────┘│
│                           ▼                                 │
│  7. Browser displays the rendered page                     │
│     ┌─────────────────────────────────────────────────────┐│
│     │  ┌───────────────────────────────────────────────┐ ││
│     │  │  Blog Posts                                  │ ││
│     │  │  ┌─────────────────────────────────────────┐ │ ││
│     │  │  │  Post Title 1                          │ │ ││
│     │  │  │  Content...                            │ │ ││
│     │  │  └─────────────────────────────────────────┘ │ ││
│     │  └───────────────────────────────────────────────┘ ││
│     └─────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 0.10: Code Quality Standard

**What Production-Quality Django Code Looks Like**

```
┌─────────────────────────────────────────────────────────────┐
│                   CODE QUALITY STANDARD                    │
│                                                             │
│  ✅ Complete                                                │
│     ┌─────────────────────────────────────────────────┐   │
│     │  No placeholders like "# implement the rest"    │   │
│     │  Every code block is copy-pasteable             │   │
│     └─────────────────────────────────────────────────┘   │
│                                                             │
│  ✅ Clear Comments                                          │
│     ┌─────────────────────────────────────────────────┐   │
│     │  Inline explanations for complex sections       │   │
│     │  Docstrings for functions and classes           │   │
│     └─────────────────────────────────────────────────┘   │
│                                                             │
│  ✅ Proper Error Handling                                   │
│     ┌─────────────────────────────────────────────────┐   │
│     │  Graceful failures                              │   │
│     │  User-friendly error messages                  │   │
│     └─────────────────────────────────────────────────┘   │
│                                                             │
│  ✅ Security First                                          │
│     ┌─────────────────────────────────────────────────┐   │
│     │  Follows Django's security best practices       │   │
│     │  Protection against XSS, CSRF, SQL injection   │   │
│     └─────────────────────────────────────────────────┘   │
│                                                             │
│  ✅ Type Hints                                              │
│     ┌─────────────────────────────────────────────────┐   │
│     │  def get_user(id: int) -> Optional[User]:      │   │
│     └─────────────────────────────────────────────────┘   │
│                                                             │
│  ✅ Clean Naming                                           │
│     ┌─────────────────────────────────────────────────┐   │
│     │  Variables: user, post_list, is_authenticated  │   │
│     │  Functions: get_published_posts()              │   │
│     │  Classes: PostListView, UserProfileService     │   │
│     └─────────────────────────────────────────────────┘   │
│                                                             │
│  ✅ DRY (Don't Repeat Yourself)                             │
│     ┌─────────────────────────────────────────────────┐   │
│     │  Extract repeated logic into reusable functions │   │
│     │  Use inheritance and mixins                    │   │
│     └─────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 0.11: Recommended Learning Rhythm

**How to Get the Most Out of This Series**

```
┌─────────────────────────────────────────────────────────────┐
│              RECOMMENDED LEARNING RHYTHM                    │
│                                                             │
│  For Beginners:                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  📅 One part per week                               │   │
│  │  ✍️ Code along — type everything yourself           │   │
│  │  🔬 Experiment — break things to fix them          │   │
│  │  📝 Take notes on what you learn                   │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  For Intermediate Learners:                                 │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  📅 Two parts per week                              │   │
│  │  🎯 Focus on unfamiliar content                     │   │
│  │  🔧 Write extra tests beyond the series             │   │
│  │  🏗️ Add your own features                         │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  For Everyone:                                              │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  ⏰ 30 minutes daily > 5 hours once a week         │   │
│  │  💬 Ask questions — the community is helpful        │   │
│  │  📂 Use Git from the start                          │   │
│  │  🎉 Celebrate small wins!                          │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Git Workflow:                                              │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  git init                                           │   │
│  │  git add .                                         │   │
│  │  git commit -m "Completed Part X: Description"     │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 0.12: Troubleshooting When Stuck

**A Step-by-Step Guide to Overcoming Obstacles**

```
┌─────────────────────────────────────────────────────────────┐
│              TROUBLESHOOTING GUIDE                          │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  1. READ THE ERROR MESSAGE                          │   │
│  │     Django's error pages are detailed and helpful   │   │
│  │     Look for: File name, line number, error type   │   │
│  └─────────────────────────────────────────────────────┘   │
│                           ▼                                 │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  2. COMPARE YOUR CODE                               │   │
│  │     One small typo can cause big problems           │   │
│  │     Use diff tools to spot differences              │   │
│  └─────────────────────────────────────────────────────┘   │
│                           ▼                                 │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  3. CHECK VERIFICATION STEPS                        │   │
│  │     Ensure earlier steps worked correctly           │   │
│  │     Go back and re-run if needed                   │   │
│  └─────────────────────────────────────────────────────┘   │
│                           ▼                                 │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  4. USE GOOGLE                                      │   │
│  │     Search the exact error message                  │   │
│  │     Chances are someone else has encountered it     │   │
│  └─────────────────────────────────────────────────────┘   │
│                           ▼                                 │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  5. CONSULT DJANGO DOCS                             │   │
│  │     https://docs.djangoproject.com/                 │   │
│  │     Comprehensive, well-organized, always updated   │   │
│  └─────────────────────────────────────────────────────┘   │
│                           ▼                                 │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  6. ASK FOR HELP                                    │   │
│  │     Stack Overflow: django tag                     │   │
│  │     Reddit: r/django                               │   │
│  │     Django Discord                                 │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 0.13: Final Words Before We Begin

**Your Journey Starts Now**

```
┌─────────────────────────────────────────────────────────────┐
│              FINAL WORDS OF ENCOURAGEMENT                   │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                                                     │   │
│  │  Embrace the Learning Journey:                      │   │
│  │                                                     │   │
│  │  🔴 Errors are normal — they mean you're learning  │   │
│  │  🟡 Confusion is normal — understanding comes      │   │
│  │      with practice                                  │   │
│  │  🟢 Refactoring is growth — it means you're        │   │
│  │      improving                                      │   │
│  │                                                     │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                                                     │   │
│  │  Celebrate Small Wins:                              │   │
│  │                                                     │   │
│  │  🎉 Development server starts without errors       │   │
│  │  🎉 First post appears on the homepage              │   │
│  │  🎉 User registration works                        │   │
│  │  🎉 All tests pass                                 │   │
│  │  🎉 Application deploys successfully               │   │
│  │                                                     │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                                                     │   │
│  │  "The master has failed more times than the        │   │
│  │   beginner has even tried."                         │   │
│  │                                                     │   │
│  │  — Stephen McCranie                                │   │
│  │                                                     │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  🚀 LET'S BUILD SOMETHING AMAZING!                         │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 0.14: Ready? Let's Begin!

**Proceed to Part 1**

```
┌─────────────────────────────────────────────────────────────┐
│                  PART 1 PREVIEW                             │
│                                                             │
│  What We'll Build:                                          │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  A functional multi-page website with:              │   │
│  │  ✅ Homepage                                        │   │
│  │  ✅ About page                                      │   │
│  │  ✅ Blog listing page                               │   │
│  │  ✅ Shared navigation across all pages              │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  What We'll Learn:                                          │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  ✅ Python virtual environments                     │   │
│  │  ✅ Installing Django 6                             │   │
│  │  ✅ Creating projects and applications              │   │
│  │  ✅ Django's MVT architecture                       │   │
│  │  ✅ Function-based views                            │   │
│  │  ✅ Templates with inheritance                      │   │
│  │  ✅ URL configuration                               │   │
│  │  ✅ The request/response cycle                      │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                                                     │   │
│  │  Let's write some code! 🚀                        │   │
│  │                                                     │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

# PART 1: DJANGO FUNDAMENTALS, ENVIRONMENT SETUP, AND YOUR FIRST APPLICATION

---

## Slide 1.1: Part 1 Introduction

**Learning Objectives**

```
┌─────────────────────────────────────────────────────────────┐
│                    PART 1 OVERVIEW                          │
│                                                             │
│  🎯 Learning Objectives:                                    │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  ✅ Set up a professional Python development        │   │
│  │     environment                                      │   │
│  │  ✅ Install Django 6                                │   │
│  │  ✅ Create your first Django project                │   │
│  │  ✅ Understand the project structure                │   │
│  │  ✅ Build your first views and templates            │   │
│  │  ✅ Create a working website with navigation        │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  🏗️ What We'll Build:                                      │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  A functional multi-page website:                   │   │
│  │  • Homepage with welcome message                    │   │
│  │  • About page with technologies list                │   │
│  │  • Blog page with placeholder content               │   │
│  │  • Shared navigation and footer                     │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  📚 Key Concepts:                                          │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  • Virtual Environments (venv / uv)                │   │
│  │  • MVT Architecture (Model-View-Template)          │   │
│  │  • Project vs. App                                 │   │
│  │  • Template Inheritance                            │   │
│  │  • URL Routing                                     │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 1.2: Virtual Environments

**Why We Use Them and How to Set Them Up**

```
┌─────────────────────────────────────────────────────────────┐
│                  VIRTUAL ENVIRONMENTS                       │
│                                                             │
│  What is a Virtual Environment?                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  An isolated Python environment for each project    │   │
│  │  Each project has its own packages and versions     │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Why Use Virtual Environments?                              │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  ✅ Isolate project dependencies                    │   │
│  │  ✅ Avoid version conflicts                         │   │
│  │  ✅ Reproducible environments                       │   │
│  │  ✅ Clean uninstallation                            │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Visual Representation:                                     │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  ┌─────────────────────────────────────────────┐   │   │
│  │  │         Global Python Environment            │   │   │
│  │  │  ┌───────────────────────────────────────┐  │   │   │
│  │  │  │  Django 4.2  │  Flask 2.3  │  ...   │  │   │   │
│  │  │  └───────────────────────────────────────┘  │   │   │
│  │  └─────────────────────────────────────────────┘   │   │
│  │           │                    ▲                     │   │
│  │           │                    │                     │   │
│  │  ┌────────▼────────┐  ┌────────┴────────┐         │   │
│  │  │   Project A     │  │   Project B     │         │   │
│  │  │   .venv/        │  │   .venv/        │         │   │
│  │  │  ┌───────────┐  │  │  ┌───────────┐  │         │   │
│  │  │  │ Django 6.0│  │  │  │ Django 5.1│  │         │   │
│  │  │  └───────────┘  │  │  └───────────┘  │         │   │
│  │  └─────────────────┘  └─────────────────┘         │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 1.3: Setting Up Your Environment — Step by Step

**Using uv (Recommended)**

```
┌─────────────────────────────────────────────────────────────┐
│              ENVIRONMENT SETUP WITH UV                      │
│                                                             │
│  Step 1: Install uv                                         │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  # macOS/Linux                                      │   │
│  │  curl -LsSf https://astral.sh/uv/install.sh | sh   │   │
│  │                                                     │   │
│  │  # Windows (PowerShell)                             │   │
│  │  powershell -c "irm https://astral.sh/uv/install.ps1 │ │
│  │  | iex"                                             │   │
│  │                                                     │   │
│  │  # Verify installation                              │   │
│  │  uv --version                                      │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Step 2: Create Project Directory                           │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  cd ~/DjangoProjects                                │   │
│  │  mkdir django_blog_project                          │   │
│  │  cd django_blog_project                             │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Step 3: Create Virtual Environment                         │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  uv venv                                           │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Step 4: Activate the Virtual Environment                   │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  # macOS/Linux                                      │   │
│  │  source .venv/bin/activate                          │   │
│  │                                                     │   │
│  │  # Windows (Command Prompt)                         │   │
│  │  .venv\Scripts\activate                             │   │
│  │                                                     │   │
│  │  # Windows (PowerShell)                             │   │
│  │  .venv\Scripts\Activate.ps1                         │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Step 5: Install Django 6                                  │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  uv pip install django==6.0                         │   │
│  │  uv pip freeze > requirements.txt                   │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Step 6: Verify Installation                                │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  python --version  # Should show 3.14+             │   │
│  │  python -m django --version  # Should show 6.0     │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 1.4: Creating Your First Django Project

**The `django-admin startproject` Command**

```
┌─────────────────────────────────────────────────────────────┐
│               CREATING A DJANGO PROJECT                     │
│                                                             │
│  The Command:                                               │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  django-admin startproject config .                 │   │
│  │                                                     │   │
│  │  # The "." means "create in the current directory"   │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  What This Creates:                                         │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  django_blog_project/                               │   │
│  │  │                                                │   │
│  │  ├── config/           ← Project configuration    │   │
│  │  │   ├── __init__.py   ← Marks as Python package  │   │
│  │  │   ├── settings.py   ← ALL Django settings      │   │
│  │  │   ├── urls.py       ← URL routing              │   │
│  │  │   ├── asgi.py       ← ASGI (async) config      │   │
│  │  │   └── wsgi.py       ← WSGI (production) config │   │
│  │  │                                                │   │
│  │  ├── manage.py          ← Django command center   │   │
│  │  ├── .venv/             ← Virtual environment     │   │
│  │  └── requirements.txt   ← Dependencies            │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Key Files Explained:                                       │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  manage.py  : Command center for all Django ops     │   │
│  │  settings.py: ALL configurations (DB, apps, etc.)   │   │
│  │  urls.py    : Website map (URL → View mapping)      │   │
│  │  wsgi.py    : Production entry point (Gunicorn)     │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 1.5: Running the Development Server

**Your First Django Application is Alive!**

```
┌─────────────────────────────────────────────────────────────┐
│              DJANGO DEVELOPMENT SERVER                      │
│                                                             │
│  Start the Server:                                          │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  python manage.py runserver                         │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Expected Output:                                           │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Watching for file changes with StatReloader        │   │
│  │  Performing system checks...                        │   │
│  │                                                     │   │
│  │  System check identified no issues (0 silenced).    │   │
│  │                                                     │   │
│  │  You have 18 unapplied migration(s). Your project   │   │
│  │  may not work properly until you apply the         │   │
│  │  migrations for app(s): admin, auth, ...           │   │
│  │  Run 'python manage.py migrate' to apply them.     │   │
│  │                                                     │   │
│  │  March 15, 2026 - 14:32:10                         │   │
│  │  Django version 6.0, using settings 'config.settings'│   │
│  │  Starting development server at http://127.0.0.1:8000/ │
│  │  Quit the server with CONTROL-C.                   │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Visit: http://127.0.0.1:8000/                             │
│  You should see the Django welcome page with a rocket ship!│
│                                                             │
│  ⚠️ Note about migrations:                                  │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  The warning about unapplied migrations is normal.  │   │
│  │  We'll apply them in Part 2 when we set up the      │   │
│  │  database. For now, just leave it.                  │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 1.6: Django's MVT Architecture

**Understanding the Model-View-Template Pattern**

```
┌─────────────────────────────────────────────────────────────┐
│                 MVT ARCHITECTURE                            │
│                                                             │
│  MVT vs MVC:                                                │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  MVC (Model-View-Controller)  │  MVT (Model-View-  │   │
│  │                              │   Template)           │   │
│  │  ├── Model = Data Layer      │  ├── Model = Data    │   │
│  │  ├── View = Presentation     │  ├── View = Business │   │
│  │  ├── Controller = Business   │  ├── Template =      │   │
│  │      Logic                    │      Presentation    │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Request Flow:                                              │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                                                     │   │
│  │  ┌─────────────┐                                    │   │
│  │  │   Browser   │                                    │   │
│  │  └──────┬──────┘                                    │   │
│  │         │ 1. GET /blog/                             │   │
│  │         ▼                                           │   │
│  │  ┌─────────────┐                                    │   │
│  │  │   URLs      │ 2. Finds view: blog_list          │   │
│  │  └──────┬──────┘                                    │   │
│  │         │                                           │   │
│  │         ▼                                           │   │
│  │  ┌─────────────┐                                    │   │
│  │  │   View      │ 3. Queries database for posts      │   │
│  │  └──────┬──────┘                                    │   │
│  │         │                                           │   │
│  │         ▼                                           │   │
│  │  ┌─────────────┐                                    │   │
│  │  │   Model     │ 4. Returns QuerySet of posts       │   │
│  │  └──────┬──────┘                                    │   │
│  │         │                                           │   │
│  │         ▼                                           │   │
│  │  ┌─────────────┐                                    │   │
│  │  │  Template   │ 5. Renders HTML with posts         │   │
│  │  └──────┬──────┘                                    │   │
│  │         │                                           │   │
│  │         ▼                                           │   │
│  │  ┌─────────────┐                                    │   │
│  │  │   Browser   │ 6. Displays rendered page          │   │
│  │  └─────────────┘                                    │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 1.7: The Restaurant Analogy

**Understanding Django Components Through a Restaurant**

```
┌─────────────────────────────────────────────────────────────┐
│              THE RESTAURANT ANALOGY                         │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                                                     │   │
│  │  🍽️ CUSTOMER (Browser)                             │   │
│  │  ┌─────────────────────────────────────────────┐   │   │
│  │  │  Wants to order a pizza (blog post)         │   │   │
│  │  └─────────────────────────────────────────────┘   │   │
│  │         │                                           │   │
│  │         ▼                                           │   │
│  │  📋 MENU (URLs)                                     │   │
│  │  ┌─────────────────────────────────────────────┐   │   │
│  │  │  Shows what's available to order            │   │   │
│  │  │  "Pizza" = blog post                       │   │   │
│  │  └─────────────────────────────────────────────┘   │   │
│  │         │                                           │   │
│  │         ▼                                           │   │
│  │  👨‍🍳 CHEF (View)                                    │   │
│  │  ┌─────────────────────────────────────────────┐   │   │
│  │  │  Takes the order, coordinates everything    │   │   │
│  │  │  Checks inventory (database)                │   │   │
│  │  │  Makes the pizza (business logic)           │   │   │
│  │  └─────────────────────────────────────────────┘   │   │
│  │         │                                           │   │
│  │         ▼                                           │   │
│  │  🍕 KITCHEN INVENTORY (Model)                       │   │
│  │  ┌─────────────────────────────────────────────┐   │   │
│  │  │  Ingredients (data)                         │   │   │
│  │  │  Recipes (business rules)                   │   │   │
│  │  │  Storage (database)                         │   │   │
│  │  └─────────────────────────────────────────────┘   │   │
│  │         │                                           │   │
│  │         ▼                                           │   │
│  │  🍽️ PLATE PRESENTATION (Template)                  │   │
│  │  ┌─────────────────────────────────────────────┐   │   │
│  │  │  How the pizza looks (HTML)                 │   │   │
│  │  │  Plating (CSS)                              │   │   │
│  │  │  Served to customer (rendered page)         │   │   │
│  │  └─────────────────────────────────────────────┘   │   │
│  │                                                     │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  The Chef is the Brain — Decides what data to show and     │
│  which template to use.                                    │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 1.8: Project vs. Application

**Understanding the Difference**

```
┌─────────────────────────────────────────────────────────────┐
│                  PROJECT VS. APP                            │
│                                                             │
│  The House Analogy:                                         │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                                                     │   │
│  │  ┌─────────────────────────────────────────────────┐│   │
│  │  │              DJANGO PROJECT                      ││   │
│  │  │               (The House)                       ││   │
│  │  │                                                 ││   │
│  │  │  ┌─────────────┐  ┌─────────────────────────┐  ││   │
│  │  │  │   Blog App  │  │   Users App             │  ││   │
│  │  │  │  (Bedroom)  │  │   (Kitchen)             │  ││   │
│  │  │  └─────────────┘  └─────────────────────────┘  ││   │
│  │  │  ┌─────────────┐  ┌─────────────────────────┐  ││   │
│  │  │  │  Comments   │  │   API App               │  ││   │
│  │  │  │    App      │  │   (Garage)              │  ││   │
│  │  │  │  (Bathroom) │  └─────────────────────────┘  ││   │
│  │  │  └─────────────┘                               ││   │
│  │  └─────────────────────────────────────────────────┘│   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Project vs. App:                                           │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                                                     │   │
│  │  PROJECT (config/)                                  │   │
│  │  ┌─────────────────────────────────────────────┐   │   │
│  │  │  • Settings (settings.py)                   │   │   │
│  │  │  • Main URL routing (urls.py)              │   │   │
│  │  │  • WSGI/ASGI entry points                   │   │   │
│  │  │  • One per website                          │   │   │
│  │  └─────────────────────────────────────────────┘   │   │
│  │                                                     │   │
│  │  APPLICATION (blog/)                                │   │
│  │  ┌─────────────────────────────────────────────┐   │   │
│  │  │  • Models (models.py)                       │   │   │
│  │  │  • Views (views.py)                         │   │   │
│  │  │  • Templates (templates/)                   │   │   │
│  │  │  • URL patterns (urls.py)                   │   │   │
│  │  │  • Many per project                         │   │   │
│  │  └─────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 1.9: Creating Your First Django Application

**The `startapp` Command**

```
┌─────────────────────────────────────────────────────────────┐
│              CREATING A DJANGO APP                          │
│                                                             │
│  The Command:                                               │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  python manage.py startapp blog                     │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  What This Creates:                                         │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  blog/                                              │   │
│  │  ├── migrations/        ← Database change scripts  │   │
│  │  │   └── __init__.py                               │   │
│  │  ├── __init__.py        ← Python package            │   │
│  │  ├── admin.py           ← Django admin config       │   │
│  │  ├── apps.py            ← App configuration         │   │
│  │  ├── models.py          ← Database models           │   │
│  │  ├── tests.py           ← Tests                     │   │
│  │  └── views.py           ← Views                     │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Register the App in `settings.py`:                         │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  INSTALLED_APPS = [                                 │   │
│  │      'django.contrib.admin',                        │   │
│  │      'django.contrib.auth',                         │   │
│  │      'django.contrib.contenttypes',                 │   │
│  │      'django.contrib.sessions',                     │   │
│  │      'django.contrib.messages',                     │   │
│  │      'django.contrib.staticfiles',                  │   │
│  │                                                    │   │
│  │      'blog',  # ← Add this!                        │   │
│  │  ]                                                 │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Verify:                                                    │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  python manage.py check                             │   │
│  │  System check identified no issues (0 silenced).    │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 1.10: Creating Your First Views

**Writing Views in `views.py`**

```
┌─────────────────────────────────────────────────────────────┐
│                 WRITING VIEWS                               │
│                                                             │
│  Basic View Structure:                                      │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  from django.shortcuts import render                │   │
│  │                                                     │   │
│  │  def home(request):                                │   │
│  │      # 1. Process request                           │   │
│  │      # 2. Do work (query database, etc.)           │   │
│  │      # 3. Return response                          │   │
│  │      return render(request, 'blog/home.html', context)│ │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Three Views We'll Create:                                  │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  1. home()      → Homepage                          │   │
│  │  2. about()     → About page                       │   │
│  │  3. blog_list() → Blog listing                     │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Home View Code:                                            │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  def home(request):                                │   │
│  │      context = {                                   │   │
│  │          'page_title': 'Welcome to My Django Blog',│   │
│  │          'welcome_message': 'This is the beginning',│   │
│  │          'year': 2026,                              │   │
│  │      }                                              │   │
│  │      return render(request, 'blog/home.html', context)│ │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Key Concept: The view is the brain — it decides what       │
│  data to show and which template to use.                   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 1.11: Creating Templates — The Base Template

**Template Inheritance with `base.html`**

```
┌─────────────────────────────────────────────────────────────┐
│               TEMPLATE INHERITANCE                          │
│                                                             │
│  Why Template Inheritance?                                  │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  ✅ DRY (Don't Repeat Yourself)                     │   │
│  │  ✅ Consistent layout across pages                  │   │
│  │  ✅ Easy to update site-wide elements               │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Base Template (`blog/templates/blog/base.html`):          │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  <!DOCTYPE html>                                    │   │
│  │  <html lang="en">                                   │   │
│  │  <head>                                             │   │
│  │      <title>{% block title %}Django Blog{% endblock %}</title>│
│  │  </head>                                            │   │
│  │  <body>                                             │   │
│  │      <!-- Navigation -->                            │   │
│  │      <nav>                                          │   │
│  │          <a href="{% url 'blog:home' %}">Home</a>   │   │
│  │          <a href="{% url 'blog:blog_list' %}">Blog</a>│   │
│  │          <a href="{% url 'blog:about' %}">About</a> │   │
│  │      </nav>                                         │   │
│  │                                                     │   │
│  │      <!-- Content Block -->                         │   │
│  │      <main>                                         │   │
│  │          {% block content %}                        │   │
│  │          {% endblock %}                             │   │
│  │      </main>                                        │   │
│  │                                                     │   │
│  │      <!-- Footer -->                                │   │
│  │      <footer>                                       │   │
│  │          &copy; {{ year }} Django Blog              │   │
│  │      </footer>                                     │   │
│  │  </body>                                            │   │
│  │  </html>                                            │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 1.12: Child Templates — Extending the Base

**Creating Page-Specific Templates**

```
┌─────────────────────────────────────────────────────────────┐
│                CHILD TEMPLATES                              │
│                                                             │
│  Home Page Template (`blog/templates/blog/home.html`):     │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  {% extends 'blog/base.html' %}                     │   │
│  │                                                     │   │
│  │  {% block title %}                                  │   │
│  │      {{ page_title }} — Django Blog                 │   │
│  │  {% endblock %}                                     │   │
│  │                                                     │   │
│  │  {% block content %}                                │   │
│  │  <div class="page-header">                          │   │
│  │      <h1>{{ welcome_message }}</h1>                 │   │
│  │      <p class="subtitle">Learn Django...</p>       │   │
│  │  </div>                                             │   │
│  │                                                     │   │
│  │  <div class="content">                              │   │
│  │      <h2>Welcome to Your Django Journey</h2>       │   │
│  │      <ul>                                           │   │
│  │          <li>✅ A fully functional Django website</li>│   │
│  │          <li>✅ Database-driven content</li>        │   │
│  │      </ul>                                          │   │
│  │      <a href="{% url 'blog:blog_list' %}">View Blog Posts →</a>│ │
│  │  </div>                                             │   │
│  │  {% endblock %}                                     │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  About Page Template (`about.html`):                        │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  {% extends 'blog/base.html' %}                     │   │
│  │                                                     │   │
│  │  {% block title %}About — Django Blog{% endblock %} │   │
│  │                                                     │   │
│  │  {% block content %}                                │   │
│  │  <div class="page-header">                          │   │
│  │      <h1>{{ page_title }}</h1>                     │   │
│  │  </div>                                             │   │
│  │  <div class="content">                              │   │
│  │      <p>{{ description }}</p>                       │   │
│  │      <ul>                                           │   │
│  │          {% for tech in technologies %}             │   │
│  │              <li>{{ tech }}</li>                    │   │
│  │          {% endfor %}                               │   │
│  │      </ul>                                          │   │
│  │  </div>                                             │   │
│  │  {% endblock %}                                     │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 1.13: Template Inheritance — Visual Flow

**How Inheritance Works**

```
┌─────────────────────────────────────────────────────────────┐
│              INHERITANCE FLOW                               │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │              base.html                              │   │
│  │  ┌───────────────────────────────────────────────┐  │   │
│  │  │  <html>                                       │  │   │
│  │  │    <head>                                     │  │   │
│  │  │      <title>                                 │  │   │
│  │  │        {% block title %}Default{% endblock %} │  │   │
│  │  │      </title>                                │  │   │
│  │  │    </head>                                    │  │   │
│  │  │    <body>                                     │  │   │
│  │  │      <nav> <!-- Navigation --> </nav>         │  │   │
│  │  │      <main>                                   │  │   │
│  │  │        {% block content %}{% endblock %}      │  │   │
│  │  │      </main>                                  │  │   │
│  │  │      <footer> <!-- Footer --> </footer>       │  │   │
│  │  │    </body>                                    │  │   │
│  │  │  </html>                                      │  │   │
│  │  └───────────────────────────────────────────────┘  │   │
│  └─────────────────────────────────────────────────────┘   │
│           │                          ▲                     │
│           │  Extends                │  Renders             │
│           ▼                          │                     │
│  ┌─────────────────────────────────────────────────────┐   │
│  │            home.html (Child)                       │   │
│  │  ┌───────────────────────────────────────────────┐  │   │
│  │  │  {% extends 'base.html' %}                    │  │   │
│  │  │  {% block title %}Home{% endblock %}           │  │   │
│  │  │  {% block content %}                          │  │   │
│  │  │    <h1>Welcome!</h1>                          │  │   │
│  │  │    <p>Content...</p>                          │  │   │
│  │  │  {% endblock %}                               │  │   │
│  │  └───────────────────────────────────────────────┘  │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Result: Everything from base.html + home.html's content   │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  <html>                                             │   │
│  │    <head><title>Home</title></head>                │   │
│  │    <body>                                           │   │
│  │      <nav> <!-- From base --> </nav>               │   │
│  │      <main><h1>Welcome!</h1><p>Content...</p></main>│   │
│  │      <footer> <!-- From base --> </footer>         │   │
│  │    </body>                                          │   │
│  │  </html>                                            │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 1.14: Creating URLs — Connecting Views

**URL Routing in Django**

```
┌─────────────────────────────────────────────────────────────┐
│                  URL ROUTING                                │
│                                                             │
│  Two Levels of URL Configuration:                           │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  1. Project Level (config/urls.py)                  │   │
│  │  2. App Level (blog/urls.py)                       │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Project URLs (`config/urls.py`):                          │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  from django.contrib import admin                   │   │
│  │  from django.urls import path, include              │   │
│  │                                                     │   │
│  │  urlpatterns = [                                    │   │
│  │      path('admin/', admin.site.urls),              │   │
│  │      path('', include('blog.urls')),  # Include app │   │
│  │  ]                                                 │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  App URLs (`blog/urls.py`):                                │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  from django.urls import path                       │   │
│  │  from . import views                                │   │
│  │                                                     │   │
│  │  app_name = 'blog'  # Namespace for reverse URLs   │   │
│  │                                                     │   │
│  │  urlpatterns = [                                    │   │
│  │      path('', views.home, name='home'),            │   │
│  │      path('about/', views.about, name='about'),    │   │
│  │      path('blog/', views.blog_list, name='blog_list'),│ │
│  │  ]                                                 │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  URL Resolution Flow:                                       │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Browser: GET /blog/                               │   │
│  │      ↓                                              │   │
│  │  config/urls.py: '' → include('blog.urls')         │   │
│  │      ↓                                              │   │
│  │  blog/urls.py: 'blog/' → blog_list view            │   │
│  │      ↓                                              │   │
│  │  blog_list(request) → Response                     │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 1.15: URL Naming and Reverse URLs

**Why Named URLs Matter**

```
┌─────────────────────────────────────────────────────────────┐
│              URL NAMING AND REVERSE LOOKUP                  │
│                                                             │
│  Why Name Your URLs?                                        │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  ✅ Flexibility — Change URL patterns without       │   │
│  │     breaking templates                               │   │
│  │  ✅ Readability — {% url 'blog:home' %} is clearer  │   │
│  │  ✅ Maintainability — One place to update all URLs  │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Named URLs in URLs File:                                   │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  urlpatterns = [                                    │   │
│  │      path('', views.home, name='home'),             │   │
│  │      path('about/', views.about, name='about'),     │   │
│  │      path('blog/', views.blog_list, name='blog_list'),│ │
│  │  ]                                                 │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Using Named URLs in Templates:                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  <!-- Hardcoded (Bad) → Breaks if URLs change -->   │   │
│  │  <a href="/">Home</a>                               │   │
│  │  <a href="/about/">About</a>                       │   │
│  │                                                     │   │
│  │  <!-- Named URLs (Good) → Always works -->          │   │
│  │  <a href="{% url 'blog:home' %}">Home</a>           │   │
│  │  <a href="{% url 'blog:about' %}">About</a>         │   │
│  │  <a href="{% url 'blog:blog_list' %}">Blog</a>      │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  The app_name Namespace:                                    │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  # blog/urls.py                                     │   │
│  │  app_name = 'blog'                                  │   │
│  │                                                     │   │
│  │  # Usage in templates                               │   │
│  │  {% url 'blog:home' %}     → '/'                   │   │
│  │  {% url 'blog:about' %}    → '/about/'             │   │
│  │  {% url 'blog:blog_list' %} → '/blog/'             │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 1.16: Static Files in Django

**Serving CSS, JavaScript, and Images**

```
┌─────────────────────────────────────────────────────────────┐
│                  STATIC FILES                               │
│                                                             │
│  What are Static Files?                                     │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Files that don't change: CSS, JavaScript, images   │   │
│  │  Served directly to the browser without processing  │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Static File Configuration in `settings.py`:               │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  STATIC_URL = '/static/'                            │   │
│  │  STATICFILES_DIRS = [BASE_DIR / 'static']          │   │
│  │  STATIC_ROOT = BASE_DIR / 'staticfiles'            │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Directory Structure:                                       │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  django_blog_project/                               │   │
│  │  └── static/                                        │   │
│  │      ├── css/                                       │   │
│  │      │   └── style.css                              │   │
│  │      ├── js/                                        │   │
│  │      │   └── main.js                               │   │
│  │      └── images/                                    │   │
│  │          └── logo.png                               │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Using Static Files in Templates:                           │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  {% load static %}                                  │   │
│  │                                                     │   │
│  │  <link rel="stylesheet" href="{% static 'css/style.css' %}">│ │
│  │  <script src="{% static 'js/main.js' %}"></script> │   │
│  │  <img src="{% static 'images/logo.png' %}" alt="Logo">│ │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 1.17: CSS Styling in Base Template

**Professional Design with Inline CSS**

```
┌─────────────────────────────────────────────────────────────┐
│                   CSS STYLING                               │
│                                                             │
│  Inline CSS in Base Template:                                │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  <style>                                            │   │
│  │      /* Reset */                                    │   │
│  │      * { margin: 0; padding: 0; box-sizing: border-box; } │
│  │                                                     │   │
│  │      body {                                         │   │
│  │          font-family: -apple-system, BlinkMacSystemFont, │ │
│  │                       'Segoe UI', Roboto, sans-serif; │   │
│  │          line-height: 1.6;                          │   │
│  │          color: #333;                               │   │
│  │          background-color: #f8f9fa;                 │   │
│  │      }                                              │   │
│  │                                                     │   │
│  │      .container {                                   │   │
│  │          max-width: 1200px;                         │   │
│  │          margin: 0 auto;                            │   │
│  │          padding: 0 20px;                           │   │
│  │      }                                              │   │
│  │                                                     │   │
│  │      /* Navigation */                               │   │
│  │      nav {                                          │   │
│  │          background-color: #2c3e50;                 │   │
│  │          color: white;                              │   │
│  │          padding: 1rem 0;                           │   │
│  │      }                                              │   │
│  │                                                     │   │
│  │      nav .nav-links {                               │   │
│  │          display: flex;                             │   │
│  │          gap: 1.5rem;                               │   │
│  │          list-style: none;                          │   │
│  │      }                                              │   │
│  │                                                     │   │
│  │      nav .nav-links a {                             │   │
│  │          color: #ecf0f1;                            │   │
│  │          text-decoration: none;                     │   │
│  │      }                                              │   │
│  │                                                     │   │
│  │      nav .nav-links a:hover {                       │   │
│  │          color: #3498db;                            │   │
│  │      }                                              │   │
│  │                                                     │   │
│  │      .content {                                     │   │
│  │          background: white;                         │   │
│  │          padding: 2rem;                             │   │
│  │          border-radius: 8px;                        │   │
│  │          box-shadow: 0 2px 4px rgba(0,0,0,0.1);    │   │
│  │      }                                              │   │
│  │  </style>                                           │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 1.18: Complete Navigation Component

**Building the Navigation Bar**

```
┌─────────────────────────────────────────────────────────────┐
│                  NAVIGATION COMPONENT                       │
│                                                             │
│  HTML Structure:                                            │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  <nav>                                              │   │
│  │      <div class="container">                        │   │
│  │          <a href="{% url 'blog:home' %}" class="nav-brand">│ │
│  │              Django Blog                            │   │
│  │          </a>                                       │   │
│  │                                                     │   │
│  │          <ul class="nav-links">                     │   │
│  │              <li><a href="{% url 'blog:home' %}">Home</a></li>│ │
│  │              <li><a href="{% url 'blog:blog_list' %}">Blog</a></li>│ │
│  │              <li><a href="{% url 'blog:about' %}">About</a></li>│ │
│  │          </ul>                                      │   │
│  │      </div>                                         │   │
│  │  </nav>                                             │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Visual Representation:                                     │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  ┌─────────────────────────────────────────────────┐│   │
│  │  │  Django Blog    [Home] [Blog] [About]           ││   │
│  │  │  ↑              ↑      ↑      ↑                  ││   │
│  │  │  Brand          Home   Blog   About             ││   │
│  │  └─────────────────────────────────────────────────┘│   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  CSS Styling:                                               │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  nav {                                              │   │
│  │      background-color: #2c3e50;                     │   │
│  │      padding: 1rem 0;                               │   │
│  │  }                                                  │   │
│  │                                                     │   │
│  │  nav .container {                                   │   │
│  │      display: flex;                                 │   │
│  │      justify-content: space-between;                │   │
│  │      align-items: center;                           │   │
│  │  }                                                  │   │
│  │                                                     │   │
│  │  nav .nav-brand {                                   │   │
│  │      font-size: 1.5rem;                             │   │
│  │      font-weight: bold;                             │   │
│  │      color: white;                                  │   │
│  │      text-decoration: none;                         │   │
│  │  }                                                  │   │
│  │                                                     │   │
│  │  nav .nav-links {                                   │   │
│  │      display: flex;                                 │   │
│  │      gap: 1.5rem;                                   │   │
│  │      list-style: none;                              │   │
│  │  }                                                  │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 1.19: The Footer Component

**Building the Footer**

```
┌─────────────────────────────────────────────────────────────┐
│                   FOOTER COMPONENT                          │
│                                                             │
│  HTML Structure:                                            │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  <footer>                                           │   │
│  │      <div class="container">                        │   │
│  │          <p>&copy; {{ year }} Django Blog.          │   │
│  │             Built with ❤️ using Django 6.</p>      │   │
│  │      </div>                                         │   │
│  │  </footer>                                          │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  CSS Styling:                                               │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  footer {                                            │   │
│  │      background-color: #2c3e50;                     │   │
│  │      color: #ecf0f1;                                │   │
│  │      text-align: center;                            │   │
│  │      padding: 1.5rem 0;                             │   │
│  │      margin-top: 3rem;                              │   │
│  │  }                                                  │   │
│  │                                                     │   │
│  │  footer a {                                         │   │
│  │      color: #3498db;                                │   │
│  │      text-decoration: none;                         │   │
│  │  }                                                  │   │
│  │                                                     │   │
│  │  footer a:hover {                                   │   │
│  │      text-decoration: underline;                    │   │
│  │  }                                                  │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Why Pass Year from Context?                                │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  • The year should be dynamic (auto-updates)        │   │
│  │  • In Part 6, we'll learn about context processors  │   │
│  │  • For now, we pass it from each view               │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 1.20: Template Tags and Filters — Quick Reference

**Essential Django Template Syntax**

```
┌─────────────────────────────────────────────────────────────┐
│              TEMPLATE TAGS AND FILTERS                      │
│                                                             │
│  Common Template Tags:                                      │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  {% extends 'base.html' %}   Inherit from base     │   │
│  │  {% block content %}{% endblock %}  Define a block │   │
│  │  {% include 'header.html' %}   Include a template  │   │
│  │  {% if condition %}          Conditional rendering │   │
│  │  {% for item in list %}      Loop over a list      │   │
│  │  {% url 'app:view' %}        Generate a URL        │   │
│  │  {% load static %}           Load static tags      │   │
│  │  {% comment %}...{% endcomment %}  Comments        │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Common Template Filters:                                   │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  {{ name|lower }}            Convert to lowercase   │   │
│  │  {{ name|upper }}            Convert to uppercase   │   │
│  │  {{ name|title }}            Title case             │   │
│  │  {{ list|length }}           Get length             │   │
│  │  {{ value|default:"N/A" }}   Provide default value │   │
│  │  {{ text|truncatewords:30 }} Cut off after N words │   │
│  │  {{ date|date:"Y-m-d" }}     Format a date          │   │
│  │  {{ text|linebreaks }}       Convert newlines to <br>│  │
│  │  {{ html|safe }}             Mark HTML as safe      │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Example Usage:                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  {% if user.is_authenticated %}                    │   │
│  │      <p>Welcome, {{ user.username|title }}!</p>    │   │
│  │  {% else %}                                        │   │
│  │      <a href="{% url 'login' %}">Login</a>        │   │
│  │  {% endif %}                                       │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 1.21: Complete Project Structure After Part 1

**What We've Built**

```
┌─────────────────────────────────────────────────────────────┐
│              PROJECT STRUCTURE — PART 1                     │
│                                                             │
│  django_blog_project/                                       │
│  ├── manage.py                                              │
│  ├── requirements.txt                                       │
│  ├── .venv/                                                 │
│  │                                                          │
│  ├── config/                                                │
│  │   ├── __init__.py                                        │
│  │   ├── settings.py         ← Django settings             │
│  │   ├── urls.py             ← Project URL routing         │
│  │   └── wsgi.py                                            │
│  │                                                          │
│  └── blog/                                                  │
│      ├── migrations/                                        │
│      │   └── __init__.py                                    │
│      ├── templates/                                         │
│      │   └── blog/                                          │
│      │       ├── base.html      ← Template inheritance     │
│      │       ├── home.html      ← Homepage                 │
│      │       ├── about.html     ← About page               │
│      │       └── blog_list.html ← Blog listing             │
│      ├── __init__.py                                        │
│      ├── admin.py                                           │
│      ├── apps.py                                            │
│      ├── models.py                                          │
│      ├── tests.py                                           │
│      ├── urls.py               ← App URL routing           │
│      └── views.py              ← Views                     │
│                                                             │
│  Key Files Created:                                        │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  ✅ 3 Views (home, about, blog_list)                │   │
│  │  ✅ 4 Templates (base, home, about, blog_list)      │   │
│  │  ✅ 1 URL configuration (blog/urls.py)              │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 1.22: Verification — Testing Your Application

**Comprehensive Verification Checklist**

```
┌─────────────────────────────────────────────────────────────┐
│              VERIFICATION CHECKLIST                         │
│                                                             │
│  Step 1: Start the Server                                   │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  python manage.py runserver                         │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Step 2: Visit Each Page                                   │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  URL                    │  Expected Result          │   │
│  │  ──────────────────────────────────────────────────  │   │
│  │  /                      │  Homepage with welcome    │   │
│  │  /blog/                 │  Blog page with "No posts" │   │
│  │  /about/                │  About page with tech list │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Step 3: Test Navigation                                   │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Click "Home"  → Goes to homepage                   │   │
│  │  Click "Blog"  → Goes to blog page                  │   │
│  │  Click "About" → Goes to about page                 │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Success Criteria:                                          │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  ✅ All pages load without errors                   │   │
│  │  ✅ Navigation links work                           │   │
│  │  ✅ CSS styling looks professional                  │   │
│  │  ✅ Footer displays correct year                    │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 1.23: Common Errors and Troubleshooting

**Quick Reference for Common Issues**

```
┌─────────────────────────────────────────────────────────────┐
│              COMMON ERRORS AND FIXES                        │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Error: "No module named 'django'"                  │   │
│  │  Cause: Virtual environment not activated            │   │
│  │  Fix: source .venv/bin/activate                    │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Error: "TemplateDoesNotExist at /"                 │   │
│  │  Cause: Template file missing or path incorrect      │   │
│  │  Fix: Check file exists at                         │   │
│  │       blog/templates/blog/home.html                 │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Error: "NoReverseMatch at /"                       │   │
│  │  Cause: URL name doesn't exist or namespace wrong    │   │
│  │  Fix: Check app_name in blog/urls.py               │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Error: "AttributeError: module 'blog.views' has    │   │
│  │  no attribute 'home'"                               │   │
│  │  Cause: View function not defined or has typo       │   │
│  │  Fix: Check function name matches URL pattern       │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Error: "ImportError: No module named 'blog'"       │   │
│  │  Cause: App not in INSTALLED_APPS                   │   │
│  │  Fix: Add 'blog' to INSTALLED_APPS in settings.py  │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 1.24: What You've Learned in Part 1

**Skills Acquired and What You've Built**

```
┌─────────────────────────────────────────────────────────────┐
│              WHAT YOU'VE LEARNED — PART 1                  │
│                                                             │
│  ✅ Skills Acquired:                                        │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  • Setting up Python virtual environments           │   │
│  │  • Installing Django 6                              │   │
│  │  • Creating Django projects and applications        │   │
│  │  • Understanding Django's MVT architecture          │   │
│  │  • Writing function-based views                     │   │
│  │  • Creating templates with template inheritance     │   │
│  │  • Configuring URLs at project and app level        │   │
│  │  • Understanding the request/response cycle         │   │
│  │  • Using {% url %} for dynamic URL generation       │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ✅ What You've Built:                                      │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  • A working Django project with proper structure    │   │
│  │  • Three pages (home, about, blog) with navigation  │   │
│  │  • A shared base template with inheritance          │   │
│  │  • Professional CSS styling                          │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  🎯 Ready for Part 2:                                       │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  In Part 2, we'll add a database to make our        │   │
│  │  blog dynamic!                                      │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 1.25: Quick Reference — Commands Used in Part 1

**Essential Commands Summary**

```
┌─────────────────────────────────────────────────────────────┐
│              QUICK REFERENCE — COMMANDS                     │
│                                                             │
│  Environment Setup:                                        │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  uv venv                                          │   │
│  │  source .venv/bin/activate     # macOS/Linux      │   │
│  │  .venv\Scripts\activate        # Windows          │   │
│  │  uv pip install django==6.0                       │   │
│  │  uv pip freeze > requirements.txt                  │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Django Commands:                                           │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  django-admin startproject config .                 │   │
│  │  python manage.py startapp blog                    │   │
│  │  python manage.py runserver                        │   │
│  │  python manage.py check                            │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Project Structure Commands:                                │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  mkdir -p blog/templates/blog                      │   │
│  │  touch blog/templates/blog/{base,home,about,blog_list}.html│ │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Testing URLs:                                              │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  http://127.0.0.1:8000/    → Homepage               │   │
│  │  http://127.0.0.1:8000/blog/  → Blog list          │   │
│  │  http://127.0.0.1:8000/about/ → About page         │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 1.26: Challenges — Extend Your Website

**Practice Exercises to Reinforce Learning**

```
┌─────────────────────────────────────────────────────────────┐
│                CHALLENGES — PART 1                          │
│                                                             │
│  Challenge 1: Add a Contact Page                           │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  1. Create view: def contact(request):              │   │
│  │  2. Create template: contact.html                   │   │
│  │  3. Add URL: path('contact/', views.contact,        │   │
│  │     name='contact')                                 │   │
│  │  4. Add navigation link                             │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Challenge 2: Add a Footer Include                         │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  1. Create blog/templates/blog/includes/footer.html │   │
│  │  2. Move footer HTML to new file                    │   │
│  │  3. Use {% include 'blog/includes/footer.html' %}   │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Challenge 3: Customize the Styling                        │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  1. Change the primary color                         │   │
│  │  2. Add a background gradient                        │   │
│  │  3. Add hover effects to navigation items           │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Challenge 4: Add a Current Year Context Processor        │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  1. Create a context processor                      │   │
│  │  2. Add current year globally                       │   │
│  │  3. Remove year from individual views              │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 1.27: Proceed to Part 2

**Preview of What's Coming**

```
┌─────────────────────────────────────────────────────────────┐
│                COMING UP IN PART 2                          │
│                                                             │
│  🗄️ Models, Database Design, ORM, and Django Admin        │
│                                                             │
│  What We'll Build:                                          │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  A database-driven blog with:                       │   │
│  │  • Post model with status, categories, tags         │   │
│  │  • Author relationship with User model              │   │
│  │  • Comment model for user discussions               │   │
│  │  • Django Admin interface for data management       │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  What We'll Learn:                                          │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  • Designing database models in Python              │   │
│  │  • Creating and running migrations                  │   │
│  │  • Django's ORM for querying data                   │   │
│  │  • Django Admin configuration                       │   │
│  │  • Displaying database content in templates         │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Preview of Data Model:                                     │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Category ────┐                                    │   │
│  │               │                                     │   │
│  │  Tag ─────────┼─── Post ────┐                     │   │
│  │               │             │                      │   │
│  │  Comment ─────┘             │                      │   │
│  │                             │                      │   │
│  │                   User (Django built-in)           │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Let's build the database! 🗄️                             │
└─────────────────────────────────────────────────────────────┘
```

---

# PART 2: MODELS, DATABASE DESIGN, ORM, AND DJANGO ADMIN

---

## Slide 2.1: Part 2 Introduction

**Learning Objectives**

```
┌─────────────────────────────────────────────────────────────┐
│                    PART 2 OVERVIEW                          │
│                                                             │
│  🎯 Learning Objectives:                                    │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  ✅ Design database models for our blog             │   │
│  │  ✅ Create and run database migrations              │   │
│  │  ✅ Use Django's powerful ORM to query data         │   │
│  │  ✅ Set up Django Admin for data management         │   │
│  │  ✅ Display real database content in templates      │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  🏗️ What We'll Build:                                      │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  • Category model for organizing posts              │   │
│  │  • Tag model for labeling posts                    │   │
│  │  • Post model with content, status, relationships  │   │
│  │  • Comment model for user discussions              │   │
│  │  • Django Admin configuration for all models       │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  📚 Key Concepts:                                          │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  • Models and fields (CharField, TextField, etc.)  │   │
│  │  • Relationships (ForeignKey, ManyToManyField)     │   │
│  │  • Migrations (makemigrations, migrate)            │   │
│  │  • ORM (create, read, update, delete)              │   │
│  │  • Admin registration and customization            │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 2.2: Understanding Django Models

**What Are Models and How Do They Work?**

```
┌─────────────────────────────────────────────────────────────┐
│                    WHAT ARE MODELS?                         │
│                                                             │
│  Models are Python classes that represent database tables:  │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                                                     │   │
│  │  Model (Python Class)  →  Database Table            │   │
│  │  Attribute             →  Column                   │   │
│  │  Instance              →  Row (Record)             │   │
│  │                                                     │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Example:                                                   │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  class Post(models.Model):                          │   │
│  │      title = models.CharField(max_length=200)       │   │
│  │      content = models.TextField()                  │   │
│  │      created_at = models.DateTimeField()           │   │
│  │                                                    │   │
│  │  ↓ Creates this table:                             │   │
│  │                                                    │   │
│  │  ┌─────┬──────────┬──────────┬─────────────────┐   │   │
│  │  │ id  │ title    │ content  │ created_at      │   │   │
│  │  ├─────┼──────────┼──────────┼─────────────────┤   │   │
│  │  │ 1   │ Django   │ ...      │ 2026-03-15 14:30│   │   │
│  │  │ 2   │ Python   │ ...      │ 2026-03-14 10:00│   │   │
│  │  └─────┴──────────┴──────────┴─────────────────┘   │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Blueprint Analogy:                                         │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  • Model = Blueprint for a house                   │   │
│  │  • Migration = Building the house                  │   │
│  │  • Instance = A specific house built from blueprint│   │
│  │  • Query = Looking for a specific house            │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 2.3: Planning Our Blog Models

**Data Relationship Diagram**

```
┌─────────────────────────────────────────────────────────────┐
│                  DATA RELATIONSHIPS                         │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                                                     │   │
│  │  ┌─────────────┐         ┌─────────────┐          │   │
│  │  │   Category  │         │    Post     │          │   │
│  │  │             │         │             │          │   │
│  │  │ id          │◄────────│ category_id │          │   │
│  │  │ name        │   Many  │ title       │          │   │
│  │  │ slug        │   To    │ slug        │          │   │
│  │  │ description │   One   │ content     │          │   │
│  │  │ created_at  │         │ excerpt     │          │   │
│  │  └─────────────┘         │ featured_img│          │   │
│  │                          │ status      │          │   │
│  │          ┌───────────────│ author_id   │          │   │
│  │          │               │ created_at  │          │   │
│  │          │               │ updated_at  │          │   │
│  │          │               │ published_at│          │   │
│  │          │               └─────────────┘          │   │
│  │          │                    │                    │   │
│  │          │                    │ One to Many       │   │
│  │          │                    ▼                    │   │
│  │          │             ┌─────────────┐          │   │
│  │          │             │   Comment   │          │   │
│  │          │             │             │          │   │
│  │          └─────────────│ id          │          │   │
│  │                        │ post_id     │          │   │
│  │                        │ author_id   │          │   │
│  │                        │ content     │          │   │
│  │                        │ created_at  │          │   │
│  │                        │ is_approved │          │   │
│  │                        └─────────────┘          │   │
│  │                                                    │   │
│  │         ┌─────────────┐         ┌─────────────┐   │   │
│  │         │    Tag      │         │   Post_Tag  │   │   │
│  │         │             │         │  (through)  │   │   │
│  │         │ id          │◄────────│ post_id     │   │   │
│  │         │ name        │   Many  │ tag_id      │   │   │
│  │         │ slug        │   To    └─────────────┘   │   │
│  │         │ created_at  │   Many                    │   │
│  │         └─────────────┘                           │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Relationships:                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  • Category → Post: One-to-Many                     │   │
│  │  • User → Post: One-to-Many                         │   │
│  │  • Post → Tag: Many-to-Many                         │   │
│  │  • Post → Comment: One-to-Many                     │   │
│  │  • User → Comment: One-to-Many                     │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 2.4: Creating the Category Model

**Code Walkthrough**

```
┌─────────────────────────────────────────────────────────────┐
│                  CATEGORY MODEL                             │
│                                                             │
│  Code:                                                      │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  from django.db import models                       │   │
│  │  from django.utils.text import slugify              │   │
│  │  from django.urls import reverse                    │   │
│  │                                                     │   │
│  │  class Category(models.Model):                      │   │
│  │      """                                            │   │
│  │      Category model for organizing blog posts.      │   │
│  │      """                                            │   │
│  │      name = models.CharField(                       │   │
│  │          max_length=100,                            │   │
│  │          unique=True,                               │   │
│  │          help_text="Display name of the category"   │   │
│  │      )                                              │   │
│  │      slug = models.SlugField(                       │   │
│  │          max_length=120,                            │   │
│  │          unique=True,                               │   │
│  │          help_text="URL-friendly version of name"   │   │
│  │      )                                              │   │
│  │      description = models.TextField(                │   │
│  │          blank=True,                                │   │
│  │          help_text="Optional description"           │   │
│  │      )                                              │   │
│  │      created_at = models.DateTimeField(             │   │
│  │          auto_now_add=True                          │   │
│  │      )                                              │   │
│  │      updated_at = models.DateTimeField(             │   │
│  │          auto_now=True                              │   │
│  │      )                                              │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Key Features:                                              │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  ✅ unique=True → Prevents duplicate names/slugs    │   │
│  │  ✅ blank=True → Field is optional in forms        │   │
│  │  ✅ auto_now_add → Set once on creation            │   │
│  │  ✅ auto_now → Update on every save                │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 2.5: Category Model — Meta and Methods

**Configuration and Custom Methods**

```
┌─────────────────────────────────────────────────────────────┐
│              CATEGORY — META AND METHODS                    │
│                                                             │
│  Meta Configuration:                                        │
│  ┌─────────────────────────────────────────────────────┐   │
│  │      class Meta:                                    │   │
│  │          ordering = ['name']                        │   │
│  │          verbose_name_plural = "Categories"         │   │
│  │      """                                            │   │
│  │      • ordering: Alphabetical order                 │   │
│  │      • verbose_name_plural: Correct plural form    │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Custom Methods:                                            │
│  ┌─────────────────────────────────────────────────────┐   │
│  │      def save(self, *args, **kwargs):               │   │
│  │          """Auto-generate slug from name."""        │   │
│  │          if not self.slug:                          │   │
│  │              self.slug = slugify(self.name)         │   │
│  │          super().save(*args, **kwargs)             │   │
│  │                                                     │   │
│  │      def __str__(self):                             │   │
│  │          """String representation."""               │   │
│  │          return self.name                           │   │
│  │                                                     │   │
│  │      def get_absolute_url(self):                    │   │
│  │          """Canonical URL for this object."""       │   │
│  │          return reverse('blog:category_detail',    │   │
│  │                         args=[self.slug])           │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Why These Methods Matter:                                  │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Method           │  Purpose                       │   │
│  │  ──────────────────────────────────────────────────  │   │
│  │  save()           │  Auto-generate slug            │   │
│  │  __str__()        │  Display in admin and shell    │   │
│  │  get_absolute_url │  URL reversal in templates     │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 2.6: Creating the Tag Model

**Code Walkthrough**

```
┌─────────────────────────────────────────────────────────────┐
│                    TAG MODEL                                │
│                                                             │
│  Code:                                                      │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  class Tag(models.Model):                           │   │
│  │      """                                            │   │
│  │      Tag model for labeling posts with keywords.    │   │
│  │      """                                            │   │
│  │      name = models.CharField(                       │   │
│  │          max_length=50,                             │   │
│  │          unique=True,                               │   │
│  │          help_text="The tag name"                   │   │
│  │      )                                              │   │
│  │      slug = models.SlugField(                       │   │
│  │          max_length=60,                             │   │
│  │          unique=True,                               │   │
│  │          help_text="URL-friendly version of name"   │   │
│  │      )                                              │   │
│  │      created_at = models.DateTimeField(             │   │
│  │          auto_now_add=True                          │   │
│  │      )                                              │   │
│  │                                                     │   │
│  │      class Meta:                                    │   │
│  │          ordering = ['name']                        │   │
│  │                                                     │   │
│  │      def save(self, *args, **kwargs):              │   │
│  │          if not self.slug:                          │   │
│  │              self.slug = slugify(self.name)         │   │
│  │          super().save(*args, **kwargs)             │   │
│  │                                                     │   │
│  │      def __str__(self):                             │   │
│  │          return self.name                           │   │
│  │                                                     │   │
│  │      def get_absolute_url(self):                    │   │
│  │          return reverse('blog:tag_detail',         │   │
│  │                         args=[self.slug])           │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Categories vs. Tags:                                       │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Categories: Hierarchical (Technology → Programming)│   │
│  │  Tags: Flat, flexible labels (Python, Django, Web)  │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 2.7: Creating the Post Model — Part 1

**Basic Fields and Relationships**

```
┌─────────────────────────────────────────────────────────────┐
│                    POST MODEL — PART 1                      │
│                                                             │
│  Code:                                                      │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  from django.contrib.auth.models import User        │   │
│  │                                                     │   │
│  │  class Post(models.Model):                          │   │
│  │      """The heart of our blog."""                   │   │
│  │                                                     │   │
│  │      # Status choices                              │   │
│  │      class Status(models.TextChoices):              │   │
│  │          DRAFT = 'draft', 'Draft'                  │   │
│  │          PUBLISHED = 'published', 'Published'      │   │
│  │          ARCHIVED = 'archived', 'Archived'         │   │
│  │                                                     │   │
│  │      # Basic information                            │   │
│  │      title = models.CharField(max_length=200)       │   │
│  │      slug = models.SlugField(max_length=220, unique=True)│ │
│  │                                                     │   │
│  │      # Content                                      │   │
│  │      content = models.TextField()                  │   │
│  │      excerpt = models.TextField(max_length=500, blank=True)│ │
│  │                                                     │   │
│  │      # Relationships                                │   │
│  │      author = models.ForeignKey(                    │   │
│  │          User,                                      │   │
│  │          on_delete=models.CASCADE,                  │   │
│  │          related_name='blog_posts'                 │   │
│  │      )                                              │   │
│  │      category = models.ForeignKey(                  │   │
│  │          Category,                                  │   │
│  │          on_delete=models.SET_NULL,                 │   │
│  │          null=True, blank=True,                     │   │
│  │          related_name='posts'                      │   │
│  │      )                                              │   │
│  │      tags = models.ManyToManyField(                 │   │
│  │          Tag,                                       │   │
│  │          blank=True,                                │   │
│  │          related_name='posts'                      │   │
│  │      )                                              │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Status Choices: Enum-like pattern for status field        │
│  related_name: Reverse relationship name                  │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 2.8: Creating the Post Model — Part 2

**Media, Dates, and Meta Data**

```
┌─────────────────────────────────────────────────────────────┐
│                    POST MODEL — PART 2                      │
│                                                             │
│  Code:                                                      │
│  ┌─────────────────────────────────────────────────────┐   │
│  │      # Media                                        │   │
│  │      featured_image = models.ImageField(            │   │
│  │          upload_to='posts/%Y/%m/%d/',              │   │
│  │          blank=True, null=True                     │   │
│  │      )                                              │   │
│  │                                                     │   │
│  │      # Status and dates                             │   │
│  │      status = models.CharField(                     │   │
│  │          max_length=10,                             │   │
│  │          choices=Status.choices,                    │   │
│  │          default=Status.DRAFT                       │   │
│  │      )                                              │   │
│  │      created_at = models.DateTimeField(             │   │
│  │          auto_now_add=True                          │   │
│  │      )                                              │   │
│  │      updated_at = models.DateTimeField(             │   │
│  │          auto_now=True                              │   │
│  │      )                                              │   │
│  │      published_at = models.DateTimeField(           │   │
│  │          blank=True, null=True                     │   │
│  │      )                                              │   │
│  │                                                     │   │
│  │      # SEO metadata                                 │   │
│  │      meta_description = models.CharField(           │   │
│  │          max_length=160, blank=True                │   │
│  │      )                                              │   │
│  │      meta_keywords = models.CharField(              │   │
│  │          max_length=255, blank=True                │   │
│  │      )                                              │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  upload_to: Organizes images by date (posts/2026/03/15/)  │
│  auto_now: Updates on every save                          │
│  auto_now_add: Set once on creation                       │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 2.9: Post Model — Meta and Custom Methods

**Configuration and Business Logic**

```
┌─────────────────────────────────────────────────────────────┐
│              POST MODEL — META AND METHODS                  │
│                                                             │
│  Meta Configuration:                                        │
│  ┌─────────────────────────────────────────────────────┐   │
│  │      class Meta:                                    │   │
│  │          ordering = ['-created_at']                 │   │
│  │          indexes = [                                │   │
│  │              models.Index(fields=['status', 'published_at']),│ │
│  │              models.Index(fields=['author']),      │   │
│  │              models.Index(fields=['slug']),        │   │
│  │          ]                                          │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Custom save() Method:                                      │
│  ┌─────────────────────────────────────────────────────┐   │
│  │      def save(self, *args, **kwargs):              │   │
│  │          # Auto-generate slug                      │   │
│  │          if not self.slug:                          │   │
│  │              self.slug = slugify(self.title)        │   │
│  │                                                     │   │
│  │          # Auto-generate excerpt                   │   │
│  │          if not self.excerpt and self.content:     │   │
│  │              self.excerpt = self.content[:200]      │   │
│  │                                                     │   │
│  │          # Set published_at on publish             │   │
│  │          if self.pk:                                │   │
│  │              old = Post.objects.get(pk=self.pk)    │   │
│  │              old_status = old.status               │   │
│  │          else:                                      │   │
│  │              old_status = None                      │   │
│  │                                                     │   │
│  │          if (self.status == Status.PUBLISHED and   │   │
│  │              old_status != Status.PUBLISHED):      │   │
│  │              self.published_at = timezone.now()    │   │
│  │                                                     │   │
│  │          super().save(*args, **kwargs)             │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 2.10: Post Model — String and URL Methods

**Display and URL Generation**

```
┌─────────────────────────────────────────────────────────────┐
│              POST MODEL — STRING AND URL                    │
│                                                             │
│  __str__ Method:                                            │
│  ┌─────────────────────────────────────────────────────┐   │
│  │      def __str__(self):                             │   │
│  │          return self.title                          │   │
│  │                                                    │   │
│  │      # Used in admin, shell, and debug output      │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  get_absolute_url Method:                                   │
│  ┌─────────────────────────────────────────────────────┐   │
│  │      def get_absolute_url(self):                    │   │
│  │          """Return the canonical URL for this post."""│   │
│  │          return reverse('blog:post_detail',        │   │
│  │                         args=[self.slug])           │   │
│  │                                                    │   │
│  │      # Used in templates:                          │   │
│  │      # <a href="{{ post.get_absolute_url }}">      │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Custom Methods:                                            │
│  ┌─────────────────────────────────────────────────────┐   │
│  │      def get_comment_count(self):                   │   │
│  │          """Return number of approved comments."""  │   │
│  │          return self.comments.filter(               │   │
│  │              is_approved=True                       │   │
│  │          ).count()                                 │   │
│  │                                                    │   │
│  │      def is_published(self):                       │   │
│  │          """Check if the post is published."""     │   │
│  │          return self.status == self.Status.PUBLISHED│   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Usage Examples:                                            │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  # Template:                                        │   │
│  │  <p>Comments: {{ post.get_comment_count }}</p>     │   │
│  │  {% if post.is_published %} Published {% endif %}   │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 2.11: Creating the Comment Model

**Code Walkthrough**

```
┌─────────────────────────────────────────────────────────────┐
│                   COMMENT MODEL                             │
│                                                             │
│  Code:                                                      │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  class Comment(models.Model):                       │   │
│  │      """                                            │   │
│  │      Comment model for user discussions on posts.   │   │
│  │      """                                            │   │
│  │      post = models.ForeignKey(                      │   │
│  │          Post,                                      │   │
│  │          on_delete=models.CASCADE,                  │   │
│  │          related_name='comments'                   │   │
│  │      )                                              │   │
│  │      author = models.ForeignKey(                    │   │
│  │          User,                                      │   │
│  │          on_delete=models.CASCADE,                  │   │
│  │          related_name='blog_comments'              │   │
│  │      )                                              │   │
│  │      content = models.TextField()                   │   │
│  │      is_approved = models.BooleanField(             │   │
│  │          default=False,                             │   │
│  │          help_text="Has this comment been approved?"│   │
│  │      )                                              │   │
│  │      created_at = models.DateTimeField(             │   │
│  │          auto_now_add=True                          │   │
│  │      )                                              │   │
│  │      updated_at = models.DateTimeField(             │   │
│  │          auto_now=True                              │   │
│  │      )                                              │   │
│  │                                                    │   │
│  │      class Meta:                                    │   │
│  │          ordering = ['created_at']                  │   │
│  │          indexes = [                                │   │
│  │              models.Index(fields=['post', 'created_at']),│ │
│  │              models.Index(fields=['is_approved']), │   │
│  │          ]                                          │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 2.12: Comment Model — Methods

**String and URL Methods**

```
┌─────────────────────────────────────────────────────────────┐
│              COMMENT MODEL — METHODS                        │
│                                                             │
│  __str__ Method:                                            │
│  ┌─────────────────────────────────────────────────────┐   │
│  │      def __str__(self):                             │   │
│  │          return f"Comment by {self.author.username} │   │
│  │                   on {self.post.title}"             │   │
│  │                                                    │   │
│  │      # Example output:                             │   │
│  │      # "Comment by johndoe on My First Post"      │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  get_absolute_url Method:                                   │
│  ┌─────────────────────────────────────────────────────┐   │
│  │      def get_absolute_url(self):                    │   │
│  │          return f"{self.post.get_absolute_url()}   │   │
│  │                   #comment-{self.id}"               │   │
│  │                                                    │   │
│  │      # Generates: /blog/my-post/#comment-1        │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Comment Moderation Flow:                                   │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  ┌─────────┐    ┌─────────┐    ┌─────────┐        │   │
│  │  │  User   │ ──▶│  Admin  │ ──▶│ Public  │        │   │
│  │  │  Posts  │    │  Approves│    │  Views  │        │   │
│  │  │ Comment │    │ Comment │    │ Comment │        │   │
│  │  └─────────┘    └─────────┘    └─────────┘        │   │
│  │                                                    │   │
│  │  is_approved=False → Private (author/admin only)  │   │
│  │  is_approved=True  → Public (visible to all)     │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 2.13: Understanding Model Field Types

**Reference Guide**

```
┌─────────────────────────────────────────────────────────────┐
│                 MODEL FIELD TYPES                            │
│                                                             │
│  Common Field Types:                                        │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Field          │ Python Type │ DB Column │ Use Case │   │
│  │  ───────────────────────────────────────────────────  │   │
│  │  CharField     │ str        │ VARCHAR   │ Short text│   │
│  │  TextField     │ str        │ TEXT      │ Long text │   │
│  │  IntegerField  │ int        │ INTEGER   │ Numbers   │   │
│  │  BooleanField  │ bool       │ BOOLEAN   │ Flags     │   │
│  │  DateField     │ date       │ DATE      │ Calendar  │   │
│  │  DateTimeField │ datetime   │ DATETIME  │ Timestamps│   │
│  │  EmailField    │ str        │ VARCHAR   │ Emails    │   │
│  │  URLField      │ str        │ VARCHAR   │ URLs      │   │
│  │  SlugField     │ str        │ VARCHAR   │ URLs      │   │
│  │  ImageField    │ str        │ VARCHAR   │ Images    │   │
│  │  ForeignKey    │ Model      │ FK        │ Relations │   │
│  │  ManyToManyField│ QuerySet  │ Through   │ Relations │   │
│  │  OneToOneField │ Model      │ FK+Unique │ Relations │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Field Parameters:                                          │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Parameter   │ Purpose                │ Example     │   │
│  │  ───────────────────────────────────────────────────  │   │
│  │  max_length  │ Max characters         │ 100         │   │
│  │  blank       │ Allow empty in forms   │ True        │   │
│  │  null        │ Allow NULL in DB       │ True        │   │
│  │  default     │ Default value          │ 'draft'     │   │
│  │  unique      │ Must be unique         │ True        │   │
│  │  choices     │ Limited options        │ STATUS_CHOICES│ │
│  │  help_text   │ Admin description      │ "Enter title"│ │
│  │  related_name│ Reverse relation name  │ 'posts'     │   │
│  │  on_delete   │ Delete behavior        │ CASCADE     │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 2.14: Foreign Key `on_delete` Options

**Understanding Delete Behavior**

```
┌─────────────────────────────────────────────────────────────┐
│              ON_DELETE OPTIONS                              │
│                                                             │
│  Options When Referenced Object is Deleted:                │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Option          │  Behavior                        │   │
│  │  ───────────────────────────────────────────────────  │   │
│  │  CASCADE         │  Delete related objects too      │   │
│  │  PROTECT         │  Prevent deletion if related     │   │
│  │                  │  objects exist                   │   │
│  │  SET_NULL        │  Set FK to NULL                  │   │
│  │  SET_DEFAULT     │  Set to default value            │   │
│  │  SET()           │  Set to specific value/function  │   │
│  │  DO_NOTHING      │  Don't handle (may cause errors) │   │
│  │  RESTRICT        │  Like PROTECT but handles        │   │
│  │                  │  circular dependencies           │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Examples in Our Models:                                    │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  # User → Post: CASCADE                            │   │
│  │  author = models.ForeignKey(User, on_delete=CASCADE)│   │
│  │  → If user is deleted, their posts are deleted      │   │
│  │                                                     │   │
│  │  # Category → Post: SET_NULL                       │   │
│  │  category = models.ForeignKey(Category, on_delete=SET_NULL)│ │
│  │  → If category is deleted, posts keep their data   │   │
│  │    but category becomes NULL                        │   │
│  │                                                     │   │
│  │  # Post → Comment: CASCADE                         │   │
│  │  post = models.ForeignKey(Post, on_delete=CASCADE) │   │
│  │  → If post is deleted, comments are deleted too    │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 2.15: Creating and Running Migrations

**The Migration Workflow**

```
┌─────────────────────────────────────────────────────────────┐
│                   MIGRATIONS                                │
│                                                             │
│  What are Migrations?                                       │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Version control for your database schema           │   │
│  │  Translate Python models to SQL tables              │   │
│  │  Track changes to your database structure           │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  The Workflow:                                              │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                                                     │   │
│  │  1. Make changes to models                         │   │
│  │     ┌─────────────────────────────────────────────┐ │   │
│  │     │  class Post(models.Model):                   │ │   │
│  │     │      title = models.CharField(...)          │ │   │
│  │     └─────────────────────────────────────────────┘ │   │
│  │                    ▼                                 │   │
│  │  2. Create migration file                          │   │
│  │     ┌─────────────────────────────────────────────┐ │   │
│  │     │  python manage.py makemigrations blog       │ │   │
│  │     └─────────────────────────────────────────────┘ │   │
│  │                    ▼                                 │   │
│  │  3. Apply migration to database                    │   │
│  │     ┌─────────────────────────────────────────────┐ │   │
│  │     │  python manage.py migrate                   │   │
│  │     └─────────────────────────────────────────────┘ │   │
│  │                                                    │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Commands:                                                  │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  # Install Pillow for image support                 │   │
│  │  uv pip install Pillow                              │   │
│  │                                                    │   │
│  │  # Create migration files                          │   │
│  │  python manage.py makemigrations blog              │   │
│  │                                                    │   │
│  │  # Apply migrations                                 │   │
│  │  python manage.py migrate                          │   │
│  │                                                    │   │
│  │  # Check migration status                          │   │
│  │  python manage.py showmigrations blog              │   │
│  │                                                    │   │
│  │  # See SQL Django will run                         │   │
│  │  python manage.py sqlmigrate blog 0001            │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 2.16: Migrations — Visual Explanation

**How Migrations Work**

```
┌─────────────────────────────────────────────────────────────┐
│              MIGRATIONS — VISUAL FLOW                       │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  models.py                  migrations/             │   │
│  │  ┌───────────────────┐     ┌─────────────────────┐ │   │
│  │  │ class Post:        │     │ 0001_initial.py     │ │   │
│  │  │   title = ...     │ ──► │ CreateModel('Post', │ │   │
│  │  │   content = ...   │     │   fields=[...])     │ │   │
│  │  │   status = ...    │     │                     │ │   │
│  │  └───────────────────┘     │ 0002_add_field.py  │ │   │
│  │                            │ AddField('Post',    │ │   │
│  │                            │   'is_featured')   │ │   │
│  │                            └─────────────────────┘ │   │
│  │                                      │               │   │
│  │                                      ▼               │   │
│  │                            ┌─────────────────────┐   │   │
│  │                            │  Database            │   │   │
│  │                            │  ┌─────────────────┐│   │   │
│  │                            │  │ posts table    ││   │   │
│  │                            │  │ id, title,     ││   │   │
│  │                            │  │ content,       ││   │   │
│  │                            │  │ status         ││   │   │
│  │                            │  └─────────────────┘│   │   │
│  │                            │  ┌─────────────────┐│   │   │
│  │                            │  │ django_migrations││   │   │
│  │                            │  │ (tracks applied) ││   │   │
│  │                            │  └─────────────────┘│   │   │
│  │                            └─────────────────────┘   │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Migration Files:                                           │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  • Located in blog/migrations/                     │   │
│  │  • Generated by makemigrations                      │   │
│  │  • Applied by migrate                              │   │
│  │  • Tracked in django_migrations table              │   │
│  │  • Should be committed to version control          │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 2.17: Setting Up Django Admin

**The Built-in Admin Interface**

```
┌─────────────────────────────────────────────────────────────┐
│                  DJANGO ADMIN                               │
│                                                             │
│  What is Django Admin?                                      │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Built-in content management interface              │   │
│  │  Automatically generated from your models           │   │
│  │  Full CRUD functionality out of the box             │   │
│  │  User authentication and permissions                │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Creating a Superuser:                                      │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  python manage.py createsuperuser                  │   │
│  │                                                    │   │
│  │  Username: admin                                   │   │
│  │  Email address: admin@example.com                  │   │
│  │  Password: (enter a secure password)               │   │
│  │  Password (again): (confirm)                       │   │
│  │  Superuser created successfully.                   │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Admin Interface Features:                                  │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  ✅ List views with search and filters              │   │
│  │  ✅ Create/update forms                            │   │
│  │  ✅ Delete confirmation                            │   │
│  │  ✅ User authentication                            │   │
│  │  ✅ Permission management                          │   │
│  │  ✅ Bulk actions                                   │   │
│  │  ✅ History tracking                               │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Access: http://127.0.0.1:8000/admin/                     │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 2.18: Registering Models with Admin

**Basic Admin Registration**

```
┌─────────────────────────────────────────────────────────────┐
│              ADMIN REGISTRATION                             │
│                                                             │
│  Register Models in `blog/admin.py`:                       │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  from django.contrib import admin                   │   │
│  │  from .models import Category, Tag, Post, Comment  │   │
│  │                                                    │   │
│  │  @admin.register(Category)                         │   │
│  │  class CategoryAdmin(admin.ModelAdmin):            │   │
│  │      list_display = ['name', 'slug', 'created_at'] │   │
│  │      search_fields = ['name', 'description']       │   │
│  │      prepopulated_fields = {'slug': ('name',)}     │   │
│  │                                                    │   │
│  │  @admin.register(Tag)                              │   │
│  │  class TagAdmin(admin.ModelAdmin):                 │   │
│  │      list_display = ['name', 'slug']              │   │
│  │      search_fields = ['name']                     │   │
│  │      prepopulated_fields = {'slug': ('name',)}     │   │
│  │                                                    │   │
│  │  @admin.register(Post)                            │   │
│  │  class PostAdmin(admin.ModelAdmin):                │   │
│  │      list_display = ['title', 'author', 'status',  │   │
│  │                      'created_at']                │   │
│  │      list_filter = ['status', 'category', 'author']│   │
│  │      search_fields = ['title', 'content']         │   │
│  │      prepopulated_fields = {'slug': ('title',)}   │   │
│  │                                                    │   │
│  │  @admin.register(Comment)                          │   │
│  │  class CommentAdmin(admin.ModelAdmin):             │   │
│  │      list_display = ['author', 'post', 'is_approved',│   │
│  │                      'created_at']                 │   │
│  │      list_filter = ['is_approved', 'created_at']   │   │
│  │      list_editable = ['is_approved']              │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 2.19: Admin Customization — PostAdmin

**Advanced Admin Configuration**

```
┌─────────────────────────────────────────────────────────────┐
│              POST ADMIN CUSTOMIZATION                       │
│                                                             │
│  Advanced Configuration:                                     │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  @admin.register(Post)                              │   │
│  │  class PostAdmin(admin.ModelAdmin):                 │   │
│  │      list_display = [                               │   │
│  │          'title', 'author', 'category', 'status',  │   │
│  │          'created_at', 'comment_count_display'     │   │
│  │      ]                                              │   │
│  │      list_filter = ['status', 'category', 'tags',   │   │
│  │                     'author', 'created_at']        │   │
│  │      search_fields = ['title', 'content',           │   │
│  │                      'author__username']           │   │
│  │      prepopulated_fields = {'slug': ('title',)}    │   │
│  │      list_editable = ['status']                    │   │
│  │      ordering = ['-created_at']                    │   │
│  │      readonly_fields = ['created_at', 'updated_at', │   │
│  │                        'published_at']             │   │
│  │                                                    │   │
│  │      fieldsets = (                                 │   │
│  │          ('Basic Information', {                   │   │
│  │              'fields': ('title', 'slug', 'author', │   │
│  │                         'category')                │   │
│  │          }),                                       │   │
│  │          ('Content', {                             │   │
│  │              'fields': ('content', 'excerpt',      │   │
│  │                         'featured_image')          │   │
│  │          }),                                       │   │
│  │          ('Taxonomy', {                            │   │
│  │              'fields': ('tags',),                  │   │
│  │              'classes': ('collapse',)              │   │
│  │          }),                                       │   │
│  │          ('SEO', {                                 │   │
│  │              'fields': ('meta_description',        │   │
│  │                         'meta_keywords'),          │   │
│  │              'classes': ('collapse',)              │   │
│  │          }),                                       │   │
│  │      )                                             │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 2.20: Admin Actions

**Bulk Operations in Admin**

```
┌─────────────────────────────────────────────────────────────┐
│                ADMIN ACTIONS                                │
│                                                             │
│  Define Custom Bulk Actions:                                │
│  ┌─────────────────────────────────────────────────────┐   │
│  │      actions = ['make_published', 'make_draft',    │   │
│  │                  'make_archived']                  │   │
│  │                                                    │   │
│  │      def make_published(self, request, queryset):  │   │
│  │          """Bulk publish selected posts."""        │   │
│  │          updated = queryset.update(status='published')│  │
│  │          self.message_user(request,                │   │
│  │              f'{updated} posts were published.')   │   │
│  │      make_published.short_description =            │   │
│  │          "Publish selected posts"                  │   │
│  │                                                    │   │
│  │      def make_draft(self, request, queryset):      │   │
│  │          """Bulk set selected posts to draft."""   │   │
│  │          updated = queryset.update(status='draft') │   │
│  │          self.message_user(request,                │   │
│  │              f'{updated} posts were set to draft.')│   │
│  │      make_draft.short_description =                │   │
│  │          "Set selected posts to draft"             │   │
│  │                                                    │   │
│  │      def make_archived(self, request, queryset):   │   │
│  │          """Bulk archive selected posts."""        │   │
│  │          updated = queryset.update(status='archived')│  │
│  │          self.message_user(request,                │   │
│  │              f'{updated} posts were archived.')    │   │
│  │      make_archived.short_description =             │   │
│  │          "Archive selected posts"                  │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  How Actions Appear in Admin:                               │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  [✓] Title   │  Author  │  Status   │  Created    │   │
│  │  [✓] Post 1  │  John    │  Draft    │  2026-03-15 │   │
│  │  [✓] Post 2  │  Jane    │  Published│  2026-03-14 │   │
│  │  [✓] Post 3  │  Bob     │  Draft    │  2026-03-13 │   │
│  │                                                    │   │
│  │  Action: [Publish selected posts ▼] [Go]          │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 2.21: Admin Custom Methods

**Adding Custom Methods to Admin**

```
┌─────────────────────────────────────────────────────────────┐
│              ADMIN CUSTOM METHODS                           │
│                                                             │
│  Custom Methods in Admin:                                   │
│  ┌─────────────────────────────────────────────────────┐   │
│  │      def comment_count_display(self, obj):          │   │
│  │          """Display comment count with link."""     │   │
│  │          count = obj.get_comment_count()            │   │
│  │          return format_html(                        │   │
│  │              '<a href="/admin/blog/comment/?'       │   │
│  │              'post__id__exact={}">{}</a>',          │   │
│  │              obj.id, count                          │   │
│  │          )                                          │   │
│  │      comment_count_display.short_description =       │   │
│  │          "Comments"                                 │   │
│  │                                                    │   │
│  │      def post_count(self, obj):                    │   │
│  │          """Display number of posts in category."""│   │
│  │          return obj.posts.count()                  │   │
│  │      post_count.short_description =                │   │
│  │          "Number of Posts"                         │   │
│  │                                                    │   │
│  │      def content_preview(self, obj):               │   │
│  │          """Display a preview of comment content."""│   │
│  │          if len(obj.content) > 50:                 │   │
│  │              return obj.content[:50] + '...'       │   │
│  │          return obj.content                        │   │
│  │      content_preview.short_description =           │   │
│  │          "Comment Preview"                         │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Benefits of Custom Methods:                                │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  ✅ Display computed values (counts, previews)      │   │
│  │  ✅ Add interactive links to related data           │   │
│  │  ✅ Create human-readable representations           │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 2.22: Using the Django ORM

**Object-Relational Mapping in Action**

```
┌─────────────────────────────────────────────────────────────┐
│                   DJANGO ORM                                │
│                                                             │
│  What is the ORM?                                           │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Object-Relational Mapping                          │   │
│  │  Translates Python code to SQL                     │   │
│  │  Database-agnostic (works with SQLite, PostgreSQL) │   │
│  │  Built-in SQL injection protection                 │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Python → SQL Translation:                                  │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Python Code               →  SQL                   │   │
│  │  ───────────────────────────────────────────────────  │   │
│  │  Post.objects.filter(     →  SELECT *               │   │
│  │      status='published'   →  FROM blog_post         │   │
│  │  )                        →  WHERE status='published'│   │
│  │                                                    │   │
│  │  Post.objects.get(id=1)   →  SELECT *              │   │
│  │                           →  FROM blog_post        │   │
│  │                           →  WHERE id=1            │   │
│  │                                                    │   │
│  │  Post.objects.create(     →  INSERT INTO           │   │
│  │      title='New Post'     →  blog_post (title, ...)│   │
│  │  )                        →  VALUES ('New Post',...)│   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ORM Shell:                                                 │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  python manage.py shell                             │   │
│  │  >>> from blog.models import Post                   │   │
│  │  >>> Post.objects.count()                          │   │
│  │  0                                                  │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 2.23: ORM — Create and Read Operations

**CRUD Operations with the ORM**

```
┌─────────────────────────────────────────────────────────────┐
│              ORM — CREATE AND READ                          │
│                                                             │
│  CREATE Operations:                                         │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  # Method 1: create()                               │   │
│  │  post = Post.objects.create(                        │   │
│  │      title='My First Post',                         │   │
│  │      content='Content...',                          │   │
│  │      author=user,                                   │   │
│  │      status='published'                             │   │
│  │  )                                                  │   │
│  │                                                    │   │
│  │  # Method 2: save()                                │   │
│  │  post = Post(title='My First Post',               │   │
│  │               content='Content...')                │   │
│  │  post.author = user                                │   │
│  │  post.save()                                       │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  READ Operations:                                           │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  # Get all                                          │   │
│  │  all_posts = Post.objects.all()                    │   │
│  │                                                    │   │
│  │  # Filter                                           │   │
│  │  published_posts = Post.objects.filter(             │   │
│  │      status='published'                            │   │
│  │  )                                                  │   │
│  │                                                    │   │
│  │  # Get single                                       │   │
│  │  post = Post.objects.get(slug='my-first-post')     │   │
│  │                                                    │   │
│  │  # Get first matching                              │   │
│  │  post = Post.objects.filter(status='published').first()│ │
│  │                                                    │   │
│  │  # Count                                            │   │
│  │  count = Post.objects.count()                      │   │
│  │                                                    │   │
│  │  # Check if exists                                 │   │
│  │  has_posts = Post.objects.filter(                  │   │
│  │      status='published'                            │   │
│  │  ).exists()                                        │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 2.24: ORM — Update and Delete Operations

**CRUD Operations Continued**

```
┌─────────────────────────────────────────────────────────────┐
│              ORM — UPDATE AND DELETE                        │
│                                                             │
│  UPDATE Operations:                                         │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  # Method 1: Update and save                       │   │
│  │  post = Post.objects.get(id=1)                     │   │
│  │  post.title = 'Updated Title'                      │   │
│  │  post.save()                                       │   │
│  │                                                    │   │
│  │  # Method 2: Bulk update                           │   │
│  │  Post.objects.filter(status='draft').update(       │   │
│  │      status='published'                            │   │
│  │  )                                                  │   │
│  │                                                    │   │
│  │  # Method 3: Update with F expressions             │   │
│  │  from django.db.models import F                    │   │
│  │  Post.objects.all().update(views=F('views') + 1)   │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  DELETE Operations:                                         │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  # Delete single                                    │   │
│  │  post = Post.objects.get(id=1)                     │   │
│  │  post.delete()                                      │   │
│  │                                                    │   │
│  │  # Bulk delete                                      │   │
│  │  Post.objects.filter(status='archived').delete()    │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Important Notes:                                           │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  ✅ delete() returns (deleted_count, {model: count})│   │
│  │  ✅ Cascade deletion follows on_delete rules        │   │
│  │  ⚠️ Bulk delete doesn't call model.delete() method │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 2.25: ORM — Advanced Queries

**Complex Queries with the ORM**

```
┌─────────────────────────────────────────────────────────────┐
│               ORM — ADVANCED QUERIES                        │
│                                                             │
│  Chain Filters:                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  recent_posts = Post.objects.filter(                │   │
│  │      status='published',                            │   │
│  │      category=category                              │   │
│  │  ).order_by('-created_at')[:5]                     │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Related Object Queries:                                    │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  # Using related_name                              │   │
│  │  user_posts = user.blog_posts.all()                │   │
│  │                                                    │   │
│  │  # Using double underscore                         │   │
│  │  posts_by_user = Post.objects.filter(              │   │
│  │      author__username='admin'                     │   │
│  │  )                                                  │   │
│  │  posts_in_category = Post.objects.filter(          │   │
│  │      category__name='Technology'                   │   │
│  │  )                                                  │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Q Objects — OR Conditions:                                 │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  from django.db.models import Q                    │   │
│  │                                                    │   │
│  │  posts = Post.objects.filter(                      │   │
│  │      Q(title__icontains='django') |               │   │
│  │      Q(content__icontains='django')                │   │
│  │  )                                                  │   │
│  │                                                    │   │
│  │  # Complex Q object combinations                  │   │
│  │  posts = Post.objects.filter(                      │   │
│  │      Q(status='published') &                       │   │
│  │      (Q(title__icontains='django') |              │   │
│  │       Q(content__icontains='django'))              │   │
│  │  )                                                  │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 2.26: ORM — Query Optimization

**Solving the N+1 Problem**

```
┌─────────────────────────────────────────────────────────────┐
│              ORM — QUERY OPTIMIZATION                       │
│                                                             │
│  The N+1 Query Problem:                                     │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  # Bad: N+1 queries                                 │   │
│  │  posts = Post.objects.all()                         │   │
│  │  for post in posts:                                 │   │
│  │      print(post.author.username)  # One query per post!│ │
│  │                                                    │   │
│  │  # If you have 100 posts:                          │   │
│  │  # 1 + 100 = 101 queries!                         │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Solution 1: select_related (Foreign Keys)                 │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  # Good: One query with JOIN                        │   │
│  │  posts = Post.objects.select_related(               │   │
│  │      'author', 'category'                          │   │
│  │  ).all()                                            │   │
│  │  for post in posts:                                 │   │
│  │      print(post.author.username)  # Already loaded! │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Solution 2: prefetch_related (Many-to-Many)               │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  # Good: Two queries (posts + tags)                 │   │
│  │  posts = Post.objects.prefetch_related('tags').all()│   │
│  │  for post in posts:                                 │   │
│  │      print(post.tags.all())  # Already loaded!     │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Solution 3: only() and defer()                            │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  # Only load specific fields                        │   │
│  │  posts = Post.objects.only('title', 'slug')        │   │
│  │                                                    │   │
│  │  # Defer loading large fields                       │   │
│  │  posts = Post.objects.defer('content', 'excerpt')  │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 2.27: Updating Views to Use the Database

**From Hardcoded Data to Database Queries**

```
┌─────────────────────────────────────────────────────────────┐
│              UPDATING VIEWS — PART 1                        │
│                                                             │
│  Home View — Before:                                        │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  def home(request):                                │   │
│  │      context = {                                   │   │
│  │          'recent_posts': [],  # Hardcoded empty    │   │
│  │          'categories': [],   # Hardcoded empty    │   │
│  │      }                                              │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Home View — After:                                         │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  from django.db.models import Count, Q              │   │
│  │                                                    │   │
│  │  def home(request):                                │   │
│  │      recent_posts = Post.objects.filter(            │   │
│  │          status=Post.Status.PUBLISHED,             │   │
│  │          published_at__lte=timezone.now()          │   │
│  │      ).order_by('-published_at')[:5]              │   │
│  │                                                    │   │
│  │      categories = Category.objects.annotate(       │   │
│  │          post_count=Count('posts', filter=Q(       │   │
│  │              posts__status=Post.Status.PUBLISHED   │   │
│  │          ))                                        │   │
│  │      ).filter(post_count__gt=0)                   │   │
│  │                                                    │   │
│  │      context = {                                   │   │
│  │          'recent_posts': recent_posts,             │   │
│  │          'categories': categories,                 │   │
│  │          'year': timezone.now().year,              │   │
│  │      }                                              │   │
│  │      return render(request, 'blog/home.html', context)│ │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 2.28: Updating Views — Blog List and Detail

**View Updates Continued**

```
┌─────────────────────────────────────────────────────────────┐
│              UPDATING VIEWS — PART 2                        │
│                                                             │
│  Blog List View:                                            │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  def blog_list(request):                            │   │
│  │      posts = Post.objects.filter(                   │   │
│  │          status=Post.Status.PUBLISHED,              │   │
│  │          published_at__lte=timezone.now()           │   │
│  │      ).select_related('author', 'category')        │   │
│  │                                                    │   │
│  │      context = {                                   │   │
│  │          'page_title': 'Blog Posts',               │   │
│  │          'posts': posts,                           │   │
│  │          'year': timezone.now().year,              │   │
│  │      }                                              │   │
│  │      return render(request, 'blog/blog_list.html', context)│ │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Post Detail View:                                          │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  from django.shortcuts import get_object_or_404     │   │
│  │                                                    │   │
│  │  def post_detail(request, slug):                   │   │
│  │      post = get_object_or_404(                     │   │
│  │          Post.objects.select_related('author',     │   │
│  │              'category').prefetch_related('tags',  │   │
│  │              'comments'),                          │   │
│  │          slug=slug,                                │   │
│  │          status=Post.Status.PUBLISHED              │   │
│  │      )                                              │   │
│  │                                                    │   │
│  │      recent_posts = Post.objects.filter(           │   │
│  │          status=Post.Status.PUBLISHED              │   │
│  │      ).exclude(id=post.id).order_by('-published_at')[:5]│ │
│  │                                                    │   │
│  │      context = {                                   │   │
│  │          'post': post,                             │   │
│  │          'recent_posts': recent_posts,             │   │
│  │          'year': timezone.now().year,              │   │
│  │      }                                              │   │
│  │      return render(request, 'blog/post_detail.html', context)│ │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 2.29: Updating Views — Category and Tag Detail

**View Updates Completed**

```
┌─────────────────────────────────────────────────────────────┐
│              UPDATING VIEWS — PART 3                        │
│                                                             │
│  Category Detail View:                                      │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  def category_detail(request, slug):               │   │
│  │      category = get_object_or_404(Category, slug=slug)│ │
│  │                                                    │   │
│  │      posts = Post.objects.filter(                  │   │
│  │          category=category,                        │   │
│  │          status=Post.Status.PUBLISHED,             │   │
│  │          published_at__lte=timezone.now()          │   │
│  │      ).select_related('author').order_by('-published_at')│ │
│  │                                                    │   │
│  │      context = {                                   │   │
│  │          'category': category,                     │   │
│  │          'posts': posts,                           │   │
│  │          'year': timezone.now().year,              │   │
│  │      }                                              │   │
│  │      return render(request, 'blog/category_detail.html', context)│ │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Tag Detail View:                                           │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  def tag_detail(request, slug):                    │   │
│  │      tag = get_object_or_404(Tag, slug=slug)       │   │
│  │                                                    │   │
│  │      posts = Post.objects.filter(                  │   │
│  │          tags=tag,                                 │   │
│  │          status=Post.Status.PUBLISHED,             │   │
│  │          published_at__lte=timezone.now()          │   │
│  │      ).select_related('author', 'category').       │   │
│  │       order_by('-published_at')                   │   │
│  │                                                    │   │
│  │      context = {                                   │   │
│  │          'tag': tag,                               │   │
│  │          'posts': posts,                           │   │
│  │          'year': timezone.now().year,              │   │
│  │      }                                              │   │
│  │      return render(request, 'blog/tag_detail.html', context)│ │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 2.30: Updating Templates for Database Content

**Displaying Real Data in Templates**

```
┌─────────────────────────────────────────────────────────────┐
│              UPDATING TEMPLATES — PART 1                    │
│                                                             │
│  Home Template — Recent Posts Section:                      │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  <h2>Recent Posts</h2>                              │   │
│  │                                                    │   │
│  │  {% if recent_posts %}                             │   │
│  │      {% for post in recent_posts %}                │   │
│  │          <div style="margin-bottom: 2rem;">        │   │
│  │              <h3>                                  │   │
│  │                  <a href="{{ post.get_absolute_url }}">│   │
│  │                      {{ post.title }}              │   │
│  │                  </a>                              │   │
│  │              </h3>                                 │   │
│  │              <p style="color: #7f8c8d;">           │   │
│  │                  By {{ post.author.get_full_name   │   │
│  │                  |default:post.author.username }}  │   │
│  │                  on {{ post.published_at|date:"F j, Y" }}│  │
│  │                  {% if post.category %}            │   │
│  │                      in <a href="{% url 'blog:category_detail' │ │
│  │                          post.category.slug %}">   │   │
│  │                          {{ post.category.name }}  │   │
│  │                      </a>                          │   │
│  │                  {% endif %}                       │   │
│  │              </p>                                  │   │
│  │              <p>{{ post.excerpt|truncatewords:30 }}</p>│  │
│  │              <a href="{{ post.get_absolute_url }}"> │   │
│  │                  Read more →                      │   │
│  │              </a>                                  │   │
│  │          </div>                                    │   │
│  │      {% endfor %}                                  │   │
│  │  {% else %}                                        │   │
│  │      <p>No blog posts available yet.</p>           │   │
│  │  {% endif %}                                       │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 2.31: Updating Templates — Categories Sidebar

**Displaying Categories with Post Counts**

```
┌─────────────────────────────────────────────────────────────┐
│              UPDATING TEMPLATES — PART 2                    │
│                                                             │
│  Categories Sidebar:                                        │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  <div style="background: #f8f9fa; padding: 1.5rem; │   │
│  │       border-radius: 8px;">                         │   │
│  │      <h3>Categories</h3>                            │   │
│  │                                                    │   │
│  │      {% if categories %}                           │   │
│  │          <ul style="list-style: none; padding: 0;">│   │
│  │              {% for category in categories %}      │   │
│  │                  <li style="margin-bottom: 0.5rem;">│  │
│  │                      <a href="{% url 'blog:category_detail' │ │
│  │                          category.slug %}"         │   │
│  │                         style="color: #2c3e50;     │   │
│  │                         text-decoration: none;">   │   │
│  │                          {{ category.name }}       │   │
│  │                          <span style="color: #7f8c8d; │   │
│  │                              font-size: 0.9rem;">  │   │
│  │                              ({{ category.post_count }}) │  │
│  │                          </span>                   │   │
│  │                      </a>                          │   │
│  │                  </li>                             │   │
│  │              {% endfor %}                          │   │
│  │          </ul>                                     │   │
│  │      {% else %}                                    │   │
│  │          <p>No categories yet.</p>                 │   │
│  │      {% endif %}                                   │   │
│  │  </div>                                            │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Key Features:                                              │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  ✅ Categories with post counts                     │   │
│  │  ✅ Links to category detail pages                  │   │
│  │  ✅ Clean design with proper spacing                │   │
│  │  ✅ Graceful fallback when no categories exist      │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 2.32: Creating Post Detail Template

**Full Post Display with Comments**

```
┌─────────────────────────────────────────────────────────────┐
│              POST DETAIL TEMPLATE                           │
│                                                             │
│  Full Template:                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  {% extends 'blog/base.html' %}                     │   │
│  │                                                    │   │
│  │  {% block title %}{{ post.title }} — Django Blog{% endblock %}│ │
│  │                                                    │   │
│  │  {% block content %}                               │   │
│  │  <div class="page-header">                         │   │
│  │      <h1>{{ post.title }}</h1>                     │   │
│  │      <p class="subtitle">                          │   │
│  │          By {{ post.author.get_full_name           │   │
│  │          |default:post.author.username }}          │   │
│  │          on {{ post.published_at|date:"F j, Y" }}  │   │
│  │          {% if post.category %}                    │   │
│  │              in <a href="{% url 'blog:category_detail' │   │
│  │                  post.category.slug %}">           │   │
│  │                  {{ post.category.name }}          │   │
│  │              </a>                                  │   │
│  │          {% endif %}                               │   │
│  │      </p>                                          │   │
│  │      {% if post.tags.all %}                        │   │
│  │          <p>                                       │   │
│  │              Tags:                                 │   │
│  │              {% for tag in post.tags.all %}        │   │
│  │                  <a href="{% url 'blog:tag_detail' │   │
│  │                      tag.slug %}"                  │   │
│  │                     style="background: #ecf0f1;   │   │
│  │                     padding: 0.2rem 0.6rem;       │   │
│  │                     border-radius: 12px;">        │   │
│  │                      {{ tag.name }}               │   │
│  │                  </a>                             │   │
│  │              {% endfor %}                          │   │
│  │          </p>                                     │   │
│  │      {% endif %}                                  │   │
│  │  </div>                                            │   │
│  │                                                    │   │
│  │  <div class="content">                             │   │
│  │      {% if post.featured_image %}                 │   │
│  │          <div style="margin-bottom: 2rem;">       │   │
│  │              <img src="{{ post.featured_image.url }}" │   │
│  │                   alt="{{ post.title }}"          │   │
│  │                   style="max-width: 100%;">       │   │
│  │          </div>                                   │   │
│  │      {% endif %}                                  │   │
│  │                                                    │   │
│  │      <div style="line-height: 1.8;">              │   │
│  │          {{ post.content|linebreaks }}            │   │
│  │      </div>                                       │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 2.33: Post Detail — Comments Section

**Displaying and Managing Comments**

```
┌─────────────────────────────────────────────────────────────┐
│              POST DETAIL — COMMENTS                         │
│                                                             │
│  Comments Section:                                          │
│  ┌─────────────────────────────────────────────────────┐   │
│  │      <!-- Comments section -->                      │   │
│  │      <div style="margin-top: 3rem; padding-top: 2rem; │   │
│  │           border-top: 2px solid #eee;">             │   │
│  │          <h3>Comments</h3>                          │   │
│  │                                                    │   │
│  │          {% with comments=post.comments.filter %}  │   │
│  │              {% for comment in comments %}         │   │
│  │                  <div style="background: #f8f9fa; │   │
│  │                       padding: 1rem;              │   │
│  │                       border-radius: 8px;          │   │
│  │                       margin-bottom: 1rem;">       │   │
│  │                      <p>                           │   │
│  │                          <strong>                  │   │
│  │                              {{ comment.author.get_full_name │   │
│  │                              |default:comment.author.username }} │   │
│  │                          </strong>                 │   │
│  │                          <span style="color: #7f8c8d;"> │   │
│  │                              — {{ comment.created_at|date:"F j, Y g:i a" }} │   │
│  │                          </span>                   │   │
│  │                      </p>                          │   │
│  │                      <p>{{ comment.content|linebreaks }}</p> │   │
│  │                  </div>                            │   │
│  │              {% empty %}                           │   │
│  │                  <p style="color: #7f8c8d;">       │   │
│  │                      No comments yet. Be the first!│   │
│  │                  </p>                              │   │
│  │              {% endfor %}                          │   │
│  │          {% endwith %}                             │   │
│  │      </div>                                       │   │
│  │                                                    │   │
│  │      <!-- Back link -->                            │   │
│  │      <div style="margin-top: 1.5rem;">            │   │
│  │          <a href="{% url 'blog:blog_list' %}">     │   │
│  │              ← Back to all posts                  │   │
│  │          </a>                                     │   │
│  │      </div>                                       │   │
│  │  </div>                                            │   │
│  │  {% endblock %}                                    │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 2.34: Category and Tag Detail Templates

**Listing Posts by Category and Tag**

```
┌─────────────────────────────────────────────────────────────┐
│              CATEGORY AND TAG TEMPLATES                     │
│                                                             │
│  Category Detail Template:                                  │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  {% extends 'blog/base.html' %}                     │   │
│  │                                                    │   │
│  │  {% block title %}{{ category.name }} — Django Blog{% endblock %}│ │
│  │                                                    │   │
│  │  {% block content %}                               │   │
│  │  <div class="page-header">                         │   │
│  │      <h1>{{ category.name }}</h1>                  │   │
│  │      <p class="subtitle">                          │   │
│  │          {{ category.description|default:"Posts in this category" }} │   │
│  │      </p>                                          │   │
│  │  </div>                                            │   │
│  │                                                    │   │
│  │  <div class="content">                             │   │
│  │      {% if posts %}                                │   │
│  │          {% for post in posts %}                   │   │
│  │              <div style="margin-bottom: 2rem;">   │   │
│  │                  <h2>                             │   │
│  │                      <a href="{{ post.get_absolute_url }}">│   │
│  │                          {{ post.title }}         │   │
│  │                      </a>                         │   │
│  │                  </h2>                            │   │
│  │                  <p style="color: #7f8c8d;">      │   │
│  │                      By {{ post.author.get_full_name │   │
│  │                      |default:post.author.username }} │   │
│  │                      on {{ post.published_at|date:"F j, Y" }} │   │
│  │                  </p>                             │   │
│  │                  <p>{{ post.excerpt|truncatewords:30 }}</p> │   │
│  │              </div>                               │   │
│  │          {% endfor %}                             │   │
│  │      {% else %}                                   │   │
│  │          <p>No posts in this category yet.</p>    │   │
│  │      {% endif %}                                  │   │
│  │  </div>                                            │   │
│  │                                                    │   │
│  │  <a href="{% url 'blog:blog_list' %}">             │   │
│  │      ← Back to all posts                          │   │
│  │  </a>                                              │   │
│  │  {% endblock %}                                    │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 2.35: Updating URLs for New Views

**Adding Category and Tag Detail URLs**

```
┌─────────────────────────────────────────────────────────────┐
│              UPDATING URLS                                  │
│                                                             │
│  Project URLs (`config/urls.py`):                          │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  from django.contrib import admin                   │   │
│  │  from django.urls import path, include              │   │
│  │  from django.conf import settings                   │   │
│  │  from django.conf.urls.static import static         │   │
│  │                                                    │   │
│  │  urlpatterns = [                                    │   │
│  │      path('admin/', admin.site.urls),              │   │
│  │      path('', include('blog.urls')),               │   │
│  │  ]                                                  │   │
│  │                                                    │   │
│  │  # Serve media files in development                │   │
│  │  if settings.DEBUG:                                │   │
│  │      urlpatterns += static(settings.MEDIA_URL,     │   │
│  │                              document_root=settings.MEDIA_ROOT)│ │
│  │      urlpatterns += static(settings.STATIC_URL,    │   │
│  │                              document_root=settings.STATIC_ROOT)│ │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  App URLs (`blog/urls.py`):                                │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  from django.urls import path                       │   │
│  │  from . import views                                │   │
│  │                                                    │   │
│  │  app_name = 'blog'                                 │   │
│  │                                                    │   │
│  │  urlpatterns = [                                    │   │
│  │      path('', views.home, name='home'),            │   │
│  │      path('about/', views.about, name='about'),    │   │
│  │      path('blog/', views.blog_list, name='blog_list'),│   │
│  │      path('blog/<slug:slug>/', views.post_detail,  │   │
│  │           name='post_detail'),                     │   │
│  │      path('category/<slug:slug>/', views.category_detail,│   │
│  │           name='category_detail'),                 │   │
│  │      path('tag/<slug:slug>/', views.tag_detail,    │   │
│  │           name='tag_detail'),                      │   │
│  │  ]                                                  │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 2.36: Verification — Testing the Database Integration

**Comprehensive Verification Checklist**

```
┌─────────────────────────────────────────────────────────────┐
│              VERIFICATION CHECKLIST                         │
│                                                             │
│  Step 1: Create Test Data                                   │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  1. Visit http://127.0.0.1:8000/admin/              │   │
│  │  2. Log in with superuser credentials               │   │
│  │  3. Create:                                         │   │
│  │     • Category (e.g., "Technology")                 │   │
│  │     • Tags (e.g., "Django", "Python")              │   │
│  │     • 3-5 blog posts with various statuses          │   │
│  │     • Publish at least 2 posts                     │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Step 2: Visit the Website                                 │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  URL                    │  Expected Content          │   │
│  │  ──────────────────────────────────────────────────  │   │
│  │  /                      │  Recent posts, categories │   │
│  │  /blog/                 │  All published posts      │   │
│  │  /blog/your-post-slug/  │  Full post with comments  │   │
│  │  /category/technology/  │  Posts in that category   │   │
│  │  /tag/django/           │  Posts with that tag      │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Step 3: Verify Data Display                               │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  ✅ Posts show titles, authors, dates, excerpts     │   │
│  │  ✅ Categories appear in sidebar with counts        │   │
│  │  ✅ Tags appear on posts                           │   │
│  │  ✅ Navigation works between pages                  │   │
│  │  ✅ Comments section appears on post detail         │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 2.37: Common ORM Methods — Quick Reference

**Essential ORM Methods Summary**

```
┌─────────────────────────────────────────────────────────────┐
│              ORM METHODS — QUICK REFERENCE                  │
│                                                             │
│  Retrieval Methods:                                         │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Method            │  Purpose                       │   │
│  │  ──────────────────────────────────────────────────  │   │
│  │  all()             │  Get all records               │   │
│  │  filter()          │  Filter records                │   │
│  │  exclude()         │  Exclude records               │   │
│  │  get()             │  Get single record             │   │
│  │  first()           │  Get first record              │   │
│  │  last()            │  Get last record               │   │
│  │  count()           │  Count records                 │   │
│  │  exists()          │  Check if records exist        │   │
│  │  order_by()        │  Sort results                  │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Modification Methods:                                      │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Method            │  Purpose                       │   │
│  │  ──────────────────────────────────────────────────  │   │
│  │  create()          │  Create and save               │   │
│  │  update()          │  Bulk update                   │   │
│  │  delete()          │  Bulk delete                   │   │
│  │  save()            │  Save instance                 │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Optimization Methods:                                      │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Method            │  Purpose                       │   │
│  │  ──────────────────────────────────────────────────  │   │
│  │  select_related()  │  Join foreign keys             │   │
│  │  prefetch_related()│  Prefetch many-to-many         │   │
│  │  only()            │  Load only specific fields     │   │
│  │  defer()           │  Defer loading fields          │   │
│  │  annotate()        │  Add aggregate fields          │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 2.38: Common Errors and Troubleshooting

**Quick Fixes for Common Issues**

```
┌─────────────────────────────────────────────────────────────┐
│              COMMON ERRORS AND FIXES                        │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Error: "OperationalError: no such table: blog_post"│   │
│  │  Cause: Migrations not applied                      │   │
│  │  Fix: python manage.py migrate                      │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Error: "Column 'category_id' cannot be null"       │   │
│  │  Cause: SET_NULL requires null=True                 │   │
│  │  Fix: Add null=True, blank=True to field            │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Error: "Duplicate entry for slug"                  │   │
│  │  Cause: Slug already exists in database              │   │
│  │  Fix: Use a unique slug or modify slug generation   │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Error: "Cannot add foreign key constraint"         │   │
│  │  Cause: Referenced table or column doesn't exist    │   │
│  │  Fix: Ensure migrations run in correct order        │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Error: "ImageField requires Pillow"                │   │
│  │  Cause: Pillow not installed                        │   │
│  │  Fix: uv pip install Pillow                         │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 2.39: What You've Learned in Part 2

**Skills Acquired and What You've Built**

```
┌─────────────────────────────────────────────────────────────┐
│              WHAT YOU'VE LEARNED — PART 2                  │
│                                                             │
│  ✅ Skills Acquired:                                        │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  • Designing database models with relationships     │   │
│  │  • Understanding Django field types and parameters  │   │
│  │  • Creating and applying migrations                 │   │
│  │  • Using Django's ORM for CRUD operations          │   │
│  │  • Configuring Django Admin for data management     │   │
│  │  • Optimizing queries with select_related and       │   │
│  │    prefetch_related                                 │   │
│  │  • Displaying database content in templates         │   │
│  │  • Creating detail views with get_object_or_404    │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ✅ What You've Built:                                      │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  • Complete database schema for a blog              │   │
│  │  • Admin interface for content management           │   │
│  │  • Dynamic views that query the database            │   │
│  │  • Templates that display real data                 │   │
│  │  • Category, tag, and post detail pages             │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  🎯 Ready for Part 3:                                       │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  In Part 3, we'll build CRUD operations so users    │   │
│  │  can create, edit, and delete posts!               │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 2.40: Challenges — Extend the Database

**Practice Exercises to Reinforce Learning**

```
┌─────────────────────────────────────────────────────────────┐
│                CHALLENGES — PART 2                          │
│                                                             │
│  Challenge 1: Add "Featured" Boolean Field                │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  # Add to Post model                               │   │
│  │  is_featured = models.BooleanField(default=False)  │   │
│  │                                                    │   │
│  │  # Update admin                                    │   │
│  │  list_display = [..., 'is_featured']              │   │
│  │  list_filter = [..., 'is_featured']               │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Challenge 2: Add Author Bio (Profile Model)              │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  class Profile(models.Model):                       │   │
│  │      user = models.OneToOneField(User)              │   │
│  │      bio = models.TextField(max_length=500, blank=True)│  │
│  │      website = models.URLField(blank=True)          │   │
│  │      location = models.CharField(max_length=100,    │   │
│  │                  blank=True)                        │   │
│  │      avatar = models.ImageField(upload_to='avatars/',│   │
│  │                 blank=True)                         │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Challenge 3: Add Comment Approval Workflow               │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  # Add to Comment model                            │   │
│  │  moderated_at = models.DateTimeField(null=True,    │   │
│  │                                       blank=True)   │   │
│  │                                                    │   │
│  │  # Auto-set when is_approved changes               │   │
│  │  def save(self, *args, **kwargs):                 │   │
│  │      if self.pk:                                   │   │
│  │          old = Comment.objects.get(pk=self.pk)     │   │
│  │          if old.is_approved != self.is_approved and│   │
│  │             self.is_approved:                      │   │
│  │              self.moderated_at = timezone.now()    │   │
│  │      super().save(*args, **kwargs)                │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 2.41: Proceed to Part 3

**Preview of What's Coming**

```
┌─────────────────────────────────────────────────────────────┐
│                COMING UP IN PART 3                          │
│                                                             │
│  📝 Templates, Static Files, Forms, and CRUD               │
│                                                             │
│  What We'll Build:                                          │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Complete CRUD operations for blog posts:           │   │
│  │  • Create new posts via web form                    │   │
│  │  • Read and view posts                              │   │
│  │  • Update/edit existing posts                       │   │
│  │  • Delete posts with confirmation                   │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  What We'll Learn:                                          │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  • Django Forms and ModelForms                     │   │
│  │  • Handling GET and POST requests                  │   │
│  │  • CSRF protection                                  │   │
│  │  • File uploads                                     │   │
│  │  • User authentication in views                    │   │
│  │  • Messages framework                               │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Preview:                                                   │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  ┌─────────────────────────────────────────────────┐│   │
│  │  │  Create Post                                   ││   │
│  │  │  ┌─────────────────────────────────────────────┐││   │
│  │  │  │  Title: [_____________________]            │││   │
│  │  │  │  Content: [_____________________]          │││   │
│  │  │  │  Category: [Select ▼]                     │││   │
│  │  │  │  Status: [Published ▼]                    │││   │
│  │  │  │  [Create Post] [Cancel]                   │││   │
│  │  │  └─────────────────────────────────────────────┘││   │
│  │  └─────────────────────────────────────────────────┘│   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Let's build CRUD operations! 📝                          │
└─────────────────────────────────────────────────────────────┘
```

---

# PART 3: TEMPLATES, STATIC FILES, FORMS, AND CRUD

---

## Slide 3.1: Part 3 Introduction

**Learning Objectives**

```
┌─────────────────────────────────────────────────────────────┐
│                    PART 3 OVERVIEW                          │
│                                                             │
│  🎯 Learning Objectives:                                    │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  ✅ Build user-facing forms with Django Forms      │   │
│  │  ✅ Handle file uploads safely                     │   │
│  │  ✅ Implement full CRUD operations                  │   │
│  │  ✅ Secure forms with CSRF protection              │   │
│  │  ✅ Use the messages framework for user feedback   │   │
│  │  ✅ Control access with @login_required            │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  🏗️ What We'll Build:                                      │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  • Post creation form with validation               │   │
│  │  • Post editing with pre-filled data               │   │
│  │  • Post deletion with confirmation                  │   │
│  │  • Comment creation on posts                        │   │
│  │  • User registration and login                     │   │
│  │  • Access control for user-owned data              │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  📚 Key Concepts:                                          │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  • Forms vs. ModelForms                            │   │
│  │  • GET vs. POST request handling                   │   │
│  │  • CSRF tokens                                     │   │
│  │  • File uploads with enctype                     │   │
│  │  • Messages framework (success, error, warning)    │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 3.2: The Need for Forms

**From Admin-Only to User-Generated Content**

```
┌─────────────────────────────────────────────────────────────┐
│                   WHY FORMS MATTER                          │
│                                                             │
│  Current State — Part 2:                                    │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  ┌─────────┐    ┌─────────┐    ┌─────────┐        │   │
│  │  │  Admin  │ ──▶│ Django  │ ──▶│  Database│       │   │
│  │  │  User   │    │  Admin  │    │  (Data) │        │   │
│  │  └─────────┘    └─────────┘    └─────────┘        │   │
│  │                                                    │   │
│  │  ❌ Only administrators can create content         │   │
│  │  ❌ Regular users can't contribute                 │   │
│  │  ❌ No user interaction                            │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Desired State — Part 3:                                   │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  ┌─────────┐    ┌─────────┐    ┌─────────┐        │   │
│  │  │  User   │ ──▶│  Django │ ──▶│  Database│       │   │
│  │  │(Browser)│    │  Forms  │    │  (Data) │        │   │
│  │  └─────────┘    └─────────┘    └─────────┘        │   │
│  │                                                    │   │
│  │  ✅ Regular users can create posts                 │   │
│  │  ✅ Users can edit their own content               │   │
│  │  ✅ Interactive user experience                    │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Forms Are the Bridge:                                     │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  • HTML forms collect user input                    │   │
│  │  • Django forms validate and clean data            │   │
│  │  • ModelForms save data to database                │   │
│  │  • Messages provide feedback                       │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 3.3: Django Forms vs. ModelForms

**Understanding the Difference**

```
┌─────────────────────────────────────────────────────────────┐
│                  FORMS VS. MODELFORMS                       │
│                                                             │
│  Regular Form (forms.Form):                                 │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  class ContactForm(forms.Form):                     │   │
│  │      name = forms.CharField(max_length=100)         │   │
│  │      email = forms.EmailField()                     │   │
│  │      message = forms.CharField(widget=forms.Textarea)│   │
│  │                                                    │   │
│  │  # Not tied to a model                             │   │
│  │  # Manual field definition                          │   │
│  │  # Manual saving logic                              │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ModelForm (forms.ModelForm):                               │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  class PostForm(forms.ModelForm):                   │   │
│  │      class Meta:                                    │   │
│  │          model = Post                               │   │
│  │          fields = ['title', 'content', 'category']  │   │
│  │                                                    │   │
│  │  # Tied to a model                                 │   │
│  │  # Auto-generates fields from model                │   │
│  │  # Auto-saving logic (form.save())                 │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  When to Use Each:                                          │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Use Form:                                         │   │
│  │  • Contact forms                                   │   │
│  │  • Search forms                                    │   │
│  │  • Forms not tied to a model                       │   │
│  │                                                    │   │
│  │  Use ModelForm:                                    │   │
│  │  • Creating/editing model instances                │   │
│  │  • CRUD operations                                 │   │
│  │  • Forms that map directly to database tables      │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 3.4: Building the PostForm — Part 1

**Defining the ModelForm**

```
┌─────────────────────────────────────────────────────────────┐
│                  BUILDING THE POSTFORM — PART 1             │
│                                                             │
│  Code:                                                      │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  from django import forms                           │   │
│  │  from django.utils.text import slugify              │   │
│  │  from .models import Post, Category, Tag           │   │
│  │                                                    │   │
│  │  class PostForm(forms.ModelForm):                  │   │
│  │      """Form for creating and editing posts."""    │   │
│  │                                                    │   │
│  │      # Custom field for tags (comma-separated)    │   │
│  │      tags_input = forms.CharField(                 │   │
│  │          required=False,                          │   │
│  │          help_text="Enter tags separated by commas",│   │
│  │          widget=forms.TextInput(attrs={            │   │
│  │              'class': 'form-control',              │   │
│  │              'placeholder': 'python, django, web'  │   │
│  │          })                                        │   │
│  │      )                                              │   │
│  │                                                    │   │
│  │      class Meta:                                    │   │
│  │          model = Post                               │   │
│  │          fields = [                                 │   │
│  │              'title', 'slug', 'category',          │   │
│  │              'content', 'excerpt',                 │   │
│  │              'featured_image', 'status',           │   │
│  │              'meta_description', 'meta_keywords'   │   │
│  │          ]                                          │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 3.5: Building the PostForm — Part 2

**Widgets and Help Texts**

```
┌─────────────────────────────────────────────────────────────┐
│                  BUILDING THE POSTFORM — PART 2             │
│                                                             │
│  Widgets and Help Texts:                                    │
│  ┌─────────────────────────────────────────────────────┐   │
│  │          widgets = {                                 │   │
│  │              'title': forms.TextInput(attrs={       │   │
│  │                  'class': 'form-control'            │   │
│  │              }),                                     │   │
│  │              'slug': forms.TextInput(attrs={        │   │
│  │                  'class': 'form-control'            │   │
│  │              }),                                     │   │
│  │              'category': forms.Select(attrs={       │   │
│  │                  'class': 'form-control'            │   │
│  │              }),                                     │   │
│  │              'content': forms.Textarea(attrs={      │   │
│  │                  'class': 'form-control',           │   │
│  │                  'rows': 15                         │   │
│  │              }),                                     │   │
│  │              'excerpt': forms.Textarea(attrs={      │   │
│  │                  'class': 'form-control',           │   │
│  │                  'rows': 3                          │   │
│  │              }),                                     │   │
│  │              'featured_image': forms.FileInput(attrs={│   │
│  │                  'class': 'form-control'            │   │
│  │              }),                                     │   │
│  │              'status': forms.Select(attrs={         │   │
│  │                  'class': 'form-control'            │   │
│  │              }),                                     │   │
│  │              'meta_description': forms.TextInput(attrs={│  │
│  │                  'class': 'form-control'            │   │
│  │              }),                                     │   │
│  │              'meta_keywords': forms.TextInput(attrs={│   │
│  │                  'class': 'form-control'            │   │
│  │              }),                                     │   │
│  │          }                                           │   │
│  │          help_texts = {                              │   │
│  │              'slug': 'Leave blank to auto-generate.',│   │
│  │              'excerpt': 'Leave blank to auto-generate.',│ │
│  │          }                                           │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 3.6: Building the PostForm — Part 3

**Custom Validation Methods**

```
┌─────────────────────────────────────────────────────────────┐
│                  BUILDING THE POSTFORM — PART 3             │
│                                                             │
│  Custom Validation:                                         │
│  ┌─────────────────────────────────────────────────────┐   │
│  │      def __init__(self, *args, **kwargs):           │   │
│  │          super().__init__(*args, **kwargs)          │   │
│  │          self.fields['slug'].required = False      │   │
│  │          self.fields['status'].initial = Post.Status.DRAFT│  │
│  │                                                    │   │
│  │      def clean_slug(self):                         │   │
│  │          """Auto-generate slug and ensure unique."""│   │
│  │          slug = self.cleaned_data.get('slug')      │   │
│  │          title = self.cleaned_data.get('title')    │   │
│  │                                                    │   │
│  │          if not slug and title:                    │   │
│  │              slug = slugify(title)                 │   │
│  │                                                    │   │
│  │          if slug:                                   │   │
│  │              instance_id = self.instance.id if self.instance else None│ │
│  │              if Post.objects.filter(slug=slug).exclude(│   │
│  │                  id=instance_id).exists():          │   │
│  │                  raise ValidationError(             │   │
│  │                      f'Slug "{slug}" already exists.'│   │
│  │                  )                                  │   │
│  │          return slug                                │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 3.7: Building the PostForm — Part 4

**File Upload Validation**

```
┌─────────────────────────────────────────────────────────────┐
│                  BUILDING THE POSTFORM — PART 4             │
│                                                             │
│  Image Validation:                                          │
│  ┌─────────────────────────────────────────────────────┐   │
│  │      def clean_featured_image(self):               │   │
│  │          """Validate uploaded image."""            │   │
│  │          image = self.cleaned_data.get('featured_image')│  │
│  │                                                    │   │
│  │          if image:                                 │   │
│  │              # Check file size (max 5MB)           │   │
│  │              if image.size > 5 * 1024 * 1024:     │   │
│  │                  raise ValidationError(             │   │
│  │                      'Image must be under 5MB.'    │   │
│  │                  )                                 │   │
│  │                                                    │   │
│  │              # Check file type                     │   │
│  │              allowed_types = ['image/jpeg',         │   │
│  │                              'image/png',          │   │
│  │                              'image/gif',          │   │
│  │                              'image/webp']         │   │
│  │              if image.content_type not in allowed_types:│  │
│  │                  raise ValidationError(             │   │
│  │                      'Only JPEG, PNG, GIF, and WebP are allowed.'│   │
│  │                  )                                 │   │
│  │                                                    │   │
│  │          return image                              │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Key Validation Checks:                                     │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  ✅ File size limit (5MB)                           │   │
│  │  ✅ MIME type checking                             │   │
│  │  ✅ Security — prevents malicious file uploads     │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 3.8: Building the PostForm — Part 5

**Saving with Tags Processing**

```
┌─────────────────────────────────────────────────────────────┐
│                  BUILDING THE POSTFORM — PART 5             │
│                                                             │
│  Save Method with Tags:                                     │
│  ┌─────────────────────────────────────────────────────┐   │
│  │      def save(self, commit=True):                   │   │
│  │          """Save post and process tags."""         │   │
│  │          instance = super().save(commit=False)      │   │
│  │          tags_input = self.cleaned_data.get('tags_input', '')│  │
│  │                                                    │   │
│  │          if commit:                                │   │
│  │              instance.save()                       │   │
│  │                                                    │   │
│  │              # Process tags                        │   │
│  │              if tags_input:                         │   │
│  │                  tag_names = [                      │   │
│  │                      tag.strip().lower()           │   │
│  │                      for tag in tags_input.split(',')│   │
│  │                      if tag.strip()                │   │
│  │                  ]                                  │   │
│  │                                                    │   │
│  │                  # Clear existing tags             │   │
│  │                  instance.tags.clear()             │   │
│  │                                                    │   │
│  │                  # Add tags                        │   │
│  │                  for tag_name in tag_names:        │   │
│  │                      tag, created = Tag.objects.get_or_create(│  │
│  │                          name=tag_name,            │   │
│  │                          defaults={'slug': slugify(tag_name)}│  │
│  │                      )                              │   │
│  │                      instance.tags.add(tag)        │   │
│  │                                                    │   │
│  │          return instance                           │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 3.9: Creating the CommentForm

**Simple Form for User Comments**

```
┌─────────────────────────────────────────────────────────────┐
│                 BUILDING THE COMMENTFORM                    │
│                                                             │
│  Code:                                                      │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  class CommentForm(forms.ModelForm):                │   │
│  │      """Form for adding comments to posts."""      │   │
│  │                                                    │   │
│  │      class Meta:                                    │   │
│  │          model = Comment                            │   │
│  │          fields = ['content']                      │   │
│  │          widgets = {                                │   │
│  │              'content': forms.Textarea(attrs={      │   │
│  │                  'class': 'form-control',           │   │
│  │                  'rows': 4,                         │   │
│  │                  'placeholder': 'Write your comment here...'│  │
│  │              })                                     │   │
│  │          }                                          │   │
│  │          labels = {                                 │   │
│  │              'content': 'Your Comment'              │   │
│  │          }                                          │   │
│  │                                                    │   │
│  │      def __init__(self, *args, **kwargs):          │   │
│  │          super().__init__(*args, **kwargs)         │   │
│  │          self.fields['content'].required = True    │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Why So Simple?                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  • Only one field needed (content)                 │   │
│  │  • Post and author set in the view                  │   │
│  │  • is_approved defaults to False for moderation     │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 3.10: Creating the Post Create View

**Handling GET and POST Requests**

```
┌─────────────────────────────────────────────────────────────┐
│                  POST CREATE VIEW                           │
│                                                             │
│  Code:                                                      │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  from django.contrib.auth.decorators import login_required│  │
│  │  from django.contrib import messages                │   │
│  │  from django.utils import timezone                  │   │
│  │                                                    │   │
│  │  @login_required                                    │   │
│  │  def post_create(request):                          │   │
│  │      """Create a new blog post."""                 │   │
│  │                                                    │   │
│  │      if request.method == 'POST':                  │   │
│  │          form = PostForm(request.POST, request.FILES)│   │
│  │                                                    │   │
│  │          if form.is_valid():                       │   │
│  │              post = form.save(commit=False)        │   │
│  │              post.author = request.user            │   │
│  │                                                    │   │
│  │              if post.status == Post.Status.PUBLISHED:│  │
│  │                  post.published_at = timezone.now()│   │
│  │                                                    │   │
│  │              post.save()                            │   │
│  │              form.save_m2m()                       │   │
│  │                                                    │   │
│  │              messages.success(request,              │   │
│  │                  f'Post "{post.title}" created!')   │   │
│  │              return redirect('blog:post_detail',   │   │
│  │                              slug=post.slug)       │   │
│  │          else:                                      │   │
│  │              messages.error(request,                │   │
│  │                  'Please correct the errors below.')│   │
│  │      else:                                          │   │
│  │          form = PostForm()                          │   │
│  │                                                    │   │
│  │      context = {                                   │   │
│  │          'form': form,                             │   │
│  │          'title': 'Create New Post',               │   │
│  │          'submit_text': 'Create Post',             │   │
│  │      }                                              │   │
│  │      return render(request, 'blog/post_form.html', context)│  │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 3.11: Creating the Post Edit View

**Editing Existing Posts with Access Control**

```
┌─────────────────────────────────────────────────────────────┐
│                  POST EDIT VIEW                             │
│                                                             │
│  Code:                                                      │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  @login_required                                    │   │
│  │  def post_edit(request, slug):                     │   │
│  │      """Edit an existing blog post."""             │   │
│  │      post = get_object_or_404(Post, slug=slug)     │   │
│  │                                                    │   │
│  │      # Check permission                            │   │
│  │      if post.author != request.user:               │   │
│  │          messages.error(request,                   │   │
│  │              'You cannot edit this post.')          │   │
│  │          return redirect('blog:post_detail',       │   │
│  │                          slug=post.slug)           │   │
│  │                                                    │   │
│  │      if request.method == 'POST':                  │   │
│  │          form = PostForm(request.POST, request.FILES,│   │
│  │                         instance=post)             │   │
│  │                                                    │   │
│  │          if form.is_valid():                       │   │
│  │              updated = form.save(commit=False)     │   │
│  │                                                    │   │
│  │              if (updated.status == Post.Status.PUBLISHED and│  │
│  │                  post.status != Post.Status.PUBLISHED):│  │
│  │                  updated.published_at = timezone.now()│  │
│  │                                                    │   │
│  │              updated.save()                        │   │
│  │              form.save_m2m()                       │   │
│  │                                                    │   │
│  │              messages.success(request,             │   │
│  │                  f'Post "{updated.title}" updated!')│   │
│  │              return redirect('blog:post_detail',   │   │
│  │                              slug=updated.slug)    │   │
│  │      else:                                          │   │
│  │          form = PostForm(instance=post)            │   │
│  │          if post.tags.exists():                    │   │
│  │              tags = [tag.name for tag in post.tags.all()]│  │
│  │              form.fields['tags_input'].initial = ', '.join(tags)│  │
│  │                                                    │   │
│  │      context = {                                   │   │
│  │          'form': form, 'post': post,               │   │
│  │          'title': f'Edit: {post.title}',           │   │
│  │          'submit_text': 'Update Post',             │   │
│  │      }                                              │   │
│  │      return render(request, 'blog/post_form.html', context)│  │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 3.12: Creating the Post Delete View

**Confirmation and Deletion**

```
┌─────────────────────────────────────────────────────────────┐
│                  POST DELETE VIEW                           │
│                                                             │
│  Code:                                                      │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  @login_required                                    │   │
│  │  def post_delete(request, slug):                   │   │
│  │      """Delete a blog post."""                     │   │
│  │      post = get_object_or_404(Post, slug=slug)     │   │
│  │                                                    │   │
│  │      # Check permission                            │   │
│  │      if post.author != request.user:               │   │
│  │          messages.error(request,                   │   │
│  │              'You cannot delete this post.')        │   │
│  │          return redirect('blog:post_detail',       │   │
│  │                          slug=post.slug)           │   │
│  │                                                    │   │
│  │      if request.method == 'POST':                  │   │
│  │          post_title = post.title                   │   │
│  │          post.delete()                              │   │
│  │          messages.success(request,                 │   │
│  │              f'Post "{post_title}" deleted.')       │   │
│  │          return redirect('blog:blog_list')         │   │
│  │                                                    │   │
│  │      context = {                                   │   │
│  │          'post': post,                             │   │
│  │      }                                              │   │
│  │      return render(request, 'blog/post_confirm_delete.html',│  │
│  │                      context)                      │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Workflow:                                                  │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  GET  → Show confirmation page                      │   │
│  │  POST → Delete and redirect                        │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 3.13: Creating the Comment Create View

**Adding Comments to Posts**

```
┌─────────────────────────────────────────────────────────────┐
│                  COMMENT CREATE VIEW                        │
│                                                             │
│  Code:                                                      │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  @login_required                                    │   │
│  │  def comment_create(request, post_slug):           │   │
│  │      """Add a comment to a post."""                │   │
│  │      post = get_object_or_404(                     │   │
│  │          Post,                                     │   │
│  │          slug=post_slug,                           │   │
│  │          status=Post.Status.PUBLISHED              │   │
│  │      )                                              │   │
│  │                                                    │   │
│  │      if request.method == 'POST':                  │   │
│  │          form = CommentForm(request.POST)          │   │
│  │                                                    │   │
│  │          if form.is_valid():                       │   │
│  │              comment = form.save(commit=False)     │   │
│  │              comment.post = post                   │   │
│  │              comment.author = request.user         │   │
│  │              comment.save()                         │   │
│  │              messages.success(request,             │   │
│  │                  'Your comment is awaiting moderation.')│  │
│  │          else:                                      │   │
│  │              messages.error(request,               │   │
│  │                  'Please enter a valid comment.')   │   │
│  │                                                    │   │
│  │      return redirect('blog:post_detail',           │   │
│  │                      slug=post.slug)               │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Comment Moderation Flow:                                   │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  1. User submits comment (is_approved=False)        │   │
│  │  2. Admin approves in admin interface              │   │
│  │  3. Comment becomes visible to public              │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 3.14: Creating the Post Form Template — Part 1

**HTML Form with CSRF Protection**

```
┌─────────────────────────────────────────────────────────────┐
│              POST FORM TEMPLATE — PART 1                    │
│                                                             │
│  Template:                                                  │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  {% extends 'blog/base.html' %}                     │   │
│  │                                                    │   │
│  │  {% block title %}{{ title }} — Django Blog{% endblock %}│  │
│  │                                                    │   │
│  │  {% block content %}                               │   │
│  │  <div class="page-header">                         │   │
│  │      <h1>{{ title }}</h1>                          │   │
│  │  </div>                                            │   │
│  │                                                    │   │
│  │  <div class="content">                             │   │
│  │      <form method="post" enctype="multipart/form-data" │   │
│  │            novalidate>                             │   │
│  │          {% csrf_token %}                          │   │
│  │                                                    │   │
│  │          <!-- Display form errors -->              │   │
│  │          {% if form.errors %}                     │   │
│  │              <div style="background: #f8d7da;      │   │
│  │                   color: #721c24;                  │   │
│  │                   padding: 1rem;                   │   │
│  │                   border-radius: 4px;              │   │
│  │                   margin-bottom: 1rem;">           │   │
│  │                  <strong>Please correct the errors:</strong>│  │
│  │                  <ul>                              │   │
│  │                      {% for field, errors in form.errors.items %}│  │
│  │                          {% for error in errors %}│   │
│  │                              <li>{{ field|capfirst }}: {{ error }}</li>│  │
│  │                          {% endfor %}              │   │
│  │                      {% endfor %}                  │   │
│  │                  </ul>                             │   │
│  │              </div>                                │   │
│  │          {% endif %}                               │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 3.15: Creating the Post Form Template — Part 2

**Form Fields with Validation Feedback**

```
┌─────────────────────────────────────────────────────────────┐
│              POST FORM TEMPLATE — PART 2                    │
│                                                             │
│  Form Fields:                                               │
│  ┌─────────────────────────────────────────────────────┐   │
│  │          <!-- Title -->                             │   │
│  │          <div style="margin-bottom: 1.5rem;">       │   │
│  │              <label for="{{ form.title.id_for_label }}">│   │
│  │                  {{ form.title.label }}             │   │
│  │                  <span style="color: #e74c3c;">*</span>│   │
│  │              </label>                                │   │
│  │              {{ form.title }}                       │   │
│  │              {% if form.title.errors %}             │   │
│  │                  <div style="color: #e74c3c;">     │   │
│  │                      {{ form.title.errors }}       │   │
│  │                  </div>                             │   │
│  │              {% endif %}                             │   │
│  │          </div>                                      │   │
│  │                                                    │   │
│  │          <!-- Slug -->                              │   │
│  │          <div style="margin-bottom: 1.5rem;">       │   │
│  │              <label for="{{ form.slug.id_for_label }}">│   │
│  │                  {{ form.slug.label }}              │   │
│  │              </label>                                │   │
│  │              {{ form.slug }}                        │   │
│  │              <small style="color: #7f8c8d;">       │   │
│  │                  {{ form.slug.help_text }}          │   │
│  │              </small>                                │   │
│  │          </div>                                      │   │
│  │                                                    │   │
│  │          <!-- Category -->                          │   │
│  │          <div style="margin-bottom: 1.5rem;">       │   │
│  │              <label for="{{ form.category.id_for_label }}">│   │
│  │                  {{ form.category.label }}          │   │
│  │                  <span style="color: #e74c3c;">*</span>│   │
│  │              </label>                                │   │
│  │              {{ form.category }}                    │   │
│  │          </div>                                      │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 3.16: Creating the Post Form Template — Part 3

**Content and Image Upload Fields**

```
┌─────────────────────────────────────────────────────────────┐
│              POST FORM TEMPLATE — PART 3                    │
│                                                             │
│  Content Fields:                                            │
│  ┌─────────────────────────────────────────────────────┐   │
│  │          <!-- Tags Input -->                        │   │
│  │          <div style="margin-bottom: 1.5rem;">       │   │
│  │              <label for="{{ form.tags_input.id_for_label }}">│   │
│  │                  Tags                               │   │
│  │              </label>                                │   │
│  │              {{ form.tags_input }}                  │   │
│  │              <small style="color: #7f8c8d;">       │   │
│  │                  {{ form.tags_input.help_text }}    │   │
│  │              </small>                                │   │
│  │          </div>                                      │   │
│  │                                                    │   │
│  │          <!-- Content -->                           │   │
│  │          <div style="margin-bottom: 1.5rem;">       │   │
│  │              <label for="{{ form.content.id_for_label }}">│   │
│  │                  {{ form.content.label }}           │   │
│  │                  <span style="color: #e74c3c;">*</span>│   │
│  │              </label>                                │   │
│  │              {{ form.content }}                     │   │
│  │          </div>                                      │   │
│  │                                                    │   │
│  │          <!-- Featured Image -->                    │   │
│  │          <div style="margin-bottom: 1.5rem;">       │   │
│  │              <label for="{{ form.featured_image.id_for_label }}">│   │
│  │                  {{ form.featured_image.label }}    │   │
│  │              </label>                                │   │
│  │              {% if form.instance.featured_image %}  │   │
│  │                  <div style="margin-bottom: 0.5rem;">│   │
│  │                      <img src="{{ form.instance.featured_image.url }}"│  │
│  │                           style="max-width: 200px;">│   │
│  │                      <br>                           │   │
│  │                      <small>Current image</small>   │   │
│  │                  </div>                             │   │
│  │              {% endif %}                            │   │
│  │              {{ form.featured_image }}              │   │
│  │          </div>                                      │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 3.17: Creating the Post Form Template — Part 4

**Status and Submit Buttons**

```
┌─────────────────────────────────────────────────────────────┐
│              POST FORM TEMPLATE — PART 4                    │
│                                                             │
│  Status and Submit:                                         │
│  ┌─────────────────────────────────────────────────────┐   │
│  │          <!-- Status -->                            │   │
│  │          <div style="margin-bottom: 1.5rem;">       │   │
│  │              <label for="{{ form.status.id_for_label }}">│   │
│  │                  {{ form.status.label }}            │   │
│  │                  <span style="color: #e74c3c;">*</span>│   │
│  │              </label>                                │   │
│  │              {{ form.status }}                       │   │
│  │          </div>                                      │   │
│  │                                                    │   │
│  │          <!-- SEO Meta -->                          │   │
│  │          <div style="margin-bottom: 1.5rem;">       │   │
│  │              <label for="{{ form.meta_description.id_for_label }}">│   │
│  │                  {{ form.meta_description.label }}  │   │
│  │              </label>                                │   │
│  │              {{ form.meta_description }}            │   │
│  │          </div>                                      │   │
│  │                                                    │   │
│  │          <div style="margin-bottom: 1.5rem;">       │   │
│  │              <label for="{{ form.meta_keywords.id_for_label }}">│   │
│  │                  {{ form.meta_keywords.label }}     │   │
│  │              </label>                                │   │
│  │              {{ form.meta_keywords }}               │   │
│  │          </div>                                      │   │
│  │                                                    │   │
│  │          <!-- Submit Buttons -->                    │   │
│  │          <div style="display: flex; gap: 1rem;">   │   │
│  │              <button type="submit" style="          │   │
│  │                  background: #3498db; color: white;│   │
│  │                  border: none; padding: 0.75rem 2rem;│   │
│  │                  border-radius: 4px; cursor: pointer;">│   │
│  │                  {{ submit_text }}                  │   │
│  │              </button>                               │   │
│  │              <a href="{% url 'blog:blog_list' %}"   │   │
│  │                 style="background: #95a5a6;         │   │
│  │                 color: white; padding: 0.75rem 2rem;│   │
│  │                 border-radius: 4px;                 │   │
│  │                 text-decoration: none;">            │   │
│  │                  Cancel                             │   │
│  │              </a>                                   │   │
│  │          </div>                                     │   │
│  │      </form>                                        │   │
│  │  </div>                                              │   │
│  │  {% endblock %}                                     │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 3.18: Creating the Delete Confirmation Template

**Safe Deletion with Confirmation**

```
┌─────────────────────────────────────────────────────────────┐
│              DELETE CONFIRMATION TEMPLATE                   │
│                                                             │
│  Template:                                                  │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  {% extends 'blog/base.html' %}                     │   │
│  │                                                    │   │
│  │  {% block title %}Delete Post — Django Blog{% endblock %}│  │
│  │                                                    │   │
│  │  {% block content %}                               │   │
│  │  <div class="page-header">                         │   │
│  │      <h1>Delete Post</h1>                          │   │
│  │  </div>                                            │   │
│  │                                                    │   │
│  │  <div class="content" style="text-align: center;"> │   │
│  │      <p style="font-size: 1.2rem;">                │   │
│  │          Are you sure you want to delete           │   │
│  │          <strong>"{{ post.title }}"</strong>?      │   │
│  │      </p>                                          │   │
│  │                                                    │   │
│  │      <p style="color: #e74c3c; margin-bottom: 2rem;">│   │
│  │          <strong>Warning:</strong>                  │   │
│  │          This action cannot be undone.             │   │
│  │      </p>                                          │   │
│  │                                                    │   │
│  │      <form method="post">                          │   │
│  │          {% csrf_token %}                          │   │
│  │          <div style="display: flex; gap: 1rem;    │   │
│  │               justify-content: center;">           │   │
│  │              <button type="submit" style="         │   │
│  │                  background: #e74c3c; color: white;│   │
│  │                  border: none; padding: 0.75rem 2rem;│   │
│  │                  border-radius: 4px; cursor: pointer;">│   │
│  │                  Yes, Delete This Post             │   │
│  │              </button>                             │   │
│  │              <a href="{% url 'blog:post_detail' post.slug %}"│  │
│  │                 style="background: #95a5a6;        │   │
│  │                 color: white; padding: 0.75rem 2rem;│   │
│  │                 border-radius: 4px;                │   │
│  │                 text-decoration: none;">           │   │
│  │                  No, Take Me Back                  │   │
│  │              </a>                                  │   │
│  │          </div>                                    │   │
│  │      </form>                                       │   │
│  │  </div>                                            │   │
│  │  {% endblock %}                                    │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 3.19: Setting Up User Authentication

**Enabling Login and Registration**

```
┌─────────────────────────────────────────────────────────────┐
│              USER AUTHENTICATION SETUP                      │
│                                                             │
│  Settings Configuration:                                    │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  # config/settings.py                              │   │
│  │                                                    │   │
│  │  LOGIN_URL = 'login'                               │   │
│  │  LOGIN_REDIRECT_URL = 'blog:home'                 │   │
│  │  LOGOUT_REDIRECT_URL = 'blog:home'                │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Login Template (`registration/login.html`):               │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  {% extends 'blog/base.html' %}                     │   │
│  │                                                    │   │
│  │  {% block content %}                               │   │
│  │  <div class="page-header"><h1>Login</h1></div>     │   │
│  │                                                    │   │
│  │  <div class="content" style="max-width: 500px;">   │   │
│  │      <form method="post">                          │   │
│  │          {% csrf_token %}                          │   │
│  │                                                    │   │
│  │          {% if form.errors %}                      │   │
│  │              <div style="color: #e74c3c;">         │   │
│  │                  Invalid username or password.     │   │
│  │              </div>                                │   │
│  │          {% endif %}                               │   │
│  │                                                    │   │
│  │          <div style="margin-bottom: 1rem;">        │   │
│  │              <label for="id_username">Username</label>│   │
│  │              <input type="text" name="username"    │   │
│  │                     id="id_username" required>    │   │
│  │          </div>                                    │   │
│  │                                                    │   │
│  │          <div style="margin-bottom: 1rem;">        │   │
│  │              <label for="id_password">Password</label>│   │
│  │              <input type="password" name="password"│   │
│  │                     id="id_password" required>    │   │
│  │          </div>                                    │   │
│  │                                                    │   │
│  │          <button type="submit">Login</button>      │   │
│  │          <a href="{% url 'register' %}">Register</a>│   │
│  │                                                    │   │
│  │          <input type="hidden" name="next"          │   │
│  │                 value="{{ next }}">                │   │
│  │      </form>                                       │   │
│  │  </div>                                            │   │
│  │  {% endblock %}                                    │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 3.20: Creating the Registration View

**User Registration with Auto-Login**

```
┌─────────────────────────────────────────────────────────────┐
│                REGISTRATION VIEW                            │
│                                                             │
│  Code:                                                      │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  from django.contrib.auth.forms import UserCreationForm│  │
│  │  from django.contrib.auth import login              │   │
│  │                                                    │   │
│  │  def register(request):                            │   │
│  │      """User registration view."""                 │   │
│  │                                                    │   │
│  │      if request.method == 'POST':                  │   │
│  │          form = UserCreationForm(request.POST)     │   │
│  │                                                    │   │
│  │          if form.is_valid():                       │   │
│  │              user = form.save()                    │   │
│  │              login(request, user)                  │   │
│  │              messages.success(request,             │   │
│  │                  f'Welcome, {user.username}!')      │   │
│  │              return redirect('blog:home')          │   │
│  │      else:                                          │   │
│  │          form = UserCreationForm()                 │   │
│  │                                                    │   │
│  │      context = {                                   │   │
│  │          'form': form,                             │   │
│  │      }                                              │   │
│  │      return render(request, 'registration/register.html',│  │
│  │                      context)                      │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Registration Workflow:                                     │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  1. User fills out registration form                │   │
│  │  2. Django validates and creates user              │   │
│  │  3. User is automatically logged in                │   │
│  │  4. Success message is displayed                   │   │
│  │  5. User is redirected to homepage                 │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 3.21: Creating the Registration Template

**User-Friendly Registration Form**

```
┌─────────────────────────────────────────────────────────────┐
│                REGISTRATION TEMPLATE                        │
│                                                             │
│  Template:                                                  │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  {% extends 'blog/base.html' %}                     │   │
│  │                                                    │   │
│  │  {% block title %}Register — Django Blog{% endblock %}│  │
│  │                                                    │   │
│  │  {% block content %}                               │   │
│  │  <div class="page-header">                         │   │
│  │      <h1>Create an Account</h1>                    │   │
│  │  </div>                                            │   │
│  │                                                    │   │
│  │  <div class="content" style="max-width: 500px;">   │   │
│  │      <form method="post">                          │   │
│  │          {% csrf_token %}                          │   │
│  │                                                    │   │
│  │          {% if form.errors %}                      │   │
│  │              <div style="background: #f8d7da;      │   │
│  │                   color: #721c24; padding: 1rem;   │   │
│  │                   border-radius: 4px;              │   │
│  │                   margin-bottom: 1rem;">           │   │
│  │                  <strong>Please correct the errors:</strong>│  │
│  │                  <ul>                              │   │
│  │                      {% for field, errors in form.errors.items %}│  │
│  │                          {% for error in errors %}│   │
│  │                              <li>{{ field|capfirst }}: {{ error }}</li>│  │
│  │                          {% endfor %}              │   │
│  │                      {% endfor %}                  │   │
│  │                  </ul>                             │   │
│  │              </div>                                │   │
│  │          {% endif %}                               │   │
│  │                                                    │   │
│  │          <div style="margin-bottom: 1rem;">        │   │
│  │              <label for="id_username">Username</label>│   │
│  │              <input type="text" name="username"    │   │
│  │                     id="id_username" required>    │   │
│  │              <small>Required. 150 characters or less.</small>│  │
│  │          </div>                                    │   │
│  │                                                    │   │
│  │          <div style="margin-bottom: 1rem;">        │   │
│  │              <label for="id_email">Email</label>   │   │
│  │              <input type="email" name="email"      │   │
│  │                     id="id_email" required>       │   │
│  │          </div>                                    │   │
│  │                                                    │   │
│  │          <div style="margin-bottom: 1rem;">        │   │
│  │              <label for="id_password1">Password</label>│   │
│  │              <input type="password" name="password1"│   │
│  │                     id="id_password1" required>   │   │
│  │              <small>At least 8 characters.</small> │   │
│  │          </div>                                    │   │
│  │                                                    │   │
│  │          <div style="margin-bottom: 1rem;">        │   │
│  │              <label for="id_password2">Confirm</label>│   │
│  │              <input type="password" name="password2"│   │
│  │                     id="id_password2" required>   │   │
│  │          </div>                                    │   │
│  │                                                    │   │
│  │          <button type="submit">Register</button>   │   │
│  │          <a href="{% url 'login' %}">Back to Login</a>│   │
│  │      </form>                                       │   │
│  │  </div>                                            │   │
│  │  {% endblock %}                                    │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 3.22: Updating URLs for Authentication

**Adding Login, Logout, and Registration URLs**

```
┌─────────────────────────────────────────────────────────────┐
│              UPDATING URLS — AUTHENTICATION                 │
│                                                             │
│  App URLs (`blog/urls.py`):                                │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  from django.urls import path                       │   │
│  │  from django.contrib.auth import views as auth_views│   │
│  │  from . import views                                │   │
│  │                                                    │   │
│  │  app_name = 'blog'                                 │   │
│  │                                                    │   │
│  │  urlpatterns = [                                    │   │
│  │      # Public views                                │   │
│  │      path('', views.home, name='home'),            │   │
│  │      path('about/', views.about, name='about'),    │   │
│  │      path('blog/', views.blog_list, name='blog_list'),│   │
│  │      path('blog/<slug:slug>/', views.post_detail,  │   │
│  │           name='post_detail'),                     │   │
│  │      path('category/<slug:slug>/', views.category_detail,│  │
│  │           name='category_detail'),                 │   │
│  │      path('tag/<slug:slug>/', views.tag_detail,    │   │
│  │           name='tag_detail'),                      │   │
│  │                                                    │   │
│  │      # CRUD views                                  │   │
│  │      path('post/create/', views.post_create,       │   │
│  │           name='post_create'),                     │   │
│  │      path('post/<slug:slug>/edit/', views.post_edit,│   │
│  │           name='post_edit'),                       │   │
│  │      path('post/<slug:slug>/delete/', views.post_delete,│  │
│  │           name='post_delete'),                     │   │
│  │                                                    │   │
│  │      # Comment views                               │   │
│  │      path('post/<slug:post_slug>/comment/',        │   │
│  │           views.comment_create,                    │   │
│  │           name='comment_create'),                  │   │
│  │                                                    │   │
│  │      # Authentication views                        │   │
│  │      path('login/', auth_views.LoginView.as_view(),│   │
│  │           name='login'),                           │   │
│  │      path('logout/', auth_views.LogoutView.as_view(),│  │
│  │           name='logout'),                          │   │
│  │      path('register/', views.register,             │   │
│  │           name='register'),                        │   │
│  │  ]                                                  │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 3.23: Understanding CSRF Protection

**Cross-Site Request Forgery Defense**

```
┌─────────────────────────────────────────────────────────────┐
│                   CSRF PROTECTION                           │
│                                                             │
│  What is CSRF?                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Cross-Site Request Forgery                         │   │
│  │  Attack where a malicious site tricks a user's     │   │
│  │  browser into making unauthorized requests          │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  How CSRF Protection Works:                                 │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                                                     │   │
│  │  ┌─────────────┐     ┌─────────────┐               │   │
│  │  │   Browser   │────▶│   Django    │               │   │
│  │  │   (User)    │     │  (Server)   │               │   │
│  │  └─────────────┘     └─────────────┘               │   │
│  │         │                   │                        │   │
│  │         │  1. GET /form/   │                        │   │
│  │         │──────────────────▶│                        │   │
│  │         │                   │                        │   │
│  │         │  2. Renders form  │                        │   │
│  │         │  with CSRF token  │                        │   │
│  │         │◀──────────────────│                        │   │
│  │         │                   │                        │   │
│  │         │  3. POST /submit/ │                        │   │
│  │         │  with CSRF token  │                        │   │
│  │         │──────────────────▶│                        │   │
│  │         │                   │                        │   │
│  │         │  4. Validates     │                        │   │
│  │         │  token ✓          │                        │   │
│  │         │                   │                        │   │
│  │         │  5. Processes     │                        │   │
│  │         │  request          │                        │   │
│  │         │◀──────────────────│                        │   │
│  │         │                   │                        │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  In Templates:                                              │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  <form method="post">                               │   │
│  │      {% csrf_token %}  <!-- Required for all POST --> │   │
│  │      <!-- Form fields -->                           │   │
│  │  </form>                                            │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 3.24: Using the Messages Framework

**User Feedback with Django Messages**

```
┌─────────────────────────────────────────────────────────────┐
│                  MESSAGES FRAMEWORK                         │
│                                                             │
│  What Are Messages?                                         │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Temporary notifications displayed to users         │   │
│  │  Survive one request cycle (redirects)             │   │
│  │  Stored in session or cookies                       │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Message Levels:                                            │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Level      │  Method                           │   │
│  │  ──────────────────────────────────────────────────  │   │
│  │  DEBUG      │  messages.debug(request, msg)      │   │
│  │  INFO       │  messages.info(request, msg)       │   │
│  │  SUCCESS    │  messages.success(request, msg)    │   │
│  │  WARNING    │  messages.warning(request, msg)    │   │
│  │  ERROR      │  messages.error(request, msg)      │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Examples in Views:                                        │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  # Success message                                 │   │
│  │  messages.success(request, f'Post created!')       │   │
│  │                                                    │   │
│  │  # Error message                                   │   │
│  │  messages.error(request, 'Please fix errors.')     │   │
│  │                                                    │   │
│  │  # Warning message                                 │   │
│  │  messages.warning(request, 'Post is in draft.')   │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Display Messages in Base Template:                        │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  {% if messages %}                                  │   │
│  │      {% for message in messages %}                 │   │
│  │          <div class="alert alert-{{ message.tags }}">│   │
│  │              {{ message }}                          │   │
│  │          </div>                                    │   │
│  │      {% endfor %}                                  │   │
│  │  {% endif %}                                        │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 3.25: Access Control — Author Only

**Ensuring Users Can Only Edit Their Own Content**

```
┌─────────────────────────────────────────────────────────────┐
│                ACCESS CONTROL                               │
│                                                             │
│  The Problem:                                               │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  ❌ User A can edit User B's posts                  │   │
│  │  ❌ User A can delete User B's posts                │   │
│  │  ❌ Unauthorized access to sensitive content        │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  The Solution:                                              │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  ✅ Check post.author == request.user               │   │
│  │  ✅ Redirect with error message on failure          │   │
│  │  ✅ @login_required for all CRUD views            │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Code Example:                                              │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  @login_required                                    │   │
│  │  def post_edit(request, slug):                     │   │
│  │      post = get_object_or_404(Post, slug=slug)     │   │
│  │                                                    │   │
│  │      # 🔒 Access Control Check                     │   │
│  │      if post.author != request.user:               │   │
│  │          messages.error(request,                   │   │
│  │              'You do not have permission.')         │   │
│  │          return redirect('blog:post_detail',       │   │
│  │                          slug=post.slug)           │   │
│  │                                                    │   │
│  │      # Continue with edit logic...                 │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Template Protection:                                       │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  {% if user == post.author %}                       │   │
│  │      <a href="{% url 'blog:post_edit' post.slug %}">│   │
│  │          Edit                                      │   │
│  │      </a>                                           │   │
│  │      <a href="{% url 'blog:post_delete' post.slug %}">│   │
│  │          Delete                                    │   │
│  │      </a>                                           │   │
│  │  {% endif %}                                        │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 3.26: Verification — Testing the Complete CRUD Workflow

**Comprehensive Verification Checklist**

```
┌─────────────────────────────────────────────────────────────┐
│              VERIFICATION CHECKLIST                         │
│                                                             │
│  Step 1: Create a User                                      │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  1. Visit http://127.0.0.1:8000/register/           │   │
│  │  2. Register a new account                          │   │
│  │  3. Verify automatic login                          │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Step 2: Create a Post                                     │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  1. Click "New Post" in navigation                  │   │
│  │  2. Fill in: Title, Category, Tags, Content        │   │
│  │  3. Click "Create Post"                             │   │
│  │  4. Verify success message and post detail          │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Step 3: Edit the Post                                     │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  1. On post detail, click "Edit"                   │   │
│  │  2. Change the title                                │   │
│  │  3. Click "Update Post"                             │   │
│  │  4. Verify changes are saved                        │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Step 4: Delete the Post                                   │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  1. On post detail, click "Delete"                 │   │
│  │  2. Confirm deletion                                │   │
│  │  3. Verify post is removed from blog list          │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Step 5: Test Access Control                               │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  1. Log out                                         │   │
│  │  2. Try to edit a post → redirected to login       │   │
│  │  3. Log in as different user                       │   │
│  │  4. Try to edit another user's post → permission error│  │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 3.27: What You've Learned in Part 3

**Skills Acquired and What You've Built**

```
┌─────────────────────────────────────────────────────────────┐
│              WHAT YOU'VE LEARNED — PART 3                  │
│                                                             │
│  ✅ Skills Acquired:                                        │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  • Creating Django ModelForms                      │   │
│  │  • Handling GET and POST requests                  │   │
│  │  • Validating form data                            │   │
│  │  • Processing file uploads                         │   │
│  │  • Implementing CRUD operations                    │   │
│  │  • Using the @login_required decorator            │   │
│  │  • Restricting access to object owners            │   │
│  │  • Using the messages framework                    │   │
│  │  • Setting up user authentication                  │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ✅ What You've Built:                                      │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  • Complete post creation workflow                  │   │
│  │  • Post editing with pre-filled data               │   │
│  │  • Post deletion with confirmation                  │   │
│  │  • Comment creation on posts                       │   │
│  │  • User registration and login                    │   │
│  │  • Access control for user-owned data              │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  🎯 Ready for Part 4:                                       │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  In Part 4, we'll refactor to Class-Based Views,    │   │
│  │  add search, filtering, and pagination!            │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 3.28: Quick Reference — Form Patterns

**Essential Form Patterns**

```
┌─────────────────────────────────────────────────────────────┐
│              FORM PATTERNS — QUICK REFERENCE               │
│                                                             │
│  Creating a ModelForm:                                      │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  class MyForm(forms.ModelForm):                     │   │
│  │      class Meta:                                    │   │
│  │          model = MyModel                            │   │
│  │          fields = ['field1', 'field2']             │   │
│  │          widgets = {                                │   │
│  │              'field1': forms.TextInput(attrs={      │   │
│  │                  'class': 'form-control'            │   │
│  │              })                                     │   │
│  │          }                                          │   │
│  │                                                    │   │
│  │      def clean_field1(self):                       │   │
│  │          data = self.cleaned_data.get('field1')    │   │
│  │          # Custom validation                       │   │
│  │          return data                               │   │
│  │                                                    │   │
│  │      def save(self, commit=True):                  │   │
│  │          instance = super().save(commit=False)     │   │
│  │          # Custom save logic                      │   │
│  │          if commit:                                │   │
│  │              instance.save()                       │   │
│  │          return instance                           │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Using a Form in a View:                                    │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  def my_view(request):                              │   │
│  │      if request.method == 'POST':                  │   │
│  │          form = MyForm(request.POST, request.FILES)│   │
│  │          if form.is_valid():                       │   │
│  │              obj = form.save()                     │   │
│  │              messages.success(request, 'Success!') │   │
│  │              return redirect('success_url')        │   │
│  │      else:                                          │   │
│  │          form = MyForm()                           │   │
│  │                                                    │   │
│  │      return render(request, 'template.html',       │   │
│  │                      {'form': form})               │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 3.29: Proceed to Part 4

**Preview of What's Coming**

```
┌─────────────────────────────────────────────────────────────┐
│                COMING UP IN PART 4                          │
│                                                             │
│  🏗️ Class-Based Views, Search, Filtering, Pagination       │
│                                                             │
│  What We'll Build:                                          │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  • Refactor all views to Class-Based Views         │   │
│  │  • Search functionality for posts                  │   │
│  │  • Filtering by category, author, status           │   │
│  │  • Pagination for post lists                       │   │
│  │  • Enhanced user messaging                         │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  What We'll Learn:                                          │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  • Class-Based Views (ListView, DetailView, etc.)  │   │
│  │  • Q objects for complex queries                   │   │
│  │  • URL parameter filtering                         │   │
│  │  • Django's pagination system                      │   │
│  │  • Mixins (LoginRequiredMixin, UserPassesTestMixin)│   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Preview of Class-Based Views:                              │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  class PostListView(ListView):                      │   │
│  │      model = Post                                   │   │
│  │      template_name = 'blog/blog_list.html'         │   │
│  │      context_object_name = 'posts'                 │   │
│  │      paginate_by = 10                              │   │
│  │                                                    │   │
│  │      def get_queryset(self):                       │   │
│  │          return Post.objects.filter(               │   │
│  │              status='published'                    │   │
│  │          )                                          │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Let's refactor to Class-Based Views! 🏗️                 │
└─────────────────────────────────────────────────────────────┘
```

---

# PART 4: CLASS-BASED VIEWS, SEARCH, FILTERING, PAGINATION, AND MESSAGING

---

## Slide 4.1: Part 4 Introduction

**Learning Objectives**

```
┌─────────────────────────────────────────────────────────────┐
│                    PART 4 OVERVIEW                          │
│                                                             │
│  🎯 Learning Objectives:                                    │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  ✅ Understand and use Class-Based Views            │   │
│  │  ✅ Refactor function views to class views          │   │
│  │  ✅ Implement search with Q objects                 │   │
│  │  ✅ Add filtering with URL parameters               │   │
│  │  ✅ Use pagination for large data sets             │   │
│  │  ✅ Work with mixins for access control             │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  🏗️ What We'll Build:                                      │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  • Searchable blog listing                          │   │
│  │  • Filterable posts by category, author, status    │   │
│  │  • Pagination for large post lists                 │   │
│  │  • Clean, maintainable class-based views           │   │
│  │  • Consistent message handling                     │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  📚 Key Concepts:                                          │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  • CBV Hierarchy (ListView, DetailView, etc.)      │   │
│  │  • get_queryset() customization                   │   │
│  │  • get_context_data() for extra data              │   │
│  │  • Q objects for OR conditions                    │   │
│  │  • Pagination with paginate_by                     │   │
│  │  • Mixin order (LoginRequiredMixin first!)        │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 4.2: Understanding Class-Based Views

**What Are Class-Based Views and Why Use Them?**

```
┌─────────────────────────────────────────────────────────────┐
│              CLASS-BASED VIEWS OVERVIEW                     │
│                                                             │
│  What Are CBVs?                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Views written as classes instead of functions      │   │
│  │  Inherit from Django's built-in view classes       │   │
│  │  Provide built-in functionality out of the box      │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  The CBV Hierarchy:                                         │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                                                    │   │
│  │                    View                             │   │
│  │                     │                               │   │
│  │          ┌──────────┼──────────┐                   │   │
│  │          │          │          │                   │   │
│  │    TemplateView  RedirectView  FormView            │   │
│  │          │          │          │                   │   │
│  │    ┌─────┼─────┐    │    ┌─────┼─────┐           │   │
│  │    │           │    │    │           │           │   │
│  │ ListView   DetailView  CreateView  UpdateView   │   │
│  │                          │           │           │   │
│  │                     DeleteView                     │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  FBV vs. CBV Comparison:                                    │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Feature          │  FBV         │  CBV             │   │
│  │  ──────────────────────────────────────────────────  │   │
│  │  Syntax           │  Functions   │  Classes         │   │
│  │  Flexibility      │  High        │  Moderate        │   │
│  │  Reusability      │  Low         │  High            │   │
│  │  Built-in Features│  Minimal     │  Many            │   │
│  │  Best For         │  Simple      │  Complex/Repetitive│ │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 4.3: CBV — The LEGO Block Analogy

**How Class-Based Views Save Time**

```
┌─────────────────────────────────────────────────────────────┐
│              CBV — LEGO BLOCK ANALOGY                       │
│                                                             │
│  Function-Based Views:                                      │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  You build everything from scratch each time        │   │
│  │  ┌─────────────────────────────────────────────────┐ │   │
│  │  │  def blog_list(request):                        │ │   │
│  │  │      posts = Post.objects.all()                 │ │   │
│  │  │      return render(request, 'list.html',        │ │   │
│  │  │                      {'posts': posts})          │ │   │
│  │  └─────────────────────────────────────────────────┘ │   │
│  │  ┌─────────────────────────────────────────────────┐ │   │
│  │  │  def another_list(request):                     │ │   │
│  │  │      items = Item.objects.all()                 │ │   │
│  │  │      return render(request, 'items.html',       │ │   │
│  │  │                      {'items': items})          │ │   │
│  │  └─────────────────────────────────────────────────┘ │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Class-Based Views:                                         │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Snap together pre-built LEGO blocks:              │   │
│  │  ┌─────────────────────────────────────────────────┐ │   │
│  │  │  class PostListView(ListView):                  │ │   │
│  │  │      model = Post                              │ │   │
│  │  │      template_name = 'list.html'               │ │   │
│  │  └─────────────────────────────────────────────────┘ │   │
│  │  ┌─────────────────────────────────────────────────┐ │   │
│  │  │  class ItemListView(ListView):                  │ │   │
│  │  │      model = Item                              │ │   │
│  │  │      template_name = 'items.html'              │ │   │
│  │  └─────────────────────────────────────────────────┘ │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Benefits:                                                  │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  ✅ Less code to write                              │   │
│  │  ✅ Built-in pagination                            │   │
│  │  ✅ Built-in form handling                         │   │
│  │  ✅ Built-in permission checking                   │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 4.4: Refactoring Blog List to Class-Based — Part 1

**Basic ListView Implementation**

```
┌─────────────────────────────────────────────────────────────┐
│              REFACTORING — POSTLISTVIEW — PART 1            │
│                                                             │
│  Before — Function-Based View:                              │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  def blog_list(request):                            │   │
│  │      posts = Post.objects.filter(                   │   │
│  │          status=Post.Status.PUBLISHED               │   │
│  │      ).select_related('author', 'category')        │   │
│  │                                                    │   │
│  │      context = {                                   │   │
│  │          'page_title': 'Blog Posts',               │   │
│  │          'posts': posts,                           │   │
│  │      }                                              │   │
│  │      return render(request, 'blog/blog_list.html',  │   │
│  │                      context)                      │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  After — Class-Based View:                                  │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  from django.views.generic import ListView          │   │
│  │                                                    │   │
│  │  class PostListView(ListView):                     │   │
│  │      model = Post                                   │   │
│  │      template_name = 'blog/blog_list.html'         │   │
│  │      context_object_name = 'posts'                 │   │
│  │      paginate_by = 10                              │   │
│  │      ordering = ['-published_at']                  │   │
│  │                                                    │   │
│  │      def get_queryset(self):                       │   │
│  │          return super().get_queryset().filter(     │   │
│  │              status=Post.Status.PUBLISHED          │   │
│  │          ).select_related('author', 'category')   │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Key Attributes:                                            │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  model          → Which model to display            │   │
│  │  template_name  → Which template to use             │   │
│  │  context_object_name → Variable name in template    │   │
│  │  paginate_by    → Items per page                   │   │
│  │  ordering       → Default sort order               │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 4.5: PostListView — Adding Search and Filters

**Customizing the Queryset**

```
┌─────────────────────────────────────────────────────────────┐
│              REFACTORING — POSTLISTVIEW — PART 2            │
│                                                             │
│  get_queryset with Search and Filters:                      │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  from django.db.models import Q, Count              │   │
│  │                                                    │   │
│  │  class PostListView(ListView):                     │   │
│  │      # ... attributes ...                          │   │
│  │                                                    │   │
│  │      def get_queryset(self):                       │   │
│  │          queryset = super().get_queryset()        │   │
│  │                                                    │   │
│  │          # Base query                              │   │
│  │          queryset = queryset.filter(               │   │
│  │              status=Post.Status.PUBLISHED,         │   │
│  │              published_at__lte=timezone.now()      │   │
│  │          ).select_related('author', 'category')   │   │
│  │                                                    │   │
│  │          # Search                                  │   │
│  │          search_query = self.request.GET.get('q')  │   │
│  │          if search_query:                          │   │
│  │              queryset = queryset.filter(           │   │
│  │                  Q(title__icontains=search_query) |│   │
│  │                  Q(content__icontains=search_query)│   │
│  │              )                                      │   │
│  │                                                    │   │
│  │          # Category filter                         │   │
│  │          category_slug = self.request.GET.get('category')│  │
│  │          if category_slug:                         │   │
│  │              queryset = queryset.filter(           │   │
│  │                  category__slug=category_slug      │   │
│  │              )                                      │   │
│  │                                                    │   │
│  │          # Author filter                           │   │
│  │          author_id = self.request.GET.get('author')│   │
│  │          if author_id:                             │   │
│  │              queryset = queryset.filter(           │   │
│  │                  author_id=author_id               │   │
│  │              )                                      │   │
│  │                                                    │   │
│  │          return queryset                           │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 4.6: PostListView — Adding Sorting

**Dynamic Sorting with URL Parameters**

```
┌─────────────────────────────────────────────────────────────┐
│              REFACTORING — POSTLISTVIEW — PART 3            │
│                                                             │
│  Sorting in get_queryset:                                   │
│  ┌─────────────────────────────────────────────────────┐   │
│  │      # Sorting                                     │   │
│  │      sort_by = self.request.GET.get('sort')        │   │
│  │      if sort_by:                                   │   │
│  │          sort_mapping = {                          │   │
│  │              'title': 'title',                     │   │
│  │              '-title': '-title',                   │   │
│  │              'created_at': 'created_at',           │   │
│  │              '-created_at': '-created_at',         │   │
│  │              'published_at': 'published_at',       │   │
│  │              '-published_at': '-published_at',     │   │
│  │              'author': 'author__username',         │   │
│  │              '-author': '-author__username',       │   │
│  │          }                                          │   │
│  │          if sort_by in sort_mapping:               │   │
│  │              queryset = queryset.order_by(         │   │
│  │                  sort_mapping[sort_by]             │   │
│  │              )                                      │   │
│  │                                                    │   │
│  │          return queryset                           │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Sorting Options in Template:                               │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  <select name="sort">                               │   │
│  │      <option value="-published_at">Newest First</option>│  │
│  │      <option value="published_at">Oldest First</option>│  │
│  │      <option value="title">Title A-Z</option>       │   │
│  │      <option value="-title">Title Z-A</option>     │   │
│  │      <option value="-created_at">Recently Created</option>│ │
│  │      <option value="author">Author A-Z</option>    │   │
│  │  </select>                                          │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 4.7: PostListView — Adding Context Data

**Providing Extra Data to Templates**

```
┌─────────────────────────────────────────────────────────────┐
│              REFACTORING — POSTLISTVIEW — PART 4            │
│                                                             │
│  get_context_data for Extra Data:                           │
│  ┌─────────────────────────────────────────────────────┐   │
│  │      def get_context_data(self, **kwargs):          │   │
│  │          context = super().get_context_data(**kwargs)│  │
│  │                                                    │   │
│  │          # Categories with post counts             │   │
│  │          categories = Category.objects.annotate(   │   │
│  │              post_count=Count('posts', filter=Q(   │   │
│  │                  posts__status=Post.Status.PUBLISHED│   │
│  │              ))                                     │   │
│  │          ).filter(post_count__gt=0)               │   │
│  │                                                    │   │
│  │          # Authors with published posts            │   │
│  │          authors = User.objects.filter(            │   │
│  │              blog_posts__status=Post.Status.PUBLISHED│   │
│  │          ).distinct().order_by('username')         │   │
│  │                                                    │   │
│  │          context['categories'] = categories        │   │
│  │          context['authors'] = authors              │   │
│  │          context['page_title'] = 'Blog Posts'      │   │
│  │                                                    │   │
│  │          # Current filters for template           │   │
│  │          context['current_filters'] = {            │   │
│  │              'q': self.request.GET.get('q', ''),   │   │
│  │              'category': self.request.GET.get('category', ''),│  │
│  │              'author': self.request.GET.get('author', ''),│  │
│  │              'sort': self.request.GET.get('sort', ''),│  │
│  │          }                                          │   │
│  │                                                    │   │
│  │          return context                            │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 4.8: Refactoring Post Detail to Class-Based

**DetailView Implementation**

```
┌─────────────────────────────────────────────────────────────┐
│              REFACTORING — POSTDETAILVIEW                   │
│                                                             │
│  Code:                                                      │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  from django.views.generic import DetailView        │   │
│  │                                                    │   │
│  │  class PostDetailView(DetailView):                 │   │
│  │      model = Post                                   │   │
│  │      template_name = 'blog/post_detail.html'       │   │
│  │      context_object_name = 'post'                  │   │
│  │      slug_field = 'slug'                           │   │
│  │      slug_url_kwarg = 'slug'                       │   │
│  │                                                    │   │
│  │      def get_queryset(self):                       │   │
│  │          queryset = super().get_queryset()        │   │
│  │                                                    │   │
│  │          # Allow authors to see their drafts      │   │
│  │          if self.request.user.is_authenticated:    │   │
│  │              return queryset.filter(               │   │
│  │                  Q(status=Post.Status.PUBLISHED) |│   │
│  │                  Q(author=self.request.user)       │   │
│  │              )                                      │   │
│  │          else:                                      │   │
│  │              return queryset.filter(               │   │
│  │                  status=Post.Status.PUBLISHED      │   │
│  │              )                                      │   │
│  │                                                    │   │
│  │      def get_context_data(self, **kwargs):        │   │
│  │          context = super().get_context_data(**kwargs)│  │
│  │          post = self.get_object()                 │   │
│  │                                                    │   │
│  │          recent_posts = Post.objects.filter(       │   │
│  │              status=Post.Status.PUBLISHED          │   │
│  │          ).exclude(id=post.id).order_by('-published_at')[:5]│ │
│  │                                                    │   │
│  │          comments = post.comments.filter(         │   │
│  │              is_approved=True                      │   │
│  │          ).order_by('created_at')                 │   │
│  │                                                    │   │
│  │          context['recent_posts'] = recent_posts   │   │
│  │          context['comments'] = comments           │   │
│  │          return context                            │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 4.9: Refactoring CRUD — CreateView

**CreateView Implementation with Mixins**

```
┌─────────────────────────────────────────────────────────────┐
│              REFACTORING — POSTCREATEVIEW                   │
│                                                             │
│  Code:                                                      │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  from django.views.generic import CreateView        │   │
│  │  from django.contrib.auth.mixins import LoginRequiredMixin│  │
│  │  from django.urls import reverse_lazy               │   │
│  │                                                    │   │
│  │  class PostCreateView(LoginRequiredMixin, CreateView):│   │
│  │      model = Post                                   │   │
│  │      form_class = PostForm                         │   │
│  │      template_name = 'blog/post_form.html'         │   │
│  │                                                    │   │
│  │      def get_context_data(self, **kwargs):         │   │
│  │          context = super().get_context_data(**kwargs)│  │
│  │          context['title'] = 'Create New Post'      │   │
│  │          context['submit_text'] = 'Create Post'    │   │
│  │          return context                             │   │
│  │                                                    │   │
│  │      def form_valid(self, form):                   │   │
│  │          form.instance.author = self.request.user  │   │
│  │                                                    │   │
│  │          if form.instance.status == Post.Status.PUBLISHED:│  │
│  │              form.instance.published_at = timezone.now()│  │
│  │                                                    │   │
│  │          response = super().form_valid(form)       │   │
│  │          messages.success(self.request,            │   │
│  │              f'Post "{form.instance.title}" created!')│   │
│  │          return response                            │   │
│  │                                                    │   │
│  │      def get_success_url(self):                    │   │
│  │          return reverse_lazy('blog:post_detail',   │   │
│  │                              kwargs={'slug': self.object.slug})│   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Key Mixins:                                                │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  LoginRequiredMixin → User must be logged in        │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 4.10: Refactoring CRUD — UpdateView

**UpdateView with UserPassesTestMixin**

```
┌─────────────────────────────────────────────────────────────┐
│              REFACTORING — POSTUPDATEVIEW                   │
│                                                             │
│  Code:                                                      │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  from django.views.generic import UpdateView        │   │
│  │  from django.contrib.auth.mixins import LoginRequiredMixin,│  │
│  │      UserPassesTestMixin                            │   │
│  │                                                    │   │
│  │  class PostUpdateView(LoginRequiredMixin,           │   │
│  │                       UserPassesTestMixin, UpdateView):│   │
│  │      model = Post                                   │   │
│  │      form_class = PostForm                         │   │
│  │      template_name = 'blog/post_form.html'         │   │
│  │      slug_field = 'slug'                           │   │
│  │      slug_url_kwarg = 'slug'                       │   │
│  │                                                    │   │
│  │      def test_func(self):                          │   │
│  │          """Check that user is the post author.""" │   │
│  │          post = self.get_object()                  │   │
│  │          return self.request.user == post.author   │   │
│  │                                                    │   │
│  │      def get_context_data(self, **kwargs):         │   │
│  │          context = super().get_context_data(**kwargs)│  │
│  │          context['title'] = f'Edit: {self.object.title}'│  │
│  │          context['submit_text'] = 'Update Post'    │   │
│  │                                                    │   │
│  │          # Pre-populate tags_input                 │   │
│  │          if self.object.tags.exists():             │   │
│  │              tags = [tag.name for tag in self.object.tags.all()]│  │
│  │              context['form'].fields['tags_input'].initial = ', '.join(tags)│  │
│  │          return context                            │   │
│  │                                                    │   │
│  │      def get_success_url(self):                    │   │
│  │          return reverse_lazy('blog:post_detail',   │   │
│  │                              kwargs={'slug': self.object.slug})│   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 4.11: Understanding Mixins and Method Order

**The Importance of Correct Mixin Order**

```
┌─────────────────────────────────────────────────────────────┐
│                    UNDERSTANDING MIXINS                     │
│                                                             │
│  What Are Mixins?                                           │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Reusable classes that provide specific functionality│   │
│  │  "Mix in" additional behavior to your views        │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Common Mixins:                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Mixin                    │  Purpose                 │   │
│  │  ──────────────────────────────────────────────────  │   │
│  │  LoginRequiredMixin      │  Require authenticated   │   │
│  │  UserPassesTestMixin     │  Require custom test     │   │
│  │  PermissionRequiredMixin │  Require permissions     │   │
│  │  FormMixin               │  Form handling           │   │
│  │  ContextMixin            │  Add context data        │   │
│  │  SingleObjectMixin       │  Object fetching         │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Mixin Order Matters!                                       │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  ✅ CORRECT: Mixins first, base view last           │   │
│  │  class PostUpdateView(LoginRequiredMixin,           │   │
│  │                       UserPassesTestMixin,          │   │
│  │                       UpdateView):                   │   │
│  │      pass                                            │   │
│  │                                                    │   │
│  │  ❌ WRONG: Mixins after base view                   │   │
│  │  class PostUpdateView(UpdateView,                   │   │
│  │                       LoginRequiredMixin,           │   │
│  │                       UserPassesTestMixin):          │   │
│  │      pass                                            │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Why? Method Resolution Order (MRO) matters!              │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 4.12: Refactoring CRUD — DeleteView

**DeleteView with Confirmation**

```
┌─────────────────────────────────────────────────────────────┐
│              REFACTORING — POSTDELETEVIEW                   │
│                                                             │
│  Code:                                                      │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  from django.views.generic import DeleteView        │   │
│  │                                                    │   │
│  │  class PostDeleteView(LoginRequiredMixin,           │   │
│  │                       UserPassesTestMixin,          │   │
│  │                       DeleteView):                   │   │
│  │      model = Post                                   │   │
│  │      template_name = 'blog/post_confirm_delete.html'│   │
│  │      slug_field = 'slug'                           │   │
│  │      slug_url_kwarg = 'slug'                       │   │
│  │      success_url = reverse_lazy('blog:blog_list')  │   │
│  │                                                    │   │
│  │      def test_func(self):                          │   │
│  │          post = self.get_object()                  │   │
│  │          return self.request.user == post.author   │   │
│  │                                                    │   │
│  │      def delete(self, request, *args, **kwargs):   │   │
│  │          post = self.get_object()                  │   │
│  │          post_title = post.title                   │   │
│  │          response = super().delete(request, *args, **kwargs)│  │
│  │          messages.success(request,                 │   │
│  │              f'Post "{post_title}" deleted.')       │   │
│  │          return response                            │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Key Features:                                              │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  ✅ UserPassesTestMixin for ownership check         │   │
│  │  ✅ success_url for redirect after deletion         │   │
│  │  ✅ Override delete() for custom messaging          │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 4.13: Refactoring Home to Class-Based

**TemplateView Implementation**

```
┌─────────────────────────────────────────────────────────────┐
│              REFACTORING — HOMEPAGE                         │
│                                                             │
│  Code:                                                      │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  from django.views.generic import TemplateView      │   │
│  │                                                    │   │
│  │  class HomeView(TemplateView):                     │   │
│  │      """Class-based view for the homepage."""      │   │
│  │      template_name = 'blog/home.html'              │   │
│  │                                                    │   │
│  │      def get_context_data(self, **kwargs):        │   │
│  │          context = super().get_context_data(**kwargs)│  │
│  │                                                    │   │
│  │          # Recent posts                            │   │
│  │          recent_posts = Post.objects.filter(       │   │
│  │              status=Post.Status.PUBLISHED,         │   │
│  │              published_at__lte=timezone.now()      │   │
│  │          ).order_by('-published_at')[:5]          │   │
│  │                                                    │   │
│  │          # Categories with post counts            │   │
│  │          categories = Category.objects.annotate(   │   │
│  │              post_count=Count('posts', filter=Q(   │   │
│  │                  posts__status=Post.Status.PUBLISHED│   │
│  │              ))                                     │   │
│  │          ).filter(post_count__gt=0)               │   │
│  │                                                    │   │
│  │          context['recent_posts'] = recent_posts   │   │
│  │          context['categories'] = categories       │   │
│  │          context['year'] = timezone.now().year    │   │
│  │          return context                            │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  TemplateView Benefits:                                     │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  ✅ Simple view for static pages                    │   │
│  │  ✅ Just override get_context_data()               │   │
│  │  ✅ No model or form needed                        │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 4.14: Updating URLs for Class-Based Views

**Using `.as_view()` for CBVs**

```
┌─────────────────────────────────────────────────────────────┐
│              UPDATING URLS FOR CBVS                         │
│                                                             │
│  App URLs (`blog/urls.py`):                                │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  from django.urls import path                       │   │
│  │  from django.contrib.auth import views as auth_views│   │
│  │  from . import views                                │   │
│  │                                                    │   │
│  │  app_name = 'blog'                                 │   │
│  │                                                    │   │
│  │  urlpatterns = [                                    │   │
│  │      # Public views (class-based)                  │   │
│  │      path('', views.HomeView.as_view(),            │   │
│  │           name='home'),                            │   │
│  │      path('about/', views.about,                   │   │
│  │           name='about'),  # Keep FBV               │   │
│  │      path('blog/', views.PostListView.as_view(),   │   │
│  │           name='blog_list'),                       │   │
│  │      path('blog/<slug:slug>/',                     │   │
│  │           views.PostDetailView.as_view(),          │   │
│  │           name='post_detail'),                     │   │
│  │      path('category/<slug:slug>/',                 │   │
│  │           views.category_detail,                   │   │
│  │           name='category_detail'),  # Keep FBV     │   │
│  │      path('tag/<slug:slug>/',                     │   │
│  │           views.tag_detail,                        │   │
│  │           name='tag_detail'),  # Keep FBV          │   │
│  │                                                    │   │
│  │      # CRUD views (class-based)                   │   │
│  │      path('post/create/',                         │   │
│  │           views.PostCreateView.as_view(),          │   │
│  │           name='post_create'),                    │   │
│  │      path('post/<slug:slug>/edit/',               │   │
│  │           views.PostUpdateView.as_view(),          │   │
│  │           name='post_edit'),                      │   │
│  │      path('post/<slug:slug>/delete/',             │   │
│  │           views.PostDeleteView.as_view(),          │   │
│  │           name='post_delete'),                    │   │
│  │                                                    │   │
│  │      # Comment views (function-based)             │   │
│  │      path('post/<slug:post_slug>/comment/',       │   │
│  │           views.comment_create,                   │   │
│  │           name='comment_create'),                 │   │
│  │                                                    │   │
│  │      # Authentication views                       │   │
│  │      path('login/', auth_views.LoginView.as_view(),│   │
│  │           name='login'),                          │   │
│  │      path('logout/', auth_views.LogoutView.as_view(),│  │
│  │           name='logout'),                         │   │
│  │      path('register/', views.register,            │   │
│  │           name='register'),                       │   │
│  │  ]                                                 │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 4.15: Updating Template for Search and Filtering — Part 1

**Search and Filter Form**

```
┌─────────────────────────────────────────────────────────────┐
│              TEMPLATE — SEARCH AND FILTER                   │
│                                                             │
│  Search and Filter Bar:                                    │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  <!-- Search and Filter Bar -->                    │   │
│  │  <div class="content" style="margin-bottom: 2rem;">│   │
│  │      <form method="get" style="display: flex;      │   │
│  │            flex-wrap: wrap; gap: 1rem;">           │   │
│  │                                                    │   │
│  │          <!-- Search -->                           │   │
│  │          <div style="flex: 2; min-width: 200px;">  │   │
│  │              <label>Search</label>                 │   │
│  │              <input type="text" name="q"           │   │
│  │                     value="{{ current_filters.q }}"│   │
│  │                     placeholder="Search posts..."> │   │
│  │          </div>                                     │   │
│  │                                                    │   │
│  │          <!-- Category Filter -->                  │   │
│  │          <div style="flex: 1; min-width: 150px;">  │   │
│  │              <label>Category</label>               │   │
│  │              <select name="category">              │   │
│  │                  <option value="">All Categories</option>│  │
│  │                  {% for category in categories %}  │   │
│  │                      <option value="{{ category.slug }}"│  │
│  │                          {% if current_filters.category == category.slug %}│  │
│  │                              selected              │   │
│  │                          {% endif %}>              │   │
│  │                          {{ category.name }}       │   │
│  │                          ({{ category.post_count }})│   │
│  │                      </option>                     │   │
│  │                  {% endfor %}                      │   │
│  │              </select>                             │   │
│  │          </div>                                     │   │
│  │                                                    │   │
│  │          <!-- Author Filter -->                    │   │
│  │          <div style="flex: 1; min-width: 150px;">  │   │
│  │              <label>Author</label>                 │   │
│  │              <select name="author">                │   │
│  │                  <option value="">All Authors</option>│  │
│  │                  {% for author in authors %}       │   │
│  │                      <option value="{{ author.id }}"│  │
│  │                          {% if current_filters.author == author.id|stringformat:"s" %}│  │
│  │                              selected              │   │
│  │                          {% endif %}>              │   │
│  │                          {{ author.get_full_name  │   │
│  │                          |default:author.username }}│   │
│  │                      </option>                     │   │
│  │                  {% endfor %}                      │   │
│  │              </select>                             │   │
│  │          </div>                                     │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 4.16: Updating Template for Search and Filtering — Part 2

**Sorting and Action Buttons**

```
┌─────────────────────────────────────────────────────────────┐
│              TEMPLATE — SORTING AND ACTIONS                 │
│                                                             │
│  Sorting and Actions:                                       │
│  ┌─────────────────────────────────────────────────────┐   │
│  │          <!-- Sort -->                              │   │
│  │          <div style="flex: 1; min-width: 150px;">  │   │
│  │              <label>Sort By</label>                 │   │
│  │              <select name="sort">                   │   │
│  │                  <option value="-published_at"      │   │
│  │                      {% if current_filters.sort == '-published_at' %}│  │
│  │                          selected                  │   │
│  │                      {% endif %}>                  │   │
│  │                      Newest First                   │   │
│  │                  </option>                          │   │
│  │                  <option value="published_at"       │   │
│  │                      {% if current_filters.sort == 'published_at' %}│  │
│  │                          selected                  │   │
│  │                      {% endif %}>                  │   │
│  │                      Oldest First                   │   │
│  │                  </option>                          │   │
│  │                  <option value="title"              │   │
│  │                      {% if current_filters.sort == 'title' %}│  │
│  │                          selected                  │   │
│  │                      {% endif %}>                  │   │
│  │                      Title A-Z                      │   │
│  │                  </option>                          │   │
│  │                  <option value="-title"             │   │
│  │                      {% if current_filters.sort == '-title' %}│  │
│  │                          selected                  │   │
│  │                      {% endif %}>                  │   │
│  │                      Title Z-A                      │   │
│  │                  </option>                          │   │
│  │              </select>                              │   │
│  │          </div>                                      │   │
│  │                                                    │   │
│  │          <!-- Action Buttons -->                   │   │
│  │          <div style="flex: 0 0 auto;">             │   │
│  │              <button type="submit" style="         │   │
│  │                  background: #3498db; color: white;│   │
│  │                  border: none; padding: 0.5rem 1.5rem;│  │
│  │                  border-radius: 4px; cursor: pointer;">│  │
│  │                  Apply Filters                     │   │
│  │              </button>                              │   │
│  │              <a href="{% url 'blog:blog_list' %}"   │   │
│  │                 style="background: #95a5a6;        │   │
│  │                 color: white; padding: 0.5rem 1.5rem;│  │
│  │                 border-radius: 4px;                │   │
│  │                 text-decoration: none;">           │   │
│  │                  Clear                             │   │
│  │              </a>                                   │   │
│  │          </div>                                     │   │
│  │      </form>                                        │   │
│  │  </div>                                              │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 4.17: Template — Posts Loop with Pagination

**Displaying Posts with Pagination Controls**

```
┌─────────────────────────────────────────────────────────────┐
│              TEMPLATE — POSTS WITH PAGINATION               │
│                                                             │
│  Posts Loop:                                                │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  <!-- Posts List -->                               │   │
│  │  <div class="content">                              │   │
│  │      {% if page_obj %}                             │   │
│  │          {% for post in page_obj %}                │   │
│  │              <div style="margin-bottom: 2rem;     │   │
│  │                   padding-bottom: 2rem;            │   │
│  │                   border-bottom: 1px solid #eee;"> │   │
│  │                  <h2>                             │   │
│  │                      <a href="{{ post.get_absolute_url }}"│  │
│  │                         style="color: #2c3e50;    │   │
│  │                         text-decoration: none;">  │   │
│  │                          {{ post.title }}          │   │
│  │                      </a>                         │   │
│  │                  </h2>                            │   │
│  │                  <p style="color: #7f8c8d;">      │   │
│  │                      By {{ post.author.get_full_name │   │
│  │                      |default:post.author.username }} │   │
│  │                      on {{ post.published_at|date:"F j, Y" }}│  │
│  │                      {% if post.category %}       │   │
│  │                          in <a href="{% url 'blog:category_detail' │  │
│  │                              post.category.slug %}">│   │
│  │                              {{ post.category.name }}│   │
│  │                          </a>                     │   │
│  │                      {% endif %}                  │   │
│  │                                                    │   │
│  │                      {% if user == post.author %}  │   │
│  │                          <span>                    │   │
│  │                              <a href="{% url 'blog:post_edit' │  │
│  │                                  post.slug %}">    │   │
│  │                                  Edit              │   │
│  │                              </a>                  │   │
│  │                              |                     │   │
│  │                              <a href="{% url 'blog:post_delete' │  │
│  │                                  post.slug %}">    │   │
│  │                                  Delete            │   │
│  │                              </a>                  │   │
│  │                          </span>                   │   │
│  │                      {% endif %}                   │   │
│  │                  </p>                              │   │
│  │                  <p>{{ post.excerpt|truncatewords:30 }}</p>│  │
│  │              </div>                               │   │
│  │          {% endfor %}                             │   │
│  │      {% else %}                                    │   │
│  │          <p>No blog posts available.</p>          │   │
│  │      {% endif %}                                  │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 4.18: Template — Pagination Controls

**Rendering Pagination with Filter Preservation**

```
┌─────────────────────────────────────────────────────────────┐
│              TEMPLATE — PAGINATION CONTROLS                 │
│                                                             │
│  Pagination Controls:                                       │
│  ┌─────────────────────────────────────────────────────┐   │
│  │      <!-- Pagination -->                            │   │
│  │      {% if is_paginated %}                          │   │
│  │          <div style="display: flex;                │   │
│  │               justify-content: center;             │   │
│  │               gap: 0.5rem; margin-top: 2rem;">    │   │
│  │                                                    │   │
│  │              {% if page_obj.has_previous %}        │   │
│  │                  <a href="?page=1                  │   │
│  │                     {% for key, value in request.GET.items %}│  │
│  │                         {% if key != 'page' %}     │   │
│  │                             &{{ key }}={{ value }} │   │
│  │                         {% endif %}                │   │
│  │                     {% endfor %}"                  │   │
│  │                     style="padding: 0.5rem 1rem;  │   │
│  │                     background: #3498db;           │   │
│  │                     color: white;                  │   │
│  │                     text-decoration: none;         │   │
│  │                     border-radius: 4px;">          │   │
│  │                      First                         │   │
│  │                  </a>                              │   │
│  │                                                    │   │
│  │                  <a href="?page=                   │   │
│  │                     {{ page_obj.previous_page_number }}│   │
│  │                     {% for key, value in request.GET.items %}│  │
│  │                         {% if key != 'page' %}     │   │
│  │                             &{{ key }}={{ value }} │   │
│  │                         {% endif %}                │   │
│  │                     {% endfor %}"                  │   │
│  │                     style="padding: 0.5rem 1rem;  │   │
│  │                     background: #3498db;           │   │
│  │                     color: white;                  │   │
│  │                     text-decoration: none;         │   │
│  │                     border-radius: 4px;">          │   │
│  │                      Previous                      │   │
│  │                  </a>                              │   │
│  │              {% endif %}                            │   │
│  │                                                    │   │
│  │              <span style="padding: 0.5rem 1rem;">  │   │
│  │                  Page {{ page_obj.number }} of     │   │
│  │                  {{ page_obj.paginator.num_pages }}│   │
│  │              </span>                               │   │
│  │                                                    │   │
│  │              {% if page_obj.has_next %}            │   │
│  │                  <a href="?page=                   │   │
│  │                     {{ page_obj.next_page_number }}│   │
│  │                     {% for key, value in request.GET.items %}│  │
│  │                         {% if key != 'page' %}     │   │
│  │                             &{{ key }}={{ value }} │   │
│  │                         {% endif %}                │   │
│  │                     {% endfor %}"                  │   │
│  │                     style="padding: 0.5rem 1rem;  │   │
│  │                     background: #3498db;           │   │
│  │                     color: white;                  │   │
│  │                     text-decoration: none;         │   │
│  │                     border-radius: 4px;">          │   │
│  │                      Next                          │   │
│  │                  </a>                              │   │
│  │                                                    │   │
│  │                  <a href="?page=                   │   │
│  │                     {{ page_obj.paginator.num_pages }}│  │
│  │                     {% for key, value in request.GET.items %}│  │
│  │                         {% if key != 'page' %}     │   │
│  │                             &{{ key }}={{ value }} │   │
│  │                         {% endif %}                │   │
│  │                     {% endfor %}"                  │   │
│  │                     style="padding: 0.5rem 1rem;  │   │
│  │                     background: #3498db;           │   │
│  │                     color: white;                  │   │
│  │                     text-decoration: none;         │   │
│  │                     border-radius: 4px;">          │   │
│  │                      Last                          │   │
│  │                  </a>                              │   │
│  │              {% endif %}                            │   │
│  │          </div>                                     │   │
│  │      {% endif %}                                    │   │
│  │  </div>                                              │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 4.19: Verification — Testing All Features

**Comprehensive Verification Checklist**

```
┌─────────────────────────────────────────────────────────────┐
│              VERIFICATION CHECKLIST                         │
│                                                             │
│  Step 1: Test Class-Based Views                            │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  1. Start server: python manage.py runserver        │   │
│  │  2. Visit all pages: /, /blog/, /about/            │   │
│  │  3. Verify all views render correctly               │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Step 2: Test Search                                       │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  1. Visit /blog/                                    │   │
│  │  2. Type a search term (e.g., "Django")            │   │
│  │  3. Click "Apply Filters"                           │   │
│  │  4. Verify only matching posts appear               │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Step 3: Test Filtering                                    │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  1. Select a category from dropdown                  │   │
│  │  2. Click "Apply Filters"                           │   │
│  │  3. Verify only posts in that category appear       │   │
│  │  4. Test author filter similarly                    │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Step 4: Test Sorting                                      │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  1. Select different sort options                   │   │
│  │  2. Verify posts are reordered correctly            │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Step 5: Test Pagination                                   │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  1. Create more than 10 posts (if needed)           │   │
│  │  2. Navigate through pages                          │   │
│  │  3. Verify filter parameters persist when paginating│   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 4.20: What You've Learned in Part 4

**Skills Acquired and What You've Built**

```
┌─────────────────────────────────────────────────────────────┐
│              WHAT YOU'VE LEARNED — PART 4                  │
│                                                             │
│  ✅ Skills Acquired:                                        │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  • Understanding class-based views                  │   │
│  │  • Refactoring function views to class views        │   │
│  │  • Implementing search with Q objects              │   │
│  │  • Adding filtering with URL parameters             │   │
│  │  • Using pagination                                  │   │
│  │  • Working with mixins                              │   │
│  │  • Handling form validation in class-based views   │   │
│  │  • Using reverse_lazy for URL resolution           │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ✅ What You've Built:                                      │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  • A searchable blog listing                        │   │
│  │  • Filterable posts by category, author, and status│   │
│  │  • Pagination for large post lists                 │   │
│  │  • Clean, maintainable class-based views           │   │
│  │  • Consistent message handling                     │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  🎯 Ready for Part 5:                                       │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  In Part 5, we'll implement user profiles,          │   │
│  │  dashboards, and password reset!                   │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 4.21: Quick Reference — CBV Patterns

**Common Class-Based View Patterns**

```
┌─────────────────────────────────────────────────────────────┐
│              CBV PATTERNS — QUICK REFERENCE                 │
│                                                             │
│  ListView:                                                  │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  class MyListView(ListView):                        │   │
│  │      model = MyModel                                │   │
│  │      template_name = 'app/list.html'               │   │
│  │      context_object_name = 'objects'               │   │
│  │      paginate_by = 10                              │   │
│  │                                                    │   │
│  │      def get_queryset(self):                       │   │
│  │          return MyModel.objects.filter(status='active')│  │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  DetailView:                                                │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  class MyDetailView(DetailView):                    │   │
│  │      model = MyModel                                │   │
│  │      template_name = 'app/detail.html'             │   │
│  │      slug_field = 'slug'                           │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  CreateView:                                                │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  class MyCreateView(LoginRequiredMixin, CreateView):│   │
│  │      model = MyModel                                │   │
│  │      form_class = MyForm                           │   │
│  │      template_name = 'app/form.html'               │   │
│  │      success_url = reverse_lazy('app:list')        │   │
│  │                                                    │   │
│  │      def form_valid(self, form):                   │   │
│  │          form.instance.author = self.request.user  │   │
│  │          return super().form_valid(form)           │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  UpdateView:                                                │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  class MyUpdateView(LoginRequiredMixin,             │   │
│  │                     UserPassesTestMixin, UpdateView):│   │
│  │      model = MyModel                                │   │
│  │      form_class = MyForm                           │   │
│  │                                                    │   │
│  │      def test_func(self):                          │   │
│  │          obj = self.get_object()                   │   │
│  │          return self.request.user == obj.author    │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 4.22: Proceed to Part 5

**Preview of What's Coming**

```
┌─────────────────────────────────────────────────────────────┐
│                COMING UP IN PART 5                          │
│                                                             │
│  🔐 Authentication, Users, Sessions, Permissions, Security  │
│                                                             │
│  What We'll Build:                                          │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  • User profiles with avatar, bio, social links     │   │
│  │  • User dashboard with statistics                   │   │
│  │  • Password reset via email                         │   │
│  │  • Account management (edit profile, change password)│   │
│  │  • Permissions and access control                   │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  What We'll Learn:                                          │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  • One-to-one profiles with User model             │   │
│  │  • Django signals for auto-creation                │   │
│  │  • Profile views and forms                         │   │
│  │  • User dashboards                                  │   │
│  │  • Password reset workflow                         │   │
│  │  • Email backends                                   │   │
│  │  • Permissions and groups                          │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Preview of Features:                                       │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  ┌─────────────────────────────────────────────────┐│   │
│  │  │  User Profile                                  ││   │
│  │  │  ┌─────────────────────────────────────────────┐││   │
│  │  │  │  [Avatar]  John Doe                        │││   │
│  │  │  │  Bio: Django developer                     │││   │
│  │  │  │  Location: New York                        │││   │
│  │  │  │  GitHub: johndoe                          │││   │
│  │  │  │  Twitter: @johndoe                        │││   │
│  │  │  └─────────────────────────────────────────────┘││   │
│  │  └─────────────────────────────────────────────────┘│   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Let's build user profiles! 🔐                            │
└─────────────────────────────────────────────────────────────┘
```

---

# PART 5: AUTHENTICATION, USERS, SESSIONS, PERMISSIONS, AND SECURITY

---

## Slide 5.1: Part 5 Introduction

**Learning Objectives**

```
┌─────────────────────────────────────────────────────────────┐
│                    PART 5 OVERVIEW                          │
│                                                             │
│  🎯 Learning Objectives:                                    │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  ✅ Create one-to-one profiles with User model      │   │
│  │  ✅ Use Django signals for auto-creation            │   │
│  │  ✅ Build profile views and forms                   │   │
│  │  ✅ Create user dashboards with statistics          │   │
│  │  ✅ Implement password reset workflow               │   │
│  │  ✅ Configure email backends                        │   │
│  │  ✅ Understand permissions and groups              │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  🏗️ What We'll Build:                                      │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  • User profiles with avatar, bio, social links     │   │
│  │  • User dashboard with statistics                   │   │
│  │  • Password reset via email                         │   │
│  │  • Account management (edit profile, change password)│   │
│  │  • Permissions and access control                   │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  📚 Key Concepts:                                          │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  • OneToOneField relationships                     │   │
│  │  • Django signals (post_save)                      │   │
│  │  • UserCreationForm                                │   │
│  │  • PasswordResetView and friends                   │   │
│  │  • Email backends (console vs SMTP)                │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 5.2: The Built-in User System

**Understanding Django's Authentication Framework**

```
┌─────────────────────────────────────────────────────────────┐
│              DJANGO'S BUILT-IN USER SYSTEM                  │
│                                                             │
│  django.contrib.auth.models.User:                           │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Fields:                                            │   │
│  │  • username    → Unique identifier                  │   │
│  │  • password    → Hashed password                    │   │
│  │  • email       → Email address                      │   │
│  │  • first_name  → First name                         │   │
│  │  • last_name   → Last name                          │   │
│  │  • is_staff    → Admin access                       │   │
│  │  • is_active   → Account active                     │   │
│  │  • is_superuser→ Full permissions                   │   │
│  │  • date_joined → Registration date                  │   │
│  │  • last_login  → Last login time                    │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Extending the User Model:                                  │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  1. OneToOneField to Profile (recommended)         │   │
│  │  2. AbstractUser (custom user model)               │   │
│  │  3. AbstractBaseUser (full custom)                 │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Authentication Backends:                                   │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  ModelBackend (default):                            │   │
│  │  • Authenticates against User model                 │   │
│  │  • Checks username and password                     │   │
│  │  • Permissions via groups and user permissions     │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 5.3: Creating the Profile Model — Part 1

**Extending User with One-to-One Profile**

```
┌─────────────────────────────────────────────────────────────┐
│              CREATING THE PROFILE MODEL — PART 1            │
│                                                             │
│  Code:                                                      │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  from django.contrib.auth.models import User        │   │
│  │                                                    │   │
│  │  class Profile(models.Model):                      │   │
│  │      """User profile extending built-in User."""   │   │
│  │                                                    │   │
│  │      user = models.OneToOneField(                  │   │
│  │          User,                                      │   │
│  │          on_delete=models.CASCADE,                  │   │
│  │          related_name='profile'                    │   │
│  │      )                                              │   │
│  │                                                    │   │
│  │      # Personal information                        │   │
│  │      bio = models.TextField(                       │   │
│  │          max_length=500, blank=True                │   │
│  │      )                                              │   │
│  │      location = models.CharField(                  │   │
│  │          max_length=100, blank=True                │   │
│  │      )                                              │   │
│  │      website = models.URLField(blank=True)         │   │
│  │      twitter = models.CharField(                   │   │
│  │          max_length=50, blank=True                 │   │
│  │      )                                              │   │
│  │      github = models.CharField(                    │   │
│  │          max_length=50, blank=True                 │   │
│  │      )                                              │   │
│  │      linkedin = models.CharField(                  │   │
│  │          max_length=100, blank=True                │   │
│  │      )                                              │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 5.4: Creating the Profile Model — Part 2

**Avatar, Preferences, and Methods**

```
┌─────────────────────────────────────────────────────────────┐
│              CREATING THE PROFILE MODEL — PART 2            │
│                                                             │
│  Code:                                                      │
│  ┌─────────────────────────────────────────────────────┐   │
│  │      # Avatar                                       │   │
│  │      avatar = models.ImageField(                    │   │
│  │          upload_to='avatars/%Y/%m/%d/',             │   │
│  │          blank=True,                                │   │
│  │          help_text="Profile picture"                 │   │
│  │      )                                              │   │
│  │                                                    │   │
│  │      # Preferences                                 │   │
│  │      email_notifications = models.BooleanField(     │   │
│  │          default=True                               │   │
│  │      )                                              │   │
│  │      show_email = models.BooleanField(              │   │
│  │          default=False                              │   │
│  │      )                                              │   │
│  │                                                    │   │
│  │      # Timestamps                                   │   │
│  │      created_at = models.DateTimeField(             │   │
│  │          auto_now_add=True                          │   │
│  │      )                                              │   │
│  │      updated_at = models.DateTimeField(             │   │
│  │          auto_now=True                              │   │
│  │      )                                              │   │
│  │                                                    │   │
│  │      def __str__(self):                             │   │
│  │          return f"{self.user.username}'s Profile"   │   │
│  │                                                    │   │
│  │      def get_avatar_url(self):                     │   │
│  │          if self.avatar and hasattr(self.avatar, 'url'):│  │
│  │              return self.avatar.url                │   │
│  │          return '/static/blog/images/default-avatar.png'│  │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 5.5: Creating Profile via Signals

**Auto-Creation with Django Signals**

```
┌─────────────────────────────────────────────────────────────┐
│              CREATING PROFILES VIA SIGNALS                  │
│                                                             │
│  What Are Signals?                                          │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Allow decoupled communication between parts       │   │
│  │  "Notify" when something happens                   │   │
│  │  post_save runs after a model is saved            │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Signal Handlers (`blog/signals.py`):                       │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  from django.db.models.signals import post_save     │   │
│  │  from django.contrib.auth.models import User        │   │
│  │  from django.dispatch import receiver               │   │
│  │  from .models import Profile                       │   │
│  │                                                    │   │
│  │  @receiver(post_save, sender=User)                 │   │
│  │  def create_user_profile(sender, instance, created, │   │
│  │                          **kwargs):                │   │
│  │      """Create Profile when User is created."""    │   │
│  │      if created:                                   │   │
│  │          Profile.objects.get_or_create(user=instance)│  │
│  │                                                    │   │
│  │  @receiver(post_save, sender=User)                 │   │
│  │  def save_user_profile(sender, instance, **kwargs):│   │
│  │      """Save Profile when User is saved."""        │   │
│  │      instance.profile.save()                       │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Register Signals in `apps.py`:                            │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  class BlogConfig(AppConfig):                       │   │
│  │      # ...                                         │   │
│  │      def ready(self):                              │   │
│  │          import blog.signals                       │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 5.6: Creating the ProfileForm

**Form for Editing User Profiles**

```
┌─────────────────────────────────────────────────────────────┐
│              CREATING THE PROFILEFORM                       │
│                                                             │
│  Code:                                                      │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  from .models import Profile                        │   │
│  │                                                    │   │
│  │  class ProfileForm(forms.ModelForm):               │   │
│  │      """Form for editing user profiles."""         │   │
│  │                                                    │   │
│  │      class Meta:                                    │   │
│  │          model = Profile                            │   │
│  │          fields = [                                 │   │
│  │              'bio', 'location', 'website',         │   │
│  │              'twitter', 'github', 'linkedin',      │   │
│  │              'avatar', 'email_notifications',      │   │
│  │              'show_email'                          │   │
│  │          ]                                          │   │
│  │          widgets = {                                │   │
│  │              'bio': forms.Textarea(attrs={          │   │
│  │                  'class': 'form-control', rows: 5  │   │
│  │              }),                                     │   │
│  │              'avatar': forms.FileInput(attrs={      │   │
│  │                  'class': 'form-control'            │   │
│  │              }),                                     │   │
│  │          }                                          │   │
│  │                                                    │   │
│  │      def clean_avatar(self):                       │   │
│  │          avatar = self.cleaned_data.get('avatar')  │   │
│  │          if avatar:                                │   │
│  │              if avatar.size > 2 * 1024 * 1024:    │   │
│  │                  raise ValidationError(            │   │
│  │                      'Avatar must be under 2MB.'   │   │
│  │                  )                                 │   │
│  │          return avatar                             │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 5.7: Creating Profile Views

**Profile Detail and Edit Views**

```
┌─────────────────────────────────────────────────────────────┐
│              CREATING PROFILE VIEWS                         │
│                                                             │
│  Profile Detail View:                                       │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  class ProfileDetailView(DetailView):               │   │
│  │      model = User                                   │   │
│  │      template_name = 'blog/profile_detail.html'    │   │
│  │      context_object_name = 'profile_user'          │   │
│  │      slug_field = 'username'                       │   │
│  │      slug_url_kwarg = 'username'                   │   │
│  │                                                    │   │
│  │      def get_context_data(self, **kwargs):         │   │
│  │          context = super().get_context_data(**kwargs)│  │
│  │          user = self.get_object()                  │   │
│  │                                                    │   │
│  │          posts = Post.objects.filter(              │   │
│  │              author=user,                          │   │
│  │              status=Post.Status.PUBLISHED          │   │
│  │          ).order_by('-published_at')[:10]         │   │
│  │                                                    │   │
│  │          context['posts'] = posts                  │   │
│  │          context['post_count'] = posts.count()     │   │
│  │          return context                            │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Profile Edit View:                                         │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  @login_required                                    │   │
│  │  def profile_edit(request):                         │   │
│  │      profile, created = Profile.objects.get_or_create(│  │
│  │          user=request.user                          │   │
│  │      )                                              │   │
│  │                                                    │   │
│  │      if request.method == 'POST':                  │   │
│  │          form = ProfileForm(request.POST,          │   │
│  │                              request.FILES,         │   │
│  │                              instance=profile)      │   │
│  │          if form.is_valid():                       │   │
│  │              form.save()                            │   │
│  │              messages.success(request,              │   │
│  │                  'Profile updated!')               │   │
│  │              return redirect('blog:profile_detail', │   │
│  │                          username=request.user.username)│   │
│  │      else:                                          │   │
│  │          form = ProfileForm(instance=profile)      │   │
│  │                                                    │   │
│  │      return render(request, 'blog/profile_edit.html',│   │
│  │                      {'form': form})               │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 5.8: Creating the Dashboard View

**User Dashboard with Statistics**

```
┌─────────────────────────────────────────────────────────────┐
│              CREATING THE DASHBOARD VIEW                    │
│                                                             │
│  Code:                                                      │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  @login_required                                    │   │
│  │  def dashboard(request):                            │   │
│  │      """User dashboard with statistics."""         │   │
│  │      user = request.user                            │   │
│  │                                                    │   │
│  │      # User's posts                                │   │
│  │      posts = Post.objects.filter(author=user)      │   │
│  │                                                    │   │
│  │      # Statistics                                  │   │
│  │      total_posts = posts.count()                   │   │
│  │      published_posts = posts.filter(               │   │
│  │          status=Post.Status.PUBLISHED              │   │
│  │      ).count()                                     │   │
│  │      draft_posts = posts.filter(                   │   │
│  │          status=Post.Status.DRAFT                  │   │
│  │      ).count()                                     │   │
│  │      total_comments = Comment.objects.filter(      │   │
│  │          author=user                               │   │
│  │      ).count()                                     │   │
│  │                                                    │   │
│  │      # Recent posts and comments                  │   │
│  │      recent_posts = posts.order_by('-created_at')[:5]│  │
│  │      recent_comments = Comment.objects.filter(     │   │
│  │          author=user                               │   │
│  │      ).order_by('-created_at')[:10]               │   │
│  │                                                    │   │
│  │      context = {                                   │   │
│  │          'total_posts': total_posts,               │   │
│  │          'published_posts': published_posts,       │   │
│  │          'draft_posts': draft_posts,               │   │
│  │          'total_comments': total_comments,         │   │
│  │          'recent_posts': recent_posts,             │   │
│  │          'comments': recent_comments,              │   │
│  │      }                                              │   │
│  │      return render(request, 'blog/dashboard.html',  │   │
│  │                      context)                      │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 5.9: Dashboard Template — Statistics Cards

**Displaying User Statistics**

```
┌─────────────────────────────────────────────────────────────┐
│              DASHBOARD — STATISTICS CARDS                   │
│                                                             │
│  Template:                                                  │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  <!-- Statistics Cards -->                          │   │
│  │  <div style="display: grid; grid-template-columns: │   │
│  │       repeat(auto-fit, minmax(200px, 1fr));        │   │
│  │       gap: 1.5rem; margin-bottom: 2rem;">         │   │
│  │                                                    │   │
│  │      <div style="background: white; padding: 1.5rem;│   │
│  │           border-radius: 8px; box-shadow: 0 2px 4px│   │
│  │           rgba(0,0,0,0.1); text-align: center;">   │   │
│  │          <div style="font-size: 2.5rem;            │   │
│  │               font-weight: bold; color: #3498db;"> │   │
│  │              {{ total_posts }}                     │   │
│  │          </div>                                    │   │
│  │          <div style="color: #7f8c8d;">Total Posts</div>│  │
│  │      </div>                                         │   │
│  │                                                    │   │
│  │      <div style="background: white; padding: 1.5rem;│   │
│  │           border-radius: 8px; box-shadow: 0 2px 4px│   │
│  │           rgba(0,0,0,0.1); text-align: center;">   │   │
│  │          <div style="font-size: 2.5rem;            │   │
│  │               font-weight: bold; color: #2ecc71;"> │   │
│  │              {{ published_posts }}                 │   │
│  │          </div>                                    │   │
│  │          <div style="color: #7f8c8d;">Published</div>│  │
│  │      </div>                                         │   │
│  │                                                    │   │
│  │      <div style="background: white; padding: 1.5rem;│   │
│  │           border-radius: 8px; box-shadow: 0 2px 4px│   │
│  │           rgba(0,0,0,0.1); text-align: center;">   │   │
│  │          <div style="font-size: 2.5rem;            │   │
│  │               font-weight: bold; color: #f39c12;"> │   │
│  │              {{ draft_posts }}                     │   │
│  │          </div>                                    │   │
│  │          <div style="color: #7f8c8d;">Drafts</div> │   │
│  │      </div>                                         │   │
│  │                                                    │   │
│  │      <div style="background: white; padding: 1.5rem;│   │
│  │           border-radius: 8px; box-shadow: 0 2px 4px│   │
│  │           rgba(0,0,0,0.1); text-align: center;">   │   │
│  │          <div style="font-size: 2.5rem;            │   │
│  │               font-weight: bold; color: #9b59b6;"> │   │
│  │              {{ total_comments }}                  │   │
│  │          </div>                                    │   │
│  │          <div style="color: #7f8c8d;">Comments</div>│   │
│  │      </div>                                         │   │
│  │  </div>                                              │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 5.10: Dashboard Template — Recent Activity

**Recent Posts and Comments**

```
┌─────────────────────────────────────────────────────────────┐
│              DASHBOARD — RECENT ACTIVITY                    │
│                                                             │
│  Recent Posts and Comments:                                 │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  <div style="display: grid; grid-template-columns: │   │
│  │       2fr 1fr; gap: 2rem;">                       │   │
│  │                                                    │   │
│  │      <!-- Recent Posts -->                         │   │
│  │      <div class="content">                         │   │
│  │          <div style="display: flex;               │   │
│  │               justify-content: space-between;      │   │
│  │               align-items: center;">              │   │
│  │              <h2>Recent Posts</h2>                 │   │
│  │              <a href="{% url 'blog:post_create' %}"│   │
│  │                 style="background: #3498db;        │   │
│  │                 color: white; padding: 0.5rem 1rem;│   │
│  │                 border-radius: 4px;                │   │
│  │                 text-decoration: none;">          │   │
│  │                  + New Post                        │   │
│  │              </a>                                  │   │
│  │          </div>                                    │   │
│  │                                                    │   │
│  │          {% if recent_posts %}                     │   │
│  │              {% for post in recent_posts %}        │   │
│  │                  <div style="margin-bottom: 1rem; │   │
│  │                       padding-bottom: 1rem;        │   │
│  │                       border-bottom: 1px solid #eee;">│  │
│  │                      <h3>                         │   │
│  │                          <a href="{{ post.get_absolute_url }}"│  │
│  │                             style="text-decoration: none;">│  │
│  │                              {{ post.title }}      │   │
│  │                          </a>                      │   │
│  │                      </h3>                         │   │
│  │                      <p style="color: #7f8c8d;">  │   │
│  │                          {{ post.created_at|date:"F j, Y" }} │   │
│  │                          <span style="background: │   │
│  │                              {% if post.status == 'published' %}#2ecc71│   │
│  │                              {% elif post.status == 'draft' %}#f39c12│   │
│  │                              {% else %}#95a5a6{% endif %};│   │
│  │                              color: white;         │   │
│  │                              padding: 0.1rem 0.5rem;│   │
│  │                              border-radius: 12px;  │   │
│  │                              font-size: 0.7rem;"> │   │
│  │                              {{ post.get_status_display }}│   │
│  │                          </span>                   │   │
│  │                      </p>                          │   │
│  │                  </div>                            │   │
│  │              {% endfor %}                          │   │
│  │          {% else %}                                 │   │
│  │              <p>No posts yet.</p>                  │   │
│  │              <a href="{% url 'blog:post_create' %}">│   │
│  │                  Create your first post →          │   │
│  │              </a>                                  │   │
│  │          {% endif %}                               │   │
│  │      </div>                                         │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 5.11: Dashboard Template — Recent Comments

**Recent Comments Section**

```
┌─────────────────────────────────────────────────────────────┐
│              DASHBOARD — RECENT COMMENTS                    │
│                                                             │
│  Recent Comments:                                           │
│  ┌─────────────────────────────────────────────────────┐   │
│  │      <!-- Recent Comments -->                       │   │
│  │      <div class="content">                          │   │
│  │          <h2>Recent Comments</h2>                   │   │
│  │                                                    │   │
│  │          {% if comments %}                          │   │
│  │              {% for comment in comments %}          │   │
│  │                  <div style="margin-bottom: 1rem;  │   │
│  │                       padding-bottom: 1rem;         │   │
│  │                       border-bottom: 1px solid #eee;">│  │
│  │                      <p style="color: #7f8c8d;">   │   │
│  │                          On <a href="{{ comment.post.get_absolute_url }}"│  │
│  │                               style="color: #3498db;">│  │
│  │                              {{ comment.post.title }}│  │
│  │                          </a>                       │   │
│  │                      </p>                           │   │
│  │                      <p>{{ comment.content|truncatewords:15 }}</p>│  │
│  │                      <p style="color: #7f8c8d;     │   │
│  │                           font-size: 0.8rem;">     │   │
│  │                          {{ comment.created_at|timesince }} ago│  │
│  │                          {% if not comment.is_approved %}│  │
│  │                              <span style="background: #f39c12;│  │
│  │                                   color: white;    │   │
│  │                                   padding: 0.1rem 0.5rem;│  │
│  │                                   border-radius: 12px;│  │
│  │                                   font-size: 0.7rem;">│  │
│  │                                  Pending            │   │
│  │                              </span>                │   │
│  │                          {% endif %}                │   │
│  │                      </p>                           │   │
│  │                  </div>                             │   │
│  │              {% endfor %}                           │   │
│  │          {% else %}                                 │   │
│  │              <p>No comments yet.</p>                │   │
│  │          {% endif %}                                │   │
│  │      </div>                                         │   │
│  │  </div>                                              │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 5.12: Implementing Password Reset — Overview

**Django's Built-in Password Reset Flow**

```
┌─────────────────────────────────────────────────────────────┐
│              PASSWORD RESET FLOW                            │
│                                                             │
│  Complete Workflow:                                         │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                                                     │   │
│  │  1. User clicks "Forgot Password?"                 │   │
│  │     ┌─────────────────────────────────────────────┐ │   │
│  │     │  GET /password-reset/                       │ │   │
│  │     └─────────────────────────────────────────────┘ │   │
│  │                     ▼                               │   │
│  │  2. User enters email address                      │   │
│  │     ┌─────────────────────────────────────────────┐ │   │
│  │     │  POST /password-reset/                      │ │   │
│  │     │  email: user@example.com                   │ │   │
│  │     └─────────────────────────────────────────────┘ │   │
│  │                     ▼                               │   │
│  │  3. Django sends reset email                      │   │
│  │     ┌─────────────────────────────────────────────┐ │   │
│  │     │  To: user@example.com                      │ │   │
│  │     │  Subject: Password Reset                   │ │   │
│  │     │  Link: /password-reset/abc123/def456/     │ │   │
│  │     └─────────────────────────────────────────────┘ │   │
│  │                     ▼                               │   │
│  │  4. User clicks link in email                     │   │
│  │     ┌─────────────────────────────────────────────┐ │   │
│  │     │  GET /password-reset/abc123/def456/        │ │   │
│  │     └─────────────────────────────────────────────┘ │   │
│  │                     ▼                               │   │
│  │  5. User sets new password                        │   │
│  │     ┌─────────────────────────────────────────────┐ │   │
│  │     │  POST /password-reset/abc123/def456/       │ │   │
│  │     │  new_password1: ******                     │ │   │
│  │     │  new_password2: ******                     │ │   │
│  │     └─────────────────────────────────────────────┘ │   │
│  │                     ▼                               │   │
│  │  6. Password reset complete                       │   │
│  │     ┌─────────────────────────────────────────────┐ │   │
│  │     │  Redirect to /password-reset/complete/     │ │   │
│  │     │  User can now login with new password      │ │   │
│  │     └─────────────────────────────────────────────┘ │   │
│  │                                                     │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 5.13: Email Configuration

**Setting Up Email Backends**

```
┌─────────────────────────────────────────────────────────────┐
│              EMAIL CONFIGURATION                            │
│                                                             │
│  Development — Console Backend:                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  # config/settings.py                              │   │
│  │  if DEBUG:                                          │   │
│  │      EMAIL_BACKEND = 'django.core.mail.backends.   │   │
│  │                      console.EmailBackend'          │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Production — SMTP Backend (Gmail Example):               │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  else:                                              │   │
│  │      EMAIL_BACKEND = 'django.core.mail.backends.   │   │
│  │                      smtp.EmailBackend'             │   │
│  │      EMAIL_HOST = 'smtp.gmail.com'                 │   │
│  │      EMAIL_PORT = 587                               │   │
│  │      EMAIL_USE_TLS = True                           │   │
│  │      EMAIL_HOST_USER = 'your-email@gmail.com'      │   │
│  │      EMAIL_HOST_PASSWORD = 'your-app-password'      │   │
│  │      DEFAULT_FROM_EMAIL = 'noreply@yourdomain.com' │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Security Settings:                                         │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  PASSWORD_RESET_TIMEOUT = 86400  # 24 hours        │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 5.14: Password Reset Templates — Form

**Password Reset Form Template**

```
┌─────────────────────────────────────────────────────────────┐
│              PASSWORD RESET FORM TEMPLATE                   │
│                                                             │
│  `registration/password_reset_form.html`:                  │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  {% extends 'blog/base.html' %}                     │   │
│  │                                                    │   │
│  │  {% block title %}Reset Password — Django Blog{% endblock %}│  │
│  │                                                    │   │
│  │  {% block content %}                               │   │
│  │  <div class="page-header">                         │   │
│  │      <h1>Reset Password</h1>                       │   │
│  │      <p class="subtitle">We'll send you a link</p>│   │
│  │  </div>                                            │   │
│  │                                                    │   │
│  │  <div class="content" style="max-width: 500px;">   │   │
│  │      <form method="post">                          │   │
│  │          {% csrf_token %}                          │   │
│  │                                                    │   │
│  │          {% if form.errors %}                      │   │
│  │              <div style="background: #f8d7da;      │   │
│  │                   color: #721c24; padding: 1rem;   │   │
│  │                   border-radius: 4px;              │   │
│  │                   margin-bottom: 1rem;">           │   │
│  │                  <strong>Please correct:</strong>  │   │
│  │                  <ul>                              │   │
│  │                      {% for error in form.non_field_errors %}│  │
│  │                          <li>{{ error }}</li>     │   │
│  │                      {% endfor %}                  │   │
│  │                  </ul>                             │   │
│  │              </div>                                │   │
│  │          {% endif %}                               │   │
│  │                                                    │   │
│  │          <div style="margin-bottom: 1.5rem;">      │   │
│  │              <label for="id_email">Email Address</label>│  │
│  │              <input type="email" name="email"      │   │
│  │                     id="id_email" required>       │   │
│  │              <small>Enter the email you used to   │   │
│  │                     register.</small>              │   │
│  │          </div>                                    │   │
│  │                                                    │   │
│  │          <button type="submit">Send Reset Link</button>│  │
│  │      </form>                                       │   │
│  │                                                    │   │
│  │      <p style="margin-top: 1.5rem;">              │   │
│  │          <a href="{% url 'login' %}">Back to Login</a>│  │
│  │      </p>                                          │   │
│  │  </div>                                            │   │
│  │  {% endblock %}                                    │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 5.15: Password Reset Templates — Email

**Password Reset Email Template**

```
┌─────────────────────────────────────────────────────────────┐
│              PASSWORD RESET EMAIL TEMPLATE                  │
│                                                             │
│  `registration/password_reset_email.html`:                 │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  {% load i18n %}{% autoescape off %}               │   │
│  │                                                    │   │
│  │  Hello,                                            │   │
│  │                                                    │   │
│  │  You're receiving this email because you requested │   │
│  │  a password reset for your account at {{ site_name }}.│  │
│  │                                                    │   │
│  │  Please go to the following page and choose a new  │   │
│  │  password:                                         │   │
│  │                                                    │   │
│  │  {{ protocol }}://{{ domain }}                     │   │
│  │  {% url 'password_reset_confirm' uidb64=uid        │   │
│  │     token=token %}                                 │   │
│  │                                                    │   │
│  │  Your username, in case you've forgotten:          │   │
│  │  {{ user.get_username }}                           │   │
│  │                                                    │   │
│  │  Thanks for using our site!                        │   │
│  │                                                    │   │
│  │  The {{ site_name }} team                          │   │
│  │                                                    │   │
│  │  {% endautoescape %}                               │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  `registration/password_reset_subject.txt`:                │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Password Reset for {{ site_name }}                │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 5.16: Password Reset — Confirm and Complete

**Templates for Setting New Password**

```
┌─────────────────────────────────────────────────────────────┐
│              PASSWORD RESET CONFIRM TEMPLATE                │
│                                                             │
│  `registration/password_reset_confirm.html`:               │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  {% extends 'blog/base.html' %}                     │   │
│  │                                                    │   │
│  │  {% block title %}Set New Password{% endblock %}    │   │
│  │                                                    │   │
│  │  {% block content %}                               │   │
│  │  <div class="page-header"><h1>Set New Password</h1></div>│  │
│  │                                                    │   │
│  │  {% if validlink %}                                │   │
│  │      <div class="content" style="max-width: 500px;">│   │
│  │          <form method="post">                      │   │
│  │              {% csrf_token %}                      │   │
│  │                                                    │   │
│  │              {% if form.errors %}                  │   │
│  │                  <div style="color: #e74c3c;">     │   │
│  │                      Please correct the errors.    │   │
│  │                  </div>                            │   │
│  │              {% endif %}                            │   │
│  │                                                    │   │
│  │              <div style="margin-bottom: 1rem;">    │   │
│  │                  <label for="id_new_password1">    │   │
│  │                      New Password                  │   │
│  │                  </label>                          │   │
│  │                  <input type="password"            │   │
│  │                         name="new_password1"       │   │
│  │                         id="id_new_password1"      │   │
│  │                         required>                  │   │
│  │              </div>                                │   │
│  │                                                    │   │
│  │              <div style="margin-bottom: 1rem;">    │   │
│  │                  <label for="id_new_password2">    │   │
│  │                      Confirm Password              │   │
│  │                  </label>                          │   │
│  │                  <input type="password"            │   │
│  │                         name="new_password2"       │   │
│  │                         id="id_new_password2"      │   │
│  │                         required>                  │   │
│  │              </div>                                │   │
│  │                                                    │   │
│  │              <button type="submit">Set Password</button>│  │
│  │          </form>                                   │   │
│  │      </div>                                         │   │
│  │  {% else %}                                         │   │
│  │      <div class="content">                         │   │
│  │          <p style="color: #e74c3c;">               │   │
│  │              The password reset link is invalid    │   │
│  │              or has already been used.             │   │
│  │          </p>                                      │   │
│  │          <a href="{% url 'password_reset' %}">     │   │
│  │              Request new reset link                │   │
│  │          </a>                                      │   │
│  │      </div>                                         │   │
│  │  {% endif %}                                        │   │
│  │  {% endblock %}                                    │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 5.17: Password Reset — Done and Complete

**Success and Completion Templates**

```
┌─────────────────────────────────────────────────────────────┐
│              PASSWORD RESET — DONE AND COMPLETE             │
│                                                             │
│  `registration/password_reset_done.html`:                  │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  {% extends 'blog/base.html' %}                     │   │
│  │                                                    │   │
│  │  {% block title %}Check Your Email{% endblock %}    │   │
│  │                                                    │   │
│  │  {% block content %}                               │   │
│  │  <div class="page-header"><h1>Check Your Email</h1></div>│  │
│  │                                                    │   │
│  │  <div class="content" style="max-width: 500px;     │   │
│  │       text-align: center;">                        │   │
│  │      <div style="font-size: 4rem;">📧</div>        │   │
│  │      <h2>Password Reset Link Sent</h2>             │   │
│  │      <p>We've emailed you instructions for setting │   │
│  │         your password. You should receive it shortly.</p>│  │
│  │      <p style="color: #7f8c8d; font-size: 0.9rem;">│   │
│  │          If you don't receive an email, please make│   │
│  │          sure you've entered the address you       │   │
│  │          registered with, and check your spam     │   │
│  │          folder.                                   │   │
│  │      </p>                                          │   │
│  │      <a href="{% url 'login' %}" style="           │   │
│  │          display: inline-block; margin-top: 2rem;">│   │
│  │          Return to Login                           │   │
│  │      </a>                                          │   │
│  │  </div>                                            │   │
│  │  {% endblock %}                                    │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  `registration/password_reset_complete.html`:              │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  <div style="font-size: 4rem;">✅</div>             │   │
│  │  <h2>Password Reset Complete</h2>                  │   │
│  │  <p>Your password has been set. You may now log in.│   │
│  │  <a href="{% url 'login' %}">Log In Now</a>        │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 5.18: Adding Account Management URLs

**Complete Authentication URL Configuration**

```
┌─────────────────────────────────────────────────────────────┐
│              ACCOUNT MANAGEMENT URLS                        │
│                                                             │
│  Password Management URLs:                                  │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  urlpatterns = [                                    │   │
│  │      # Password change                             │   │
│  │      path('password-change/',                       │   │
│  │           auth_views.PasswordChangeView.as_view(    │   │
│  │               template_name='registration/          │   │
│  │               password_change_form.html',           │   │
│  │               success_url='/password-change/done/' │   │
│  │           ),                                        │   │
│  │           name='password_change'),                  │   │
│  │                                                    │   │
│  │      path('password-change/done/',                  │   │
│  │           auth_views.PasswordChangeDoneView.as_view(│   │
│  │               template_name='registration/          │   │
│  │               password_change_done.html'            │   │
│  │           ),                                        │   │
│  │           name='password_change_done'),            │   │
│  │                                                    │   │
│  │      # Password reset                              │   │
│  │      path('password-reset/',                       │   │
│  │           auth_views.PasswordResetView.as_view(    │   │
│  │               template_name='registration/         │   │
│  │               password_reset_form.html',            │   │
│  │               email_template_name='registration/   │   │
│  │               password_reset_email.html',           │   │
│  │               subject_template_name='registration/  │   │
│  │               password_reset_subject.txt'          │   │
│  │           ),                                        │   │
│  │           name='password_reset'),                  │   │
│  │                                                    │   │
│  │      path('password-reset/done/',                  │   │
│  │           auth_views.PasswordResetDoneView.as_view(│   │
│  │               template_name='registration/         │   │
│  │               password_reset_done.html'             │   │
│  │           ),                                        │   │
│  │           name='password_reset_done'),            │   │
│  │                                                    │   │
│  │      path('password-reset/<uidb64>/<token>/',      │   │
│  │           auth_views.PasswordResetConfirmView.as_view(│  │
│  │               template_name='registration/         │   │
│  │               password_reset_confirm.html'         │   │
│  │           ),                                        │   │
│  │           name='password_reset_confirm'),          │   │
│  │                                                    │   │
│  │      path('password-reset/complete/',              │   │
│  │           auth_views.PasswordResetCompleteView.as_view(│  │
│  │               template_name='registration/         │   │
│  │               password_reset_complete.html'        │   │
│  │           ),                                        │   │
│  │           name='password_reset_complete'),         │   │
│  │  ]                                                 │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 5.19: Updating Navigation — User Dropdown

**User Dropdown Menu**

```
┌─────────────────────────────────────────────────────────────┐
│              USER DROPDOWN NAVIGATION                       │
│                                                             │
│  Navigation HTML:                                           │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  {% if user.is_authenticated %}                     │   │
│  │      <li><a href="{% url 'blog:post_create' %}">    │   │
│  │          New Post                                  │   │
│  │      </a></li>                                      │   │
│  │      <li><a href="{% url 'blog:dashboard' %}">      │   │
│  │          Dashboard                                  │   │
│  │      </a></li>                                      │   │
│  │                                                    │   │
│  │      <!-- User Dropdown -->                        │   │
│  │      <li style="position: relative;">              │   │
│  │          <div style="display: flex;                │   │
│  │               align-items: center; gap: 0.5rem;    │   │
│  │               cursor: pointer;">                   │   │
│  │              <img src="{{ user.profile.get_avatar_url }}" │  │
│  │                   alt="{{ user.username }}"        │   │
│  │                   style="width: 30px; height: 30px;│   │
│  │                   border-radius: 50%;              │   │
│  │                   object-fit: cover;">             │   │
│  │              <span>{{ user.username }}</span>      │   │
│  │              <span style="font-size: 0.7rem;">▼</span>│  │
│  │          </div>                                    │   │
│  │                                                    │   │
│  │          <ul style="display: none;                 │   │
│  │               position: absolute;                  │   │
│  │               top: 100%; right: 0;                │   │
│  │               background: white;                   │   │
│  │               box-shadow: 0 2px 8px rgba(0,0,0,0.15);│  │
│  │               border-radius: 4px;                  │   │
│  │               min-width: 180px;                    │   │
│  │               padding: 0.5rem 0;">                │   │
│  │              <li><a href="{% url 'blog:profile_detail' user.username %}"│  │
│  │                   style="display: block; padding: 0.5rem 1rem;│  │
│  │                   color: #2c3e50; text-decoration: none;">│  │
│  │                  My Profile                        │   │
│  │              </a></li>                             │   │
│  │              <li><a href="{% url 'blog:profile_edit' %}"│   │
│  │                   style="display: block; padding: 0.5rem 1rem;│  │
│  │                   color: #2c3e50; text-decoration: none;">│  │
│  │                  Edit Profile                      │   │
│  │              </a></li>                             │   │
│  │              <li><a href="{% url 'password_change' %}"│   │
│  │                   style="display: block; padding: 0.5rem 1rem;│  │
│  │                   color: #2c3e50; text-decoration: none;">│  │
│  │                  Change Password                   │   │
│  │              </a></li>                             │   │
│  │              <li style="border-top: 1px solid #eee;│   │
│  │                   margin: 0.25rem 0;"></li>        │   │
│  │              <li>                                  │   │
│  │                  <form method="post"               │   │
│  │                        action="{% url 'logout' %}"│   │
│  │                        style="display: block;      │   │
│  │                        padding: 0; margin: 0;">   │   │
│  │                      {% csrf_token %}              │   │
│  │                      <button type="submit"         │   │
│  │                              style="display: block;│   │
│  │                              width: 100%;          │   │
│  │                              text-align: left;     │   │
│  │                              padding: 0.5rem 1rem; │   │
│  │                              background: none;     │   │
│  │                              border: none;         │   │
│  │                              color: #e74c3c;        │   │
│  │                              cursor: pointer;      │   │
│  │                              font-size: 0.9rem;"> │   │
│  │                          Logout                    │   │
│  │                      </button>                     │   │
│  │                  </form>                           │   │
│  │              </li>                                 │   │
│  │          </ul>                                     │   │
│  │      </li>                                         │   │
│  │  {% else %}                                        │   │
│  │      <li><a href="{% url 'login' %}">Login</a></li>│   │
│  │      <li><a href="{% url 'register' %}">Register</a></li>│  │
│  │  {% endif %}                                       │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 5.20: Verification — Testing the Complete Account System

**Comprehensive Verification Checklist**

```
┌─────────────────────────────────────────────────────────────┐
│              VERIFICATION CHECKLIST                         │
│                                                             │
│  Step 1: Register a New User                               │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  1. Visit http://127.0.0.1:8000/register/           │   │
│  │  2. Create a new account                            │   │
│  │  3. Verify automatic login                          │   │
│  │  4. Check that Profile was created (signals)       │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Step 2: View and Edit Profile                            │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  1. Click username → "My Profile"                   │   │
│  │  2. Verify public profile page                      │   │
│  │  3. Click "Edit Profile"                           │   │
│  │  4. Update bio, location, upload avatar            │   │
│  │  5. Verify changes appear                           │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Step 3: Test Dashboard                                   │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  1. Click "Dashboard"                              │   │
│  │  2. Verify statistics show correctly               │   │
│  │  3. Click "New Post" from dashboard                │   │
│  │  4. Create posts in different statuses             │   │
│  │  5. Verify dashboard updates                       │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Step 4: Test Password Reset                              │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  1. Logout                                          │   │
│  │  2. Click "Login" → "Forgot your password?"        │   │
│  │  3. Enter email address                             │   │
│  │  4. Check console for reset email (development)    │   │
│  │  5. Click link and set new password                │   │
│  │  6. Login with new password                        │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Step 5: Test Change Password                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  1. Login                                           │   │
│  │  2. Click username → "Change Password"             │   │
│  │  3. Enter current and new password                  │   │
│  │  4. Verify success message                          │   │
│  │  5. Login with new password                        │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 5.21: What You've Learned in Part 5

**Skills Acquired and What You've Built**

```
┌─────────────────────────────────────────────────────────────┐
│              WHAT YOU'VE LEARNED — PART 5                  │
│                                                             │
│  ✅ Skills Acquired:                                        │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  • Creating one-to-one profiles with User model     │   │
│  │  • Using Django signals for auto-creation          │   │
│  │  • Building profile views and forms                │   │
│  │  • Creating user dashboards                        │   │
│  │  • Implementing password reset workflow             │   │
│  │  • Configuring email backends                       │   │
│  │  • Understanding permissions and groups            │   │
│  │  • Implementing account management features        │   │
│  │  • Using Django's built-in authentication views    │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ✅ What You've Built:                                      │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  • Complete user profile system                     │   │
│  │  • Public profile pages                            │   │
│  │  • User dashboard with statistics                  │   │
│  │  • Password reset functionality                    │   │
│  │  • Password change functionality                   │   │
│  │  • User account management                         │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  🎯 Ready for Part 6:                                       │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  In Part 6, we'll dive into advanced architecture:  │   │
│  │  middleware, signals, context processors, and       │   │
│  │  service layers!                                    │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 5.22: Quick Reference — Account Management URLs

**Complete List of Account URLs**

```
┌─────────────────────────────────────────────────────────────┐
│              ACCOUNT MANAGEMENT URLS — REFERENCE            │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  URL Pattern                     │  Purpose         │   │
│  │  ──────────────────────────────────────────────────  │   │
│  │  /login/                         │  Login page      │   │
│  │  /logout/                        │  Logout (POST)   │   │
│  │  /register/                      │  Registration    │   │
│  │  /profile/<username>/            │  User profile    │   │
│  │  /profile/edit/                  │  Edit profile    │   │
│  │  /dashboard/                     │  User dashboard  │   │
│  │  /password-change/               │  Change password │   │
│  │  /password-change/done/          │  Change confirm  │   │
│  │  /password-reset/                │  Request reset   │   │
│  │  /password-reset/done/           │  Link sent       │   │
│  │  /password-reset/<uidb64>/<token>/│ Set new password│   │
│  │  /password-reset/complete/       │  Reset complete  │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Built-in Views Used:                                       │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  View                          │  Purpose           │   │
│  │  ──────────────────────────────────────────────────  │   │
│  │  LoginView                    │  Login page        │   │
│  │  LogoutView                   │  Logout            │   │
│  │  PasswordChangeView           │  Change password   │   │
│  │  PasswordChangeDoneView       │  Change confirm    │   │
│  │  PasswordResetView            │  Request reset     │   │
│  │  PasswordResetDoneView        │  Link sent         │   │
│  │  PasswordResetConfirmView     │  Set new password  │   │
│  │  PasswordResetCompleteView    │  Reset complete    │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 5.23: Proceed to Part 6

**Preview of What's Coming**

```
┌─────────────────────────────────────────────────────────────┐
│                COMING UP IN PART 6                          │
│                                                             │
│  🏛️ Advanced Django Architecture and Application Design    │
│                                                             │
│  What We'll Build:                                          │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  • Custom middleware for cross-cutting concerns     │   │
│  │  • Context processors for global variables          │   │
│  │  • Signals for decoupled functionality              │   │
│  │  • Service layer for business logic                 │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  What We'll Learn:                                          │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  • Django request lifecycle                         │   │
│  │  • Custom middleware creation                       │   │
│  │  • Context processor implementation                 │   │
│  │  • Django signals                                  │   │
│  │  • Service layer pattern                            │   │
│  │  • Large application organization                  │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Preview of Architecture:                                   │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  ┌─────────────────────────────────────────────────┐│   │
│  │  │  Middleware │ Context │ Signals │ Service Layer ││   │
│  │  │  ┌─────────┐│ ┌──────┐│ ┌──────┐│ ┌──────────┐││   │
│  │  │  │Logging  ││ │Global││ │User  ││ │Post      │││   │
│  │  │  │Security ││ │Vars  ││ │Email ││ │Service   │││   │
│  │  │  └─────────┘│ └──────┘│ └──────┘│ └──────────┘││   │
│  │  └─────────────────────────────────────────────────┘│   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Let's build a maintainable architecture! 🏛️              │
└─────────────────────────────────────────────────────────────┘
```

---

# PART 6: ADVANCED DJANGO ARCHITECTURE AND APPLICATION DESIGN

---

## Slide 6.1: Part 6 Introduction

**Learning Objectives**

```
┌─────────────────────────────────────────────────────────────┐
│                    PART 6 OVERVIEW                          │
│                                                             │
│  🎯 Learning Objectives:                                    │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  ✅ Understand Django's request lifecycle           │   │
│  │  ✅ Create custom middleware                       │   │
│  │  ✅ Implement context processors                   │   │
│  │  ✅ Work with Django signals                       │   │
│  │  ✅ Build a service layer                         │   │
│  │  ✅ Organize large Django applications             │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  🏗️ What We'll Build:                                      │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  • Request logging middleware                       │   │
│  │  • Security headers middleware                     │   │
│  │  • Global context processors                       │   │
│  │  • Signal handlers for user and post events        │   │
│  │  • Service layer for business logic               │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  📚 Key Concepts:                                          │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  • Middleware stack order                          │   │
│  │  • Context processor registration                  │   │
│  │  • Signal registration in apps.py                 │   │
│  │  • Service layer pattern                          │   │
│  │  • Separation of concerns                          │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 6.2: Understanding Django's Request Lifecycle

**The Complete Request Flow**

```
┌─────────────────────────────────────────────────────────────┐
│              DJANGO REQUEST LIFECYCLE                       │
│                                                             │
│  1. Browser makes HTTP request                              │
│     ┌─────────────────────────────────────────────────────┐│
│     │  GET /blog/ HTTP/1.1                               ││
│     │  Host: localhost:8000                              ││
│     └─────────────────────────────────────────────────────┘│
│                           ▼                                 │
│  2. Django creates an HttpRequest object                   │
│     ┌─────────────────────────────────────────────────────┐│
│     │  request.method = 'GET'                            ││
│     │  request.path = '/blog/'                          ││
│     │  request.user = AnonymousUser()                   ││
│     └─────────────────────────────────────────────────────┘│
│                           ▼                                 │
│  3. Request passes through all MIDDLEWARE (in order)       │
│     ┌─────────────────────────────────────────────────────┐│
│     │  SecurityMiddleware → SessionMiddleware →          ││
│     │  AuthenticationMiddleware → CSRFMiddleware → ...  ││
│     └─────────────────────────────────────────────────────┘│
│                           ▼                                 │
│  4. URL dispatcher finds matching view                     │
│     ┌─────────────────────────────────────────────────────┐│
│     │  path('blog/', views.blog_list, name='blog_list')  ││
│     └─────────────────────────────────────────────────────┘│
│                           ▼                                 │
│  5. View executes business logic                           │
│     ┌─────────────────────────────────────────────────────┐│
│     │  posts = Post.objects.filter(status='published')   ││
│     └─────────────────────────────────────────────────────┘│
│                           ▼                                 │
│  6. View returns an HttpResponse object                   │
│     ┌─────────────────────────────────────────────────────┐│
│     │  return render(request, 'blog/list.html', context) ││
│     └─────────────────────────────────────────────────────┘│
│                           ▼                                 │
│  7. Response passes through all MIDDLEWARE (reverse order) │
│     ┌─────────────────────────────────────────────────────┐│
│     │  ... → CSRFMiddleware → AuthenticationMiddleware → ││
│     │  SessionMiddleware → SecurityMiddleware             ││
│     └─────────────────────────────────────────────────────┘│
│                           ▼                                 │
│  8. Django returns the response to the browser            │
│     ┌─────────────────────────────────────────────────────┐│
│     │  HTTP/1.1 200 OK                                   ││
│     │  Content-Type: text/html                           ││
│     │  <!DOCTYPE html><html>...                         ││
│     └─────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 6.3: Middleware — Overview and Creation

**Custom Middleware for Cross-Cutting Concerns**

```
┌─────────────────────────────────────────────────────────────┐
│                    MIDDLEWARE OVERVIEW                      │
│                                                             │
│  What is Middleware?                                        │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Code that runs on every request/response           │   │
│  │  Perfect for cross-cutting concerns                │   │
│  │  Examples: logging, security, authentication      │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Middleware Structure:                                      │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  class MyMiddleware:                                │   │
│  │      def __init__(self, get_response):              │   │
│  │          self.get_response = get_response          │   │
│  │                                                    │   │
│  │      def __call__(self, request):                  │   │
│  │          # Request phase                            │   │
│  │          # ... do something before view             │   │
│  │                                                    │   │
│  │          response = self.get_response(request)      │   │
│  │                                                    │   │
│  │          # Response phase                           │   │
│  │          # ... do something after view              │   │
│  │                                                    │   │
│  │          return response                            │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Common Use Cases:                                          │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  ✅ Request logging                                 │   │
│  │  ✅ Security headers                                │   │
│  │  ✅ Performance monitoring                          │   │
│  │  ✅ Rate limiting                                   │   │
│  │  ✅ Maintenance mode                               │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 6.4: Middleware — Request Logging

**Logging All Requests with Timing**

```
┌─────────────────────────────────────────────────────────────┐
│              REQUEST LOGGING MIDDLEWARE                     │
│                                                             │
│  Code:                                                      │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  import logging                                     │   │
│  │  import time                                        │   │
│  │                                                    │   │
│  │  logger = logging.getLogger(__name__)              │   │
│  │                                                    │   │
│  │  class RequestLoggingMiddleware:                   │   │
│  │      """Log all requests with timing."""          │   │
│  │                                                    │   │
│  │      def __init__(self, get_response):             │   │
│  │          self.get_response = get_response         │   │
│  │                                                    │   │
│  │      def __call__(self, request):                  │   │
│  │          # Request phase                           │   │
│  │          start_time = time.time()                  │   │
│  │                                                    │   │
│  │          # Process the request                     │   │
│  │          response = self.get_response(request)     │   │
│  │                                                    │   │
│  │          # Response phase                          │   │
│  │          duration = time.time() - start_time       │   │
│  │                                                    │   │
│  │          # Log the request                         │   │
│  │          logger.info(                              │   │
│  │              f"Request: {request.method} {request.path} "│   │
│  │              f"User: {request.user.username if request.user.is_authenticated else 'Anonymous'} "│   │
│  │              f"Duration: {duration:.3f}s "        │   │
│  │              f"Status: {response.status_code}"    │   │
│  │          )                                         │   │
│  │                                                    │   │
│  │          return response                           │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Sample Log Output:                                         │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  INFO: Request: GET /blog/ User: admin            │   │
│  │       Duration: 0.045s Status: 200                 │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 6.5: Middleware — Security Headers

**Adding Security Headers to Every Response**

```
┌─────────────────────────────────────────────────────────────┐
│              SECURITY HEADERS MIDDLEWARE                    │
│                                                             │
│  Code:                                                      │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  class SecurityHeadersMiddleware:                   │   │
│  │      """Add security headers to all responses."""   │   │
│  │                                                    │   │
│  │      def __init__(self, get_response):             │   │
│  │          self.get_response = get_response         │   │
│  │                                                    │   │
│  │      def __call__(self, request):                  │   │
│  │          response = self.get_response(request)     │   │
│  │                                                    │   │
│  │          # Basic security headers                  │   │
│  │          response['X-Content-Type-Options'] = 'nosniff'│  │
│  │          response['X-Frame-Options'] = 'DENY'     │   │
│  │          response['X-XSS-Protection'] = '1; mode=block'│  │
│  │                                                    │   │
│  │          # Content Security Policy                 │   │
│  │          response['Content-Security-Policy'] = (   │   │
│  │              "default-src 'self'; "                │   │
│  │              "img-src 'self' data: https:; "      │   │
│  │              "style-src 'self' 'unsafe-inline'; " │   │
│  │              "script-src 'self' 'unsafe-inline';" │   │
│  │          )                                         │   │
│  │                                                    │   │
│  │          # Referrer Policy                         │   │
│  │          response['Referrer-Policy'] =             │   │
│  │              'strict-origin-when-cross-origin'    │   │
│  │                                                    │   │
│  │          return response                           │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Why These Headers Matter:                                  │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Header                    │  Protects Against      │   │
│  │  ──────────────────────────────────────────────────  │   │
│  │  X-Content-Type-Options   │  MIME sniffing         │   │
│  │  X-Frame-Options          │  Clickjacking          │   │
│  │  X-XSS-Protection         │  XSS attacks           │   │
│  │  Content-Security-Policy  │  XSS, data injection   │   │
│  │  Referrer-Policy          │  Information leakage   │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 6.6: Middleware — Query Count Logger

**Monitoring Database Query Performance**

```
┌─────────────────────────────────────────────────────────────┐
│              QUERY COUNT MIDDLEWARE                         │
│                                                             │
│  Code:                                                      │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  class QueryCountMiddleware:                        │   │
│  │      """Log database query count per request."""    │   │
│  │                                                    │   │
│  │      def __init__(self, get_response):             │   │
│  │          self.get_response = get_response         │   │
│  │                                                    │   │
│  │      def __call__(self, request):                  │   │
│  │          from django.db import connection          │   │
│  │          connection.queries_log.clear()            │   │
│  │                                                    │   │
│  │          response = self.get_response(request)     │   │
│  │                                                    │   │
│  │          query_count = len(connection.queries)     │   │
│  │                                                    │   │
│  │          if query_count > 10:  # Warn if > 10     │   │
│  │              logger.warning(                       │   │
│  │                  f"Path: {request.path} - "        │   │
│  │                  f"Query count: {query_count} - " │   │
│  │                  f"User: {request.user}"          │   │
│  │              )                                      │   │
│  │                                                    │   │
│  │          return response                           │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Why Query Count Matters:                                   │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  ✅ Identifies N+1 query problems                   │   │
│  │  ✅ Highlights performance bottlenecks              │   │
│  │  ✅ Helps optimize database usage                   │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Adding to MIDDLEWARE:                                      │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  MIDDLEWARE = [                                     │   │
│  │      # ... default middleware ...                  │   │
│  │      'blog.middleware.RequestLoggingMiddleware',    │   │
│  │      'blog.middleware.SecurityHeadersMiddleware',   │   │
│  │      'blog.middleware.QueryCountMiddleware',        │   │
│  │  ]                                                  │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 6.7: Implementing Context Processors

**Global Variables for All Templates**

```
┌─────────────────────────────────────────────────────────────┐
│              CONTEXT PROCESSORS                             │
│                                                             │
│  What Are Context Processors?                               │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Functions that add variables to EVERY template     │   │
│  │  Run for every request                             │   │
│  │  Perfect for site-wide data                        │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Code (`blog/context_processors.py`):                      │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  from datetime import datetime                      │   │
│  │  from django.db.models import Count, Q              │   │
│  │  from .models import Category, Post                │   │
│  │                                                    │   │
│  │  def global_context(request):                      │   │
│  │      """Add global variables to all templates."""  │   │
│  │      context = {}                                  │   │
│  │                                                    │   │
│  │      # Site information                            │   │
│  │      context['site_name'] = 'Django Blog'          │   │
│  │      context['current_year'] = datetime.now().year │   │
│  │                                                    │   │
│  │      # Navigation - categories with post counts   │   │
│  │      categories = Category.objects.annotate(       │   │
│  │          post_count=Count('posts', filter=Q(       │   │
│  │              posts__status=Post.Status.PUBLISHED   │   │
│  │          ))                                        │   │
│  │      ).filter(post_count__gt=0)                   │   │
│  │      context['categories_nav'] = categories        │   │
│  │                                                    │   │
│  │      # User information (if authenticated)        │   │
│  │      if request.user.is_authenticated:             │   │
│  │          context['user_is_authenticated'] = True   │   │
│  │          context['user_username'] =                │   │
│  │              request.user.username                 │   │
│  │                                                    │   │
│  │      return context                                │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 6.8: Registering Context Processors

**Adding Custom Processors to Settings**

```
┌─────────────────────────────────────────────────────────────┐
│              REGISTERING CONTEXT PROCESSORS                 │
│                                                             │
│  Settings Configuration:                                    │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  # config/settings.py                              │   │
│  │                                                    │   │
│  │  TEMPLATES = [                                     │   │
│  │      {                                              │   │
│  │          'BACKEND': 'django.template.backends.     │   │
│  │                      django.DjangoTemplates',       │   │
│  │          'DIRS': [BASE_DIR / 'templates'],         │   │
│  │          'APP_DIRS': True,                         │   │
│  │          'OPTIONS': {                              │   │
│  │              'context_processors': [               │   │
│  │                  'django.template.context_processors.│  │
│  │                   debug',                          │   │
│  │                  'django.template.context_processors.│  │
│  │                   request',                        │   │
│  │                  'django.contrib.auth.context_processors.│  │
│  │                   auth',                           │   │
│  │                  'django.contrib.messages.context_processors.│  │
│  │                   messages',                       │   │
│  │                                                    │   │
│  │                  # Custom context processor        │   │
│  │                  'blog.context_processors.         │   │
│  │                   global_context',                 │   │
│  │              ],                                     │   │
│  │          },                                         │   │
│  │      },                                             │   │
│  │  ]                                                  │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Now Available in All Templates:                            │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  {{ site_name }}       → "Django Blog"             │   │
│  │  {{ current_year }}    → 2026                      │   │
│  │  {{ categories_nav }}  → Category list with counts │   │
│  │  {{ user_username }}   → Current user's username   │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 6.9: Working with Django Signals

**Decoupled Communication Between Components**

```
┌─────────────────────────────────────────────────────────────┐
│              UNDERSTANDING SIGNALS                          │
│                                                             │
│  What Are Signals?                                          │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Allow decoupled communication between parts       │   │
│  │  "Notify" when something happens                   │   │
│  │  Sender → Signal → Receiver                        │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Visual Representation:                                     │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                                                    │   │
│  │  ┌─────────────────────────────────────────────┐   │   │
│  │  │             SIGNAL                           │   │   │
│  │  │  ┌─────────┐    ┌─────────┐    ┌─────────┐ │   │   │
│  │  │  │ Sender  │ ──▶│ Event   │ ──▶│Receiver │ │   │   │
│  │  │  │ (Model) │    │ (Signal)│    │(Handler)│ │   │   │
│  │  │  └─────────┘    └─────────┘    └─────────┘ │   │   │
│  │  └─────────────────────────────────────────────┘   │   │
│  │                                                    │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Common Signals:                                            │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Signal          │  Emitted When                   │   │
│  │  ──────────────────────────────────────────────────  │   │
│  │  post_save       │  After model is saved          │   │
│  │  pre_save        │  Before model is saved         │   │
│  │  post_delete     │  After model is deleted        │   │
│  │  m2m_changed     │  When many-to-many changes     │   │
│  │  user_logged_in  │  When user logs in             │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Use Cases:                                                 │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  ✅ Auto-create profiles for new users              │   │
│  │  ✅ Send welcome emails                             │   │
│  │  ✅ Invalidate cache on model changes               │   │
│  │  ✅ Log user activity                               │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 6.10: Creating Signal Handlers

**Auto-Create Profiles and Send Emails**

```
┌─────────────────────────────────────────────────────────────┐
│              CREATING SIGNAL HANDLERS                       │
│                                                             │
│  Code (`blog/signals.py`):                                 │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  from django.db.models.signals import post_save     │   │
│  │  from django.contrib.auth.models import User        │   │
│  │  from django.dispatch import receiver               │   │
│  │  from django.core.mail import send_mail             │   │
│  │  from django.conf import settings                   │   │
│  │  from .models import Profile, Post                 │   │
│  │                                                    │   │
│  │  @receiver(post_save, sender=User)                 │   │
│  │  def create_user_profile(sender, instance, created, │   │
│  │                          **kwargs):                │   │
│  │      """Create a profile for every new user."""    │   │
│  │      if created:                                   │   │
│  │          Profile.objects.get_or_create(user=instance)│  │
│  │                                                    │   │
│  │  @receiver(post_save, sender=User)                 │   │
│  │  def send_welcome_email(sender, instance, created, │   │
│  │                         **kwargs):                 │   │
│  │      """Send welcome email to new users."""        │   │
│  │      if created and instance.email:                │   │
│  │          send_mail(                                │   │
│  │              subject='Welcome to Django Blog!',    │   │
│  │              message=f'Hello {instance.username},   │   │
│  │              Welcome to our community!',           │   │
│  │              from_email=settings.DEFAULT_FROM_EMAIL,│   │
│  │              recipient_list=[instance.email],      │   │
│  │              fail_silently=True,                   │   │
│  │          )                                          │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 6.11: Signal — Post Publication Notification

**Sending Emails When Posts Are Published**

```
┌─────────────────────────────────────────────────────────────┐
│              POST PUBLICATION SIGNAL                        │
│                                                             │
│  Code:                                                      │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  @receiver(post_save, sender=Post)                  │   │
│  │  def handle_post_publication(sender, instance,     │   │
│  │                            created, **kwargs):     │   │
│  │      """Send notification when a post is published."""│  │
│  │                                                    │   │
│  │      if not created:                               │   │
│  │          try:                                      │   │
│  │              old = Post.objects.get(id=instance.id)│   │
│  │                                                    │   │
│  │              if (old.status != Post.Status.PUBLISHED and│  │
│  │                  instance.status == Post.Status.PUBLISHED):│  │
│  │                                                    │   │
│  │                  send_mail(                        │   │
│  │                      subject=f'Your post "{instance.title}" published!',│  │
│  │                      message=f'''                   │   │
│  │                      Hello {instance.author.username},│   │
│  │                                                    │   │
│  │                      Your post "{instance.title}"   │   │
│  │                      is now live!                  │   │
│  │                                                    │   │
│  │                      View it here:                 │   │
│  │                      {settings.SITE_URL}{instance.get_absolute_url()}│  │
│  │                      ''',                          │   │
│  │                      from_email=settings.DEFAULT_FROM_EMAIL,│  │
│  │                      recipient_list=[instance.author.email],│  │
│  │                      fail_silently=True,           │   │
│  │                  )                                 │   │
│  │          except Post.DoesNotExist:                 │   │
│  │              pass                                  │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Register Signals in `apps.py`:                            │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  class BlogConfig(AppConfig):                       │   │
│  │      default_auto_field = 'django.db.models.BigAutoField'│  │
│  │      name = 'blog'                                 │   │
│  │                                                    │   │
│  │      def ready(self):                              │   │
│  │          import blog.signals                       │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 6.12: Building a Service Layer

**Separating Business Logic from Views**

```
┌─────────────────────────────────────────────────────────────┐
│              SERVICE LAYER OVERVIEW                         │
│                                                             │
│  What is a Service Layer?                                   │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Encapsulates business logic                       │   │
│  │  Keeps views thin and focused                      │   │
│  │  Makes code reusable and testable                  │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Architecture:                                              │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                                                    │   │
│  │  ┌───────────────────────────────────────────────┐ │   │
│  │  │              Views                            │ │   │
│  │  │  Handle requests and responses               │ │   │
│  │  │  Call service methods                         │ │   │
│  │  └───────────────────┬───────────────────────────┘ │   │
│  │                      │                              │   │
│  │                      ▼                              │   │
│  │  ┌───────────────────────────────────────────────┐ │   │
│  │  │           Service Layer                      │ │   │
│  │  │  ┌─────────────────────────────────────────┐ │ │   │
│  │  │  │ Business Logic                         │ │ │   │
│  │  │  │ Database Operations                    │ │ │   │
│  │  │  │ External API Calls                     │ │ │   │
│  │  │  │ Transaction Management                 │ │ │   │
│  │  │  └─────────────────────────────────────────┘ │ │   │
│  │  └───────────────────┬───────────────────────────┘ │   │
│  │                      │                              │   │
│  │                      ▼                              │   │
│  │  ┌───────────────────────────────────────────────┐ │   │
│  │  │             Models                           │ │   │
│  │  └───────────────────────────────────────────────┘ │   │
│  │                                                    │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Benefits:                                                  │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  ✅ Views stay thin and focused                    │   │
│  │  ✅ Business logic is reusable                     │   │
│  │  ✅ Easier to test                                │   │
│  │  ✅ Clean separation of concerns                   │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 6.13: Creating the Post Service

**Service Layer Implementation**

```
┌─────────────────────────────────────────────────────────────┐
│              POST SERVICE — CREATE AND UPDATE               │
│                                                             │
│  Code (`blog/services/post_service.py`):                   │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  from django.core.exceptions import ValidationError │   │
│  │  from .models import Post, Tag, Comment            │   │
│  │  from .forms import PostForm                       │   │
│  │                                                    │   │
│  │  class PostService:                                │   │
│  │      """Service layer for post operations."""     │   │
│  │                                                    │   │
│  │      @staticmethod                                 │   │
│  │      def create_post(data, author):               │   │
│  │          """Create a new post."""                 │   │
│  │          form = PostForm(data, data.get('files', {}))│  │
│  │                                                    │   │
│  │          if not form.is_valid():                   │   │
│  │              raise ValidationError(form.errors)    │   │
│  │                                                    │   │
│  │          post = form.save(commit=False)            │   │
│  │          post.author = author                      │   │
│  │                                                    │   │
│  │          if post.status == Post.Status.PUBLISHED:  │   │
│  │              post.published_at = timezone.now()    │   │
│  │                                                    │   │
│  │          post.save()                               │   │
│  │          form.save_m2m()                           │   │
│  │                                                    │   │
│  │          return post                              │   │
│  │                                                    │   │
│  │      @staticmethod                                 │   │
│  │      def update_post(post, data, user):           │   │
│  │          """Update an existing post."""            │   │
│  │          if post.author != user:                   │   │
│  │              raise PermissionError(                │   │
│  │                  "You don't have permission."      │   │
│  │              )                                     │   │
│  │                                                    │   │
│  │          form = PostForm(data, data.get('files', {}),│  │
│  │                         instance=post)             │   │
│  │                                                    │   │
│  │          if not form.is_valid():                   │   │
│  │              raise ValidationError(form.errors)    │   │
│  │                                                    │   │
│  │          updated = form.save(commit=False)         │   │
│  │                                                    │   │
│  │          if (updated.status == Post.Status.PUBLISHED and│  │
│  │              post.status != Post.Status.PUBLISHED):│   │
│  │              updated.published_at = timezone.now()│   │
│  │                                                    │   │
│  │          updated.save()                            │   │
│  │          form.save_m2m()                           │   │
│  │                                                    │   │
│  │          return updated                            │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 6.14: Post Service — Query Methods

**Service Methods for Data Retrieval**

```
┌─────────────────────────────────────────────────────────────┐
│              POST SERVICE — QUERY METHODS                   │
│                                                             │
│  Code:                                                      │
│  ┌─────────────────────────────────────────────────────┐   │
│  │      @staticmethod                                 │   │
│  │      def get_published_posts():                    │   │
│  │          """Get all published posts."""            │   │
│  │          return Post.objects.filter(               │   │
│  │              status=Post.Status.PUBLISHED,         │   │
│  │              published_at__lte=timezone.now()      │   │
│  │          ).select_related('author', 'category')   │   │
│  │                                                    │   │
│  │      @staticmethod                                 │   │
│  │      def get_user_posts(user):                     │   │
│  │          """Get all posts by a user."""            │   │
│  │          return Post.objects.filter(author=user)   │   │
│  │                                                    │   │
│  │      @staticmethod                                 │   │
│  │      def search_posts(query):                      │   │
│  │          """Search posts by title or content."""   │   │
│  │          from django.db.models import Q            │   │
│  │                                                    │   │
│  │          return Post.objects.filter(               │   │
│  │              Q(title__icontains=query) |           │   │
│  │              Q(content__icontains=query)           │   │
│  │          ).filter(                                 │   │
│  │              status=Post.Status.PUBLISHED          │   │
│  │          ).order_by('-published_at')              │   │
│  │                                                    │   │
│  │      @staticmethod                                 │   │
│  │      def get_post_stats(user):                     │   │
│  │          """Get statistics for a user's posts."""  │   │
│  │          posts = Post.objects.filter(author=user)  │   │
│  │                                                    │   │
│  │          return {                                  │   │
│  │              'total': posts.count(),               │   │
│  │              'published': posts.filter(            │   │
│  │                  status=Post.Status.PUBLISHED      │   │
│  │              ).count(),                            │   │
│  │              'draft': posts.filter(                │   │
│  │                  status=Post.Status.DRAFT          │   │
│  │              ).count(),                            │   │
│  │              'archived': posts.filter(             │   │
│  │                  status=Post.Status.ARCHIVED       │   │
│  │              ).count(),                            │   │
│  │          }                                         │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 6.15: Using the Service Layer in Views

**Views Calling Service Methods**

```
┌─────────────────────────────────────────────────────────────┐
│              USING THE SERVICE LAYER                        │
│                                                             │
│  Post Create View:                                          │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  from blog.services.post_service import PostService │   │
│  │                                                    │   │
│  │  @login_required                                    │   │
│  │  def post_create(request):                         │   │
│  │      if request.method == 'POST':                  │   │
│  │          try:                                      │   │
│  │              post = PostService.create_post(       │   │
│  │                  request.POST,                     │   │
│  │                  request.user                      │   │
│  │              )                                      │   │
│  │              messages.success(request,             │   │
│  │                  f'Post "{post.title}" created!')   │   │
│  │              return redirect('blog:post_detail',   │   │
│  │                          slug=post.slug)           │   │
│  │          except ValidationError as e:              │   │
│  │              messages.error(request, str(e))       │   │
│  │      else:                                          │   │
│  │          form = PostForm()                         │   │
│  │                                                    │   │
│  │      return render(request, 'blog/post_form.html', │   │
│  │                      {'form': form})               │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Dashboard View:                                            │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  @login_required                                    │   │
│  │  def dashboard(request):                            │   │
│  │      stats = PostService.get_post_stats(            │   │
│  │          request.user                               │   │
│  │      )                                              │   │
│  │      recent_posts = PostService.get_user_posts(     │   │
│  │          request.user                               │   │
│  │      )[:5]                                          │   │
│  │                                                    │   │
│  │      return render(request, 'blog/dashboard.html', │   │
│  │                      {'stats': stats,              │   │
│  │                       'recent_posts': recent_posts})│   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 6.16: Verification — Testing Advanced Architecture

**Verification Checklist**

```
┌─────────────────────────────────────────────────────────────┐
│              VERIFICATION CHECKLIST                         │
│                                                             │
│  Step 1: Test Middleware                                   │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  1. Start server: python manage.py runserver        │   │
│  │  2. Visit any page                                 │   │
│  │  3. Check console for log messages                 │   │
│  │  4. Verify security headers in browser dev tools   │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Step 2: Test Context Processors                           │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  1. Add {{ site_name }} to any template             │   │
│  │  2. Add {{ current_year }} to any template          │   │
│  │  3. Verify values appear correctly                  │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Step 3: Test Signals                                      │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  1. Create a new user via registration              │   │
│  │  2. Check console for welcome email                 │   │
│  │  3. Create and publish a post                      │   │
│  │  4. Check console for publication notification      │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Step 4: Test Service Layer                                │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  1. Open Django shell: python manage.py shell       │   │
│  │  2. from blog.services.post_service import PostService│  │
│  │  3. from django.contrib.auth.models import User    │   │
│  │  4. user = User.objects.first()                    │   │
│  │  5. stats = PostService.get_post_stats(user)       │   │
│  │  6. print(stats)                                   │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 6.17: What You've Learned in Part 6

**Skills Acquired and What You've Built**

```
┌─────────────────────────────────────────────────────────────┐
│              WHAT YOU'VE LEARNED — PART 6                  │
│                                                             │
│  ✅ Skills Acquired:                                        │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  • Understanding Django's request lifecycle         │   │
│  │  • Creating custom middleware                       │   │
│  │  • Implementing context processors                  │   │
│  │  • Working with Django signals                     │   │
│  │  • Building a service layer                        │   │
│  │  • Organizing large Django applications             │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ✅ What You've Built:                                      │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  • Request logging middleware                       │   │
│  │  • Security headers middleware                     │   │
│  │  • Global context processors                       │   │
│  │  • Signal handlers for user creation               │   │
│  │  • Signal handlers for post publication            │   │
│  │  • Service layer for business logic                │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  🎯 Ready for Part 7:                                       │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  In Part 7, we'll add real-world features:          │   │
│  │  file uploads, email, sessions, transactions!      │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 6.18: Quick Reference — Architecture Components

**Summary of Key Components**

```
┌─────────────────────────────────────────────────────────────┐
│              ARCHITECTURE COMPONENTS — REFERENCE            │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Component          │  Purpose                     │   │
│  │  ──────────────────────────────────────────────────  │   │
│  │  Middleware         │  Cross-cutting concerns      │   │
│  │  Context Processor  │  Global template variables   │   │
│  │  Signal             │  Decoupled event handling    │   │
│  │  Service Layer      │  Business logic              │   │
│  │  View               │  Request/response handling   │   │
│  │  Model              │  Data and database           │   │
│  │  Template           │  Presentation                │   │
│  │  URL                │  Routing                     │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Middleware Order:                                          │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  1. SecurityMiddleware                             │   │
│  │  2. SessionMiddleware                              │   │
│  │  3. AuthenticationMiddleware                       │   │
│  │  4. CSRFMiddleware                                 │   │
│  │  5. Custom Middleware (log, headers, etc.)        │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Signal Registration:                                       │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  # apps.py                                          │   │
│  │  def ready(self):                                  │   │
│  │      import blog.signals                           │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 6.19: Proceed to Part 7

**Preview of What's Coming**

```
┌─────────────────────────────────────────────────────────────┐
│                COMING UP IN PART 7                          │
│                                                             │
│  📎 Files, Images, Email, Sessions, and Real-World Features│
│                                                             │
│  What We'll Build:                                          │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  • File and image uploads with validation           │   │
│  │  • HTML email notifications                        │   │
│  │  • Session management for recent posts             │   │
│  │  • Database transactions for consistency           │   │
│  │  • Post scheduling and publishing                  │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  What We'll Learn:                                          │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  • Configuring media files                         │   │
│  │  • File upload validation                          │   │
│  │  • Sending HTML emails                             │   │
│  │  • Using Django sessions                           │   │
│  │  • Database transactions                           │   │
│  │  • Management commands                             │   │
│  │  • Scheduled content publication                   │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Let's build real-world features! 📎                      │
└─────────────────────────────────────────────────────────────┘
```

---

# PART 7: FILES, IMAGES, EMAIL, SESSIONS, AND REAL-WORLD FEATURES

---

## Slide 7.1: Part 7 Introduction

**Learning Objectives**

```
┌─────────────────────────────────────────────────────────────┐
│                    PART 7 OVERVIEW                          │
│                                                             │
│  🎯 Learning Objectives:                                    │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  ✅ Configure media files for uploads              │   │
│  │  ✅ Validate file uploads                          │   │
│  │  ✅ Send HTML emails                               │   │
│  │  ✅ Use Django sessions                            │   │
│  │  ✅ Implement database transactions                │   │
│  │  ✅ Build management commands                      │   │
│  │  ✅ Schedule content publication                   │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  🏗️ What We'll Build:                                      │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  • Profile and post image uploads                  │   │
│  │  • HTML email templates                            │   │
│  │  • Welcome and notification emails                │   │
│  │  • Recently viewed posts via sessions              │   │
│  │  • Atomic database operations                      │   │
│  │  • Scheduled post publishing                       │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  📚 Key Concepts:                                          │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  • MEDIA_URL and MEDIA_ROOT                       │   │
│  │  • File validation (size, type, dimensions)       │   │
│  │  • HTML emails with EmailMultiAlternatives        │   │
│  │  • Session storage                                 │   │
│  │  • @transaction.atomic                            │   │
│  │  • Management commands                             │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 7.2: Configuring Media Files

**Setting Up File Uploads**

```
┌─────────────────────────────────────────────────────────────┐
│              MEDIA FILE CONFIGURATION                       │
│                                                             │
│  Static vs. Media Files:                                    │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Static Files:                                     │   │
│  │  • CSS, JavaScript, images YOU provide             │   │
│  │  • Part of your codebase                          │   │
│  │  • Same across all environments                    │   │
│  │                                                    │   │
│  │  Media Files:                                      │   │
│  │  • Images, documents USERS upload                 │   │
│  │  • Generated at runtime                           │   │
│  │  • Vary by environment                            │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Settings Configuration:                                    │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  # config/settings.py                              │   │
│  │                                                    │   │
│  │  # Media files (User-uploaded content)            │   │
│  │  MEDIA_URL = '/media/'                            │   │
│  │  MEDIA_ROOT = BASE_DIR / 'media'                  │   │
│  │                                                    │   │
│  │  # File upload settings                           │   │
│  │  FILE_UPLOAD_MAX_MEMORY_SIZE = 2621440  # 2.5 MB │   │
│  │  DATA_UPLOAD_MAX_MEMORY_SIZE = 2621440  # 2.5 MB │   │
│  │                                                    │   │
│  │  # Allowed image types                            │   │
│  │  ALLOWED_IMAGE_TYPES = [                           │   │
│  │      'image/jpeg', 'image/png',                   │   │
│  │      'image/gif', 'image/webp'                    │   │
│  │  ]                                                 │   │
│  │  MAX_IMAGE_SIZE = 5242880  # 5 MB                │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  URL Configuration:                                         │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  # config/urls.py                                  │   │
│  │  if settings.DEBUG:                               │   │
│  │      urlpatterns += static(settings.MEDIA_URL,     │   │
│  │                          document_root=settings.MEDIA_ROOT)│  │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 7.3: File Upload Validation

**Validating Uploaded Files**

```
┌─────────────────────────────────────────────────────────────┐
│              FILE UPLOAD VALIDATION                         │
│                                                             │
│  Validators (`blog/validators.py`):                        │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  from django.core.exceptions import ValidationError │   │
│  │  from django.conf import settings                   │   │
│  │  from PIL import Image                             │   │
│  │  import magic                                       │   │
│  │                                                    │   │
│  │  def validate_file_size(value, max_size=5*1024*1024):│  │
│  │      if value.size > max_size:                     │   │
│  │          raise ValidationError(                     │   │
│  │              f'File must be under {max_size/1024/1024:.1f} MB.'│  │
│  │          )                                          │   │
│  │                                                    │   │
│  │  def validate_image_type(value):                   │   │
│  │      mime_type = magic.from_buffer(                │   │
│  │          value.read(1024), mime=True               │   │
│  │      )                                              │   │
│  │      value.seek(0)                                 │   │
│  │                                                    │   │
│  │      if mime_type not in settings.ALLOWED_IMAGE_TYPES:│  │
│  │          raise ValidationError(                     │   │
│  │              'Only JPEG, PNG, GIF, and WebP are allowed.'│  │
│  │          )                                          │   │
│  │                                                    │   │
│  │  def validate_image_dimensions(value, min_w=100,  │   │
│  │                                 min_h=100, max_w=2000, max_h=2000):│  │
│  │      try:                                          │   │
│  │          img = Image.open(value)                  │   │
│  │          width, height = img.size                 │   │
│  │                                                    │   │
│  │          if width < min_w or height < min_h:      │   │
│  │              raise ValidationError(                 │   │
│  │                  f'Image must be at least {min_w}x{min_h}.'│  │
│  │              )                                      │   │
│  │                                                    │   │
│  │          if width > max_w or height > max_h:      │   │
│  │              raise ValidationError(                 │   │
│  │                  f'Image must be at most {max_w}x{max_h}.'│  │
│  │              )                                      │   │
│  │      except Exception as e:                        │   │
│  │          raise ValidationError(f'Invalid image: {e}')│  │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 7.4: Using Validators in Forms

**Adding Validation to Post and Profile Forms**

```
┌─────────────────────────────────────────────────────────────┐
│              USING VALIDATORS IN FORMS                      │
│                                                             │
│  PostForm Validation:                                       │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  from .validators import (                          │   │
│  │      validate_file_size, validate_image_type,      │   │
│  │      validate_image_dimensions,                    │   │
│  │      validate_filename_safety                      │   │
│  │  )                                                  │   │
│  │                                                    │   │
│  │  class PostForm(forms.ModelForm):                  │   │
│  │      # ...                                         │   │
│  │                                                    │   │
│  │      def clean_featured_image(self):               │   │
│  │          image = self.cleaned_data.get('featured_image')│  │
│  │                                                    │   │
│  │          if image:                                 │   │
│  │              validate_filename_safety(image)       │   │
│  │              validate_file_size(image,             │   │
│  │                  max_size=5 * 1024 * 1024)        │   │
│  │              validate_image_type(image)            │   │
│  │              validate_image_dimensions(             │   │
│  │                  image,                            │   │
│  │                  min_width=400,                    │   │
│  │                  min_height=300,                   │   │
│  │                  max_width=2000,                   │   │
│  │                  max_height=2000                   │   │
│  │              )                                      │   │
│  │                                                    │   │
│  │          return image                              │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ProfileForm Validation:                                    │
│  ┌─────────────────────────────────────────────────────┐   │
│  │      def clean_avatar(self):                       │   │
│  │          avatar = self.cleaned_data.get('avatar')  │   │
│  │          if avatar:                                │   │
│  │              validate_filename_safety(avatar)      │   │
│  │              validate_file_size(avatar,            │   │
│  │                  max_size=2 * 1024 * 1024)        │   │
│  │              validate_image_type(avatar)           │   │
│  │              validate_image_dimensions(             │   │
│  │                  avatar,                           │   │
│  │                  min_width=100,                    │   │
│  │                  min_height=100,                   │   │
│  │                  max_width=1000,                   │   │
│  │                  max_height=1000                   │   │
│  │              )                                      │   │
│  │          return avatar                             │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 7.5: Sending HTML Emails

**Email Configuration and Sending**

```
┌─────────────────────────────────────────────────────────────┐
│              SENDING HTML EMAILS                            │
│                                                             │
│  Email Configuration:                                       │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  # config/settings.py                              │   │
│  │                                                    │   │
│  │  if DEBUG:                                          │   │
│  │      EMAIL_BACKEND = 'django.core.mail.backends.   │   │
│  │                      console.EmailBackend'          │   │
│  │  else:                                              │   │
│  │      EMAIL_BACKEND = 'django.core.mail.backends.   │   │
│  │                      smtp.EmailBackend'             │   │
│  │      EMAIL_HOST = os.environ.get('EMAIL_HOST')     │   │
│  │      EMAIL_PORT = int(os.environ.get('EMAIL_PORT', 587))│  │
│  │      EMAIL_USE_TLS = True                           │   │
│  │      EMAIL_HOST_USER = os.environ.get('EMAIL_HOST_USER')│  │
│  │      EMAIL_HOST_PASSWORD = os.environ.get('EMAIL_HOST_PASSWORD')│  │
│  │      DEFAULT_FROM_EMAIL = os.environ.get('DEFAULT_FROM_EMAIL')│  │
│  │                                                    │   │
│  │      SITE_URL = os.environ.get('SITE_URL',         │   │
│  │                  'http://localhost:8000')          │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Sending HTML Email:                                        │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  from django.core.mail import EmailMultiAlternatives │   │
│  │  from django.template.loader import render_to_string│   │
│  │  from django.utils.html import strip_tags           │   │
│  │                                                    │   │
│  │  # Render HTML email                               │   │
│  │  html_content = render_to_string(                  │   │
│  │      'email/welcome.html', context                 │   │
│  │  )                                                  │   │
│  │  text_content = strip_tags(html_content)            │   │
│  │                                                    │   │
│  │  # Create email with both versions                │   │
│  │  email = EmailMultiAlternatives(                   │   │
│  │      subject='Welcome to Django Blog!',            │   │
│  │      body=text_content,                            │   │
│  │      from_email=settings.DEFAULT_FROM_EMAIL,       │   │
│  │      to=[user.email]                               │   │
│  │  )                                                  │   │
│  │  email.attach_alternative(html_content, "text/html")│  │
│  │  email.send(fail_silently=True)                    │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 7.6: HTML Email Templates

**Welcome Email Template**

```
┌─────────────────────────────────────────────────────────────┐
│              HTML EMAIL TEMPLATES                           │
│                                                             │
│  `templates/email/welcome.html`:                           │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  <!DOCTYPE html>                                    │   │
│  │  <html>                                             │   │
│  │  <head>                                             │   │
│  │      <style>                                        │   │
│  │          body { font-family: Arial, sans-serif;    │   │
│  │                 line-height: 1.6; color: #333; }   │   │
│  │          .container { max-width: 600px; margin: 0 auto;│  │
│  │                       padding: 20px; }             │   │
│  │          .header { background: #2c3e50;            │   │
│  │                    color: white; padding: 20px;    │   │
│  │                    text-align: center; }           │   │
│  │          .content { padding: 20px; }              │   │
│  │          .button { display: inline-block;          │   │
│  │                    padding: 10px 20px;             │   │
│  │                    background: #3498db;            │   │
│  │                    color: white;                   │   │
│  │                    text-decoration: none;          │   │
│  │                    border-radius: 4px; }           │   │
│  │          .footer { margin-top: 20px; padding: 10px;│   │
│  │                    background: #f8f9fa;            │   │
│  │                    text-align: center;             │   │
│  │                    font-size: 12px;                │   │
│  │                    color: #7f8c8d; }              │   │
│  │      </style>                                       │   │
│  │  </head>                                            │   │
│  │  <body>                                             │   │
│  │      <div class="container">                        │   │
│  │          <div class="header">                       │   │
│  │              <h1>Welcome to Django Blog!</h1>      │   │
│  │          </div>                                     │   │
│  │          <div class="content">                      │   │
│  │              <p>Hello {{ username }},</p>           │   │
│  │              <p>Welcome to Django Blog! We're      │   │
│  │                 excited to have you join.</p>      │   │
│  │              <h3>Here's what you can do:</h3>      │   │
│  │              <ul>                                   │   │
│  │                  <li>📝 Create blog posts</li>     │   │
│  │                  <li>💬 Comment on posts</li>      │   │
│  │                  <li>👥 Connect with others</li>   │   │
│  │              </ul>                                  │   │
│  │              <p>                                   │   │
│  │                  <a href="{{ site_url }}/dashboard/" │   │
│  │                     class="button">                │   │
│  │                      Visit Dashboard                │   │
│  │                  </a>                              │   │
│  │              </p>                                   │   │
│  │              <p>Best regards,<br>The Django Blog Team</p>│  │
│  │          </div>                                     │   │
│  │          <div class="footer">                      │   │
│  │              <p>&copy; {{ current_year }} Django Blog</p>│  │
│  │          </div>                                     │   │
│  │      </div>                                         │   │
│  │  </body>                                            │   │
│  │  </html>                                            │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 7.7: Post Publication Email Template

**Notification Email Template**

```
┌─────────────────────────────────────────────────────────────┐
│              POST PUBLICATION EMAIL TEMPLATE                │
│                                                             │
│  `templates/email/post_published.html`:                    │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  <!DOCTYPE html>                                    │   │
│  │  <html>                                             │   │
│  │  <head>                                             │   │
│  │      <style>                                        │   │
│  │          body { font-family: Arial, sans-serif;    │   │
│  │                 line-height: 1.6; color: #333; }   │   │
│  │          .container { max-width: 600px; margin: 0 auto;│  │
│  │                       padding: 20px; }             │   │
│  │          .header { background: #27ae60;            │   │
│  │                    color: white; padding: 20px;    │   │
│  │                    text-align: center; }           │   │
│  │          .content { padding: 20px; }              │   │
│  │          .post-preview { background: #f8f9fa;     │   │
│  │                         padding: 15px;             │   │
│  │                         border-radius: 4px;        │   │
│  │                         margin: 10px 0; }          │   │
│  │          .button { display: inline-block;          │   │
│  │                    padding: 10px 20px;             │   │
│  │                    background: #3498db;            │   │
│  │                    color: white;                   │   │
│  │                    text-decoration: none;          │   │
│  │                    border-radius: 4px; }           │   │
│  │      </style>                                       │   │
│  │  </head>                                            │   │
│  │  <body>                                             │   │
│  │      <div class="container">                        │   │
│  │          <div class="header">                       │   │
│  │              <h1>📝 Your Post is Published!</h1>   │   │
│  │          </div>                                     │   │
│  │          <div class="content">                      │   │
│  │              <p>Hello {{ username }},</p>           │   │
│  │              <p>Congratulations! Your post         │   │
│  │                 "<strong>{{ post_title }}</strong>" │   │
│  │                 is now live!</p>                   │   │
│  │                                                    │   │
│  │              <div class="post-preview">            │   │
│  │                  <h3>{{ post_title }}</h3>         │   │
│  │                  <p>{{ post_excerpt|truncatechars:200 }}</p>│  │
│  │              </div>                                 │   │
│  │                                                    │   │
│  │              <p>                                   │   │
│  │                  <a href="{{ site_url }}{{ post_url }}" │   │
│  │                     class="button">                │   │
│  │                      View Your Post                │   │
│  │                  </a>                              │   │
│  │              </p>                                   │   │
│  │              <p>Keep writing!<br>The Django Blog Team</p>│  │
│  │          </div>                                     │   │
│  │          <div class="footer">                      │   │
│  │              <p>&copy; {{ current_year }} Django Blog</p>│  │
│  │          </div>                                     │   │
│  │      </div>                                         │   │
│  │  </body>                                            │   │
│  │  </html>                                            │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 7.8: Working with Sessions — Recent Posts

**Tracking Recently Viewed Posts**

```
┌─────────────────────────────────────────────────────────────┐
│              SESSIONS — RECENT POSTS                        │
│                                                             │
│  What Are Sessions?                                         │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Store temporary data about a user between requests │   │
│  │  Identified by a session cookie                    │   │
│  │  Perfect for: cart, recent views, preferences      │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Post Detail View with Session Tracking:                   │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  class PostDetailView(DetailView):                 │   │
│  │      # ...                                         │   │
│  │                                                    │   │
│  │      def get_context_data(self, **kwargs):        │   │
│  │          context = super().get_context_data(**kwargs)│  │
│  │          post = self.get_object()                 │   │
│  │                                                    │   │
│  │          # Track recently viewed posts            │   │
│  │          recent_posts = self.request.session.get(  │   │
│  │              'recent_posts', []                    │   │
│  │          )                                          │   │
│  │                                                    │   │
│  │          if post.status == Post.Status.PUBLISHED:  │   │
│  │              # Remove if already exists           │   │
│  │              if post.id in recent_posts:           │   │
│  │                  recent_posts.remove(post.id)     │   │
│  │              # Add to front                       │   │
│  │              recent_posts.insert(0, post.id)      │   │
│  │              # Keep only last 5                   │   │
│  │              recent_posts = recent_posts[:5]      │   │
│  │              self.request.session['recent_posts'] = │   │
│  │                  recent_posts                      │   │
│  │                                                    │   │
│  │          # Get actual post objects                │   │
│  │          recent_post_objects = []                 │   │
│  │          for post_id in recent_posts[:5]:         │   │
│  │              try:                                  │   │
│  │                  recent = Post.objects.get(       │   │
│  │                      id=post_id,                  │   │
│  │                      status=Post.Status.PUBLISHED │   │
│  │                  )                                 │   │
│  │                  recent_post_objects.append(recent)│   │
│  │              except Post.DoesNotExist:            │   │
│  │                  pass                             │   │
│  │                                                    │   │
│  │          context['recently_viewed'] = recent_post_objects│  │
│  │          return context                            │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 7.9: Clear Recent Posts View

**Managing Session Data**

```
┌─────────────────────────────────────────────────────────────┐
│              CLEAR RECENT POSTS VIEW                        │
│                                                             │
│  View to Clear Session Data:                                │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  @login_required                                    │   │
│  │  def clear_recent_posts(request):                   │   │
│  │      """Clear the user's recently viewed posts."""  │   │
│  │      if 'recent_posts' in request.session:         │   │
│  │          del request.session['recent_posts']       │   │
│  │          messages.success(request,                  │   │
│  │              'Recent posts history cleared.')       │   │
│  │                                                    │   │
│  │      return redirect('blog:dashboard')             │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  URL Pattern:                                               │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  path('clear-recent/', views.clear_recent_posts,    │   │
│  │       name='clear_recent'),                         │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Session Operations Reference:                              │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  # Set a session variable                           │   │
│  │  request.session['key'] = 'value'                  │   │
│  │                                                    │   │
│  │  # Get a session variable (with default)           │   │
│  │  value = request.session.get('key', 'default')     │   │
│  │                                                    │   │
│  │  # Check if key exists                             │   │
│  │  if 'key' in request.session:                     │   │
│  │                                                    │   │
│  │  # Delete a session variable                       │   │
│  │  del request.session['key']                        │   │
│  │                                                    │   │
│  │  # Clear all session data                          │   │
│  │  request.session.clear()                           │   │
│  │                                                    │   │
│  │  # Session expiration (1 hour)                    │   │
│  │  request.session.set_expiry(3600)                 │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 7.10: Database Transactions

**Ensuring Data Consistency**

```
┌─────────────────────────────────────────────────────────────┐
│              DATABASE TRANSACTIONS                          │
│                                                             │
│  What Are Transactions?                                     │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  A group of database operations that either all     │   │
│  │  succeed or all fail.                              │   │
│  │                                                    │   │
│  │  ACID Properties:                                  │   │
│  │  • Atomicity: All or nothing                      │   │
│  │  • Consistency: Data follows rules                │   │
│  │  • Isolation: Transactions don't interfere         │   │
│  │  • Durability: Committed changes persist           │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Using @transaction.atomic:                                 │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  from django.db import transaction                  │   │
│  │                                                    │   │
│  │  class PostService:                                │   │
│  │      @staticmethod                                 │   │
│  │      @transaction.atomic                           │   │
│  │      def create_post_with_tags(data, author):     │   │
│  │          """Create post and tags in a transaction."""│  │
│  │                                                    │   │
│  │          # Create post                            │   │
│  │          post = Post.objects.create(               │   │
│  │              title=data['title'],                  │   │
│  │              content=data['content'],              │   │
│  │              author=author,                        │   │
│  │              category=data.get('category'),        │   │
│  │              status=data.get('status', 'draft')    │   │
│  │          )                                          │   │
│  │                                                    │   │
│  │          # Process tags (same transaction)        │   │
│  │          tags_input = data.get('tags_input', '')  │   │
│  │          if tags_input:                            │   │
│  │              tag_names = [                         │   │
│  │                  tag.strip().lower()              │   │
│  │                  for tag in tags_input.split(',')  │   │
│  │                  if tag.strip()                   │   │
│  │              ]                                      │   │
│  │                                                    │   │
│  │              for tag_name in tag_names:            │   │
│  │                  tag, created = Tag.objects.       │   │
│  │                      get_or_create(                │   │
│  │                          name=tag_name,            │   │
│  │                          defaults={                │   │
│  │                              'slug': slugify(tag_name)│  │
│  │                          }                         │   │
│  │                      )                             │   │
│  │                  post.tags.add(tag)                │   │
│  │                                                    │   │
│  │          return post                              │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 7.11: Bulk Operations with Transactions

**Bulk Updates in Transactions**

```
┌─────────────────────────────────────────────────────────────┐
│              BULK OPERATIONS WITH TRANSACTIONS              │
│                                                             │
│  Bulk Update Service Method:                                 │
│  ┌─────────────────────────────────────────────────────┐   │
│  │      @staticmethod                                 │   │
│  │      @transaction.atomic                           │   │
│  │      def bulk_update_posts(post_ids, update_data): │   │
│  │          """Update multiple posts atomically."""   │   │
│  │          if not post_ids:                          │   │
│  │              return 0                              │   │
│  │                                                    │   │
│  │          posts = Post.objects.filter(              │   │
│  │              id__in=post_ids                       │   │
│  │          )                                          │   │
│  │                                                    │   │
│  │          updated_count = 0                         │   │
│  │          for post in posts:                        │   │
│  │              for key, value in update_data.items():│   │
│  │                  setattr(post, key, value)        │   │
│  │              post.save()                            │   │
│  │              updated_count += 1                    │   │
│  │                                                    │   │
│  │          return updated_count                     │   │
│  │                                                    │   │
│  │      @staticmethod                                 │   │
│  │      @transaction.atomic                           │   │
│  │      def move_posts_to_category(post_ids, category):│   │
│  │          """Move multiple posts to a new category."""│  │
│  │          if not post_ids:                          │   │
│  │              return 0                              │   │
│  │                                                    │   │
│  │          posts = Post.objects.filter(              │   │
│  │              id__in=post_ids                       │   │
│  │          )                                          │   │
│  │          updated = posts.update(category=category) │   │
│  │          return updated                            │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Benefits of Transactions:                                  │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  ✅ Data consistency                                │   │
│  │  ✅ Rollback on any failure                        │   │
│  │  ✅ Atomic operations                              │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 7.12: Post Scheduling — Adding the Field

**Scheduled Publication Field**

```
┌─────────────────────────────────────────────────────────────┐
│              POST SCHEDULING — ADDING THE FIELD             │
│                                                             │
│  Add Field to Post Model:                                   │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  class Post(models.Model):                          │   │
│  │      # ... existing fields ...                     │   │
│  │                                                    │   │
│  │      scheduled_publish_at = models.DateTimeField(   │   │
│  │          blank=True,                                │   │
│  │          null=True,                                 │   │
│  │          help_text="If set, the post will be       │   │
│  │                     published at this date and time."│   │
│  │      )                                              │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Update Form:                                               │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  class PostForm(forms.ModelForm):                  │   │
│  │      class Meta:                                    │   │
│  │          model = Post                               │   │
│  │          fields = [                                 │   │
│  │              # ... existing fields ...             │   │
│  │              'scheduled_publish_at',  # Add this   │   │
│  │          ]                                          │   │
│  │          widgets = {                                │   │
│  │              # ... existing widgets ...             │   │
│  │              'scheduled_publish_at':                │   │
│  │                  forms.DateTimeInput(attrs={        │   │
│  │                      'class': 'form-control',      │   │
│  │                      'type': 'datetime-local'      │   │
│  │                  }),                                │   │
│  │          }                                          │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Create Migration:                                          │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  python manage.py makemigrations blog              │   │
│  │  python manage.py migrate blog                     │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 7.13: Management Command — Publish Scheduled Posts

**Scheduled Publication Command**

```
┌─────────────────────────────────────────────────────────────┐
│              MANAGEMENT COMMAND — SCHEDULED POSTS           │
│                                                             │
│  Directory Structure:                                       │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  blog/                                              │   │
│  │  ├── management/                                    │   │
│  │  │   ├── __init__.py                               │   │
│  │  │   └── commands/                                  │   │
│  │  │       ├── __init__.py                           │   │
│  │  │       └── publish_scheduled_posts.py            │   │
│  │  └── ...                                            │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Command Code:                                              │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  from django.core.management.base import BaseCommand│   │
│  │  from django.utils import timezone                  │   │
│  │  from blog.models import Post                       │   │
│  │                                                    │   │
│  │  class Command(BaseCommand):                       │   │
│  │      help = 'Publish posts scheduled for publication'│  │
│  │                                                    │   │
│  │      def handle(self, *args, **options):           │   │
│  │          now = timezone.now()                      │   │
│  │                                                    │   │
│  │          scheduled_posts = Post.objects.filter(    │   │
│  │              status=Post.Status.DRAFT,             │   │
│  │              scheduled_publish_at__lte=now         │   │
│  │          )                                          │   │
│  │                                                    │   │
│  │          count = scheduled_posts.count()           │   │
│  │                                                    │   │
│  │          if count == 0:                            │   │
│  │              self.stdout.write(                    │   │
│  │                  'No posts scheduled for publication.'│  │
│  │              )                                      │   │
│  │              return                                │   │
│  │                                                    │   │
│  │          for post in scheduled_posts:              │   │
│  │              post.status = Post.Status.PUBLISHED   │   │
│  │              post.published_at = now               │   │
│  │              post.save()                            │   │
│  │              self.stdout.write(f'Published: {post.title}')│  │
│  │                                                    │   │
│  │          self.stdout.write(                        │   │
│  │              self.style.SUCCESS(                   │   │
│  │                  f'Successfully published {count} post(s).'│  │
│  │              )                                      │   │
│  │          )                                          │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Usage:                                                     │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  python manage.py publish_scheduled_posts          │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 7.14: Dashboard — Display Scheduled Posts

**Showing Scheduled Posts in Dashboard**

```
┌─────────────────────────────────────────────────────────────┐
│              DASHBOARD — SCHEDULED POSTS                    │
│                                                             │
│  Update Dashboard View:                                     │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  @login_required                                    │   │
│  │  def dashboard(request):                            │   │
│  │      # ... existing code ...                       │   │
│  │                                                    │   │
│  │      # Scheduled posts                             │   │
│  │      scheduled_posts = Post.objects.filter(        │   │
│  │          author=user,                              │   │
│  │          status=Post.Status.DRAFT,                 │   │
│  │          scheduled_publish_at__isnull=False       │   │
│  │      ).order_by('scheduled_publish_at')           │   │
│  │                                                    │   │
│  │      context['scheduled_posts'] = scheduled_posts  │   │
│  │      return render(request, 'blog/dashboard.html',  │   │
│  │                      context)                      │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Dashboard Template Addition:                               │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  <!-- Scheduled Posts -->                           │   │
│  │  {% if scheduled_posts %}                           │   │
│  │      <div class="content" style="margin-bottom: 2rem;">│  │
│  │          <h2>📅 Scheduled Posts</h2>               │   │
│  │          {% for post in scheduled_posts %}         │   │
│  │              <div style="display: flex;            │   │
│  │                   justify-content: space-between;  │   │
│  │                   align-items: center;             │   │
│  │                   padding: 0.5rem 0;               │   │
│  │                   border-bottom: 1px solid #eee;">│   │
│  │                  <div>                             │   │
│  │                      <strong>{{ post.title }}</strong>│  │
│  │                      <span style="color: #7f8c8d;  │   │
│  │                           font-size: 0.9rem;">    │   │
│  │                          Scheduled for:            │   │
│  │                          {{ post.scheduled_publish_at|date:"F j, Y g:i a" }}│  │
│  │                      </span>                       │   │
│  │                  </div>                            │   │
│  │                  <div>                             │   │
│  │                      <a href="{% url 'blog:post_edit' post.slug %}">│  │
│  │                          Edit                      │   │
│  │                      </a>                          │   │
│  │                      <a href="{% url 'blog:post_delete' post.slug %}"│  │
│  │                         style="color: #e74c3c;">  │   │
│  │                          Delete                    │   │
│  │                      </a>                          │   │
│  │                  </div>                            │   │
│  │              </div>                                │   │
│  │          {% endfor %}                              │   │
│  │      </div>                                         │   │
│  │  {% endif %}                                        │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 7.15: Verification — Testing Real-World Features

**Comprehensive Verification Checklist**

```
┌─────────────────────────────────────────────────────────────┐
│              VERIFICATION CHECKLIST                         │
│                                                             │
│  Step 1: Test File Uploads                                 │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  1. Log in and edit profile                         │   │
│  │  2. Upload an avatar                                │   │
│  │  3. Verify it appears on profile                    │   │
│  │  4. Create a post with featured image               │   │
│  │  5. Verify image appears on post detail            │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Step 2: Test Email Notifications                          │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  1. Register a new user                             │   │
│  │  2. Check console for welcome email                 │   │
│  │  3. Create and publish a post                      │   │
│  │  4. Check console for publication notification      │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Step 3: Test Sessions                                     │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  1. Visit several blog posts                        │   │
│  │  2. Verify recent posts are tracked                 │   │
│  │  3. Check session data in debug toolbar             │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Step 4: Test Scheduled Posts                              │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  1. Create a post with "Draft" status               │   │
│  │  2. Set scheduled publish date 5 minutes in future  │   │
│  │  3. Run: python manage.py publish_scheduled_posts  │   │
│  │  4. Verify post becomes published                   │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Step 5: Test Transactions                                 │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  1. Create a post with multiple tags                │   │
│  │  2. If any tag creation fails, entire operation     │   │
│  │     should roll back                                │   │
│  │  3. Verify data consistency                         │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 7.16: What You've Learned in Part 7

**Skills Acquired and What You've Built**

```
┌─────────────────────────────────────────────────────────────┐
│              WHAT YOU'VE LEARNED — PART 7                  │
│                                                             │
│  ✅ Skills Acquired:                                        │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  • Configuring media files for uploads             │   │
│  │  • Validating file uploads                          │   │
│  │  • Sending HTML emails                              │   │
│  │  • Using Django sessions                            │   │
│  │  • Implementing database transactions               │   │
│  │  • Building management commands                    │   │
│  │  • Scheduling content publication                  │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ✅ What You've Built:                                      │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  • Profile and post image uploads                  │   │
│  │  • HTML email templates                            │   │
│  │  • Welcome and notification emails                │   │
│  │  • Recently viewed posts via sessions              │   │
│  │  • Atomic database operations                      │   │
│  │  • Scheduled post publishing                       │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  🎯 Ready for Part 8:                                       │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  In Part 8, we'll write comprehensive tests and     │   │
│  │  implement logging for debugging and monitoring!    │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 7.17: Quick Reference — Email Operations

**Email Sending Reference**

```
┌─────────────────────────────────────────────────────────────┐
│              EMAIL OPERATIONS — REFERENCE                   │
│                                                             │
│  Simple Email:                                              │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  from django.core.mail import send_mail             │   │
│  │                                                    │   │
│  │  send_mail(                                        │   │
│  │      subject='Subject',                             │   │
│  │      message='Message body',                        │   │
│  │      from_email='from@example.com',                 │   │
│  │      recipient_list=['to@example.com'],            │   │
│  │      fail_silently=True,                           │   │
│  │  )                                                  │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  HTML Email:                                                │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  from django.core.mail import EmailMultiAlternatives │   │
│  │  from django.template.loader import render_to_string│   │
│  │  from django.utils.html import strip_tags           │   │
│  │                                                    │   │
│  │  html_content = render_to_string('email/template.html', │  │
│  │                                 context)            │   │
│  │  text_content = strip_tags(html_content)           │   │
│  │                                                    │   │
│  │  email = EmailMultiAlternatives(                   │   │
│  │      subject='Subject',                            │   │
│  │      body=text_content,                            │   │
│  │      from_email='from@example.com',                │   │
│  │      to=['to@example.com']                         │   │
│  │  )                                                  │   │
│  │  email.attach_alternative(html_content, "text/html")│  │
│  │  email.send(fail_silently=True)                    │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Email Settings:                                            │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  EMAIL_BACKEND = 'django.core.mail.backends.       │   │
│  │                  smtp.EmailBackend'                 │   │
│  │  EMAIL_HOST = 'smtp.gmail.com'                     │   │
│  │  EMAIL_PORT = 587                                  │   │
│  │  EMAIL_USE_TLS = True                              │   │
│  │  EMAIL_HOST_USER = 'your-email@gmail.com'          │   │
│  │  EMAIL_HOST_PASSWORD = 'your-app-password'         │   │
│  │  DEFAULT_FROM_EMAIL = 'noreply@example.com'        │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 7.18: Quick Reference — Session Operations

**Session Management Reference**

```
┌─────────────────────────────────────────────────────────────┐
│              SESSION OPERATIONS — REFERENCE                 │
│                                                             │
│  Basic Operations:                                          │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  # Set a session variable                           │   │
│  │  request.session['key'] = 'value'                  │   │
│  │                                                    │   │
│  │  # Get a session variable (with default)           │   │
│  │  value = request.session.get('key', 'default')     │   │
│  │                                                    │   │
│  │  # Check if key exists                             │   │
│  │  if 'key' in request.session:                     │   │
│  │                                                    │   │
│  │  # Delete a session variable                       │   │
│  │  del request.session['key']                        │   │
│  │                                                    │   │
│  │  # Clear all session data                          │   │
│  │  request.session.clear()                           │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Session Configuration:                                     │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  # Settings                                         │   │
│  │  SESSION_ENGINE = 'django.contrib.sessions.backends.cached_db'│  │
│  │  SESSION_COOKIE_AGE = 86400  # 24 hours            │   │
│  │  SESSION_COOKIE_SECURE = True  # HTTPS only        │   │
│  │  SESSION_COOKIE_HTTPONLY = True  # No JS access    │   │
│  │  SESSION_COOKIE_SAMESITE = 'Lax'                   │   │
│  │                                                    │   │
│  │  # Per-session expiration                          │   │
│  │  request.session.set_expiry(3600)  # 1 hour       │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Session Backends:                                          │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Backend                    │  Use Case             │   │
│  │  ──────────────────────────────────────────────────  │   │
│  │  db (database)              │  Production default   │   │
│  │  cache (Redis/Memcached)    │  High performance     │   │
│  │  cached_db                  │  Best of both         │   │
│  │  file                       │  Development          │   │
│  │  signed_cookies             │  No server storage    │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 7.19: Proceed to Part 8

**Preview of What's Coming**

```
┌─────────────────────────────────────────────────────────────┐
│                COMING UP IN PART 8                          │
│                                                             │
│  🧪 Testing, Debugging, Logging, and Quality               │
│                                                             │
│  What We'll Build:                                          │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  • Comprehensive test suite for models, forms,     │   │
│  │    and views                                        │   │
│  │  • Logging configuration for debugging             │   │
│  │  • Debugging tools for development                 │   │
│  │  • Code quality automation                         │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  What We'll Learn:                                          │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  • Writing unit tests for models                   │   │
│  │  • Writing tests for forms                         │   │
│  │  • Writing tests for views                         │   │
│  │  • Implementing logging                            │   │
│  │  • Using debugging tools                           │   │
│  │  • Setting up pre-commit hooks                    │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Preview of Testing Pyramid:                                │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  ┌─────────────────────────────────────────────────┐│   │
│  │  │           UI / End-to-End Tests                ││   │
│  │  │  ┌───────────────────────────────────────────┐ ││   │
│  │  │  │        Integration Tests                  │ ││   │
│  │  │  │  ┌─────────────────────────────────────┐  │ ││   │
│  │  │  │  │        Unit Tests                  │  │ ││   │
│  │  │  │  └─────────────────────────────────────┘  │ ││   │
│  │  │  └───────────────────────────────────────────┘ ││   │
│  │  └─────────────────────────────────────────────────┘│   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Let's ensure quality with testing! 🧪                    │
└─────────────────────────────────────────────────────────────┘
```

---

# PART 8: TESTING, DEBUGGING, LOGGING, AND QUALITY

---

## Slide 8.1: Part 8 Introduction

**Learning Objectives**

```
┌─────────────────────────────────────────────────────────────┐
│                    PART 8 OVERVIEW                          │
│                                                             │
│  🎯 Learning Objectives:                                    │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  ✅ Write unit tests for models                    │   │
│  │  ✅ Write tests for forms                          │   │
│  │  ✅ Write tests for views                          │   │
│  │  ✅ Implement logging                              │   │
│  │  ✅ Use debugging tools                            │   │
│  │  ✅ Set up pre-commit hooks                       │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  🏗️ What We'll Build:                                      │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  • Comprehensive test suite                         │   │
│  │  • Logging configuration                           │   │
│  │  • Debug toolbar setup                             │   │
│  │  • Code quality automation                         │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  📚 Key Concepts:                                          │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  • TestCase and its subclasses                    │   │
│  │  • Assertion methods                              │   │
│  │  • Test client                                    │   │
│  │  • Logging levels (DEBUG, INFO, WARNING, ERROR)   │   │
│  │  • Debug Toolbar                                  │   │
│  │  • Pre-commit hooks                               │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 8.2: Understanding Django Testing

**Why Testing Matters**

```
┌─────────────────────────────────────────────────────────────┐
│              UNDERSTANDING DJANGO TESTING                   │
│                                                             │
│  Why Testing Matters:                                       │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  ✅ Catches bugs before users do                    │   │
│  │  ✅ Ensures code works correctly                    │   │
│  │  ✅ Prevents regressions when adding features       │   │
│  │  ✅ Provides documentation for your code            │   │
│  │  ✅ Builds confidence in your application           │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Types of Tests:                                            │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Type               │  Purpose                     │   │
│  │  ──────────────────────────────────────────────────  │   │
│  │  Unit Tests         │  Test individual components  │   │
│  │  Integration Tests  │  Test how components work    │   │
│  │                     │  together                    │   │
│  │  Functional Tests   │  Test complete user          │   │
│  │                     │  workflows                   │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Django's Test Hierarchy:                                   │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  TestCase                                            │   │
│  │    ├── SimpleTestCase (no database)                 │   │
│  │    ├── TransactionTestCase (database with rollback) │   │
│  │    ├── TestCase (database with transactions)        │   │
│  │    └── LiveServerTestCase (with live server)        │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 8.3: Setting Up Test Configuration

**Test Environment Setup**

```
┌─────────────────────────────────────────────────────────────┐
│              TEST CONFIGURATION                             │
│                                                             │
│  Settings for Testing:                                      │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  # config/settings.py                              │   │
│  │                                                    │   │
│  │  TEST_RUNNER = 'django.test.runner.DiscoverRunner' │   │
│  │                                                    │   │
│  │  # Use in-memory SQLite for faster tests          │   │
│  │  if 'test' in sys.argv:                            │   │
│  │      DATABASES = {                                 │   │
│  │          'default': {                              │   │
│  │              'ENGINE': 'django.db.backends.sqlite3',│  │
│  │              'NAME': ':memory:',                   │   │
│  │          }                                          │   │
│  │      }                                              │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Benefits of In-Memory Database:                            │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  ✅ Tests run faster                                │   │
│  │  ✅ No file I/O                                    │   │
│  │  ✅ Clean state for each test                      │   │
│  │  ✅ Perfect for CI/CD pipelines                     │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Running Tests:                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  # Run all tests                                    │   │
│  │  python manage.py test blog                         │   │
│  │                                                    │   │
│  │  # Run specific test class                         │   │
│  │  python manage.py test blog.tests.test_models      │   │
│  │                                                    │   │
│  │  # Run with verbosity                              │   │
│  │  python manage.py test blog --verbosity=2         │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 8.4: Creating Test Utilities — Base Test Case

**Common Setup for All Tests**

```
┌─────────────────────────────────────────────────────────────┐
│              BASE TEST CASE                                 │
│                                                             │
│  Code (`blog/tests/test_utils.py`):                        │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  from django.test import TestCase                   │   │
│  │  from django.contrib.auth.models import User        │   │
│  │  from django.utils import timezone                  │   │
│  │  from blog.models import Category, Tag, Post, Comment│  │
│  │                                                    │   │
│  │  class BaseTestCase(TestCase):                     │   │
│  │      """Base test case with common setup."""      │   │
│  │                                                    │   │
│  │      def setUp(self):                              │   │
│  │          self.setup_users()                        │   │
│  │          self.setup_categories()                   │   │
│  │          self.setup_tags()                         │   │
│  │          self.setup_posts()                        │   │
│  │          self.setup_comments()                     │   │
│  │                                                    │   │
│  │      def setup_users(self):                       │   │
│  │          self.user = User.objects.create_user(     │   │
│  │              username='testuser',                  │   │
│  │              email='test@example.com',             │   │
│  │              password='testpass123'                │   │
│  │          )                                          │   │
│  │          self.admin = User.objects.create_superuser(│  │
│  │              username='admin',                     │   │
│  │              email='admin@example.com',            │   │
│  │              password='adminpass123'               │   │
│  │          )                                          │   │
│  │          self.other_user = User.objects.create_user(│  │
│  │              username='otheruser',                 │   │
│  │              email='other@example.com',            │   │
│  │              password='otherpass123'               │   │
│  │          )                                          │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 8.5: Testing Models — Category

**Model Tests Example**

```
┌─────────────────────────────────────────────────────────────┐
│              TESTING MODELS — CATEGORY                      │
│                                                             │
│  Code (`blog/tests/test_models.py`):                       │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  from django.test import TestCase                   │   │
│  │  from blog.models import Category                   │   │
│  │  from blog.tests.test_utils import BaseTestCase    │   │
│  │                                                    │   │
│  │  class CategoryModelTest(BaseTestCase):            │   │
│  │      """Test the Category model."""               │   │
│  │                                                    │   │
│  │      def test_category_creation(self):             │   │
│  │          """Test creating a category."""           │   │
│  │          self.assertEqual(self.category.name,       │   │
│  │                           'Test Category')          │   │
│  │          self.assertEqual(self.category.slug,       │   │
│  │                           'test-category')          │   │
│  │                                                    │   │
│  │      def test_category_str_method(self):           │   │
│  │          """Test the __str__ method."""            │   │
│  │          self.assertEqual(str(self.category),      │   │
│  │                           'Test Category')          │   │
│  │                                                    │   │
│  │      def test_category_slug_auto_generation(self): │   │
│  │          """Test slug auto-generation."""          │   │
│  │          category = Category.objects.create(       │   │
│  │              name='New Category'                   │   │
│  │          )                                          │   │
│  │          self.assertEqual(category.slug,            │   │
│  │                           'new-category')           │   │
│  │                                                    │   │
│  │      def test_category_get_absolute_url(self):    │   │
│  │          """Test get_absolute_url method."""      │   │
│  │          url = self.category.get_absolute_url()    │   │
│  │          self.assertEqual(url,                     │   │
│  │                           '/category/test-category/')│  │
│  │                                                    │   │
│  │      def test_category_unique_slug(self):         │   │
│  │          """Test that slugs must be unique."""    │   │
│  │          with self.assertRaises(Exception):        │   │
│  │              Category.objects.create(              │   │
│  │                  name='Test Category 2',           │   │
│  │                  slug='test-category'  # Duplicate │   │
│  │              )                                      │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 8.6: Testing Models — Post

**Testing the Post Model**

```
┌─────────────────────────────────────────────────────────────┐
│              TESTING MODELS — POST                          │
│                                                             │
│  Code:                                                      │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  class PostModelTest(BaseTestCase):                 │   │
│  │      """Test the Post model."""                    │   │
│  │                                                    │   │
│  │      def test_post_creation(self):                 │   │
│  │          self.assertEqual(self.published_post.title, │   │
│  │                           'Published Post')          │   │
│  │          self.assertEqual(self.published_post.slug, │   │
│  │                           'published-post')         │   │
│  │          self.assertEqual(self.published_post.author,│   │
│  │                           self.user)               │   │
│  │                                                    │   │
│  │      def test_post_str_method(self):               │   │
│  │          self.assertEqual(str(self.published_post), │   │
│  │                           'Published Post')         │   │
│  │                                                    │   │
│  │      def test_post_get_absolute_url(self):        │   │
│  │          url = self.published_post.get_absolute_url()│  │
│  │          self.assertEqual(url,                     │   │
│  │                           '/blog/published-post/') │   │
│  │                                                    │   │
│  │      def test_post_get_comment_count(self):       │   │
│  │          count = self.published_post.get_comment_count()│  │
│  │          self.assertEqual(count, 1)  # Only approved │   │
│  │                                                    │   │
│  │      def test_post_is_published(self):             │   │
│  │          self.assertTrue(                          │   │
│  │              self.published_post.is_published()    │   │
│  │          )                                          │   │
│  │          self.assertFalse(self.draft_post.is_published())│  │
│  │                                                    │   │
│  │      def test_post_slug_auto_generation(self):    │   │
│  │          post = Post.objects.create(               │   │
│  │              title='My New Post',                  │   │
│  │              content='Content',                    │   │
│  │              author=self.user,                     │   │
│  │              status=Post.Status.DRAFT              │   │
│  │          )                                          │   │
│  │          self.assertEqual(post.slug, 'my-new-post')│   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 8.7: Testing Forms — PostForm

**Testing Form Validation**

```
┌─────────────────────────────────────────────────────────────┐
│              TESTING FORMS — POSTFORM                       │
│                                                             │
│  Code (`blog/tests/test_forms.py`):                        │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  from django.test import TestCase                   │   │
│  │  from blog.forms import PostForm                   │   │
│  │  from blog.tests.test_utils import BaseTestCase    │   │
│  │                                                    │   │
│  │  class PostFormTest(BaseTestCase):                 │   │
│  │      """Test the PostForm."""                     │   │
│  │                                                    │   │
│  │      def test_valid_post_form(self):               │   │
│  │          form_data = {                             │   │
│  │              'title': 'Test Form Post',            │   │
│  │              'content': 'This is content.',        │   │
│  │              'category': self.category.id,         │   │
│  │              'status': 'published',                │   │
│  │              'tags_input': 'test, django'          │   │
│  │          }                                          │   │
│  │          form = PostForm(data=form_data)           │   │
│  │          self.assertTrue(form.is_valid())          │   │
│  │                                                    │   │
│  │      def test_post_form_required_fields(self):    │   │
│  │          form = PostForm(data={})                 │   │
│  │          self.assertFalse(form.is_valid())        │   │
│  │          self.assertIn('title', form.errors)      │   │
│  │          self.assertIn('content', form.errors)    │   │
│  │                                                    │   │
│  │      def test_post_form_slug_auto_generation(self):│   │
│  │          form_data = {                             │   │
│  │              'title': 'Auto Slug Test',            │   │
│  │              'content': 'Content',                 │   │
│  │              'category': self.category.id,         │   │
│  │              'status': 'published'                 │   │
│  │          }                                          │   │
│  │          form = PostForm(data=form_data)           │   │
│  │          self.assertTrue(form.is_valid())          │   │
│  │          cleaned_data = form.clean()               │   │
│  │          self.assertEqual(cleaned_data.get('slug'),│   │
│  │                           'auto-slug-test')        │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 8.8: Testing Views — Public Views

**Testing Public Page Access**

```
┌─────────────────────────────────────────────────────────────┐
│              TESTING VIEWS — PUBLIC                         │
│                                                             │
│  Code (`blog/tests/test_views.py`):                        │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  from django.test import Client                     │   │
│  │  from django.urls import reverse                    │   │
│  │  from blog.tests.test_utils import BaseTestCase    │   │
│  │                                                    │   │
│  │  class PublicViewTest(BaseTestCase):               │   │
│  │      """Test public views."""                     │   │
│  │                                                    │   │
│  │      def setUp(self):                              │   │
│  │          super().setUp()                           │   │
│  │          self.client = Client()                    │   │
│  │                                                    │   │
│  │      def test_home_page_status(self):              │   │
│  │          response = self.client.get(reverse('blog:home'))│  │
│  │          self.assertEqual(response.status_code, 200)│   │
│  │          self.assertTemplateUsed(response,         │   │
│  │              'blog/home.html')                     │   │
│  │                                                    │   │
│  │      def test_home_page_context(self):             │   │
│  │          response = self.client.get(reverse('blog:home'))│  │
│  │          self.assertIn('recent_posts',             │   │
│  │              response.context)                     │   │
│  │          self.assertIn('categories',               │   │
│  │              response.context)                     │   │
│  │                                                    │   │
│  │      def test_blog_list_status(self):              │   │
│  │          response = self.client.get(               │   │
│  │              reverse('blog:blog_list')             │   │
│  │          )                                          │   │
│  │          self.assertEqual(response.status_code, 200)│   │
│  │                                                    │   │
│  │      def test_blog_list_contains_posts(self):     │   │
│  │          response = self.client.get(               │   │
│  │              reverse('blog:blog_list')             │   │
│  │          )                                          │   │
│  │          posts = response.context['posts']         │   │
│  │          self.assertIn(self.published_post, posts) │   │
│  │          self.assertNotIn(self.draft_post, posts)  │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 8.9: Testing Views — Authentication and CRUD

**Testing Login, Registration, and CRUD Operations**

```
┌─────────────────────────────────────────────────────────────┐
│              TESTING VIEWS — AUTH AND CRUD                  │
│                                                             │
│  Code:                                                      │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  class AuthenticationViewTest(BaseTestCase):        │   │
│  │      def test_login_success(self):                 │   │
│  │          response = self.client.post(reverse('login'), │  │
│  │              {'username': 'testuser',               │   │
│  │               'password': 'testpass123'})          │   │
│  │          self.assertRedirects(response,             │   │
│  │              reverse('blog:home'))                 │   │
│  │                                                    │   │
│  │      def test_login_failure(self):                 │   │
│  │          response = self.client.post(reverse('login'), │  │
│  │              {'username': 'testuser',               │   │
│  │               'password': 'wrongpassword'})        │   │
│  │          self.assertEqual(response.status_code, 200)│   │
│  │          self.assertContains(response,             │   │
│  │              'Invalid username or password')       │   │
│  │                                                    │   │
│  │      def test_register_success(self):              │   │
│  │          response = self.client.post(              │   │
│  │              reverse('register'),                  │   │
│  │              {'username': 'newuser123',            │   │
│  │               'email': 'new@example.com',          │   │
│  │               'password1': 'testpass456',          │   │
│  │               'password2': 'testpass456'}          │   │
│  │          )                                          │   │
│  │          self.assertRedirects(response,             │   │
│  │              reverse('blog:home'))                 │   │
│  │          self.assertTrue(User.objects.filter(       │   │
│  │              username='newuser123').exists())      │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  CRUD Tests:                                                │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  class CRUDViewTest(BaseTestCase):                  │   │
│  │      def test_post_create_success(self):           │   │
│  │          self.client.login(username='testuser',    │   │
│  │                          password='testpass123')   │   │
│  │          response = self.client.post(              │   │
│  │              reverse('blog:post_create'),          │   │
│  │              {'title': 'Test Create Post',         │   │
│  │               'content': 'Content...',             │   │
│  │               'category': self.category.id,        │   │
│  │               'status': 'published'}               │   │
│  │          )                                          │   │
│  │          self.assertRedirects(response,            │   │
│  │              reverse('blog:post_detail',           │   │
│  │                      kwargs={'slug': 'test-create-post'}))│  │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 8.10: Common Test Assertions

**Quick Reference of Assertion Methods**

```
┌─────────────────────────────────────────────────────────────┐
│              COMMON TEST ASSERTIONS                         │
│                                                             │
│  Basic Assertions:                                          │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  self.assertEqual(a, b)        # a == b             │   │
│  │  self.assertNotEqual(a, b)     # a != b             │   │
│  │  self.assertTrue(x)            # bool(x) is True    │   │
│  │  self.assertFalse(x)           # bool(x) is False   │   │
│  │  self.assertIs(a, b)           # a is b             │   │
│  │  self.assertIsNot(a, b)        # a is not b         │   │
│  │  self.assertIsNone(x)          # x is None          │   │
│  │  self.assertIsNotNone(x)       # x is not None      │   │
│  │  self.assertIn(a, b)           # a in b             │   │
│  │  self.assertNotIn(a, b)        # a not in b         │   │
│  │  self.assertIsInstance(a, b)   # isinstance(a, b)   │   │
│  │  self.assertRaises(Exc, func)  # func raises Exc    │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Django-Specific Assertions:                                │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  self.assertContains(response, text)               │   │
│  │  self.assertNotContains(response, text)            │   │
│  │  self.assertRedirects(response, url)               │   │
│  │  self.assertTemplateUsed(response, name)           │   │
│  │  self.assertTemplateNotUsed(response, name)        │   │
│  │  self.assertFormError(response, form, field, errors)│  │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Example:                                                   │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  # Test that the response contains 'Welcome'       │   │
│  │  self.assertContains(response, 'Welcome')          │   │
│  │                                                    │   │
│  │  # Test that the response redirects to home       │   │
│  │  self.assertRedirects(response, '/')               │   │
│  │                                                    │   │
│  │  # Test that a specific template was used         │   │
│  │  self.assertTemplateUsed(response, 'blog/home.html')│  │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 8.11: Implementing Logging

**Logging Configuration and Usage**

```
┌─────────────────────────────────────────────────────────────┐
│              IMPLEMENTING LOGGING                           │
│                                                             │
│  Logging Configuration (`config/settings.py`):             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  LOGGING = {                                        │   │
│  │      'version': 1,                                  │   │
│  │      'disable_existing_loggers': False,             │   │
│  │      'formatters': {                                │   │
│  │          'verbose': {                               │   │
│  │              'format': '{levelname} {asctime} {module} {message}',│  │
│  │              'style': '{',                         │   │
│  │          },                                         │   │
│  │          'simple': {                                │   │
│  │              'format': '{levelname} {asctime} {message}',│  │
│  │              'style': '{',                         │   │
│  │          },                                         │   │
│  │      },                                             │   │
│  │      'handlers': {                                  │   │
│  │          'console': {                               │   │
│  │              'level': 'DEBUG',                      │   │
│  │              'class': 'logging.StreamHandler',      │   │
│  │              'formatter': 'simple',                 │   │
│  │          },                                         │   │
│  │          'file': {                                  │   │
│  │              'level': 'INFO',                       │   │
│  │              'class': 'logging.handlers.           │   │
│  │                       RotatingFileHandler',        │   │
│  │              'filename': BASE_DIR / 'logs' /       │   │
│  │                         'django.log',              │   │
│  │              'maxBytes': 1024 * 1024 * 10,        │   │
│  │              'backupCount': 5,                     │   │
│  │              'formatter': 'verbose',                │   │
│  │          },                                         │   │
│  │          'mail_admins': {                           │   │
│  │              'level': 'ERROR',                      │   │
│  │              'class': 'django.utils.log.          │   │
│  │                       AdminEmailHandler',          │   │
│  │              'formatter': 'verbose',                │   │
│  │          },                                         │   │
│  │      },                                             │   │
│  │      'loggers': {                                   │   │
│  │          'django': {                                │   │
│  │              'handlers': ['console', 'file'],       │   │
│  │              'level': 'INFO',                      │   │
│  │          },                                         │   │
│  │          'blog': {                                  │   │
│  │              'handlers': ['console', 'file'],       │   │
│  │              'level': 'DEBUG',                     │   │
│  │          },                                         │   │
│  │      },                                             │   │
│  │  }                                                  │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 8.12: Using Logging in Views

**Adding Logging to Views**

```
┌─────────────────────────────────────────────────────────────┐
│              LOGGING IN VIEWS                               │
│                                                             │
│  Code:                                                      │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  import logging                                     │   │
│  │                                                    │   │
│  │  logger = logging.getLogger(__name__)              │   │
│  │                                                    │   │
│  │  class PostListView(ListView):                     │   │
│  │      # ...                                         │   │
│  │                                                    │   │
│  │      def get_queryset(self):                       │   │
│  │          logger.info(                              │   │
│  │              f"Blog list accessed by user: "       │   │
│  │              f"{self.request.user}"                │   │
│  │          )                                          │   │
│  │          return super().get_queryset()             │   │
│  │                                                    │   │
│  │  class PostDetailView(DetailView):                 │   │
│  │      # ...                                         │   │
│  │                                                    │   │
│  │      def get_context_data(self, **kwargs):        │   │
│  │          context = super().get_context_data(**kwargs)│  │
│  │          logger.info(                              │   │
│  │              f"Post detail accessed: "             │   │
│  │              f"{context['post'].title} by "        │   │
│  │              f"{self.request.user}"                │   │
│  │          )                                          │   │
│  │          return context                            │   │
│  │                                                    │   │
│  │  @login_required                                    │   │
│  │  def post_create(request):                         │   │
│  │      logger.info(                                  │   │
│  │          f"Post creation by user: {request.user}"  │   │
│  │      )                                              │   │
│  │      # ...                                         │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Sample Log Output:                                         │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  INFO 2026-03-15 14:32:10 views.py:123             │   │
│  │  Blog list accessed by user: admin                  │   │
│  │                                                    │   │
│  │  INFO 2026-03-15 14:32:15 views.py:130             │   │
│  │  Post detail accessed: "My Post" by admin          │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 8.13: Adding Debugging Tools — Django Debug Toolbar

**Debugging with Django Debug Toolbar**

```
┌─────────────────────────────────────────────────────────────┐
│              DJANGO DEBUG TOOLBAR                           │
│                                                             │
│  Installation:                                              │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  uv pip install django-debug-toolbar               │   │
│  │  uv pip freeze > requirements.txt                  │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Configuration:                                            │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  # config/settings.py                              │   │
│  │  if DEBUG:                                          │   │
│  │      INSTALLED_APPS += ['debug_toolbar']           │   │
│  │      MIDDLEWARE.insert(                            │   │
│  │          0, 'debug_toolbar.middleware.             │   │
│  │             DebugToolbarMiddleware'                 │   │
│  │      )                                              │   │
│  │                                                    │   │
│  │      INTERNAL_IPS = ['127.0.0.1', 'localhost']     │   │
│  │                                                    │   │
│  │      DEBUG_TOOLBAR_CONFIG = {                      │   │
│  │          'SHOW_TOOLBAR_CALLBACK': lambda request: True,│  │
│  │      }                                              │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  URLs:                                                      │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  # config/urls.py                                  │   │
│  │  if settings.DEBUG:                                │   │
│  │      import debug_toolbar                          │   │
│  │      urlpatterns += [                              │   │
│  │          path('__debug__/', include(debug_toolbar.urls)),│  │
│  │      ]                                              │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Debug Toolbar Features:                                    │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  • SQL query display and timing                     │   │
│  │  • Cache statistics                                 │   │
│  │  • Request/response headers                         │   │
│  │  • Session data                                     │   │
│  │  • Template rendering info                          │   │
│  │  • Logging output                                   │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 8.14: Code Quality — Pre-commit Hooks

**Automated Code Quality Checks**

```
┌─────────────────────────────────────────────────────────────┐
│              PRE-COMMIT HOOKS                               │
│                                                             │
│  Installation:                                              │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  uv pip install pre-commit black flake8 isort      │   │
│  │  uv pip freeze > requirements.txt                  │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  `.pre-commit-config.yaml`:                                │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  repos:                                             │   │
│  │    - repo: https://github.com/psf/black            │   │
│  │      rev: 24.3.0                                   │   │
│  │      hooks:                                         │   │
│  │        - id: black                                  │   │
│  │          language_version: python3.14              │   │
│  │                                                    │   │
│  │    - repo: https://github.com/PyCQA/isort          │   │
│  │      rev: 5.13.2                                   │   │
│  │      hooks:                                         │   │
│  │        - id: isort                                  │   │
│  │          args: ["--profile", "black"]              │   │
│  │                                                    │   │
│  │    - repo: https://github.com/PyCQA/flake8         │   │
│  │      rev: 7.0.0                                    │   │
│  │      hooks:                                         │   │
│  │        - id: flake8                                 │   │
│  │          args: ["--max-line-length=88",            │   │
│  │                 "--extend-ignore=E203,W503"]       │   │
│  │                                                    │   │
│  │    - repo: https://github.com/pre-commit/          │   │
│  │             pre-commit-hooks                       │   │
│  │      rev: v4.5.0                                   │   │
│  │      hooks:                                         │   │
│  │        - id: trailing-whitespace                   │   │
│  │        - id: end-of-file-fixer                    │   │
│  │        - id: check-yaml                            │   │
│  │        - id: check-added-large-files              │   │
│  │        - id: check-merge-conflict                 │   │
│  │        - id: detect-private-key                   │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Install Hooks:                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  pre-commit install                                 │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 8.15: Verification — Running Tests

**Comprehensive Verification Checklist**

```
┌─────────────────────────────────────────────────────────────┐
│              VERIFICATION CHECKLIST                         │
│                                                             │
│  Step 1: Run All Tests                                     │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  python manage.py test blog                         │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Step 2: Run Specific Test Class                          │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  python manage.py test blog.tests.test_models.     │   │
│  │  CategoryModelTest                                  │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Step 3: Run Tests with Verbosity                         │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  python manage.py test blog --verbosity=2          │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Step 4: Run Tests with Coverage                          │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  uv pip install coverage                            │   │
│  │  coverage run manage.py test blog                   │   │
│  │  coverage report                                     │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Expected Output:                                           │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Creating test database for alias 'default'...      │   │
│  │  System check identified no issues (0 silenced).    │   │
│  │  .......................                           │   │
│  │  --------------------------------------------------- │   │
│  │  Ran 23 tests in 1.234s                            │   │
│  │                                                    │   │
│  │  OK                                                │   │
│  │  Destroying test database for alias 'default'...   │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Step 5: Check Logging                                     │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  1. Start server                                    │   │
│  │  2. Visit some pages                               │   │
│  │  3. Check console for log messages                  │   │
│  │  4. Check logs/django.log for file logs            │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 8.16: What You've Learned in Part 8

**Skills Acquired and What You've Built**

```
┌─────────────────────────────────────────────────────────────┐
│              WHAT YOU'VE LEARNED — PART 8                  │
│                                                             │
│  ✅ Skills Acquired:                                        │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  • Writing unit tests for models                   │   │
│  │  • Writing tests for forms                         │   │
│  │  • Writing tests for views                         │   │
│  │  • Implementing logging                            │   │
│  │  • Using debugging tools                           │   │
│  │  • Setting up pre-commit hooks                    │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ✅ What You've Built:                                      │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  • Comprehensive test suite                         │   │
│  │  • Logging configuration                           │   │
│  │  • Debug toolbar setup                             │   │
│  │  • Code quality automation                         │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  🎯 Ready for Part 9:                                       │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  In Part 9, we'll optimize performance and harden   │   │
│  │  security for production!                           │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 8.17: Proceed to Part 9

**Preview of What's Coming**

```
┌─────────────────────────────────────────────────────────────┐
│                COMING UP IN PART 9                          │
│                                                             │
│  ⚡ Performance, Security Hardening, and Production Config  │
│                                                             │
│  What We'll Build:                                          │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  • Optimized ORM queries                            │   │
│  │  • Database indexes for faster queries              │   │
│  │  • Caching to reduce database load                  │   │
│  │  • Security hardening with production settings     │   │
│  │  • Environment variables for sensitive data        │   │
│  │  • PostgreSQL as production database               │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  What We'll Learn:                                          │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  • Query optimization (select_related, etc.)       │   │
│  │  • Database indexes                                │   │
│  │  • Redis/Memcached caching                         │   │
│  │  • Security headers and HTTPS                      │   │
│  │  • Environment variables with python-dotenv        │   │
│  │  • PostgreSQL configuration                        │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Let's prepare for production! ⚡                         │
└─────────────────────────────────────────────────────────────┘
```

---

# PART 9: PERFORMANCE, SECURITY HARDENING, AND PRODUCTION CONFIGURATION

---

## Slide 9.1: Part 9 Introduction

**Learning Objectives**

```
┌─────────────────────────────────────────────────────────────┐
│                    PART 9 OVERVIEW                          │
│                                                             │
│  🎯 Learning Objectives:                                    │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  ✅ Optimize ORM queries for better performance     │   │
│  │  ✅ Add database indexes for faster queries        │   │
│  │  ✅ Implement caching to reduce database load      │   │
│  │  ✅ Harden security with production settings       │   │
│  │  ✅ Configure environment variables                │   │
│  │  ✅ Set up PostgreSQL as production database       │   │
│  │  ✅ Perform a security audit                       │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  🏗️ What We'll Build:                                      │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  • Optimized database queries                       │   │
│  │  • Cache implementation                            │   │
│  │  • Production-ready settings                       │   │
│  │  • Security headers                                │   │
│  │  • Security audit checklist                        │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  📚 Key Concepts:                                          │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  • N+1 query problem and solutions                 │   │
│  │  • Database indexes                                │   │
│  │  • Caching strategies                              │   │
│  │  • Django security best practices                  │   │
│  │  • Environment variables                           │   │
│  │  • PostgreSQL vs SQLite                            │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 9.2: The N+1 Query Problem

**Understanding and Solving the N+1 Problem**

```
┌─────────────────────────────────────────────────────────────┐
│              THE N+1 QUERY PROBLEM                          │
│                                                             │
│  The Problem:                                               │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  # Bad: N+1 queries                                 │   │
│  │  posts = Post.objects.all()                         │   │
│  │  for post in posts:                                 │   │
│  │      print(post.author.username)  # One query per post!│ │
│  │                                                    │   │
│  │  # If you have 100 posts:                          │   │
│  │  # 1 (posts) + 100 (authors) = 101 queries!        │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Visual Representation:                                     │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  ┌─────────────────────────────────────────────────┐│   │
│  │  │  SELECT * FROM blog_post                       ││   │
│  │  └─────────────────────────────────────────────────┘│   │
│  │  ┌─────────────────────────────────────────────────┐│   │
│  │  │  SELECT * FROM auth_user WHERE id = 1          ││   │
│  │  └─────────────────────────────────────────────────┘│   │
│  │  ┌─────────────────────────────────────────────────┐│   │
│  │  │  SELECT * FROM auth_user WHERE id = 2          ││   │
│  │  └─────────────────────────────────────────────────┘│   │
│  │  ┌─────────────────────────────────────────────────┐│   │
│  │  │  SELECT * FROM auth_user WHERE id = 3          ││   │
│  │  └─────────────────────────────────────────────────┘│   │
│  │  ... (N more queries)                              │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  The Solution — select_related:                            │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  # Good: One query with JOIN                        │   │
│  │  posts = Post.objects.select_related('author').all()│   │
│  │  for post in posts:                                 │   │
│  │      print(post.author.username)  # Already loaded!  │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 9.3: ORM Optimization Techniques

**Making Your Queries Efficient**

```
┌─────────────────────────────────────────────────────────────┐
│              ORM OPTIMIZATION TECHNIQUES                    │
│                                                             │
│  1. select_related — Foreign Keys                          │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  # One JOIN for each foreign key                    │   │
│  │  posts = Post.objects.select_related(               │   │
│  │      'author', 'category'                          │   │
│  │  ).all()                                            │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  2. prefetch_related — Many-to-Many                       │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  # Two queries: one for posts, one for tags        │   │
│  │  posts = Post.objects.prefetch_related('tags').all()│   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  3. only() — Load Only Specific Fields                     │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  # Only load title and slug                        │   │
│  │  posts = Post.objects.only('title', 'slug')        │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  4. defer() — Don't Load Unless Needed                    │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  # Don't load content and meta fields               │   │
│  │  posts = Post.objects.defer('content', 'meta_description')│  │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  5. exists() vs count()                                    │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  # Bad: Loads all data                             │   │
│  │  if Post.objects.filter(status='published').count() > 0:│  │
│  │                                                    │   │
│  │  # Good: Just checks existence                     │   │
│  │  if Post.objects.filter(status='published').exists():│   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  6. Aggregations — One Query Instead of Many              │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  from django.db.models import Count, Q              │   │
│  │  stats = Post.objects.aggregate(                    │   │
│  │      total=Count('id'),                             │   │
│  │      published=Count('id', filter=Q(status='published'))│  │
│  │  )                                                  │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 9.4: Optimized Service Layer Queries

**Putting Optimization into Practice**

```
┌─────────────────────────────────────────────────────────────┐
│              OPTIMIZED SERVICE QUERIES                      │
│                                                             │
│  Code (`blog/services/post_service.py`):                   │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  from django.db.models import Prefetch, Q, Count    │   │
│  │                                                    │   │
│  │  class PostService:                                │   │
│  │      @staticmethod                                 │   │
│  │      def get_optimized_posts():                    │   │
│  │          """Get posts with optimized queries."""   │   │
│  │          return Post.objects.filter(               │   │
│  │              status=Post.Status.PUBLISHED,         │   │
│  │              published_at__lte=timezone.now()      │   │
│  │          ).select_related(                         │   │
│  │              'author', 'category'                  │   │
│  │          ).prefetch_related(                       │   │
│  │              'tags',                               │   │
│  │              Prefetch('comments',                  │   │
│  │                  queryset=Comment.objects.filter(  │   │
│  │                      is_approved=True              │   │
│  │                  ).select_related('author')        │   │
│  │              )                                      │   │
│  │          ).only(                                    │   │
│  │              'title', 'slug', 'content', 'excerpt',│   │
│  │              'published_at', 'status',             │   │
│  │              'author__username', 'author__first_name',│  │
│  │              'author__last_name',                  │   │
│  │              'category__name', 'category__slug'    │   │
│  │          ).defer(                                  │   │
│  │              'meta_description', 'meta_keywords'   │   │
│  │          )                                          │   │
│  │                                                    │   │
│  │      @staticmethod                                 │   │
│  │      def get_post_with_comment_count(slug):       │   │
│  │          """Get a post with comment count."""     │   │
│  │          return Post.objects.filter(               │   │
│  │              slug=slug,                            │   │
│  │              status=Post.Status.PUBLISHED          │   │
│  │          ).select_related('author', 'category').annotate(│  │
│  │              comment_count=Count('comments',       │   │
│  │                  filter=Q(comments__is_approved=True))│  │
│  │          ).first()                                 │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 9.5: Database Indexes — Concept and Implementation

**Speeding Up Queries with Indexes**

```
┌─────────────────────────────────────────────────────────────┐
│              DATABASE INDEXES                               │
│                                                             │
│  What Are Indexes?                                          │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Like a book index — helps find data faster         │   │
│  │  Without index: scans every row                    │   │
│  │  With index: jumps directly to matching rows       │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Adding Indexes to Models:                                  │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  class Post(models.Model):                          │   │
│  │      # ... fields ...                              │   │
│  │                                                    │   │
│  │      class Meta:                                    │   │
│  │          indexes = [                                │   │
│  │              # Composite index for common queries  │   │
│  │              models.Index(                          │   │
│  │                  fields=['status', 'published_at'] │   │
│  │              ),                                      │   │
│  │              # Index for filtering by author       │   │
│  │              models.Index(fields=['author']),      │   │
│  │              # Index for slug lookups              │   │
│  │              models.Index(fields=['slug']),        │   │
│  │              # Index for date filtering            │   │
│  │              models.Index(fields=['published_at']),│   │
│  │          ]                                          │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Creating Migrations:                                       │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  python manage.py makemigrations blog              │   │
│  │  python manage.py migrate blog                     │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  When to Use Indexes:                                       │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  ✅ Columns used in WHERE clauses                   │   │
│  │  ✅ Columns used in ORDER BY                       │   │
│  │  ✅ Columns used in JOIN conditions                │   │
│  │  ⚠️ Don't over-index — slows down writes          │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 9.6: Implementing Caching — Configuration

**Reducing Database Load with Caching**

```
┌─────────────────────────────────────────────────────────────┐
│              CACHING CONFIGURATION                          │
│                                                             │
│  What is Caching?                                           │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Store frequently accessed data in memory           │   │
│  │  Reduce database queries                            │   │
│  │  Faster response times                              │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Cache Configuration:                                       │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  # config/settings.py                              │   │
│  │                                                    │   │
│  │  if DEBUG:                                          │   │
│  │      CACHES = {                                    │   │
│  │          'default': {                              │   │
│  │              'BACKEND': 'django.core.cache.backends.│  │
│  │                         locmem.LocMemCache',       │   │
│  │              'LOCATION': 'unique-snowflake',       │   │
│  │              'TIMEOUT': 300,  # 5 minutes          │   │
│  │          }                                          │   │
│  │      }                                              │   │
│  │  else:                                              │   │
│  │      CACHES = {                                    │   │
│  │          'default': {                              │   │
│  │              'BACKEND': 'django.core.cache.backends.│  │
│  │                         redis.RedisCache',         │   │
│  │              'LOCATION': os.environ.get(            │   │
│  │                  'REDIS_URL', 'redis://127.0.0.1:6379/1'),│  │
│  │              'TIMEOUT': 300,                       │   │
│  │              'OPTIONS': {                          │   │
│  │                  'CLIENT_CLASS': 'django_redis.   │   │
│  │                               client.DefaultClient',│  │
│  │                  'PASSWORD': os.environ.get(       │   │
│  │                      'REDIS_PASSWORD', ''),       │   │
│  │              }                                      │   │
│  │          }                                          │   │
│  │      }                                              │   │
│  │                                                    │   │
│  │  # Cache timeouts                                  │   │
│  │  CACHE_TIMEOUT_SHORT = 60   # 1 minute            │   │
│  │  CACHE_TIMEOUT_MEDIUM = 300 # 5 minutes            │   │
│  │  CACHE_TIMEOUT_LONG = 3600  # 1 hour              │   │
│  │  CACHE_TIMEOUT_DAY = 86400  # 24 hours            │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 9.7: Caching in Views

**Using Caches to Speed Up Your Application**

```
┌─────────────────────────────────────────────────────────────┐
│              CACHING IN VIEWS                               │
│                                                             │
│  Caching Querysets:                                         │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  from django.core.cache import cache                │   │
│  │                                                    │   │
│  │  class PostListView(ListView):                     │   │
│  │      def get_queryset(self):                       │   │
│  │          cache_key = f'post_list_{self.request.GET.urlencode()}'│  │
│  │          queryset = cache.get(cache_key)           │   │
│  │                                                    │   │
│  │          if queryset is None:                      │   │
│  │              queryset = super().get_queryset()     │   │
│  │              cache.set(cache_key, queryset, timeout=300)│  │
│  │                                                    │   │
│  │          return queryset                           │   │
│  │                                                    │   │
│  │      def get_context_data(self, **kwargs):        │   │
│  │          context = super().get_context_data(**kwargs)│  │
│  │                                                    │   │
│  │          categories = cache.get('categories_with_counts')│  │
│  │          if categories is None:                   │   │
│  │              categories = Category.objects.annotate(│  │
│  │                  post_count=Count('posts')        │   │
│  │              ).filter(post_count__gt=0)           │   │
│  │              cache.set('categories_with_counts',  │   │
│  │                  categories, timeout=3600)        │   │
│  │                                                    │   │
│  │          context['categories'] = categories        │   │
│  │          return context                            │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Caching Entire Pages:                                      │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  from django.views.decorators.cache import cache_page│  │
│  │                                                    │   │
│  │  @method_decorator(cache_page(300), name='dispatch')│   │
│  │  class HomeView(TemplateView):                     │   │
│  │      # ...                                         │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 9.8: Cache Invalidation via Signals

**Keeping Cache Fresh**

```
┌─────────────────────────────────────────────────────────────┐
│              CACHE INVALIDATION                             │
│                                                             │
│  Why Invalidate Cache?                                      │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Cache becomes stale when data changes              │   │
│  │  Need to clear cache when models are updated        │   │
│  │  Signals make this automatic                       │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Signal Handlers for Cache Invalidation:                   │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  from django.core.cache import cache                │   │
│  │  from django.db.models.signals import post_save, post_delete│  │
│  │                                                    │   │
│  │  @receiver(post_save, sender=Post)                 │   │
│  │  def invalidate_post_cache(sender, instance, **kwargs):│  │
│  │      """Invalidate cache when a post is saved."""  │   │
│  │      cache.delete(f'post_{instance.slug}')         │   │
│  │      cache.delete_pattern('post_list_*')           │   │
│  │      cache.delete('categories_with_counts')        │   │
│  │                                                    │   │
│  │  @receiver(post_delete, sender=Post)               │   │
│  │  def invalidate_post_cache_on_delete(sender, instance, **kwargs):│  │
│  │      """Invalidate cache when a post is deleted."""│   │
│  │      cache.delete(f'post_{instance.slug}')         │   │
│  │      cache.delete_pattern('post_list_*')           │   │
│  │      cache.delete('categories_with_counts')        │   │
│  │                                                    │   │
│  │  @receiver(post_save, sender=Comment)              │   │
│  │  def invalidate_comment_cache(sender, instance, **kwargs):│  │
│  │      """Invalidate cache when a comment is saved."""│  │
│  │      cache.delete(f'post_{instance.post.slug}')    │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 9.9: Production Settings — Environment Variables

**Keeping Secrets Out of Code**

```
┌─────────────────────────────────────────────────────────────┐
│              ENVIRONMENT VARIABLES                          │
│                                                             │
│  Why Environment Variables?                                 │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  ✅ Never hardcode secrets in code                  │   │
│  │  ✅ Different values for different environments     │   │
│  │  ✅ Safe to commit settings files                   │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  `.env` File (NEVER commit this!):                         │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  # Django Settings                                  │   │
│  │  SECRET_KEY=your-super-secret-key-here              │   │
│  │  DEBUG=False                                        │   │
│  │  ALLOWED_HOSTS=yourdomain.com,www.yourdomain.com   │   │
│  │                                                    │   │
│  │  # Database Settings                               │   │
│  │  DB_NAME=django_blog                               │   │
│  │  DB_USER=django_user                               │   │
│  │  DB_PASSWORD=your-strong-database-password         │   │
│  │  DB_HOST=localhost                                 │   │
│  │  DB_PORT=5432                                      │   │
│  │                                                    │   │
│  │  # Email Settings                                  │   │
│  │  EMAIL_HOST=smtp.gmail.com                         │   │
│  │  EMAIL_PORT=587                                    │   │
│  │  EMAIL_USE_TLS=True                                │   │
│  │  EMAIL_HOST_USER=your-email@gmail.com              │   │
│  │  EMAIL_HOST_PASSWORD=your-app-password             │   │
│  │  DEFAULT_FROM_EMAIL=noreply@yourdomain.com         │   │
│  │                                                    │   │
│  │  # Security Settings                               │   │
│  │  SECURE_SSL_REDIRECT=True                          │   │
│  │  SESSION_COOKIE_SECURE=True                        │   │
│  │  CSRF_COOKIE_SECURE=True                           │   │
│  │  SECURE_HSTS_SECONDS=31536000                     │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 9.10: Loading Environment Variables

**Using python-dotenv**

```
┌─────────────────────────────────────────────────────────────┐
│              LOADING ENVIRONMENT VARIABLES                  │
│                                                             │
│  Installation:                                              │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  uv pip install python-dotenv                       │   │
│  │  uv pip freeze > requirements.txt                  │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Settings Configuration:                                    │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  # config/settings.py                              │   │
│  │  import os                                          │   │
│  │  from pathlib import Path                          │   │
│  │  from dotenv import load_dotenv                    │   │
│  │                                                    │   │
│  │  # Load environment variables                      │   │
│  │  load_dotenv()                                     │   │
│  │                                                    │   │
│  │  BASE_DIR = Path(__file__).resolve().parent.parent │   │
│  │                                                    │   │
│  │  # SECURITY WARNING: keep the secret key secret!   │   │
│  │  SECRET_KEY = os.environ.get(                      │   │
│  │      'SECRET_KEY',                                 │   │
│  │      'django-insecure-your-dev-key'                │   │
│  │  )                                                  │   │
│  │                                                    │   │
│  │  # SECURITY WARNING: don't run with debug on!     │   │
│  │  DEBUG = os.environ.get('DEBUG', 'False') == 'True'│   │
│  │                                                    │   │
│  │  ALLOWED_HOSTS = os.environ.get(                   │   │
│  │      'ALLOWED_HOSTS', 'localhost,127.0.0.1'       │   │
│  │  ).split(',')                                      │   │
│  │                                                    │   │
│  │  # Database                                        │   │
│  │  DATABASES = {                                     │   │
│  │      'default': {                                  │   │
│  │          'ENGINE': 'django.db.backends.postgresql',│   │
│  │          'NAME': os.environ.get('DB_NAME',         │   │
│  │                   'django_blog'),                  │   │
│  │          'USER': os.environ.get('DB_USER',         │   │
│  │                   'postgres'),                     │   │
│  │          'PASSWORD': os.environ.get('DB_PASSWORD', │   │
│  │                       ''),                         │   │
│  │          'HOST': os.environ.get('DB_HOST',         │   │
│  │                  'localhost'),                     │   │
│  │          'PORT': os.environ.get('DB_PORT', '5432'),│   │
│  │          'CONN_MAX_AGE': 600,  # Persistent conns  │   │
│  │      }                                              │   │
│  │  }                                                  │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 9.11: Production Security Settings

**Hardening Your Application**

```
┌─────────────────────────────────────────────────────────────┐
│              PRODUCTION SECURITY SETTINGS                   │
│                                                             │
│  Security Settings:                                         │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  # config/settings.py                              │   │
│  │                                                    │   │
│  │  # HTTPS enforcement                               │   │
│  │  SECURE_SSL_REDIRECT = os.environ.get(             │   │
│  │      'SECURE_SSL_REDIRECT', 'False'                │   │
│  │  ) == 'True'                                       │   │
│  │                                                    │   │
│  │  # Secure cookies                                  │   │
│  │  SESSION_COOKIE_SECURE = os.environ.get(           │   │
│  │      'SESSION_COOKIE_SECURE', 'False'              │   │
│  │  ) == 'True'                                       │   │
│  │  CSRF_COOKIE_SECURE = os.environ.get(              │   │
│  │      'CSRF_COOKIE_SECURE', 'False'                 │   │
│  │  ) == 'True'                                       │   │
│  │                                                    │   │
│  │  # Security headers                                │   │
│  │  SECURE_BROWSER_XSS_FILTER = True                  │   │
│  │  SECURE_CONTENT_TYPE_NOSNIFF = True                │   │
│  │  X_FRAME_OPTIONS = 'DENY'                          │   │
│  │                                                    │   │
│  │  # HSTS (HTTP Strict Transport Security)           │   │
│  │  SECURE_HSTS_SECONDS = int(os.environ.get(         │   │
│  │      'SECURE_HSTS_SECONDS', 0                      │   │
│  │  ))                                                │   │
│  │  SECURE_HSTS_INCLUDE_SUBDOMAINS = True             │   │
│  │  SECURE_HSTS_PRELOAD = True                        │   │
│  │                                                    │   │
│  │  # Session settings                                │   │
│  │  SESSION_ENGINE = 'django.contrib.sessions.backends.│   │
│  │                    cached_db'                      │   │
│  │  SESSION_COOKIE_AGE = 86400  # 24 hours           │   │
│  │  SESSION_COOKIE_HTTPONLY = True                    │   │
│  │  SESSION_COOKIE_SAMESITE = 'Lax'                  │   │
│  │                                                    │   │
│  │  # CSRF trusted origins                            │   │
│  │  CSRF_TRUSTED_ORIGINS = os.environ.get(            │   │
│  │      'CSRF_TRUSTED_ORIGINS', ''                   │   │
│  │  ).split(',')                                      │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 9.12: Security Audit Checklist

**Comprehensive Security Review**

```
┌─────────────────────────────────────────────────────────────┐
│              SECURITY AUDIT CHECKLIST                       │
│                                                             │
│  Authentication & Authorization:                            │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  ✅ Users can only edit/delete their own posts      │   │
│  │  ✅ Superusers have full access                     │   │
│  │  ✅ Password reset implemented                      │   │
│  │  ✅ Login attempts are limited                      │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Data Protection:                                           │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  ✅ CSRF protection enabled                         │   │
│  │  ✅ SQL injection prevention (ORM)                  │   │
│  │  ✅ XSS protection (auto-escaping)                  │   │
│  │  ✅ Clickjacking protection                         │   │
│  │  ✅ File upload validation                          │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Configuration:                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  ✅ DEBUG=False in production                       │   │
│  │  ✅ Secret key in environment variables             │   │
│  │  ✅ Allowed hosts configured                        │   │
│  │  ✅ HTTPS enforced                                 │   │
│  │  ✅ Secure cookies configured                       │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Monitoring:                                                │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  ✅ Logging configured                              │   │
│  │  ✅ Error emails sent to admins                    │   │
│  │  ✅ Security headers added                         │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ⚠️ Review Regularly:                                      │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  • Check for outdated packages                      │   │
│  │  • Review security advisories                       │   │
│  │  • Update Django regularly                          │   │
│  │  • Review user permissions                          │   │
│  │  • Audit admin access                               │   │
│  │  • Database backups configured                      │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 9.13: Switching to PostgreSQL

**Production Database Migration**

```
┌─────────────────────────────────────────────────────────────┐
│              SWITCHING TO POSTGRESQL                        │
│                                                             │
│  Why PostgreSQL?                                            │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  ✅ Production-ready and robust                     │   │
│  │  ✅ Full-text search support                        │   │
│  │  ✅ Better performance at scale                    │   │
│  │  ✅ ACID compliance                                │   │
│  │  ✅ Advanced data types (JSON, arrays, etc.)       │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Step 1: Install PostgreSQL                                │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  # macOS                                            │   │
│  │  brew install postgresql                            │   │
│  │  # Ubuntu/Debian                                    │   │
│  │  sudo apt install postgresql postgresql-contrib    │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Step 2: Create Database and User                         │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  sudo -u postgres psql                             │   │
│  │                                                    │   │
│  │  CREATE DATABASE django_blog;                      │   │
│  │  CREATE USER django_user WITH PASSWORD 'secure';   │   │
│  │  GRANT ALL PRIVILEGES ON DATABASE django_blog      │   │
│  │  TO django_user;                                   │   │
│  │  \q                                                 │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Step 3: Migrate Data                                      │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  # Dump data from SQLite                           │   │
│  │  python manage.py dumpdata > data_dump.json        │   │
│  │                                                    │   │
│  │  # Switch to PostgreSQL in settings               │   │
│  │  # Load data into PostgreSQL                      │   │
│  │  python manage.py loaddata data_dump.json         │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 9.14: Verification — Testing Production Readiness

**Comprehensive Verification Checklist**

```
┌─────────────────────────────────────────────────────────────┐
│              VERIFICATION CHECKLIST                         │
│                                                             │
│  Step 1: Check Query Performance                           │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  1. python manage.py shell                          │   │
│  │  2. from blog.services.post_service import PostService│  │
│  │  3. from django.db import connection                │   │
│  │  4. connection.queries_log.clear()                  │   │
│  │  5. posts = PostService.get_optimized_posts()      │   │
│  │  6. print(f"Queries: {len(connection.queries)}")   │   │
│  │  7. Should be 1-2 queries, not N+1                 │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Step 2: Test Caching                                      │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  1. python manage.py shell                          │   │
│  │  2. from django.core.cache import cache             │   │
│  │  3. cache.set('test_key', 'test_value', timeout=60)│   │
│  │  4. value = cache.get('test_key')                  │   │
│  │  5. print(f"Cache value: {value}")                 │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Step 3: Test Production Settings                         │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  1. export DEBUG=False                              │   │
│  │  2. python manage.py runserver                      │   │
│  │  3. Visit site — should NOT see debug pages        │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Step 4: Security Headers Check                           │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  curl -I http://127.0.0.1:8000/                    │   │
│  │  Should return:                                     │   │
│  │  X-Content-Type-Options: nosniff                    │   │
│  │  X-Frame-Options: DENY                              │   │
│  │  X-XSS-Protection: 1; mode=block                   │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 9.15: What You've Learned in Part 9

**Skills Acquired and What You've Built**

```
┌─────────────────────────────────────────────────────────────┐
│              WHAT YOU'VE LEARNED — PART 9                  │
│                                                             │
│  ✅ Skills Acquired:                                        │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  • Optimizing ORM queries                           │   │
│  │  • Creating database indexes                        │   │
│  │  • Implementing caching                             │   │
│  │  • Using environment variables                      │   │
│  │  • Configuring production settings                  │   │
│  │  • Hardening security                               │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ✅ What You've Built:                                      │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  • Optimized database queries                       │   │
│  │  • Cache implementation                             │   │
│  │  • Production-ready settings                        │   │
│  │  • Security headers                                 │   │
│  │  • Security audit checklist                        │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  🎯 Ready for Part 10:                                      │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  In Part 10, we'll containerize and deploy our      │   │
│  │  application with Docker, Gunicorn, and Nginx!     │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 9.16: Quick Reference — Query Optimization

**Optimization Techniques Summary**

```
┌─────────────────────────────────────────────────────────────┐
│              QUERY OPTIMIZATION — REFERENCE                 │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Problem           │  Solution                      │   │
│  │  ──────────────────────────────────────────────────  │   │
│  │  N+1 queries       │  select_related()             │   │
│  │  (Foreign Keys)    │                                │   │
│  │  N+1 queries       │  prefetch_related()           │   │
│  │  (Many-to-Many)    │                                │   │
│  │  Loading too much  │  only() / defer()             │   │
│  │  data               │                                │   │
│  │  Counting in loops  │  count() / exists()           │   │
│  │  Multiple counts    │  aggregate() with Count       │   │
│  │  Slow queries       │  Database indexes             │   │
│  │  Repeated queries   │  Caching                      │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Index Creation:                                            │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  class Meta:                                        │   │
│  │      indexes = [                                    │   │
│  │          models.Index(fields=['status', 'published_at']),│  │
│  │          models.Index(fields=['slug']),            │   │
│  │      ]                                              │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Cache Patterns:                                            │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  # Set a value                                     │   │
│  │  cache.set('key', value, timeout=300)              │   │
│  │                                                    │   │
│  │  # Get a value (with default)                      │   │
│  │  value = cache.get('key', 'default')               │   │
│  │                                                    │   │
│  │  # Delete a value                                  │   │
│  │  cache.delete('key')                               │   │
│  │                                                    │   │
│  │  # Delete pattern                                  │   │
│  │  cache.delete_pattern('post_*')                   │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 9.17: Proceed to Part 10

**Preview of What's Coming**

```
┌─────────────────────────────────────────────────────────────┐
│                COMING UP IN PART 10                         │
│                                                             │
│  🐳 Docker, Gunicorn, Nginx, CI/CD, and Production Deploy  │
│                                                             │
│  What We'll Build:                                          │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  • Docker containerization                         │   │
│  │  • Gunicorn application server                     │   │
│  │  • Nginx reverse proxy                             │   │
│  │  • Docker Compose orchestration                    │   │
│  │  • CI/CD pipeline                                  │   │
│  │  • Production deployment                           │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  What We'll Learn:                                          │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  • Dockerfiles and Docker Compose                  │   │
│  │  • Gunicorn configuration                           │   │
│  │  • Nginx configuration                              │   │
│  │  • CI/CD with GitHub Actions                       │   │
│  │  • Deployment strategies                           │   │
│  │  • Health checks and monitoring                    │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Preview of Architecture:                                   │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  ┌─────────────────────────────────────────────────┐│   │
│  │  │  Browser ──► Nginx ──► Gunicorn ──► Django    ││   │
│  │  │              (Web)    (App)     (Code)          ││   │
│  │  └─────────────────────────────────────────────────┘│   │
│  │  ┌─────────────────────────────────────────────────┐│   │
│  │  │  PostgreSQL (Database) │ Redis (Cache)         ││   │
│  │  └─────────────────────────────────────────────────┘│   │
│  │  ┌─────────────────────────────────────────────────┐│   │
│  │  │  Docker Compose orchestrates all containers    ││   │
│  │  └─────────────────────────────────────────────────┘│   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Let's deploy! 🐳                                         │
└─────────────────────────────────────────────────────────────┘
```

---

# PART 10: DOCKER, GUNICORN, NGINX, CI/CD, AND PRODUCTION DEPLOYMENT

---

## Slide 10.1: Part 10 Introduction

**Learning Objectives**

```
┌─────────────────────────────────────────────────────────────┐
│                    PART 10 OVERVIEW                         │
│                                                             │
│  🎯 Learning Objectives:                                    │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  ✅ Containerize your application with Docker      │   │
│  │  ✅ Configure Gunicorn as the application server   │   │
│  │  ✅ Set up Nginx as a reverse proxy                │   │
│  │  ✅ Use Docker Compose for orchestration           │   │
│  │  ✅ Implement a CI/CD pipeline                     │   │
│  │  ✅ Deploy to a production server                  │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  🏗️ What We'll Build:                                      │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  • Production Dockerfile                            │   │
│  │  • Gunicorn configuration                           │   │
│  │  • Nginx configuration                              │   │
│  │  • Docker Compose setup                             │   │
│  │  • CI/CD pipeline                                   │   │
│  │  • Deployment scripts                               │   │
│  │  • Health check endpoint                            │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  📚 Key Concepts:                                          │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  • Docker images and containers                    │   │
│  │  • WSGI vs ASGI                                    │   │
│  │  • Reverse proxies                                  │   │
│  │  • Container orchestration                         │   │
│  │  • CI/CD pipelines                                 │   │
│  │  • Continuous deployment                           │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 10.2: Understanding Docker

**Docker Fundamentals**

```
┌─────────────────────────────────────────────────────────────┐
│                    UNDERSTANDING DOCKER                     │
│                                                             │
│  What is Docker?                                            │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Packages your application and all dependencies     │   │
│  │  into a container                                   │   │
│  │  Runs the same everywhere (dev, test, production)   │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Docker Container:                                          │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  ┌─────────────────────────────────────────────────┐│   │
│  │  │            Docker Container                     ││   │
│  │  │  ┌───────────────────────────────────────────┐  ││   │
│  │  │  │         Application Code                  │  ││   │
│  │  │  ├───────────────────────────────────────────┤  ││   │
│  │  │  │      Python + Dependencies                │  ││   │
│  │  │  ├───────────────────────────────────────────┤  ││   │
│  │  │  │    Operating System (Linux)               │  ││   │
│  │  │  └───────────────────────────────────────────┘  ││   │
│  │  └─────────────────────────────────────────────────┘│   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Key Concepts:                                              │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Concept           │  Analogy                       │   │
│  │  ──────────────────────────────────────────────────  │   │
│  │  Image             │  Blueprint for a house         │   │
│  │  Container         │  A house built from blueprint  │   │
│  │  Dockerfile        │  Building instructions         │   │
│  │  Volume            │  Storage unit attached to house│   │
│  │  Network           │  Roads connecting houses       │   │
│  │  Compose           │  Neighborhood with multiple    │   │
│  │                    │  houses                        │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 10.3: Creating a Dockerfile

**Building the Application Image**

```
┌─────────────────────────────────────────────────────────────┐
│                    CREATING A DOCKERFILE                    │
│                                                             │
│  Dockerfile:                                                │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  # Use Python 3.14 slim image as base              │   │
│  │  FROM python:3.14-slim-bookworm                    │   │
│  │                                                    │   │
│  │  # Set environment variables                       │   │
│  │  ENV PYTHONDONTWRITEBYTECODE=1 \                   │   │
│  │      PYTHONUNBUFFERED=1 \                          │   │
│  │      DJANGO_SETTINGS_MODULE=config.settings        │   │
│  │                                                    │   │
│  │  # Set work directory                              │   │
│  │  WORKDIR /app                                      │   │
│  │                                                    │   │
│  │  # Install system dependencies                     │   │
│  │  RUN apt-get update && apt-get install -y \       │   │
│  │      libpq-dev \                                   │   │
│  │      libjpeg-dev \                                 │   │
│  │      libpng-dev \                                  │   │
│  │      libwebp-dev \                                 │   │
│  │      curl \                                        │   │
│  │      build-essential \                            │   │
│  │      && rm -rf /var/lib/apt/lists/*               │   │
│  │                                                    │   │
│  │  # Install Python dependencies                     │   │
│  │  COPY requirements.txt .                          │   │
│  │  RUN pip install --no-cache-dir -r requirements.txt \│  │
│  │      && pip install --no-cache-dir gunicorn==21.2.0│   │
│  │                                                    │   │
│  │  # Copy project files                              │   │
│  │  COPY . .                                          │   │
│  │                                                    │   │
│  │  # Collect static files                            │   │
│  │  RUN python manage.py collectstatic --noinput      │   │
│  │                                                    │   │
│  │  # Create non-root user                            │   │
│  │  RUN addgroup --system django \                   │   │
│  │      && adduser --system --group django \          │   │
│  │      && chown -R django:django /app               │   │
│  │                                                    │   │
│  │  USER django                                       │   │
│  │                                                    │   │
│  │  EXPOSE 8000                                       │   │
│  │                                                    │   │
│  │  CMD ["gunicorn", "--config", "gunicorn.conf.py",  │   │
│  │       "config.wsgi:application"]                   │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 10.4: Gunicorn Configuration

**Configuring the Application Server**

```
┌─────────────────────────────────────────────────────────────┐
│                    GUNICORN CONFIGURATION                   │
│                                                             │
│  `gunicorn.conf.py`:                                        │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  import os                                          │   │
│  │  import multiprocessing                             │   │
│  │                                                    │   │
│  │  # Server socket                                   │   │
│  │  bind = "0.0.0.0:8000"                            │   │
│  │  backlog = 2048                                    │   │
│  │                                                    │   │
│  │  # Worker processes (CPU cores * 2 + 1)           │   │
│  │  workers = multiprocessing.cpu_count() * 2 + 1    │   │
│  │  worker_class = "sync"                            │   │
│  │  worker_connections = 1000                        │   │
│  │  timeout = 30                                      │   │
│  │  keepalive = 2                                     │   │
│  │                                                    │   │
│  │  # Logging                                         │   │
│  │  accesslog = "/app/logs/gunicorn-access.log"       │   │
│  │  errorlog = "/app/logs/gunicorn-error.log"        │   │
│  │  loglevel = "info"                                │   │
│  │                                                    │   │
│  │  # Process naming                                  │   │
│  │  proc_name = "django_blog"                        │   │
│  │                                                    │   │
│  │  # Server mechanics                                │   │
│  │  daemon = False                                    │   │
│  │  pidfile = None                                    │   │
│  │  umask = 0                                         │   │
│  │  user = None                                       │   │
│  │  group = None                                      │   │
│  │                                                    │   │
│  │  # Environment                                     │   │
│  │  raw_env = [                                       │   │
│  │      f"DJANGO_SETTINGS_MODULE={os.environ.get(    │   │
│  │          'DJANGO_SETTINGS_MODULE',                │   │
│  │          'config.settings'                        │   │
│  │      )}",                                          │   │
│  │  ]                                                 │   │
│  │                                                    │   │
│  │  # Preload application code                        │   │
│  │  preload_app = True                                │   │
│  │                                                    │   │
│  │  # Worker timeout                                  │   │
│  │  graceful_timeout = 30                            │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 10.5: Docker Compose — Orchestration

**Running Multiple Containers Together**

```
┌─────────────────────────────────────────────────────────────┐
│                    DOCKER COMPOSE                           │
│                                                             │
│  `docker-compose.yml`:                                      │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  version: '3.8'                                    │   │
│  │                                                    │   │
│  │  services:                                          │   │
│  │    db:                                              │   │
│  │      image: postgres:16-alpine                     │   │
│  │      container_name: django_blog_db                │   │
│  │      restart: always                               │   │
│  │      volumes:                                      │   │
│  │        - postgres_data:/var/lib/postgresql/data   │   │
│  │      environment:                                  │   │
│  │        POSTGRES_DB: ${DB_NAME}                     │   │
│  │        POSTGRES_USER: ${DB_USER}                   │   │
│  │        POSTGRES_PASSWORD: ${DB_PASSWORD}           │   │
│  │      networks:                                     │   │
│  │        - django_network                            │   │
│  │                                                    │   │
│  │    redis:                                          │   │
│  │      image: redis:7-alpine                         │   │
│  │      container_name: django_blog_redis             │   │
│  │      restart: always                               │   │
│  │      volumes:                                      │   │
│  │        - redis_data:/data                          │   │
│  │      networks:                                     │   │
│  │        - django_network                            │   │
│  │                                                    │   │
│  │    web:                                             │   │
│  │      build: .                                      │   │
│  │      container_name: django_blog_web               │   │
│  │      restart: always                               │   │
│  │      command: gunicorn --config gunicorn.conf.py   │   │
│  │                config.wsgi:application              │   │
│  │      volumes:                                      │   │
│  │        - ./media:/app/media                        │   │
│  │        - ./staticfiles:/app/staticfiles            │   │
│  │        - ./logs:/app/logs                          │   │
│  │      environment:                                  │   │
│  │        - DEBUG=${DEBUG}                            │   │
│  │        - SECRET_KEY=${SECRET_KEY}                  │   │
│  │        - DB_NAME=${DB_NAME}                        │   │
│  │        - DB_USER=${DB_USER}                        │   │
│  │        - DB_PASSWORD=${DB_PASSWORD}                │   │
│  │        - DB_HOST=db                                │   │
│  │        - DB_PORT=5432                              │   │
│  │      depends_on:                                   │   │
│  │        db:                                         │   │
│  │          condition: service_healthy                │   │
│  │      networks:                                     │   │
│  │        - django_network                            │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 10.6: Nginx Configuration — Web Server

**Nginx as Reverse Proxy and Static File Server**

```
┌─────────────────────────────────────────────────────────────┐
│                    NGINX CONFIGURATION                      │
│                                                             │
│  `nginx/nginx.conf`:                                        │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  user nginx;                                        │   │
│  │  worker_processes auto;                             │   │
│  │  error_log /var/log/nginx/error.log warn;          │   │
│  │  pid /var/run/nginx.pid;                           │   │
│  │                                                    │   │
│  │  events {                                           │   │
│  │      worker_connections 1024;                      │   │
│  │  }                                                  │   │
│  │                                                    │   │
│  │  http {                                             │   │
│  │      include /etc/nginx/mime.types;                │   │
│  │      default_type application/octet-stream;        │   │
│  │                                                    │   │
│  │      # Logging                                     │   │
│  │      log_format main '$remote_addr - $remote_user  │   │
│  │          [$time_local] "$request"                  │   │
│  │          $status $body_bytes_sent "$http_referer"  │   │
│  │          "$http_user_agent" "$http_x_forwarded_for"│   │
│  │      access_log /var/log/nginx/access.log main;    │   │
│  │                                                    │   │
│  │      # Security                                    │   │
│  │      sendfile on;                                  │   │
│  │      tcp_nopush on;                                │   │
│  │      tcp_nodelay on;                               │   │
│  │      keepalive_timeout 65;                         │   │
│  │      client_max_body_size 10M;                    │   │
│  │      server_tokens off;                           │   │
│  │                                                    │   │
│  │      # Gzip compression                            │   │
│  │      gzip on;                                      │   │
│  │      gzip_vary on;                                 │   │
│  │      gzip_proxied any;                            │   │
│  │      gzip_comp_level 6;                           │   │
│  │      gzip_types text/plain text/css text/xml       │   │
│  │          application/json application/javascript   │   │
│  │          application/xml+rss application/rss+xml   │   │
│  │          application/atom+xml image/svg+xml;      │   │
│  │                                                    │   │
│  │      # Security headers                            │   │
│  │      add_header X-Content-Type-Options "nosniff"   │   │
│  │          always;                                   │   │
│  │      add_header X-Frame-Options "DENY" always;     │   │
│  │      add_header X-XSS-Protection "1; mode=block"   │   │
│  │          always;                                   │   │
│  │                                                    │   │
│  │      include /etc/nginx/conf.d/*.conf;            │   │
│  │  }                                                  │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 10.7: Nginx — Django Application Configuration

**Proxy and Static File Configuration**

```
┌─────────────────────────────────────────────────────────────┐
│              NGINX — DJANGO APP CONFIG                      │
│                                                             │
│  `nginx/conf.d/django.conf`:                               │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  # Upstream for Django application                  │   │
│  │  upstream django_app {                              │   │
│  │      server web:8000;                               │   │
│  │  }                                                  │   │
│  │                                                    │   │
│  │  server {                                           │   │
│  │      listen 80;                                     │   │
│  │      server_name localhost yourdomain.com           │   │
│  │                   www.yourdomain.com;               │   │
│  │                                                    │   │
│  │      # Redirect to HTTPS (uncomment when SSL ready)│   │
│  │      # return 301 https://$server_name$request_uri;│   │
│  │                                                    │   │
│  │      # Static files                                │   │
│  │      location /static/ {                           │   │
│  │          alias /app/staticfiles/;                  │   │
│  │          expires 30d;                              │   │
│  │          add_header Cache-Control "public, immutable";│  │
│  │      }                                              │   │
│  │                                                    │   │
│  │      # Media files                                 │   │
│  │      location /media/ {                            │   │
│  │          alias /app/media/;                        │   │
│  │          expires 30d;                              │   │
│  │          add_header Cache-Control "public, immutable";│  │
│  │      }                                              │   │
│  │                                                    │   │
│  │      # Django application                          │   │
│  │      location / {                                  │   │
│  │          proxy_pass http://django_app;             │   │
│  │          proxy_set_header Host $host;              │   │
│  │          proxy_set_header X-Real-IP $remote_addr;  │   │
│  │          proxy_set_header X-Forwarded-For          │   │
│  │              $proxy_add_x_forwarded_for;           │   │
│  │          proxy_set_header X-Forwarded-Proto $scheme;│  │
│  │          proxy_redirect off;                       │   │
│  │                                                    │   │
│  │          # Timeouts                                │   │
│  │          proxy_connect_timeout 60s;                │   │
│  │          proxy_send_timeout 60s;                   │   │
│  │          proxy_read_timeout 60s;                   │   │
│  │          proxy_buffering off;                      │   │
│  │      }                                              │   │
│  │  }                                                  │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 10.8: Entrypoint Script

**Container Startup Logic**

```
┌─────────────────────────────────────────────────────────────┐
│                    ENTRYPOINT SCRIPT                        │
│                                                             │
│  `scripts/entrypoint.sh`:                                   │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  #!/bin/bash                                        │   │
│  │  set -e                                             │   │
│  │                                                    │   │
│  │  echo "Starting entrypoint script..."              │   │
│  │                                                    │   │
│  │  # Wait for database to be ready                   │   │
│  │  echo "Waiting for database..."                    │   │
│  │  while ! nc -z db 5432; do                         │   │
│  │      sleep 1                                       │   │
│  │  done                                              │   │
│  │  echo "Database is ready!"                         │   │
│  │                                                    │   │
│  │  # Run migrations                                   │   │
│  │  echo "Running database migrations..."             │   │
│  │  python manage.py migrate --noinput                │   │
│  │                                                    │   │
│  │  # Create superuser if needed                      │   │
│  │  echo "Creating superuser if needed..."            │   │
│  │  python manage.py shell -c "                       │   │
│  │  from django.contrib.auth.models import User;      │   │
│  │  if not User.objects.filter(username='admin').exists():│  │
│  │      User.objects.create_superuser('admin',        │   │
│  │          'admin@example.com', '${ADMIN_PASSWORD:-admin123}');│  │
│  │      print('Superuser created.');                 │   │
│  │  else:                                             │   │
│  │      print('Superuser already exists.');           │   │
│  │  "                                                  │   │
│  │                                                    │   │
│  │  # Collect static files                            │   │
│  │  echo "Collecting static files..."                 │   │
│  │  python manage.py collectstatic --noinput          │   │
│  │                                                    │   │
│  │  echo "Starting Gunicorn..."                       │   │
│  │  exec "$@"                                         │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Update Dockerfile:                                         │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  COPY scripts/entrypoint.sh /entrypoint.sh         │   │
│  │  RUN chmod +x /entrypoint.sh                       │   │
│  │  ENTRYPOINT ["/entrypoint.sh"]                     │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 10.9: Production Environment Variables

**Secrets and Configuration**

```
┌─────────────────────────────────────────────────────────────┐
│              PRODUCTION ENVIRONMENT VARIABLES               │
│                                                             │
│  `.env.production` (NEVER commit this!):                   │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  # Django Settings                                  │   │
│  │  SECRET_KEY=your-production-secret-key-here         │   │
│  │  DEBUG=False                                        │   │
│  │  ALLOWED_HOSTS=yourdomain.com,www.yourdomain.com   │   │
│  │                                                    │   │
│  │  # Database Settings                               │   │
│  │  DB_NAME=django_blog                               │   │
│  │  DB_USER=django_user                               │   │
│  │  DB_PASSWORD=your-strong-database-password         │   │
│  │  DB_HOST=db                                        │   │
│  │  DB_PORT=5432                                      │   │
│  │                                                    │   │
│  │  # Email Settings                                  │   │
│  │  EMAIL_HOST=smtp.gmail.com                         │   │
│  │  EMAIL_PORT=587                                    │   │
│  │  EMAIL_USE_TLS=True                                │   │
│  │  EMAIL_HOST_USER=your-email@gmail.com              │   │
│  │  EMAIL_HOST_PASSWORD=your-app-password             │   │
│  │  DEFAULT_FROM_EMAIL=noreply@yourdomain.com         │   │
│  │                                                    │   │
│  │  # Security Settings                               │   │
│  │  SECURE_SSL_REDIRECT=True                          │   │
│  │  SESSION_COOKIE_SECURE=True                        │   │
│  │  CSRF_COOKIE_SECURE=True                           │   │
│  │  SECURE_HSTS_SECONDS=31536000                     │   │
│  │                                                    │   │
│  │  # Redis Settings                                  │   │
│  │  REDIS_URL=redis://redis:6379/1                   │   │
│  │                                                    │   │
│  │  # Site Settings                                   │   │
│  │  SITE_URL=https://yourdomain.com                  │   │
│  │                                                    │   │
│  │  # Admin User (for automatic creation)            │   │
│  │  ADMIN_PASSWORD=your-admin-password               │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  `.env.example` (Commit this!):                            │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  # Copy this to .env.production and fill in values │   │
│  │  SECRET_KEY=your-secret-key-here                   │   │
│  │  DEBUG=False                                       │   │
│  │  ALLOWED_HOSTS=localhost,127.0.0.1                │   │
│  │  DB_NAME=django_blog                               │   │
│  │  DB_USER=django_user                               │   │
│  │  DB_PASSWORD=change-this                           │   │
│  │  SITE_URL=http://localhost:8000                   │   │
│  │  ADMIN_PASSWORD=admin123                          │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 10.10: Production Docker Compose

**Production-Specific Configuration**

```
┌─────────────────────────────────────────────────────────────┐
│              PRODUCTION DOCKER COMPOSE                      │
│                                                             │
│  `docker-compose.prod.yml`:                                 │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  version: '3.8'                                    │   │
│  │                                                    │   │
│  │  services:                                          │   │
│  │    db:                                              │   │
│  │      image: postgres:16-alpine                     │   │
│  │      container_name: django_blog_db                │   │
│  │      restart: always                               │   │
│  │      volumes:                                      │   │
│  │        - postgres_data:/var/lib/postgresql/data   │   │
│  │      environment:                                  │   │
│  │        POSTGRES_DB: ${DB_NAME}                     │   │
│  │        POSTGRES_USER: ${DB_USER}                   │   │
│  │        POSTGRES_PASSWORD: ${DB_PASSWORD}           │   │
│  │      healthcheck:                                  │   │
│  │        test: ["CMD-SHELL", "pg_isready -U ${DB_USER}"]│  │
│  │        interval: 10s                               │   │
│  │        timeout: 5s                                 │   │
│  │        retries: 5                                  │   │
│  │      networks:                                     │   │
│  │        - django_network                            │   │
│  │                                                    │   │
│  │    redis:                                          │   │
│  │      image: redis:7-alpine                         │   │
│  │      container_name: django_blog_redis             │   │
│  │      restart: always                               │   │
│  │      volumes:                                      │   │
│  │        - redis_data:/data                          │   │
│  │      networks:                                     │   │
│  │        - django_network                            │   │
│  │      healthcheck:                                  │   │
│  │        test: ["CMD", "redis-cli", "ping"]          │   │
│  │        interval: 10s                               │   │
│  │        timeout: 5s                                 │   │
│  │        retries: 5                                  │   │
│  │                                                    │   │
│  │    web:                                             │   │
│  │      build: .                                      │   │
│  │      container_name: django_blog_web               │   │
│  │      restart: always                               │   │
│  │      volumes:                                      │   │
│  │        - ./media:/app/media                        │   │
│  │        - ./staticfiles:/app/staticfiles            │   │
│  │        - ./logs:/app/logs                          │   │
│  │      env_file:                                     │   │
│  │        - .env.production                           │   │
│  │      environment:                                  │   │
│  │        - DB_HOST=db                                │   │
│  │        - REDIS_URL=redis://redis:6379/1           │   │
│  │      depends_on:                                   │   │
│  │        db:                                         │   │
│  │          condition: service_healthy                │   │
│  │        redis:                                      │   │
│  │          condition: service_healthy                │   │
│  │      networks:                                     │   │
│  │        - django_network                            │   │
│  │                                                    │   │
│  │    nginx:                                          │   │
│  │      image: nginx:alpine                           │   │
│  │      container_name: django_blog_nginx             │   │
│  │      restart: always                               │   │
│  │      ports:                                        │   │
│  │        - "80:80"                                   │   │
│  │        - "443:443"                                 │   │
│  │      volumes:                                      │   │
│  │        - ./nginx/nginx.prod.conf:/etc/nginx/nginx.conf:ro│  │
│  │        - ./nginx/conf.d:/etc/nginx/conf.d:ro      │   │
│  │        - ./staticfiles:/app/staticfiles:ro        │   │
│  │        - ./media:/app/media:ro                    │   │
│  │        - ./ssl:/etc/ssl:ro                        │   │
│  │      depends_on:                                   │   │
│  │        - web                                       │   │
│  │      networks:                                     │   │
│  │        - django_network                            │   │
│  │                                                    │   │
│  │  volumes:                                          │   │
│  │    postgres_data:                                  │   │
│  │    redis_data:                                     │   │
│  │                                                    │   │
│  │  networks:                                         │   │
│  │    django_network:                                 │   │
│  │      driver: bridge                                │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 10.11: CI/CD Pipeline — GitHub Actions

**Automated Testing and Deployment**

```
┌─────────────────────────────────────────────────────────────┐
│                    CI/CD PIPELINE                           │
│                                                             │
│  `.github/workflows/deploy.yml`:                           │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  name: Deploy to Production                         │   │
│  │                                                    │   │
│  │  on:                                               │   │
│  │    push:                                            │   │
│  │      branches: [ main ]                            │   │
│  │    pull_request:                                    │   │
│  │      branches: [ main ]                            │   │
│  │                                                    │   │
│  │  jobs:                                              │   │
│  │    test:                                            │   │
│  │      runs-on: ubuntu-latest                        │   │
│  │                                                    │   │
│  │      services:                                      │   │
│  │        postgres:                                    │   │
│  │          image: postgres:16-alpine                 │   │
│  │          env:                                       │   │
│  │            POSTGRES_USER: django_user              │   │
│  │            POSTGRES_PASSWORD: test_password        │   │
│  │            POSTGRES_DB: django_blog                │   │
│  │          ports:                                    │   │
│  │            - 5432:5432                             │   │
│  │          options: >-                               │   │
│  │            --health-cmd pg_isready                 │   │
│  │            --health-interval 10s                   │   │
│  │            --health-timeout 5s                     │   │
│  │            --health-retries 5                      │   │
│  │                                                    │   │
│  │      steps:                                         │   │
│  │      - uses: actions/checkout@v4                   │   │
│  │                                                    │   │
│  │      - name: Set up Python                         │   │
│  │        uses: actions/setup-python@v5               │   │
│  │        with:                                       │   │
│  │          python-version: '3.14'                    │   │
│  │                                                    │   │
│  │      - name: Install dependencies                  │   │
│  │        run: |                                      │   │
│  │          python -m pip install --upgrade pip      │   │
│  │          pip install -r requirements.txt           │   │
│  │          pip install flake8 black isort coverage   │   │
│  │                                                    │   │
│  │      - name: Run tests with coverage              │   │
│  │        env:                                        │   │
│  │          DB_NAME: django_blog                     │   │
│  │          DB_USER: django_user                     │   │
│  │          DB_PASSWORD: test_password               │   │
│  │          DB_HOST: localhost                       │   │
│  │          DB_PORT: 5432                            │   │
│  │          SECRET_KEY: test-secret-key              │   │
│  │          DEBUG: False                             │   │
│  │        run: |                                      │   │
│  │          coverage run manage.py test blog         │   │
│  │          coverage report --fail-under=80          │   │
│  │                                                    │   │
│  │    deploy:                                         │   │
│  │      needs: test                                   │   │
│  │      runs-on: ubuntu-latest                       │   │
│  │      if: github.event_name == 'push' &&           │   │
│  │          github.ref == 'refs/heads/main'         │   │
│  │                                                    │   │
│  │      steps:                                        │   │
│  │      - uses: actions/checkout@v4                  │   │
│  │                                                    │   │
│  │      - name: Set up SSH                           │   │
│  │        uses: webfactory/ssh-agent@v0.9.0          │   │
│  │        with:                                      │   │
│  │          ssh-private-key: ${{ secrets.SSH_PRIVATE_KEY }}│  │
│  │                                                    │   │
│  │      - name: Deploy to server                     │   │
│  │        run: |                                      │   │
│  │          ssh -o StrictHostKeyChecking=no \         │   │
│  │            ${{ secrets.DEPLOY_USER }}@\           │   │
│  │            ${{ secrets.DEPLOY_HOST }} << 'ENDSSH' │   │
│  │            cd /var/www/django_blog_project        │   │
│  │            git pull origin main                   │   │
│  │            docker compose -f docker-compose.prod.yml down│  │
│  │            docker compose -f docker-compose.prod.yml build│  │
│  │            docker compose -f docker-compose.prod.yml up -d│  │
│  │            docker system prune -f                 │   │
│  │          ENDSSH                                    │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 10.12: Health Check Endpoint

**Monitoring Application Health**

```
┌─────────────────────────────────────────────────────────────┐
│                    HEALTH CHECK ENDPOINT                    │
│                                                             │
│  View Code:                                                 │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  from django.http import JsonResponse               │   │
│  │  from django.db import connection                   │   │
│  │  from django.core.cache import cache                │   │
│  │                                                    │   │
│  │  def health_check(request):                        │   │
│  │      """Health check endpoint for monitoring."""   │   │
│  │      status = {                                    │   │
│  │          'status': 'healthy',                      │   │
│  │          'checks': {}                              │   │
│  │      }                                              │   │
│  │                                                    │   │
│  │      # Check database                              │   │
│  │      try:                                          │   │
│  │          with connection.cursor() as cursor:      │   │
│  │              cursor.execute('SELECT 1')            │   │
│  │          status['checks']['database'] = 'ok'      │   │
│  │      except Exception as e:                        │   │
│  │          status['status'] = 'unhealthy'            │   │
│  │          status['checks']['database'] = str(e)     │   │
│  │                                                    │   │
│  │      # Check cache                                 │   │
│  │      try:                                          │   │
│  │          cache.set('health_check', 'ok', timeout=5)│   │
│  │          if cache.get('health_check') != 'ok':    │   │
│  │              raise Exception('Cache write/read failed')│  │
│  │          status['checks']['cache'] = 'ok'         │   │
│  │      except Exception as e:                        │   │
│  │          status['status'] = 'unhealthy'            │   │
│  │          status['checks']['cache'] = str(e)        │   │
│  │                                                    │   │
│  │      return JsonResponse(status)                   │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  URL Pattern:                                               │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  path('health/', views.health_check,                │   │
│  │       name='health_check'),                         │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Response Example:                                          │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  {                                                  │   │
│  │      "status": "healthy",                           │   │
│  │      "checks": {                                    │   │
│  │          "database": "ok",                          │   │
│  │          "cache": "ok"                              │   │
│  │      }                                              │   │
│  │  }                                                  │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 10.13: Deployment Script

**Automated Deployment Commands**

```
┌─────────────────────────────────────────────────────────────┐
│                    DEPLOYMENT SCRIPT                        │
│                                                             │
│  `scripts/deploy.sh`:                                       │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  #!/bin/bash                                        │   │
│  │  set -e                                             │   │
│  │                                                    │   │
│  │  echo "🚀 Starting deployment..."                  │   │
│  │                                                    │   │
│  │  # Pull latest changes                             │   │
│  │  echo "📥 Pulling latest code..."                  │   │
│  │  git pull origin main                              │   │
│  │                                                    │   │
│  │  # Build and start containers                      │   │
│  │  echo "🏗️  Building and starting containers..."    │   │
│  │  docker compose -f docker-compose.prod.yml build   │   │
│  │  docker compose -f docker-compose.prod.yml up -d   │   │
│  │                                                    │   │
│  │  # Run migrations                                   │   │
│  │  echo "🗄️  Running database migrations..."         │   │
│  │  docker compose -f docker-compose.prod.yml exec web \│   │
│  │      python manage.py migrate --noinput            │   │
│  │                                                    │   │
│  │  # Collect static files                            │   │
│  │  echo "📦 Collecting static files..."              │   │
│  │  docker compose -f docker-compose.prod.yml exec web \│   │
│  │      python manage.py collectstatic --noinput      │   │
│  │                                                    │   │
│  │  # Create superuser if needed                      │   │
│  │  echo "👤 Creating superuser..."                   │   │
│  │  docker compose -f docker-compose.prod.yml exec web \│   │
│  │      python manage.py shell -c "                   │   │
│  │      from django.contrib.auth.models import User;  │   │
│  │      if not User.objects.filter(username='admin').exists():│  │
│  │          User.objects.create_superuser('admin',    │   │
│  │              'admin@example.com', '${ADMIN_PASSWORD}');│  │
│  │      "                                              │   │
│  │                                                    │   │
│  │  # Clean up old images                             │   │
│  │  echo "🧹 Cleaning up old images..."               │   │
│  │  docker system prune -f                           │   │
│  │                                                    │   │
│  │  echo "✅ Deployment complete!"                    │   │
│  │  echo "🌐 Application is running at \              │   │
│  │      $(cat .env.production | grep SITE_URL | cut -d '=' -f2)" │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Make Executable:                                           │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  chmod +x scripts/deploy.sh                        │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 10.14: Verification — Complete Deployment

**Testing the Production Deployment**

```
┌─────────────────────────────────────────────────────────────┐
│              VERIFICATION CHECKLIST                         │
│                                                             │
│  Step 1: Build and Run Locally                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  docker compose build                               │   │
│  │  docker compose up -d                               │   │
│  │  docker compose ps                                   │   │
│  │  docker compose logs web                            │   │
│  │  open http://localhost                              │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Step 2: Test in Production Mode                          │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  docker compose -f docker-compose.prod.yml down     │   │
│  │  docker compose -f docker-compose.prod.yml up -d   │   │
│  │  docker compose -f docker-compose.prod.yml ps      │   │
│  │  curl -I http://localhost                           │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Step 3: Database Backup                                   │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  docker exec django_blog_db pg_dump -U django_user  │   │
│  │      django_blog > backup.sql                       │   │
│  │                                                    │   │
│  │  cat backup.sql | docker exec -i django_blog_db    │   │
│  │      psql -U django_user django_blog                │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Step 4: View Logs                                         │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  docker compose logs web                            │   │
│  │  docker compose logs nginx                          │   │
│  │  docker compose logs -f web  # Follow logs         │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Step 5: Health Check                                      │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  curl http://localhost/health/                      │   │
│  │  # Should return {"status":"healthy", ...}          │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 10.15: Final Architecture Diagram

**Complete Production-Ready Application**

```
┌─────────────────────────────────────────────────────────────┐
│              FINAL ARCHITECTURE DIAGRAM                     │
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐│
│  │                    Production Deployment                ││
│  ├─────────────────────────────────────────────────────────┤│
│  │                                                         ││
│  │  ┌─────────────────────────────────────────────────────┐││
│  │  │                 Nginx (Web Server)                  │││
│  │  │  - Serves static/media files                       │││
│  │  │  - Reverse proxy to Gunicorn                      │││
│  │  │  - SSL termination                                │││
│  │  │  - Security headers                               │││
│  │  └────────────────────┬────────────────────────────────┘││
│  │                       │                                  ││
│  │  ┌────────────────────▼────────────────────────────────┐││
│  │  │             Gunicorn (App Server)                  │││
│  │  │  - Multi-worker processing                        │││
│  │  │  - Load balancing                                 │││
│  │  │  - Connection pooling                             │││
│  │  └────────────────────┬────────────────────────────────┘││
│  │                       │                                  ││
│  │  ┌────────────────────▼────────────────────────────────┐││
│  │  │           Django Application                       │││
│  │  │  ✅ Models with indexes                           │││
│  │  │  ✅ Class-based views                             │││
│  │  │  ✅ Forms with validation                         │││
│  │  │  ✅ Authentication & authorization               │││
│  │  │  ✅ User profiles                                 │││
│  │  │  ✅ CRUD operations                               │││
│  │  │  ✅ Search & filtering                           │││
│  │  │  ✅ Pagination                                    │││
│  │  │  ✅ File uploads                                  │││
│  │  │  ✅ Email notifications                           │││
│  │  │  ✅ Sessions                                      │││
│  │  │  ✅ Caching                                       │││
│  │  │  ✅ Logging                                       │││
│  │  │  ✅ Testing                                       │││
│  │  │  ✅ Security hardening                            │││
│  │  └────────────────────┬────────────────────────────────┘││
│  │                       │                                  ││
│  │  ┌────────────────────▼────────────────────────────────┐││
│  │  │               Redis (Cache)                       │││
│  │  │  - Session storage                                │││
│  │  │  - Query caching                                  │││
│  │  │  - Rate limiting                                  │││
│  │  └────────────────────┬────────────────────────────────┘││
│  │                       │                                  ││
│  │  ┌────────────────────▼────────────────────────────────┐││
│  │  │           PostgreSQL (Database)                   │││
│  │  │  - All application data                           │││
│  │  │  - Optimized indexes                              │││
│  │  │  - Foreign key constraints                        │││
│  │  │  - ACID compliance                                │││
│  │  └─────────────────────────────────────────────────────┘││
│  │                                                         ││
│  └─────────────────────────────────────────────────────────┘│
│                                                             │
│  Docker Compose Orchestrates All Containers                │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 10.16: What You've Learned in Part 10

**Skills Acquired and What You've Built**

```
┌─────────────────────────────────────────────────────────────┐
│              WHAT YOU'VE LEARNED — PART 10                 │
│                                                             │
│  ✅ Skills Acquired:                                        │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  • Dockerizing Django applications                  │   │
│  │  • Configuring Gunicorn for production              │   │
│  │  • Setting up Nginx as a reverse proxy              │   │
│  │  • Using Docker Compose for orchestration           │   │
│  │  • Setting up CI/CD with GitHub Actions             │   │
│  │  • Deploying to production                          │   │
│  │  • Monitoring application health                    │   │
│  │  • Managing backups                                 │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ✅ What You've Built:                                      │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  • Production Dockerfile                            │   │
│  │  • Gunicorn configuration                           │   │
│  │  • Nginx configuration                              │   │
│  │  • Docker Compose setup                             │   │
│  │  • CI/CD pipeline                                   │   │
│  │  • Deployment scripts                               │   │
│  │  • Health check endpoint                            │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 10.17: The Complete Skill Set

**Everything You've Mastered**

```
┌─────────────────────────────────────────────────────────────┐
│              COMPLETE SKILL SET                             │
│                                                             │
│  Django Development:                                        │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  • Models, views, templates, forms                  │   │
│  │  • ORM, migrations, admin                          │   │
│  │  • Authentication, authorization                   │   │
│  │  • Middleware, context processors, signals         │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Frontend:                                                  │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  • Django templates                                 │   │
│  │  • HTML/CSS                                         │   │
│  │  • Template inheritance and includes                │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Database:                                                  │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  • SQLite (development)                             │   │
│  │  • PostgreSQL (production)                          │   │
│  │  • Database design and relationships                │   │
│  │  • Indexes and query optimization                   │   │
│  │  • Transactions                                     │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Testing:                                                   │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  • Unit tests for models, forms, views              │   │
│  │  • Integration tests                                │   │
│  │  • Test coverage                                    │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Security:                                                  │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  • CSRF protection                                  │   │
│  │  • XSS prevention                                   │   │
│  │  • SQL injection prevention                         │   │
│  │  • Security headers                                 │   │
│  │  • File upload validation                           │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Performance:                                               │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  • Query optimization                               │   │
│  │  • Caching                                          │   │
│  │  • Pagination                                       │   │
│  │  • Database indexes                                 │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Deployment:                                                │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  • Docker containerization                          │   │
│  │  • Gunicorn application server                      │   │
│  │  • Nginx reverse proxy                              │   │
│  │  • Docker Compose                                   │   │
│  │  • CI/CD pipeline                                   │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 10.18: What's Next?

**Continuing Your Django Journey**

```
┌─────────────────────────────────────────────────────────────┐
│                    WHAT'S NEXT?                             │
│                                                             │
│  🚀 Next Projects:                                          │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  1. Build the Capstone Project                      │   │
│  │     • Learning Management System                    │   │
│  │     • Event Management Platform                     │   │
│  │     • Inventory Management System                   │   │
│  │     • Job Board                                     │   │
│  │     • Help Desk / Ticketing System                  │   │
│  │                                                    │   │
│  │  2. Add a REST API                                  │   │
│  │     • Django REST Framework                         │   │
│  │     • API versioning                                │   │
│  │     • Authentication with JWT                      │   │
│  │                                                    │   │
│  │  3. Modern Frontend                                 │   │
│  │     • React/Vue with Django backend                │   │
│  │     • API integration                              │   │
│  │     • State management                              │   │
│  │                                                    │   │
│  │  4. Mobile Backend                                  │   │
│  │     • Build APIs for mobile apps                   │   │
│  │     • Push notifications                            │   │
│  │                                                    │   │
│  │  5. Microservices                                   │   │
│  │     • Split monolith into services                  │   │
│  │     • Service discovery                             │   │
│  │     • Message queues                                │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  📚 Further Learning:                                       │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  • Django Documentation                             │   │
│  │  • Django REST Framework                            │   │
│  │  • PostgreSQL Advanced Queries                     │   │
│  │  • Docker Multi-stage Builds                       │   │
│  │  • Kubernetes                                       │   │
│  │  • Cloud Deployment (AWS/GCP/Azure)                │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 10.19: Thank You!

**Congratulations on Completing the Series**

```
┌─────────────────────────────────────────────────────────────┐
│              CONGRATULATIONS!                               │
│                                                             │
│  You've completed **Mastering Django 6: Full-Stack         │
│  Web Development**!                                        │
│                                                             │
│  From a blank directory to a production-ready Django       │
│  monolith with:                                            │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  ✅ Full CRUD functionality                        │   │
│  │  ✅ User authentication and profiles                │   │
│  │  ✅ Search, filtering, and pagination              │   │
│  │  ✅ File uploads and email notifications            │   │
│  │  ✅ Comprehensive testing                          │   │
│  │  ✅ Security hardening                             │   │
│  │  ✅ Docker containerization                        │   │
│  │  ✅ Production deployment                          │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  🎉 You're now equipped to build and deploy Django         │
│  applications professionally!                              │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                                                     │   │
│  │        Happy Coding! 🚀🐍                         │   │
│  │                                                     │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 10.20: Resources

**Helpful Links and Documentation**

```
┌─────────────────────────────────────────────────────────────┐
│                    RESOURCES                                │
│                                                             │
│  Official Documentation:                                    │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Django: https://docs.djangoproject.com/            │   │
│  │  Django REST Framework:                            │   │
│  │  https://www.django-rest-framework.org/            │   │
│  │  Python: https://docs.python.org/3.14/             │   │
│  │  PostgreSQL: https://www.postgresql.org/docs/      │   │
│  │  Docker: https://docs.docker.com/                  │   │
│  │  Nginx: https://nginx.org/en/docs/                 │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Community:                                                 │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Stack Overflow:                                   │   │
│  │  https://stackoverflow.com/questions/tagged/django │   │
│  │  Reddit: https://www.reddit.com/r/django/          │   │
│  │  Django Discord: https://discord.gg/django         │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Tools:                                                     │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  VS Code: https://code.visualstudio.com/           │   │
│  │  Docker: https://www.docker.com/                   │   │
│  │  GitHub: https://github.com/                       │   │
│  │  DigitalOcean: https://www.digitalocean.com/       │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Series Repository:                                         │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  [Link to your GitHub repository]                   │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Slide 10.21: Questions & Discussion

**Open Floor**

```
┌─────────────────────────────────────────────────────────────┐
│              QUESTIONS & DISCUSSION                         │
│                                                             │
│  Open Floor:                                                │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  ❓ Questions about the series                      │   │
│  │  ❓ Questions about specific parts                 │   │
│  │  ❓ Questions about Django in general              │   │
│  │  ❓ Questions about deployment                      │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Discussion Topics:                                         │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  💬 What will you build next?                      │   │
│  │  💬 What was the most challenging part?            │   │
│  │  💬 What was the most rewarding part?              │   │
│  │  💬 How will you use these skills?                 │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                                                     │   │
│  │        Thank You for Your Attention!                │   │
│  │                                                     │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

**End of Slide Deck Outline**

---

# Quick Reference: Django Commands

| Command | Purpose |
|---------|---------|
| `django-admin startproject config .` | Create a new Django project |
| `python manage.py startapp blog` | Create a new Django app |
| `python manage.py runserver` | Start the development server |
| `python manage.py makemigrations` | Create migration files |
| `python manage.py migrate` | Apply migrations to database |
| `python manage.py createsuperuser` | Create an admin user |
| `python manage.py shell` | Open Django interactive shell |
| `python manage.py test` | Run tests |
| `python manage.py collectstatic` | Collect static files |

---

# Quick Reference: Django Template Tags

| Tag | Purpose |
|-----|---------|
| `{% extends %}` | Inherit from another template |
| `{% block %}` | Define a block to be filled |
| `{% include %}` | Insert another template |
| `{% if %}` | Conditional rendering |
| `{% for %}` | Loop over a list |
| `{% url %}` | Generate a URL by name |
| `{% load %}` | Load template tags |
| `{% csrf_token %}` | CSRF protection token |
| `{% comment %}` | Comments |

---

# Quick Reference: Django ORM Methods

| Method | Purpose |
|--------|---------|
| `all()` | Get all records |
| `filter()` | Filter records |
| `exclude()` | Exclude records |
| `get()` | Get single record |
| `create()` | Create and save |
| `count()` | Count records |
| `exists()` | Check if exists |
| `order_by()` | Sort results |
| `select_related()` | Join foreign keys |
| `prefetch_related()` | Prefetch many-to-many |
| `only()` | Load only specific fields |
| `defer()` | Defer loading fields |
| `annotate()` | Add aggregate fields |
| `update()` | Bulk update |
| `delete()` | Bulk delete |
