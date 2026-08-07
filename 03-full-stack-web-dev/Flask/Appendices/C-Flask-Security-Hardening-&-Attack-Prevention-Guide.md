# Appendix C: Flask Security Hardening & Attack Prevention Guide

Welcome to Appendix C! This comprehensive reference provides an expert-level deep dive into security for Flask applications. While the main tutorial covered practical security implementations, this appendix explores the threat landscape in detail, advanced security patterns, and defense-in-depth strategies that will help you build truly secure applications.

---

## Table of Contents

1. [The Threat Landscape](#1-the-threat-landscape)
2. [OWASP Top 10 in Flask Context](#2-owasp-top-10-in-flask-context)
3. [Authentication & Session Security](#3-authentication--session-security)
4. [Input Validation & Output Encoding](#4-input-validation--output-encoding)
5. [SQL Injection Prevention Deep Dive](#5-sql-injection-prevention-deep-dive)
6. [Cross-Site Scripting (XSS) Prevention](#6-cross-site-scripting-xss-prevention)
7. [Cross-Site Request Forgery (CSRF)](#7-cross-site-request-forgery-csrf)
8. [Secure Headers & HTTPS Implementation](#8-secure-headers--https-implementation)
9. [File Upload Security](#9-file-upload-security)
10. [API Security & Rate Limiting](#10-api-security--rate-limiting)
11. [Security Monitoring & Incident Response](#11-security-monitoring--incident-response)

---

## 1. The Threat Landscape

### Understanding Attack Vectors

Web applications face threats from multiple angles. Understanding these threats is the first step to defending against them.

```
┌─────────────────────────────────────────────────────────────┐
│                    Attack Surface                           │
├─────────────────────────────────────────────────────────────┤
│  Network Layer           │  Application Layer               │
│  - Man-in-the-Middle     │  - SQL Injection                 │
│  - DDoS Attacks          │  - XSS                           │
│  - Port Scanning         │  - CSRF                          │
│  - SSL/TLS Attacks       │  - Session Hijacking            │
├──────────────────────────┼──────────────────────────────────┤
│  Infrastructure Layer    │  Human Layer                     │
│  - Server Vulnerabilities│  - Phishing                     │
│  - Misconfiguration      │  - Social Engineering           │
│  - Outdated Software     │  - Weak Passwords               │
│  - Insecure Cloud Setup  │  - Insider Threats              │
└─────────────────────────────────────────────────────────────┘
```

### Common Attack Patterns in Flask Applications

```python
# Example: SQL Injection
# ❌ Vulnerable code
@app.route('/user/<user_id>')
def get_user(user_id):
    query = f"SELECT * FROM users WHERE id = {user_id}"
    result = db.engine.execute(query)
    return jsonify(result.fetchall())

# Example: XSS
# ❌ Vulnerable code
@app.route('/search')
def search():
    query = request.args.get('q', '')
    return f"<h1>Search results for: {query}</h1>"

# Example: CSRF
# ❌ Vulnerable code
@app.route('/delete-account', methods=['POST'])
def delete_account():
    # No CSRF protection!
    user_id = session['user_id']
    # Delete account...
    return "Account deleted"

# Example: Path Traversal
# ❌ Vulnerable code
@app.route('/files/<path:filename>')
def download_file(filename):
    # No path validation!
    return send_file(f'/var/files/{filename}')
```

---

## 2. OWASP Top 10 in Flask Context

### OWASP Top 10 Vulnerabilities (2021) and Flask Countermeasures

| # | Vulnerability | Flask Countermeasure |
|---|---------------|---------------------|
| **A01:2021** | Broken Access Control | Role-based authorization, decorators, @login_required |
| **A02:2021** | Cryptographic Failures | Use HTTPS, secure session cookies, proper password hashing |
| **A03:2021** | Injection | SQLAlchemy parameterized queries, input validation |
| **A04:2021** | Insecure Design | Security by design, threat modeling, secure defaults |
| **A05:2021** | Security Misconfiguration | Secure defaults, environment-specific configs, secrets management |
| **A06:2021** | Vulnerable Components | Dependency scanning, regular updates, pip-audit |
| **A07:2021** | Identification/Auth Failures | Strong password policies, MFA, session management |
| **A08:2021** | Software/Data Integrity | Secure CI/CD, signed commits, dependency pinning |
| **A09:2021** | Security Logging Failures | Structured logging, audit trails, monitoring |
| **A10:2021** | Server-Side Request Forgery | Input validation, URL allowlisting, network segmentation |

### Implementing OWASP Compliance in Flask

```python
# A01: Broken Access Control Prevention
from functools import wraps
from flask import abort, session

def role_required(role):
    def decorator(f):
        @wraps(f)
        def decorated(*args, **kwargs):
            if session.get('role') != role:
                abort(403)
            return f(*args, **kwargs)
        return decorated
    return decorator

# A02: Cryptographic Failures Prevention
def secure_config():
    # Use HTTPS-only cookies
    app.config['SESSION_COOKIE_SECURE'] = True
    app.config['SESSION_COOKIE_HTTPONLY'] = True
    app.config['SESSION_COOKIE_SAMESITE'] = 'Strict'
    
    # Use strong hashing
    from werkzeug.security import generate_password_hash
    password_hash = generate_password_hash(
        password,
        method='scrypt'  # Strongest available
    )

# A05: Security Misconfiguration Prevention
class ProductionConfig:
    DEBUG = False
    TESTING = False
    SECRET_KEY = os.environ.get('SECRET_KEY')  # Never hardcode!
    
    # Always validate critical config
    @classmethod
    def init_app(cls, app):
        if not cls.SECRET_KEY:
            raise ValueError("SECRET_KEY must be set in production")
        if cls.SECRET_KEY == 'dev-secret-key-change-in-production':
            raise ValueError("SECRET_KEY must be changed from default")
```

---

## 3. Authentication & Session Security

### Secure Password Storage

```python
import secrets
import hashlib
from werkzeug.security import generate_password_hash, check_password_hash

# ❌ BAD: Plain text storage
def bad_password_storage(user, password):
    user.password = password  # NEVER DO THIS!
    db.session.commit()

# ❌ BAD: Weak hashing (MD5)
def bad_hashing(user, password):
    user.password_hash = hashlib.md5(password.encode()).hexdigest()

# ✅ GOOD: Werkzeug's secure password hashing
def good_password_storage(user, password):
    # Uses pbkdf2:sha256 with 600,000 iterations by default
    user.password_hash = generate_password_hash(password)
    db.session.commit()

# ✅ BEST: Using scrypt or argon2
def best_password_storage(user, password):
    # scrypt is memory-hard and resistant to GPU attacks
    from werkzeug.security import generate_password_hash
    user.password_hash = generate_password_hash(password, method='scrypt')
    db.session.commit()

# Password policy enforcement
def validate_password(password):
    # Length requirements
    if len(password) < 12:
        return False, "Password must be at least 12 characters"
    
    # Complexity requirements
    if not any(c.isupper() for c in password):
        return False, "Password must contain at least one uppercase letter"
    if not any(c.islower() for c in password):
        return False, "Password must contain at least one lowercase letter"
    if not any(c.isdigit() for c in password):
        return False, "Password must contain at least one number"
    if not any(c in "!@#$%^&*()_+-=" for c in password):
        return False, "Password must contain at least one special character"
    
    # Check against common passwords
    common_passwords = load_common_passwords()
    if password in common_passwords:
        return False, "Password is too common"
    
    # Check against username/email
    return True, "Password meets requirements"
```

### Session Management

```python
from flask import session, request, g
from itsdangerous import URLSafeTimedSerializer, SignatureExpired, BadSignature

class SessionManager:
    def __init__(self, app):
        self.app = app
        self.serializer = URLSafeTimedSerializer(
            app.config['SECRET_KEY'],
            salt='session-security'
        )
    
    def create_secure_session(self, user_id):
        """Create a session with security tracking."""
        session.clear()
        session['user_id'] = user_id
        session['login_time'] = datetime.utcnow().isoformat()
        session['ip_address'] = request.remote_addr
        session['user_agent'] = request.headers.get('User-Agent')
        session['session_id'] = secrets.token_urlsafe(32)
        
        # Sign the session data to detect tampering
        session['signature'] = self._sign_session(session)
    
    def verify_session(self):
        """Verify session integrity and detect hijacking."""
        if 'user_id' not in session:
            return False
        
        # Verify signature
        if not self._verify_session(session):
            session.clear()
            return False
        
        # Check for session hijacking
        if session.get('ip_address') != request.remote_addr:
            app.logger.warning(f"Session hijacking attempt: {session.get('user_id')}")
            session.clear()
            return False
        
        # Check user agent consistency
        current_agent = request.headers.get('User-Agent')
        if session.get('user_agent') != current_agent:
            app.logger.warning(f"User agent changed for user: {session.get('user_id')}")
            # Could force re-authentication
        
        # Session timeout
        login_time = datetime.fromisoformat(session.get('login_time'))
        if (datetime.utcnow() - login_time).days > 7:
            session.clear()
            return False
        
        return True
    
    def _sign_session(self, session):
        """Sign session data to prevent tampering."""
        # Create a string representation of session data
        session_string = f"{session.get('user_id')}|{session.get('session_id')}|{session.get('login_time')}"
        return self.serializer.dumps(session_string)
    
    def _verify_session(self, session):
        """Verify session signature."""
        if 'signature' not in session:
            return False
        
        try:
            session_string = f"{session.get('user_id')}|{session.get('session_id')}|{session.get('login_time')}"
            expected = self.serializer.loads(session['signature'])
            return expected == session_string
        except (SignatureExpired, BadSignature):
            return False

# Session management middleware
@app.before_request
def check_session():
    if 'user_id' in session:
        session_manager = SessionManager(app)
        if not session_manager.verify_session():
            session.clear()
            flash("Your session was invalid or expired. Please log in again.", "warning")
            return redirect(url_for('auth.login'))

# Logout with session clearing
@app.route('/logout')
def logout():
    # Log the logout
    app.logger.info(f"User {session.get('user_id')} logged out")
    
    # Clear session
    session.clear()
    
    # Redirect
    flash("You have been logged out.", "info")
    return redirect(url_for('main.index'))
```

### Multi-Factor Authentication (MFA)

```python
import pyotp
import qrcode
from io import BytesIO
import base64

class MFAManager:
    def __init__(self, user):
        self.user = user
        
    def setup_mfa(self):
        """Generate MFA secret and QR code."""
        # Generate secret key
        secret = pyotp.random_base32()
        self.user.mfa_secret = secret
        db.session.commit()
        
        # Generate TOTP URI
        totp = pyotp.TOTP(secret)
        uri = totp.provisioning_uri(
            name=self.user.email,
            issuer_name="TaskFlow"
        )
        
        # Generate QR code
        qr = qrcode.QRCode(version=1, box_size=10, border=5)
        qr.add_data(uri)
        qr.make(fit=True)
        img = qr.make_image(fill_color="black", back_color="white")
        
        # Convert to base64 for embedding in HTML
        buffered = BytesIO()
        img.save(buffered, format="PNG")
        qr_base64 = base64.b64encode(buffered.getvalue()).decode()
        
        return {
            'secret': secret,
            'qr_code': qr_base64,
            'uri': uri
        }
    
    def verify_mfa_code(self, code):
        """Verify a TOTP code."""
        if not self.user.mfa_secret:
            return False
        
        totp = pyotp.TOTP(self.user.mfa_secret)
        return totp.verify(code)
    
    def generate_recovery_codes(self):
        """Generate backup recovery codes."""
        codes = []
        for i in range(10):
            code = secrets.token_hex(4).upper()
            # Store hashed versions of codes
            hashed = hashlib.sha256(code.encode()).hexdigest()
            codes.append(hashed)
        
        self.user.recovery_codes = codes
        db.session.commit()
        
        # Return plain codes to user
        return [secrets.token_hex(4).upper() for _ in range(10)]

# MFA verification endpoint
@app.route('/verify-mfa', methods=['POST'])
@login_required
def verify_mfa():
    code = request.form.get('code')
    mfa_manager = MFAManager(current_user)
    
    if mfa_manager.verify_mfa_code(code):
        session['mfa_verified'] = True
        return redirect(url_for('tasks.dashboard'))
    else:
        flash("Invalid MFA code. Please try again.", "danger")
        return render_template('auth/verify_mfa.html')
```

---

## 4. Input Validation & Output Encoding

### Comprehensive Input Validation

```python
from marshmallow import Schema, fields, validate, ValidationError
import re
from flask import request, jsonify

class UserRegistrationSchema(Schema):
    """Schema for validating user registration input."""
    username = fields.Str(
        required=True,
        validate=[
            validate.Length(min=3, max=50),
            validate.Regexp(
                r'^[a-zA-Z0-9_]+$',
                error="Username must contain only letters, numbers, and underscores"
            )
        ]
    )
    email = fields.Email(required=True)
    password = fields.Str(
        required=True,
        validate=validate.Length(min=12)
    )
    first_name = fields.Str(
        validate=[
            validate.Length(max=50),
            validate.Regexp(
                r'^[a-zA-Z\s\-]+$',
                error="First name must contain only letters, spaces, and hyphens"
            )
        ]
    )
    last_name = fields.Str(
        validate=[
            validate.Length(max=50),
            validate.Regexp(
                r'^[a-zA-Z\s\-]+$',
                error="Last name must contain only letters, spaces, and hyphens"
            )
        ]
    )

class TaskSchema(Schema):
    """Schema for validating task input."""
    title = fields.Str(
        required=True,
        validate=[
            validate.Length(min=1, max=200)
        ]
    )
    description = fields.Str(
        validate=validate.Length(max=2000)
    )
    priority = fields.Str(
        validate=validate.OneOf(['low', 'medium', 'high', 'urgent'])
    )
    status = fields.Str(
        validate=validate.OneOf(['pending', 'in_progress', 'review', 'completed', 'archived'])
    )
    due_date = fields.DateTime(
        validate=validate.Range(
            min=datetime.utcnow(),
            error="Due date must be in the future"
        )
    )

# Usage in routes
@app.route('/api/users', methods=['POST'])
def create_user():
    schema = UserRegistrationSchema()
    
    try:
        # Validate request data
        validated_data = schema.load(request.get_json())
        
        # Data is now validated and typed
        user = UserService.create_user(**validated_data)
        return jsonify({'user': user.id}), 201
        
    except ValidationError as err:
        return jsonify({
            'errors': err.messages
        }), 400
```

### Output Encoding Strategies

```python
import html
import bleach
from markupsafe import Markup, escape

# Contextual encoding for HTML
def contextual_encoding(data, context):
    """
    Apply context-appropriate encoding.
    
    Contexts:
    - 'html': HTML body encoding
    - 'attribute': HTML attribute encoding
    - 'javascript': JavaScript encoding
    - 'css': CSS encoding
    - 'url': URL encoding
    """
    if context == 'html':
        return html.escape(data)
    elif context == 'attribute':
        # Attribute encoding (more strict)
        return html.escape(data, quote=True)
    elif context == 'javascript':
        # JavaScript string encoding
        return json.dumps(data)[1:-1]
    elif context == 'css':
        # CSS string encoding
        return data.replace('\\', '\\\\').replace('"', '\\"')
    elif context == 'url':
        from urllib.parse import quote
        return quote(data)
    else:
        return data

# Using Bleach for safe HTML rendering
def safe_html_render(html_content):
    """
    Render HTML safely with Bleach.
    
    Allows only safe tags and attributes.
    """
    # Define allowed tags
    allowed_tags = [
        'p', 'br', 'b', 'strong', 'i', 'em', 'u',
        'h1', 'h2', 'h3', 'h4', 'h5', 'h6',
        'ul', 'ol', 'li',
        'a', 'img', 'blockquote', 'code', 'pre'
    ]
    
    # Define allowed attributes
    allowed_attrs = {
        'a': ['href', 'target', 'rel'],
        'img': ['src', 'alt', 'title'],
        '*': ['class', 'id']
    }
    
    # Define allowed CSS
    allowed_styles = ['color', 'background-color', 'font-size']
    
    # Clean the HTML
    cleaned = bleach.clean(
        html_content,
        tags=allowed_tags,
        attributes=allowed_attrs,
        styles=allowed_styles,
        strip=True
    )
    
    return cleaned

# Custom template filter for safe HTML
@app.template_filter('safe_html')
def safe_html_filter(value):
    return Markup(safe_html_render(value))
```

### Sanitization vs Validation

```python
# Validation: "Is this input valid?"
def validate_email(email):
    """Validate email format without modifying it."""
    pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    return re.match(pattern, email) is not None

# Sanitization: "Clean this input to make it safe"
def sanitize_html(html):
    """Remove dangerous HTML while preserving structure."""
    return bleach.clean(html, tags=['p', 'b', 'i', 'u'])

# Normalization: "Standardize this input"
def normalize_phone(phone):
    """Convert phone numbers to a standard format."""
    # Remove all non-digit characters
    cleaned = re.sub(r'\D', '', phone)
    # Format as (XXX) XXX-XXXX
    if len(cleaned) == 10:
        return f"({cleaned[:3]}) {cleaned[3:6]}-{cleaned[6:]}"
    return phone

# Escaping: "Make this safe for a specific context"
def escape_for_context(data, context):
    """Escape data for different output contexts."""
    if context == 'html':
        return html.escape(data)
    elif context == 'js':
        return json.dumps(data)
    elif context == 'sql':
        # Never escape for SQL - use parameterized queries instead!
        raise ValueError("SQL escaping must use parameterized queries")
```

---

## 5. SQL Injection Prevention Deep Dive

### How SQL Injection Works

```python
# ❌ VULNERABLE: String concatenation
@app.route('/user/<user_id>')
def vulnerable_query(user_id):
    # If user_id = "1 OR 1=1", this returns ALL users
    query = f"SELECT * FROM users WHERE id = {user_id}"
    result = db.engine.execute(query)
    return jsonify([dict(row) for row in result])

# ❌ VULNERABLE: Raw SQL with bad formatting
@app.route('/tasks')
def vulnerable_filter():
    status = request.args.get('status', 'pending')
    # If status = "pending' OR '1'='1", returns ALL tasks
    query = f"SELECT * FROM tasks WHERE status = '{status}'"
    result = db.engine.execute(query)
    return jsonify([dict(row) for row in result])

# ✅ SAFE: Parameterized queries with SQLAlchemy
@app.route('/user/<user_id>')
def safe_query(user_id):
    # SQLAlchemy automatically parameterizes
    user = User.query.get(user_id)
    return jsonify(user.to_dict())

# ✅ SAFE: Raw SQL with parameters
@app.route('/tasks')
def safe_filter():
    status = request.args.get('status', 'pending')
    # Using SQLAlchemy Core with parameters
    query = text("SELECT * FROM tasks WHERE status = :status")
    result = db.engine.execute(query, {'status': status})
    return jsonify([dict(row) for row in result])

# ✅ SAFE: Use SQLAlchemy's expression language
@app.route('/tasks')
def safe_expression():
    status = request.args.get('status', 'pending')
    query = db.session.query(Task).filter(Task.status == status)
    return jsonify([task.to_dict() for task in query])
```

### Advanced SQL Injection Defenses

```python
from sqlalchemy import event, text
from sqlalchemy.engine import Engine

# 1. SQL injection detection with auditing
@event.listens_for(Engine, "before_execute")
def before_execute(conn, clause, multiparams, params):
    """Audit SQL statements for suspicious patterns."""
    statement = str(clause)
    suspicious_patterns = [
        '; DROP', '; DELETE', '; UPDATE', '; INSERT',
        'UNION SELECT', 'AND 1=1', 'OR 1=1',
        '--', '/*', '*/', 'xp_', 'sp_'
    ]
    
    for pattern in suspicious_patterns:
        if pattern.lower() in statement.lower():
            app.logger.warning(f"Suspicious SQL pattern detected: {pattern}")
            app.logger.warning(f"Query: {statement}")
            app.logger.warning(f"Parameters: {params}")
            # Could block the query here

# 2. Query parameter validation
def validate_query_params(query_params):
    """Validate query parameters before using in SQL."""
    allowed_fields = ['id', 'username', 'email', 'status']
    for key in query_params:
        if key not in allowed_fields:
            raise ValueError(f"Invalid query parameter: {key}")

# 3. Use prepared statements for all raw SQL
def safe_raw_query(sql, params):
    """Execute raw SQL safely with prepared statements."""
    # Always use text() and bind parameters
    query = text(sql)
    result = db.engine.execute(query, **params)
    return result

# 4. Input filtering for SQL keywords
def filter_sql_keywords(input_str):
    """Remove or escape SQL keywords from input."""
    keywords = ['SELECT', 'INSERT', 'UPDATE', 'DELETE', 'DROP', 'UNION', 
                'FROM', 'WHERE', 'ORDER', 'GROUP', 'HAVING', 'JOIN']
    for keyword in keywords:
        input_str = input_str.replace(keyword, '')
    return input_str
```

---

## 6. Cross-Site Scripting (XSS) Prevention

### Understanding XSS Types

```python
# 1. Reflected XSS
@app.route('/search')
def reflected_xss():
    # ❌ VULNERABLE: User input echoed directly
    query = request.args.get('q', '')
    return f"<h1>Search results for: {query}</h1>"

# 2. Stored XSS
@app.route('/comment', methods=['POST'])
def stored_xss():
    # ❌ VULNERABLE: User input stored and displayed later
    comment = request.form.get('comment')
    db.execute("INSERT INTO comments (text) VALUES (?)", (comment,))
    return redirect('/comments')

# 3. DOM-based XSS
# ❌ VULNERABLE: Client-side JavaScript using unsafe input
# <script>
#   const query = new URLSearchParams(window.location.search).get('q');
#   document.getElementById('results').innerHTML = query;
# </script>
```

### Comprehensive XSS Prevention

```python
from markupsafe import escape, Markup
import bleach
import re

class XSSPrevention:
    """Comprehensive XSS prevention utilities."""
    
    @staticmethod
    def escape_all(data):
        """Escape all potentially dangerous characters."""
        if isinstance(data, str):
            return escape(data)
        elif isinstance(data, dict):
            return {k: XSSPrevention.escape_all(v) for k, v in data.items()}
        elif isinstance(data, list):
            return [XSSPrevention.escape_all(item) for item in data]
        else:
            return data
    
    @staticmethod
    def sanitize_html(html_content):
        """Sanitize HTML content while preserving safe formatting."""
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
        
        return bleach.clean(
            html_content,
            tags=allowed_tags,
            attributes=allowed_attrs,
            strip=True
        )
    
    @staticmethod
    def validate_url(url):
        """Validate URLs to prevent javascript: and other dangerous schemes."""
        if not url:
            return None
        
        # Only allow certain schemes
        allowed_schemes = ['http', 'https', 'mailto', 'tel']
        
        # Parse and validate URL
        from urllib.parse import urlparse
        parsed = urlparse(url)
        
        if parsed.scheme not in allowed_schemes:
            return None
        
        # Prevent javascript: protocol
        if parsed.scheme == 'javascript':
            return None
        
        return url

# Template filters for auto-escaping
@app.template_filter('safe_url')
def safe_url_filter(url):
    """Template filter for safe URLs."""
    return XSSPrevention.validate_url(url)

@app.template_filter('sanitize_html')
def sanitize_html_filter(html):
    """Template filter for sanitized HTML."""
    return Markup(XSSPrevention.sanitize_html(html))

# Content Security Policy headers
def add_csp_headers(response):
    """Add CSP headers to responses."""
    csp = [
        "default-src 'self'",
        "script-src 'self' 'unsafe-inline' https://cdn.jsdelivr.net",
        "style-src 'self' 'unsafe-inline' https://cdn.jsdelivr.net",
        "img-src 'self' data: https:",
        "font-src 'self' https://cdn.jsdelivr.net",
        "connect-src 'self'",
        "base-uri 'self'",
        "form-action 'self'",
        "frame-ancestors 'none'"
    ]
    
    response.headers['Content-Security-Policy'] = '; '.join(csp)
    return response
```

### XSS Prevention Checklist

```python
# ✅ Use Jinja's auto-escaping (enabled by default)
@app.route('/safe')
def safe_template():
    query = request.args.get('q', '')
    # Jinja auto-escapes {{ query }} by default
    return render_template('search.html', query=query)

# ✅ Use safe rendering for HTML content
@app.route('/safe-html')
def safe_html():
    html_content = get_unsafe_html()
    # Mark as safe only if you've sanitized it
    safe_html = XSSPrevention.sanitize_html(html_content)
    return render_template('safe.html', content=Markup(safe_html))

# ✅ Validate all user input
@app.route('/profile')
def safe_profile():
    name = request.args.get('name', '')
    # Validate input format
    if not re.match(r'^[a-zA-Z\s\-]+$', name):
        return "Invalid name", 400
    return render_template('profile.html', name=name)

# ✅ Use JSON serialization for API responses
@app.route('/api/data')
def api_data():
    data = get_user_input()
    # Flask's jsonify automatically escapes
    return jsonify(data)

# ✅ Set secure cookie flags
@app.after_request
def set_secure_cookies(response):
    response.headers['X-XSS-Protection'] = '1; mode=block'
    response.headers['X-Content-Type-Options'] = 'nosniff'
    return response
```

---

## 7. Cross-Site Request Forgery (CSRF)

### Understanding CSRF

```python
# ❌ VULNERABLE: No CSRF protection
@app.route('/transfer', methods=['POST'])
def transfer_money():
    amount = request.form.get('amount')
    to_account = request.form.get('to_account')
    # No CSRF token validation!
    # An attacker can trick a user into making this request
    
    transfer_funds(current_user.id, to_account, amount)
    return "Transfer complete"

# ✅ SAFE: CSRF protection with Flask-WTF
from flask_wtf import FlaskForm
from wtforms import HiddenField, FloatField, StringField
from wtforms.validators import DataRequired

class TransferForm(FlaskForm):
    """Form with CSRF protection."""
    # CSRF token is automatically included
    amount = FloatField('Amount', validators=[DataRequired()])
    to_account = StringField('To Account', validators=[DataRequired()])

@app.route('/transfer', methods=['POST'])
def transfer_money():
    form = TransferForm()
    if form.validate_on_submit():  # CSRF token automatically validated
        transfer_funds(current_user.id, form.to_account.data, form.amount.data)
        return "Transfer complete"
    return "Invalid request", 400
```

### Custom CSRF Protection Implementation

```python
import hmac
import hashlib
import secrets
from functools import wraps
from flask import request, session, g, abort, current_app

class CSRFProtection:
    """Custom CSRF protection implementation."""
    
    def __init__(self, app=None):
        self.app = app
        if app:
            self.init_app(app)
    
    def init_app(self, app):
        app.before_request(self.generate_csrf_token)
        app.jinja_env.globals['csrf_token'] = self.get_token
    
    def generate_csrf_token(self):
        """Generate a CSRF token and store it in the session."""
        if 'csrf_token' not in session:
            session['csrf_token'] = secrets.token_urlsafe(32)
        g.csrf_token = session['csrf_token']
    
    def get_token(self):
        """Get the current CSRF token for template usage."""
        return g.get('csrf_token', '')
    
    def validate_token(self, token):
        """Validate a CSRF token."""
        if not token:
            return False
        
        stored_token = session.get('csrf_token')
        if not stored_token:
            return False
        
        # Constant-time comparison to prevent timing attacks
        return hmac.compare_digest(token, stored_token)
    
    def protect(self, f):
        """Decorator to protect routes from CSRF."""
        @wraps(f)
        def decorated(*args, **kwargs):
            # Skip for safe methods
            if request.method in ['GET', 'HEAD', 'OPTIONS', 'TRACE']:
                return f(*args, **kwargs)
            
            # Get token from request
            token = request.form.get('csrf_token') or \
                    request.headers.get('X-CSRFToken') or \
                    request.headers.get('X-CSRF-Token')
            
            if not self.validate_token(token):
                current_app.logger.warning(f"CSRF validation failed: {request.path}")
                abort(403, description="CSRF token validation failed")
            
            return f(*args, **kwargs)
        return decorated

# Initialize CSRF protection
csrf = CSRFProtection(app)

# Use as decorator
@app.route('/transfer', methods=['POST'])
@csrf.protect
def transfer_money():
    # CSRF token validated before this function runs
    pass

# AJAX CSRF handling
@app.before_request
def setup_csrf_ajax():
    """Set CSRF token for AJAX requests."""
    if request.is_json:
        # For JSON requests, check header
        pass

# Template usage
# <input type="hidden" name="csrf_token" value="{{ csrf_token() }}">
# <meta name="csrf-token" content="{{ csrf_token() }}">
```

### Double Submit Cookie Pattern

```python
class DoubleSubmitCSRF:
    """
    CSRF protection using the Double Submit Cookie pattern.
    
    This pattern is useful for APIs and Single Page Applications.
    """
    
    @staticmethod
    def generate_token():
        """Generate a CSRF token and set it as a cookie."""
        token = secrets.token_urlsafe(32)
        # Set cookie with same-site strict
        response = make_response()
        response.set_cookie(
            'csrf_token',
            token,
            httponly=False,  # Must be accessible by JavaScript
            secure=True,
            samesite='Strict',
            max_age=3600
        )
        return response, token
    
    @staticmethod
    def validate_token(token):
        """Validate token against the cookie value."""
        cookie_token = request.cookies.get('csrf_token')
        if not cookie_token:
            return False
        return hmac.compare_digest(token, cookie_token)
    
    @staticmethod
    def protect_json_apis():
        """Protect JSON APIs with the double submit pattern."""
        # For AJAX requests, token sent in header
        token = request.headers.get('X-CSRF-Token')
        return DoubleSubmitCSRF.validate_token(token)

# Usage for SPA
@app.route('/api/login', methods=['POST'])
def api_login():
    # ... validate credentials ...
    
    # Generate CSRF token for API session
    response, token = DoubleSubmitCSRF.generate_token()
    return jsonify({
        'csrf_token': token,
        'user': user.to_dict()
    }), response

# Usage for API endpoints
@app.route('/api/tasks', methods=['POST'])
def api_create_task():
    # Validate CSRF token from header
    token = request.headers.get('X-CSRF-Token')
    if not DoubleSubmitCSRF.validate_token(token):
        abort(403, description="Invalid CSRF token")
    
    # ... create task ...
```

---

## 8. Secure Headers & HTTPS Implementation

### Comprehensive Security Headers

```python
from flask import make_response, request, current_app
import re

class SecurityHeaders:
    """Comprehensive security headers implementation."""
    
    @staticmethod
    def apply_all(response):
        """Apply all security headers to a response."""
        SecurityHeaders.apply_hsts(response)
        SecurityHeaders.apply_csp(response)
        SecurityHeaders.apply_frame_options(response)
        SecurityHeaders.apply_xss_protection(response)
        SecurityHeaders.apply_content_type_options(response)
        SecurityHeaders.apply_referrer_policy(response)
        SecurityHeaders.apply_permissions_policy(response)
        SecurityHeaders.apply_remove_version_headers(response)
        return response
    
    @staticmethod
    def apply_hsts(response):
        """Apply HTTP Strict Transport Security."""
        if current_app.config.get('ENV') == 'production':
            # Force HTTPS for 1 year
            response.headers['Strict-Transport-Security'] = (
                'max-age=31536000; includeSubDomains; preload'
            )
        return response
    
    @staticmethod
    def apply_csp(response):
        """Apply Content Security Policy."""
        csp_directives = [
            "default-src 'self'",
            "script-src 'self' 'unsafe-inline' https://cdn.jsdelivr.net",
            "style-src 'self' 'unsafe-inline' https://cdn.jsdelivr.net",
            "img-src 'self' data: https:",
            "font-src 'self' https://cdn.jsdelivr.net",
            "connect-src 'self'",
            "base-uri 'self'",
            "form-action 'self'",
            "frame-ancestors 'none'",
            "report-uri /csp-report"
        ]
        response.headers['Content-Security-Policy'] = '; '.join(csp_directives)
        return response
    
    @staticmethod
    def apply_frame_options(response):
        """Apply X-Frame-Options to prevent clickjacking."""
        response.headers['X-Frame-Options'] = 'SAMEORIGIN'
        return response
    
    @staticmethod
    def apply_xss_protection(response):
        """Apply X-XSS-Protection."""
        response.headers['X-XSS-Protection'] = '1; mode=block'
        return response
    
    @staticmethod
    def apply_content_type_options(response):
        """Apply X-Content-Type-Options."""
        response.headers['X-Content-Type-Options'] = 'nosniff'
        return response
    
    @staticmethod
    def apply_referrer_policy(response):
        """Apply Referrer-Policy."""
        response.headers['Referrer-Policy'] = 'strict-origin-when-cross-origin'
        return response
    
    @staticmethod
    def apply_permissions_policy(response):
        """Apply Permissions-Policy."""
        policies = [
            "geolocation=()",
            "microphone=()",
            "camera=()",
            "payment=()",
            "usb=()",
            "magnetometer=()",
            "accelerometer=()"
        ]
        response.headers['Permissions-Policy'] = ', '.join(policies)
        return response
    
    @staticmethod
    def apply_remove_version_headers(response):
        """Remove server version headers."""
        response.headers.pop('Server', None)
        response.headers.pop('X-Powered-By', None)
        return response

# Apply headers globally
@app.after_request
def add_security_headers(response):
    return SecurityHeaders.apply_all(response)

# CSP violation reporting
@app.route('/csp-report', methods=['POST'])
def csp_report():
    """Handle CSP violation reports."""
    data = request.get_json()
    current_app.logger.warning(f"CSP violation: {data}")
    return '', 204
```

### HTTPS Implementation

```python
# SSL/TLS Configuration
ssl_context = {
    'certfile': '/path/to/certificate.pem',
    'keyfile': '/path/to/private_key.pem',
    'ssl_version': 2  # Use TLS 1.2+
}

# Running with SSL
# app.run(ssl_context=ssl_context)

# Development SSL (self-signed for testing)
# openssl req -x509 -newkey rsa:4096 -nodes -out cert.pem -keyout key.pem -days 365
# app.run(ssl_context=('cert.pem', 'key.pem'))

# Enforce HTTPS in production
@app.before_request
def enforce_https():
    """Redirect HTTP to HTTPS."""
    if current_app.config.get('ENV') == 'production':
        if not request.is_secure:
            url = request.url.replace('http://', 'https://', 1)
            return redirect(url, code=301)

# HSTS Preload - For submitting to browser HSTS preload list
# Add to response: Strict-Transport-Security: max-age=31536000; includeSubDomains; preload

# Secure cookie settings
app.config.update({
    'SESSION_COOKIE_SECURE': True,      # Only send cookies over HTTPS
    'SESSION_COOKIE_HTTPONLY': True,    # Prevent JavaScript access
    'SESSION_COOKIE_SAMESITE': 'Strict', # Prevent CSRF
    'REMEMBER_COOKIE_SECURE': True,
    'REMEMBER_COOKIE_HTTPONLY': True,
    'REMEMBER_COOKIE_SAMESITE': 'Strict',
})
```

---

## 9. File Upload Security

### Comprehensive File Upload Security

```python
import os
import magic
from werkzeug.utils import secure_filename
from PIL import Image
import hashlib

class SecureFileUpload:
    """Secure file upload handling."""
    
    ALLOWED_EXTENSIONS = {
        'jpg', 'jpeg', 'png', 'gif', 'webp',  # Images
        'pdf', 'doc', 'docx', 'xls', 'xlsx',  # Documents
        'txt', 'csv'                           # Text files
    }
    
    ALLOWED_MIME_TYPES = {
        'image/jpeg', 'image/png', 'image/gif', 'image/webp',
        'application/pdf', 'application/msword',
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
        'application/vnd.ms-excel',
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        'text/plain', 'text/csv'
    }
    
    MAX_FILE_SIZE = 16 * 1024 * 1024  # 16MB
    
    @staticmethod
    def validate_file(file):
        """Validate uploaded file."""
        if not file or not file.filename:
            return False, "No file selected"
        
        # 1. Check file size
        file.seek(0, os.SEEK_END)
        size = file.tell()
        file.seek(0)
        
        if size > SecureFileUpload.MAX_FILE_SIZE:
            return False, f"File too large (max {SecureFileUpload.MAX_FILE_SIZE // (1024*1024)}MB)"
        
        # 2. Check filename extension
        filename = secure_filename(file.filename)
        extension = filename.rsplit('.', 1)[1].lower() if '.' in filename else ''
        
        if extension not in SecureFileUpload.ALLOWED_EXTENSIONS:
            return False, "File type not allowed"
        
        # 3. Check MIME type with python-magic
        file_content = file.read(1024)
        file.seek(0)
        mime_type = magic.from_buffer(file_content, mime=True)
        
        if mime_type not in SecureFileUpload.ALLOWED_MIME_TYPES:
            return False, "Invalid file type"
        
        # 4. Additional image validation
        if mime_type.startswith('image/'):
            try:
                img = Image.open(file)
                img.verify()  # Verify image integrity
                file.seek(0)
            except Exception:
                return False, "Invalid image file"
        
        # 5. Scan for malware (in production, use ClamAV)
        # if not SecureFileUpload.scan_for_viruses(file):
        #     return False, "File may contain malware"
        
        return True, "File is valid"
    
    @staticmethod
    def generate_secure_filename(original_filename):
        """Generate a secure, unique filename."""
        # Get extension
        extension = original_filename.rsplit('.', 1)[1].lower() if '.' in original_filename else ''
        
        # Generate random filename
        random_name = secrets.token_hex(16)
        
        # Add timestamp for uniqueness
        timestamp = int(time.time())
        
        # Hash original name for audit
        name_hash = hashlib.sha256(original_filename.encode()).hexdigest()[:8]
        
        return f"{timestamp}_{random_name}_{name_hash}.{extension}"
    
    @staticmethod
    def save_uploaded_file(file, upload_dir, generate_thumbnail=False):
        """Save an uploaded file securely."""
        # Validate first
        valid, message = SecureFileUpload.validate_file(file)
        if not valid:
            raise ValueError(message)
        
        # Generate secure filename
        filename = SecureFileUpload.generate_secure_filename(file.filename)
        file_path = os.path.join(upload_dir, filename)
        
        # Save file
        file.save(file_path)
        
        # Set secure permissions
        os.chmod(file_path, 0o600)
        
        # Generate thumbnail if image
        if generate_thumbnail and file.content_type.startswith('image/'):
            thumbnail_path = SecureFileUpload.generate_thumbnail(file_path)
            return {
                'filename': filename,
                'path': file_path,
                'thumbnail': thumbnail_path
            }
        
        return {
            'filename': filename,
            'path': file_path
        }
    
    @staticmethod
    def generate_thumbnail(image_path, size=(200, 200)):
        """Generate a thumbnail for an image."""
        with Image.open(image_path) as img:
            # Maintain aspect ratio
            img.thumbnail(size)
            
            # Generate thumbnail filename
            base, ext = os.path.splitext(image_path)
            thumbnail_path = f"{base}_thumb{ext}"
            
            # Save thumbnail
            img.save(thumbnail_path, optimize=True, quality=85)
            os.chmod(thumbnail_path, 0o600)
            
            return thumbnail_path
    
    @staticmethod
    def scan_for_viruses(file):
        """Scan file for viruses using ClamAV."""
        # In production, implement ClamAV scanning
        # import clamd
        # cd = clamd.ClamdUnixSocket()
        # result = cd.scan_stream(file.read())
        # return result['stream'] == 'OK'
        return True  # Placeholder

# Upload route
@app.route('/upload', methods=['POST'])
@login_required
def upload_file():
    if 'file' not in request.files:
        flash('No file selected', 'danger')
        return redirect(request.referrer)
    
    file = request.files['file']
    
    try:
        result = SecureFileUpload.save_uploaded_file(
            file,
            current_app.config['UPLOAD_FOLDER'],
            generate_thumbnail=True
        )
        
        # Save to database
        attachment = Attachment(
            filename=result['filename'],
            path=result['path'],
            thumbnail_path=result.get('thumbnail'),
            user_id=current_user.id
        )
        db.session.add(attachment)
        db.session.commit()
        
        flash('File uploaded successfully!', 'success')
        
    except ValueError as e:
        flash(str(e), 'danger')
    
    return redirect(request.referrer)
```

---

## 10. API Security & Rate Limiting

### Comprehensive API Security

```python
from flask_limiter import Limiter
from flask_limiter.util import get_remote_address
from flask_httpauth import HTTPTokenAuth

# Rate Limiting Configuration
limiter = Limiter(
    get_remote_address,
    app=app,
    default_limits=["200 per day", "50 per hour"],
    storage_uri="redis://localhost:6379",
    strategy="fixed-window"
)

# Token Authentication
auth = HTTPTokenAuth(scheme='Bearer')

@auth.verify_token
def verify_token(token):
    """Verify API token."""
    # Validate token
    user_id = TokenManager.verify_token(token)
    if user_id:
        user = UserService.get_by_id(user_id)
        return user
    return None

# API Rate Limiting Examples
@app.route('/api/v1/tasks', methods=['GET'])
@auth.login_required
@limiter.limit("100 per minute")
def api_get_tasks():
    """Get tasks with rate limiting."""
    return jsonify(tasks)

@app.route('/api/v1/tasks', methods=['POST'])
@auth.login_required
@limiter.limit("30 per minute")
def api_create_task():
    """Create task with stricter rate limit."""
    return jsonify(task)

# Rate Limiting for Sensitive Endpoints
@app.route('/api/auth/login', methods=['POST'])
@limiter.limit("5 per minute", error_message="Too many login attempts")
def api_login():
    """Login with very strict rate limit."""
    pass

# IP-Based Rate Limiting
@app.route('/api/sensitive', methods=['POST'])
@limiter.limit("10 per hour", key_func=get_remote_address)
def sensitive_operation():
    """Endpoint with IP-based rate limiting."""
    pass

# Custom Rate Limit Keys (per user)
def get_user_key():
    """Get rate limit key based on user ID."""
    if current_user.is_authenticated:
        return f"user:{current_user.id}"
    return get_remote_address()

@app.route('/api/user-data', methods=['GET'])
@limiter.limit("60 per minute", key_func=get_user_key)
def user_data():
    """Rate limit per user."""
    pass

# Rate Limit Headers
@limiter.request_filter
def add_rate_limit_headers(response):
    """Add rate limit headers to response."""
    response.headers['X-RateLimit-Limit'] = '100'
    response.headers['X-RateLimit-Remaining'] = '95'
    response.headers['X-RateLimit-Reset'] = '3600'
    return response
```

### API Authentication Best Practices

```python
# JWT Authentication
import jwt
from datetime import datetime, timedelta

class JWTManager:
    """JWT-based API authentication."""
    
    @staticmethod
    def generate_token(user_id, expires_in=3600):
        """Generate JWT token."""
        payload = {
            'user_id': user_id,
            'exp': datetime.utcnow() + timedelta(seconds=expires_in),
            'iat': datetime.utcnow(),
            'iss': 'taskflow-api'
        }
        return jwt.encode(
            payload,
            current_app.config['SECRET_KEY'],
            algorithm='HS256'
        )
    
    @staticmethod
    def verify_token(token):
        """Verify and decode JWT token."""
        try:
            payload = jwt.decode(
                token,
                current_app.config['SECRET_KEY'],
                algorithms=['HS256'],
                issuer='taskflow-api'
            )
            return payload['user_id']
        except jwt.ExpiredSignatureError:
            return None
        except jwt.InvalidTokenError:
            return None

# API Key Authentication
class APIKeyManager:
    """API Key authentication for third-party integrations."""
    
    @staticmethod
    def generate_api_key():
        """Generate a new API key."""
        return secrets.token_urlsafe(32)
    
    @staticmethod
    def verify_api_key(api_key):
        """Verify an API key."""
        # Check against database
        key = APIKey.query.filter_by(key=api_key, active=True).first()
        if key:
            # Update last used
            key.last_used = datetime.utcnow()
            db.session.commit()
            return key.user_id
        return None

# API Key decorator
def api_key_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        api_key = request.headers.get('X-API-Key')
        if not api_key:
            abort(401, "API key required")
        
        user_id = APIKeyManager.verify_api_key(api_key)
        if not user_id:
            abort(401, "Invalid API key")
        
        # Load user
        user = UserService.get_by_id(user_id)
        if not user:
            abort(401, "User not found")
        
        # Set current user
        login_user(user)
        return f(*args, **kwargs)
    return decorated
```

---

## 11. Security Monitoring & Incident Response

### Security Logging

```python
import json
from datetime import datetime
import socket

class SecurityLogger:
    """Comprehensive security logging."""
    
    @staticmethod
    def log_security_event(event_type, data, severity='info'):
        """Log a security event."""
        log_entry = {
            'timestamp': datetime.utcnow().isoformat() + 'Z',
            'event_type': event_type,
            'severity': severity,
            'remote_addr': request.remote_addr,
            'user_agent': request.headers.get('User-Agent'),
            'user_id': current_user.id if current_user.is_authenticated else None,
            'data': data,
            'hostname': socket.gethostname(),
            'request_id': get_request_id()
        }
        
        # Log to different handlers based on severity
        if severity == 'critical':
            app.logger.critical(json.dumps(log_entry))
        elif severity == 'warning':
            app.logger.warning(json.dumps(log_entry))
        else:
            app.logger.info(json.dumps(log_entry))
        
        # Store in database for analysis
        AuditLog.create(**log_entry)
    
    @staticmethod
    def log_auth_attempt(email, success, ip, reason=None):
        """Log authentication attempts."""
        SecurityLogger.log_security_event(
            'auth_attempt',
            {
                'email': email,
                'success': success,
                'reason': reason,
                'ip': ip
            },
            severity='warning' if not success else 'info'
        )
    
    @staticmethod
    def log_suspicious_activity(activity, details):
        """Log suspicious activity for investigation."""
        SecurityLogger.log_security_event(
            'suspicious_activity',
            {
                'activity': activity,
                'details': details
            },
            severity='critical'
        )

# Audit Middleware
@app.before_request
def audit_request():
    """Log all requests for audit purposes."""
    if request.method in ['POST', 'PUT', 'DELETE']:
        SecurityLogger.log_security_event(
            'api_request',
            {
                'method': request.method,
                'path': request.path,
                'body': request.get_json() if request.is_json else None
            }
        )

# Suspicious Activity Detection
class SuspiciousActivityDetector:
    """Detect and respond to suspicious activity."""
    
    @staticmethod
    def detect_brute_force(email):
        """Detect brute force login attempts."""
        # Check login attempts in last 5 minutes
        recent_attempts = AuditLog.query.filter(
            AuditLog.event_type == 'auth_attempt',
            AuditLog.data['email'].astext == email,
            AuditLog.timestamp > datetime.utcnow() - timedelta(minutes=5)
        ).count()
        
        if recent_attempts > 5:
            # Block the account temporarily
            user = UserService.get_by_email(email)
            if user:
                user.is_active = False
                db.session.commit()
                
                SecurityLogger.log_suspicious_activity(
                    'brute_force_detected',
                    {'email': email, 'attempts': recent_attempts}
                )
                
                # Notify admin
                notify_admin(f"Brute force attack detected on {email}")
            
            return True
        return False
    
    @staticmethod
    def detect_unusual_ip(user_id, ip):
        """Detect unusual IP address access."""
        user = UserService.get_by_id(user_id)
        if not user:
            return False
        
        # Check if IP is new
        known_ips = AuditLog.query.filter(
            AuditLog.user_id == user_id,
            AuditLog.remote_addr != ip,
            AuditLog.timestamp > datetime.utcnow() - timedelta(days=30)
        ).count()
        
        if known_ips == 0 and user.previous_ips:
            # New IP detected
            SecurityLogger.log_security_event(
                'new_ip_detected',
                {
                    'user_id': user_id,
                    'ip': ip,
                    'previous_ips': user.previous_ips
                },
                severity='warning'
            )
            
            # Force MFA if available
            session['require_mfa'] = True
            return True
        return False

# Incident Response Functions
def security_incident_response(event):
    """Handle security incidents."""
    # 1. Log the incident
    SecurityLogger.log_security_event(
        'incident_response',
        {'event': event},
        severity='critical'
    )
    
    # 2. Notify security team
    notify_security_team(f"Security incident: {event}")
    
    # 3. Take immediate action
    if 'brute_force' in str(event):
        # Block offending IP
        ip = event.get('ip')
        block_ip(ip)
    
    # 4. Create incident ticket
    create_incident_ticket(event)
    
    # 5. Begin investigation
    gather_forensic_data(event)
```

---

## Summary

This appendix has covered comprehensive security hardening for Flask applications:

1. **Threat Landscape**: Understanding attack vectors and patterns
2. **OWASP Top 10**: Implementation of security controls
3. **Authentication**: Secure password storage, session management, MFA
4. **Input Validation**: Comprehensive validation, sanitization, and encoding
5. **SQL Injection**: Prevention techniques and parameterized queries
6. **XSS Prevention**: Contextual encoding, CSP, and sanitization
7. **CSRF Protection**: Token-based protection and double-submit cookies
8. **Secure Headers**: HSTS, CSP, and other security headers
9. **File Upload**: Validation, sanitization, and secure storage
10. **API Security**: Rate limiting, authentication, and best practices
11. **Monitoring**: Security logging and incident response

**Remember**: Security is not a one-time implementation but an ongoing process. Regular security audits, penetration testing, and staying updated with new vulnerabilities are essential for maintaining a secure application.
