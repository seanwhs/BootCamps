# Primer 11: Clerk Performance Optimization

## Building Fast, Scalable Authentication

Welcome to the eleventh primer in the Clerk Mastery Series. This primer provides a comprehensive guide to optimizing Clerk's performance in your applications — ensuring fast authentication checks, minimal latency, and efficient resource usage at scale.

---

## Performance Fundamentals

### The Performance Equation

Authentication performance is measured by:

```
Total Latency = Client Request Time + Clerk API Time + Your Server Processing + Network Roundtrip
```

| Component | Typical Time | Optimization |
|-----------|--------------|--------------|
| **Client Request** | 50-200ms | Use SSR, preload auth state |
| **Clerk API** | 100-500ms | Use caching, edge functions |
| **Your Server** | 50-300ms | Optimize database queries, use caching |
| **Network** | 50-200ms | Use CDN, regional deployment |

### The 100ms Goal

For optimal user experience, authentication checks should complete in under 100ms:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    Performance Targets                                     │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  Authentication Check < 100ms                                      │   │
│  │  ──────────────────────────────────────────────────────────         │   │
│  │  Fast enough that users don't notice waiting                     │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  Token Refresh < 50ms                                              │   │
│  │  ──────────────────────────────────────────────────────────         │   │
│  │  Background refresh without user impact                           │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  Page Load < 200ms                                                 │   │
│  │  ──────────────────────────────────────────────────────────         │   │
│  │  Includes auth check + content rendering                          │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Server-Side Optimization

### 1. Use React's `cache()` Function

The `cache()` function deduplicates authentication calls across Server Components:

```typescript
// lib/auth-helpers.ts
import { cache } from "react";
import { auth, currentUser } from "@clerk/nextjs/server";

// ✅ Cached auth check - prevents duplicate calls
export const getAuth = cache(async () => {
  const { userId, sessionId, orgId } = await auth();
  return { userId, sessionId, orgId };
});

// ✅ Cached currentUser - prevents duplicate API calls
export const getCurrentUser = cache(async () => {
  const user = await currentUser();
  return user;
});

// ❌ Without cache - multiple calls may happen in the same request
export async function getAuthUncached() {
  return await auth();
}
```

**Why this matters:**
- Without `cache()`, each Server Component calls `auth()` separately
- With `cache()`, all components share the same result
- Reduces Clerk API calls and improves performance

### 2. Use `getToken()` for Lightweight Checks

For simple authentication checks, use `getToken()` instead of full user data:

```typescript
// ✅ Lightweight - only validates the token
export async function isAuthenticated() {
  const token = await getToken();
  return !!token;
}

// ❌ Heavy - fetches full user data
export async function isAuthenticatedHeavy() {
  const user = await currentUser();
  return !!user;
}
```

### 3. Select Only Needed Fields

```typescript
// ✅ Efficient - only fetch what you need
export async function getCurrentUserLight() {
  const user = await currentUser();
  
  // Return only essential data
  return {
    id: user?.id,
    email: user?.emailAddresses[0]?.emailAddress,
    name: user?.fullName,
    role: user?.publicMetadata?.role,
  };
}

// ❌ Inefficient - returns unnecessary data
export async function getCurrentUserHeavy() {
  const user = await currentUser(); // Returns everything
  return user; // All fields included
}
```

### 4. Add Database Indexes

```sql
-- For efficient user lookup
CREATE INDEX idx_users_clerk_id ON users(clerk_id);
CREATE INDEX idx_users_email ON users(email);

-- For organization queries
CREATE INDEX idx_projects_org_id ON projects(organization_id);
CREATE INDEX idx_projects_owner_id ON projects(owner_id);

-- For audit queries
CREATE INDEX idx_audit_logs_user_id ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_created_at ON audit_logs(created_at);
```

---

## Client-Side Optimization

### 1. Defer Non-Critical Auth Operations

```typescript
// app/components/Dashboard.tsx
"use client";

import { useUser } from "@clerk/nextjs";
import { lazy, Suspense } from "react";

// Lazy load heavy components that depend on auth
const AnalyticsDashboard = lazy(() => import("./AnalyticsDashboard"));

export function Dashboard() {
  const { isLoaded, isSignedIn, user } = useUser();
  
  // Show auth checks first, defer heavy components
  if (!isLoaded) {
    return <LoadingSpinner />;
  }
  
  if (!isSignedIn) {
    return <SignInPrompt />;
  }
  
  return (
    <div>
      <QuickStats user={user} /> {/* Lightweight */}
      
      <Suspense fallback={<AnalyticsSkeleton />}>
        <AnalyticsDashboard userId={user.id} /> {/* Heavy */}
      </Suspense>
    </div>
  );
}
```

### 2. Memoize Auth-Dependent Components

```typescript
"use client";

import { memo, useMemo } from "react";
import { useUser } from "@clerk/nextjs";

// ✅ Memoized to prevent unnecessary re-renders
const UserProfile = memo(({ user }: { user: any }) => {
  // Only re-renders when user data changes
  return <div>{user.fullName}</div>;
});

// ✅ useMemo for derived data
export function DashboardStats() {
  const { user } = useUser();
  
  const stats = useMemo(() => {
    // Expensive calculation only runs when user changes
    return calculateStats(user);
  }, [user]);
  
  return <StatsDisplay stats={stats} />;
}
```

### 3. Use SWR for Caching

```typescript
// lib/hooks/use-cached-user.ts
import useSWR from "swr";

export function useCachedUser(userId: string) {
  const { data, error, mutate } = useSWR(
    `/api/users/${userId}`,
    fetcher,
    {
      revalidateOnFocus: false,
      revalidateOnReconnect: false,
      refreshInterval: 300000, // 5 minutes
      dedupingInterval: 60000, // 1 minute
    }
  );
  
  return {
    user: data,
    isLoading: !error && !data,
    isError: error,
    mutate,
  };
}
```

---

## Middleware Optimization

### 1. Exclude Static Assets

```typescript
// middleware.ts
export const config = {
  matcher: [
    // Skip Next.js internals and all static files
    "/((?!_next|[^?]*\\.(?:html?|css|js(?!on)|jpe?g|webp|png|gif|svg|ttf|woff2?|ico|csv|docx?|xlsx?|zip|webmanifest)).*)",
    // Always run for API routes
    "/(api|trpc)(.*)",
  ],
};
```

### 2. Early Return for Public Routes

```typescript
// middleware.ts
import { clerkMiddleware, createRouteMatcher } from "@clerk/nextjs/server";

const isPublicRoute = createRouteMatcher([
  "/",
  "/about",
  "/sign-in(.*)",
  "/sign-up(.*)",
  "/api/webhooks(.*)",
]);

export default clerkMiddleware((auth, req) => {
  // ✅ Early return for public routes - skip auth checks
  if (isPublicRoute(req)) {
    return NextResponse.next();
  }
  
  // Auth checks only for protected routes
  auth().protect();
});
```

### 3. Use Edge Runtime for Middleware

```typescript
// middleware.ts
export const runtime = "edge"; // Runs on Vercel Edge Network

// Edge runtime is faster for auth checks
// Reduces latency by running middleware closer to users
```

---

## API Route Optimization

### 1. Use Caching Headers

```typescript
// app/api/projects/route.ts
import { NextResponse } from "next/server";
import prisma from "@/lib/db";

export async function GET(request: Request) {
  const projects = await prisma.project.findMany();
  
  return NextResponse.json(projects, {
    headers: {
      // ✅ Cache for 60 seconds
      "Cache-Control": "public, s-maxage=60, stale-while-revalidate=300",
      "CDN-Cache-Control": "public, s-maxage=300",
    },
  });
}
```

### 2. Use `unstable_cache` for Server Components

```typescript
// lib/projects.ts
import { unstable_cache } from "next/cache";

export const getCachedProjects = unstable_cache(
  async (orgId: string) => {
    return await prisma.project.findMany({
      where: { organizationId: orgId },
    });
  },
  ["projects"],
  {
    revalidate: 60, // Revalidate every 60 seconds
    tags: ["projects"], // For on-demand revalidation
  }
);
```

### 3. Implement Pagination

```typescript
// app/api/users/route.ts
export async function GET(request: Request) {
  const { searchParams } = new URL(request.url);
  const page = parseInt(searchParams.get("page") || "1");
  const limit = parseInt(searchParams.get("limit") || "20");
  const skip = (page - 1) * limit;
  
  const [users, total] = await Promise.all([
    prisma.user.findMany({
      skip,
      take: limit,
      orderBy: { createdAt: "desc" },
      select: {
        id: true,
        email: true,
        name: true,
        // Only select what's needed
      },
    }),
    prisma.user.count(),
  ]);
  
  return NextResponse.json({
    data: users,
    meta: {
      page,
      limit,
      total,
      totalPages: Math.ceil(total / limit),
    },
  });
}
```

---

## Caching Strategies

### Redis Caching

```typescript
// lib/redis.ts
import Redis from "ioredis";

const redis = new Redis(process.env.REDIS_URL!);

export async function getCachedUser(userId: string) {
  const key = `user:${userId}`;
  
  // Try cache
  const cached = await redis.get(key);
  if (cached) {
    return JSON.parse(cached);
  }
  
  // Fetch from database
  const user = await prisma.user.findUnique({
    where: { clerkId: userId },
  });
  
  // Cache for 5 minutes
  if (user) {
    await redis.setex(key, 300, JSON.stringify(user));
  }
  
  return user;
}
```

### In-Memory Cache

```typescript
// lib/memory-cache.ts
interface CacheEntry<T> {
  data: T;
  expiresAt: number;
}

class MemoryCache {
  private cache = new Map<string, CacheEntry<any>>();
  
  set<T>(key: string, data: T, ttlSeconds: number): void {
    this.cache.set(key, {
      data,
      expiresAt: Date.now() + ttlSeconds * 1000,
    });
  }
  
  get<T>(key: string): T | null {
    const entry = this.cache.get(key);
    
    if (!entry) return null;
    
    if (Date.now() > entry.expiresAt) {
      this.cache.delete(key);
      return null;
    }
    
    return entry.data;
  }
  
  clear(): void {
    this.cache.clear();
  }
}

export const cache = new MemoryCache();

// Usage
export async function getCachedUser(userId: string) {
  const key = `user:${userId}`;
  const cached = cache.get(key);
  
  if (cached) return cached;
  
  const user = await prisma.user.findUnique({
    where: { clerkId: userId },
  });
  
  if (user) {
    cache.set(key, user, 300); // 5 minutes
  }
  
  return user;
}
```

---

## Database Optimization

### 1. Connection Pooling

```typescript
// lib/db.ts
import { PrismaClient } from "@prisma/client";

// Singleton with connection pooling
const globalForPrisma = global as unknown as { prisma: PrismaClient };

export const prisma =
  globalForPrisma.prisma ||
  new PrismaClient({
    log: ["error"],
    // Connection pooling
    connection: {
      pool: {
        max: 20, // Maximum connections
        idle: 5, // Idle connections
        timeout: 30, // Connection timeout in seconds
      },
    },
  });

if (process.env.NODE_ENV !== "production") globalForPrisma.prisma = prisma;
```

### 2. Query Optimization

```typescript
// ✅ Efficient - only what's needed
async function getUser(email: string) {
  return prisma.user.findUnique({
    where: { email },
    select: {
      id: true,
      name: true,
      email: true,
      role: true,
    },
  });
}

// ❌ Inefficient - fetches everything
async function getUserHeavy(email: string) {
  return prisma.user.findUnique({
    where: { email },
    include: {
      projects: true,
      sessions: true,
      auditLogs: true,
    },
  });
}
```

---

## CDN Optimization

### 1. Use CDN for Static Assets

```typescript
// next.config.js
module.exports = {
  images: {
    domains: ['img.clerk.com', 'lh3.googleusercontent.com'],
    loader: 'custom',
    loaderFile: './lib/image-loader.ts',
  },
};

// lib/image-loader.ts
export default function imageLoader({ src, width, quality }: any) {
  // Use Clerk's image optimization CDN
  return `https://img.clerk.com/${src}?w=${width}&q=${quality || 75}`;
}
```

### 2. Use Edge Functions for Auth

```typescript
// middleware.ts - Deploy to Edge Network
export const runtime = "edge";
// Vercel automatically distributes middleware to Edge Network
```

---

## Monitoring Performance

### 1. Track Authentication Latency

```typescript
// lib/monitoring.ts
import { performance } from "perf_hooks";

export async function trackAuthPerformance<T>(
  name: string,
  fn: () => Promise<T>
): Promise<T> {
  const start = performance.now();
  
  try {
    return await fn();
  } finally {
    const duration = performance.now() - start;
    
    // Send to monitoring service
    console.log(`[Auth] ${name}: ${duration.toFixed(2)}ms`);
    
    // In production: send to Datadog, New Relic, etc.
    if (duration > 100) {
      // Slow authentication - log for investigation
      console.warn(`[Auth] Slow operation: ${name} took ${duration.toFixed(2)}ms`);
    }
  }
}

// Usage
const user = await trackAuthPerformance("getCurrentUser", () => currentUser());
```

### 2. Database Query Monitoring

```typescript
// lib/db-monitor.ts
import prisma from "./db";

prisma.$use(async (params, next) => {
  const start = performance.now();
  const result = await next(params);
  const duration = performance.now() - start;
  
  if (duration > 100) {
    console.warn(`[DB] Slow query: ${params.model}.${params.action} took ${duration.toFixed(2)}ms`);
    console.warn(`[DB] Query:`, params.args);
  }
  
  return result;
});
```

---

## Quick Reference: Performance Checklist

| Area | Optimization | Impact |
|------|--------------|--------|
| **Server Components** | Use `cache()` | Reduces duplicate auth calls |
| **Middleware** | Use Edge Runtime | Faster response times |
| **API Routes** | Pagination, caching | Reduces data transfer |
| **Database** | Indexes, connection pooling | Faster queries |
| **Caching** | Redis, CDN | Reduces load on origin |
| **Client** | Memoization, SWR | Reduces re-renders |
| **Monitoring** | Track performance | Identify bottlenecks |

---

## Key Takeaways

1. **Use `cache()` for Server Components** — Prevents duplicate auth calls
2. **Exclude static assets** — Reduces middleware load
3. **Edge Runtime is faster** — Deploy middleware to edge network
4. **Cache aggressively** — Use Redis, CDN, and cache headers
5. **Paginate API responses** — Reduce data transfer
6. **Monitor performance** — Track and optimize bottlenecks
7. **Select only needed fields** — Reduce data fetching

---

## Ready to Implement?

This primer covers performance optimization with Clerk. Now proceed to:

- **Part 5: React 19 & Next.js 16** for modern performance patterns
- **Appendix B: Production Deployment** for deployment optimization
- **Appendix C: Common Patterns & Snippets** for reusable patterns

**Build fast authentication at scale!**
