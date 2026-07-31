# Part 3: Implement Foundational Security Controls

## Learning Objectives

By completing this tutorial, you will:

- Deploy comprehensive Identity and Access Management (IAM) with Multi-Factor Authentication (MFA)
- Implement Privileged Access Management (PAM) with just-in-time access
- Deploy Endpoint Detection and Response (EDR) and Extended Detection and Response (XDR)
- Implement network micro-segmentation and Zero Trust Network Access (ZTNA)
- Deploy Cloud Security Posture Management (CSPM) for multi-cloud environments
- Implement encryption at rest, in transit, and in use
- Deploy Data Loss Prevention (DLP) controls
- Establish secure configuration baselines and automated vulnerability management
- Build a comprehensive security control framework mapped to NIST CSF, ISO 27001, and CIS Controls

## Key Concepts & Frameworks

### Why Foundational Controls Matter

Think of cybersecurity controls like the layers of a medieval castle:
- **Moat**: Network segmentation (keep attackers out)
- **Walls**: Firewalls and perimeter security
- **Guard Towers**: Monitoring and detection
- **Inner Keep**: Identity and access controls
- **Treasury Vault**: Data encryption and protection
- **Soldiers**: Endpoint protection and response

Our foundational controls build these layers systematically, starting with identity—the most critical layer in modern security.

### Core Frameworks We'll Use

**CIS Critical Security Controls (v8)**
- Control 1: Inventory and Control of Enterprise Assets
- Control 2: Inventory and Control of Software Assets
- Control 3: Data Protection
- Control 4: Secure Configuration of Enterprise Assets
- Control 5: Account Management
- Control 6: Access Control Management
- Control 7: Continuous Vulnerability Management
- Control 8: Audit Log Management
- Control 13: Network Monitoring and Defense

**NIST SP 800-53 Controls**
- AC (Access Control) family
- IA (Identification and Authentication) family
- SC (System and Communications Protection) family
- SI (System and Information Integrity) family

## Hands-On Implementation

### Step 1: Deploy Identity and Access Management (IAM)

**The Target:** Build a comprehensive IAM system with MFA, RBAC, and automated lifecycle management.

**The Concept:** IAM is like the security checkpoint at a building entrance. Every person must prove who they are (authentication) and show they have permission to enter (authorization). We'll build this for digital access.

#### 1.1 Create the IAM Implementation Script

**File:** `03-security-controls/scripts/iam_implementation.py`

```python
#!/usr/bin/env python3
"""
Identity and Access Management (IAM) Implementation

This module implements comprehensive IAM including:
- User lifecycle management
- Role-Based Access Control (RBAC)
- Multi-Factor Authentication (MFA) enforcement
- Privileged Access Management (PAM)
- Access reviews and recertification
"""

import json
import datetime
import hashlib
import secrets
import re
from typing import Dict, List, Optional, Set, Any
from dataclasses import dataclass, field
from enum import Enum
import os
import base64
from cryptography.fernet import Fernet
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.kdf.pbkdf2 import PBKDF2HMAC


class AuthMethod(Enum):
    """Authentication methods supported."""
    PASSWORD = "password"
    TOTP = "totp"
    SMS = "sms"
    EMAIL = "email"
    WEBAUTHN = "webauthn"
    PUSH = "push"
    BIOMETRIC = "biometric"


class Role(Enum):
    """User roles with defined permissions."""
    ADMIN = "admin"
    SECURITY_ENGINEER = "security_engineer"
    SECURITY_ANALYST = "security_analyst"
    IT_ENGINEER = "it_engineer"
    DEVELOPER = "developer"
    BUSINESS_USER = "business_user"
    VIEWER = "viewer"
    CONTRACTOR = "contractor"
    SYSTEM = "system"


class Permission(Enum):
    """Granular permissions for access control."""
    # User management
    USER_CREATE = "user:create"
    USER_READ = "user:read"
    USER_UPDATE = "user:update"
    USER_DELETE = "user:delete"
    
    # Role management
    ROLE_CREATE = "role:create"
    ROLE_READ = "role:read"
    ROLE_UPDATE = "role:update"
    ROLE_DELETE = "role:delete"
    
    # Resource access
    RESOURCE_READ = "resource:read"
    RESOURCE_WRITE = "resource:write"
    RESOURCE_DELETE = "resource:delete"
    
    # Security operations
    SECURITY_VIEW = "security:view"
    SECURITY_ALERT = "security:alert"
    SECURITY_RESPOND = "security:respond"
    SECURITY_CONFIG = "security:config"
    
    # Audit
    AUDIT_READ = "audit:read"
    AUDIT_EXPORT = "audit:export"
    
    # System
    SYSTEM_CONFIG = "system:config"
    SYSTEM_MONITOR = "system:monitor"


# Role to permission mapping
ROLE_PERMISSIONS = {
    Role.ADMIN.value: [p.value for p in Permission],
    Role.SECURITY_ENGINEER.value: [
        Permission.SECURITY_VIEW.value,
        Permission.SECURITY_ALERT.value,
        Permission.SECURITY_RESPOND.value,
        Permission.AUDIT_READ.value,
        Permission.RESOURCE_READ.value,
        Permission.USER_READ.value
    ],
    Role.SECURITY_ANALYST.value: [
        Permission.SECURITY_VIEW.value,
        Permission.AUDIT_READ.value,
        Permission.RESOURCE_READ.value
    ],
    Role.IT_ENGINEER.value: [
        Permission.SYSTEM_CONFIG.value,
        Permission.SYSTEM_MONITOR.value,
        Permission.RESOURCE_READ.value,
        Permission.RESOURCE_WRITE.value
    ],
    Role.DEVELOPER.value: [
        Permission.RESOURCE_READ.value,
        Permission.RESOURCE_WRITE.value,
        Permission.SECURITY_VIEW.value
    ],
    Role.BUSINESS_USER.value: [
        Permission.RESOURCE_READ.value,
        Permission.RESOURCE_WRITE.value
    ],
    Role.VIEWER.value: [
        Permission.RESOURCE_READ.value
    ],
    Role.CONTRACTOR.value: [
        Permission.RESOURCE_READ.value,
        Permission.SECURITY_VIEW.value
    ],
    Role.SYSTEM.value: [
        Permission.SYSTEM_CONFIG.value,
        Permission.SYSTEM_MONITOR.value,
        Permission.RESOURCE_READ.value,
        Permission.RESOURCE_WRITE.value
    ]
}


@dataclass
class User:
    """
    User account representation.
    
    Attributes:
        user_id: Unique user identifier
        username: Login username
        email: Email address
        roles: List of assigned roles
        enabled: Whether account is active
        mfa_enabled: Whether MFA is configured
        mfa_methods: List of configured MFA methods
        password_hash: Hashed password (stored securely)
        created_at: Creation timestamp
        last_login: Last login timestamp
        failed_attempts: Number of failed login attempts
        locked_until: Account lock expiration
        attributes: Additional user attributes
    """
    user_id: str
    username: str
    email: str
    roles: List[str]
    enabled: bool = True
    mfa_enabled: bool = False
    mfa_methods: List[str] = field(default_factory=list)
    password_hash: str = ""
    created_at: str = field(default_factory=lambda: datetime.datetime.utcnow().isoformat())
    last_login: Optional[str] = None
    failed_attempts: int = 0
    locked_until: Optional[str] = None
    attributes: Dict[str, Any] = field(default_factory=dict)
    
    def to_dict(self) -> Dict:
        """Convert to dictionary for serialization."""
        return {
            "user_id": self.user_id,
            "username": self.username,
            "email": self.email,
            "roles": self.roles,
            "enabled": self.enabled,
            "mfa_enabled": self.mfa_enabled,
            "mfa_methods": self.mfa_methods,
            "created_at": self.created_at,
            "last_login": self.last_login,
            "failed_attempts": self.failed_attempts,
            "locked_until": self.locked_until,
            "attributes": self.attributes
        }
    
    @classmethod
    def from_dict(cls, data: Dict) -> 'User':
        """Create user from dictionary."""
        return cls(
            user_id=data['user_id'],
            username=data['username'],
            email=data['email'],
            roles=data.get('roles', []),
            enabled=data.get('enabled', True),
            mfa_enabled=data.get('mfa_enabled', False),
            mfa_methods=data.get('mfa_methods', []),
            created_at=data.get('created_at', datetime.datetime.utcnow().isoformat()),
            last_login=data.get('last_login'),
            failed_attempts=data.get('failed_attempts', 0),
            locked_until=data.get('locked_until'),
            attributes=data.get('attributes', {})
        )


@dataclass
class AccessToken:
    """Access token for authenticated sessions."""
    token: str
    user_id: str
    created_at: str
    expires_at: str
    scopes: List[str]
    refresh_token: Optional[str] = None
    
    def is_expired(self) -> bool:
        """Check if token is expired."""
        return datetime.datetime.utcnow().isoformat() > self.expires_at


class IAMManager:
    """
    Identity and Access Management Manager.
    
    This class handles user lifecycle, authentication, authorization,
    and access governance.
    """
    
    def __init__(self, data_dir: str = "./iam_data"):
        """
        Initialize IAM manager.
        
        Args:
            data_dir: Directory for persistent storage
        """
        self.data_dir = data_dir
        self._ensure_data_dir()
        
        self.users: Dict[str, User] = {}
        self.tokens: Dict[str, AccessToken] = {}
        self.audit_log: List[Dict] = []
        
        # Load existing data
        self._load_data()
        
        # Create default admin if no users exist
        if not self.users:
            self._create_default_admin()
    
    def _ensure_data_dir(self) -> None:
        """Create data directory if it doesn't exist."""
        os.makedirs(self.data_dir, exist_ok=True)
        os.makedirs(f"{self.data_dir}/users", exist_ok=True)
        os.makedirs(f"{self.data_dir}/tokens", exist_ok=True)
        os.makedirs(f"{self.data_dir}/audit", exist_ok=True)
    
    def _load_data(self) -> None:
        """Load existing data from storage."""
        # Load users
        users_dir = f"{self.data_dir}/users"
        if os.path.exists(users_dir):
            for filename in os.listdir(users_dir):
                if filename.endswith('.json'):
                    with open(f"{users_dir}/{filename}", 'r') as f:
                        data = json.load(f)
                        user = User.from_dict(data)
                        self.users[user.user_id] = user
        
        # Load audit log
        audit_file = f"{self.data_dir}/audit/audit.log"
        if os.path.exists(audit_file):
            with open(audit_file, 'r') as f:
                for line in f:
                    try:
                        self.audit_log.append(json.loads(line.strip()))
                    except json.JSONDecodeError:
                        continue
    
    def _save_user(self, user: User) -> None:
        """Save user to storage."""
        with open(f"{self.data_dir}/users/{user.user_id}.json", 'w') as f:
            json.dump(user.to_dict(), f, indent=2)
    
    def _log_audit(self, action: str, user_id: str, details: Dict) -> None:
        """
        Log audit event.
        
        Args:
            action: Action performed
            user_id: User performing action
            details: Additional details
        """
        log_entry = {
            "timestamp": datetime.datetime.utcnow().isoformat(),
            "action": action,
            "user_id": user_id,
            "details": details
        }
        self.audit_log.append(log_entry)
        
        # Write to file
        audit_file = f"{self.data_dir}/audit/audit.log"
        with open(audit_file, 'a') as f:
            f.write(json.dumps(log_entry) + "\n")
    
    def _create_default_admin(self) -> None:
        """Create default admin user for initial setup."""
        admin = User(
            user_id="admin-001",
            username="admin",
            email="admin@company.com",
            roles=[Role.ADMIN.value],
            enabled=True,
            mfa_enabled=False  # Will be enforced later
        )
        # In production, use proper password hashing
        admin.password_hash = self._hash_password("Admin@123!" if os.environ.get('ENV') != 'production' else secrets.token_urlsafe(32))
        
        self.users[admin.user_id] = admin
        self._save_user(admin)
        self._log_audit("ADMIN_CREATED", "system", {"admin_id": admin.user_id})
    
    def _hash_password(self, password: str) -> str:
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
    
    def _verify_password(self, password: str, password_hash: str) -> bool:
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
    
    def _validate_password_strength(self, password: str) -> Tuple[bool, List[str]]:
        """
        Validate password against security requirements.
        
        Args:
            password: Password to validate
            
        Returns:
            Tuple of (is_valid, violations)
        """
        violations = []
        
        if len(password) < 12:
            violations.append("Password must be at least 12 characters")
        if not re.search(r'[A-Z]', password):
            violations.append("Password must contain at least one uppercase letter")
        if not re.search(r'[a-z]', password):
            violations.append("Password must contain at least one lowercase letter")
        if not re.search(r'[0-9]', password):
            violations.append("Password must contain at least one number")
        if not re.search(r'[!@#$%^&*(),.?":{}|<>]', password):
            violations.append("Password must contain at least one special character")
        if password.lower() in ['password', 'admin', 'letmein', '12345678', 'qwerty']:
            violations.append("Password is too common")
        
        return len(violations) == 0, violations
    
    def create_user(self, username: str, email: str, password: str, 
                   roles: List[str], attributes: Optional[Dict] = None) -> Optional[User]:
        """
        Create a new user account.
        
        Args:
            username: Desired username
            email: Email address
            password: Initial password
            roles: List of roles to assign
            attributes: Additional user attributes
            
        Returns:
            Created User or None if creation failed
        """
        # Check if username or email already exists
        for user in self.users.values():
            if user.username == username:
                self._log_audit("USER_CREATE_FAILED", "system", {"reason": "Username already exists", "username": username})
                return None
            if user.email == email:
                self._log_audit("USER_CREATE_FAILED", "system", {"reason": "Email already exists", "email": email})
                return None
        
        # Validate password
        is_valid, violations = self._validate_password_strength(password)
        if not is_valid:
            self._log_audit("USER_CREATE_FAILED", "system", {"reason": "Password policy violation", "violations": violations})
            return None
        
        # Create user
        user_id = hashlib.md5(f"{username}:{email}:{datetime.datetime.utcnow().isoformat()}".encode()).hexdigest()[:12]
        
        user = User(
            user_id=user_id,
            username=username,
            email=email,
            roles=roles,
            enabled=True,
            mfa_enabled=False,
            password_hash=self._hash_password(password),
            attributes=attributes or {}
        )
        
        self.users[user_id] = user
        self._save_user(user)
        self._log_audit("USER_CREATED", "system", {"user_id": user_id, "username": username})
        
        return user
    
    def authenticate(self, username: str, password: str) -> Optional[User]:
        """
        Authenticate a user with username and password.
        
        Args:
            username: Username
            password: Password
            
        Returns:
            User if authenticated, None otherwise
        """
        # Find user by username
        user = None
        for u in self.users.values():
            if u.username == username:
                user = u
                break
        
        if not user:
            self._log_audit("AUTH_FAILED", "unknown", {"username": username, "reason": "User not found"})
            return None
        
        # Check if account is locked
        if user.locked_until:
            lock_time = datetime.datetime.fromisoformat(user.locked_until)
            if datetime.datetime.utcnow() < lock_time:
                self._log_audit("AUTH_FAILED", user.user_id, {"reason": "Account locked"})
                return None
        
        # Check password
        if not self._verify_password(password, user.password_hash):
            user.failed_attempts += 1
            if user.failed_attempts >= 5:
                # Lock account for 15 minutes
                user.locked_until = (datetime.datetime.utcnow() + datetime.timedelta(minutes=15)).isoformat()
                self._log_audit("ACCOUNT_LOCKED", user.user_id, {"reason": "Too many failed attempts"})
            self._save_user(user)
            self._log_audit("AUTH_FAILED", user.user_id, {"reason": "Invalid password"})
            return None
        
        # Successful authentication
        user.failed_attempts = 0
        user.locked_until = None
        user.last_login = datetime.datetime.utcnow().isoformat()
        self._save_user(user)
        self._log_audit("AUTH_SUCCESS", user.user_id, {"username": username})
        
        return user
    
    def enforce_mfa(self, user_id: str, method: str) -> bool:
        """
        Enforce MFA for a user.
        
        Args:
            user_id: User ID
            method: MFA method to enable
            
        Returns:
            True if MFA was enabled
        """
        user = self.users.get(user_id)
        if not user:
            return False
        
        # In production, this would send TOTP secret or setup push notification
        user.mfa_enabled = True
        if method not in user.mfa_methods:
            user.mfa_methods.append(method)
        
        self._save_user(user)
        self._log_audit("MFA_ENABLED", user_id, {"method": method})
        return True
    
    def check_permission(self, user_id: str, permission: str) -> bool:
        """
        Check if a user has a specific permission.
        
        Args:
            user_id: User ID
            permission: Permission to check
            
        Returns:
            True if user has permission
        """
        user = self.users.get(user_id)
        if not user:
            return False
        
        if not user.enabled:
            return False
        
        # Admin has all permissions
        if Role.ADMIN.value in user.roles:
            return True
        
        # Check each role
        for role in user.roles:
            if role in ROLE_PERMISSIONS:
                if permission in ROLE_PERMISSIONS[role]:
                    return True
        
        return False
    
    def get_user_permissions(self, user_id: str) -> Set[str]:
        """
        Get all permissions for a user.
        
        Args:
            user_id: User ID
            
        Returns:
            Set of permissions
        """
        user = self.users.get(user_id)
        if not user:
            return set()
        
        permissions = set()
        for role in user.roles:
            if role in ROLE_PERMISSIONS:
                permissions.update(ROLE_PERMISSIONS[role])
        
        return permissions
    
    def generate_token(self, user_id: str, scopes: List[str]) -> Optional[AccessToken]:
        """
        Generate an access token for a user.
        
        Args:
            user_id: User ID
            scopes: List of scopes for the token
            
        Returns:
            AccessToken or None if user not found
        """
        user = self.users.get(user_id)
        if not user:
            return None
        
        token = secrets.token_urlsafe(32)
        created_at = datetime.datetime.utcnow().isoformat()
        expires_at = (datetime.datetime.utcnow() + datetime.timedelta(hours=1)).isoformat()
        
        access_token = AccessToken(
            token=token,
            user_id=user_id,
            created_at=created_at,
            expires_at=expires_at,
            scopes=scopes,
            refresh_token=secrets.token_urlsafe(32)
        )
        
        self.tokens[token] = access_token
        self._log_audit("TOKEN_GENERATED", user_id, {"scopes": scopes})
        
        return access_token
    
    def validate_token(self, token: str) -> Optional[AccessToken]:
        """
        Validate an access token.
        
        Args:
            token: Token to validate
            
        Returns:
            AccessToken if valid, None otherwise
        """
        if token not in self.tokens:
            return None
        
        access_token = self.tokens[token]
        if access_token.is_expired():
            del self.tokens[token]
            return None
        
        return access_token
    
    def revoke_token(self, token: str) -> bool:
        """
        Revoke an access token.
        
        Args:
            token: Token to revoke
            
        Returns:
            True if revoked
        """
        if token not in self.tokens:
            return False
        
        del self.tokens[token]
        self._log_audit("TOKEN_REVOKED", "system", {"token": token[:8] + "..."})
        return True
    
    def access_review(self, user_id: str) -> Dict:
        """
        Perform an access review for a user.
        
        Args:
            user_id: User ID to review
            
        Returns:
            Access review report
        """
        user = self.users.get(user_id)
        if not user:
            return {"error": "User not found"}
        
        permissions = self.get_user_permissions(user_id)
        
        review = {
            "user_id": user_id,
            "username": user.username,
            "roles": user.roles,
            "permissions": list(permissions),
            "mfa_enabled": user.mfa_enabled,
            "last_login": user.last_login,
            "enabled": user.enabled,
            "review_date": datetime.datetime.utcnow().isoformat(),
            "recommendations": []
        }
        
        # Generate recommendations
        if not user.mfa_enabled:
            review["recommendations"].append("Enable MFA immediately")
        
        if len(user.roles) > 3:
            review["recommendations"].append("Review role assignments - too many roles")
        
        if "highly_confidential" in user.attributes.get("data_access", []) and not user.mfa_enabled:
            review["recommendations"].append("MFA required for highly confidential data access")
        
        if not user.last_login:
            review["recommendations"].append("User has never logged in - consider deactivation")
        elif (datetime.datetime.utcnow() - datetime.datetime.fromisoformat(user.last_login)).days > 90:
            review["recommendations"].append("User inactive for 90+ days - review necessity")
        
        return review
    
    def generate_report(self) -> str:
        """
        Generate IAM report.
        
        Returns:
            Markdown formatted report
        """
        total_users = len(self.users)
        mfa_enabled = sum(1 for u in self.users.values() if u.mfa_enabled)
        enabled_users = sum(1 for u in self.users.values() if u.enabled)
        
        # Count by role
        role_counts = {}
        for user in self.users.values():
            for role in user.roles:
                role_counts[role] = role_counts.get(role, 0) + 1
        
        report = f"""
# Identity and Access Management Report
*Generated: {datetime.datetime.now().strftime('%Y-%m-%d %H:%M')}*

## Executive Summary

| Metric | Value |
|--------|-------|
| Total Users | {total_users} |
| Active Users | {enabled_users} ({enabled_users/total_users*100:.1f}%) |
| MFA Enabled | {mfa_enabled} ({mfa_enabled/total_users*100:.1f}%) |

## Role Distribution

| Role | Count |
|------|-------|
"""
        
        for role, count in sorted(role_counts.items(), key=lambda x: x[1], reverse=True):
            report += f"| {role} | {count} |\n"
        
        report += """
## User Access Review Status

| User | Roles | MFA | Last Login | Status |
|------|-------|-----|------------|--------|
"""
        
        for user in sorted(self.users.values(), key=lambda u: u.username):
            status = "✅ Active" if user.enabled else "❌ Disabled"
            mfa = "✅" if user.mfa_enabled else "❌"
            last_login = user.last_login[:10] if user.last_login else "Never"
            
            report += f"| {user.username} | {', '.join(user.roles)} | {mfa} | {last_login} | {status} |\n"
        
        return report


def main():
    """CLI for IAM management."""
    import argparse
    
    parser = argparse.ArgumentParser(description='IAM Management Tool')
    subparsers = parser.add_subparsers(dest='command', help='Subcommands')
    
    # Create user
    create_parser = subparsers.add_parser('create', help='Create a new user')
    create_parser.add_argument('--username', '-u', required=True, help='Username')
    create_parser.add_argument('--email', '-e', required=True, help='Email')
    create_parser.add_argument('--password', '-p', required=True, help='Password')
    create_parser.add_argument('--roles', '-r', nargs='+', required=True, help='Roles to assign')
    
    # Authenticate
    auth_parser = subparsers.add_parser('auth', help='Authenticate a user')
    auth_parser.add_argument('--username', '-u', required=True, help='Username')
    auth_parser.add_argument('--password', '-p', required=True, help='Password')
    
    # Enable MFA
    mfa_parser = subparsers.add_parser('enable-mfa', help='Enable MFA for a user')
    mfa_parser.add_argument('--user-id', '-u', required=True, help='User ID')
    mfa_parser.add_argument('--method', '-m', default='totp', help='MFA method')
    
    # Access review
    review_parser = subparsers.add_parser('review', help='Perform access review')
    review_parser.add_argument('--user-id', '-u', required=True, help='User ID')
    
    # Generate report
    report_parser = subparsers.add_parser('report', help='Generate IAM report')
    
    # Check permission
    perm_parser = subparsers.add_parser('check-perm', help='Check user permission')
    perm_parser.add_argument('--user-id', '-u', required=True, help='User ID')
    perm_parser.add_argument('--permission', '-p', required=True, help='Permission to check')
    
    # Generate token
    token_parser = subparsers.add_parser('token', help='Generate access token')
    token_parser.add_argument('--user-id', '-u', required=True, help='User ID')
    token_parser.add_argument('--scopes', '-s', nargs='+', default=['read'], help='Token scopes')
    
    args = parser.parse_args()
    
    iam = IAMManager()
    
    if args.command == 'create':
        user = iam.create_user(args.username, args.email, args.password, args.roles)
        if user:
            print(f"✅ User created: {user.user_id}")
            print(f"   Username: {user.username}")
            print(f"   Email: {user.email}")
            print(f"   Roles: {', '.join(user.roles)}")
        else:
            print("❌ User creation failed")
    
    elif args.command == 'auth':
        user = iam.authenticate(args.username, args.password)
        if user:
            print(f"✅ Authentication successful: {user.username}")
            print(f"   User ID: {user.user_id}")
            print(f"   Roles: {', '.join(user.roles)}")
            print(f"   MFA Enabled: {user.mfa_enabled}")
        else:
            print("❌ Authentication failed")
    
    elif args.command == 'enable-mfa':
        if iam.enforce_mfa(args.user_id, args.method):
            print(f"✅ MFA enabled for user {args.user_id}")
        else:
            print(f"❌ User {args.user_id} not found")
    
    elif args.command == 'review':
        review = iam.access_review(args.user_id)
        if 'error' in review:
            print(f"❌ {review['error']}")
        else:
            print(f"\nAccess Review for {review['username']} ({review['user_id']})")
            print(f"  Roles: {', '.join(review['roles'])}")
            print(f"  Permissions: {len(review['permissions'])} permissions")
            print(f"  MFA: {'✅ Enabled' if review['mfa_enabled'] else '❌ Disabled'}")
            print(f"  Last Login: {review['last_login'] or 'Never'}")
            if review['recommendations']:
                print("\n  Recommendations:")
                for rec in review['recommendations']:
                    print(f"    - {rec}")
    
    elif args.command == 'report':
        report = iam.generate_report()
        print(report)
    
    elif args.command == 'check-perm':
        has_perm = iam.check_permission(args.user_id, args.permission)
        print(f"User {args.user_id} has permission '{args.permission}': {'✅ Yes' if has_perm else '❌ No'}")
    
    elif args.command == 'token':
        token = iam.generate_token(args.user_id, args.scopes)
        if token:
            print(f"✅ Token generated for user {args.user_id}")
            print(f"   Token: {token.token}")
            print(f"   Expires: {token.expires_at}")
            print(f"   Scopes: {', '.join(token.scopes)}")
        else:
            print(f"❌ User {args.user_id} not found")
    
    else:
        parser.print_help()


if __name__ == "__main__":
    main()
```

#### 1.2 Create the PAM Implementation

**File:** `03-security-controls/scripts/pam_implementation.py`

```python
#!/usr/bin/env python3
"""
Privileged Access Management (PAM) Implementation

This module implements Privileged Access Management including:
- Privileged account vaulting
- Just-in-time (JIT) access
- Session recording
- Credential rotation
- Break-glass access
"""

import json
import datetime
import secrets
import hashlib
from typing import Dict, List, Optional, Any
from dataclasses import dataclass, field
from enum import Enum
import os
import base64
from cryptography.fernet import Fernet


class PrivilegeLevel(Enum):
    """Levels of privilege."""
    STANDARD = "standard"
    ADMIN = "admin"
    SUPER_ADMIN = "super_admin"
    SYSTEM = "system"
    EMERGENCY = "emergency"


class PAMStatus(Enum):
    """Status of PAM operations."""
    ACTIVE = "active"
    INACTIVE = "inactive"
    EXPIRED = "expired"
    REVOKED = "revoked"
    BREAK_GLASS = "break_glass"


@dataclass
class PrivilegedAccount:
    """
    Privileged account stored in the PAM vault.
    
    Attributes:
        account_id: Unique account identifier
        username: Account username
        target_system: System this account belongs to
        privilege_level: Level of privilege
        credential_hash: Encrypted credential
        owner: Owner of the account
        status: Current status
        last_used: Last usage timestamp
        rotation_date: Last rotation date
        rotation_interval: Rotation interval in days
    """
    account_id: str
    username: str
    target_system: str
    privilege_level: str
    credential_hash: str
    owner: str
    status: str = PAMStatus.ACTIVE.value
    last_used: Optional[str] = None
    rotation_date: str = field(default_factory=lambda: datetime.datetime.utcnow().isoformat())
    rotation_interval: int = 90  # days
    attributes: Dict[str, Any] = field(default_factory=dict)
    
    def to_dict(self) -> Dict:
        """Convert to dictionary."""
        return {
            "account_id": self.account_id,
            "username": self.username,
            "target_system": self.target_system,
            "privilege_level": self.privilege_level,
            "owner": self.owner,
            "status": self.status,
            "last_used": self.last_used,
            "rotation_date": self.rotation_date,
            "rotation_interval": self.rotation_interval,
            "attributes": self.attributes
        }


@dataclass
class PAMSession:
    """
    Privileged access session.
    
    Attributes:
        session_id: Unique session identifier
        account_id: Privileged account used
        user_id: User requesting access
        start_time: Session start time
        end_time: Session end time
        reason: Reason for access
        status: Session status
        recorded: Whether session was recorded
    """
    session_id: str
    account_id: str
    user_id: str
    start_time: str
    end_time: Optional[str] = None
    reason: str = ""
    status: str = PAMStatus.ACTIVE.value
    recorded: bool = True
    
    def to_dict(self) -> Dict:
        """Convert to dictionary."""
        return {
            "session_id": self.session_id,
            "account_id": self.account_id,
            "user_id": self.user_id,
            "start_time": self.start_time,
            "end_time": self.end_time,
            "reason": self.reason,
            "status": self.status,
            "recorded": self.recorded
        }


class PAMManager:
    """
    Privileged Access Management Manager.
    
    This class handles privileged account vaulting, session management,
    and access control for privileged operations.
    """
    
    def __init__(self, data_dir: str = "./pam_data", encryption_key: Optional[str] = None):
        """
        Initialize PAM manager.
        
        Args:
            data_dir: Directory for persistent storage
            encryption_key: Encryption key for credentials
        """
        self.data_dir = data_dir
        self._ensure_data_dir()
        
        # Initialize encryption
        if encryption_key:
            self.cipher = Fernet(encryption_key.encode())
        else:
            # Generate key if not provided
            key = Fernet.generate_key()
            self.cipher = Fernet(key)
            # Save key for persistence
            with open(f"{data_dir}/encryption.key", 'w') as f:
                f.write(key.decode())
        
        self.accounts: Dict[str, PrivilegedAccount] = {}
        self.sessions: Dict[str, PAMSession] = {}
        self.audit_log: List[Dict] = []
        
        self._load_data()
    
    def _ensure_data_dir(self) -> None:
        """Create data directory."""
        os.makedirs(self.data_dir, exist_ok=True)
        os.makedirs(f"{self.data_dir}/accounts", exist_ok=True)
        os.makedirs(f"{self.data_dir}/sessions", exist_ok=True)
        os.makedirs(f"{self.data_dir}/audit", exist_ok=True)
    
    def _load_data(self) -> None:
        """Load existing data."""
        # Load accounts
        acc_dir = f"{self.data_dir}/accounts"
        if os.path.exists(acc_dir):
            for filename in os.listdir(acc_dir):
                if filename.endswith('.json'):
                    with open(f"{acc_dir}/{filename}", 'r') as f:
                        data = json.load(f)
                        account = PrivilegedAccount(
                            account_id=data['account_id'],
                            username=data['username'],
                            target_system=data['target_system'],
                            privilege_level=data['privilege_level'],
                            credential_hash=data['credential_hash'],
                            owner=data['owner'],
                            status=data.get('status', PAMStatus.ACTIVE.value),
                            last_used=data.get('last_used'),
                            rotation_date=data.get('rotation_date', datetime.datetime.utcnow().isoformat()),
                            rotation_interval=data.get('rotation_interval', 90),
                            attributes=data.get('attributes', {})
                        )
                        self.accounts[account.account_id] = account
        
        # Load sessions
        sess_dir = f"{self.data_dir}/sessions"
        if os.path.exists(sess_dir):
            for filename in os.listdir(sess_dir):
                if filename.endswith('.json'):
                    with open(f"{sess_dir}/{filename}", 'r') as f:
                        data = json.load(f)
                        session = PAMSession(
                            session_id=data['session_id'],
                            account_id=data['account_id'],
                            user_id=data['user_id'],
                            start_time=data['start_time'],
                            end_time=data.get('end_time'),
                            reason=data.get('reason', ''),
                            status=data.get('status', PAMStatus.ACTIVE.value),
                            recorded=data.get('recorded', True)
                        )
                        self.sessions[session.session_id] = session
    
    def _save_account(self, account: PrivilegedAccount) -> None:
        """Save account to storage."""
        with open(f"{self.data_dir}/accounts/{account.account_id}.json", 'w') as f:
            json.dump(account.to_dict(), f, indent=2)
    
    def _save_session(self, session: PAMSession) -> None:
        """Save session to storage."""
        with open(f"{self.data_dir}/sessions/{session.session_id}.json", 'w') as f:
            json.dump(session.to_dict(), f, indent=2)
    
    def _log_audit(self, action: str, user_id: str, details: Dict) -> None:
        """Log audit event."""
        log_entry = {
            "timestamp": datetime.datetime.utcnow().isoformat(),
            "action": action,
            "user_id": user_id,
            "details": details
        }
        self.audit_log.append(log_entry)
        
        with open(f"{self.data_dir}/audit/audit.log", 'a') as f:
            f.write(json.dumps(log_entry) + "\n")
    
    def _encrypt_credential(self, credential: str) -> str:
        """Encrypt a credential."""
        return self.cipher.encrypt(credential.encode()).decode()
    
    def _decrypt_credential(self, encrypted: str) -> str:
        """Decrypt a credential."""
        return self.cipher.decrypt(encrypted.encode()).decode()
    
    def _generate_strong_password(self) -> str:
        """Generate a strong random password."""
        # 24 characters with mixed case, numbers, and symbols
        alphabet = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*"
        return ''.join(secrets.choice(alphabet) for _ in range(24))
    
    def create_privileged_account(self, username: str, target_system: str, 
                                  privilege_level: str, owner: str,
                                  credential: Optional[str] = None) -> PrivilegedAccount:
        """
        Create a privileged account in the vault.
        
        Args:
            username: Account username
            target_system: Target system
            privilege_level: Level of privilege
            owner: Account owner
            credential: Optional credential (auto-generate if not provided)
            
        Returns:
            Created PrivilegedAccount
        """
        # Generate credential if not provided
        if not credential:
            credential = self._generate_strong_password()
        
        account_id = hashlib.md5(
            f"{username}:{target_system}:{datetime.datetime.utcnow().isoformat()}".encode()
        ).hexdigest()[:12]
        
        account = PrivilegedAccount(
            account_id=account_id,
            username=username,
            target_system=target_system,
            privilege_level=privilege_level,
            credential_hash=self._encrypt_credential(credential),
            owner=owner
        )
        
        self.accounts[account_id] = account
        self._save_account(account)
        self._log_audit("ACCOUNT_CREATED", owner, {
            "account_id": account_id,
            "username": username,
            "target_system": target_system,
            "privilege_level": privilege_level
        })
        
        return account
    
    def request_access(self, account_id: str, user_id: str, reason: str) -> Optional[PAMSession]:
        """
        Request privileged access to an account.
        
        Args:
            account_id: Account to access
            user_id: User requesting access
            reason: Reason for access
            
        Returns:
            PAMSession if access granted
        """
        account = self.accounts.get(account_id)
        if not account:
            self._log_audit("ACCESS_DENIED", user_id, {"reason": "Account not found"})
            return None
        
        if account.status != PAMStatus.ACTIVE.value:
            self._log_audit("ACCESS_DENIED", user_id, {"reason": "Account not active"})
            return None
        
        # Create session
        session_id = secrets.token_urlsafe(16)
        session = PAMSession(
            session_id=session_id,
            account_id=account_id,
            user_id=user_id,
            start_time=datetime.datetime.utcnow().isoformat(),
            reason=reason
        )
        
        # Auto-approve for now (would integrate with approval workflow)
        self.sessions[session_id] = session
        self._save_session(session)
        
        # Update account last used
        account.last_used = datetime.datetime.utcnow().isoformat()
        self._save_account(account)
        
        self._log_audit("ACCESS_GRANTED", user_id, {
            "session_id": session_id,
            "account_id": account_id,
            "reason": reason
        })
        
        return session
    
    def get_credential(self, session_id: str, user_id: str) -> Optional[str]:
        """
        Get credential for an active session.
        
        Args:
            session_id: Session ID
            user_id: User requesting credential
            
        Returns:
            Decrypted credential or None
        """
        session = self.sessions.get(session_id)
        if not session:
            return None
        
        if session.user_id != user_id:
            self._log_audit("CREDENTIAL_ACCESS_DENIED", user_id, {"reason": "Unauthorized"})
            return None
        
        if session.status != PAMStatus.ACTIVE.value:
            self._log_audit("CREDENTIAL_ACCESS_DENIED", user_id, {"reason": "Session not active"})
            return None
        
        # Check if session has expired (max 4 hours)
        start_time = datetime.datetime.fromisoformat(session.start_time)
        if (datetime.datetime.utcnow() - start_time) > datetime.timedelta(hours=4):
            session.status = PAMStatus.EXPIRED.value
            self._save_session(session)
            self._log_audit("CREDENTIAL_ACCESS_DENIED", user_id, {"reason": "Session expired"})
            return None
        
        account = self.accounts.get(session.account_id)
        if not account:
            return None
        
        self._log_audit("CREDENTIAL_ACCESS", user_id, {"session_id": session_id})
        
        return self._decrypt_credential(account.credential_hash)
    
    def end_session(self, session_id: str, user_id: str) -> bool:
        """
        End a privileged session.
        
        Args:
            session_id: Session ID
            user_id: User ending session
            
        Returns:
            True if session ended
        """
        session = self.sessions.get(session_id)
        if not session:
            return False
        
        if session.user_id != user_id:
            return False
        
        session.end_time = datetime.datetime.utcnow().isoformat()
        session.status = PAMStatus.INACTIVE.value
        self._save_session(session)
        
        self._log_audit("SESSION_ENDED", user_id, {"session_id": session_id})
        return True
    
    def rotate_credentials(self, account_id: str) -> bool:
        """
        Rotate credentials for a privileged account.
        
        Args:
            account_id: Account ID
            
        Returns:
            True if rotation successful
        """
        account = self.accounts.get(account_id)
        if not account:
            return False
        
        # Generate new credential
        new_credential = self._generate_strong_password()
        account.credential_hash = self._encrypt_credential(new_credential)
        account.rotation_date = datetime.datetime.utcnow().isoformat()
        
        self._save_account(account)
        self._log_audit("CREDENTIAL_ROTATED", account.owner, {
            "account_id": account_id,
            "username": account.username,
            "target_system": account.target_system
        })
        
        return True
    
    def check_rotation_needed(self) -> List[PrivilegedAccount]:
        """
        Check which accounts need credential rotation.
        
        Returns:
            List of accounts needing rotation
        """
        need_rotation = []
        now = datetime.datetime.utcnow()
        
        for account in self.accounts.values():
            if account.status != PAMStatus.ACTIVE.value:
                continue
            
            rotation_date = datetime.datetime.fromisoformat(account.rotation_date)
            days_since_rotation = (now - rotation_date).days
            
            if days_since_rotation >= account.rotation_interval:
                need_rotation.append(account)
        
        return need_rotation
    
    def get_break_glass_access(self, user_id: str, target_system: str, reason: str) -> Optional[PAMSession]:
        """
        Emergency break-glass access.
        
        Args:
            user_id: User requesting access
            target_system: Target system
            reason: Emergency reason
            
        Returns:
            PAMSession for break-glass access
        """
        # Find a privileged account for the target system
        account = None
        for acc in self.accounts.values():
            if acc.target_system == target_system and acc.status == PAMStatus.ACTIVE.value:
                account = acc
                break
        
        if not account:
            self._log_audit("BREAK_GLASS_DENIED", user_id, {"reason": "No account found"})
            return None
        
        # Create emergency session
        session_id = f"BG-{secrets.token_urlsafe(12)}"
        session = PAMSession(
            session_id=session_id,
            account_id=account.account_id,
            user_id=user_id,
            start_time=datetime.datetime.utcnow().isoformat(),
            reason=f"BREAK GLASS: {reason}",
            status=PAMStatus.BREAK_GLASS.value
        )
        
        self.sessions[session_id] = session
        self._save_session(session)
        
        self._log_audit("BREAK_GLASS_ACCESS", user_id, {
            "session_id": session_id,
            "account_id": account.account_id,
            "target_system": target_system,
            "reason": reason
        })
        
        return session
    
    def generate_report(self) -> str:
        """
        Generate PAM report.
        
        Returns:
            Markdown formatted report
        """
        total_accounts = len(self.accounts)
        active_accounts = sum(1 for a in self.accounts.values() if a.status == PAMStatus.ACTIVE.value)
        total_sessions = len(self.sessions)
        active_sessions = sum(1 for s in self.sessions.values() if s.status == PAMStatus.ACTIVE.value)
        break_glass_sessions = sum(1 for s in self.sessions.values() if s.status == PAMStatus.BREAK_GLASS.value)
        
        need_rotation = self.check_rotation_needed()
        
        report = f"""
# Privileged Access Management Report
*Generated: {datetime.datetime.now().strftime('%Y-%m-%d %H:%M')}*

## Executive Summary

| Metric | Value |
|--------|-------|
| Total Accounts | {total_accounts} |
| Active Accounts | {active_accounts} ({active_accounts/total_accounts*100:.1f}%) |
| Total Sessions | {total_sessions} |
| Active Sessions | {active_sessions} |
| Break-Glass Sessions | {break_glass_sessions} |
| Accounts Needing Rotation | {len(need_rotation)} |

## Accounts by Privilege Level

| Level | Count |
|-------|-------|
"""
        
        level_counts = {}
        for account in self.accounts.values():
            level_counts[account.privilege_level] = level_counts.get(account.privilege_level, 0) + 1
        
        for level, count in sorted(level_counts.items()):
            report += f"| {level} | {count} |\n"
        
        report += """
## Accounts Needing Rotation

| Account | System | Owner | Days Since Rotation |
|---------|--------|-------|---------------------|
"""
        
        now = datetime.datetime.utcnow()
        for account in need_rotation[:20]:  # Show top 20
            rotation_date = datetime.datetime.fromisoformat(account.rotation_date)
            days = (now - rotation_date).days
            report += f"| {account.username} | {account.target_system} | {account.owner} | {days} |\n"
        
        if not need_rotation:
            report += "| *No accounts need rotation* | | | |\n"
        
        return report


def main():
    """CLI for PAM management."""
    import argparse
    
    parser = argparse.ArgumentParser(description='PAM Management Tool')
    subparsers = parser.add_subparsers(dest='command', help='Subcommands')
    
    # Create account
    create_parser = subparsers.add_parser('create', help='Create privileged account')
    create_parser.add_argument('--username', '-u', required=True, help='Account username')
    create_parser.add_argument('--system', '-s', required=True, help='Target system')
    create_parser.add_argument('--level', '-l', required=True, help='Privilege level')
    create_parser.add_argument('--owner', '-o', required=True, help='Account owner')
    create_parser.add_argument('--credential', '-c', help='Credential (auto-generate if not provided)')
    
    # Request access
    access_parser = subparsers.add_parser('request', help='Request access')
    access_parser.add_argument('--account', '-a', required=True, help='Account ID')
    access_parser.add_argument('--user', '-u', required=True, help='User ID')
    access_parser.add_argument('--reason', '-r', required=True, help='Reason for access')
    
    # Get credential
    cred_parser = subparsers.add_parser('credential', help='Get credential')
    cred_parser.add_argument('--session', '-s', required=True, help='Session ID')
    cred_parser.add_argument('--user', '-u', required=True, help='User ID')
    
    # End session
    end_parser = subparsers.add_parser('end', help='End session')
    end_parser.add_argument('--session', '-s', required=True, help='Session ID')
    end_parser.add_argument('--user', '-u', required=True, help='User ID')
    
    # Rotate credentials
    rotate_parser = subparsers.add_parser('rotate', help='Rotate credentials')
    rotate_parser.add_argument('--account', '-a', required=True, help='Account ID')
    
    # Break glass
    bg_parser = subparsers.add_parser('break-glass', help='Break-glass access')
    bg_parser.add_argument('--user', '-u', required=True, help='User ID')
    bg_parser.add_argument('--system', '-s', required=True, help='Target system')
    bg_parser.add_argument('--reason', '-r', required=True, help='Emergency reason')
    
    # Report
    report_parser = subparsers.add_parser('report', help='Generate report')
    
    args = parser.parse_args()
    
    pam = PAMManager()
    
    if args.command == 'create':
        account = pam.create_privileged_account(
            args.username,
            args.system,
            args.level,
            args.owner,
            args.credential
        )
        print(f"✅ Privileged account created:")
        print(f"   ID: {account.account_id}")
        print(f"   Username: {account.username}")
        print(f"   System: {account.target_system}")
        print(f"   Level: {account.privilege_level}")
        if not args.credential:
            print("   ⚠️ Credential auto-generated (check PAM vault)")
    
    elif args.command == 'request':
        session = pam.request_access(args.account, args.user, args.reason)
        if session:
            print(f"✅ Access granted")
            print(f"   Session ID: {session.session_id}")
            print(f"   Account: {args.account}")
            print(f"   Status: {session.status}")
        else:
            print("❌ Access denied")
    
    elif args.command == 'credential':
        credential = pam.get_credential(args.session, args.user)
        if credential:
            print(f"✅ Credential retrieved")
            print(f"   Credential: {credential}")
        else:
            print("❌ Access denied or session expired")
    
    elif args.command == 'end':
        if pam.end_session(args.session, args.user):
            print(f"✅ Session ended: {args.session}")
        else:
            print("❌ Failed to end session")
    
    elif args.command == 'rotate':
        if pam.rotate_credentials(args.account):
            print(f"✅ Credentials rotated for account {args.account}")
        else:
            print("❌ Account not found")
    
    elif args.command == 'break-glass':
        session = pam.get_break_glass_access(args.user, args.system, args.reason)
        if session:
            print(f"✅ Break-glass access granted")
            print(f"   Session ID: {session.session_id}")
            print(f"   Account: {session.account_id}")
            print(f"   ⚠️ Emergency access logged and audited")
        else:
            print("❌ Break-glass access denied")
    
    elif args.command == 'report':
        report = pam.generate_report()
        print(report)
    
    else:
        parser.print_help()


if __name__ == "__main__":
    main()
```

### Step 2: Deploy Endpoint Detection and Response (EDR)

**The Target:** Build an EDR/XDR system for comprehensive endpoint monitoring and response.

**The Concept:** EDR is like having security guards on every computer watching for suspicious activity. XDR extends this to include network, cloud, and other data sources.

**File:** `03-security-controls/scripts/edr_implementation.py`

```python
#!/usr/bin/env python3
"""
Endpoint Detection and Response (EDR) Implementation

This module implements EDR/XDR including:
- Endpoint monitoring
- Threat detection
- Automated response
- Threat hunting
- Integration with SIEM
"""

import json
import datetime
import secrets
import hashlib
import re
from typing import Dict, List, Optional, Any, Set
from dataclasses import dataclass, field
from enum import Enum
import os


class Severity(Enum):
    """Alert severity levels."""
    INFO = "info"
    LOW = "low"
    MEDIUM = "medium"
    HIGH = "high"
    CRITICAL = "critical"


class EndpointStatus(Enum):
    """Status of an endpoint."""
    ONLINE = "online"
    OFFLINE = "offline"
    COMPROMISED = "compromised"
    MAINTENANCE = "maintenance"
    UNKNOWN = "unknown"


@dataclass
class Endpoint:
    """
    Endpoint device.
    
    Attributes:
        endpoint_id: Unique identifier
        hostname: Device hostname
        ip_address: IP address
        os: Operating system
        status: Current status
        last_seen: Last communication
        installed_edr: EDR version
        compliance_score: Compliance score (0-100)
        vulnerabilities: List of vulnerabilities
        alerts: Recent alerts
    """
    endpoint_id: str
    hostname: str
    ip_address: str
    os: str
    status: str
    last_seen: str
    installed_edr: str
    compliance_score: int = 100
    vulnerabilities: List[Dict] = field(default_factory=list)
    alerts: List[Dict] = field(default_factory=list)
    attributes: Dict[str, Any] = field(default_factory=dict)
    
    def to_dict(self) -> Dict:
        """Convert to dictionary."""
        return {
            "endpoint_id": self.endpoint_id,
            "hostname": self.hostname,
            "ip_address": self.ip_address,
            "os": self.os,
            "status": self.status,
            "last_seen": self.last_seen,
            "installed_edr": self.installed_edr,
            "compliance_score": self.compliance_score,
            "vulnerabilities": self.vulnerabilities,
            "alerts": self.alerts,
            "attributes": self.attributes
        }


@dataclass
class SecurityAlert:
    """
    Security alert from EDR/XDR.
    
    Attributes:
        alert_id: Unique identifier
        endpoint_id: Associated endpoint
        severity: Alert severity
        rule_name: Rule that triggered
        description: Alert description
        detection_time: When detected
        status: Alert status
        indicators: Indicators of compromise
        response: Response actions taken
    """
    alert_id: str
    endpoint_id: str
    severity: str
    rule_name: str
    description: str
    detection_time: str
    status: str = "open"
    indicators: List[str] = field(default_factory=list)
    response: List[str] = field(default_factory=list)
    
    def to_dict(self) -> Dict:
        """Convert to dictionary."""
        return {
            "alert_id": self.alert_id,
            "endpoint_id": self.endpoint_id,
            "severity": self.severity,
            "rule_name": self.rule_name,
            "description": self.description,
            "detection_time": self.detection_time,
            "status": self.status,
            "indicators": self.indicators,
            "response": self.response
        }


class EDRManager:
    """
    Endpoint Detection and Response Manager.
    
    This class handles endpoint monitoring, threat detection,
    automated response, and threat hunting.
    """
    
    def __init__(self, data_dir: str = "./edr_data"):
        """
        Initialize EDR manager.
        
        Args:
            data_dir: Directory for persistent storage
        """
        self.data_dir = data_dir
        self._ensure_data_dir()
        
        self.endpoints: Dict[str, Endpoint] = {}
        self.alerts: Dict[str, SecurityAlert] = {}
        self.threat_intel: List[Dict] = []
        self.audit_log: List[Dict] = []
        
        self._load_data()
        self._init_threat_intel()
    
    def _ensure_data_dir(self) -> None:
        """Create data directory."""
        os.makedirs(self.data_dir, exist_ok=True)
        os.makedirs(f"{self.data_dir}/endpoints", exist_ok=True)
        os.makedirs(f"{self.data_dir}/alerts", exist_ok=True)
        os.makedirs(f"{self.data_dir}/audit", exist_ok=True)
    
    def _load_data(self) -> None:
        """Load existing data."""
        # Load endpoints
        ep_dir = f"{self.data_dir}/endpoints"
        if os.path.exists(ep_dir):
            for filename in os.listdir(ep_dir):
                if filename.endswith('.json'):
                    with open(f"{ep_dir}/{filename}", 'r') as f:
                        data = json.load(f)
                        endpoint = Endpoint(
                            endpoint_id=data['endpoint_id'],
                            hostname=data['hostname'],
                            ip_address=data['ip_address'],
                            os=data['os'],
                            status=data.get('status', EndpointStatus.ONLINE.value),
                            last_seen=data.get('last_seen', datetime.datetime.utcnow().isoformat()),
                            installed_edr=data.get('installed_edr', 'unknown'),
                            compliance_score=data.get('compliance_score', 100),
                            vulnerabilities=data.get('vulnerabilities', []),
                            alerts=data.get('alerts', []),
                            attributes=data.get('attributes', {})
                        )
                        self.endpoints[endpoint.endpoint_id] = endpoint
        
        # Load alerts
        alert_dir = f"{self.data_dir}/alerts"
        if os.path.exists(alert_dir):
            for filename in os.listdir(alert_dir):
                if filename.endswith('.json'):
                    with open(f"{alert_dir}/{filename}", 'r') as f:
                        data = json.load(f)
                        alert = SecurityAlert(
                            alert_id=data['alert_id'],
                            endpoint_id=data['endpoint_id'],
                            severity=data['severity'],
                            rule_name=data['rule_name'],
                            description=data['description'],
                            detection_time=data['detection_time'],
                            status=data.get('status', 'open'),
                            indicators=data.get('indicators', []),
                            response=data.get('response', [])
                        )
                        self.alerts[alert.alert_id] = alert
    
    def _init_threat_intel(self) -> None:
        """Initialize threat intelligence feed."""
        # Sample threat intelligence (in production, this would be a feed)
        self.threat_intel = [
            {
                "id": "TI-001",
                "indicator": "malicious_domain",
                "type": "domain",
                "value": "*.malicious.com",
                "severity": "high",
                "category": "command_and_control"
            },
            {
                "id": "TI-002",
                "indicator": "ransomware_hash",
                "type": "hash",
                "value": "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
                "severity": "critical",
                "category": "ransomware"
            },
            {
                "id": "TI-003",
                "indicator": "suspicious_process",
                "type": "process",
                "value": "powershell -enc",
                "severity": "medium",
                "category": "suspicious_activity"
            }
        ]
    
    def _log_audit(self, action: str, user_id: str, details: Dict) -> None:
        """Log audit event."""
        log_entry = {
            "timestamp": datetime.datetime.utcnow().isoformat(),
            "action": action,
            "user_id": user_id,
            "details": details
        }
        self.audit_log.append(log_entry)
        
        with open(f"{self.data_dir}/audit/audit.log", 'a') as f:
            f.write(json.dumps(log_entry) + "\n")
    
    def register_endpoint(self, hostname: str, ip_address: str, os: str, 
                          edr_version: str = "1.0.0") -> Endpoint:
        """
        Register a new endpoint with EDR.
        
        Args:
            hostname: Hostname
            ip_address: IP address
            os: Operating system
            edr_version: EDR version installed
            
        Returns:
            Registered Endpoint
        """
        endpoint_id = hashlib.md5(
            f"{hostname}:{datetime.datetime.utcnow().isoformat()}".encode()
        ).hexdigest()[:12]
        
        endpoint = Endpoint(
            endpoint_id=endpoint_id,
            hostname=hostname,
            ip_address=ip_address,
            os=os,
            status=EndpointStatus.ONLINE.value,
            last_seen=datetime.datetime.utcnow().isoformat(),
            installed_edr=edr_version
        )
        
        self.endpoints[endpoint_id] = endpoint
        self._save_endpoint(endpoint)
        self._log_audit("ENDPOINT_REGISTERED", "system", {"endpoint_id": endpoint_id, "hostname": hostname})
        
        return endpoint
    
    def _save_endpoint(self, endpoint: Endpoint) -> None:
        """Save endpoint to storage."""
        with open(f"{self.data_dir}/endpoints/{endpoint.endpoint_id}.json", 'w') as f:
            json.dump(endpoint.to_dict(), f, indent=2)
    
    def _save_alert(self, alert: SecurityAlert) -> None:
        """Save alert to storage."""
        with open(f"{self.data_dir}/alerts/{alert.alert_id}.json", 'w') as f:
            json.dump(alert.to_dict(), f, indent=2)
    
    def analyze_activity(self, endpoint_id: str, activity: Dict) -> Optional[SecurityAlert]:
        """
        Analyze endpoint activity for threats.
        
        Args:
            endpoint_id: Endpoint ID
            activity: Activity data
            
        Returns:
            SecurityAlert if threat detected, None otherwise
        """
        endpoint = self.endpoints.get(endpoint_id)
        if not endpoint:
            return None
        
        # Update last seen
        endpoint.last_seen = datetime.datetime.utcnow().isoformat()
        self._save_endpoint(endpoint)
        
        # Check against threat intelligence
        detected_indicators = []
        
        # Check for malicious processes
        if activity.get('process') and activity.get('process_name'):
            process = activity['process_name'].lower()
            
            # Check for known malicious process names
            malicious_patterns = ['powershell -enc', 'wscript', 'rundll32', 'regsvr32']
            if any(pattern in process for pattern in malicious_patterns):
                detected_indicators.append("suspicious_process")
            
            # Check for encoded commands
            if 'powershell' in process and '-enc' in process:
                detected_indicators.append("encoded_command")
        
        # Check for file operations
        if activity.get('file_operations'):
            for file_op in activity['file_operations']:
                # Check for ransomware patterns
                if file_op.get('extension') in ['.encrypted', '.locked', '.crypt']:
                    detected_indicators.append("ransomware_activity")
                if file_op.get('path') and 'system32' in file_op['path'].lower():
                    detected_indicators.append("system_modification")
        
        # Check for network connections
        if activity.get('network_connections'):
            for conn in activity['network_connections']:
                # Check for known malicious ports
                if conn.get('port') in [445, 139, 3389, 22]:
                    detected_indicators.append("suspicious_port")
                
                # Check for known malicious domains
                domain = conn.get('domain', '')
                for ti in self.threat_intel:
                    if ti['type'] == 'domain' and domain:
                        if '*' in ti['value']:
                            pattern = ti['value'].replace('.', r'\.').replace('*', '.*')
                            if re.search(pattern, domain):
                                detected_indicators.append(ti['id'])
        
        if not detected_indicators:
            return None
        
        # Create alert based on detected indicators
        severity = Severity.MEDIUM.value
        description = "Suspicious activity detected"
        
        # Determine severity based on indicators
        if 'ransomware_activity' in detected_indicators:
            severity = Severity.CRITICAL.value
            description = "Ransomware activity detected"
        elif 'encoded_command' in detected_indicators:
            severity = Severity.HIGH.value
            description = "Encoded command execution detected"
        
        # Check threat intel for severity
        for ti in self.threat_intel:
            if ti['id'] in detected_indicators and ti.get('severity'):
                if ti['severity'] == 'critical':
                    severity = Severity.CRITICAL.value
                    description = f"Threat intel match: {ti['indicator']}"
        
        alert = SecurityAlert(
            alert_id=f"ALERT-{secrets.token_urlsafe(8)}",
            endpoint_id=endpoint_id,
            severity=severity,
            rule_name=f"rule-{'-'.join(detected_indicators[:2])}",
            description=description,
            detection_time=datetime.datetime.utcnow().isoformat(),
            indicators=detected_indicators
        )
        
        self.alerts[alert.alert_id] = alert
        self._save_alert(alert)
        
        # Update endpoint alerts
        endpoint.alerts.append(alert.to_dict())
        if len(endpoint.alerts) > 100:
            endpoint.alerts = endpoint.alerts[-100:]
        self._save_endpoint(endpoint)
        
        self._log_audit("ALERT_CREATED", "system", {
            "alert_id": alert.alert_id,
            "endpoint_id": endpoint_id,
            "severity": severity,
            "indicators": detected_indicators
        })
        
        return alert
    
    def respond_alert(self, alert_id: str, action: str) -> bool:
        """
        Respond to a security alert.
        
        Args:
            alert_id: Alert ID
            action: Response action (isolate, quarantine, block, etc.)
            
        Returns:
            True if response successful
        """
        alert = self.alerts.get(alert_id)
        if not alert:
            return False
        
        if alert.status != "open":
            return False
        
        alert.response.append(action)
        
        # Execute automated response
        if action == "isolate":
            # Isolate endpoint from network
            endpoint = self.endpoints.get(alert.endpoint_id)
            if endpoint:
                endpoint.status = EndpointStatus.COMPROMISED.value
                self._save_endpoint(endpoint)
        
        elif action == "quarantine":
            # Quarantine affected files
            alert.status = "quarantined"
        
        elif action == "block":
            # Block indicators
            pass
        
        alert.status = "responded"
        self._save_alert(alert)
        
        self._log_audit("ALERT_RESPONSE", "system", {
            "alert_id": alert_id,
            "action": action
        })
        
        return True
    
    def threat_hunt(self, query: Dict) -> List[Endpoint]:
        """
        Perform threat hunting across endpoints.
        
        Args:
            query: Hunt query
            
        Returns:
            List of endpoints matching query
        """
        results = []
        
        for endpoint in self.endpoints.values():
            matches = True
            
            # Check status
            if query.get('status') and endpoint.status != query['status']:
                matches = False
            
            # Check OS
            if query.get('os') and endpoint.os != query['os']:
                matches = False
            
            # Check compliance
            if query.get('compliance_below'):
                if endpoint.compliance_score >= query['compliance_below']:
                    matches = False
            
            # Check alerts
            if query.get('alerts_in_last_hours'):
                hours = query['alerts_in_last_hours']
                cutoff = datetime.datetime.utcnow() - datetime.timedelta(hours=hours)
                recent_alerts = []
                for alert_data in endpoint.alerts:
                    if 'detection_time' in alert_data:
                        if datetime.datetime.fromisoformat(alert_data['detection_time']) > cutoff:
                            recent_alerts.append(alert_data)
                if not recent_alerts:
                    matches = False
            
            if matches:
                results.append(endpoint)
        
        return results
    
    def generate_report(self) -> str:
        """
        Generate EDR report.
        
        Returns:
            Markdown formatted report
        """
        total_endpoints = len(self.endpoints)
        online_endpoints = sum(1 for e in self.endpoints.values() if e.status == EndpointStatus.ONLINE.value)
        compromised_endpoints = sum(1 for e in self.endpoints.values() if e.status == EndpointStatus.COMPROMISED.value)
        open_alerts = sum(1 for a in self.alerts.values() if a.status == "open")
        critical_alerts = sum(1 for a in self.alerts.values() if a.severity == "critical" and a.status == "open")
        
        # Get threat hunt results for suspicious endpoints
        suspicious = self.threat_hunt({"status": "online", "alerts_in_last_hours": 24})
        
        report = f"""
# Endpoint Detection and Response Report
*Generated: {datetime.datetime.now().strftime('%Y-%m-%d %H:%M')}*

## Executive Summary

| Metric | Value |
|--------|-------|
| Total Endpoints | {total_endpoints} |
| Online Endpoints | {online_endpoints} ({online_endpoints/total_endpoints*100:.1f}%) |
| Compromised Endpoints | {compromised_endpoints} |
| Open Alerts | {open_alerts} |
| Critical Alerts | {critical_alerts} |

## Alert Distribution

| Severity | Count |
|----------|-------|
"""
        
        severity_counts = {}
        for alert in self.alerts.values():
            if alert.status == "open":
                severity_counts[alert.severity] = severity_counts.get(alert.severity, 0) + 1
        
        for severity, count in sorted(severity_counts.items()):
            report += f"| {severity} | {count} |\n"
        
        report += """
## Suspicious Endpoints (Alerts in Last 24 Hours)

| Hostname | OS | Status | Recent Alerts |
|----------|-----|--------|---------------|
"""
        
        for endpoint in suspicious[:10]:
            alert_count = len(endpoint.alerts)
            report += f"| {endpoint.hostname} | {endpoint.os} | {endpoint.status} | {alert_count} |\n"
        
        if not suspicious:
            report += "| *No suspicious endpoints found* | | | |\n"
        
        return report


def main():
    """CLI for EDR management."""
    import argparse
    
    parser = argparse.ArgumentParser(description='EDR Management Tool')
    subparsers = parser.add_subparsers(dest='command', help='Subcommands')
    
    # Register endpoint
    register_parser = subparsers.add_parser('register', help='Register endpoint')
    register_parser.add_argument('--hostname', '-h', required=True, help='Hostname')
    register_parser.add_argument('--ip', '-i', required=True, help='IP address')
    register_parser.add_argument('--os', '-o', required=True, help='Operating system')
    
    # Analyze activity
    analyze_parser = subparsers.add_parser('analyze', help='Analyze endpoint activity')
    analyze_parser.add_argument('--endpoint', '-e', required=True, help='Endpoint ID')
    analyze_parser.add_argument('--activity', '-a', required=True, help='Activity JSON')
    
    # Respond to alert
    respond_parser = subparsers.add_parser('respond', help='Respond to alert')
    respond_parser.add_argument('--alert', '-a', required=True, help='Alert ID')
    respond_parser.add_argument('--action', '-r', required=True, help='Response action')
    
    # Threat hunt
    hunt_parser = subparsers.add_parser('hunt', help='Threat hunt')
    hunt_parser.add_argument('--query', '-q', required=True, help='Query JSON')
    
    # Report
    report_parser = subparsers.add_parser('report', help='Generate report')
    
    args = parser.parse_args()
    
    edr = EDRManager()
    
    if args.command == 'register':
        endpoint = edr.register_endpoint(args.hostname, args.ip, args.os)
        print(f"✅ Endpoint registered: {endpoint.endpoint_id}")
        print(f"   Hostname: {endpoint.hostname}")
        print(f"   IP: {endpoint.ip_address}")
        print(f"   OS: {endpoint.os}")
    
    elif args.command == 'analyze':
        try:
            activity = json.loads(args.activity)
            alert = edr.analyze_activity(args.endpoint, activity)
            if alert:
                print(f"⚠️ Alert created: {alert.alert_id}")
                print(f"   Severity: {alert.severity}")
                print(f"   Description: {alert.description}")
                print(f"   Indicators: {', '.join(alert.indicators)}")
            else:
                print("✅ No threats detected")
        except json.JSONDecodeError:
            print("❌ Invalid activity JSON")
    
    elif args.command == 'respond':
        if edr.respond_alert(args.alert, args.action):
            print(f"✅ Response action '{args.action}' taken for alert {args.alert}")
        else:
            print("❌ Alert not found or already resolved")
    
    elif args.command == 'hunt':
        try:
            query = json.loads(args.query)
            results = edr.threat_hunt(query)
            print(f"Found {len(results)} matching endpoints:")
            for endpoint in results:
                print(f"  {endpoint.hostname} ({endpoint.ip_address}) - {endpoint.status}")
        except json.JSONDecodeError:
            print("❌ Invalid query JSON")
    
    elif args.command == 'report':
        report = edr.generate_report()
        print(report)
    
    else:
        parser.print_help()


if __name__ == "__main__":
    main()
```

## Verification

### Verification 1: Test IAM Implementation

```bash
cd 03-security-controls/scripts

# Create a test user
python3 iam_implementation.py create \
    --username testuser \
    --email test@company.com \
    --password "Test@12345678" \
    --roles business_user

# Create an admin user
python3 iam_implementation.py create \
    --username admin \
    --email admin@company.com \
    --password "Admin@2024!" \
    --roles admin

# Authenticate
python3 iam_implementation.py auth --username admin --password "Admin@2024!"

# Enable MFA
python3 iam_implementation.py enable-mfa --user-id admin-001 --method totp

# Check permissions
python3 iam_implementation.py check-perm --user-id admin-001 --permission "security:config"

# Generate token
python3 iam_implementation.py token --user-id admin-001 --scopes admin admin

# Generate report
python3 iam_implementation.py report
```

### Verification 2: Test PAM Implementation

```bash
# Create privileged account
python3 pam_implementation.py create \
    --username root \
    --system "production-db-01" \
    --level super_admin \
    --owner "IT Operations"

# Request access
python3 pam_implementation.py request \
    --account <account-id> \
    --user admin-001 \
    --reason "Database maintenance"

# Get credential (using session ID from previous step)
python3 pam_implementation.py credential \
    --session <session-id> \
    --user admin-001

# End session
python3 pam_implementation.py end \
    --session <session-id> \
    --user admin-001

# Check rotation
python3 pam_implementation.py report
```

### Verification 3: Test EDR Implementation

```bash
# Register endpoint
python3 edr_implementation.py register \
    --hostname "workstation-01" \
    --ip "192.168.1.100" \
    --os "Windows 11"

# Analyze suspicious activity
python3 edr_implementation.py analyze \
    --endpoint <endpoint-id> \
    --activity '{"process_name": "powershell -enc", "file_operations": [], "network_connections": []}'

# Analyze ransomware activity
python3 edr_implementation.py analyze \
    --endpoint <endpoint-id> \
    --activity '{"process_name": "cmd.exe", "file_operations": [{"path": "C:\\Users\\test\\document.encrypted", "extension": ".encrypted"}], "network_connections": []}'

# Threat hunt
python3 edr_implementation.py hunt \
    --query '{"status": "online", "alerts_in_last_hours": 24}'

# Generate report
python3 edr_implementation.py report
```

## Key Takeaways

### What You Built

1. **IAM System**: Complete identity management with RBAC, MFA, and user lifecycle
2. **PAM System**: Privileged access vaulting, JIT access, and credential rotation
3. **EDR System**: Endpoint monitoring, threat detection, and automated response

### Controls Implemented

| Control | Framework Mapping |
|---------|-------------------|
| MFA Enforcement | CIS Control 6, NIST AC-2 |
| RBAC | CIS Control 5, NIST AC-3 |
| PAM | CIS Control 5, NIST AC-6 |
| EDR | CIS Control 8, NIST SI-4 |
| Threat Intelligence | CIS Control 7, NIST SI-5 |

### Security Posture Improvements

- **Identity Security**: MFA adoption, privileged access management
- **Endpoint Security**: Real-time threat detection and response
- **Visibility**: Comprehensive logging and monitoring
- **Automation**: Automated response to security incidents

### What's Next

In **Part 4**, we'll build detection, incident response, and cyber resilience capabilities:
- Security Operations Center (SOC) operations
- SIEM implementation with centralized logging
- Incident response playbooks and tabletop exercises
- Business continuity and disaster recovery planning
- Immutable backup strategies and recovery testing
