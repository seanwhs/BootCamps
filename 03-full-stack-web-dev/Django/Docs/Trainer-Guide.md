# Mastering Django 6: Trainer Guide

## Full-Stack Web Development with Python

---

# Welcome, Trainer!

This trainer guide is designed to help you deliver the Mastering Django 6 course effectively. It contains:

1. **Course Overview** — Understanding the course structure and philosophy
2. **Teaching Strategies** — How to deliver each part effectively
3. **Lesson Plans** — Detailed session plans for each part
4. **Discussion Questions** — Prompts for classroom engagement
5. **Activity Guide** — In-class activities and demonstrations
6. **Assessment Guide** — How to evaluate student progress
7. **Troubleshooting Common Issues** — Solutions for typical problems
8. **Supplementary Resources** — Additional materials and references

**How to use this guide:**
- Review the entire guide before starting the course
- Use the lesson plans as a framework for each session
- Adapt activities based on your students' needs and pace
- Refer to the troubleshooting section for common issues

---

# Part 0: Introduction

## Course Overview

**Duration:** 30-45 minutes (first session)

### Learning Objectives

By the end of this session, students will:
- Understand what Django is and why it's used
- Know the course structure and learning journey
- Set up their development environment
- Understand the "Simple Stack" philosophy

### Key Concepts to Cover

1. **What is Django?**
   - High-level Python web framework
   - "Batteries included" philosophy
   - Real-world examples (Instagram, Pinterest, etc.)

2. **The Simple Stack Philosophy**
   - Traditional server-rendered monolith
   - Why simplicity matters
   - The architecture diagram

3. **The 10-Part Journey**
   - What students will build
   - How the application evolves
   - Skills progression

4. **Environment Setup**
   - Python installation
   - Virtual environments
   - VS Code setup
   - Django installation

### Teaching Tips

**Icebreaker Activity:**
Ask students:
- "What brought you to this course?"
- "What do you hope to build with Django?"
- "What's your experience with Python?"

**Visual Aids:**
- Show the architecture diagram
- Show a mockup of the final application
- Show the learning journey roadmap

**Common Questions:**
- "Do I need to know JavaScript?" → No, this course focuses on server-rendered HTML
- "Why not use React?" → We want to master Django fundamentals first
- "How long will this take?" → 10 parts, each ~2-4 hours

### Discussion Questions

1. What do you hope to build with Django?
2. Why do you think Django is popular for web development?
3. What concerns do you have about starting this course?

---

# Part 1: Django Fundamentals, Environment Setup, and Your First Application

## Lesson Plan

**Duration:** 90-120 minutes

### Learning Objectives

By the end of this session, students will:
- Create a Django project and application
- Understand the MVT architecture
- Build simple views and templates
- Configure URL routing
- Run the development server

### Session Outline

**1. Environment Setup (15 min)**
- Virtual environments (venv/uv)
- Installing Django
- Creating a project
- Creating an app

**2. MVT Architecture (15 min)**
- Model-View-Template explanation
- Request/response cycle
- Project vs. app

**3. Building Views (20 min)**
- Function-based views
- HttpResponse vs. render
- Context dictionaries

**4. Template Basics (20 min)**
- Template inheritance
- Variable interpolation
- Common template tags

**5. URL Routing (15 min)**
- URL patterns
- Named URLs
- Namespaces

**6. Live Demo (20 min)**
- Build a simple website together
- Show navigation between pages

**7. Q&A and Exercise (15 min)**

### Teaching Tips

**Key Concept Explanation:**

**The Restaurant Analogy:**
- URLs = Menu board
- View = Chef
- Model = Kitchen inventory
- Template = Plate presentation

**Common Pitfalls:**

1. **Virtual Environment Issues:**
   - "I can't find django" → Check if venv is activated
   - "Permission denied" → Don't use sudo with pip

2. **Template Errors:**
   - "TemplateDoesNotExist" → Check template path and APP_DIRS
   - Missing block tags → Ensure {% block %} and {% endblock %} match

3. **URL Errors:**
   - "NoReverseMatch" → Check URL name and namespace
   - 404 errors → Check URL pattern syntax

**Live Demo Script:**
```
Step 1: Create project and app
Step 2: Create a simple view
Step 3: Add URL pattern
Step 4: Create a template
Step 5: Add navigation links
Step 6: Run the server
```

### Classroom Activity

**Activity 1: First Website (30 min)**

**Instructions:**
Students build a simple website with:
- A homepage
- An about page
- A blog list page
- Shared navigation

**Checkpoints:**
- [ ] Project created
- [ ] App created and registered
- [ ] Views defined
- [ ] URLs configured
- [ ] Templates created
- [ ] Navigation works
- [ ] Server runs without errors

### Discussion Questions

1. Why do we use virtual environments?
2. What's the difference between a project and an app?
3. How does a request travel through Django?
4. What's the benefit of template inheritance?

---

# Part 2: Models, Database Design, ORM, and Django Admin

## Lesson Plan

**Duration:** 90-120 minutes

### Learning Objectives

By the end of this session, students will:
- Design Django models
- Create and run migrations
- Use Django Admin interface
- Query data with the ORM

### Session Outline

**1. Database Fundamentals (15 min)**
- Relational databases
- Tables, rows, columns
- Relationships
- Primary and foreign keys

**2. Django Models (20 min)**
- Model fields
- Relationships (ForeignKey, ManyToMany)
- Meta options
- Methods (__str__, get_absolute_url)

**3. Migrations (15 min)**
- makemigrations vs migrate
- Migration files
- Checking migration status

**4. Django Admin (20 min)**
- Creating a superuser
- Registering models
- Customizing admin
- List display, filters, search

**5. Django ORM (20 min)**
- Creating objects
- Querying objects
- Updating objects
- Deleting objects
- Advanced queries

**6. Live Demo (20 min)**
- Build the blog models
- Customize admin
- Query data in shell

**7. Q&A and Exercise (10 min)**

### Teaching Tips

**Key Concept Explanation:**

**The Database as a Filing Cabinet:**
- Tables = Drawers
- Columns = Dividers
- Rows = Folders
- Records = Documents
- Relationships = Cross-references

**Model Relationships:**

Explain relationships with examples:
- One-to-One: User → Profile
- One-to-Many: User → Posts
- Many-to-Many: Posts → Tags

**Demo Script:**

```
1. Define models in models.py
2. Run makemigrations
3. Show migration file
4. Run migrate
5. Show database tables
6. Register in admin
7. Customize admin display
8. Create data in admin
9. Query in shell
```

### Common Pitfalls

| Problem | Solution |
|---------|----------|
| Migration doesn't create table | Check if app is in INSTALLED_APPS |
| Foreign key error | Ensure related model exists |
| Admin not showing | Register model with @admin.register |
| ORM returns no results | Check filter conditions |
| Slug not generating | Override save() method |

### Classroom Activity

**Activity 2: Build Blog Models (40 min)**

**Instructions:**
Students build the full blog models:
- Category
- Tag
- Post
- Comment

**Checkpoints:**
- [ ] All models defined
- [ ] Relationships correct
- [ ] Migrations created and applied
- [ ] Models registered in admin
- [ ] Admin customized
- [ ] Test data created
- [ ] Basic queries work

### Discussion Questions

1. Why do we need migrations?
2. What's the difference between ForeignKey and ManyToManyField?
3. How does `on_delete` work?
4. Why use Django Admin?

---

# Part 3: Templates, Static Files, Forms, and CRUD

## Lesson Plan

**Duration:** 90-120 minutes

### Learning Objectives

By the end of this session, students will:
- Create ModelForms
- Implement CRUD operations
- Handle file uploads
- Use Django messages
- Secure forms with CSRF

### Session Outline

**1. Forms Overview (15 min)**
- Form vs ModelForm
- Creating ModelForms
- Form fields and widgets
- Validation

**2. CRUD Views (25 min)**
- Create (GET → POST)
- Read (List and Detail)
- Update (GET → POST)
- Delete (GET → POST)

**3. File Uploads (10 min)**
- enctype="multipart/form-data"
- ImageField and FileField
- MEDIA_URL and MEDIA_ROOT

**4. Messages Framework (10 min)**
- success, info, warning, error
- Displaying messages in templates

**5. CSRF Protection (10 min)**
- What is CSRF?
- The {% csrf_token %} tag
- CSRF middleware

**6. Live Demo (30 min)**
- Full CRUD implementation

**7. Q&A and Exercise (20 min)**

### Teaching Tips

**Key Concept Explanation:**

**The Form Lifecycle:**
```
GET Request → Empty Form → User fills → POST Request → Validation → Save/Errors
```

**Common CRUD Pattern:**
```python
if request.method == 'POST':
    form = Form(request.POST)
    if form.is_valid():
        # Save and redirect
else:
    form = Form()
return render(request, 'template.html', {'form': form})
```

**Demo Script:**

```
1. Create PostForm
2. Create post_create view
3. Create post_edit view
4. Create post_delete view
5. Create templates
6. Add URLs
7. Test CRUD operations
```

### Common Pitfalls

| Problem | Solution |
|---------|----------|
| CSRF token missing | Add {% csrf_token %} to forms |
| File upload not working | Add enctype="multipart/form-data" |
| Form not validating | Check field requirements |
| Messages not showing | Add messages to template |
| Permission errors | Add @login_required |

### Classroom Activity

**Activity 3: Build CRUD Interface (50 min)**

**Instructions:**
Students build a complete CRUD interface:
- Create posts
- Read posts
- Edit posts
- Delete posts
- Add comments

**Checkpoints:**
- [ ] Create form works
- [ ] Edit form pre-populates
- [ ] Delete confirms
- [ ] Only authors can edit/delete
- [ ] Success/error messages appear
- [ ] File uploads work

### Discussion Questions

1. Why do we need both GET and POST in forms?
2. What happens if we don't use CSRF protection?
3. How does Django validate forms?
4. When would you use commit=False?

---

# Part 4: Class-Based Views, Search, Filtering, Pagination, and Messaging

## Lesson Plan

**Duration:** 90-120 minutes

### Learning Objectives

By the end of this session, students will:
- Use class-based views (ListView, DetailView)
- Implement CreateView, UpdateView, DeleteView
- Build search functionality
- Implement filtering
- Add pagination

### Session Outline

**1. Understanding CBVs (15 min)**
- FBV vs CBV
- Common CBV types
- CBV hierarchy
- Methods and attributes

**2. ListView and DetailView (20 min)**
- Configuration options
- Custom querysets
- Extra context data

**3. CreateView, UpdateView, DeleteView (20 min)**
- Form handling
- Success URLs
- Mixins (LoginRequiredMixin, UserPassesTestMixin)

**4. Search and Filtering (20 min)**
- Q objects
- Filter parameters
- Search in templates

**5. Pagination (15 min)**
- paginate_by attribute
- Paginator object
- Template controls

**6. Live Demo (25 min)**
- Refactor FBVs to CBVs
- Add search and pagination

**7. Q&A and Exercise (15 min)**

### Teaching Tips

**Key Concept Explanation:**

**CBV Flow:**
```
URL → as_view() → dispatch() → get()/post() → context → template
```

**Common CBV Attributes:**

| Attribute | Purpose |
|-----------|---------|
| model | The model to work with |
| template_name | Template to render |
| context_object_name | Variable name in template |
| paginate_by | Items per page |
| form_class | Form class to use |
| success_url | URL after success |

**Demo Script:**

```
1. Create PostListView
2. Add pagination
3. Add search with Q objects
4. Add category filtering
5. Create PostDetailView
6. Create PostCreateView
7. Create PostUpdateView
8. Create PostDeleteView
```

### Common Pitfalls

| Problem | Solution |
|---------|----------|
| Template not found | Set template_name correctly |
| Context variable missing | Set context_object_name |
| Pagination not working | Add paginate_by |
| Login not required | Add LoginRequiredMixin first |
| Permission issues | Add UserPassesTestMixin |

### Classroom Activity

**Activity 4: Implement Search and Pagination (40 min)**

**Instructions:**
Students enhance the blog with:
- Search by title/content
- Filter by category
- Pagination (10 per page)

**Checkpoints:**
- [ ] Search works
- [ ] Category filter works
- [ ] Pagination works
- [ ] Filter parameters preserved
- [ ] Empty states handled

### Discussion Questions

1. When would you use FBV over CBV?
2. Why use mixins?
3. How does pagination improve performance?
4. What are Q objects used for?

---

# Part 5: Authentication, Users, Sessions, Permissions, and Security

## Lesson Plan

**Duration:** 90-120 minutes

### Learning Objectives

By the end of this session, students will:
- Implement user registration
- Implement login/logout
- Create user profiles
- Manage permissions
- Implement password reset

### Session Outline

**1. Django Authentication (15 min)**
- Built-in auth system
- User model
- Authentication backends
- Sessions

**2. Registration and Login (20 min)**
- UserCreationForm
- LoginView
- Auto-login after registration
- Protecting views

**3. User Profiles (20 min)**
- OneToOneField
- Profile model
- Signals (post_save)
- Profile views and templates

**4. Permissions (15 min)**
- Model permissions
- Custom permissions
- Checking permissions in views and templates
- Groups

**5. Password Reset (15 min)**
- Built-in views
- Email configuration
- Templates

**6. Live Demo (25 min)**
- Full authentication system

**7. Q&A and Exercise (10 min)**

### Teaching Tips

**Key Concept Explanation:**

**User Authentication Flow:**
```
Registration → Login → Session Created → Authenticated Requests → Logout → Session Destroyed
```

**Why OneToOneField for Profiles:**
- User model is built-in and shouldn't be modified
- Profile extends user data
- Each user has exactly one profile
- Easy to access: `user.profile`

**Demo Script:**

```
1. Create Profile model
2. Add signals for auto-creation
3. Create ProfileForm
4. Create profile views
5. Create dashboard
6. Configure password reset
7. Test registration
8. Test login/logout
9. Test profile editing
10. Test password reset
```

### Common Pitfalls

| Problem | Solution |
|---------|----------|
| Profile not created | Check signal registration |
| Password reset email not sent | Configure email backend |
| User can edit others' profiles | Check ownership in views |
| Profile fields not saving | Check form fields |
| Password reset link invalid | Check email template URL |

### Classroom Activity

**Activity 5: Build Authentication System (40 min)**

**Instructions:**
Students build a complete authentication system:
- Registration
- Login/Logout
- Profile editing
- Password reset
- Dashboard

**Checkpoints:**
- [ ] Registration works
- [ ] Login works
- [ ] Profile created automatically
- [ ] Profile editing works
- [ ] Password reset works
- [ ] Dashboard shows user data

### Discussion Questions

1. Why use Django's built-in auth instead of custom?
2. Why use OneToOneField for profiles?
3. How do signals help with profiles?
4. Why is password reset important?

---

# Part 6: Advanced Django Architecture and Application Design

## Lesson Plan

**Duration:** 90-120 minutes

### Learning Objectives

By the end of this session, students will:
- Understand the request lifecycle
- Create custom middleware
- Implement context processors
- Use Django signals
- Build a service layer

### Session Outline

**1. Request Lifecycle (15 min)**
- Complete flow
- Middleware
- URL dispatcher
- View processing
- Response generation

**2. Custom Middleware (20 min)**
- Creating middleware
- Request/response processing
- Registering middleware
- Use cases (logging, security)

**3. Context Processors (15 min)**
- What they are
- Creating context processors
- Registering them
- Use cases

**4. Django Signals (15 min)**
- Signal types
- Creating receivers
- Registering signals
- Use cases

**5. Service Layer (20 min)**
- What is a service layer
- Separating business logic
- Creating services
- Using services in views

**6. Live Demo (25 min)**
- Build middleware, context processors, service layer

**7. Q&A and Exercise (10 min)**

### Teaching Tips

**Key Concept Explanation:**

**The Request Lifecycle:**
```
Browser → Middleware (Request) → URL Resolver → View → Template → Middleware (Response) → Browser
```

**Service Layer Benefits:**
- Separation of concerns
- Reusability
- Testability
- Maintainability

**Demo Script:**

```
1. Create request logging middleware
2. Create security headers middleware
3. Create global context processor
4. Create post_save signal for welcome email
5. Create PostService
6. Refactor views to use service layer
7. Test everything
```

### Common Pitfalls

| Problem | Solution |
|---------|----------|
| Middleware not running | Check registration order |
| Context processor not loading | Check TEMPLATES settings |
| Signal not firing | Check app ready() method |
| Service layer too complex | Keep it simple and focused |

### Classroom Activity

**Activity 6: Build Architecture Components (40 min)**

**Instructions:**
Students build:
- Request logging middleware
- Global context processor
- User activity signal
- Post service layer

**Checkpoints:**
- [ ] Middleware logs requests
- [ ] Context processor adds variables
- [ ] Signal triggers on user creation
- [ ] Service layer works
- [ ] Views refactored

### Discussion Questions

1. Why separate logic from views?
2. When would you use middleware vs context processors?
3. What are the benefits of signals?
4. How does a service layer improve testability?

---

# Part 7: Files, Images, Email, Sessions, and Real-World Features

## Lesson Plan

**Duration:** 90-120 minutes

### Learning Objectives

By the end of this session, students will:
- Handle file and image uploads
- Send email notifications
- Use sessions for temporary data
- Implement database transactions

### Session Outline

**1. File and Image Uploads (20 min)**
- MEDIA_URL and MEDIA_ROOT
- ImageField and FileField
- File upload validation
- Serving media files

**2. Email Notifications (20 min)**
- Email backends
- send_mail
- HTML emails
- Email templates

**3. Sessions (15 min)**
- What are sessions
- Setting and getting session data
- Session expiration
- Use cases (recently viewed, shopping cart)

**4. Database Transactions (15 min)**
- Why transactions
- transaction.atomic
- Savepoints
- Use cases

**5. Live Demo (30 min)**
- Add image uploads
- Add email notifications
- Add recently viewed
- Add transactions

**6. Q&A and Exercise (20 min)**

### Teaching Tips

**Key Concept Explanation:**

**File Upload Flow:**
```
Form → enctype="multipart/form-data" → request.FILES → Model ImageField → MEDIA_ROOT → Served via URL
```

**Email Flow:**
```
View → send_mail → Email Backend → SMTP/Console → Recipient
```

**Demo Script:**

```
1. Configure media settings
2. Add featured_image to Post
3. Add avatar to Profile
4. Create email templates
5. Send welcome email
6. Track recent posts in session
7. Wrap operations in transactions
```

### Common Pitfalls

| Problem | Solution |
|---------|----------|
| File not saving | Check enctype and permissions |
| Image not displaying | Check MEDIA_URL and URL config |
| Email not sending | Check email backend settings |
| Session not persisting | Check session middleware |

### Classroom Activity

**Activity 7: Add Real-World Features (40 min)**

**Instructions:**
Students add:
- Profile avatars
- Post featured images
- Welcome email on registration
- Recently viewed posts

**Checkpoints:**
- [ ] Avatar upload works
- [ ] Featured image upload works
- [ ] Welcome email sent
- [ ] Recently viewed works
- [ ] Session persistence works

### Discussion Questions

1. Why separate static and media files?
2. How do you validate file uploads?
3. What are the benefits of email templates?
4. When would you use transactions?

---

# Part 8: Testing, Debugging, Logging, and Quality

## Lesson Plan

**Duration:** 90-120 minutes

### Learning Objectives

By the end of this session, students will:
- Write model tests
- Write form tests
- Write view tests
- Implement logging
- Use debugging tools

### Session Outline

**1. Testing Overview (15 min)**
- Why test
- Test types
- TestCase class
- Test database

**2. Model Tests (15 min)**
- Testing model creation
- Testing methods
- Testing relationships

**3. Form Tests (15 min)**
- Testing valid forms
- Testing invalid forms
- Testing custom validation

**4. View Tests (20 min)**
- Testing status codes
- Testing templates
- Testing context data
- Testing redirects
- Authentication testing

**5. Logging (15 min)**
- Log levels
- Configuring logging
- Handlers and formatters
- Use cases

**6. Debugging Tools (15 min)**
- Django Debug Toolbar
- pdb/ipdb
- Reading tracebacks

**7. Live Demo (20 min)**
- Write comprehensive tests

**8. Q&A and Exercise (15 min)**

### Teaching Tips

**Key Concept Explanation:**

**Testing Pyramid:**
```
       ┌─────┐
       │ End │
       │ -to-│
       │ End │
     ┌─┴─────┴─┐
     │Integra- │
     │  tion   │
   ┌─┴─────────┴─┐
   │   Unit Tests │
   └──────────────┘
```

**Demo Script:**

```
1. Write Post model tests
2. Write PostForm tests
3. Write PostListView tests
4. Write authentication tests
5. Configure logging
6. Use debug toolbar
```

### Common Pitfalls

| Problem | Solution |
|---------|----------|
| Tests failing | Check test data and assumptions |
| Database errors | Use transaction.atomic in tests |
| Authentication failures | Use client.login() |
| Logging not showing | Check log level |

### Classroom Activity

**Activity 8: Write Tests (40 min)**

**Instructions:**
Students write tests for:
- Post model
- PostForm
- PostListView
- Authentication

**Checkpoints:**
- [ ] Model tests pass
- [ ] Form tests pass
- [ ] View tests pass
- [ ] Auth tests pass
- [ ] Logging configured

### Discussion Questions

1. Why write tests?
2. What's the difference between unit and integration tests?
3. How does logging help in production?
4. What are common debugging techniques?

---

# Part 9: Performance, Security Hardening, and Production Configuration

## Lesson Plan

**Duration:** 90-120 minutes

### Learning Objectives

By the end of this session, students will:
- Optimize ORM queries
- Implement caching
- Harden security
- Use environment variables
- Configure production settings

### Session Outline

**1. Query Optimization (20 min)**
- N+1 problem
- select_related
- prefetch_related
- only and defer
- Database indexes

**2. Caching (15 min)**
- Cache backends
- cache_page
- Manual caching
- Cache invalidation

**3. Security Hardening (20 min)**
- Production checklist
- Security headers
- HTTPS
- Secure cookies
- ALLOWED_HOSTS

**4. Environment Variables (15 min)**
- Why use them
- python-dotenv
- .env files
- Production vs development

**5. PostgreSQL Setup (15 min)**
- Why PostgreSQL
- Migration from SQLite
- PostgreSQL configuration

**6. Live Demo (25 min)**
- Optimize queries
- Add caching
- Harden security

**7. Q&A and Exercise (10 min)**

### Teaching Tips

**Key Concept Explanation:**

**The N+1 Problem:**
```
posts = Post.objects.all()
for post in posts:
    print(post.author.username)  # 1 + N queries
```

**Solution:**
```
posts = Post.objects.select_related('author').all()
for post in posts:
    print(post.author.username)  # Only 1 query
```

**Demo Script:**

```
1. Identify N+1 queries
2. Add select_related
3. Add prefetch_related
4. Implement caching
5. Configure security settings
6. Set up environment variables
7. Switch to PostgreSQL
```

### Common Pitfalls

| Problem | Solution |
|---------|----------|
| Queries still slow | Add database indexes |
| Cache not working | Check cache backend |
| Security errors | Check ALLOWED_HOSTS |
| Environment variables not loading | Check dotenv path |

### Classroom Activity

**Activity 9: Production Readiness (40 min)**

**Instructions:**
Students prepare for production:
- Optimize queries
- Add caching
- Harden security
- Configure environment variables

**Checkpoints:**
- [ ] N+1 queries fixed
- [ ] Caching implemented
- [ ] Security settings correct
- [ ] Environment variables set
- [ ] PostgreSQL configured

### Discussion Questions

1. What is the N+1 problem?
2. How does caching improve performance?
3. Why is security important in production?
4. What are environment variables used for?

---

# Part 10: Docker, Gunicorn, Nginx, CI/CD, and Production Deployment

## Lesson Plan

**Duration:** 90-120 minutes

### Learning Objectives

By the end of this session, students will:
- Containerize the application with Docker
- Configure Gunicorn
- Set up Nginx as a reverse proxy
- Use Docker Compose
- Implement a CI/CD pipeline
- Deploy to production

### Session Outline

**1. Docker Fundamentals (15 min)**
- What is Docker
- Images vs containers
- Dockerfile
- Docker commands

**2. Gunicorn (10 min)**
- WSGI servers
- Gunicorn configuration
- Workers and threads

**3. Nginx (15 min)**
- Reverse proxy
- Serving static files
- Nginx configuration
- SSL/HTTPS

**4. Docker Compose (20 min)**
- Multi-container applications
- docker-compose.yml
- Services, volumes, networks

**5. CI/CD (15 min)**
- What is CI/CD
- GitHub Actions
- Deployment pipeline

**6. Live Demo (30 min)**
- Build Dockerfile
- Configure Gunicorn
- Set up Nginx
- Deploy with Docker Compose

**7. Q&A and Exercise (15 min)**

### Teaching Tips

**Key Concept Explanation:**

**Docker vs Virtual Machines:**
```
VM: Guest OS → Hypervisor → Host OS → Hardware
Docker: Container → Docker Engine → Host OS → Hardware
```

**Deployment Architecture:**
```
Browser → Nginx (Port 80/443) → Gunicorn (Port 8000) → Django → PostgreSQL
```

**Demo Script:**

```
1. Create Dockerfile
2. Create Gunicorn config
3. Create Nginx config
4. Create docker-compose.yml
5. Build images
6. Run containers
7. Test deployment
```

### Common Pitfalls

| Problem | Solution |
|---------|----------|
| Docker build fails | Check Dockerfile syntax |
| Gunicorn won't start | Check WSGI path |
| Nginx 502 error | Check upstream server |
| Port conflict | Change exposed ports |
| Database connection | Check DB_HOST |

### Classroom Activity

**Activity 10: Deployment (40 min)**

**Instructions:**
Students deploy the application using:
- Docker
- Gunicorn
- Nginx
- Docker Compose

**Checkpoints:**
- [ ] Dockerfile works
- [ ] Gunicorn configured
- [ ] Nginx configured
- [ ] Docker Compose works
- [ ] Application accessible
- [ ] Static files served

### Discussion Questions

1. Why use Docker for deployment?
2. What's the difference between Gunicorn and Django's dev server?
3. Why use Nginx in front of Gunicorn?
4. What are the benefits of CI/CD?

---

# Assessment Guide

## Formative Assessment

### During Sessions

**Questioning Strategies:**
- "What do you think happens next?"
- "Why do we need this?"
- "Can you explain this to the class?"

**Code Reviews:**
- Walk through student code
- Identify patterns and anti-patterns
- Provide constructive feedback

### Exercise Checkpoints

Each part includes exercise checkpoints. Use these to verify understanding:

**Green** = On track, **Yellow** = Needs support, **Red** = Needs intervention

## Summative Assessment

### Part Quizzes

Use the quiz bank for each part. Recommended:
- 10 multiple-choice questions
- 15 minutes for completion
- 70% passing threshold

### Midterm Exam

Covering Parts 1-5:
- 50 multiple-choice questions
- 60 minutes for completion
- 70% passing threshold

### Final Exam

Covering Parts 1-10:
- 100 multiple-choice questions
- 120 minutes for completion
- 70% passing threshold

### Practical Project

Students build a complete application:
- 2-4 weeks to complete
- Rubric based on the capstone requirements
- Presentation of final project

## Grading Scale

| Grade | Percentage | Performance |
|-------|------------|-------------|
| A | 90-100% | Outstanding |
| B | 80-89% | Good |
| C | 70-79% | Satisfactory |
| D | 60-69% | Below average |
| F | <60% | Needs improvement |

## Sample Grading Rubric

| Component | Weight | Description |
|-----------|--------|-------------|
| Part Quizzes | 20% | 10 quizzes |
| Midterm Exam | 20% | Parts 1-5 |
| Final Exam | 30% | Parts 1-10 |
| Practical Project | 30% | Capstone project |

---

# Troubleshooting Common Issues

## Environment Setup Issues

| Issue | Solution |
|-------|----------|
| "Command not found: django-admin" | `pip install django` or check PATH |
| Virtual environment not activating | Check path and syntax |
| Permission denied | Don't use `sudo` with pip |
| Python version mismatch | Use correct Python version |

## Code Issues

| Issue | Solution |
|-------|----------|
| Syntax errors | Check indentation and brackets |
| Import errors | Check import statements and installed packages |
| URL errors | Check URL patterns and names |
| Template errors | Check template syntax and inheritance |

## Database Issues

| Issue | Solution |
|-------|----------|
| Migration errors | Check model syntax and relationships |
| Query errors | Check ORM syntax |
| Data not saving | Check form and model validation |

## Deployment Issues

| Issue | Solution |
|-------|----------|
| Docker build fails | Check Dockerfile syntax |
| Container won't start | Check logs: `docker logs` |
| Port already in use | Change port mapping |
| Database connection | Check connection string and credentials |

---

# Supplementary Resources

## Official Documentation

- [Django Documentation](https://docs.djangoproject.com/)
- [Django REST Framework](https://www.django-rest-framework.org/)
- [Django Tutorial](https://docs.djangoproject.com/en/stable/intro/tutorial01/)

## Reference Books

- *Two Scoops of Django* by Daniel Roy Greenfeld
- *Django for Beginners* by William S. Vincent
- *Django 4 By Example* by Antonio Mele

## Community Resources

- [Django Subreddit](https://www.reddit.com/r/django/)
- [Django Discord](https://discord.com/invite/django)
- [Stack Overflow (Django)](https://stackoverflow.com/questions/tagged/django)

## Additional Tutorials

- [Django Girls Tutorial](https://tutorial.djangogirls.org/)
- [Real Python Django Tutorials](https://realpython.com/tutorials/django/)
- [MDN Django Tutorial](https://developer.mozilla.org/en-US/docs/Learn/Server-side/Django)

## Development Tools

- [VS Code](https://code.visualstudio.com/)
- [PyCharm](https://www.jetbrains.com/pycharm/)
- [Postman](https://www.postman.com/)
- [Django Debug Toolbar](https://github.com/jazzband/django-debug-toolbar)

## Deployment Platforms

- [Heroku](https://www.heroku.com/)
- [PythonAnywhere](https://www.pythonanywhere.com/)
- [DigitalOcean](https://www.digitalocean.com/)
- [AWS](https://aws.amazon.com/)

---

# Conclusion

## Final Trainer Notes

**Key Teaching Principles:**

1. **Teach by Doing:** Students learn best by writing code
2. **Start Simple:** Build complexity gradually
3. **Use Analogies:** Relate concepts to everyday things
4. **Encourage Questions:** Create a safe learning environment
5. **Provide Context:** Explain why things are done a certain way
6. **Make It Real:** Use real-world examples
7. **Celebrate Success:** Acknowledge progress and achievements

**Common Student Concerns:**

- "I'm not a good coder" → Everyone starts somewhere
- "This is too hard" → Break it down into smaller steps
- "I don't understand" → Ask specific questions
- "I'm falling behind" → Provide extra support

**Tips for Success:**

1. **Be Patient:** Students learn at different paces
2. **Be Encouraging:** Positive reinforcement goes a long way
3. **Be Available:** Provide office hours or chat support
4. **Be Prepared:** Know the material well
5. **Be Flexible:** Adapt to student needs

---

**[END OF TRAINER GUIDE]**
