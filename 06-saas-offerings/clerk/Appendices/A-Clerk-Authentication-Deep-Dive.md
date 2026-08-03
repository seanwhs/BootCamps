# Appendix A: Clerk Authentication Deep Dive

## Understanding the Underlying Architecture

This appendix provides comprehensive technical reference material for the concepts introduced throughout the series. While the main tutorials focused on practical implementation, this appendix dives deep into the "why" and "how" behind Clerk's architecture. Consider this your technical reference manual for understanding modern authentication at a fundamental level.

---

## A.1 The Evolution of Authentication: From Sessions to JWTs

### The Traditional Session-Store Model

In traditional web applications, authentication worked through server-side session storage:

1. **User submits credentials** to the server
2. **Server validates** credentials and creates a session record in a database or cache
3. **Server generates** a session ID and stores it in a browser cookie
4. **On subsequent requests**, the browser sends the session cookie
5. **Server looks up** the session record, validates it, and processes the request

```
┌─────────────┐     ┌─────────────┐     ┌─────────────────┐
│   Browser   │────▶│    Server   │────▶│  Session Store  │
│             │     │             │     │  (Database/     │
│  Cookie     │     │  Validates  │     │   Redis)        │
│  with       │     │  Session ID │     │                 │
│  Session ID │◀────│             │◀────│  Session Record │
└─────────────┘     └─────────────┘     └─────────────────┘
```

**Problems with this approach:**

| Problem | Impact |
|---------|--------|
| **Scaling nightmare** | Every request needs a database lookup or Redis call |
| **Stateful by design** | Server must maintain session state, making horizontal scaling complex |
| **Single point of failure** | If session store goes down, all users are logged out |
| **Security risks** | Session cookies can be hijacked; server must validate every request |
| **Performance overhead** | Database lookups add latency to every request |

### The Modern Token-Based Model

Modern applications use **stateless token-based authentication** (typically with JWTs):

1. **User submits credentials** to the authentication service
2. **Service validates** credentials and issues a signed JWT
3. **JWT contains** user identity, expiration time, and cryptographic signature
4. **Browser stores** token in HTTP-only cookies (for security)
5. **On subsequent requests**, browser sends the token
6. **Server validates** token's signature and expiration without database lookups

```
┌─────────────┐     ┌─────────────────────┐     ┌─────────────────┐
│   Browser   │────▶│  Authentication     │     │   Your API      │
│             │     │  Service (Clerk)    │     │                 │
│  HTTP-Only  │     │                     │     │  Validates JWT  │
│  Cookie     │     │  Issues Signed JWT  │     │  Signature      │
│  with JWT   │◀────│                     │     │  & Expiration   │
└─────────────┘     └─────────────────────┘     └─────────────────┘
        │                                                           │
        │                                                           │
        └───────────────────API Request with JWT────────────────────┘
```

**Why this is superior:**

- **Stateless:** No server-side session storage; scale horizontally without effort
- **Self-contained:** User identity and permissions are encoded in the token
- **Performance:** No database lookups for authentication on every request
- **Security:** Cryptographic signatures prevent tampering
- **Decoupled:** Authentication is separate from your application logic

---

## A.2 How Clerk's Session Management Works

Clerk implements a sophisticated session architecture that balances performance with security .

### Clients and Sessions

In Clerk's architecture:

- **Client:** The device/browser where ClerkJS is running. A Client is created when ClerkJS loads in a browser .
- **Session:** The period of time a user is signed in. Sessions are attached to Clients .

```
┌─────────────────────────────────────────────────────────────┐
│                    Clerk Architecture                       │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Client (Browser)                                  │   │
│  │  ┌─────────────────────────────────────────────┐  │   │
│  │  │  Session 1 (User A)                       │  │   │
│  │  │  - Session ID: sess_123abc                │  │   │
│  │  │  - Created: 2024-01-01 10:00:00          │  │   │
│  │  │  - Expires: 2024-01-01 11:00:00          │  │   │
│  │  └─────────────────────────────────────────────┘  │   │
│  │  ┌─────────────────────────────────────────────┐  │   │
│  │  │  Session 2 (User B)                       │  │   │
│  │  │  - Session ID: sess_456def                │  │   │
│  │  │  - Created: 2024-01-01 10:30:00          │  │   │
│  │  │  - Expires: 2024-01-01 11:30:00          │  │   │
│  │  └─────────────────────────────────────────────┘  │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Clerk Server                                      │   │
│  │  - Validates session tokens                       │   │
│  │  - Generates new tokens                           │   │
│  │  - Manages session expiration                     │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

### The Session Token Lifecycle

Clerk's session management is built on a hybrid approach that combines the security of server-side sessions with the performance of JWTs :

1. **User signs in** → Clerk creates a Session object and generates a JWT
2. **JWT is stored** in an HTTP-only, Secure cookie (`__session`)
3. **JWT expires** after 60 seconds (short-lived for security)
4. **Before expiration**, Clerk automatically refreshes the token using the session
5. **If session is revoked**, token refresh fails → user must sign in again

```
┌─────────────────────────────────────────────────────────────────────┐
│                    Session Token Lifecycle                         │
│                                                                     │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐            │
│  │   Sign In   │───▶│  Issue JWT  │───▶│  60 sec     │            │
│  │             │    │  (expires   │    │  lifetime   │            │
│  │             │    │   in 60s)   │    │             │            │
│  └─────────────┘    └─────────────┘    └──────┬──────┘            │
│                                               │                    │
│                                               ▼                    │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐            │
│  │   Auto      │◀───│   Token     │    │   Token     │            │
│  │   Refresh   │    │   Expires   │───▶│   Valid     │            │
│  │   (if       │    │             │    │   (60s)     │            │
│  │   active)   │    └─────────────┘    └─────────────┘            │
│  └──────┬──────┘                                                    │
│         │                                                          │
│         ▼                                                          │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐            │
│  │   Session   │───▶│   User      │    │   Token     │            │
│  │   Revoked?  │    │   Must      │◀───│   Invalid   │            │
│  │             │    │   Re-auth   │    │             │            │
│  └─────────────┘    └─────────────┘    └─────────────┘            │
└─────────────────────────────────────────────────────────────────────┘
```

### Key Session Security Features 

| Feature | Description |
|---------|-------------|
| **Short-lived tokens** | JWTs expire in 60 seconds; prevents long-term compromise |
| **Automatic refresh** | Tokens are refreshed without user interaction while session is active |
| **Remote sign-out** | Session can be revoked server-side; user is signed out within 60 seconds |
| **Inactivity timeout** | Configurable timeout after which session expires |
| **Multi-session support** | Users can be signed in on multiple devices |
| **Device tracking** | Each Client is tracked; users can see and manage their sessions |
| **HTTP-only cookies** | Session tokens are stored in HTTP-only cookies to prevent XSS attacks |
| **Secure cookies** | Cookies are only sent over HTTPS |

---

## A.3 Understanding JWTs and Clerk's Implementation

### JWT Structure

A JSON Web Token (JWT) consists of three parts, each base64-encoded and separated by dots:

```
Header.Payload.Signature
```

**Header:** Contains the algorithm and token type
```json
{
  "alg": "RS256",
  "typ": "JWT"
}
```

**Payload:** Contains the claims (user data)
```json
{
  "sub": "user_456def",        // Subject (User ID)
  "sid": "sess_123abc",        // Session ID
  "org": "org_789ghi",         // Organization ID
  "iat": 1700000000,           // Issued At
  "exp": 1700003600,           // Expiration (1 hour later)
  "iss": "https://api.clerk.com",
  "azp": "https://api.clerk.com",
  "roles": ["admin"],          // User roles
  "permissions": ["read", "write"] // Permissions
}
```

**Signature:** Cryptographic signature verifying token authenticity
```
HMACSHA256(
  base64UrlEncode(header) + "." + base64UrlEncode(payload),
  secret
)
```

### Clerk's JWT Implementation 

Clerk uses **RS256** (RSA with SHA-256) for signing JWTs:

- **Private key:** Used by Clerk to sign tokens
- **Public key:** Exposed at `/.well-known/jwks.json` for token verification

**Why RS256 over HS256:**

| Aspect | RS256 | HS256 |
|--------|-------|-------|
| **Key type** | Asymmetric (public/private) | Symmetric (shared secret) |
| **Security** | Private key never shared | Secret must be shared with all services |
| **Key rotation** | Easy (public key can be distributed) | Complex (all services must update) |
| **Verification** | Any service with public key can verify | Only services with secret can verify |
| **Best for** | Microservices, third-party verification | Single service, internal use |

### Token Verification Process

When your server receives a token, Clerk's SDK verifies it:

1. **Extract token** from Authorization header or cookie
2. **Verify signature** using public key from JWKS endpoint
3. **Validate claims**:
   - `exp` (Expiration) - token is not expired
   - `iat` (Issued At) - token was issued in the past
   - `iss` (Issuer) - token was issued by Clerk
   - `azp` (Authorized Party) - token is for your application
4. **Extract user data** from claims

```typescript
// Example of manual token verification (simplified)
import jwt from 'jsonwebtoken';
import jwksClient from 'jwks-rsa';

const client = jwksClient({
  jwksUri: 'https://your-clerk-instance.clerk.accounts.dev/.well-known/jwks.json'
});

function verifyToken(token: string): Promise<JWTPayload> {
  return new Promise((resolve, reject) => {
    const decoded = jwt.decode(token, { complete: true });
    if (!decoded) {
      reject(new Error('Invalid token'));
      return;
    }
    
    const kid = decoded.header.kid;
    client.getSigningKey(kid, (err, key) => {
      if (err) {
        reject(err);
        return;
      }
      
      const signingKey = key.getPublicKey();
      jwt.verify(token, signingKey, {
        algorithms: ['RS256'],
        issuer: 'https://api.clerk.com',
      }, (err, decoded) => {
        if (err) {
          reject(err);
          return;
        }
        resolve(decoded as JWTPayload);
      });
    });
  });
}
```

### Session Token Claims in Clerk

Clerk's Session Token includes these claims :

| Claim | Description | Use Case |
|-------|-------------|----------|
| `sub` | User ID (subject) | Identify the user |
| `sid` | Session ID | Track and manage sessions |
| `org` | Active Organization ID | Multi-tenant context |
| `iat` | Issued At timestamp | Token age tracking |
| `exp` | Expiration timestamp | Token lifetime |
| `iss` | Issuer (Clerk API) | Token origin |
| `azp` | Authorized Party (your app) | Prevent token misuse |
| `roles` | User roles | Role-based access control |
| `permissions` | User permissions | Fine-grained authorization |
| `custom_claims` | Your custom data | Application-specific authorization |

---

## A.4 Multi-Tenant Architecture Deep Dive

### What Is Multi-Tenant Authentication?

Multi-tenant authentication is a system design pattern that securely supports multiple independent tenants within a single application instance . Each tenant (typically an organization or company) has its own users, data, and configuration, while sharing common infrastructure .

Think of it like an office building:

```
┌─────────────────────────────────────────────────────────────┐
│                    Office Building                          │
│                    (Application Instance)                   │
│                                                             │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────┐ │
│  │   Company A     │  │   Company B     │  │  Company C  │ │
│  │   (Tenant 1)    │  │   (Tenant 2)    │  │  (Tenant 3) │ │
│  │                 │  │                 │  │             │ │
│  │  ┌───────────┐ │  │  ┌───────────┐ │  │  ┌───────┐  │ │
│  │  │ Employee  │ │  │  │ Employee  │ │  │  │ User  │  │ │
│  │  │ Data      │ │  │  │ Data      │ │  │  │ Data  │  │ │
│  │  └───────────┘ │  │  └───────────┘ │  │  └───────┘  │ │
│  │  ┌───────────┐ │  │  ┌───────────┐ │  │             │ │
│  │  │ Projects  │ │  │  │ Projects  │ │  │             │ │
│  │  └───────────┘ │  │  └───────────┘ │  │             │ │
│  └─────────────────┘  └─────────────────┘  └─────────────┘ │
│                                                             │
│  Shared Services: Authentication, Security, Infrastructure  │
└─────────────────────────────────────────────────────────────┘
```

### Key Multi-Tenant Concepts 

| Concept | Description |
|---------|-------------|
| **Organization (Tenant)** | A container for users, data, and configuration |
| **Organization Member** | A user who belongs to an organization |
| **Organization Role** | Defines what a member can do within the organization |
| **Organization Permission** | Specific actions a member can perform |
| **Active Organization** | The organization currently selected by the user |
| **Organization Invitation** | A pending request for a user to join an organization |
| **Organization Domain** | Verified domain associated with an organization |

### Challenges in Multi-Tenant Authentication 

| Challenge | Description | Solution Approach |
|-----------|-------------|-------------------|
| **Organizational Context** | Tracking which organization a user is working in | Store organization ID in session, enforce on every request |
| **Invite-Based Access** | Managing invitations and onboarding flows | Use Clerk's built-in invitation system |
| **Per-Organization RBAC** | Roles that differ across organizations | Scope roles to organization level |
| **Tenant-Specific Branding** | Custom domains and white-label experiences | Use Clerk's verified domains feature |
| **Cross-Organization Management** | Users belonging to multiple organizations | Support multi-organization memberships |
| **Data Isolation** | Preventing cross-tenant data leakage | Filter all queries by organization ID |

### Single-User vs Multi-Tenant Authentication 

| Aspect | Single-User | Multi-Tenant |
|--------|-------------|--------------|
| **User Model** | User isolated | User belongs to organizations |
| **Data Access** | User's own data | Data scoped to organization |
| **Permissions** | Global roles | Per-organization roles |
| **Authentication** | User identity only | User + Organization context |
| **Example** | Personal to-do app | Slack workspace |

### How Clerk Simplifies Multi-Tenant Authentication 

Clerk provides built-in support for multi-tenant authentication:

1. **Organizations as first-class citizens** - Create, list, join, and leave organizations without custom code
2. **Organization-scoped sessions** - Automatic tracking of active organization
3. **Per-organization RBAC** - Roles scoped per organization
4. **Invitation system** - Manage invites and onboarding flows
5. **Verified domains** - Link custom domains to organizations
6. **Organization switcher** - Built-in UI component for switching orgs
7. **Organization metadata** - Store organization-specific data

---

## A.5 Security Best Practices

### Authentication Security Checklist

| Practice | Description | Implementation |
|----------|-------------|----------------|
| **Use HTTP-only cookies** | Prevent XSS token theft | Clerk stores tokens in HTTP-only cookies by default |
| **Enable HTTPS** | Encrypt all traffic | Use TLS/SSL for all connections |
| **Implement CSRF protection** | Prevent cross-site request forgery | Clerk includes CSRF protection  |
| **Short-lived tokens** | Minimize compromise window | Clerk tokens expire in 60 seconds  |
| **Automatic token refresh** | Maintain session without re-auth | Clerk handles token refresh automatically  |
| **Session revocation** | Ability to sign out remotely | Users can revoke sessions in UserProfile  |
| **Multi-factor authentication** | Add extra security layer | Clerk supports SMS OTP, TOTP, and WebAuthn  |
| **Inactivity timeout** | Auto-signout after idle period | Configurable in Clerk Dashboard  |
| **Rate limiting** | Prevent brute force attacks | Clerk includes built-in rate limiting |
| **Audit logging** | Track authentication events | Clerk provides audit logs  |

### Common Security Vulnerabilities and Mitigations

| Vulnerability | Description | Clerk Mitigation |
|---------------|-------------|------------------|
| **XSS (Cross-Site Scripting)** | Script injection in user input | HTTP-only cookies, output encoding |
| **CSRF (Cross-Site Request Forgery)** | Unauthorized state-changing requests | CSRF tokens, same-site cookies |
| **Session Fixation** | Attacker sets a known session ID | Session regeneration on login |
| **Man-in-the-Middle** | Intercepting communication | HTTPS, HSTS headers |
| **Credential Stuffing** | Using leaked passwords from other breaches | Breached password detection |
| **Password Spraying** | Trying common passwords on many accounts | Rate limiting, password policies |
| **Token Hijacking** | Stealing session tokens | Short-lived tokens, HTTP-only cookies |
| **Account Takeover** | Gaining control of a user account | MFA, email verification |
| **Privilege Escalation** | Gaining higher permissions than authorized | Strict role checking, permission verification |
| **Data Leakage** | Exposing data across tenants | Organization-scoped queries |

### NIST Password Guidelines Implementation 

Clerk follows NIST (National Institute of Standards and Technology) password guidelines:

| Requirement | NIST SP 800-63B | Clerk Implementation |
|-------------|-----------------|---------------------|
| **Password length** | Minimum 8 characters | Configurable |
| **Common passwords** | Reject commonly-used, breached passwords | Built-in breached password detection  |
| **No password expiration** | Don't require arbitrary changes | No forced rotation |
| **No complexity rules** | Don't enforce arbitrary composition rules | Configurable, but not mandatory |
| **Rate limiting** | Prevent brute force attempts | Built-in rate limiting |

---

## A.6 Clerk Infrastructure Architecture

Understanding the infrastructure behind Clerk helps explain why it's secure, scalable, and reliable.

### Clerk-Hosted Architecture 

When you use Clerk, you're leveraging a fully managed authentication infrastructure:

```
┌─────────────────────────────────────────────────────────────────────┐
│                    Clerk Platform Architecture                      │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │  Client Layer                                                │   │
│  │  ┌──────────────────────────────────────────────────────┐  │   │
│  │  │  ClerkJS + Pre-built Components                    │  │   │
│  │  │  (SignIn, SignUp, UserButton, OrganizationSwitcher)│  │   │
│  │  └──────────────────────────────────────────────────────┘  │   │
│  │  ┌──────────────────────────────────────────────────────┐  │   │
│  │  │  React Native SDK + Mobile Components             │  │   │
│  │  └──────────────────────────────────────────────────────┘  │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                              │                                      │
│                              ▼                                      │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │  API Layer (Google Cloud Run)                              │   │
│  │  ┌─────────────────────┐  ┌─────────────────────────────┐ │   │
│  │  │  Frontend API       │  │  Backend API               │ │   │
│  │  │  - Sign-in flows    │  │  - Token verification      │ │   │
│  │  │  - OAuth handlers   │  │  - User data access        │ │   │
│  │  │  - Session sync     │  │  - Webhook delivery        │ │   │
│  │  └─────────────────────┘  └─────────────────────────────┘ │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                              │                                      │
│                              ▼                                      │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │  Data Layer (Google Cloud SQL)                              │   │
│  │  ┌─────────────────────────────────────────────────────┐   │   │
│  │  │  User Data          │  Organization Data           │   │   │
│  │  │  - Profiles         │  - Memberships              │   │   │
│  │  │  - Credentials      │  - Roles                    │   │   │
│  │  │  - Sessions         │  - Invitations              │   │   │
│  │  └─────────────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                              │                                      │
│                              ▼                                      │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │  External Services                                         │   │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────────┐ │   │
│  │  │  SendGrid    │  │  Twilio      │  │  Svix (Webhooks) │ │   │
│  │  │  (Emails)    │  │  (SMS)       │  │                  │ │   │
│  │  └──────────────┘  └──────────────┘  └──────────────────┘ │   │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────────┐ │   │
│  │  │  Cloudflare  │  │  OAuth       │  │  SAML IDPs      │ │   │
│  │  │  (Bot        │  │  Providers   │  │                  │ │   │
│  │  │  Detection)  │  │              │  │                  │ │   │
│  │  └──────────────┘  └──────────────┘  └──────────────────┘ │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

### Key Infrastructure Components 

| Component | Technology | Purpose |
|-----------|------------|---------|
| **Compute** | Google Cloud Run | Highly scalable, serverless API runtime |
| **Data Storage** | Google Cloud SQL | Secure, managed database |
| **Emails** | Sendgrid | Email delivery for magic links, OTPs, invitations |
| **SMS** | Twilio | SMS delivery for OTPs, two-factor auth |
| **Webhooks** | Svix | Reliable webhook delivery to your applications |
| **Bot Detection** | Cloudflare + in-house | Prevent spam and abuse |
| **Caching** | CDN + In-memory | Performance optimization |
| **Monitoring** | Custom + Google Cloud | Observability and alerts |

### Development vs Production Instances 

| Aspect | Development Instance | Production Instance |
|--------|---------------------|---------------------|
| **Domain** | `*.clerk.accounts.dev` | `clerk.yourdomain.com` |
| **DNS Setup** | None (auto-provided) | Required (set TXT records) |
| **OAuth Credentials** | Shared (Clerk-provided) | Your own (app-specific) |
| **Emails** | `no-reply@accounts.dev` | Your domain |
| **Cross-origin auth** | Yes (works on any domain) | No (same-origin only) |
| **Security** | Development level | Production level |
| **Rate Limits** | Higher limits | Configurable |

---

## A.7 Webhooks and Event-Driven Architecture

### Webhook Signature Verification

Clerk signs webhook payloads to ensure they come from Clerk and haven't been tampered with.

**How it works:**

1. **Clerk generates** a payload signature using the webhook secret
2. **Signature is sent** in the `svix-signature` header
3. **Your server verifies** the signature using the same secret

```typescript
// Webhook signature verification using Svix
import { Webhook } from 'svix';

function verifyWebhook(payload: string, headers: Headers) {
  const webhook = new Webhook(process.env.CLERK_WEBHOOK_SECRET);
  const verifiedPayload = webhook.verify(payload, {
    'svix-signature': headers.get('svix-signature'),
    'svix-timestamp': headers.get('svix-timestamp'),
    'svix-id': headers.get('svix-id'),
  });
  return verifiedPayload;
}
```

### Event Types and Processing

Clerk sends webhooks for these event types:

| Event Type | Description | When It Occurs |
|------------|-------------|----------------|
| `user.created` | New user registered | After successful sign-up |
| `user.updated` | User data changed | Profile updates, metadata changes |
| `user.deleted` | User account removed | Account deletion |
| `user.organization.created` | User created an org | Organization creation |
| `user.organization.updated` | User's org membership changed | Role changes, updates |
| `user.organization.deleted` | User removed from org | Membership removal |
| `session.created` | User signed in | Successful authentication |
| `session.ended` | User signed out | Sign-out, session expiry |
| `session.removed` | Session revoked | Remote sign-out |

### Webhook Processing Best Practices

| Best Practice | Why | Implementation |
|---------------|-----|----------------|
| **Verify signatures** | Prevent fake webhook calls | Use Svix verification |
| **Idempotent processing** | Handle duplicate events | Track processed event IDs |
| **Async processing** | Don't block the webhook | Queue events, process in background |
| **Retry handling** | Handle temporary failures | Clerk retries failed webhooks |
| **Logging** | Debug and audit | Log all webhook events |
| **Error handling** | Graceful failure | Return 500 for retry, 200 for success |

---

## A.8 Clerk APIs Reference

### Frontend API

The Clerk Frontend API is used directly by client applications .

**Base URL:** `https://{domain}.clerk.accounts.dev/v1`

**Key Endpoints:**

| Endpoint | Purpose | Authentication |
|----------|---------|----------------|
| `GET /environment` | Get instance configuration | None (public) |
| `PATCH /environment` | Update instance config | Session (admin) |
| `GET /me` | Get current user data | Session |
| `PATCH /me` | Update current user | Session |

**Example:** Getting environment configuration
```bash
curl https://example.clerk.accounts.dev/v1/environment
```

### Backend API

The Clerk Backend API is used for server-side operations .

**Base URL:** `https://api.clerk.com/v1`

**Authentication:** Bearer token (Secret Key)

**Key Endpoints :**

| Endpoint | Purpose | Method |
|----------|---------|--------|
| `/users` | List users | GET |
| `/users/{id}` | Get specific user | GET |
| `/users/{id}` | Update user | PATCH |
| `/users/{id}` | Delete user | DELETE |
| `/organizations` | List organizations | GET |
| `/organizations` | Create organization | POST |
| `/organizations/{id}` | Get organization | GET |
| `/organizations/{id}/memberships` | List members | GET |
| `/redirect_urls` | List redirect URLs | GET  |
| `/redirect_urls` | Create redirect URL | POST  |
| `/redirect_urls/{id}` | Delete redirect URL | DELETE  |

**Example: List all users**
```bash
curl https://api.clerk.com/v1/users \
  -H "Authorization: Bearer sk_test_xxxxxx"
```

### Platform API

The Clerk Platform API is used for programmatic workspace management .

**Base URL:** `https://api.clerk.com/v1/platform`

**Authentication:** Platform API access token

**Key Endpoints :**

| Endpoint | Purpose | Method |
|----------|---------|--------|
| `/applications` | List applications | GET |
| `/applications` | Create application | POST |

**Example: Create a new application **
```bash
curl https://api.clerk.com/v1/platform/applications \
  -X POST \
  -H "Authorization: Bearer YOUR_SECRET_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "My New App",
    "environment_types": ["development", "production"]
  }'
```

---

## A.9 JWT Single Sign-On (SSO)

### How JWT SSO Works

Clerk's JWT Single Sign-On enables integration with BaaS providers like Firebase, Supabase, and Convex .

```
┌─────────────────────────────────────────────────────────────────────┐
│                    JWT SSO Flow                                    │
│                                                                     │
│  1. User signs in with Clerk                                       │
│  ┌─────────────┐                                                  │
│  │   Browser   │                                                  │
│  │  (Signed    │                                                  │
│  │   in with   │                                                  │
│  │   Clerk)    │                                                  │
│  └──────┬──────┘                                                  │
│         │                                                         │
│  2. Request JWT from Clerk                                        │
│         ▼                                                         │
│  ┌─────────────┐    ┌──────────────────────────────────────────┐ │
│  │   Clerk     │───▶│  JWT Template (configured in dashboard) │ │
│  │   Backend   │    │  - Custom claims                        │ │
│  │   API       │    │  - Expiry time                         │ │
│  └─────────────┘    │  - Custom signing key                  │ │
│                      └──────────────────────────────────────────┘ │
│         │                                                         │
│  3. Use JWT with BaaS provider                                    │
│         ▼                                                         │
│  ┌─────────────┐    ┌─────────────┐    ┌──────────────────────┐ │
│  │   Browser   │───▶│   BaaS      │───▶│  Data access with   │ │
│  │             │    │   Provider  │    │  JWT security rules │ │
│  └─────────────┘    └─────────────┘    └──────────────────────┘ │
└─────────────────────────────────────────────────────────────────────┘
```

### JWT Template Configuration

JWT Templates in the Clerk Dashboard allow you to configure :

| Configuration | Description |
|---------------|-------------|
| **Token lifetime** | How long the token is valid (short-lived or long-lived) |
| **Custom signing key** | Use provider's secret key to sign tokens |
| **Issuer defined key** | Expose JWKS endpoint for providers to verify |
| **Custom claims** | Add application-specific claims using handlebars templates |

### Example: Custom Claims with Handlebars

```json
{
  "user_id": "{{user.id}}",
  "email": "{{user.primaryEmail}}",
  "name": "{{user.fullName}}",
  "role": "{{user.publicMetadata.role}}",
  "org_id": "{{activeOrg.id}}",
  "org_role": "{{activeOrg.role}}",
  "verified": "{{user.emailVerified}}"
}
```

### Supported BaaS Integrations 

| Provider | Integration Method | Configuration |
|----------|-------------------|---------------|
| Firebase | Custom signing key | Use Firebase project secret |
| Supabase | Custom signing key | Use Supabase JWT secret |
| Convex | Issuer/JWKS | Configure Clerk as issuer |
| Hasura | JWT claims | Claims-based authorization |

---

## A.10 Multi-Factor Authentication (MFA)

### What MFA Provides

Multi-factor authentication adds an extra security layer by requiring two different types of evidence :

| Factor Type | Description | Examples |
|-------------|-------------|----------|
| **Something you know** (Knowledge) | Information only the user knows | Password, security questions |
| **Something you have** (Possession) | Physical device | SMS OTP, TOTP app, security key |

### Clerk's MFA Implementation 

Clerk provides MFA out of the box through the `<UserProfile/>` component:

| Feature | Description |
|---------|-------------|
| **SMS OTP** | One-time password sent via SMS |
| **TOTP** | Time-based one-time password (Google Authenticator) |
| **WebAuthn** | Physical security keys (Yubikey) |
| **Backup Codes** | Emergency codes for lost access |
| **Self-service** | Users configure MFA in UserProfile |

### MFA Flow

1. **User signs in** with email/password
2. **System detects** MFA is configured
3. **User prompted** for second factor
4. **User provides** TOTP code, SMS code, or uses security key
5. **System validates** and completes sign-in

### Security Considerations 

| Consideration | Description |
|---------------|-------------|
| **SIM swap mitigation** | SMS OTP can be disabled at app or user level |
| **Factor independence** | Each factor must be from different category |
| **Password reset** | Doesn't bypass MFA |
| **Account recovery** | Admin-assisted recovery for lost factors |

---

## A.11 Clerk CLI Reference

The Clerk CLI provides programmatic control over your Clerk applications .

### Installation

```bash
curl -fsSL https://clerk.com/install | sh
# or
npm install -g clerk
```

### Key Commands 

| Command | Purpose |
|---------|---------|
| `clerk auth login` | OAuth login to Clerk |
| `clerk whoami` | Show current user + linked app |
| `clerk apps list` | List apps in your workspace |
| `clerk apps create <name>` | Create a new app |
| `clerk init` | Initialize Clerk in a project |
| `clerk link --app <id>` | Link CLI to an existing app |
| `clerk env pull` | Write env vars to .env.local |
| `clerk doctor` | Validate auth + env vars |
| `clerk api /users` | Query the Clerk Backend API |
| `clerk config pull` | Snapshot current config |
| `clerk config patch` | Update config partially |

### Environment Variables 

| Variable | Purpose |
|----------|---------|
| `CLERK_CONFIG_DIR` | Override CLI config directory |
| `NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY` | Client-side key |
| `CLERK_SECRET_KEY` | Server-side key |
| `NEXT_PUBLIC_CLERK_SIGN_IN_URL` | Sign-in page URL |
| `NEXT_PUBLIC_CLERK_SIGN_UP_URL` | Sign-up page URL |
| `NEXT_PUBLIC_CLERK_AFTER_SIGN_IN_URL` | Post-sign-in redirect |
| `NEXT_PUBLIC_CLERK_AFTER_SIGN_UP_URL` | Post-sign-up redirect |
