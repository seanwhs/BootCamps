# Part 3: Multi-Tenant SaaS Architecture

## Organizations, Roles, and Enterprise Authorization

**Welcome to Part 3!** Now that you've mastered server-side security and role-based access control, it's time to build multi-tenant SaaS applications. In this module, you'll learn how to architect scalable B2B applications with team-based access control, tenant isolation, and enterprise permissions using Clerk Organizations.

---

## What You'll Learn in Part 3

By the end of this part, you'll be able to:

- Understand the core architectural patterns of multi-tenancy
- Configure and utilize Clerk Organizations for team management
- Programmatically invite users into organizations
- Build custom organization switcher UI components
- Implement Role-Based Access Control (RBAC) using Clerk Roles and custom Permissions
- Combine organization-level roles with application-specific business logic
- Filter database queries by active organization ID to prevent cross-tenant data leaks
- Design scalable permission hierarchies for complex enterprise workflows
- Build a multi-company SaaS dashboard with isolated user data

---

## Understanding Multi-Tenancy Architecture

### What Is Multi-Tenancy?

Multi-tenancy is a software architecture where a single instance of an application serves multiple organizations (tenants), with each tenant's data isolated and invisible to other tenants.

Think of it like a large office building:

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

### Multi-Tenancy Models

There are three primary approaches to multi-tenancy:

| Model | Description | Use Case |
|-------|-------------|----------|
| **Database Per Tenant** | Each tenant has their own database | High isolation, compliance requirements |
| **Schema Per Tenant** | Single database, separate schemas | Medium isolation, easier management |
| **Shared Database** | Single database, tenant_id column | Most common, cost-effective |

### Why Use Clerk Organizations?

Clerk Organizations provide a built-in multi-tenancy solution that handles:

- **Tenant creation and management** - Create organizations programmatically
- **Member management** - Add/remove users, manage roles
- **Invitation system** - Send email invitations to join organizations
- **Organization switching** - Users can belong to multiple orgs
- **Role-based access** - Define roles at the organization level
- **Metadata storage** - Store organization-specific data

---

## Setting Up the Project for Part 3

We'll build on the code from Parts 1 and 2. If you haven't completed them, you can start with the provided starter code.

### Project Structure for Part 3

```
part-3-multi-tenant-saas/
├── app/
│   ├── (auth)/
│   │   ├── dashboard/
│   │   │   └── page.tsx          # Dashboard with org context
│   │   ├── organization/
│   │   │   ├── [orgId]/
│   │   │   │   ├── page.tsx      # Organization dashboard
│   │   │   │   ├── settings/
│   │   │   │   │   └── page.tsx  # Org settings
│   │   │   │   ├── members/
│   │   │   │   │   └── page.tsx  # Member management
│   │   │   │   └── projects/
│   │   │   │       └── page.tsx  # Org projects
│   │   │   ├── create/
│   │   │   │   └── page.tsx      # Create organization
│   │   │   └── layout.tsx        # Org layout with switcher
│   │   ├── profile/
│   │   │   └── page.tsx          # User profile
│   │   └── layout.tsx            # Auth layout
│   ├── api/
│   │   ├── organizations/
│   │   │   ├── route.ts          # GET/POST organizations
│   │   │   └── [orgId]/
│   │   │       ├── route.ts      # GET/PUT/DELETE organization
│   │   │       ├── members/
│   │   │       │   └── route.ts  # GET/POST members
│   │   │       └── projects/
│   │   │           └── route.ts  # GET/POST projects
│   │   └── invitations/
│   │       ├── route.ts          # GET/POST invitations
│   │       └── [invitationId]/
│   │           └── route.ts      # Accept/reject invitation
│   ├── components/
│   │   ├── OrganizationSwitcher.tsx
│   │   ├── OrganizationInviteButton.tsx
│   │   ├── RoleBadge.tsx
│   │   └── ProjectList.tsx
│   ├── lib/
│   │   ├── org-helpers.ts        # Organization utilities
│   │   ├── permissions.ts        # Updated with org permissions
│   │   └── auth-helpers.ts       # Updated with org support
│   └── middleware.ts            # Updated with org protection
├── prisma/
│   ├── schema.prisma            # Database schema with org support
│   └── migrations/
├── .env.local
└── package.json
```

---

## Deep Dive: Clerk Organizations

### How Clerk Organizations Work

Clerk Organizations provide a complete multi-tenancy solution:

```
┌─────────────────────────────────────────────────────────────┐
│                    Clerk Platform                           │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Organizations Service                              │   │
│  │                                                     │   │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐ │   │
│  │  │ Organization│  │ Organization│  │ Organization│ │   │
│  │  │    A        │  │    B        │  │    C        │ │   │
│  │  │             │  │             │  │             │ │   │
│  │  │ Members:    │  │ Members:    │  │ Members:    │ │   │
│  │  │ - Alice     │  │ - Bob       │  │ - Charlie   │ │   │
│  │  │ - Bob       │  │ - Charlie   │  │ - Dave      │ │   │
│  │  │ - Charlie   │  │             │  │             │ │   │
│  │  └─────────────┘  └─────────────┘  └─────────────┘ │   │
│  │                                                     │   │
│  │  Roles: admin, moderator, member, guest             │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  User Service                                       │   │
│  │                                                     │   │
│  │  ┌─────────────────────────────────────────────────┐│   │
│  │  │ User: Bob                                      ││   │
│  │  │ Organizations:                                 ││   │
│  │  │ - Org A: admin                                ││   │
│  │  │ - Org B: member                               ││   │
│  │  └─────────────────────────────────────────────────┘│   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

### Key Organization Concepts

| Concept | Description |
|---------|-------------|
| **Organization** | A tenant/workspace that groups users and resources |
| **Member** | A user who belongs to an organization |
| **Role** | Defines what a member can do within the organization |
| **Permission** | Specific actions a member can perform (e.g., read, write, delete) |
| **Invitation** | A pending request for a user to join an organization |
| **Organization ID** | Unique identifier for the organization (e.g., `org_123abc`) |
| **Active Organization** | The organization currently selected by the user |

### Organization Role Hierarchy

We'll implement this role hierarchy:

```
┌─────────────────────────────────────────────────────────────┐
│                    Role Hierarchy                           │
│                                                             │
│                     ┌───────────┐                          │
│                     │  Admin    │                          │
│                     │ (Full     │                          │
│                     │  Access)  │                          │
│                     └─────┬─────┘                          │
│                           │                                │
│                     ┌─────┴─────┐                          │
│                     │ Moderator │                          │
│                     │ (Manage   │                          │
│                     │  Content) │                          │
│                     └─────┬─────┘                          │
│                           │                                │
│                     ┌─────┴─────┐                          │
│                     │  Member   │                          │
│                     │ (Standard │                          │
│                     │  Access)  │                          │
│                     └─────┬─────┘                          │
│                           │                                │
│                     ┌─────┴─────┐                          │
│                     │  Guest    │                          │
│                     │ (Read-    │                          │
│                     │  Only)    │                          │
│                     └───────────┘                          │
└─────────────────────────────────────────────────────────────┘
```

---

## Step 1: Enable Organizations in Clerk Dashboard

First, let's enable the Organizations feature in your Clerk application.

### 1.1 Access Organization Settings

1. Go to the [Clerk Dashboard](https://dashboard.clerk.com)
2. Select your application (the one you created in Part 1)
3. In the left sidebar, click **"User & Authentication"** → **"Organizations"**

### 1.2 Enable Organizations

1. Toggle **"Enable Organizations"** to ON
2. Configure the following settings:
   - **Organization Name:** Enable this field
   - **Organization Slug:** Enable this field (used for URLs)
   - **Organization Logo:** Enable this field (optional)
   - **Membership Roles:** We'll create custom roles later

3. Click **"Save"**

### 1.3 Configure Organization Settings

Under **"Organization Settings"**, configure:

| Setting | Value |
|---------|-------|
| **Max Members** | Leave as default (unlimited for development) |
| **Max Organizations** | Leave as default |
| **Allow Users to Create Organizations** | Enable |
| **Require Email Verification** | Enable (recommended for security) |
| **Invitation Expiry** | 7 days (default) |

### 1.4 Create Custom Roles

Click **"Membership Roles"** and create custom roles:

1. **Admin Role:**
   - **Name:** `admin`
   - **Permissions:** `org:read`, `org:write`, `org:delete`, `org:members`, `org:invite`
   - **Key:** `admin` (default)

2. **Moderator Role:**
   - **Name:** `moderator`
   - **Permissions:** `org:read`, `org:write`, `org:members` (read-only)
   - **Key:** `moderator`

3. **Member Role:**
   - **Name:** `member`
   - **Permissions:** `org:read`, `org:write` (limited)
   - **Key:** `member`

4. **Guest Role:**
   - **Name:** `guest`
   - **Permissions:** `org:read` (read-only)
   - **Key:** `guest`

---

## Step 2: Update Environment Variables

Add organization-related configuration to your `.env.local`:

**File:** `.env.local`

```env
# .env.local - Updated with organization configuration

# Clerk API Keys (from Part 1)
NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY=pk_test_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
CLERK_SECRET_KEY=sk_test_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

# Clerk Configuration
NEXT_PUBLIC_CLERK_SIGN_IN_URL=/sign-in
NEXT_PUBLIC_CLERK_SIGN_UP_URL=/sign-up
NEXT_PUBLIC_CLERK_AFTER_SIGN_IN_URL=/dashboard
NEXT_PUBLIC_CLERK_AFTER_SIGN_UP_URL=/dashboard

# Organization Configuration
NEXT_PUBLIC_CLERK_ORGANIZATION_URL=/organization

# Database Configuration (for Part 3)
DATABASE_URL="postgresql://postgres:password@localhost:5432/clerk_mastery_part3"

# App Configuration
NEXT_PUBLIC_APP_NAME="Clerk Mastery - Part 3"
NEXT_PUBLIC_APP_URL="http://localhost:3000"
```

---

## Step 3: Update Auth Helpers with Organization Support

Extend our auth helpers to work with organizations.

**File:** `lib/auth-helpers.ts` (updated)

```tsx
// lib/auth-helpers.ts
// Updated with organization support

import { auth, currentUser, clerkClient, getOrganizationMemberships } from "@clerk/nextjs/server";
import { NextRequest, NextResponse } from "next/server";

// ... (previous code from Part 2)

// New type definitions for organization support
export type OrganizationRole = "admin" | "moderator" | "member" | "guest";

export interface OrganizationMembership {
  id: string;
  role: OrganizationRole;
  organization: {
    id: string;
    name: string;
    slug: string;
    createdAt: Date;
  };
}

export interface AuthContextWithOrg extends AuthContext {
  activeOrganizationId: string | null;
  activeOrganization: {
    id: string;
    name: string;
    slug: string;
    role: OrganizationRole;
  } | null;
  memberships: OrganizationMembership[];
}

/**
 * Get the current authentication context with organization support
 * 
 * @returns Extended AuthContext with organization data
 */
export async function getAuthContextWithOrg(): Promise<AuthContextWithOrg> {
  const { userId, sessionId, orgId } = await auth();
  
  if (!userId) {
    throw new Error("User not authenticated");
  }

  const user = await currentUser();
  const role = user?.publicMetadata?.role as string || "guest";
  const permissions = user?.publicMetadata?.permissions as string[] || [];
  
  // Get organization memberships
  const memberships = await getOrganizationMemberships({
    userId,
    // Include all memberships, including those pending
  });
  
  // Format memberships
  const formattedMemberships: OrganizationMembership[] = memberships.data.map(membership => ({
    id: membership.id,
    role: membership.role as OrganizationRole,
    organization: {
      id: membership.organization.id,
      name: membership.organization.name,
      slug: membership.organization.slug || "",
      createdAt: membership.organization.createdAt,
    },
  }));
  
  // Get active organization details
  let activeOrganization = null;
  if (orgId) {
    const orgMembership = memberships.data.find(m => m.organization.id === orgId);
    if (orgMembership) {
      activeOrganization = {
        id: orgId,
        name: orgMembership.organization.name,
        slug: orgMembership.organization.slug || "",
        role: orgMembership.role as OrganizationRole,
      };
    }
  }
  
  return {
    userId,
    sessionId: sessionId || "",
    orgId: orgId || null,
    role,
    permissions,
    isAuthenticated: true,
    activeOrganizationId: orgId || null,
    activeOrganization,
    memberships: formattedMemberships,
  };
}

/**
 * Require an active organization for the current user
 * 
 * @param request - NextRequest object
 * @param redirectTo - Optional redirect URL
 * @returns AuthContext with organization data
 * @throws {Error} If user has no active organization
 */
export async function requireOrganization(
  request: NextRequest,
  redirectTo: string = "/sign-in"
): Promise<AuthContextWithOrg> {
  const authContext = await requireAuth(request, redirectTo);
  const orgContext = await getAuthContextWithOrg();
  
  if (!orgContext.activeOrganizationId) {
    // User is authenticated but has no active organization
    // Redirect to organization selection page
    const redirectResponse = NextResponse.redirect(
      new URL("/organization/select", request.url)
    );
    throw new Error("No active organization");
  }
  
  return orgContext;
}

/**
 * Require a specific role within the active organization
 * 
 * @param requiredRole - The role required for access
 * @param request - NextRequest object
 * @param redirectTo - Optional redirect URL
 * @returns AuthContext with organization data
 * @throws {Error} If user doesn't have required role
 */
export async function requireOrganizationRole(
  requiredRole: OrganizationRole,
  request: NextRequest,
  redirectTo: string = "/sign-in"
): Promise<AuthContextWithOrg> {
  const orgContext = await requireOrganization(request, redirectTo);
  
  // Check if user has the required role in the active organization
  const hasRole = orgContext.activeOrganization?.role === requiredRole;
  
  if (!hasRole) {
    throw new Error(`Required role: ${requiredRole}`);
  }
  
  return orgContext;
}

/**
 * Check if the user has a specific role in the active organization
 * 
 * @param requiredRole - The role to check for
 * @returns boolean indicating if user has the role
 */
export async function hasOrganizationRole(requiredRole: OrganizationRole): Promise<boolean> {
  try {
    const orgContext = await getAuthContextWithOrg();
    return orgContext.activeOrganization?.role === requiredRole;
  } catch (error) {
    return false;
  }
}

/**
 * Get the active organization ID
 * 
 * @returns Organization ID or null
 */
export async function getActiveOrganizationId(): Promise<string | null> {
  try {
    const { orgId } = await auth();
    return orgId || null;
  } catch (error) {
    return null;
  }
}
```

---

## Step 4: Update Permissions with Organization Support

**File:** `lib/permissions.ts` (updated)

```tsx
// lib/permissions.ts
// Updated with organization permissions

// ... (previous code from Part 2)

// Add organization-specific permissions
export const ORG_PERMISSIONS = {
  // Organization management
  ORG_READ: "org:read",
  ORG_WRITE: "org:write",
  ORG_DELETE: "org:delete",
  ORG_SETTINGS: "org:settings",
  
  // Member management
  ORG_MEMBERS_READ: "org:members:read",
  ORG_MEMBERS_WRITE: "org:members:write",
  ORG_MEMBERS_DELETE: "org:members:delete",
  ORG_MEMBERS_INVITE: "org:members:invite",
  
  // Project management
  ORG_PROJECTS_READ: "org:projects:read",
  ORG_PROJECTS_WRITE: "org:projects:write",
  ORG_PROJECTS_DELETE: "org:projects:delete",
} as const;

// Organization role permission mappings
export const ORG_ROLE_PERMISSIONS = {
  guest: [
    ORG_PERMISSIONS.ORG_READ,
    ORG_PERMISSIONS.ORG_PROJECTS_READ,
  ],
  
  member: [
    ORG_PERMISSIONS.ORG_READ,
    ORG_PERMISSIONS.ORG_PROJECTS_READ,
    ORG_PERMISSIONS.ORG_PROJECTS_WRITE,
  ],
  
  moderator: [
    ORG_PERMISSIONS.ORG_READ,
    ORG_PERMISSIONS.ORG_WRITE,
    ORG_PERMISSIONS.ORG_PROJECTS_READ,
    ORG_PERMISSIONS.ORG_PROJECTS_WRITE,
    ORG_PERMISSIONS.ORG_PROJECTS_DELETE,
    ORG_PERMISSIONS.ORG_MEMBERS_READ,
  ],
  
  admin: [
    ORG_PERMISSIONS.ORG_READ,
    ORG_PERMISSIONS.ORG_WRITE,
    ORG_PERMISSIONS.ORG_DELETE,
    ORG_PERMISSIONS.ORG_SETTINGS,
    ORG_PERMISSIONS.ORG_PROJECTS_READ,
    ORG_PERMISSIONS.ORG_PROJECTS_WRITE,
    ORG_PERMISSIONS.ORG_PROJECTS_DELETE,
    ORG_PERMISSIONS.ORG_MEMBERS_READ,
    ORG_PERMISSIONS.ORG_MEMBERS_WRITE,
    ORG_PERMISSIONS.ORG_MEMBERS_DELETE,
    ORG_PERMISSIONS.ORG_MEMBERS_INVITE,
  ],
};

/**
 * Check if a user has an organization permission
 * 
 * @param userRole - The user's role in the organization
 * @param permission - The permission to check
 * @returns boolean indicating if the user has the permission
 */
export function hasOrgPermission(userRole: string, permission: string): boolean {
  const userPermissions = ORG_ROLE_PERMISSIONS[userRole as keyof typeof ORG_ROLE_PERMISSIONS] || [];
  return userPermissions.includes(permission);
}

/**
 * Check if a user has any of the required organization permissions
 * 
 * @param userRole - The user's role in the organization
 * @param requiredPermissions - Array of permissions to check
 * @returns boolean indicating if user has any required permission
 */
export function hasAnyOrgPermission(
  userRole: string,
  requiredPermissions: string[]
): boolean {
  const userPermissions = ORG_ROLE_PERMISSIONS[userRole as keyof typeof ORG_ROLE_PERMISSIONS] || [];
  return requiredPermissions.some(permission => userPermissions.includes(permission));
}
```

---

## Step 5: Create Organization Helpers

**File:** `lib/org-helpers.ts`

```tsx
// lib/org-helpers.ts
// Organization-specific helper functions

import { clerkClient, organizations } from "@clerk/nextjs/server";
import { OrganizationRole } from "@/lib/auth-helpers";
import { logAuthEvent } from "@/lib/auth-helpers";

/**
 * Create a new organization
 * 
 * @param userId - The user ID creating the organization
 * @param name - Organization name
 * @param slug - Organization slug (URL-friendly name)
 * @param metadata - Additional metadata
 * @returns The created organization
 */
export async function createOrganization(
  userId: string,
  name: string,
  slug: string,
  metadata?: Record<string, unknown>
) {
  try {
    const org = await clerkClient().organizations.createOrganization({
      name,
      slug,
      createdBy: userId,
      publicMetadata: metadata || {},
    });
    
    // Log the creation
    await logAuthEvent(userId, "organization_created", {
      orgId: org.id,
      name: org.name,
      slug: org.slug,
    });
    
    return org;
  } catch (error) {
    console.error("Failed to create organization:", error);
    throw new Error("Failed to create organization");
  }
}

/**
 * Get an organization by ID
 * 
 * @param orgId - The organization ID
 * @returns The organization
 */
export async function getOrganization(orgId: string) {
  try {
    return await clerkClient().organizations.getOrganization({
      organizationId: orgId,
    });
  } catch (error) {
    console.error("Failed to get organization:", error);
    return null;
  }
}

/**
 * Update organization settings
 * 
 * @param orgId - The organization ID
 * @param data - Data to update (name, slug, metadata)
 * @returns Updated organization
 */
export async function updateOrganization(
  orgId: string,
  data: {
    name?: string;
    slug?: string;
    metadata?: Record<string, unknown>;
  }
) {
  try {
    return await clerkClient().organizations.updateOrganization({
      organizationId: orgId,
      ...data,
    });
  } catch (error) {
    console.error("Failed to update organization:", error);
    throw new Error("Failed to update organization");
  }
}

/**
 * Delete an organization
 * 
 * @param orgId - The organization ID
 */
export async function deleteOrganization(orgId: string) {
  try {
    await clerkClient().organizations.deleteOrganization({
      organizationId: orgId,
    });
  } catch (error) {
    console.error("Failed to delete organization:", error);
    throw new Error("Failed to delete organization");
  }
}

/**
 * Invite a user to join an organization
 * 
 * @param orgId - The organization ID
 * @param email - The user's email
 * @param role - The role to assign
 * @param inviterUserId - The user sending the invitation
 * @returns The invitation
 */
export async function inviteUserToOrganization(
  orgId: string,
  email: string,
  role: OrganizationRole,
  inviterUserId: string
) {
  try {
    const invitation = await clerkClient().organizations.createOrganizationInvitation({
      organizationId: orgId,
      emailAddress: email,
      role,
      inviterUserId,
      publicMetadata: {
        invitedAt: new Date().toISOString(),
      },
    });
    
    // Log the invitation
    await logAuthEvent(inviterUserId, "organization_invite_sent", {
      orgId,
      email,
      role,
      invitationId: invitation.id,
    });
    
    return invitation;
  } catch (error) {
    console.error("Failed to send invitation:", error);
    throw new Error("Failed to send invitation");
  }
}

/**
 * Accept an organization invitation
 * 
 * @param invitationId - The invitation ID
 * @param userId - The user accepting the invitation
 * @returns The accepted membership
 */
export async function acceptOrganizationInvitation(invitationId: string, userId: string) {
  try {
    const membership = await clerkClient().organizations.acceptOrganizationInvitation({
      invitationId,
      userId,
    });
    
    // Log the acceptance
    await logAuthEvent(userId, "organization_invite_accepted", {
      invitationId,
      orgId: membership.organization.id,
    });
    
    return membership;
  } catch (error) {
    console.error("Failed to accept invitation:", error);
    throw new Error("Failed to accept invitation");
  }
}

/**
 * Remove a member from an organization
 * 
 * @param orgId - The organization ID
 * @param userId - The user ID to remove
 */
export async function removeMemberFromOrganization(orgId: string, userId: string) {
  try {
    await clerkClient().organizations.deleteOrganizationMembership({
      organizationId: orgId,
      userId,
    });
  } catch (error) {
    console.error("Failed to remove member:", error);
    throw new Error("Failed to remove member");
  }
}

/**
 * Update a member's role in an organization
 * 
 * @param orgId - The organization ID
 * @param userId - The user ID
 * @param role - The new role
 * @returns Updated membership
 */
export async function updateMemberRole(
  orgId: string,
  userId: string,
  role: OrganizationRole
) {
  try {
    return await clerkClient().organizations.updateOrganizationMembership({
      organizationId: orgId,
      userId,
      role,
    });
  } catch (error) {
    console.error("Failed to update member role:", error);
    throw new Error("Failed to update member role");
  }
}

/**
 * List all members of an organization
 * 
 * @param orgId - The organization ID
 * @param limit - Maximum number of members to return
 * @returns List of members
 */
export async function listOrganizationMembers(orgId: string, limit: number = 50) {
  try {
    const members = await clerkClient().organizations.getOrganizationMembershipList({
      organizationId: orgId,
      limit,
    });
    
    return members;
  } catch (error) {
    console.error("Failed to list members:", error);
    return { data: [], total_count: 0 };
  }
}

/**
 * Check if a user is a member of an organization
 * 
 * @param orgId - The organization ID
 * @param userId - The user ID
 * @returns boolean indicating membership
 */
export async function isMemberOfOrganization(orgId: string, userId: string): Promise<boolean> {
  try {
    const memberships = await clerkClient().organizations.getOrganizationMembershipList({
      organizationId: orgId,
      userId,
    });
    
    return memberships.data.length > 0;
  } catch (error) {
    return false;
  }
}
```

---

## Step 6: Update Middleware with Organization Protection

**File:** `middleware.ts` (updated with organization support)

```tsx
// middleware.ts
// Updated middleware with organization protection

import { clerkMiddleware, createRouteMatcher } from "@clerk/nextjs/server";
import { NextResponse } from "next/server";

// Define route patterns
const isProtectedRoute = createRouteMatcher([
  "/dashboard(.*)",
  "/profile(.*)",
  "/settings(.*)",
  "/organization(.*)",
  "/api/organizations(.*)",
  "/api/invitations(.*)",
]);

const isOrganizationRoute = createRouteMatcher([
  "/organization/(.*)",
  "/api/organizations/(.*)",
]);

export default clerkMiddleware(async (auth, req) => {
  const path = req.nextUrl.pathname;
  const { userId, orgId } = await auth();
  
  // Check if route is protected
  if (isProtectedRoute(req)) {
    if (!userId) {
      // Unauthenticated - redirect to sign-in
      const signInUrl = new URL("/sign-in", req.url);
      signInUrl.searchParams.set("redirect_url", path);
      return NextResponse.redirect(signInUrl);
    }
    
    // Check if route requires organization context
    if (isOrganizationRoute(req) && !orgId) {
      // User is authenticated but has no active organization
      // Redirect to organization selection
      return NextResponse.redirect(new URL("/organization/select", req.url));
    }
  }
  
  return NextResponse.next();
});

export const config = {
  matcher: [
    "/((?!_next|[^?]*\\.(?:html?|css|js(?!on)|jpe?g|webp|png|gif|svg|ttf|woff2?|ico|csv|docx?|xlsx?|zip|webmanifest)).*)",
    "/(api|trpc)(.*)",
  ],
};
```

---

## Step 7: Create Organization Selection Page

**File:** `app/organization/select/page.tsx`

```tsx
// app/organization/select/page.tsx
// Organization selection page - displays all user's organizations

import { auth, clerkClient } from "@clerk/nextjs/server";
import { redirect } from "next/navigation";
import Link from "next/link";
import { UserButton } from "@clerk/nextjs";

export default async function OrganizationSelectPage() {
  const { userId } = await auth();
  
  if (!userId) {
    redirect("/sign-in");
  }
  
  // Get user's organization memberships
  const memberships = await clerkClient().organizations.getOrganizationMembershipList({
    userId,
  });
  
  const organizations = memberships.data.map(membership => ({
    id: membership.organization.id,
    name: membership.organization.name,
    slug: membership.organization.slug,
    role: membership.role,
    imageUrl: membership.organization.imageUrl,
  }));
  
  // If user has no organizations, show create option
  if (organizations.length === 0) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="max-w-md w-full bg-white rounded-lg shadow-sm p-8">
          <div className="text-center">
            <div className="text-6xl mb-4">🏢</div>
            <h1 className="text-2xl font-bold text-gray-900 mb-2">
              No Organizations Found
            </h1>
            <p className="text-gray-600 mb-6">
              You're not a member of any organization yet. Create your first organization to get started.
            </p>
            <Link
              href="/organization/create"
              className="inline-block bg-indigo-600 text-white px-6 py-3 rounded-md hover:bg-indigo-700 transition-colors"
            >
              Create Organization
            </Link>
          </div>
        </div>
      </div>
    );
  }
  
  // If user has exactly one organization, redirect to it
  if (organizations.length === 1) {
    redirect(`/organization/${organizations[0].id}`);
  }
  
  // Show organization selection
  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <header className="bg-white shadow-sm border-b border-gray-200">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
          <div className="flex items-center justify-between">
            <Link href="/" className="text-xl font-bold text-indigo-600">
              Clerk Mastery
            </Link>
            <div className="flex items-center space-x-4">
              <UserButton afterSignOutUrl="/" />
            </div>
          </div>
        </div>
      </header>
      
      {/* Main Content */}
      <main className="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
        <div className="text-center mb-8">
          <h1 className="text-3xl font-bold text-gray-900">
            Select Your Organization
          </h1>
          <p className="text-gray-600 mt-2">
            Choose which organization you want to access
          </p>
        </div>
        
        <div className="grid gap-4">
          {organizations.map((org) => (
            <Link
              key={org.id}
              href={`/organization/${org.id}`}
              className="block bg-white rounded-lg shadow-sm hover:shadow-md transition-shadow p-6 border-2 border-transparent hover:border-indigo-500"
            >
              <div className="flex items-center space-x-4">
                {org.imageUrl ? (
                  <img
                    src={org.imageUrl}
                    alt={org.name}
                    className="w-12 h-12 rounded-full"
                  />
                ) : (
                  <div className="w-12 h-12 rounded-full bg-indigo-100 flex items-center justify-center">
                    <span className="text-indigo-600 text-xl font-bold">
                      {org.name.charAt(0).toUpperCase()}
                    </span>
                  </div>
                )}
                <div className="flex-1">
                  <h3 className="text-lg font-semibold text-gray-900">
                    {org.name}
                  </h3>
                  <div className="flex items-center space-x-2 text-sm">
                    <span className="text-gray-500">@{org.slug}</span>
                    <span className="text-gray-300">•</span>
                    <span className="text-gray-500 capitalize">
                      Role: {org.role}
                    </span>
                  </div>
                </div>
                <div className="text-indigo-600">
                  <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 7l5 5m0 0l-5 5m5-5H6" />
                  </svg>
                </div>
              </div>
            </Link>
          ))}
        </div>
        
        <div className="mt-6 text-center">
          <Link
            href="/organization/create"
            className="text-indigo-600 hover:text-indigo-700 font-medium"
          >
            + Create a new organization
          </Link>
        </div>
      </main>
    </div>
  );
}
```

---

## Step 8: Create Organization Creation Page

**File:** `app/organization/create/page.tsx`

```tsx
// app/organization/create/page.tsx
// Organization creation page

"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { useUser } from "@clerk/nextjs";
import Link from "next/link";
import { createOrganization } from "@/lib/org-helpers";
import { slugify } from "@/lib/utils";

export default function CreateOrganizationPage() {
  const { user, isLoaded } = useUser();
  const router = useRouter();
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  
  const [formData, setFormData] = useState({
    name: "",
    slug: "",
    description: "",
  });
  
  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) => {
    const { name, value } = e.target;
    setFormData(prev => ({ ...prev, [name]: value }));
    
    // Auto-generate slug from name
    if (name === "name") {
      const generatedSlug = slugify(value);
      setFormData(prev => ({ ...prev, slug: generatedSlug }));
    }
  };
  
  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError(null);
    
    // Validation
    if (!formData.name.trim()) {
      setError("Organization name is required");
      setLoading(false);
      return;
    }
    
    if (!formData.slug.trim()) {
      setError("Organization slug is required");
      setLoading(false);
      return;
    }
    
    try {
      // Create the organization
      const org = await createOrganization(
        user?.id || "",
        formData.name.trim(),
        formData.slug.trim(),
        {
          description: formData.description.trim(),
          createdAt: new Date().toISOString(),
        }
      );
      
      // Redirect to the organization dashboard
      router.push(`/organization/${org.id}`);
      
    } catch (error) {
      console.error("Failed to create organization:", error);
      setError("Failed to create organization. Please try again.");
    } finally {
      setLoading(false);
    }
  };
  
  if (!isLoaded) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="text-gray-500">Loading...</div>
      </div>
    );
  }
  
  if (!user) {
    router.push("/sign-in");
    return null;
  }
  
  return (
    <div className="min-h-screen bg-gray-50">
      <div className="max-w-md mx-auto px-4 py-12">
        {/* Header */}
        <div className="mb-8">
          <Link href="/" className="text-xl font-bold text-indigo-600">
            Clerk Mastery
          </Link>
          <h1 className="text-2xl font-bold text-gray-900 mt-4">
            Create Your Organization
          </h1>
          <p className="text-gray-600">
            Set up your organization and invite team members
          </p>
        </div>
        
        {/* Form */}
        <div className="bg-white rounded-lg shadow-sm p-6">
          {error && (
            <div className="mb-4 p-3 bg-red-100 text-red-700 rounded">
              {error}
            </div>
          )}
          
          <form onSubmit={handleSubmit} className="space-y-4">
            {/* Organization Name */}
            <div>
              <label htmlFor="name" className="block text-sm font-medium text-gray-700">
                Organization Name *
              </label>
              <input
                type="text"
                id="name"
                name="name"
                value={formData.name}
                onChange={handleChange}
                required
                placeholder="Acme Corporation"
                className="mt-1 block w-full border border-gray-300 rounded-md shadow-sm px-3 py-2 focus:ring-indigo-500 focus:border-indigo-500"
              />
            </div>
            
            {/* Organization Slug */}
            <div>
              <label htmlFor="slug" className="block text-sm font-medium text-gray-700">
                Organization Slug *
              </label>
              <div className="mt-1 relative">
                <span className="absolute left-3 top-2 text-gray-400">@</span>
                <input
                  type="text"
                  id="slug"
                  name="slug"
                  value={formData.slug}
                  onChange={handleChange}
                  required
                  placeholder="acme-corp"
                  className="pl-8 block w-full border border-gray-300 rounded-md shadow-sm px-3 py-2 focus:ring-indigo-500 focus:border-indigo-500"
                />
              </div>
              <p className="mt-1 text-xs text-gray-500">
                URL-friendly name: /organization/{formData.slug || "your-org"}
              </p>
            </div>
            
            {/* Description */}
            <div>
              <label htmlFor="description" className="block text-sm font-medium text-gray-700">
                Description (optional)
              </label>
              <textarea
                id="description"
                name="description"
                value={formData.description}
                onChange={handleChange}
                rows={3}
                placeholder="Tell us about your organization..."
                className="mt-1 block w-full border border-gray-300 rounded-md shadow-sm px-3 py-2 focus:ring-indigo-500 focus:border-indigo-500"
              />
            </div>
            
            {/* Submit Button */}
            <button
              type="submit"
              disabled={loading}
              className="w-full bg-indigo-600 text-white px-4 py-2 rounded-md hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
            >
              {loading ? "Creating..." : "Create Organization"}
            </button>
          </form>
          
          <div className="mt-4 text-center">
            <Link
              href="/organization/select"
              className="text-sm text-gray-500 hover:text-gray-700"
            >
              ← Back to organization selection
            </Link>
          </div>
        </div>
      </div>
    </div>
  );
}

// Utility function for generating slugs
function slugify(text: string): string {
  return text
    .toLowerCase()
    .trim()
    .replace(/[^\w\s-]/g, "")
    .replace(/[\s_-]+/g, "-")
    .replace(/^-+|-+$/g, "");
}
```

---

## Step 9: Create Organization Layout with Switcher

**File:** `app/organization/[orgId]/layout.tsx`

```tsx
// app/organization/[orgId]/layout.tsx
// Organization layout with organization switcher and navigation

import { auth, clerkClient } from "@clerk/nextjs/server";
import { redirect } from "next/navigation";
import Link from "next/link";
import { OrganizationSwitcher, UserButton } from "@clerk/nextjs";
import { getAuthContextWithOrg } from "@/lib/auth-helpers";

interface OrganizationLayoutProps {
  children: React.ReactNode;
  params: {
    orgId: string;
  };
}

export default async function OrganizationLayout({
  children,
  params,
}: OrganizationLayoutProps) {
  const { userId } = await auth();
  
  if (!userId) {
    redirect("/sign-in");
  }
  
  // Get organization details
  const org = await clerkClient().organizations.getOrganization({
    organizationId: params.orgId,
  });
  
  if (!org) {
    redirect("/organization/select");
  }
  
  // Check if user is a member of the organization
  const memberships = await clerkClient().organizations.getOrganizationMembershipList({
    organizationId: params.orgId,
    userId,
  });
  
  if (memberships.data.length === 0) {
    // User is not a member of this organization
    redirect("/organization/select");
  }
  
  // Get auth context with organization
  const authContext = await getAuthContextWithOrg();
  
  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <header className="bg-white shadow-sm border-b border-gray-200">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-4">
              <Link href="/" className="text-xl font-bold text-indigo-600">
                Clerk Mastery
              </Link>
              <span className="text-gray-300">|</span>
              <div className="flex items-center space-x-2">
                <span className="text-gray-700">{org.name}</span>
                <span className="text-xs text-gray-400 capitalize">
                  ({authContext.activeOrganization?.role})
                </span>
              </div>
            </div>
            
            <div className="flex items-center space-x-4">
              {/* Organization Switcher */}
              <OrganizationSwitcher
                afterSelectOrganizationUrl="/organization/select"
                appearance={{
                  elements: {
                    rootBox: "flex items-center",
                  },
                }}
              />
              
              {/* User Button */}
              <UserButton afterSignOutUrl="/" />
            </div>
          </div>
        </div>
      </header>
      
      {/* Navigation */}
      <nav className="bg-white border-b border-gray-200">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex space-x-8">
            <Link
              href={`/organization/${params.orgId}`}
              className="py-3 text-sm font-medium text-gray-700 hover:text-indigo-600 border-b-2 border-transparent hover:border-indigo-600"
            >
              Dashboard
            </Link>
            <Link
              href={`/organization/${params.orgId}/projects`}
              className="py-3 text-sm font-medium text-gray-700 hover:text-indigo-600 border-b-2 border-transparent hover:border-indigo-600"
            >
              Projects
            </Link>
            <Link
              href={`/organization/${params.orgId}/members`}
              className="py-3 text-sm font-medium text-gray-700 hover:text-indigo-600 border-b-2 border-transparent hover:border-indigo-600"
            >
              Members
            </Link>
            <Link
              href={`/organization/${params.orgId}/settings`}
              className="py-3 text-sm font-medium text-gray-700 hover:text-indigo-600 border-b-2 border-transparent hover:border-indigo-600"
            >
              Settings
            </Link>
          </div>
        </div>
      </nav>
      
      {/* Main Content */}
      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {children}
      </main>
    </div>
  );
}
```

---

## Step 10: Create Organization Dashboard

**File:** `app/organization/[orgId]/page.tsx`

```tsx
// app/organization/[orgId]/page.tsx
// Organization dashboard

import { auth, clerkClient } from "@clerk/nextjs/server";
import { redirect } from "next/navigation";
import { getAuthContextWithOrg } from "@/lib/auth-helpers";

export default async function OrganizationDashboard({
  params,
}: {
  params: { orgId: string };
}) {
  const { userId } = await auth();
  
  if (!userId) {
    redirect("/sign-in");
  }
  
  // Get organization details
  const org = await clerkClient().organizations.getOrganization({
    organizationId: params.orgId,
  });
  
  if (!org) {
    redirect("/organization/select");
  }
  
  // Get auth context
  const authContext = await getAuthContextWithOrg();
  
  // Get organization members
  const memberships = await clerkClient().organizations.getOrganizationMembershipList({
    organizationId: params.orgId,
    limit: 10,
  });
  
  // Member count
  const memberCount = memberships.data.length;
  
  return (
    <div className="space-y-6">
      {/* Welcome Section */}
      <div className="bg-white rounded-lg shadow-sm p-6">
        <h1 className="text-2xl font-bold text-gray-900">
          Welcome to {org.name}
        </h1>
        <p className="text-gray-600 mt-1">
          You're signed in as {authContext.activeOrganization?.role}
        </p>
        <div className="mt-4 flex items-center space-x-4 text-sm">
          <span className="text-gray-500">
            Organization ID: {org.id}
          </span>
          <span className="text-gray-300">|</span>
          <span className="text-gray-500">
            Slug: @{org.slug}
          </span>
        </div>
      </div>
      
      {/* Stats Grid */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <div className="bg-white rounded-lg shadow-sm p-6">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-500">Members</p>
              <p className="text-2xl font-bold text-gray-900">{memberCount}</p>
            </div>
            <div className="text-3xl">👥</div>
          </div>
        </div>
        
        <div className="bg-white rounded-lg shadow-sm p-6">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-500">Projects</p>
              <p className="text-2xl font-bold text-gray-900">0</p>
            </div>
            <div className="text-3xl">📁</div>
          </div>
        </div>
        
        <div className="bg-white rounded-lg shadow-sm p-6">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-500">Your Role</p>
              <p className="text-2xl font-bold text-gray-900 capitalize">
                {authContext.activeOrganization?.role}
              </p>
            </div>
            <div className="text-3xl">🎯</div>
          </div>
        </div>
      </div>
      
      {/* Quick Actions */}
      <div className="bg-white rounded-lg shadow-sm p-6">
        <h2 className="text-lg font-semibold text-gray-900 mb-4">Quick Actions</h2>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          <button className="flex items-center justify-center space-x-2 p-3 border-2 border-dashed border-gray-300 rounded-lg hover:border-indigo-500 hover:bg-indigo-50 transition-colors">
            <span className="text-xl">➕</span>
            <span className="text-sm text-gray-700">Invite Members</span>
          </button>
          <button className="flex items-center justify-center space-x-2 p-3 border-2 border-dashed border-gray-300 rounded-lg hover:border-indigo-500 hover:bg-indigo-50 transition-colors">
            <span className="text-xl">📋</span>
            <span className="text-sm text-gray-700">Create Project</span>
          </button>
          <button className="flex items-center justify-center space-x-2 p-3 border-2 border-dashed border-gray-300 rounded-lg hover:border-indigo-500 hover:bg-indigo-50 transition-colors">
            <span className="text-xl">⚙️</span>
            <span className="text-sm text-gray-700">Settings</span>
          </button>
        </div>
      </div>
      
      {/* Recent Members */}
      {memberships.data.length > 0 && (
        <div className="bg-white rounded-lg shadow-sm p-6">
          <h2 className="text-lg font-semibold text-gray-900 mb-4">
            Recent Members
          </h2>
          <div className="space-y-3">
            {memberships.data.map((membership) => (
              <div key={membership.id} className="flex items-center justify-between">
                <div className="flex items-center space-x-3">
                  <div className="w-8 h-8 rounded-full bg-gray-200 flex items-center justify-center">
                    <span className="text-sm font-medium text-gray-600">
                      {membership.publicUserData?.firstName?.[0] || "U"}
                    </span>
                  </div>
                  <div>
                    <p className="text-sm font-medium text-gray-900">
                      {membership.publicUserData?.firstName} {membership.publicUserData?.lastName}
                    </p>
                    <p className="text-xs text-gray-500">
                      {membership.publicUserData?.email}
                    </p>
                  </div>
                </div>
                <span className="text-xs text-gray-500 capitalize">
                  {membership.role}
                </span>
              </div>
            ))}
          </div>
        </div>
      )}
    </div>
  );
}
```

---

## Step 11: Create Member Management Page

**File:** `app/organization/[orgId]/members/page.tsx`

```tsx
// app/organization/[orgId]/members/page.tsx
// Organization member management page

import { auth, clerkClient } from "@clerk/nextjs/server";
import { redirect } from "next/navigation";
import { getAuthContextWithOrg, hasOrganizationRole } from "@/lib/auth-helpers";
import MemberList from "@/app/components/MemberList";
import InviteMemberForm from "@/app/components/InviteMemberForm";

export default async function OrganizationMembersPage({
  params,
}: {
  params: { orgId: string };
}) {
  const { userId } = await auth();
  
  if (!userId) {
    redirect("/sign-in");
  }
  
  // Get organization details
  const org = await clerkClient().organizations.getOrganization({
    organizationId: params.orgId,
  });
  
  if (!org) {
    redirect("/organization/select");
  }
  
  // Get auth context
  const authContext = await getAuthContextWithOrg();
  
  // Check if user can manage members
  const canManageMembers = await hasOrganizationRole("admin") || 
                           await hasOrganizationRole("moderator");
  
  // Get all members
  const memberships = await clerkClient().organizations.getOrganizationMembershipList({
    organizationId: params.orgId,
    limit: 100,
  });
  
  // Format members for display
  const members = memberships.data.map(membership => ({
    id: membership.id,
    userId: membership.publicUserData?.userId || "",
    firstName: membership.publicUserData?.firstName || "",
    lastName: membership.publicUserData?.lastName || "",
    email: membership.publicUserData?.email || "",
    role: membership.role,
    imageUrl: membership.publicUserData?.imageUrl,
  }));
  
  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Members</h1>
          <p className="text-gray-600">
            Manage your organization members and their roles
          </p>
        </div>
        <div className="text-sm text-gray-500">
          Total: {members.length} members
        </div>
      </div>
      
      {/* Invite Form - Only for admins/moderators */}
      {canManageMembers && (
        <div className="bg-white rounded-lg shadow-sm p-6">
          <h2 className="text-lg font-semibold text-gray-900 mb-4">
            Invite New Member
          </h2>
          <InviteMemberForm orgId={params.orgId} />
        </div>
      )}
      
      {/* Member List */}
      <div className="bg-white rounded-lg shadow-sm p-6">
        <h2 className="text-lg font-semibold text-gray-900 mb-4">
          Current Members
        </h2>
        <MemberList
          members={members}
          orgId={params.orgId}
          canManage={canManageMembers}
          currentUserId={userId}
        />
      </div>
    </div>
  );
}
```

---

## Step 12: Create Invite Member Form Component

**File:** `app/components/InviteMemberForm.tsx`

```tsx
// app/components/InviteMemberForm.tsx
// Invite member form component

"use client";

import { useState } from "react";
import { useUser } from "@clerk/nextjs";
import { inviteUserToOrganization } from "@/lib/org-helpers";

interface InviteMemberFormProps {
  orgId: string;
}

export default function InviteMemberForm({ orgId }: InviteMemberFormProps) {
  const { user } = useUser();
  const [loading, setLoading] = useState(false);
  const [success, setSuccess] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);
  
  const [formData, setFormData] = useState({
    email: "",
    role: "member" as "admin" | "moderator" | "member" | "guest",
  });
  
  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setSuccess(null);
    setError(null);
    
    try {
      await inviteUserToOrganization(
        orgId,
        formData.email,
        formData.role,
        user?.id || ""
      );
      
      setSuccess(`Invitation sent to ${formData.email}`);
      setFormData({
        email: "",
        role: "member",
      });
    } catch (error) {
      setError("Failed to send invitation. Please try again.");
    } finally {
      setLoading(false);
    }
  };
  
  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      {success && (
        <div className="p-3 bg-green-100 text-green-700 rounded">
          {success}
        </div>
      )}
      
      {error && (
        <div className="p-3 bg-red-100 text-red-700 rounded">
          {error}
        </div>
      )}
      
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        <div className="md:col-span-2">
          <label htmlFor="email" className="block text-sm font-medium text-gray-700">
            Email Address
          </label>
          <input
            type="email"
            id="email"
            value={formData.email}
            onChange={(e) => setFormData({ ...formData, email: e.target.value })}
            required
            placeholder="colleague@company.com"
            className="mt-1 block w-full border border-gray-300 rounded-md shadow-sm px-3 py-2 focus:ring-indigo-500 focus:border-indigo-500"
          />
        </div>
        
        <div>
          <label htmlFor="role" className="block text-sm font-medium text-gray-700">
            Role
          </label>
          <select
            id="role"
            value={formData.role}
            onChange={(e) => setFormData({
              ...formData,
              role: e.target.value as typeof formData.role,
            })}
            className="mt-1 block w-full border border-gray-300 rounded-md shadow-sm px-3 py-2 focus:ring-indigo-500 focus:border-indigo-500"
          >
            <option value="guest">Guest</option>
            <option value="member">Member</option>
            <option value="moderator">Moderator</option>
            <option value="admin">Admin</option>
          </select>
        </div>
      </div>
      
      <button
        type="submit"
        disabled={loading}
        className="bg-indigo-600 text-white px-4 py-2 rounded-md hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
      >
        {loading ? "Sending..." : "Send Invitation"}
      </button>
    </form>
  );
}
```

---

## Step 13: Create Member List Component

**File:** `app/components/MemberList.tsx`

```tsx
// app/components/MemberList.tsx
// Member list component with role management

"use client";

import { useState } from "react";
import { updateMemberRole, removeMemberFromOrganization } from "@/lib/org-helpers";

interface Member {
  id: string;
  userId: string;
  firstName: string;
  lastName: string;
  email: string;
  role: string;
  imageUrl?: string;
}

interface MemberListProps {
  members: Member[];
  orgId: string;
  canManage: boolean;
  currentUserId: string;
}

export default function MemberList({
  members,
  orgId,
  canManage,
  currentUserId,
}: MemberListProps) {
  const [localMembers, setLocalMembers] = useState(members);
  const [loading, setLoading] = useState<string | null>(null);
  const [message, setMessage] = useState<{
    userId: string;
    type: "success" | "error";
    text: string;
  } | null>(null);
  
  const handleRoleChange = async (userId: string, newRole: string) => {
    if (!canManage) return;
    
    setLoading(userId);
    setMessage(null);
    
    try {
      await updateMemberRole(orgId, userId, newRole as any);
      
      setLocalMembers(prev =>
        prev.map(member =>
          member.userId === userId
            ? { ...member, role: newRole }
            : member
        )
      );
      
      setMessage({
        userId,
        type: "success",
        text: "Role updated successfully",
      });
    } catch (error) {
      setMessage({
        userId,
        type: "error",
        text: "Failed to update role",
      });
    } finally {
      setLoading(null);
    }
  };
  
  const handleRemoveMember = async (userId: string, memberName: string) => {
    if (!canManage) return;
    
    if (!confirm(`Are you sure you want to remove ${memberName} from the organization?`)) {
      return;
    }
    
    setLoading(userId);
    setMessage(null);
    
    try {
      await removeMemberFromOrganization(orgId, userId);
      
      setLocalMembers(prev =>
        prev.filter(member => member.userId !== userId)
      );
      
      setMessage({
        userId,
        type: "success",
        text: "Member removed successfully",
      });
    } catch (error) {
      setMessage({
        userId,
        type: "error",
        text: "Failed to remove member",
      });
    } finally {
      setLoading(null);
    }
  };
  
  return (
    <div className="overflow-x-auto">
      {localMembers.length === 0 ? (
        <p className="text-gray-500 text-center py-8">No members found</p>
      ) : (
        <table className="min-w-full divide-y divide-gray-200">
          <thead className="bg-gray-50">
            <tr>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Member
              </th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Email
              </th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Role
              </th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Actions
              </th>
            </tr>
          </thead>
          <tbody className="bg-white divide-y divide-gray-200">
            {localMembers.map((member) => {
              const isCurrentUser = member.userId === currentUserId;
              const showMessage = message?.userId === member.userId;
              
              return (
                <tr key={member.id}>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="flex items-center">
                      {member.imageUrl ? (
                        <img
                          src={member.imageUrl}
                          alt={member.firstName}
                          className="h-8 w-8 rounded-full"
                        />
                      ) : (
                        <div className="h-8 w-8 rounded-full bg-indigo-100 flex items-center justify-center">
                          <span className="text-indigo-600 font-medium text-sm">
                            {member.firstName.charAt(0).toUpperCase()}
                          </span>
                        </div>
                      )}
                      <div className="ml-3">
                        <div className="text-sm font-medium text-gray-900">
                          {member.firstName} {member.lastName}
                          {isCurrentUser && (
                            <span className="ml-2 text-xs text-gray-500">(You)</span>
                          )}
                        </div>
                      </div>
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    {member.email}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    {canManage && !isCurrentUser ? (
                      <select
                        value={member.role}
                        onChange={(e) => handleRoleChange(member.userId, e.target.value)}
                        disabled={loading === member.userId}
                        className="text-sm border border-gray-300 rounded-md px-2 py-1 focus:ring-indigo-500 focus:border-indigo-500 disabled:opacity-50"
                      >
                        <option value="guest">Guest</option>
                        <option value="member">Member</option>
                        <option value="moderator">Moderator</option>
                        <option value="admin">Admin</option>
                      </select>
                    ) : (
                      <span className="text-sm text-gray-900 capitalize">
                        {member.role}
                        {isCurrentUser && (
                          <span className="ml-2 text-xs text-gray-400">(you)</span>
                        )}
                      </span>
                    )}
                    {loading === member.userId && (
                      <span className="ml-2 text-xs text-gray-500">Updating...</span>
                    )}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                    {canManage && !isCurrentUser && (
                      <button
                        onClick={() => handleRemoveMember(member.userId, `${member.firstName} ${member.lastName}`)}
                        disabled={loading === member.userId}
                        className="text-red-600 hover:text-red-900 disabled:opacity-50 disabled:cursor-not-allowed"
                      >
                        Remove
                      </button>
                    )}
                    {showMessage && (
                      <span className={`ml-2 text-xs ${
                        message.type === "success" ? "text-green-600" : "text-red-600"
                      }`}>
                        {message.text}
                      </span>
                    )}
                  </td>
                </tr>
              );
            })}
          </tbody>
        </table>
      )}
    </div>
  );
}
```

---

## What We've Accomplished

Let's recap everything you've built in Part 3:

### ✅ Completed Tasks

1. **Enabled Organizations in Clerk Dashboard**
2. **Created custom roles:** Admin, Moderator, Member, Guest
3. **Updated auth helpers** with organization support
4. **Created organization helpers** for CRUD operations
5. **Updated permissions** with organization-level permissions
6. **Enhanced middleware** with organization protection
7. **Built organization selection page** for users with multiple orgs
8. **Built organization creation page**
9. **Created organization layout** with switcher
10. **Built organization dashboard**
11. **Created member management** with invitation and role management
12. **Built reusable components:** MemberList, InviteMemberForm

### 🎯 Key Skills Acquired

- Understanding multi-tenancy architecture patterns
- Implementing Clerk Organizations for B2B applications
- Managing organization memberships and roles
- Building organization switcher UI components
- Implementing role-based access control at the organization level
- Filtering queries by organization ID
- Managing invitations and member lifecycles
- Designing scalable permission hierarchies

---

## Verification Checklist

- [ ] Organizations enabled in Clerk Dashboard
- [ ] Custom roles created (admin, moderator, member, guest)
- [ ] Can create a new organization
- [ ] Organization appears in selection page
- [ ] Can switch between organizations
- [ ] Organization dashboard shows correct data
- [ ] Can invite new members via email
- [ ] Invitation email is sent (check spam folder)
- [ ] Can accept invitations
- [ ] Member list displays all members
- [ ] Can update member roles (if admin)
- [ ] Can remove members (if admin)
- [ ] Organization permissions restrict access
- [ ] API endpoints respect organization isolation
- [ ] Database queries filter by orgId

---

## What's Coming in Part 4

Now that you've mastered multi-tenant SaaS architecture, Part 4 will dive deep into **Extending Clerk with Metadata, Webhooks, and Custom Authentication**. You'll learn:

- Understanding Clerk metadata: Public, Private, and Unsafe Metadata
- Storing application-specific user preferences on the user object
- Synchronizing Clerk user events with relational databases
- Configuring, testing, and securing Clerk Webhooks
- Verifying webhook signatures cryptographically
- Building completely headless authentication interfaces
- Managing user sessions programmatically
- Monitoring authentication telemetry and audit logs

**Ready to extend Clerk with custom data and webhooks?** Proceed to Part 4!
