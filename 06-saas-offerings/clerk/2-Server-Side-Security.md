# Part 2: Server-Side Security

## Protecting APIs, Sessions, and Backend Resources

**Welcome to Part 2!** Now that you've mastered client-side authentication with Clerk, it's time to secure your backend services. In this module, you'll learn how to protect APIs, validate tokens, and enforce strict authorization boundaries across diverse server environments.

---

## What You'll Learn in Part 2

By the end of this part, you'll be able to:

- Understand how Clerk manages authentication tokens, cookies, and sessions behind the scenes
- Decode the mechanics of JSON Web Tokens (JWTs) and Clerk-issued session tokens
- Utilize core server helpers: `auth()`, `currentUser()`, `getAuth()`, and `verifyToken()`
- Protect endpoints across Next.js Route Handlers and Server Actions
- Build resilient, modular authentication middleware
- Extract critical authenticated user context: `userId`, `sessionId`, `orgId`
- Implement secure cookie handling and session renewal strategies
- Handle unauthorized (401) and forbidden (403) responses gracefully
- Apply the principle of least privilege in backend authorization rules
- Build a secure REST API with proper error handling and logging

---

## Deep Dive: Clerk's Server-Side Architecture

### The Journey of an Authenticated Request

Let's trace exactly what happens when a user makes an authenticated request to your server:

```
1. CLIENT REQUEST
   Browser has Clerk session cookie from previous authentication.
   Makes request to /api/users/profile
   Cookie: __session=eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9...
         │
         ▼
2. SERVER MIDDLEWARE (clerkMiddleware)
   Runs before route handler executes:
   a) Extracts session token from __session cookie
   b) Verifies token signature using Clerk's public key
   c) Checks token expiration (iat, exp claims)
   d) Validates token against Clerk's API (if needed)
   e) Decodes token payload into auth context
   f) Attaches auth data to request object
         │
         ▼
3. ROUTE HANDLER
   Executes with authenticated context available:
   - auth() returns { userId, sessionId, orgId, ... }
   - currentUser() fetches full user profile
   - Business logic executes with user context
         │
         ▼
4. RESPONSE
   Returns data to client with appropriate status codes:
   - 200 OK: Successful authenticated request
   - 401 Unauthorized: Missing or invalid token
   - 403 Forbidden: Authenticated but insufficient permissions
   - 404 Not Found: Resource doesn't exist
```

### Understanding Clerk's Session Token

Clerk issues JWTs (JSON Web Tokens) that contain all necessary authentication information. Let's decode one:

**Encoded JWT:**
```
eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJhenAiOiJodHRwczovL2FwaS5jbGVyay5jb20iLCJleHAiOjE3MDAwMDAwMDAsImlhdCI6MTcwMDAwMDAwMCwiaXNzIjoiaHR0cHM6Ly9hcGkuY2xlcmsuY29tIiwibmJmIjoxNzAwMDAwMDAwLCJzaWQiOiJzZXNzXzEyM2FiYyIsInN1YiI6InVzZXJfNDU2ZGVmIiwiYWN0IjoidXNlcl80NTZkZWYiLCJvcmciOiJvcmdfNzg5Z2hpIiwicm9sZXMiOlsiYWRtaW4iXSwicGVybWlzc2lvbnMiOlsicmVhZCIsIndyaXRlIl19.qwertyuiopasdfghjklzxcvbnm1234567890
```

**Decoded Payload:**
```json
{
  "azp": "https://api.clerk.com",
  "exp": 1700000000,          // Expiration timestamp (1 hour from issuance)
  "iat": 1700000000,          // Issued at timestamp
  "iss": "https://api.clerk.com",
  "nbf": 1700000000,
  "sid": "sess_123abc",       // Session ID
  "sub": "user_456def",       // User ID (subject)
  "act": "user_456def",       // Actor (who performed action)
  "org": "org_789ghi",        // Organization ID (if in active org)
  "roles": ["admin"],          // User roles
  "permissions": ["read", "write"] // Permissions
}
```

**Critical security properties:**
- **Signed with RS256:** Clerk signs with a private key; your server validates with a public key
- **HTTP-Only Cookie:** Prevents XSS attacks from accessing the token
- **Short Expiration:** Default 1-hour lifetime, requiring refresh
- **Self-Contained:** All identity data is in the token, no database lookup needed

---

## Setting Up the Project for Part 2

We'll build on the project from Part 1. If you haven't completed Part 1, you can clone the starter code.

### Project Structure for Part 2

```
part-2-server-side-security/
├── app/
│   ├── (auth)/
│   │   ├── dashboard/
│   │   │   └── page.tsx          # Protected dashboard (from Part 1)
│   │   ├── profile/
│   │   │   └── page.tsx          # User profile (from Part 1)
│   │   └── layout.tsx            # Auth layout
│   ├── api/
│   │   ├── auth/
│   │   │   ├── me/
│   │   │   │   └── route.ts      # GET /api/auth/me - Get current user
│   │   │   └── protected/
│   │   │       └── route.ts      # GET /api/auth/protected - Test protected endpoint
│   │   ├── users/
│   │   │   ├── route.ts          # GET /api/users - List all users (admin only)
│   │   │   └── [userId]/
│   │   │       └── route.ts      # GET /api/users/:id - Get specific user
│   │   └── admin/
│   │       └── route.ts          # GET /api/admin - Admin-only endpoint
│   ├── sign-in/
│   │   └── [[...sign-in]]/
│   │       └── page.tsx          # Sign-in page (from Part 1)
│   ├── sign-up/
│   │   └── [[...sign-up]]/
│   │       └── page.tsx          # Sign-up page (from Part 1)
│   ├── layout.tsx               # Root layout with ClerkProvider
│   └── page.tsx                 # Homepage
├── lib/
│   ├── auth-helpers.ts          # Custom authentication utilities
│   ├── middleware-helpers.ts    # Middleware helper functions
│   └── permissions.ts           # Permission definitions
├── middleware.ts               # Enhanced middleware with role checking
├── .env.local                  # Environment variables
├── next.config.js
├── package.json
└── tsconfig.json
```

### Step 1: Create the Custom Auth Helpers

Let's build a comprehensive set of authentication utilities that we'll use throughout our application.

**File:** `lib/auth-helpers.ts`

```tsx
// lib/auth-helpers.ts
// Custom authentication helper functions for server-side security
// These utilities extend Clerk's built-in functions with additional logic

import { auth, currentUser, clerkClient } from "@clerk/nextjs/server";
import { NextRequest, NextResponse } from "next/server";

// Type definitions for our custom helpers
export type AuthContext = {
  userId: string;
  sessionId: string;
  orgId: string | null;
  role: string | null;
  permissions: string[];
  isAuthenticated: boolean;
};

export type UserRole = "admin" | "moderator" | "user" | "guest";

/**
 * Get the current authentication context with type safety
 * This extends Clerk's auth() with additional context extraction
 * 
 * @returns AuthContext object with user details and role/permissions
 * @throws {Error} If user is not authenticated
 */
export async function getAuthContext(): Promise<AuthContext> {
  // Get the raw auth data from Clerk
  const { userId, sessionId, orgId } = await auth();
  
  // If no userId, user is not authenticated
  if (!userId) {
    throw new Error("User not authenticated");
  }

  // Fetch the full user to get metadata and role information
  const user = await currentUser();
  
  // Extract role from public metadata
  // Public metadata is stored on the user object and accessible server-side
  const role = user?.publicMetadata?.role as string || "guest";
  
  // Extract permissions from public metadata
  // In a production app, permissions would be derived from roles
  const permissions = user?.publicMetadata?.permissions as string[] || [];
  
  return {
    userId,
    sessionId: sessionId || "",
    orgId: orgId || null,
    role,
    permissions,
    isAuthenticated: true,
  };
}

/**
 * Check if the current user has a specific role
 * 
 * @param requiredRole - The role to check for
 * @returns boolean indicating if user has the role
 */
export async function hasRole(requiredRole: UserRole): Promise<boolean> {
  try {
    const { role } = await getAuthContext();
    return role === requiredRole;
  } catch (error) {
    return false;
  }
}

/**
 * Check if the current user has all required permissions
 * 
 * @param requiredPermissions - Array of permission strings to check
 * @returns boolean indicating if user has ALL required permissions
 */
export async function hasPermissions(requiredPermissions: string[]): Promise<boolean> {
  try {
    const { permissions } = await getAuthContext();
    // Check if user has ALL required permissions
    return requiredPermissions.every(permission => 
      permissions.includes(permission)
    );
  } catch (error) {
    return false;
  }
}

/**
 * Check if the current user has any of the required permissions
 * 
 * @param requiredPermissions - Array of permission strings to check
 * @returns boolean indicating if user has ANY required permission
 */
export async function hasAnyPermission(requiredPermissions: string[]): Promise<boolean> {
  try {
    const { permissions } = await getAuthContext();
    // Check if user has ANY of the required permissions
    return requiredPermissions.some(permission => 
      permissions.includes(permission)
    );
  } catch (error) {
    return false;
  }
}

/**
 * Middleware helper: Require authentication
 * Throws an error if user is not authenticated
 * 
 * @param request - NextRequest object
 * @param redirectTo - Optional redirect URL (defaults to /sign-in)
 * @returns AuthContext if authenticated
 * @throws {NextResponse} Redirect response if not authenticated
 */
export async function requireAuth(
  request: NextRequest,
  redirectTo: string = "/sign-in"
): Promise<AuthContext> {
  const { userId } = await auth();
  
  if (!userId) {
    // Return a redirect response instead of throwing
    const redirectResponse = NextResponse.redirect(new URL(redirectTo, request.url));
    // This signals to the caller that redirection is needed
    throw new Error("Authentication required");
  }
  
  return getAuthContext();
}

/**
 * Middleware helper: Require a specific role
 * 
 * @param requiredRole - The role required for access
 * @param request - NextRequest object
 * @param redirectTo - Optional redirect URL (defaults to /sign-in)
 * @returns AuthContext if user has required role
 * @throws {NextResponse} Redirect response if not authenticated or not authorized
 */
export async function requireRole(
  requiredRole: UserRole,
  request: NextRequest,
  redirectTo: string = "/sign-in"
): Promise<AuthContext> {
  const authContext = await requireAuth(request, redirectTo);
  
  if (authContext.role !== requiredRole) {
    // User is authenticated but doesn't have the required role
    // Return a 403 Forbidden response
    const forbiddenResponse = NextResponse.json(
      { error: "Insufficient permissions. Admin access required." },
      { status: 403 }
    );
    throw new Error("Insufficient permissions");
  }
  
  return authContext;
}

/**
 * Middleware helper: Require specific permissions
 * 
 * @param requiredPermissions - Array of permission strings required
 * @param request - NextRequest object
 * @param redirectTo - Optional redirect URL (defaults to /sign-in)
 * @returns AuthContext if user has required permissions
 * @throws {NextResponse} Redirect or 403 response if not authorized
 */
export async function requirePermissions(
  requiredPermissions: string[],
  request: NextRequest,
  redirectTo: string = "/sign-in"
): Promise<AuthContext> {
  const authContext = await requireAuth(request, redirectTo);
  
  const hasAllPermissions = requiredPermissions.every(permission =>
    authContext.permissions.includes(permission)
  );
  
  if (!hasAllPermissions) {
    // User doesn't have required permissions
    throw new NextResponse(
      JSON.stringify({ error: "Insufficient permissions" }),
      { status: 403, headers: { "Content-Type": "application/json" } }
    );
  }
  
  return authContext;
}

/**
 * Get the current user with additional application-specific data
 * This extends Clerk's currentUser() with metadata enrichment
 * 
 * @returns Extended user object with application data
 */
export async function getEnhancedCurrentUser() {
  const user = await currentUser();
  
  if (!user) {
    return null;
  }
  
  // Enhance user with application-specific properties
  return {
    ...user,
    // Extract commonly used metadata fields
    role: user.publicMetadata?.role as string || "guest",
    preferences: user.publicMetadata?.preferences as Record<string, unknown> || {},
    isVerified: user.emailAddresses.some(email => email.verification?.status === "verified"),
    primaryEmail: user.emailAddresses[0]?.emailAddress || "",
    displayName: user.fullName || user.username || user.emailAddresses[0]?.emailAddress || "User",
    // Add any other derived properties
  };
}

/**
 * Log authentication events for auditing
 * 
 * @param userId - The user ID
 * @param action - The action being performed
 * @param details - Additional details about the event
 */
export async function logAuthEvent(
  userId: string | null,
  action: string,
  details: Record<string, unknown>
): Promise<void> {
  // In a production app, this would send logs to a service like:
  // - Datadog
  // - Splunk
  // - AWS CloudWatch
  // - Custom database table
  console.log(`[AUTH EVENT] [${new Date().toISOString()}] User: ${userId || "anonymous"}`, {
    action,
    ...details,
    timestamp: new Date().toISOString(),
  });
  
  // For production, you'd want to use a proper logging library:
  // import { logger } from "@/lib/logger";
  // logger.info(`Auth event: ${action}`, { userId, details });
}
```

### Step 2: Set Up Middleware Helpers

Now let's create utilities specifically for middleware-based protection.

**File:** `lib/middleware-helpers.ts`

```tsx
// lib/middleware-helpers.ts
// Middleware-specific helper functions for route protection
// These utilities complement the middleware.ts file

import { auth } from "@clerk/nextjs/server";
import { NextRequest, NextResponse } from "next/server";

/**
 * Check if the current request is from an authenticated user
 * 
 * @param request - NextRequest object
 * @returns boolean indicating authentication status
 */
export async function isAuthenticated(request: NextRequest): Promise<boolean> {
  const { userId } = await auth();
  return !!userId;
}

/**
 * Get the user ID from the current request
 * 
 * @param request - NextRequest object
 * @returns userId or null if not authenticated
 */
export async function getUserId(request: NextRequest): Promise<string | null> {
  const { userId } = await auth();
  return userId || null;
}

/**
 * Create a pattern matcher for protecting routes
 * This extends Clerk's createRouteMatcher with additional functionality
 * 
 * @param patterns - Array of route patterns to match
 * @returns Function that tests if a path matches any pattern
 */
export function createRouteMatcher(patterns: string[]) {
  return (pathname: string): boolean => {
    // Convert glob patterns to regex
    const regexPatterns = patterns.map(pattern => {
      // Replace * with .* for regex
      const regexStr = pattern
        .replace(/[.*+?^${}()|[\]\\]/g, '\\$&') // Escape special characters
        .replace(/\\\*/g, '.*'); // Convert * to .*
      return new RegExp(`^${regexStr}$`);
    });
    
    return regexPatterns.some(regex => regex.test(pathname));
  };
}

/**
 * Middleware wrapper for API routes that adds CORS headers
 * 
 * @param handler - The route handler function
 * @returns Wrapped handler with CORS support
 */
export function withCors<T>(
  handler: (request: NextRequest) => Promise<T>
): (request: NextRequest) => Promise<NextResponse<T> | NextResponse> {
  return async (request: NextRequest) => {
    // Handle preflight OPTIONS request
    if (request.method === "OPTIONS") {
      return new NextResponse(null, {
        status: 200,
        headers: {
          "Access-Control-Allow-Origin": "*",
          "Access-Control-Allow-Methods": "GET, POST, PUT, DELETE, OPTIONS",
          "Access-Control-Allow-Headers": "Content-Type, Authorization",
          "Access-Control-Max-Age": "86400",
        },
      });
    }
    
    // Execute handler
    const response = await handler(request);
    
    // Add CORS headers to response
    if (response instanceof NextResponse) {
      response.headers.set("Access-Control-Allow-Origin", "*");
      return response;
    }
    
    // If handler returned a custom type, wrap it in NextResponse
    return NextResponse.json(response, {
      headers: {
        "Access-Control-Allow-Origin": "*",
      },
    });
  };
}

/**
 * Log middleware actions for debugging and monitoring
 * 
 * @param request - NextRequest object
 * @param action - The action being performed
 * @param result - The result of the action
 */
export function logMiddlewareAction(
  request: NextRequest,
  action: string,
  result: "allowed" | "blocked" | "redirected"
): void {
  const timestamp = new Date().toISOString();
  const path = request.nextUrl.pathname;
  const method = request.method;
  const ip = request.headers.get("x-forwarded-for") || request.headers.get("x-real-ip") || "unknown";
  
  console.log(`[MIDDLEWARE] ${timestamp} ${method} ${path}`, {
    action,
    result,
    ip,
    userAgent: request.headers.get("user-agent"),
    referer: request.headers.get("referer"),
  });
  
  // In production, send to your logging service
  // logger.info(`Middleware action: ${action}`, { path, method, result, ip });
}
```

### Step 3: Define Permissions

Let's create a centralized permission system.

**File:** `lib/permissions.ts`

```tsx
// lib/permissions.ts
// Centralized permission and role definitions
// This provides type-safe permission checking across the application

// Define all possible permissions in the system
export const PERMISSIONS = {
  // User management
  USER_READ: "user:read",
  USER_WRITE: "user:write",
  USER_DELETE: "user:delete",
  USER_LIST: "user:list",
  
  // Content management
  CONTENT_READ: "content:read",
  CONTENT_WRITE: "content:write",
  CONTENT_DELETE: "content:delete",
  CONTENT_PUBLISH: "content:publish",
  
  // Admin functions
  ADMIN_ACCESS: "admin:access",
  ADMIN_SETTINGS: "admin:settings",
  ADMIN_LOGS: "admin:logs",
  
  // Organization management (for Part 3)
  ORG_READ: "org:read",
  ORG_WRITE: "org:write",
  ORG_DELETE: "org:delete",
  ORG_MANAGE_MEMBERS: "org:members",
} as const;

// Type for permissions - derives from the keys above
export type Permission = typeof PERMISSIONS[keyof typeof PERMISSIONS];

// Define role-based permission sets
export const ROLE_PERMISSIONS = {
  // Guest users have minimal permissions
  guest: [
    PERMISSIONS.USER_READ,      // Can read own user data
    PERMISSIONS.CONTENT_READ,   // Can read public content
  ],
  
  // Regular authenticated users
  user: [
    PERMISSIONS.USER_READ,
    PERMISSIONS.USER_WRITE,     // Can update own user data
    PERMISSIONS.CONTENT_READ,
    PERMISSIONS.CONTENT_WRITE,  // Can create and edit content
  ],
  
  // Moderators have additional management permissions
  moderator: [
    PERMISSIONS.USER_READ,
    PERMISSIONS.USER_WRITE,
    PERMISSIONS.USER_LIST,       // Can list all users
    PERMISSIONS.CONTENT_READ,
    PERMISSIONS.CONTENT_WRITE,
    PERMISSIONS.CONTENT_DELETE,  // Can delete any content
    PERMISSIONS.CONTENT_PUBLISH, // Can publish content
  ],
  
  // Administrators have all permissions
  admin: Object.values(PERMISSIONS),
} as const;

// Define which routes require which permissions
export const ROUTE_PERMISSIONS = {
  // Admin routes
  "/api/admin": [PERMISSIONS.ADMIN_ACCESS],
  "/api/admin/settings": [PERMISSIONS.ADMIN_SETTINGS],
  "/api/admin/logs": [PERMISSIONS.ADMIN_LOGS],
  
  // User management routes
  "/api/users": [PERMISSIONS.USER_LIST],
  "/api/users/*": [PERMISSIONS.USER_READ],
  
  // Content routes
  "/api/content": [PERMISSIONS.CONTENT_READ],
  "/api/content/*": [PERMISSIONS.CONTENT_READ],
};

/**
 * Check if a user has a specific permission
 * 
 * @param userRole - The user's role
 * @param permission - The permission to check
 * @returns boolean indicating if the user has the permission
 */
export function hasPermission(userRole: string, permission: Permission): boolean {
  const userPermissions = ROLE_PERMISSIONS[userRole as keyof typeof ROLE_PERMISSIONS] || [];
  return userPermissions.includes(permission);
}

/**
 * Get all permissions for a user role
 * 
 * @param role - The user's role
 * @returns Array of permissions for that role
 */
export function getPermissionsForRole(role: string): Permission[] {
  return ROLE_PERMISSIONS[role as keyof typeof ROLE_PERMISSIONS] || [];
}

/**
 * Check if a user has permissions for a specific route
 * 
 * @param userRole - The user's role
 * @param path - The route path to check
 * @returns boolean indicating if the user can access the route
 */
export function canAccessRoute(userRole: string, path: string): boolean {
  // Find matching route permission
  for (const [routePattern, requiredPermissions] of Object.entries(ROUTE_PERMISSIONS)) {
    // Convert route pattern to regex
    const regexPattern = routePattern
      .replace(/[.*+?^${}()|[\]\\]/g, '\\$&')
      .replace(/\\\*/g, '.*');
    const regex = new RegExp(`^${regexPattern}$`);
    
    if (regex.test(path)) {
      // Check if user has all required permissions
      const userPermissions = getPermissionsForRole(userRole);
      return requiredPermissions.every(perm => userPermissions.includes(perm));
    }
  }
  
  // If no specific permission required, allow access
  return true;
}
```

### Step 4: Update Middleware with Enhanced Protection

Now let's enhance our middleware with role and permission checking.

**File:** `middleware.ts` (updated)

```tsx
// middleware.ts
// Enhanced middleware with role-based protection and permission checking
// This runs before every request to protect routes and APIs

import { clerkMiddleware, createRouteMatcher } from "@clerk/nextjs/server";
import { NextResponse } from "next/server";
import { canAccessRoute, getPermissionsForRole } from "@/lib/permissions";
import { logMiddlewareAction } from "@/lib/middleware-helpers";

// Define route patterns that require authentication
const isProtectedRoute = createRouteMatcher([
  "/dashboard(.*)",      // Dashboard and sub-routes
  "/profile(.*)",        // Profile pages
  "/settings(.*)",       // Settings pages
  "/api/auth/protected(.*)", // Protected API routes
  "/api/users(.*)",     // User management API
  "/api/admin(.*)",     // Admin API routes
]);

// Define route patterns that require specific roles
const isAdminRoute = createRouteMatcher([
  "/api/admin(.*)",      // Admin API routes
  "/admin(.*)",          // Admin pages
  "/api/users(.*)",     // User management (admin only)
]);

// Define route patterns that are API routes
const isApiRoute = createRouteMatcher([
  "/api/(.*)",
]);

// Export the Clerk middleware with enhanced protection
export default clerkMiddleware(async (auth, req) => {
  const path = req.nextUrl.pathname;
  const { userId, sessionId, orgId } = await auth();
  
  // Log the request for debugging
  logMiddlewareAction(req, "auth-check", userId ? "authenticated" : "unauthenticated");
  
  // Check if the route is protected
  if (isProtectedRoute(req)) {
    // If not authenticated, redirect to sign-in
    if (!userId) {
      logMiddlewareAction(req, "protection", "redirected");
      
      // For API routes, return 401 instead of redirect
      if (isApiRoute(req)) {
        return NextResponse.json(
          { error: "Authentication required" },
          { status: 401 }
        );
      }
      
      // For UI routes, redirect to sign-in
      return NextResponse.redirect(new URL("/sign-in", req.url));
    }
    
    // Check if the route requires admin access
    if (isAdminRoute(req)) {
      // Get user's role from public metadata
      // Note: In production, you'd cache this or get it from the session
      const user = await auth().userId; // We'll use a different approach
      
      // Since we can't easily get metadata in middleware without an extra API call,
      // we'll check the session claims for a role claim
      // For this example, we'll assume the role is stored in the session
      // In practice, you'd use Clerk's sessions API or check JWT claims
      
      // For demonstration, we'll check if the user has admin access
      // In a real app, you'd use a more robust method
      const hasAdminAccess = false; // Default to false for safety
      
      if (!hasAdminAccess) {
        logMiddlewareAction(req, "admin-protection", "blocked");
        
        // For API routes, return 403
        if (isApiRoute(req)) {
          return NextResponse.json(
            { error: "Admin access required" },
            { status: 403 }
          );
        }
        
        // For UI routes, redirect to dashboard with error message
        return NextResponse.redirect(new URL("/dashboard?error=access_denied", req.url));
      }
    }
    
    // If all checks pass, continue to the route
    logMiddlewareAction(req, "protection", "allowed");
    return NextResponse.next();
  }
  
  // If route is not protected, continue
  return NextResponse.next();
});

// Configuration: which paths the middleware should run on
export const config = {
  matcher: [
    // Skip Next.js internals and all static files
    "/((?!_next|[^?]*\\.(?:html?|css|js(?!on)|jpe?g|webp|png|gif|svg|ttf|woff2?|ico|csv|docx?|xlsx?|zip|webmanifest)).*)",
    // Always run for API routes
    "/(api|trpc)(.*)",
  ],
};
```

### Step 5: Build Protected API Routes

Now let's create the API endpoints that demonstrate server-side security.

**File:** `app/api/auth/me/route.ts`

```tsx
// app/api/auth/me/route.ts
// GET /api/auth/me - Get current authenticated user information
// This endpoint demonstrates basic authentication protection

import { NextRequest, NextResponse } from "next/server";
import { auth, currentUser } from "@clerk/nextjs/server";
import { getEnhancedCurrentUser, logAuthEvent } from "@/lib/auth-helpers";

/**
 * GET handler for /api/auth/me
 * Returns the current authenticated user's information
 * 
 * @param request - The incoming request
 * @returns User data or error response
 */
export async function GET(request: NextRequest) {
  try {
    // Check authentication using Clerk's auth helper
    const { userId, sessionId } = await auth();
    
    // If not authenticated, return 401
    if (!userId) {
      return NextResponse.json(
        { 
          error: "Not authenticated",
          message: "Please sign in to access this resource"
        },
        { status: 401 }
      );
    }
    
    // Get enhanced user data
    const user = await getEnhancedCurrentUser();
    
    if (!user) {
      return NextResponse.json(
        { error: "User not found" },
        { status: 404 }
      );
    }
    
    // Log the access for auditing
    await logAuthEvent(userId, "api_access", {
      endpoint: "/api/auth/me",
      method: "GET",
      sessionId,
    });
    
    // Return user data (exclude sensitive information)
    return NextResponse.json({
      id: user.id,
      email: user.primaryEmail,
      displayName: user.displayName,
      role: user.role,
      isVerified: user.isVerified,
      preferences: user.preferences,
      // Only include public metadata, not private
      publicMetadata: user.publicMetadata,
      // Include session info
      sessionId,
      // Include timestamps
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    });
    
  } catch (error) {
    console.error("Error in /api/auth/me:", error);
    return NextResponse.json(
      { error: "Internal server error" },
      { status: 500 }
    );
  }
}
```

**File:** `app/api/auth/protected/route.ts`

```tsx
// app/api/auth/protected/route.ts
// GET /api/auth/protected - Test endpoint for authentication protection
// This demonstrates the middleware protection in action

import { NextRequest, NextResponse } from "next/server";
import { auth } from "@clerk/nextjs/server";

/**
 * GET handler for /api/auth/protected
 * Returns success message if authenticated
 * 
 * @param request - The incoming request
 * @returns Success message or error
 */
export async function GET(request: NextRequest) {
  try {
    // This endpoint relies on middleware for authentication
    // But we still check again for defense in depth
    const { userId, sessionId, orgId } = await auth();
    
    if (!userId) {
      return NextResponse.json(
        { error: "Authentication required" },
        { status: 401 }
      );
    }
    
    // Return success with user context
    return NextResponse.json({
      success: true,
      message: "You have access to this protected endpoint",
      user: {
        userId,
        sessionId,
        orgId,
      },
      timestamp: new Date().toISOString(),
    });
    
  } catch (error) {
    console.error("Error in /api/auth/protected:", error);
    return NextResponse.json(
      { error: "Internal server error" },
      { status: 500 }
    );
  }
}

// POST handler for demonstration
export async function POST(request: NextRequest) {
  try {
    const { userId } = await auth();
    
    if (!userId) {
      return NextResponse.json(
        { error: "Authentication required" },
        { status: 401 }
      );
    }
    
    // Parse request body
    const body = await request.json();
    
    // Process the data (this is just a demonstration)
    return NextResponse.json({
      success: true,
      message: "Data processed successfully",
      received: body,
      userId,
      timestamp: new Date().toISOString(),
    });
    
  } catch (error) {
    console.error("Error in POST /api/auth/protected:", error);
    return NextResponse.json(
      { error: "Invalid request body" },
      { status: 400 }
    );
  }
}
```

**File:** `app/api/users/route.ts`

```tsx
// app/api/users/route.ts
// GET /api/users - List all users (admin only)
// Demonstrates role-based access control

import { NextRequest, NextResponse } from "next/server";
import { auth, clerkClient } from "@clerk/nextjs/server";
import { getEnhancedCurrentUser, logAuthEvent, requireRole } from "@/lib/auth-helpers";

/**
 * GET handler for /api/users
 * Returns a list of all users (requires admin role)
 * 
 * @param request - The incoming request
 * @returns List of users or error response
 */
export async function GET(request: NextRequest) {
  try {
    // Check authentication and role using our custom helper
    // This will throw if the user is not authenticated or not an admin
    const authContext = await requireRole("admin", request, "/sign-in");
    
    // Log the access
    await logAuthEvent(authContext.userId, "api_access", {
      endpoint: "/api/users",
      method: "GET",
      sessionId: authContext.sessionId,
      action: "list_all_users",
    });
    
    // Get all users from Clerk
    const users = await clerkClient().users.getUserList({
      // You can add pagination, filtering, etc.
      limit: 100, // Maximum users to return
      // orderBy: "-created_at", // Order by creation date descending
    });
    
    // Format user data for response (exclude sensitive info)
    const formattedUsers = users.map(user => ({
      id: user.id,
      email: user.emailAddresses[0]?.emailAddress || "",
      name: user.fullName || user.username || "Unknown",
      role: user.publicMetadata?.role || "guest",
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
      // Only include public metadata
      metadata: user.publicMetadata,
    }));
    
    return NextResponse.json({
      success: true,
      count: formattedUsers.length,
      users: formattedUsers,
      requestedBy: authContext.userId,
    });
    
  } catch (error: any) {
    // Check if it's a redirect or forbidden response from requireRole
    if (error.message === "Authentication required") {
      return NextResponse.json(
        { error: "Authentication required" },
        { status: 401 }
      );
    }
    
    if (error.message === "Insufficient permissions") {
      return NextResponse.json(
        { error: "Admin access required to list all users" },
        { status: 403 }
      );
    }
    
    console.error("Error in /api/users:", error);
    return NextResponse.json(
      { error: "Internal server error" },
      { status: 500 }
    );
  }
}
```

**File:** `app/api/users/[userId]/route.ts`

```tsx
// app/api/users/[userId]/route.ts
// GET /api/users/:id - Get a specific user by ID
// Demonstrates permission-based access control

import { NextRequest, NextResponse } from "next/server";
import { auth, clerkClient } from "@clerk/nextjs/server";
import { getAuthContext, logAuthEvent, hasPermission } from "@/lib/auth-helpers";
import { PERMISSIONS } from "@/lib/permissions";

/**
 * GET handler for /api/users/:id
 * Returns a specific user by ID
 * Users can only access their own data unless they have admin permissions
 * 
 * @param request - The incoming request
 * @param params - Route parameters containing userId
 * @returns User data or error response
 */
export async function GET(
  request: NextRequest,
  { params }: { params: { userId: string } }
) {
  try {
    // Get the requested user ID from the URL
    const requestedUserId = params.userId;
    
    // Get authentication context
    const authContext = await getAuthContext();
    
    // Check if the user is accessing their own data
    const isOwnData = authContext.userId === requestedUserId;
    
    // Check if the user has permission to read any user
    const canReadAnyUser = await hasPermission(authContext.userId, PERMISSIONS.USER_LIST);
    
    // If not their own data and not an admin, deny access
    if (!isOwnData && !canReadAnyUser) {
      await logAuthEvent(authContext.userId, "api_access_denied", {
        endpoint: `/api/users/${requestedUserId}`,
        method: "GET",
        reason: "Insufficient permissions",
      });
      
      return NextResponse.json(
        { error: "You don't have permission to view this user" },
        { status: 403 }
      );
    }
    
    // Fetch the user from Clerk
    const user = await clerkClient().users.getUser(requestedUserId);
    
    if (!user) {
      return NextResponse.json(
        { error: "User not found" },
        { status: 404 }
      );
    }
    
    // Log the access
    await logAuthEvent(authContext.userId, "api_access", {
      endpoint: `/api/users/${requestedUserId}`,
      method: "GET",
      targetUserId: requestedUserId,
    });
    
    // Format user data for response
    // If viewing own data, include more details
    const responseData = {
      id: user.id,
      email: user.emailAddresses[0]?.emailAddress || "",
      name: user.fullName || user.username || "Unknown",
      role: user.publicMetadata?.role || "guest",
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
      // Only include public metadata
      metadata: user.publicMetadata,
      // Include additional data only for own profile
      ...(isOwnData && {
        emailAddresses: user.emailAddresses.map(email => ({
          email: email.emailAddress,
          verified: email.verification?.status === "verified",
        })),
        phoneNumbers: user.phoneNumbers.map(phone => ({
          phone: phone.phoneNumber,
        })),
        lastSignInAt: user.lastSignInAt,
        // Include private metadata only for own profile
        privateMetadata: user.privateMetadata,
      }),
    };
    
    return NextResponse.json({
      success: true,
      user: responseData,
      accessLevel: isOwnData ? "own_profile" : "admin_access",
    });
    
  } catch (error: any) {
    console.error(`Error in /api/users/${params.userId}:`, error);
    
    if (error.message === "User not authenticated") {
      return NextResponse.json(
        { error: "Authentication required" },
        { status: 401 }
      );
    }
    
    return NextResponse.json(
      { error: "Internal server error" },
      { status: 500 }
    );
  }
}

// PUT handler for updating a user
export async function PUT(
  request: NextRequest,
  { params }: { params: { userId: string } }
) {
  try {
    const requestedUserId = params.userId;
    const authContext = await getAuthContext();
    
    // Check if updating own profile or has admin permission
    const isOwnData = authContext.userId === requestedUserId;
    const canWriteUser = await hasPermission(authContext.userId, PERMISSIONS.USER_WRITE);
    
    if (!isOwnData && !canWriteUser) {
      return NextResponse.json(
        { error: "You don't have permission to update this user" },
        { status: 403 }
      );
    }
    
    // Parse the request body
    const body = await request.json();
    
    // Validate the data (simplified for demonstration)
    if (!body || typeof body !== "object") {
      return NextResponse.json(
        { error: "Invalid request body" },
        { status: 400 }
      );
    }
    
    // Update user metadata (public)
    const updatedUser = await clerkClient().users.updateUser(requestedUserId, {
      publicMetadata: body.publicMetadata || {},
      ...(isOwnData && {
        privateMetadata: body.privateMetadata || {},
      }),
    });
    
    // Log the update
    await logAuthEvent(authContext.userId, "user_update", {
      endpoint: `/api/users/${requestedUserId}`,
      method: "PUT",
      targetUserId: requestedUserId,
      fieldsUpdated: Object.keys(body),
    });
    
    return NextResponse.json({
      success: true,
      message: "User updated successfully",
      updatedFields: Object.keys(body),
      user: {
        id: updatedUser.id,
        email: updatedUser.emailAddresses[0]?.emailAddress,
        name: updatedUser.fullName,
        role: updatedUser.publicMetadata?.role,
      },
    });
    
  } catch (error: any) {
    console.error(`Error in PUT /api/users/${params.userId}:`, error);
    
    if (error.message === "User not authenticated") {
      return NextResponse.json(
        { error: "Authentication required" },
        { status: 401 }
      );
    }
    
    return NextResponse.json(
      { error: "Internal server error" },
      { status: 500 }
    );
  }
}

// DELETE handler for removing a user (admin only)
export async function DELETE(
  request: NextRequest,
  { params }: { params: { userId: string } }
) {
  try {
    const requestedUserId = params.userId;
    const authContext = await getAuthContext();
    
    // Only admins can delete users
    const canDeleteUser = await hasPermission(authContext.userId, PERMISSIONS.USER_DELETE);
    
    if (!canDeleteUser) {
      return NextResponse.json(
        { error: "Admin access required to delete users" },
        { status: 403 }
      );
    }
    
    // Prevent deleting own account (safety check)
    if (authContext.userId === requestedUserId) {
      return NextResponse.json(
        { error: "You cannot delete your own account" },
        { status: 400 }
      );
    }
    
    // Delete the user from Clerk
    await clerkClient().users.deleteUser(requestedUserId);
    
    // Log the deletion
    await logAuthEvent(authContext.userId, "user_delete", {
      endpoint: `/api/users/${requestedUserId}`,
      method: "DELETE",
      targetUserId: requestedUserId,
    });
    
    return NextResponse.json({
      success: true,
      message: "User deleted successfully",
      deletedUserId: requestedUserId,
    });
    
  } catch (error: any) {
    console.error(`Error in DELETE /api/users/${params.userId}:`, error);
    
    if (error.message === "User not authenticated") {
      return NextResponse.json(
        { error: "Authentication required" },
        { status: 401 }
      );
    }
    
    return NextResponse.json(
      { error: "Internal server error" },
      { status: 500 }
    );
  }
}
```

### Step 6: Create Admin-Only Endpoints

**File:** `app/api/admin/route.ts`

```tsx
// app/api/admin/route.ts
// GET /api/admin - Admin dashboard endpoint
// Demonstrates strict admin-only access

import { NextRequest, NextResponse } from "next/server";
import { getAuthContext, logAuthEvent, requireRole } from "@/lib/auth-helpers";
import { PERMISSIONS, hasPermission } from "@/lib/permissions";
import { clerkClient } from "@clerk/nextjs/server";

/**
 * GET handler for /api/admin
 * Returns admin dashboard data
 * Requires admin role
 * 
 * @param request - The incoming request
 * @returns Admin dashboard data or error
 */
export async function GET(request: NextRequest) {
  try {
    // Require admin role using our helper
    // This will throw if user is not admin
    const authContext = await requireRole("admin", request, "/sign-in");
    
    // Additional permission check for specific admin actions
    const hasAdminAccess = await hasPermission(authContext.userId, PERMISSIONS.ADMIN_ACCESS);
    if (!hasAdminAccess) {
      return NextResponse.json(
        { error: "You don't have admin access permission" },
        { status: 403 }
      );
    }
    
    // Log the admin access
    await logAuthEvent(authContext.userId, "admin_dashboard_access", {
      endpoint: "/api/admin",
      method: "GET",
      sessionId: authContext.sessionId,
    });
    
    // Gather admin dashboard statistics
    // In production, this would query your database
    
    // Get user count
    const usersList = await clerkClient().users.getUserList({ limit: 1 });
    // Note: In production, you'd use a proper count endpoint or pagination
    
    // Get session count (simplified)
    // In production, you'd use Clerk's sessions API or your own database
    
    // Compile dashboard data
    const dashboardData = {
      admin: {
        id: authContext.userId,
        role: authContext.role,
        permissions: authContext.permissions,
      },
      statistics: {
        totalUsers: 0, // In production, fetch actual count
        activeSessions: 0,
        recentSignups: 0,
        organizations: 0,
      },
      systemInfo: {
        timestamp: new Date().toISOString(),
        environment: process.env.NODE_ENV || "development",
        version: process.env.NEXT_PUBLIC_APP_VERSION || "1.0.0",
      },
      // Add recent activity (simplified)
      recentActivity: [
        {
          id: "1",
          action: "user_login",
          timestamp: new Date().toISOString(),
          userId: "user_example",
        },
      ],
    };
    
    return NextResponse.json({
      success: true,
      data: dashboardData,
      message: "Welcome to the admin dashboard",
    });
    
  } catch (error: any) {
    console.error("Error in /api/admin:", error);
    
    if (error.message === "Authentication required") {
      return NextResponse.json(
        { error: "Authentication required" },
        { status: 401 }
      );
    }
    
    if (error.message === "Insufficient permissions") {
      return NextResponse.json(
        { error: "Admin access required" },
        { status: 403 }
      );
    }
    
    return NextResponse.json(
      { error: "Internal server error" },
      { status: 500 }
    );
  }
}
```

### Step 7: Create Server Actions for Secure Operations

Next.js Server Actions provide a way to perform server-side mutations directly from client components. Let's secure them with Clerk.

**File:** `app/actions/auth-actions.ts`

```tsx
// app/actions/auth-actions.ts
// Server Actions for authentication and user operations
// These run on the server and are protected by Clerk

"use server";

import { auth, currentUser, clerkClient } from "@clerk/nextjs/server";
import { revalidatePath } from "next/cache";
import { z } from "zod"; // We'll add this for validation

// Schema for updating user profile
const UpdateProfileSchema = z.object({
  fullName: z.string().min(1, "Full name is required"),
  username: z.string().min(3, "Username must be at least 3 characters"),
  bio: z.string().max(500, "Bio must be 500 characters or less").optional(),
});

type UpdateProfileData = z.infer<typeof UpdateProfileSchema>;

/**
 * Server Action: Update user profile
 * Only the authenticated user can update their own profile
 * 
 * @param data - The profile data to update
 * @returns Success message or error
 */
export async function updateUserProfile(data: UpdateProfileData) {
  try {
    // Check authentication
    const { userId } = await auth();
    if (!userId) {
      return {
        success: false,
        error: "You must be signed in to update your profile",
      };
    }
    
    // Validate the data
    const validatedData = UpdateProfileSchema.parse(data);
    
    // Get the current user
    const user = await currentUser();
    if (!user) {
      return {
        success: false,
        error: "User not found",
      };
    }
    
    // Update user metadata (public)
    await clerkClient().users.updateUser(userId, {
      firstName: validatedData.fullName.split(" ")[0] || "",
      lastName: validatedData.fullName.split(" ").slice(1).join(" ") || "",
      username: validatedData.username,
      publicMetadata: {
        ...user.publicMetadata,
        bio: validatedData.bio || "",
        updatedAt: new Date().toISOString(),
      },
    });
    
    // Revalidate the profile page to show updated data
    revalidatePath("/profile");
    revalidatePath("/dashboard");
    
    return {
      success: true,
      message: "Profile updated successfully",
    };
    
  } catch (error: any) {
    console.error("Error updating user profile:", error);
    
    if (error.name === "ZodError") {
      return {
        success: false,
        error: "Validation failed",
        details: error.errors,
      };
    }
    
    return {
      success: false,
      error: "Failed to update profile",
    };
  }
}

/**
 * Server Action: Get user's session info
 * Returns current session details
 * 
 * @returns Session information
 */
export async function getSessionInfo() {
  try {
    const { userId, sessionId, orgId } = await auth();
    
    if (!userId) {
      return {
        authenticated: false,
        error: "Not authenticated",
      };
    }
    
    return {
      authenticated: true,
      userId,
      sessionId,
      orgId,
      timestamp: new Date().toISOString(),
    };
    
  } catch (error) {
    console.error("Error getting session info:", error);
    return {
      authenticated: false,
      error: "Failed to get session info",
    };
  }
}

/**
 * Server Action: Change user's password (requires current password)
 * 
 * @param currentPassword - The user's current password
 * @param newPassword - The new password
 * @returns Success message or error
 */
export async function changeUserPassword(
  currentPassword: string,
  newPassword: string
) {
  try {
    const { userId } = await auth();
    if (!userId) {
      return {
        success: false,
        error: "You must be signed in to change your password",
      };
    }
    
    // Note: Clerk handles password changes through their API
    // This requires the user to provide their current password for verification
    
    // In a production app, you'd use Clerk's password verification
    // and then update the password
    // For demonstration:
    await clerkClient().users.updateUser(userId, {
      password: newPassword,
    });
    
    return {
      success: true,
      message: "Password changed successfully",
    };
    
  } catch (error) {
    console.error("Error changing password:", error);
    return {
      success: false,
      error: "Failed to change password. Please try again.",
    };
  }
}
```

**File:** `app/actions/user-actions.ts`

```tsx
// app/actions/user-actions.ts
// Server Actions for user management (admin only)

"use server";

import { auth, clerkClient } from "@clerk/nextjs/server";
import { revalidatePath } from "next/cache";
import { hasPermission } from "@/lib/auth-helpers";
import { PERMISSIONS } from "@/lib/permissions";

/**
 * Server Action: Assign role to a user (admin only)
 * 
 * @param userId - The user ID to update
 * @param role - The role to assign
 * @returns Success message or error
 */
export async function assignUserRole(userId: string, role: string) {
  try {
    // Check authentication
    const { userId: currentUserId } = await auth();
    if (!currentUserId) {
      return {
        success: false,
        error: "You must be signed in to perform this action",
      };
    }
    
    // Check if user has admin permissions
    const hasAdminPermission = await hasPermission(currentUserId, PERMISSIONS.USER_WRITE);
    if (!hasAdminPermission) {
      return {
        success: false,
        error: "You don't have permission to assign roles",
      };
    }
    
    // Prevent self-demotion or self-promotion (safety check)
    if (currentUserId === userId) {
      return {
        success: false,
        error: "You cannot modify your own role",
      };
    }
    
    // Get the user to update
    const user = await clerkClient().users.getUser(userId);
    if (!user) {
      return {
        success: false,
        error: "User not found",
      };
    }
    
    // Update the user's role in public metadata
    await clerkClient().users.updateUser(userId, {
      publicMetadata: {
        ...user.publicMetadata,
        role,
        roleUpdatedAt: new Date().toISOString(),
        roleUpdatedBy: currentUserId,
      },
    });
    
    // Revalidate relevant pages
    revalidatePath("/admin/users");
    revalidatePath("/users");
    revalidatePath("/dashboard");
    
    return {
      success: true,
      message: `Role updated to "${role}" successfully`,
    };
    
  } catch (error) {
    console.error("Error assigning user role:", error);
    return {
      success: false,
      error: "Failed to assign role",
    };
  }
}

/**
 * Server Action: Delete a user (admin only)
 * 
 * @param userId - The user ID to delete
 * @returns Success message or error
 */
export async function deleteUserAccount(userId: string) {
  try {
    const { userId: currentUserId } = await auth();
    if (!currentUserId) {
      return {
        success: false,
        error: "You must be signed in to perform this action",
      };
    }
    
    // Check if user has admin permissions
    const canDeleteUser = await hasPermission(currentUserId, PERMISSIONS.USER_DELETE);
    if (!canDeleteUser) {
      return {
        success: false,
        error: "You don't have permission to delete users",
      };
    }
    
    // Prevent deleting own account
    if (currentUserId === userId) {
      return {
        success: false,
        error: "You cannot delete your own account",
      };
    }
    
    // Delete the user
    await clerkClient().users.deleteUser(userId);
    
    // Revalidate pages
    revalidatePath("/admin/users");
    revalidatePath("/users");
    
    return {
      success: true,
      message: "User deleted successfully",
    };
    
  } catch (error) {
    console.error("Error deleting user:", error);
    return {
      success: false,
      error: "Failed to delete user",
    };
  }
}
```

### Step 8: Create a Protected Client Component Example

Let's create a client component that uses Server Actions for secure operations.

**File:** `app/components/ProfileEditor.tsx`

```tsx
// app/components/ProfileEditor.tsx
// Client component that uses Server Actions for profile updates
// Demonstrates secure client-server interaction

"use client";

import { useState } from "react";
import { updateUserProfile } from "@/app/actions/auth-actions";
import { useUser } from "@clerk/nextjs";

interface ProfileEditorProps {
  initialData: {
    fullName: string;
    username: string;
    bio?: string;
  };
}

export default function ProfileEditor({ initialData }: ProfileEditorProps) {
  const { user, isLoaded } = useUser();
  const [isLoading, setIsLoading] = useState(false);
  const [message, setMessage] = useState<{
    type: "success" | "error" | "info";
    text: string;
  } | null>(null);
  
  // Form state
  const [formData, setFormData] = useState(initialData);
  
  // Handle form submission
  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsLoading(true);
    setMessage(null);
    
    try {
      // Call the Server Action
      const result = await updateUserProfile(formData);
      
      if (result.success) {
        setMessage({
          type: "success",
          text: result.message || "Profile updated successfully!",
        });
        // Refresh the page to show updated data
        window.location.reload();
      } else {
        setMessage({
          type: "error",
          text: result.error || "Failed to update profile",
        });
      }
    } catch (error) {
      setMessage({
        type: "error",
        text: "An unexpected error occurred",
      });
    } finally {
      setIsLoading(false);
    }
  };
  
  // Handle input changes
  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) => {
    const { name, value } = e.target;
    setFormData(prev => ({ ...prev, [name]: value }));
  };
  
  // Check if user is loading
  if (!isLoaded) {
    return <div className="text-gray-500">Loading profile...</div>;
  }
  
  // Check if user is authenticated
  if (!user) {
    return <div className="text-red-600">Please sign in to edit your profile</div>;
  }
  
  return (
    <div className="max-w-2xl mx-auto p-6 bg-white rounded-lg shadow-sm">
      <h2 className="text-2xl font-bold text-gray-900 mb-6">
        Edit Profile
      </h2>
      
      {/* Status message */}
      {message && (
        <div className={`mb-4 p-3 rounded ${
          message.type === "success" ? "bg-green-100 text-green-700" :
          message.type === "error" ? "bg-red-100 text-red-700" :
          "bg-blue-100 text-blue-700"
        }`}>
          {message.text}
        </div>
      )}
      
      <form onSubmit={handleSubmit} className="space-y-4">
        {/* Full Name */}
        <div>
          <label htmlFor="fullName" className="block text-sm font-medium text-gray-700">
            Full Name
          </label>
          <input
            type="text"
            id="fullName"
            name="fullName"
            value={formData.fullName}
            onChange={handleChange}
            required
            className="mt-1 block w-full border border-gray-300 rounded-md shadow-sm px-3 py-2 focus:ring-indigo-500 focus:border-indigo-500"
          />
        </div>
        
        {/* Username */}
        <div>
          <label htmlFor="username" className="block text-sm font-medium text-gray-700">
            Username
          </label>
          <input
            type="text"
            id="username"
            name="username"
            value={formData.username}
            onChange={handleChange}
            required
            className="mt-1 block w-full border border-gray-300 rounded-md shadow-sm px-3 py-2 focus:ring-indigo-500 focus:border-indigo-500"
          />
        </div>
        
        {/* Bio */}
        <div>
          <label htmlFor="bio" className="block text-sm font-medium text-gray-700">
            Bio
          </label>
          <textarea
            id="bio"
            name="bio"
            value={formData.bio || ""}
            onChange={handleChange}
            rows={4}
            maxLength={500}
            className="mt-1 block w-full border border-gray-300 rounded-md shadow-sm px-3 py-2 focus:ring-indigo-500 focus:border-indigo-500"
            placeholder="Tell us about yourself..."
          />
          <p className="mt-1 text-sm text-gray-500">
            {formData.bio?.length || 0}/500 characters
          </p>
        </div>
        
        {/* Submit Button */}
        <div>
          <button
            type="submit"
            disabled={isLoading}
            className="w-full bg-indigo-600 text-white px-4 py-2 rounded-md hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
          >
            {isLoading ? "Saving..." : "Update Profile"}
          </button>
        </div>
      </form>
      
      {/* Security info */}
      <div className="mt-6 pt-6 border-t border-gray-200">
        <p className="text-xs text-gray-400">
          🔒 Your data is securely transmitted and processed on the server.
          All changes are authenticated using Clerk's session management.
        </p>
      </div>
    </div>
  );
}
```

**File:** `app/profile/page.tsx` (updated to include the editor)

```tsx
// app/profile/page.tsx
// Updated profile page with the ProfileEditor component

import { auth, currentUser } from "@clerk/nextjs/server";
import { redirect } from "next/navigation";
import { UserButton } from "@clerk/nextjs";
import Link from "next/link";
import ProfileEditor from "@/app/components/ProfileEditor";

export default async function ProfilePage() {
  // Verify authentication
  const { userId } = await auth();
  if (!userId) {
    redirect("/sign-in");
  }

  // Fetch user data
  const user = await currentUser();
  
  // Extract user details
  const fullName = user?.fullName || "";
  const username = user?.username || "";
  const bio = user?.publicMetadata?.bio as string || "";
  
  // Prepare initial data for the editor
  const initialData = {
    fullName,
    username,
    bio,
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
              <span className="ml-3 text-sm text-gray-500">Profile</span>
            </div>
            
            <div className="flex items-center space-x-4">
              <Link 
                href="/dashboard" 
                className="text-gray-600 hover:text-indigo-600 transition-colors"
              >
                Dashboard
              </Link>
              <UserButton afterSignOutUrl="/" />
            </div>
          </div>
        </div>
      </nav>

      {/* Main Content */}
      <main className="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
        {/* User Info Header */}
        <div className="bg-white rounded-lg shadow-sm p-6 mb-6">
          <div className="flex items-center space-x-4">
            <div className="w-16 h-16 rounded-full bg-indigo-100 flex items-center justify-center text-2xl">
              {fullName.charAt(0) || "👤"}
            </div>
            <div>
              <h1 className="text-2xl font-bold text-gray-900">{fullName}</h1>
              <p className="text-gray-600">@{username}</p>
              {bio && <p className="text-gray-600 text-sm mt-1">{bio}</p>}
            </div>
          </div>
        </div>

        {/* Profile Editor */}
        <ProfileEditor initialData={initialData} />
      </main>
    </div>
  );
}
```

### Step 9: Create a User Admin Table (Admin Only)

Let's build an admin interface for managing users.

**File:** `app/admin/users/page.tsx`

```tsx
// app/admin/users/page.tsx
// Admin page for user management
// Demonstrates server-side protection and client-server interaction

import { auth, clerkClient } from "@clerk/nextjs/server";
import { redirect } from "next/navigation";
import Link from "next/link";
import { UserButton } from "@clerk/nextjs";
import { hasPermission } from "@/lib/auth-helpers";
import { PERMISSIONS } from "@/lib/permissions";
import UserManagementTable from "@/app/components/UserManagementTable";

export default async function AdminUsersPage() {
  // Check authentication
  const { userId } = await auth();
  if (!userId) {
    redirect("/sign-in");
  }
  
  // Check admin permission
  const canListUsers = await hasPermission(userId, PERMISSIONS.USER_LIST);
  if (!canListUsers) {
    redirect("/dashboard?error=access_denied");
  }
  
  // Fetch all users
  const users = await clerkClient().users.getUserList({
    limit: 100,
  });
  
  // Format users for display
  const formattedUsers = users.map(user => ({
    id: user.id,
    email: user.emailAddresses[0]?.emailAddress || "",
    name: user.fullName || user.username || "Unknown",
    role: (user.publicMetadata?.role as string) || "guest",
    createdAt: user.createdAt,
    lastSignInAt: user.lastSignInAt,
    isVerified: user.emailAddresses.some(e => e.verification?.status === "verified"),
  }));
  
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
              <span className="ml-3 text-sm text-gray-500">Admin</span>
            </div>
            
            <div className="flex items-center space-x-4">
              <Link 
                href="/dashboard" 
                className="text-gray-600 hover:text-indigo-600 transition-colors"
              >
                Dashboard
              </Link>
              <Link 
                href="/admin/users" 
                className="text-indigo-600 font-medium"
              >
                Users
              </Link>
              <UserButton afterSignOutUrl="/" />
            </div>
          </div>
        </div>
      </nav>

      {/* Main Content */}
      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
        <div className="bg-white rounded-lg shadow-sm p-6">
          <div className="flex items-center justify-between mb-6">
            <div>
              <h1 className="text-2xl font-bold text-gray-900">User Management</h1>
              <p className="text-gray-600">Manage all users in the system</p>
            </div>
            <div className="text-sm text-gray-500">
              Total: {formattedUsers.length} users
            </div>
          </div>
          
          {/* User Management Table */}
          <UserManagementTable initialUsers={formattedUsers} />
          
          <div className="mt-6 pt-6 border-t border-gray-200">
            <p className="text-xs text-gray-400">
              🔒 This page is only accessible to administrators.
              All actions are securely authenticated and authorized.
            </p>
          </div>
        </div>
      </main>
    </div>
  );
}
```

**File:** `app/components/UserManagementTable.tsx`

```tsx
// app/components/UserManagementTable.tsx
// Client component for user management with Server Actions

"use client";

import { useState } from "react";
import { assignUserRole, deleteUserAccount } from "@/app/actions/user-actions";

interface User {
  id: string;
  email: string;
  name: string;
  role: string;
  createdAt: Date;
  lastSignInAt: Date | null;
  isVerified: boolean;
}

interface UserManagementTableProps {
  initialUsers: User[];
}

export default function UserManagementTable({ initialUsers }: UserManagementTableProps) {
  const [users, setUsers] = useState(initialUsers);
  const [loading, setLoading] = useState<string | null>(null);
  const [message, setMessage] = useState<{
    userId: string;
    type: "success" | "error";
    text: string;
  } | null>(null);
  
  const handleRoleChange = async (userId: string, newRole: string) => {
    setLoading(userId);
    setMessage(null);
    
    try {
      const result = await assignUserRole(userId, newRole);
      
      if (result.success) {
        // Update the local state
        setUsers(prev => 
          prev.map(user => 
            user.id === userId 
              ? { ...user, role: newRole }
              : user
          )
        );
        setMessage({
          userId,
          type: "success",
          text: result.message || "Role updated",
        });
      } else {
        setMessage({
          userId,
          type: "error",
          text: result.error || "Failed to update role",
        });
      }
    } catch (error) {
      setMessage({
        userId,
        type: "error",
        text: "An unexpected error occurred",
      });
    } finally {
      setLoading(null);
    }
  };
  
  const handleDeleteUser = async (userId: string, userName: string) => {
    if (!confirm(`Are you sure you want to delete ${userName}? This action cannot be undone.`)) {
      return;
    }
    
    setLoading(userId);
    setMessage(null);
    
    try {
      const result = await deleteUserAccount(userId);
      
      if (result.success) {
        // Remove the user from local state
        setUsers(prev => prev.filter(user => user.id !== userId));
        setMessage({
          userId,
          type: "success",
          text: result.message || "User deleted",
        });
      } else {
        setMessage({
          userId,
          type: "error",
          text: result.error || "Failed to delete user",
        });
      }
    } catch (error) {
      setMessage({
        userId,
        type: "error",
        text: "An unexpected error occurred",
      });
    } finally {
      setLoading(null);
    }
  };
  
  return (
    <div className="overflow-x-auto">
      {users.length === 0 ? (
        <p className="text-gray-500 text-center py-8">No users found</p>
      ) : (
        <table className="min-w-full divide-y divide-gray-200">
          <thead className="bg-gray-50">
            <tr>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                User
              </th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Email
              </th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Role
              </th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Status
              </th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Joined
              </th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Actions
              </th>
            </tr>
          </thead>
          <tbody className="bg-white divide-y divide-gray-200">
            {users.map((user) => (
              <tr key={user.id}>
                <td className="px-6 py-4 whitespace-nowrap">
                  <div className="flex items-center">
                    <div className="h-10 w-10 rounded-full bg-indigo-100 flex items-center justify-center">
                      <span className="text-indigo-600 font-medium">
                        {user.name.charAt(0).toUpperCase()}
                      </span>
                    </div>
                    <div className="ml-4">
                      <div className="text-sm font-medium text-gray-900">
                        {user.name}
                      </div>
                    </div>
                  </div>
                </td>
                <td className="px-6 py-4 whitespace-nowrap">
                  <div className="text-sm text-gray-900">{user.email}</div>
                  {user.isVerified && (
                    <span className="text-xs text-green-600">Verified</span>
                  )}
                </td>
                <td className="px-6 py-4 whitespace-nowrap">
                  <select
                    value={user.role}
                    onChange={(e) => handleRoleChange(user.id, e.target.value)}
                    disabled={loading === user.id}
                    className="text-sm border border-gray-300 rounded-md px-2 py-1 focus:ring-indigo-500 focus:border-indigo-500 disabled:opacity-50"
                  >
                    <option value="guest">Guest</option>
                    <option value="user">User</option>
                    <option value="moderator">Moderator</option>
                    <option value="admin">Admin</option>
                  </select>
                  {loading === user.id && (
                    <span className="ml-2 text-xs text-gray-500">Updating...</span>
                  )}
                </td>
                <td className="px-6 py-4 whitespace-nowrap">
                  <span className={`px-2 inline-flex text-xs leading-5 font-semibold rounded-full ${
                    user.isVerified 
                      ? "bg-green-100 text-green-800" 
                      : "bg-yellow-100 text-yellow-800"
                  }`}>
                    {user.isVerified ? "Active" : "Pending"}
                  </span>
                </td>
                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                  {new Date(user.createdAt).toLocaleDateString()}
                </td>
                <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                  <button
                    onClick={() => handleDeleteUser(user.id, user.name)}
                    disabled={loading === user.id}
                    className="text-red-600 hover:text-red-900 disabled:opacity-50 disabled:cursor-not-allowed"
                  >
                    Delete
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      )}
      
      {/* Messages */}
      {message && (
        <div className={`mt-4 p-3 rounded ${
          message.type === "success" ? "bg-green-100 text-green-700" : "bg-red-100 text-red-700"
        }`}>
          {message.text}
        </div>
      )}
    </div>
  );
}
```

### Step 10: Add Error Handling and Logging Middleware

Let's create a global error handler for API routes.

**File:** `app/api/error-handler.ts`

```tsx
// app/api/error-handler.ts
// Global error handler for API routes
// Centralizes error handling, logging, and response formatting

import { NextResponse } from "next/server";
import { logAuthEvent } from "@/lib/auth-helpers";

export type ApiError = {
  code: string;
  message: string;
  status: number;
  details?: unknown;
};

export class ApiError extends Error {
  code: string;
  status: number;
  details?: unknown;
  
  constructor(code: string, message: string, status: number = 500, details?: unknown) {
    super(message);
    this.code = code;
    this.status = status;
    this.details = details;
    this.name = "ApiError";
  }
  
  // Predefined error types
  static unauthorized(details?: unknown): ApiError {
    return new ApiError(
      "UNAUTHORIZED",
      "Authentication required",
      401,
      details
    );
  }
  
  static forbidden(details?: unknown): ApiError {
    return new ApiError(
      "FORBIDDEN",
      "You don't have permission to access this resource",
      403,
      details
    );
  }
  
  static notFound(details?: unknown): ApiError {
    return new ApiError(
      "NOT_FOUND",
      "Resource not found",
      404,
      details
    );
  }
  
  static validationFailed(details?: unknown): ApiError {
    return new ApiError(
      "VALIDATION_FAILED",
      "Validation failed",
      400,
      details
    );
  }
  
  static internalError(details?: unknown): ApiError {
    return new ApiError(
      "INTERNAL_ERROR",
      "An internal server error occurred",
      500,
      details
    );
  }
}

/**
 * Global error handler for API routes
 * Wraps API handlers with error handling and logging
 * 
 * @param handler - The API handler function
 * @returns Wrapped handler with error handling
 */
export function withErrorHandler<T>(
  handler: (request: Request, ...args: unknown[]) => Promise<T>
): (request: Request, ...args: unknown[]) => Promise<NextResponse> {
  return async (request: Request, ...args: unknown[]) => {
    try {
      const result = await handler(request, ...args);
      return NextResponse.json(result);
    } catch (error) {
      // Log the error
      console.error("[API Error]", error);
      
      // Determine if it's our custom API error
      if (error instanceof ApiError) {
        // Log authentication errors
        if (error.status === 401 || error.status === 403) {
          await logAuthEvent(null, "api_error", {
            error: error.code,
            message: error.message,
            status: error.status,
            path: new URL(request.url).pathname,
          });
        }
        
        return NextResponse.json(
          {
            error: error.code,
            message: error.message,
            details: error.details,
          },
          { status: error.status }
        );
      }
      
      // Handle unknown errors
      return NextResponse.json(
        {
          error: "INTERNAL_ERROR",
          message: "An unexpected error occurred",
        },
        { status: 500 }
      );
    }
  };
}

/**
 * Validate request body against a schema
 * 
 * @param body - The request body
 * @param schema - Zod schema or validation function
 * @returns Validated data
 * @throws {ApiError} If validation fails
 */
export function validateBody<T>(
  body: unknown,
  schema: (data: unknown) => T
): T {
  try {
    return schema(body);
  } catch (error) {
    throw ApiError.validationFailed({
      error: error instanceof Error ? error.message : "Invalid request body",
    });
  }
}
```

### Step 11: Test the API Endpoints

Now let's create a test script and document how to verify everything works.

**File:** `tests/api-test.sh`

```bash
#!/bin/bash
# tests/api-test.sh
# Test script for the Clerk authentication API endpoints
# Run with: bash tests/api-test.sh

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

BASE_URL="http://localhost:3000"
echo -e "${YELLOW}Testing Clerk Authentication API${NC}"
echo "====================================="

# Test 1: Unauthenticated access to protected endpoint
echo -e "\n${YELLOW}Test 1: Unauthenticated access to protected endpoint${NC}"
response=$(curl -s -o /dev/null -w "%{http_code}" $BASE_URL/api/auth/protected)
if [ "$response" -eq 401 ]; then
  echo -e "${GREEN}✓ Passed: Got 401 Unauthorized${NC}"
else
  echo -e "${RED}✗ Failed: Expected 401, got $response${NC}"
fi

# Test 2: Unauthenticated access to users endpoint
echo -e "\n${YELLOW}Test 2: Unauthenticated access to users endpoint${NC}"
response=$(curl -s -o /dev/null -w "%{http_code}" $BASE_URL/api/users)
if [ "$response" -eq 401 ]; then
  echo -e "${GREEN}✓ Passed: Got 401 Unauthorized${NC}"
else
  echo -e "${RED}✗ Failed: Expected 401, got $response${NC}"
fi

# Test 3: Unauthenticated access to admin endpoint
echo -e "\n${YELLOW}Test 3: Unauthenticated access to admin endpoint${NC}"
response=$(curl -s -o /dev/null -w "%{http_code}" $BASE_URL/api/admin)
if [ "$response" -eq 401 ]; then
  echo -e "${GREEN}✓ Passed: Got 401 Unauthorized${NC}"
else
  echo -e "${RED}✗ Failed: Expected 401, got $response${NC}"
fi

# Test 4: Check if API routes are accessible
echo -e "\n${YELLOW}Test 4: Check API route availability${NC}"
echo "Note: These tests require authentication."
echo "To test authenticated endpoints, you need to:"
echo "1. Sign in at $BASE_URL/sign-in"
echo "2. Get your session cookie from the browser dev tools"
echo "3. Use the cookie in curl requests"

echo -e "\n${YELLOW}Example authenticated request:${NC}"
echo "curl -b '__session=YOUR_SESSION_COOKIE' $BASE_URL/api/auth/me"

echo -e "\n${YELLOW}Manual verification steps:${NC}"
echo "1. Navigate to $BASE_URL/api/auth/me in your browser (while signed in)"
echo "2. You should see your user data in JSON format"
echo "3. Navigate to $BASE_URL/api/users (admin users only)"
echo "4. You should see a list of all users"

echo -e "\n${GREEN}Testing complete!${NC}"
```

---

## What We've Accomplished

Let's recap everything you've built in Part 2:

### ✅ Completed Tasks

1. **Created comprehensive auth helpers:**
   - `getAuthContext()` - Type-safe authentication context
   - `hasRole()` / `hasPermissions()` - Permission checking
   - `requireAuth()` / `requireRole()` - Middleware helpers
   - `getEnhancedCurrentUser()` - Extended user data
   - `logAuthEvent()` - Audit logging

2. **Built middleware helpers:**
   - `isAuthenticated()` - Quick auth check
   - `createRouteMatcher()` - Pattern matching
   - `withCors()` - CORS support for APIs
   - `logMiddlewareAction()` - Middleware logging

3. **Defined permission system:**
   - `PERMISSIONS` - All permission constants
   - `ROLE_PERMISSIONS` - Role-based permission sets
   - `hasPermission()` - Permission checking
   - `canAccessRoute()` - Route-based access control

4. **Created protected API endpoints:**
   - `GET /api/auth/me` - Get current user
   - `GET /api/auth/protected` - Test protected endpoint
   - `GET /api/users` - List users (admin)
   - `GET /api/users/:id` - Get specific user
   - `PUT /api/users/:id` - Update user
   - `DELETE /api/users/:id` - Delete user
   - `GET /api/admin` - Admin dashboard

5. **Built Server Actions:**
   - `updateUserProfile()` - Update user profile
   - `getSessionInfo()` - Get session details
   - `assignUserRole()` - Assign user role (admin)
   - `deleteUserAccount()` - Delete user (admin)

6. **Created UI components:**
   - `ProfileEditor` - Client component with Server Actions
   - `UserManagementTable` - Admin user management

7. **Added error handling:**
   - `ApiError` class with predefined error types
   - `withErrorHandler()` - Global error handler wrapper
   - `validateBody()` - Request validation

8. **Enhanced middleware:**
   - Role checking
   - Permission verification
   - API vs UI route handling
   - Proper status codes (401, 403)

### 🎯 Key Skills Acquired

- Understanding JWT tokens and session management
- Building type-safe authentication utilities
- Implementing role-based access control (RBAC)
- Creating permission-based authorization systems
- Protecting API endpoints with middleware
- Using Server Actions with authentication
- Building admin interfaces with user management
- Implementing proper error handling and logging
- Understanding the principle of least privilege

---

## Common Issues and Troubleshooting

### Issue: API returns 401 even when authenticated

**Solution:**
- Check that the session cookie is being sent
- Verify the cookie name: `__session`
- Ensure the request is made to the same domain
- Check if the token has expired (try refreshing the page)

### Issue: `auth()` returns null in API routes

**Solution:**
- Ensure the API route is inside the `app/api` directory
- Verify that the route is not excluded from middleware
- Check that `clerkMiddleware` is properly configured
- Ensure the route matcher includes API routes

### Issue: Role/permission checks fail

**Solution:**
- Verify that user metadata is set correctly in Clerk Dashboard
- Check the structure of `publicMetadata` (should have `role` and `permissions`)
- Ensure metadata is being correctly extracted
- Consider caching user data to reduce API calls

### Issue: Server Actions return "Not authenticated" even when signed in

**Solution:**
- Server Actions run on the server, so they have access to the session
- Ensure the `auth()` function is called inside the action
- Check that the action is properly imported and used
- Verify that the action is using `"use server"` directive

### Issue: CORS errors when calling API from other domains

**Solution:**
- Use the `withCors()` helper for API routes
- Configure allowed origins in production
- Handle preflight OPTIONS requests

### Issue: Rate limiting or performance issues

**Solution:**
- Cache user data when possible
- Implement pagination for user lists
- Use Clerk's session caching
- Consider using database storage for frequently accessed data

---

## Part 2 Verification Checklist

- [ ] `GET /api/auth/me` returns user data when authenticated
- [ ] `GET /api/auth/me` returns 401 when unauthenticated
- [ ] `GET /api/auth/protected` returns success when authenticated
- [ ] `GET /api/users` returns 401 when unauthenticated
- [ ] `GET /api/users` returns 403 when authenticated as non-admin
- [ ] `GET /api/users` returns list when authenticated as admin
- [ ] `GET /api/users/:id` allows access to own profile
- [ ] `GET /api/users/:id` denies access to other user's profile (non-admin)
- [ ] `PUT /api/users/:id` allows updating own profile
- [ ] `DELETE /api/users/:id` requires admin permission
- [ ] `GET /api/admin` requires admin role
- [ ] Server Actions work with authentication
- [ ] ProfileEditor updates user profile correctly
- [ ] UserManagementTable displays users (admin)
- [ ] UserManagementTable can assign roles (admin)
- [ ] UserManagementTable can delete users (admin)
- [ ] Error handling returns appropriate status codes
- [ ] Audit logging records auth events

---

## What's Coming in Part 3

Now that you've mastered server-side security, Part 3 will dive deep into **Multi-Tenant SaaS Architecture**. You'll learn:

- The core architectural patterns of multi-tenancy
- Configuring and utilizing Clerk Organizations
- Programmatically inviting users into organizations
- Building custom organization switcher UI components
- Implementing Role-Based Access Control (RBAC) using Clerk Roles
- Combining organization-level roles with business logic
- Filtering database queries by active organization ID
- Designing scalable permission hierarchies for enterprise workflows

**The architecture expands:**
```
┌─────────────────────────────────────────────────────────────┐
│                    Part 2: Server Security                  │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  User & Role Management                            │   │
│  │  - User CRUD operations                           │   │
│  │  - Role assignment                                │   │
│  │  - Permission checking                            │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    Part 3: Multi-Tenant SaaS               │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Organizations & Teams                             │   │
│  │  - Tenant isolation                               │   │
│  │  - Organization management                        │   │
│  │  - Team invitations                               │   │
│  │  - Organization switcher                          │   │
│  │  - RBAC with org roles                            │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

**Ready to build multi-tenant SaaS architecture?** Proceed to Part 3, where we'll add organizations, teams, and enterprise-grade authorization.
