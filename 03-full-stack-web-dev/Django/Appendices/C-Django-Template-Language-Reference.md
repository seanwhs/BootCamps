# Appendix C: Django Template Language Reference

## Welcome to Appendix C!

This appendix provides a comprehensive reference for Django's template language. You'll find everything from basic syntax to advanced features, complete with examples for each tag, filter, and template feature.

---

## C.1: Template Syntax Basics

### Variable Display

```html
<!-- Basic variable display -->
{{ variable }}

<!-- With default value -->
{{ variable|default:"Nothing" }}

<!-- Safe HTML (don't auto-escape) -->
{{ html_content|safe }}

<!-- Escape HTML (force escaping) -->
{{ user_input|escape }}

<!-- Debugging -->
{{ variable|debug }}
```

### Comments

```html
{# Single line comment #}

{% comment %}
Multi-line comment
This won't appear in the output
{% endcomment %}
```

### Whitespace Control

```html
<!-- Remove whitespace around tags -->
{% if user %}{{ user.username }}{% endif %}

<!-- Trimming whitespace with minus signs -->
{% if user -%}
    {{ user.username }}
{%- endif %}

<!-- The - removes whitespace before/after the tag -->
```

---

## C.2: Template Tags

### Conditional Tags

#### {% if %}

```html
<!-- Basic if -->
{% if user.is_authenticated %}
    <p>Welcome, {{ user.username }}!</p>
{% endif %}

<!-- If-else -->
{% if post.status == 'published' %}
    <span class="published">Published</span>
{% else %}
    <span class="draft">Draft</span>
{% endif %}

<!-- If-elif-else -->
{% if user.is_superuser %}
    <p>You are a superuser</p>
{% elif user.is_staff %}
    <p>You are staff</p>
{% else %}
    <p>You are a regular user</p>
{% endif %}

<!-- Complex conditions -->
{% if user.is_authenticated and user.has_perm('blog.add_post') %}
    <a href="{% url 'post_create' %}">Create Post</a>
{% endif %}

{% if not post.is_published %}
    <p>This post is not yet published</p>
{% endif %}

{% if post.category.name in 'Technology,Python' %}
    <p>This is a tech post</p>
{% endif %}

{% if post.author == request.user or user.is_superuser %}
    <p>You can edit this post</p>
{% endif %}
```

#### {% for %}

```html
<!-- Basic loop -->
<ul>
    {% for post in posts %}
        <li>{{ post.title }}</li>
    {% endfor %}
</ul>

<!-- Loop with empty fallback -->
<ul>
    {% for post in posts %}
        <li>{{ post.title }}</li>
    {% empty %}
        <li>No posts available</li>
    {% endfor %}
</ul>

<!-- Loop with forloop variables -->
{% for post in posts %}
    <p>
        {{ forloop.counter }}. {{ post.title }}
        {% if forloop.first %}⭐ First{% endif %}
        {% if forloop.last %}🏁 Last{% endif %}
    </p>
    
    <!-- Forloop variables -->
    <ul>
        <li>Counter: {{ forloop.counter }}</li>        <!-- 1-indexed -->
        <li>Counter0: {{ forloop.counter0 }}</li>      <!-- 0-indexed -->
        <li>Rev Counter: {{ forloop.revcounter }}</li> <!-- 1-indexed from end -->
        <li>Rev Counter0: {{ forloop.revcounter0 }}</li> <!-- 0-indexed from end -->
        <li>First: {{ forloop.first }}</li>            <!-- Boolean -->
        <li>Last: {{ forloop.last }}</li>              <!-- Boolean -->
        <li>Parent Loop: {{ forloop.parentloop }}</li> <!-- For nested loops -->
    </ul>
{% endfor %}

<!-- Loop with reversed -->
{% for post in posts reversed %}
    <li>{{ post.title }}</li>
{% endfor %}

<!-- Loop over dictionary -->
<dl>
    {% for key, value in post.metadata.items %}
        <dt>{{ key }}</dt>
        <dd>{{ value }}</dd>
    {% endfor %}
</dl>

<!-- Break loop (requires custom tag or Django 3.2+) -->
<!-- Use a custom template tag for break functionality -->
```

#### {% with %}

```html
<!-- Assign variable -->
{% with total=posts|length %}
    <p>Total posts: {{ total }}</p>
{% endwith %}

<!-- Multiple assignments -->
{% with user=post.author|default:"Anonymous" date=post.created_at|date:"Y-m-d" %}
    <p>By {{ user }} on {{ date }}</p>
{% endwith %}

<!-- Assignment with complex expression -->
{% with full_name=user.first_name|add:" "|add:user.last_name %}
    <p>Welcome, {{ full_name }}!</p>
{% endwith %}
```

#### {% ifchanged %}

```html
<!-- Display only when value changes -->
{% for post in posts %}
    {% ifchanged post.category %}
        <h2>{{ post.category.name }}</h2>
    {% endifchanged %}
    <p>{{ post.title }}</p>
{% endfor %}

<!-- With multiple variables -->
{% for item in items %}
    {% ifchanged item.category item.status %}
        <hr>
    {% endifchanged %}
    <p>{{ item.name }}</p>
{% endfor %}
```

### Inheritance Tags

#### {% extends %}

```html
<!-- Extend base template -->
{% extends 'blog/base.html' %}

<!-- Extend with dynamic path -->
{% extends base_template|default:'blog/base.html' %}

<!-- Extend from different app -->
{% extends 'admin/base_site.html' %}

<!-- Multiple inheritance (not directly supported) -->
<!-- Use nested extends: child extends parent, parent extends grandparent -->
```

#### {% block %}

```html
<!-- Base template -->
<!DOCTYPE html>
<html>
<head>
    <title>{% block title %}Default Title{% endblock %}</title>
    {% block extra_head %}{% endblock %}
</head>
<body>
    {% block content %}
        <p>Default content</p>
    {% endblock %}
    
    {% block footer %}
        <footer>&copy; 2026</footer>
    {% endblock %}
</body>
</html>

<!-- Child template -->
{% extends 'base.html' %}

{% block title %}
    {{ page_title }} - My Site
{% endblock %}

{% block content %}
    <div class="content">
        {{ block.super }}  <!-- Include parent content -->
        <p>Additional content</p>
    </div>
{% endblock %}

{% block extra_head %}
    <link rel="stylesheet" href="/static/custom.css">
{% endblock %}

<!-- Override a block completely -->
{% block footer %}
    <!-- This completely replaces the footer block -->
    <footer>Custom footer</footer>
{% endblock %}
```

#### {% include %}

```html
<!-- Basic include -->
{% include 'blog/includes/header.html' %}

<!-- Include with context -->
{% include 'blog/includes/post_card.html' with post=post %}

<!-- Include with only specific variables -->
{% include 'blog/includes/post_card.html' with post=post only %}

<!-- Include with fallback -->
{% include 'blog/includes/feature.html' %}

<!-- Include with variable path -->
{% include template_name|default:'default_template.html' %}

<!-- Include multiple times -->
{% for post in posts %}
    {% include 'blog/includes/post_card.html' with post=post %}
{% endfor %}
```

#### {% load %}

```html
<!-- Load built-in tags -->
{% load static %}
{% load i18n %}
{% load humanize %}

<!-- Load custom template tags -->
{% load blog_tags %}
{% load custom_filters %}

<!-- Load multiple tags -->
{% load static blog_tags custom_filters %}

<!-- Load from specific app -->
{% load blog_tags from blog %}
```

### URL Tags

#### {% url %}

```html
<!-- Basic URL -->
<a href="{% url 'blog:home' %}">Home</a>

<!-- URL with parameters -->
<a href="{% url 'blog:post_detail' slug=post.slug %}">{{ post.title }}</a>

<!-- URL with positional parameters -->
<a href="{% url 'blog:post_detail' post.slug %}">{{ post.title }}</a>

<!-- URL with multiple parameters -->
<a href="{% url 'blog:post_search' category=category slug=slug %}">Search</a>

<!-- URL with query string -->
<a href="{% url 'blog:blog_list' %}?page={{ page }}">Page {{ page }}</a>

<!-- URL with variable -->
<a href="{% url url_name arg1 arg2 %}">Link</a>

<!-- URL with as variable -->
{% url 'blog:post_detail' slug=post.slug as post_url %}
<a href="{{ post_url }}">{{ post.title }}</a>
```

#### {% static %}

```html
<!-- Load static tag -->
{% load static %}

<!-- Basic static file -->
<img src="{% static 'blog/images/logo.png' %}" alt="Logo">

<!-- Static file with variable -->
<link rel="stylesheet" href="{% static css_file|default:'blog/css/style.css' %}">

<!-- Static file with versioning -->
<link rel="stylesheet" href="{% static 'blog/css/style.css' %}?v=1.0">

<!-- Static file from different app -->
<img src="{% static 'admin/img/icon-yes.svg' %}" alt="Yes">

<!-- Static with as variable -->
{% static 'blog/images/default.jpg' as default_image %}
<img src="{{ default_image }}" alt="Default">

<!-- Static with JavaScript -->
<script src="{% static 'blog/js/main.js' %}"></script>
```

#### {% media %}

```html
<!-- Media files (user-uploaded) -->
{% load static %}

<!-- Display media file -->
<img src="{{ post.featured_image.url }}" alt="{{ post.title }}">

<!-- Media with fallback -->
{% if post.featured_image %}
    <img src="{{ post.featured_image.url }}" alt="{{ post.title }}">
{% else %}
    <img src="{% static 'blog/images/default.jpg' %}" alt="No image">
{% endif %}

<!-- Media with thumbnail -->
<img src="{{ post.featured_image.thumbnail.url }}" alt="{{ post.title }}">
```

### Special Tags

#### {% csrf_token %}

```html
<!-- Must be inside form for POST requests -->
<form method="post">
    {% csrf_token %}
    <!-- Form fields -->
    <button type="submit">Submit</button>
</form>
```

#### {% now %}

```html
<!-- Current date/time -->
<p>{% now "Y-m-d" %}</p>           <!-- 2026-03-15 -->
<p>{% now "F j, Y g:i a" %}</p>     <!-- March 15, 2026 2:30 pm -->
<p>{% now "r" %}</p>                <!-- Thu, 15 Mar 2026 14:30:00 +0000 -->
<p>{% now "DATE_FORMAT" %}</p>      <!-- March 15, 2026 -->
<p>{% now "DATETIME_FORMAT" %}</p>  <!-- March 15, 2026, 2:30 p.m. -->

<!-- Using now with as variable -->
{% now "Y-m-d" as current_date %}
<p>Today is {{ current_date }}</p>
```

#### {% trans %} and {% blocktrans %}

```html
<!-- Internationalization -->
{% load i18n %}

<!-- Simple translation -->
<p>{% trans "Welcome to our blog" %}</p>

<!-- Translation with variable -->
{% blocktrans with name=user.username %}
    Welcome, {{ name }}!
{% endblocktrans %}

<!-- Translation with multiple variables -->
{% blocktrans with first_name=user.first_name last_name=user.last_name %}
    Hello {{ first_name }} {{ last_name }}
{% endblocktrans %}

<!-- Translation with pluralization -->
{% blocktrans count counter=posts|length %}
    There is {{ counter }} post
{% plural %}
    There are {{ counter }} posts
{% endblocktrans %}
```

#### {% resetcycle %}

```html
<!-- Reset cycle in loops -->
{% for post in posts %}
    <div class="{% cycle 'row1' 'row2' %}">
        {{ post.title }}
    </div>
    {% resetcycle %}
{% endfor %}
```

#### {% cycle %}

```html
<!-- Cycle through values -->
{% for post in posts %}
    <tr class="{% cycle 'even' 'odd' %}">
        <td>{{ post.title }}</td>
    </tr>
{% endfor %}

<!-- Cycle with current value -->
{% for post in posts %}
    <div class="{% cycle 'row1' 'row2' 'row3' as row_color %}">
        Row color: {{ row_color }}
    </div>
{% endfor %}
```

---

## C.3: Template Filters

### String Filters

#### capfirst

```html
{{ "hello world"|capfirst }}  <!-- Hello world -->
{{ name|capfirst }}           <!-- John (from "john") -->
```

#### lower / upper

```html
{{ "Hello World"|lower }}     <!-- hello world -->
{{ "Hello World"|upper }}     <!-- HELLO WORLD -->
```

#### title

```html
{{ "hello world"|title }}     <!-- Hello World -->
{{ "django blog"|title }}     <!-- Django Blog -->
```

#### truncatechars / truncatechars_html

```html
{{ long_text|truncatechars:50 }}        <!-- First 50 characters + "..." -->
{{ html_content|truncatechars_html:50 }} <!-- Same, but preserves HTML -->
```

#### truncatewords / truncatewords_html

```html
{{ long_text|truncatewords:30 }}        <!-- First 30 words + "..." -->
{{ html_content|truncatewords_html:30 }} <!-- Same, preserves HTML -->
```

#### wordcount

```html
{{ content|wordcount }}  <!-- Number of words in content -->
```

#### length

```html
{{ posts|length }}       <!-- Number of items in posts -->
{{ name|length }}        <!-- Length of string -->
```

#### slice

```html
{{ "Hello World"|slice:"2:5" }}  <!-- llo -->
{{ posts|slice:"0:5" }}          <!-- First 5 posts -->
{{ posts|slice:":5" }}           <!-- First 5 posts -->
{{ posts|slice:"5:" }}           <!-- From 5 to end -->
{{ posts|slice:"-5:" }}          <!-- Last 5 -->
```

#### add

```html
{{ "Hello"|add:" World" }}   <!-- Hello World -->
{{ 10|add:5 }}              <!-- 15 -->
{{ price|add:5 }}           <!-- price + 5 -->
```

#### cut

```html
{{ "Hello World"|cut:" " }}  <!-- HelloWorld -->
{{ "a,b,c"|cut:"," }}       <!-- abc -->
```

#### escape / escapejs

```html
{{ user_input|escape }}      <!-- Escape HTML entities -->
{{ user_input|escapejs }}    <!-- Escape for JavaScript -->
```

#### linebreaks / linebreaksbr

```html
{{ text|linebreaks }}    <!-- Convert newlines to <p> tags -->
{{ text|linebreaksbr }}  <!-- Convert newlines to <br> tags -->
```

#### removetags

```html
{{ html|removetags:"script style" }}  <!-- Remove script and style tags -->
```

#### slugify

```html
{{ "Hello World!"|slugify }}  <!-- hello-world -->
{{ post.title|slugify }}      <!-- Auto-generate slug -->
```

#### urlize / urlizetrunc

```html
{{ text|urlize }}                        <!-- Convert URLs to links -->
{{ text|urlizetrunc:30 }}                <!-- Truncate URLs to 30 chars -->
```

#### wordwrap

```html
{{ long_text|wordwrap:80 }}  <!-- Wrap at 80 characters -->
```

### Number Filters

#### addslashes

```html
{{ "Hello 'World'"|addslashes }}  <!-- Hello \'World\' -->
```

#### date

```html
{{ post.created_at|date:"Y-m-d" }}        <!-- 2026-03-15 -->
{{ post.created_at|date:"F j, Y" }}       <!-- March 15, 2026 -->
{{ post.created_at|date:"g:i a" }}        <!-- 2:30 pm -->
{{ post.created_at|date:"DATE_FORMAT" }}  <!-- March 15, 2026 -->
{{ post.created_at|date:"DATETIME_FORMAT" }} <!-- March 15, 2026, 2:30 p.m. -->
```

#### time

```html
{{ post.created_at|time:"H:i:s" }}  <!-- 14:30:00 -->
{{ post.created_at|time:"g:i a" }}  <!-- 2:30 pm -->
```

#### timesince / timeuntil

```html
{{ post.created_at|timesince }}        <!-- 2 days, 3 hours ago -->
{{ post.created_at|timesince:now }}    <!-- Time since -->
{{ event_date|timeuntil }}             <!-- 3 days, 2 hours from now -->
```

#### floatformat

```html
{{ price|floatformat }}          <!-- 12.34 -->
{{ price|floatformat:2 }}        <!-- 12.34 -->
{{ price|floatformat:0 }}        <!-- 12 -->
{{ price|floatformat:"-3" }}     <!-- 12.340 -->
```

#### filesizeformat

```html
{{ file_size|filesizeformat }}   <!-- 2.5 MB -->
{{ 1024|filesizeformat }}        <!-- 1.0 KB -->
{{ 1048576|filesizeformat }}     <!-- 1.0 MB -->
```

#### phone2numeric

```html
{{ "1-800-CALL-ME"|phone2numeric }}  <!-- 1-800-2255-63 -->
```

#### pluralize

```html
{{ posts|length }} post{{ posts|length|pluralize }}  <!-- 3 posts -->
{{ posts|length }} post{{ posts|length|pluralize:"es" }}  <!-- 1 post, 2 posts -->
```

### List Filters

#### dictsort / dictsortreversed

```html
<!-- Sort list of dicts -->
{{ posts|dictsort:"title" }}
{{ posts|dictsortreversed:"created_at" }}
```

#### first / last

```html
{{ posts|first }}  <!-- First post in list -->
{{ posts|last }}   <!-- Last post in list -->
```

#### join

```html
{{ tags|join:", " }}  <!-- python, django, web -->
{{ tags|join:" and " }}  <!-- python and django and web -->
```

#### length / length_is

```html
{% if posts|length > 5 %}
    <p>More than 5 posts</p>
{% endif %}

{% if posts|length_is:0 %}
    <p>No posts</p>
{% endif %}
```

#### random

```html
{{ posts|random }}  <!-- Random post from list -->
```

### Database Filters

#### safe / safe_join

```html
<!-- safe: Mark as safe HTML -->
{{ html_content|safe }}

<!-- safe_join: Safe URL joining -->
{{ base_url|safe_join:"path/to/file" }}
```

### Custom Filters Example

**File: `blog/templatetags/blog_filters.py`**

```python
from django import template
import re

register = template.Library()

@register.filter(name='highlight')
def highlight(text, search_term):
    """Highlight search terms in text."""
    if not search_term:
        return text
    return re.sub(
        f'({search_term})',
        r'<mark>\1</mark>',
        text,
        flags=re.IGNORECASE
    )

@register.filter
def excerpt(text, length=200):
    """Generate excerpt from text."""
    if len(text) <= length:
        return text
    return text[:length] + '...'

@register.filter
def stars(value, max_stars=5):
    """Convert rating to stars."""
    filled = '★' * min(value, max_stars)
    empty = '☆' * (max_stars - min(value, max_stars))
    return filled + empty

@register.filter
def format_currency(value, currency='$'):
    """Format as currency."""
    return f"{currency}{value:,.2f}"
```

---

## C.4: Template Inheritance Deep Dive

### Base Template Pattern

**File: `templates/base.html`**

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{% block title %}My Site{% endblock %}</title>
    
    <!-- Meta tags -->
    <meta name="description" content="{% block meta_description %}Default description{% endblock %}">
    <meta name="keywords" content="{% block meta_keywords %}django, blog{% endblock %}">
    
    <!-- CSS -->
    {% block extra_head %}
        <link rel="stylesheet" href="{% static 'css/style.css' %}">
    {% endblock %}
    
    <!-- Additional head content -->
    {% block head_extra %}{% endblock %}
</head>
<body>
    <!-- Header -->
    <header>
        {% block header %}
            {% include 'includes/header.html' %}
        {% endblock %}
    </header>
    
    <!-- Navigation -->
    <nav>
        {% block navigation %}
            {% include 'includes/navigation.html' %}
        {% endblock %}
    </nav>
    
    <!-- Messages -->
    {% if messages %}
        <div class="messages">
            {% for message in messages %}
                <div class="message {{ message.tags }}">
                    {{ message }}
                </div>
            {% endfor %}
        </div>
    {% endif %}
    
    <!-- Main Content -->
    <main>
        {% block content %}
            <p>Default content</p>
        {% endblock %}
    </main>
    
    <!-- Footer -->
    <footer>
        {% block footer %}
            {% include 'includes/footer.html' %}
        {% endblock %}
    </footer>
    
    <!-- JavaScript -->
    {% block scripts %}
        <script src="{% static 'js/main.js' %}"></script>
    {% endblock %}
    
    <!-- Additional scripts -->
    {% block scripts_extra %}{% endblock %}
</body>
</html>
```

### Child Template Pattern

**File: `blog/templates/blog/post_list.html`**

```html
{% extends 'base.html' %}
{% load static %}

{% block title %}
    {{ page_title }} - My Blog
{% endblock %}

{% block meta_description %}
    Browse all posts on my blog
{% endblock %}

{% block extra_head %}
    {{ block.super }}
    <link rel="stylesheet" href="{% static 'blog/css/blog.css' %}">
{% endblock %}

{% block content %}
    <div class="blog-list">
        <h1>{{ page_title }}</h1>
        
        {% for post in posts %}
            <article>
                <h2><a href="{{ post.get_absolute_url }}">{{ post.title }}</a></h2>
                <p class="meta">
                    By {{ post.author.username }}
                    on {{ post.published_at|date:"F j, Y" }}
                </p>
                <p>{{ post.excerpt|truncatewords:30 }}</p>
                <a href="{{ post.get_absolute_url }}">Read more →</a>
            </article>
        {% empty %}
            <p>No posts available</p>
        {% endfor %}
    </div>
{% endblock %}

{% block scripts %}
    {{ block.super }}
    <script src="{% static 'blog/js/blog.js' %}"></script>
{% endblock %}
```

---

## C.5: Custom Template Tags

### Simple Tag

**File: `blog/templatetags/blog_tags.py`**

```python
from django import template
from blog.models import Category, Post

register = template.Library()

@register.simple_tag
def get_categories():
    """Get all categories with post counts."""
    from django.db.models import Count
    return Category.objects.annotate(
        post_count=Count('posts')
    ).filter(post_count__gt=0)

@register.simple_tag(takes_context=True)
def get_recent_posts(context, count=5):
    """Get recent posts."""
    request = context.get('request')
    return Post.objects.filter(
        status=Post.Status.PUBLISHED
    ).order_by('-published_at')[:count]

@register.simple_tag
def render_markdown(text):
    """Render markdown text to HTML."""
    import markdown
    return markdown.markdown(text)
```

**Usage:**
```html
{% load blog_tags %}

<ul>
    {% for category in get_categories %}
        <li>{{ category.name }} ({{ category.post_count }})</li>
    {% endfor %}
</ul>

{% get_recent_posts 10 as recent_posts %}
{% for post in recent_posts %}
    <li>{{ post.title }}</li>
{% endfor %}

{{ content|render_markdown }}
```

### Inclusion Tag

```python
@register.inclusion_tag('blog/includes/post_card.html')
def render_post_card(post, show_author=True):
    """Render a post card with optional author."""
    return {
        'post': post,
        'show_author': show_author,
        'comment_count': post.comments.filter(is_approved=True).count(),
    }
```

**Usage:**
```html
{% load blog_tags %}

{% for post in posts %}
    {% render_post_card post show_author=True %}
{% endfor %}
```

### Assignment Tag

```python
@register.assignment_tag
def get_comment_count(post):
    """Get comment count for a post."""
    return post.comments.filter(is_approved=True).count()
```

**Usage:**
```html
{% load blog_tags %}

{% get_comment_count post as comment_count %}
<p>{{ comment_count }} comments</p>
```

### Filter with Multiple Arguments

```python
@register.filter
def timesince_pretty(value):
    """Format timesince with days, hours, minutes."""
    from django.utils import timesince
    result = timesince.timesince(value)
    # Custom formatting
    return result.replace('weeks', 'w').replace('days', 'd')
```

**Usage:**
```html
{{ post.created_at|timesince_pretty }}
```

---

## C.6: Built-in Template Context Processors

### Debug Context Processor

```html
<!-- Only available when DEBUG=True -->
{% if debug %}
    <p>Debug mode is enabled</p>
{% endif %}

<!-- SQL queries (only in debug mode) -->
{% if sql_queries %}
    <div class="sql-debug">
        {% for query in sql_queries %}
            <p>{{ query.sql|escape }}</p>
        {% endfor %}
    </div>
{% endif %}
```

### Request Context Processor

```html
<!-- Access request object -->
<p>Current path: {{ request.path }}</p>
<p>GET parameters: {{ request.GET }}</p>
<p>User agent: {{ request.META.HTTP_USER_AGENT }}</p>

<!-- Check if user is authenticated -->
{% if request.user.is_authenticated %}
    <p>Welcome, {{ request.user.username }}</p>
{% endif %}
```

### Auth Context Processor

```html
<!-- User object -->
<p>Username: {{ user.username }}</p>
<p>User email: {{ user.email }}</p>
<p>Is authenticated: {{ user.is_authenticated }}</p>
<p>Is superuser: {{ user.is_superuser }}</p>

<!-- Permissions -->
{% if perms.blog.add_post %}
    <a href="{% url 'post_create' %}">Create Post</a>
{% endif %}

{% if perms.blog.can_publish %}
    <a href="{% url 'post_publish' post.slug %}">Publish</a>
{% endif %}
```

### Messages Context Processor

```html
{% if messages %}
    <ul class="messages">
        {% for message in messages %}
            <li class="message {{ message.tags }}">
                {{ message }}
            </li>
        {% endfor %}
    </ul>
{% endif %}
```

---

## C.7: Common Template Patterns

### Pagination Pattern

```html
{% if page_obj.has_other_pages %}
    <div class="pagination">
        {% if page_obj.has_previous %}
            <a href="?page={{ page_obj.previous_page_number }}">Previous</a>
        {% endif %}
        
        <span class="current">
            Page {{ page_obj.number }} of {{ page_obj.paginator.num_pages }}
        </span>
        
        {% if page_obj.has_next %}
            <a href="?page={{ page_obj.next_page_number }}">Next</a>
        {% endif %}
    </div>
{% endif %}
```

### Form Pattern

```html
<form method="post" enctype="multipart/form-data" novalidate>
    {% csrf_token %}
    
    {% if form.errors %}
        <div class="form-errors">
            <strong>Please correct the following errors:</strong>
            <ul>
                {% for field, errors in form.errors.items %}
                    {% for error in errors %}
                        <li>{{ field|capfirst }}: {{ error }}</li>
                    {% endfor %}
                {% endfor %}
            </ul>
        </div>
    {% endif %}
    
    {% for field in form %}
        <div class="form-group">
            <label for="{{ field.id_for_label }}">
                {{ field.label }}
                {% if field.field.required %}
                    <span class="required">*</span>
                {% endif %}
            </label>
            
            {{ field }}
            
            {% if field.help_text %}
                <small class="help-text">{{ field.help_text }}</small>
            {% endif %}
            
            {% if field.errors %}
                <div class="field-errors">
                    {{ field.errors }}
                </div>
            {% endif %}
        </div>
    {% endfor %}
    
    <button type="submit">Submit</button>
</form>
```

### List with Filter Form Pattern

```html
<form method="get" class="filter-form">
    <input type="text" name="q" placeholder="Search..." value="{{ search_query }}">
    
    <select name="category">
        <option value="">All Categories</option>
        {% for category in categories %}
            <option value="{{ category.slug }}" {% if selected_category == category.slug %}selected{% endif %}>
                {{ category.name }}
            </option>
        {% endfor %}
    </select>
    
    <button type="submit">Filter</button>
</form>

<div class="results">
    {% for item in items %}
        <div class="item">
            <h3><a href="{% url 'item_detail' slug=item.slug %}">{{ item.title }}</a></h3>
            <p>{{ item.description|truncatewords:30 }}</p>
        </div>
    {% empty %}
        <p>No items found</p>
    {% endfor %}
</div>
```

---

## C.8: Performance Tips

### Use `{% if %}` Efficiently

```html
<!-- Bad: querying database in template -->
{% if post.author.first_name %}
    <p>{{ post.author.first_name }}</p>
{% endif %}

<!-- Good: already loaded in view -->
<p>{{ post.author.first_name }}</p>
```

### Cache Template Fragments

```html
{% load cache %}

<!-- Cache for 5 minutes -->
{% cache 300 sidebar %}
    <div class="sidebar">
        {% include 'includes/sidebar.html' %}
    </div>
{% endcache %}

<!-- Cache with version -->
{% cache 300 sidebar request.user.is_authenticated %}
    <div class="sidebar">
        {% include 'includes/sidebar.html' %}
    </div>
{% endcache %}

<!-- Cache by name -->
{% cache 300 sidebar request.LANGUAGE_CODE %}
    <div class="sidebar">
        {% include 'includes/sidebar.html' %}
    </div>
{% endcache %}
```

### Use `{% with %}` for Complex Expressions

```html
<!-- Avoid multiple evaluations -->
{% with total=posts|length %}
    <p>Found {{ total }} post{{ total|pluralize }}</p>
{% endwith %}

<!-- Use with for complex values -->
{% with full_name=user.first_name|add:" "|add:user.last_name %}
    <p>Welcome, {{ full_name }}</p>
{% endwith %}
```

---

## C.9: Debugging Templates

### Using `{% debug %}`

```html
<!-- Display all template context variables -->
{% debug %}

<!-- Outputs something like:
{
    'user': User: admin,
    'posts': [<Post: Post 1>, <Post: Post 2>],
    ...
}
-->
```

### Template Error Page

When a template error occurs, Django shows a detailed error page with:
- Error message and line number
- Full template source
- Context variables
- Traceback

### Manual Debugging

```html
<!-- Check if variable exists -->
{% if variable %}
    <p>Variable: {{ variable }}</p>
{% else %}
    <p>Variable is undefined or empty</p>
{% endif %}

<!-- Check variable type -->
{{ variable|default:"<empty>" }}

<!-- Check list length -->
{{ posts|length }} posts

<!-- Force error to see variable (remove when not debugging) -->
{{ unknown_variable }}
```

---

This appendix provides a comprehensive reference for Django's template language. Use it as a quick reference when building your templates!
