# Primer 9: Clerk's Integration Ecosystem

## Connecting Clerk to Your Stack

Welcome to the ninth primer in the Clerk Mastery Series. This primer provides a comprehensive overview of Clerk's integration ecosystem — how Clerk connects with your existing tools, frameworks, and services. Understanding this ecosystem is essential for building applications that leverage the full power of Clerk's authentication platform.

---

## Framework Integrations

### Next.js (Official SDK)

Clerk provides deep integration with Next.js, supporting both the Pages Router and App Router.

```bash
npm install @clerk/nextjs
```

**Key Features:**

| Feature | Support |
|---------|---------|
| App Router | ✅ Server Components, Server Actions, Middleware |
| Pages Router | ✅ getServerSideProps, getStaticProps, API routes |
| Middleware | ✅ clerkMiddleware() for route protection |
| Server Components | ✅ auth(), currentUser() helpers |
| Server Actions | ✅ auth.protect() for secure mutations |
| Streaming | ✅ Suspense support with auth checks |

```typescript
// middleware.ts - Next.js 16
import { clerkMiddleware, createRouteMatcher } from "@clerk/nextjs/server";

const isProtectedRoute = createRouteMatcher(["/dashboard(.*)"]);

export default clerkMiddleware((auth, req) => {
  if (isProtectedRoute(req)) {
    auth().protect();
  }
});

export const config = {
  matcher: ["/((?!_next).*)"],
};
```

### React (Official SDK)

Clerk's React SDK works with any React application, including Create React App, Vite, and custom setups.

```bash
npm install @clerk/clerk-react
```

**Key Features:**

| Feature | Description |
|---------|-------------|
| ClerkProvider | Context provider for authentication |
| useUser() | Hook for user data |
| useSession() | Hook for session data |
| useSignIn() | Hook for sign-in flows |
| useSignUp() | Hook for sign-up flows |
| useOrganization() | Hook for organization data |

```typescript
// App.tsx
import { ClerkProvider, SignedIn, SignedOut, UserButton } from "@clerk/clerk-react";

function App() {
  return (
    <ClerkProvider publishableKey={process.env.REACT_APP_CLERK_PUBLISHABLE_KEY}>
      <SignedIn>
        <UserButton />
        <Dashboard />
      </SignedIn>
      <SignedOut>
        <SignIn />
      </SignedOut>
    </ClerkProvider>
  );
}
```

### Express (Official SDK)

Clerk provides middleware for Express and other Node.js frameworks.

```bash
npm install @clerk/express
```

**Key Features:**

| Feature | Description |
|---------|-------------|
| ClerkMiddleware | Authentication middleware |
| getAuth() | Extract auth data from request |
| requireAuth() | Route protection middleware |
| Webhook verification | Built-in signature verification |

```typescript
// server.ts
import express from "express";
import { ClerkMiddleware, getAuth, requireAuth } from "@clerk/express";

const app = express();
app.use(ClerkMiddleware());

app.get("/api/me", requireAuth(), (req, res) => {
  const { userId } = getAuth(req);
  res.json({ userId });
});

app.post("/api/webhooks/clerk", express.raw({ type: "application/json" }), 
  async (req, res) => {
    // Verify webhook signature
    const payload = await verifyWebhook(req);
    // Process event
    res.status(200).json({ success: true });
  }
);
```

### React Native (Official SDK)

Clerk's React Native SDK provides authentication for iOS and Android apps.

```bash
npm install @clerk/clerk-react-native
```

**Key Features:**

| Feature | Description |
|---------|-------------|
| Expo Support | ✅ Works with Expo |
| Native Components | ✅ Custom native auth flows |
| Secure Storage | ✅ Uses expo-secure-store |
| OAuth Support | ✅ Social login on mobile |

```typescript
// App.tsx
import { ClerkProvider, SignedIn, SignedOut } from "@clerk/clerk-react-native";

export default function App() {
  return (
    <ClerkProvider publishableKey={process.env.EXPO_PUBLIC_CLERK_PUBLISHABLE_KEY}>
      <SignedIn>
        <HomeScreen />
      </SignedIn>
      <SignedOut>
        <SignInScreen />
      </SignedOut>
    </ClerkProvider>
  );
}
```

### Additional Framework Support

| Framework | SDK | Status |
|-----------|-----|--------|
| **Svelte** | `@clerk/sveltekit` | Official |
| **Remix** | `@clerk/remix` | Official |
| **Vue** | `@clerk/vue` | Community |
| **Angular** | `@clerk/angular` | Community |
| **Django** | `clerk-sdk-python` | Community |
| **Rails** | `clerk-ruby` | Community |

---

## Database Integrations

### Prisma

Clerk integrates seamlessly with Prisma for database synchronization.

```typescript
// lib/db.ts
import { PrismaClient } from "@prisma/client";

export const prisma = new PrismaClient();

// User sync from webhook
export async function syncUserToDatabase(clerkUser: any) {
  const email = clerkUser.email_addresses[0]?.email_address;
  
  return prisma.user.upsert({
    where: { clerkId: clerkUser.id },
    update: {
      email,
      name: clerkUser.full_name,
      metadata: clerkUser.public_metadata,
    },
    create: {
      clerkId: clerkUser.id,
      email,
      name: clerkUser.full_name || email,
      metadata: clerkUser.public_metadata,
    },
  });
}
```

### Drizzle

Drizzle ORM is also well-supported.

```typescript
// lib/db.ts
import { drizzle } from "drizzle-orm/postgres-js";
import { users } from "./schema";

export const db = drizzle(process.env.DATABASE_URL!);

// User sync
export async function syncUserToDatabase(clerkUser: any) {
  const email = clerkUser.email_addresses[0]?.email_address;
  
  return db.insert(users).values({
    clerkId: clerkUser.id,
    email,
    name: clerkUser.full_name || email,
    metadata: clerkUser.public_metadata,
  }).onConflictDoUpdate({
    target: users.clerkId,
    set: {
      email,
      name: clerkUser.full_name || email,
      metadata: clerkUser.public_metadata,
    },
  });
}
```

### TypeORM

```typescript
// entities/User.ts
import { Entity, Column, PrimaryGeneratedColumn } from "typeorm";

@Entity()
export class User {
  @PrimaryGeneratedColumn("uuid")
  id: string;
  
  @Column({ unique: true })
  clerkId: string;
  
  @Column()
  email: string;
  
  @Column({ nullable: true })
  name: string;
  
  @Column({ type: "json", nullable: true })
  metadata: any;
}
```

---

## Backend as a Service (BaaS) Integrations

### Firebase

Clerk can integrate with Firebase using JWT SSO.

```typescript
// lib/firebase.ts
import { initializeApp } from "firebase/app";
import { getAuth, signInWithCustomToken } from "firebase/auth";
import { getFirestore } from "firebase/firestore";

// Configure JWT SSO in Clerk Dashboard
// Use Firebase's custom token format

export async function signInWithClerkToFirebase() {
  // Get JWT from Clerk
  const token = await clerk.getToken({
    template: "firebase",
  });
  
  // Sign in to Firebase with the token
  const auth = getAuth();
  const credential = await signInWithCustomToken(auth, token);
  
  return credential.user;
}
```

### Supabase

Clerk integrates with Supabase using JWT claims.

```typescript
// lib/supabase.ts
import { createClient } from "@supabase/supabase-js";

// Clerk generates JWT in Supabase format
// Configure in Clerk Dashboard → JWT Templates

export async function getSupabaseClient() {
  const token = await clerk.getToken({
    template: "supabase",
  });
  
  const supabase = createClient(
    process.env.SUPABASE_URL!,
    process.env.SUPABASE_ANON_KEY!,
    {
      global: {
        headers: {
          Authorization: `Bearer ${token}`,
        },
      },
    }
  );
  
  return supabase;
}
```

### Hasura

Clerk integrates with Hasura through JWT claims and RBAC.

```typescript
// lib/hasura.ts
import { GraphQLClient } from "graphql-request";

// Clerk JWT includes Hasura claims:
// {
//   "https://hasura.io/jwt/claims": {
//     "x-hasura-default-role": "user",
//     "x-hasura-allowed-roles": ["user", "admin"],
//     "x-hasura-user-id": "user_123abc",
//     "x-hasura-org-id": "org_456def"
//   }
// }

export async function getHasuraClient() {
  const token = await clerk.getToken({
    template: "hasura",
  });
  
  return new GraphQLClient(process.env.HASURA_ENDPOINT!, {
    headers: {
      Authorization: `Bearer ${token}`,
    },
  });
}
```

### Convex

Clerk provides official integration with Convex.

```typescript
// lib/convex.ts
import { convex } from "@convex-dev/clerk";

// Configure in Convex project
// Use Clerk's JWT for authentication

export function useClerkAuth() {
  // Convex handles authentication via Clerk's JWT
  // Config in convex/configuration.ts
}
```

---

## Cloud Platform Integrations

### Vercel

Vercel provides the best deployment experience for Clerk applications.

```bash
# Environment variables in Vercel
NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY=pk_live_xxxxxx
CLERK_SECRET_KEY=sk_live_xxxxxx
CLERK_WEBHOOK_SECRET=whsec_xxxxxx
DATABASE_URL=postgresql://...
```

**Features:**
- Automatic environment variable injection
- Edge runtime support
- Preview deployments with different Clerk instances
- Serverless functions with Clerk middleware

### AWS (ECS / Lambda)

```typescript
// AWS Lambda handler
import { getAuth } from "@clerk/backend";

export const handler = async (event: any) => {
  const auth = await getAuth({
    secretKey: process.env.CLERK_SECRET_KEY,
    authorization: event.headers?.Authorization,
  });
  
  if (!auth.userId) {
    return {
      statusCode: 401,
      body: JSON.stringify({ error: "Unauthorized" }),
    };
  }
  
  // Process request
};
```

### Google Cloud

```typescript
// Google Cloud Run / Cloud Functions
const { clerkClient } = require("@clerk/clerk-sdk-node");

exports.myFunction = async (req, res) => {
  const auth = await clerkClient.verifyToken(req.headers.authorization);
  
  if (!auth) {
    res.status(401).json({ error: "Unauthorized" });
    return;
  }
  
  // Process request
};
```

---

## Payment & Subscription Integrations

### Stripe

Clerk integrates with Stripe through webhooks and metadata.

```typescript
// Sync user to Stripe
export async function createStripeCustomer(userId: string) {
  const user = await clerkClient().users.getUser(userId);
  const email = user.emailAddresses[0]?.emailAddress;
  
  const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!);
  const customer = await stripe.customers.create({
    email,
    metadata: {
      clerkUserId: userId,
    },
  });
  
  // Store Stripe customer ID in private metadata
  await clerkClient().users.updateUser(userId, {
    privateMetadata: {
      stripeCustomerId: customer.id,
    },
  });
  
  return customer;
}

// Webhook: subscription.created
// Update user's subscription status in Clerk metadata
```

### Paddle

```typescript
// Paddle integration
export async function syncPaddleSubscription(userId: string, subscription: any) {
  await clerkClient().users.updateUser(userId, {
    publicMetadata: {
      subscriptionTier: subscription.tier,
      subscriptionStatus: subscription.status,
      subscriptionExpiresAt: subscription.expires_at,
    },
  });
}
```

### Lemonsqueezy

```typescript
// Lemonsqueezy integration
export async function syncLemonSubscription(userId: string, subscription: any) {
  await clerkClient().users.updateUser(userId, {
    privateMetadata: {
      lemonSqueezyCustomerId: subscription.customer_id,
      lemonSqueezySubscriptionId: subscription.id,
    },
  });
}
```

---

## Email & Notification Integrations

### SendGrid

```typescript
// lib/email.ts
import sgMail from "@sendgrid/mail";

sgMail.setApiKey(process.env.SENDGRID_API_KEY!);

export async function sendWelcomeEmail(user: any) {
  const email = user.emailAddresses[0]?.emailAddress;
  
  await sgMail.send({
    to: email,
    from: "welcome@yourdomain.com",
    subject: "Welcome to our platform!",
    html: `
      <h1>Welcome, ${user.full_name || "User"}!</h1>
      <p>Thanks for signing up.</p>
    `,
  });
}
```

### Resend

```typescript
// lib/email.ts
import { Resend } from "resend";

const resend = new Resend(process.env.RESEND_API_KEY!);

export async function sendWelcomeEmail(user: any) {
  const email = user.emailAddresses[0]?.emailAddress;
  
  await resend.emails.send({
    from: "welcome@yourdomain.com",
    to: email,
    subject: "Welcome!",
    html: `<h1>Welcome, ${user.full_name}!</h1>`,
  });
}
```

### Slack

```typescript
// lib/slack.ts
import { WebClient } from "@slack/web-api";

const slack = new WebClient(process.env.SLACK_BOT_TOKEN!);

export async function notifyNewUser(user: any) {
  await slack.chat.postMessage({
    channel: "#user-signups",
    text: `🎉 New user signed up: ${user.full_name} (${user.email_addresses[0]?.email_address})`,
  });
}
```

---

## Monitoring & Observability

### Sentry

```typescript
// lib/sentry.ts
import * as Sentry from "@sentry/nextjs";

// Capture authentication errors
try {
  await signIn();
} catch (error) {
  Sentry.captureException(error, {
    tags: {
      flow: "authentication",
      provider: "google",
    },
  });
}

// Set user context
Sentry.setUser({
  id: user.id,
  email: user.emailAddresses[0]?.emailAddress,
});
```

### Datadog

```typescript
// lib/datadog.ts
import { dogstatsd } from "datadog-statsd";

// Track authentication metrics
export function trackAuthMetrics(userId: string, action: string, success: boolean) {
  dogstatsd.increment("auth.attempts", {
    action,
    success: success ? "true" : "false",
  });
  
  if (success) {
    dogstatsd.increment("auth.success", { action });
  } else {
    dogstatsd.increment("auth.failures", { action });
  }
}
```

### LogRocket

```typescript
// lib/logrocket.ts
import LogRocket from "logrocket";

// Set user context
LogRocket.identify(user.id, {
  name: user.full_name,
  email: user.emailAddresses[0]?.emailAddress,
});

// Track authentication events
LogRocket.track("user_signed_in", {
  userId: user.id,
  method: "google",
});
```

---

## Quick Reference: Integration Ecosystem

| Category | Service | Integration Method |
|----------|---------|-------------------|
| **Framework** | Next.js | `@clerk/nextjs` |
| **Framework** | React | `@clerk/clerk-react` |
| **Framework** | Express | `@clerk/express` |
| **Framework** | React Native | `@clerk/clerk-react-native` |
| **Database** | Prisma | Webhook sync |
| **Database** | Drizzle | Webhook sync |
| **BaaS** | Firebase | JWT SSO |
| **BaaS** | Supabase | JWT SSO |
| **BaaS** | Hasura | JWT claims |
| **Payment** | Stripe | Webhooks + Metadata |
| **Payment** | Paddle | Webhooks + Metadata |
| **Email** | SendGrid | Webhook triggers |
| **Email** | Resend | Webhook triggers |
| **Monitoring** | Sentry | SDK integration |
| **Monitoring** | Datadog | SDK integration |

---

## Key Takeaways

1. **Clerk supports multiple frameworks** — Next.js, React, Express, React Native
2. **Database integration via webhooks** — Keep your data in sync
3. **BaaS integration via JWT SSO** — Single sign-on across services
4. **Payment integration via metadata** — Store subscription data on users
5. **Monitoring via SDKs** — Track authentication events
6. **Cloud platform support** — Vercel, AWS, Google Cloud

---

## Ready to Implement?

This primer covers Clerk's integration ecosystem. Now proceed to:

- **Part 1: Foundations** for initial implementation
- **Part 2: Server-Side Security** for API protection
- **Part 4: Extending Clerk** for webhook integrations
- **Part 5: React 19 & Next.js 16** for modern full-stack patterns

**Connect Clerk to your entire stack!**
