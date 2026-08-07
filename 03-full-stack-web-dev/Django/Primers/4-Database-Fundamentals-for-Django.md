# Primer 4: Database Fundamentals for Django

## Welcome to the Database Primer!

This primer is designed to give you a solid understanding of databases and how Django interacts with them. You don't need to be a database expert to build Django applications, but understanding these concepts will help you design better models, write efficient queries, and troubleshoot issues.

By the end of this primer, you'll understand how relational databases work, what the Django ORM does, and how to think about data relationships.

---

## P.1: What is a Database?

### The Simple Answer

A database is an organized collection of data. Think of it like a digital filing cabinet:

- **Files** = Database tables
- **Pages** = Rows/records
- **Information on a page** = Columns/fields

### Why Use a Database?

- **Persistence**: Data survives beyond a single request
- **Organization**: Structured, searchable data
- **Relationships**: Data can be linked together
- **Security**: Access control and data integrity
- **Scalability**: Can handle millions of records

---

## P.2: Relational Databases

### What is a Relational Database?

A relational database organizes data into tables with rows and columns. Tables can be linked (related) to each other using keys.

### Anatomy of a Table

```
Table: users
┌────┬───────────┬─────────────────┬──────────┐
│ id │ username  │ email           │ active   │
├────┼───────────┼─────────────────┼──────────┤
│ 1  │ alice     │ alice@email.com │ true     │
│ 2  │ bob       │ bob@email.com   │ true     │
│ 3  │ charlie   │ charlie@email   │ false    │
└────┴───────────┴─────────────────┴──────────┘
    │           │                 │          │
    │           │                 │          │
    ▼           ▼                 ▼          ▼
  Column      Row              Cell       Cell

Primary Key: id (unique identifier for each row)
```

### Key Concepts

**Table**: A collection of related data (like a spreadsheet)
**Row**: A single record (like a row in a spreadsheet)
**Column**: A specific field (like a column in a spreadsheet)
**Primary Key**: A unique identifier for each row (usually `id`)
**Foreign Key**: A reference to a primary key in another table

### Common Data Types

| SQL Type | Description | Example |
|----------|-------------|---------|
| `INTEGER` | Whole numbers | `25`, `-10`, `0` |
| `VARCHAR(n)` | Variable text up to n characters | `"Alice"` |
| `TEXT` | Unlimited text | `"This is a long blog post..."` |
| `BOOLEAN` | True/False | `true`, `false` |
| `DATE` | Calendar date | `2026-03-15` |
| `DATETIME` | Date and time | `2026-03-15 14:30:00` |
| `DECIMAL(p,s)` | Precise decimal numbers | `19.99` |
| `FLOAT` | Approximate decimal numbers | `3.14159` |

---

## P.3: Table Relationships

### One-to-One (1:1)

One record in table A relates to exactly one record in table B.

```
User (1) ─── Profile (1)
   │            │
   │            │
   └────────────┘
```

**Example**: Each user has exactly one profile

```
Users Table
┌────┬──────────┐
│ id │ username │
├────┼──────────┤
│ 1  │ alice    │
│ 2  │ bob      │
└────┴──────────┘

Profiles Table
┌────┬─────────┬─────────────┐
│ id │ user_id │ bio         │
├────┼─────────┼─────────────┤
│ 1  │ 1       │ I love cats │
│ 2  │ 2       │ I love dogs │
└────┴─────────┴─────────────┘
```

**Django**: `OneToOneField`

### One-to-Many (1:N)

One record in table A relates to many records in table B.

```
User (1) ───┬─── Post (many)
            ├─── Post (many)
            └─── Post (many)
```

**Example**: One user can have many posts

```
Users Table
┌────┬──────────┐
│ id │ username │
├────┼──────────┤
│ 1  │ alice    │
│ 2  │ bob      │
└────┴──────────┘

Posts Table
┌────┬──────────────┬───────────┐
│ id │ title        │ user_id   │
├────┼──────────────┼───────────┤
│ 1  │ Hello World  │ 1         │
│ 2  │ Django Rocks │ 1         │
│ 3  │ Python Fun   │ 2         │
└────┴──────────────┴───────────┘
```

**Django**: `ForeignKey` (on the "many" side)

### Many-to-Many (M:N)

Many records in table A relate to many records in table B.

```
Post (many) ───┬─── Tag (many)
               ├─── Tag (many)
               └─── Tag (many)
```

**Example**: A post can have many tags; a tag can belong to many posts

```
Posts Table
┌────┬──────────────┐
│ id │ title        │
├────┼──────────────┤
│ 1  │ Hello World  │
│ 2  │ Django Rocks │
└────┴──────────────┘

Tags Table
┌────┬─────────┐
│ id │ name    │
├────┼─────────┤
│ 1  │ python  │
│ 2  │ django  │
│ 3  │ web     │
└────┴─────────┘

Post_Tags Table (junction table)
┌─────────┬────────┐
│ post_id │ tag_id │
├─────────┼────────┤
│ 1       │ 1      │
│ 1       │ 3      │
│ 2       │ 1      │
│ 2       │ 2      │
│ 2       │ 3      │
└─────────┴────────┘
```

**Django**: `ManyToManyField` (on either side, with a junction table automatically created)

---

## P.4: SQL Basics

### What is SQL?

SQL (Structured Query Language) is the language used to interact with databases. Django's ORM translates Python code into SQL.

### CRUD Operations

| Operation | SQL | Django ORM |
|-----------|-----|------------|
| **Create** | `INSERT INTO ...` | `Model.objects.create()` |
| **Read** | `SELECT ... FROM ...` | `Model.objects.filter()` |
| **Update** | `UPDATE ... SET ...` | `instance.save()` or `Model.objects.update()` |
| **Delete** | `DELETE FROM ...` | `instance.delete()` or `Model.objects.delete()` |

### Create (INSERT)

```sql
-- Create a user
INSERT INTO users (username, email, active) 
VALUES ('alice', 'alice@email.com', true);

-- Create a post
INSERT INTO posts (title, content, user_id) 
VALUES ('Hello World', 'This is my first post', 1);
```

### Read (SELECT)

```sql
-- Get all users
SELECT * FROM users;

-- Get active users
SELECT * FROM users WHERE active = true;

-- Get users by email
SELECT * FROM users WHERE email LIKE '%@email.com';

-- Get posts with author information (JOIN)
SELECT p.title, p.content, u.username 
FROM posts p 
JOIN users u ON p.user_id = u.id;

-- Count posts by user
SELECT u.username, COUNT(p.id) as post_count 
FROM users u 
LEFT JOIN posts p ON u.id = p.user_id 
GROUP BY u.id;
```

### Update

```sql
-- Update a user
UPDATE users 
SET email = 'alice_new@email.com' 
WHERE id = 1;

-- Update all posts by a user
UPDATE posts 
SET status = 'published' 
WHERE user_id = 1;
```

### Delete

```sql
-- Delete a user
DELETE FROM users WHERE id = 1;

-- Delete all inactive users
DELETE FROM users WHERE active = false;
```

---

## P.5: Django ORM (Object-Relational Mapping)

### What is an ORM?

ORM is a technique that lets you interact with your database using Python objects instead of SQL. Django's ORM is its most powerful feature.

```
Python Objects → ORM → SQL → Database
Database → SQL → ORM → Python Objects
```

### How Django Models Map to Database Tables

```python
# Django Model
class User(models.Model):
    username = models.CharField(max_length=150)
    email = models.EmailField()
    active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    
    def __str__(self):
        return self.username
```

```sql
-- Corresponding SQL Table
CREATE TABLE blog_user (
    id INTEGER PRIMARY KEY,
    username VARCHAR(150) NOT NULL,
    email VARCHAR(254) NOT NULL,
    active BOOLEAN NOT NULL DEFAULT true,
    created_at DATETIME NOT NULL
);
```

### Basic ORM Operations

```python
# CREATE
user = User.objects.create(
    username='alice',
    email='alice@email.com',
    active=True
)

# READ
# Get all users
all_users = User.objects.all()

# Filter users
active_users = User.objects.filter(active=True)

# Get single user
user = User.objects.get(id=1)
user = User.objects.get(username='alice')

# Get first user
first_user = User.objects.first()

# Count users
count = User.objects.count()

# UPDATE
# Update a single user
user = User.objects.get(id=1)
user.email = 'alice_new@email.com'
user.save()

# Update all active users
User.objects.filter(active=True).update(active=False)

# DELETE
# Delete a user
user = User.objects.get(id=1)
user.delete()

# Delete all inactive users
User.objects.filter(active=False).delete()
```

### Advanced ORM Queries

```python
# Filter with multiple conditions
posts = Post.objects.filter(
    status='published',
    user__username='alice'
)

# Filter with OR (Q objects)
from django.db.models import Q
posts = Post.objects.filter(
    Q(title__icontains='python') | Q(content__icontains='python')
)

# Filter with exclude
posts = Post.objects.filter(status='published').exclude(category='draft')

# Order by
posts = Post.objects.order_by('-created_at')  # Newest first

# Limit results
posts = Post.objects.all()[:5]  # First 5

# Count and exists
if Post.objects.filter(status='published').exists():
    print("There are published posts")

count = Post.objects.filter(status='published').count()

# Values only (efficient)
titles = Post.objects.values_list('title', flat=True)

# Aggregation
from django.db.models import Count, Sum, Avg, Max, Min

stats = Post.objects.aggregate(
    total=Count('id'),
    avg_views=Avg('view_count'),
    max_views=Max('view_count')
)

# Annotate (add calculated fields)
from django.db.models import Count
posts = Post.objects.annotate(
    comment_count=Count('comments')
)

# Select related (fetch related objects in one query)
posts = Post.objects.select_related('user', 'category').all()

# Prefetch related (for many-to-many)
posts = Post.objects.prefetch_related('tags').all()
```

---

## P.6: Database Design Principles

### Think Before You Code

Good database design is crucial for application performance and maintainability.

### Normalization

Normalization is the process of organizing data to reduce redundancy.

**Bad Design (Denormalized)**

```
Posts Table
┌────┬──────────────┬─────────────────┬─────────────────┐
│ id │ title        │ content         │ author_name     │
├────┼──────────────┼─────────────────┼─────────────────┤
│ 1  │ Hello World  │ ...             │ Alice Johnson   │ ← Duplicated
│ 2  │ Django Rocks │ ...             │ Alice Johnson   │ ← Duplicated
│ 3  │ Python Fun   │ ...             │ Bob Smith       │
└────┴──────────────┴─────────────────┴─────────────────┘
```

**Good Design (Normalized)**

```
Users Table
┌────┬──────────┬──────────────┐
│ id │ username │ full_name    │
├────┼──────────┼──────────────┤
│ 1  │ alice    │ Alice Johnson│
│ 2  │ bob      │ Bob Smith    │
└────┴──────────┴──────────────┘

Posts Table
┌────┬──────────────┬─────────┬──────────┐
│ id │ title        │ content │ user_id  │
├────┼──────────────┼─────────┼──────────┤
│ 1  │ Hello World  │ ...     │ 1        │
│ 2  │ Django Rocks │ ...     │ 1        │
│ 3  │ Python Fun   │ ...     │ 2        │
└────┴──────────────┴─────────┴──────────┘
```

### Common Design Patterns

**1. Always Use a Primary Key**

```python
# Django does this automatically
id = models.AutoField(primary_key=True)
# or
id = models.BigAutoField(primary_key=True)
```

**2. Use Foreign Keys for Relationships**

```python
# One-to-Many
author = models.ForeignKey(User, on_delete=models.CASCADE)

# Many-to-Many
tags = models.ManyToManyField(Tag, blank=True)

# One-to-One
profile = models.OneToOneField(User, on_delete=models.CASCADE)
```

**3. Add Indexes on Frequently Queried Fields**

```python
class Meta:
    indexes = [
        models.Index(fields=['status', 'published_at']),
        models.Index(fields=['author']),
        models.Index(fields=['slug']),
    ]
```

**4. Use Appropriate Data Types**

```python
# Good
price = models.DecimalField(max_digits=10, decimal_places=2)
is_active = models.BooleanField(default=True)
created_at = models.DateTimeField(auto_now_add=True)

# Bad (use CharField for short text, TextField for long text)
content = models.CharField(max_length=10000)  # Should be TextField
```

**5. Add Constraints for Data Integrity**

```python
class Meta:
    constraints = [
        models.UniqueConstraint(
            fields=['slug', 'author'],
            name='unique_slug_per_author'
        ),
        models.CheckConstraint(
            check=models.Q(price__gte=0),
            name='price_positive'
        ),
    ]
```

---

## P.7: Django Migrations

### What are Migrations?

Migrations are Django's way of applying changes to your database schema. They're like version control for your database.

### Migration Workflow

```bash
# 1. Make changes to models.py
# 2. Create migration files
python manage.py makemigrations

# 3. Apply migrations
python manage.py migrate

# 4. Optional: Check migration status
python manage.py showmigrations

# 5. Optional: See SQL that will be run
python manage.py sqlmigrate myapp 0001
```

### Migration Files Example

**File: `blog/migrations/0001_initial.py`**

```python
from django.db import migrations, models
import django.db.models.deletion

class Migration(migrations.Migration):
    initial = True
    
    dependencies = [
        ('auth', '0012_alter_user_first_name_max_length'),
    ]
    
    operations = [
        migrations.CreateModel(
            name='User',
            fields=[
                ('id', models.BigAutoField(primary_key=True)),
                ('username', models.CharField(max_length=150, unique=True)),
                ('email', models.EmailField(max_length=254)),
                ('active', models.BooleanField(default=True)),
                ('created_at', models.DateTimeField(auto_now_add=True)),
            ],
        ),
        migrations.CreateModel(
            name='Post',
            fields=[
                ('id', models.BigAutoField(primary_key=True)),
                ('title', models.CharField(max_length=200)),
                ('content', models.TextField()),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('author', models.ForeignKey(
                    on_delete=django.db.models.deletion.CASCADE,
                    to='auth.User'
                )),
            ],
        ),
    ]
```

### Common Migration Commands

```bash
# Create migrations for all changes
python manage.py makemigrations

# Create migrations for a specific app
python manage.py makemigrations blog

# Apply all migrations
python manage.py migrate

# Apply migrations for a specific app
python manage.py migrate blog

# Apply a specific migration
python manage.py migrate blog 0002

# Show migration status
python manage.py showmigrations

# Show SQL for a migration
python manage.py sqlmigrate blog 0001

# Create an empty migration
python manage.py makemigrations --empty blog

# Fake a migration (mark as applied without running)
python manage.py migrate --fake blog 0001
```

---

## P.8: PostgreSQL vs SQLite

### SQLite (Development)

**Pros:**
- No setup required
- File-based (easy to share)
- Fast for development

**Cons:**
- Limited features
- Not suitable for production
- No user management
- Limited concurrency

**Setup:**
```python
# settings.py
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': BASE_DIR / 'db.sqlite3',
    }
}
```

### PostgreSQL (Production)

**Pros:**
- Production-ready
- Advanced features (JSON, full-text search)
- User management
- High concurrency
- Better performance

**Cons:**
- Requires setup
- More complex

**Setup:**
```python
# settings.py
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': 'my_database',
        'USER': 'my_user',
        'PASSWORD': 'my_password',
        'HOST': 'localhost',
        'PORT': '5432',
    }
}
```

---

## P.9: Common Database Patterns in Django

### Timestamp Fields

```python
class Post(models.Model):
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
```

### Soft Delete

```python
class Post(models.Model):
    is_deleted = models.BooleanField(default=False)
    deleted_at = models.DateTimeField(null=True, blank=True)
    
    def delete(self):
        self.is_deleted = True
        self.deleted_at = timezone.now()
        self.save()
    
    class Meta:
        # Default manager excludes deleted
        default_manager_name = 'objects'
    
    objects = models.Manager()  # All objects
    active = ActiveManager()  # Only non-deleted
```

### Status Fields

```python
class Post(models.Model):
    class Status(models.TextChoices):
        DRAFT = 'draft', 'Draft'
        PUBLISHED = 'published', 'Published'
        ARCHIVED = 'archived', 'Archived'
    
    status = models.CharField(
        max_length=10,
        choices=Status.choices,
        default=Status.DRAFT
    )
```

### Slug Fields

```python
from django.utils.text import slugify

class Post(models.Model):
    title = models.CharField(max_length=200)
    slug = models.SlugField(max_length=220, unique=True)
    
    def save(self, *args, **kwargs):
        if not self.slug:
            self.slug = slugify(self.title)
        super().save(*args, **kwargs)
```

---

## P.10: Query Optimization Tips

### 1. Use `select_related()` for Foreign Keys

```python
# Bad: N+1 queries
posts = Post.objects.all()
for post in posts:
    print(post.author.username)  # One query per post

# Good: Single query with JOIN
posts = Post.objects.select_related('author').all()
for post in posts:
    print(post.author.username)  # Already loaded
```

### 2. Use `prefetch_related()` for Many-to-Many

```python
# Bad: N+1 queries
posts = Post.objects.all()
for post in posts:
    for tag in post.tags.all():  # One query per post
        print(tag.name)

# Good: 2 queries total
posts = Post.objects.prefetch_related('tags').all()
for post in posts:
    for tag in post.tags.all():  # Already loaded
        print(tag.name)
```

### 3. Use `only()` and `defer()`

```python
# Load only needed fields
posts = Post.objects.only('title', 'slug', 'created_at')

# Defer loading heavy fields
posts = Post.objects.defer('content', 'meta_description')
```

### 4. Use `count()` instead of `len()`

```python
# Bad: Loads all objects
count = len(Post.objects.all())

# Good: Single count query
count = Post.objects.count()
```

### 5. Use `exists()` instead of checking count

```python
# Bad: Loads all objects
if Post.objects.filter(status='published'):
    print("Has published posts")

# Good: Single exists query
if Post.objects.filter(status='published').exists():
    print("Has published posts")
```

### 6. Use `values()` and `values_list()`

```python
# Load only data needed
titles = Post.objects.values_list('title', flat=True)

# Load as dictionaries
data = Post.objects.values('title', 'slug', 'author__username')
```

### 7. Use `bulk_create()` for many records

```python
# Bad: N queries
for i in range(100):
    Post.objects.create(title=f'Post {i}', content='Content')

# Good: 1 query
posts = [Post(title=f'Post {i}', content='Content') for i in range(100)]
Post.objects.bulk_create(posts)
```

---

## P.11: Common Database Errors

### Error: "no such table: app_model"

**Problem**: Migration not applied

**Solution**:
```bash
python manage.py makemigrations
python manage.py migrate
```

### Error: "column 'field' cannot be null"

**Problem**: Field required but no value provided

**Solution**:
```python
# Add default or allow null
field = models.CharField(max_length=100, default='')
# or
field = models.CharField(max_length=100, null=True, blank=True)
```

### Error: "duplicate key value violates unique constraint"

**Problem**: Duplicate value in a unique field

**Solution**:
```python
# Check if exists before creating
if not Post.objects.filter(slug=slug).exists():
    Post.objects.create(slug=slug, ...)
```

### Error: "OperationalError: database is locked"

**Problem**: SQLite concurrency issue

**Solution**: Switch to PostgreSQL for production, or wrap operations in transactions.

### Error: "IntegrityError: foreign key constraint failed"

**Problem**: Orphaned foreign key reference

**Solution**: Ensure related object exists before saving, or use `on_delete=models.SET_NULL`

---

## P.12: Quick Reference

### Django ORM Cheat Sheet

```python
# CREATE
Model.objects.create(field='value')
instance = Model(field='value')
instance.save()

# READ
Model.objects.all()
Model.objects.filter(field='value')
Model.objects.get(id=1)
Model.objects.first()
Model.objects.last()
Model.objects.count()
Model.objects.exists()

# UPDATE
instance.field = 'new value'
instance.save()
Model.objects.filter(field='value').update(field='new value')

# DELETE
instance.delete()
Model.objects.filter(field='value').delete()

# FILTERS
Model.objects.filter(field__exact='value')
Model.objects.filter(field__iexact='value')
Model.objects.filter(field__contains='value')
Model.objects.filter(field__icontains='value')
Model.objects.filter(field__startswith='value')
Model.objects.filter(field__istartswith='value')
Model.objects.filter(field__gt=10)
Model.objects.filter(field__gte=10)
Model.objects.filter(field__lt=10)
Model.objects.filter(field__lte=10)
Model.objects.filter(field__range=(10, 20))
Model.objects.filter(field__in=[1, 2, 3])
Model.objects.filter(field__isnull=True)

# AGGREGATION
from django.db.models import Count, Sum, Avg, Max, Min
Model.objects.aggregate(Count('id'))
Model.objects.annotate(Count('related'))

# RELATIONSHIPS
Model.objects.select_related('foreign_key')
Model.objects.prefetch_related('many_to_many')
```

---

This primer gives you a solid foundation in database concepts for Django development. Understanding these fundamentals will help you design better models and write more efficient queries!
