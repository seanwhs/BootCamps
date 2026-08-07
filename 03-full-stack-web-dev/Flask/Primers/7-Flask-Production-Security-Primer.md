# Primer 7: Flask Production Security Primer

Welcome to Primer 7! This foundational primer is designed for beginners who want to understand how to secure their Flask applications for production. Building on the basics from Primers 1-6, you'll learn how to protect your application from common attacks and security vulnerabilities.

---

## Table of Contents

1. [Why Security Matters](#1-why-security-matters)
2. [The Security Mindset](#2-the-security-mindset)
3. [Common Web Vulnerabilities](#3-common-web-vulnerabilities)
4. [Authentication Security](#4-authentication-security)
5. [Data Protection](#5-data-protection)
6. [Security Headers](#6-security-headers)
7. [Input Validation & Sanitization](#7-input-validation--sanitization)
8. [Database Security](#8-database-security)
9. [API Security](#9-api-security)
10. [Production Security Checklist](#10-production-security-checklist)

---

## 1. Why Security Matters

### Real-World Consequences

```python
# The Cost of Insecurity

# 1. Data Breach: User data stolen
# 2. Financial Loss: Fines, lawsuits
# 3. Reputation Damage: Lost trust
# 4. Business Shutdown: Can't recover

# Example: SQL Injection could expose ALL users:
# ❌ Vulnerable code
@app.route('/user/<int:user_id>')
def get_user(user_id):
    query = f"SELECT * FROM users WHERE id = {user_id}"
    result = db.engine.execute(query)
    # If user_id = "1 OR 1=1", returns ALL users!
    return jsonify(result.fetchall())
```

### Security by Design

```python
# Security is not an afterthought

# ❌ Bad: Add security later
def create_app():
    app = Flask(__name__)
    # Add routes, features...
    # Then try to add security
    # Usually fails or is incomplete

# ✅ Good: Security from the start
def create_app():
    app = Flask(__name__)
    
    # Security first
    app.config['SECRET_KEY'] = os.environ.get('SECRET_KEY')
    app.config['SESSION_COOKIE_SECURE'] = True
    app.config['SESSION_COOKIE_HTTPONLY'] = True
    
    # CSRF protection
    csrf = CSRFProtect(app)
    
    # Security headers
    @app.after_request
    def add_security_headers(response):
        response.headers['Strict-Transport-Security'] = 'max-age=31536000'
        return response
    
    # Then add routes
    register_blueprints(app)
    return app
```

### The Security Mindset

```
Security Mindset Principle: TRUST NOTHING

┌─────────────────────────────────────────────────────────────┐
│                    Trust Nothing!                           │
├─────────────────────────────────────────────────────────────┤
│  1. Validate ALL user input                                │
│  2. Validate ALL data from external sources                │
│  3. Don't trust client-side validation                     │
│  4. Don't trust cookies without verification               │
│  5. Don't trust environment variables without validation   │
│  6. Don't trust ANYTHING by default                       │
└─────────────────────────────────────────────────────────────┘
```

---

## 2. The Security Mindset

### Defense in Depth

```
Multiple layers of security:

Layer 1: Network Security (Firewall, HTTPS)
Layer 2: Server Security (OS updates, SSH keys)
Layer 3: Application Security (Your code)
Layer 4: Database Security (Strong passwords, encryption)
Layer 5: User Security (Strong passwords, 2FA)

If one layer fails, others still protect you.
```

### Principle of Least Privilege

```python
# Only give what's needed, nothing more

# ❌ Bad: User has too much access
@app.route('/admin')
@login_required  # Only checks if logged in
def admin_panel():
    # Anyone logged in can access admin!
    return render_template('admin.html')

# ✅ Good: Only admins can access
@app.route('/admin')
@login_required
@admin_required  # Extra check for admin role
def admin_panel():
    return render_template('admin.html')

# ✅ Good: Even more specific
@app.route('/admin/users')
@login_required
@admin_required
@permission_required('manage_users')  # Specific permission
def manage_users():
    return render_template('admin/users.html')
```

### Security Through Obscurity (Don't Rely On It)

```python
# ❌ Bad: Hidden but not secure
# Using /secret-admin instead of /admin
# Attackers will find it through scanning

# ❌ Bad: Secret URL for API
# /api/1234-secret-key-5678-data
# Not secure, can be found in logs

# ✅ Good: Proper authentication
# Always use proper authentication, not hidden URLs
```

---

## 3. Common Web Vulnerabilities

### OWASP Top 10 (Simplified)

```python
# OWASP Top 10 Vulnerabilities (2021)

# 1. Broken Access Control
# ✅ Check: Users can only access what they should

# 2. Cryptographic Failures
# ✅ Check: Use HTTPS, strong encryption

# 3. Injection
# ✅ Check: SQL injection, XSS prevention

# 4. Insecure Design
# ✅ Check: Security by design

# 5. Security Misconfiguration
# ✅ Check: Default passwords, unnecessary services

# 6. Vulnerable Components
# ✅ Check: Update dependencies regularly

# 7. Identification/Authentication Failures
# ✅ Check: Strong passwords, 2FA

# 8. Software/Data Integrity Failures
# ✅ Check: Verify updates, signed commits

# 9. Security Logging Failures
# ✅ Check: Log security events

# 10. Server-Side Request Forgery
# ✅ Check: Validate URLs before fetching
```

### SQL Injection

```python
# ❌ VULNERABLE: String concatenation
@app.route('/user/<int:user_id>')
def vulnerable_user(user_id):
    query = f"SELECT * FROM users WHERE id = {user_id}"
    result = db.engine.execute(query)
    # If user_id = "1; DROP TABLE users;", it's game over!
    return jsonify(result.fetchall())

# ✅ SAFE: Parameterized query
@app.route('/user/<int:user_id>')
def safe_user(user_id):
    query = "SELECT * FROM users WHERE id = :id"
    result = db.engine.execute(query, {'id': user_id})
    return jsonify(result.fetchall())

# ✅ SAFE: SQLAlchemy ORM
@app.route('/user/<int:user_id>')
def safe_user_orm(user_id):
    user = User.query.get(user_id)
    return jsonify(user.to_dict())
```

### Cross-Site Scripting (XSS)

```python
# ❌ VULNERABLE: User input directly in HTML
@app.route('/search')
def vulnerable_search():
    query = request.args.get('q', '')
    # If query = "<script>alert('XSS')</script>"
    # Script runs in browser!
    return f"<h1>Search: {query}</h1>"

# ✅ SAFE: Auto-escaping with Jinja2
@app.route('/search')
def safe_search():
    query = request.args.get('q', '')
    # Jinja2 auto-escapes by default
    return render_template('search.html', query=query)

# ✅ SAFE: Manual escaping
from flask import escape

@app.route('/search')
def safe_manual():
    query = request.args.get('q', '')
    return f"<h1>Search: {escape(query)}</h1>"

# ✅ SAFE: Sanitize HTML
import bleach

@app.route('/comment')
def safe_comment():
    comment = request.args.get('comment', '')
    # Only allow safe HTML tags
    clean = bleach.clean(comment, tags=['p', 'b', 'i'])
    return render_template('comment.html', comment=clean)
```

### Cross-Site Request Forgery (CSRF)

```python
# ❌ VULNERABLE: No CSRF protection
@app.route('/transfer', methods=['POST'])
def transfer_money():
    amount = request.form.get('amount')
    # Attacker can trick user into submitting this
    return "Money transferred!"

# ✅ SAFE: CSRF token required
from flask_wtf.csrf import CSRFProtect

csrf = CSRFProtect(app)

@app.route('/transfer', methods=['POST'])
def transfer_money():
    # CSRF token automatically validated
    amount = request.form.get('amount')
    return "Money transferred!"

# ✅ SAFE: In forms
<!-- Template automatically includes CSRF token -->
<form method="POST">
    {{ form.csrf_token }}
    <input type="text" name="amount">
    <button type="submit">Transfer</button>
</form>

# ✅ SAFE: In AJAX requests
# <meta name="csrf-token" content="{{ csrf_token() }}">
# In JavaScript:
# fetch('/api/transfer', {
#     method: 'POST',
#     headers: {
#         'X-CSRFToken': document.querySelector('meta[name="csrf-token"]').content
#     },
#     body: JSON.stringify({amount: 100})
# })
```

---

## 4. Authentication Security

### Secure Password Storage

```python
from werkzeug.security import generate_password_hash, check_password_hash

class User(db.Model):
    __tablename__ = 'users'
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(50), unique=True)
    password_hash = db.Column(db.String(128), nullable=False)
    
    def set_password(self, password):
        # ❌ BAD: Plain text
        # self.password = password  # NEVER!
        
        # ❌ BAD: MD5 (weak)
        # import hashlib
        # self.password_hash = hashlib.md5(password.encode()).hexdigest()
        
        # ✅ GOOD: Secure hashing with Werkzeug
        self.password_hash = generate_password_hash(password)
    
    def check_password(self, password):
        return check_password_hash(self.password_hash, password)

# Usage
user = User(username='john')
user.set_password('MySecurePassword123!')
db.session.add(user)
db.session.commit()

# Verification
user = User.query.filter_by(username='john').first()
if user.check_password(input_password):
    login_user(user)
```

### Password Policy

```python
def validate_password(password):
    """Enforce strong password policy."""
    errors = []
    
    # Length check
    if len(password) < 8:
        errors.append("Password must be at least 8 characters")
    
    # Uppercase check
    if not any(c.isupper() for c in password):
        errors.append("Password must contain uppercase letters")
    
    # Lowercase check
    if not any(c.islower() for c in password):
        errors.append("Password must contain lowercase letters")
    
    # Digit check
    if not any(c.isdigit() for c in password):
        errors.append("Password must contain numbers")
    
    # Special character check
    special_chars = '!@#$%^&*()_+-=[]{}|;:,.<>?'
    if not any(c in special_chars for c in password):
        errors.append("Password must contain special characters")
    
    # Common password check
    common_passwords = [
        'password123', 'admin123', 'qwerty123',
        'letmein', 'welcome123', '12345678'
    ]
    if password.lower() in common_passwords:
        errors.append("Password is too common")
    
    # Dictionary word check (basic)
    if password.lower() in ['password', 'admin', 'user', 'guest']:
        errors.append("Password is too common")
    
    return errors

# Usage in registration
@app.route('/register', methods=['POST'])
def register():
    password = request.form.get('password')
    errors = validate_password(password)
    
    if errors:
        flash('; '.join(errors), 'danger')
        return render_template('register.html')
    
    # Password is valid, create user...
```

### Login Security

```python
from flask_limiter import Limiter
from flask_limiter.util import get_remote_address

limiter = Limiter(app, key_func=get_remote_address)

@app.route('/login', methods=['POST'])
@limiter.limit("5 per minute", error_message="Too many login attempts")
def login():
    email = request.form.get('email')
    password = request.form.get('password')
    
    user = User.query.filter_by(email=email).first()
    
    if user and user.check_password(password):
        # ✅ GOOD: Reset failed attempts
        user.failed_login_attempts = 0
        db.session.commit()
        
        login_user(user)
        flash('Login successful!', 'success')
        return redirect(url_for('dashboard'))
    
    # ✅ GOOD: Track failed attempts
    if user:
        user.failed_login_attempts += 1
        db.session.commit()
        
        # Lock account after 5 failures
        if user.failed_login_attempts >= 5:
            user.is_locked = True
            db.session.commit()
            flash('Account locked. Contact support.', 'danger')
            return render_template('login.html')
    
    flash('Invalid email or password', 'danger')
    return render_template('login.html')

# Unlock account with admin
@app.route('/admin/unlock/<int:user_id>', methods=['POST'])
@admin_required
def unlock_account(user_id):
    user = User.query.get(user_id)
    if user:
        user.is_locked = False
        user.failed_login_attempts = 0
        db.session.commit()
        flash(f'Account {user.username} unlocked', 'success')
    return redirect(url_for('admin.users'))
```

### Session Security

```python
# Session configuration
app.config.update({
    # Strong secret key
    'SECRET_KEY': os.environ.get('SECRET_KEY'),
    
    # Session cookies
    'SESSION_COOKIE_HTTPONLY': True,   # No JavaScript access
    'SESSION_COOKIE_SECURE': True,     # HTTPS only
    'SESSION_COOKIE_SAMESITE': 'Strict', # CSRF protection
    
    # Session duration
    'PERMANENT_SESSION_LIFETIME': timedelta(hours=1),
    
    # Remember me
    'REMEMBER_COOKIE_HTTPONLY': True,
    'REMEMBER_COOKIE_SECURE': True,
    'REMEMBER_COOKIE_SAMESITE': 'Strict',
    'REMEMBER_COOKIE_DURATION': timedelta(days=30),
})

# Session timeout
@app.before_request
def check_session_timeout():
    if current_user.is_authenticated:
        # Check if session has been active too long
        if 'last_activity' in session:
            inactive_time = datetime.utcnow() - session['last_activity']
            if inactive_time > timedelta(minutes=15):
                logout_user()
                flash('Session expired due to inactivity', 'warning')
                return redirect(url_for('login'))
        
        session['last_activity'] = datetime.utcnow()
```

---

## 5. Data Protection

### Encryption at Rest

```python
from cryptography.fernet import Fernet

# Generate key (store in environment variable)
# key = Fernet.generate_key()
# Store in: ENCRYPTION_KEY

class SecureDataMixin:
    """Mixin for encrypted fields."""
    
    def __init__(self):
        self.cipher = Fernet(os.environ.get('ENCRYPTION_KEY').encode())
    
    def encrypt(self, data):
        if data is None:
            return None
        return self.cipher.encrypt(data.encode()).decode()
    
    def decrypt(self, encrypted_data):
        if encrypted_data is None:
            return None
        return self.cipher.decrypt(encrypted_data.encode()).decode()

# Use in models
class User(db.Model, SecureDataMixin):
    __tablename__ = 'users'
    
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(50), unique=True)
    email = db.Column(db.String(120), unique=True)
    email_encrypted = db.Column(db.Text)  # Encrypted email
    
    def set_email(self, email):
        self.email_encrypted = self.encrypt(email)
    
    def get_email(self):
        return self.decrypt(self.email_encrypted)
    
    # Always store plain email in a separate table for searching
    
# Usage
user = User(username='john')
user.set_email('john@example.com')
db.session.add(user)
db.session.commit()

# Retrieve
user = User.query.first()
email = user.get_email()  # john@example.com
```

### Database Encryption (PostgreSQL)

```sql
-- PostgreSQL encryption extensions
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Encrypt data at rest
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50),
    email BYTEA,  -- Encrypted
    created_at TIMESTAMP
);

-- Insert with encryption
INSERT INTO users (username, email) 
VALUES ('john', pgp_sym_encrypt('john@example.com', 'encryption-key'));

-- Select with decryption
SELECT 
    username, 
    pgp_sym_decrypt(email, 'encryption-key') as email
FROM users
WHERE username = 'john';

-- Full-disk encryption (AWS EBS, LUKS)
```

### HTTPS Configuration

```python
# Flask HTTPS (development only)
if __name__ == '__main__':
    # Generate cert: openssl req -x509 -newkey rsa:4096 -nodes -out cert.pem -keyout key.pem -days 365
    app.run(ssl_context=('cert.pem', 'key.pem'))

# Production HTTPS with Nginx
# server {
#     listen 443 ssl http2;
#     server_name your-domain.com;
#     
#     ssl_certificate /etc/ssl/certs/your-domain.crt;
#     ssl_certificate_key /etc/ssl/private/your-domain.key;
#     
#     # Strong SSL config
#     ssl_protocols TLSv1.2 TLSv1.3;
#     ssl_ciphers 'ECDHE-ECDSA-AES256-GCM-SHA384:...';
#     ssl_prefer_server_ciphers off;
#     
#     # HSTS
#     add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
# }

# Redirect HTTP to HTTPS
@app.before_request
def redirect_https():
    if not request.is_secure and app.config.get('ENV') == 'production':
        url = request.url.replace('http://', 'https://', 1)
        return redirect(url, code=301)
```

---

## 6. Security Headers

### Complete Security Headers

```python
@app.after_request
def add_security_headers(response):
    """Add comprehensive security headers."""
    
    # HSTS - Force HTTPS
    if app.config.get('ENV') == 'production':
        response.headers['Strict-Transport-Security'] = \
            'max-age=31536000; includeSubDomains; preload'
    
    # X-Frame-Options - Prevent clickjacking
    response.headers['X-Frame-Options'] = 'SAMEORIGIN'
    
    # X-Content-Type-Options - Prevent MIME sniffing
    response.headers['X-Content-Type-Options'] = 'nosniff'
    
    # X-XSS-Protection - Prevent XSS (legacy)
    response.headers['X-XSS-Protection'] = '1; mode=block'
    
    # Referrer-Policy - Control referrer info
    response.headers['Referrer-Policy'] = 'strict-origin-when-cross-origin'
    
    # Permissions-Policy - Control browser features
    response.headers['Permissions-Policy'] = \
        'geolocation=(), microphone=(), camera=(), payment=()'
    
    # Content-Security-Policy
    csp = [
        "default-src 'self'",
        "script-src 'self' 'unsafe-inline' https://cdn.jsdelivr.net",
        "style-src 'self' 'unsafe-inline' https://cdn.jsdelivr.net",
        "img-src 'self' data: https:",
        "font-src 'self' https://cdn.jsdelivr.net",
        "connect-src 'self'",
        "frame-ancestors 'none'",
        "form-action 'self'",
    ]
    response.headers['Content-Security-Policy'] = '; '.join(csp)
    
    # Remove server identification
    response.headers.pop('Server', None)
    response.headers.pop('X-Powered-By', None)
    
    return response
```

### Content Security Policy (CSP) Details

```python
# CSP protects against XSS and data injection

# ❌ BAD: No CSP (vulnerable)
# No Content-Security-Policy header

# ✅ GOOD: Restrictive CSP
# Content-Security-Policy: default-src 'self'; script-src 'self'

# ✅ GOOD: With external resources
# Content-Security-Policy: default-src 'self'; 
#     script-src 'self' https://cdn.jsdelivr.net; 
#     style-src 'self' https://cdn.jsdelivr.net; 
#     img-src 'self' data: https:

# ✅ GOOD: With nonce (for inline scripts)
import secrets

@app.before_request
def generate_nonce():
    g.csp_nonce = secrets.token_urlsafe(32)

# In template:
# <script nonce="{{ g.csp_nonce }}">
#     // Safe inline script
# </script>

# In header:
# Content-Security-Policy: script-src 'self' 'nonce-{{ g.csp_nonce }}'

# CSP violation reporting
@app.route('/csp-report', methods=['POST'])
def csp_report():
    report = request.json
    app.logger.warning(f"CSP violation: {report}")
    return '', 204
```

---

## 7. Input Validation & Sanitization

### Comprehensive Input Validation

```python
from marshmallow import Schema, fields, validate, ValidationError

class UserRegistrationSchema(Schema):
    """Validate user registration input."""
    username = fields.Str(
        required=True,
        validate=[
            validate.Length(min=3, max=50),
            validate.Regexp(
                r'^[a-zA-Z0-9_]+$',
                error="Username can only contain letters, numbers, and underscores"
            )
        ]
    )
    email = fields.Email(required=True)
    password = fields.Str(
        required=True,
        validate=validate.Length(min=8)
    )

class TaskSchema(Schema):
    """Validate task input."""
    title = fields.Str(
        required=True,
        validate=[
            validate.Length(min=1, max=200),
            validate.Regexp(
                r'^[a-zA-Z0-9\s\-_,.!?]+$',
                error="Task title contains invalid characters"
            )
        ]
    )
    description = fields.Str(
        allow_none=True,
        validate=validate.Length(max=2000)
    )
    priority = fields.Str(
        validate=validate.OneOf(['low', 'medium', 'high', 'urgent'])
    )
    due_date = fields.DateTime(allow_none=True)

# Usage
@app.route('/api/tasks', methods=['POST'])
def create_task():
    schema = TaskSchema()
    
    try:
        data = schema.load(request.get_json())
    except ValidationError as err:
        return jsonify({'errors': err.messages}), 400
    
    # Data is validated and safe
    task = Task(**data)
    db.session.add(task)
    db.session.commit()
    return jsonify(task.to_dict()), 201
```

### Input Sanitization

```python
import bleach
import html

def sanitize_html_content(html_content):
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
    
    return bleach.clean(
        html_content,
        tags=allowed_tags,
        attributes=allowed_attrs,
        strip=True
    )

def sanitize_user_input(data):
    """Sanitize all user input."""
    if isinstance(data, str):
        # Remove potentially dangerous characters
        data = html.escape(data)
        # Remove null bytes
        data = data.replace('\x00', '')
        return data
    elif isinstance(data, dict):
        return {k: sanitize_user_input(v) for k, v in data.items()}
    elif isinstance(data, list):
        return [sanitize_user_input(item) for item in data]
    else:
        return data

@app.route('/comment', methods=['POST'])
def add_comment():
    content = request.form.get('comment')
    
    # Sanitize
    content = sanitize_html_content(content)
    
    # Now safe to render
    comment = Comment(text=content)
    db.session.add(comment)
    db.session.commit()
    
    return render_template('comment.html', comment=content)
```

### File Upload Security

```python
import os
import magic
from werkzeug.utils import secure_filename

class SecureFileUpload:
    """Secure file upload handling."""
    
    ALLOWED_EXTENSIONS = {
        'jpg', 'jpeg', 'png', 'gif', 'webp',
        'pdf', 'doc', 'docx', 'xls', 'xlsx', 'txt'
    }
    
    ALLOWED_MIME_TYPES = {
        'image/jpeg', 'image/png', 'image/gif', 'image/webp',
        'application/pdf', 'application/msword',
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
        'text/plain'
    }
    
    MAX_FILE_SIZE = 5 * 1024 * 1024  # 5MB
    
    @staticmethod
    def validate_file(file):
        """Validate uploaded file."""
        # Check file exists
        if not file or not file.filename:
            return False, "No file selected"
        
        # Check file size
        file.seek(0, os.SEEK_END)
        size = file.tell()
        file.seek(0)
        
        if size > SecureFileUpload.MAX_FILE_SIZE:
            return False, f"File too large (max {SecureFileUpload.MAX_FILE_SIZE // (1024*1024)}MB)"
        
        # Secure filename
        filename = secure_filename(file.filename)
        if not filename:
            return False, "Invalid filename"
        
        # Check extension
        extension = filename.rsplit('.', 1)[1].lower() if '.' in filename else ''
        if extension not in SecureFileUpload.ALLOWED_EXTENSIONS:
            return False, "File type not allowed"
        
        # Check MIME type
        file_content = file.read(1024)
        file.seek(0)
        mime_type = magic.from_buffer(file_content, mime=True)
        
        if mime_type not in SecureFileUpload.ALLOWED_MIME_TYPES:
            return False, "Invalid file content type"
        
        # Image validation
        if mime_type.startswith('image/'):
            try:
                from PIL import Image
                img = Image.open(file)
                img.verify()
                file.seek(0)
            except Exception:
                return False, "Invalid image file"
        
        # Virus scan (if available)
        # if not SecureFileUpload.scan_virus(file):
        #     return False, "File contains virus"
        
        return True, "File valid"
    
    @staticmethod
    def save_file(file, upload_dir):
        """Save uploaded file securely."""
        valid, message = SecureFileUpload.validate_file(file)
        if not valid:
            raise ValueError(message)
        
        # Generate safe filename
        filename = secure_filename(file.filename)
        name, ext = filename.rsplit('.', 1)
        new_filename = f"{secrets.token_hex(8)}_{name}.{ext}"
        
        # Save file
        path = os.path.join(upload_dir, new_filename)
        file.save(path)
        
        # Set restricted permissions
        os.chmod(path, 0o600)  # Read/write for owner only
        
        return new_filename, path

# Usage
@app.route('/upload', methods=['POST'])
@login_required
def upload_file():
    file = request.files.get('file')
    
    try:
        filename, path = SecureFileUpload.save_file(file, app.config['UPLOAD_FOLDER'])
        flash(f'File {filename} uploaded successfully!', 'success')
    except ValueError as e:
        flash(str(e), 'danger')
    
    return redirect(url_for('dashboard'))
```

---

## 8. Database Security

### Secure Database Configuration

```python
# PostgreSQL security configuration

# 1. Use strong passwords
# CREATE USER taskflow WITH PASSWORD 'C0mpl3xP@ssw0rd!';

# 2. Limit connections
# ALTER SYSTEM SET max_connections = 100;

# 3. Use SSL
# ALTER SYSTEM SET ssl = on;

# 4. Restrict access
# ALTER SYSTEM SET listen_addresses = 'localhost';

# 5. Regular backups
# pg_dump -U taskflow -d taskflow > backup.sql

# 6. Connection pooling
app.config['SQLALCHEMY_ENGINE_OPTIONS'] = {
    'pool_size': 10,
    'pool_recycle': 3600,
    'pool_pre_ping': True,
    'max_overflow': 20,
}
```

### SQL Injection Prevention

```python
# ✅ ALWAYS use parameterized queries

# ❌ BAD: String concatenation
user_id = request.args.get('id')
query = f"SELECT * FROM users WHERE id = {user_id}"
result = db.engine.execute(query)

# ✅ GOOD: Parameterized (SQLAlchemy Core)
user_id = request.args.get('id')
query = "SELECT * FROM users WHERE id = :id"
result = db.engine.execute(query, {'id': user_id})

# ✅ GOOD: ORM (SQLAlchemy)
user_id = request.args.get('id')
user = User.query.get(user_id)

# ✅ GOOD: With LIKE (use escaping)
from sqlalchemy import text
search = request.args.get('search')
query = text("SELECT * FROM users WHERE username LIKE :search")
result = db.engine.execute(query, {'search': f'%{search}%'})

# ❌ BAD: Raw SQL in ORM filters
# User.query.filter_by(username=f"'{search}'")  # vulnerable
# User.query.filter(User.username == search)    # safe
```

### Database Backup & Recovery

```python
import subprocess
from datetime import datetime
import boto3

class DatabaseBackup:
    """Automated database backup."""
    
    def __init__(self):
        self.backup_dir = '/var/backups/taskflow'
        self.s3_client = boto3.client('s3')
        self.bucket_name = 'taskflow-backups'
    
    def create_backup(self):
        """Create database backup."""
        timestamp = datetime.utcnow().strftime('%Y%m%d_%H%M%S')
        backup_file = f"{self.backup_dir}/taskflow_{timestamp}.sql.gz"
        
        # Create backup
        subprocess.run([
            'pg_dump',
            '-h', 'localhost',
            '-U', 'taskflow',
            '-d', 'taskflow',
            '-Fc',  # Custom format
            '-f', backup_file
        ], check=True)
        
        # Upload to cloud
        self.upload_to_cloud(backup_file)
        
        # Clean old backups
        self.clean_old_backups()
        
        return backup_file
    
    def upload_to_cloud(self, backup_file):
        """Upload backup to S3."""
        try:
            self.s3_client.upload_file(
                backup_file,
                self.bucket_name,
                f"backups/{os.path.basename(backup_file)}"
            )
        except Exception as e:
            app.logger.error(f"Failed to upload backup: {e}")
    
    def clean_old_backups(self):
        """Remove backups older than 30 days."""
        import time
        cutoff = time.time() - 30 * 86400
        
        for file in os.listdir(self.backup_dir):
            file_path = os.path.join(self.backup_dir, file)
            if os.path.getmtime(file_path) < cutoff:
                os.remove(file_path)
    
    def restore_backup(self, backup_file):
        """Restore from backup."""
        subprocess.run([
            'pg_restore',
            '-h', 'localhost',
            '-U', 'taskflow',
            '-d', 'taskflow',
            backup_file
        ], check=True)

# Schedule backups
import schedule

def schedule_backups():
    backup = DatabaseBackup()
    
    # Daily full backup at 2 AM
    schedule.every().day.at("02:00").do(backup.create_backup)
    
    # Hourly backups for frequent data
    schedule.every().hour.at(":00").do(backup.create_backup)
    
    while True:
        schedule.run_pending()
        time.sleep(60)
```

---

## 9. API Security

### API Authentication & Authorization

```python
from functools import wraps
import jwt
from flask import request, jsonify, g

# JWT Setup
SECRET_KEY = os.environ.get('JWT_SECRET_KEY')

def generate_token(user_id, expires_in=3600):
    """Generate JWT token."""
    payload = {
        'user_id': user_id,
        'exp': datetime.utcnow() + timedelta(seconds=expires_in),
        'iat': datetime.utcnow()
    }
    return jwt.encode(payload, SECRET_KEY, algorithm='HS256')

def verify_token(token):
    """Verify JWT token."""
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=['HS256'])
        return payload['user_id']
    except jwt.ExpiredSignatureError:
        return None
    except jwt.InvalidTokenError:
        return None

def token_required(f):
    """Decorator for token authentication."""
    @wraps(f)
    def decorated(*args, **kwargs):
        auth_header = request.headers.get('Authorization')
        
        if not auth_header or not auth_header.startswith('Bearer '):
            return jsonify({'error': 'Token required'}), 401
        
        token = auth_header[7:]  # Remove 'Bearer '
        user_id = verify_token(token)
        
        if not user_id:
            return jsonify({'error': 'Invalid or expired token'}), 401
        
        g.user_id = user_id
        return f(*args, **kwargs)
    return decorated

# API Rate Limiting
from flask_limiter import Limiter
from flask_limiter.util import get_remote_address

limiter = Limiter(app, key_func=get_remote_address)

@app.route('/api/tasks', methods=['GET'])
@token_required
@limiter.limit("100 per minute")
def api_get_tasks():
    """Get tasks with rate limiting."""
    tasks = Task.query.filter_by(user_id=g.user_id).all()
    return jsonify([task.to_dict() for task in tasks])

@app.route('/api/tasks', methods=['POST'])
@token_required
@limiter.limit("30 per minute")
def api_create_task():
    """Create task with stricter rate limit."""
    data = request.get_json()
    task = Task(title=data['title'], user_id=g.user_id)
    db.session.add(task)
    db.session.commit()
    return jsonify(task.to_dict()), 201
```

### API Input Validation

```python
from marshmallow import Schema, fields, validate, ValidationError

class APITaskSchema(Schema):
    title = fields.Str(
        required=True,
        validate=validate.Length(min=1, max=200)
    )
    description = fields.Str(allow_none=True)
    priority = fields.Str(
        validate=validate.OneOf(['low', 'medium', 'high', 'urgent'])
    )

def validate_api_request(schema_class):
    """Decorator to validate API request."""
    def decorator(f):
        @wraps(f)
        def decorated(*args, **kwargs):
            schema = schema_class()
            try:
                data = schema.load(request.get_json())
                g.validated_data = data
                return f(*args, **kwargs)
            except ValidationError as err:
                return jsonify({'errors': err.messages}), 400
            except Exception as e:
                return jsonify({'error': str(e)}), 400
        return decorated
    return decorator

@app.route('/api/tasks', methods=['POST'])
@token_required
@validate_api_request(APITaskSchema)
def api_create_task():
    data = g.validated_data
    task = Task(**data, user_id=g.user_id)
    db.session.add(task)
    db.session.commit()
    return jsonify(task.to_dict()), 201
```

### API Response Security

```python
def secure_api_response(data):
    """Secure API response."""
    # Remove sensitive data
    if isinstance(data, dict):
        # Remove password_hash, password, etc.
        data = {k: v for k, v in data.items() 
                if k not in ['password_hash', 'password', 'api_key', 'secret']}
    elif isinstance(data, list):
        data = [secure_api_response(item) for item in data]
    elif hasattr(data, 'to_dict'):
        data = data.to_dict()
        data.pop('password_hash', None)
    
    return data

@app.route('/api/users')
@token_required
def api_get_users():
    users = User.query.all()
    return jsonify([secure_api_response(user.to_dict()) for user in users])

# CORS Configuration
from flask_cors import CORS

# ❌ BAD: Allow everything
# CORS(app)  # Allows all origins!

# ✅ GOOD: Restrict to specific origins
CORS(app, origins=['https://myapp.com', 'https://api.myapp.com'])

# ✅ GOOD: Per-route CORS
@app.route('/api/public')
@cross_origin(origin='*')
def public_api():
    return jsonify({'public': 'data'})

@app.route('/api/private')
@token_required
@cross_origin(origin='https://myapp.com')
def private_api():
    return jsonify({'private': 'data'})
```

---

## 10. Production Security Checklist

### Deployment Security Checklist

```yaml
# Before Going Live

# 1. Environment Configuration
- [ ] SECRET_KEY is strong (32+ random characters)
- [ ] SECRET_KEY is not in version control
- [ ] DEBUG is False
- [ ] TESTING is False
- [ ] FLASK_ENV is 'production'

# 2. HTTPS Configuration
- [ ] SSL/TLS certificate installed
- [ ] HTTP redirects to HTTPS
- [ ] HSTS headers enabled
- [ ] Secure cookie flags set

# 3. Authentication & Authorization
- [ ] Password policy enforced
- [ ] Rate limiting on login
- [ ] Session timeout configured
- [ ] Role-based access control
- [ ] All routes protected properly

# 4. Data Protection
- [ ] Database passwords strong
- [ ] Database connections encrypted
- [ ] Sensitive data encrypted at rest
- [ ] Regular backups configured

# 5. Input Validation
- [ ] All user input validated
- [ ] SQL injection prevention
- [ ] XSS prevention
- [ ] CSRF protection
- [ ] File uploads validated

# 6. Security Headers
- [ ] HSTS header set
- [ ] X-Frame-Options set
- [ ] X-Content-Type-Options set
- [ ] X-XSS-Protection set
- [ ] Content-Security-Policy set
- [ ] Referrer-Policy set

# 7. Monitoring & Logging
- [ ] Security events logged
- [ ] Error tracking configured
- [ ] Application performance monitoring
- [ ] Alerting configured

# 8. Dependencies
- [ ] All dependencies updated
- [ ] Known vulnerabilities checked
- [ ] Outdated packages removed

# 9. Infrastructure
- [ ] Firewall configured
- [ ] SSH keys used (not passwords)
- [ ] Services run as non-root
- [ ] Regular security updates

# 10. Disaster Recovery
- [ ] Backup strategy in place
- [ ] Restore procedure tested
- [ ] Incident response plan
- [ ] Rollback strategy
```

### Security Audit Script

```python
# security_audit.py - Check your application's security

import os
import sys
from flask import current_app

def run_security_audit(app):
    """Run security audit on application."""
    issues = []
    
    # 1. Check SECRET_KEY
    if app.config.get('SECRET_KEY') == 'dev-secret-key-change-in-production':
        issues.append("❌ SECRET_KEY is the default value!")
    elif len(app.config.get('SECRET_KEY', '')) < 32:
        issues.append("❌ SECRET_KEY is too short (minimum 32 chars)")
    
    # 2. Check DEBUG
    if app.config.get('DEBUG', True):
        issues.append("❌ DEBUG is enabled! Disable in production")
    
    # 3. Check session security
    if not app.config.get('SESSION_COOKIE_SECURE', False):
        issues.append("⚠️ SESSION_COOKIE_SECURE is False (should be True in production)")
    
    if not app.config.get('SESSION_COOKIE_HTTPONLY', False):
        issues.append("⚠️ SESSION_COOKIE_HTTPONLY is False (should be True)")
    
    # 4. Check database URL
    if 'sqlite://' in app.config.get('SQLALCHEMY_DATABASE_URI', ''):
        issues.append("⚠️ Using SQLite in production (recommend PostgreSQL)")
    
    # 5. Check for missing security headers
    # This is more complex, would need to make a test request
    
    # 6. Check dependencies
    import subprocess
    result = subprocess.run(['safety', 'check', '--json'], 
                          capture_output=True, text=True)
    if result.returncode != 0:
        issues.append("❌ Vulnerable dependencies found!")
    
    # Output results
    print("\n" + "="*60)
    print("Security Audit Results")
    print("="*60)
    
    if issues:
        for issue in issues:
            print(issue)
        print("\n⚠️ " + str(len(issues)) + " issues found!")
    else:
        print("✅ No major security issues found!")
    
    return issues

# Run audit
if __name__ == '__main__':
    from app import create_app
    app = create_app()
    with app.app_context():
        run_security_audit(app)
```

---

## Summary

This primer has introduced you to securing Flask applications:

1. **Security Matters**: Protect users and data
2. **Security Mindset**: Trust nothing, defense in depth
3. **Common Vulnerabilities**: SQL injection, XSS, CSRF
4. **Authentication Security**: Strong passwords, secure sessions
5. **Data Protection**: Encryption, HTTPS
6. **Security Headers**: HSTS, CSP, etc.
7. **Input Validation**: Validate and sanitize all input
8. **Database Security**: Secure config, backups
9. **API Security**: Authentication, rate limiting
10. **Production Checklist**: Secure deployment

### Security Quick Reference

```python
# 1. Secure config
app.config.update({
    'SECRET_KEY': os.environ.get('SECRET_KEY'),
    'DEBUG': False,
    'SESSION_COOKIE_SECURE': True,
    'SESSION_COOKIE_HTTPONLY': True,
})

# 2. Password hashing
user.set_password(password)  # Never store plain text

# 3. Input validation
data = schema.load(request.get_json())

# 4. CSRF protection
csrf = CSRFProtect(app)

# 5. Security headers
@after_request
def add_headers(response):
    response.headers['Strict-Transport-Security'] = 'max-age=31536000'
    return response

# 6. SQL injection prevention
# Always use parameterized queries

# 7. XSS prevention
# Jinja2 auto-escapes by default

# 8. Session security
app.config['SESSION_COOKIE_SECURE'] = True
app.config['SESSION_COOKIE_HTTPONLY'] = True

# 9. Rate limiting
@limiter.limit("5 per minute")

# 10. Regular updates
pip list --outdated
safety check
```

**Next Steps**:
- Run a security audit on your application
- Implement missing security measures
- Set up monitoring and alerting
- Create incident response plan
- Regularly update dependencies
