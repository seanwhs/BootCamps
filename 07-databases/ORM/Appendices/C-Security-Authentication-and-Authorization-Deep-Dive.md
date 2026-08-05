# Appendix C: Security, Authentication, and Authorization Deep Dive

### Purpose of This Appendix

Security is the foundation of any production application. In the main series, we covered authentication with NextAuth.js, basic RBAC, and input validation. This appendix takes a comprehensive look at security across the stack, with a focus on how Prisma and Drizzle can be used to implement robust security patterns.

**What you'll find here:**
- **Authentication strategies** – JWT, session cookies, OAuth, and their integration with both ORMs.
- **Authorization and RBAC** – role‑based access control with organization‑level roles (owner, admin, member, viewer).
- **Row‑Level Security (RLS)** – implementing database‑level security with PostgreSQL and integrating with both ORMs.
- **Data encryption** – encrypting sensitive data at rest (e.g., PII, tokens) and in transit.
- **Audit logging** – building a comprehensive audit trail.
- **Security best practices** – preventing SQL injection, XSS, CSRF, and using environment variables securely.

---

## Appendix C, Section 1: Authentication Strategies

### 1.1 JWT Authentication with NextAuth.js

We already set up NextAuth.js with Credentials provider. Here we add a JWT strategy and integrate it with both ORMs.

**Prisma adapter:**

```typescript
// apps/nextjs/app/api/auth/[...nextauth]/route.ts
import NextAuth from 'next-auth'
import CredentialsProvider from 'next-auth/providers/credentials'
import { PrismaAdapter } from '@next-auth/prisma-adapter'
import { prisma } from '@taskflow/database/prisma/client'
import { compare } from 'bcryptjs'

export const authOptions = {
  adapter: PrismaAdapter(prisma),
  providers: [
    CredentialsProvider({
      name: 'Credentials',
      credentials: {
        email: { label: 'Email', type: 'email' },
        password: { label: 'Password', type: 'password' },
      },
      async authorize(credentials) {
        if (!credentials?.email || !credentials?.password) return null
        const user = await prisma.user.findUnique({
          where: { email: credentials.email },
        })
        if (!user) return null
        const isValid = await compare(credentials.password, user.passwordHash)
        if (!isValid) return null
        return { id: user.id, email: user.email, name: user.fullName }
      },
    }),
  ],
  session: { strategy: 'jwt' },
  callbacks: {
    async jwt({ token, user }) {
      if (user) {
        token.id = user.id
        // Fetch user's default organization (or first one)
        const membership = await prisma.organizationMember.findFirst({
          where: { userId: user.id },
          orderBy: { joinedAt: 'asc' },
        })
        token.orgId = membership?.organizationId || null
        token.role = membership?.role || null
      }
      return token
    },
    async session({ session, token }) {
      session.user.id = token.id as string
      session.user.orgId = token.orgId as string | null
      session.user.role = token.role as string | null
      return session
    },
  },
  pages: { signIn: '/login' },
}

const handler = NextAuth(authOptions)
export { handler as GET, handler as POST }
```

**Drizzle adapter (if you want to use Drizzle for auth):**

You can use the `@auth/drizzle-adapter` package. However, NextAuth.js's Prisma adapter is more mature. If you want Drizzle, you'd need to implement a custom adapter.

---

### 1.2 OAuth Providers (Google, GitHub)

OAuth providers can be added easily:

```typescript
import GoogleProvider from 'next-auth/providers/google'
import GitHubProvider from 'next-auth/providers/github'

// In authOptions:
providers: [
  GoogleProvider({
    clientId: process.env.GOOGLE_CLIENT_ID!,
    clientSecret: process.env.GOOGLE_CLIENT_SECRET!,
  }),
  GitHubProvider({
    clientId: process.env.GITHUB_CLIENT_ID!,
    clientSecret: process.env.GITHUB_CLIENT_SECRET!,
  }),
  // ... CredentialsProvider
],
```

The Prisma adapter will automatically handle user creation/updates.

---

### 1.3 Session Management

With JWT, sessions are stateless; we don't need a database session table. However, we can store session data in the JWT token. For serverless, this is ideal.

---

## Appendix C, Section 2: Authorization and RBAC

### 2.1 Role Definitions

We defined roles: `owner`, `admin`, `member`, `viewer`. Each role has increasing permissions.

**Permission Matrix:**

| Action | Owner | Admin | Member | Viewer |
|--------|-------|-------|--------|--------|
| View organization settings | ✅ | ✅ | ❌ | ❌ |
| Manage members (invite, remove, change roles) | ✅ | ✅ (except owner) | ❌ | ❌ |
| Create project | ✅ | ✅ | ✅ | ❌ |
| Edit any project | ✅ | ✅ | ❌ | ❌ |
| Edit own project (if member) | ✅ | ✅ | ✅ (if assigned) | ❌ |
| Delete project | ✅ | ✅ | ❌ | ❌ |
| Create task in any project | ✅ | ✅ | ✅ (if member) | ❌ |
| Assign tasks to anyone | ✅ | ✅ | ❌ (only self) | ❌ |
| Delete any comment | ✅ | ✅ (except owner's) | ❌ | ❌ |

### 2.2 Implementing RBAC in Services

We'll create a base service that checks permissions.

**Prisma Service with RBAC:**

```typescript
// packages/services/src/base.service.ts
import { prisma } from '@taskflow/database/prisma/client'

export class BaseService {
  constructor(protected userId: string, protected orgId: string) {}

  protected async getUserRole(): Promise<string> {
    const membership = await prisma.organizationMember.findUnique({
      where: {
        organizationId_userId: {
          organizationId: this.orgId,
          userId: this.userId,
        },
      },
      select: { role: true },
    })
    return membership?.role || 'viewer' // default viewer
  }

  protected async checkPermission(requiredRole: string | string[]) {
    const role = await this.getUserRole()
    const allowed = Array.isArray(requiredRole) ? requiredRole.includes(role) : role === requiredRole
    if (!allowed) {
      throw new Error(`Insufficient permissions. Required: ${requiredRole}, got: ${role}`)
    }
    return role
  }
}
```

Then, for a ProjectService:

```typescript
// packages/services/src/project.service.ts
import { BaseService } from './base.service'
import { prisma } from '@taskflow/database/prisma/client'

export class ProjectService extends BaseService {
  async createProject(data: { name: string; description?: string }) {
    // Owners, admins, and members can create projects
    await this.checkPermission(['owner', 'admin', 'member'])
    return prisma.project.create({
      data: { ...data, organizationId: this.orgId, createdBy: this.userId },
    })
  }

  async deleteProject(projectId: string) {
    // Only owners and admins can delete
    await this.checkPermission(['owner', 'admin'])
    // Ensure project belongs to the org
    const project = await prisma.project.findFirst({
      where: { id: projectId, organizationId: this.orgId },
    })
    if (!project) throw new Error('Project not found')
    return prisma.project.delete({ where: { id: projectId } })
  }
}
```

### 2.3 Drizzle Service with RBAC

Similar implementation, but using Drizzle queries.

```typescript
// packages/services/src/base.service.drizzle.ts
import { db } from '@taskflow/database/drizzle/client'
import { organizationMembers } from '@taskflow/database/drizzle/schema'
import { eq, and } from 'drizzle-orm'

export class DrizzleBaseService {
  constructor(protected userId: string, protected orgId: string) {}

  protected async getUserRole(): Promise<string> {
    const membership = await db.query.organizationMembers.findFirst({
      where: and(
        eq(organizationMembers.organizationId, this.orgId),
        eq(organizationMembers.userId, this.userId)
      ),
      columns: { role: true },
    })
    return membership?.role || 'viewer'
  }

  protected async checkPermission(requiredRole: string | string[]) {
    const role = await this.getUserRole()
    const allowed = Array.isArray(requiredRole) ? requiredRole.includes(role) : role === requiredRole
    if (!allowed) {
      throw new Error(`Insufficient permissions. Required: ${requiredRole}, got: ${role}`)
    }
    return role
  }
}
```

Then, similarly implement project service.

---

## Appendix C, Section 3: Row‑Level Security (RLS) in PostgreSQL

RLS allows you to enforce security at the database level, ensuring that users can only access rows they are authorized to see. This is a powerful defense‑in‑depth measure.

### 3.1 Enabling RLS

```sql
-- Enable RLS on tables
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE organization_members ENABLE ROW LEVEL SECURITY;
-- etc.
```

### 3.2 Creating Policies

**Policy: users can only see projects in their organization.**

```sql
CREATE POLICY user_projects ON projects
  USING (
    organization_id IN (
      SELECT organization_id FROM organization_members WHERE user_id = current_setting('app.current_user_id')::uuid
    )
  );
```

**Policy: users can only see tasks in projects they have access to.**

```sql
CREATE POLICY user_tasks ON tasks
  USING (
    project_id IN (
      SELECT id FROM projects WHERE organization_id IN (
        SELECT organization_id FROM organization_members WHERE user_id = current_setting('app.current_user_id')::uuid
      )
    )
  );
```

**Policy: members can only update tasks they are assigned to (or if they are admin/owner).**

```sql
CREATE POLICY user_task_update ON tasks
  FOR UPDATE
  USING (
    assigned_to = current_setting('app.current_user_id')::uuid
    OR
    project_id IN (
      SELECT id FROM projects WHERE organization_id IN (
        SELECT organization_id FROM organization_members 
        WHERE user_id = current_setting('app.current_user_id')::uuid 
        AND role IN ('owner', 'admin')
      )
    )
  );
```

### 3.3 Integrating with Prisma

To use RLS with Prisma, you need to set the `app.current_user_id` session variable for each request. You can do this via middleware or by running a raw SQL before each query.

**Using Prisma middleware (via `$extends`):**

```typescript
// packages/database/src/prisma/client.ts
import { PrismaClient } from '@prisma/client'

const prisma = new PrismaClient().$extends({
  query: {
    $allModels: {
      async $allOperations({ args, query }) {
        // Set the current user ID in the session
        const userId = getCurrentUserId() // you need to provide this via context
        if (userId) {
          await prisma.$executeRaw`SELECT set_config('app.current_user_id', ${userId}, true)`
        }
        return query(args)
      },
    },
  },
})
```

**Note:** This approach sets the session variable for every query, which can be a performance overhead. Alternatively, you can set it once per request in a middleware or server action.

### 3.4 Integrating with Drizzle

Similarly, you can use `db.execute` to set the session variable:

```typescript
// In a middleware or before queries
await db.execute(sql`SELECT set_config('app.current_user_id', ${userId}, true)`)
```

Then, RLS policies will apply automatically to all subsequent queries.

---

## Appendix C, Section 4: Data Encryption

### 4.1 Encrypting Sensitive Fields (PII, tokens)

For fields like email, personal details, we can use `crypto` or `bcrypt` for hashing (for passwords) and symmetric encryption for reversible data.

**Example: Encrypt user email (if needed) using AES-256-GCM.**

```typescript
// packages/database/src/encryption.ts
import { createCipheriv, createDecipheriv, randomBytes } from 'crypto'

const ENCRYPTION_KEY = Buffer.from(process.env.ENCRYPTION_KEY!, 'hex') // 32 bytes
const IV_LENGTH = 16

export function encrypt(text: string): string {
  const iv = randomBytes(IV_LENGTH)
  const cipher = createCipheriv('aes-256-gcm', ENCRYPTION_KEY, iv)
  let encrypted = cipher.update(text, 'utf8', 'hex')
  encrypted += cipher.final('hex')
  const authTag = cipher.getAuthTag()
  return iv.toString('hex') + ':' + authTag.toString('hex') + ':' + encrypted
}

export function decrypt(text: string): string {
  const [ivHex, authTagHex, encrypted] = text.split(':')
  const iv = Buffer.from(ivHex, 'hex')
  const authTag = Buffer.from(authTagHex, 'hex')
  const decipher = createDecipheriv('aes-256-gcm', ENCRYPTION_KEY, iv)
  decipher.setAuthTag(authTag)
  let decrypted = decipher.update(encrypted, 'hex', 'utf8')
  decrypted += decipher.final('utf8')
  return decrypted
}
```

Then in your Prisma/Drizzle schema, store the encrypted value.

### 4.2 Encryption at Rest

Use database‑level encryption (e.g., AWS RDS encryption, or full‑disk encryption). This is transparent to the ORM.

### 4.3 Encryption in Transit

Always use TLS/SSL for database connections. Set `sslmode=require` in the connection string.

---

## Appendix C, Section 5: Audit Logging

We already have the `activity_logs` table. To ensure comprehensive auditing, we need to log every change to sensitive data, including who, what, when, and the old/new values.

**Implement audit logging via Prisma middleware:**

```typescript
// packages/database/src/prisma/audit.ts
import { Prisma } from '@prisma/client'

export const auditExtension = Prisma.defineExtension({
  query: {
    $allModels: {
      async update({ model, args, query }) {
        // Fetch the current record before update to capture old values
        const where = args.where
        const current = await (prisma as any)[model].findUnique({ where })
        const result = await query(args)
        // Log the change
        await prisma.activityLog.create({
          data: {
            userId: getCurrentUserId(),
            organizationId: getCurrentOrgId(),
            action: `${model}.updated`,
            details: {
              recordId: result.id,
              old: current,
              new: result,
            },
          },
        })
        return result
      },
      // Similarly for create, delete
    },
  },
})
```

This is a simplified example; in production, you'd want to avoid performance overhead by filtering only certain models.

---

## Appendix C, Section 6: Security Best Practices Checklist

- [ ] **Use environment variables** for all secrets (DB URL, API keys, JWT secret).
- [ ] **Never hard-code credentials** in source code.
- [ ] **Use parameterized queries** – both ORMs do this automatically, but raw SQL must use placeholders.
- [ ] **Validate all user inputs** with Zod or similar.
- [ ] **Use HTTPS** in production.
- [ ] **Set secure HTTP headers** (CSP, HSTS, X‑Frame‑Options) using Next.js middleware or headers.
- [ ] **Implement rate limiting** to prevent brute‑force attacks.
- [ ] **Use CSRF protection** – NextAuth.js handles this automatically.
- [ ] **Hash passwords** with bcrypt (cost factor ≥ 10).
- [ ] **Use Row‑Level Security** for an extra layer of data isolation.
- [ ] **Regularly rotate secrets** and API keys.
- [ ] **Conduct dependency audits** (`pnpm audit`).
- [ ] **Implement logging and monitoring** to detect anomalies.
- [ ] **Penetration testing** (consider using tools like OWASP ZAP).

---

## Appendix C, Section 7: Implementing Rate Limiting

Rate limiting protects APIs from abuse. We can use Upstash Rate Limit with Vercel.

```typescript
// apps/nextjs/middleware.ts
import { NextResponse } from 'next/server'
import { Ratelimit } from '@upstash/ratelimit'
import { Redis } from '@upstash/redis'

const ratelimit = new Ratelimit({
  redis: Redis.fromEnv(),
  limiter: Ratelimit.slidingWindow(10, '10 s'), // 10 requests per 10 seconds
})

export async function middleware(request: Request) {
  const ip = request.headers.get('x-forwarded-for') || 'anonymous'
  const { success } = await ratelimit.limit(ip)
  if (!success) {
    return new NextResponse('Too Many Requests', { status: 429 })
  }
  return NextResponse.next()
}
```

---

## Conclusion of Appendix C

This appendix has given you a comprehensive understanding of security patterns and their implementation with Prisma and Drizzle. You now have the tools to build a secure, robust application that protects user data and prevents unauthorized access.
