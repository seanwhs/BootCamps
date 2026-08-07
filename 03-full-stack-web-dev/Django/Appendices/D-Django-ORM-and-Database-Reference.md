# Appendix D: Django ORM and Database Reference

## Welcome to Appendix D!

This appendix provides a comprehensive reference for Django's Object-Relational Mapping (ORM) system. You'll find everything from basic queries to advanced operations, complete with examples for each method and pattern.

---

## D.1: QuerySet Basics

### Creating QuerySets

```python
# Get all objects
all_objects = MyModel.objects.all()

# Get filtered objects
filtered = MyModel.objects.filter(field='value')

# Get single object (raises DoesNotExist if not found)
single = MyModel.objects.get(id=1)

# Get first object (returns None if not found)
first = MyModel.objects.first()

# Get last object
last = MyModel.objects.last()

# Get count
count = MyModel.objects.count()

# Check if any exist
exists = MyModel.objects.filter(status='active').exists()

# Get values as dictionaries
values = MyModel.objects.values('field1', 'field2')

# Get values as tuples
values_list = MyModel.objects.values_list('field1', 'field2', flat=True)

# Get distinct values
distinct = MyModel.objects.values('category').distinct()
```

### Chaining Queries

```python
# Chain filters
results = MyModel.objects.filter(
    status='active'
).exclude(
    is_deleted=True
).order_by(
    '-created_at'
).select_related(
    'related_field'
)[:10]

# QuerySets are lazy - executed only when evaluated
queryset = MyModel.objects.filter(status='active')  # Not executed yet
result = list(queryset)  # Now executed

# Using filter parameters
from django.db.models import Q
results = MyModel.objects.filter(
    Q(title__icontains='python') | Q(content__icontains='python')
)
```

---

## D.2: Field Lookups

### String Lookups

```python
# Exact match (case-sensitive)
MyModel.objects.filter(name__exact='Python')

# Case-insensitive exact
MyModel.objects.filter(name__iexact='python')

# Contains (case-sensitive)
MyModel.objects.filter(name__contains='thon')

# Case-insensitive contains
MyModel.objects.filter(name__icontains='thon')

# Starts with (case-sensitive)
MyModel.objects.filter(name__startswith='Py')

# Case-insensitive starts with
MyModel.objects.filter(name__istartswith='py')

# Ends with (case-sensitive)
MyModel.objects.filter(name__endswith='on')

# Case-insensitive ends with
MyModel.objects.filter(name__iendswith='ON')

# Regex match (case-sensitive)
MyModel.objects.filter(name__regex=r'^[Pp]y.*')

# Case-insensitive regex
MyModel.objects.filter(name__iregex=r'^[Pp]y.*')
```

### Numeric Lookups

```python
# Exact match
MyModel.objects.filter(price__exact=100)

# Greater than
MyModel.objects.filter(price__gt=100)

# Greater than or equal
MyModel.objects.filter(price__gte=100)

# Less than
MyModel.objects.filter(price__lt=100)

# Less than or equal
MyModel.objects.filter(price__lte=100)

# In a range
MyModel.objects.filter(price__range=(50, 100))

# In a list
MyModel.objects.filter(price__in=[50, 75, 100])
```

### Date/Time Lookups

```python
from datetime import datetime, timedelta
from django.utils import timezone

# Exact date
MyModel.objects.filter(created_at__date=datetime.date(2026, 3, 15))

# Year
MyModel.objects.filter(created_at__year=2026)

# Month
MyModel.objects.filter(created_at__month=3)

# Day
MyModel.objects.filter(created_at__day=15)

# Week day (1=Sunday, 7=Saturday)
MyModel.objects.filter(created_at__week_day=1)

# Quarter
MyModel.objects.filter(created_at__quarter=1)

# Hour
MyModel.objects.filter(created_at__hour=14)

# Minute
MyModel.objects.filter(created_at__minute=30)

# Second
MyModel.objects.filter(created_at__second=0)

# Greater than date
MyModel.objects.filter(created_at__date__gt=datetime.date(2026, 1, 1))

# Range between dates
start_date = timezone.now() - timedelta(days=30)
end_date = timezone.now()
MyModel.objects.filter(created_at__range=(start_date, end_date))

# In the last 7 days
MyModel.objects.filter(created_at__gte=timezone.now() - timedelta(days=7))
```

### Boolean Lookups

```python
# True
MyModel.objects.filter(is_active=True)

# False
MyModel.objects.filter(is_active=False)

# Not null
MyModel.objects.filter(is_active__isnull=False)

# Null
MyModel.objects.filter(is_active__isnull=True)
```

### Relationship Lookups

```python
# ForeignKey (Post belongs to Category)
# Get posts in a specific category
Post.objects.filter(category__name='Technology')

# Get posts where category name starts with 'T'
Post.objects.filter(category__name__startswith='T')

# Get posts with category id in list
Post.objects.filter(category__id__in=[1, 2, 3])

# ManyToManyField (Post has many Tags)
# Get posts with a specific tag
Post.objects.filter(tags__name='Python')

# Get posts with all tags
Post.objects.filter(tags__name='Python').filter(tags__name='Django')

# Get posts with any of the tags
Post.objects.filter(tags__name__in=['Python', 'Django'])

# Reverse relationship (Category has many Posts)
# Get all categories that have posts
Category.objects.filter(posts__isnull=False)

# Get categories with at least one published post
Category.objects.filter(posts__status='published').distinct()

# OneToOneField (User has Profile)
# Get user with profile containing specific bio
User.objects.filter(profile__bio__icontains='developer')

# Get profile with user having specific username
Profile.objects.filter(user__username='admin')
```

### Combined Lookups

```python
# Using Q objects for complex queries
from django.db.models import Q

# OR condition
MyModel.objects.filter(
    Q(title__icontains='python') | Q(content__icontains='python')
)

# AND condition (default)
MyModel.objects.filter(
    Q(title__icontains='python') & Q(status='published')
)

# NOT condition
MyModel.objects.filter(
    ~Q(status='deleted')
)

# Complex nesting
MyModel.objects.filter(
    Q(title__icontains='python') &
    (Q(status='published') | Q(status='draft'))
)

# Combining Q objects dynamically
query = Q()
if search_term:
    query &= Q(title__icontains=search_term)
if category:
    query &= Q(category__slug=category)
if status:
    query &= Q(status=status)
MyModel.objects.filter(query)
```

---

## D.3: Aggregation and Annotation

### Basic Aggregation

```python
from django.db.models import Count, Sum, Avg, Max, Min

# Count
total = MyModel.objects.count()
published_count = MyModel.objects.filter(status='published').count()

# Sum
total_price = Product.objects.aggregate(Sum('price'))
total_price = Product.objects.aggregate(total_price=Sum('price'))

# Average
avg_price = Product.objects.aggregate(Avg('price'))

# Maximum
max_price = Product.objects.aggregate(Max('price'))

# Minimum
min_price = Product.objects.aggregate(Min('price'))

# Multiple aggregations
stats = Product.objects.aggregate(
    total=Count('id'),
    avg_price=Avg('price'),
    max_price=Max('price'),
    min_price=Min('price'),
)
```

### Annotations

```python
from django.db.models import Count, Sum, Avg, Q

# Add comment count to posts
posts = Post.objects.annotate(
    comment_count=Count('comments')
)
for post in posts:
    print(f"{post.title}: {post.comment_count} comments")

# Add approved comment count
posts = Post.objects.annotate(
    approved_comments=Count('comments', filter=Q(comments__is_approved=True))
)

# Add total likes (if you have a likes model)
posts = Post.objects.annotate(
    total_likes=Count('likes')
)

# Add average rating (if you have ratings)
posts = Post.objects.annotate(
    avg_rating=Avg('ratings__value')
)

# Annotate with condition
from django.db.models import Case, When, Value, IntegerField
posts = Post.objects.annotate(
    comment_status=Case(
        When(comments__isnull=True, then=Value(0)),
        When(comments__is_approved=True, then=Value(1)),
        default=Value(2),
        output_field=IntegerField()
    )
)
```

### Group By (Using annotate with values)

```python
from django.db.models import Count

# Group posts by category
Category.objects.annotate(
    post_count=Count('posts')
)

# Group posts by author
User.objects.annotate(
    post_count=Count('blog_posts')
)

# Group with filter
Category.objects.annotate(
    published_posts=Count('posts', filter=Q(posts__status='published'))
)

# Group by date
from django.db.models.functions import TruncMonth
Post.objects.annotate(
    month=TruncMonth('created_at')
).values('month').annotate(
    count=Count('id')
).order_by('month')
```

---

## D.4: Advanced QuerySet Methods

### Select Related (Foreign Keys)

```python
# Without select_related (N+1 queries)
posts = Post.objects.all()
for post in posts:
    print(post.author.username)  # One query per post!

# With select_related (single query)
posts = Post.objects.select_related('author').all()
for post in posts:
    print(post.author.username)  # Already loaded!

# Multiple foreign keys
posts = Post.objects.select_related(
    'author', 
    'category'
).all()

# Nested foreign keys
posts = Post.objects.select_related(
    'author__profile'  # Author's profile
).all()
```

### Prefetch Related (Many-to-Many)

```python
from django.db.models import Prefetch

# Basic prefetch
posts = Post.objects.prefetch_related('tags').all()
for post in posts:
    for tag in post.tags.all():  # Already loaded!
        print(tag.name)

# Nested prefetch
posts = Post.objects.prefetch_related(
    'tags',
    'comments',
    'comments__author'
).all()

# Custom prefetch with filtering
posts = Post.objects.prefetch_related(
    Prefetch(
        'comments',
        queryset=Comment.objects.filter(is_approved=True),
        to_attr='approved_comments'
    )
).all()

for post in posts:
    for comment in post.approved_comments:  # Only approved comments
        print(comment.content)

# Prefetch with ordering
posts = Post.objects.prefetch_related(
    Prefetch(
        'comments',
        queryset=Comment.objects.order_by('-created_at'),
        to_attr='recent_comments'
    )
).all()
```

### Only and Defer

```python
# Only load specific fields (use sparingly)
posts = Post.objects.only('title', 'slug', 'created_at').all()

# Defer loading specific fields
posts = Post.objects.defer('content', 'meta_description').all()

# Combining
posts = Post.objects.only('title', 'content').defer('meta_description').all()
```

### Raw SQL Queries

```python
# Raw query (returns model instances)
posts = Post.objects.raw('SELECT * FROM blog_post WHERE status = %s', ['published'])

# Raw query with joins
posts = Post.objects.raw('''
    SELECT p.*, u.username 
    FROM blog_post p 
    JOIN auth_user u ON p.author_id = u.id 
    WHERE p.status = %s
''', ['published'])

# Using connection for custom queries
from django.db import connection

with connection.cursor() as cursor:
    cursor.execute("""
        SELECT COUNT(*) FROM blog_post 
        WHERE status = %s AND created_at > %s
    """, ['published', '2026-01-01'])
    count = cursor.fetchone()[0]
```

---

## D.5: Transactions

### Atomic Transactions

```python
from django.db import transaction

# Basic transaction
with transaction.atomic():
    post = Post.objects.create(
        title='My Post',
        content='Content'
    )
    Tag.objects.create(name='Python', post=post)
    # If any operation fails, everything rolls back

# As a decorator
@transaction.atomic
def create_post_with_tags(title, content, author, tags):
    post = Post.objects.create(
        title=title,
        content=content,
        author=author
    )
    for tag_name in tags:
        Tag.objects.create(name=tag_name, post=post)
    return post

# Nested transactions
with transaction.atomic():
    # Outer transaction
    post = Post.objects.create(title='My Post', content='Content')
    
    with transaction.atomic():
        # Inner transaction (savepoint)
        Tag.objects.create(name='Python', post=post)
        # If this fails, only inner transaction rolls back

# Savepoints
with transaction.atomic():
    post = Post.objects.create(title='My Post', content='Content')
    sid = transaction.savepoint()
    try:
        Tag.objects.create(name='Python', post=post)
    except Exception:
        transaction.savepoint_rollback(sid)
```

### Transaction Behaviors

```python
# Setting savepoint behavior
@transaction.atomic(savepoint=False)
def my_function():
    # No savepoint used (faster but less granular)
    pass

# Durability (bypassing transaction)
with transaction.atomic():
    post = Post.objects.create(title='My Post')
    # This will be committed even if outer transaction fails
    transaction.on_commit(lambda: send_notification(post.id))

# Using select_for_update for row locking
with transaction.atomic():
    post = Post.objects.select_for_update().get(id=1)
    post.title = 'Updated Title'
    post.save()
```

---

## D.6: F Expressions

```python
from django.db.models import F

# Update using current field value
Post.objects.filter(id=1).update(view_count=F('view_count') + 1)

# Increment multiple fields
Post.objects.filter(category='popular').update(
    view_count=F('view_count') + 1,
    comment_count=F('comment_count') + 5
)

# Compare fields
posts = Post.objects.filter(
    view_count__gt=F('comment_count') * 2
)

# Use in annotations
from django.db.models import F, Value
from django.db.models.functions import Concat

posts = Post.objects.annotate(
    total=F('view_count') + F('comment_count')
)

# Complex expressions
posts = Post.objects.annotate(
    popularity=F('view_count') * 2 + F('comment_count')
)

# Update with expression
Post.objects.update(
    slug=F('title').lower().replace(' ', '-')
)
```

---

## D.7: Q Objects

```python
from django.db.models import Q

# Basic Q objects
posts = Post.objects.filter(
    Q(title__icontains='python') | Q(content__icontains='python')
)

# Complex Q objects
posts = Post.objects.filter(
    (Q(title__icontains='python') | Q(content__icontains='python')) &
    Q(status='published')
)

# Negating Q objects
posts = Post.objects.filter(
    ~Q(status='draft')
)

# Dynamic Q building
query = Q()
if search_term:
    query &= Q(title__icontains=search_term) | Q(content__icontains=search_term)
if category:
    query &= Q(category__slug=category)
if status:
    query &= Q(status=status)
posts = Post.objects.filter(query)

# Q with relationships
posts = Post.objects.filter(
    Q(author__username='admin') | Q(category__name='Technology')
)
```

---

## D.8: Database Functions

### Date/Time Functions

```python
from django.db.models.functions import (
    Now, CurrentTimestamp, Extract, TruncDate, TruncMonth, TruncYear
)

# Get current time
posts = Post.objects.annotate(
    now=Now()
)

# Extract parts
posts = Post.objects.annotate(
    year=Extract('created_at', 'year'),
    month=Extract('created_at', 'month'),
    day=Extract('created_at', 'day'),
    hour=Extract('created_at', 'hour')
)

# Truncate dates
posts = Post.objects.annotate(
    date=TruncDate('created_at'),
    month=TruncMonth('created_at'),
    year=TruncYear('created_at')
)

# Group by date
from django.db.models import Count
posts_by_date = Post.objects.annotate(
    date=TruncDate('created_at')
).values('date').annotate(
    count=Count('id')
).order_by('date')
```

### String Functions

```python
from django.db.models.functions import (
    Concat, Lower, Upper, Length, Substr, Replace, StrIndex
)

# Concatenate fields
users = User.objects.annotate(
    full_name=Concat('first_name', Value(' '), 'last_name')
)

# Convert case
posts = Post.objects.annotate(
    lower_title=Lower('title'),
    upper_title=Upper('title')
)

# String length
posts = Post.objects.annotate(
    title_length=Length('title')
)

# Substring
posts = Post.objects.annotate(
    first_word=Substr('content', 1, 10)
)

# Replace
posts = Post.objects.annotate(
    clean_title=Replace('title', Value(' '), Value('-'))
)

# Find position
posts = Post.objects.annotate(
    position=StrIndex('content', Value('python'))
)
```

### Aggregate Functions

```python
from django.db.models import (
    Count, Sum, Avg, Max, Min, StdDev, Variance
)

# Statistics
stats = Post.objects.aggregate(
    total_posts=Count('id'),
    total_views=Sum('view_count'),
    avg_views=Avg('view_count'),
    max_views=Max('view_count'),
    min_views=Min('view_count'),
    std_dev_views=StdDev('view_count'),
    variance_views=Variance('view_count')
)

# Window functions
from django.db.models import Window
from django.db.models.functions import RowNumber, Rank, DenseRank

posts = Post.objects.annotate(
    row_number=Window(
        expression=RowNumber(),
        order_by=F('created_at').desc()
    ),
    rank=Window(
        expression=Rank(),
        order_by=F('view_count').desc()
    )
)
```

---

## D.9: Subqueries and CTEs

### Subqueries

```python
from django.db.models import Subquery, OuterRef

# Subquery in filter
recent_comments = Comment.objects.filter(
    post=OuterRef('pk')
).order_by('-created_at')
posts = Post.objects.annotate(
    latest_comment_date=Subquery(recent_comments.values('created_at')[:1])
)

# Subquery in annotate
authors_with_posts = User.objects.annotate(
    post_count=Subquery(
        Post.objects.filter(author=OuterRef('pk')).values('author').annotate(
            count=Count('id')
        ).values('count')
    )
)

# Subquery in values
posts = Post.objects.annotate(
    author_email=Subquery(
        User.objects.filter(pk=OuterRef('author_id')).values('email')[:1]
    )
)
```

### CTEs (Common Table Expressions)

```python
from django.db.models import Count, Q
from django.db.models.expressions import Window
from django.db.models.functions import Rank

# Using CTEs for recursive queries (advanced)
# Example: Getting post hierarchy (if using tree structure)
from django.contrib.postgres.expressions import CTE

# This is PostgreSQL only
cte = CTE(
    'post_tree',
    queryset=Post.objects.filter(
        parent__isnull=True
    ).annotate(
        level=Value(0, output_field=IntegerField())
    )
).union(
    CTE(
        'post_tree',
        queryset=Post.objects.filter(
            parent=OuterRef('id')
        ).annotate(
            level=F('level') + 1
        )
    )
)
```

---

## D.10: Model Managers and QuerySets

### Custom Manager

```python
class PublishedManager(models.Manager):
    """Manager for published posts."""
    
    def get_queryset(self):
        return super().get_queryset().filter(status='published')
    
    def recent(self, limit=5):
        return self.get_queryset().order_by('-published_at')[:limit]
    
    def by_author(self, author):
        return self.get_queryset().filter(author=author)

class Post(models.Model):
    # ... fields ...
    objects = models.Manager()  # Default manager
    published = PublishedManager()  # Custom manager
    
    class Meta:
        # ... meta options ...
```

**Usage:**
```python
# Use custom manager
recent_published = Post.published.recent()
author_posts = Post.published.by_author(user)

# Default manager still works
all_posts = Post.objects.all()
```

### Custom QuerySet

```python
class PostQuerySet(models.QuerySet):
    def published(self):
        return self.filter(status='published')
    
    def drafts(self):
        return self.filter(status='draft')
    
    def recent(self, limit=5):
        return self.order_by('-published_at')[:limit]
    
    def by_author(self, author):
        return self.filter(author=author)
    
    def with_comments(self):
        return self.annotate(
            comment_count=Count('comments')
        )

class Post(models.Model):
    # ... fields ...
    objects = PostQuerySet.as_manager()
```

**Usage:**
```python
# Chain custom methods
posts = Post.objects.published().by_author(user).recent(10)

# Combine with built-in methods
posts = Post.objects.published().filter(category='tech').with_comments()
```

---

## D.11: Bulk Operations

### Bulk Create

```python
# Bulk create (fewer queries)
posts = [
    Post(title=f'Post {i}', content='Content', author=user)
    for i in range(100)
]
Post.objects.bulk_create(posts, batch_size=50)

# Bulk create with ignore conflicts
Post.objects.bulk_create(
    posts,
    ignore_conflicts=True,  # Ignores duplicates
    batch_size=100
)
```

### Bulk Update

```python
# Bulk update (single query)
Post.objects.filter(status='draft').update(
    status='published',
    published_at=timezone.now()
)

# Bulk update with F expressions
Post.objects.filter(status='published').update(
    view_count=F('view_count') + 1
)

# Bulk update with values
posts = Post.objects.filter(status='draft')
for post in posts:
    post.status = 'published'
    post.published_at = timezone.now()
Post.objects.bulk_update(posts, ['status', 'published_at'], batch_size=100)
```

### Bulk Delete

```python
# Bulk delete
Post.objects.filter(status='archived').delete()

# All objects (use with caution)
Post.objects.all().delete()

# With cascade
Post.objects.filter(id=1).delete()  # Deletes related objects with CASCADE
```

---

## D.12: Database Indexes

### Creating Indexes in Models

```python
class Post(models.Model):
    # ... fields ...
    
    class Meta:
        indexes = [
            # Simple index
            models.Index(fields=['status', 'published_at']),
            
            # Index with name
            models.Index(
                fields=['author'],
                name='author_idx'
            ),
            
            # Index with condition (PostgreSQL only)
            models.Index(
                fields=['status'],
                condition=Q(status='published'),
                name='published_posts_idx'
            ),
            
            # Unique index
            models.UniqueConstraint(
                fields=['slug', 'author'],
                name='unique_slug_author'
            ),
            
            # Check constraint
            models.CheckConstraint(
                check=Q(price__gte=0),
                name='price_positive'
            ),
        ]
```

### Creating Indexes with Migrations

```bash
# Create migrations with indexes
python manage.py makemigrations

# Add indexes manually (advanced)
python manage.py makemigrations --name add_indexes

# Check indexes in database
python manage.py dbshell
# \d+ blog_post  # PostgreSQL
# SHOW INDEX FROM blog_post;  # MySQL
```

---

## D.13: Common ORM Patterns

### Eager Loading

```python
# For ForeignKey
posts = Post.objects.select_related('author', 'category').all()

# For ManyToMany
posts = Post.objects.prefetch_related('tags').all()

# For both
posts = Post.objects.select_related('author').prefetch_related('tags').all()

# Nested prefetch
posts = Post.objects.prefetch_related(
    'tags',
    'comments__author'
).all()
```

### Filter by Relationship Existence

```python
# Has any related objects
Category.objects.filter(posts__isnull=False)

# Has no related objects
Category.objects.filter(posts__isnull=True)

# Has at least one comment
Post.objects.filter(comments__isnull=False)

# Has no comments
Post.objects.filter(comments__isnull=True)

# Has at least one approved comment
Post.objects.filter(comments__is_approved=True)
```

### Get or Create

```python
# Get or create
category, created = Category.objects.get_or_create(
    name='Technology',
    defaults={'description': 'Technology posts'}
)

# Update or create
post, created = Post.objects.update_or_create(
    slug='my-post',
    defaults={
        'title': 'My Post',
        'content': 'Updated content',
        'author': user
    }
)

# Get or create with validation
try:
    category = Category.objects.get(name='Technology')
except Category.DoesNotExist:
    category = Category.objects.create(name='Technology', description='Technology posts')
```

### Distinct Queries

```python
# Get distinct values
authors = Post.objects.values('author').distinct()

# Get distinct objects
posts = Post.objects.select_related('author').distinct()

# Distinct with specific fields
posts = Post.objects.values('author', 'category').distinct()

# Get distinct count
author_count = Post.objects.values('author').distinct().count()
```

### Pagination

```python
from django.core.paginator import Paginator

# Manual pagination
posts = Post.objects.filter(status='published').order_by('-created_at')
paginator = Paginator(posts, 10)
page_obj = paginator.get_page(request.GET.get('page'))

# In class-based views
class PostListView(ListView):
    model = Post
    paginate_by = 10
    # ... other attributes
```

---

## D.14: Database Connections

### Multiple Databases

```python
# settings.py
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': 'main_db',
        # ... settings
    },
    'readonly': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': 'replica_db',
        # ... settings
    }
}

# Using different databases
Post.objects.using('default').all()
Post.objects.using('readonly').filter(status='published')

# Using router (advanced)
class DatabaseRouter:
    def db_for_read(self, model, **hints):
        if model._meta.app_label == 'blog':
            return 'readonly'
        return 'default'
```

### Connection Pooling

```python
# settings.py
DATABASES = {
    'default': {
        # ... settings
        'CONN_MAX_AGE': 600,  # Persistent connections (seconds)
        'OPTIONS': {
            'connect_timeout': 10,
            'keepalives': 1,
            'keepalives_idle': 300,
            'keepalives_interval': 60,
        }
    }
}
```

---

## D.15: Performance Tips

### Query Optimization

```python
# 1. Use select_related for ForeignKey
# Bad: N+1 queries
posts = Post.objects.all()
for post in posts:
    print(post.author.username)

# Good: 1 query
posts = Post.objects.select_related('author').all()
for post in posts:
    print(post.author.username)

# 2. Use prefetch_related for ManyToMany
# Bad: N+1 queries
posts = Post.objects.all()
for post in posts:
    for tag in post.tags.all():
        print(tag.name)

# Good: 2 queries
posts = Post.objects.prefetch_related('tags').all()
for post in posts:
    for tag in post.tags.all():
        print(tag.name)

# 3. Use only() for specific fields
# Bad: Loads all fields
posts = Post.objects.all()

# Good: Loads only needed fields
posts = Post.objects.only('title', 'slug', 'content')

# 4. Use count() instead of len()
# Bad: Loads all objects
count = len(Post.objects.all())

# Good: Single count query
count = Post.objects.count()

# 5. Use exists() instead of boolean check
# Bad: Loads all objects
if Post.objects.filter(status='published'):
    print("Has posts")

# Good: Single exists query
if Post.objects.filter(status='published').exists():
    print("Has posts")

# 6. Use values() for specific data
# Bad: Loads full objects
posts = Post.objects.all()
titles = [post.title for post in posts]

# Good: Values only
titles = Post.objects.values_list('title', flat=True)

# 7. Use bulk_create for many records
# Bad: N queries
for i in range(100):
    Post.objects.create(title=f'Post {i}', content='Content')

# Good: 1 query
posts = [Post(title=f'Post {i}', content='Content') for i in range(100)]
Post.objects.bulk_create(posts)
```

### Query Profiling

```python
from django.db import connection
import time

def profile_query():
    # Clear query log
    connection.queries_log.clear()
    
    # Execute query
    start = time.time()
    posts = Post.objects.select_related('author').all()
    end = time.time()
    
    # Print results
    print(f"Query time: {end - start:.3f}s")
    print(f"Number of queries: {len(connection.queries)}")
    for query in connection.queries:
        print(f"SQL: {query['sql']}")
        print(f"Time: {query['time']}s")
```

---

This appendix provides a comprehensive reference for Django's ORM. Use it as a quick guide for database operations in your Django applications!
