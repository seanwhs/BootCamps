# Part 8: Testing, Debugging, Logging, and Quality

## Welcome to Part 8!

Your blog is now feature-rich with file uploads, email notifications, sessions, and scheduled publishing. But how do you know it all works correctly? And how do you ensure it keeps working as you add more features?

In this part, we'll:

1. **Write comprehensive tests** for models, forms, views, and authentication
2. **Implement logging** for debugging and monitoring
3. **Add debugging tools** for development
4. **Apply code quality standards** (PEP 8, type hints)
5. **Set up pre-commit hooks** for automated code quality checks

By the end of this part, you'll have a professional test suite and robust logging system.

Let's begin!

---

## Target 8.1: Understanding Django Testing

### The Concept

**Testing** is the practice of writing code that verifies your application works correctly. Think of tests like a safety net — they catch bugs before users do.

Django provides a powerful testing framework built on Python's `unittest` module.

### Types of Tests

1. **Unit Tests**: Test individual components in isolation
2. **Integration Tests**: Test how components work together
3. **Functional Tests**: Test complete user workflows

### Django's Test Hierarchy

```
TestCase
  ├── SimpleTestCase (no database)
  ├── TransactionTestCase (database with rollback)
  └── TestCase (database with transactions)
       └── LiveServerTestCase (with live server)
```

---

## Target 8.2: Setting Up Testing Configuration

### The Concept

We need to configure Django for testing with a separate test database.

### The Implementation

**File: `config/settings.py`** (test settings are automatic, but let's add some utilities)

```python
# config/settings.py

# Testing settings
TEST_RUNNER = 'django.test.runner.DiscoverRunner'

# Use in-memory SQLite for faster tests (optional)
if 'test' in sys.argv:
    DATABASES = {
        'default': {
            'ENGINE': 'django.db.backends.sqlite3',
            'NAME': ':memory:',
        }
    }
```

Create a test utilities file:

**File: `blog/tests/test_utils.py`** (create new)

```python
"""
Test utilities for the blog app.
"""

from django.contrib.auth.models import User
from django.test import TestCase
from django.utils import timezone
from blog.models import Category, Tag, Post, Comment, Profile


class BaseTestCase(TestCase):
    """
    Base test case with common setup methods.
    """
    
    def setUp(self):
        """Set up test data."""
        self.setup_users()
        self.setup_categories()
        self.setup_tags()
        self.setup_posts()
        self.setup_comments()
    
    def setup_users(self):
        """Create test users."""
        self.user = User.objects.create_user(
            username='testuser',
            email='test@example.com',
            password='testpass123'
        )
        self.admin = User.objects.create_superuser(
            username='admin',
            email='admin@example.com',
            password='adminpass123'
        )
        self.other_user = User.objects.create_user(
            username='otheruser',
            email='other@example.com',
            password='otherpass123'
        )
    
    def setup_categories(self):
        """Create test categories."""
        self.category = Category.objects.create(
            name='Test Category',
            slug='test-category',
            description='A test category'
        )
        self.other_category = Category.objects.create(
            name='Other Category',
            slug='other-category',
            description='Another test category'
        )
    
    def setup_tags(self):
        """Create test tags."""
        self.tag1 = Tag.objects.create(name='Test Tag 1', slug='test-tag-1')
        self.tag2 = Tag.objects.create(name='Test Tag 2', slug='test-tag-2')
    
    def setup_posts(self):
        """Create test posts."""
        self.published_post = Post.objects.create(
            title='Published Post',
            slug='published-post',
            content='This is a published post content.',
            excerpt='Published post excerpt.',
            author=self.user,
            category=self.category,
            status=Post.Status.PUBLISHED,
            published_at=timezone.now()
        )
        self.published_post.tags.add(self.tag1, self.tag2)
        
        self.draft_post = Post.objects.create(
            title='Draft Post',
            slug='draft-post',
            content='This is a draft post content.',
            excerpt='Draft post excerpt.',
            author=self.user,
            category=self.category,
            status=Post.Status.DRAFT
        )
        
        self.other_user_post = Post.objects.create(
            title='Other User Post',
            slug='other-user-post',
            content='This is another user\'s post.',
            excerpt='Other user post excerpt.',
            author=self.other_user,
            category=self.other_category,
            status=Post.Status.PUBLISHED,
            published_at=timezone.now()
        )
    
    def setup_comments(self):
        """Create test comments."""
        self.comment = Comment.objects.create(
            post=self.published_post,
            author=self.other_user,
            content='This is a test comment.',
            is_approved=True
        )
        self.pending_comment = Comment.objects.create(
            post=self.published_post,
            author=self.user,
            content='This is a pending comment.',
            is_approved=False
        )
```

---

## Target 8.3: Testing Models

### The Concept

Model tests verify that:
- Models are created correctly
- Relationships work
- Custom methods return expected values
- Validation works

### The Implementation

**File: `blog/tests/test_models.py`** (create new)

```python
from django.test import TestCase
from django.contrib.auth.models import User
from django.utils import timezone
from django.core.exceptions import ValidationError
from blog.models import Category, Tag, Post, Comment, Profile
from blog.tests.test_utils import BaseTestCase


class CategoryModelTest(BaseTestCase):
    """Test the Category model."""
    
    def test_category_creation(self):
        """Test creating a category."""
        self.assertEqual(self.category.name, 'Test Category')
        self.assertEqual(self.category.slug, 'test-category')
        self.assertEqual(self.category.description, 'A test category')
    
    def test_category_str_method(self):
        """Test the __str__ method."""
        self.assertEqual(str(self.category), 'Test Category')
    
    def test_category_slug_auto_generation(self):
        """Test slug auto-generation when not provided."""
        category = Category.objects.create(name='New Category')
        self.assertEqual(category.slug, 'new-category')
    
    def test_category_get_absolute_url(self):
        """Test get_absolute_url method."""
        url = self.category.get_absolute_url()
        self.assertEqual(url, '/category/test-category/')
    
    def test_category_unique_slug(self):
        """Test that slugs must be unique."""
        with self.assertRaises(Exception):
            Category.objects.create(
                name='Test Category 2',
                slug='test-category'  # Duplicate slug
            )


class TagModelTest(BaseTestCase):
    """Test the Tag model."""
    
    def test_tag_creation(self):
        """Test creating a tag."""
        self.assertEqual(self.tag1.name, 'Test Tag 1')
        self.assertEqual(self.tag1.slug, 'test-tag-1')
    
    def test_tag_str_method(self):
        """Test the __str__ method."""
        self.assertEqual(str(self.tag1), 'Test Tag 1')
    
    def test_tag_slug_auto_generation(self):
        """Test slug auto-generation when not provided."""
        tag = Tag.objects.create(name='New Tag')
        self.assertEqual(tag.slug, 'new-tag')


class PostModelTest(BaseTestCase):
    """Test the Post model."""
    
    def test_post_creation(self):
        """Test creating a post."""
        self.assertEqual(self.published_post.title, 'Published Post')
        self.assertEqual(self.published_post.slug, 'published-post')
        self.assertEqual(self.published_post.author, self.user)
        self.assertEqual(self.published_post.category, self.category)
        self.assertEqual(self.published_post.status, Post.Status.PUBLISHED)
    
    def test_post_str_method(self):
        """Test the __str__ method."""
        self.assertEqual(str(self.published_post), 'Published Post')
    
    def test_post_get_absolute_url(self):
        """Test get_absolute_url method."""
        url = self.published_post.get_absolute_url()
        self.assertEqual(url, '/blog/published-post/')
    
    def test_post_get_comment_count(self):
        """Test get_comment_count method."""
        count = self.published_post.get_comment_count()
        self.assertEqual(count, 1)  # Only approved comments
    
    def test_post_is_published(self):
        """Test is_published method."""
        self.assertTrue(self.published_post.is_published())
        self.assertFalse(self.draft_post.is_published())
    
    def test_post_slug_auto_generation(self):
        """Test slug auto-generation when not provided."""
        post = Post.objects.create(
            title='My New Post',
            content='Content',
            author=self.user,
            status=Post.Status.DRAFT
        )
        self.assertEqual(post.slug, 'my-new-post')
    
    def test_post_excerpt_auto_generation(self):
        """Test excerpt auto-generation when not provided."""
        content = 'A' * 300  # 300 characters
        post = Post.objects.create(
            title='Test Post',
            content=content,
            author=self.user,
            status=Post.Status.DRAFT
        )
        self.assertEqual(len(post.excerpt), 200)  # First 200 chars
    
    def test_post_published_at_on_publish(self):
        """Test published_at is set when publishing."""
        draft = Post.objects.create(
            title='Test Draft',
            content='Content',
            author=self.user,
            status=Post.Status.DRAFT
        )
        self.assertIsNone(draft.published_at)
        
        # Change to published
        draft.status = Post.Status.PUBLISHED
        draft.save()
        draft.refresh_from_db()
        self.assertIsNotNone(draft.published_at)
    
    def test_post_meta_description_blank(self):
        """Test meta_description can be blank."""
        self.assertEqual(self.published_post.meta_description, '')
    
    def test_post_ordering(self):
        """Test posts are ordered by -created_at."""
        post1 = Post.objects.create(
            title='Older Post',
            content='Content',
            author=self.user,
            status=Post.Status.PUBLISHED,
            published_at=timezone.now()
        )
        post2 = Post.objects.create(
            title='Newer Post',
            content='Content',
            author=self.user,
            status=Post.Status.PUBLISHED,
            published_at=timezone.now()
        )
        posts = Post.objects.filter(status=Post.Status.PUBLISHED)
        self.assertEqual(posts.first().title, 'Newer Post')


class CommentModelTest(BaseTestCase):
    """Test the Comment model."""
    
    def test_comment_creation(self):
        """Test creating a comment."""
        self.assertEqual(self.comment.content, 'This is a test comment.')
        self.assertEqual(self.comment.post, self.published_post)
        self.assertEqual(self.comment.author, self.other_user)
        self.assertTrue(self.comment.is_approved)
    
    def test_comment_str_method(self):
        """Test the __str__ method."""
        expected = f"Comment by {self.other_user.username} on {self.published_post.title}"
        self.assertEqual(str(self.comment), expected)
    
    def test_comment_get_absolute_url(self):
        """Test get_absolute_url method."""
        url = self.comment.get_absolute_url()
        self.assertTrue('/blog/published-post/#comment-' in url)


class ProfileModelTest(BaseTestCase):
    """Test the Profile model."""
    
    def test_profile_creation_signal(self):
        """Test profile is created automatically for new users."""
        new_user = User.objects.create_user(
            username='newuser',
            email='new@example.com',
            password='newpass123'
        )
        self.assertTrue(hasattr(new_user, 'profile'))
        self.assertIsNotNone(new_user.profile)
    
    def test_profile_str_method(self):
        """Test the __str__ method."""
        expected = f"{self.user.username}'s Profile"
        self.assertEqual(str(self.user.profile), expected)
    
    def test_profile_get_avatar_url(self):
        """Test get_avatar_url method."""
        # Should return default avatar URL
        url = self.user.profile.get_avatar_url()
        self.assertEqual(url, '/static/blog/images/default-avatar.png')
```

---

## Target 8.4: Testing Forms

### The Concept

Form tests verify that:
- Valid data passes validation
- Invalid data fails validation
- Custom clean methods work
- Error messages are correct

### The Implementation

**File: `blog/tests/test_forms.py`** (create new)

```python
from django.test import TestCase
from django.core.files.uploadedfile import SimpleUploadedFile
from blog.forms import PostForm, CommentForm, ProfileForm
from blog.models import Category, Tag
from blog.tests.test_utils import BaseTestCase


class PostFormTest(BaseTestCase):
    """Test the PostForm."""
    
    def test_valid_post_form(self):
        """Test a valid post form."""
        form_data = {
            'title': 'Test Form Post',
            'content': 'This is content for the form test.',
            'category': self.category.id,
            'status': 'published',
            'tags_input': 'test, django'
        }
        form = PostForm(data=form_data)
        self.assertTrue(form.is_valid())
    
    def test_post_form_required_fields(self):
        """Test required fields in post form."""
        form = PostForm(data={})
        self.assertFalse(form.is_valid())
        self.assertIn('title', form.errors)
        self.assertIn('content', form.errors)
        self.assertIn('category', form.errors)
    
    def test_post_form_slug_auto_generation(self):
        """Test slug auto-generation in form."""
        form_data = {
            'title': 'Auto Slug Test',
            'content': 'Content',
            'category': self.category.id,
            'status': 'published'
        }
        form = PostForm(data=form_data)
        self.assertTrue(form.is_valid())
        
        # Clean the slug
        cleaned_data = form.clean()
        self.assertEqual(cleaned_data.get('slug'), 'auto-slug-test')
    
    def test_post_form_tags_processing(self):
        """Test tag processing in form."""
        form_data = {
            'title': 'Tag Test Post',
            'content': 'Content',
            'category': self.category.id,
            'status': 'published',
            'tags_input': 'python, django, web'
        }
        form = PostForm(data=form_data)
        self.assertTrue(form.is_valid())
        
        # Save the form
        post = form.save(commit=False)
        post.author = self.user
        post.save()
        form.save_m2m()
        
        # Check tags were created
        tags = post.tags.all()
        tag_names = [tag.name for tag in tags]
        self.assertIn('python', tag_names)
        self.assertIn('django', tag_names)
        self.assertIn('web', tag_names)
    
    def test_post_form_invalid_slug(self):
        """Test invalid slug validation."""
        # Create a post with a slug
        post = Post.objects.create(
            title='Existing Post',
            slug='existing-slug',
            content='Content',
            author=self.user,
            status=Post.Status.DRAFT
        )
        
        # Try to create another post with same slug
        form_data = {
            'title': 'New Post',
            'slug': 'existing-slug',
            'content': 'Content',
            'category': self.category.id,
            'status': 'published'
        }
        form = PostForm(data=form_data)
        self.assertFalse(form.is_valid())
        self.assertIn('slug', form.errors)
    
    def test_post_form_featured_image_validation(self):
        """Test featured image validation."""
        # Create a fake image file
        image = SimpleUploadedFile(
            'test.jpg',
            b'fake image content',
            content_type='image/jpeg'
        )
        
        form_data = {
            'title': 'Image Test',
            'content': 'Content',
            'category': self.category.id,
            'status': 'published'
        }
        form = PostForm(data=form_data, files={'featured_image': image})
        self.assertTrue(form.is_valid())
    
    def test_post_form_invalid_image_type(self):
        """Test invalid image type validation."""
        # Create a fake non-image file
        file = SimpleUploadedFile(
            'test.txt',
            b'text content',
            content_type='text/plain'
        )
        
        form_data = {
            'title': 'Invalid Image Test',
            'content': 'Content',
            'category': self.category.id,
            'status': 'published'
        }
        form = PostForm(data=form_data, files={'featured_image': file})
        self.assertFalse(form.is_valid())
        self.assertIn('featured_image', form.errors)
    
    def test_post_form_large_image(self):
        """Test large image validation."""
        # Create a large image file (5MB+)
        large_image = SimpleUploadedFile(
            'large.jpg',
            b'x' * (5 * 1024 * 1024 + 1),  # 5MB + 1 byte
            content_type='image/jpeg'
        )
        
        form_data = {
            'title': 'Large Image Test',
            'content': 'Content',
            'category': self.category.id,
            'status': 'published'
        }
        form = PostForm(data=form_data, files={'featured_image': large_image})
        self.assertFalse(form.is_valid())
        self.assertIn('featured_image', form.errors)


class CommentFormTest(TestCase):
    """Test the CommentForm."""
    
    def test_valid_comment_form(self):
        """Test a valid comment form."""
        from blog.forms import CommentForm
        form_data = {'content': 'This is a test comment.'}
        form = CommentForm(data=form_data)
        self.assertTrue(form.is_valid())
    
    def test_comment_form_required_content(self):
        """Test content is required in comment form."""
        from blog.forms import CommentForm
        form = CommentForm(data={})
        self.assertFalse(form.is_valid())
        self.assertIn('content', form.errors)
    
    def test_comment_form_empty_content(self):
        """Test empty content in comment form."""
        from blog.forms import CommentForm
        form_data = {'content': ''}
        form = CommentForm(data=form_data)
        self.assertFalse(form.is_valid())
        self.assertIn('content', form.errors)
```

---

## Target 8.5: Testing Views

### The Concept

View tests verify that:
- URLs return correct status codes
- Templates are rendered correctly
- Context data is correct
- Authentication/authorization works
- Redirects are correct

### The Implementation

**File: `blog/tests/test_views.py`** (create new)

```python
from django.test import TestCase, Client
from django.urls import reverse
from django.contrib.auth.models import User
from django.utils import timezone
from blog.models import Post, Category, Comment
from blog.tests.test_utils import BaseTestCase


class PublicViewTest(BaseTestCase):
    """Test public views."""
    
    def setUp(self):
        super().setUp()
        self.client = Client()
    
    def test_home_page_status(self):
        """Test home page loads."""
        response = self.client.get(reverse('blog:home'))
        self.assertEqual(response.status_code, 200)
        self.assertTemplateUsed(response, 'blog/home.html')
    
    def test_home_page_context(self):
        """Test home page context."""
        response = self.client.get(reverse('blog:home'))
        self.assertIn('recent_posts', response.context)
        self.assertIn('categories', response.context)
    
    def test_blog_list_status(self):
        """Test blog list page loads."""
        response = self.client.get(reverse('blog:blog_list'))
        self.assertEqual(response.status_code, 200)
        self.assertTemplateUsed(response, 'blog/blog_list.html')
    
    def test_blog_list_contains_posts(self):
        """Test blog list contains published posts."""
        response = self.client.get(reverse('blog:blog_list'))
        posts = response.context['posts']
        self.assertIn(self.published_post, posts)
        self.assertNotIn(self.draft_post, posts)
    
    def test_post_detail_status(self):
        """Test post detail page loads."""
        response = self.client.get(
            reverse('blog:post_detail', kwargs={'slug': self.published_post.slug})
        )
        self.assertEqual(response.status_code, 200)
        self.assertTemplateUsed(response, 'blog/post_detail.html')
    
    def test_post_detail_context(self):
        """Test post detail page context."""
        response = self.client.get(
            reverse('blog:post_detail', kwargs={'slug': self.published_post.slug})
        )
        self.assertEqual(response.context['post'], self.published_post)
        self.assertIn('recent_posts', response.context)
        self.assertIn('comments', response.context)
    
    def test_post_detail_not_found(self):
        """Test post detail page returns 404 for non-existent post."""
        response = self.client.get(
            reverse('blog:post_detail', kwargs={'slug': 'non-existent-slug'})
        )
        self.assertEqual(response.status_code, 404)
    
    def test_category_detail_status(self):
        """Test category detail page loads."""
        response = self.client.get(
            reverse('blog:category_detail', kwargs={'slug': self.category.slug})
        )
        self.assertEqual(response.status_code, 200)
        self.assertTemplateUsed(response, 'blog/category_detail.html')
    
    def test_category_detail_context(self):
        """Test category detail page context."""
        response = self.client.get(
            reverse('blog:category_detail', kwargs={'slug': self.category.slug})
        )
        self.assertEqual(response.context['category'], self.category)
        self.assertIn(self.published_post, response.context['posts'])
    
    def test_tag_detail_status(self):
        """Test tag detail page loads."""
        response = self.client.get(
            reverse('blog:tag_detail', kwargs={'slug': self.tag1.slug})
        )
        self.assertEqual(response.status_code, 200)
        self.assertTemplateUsed(response, 'blog/tag_detail.html')
    
    def test_tag_detail_context(self):
        """Test tag detail page context."""
        response = self.client.get(
            reverse('blog:tag_detail', kwargs={'slug': self.tag1.slug})
        )
        self.assertEqual(response.context['tag'], self.tag1)
        self.assertIn(self.published_post, response.context['posts'])


class AuthenticationViewTest(BaseTestCase):
    """Test authentication views."""
    
    def setUp(self):
        super().setUp()
        self.client = Client()
    
    def test_login_page_status(self):
        """Test login page loads."""
        response = self.client.get(reverse('login'))
        self.assertEqual(response.status_code, 200)
        self.assertTemplateUsed(response, 'registration/login.html')
    
    def test_login_success(self):
        """Test successful login."""
        response = self.client.post(reverse('login'), {
            'username': 'testuser',
            'password': 'testpass123'
        })
        self.assertRedirects(response, reverse('blog:home'))
    
    def test_login_failure(self):
        """Test login with invalid credentials."""
        response = self.client.post(reverse('login'), {
            'username': 'testuser',
            'password': 'wrongpassword'
        })
        self.assertEqual(response.status_code, 200)
        self.assertContains(response, 'Invalid username or password')
    
    def test_register_page_status(self):
        """Test register page loads."""
        response = self.client.get(reverse('register'))
        self.assertEqual(response.status_code, 200)
        self.assertTemplateUsed(response, 'registration/register.html')
    
    def test_register_success(self):
        """Test successful registration."""
        response = self.client.post(reverse('register'), {
            'username': 'newuser123',
            'email': 'new@example.com',
            'password1': 'testpass456',
            'password2': 'testpass456'
        })
        self.assertRedirects(response, reverse('blog:home'))
        self.assertTrue(User.objects.filter(username='newuser123').exists())
    
    def test_register_duplicate_username(self):
        """Test registration with duplicate username."""
        response = self.client.post(reverse('register'), {
            'username': 'testuser',  # Already exists
            'email': 'test2@example.com',
            'password1': 'testpass456',
            'password2': 'testpass456'
        })
        self.assertEqual(response.status_code, 200)
        self.assertContains(response, 'A user with that username already exists')


class CRUDViewTest(BaseTestCase):
    """Test CRUD views."""
    
    def setUp(self):
        super().setUp()
        self.client = Client()
        self.client.login(username='testuser', password='testpass123')
    
    def test_post_create_get(self):
        """Test post create page loads."""
        response = self.client.get(reverse('blog:post_create'))
        self.assertEqual(response.status_code, 200)
        self.assertTemplateUsed(response, 'blog/post_form.html')
    
    def test_post_create_success(self):
        """Test successful post creation."""
        response = self.client.post(reverse('blog:post_create'), {
            'title': 'Test Create Post',
            'content': 'This is a test post created via form.',
            'category': self.category.id,
            'status': 'published',
            'tags_input': 'test, create'
        })
        self.assertRedirects(response, reverse('blog:post_detail', kwargs={'slug': 'test-create-post'}))
        self.assertTrue(Post.objects.filter(slug='test-create-post').exists())
    
    def test_post_create_login_required(self):
        """Test post create requires login."""
        self.client.logout()
        response = self.client.get(reverse('blog:post_create'))
        self.assertRedirects(response, f'/login/?next={reverse("blog:post_create")}')
    
    def test_post_edit_get(self):
        """Test post edit page loads."""
        response = self.client.get(
            reverse('blog:post_edit', kwargs={'slug': self.published_post.slug})
        )
        self.assertEqual(response.status_code, 200)
        self.assertTemplateUsed(response, 'blog/post_form.html')
    
    def test_post_edit_success(self):
        """Test successful post edit."""
        response = self.client.post(
            reverse('blog:post_edit', kwargs={'slug': self.published_post.slug}),
            {
                'title': 'Updated Post Title',
                'content': 'This is updated content.',
                'category': self.category.id,
                'status': 'published',
                'tags_input': 'updated'
            }
        )
        self.assertRedirects(response, reverse('blog:post_detail', kwargs={'slug': 'updated-post-title'}))
        
        # Refresh post from database
        self.published_post.refresh_from_db()
        self.assertEqual(self.published_post.title, 'Updated Post Title')
    
    def test_post_edit_permission(self):
        """Test users can only edit their own posts."""
        self.client.logout()
        self.client.login(username='otheruser', password='otherpass123')
        
        response = self.client.get(
            reverse('blog:post_edit', kwargs={'slug': self.published_post.slug})
        )
        self.assertEqual(response.status_code, 302)  # Redirect with error
        self.assertRedirects(response, reverse('blog:post_detail', kwargs={'slug': self.published_post.slug}))
    
    def test_post_delete_get(self):
        """Test post delete confirmation page loads."""
        response = self.client.get(
            reverse('blog:post_delete', kwargs={'slug': self.published_post.slug})
        )
        self.assertEqual(response.status_code, 200)
        self.assertTemplateUsed(response, 'blog/post_confirm_delete.html')
    
    def test_post_delete_success(self):
        """Test successful post deletion."""
        response = self.client.post(
            reverse('blog:post_delete', kwargs={'slug': self.published_post.slug})
        )
        self.assertRedirects(response, reverse('blog:blog_list'))
        self.assertFalse(Post.objects.filter(slug='published-post').exists())
    
    def test_post_delete_permission(self):
        """Test users can only delete their own posts."""
        self.client.logout()
        self.client.login(username='otheruser', password='otherpass123')
        
        response = self.client.post(
            reverse('blog:post_delete', kwargs={'slug': self.published_post.slug})
        )
        self.assertEqual(response.status_code, 302)  # Redirect with error
        self.assertTrue(Post.objects.filter(slug='published-post').exists())


class CommentViewTest(BaseTestCase):
    """Test comment views."""
    
    def setUp(self):
        super().setUp()
        self.client = Client()
        self.client.login(username='testuser', password='testpass123')
    
    def test_comment_create_success(self):
        """Test successful comment creation."""
        response = self.client.post(
            reverse('blog:comment_create', kwargs={'post_slug': self.published_post.slug}),
            {'content': 'This is a test comment from view.'}
        )
        self.assertRedirects(response, reverse('blog:post_detail', kwargs={'slug': self.published_post.slug}))
        self.assertTrue(Comment.objects.filter(content='This is a test comment from view.').exists())
    
    def test_comment_create_login_required(self):
        """Test comment creation requires login."""
        self.client.logout()
        response = self.client.post(
            reverse('blog:comment_create', kwargs={'post_slug': self.published_post.slug}),
            {'content': 'This comment should not be created.'}
        )
        self.assertRedirects(response, f'/login/?next={reverse("blog:comment_create", kwargs={"post_slug": self.published_post.slug})}')
        self.assertFalse(Comment.objects.filter(content='This comment should not be created.').exists())
    
    def test_comment_create_empty_content(self):
        """Test comment creation with empty content."""
        response = self.client.post(
            reverse('blog:comment_create', kwargs={'post_slug': self.published_post.slug}),
            {'content': ''}
        )
        self.assertRedirects(response, reverse('blog:post_detail', kwargs={'slug': self.published_post.slug}))
        self.assertFalse(Comment.objects.filter(content='').exists())
```

---

## Target 8.6: Implementing Logging

### The Concept

**Logging** records information about your application's operation. It's essential for:
- Debugging issues in production
- Monitoring application health
- Tracking user actions
- Identifying security threats

### The Implementation

**File: `config/settings.py`** (add logging configuration)

```python
# config/settings.py

import logging.config

# Logging Configuration
LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'formatters': {
        'verbose': {
            'format': '{levelname} {asctime} {module} {process:d} {thread:d} {message}',
            'style': '{',
        },
        'simple': {
            'format': '{levelname} {asctime} {message}',
            'style': '{',
        },
        'django': {
            'format': '{levelname} {asctime} {name} {message}',
            'style': '{',
        },
    },
    'filters': {
        'require_debug_true': {
            '()': 'django.utils.log.RequireDebugTrue',
        },
        'require_debug_false': {
            '()': 'django.utils.log.RequireDebugFalse',
        },
    },
    'handlers': {
        'console': {
            'level': 'DEBUG',
            'filters': ['require_debug_true'],
            'class': 'logging.StreamHandler',
            'formatter': 'simple',
        },
        'file': {
            'level': 'INFO',
            'filters': ['require_debug_false'],
            'class': 'logging.handlers.RotatingFileHandler',
            'filename': BASE_DIR / 'logs' / 'django.log',
            'maxBytes': 1024 * 1024 * 10,  # 10 MB
            'backupCount': 5,
            'formatter': 'verbose',
        },
        'mail_admins': {
            'level': 'ERROR',
            'filters': ['require_debug_false'],
            'class': 'django.utils.log.AdminEmailHandler',
            'formatter': 'verbose',
        },
    },
    'loggers': {
        'django': {
            'handlers': ['console', 'file'],
            'level': 'INFO',
            'propagate': True,
        },
        'django.request': {
            'handlers': ['mail_admins', 'file'],
            'level': 'ERROR',
            'propagate': False,
        },
        'blog': {
            'handlers': ['console', 'file'],
            'level': 'DEBUG',
            'propagate': False,
        },
        'blog.middleware': {
            'handlers': ['console', 'file'],
            'level': 'INFO',
            'propagate': False,
        },
    },
}

# Ensure logs directory exists
import os
logs_dir = BASE_DIR / 'logs'
if not logs_dir.exists():
    logs_dir.mkdir()
```

Now add logging to your views:

**File: `blog/views.py`** (add logging)

```python
import logging
from django.views.generic import ListView, DetailView

logger = logging.getLogger(__name__)

class PostListView(ListView):
    # ... existing code ...
    
    def get_queryset(self):
        logger.info(f"Blog list accessed by user: {self.request.user}")
        return super().get_queryset()

class PostDetailView(DetailView):
    # ... existing code ...
    
    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        logger.info(f"Post detail accessed: {context['post'].title} by {self.request.user}")
        return context

@login_required
def post_create(request):
    logger.info(f"Post creation by user: {request.user}")
    # ... existing code ...
```

---

## Target 8.7: Adding Debugging Tools

### The Concept

Debugging tools help you understand what's happening in your application during development.

### The Implementation

Install Django Debug Toolbar:

```bash
uv pip install django-debug-toolbar
uv pip freeze > requirements.txt
```

**File: `config/settings.py`** (update)

```python
# config/settings.py

if DEBUG:
    INSTALLED_APPS += [
        'debug_toolbar',
    ]
    
    MIDDLEWARE.insert(0, 'debug_toolbar.middleware.DebugToolbarMiddleware')
    
    # Debug Toolbar settings
    INTERNAL_IPS = [
        '127.0.0.1',
        'localhost',
    ]
    
    DEBUG_TOOLBAR_CONFIG = {
        'SHOW_TOOLBAR_CALLBACK': lambda request: True,
    }
```

**File: `config/urls.py`** (update)

```python
from django.conf import settings

if settings.DEBUG:
    import debug_toolbar
    urlpatterns += [
        path('__debug__/', include(debug_toolbar.urls)),
    ]
```

---

## The Verification

### Step 1: Run the Tests

```bash
# Run all tests
python manage.py test blog

# Run specific test class
python manage.py test blog.tests.test_models.CategoryModelTest

# Run with verbosity
python manage.py test blog --verbosity=2

# Run with coverage (if coverage is installed)
uv pip install coverage
coverage run manage.py test blog
coverage report
```

### Step 2: Check Test Output

You should see output like:
```
Creating test database for alias 'default'...
System check identified no issues (0 silenced).
.......................
----------------------------------------------------------------------
Ran 23 tests in 1.234s

OK
Destroying test database for alias 'default'...
```

### Step 3: Check Logging

```bash
# Start the server and visit some pages
python manage.py runserver

# Check the console for log messages
# Check logs/django.log for file logs
```

### Step 4: Use Debug Toolbar

1. Start the server
2. Visit any page
3. Look for the debug toolbar on the right side
4. Explore SQL queries, cache, headers, etc.

---

## Target 8.8: Code Quality with Pre-commit Hooks

### The Concept

Pre-commit hooks automatically check code quality before commits.

### The Implementation

Install pre-commit:

```bash
uv pip install pre-commit black flake8 isort
uv pip freeze > requirements.txt
```

**File: `.pre-commit-config.yaml`** (create new)

```yaml
repos:
  - repo: https://github.com/psf/black
    rev: 24.3.0
    hooks:
      - id: black
        language_version: python3.14

  - repo: https://github.com/PyCQA/isort
    rev: 5.13.2
    hooks:
      - id: isort
        args: ["--profile", "black"]

  - repo: https://github.com/PyCQA/flake8
    rev: 7.0.0
    hooks:
      - id: flake8
        args: ["--max-line-length=88", "--extend-ignore=E203,W503"]

  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.5.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-added-large-files
      - id: check-merge-conflict
      - id: detect-private-key
```

Install the hooks:

```bash
pre-commit install
```

---

## What You've Learned in Part 8

### ✅ Skills Acquired
- Writing unit tests for models
- Writing tests for forms
- Writing tests for views
- Implementing logging
- Using debugging tools
- Setting up pre-commit hooks

### ✅ What You've Built
- Comprehensive test suite
- Logging configuration
- Debug toolbar setup
- Code quality automation
