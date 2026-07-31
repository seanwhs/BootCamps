# Appendix C: Complete Technical Implementation Reference

## Overview

This appendix provides the complete technical implementation reference for the Enterprise Cybersecurity Program, including code patterns, deployment configurations, security controls implementation, and automation scripts. This serves as the hands-on implementation guide for building the entire program.

---

## C.1: Common Implementation Patterns

### C.1.1: Python Security Library

**File:** `shared/security_lib.py`

```python
#!/usr/bin/env python3
"""
Common Security Library

This module provides shared security utilities used across the entire
Enterprise Cybersecurity Program.
"""

import json
import datetime
import hashlib
import secrets
import re
import os
import base64
from typing import Dict, List, Optional, Any, Tuple
from dataclasses import dataclass, field
from enum import Enum
import logging
from cryptography.fernet import Fernet
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.kdf.pbkdf2 import PBKDF2HMAC

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)


class SecurityUtils:
    """
    Security utilities for encryption, hashing, and validation.
    """
    
    @staticmethod
    def generate_key() -> str:
        """
        Generate a secure encryption key.
        
        Returns:
            Base64 encoded key
        """
        return Fernet.generate_key().decode()
    
    @staticmethod
    def encrypt_data(data: str, key: str) -> str:
        """
        Encrypt data using Fernet.
        
        Args:
            data: Data to encrypt
            key: Encryption key
            
        Returns:
            Encrypted data as string
        """
        try:
            cipher = Fernet(key.encode())
            encrypted = cipher.encrypt(data.encode())
            return encrypted.decode()
        except Exception as e:
            logger.error(f"Encryption failed: {e}")
            raise
    
    @staticmethod
    def decrypt_data(encrypted_data: str, key: str) -> str:
        """
        Decrypt data using Fernet.
        
        Args:
            encrypted_data: Data to decrypt
            key: Encryption key
            
        Returns:
            Decrypted data as string
        """
        try:
            cipher = Fernet(key.encode())
            decrypted = cipher.decrypt(encrypted_data.encode())
            return decrypted.decode()
        except Exception as e:
            logger.error(f"Decryption failed: {e}")
            raise
    
    @staticmethod
    def hash_password(password: str) -> str:
        """
        Hash a password using PBKDF2.
        
        Args:
            password: Plaintext password
            
        Returns:
            Hashed password string
        """
        salt = secrets.token_bytes(16)
        kdf = PBKDF2HMAC(
            algorithm=hashes.SHA256(),
            length=32,
            salt=salt,
            iterations=100000,
        )
        key = base64.urlsafe_b64encode(kdf.derive(password.encode()))
        return f"{salt.hex()}:{key.decode()}"
    
    @staticmethod
    def verify_password(password: str, password_hash: str) -> bool:
        """
        Verify a password against its hash.
        
        Args:
            password: Plaintext password
            password_hash: Stored password hash
            
        Returns:
            True if password matches
        """
        try:
            salt_hex, key = password_hash.split(':')
            salt = bytes.fromhex(salt_hex)
            kdf = PBKDF2HMAC(
                algorithm=hashes.SHA256(),
                length=32,
                salt=salt,
                iterations=100000,
            )
            computed = base64.urlsafe_b64encode(kdf.derive(password.encode())).decode()
            return computed == key
        except Exception:
            return False
    
    @staticmethod
    def validate_password_strength(password: str) -> Tuple[bool, List[str]]:
        """
        Validate password strength.
        
        Args:
            password: Password to validate
            
        Returns:
            Tuple of (is_valid, violations)
        """
        violations = []
        
        if len(password) < 16:
            violations.append("Password must be at least 16 characters")
        if not re.search(r'[A-Z]', password):
            violations.append("Password must contain at least one uppercase letter")
        if not re.search(r'[a-z]', password):
            violations.append("Password must contain at least one lowercase letter")
        if not re.search(r'[0-9]', password):
            violations.append("Password must contain at least one number")
        if not re.search(r'[!@#$%^&*(),.?":{}|<>]', password):
            violations.append("Password must contain at least one special character")
        
        # Common password check
        common_passwords = [
            'password', 'admin', 'letmein', '12345678', 'qwerty',
            'password123', 'admin123', 'welcome'
        ]
        if password.lower() in common_passwords:
            violations.append("Password is too common")
        
        return len(violations) == 0, violations
    
    @staticmethod
    def generate_secure_token(length: int = 32) -> str:
        """
        Generate a secure random token.
        
        Args:
            length: Token length
            
        Returns:
            Secure token
        """
        return secrets.token_urlsafe(length)
    
    @staticmethod
    def generate_strong_password() -> str:
        """
        Generate a strong random password.
        
        Returns:
            Strong password
        """
        alphabet = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*"
        return ''.join(secrets.choice(alphabet) for _ in range(24))
    
    @staticmethod
    def calculate_hash(data: str) -> str:
        """
        Calculate SHA-256 hash of data.
        
        Args:
            data: Data to hash
            
        Returns:
            SHA-256 hash
        """
        return hashlib.sha256(data.encode()).hexdigest()
    
    @staticmethod
    def validate_email(email: str) -> bool:
        """
        Validate email address format.
        
        Args:
            email: Email to validate
            
        Returns:
            True if valid
        """
        pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
        return bool(re.match(pattern, email))
    
    @staticmethod
    def sanitize_input(input_data: str) -> str:
        """
        Sanitize input to prevent injection.
        
        Args:
            input_data: Data to sanitize
            
        Returns:
            Sanitized data
        """
        # Remove potentially dangerous characters
        return re.sub(r'[<>\'";]', '', input_data)
    
    @staticmethod
    def validate_json_schema(data: Dict, schema: Dict) -> Tuple[bool, str]:
        """
        Validate data against a JSON schema.
        
        Args:
            data: Data to validate
            schema: Schema to validate against
            
        Returns:
            Tuple of (is_valid, error_message)
        """
        # This is a simplified validation. In production, use a proper JSON schema validator
        try:
            required_fields = schema.get('required', [])
            for field in required_fields:
                if field not in data:
                    return False, f"Missing required field: {field}"
            
            # Check field types
            properties = schema.get('properties', {})
            for field, value in data.items():
                if field in properties:
                    field_schema = properties[field]
                    field_type = field_schema.get('type')
                    if field_type:
                        if field_type == 'string' and not isinstance(value, str):
                            return False, f"Field {field} must be string"
                        elif field_type == 'number' and not isinstance(value, (int, float)):
                            return False, f"Field {field} must be number"
                        elif field_type == 'integer' and not isinstance(value, int):
                            return False, f"Field {field} must be integer"
                        elif field_type == 'boolean' and not isinstance(value, bool):
                            return False, f"Field {field} must be boolean"
                        elif field_type == 'array' and not isinstance(value, list):
                            return False, f"Field {field} must be array"
                        elif field_type == 'object' and not isinstance(value, dict):
                            return False, f"Field {field} must be object"
            
            return True, ""
        except Exception as e:
            return False, f"Validation error: {e}"


class AuditLogger:
    """
    Security audit logger.
    """
    
    def __init__(self, log_dir: str = "./audit_logs"):
        """
        Initialize audit logger.
        
        Args:
            log_dir: Directory for audit logs
        """
        self.log_dir = log_dir
        self._ensure_log_dir()
    
    def _ensure_log_dir(self) -> None:
        """Create log directory if it doesn't exist."""
        os.makedirs(self.log_dir, exist_ok=True)
    
    def log(self, action: str, user_id: str, details: Dict) -> None:
        """
        Log an audit event.
        
        Args:
            action: Action performed
            user_id: User performing action
            details: Event details
        """
        log_entry = {
            "timestamp": datetime.datetime.utcnow().isoformat(),
            "action": action,
            "user_id": user_id,
            "details": details
        }
        
        # Log to daily file
        date_str = datetime.datetime.utcnow().strftime("%Y-%m-%d")
        log_file = f"{self.log_dir}/audit-{date_str}.jsonl"
        
        with open(log_file, 'a') as f:
            f.write(json.dumps(log_entry) + "\n")
        
        # Also log to standard logging
        logger.info(f"AUDIT: {action} - User: {user_id}")
    
    def query(self, start_date: str, end_date: str, 
              action: Optional[str] = None, 
              user_id: Optional[str] = None) -> List[Dict]:
        """
        Query audit logs.
        
        Args:
            start_date: Start date (YYYY-MM-DD)
            end_date: End date (YYYY-MM-DD)
            action: Optional action filter
            user_id: Optional user filter
            
        Returns:
            List of audit entries
        """
        results = []
        
        # Generate list of dates to check
        start = datetime.datetime.fromisoformat(start_date)
        end = datetime.datetime.fromisoformat(end_date)
        
        current = start
        while current <= end:
            date_str = current.strftime("%Y-%m-%d")
            log_file = f"{self.log_dir}/audit-{date_str}.jsonl"
            
            if os.path.exists(log_file):
                with open(log_file, 'r') as f:
                    for line in f:
                        try:
                            entry = json.loads(line.strip())
                            # Apply filters
                            if action and entry.get('action') != action:
                                continue
                            if user_id and entry.get('user_id') != user_id:
                                continue
                            results.append(entry)
                        except json.JSONDecodeError:
                            continue
            
            current += datetime.timedelta(days=1)
        
        return sorted(results, key=lambda x: x['timestamp'])


class RateLimiter:
    """
    Rate limiter for API endpoints.
    """
    
    def __init__(self, max_requests: int, time_window: int):
        """
        Initialize rate limiter.
        
        Args:
            max_requests: Maximum requests in time window
            time_window: Time window in seconds
        """
        self.max_requests = max_requests
        self.time_window = time_window
        self.requests: Dict[str, List[float]] = {}
    
    def is_allowed(self, key: str) -> bool:
        """
        Check if request is allowed.
        
        Args:
            key: Unique identifier (user ID, IP, etc.)
            
        Returns:
            True if request is allowed
        """
        now = datetime.datetime.utcnow().timestamp()
        
        if key not in self.requests:
            self.requests[key] = []
        
        # Remove old requests
        cutoff = now - self.time_window
        self.requests[key] = [t for t in self.requests[key] if t > cutoff]
        
        # Check if limit reached
        if len(self.requests[key]) >= self.max_requests:
            return False
        
        # Add current request
        self.requests[key].append(now)
        return True
    
    def get_remaining(self, key: str) -> int:
        """
        Get remaining request count.
        
        Args:
            key: Unique identifier
            
        Returns:
            Remaining requests in current window
        """
        now = datetime.datetime.utcnow().timestamp()
        
        if key not in self.requests:
            return self.max_requests
        
        cutoff = now - self.time_window
        current_requests = [t for t in self.requests[key] if t > cutoff]
        
        return max(0, self.max_requests - len(current_requests))


class TokenManager:
    """
    Token management for authentication and authorization.
    """
    
    def __init__(self, secret_key: str):
        """
        Initialize token manager.
        
        Args:
            secret_key: Secret key for token generation
        """
        self.secret_key = secret_key
        self.tokens: Dict[str, Dict] = {}
    
    def generate_token(self, user_id: str, expires_in: int = 3600) -> str:
        """
        Generate a new token.
        
        Args:
            user_id: User ID
            expires_in: Expiration time in seconds
            
        Returns:
            Generated token
        """
        token = secrets.token_urlsafe(32)
        expires_at = datetime.datetime.utcnow().timestamp() + expires_in
        
        self.tokens[token] = {
            'user_id': user_id,
            'expires_at': expires_at,
            'created_at': datetime.datetime.utcnow().timestamp()
        }
        
        return token
    
    def validate_token(self, token: str) -> Optional[str]:
        """
        Validate a token.
        
        Args:
            token: Token to validate
            
        Returns:
            User ID if valid, None otherwise
        """
        if token not in self.tokens:
            return None
        
        token_data = self.tokens[token]
        
        if datetime.datetime.utcnow().timestamp() > token_data['expires_at']:
            del self.tokens[token]
            return None
        
        return token_data['user_id']
    
    def revoke_token(self, token: str) -> bool:
        """
        Revoke a token.
        
        Args:
            token: Token to revoke
            
        Returns:
            True if revoked
        """
        if token in self.tokens:
            del self.tokens[token]
            return True
        return False
    
    def revoke_all_user_tokens(self, user_id: str) -> int:
        """
        Revoke all tokens for a user.
        
        Args:
            user_id: User ID
            
        Returns:
            Number of tokens revoked
        """
        to_revoke = []
        for token, data in self.tokens.items():
            if data['user_id'] == user_id:
                to_revoke.append(token)
        
        for token in to_revoke:
            del self.tokens[token]
        
        return len(to_revoke)
```

### C.1.2: Database Utilities

**File:** `shared/db_utils.py`

```python
#!/usr/bin/env python3
"""
Database Utilities

This module provides database utilities for the security program.
"""

import json
import datetime
import sqlite3
from typing import Dict, List, Optional, Any, Tuple
import os
import logging

logger = logging.getLogger(__name__)


class SecurityDatabase:
    """
    SQLite-based security database for the security program.
    """
    
    def __init__(self, db_path: str = "./security.db"):
        """
        Initialize the security database.
        
        Args:
            db_path: Path to SQLite database
        """
        self.db_path = db_path
        self._initialize_database()
    
    def _initialize_database(self) -> None:
        """Initialize database schema."""
        with sqlite3.connect(self.db_path) as conn:
            cursor = conn.cursor()
            
            # Users table
            cursor.execute("""
                CREATE TABLE IF NOT EXISTS users (
                    user_id TEXT PRIMARY KEY,
                    username TEXT UNIQUE NOT NULL,
                    email TEXT UNIQUE NOT NULL,
                    password_hash TEXT NOT NULL,
                    enabled INTEGER DEFAULT 1,
                    mfa_enabled INTEGER DEFAULT 0,
                    mfa_methods TEXT,
                    created_at TEXT,
                    last_login TEXT,
                    failed_attempts INTEGER DEFAULT 0,
                    locked_until TEXT,
                    attributes TEXT
                )
            """)
            
            # Roles table
            cursor.execute("""
                CREATE TABLE IF NOT EXISTS roles (
                    role_id TEXT PRIMARY KEY,
                    name TEXT UNIQUE NOT NULL,
                    description TEXT,
                    permissions TEXT
                )
            """)
            
            # User roles table
            cursor.execute("""
                CREATE TABLE IF NOT EXISTS user_roles (
                    user_id TEXT,
                    role_id TEXT,
                    assigned_at TEXT,
                    PRIMARY KEY (user_id, role_id),
                    FOREIGN KEY (user_id) REFERENCES users(user_id),
                    FOREIGN KEY (role_id) REFERENCES roles(role_id)
                )
            """)
            
            # Audit log table
            cursor.execute("""
                CREATE TABLE IF NOT EXISTS audit_log (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    timestamp TEXT,
                    action TEXT,
                    user_id TEXT,
                    details TEXT
                )
            """)
            
            # Vendors table
            cursor.execute("""
                CREATE TABLE IF NOT EXISTS vendors (
                    vendor_id TEXT PRIMARY KEY,
                    name TEXT NOT NULL,
                    description TEXT,
                    category TEXT,
                    status TEXT,
                    tier INTEGER,
                    url TEXT,
                    contact TEXT,
                    contract_start TEXT,
                    contract_end TEXT,
                    risk_score REAL,
                    monitored_since TEXT,
                    attributes TEXT
                )
            """)
            
            # Vendor assessments table
            cursor.execute("""
                CREATE TABLE IF NOT EXISTS vendor_assessments (
                    assessment_id TEXT PRIMARY KEY,
                    vendor_id TEXT,
                    assessment_type TEXT,
                    timestamp TEXT,
                    results TEXT,
                    FOREIGN KEY (vendor_id) REFERENCES vendors(vendor_id)
                )
            """)
            
            # SBOM table
            cursor.execute("""
                CREATE TABLE IF NOT EXISTS sboms (
                    sbom_id TEXT PRIMARY KEY,
                    name TEXT NOT NULL,
                    version TEXT NOT NULL,
                    format TEXT,
                    created TEXT,
                    updated TEXT,
                    metadata TEXT
                )
            """)
            
            # SBOM components table
            cursor.execute("""
                CREATE TABLE IF NOT EXISTS sbom_components (
                    component_id TEXT PRIMARY KEY,
                    sbom_id TEXT,
                    name TEXT NOT NULL,
                    version TEXT NOT NULL,
                    vendor TEXT,
                    description TEXT,
                    status TEXT,
                    licenses TEXT,
                    dependencies TEXT,
                    vulnerabilities TEXT,
                    FOREIGN KEY (sbom_id) REFERENCES sboms(sbom_id)
                )
            """)
            
            # Incidents table
            cursor.execute("""
                CREATE TABLE IF NOT EXISTS incidents (
                    incident_id TEXT PRIMARY KEY,
                    title TEXT NOT NULL,
                    description TEXT,
                    severity TEXT,
                    status TEXT,
                    reported_at TEXT,
                    updated_at TEXT,
                    reported_by TEXT,
                    assigned_to TEXT,
                    resolution TEXT,
                    lessons_learned TEXT
                )
            """)
            
            # Incident logs table
            cursor.execute("""
                CREATE TABLE IF NOT EXISTS incident_logs (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    incident_id TEXT,
                    timestamp TEXT,
                    user_id TEXT,
                    action TEXT,
                    details TEXT,
                    FOREIGN KEY (incident_id) REFERENCES incidents(incident_id)
                )
            """)
            
            conn.commit()
    
    def execute_query(self, query: str, params: tuple = ()) -> List[Dict]:
        """
        Execute a SELECT query and return results.
        
        Args:
            query: SQL query
            params: Query parameters
            
        Returns:
            List of dictionaries representing rows
        """
        with sqlite3.connect(self.db_path) as conn:
            conn.row_factory = sqlite3.Row
            cursor = conn.cursor()
            cursor.execute(query, params)
            results = cursor.fetchall()
            return [dict(row) for row in results]
    
    def execute_write(self, query: str, params: tuple = ()) -> int:
        """
        Execute a write query (INSERT, UPDATE, DELETE).
        
        Args:
            query: SQL query
            params: Query parameters
            
        Returns:
            Number of rows affected
        """
        with sqlite3.connect(self.db_path) as conn:
            cursor = conn.cursor()
            cursor.execute(query, params)
            conn.commit()
            return cursor.rowcount
    
    def insert_user(self, user_data: Dict) -> bool:
        """
        Insert a user into the database.
        
        Args:
            user_data: User data dictionary
            
        Returns:
            True if successful
        """
        try:
            query = """
                INSERT INTO users (
                    user_id, username, email, password_hash, enabled,
                    mfa_enabled, mfa_methods, created_at, last_login,
                    failed_attempts, locked_until, attributes
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """
            params = (
                user_data.get('user_id'),
                user_data.get('username'),
                user_data.get('email'),
                user_data.get('password_hash'),
                user_data.get('enabled', 1),
                user_data.get('mfa_enabled', 0),
                json.dumps(user_data.get('mfa_methods', [])),
                user_data.get('created_at', datetime.datetime.utcnow().isoformat()),
                user_data.get('last_login'),
                user_data.get('failed_attempts', 0),
                user_data.get('locked_until'),
                json.dumps(user_data.get('attributes', {}))
            )
            return self.execute_write(query, params) > 0
        except sqlite3.IntegrityError as e:
            logger.error(f"Failed to insert user: {e}")
            return False
    
    def get_user_by_username(self, username: str) -> Optional[Dict]:
        """
        Get a user by username.
        
        Args:
            username: Username
            
        Returns:
            User data dictionary or None
        """
        results = self.execute_query(
            "SELECT * FROM users WHERE username = ?",
            (username,)
        )
        if results:
            user = results[0]
            # Parse JSON fields
            if user.get('mfa_methods'):
                user['mfa_methods'] = json.loads(user['mfa_methods'])
            else:
                user['mfa_methods'] = []
            if user.get('attributes'):
                user['attributes'] = json.loads(user['attributes'])
            else:
                user['attributes'] = {}
            return user
        return None
    
    def get_user_by_email(self, email: str) -> Optional[Dict]:
        """
        Get a user by email.
        
        Args:
            email: Email address
            
        Returns:
            User data dictionary or None
        """
        results = self.execute_query(
            "SELECT * FROM users WHERE email = ?",
            (email,)
        )
        if results:
            user = results[0]
            if user.get('mfa_methods'):
                user['mfa_methods'] = json.loads(user['mfa_methods'])
            else:
                user['mfa_methods'] = []
            if user.get('attributes'):
                user['attributes'] = json.loads(user['attributes'])
            else:
                user['attributes'] = {}
            return user
        return None
    
    def update_user(self, user_id: str, updates: Dict) -> bool:
        """
        Update a user.
        
        Args:
            user_id: User ID
            updates: Fields to update
            
        Returns:
            True if successful
        """
        # Build SET clause
        set_clauses = []
        params = []
        for key, value in updates.items():
            # Handle JSON fields
            if key in ['mfa_methods', 'attributes']:
                set_clauses.append(f"{key} = ?")
                params.append(json.dumps(value))
            else:
                set_clauses.append(f"{key} = ?")
                params.append(value)
        
        params.append(user_id)
        
        query = f"UPDATE users SET {', '.join(set_clauses)} WHERE user_id = ?"
        return self.execute_write(query, tuple(params)) > 0
    
    def insert_audit_log(self, entry: Dict) -> bool:
        """
        Insert an audit log entry.
        
        Args:
            entry: Audit entry dictionary
            
        Returns:
            True if successful
        """
        query = """
            INSERT INTO audit_log (timestamp, action, user_id, details)
            VALUES (?, ?, ?, ?)
        """
        params = (
            entry.get('timestamp', datetime.datetime.utcnow().isoformat()),
            entry.get('action'),
            entry.get('user_id'),
            json.dumps(entry.get('details', {}))
        )
        return self.execute_write(query, params) > 0
    
    def get_audit_logs(self, start_date: str, end_date: str,
                      action: Optional[str] = None,
                      user_id: Optional[str] = None) -> List[Dict]:
        """
        Get audit logs.
        
        Args:
            start_date: Start date (YYYY-MM-DD)
            end_date: End date (YYYY-MM-DD)
            action: Optional action filter
            user_id: Optional user filter
            
        Returns:
            List of audit entries
        """
        query = """
            SELECT * FROM audit_log
            WHERE timestamp >= ? AND timestamp <= ?
        """
        params = [start_date, end_date]
        
        if action:
            query += " AND action = ?"
            params.append(action)
        
        if user_id:
            query += " AND user_id = ?"
            params.append(user_id)
        
        query += " ORDER BY timestamp DESC"
        
        results = self.execute_query(query, tuple(params))
        for result in results:
            if result.get('details'):
                result['details'] = json.loads(result['details'])
        return results
```

### C.1.3: Common API Patterns

**File:** `shared/api_patterns.py`

```python
#!/usr/bin/env python3
"""
API Patterns

This module provides common API patterns for the security program.
"""

import json
import datetime
from typing import Dict, List, Optional, Any, Callable
from functools import wraps
import logging

logger = logging.getLogger(__name__)


class APIResponse:
    """
    Standardized API response format.
    """
    
    @staticmethod
    def success(data: Any = None, message: str = "Success") -> Dict:
        """
        Create a success response.
        
        Args:
            data: Response data
            message: Success message
            
        Returns:
            Response dictionary
        """
        return {
            "status": "success",
            "message": message,
            "data": data,
            "timestamp": datetime.datetime.utcnow().isoformat()
        }
    
    @staticmethod
    def error(message: str, code: str = "ERROR", details: Any = None) -> Dict:
        """
        Create an error response.
        
        Args:
            message: Error message
            code: Error code
            details: Error details
            
        Returns:
            Response dictionary
        """
        return {
            "status": "error",
            "message": message,
            "code": code,
            "details": details,
            "timestamp": datetime.datetime.utcnow().isoformat()
        }
    
    @staticmethod
    def not_found(resource: str) -> Dict:
        """
        Create a not found response.
        
        Args:
            resource: Resource type
            
        Returns:
            Response dictionary
        """
        return APIResponse.error(
            f"{resource} not found",
            "NOT_FOUND"
        )
    
    @staticmethod
    def unauthorized() -> Dict:
        """
        Create an unauthorized response.
        
        Returns:
            Response dictionary
        """
        return APIResponse.error(
            "Authentication required",
            "UNAUTHORIZED"
        )
    
    @staticmethod
    def forbidden() -> Dict:
        """
        Create a forbidden response.
        
        Returns:
            Response dictionary
        """
        return APIResponse.error(
            "Insufficient permissions",
            "FORBIDDEN"
        )
    
    @staticmethod
    def validation_error(errors: Dict) -> Dict:
        """
        Create a validation error response.
        
        Args:
            errors: Validation errors
            
        Returns:
            Response dictionary
        """
        return APIResponse.error(
            "Validation failed",
            "VALIDATION_ERROR",
            errors
        )


class APIEndpoint:
    """
    Base class for API endpoints.
    """
    
    def __init__(self):
        """Initialize endpoint."""
        self.logger = logging.getLogger(self.__class__.__name__)
    
    def handle_request(self, request: Dict) -> Dict:
        """
        Handle an API request.
        
        Args:
            request: Request dictionary
            
        Returns:
            Response dictionary
        """
        try:
            # Validate request
            if not self._validate_request(request):
                return APIResponse.validation_error(
                    {"request": "Invalid request format"}
                )
            
            # Process request
            return self._process_request(request)
        except Exception as e:
            self.logger.error(f"Request handling error: {e}")
            return APIResponse.error(
                "Internal server error",
                "INTERNAL_ERROR",
                str(e)
            )
    
    def _validate_request(self, request: Dict) -> bool:
        """
        Validate the request.
        
        Args:
            request: Request to validate
            
        Returns:
            True if valid
        """
        raise NotImplementedError
    
    def _process_request(self, request: Dict) -> Dict:
        """
        Process the request.
        
        Args:
            request: Request to process
            
        Returns:
            Response dictionary
        """
        raise NotImplementedError


def require_auth(func: Callable) -> Callable:
    """
    Decorator to require authentication.
    
    Args:
        func: Function to decorate
        
    Returns:
        Decorated function
    """
    @wraps(func)
    def wrapper(self, *args, **kwargs):
        # Check for authentication token
        request = kwargs.get('request', {})
        token = request.get('token')
        if not token:
            return APIResponse.unauthorized()
        
        # Validate token (implementation depends on your auth system)
        # For now, just check it exists
        if token:
            return func(self, *args, **kwargs)
        else:
            return APIResponse.unauthorized()
    
    return wrapper


def require_permission(permission: str) -> Callable:
    """
    Decorator to require a specific permission.
    
    Args:
        permission: Required permission
        
    Returns:
        Decorator function
    """
    def decorator(func: Callable) -> Callable:
        @wraps(func)
        def wrapper(self, *args, **kwargs):
            # Check for permission
            request = kwargs.get('request', {})
            user_permissions = request.get('permissions', [])
            
            if permission in user_permissions:
                return func(self, *args, **kwargs)
            else:
                return APIResponse.forbidden()
        
        return wrapper
    
    return decorator


class PaginationHelper:
    """
    Helper for paginated responses.
    """
    
    @staticmethod
    def paginate(data: List, page: int = 1, per_page: int = 20) -> Dict:
        """
        Paginate a list of data.
        
        Args:
            data: Full list of data
            page: Page number
            per_page: Items per page
            
        Returns:
            Paginated response
        """
        total = len(data)
        total_pages = (total + per_page - 1) // per_page
        start = (page - 1) * per_page
        end = min(start + per_page, total)
        
        return {
            "data": data[start:end],
            "pagination": {
                "page": page,
                "per_page": per_page,
                "total": total,
                "total_pages": total_pages,
                "has_next": page < total_pages,
                "has_previous": page > 1
            }
        }
```

---

## C.2: Infrastructure as Code Templates

### C.2.1: Terraform Security Module

**File:** `terraform/security_module/main.tf`

```hcl
# Terraform Security Module
# This module creates security resources across AWS

terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

# Security Group Module
module "security_groups" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  for_each = var.security_groups

  name        = each.key
  description = each.value.description
  vpc_id      = var.vpc_id

  ingress_rules = each.value.ingress_rules
  egress_rules  = each.value.egress_rules

  ingress_cidr_blocks = each.value.ingress_cidr_blocks
  egress_cidr_blocks  = each.value.egress_cidr_blocks

  tags = merge(var.tags, {
    Name = "sg-${each.key}"
  })
}

# IAM Security Module
module "iam_security" {
  source  = "terraform-aws-modules/iam/aws"
  version = "~> 5.0"

  for_each = var.iam_roles

  name        = each.key
  description = each.value.description
  path        = "/security/"

  assume_role_policy = each.value.assume_role_policy

  policies = each.value.policies

  tags = var.tags
}

# CloudTrail for Security Monitoring
resource "aws_cloudtrail" "security_trail" {
  name                          = "security-cloudtrail"
  s3_bucket_name               = var.cloudtrail_bucket
  include_global_service_events = true
  is_multi_region_trail        = true
  enable_log_file_validation   = true

  event_selector {
    read_write_type = "All"
    include_management_events = true

    data_resource {
      type = "AWS::S3::Object"
      values = ["arn:aws:s3:::${var.cloudtrail_bucket}/AWSLogs/${var.account_id}/*"]
    }
  }

  tags = var.tags
}

# Security Hub
resource "aws_securityhub_account" "security_hub" {
  enable_default_standards = true
}

# GuardDuty
resource "aws_guardduty_detector" "guardduty" {
  enable = true
  depends_on = [aws_securityhub_account.security_hub]
}

# GuardDuty Threat Intel Sets
resource "aws_guardduty_threatintelset" "threat_intel" {
  detector_id = aws_guardduty_detector.guardduty.id
  name        = "custom-threat-intel"
  format      = "TXT"
  location    = var.threat_intel_s3_location
  activate    = true
}

# Config for Security Monitoring
resource "aws_config_configuration_recorder" "security_config" {
  name     = "security-config-recorder"
  role_arn = aws_iam_role.config_role.arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = true
  }
}

resource "aws_config_delivery_channel" "security_channel" {
  name           = "security-config-channel"
  s3_bucket_name = var.config_bucket
  depends_on     = [aws_config_configuration_recorder.security_config]
}

# IAM Role for Config
resource "aws_iam_role" "config_role" {
  name = "security-config-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "config.amazonaws.com"
        }
      }
    ]
  })
}

# Config Rules
resource "aws_config_config_rule" "security_rules" {
  for_each = var.config_rules

  name        = each.key
  description = each.value.description

  source {
    owner             = "AWS"
    source_identifier = each.value.source_identifier
  }

  scope {
    compliance_resource_types = each.value.resource_types
  }

  depends_on = [
    aws_config_configuration_recorder.security_config
  ]
}

# S3 Bucket for Config
resource "aws_s3_bucket" "config_bucket" {
  bucket = var.config_bucket
  acl    = "private"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = var.tags
}

# S3 Bucket for CloudTrail
resource "aws_s3_bucket" "cloudtrail_bucket" {
  bucket = var.cloudtrail_bucket
  acl    = "private"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  lifecycle {
    transition {
      days = 30
      storage_class = "STANDARD_IA"
    }
    transition {
      days = 90
      storage_class = "GLACIER"
    }
    expiration {
      days = 365
    }
  }

  tags = var.tags
}

# Outputs
output "security_group_ids" {
  value = {
    for k, sg in module.security_groups : k => sg.security_group_id
  }
}

output "iam_role_arns" {
  value = {
    for k, role in module.iam_security : k => role.iam_role_arn
  }
}
```

**File:** `terraform/security_module/variables.tf`

```hcl
# Terraform Security Module Variables

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "account_id" {
  description = "AWS Account ID"
  type        = string
}

variable "security_groups" {
  description = "Security group configurations"
  type = map(object({
    description           = string
    ingress_rules         = list(string)
    egress_rules          = list(string)
    ingress_cidr_blocks   = list(string)
    egress_cidr_blocks    = list(string)
  }))
  default = {
    "web_security_group" = {
      description         = "Security group for web tier"
      ingress_rules       = ["https-443-tcp", "http-80-tcp"]
      egress_rules        = ["all-all"]
      ingress_cidr_blocks = ["0.0.0.0/0"]
      egress_cidr_blocks  = ["0.0.0.0/0"]
    }
    "app_security_group" = {
      description         = "Security group for application tier"
      ingress_rules       = ["ssh-tcp", "http-80-tcp"]
      egress_rules        = ["all-all"]
      ingress_cidr_blocks = ["10.0.0.0/8"]
      egress_cidr_blocks  = ["10.0.0.0/8"]
    }
    "db_security_group" = {
      description         = "Security group for database tier"
      ingress_rules       = ["postgresql-tcp", "mysql-tcp"]
      egress_rules        = ["all-all"]
      ingress_cidr_blocks = ["10.0.0.0/8"]
      egress_cidr_blocks  = ["10.0.0.0/8"]
    }
  }
}

variable "iam_roles" {
  description = "IAM role configurations"
  type = map(object({
    description         = string
    assume_role_policy  = string
    policies           = list(object({
      name   = string
      policy = string
    }))
  }))
  default = {}
}

variable "cloudtrail_bucket" {
  description = "S3 bucket name for CloudTrail logs"
  type        = string
}

variable "config_bucket" {
  description = "S3 bucket name for Config logs"
  type        = string
}

variable "threat_intel_s3_location" {
  description = "S3 location for threat intel sets"
  type        = string
  default     = ""
}

variable "config_rules" {
  description = "Config rules configuration"
  type = map(object({
    description        = string
    source_identifier  = string
    resource_types     = list(string)
  }))
  default = {
    "cloudtrail_enabled" = {
      description       = "CloudTrail is enabled"
      source_identifier = "CLOUD_TRAIL_ENABLED"
      resource_types    = ["AWS::CloudTrail::Trail"]
    }
    "encrypted_volumes" = {
      description       = "EBS volumes are encrypted"
      source_identifier = "ENCRYPTED_VOLUMES"
      resource_types    = ["AWS::EC2::Volume"]
    }
    "security_group_restricted" = {
      description       = "Security groups restrict SSH access"
      source_identifier = "INCOMING_SSH_DISABLED"
      resource_types    = ["AWS::EC2::SecurityGroup"]
    }
    "s3_bucket_public_access" = {
      description       = "S3 buckets are not publicly accessible"
      source_identifier = "S3_BUCKET_PUBLIC_READ_PROHIBITED"
      resource_types    = ["AWS::S3::Bucket"]
    }
  }
}

variable "tags" {
  description = "Tags for all resources"
  type        = map(string)
  default = {
    Environment = "security"
    ManagedBy   = "terraform"
  }
}
```

### C.2.2: AWS CloudFormation Security Template

**File:** `cloudformation/security-stack.yaml`

```yaml
---
AWSTemplateFormatVersion: '2010-09-09'
Description: 'Enterprise Security Stack - CloudFormation Template'

Parameters:
  EnvironmentName:
    Type: String
    Default: 'security'
    Description: 'Environment name'
  
  VpcId:
    Type: AWS::EC2::VPC::Id
    Description: 'VPC ID for security resources'
  
  SubnetIds:
    Type: List<AWS::EC2::Subnet::Id>
    Description: 'Subnet IDs for security resources'

Resources:
  # Security Monitoring Stack
  SecurityHub:
    Type: AWS::SecurityHub::Hub
    Properties:
      EnableDefaultStandards: true
  
  GuardDuty:
    Type: AWS::GuardDuty::Detector
    Properties:
      Enable: true
      FindingPublishingFrequency: 'FIFTEEN_MINUTES'
  
  # CloudTrail for auditing
  SecurityTrail:
    Type: AWS::CloudTrail::Trail
    Properties:
      IsLogging: true
      IsMultiRegionTrail: true
      IncludeGlobalServiceEvents: true
      EnableLogFileValidation: true
      S3BucketName: !Ref AuditBucket
  
  # Audit bucket
  AuditBucket:
    Type: AWS::S3::Bucket
    Properties:
      VersioningConfiguration:
        Status: Enabled
      BucketEncryption:
        ServerSideEncryptionConfiguration:
          - ServerSideEncryptionByDefault:
              SSEAlgorithm: AES256
      PublicAccessBlockConfiguration:
        BlockPublicAcls: true
        BlockPublicPolicy: true
        IgnorePublicAcls: true
        RestrictPublicBuckets: true
  
  # Config recorder
  ConfigRecorder:
    Type: AWS::Config::ConfigurationRecorder
    Properties:
      Name: 'security-config-recorder'
      RoleARN: !GetAtt ConfigRole.Arn
      RecordingGroup:
        AllSupported: true
        IncludeGlobalResourceTypes: true
  
  ConfigDeliveryChannel:
    Type: AWS::Config::DeliveryChannel
    Properties:
      Name: 'security-config-channel'
      S3BucketName: !Ref ConfigBucket
    DependsOn:
      - ConfigRecorder
  
  ConfigBucket:
    Type: AWS::S3::Bucket
    Properties:
      VersioningConfiguration:
        Status: Enabled
      BucketEncryption:
        ServerSideEncryptionConfiguration:
          - ServerSideEncryptionByDefault:
              SSEAlgorithm: AES256
      PublicAccessBlockConfiguration:
        BlockPublicAcls: true
        BlockPublicPolicy: true
        IgnorePublicAcls: true
        RestrictPublicBuckets: true
  
  # IAM roles for security services
  ConfigRole:
    Type: AWS::IAM::Role
    Properties:
      AssumeRolePolicyDocument:
        Version: '2012-10-17'
        Statement:
          - Effect: Allow
            Principal:
              Service: config.amazonaws.com
            Action: sts:AssumeRole
      ManagedPolicyArns:
        - arn:aws:iam::aws:policy/service-role/AWSConfigRole
  
  # Security groups
  WebSecurityGroup:
    Type: AWS::EC2::SecurityGroup
    Properties:
      GroupDescription: 'Web tier security group'
      VpcId: !Ref VpcId
      SecurityGroupIngress:
        - IpProtocol: tcp
          FromPort: 443
          ToPort: 443
          CidrIp: 0.0.0.0/0
        - IpProtocol: tcp
          FromPort: 80
          ToPort: 80
          CidrIp: 0.0.0.0/0
  
  AppSecurityGroup:
    Type: AWS::EC2::SecurityGroup
    Properties:
      GroupDescription: 'Application tier security group'
      VpcId: !Ref VpcId
      SecurityGroupIngress:
        - IpProtocol: tcp
          FromPort: 22
          ToPort: 22
          CidrIp: 10.0.0.0/8
        - IpProtocol: tcp
          FromPort: 8080
          ToPort: 8080
          CidrIp: 10.0.0.0/8
  
  DbSecurityGroup:
    Type: AWS::EC2::SecurityGroup
    Properties:
      GroupDescription: 'Database tier security group'
      VpcId: !Ref VpcId
      SecurityGroupIngress:
        - IpProtocol: tcp
          FromPort: 5432
          ToPort: 5432
          CidrIp: 10.0.0.0/8
        - IpProtocol: tcp
          FromPort: 3306
          ToPort: 3306
          CidrIp: 10.0.0.0/8

  # KMS key for encryption
  SecurityKey:
    Type: AWS::KMS::Key
    Properties:
      Description: 'Security encryption key'
      KeyPolicy:
        Version: '2012-10-17'
        Statement:
          - Sid: Enable IAM User Permissions
            Effect: Allow
            Principal:
              AWS: !Sub arn:aws:iam::${AWS::AccountId}:root
            Action: kms:*
            Resource: '*'

# Outputs
Outputs:
  SecurityHubArn:
    Description: 'Security Hub ARN'
    Value: !GetAtt SecurityHub.Arn
  
  GuardDutyDetectorId:
    Description: 'GuardDuty Detector ID'
    Value: !Ref GuardDuty
  
  SecurityKeyId:
    Description: 'KMS Key ID'
    Value: !Ref SecurityKey
  
  WebSecurityGroupId:
    Description: 'Web Security Group ID'
    Value: !Ref WebSecurityGroup
  
  AppSecurityGroupId:
    Description: 'Application Security Group ID'
    Value: !Ref AppSecurityGroup
  
  DbSecurityGroupId:
    Description: 'Database Security Group ID'
    Value: !Ref DbSecurityGroup
```

---

## C.3: Automation Scripts

### C.3.1: Security Dashboard Automation

**File:** `automation/dashboard_generator.py`

```python
#!/usr/bin/env python3
"""
Security Dashboard Generator

This script generates security dashboards from various data sources.
"""

import json
import datetime
import os
from typing import Dict, List, Any
import sys

# Add shared directory to path
sys.path.append(os.path.join(os.path.dirname(__file__), '..', 'shared'))
from security_lib import SecurityUtils, AuditLogger


class DashboardGenerator:
    """
    Generate security dashboards.
    """
    
    def __init__(self, output_dir: str = "./dashboards"):
        """
        Initialize the dashboard generator.
        
        Args:
            output_dir: Output directory for dashboards
        """
        self.output_dir = output_dir
        os.makedirs(output_dir, exist_ok=True)
        self.logger = AuditLogger()
    
    def generate_executive_dashboard(self, data_sources: Dict) -> Dict:
        """
        Generate executive dashboard.
        
        Args:
            data_sources: Dictionary of data sources
            
        Returns:
            Dashboard data
        """
        dashboard = {
            "title": "Executive Security Dashboard",
            "generated": datetime.datetime.utcnow().isoformat(),
            "sections": []
        }
        
        # Security Posture section
        posture_data = data_sources.get('posture', {})
        posture_section = {
            "name": "Security Posture",
            "metrics": {
                "overall_score": posture_data.get('overall_score', 0),
                "maturity_level": posture_data.get('maturity_level', 0),
                "risk_rating": posture_data.get('risk_rating', 'Unknown')
            }
        }
        dashboard['sections'].append(posture_section)
        
        # Incident Summary section
        incident_data = data_sources.get('incidents', {})
        incident_section = {
            "name": "Incident Summary",
            "metrics": {
                "open_incidents": incident_data.get('open', 0),
                "critical_incidents": incident_data.get('critical', 0),
                "mttd": incident_data.get('mttd', 0),
                "mttr": incident_data.get('mttr', 0)
            }
        }
        dashboard['sections'].append(incident_section)
        
        # Control Status section
        control_data = data_sources.get('controls', {})
        control_section = {
            "name": "Control Status",
            "metrics": {
                "mfa_adoption": control_data.get('mfa_adoption', 0),
                "patch_compliance": control_data.get('patch_compliance', 0),
                "edr_coverage": control_data.get('edr_coverage', 0),
                "encryption_usage": control_data.get('encryption_usage', 0)
            }
        }
        dashboard['sections'].append(control_section)
        
        # Vendor Risk section
        vendor_data = data_sources.get('vendors', {})
        vendor_section = {
            "name": "Vendor Risk Summary",
            "metrics": {
                "total_vendors": vendor_data.get('total', 0),
                "high_risk_vendors": vendor_data.get('high_risk', 0),
                "average_risk_score": vendor_data.get('average_score', 0)
            }
        }
        dashboard['sections'].append(vendor_section)
        
        return dashboard
    
    def generate_soc_dashboard(self, data_sources: Dict) -> Dict:
        """
        Generate SOC dashboard.
        
        Args:
            data_sources: Dictionary of data sources
            
        Returns:
            Dashboard data
        """
        dashboard = {
            "title": "SOC Operations Dashboard",
            "generated": datetime.datetime.utcnow().isoformat(),
            "sections": []
        }
        
        # Alert Status section
        alert_data = data_sources.get('alerts', {})
        alert_section = {
            "name": "Alert Status",
            "metrics": {
                "total_alerts": alert_data.get('total', 0),
                "critical_alerts": alert_data.get('critical', 0),
                "high_alerts": alert_data.get('high', 0),
                "medium_alerts": alert_data.get('medium', 0),
                "low_alerts": alert_data.get('low', 0)
            }
        }
        dashboard['sections'].append(alert_section)
        
        # Recent Alerts section
        recent_alerts = data_sources.get('recent_alerts', [])
        recent_section = {
            "name": "Recent Alerts",
            "alerts": recent_alerts[:20]  # Top 20 recent alerts
        }
        dashboard['sections'].append(recent_section)
        
        # Response Metrics section
        response_data = data_sources.get('response', {})
        response_section = {
            "name": "Response Metrics",
            "metrics": {
                "average_acknowledgement_time": response_data.get('avg_ack_time', 0),
                "average_response_time": response_data.get('avg_response_time', 0),
                "resolved_today": response_data.get('resolved_today', 0)
            }
        }
        dashboard['sections'].append(response_section)
        
        return dashboard
    
    def generate_as_markdown(self, dashboard: Dict) -> str:
        """
        Convert dashboard to markdown.
        
        Args:
            dashboard: Dashboard data
            
        Returns:
            Markdown string
        """
        md = f"# {dashboard.get('title', 'Security Dashboard')}\n\n"
        md += f"*Generated: {dashboard.get('generated', '')}*\n\n"
        
        for section in dashboard.get('sections', []):
            md += f"## {section.get('name', 'Section')}\n\n"
            
            # Check if it's a metrics section
            if 'metrics' in section:
                metrics = section['metrics']
                for key, value in metrics.items():
                    formatted_key = key.replace('_', ' ').title()
                    if isinstance(value, float):
                        md += f"- **{formatted_key}**: {value:.1f}\n"
                    else:
                        md += f"- **{formatted_key}**: {value}\n"
                md += "\n"
            
            # Check if it's an alerts section
            if 'alerts' in section:
                md += "| Time | Severity | Description | Status |\n"
                md += "|------|----------|-------------|--------|\n"
                for alert in section['alerts']:
                    md += f"| {alert.get('time', '')[:16]} | {alert.get('severity', '')} | {alert.get('description', '')[:40]}... | {alert.get('status', '')} |\n"
                md += "\n"
        
        return md
    
    def save_dashboard(self, dashboard: Dict, name: str, format: str = 'json') -> str:
        """
        Save dashboard to file.
        
        Args:
            dashboard: Dashboard data
            name: Dashboard name
            format: Output format (json, markdown)
            
        Returns:
            Output file path
        """
        if format == 'json':
            filename = f"{self.output_dir}/{name}_{datetime.datetime.utcnow().strftime('%Y%m%d')}.json"
            with open(filename, 'w') as f:
                json.dump(dashboard, f, indent=2)
        elif format == 'markdown':
            filename = f"{self.output_dir}/{name}_{datetime.datetime.utcnow().strftime('%Y%m%d')}.md"
            md_content = self.generate_as_markdown(dashboard)
            with open(filename, 'w') as f:
                f.write(md_content)
        else:
            raise ValueError(f"Unsupported format: {format}")
        
        self.logger.log("DASHBOARD_GENERATED", "system", {
            "name": name,
            "format": format,
            "filename": filename
        })
        
        return filename


def main():
    """CLI for dashboard generation."""
    import argparse
    
    parser = argparse.ArgumentParser(description='Security Dashboard Generator')
    parser.add_argument('--output', '-o', default='./dashboards', help='Output directory')
    parser.add_argument('--format', '-f', choices=['json', 'markdown'], default='json', help='Output format')
    parser.add_argument('--data', '-d', help='Data source file (JSON)')
    
    args = parser.parse_args()
    
    generator = DashboardGenerator(args.output)
    
    # Load sample data or use provided file
    if args.data:
        with open(args.data, 'r') as f:
            data = json.load(f)
    else:
        # Generate sample data
        data = {
            'posture': {
                'overall_score': 72.5,
                'maturity_level': 3,
                'risk_rating': 'Medium'
            },
            'incidents': {
                'open': 5,
                'critical': 1,
                'mttd': 4.2,
                'mttr': 2.8
            },
            'controls': {
                'mfa_adoption': 85.0,
                'patch_compliance': 92.0,
                'edr_coverage': 95.0,
                'encryption_usage': 88.0
            },
            'vendors': {
                'total': 45,
                'high_risk': 3,
                'average_score': 35.0
            },
            'alerts': {
                'total': 127,
                'critical': 2,
                'high': 8,
                'medium': 35,
                'low': 82
            },
            'recent_alerts': [
                {'time': datetime.datetime.utcnow().isoformat(), 'severity': 'High', 'description': 'Multiple failed login attempts detected', 'status': 'Investigating'},
                {'time': datetime.datetime.utcnow().isoformat(), 'severity': 'Critical', 'description': 'Malware detected on critical server', 'status': 'Containing'},
                {'time': datetime.datetime.utcnow().isoformat(), 'severity': 'Medium', 'description': 'Unusual outbound network traffic', 'status': 'Open'}
            ],
            'response': {
                'avg_ack_time': 12.5,
                'avg_response_time': 45.0,
                'resolved_today': 8
            }
        }
    
    # Generate executive dashboard
    exec_dash = generator.generate_executive_dashboard(data)
    exec_file = generator.save_dashboard(exec_dash, 'executive_dashboard', args.format)
    print(f"✅ Executive dashboard saved to: {exec_file}")
    
    # Generate SOC dashboard
    soc_dash = generator.generate_soc_dashboard(data)
    soc_file = generator.save_dashboard(soc_dash, 'soc_dashboard', args.format)
    print(f"✅ SOC dashboard saved to: {soc_file}")
    
    print("\nDashboards generated successfully!")


if __name__ == "__main__":
    main()
```

### C.3.2: Security Assessment Automation

**File:** `automation/security_assessment.py`

```python
#!/usr/bin/env python3
"""
Security Assessment Automation

This script automates security assessments against industry standards.
"""

import json
import datetime
import os
import sys
from typing import Dict, List, Any, Optional

# Add shared directory to path
sys.path.append(os.path.join(os.path.dirname(__file__), '..', 'shared'))
from security_lib import SecurityUtils, AuditLogger


class SecurityAssessment:
    """
    Automated security assessment.
    """
    
    def __init__(self):
        """Initialize assessment."""
        self.logger = AuditLogger()
        self.controls = []
        self.load_controls()
    
    def load_controls(self) -> None:
        """Load security controls from multiple frameworks."""
        self.controls = [
            # NIST CSF 2.0 Controls
            {
                "id": "NIST-GV-01",
                "framework": "NIST CSF 2.0",
                "category": "Govern",
                "description": "Organizational cybersecurity risk management strategy is established",
                "implementation_level": "high"
            },
            {
                "id": "NIST-ID-01",
                "framework": "NIST CSF 2.0",
                "category": "Identify",
                "description": "Asset inventory and management processes are established",
                "implementation_level": "critical"
            },
            {
                "id": "NIST-PR-01",
                "framework": "NIST CSF 2.0",
                "category": "Protect",
                "description": "Identity and access management is implemented",
                "implementation_level": "critical"
            },
            {
                "id": "NIST-PR-02",
                "framework": "NIST CSF 2.0",
                "category": "Protect",
                "description": "Data security protections are in place",
                "implementation_level": "critical"
            },
            {
                "id": "NIST-DE-01",
                "framework": "NIST CSF 2.0",
                "category": "Detect",
                "description": "Security monitoring and detection capabilities are operational",
                "implementation_level": "high"
            },
            {
                "id": "NIST-RS-01",
                "framework": "NIST CSF 2.0",
                "category": "Respond",
                "description": "Incident response capabilities are established and tested",
                "implementation_level": "high"
            },
            {
                "id": "NIST-RC-01",
                "framework": "NIST CSF 2.0",
                "category": "Recover",
                "description": "Business continuity and recovery plans are in place",
                "implementation_level": "medium"
            },
            # ISO 27001 Controls
            {
                "id": "ISO-5",
                "framework": "ISO 27001",
                "category": "Leadership",
                "description": "Information security policy established",
                "implementation_level": "high"
            },
            {
                "id": "ISO-6",
                "framework": "ISO 27001",
                "category": "Planning",
                "description": "Risk management process implemented",
                "implementation_level": "high"
            },
            {
                "id": "ISO-7",
                "framework": "ISO 27001",
                "category": "Support",
                "description": "Awareness and training program in place",
                "implementation_level": "medium"
            },
            {
                "id": "ISO-8",
                "framework": "ISO 27001",
                "category": "Operation",
                "description": "Operational controls implemented",
                "implementation_level": "critical"
            },
            {
                "id": "ISO-9",
                "framework": "ISO 27001",
                "category": "Performance",
                "description": "Monitoring and measurement of security performance",
                "implementation_level": "medium"
            },
            # CIS Controls
            {
                "id": "CIS-1",
                "framework": "CIS Controls",
                "category": "Inventory",
                "description": "Inventory and control of enterprise assets",
                "implementation_level": "critical"
            },
            {
                "id": "CIS-2",
                "framework": "CIS Controls",
                "category": "Software",
                "description": "Inventory and control of software assets",
                "implementation_level": "critical"
            },
            {
                "id": "CIS-3",
                "framework": "CIS Controls",
                "category": "Data Protection",
                "description": "Data protection measures in place",
                "implementation_level": "high"
            },
            {
                "id": "CIS-5",
                "framework": "CIS Controls",
                "category": "Access Management",
                "description": "Account management controls implemented",
                "implementation_level": "critical"
            },
            {
                "id": "CIS-6",
                "framework": "CIS Controls",
                "category": "Access Control",
                "description": "Access control management implemented",
                "implementation_level": "critical"
            },
            {
                "id": "CIS-7",
                "framework": "CIS Controls",
                "category": "Vulnerability Management",
                "description": "Vulnerability management program in place",
                "implementation_level": "high"
            },
            {
                "id": "CIS-8",
                "framework": "CIS Controls",
                "category": "Audit and Logging",
                "description": "Audit log management implemented",
                "implementation_level": "high"
            },
            {
                "id": "CIS-13",
                "framework": "CIS Controls",
                "category": "Network Monitoring",
                "description": "Network monitoring and defense in place",
                "implementation_level": "high"
            }
        ]
    
    def run_assessment(self, implementation_data: Dict) -> Dict:
        """
        Run security assessment.
        
        Args:
            implementation_data: Data about implementation status
            
        Returns:
            Assessment results
        """
        results = []
        implemented = 0
        partially_implemented = 0
        not_implemented = 0
        
        for control in self.controls:
            control_id = control['id']
            status = implementation_data.get(control_id, 'not_implemented')
            
            result = {
                "control_id": control_id,
                "framework": control['framework'],
                "category": control['category'],
                "description": control['description'],
                "status": status,
                "evidence": implementation_data.get(f"{control_id}_evidence", ""),
                "recommendations": self._generate_recommendations(control, status)
            }
            
            results.append(result)
            
            if status == 'implemented':
                implemented += 1
            elif status == 'partially_implemented':
                partially_implemented += 1
            else:
                not_implemented += 1
        
        total_controls = len(self.controls)
        overall_score = (implemented + (partially_implemented * 0.5)) / total_controls * 100
        
        return {
            "assessment_date": datetime.datetime.utcnow().isoformat(),
            "total_controls": total_controls,
            "implemented": implemented,
            "partially_implemented": partially_implemented,
            "not_implemented": not_implemented,
            "overall_score": overall_score,
            "results": results,
            "summary": self._generate_summary(results)
        }
    
    def _generate_recommendations(self, control: Dict, status: str) -> List[str]:
        """
        Generate recommendations based on status.
        
        Args:
            control: Control data
            status: Implementation status
            
        Returns:
            List of recommendations
        """
        recommendations = []
        
        if status == 'not_implemented':
            recommendations.append(f"Implement {control['description']}")
            if control['implementation_level'] == 'critical':
                recommendations.append("Priority: CRITICAL - Implement immediately")
            elif control['implementation_level'] == 'high':
                recommendations.append("Priority: HIGH - Implement within 30 days")
            else:
                recommendations.append("Priority: MEDIUM - Implement within 90 days")
        
        elif status == 'partially_implemented':
            recommendations.append(f"Complete implementation of {control['description']}")
            recommendations.append("Review gaps and develop remediation plan")
        
        elif status == 'implemented':
            recommendations.append(f"{control['description']} is implemented")
            recommendations.append("Consider continuous improvement opportunities")
        
        return recommendations
    
    def _generate_summary(self, results: List[Dict]) -> Dict:
        """
        Generate assessment summary.
        
        Args:
            results: Assessment results
            
        Returns:
            Summary dictionary
        """
        summary = {
            "by_framework": {},
            "by_category": {},
            "by_level": {},
            "recommendations_priority": {
                "critical": [],
                "high": [],
                "medium": []
            }
        }
        
        for result in results:
            # By framework
            framework = result['framework']
            if framework not in summary['by_framework']:
                summary['by_framework'][framework] = {
                    'total': 0,
                    'implemented': 0,
                    'partial': 0,
                    'not_implemented': 0
                }
            summary['by_framework'][framework]['total'] += 1
            if result['status'] == 'implemented':
                summary['by_framework'][framework]['implemented'] += 1
            elif result['status'] == 'partially_implemented':
                summary['by_framework'][framework]['partial'] += 1
            else:
                summary['by_framework'][framework]['not_implemented'] += 1
            
            # By category
            category = result['category']
            if category not in summary['by_category']:
                summary['by_category'][category] = {
                    'total': 0,
                    'implemented': 0,
                    'partial': 0,
                    'not_implemented': 0
                }
            summary['by_category'][category]['total'] += 1
            if result['status'] == 'implemented':
                summary['by_category'][category]['implemented'] += 1
            elif result['status'] == 'partially_implemented':
                summary['by_category'][category]['partial'] += 1
            else:
                summary['by_category'][category]['not_implemented'] += 1
            
            # By implementation level
            level = "critical" if result.get('implementation_level') == 'critical' else "high" if result.get('implementation_level') == 'high' else "medium"
            if level not in summary['by_level']:
                summary['by_level'][level] = {
                    'total': 0,
                    'implemented': 0,
                    'partial': 0,
                    'not_implemented': 0
                }
            summary['by_level'][level]['total'] += 1
            if result['status'] == 'implemented':
                summary['by_level'][level]['implemented'] += 1
            elif result['status'] == 'partially_implemented':
                summary['by_level'][level]['partial'] += 1
            else:
                summary['by_level'][level]['not_implemented'] += 1
            
            # Priority recommendations
            if result['status'] != 'implemented':
                level = result.get('implementation_level', 'medium')
                if level in summary['recommendations_priority']:
                    summary['recommendations_priority'][level].append({
                        'control_id': result['control_id'],
                        'description': result['description'],
                        'status': result['status'],
                        'recommendations': result['recommendations']
                    })
        
        return summary


def main():
    """CLI for security assessment."""
    import argparse
    
    parser = argparse.ArgumentParser(description='Security Assessment Tool')
    parser.add_argument('--input', '-i', help='Implementation data file (JSON)')
    parser.add_argument('--output', '-o', default='assessment_results.json', help='Output file')
    parser.add_argument('--format', '-f', choices=['json', 'markdown'], default='json', help='Output format')
    
    args = parser.parse_args()
    
    assessment = SecurityAssessment()
    
    # Load or generate implementation data
    if args.input:
        with open(args.input, 'r') as f:
            implementation_data = json.load(f)
    else:
        # Generate sample data
        implementation_data = {}
        for control in assessment.controls:
            import random
            implementation_data[control['id']] = random.choice(['implemented', 'partially_implemented', 'not_implemented'])
            if random.choice([True, False]):
                implementation_data[f"{control['id']}_evidence"] = f"Evidence for {control['id']}"
    
    # Run assessment
    results = assessment.run_assessment(implementation_data)
    
    # Save results
    if args.format == 'json':
        with open(args.output, 'w') as f:
            json.dump(results, f, indent=2)
    else:
        # Generate markdown report
        md = f"# Security Assessment Report\n\n"
        md += f"*Assessment Date: {results['assessment_date']}*\n\n"
        md += f"## Summary\n\n"
        md += f"- Total Controls: {results['total_controls']}\n"
        md += f"- Implemented: {results['implemented']}\n"
        md += f"- Partially Implemented: {results['partially_implemented']}\n"
        md += f"- Not Implemented: {results['not_implemented']}\n"
        md += f"- Overall Score: {results['overall_score']:.1f}%\n\n"
        
        md += f"## Framework Summary\n\n"
        md += "| Framework | Total | Implemented | Partial | Not Implemented |\n"
        md += "|-----------|-------|-------------|---------|-----------------|\n"
        for framework, stats in results['summary']['by_framework'].items():
            md += f"| {framework} | {stats['total']} | {stats['implemented']} | {stats['partial']} | {stats['not_implemented']} |\n"
        
        md += f"\n## Details\n\n"
        for result in results['results']:
            status_icon = "✅" if result['status'] == 'implemented' else "🟡" if result['status'] == 'partially_implemented' else "❌"
            md += f"### {status_icon} {result['control_id']}: {result['description']}\n"
            md += f"- Framework: {result['framework']}\n"
            md += f"- Category: {result['category']}\n"
            md += f"- Status: {result['status']}\n"
            if result['evidence']:
                md += f"- Evidence: {result['evidence']}\n"
            md += "- Recommendations:\n"
            for rec in result['recommendations']:
                md += f"  - {rec}\n"
            md += "\n"
        
        with open(args.output, 'w') as f:
            f.write(md)
    
    print(f"✅ Assessment results saved to: {args.output}")


if __name__ == "__main__":
    main()
```

---

This concludes Appendix C: Complete Technical Implementation Reference. This appendix provides the technical building blocks, infrastructure templates, and automation scripts needed to implement the entire Enterprise Cybersecurity Program.
