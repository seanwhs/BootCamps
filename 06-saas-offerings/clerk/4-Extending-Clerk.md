# Part 4: Extending Clerk

## Metadata, Webhooks, Custom Authentication, and User Lifecycle Management

**Welcome to Part 4!** Now that you've mastered multi-tenant SaaS architecture, it's time to deeply integrate Clerk into your application's internal business logic. In this module, you'll learn how to synchronize Clerk with your own database, store application-specific data, build headless authentication interfaces, and manage user lifecycles through secure webhooks.

---

## What You'll Learn in Part 4

By the end of this part, you'll be able to:

- Understand Clerk metadata boundaries: Public Metadata, Private Metadata, and Unsafe Metadata
- Store and mutate application-specific user preferences directly on the user object
- Synchronize Clerk user events with relational databases (PostgreSQL using Prisma)
- Configure, test, and secure Clerk Webhooks for user lifecycle events
- Verify webhook signatures cryptographically to ensure payload integrity
- Build completely headless, custom authentication interfaces using Clerk's low-level SDKs
- Manage user sessions programmatically
- Monitor authentication telemetry and audit logs
- Build a fully synchronized, webhook-driven authentication system backed by your own database

---

## Deep Dive: Clerk Metadata System

### Understanding Metadata Types

Clerk provides three types of metadata for storing application-specific data:

| Metadata Type | Accessibility | Use Case | Example |
|---------------|---------------|----------|---------|
| **Public Metadata** | Readable by anyone | User preferences, public profile data | `{ "theme": "dark", "bio": "Software Engineer" }` |
| **Private Metadata** | Only server-side | Sensitive application data | `{ "stripe_customer_id": "cus_123", "internal_notes": "VIP user" }` |
| **Unsafe Metadata** | Readable by anyone, writable by client | Temporary, non-critical data | `{ "last_action": "viewed_dashboard", "ui_state": "collapsed" }` |

**Metadata Flow Diagram:**

```
┌─────────────────────────────────────────────────────────────┐
│                    Clerk User Object                        │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Public Metadata                                   │   │
│  │  ┌─────────────────────────────────────────────┐  │   │
│  │  │  {                                         │  │   │
│  │  │    "theme": "dark",                       │  │   │
│  │  │    "bio": "Software Engineer",            │  │   │
│  │  │    "preferences": {                      │  │   │
│  │  │      "notifications": true              │  │   │
│  │  │    }                                     │  │   │
│  │  │  }                                        │  │   │
│  │  └─────────────────────────────────────────────┘  │   │
│  │                                                   │   │
│  │  Readable: ✅ Client-side, ✅ Server-side        │   │
│  │  Writable: ✅ Server-side only                  │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Private Metadata                                  │   │
│  │  ┌─────────────────────────────────────────────┐  │   │
│  │  │  {                                         │  │   │
│  │  │    "stripe_customer_id": "cus_123",       │  │   │
│  │  │    "internal_notes": "Premium user",     │  │   │
│  │  │    "last_ip": "192.168.1.1"              │  │   │
│  │  │  }                                        │  │   │
│  │  └─────────────────────────────────────────────┘  │   │
│  │                                                   │   │
│  │  Readable: ❌ Client-side, ✅ Server-side        │   │
│  │  Writable: ✅ Server-side only                  │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Unsafe Metadata                                   │   │
│  │  ┌─────────────────────────────────────────────┐  │   │
│  │  │  {                                         │  │   │
│  │  │    "last_action": "viewed_dashboard",     │  │   │
│  │  │    "ui_state": "collapsed"               │  │   │
│  │  │  }                                        │  │   │
│  │  └─────────────────────────────────────────────┘  │   │
│  │                                                   │   │
│  │  Readable: ✅ Client-side, ✅ Server-side        │   │
│  │  Writable: ✅ Client-side, ✅ Server-side        │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

### When to Use Each Metadata Type

**Public Metadata:**
- User display preferences (theme, language)
- Public profile information (bio, location)
- User settings that other users might see
- Feature flags visible to the user

**Private Metadata:**
- Payment provider IDs
- Internal user ratings or notes
- Security-related data (last IP, device fingerprints)
- Integration IDs (CRM, marketing tools)

**Unsafe Metadata:**
- Temporary UI state
- Analytics tracking data
- Non-critical session data
- Cached client-side values

---

## Setting Up the Project for Part 4

We'll build on the code from Parts 1-3 and add database integration.

### Project Structure for Part 4

```
part-4-metadata-webhooks/
├── app/
│   ├── (auth)/
│   │   ├── dashboard/
│   │   │   └── page.tsx          # Dashboard with database integration
│   │   ├── profile/
│   │   │   ├── page.tsx          # Profile with preferences
│   │   │   └── settings/
│   │   │       └── page.tsx      # User settings with metadata
│   │   └── layout.tsx
│   ├── api/
│   │   ├── webhooks/
│   │   │   └── clerk/
│   │   │       └── route.ts      # Clerk webhook endpoint
│   │   └── metadata/
│   │       └── route.ts          # User metadata management
│   ├── components/
│   │   ├── PreferencesForm.tsx
│   │   ├── UserSyncStatus.tsx
│   │   └── HeadlessSignIn.tsx
│   ├── lib/
│   │   ├── db.ts                 # Prisma client singleton
│   │   ├── sync.ts               # User sync utilities
│   │   └── webhook-verify.ts     # Webhook signature verification
│   └── layout.tsx
├── prisma/
│   ├── schema.prisma             # Database schema
│   └── migrations/               # Database migrations
├── middleware.ts
├── .env.local
└── package.json
```

---

## Step 1: Install and Configure Prisma

We'll use Prisma as our ORM for database integration.

### 1.1 Install Prisma Dependencies

```bash
# Install Prisma
npm install @prisma/client
npm install -D prisma

# Initialize Prisma
npx prisma init
```

### 1.2 Configure Database Schema

**File:** `prisma/schema.prisma`

```prisma
// prisma/schema.prisma
// Database schema for Clerk integration

generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

// User model - synchronized with Clerk
model User {
  id            String   @id @default(cuid())
  clerkId       String   @unique @map("clerk_id")
  email         String   @unique
  name          String?
  username      String?  @unique
  avatarUrl     String?  @map("avatar_url")
  role          String   @default("guest")
  
  // Metadata synchronization
  publicMetadata  Json?    @map("public_metadata")
  privateMetadata Json?    @map("private_metadata")
  
  // Application-specific fields
  preferences    Json?    @default("{}")
  bio            String?
  location       String?
  website        String?
  company        String?
  title          String?
  
  // Organization support
  organizationId String?  @map("organization_id")
  organizationRole String? @map("organization_role")
  
  // Sync tracking
  syncedAt       DateTime @default(now()) @map("synced_at")
  lastSignInAt   DateTime? @map("last_sign_in_at")
  createdAt      DateTime @default(now()) @map("created_at")
  updatedAt      DateTime @updatedAt @map("updated_at")
  
  // Relations
  projects       Project[]
  auditLogs      AuditLog[]
  sessions       Session[]
  
  @@map("users")
  @@index([clerkId])
  @@index([email])
  @@index([organizationId])
}

// Project model - tenant-isolated
model Project {
  id             String   @id @default(cuid())
  name           String
  description    String?
  status         String   @default("active")
  
  // Organization isolation
  organizationId String   @map("organization_id")
  organization   User?    @relation(fields: [organizationId], references: [id])
  
  // Owner tracking
  ownerId        String   @map("owner_id")
  owner          User?    @relation(fields: [ownerId], references: [id])
  
  // Metadata
  metadata       Json?    @default("{}")
  createdAt      DateTime @default(now()) @map("created_at")
  updatedAt      DateTime @updatedAt @map("updated_at")
  
  @@map("projects")
  @@index([organizationId])
  @@index([ownerId])
}

// Audit log for tracking auth events
model AuditLog {
  id             String   @id @default(cuid())
  userId         String?  @map("user_id")
  user           User?    @relation(fields: [userId], references: [id])
  
  event          String   // user.created, user.updated, user.deleted, etc.
  ipAddress      String?  @map("ip_address")
  userAgent      String?  @map("user_agent")
  metadata       Json?    @default("{}")
  
  createdAt      DateTime @default(now()) @map("created_at")
  
  @@map("audit_logs")
  @@index([userId])
  @@index([event])
  @@index([createdAt])
}

// Session tracking
model Session {
  id             String   @id @default(cuid())
  clerkSessionId String   @unique @map("clerk_session_id")
  userId         String   @map("user_id")
  user           User?    @relation(fields: [userId], references: [id])
  
  ipAddress      String?  @map("ip_address")
  userAgent      String?  @map("user_agent")
  deviceInfo     Json?    @map("device_info")
  
  expiresAt      DateTime @map("expires_at")
  createdAt      DateTime @default(now()) @map("created_at")
  updatedAt      DateTime @updatedAt @map("updated_at")
  
  @@map("sessions")
  @@index([userId])
  @@index([expiresAt])
}
```

### 1.3 Create Database Migration

```bash
# Create and apply migration
npx prisma migrate dev --name init_clerk_integration

# Generate Prisma client
npx prisma generate
```

### 1.4 Set Up Prisma Client Singleton

**File:** `lib/db.ts`

```tsx
// lib/db.ts
// Prisma client singleton for efficient connection management

import { PrismaClient } from "@prisma/client";

// PrismaClient is attached to the `global` object in development to prevent
// exhausting your database connection limit.
//
// Learn more:
// https://pris.ly/d/help/next-js-best-practices

const globalForPrisma = global as unknown as { prisma: PrismaClient };

export const prisma =
  globalForPrisma.prisma ||
  new PrismaClient({
    log: process.env.NODE_ENV === "development" ? ["query", "error", "warn"] : ["error"],
  });

if (process.env.NODE_ENV !== "production") globalForPrisma.prisma = prisma;

export default prisma;
```

---

## Step 2: Create User Synchronization Utilities

**File:** `lib/sync.ts`

```tsx
// lib/sync.ts
// User synchronization utilities for Clerk ↔ Database sync

import prisma from "@/lib/db";
import { User } from "@clerk/nextjs/server";
import { logAuthEvent } from "@/lib/auth-helpers";

/**
 * Synchronize a Clerk user with the database
 * Creates or updates the user record
 * 
 * @param clerkUser - The Clerk user object
 * @param organizationId - Optional organization ID
 * @param organizationRole - Optional organization role
 * @returns The synced user
 */
export async function syncUserWithDatabase(
  clerkUser: User,
  organizationId?: string,
  organizationRole?: string
) {
  try {
    // Extract user data from Clerk
    const email = clerkUser.emailAddresses[0]?.emailAddress || "";
    const name = clerkUser.fullName || clerkUser.username || email;
    const username = clerkUser.username || undefined;
    const avatarUrl = clerkUser.imageUrl || undefined;
    
    // Extract metadata
    const publicMetadata = clerkUser.publicMetadata || {};
    const privateMetadata = clerkUser.privateMetadata || {};
    
    // Find or create user in database
    const user = await prisma.user.upsert({
      where: {
        clerkId: clerkUser.id,
      },
      update: {
        email,
        name,
        username,
        avatarUrl,
        role: (publicMetadata.role as string) || "guest",
        publicMetadata: publicMetadata as any,
        privateMetadata: privateMetadata as any,
        lastSignInAt: clerkUser.lastSignInAt ? new Date(clerkUser.lastSignInAt) : undefined,
        syncedAt: new Date(),
        // Organization fields
        ...(organizationId && { organizationId }),
        ...(organizationRole && { organizationRole }),
      },
      create: {
        clerkId: clerkUser.id,
        email,
        name,
        username,
        avatarUrl,
        role: (publicMetadata.role as string) || "guest",
        publicMetadata: publicMetadata as any,
        privateMetadata: privateMetadata as any,
        lastSignInAt: clerkUser.lastSignInAt ? new Date(clerkUser.lastSignInAt) : undefined,
        syncedAt: new Date(),
        ...(organizationId && { organizationId }),
        ...(organizationRole && { organizationRole }),
      },
    });
    
    // Log the sync event
    await logAuthEvent(clerkUser.id, "user_synced", {
      email,
      name,
      organizationId: organizationId || "none",
    });
    
    return user;
  } catch (error) {
    console.error("Failed to sync user with database:", error);
    throw new Error("Database synchronization failed");
  }
}

/**
 * Get a user from the database by Clerk ID
 * 
 * @param clerkId - The Clerk user ID
 * @returns The user or null
 */
export async function getUserByClerkId(clerkId: string) {
  try {
    return await prisma.user.findUnique({
      where: { clerkId },
      include: {
        projects: true,
        sessions: true,
      },
    });
  } catch (error) {
    console.error("Failed to get user:", error);
    return null;
  }
}

/**
 * Delete a user from the database (soft delete or hard delete)
 * 
 * @param clerkId - The Clerk user ID
 * @param hardDelete - If true, permanently delete the user
 */
export async function deleteUserFromDatabase(clerkId: string, hardDelete: boolean = false) {
  try {
    if (hardDelete) {
      // Hard delete - remove all related records
      await prisma.$transaction([
        prisma.auditLog.deleteMany({ where: { userId: clerkId } }),
        prisma.session.deleteMany({ where: { userId: clerkId } }),
        prisma.project.deleteMany({ where: { ownerId: clerkId } }),
        prisma.user.delete({ where: { clerkId } }),
      ]);
    } else {
      // Soft delete - just mark as deleted in metadata
      await prisma.user.update({
        where: { clerkId },
        data: {
          publicMetadata: {
            deletedAt: new Date().toISOString(),
          } as any,
        },
      });
    }
  } catch (error) {
    console.error("Failed to delete user:", error);
    throw new Error("Failed to delete user");
  }
}

/**
 * Update user preferences in the database
 * 
 * @param clerkId - The Clerk user ID
 * @param preferences - User preferences object
 * @returns Updated user
 */
export async function updateUserPreferences(
  clerkId: string,
  preferences: Record<string, unknown>
) {
  try {
    return await prisma.user.update({
      where: { clerkId },
      data: {
        preferences: preferences as any,
      },
    });
  } catch (error) {
    console.error("Failed to update user preferences:", error);
    throw new Error("Failed to update preferences");
  }
}

/**
 * Update user profile in the database
 * 
 * @param clerkId - The Clerk user ID
 * @param data - Profile data to update
 * @returns Updated user
 */
export async function updateUserProfile(
  clerkId: string,
  data: {
    name?: string;
    username?: string;
    bio?: string;
    location?: string;
    website?: string;
    company?: string;
    title?: string;
  }
) {
  try {
    return await prisma.user.update({
      where: { clerkId },
      data,
    });
  } catch (error) {
    console.error("Failed to update user profile:", error);
    throw new Error("Failed to update profile");
  }
}
```

---

## Step 3: Implement Webhook Signature Verification

Webhooks must be verified to ensure they come from Clerk and haven't been tampered with.

**File:** `lib/webhook-verify.ts`

```tsx
// lib/webhook-verify.ts
// Webhook signature verification for Clerk webhooks

import { Webhook } from "svix";
import { NextRequest } from "next/server";

// Clerk webhook headers
const WEBHOOK_HEADERS = {
  SIGNATURE: "svix-signature",
  TIMESTAMP: "svix-timestamp",
  ID: "svix-id",
} as const;

/**
 * Verify a Clerk webhook request
 * 
 * @param request - The incoming request
 * @param secret - The webhook secret from Clerk Dashboard
 * @returns The verified payload
 * @throws {Error} If verification fails
 */
export async function verifyWebhookRequest(
  request: NextRequest,
  secret: string
): Promise<unknown> {
  // Get the raw body as text
  const payload = await request.text();
  
  // Get the headers
  const headers = {
    [WEBHOOK_HEADERS.SIGNATURE]: request.headers.get(WEBHOOK_HEADERS.SIGNATURE) || "",
    [WEBHOOK_HEADERS.TIMESTAMP]: request.headers.get(WEBHOOK_HEADERS.TIMESTAMP) || "",
    [WEBHOOK_HEADERS.ID]: request.headers.get(WEBHOOK_HEADERS.ID) || "",
  };
  
  // Validate required headers
  if (!headers[WEBHOOK_HEADERS.SIGNATURE] || !headers[WEBHOOK_HEADERS.TIMESTAMP]) {
    throw new Error("Missing required webhook headers");
  }
  
  try {
    // Create webhook instance
    const wh = new Webhook(secret);
    
    // Verify the payload
    const verifiedPayload = wh.verify(payload, headers);
    
    return verifiedPayload;
  } catch (error) {
    console.error("Webhook verification failed:", error);
    throw new Error("Webhook verification failed");
  }
}

/**
 * Extract webhook event type and data
 * 
 * @param payload - The verified webhook payload
 * @returns Event type and data
 */
export function parseWebhookEvent(payload: unknown) {
  if (!payload || typeof payload !== "object") {
    throw new Error("Invalid webhook payload");
  }
  
  const typedPayload = payload as {
    type: string;
    data: unknown;
    object: string;
    timestamp: number;
  };
  
  return {
    type: typedPayload.type,
    data: typedPayload.data,
  };
}

/**
 * Get the webhook secret from environment
 * 
 * @returns The webhook secret
 * @throws {Error} If secret is not configured
 */
export function getWebhookSecret(): string {
  const secret = process.env.CLERK_WEBHOOK_SECRET;
  
  if (!secret) {
    throw new Error("CLERK_WEBHOOK_SECRET is not configured");
  }
  
  return secret;
}
```

**File:** `.env.local` (add webhook secret)

```env
# .env.local - Add webhook configuration

# Clerk Webhook Secret (from Clerk Dashboard)
CLERK_WEBHOOK_SECRET=whsec_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

# Database URL
DATABASE_URL="postgresql://postgres:password@localhost:5432/clerk_mastery_part4"
```

---

## Step 4: Create Webhook Endpoint

**File:** `app/api/webhooks/clerk/route.ts`

```tsx
// app/api/webhooks/clerk/route.ts
// Clerk webhook endpoint - handles user lifecycle events

import { NextRequest, NextResponse } from "next/server";
import { verifyWebhookRequest, parseWebhookEvent, getWebhookSecret } from "@/lib/webhook-verify";
import { syncUserWithDatabase, deleteUserFromDatabase, updateUserPreferences } from "@/lib/sync";
import prisma from "@/lib/db";
import { logAuthEvent } from "@/lib/auth-helpers";

// Webhook event types
type WebhookEventType = 
  | "user.created"
  | "user.updated"
  | "user.deleted"
  | "user.organization.created"
  | "user.organization.updated"
  | "user.organization.deleted"
  | "session.created"
  | "session.ended"
  | "session.removed"
  | "email.created"
  | "email.updated"
  | "phone.created"
  | "phone.updated";

// Rate limiting for webhooks (in production, use Redis or similar)
const processedEvents = new Map<string, number>();

/**
 * POST handler for Clerk webhooks
 * 
 * @param request - The incoming request
 * @returns Response indicating success
 */
export async function POST(request: NextRequest) {
  try {
    // Get webhook secret
    const secret = getWebhookSecret();
    
    // Verify the request
    const verifiedPayload = await verifyWebhookRequest(request, secret);
    
    // Parse event type and data
    const { type, data } = parseWebhookEvent(verifiedPayload);
    
    // Deduplicate events (in production, use Redis or similar)
    const eventId = request.headers.get("svix-id") || "";
    if (processedEvents.has(eventId)) {
      return NextResponse.json({ message: "Event already processed" }, { status: 200 });
    }
    
    // Process different event types
    await processWebhookEvent(type as WebhookEventType, data);
    
    // Store processed event ID
    processedEvents.set(eventId, Date.now());
    
    // Clean old entries (keep last 1000)
    if (processedEvents.size > 1000) {
      const entries = Array.from(processedEvents.entries());
      const sorted = entries.sort((a, b) => a[1] - b[1]);
      const toDelete = sorted.slice(0, sorted.length - 1000);
      toDelete.forEach(([key]) => processedEvents.delete(key));
    }
    
    return NextResponse.json({ success: true }, { status: 200 });
    
  } catch (error) {
    console.error("Webhook processing error:", error);
    
    // Return 500 for errors, Clerk will retry
    return NextResponse.json(
      { error: "Webhook processing failed" },
      { status: 500 }
    );
  }
}

/**
 * Process a webhook event
 * 
 * @param type - The event type
 * @param data - The event data
 */
async function processWebhookEvent(type: WebhookEventType, data: any) {
  switch (type) {
    case "user.created":
      await handleUserCreated(data);
      break;
      
    case "user.updated":
      await handleUserUpdated(data);
      break;
      
    case "user.deleted":
      await handleUserDeleted(data);
      break;
      
    case "user.organization.created":
      await handleOrganizationCreated(data);
      break;
      
    case "user.organization.updated":
      await handleOrganizationUpdated(data);
      break;
      
    case "user.organization.deleted":
      await handleOrganizationDeleted(data);
      break;
      
    case "session.created":
      await handleSessionCreated(data);
      break;
      
    case "session.ended":
    case "session.removed":
      await handleSessionEnded(data);
      break;
      
    default:
      console.log(`Unhandled webhook event: ${type}`);
  }
}

/**
 * Handle user.created event
 */
async function handleUserCreated(data: any) {
  const user = data;
  
  // Log the event
  console.log(`User created: ${user.id} - ${user.email_addresses[0]?.email_address}`);
  
  // Sync user to database
  await syncUserWithDatabase(user);
  
  // Create audit log
  await prisma.auditLog.create({
    data: {
      userId: user.id,
      event: "user.created",
      metadata: {
        email: user.email_addresses[0]?.email_address,
        name: user.full_name,
        created_at: new Date().toISOString(),
      },
    },
  });
  
  // Log to auth system
  await logAuthEvent(user.id, "user_created", {
    email: user.email_addresses[0]?.email_address,
  });
}

/**
 * Handle user.updated event
 */
async function handleUserUpdated(data: any) {
  const user = data;
  
  console.log(`User updated: ${user.id}`);
  
  // Sync user to database
  await syncUserWithDatabase(user);
  
  // Create audit log
  await prisma.auditLog.create({
    data: {
      userId: user.id,
      event: "user.updated",
      metadata: {
        email: user.email_addresses[0]?.email_address,
        updated_at: new Date().toISOString(),
      },
    },
  });
  
  await logAuthEvent(user.id, "user_updated", {
    email: user.email_addresses[0]?.email_address,
  });
}

/**
 * Handle user.deleted event
 */
async function handleUserDeleted(data: any) {
  const user = data;
  
  console.log(`User deleted: ${user.id}`);
  
  // Delete from database (hard delete)
  await deleteUserFromDatabase(user.id, true);
  
  // Create audit log
  await prisma.auditLog.create({
    data: {
      userId: user.id,
      event: "user.deleted",
      metadata: {
        email: user.email_addresses[0]?.email_address,
        deleted_at: new Date().toISOString(),
      },
    },
  });
  
  await logAuthEvent(user.id, "user_deleted", {
    email: user.email_addresses[0]?.email_address,
  });
}

/**
 * Handle user.organization.created event
 */
async function handleOrganizationCreated(data: any) {
  const { user, organization, membership } = data;
  
  console.log(`User ${user.id} created organization: ${organization.name}`);
  
  // Sync user with organization context
  await syncUserWithDatabase(user, organization.id, membership.role);
  
  // Create audit log
  await prisma.auditLog.create({
    data: {
      userId: user.id,
      event: "organization.created",
      metadata: {
        organizationId: organization.id,
        organizationName: organization.name,
        role: membership.role,
      },
    },
  });
}

/**
 * Handle user.organization.updated event
 */
async function handleOrganizationUpdated(data: any) {
  const { user, organization, membership } = data;
  
  console.log(`User ${user.id} updated organization: ${organization.name}`);
  
  // Update organization fields
  await prisma.user.update({
    where: { clerkId: user.id },
    data: {
      organizationId: organization.id,
      organizationRole: membership.role,
    },
  });
  
  // Create audit log
  await prisma.auditLog.create({
    data: {
      userId: user.id,
      event: "organization.updated",
      metadata: {
        organizationId: organization.id,
        role: membership.role,
      },
    },
  });
}

/**
 * Handle user.organization.deleted event
 */
async function handleOrganizationDeleted(data: any) {
  const { user, organization } = data;
  
  console.log(`User ${user.id} removed from organization: ${organization.id}`);
  
  // Clear organization fields
  await prisma.user.update({
    where: { clerkId: user.id },
    data: {
      organizationId: null,
      organizationRole: null,
    },
  });
  
  // Create audit log
  await prisma.auditLog.create({
    data: {
      userId: user.id,
      event: "organization.deleted",
      metadata: {
        organizationId: organization.id,
      },
    },
  });
}

/**
 * Handle session.created event
 */
async function handleSessionCreated(data: any) {
  const { session, user } = data;
  
  console.log(`Session created for user: ${user.id}`);
  
  // Record session in database
  await prisma.session.create({
    data: {
      clerkSessionId: session.id,
      userId: user.id,
      ipAddress: session.last_active_ip || null,
      userAgent: session.user_agent || null,
      deviceInfo: {
        browser: session.browser,
        device: session.device,
      },
      expiresAt: new Date(session.expires_at),
    },
  });
  
  // Update last sign-in
  await prisma.user.update({
    where: { clerkId: user.id },
    data: {
      lastSignInAt: new Date(),
    },
  });
  
  // Create audit log
  await prisma.auditLog.create({
    data: {
      userId: user.id,
      event: "session.created",
      metadata: {
        sessionId: session.id,
        ipAddress: session.last_active_ip,
        userAgent: session.user_agent,
      },
    },
  });
}

/**
 * Handle session.ended event
 */
async function handleSessionEnded(data: any) {
  const { session, user } = data;
  
  console.log(`Session ended for user: ${user.id}`);
  
  // Mark session as ended in database (soft delete or update)
  await prisma.session.updateMany({
    where: { clerkSessionId: session.id },
    data: {
      expiresAt: new Date(), // Expire immediately
    },
  });
  
  // Create audit log
  await prisma.auditLog.create({
    data: {
      userId: user.id,
      event: "session.ended",
      metadata: {
        sessionId: session.id,
        endedAt: new Date().toISOString(),
      },
    },
  });
}
```

---

## Step 5: Configure Webhooks in Clerk Dashboard

### 5.1 Get Webhook Secret

1. Go to the [Clerk Dashboard](https://dashboard.clerk.com)
2. Select your application
3. Navigate to **"Webhooks"** in the left sidebar
4. Click **"Add Endpoint"**
5. Configure the endpoint:
   - **Endpoint URL:** `https://your-app.com/api/webhooks/clerk` (use `http://localhost:3000/api/webhooks/clerk` for development)
   - **Event Types:** Select all user-related events:
     - ✅ `user.created`
     - ✅ `user.updated`
     - ✅ `user.deleted`
     - ✅ `user.organization.created`
     - ✅ `user.organization.updated`
     - ✅ `user.organization.deleted`
     - ✅ `session.created`
     - ✅ `session.ended`
     - ✅ `session.removed`
6. Click **"Create"**
7. Copy the **"Signing Secret"** (starts with `whsec_`)
8. Add it to your `.env.local` as `CLERK_WEBHOOK_SECRET`

### 5.2 Test Webhooks in Development

For local development, use a tool like [ngrok](https://ngrok.com) or [localhost.run](https://localhost.run) to expose your local server:

```bash
# Install ngrok
npm install -g ngrok

# Expose your local server
ngrok http 3000

# Copy the ngrok URL (e.g., https://abc123.ngrok.io)
# Add this URL to your Clerk webhook endpoint in the dashboard
```

---

## Step 6: Build Custom Metadata Management

**File:** `app/api/metadata/route.ts`

```tsx
// app/api/metadata/route.ts
// API endpoints for managing user metadata

import { NextRequest, NextResponse } from "next/server";
import { auth, clerkClient } from "@clerk/nextjs/server";
import prisma from "@/lib/db";
import { getEnhancedCurrentUser } from "@/lib/auth-helpers";

/**
 * GET /api/metadata - Get user metadata
 */
export async function GET(request: NextRequest) {
  try {
    const { userId } = await auth();
    
    if (!userId) {
      return NextResponse.json(
        { error: "Authentication required" },
        { status: 401 }
      );
    }
    
    // Get user from Clerk
    const clerkUser = await clerkClient().users.getUser(userId);
    
    if (!clerkUser) {
      return NextResponse.json(
        { error: "User not found" },
        { status: 404 }
      );
    }
    
    // Get user from database
    const dbUser = await prisma.user.findUnique({
      where: { clerkId: userId },
      select: {
        preferences: true,
        publicMetadata: true,
        privateMetadata: true,
        bio: true,
        location: true,
        website: true,
        company: true,
        title: true,
        role: true,
      },
    });
    
    return NextResponse.json({
      clerk: {
        publicMetadata: clerkUser.publicMetadata,
        privateMetadata: clerkUser.privateMetadata,
        unsafeMetadata: clerkUser.unsafeMetadata,
      },
      database: dbUser || null,
    });
    
  } catch (error) {
    console.error("Error getting metadata:", error);
    return NextResponse.json(
      { error: "Failed to get metadata" },
      { status: 500 }
    );
  }
}

/**
 * PUT /api/metadata - Update user metadata
 */
export async function PUT(request: NextRequest) {
  try {
    const { userId } = await auth();
    
    if (!userId) {
      return NextResponse.json(
        { error: "Authentication required" },
        { status: 401 }
      );
    }
    
    const body = await request.json();
    
    // Validate request
    const { metadataType, data } = body;
    
    if (!metadataType || !data) {
      return NextResponse.json(
        { error: "Missing required fields: metadataType, data" },
        { status: 400 }
      );
    }
    
    // Update Clerk metadata
    let updatedUser;
    
    switch (metadataType) {
      case "public":
        updatedUser = await clerkClient().users.updateUser(userId, {
          publicMetadata: data,
        });
        break;
        
      case "private":
        updatedUser = await clerkClient().users.updateUser(userId, {
          privateMetadata: data,
        });
        break;
        
      case "unsafe":
        updatedUser = await clerkClient().users.updateUser(userId, {
          unsafeMetadata: data,
        });
        break;
        
      case "preferences":
        // Update preferences in database
        await prisma.user.update({
          where: { clerkId: userId },
          data: {
            preferences: data,
          },
        });
        
        // Also update in Clerk public metadata
        const clerkUser = await clerkClient().users.getUser(userId);
        updatedUser = await clerkClient().users.updateUser(userId, {
          publicMetadata: {
            ...clerkUser.publicMetadata,
            preferences: data,
          },
        });
        break;
        
      case "profile":
        // Update profile in database
        await prisma.user.update({
          where: { clerkId: userId },
          data: {
            bio: data.bio,
            location: data.location,
            website: data.website,
            company: data.company,
            title: data.title,
          },
        });
        
        // Also update in Clerk public metadata
        const userForProfile = await clerkClient().users.getUser(userId);
        updatedUser = await clerkClient().users.updateUser(userId, {
          publicMetadata: {
            ...userForProfile.publicMetadata,
            profile: {
              bio: data.bio,
              location: data.location,
              website: data.website,
              company: data.company,
              title: data.title,
            },
          },
        });
        break;
        
      default:
        return NextResponse.json(
          { error: `Invalid metadataType: ${metadataType}` },
          { status: 400 }
        );
    }
    
    // Sync user with database
    const dbUser = await prisma.user.update({
      where: { clerkId: userId },
      data: {
        syncedAt: new Date(),
      },
    });
    
    return NextResponse.json({
      success: true,
      message: "Metadata updated successfully",
      metadataType,
      updatedUser: {
        id: updatedUser.id,
        publicMetadata: updatedUser.publicMetadata,
        privateMetadata: updatedUser.privateMetadata,
        unsafeMetadata: updatedUser.unsafeMetadata,
      },
      databaseUser: dbUser,
    });
    
  } catch (error) {
    console.error("Error updating metadata:", error);
    return NextResponse.json(
      { error: "Failed to update metadata" },
      { status: 500 }
    );
  }
}
```

---

## Step 7: Build User Preferences Component

**File:** `app/components/PreferencesForm.tsx`

```tsx
// app/components/PreferencesForm.tsx
// User preferences form component

"use client";

import { useState, useEffect } from "react";

interface Preferences {
  theme: "light" | "dark" | "system";
  notifications: {
    email: boolean;
    push: boolean;
    inApp: boolean;
  };
  language: string;
  timezone: string;
  dateFormat: string;
}

interface PreferencesFormProps {
  initialPreferences: Partial<Preferences>;
  userId: string;
}

export default function PreferencesForm({
  initialPreferences,
  userId,
}: PreferencesFormProps) {
  const [preferences, setPreferences] = useState<Preferences>({
    theme: "system",
    notifications: {
      email: true,
      push: true,
      inApp: true,
    },
    language: "en",
    timezone: "UTC",
    dateFormat: "MM/DD/YYYY",
    ...initialPreferences,
  });
  
  const [loading, setLoading] = useState(false);
  const [message, setMessage] = useState<{
    type: "success" | "error";
    text: string;
  } | null>(null);
  
  const handleChange = (field: string, value: any) => {
    setPreferences(prev => ({
      ...prev,
      [field]: value,
    }));
  };
  
  const handleNotificationChange = (type: string, value: boolean) => {
    setPreferences(prev => ({
      ...prev,
      notifications: {
        ...prev.notifications,
        [type]: value,
      },
    }));
  };
  
  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setMessage(null);
    
    try {
      const response = await fetch("/api/metadata", {
        method: "PUT",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          metadataType: "preferences",
          data: preferences,
        }),
      });
      
      if (!response.ok) {
        throw new Error("Failed to update preferences");
      }
      
      setMessage({
        type: "success",
        text: "Preferences updated successfully!",
      });
      
      // Reload after short delay to show updated data
      setTimeout(() => {
        window.location.reload();
      }, 1500);
      
    } catch (error) {
      setMessage({
        type: "error",
        text: "Failed to update preferences. Please try again.",
      });
    } finally {
      setLoading(false);
    }
  };
  
  return (
    <form onSubmit={handleSubmit} className="space-y-6">
      {message && (
        <div className={`p-3 rounded ${
          message.type === "success" 
            ? "bg-green-100 text-green-700" 
            : "bg-red-100 text-red-700"
        }`}>
          {message.text}
        </div>
      )}
      
      {/* Theme Selection */}
      <div>
        <label className="block text-sm font-medium text-gray-700 mb-2">
          Theme
        </label>
        <div className="grid grid-cols-3 gap-2">
          {["light", "dark", "system"].map((theme) => (
            <button
              key={theme}
              type="button"
              onClick={() => handleChange("theme", theme)}
              className={`px-4 py-2 rounded-md capitalize ${
                preferences.theme === theme
                  ? "bg-indigo-600 text-white"
                  : "bg-gray-100 text-gray-700 hover:bg-gray-200"
              }`}
            >
              {theme}
            </button>
          ))}
        </div>
      </div>
      
      {/* Notifications */}
      <div>
        <label className="block text-sm font-medium text-gray-700 mb-2">
          Notifications
        </label>
        <div className="space-y-2">
          {[
            { key: "email", label: "Email Notifications" },
            { key: "push", label: "Push Notifications" },
            { key: "inApp", label: "In-App Notifications" },
          ].map(({ key, label }) => (
            <label key={key} className="flex items-center space-x-2">
              <input
                type="checkbox"
                checked={preferences.notifications[key as keyof typeof preferences.notifications]}
                onChange={(e) => handleNotificationChange(key, e.target.checked)}
                className="w-4 h-4 text-indigo-600 border-gray-300 rounded focus:ring-indigo-500"
              />
              <span className="text-sm text-gray-700">{label}</span>
            </label>
          ))}
        </div>
      </div>
      
      {/* Language */}
      <div>
        <label htmlFor="language" className="block text-sm font-medium text-gray-700">
          Language
        </label>
        <select
          id="language"
          value={preferences.language}
          onChange={(e) => handleChange("language", e.target.value)}
          className="mt-1 block w-full border border-gray-300 rounded-md shadow-sm px-3 py-2 focus:ring-indigo-500 focus:border-indigo-500"
        >
          <option value="en">English</option>
          <option value="es">Spanish</option>
          <option value="fr">French</option>
          <option value="de">German</option>
          <option value="ja">Japanese</option>
        </select>
      </div>
      
      {/* Timezone */}
      <div>
        <label htmlFor="timezone" className="block text-sm font-medium text-gray-700">
          Timezone
        </label>
        <select
          id="timezone"
          value={preferences.timezone}
          onChange={(e) => handleChange("timezone", e.target.value)}
          className="mt-1 block w-full border border-gray-300 rounded-md shadow-sm px-3 py-2 focus:ring-indigo-500 focus:border-indigo-500"
        >
          <option value="UTC">UTC</option>
          <option value="America/New_York">Eastern Time (ET)</option>
          <option value="America/Chicago">Central Time (CT)</option>
          <option value="America/Denver">Mountain Time (MT)</option>
          <option value="America/Los_Angeles">Pacific Time (PT)</option>
          <option value="Europe/London">London (GMT)</option>
          <option value="Europe/Paris">Paris (CET)</option>
          <option value="Asia/Tokyo">Tokyo (JST)</option>
        </select>
      </div>
      
      {/* Date Format */}
      <div>
        <label htmlFor="dateFormat" className="block text-sm font-medium text-gray-700">
          Date Format
        </label>
        <select
          id="dateFormat"
          value={preferences.dateFormat}
          onChange={(e) => handleChange("dateFormat", e.target.value)}
          className="mt-1 block w-full border border-gray-300 rounded-md shadow-sm px-3 py-2 focus:ring-indigo-500 focus:border-indigo-500"
        >
          <option value="MM/DD/YYYY">MM/DD/YYYY</option>
          <option value="DD/MM/YYYY">DD/MM/YYYY</option>
          <option value="YYYY-MM-DD">YYYY-MM-DD</option>
          <option value="MMMM DD, YYYY">MMMM DD, YYYY</option>
        </select>
      </div>
      
      {/* Submit Button */}
      <button
        type="submit"
        disabled={loading}
        className="w-full bg-indigo-600 text-white px-4 py-2 rounded-md hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
      >
        {loading ? "Saving..." : "Save Preferences"}
      </button>
    </form>
  );
}
```

---

## Step 8: Build Headless Authentication Flow

For applications that need complete control over the authentication UI, Clerk provides low-level SDKs.

**File:** `app/components/HeadlessSignIn.tsx`

```tsx
// app/components/HeadlessSignIn.tsx
// Headless authentication component using Clerk's low-level APIs

"use client";

import { useState } from "react";
import { useSignIn, useSignUp } from "@clerk/nextjs";
import { useRouter } from "next/navigation";

export default function HeadlessSignIn() {
  const { isLoaded: signInLoaded, signIn, setActive } = useSignIn();
  const { isLoaded: signUpLoaded, signUp } = useSignUp();
  const router = useRouter();
  
  const [mode, setMode] = useState<"signin" | "signup">("signin");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);
  const [verifying, setVerifying] = useState(false);
  const [verificationCode, setVerificationCode] = useState("");
  const [pendingVerification, setPendingVerification] = useState(false);
  
  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);
    setLoading(true);
    
    try {
      if (mode === "signin") {
        // Sign In flow
        if (!signInLoaded) return;
        
        const signInAttempt = await signIn.create({
          identifier: email,
          password,
        });
        
        if (signInAttempt.status === "complete") {
          // Successful sign in
          await setActive({ session: signInAttempt.createdSessionId });
          router.push("/dashboard");
        } else if (signInAttempt.status === "needs_second_factor") {
          // Handle 2FA (if enabled)
          setError("Two-factor authentication required");
        } else {
          setError("Sign in failed. Please check your credentials.");
        }
        
      } else {
        // Sign Up flow
        if (!signUpLoaded) return;
        
        if (password !== confirmPassword) {
          setError("Passwords do not match");
          setLoading(false);
          return;
        }
        
        const signUpAttempt = await signUp.create({
          emailAddress: email,
          password,
        });
        
        if (signUpAttempt.status === "complete") {
          // Successful sign up
          await setActive({ session: signUpAttempt.createdSessionId });
          router.push("/dashboard");
        } else if (signUpAttempt.status === "needs_verification") {
          // Email verification required
          setPendingVerification(true);
          setError("Please check your email for verification code");
        } else {
          setError("Sign up failed. Please try again.");
        }
      }
    } catch (err: any) {
      console.error("Authentication error:", err);
      setError(err.message || "Authentication failed. Please try again.");
    } finally {
      setLoading(false);
    }
  };
  
  const handleVerify = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);
    setLoading(true);
    
    try {
      if (!signUpLoaded) return;
      
      const verificationAttempt = await signUp.attemptEmailAddressVerification({
        code: verificationCode,
      });
      
      if (verificationAttempt.status === "complete") {
        await setActive({ session: verificationAttempt.createdSessionId });
        router.push("/dashboard");
      } else {
        setError("Verification failed. Please check your code.");
      }
    } catch (err: any) {
      console.error("Verification error:", err);
      setError(err.message || "Verification failed. Please try again.");
    } finally {
      setLoading(false);
    }
  };
  
  // If verification is pending, show verification form
  if (pendingVerification) {
    return (
      <div className="max-w-md mx-auto p-6 bg-white rounded-lg shadow-sm">
        <h2 className="text-2xl font-bold text-gray-900 mb-6">
          Verify Your Email
        </h2>
        <p className="text-gray-600 mb-4">
          Enter the verification code sent to your email address.
        </p>
        <form onSubmit={handleVerify} className="space-y-4">
          <div>
            <label htmlFor="verificationCode" className="block text-sm font-medium text-gray-700">
              Verification Code
            </label>
            <input
              type="text"
              id="verificationCode"
              value={verificationCode}
              onChange={(e) => setVerificationCode(e.target.value)}
              placeholder="Enter 6-digit code"
              required
              className="mt-1 block w-full border border-gray-300 rounded-md shadow-sm px-3 py-2 focus:ring-indigo-500 focus:border-indigo-500"
            />
          </div>
          
          {error && (
            <div className="p-3 bg-red-100 text-red-700 rounded">
              {error}
            </div>
          )}
          
          <button
            type="submit"
            disabled={loading}
            className="w-full bg-indigo-600 text-white px-4 py-2 rounded-md hover:bg-indigo-700 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {loading ? "Verifying..." : "Verify Email"}
          </button>
        </form>
      </div>
    );
  }
  
  return (
    <div className="max-w-md mx-auto p-6 bg-white rounded-lg shadow-sm">
      <div className="text-center mb-6">
        <h2 className="text-2xl font-bold text-gray-900">
          {mode === "signin" ? "Sign In" : "Create Account"}
        </h2>
        <p className="text-gray-600 text-sm mt-1">
          {mode === "signin"
            ? "Welcome back! Sign in to your account"
            : "Join us and get started with your account"}
        </p>
      </div>
      
      {/* Mode Toggle */}
      <div className="flex rounded-md shadow-sm mb-6">
        <button
          type="button"
          onClick={() => setMode("signin")}
          className={`flex-1 px-4 py-2 text-sm font-medium rounded-l-md ${
            mode === "signin"
              ? "bg-indigo-600 text-white"
              : "bg-gray-100 text-gray-700 hover:bg-gray-200"
          }`}
        >
          Sign In
        </button>
        <button
          type="button"
          onClick={() => setMode("signup")}
          className={`flex-1 px-4 py-2 text-sm font-medium rounded-r-md ${
            mode === "signup"
              ? "bg-indigo-600 text-white"
              : "bg-gray-100 text-gray-700 hover:bg-gray-200"
          }`}
        >
          Sign Up
        </button>
      </div>
      
      <form onSubmit={handleSubmit} className="space-y-4">
        {/* Email */}
        <div>
          <label htmlFor="email" className="block text-sm font-medium text-gray-700">
            Email Address
          </label>
          <input
            type="email"
            id="email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            placeholder="you@example.com"
            required
            className="mt-1 block w-full border border-gray-300 rounded-md shadow-sm px-3 py-2 focus:ring-indigo-500 focus:border-indigo-500"
          />
        </div>
        
        {/* Password */}
        <div>
          <label htmlFor="password" className="block text-sm font-medium text-gray-700">
            Password
          </label>
          <input
            type="password"
            id="password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            placeholder="••••••••"
            required
            className="mt-1 block w-full border border-gray-300 rounded-md shadow-sm px-3 py-2 focus:ring-indigo-500 focus:border-indigo-500"
          />
          {mode === "signup" && (
            <p className="mt-1 text-xs text-gray-500">
              Password must be at least 8 characters
            </p>
          )}
        </div>
        
        {/* Confirm Password (signup only) */}
        {mode === "signup" && (
          <div>
            <label htmlFor="confirmPassword" className="block text-sm font-medium text-gray-700">
              Confirm Password
            </label>
            <input
              type="password"
              id="confirmPassword"
              value={confirmPassword}
              onChange={(e) => setConfirmPassword(e.target.value)}
              placeholder="••••••••"
              required
              className="mt-1 block w-full border border-gray-300 rounded-md shadow-sm px-3 py-2 focus:ring-indigo-500 focus:border-indigo-500"
            />
          </div>
        )}
        
        {/* Error Message */}
        {error && (
          <div className="p-3 bg-red-100 text-red-700 rounded">
            {error}
          </div>
        )}
        
        {/* Submit Button */}
        <button
          type="submit"
          disabled={loading}
          className="w-full bg-indigo-600 text-white px-4 py-2 rounded-md hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
        >
          {loading ? "Loading..." : mode === "signin" ? "Sign In" : "Create Account"}
        </button>
      </form>
      
      {/* Alternative auth methods */}
      <div className="mt-6">
        <div className="relative">
          <div className="absolute inset-0 flex items-center">
            <div className="w-full border-t border-gray-300"></div>
          </div>
          <div className="relative flex justify-center text-sm">
            <span className="px-2 bg-white text-gray-500">Or continue with</span>
          </div>
        </div>
        
        <div className="mt-4 grid grid-cols-2 gap-2">
          <button
            type="button"
            onClick={() => {
              // Redirect to Clerk's OAuth flow
              window.location.href = "/sign-in?strategy=google";
            }}
            className="flex items-center justify-center px-4 py-2 border border-gray-300 rounded-md shadow-sm text-sm font-medium text-gray-700 bg-white hover:bg-gray-50"
          >
            <svg className="w-5 h-5 mr-2" viewBox="0 0 24 24">
              <path
                fill="#4285F4"
                d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"
              />
              <path
                fill="#34A853"
                d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"
              />
              <path
                fill="#FBBC05"
                d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z"
              />
              <path
                fill="#EA4335"
                d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"
              />
            </svg>
            Google
          </button>
          
          <button
            type="button"
            onClick={() => {
              window.location.href = "/sign-in?strategy=github";
            }}
            className="flex items-center justify-center px-4 py-2 border border-gray-300 rounded-md shadow-sm text-sm font-medium text-gray-700 bg-white hover:bg-gray-50"
          >
            <svg className="w-5 h-5 mr-2" fill="currentColor" viewBox="0 0 24 24">
              <path d="M12 0C5.37 0 0 5.37 0 12c0 5.31 3.435 9.795 8.205 11.385.6.105.825-.255.825-.57 0-.285-.015-1.23-.015-2.235-3.015.555-3.795-.735-4.035-1.41-.135-.345-.72-1.41-1.23-1.695-.42-.225-1.02-.78-.015-.795.945-.015 1.62.87 1.845 1.23 1.08 1.815 2.805 1.305 3.495.99.105-.78.42-1.305.765-1.605-2.67-.3-5.46-1.335-5.46-5.925 0-1.305.465-2.385 1.23-3.225-.12-.3-.54-1.53.12-3.15 0 0 1.005-.315 3.3 1.23.96-.27 1.98-.405 3-.405s2.04.135 3 .405c2.295-1.56 3.3-1.23 3.3-1.23.66 1.62.24 2.85.12 3.15.765.84 1.23 1.905 1.23 3.225 0 4.605-2.805 5.625-5.475 5.925.435.375.81 1.095.81 2.22 0 1.605-.015 2.895-.015 3.3 0 .315.225.69.825.57A12.02 12.02 0 0024 12c0-6.63-5.37-12-12-12z"/>
            </svg>
            GitHub
          </button>
        </div>
      </div>
    </div>
  );
}
```

---

## Step 9: Create a Profile Page with Metadata Management

**File:** `app/profile/settings/page.tsx`

```tsx
// app/profile/settings/page.tsx
// User settings page with metadata management

import { auth, currentUser } from "@clerk/nextjs/server";
import { redirect } from "next/navigation";
import Link from "next/link";
import { UserButton } from "@clerk/nextjs";
import PreferencesForm from "@/app/components/PreferencesForm";
import prisma from "@/lib/db";

export default async function UserSettingsPage() {
  const { userId } = await auth();
  
  if (!userId) {
    redirect("/sign-in");
  }
  
  // Get Clerk user
  const clerkUser = await currentUser();
  
  if (!clerkUser) {
    redirect("/sign-in");
  }
  
  // Get user from database
  const dbUser = await prisma.user.findUnique({
    where: { clerkId: userId },
  });
  
  // Get preferences from database or use defaults
  const preferences = (dbUser?.preferences as any) || {
    theme: "system",
    notifications: {
      email: true,
      push: true,
      inApp: true,
    },
    language: "en",
    timezone: "UTC",
    dateFormat: "MM/DD/YYYY",
  };
  
  return (
    <div className="min-h-screen bg-gray-50">
      {/* Navigation */}
      <nav className="bg-white shadow-sm border-b border-gray-200">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center">
              <Link href="/" className="text-xl font-bold text-indigo-600">
                Clerk Mastery
              </Link>
              <span className="ml-3 text-sm text-gray-500">Settings</span>
            </div>
            
            <div className="flex items-center space-x-4">
              <Link 
                href="/profile" 
                className="text-gray-600 hover:text-indigo-600 transition-colors"
              >
                Profile
              </Link>
              <Link 
                href="/profile/settings" 
                className="text-indigo-600 font-medium"
              >
                Settings
              </Link>
              <UserButton afterSignOutUrl="/" />
            </div>
          </div>
        </div>
      </nav>
      
      {/* Main Content */}
      <main className="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
        <div className="bg-white rounded-lg shadow-sm p-6">
          <h1 className="text-2xl font-bold text-gray-900 mb-2">
            User Settings
          </h1>
          <p className="text-gray-600 mb-6">
            Manage your preferences and account settings
          </p>
          
          <PreferencesForm
            initialPreferences={preferences}
            userId={userId}
          />
        </div>
        
        {/* Metadata Info */}
        <div className="mt-6 bg-white rounded-lg shadow-sm p-6">
          <h2 className="text-lg font-semibold text-gray-900 mb-4">
            Metadata Information
          </h2>
          <div className="space-y-3 text-sm">
            <div>
              <p className="text-gray-500">Public Metadata</p>
              <pre className="mt-1 p-2 bg-gray-50 rounded text-xs overflow-auto">
                {JSON.stringify(clerkUser.publicMetadata, null, 2)}
              </pre>
            </div>
            <div>
              <p className="text-gray-500">Private Metadata</p>
              <pre className="mt-1 p-2 bg-gray-50 rounded text-xs overflow-auto">
                {JSON.stringify(clerkUser.privateMetadata, null, 2)}
              </pre>
            </div>
            <div>
              <p className="text-gray-500">Database User</p>
              <pre className="mt-1 p-2 bg-gray-50 rounded text-xs overflow-auto">
                {JSON.stringify(dbUser, null, 2)}
              </pre>
            </div>
          </div>
          <p className="mt-4 text-xs text-gray-400">
            ℹ️ Metadata is synchronized between Clerk and your database via webhooks.
            Changes made in Clerk Dashboard will automatically sync to your database.
          </p>
        </div>
      </main>
    </div>
  );
}
```

---

## What We've Accomplished

Let's recap everything you've built in Part 4:

### ✅ Completed Tasks

1. **Set up Prisma ORM** with PostgreSQL
2. **Created database schema** with User, Project, AuditLog, and Session models
3. **Implemented user synchronization** between Clerk and database
4. **Built webhook signature verification** using Svix
5. **Created webhook endpoint** handling all user lifecycle events
6. **Implemented event processing** for user.created, updated, deleted, session events
7. **Built metadata management API** for public, private, and unsafe metadata
8. **Created user preferences form** with theme, notifications, language, etc.
9. **Built headless authentication interface** with low-level Clerk SDKs
10. **Created settings page** with metadata management and sync status

### 🎯 Key Skills Acquired

- Understanding Clerk metadata types and use cases
- Synchronizing users between Clerk and your database
- Implementing secure webhook verification
- Processing user lifecycle events in real-time
- Building custom metadata management APIs
- Creating headless authentication flows
- Managing user sessions programmatically
- Setting up audit logging and monitoring

---

## Verification Checklist

- [ ] Prisma installed and configured
- [ ] Database schema created and migrated
- [ ] User sync utilities working
- [ ] Webhook endpoint accessible
- [ ] Webhook signature verification working
- [ ] Clerk webhook configured in dashboard
- [ ] User.created webhook creates user in database
- [ ] User.updated webhook updates user in database
- [ ] User.deleted webhook removes user from database
- [ ] Session.created webhook records session
- [ ] Session.ended webhook updates session
- [ ] Metadata API updates Clerk and database
- [ ] Preferences form saves correctly
- [ ] Headless authentication flow works
- [ ] Audit logs recording events
- [ ] Settings page displays metadata

---

## What's Coming in Part 5

Now that you've mastered metadata, webhooks, and custom authentication, Part 5 will dive deep into **Clerk with React 19 & Next.js 16**. You'll learn:

- Configuring Clerk natively for the Next.js App Router
- Mastering React Server Components (RSC) authentication patterns
- Safely leveraging asynchronous server helpers like `await auth()` inside Server Components
- Securing Next.js Server Actions using `auth.protect()`
- Building secure authenticated layouts and streaming authenticated content
- Managing React 19 concurrent rendering considerations
- Optimizing client/server hydration boundaries
- Advanced performance tuning and production deployment strategies

**Ready to build the ultimate full-stack application?** Proceed to Part 5!
