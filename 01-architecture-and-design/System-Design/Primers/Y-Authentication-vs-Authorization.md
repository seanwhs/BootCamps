# Primer Y: Authentication vs Authorization

These two words are constantly mixed up. In system design and security discussions the distinction is fundamental. This primer makes the difference clear and shows how both appear in real architectures.

### 1. The One-Sentence Distinction

- **Authentication** answers: **“Who are you?”**
- **Authorization** answers: **“What are you allowed to do?”**

You almost always authenticate first, then authorize.

**Mental model**  
Authentication is checking someone’s ID at the building entrance.  
Authorization is checking whether that person is allowed to enter a particular room or open a particular drawer.

### 2. Authentication in Practice

Common techniques:

| Method | Typical use |
|--------|-------------|
| Username + password | Human users (usually with extra factors) |
| API keys | Simple service-to-service or external integrations |
| Tokens (JWT, opaque access tokens) | Most modern web and mobile APIs |
| OAuth 2.0 / OpenID Connect | Delegated login (“Sign in with Google”, etc.) |
| mTLS (mutual TLS) | Service-to-service identity inside a zero-trust network |
| Session cookies | Traditional web applications |

After successful authentication the system usually issues a **credential** (session cookie, JWT, access token, etc.) that the client presents on later requests so it does not have to re-prove its identity every time.

### 3. Authorization in Practice

Once you know *who* is making the request, you decide *what* they may do.

Common models:

| Model | How it works | Example |
|-------|--------------|---------|
| **RBAC** (Role-Based Access Control) | Users are assigned roles; roles carry permissions | Admin, Editor, Viewer |
| **ABAC** (Attribute-Based Access Control) | Decisions based on attributes of the user, resource, and environment | “Finance department can view reports only during business hours” |
| **ReBAC / relationship-based** | Permissions derived from relationships | “User can edit this document because they are a collaborator” |
| **ACL** (Access Control List) | Explicit list of who can do what on a given resource | Per-file sharing permissions |

In multi-tenant systems authorization almost always includes a **tenant membership** check as well: “Is this user even a member of the workspace they are trying to access?”

### 4. Where Each Concern Lives

A typical request flow:

1. Client presents a credential (cookie, Bearer token, etc.).
2. **Authentication** layer validates the credential and establishes identity (user ID, service name, etc.).
3. **Authorization** layer checks whether that identity is allowed to perform the requested action on the requested resource.
4. If both succeed, the business logic runs.

These checks may happen in:

- API Gateway / Edge
- Application middleware
- Individual service code
- Database policies (row-level security)
- A dedicated policy engine (OPA, etc.)

### 5. Common Design Mistakes

- Treating authentication as sufficient (“they logged in, so they can do anything”).
- Trusting a client-supplied tenant ID or user ID without verifying membership and permissions.
- Putting authorization decisions only in the UI (the API must enforce them too).
- Using long-lived, overly powerful tokens that cannot be revoked easily.
- Mixing authentication data and authorization data so thoroughly that you cannot rotate or change one without the other.

### 6. Tokens and Claims

In modern token-based systems (especially JWT):

- The token is usually **signed** so the receiver can verify it has not been tampered with.
- The token contains **claims** (statements about the identity and sometimes about permissions).
- Authentication verifies the signature and expiry.
- Authorization looks at the claims (roles, scopes, tenant IDs, etc.) and decides whether the action is permitted.

Important security notes:

- Do not put highly sensitive data in a JWT if it is only base64-encoded (not encrypted).
- Prefer short-lived access tokens plus refresh tokens.
- Validate audience, issuer, and expiry on every use.

### 7. Service-to-Service vs User-to-Service

- **User → Service**: Usually OAuth/OIDC, sessions, or API keys tied to a user.
- **Service → Service**: Often mTLS, workload identity, or short-lived tokens issued by an internal identity system. The “who” is a service account rather than a human.

Both still follow the same two-step logic: prove identity, then check permission.

### 8. What You Should Be Able to Do After This Primer

- Clearly distinguish authentication from authorization in one sentence each.
- Give concrete examples of each.
- Describe a typical request flow that includes both checks.
- Explain why UI-only authorization is insufficient.
- Recognize common multi-tenant authorization mistakes (especially trusting client-supplied tenant IDs).
- Sketch where authentication and authorization responsibilities might live in a high-level architecture.

This primer supports the security material in Part 6 and is foundational for any design that involves users, tenants, or service-to-service calls.

**[END OF PRIMER Y]**
