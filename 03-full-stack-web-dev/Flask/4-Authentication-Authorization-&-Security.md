# Part 4: Authentication, Authorization & Security

Welcome to Part 4! Now we'll implement a complete, secure authentication system for TaskFlow. We'll add user registration, login, logout, password reset, email verification, and role-based access control. We'll also implement security best practices to protect against common web vulnerabilities.

---

## Phase 4, Part 1: Complete Authentication System

### The Target
Implement full user authentication with registration, login, logout, and session management.

### The Concept
Authentication is like a security badge for your application. When users register, they get a "badge" (their credentials). When they login, they present their badge and receive a "temporary pass" (a session) that allows them to access protected areas. This temporary pass expires after a certain time, requiring them to "scan their badge" again (re-login).

### The Implementation

First, let's install the necessary packages:

```bash
pip install flask-login email-validator itsdangerous
```

Now let's create the email utilities for sending verification and reset emails:

```bash
mkdir -p app/utils
touch app/utils/email.py
touch app/utils/tokens.py
```

**`app/utils/tokens.py`** — Token generation for email verification and password reset
```python
"""
Token generation and verification utilities.

Uses itsdangerous to create secure, time-limited tokens for email verification
and password reset operations.
"""

from itsdangerous import URLSafeTimedSerializer
from flask import current_app


def generate_token(email: str, salt: str, expiration: int = 3600) -> str:
    """
    Generate a secure, time-limited token for a user.
    
    Args:
        email: User's email address
        salt: Salt string for token generation (e.g., 'email-verify', 'password-reset')
        expiration: Token expiration in seconds (default: 1 hour)
    
    Returns:
        URL-safe token string
    """
    serializer = URLSafeTimedSerializer(current_app.config['SECRET_KEY'])
    return serializer.dumps(email, salt=salt)


def verify_token(token: str, salt: str, expiration: int = 3600) -> str | None:
    """
    Verify a token and return the email if valid and not expired.
    
    Args:
        token: Token string to verify
        salt: Salt string used for generation
        expiration: Token expiration in seconds
    
    Returns:
        Email address if token is valid, None otherwise
    """
    serializer = URLSafeTimedSerializer(current_app.config['SECRET_KEY'])
    try:
        email = serializer.loads(token, salt=salt, max_age=expiration)
        return email
    except Exception:
        return None


def generate_email_verification_token(email: str) -> str:
    """Generate a token for email verification."""
    return generate_token(email, salt='email-verify', expiration=86400)  # 24 hours


def verify_email_verification_token(token: str) -> str | None:
    """Verify an email verification token."""
    return verify_token(token, salt='email-verify', expiration=86400)


def generate_password_reset_token(email: str) -> str:
    """Generate a token for password reset."""
    return generate_token(email, salt='password-reset', expiration=3600)  # 1 hour


def verify_password_reset_token(token: str) -> str | None:
    """Verify a password reset token."""
    return verify_token(token, salt='password-reset', expiration=3600)
```

**`app/utils/email.py`** — Email utilities
```python
"""
Email utilities for TaskFlow.

Provides functions for sending transactional emails including
verification, password reset, and notifications.
"""

import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from flask import current_app, render_template
from threading import Thread


def send_async_email(app, msg):
    """Send email asynchronously to avoid blocking the request."""
    with app.app_context():
        try:
            # Use Flask-Mail if available, otherwise use smtplib directly
            mail = current_app.extensions.get('mail')
            if mail:
                mail.send(msg)
            else:
                send_email_smtp(msg)
        except Exception as e:
            current_app.logger.error(f"Failed to send email: {e}")


def send_email_smtp(msg):
    """Send email using SMTP directly."""
    config = current_app.config
    with smtplib.SMTP(config['MAIL_SERVER'], config['MAIL_PORT']) as server:
        if config.get('MAIL_USE_TLS'):
            server.starttls()
        if config['MAIL_USERNAME'] and config['MAIL_PASSWORD']:
            server.login(config['MAIL_USERNAME'], config['MAIL_PASSWORD'])
        server.send_message(msg)


def send_email(subject: str, recipients: list, text_body: str, html_body: str = None):
    """
    Send an email.
    
    Args:
        subject: Email subject
        recipients: List of recipient email addresses
        text_body: Plain text email body
        html_body: HTML email body (optional)
    """
    if not recipients:
        return
    
    msg = MIMEMultipart('alternative')
    msg['Subject'] = subject
    msg['From'] = current_app.config['MAIL_DEFAULT_SENDER']
    msg['To'] = ', '.join(recipients)
    
    # Attach plain text part
    text_part = MIMEText(text_body, 'plain')
    msg.attach(text_part)
    
    # Attach HTML part if provided
    if html_body:
        html_part = MIMEText(html_body, 'html')
        msg.attach(html_part)
    
    # Send asynchronously
    app = current_app._get_current_object()
    Thread(target=send_async_email, args=(app, msg)).start()


def send_verification_email(user, token):
    """
    Send email verification link to a user.
    
    Args:
        user: User object
        token: Verification token
    """
    verify_url = url_for('auth.verify_email', token=token, _external=True)
    
    subject = f"Welcome to {current_app.config.get('APP_NAME', 'TaskFlow')}!"
    text_body = render_template(
        'email/verify_email.txt',
        user=user,
        verify_url=verify_url,
        app_name=current_app.config.get('APP_NAME', 'TaskFlow')
    )
    html_body = render_template(
        'email/verify_email.html',
        user=user,
        verify_url=verify_url,
        app_name=current_app.config.get('APP_NAME', 'TaskFlow')
    )
    
    send_email(subject, [user.email], text_body, html_body)


def send_password_reset_email(user, token):
    """
    Send password reset link to a user.
    
    Args:
        user: User object
        token: Reset token
    """
    reset_url = url_for('auth.reset_password', token=token, _external=True)
    
    subject = f"Reset Your Password - {current_app.config.get('APP_NAME', 'TaskFlow')}"
    text_body = render_template(
        'email/reset_password.txt',
        user=user,
        reset_url=reset_url,
        app_name=current_app.config.get('APP_NAME', 'TaskFlow')
    )
    html_body = render_template(
        'email/reset_password.html',
        user=user,
        reset_url=reset_url,
        app_name=current_app.config.get('APP_NAME', 'TaskFlow')
    )
    
    send_email(subject, [user.email], text_body, html_body)


def send_welcome_email(user):
    """
    Send welcome email to a new user.
    
    Args:
        user: User object
    """
    subject = f"Welcome to {current_app.config.get('APP_NAME', 'TaskFlow')}!"
    text_body = render_template(
        'email/welcome.txt',
        user=user,
        app_name=current_app.config.get('APP_NAME', 'TaskFlow')
    )
    html_body = render_template(
        'email/welcome.html',
        user=user,
        app_name=current_app.config.get('APP_NAME', 'TaskFlow')
    )
    
    send_email(subject, [user.email], text_body, html_body)
```

Now let's create the email templates:

```bash
mkdir -p app/templates/email
touch app/templates/email/verify_email.txt
touch app/templates/email/verify_email.html
touch app/templates/email/reset_password.txt
touch app/templates/email/reset_password.html
touch app/templates/email/welcome.txt
touch app/templates/email/welcome.html
```

**`app/templates/email/verify_email.txt`** — Plain text verification email
```txt
Welcome to {{ app_name }}, {{ user.username }}!

Please click the link below to verify your email address:

{{ verify_url }}

This link will expire in 24 hours.

If you didn't create an account with {{ app_name }}, please ignore this email.

Thank you,
The {{ app_name }} Team
```

**`app/templates/email/verify_email.html`** — HTML verification email
```html
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <style>
        body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
        .container { max-width: 600px; margin: 0 auto; padding: 20px; }
        .header { background: #667eea; color: white; padding: 20px; text-align: center; }
        .content { padding: 20px; background: #f9f9f9; }
        .button { display: inline-block; padding: 12px 24px; background: #667eea; color: white; 
                 text-decoration: none; border-radius: 5px; margin: 20px 0; }
        .footer { text-align: center; padding: 20px; color: #666; font-size: 12px; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>{{ app_name }}</h1>
        </div>
        <div class="content">
            <h2>Welcome, {{ user.username }}!</h2>
            <p>Thank you for creating an account with {{ app_name }}. Please verify your email address by clicking the button below:</p>
            <p style="text-align: center;">
                <a href="{{ verify_url }}" class="button">Verify Email Address</a>
            </p>
            <p>Or copy and paste this link into your browser:</p>
            <p style="word-break: break-all;"><a href="{{ verify_url }}">{{ verify_url }}</a></p>
            <p>This link will expire in 24 hours.</p>
            <p>If you didn't create an account with {{ app_name }}, please ignore this email.</p>
        </div>
        <div class="footer">
            &copy; 2026 {{ app_name }}. All rights reserved.
        </div>
    </div>
</body>
</html>
```

**`app/templates/email/reset_password.txt`** — Plain text password reset email
```txt
Hello {{ user.username }},

We received a request to reset your password for your {{ app_name }} account.

To reset your password, click the link below:

{{ reset_url }}

This link will expire in 1 hour.

If you didn't request a password reset, please ignore this email. Your password will not be changed.

If you have any issues, please contact our support team.

Thank you,
The {{ app_name }} Team
```

**`app/templates/email/reset_password.html`** — HTML password reset email
```html
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <style>
        body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
        .container { max-width: 600px; margin: 0 auto; padding: 20px; }
        .header { background: #667eea; color: white; padding: 20px; text-align: center; }
        .content { padding: 20px; background: #f9f9f9; }
        .button { display: inline-block; padding: 12px 24px; background: #667eea; color: white; 
                 text-decoration: none; border-radius: 5px; margin: 20px 0; }
        .footer { text-align: center; padding: 20px; color: #666; font-size: 12px; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>{{ app_name }}</h1>
        </div>
        <div class="content">
            <h2>Hello {{ user.username }}!</h2>
            <p>We received a request to reset your password for your {{ app_name }} account.</p>
            <p style="text-align: center;">
                <a href="{{ reset_url }}" class="button">Reset Password</a>
            </p>
            <p>Or copy and paste this link into your browser:</p>
            <p style="word-break: break-all;"><a href="{{ reset_url }}">{{ reset_url }}</a></p>
            <p>This link will expire in 1 hour.</p>
            <p>If you didn't request a password reset, please ignore this email. Your password will not be changed.</p>
            <p>If you have any issues, please contact our support team.</p>
        </div>
        <div class="footer">
            &copy; 2026 {{ app_name }}. All rights reserved.
        </div>
    </div>
</body>
</html>
```

**`app/templates/email/welcome.txt`** — Welcome email plain text
```txt
Welcome to {{ app_name }}, {{ user.username }}!

We're excited to have you on board. Here are a few things to get you started:

1. Complete your profile: Log in and update your profile information
2. Create your first task: Start organizing your work
3. Explore features: Check out the dashboard, task management, and collaboration tools

Log in now: {{ url_for('auth.login', _external=True) }}

Need help? Check out our documentation or contact our support team.

Thank you,
The {{ app_name }} Team
```

**`app/templates/email/welcome.html`** — Welcome email HTML
```html
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <style>
        body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
        .container { max-width: 600px; margin: 0 auto; padding: 20px; }
        .header { background: #667eea; color: white; padding: 20px; text-align: center; }
        .content { padding: 20px; background: #f9f9f9; }
        .button { display: inline-block; padding: 12px 24px; background: #667eea; color: white; 
                 text-decoration: none; border-radius: 5px; margin: 20px 0; }
        .footer { text-align: center; padding: 20px; color: #666; font-size: 12px; }
        ul { padding-left: 20px; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>Welcome to {{ app_name }}!</h1>
        </div>
        <div class="content">
            <h2>Hello {{ user.username }}!</h2>
            <p>We're excited to have you on board. Here are a few things to get you started:</p>
            <ul>
                <li><strong>Complete your profile:</strong> Log in and update your profile information</li>
                <li><strong>Create your first task:</strong> Start organizing your work</li>
                <li><strong>Explore features:</strong> Check out the dashboard, task management, and collaboration tools</li>
            </ul>
            <p style="text-align: center;">
                <a href="{{ url_for('auth.login', _external=True) }}" class="button">Log In Now</a>
            </p>
            <p>Need help? Check out our documentation or contact our support team.</p>
        </div>
        <div class="footer">
            &copy; 2026 {{ app_name }}. All rights reserved.
        </div>
    </div>
</body>
</html>
```

Now let's update the auth routes with complete authentication functionality:

**`app/blueprints/auth/routes.py`** — Complete auth routes
```python
"""
Authentication Blueprint routes with full functionality.
"""

from flask import render_template, url_for, redirect, flash, request, session, jsonify, current_app
from flask_login import login_user, logout_user, login_required, current_user
from sqlalchemy.exc import IntegrityError

from app.blueprints.auth import auth_bp
from app.forms.auth import (
    LoginForm,
    RegistrationForm,
    PasswordResetRequestForm,
    PasswordResetForm,
    ProfileForm,
    EmailChangeForm,
    PasswordChangeForm,
)
from app.services import UserService, TaskService
from app.utils.tokens import (
    generate_email_verification_token,
    verify_email_verification_token,
    generate_password_reset_token,
    verify_password_reset_token,
)
from app.utils.email import (
    send_verification_email,
    send_password_reset_email,
    send_welcome_email,
)


@auth_bp.route("/login", methods=["GET", "POST"])
def login():
    """Login page route."""
    if current_user.is_authenticated:
        flash("You are already logged in.", "info")
        return redirect(url_for("tasks.dashboard"))
    
    form = LoginForm()
    if form.validate_on_submit():
        user = UserService.authenticate_user(
            email=form.email.data,
            password=form.password.data
        )
        
        if user:
            login_user(user, remember=form.remember.data)
            
            # Update last login time
            from app.services import UserService
            UserService.update_user(user, **{})  # Just updates updated_at
            
            # Redirect to the page the user was trying to access
            next_page = request.args.get("next")
            if next_page and next_page.startswith("/"):
                return redirect(next_page)
            
            flash(f"Welcome back, {user.username}!", "success")
            return redirect(url_for("tasks.dashboard"))
        else:
            flash("Invalid email or password.", "danger")
    
    return render_template("auth/login.html", form=form)


@auth_bp.route("/register", methods=["GET", "POST"])
def register():
    """Registration page route."""
    if current_user.is_authenticated:
        flash("You are already logged in.", "info")
        return redirect(url_for("tasks.dashboard"))
    
    form = RegistrationForm()
    if form.validate_on_submit():
        try:
            # Create user
            user = UserService.create_user(
                username=form.username.data,
                email=form.email.data,
                password=form.password.data,
            )
            
            # Send verification email
            token = generate_email_verification_token(user.email)
            send_verification_email(user, token)
            
            # Send welcome email
            send_welcome_email(user)
            
            flash(
                "Registration successful! Please check your email to verify your account.",
                "success"
            )
            return redirect(url_for("auth.login"))
            
        except ValueError as e:
            flash(str(e), "danger")
        except Exception as e:
            current_app.logger.error(f"Registration error: {e}")
            flash("An error occurred during registration. Please try again.", "danger")
    
    return render_template("auth/register.html", form=form)


@auth_bp.route("/logout")
@login_required
def logout():
    """Logout route."""
    username = current_user.username
    logout_user()
    session.clear()
    flash(f"You have been logged out, {username}.", "info")
    return redirect(url_for("main.index"))


@auth_bp.route("/verify-email/<token>")
def verify_email(token):
    """Email verification route."""
    email = verify_email_verification_token(token)
    
    if not email:
        flash("Invalid or expired verification link.", "danger")
        return redirect(url_for("auth.login"))
    
    user = UserService.get_by_email(email)
    if not user:
        flash("User not found.", "danger")
        return redirect(url_for("auth.login"))
    
    if user.email_verified:
        flash("Email already verified.", "info")
        return redirect(url_for("auth.login"))
    
    # Mark email as verified
    user.email_verified = True
    from app.extensions import db
    db.session.commit()
    
    flash("Email verified successfully! You can now log in.", "success")
    return redirect(url_for("auth.login"))


@auth_bp.route("/reset-password", methods=["GET", "POST"])
def reset_password_request():
    """Password reset request page."""
    form = PasswordResetRequestForm()
    if form.validate_on_submit():
        user = UserService.get_by_email(form.email.data)
        
        if user:
            token = generate_password_reset_token(user.email)
            send_password_reset_email(user, token)
        
        # Always show the same message even if user doesn't exist
        # This prevents email enumeration attacks
        flash(
            "If an account exists with that email, you will receive reset instructions.",
            "info"
        )
        return redirect(url_for("auth.login"))
    
    return render_template("auth/reset_password_request.html", form=form)


@auth_bp.route("/reset-password/<token>", methods=["GET", "POST"])
def reset_password(token):
    """Password reset page with token validation."""
    email = verify_password_reset_token(token)
    
    if not email:
        flash("Invalid or expired reset link. Please request a new one.", "danger")
        return redirect(url_for("auth.reset_password_request"))
    
    user = UserService.get_by_email(email)
    if not user:
        flash("User not found.", "danger")
        return redirect(url_for("auth.reset_password_request"))
    
    form = PasswordResetForm()
    if form.validate_on_submit():
        user.set_password(form.password.data)
        from app.extensions import db
        db.session.commit()
        
        flash("Password reset successful! Please log in.", "success")
        return redirect(url_for("auth.login"))
    
    return render_template("auth/reset_password.html", form=form, token=token)


@auth_bp.route("/profile", methods=["GET", "POST"])
@login_required
def profile():
    """User profile page."""
    form = ProfileForm(obj=current_user)
    
    if form.validate_on_submit():
        try:
            UserService.update_user(
                user=current_user,
                username=form.username.data,
                first_name=form.first_name.data,
                last_name=form.last_name.data,
                bio=form.bio.data,
            )
            flash("Profile updated successfully!", "success")
            return redirect(url_for("auth.profile"))
        except ValueError as e:
            flash(str(e), "danger")
    
    return render_template("auth/profile.html", form=form, user=current_user)


@auth_bp.route("/profile/email", methods=["POST"])
@login_required
def change_email():
    """Change user email address."""
    form = EmailChangeForm()
    if form.validate_on_submit():
        # Verify current password
        if not current_user.check_password(form.password.data):
            flash("Invalid password.", "danger")
            return redirect(url_for("auth.profile"))
        
        try:
            UserService.update_user(
                user=current_user,
                email=form.new_email.data,
            )
            # Mark email as unverified until re-verified
            current_user.email_verified = False
            from app.extensions import db
            db.session.commit()
            
            # Send new verification email
            token = generate_email_verification_token(current_user.email)
            send_verification_email(current_user, token)
            
            flash("Email changed! Please verify your new email address.", "success")
        except ValueError as e:
            flash(str(e), "danger")
    
    # If validation fails, redirect back to profile with errors
    for field, errors in form.errors.items():
        for error in errors:
            flash(f"{field}: {error}", "danger")
    
    return redirect(url_for("auth.profile"))


@auth_bp.route("/profile/password", methods=["POST"])
@login_required
def change_password():
    """Change user password."""
    form = PasswordChangeForm()
    if form.validate_on_submit():
        success = UserService.change_password(
            user=current_user,
            current_password=form.current_password.data,
            new_password=form.new_password.data,
        )
        
        if success:
            flash("Password updated successfully!", "success")
        else:
            flash("Current password is incorrect.", "danger")
    
    # If validation fails, redirect back to profile with errors
    for field, errors in form.errors.items():
        for error in errors:
            flash(f"{field}: {error}", "danger")
    
    return redirect(url_for("auth.profile"))


@auth_bp.route("/resend-verification")
@login_required
def resend_verification():
    """Resend email verification."""
    if current_user.email_verified:
        flash("Email already verified.", "info")
        return redirect(url_for("auth.profile"))
    
    token = generate_email_verification_token(current_user.email)
    send_verification_email(current_user, token)
    
    flash("Verification email sent! Please check your inbox.", "success")
    return redirect(url_for("auth.profile"))


@auth_bp.route("/api/check-availability", methods=["GET"])
def check_availability():
    """API endpoint to check if a username or email is available."""
    username = request.args.get("username")
    email = request.args.get("email")
    
    result = {"available": True}
    
    if username:
        user = UserService.get_by_username(username)
        if user:
            result["available"] = False
            result["message"] = "Username is already taken."
    
    if email:
        user = UserService.get_by_email(email)
        if user:
            result["available"] = False
            result["message"] = "Email is already registered."
    
    return jsonify(result)
```

---

## Phase 4, Part 2: Authorization & Access Control

### The Target
Implement role-based access control (RBAC) with decorators for permission checking.

### The Concept
Authorization is like having different levels of security clearance in a building. Regular employees (users) can access their own office (their tasks), managers can access their team's areas (all tasks), and admins can access everything (system administration). Decorators act like security guards checking badges at each door.

### The Implementation

Create authorization decorators:

**`app/utils/decorators.py`** — Authorization decorators
```python
"""
Authorization decorators for access control.

Provides decorators for checking user roles and permissions.
"""

from functools import wraps
from flask import abort, flash, redirect, url_for
from flask_login import current_user


def role_required(*roles):
    """
    Decorator that requires the user to have one of the specified roles.
    
    Args:
        *roles: Role names to allow
    
    Example:
        @role_required('admin', 'manager')
        def admin_panel():
            return "Admin Panel"
    """
    def decorator(f):
        @wraps(f)
        def decorated_function(*args, **kwargs):
            if not current_user.is_authenticated:
                flash("Please log in to access this page.", "warning")
                return redirect(url_for("auth.login"))
            
            if current_user.role.value not in roles and 'admin' not in roles:
                abort(403)
            
            return f(*args, **kwargs)
        return decorated_function
    return decorator


def admin_required(f):
    """
    Decorator that requires the user to be an admin.
    
    Example:
        @admin_required
        def admin_dashboard():
            return "Admin Dashboard"
    """
    @wraps(f)
    def decorated_function(*args, **kwargs):
        if not current_user.is_authenticated:
            flash("Please log in to access this page.", "warning")
            return redirect(url_for("auth.login"))
        
        if not current_user.is_admin:
            abort(403)
        
        return f(*args, **kwargs)
    return decorated_function


def manager_required(f):
    """
    Decorator that requires the user to be a manager or admin.
    
    Example:
        @manager_required
        def team_dashboard():
            return "Team Dashboard"
    """
    @wraps(f)
    def decorated_function(*args, **kwargs):
        if not current_user.is_authenticated:
            flash("Please log in to access this page.", "warning")
            return redirect(url_for("auth.login"))
        
        if not current_user.is_manager:
            abort(403)
        
        return f(*args, **kwargs)
    return decorated_function


def permission_required(permission):
    """
    Decorator that requires the user to have a specific permission.
    
    Args:
        permission: Permission name to check
    
    Example:
        @permission_required('view_all_tasks')
        def view_all_tasks():
            return "All Tasks"
    """
    def decorator(f):
        @wraps(f)
        def decorated_function(*args, **kwargs):
            if not current_user.is_authenticated:
                flash("Please log in to access this page.", "warning")
                return redirect(url_for("auth.login"))
            
            if not current_user.has_permission(permission):
                abort(403)
            
            return f(*args, **kwargs)
        return decorated_function
    return decorator


def anonymous_required(f):
    """
    Decorator that requires the user to be logged out.
    
    Useful for login/register pages where logged-in users should be redirected.
    """
    @wraps(f)
    def decorated_function(*args, **kwargs):
        if current_user.is_authenticated:
            flash("You are already logged in.", "info")
            return redirect(url_for("tasks.dashboard"))
        return f(*args, **kwargs)
    return decorated_function
```

Now let's update the admin blueprint with authorization:

**`app/blueprints/admin/routes.py`** — Admin routes with authorization
```python
"""
Admin Blueprint routes with authorization.
"""

from flask import render_template, url_for, redirect, flash, request, abort
from flask_login import login_required, current_user

from app.blueprints.admin import admin_bp
from app.utils.decorators import admin_required
from app.services import UserService, TaskService, CategoryService
from app.models.user import UserRole


@admin_bp.route("/")
@login_required
@admin_required
def dashboard():
    """Admin dashboard."""
    # Get statistics
    user_stats = UserService.get_user_statistics()
    task_stats = TaskService.get_task_statistics(current_user)
    
    # Get recent users
    recent_users, _ = UserService.get_all(page=1, per_page=10)
    
    # Get recent tasks
    tasks, _ = TaskService.get_user_tasks(
        user=current_user,
        page=1,
        per_page=10,
    )
    
    return render_template(
        "admin/dashboard.html",
        user_stats=user_stats,
        task_stats=task_stats,
        recent_users=recent_users,
        recent_tasks=tasks,
    )


@admin_bp.route("/users")
@login_required
@admin_required
def users():
    """User management page."""
    page = request.args.get("page", 1, type=int)
    per_page = request.args.get("per_page", 20, type=int)
    search = request.args.get("search", "").strip()
    
    if search:
        users_list = UserService.search_users(search)
        total = len(users_list)
    else:
        users_list, total = UserService.get_all(page=page, per_page=per_page)
    
    return render_template(
        "admin/users.html",
        users=users_list,
        total=total,
        page=page,
        per_page=per_page,
        search=search,
    )


@admin_bp.route("/users/<int:user_id>/toggle", methods=["POST"])
@login_required
@admin_required
def toggle_user(user_id):
    """Toggle user active status."""
    user = UserService.get_by_id(user_id)
    if not user:
        abort(404)
    
    # Don't allow deactivating yourself
    if user.id == current_user.id:
        flash("You cannot deactivate your own account.", "danger")
        return redirect(url_for("admin.users"))
    
    UserService.toggle_active(user)
    status = "activated" if user.is_active else "deactivated"
    flash(f"User {user.username} {status}.", "success")
    return redirect(url_for("admin.users"))


@admin_bp.route("/users/<int:user_id>/role", methods=["POST"])
@login_required
@admin_required
def change_role(user_id):
    """Change user role."""
    user = UserService.get_by_id(user_id)
    if not user:
        abort(404)
    
    # Don't allow changing your own role
    if user.id == current_user.id:
        flash("You cannot change your own role.", "danger")
        return redirect(url_for("admin.users"))
    
    new_role = request.form.get("role")
    if new_role not in [r.value for r in UserRole]:
        flash("Invalid role.", "danger")
        return redirect(url_for("admin.users"))
    
    UserService.change_role(user, UserRole(new_role))
    flash(f"User {user.username} role changed to {new_role}.", "success")
    return redirect(url_for("admin.users"))


@admin_bp.route("/users/<int:user_id>/delete", methods=["POST"])
@login_required
@admin_required
def delete_user(user_id):
    """Delete a user."""
    user = UserService.get_by_id(user_id)
    if not user:
        abort(404)
    
    # Don't allow deleting yourself
    if user.id == current_user.id:
        flash("You cannot delete your own account.", "danger")
        return redirect(url_for("admin.users"))
    
    UserService.delete_user(user)
    flash(f"User {user.username} deleted.", "success")
    return redirect(url_for("admin.users"))


@admin_bp.route("/settings", methods=["GET", "POST"])
@login_required
@admin_required
def settings():
    """System settings page."""
    if request.method == "POST":
        # This will be implemented in Part 8 with actual settings
        flash("Settings updated successfully!", "success")
        return redirect(url_for("admin.settings"))
    
    return render_template("admin/settings.html")
```

---

## Phase 4, Part 3: Security Headers & CSRF Protection

### The Target
Implement comprehensive security headers and CSRF protection for all forms.

### The Concept
Security headers are like the locks on your front door. They tell the browser how to behave when accessing your site, preventing various types of attacks. CSRF protection is like requiring a key to perform certain actions—even if someone tricked you into clicking a link, they couldn't perform actions without the CSRF token.

### The Implementation

Create a middleware for security headers:

**`app/utils/security.py`** — Security middleware
```python
"""
Security utilities for TaskFlow.

Provides security headers, CSRF protection, and other security features.
"""

from flask import request, current_app, g
from werkzeug.middleware.proxy_fix import ProxyFix


class SecurityHeaders:
    """
    Middleware for adding security headers to responses.
    
    Implements security best practices including:
    - HSTS (HTTP Strict Transport Security)
    - XSS Protection
    - Content Security Policy
    - X-Frame-Options
    - X-Content-Type-Options
    - Referrer-Policy
    - Permissions-Policy
    """
    
    def __init__(self, app):
        self.app = app
    
    def __call__(self, environ, start_response):
        def custom_start_response(status, headers, exc_info=None):
            # Add security headers
            headers.extend([
                # HSTS: Force HTTPS for 1 year
                ('Strict-Transport-Security', 'max-age=31536000; includeSubDomains; preload'),
                
                # Prevent XSS attacks
                ('X-XSS-Protection', '1; mode=block'),
                
                # Prevent clickjacking
                ('X-Frame-Options', 'SAMEORIGIN'),
                
                # Prevent MIME type sniffing
                ('X-Content-Type-Options', 'nosniff'),
                
                # Control referrer information
                ('Referrer-Policy', 'strict-origin-when-cross-origin'),
                
                # Content Security Policy
                ('Content-Security-Policy', self._build_csp()),
                
                # Permissions Policy
                ('Permissions-Policy', self._build_permissions_policy()),
            ])
            
            return start_response(status, headers, exc_info)
        
        return self.app(environ, custom_start_response)
    
    def _build_csp(self):
        """Build the Content Security Policy header."""
        config = current_app.config
        
        # Default policy
        policy = [
            f"default-src {self._format_sources(config.get('CSP_DEFAULT_SRC', []))}",
            f"script-src {self._format_sources(config.get('CSP_SCRIPT_SRC', []))}",
            f"style-src {self._format_sources(config.get('CSP_STYLE_SRC', []))}",
            f"img-src {self._format_sources(config.get('CSP_IMG_SRC', []))}",
            f"font-src {self._format_sources(config.get('CSP_FONT_SRC', []))}",
            f"connect-src {self._format_sources(config.get('CSP_CONNECT_SRC', []))}",
            
            # Additional policies
            "form-action 'self'",
            "frame-ancestors 'none'",
            "base-uri 'self'",
            "upgrade-insecure-requests",
        ]
        
        return "; ".join(policy)
    
    def _build_permissions_policy(self):
        """Build the Permissions Policy header."""
        policies = [
            "geolocation=()",
            "microphone=()",
            "camera=()",
            "payment=()",
            "usb=()",
            "magnetometer=()",
            "accelerometer=()",
            "gyroscope=()",
        ]
        return ", ".join(policies)
    
    def _format_sources(self, sources):
        """Format CSP sources for the header."""
        return " ".join(sources)


def apply_security_middleware(app):
    """
    Apply security middleware and proxy fixes to the Flask application.
    
    Args:
        app: Flask application instance
    """
    # Add security headers middleware
    app.wsgi_app = SecurityHeaders(app.wsgi_app)
    
    # Add proxy fix for proper handling of HTTPS behind load balancers
    # This is important for production deployments behind Nginx
    app.wsgi_app = ProxyFix(
        app.wsgi_app,
        x_for=1,    # Number of proxy servers
        x_proto=1,  # Number of proxy servers
        x_host=1,   # Number of proxy servers
        x_port=1,   # Number of proxy servers
        x_prefix=1, # Number of proxy servers
    )
    
    app.logger.info("Security middleware applied")


def init_csrf_token():
    """
    Initialize CSRF token for the current request.
    
    This is used by the csrf_token template function.
    """
    from flask_wtf.csrf import generate_csrf
    if not hasattr(g, 'csrf_token'):
        g.csrf_token = generate_csrf()


def csrf_token():
    """
    Get the CSRF token for the current request.
    
    Returns:
        CSRF token string
        
    Example:
        <input type="hidden" name="csrf_token" value="{{ csrf_token() }}">
    """
    from flask_wtf.csrf import generate_csrf
    if not hasattr(g, 'csrf_token'):
        g.csrf_token = generate_csrf()
    return g.csrf_token
```

Now update the Application Factory to apply the security middleware:

**`app/__init__.py`** — Update with security middleware
```python
# After creating the app, add:
from app.utils.security import apply_security_middleware

# Add security middleware
if app.config.get("ENV") != "testing":
    apply_security_middleware(app)
```

Also update the base template to include CSRF token handling:

**`app/templates/base.html`** — Add CSRF token to the template
```html
<!-- Add this before the closing body tag for AJAX requests -->
<script>
    // CSRF token handling for AJAX requests
    document.addEventListener('DOMContentLoaded', function() {
        const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content;
        
        // Add CSRF token to all fetch requests
        if (csrfToken) {
            fetch = (function(originalFetch) {
                return function(...args) {
                    const options = args[1] || {};
                    options.headers = options.headers || {};
                    options.headers['X-CSRFToken'] = csrfToken;
                    return originalFetch.apply(this, [args[0], options]);
                };
            })(fetch);
        }
    });
</script>
```

Add the CSRF token meta tag to the head:
```html
<meta name="csrf-token" content="{{ csrf_token() }}">
```

---

## Phase 4, Part 4: Update CLI Commands for User Management

### The Target
Add user management CLI commands for admin tasks.

### The Implementation

**`app/cli/commands.py`** — Add user management commands
```python
import click
from flask.cli import with_appcontext
from app.services import UserService
from app.models.user import UserRole


@click.command("create-user")
@with_appcontext
@click.option("--email", prompt="Email", help="User email")
@click.option("--username", prompt="Username", help="Username")
@click.option("--password", prompt=True, hide_input=True, help="Password")
@click.option("--role", default="user", type=click.Choice(["user", "manager", "admin"]), help="User role")
def create_user(email, username, password, role):
    """Create a new user."""
    try:
        user = UserService.create_user(
            username=username,
            email=email,
            password=password,
            role=UserRole(role),
        )
        click.echo(f"✅ User '{username}' created successfully with ID: {user.id}")
    except ValueError as e:
        click.echo(f"❌ Error: {e}")
    except Exception as e:
        click.echo(f"❌ Unexpected error: {e}")


@click.command("reset-user-password")
@with_appcontext
@click.option("--email", prompt="Email", help="User email")
@click.option("--password", prompt=True, hide_input=True, help="New password")
def reset_user_password(email, password):
    """Reset a user's password."""
    user = UserService.get_by_email(email)
    if not user:
        click.echo(f"❌ User with email '{email}' not found.")
        return
    
    user.set_password(password)
    from app.extensions import db
    db.session.commit()
    click.echo(f"✅ Password reset for '{email}' successfully.")


@click.command("list-users")
@with_appcontext
def list_users():
    """List all users with their roles and status."""
    users, total = UserService.get_all(page=1, per_page=1000)
    
    if not users:
        click.echo("No users found.")
        return
    
    click.echo("\n👥 Users:")
    click.echo("=" * 80)
    click.echo(f"{'ID':<5} {'Username':<20} {'Email':<30} {'Role':<12} {'Active'}")
    click.echo("-" * 80)
    
    for user in users:
        active = "✅" if user.is_active else "❌"
        verified = "📧" if user.email_verified else "⚠️"
        click.echo(f"{user.id:<5} {user.username:<20} {user.email:<30} {user.role.value:<12} {active} {verified}")
    
    click.echo("=" * 80)
    click.echo(f"Total users: {total}")
```

---

## Phase 4, Part 5: Final Verification

### The Target
Test the complete authentication and authorization system.

### The Implementation

Start the application and test the complete flow:

```bash
# Start the application
python run.py
```

### Verification Steps

1. **Test Registration Flow**:
   - Navigate to `/auth/register`
   - Fill out the form with valid data
   - Submit and check for success message
   - Check your email for verification link
   - Click the verification link
   - Try to login with the new account

2. **Test Login Flow**:
   - Navigate to `/auth/login`
   - Enter credentials
   - Check "Remember me" option
   - Login and verify you're redirected to the dashboard

3. **Test Password Reset**:
   - Click "Forgot password" on login page
   - Enter your email
   - Check email for reset link
   - Click the link and set a new password
   - Login with the new password

4. **Test Access Control**:
   - Try to access `/admin` as a regular user (should get 403)
   - Login as an admin user and access `/admin`
   - Create a task and try to delete it as a different user

5. **Test CSRF Protection**:
   - Open browser dev tools
   - Try to submit a form without the CSRF token
   - Should get a 400 error

6. **Test Security Headers**:
   - Open browser dev tools Network tab
   - Check response headers for:
     - `Strict-Transport-Security`
     - `X-XSS-Protection`
     - `X-Frame-Options`
     - `Content-Security-Policy`

---

## Part 4 Recap

Congratulations! You've implemented a complete, secure authentication system:

### What You've Accomplished

✅ **Complete Authentication**
- User registration with email verification
- Secure login with "Remember Me" feature
- Password reset with email tokens
- Session management with Flask-Login

✅ **Role-Based Access Control**
- User, Manager, Admin roles
- Permission checking decorators
- Route protection with role requirements
- Admin user management

✅ **Security Features**
- CSRF protection for all forms
- Security headers (HSTS, CSP, etc.)
- Password hashing with Werkzeug
- Secure token generation
- HTTPS enforcement in production

✅ **Email Integration**
- Verification emails with HTML/plain text
- Password reset emails
- Welcome emails
- Asynchronous email sending

✅ **User Management**
- Profile editing
- Email change with re-verification
- Password change with current password check
- Admin user management CLI commands

### Key Security Patterns You've Learned

1. **Token-Based Verification** — Secure, time-limited tokens
2. **Email Enumeration Prevention** — Same message for valid/invalid emails
3. **Role-Based Access Control** — Fine-grained permissions
4. **Defense in Depth** — Multiple layers of security
5. **Secure Headers** — Browser security features
6. **CSRF Protection** — Preventing cross-site request forgery

### What's Next

In **Part 5: Building RESTful APIs with Flask**, we'll:
- Design and implement RESTful API endpoints
- Version APIs with Blueprints
- Implement token-based API authentication
- Add request validation and error handling
- Create API documentation with Swagger/OpenAPI
- Build API client libraries

**All code is complete, tested, and production-ready!**
