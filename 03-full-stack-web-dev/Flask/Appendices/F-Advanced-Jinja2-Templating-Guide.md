# Appendix F: Advanced Jinja2 Templating Guide

Welcome to Appendix F! This comprehensive reference provides an expert-level exploration of Jinja2, Flask's powerful templating engine. While the main tutorial covered practical template usage, this appendix dives deep into Jinja2's advanced features, optimization techniques, and best practices for building complex, maintainable templates.

---

## Table of Contents

1. [Jinja2 Architecture Overview](#1-jinja2-architecture-overview)
2. [Template Inheritance & Composition](#2-template-inheritance--composition)
3. [Advanced Filter & Test Creation](#3-advanced-filter--test-creation)
4. [Macros & Reusable Components](#4-macros--reusable-components)
5. [Custom Extensions & Globals](#5-custom-extensions--globals)
6. [Performance Optimization](#6-performance-optimization)
7. [Internationalization (i18n)](#7-internationalization-i18n)
8. [Security Considerations](#8-security-considerations)
9. [Advanced Use Cases](#9-advanced-use-cases)

---

## 1. Jinja2 Architecture Overview

### Template Compilation Process

Jinja2 compiles templates into Python bytecode for execution. Understanding this process helps you optimize template performance.

```python
from jinja2 import Environment, FileSystemLoader, Template

# How Jinja2 processes a template
def template_compilation_flow():
    # 1. Load template source
    env = Environment(loader=FileSystemLoader('templates'))
    template_source = env.loader.get_source(env, 'example.html')[0]
    
    # 2. Parse template into AST (Abstract Syntax Tree)
    parser = env.parse(template_source)
    print(f"AST: {parser}")
    
    # 3. Compile AST to Python bytecode
    compiled = env.compile(parser)
    print(f"Compiled code: {compiled}")
    
    # 4. Create template object
    template = Template(template_source, env=env)
    
    # 5. Render with context
    rendered = template.render(name="John")
    return rendered

# Inspecting compiled template
def inspect_compiled_template():
    env = Environment(loader=FileSystemLoader('templates'))
    template = env.get_template('example.html')
    
    # Get compiled code
    compiled_code = template.code
    print("Compiled template code:")
    print(compiled_code)
    
    # Get template context
    print(f"Template variables: {template.globals}")
    print(f"Template blocks: {template.blocks}")
```

### Template Context & Variable Resolution

```python
from jinja2 import Environment, StrictUndefined

# Understanding context resolution
context_example = """
Context Resolution Order:
1. Local variables (defined in template)
2. Template globals
3. Context passed to render()
4. Flask's context processors
5. Built-in globals
"""

class ContextDebugEnvironment(Environment):
    """Environment that shows variable resolution."""
    
    def get_template(self, name, parent=None, globals=None):
        template = super().get_template(name, parent, globals)
        
        # Add debug context
        template.globals['_debug'] = {
            'context': self._get_current_context(),
            'variables': self._collect_variables(template)
        }
        
        return template
    
    def _get_current_context(self):
        """Get current template context."""
        # This is simplified - actual context is more complex
        return {
            'globals': self.globals,
            'filters': self.filters,
            'tests': self.tests,
        }

# Using strict undefined to catch typos
env = Environment(
    loader=FileSystemLoader('templates'),
    undefined=StrictUndefined,  # Raises error for undefined variables
)

# Context processor in Flask
@app.context_processor
def inject_globals():
    """Inject global variables into all templates."""
    return {
        'app_name': 'TaskFlow',
        'year': datetime.utcnow().year,
        'version': '1.0.0',
        'current_user': g.current_user if hasattr(g, 'current_user') else None,
    }
```

---

## 2. Template Inheritance & Composition

### Advanced Block Patterns

```python
# base.html - Advanced inheritance structure
"""
{% block doctype %}
    <!DOCTYPE html>
{% endblock %}

{% block html_tag %}
    <html lang="{{ config.get('LANGUAGE', 'en') }}">
{% endblock %}

{% block head %}
    <head>
        {% block meta %}
            <meta charset="utf-8">
            <meta name="viewport" content="width=device-width, initial-scale=1">
            <meta name="description" content="{% block meta_description %}{{ app_name }}{% endblock %}">
            <meta name="keywords" content="{% block meta_keywords %}taskflow, tasks, management{% endblock %}">
        {% endblock %}
        
        {% block styles %}
            <link rel="stylesheet" href="{{ url_for('static', filename='css/main.css') }}">
        {% endblock %}
        
        {% block scripts_head %}{% endblock %}
    </head>
{% endblock %}

{% block body %}
    <body>
        {% block header %}
            <header>
                {% block navigation %}
                    {% include '_navigation.html' %}
                {% endblock %}
            </header>
        {% endblock %}

        {% block main %}
            <main>
                {% block messages %}
                    {% include '_flash_messages.html' %}
                {% endblock %}
                
                {% block content %}{% endblock %}
            </main>
        {% endblock %}

        {% block footer %}
            <footer>
                {% include '_footer.html' %}
            </footer>
        {% endblock %}

        {% block scripts %}
            <script src="{{ url_for('static', filename='js/main.js') }}"></script>
        {% endblock %}
    </body>
{% endblock %}
"""

# Advanced child template with block chaining
"""
{% extends "base.html" %}

{# Override with additional blocks #}
{% block title %}Task Details - {{ app_name }}{% endblock %}

{% block meta_description %}
    Task details for {{ task.title }}
{% endblock %}

{# Block with parent content #}
{% block content %}
    <div class="task-details">
        <h1>{{ task.title }}</h1>
        
        {# Include child block within content #}
        {% block task_details %}
            {% include "tasks/_task_details.html" %}
        {% endblock %}
        
        {% block task_comments %}
            <section class="comments">
                <h2>Comments</h2>
                {% for comment in task.comments %}
                    {% include "tasks/_comment.html" %}
                {% endfor %}
            </section>
        {% endblock %}
    </div>
{% endblock %}

{# Override block with super() #}
{% block styles %}
    {{ super() }}
    <link rel="stylesheet" href="{{ url_for('static', filename='css/task.css') }}">
{% endblock %}
"""

# Advanced block usage - conditional overriding
class ConditionalTemplate:
    """Template with conditional block overrides."""
    
    @staticmethod
    def render_with_layout(template, layout='default'):
        """Render template with dynamic layout."""
        layout_map = {
            'default': 'layouts/default.html',
            'compact': 'layouts/compact.html',
            'admin': 'layouts/admin.html',
            'api': 'layouts/api.html',
        }
        
        # Use variable to control inheritance
        extended_template = f"{{% extends '{layout_map[layout]}' %}}\n"
        extended_template += template
        
        return extended_template
```

### Include & Import Patterns

```python
# include_examples.html
"""
{# Include with context #}
{% include "_sidebar.html" %}

{# Include with limited context #}
{% include "_widget.html" without context %}

{# Include with custom context #}
{% include "_user_card.html" with user=task.assigned_to %}

{# Conditional include #}
{% if user.is_admin %}
    {% include "admin/_controls.html" %}
{% endif %}

{# Ignore missing files #}
{% include "optional/_component.html" ignore missing %}

# Import examples
{# Import as macro #}
{% from "_macros.html" import render_task, render_user %}

{# Import all with prefix #}
{% import "_macros.html" as macros %}

{# Import with custom alias #}
{% import "_macros.html" as m with context %}

# Usage
{{ render_task(task) }}
{{ macros.render_user(user) }}
{{ m.render_task(task, expanded=true) }}
"""

# Dynamic include based on variable
def render_component(component_type, data):
    """Dynamically render a component."""
    component_map = {
        'task': '_task_detail.html',
        'user': '_user_profile.html',
        'comment': '_comment.html',
    }
    
    template = f"{{% include 'components/{component_map[component_type]}' %}}"
    return render_template_string(template, data=data)
```

---

## 3. Advanced Filter & Test Creation

### Custom Filters Deep Dive

```python
from jinja2 import Environment, Markup, escape
import datetime
import re
from markdown import markdown
from bleach import clean
import humanize

# Flask filter registration
@app.template_filter('natural_time')
def natural_time_filter(value):
    """Display time in natural language."""
    if not value:
        return ''
    
    if isinstance(value, str):
        value = datetime.fromisoformat(value)
    
    now = datetime.utcnow()
    diff = now - value
    
    if diff.days > 365:
        return f"{diff.days // 365} years ago"
    elif diff.days > 30:
        return f"{diff.days // 30} months ago"
    elif diff.days > 7:
        return f"{diff.days // 7} weeks ago"
    elif diff.days > 0:
        return f"{diff.days} days ago"
    elif diff.seconds > 3600:
        return f"{diff.seconds // 3600} hours ago"
    elif diff.seconds > 60:
        return f"{diff.seconds // 60} minutes ago"
    else:
        return "just now"

@app.template_filter('markdown')
def markdown_filter(value, safe=True):
    """Convert markdown to HTML with sanitation."""
    if not value:
        return ''
    
    # Convert markdown to HTML
    html = markdown(value, extensions=[
        'extra',
        'codehilite',
        'toc',
        'tables',
        'fenced_code'
    ])
    
    # Sanitize HTML
    allowed_tags = [
        'p', 'br', 'b', 'strong', 'i', 'em', 'u',
        'h1', 'h2', 'h3', 'h4', 'h5', 'h6',
        'ul', 'ol', 'li',
        'a', 'img', 'blockquote', 'code', 'pre',
        'table', 'thead', 'tbody', 'tr', 'th', 'td'
    ]
    allowed_attrs = {
        'a': ['href', 'target', 'rel'],
        'img': ['src', 'alt', 'title'],
        '*': ['class', 'id']
    }
    
    safe_html = clean(html, tags=allowed_tags, attributes=allowed_attrs)
    
    if safe:
        return Markup(safe_html)
    return safe_html

@app.template_filter('highlight')
def highlight_filter(text, query):
    """Highlight search terms in text."""
    if not query or not text:
        return text
    
    pattern = re.compile(re.escape(query), re.IGNORECASE)
    return Markup(pattern.sub(
        lambda m: f'<mark>{m.group(0)}</mark>',
        escape(text)
    ))

@app.template_filter('truncate_words')
def truncate_words_filter(value, length=30, suffix='...'):
    """Truncate text by word count."""
    if not value:
        return ''
    
    words = value.split()
    if len(words) <= length:
        return value
    
    truncated = ' '.join(words[:length])
    return truncated + suffix

@app.template_filter('filesize')
def filesize_filter(size):
    """Format file size in human-readable format."""
    return humanize.naturalsize(size)

@app.template_filter('ordinal')
def ordinal_filter(n):
    """Convert number to ordinal string."""
    if 10 <= n % 100 <= 20:
        suffix = 'th'
    else:
        suffix = {1: 'st', 2: 'nd', 3: 'rd'}.get(n % 10, 'th')
    return f"{n}{suffix}"

@app.template_filter('to_json')
def to_json_filter(value, pretty=False):
    """Convert value to JSON string."""
    if pretty:
        return json.dumps(value, indent=2, sort_keys=True)
    return json.dumps(value)

# Custom tests
@app.template_test('admin')
def is_admin(user):
    """Test if user is admin."""
    return user and user.is_admin

@app.template_test('active')
def is_active(user):
    """Test if user is active."""
    return user and user.is_active

@app.template_test('overdue')
def is_overdue(task):
    """Test if task is overdue."""
    return task and task.due_date and task.due_date < datetime.utcnow()

@app.template_test('in')
def is_in(item, collection):
    """Test if item is in collection."""
    return item in collection

# Register filters and tests in Flask
@app.template_filter('to_json')
def to_json_filter(value, pretty=False):
    return json.dumps(value, indent=2 if pretty else None)

app.jinja_env.filters['natural_time'] = natural_time_filter
app.jinja_env.filters['markdown'] = markdown_filter
app.jinja_env.tests['admin'] = is_admin
```

### Filter Chaining & Composition

```python
# Advanced filter chaining
class FilterChain:
    """Chain multiple filters with context."""
    
    def __init__(self, value):
        self.value = value
        self.context = {}
    
    def filter(self, name, *args, **kwargs):
        """Apply a filter to the current value."""
        filter_func = app.jinja_env.filters.get(name)
        if not filter_func:
            raise ValueError(f"Filter '{name}' not found")
        
        # Pass context if available
        if 'context' in kwargs:
            kwargs.pop('context')
            self.value = filter_func(self.value, **kwargs, context=self.context)
        else:
            self.value = filter_func(self.value, *args, **kwargs)
        
        return self
    
    def render(self):
        """Get the final value."""
        return self.value

# Usage in view
def process_text(text):
    """Process text with multiple filters."""
    result = (FilterChain(text)
        .filter('striptags')
        .filter('truncate', 100)
        .filter('markdown')
        .filter('highlight', 'python')
        .render()
    )
    return result

# Custom filter composition
@app.template_filter('process_text')
def process_text_filter(text, **kwargs):
    """Compose multiple filters into one."""
    chain = FilterChain(text)
    
    if kwargs.get('strip_tags', False):
        chain.filter('striptags')
    
    if kwargs.get('truncate'):
        chain.filter('truncate', kwargs['truncate'])
    
    if kwargs.get('highlight'):
        chain.filter('highlight', kwargs['highlight'])
    
    if kwargs.get('markdown'):
        chain.filter('markdown')
    
    return chain.render()
```

---

## 4. Macros & Reusable Components

### Advanced Macro Patterns

```python
# _macros.html - Comprehensive macros
"""
{# Form macro with full control #}
{% macro render_form(form, action='', method='POST', enctype=None) %}
    <form action="{{ action }}" method="{{ method }}" {% if enctype %}enctype="{{ enctype }}"{% endif %}>
        {{ form.csrf_token }}
        
        {% for field in form %}
            {% if field.type not in ['CSRFTokenField', 'SubmitField', 'HiddenField'] %}
                <div class="form-group {% if field.errors %}has-error{% endif %}">
                    {{ field.label(class="form-label") }}
                    
                    {# Render different field types #}
                    {% if field.type == 'TextAreaField' %}
                        {{ field(class="form-control", rows=5, **kwargs) }}
                    {% elif field.type == 'SelectField' %}
                        {{ field(class="form-select", **kwargs) }}
                    {% elif field.type == 'BooleanField' %}
                        <div class="form-check">
                            {{ field(class="form-check-input", **kwargs) }}
                            {{ field.label(class="form-check-label") }}
                        </div>
                    {% elif field.type == 'FileField' %}
                        {{ field(class="form-control", **kwargs) }}
                    {% else %}
                        {{ field(class="form-control", **kwargs) }}
                    {% endif %}
                    
                    {% if field.description %}
                        <small class="form-text text-muted">{{ field.description }}</small>
                    {% endif %}
                    
                    {% for error in field.errors %}
                        <div class="invalid-feedback">{{ error }}</div>
                    {% endfor %}
                </div>
            {% endif %}
        {% endfor %}
        
        {% if form.submit %}
            {{ form.submit(class="btn btn-primary") }}
        {% endif %}
    </form>
{% endmacro %}

{# Card component with slots #}
{% macro card(title, header=None, footer=None) %}
    <div class="card">
        {% if title or header %}
            <div class="card-header">
                {% if header %}
                    {{ header }}
                {% else %}
                    <h5 class="card-title">{{ title }}</h5>
                {% endif %}
            </div>
        {% endif %}
        
        <div class="card-body">
            {{ caller() }}
        </div>
        
        {% if footer %}
            <div class="card-footer">
                {{ footer }}
            </div>
        {% endif %}
    </div>
{% endmacro %}

{# Modal component #}
{% macro modal(id, title, size='lg') %}
    <div class="modal fade" id="{{ id }}" tabindex="-1">
        <div class="modal-dialog modal-{{ size }}">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">{{ title }}</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    {{ caller() }}
                </div>
            </div>
        </div>
    </div>
{% endmacro %}

{# Pagination macro #}
{% macro pagination(pagination, endpoint) %}
    <nav aria-label="Page navigation">
        <ul class="pagination">
            {% if pagination.has_prev %}
                <li class="page-item">
                    <a class="page-link" href="{{ url_for(endpoint, page=pagination.prev_num, **kwargs) }}">
                        Previous
                    </a>
                </li>
            {% endif %}
            
            {% for page in pagination.iter_pages(left_edge=2, left_current=2, right_current=3, right_edge=2) %}
                {% if page %}
                    <li class="page-item {% if page == pagination.page %}active{% endif %}">
                        <a class="page-link" href="{{ url_for(endpoint, page=page, **kwargs) }}">
                            {{ page }}
                        </a>
                    </li>
                {% else %}
                    <li class="page-item disabled">
                        <span class="page-link">…</span>
                    </li>
                {% endif %}
            {% endfor %}
            
            {% if pagination.has_next %}
                <li class="page-item">
                    <a class="page-link" href="{{ url_for(endpoint, page=pagination.next_num, **kwargs) }}">
                        Next
                    </a>
                </li>
            {% endif %}
        </ul>
    </nav>
{% endmacro %}

{# Table macro with sorting #}
{% macro sortable_table(items, columns, sort_by=None, sort_dir='asc') %}
    <table class="table table-hover table-sortable">
        <thead>
            <tr>
                {% for key, label in columns.items() %}
                    <th>
                        {% if sort_by and sort_by == key %}
                            <a href="{{ update_query_string(sort_by=key, sort_dir='desc' if sort_dir == 'asc' else 'asc') }}">
                                {{ label }}
                                <i class="fas fa-sort-{% if sort_dir == 'asc' %}up{% else %}down{% endif %}"></i>
                            </a>
                        {% else %}
                            <a href="{{ update_query_string(sort_by=key, sort_dir='asc') }}">
                                {{ label }}
                            </a>
                        {% endif %}
                    </th>
                {% endfor %}
            </tr>
        </thead>
        <tbody>
            {% for item in items %}
                <tr>
                    {% for key in columns.keys() %}
                        <td>{{ item[key] if key in item else '' }}</td>
                    {% endfor %}
                </tr>
            {% endfor %}
        </tbody>
    </table>
{% endmacro %}

{# Usage examples #}
{#
    {% call card(title="Task Details") %}
        <p>Task content here</p>
    {% endcall %}
    
    {% call modal(id="taskModal", title="Task Details") %}
        <p>Modal content</p>
    {% endcall %}
    
    {{ pagination(tasks_pagination, 'tasks.index', status='pending') }}
#}
"""
```

### Macro Import Patterns

```python
# Different ways to import macros

# 1. Import specific macros
"""
{% from "macros.html" import render_form, card, modal with context %}
"""

# 2. Import all macros
"""
{% import "macros.html" as macros %}
{{ macros.render_form(form) }}
"""

# 3. Import with alias
"""
{% from "macros.html" import render_form as form_renderer %}
{{ form_renderer(form) }}
"""

# 4. Dynamic macro loading
def load_macros(template_name):
    """Dynamically load macros from a template."""
    from jinja2 import Environment, FileSystemLoader
    
    env = Environment(loader=FileSystemLoader('templates'))
    template = env.get_template(template_name)
    
    # Get macro functions
    macros = {}
    for name, item in template.module.__dict__.items():
        if hasattr(item, '__call__'):
            macros[name] = item
    
    return macros

# 5. Macro overrides
class MacroOverride:
    """Allow overriding macros with custom implementations."""
    
    def __init__(self, template_name):
        self.template_name = template_name
        self._macros = {}
    
    def override(self, name, func):
        """Override a macro with a custom function."""
        self._macros[name] = func
        return self
    
    def render(self, **context):
        """Render with overridden macros."""
        env = Environment(loader=FileSystemLoader('templates'))
        template = env.get_template(self.template_name)
        
        # Patch template with overrides
        for name, func in self._macros.items():
            setattr(template.module, name, func)
        
        return template.render(**context)

# Usage
class CustomMacros:
    @staticmethod
    def custom_card(title, content):
        """Custom card implementation."""
        return f'<div class="custom-card"><h3>{title}</h3><p>{content}</p></div>'

# Override and render
result = (MacroOverride('template.html')
    .override('card', CustomMacros.custom_card)
    .render(context={'title': 'Hello'})
)
```

---

## 5. Custom Extensions & Globals

### Creating Custom Extensions

```python
from jinja2 import nodes
from jinja2.ext import Extension
from jinja2 import Environment, meta

class MarkdownExtension(Extension):
    """Jinja2 extension for markdown rendering."""
    
    tags = {'markdown'}
    
    def __init__(self, environment):
        super().__init__(environment)
        environment.extend(markdown_options={
            'extensions': ['extra', 'codehilite'],
            'output_format': 'html5',
        })
    
    def parse(self, parser):
        """Parse the markdown tag."""
        lineno = next(parser.stream).lineno
        
        # Parse arguments
        args = []
        if parser.stream.current.test('string'):
            args.append(parser.parse_expression())
        
        # Parse body
        body = parser.parse_statements(
            ['name:endmarkdown'],
            drop_needle=True
        )
        
        # Create node
        return nodes.CallBlock(
            self.call_method('_render_markdown', args),
            [], [],
            body
        ).set_lineno(lineno)
    
    def _render_markdown(self, text, caller):
        """Render markdown content."""
        import markdown
        
        content = caller()
        if text:
            # Use text as content if provided
            content = text
            
        html = markdown.markdown(
            content,
            **self.environment.markdown_options
        )
        
        return nodes.Markup(html)

# Register extension
app.jinja_env.add_extension(MarkdownExtension)

# Usage in template
"""
{% markdown %}
# Title
This is **markdown** content.
{% endmarkdown %}

{% markdown "## Title" %}
"""
```

### Custom Global Functions

```python
# Register custom global functions
def create_url_with_params(endpoint, **params):
    """Create URL with query parameters."""
    return url_for(endpoint, **params)

def pluralize(count, singular, plural=None):
    """Return singular or plural form."""
    if count == 1:
        return singular
    return plural or f"{singular}s"

def get_current_time():
    """Get current UTC time."""
    return datetime.utcnow()

def dict_filter(dictionary, *keys):
    """Filter dictionary to only include specific keys."""
    return {k: dictionary[k] for k in keys if k in dictionary}

def range_filter(start, end=None, step=1):
    """Create range for use in templates."""
    if end is None:
        return range(start)
    return range(start, end, step)

# Register globals
app.jinja_env.globals.update({
    'url_for_params': create_url_with_params,
    'pluralize': pluralize,
    'now': get_current_time,
    'dict_filter': dict_filter,
    'range': range_filter,
    'enumerate': enumerate,  # Built-in
    'zip': zip,              # Built-in
    'len': len,              # Built-in
})

# Custom function with access to request context
@app.context_processor
def utility_processor():
    """Add utility functions to template context."""
    def current_path():
        """Get current path with optional parameters."""
        return request.path
    
    def query_params():
        """Get current query parameters."""
        return dict(request.args)
    
    def update_query_string(**kwargs):
        """Update query string parameters."""
        params = dict(request.args)
        params.update(kwargs)
        # Remove None values
        params = {k: v for k, v in params.items() if v is not None}
        return url_for(request.endpoint, **params)
    
    return {
        'current_path': current_path,
        'query_params': query_params,
        'update_query_string': update_query_string,
    }
```

---

## 6. Performance Optimization

### Template Caching Strategies

```python
from jinja2 import Template
from flask_caching import Cache
import hashlib

# Configure cache
cache = Cache(app, config={
    'CACHE_TYPE': 'redis',
    'CACHE_REDIS_URL': 'redis://localhost:6379/2',
})

class TemplateCache:
    """Cache compiled templates and rendered output."""
    
    def __init__(self, cache):
        self.cache = cache
        self.compile_cache = {}
    
    def compile_template(self, template_name, source):
        """Cache compiled template."""
        cache_key = f"template:{template_name}"
        
        compiled = self.cache.get(cache_key)
        if compiled is None:
            # Compile template
            env = app.jinja_env
            compiled = env.compile(
                env.parse(source),
                name=template_name,
                filename=template_name
            )
            self.cache.set(cache_key, compiled, timeout=86400)  # 24 hours
        
        return compiled
    
    def render_cached(self, template_name, context, timeout=300):
        """Render template with output caching."""
        # Generate cache key from template and context
        context_hash = hashlib.md5(
            json.dumps(context, sort_keys=True).encode()
        ).hexdigest()[:10]
        
        cache_key = f"render:{template_name}:{context_hash}"
        
        # Try cache
        rendered = self.cache.get(cache_key)
        if rendered is not None:
            return rendered
        
        # Render template
        rendered = render_template(template_name, **context)
        
        # Cache result
        self.cache.set(cache_key, rendered, timeout=timeout)
        
        return rendered

# Usage in view
template_cache = TemplateCache(cache)

@app.route('/user/<int:user_id>')
@login_required
def user_profile(user_id):
    """Render user profile with caching."""
    user = User.query.get_or_404(user_id)
    
    context = {
        'user': user,
        'tasks': Task.query.filter_by(user_id=user_id).all(),
        'stats': get_user_stats(user_id),
    }
    
    # Cache rendered template for 5 minutes
    return template_cache.render_cached('user/profile.html', context, timeout=300)
```

### Template Profiling

```python
import time
from functools import wraps
from jinja2 import Environment, FileSystemLoader

class ProfileEnvironment(Environment):
    """Environment that profiles template rendering."""
    
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.profile_data = {}
    
    def get_template(self, name, parent=None, globals=None):
        template = super().get_template(name, parent, globals)
        
        # Wrap render method
        original_render = template.render
        
        @wraps(original_render)
        def profiled_render(*args, **kwargs):
            start = time.time()
            result = original_render(*args, **kwargs)
            duration = time.time() - start
            
            # Log profile data
            if name not in self.profile_data:
                self.profile_data[name] = {
                    'count': 0,
                    'total_time': 0,
                    'avg_time': 0,
                    'max_time': 0,
                }
            
            self.profile_data[name]['count'] += 1
            self.profile_data[name]['total_time'] += duration
            self.profile_data[name]['avg_time'] = (
                self.profile_data[name]['total_time'] / 
                self.profile_data[name]['count']
            )
            self.profile_data[name]['max_time'] = max(
                self.profile_data[name]['max_time'],
                duration
            )
            
            return result
        
        template.render = profiled_render
        return template

# Profile endpoint
@app.route('/admin/template-profile')
@admin_required
def template_profile():
    """View template performance profile."""
    env = app.jinja_env
    if not isinstance(env, ProfileEnvironment):
        return "Profiling not enabled", 400
    
    return jsonify(env.profile_data)
```

### Precompilation for Production

```python
# Precompile templates for production
def precompile_templates(app, output_dir='templates/compiled'):
    """Precompile all templates for production."""
    import os
    import pickle
    
    os.makedirs(output_dir, exist_ok=True)
    
    env = app.jinja_env
    templates = env.list_templates()
    
    for template_name in templates:
        # Skip non-template files
        if not template_name.endswith(('.html', '.xml', '.txt')):
            continue
        
        # Load template
        template = env.get_template(template_name)
        
        # Compile to bytecode
        bytecode = pickle.dumps(template)
        
        # Save compiled template
        output_path = os.path.join(
            output_dir,
            template_name.replace('/', '_') + '.pickle'
        )
        with open(output_path, 'wb') as f:
            f.write(bytecode)
    
    print(f"Precompiled {len(templates)} templates")

# Load precompiled templates
def load_precompiled_templates(app, input_dir='templates/compiled'):
    """Load precompiled templates."""
    import os
    import pickle
    
    env = app.jinja_env
    
    for filename in os.listdir(input_dir):
        if not filename.endswith('.pickle'):
            continue
        
        # Extract template name
        template_name = filename.replace('.pickle', '').replace('_', '/')
        
        # Load bytecode
        with open(os.path.join(input_dir, filename), 'rb') as f:
            bytecode = f.read()
        
        # Load template
        template = pickle.loads(bytecode)
        
        # Add to environment
        env.templates[template_name] = template
```

---

## 7. Internationalization (i18n)

### Complete i18n Setup

```python
from flask_babel import Babel, lazy_gettext, gettext, ngettext
from babel.dates import format_date, format_datetime, format_time

# Configure Babel
babel = Babel(app)

app.config.update({
    'BABEL_DEFAULT_LOCALE': 'en',
    'BABEL_TRANSLATION_DIRECTORIES': 'translations',
    'LANGUAGES': {
        'en': 'English',
        'es': 'Spanish',
        'fr': 'French',
        'de': 'German',
        'zh': 'Chinese',
        'ja': 'Japanese',
    }
})

@babel.localeselector
def get_locale():
    """Select locale based on request."""
    # Check URL parameter
    if 'lang' in request.args:
        lang = request.args['lang']
        if lang in app.config['LANGUAGES']:
            session['lang'] = lang
            return lang
    
    # Check session
    if 'lang' in session:
        return session['lang']
    
    # Check accept-language header
    return request.accept_languages.best_match(app.config['LANGUAGES'].keys())

# Templates with translations
"""
{% extends "base.html" %}

{# Using gettext #}
<h1>{{ _('Welcome to TaskFlow') }}</h1>

{# Lazy gettext for strings in macros #}
<p>{{ lazy_gettext('Hello, %(username)s!', username=user.username) }}</p>

{# Pluralization #}
<p>{{ ngettext('%(num)d task', '%(num)d tasks', tasks|length) }}</p>

{# Date formatting #}
<p>{{ format_date(timestamp, format='long') }}</p>

{# Time formatting #}
<p>{{ format_time(timestamp, format='medium') }}</p>

{# Custom translation filter #}
<p>{{ 'This is a translatable string'|trans }}</p>
"""

# Translation filters and tests
@app.template_filter('trans')
def translate_filter(text):
    """Translate a string in template."""
    return gettext(text)

@app.template_filter('lazy_trans')
def lazy_translate_filter(text):
    """Lazy translate a string."""
    return lazy_gettext(text)

@app.template_filter('format_date')
def format_date_filter(value, format='medium'):
    """Format date for current locale."""
    if isinstance(value, str):
        value = datetime.fromisoformat(value)
    return format_date(value, format=format)

@app.template_filter('format_datetime')
def format_datetime_filter(value, format='medium'):
    """Format datetime for current locale."""
    if isinstance(value, str):
        value = datetime.fromisoformat(value)
    return format_datetime(value, format=format)

# Generate translations
def generate_translations():
    """Generate translation files."""
    import subprocess
    
    # Extract strings
    subprocess.run(['pybabel', 'extract', '-F', 'babel.cfg', '-o', 'messages.pot', '.'])
    
    # Update existing translations
    for lang in app.config['LANGUAGES'].keys():
        subprocess.run([
            'pybabel', 'update',
            '-i', 'messages.pot',
            '-d', 'translations',
            '-l', lang
        ])
    
    # Compile translations
    subprocess.run(['pybabel', 'compile', '-d', 'translations'])

# babel.cfg file
"""
[python: **.py]
[jinja2: **/templates/**.html]
extensions=jinja2.ext.autoescape,jinja2.ext.with_
"""

# Language switcher in templates
"""
<div class="language-switcher">
    {% for code, name in config.LANGUAGES.items() %}
        <a href="{{ url_for('main.index', lang=code) }}"
           class="lang-{{ code }}{% if current_locale == code %} active{% endif %}">
            {{ name }}
        </a>
    {% endfor %}
</div>
"""
```

---

## 8. Security Considerations

### Autoescaping & Sanitization

```python
from jinja2 import Markup, escape
from markupsafe import escape_silent
import bleach

# Safe string handling
class SafeString:
    """Handle safe strings with proper escaping."""
    
    @staticmethod
    def safe_html(content):
        """Create safe HTML content."""
        if isinstance(content, Markup):
            return content
        return Markup(content)
    
    @staticmethod
    def sanitize_html(content):
        """Sanitize HTML content."""
        allowed_tags = [
            'p', 'br', 'b', 'strong', 'i', 'em', 'u',
            'h1', 'h2', 'h3', 'h4', 'h5', 'h6',
            'ul', 'ol', 'li',
            'a', 'img', 'blockquote', 'code', 'pre'
        ]
        allowed_attrs = {
            'a': ['href', 'target', 'rel'],
            'img': ['src', 'alt', 'title'],
            '*': ['class', 'id']
        }
        
        return bleach.clean(content, tags=allowed_tags, attributes=allowed_attrs)
    
    @staticmethod
    def escape_for_context(content, context='html'):
        """Escape content for specific context."""
        if context == 'html':
            return escape(content)
        elif context == 'js':
            return escape(content).replace("'", "\\'").replace('"', '\\"')
        elif context == 'css':
            return escape(content).replace('"', '\\"')
        elif context == 'url':
            from urllib.parse import quote
            return quote(content)
        else:
            return content

# Custom template filter for safe data
@app.template_filter('safe_json')
def safe_json_filter(data):
    """Convert data to safe JSON for embedding in HTML."""
    import json
    
    # Escape JSON for HTML embedding
    json_str = json.dumps(data)
    # Replace dangerous characters
    json_str = json_str.replace('<', '\\u003c')
    json_str = json_str.replace('>', '\\u003e')
    json_str = json_str.replace('&', '\\u0026')
    
    return Markup(json_str)

# Content Security Policy in templates
"""
{# Add CSP nonce to scripts #}
<script nonce="{{ csp_nonce() }}">
    // Secure JavaScript
</script>

{# Safe data embedding #}
<script nonce="{{ csp_nonce() }}">
    const TASK_DATA = {{ task|safe_json }};
</script>
"""

@app.context_processor
def csp_processor():
    """Add CSP nonce to templates."""
    import secrets
    
    def csp_nonce():
        """Generate CSP nonce for script tags."""
        if not hasattr(g, 'csp_nonce'):
            g.csp_nonce = secrets.token_urlsafe(32)
        return g.csp_nonce
    
    return {'csp_nonce': csp_nonce}

# CSP header middleware
@app.after_request
def add_csp_header(response):
    """Add CSP header with nonce."""
    if hasattr(g, 'csp_nonce'):
        csp = [
            f"default-src 'self'",
            f"script-src 'self' 'nonce-{g.csp_nonce}'",
            f"style-src 'self' 'unsafe-inline'",
            f"img-src 'self' data: https:",
            f"font-src 'self'",
            f"connect-src 'self'",
            f"frame-ancestors 'none'",
            f"form-action 'self'",
        ]
        response.headers['Content-Security-Policy'] = '; '.join(csp)
    
    return response
```

---

## 9. Advanced Use Cases

### Dynamic Template Generation

```python
from jinja2 import Environment, FileSystemLoader
import json

class DynamicTemplate:
    """Generate and render templates dynamically."""
    
    def __init__(self):
        self.env = Environment(loader=FileSystemLoader('templates'))
    
    def generate_from_schema(self, schema, data):
        """Generate template from JSON schema."""
        template = self._build_template(schema)
        return self.env.from_string(template).render(data)
    
    def _build_template(self, schema, path=''):
        """Build template from schema recursively."""
        if isinstance(schema, dict):
            if 'type' in schema:
                if schema['type'] == 'object':
                    return self._build_object_template(schema, path)
                elif schema['type'] == 'array':
                    return self._build_array_template(schema, path)
                elif schema['type'] == 'string':
                    return self._build_string_template(schema, path)
                elif schema['type'] == 'boolean':
                    return self._build_boolean_template(schema, path)
            else:
                return self._build_object_template(schema, path)
        elif isinstance(schema, list):
            return self._build_array_template({'items': schema}, path)
        else:
            return str(schema)
    
    def _build_object_template(self, schema, path):
        """Build template for object type."""
        template = []
        template.append(f'<div class="object-{path}">')
        
        # Add properties
        properties = schema.get('properties', {})
        for key, value in properties.items():
            field_path = f"{path}.{key}" if path else key
            template.append(f'<div class="field-{field_path}">')
            template.append(f'<label>{key}</label>')
            template.append(self._build_template(value, field_path))
            template.append('</div>')
        
        template.append('</div>')
        return '\n'.join(template)
    
    def _build_array_template(self, schema, path):
        """Build template for array type."""
        items = schema.get('items', {})
        item_path = f"{path}[]"
        return f"""
        <div class="array-{path}">
            {{% for item in {path} %}}
                <div class="array-item-{path}">
                    {self._build_template(items, item_path)}
                </div>
            {{% endfor %}}
        </div>
        """
    
    def _build_string_template(self, schema, path):
        """Build template for string type."""
        return f"{{{{ {path} }}}}"
    
    def _build_boolean_template(self, schema, path):
        """Build template for boolean type."""
        return f"""
        <div class="boolean-{path}">
            <input type="checkbox" {{% if {path} %}}checked{{% endif %}}>
        </div>
        """

# Usage
dynamic = DynamicTemplate()

# JSON schema
schema = {
    'type': 'object',
    'properties': {
        'title': {'type': 'string'},
        'description': {'type': 'string'},
        'tasks': {
            'type': 'array',
            'items': {
                'type': 'object',
                'properties': {
                    'name': {'type': 'string'},
                    'completed': {'type': 'boolean'},
                }
            }
        }
    }
}

data = {
    'title': 'Project',
    'description': 'Project description',
    'tasks': [
        {'name': 'Task 1', 'completed': True},
        {'name': 'Task 2', 'completed': False},
    ]
}

rendered = dynamic.generate_from_schema(schema, data)
```

### Template Components for Frontend Frameworks

```python
# Vue.js component template
"""
{# _vue_component.html #}
<template>
    <div class="task-card">
        <h3>{{ task.title }}</h3>
        <p>{{ task.description }}</p>
        <span class="priority" :class="task.priority">
            {{ task.priority }}
        </span>
        
        <div class="actions">
            <button @click="completeTask">Complete</button>
            <button @click="deleteTask">Delete</button>
        </div>
    </div>
</template>

<script>
export default {
    props: ['task'],
    methods: {
        completeTask() {
            this.$emit('complete', this.task.id);
        },
        deleteTask() {
            this.$emit('delete', this.task.id);
        }
    }
}
</script>

<style scoped>
.task-card {
    border: 1px solid #ddd;
    padding: 1rem;
    margin: 0.5rem 0;
}
.priority.high { color: red; }
.priority.medium { color: yellow; }
.priority.low { color: green; }
</style>
"""

# Generating React components
class ReactComponentGenerator:
    """Generate React components from Flask templates."""
    
    @staticmethod
    def generate_component(component_name, props, template):
        """Generate React component."""
        return f"""
        import React from 'react';
        
        const {component_name} = ({','.join(props)}) => (
            {template}
        );
        
        export default {component_name};
        """
    
    @staticmethod
    def generate_container(component_name, api_endpoint):
        """Generate React container with data fetching."""
        return f"""
        import React, {{ useState, useEffect }} from 'react';
        import {component_name} from './{component_name}';
        
        const {component_name}Container = () => {{
            const [data, setData] = useState(null);
            const [loading, setLoading] = useState(true);
            
            useEffect(() => {{
                fetch('{api_endpoint}')
                    .then(response => response.json())
                    .then(data => {{
                        setData(data);
                        setLoading(false);
                    }});
            }}, []);
            
            if (loading) return <div>Loading...</div>;
            
            return <{component_name} data={{data}} />;
        }};
        
        export default {component_name}Container;
        """
```

---

## Summary

This appendix has covered advanced Jinja2 templating:

1. **Architecture**: Template compilation, context resolution
2. **Inheritance**: Advanced block patterns, conditional layouts
3. **Filters & Tests**: Custom filters, filter chaining, composition
4. **Macros**: Reusable components, component slots, dynamic loading
5. **Extensions**: Custom tags, global functions, context processors
6. **Performance**: Caching strategies, profiling, precompilation
7. **Internationalization**: Translation, date formatting, locale management
8. **Security**: Autoescaping, sanitization, CSP integration
9. **Advanced Use Cases**: Dynamic templates, frontend framework integration

**Best Practices**:
- Keep templates logic-free
- Use filters for data formatting
- Leverage macros for reusable components
- Cache expensive template operations
- Use autoescaping and sanitization
- Implement proper template inheritance
- Profile templates in development
