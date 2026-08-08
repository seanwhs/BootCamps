# Primer 8: Authentication & Authorization Fundamentals

## Essential Authentication and Authorization Knowledge for the Masterclass

Welcome to **Primer 8** of the Django REST Framework & Next.js 16 masterclass. This primer is designed for developers who need a quick refresh or introduction to authentication and authorization fundamentals before diving into the main series.

---

## Section 1: Authentication vs Authorization

### 1.1 Key Concepts

| Concept | Definition | Questions |
|---------|------------|-----------|
| **Authentication** | Verifying who a user is | "Are you who you say you are?" |
| **Authorization** | What a user can do | "Are you allowed to do this?" |
| **Identification** | Declaring who a user is | "Who are you?" |

**Example:**
1. **Identification**: "I am John Doe"
2. **Authentication**: "Here is my password" → Verified by system
3. **Authorization**: "Can John delete tasks?" → Check permissions

### 1.2 Authentication Factors

| Factor | Description | Examples |
|--------|-------------|----------|
| **Something you know** | Knowledge-based | Password, PIN, Security questions |
| **Something you have** | Possession-based | Phone, Token, Smart card |
| **Something you are** | Biometric | Fingerprint, Face ID, Retina scan |
| **Something you do** | Behavioral | Typing pattern, Voice recognition |

### 1.3 Authentication Methods

| Method | Description | Security | Use Case |
|--------|-------------|----------|----------|
| **Basic Auth** | Username + password in header | Low | Legacy, internal |
| **Session Auth** | Server-side session with cookie | Medium | Traditional web apps |
| **Token Auth** | Client-side token | Medium | APIs |
| **JWT** | Self-contained token | High | Modern APIs, mobile apps |
| **OAuth2** | Third-party authorization | High | Social login, SSO |
| **API Key** | Simple key-based auth | Low | Simple APIs |

---

## Section 2: Authentication Protocols

### 2.1 JWT (JSON Web Token)

**Structure:**
```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.
eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.
SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c
```

**Parts:**
1. **Header**: Algorithm and token type
```json
{"alg": "HS256", "typ": "JWT"}
```

2. **Payload**: Claims (user data)
```json
{
    "sub": "1234567890",
    "name": "John Doe",
    "iat": 1516239022,
    "exp": 1516239322,
    "user_id": 1,
    "email": "john@example.com"
}
```

3. **Signature**: Verifies token integrity
```
HMACSHA256(
    base64UrlEncode(header) + "." +
    base64UrlEncode(payload),
    secret
)
```

**Token Types:**
- **Access Token**: Short-lived (15 min), used for API requests
- **Refresh Token**: Long-lived (7 days), used to get new access tokens

### 2.2 OAuth 2.0 Flow

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Client    │     │   Auth      │     │   Resource  │
│             │     │   Server    │     │   Server    │
└──────┬──────┘     └──────┬──────┘     └──────┬──────┘
       │                   │                   │
       │ 1. Auth Request   │                   │
       │──────────────────>│                   │
       │                   │                   │
       │ 2. Auth Code      │                   │
       │<──────────────────│                   │
       │                   │                   │
       │ 3. Exchange Code  │                   │
       │──────────────────>│                   │
       │                   │                   │
       │ 4. Access Token   │                   │
       │<──────────────────│                   │
       │                   │                   │
       │ 5. Request with   │                   │
       │    Access Token   │                   │
       │───────────────────────────────────────>│
       │                   │                   │
       │ 6. Protected      │                   │
       │    Resource       │                   │
       │<───────────────────────────────────────│
       │                   │                   │
```

### 2.3 API Key Authentication

**Request:**
```http
GET /api/tasks/ HTTP/1.1
Host: api.example.com
X-API-Key: abc123xyz456
```

**Response:**
```http
HTTP/1.1 200 OK
Content-Type: application/json

{...}
```

---

## Section 3: Authorization

### 3.1 Authorization Models

| Model | Description | Example |
|-------|-------------|---------|
| **ACL** | Access Control Lists | User → resource permissions |
| **RBAC** | Role-Based Access Control | User → Role → Permissions |
| **ABAC** | Attribute-Based Access Control | User attributes → Access |
| **PBAC** | Policy-Based Access Control | Policies defined by admin |
| **MAC** | Mandatory Access Control | System-enforced rules |

### 3.2 RBAC Example

```
Roles:
├── Admin
│   ├── Create users
│   ├── Delete users
│   ├── Manage projects
│   └── All permissions
│
├── Manager
│   ├── Manage projects
│   ├── Manage tasks
│   └── View users
│
├── Member
│   ├── View projects
│   ├── Manage own tasks
│   └── Add comments
│
└── Viewer
    ├── View projects
    ├── View tasks
    └── View comments
```

### 3.3 Permission Levels

| Level | Description | Example |
|-------|-------------|---------|
| **Global** | All resources | Admin can delete any task |
| **Resource** | Specific resource | User can edit their own tasks |
| **Object** | Specific object | User can only edit tasks they created |
| **Instance** | Specific instance | User can edit task if assigned |

---

## Section 4: Common Security Attacks

### 4.1 Authentication Attacks

| Attack | Description | Prevention |
|--------|-------------|------------|
| **Brute Force** | Trying many passwords | Rate limiting, captcha |
| **Credential Stuffing** | Using leaked credentials | MFA, password policies |
| **Phishing** | Stealing credentials | User education, MFA |
| **Session Hijacking** | Stealing session token | HTTPS, HttpOnly cookies |

### 4.2 Authorization Attacks

| Attack | Description | Prevention |
|--------|-------------|------------|
| **Privilege Escalation** | Getting higher privileges | Least privilege principle |
| **IDOR** | Accessing unauthorized resources | Object-level permissions |
| **CSRF** | Forced actions | CSRF tokens, SameSite cookies |
| **XSS** | Script injection | Input sanitization, CSP |

### 4.3 Security Best Practices

**Passwords:**
- Minimum length (8-12 characters)
- Complexity requirements (uppercase, lowercase, numbers, symbols)
- Regular rotation (every 90 days)
- No common passwords
- Bcrypt or Argon2 hashing

**Tokens:**
- Short-lived access tokens (15 min)
- HTTP-only cookies for storage
- HTTPS for transmission
- Token rotation
- Implement revocation

**Rate Limiting:**
```
10 requests/minute for login
100 requests/hour for API
1000 requests/day per user
```

---

## Section 5: Implementation Patterns

### 5.1 JWT Authentication Flow

```python
# Django/DRF
from rest_framework_simplejwt.tokens import RefreshToken

def login_user(request):
    user = authenticate(email=email, password=password)
    if user:
        refresh = RefreshToken.for_user(user)
        return {
            'access': str(refresh.access_token),
            'refresh': str(refresh),
            'user': user.serialize()
        }
```

```javascript
// Next.js/React
async function login(email, password) {
    const response = await fetch('/api/v1/token/', {
        method: 'POST',
        body: JSON.stringify({ email, password })
    });
    const data = await response.json();
    
    // Store tokens
    localStorage.setItem('access_token', data.access);
    localStorage.setItem('refresh_token', data.refresh);
    setUser(data.user);
}
```

### 5.2 Token Refresh Flow

```python
# Django/DRF
def refresh_token(request):
    refresh_token = request.data.get('refresh')
    try:
        refresh = RefreshToken(refresh_token)
        return {'access': str(refresh.access_token)}
    except TokenError:
        return error('Invalid refresh token')
```

```javascript
// Next.js/React
async function refreshToken() {
    const refresh = localStorage.getItem('refresh_token');
    const response = await fetch('/api/v1/token/refresh/', {
        method: 'POST',
        body: JSON.stringify({ refresh })
    });
    const data = await response.json();
    localStorage.setItem('access_token', data.access);
    return data.access;
}
```

### 5.3 API Interceptor

```javascript
// Axios interceptor
api.interceptors.request.use((config) => {
    const token = localStorage.getItem('access_token');
    if (token) {
        config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
});

api.interceptors.response.use(
    (response) => response,
    async (error) => {
        const originalRequest = error.config;
        if (error.response?.status === 401 && !originalRequest._retry) {
            originalRequest._retry = true;
            try {
                const newToken = await refreshToken();
                originalRequest.headers.Authorization = `Bearer ${newToken}`;
                return api(originalRequest);
            } catch (refreshError) {
                // Redirect to login
                window.location.href = '/login';
                return Promise.reject(refreshError);
            }
        }
        return Promise.reject(error);
    }
);
```

### 5.4 Protected Route Component

```tsx
'use client';

import { useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { useAuth } from '@/hooks/useAuth';
import { LoadingSpinner } from '@/components/ui/LoadingSpinner';

export function ProtectedRoute({ children }: { children: React.ReactNode }) {
    const router = useRouter();
    const { isAuthenticated, isLoading } = useAuth();

    useEffect(() => {
        if (!isLoading && !isAuthenticated) {
            router.push('/login');
        }
    }, [isLoading, isAuthenticated, router]);

    if (isLoading) {
        return <LoadingSpinner />;
    }

    if (!isAuthenticated) {
        return null;
    }

    return <>{children}</>;
}
```

### 5.5 Middleware for Route Protection

```tsx
// middleware.ts
import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';

const publicPaths = ['/', '/login', '/register'];
const protectedPaths = ['/dashboard', '/projects', '/tasks'];

export function middleware(request: NextRequest) {
    const token = request.cookies.get('access_token');
    const path = request.nextUrl.pathname;
    
    const isPublic = publicPaths.some(p => path.startsWith(p));
    const isProtected = protectedPaths.some(p => path.startsWith(p));
    
    if (isProtected && !token) {
        return NextResponse.redirect(new URL('/login', request.url));
    }
    
    if (isPublic && token && path !== '/') {
        return NextResponse.redirect(new URL('/dashboard', request.url));
    }
    
    return NextResponse.next();
}
```

---

## Section 6: Security Headers

### 6.1 Common Security Headers

| Header | Value | Purpose |
|--------|-------|---------|
| `Strict-Transport-Security` | `max-age=31536000` | Enforce HTTPS |
| `X-Frame-Options` | `DENY` | Prevent clickjacking |
| `X-Content-Type-Options` | `nosniff` | Prevent MIME sniffing |
| `X-XSS-Protection` | `1; mode=block` | XSS protection |
| `Content-Security-Policy` | `default-src 'self'` | Resource restrictions |
| `Referrer-Policy` | `strict-origin-when-cross-origin` | Referrer control |
| `Permissions-Policy` | `geolocation=()` | Feature restrictions |

### 6.2 Implementing Security Headers

**Django:**
```python
# settings.py
SECURE_SSL_REDIRECT = True
SECURE_HSTS_SECONDS = 31536000
SECURE_HSTS_INCLUDE_SUBDOMAINS = True
SESSION_COOKIE_SECURE = True
CSRF_COOKIE_SECURE = True
SESSION_COOKIE_HTTPONLY = True
SECURE_CONTENT_TYPE_NOSNIFF = True
SECURE_BROWSER_XSS_FILTER = True
X_FRAME_OPTIONS = 'DENY'
```

**Nginx:**
```nginx
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
add_header X-Frame-Options "DENY" always;
add_header X-Content-Type-Options "nosniff" always;
add_header X-XSS-Protection "1; mode=block" always;
add_header Content-Security-Policy "default-src 'self'" always;
add_header Referrer-Policy "strict-origin-when-cross-origin" always;
```

**Next.js:**
```javascript
// next.config.js
async headers() {
    return [
        {
            source: '/(.*)',
            headers: [
                { key: 'X-Frame-Options', value: 'DENY' },
                { key: 'X-Content-Type-Options', value: 'nosniff' },
                { key: 'X-XSS-Protection', value: '1; mode=block' },
            ],
        },
    ];
}
```

---

## Quick Reference Cards

### Authentication Methods

| Method | When to Use | Implementation |
|--------|-------------|----------------|
| **JWT** | Modern APIs, SPAs | `djangorestframework-simplejwt` |
| **Session** | Traditional web apps | Django default |
| **OAuth2** | Third-party login | `django-oauth-toolkit` |
| **API Key** | Simple APIs | Custom middleware |

### Common Claims

| Claim | Description | Example |
|-------|-------------|---------|
| `sub` | Subject | User ID: `"123"` |
| `name` | Full name | `"John Doe"` |
| `email` | Email | `"john@example.com"` |
| `iat` | Issued at | Timestamp |
| `exp` | Expiration | Timestamp |
| `iss` | Issuer | `"myapp.com"` |
| `aud` | Audience | `"myapi.com"` |
| `role` | User role | `"admin"` |

---

*This concludes Primer 8. You now have the essential authentication and authorization knowledge needed for the masterclass.*
