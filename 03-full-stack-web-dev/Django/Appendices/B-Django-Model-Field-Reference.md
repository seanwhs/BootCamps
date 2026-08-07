# Appendix B: Django Model Field Reference

## Welcome to Appendix B!

This appendix provides a comprehensive reference for all Django model fields, their parameters, relationships, and common use cases. Use this as your go-to guide when designing database models.

---

## B.1: Field Types Overview

### Field Category Summary

| Category | Fields | Use Case |
|----------|--------|----------|
| **Text/String** | CharField, TextField, SlugField, EmailField, URLField | Storing text data |
| **Numeric** | IntegerField, DecimalField, FloatField, PositiveIntegerField | Storing numbers |
| **Date/Time** | DateField, DateTimeField, TimeField, DurationField | Storing dates and times |
| **Boolean** | BooleanField, NullBooleanField | True/False values |
| **Binary/File** | FileField, ImageField, FilePathField | File uploads |
| **Relationships** | ForeignKey, ManyToManyField, OneToOneField | Model relationships |
| **Special** | JSONField, ArrayField, UUIDField, IPAddressField | Special data types |

---

## B.2: String and Text Fields

### CharField

**Purpose**: Store short to medium-length text (e.g., names, titles)

```python
from django.db import models

class MyModel(models.Model):
    # Basic usage
    name = models.CharField(max_length=100)
    
    # With options
    title = models.CharField(
        max_length=200,
        blank=True,         # Allow empty in forms
        null=True,          # Allow NULL in database
        default='',         # Default value
        unique=True,        # Must be unique
        db_index=True,      # Create database index
        help_text="Enter the title",  # Admin help text
        verbose_name="Title",         # Human-readable name
    )
```

**Common Parameters**:
- `max_length` (required): Maximum number of characters
- `choices`: Limit to predefined choices
- `blank`: Allow empty in forms (default: False)
- `null`: Allow NULL in database (default: False)
- `default`: Default value
- `unique`: Must be unique (default: False)
- `db_index`: Create database index (default: False)

### TextField

**Purpose**: Store unlimited length text (e.g., blog posts, comments)

```python
class Post(models.Model):
    # Basic usage
    content = models.TextField()
    
    # With options
    description = models.TextField(
        blank=True,
        null=True,
        help_text="Detailed description",
        max_length=5000,  # Django 4.0+ supports max_length
    )
```

### EmailField

**Purpose**: Store email addresses with built-in validation

```python
class UserProfile(models.Model):
    email = models.EmailField(
        max_length=254,      # Standard email length
        unique=True,
        help_text="Enter a valid email address",
    )
```

### URLField

**Purpose**: Store URLs with built-in validation

```python
class Link(models.Model):
    website = models.URLField(
        max_length=200,
        blank=True,
        help_text="Enter your website URL",
    )
    
    # Automatically convert to https
    secure_url = models.URLField(
        schemes=['https'],   # Only allow https
    )
```

### SlugField

**Purpose**: Store URL-friendly identifiers (e.g., /blog/my-post/)

```python
from django.utils.text import slugify

class Post(models.Model):
    title = models.CharField(max_length=200)
    slug = models.SlugField(
        max_length=220,
        unique=True,
        blank=True,
        help_text="URL-friendly version of the title",
    )
    
    def save(self, *args, **kwargs):
        if not self.slug:
            self.slug = slugify(self.title)
        super().save(*args, **kwargs)
```

### FilePathField

**Purpose**: Choose a file from a filesystem path

```python
class Document(models.Model):
    file_path = models.FilePathField(
        path='/home/user/documents/',
        match='.*\.pdf$',    # Only .pdf files
        recursive=True,      # Search subdirectories
        allow_files=True,
        allow_folders=False,
    )
```

---

## B.3: Numeric Fields

### IntegerField

**Purpose**: Store whole numbers

```python
class Product(models.Model):
    quantity = models.IntegerField(
        default=0,
        help_text="Number of items in stock",
    )
    
    # With choices
    class RatingChoices(models.IntegerChoices):
        ONE = 1, 'Poor'
        TWO = 2, 'Fair'
        THREE = 3, 'Good'
        FOUR = 4, 'Very Good'
        FIVE = 5, 'Excellent'
    
    rating = models.IntegerField(
        choices=RatingChoices.choices,
        default=RatingChoices.THREE,
    )
```

### PositiveIntegerField

**Purpose**: Store non-negative whole numbers

```python
class Product(models.Model):
    stock = models.PositiveIntegerField(
        default=0,
        help_text="Stock quantity (must be 0 or greater)",
    )
    
    def clean(self):
        from django.core.exceptions import ValidationError
        if self.stock < 0:
            raise ValidationError('Stock cannot be negative')
```

### PositiveSmallIntegerField

**Purpose**: Store small non-negative numbers (0-32767)

```python
class Product(models.Model):
    # Good for small counts
    small_count = models.PositiveSmallIntegerField(
        default=0,
    )
```

### BigIntegerField

**Purpose**: Store very large numbers

```python
class BigData(models.Model):
    big_number = models.BigIntegerField(
        default=0,
    )
```

### DecimalField

**Purpose**: Store decimal numbers with fixed precision (e.g., prices)

```python
class Product(models.Model):
    price = models.DecimalField(
        max_digits=10,       # Total digits (including decimal)
        decimal_places=2,    # Number of decimal places
        default=0.00,
        help_text="Product price",
    )
    
    # With validation
    amount = models.DecimalField(
        max_digits=12,
        decimal_places=2,
        validators=[
            MinValueValidator(Decimal('0.01')),
            MaxValueValidator(Decimal('999999.99')),
        ],
    )
```

### FloatField

**Purpose**: Store floating-point numbers (less precise than Decimal)

```python
class Measurement(models.Model):
    temperature = models.FloatField()
    
    # For coordinates
    latitude = models.FloatField(
        validators=[MinValueValidator(-90), MaxValueValidator(90)]
    )
    longitude = models.FloatField(
        validators=[MinValueValidator(-180), MaxValueValidator(180)]
    )
```

---

## B.4: Date and Time Fields

### DateField

**Purpose**: Store calendar dates

```python
class Event(models.Model):
    # Basic usage
    date = models.DateField()
    
    # With options
    start_date = models.DateField(
        auto_now_add=True,   # Set to now on creation
        help_text="Event start date",
    )
    
    end_date = models.DateField(
        auto_now=True,       # Update to now on save
        null=True,
        blank=True,
    )
    
    # With validation
    scheduled_date = models.DateField(
        validators=[validate_future_date],
    )
```

### DateTimeField

**Purpose**: Store dates with times

```python
class Post(models.Model):
    # Auto-set on creation
    created_at = models.DateTimeField(
        auto_now_add=True,
        help_text="When the post was created",
    )
    
    # Auto-update on save
    updated_at = models.DateTimeField(
        auto_now=True,
        help_text="When the post was last updated",
    )
    
    # Manual date
    published_at = models.DateTimeField(
        blank=True,
        null=True,
        help_text="When the post was published",
    )
```

### TimeField

**Purpose**: Store times

```python
class Schedule(models.Model):
    start_time = models.TimeField(
        help_text="Start time (24-hour format)",
    )
    
    end_time = models.TimeField(
        blank=True,
        null=True,
    )
```

### DurationField

**Purpose**: Store time durations

```python
class Task(models.Model):
    duration = models.DurationField(
        help_text="Time required to complete the task",
    )
```

---

## B.5: Boolean Fields

### BooleanField

**Purpose**: Store True/False values

```python
class Post(models.Model):
    is_published = models.BooleanField(
        default=False,
        help_text="Is this post visible to the public?",
    )
    
    is_featured = models.BooleanField(
        default=False,
        db_index=True,       # Often filtered on
    )
```

### NullBooleanField

**Purpose**: Store True/False/None (NULL in database)

```python
class UserProfile(models.Model):
    verified = models.NullBooleanField(
        default=None,        # Unknown, not set
        help_text="Has the user been verified?",
    )
```

---

## B.6: Relationship Fields

### ForeignKey

**Purpose**: Create many-to-one relationships

```python
class Comment(models.Model):
    # Basic usage
    post = models.ForeignKey(
        'Post',
        on_delete=models.CASCADE,
        help_text="The post this comment belongs to",
    )
    
    # With related_name
    author = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name='blog_comments',  # user.blog_comments.all()
        help_text="User who wrote the comment",
    )
    
    # With custom options
    category = models.ForeignKey(
        Category,
        on_delete=models.SET_NULL,  # Set NULL if category deleted
        null=True,
        blank=True,
        related_name='posts',
        limit_choices_to={'is_active': True},  # Only active categories
        db_index=True,
    )
```

### on_delete Options

| Option | Behavior |
|--------|----------|
| `CASCADE` | Delete related objects too |
| `PROTECT` | Prevent deletion if related objects exist |
| `RESTRICT` | Prevent deletion (like PROTECT, handles circular) |
| `SET_NULL` | Set foreign key to NULL (requires `null=True`) |
| `SET_DEFAULT` | Set to default value |
| `SET()` | Set to a specific value or function |
| `DO_NOTHING` | Don't handle (may cause database errors) |

### ManyToManyField

**Purpose**: Create many-to-many relationships

```python
class Post(models.Model):
    # Basic usage
    tags = models.ManyToManyField('Tag')
    
    # With related_name
    categories = models.ManyToManyField(
        Category,
        related_name='posts',
        blank=True,
    )
    
    # With through model for extra fields
    members = models.ManyToManyField(
        User,
        through='Membership',  # Custom intermediate model
        related_name='groups',
    )

# Custom through model
class Membership(models.Model):
    person = models.ForeignKey(Person, on_delete=models.CASCADE)
    group = models.ForeignKey(Group, on_delete=models.CASCADE)
    joined_at = models.DateTimeField(auto_now_add=True)
    role = models.CharField(max_length=50)
```

### OneToOneField

**Purpose**: Create one-to-one relationships

```python
class Profile(models.Model):
    # Basic usage
    user = models.OneToOneField(
        User,
        on_delete=models.CASCADE,
        related_name='profile',
        help_text="The user this profile belongs to",
    )
    
    # With custom options
    settings = models.OneToOneField(
        UserSettings,
        on_delete=models.CASCADE,
        primary_key=True,    # Use as primary key
        parent_link=True,    # Inherit from parent
    )
```

---

## B.7: Special Fields

### JSONField

**Purpose**: Store JSON data (PostgreSQL only, or Django 3.1+)

```python
class Product(models.Model):
    metadata = models.JSONField(
        default=dict,
        blank=True,
        help_text="Additional product data in JSON format",
    )
    
    # Usage
    # product.metadata = {'color': 'red', 'size': 'large'}
```

### ArrayField

**Purpose**: Store arrays (PostgreSQL only)

```python
from django.contrib.postgres.fields import ArrayField

class Post(models.Model):
    tags = ArrayField(
        models.CharField(max_length=50),
        blank=True,
        default=list,
        help_text="List of tags for this post",
    )
    
    # With size limitation
    colors = ArrayField(
        models.CharField(max_length=20),
        size=5,  # Max 5 items
    )
```

### UUIDField

**Purpose**: Store universally unique identifiers

```python
import uuid

class Product(models.Model):
    id = models.UUIDField(
        primary_key=True,
        default=uuid.uuid4,
        editable=False,
        help_text="Unique product identifier",
    )
```

### IPAddressField (Deprecated)

**Purpose**: Store IP addresses (use GenericIPAddressField)

```python
class Log(models.Model):
    ip_address = models.GenericIPAddressField(
        protocol='both',     # IPv4 and IPv6
        unpack_ipv4=False,
        help_text="User IP address",
    )
```

### BinaryField

**Purpose**: Store raw binary data

```python
class File(models.Model):
    data = models.BinaryField(
        editable=True,
        help_text="Raw binary data",
    )
```

---

## B.8: Field Parameters Reference

### Common Parameters

| Parameter | Description | Example |
|-----------|-------------|---------|
| `max_length` | Maximum characters | `max_length=255` |
| `blank` | Allow empty in forms | `blank=True` |
| `null` | Allow NULL in database | `null=True` |
| `default` | Default value | `default=0` |
| `unique` | Must be unique | `unique=True` |
| `db_index` | Create database index | `db_index=True` |
| `help_text` | Admin help text | `help_text="Enter title"` |
| `verbose_name` | Human-readable name | `verbose_name="Title"` |
| `validators` | Custom validation | `validators=[validate_name]` |
| `choices` | Limited options | `choices=STATUS_CHOICES` |
| `error_messages` | Custom error messages | `error_messages={'required': '...'}` |
| `editable` | Show in admin forms | `editable=False` |
| `primary_key` | Use as primary key | `primary_key=True` |

### Date/Time Specific Parameters

| Parameter | Description | Example |
|-----------|-------------|---------|
| `auto_now` | Update on every save | `auto_now=True` |
| `auto_now_add` | Set on creation only | `auto_now_add=True` |

### Relationship Specific Parameters

| Parameter | Description | Example |
|-----------|-------------|---------|
| `related_name` | Reverse relation name | `related_name='posts'` |
| `related_query_name` | Query name | `related_query_name='post'` |
| `limit_choices_to` | Filter choices | `limit_choices_to={'is_active': True}` |
| `through` | Custom intermediate model | `through='Membership'` |
| `through_fields` | Field mapping | `through_fields=('from', 'to')` |

---

## B.9: Common Field Combinations

### User Profile Pattern

```python
class Profile(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='profile')
    bio = models.TextField(max_length=500, blank=True)
    location = models.CharField(max_length=100, blank=True)
    birth_date = models.DateField(null=True, blank=True)
    avatar = models.ImageField(upload_to='avatars/', blank=True)
    website = models.URLField(blank=True)
    twitter = models.CharField(max_length=50, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
```

### Blog Post Pattern

```python
class Post(models.Model):
    class Status(models.TextChoices):
        DRAFT = 'DRAFT', 'Draft'
        PUBLISHED = 'PUBLISHED', 'Published'
        ARCHIVED = 'ARCHIVED', 'Archived'
    
    title = models.CharField(max_length=200)
    slug = models.SlugField(max_length=220, unique=True)
    content = models.TextField()
    excerpt = models.TextField(max_length=500, blank=True)
    author = models.ForeignKey(User, on_delete=models.CASCADE, related_name='posts')
    category = models.ForeignKey(Category, on_delete=models.SET_NULL, null=True)
    tags = models.ManyToManyField(Tag, blank=True)
    status = models.CharField(max_length=10, choices=Status.choices, default=Status.DRAFT)
    featured_image = models.ImageField(upload_to='posts/', blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    published_at = models.DateTimeField(null=True, blank=True)
```

### E-commerce Product Pattern

```python
class Product(models.Model):
    name = models.CharField(max_length=200)
    slug = models.SlugField(max_length=220, unique=True)
    description = models.TextField()
    price = models.DecimalField(max_digits=10, decimal_places=2)
    compare_price = models.DecimalField(max_digits=10, decimal_places=2, blank=True, null=True)
    stock = models.PositiveIntegerField(default=0)
    sku = models.CharField(max_length=50, unique=True)
    category = models.ForeignKey(Category, on_delete=models.CASCADE)
    tags = models.ManyToManyField(Tag, blank=True)
    is_active = models.BooleanField(default=True)
    featured = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
```

---

## B.10: Validation Examples

### Custom Validators

```python
# validators.py
from django.core.exceptions import ValidationError
from django.utils import timezone
import re

def validate_positive(value):
    """Validate that a number is positive."""
    if value < 0:
        raise ValidationError('Value must be positive.')

def validate_future_date(value):
    """Validate that a date is in the future."""
    if value < timezone.now().date():
        raise ValidationError('Date must be in the future.')

def validate_phone_number(value):
    """Validate phone number format."""
    pattern = r'^\+?1?\d{9,15}$'
    if not re.match(pattern, value):
        raise ValidationError('Enter a valid phone number.')

def validate_title(value):
    """Validate title length and content."""
    if len(value) < 5:
        raise ValidationError('Title must be at least 5 characters.')
    if len(value) > 200:
        raise ValidationError('Title cannot exceed 200 characters.')

# Using validators in models
class Product(models.Model):
    price = models.DecimalField(
        max_digits=10,
        decimal_places=2,
        validators=[validate_positive]
    )
```

### Field-Level Validation in Models

```python
class Post(models.Model):
    title = models.CharField(max_length=200)
    content = models.TextField()
    published_at = models.DateTimeField(null=True, blank=True)
    
    def clean(self):
        """
        Field-level validation.
        Called when model is validated (by forms, etc.)
        """
        from django.core.exceptions import ValidationError
        
        # Validate title
        if len(self.title) < 5:
            raise ValidationError({'title': 'Title must be at least 5 characters.'})
        
        # Validate content
        if len(self.content) < 10:
            raise ValidationError({'content': 'Content must be at least 10 characters.'})
        
        # Validate published date
        if self.published_at and self.published_at < timezone.now():
            raise ValidationError({'published_at': 'Published date cannot be in the past.'})
    
    def save(self, *args, **kwargs):
        """Override save to run validation."""
        self.full_clean()  # Calls clean()
        super().save(*args, **kwargs)
```

---

## B.11: Meta Class Options

### Common Meta Options

```python
class Post(models.Model):
    # ... fields ...
    
    class Meta:
        # Database table name
        db_table = 'blog_posts'
        
        # Ordering
        ordering = ['-created_at', 'title']
        
        # Human-readable names
        verbose_name = 'Blog Post'
        verbose_name_plural = 'Blog Posts'
        
        # Custom permissions
        permissions = [
            ("can_publish", "Can publish posts"),
            ("can_moderate", "Can moderate comments"),
        ]
        
        # Indexes
        indexes = [
            models.Index(fields=['status', 'published_at']),
            models.Index(fields=['author']),
        ]
        
        # Constraints
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

### Meta Options Summary

| Option | Description |
|--------|-------------|
| `db_table` | Custom database table name |
| `ordering` | Default ordering of objects |
| `verbose_name` | Singular name for admin |
| `verbose_name_plural` | Plural name for admin |
| `permissions` | Custom permissions |
| `indexes` | Database indexes |
| `constraints` | Database constraints |
| `unique_together` | (Deprecated) Unique constraints |
| `index_together` | (Deprecated) Indexes |
| `get_latest_by` | Field for latest() method |
| `default_permissions` | Default permissions ('add', 'change', 'delete', 'view') |
| `proxy` | Proxy model |
| `app_label` | App label if not in current app |

---

## B.12: Choices Options

### Simple Choices

```python
class Post(models.Model):
    # Tuple of choices
    STATUS_CHOICES = (
        ('draft', 'Draft'),
        ('published', 'Published'),
        ('archived', 'Archived'),
    )
    status = models.CharField(max_length=10, choices=STATUS_CHOICES, default='draft')
```

### Integer Choices

```python
class Product(models.Model):
    # Using IntegerChoices
    class RatingChoices(models.IntegerChoices):
        ONE = 1, 'Poor'
        TWO = 2, 'Fair'
        THREE = 3, 'Good'
        FOUR = 4, 'Very Good'
        FIVE = 5, 'Excellent'
    
    rating = models.IntegerField(choices=RatingChoices.choices, default=RatingChoices.THREE)
    
    # Access choices
    # rating = 3  # Good
    # Product.RatingChoices.THREE.value == 3
    # Product.RatingChoices.THREE.label == 'Good'
```

### Text Choices

```python
class Order(models.Model):
    # Using TextChoices
    class StatusChoices(models.TextChoices):
        PENDING = 'PENDING', 'Pending'
        PROCESSING = 'PROCESSING', 'Processing'
        SHIPPED = 'SHIPPED', 'Shipped'
        DELIVERED = 'DELIVERED', 'Delivered'
        CANCELLED = 'CANCELLED', 'Cancelled'
    
    status = models.CharField(
        max_length=20,
        choices=StatusChoices.choices,
        default=StatusChoices.PENDING
    )
    
    # Access choices
    # status = 'PENDING'
    # Order.StatusChoices.PENDING.value == 'PENDING'
    # Order.StatusChoices.PENDING.label == 'Pending'
```

### Dynamic Choices

```python
def get_category_choices():
    """Dynamic choices from database."""
    from .models import Category
    return [(c.id, c.name) for c in Category.objects.filter(is_active=True)]

class Product(models.Model):
    category = models.CharField(
        max_length=100,
        choices=get_category_choices,
    )
```

---

## B.13: Field Method Reference

### Useful Model Methods

```python
class Post(models.Model):
    # ... fields ...
    
    def __str__(self):
        """String representation."""
        return self.title
    
    def get_absolute_url(self):
        """Canonical URL."""
        from django.urls import reverse
        return reverse('post_detail', kwargs={'slug': self.slug})
    
    def save(self, *args, **kwargs):
        """Override save behavior."""
        # Auto-generate slug
        if not self.slug:
            self.slug = slugify(self.title)
        super().save(*args, **kwargs)
    
    def delete(self, *args, **kwargs):
        """Override delete behavior."""
        # Clean up files before deletion
        if self.image:
            self.image.delete()
        super().delete(*args, **kwargs)
    
    class Meta:
        # Meta options
        pass
```

---

This appendix provides a complete reference for Django model fields. Keep it handy when designing your database schemas!
