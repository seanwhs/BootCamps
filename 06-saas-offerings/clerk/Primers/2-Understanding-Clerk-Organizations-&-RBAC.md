# Primer 2: Understanding Clerk's Organizations & RBAC

## The Core Concepts for Multi-Tenant Applications

Welcome to the second primer in the Clerk Mastery Series. While the main series covers implementation, this primer dives deep into Clerk's Organizations and Role-Based Access Control (RBAC) — the foundation of modern multi-tenant SaaS applications.

---

## What is Multi-Tenancy?

Multi-tenancy is an architecture where **a single instance of an application serves multiple organizations** (tenants), with each tenant's data isolated and invisible to others.

### The Office Building Analogy

Think of your application as an office building:

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

Each company (tenant) has their own:
- Employees (users)
- Workspaces (data, projects, settings)
- Access rules (who can see what)

But they share the same building infrastructure (authentication, security, hosting).

---

## Why Organizations Matter

Without organizations, every user is isolated:

```
Single-User Model:
- User A: Owns their data, can't see User B's data
- User B: Owns their data, can't see User A's data
- No concept of "company" or "team"
```

With organizations, users collaborate:

```
Multi-Tenant Model:
- User A is in "Company X" → Can see Company X's projects
- User B is in "Company X" → Can see Company X's projects
- User C is in "Company Y" → Can only see Company Y's projects
- Users can belong to multiple organizations
- Different roles per organization (admin, member, guest)
```

### Real-World Applications

| Application | How Organizations Are Used |
|-------------|---------------------------|
| **Slack** | Each workspace is an organization |
| **Notion** | Each team/workspace is an organization |
| **GitHub** | Each GitHub organization or repository team |
| **Stripe** | Each business account is an organization |
| **Figma** | Each team/project is an organization |

---

## How Clerk Implements Organizations

Clerk's Organizations feature provides:

### Core Components

```
┌─────────────────────────────────────────────────────────────────┐
│                    Clerk Organizations                         │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  Organization                                           │   │
│  │  - id: org_123abc                                      │   │
│  │  - name: "Acme Corp"                                   │   │
│  │  - slug: "acme-corp"                                   │   │
│  │  - createdBy: user_456def                              │   │
│  │  - metadata: { industry: "tech", ... }                │   │
│  └─────────────────────────────────────────────────────────┘   │
│                              │                                  │
│                              ▼                                  │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  Memberships                                            │   │
│  │  ┌─────────────────────────────────────────────────┐   │   │
│  │  │  User A → admin                                │   │   │
│  │  │  User B → moderator                            │   │   │
│  │  │  User C → member                               │   │   │
│  │  │  User D → guest                                │   │   │
│  │  └─────────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────┘   │
│                              │                                  │
│                              ▼                                  │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  Invitations                                            │   │
│  │  ┌─────────────────────────────────────────────────┐   │   │
│  │  │  user@example.com → pending (admin role)     │   │   │
│  │  │  user2@example.com → expired                 │   │   │
│  │  └─────────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

### Key Concepts Explained

| Concept | Description | Example |
|---------|-------------|---------|
| **Organization** | A container for users, data, and settings | "Acme Corp" |
| **Membership** | A user's relationship to an organization | User A is an admin |
| **Role** | A set of permissions within an organization | admin, moderator, member, guest |
| **Invitation** | A pending request to join an organization | "user@example.com has been invited" |
| **Active Organization** | Which organization the user is currently working in | User A is viewing "Acme Corp" |

### The `orgId` Session Claim

When a user has an active organization, the session token includes:

```json
{
  "sub": "user_456def",
  "sid": "sess_123abc",
  "org": "org_789ghi",          // ← Active organization ID
  "org_role": "admin",          // ← Role in active organization
  "org_permissions": [          // ← Permissions in active organization
    "org:read",
    "org:write",
    "org:projects:read"
  ]
}
```

Your server can access these via the Auth object:

```typescript
const { userId, orgId, orgRole, orgPermissions } = await auth();
```

---

## Role-Based Access Control (RBAC)

### What is RBAC?

RBAC restricts system access based on a user's role. Each role defines a set of permissions.

```
┌─────────────────────────────────────────────────────────────────┐
│                    Role Hierarchy                               │
│                                                                 │
│                     ┌───────────┐                              │
│                     │  Admin    │                              │
│                     │ (Full     │                              │
│                     │  Access)  │                              │
│                     └─────┬─────┘                              │
│                           │                                    │
│                     ┌─────┴─────┐                              │
│                     │ Moderator │                              │
│                     │ (Manage   │                              │
│                     │  Content) │                              │
│                     └─────┬─────┘                              │
│                           │                                    │
│                     ┌─────┴─────┐                              │
│                     │  Member   │                              │
│                     │ (Standard │                              │
│                     │  Access)  │                              │
│                     └─────┬─────┘                              │
│                           │                                    │
│                     ┌─────┴─────┐                              │
│                     │  Guest    │                              │
│                     │ (Read-    │                              │
│                     │  Only)    │                              │
│                     └───────────┘                              │
└─────────────────────────────────────────────────────────────────┘
```

### Roles vs. Permissions

| Aspect | Role | Permission |
|--------|------|------------|
| **What it is** | A named set of permissions | A specific action |
| **Granularity** | Coarse-grained | Fine-grained |
| **Example** | "admin" | "org:projects:delete" |
| **User-facing** | Yes ("You are an admin") | No ("You can delete projects") |
| **Assignment** | Assigned to a user | Inherited from role |

### Common Organization Roles

| Role | Typical Permissions | Example Actions |
|------|---------------------|-----------------|
| **Admin** | All permissions | Manage members, delete org, billing |
| **Moderator** | Manage content | Create/edit/delete projects |
| **Member** | Standard access | Create/edit own content |
| **Guest** | Read-only | View content |

### Permission Naming Convention

Clerk uses a `resource:action` convention:

| Permission | Meaning |
|------------|---------|
| `org:read` | Can view organization details |
| `org:write` | Can update organization settings |
| `org:delete` | Can delete the organization |
| `org:members:read` | Can view members |
| `org:members:write` | Can add/update members |
| `org:members:delete` | Can remove members |
| `org:projects:read` | Can view projects |
| `org:projects:write` | Can create/update projects |
| `org:projects:delete` | Can delete projects |

---

## The Auth Object in Depth

### Structure

```typescript
interface AuthObject {
  // Identity
  userId: string;
  sessionId: string;
  
  // Organization Context
  orgId?: string;           // Active organization ID (optional)
  orgRole?: string;         // Role in active organization (optional)
  orgPermissions?: string[]; // Permissions in active organization (optional)
  
  // Check Methods
  has(params: { role?: string; permission?: string }): boolean;
  protect(params?: { role?: string; permission?: string }): void;
  
  // Session Management
  getToken(): Promise<string | null>;
}
```

### The `has()` Method

`has()` checks if the authenticated user satisfies a condition:

```typescript
// Check for a role
const isAdmin = auth().has({ role: "admin" });

// Check for a permission
const canDelete = auth().has({ permission: "org:projects:delete" });

// Check multiple (requires ALL)
const canManage = auth().has({ 
  role: "admin",
  permission: "org:members:write"
});
```

### The `protect()` Method

`protect()` ensures the user meets a condition — if not, it throws an error:

```typescript
// In an API route
try {
  // Throws if not authenticated OR not an admin
  auth().protect({ role: "admin" });
} catch (error) {
  // Return 401 or 403
}
```

In Next.js Server Components:

```typescript
// Automatically redirects to sign-in if not authenticated
auth().protect();
```

### In Next.js Server Actions

```typescript
"use server";
import { auth } from "@clerk/nextjs/server";

export async function deleteProject(projectId: string) {
  // Throws if not authenticated OR not admin
  const { userId } = await auth().protect({ role: "admin" });
  
  // Only admins reach here
  await prisma.project.delete({ where: { id: projectId, ownerId: userId } });
}
```

---

## Data Isolation: The `orgId` Filter

The most critical aspect of multi-tenancy is **ensuring users only see data from their organization**.

### Database Filtering

Every database query must filter by `orgId`:

```typescript
// ✅ Secure - filters by organization
const projects = await prisma.project.findMany({
  where: {
    organizationId: orgId,  // Only return projects for the active org
  },
});

// ❌ Insecure - could leak data across tenants
const projects = await prisma.project.findMany(); // Returns ALL projects
```

### The Principle of Least Privilege

Every query should ask: "Does this user have permission to access this specific resource?"

```typescript
// Check ownership AND organization
const project = await prisma.project.findFirst({
  where: {
    id: projectId,
    organizationId: orgId,        // Must be in user's org
    OR: [
      { ownerId: userId },        // OR user owns it
      { public: true },           // OR it's public
    ],
  },
});

if (!project) {
  return new Response("Not found", { status: 404 });
}
```

---

## Authentication Flows with Organizations

### Sign-Up with Organization Creation

```
User signs up → Clerk creates user → User creates organization (optional)
```

In Clerk Dashboard, you can configure:
- Whether users can create organizations
- The role of the creator (default: "admin")
- Organization name and slug requirements

### Sign-In with Organization Selection

```
User signs in → If user belongs to multiple orgs → Show org selector
                If user belongs to one org → Auto-select it
                If user belongs to no org → Prompt to create one
```

### Organization Switching

```
User clicks "Switch Organization" → Show list of their orgs → Select one → Session updates with new orgId
```

Clerk's `<OrganizationSwitcher/>` handles this automatically:

```tsx
<OrganizationSwitcher
  afterSelectOrganizationUrl="/dashboard"
  appearance={{
    elements: {
      rootBox: "flex items-center",
    },
  }}
/>
```

---

## The Invitation Lifecycle

### 1. Sending an Invitation

```typescript
const invitation = await clerkClient().organizations.createOrganizationInvitation({
  organizationId: orgId,
  emailAddress: "user@example.com",
  role: "member",
  inviterUserId: currentUserId,
});
```

### 2. Invitation Status

| Status | Description |
|--------|-------------|
| `pending` | Email sent, awaiting response |
| `accepted` | User joined the organization |
| `revoked` | Invitation was cancelled |
| `expired` | Invitation expired (default: 7 days) |

### 3. Accepting an Invitation

```typescript
const membership = await clerkClient().organizations.acceptOrganizationInvitation({
  invitationId: invitation.id,
  userId: user.id,
});
```

### 4. Post-Acceptance

After acceptance, the user becomes a member of the organization with the specified role.

---

## Organization Metadata

Organizations support metadata, similar to users:

| Metadata Type | Accessibility | Use Case |
|---------------|---------------|----------|
| **Public** | Readable by all members | Company name, logo URL, industry |
| **Private** | Server-side only | Billing information, internal notes |

```typescript
// Creating an organization with metadata
const org = await clerkClient().organizations.createOrganization({
  name: "Acme Corp",
  slug: "acme-corp",
  createdBy: userId,
  publicMetadata: {
    industry: "technology",
    website: "https://acme.com",
    companySize: "50-100",
  },
  privateMetadata: {
    stripeCustomerId: "cus_123abc",
    billingPlan: "enterprise",
  },
});
```

---

## Security Best Practices

### 1. Always Check `orgId`

Every database query should filter by organization ID.

### 2. Validate Role on Sensitive Operations

```typescript
const { orgRole } = await auth();
if (orgRole !== "admin") {
  throw new Error("Admin access required");
}
```

### 3. Use `protect()` for Critical Actions

```typescript
// In Server Actions
await auth().protect({ role: "admin" });

// In API routes
auth().protect({ permission: "org:members:write" });
```

### 4. Implement Defense in Depth

Layer 1: Middleware protects routes
Layer 2: Component-level protection
Layer 3: Database-level filtering

### 5. Prevent Cross-Tenant Data Leakage

```typescript
// ❌ Never trust client-provided orgId
const orgId = request.body.orgId;

// ✅ Always use the orgId from the session
const { orgId } = await auth();
```

---

## The `clerkMiddleware()` for Organizations

```typescript
import { clerkMiddleware, createRouteMatcher } from "@clerk/nextjs/server";

const isOrganizationRoute = createRouteMatcher(["/org/(.*)"]);

export default clerkMiddleware((auth, req) => {
  const { userId, orgId } = auth();
  
  // Protect organization routes
  if (isOrganizationRoute(req)) {
    if (!userId) {
      return NextResponse.redirect(new URL("/sign-in", req.url));
    }
    
    if (!orgId) {
      return NextResponse.redirect(new URL("/org/select", req.url));
    }
  }
});

export const config = {
  matcher: ["/((?!_next).*)"],
};
```

---

## Key Takeaways

1. **Organizations enable multi-tenancy** — Users belong to companies/teams
2. **The `orgId` is critical** — It determines which data a user can access
3. **Roles define access** — admin, moderator, member, guest
4. **Permissions are granular** — Specific actions within an organization
5. **Data isolation is your responsibility** — Every query must filter by `orgId`
6. **The Auth object is your source of truth** — Always use `auth()` for authorization

---

## Quick Reference

| Concept | Clerk Implementation |
|---------|---------------------|
| Tenant | `Organization` |
| User's tenant membership | `OrganizationMembership` |
| User's role in tenant | `orgRole` in Auth object |
| Permissions in tenant | `orgPermissions` in Auth object |
| Invite to tenant | `OrganizationInvitation` |
| Active tenant | `orgId` in Auth object |
| Tenant switcher | `<OrganizationSwitcher/>` |

---

## Ready to Implement?

This primer covers the conceptual foundation for multi-tenant applications. Now proceed to:

- **Part 3: Multi-Tenant SaaS Architecture** for hands-on implementation
- **Part 2: Server-Side Security** for protecting routes with roles
- **Part 5: React 19 & Next.js 16** for modern full-stack patterns

The technical implementation awaits — let's build secure multi-tenant applications.
