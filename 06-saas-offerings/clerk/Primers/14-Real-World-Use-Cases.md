# Primer 14: Clerk Real-World Use Cases

## Authentication Patterns for Common Application Types

Welcome to the fourteenth primer in the Clerk Mastery Series. This primer explores real-world use cases for Clerk authentication across different application types — from simple blogs to complex enterprise SaaS platforms. Each use case includes architectural patterns, implementation strategies, and code examples.

---

## Use Case 1: Consumer Application

### Example: Social Media or Content Platform

**Characteristics:**
- High volume of users
- Social login preferred
- Public content with user accounts
- Simple permissions (user/admin)

### Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    Consumer Application Architecture                       │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  Frontend: Next.js / React                                         │   │
│  │  ──────────────────────────────────────────────────────────         │   │
│  │  - Public pages (SSG)                                              │   │
│  │  - Dashboard (SSR with auth)                                       │   │
│  │  - Clerk components (SignIn, SignUp, UserButton)                  │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│                                    ▼                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  Authentication: Clerk                                              │   │
│  │  ──────────────────────────────────────────────────────────         │   │
│  │  - Social login (Google, GitHub)                                  │   │
│  │  - Email/password                                                 │   │
│  │  - Optional MFA                                                   │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│                                    ▼                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  Backend: API Routes                                               │   │
│  │  ──────────────────────────────────────────────────────────         │   │
│  │  - Protected API endpoints                                        │   │
│  │  - User metadata for preferences                                 │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Implementation

```typescript
// app/layout.tsx
import { ClerkProvider } from "@clerk/nextjs";
import { Header } from "@/components/Header";

export default function RootLayout({ children }) {
  return (
    <html>
      <body>
        <ClerkProvider
          appearance={{
            variables: {
              colorPrimary: "#1a73e8",
            },
          }}
        >
          <Header />
          <main>{children}</main>
        </ClerkProvider>
      </body>
    </html>
  );
}

// components/Header.tsx
"use client";

import { useUser, UserButton, SignInButton } from "@clerk/nextjs";

export function Header() {
  const { isLoaded, isSignedIn, user } = useUser();
  
  return (
    <header>
      <nav>
        <Logo />
        
        {isLoaded && isSignedIn ? (
          <div className="flex items-center gap-4">
            <span>{user.fullName}</span>
            <UserButton afterSignOutUrl="/" />
          </div>
        ) : (
          <SignInButton mode="modal">
            <button className="btn-primary">Sign In</button>
          </SignInButton>
        )}
      </nav>
    </header>
  );
}

// app/dashboard/page.tsx
import { auth } from "@clerk/nextjs/server";
import { redirect } from "next/navigation";

export default async function DashboardPage() {
  const { userId } = await auth();
  
  if (!userId) {
    redirect("/sign-in");
  }
  
  // Fetch user's data
  const posts = await getPostsForUser(userId);
  
  return <Dashboard posts={posts} />;
}
```

### Key Features

| Feature | Implementation |
|---------|----------------|
| Social Login | Clerk social providers (Google, GitHub) |
| User Management | Clerk UserProfile component |
| Email Verification | Clerk automatic verification |
| Password Reset | Clerk built-in flow |
| Simple Permissions | PublicMetadata role field |

---

## Use Case 2: SaaS Application

### Example: Project Management Tool

**Characteristics:**
- Multi-tenant (organizations/workspaces)
- Team collaboration
- Role-based access control
- Subscription/payment integration

### Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    SaaS Application Architecture                           │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  Frontend: Next.js 16 + React 19                                    │   │
│  │  ──────────────────────────────────────────────────────────         │   │
│  │  - Organization switcher                                           │   │
│  │  - Team management UI                                              │   │
│  │  - Role-based UI rendering                                        │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│                                    ▼                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  Authentication: Clerk Organizations                                │   │
│  │  ──────────────────────────────────────────────────────────         │   │
│  │  - Organizations (workspaces)                                     │   │
│  │  - Custom roles (Admin, Member, Guest)                           │   │
│  │  - Invitations                                                   │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│                                    ▼                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  Backend: API Routes + Server Actions                               │   │
│  │  ──────────────────────────────────────────────────────────         │   │
│  │  - Organization-scoped data queries                               │   │
│  │  - Role-based authorization                                       │   │
│  │  - Webhooks for user sync                                         │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│                                    ▼                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  Integrations                                                       │   │
│  │  ──────────────────────────────────────────────────────────         │   │
│  │  - Stripe for subscriptions                                       │   │
│  │  - Database for user data                                         │   │
│  │  - Email service for invites                                     │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Implementation

```typescript
// app/organization/[orgId]/layout.tsx
import { OrganizationSwitcher, UserButton } from "@clerk/nextjs";
import { auth } from "@clerk/nextjs/server";

export default async function OrgLayout({ children, params }) {
  const { orgId } = await auth();
  
  if (!orgId) {
    redirect("/organization/select");
  }
  
  return (
    <div>
      <header className="flex items-center justify-between p-4 border-b">
        <OrganizationSwitcher />
        <UserButton />
      </header>
      <main>{children}</main>
    </div>
  );
}

// app/actions/projects.ts
"use server";

import { auth } from "@clerk/nextjs/server";

export async function createProject(formData: FormData) {
  const { userId, orgId } = await auth();
  
  if (!userId || !orgId) {
    throw new Error("Unauthorized");
  }
  
  // Check if user has permission in this organization
  const hasPermission = await checkOrgPermission(userId, orgId, "create_project");
  
  if (!hasPermission) {
    throw new Error("Insufficient permissions");
  }
  
  // Create project (scoped to organization)
  return prisma.project.create({
    data: {
      name: formData.get("name"),
      organizationId: orgId,
      ownerId: userId,
    },
  });
}

// app/api/projects/route.ts
import { auth } from "@clerk/nextjs/server";
import { NextResponse } from "next/server";

export async function GET() {
  const { userId, orgId } = await auth();
  
  if (!userId || !orgId) {
    return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
  }
  
  // Query scoped to organization
  const projects = await prisma.project.findMany({
    where: { organizationId: orgId },
  });
  
  return NextResponse.json({ projects });
}
```

### Key Features

| Feature | Implementation |
|---------|----------------|
| Multi-Tenancy | Clerk Organizations |
| Team Management | Organization members + roles |
| Invitations | Clerk Organization invitations |
| RBAC | Custom roles + permissions |
| Data Isolation | All queries scoped by orgId |
| Billing | Stripe integration via webhooks |

---

## Use Case 3: Enterprise Application

### Example: Internal Company Portal

**Characteristics:**
- SSO (SAML/OIDC) required
- Strict compliance requirements
- Role-based access
- Audit logging

### Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    Enterprise Application Architecture                     │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  Frontend: Next.js + Enterprise UI                                  │   │
│  │  ──────────────────────────────────────────────────────────         │   │
│  │  - Custom branded login                                            │   │
│  │  - SSO authentication                                             │   │
│  │  - Admin dashboard                                                │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│                                    ▼                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  Authentication: Clerk + Enterprise SSO                             │   │
│  │  ──────────────────────────────────────────────────────────         │   │
│  │  - SAML/OIDC integration                                           │   │
│  │  - Azure AD / Okta SSO                                            │   │
│  │  - SCIM for provisioning                                          │   │
│  │  - MFA enforcement                                                │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│                                    ▼                                        │
│  ────▶┌─────────────────────────────────────────────────────────────────────┐   │
│  │  Backend: Enterprise APIs                                             │   │
│  │  ──────────────────────────────────────────────────────────         │   │
│  │  - IP whitelisting                                                 │   │
│  │  - Audit logging                                                   │   │
│  │  - Advanced RBAC                                                   │   │
│  │  - Data encryption                                                 │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│                                    ▼                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  Compliance & Security                                              │   │
│  │  ──────────────────────────────────────────────────────────         │   │
│  │  - SOC2 compliance                                                │   │
│  │  - GDPR compliance                                                │   │
│  │  - HIPAA compliance (if needed)                                  │   │
│  │  - Security monitoring                                            │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Implementation

```typescript
// lib/sso-config.ts
export const ssoConfig = {
  saml: {
    enabled: true,
    metadataUrl: process.env.SAML_METADATA_URL,
    entityId: process.env.SAML_ENTITY_ID,
    attributeMapping: {
      email: "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress",
      firstName: "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/givenname",
      lastName: "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/surname",
      groups: "http://schemas.microsoft.com/ws/2008/06/identity/claims/groups",
    },
  },
};

// app/api/saml/route.ts
import { clerkClient } from "@clerk/nextjs/server";

export async function POST(request: Request) {
  const { userId, samlResponse } = await request.json();
  
  // Validate SAML response
  const validated = await validateSAMLResponse(samlResponse);
  
  if (!validated) {
    return Response.json({ error: "Invalid SAML response" }, { status: 400 });
  }
  
  // Create or update user
  const user = await clerkClient().users.createUser({
    emailAddresses: [{ emailAddress: validated.email }],
    firstName: validated.firstName,
    lastName: validated.lastName,
    publicMetadata: {
      groups: validated.groups,
      ssoProvider: "azure-ad",
    },
  });
  
  // Create session
  const session = await clerkClient().sessions.createSession({
    userId: user.id,
  });
  
  return Response.json({ sessionId: session.id });
}

// middleware.ts - Enterprise security
import { clerkMiddleware, createRouteMatcher } from "@clerk/nextjs/server";
import { NextResponse } from "next/server";

const isProtectedRoute = createRouteMatcher(["/dashboard(.*)", "/admin(.*)"]);
const isAdminRoute = createRouteMatcher(["/admin(.*)"]);

export default clerkMiddleware(async (auth, req) => {
  const { userId, sessionId } = await auth();
  
  // IP whitelisting
  const ip = req.headers.get("x-forwarded-for");
  if (ip && !isWhitelistedIP(ip)) {
    return NextResponse.json(
      { error: "Access denied from this IP" },
      { status: 403 }
    );
  }
  
  // Protected routes
  if (isProtectedRoute(req) && !userId) {
    return NextResponse.redirect(new URL("/sso/login", req.url));
  }
  
  // Admin routes require admin role
  if (isAdminRoute(req) && userId) {
    const user = await clerkClient().users.getUser(userId);
    const role = user.publicMetadata?.role;
    
    if (role !== "admin") {
      return NextResponse.json(
        { error: "Admin access required" },
        { status: 403 }
      );
    }
  }
  
  // Audit logging
  await logAuthEvent(userId, "api_access", {
    path: req.nextUrl.pathname,
    method: req.method,
    ip,
    sessionId,
  });
  
  return NextResponse.next();
});
```

### Key Features

| Feature | Implementation |
|---------|----------------|
| SSO Integration | SAML/OIDC providers |
| SCIM Provisioning | Automated user sync |
| MFA Enforcement | Mandatory MFA for all users |
| IP Whitelisting | Restrict to corporate network |
| Audit Logging | Comprehensive event tracking |
| Compliance | SOC2, GDPR, HIPAA ready |

---

## Use Case 4: Mobile Application

### Example: React Native App

**Characteristics:**
- Native mobile experience
- Offline support
- Biometric authentication
- Push notifications

### Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    Mobile Application Architecture                         │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  Mobile App: React Native / Expo                                    │   │
│  │  ──────────────────────────────────────────────────────────         │   │
│  │  - Native authentication flows                                     │   │
│  │  - Biometric login (Face ID, Touch ID)                            │   │
│  │  - Secure storage (Keychain/Keystore)                             │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│                                    ▼                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  Authentication: Clerk React Native SDK                            │   │
│  │  ──────────────────────────────────────────────────────────         │   │
│  │  - Native OAuth flows                                             │   │
│  │  - Magic links                                                    │   │
│  │  - Session persistence                                           │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│                                    ▼                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  Backend: API                                                       │   │
│  │  ──────────────────────────────────────────────────────────         │   │
│  │  - Token validation                                               │   │
│  │  - Push notifications (FCM/APNs)                                 │   │
│  │  - Offline sync                                                   │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Implementation

```typescript
// App.tsx (React Native)
import { ClerkProvider, SignedIn, SignedOut, useUser } from "@clerk/clerk-react-native";
import { NavigationContainer } from "@react-navigation/native";
import { SignInScreen, HomeScreen } from "./screens";

export default function App() {
  return (
    <ClerkProvider publishableKey={process.env.EXPO_PUBLIC_CLERK_PUBLISHABLE_KEY}>
      <NavigationContainer>
        <SignedIn>
          <HomeScreen />
        </SignedIn>
        <SignedOut>
          <SignInScreen />
        </SignedOut>
      </NavigationContainer>
    </ClerkProvider>
  );
}

// screens/SignInScreen.tsx
import { useSignIn, useSignUp } from "@clerk/clerk-react-native";
import { useState } from "react";
import { View, Text, TextInput, Button } from "react-native";

export function SignInScreen() {
  const { signIn, setActive } = useSignIn();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");

  const handleSignIn = async () => {
    try {
      const result = await signIn.create({
        identifier: email,
        password,
      });
      
      if (result.status === "complete") {
        await setActive({ session: result.createdSessionId });
      }
    } catch (err: any) {
      setError(err.message);
    }
  };

  return (
    <View>
      <Text>Email</Text>
      <TextInput value={email} onChangeText={setEmail} />
      <Text>Password</Text>
      <TextInput value={password} onChangeText={setPassword} secureTextEntry />
      {error && <Text>{error}</Text>}
      <Button title="Sign In" onPress={handleSignIn} />
    </View>
  );
}

// lib/push-notifications.ts
import { useUser } from "@clerk/clerk-react-native";
import messaging from "@react-native-firebase/messaging";

export function usePushNotifications() {
  const { user } = useUser();
  
  const registerForPushNotifications = async () => {
    if (!user) return;
    
    const token = await messaging().getToken();
    
    // Store the push token with the user's ID
    await fetch("/api/push-tokens", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${await user.getToken()}`,
      },
      body: JSON.stringify({ token, userId: user.id }),
    });
  };
  
  return { registerForPushNotifications };
}
```

### Key Features

| Feature | Implementation |
|---------|----------------|
| Native Auth | Clerk React Native SDK |
| Biometrics | React Native Biometrics |
| Secure Storage | expo-secure-store |
| OAuth | Native OAuth flows |
| Push Notifications | FCM/APNs + user tokens |
| Offline Mode | AsyncStorage + sync |

---

## Use Case 5: E-Commerce Application

### Example: Online Store

**Characteristics:**
- Guest checkout
- Customer accounts
- Order history
- Address management
- Payment integration

### Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    E-Commerce Application Architecture                     │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  Frontend: Next.js + Tailwind                                       │   │
│  │  ──────────────────────────────────────────────────────────         │   │
│  │  - Product pages (SSG)                                             │   │
│  │  - Cart (client-side)                                             │   │
│  │  - Checkout (SSR with auth)                                      │   │
│  │  - Order history (protected)                                     │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│                                    ▼                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  Authentication: Clerk                                              │   │
│  │  ──────────────────────────────────────────────────────────         │   │
│  │  - Guest checkout with email                                     │   │
│  │  - Account creation during checkout                              │   │
│  │  - Order history per user                                        │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│                                    ▼                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  Backend: API Routes + Webhooks                                     │   │
│  │  ──────────────────────────────────────────────────────────         │   │
│  │  - Payment processing (Stripe)                                   │   │
│  │  - Order management                                              │   │
│  │  - Inventory management                                          │   │
│  │  - User sync via webhooks                                       │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Implementation

```typescript
// app/checkout/page.tsx
import { auth, currentUser } from "@clerk/nextjs/server";
import { redirect } from "next/navigation";
import { CheckoutForm } from "@/components/CheckoutForm";

export default async function CheckoutPage() {
  const { userId } = await auth();
  
  // If user is signed in, pre-fill their info
  let userData = null;
  if (userId) {
    const user = await currentUser();
    userData = {
      email: user?.emailAddresses[0]?.emailAddress,
      name: user?.fullName,
      address: user?.publicMetadata?.defaultAddress,
    };
  }
  
  return (
    <CheckoutForm
      user={userData}
      isGuest={!userId}
      onComplete={async (orderData) => {
        "use server";
        
        // If guest, ask for email during checkout
        // If signed in, associate order with user ID
        if (userId) {
          await createOrder(userId, orderData);
        } else {
          await createGuestOrder(orderData);
        }
      }}
    />
  );
}

// app/api/webhooks/clerk/route.ts
// Sync user data to e-commerce database

export async function POST(request: Request) {
  const payload = await verifyWebhook(request);
  const { type, data } = payload;
  
  switch (type) {
    case "user.created":
      // Create customer in e-commerce database
      await createCustomer({
        clerkId: data.id,
        email: data.email_addresses[0]?.email_address,
        name: data.full_name,
      });
      break;
      
    case "user.updated":
      // Update customer
      await updateCustomer({
        clerkId: data.id,
        email: data.email_addresses[0]?.email_address,
        name: data.full_name,
        address: data.public_metadata?.defaultAddress,
      });
      break;
      
    case "user.deleted":
      // Anonymize or delete customer data
      await deleteCustomer(data.id);
      break;
  }
  
  return Response.json({ success: true });
}
```

### Key Features

| Feature | Implementation |
|---------|----------------|
| Guest Checkout | Optional authentication |
| Account Creation | During checkout flow |
| Order History | Scoped by userId |
| Address Management | User metadata |
| Payment Integration | Stripe + user metadata |
| User Sync | Webhooks for customer sync |

---

## Use Case 6: Admin Dashboard

### Example: Internal Admin Tool

**Characteristics:**
- Admin-only access
- User management
- Analytics
- System settings

### Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    Admin Dashboard Architecture                            │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  Frontend: Next.js + Admin UI                                       │   │
│  │  ──────────────────────────────────────────────────────────         │   │
│  │  - Admin-only routes                                               │   │
│  │  - User management UI                                              │   │
│  │  - Analytics dashboards                                           │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│                                    ▼                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  Authentication: Clerk + RBAC                                       │   │
│  │  ──────────────────────────────────────────────────────────         │   │
│  │  - Admin role required                                            │   │
│  │  - IP whitelisting                                               │   │
│  │  - MFA enforced                                                  │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│                                    ▼                                        │
│  ────▶┌─────────────────────────────────────────────────────────────────────┐   │
│  │  Backend: Admin APIs                                                  │   │
│  │  ──────────────────────────────────────────────────────────         │   │
│  │  - Admin-only endpoints                                            │   │
│  │  - Audit logging                                                   │   │
│  │  - User management operations                                     │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Implementation

```typescript
// app/admin/layout.tsx
import { auth, clerkClient } from "@clerk/nextjs/server";
import { redirect } from "next/navigation";

export default async function AdminLayout({ children }) {
  const { userId } = await auth();
  
  if (!userId) {
    redirect("/sign-in");
  }
  
  // Check admin status
  const user = await clerkClient().users.getUser(userId);
  const role = user.publicMetadata?.role;
  
  if (role !== "admin") {
    redirect("/dashboard");
  }
  
  return (
    <div className="admin-layout">
      <AdminSidebar />
      <main>{children}</main>
    </div>
  );
}

// app/actions/admin.ts
"use server";

import { auth, clerkClient } from "@clerk/nextjs/server";
import { revalidatePath } from "next/cache";

export async function assignUserRole(userId: string, role: string) {
  const { userId: adminId } = await auth();
  
  if (!adminId) {
    throw new Error("Unauthorized");
  }
  
  // Verify admin status
  const admin = await clerkClient().users.getUser(adminId);
  if (admin.publicMetadata?.role !== "admin") {
    throw new Error("Insufficient permissions");
  }
  
  // Update user role
  await clerkClient().users.updateUser(userId, {
    publicMetadata: {
      role,
      roleUpdatedAt: new Date().toISOString(),
      roleUpdatedBy: adminId,
    },
  });
  
  revalidatePath("/admin/users");
  return { success: true };
}

// app/admin/users/page.tsx
import { clerkClient } from "@clerk/nextjs/server";
import { auth } from "@clerk/nextjs/server";

export default async function AdminUsersPage() {
  const { userId } = await auth();
  
  // Ensure admin access
  const user = await clerkClient().users.getUser(userId);
  if (user.publicMetadata?.role !== "admin") {
    redirect("/dashboard");
  }
  
  // Get all users
  const users = await clerkClient().users.getUserList();
  
  return <UserManagementTable users={users.data} />;
}
```

### Key Features

| Feature | Implementation |
|---------|----------------|
| Admin Routes | Route group protection |
| User Management | Clerk SDK for user operations |
| Role Assignment | Admin-only Server Actions |
| Audit Logging | All admin actions logged |
| Analytics | Admin-only dashboard |

---

## Use Case 7: API-First Application

### Example: Headless CMS Backend

**Characteristics:**
- No frontend UI
- API-only authentication
- Token-based access
- Rate limiting

### Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    API-First Application Architecture                      │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  Clients: Web, Mobile, Third-party                                  │   │
│  │  ──────────────────────────────────────────────────────────         │   │
│  │  - API requests with JWT tokens                                    │   │
│  │  - Service accounts for automation                                │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│                                    ▼                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  Authentication: Clerk API + JWT                                    │   │
│  │  ──────────────────────────────────────────────────────────         │   │
│  │  - JWT verification                                               │   │
│  │  - API key authentication                                         │   │
│  │  - Rate limiting                                                  │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│                                    ▼                                        │
│  ────▶┌─────────────────────────────────────────────────────────────────────┐   │
│  │  Backend: API Routes + Services                                       │   │
│  │  ──────────────────────────────────────────────────────────         │   │
│  │  - Public endpoints                                                │   │
│  │  - Protected endpoints                                            │   │
│  │  - Admin endpoints                                                │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Implementation

```typescript
// lib/api-auth.ts
import { getAuth } from "@clerk/nextjs/server";
import { NextRequest, NextResponse } from "next/server";

export function requireAuth(handler: Function) {
  return async (request: NextRequest, ...args: any[]) => {
    const { userId } = getAuth(request);
    
    if (!userId) {
      return NextResponse.json(
        { error: "Authentication required" },
        { status: 401 }
      );
    }
    
    return handler(request, { ...args, userId });
  };
}

export function requireApiKey(handler: Function) {
  return async (request: NextRequest, ...args: any[]) => {
    const apiKey = request.headers.get("x-api-key");
    
    if (!apiKey || !isValidApiKey(apiKey)) {
      return NextResponse.json(
        { error: "Invalid API key" },
        { status: 401 }
      );
    }
    
    return handler(request, ...args);
  };
}

// app/api/v1/posts/route.ts
import { requireAuth } from "@/lib/api-auth";

export const GET = requireAuth(async (request: NextRequest, { userId }) => {
  const posts = await getPostsForUser(userId);
  return NextResponse.json({ posts });
});

export const POST = requireAuth(async (request: NextRequest, { userId }) => {
  const body = await request.json();
  const post = await createPost({
    ...body,
    authorId: userId,
  });
  return NextResponse.json({ post }, { status: 201 });
});

// app/api/v1/admin/route.ts
import { requireAuth, requireRole } from "@/lib/api-auth";

export const GET = requireAuth(
  requireRole("admin", async (request: NextRequest, { userId }) => {
    const stats = await getSystemStats();
    return NextResponse.json({ stats });
  })
);
```

### Key Features

| Feature | Implementation |
|---------|----------------|
| JWT Authentication | Clerk token verification |
| API Key Auth | Service account tokens |
| Rate Limiting | API middleware |
| Role-Based Access | Admin-only endpoints |
| OAuth2 Support | Clerk OAuth flows |

---

## Quick Reference: Use Case Patterns

| Use Case | Key Features | Clerk Components |
|----------|--------------|------------------|
| Consumer App | Social login, simple permissions | ClerkProvider, useUser |
| SaaS App | Organizations, RBAC, billing | Organizations, roles |
| Enterprise | SSO, SCIM, audit logs | SAML/OIDC, SCIM |
| Mobile | Native auth, biometrics | React Native SDK |
| E-Commerce | Guest checkout, user sync | Webhooks, metadata |
| Admin | Admin roles, user management | Role checking, APIs |
| API-First | Token auth, rate limiting | JWT, API protection |

---

## Key Takeaways

1. **Clerk adapts to any application type** — From consumer to enterprise
2. **Use Organizations for multi-tenancy** — SaaS applications need orgs
3. **Use webhooks for user sync** — Keep your database in sync
4. **Use metadata for user data** — Store application-specific data
5. **Use roles for access control** — Admin, member, guest
6. **Use MFA for security** — Especially for admin accounts
7. **Use SSO for enterprise** — SAML/OIDC integration
8. **Use JWT for API access** — Stateless token-based auth

---

## Ready to Build?

This primer covers real-world use cases with Clerk. Now proceed to:

- **Part 1: Foundations** for initial implementation
- **Part 2: Server-Side Security** for API protection
- **Part 3: Multi-Tenant SaaS** for organization patterns
- **Part 4: Extending Clerk** for webhook integration

**Build your use case with Clerk!**
