# Part 2: Models, Database Design, ORM, and Django Admin

## Welcome to Part 2!

You've built a static website. Now it's time to make it dynamic by adding a database. In this part, we'll:

1. Design database models for our blog (Posts, Categories, Authors, Comments)
2. Create and run database migrations
3. Use Django's powerful ORM to query data
4. Set up Django Admin for easy data management
5. Display real database content in our templates

By the end of this part, you'll have a fully database-driven blog application with an admin interface for managing content.

Let's begin!

---

## Target 2.1: Understanding Django Models and Databases

### The Concept

**Models** are Python classes that represent database tables. Each model class maps to a database table, and each attribute of the class maps to a database column.

Think of models like blueprints for your data:

```
Model (Python Class)    →    Database Table
Attribute               →    Column
Instance                →    Row (Record)
```

For our blog, we need:
- **Category**: Organize posts into topics
- **Author**: Users who write posts (we'll link to Django's built-in User model)
- **Post**: Individual blog entries
- **Comment**: User comments on posts
- **Tag**: Labels for posts (many-to-many)

Let's design this properly.

---

## Target 2.2: Creating Our Blog Models

### The Concept

Before writing code, let's plan our data relationships:

```
┌─────────────┐         ┌─────────────┐         ┌─────────────┐
│   Category  │         │    Post     │         │    Tag      │
│             │         │             │         │             │
│ id          │◄────────│ category_id │         │ id          │
│ name        │   Many  │ title       │─────────│ name        │
│ slug        │   To    │ slug        │ Many To  │ slug        │
│ description │   One   │ content     │ Many     │             │
│ created_at  │         │ excerpt     │         └─────────────┘
└─────────────┘         │ featured_image│              ▲
                        │ status      │              │
          ┌─────────────│ author_id   │──────────────┘
          │             │ created_at  │   Through: Post_Tag
          │             │ updated_at  │
          │             │ published_at│
          │             └─────────────┘
          │                    │
          │                    │ One to Many
          │                    ▼
          │             ┌─────────────┐
          │             │   Comment   │
          │             │             │
          │             │ id          │
          │             │ post_id     │
          └─────────────│ author_id   │
                        │ content     │
                        │ created_at  │
                        │ is_approved │
                        └─────────────┘
```

Now let's implement this in code.

### The Implementation

**File: `blog/models.py`**

```python
from django.db import models
from django.contrib.auth.models import User
from django.utils.text import slugify
from django.utils import timezone
from django.urls import reverse


class Category(models.Model):
    """
    Category model for organizing blog posts.
    
    Each post belongs to one category. Categories help users
    find content by topic.
    """
    name = models.CharField(
        max_length=100,
        unique=True,
        help_text="The display name of the category (e.g., 'Technology')"
    )
    slug = models.SlugField(
        max_length=120,
        unique=True,
        help_text="URL-friendly version of the name (e.g., 'technology')"
    )
    description = models.TextField(
        blank=True,
        help_text="Optional description of what this category covers"
    )
    created_at = models.DateTimeField(
        auto_now_add=True,
        help_text="When this category was created"
    )
    updated_at = models.DateTimeField(
        auto_now=True,
        help_text="When this category was last updated"
    )

    class Meta:
        # Order categories by name alphabetically
        ordering = ['name']
        # Human-readable name for the admin interface
        verbose_name_plural = "Categories"

    def save(self, *args, **kwargs):
        """
        Override save to auto-generate slug from name if not provided.
        
        This ensures every category has a valid slug, even if the user
        doesn't provide one.
        """
        if not self.slug:
            self.slug = slugify(self.name)
        super().save(*args, **kwargs)

    def __str__(self):
        """String representation for display in admin and templates."""
        return self.name

    def get_absolute_url(self):
        """
        Return the URL for this category's detail page.
        
        This is a Django convention for getting the canonical URL
        for an object.
        """
        return reverse('blog:category_detail', args=[self.slug])


class Tag(models.Model):
    """
    Tag model for labeling posts with keywords.
    
    Unlike categories (which are hierarchical), tags are flat
    labels that can be applied to posts flexibly. A post can have
    multiple tags, and a tag can belong to multiple posts.
    """
    name = models.CharField(
        max_length=50,
        unique=True,
        help_text="The tag name (e.g., 'Python', 'Tutorial')"
    )
    slug = models.SlugField(
        max_length=60,
        unique=True,
        help_text="URL-friendly version of the tag name"
    )
    created_at = models.DateTimeField(
        auto_now_add=True,
        help_text="When this tag was created"
    )

    class Meta:
        ordering = ['name']

    def save(self, *args, **kwargs):
        if not self.slug:
            self.slug = slugify(self.name)
        super().save(*args, **kwargs)

    def __str__(self):
        return self.name

    def get_absolute_url(self):
        return reverse('blog:tag_detail', args=[self.slug])


class Post(models.Model):
    """
    Post model - the heart of our blog.
    
    Each post has a title, content, author, category, and optional tags.
    Posts can be in draft or published status.
    """
    
    # Status choices for the post
    class Status(models.TextChoices):
        DRAFT = 'draft', 'Draft'
        PUBLISHED = 'published', 'Published'
        ARCHIVED = 'archived', 'Archived'
    
    # Basic information
    title = models.CharField(
        max_length=200,
        help_text="The headline of your blog post"
    )
    slug = models.SlugField(
        max_length=220,
        unique=True,
        help_text="URL-friendly version of the title. Used in the post's URL."
    )
    
    # Content
    content = models.TextField(
        help_text="The main content of your blog post. Supports HTML formatting."
    )
    excerpt = models.TextField(
        max_length=500,
        blank=True,
        help_text="A short summary of the post. If blank, will be auto-generated."
    )
    
    # Relationships
    author = models.ForeignKey(
        User,
        on_delete=models.CASCADE,  # If user is deleted, delete their posts
        related_name='blog_posts',  # Allows: user.blog_posts.all()
        help_text="The user who wrote this post"
    )
    category = models.ForeignKey(
        Category,
        on_delete=models.SET_NULL,  # If category is deleted, set to NULL
        null=True,
        blank=True,
        related_name='posts',
        help_text="The category this post belongs to"
    )
    tags = models.ManyToManyField(
        Tag,
        blank=True,
        related_name='posts',
        help_text="Tags that describe this post"
    )
    
    # Media
    featured_image = models.ImageField(
        upload_to='posts/%Y/%m/%d/',  # Organize by date
        blank=True,
        null=True,
        help_text="An optional image to display with the post"
    )
    
    # Status and dates
    status = models.CharField(
        max_length=10,
        choices=Status.choices,
        default=Status.DRAFT,
        help_text="Draft: Not visible to public. Published: Visible to everyone."
    )
    created_at = models.DateTimeField(
        auto_now_add=True,
        help_text="When the post was first created"
    )
    updated_at = models.DateTimeField(
        auto_now=True,
        help_text="When the post was last modified"
    )
    published_at = models.DateTimeField(
        blank=True,
        null=True,
        help_text="When the post was published. Set automatically on publish."
    )
    
    # Metadata for SEO
    meta_description = models.CharField(
        max_length=160,
        blank=True,
        help_text="SEO meta description. Recommended length: 150-160 characters."
    )
    meta_keywords = models.CharField(
        max_length=255,
        blank=True,
        help_text="SEO keywords, comma-separated."
    )

    class Meta:
        ordering = ['-created_at']  # Newest posts first
        indexes = [
            models.Index(fields=['status', 'published_at']),  # Optimize published queries
            models.Index(fields=['author']),  # Optimize author queries
            models.Index(fields=['slug']),  # Optimize slug lookups
        ]

    def save(self, *args, **kwargs):
        """
        Override save to handle auto-slug generation and published_at.
        
        When a post changes from draft to published, automatically
        set the published_at timestamp.
        """
        # Check if this is an existing post (has a primary key)
        if self.pk:
            # Get the current status from the database
            old_instance = Post.objects.get(pk=self.pk)
            old_status = old_instance.status
        else:
            old_status = None
        
        # Generate slug if not provided
        if not self.slug:
            self.slug = slugify(self.title)
        
        # Auto-generate excerpt from content if empty
        if not self.excerpt and self.content:
            # Take first 200 characters as excerpt
            self.excerpt = self.content[:200]
        
        # Set published_at when status changes to PUBLISHED
        if self.status == self.Status.PUBLISHED and old_status != self.Status.PUBLISHED:
            self.published_at = timezone.now()
        
        super().save(*args, **kwargs)

    def __str__(self):
        """Display the post title in admin and other contexts."""
        return self.title

    def get_absolute_url(self):
        """Return the canonical URL for this post."""
        return reverse('blog:post_detail', args=[self.slug])

    def get_comment_count(self):
        """Return the number of approved comments on this post."""
        return self.comments.filter(is_approved=True).count()

    def is_published(self):
        """Check if the post is published."""
        return self.status == self.Status.PUBLISHED


class Comment(models.Model):
    """
    Comment model for user discussions on posts.
    
    Comments can be approved or held for moderation.
    """
    post = models.ForeignKey(
        Post,
        on_delete=models.CASCADE,
        related_name='comments',
        help_text="The post this comment belongs to"
    )
    author = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name='blog_comments',
        help_text="The user who wrote this comment"
    )
    content = models.TextField(
        help_text="The comment text"
    )
    is_approved = models.BooleanField(
        default=False,
        help_text="Has this comment been approved for public viewing?"
    )
    created_at = models.DateTimeField(
        auto_now_add=True,
        help_text="When the comment was created"
    )
    updated_at = models.DateTimeField(
        auto_now=True,
        help_text="When the comment was last edited"
    )

    class Meta:
        ordering = ['created_at']
        indexes = [
            models.Index(fields=['post', 'created_at']),  # Optimize post comments queries
            models.Index(fields=['is_approved']),  # Optimize approval filtering
        ]

    def __str__(self):
        return f"Comment by {self.author.username} on {self.post.title}"

    def get_absolute_url(self):
        return f"{self.post.get_absolute_url()}#comment-{self.id}"
```

---

## Target 2.3: Understanding Model Fields

### The Concept

Django provides many field types to map Python data types to database columns. Let's understand the ones we used:

### Common Field Types

| Field | Python Type | Database Column | Use Case |
|-------|-------------|-----------------|----------|
| `CharField` | `str` | VARCHAR | Short text (titles, names) |
| `TextField` | `str` | TEXT | Long text (blog content) |
| `IntegerField` | `int` | INTEGER | Whole numbers |
| `DecimalField` | `Decimal` | DECIMAL | Financial values |
| `BooleanField` | `bool` | BOOLEAN | True/False flags |
| `DateField` | `date` | DATE | Calendar dates |
| `DateTimeField` | `datetime` | DATETIME | Dates with times |
| `EmailField` | `str` | VARCHAR(254) | Email addresses |
| `URLField` | `str` | VARCHAR(200) | URLs |
| `SlugField` | `str` | VARCHAR | URL-friendly strings |
| `ImageField` | `str` | VARCHAR | Image file paths |
| `FileField` | `str` | VARCHAR | Generic file paths |
| `ForeignKey` | Model instance | FOREIGN KEY | Many-to-one relationship |
| `ManyToManyField` | QuerySet | Many-to-Many Table | Many-to-many relationship |
| `OneToOneField` | Model instance | FOREIGN KEY + UNIQUE | One-to-one relationship |

### Field Parameters

| Parameter | Purpose | Example |
|-----------|---------|---------|
| `max_length` | Maximum characters | `CharField(max_length=100)` |
| `blank` | Allow empty in forms | `blank=True` |
| `null` | Allow NULL in database | `null=True` |
| `default` | Default value | `default='draft'` |
| `unique` | Must be unique | `unique=True` |
| `choices` | Limited options | `choices=STATUS_CHOICES` |
| `help_text` | Description for admin | `help_text="Enter title"` |
| `related_name` | Reverse relation name | `related_name='posts'` |
| `on_delete` | Behavior on deletion | `on_delete=models.CASCADE` |
| `auto_now` | Update on every save | `auto_now=True` |
| `auto_now_add` | Set once on creation | `auto_now_add=True` |
| `upload_to` | Upload destination | `upload_to='posts/'` |

### Foreign Key `on_delete` Options

| Option | Behavior |
|--------|----------|
| `CASCADE` | Delete related objects too |
| `PROTECT` | Prevent deletion if related objects exist |
| `SET_NULL` | Set foreign key to NULL (requires `null=True`) |
| `SET_DEFAULT` | Set to default value |
| `SET()` | Set to a specific value or function |
| `DO_NOTHING` | Don't handle it (may cause database errors) |
| `RESTRICT` | Prevent deletion (like PROTECT but handles circular dependencies) |

---

## Target 2.4: Creating and Running Migrations

### The Concept

**Migrations** are Django's way of applying changes to your database schema. Think of them like version control for your database.

The workflow:
1. Make changes to models
2. Create migration files (`makemigrations`)
3. Apply migrations to database (`migrate`)
4. Repeat for future changes

### The Implementation

First, we need to install `Pillow` for image support:

```bash
uv pip install Pillow
uv pip freeze > requirements.txt
```

Now create and apply migrations:

```bash
# Create migration files for our new models
python manage.py makemigrations blog

# Apply migrations to the database
python manage.py migrate
```

Let's examine what Django generated:

**File: `blog/migrations/0001_initial.py`** (auto-generated, but let's understand it)

```python
# This file is auto-generated by Django, but it's important to understand
# what it contains.

from django.db import migrations, models
import django.db.models.deletion

class Migration(migrations.Migration):
    initial = True
    
    dependencies = [
        ('auth', '0012_alter_user_first_name_max_length'),
    ]
    
    operations = [
        migrations.CreateModel(
            name='Category',
            fields=[
                # Django automatically adds an 'id' AutoField as primary key
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('name', models.CharField(max_length=100, unique=True)),
                ('slug', models.SlugField(max_length=120, unique=True)),
                # ... etc
            ],
            options={
                'ordering': ['name'],
                'verbose_name_plural': 'Categories',
            },
        ),
        # ... similar for other models
    ]
```

### The Verification

Verify migrations were applied:

```bash
# Check migration status
python manage.py showmigrations blog
```

You should see:
```
blog
 [X] 0001_initial
```

The `[X]` means the migration has been applied.

To see the SQL Django generated:

```bash
python manage.py sqlmigrate blog 0001
```

This shows the actual SQL that was run against your database (helpful for understanding what Django does under the hood).

---

## Target 2.5: Setting Up Django Admin

### The Concept

**Django Admin** is a built-in interface for managing your application data. It's automatically generated from your models and provides:

- List views with search and filters
- Create/update forms
- Delete confirmation
- User authentication

Think of it as a CMS (Content Management System) that comes free with Django.

### The Implementation

First, let's create a superuser (admin) account:

```bash
python manage.py createsuperuser
```

You'll be prompted to enter:
```
Username: admin
Email address: admin@example.com
Password: (enter a secure password)
Password (again): (confirm)
Superuser created successfully.
```

Now register our models with the admin:

**File: `blog/admin.py`**

```python
from django.contrib import admin
from django.utils.html import format_html
from .models import Category, Tag, Post, Comment


@admin.register(Category)
class CategoryAdmin(admin.ModelAdmin):
    """
    Admin configuration for Category model.
    """
    list_display = ['name', 'slug', 'post_count', 'created_at']
    list_filter = ['created_at']
    search_fields = ['name', 'description']
    prepopulated_fields = {'slug': ('name',)}
    ordering = ['name']
    
    def post_count(self, obj):
        """Display the number of posts in this category."""
        return obj.posts.count()
    post_count.short_description = 'Number of Posts'


@admin.register(Tag)
class TagAdmin(admin.ModelAdmin):
    """
    Admin configuration for Tag model.
    """
    list_display = ['name', 'slug', 'post_count', 'created_at']
    search_fields = ['name']
    prepopulated_fields = {'slug': ('name',)}
    
    def post_count(self, obj):
        """Display the number of posts with this tag."""
        return obj.posts.count()
    post_count.short_description = 'Number of Posts'


@admin.register(Post)
class PostAdmin(admin.ModelAdmin):
    """
    Admin configuration for Post model.
    
    This is more complex because Post is the main model.
    """
    # Fields to display in the list view
    list_display = [
        'title', 
        'author', 
        'category', 
        'status', 
        'created_at', 
        'published_at',
        'comment_count_display'
    ]
    
    # Filters for the sidebar
    list_filter = [
        'status', 
        'category', 
        'tags', 
        'author',
        'created_at',
        'published_at'
    ]
    
    # Search fields
    search_fields = ['title', 'content', 'excerpt', 'author__username']
    
    # Prepopulate slug from title
    prepopulated_fields = {'slug': ('title',)}
    
    # Fields to make editable directly from the list view
    list_editable = ['status']
    
    # Default ordering
    ordering = ['-created_at']
    
    # Fields to show in the detail form
    fieldsets = (
        ('Basic Information', {
            'fields': ('title', 'slug', 'author', 'category')
        }),
        ('Content', {
            'fields': ('content', 'excerpt', 'featured_image')
        }),
        ('Taxonomy', {
            'fields': ('tags',),
            'classes': ('collapse',)  # Collapsible section
        }),
        ('Status & Dates', {
            'fields': ('status', 'created_at', 'updated_at', 'published_at'),
            'classes': ('collapse',)
        }),
        ('SEO', {
            'fields': ('meta_description', 'meta_keywords'),
            'classes': ('collapse',)
        }),
    )
    
    # Fields that are read-only in the detail form
    readonly_fields = ['created_at', 'updated_at', 'published_at']
    
    # Actions that can be performed on multiple items
    actions = ['make_published', 'make_draft', 'make_archived']
    
    # Filter by custom method
    def comment_count_display(self, obj):
        """Display comment count with a link to filter comments."""
        count = obj.get_comment_count()
        return format_html(
            '<a href="/admin/blog/comment/?post__id__exact={}">{}</a>',
            obj.id,
            count
        )
    comment_count_display.short_description = 'Comments'
    
    def make_published(self, request, queryset):
        """Bulk action: publish selected posts."""
        updated = queryset.update(status='published')
        self.message_user(request, f'{updated} posts were published.')
    make_published.short_description = "Publish selected posts"
    
    def make_draft(self, request, queryset):
        """Bulk action: set selected posts to draft."""
        updated = queryset.update(status='draft')
        self.message_user(request, f'{updated} posts were set to draft.')
    make_draft.short_description = "Set selected posts to draft"
    
    def make_archived(self, request, queryset):
        """Bulk action: archive selected posts."""
        updated = queryset.update(status='archived')
        self.message_user(request, f'{updated} posts were archived.')
    make_archived.short_description = "Archive selected posts"


@admin.register(Comment)
class CommentAdmin(admin.ModelAdmin):
    """
    Admin configuration for Comment model.
    """
    list_display = ['author', 'post', 'is_approved', 'created_at', 'content_preview']
    list_filter = ['is_approved', 'created_at', 'post']
    search_fields = ['author__username', 'content', 'post__title']
    list_editable = ['is_approved']
    ordering = ['-created_at']
    
    def content_preview(self, obj):
        """Display a preview of the comment content."""
        if len(obj.content) > 50:
            return obj.content[:50] + '...'
        return obj.content
    content_preview.short_description = 'Comment Preview'
```

### The Verification

Start the development server and visit the admin interface:

```bash
python manage.py runserver
```

Go to: **http://127.0.0.1:8000/admin/**

Log in with the superuser credentials you created.

You should see:
- **Categories**: Add, edit, delete categories
- **Tags**: Manage tags
- **Posts**: Full post management
- **Comments**: Comment moderation

Try creating:
1. A category: "Technology"
2. A tag: "Python"
3. A post with content (you'll need a user — use your admin account)
4. Browse around and see how the admin interface works

---

## Target 2.6: Using the Django ORM

### The Concept

The **ORM (Object-Relational Mapping)** allows you to interact with your database using Python code instead of SQL. It translates Python operations into database queries.

Think of the ORM as a translator between Python and your database:
```
Python code → ORM → SQL → Database
Database → SQL → ORM → Python objects
```

### The Implementation

Let's explore the ORM through Django's interactive shell:

```bash
python manage.py shell
```

Now let's run some ORM operations:

```python
# 1. Import our models
from blog.models import Category, Tag, Post, Comment
from django.contrib.auth.models import User
from django.utils import timezone

# 2. CREATE - Creating objects

# Create a category
category = Category.objects.create(
    name='Technology',
    slug='technology',
    description='Posts about technology and software development'
)
print(f"Created category: {category}")

# Create a tag
tag = Tag.objects.create(
    name='Python',
    slug='python'
)
print(f"Created tag: {tag}")

# Get a user (you should have created a superuser)
user = User.objects.get(username='admin')

# Create a post
post = Post.objects.create(
    title='My First Blog Post',
    slug='my-first-blog-post',
    content='This is the content of my first blog post. It is full of interesting information.',
    author=user,
    category=category,
    status='published'
)
print(f"Created post: {post}")

# Add a tag to the post
post.tags.add(tag)
print("Added tag to post")

# 3. READ - Retrieving objects

# Get all posts
all_posts = Post.objects.all()
print(f"All posts: {all_posts}")

# Filter posts by status
published_posts = Post.objects.filter(status='published')
print(f"Published posts: {published_posts}")

# Get a single post by slug
post = Post.objects.get(slug='my-first-blog-post')
print(f"Found post: {post.title}")

# Filter with multiple conditions
tech_posts = Post.objects.filter(
    category=category,
    status='published'
)
print(f"Technology posts: {tech_posts}")

# 4. UPDATE - Modifying objects

# Update a post
post.title = 'My Updated Blog Post Title'
post.save()
print(f"Updated post: {post.title}")

# Bulk update
Post.objects.filter(status='draft').update(status='published')
print("Updated all drafts to published")

# 5. DELETE - Removing objects

# Delete a post
# post.delete()  # Uncomment to delete

# 6. ADVANCED QUERIES

# Chain filters
recent_posts = Post.objects.filter(
    status='published',
    category=category
).order_by('-created_at')[:5]
print(f"Recent published posts: {recent_posts}")

# Count objects
post_count = Post.objects.count()
print(f"Total posts: {post_count}")

# Check if any exist
has_posts = Post.objects.filter(status='published').exists()
print(f"Has published posts: {has_posts}")

# Related object queries
user_posts = user.blog_posts.all()  # Using related_name
print(f"User's posts: {user_posts}")

# 7. EXIT
exit()
```

---

## Target 2.7: Updating Views to Use the Database

### The Concept

Now that we have data in the database, we need to update our views to display it. Instead of hardcoded data, we'll query the database.

### The Implementation

**File: `blog/views.py`** (update)

```python
from django.shortcuts import render, get_object_or_404
from django.http import HttpResponse
from django.db.models import Q, Count
from django.utils import timezone
from .models import Post, Category, Tag, Comment

# Create your views here.

def home(request):
    """
    Homepage view - displays recent published posts.
    """
    # Get the 5 most recent published posts
    recent_posts = Post.objects.filter(
        status=Post.Status.PUBLISHED,
        published_at__lte=timezone.now()  # Only show posts published in the past
    ).order_by('-published_at')[:5]
    
    # Get all categories with a post count
    categories = Category.objects.annotate(
        post_count=Count('posts', filter=Q(posts__status=Post.Status.PUBLISHED))
    ).filter(post_count__gt=0)  # Only show categories with published posts
    
    context = {
        'recent_posts': recent_posts,
        'categories': categories,
        'site_name': 'Django Blog',
        'year': timezone.now().year,
    }
    
    return render(request, 'blog/home.html', context)


def about(request):
    """
    About page view.
    """
    context = {
        'page_title': 'About This Blog',
        'description': 'This blog is built using Django 6, a powerful Python web framework.',
        'technologies': ['Django 6', 'Python 3.14', 'HTML5', 'CSS3', 'PostgreSQL'],
        'year': timezone.now().year,
    }
    
    return render(request, 'blog/about.html', context)


def blog_list(request):
    """
    Blog listing view - displays all published posts with pagination.
    """
    # Get all published posts
    posts = Post.objects.filter(
        status=Post.Status.PUBLISHED,
        published_at__lte=timezone.now()
    ).select_related('author', 'category')  # Optimize queries
    
    context = {
        'page_title': 'Blog Posts',
        'posts': posts,
        'year': timezone.now().year,
    }
    
    return render(request, 'blog/blog_list.html', context)


def post_detail(request, slug):
    """
    Post detail view - displays a single post.
    """
    # Get the post or return 404 if not found
    post = get_object_or_404(
        Post.objects.select_related('author', 'category').prefetch_related('tags', 'comments'),
        slug=slug,
        status=Post.Status.PUBLISHED
    )
    
    # Get recent posts for sidebar
    recent_posts = Post.objects.filter(
        status=Post.Status.PUBLISHED
    ).exclude(id=post.id).order_by('-published_at')[:5]
    
    context = {
        'post': post,
        'recent_posts': recent_posts,
        'year': timezone.now().year,
    }
    
    return render(request, 'blog/post_detail.html', context)


def category_detail(request, slug):
    """
    Category detail view - displays all posts in a category.
    """
    category = get_object_or_404(Category, slug=slug)
    
    posts = Post.objects.filter(
        category=category,
        status=Post.Status.PUBLISHED,
        published_at__lte=timezone.now()
    ).select_related('author').order_by('-published_at')
    
    context = {
        'category': category,
        'posts': posts,
        'year': timezone.now().year,
    }
    
    return render(request, 'blog/category_detail.html', context)


def tag_detail(request, slug):
    """
    Tag detail view - displays all posts with a specific tag.
    """
    tag = get_object_or_404(Tag, slug=slug)
    
    posts = Post.objects.filter(
        tags=tag,
        status=Post.Status.PUBLISHED,
        published_at__lte=timezone.now()
    ).select_related('author', 'category').order_by('-published_at')
    
    context = {
        'tag': tag,
        'posts': posts,
        'year': timezone.now().year,
    }
    
    return render(request, 'blog/tag_detail.html', context)
```

---

## Target 2.8: Creating Templates for Database Content

### The Concept

Now we need templates that display data from the database. We'll use Django template tags to loop through posts and display their fields.

### The Implementation

**File: `blog/templates/blog/home.html`** (update)

```html
{% extends 'blog/base.html' %}
{% load static %}

{% block title %}
    Home — Django Blog
{% endblock %}

{% block content %}
<div class="page-header">
    <h1>Welcome to Django Blog</h1>
    <p class="subtitle">Learn Django by building a real application.</p>
</div>

<div class="content">
    <div style="display: grid; grid-template-columns: 2fr 1fr; gap: 2rem;">
        <!-- Main content area -->
        <div>
            <h2>Recent Posts</h2>
            
            {% if recent_posts %}
                {% for post in recent_posts %}
                    <div style="margin-bottom: 2rem; padding-bottom: 2rem; border-bottom: 1px solid #eee;">
                        <h3 style="margin-bottom: 0.25rem;">
                            <a href="{{ post.get_absolute_url }}" style="color: #2c3e50; text-decoration: none;">
                                {{ post.title }}
                            </a>
                        </h3>
                        <p style="color: #7f8c8d; font-size: 0.9rem;">
                            By {{ post.author.get_full_name|default:post.author.username }}
                            on {{ post.published_at|date:"F j, Y" }}
                            {% if post.category %}
                                in <a href="{{ post.category.get_absolute_url }}" style="color: #3498db; text-decoration: none;">
                                    {{ post.category.name }}
                                </a>
                            {% endif %}
                        </p>
                        <p>{{ post.excerpt|truncatewords:30 }}</p>
                        <p>
                            <a href="{{ post.get_absolute_url }}" style="color: #3498db; text-decoration: none;">
                                Read more →
                            </a>
                        </p>
                    </div>
                {% endfor %}
            {% else %}
                <p>No blog posts available yet. Check back later!</p>
            {% endif %}
        </div>
        
        <!-- Sidebar -->
        <div style="background: #f8f9fa; padding: 1.5rem; border-radius: 8px;">
            <h3 style="margin-bottom: 1rem;">Categories</h3>
            {% if categories %}
                <ul style="list-style: none; padding: 0;">
                    {% for category in categories %}
                        <li style="margin-bottom: 0.5rem;">
                            <a href="{{ category.get_absolute_url }}" style="color: #2c3e50; text-decoration: none;">
                                {{ category.name }}
                                <span style="color: #7f8c8d; font-size: 0.9rem;">({{ category.post_count }})</span>
                            </a>
                        </li>
                    {% endfor %}
                </ul>
            {% else %}
                <p>No categories yet.</p>
            {% endif %}
            
            <h3 style="margin-top: 2rem; margin-bottom: 1rem;">About</h3>
            <p style="color: #7f8c8d;">
                A Django blog built from scratch as part of the
                Mastering Django 6 tutorial series.
            </p>
            <p style="margin-top: 0.5rem;">
                <a href="{% url 'blog:about' %}" style="color: #3498db; text-decoration: none;">
                    Learn more →
                </a>
            </p>
        </div>
    </div>
</div>
{% endblock %}
```

**File: `blog/templates/blog/blog_list.html`** (update)

```html
{% extends 'blog/base.html' %}
{% load static %}

{% block title %}
    {{ page_title }} — Django Blog
{% endblock %}

{% block content %}
<div class="page-header">
    <h1>{{ page_title }}</h1>
    <p class="subtitle">All blog posts</p>
</div>

<div class="content">
    {% if posts %}
        {% for post in posts %}
            <div style="margin-bottom: 2rem; padding-bottom: 2rem; border-bottom: 1px solid #eee;">
                <h2 style="margin-bottom: 0.25rem;">
                    <a href="{{ post.get_absolute_url }}" style="color: #2c3e50; text-decoration: none;">
                        {{ post.title }}
                    </a>
                </h2>
                <p style="color: #7f8c8d; font-size: 0.9rem;">
                    By {{ post.author.get_full_name|default:post.author.username }}
                    on {{ post.published_at|date:"F j, Y" }}
                    {% if post.category %}
                        in <a href="{{ post.category.get_absolute_url }}" style="color: #3498db; text-decoration: none;">
                            {{ post.category.name }}
                        </a>
                    {% endif %}
                </p>
                <p>{{ post.excerpt|truncatewords:30 }}</p>
                {% if post.tags.all %}
                    <p style="margin-top: 0.5rem;">
                        Tags:
                        {% for tag in post.tags.all %}
                            <a href="{{ tag.get_absolute_url }}" style="background: #ecf0f1; padding: 0.2rem 0.6rem; border-radius: 12px; color: #2c3e50; text-decoration: none; font-size: 0.85rem;">
                                {{ tag.name }}
                            </a>
                            {% if not forloop.last %} {% endif %}
                        {% endfor %}
                    </p>
                {% endif %}
            </div>
        {% endfor %}
    {% else %}
        <p>No blog posts available yet. Check back later!</p>
    {% endif %}
</div>
{% endblock %}
```

**File: `blog/templates/blog/post_detail.html`** (create new)

```html
{% extends 'blog/base.html' %}
{% load static %}

{% block title %}
    {{ post.title }} — Django Blog
{% endblock %}

{% block content %}
<div class="page-header">
    <h1>{{ post.title }}</h1>
    <p class="subtitle">
        By {{ post.author.get_full_name|default:post.author.username }}
        on {{ post.published_at|date:"F j, Y" }}
        {% if post.category %}
            in <a href="{{ post.category.get_absolute_url }}" style="color: #3498db; text-decoration: none;">
                {{ post.category.name }}
            </a>
        {% endif %}
    </p>
    {% if post.tags.all %}
        <p>
            Tags:
            {% for tag in post.tags.all %}
                <a href="{{ tag.get_absolute_url }}" style="background: #ecf0f1; padding: 0.2rem 0.6rem; border-radius: 12px; color: #2c3e50; text-decoration: none; font-size: 0.85rem;">
                    {{ tag.name }}
                </a>
                {% if not forloop.last %} {% endif %}
            {% endfor %}
        </p>
    {% endif %}
</div>

<div class="content">
    {% if post.featured_image %}
        <div style="margin-bottom: 2rem;">
            <img src="{{ post.featured_image.url }}" alt="{{ post.title }}" style="max-width: 100%; border-radius: 8px;">
        </div>
    {% endif %}
    
    <div style="line-height: 1.8;">
        {{ post.content|linebreaks }}
    </div>
    
    <!-- Comments section -->
    <div style="margin-top: 3rem; padding-top: 2rem; border-top: 2px solid #eee;">
        <h3>Comments</h3>
        {% with comments=post.comments.filter|dictsort:"created_at" %}
            {% for comment in comments %}
                <div style="background: #f8f9fa; padding: 1rem; border-radius: 8px; margin-bottom: 1rem;">
                    <p><strong>{{ comment.author.get_full_name|default:comment.author.username }}</strong>
                    <span style="color: #7f8c8d; font-size: 0.9rem;">— {{ comment.created_at|date:"F j, Y g:i a" }}</span></p>
                    <p>{{ comment.content|linebreaks }}</p>
                </div>
            {% empty %}
                <p style="color: #7f8c8d;">No comments yet. Be the first to comment!</p>
            {% endfor %}
        {% endwith %}
    </div>
</div>

<!-- Back link -->
<div style="margin-top: 1.5rem;">
    <a href="{% url 'blog:blog_list' %}" style="color: #3498db; text-decoration: none;">
        ← Back to all posts
    </a>
</div>
{% endblock %}
```

**File: `blog/templates/blog/category_detail.html`** (create new)

```html
{% extends 'blog/base.html' %}
{% load static %}

{% block title %}
    {{ category.name }} — Django Blog
{% endblock %}

{% block content %}
<div class="page-header">
    <h1>{{ category.name }}</h1>
    <p class="subtitle">{{ category.description|default:"Posts in this category" }}</p>
</div>

<div class="content">
    {% if posts %}
        {% for post in posts %}
            <div style="margin-bottom: 2rem; padding-bottom: 2rem; border-bottom: 1px solid #eee;">
                <h2 style="margin-bottom: 0.25rem;">
                    <a href="{{ post.get_absolute_url }}" style="color: #2c3e50; text-decoration: none;">
                        {{ post.title }}
                    </a>
                </h2>
                <p style="color: #7f8c8d; font-size: 0.9rem;">
                    By {{ post.author.get_full_name|default:post.author.username }}
                    on {{ post.published_at|date:"F j, Y" }}
                </p>
                <p>{{ post.excerpt|truncatewords:30 }}</p>
            </div>
        {% endfor %}
    {% else %}
        <p>No posts in this category yet.</p>
    {% endif %}
</div>

<div style="margin-top: 1.5rem;">
    <a href="{% url 'blog:blog_list' %}" style="color: #3498db; text-decoration: none;">
        ← Back to all posts
    </a>
</div>
{% endblock %}
```

**File: `blog/templates/blog/tag_detail.html`** (create new)

```html
{% extends 'blog/base.html' %}
{% load static %}

{% block title %}
    Posts tagged "{{ tag.name }}" — Django Blog
{% endblock %}

{% block content %}
<div class="page-header">
    <h1>Posts tagged "{{ tag.name }}"</h1>
</div>

<div class="content">
    {% if posts %}
        {% for post in posts %}
            <div style="margin-bottom: 2rem; padding-bottom: 2rem; border-bottom: 1px solid #eee;">
                <h2 style="margin-bottom: 0.25rem;">
                    <a href="{{ post.get_absolute_url }}" style="color: #2c3e50; text-decoration: none;">
                        {{ post.title }}
                    </a>
                </h2>
                <p style="color: #7f8c8d; font-size: 0.9rem;">
                    By {{ post.author.get_full_name|default:post.author.username }}
                    on {{ post.published_at|date:"F j, Y" }}
                    {% if post.category %}
                        in <a href="{{ post.category.get_absolute_url }}" style="color: #3498db; text-decoration: none;">
                            {{ post.category.name }}
                        </a>
                    {% endif %}
                </p>
                <p>{{ post.excerpt|truncatewords:30 }}</p>
            </div>
        {% endfor %}
    {% else %}
        <p>No posts with this tag yet.</p>
    {% endif %}
</div>

<div style="margin-top: 1.5rem;">
    <a href="{% url 'blog:blog_list' %}" style="color: #3498db; text-decoration: none;">
        ← Back to all posts
    </a>
</div>
{% endblock %}
```

---

## Target 2.9: Updating URLs

### The Concept

We need to add URL patterns for our new views (post detail, category detail, tag detail).

### The Implementation

**File: `blog/urls.py`** (update)

```python
from django.urls import path
from . import views

# Application namespace
app_name = 'blog'

# URL patterns for the blog app
urlpatterns = [
    # Home page
    path('', views.home, name='home'),
    
    # About page
    path('about/', views.about, name='about'),
    
    # Blog list page
    path('blog/', views.blog_list, name='blog_list'),
    
    # Post detail page - slug in URL
    path('blog/<slug:slug>/', views.post_detail, name='post_detail'),
    
    # Category detail page
    path('category/<slug:slug>/', views.category_detail, name='category_detail'),
    
    # Tag detail page
    path('tag/<slug:slug>/', views.tag_detail, name='tag_detail'),
]
```

**Important:** The order of URL patterns matters! Django matches from top to bottom, so more specific patterns should come before more general ones.

---

## The Verification

Let's test everything works:

```bash
python manage.py runserver
```

### Step 1: Create Test Data

1. Visit **http://127.0.0.1:8000/admin/**
2. Log in with your superuser account
3. Create:
   - A category (e.g., "Technology", "Python")
   - Several tags (e.g., "Django", "Web Development", "Tutorial")
   - A user (or use your admin account)
   - 3-5 blog posts with various categories and tags
   - Publish them

### Step 2: Visit the Website

1. **http://127.0.0.1:8000/** → Homepage shows recent posts and categories
2. **http://127.0.0.1:8000/blog/** → Full blog listing
3. **http://127.0.0.1:8000/blog/your-post-slug/** → Post detail page
4. **http://127.0.0.1:8000/category/technology/** → Category page
5. **http://127.0.0.1:8000/tag/django/** → Tag page

### Step 3: Verify Data Display

- Posts show titles, authors, dates, excerpts
- Categories appear in sidebar with post counts
- Tags appear on posts
- Navigation works between pages
- Comments section appears on post detail (empty for now)

---

## Deep Dive: Understanding ORM Query Performance

### The N+1 Query Problem

When you loop through objects and access related data, Django makes separate queries for each object:

```python
# Bad: N+1 queries
posts = Post.objects.all()
for post in posts:
    print(post.author.username)  # One query per post!
```

**Solution:** Use `select_related()` for foreign keys and `prefetch_related()` for many-to-many:

```python
# Good: Only 2 queries
posts = Post.objects.select_related('author', 'category').prefetch_related('tags')
for post in posts:
    print(post.author.username)  # Already loaded!
```

### Common ORM Methods

| Method | Purpose | Example |
|--------|---------|---------|
| `all()` | Get all records | `Post.objects.all()` |
| `filter()` | Filter records | `Post.objects.filter(status='published')` |
| `exclude()` | Exclude records | `Post.objects.exclude(status='draft')` |
| `get()` | Get single record | `Post.objects.get(id=1)` |
| `create()` | Create and save | `Post.objects.create(title='...')` |
| `order_by()` | Sort results | `Post.objects.order_by('-created_at')` |
| `count()` | Count records | `Post.objects.count()` |
| `exists()` | Check if exists | `Post.objects.filter(title='...').exists()` |
| `values()` | Get dicts of data | `Post.objects.values('title', 'slug')` |
| `values_list()` | Get tuples | `Post.objects.values_list('title', flat=True)` |
| `first()` | Get first record | `Post.objects.first()` |
| `last()` | Get last record | `Post.objects.last()` |
| `select_related()` | Join foreign keys | `select_related('author')` |
| `prefetch_related()` | Join many-to-many | `prefetch_related('tags')` |
| `annotate()` | Add aggregate fields | `annotate(Count('comments'))` |
| `distinct()` | Remove duplicates | `Post.objects.distinct()` |

---

## Common Errors and Troubleshooting

### Error: "OperationalError: no such table: blog_post"
**Cause**: Migrations not applied
**Fix**:
```bash
python manage.py migrate
```

### Error: "Column 'category_id' cannot be null"
**Cause**: `SET_NULL` requires `null=True`
**Fix**: Ensure model has `null=True, blank=True` for nullable foreign keys

### Error: "Duplicate entry for slug"
**Cause**: Slug already exists in database
**Fix**: Use a unique slug or modify the slug generation logic

### Error: "Cannot add foreign key constraint"
**Cause**: Referenced table or column doesn't exist
**Fix**: Ensure migrations are run in correct order

### Error: "ImageField requires Pillow"
**Cause**: Pillow not installed
**Fix**:
```bash
uv pip install Pillow
```

---

## Challenge: Extend the Database

### Challenge 1: Add a "Featured" Boolean Field
Add a `is_featured` boolean field to the Post model. Update the admin to show it and add a filter.

### Challenge 2: Add Author Bio
Create a Profile model (OneToOneField to User) with fields: bio, website, location, avatar.

### Challenge 3: Add Comment Approval Workflow
Add a `moderated_at` DateTimeField to Comment. Auto-set when `is_approved` changes.

### Challenge 4: Implement Soft Delete
Add a `deleted_at` DateTimeField (null=True) and add a custom manager that excludes deleted records.

---

## What You've Learned in Part 2

### ✅ Skills Acquired
- Designing database models with relationships
- Understanding Django field types and parameters
- Creating and applying migrations
- Using Django's ORM for CRUD operations
- Configuring Django Admin for data management
- Optimizing queries with `select_related` and `prefetch_related`
- Displaying database content in templates
- Creating detail views with `get_object_or_404`

### ✅ What You've Built
- Complete database schema for a blog
- Admin interface for content management
- Dynamic views that query the database
- Templates that display real data
- Category, tag, and post detail pages

---

## Quick Reference: ORM Commands

```python
# CREATE
obj = Model.objects.create(field1='value', field2=123)

# READ
all_items = Model.objects.all()
filtered = Model.objects.filter(field='value')
single = Model.objects.get(id=1)

# UPDATE
obj.field = 'new value'
obj.save()
Model.objects.filter(field='value').update(field='new value')

# DELETE
obj.delete()
Model.objects.filter(field='value').delete()

# AGGREGATE
from django.db.models import Count, Sum, Avg
count = Model.objects.count()
total = Model.objects.aggregate(Sum('field'))
```
