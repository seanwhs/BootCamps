# Mastering Django 6: Quiz and Test Bank

## Full-Stack Web Development with Python

---

# Welcome!

This quiz and test bank is designed to assess understanding of the Mastering Django 6 series. It contains:

1. **Part Quizzes** — Short quizzes for each part (10 questions each)
2. **Midterm Exam** — Comprehensive exam covering Parts 1-5 (50 questions)
3. **Final Exam** — Comprehensive exam covering Parts 1-10 (100 questions)
4. **Answer Keys** — Complete answer keys for all assessments
5. **Practical Exercises** — Hands-on coding challenges

**How to use this test bank:**
- Take quizzes after completing each part
- Use the midterm as a progress check after Part 5
- Use the final exam as a comprehensive assessment
- The practical exercises can be used as take-home assignments

---

# Part 1 Quiz: Django Fundamentals

## Multiple Choice (1 point each)

**1. What command creates a new Django project?**
- A) `django-admin startapp config .`
- B) `django-admin startproject config .`
- C) `python manage.py startproject config .`
- D) `django-create project config .`

**2. What is the purpose of `manage.py`?**
- A) It contains the project's settings
- B) It defines URL patterns
- C) It's the command-line utility for Django
- D) It manages database migrations only

**3. In Django's MVT architecture, what does the "V" stand for?**
- A) Visual
- B) Validator
- C) View
- D) Variable

**4. Which template tag is used to display a variable in Django templates?**
- A) `{% variable %}`
- B) `{{ variable }}`
- C) `# variable #`
- D) `$variable$`

**5. What is the correct way to extend a base template?**
- A) `{% include 'base.html' %}`
- B) `{% load 'base.html' %}`
- C) `{% extends 'base.html' %}`
- D) `{% inherit 'base.html' %}`

**6. Which file contains all of your Django project's settings?**
- A) `manage.py`
- B) `urls.py`
- C) `settings.py`
- D) `wsgi.py`

**7. What is the purpose of `app_name` in `urls.py`?**
- A) It sets the application's display name
- B) It creates a namespace for URL reversing
- C) It defines the app's database table name
- D) It configures the app's middleware

**8. Which command runs the Django development server?**
- A) `python manage.py run`
- B) `python manage.py start`
- C) `python manage.py runserver`
- D) `python manage.py serve`

**9. What is the difference between a project and an app in Django?**
- A) A project is the entire website, apps are specific features
- B) A project is a database, apps are tables
- C) A project is frontend, apps are backend
- D) There is no difference

**10. Which template tag generates a URL from a view name?**
- A) `{% link 'view_name' %}`
- B) `{% url 'view_name' %}`
- C) `{% path 'view_name' %}`
- D) `{% route 'view_name' %}`

---

# Part 2 Quiz: Models and Databases

## Multiple Choice (1 point each)

**1. What is a Django model?**
- A) A class that represents a database table
- B) A function that handles HTTP requests
- C) An HTML template
- D) A URL pattern

**2. Which field type is used for short text (e.g., titles, names)?**
- A) `TextField`
- B) `CharField`
- C) `StringField`
- D) `VarcharField`

**3. What does `on_delete=models.CASCADE` do?**
- A) It prevents deletion of the related object
- B) It sets the foreign key to NULL
- C) It deletes related objects when the parent is deleted
- D) It does nothing

**4. What is the correct workflow for migrations?**
- A) `migrate` → `makemigrations`
- B) `makemigrations` → `migrate`
- C) `createmigration` → `runmigration`
- D) `migration` → `apply`

**5. What is a ForeignKey in Django?**
- A) A one-to-one relationship
- B) A many-to-many relationship
- C) A one-to-many relationship
- D) A field that stores an email address

**6. What command creates a superuser in Django?**
- A) `python manage.py createuser`
- B) `python manage.py createsuperuser`
- C) `python manage.py admin`
- D) `python manage.py useradmin`

**7. Which ORM method retrieves all objects from a model?**
- A) `Model.objects.get_all()`
- B) `Model.objects.all()`
- C) `Model.objects.retrieve()`
- D) `Model.objects.list()`

**8. What does `auto_now_add=True` do on a DateTimeField?**
- A) Updates the field on every save
- B) Sets the field to the current time only on creation
- C) Disables the field
- D) Sets the field to a random time

**9. Which of the following is NOT a valid field relationship in Django?**
- A) `OneToOneField`
- B) `ForeignKey`
- C) `ManyToManyField`
- D) `ZeroToOneField`

**10. What is the purpose of `list_display` in Django Admin?**
- A) It sets the fields displayed in the list view
- B) It defines the search fields
- C) It configures the form layout
- D) It sets permissions for the model

---

# Part 3 Quiz: Forms and CRUD

## Multiple Choice (1 point each)

**1. What is a ModelForm in Django?**
- A) A form that inherits from a model
- B) A form that automatically generates fields from a model
- C) A form that creates a new model
- D) A form that only handles GET requests

**2. Which decorator is used to require authentication for a view?**
- A) `@authenticated`
- B) `@login_required`
- C) `@user_required`
- D) `@secure`

**3. What is the purpose of `{% csrf_token %}` in a form?**
- A) It speeds up form submission
- B) It prevents cross-site request forgery attacks
- C) It validates the user's email
- D) It encrypts form data

**4. Which method is called when a form is valid?**
- A) `form.save()`
- B) `form.is_valid()`
- C) `form.clean()`
- D) `form.validate()`

**5. What does `enctype="multipart/form-data"` do?**
- A) Encrypts form data
- B) Allows file uploads
- C) Compresses form data
- D) Formats data as JSON

**6. What is the purpose of `commit=False` when saving a form?**
- A) It deletes the form
- B) It prevents the form from being saved
- C) It creates an instance without saving to the database
- D) It commits the form to the database

**7. Which message type is used for success messages in Django?**
- A) `messages.warning`
- B) `messages.info`
- C) `messages.success`
- D) `messages.error`

**8. What is the correct way to redirect after form submission?**
- A) `return render(request, 'template.html')`
- B) `return redirect('view_name')`
- C) `return HttpResponseRedirect('view_name')`
- D) `return redirect('view_name')` is correct

**9. What is the purpose of `request.FILES`?**
- A) It contains uploaded files
- B) It contains GET parameters
- C) It contains POST data
- D) It contains session data

**10. Which of the following is NOT a part of CRUD?**
- A) Create
- B) Read
- C) Update
- D) Generate

---

# Part 4 Quiz: Class-Based Views

## Multiple Choice (1 point each)

**1. What is a Class-Based View (CBV) in Django?**
- A) A view defined as a function
- B) A view defined as a class with methods
- C) A view that only handles GET requests
- D) A view that generates JSON responses

**2. Which CBV is used to display a list of objects?**
- A) `DetailView`
- B) `ListView`
- C) `TemplateView`
- D) `FormView`

**3. What is the purpose of `LoginRequiredMixin`?**
- A) It creates a login form
- B) It requires the user to be authenticated
- C) It logs the user out
- D) It registers a new user

**4. How do you specify the template for a CBV?**
- A) `template = 'app/template.html'`
- B) `template_name = 'app/template.html'`
- C) `template_file = 'app/template.html'`
- D) `html = 'app/template.html'`

**5. What does `UserPassesTestMixin` do?**
- A) It passes the user to the template
- B) It runs a custom test to determine access
- C) It tests the user's password
- D) It validates the user's email

**6. Which method in a CBV is used to add extra context data?**
- A) `get_queryset()`
- B) `get_context_data()`
- C) `get_object()`
- D) `get_template()`

**7. What is the purpose of `slug_field` in a DetailView?**
- A) It specifies the field used for the slug
- B) It defines the URL parameter name
- C) It sets the template name
- D) It configures pagination

**8. Which of the following is a CBV for creating new objects?**
- A) `EditView`
- B) `CreateView`
- C) `NewView`
- D) `AddView`

**9. What is `reverse_lazy` used for?**
- A) To reverse strings
- B) To generate URLs lazily (for CBVs)
- C) To redirect to a new page
- D) To lazy load templates

**10. What is the advantage of CBVs over FBVs?**
- A) CBVs are faster
- B) CBVs are more reusable through inheritance
- C) CBVs require less code
- D) CBVs are easier to debug

---

# Part 5 Quiz: Authentication and Users

## Multiple Choice (1 point each)

**1. Which Django app provides authentication functionality?**
- A) `django.contrib.auth`
- B) `django.contrib.admin`
- C) `django.contrib.authentication`
- D) `django.contrib.users`

**2. Which form is used for user registration in Django?**
- A) `RegisterForm`
- B) `SignUpForm`
- C) `UserCreationForm`
- D) `UserRegisterForm`

**3. What is a OneToOneField used for in user profiles?**
- A) To create many-to-many relationships
- B) To create a one-to-one relationship with the User model
- C) To create foreign key relationships
- D) To store passwords securely

**4. Which setting controls where users are redirected after login?**
- A) `LOGIN_URL`
- B) `LOGIN_REDIRECT_URL`
- C) `REDIRECT_URL`
- D) `DEFAULT_REDIRECT`

**5. What is the purpose of Django signals?**
- A) To handle HTTP requests
- B) To trigger actions when events occur
- C) To manage database connections
- D) To render templates

**6. What does `@login_required` do?**
- A) It creates a login form
- B) It requires the user to be authenticated
- C) It logs the user out
- D) It registers a new user

**7. How do you add a custom field to a user model?**
- A) By modifying the User model directly
- B) By creating a Profile model with a OneToOneField
- C) By using the UserCreationForm
- D) By overriding the User model

**8. Which signal is commonly used to create a profile when a user registers?**
- A) `pre_save`
- B) `post_save`
- C) `pre_delete`
- D) `post_delete`

**9. What is the purpose of `fail_silently=True` when sending email?**
- A) It prevents email from being sent
- B) It suppresses exceptions on email failure
- C) It sends email silently
- D) It logs emails to the console

**10. Which of the following is NOT a built-in Django password reset view?**
- A) `PasswordResetView`
- B) `PasswordResetDoneView`
- C) `PasswordResetConfirmView`
- D) `PasswordResetSuccessView`

---

# Midterm Exam (Parts 1-5)

## Multiple Choice (1 point each)

**1. What is Django?**
- A) A programming language
- B) A Python web framework
- C) A database management system
- D) A frontend framework

**2. Which command creates a new Django application?**
- A) `django-admin startapp app_name`
- B) `python manage.py startapp app_name`
- C) `django-create app app_name`
- D) `python manage.py createapp app_name`

**3. In Django's MVT architecture, what does the "T" stand for?**
- A) Test
- B) Table
- C) Template
- D) Tag

**4. Which of the following is NOT a valid template tag?**
- A) `{% if %}`
- B) `{% for %}`
- C) `{% while %}`
- D) `{% block %}`

**5. What is the primary key of a Django model by default?**
- A) `name`
- B) `id`
- C) `key`
- D) `primary_key`

**6. Which field type is used for long text (e.g., blog posts)?**
- A) `CharField`
- B) `TextField`
- C) `StringField`
- D) `LongField`

**7. What does `null=True` do in a model field?**
- A) Allows the field to be empty in forms
- B) Allows the database column to store NULL
- C) Sets a default value of None
- D) Disables the field

**8. Which command applies migrations to the database?**
- A) `python manage.py makemigrations`
- B) `python manage.py migrate`
- C) `python manage.py applymigrations`
- D) `python manage.py updatedb`

**9. What is the purpose of `related_name` in a ForeignKey?**
- A) It names the related object in templates
- B) It defines the reverse relationship name
- C) It creates a new field in the model
- D) It sets the field as required

**10. Which method is used to render a template with context?**
- A) `render_to_response()`
- B) `render()`
- C) `template.render()`
- D) `render_template()`

**11. What is a ModelForm?**
- A) A form that models user behavior
- B) A form that automatically generates fields from a model
- C) A form that handles model validation
- D) A form that creates new models

**12. Which of the following is a valid form field type?**
- A) `TextInput`
- B) `CharField`
- C) `StringField`
- D) `TextField`

**13. What is the purpose of `request.method`?**
- A) To check the HTTP method (GET, POST, etc.)
- B) To set the response method
- C) To define the URL method
- D) To configure the template method

**14. Which Django message level is used for errors?**
- A) `messages.info`
- B) `messages.success`
- C) `messages.warning`
- D) `messages.error`

**15. What is the difference between `get()` and `filter()` in the ORM?**
- A) `get()` returns one object, `filter()` returns a queryset
- B) `get()` returns a queryset, `filter()` returns one object
- C) They are interchangeable
- D) `get()` is faster

**16. Which of the following is NOT a common CBV type?**
- A) `ListView`
- B) `DetailView`
- C) `EditView`
- D) `CreateView`

**17. What is the purpose of `paginate_by` in a ListView?**
- A) To enable pagination and set items per page
- B) To set the number of pages
- C) To disable pagination
- D) To set the page template

**18. Which mixin is used to restrict access to specific users?**
- A) `LoginRequiredMixin`
- B) `UserPassesTestMixin`
- C) `PermissionRequiredMixin`
- D) All of the above

**19. What is Django's built-in User model called?**
- A) `UserModel`
- B) `User`
- C) `AuthUser`
- D) `CustomUser`

**20. Which of the following is NOT a valid authentication view?**
- A) `LoginView`
- B) `LogoutView`
- C) `RegisterView`
- D) `PasswordResetView`

**21. What is the purpose of `DEFAULT_FROM_EMAIL`?**
- A) To set the default recipient email
- B) To set the default sender email
- C) To set the default email subject
- D) To set the email template

**22. What is the recommended approach for customizing the User model?**
- A) Modify the existing User model
- B) Create a custom User model or Profile model
- C) Use a third-party package
- D) Override Django's authentication

**23. How do you check if a user is authenticated in a template?**
- A) `{% if user.authenticated %}`
- B) `{% if user.is_authenticated %}`
- C) `{% if user.auth %}`
- D) `{% if user.logged_in %}`

**24. What is the purpose of `reverse_lazy()`?**
- A) To reverse the order of migrations
- B) To generate URLs lazily in class-based views
- C) To lazy load templates
- D) To reverse string operations

**25. What is the correct URL pattern for a post detail view with a slug?**
- A) `path('post/<slug>/', views.post_detail)`
- B) `path('post/<slug:slug>/', views.post_detail)`
- C) `path('post/<slug:slug>/', views.post_detail, name='post_detail')`
- D) `path('post/<str:slug>/', views.post_detail)`

**26. Which of the following is NOT a valid database relationship?**
- A) One-to-One
- B) One-to-Many
- C) Many-to-One
- D) Many-to-Many

**27. What does the `select_related()` method do?**
- A) It selects related objects in a single query (JOIN)
- B) It selects all objects
- C) It filters related objects
- D) It deletes related objects

**28. What is the purpose of `only()` in the ORM?**
- A) To load only specific fields
- B) To filter by one field
- C) To limit the number of results
- D) To order by a single field

**29. Which of the following is a valid field lookup in Django?**
- A) `field__contains`
- B) `field.contains`
- C) `field_contains`
- D) `field-contains`

**30. What is the purpose of `Q` objects in Django?**
- A) To create complex OR queries
- B) To query using raw SQL
- C) To count records
- D) To format queries

**31. What is the default database engine for Django?**
- A) PostgreSQL
- B) MySQL
- C) SQLite
- D) Oracle

**32. Which of the following is NOT a Django model field?**
- A) `DateField`
- B) `TimeField`
- C) `DateTimeField`
- D) `TimestampField`

**33. What does `auto_now=True` do?**
- A) Sets the field on creation only
- B) Updates the field on every save
- C) Disables the field
- D) Sets the field to a random time

**34. How do you create a migration for a specific app?**
- A) `python manage.py makemigrations app_name`
- B) `python manage.py migrate app_name`
- C) `python manage.py makemigration app_name`
- D) `python manage.py create-migration app_name`

**35. What is the purpose of `context_object_name` in a ListView?**
- A) To set the variable name used in the template
- B) To set the model name
- C) To set the template name
- D) To configure the URL pattern

**36. Which of the following is a valid way to add extra context to a CBV?**
- A) `get_queryset()`
- B) `get_context_data()`
- C) `get_object()`
- D) `get_template_names()`

**37. What is the purpose of `post_save` signal?**
- A) To run code after a model is saved
- B) To run code before a model is saved
- C) To run code after a model is deleted
- D) To run code before a model is deleted

**38. What is the recommended way to create a Profile for new users?**
- A) Using a `post_save` signal
- B) Using a `pre_save` signal
- C) Using the admin interface
- D) Using a custom form

**39. Which of the following is NOT a valid Django admin option?**
- A) `list_display`
- B) `list_filter`
- C) `search_fields`
- D) `edit_fields`

**40. What is the purpose of `prepopulated_fields` in admin?**
- A) To auto-populate fields from other fields
- B) To set default values
- C) To validate fields
- D) To format fields

**41. How do you access session data in Django?**
- A) `request.session`
- B) `request.session_data`
- C) `session.request`
- D) `session_data`

**42. What is the purpose of `@transaction.atomic`?**
- A) To make a transaction atomic (all or nothing)
- B) To make a transaction faster
- C) To create a new transaction
- D) To commit a transaction

**43. Which of the following is NOT a valid Django template filter?**
- A) `|date`
- B) `|truncatewords`
- C) `|uppercase`
- D) `|safe`

**44. What is the purpose of `include` in Django templates?**
- A) To include another template
- B) To include static files
- C) To include JavaScript
- D) To include CSS

**45. How do you create a new user in Django?**
- A) `User.objects.create_user()`
- B) `User.objects.create()`
- C) `User.create()`
- D) `User.new()`

**46. What is the purpose of `LoginRequiredMixin` in a CBV?**
- A) It creates a login view
- B) It requires the user to be logged in
- C) It logs the user out
- D) It registers the user

**47. Which of the following is a valid password reset view?**
- A) `PasswordResetRequestView`
- B) `PasswordResetConfirmView`
- C) `PasswordResetView`
- D) All of the above

**48. What is the purpose of `get_absolute_url()` in a model?**
- A) To return the URL of the object
- B) To return the absolute path of the object
- C) To return the object's ID
- D) To return the object's string representation

**49. Which of the following is NOT a valid Django template tag?**
- A) `{% load %}`
- B) `{% include %}`
- C) `{% import %}`
- D) `{% block %}`

**50. What is the purpose of Django's messages framework?**
- A) To display one-time notification messages
- B) To send email messages
- C) To log messages
- D) To display database messages

---

# Part 6 Quiz: Advanced Architecture

## Multiple Choice (1 point each)

**1. What is middleware in Django?**
- A) A framework for building APIs
- B) Code that runs on every request/response
- C) A database abstraction layer
- D) A template engine

**2. What is the purpose of a context processor?**
- A) To process HTTP requests
- B) To add variables to every template's context
- C) To handle form processing
- D) To manage database connections

**3. Which signal runs after a model is saved?**
- A) `pre_save`
- B) `post_save`
- C) `after_save`
- D) `save_signal`

**4. What is a service layer in Django?**
- A) A layer that handles HTTP requests
- B) A layer that contains business logic
- C) A layer that manages templates
- D) A layer that handles database connections

**5. Which of the following is NOT a benefit of a service layer?**
- A) Separation of concerns
- B) Reusability
- C) Faster database queries
- D) Testability

**6. What is the purpose of `__call__` in middleware?**
- A) To process the request and response
- B) To initialize middleware
- C) To register middleware
- D) To destroy middleware

**7. Which of the following is a valid middleware use case?**
- A) Request logging
- B) Authentication checking
- C) Security headers
- D) All of the above

**8. What is the difference between a context processor and a template tag?**
- A) Context processors add global variables; template tags add functionality
- B) There is no difference
- C) Context processors are faster
- D) Template tags are only for loops

**9. How do you register a context processor?**
- A) In `settings.py` under `TEMPLATES`
- B) In `urls.py`
- C) In `models.py`
- D) In `views.py`

**10. What is the purpose of Django signals?**
- A) To handle HTTP requests
- B) To decouple application logic
- C) To manage URLs
- D) To process templates

---

# Part 7 Quiz: Real-World Features

## Multiple Choice (1 point each)

**1. Which setting configures the directory for uploaded files?**
- A) `STATIC_ROOT`
- B) `MEDIA_ROOT`
- C) `UPLOAD_ROOT`
- D) `FILE_ROOT`

**2. Which field type is used for image uploads?**
- A) `FileField`
- B) `ImageField`
- C) `PictureField`
- D) `UploadField`

**3. What is the purpose of `enctype="multipart/form-data"`?**
- A) To encrypt form data
- B) To allow file uploads
- C) To compress form data
- D) To format data as JSON

**4. Which module is used for sending email in Django?**
- A) `django.core.mail`
- B) `django.email`
- C) `django.mail`
- D) `django.sendmail`

**5. What is the purpose of `fail_silently=True` in email sending?**
- A) It prevents email from being sent
- B) It suppresses exceptions on failure
- C) It sends email silently
- D) It logs emails to the console

**6. How do you set session data?**
- A) `request.session['key'] = value`
- B) `session['key'] = value`
- C) `request.session_set('key', value)`
- D) `session.set('key', value)`

**7. What is the purpose of `transaction.atomic()`?**
- A) To make database operations atomic
- B) To make operations faster
- C) To create a new database connection
- D) To delete data

**8. Which of the following is NOT a valid email backend?**
- A) Console
- B) SMTP
- C) File
- D) Database

**9. What is the purpose of sessions in Django?**
- A) To store temporary user data
- B) To store permanent user data
- C) To store database queries
- D) To store template variables

**10. What is a savepoint in a database transaction?**
- A) A point where data is saved
- B) A point where you can roll back part of a transaction
- C) A point where data is committed
- D) A point where connections are closed

---

# Part 8 Quiz: Testing and Quality

## Multiple Choice (1 point each)

**1. Which class is used for Django tests?**
- A) `unittest.TestCase`
- B) `django.test.TestCase`
- C) `django.unittest`
- D) `pytest.TestCase`

**2. What is the purpose of `setUp()` in a test case?**
- A) To clean up after tests
- B) To set up test data before each test
- C) To run tests
- D) To assert conditions

**3. Which method checks if two values are equal?**
- A) `assertEqual()`
- B) `assertSame()`
- C) `assertEquals()`
- D) `assertIs()`

**4. What is the Django test client used for?**
- A) To simulate HTTP requests
- B) To test database connections
- C) To test email sending
- D) To test template rendering

**5. Which of the following is NOT a test assertion?**
- A) `assertContains()`
- B) `assertRedirects()`
- C) `assertTemplateUsed()`
- D) `assertResponse()`

**6. What is the purpose of the `@transaction.atomic` decorator in tests?**
- A) To speed up tests
- B) To roll back database changes after each test
- C) To enable database connections
- D) To disable database operations

**7. How do you check for a 404 response in a test?**
- A) `self.assertEqual(response.status_code, 404)`
- B) `self.assert404(response)`
- C) `self.assertNotFound(response)`
- D) `self.assertStatus(response, 404)`

**8. What is the purpose of logging in Django?**
- A) To record application events
- B) To debug code
- C) To monitor application health
- D) All of the above

**9. Which log level is the most severe?**
- A) DEBUG
- B) INFO
- C) WARNING
- D) ERROR

**10. What is the purpose of `getLogger(__name__)`?**
- A) To create a logger with the module name
- B) To create a global logger
- C) To disable logging
- D) To configure logging settings

---

# Part 9 Quiz: Production Readiness

## Multiple Choice (1 point each)

**1. What is the N+1 query problem?**
- A) One query plus one for each related object
- B) One query for all objects
- C) One query plus one for each table
- D) One query plus one for each database

**2. How do you solve the N+1 query problem?**
- A) Use `select_related()` and `prefetch_related()`
- B) Use `only()` and `defer()`
- C) Use `raw()` queries
- D) Use `extra()` queries

**3. What is the purpose of `select_related()`?**
- A) To join related tables in a single query
- B) To select related objects
- C) To filter related objects
- D) To delete related objects

**4. Which of the following is NOT a caching backend in Django?**
- A) Memcached
- B) Redis
- C) File-based cache
- D) PostgreSQL cache

**5. What is the purpose of `cache_page`?**
- A) To cache the entire page
- B) To cache a single field
- C) To cache database queries
- D) To cache templates

**6. Which setting should be False in production?**
- A) `DEBUG`
- B) `ALLOWED_HOSTS`
- C) `SECRET_KEY`
- D) `DATABASES`

**7. What is HSTS?**
- A) HTTP Strict Transport Security
- B) HTTPS Secure Transport
- C) HTTP Secure Transport System
- D) HTTPS Strict Transport Security

**8. Which of the following is NOT a security header?**
- A) `X-Content-Type-Options`
- B) `X-Frame-Options`
- C) `X-XSS-Protection`
- D) `Content-Type`

**9. What is the purpose of environment variables?**
- A) To store sensitive information outside the codebase
- B) To speed up the application
- C) To configure database connections
- D) To set logging levels

**10. Which of the following is a valid environment variable name?**
- A) `SECRET_KEY`
- B) `secret-key`
- C) `SECRET KEY`
- D) `secret_key`

---

# Part 10 Quiz: Deployment

## Multiple Choice (1 point each)

**1. What is Docker?**
- A) A programming language
- B) A containerization platform
- C) A database system
- D) A web framework

**2. What is a Dockerfile used for?**
- A) To define a Docker image
- B) To run Docker containers
- C) To stop Docker containers
- D) To delete Docker images

**3. What is Gunicorn?**
- A) A web server
- B) A WSGI HTTP server
- C) A database server
- D) A container platform

**4. What is the purpose of Nginx in a Django deployment?**
- A) To serve as a reverse proxy
- B) To serve as a database
- C) To run the Django application
- D) To manage migrations

**5. What is Docker Compose used for?**
- A) To run multiple containers
- B) To build Docker images
- C) To push Docker images
- D) To delete Docker containers

**6. Which of the following is NOT a Gunicorn option?**
- A) `--workers`
- B) `--bind`
- C) `--threads`
- D) `--database`

**7. What is the purpose of `collectstatic` in deployment?**
- A) To collect all static files in one directory
- B) To delete static files
- C) To minify static files
- D) To compress static files

**8. What is a CI/CD pipeline?**
- A) Automated testing and deployment
- B) Manual deployment
- C) Database migration
- D) Code review

**9. Which of the following is a valid Docker command?**
- A) `docker build`
- B) `docker create`
- C) `docker start`
- D) All of the above

**10. What is the purpose of `docker-compose up -d`?**
- A) To start containers in detached mode
- B) To build containers
- C) To stop containers
- D) To delete containers

---

# Final Exam (Parts 1-10)

## Multiple Choice (1 point each)

**1. Which command creates a new Django project?**
- A) `django-admin startapp config .`
- B) `django-admin startproject config .`
- C) `python manage.py startproject config .`
- D) `django-create project config .`

**2. In Django's MVT architecture, what does the "M" stand for?**
- A) Middleware
- B) Model
- C) Module
- D) Migration

**3. Which template tag is used for conditional logic?**
- A) `{% if %}`
- B) `{% when %}`
- C) `{% case %}`
- D) `{% condition %}`

**4. What is the purpose of `manage.py`?**
- A) It contains the project's settings
- B) It defines URL patterns
- C) It's the command-line utility for Django
- D) It manages database migrations only

**5. Which field type is used for short text?**
- A) `TextField`
- B) `CharField`
- C) `StringField`
- D) `VarcharField`

**6. What does `on_delete=models.CASCADE` do?**
- A) It prevents deletion of the related object
- B) It sets the foreign key to NULL
- C) It deletes related objects when the parent is deleted
- D) It does nothing

**7. What is the correct migration workflow?**
- A) `migrate` → `makemigrations`
- B) `makemigrations` → `migrate`
- C) `createmigration` → `runmigration`
- D) `migration` → `apply`

**8. Which decorator is used to require authentication?**
- A) `@authenticated`
- B) `@login_required`
- C) `@user_required`
- D) `@secure`

**9. What is the purpose of `{% csrf_token %}`?**
- A) It speeds up form submission
- B) It prevents cross-site request forgery attacks
- C) It validates the user's email
- D) It encrypts form data

**10. Which CRUD operation retrieves data?**
- A) Create
- B) Read
- C) Update
- D) Delete

**11. What is a Class-Based View (CBV)?**
- A) A view defined as a function
- B) A view defined as a class with methods
- C) A view that only handles GET requests
- D) A view that generates JSON responses

**12. Which CBV is used to display a single object?**
- A) `ListView`
- B) `DetailView`
- C) `TemplateView`
- D) `FormView`

**13. Which form is used for user registration?**
- A) `RegisterForm`
- B) `SignUpForm`
- C) `UserCreationForm`
- D) `UserRegisterForm`

**14. What is a OneToOneField used for?**
- A) Many-to-many relationships
- B) One-to-one relationships
- C) Foreign key relationships
- D) Storing passwords

**15. What is the purpose of signals?**
- A) To handle HTTP requests
- B) To trigger actions when events occur
- C) To manage database connections
- D) To render templates

**16. What is middleware in Django?**
- A) A framework for building APIs
- B) Code that runs on every request/response
- C) A database abstraction layer
- D) A template engine

**17. What is the purpose of a context processor?**
- A) To process HTTP requests
- B) To add variables to every template's context
- C) To handle form processing
- D) To manage database connections

**18. Which field type is used for image uploads?**
- A) `FileField`
- B) `ImageField`
- C) `PictureField`
- D) `UploadField`

**19. How do you set session data?**
- A) `request.session['key'] = value`
- B) `session['key'] = value`
- C) `request.session_set('key', value)`
- D) `session.set('key', value)`

**20. Which class is used for Django tests?**
- A) `unittest.TestCase`
- B) `django.test.TestCase`
- C) `django.unittest`
- D) `pytest.TestCase`

**21. What is the N+1 query problem?**
- A) One query plus one for each related object
- B) One query for all objects
- C) One query plus one for each table
- D) One query plus one for each database

**22. Which setting should be False in production?**
- A) `DEBUG`
- B) `ALLOWED_HOSTS`
- C) `SECRET_KEY`
- D) `DATABASES`

**23. What is Docker?**
- A) A programming language
- B) A containerization platform
- C) A database system
- D) A web framework

**24. What is Gunicorn?**
- A) A web server
- B) A WSGI HTTP server
- C) A database server
- D) A container platform

**25. What is the purpose of Nginx in a Django deployment?**
- A) To serve as a reverse proxy
- B) To serve as a database
- C) To run the Django application
- D) To manage migrations

**26. Which command creates a new Django application?**
- A) `django-admin startapp app_name`
- B) `python manage.py startapp app_name`
- C) `django-create app app_name`
- D) `python manage.py createapp app_name`

**27. What is the primary key of a Django model by default?**
- A) `name`
- B) `id`
- C) `key`
- D) `primary_key`

**28. What does `null=True` do in a model field?**
- A) Allows the field to be empty in forms
- B) Allows the database column to store NULL
- C) Sets a default value of None
- D) Disables the field

**29. What is the purpose of `related_name` in a ForeignKey?**
- A) It names the related object in templates
- B) It defines the reverse relationship name
- C) It creates a new field in the model
- D) It sets the field as required

**30. Which method is used to render a template with context?**
- A) `render_to_response()`
- B) `render()`
- C) `template.render()`
- D) `render_template()`

**31. What is a ModelForm?**
- A) A form that models user behavior
- B) A form that automatically generates fields from a model
- C) A form that handles model validation
- D) A form that creates new models

**32. What is the purpose of `request.method`?**
- A) To check the HTTP method (GET, POST, etc.)
- B) To set the response method
- C) To define the URL method
- D) To configure the template method

**33. What is the difference between `get()` and `filter()` in the ORM?**
- A) `get()` returns one object, `filter()` returns a queryset
- B) `get()` returns a queryset, `filter()` returns one object
- C) They are interchangeable
- D) `get()` is faster

**34. What is the purpose of `paginate_by` in a ListView?**
- A) To enable pagination and set items per page
- B) To set the number of pages
- C) To disable pagination
- D) To set the page template

**35. What is Django's built-in User model called?**
- A) `UserModel`
- B) `User`
- C) `AuthUser`
- D) `CustomUser`

**36. How do you check if a user is authenticated in a template?**
- A) `{% if user.authenticated %}`
- B) `{% if user.is_authenticated %}`
- C) `{% if user.auth %}`
- D) `{% if user.logged_in %}`

**37. What is the purpose of `reverse_lazy()`?**
- A) To reverse the order of migrations
- B) To generate URLs lazily in class-based views
- C) To lazy load templates
- D) To reverse string operations

**38. What is the correct URL pattern for a post detail view with a slug?**
- A) `path('post/<slug>/', views.post_detail)`
- B) `path('post/<slug:slug>/', views.post_detail)`
- C) `path('post/<slug:slug>/', views.post_detail, name='post_detail')`
- D) `path('post/<str:slug>/', views.post_detail)`

**39. What does the `select_related()` method do?**
- A) It selects related objects in a single query (JOIN)
- B) It selects all objects
- C) It filters related objects
- D) It deletes related objects

**40. What is the purpose of `only()` in the ORM?**
- A) To load only specific fields
- B) To filter by one field
- C) To limit the number of results
- D) To order by a single field

**41. What is the purpose of `Q` objects in Django?**
- A) To create complex OR queries
- B) To query using raw SQL
- C) To count records
- D) To format queries

**42. What does `auto_now=True` do?**
- A) Sets the field on creation only
- B) Updates the field on every save
- C) Disables the field
- D) Sets the field to a random time

**43. How do you create a migration for a specific app?**
- A) `python manage.py makemigrations app_name`
- B) `python manage.py migrate app_name`
- C) `python manage.py makemigration app_name`
- D) `python manage.py create-migration app_name`

**44. What is the purpose of `context_object_name` in a ListView?**
- A) To set the variable name used in the template
- B) To set the model name
- C) To set the template name
- D) To configure the URL pattern

**45. What is the purpose of `post_save` signal?**
- A) To run code after a model is saved
- B) To run code before a model is saved
- C) To run code after a model is deleted
- D) To run code before a model is deleted

**46. What is the purpose of `prepopulated_fields` in admin?**
- A) To auto-populate fields from other fields
- B) To set default values
- C) To validate fields
- D) To format fields

**47. How do you access session data in Django?**
- A) `request.session`
- B) `request.session_data`
- C) `session.request`
- D) `session_data`

**48. What is the purpose of `@transaction.atomic`?**
- A) To make a transaction atomic (all or nothing)
- B) To make a transaction faster
- C) To create a new transaction
- D) To commit a transaction

**49. What is the purpose of `include` in Django templates?**
- A) To include another template
- B) To include static files
- C) To include JavaScript
- D) To include CSS

**50. How do you create a new user in Django?**
- A) `User.objects.create_user()`
- B) `User.objects.create()`
- C) `User.create()`
- D) `User.new()`

**51. What is the purpose of `LoginRequiredMixin` in a CBV?**
- A) It creates a login view
- B) It requires the user to be logged in
- C) It logs the user out
- D) It registers the user

**52. Which of the following is a valid password reset view?**
- A) `PasswordResetRequestView`
- B) `PasswordResetConfirmView`
- C) `PasswordResetView`
- D) All of the above

**53. What is the purpose of `get_absolute_url()` in a model?**
- A) To return the URL of the object
- B) To return the absolute path of the object
- C) To return the object's ID
- D) To return the object's string representation

**54. Which of the following is NOT a valid Django template tag?**
- A) `{% load %}`
- B) `{% include %}`
- C) `{% import %}`
- D) `{% block %}`

**55. What is the purpose of Django's messages framework?**
- A) To display one-time notification messages
- B) To send email messages
- C) To log messages
- D) To display database messages

**56. What is a service layer in Django?**
- A) A layer that handles HTTP requests
- B) A layer that contains business logic
- C) A layer that manages templates
- D) A layer that handles database connections

**57. What is the purpose of `__call__` in middleware?**
- A) To process the request and response
- B) To initialize middleware
- C) To register middleware
- D) To destroy middleware

**58. How do you register a context processor?**
- A) In `settings.py` under `TEMPLATES`
- B) In `urls.py`
- C) In `models.py`
- D) In `views.py`

**59. Which setting configures the directory for uploaded files?**
- A) `STATIC_ROOT`
- B) `MEDIA_ROOT`
- C) `UPLOAD_ROOT`
- D) `FILE_ROOT`

**60. Which module is used for sending email in Django?**
- A) `django.core.mail`
- B) `django.email`
- C) `django.mail`
- D) `django.sendmail`

**61. What is the purpose of `fail_silently=True` in email sending?**
- A) It prevents email from being sent
- B) It suppresses exceptions on failure
- C) It sends email silently
- D) It logs emails to the console

**62. What is the purpose of `transaction.atomic()`?**
- A) To make database operations atomic
- B) To make operations faster
- C) To create a new database connection
- D) To delete data

**63. Which method checks if two values are equal?**
- A) `assertEqual()`
- B) `assertSame()`
- C) `assertEquals()`
- D) `assertIs()`

**64. What is the Django test client used for?**
- A) To simulate HTTP requests
- B) To test database connections
- C) To test email sending
- D) To test template rendering

**65. Which of the following is NOT a test assertion?**
- A) `assertContains()`
- B) `assertRedirects()`
- C) `assertTemplateUsed()`
- D) `assertResponse()`

**66. How do you solve the N+1 query problem?**
- A) Use `select_related()` and `prefetch_related()`
- B) Use `only()` and `defer()`
- C) Use `raw()` queries
- D) Use `extra()` queries

**67. Which of the following is NOT a caching backend in Django?**
- A) Memcached
- B) Redis
- C) File-based cache
- D) PostgreSQL cache

**68. What is the purpose of `cache_page`?**
- A) To cache the entire page
- B) To cache a single field
- C) To cache database queries
- D) To cache templates

**69. What is HSTS?**
- A) HTTP Strict Transport Security
- B) HTTPS Secure Transport
- C) HTTP Secure Transport System
- D) HTTPS Strict Transport Security

**70. Which of the following is NOT a security header?**
- A) `X-Content-Type-Options`
- B) `X-Frame-Options`
- C) `X-XSS-Protection`
- D) `Content-Type`

**71. What is a Dockerfile used for?**
- A) To define a Docker image
- B) To run Docker containers
- C) To stop Docker containers
- D) To delete Docker images

**72. What is Docker Compose used for?**
- A) To run multiple containers
- B) To build Docker images
- C) To push Docker images
- D) To delete Docker containers

**73. Which of the following is NOT a Gunicorn option?**
- A) `--workers`
- B) `--bind`
- C) `--threads`
- D) `--database`

**74. What is the purpose of `collectstatic` in deployment?**
- A) To collect all static files in one directory
- B) To delete static files
- C) To minify static files
- D) To compress static files

**75. What is a CI/CD pipeline?**
- A) Automated testing and deployment
- B) Manual deployment
- C) Database migration
- D) Code review

**76. Which of the following is a valid Docker command?**
- A) `docker build`
- B) `docker create`
- C) `docker start`
- D) All of the above

**77. What is the purpose of `docker-compose up -d`?**
- A) To start containers in detached mode
- B) To build containers
- C) To stop containers
- D) To delete containers

**78. What is the difference between a project and an app?**
- A) A project is the entire website, apps are specific features
- B) A project is a database, apps are tables
- C) A project is frontend, apps are backend
- D) There is no difference

**79. Which template tag is used to display a variable?**
- A) `{% variable %}`
- B) `{{ variable }}`
- C) `# variable #`
- D) `$variable$`

**80. What is the correct way to extend a base template?**
- A) `{% include 'base.html' %}`
- B) `{% load 'base.html' %}`
- C) `{% extends 'base.html' %}`
- D) `{% inherit 'base.html' %}`

**81. Which file contains all of your Django project's settings?**
- A) `manage.py`
- B) `urls.py`
- C) `settings.py`
- D) `wsgi.py`

**82. What is the purpose of `app_name` in `urls.py`?**
- A) It sets the application's display name
- B) It creates a namespace for URL reversing
- C) It defines the app's database table name
- D) It configures the app's middleware

**83. Which command runs the Django development server?**
- A) `python manage.py run`
- B) `python manage.py start`
- C) `python manage.py runserver`
- D) `python manage.py serve`

**84. Which template tag generates a URL from a view name?**
- A) `{% link 'view_name' %}`
- B) `{% url 'view_name' %}`
- C) `{% path 'view_name' %}`
- D) `{% route 'view_name' %}`

**85. What is a Django model?**
- A) A class that represents a database table
- B) A function that handles HTTP requests
- C) An HTML template
- D) A URL pattern

**86. Which field type is used for long text?**
- A) `CharField`
- B) `TextField`
- C) `StringField`
- D) `LongField`

**87. Which command creates a superuser in Django?**
- A) `python manage.py createuser`
- B) `python manage.py createsuperuser`
- C) `python manage.py admin`
- D) `python manage.py useradmin`

**88. Which ORM method retrieves all objects from a model?**
- A) `Model.objects.get_all()`
- B) `Model.objects.all()`
- C) `Model.objects.retrieve()`
- D) `Model.objects.list()`

**89. What does `auto_now_add=True` do on a DateTimeField?**
- A) Updates the field on every save
- B) Sets the field to the current time only on creation
- C) Disables the field
- D) Sets the field to a random time

**90. What is the purpose of `list_display` in Django Admin?**
- A) It sets the fields displayed in the list view
- B) It defines the search fields
- C) It configures the form layout
- D) It sets permissions for the model

**91. Which decorator is used to require authentication for a view?**
- A) `@authenticated`
- B) `@login_required`
- C) `@user_required`
- D) `@secure`

**92. What does `enctype="multipart/form-data"` do?**
- A) Encrypts form data
- B) Allows file uploads
- C) Compresses form data
- D) Formats data as JSON

**93. What is the purpose of `commit=False` when saving a form?**
- A) It deletes the form
- B) It prevents the form from being saved
- C) It creates an instance without saving to the database
- D) It commits the form to the database

**94. Which message type is used for success messages?**
- A) `messages.warning`
- B) `messages.info`
- C) `messages.success`
- D) `messages.error`

**95. Which CBV is used to display a list of objects?**
- A) `DetailView`
- B) `ListView`
- C) `TemplateView`
- D) `FormView`

**96. What is the purpose of `LoginRequiredMixin`?**
- A) It creates a login form
- B) It requires the user to be authenticated
- C) It logs the user out
- D) It registers a new user

**97. How do you specify the template for a CBV?**
- A) `template = 'app/template.html'`
- B) `template_name = 'app/template.html'`
- C) `template_file = 'app/template.html'`
- D) `html = 'app/template.html'`

**98. What does `UserPassesTestMixin` do?**
- A) It passes the user to the template
- B) It runs a custom test to determine access
- C) It tests the user's password
- D) It validates the user's email

**99. Which method in a CBV is used to add extra context data?**
- A) `get_queryset()`
- B) `get_context_data()`
- C) `get_object()`
- D) `get_template()`

**100. What is the advantage of CBVs over FBVs?**
- A) CBVs are faster
- B) CBVs are more reusable through inheritance
- C) CBVs require less code
- D) CBVs are easier to debug

---

# Practical Exercises

## Exercise 1: Build a Todo App

**Instructions:** Build a simple Todo application with the following features:

1. A Todo model with fields: title, description, completed, created_at
2. CRUD operations for todos
3. User authentication (users can only see their own todos)
4. A dashboard showing todo statistics
5. AJAX-based completion toggle

**Evaluation Criteria:**
- Models are properly designed (10 points)
- CRUD operations work correctly (15 points)
- User authentication and ownership (10 points)
- Dashboard with statistics (10 points)
- AJAX functionality works (5 points)
- Code quality and organization (10 points)
- Tests are included (10 points)
- Documentation (5 points)
- Deployment (5 points)
- Bonus: API endpoints (10 points)

**Total: 80 points**

---

## Exercise 2: Build a Book Review Site

**Instructions:** Build a book review website with the following features:

1. Book model with title, author, description, cover image
2. Review model with rating (1-5), review text, user
3. Users can add books and reviews
4. Average rating calculation
5. Search and filter by author or rating
6. User dashboard showing their books and reviews

**Evaluation Criteria:**
- Models are properly designed (10 points)
- CRUD operations work correctly (15 points)
- User authentication and ownership (10 points)
- Average rating calculation (10 points)
- Search and filter (10 points)
- User dashboard (10 points)
- Code quality and organization (10 points)
- Tests are included (10 points)
- Documentation (5 points)
- Deployment (5 points)
- Bonus: API endpoints (10 points)

**Total: 100 points**

---

## Exercise 3: Build a Discussion Forum

**Instructions:** Build a discussion forum with the following features:

1. Forum categories
2. Topics with title, content, user, created_at
3. Replies to topics
4. User profiles with avatars
5. Topic voting (upvote/downvote)
6. Notification system (email or in-app)
7. Search across topics and replies
8. Pagination

**Evaluation Criteria:**
- Models are properly designed (10 points)
- CRUD operations work correctly (15 points)
- User authentication and ownership (10 points)
- Voting system (10 points)
- Notifications (10 points)
- Search functionality (10 points)
- User profiles with avatars (5 points)
- Code quality and organization (10 points)
- Tests are included (10 points)
- Documentation (5 points)
- Deployment (5 points)

**Total: 100 points**

---

# Answer Keys

## Part 1 Quiz Answer Key

1. B
2. C
3. C
4. B
5. C
6. C
7. B
8. C
9. A
10. B

## Part 2 Quiz Answer Key

1. A
2. B
3. C
4. B
5. C
6. B
7. B
8. B
9. D
10. A

## Part 3 Quiz Answer Key

1. B
2. B
3. B
4. A
5. B
6. C
7. C
8. B
9. A
10. D

## Part 4 Quiz Answer Key

1. B
2. B
3. B
4. B
5. B
6. B
7. A
8. B
9. B
10. B

## Part 5 Quiz Answer Key

1. A
2. C
3. B
4. B
5. B
6. B
7. B
8. B
9. B
10. D

## Part 6 Quiz Answer Key

1. B
2. B
3. B
4. B
5. C
6. A
7. D
8. A
9. A
10. B

## Part 7 Quiz Answer Key

1. B
2. B
3. B
4. A
5. B
6. A
7. A
8. D
9. A
10. B

## Part 8 Quiz Answer Key

1. B
2. B
3. A
4. A
5. D
6. B
7. A
8. D
9. D
10. A

## Part 9 Quiz Answer Key

1. A
2. A
3. A
4. D
5. A
6. A
7. A
8. D
9. A
10. A

## Part 10 Quiz Answer Key

1. B
2. A
3. B
4. A
5. A
6. D
7. A
8. A
9. D
10. A

## Midterm Exam Answer Key (1-50)

1. B
2. B
3. C
4. C
5. B
6. B
7. B
8. B
9. B
10. B
11. B
12. A
13. A
14. D
15. A
16. C
17. A
18. D
19. B
20. C
21. B
22. B
23. B
24. B
25. C
26. C
27. A
28. A
29. A
30. A
31. C
32. D
33. B
34. A
35. A
36. B
37. A
38. A
39. D
40. A
41. A
42. A
43. C
44. A
45. A
46. B
47. D
48. A
49. C
50. A

## Final Exam Answer Key (1-100)

1. B
2. B
3. A
4. C
5. B
6. C
7. B
8. B
9. B
10. B
11. B
12. B
13. C
14. B
15. B
16. B
17. B
18. B
19. A
20. B
21. A
22. A
23. B
24. B
25. A
26. B
27. B
28. B
29. B
30. B
31. B
32. A
33. A
34. A
35. B
36. B
37. B
38. C
39. A
40. A
41. A
42. B
43. A
44. A
45. A
46. A
47. A
48. A
49. A
50. A
51. B
52. D
53. A
54. C
55. A
56. B
57. A
58. A
59. B
60. A
61. B
62. A
63. A
64. A
65. D
66. A
67. D
68. A
69. A
70. D
71. A
72. A
73. D
74. A
75. A
76. D
77. A
78. A
79. B
80. C
81. C
82. B
83. C
84. B
85. A
86. B
87. B
88. B
89. B
90. A
91. B
92. B
93. C
94. C
95. B
96. B
97. B
98. B
99. B
100. B

---

# Scoring Guide

## Quiz Scoring

| Score | Grade | Interpretation |
|-------|-------|----------------|
| 9-10 | A | Excellent understanding |
| 7-8 | B | Good understanding |
| 5-6 | C | Satisfactory understanding |
| 3-4 | D | Needs improvement |
| 0-2 | F | Review the material |

## Exam Scoring

| Score | Grade | Interpretation |
|-------|-------|----------------|
| 90-100% | A | Outstanding |
| 80-89% | B | Good |
| 70-79% | C | Satisfactory |
| 60-69% | D | Below average |
| <60% | F | Needs comprehensive review |

---

**[END OF QUIZ AND TEST BANK]**
