# Appendix C: Security Best Practices for Python Developers

## C.1 Introduction to Secure Python Development

### The Security Mindset

Think of security like building a house. You don't just lock the front door—you consider windows, back doors, basement access, and even the roof. Similarly, secure development requires thinking about all possible attack vectors, not just the obvious ones.

### Why Security Matters in Python

While Python has many safety features, it's not immune to security issues:

- **Dynamic typing** can hide type-related vulnerabilities
- **Reflection** can expose internal APIs
- **Third-party packages** may contain vulnerabilities
- **Default behaviors** may be insecure

---

## C.2 Input Validation & Sanitization

### The Principle: Never Trust User Input

All input from outside your application should be treated as potentially malicious. Validate it thoroughly before use.

### Command Injection Prevention

```python
# DANGEROUS - Command injection
import os
user_input = input("Enter filename: ")
os.system(f"cat {user_input}")  # If user enters "file.txt; rm -rf /"...

# SAFE - Using subprocess with list
import subprocess
user_input = input("Enter filename: ")
subprocess.run(["cat", user_input])  # Argument is treated as one token

# SAFE - Validate input
import subprocess
import re

def validate_filename(filename):
    # Only allow alphanumeric, underscore, dot, hyphen
    if re.match(r'^[\w\-\.]+$', filename):
        return True
    return False

user_input = input("Enter filename: ")
if validate_filename(user_input):
    subprocess.run(["cat", user_input])
else:
    print("Invalid filename")

# SAFE - Use shlex.quote when strings are necessary
import shlex
user_input = input("Enter filename: ")
subprocess.run(f"cat {shlex.quote(user_input)}", shell=True)
```

### SQL Injection Prevention

```python
# DANGEROUS - SQL injection
import sqlite3
user_input = input("Enter username: ")
conn = sqlite3.connect('users.db')
cursor = conn.execute(f"SELECT * FROM users WHERE username = '{user_input}'")
# If user enters "admin' OR '1'='1", all users are returned

# SAFE - Parameterized queries
import sqlite3
user_input = input("Enter username: ")
conn = sqlite3.connect('users.db')
cursor = conn.execute(
    "SELECT * FROM users WHERE username = ?", 
    (user_input,)
)

# SAFE - Using ORM (SQLAlchemy)
from sqlalchemy import text
conn.execute(
    text("SELECT * FROM users WHERE username = :username"),
    {"username": user_input}
)
```

### Path Traversal Prevention

```python
# DANGEROUS - Path traversal
from pathlib import Path
import os

user_input = input("Enter file path: ")
with open(user_input, 'r') as f:  # User could enter "../../etc/passwd"
    data = f.read()

# SAFE - Validate and normalize paths
from pathlib import Path

BASE_DIR = Path("/var/www/uploads")

def safe_open(filename):
    # Resolve path and check it's under BASE_DIR
    path = (BASE_DIR / filename).resolve()
    if not str(path).startswith(str(BASE_DIR.resolve())):
        raise ValueError("Invalid path")
    return open(path, 'r')

user_input = input("Enter filename: ")
with safe_open(user_input) as f:
    data = f.read()

# SAFE - Use whitelist of allowed files
ALLOWED_FILES = {'file1.txt', 'file2.txt', 'file3.txt'}

def safe_open(filename):
    if filename not in ALLOWED_FILES:
        raise ValueError("File not allowed")
    return open(Path(BASE_DIR) / filename, 'r')
```

### HTML/XML Injection Prevention

```python
# DANGEROUS - XSS vulnerability
from flask import Flask, request

app = Flask(__name__)

@app.route('/hello')
def hello():
    name = request.args.get('name', 'World')
    return f"<h1>Hello, {name}!</h1>"  # User could inject <script>alert('XSS')</script>

# SAFE - HTML escaping
from markupsafe import escape

@app.route('/hello')
def hello():
    name = request.args.get('name', 'World')
    return f"<h1>Hello, {escape(name)}!</h1>"

# SAFE - Using a template engine (Jinja2)
from flask import render_template_string

@app.route('/hello')
def hello():
    name = request.args.get('name', 'World')
    return render_template_string(
        "<h1>Hello, {{ name }}!</h1>",
        name=name  # Auto-escaped by Jinja2
    )
```

### Deserialization Security

```python
# DANGEROUS - pickle deserialization
import pickle

user_input = input("Enter serialized data: ")
data = pickle.loads(user_input.encode())  # Could execute arbitrary code

# SAFE - Use JSON for serialization
import json

user_input = input("Enter serialized data: ")
data = json.loads(user_input)  # Safe for basic data types

# SAFE - Use pickle with restrictions
import pickle
import builtins
import io

class RestrictedUnpickler(pickle.Unpickler):
    def find_class(self, module, name):
        # Only allow certain modules and classes
        allowed = {
            'builtins': {'list', 'dict', 'str', 'int', 'float', 'bool', 'NoneType'},
            'collections': {'OrderedDict', 'defaultdict'},
        }
        
        if module in allowed and name in allowed[module]:
            return getattr(__import__(module), name)
        raise pickle.UnpicklingError(f"Loading {module}.{name} is not allowed")

def safe_loads(data):
    file = io.BytesIO(data)
    return RestrictedUnpickler(file).load()

# Usage
user_input = input("Enter serialized data: ")
data = safe_loads(user_input.encode())
```

---

## C.3 Authentication & Authorization

### Password Security

```python
# DANGEROUS - Storing passwords in plaintext
users = {
    "admin": "password123"  # Anyone can read this
}

# DANGEROUS - MD5/SHA1 for passwords (weak)
import hashlib
password_hash = hashlib.md5("password123".encode()).hexdigest()
# Use SHA256 or higher

# SAFE - Use bcrypt or Argon2
import bcrypt

def hash_password(password):
    # Generate salt and hash
    salt = bcrypt.gensalt()
    hashed = bcrypt.hashpw(password.encode(), salt)
    return hashed

def verify_password(password, hashed):
    return bcrypt.checkpw(password.encode(), hashed)

# Usage
hashed = hash_password("password123")
print(f"Hashed: {hashed}")

is_valid = verify_password("password123", hashed)
print(f"Valid: {is_valid}")

# SAFE - Argon2 (strongest password hashing)
from argon2 import PasswordHasher
from argon2.exceptions import VerificationError

ph = PasswordHasher()

def hash_password_argon2(password):
    return ph.hash(password)

def verify_password_argon2(password, hashed):
    try:
        ph.verify(hashed, password)
        return True
    except VerificationError:
        return False

# Usage
hashed = hash_password_argon2("password123")
is_valid = verify_password_argon2("password123", hashed)
```

### Rate Limiting for Login

```python
import time
from collections import defaultdict
from functools import wraps

class RateLimiter:
    def __init__(self, max_attempts=5, window=300):  # 5 attempts in 5 minutes
        self.max_attempts = max_attempts
        self.window = window
        self.attempts = defaultdict(list)
    
    def check(self, key):
        """Check if rate limit has been exceeded."""
        now = time.time()
        # Clean old attempts
        self.attempts[key] = [t for t in self.attempts[key] if now - t < self.window]
        
        if len(self.attempts[key]) >= self.max_attempts:
            return False
        
        return True
    
    def record(self, key):
        """Record an attempt."""
        self.attempts[key].append(time.time())
    
    def get_remaining_time(self, key):
        """Get time until limit resets."""
        if key not in self.attempts or not self.attempts[key]:
            return 0
        
        now = time.time()
        oldest = min(self.attempts[key])
        return max(0, self.window - (now - oldest))

# Usage
limiter = RateLimiter(max_attempts=3, window=60)  # 3 attempts per minute

def login(username, password):
    key = f"login:{username}"
    
    if not limiter.check(key):
        remaining = limiter.get_remaining_time(key)
        raise Exception(f"Too many attempts. Try again in {remaining:.0f} seconds")
    
    # Check credentials...
    if invalid:
        limiter.record(key)
        raise Exception("Invalid credentials")
    
    return "Success"
```

### Session Management

```python
import secrets
import time
from typing import Dict, Optional

class SessionManager:
    def __init__(self, timeout=3600):  # 1 hour timeout
        self.sessions: Dict[str, Dict] = {}
        self.timeout = timeout
        self._cleanup_task = None
    
    def create_session(self, user_id: str) -> str:
        """Create a new session."""
        session_id = secrets.token_urlsafe(32)
        self.sessions[session_id] = {
            'user_id': user_id,
            'created_at': time.time(),
            'last_accessed': time.time(),
        }
        return session_id
    
    def get_session(self, session_id: str) -> Optional[Dict]:
        """Get session data."""
        if session_id not in self.sessions:
            return None
        
        session = self.sessions[session_id]
        
        # Check expiration
        if time.time() - session['last_accessed'] > self.timeout:
            del self.sessions[session_id]
            return None
        
        # Update last accessed
        session['last_accessed'] = time.time()
        return session
    
    def invalidate_session(self, session_id: str):
        """Invalidate a session."""
        if session_id in self.sessions:
            del self.sessions[session_id]
    
    def cleanup_expired(self):
        """Remove expired sessions."""
        now = time.time()
        expired = [
            sid for sid, sess in self.sessions.items()
            if now - sess['last_accessed'] > self.timeout
        ]
        for sid in expired:
            del self.sessions[sid]
        return len(expired)
```

---

## C.4 Cryptography

### Secure Randomness

```python
# DANGEROUS - Predictable random numbers
import random
token = random.randint(100000, 999999)  # Predictable!

# DANGEROUS - Using default random for security
import random
password = ''.join(random.choices('abcdefghijklmnopqrstuvwxyz', k=10))

# SAFE - Use secrets module
import secrets

def generate_token():
    return secrets.token_urlsafe(32)  # Cryptographically secure

def generate_otp():
    return ''.join(secrets.choice('0123456789') for _ in range(6))

def generate_password():
    alphabet = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*'
    return ''.join(secrets.choice(alphabet) for _ in range(20))

# SAFE - Use os.urandom for bytes
import os
random_bytes = os.urandom(32)
```

### Encryption

```python
from cryptography.fernet import Fernet
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.kdf.pbkdf2 import PBKDF2HMAC
import base64
import os

# Symmetric Encryption (AES)
class SymmetricEncryption:
    def __init__(self, key: bytes = None):
        if key:
            self.key = key
        else:
            self.key = Fernet.generate_key()
        self.cipher = Fernet(self.key)
    
    def encrypt(self, data: bytes) -> bytes:
        return self.cipher.encrypt(data)
    
    def decrypt(self, encrypted: bytes) -> bytes:
        return self.cipher.decrypt(encrypted)
    
    @staticmethod
    def derive_key(password: str, salt: bytes = None) -> bytes:
        """Derive a key from a password."""
        if salt is None:
            salt = os.urandom(16)
        
        kdf = PBKDF2HMAC(
            algorithm=hashes.SHA256(),
            length=32,
            salt=salt,
            iterations=100000,
        )
        key = base64.urlsafe_b64encode(kdf.derive(password.encode()))
        return key, salt

# Usage
encryptor = SymmetricEncryption()
data = "Sensitive data".encode()
encrypted = encryptor.encrypt(data)
decrypted = encryptor.decrypt(encrypted)
print(f"Original: {data}")
print(f"Encrypted: {encrypted}")
print(f"Decrypted: {decrypted}")

# Asymmetric Encryption (RSA)
from cryptography.hazmat.primitives.asymmetric import rsa, padding
from cryptography.hazmat.primitives import serialization

class AsymmetricEncryption:
    def __init__(self):
        # Generate key pair
        self.private_key = rsa.generate_private_key(
            public_exponent=65537,
            key_size=2048
        )
        self.public_key = self.private_key.public_key()
    
    def encrypt(self, data: bytes) -> bytes:
        return self.public_key.encrypt(
            data,
            padding.OAEP(
                mgf=padding.MGF1(algorithm=hashes.SHA256()),
                algorithm=hashes.SHA256(),
                label=None
            )
        )
    
    def decrypt(self, encrypted: bytes) -> bytes:
        return self.private_key.decrypt(
            encrypted,
            padding.OAEP(
                mgf=padding.MGF1(algorithm=hashes.SHA256()),
                algorithm=hashes.SHA256(),
                label=None
            )
        )
    
    def export_public_key(self) -> bytes:
        return self.public_key.public_bytes(
            encoding=serialization.Encoding.PEM,
            format=serialization.PublicFormat.SubjectPublicKeyInfo
        )
    
    def export_private_key(self) -> bytes:
        return self.private_key.private_bytes(
            encoding=serialization.Encoding.PEM,
            format=serialization.PrivateFormat.PKCS8,
            encryption_algorithm=serialization.NoEncryption()
        )

# Usage
asym = AsymmetricEncryption()
data = "Sensitive data".encode()
encrypted = asym.encrypt(data)
decrypted = asym.decrypt(encrypted)
print(f"Original: {data}")
print(f"Encrypted (RSA): {encrypted[:50]}...")
print(f"Decrypted: {decrypted}")
```

### Hashing for Integrity

```python
import hashlib
import hmac

def hash_file(filepath: str, algorithm='sha256') -> str:
    """Calculate file hash."""
    hash_func = getattr(hashlib, algorithm)()
    
    with open(filepath, 'rb') as f:
        for chunk in iter(lambda: f.read(4096), b''):
            hash_func.update(chunk)
    
    return hash_func.hexdigest()

# HMAC for message authentication
def create_hmac(message: bytes, key: bytes) -> str:
    return hmac.new(key, message, hashlib.sha256).hexdigest()

def verify_hmac(message: bytes, key: bytes, signature: str) -> bool:
    expected = create_hmac(message, key)
    return hmac.compare_digest(signature, expected)

# Usage
message = b"Important message"
key = b"secret-key"
signature = create_hmac(message, key)
is_valid = verify_hmac(message, key, signature)
```

---

## C.5 Secure Storage & Secrets Management

### Environment Variables

```python
# SAFE - Load from environment variables
import os

DATABASE_URL = os.environ.get('DATABASE_URL')
API_KEY = os.environ.get('API_KEY')

if not DATABASE_URL:
    raise ValueError("DATABASE_URL environment variable is required")

# Using python-dotenv
from dotenv import load_dotenv

load_dotenv()  # Load .env file

DATABASE_URL = os.getenv('DATABASE_URL')
SECRET_KEY = os.getenv('SECRET_KEY')
```

### Vault Integration (Hashicorp Vault)

```python
import hvac

class VaultClient:
    def __init__(self, url, token):
        self.client = hvac.Client(url=url, token=token)
    
    def get_secret(self, path, key):
        """Get a secret from Vault."""
        try:
            response = self.client.secrets.kv.v2.read_secret_version(path=path)
            return response['data']['data'][key]
        except Exception as e:
            raise ValueError(f"Failed to read secret: {e}")
    
    def set_secret(self, path, data):
        """Store a secret in Vault."""
        self.client.secrets.kv.v2.create_or_update_secret(
            path=path,
            secret=data
        )
    
    def list_secrets(self, path):
        """List secrets at a path."""
        return self.client.secrets.kv.v2.list_secrets(path=path)

# Usage
vault = VaultClient(
    url='https://vault.example.com',
    token='hvs.xxxxxxxxxxxxxx'
)

# Get database credentials
db_password = vault.get_secret('database/creds', 'password')
```

### Secure Configuration

```python
# config.py - Never store secrets in code
import os
from typing import Optional

class SecureConfig:
    # Always use environment variables for secrets
    SECRET_KEY = os.environ.get('SECRET_KEY')
    DATABASE_URL = os.environ.get('DATABASE_URL')
    
    # Default values for non-sensitive configs
    DEBUG = os.environ.get('DEBUG', 'false').lower() == 'true'
    HOST = os.environ.get('HOST', '0.0.0.0')
    PORT = int(os.environ.get('PORT', '8000'))
    
    @classmethod
    def validate(cls):
        """Validate required configuration."""
        required = ['SECRET_KEY', 'DATABASE_URL']
        missing = [r for r in required if not getattr(cls, r, None)]
        
        if missing:
            raise ValueError(f"Missing required environment variables: {', '.join(missing)}")
        
        if cls.DEBUG and len(cls.SECRET_KEY) < 32:
            raise ValueError("SECRET_KEY must be at least 32 characters in production")

# Usage
SecureConfig.validate()
```

---

## C.6 Dependency Security

### Checking Vulnerable Dependencies

```python
# Using pip-audit
import subprocess
import json

def check_dependencies():
    """Run pip-audit and return vulnerabilities."""
    try:
        result = subprocess.run(
            ['pip-audit', '--format', 'json'],
            capture_output=True,
            text=True
        )
        return json.loads(result.stdout)
    except Exception as e:
        print(f"Dependency check failed: {e}")
        return None

# Using safety
def check_safety():
    """Run safety check."""
    try:
        result = subprocess.run(
            ['safety', 'check', '--json'],
            capture_output=True,
            text=True
        )
        return json.loads(result.stdout)
    except Exception as e:
        print(f"Safety check failed: {e}")
        return None

# Usage
vulnerabilities = check_dependencies()
if vulnerabilities:
    print(f"Found {len(vulnerabilities)} vulnerabilities")
    for vuln in vulnerabilities:
        print(f"  - {vuln['name']} {vuln['version']}: {vuln['vulnerability']}")
```

### Dependency Pinning

```python
# requirements.txt with pinned versions
"""
Django==4.2.0
requests==2.28.2
cryptography==39.0.0
"""

# pyproject.toml with version constraints
"""
[project]
dependencies = [
    "Django>=4.2.0,<5.0.0",
    "requests>=2.28.0,<3.0.0",
    "cryptography>=39.0.0,<40.0.0",
]
"""
```

### Using Virtual Environments

```bash
# Create virtual environment
python -m venv venv

# Activate
source venv/bin/activate  # Linux/Mac
venv\Scripts\activate     # Windows

# Install dependencies
pip install -r requirements.txt

# Generate requirements
pip freeze > requirements.txt
```

---

## C.7 Logging & Monitoring

### Secure Logging

```python
import logging
import re

class SensitiveDataFilter(logging.Filter):
    """Filter sensitive data from logs."""
    
    def __init__(self):
        self.patterns = {
            'password': re.compile(r'password\s*=\s*[^\s,]+', re.IGNORECASE),
            'token': re.compile(r'token\s*=\s*[^\s,]+', re.IGNORECASE),
            'email': re.compile(r'email\s*=\s*[^\s,]+', re.IGNORECASE),
            'api_key': re.compile(r'api_key\s*=\s*[^\s,]+', re.IGNORECASE),
            'credit_card': re.compile(r'\d{4}[- ]?\d{4}[- ]?\d{4}[- ]?\d{4}'),
        }
    
    def filter(self, record):
        if record.getMessage():
            message = record.getMessage()
            for name, pattern in self.patterns.items():
                message = pattern.sub(f'[{name.upper()}_REDACTED]', message)
            record.msg = message
        return True

# Configure logging
def setup_secure_logging():
    # Create logger
    logger = logging.getLogger('app')
    logger.setLevel(logging.INFO)
    
    # Create handler
    handler = logging.StreamHandler()
    handler.setLevel(logging.INFO)
    
    # Add sensitive data filter
    handler.addFilter(SensitiveDataFilter())
    
    # Create formatter
    formatter = logging.Formatter(
        '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
    )
    handler.setFormatter(formatter)
    
    # Add handler
    logger.addHandler(handler)
    
    return logger

# Usage
logger = setup_secure_logging()

# This will redact sensitive data
logger.info(f"User login: username=admin, password=secret123, token=abc123")
# Output: User login: username=admin, password=[PASSWORD_REDACTED], token=[TOKEN_REDACTED]

# Never log sensitive data
logger.info("User login successful")  # OK
logger.info(f"User: {username}")      # OK
```

### Security Monitoring

```python
import time
from collections import deque
from typing import Dict, List

class SecurityMonitor:
    def __init__(self, max_events=1000):
        self.events: List[Dict] = []
        self.max_events = max_events
        self.alerts: List[Dict] = []
    
    def log_event(self, event_type: str, details: Dict):
        """Log a security event."""
        event = {
            'timestamp': time.time(),
            'type': event_type,
            'details': details,
        }
        self.events.append(event)
        
        # Trim if needed
        if len(self.events) > self.max_events:
            self.events = self.events[-self.max_events:]
    
    def check_suspicious(self):
        """Check for suspicious patterns."""
        # Check for multiple failed logins
        failed_logins = [
            e for e in self.events 
            if e['type'] == 'login_failed'
        ]
        
        if len(failed_logins) > 10:
            self.alerts.append({
                'timestamp': time.time(),
                'type': 'brute_force_detected',
                'details': f"{len(failed_logins)} failed logins detected"
            })
        
        # Check for SQL injection attempts
        sqli_patterns = ["' OR '1'='1", "'; DROP TABLE", "' UNION SELECT"]
        
        for event in self.events:
            if event['type'] == 'request':
                url = event['details'].get('url', '')
                for pattern in sqli_patterns:
                    if pattern in url:
                        self.alerts.append({
                            'timestamp': time.time(),
                            'type': 'sql_injection_attempt',
                            'details': f"Pattern '{pattern}' detected in request"
                        })
    
    def get_alerts(self) -> List[Dict]:
        """Get all alerts."""
        return self.alerts
```

---

## C.8 Network Security

### SSL/TLS Best Practices

```python
import ssl
import aiohttp
import requests

# SAFE - HTTPS with certificate validation
def secure_request(url):
    response = requests.get(url, verify=True)  # Verify certificate
    return response

# SAFE - Custom SSL context
def create_secure_context():
    context = ssl.create_default_context()
    
    # Verify certificate
    context.verify_mode = ssl.CERT_REQUIRED
    
    # Use strong protocols (disable SSLv2, SSLv3)
    context.options |= ssl.OP_NO_SSLv2
    context.options |= ssl.OP_NO_SSLv3
    context.options |= ssl.OP_NO_TLSv1
    context.options |= ssl.OP_NO_TLSv1_1
    
    # Set strong ciphers
    context.set_ciphers('ECDHE+AESGCM:ECDHE+CHACHA20:DHE+AESGCM')
    
    return context

# SAFE - aiohttp with custom SSL
async def secure_async_request(url):
    connector = aiohttp.TCPConnector(ssl=create_secure_context())
    async with aiohttp.ClientSession(connector=connector) as session:
        async with session.get(url) as response:
            return await response.text()

# DANGEROUS - Disabling certificate validation
def dangerous_request(url):
    response = requests.get(url, verify=False)  # Disables validation!
    return response

# DANGEROUS - Using weak ciphers
def dangerous_context():
    context = ssl.SSLContext(ssl.PROTOCOL_SSLv3)  # Weak protocol
    return context
```

### SSH Security

```python
import paramiko
import socket

class SecureSSHClient:
    def __init__(self):
        self.client = paramiko.SSHClient()
        self.client.set_missing_host_key_policy(paramiko.RejectPolicy())
        # Use paramiko.AutoAddPolicy() for trusted hosts
        # Use paramiko.RejectPolicy() for strict security
    
    def connect(self, hostname, username, key_filename=None, password=None):
        """Connect with secure defaults."""
        try:
            self.client.connect(
                hostname=hostname,
                username=username,
                key_filename=key_filename,
                password=password,
                timeout=10,
                auth_timeout=5,
                banner_timeout=5,
            )
            return True
        except paramiko.AuthenticationException:
            print(f"Authentication failed for {username}@{hostname}")
            return False
        except socket.timeout:
            print(f"Connection timeout for {hostname}")
            return False
        except Exception as e:
            print(f"Connection failed for {hostname}: {e}")
            return False
    
    def execute_command(self, command):
        """Execute a command with proper error handling."""
        try:
            stdin, stdout, stderr = self.client.exec_command(
                command,
                timeout=30,  # Command timeout
                get_pty=False,  # Disable PTY unless needed
            )
            
            # Read output with timeout
            stdout_data = stdout.read().decode('utf-8', errors='ignore')
            stderr_data = stderr.read().decode('utf-8', errors='ignore')
            
            return stdout_data, stderr_data
            
        except paramiko.SSHException as e:
            print(f"SSH command failed: {e}")
            return None, str(e)
    
    def close(self):
        """Close connection."""
        self.client.close()
```

---

## C.9 Code Security Patterns

### Secure Decorators

```python
from functools import wraps
import time
import logging

# Rate limiting decorator
def rate_limit(max_calls=5, period=60):
    """
    Rate limit function calls.
    
    Args:
        max_calls: Maximum calls in period
        period: Time period in seconds
    """
    calls = []
    
    def decorator(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            now = time.time()
            # Clean old calls
            calls[:] = [c for c in calls if now - c < period]
            
            if len(calls) >= max_calls:
                raise Exception(f"Rate limit exceeded. Max {max_calls} calls per {period}s")
            
            calls.append(now)
            return func(*args, **kwargs)
        return wrapper
    return decorator

# Input validation decorator
def validate_input(schema):
    """Validate function arguments against a schema."""
    def decorator(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            # Validate args based on schema
            for i, value in enumerate(args):
                if i < len(schema):
                    validator = schema[i]
                    if not validator(value):
                        raise ValueError(f"Invalid argument at position {i}: {value}")
            
            # Validate kwargs
            for key, value in kwargs.items():
                if key in schema:
                    validator = schema[key]
                    if not validator(value):
                        raise ValueError(f"Invalid argument {key}: {value}")
            
            return func(*args, **kwargs)
        return wrapper
    return decorator

# Usage
@rate_limit(max_calls=10, period=60)
def login_attempt(username, password):
    return "Login successful"

def is_username_valid(username):
    return re.match(r'^[a-zA-Z0-9_]{3,20}$', username) is not None

@validate_input([is_username_valid])
def create_user(username, email):
    return f"User {username} created"
```

### Secure Class Patterns

```python
class SecureResource:
    """Resource with proper cleanup."""
    
    def __init__(self, resource_id, secret=None):
        self.resource_id = resource_id
        self._secret = secret  # Private attribute
        self._initialized = False
    
    def __enter__(self):
        """Context manager entry."""
        self._initialize()
        return self
    
    def __exit__(self, exc_type, exc_val, exc_tb):
        """Context manager exit."""
        self._cleanup()
    
    def _initialize(self):
        """Initialize resources."""
        if not self._initialized:
            # Initialize connections, allocate resources
            self._initialized = True
    
    def _cleanup(self):
        """Clean up resources."""
        if self._initialized:
            # Close connections, free resources
            self._initialized = False
    
    def __del__(self):
        """Destructor - fallback cleanup."""
        try:
            self._cleanup()
        except Exception:
            pass  # Avoid errors during garbage collection

# Property-based access control
class SecureUser:
    def __init__(self, username, password):
        self._username = username
        self._password_hash = self._hash_password(password)
        self._is_admin = False
    
    @property
    def username(self):
        """Read-only username."""
        return self._username
    
    @property
    def is_admin(self):
        """Admin status."""
        return self._is_admin
    
    @is_admin.setter
    def is_admin(self, value):
        """Only allow elevation with verification."""
        raise AttributeError("Cannot set admin status directly")
    
    def promote_to_admin(self, admin_password):
        """Promote user with verification."""
        if admin_password == "super_secret_admin":
            self._is_admin = True
            return True
        return False
    
    def _hash_password(self, password):
        """Hash password for storage."""
        import hashlib
        return hashlib.sha256(password.encode()).hexdigest()
```

---

## C.10 Testing Security

### Security Tests

```python
import pytest
import time

class TestSecurity:
    def test_rate_limiting(self):
        """Test rate limiting functionality."""
        from app.security import rate_limited_function
        
        # Should succeed
        for _ in range(5):
            result = rate_limited_function()
            assert result is not None
        
        # Should fail on 6th attempt
        with pytest.raises(Exception, match="Rate limit exceeded"):
            rate_limited_function()
    
    def test_input_validation(self):
        """Test input validation."""
        from app.security import validate_input
        
        with pytest.raises(ValueError, match="Invalid argument"):
            validate_input_schema("invalid_input")
    
    def test_sql_injection_prevention(self):
        """Test SQL injection prevention."""
        from app.security import safe_query
        
        malicious_input = "admin' OR '1'='1"
        result = safe_query(malicious_input)
        
        # Should return no results or escape properly
        assert "OR '1'='1" not in str(result)
    
    def test_xss_prevention(self):
        """Test XSS prevention."""
        from app.security import escape_html
        
        malicious_input = "<script>alert('XSS')</script>"
        escaped = escape_html(malicious_input)
        
        assert "<script>" not in escaped
        assert "&lt;script&gt;" in escaped
    
    def test_password_strength(self):
        """Test password strength requirements."""
        from app.security import validate_password
        
        weak_passwords = ['password', '123456', 'qwerty', 'abcdef']
        for password in weak_passwords:
            assert not validate_password(password)
        
        strong_password = 'Str0ngP@ssw0rd!2024'
        assert validate_password(strong_password)
```

---

## C.11 Security Checklist

### Development Phase

- [ ] Use virtual environments
- [ ] Pin dependency versions
- [ ] Run security scanners (pip-audit, safety)
- [ ] Enable debug mode only in development
- [ ] Use environment variables for secrets
- [ ] Validate all user input
- [ ] Parameterize SQL queries
- [ ] Escape HTML output
- [ ] Use CSRF protection in forms
- [ ] Implement rate limiting

### Authentication

- [ ] Use strong password hashing (bcrypt/Argon2)
- [ ] Implement rate limiting on login
- [ ] Use secure session management
- [ ] Set session timeout
- [ ] Implement multi-factor authentication
- [ ] Use HTTPS for all authentication
- [ ] Secure password reset flow
- [ ] Implement account lockout

### Data Protection

- [ ] Encrypt sensitive data at rest
- [ ] Use TLS/SSL for data in transit
- [ ] Redact sensitive data in logs
- [ ] Implement data retention policies
- [ ] Secure backup procedures
- [ ] Use secure deletion for sensitive data

### Deployment

- [ ] Use HTTPS in production
- [ ] Secure SSL/TLS configuration
- [ ] Disable debug mode
- [ ] Set secure cookie flags
- [ ] Use Content Security Policy
- [ ] Implement proper error handling
- [ ] Use a web application firewall
- [ ] Regular security updates

### Monitoring

- [ ] Log security events
- [ ] Implement alerting
- [ ] Monitor for suspicious activity
- [ ] Regular security audits
- [ ] Penetration testing
- [ ] Vulnerability scanning

---

## C.12 Common Vulnerabilities (OWASP Top 10)

| Vulnerability | Prevention |
|---------------|------------|
| **Injection** | Parameterized queries, input validation |
| **Broken Authentication** | Strong password hashing, MFA, session management |
| **Sensitive Data Exposure** | Encryption at rest and in transit |
| **XXE** | Disable external entity processing |
| **Broken Access Control** | Implement proper authorization checks |
| **Security Misconfiguration** | Secure defaults, regular audits |
| **XSS** | Output encoding, CSP headers |
| **Insecure Deserialization** | Validate input, use safe serialization |
| **Vulnerable Components** | Regular updates, dependency scanning |
| **Insufficient Logging** | Comprehensive logging, monitoring |

---

```
[COMPLETED: Appendix C - Security Best Practices]
