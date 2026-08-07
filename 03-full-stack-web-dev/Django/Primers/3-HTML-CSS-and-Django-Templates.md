# Primer 3: HTML, CSS, and Django Templates

## Welcome to the Frontend Primer!

This primer is designed to give you a solid foundation in HTML, CSS, and Django's template language. You don't need to be a frontend expert to build Django applications, but understanding these concepts is essential for creating web interfaces.

By the end of this primer, you'll understand how HTML structures content, how CSS styles it, and how Django templates bring everything together with dynamic data.

---

## P.1: HTML Fundamentals

### What is HTML?

HTML (HyperText Markup Language) is the skeleton of every webpage. Think of it like the frame of a house — it defines the structure.

```html
<!DOCTYPE html>
<html>
<head>
    <title>My Page</title>
</head>
<body>
    <h1>Welcome!</h1>
    <p>This is a paragraph.</p>
</body>
</html>
```

### HTML Document Structure

Every HTML document has a basic structure:

```html
<!DOCTYPE html>    <!-- Tells the browser it's HTML5 -->
<html>             <!-- The root element -->
<head>             <!-- Meta information -->
    <meta charset="UTF-8">
    <title>Page Title</title>
</head>
<body>             <!-- Content goes here -->
    <!-- Everything visible on the page -->
</body>
</html>
```

### Common HTML Elements

#### Headings

```html
<h1>Main Heading</h1>      <!-- Largest -->
<h2>Subheading</h2>
<h3>Section Heading</h3>
<h4>Small Heading</h4>
<h5>Smaller Heading</h5>
<h6>Smallest Heading</h6>   <!-- Smallest -->
```

#### Paragraphs and Text

```html
<p>This is a paragraph of text.</p>
<p>Another paragraph with <strong>bold</strong> and <em>italic</em> text.</p>

<!-- Line break -->
<p>First line<br>Second line</p>

<!-- Horizontal rule (divider) -->
<hr>

<!-- Preformatted text (preserves spacing) -->
<pre>
    This text
        will keep its
    formatting
</pre>
```

#### Links

```html
<!-- Basic link -->
<a href="https://example.com">Visit Example</a>

<!-- Link to another page on your site -->
<a href="/about/">About Us</a>

<!-- Link with target (opens in new tab) -->
<a href="https://example.com" target="_blank">Open in New Tab</a>

<!-- Email link -->
<a href="mailto:contact@example.com">Email Us</a>
```

#### Images

```html
<!-- Basic image -->
<img src="photo.jpg" alt="A beautiful sunset">

<!-- Image with width and height -->
<img src="photo.jpg" alt="Sunset" width="300" height="200">

<!-- Image from another website -->
<img src="https://example.com/image.jpg" alt="External image">
```

#### Lists

```html
<!-- Unordered list (bullets) -->
<ul>
    <li>Item 1</li>
    <li>Item 2</li>
    <li>Item 3</li>
</ul>

<!-- Ordered list (numbers) -->
<ol>
    <li>First step</li>
    <li>Second step</li>
    <li>Third step</li>
</ol>

<!-- Nested lists -->
<ul>
    <li>Category 1
        <ul>
            <li>Sub-item A</li>
            <li>Sub-item B</li>
        </ul>
    </li>
    <li>Category 2</li>
</ul>
```

#### Tables

```html
<table>
    <thead>
        <tr>
            <th>Name</th>
            <th>Age</th>
            <th>City</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>Alice</td>
            <td>25</td>
            <td>New York</td>
        </tr>
        <tr>
            <td>Bob</td>
            <td>30</td>
            <td>Boston</td>
        </tr>
    </tbody>
</table>
```

#### Div and Span (Containers)

```html
<!-- Block-level container (takes full width) -->
<div class="container">
    <p>This is inside a div</p>
</div>

<!-- Inline container (takes only needed width) -->
<p>This is a <span class="highlight">highlighted</span> word.</p>
```

#### Forms

```html
<form action="/submit/" method="POST">
    <!-- Text input -->
    <label for="name">Name:</label>
    <input type="text" id="name" name="name" placeholder="Enter your name">
    
    <!-- Email input -->
    <label for="email">Email:</label>
    <input type="email" id="email" name="email" required>
    
    <!-- Password input -->
    <label for="password">Password:</label>
    <input type="password" id="password" name="password">
    
    <!-- Textarea -->
    <label for="message">Message:</label>
    <textarea id="message" name="message" rows="4"></textarea>
    
    <!-- Dropdown (select) -->
    <label for="country">Country:</label>
    <select id="country" name="country">
        <option value="us">United States</option>
        <option value="uk">United Kingdom</option>
        <option value="ca">Canada</option>
    </select>
    
    <!-- Radio buttons -->
    <label>Gender:</label>
    <input type="radio" id="male" name="gender" value="male">
    <label for="male">Male</label>
    <input type="radio" id="female" name="gender" value="female">
    <label for="female">Female</label>
    
    <!-- Checkbox -->
    <input type="checkbox" id="agree" name="agree" value="yes">
    <label for="agree">I agree to the terms</label>
    
    <!-- Submit button -->
    <button type="submit">Submit</button>
</form>
```

---

## P.2: CSS Fundamentals

### What is CSS?

CSS (Cascading Style Sheets) controls how HTML elements look — colors, fonts, layout, spacing, and more. Think of CSS as the paint, wallpaper, and furniture that makes the house look good.

### Three Ways to Add CSS

#### 1. Inline CSS (applied directly to an element)

```html
<p style="color: red; font-size: 20px;">This is red text</p>
```

#### 2. Internal CSS (in the `<head>` section)

```html
<!DOCTYPE html>
<html>
<head>
    <style>
        p {
            color: blue;
            font-size: 18px;
        }
        .highlight {
            background-color: yellow;
        }
    </style>
</head>
<body>
    <p>This is blue text</p>
    <p class="highlight">This has a yellow background</p>
</body>
</html>
```

#### 3. External CSS (separate file)

```html
<!-- HTML file -->
<!DOCTYPE html>
<html>
<head>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <p>Styled by external CSS</p>
</body>
</html>
```

```css
/* style.css */
p {
    color: green;
    font-size: 16px;
}
```

### CSS Selectors

Selectors determine which HTML elements get styled:

```css
/* Element selector - all paragraphs */
p {
    color: blue;
}

/* Class selector - elements with class="highlight" */
.highlight {
    background-color: yellow;
}

/* ID selector - element with id="header" */
#header {
    font-size: 24px;
}

/* Multiple selectors */
h1, h2, h3 {
    font-family: Arial, sans-serif;
}

/* Descendant selector - links inside paragraphs */
p a {
    color: orange;
}

/* Direct child selector - direct children of nav */
nav > ul {
    list-style: none;
}

/* Pseudo-class - hover state */
button:hover {
    background-color: darkblue;
}

/* Pseudo-class - first child */
p:first-child {
    margin-top: 0;
}
```

### Common CSS Properties

#### Text and Fonts

```css
p {
    color: #333;              /* Text color */
    font-family: Arial, sans-serif;  /* Font family */
    font-size: 16px;         /* Font size */
    font-weight: bold;       /* Bold, normal, 100-900 */
    font-style: italic;      /* Normal, italic */
    text-align: center;      /* Left, right, center, justify */
    text-decoration: underline;  /* Underline, line-through, none */
    line-height: 1.6;        /* Space between lines */
    letter-spacing: 1px;     /* Space between letters */
}
```

#### Colors

```css
/* Color names */
p { color: red; }

/* Hex codes */
p { color: #FF0000; }       /* Red */
p { color: #00FF00; }       /* Green */
p { color: #0000FF; }       /* Blue */

/* RGB values */
p { color: rgb(255, 0, 0); } /* Red */
p { color: rgba(255, 0, 0, 0.5); } /* Semi-transparent red */

/* HSL values */
p { color: hsl(0, 100%, 50%); } /* Red */
```

#### Backgrounds

```css
div {
    background-color: #f0f0f0;  /* Solid color */
    background-image: url('bg.jpg');  /* Image */
    background-size: cover;     /* Cover, contain, auto */
    background-position: center;  /* Position */
    background-repeat: no-repeat;  /* Repeat behavior */
    background: #f0f0f0 url('bg.jpg') no-repeat center/cover;
}
```

#### Box Model

Every HTML element is a box with:

- **Content**: The actual content
- **Padding**: Space inside the border
- **Border**: The border around the padding
- **Margin**: Space outside the border

```css
div {
    /* Content */
    width: 300px;
    height: 200px;
    
    /* Padding */
    padding: 20px;           /* All sides */
    padding-top: 10px;
    padding-right: 20px;
    padding-bottom: 10px;
    padding-left: 20px;
    padding: 10px 20px;      /* Top/bottom, left/right */
    padding: 10px 20px 10px 20px;  /* Top, right, bottom, left */
    
    /* Border */
    border: 1px solid #ccc;
    border-radius: 5px;      /* Rounded corners */
    
    /* Margin */
    margin: 20px;            /* All sides */
    margin: 10px 20px;       /* Top/bottom, left/right */
    margin: 10px 20px 10px 20px; /* Top, right, bottom, left */
}
```

#### Layout (Flexbox)

Flexbox is a powerful layout system:

```css
.container {
    display: flex;
    flex-direction: row;        /* Row, column, row-reverse, column-reverse */
    justify-content: center;    /* Center, flex-start, flex-end, space-between, space-around */
    align-items: center;       /* Center, flex-start, flex-end, stretch */
    flex-wrap: wrap;          /* Wrap, nowrap */
    gap: 20px;                /* Space between items */
}

.item {
    flex: 1;                  /* Grow to fill space */
    /* Or specific values */
    flex: 0 0 200px;          /* Don't grow, don't shrink, 200px base */
}
```

#### Layout (Grid)

CSS Grid is great for 2D layouts:

```css
.grid {
    display: grid;
    grid-template-columns: 1fr 1fr 1fr;  /* 3 equal columns */
    grid-template-columns: repeat(3, 1fr);  /* Same as above */
    grid-template-columns: 200px 1fr;  /* 200px, rest */
    gap: 20px;               /* Space between items */
}

.item {
    grid-column: 1 / 3;       /* Span 2 columns */
    grid-row: 1 / 2;          /* First row */
}
```

#### Responsive Design

```css
/* Make elements responsive */
.container {
    max-width: 1200px;
    width: 100%;
    margin: 0 auto;
}

img {
    max-width: 100%;
    height: auto;
}

/* Media queries for different screen sizes */
@media (max-width: 768px) {
    .container {
        padding: 0 15px;
    }
    .grid {
        grid-template-columns: 1fr;
    }
}

@media (min-width: 769px) and (max-width: 1024px) {
    .grid {
        grid-template-columns: 1fr 1fr;
    }
}
```

---

## P.3: Django Template Fundamentals

### What are Django Templates?

Django templates are HTML files with special tags that let you insert dynamic data. They're the "V" in Django's MTV (Model-Template-View) architecture.

Think of templates like a form letter — you have a fixed structure, and you fill in the blanks with specific information.

### Basic Template Structure

```html
<!DOCTYPE html>
<html>
<head>
    <title>{{ page_title }}</title>
</head>
<body>
    <h1>Welcome, {{ user.username }}!</h1>
    <p>Today is {{ current_date|date:"F j, Y" }}</p>
    
    {% if user.is_authenticated %}
        <p>You are logged in</p>
    {% else %}
        <p>Please log in</p>
    {% endif %}
    
    <ul>
    {% for post in posts %}
        <li>{{ post.title }}</li>
    {% empty %}
        <li>No posts available</li>
    {% endfor %}
    </ul>
</body>
</html>
```

### Template Variables

Variables are wrapped in `{{ }}`:

```python
# In views.py
context = {
    'name': 'Alice',
    'age': 25,
    'user': {
        'username': 'alice123',
        'email': 'alice@example.com'
    },
    'items': ['apple', 'banana', 'orange']
}
```

```html
<!-- In template -->
<p>Hello, {{ name }}!</p>                    <!-- Hello, Alice! -->
<p>You are {{ age }} years old</p>          <!-- You are 25 years old -->
<p>Username: {{ user.username }}</p>        <!-- Username: alice123 -->
<p>Email: {{ user.email }}</p>              <!-- Email: alice@example.com -->
<p>First item: {{ items.0 }}</p>            <!-- First item: apple -->
<p>Last item: {{ items|last }}</p>          <!-- Last item: orange -->
```

### Template Tags

Tags are wrapped in `{% %}`:

#### `{% if %}` - Conditional Logic

```html
<!-- Basic if -->
{% if user.is_authenticated %}
    <p>Welcome back, {{ user.username }}!</p>
{% endif %}

<!-- If-else -->
{% if post.status == 'published' %}
    <span class="published">Published</span>
{% else %}
    <span class="draft">Draft</span>
{% endif %}

<!-- If-elif-else -->
{% if user.is_superuser %}
    <p>You're a superuser</p>
{% elif user.is_staff %}
    <p>You're staff</p>
{% else %}
    <p>You're a regular user</p>
{% endif %}

<!-- Complex conditions -->
{% if user.is_authenticated and user.has_perm('blog.add_post') %}
    <a href="{% url 'post_create' %}">Create Post</a>
{% endif %}

{% if not post.is_published %}
    <p>This post is not published</p>
{% endif %}
```

#### `{% for %}` - Loops

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
{% endfor %}

<!-- Loop over dictionary -->
<dl>
    {% for key, value in post.metadata.items %}
        <dt>{{ key }}</dt>
        <dd>{{ value }}</dd>
    {% endfor %}
</dl>

<!-- Reversed loop -->
{% for post in posts reversed %}
    <li>{{ post.title }}</li>
{% endfor %}
```

#### `{% url %}` - Generating URLs

```html
<!-- Basic URL -->
<a href="{% url 'home' %}">Home</a>

<!-- URL with parameters -->
<a href="{% url 'post_detail' slug=post.slug %}">{{ post.title }}</a>

<!-- URL with positional parameters -->
<a href="{% url 'post_detail' post.slug %}">{{ post.title }}</a>

<!-- URL as variable -->
{% url 'post_detail' slug=post.slug as post_url %}
<a href="{{ post_url }}">{{ post.title }}</a>
```

### Template Filters

Filters modify variables:

```html
<!-- Text filters -->
{{ text|lower }}           <!-- Converts to lowercase -->
{{ text|upper }}           <!-- Converts to uppercase -->
{{ text|title }}           <!-- Converts to title case -->
{{ text|capfirst }}        <!-- Capitalizes first letter -->

<!-- Truncation -->
{{ text|truncatechars:50 }}    <!-- First 50 chars + "..." -->
{{ text|truncatewords:30 }}    <!-- First 30 words + "..." -->

<!-- Default values -->
{{ value|default:"Nothing" }}   <!-- If value is empty, show "Nothing" -->

<!-- Date formatting -->
{{ post.created_at|date:"F j, Y" }}     <!-- March 15, 2026 -->
{{ post.created_at|date:"Y-m-d" }}      <!-- 2026-03-15 -->
{{ post.created_at|date:"g:i a" }}      <!-- 2:30 pm -->

<!-- Time since -->
{{ post.created_at|timesince }}         <!-- 2 days, 3 hours ago -->

<!-- List operations -->
{{ items|length }}           <!-- Number of items -->
{{ items|join:", " }}        <!-- Join with comma -->
{{ items|first }}            <!-- First item -->
{{ items|last }}             <!-- Last item -->
{{ items|random }}           <!-- Random item -->
{{ items|slice:":5" }}       <!-- First 5 items -->

<!-- Number formatting -->
{{ number|floatformat:2 }}   <!-- 19.99 -->
{{ filesize|filesizeformat }}  <!-- 2.5 MB -->

<!-- Safe HTML -->
{{ html_content|safe }}      <!-- Don't escape HTML -->

<!-- Line breaks -->
{{ text|linebreaks }}        <!-- Converts newlines to <br> -->
```

### Template Inheritance

Base template (the "skeleton"):

```html
<!-- base.html -->
<!DOCTYPE html>
<html>
<head>
    <title>{% block title %}Default Title{% endblock %}</title>
    <link rel="stylesheet" href="{% static 'css/style.css' %}">
    {% block extra_head %}{% endblock %}
</head>
<body>
    <header>
        {% include 'includes/header.html' %}
    </header>
    
    <main>
        {% block content %}
            <p>Default content</p>
        {% endblock %}
    </main>
    
    <footer>
        {% include 'includes/footer.html' %}
    </footer>
    
    {% block scripts %}{% endblock %}
</body>
</html>
```

Child template (extends the base):

```html
<!-- child.html -->
{% extends 'base.html' %}

{% block title %}
    {{ page_title }} - My Site
{% endblock %}

{% block content %}
    <h1>{{ page_title }}</h1>
    <p>{{ description }}</p>
{% endblock %}

{% block extra_head %}
    <link rel="stylesheet" href="{% static 'custom.css' %}">
{% endblock %}
```

### Static Files

```html
<!-- Load static tag -->
{% load static %}

<!-- CSS -->
<link rel="stylesheet" href="{% static 'blog/css/style.css' %}">

<!-- JavaScript -->
<script src="{% static 'blog/js/main.js' %}"></script>

<!-- Images -->
<img src="{% static 'blog/images/logo.png' %}" alt="Logo">

<!-- Static with variable -->
<link rel="stylesheet" href="{% static 'blog/css/'|add:css_file %}">
```

### CSRF Token

```html
<!-- Always include in POST forms -->
<form method="post">
    {% csrf_token %}
    <!-- form fields -->
    <button type="submit">Submit</button>
</form>
```

---

## P.4: Django Template in Action

### Complete Example

**views.py**

```python
from django.shortcuts import render

def blog_list(request):
    posts = [
        {'id': 1, 'title': 'First Post', 'content': 'This is my first post'},
        {'id': 2, 'title': 'Second Post', 'content': 'This is my second post'},
    ]
    context = {
        'page_title': 'My Blog',
        'posts': posts,
        'user': request.user,
    }
    return render(request, 'blog/blog_list.html', context)
```

**base.html**

```html
<!DOCTYPE html>
<html>
<head>
    <title>{% block title %}Django Blog{% endblock %}</title>
    <link rel="stylesheet" href="{% static 'css/style.css' %}">
</head>
<body>
    <nav>
        <ul>
            <li><a href="{% url 'home' %}">Home</a></li>
            <li><a href="{% url 'blog_list' %}">Blog</a></li>
            {% if user.is_authenticated %}
                <li><a href="{% url 'profile' %}">Profile</a></li>
                <li>
                    <form method="post" action="{% url 'logout' %}">
                        {% csrf_token %}
                        <button type="submit">Logout</button>
                    </form>
                </li>
            {% else %}
                <li><a href="{% url 'login' %}">Login</a></li>
            {% endif %}
        </ul>
    </nav>
    
    <main>
        {% block content %}
        {% endblock %}
    </main>
</body>
</html>
```

**blog_list.html**

```html
{% extends 'base.html' %}

{% block title %}
    {{ page_title }}
{% endblock %}

{% block content %}
    <h1>{{ page_title }}</h1>
    
    {% if posts %}
        <ul>
            {% for post in posts %}
                <li>
                    <h2>{{ post.title }}</h2>
                    <p>{{ post.content|truncatewords:20 }}</p>
                    <a href="{% url 'post_detail' id=post.id %}">Read more</a>
                </li>
            {% endfor %}
        </ul>
    {% else %}
        <p>No posts available</p>
    {% endif %}
{% endblock %}
```

---

## P.5: Common Django Template Patterns

### Form Rendering

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

### Messages Display

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

### Pagination

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

### With Block (for complex expressions)

```html
{% with total_posts=posts|length %}
    <p>Found {{ total_posts }} post{{ total_posts|pluralize }}</p>
{% endwith %}

{% with full_name=user.first_name|add:" "|add:user.last_name %}
    <p>Welcome, {{ full_name }}</p>
{% endwith %}
```

---

## P.6: CSS Framework Integration

### Bootstrap Example

```html
<!DOCTYPE html>
<html>
<head>
    <title>{% block title %}Django Blog{% endblock %}</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="{% static 'css/style.css' %}">
</head>
<body>
    <nav class="navbar navbar-expand-lg navbar-dark bg-dark">
        <div class="container">
            <a class="navbar-brand" href="{% url 'home' %}">Django Blog</a>
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="navbarNav">
                <ul class="navbar-nav ms-auto">
                    <li class="nav-item">
                        <a class="nav-link" href="{% url 'blog_list' %}">Blog</a>
                    </li>
                    {% if user.is_authenticated %}
                        <li class="nav-item">
                            <a class="nav-link" href="{% url 'post_create' %}">New Post</a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="{% url 'profile' %}">{{ user.username }}</a>
                        </li>
                    {% else %}
                        <li class="nav-item">
                            <a class="nav-link" href="{% url 'login' %}">Login</a>
                        </li>
                    {% endif %}
                </ul>
            </div>
        </div>
    </nav>
    
    <main class="container mt-4">
        {% if messages %}
            {% for message in messages %}
                <div class="alert alert-{{ message.tags }} alert-dismissible fade show">
                    {{ message }}
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            {% endfor %}
        {% endif %}
        
        {% block content %}
        {% endblock %}
    </main>
    
    <footer class="bg-light text-center py-3 mt-5">
        <div class="container">
            <p>&copy; 2026 Django Blog. All rights reserved.</p>
        </div>
    </footer>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="{% static 'js/main.js' %}"></script>
</body>
</html>
```

---

## P.7: Common Pitfalls

### Pitfall 1: Forgetting `{% load static %}`

```html
<!-- Wrong -->
<link rel="stylesheet" href="{% static 'css/style.css' %}">

<!-- Correct -->
{% load static %}
<link rel="stylesheet" href="{% static 'css/style.css' %}">
```

### Pitfall 2: Forgetting `{% csrf_token %}`

```html
<!-- Wrong -->
<form method="post">
    <input type="text" name="title">
    <button type="submit">Submit</button>
</form>

<!-- Correct -->
<form method="post">
    {% csrf_token %}
    <input type="text" name="title">
    <button type="submit">Submit</button>
</form>
```

### Pitfall 3: Variable Name Mismatch

```python
# In views.py
context = {
    'articles': posts  # Variable name is 'articles'
}
```

```html
<!-- In template - Wrong -->
{% for post in posts %}  # 'posts' doesn't exist
    {{ post.title }}
{% endfor %}

<!-- Correct -->
{% for article in articles %}
    {{ article.title }}
{% endfor %}
```

### Pitfall 4: Missing `empty` in For Loops

```html
<!-- Wrong - no empty block -->
<ul>
    {% for post in posts %}
        <li>{{ post.title }}</li>
    {% endfor %}
</ul>

<!-- Correct - with empty block -->
<ul>
    {% for post in posts %}
        <li>{{ post.title }}</li>
    {% empty %}
        <li>No posts available</li>
    {% endfor %}
</ul>
```

---

## P.8: Quick Reference

### HTML Quick Reference

```html
<!-- Structure -->
<div>Block container</div>
<span>Inline container</span>

<!-- Text -->
<h1>Heading</h1>
<p>Paragraph</p>
<strong>Bold</strong>
<em>Italic</em>
<br>Line break
<hr>Horizontal rule

<!-- Links -->
<a href="url">Link</a>

<!-- Images -->
<img src="url" alt="description">

<!-- Lists -->
<ul><li>Item</li></ul>
<ol><li>Item</li></ol>

<!-- Tables -->
<table><tr><td>Cell</td></tr></table>

<!-- Forms -->
<form><input type="text"></form>
```

### CSS Quick Reference

```css
/* Selectors */
p { }           /* Element */
.class { }      /* Class */
#id { }         /* ID */
p a { }         /* Descendant */
p > a { }       /* Direct child */

/* Properties */
color: red;
font-size: 16px;
font-family: Arial;
background-color: #f0f0f0;
margin: 10px;
padding: 10px;
border: 1px solid #ccc;
border-radius: 5px;
width: 100%;
height: auto;
display: flex;
justify-content: center;
align-items: center;

/* Units */
px      /* Pixels (fixed) */
%       /* Percentage (relative) */
em      /* Relative to parent font size */
rem     /* Relative to root font size */
vw/vh   /* Viewport relative */
```

### Django Template Quick Reference

```html
<!-- Variables -->
{{ variable }}
{{ object.attribute }}
{{ dict.key }}
{{ list.0 }}

<!-- Filters -->
{{ text|lower }}
{{ text|upper }}
{{ text|truncatewords:30 }}
{{ text|default:"Nothing" }}
{{ date|date:"F j, Y" }}
{{ html|safe }}

<!-- Tags -->
{% if condition %}...{% endif %}
{% for item in list %}...{% endfor %}
{% block name %}...{% endblock %}
{% extends 'base.html' %}
{% include 'partial.html' %}
{% url 'view_name' %}
{% load static %}
{% csrf_token %}

<!-- Comments -->
{# This is a comment #}
{% comment %}Multi-line comment{% endcomment %}
```

---

This primer gives you everything you need to start working with Django templates. Practice building simple HTML pages, styling them with CSS, and then moving on to Django templates with dynamic data!
