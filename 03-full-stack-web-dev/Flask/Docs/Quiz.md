# Master Modern Flask 3.x: Quiz & Test Bank

## Comprehensive Assessment with Answer Keys

---

# HOW TO USE THIS TEST BANK

This test bank is designed to assess understanding of the "Master Modern Flask 3.x" tutorial series. It includes:

1. **Chapter Quizzes** - Short quizzes for each part (10 questions each)
2. **Midterm Exam** - Comprehensive exam covering Parts 1-4
3. **Final Exam** - Complete exam covering all 8 parts
4. **Practical Exercises** - Hands-on coding challenges
5. **Answer Keys** - Detailed answers with explanations

**Question Types:**
- Multiple Choice
- True/False
- Fill in the Blank
- Short Answer
- Code Writing
- Practical Exercises

---

# PART 1: FLASK FOUNDATIONS & PROJECT ARCHITECTURE

## Quiz 1: Flask Fundamentals

### Multiple Choice

**1. What is Flask?**
- A) A full-stack web framework
- B) A microframework for web applications
- C) A database management system
- D) A frontend JavaScript library

**2. Which pattern is recommended for creating Flask applications in production?**
- A) Global App Pattern
- B) Application Factory Pattern
- C) Singleton Pattern
- D) Observer Pattern

**3. What is the purpose of Blueprints in Flask?**
- A) To manage database connections
- B) To organize routes and views into modules
- C) To handle authentication
- D) To render templates

**4. Which tool is NOT typically used for code quality in Flask projects?**
- A) Ruff
- B) Black
- C) Django
- D) mypy

**5. What command activates a Python virtual environment on macOS/Linux?**
- A) venv activate
- B) source venv/bin/activate
- C) venv/Scripts/activate
- D) activate venv

### True/False

**6.** [ ] Flask comes with a built-in ORM.

**7.** [ ] The Application Factory pattern makes testing easier.

**8.** [ ] Environment variables should be hardcoded in your application.

**9.** [ ] Blueprints can have their own templates and static files.

**10.** [ ] The Flask development server is suitable for production use.

---

## Answer Key: Quiz 1

| # | Answer | Explanation |
|---|--------|-------------|
| 1 | B | Flask is a microframework that provides only essential features |
| 2 | B | Application Factory pattern allows multiple configurations and easier testing |
| 3 | B | Blueprints organize routes and views into reusable modules |
| 4 | C | Django is a web framework, not a code quality tool |
| 5 | B | Source activates the virtual environment on Unix-based systems |
| 6 | False | Flask does not include a built-in ORM; you add one like SQLAlchemy |
| 7 | True | Factory pattern makes testing easier by creating app instances per test |
| 8 | False | Environment variables should never be hardcoded; use env vars |
| 9 | True | Blueprints can have their own templates and static folders |
| 10 | False | Flask development server is not suitable for production use |

---

# PART 2: ROUTING, REQUESTS & TEMPLATING

## Quiz 2: Routing & Templating

### Multiple Choice

**1. Which decorator is used to define a route in Flask?**
- A) `@app.get()`
- B) `@app.route()`
- C) `@app.url()`
- D) `@app.path()`

**2. What does `url_for('profile', username='john')` return?**
- A) `/profile?username=john`
- B) `/profile/john`
- C) `/user/john`
- D) `/profile?user=john`

**3. Which Jinja2 template tag is used for conditionals?**
- A) `{{ if condition }}`
- B) `{% if condition %}`
- C) `{# if condition #}`
- D) `$(if condition)`

**4. What does `{{ text|safe }}` do in Jinja2?**
- A) Encrypts the text
- B) Escapes HTML characters
- C) Marks text as safe HTML
- D) Converts text to lowercase

**5. What is the purpose of CSRF protection in Flask-WTF?**
- A) To prevent SQL injection
- B) To prevent cross-site request forgery
- C) To prevent XSS attacks
- D) To encrypt passwords

### True/False

**6.** [ ] Jinja2 templates auto-escape HTML by default.

**7.** [ ] Flash messages persist across multiple requests.

**8.** [ ] The `request.args` object contains form data from POST requests.

**9.** [ ] Custom URL converters can be created in Flask.

**10.** [ ] Error handlers can only be defined for 404 errors.

---

## Answer Key: Quiz 2

| # | Answer | Explanation |
|---|--------|-------------|
| 1 | B | `@app.route()` is the primary decorator for defining routes |
| 2 | B | `url_for()` generates `/profile/john` for the profile route |
| 3 | B | `{% if %}` is used for conditionals in Jinja2 |
| 4 | C | The `safe` filter marks content as safe HTML without escaping |
| 5 | B | CSRF protection prevents cross-site request forgery attacks |
| 6 | True | Jinja2 auto-escapes HTML to prevent XSS attacks |
| 7 | True | Flash messages persist across requests via session |
| 8 | False | `request.form` contains POST data; `request.args` contains URL params |
| 9 | True | Custom URL converters can be created and registered |
| 10 | False | Error handlers can be defined for any HTTP status code |

---

# PART 3: DATABASES, ORM & DATA MODELING

## Quiz 3: Databases & ORM

### Multiple Choice

**1. Which library is most commonly used as an ORM with Flask?**
- A) Django ORM
- B) SQLAlchemy
- C) Peewee
- D) SQLite3

**2. What does `db.Column(db.String(50), unique=True)` define?**
- A) A column that can have duplicate values
- B) A column that must have unique values
- C) A column that can be null
- D) A column that is a primary key

**3. What is the purpose of `db.relationship()`?**
- A) To create a foreign key constraint
- B) To define a relationship between models
- C) To create an index
- D) To add a column

**4. What is the N+1 query problem?**
- A) Making N+1 queries to get related data
- B) Querying N+1 tables
- C) Having N+1 indexes on a table
- D) Running N+1 migrations

**5. Which command creates a new migration in Alembic?**
- A) `flask db init`
- B) `flask db migrate`
- C) `flask db upgrade`
- D) `flask db create`

### True/False

**6.** [ ] The Session object tracks changes to models.

**7.** [ ] `joinedload()` is used for lazy loading.

**8.** [ ] Many-to-many relationships require an association table.

**9.** [ ] `db.create_all()` should be used in production.

**10.** [ ] Migrations allow database schema rollbacks.

---

## Answer Key: Quiz 3

| # | Answer | Explanation |
|---|--------|-------------|
| 1 | B | SQLAlchemy is the most common ORM used with Flask |
| 2 | B | `unique=True` ensures values in the column are unique |
| 3 | B | `db.relationship()` defines relationships between models |
| 4 | A | N+1 queries occur when you make additional queries for related data |
| 5 | B | `flask db migrate` creates a new migration file |
| 6 | True | The Session tracks all changes to models |
| 7 | False | `joinedload()` is for eager loading; lazy loading is default |
| 8 | True | Many-to-many requires an association (join) table |
| 9 | False | Use migrations in production, not `db.create_all()` |
| 10 | True | Migrations support rolling back schema changes |

---

# PART 4: AUTHENTICATION, AUTHORIZATION & SECURITY

## Quiz 4: Authentication & Security

### Multiple Choice

**1. Which extension is used for user session management in Flask?**
- A) Flask-Security
- B) Flask-Login
- C) Flask-Auth
- D) Flask-Sessions

**2. What does `UserMixin` provide in Flask-Login?**
- A) Password hashing
- B) Default implementations for authentication methods
- C) Database connection
- D) Form validation

**3. Which function is used to hash passwords in Werkzeug?**
- A) `hash_password()`
- B) `generate_password_hash()`
- C) `encrypt_password()`
- D) `secure_password()`

**4. What is the purpose of CSRF tokens?**
- A) To encrypt data
- B) To prevent cross-site request forgery
- C) To hash passwords
- D) To manage sessions

**5. Which header enforces HTTPS?**
- A) X-Frame-Options
- B) Strict-Transport-Security
- C) X-Content-Type-Options
- D) Content-Security-Policy

### True/False

**6.** [ ] Password hashing is reversible.

**7.** [ ] Flask-Login requires a `user_loader` function.

**8.** [ ] Role-based access control (RBAC) uses permissions.

**9.** [ ] CSRF protection is only needed for GET requests.

**10.** [ ] Security headers should only be added in production.

---

## Answer Key: Quiz 4

| # | Answer | Explanation |
|---|--------|-------------|
| 1 | B | Flask-Login manages user sessions and authentication |
| 2 | B | UserMixin provides default implementations for authentication methods |
| 3 | B | `generate_password_hash()` is the Werkzeug function for hashing |
| 4 | B | CSRF tokens prevent cross-site request forgery attacks |
| 5 | B | Strict-Transport-Security (HSTS) enforces HTTPS |
| 6 | False | Password hashing is one-way; it cannot be reversed |
| 7 | True | `@login_manager.user_loader` is required to load users |
| 8 | True | RBAC uses permissions assigned to roles |
| 9 | False | CSRF protection is needed for all state-changing requests (POST, PUT, DELETE) |
| 10 | False | Security headers should be added in all environments |

---

# PART 5: BUILDING RESTFUL APIS

## Quiz 5: REST APIs

### Multiple Choice

**1. What does REST stand for?**
- A) Representational State Transfer
- B) Request State Transfer
- C) Representational Server Technology
- D) Response State Transfer

**2. Which HTTP method is used to create a new resource?**
- A) GET
- B) PUT
- C) POST
- D) DELETE

**3. What is the correct HTTP status code for "Created"?**
- A) 200
- B) 201
- C) 202
- D) 204

**4. Which library is commonly used for serialization in Flask APIs?**
- A) SQLAlchemy
- B) Marshmallow
- C) Django REST
- D) Flask-RESTful

**5. What is the purpose of rate limiting in APIs?**
- A) To increase performance
- B) To prevent abuse
- C) To cache responses
- D) To encrypt data

### True/False

**6.** [ ] REST APIs should use verbs for resources.

**7.** [ ] JWT tokens are used for authentication.

**8.** [ ] The PUT method should be idempotent.

**9.** [ ] API versioning is optional in REST APIs.

**10.** [ ] 404 status code means "Method Not Allowed".

---

## Answer Key: Quiz 5

| # | Answer | Explanation |
|---|--------|-------------|
| 1 | A | REST stands for Representational State Transfer |
| 2 | C | POST creates a new resource |
| 3 | B | 201 Created is the status code for successful creation |
| 4 | B | Marshmallow is commonly used for serialization |
| 5 | B | Rate limiting prevents API abuse and ensures fair usage |
| 6 | False | REST APIs should use nouns for resources, not verbs |
| 7 | True | JWT tokens are used for stateless API authentication |
| 8 | True | PUT is idempotent (multiple identical requests have same effect) |
| 9 | True | API versioning is optional but recommended |
| 10 | False | 404 is "Not Found"; 405 is "Method Not Allowed" |

---

# PART 6: ASYNC PROGRAMMING & BACKGROUND PROCESSING

## Quiz 6: Async & Background Tasks

### Multiple Choice

**1. What is the main benefit of async programming?**
- A) Faster CPU processing
- B) Better memory usage
- C) Non-blocking I/O operations
- D) Simpler code

**2. Which library is commonly used for background tasks in Flask?**
- A) Celery
- B) Redis
- C) SQLAlchemy
- D) Flask-Async

**3. What is a message broker in Celery?**
- A) A database
- B) A queue that stores tasks
- C) A web server
- D) A cache

**4. Which command starts a Celery worker?**
- A) `celery start`
- B) `celery -A app.celery_worker.celery worker`
- C) `celery run`
- D) `celery work`

**5. What is Celery Beat used for?**
- A) Running tasks immediately
- B) Scheduling periodic tasks
- C) Monitoring tasks
- D) Storing results

### True/False

**6.** [ ] Async views should be used for CPU-intensive operations.

**7.** [ ] Celery tasks can have retry logic.

**8.** [ ] Redis can be used as both a broker and result backend.

**9.** [ ] Flower is used for Celery monitoring.

**10.** [ ] Celery tasks are executed immediately when called.

---

## Answer Key: Quiz 6

| # | Answer | Explanation |
|---|--------|-------------|
| 1 | C | Async enables non-blocking I/O operations |
| 2 | A | Celery is the most common background task library |
| 3 | B | A message broker stores tasks in a queue |
| 4 | B | The command starts a Celery worker with the specified app |
| 5 | B | Celery Beat schedules periodic tasks |
| 6 | False | Async views are for I/O-bound, not CPU-bound operations |
| 7 | True | Celery tasks can have retry logic with `max_retries` |
| 8 | True | Redis can serve as both broker and result backend |
| 9 | True | Flower provides a web interface for Celery monitoring |
| 10 | False | Celery tasks are enqueued and executed by workers asynchronously |

---

# PART 7: TESTING, DEBUGGING & QUALITY ASSURANCE

## Quiz 7: Testing & Quality

### Multiple Choice

**1. What is the recommended testing framework for Flask?**
- A) unittest
- B) pytest
- C) nose
- D) doctest

**2. What is a fixture in pytest?**
- A) A test case
- B) A setup function
- C) An assertion
- D) A mock object

**3. What does test coverage measure?**
- A) How many tests pass
- B) How much code is tested
- C) How fast tests run
- D) How many bugs are found

**4. Which tool is used for code linting?**
- A) Black
- B) Ruff
- C) mypy
- D) pytest

**5. What is the purpose of pre-commit hooks?**
- A) To run code analysis before commits
- B) To commit code automatically
- C) To deploy to production
- D) To run tests after commits

### True/False

**6.** [ ] Unit tests should be fast and isolated.

**7.** [ ] Integration tests require a real database.

**8.** [ ] Coverage should always be 100%.

**9.** [ ] Print debugging is the only way to debug Flask apps.

**10.** [ ] Type checking helps catch errors early.

---

## Answer Key: Quiz 7

| # | Answer | Explanation |
|---|--------|-------------|
| 1 | B | pytest is the recommended testing framework |
| 2 | B | Fixtures provide setup and teardown functionality |
| 3 | B | Coverage measures the percentage of code executed by tests |
| 4 | B | Ruff is a fast Python linter |
| 5 | A | Pre-commit hooks run checks before code is committed |
| 6 | True | Unit tests should be fast and isolated |
| 7 | True | Integration tests typically require a database |
| 8 | False | 100% coverage is not always necessary or practical |
| 9 | False | Many debugging methods exist (pdb, logging, debugger) |
| 10 | True | Type checking catches type-related errors early |

---

# PART 8: PRODUCTION DEPLOYMENT, DEVOPS & MONITORING

## Quiz 8: Deployment & DevOps

### Multiple Choice

**1. Which server is recommended for production Flask applications?**
- A) Flask development server
- B) Gunicorn
- C) Apache
- D) Node.js

**2. What is the role of Nginx in a production setup?**
- A) To run the Flask application
- B) To serve static files and reverse proxy
- C) To manage the database
- D) To handle background tasks

**3. What is Docker used for?**
- A) Running tests
- B) Containerizing applications
- C) Managing databases
- D) Monitoring applications

**4. What does CI/CD stand for?**
- A) Continuous Integration / Continuous Deployment
- B) Code Integration / Code Deployment
- C) Continuous Implementation / Continuous Delivery
- D) Code Inspection / Code Distribution

**5. What is a health check endpoint used for?**
- A) Testing API performance
- B) Monitoring application health
- C) Checking user authentication
- D) Validating database schema

### True/False

**6.** [ ] The Flask development server is suitable for production.

**7.** [ ] Docker ensures consistent environments.

**8.** [ ] CI/CD pipelines should run tests before deployment.

**9.** [ ] Logging is not necessary in production.

**10.** [ ] Horizontal scaling adds more server instances.

---

## Answer Key: Quiz 8

| # | Answer | Explanation |
|---|--------|-------------|
| 1 | B | Gunicorn is a production WSGI server for Flask |
| 2 | B | Nginx serves static files and acts as a reverse proxy |
| 3 | B | Docker containerizes applications with their dependencies |
| 4 | A | CI/CD stands for Continuous Integration / Continuous Deployment |
| 5 | B | Health checks monitor application status |
| 6 | False | Flask development server is not suitable for production |
| 7 | True | Docker ensures consistent environments across deployments |
| 8 | True | CI/CD pipelines should run tests before deployment |
| 9 | False | Logging is essential for monitoring and troubleshooting |
| 10 | True | Horizontal scaling adds more server instances |

---

# MIDTERM EXAM

## Comprehensive Exam (Parts 1-4)

### Multiple Choice (40 questions)

**1. What is Flask?**
- A) A database management system
- B) A microframework for web applications
- C) A frontend framework
- D) An operating system

**2. Which pattern is used to create Flask applications?**
- A) Singleton
- B) Application Factory
- C) Observer
- D) MVC

**3. What is the purpose of Blueprints?**
- A) Database management
- B) Organizing routes
- C) Authentication
- D) Template rendering

**4. Which command activates a virtual environment on Windows?**
- A) `source venv/bin/activate`
- B) `venv\Scripts\activate`
- C) `activate venv`
- D) `venv activate`

**5. What does the `@app.route()` decorator do?**
- A) Creates a database table
- B) Maps a URL to a function
- C) Renders a template
- D) Handles form data

**6. Which function generates URLs dynamically?**
- A) `url_create()`
- B) `url_for()`
- C) `generate_url()`
- D) `get_url()`

**7. What is Jinja2 used for?**
- A) Database queries
- B) Template rendering
- C) Authentication
- D) File uploads

**8. Which tag is used for conditionals in Jinja2?**
- A) `{{ if }}`
- B) `{% if %}`
- C) `{# if #}`
- D) `$(if)`

**9. What is CSRF protection?**
- A) SQL injection prevention
- B) Cross-site request forgery prevention
- C) XSS prevention
- D) Password encryption

**10. Which is NOT a valid HTTP method?**
- A) GET
- B) POST
- C) SEND
- D) DELETE

**11. What is the purpose of flash messages?**
- A) Database queries
- B) User feedback
- C) Authentication
- D) Template rendering

**12. Which object contains URL parameters?**
- A) `request.form`
- B) `request.args`
- C) `request.json`
- D) `request.data`

**13. What is SQLAlchemy?**
- A) A web server
- B) An ORM
- C) A template engine
- D) A testing framework

**14. What does `db.Column(db.String(50), unique=True)` create?**
- A) A nullable column
- B) A unique string column
- C) A primary key
- D) A foreign key

**15. What is a one-to-many relationship?**
- A) One record related to many records in another table
- B) One record related to one record
- C) Many records related to many records
- D) No relationship

**16. What is the N+1 query problem?**
- A) Too many tables
- B) Too many indexes
- C) Additional queries for related data
- D) Slow queries

**17. Which command creates a migration?**
- A) `flask db init`
- B) `flask db migrate`
- C) `flask db upgrade`
- D) `flask db create`

**18. What is Flask-Login used for?**
- A) Database management
- B) User session management
- C) Template rendering
- D) API creation

**19. What does `UserMixin` provide?**
- A) Password hashing
- B) Authentication methods
- C) Database connection
- D) Form validation

**20. Which function hashes passwords?**
- A) `hash_password()`
- B) `generate_password_hash()`
- C) `encrypt_password()`
- D) `secure_password()`

**21. What is the purpose of RBAC?**
- A) Database optimization
- B) User authorization
- C) Template rendering
- D) API creation

**22. Which security header enforces HTTPS?**
- A) X-Frame-Options
- B) HSTS
- C) CSP
- D) X-Content-Type-Options

**23. What does `@login_required` do?**
- A) Creates a login form
- B) Protects a route
- C) Renders a template
- D) Hashes a password

**24. Which is NOT a valid WTForms field?**
- A) StringField
- B) PasswordField
- C) DatabaseField
- D) SubmitField

**25. What is the purpose of `.env` files?**
- A) Template storage
- B) Environment variables
- C) Database storage
- D) Static files

**26. Which is NOT a Flask extension?**
- A) Flask-SQLAlchemy
- B) Flask-Login
- C) Flask-WTF
- D) Django-ORM

**27. What does `url_for()` do?**
- A) Creates a URL from parameters
- B) Renders a template
- C) Redirects to a URL
- D) Opens a URL

**28. What is the default port for Flask development server?**
- A) 3000
- B) 5000
- C) 8000
- D) 8080

**29. What is a Blueprint?**
- A) A database model
- B) A modular route component
- C) A template
- D) A form

**30. Which tool is used for code formatting?**
- A) Ruff
- B) Black
- C) mypy
- D) pytest

**31. What is the purpose of `db.session.commit()`?**
- A) Rolls back changes
- B) Saves changes to database
- C) Starts a new session
- D) Closes the connection

**32. What is a foreign key?**
- A) A primary key
- B) A reference to another table
- C) An index
- D) A constraint

**33. What does `joinedload()` do?**
- A) Lazy loading
- B) Eager loading
- C) No loading
- D) Delayed loading

**34. What is the purpose of Alembic?**
- A) Database migrations
- B) Template rendering
- C) Authentication
- D) API creation

**35. Which is NOT a session protection level?**
- A) basic
- B) strong
- C) advanced
- D) None

**36. What does `check_password_hash()` do?**
- A) Hashes a password
- B) Verifies a password
- C) Encrypts a password
- D) Decrypts a password

**37. What is a decorator in Python?**
- A) A database table
- B) A function that modifies another function
- C) A template tag
- D) A form field

**38. What is the purpose of `__repr__()` in models?**
- A) Database query
- B) String representation
- C) Template rendering
- D) Form validation

**39. Which is NOT a valid database column type?**
- A) Integer
- B) String
- C) Boolean
- D) HTML

**40. What is lazy loading?**
- A) Loading data when needed
- B) Loading data immediately
- C) Not loading data
- D) Loading all data

### True/False (20 questions)

**41.** [ ] Flask is a full-stack framework.

**42.** [ ] The Application Factory pattern is optional.

**43.** [ ] Blueprints can be reused across applications.

**44.** [ ] Environment variables should be hardcoded.

**45.** [ ] Jinja2 automatically escapes HTML.

**46.** [ ] CSRF protection is automatically enabled in Flask.

**47.** [ ] SQLAlchemy requires raw SQL queries.

**48.** [ ] Migrations can be rolled back.

**49.** [ ] `db.create_all()` should be used in production.

**50.** [ ] Flask-Login automatically hashes passwords.

**51.** [ ] Password hashing is reversible.

**52.** [ ] CSRF tokens prevent XSS attacks.

**53.** [ ] Security headers are only for production.

**54.** [ ] GET requests should modify data.

**55.** [ ] POST requests should not modify data.

**56.** [ ] The request object is thread-local.

**57.** [ ] SQLAlchemy supports multiple databases.

**58.** [ ] Indexes improve query performance.

**59.** [ ] Foreign keys enforce data integrity.

**60.** [ ] Sessions are stored in cookies.

---

## Midterm Answer Key

### Multiple Choice Answers

| # | Answer | # | Answer |
|---|--------|---|--------|
| 1 | B | 21 | B |
| 2 | B | 22 | B |
| 3 | B | 23 | B |
| 4 | B | 24 | C |
| 5 | B | 25 | B |
| 6 | B | 26 | D |
| 7 | B | 27 | A |
| 8 | B | 28 | B |
| 9 | B | 29 | B |
| 10 | C | 30 | B |
| 11 | B | 31 | B |
| 12 | B | 32 | B |
| 13 | B | 33 | B |
| 14 | B | 34 | A |
| 15 | A | 35 | C |
| 16 | C | 36 | B |
| 17 | B | 37 | B |
| 18 | B | 38 | B |
| 19 | B | 39 | D |
| 20 | B | 40 | A |

### True/False Answers

| # | Answer | Explanation |
|---|--------|-------------|
| 41 | False | Flask is a microframework, not full-stack |
| 42 | True | Application Factory is recommended but optional |
| 43 | True | Blueprints are reusable components |
| 44 | False | Environment variables should not be hardcoded |
| 45 | True | Jinja2 auto-escapes HTML for security |
| 46 | False | CSRF must be enabled with Flask-WTF |
| 47 | False | SQLAlchemy provides ORM and SQL expression |
| 48 | True | Migrations support rollbacks |
| 49 | False | Use migrations in production |
| 50 | False | Flask-Login doesn't hash passwords |
| 51 | False | Password hashing is one-way |
| 52 | False | CSRF prevents CSRF, not XSS |
| 53 | False | Security headers should be used everywhere |
| 54 | False | GET should be safe (not modify data) |
| 55 | False | POST modifies data |
| 56 | True | Request is thread-local |
| 57 | True | SQLAlchemy supports multiple databases |
| 58 | True | Indexes improve query performance |
| 59 | True | Foreign keys enforce referential integrity |
| 60 | False | Sessions are stored server-side, cookie contains session ID |

---

# FINAL EXAM

## Comprehensive Exam (All 8 Parts)

### Multiple Choice (50 questions)

**1. Which Flask pattern uses a function to create the application?**
- A) Singleton Pattern
- B) Application Factory Pattern
- C) Observer Pattern
- D) MVC Pattern

**2. What is the primary purpose of Blueprints?**
- A) Database management
- B) Route organization
- C) Template rendering
- D) Authentication

**3. Which tool is used for type checking?**
- A) Ruff
- B) Black
- C) mypy
- D) isort

**4. What command activates a virtual environment on macOS/Linux?**
- A) `venv activate`
- B) `source venv/bin/activate`
- C) `venv\Scripts\activate`
- D) `activate venv`

**5. What does `url_for('profile', username='john')` return?**
- A) `/profile?username=john`
- B) `/profile/john`
- C) `/user/john`
- D) `/profile?user=john`

**6. What is the purpose of CSRF tokens?**
- A) Password hashing
- B) Cross-site request forgery prevention
- C) XSS prevention
- D) Session management

**7. Which library is used as the primary ORM with Flask?**
- A) Django ORM
- B) SQLAlchemy
- C) Peewee
- D) SQLite3

**8. What is the N+1 query problem?**
- A) Too many tables
- B) Additional queries for related data
- C) Too many indexes
- D) Slow queries

**9. Which command creates a migration?**
- A) `flask db init`
- B) `flask db migrate`
- C) `flask db upgrade`
- D) `flask db create`

**10. What is Flask-Login used for?**
- A) Database management
- B) User session management
- C) Template rendering
- D) API creation

**11. Which function hashes passwords in Werkzeug?**
- A) `hash_password()`
- B) `generate_password_hash()`
- C) `encrypt_password()`
- D) `secure_password()`

**12. What does REST stand for?**
- A) Representational State Transfer
- B) Request State Transfer
- C) Representational Server Technology
- D) Response State Transfer

**13. Which HTTP method is idempotent?**
- A) POST
- B) PUT
- C) PATCH
- D) All of the above

**14. What is the correct status code for "Created"?**
- A) 200
- B) 201
- C) 202
- D) 204

**15. Which library is used for serialization in Flask APIs?**
- A) SQLAlchemy
- B) Marshmallow
- C) Django REST
- D) Flask-RESTful

**16. What is the primary benefit of async programming?**
- A) Faster CPU processing
- B) Non-blocking I/O
- C) Better memory usage
- D) Simpler code

**17. Which library is commonly used for background tasks?**
- A) Celery
- B) Redis
- C) SQLAlchemy
- D) Flask-Async

**18. What is a message broker?**
- A) A database
- B) A queue that stores tasks
- C) A web server
- D) A cache

**19. Which command starts a Celery worker?**
- A) `celery start`
- B) `celery -A app.celery_worker.celery worker`
- C) `celery run`
- D) `celery work`

**20. What is Celery Beat used for?**
- A) Running tasks immediately
- B) Scheduling periodic tasks
- C) Monitoring tasks
- D) Storing results

**21. Which is the recommended testing framework for Flask?**
- A) unittest
- B) pytest
- C) nose
- D) doctest

**22. What is a fixture in pytest?**
- A) A test case
- B) A setup function
- C) An assertion
- D) A mock object

**23. What does test coverage measure?**
- A) How many tests pass
- B) How much code is tested
- C) How fast tests run
- D) How many bugs are found

**24. Which tool is used for linting?**
- A) Black
- B) Ruff
- C) mypy
- D) pytest

**25. What is the purpose of pre-commit hooks?**
- A) Run code analysis before commits
- B) Commit code automatically
- C) Deploy to production
- D) Run tests after commits

**26. Which server is recommended for production?**
- A) Flask development server
- B) Gunicorn
- C) Apache
- D) Node.js

**27. What is the role of Nginx in production?**
- A) Run the Flask application
- B) Serve static files and reverse proxy
- C) Manage the database
- D) Handle background tasks

**28. What does CI/CD stand for?**
- A) Continuous Integration / Continuous Deployment
- B) Code Integration / Code Deployment
- C) Continuous Implementation / Continuous Delivery
- D) Code Inspection / Code Distribution

**29. What is a health check endpoint?**
- A) API performance test
- B) Application status monitor
- C) User authentication
- D) Database validation

**30. Which is NOT a valid HTTP method?**
- A) GET
- B) POST
- C) SEND
- D) DELETE

**31. What is Jinja2?**
- A) Database ORM
- B) Template engine
- C) Web server
- D) Authentication system

**32. What is the purpose of `db.relationship()`?**
- A) Foreign key creation
- B) Model relationship definition
- C) Index creation
- D) Column addition

**33. What is a many-to-many relationship?**
- A) One record to many
- B) Many records to one
- C) Many records to many
- D) No relationship

**34. What is lazy loading?**
- A) Loading data when needed
- B) Loading data immediately
- C) Not loading data
- D) Loading all data

**35. What does `joinedload()` do?**
- A) Lazy loading
- B) Eager loading
- C) No loading
- D) Delayed loading

**36. What is the purpose of RBAC?**
- A) Database optimization
- B) User authorization
- C) Template rendering
- D) API creation

**37. Which security header enforces HTTPS?**
- A) X-Frame-Options
- B) HSTS
- C) CSP
- D) X-Content-Type-Options

**38. What does `@login_required` do?**
- A) Creates a login form
- B) Protects a route
- C) Renders a template
- D) Hashes a password

**39. What is the purpose of `.env` files?**
- A) Template storage
- B) Environment variables
- C) Database storage
- D) Static files

**40. Which is NOT a valid database column type?**
- A) Integer
- B) String
- C) Boolean
- D) HTML

**41. What does `db.session.commit()` do?**
- A) Rolls back changes
- B) Saves changes to database
- C) Starts a new session
- D) Closes the connection

**42. What is a foreign key?**
- A) A primary key
- B) A reference to another table
- C) An index
- D) A constraint

**43. What is the purpose of Alembic?**
- A) Database migrations
- B) Template rendering
- C) Authentication
- D) API creation

**44. What is the Flask development server port?**
- A) 3000
- B) 5000
- C) 8000
- D) 8080

**45. Which command initializes migrations?**
- A) `flask db init`
- B) `flask db migrate`
- C) `flask db upgrade`
- D) `flask db create`

**46. What is the purpose of `url_for()`?**
- A) Creates a URL
- B) Renders a template
- C) Redirects to a URL
- D) Opens a URL

**47. What is a Blueprint?**
- A) A database model
- B) A modular route component
- C) A template
- D) A form

**48. What does `UserMixin` provide?**
- A) Password hashing
- B) Authentication methods
- C) Database connection
- D) Form validation

**49. What is rate limiting?**
- A) Increasing performance
- B) Preventing abuse
- C) Caching responses
- D) Encrypting data

**50. What is Docker used for?**
- A) Running tests
- B) Containerizing applications
- C) Managing databases
- D) Monitoring applications

### True/False (25 questions)

**51.** [ ] Flask is a full-stack framework.

**52.** [ ] The Application Factory pattern is optional.

**53.** [ ] Blueprints can be reused.

**54.** [ ] Environment variables should be hardcoded.

**55.** [ ] Jinja2 auto-escapes HTML.

**56.** [ ] CSRF is automatically enabled.

**57.** [ ] SQLAlchemy supports multiple databases.

**58.** [ ] Migrations support rollbacks.

**59.** [ ] `db.create_all()` should be used in production.

**60.** [ ] Flask-Login hashes passwords.

**61.** [ ] Password hashing is reversible.

**62.** [ ] CSRF prevents XSS attacks.

**63.** [ ] Security headers are only for production.

**64.** [ ] GET requests should modify data.

**65.** [ ] POST requests should not modify data.

**66.** [ ] The request object is thread-local.

**67.** [ ] Async views are for CPU operations.

**68.** [ ] Celery tasks can have retry logic.

**69.** [ ] Redis can be a broker and backend.

**70.** [ ] Unit tests should be fast.

**71.** [ ] Integration tests use real databases.

**72.** [ ] Coverage should always be 100%.

**73.** [ ] The Flask dev server is for production.

**74.** [ ] Docker ensures consistent environments.

**75.** [ ] CI/CD pipelines run tests before deployment.

---

## Final Exam Answer Key

### Multiple Choice Answers

| # | Answer | # | Answer | # | Answer |
|---|--------|---|--------|---|--------|
| 1 | B | 18 | B | 35 | B |
| 2 | B | 19 | B | 36 | B |
| 3 | C | 20 | B | 37 | B |
| 4 | B | 21 | B | 38 | B |
| 5 | B | 22 | B | 39 | B |
| 6 | B | 23 | B | 40 | D |
| 7 | B | 24 | B | 41 | B |
| 8 | B | 25 | A | 42 | B |
| 9 | B | 26 | B | 43 | A |
| 10 | B | 27 | B | 44 | B |
| 11 | B | 28 | A | 45 | A |
| 12 | A | 29 | B | 46 | A |
| 13 | B | 30 | C | 47 | B |
| 14 | B | 31 | B | 48 | B |
| 15 | B | 32 | B | 49 | B |
| 16 | B | 33 | C | 50 | B |
| 17 | A | 34 | A | | |

### True/False Answers

| # | Answer | # | Answer |
|---|--------|---|--------|
| 51 | False | 64 | False |
| 52 | True | 65 | False |
| 53 | True | 66 | True |
| 54 | False | 67 | False |
| 55 | True | 68 | True |
| 56 | False | 69 | True |
| 57 | True | 70 | True |
| 58 | True | 71 | True |
| 59 | False | 72 | False |
| 60 | False | 73 | False |
| 61 | False | 74 | True |
| 62 | False | 75 | True |
| 63 | False | | |

---

# PRACTICAL EXERCISES

## Exercise 1: Build a Simple Blog API (2 hours)

**Requirements:**
1. Create a Flask API with the following endpoints:
   - `GET /api/posts` - List all posts
   - `POST /api/posts` - Create a new post
   - `GET /api/posts/<id>` - Get a single post
   - `PUT /api/posts/<id>` - Update a post
   - `DELETE /api/posts/<id>` - Delete a post

2. Use SQLAlchemy for data persistence
3. Use Marshmallow for serialization
4. Add authentication with JWT
5. Implement rate limiting

**Evaluation Criteria:**
- Code organization (25%)
- Functionality (25%)
- Error handling (20%)
- Testing (15%)
- Documentation (15%)

**Solution Outline:**
```python
# models.py
class Post(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(200), nullable=False)
    content = db.Column(db.Text, nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'))

# schemas.py
class PostSchema(SQLAlchemyAutoSchema):
    class Meta:
        model = Post

# api.py
@api_bp.route('/posts', methods=['GET'])
@token_required
def list_posts():
    posts = Post.query.all()
    return jsonify(PostSchema(many=True).dump(posts))

@api_bp.route('/posts', methods=['POST'])
@token_required
def create_post():
    data = request.get_json()
    post = Post(**data)
    db.session.add(post)
    db.session.commit()
    return jsonify(PostSchema().dump(post)), 201
```

---

## Exercise 2: Deploy a Flask App with Docker (1 hour)

**Requirements:**
1. Create a Dockerfile for a Flask application
2. Create a docker-compose.yml with:
   - Flask app service
   - PostgreSQL database
   - Redis cache
3. Configure environment variables
4. Set up health checks

**Evaluation Criteria:**
- Dockerfile quality (25%)
- docker-compose configuration (25%)
- Environment configuration (25%)
- Health checks (25%)

**Solution Outline:**
```dockerfile
# Dockerfile
FROM python:3.13-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
CMD ["gunicorn", "-c", "gunicorn.conf.py", "run:app"]
```

```yaml
# docker-compose.yml
version: '3.8'
services:
  web:
    build: .
    ports:
      - "8000:8000"
    environment:
      - FLASK_ENV=production
      - DATABASE_URL=postgresql://user:pass@db:5432/app
    depends_on:
      - db
      - redis
  db:
    image: postgres:15
    environment:
      - POSTGRES_USER=user
      - POSTGRES_PASSWORD=pass
      - POSTGRES_DB=app
  redis:
    image: redis:7-alpine
```

---

## Exercise 3: Authentication System (1.5 hours)

**Requirements:**
1. Implement user registration
2. Implement login with JWT
3. Implement logout (invalidate token)
4. Add email verification
5. Add password reset

**Evaluation Criteria:**
- Security (25%)
- Functionality (25%)
- Error handling (20%)
- Code quality (15%)
- Testing (15%)

**Solution Outline:**
```python
# auth.py
@auth_bp.route('/register', methods=['POST'])
def register():
    data = request.get_json()
    user = User(**data)
    user.set_password(data['password'])
    db.session.add(user)
    db.session.commit()
    
    # Send verification email (background)
    send_verification_email.delay(user.id)
    
    return jsonify({'message': 'User created'}), 201

@auth_bp.route('/login', methods=['POST'])
def login():
    user = User.query.filter_by(email=request.json['email']).first()
    if user and user.check_password(request.json['password']):
        token = generate_token(user.id)
        return jsonify({'token': token})
    return jsonify({'error': 'Invalid credentials'}), 401
```

---

# RUBRICS

## Practical Exercise Grading Rubric

| Criteria | Excellent (90-100%) | Good (70-89%) | Needs Improvement (<70%) |
|----------|---------------------|---------------|-------------------------|
| **Code Organization** | Clear structure, follows best practices, well-commented | Mostly organized, some issues | Disorganized, hard to follow |
| **Functionality** | All features work correctly | Most features work | Major features broken |
| **Error Handling** | Comprehensive error handling, clear messages | Basic error handling | Minimal or no error handling |
| **Testing** | Comprehensive test coverage, edge cases | Basic tests | Few or no tests |
| **Documentation** | Complete documentation, examples | Partial documentation | Minimal documentation |

## Coding Style Rubric

| Criteria | Excellent (90-100%) | Good (70-89%) | Needs Improvement (<70%) |
|----------|---------------------|---------------|-------------------------|
| **Naming** | Clear, consistent, descriptive | Mostly consistent | Inconsistent, unclear |
| **Formatting** | Consistent, follows PEP 8 | Mostly consistent | Inconsistent |
| **Type Hints** | Comprehensive type hints | Some type hints | No type hints |
| **Comments** | Clear, helpful comments | Some comments | No comments |
| **Imports** | Properly organized | Mostly organized | Disorganized |

---

# ADDITIONAL RESOURCES

## Recommended Reading

1. **Flask Documentation** - https://flask.palletsprojects.com
2. **SQLAlchemy Documentation** - https://www.sqlalchemy.org
3. **Jinja Documentation** - https://jinja.palletsprojects.com
4. **OWASP Cheat Sheets** - https://cheatsheetseries.owasp.org
5. **REST API Tutorial** - https://restfulapi.net

## Practice Projects

1. **Blog Platform** - Users, posts, comments, categories
2. **Task Manager** - Tasks, users, teams, deadlines
3. **E-commerce API** - Products, cart, orders, payments
4. **Social Media App** - Posts, likes, comments, followers
5. **Project Management** - Projects, tasks, sprints, reports

## Interview Questions

1. What is the request-response cycle in Flask?
2. How do you handle database migrations?
3. What are the differences between Flask and Django?
4. How do you implement authentication in Flask?
5. What is the Application Factory pattern?
6. How do you handle errors in Flask?
7. What are Blueprints and why are they useful?
8. How do you optimize Flask applications?
9. What is the N+1 query problem and how do you solve it?
10. How do you deploy Flask applications?

---

**End of Test Bank**
