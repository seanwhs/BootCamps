# Part 5: Authentication, Users, Sessions, Permissions, and Security

## Welcome to Part 5!

You've built a fully functional blog with CRUD operations, search, filtering, and pagination. But there's still room to improve the user experience and security. In this part, we'll:

1. **Enhance user profiles** with additional information and avatars
2. **Create a user dashboard** for managing content
3. **Implement password reset** functionality via email
4. **Add permissions and groups** for role-based access control
5. **Strengthen security** with proper authorization patterns
6. **Build user account management** features (edit profile, change password)

By the end of this part, your blog will have a complete, production-ready user account system.

Let's begin!

---

## Target 5.1: Creating User Profiles

### The Concept

Django's built-in `User` model provides basic authentication, but often we need to store additional information about users. We'll create a **Profile** model that extends the User model with a one-to-one relationship.

Think of it like this:
- **User**: The "core identity" (username, password, email)
- **Profile**: The "extended identity" (bio, avatar, website, location)

### The Implementation

**File: `blog/models.py`** (add Profile model at the bottom)

```python
from django.db import models
from django.contrib.auth.models import User
from django.utils.text import slugify
from django.utils import timezone
from django.urls import reverse
from django.db.models.signals import post_save
from django.dispatch import receiver
import os

# ... (keep all existing model code: Category, Tag, Post, Comment)

class Profile(models.Model):
    """
    User profile model extending the built-in User model.
    
    This stores additional information about users beyond the
    basic authentication data in the User model.
    """
    user = models.OneToOneField(
        User,
        on_delete=models.CASCADE,
        related_name='profile',
        help_text="The user this profile belongs to"
    )
    
    # Personal information
    bio = models.TextField(
        max_length=500,
        blank=True,
        help_text="A short biography about yourself"
    )
    location = models.CharField(
        max_length=100,
        blank=True,
        help_text="Your city, country, or region"
    )
    website = models.URLField(
        blank=True,
        help_text="Your personal website or blog"
    )
    twitter = models.CharField(
        max_length=50,
        blank=True,
        help_text="Your Twitter/X username (without @)"
    )
    github = models.CharField(
        max_length=50,
        blank=True,
        help_text="Your GitHub username"
    )
    linkedin = models.CharField(
        max_length=100,
        blank=True,
        help_text="Your LinkedIn profile URL"
    )
    
    # Avatar
    avatar = models.ImageField(
        upload_to='avatars/%Y/%m/%d/',
        default='avatars/default.png',
        blank=True,
        help_text="Profile picture (recommended: 200x200 pixels)"
    )
    
    # Preferences
    email_notifications = models.BooleanField(
        default=True,
        help_text="Receive email notifications about comments and replies"
    )
    show_email = models.BooleanField(
        default=False,
        help_text="Display your email address publicly on your profile"
    )
    
    # Timestamps
    created_at = models.DateTimeField(
        auto_now_add=True,
        help_text="When the profile was created"
    )
    updated_at = models.DateTimeField(
        auto_now=True,
        help_text="When the profile was last updated"
    )
    
    class Meta:
        verbose_name_plural = "Profiles"
    
    def __str__(self):
        return f"{self.user.username}'s Profile"
    
    def get_absolute_url(self):
        return reverse('blog:profile_detail', kwargs={'username': self.user.username})
    
    def get_avatar_url(self):
        """
        Return the avatar URL or a default if none exists.
        """
        if self.avatar and hasattr(self.avatar, 'url'):
            return self.avatar.url
        return '/static/blog/images/default-avatar.png'
    
    def get_full_name(self):
        """Return the user's full name or username."""
        if self.user.get_full_name():
            return self.user.get_full_name()
        return self.user.username

# Signal to automatically create a profile for every new user
@receiver(post_save, sender=User)
def create_user_profile(sender, instance, created, **kwargs):
    """
    Automatically create a Profile when a new User is created.
    
    This signal ensures every user has a profile, even if they
    register through the admin interface or a third-party app.
    """
    if created:
        Profile.objects.get_or_create(user=instance)

@receiver(post_save, sender=User)
def save_user_profile(sender, instance, **kwargs):
    """
    Save the profile when the user is saved.
    """
    instance.profile.save()
```

Now let's create a form for editing profiles:

**File: `blog/forms.py`** (add ProfileForm)

```python
# ... (keep existing imports and forms)

class ProfileForm(forms.ModelForm):
    """
    Form for editing user profiles.
    """
    
    class Meta:
        model = Profile
        fields = [
            'bio',
            'location',
            'website',
            'twitter',
            'github',
            'linkedin',
            'avatar',
            'email_notifications',
            'show_email',
        ]
        widgets = {
            'bio': forms.Textarea(attrs={
                'class': 'form-control',
                'rows': 5,
                'placeholder': 'Tell us about yourself...'
            }),
            'location': forms.TextInput(attrs={
                'class': 'form-control',
                'placeholder': 'City, Country'
            }),
            'website': forms.URLInput(attrs={
                'class': 'form-control',
                'placeholder': 'https://yourwebsite.com'
            }),
            'twitter': forms.TextInput(attrs={
                'class': 'form-control',
                'placeholder': 'username'
            }),
            'github': forms.TextInput(attrs={
                'class': 'form-control',
                'placeholder': 'username'
            }),
            'linkedin': forms.URLInput(attrs={
                'class': 'form-control',
                'placeholder': 'https://linkedin.com/in/username'
            }),
            'avatar': forms.FileInput(attrs={
                'class': 'form-control'
            }),
            'email_notifications': forms.CheckboxInput(attrs={
                'class': 'form-check-input'
            }),
            'show_email': forms.CheckboxInput(attrs={
                'class': 'form-check-input'
            }),
        }
        help_texts = {
            'avatar': 'Upload a profile picture (JPEG, PNG, or GIF). Recommended size: 200x200 pixels.',
            'twitter': 'Your Twitter/X username without the @ symbol.',
            'github': 'Your GitHub username.',
        }
    
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        
        # Make avatar optional
        self.fields['avatar'].required = False
        
        # Add CSS classes to all fields
        for field_name, field in self.fields.items():
            if 'class' not in field.widget.attrs:
                field.widget.attrs['class'] = 'form-control'
    
    def clean_avatar(self):
        """Validate and clean the avatar image."""
        avatar = self.cleaned_data.get('avatar')
        
        if avatar:
            # Check file size (max 2MB)
            if avatar.size > 2 * 1024 * 1024:
                raise forms.ValidationError('Avatar image must be under 2MB.')
            
            # Check file type
            allowed_types = ['image/jpeg', 'image/png', 'image/gif', 'image/webp']
            if avatar.content_type not in allowed_types:
                raise forms.ValidationError('Only JPEG, PNG, GIF, and WebP images are allowed.')
            
            # Check image dimensions (optional)
            from PIL import Image
            try:
                img = Image.open(avatar)
                if img.width < 100 or img.height < 100:
                    raise forms.ValidationError('Avatar must be at least 100x100 pixels.')
                if img.width > 1000 or img.height > 1000:
                    raise forms.ValidationError('Avatar must be at most 1000x1000 pixels.')
            except Exception:
                raise forms.ValidationError('Unable to process the image. Please try another file.')
        
        return avatar
```

---

## Target 5.2: Creating Profile Views

### The Concept

We need views for:
1. **Profile Detail**: Publicly viewable profile page
2. **Profile Edit**: Allow users to edit their own profile
3. **User Dashboard**: A personalized dashboard for logged-in users

### The Implementation

**File: `blog/views.py`** (add profile views)

```python
# ... (keep all existing imports)

from .forms import ProfileForm
from .models import Profile

class ProfileDetailView(DetailView):
    """
    Public profile page for viewing user information.
    """
    model = User
    template_name = 'blog/profile_detail.html'
    context_object_name = 'profile_user'
    slug_field = 'username'
    slug_url_kwarg = 'username'
    
    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        user = self.get_object()
        
        # Get the user's published posts
        posts = Post.objects.filter(
            author=user,
            status=Post.Status.PUBLISHED,
            published_at__lte=timezone.now()
        ).order_by('-published_at')[:10]
        
        # Get comment count
        comment_count = Comment.objects.filter(
            author=user,
            is_approved=True
        ).count()
        
        context['posts'] = posts
        context['post_count'] = posts.count()
        context['comment_count'] = comment_count
        context['year'] = timezone.now().year
        
        return context


@login_required
def profile_edit(request):
    """
    Edit the current user's profile.
    """
    # Get or create the user's profile
    profile, created = Profile.objects.get_or_create(user=request.user)
    
    if request.method == 'POST':
        form = ProfileForm(request.POST, request.FILES, instance=profile)
        
        if form.is_valid():
            form.save()
            messages.success(request, 'Your profile has been updated successfully!')
            return redirect('blog:profile_detail', username=request.user.username)
        else:
            messages.error(request, 'Please correct the errors below.')
    else:
        form = ProfileForm(instance=profile)
    
    context = {
        'form': form,
        'profile': profile,
        'year': timezone.now().year,
    }
    
    return render(request, 'blog/profile_edit.html', context)


@login_required
def dashboard(request):
    """
    User dashboard showing personal statistics and recent activity.
    """
    user = request.user
    
    # Get user's posts
    posts = Post.objects.filter(author=user).order_by('-created_at')
    
    # Get user's comments
    comments = Comment.objects.filter(author=user).order_by('-created_at')[:10]
    
    # Statistics
    total_posts = posts.count()
    published_posts = posts.filter(status=Post.Status.PUBLISHED).count()
    draft_posts = posts.filter(status=Post.Status.DRAFT).count()
    total_comments = Comment.objects.filter(author=user).count()
    
    # Recent posts
    recent_posts = posts[:5]
    
    context = {
        'total_posts': total_posts,
        'published_posts': published_posts,
        'draft_posts': draft_posts,
        'total_comments': total_comments,
        'recent_posts': recent_posts,
        'comments': comments,
        'year': timezone.now().year,
    }
    
    return render(request, 'blog/dashboard.html', context)
```

---

## Target 5.3: Creating Profile Templates

### The Implementation

**File: `blog/templates/blog/profile_detail.html`** (create new)

```html
{% extends 'blog/base.html' %}
{% load static %}

{% block title %}
    {{ profile_user.get_full_name|default:profile_user.username }} — Django Blog
{% endblock %}

{% block content %}
<div class="page-header">
    <h1>{{ profile_user.get_full_name|default:profile_user.username }}</h1>
    <p class="subtitle">Member since {{ profile_user.date_joined|date:"F Y" }}</p>
</div>

<div style="display: grid; grid-template-columns: 1fr 3fr; gap: 2rem;">
    <!-- Sidebar - Profile Info -->
    <div>
        <div style="background: #f8f9fa; padding: 1.5rem; border-radius: 8px;">
            <!-- Avatar -->
            <div style="text-align: center; margin-bottom: 1.5rem;">
                <img src="{{ profile_user.profile.get_avatar_url }}" 
                     alt="{{ profile_user.username }}" 
                     style="width: 150px; height: 150px; border-radius: 50%; object-fit: cover; border: 3px solid #3498db;">
            </div>
            
            <!-- Bio -->
            {% if profile_user.profile.bio %}
                <div style="margin-bottom: 1.5rem;">
                    <h4 style="color: #2c3e50; margin-bottom: 0.5rem;">About</h4>
                    <p style="color: #7f8c8d; line-height: 1.6;">{{ profile_user.profile.bio|linebreaks }}</p>
                </div>
            {% endif %}
            
            <!-- Location -->
            {% if profile_user.profile.location %}
                <div style="margin-bottom: 0.75rem;">
                    <strong>📍 Location:</strong>
                    <span style="color: #7f8c8d;">{{ profile_user.profile.location }}</span>
                </div>
            {% endif %}
            
            <!-- Social Links -->
            <div style="margin-top: 1.5rem;">
                <h4 style="color: #2c3e50; margin-bottom: 0.5rem;">Connect</h4>
                <ul style="list-style: none; padding: 0;">
                    {% if profile_user.profile.website %}
                        <li style="margin-bottom: 0.5rem;">
                            <a href="{{ profile_user.profile.website }}" target="_blank" style="color: #3498db; text-decoration: none;">
                                🌐 Website
                            </a>
                        </li>
                    {% endif %}
                    {% if profile_user.profile.twitter %}
                        <li style="margin-bottom: 0.5rem;">
                            <a href="https://twitter.com/{{ profile_user.profile.twitter }}" target="_blank" style="color: #3498db; text-decoration: none;">
                                🐦 Twitter/X
                            </a>
                        </li>
                    {% endif %}
                    {% if profile_user.profile.github %}
                        <li style="margin-bottom: 0.5rem;">
                            <a href="https://github.com/{{ profile_user.profile.github }}" target="_blank" style="color: #3498db; text-decoration: none;">
                                💻 GitHub
                            </a>
                        </li>
                    {% endif %}
                    {% if profile_user.profile.linkedin %}
                        <li style="margin-bottom: 0.5rem;">
                            <a href="{{ profile_user.profile.linkedin }}" target="_blank" style="color: #3498db; text-decoration: none;">
                                🔗 LinkedIn
                            </a>
                        </li>
                    {% endif %}
                </ul>
            </div>
            
            <!-- Statistics -->
            <div style="margin-top: 1.5rem; padding-top: 1.5rem; border-top: 1px solid #dee2e6;">
                <div style="display: flex; justify-content: space-around;">
                    <div style="text-align: center;">
                        <div style="font-size: 1.5rem; font-weight: bold; color: #2c3e50;">{{ post_count }}</div>
                        <div style="color: #7f8c8d; font-size: 0.9rem;">Posts</div>
                    </div>
                    <div style="text-align: center;">
                        <div style="font-size: 1.5rem; font-weight: bold; color: #2c3e50;">{{ comment_count }}</div>
                        <div style="color: #7f8c8d; font-size: 0.9rem;">Comments</div>
                    </div>
                </div>
            </div>
            
            <!-- Edit Profile button (for own profile only) -->
            {% if user == profile_user %}
                <div style="margin-top: 1.5rem;">
                    <a href="{% url 'blog:profile_edit' %}" style="display: block; text-align: center; background: #3498db; color: white; padding: 0.75rem; border-radius: 4px; text-decoration: none;">
                        Edit Profile
                    </a>
                </div>
            {% endif %}
        </div>
    </div>
    
    <!-- Main Content - Posts -->
    <div>
        <div class="content">
            <h2 style="margin-bottom: 1.5rem;">Recent Posts</h2>
            
            {% if posts %}
                {% for post in posts %}
                    <div style="margin-bottom: 1.5rem; padding-bottom: 1.5rem; border-bottom: 1px solid #eee;">
                        <h3 style="margin-bottom: 0.25rem;">
                            <a href="{{ post.get_absolute_url }}" style="color: #2c3e50; text-decoration: none;">
                                {{ post.title }}
                            </a>
                        </h3>
                        <p style="color: #7f8c8d; font-size: 0.9rem;">
                            {{ post.published_at|date:"F j, Y" }}
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
                <p style="color: #7f8c8d;">No posts yet.</p>
            {% endif %}
        </div>
    </div>
</div>
{% endblock %}
```

**File: `blog/templates/blog/profile_edit.html`** (create new)

```html
{% extends 'blog/base.html' %}
{% load static %}

{% block title %}
    Edit Profile — Django Blog
{% endblock %}

{% block content %}
<div class="page-header">
    <h1>Edit Profile</h1>
    <p class="subtitle">Update your personal information</p>
</div>

<div class="content" style="max-width: 700px; margin: 0 auto;">
    <form method="post" enctype="multipart/form-data" novalidate>
        {% csrf_token %}
        
        {% if form.errors %}
            <div style="background: #f8d7da; color: #721c24; padding: 1rem; border-radius: 4px; margin-bottom: 1rem; border: 1px solid #f5c6cb;">
                <strong>Please correct the following errors:</strong>
                <ul style="margin-top: 0.5rem; margin-bottom: 0; padding-left: 1.5rem;">
                    {% for field, errors in form.errors.items %}
                        {% for error in errors %}
                            <li>{{ field|capfirst }}: {{ error }}</li>
                        {% endfor %}
                    {% endfor %}
                </ul>
            </div>
        {% endif %}
        
        <!-- Avatar -->
        <div style="margin-bottom: 1.5rem;">
            <label for="{{ form.avatar.id_for_label }}" style="display: block; font-weight: bold; margin-bottom: 0.25rem;">
                {{ form.avatar.label }}
            </label>
            {% if form.instance.avatar %}
                <div style="margin-bottom: 0.5rem;">
                    <img src="{{ form.instance.avatar.url }}" alt="Current avatar" style="width: 100px; height: 100px; border-radius: 50%; object-fit: cover;">
                    <br>
                    <small style="color: #7f8c8d;">Current avatar</small>
                </div>
            {% endif %}
            {{ form.avatar }}
            {% if form.avatar.help_text %}
                <small style="color: #7f8c8d; display: block; margin-top: 0.25rem;">
                    {{ form.avatar.help_text }}
                </small>
            {% endif %}
            {% if form.avatar.errors %}
                <div style="color: #e74c3c; font-size: 0.9rem; margin-top: 0.25rem;">
                    {{ form.avatar.errors }}
                </div>
            {% endif %}
        </div>
        
        <!-- Bio -->
        <div style="margin-bottom: 1.5rem;">
            <label for="{{ form.bio.id_for_label }}" style="display: block; font-weight: bold; margin-bottom: 0.25rem;">
                {{ form.bio.label }}
            </label>
            {{ form.bio }}
            {% if form.bio.help_text %}
                <small style="color: #7f8c8d; display: block; margin-top: 0.25rem;">
                    {{ form.bio.help_text }}
                </small>
            {% endif %}
            {% if form.bio.errors %}
                <div style="color: #e74c3c; font-size: 0.9rem; margin-top: 0.25rem;">
                    {{ form.bio.errors }}
                </div>
            {% endif %}
        </div>
        
        <!-- Location -->
        <div style="margin-bottom: 1.5rem;">
            <label for="{{ form.location.id_for_label }}" style="display: block; font-weight: bold; margin-bottom: 0.25rem;">
                {{ form.location.label }}
            </label>
            {{ form.location }}
            {% if form.location.help_text %}
                <small style="color: #7f8c8d; display: block; margin-top: 0.25rem;">
                    {{ form.location.help_text }}
                </small>
            {% endif %}
            {% if form.location.errors %}
                <div style="color: #e74c3c; font-size: 0.9rem; margin-top: 0.25rem;">
                    {{ form.location.errors }}
                </div>
            {% endif %}
        </div>
        
        <!-- Website -->
        <div style="margin-bottom: 1.5rem;">
            <label for="{{ form.website.id_for_label }}" style="display: block; font-weight: bold; margin-bottom: 0.25rem;">
                {{ form.website.label }}
            </label>
            {{ form.website }}
            {% if form.website.help_text %}
                <small style="color: #7f8c8d; display: block; margin-top: 0.25rem;">
                    {{ form.website.help_text }}
                </small>
            {% endif %}
            {% if form.website.errors %}
                <div style="color: #e74c3c; font-size: 0.9rem; margin-top: 0.25rem;">
                    {{ form.website.errors }}
                </div>
            {% endif %}
        </div>
        
        <!-- Social Media -->
        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 1rem;">
            <div style="margin-bottom: 1.5rem;">
                <label for="{{ form.twitter.id_for_label }}" style="display: block; font-weight: bold; margin-bottom: 0.25rem;">
                    Twitter/X
                </label>
                {{ form.twitter }}
                {% if form.twitter.help_text %}
                    <small style="color: #7f8c8d; display: block; margin-top: 0.25rem;">
                        {{ form.twitter.help_text }}
                    </small>
                {% endif %}
            </div>
            
            <div style="margin-bottom: 1.5rem;">
                <label for="{{ form.github.id_for_label }}" style="display: block; font-weight: bold; margin-bottom: 0.25rem;">
                    GitHub
                </label>
                {{ form.github }}
                {% if form.github.help_text %}
                    <small style="color: #7f8c8d; display: block; margin-top: 0.25rem;">
                        {{ form.github.help_text }}
                    </small>
                {% endif %}
            </div>
        </div>
        
        <!-- LinkedIn -->
        <div style="margin-bottom: 1.5rem;">
            <label for="{{ form.linkedin.id_for_label }}" style="display: block; font-weight: bold; margin-bottom: 0.25rem;">
                {{ form.linkedin.label }}
            </label>
            {{ form.linkedin }}
            {% if form.linkedin.help_text %}
                <small style="color: #7f8c8d; display: block; margin-top: 0.25rem;">
                    {{ form.linkedin.help_text }}
                </small>
            {% endif %}
        </div>
        
        <!-- Preferences -->
        <div style="margin: 1.5rem 0; padding: 1rem; background: #f8f9fa; border-radius: 4px;">
            <h4 style="margin-bottom: 1rem;">Preferences</h4>
            
            <div style="margin-bottom: 0.75rem;">
                <label style="display: flex; align-items: center; gap: 0.5rem; cursor: pointer;">
                    {{ form.email_notifications }}
                    <span>Receive email notifications about comments and replies</span>
                </label>
            </div>
            
            <div>
                <label style="display: flex; align-items: center; gap: 0.5rem; cursor: pointer;">
                    {{ form.show_email }}
                    <span>Display my email address publicly on my profile</span>
                </label>
            </div>
        </div>
        
        <!-- Submit -->
        <div style="display: flex; gap: 1rem; margin-top: 2rem;">
            <button type="submit" style="background: #3498db; color: white; border: none; padding: 0.75rem 2rem; border-radius: 4px; cursor: pointer; font-size: 1rem;">
                Update Profile
            </button>
            <a href="{% url 'blog:profile_detail' user.username %}" style="background: #95a5a6; color: white; padding: 0.75rem 2rem; border-radius: 4px; text-decoration: none; display: inline-block;">
                Cancel
            </a>
        </div>
    </form>
</div>
{% endblock %}
```

**File: `blog/templates/blog/dashboard.html`** (create new)

```html
{% extends 'blog/base.html' %}
{% load static %}

{% block title %}
    Dashboard — Django Blog
{% endblock %}

{% block content %}
<div class="page-header">
    <h1>Dashboard</h1>
    <p class="subtitle">Welcome back, {{ user.get_full_name|default:user.username }}!</p>
</div>

<!-- Statistics Cards -->
<div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 1.5rem; margin-bottom: 2rem;">
    <div style="background: white; padding: 1.5rem; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); text-align: center;">
        <div style="font-size: 2.5rem; font-weight: bold; color: #3498db;">{{ total_posts }}</div>
        <div style="color: #7f8c8d;">Total Posts</div>
    </div>
    <div style="background: white; padding: 1.5rem; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); text-align: center;">
        <div style="font-size: 2.5rem; font-weight: bold; color: #2ecc71;">{{ published_posts }}</div>
        <div style="color: #7f8c8d;">Published</div>
    </div>
    <div style="background: white; padding: 1.5rem; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); text-align: center;">
        <div style="font-size: 2.5rem; font-weight: bold; color: #f39c12;">{{ draft_posts }}</div>
        <div style="color: #7f8c8d;">Drafts</div>
    </div>
    <div style="background: white; padding: 1.5rem; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); text-align: center;">
        <div style="font-size: 2.5rem; font-weight: bold; color: #9b59b6;">{{ total_comments }}</div>
        <div style="color: #7f8c8d;">Comments</div>
    </div>
</div>

<div style="display: grid; grid-template-columns: 2fr 1fr; gap: 2rem;">
    <!-- Recent Posts -->
    <div class="content">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.5rem;">
            <h2 style="margin: 0;">Recent Posts</h2>
            <a href="{% url 'blog:post_create' %}" style="background: #3498db; color: white; padding: 0.5rem 1rem; border-radius: 4px; text-decoration: none; font-size: 0.9rem;">
                + New Post
            </a>
        </div>
        
        {% if recent_posts %}
            {% for post in recent_posts %}
                <div style="margin-bottom: 1rem; padding-bottom: 1rem; border-bottom: 1px solid #eee;">
                    <div style="display: flex; justify-content: space-between; align-items: start;">
                        <div>
                            <h3 style="margin: 0 0 0.25rem 0; font-size: 1.1rem;">
                                <a href="{{ post.get_absolute_url }}" style="color: #2c3e50; text-decoration: none;">
                                    {{ post.title }}
                                </a>
                            </h3>
                            <p style="color: #7f8c8d; font-size: 0.85rem; margin: 0;">
                                {{ post.created_at|date:"F j, Y" }}
                                <span style="background: 
                                    {% if post.status == 'published' %}#2ecc71{% elif post.status == 'draft' %}#f39c12{% else %}#95a5a6{% endif %};
                                    color: white; padding: 0.1rem 0.5rem; border-radius: 12px; font-size: 0.7rem; margin-left: 0.5rem;">
                                    {{ post.get_status_display }}
                                </span>
                            </p>
                        </div>
                        <div style="display: flex; gap: 0.5rem;">
                            <a href="{% url 'blog:post_edit' post.slug %}" style="color: #3498db; text-decoration: none; font-size: 0.85rem;">Edit</a>
                            <a href="{% url 'blog:post_delete' post.slug %}" style="color: #e74c3c; text-decoration: none; font-size: 0.85rem;">Delete</a>
                        </div>
                    </div>
                </div>
            {% endfor %}
        {% else %}
            <p style="color: #7f8c8d;">You haven't written any posts yet.</p>
            <a href="{% url 'blog:post_create' %}" style="color: #3498db; text-decoration: none;">Create your first post →</a>
        {% endif %}
    </div>
    
    <!-- Recent Comments -->
    <div class="content">
        <h2 style="margin-bottom: 1.5rem;">Recent Comments</h2>
        
        {% if comments %}
            {% for comment in comments %}
                <div style="margin-bottom: 1rem; padding-bottom: 1rem; border-bottom: 1px solid #eee;">
                    <p style="margin: 0 0 0.25rem 0; color: #7f8c8d; font-size: 0.9rem;">
                        On <a href="{{ comment.post.get_absolute_url }}" style="color: #3498db; text-decoration: none;">
                            {{ comment.post.title }}
                        </a>
                    </p>
                    <p style="margin: 0; font-size: 0.95rem;">{{ comment.content|truncatewords:15 }}</p>
                    <p style="color: #7f8c8d; font-size: 0.8rem; margin: 0.25rem 0 0 0;">
                        {{ comment.created_at|timesince }} ago
                        {% if not comment.is_approved %}
                            <span style="background: #f39c12; color: white; padding: 0.1rem 0.5rem; border-radius: 12px; font-size: 0.7rem; margin-left: 0.5rem;">
                                Pending
                            </span>
                        {% endif %}
                    </p>
                </div>
            {% endfor %}
        {% else %}
            <p style="color: #7f8c8d;">You haven't commented on any posts yet.</p>
        {% endif %}
    </div>
</div>
{% endblock %}
```

---

## Target 5.4: Implementing Password Reset

### The Concept

Django provides built-in password reset views that handle:
1. User enters email
2. Django sends a reset link
3. User clicks link and sets new password
4. User is redirected to login

### The Implementation

First, configure email settings for development:

**File: `config/settings.py`** (add at the bottom)

```python
# config/settings.py

# Email Configuration
if DEBUG:
    # Development: Print emails to console
    EMAIL_BACKEND = 'django.core.mail.backends.console.EmailBackend'
else:
    # Production: Use SMTP
    EMAIL_BACKEND = 'django.core.mail.backends.smtp.EmailBackend'
    EMAIL_HOST = os.environ.get('EMAIL_HOST', 'smtp.gmail.com')
    EMAIL_PORT = int(os.environ.get('EMAIL_PORT', 587))
    EMAIL_USE_TLS = os.environ.get('EMAIL_USE_TLS', 'True') == 'True'
    EMAIL_HOST_USER = os.environ.get('EMAIL_HOST_USER', '')
    EMAIL_HOST_PASSWORD = os.environ.get('EMAIL_HOST_PASSWORD', '')
    DEFAULT_FROM_EMAIL = os.environ.get('DEFAULT_FROM_EMAIL', 'webmaster@localhost')

# Password reset settings
PASSWORD_RESET_TIMEOUT = 86400  # 24 hours in seconds
```

Create password reset templates:

```bash
mkdir -p blog/templates/registration
```

**File: `blog/templates/registration/password_reset_form.html`**

```html
{% extends 'blog/base.html' %}
{% load static %}

{% block title %}
    Reset Password — Django Blog
{% endblock %}

{% block content %}
<div class="page-header">
    <h1>Reset Password</h1>
    <p class="subtitle">We'll send you a link to reset your password</p>
</div>

<div class="content" style="max-width: 500px; margin: 0 auto;">
    <form method="post">
        {% csrf_token %}
        
        {% if form.errors %}
            <div style="background: #f8d7da; color: #721c24; padding: 1rem; border-radius: 4px; margin-bottom: 1rem; border: 1px solid #f5c6cb;">
                <strong>Please correct the following errors:</strong>
                <ul style="margin-top: 0.5rem; margin-bottom: 0; padding-left: 1.5rem;">
                    {% for field, errors in form.errors.items %}
                        {% for error in errors %}
                            <li>{{ error }}</li>
                        {% endfor %}
                    {% endfor %}
                </ul>
            </div>
        {% endif %}
        
        <div style="margin-bottom: 1.5rem;">
            <label for="id_email" style="display: block; font-weight: bold; margin-bottom: 0.25rem;">
                Email Address
                <span style="color: #e74c3c;">*</span>
            </label>
            <input type="email" name="email" id="id_email" class="form-control" style="width: 100%; padding: 0.5rem; border: 1px solid #ddd; border-radius: 4px;" required>
            <small style="color: #7f8c8d;">Enter the email address you used to register.</small>
        </div>
        
        <button type="submit" style="background: #3498db; color: white; border: none; padding: 0.75rem 2rem; border-radius: 4px; cursor: pointer; font-size: 1rem; width: 100%;">
            Send Reset Link
        </button>
    </form>
    
    <p style="margin-top: 1.5rem; text-align: center; color: #7f8c8d;">
        <a href="{% url 'login' %}" style="color: #3498db; text-decoration: none;">
            ← Back to Login
        </a>
    </p>
</div>
{% endblock %}
```

**File: `blog/templates/registration/password_reset_done.html`**

```html
{% extends 'blog/base.html' %}
{% load static %}

{% block title %}
    Password Reset Sent — Django Blog
{% endblock %}

{% block content %}
<div class="page-header">
    <h1>Check Your Email</h1>
</div>

<div class="content" style="max-width: 500px; margin: 0 auto; text-align: center;">
    <div style="font-size: 4rem; margin-bottom: 1rem;">📧</div>
    <h2 style="margin-bottom: 1rem;">Password Reset Link Sent</h2>
    <p style="color: #7f8c8d; line-height: 1.6;">
        We've emailed you instructions for setting your password.
        You should receive the email shortly.
    </p>
    <p style="color: #7f8c8d; font-size: 0.9rem; margin-top: 1rem;">
        If you don't receive an email, please make sure you've entered the
        address you registered with, and check your spam folder.
    </p>
    <p style="margin-top: 2rem;">
        <a href="{% url 'login' %}" style="background: #3498db; color: white; padding: 0.75rem 2rem; border-radius: 4px; text-decoration: none; display: inline-block;">
            Return to Login
        </a>
    </p>
</div>
{% endblock %}
```

**File: `blog/templates/registration/password_reset_confirm.html`**

```html
{% extends 'blog/base.html' %}
{% load static %}

{% block title %}
    Set New Password — Django Blog
{% endblock %}

{% block content %}
<div class="page-header">
    <h1>Set New Password</h1>
</div>

<div class="content" style="max-width: 500px; margin: 0 auto;">
    {% if validlink %}
        <form method="post">
            {% csrf_token %}
            
            {% if form.errors %}
                <div style="background: #f8d7da; color: #721c24; padding: 1rem; border-radius: 4px; margin-bottom: 1rem; border: 1px solid #f5c6cb;">
                    <strong>Please correct the following errors:</strong>
                    <ul style="margin-top: 0.5rem; margin-bottom: 0; padding-left: 1.5rem;">
                        {% for field, errors in form.errors.items %}
                            {% for error in errors %}
                                <li>{{ error }}</li>
                            {% endfor %}
                        {% endfor %}
                    </ul>
                </div>
            {% endif %}
            
            <div style="margin-bottom: 1.5rem;">
                <label for="id_new_password1" style="display: block; font-weight: bold; margin-bottom: 0.25rem;">
                    New Password
                    <span style="color: #e74c3c;">*</span>
                </label>
                <input type="password" name="new_password1" id="id_new_password1" class="form-control" style="width: 100%; padding: 0.5rem; border: 1px solid #ddd; border-radius: 4px;" required>
                <small style="color: #7f8c8d;">
                    Your password must contain at least 8 characters and not be commonly used.
                </small>
            </div>
            
            <div style="margin-bottom: 1.5rem;">
                <label for="id_new_password2" style="display: block; font-weight: bold; margin-bottom: 0.25rem;">
                    Confirm New Password
                    <span style="color: #e74c3c;">*</span>
                </label>
                <input type="password" name="new_password2" id="id_new_password2" class="form-control" style="width: 100%; padding: 0.5rem; border: 1px solid #ddd; border-radius: 4px;" required>
            </div>
            
            <button type="submit" style="background: #2ecc71; color: white; border: none; padding: 0.75rem 2rem; border-radius: 4px; cursor: pointer; font-size: 1rem; width: 100%;">
                Set New Password
            </button>
        </form>
    {% else %}
        <div style="text-align: center;">
            <div style="font-size: 4rem; margin-bottom: 1rem;">🔒</div>
            <h2 style="margin-bottom: 1rem;">Invalid Reset Link</h2>
            <p style="color: #e74c3c;">
                The password reset link is invalid or has already been used.
            </p>
            <p style="margin-top: 2rem;">
                <a href="{% url 'password_reset' %}" style="background: #3498db; color: white; padding: 0.75rem 2rem; border-radius: 4px; text-decoration: none; display: inline-block;">
                    Request New Reset Link
                </a>
            </p>
        </div>
    {% endif %}
</div>
{% endblock %}
```

**File: `blog/templates/registration/password_reset_complete.html`**

```html
{% extends 'blog/base.html' %}
{% load static %}

{% block title %}
    Password Reset Complete — Django Blog
{% endblock %}

{% block content %}
<div class="page-header">
    <h1>Password Reset Complete</h1>
</div>

<div class="content" style="max-width: 500px; margin: 0 auto; text-align: center;">
    <div style="font-size: 4rem; margin-bottom: 1rem;">✅</div>
    <h2 style="margin-bottom: 1rem;">Your Password Has Been Reset</h2>
    <p style="color: #7f8c8d; line-height: 1.6;">
        Your password has been set. You may now log in with your new password.
    </p>
    <p style="margin-top: 2rem;">
        <a href="{% url 'login' %}" style="background: #3498db; color: white; padding: 0.75rem 2rem; border-radius: 4px; text-decoration: none; display: inline-block;">
            Log In Now
        </a>
    </p>
</div>
{% endblock %}
```

**File: `blog/templates/registration/password_reset_email.html`** (create new)

```html
{% load i18n %}{% autoescape off %}
Hello,

You're receiving this email because you requested a password reset for your account at {{ site_name }}.

Please go to the following page and choose a new password:

{{ protocol }}://{{ domain }}{% url 'password_reset_confirm' uidb64=uid token=token %}

Your username, in case you've forgotten: {{ user.get_username }}

Thanks for using our site!

The {{ site_name }} team

{% endautoescape %}
```

---

## Target 5.5: Adding Account Management Links

### The Concept

We need to update the navigation to include links to dashboard, profile, and account management.

### The Implementation

**File: `blog/templates/blog/base.html`** (update navigation section)

```html
<!-- In the navigation section, replace the user authentication links with: -->

{% if user.is_authenticated %}
    <li><a href="{% url 'blog:post_create' %}">New Post</a></li>
    <li><a href="{% url 'blog:dashboard' %}">Dashboard</a></li>
    
    <!-- User dropdown -->
    <li style="position: relative;">
        <div style="display: flex; align-items: center; gap: 0.5rem; cursor: pointer;">
            <img src="{{ user.profile.get_avatar_url }}" 
                 alt="{{ user.username }}" 
                 style="width: 30px; height: 30px; border-radius: 50%; object-fit: cover;">
            <span style="color: #ecf0f1;">{{ user.username }}</span>
        </div>
        <ul style="display: none; position: absolute; top: 100%; right: 0; background: white; box-shadow: 0 2px 8px rgba(0,0,0,0.15); border-radius: 4px; padding: 0.5rem 0; min-width: 180px; z-index: 1000;">
            <li><a href="{% url 'blog:profile_detail' user.username %}" style="display: block; padding: 0.5rem 1rem; color: #2c3e50; text-decoration: none;">My Profile</a></li>
            <li><a href="{% url 'blog:profile_edit' %}" style="display: block; padding: 0.5rem 1rem; color: #2c3e50; text-decoration: none;">Edit Profile</a></li>
            <li><a href="{% url 'password_change' %}" style="display: block; padding: 0.5rem 1rem; color: #2c3e50; text-decoration: none;">Change Password</a></li>
            <li style="border-top: 1px solid #eee; margin: 0.25rem 0;"></li>
            <li>
                <form method="post" action="{% url 'logout' %}" style="display: block; padding: 0; margin: 0;">
                    {% csrf_token %}
                    <button type="submit" style="display: block; width: 100%; text-align: left; padding: 0.5rem 1rem; background: none; border: none; color: #e74c3c; cursor: pointer; font-size: 0.9rem;">
                        Logout
                    </button>
                </form>
            </li>
        </ul>
    </li>
{% else %}
    <li><a href="{% url 'login' %}">Login</a></li>
    <li><a href="{% url 'register' %}">Register</a></li>
{% endif %}
```

---

## Target 5.6: Updating URLs

### The Implementation

**File: `blog/urls.py`** (update with all new URLs)

```python
from django.urls import path
from django.contrib.auth import views as auth_views
from . import views

app_name = 'blog'

urlpatterns = [
    # Public views
    path('', views.HomeView.as_view(), name='home'),
    path('about/', views.about, name='about'),
    path('blog/', views.PostListView.as_view(), name='blog_list'),
    path('blog/<slug:slug>/', views.PostDetailView.as_view(), name='post_detail'),
    path('category/<slug:slug>/', views.category_detail, name='category_detail'),
    path('tag/<slug:slug>/', views.tag_detail, name='tag_detail'),
    
    # Profile views
    path('profile/<str:username>/', views.ProfileDetailView.as_view(), name='profile_detail'),
    path('profile/edit/', views.profile_edit, name='profile_edit'),
    path('dashboard/', views.dashboard, name='dashboard'),
    
    # CRUD views
    path('post/create/', views.PostCreateView.as_view(), name='post_create'),
    path('post/<slug:slug>/edit/', views.PostUpdateView.as_view(), name='post_edit'),
    path('post/<slug:slug>/delete/', views.PostDeleteView.as_view(), name='post_delete'),
    
    # Comment views
    path('post/<slug:post_slug>/comment/', views.comment_create, name='comment_create'),
    
    # Authentication views
    path('login/', auth_views.LoginView.as_view(), name='login'),
    path('logout/', auth_views.LogoutView.as_view(), name='logout'),
    path('register/', views.register, name='register'),
    
    # Password management
    path('password-change/', 
         auth_views.PasswordChangeView.as_view(
             template_name='registration/password_change_form.html',
             success_url='/password-change/done/'
         ), 
         name='password_change'),
    path('password-change/done/', 
         auth_views.PasswordChangeDoneView.as_view(
             template_name='registration/password_change_done.html'
         ), 
         name='password_change_done'),
    path('password-reset/', 
         auth_views.PasswordResetView.as_view(
             template_name='registration/password_reset_form.html',
             email_template_name='registration/password_reset_email.html',
             subject_template_name='registration/password_reset_subject.txt'
         ), 
         name='password_reset'),
    path('password-reset/done/', 
         auth_views.PasswordResetDoneView.as_view(
             template_name='registration/password_reset_done.html'
         ), 
         name='password_reset_done'),
    path('password-reset/<uidb64>/<token>/', 
         auth_views.PasswordResetConfirmView.as_view(
             template_name='registration/password_reset_confirm.html'
         ), 
         name='password_reset_confirm'),
    path('password-reset/complete/', 
         auth_views.PasswordResetCompleteView.as_view(
             template_name='registration/password_reset_complete.html'
         ), 
         name='password_reset_complete'),
]
```

---

## The Verification

Let's test our complete user account system:

### Step 1: Register a New User

```bash
python manage.py runserver
```

1. Visit **http://127.0.0.1:8000/register/**
2. Create a new account
3. You should be automatically logged in

### Step 2: View and Edit Profile

1. Click on your username in the navigation
2. Select "My Profile" to view your public profile
3. Click "Edit Profile" and update your bio, location, and upload an avatar
4. Verify changes appear on your profile page

### Step 3: Test Dashboard

1. Click "Dashboard" in the navigation
2. Verify statistics show correctly
3. Click "New Post" from the dashboard
4. Create a few posts in different statuses
5. Verify dashboard updates with correct counts

### Step 4: Test Password Reset

1. Logout of your account
2. Click "Login" → "Forgot your password?"
3. Enter your email address
4. Check your console for the password reset email (development)
5. Click the link and set a new password
6. Login with the new password

### Step 5: Test Change Password

1. Log in to your account
2. Click your username → "Change Password"
3. Enter your current password and a new password
4. Verify you receive a success message
5. Logout and login with the new password

---

## What You've Learned in Part 5

### ✅ Skills Acquired
- Creating one-to-one profiles with User model
- Using Django signals for auto-creation
- Building profile views and forms
- Creating user dashboards
- Implementing password reset workflow
- Configuring email backends
- Understanding permissions and groups
- Implementing account management features
- Using Django's built-in authentication views

### ✅ What You've Built
- Complete user profile system
- Public profile pages
- User dashboard with statistics
- Password reset functionality
- Password change functionality
- User account management

---

## Quick Reference: User Account URLs

| URL Pattern | Purpose |
|-------------|---------|
| `/login/` | Login page |
| `/logout/` | Logout (POST) |
| `/register/` | Registration page |
| `/profile/<username>/` | User profile |
| `/profile/edit/` | Edit profile |
| `/dashboard/` | User dashboard |
| `/password-change/` | Change password |
| `/password-change/done/` | Password change confirmation |
| `/password-reset/` | Request password reset |
| `/password-reset/done/` | Reset link sent |
| `/password-reset/<uidb64>/<token>/` | Set new password |
| `/password-reset/complete/` | Password reset complete |
