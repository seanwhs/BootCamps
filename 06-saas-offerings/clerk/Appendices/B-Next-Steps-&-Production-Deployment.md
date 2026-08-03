# Appendix B: Next Steps & Production Deployment

## Taking Your Clerk Application to Production

Congratulations on completing the Clerk Mastery Series! This appendix provides a comprehensive roadmap for taking your application from development to production, including deployment strategies, security hardening, performance optimization, and enterprise features.

---

## B.1 Production Readiness Checklist

Before deploying your Clerk-powered application to production, ensure you've addressed every item on this checklist.

### Clerk Configuration

| Item | Status | Action |
|------|--------|--------|
| Production instance created | [ ] | Create a production instance in Clerk Dashboard |
| Custom domain configured | [ ] | Set up `auth.yourdomain.com` |
| Domain verification complete | [ ] | Add TXT records to your DNS |
| OAuth credentials updated | [ ] | Use production OAuth credentials (Google, GitHub, etc.) |
| Email templates customized | [ ] | Brand all emails with your company |
| Redirect URLs configured | [ ] | Add production URLs to allowed list |
| Webhook endpoints verified | [ ] | Test webhooks in production environment |
| Rate limits configured | [ ] | Set appropriate limits for your user base |

### Security

| Item | Status | Action |
|------|--------|--------|
| Secret keys rotated | [ ] | Generate new secret keys for production |
| Environment variables secured | [ ] | Use secret management (Vercel, AWS Secrets Manager) |
| HTTPS enforced | [ ] | Configure HSTS headers |
| CSP headers configured | [ ] | Set Content Security Policy |
| CORS properly configured | [ ] | Restrict to production domains |
| CSRF protection enabled | [ ] | Verify Clerk's CSRF protection |
| Session timeout configured | [ ] | Set appropriate inactivity timeout |
| Rate limiting enabled | [ ] | Configure API rate limits |
| Audit logging active | [ ] | Verify audit logs are being captured |

### Database

| Item | Status | Action |
|------|--------|--------|
| Production database provisioned | [ ] | Set up PostgreSQL (RDS, Supabase, etc.) |
| Migrations applied | [ ] | Run database migrations |
| Connection pooling configured | [ ] | Set appropriate pool size |
| Backup strategy in place | [ ] | Configure automated backups |
| Read replicas (if needed) | [ ] | Set up for high-traffic apps |
| Monitoring configured | [ ] | Track database performance |

### Application

| Item | Status | Action |
|------|--------|--------|
| Build successful | [ ] | `npm run build` completes without errors |
| TypeScript strict mode | [ ] | Enable `strict: true` in tsconfig |
| Tests passing | [ ] | Run test suite |
| Error tracking configured | [ ] | Set up Sentry, LogRocket, etc. |
| Performance monitoring | [ ] | Configure analytics (Vercel Analytics, etc.) |
| Logging strategy | [ ] | Set up structured logging |
| Health check endpoint | [ ] | Add `/api/health` endpoint |
| Static assets optimized | [ ] | Optimize images, fonts, etc. |
| SEO meta tags | [ ] | Configure metadata for public pages |

### Monitoring & Observability

| Item | Status | Action |
|------|--------|--------|
| Application performance monitoring | [ ] | Set up Datadog, New Relic, etc. |
| Error tracking | [ ] | Configure Sentry or similar |
| Log aggregation | [ ] | Set up centralized logging |
| Uptime monitoring | [ ] | Configure health checks |
| Alerting configured | [ ] | Set up critical alerts |
| Dashboard created | [ ] | Monitor key metrics |

---

## B.2 Deployment Strategies

### Option 1: Vercel (Recommended for Next.js)

Vercel provides the most seamless deployment experience for Next.js applications with Clerk.

**Step-by-Step Vercel Deployment:**

1. **Push code to GitHub**
```bash
git init
git add .
git commit -m "Ready for production"
git remote add origin https://github.com/yourusername/your-repo.git
git push -u origin main
```

2. **Import to Vercel**
   - Go to [vercel.com](https://vercel.com)
   - Click "Import Project"
   - Select your GitHub repository
   - Click "Import"

3. **Configure Environment Variables**
```bash
# Required Clerk variables
NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY=pk_prod_xxxxxx
CLERK_SECRET_KEY=sk_prod_xxxxxx
CLERK_WEBHOOK_SECRET=whsec_xxxxxx

# Database
DATABASE_URL=postgresql://user:password@host:port/database

# Application
NEXT_PUBLIC_APP_URL=https://yourdomain.com
NEXTAUTH_URL=https://yourdomain.com
```

4. **Deploy**
   - Click "Deploy"
   - Wait for build and deployment
   - Configure custom domain in Vercel settings

**Vercel Configuration File:**

**File:** `vercel.json`

```json
{
  "buildCommand": "npm run build",
  "outputDirectory": ".next",
  "devCommand": "npm run dev",
  "installCommand": "npm install",
  "framework": "nextjs",
  "regions": ["iad1"],
  "env": {
    "NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY": "@clerk_publishable_key",
    "CLERK_SECRET_KEY": "@clerk_secret_key"
  }
}
```

### Option 2: Docker Containerization

For containerized deployments (AWS ECS, Google Cloud Run, etc.)

**File:** `Dockerfile`

```dockerfile
# Dockerfile for Clerk application
FROM node:20-alpine AS builder

WORKDIR /app

# Install dependencies
COPY package*.json ./
RUN npm ci

# Copy source
COPY . .

# Build the application
RUN npm run build

# Production image
FROM node:20-alpine AS runner

WORKDIR /app

# Copy built application
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/next.config.js ./next.config.js

# Expose port
EXPOSE 3000

# Start the application
CMD ["npm", "start"]
```

**File:** `docker-compose.yml`

```yaml
version: '3.8'

services:
  app:
    build: .
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
      - NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY=${NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY}
      - CLERK_SECRET_KEY=${CLERK_SECRET_KEY}
      - DATABASE_URL=${DATABASE_URL}
    env_file:
      - .env.production
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/api/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  db:
    image: postgres:16-alpine
    environment:
      - POSTGRES_USER=clerk_app
      - POSTGRES_PASSWORD=${DB_PASSWORD}
      - POSTGRES_DB=clerk_mastery
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"
    restart: unless-stopped

volumes:
  postgres_data:
```

### Option 3: AWS or Google Cloud

For enterprise deployments with specific compliance requirements.

**AWS Deployment Steps:**

1. **Set up RDS PostgreSQL**
   - Enable automated backups
   - Configure read replicas
   - Set up security groups

2. **Deploy to ECS Fargate**
   - Build Docker image
   - Push to ECR
   - Create ECS task definition
   - Deploy service

3. **Configure CloudFront**
   - Set up CDN for static assets
   - Configure SSL certificate

4. **Set up CloudWatch**
   - Enable logging
   - Create dashboards
   - Configure alerts

**Google Cloud Run Deployment:**

```bash
# Build and deploy to Cloud Run
gcloud builds submit --tag gcr.io/your-project/clerk-app
gcloud run deploy clerk-app \
  --image gcr.io/your-project/clerk-app \
  --platform managed \
  --region us-central1 \
  --memory 1Gi \
  --cpu 1 \
  --concurrency 100 \
  --max-instances 10 \
  --set-env-vars "NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY=$NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY" \
  --set-env-vars "CLERK_SECRET_KEY=$CLERK_SECRET_KEY" \
  --set-env-vars "DATABASE_URL=$DATABASE_URL"
```

---

## B.3 Security Hardening for Production

### HTTP Security Headers

**File:** `middleware.ts` (enhanced security)

```tsx
// middleware.ts - Enhanced security headers
import { NextResponse } from 'next/server';

export function middleware(request: Request) {
  // ... existing middleware logic
  
  const response = NextResponse.next();
  
  // Security Headers
  response.headers.set('X-Content-Type-Options', 'nosniff');
  response.headers.set('X-Frame-Options', 'DENY');
  response.headers.set('X-XSS-Protection', '1; mode=block');
  response.headers.set('Referrer-Policy', 'strict-origin-when-cross-origin');
  
  // Content Security Policy
  response.headers.set('Content-Security-Policy', `
    default-src 'self';
    script-src 'self' 'unsafe-inline' 'unsafe-eval' https://clerk.accounts.dev https://*.clerk.accounts.dev;
    style-src 'self' 'unsafe-inline';
    img-src 'self' data: https://img.clerk.com https://lh3.googleusercontent.com;
    connect-src 'self' https://api.clerk.com https://*.clerk.accounts.dev;
    font-src 'self';
    frame-src 'self' https://*.clerk.accounts.dev;
    object-src 'none';
    base-uri 'self';
    form-action 'self';
  `.replace(/\s+/g, ' ').trim());
  
  // HSTS (strict-transport-security) - enable in production
  response.headers.set('Strict-Transport-Security', 'max-age=31536000; includeSubDomains; preload');
  
  // Permissions Policy
  response.headers.set('Permissions-Policy', `
    camera=(),
    microphone=(),
    geolocation=(),
    payment=(),
    usb=()
  `.replace(/\s+/g, ' ').trim());
  
  return response;
}
```

### Rate Limiting

**File:** `lib/rate-limit.ts`

```tsx
// lib/rate-limit.ts
// Rate limiting for API routes

interface RateLimitConfig {
  windowMs: number;   // Time window in milliseconds
  maxRequests: number; // Maximum requests per window
}

interface RateLimitStore {
  [key: string]: {
    count: number;
    resetTime: number;
  };
}

const store: RateLimitStore = {};

/**
 * Simple in-memory rate limiter
 * For production, use Redis or a distributed store
 */
export function rateLimit(config: RateLimitConfig) {
  return function (identifier: string): { allowed: boolean; remaining: number; resetTime: number } {
    const now = Date.now();
    const key = `rate_limit:${identifier}`;
    
    // Check if key exists
    if (!store[key] || store[key].resetTime <= now) {
      // Reset window
      store[key] = {
        count: 1,
        resetTime: now + config.windowMs,
      };
      return {
        allowed: true,
        remaining: config.maxRequests - 1,
        resetTime: store[key].resetTime,
      };
    }
    
    // Increment count
    store[key].count++;
    
    // Check if over limit
    const allowed = store[key].count <= config.maxRequests;
    
    return {
      allowed,
      remaining: Math.max(0, config.maxRequests - store[key].count),
      resetTime: store[key].resetTime,
    };
  };
}

// Usage in API route
const authRateLimit = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  maxRequests: 10, // 10 attempts
});

export async function POST(request: Request) {
  const ip = request.headers.get('x-forwarded-for') || 'unknown';
  const result = authRateLimit(ip);
  
  if (!result.allowed) {
    return new Response(JSON.stringify({
      error: 'Too many requests, please try again later'
    }), {
      status: 429,
      headers: {
        'Retry-After': Math.ceil((result.resetTime - Date.now()) / 1000).toString(),
      },
    });
  }
  
  // ... handle request
}
```

### CORS Configuration

**File:** `lib/cors.ts`

```tsx
// lib/cors.ts
// CORS configuration for production

const allowedOrigins = [
  'https://yourdomain.com',
  'https://www.yourdomain.com',
  // Add staging domains
  'https://staging.yourdomain.com',
];

export function getCorsHeaders(origin: string | null) {
  const isAllowed = origin && allowedOrigins.includes(origin);
  
  return {
    'Access-Control-Allow-Origin': isAllowed ? origin : 'null',
    'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type, Authorization',
    'Access-Control-Allow-Credentials': 'true',
    'Access-Control-Max-Age': '86400',
  };
}
```

---

## B.4 Performance Optimization

### Cache Strategies

**File:** `lib/cache.ts` (production cache)

```tsx
// lib/cache.ts
// Production cache strategies

import { unstable_cache } from 'next/cache';
import Redis from 'ioredis';

// Redis client (optional, for distributed caching)
let redis: Redis | null = null;
if (process.env.REDIS_URL) {
  redis = new Redis(process.env.REDIS_URL);
}

/**
 * Cache user data with Redis (distributed cache)
 */
export async function getCachedUser(userId: string) {
  if (redis) {
    // Try Redis cache
    const cached = await redis.get(`user:${userId}`);
    if (cached) {
      return JSON.parse(cached);
    }
  }
  
  // Fetch from database
  const user = await prisma.user.findUnique({
    where: { clerkId: userId },
  });
  
  // Cache in Redis
  if (redis && user) {
    await redis.setex(`user:${userId}`, 300, JSON.stringify(user)); // 5 minutes
  }
  
  return user;
}

/**
 * Cache with Next.js built-in cache
 */
export const cachedProjects = unstable_cache(
  async (orgId: string) => {
    return prisma.project.findMany({
      where: { organizationId: orgId },
      include: { owner: true },
    });
  },
  ['projects'],
  {
    revalidate: 60, // Revalidate every 60 seconds
    tags: ['projects'], // For on-demand revalidation
  }
);
```

### Image Optimization

**File:** `app/components/OptimizedImage.tsx`

```tsx
// app/components/OptimizedImage.tsx
// Optimized image component using Next.js Image

import Image from 'next/image';
import { useState } from 'react';

interface OptimizedImageProps {
  src: string;
  alt: string;
  width: number;
  height: number;
  className?: string;
  priority?: boolean;
}

export function OptimizedImage({
  src,
  alt,
  width,
  height,
  className,
  priority = false,
}: OptimizedImageProps) {
  const [error, setError] = useState(false);
  
  // Use Clerk's image optimization if available
  const imageSrc = src.startsWith('http') 
    ? src 
    : `https://img.clerk.com/${src}`;
  
  return (
    <div className={`relative ${className || ''}`}>
      <Image
        src={error ? '/images/fallback-avatar.png' : imageSrc}
        alt={alt}
        width={width}
        height={height}
        className="rounded-full object-cover"
        priority={priority}
        onError={() => setError(true)}
        sizes="(max-width: 768px) 100vw, (max-width: 1200px) 50vw, 33vw"
        quality={85}
        loading={priority ? 'eager' : 'lazy'}
      />
    </div>
  );
}
```

### Bundle Optimization

**File:** `next.config.js` (optimization)

```js
/** @type {import('next').NextConfig} */
const nextConfig = {
  // ... existing config
  
  // Bundle optimization
  webpack: (config, { isServer }) => {
    // Split chunks for better caching
    config.optimization.splitChunks = {
      chunks: 'all',
      maxSize: 244000,
      cacheGroups: {
        clerk: {
          test: /[\\/]node_modules[\\/](@clerk)[\\/]/,
          name: 'clerk',
          priority: 30,
          reuseExistingChunk: true,
        },
        react: {
          test: /[\\/]node_modules[\\/](react|react-dom)[\\/]/,
          name: 'react',
          priority: 20,
          reuseExistingChunk: true,
        },
        ui: {
          test: /[\\/]components[\\/]ui[\\/]/,
          name: 'ui',
          priority: 10,
          reuseExistingChunk: true,
        },
      },
    };
    
    return config;
  },
  
  // Enable compression
  compress: true,
  
  // Configure headers for caching
  async headers() {
    return [
      {
        source: '/_next/static/(.*)',
        headers: [
          {
            key: 'Cache-Control',
            value: 'public, max-age=31536000, immutable',
          },
        ],
      },
      {
        source: '/static/(.*)',
        headers: [
          {
            key: 'Cache-Control',
            value: 'public, max-age=86400, stale-while-revalidate=300',
          },
        ],
      },
    ];
  },
};

module.exports = nextConfig;
```

### Database Query Optimization

**File:** `lib/db-optimizations.ts`

```tsx
// lib/db-optimizations.ts
// Database query optimizations

import prisma from './db';

/**
 * Get user with optimized query
 * Using select to only fetch needed fields
 */
export async function getOptimizedUser(clerkId: string) {
  return prisma.user.findUnique({
    where: { clerkId },
    select: {
      id: true,
      email: true,
      name: true,
      role: true,
      preferences: true,
      // Exclude large metadata fields unless needed
    },
  });
}

/**
 * Get projects with pagination and filtering
 */
export async function getPaginatedProjects({
  organizationId,
  cursor,
  limit = 20,
  status,
}: {
  organizationId: string;
  cursor?: string;
  limit?: number;
  status?: string;
}) {
  return prisma.project.findMany({
    where: {
      organizationId,
      ...(status && { status }),
    },
    take: limit + 1,
    ...(cursor && {
      cursor: { id: cursor },
      skip: 1,
    }),
    orderBy: { createdAt: 'desc' },
    select: {
      id: true,
      name: true,
      description: true,
      status: true,
      createdAt: true,
      owner: {
        select: {
          id: true,
          name: true,
          email: true,
        },
      },
    },
  });
}

/**
 * Batch get users (N+1 query prevention)
 */
export async function getUsersBatch(userIds: string[]) {
  return prisma.user.findMany({
    where: {
      id: { in: userIds },
    },
    select: {
      id: true,
      name: true,
      email: true,
      avatarUrl: true,
    },
  });
}
```

---

## B.5 Monitoring and Observability

### Health Check Endpoint

**File:** `app/api/health/route.ts`

```tsx
// app/api/health/route.ts
// Health check endpoint for monitoring

import { NextResponse } from 'next/server';
import prisma from '@/lib/db';
import { clerkClient } from '@clerk/nextjs/server';

export async function GET() {
  const health = {
    status: 'healthy',
    timestamp: new Date().toISOString(),
    version: process.env.NEXT_PUBLIC_APP_VERSION || '1.0.0',
    uptime: process.uptime(),
    checks: {
      database: 'unknown',
      clerk: 'unknown',
    },
  };
  
  // Check database
  try {
    await prisma.$queryRaw`SELECT 1`;
    health.checks.database = 'healthy';
  } catch (error) {
    health.checks.database = 'unhealthy';
    health.status = 'unhealthy';
  }
  
  // Check Clerk
  try {
    await clerkClient().users.getUserList({ limit: 1 });
    health.checks.clerk = 'healthy';
  } catch (error) {
    health.checks.clerk = 'unhealthy';
    health.status = 'unhealthy';
  }
  
  const statusCode = health.status === 'healthy' ? 200 : 503;
  
  return NextResponse.json(health, { status: statusCode });
}
```

### Structured Logging

**File:** `lib/logger.ts`

```tsx
// lib/logger.ts
// Structured logging for production

type LogLevel = 'debug' | 'info' | 'warn' | 'error';

interface LogContext {
  [key: string]: any;
}

class Logger {
  private level: LogLevel = process.env.NODE_ENV === 'production' ? 'info' : 'debug';
  
  private log(level: LogLevel, message: string, context: LogContext = {}) {
    const entry = {
      level,
      message,
      timestamp: new Date().toISOString(),
      environment: process.env.NODE_ENV,
      service: 'clerk-app',
      ...context,
    };
    
    // In production, send to logging service
    if (process.env.NODE_ENV === 'production') {
      // Send to Datadog, Splunk, etc.
      console.log(JSON.stringify(entry));
    } else {
      // Pretty print in development
      console[level === 'error' ? 'error' : level](
        `[${entry.timestamp}] ${level.toUpperCase()}: ${message}`,
        context
      );
    }
  }
  
  info(message: string, context: LogContext = {}) {
    this.log('info', message, context);
  }
  
  warn(message: string, context: LogContext = {}) {
    this.log('warn', message, context);
  }
  
  error(message: string, context: LogContext = {}) {
    this.log('error', message, context);
  }
  
  debug(message: string, context: LogContext = {}) {
    this.log('debug', message, context);
  }
}

export const logger = new Logger();

// Usage:
// logger.info('User signed in', { userId: 'user_123', orgId: 'org_456' });
// logger.error('Authentication failed', { error: 'Invalid token', ip: '192.168.1.1' });
```

### Performance Monitoring

**File:** `lib/monitoring.ts`

```tsx
// lib/monitoring.ts
// Performance monitoring utilities

import { performance } from 'perf_hooks';

export function measurePerformance<T>(
  fn: () => Promise<T>,
  name: string
): Promise<T> {
  const start = performance.now();
  
  return fn().finally(() => {
    const duration = performance.now() - start;
    
    // Log performance metric
    console.log(`[Performance] ${name}: ${duration.toFixed(2)}ms`);
    
    // Send to monitoring service
    if (process.env.NODE_ENV === 'production') {
      // Send to Datadog, New Relic, etc.
      // await sendMetric('app.performance', duration, { name });
    }
  });
}

export async function withPerformance<T>(
  name: string,
  fn: () => Promise<T>
): Promise<T> {
  return measurePerformance(fn, name);
}

// Usage:
// const user = await withPerformance('getUser', () => getUser(userId));
```

---

## B.6 Enterprise Features

### Single Sign-On (SSO) Configuration

Clerk supports enterprise SSO through SAML and OIDC.

**SAML Configuration:**
1. Go to Clerk Dashboard → User & Authentication → SSO
2. Click "Add SSO Provider"
3. Select "SAML"
4. Configure metadata URL or upload metadata file
5. Set attribute mappings (email, name, groups)
6. Enable the provider

**OIDC Configuration:**
1. Go to Clerk Dashboard → User & Authentication → SSO
2. Click "Add SSO Provider"
3. Select "OIDC"
4. Configure Client ID, Client Secret, Issuer URL
5. Set authorization endpoint, token endpoint, userinfo endpoint
6. Enable the provider

**SAML Integration Code:**

```typescript
// app/api/auth/sso/route.ts
import { clerkClient } from '@clerk/nextjs/server';

export async function POST(request: Request) {
  const { userId, orgId } = await request.json();
  
  // Create SAML connection
  const connection = await clerkClient().organizations.createOrganization({
    name: 'Enterprise Corp',
    createdBy: userId,
    publicMetadata: {
      saml_enabled: true,
      saml_metadata_url: 'https://enterprise.com/saml/metadata',
    },
  });
  
  // Create SAML connection for SSO
  await clerkClient().samlConnections.create({
    organizationId: connection.id,
    name: 'Enterprise SAML',
    idpMetadataUrl: 'https://enterprise.com/saml/metadata',
    attributeMapping: {
      email: 'email',
      firstName: 'firstName',
      lastName: 'lastName',
      groups: 'groups',
    },
  });
  
  return Response.json({ success: true });
}
```

### Audit Logging for Compliance

**File:** `lib/audit.ts`

```tsx
// lib/audit.ts
// Audit logging for compliance (SOC2, GDPR, HIPAA)

import prisma from './db';
import { logger } from './logger';

export enum AuditAction {
  USER_LOGIN = 'user.login',
  USER_LOGOUT = 'user.logout',
  USER_CREATED = 'user.created',
  USER_UPDATED = 'user.updated',
  USER_DELETED = 'user.deleted',
  ORGANIZATION_CREATED = 'organization.created',
  ORGANIZATION_UPDATED = 'organization.updated',
  ORGANIZATION_DELETED = 'organization.deleted',
  PERMISSION_CHANGED = 'permission.changed',
  DATA_ACCESSED = 'data.accessed',
  DATA_MODIFIED = 'data.modified',
  DATA_EXPORTED = 'data.exported',
}

interface AuditLogData {
  userId: string;
  action: AuditAction;
  resourceId?: string;
  resourceType?: string;
  details?: Record<string, any>;
  ipAddress?: string;
  userAgent?: string;
}

export async function auditLog(data: AuditLogData) {
  try {
    // Store in database
    await prisma.auditLog.create({
      data: {
        userId: data.userId,
        event: data.action,
        metadata: {
          resourceId: data.resourceId,
          resourceType: data.resourceType,
          details: data.details,
          ipAddress: data.ipAddress,
          userAgent: data.userAgent,
        },
      },
    });
    
    // Log to logger
    logger.info(`[AUDIT] ${data.action}`, {
      userId: data.userId,
      resourceId: data.resourceId,
      resourceType: data.resourceType,
      details: data.details,
    });
    
    // For sensitive actions, also send to security monitoring
    if ([
      AuditAction.USER_DELETED,
      AuditAction.PERMISSION_CHANGED,
      AuditAction.DATA_EXPORTED,
    ].includes(data.action)) {
      // Send to security team alert channel
      await sendSecurityAlert(data);
    }
  } catch (error) {
    // Audit failure shouldn't break the main flow
    logger.error('Failed to create audit log', { error, data });
  }
}

async function sendSecurityAlert(data: AuditLogData) {
  // In production, send to Slack, PagerDuty, etc.
  console.log(`[SECURITY ALERT] ${data.action} by user ${data.userId}`);
}
```

### GDPR Compliance

**File:** `lib/gdpr.ts`

```tsx
// lib/gdpr.ts
// GDPR compliance utilities

import prisma from './db';
import { clerkClient } from '@clerk/nextjs/server';
import { logger } from './logger';

/**
 * Data Subject Access Request (DSAR) - Export user data
 */
export async function exportUserData(userId: string) {
  const user = await clerkClient().users.getUser(userId);
  
  // Collect all user data from database
  const dbUser = await prisma.user.findUnique({
    where: { clerkId: userId },
    include: {
      projects: true,
      auditLogs: true,
      sessions: true,
    },
  });
  
  const exportData = {
    user: {
      id: user.id,
      email: user.emailAddresses[0]?.emailAddress,
      name: user.fullName,
      username: user.username,
      createdAt: user.createdAt,
      lastSignInAt: user.lastSignInAt,
      publicMetadata: user.publicMetadata,
    },
    projects: dbUser?.projects || [],
    auditLogs: dbUser?.auditLogs || [],
    sessions: dbUser?.sessions || [],
  };
  
  // Log DSAR request
  await logger.info('DSAR export completed', { userId });
  
  return exportData;
}

/**
 * Right to be forgotten - Delete all user data
 */
export async function deleteAllUserData(userId: string) {
  // Log before deletion
  await logger.warn('GDPR deletion request', { userId });
  
  // Delete from your database
  await prisma.$transaction([
    prisma.auditLog.deleteMany({ where: { userId } }),
    prisma.session.deleteMany({ where: { userId } }),
    prisma.project.deleteMany({ where: { ownerId: userId } }),
    prisma.user.delete({ where: { clerkId: userId } }),
  ]);
  
  // Delete from Clerk
  await clerkClient().users.deleteUser(userId);
  
  // Log completion
  await logger.info('GDPR deletion completed', { userId });
  
  return { success: true };
}

/**
 * Data Processing Agreement (DPA) consent
 */
export async function recordDPAConsent(userId: string, version: string) {
  await prisma.user.update({
    where: { clerkId: userId },
    data: {
      publicMetadata: {
        dpaConsent: {
          version,
          consentedAt: new Date().toISOString(),
          ipAddress: 'user_ip', // Pass from request
        },
      },
    },
  });
}
```

---

## B.7 Production Checklist Summary

### Pre-Deployment

- [ ] All tests passing
- [ ] Build successful
- [ ] Environment variables configured
- [ ] Production Clerk instance created
- [ ] Custom domain configured
- [ ] SSL/HTTPS enabled
- [ ] Database migrated

### Security

- [ ] Secret keys rotated
- [ ] CSP headers configured
- [ ] CORS properly configured
- [ ] Rate limiting enabled
- [ ] Session timeout configured
- [ ] MFA enabled (recommended)
- [ ] Security headers set

### Monitoring

- [ ] Health check endpoint
- [ ] Performance monitoring
- [ ] Error tracking
- [ ] Log aggregation
- [ ] Alerting configured
- [ ] Uptime monitoring

### Maintenance

- [ ] Backup strategy
- [ ] Disaster recovery plan
- [ ] Documentation updated
- [ ] On-call rotation
- [ ] Incident response plan
