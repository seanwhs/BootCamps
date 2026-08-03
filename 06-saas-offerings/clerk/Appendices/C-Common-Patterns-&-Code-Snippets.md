# Appendix C: Common Patterns & Code Snippets

## Reusable Authentication Patterns for Production Applications

This appendix provides a comprehensive collection of reusable code patterns, snippets, and best practices for common authentication scenarios with Clerk. Use these as building blocks for your own applications.

---

## C.1 User Management Patterns

### Pattern: Get User with Fallback

```typescript
// lib/user.ts
// Get user with fallback for unauthenticated users

import { currentUser } from "@clerk/nextjs/server";

export async function getUserWithFallback() {
  try {
    const user = await currentUser();
    
    if (!user) {
      return {
        id: null,
        email: null,
        name: "Guest",
        role: "guest",
        isAuthenticated: false,
      };
    }
    
    return {
      id: user.id,
      email: user.emailAddresses[0]?.emailAddress || null,
      name: user.fullName || user.username || "User",
      role: user.publicMetadata?.role || "guest",
      isAuthenticated: true,
      avatar: user.imageUrl,
      createdAt: user.createdAt,
    };
  } catch (error) {
    console.error("Error fetching user:", error);
    return {
      id: null,
      email: null,
      name: "Guest",
      role: "guest",
      isAuthenticated: false,
    };
  }
}
```

### Pattern: User Context Provider

```tsx
// components/providers/UserContext.tsx
// React context for user data

"use client";

import { createContext, useContext, useEffect, useState } from "react";
import { useUser } from "@clerk/nextjs";

interface UserContextType {
  user: any | null;
  isLoading: boolean;
  isAuthenticated: boolean;
  refreshUser: () => Promise<void>;
}

const UserContext = createContext<UserContextType>({
  user: null,
  isLoading: true,
  isAuthenticated: false,
  refreshUser: async () => {},
});

export function UserProvider({ children }: { children: React.ReactNode }) {
  const { user, isLoaded, isSignedIn } = useUser();
  const [isLoading, setIsLoading] = useState(true);
  
  useEffect(() => {
    if (isLoaded) {
      setIsLoading(false);
    }
  }, [isLoaded]);
  
  const refreshUser = async () => {
    setIsLoading(true);
    // Force refresh user data
    await user?.reload();
    setIsLoading(false);
  };
  
  return (
    <UserContext.Provider
      value={{
        user,
        isLoading,
        isAuthenticated: isSignedIn || false,
        refreshUser,
      }}
    >
      {children}
    </UserContext.Provider>
  );
}

export function useUserContext() {
  const context = useContext(UserContext);
  if (!context) {
    throw new Error("useUserContext must be used within a UserProvider");
  }
  return context;
}
```

### Pattern: Update User Metadata

```typescript
// lib/user-metadata.ts
// Utilities for managing user metadata

import { clerkClient } from "@clerk/nextjs/server";

export async function updateUserMetadata(
  userId: string,
  metadata: {
    public?: Record<string, any>;
    private?: Record<string, any>;
    unsafe?: Record<string, any>;
  }
) {
  try {
    const updates: any = {};
    
    if (metadata.public) {
      updates.publicMetadata = metadata.public;
    }
    if (metadata.private) {
      updates.privateMetadata = metadata.private;
    }
    if (metadata.unsafe) {
      updates.unsafeMetadata = metadata.unsafe;
    }
    
    const updatedUser = await clerkClient().users.updateUser(userId, updates);
    return updatedUser;
  } catch (error) {
    console.error("Failed to update user metadata:", error);
    throw new Error("Could not update user metadata");
  }
}

// Example: Update user preferences
export async function updateUserPreferences(
  userId: string,
  preferences: Record<string, any>
) {
  const user = await clerkClient().users.getUser(userId);
  
  return updateUserMetadata(userId, {
    public: {
      ...user.publicMetadata,
      preferences: {
        ...(user.publicMetadata?.preferences as Record<string, any> || {}),
        ...preferences,
      },
    },
  });
}
```

---

## C.2 Organization Management Patterns

### Pattern: Organization Membership Check

```typescript
// lib/org-check.ts
// Check if user is a member of an organization

import { clerkClient } from "@clerk/nextjs/server";

export async function isMemberOfOrganization(
  userId: string,
  orgId: string
): Promise<boolean> {
  try {
    const memberships = await clerkClient().organizations.getOrganizationMembershipList({
      organizationId: orgId,
      userId,
    });
    
    return memberships.data.length > 0;
  } catch (error) {
    console.error("Error checking organization membership:", error);
    return false;
  }
}

export async function getUserRoleInOrganization(
  userId: string,
  orgId: string
): Promise<string | null> {
  try {
    const memberships = await clerkClient().organizations.getOrganizationMembershipList({
      organizationId: orgId,
      userId,
    });
    
    if (memberships.data.length === 0) {
      return null;
    }
    
    return memberships.data[0].role;
  } catch (error) {
    console.error("Error getting user role:", error);
    return null;
  }
}
```

### Pattern: Organization Switcher with Custom UI

```tsx
// components/OrganizationSwitcher.tsx
// Custom organization switcher component

"use client";

import { useState } from "react";
import { useOrganization, useOrganizationList } from "@clerk/nextjs";
import Link from "next/link";

export function OrganizationSwitcher() {
  const { organization, isLoaded: orgLoaded } = useOrganization();
  const { userMemberships, isLoaded: listLoaded } = useOrganizationList({
    userMemberships: true,
  });
  
  const [isOpen, setIsOpen] = useState(false);
  
  if (!orgLoaded || !listLoaded) {
    return <div className="w-32 h-8 bg-gray-200 animate-pulse rounded"></div>;
  }
  
  const organizations = userMemberships?.data || [];
  
  return (
    <div className="relative">
      {/* Current Organization Button */}
      <button
        onClick={() => setIsOpen(!isOpen)}
        className="flex items-center space-x-2 px-3 py-2 border border-gray-300 rounded-md hover:bg-gray-50 transition-colors"
      >
        {organization?.imageUrl ? (
          <img
            src={organization.imageUrl}
            alt={organization.name}
            className="w-6 h-6 rounded-full"
          />
        ) : (
          <div className="w-6 h-6 rounded-full bg-indigo-100 flex items-center justify-center">
            <span className="text-indigo-600 text-sm font-medium">
              {organization?.name?.[0]?.toUpperCase() || "?"}
            </span>
          </div>
        )}
        <span className="text-sm font-medium text-gray-700">
          {organization?.name || "Select Organization"}
        </span>
        <svg
          className={`w-4 h-4 transition-transform ${isOpen ? "rotate-180" : ""}`}
          fill="none"
          stroke="currentColor"
          viewBox="0 0 24 24"
        >
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 9l-7 7-7-7" />
        </svg>
      </button>
      
      {/* Dropdown */}
      {isOpen && (
        <div className="absolute top-full left-0 mt-2 w-64 bg-white border border-gray-200 rounded-md shadow-lg z-50">
          <div className="p-2">
            <p className="text-xs text-gray-500 px-3 py-1">Switch Organization</p>
            
            {organizations.map((membership) => (
              <Link
                key={membership.organization.id}
                href={`/organization/${membership.organization.id}`}
                className={`flex items-center space-x-2 px-3 py-2 rounded-md hover:bg-gray-50 transition-colors ${
                  membership.organization.id === organization?.id
                    ? "bg-indigo-50"
                    : ""
                }`}
                onClick={() => setIsOpen(false)}
              >
                {membership.organization.imageUrl ? (
                  <img
                    src={membership.organization.imageUrl}
                    alt={membership.organization.name}
                    className="w-6 h-6 rounded-full"
                  />
                ) : (
                  <div className="w-6 h-6 rounded-full bg-gray-100 flex items-center justify-center">
                    <span className="text-gray-600 text-sm font-medium">
                      {membership.organization.name?.[0]?.toUpperCase() || "?"}
                    </span>
                  </div>
                )}
                <div className="flex-1">
                  <p className="text-sm text-gray-700">
                    {membership.organization.name}
                  </p>
                  <p className="text-xs text-gray-400 capitalize">
                    {membership.role}
                  </p>
                </div>
                {membership.organization.id === organization?.id && (
                  <svg className="w-4 h-4 text-indigo-600" fill="currentColor" viewBox="0 0 20 20">
                    <path fillRule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clipRule="evenodd" />
                  </svg>
                )}
              </Link>
            ))}
            
            <div className="border-t border-gray-100 mt-2 pt-2">
              <Link
                href="/organization/create"
                className="flex items-center space-x-2 px-3 py-2 text-sm text-indigo-600 hover:bg-indigo-50 rounded-md transition-colors"
                onClick={() => setIsOpen(false)}
              >
                <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 4v16m8-8H4" />
                </svg>
                <span>Create Organization</span>
              </Link>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
```

### Pattern: Invite User to Organization

```typescript
// lib/org-invites.ts
// Organization invitation utilities

import { clerkClient } from "@clerk/nextjs/server";

interface InviteUserOptions {
  orgId: string;
  email: string;
  role: "admin" | "moderator" | "member" | "guest";
  inviterId: string;
  message?: string;
}

export async function inviteUserToOrganization(options: InviteUserOptions) {
  try {
    const invitation = await clerkClient().organizations.createOrganizationInvitation({
      organizationId: options.orgId,
      emailAddress: options.email,
      role: options.role,
      inviterUserId: options.inviterId,
      publicMetadata: {
        message: options.message || "You've been invited to join our organization!",
        invitedAt: new Date().toISOString(),
        invitedBy: options.inviterId,
      },
    });
    
    return {
      success: true,
      invitation,
      message: `Invitation sent to ${options.email}`,
    };
  } catch (error: any) {
    console.error("Failed to send invitation:", error);
    
    // Handle common errors
    if (error.message?.includes("User already has a pending invitation")) {
      return {
        success: false,
        error: "This user already has a pending invitation",
      };
    }
    
    if (error.message?.includes("User is already a member")) {
      return {
        success: false,
        error: "This user is already a member of the organization",
      };
    }
    
    return {
      success: false,
      error: "Failed to send invitation. Please try again.",
    };
  }
}

export async function acceptOrganizationInvitation(invitationId: string, userId: string) {
  try {
    const membership = await clerkClient().organizations.acceptOrganizationInvitation({
      invitationId,
      userId,
    });
    
    return {
      success: true,
      membership,
      message: "You've successfully joined the organization!",
    };
  } catch (error) {
    console.error("Failed to accept invitation:", error);
    return {
      success: false,
      error: "Failed to accept invitation. Please try again.",
    };
  }
}
```

---

## C.3 API Protection Patterns

### Pattern: API Route with Authentication

```typescript
// app/api/protected/route.ts
// API route with authentication and role checking

import { NextRequest, NextResponse } from "next/server";
import { auth, clerkClient } from "@clerk/nextjs/server";

export async function GET(request: NextRequest) {
  try {
    // Check authentication
    const { userId } = await auth();
    
    if (!userId) {
      return NextResponse.json(
        { error: "Authentication required" },
        { status: 401 }
      );
    }
    
    // Check role (optional)
    const user = await clerkClient().users.getUser(userId);
    const role = user.publicMetadata?.role as string || "guest";
    
    if (role !== "admin") {
      return NextResponse.json(
        { error: "Admin access required" },
        { status: 403 }
      );
    }
    
    // Process request
    const data = await getProtectedData();
    
    return NextResponse.json({
      success: true,
      data,
      user: {
        id: userId,
        role,
      },
    });
  } catch (error) {
    console.error("API Error:", error);
    return NextResponse.json(
      { error: "Internal server error" },
      { status: 500 }
    );
  }
}
```

### Pattern: API Middleware with Authentication

```typescript
// lib/api-middleware.ts
// Reusable API middleware with authentication

import { NextRequest, NextResponse } from "next/server";
import { auth } from "@clerk/nextjs/server";
import { rateLimit } from "./rate-limit";

type ApiHandler = (request: NextRequest, context: any) => Promise<NextResponse>;

interface ApiMiddlewareOptions {
  requireAuth?: boolean;
  requireRole?: string;
  rateLimit?: {
    windowMs: number;
    maxRequests: number;
  };
}

export function withApiMiddleware(
  handler: ApiHandler,
  options: ApiMiddlewareOptions = {}
) {
  return async (request: NextRequest, context: any) => {
    try {
      // 1. Rate limiting
      if (options.rateLimit) {
        const ip = request.headers.get("x-forwarded-for") || "unknown";
        const limiter = rateLimit(options.rateLimit);
        const result = limiter(ip);
        
        if (!result.allowed) {
          return NextResponse.json(
            { error: "Too many requests" },
            {
              status: 429,
              headers: {
                "Retry-After": Math.ceil((result.resetTime - Date.now()) / 1000).toString(),
                "X-RateLimit-Limit": options.rateLimit.maxRequests.toString(),
                "X-RateLimit-Remaining": result.remaining.toString(),
                "X-RateLimit-Reset": result.resetTime.toString(),
              },
            }
          );
        }
      }
      
      // 2. Authentication
      if (options.requireAuth) {
        const { userId } = await auth();
        
        if (!userId) {
          return NextResponse.json(
            { error: "Authentication required" },
            { status: 401 }
          );
        }
        
        // 3. Role checking
        if (options.requireRole) {
          const user = await clerkClient().users.getUser(userId);
          const role = user.publicMetadata?.role as string || "guest";
          
          if (role !== options.requireRole) {
            return NextResponse.json(
              { error: "Insufficient permissions" },
              { status: 403 }
            );
          }
        }
      }
      
      // 4. Execute handler
      return await handler(request, context);
    } catch (error) {
      console.error("API Middleware Error:", error);
      return NextResponse.json(
        { error: "Internal server error" },
        { status: 500 }
      );
    }
  };
}

// Usage:
// export const GET = withApiMiddleware(
//   async (request) => {
//     const data = await fetchData();
//     return NextResponse.json({ data });
//   },
//   { requireAuth: true, requireRole: "admin" }
// );
```

---

## C.4 Client Component Patterns

### Pattern: Protected Client Component

```tsx
// components/ProtectedComponent.tsx
// Client component with authentication check

"use client";

import { useUser } from "@clerk/nextjs";
import { useRouter } from "next/navigation";
import { useEffect, useState } from "react";

interface ProtectedComponentProps {
  children: React.ReactNode;
  fallback?: React.ReactNode;
  redirectTo?: string;
  requireRole?: string;
}

export function ProtectedComponent({
  children,
  fallback,
  redirectTo = "/sign-in",
  requireRole,
}: ProtectedComponentProps) {
  const { isLoaded, isSignedIn, user } = useUser();
  const router = useRouter();
  const [isAuthorized, setIsAuthorized] = useState(false);
  
  useEffect(() => {
    if (!isLoaded) return;
    
    if (!isSignedIn) {
      router.push(redirectTo);
      return;
    }
    
    if (requireRole) {
      const role = user?.publicMetadata?.role as string || "guest";
      setIsAuthorized(role === requireRole);
      
      if (role !== requireRole) {
        router.push("/dashboard?error=access_denied");
        return;
      }
    }
    
    setIsAuthorized(true);
  }, [isLoaded, isSignedIn, user, router, redirectTo, requireRole]);
  
  if (!isLoaded) {
    return fallback || <div>Loading...</div>;
  }
  
  if (!isSignedIn || !isAuthorized) {
    return null;
  }
  
  return <>{children}</>;
}
```

### Pattern: With Authentication HOC

```tsx
// components/hocs/withAuth.tsx
// Higher-order component for authentication

"use client";

import { useUser } from "@clerk/nextjs";
import { useRouter } from "next/navigation";
import { useEffect } from "react";

interface WithAuthOptions {
  redirectTo?: string;
  requireRole?: string;
}

export function withAuth<P extends object>(
  Component: React.ComponentType<P>,
  options: WithAuthOptions = {}
) {
  return function AuthenticatedComponent(props: P) {
    const { isLoaded, isSignedIn, user } = useUser();
    const router = useRouter();
    const { redirectTo = "/sign-in", requireRole } = options;
    
    useEffect(() => {
      if (!isLoaded) return;
      
      if (!isSignedIn) {
        router.push(redirectTo);
        return;
      }
      
      if (requireRole) {
        const role = user?.publicMetadata?.role as string || "guest";
        if (role !== requireRole) {
          router.push("/dashboard?error=access_denied");
          return;
        }
      }
    }, [isLoaded, isSignedIn, user, router, redirectTo, requireRole]);
    
    if (!isLoaded) {
      return <div>Loading...</div>;
    }
    
    if (!isSignedIn) {
      return null;
    }
    
    if (requireRole) {
      const role = user?.publicMetadata?.role as string || "guest";
      if (role !== requireRole) {
        return null;
      }
    }
    
    return <Component {...props} />;
  };
}

// Usage:
// const AdminDashboard = withAuth(Dashboard, { requireRole: "admin" });
// export default function Page() {
//   return <AdminDashboard />;
// }
```

### Pattern: Real-time Authentication Status

```tsx
// components/AuthStatus.tsx
// Real-time authentication status indicator

"use client";

import { useUser, useSession } from "@clerk/nextjs";

export function AuthStatus() {
  const { isLoaded, isSignedIn, user } = useUser();
  const { session } = useSession();
  
  if (!isLoaded) {
    return (
      <div className="flex items-center space-x-2">
        <div className="w-2 h-2 bg-gray-400 rounded-full animate-pulse"></div>
        <span className="text-sm text-gray-400">Checking...</span>
      </div>
    );
  }
  
  if (!isSignedIn) {
    return (
      <div className="flex items-center space-x-2">
        <div className="w-2 h-2 bg-red-400 rounded-full"></div>
        <span className="text-sm text-gray-600">Not signed in</span>
      </div>
    );
  }
  
  const role = user.publicMetadata?.role as string || "guest";
  const sessionExpiry = session?.expiresAt 
    ? new Date(session.expiresAt) 
    : null;
  
  return (
    <div className="flex items-center space-x-4">
      <div className="flex items-center space-x-2">
        <div className="w-2 h-2 bg-green-400 rounded-full animate-pulse"></div>
        <span className="text-sm text-gray-600">
          Signed in as {user.fullName || user.username || "User"}
        </span>
      </div>
      <div className="text-xs text-gray-400">
        Role: <span className="capitalize">{role}</span>
      </div>
      {sessionExpiry && (
        <div className="text-xs text-gray-400">
          Session: {sessionExpiry.toLocaleTimeString()}
        </div>
      )}
    </div>
  );
}
```

---

## C.5 Webhook Patterns

### Pattern: Process Webhook with Retries

```typescript
// lib/webhook-processor.ts
// Webhook processing with retry logic

import { logAuthEvent } from "./auth-helpers";

interface WebhookEvent {
  type: string;
  data: any;
}

export async function processWebhookWithRetry(
  event: WebhookEvent,
  maxRetries: number = 3
): Promise<{ success: boolean; error?: string }> {
  let lastError: Error | null = null;
  
  for (let attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      await processWebhookEvent(event);
      
      // Log success
      await logAuthEvent(null, "webhook_processed", {
        eventType: event.type,
        attempt,
        success: true,
      });
      
      return { success: true };
    } catch (error) {
      lastError = error as Error;
      
      // Log failure
      await logAuthEvent(null, "webhook_failed", {
        eventType: event.type,
        attempt,
        error: lastError.message,
      });
      
      // Exponential backoff
      if (attempt < maxRetries) {
        const delay = Math.pow(2, attempt) * 1000; // 2s, 4s, 8s
        await new Promise(resolve => setTimeout(resolve, delay));
      }
    }
  }
  
  return {
    success: false,
    error: lastError?.message || "Failed to process webhook after retries",
  };
}

async function processWebhookEvent(event: WebhookEvent) {
  // Process event based on type
  switch (event.type) {
    case "user.created":
      await handleUserCreated(event.data);
      break;
    case "user.updated":
      await handleUserUpdated(event.data);
      break;
    case "user.deleted":
      await handleUserDeleted(event.data);
      break;
    default:
      throw new Error(`Unsupported event type: ${event.type}`);
  }
}
```

### Pattern: Webhook Signature Validation

```typescript
// lib/webhook-signature.ts
// Webhook signature validation

import { Webhook } from "svix";

export function validateWebhookSignature(
  payload: string,
  headers: Record<string, string>,
  secret: string
): boolean {
  try {
    const webhook = new Webhook(secret);
    
    const verified = webhook.verify(payload, {
      "svix-id": headers["svix-id"] || "",
      "svix-timestamp": headers["svix-timestamp"] || "",
      "svix-signature": headers["svix-signature"] || "",
    });
    
    return !!verified;
  } catch (error) {
    console.error("Webhook signature validation failed:", error);
    return false;
  }
}
```

---

## C.6 Performance Patterns

### Pattern: Debounced User Search

```tsx
// components/UserSearch.tsx
// Debounced search input for user search

"use client";

import { useState, useCallback, useMemo } from "react";
import { useDebounce } from "@/hooks/useDebounce";

interface User {
  id: string;
  name: string;
  email: string;
}

export function UserSearch() {
  const [query, setQuery] = useState("");
  const [results, setResults] = useState<User[]>([]);
  const [isLoading, setIsLoading] = useState(false);
  const debouncedQuery = useDebounce(query, 300);
  
  const searchUsers = useCallback(async (searchQuery: string) => {
    if (!searchQuery.trim()) {
      setResults([]);
      return;
    }
    
    setIsLoading(true);
    
    try {
      const response = await fetch(`/api/users/search?q=${encodeURIComponent(searchQuery)}`);
      const data = await response.json();
      setResults(data.users || []);
    } catch (error) {
      console.error("Error searching users:", error);
    } finally {
      setIsLoading(false);
    }
  }, []);
  
  // Trigger search when debounced query changes
  useMemo(() => {
    searchUsers(debouncedQuery);
  }, [debouncedQuery, searchUsers]);
  
  return (
    <div className="relative">
      <input
        type="text"
        value={query}
        onChange={(e) => setQuery(e.target.value)}
        placeholder="Search users..."
        className="w-full border border-gray-300 rounded-md px-3 py-2 focus:ring-indigo-500 focus:border-indigo-500"
      />
      
      {isLoading && (
        <div className="absolute right-3 top-2.5">
          <div className="animate-spin h-5 w-5 border-2 border-indigo-500 border-t-transparent rounded-full"></div>
        </div>
      )}
      
      {results.length > 0 && (
        <div className="absolute top-full left-0 right-0 mt-1 bg-white border border-gray-200 rounded-md shadow-lg z-10 max-h-60 overflow-auto">
          {results.map((user) => (
            <div
              key={user.id}
              className="px-3 py-2 hover:bg-gray-50 cursor-pointer"
            >
              <p className="text-sm font-medium">{user.name}</p>
              <p className="text-xs text-gray-500">{user.email}</p>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
```

**File:** `hooks/useDebounce.ts`

```typescript
// hooks/useDebounce.ts
// Debounce hook for performance

import { useState, useEffect } from "react";

export function useDebounce<T>(value: T, delay: number): T {
  const [debouncedValue, setDebouncedValue] = useState<T>(value);
  
  useEffect(() => {
    const handler = setTimeout(() => {
      setDebouncedValue(value);
    }, delay);
    
    return () => {
      clearTimeout(handler);
    };
  }, [value, delay]);
  
  return debouncedValue;
}
```

---

## C.7 Error Handling Patterns

### Pattern: Global Error Boundary for Auth

```tsx
// components/ErrorBoundary.tsx
// Error boundary with authentication-specific handling

"use client";

import { Component, ErrorInfo, ReactNode } from "react";
import { useRouter } from "next/navigation";

interface ErrorBoundaryProps {
  children: ReactNode;
  fallback?: ReactNode;
}

interface ErrorBoundaryState {
  hasError: boolean;
  error: Error | null;
}

export class ErrorBoundary extends Component<ErrorBoundaryProps, ErrorBoundaryState> {
  constructor(props: ErrorBoundaryProps) {
    super(props);
    this.state = { hasError: false, error: null };
  }
  
  static getDerivedStateFromError(error: Error): ErrorBoundaryState {
    return { hasError: true, error };
  }
  
  componentDidCatch(error: Error, errorInfo: ErrorInfo) {
    console.error("Error caught by boundary:", error, errorInfo);
    
    // Check if it's an authentication error
    if (error.message.includes("auth") || error.message.includes("authentication")) {
      // Redirect to sign-in (but we need router, so we'll handle in componentDidCatch with a flag)
      this.setState({ hasError: true, error });
    }
  }
  
  render() {
    if (this.state.hasError) {
      return this.props.fallback || <FallbackError error={this.state.error} />;
    }
    
    return this.props.children;
  }
}

function FallbackError({ error }: { error: Error | null }) {
  const router = useRouter();
  
  const handleRetry = () => {
    window.location.reload();
  };
  
  const handleSignOut = async () => {
    // Sign out and redirect to home
    router.push("/sign-out");
  };
  
  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-50">
      <div className="max-w-md w-full bg-white rounded-lg shadow-sm p-8 text-center">
        <div className="text-6xl mb-4">😅</div>
        <h2 className="text-2xl font-bold text-gray-900 mb-2">
          Something went wrong
        </h2>
        <p className="text-gray-600 mb-6">
          {error?.message || "An unexpected error occurred"}
        </p>
        <div className="flex space-x-4 justify-center">
          <button
            onClick={handleRetry}
            className="bg-indigo-600 text-white px-4 py-2 rounded-md hover:bg-indigo-700 transition-colors"
          >
            Try again
          </button>
          <button
            onClick={handleSignOut}
            className="border border-gray-300 text-gray-700 px-4 py-2 rounded-md hover:bg-gray-50 transition-colors"
          >
            Sign out
          </button>
        </div>
      </div>
    </div>
  );
}
```

### Pattern: API Error Handling with Custom Types

```typescript
// lib/api-errors.ts
// Custom API error types

export class ApiError extends Error {
  status: number;
  code: string;
  
  constructor(message: string, status: number, code: string) {
    super(message);
    this.status = status;
    this.code = code;
    this.name = "ApiError";
  }
  
  static unauthorized(message = "Authentication required") {
    return new ApiError(message, 401, "UNAUTHORIZED");
  }
  
  static forbidden(message = "Access denied") {
    return new ApiError(message, 403, "FORBIDDEN");
  }
  
  static notFound(message = "Resource not found") {
    return new ApiError(message, 404, "NOT_FOUND");
  }
  
  static validationFailed(message = "Validation failed", details?: any) {
    const error = new ApiError(message, 400, "VALIDATION_FAILED");
    (error as any).details = details;
    return error;
  }
  
  static internal(message = "Internal server error") {
    return new ApiError(message, 500, "INTERNAL_ERROR");
  }
  
  toResponse() {
    return {
      error: {
        code: this.code,
        message: this.message,
        status: this.status,
        ...((this as any).details && { details: (this as any).details }),
      },
    };
  }
}

// Usage in API route:
// try {
//   if (!userId) throw ApiError.unauthorized();
//   if (role !== "admin") throw ApiError.forbidden("Admin access required");
//   // ...
// } catch (error) {
//   if (error instanceof ApiError) {
//     return NextResponse.json(error.toResponse(), { status: error.status });
//   }
//   throw error;
// }
```

---

## C.8 Email & Notification Patterns

### Pattern: Send Email with Clerk User Data

```typescript
// lib/email.ts
// Email utilities with Clerk user data

import { clerkClient } from "@clerk/nextjs/server";

interface SendEmailOptions {
  to: string;
  subject: string;
  template: string;
  data: Record<string, any>;
}

export async function sendEmailToUser(
  userId: string,
  options: Omit<SendEmailOptions, "to" | "data">
) {
  try {
    const user = await clerkClient().users.getUser(userId);
    const email = user.emailAddresses[0]?.emailAddress;
    
    if (!email) {
      throw new Error("User has no email address");
    }
    
    return sendEmail({
      to: email,
      subject: options.subject,
      template: options.template,
      data: {
        userName: user.fullName || user.username || "User",
        userEmail: email,
        ...options.data,
      },
    });
  } catch (error) {
    console.error("Failed to send email:", error);
    throw error;
  }
}

async function sendEmail(options: SendEmailOptions) {
  // Implementation using SendGrid, Resend, etc.
  console.log("Sending email:", options);
  // Return success
  return { success: true };
}

// Example: Send welcome email
export async function sendWelcomeEmail(userId: string) {
  return sendEmailToUser(userId, {
    subject: "Welcome to our platform!",
    template: "welcome",
    data: {
      // Additional data for the template
      welcomeMessage: "We're excited to have you!",
    },
  });
}
```

---

## C.9 Testing Patterns

### Pattern: Mock Clerk for Testing

```typescript
// tests/mocks/clerk.ts
// Clerk mocks for testing

export const mockUser = {
  id: "user_test_123",
  emailAddresses: [{ emailAddress: "test@example.com", verification: { status: "verified" } }],
  fullName: "Test User",
  username: "testuser",
  imageUrl: "https://example.com/avatar.jpg",
  publicMetadata: { role: "admin" },
  privateMetadata: {},
  createdAt: new Date().toISOString(),
  lastSignInAt: new Date().toISOString(),
};

export const mockSession = {
  id: "sess_test_123",
  userId: "user_test_123",
  status: "active",
  expiresAt: new Date(Date.now() + 3600000).toISOString(),
  lastActiveAt: new Date().toISOString(),
};

export const mockAuth = {
  userId: "user_test_123",
  sessionId: "sess_test_123",
  orgId: null,
};

export function createMockClerk() {
  return {
    users: {
      getUser: jest.fn().mockResolvedValue(mockUser),
      getUserList: jest.fn().mockResolvedValue({ data: [mockUser] }),
      updateUser: jest.fn().mockResolvedValue(mockUser),
      deleteUser: jest.fn().mockResolvedValue(undefined),
    },
    organizations: {
      getOrganization: jest.fn().mockResolvedValue({
        id: "org_test_123",
        name: "Test Org",
        slug: "test-org",
      }),
      getOrganizationMembershipList: jest.fn().mockResolvedValue({
        data: [{ role: "admin" }],
      }),
    },
    sessions: {
      getSession: jest.fn().mockResolvedValue(mockSession),
    },
  };
}

// Usage in tests:
// import { createMockClerk } from "@/tests/mocks/clerk";
// jest.mock("@clerk/nextjs/server", () => ({
//   clerkClient: () => createMockClerk(),
//   auth: () => Promise.resolve({ userId: "user_test_123" }),
// }));
```
