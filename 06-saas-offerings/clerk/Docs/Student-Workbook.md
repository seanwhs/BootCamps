# Student Workbook: Mastering Clerk Authentication for Modern Web Applications

## A Hands-On Companion to the Complete Series

---

## About This Workbook

This workbook is designed to accompany the "Mastering Clerk Authentication for Modern Web Applications" series. It provides structured exercises, code completion tasks, reflection questions, and checkpoints to reinforce your learning.

**How to Use This Workbook:**
1. Read each chapter of the series before starting the corresponding workbook section
2. Complete the exercises as you go - they build on each other
3. Use the code snippets as starting points, then extend them
4. Check your answers against the provided solutions
5. Reflect on what you've learned after each module

---

## Part 0: Introduction & Setup

### Pre-Work Checklist

Before starting the series, complete these tasks:

- [ ] Create a Clerk account at [clerk.com](https://clerk.com)
- [ ] Install Node.js (v18.17.0 or higher)
- [ ] Install a code editor (VS Code recommended)
- [ ] Install Git
- [ ] Install a package manager (npm, pnpm, or yarn)
- [ ] Set up a PostgreSQL database (for later parts)

### Exercise 0.1: Install Dependencies

Run these commands to set up your project:

```bash
# Create project directory
mkdir clerk-mastery-series
cd clerk-mastery-series

# Create a new Next.js project
npx create-next-app@latest part-1-zero-config-auth --typescript --tailwind --app

# Navigate to the project
cd part-1-zero-config-auth

# Install Clerk
npm install @clerk/nextjs
```

**Question:** What versions of Next.js, React, and Clerk did you install? Record them below:

- Next.js: ____________________
- React: _____________________
- Clerk: _____________________

---

### Exercise 0.2: Environment Setup

Create a `.env.local` file in your project root:

```env
# .env.local
# Replace with your actual Clerk keys
NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY=pk_test_xxxxxxxxxxxx
CLERK_SECRET_KEY=sk_test_xxxxxxxxxxxx
```

**Question:** Where can you find these keys in the Clerk Dashboard?

Answer: ___________________________________________________________________________
_________________________________________________________________________________

---

### Exercise 0.3: Project Structure

Create the following folder structure (for the complete series):

```
clerk-mastery-series/
├── part-1-zero-config-auth/
│   ├── app/
│   │   ├── layout.tsx
│   │   ├── page.tsx
│   │   ├── sign-in/[[...sign-in]]/
│   │   │   └── page.tsx
│   │   ├── sign-up/[[...sign-up]]/
│   │   │   └── page.tsx
│   │   └── dashboard/
│   │       └── page.tsx
│   ├── middleware.ts
│   ├── .env.local
│   ├── next.config.js
│   ├── package.json
│   └── tsconfig.json
├── part-2-server-side-security/
├── part-3-multi-tenant-saas/
├── part-4-metadata-webhooks/
└── part-5-react19-nextjs16/
```

**Reflection:** Why is it helpful to have separate folders for each part of the series?

_________________________________________________________________________________
_________________________________________________________________________________

---

## Part 1: Foundations of Modern Authentication

### Exercise 1.1: ClerkProvider Setup

**Task:** Complete the code for the root layout with ClerkProvider.

```tsx
// app/layout.tsx
import type { Metadata } from "next";
import { Inter } from "next/font/google";
import "./globals.css";
// TODO: Import ClerkProvider from @clerk/nextjs

const inter = Inter({ subsets: ["latin"] });

export const metadata: Metadata = {
  title: "Clerk Mastery Series - Part 1",
  description: "Learning modern authentication with Clerk in Next.js 16",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    // TODO: Wrap the application with ClerkProvider
    // TODO: The publishable key should be loaded from environment variables
    
  );
}
```

**Solution Check:**
- [ ] ClerkProvider wraps the entire application
- [ ] publishableKey is loaded from `NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY`
- [ ] The font is applied to the body
- [ ] The HTML document has the correct structure

---

### Exercise 1.2: Middleware Protection

**Task:** Complete the middleware to protect the `/dashboard` route.

```tsx
// middleware.ts
import { clerkMiddleware, createRouteMatcher } from "@clerk/nextjs/server";

// TODO: Define which routes should be protected
const isProtectedRoute = createRouteMatcher([
  // TODO: Add routes that require authentication
]);

export default clerkMiddleware((auth, req) => {
  // TODO: Protect the route if it's in the protected list
  // TODO: Clerk should automatically redirect to sign-in
});

export const config = {
  matcher: [
    // TODO: Add the matcher to skip Next.js internals and static files
  ],
};
```

**Challenge:** Add protection for `/profile`, `/settings`, and `/organization` routes.

**Solution Check:**
- [ ] `/dashboard` route is protected
- [ ] Middleware redirects to sign-in when not authenticated
- [ ] Static files and Next.js internals are skipped

---

### Exercise 1.3: Sign-In and Sign-Up Pages

**Task:** Create the sign-in page using Clerk's prebuilt component.

```tsx
// app/sign-in/[[...sign-in]]/page.tsx
import { SignIn } from "@clerk/nextjs";

export default function SignInPage() {
  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-50">
      {/* TODO: Render the SignIn component */}
      {/* TODO: Configure afterSignInUrl to redirect to /dashboard */}
    </div>
  );
}
```

**Task:** Create the sign-up page.

```tsx
// app/sign-up/[[...sign-up]]/page.tsx
import { SignUp } from "@clerk/nextjs";

export default function SignUpPage() {
  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-50">
      {/* TODO: Render the SignUp component */}
      {/* TODO: Configure afterSignUpUrl to redirect to /dashboard */}
    </div>
  );
}
```

**Reflection:** What happens if a user who is already signed in visits the sign-in page?

_________________________________________________________________________________
_________________________________________________________________________________

---

### Exercise 1.4: Conditional UI Rendering

**Task:** Create a homepage that shows different content for authenticated vs unauthenticated users.

```tsx
// app/page.tsx
import { auth } from "@clerk/nextjs/server";
import Link from "next/link";
import { UserButton } from "@clerk/nextjs";

export default async function HomePage() {
  // TODO: Check if the user is authenticated
  const { userId } = await auth();
  const isAuthenticated = !!userId;

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100">
      <header className="bg-white shadow-sm border-b border-gray-200">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center">
              <span className="text-2xl font-bold text-indigo-600">Clerk Mastery</span>
              <span className="ml-2 text-sm text-gray-500">Part 1</span>
            </div>
            
            <nav className="flex items-center space-x-4">
              {isAuthenticated ? (
                // TODO: Show UserButton with sign-out
                // TODO: Show a link to the dashboard
              ) : (
                // TODO: Show "Sign In" and "Get Started" buttons
              )}
            </nav>
          </div>
        </div>
      </header>

      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-16">
        {/* TODO: Show different content based on authentication status */}
        {/* Authenticated: Show welcome message and dashboard link */}
        {/* Unauthenticated: Show marketing content and sign-up link */}
      </main>
    </div>
  );
}
```

**Challenge:** Add feature cards below the main content showing what users can do with the app.

---

### Exercise 1.5: Protected Dashboard

**Task:** Create a protected dashboard page.

```tsx
// app/dashboard/page.tsx
import { auth, currentUser } from "@clerk/nextjs/server";
import { redirect } from "next/navigation";
import { UserButton } from "@clerk/nextjs";
import Link from "next/link";

export default async function DashboardPage() {
  // TODO: Check authentication
  // TODO: Redirect to sign-in if not authenticated
  // TODO: Fetch the current user

  // TODO: Extract user details (email, name, etc.)

  return (
    <div className="min-h-screen bg-gray-50">
      <nav className="bg-white shadow-sm border-b border-gray-200">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center">
              <Link href="/" className="text-xl font-bold text-indigo-600">
                Clerk Mastery
              </Link>
              <span className="ml-3 text-sm text-gray-500">Dashboard</span>
            </div>
            
            <div className="flex items-center space-x-4">
              <Link href="/profile" className="text-gray-600 hover:text-indigo-600">
                Profile
              </Link>
              {/* TODO: Add UserButton with afterSignOutUrl */}
            </div>
          </div>
        </div>
      </nav>

      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
        <div className="bg-white rounded-lg shadow-sm p-6 mb-8">
          <h1 className="text-2xl font-bold text-gray-900">
            {/* TODO: Show welcome message with user's name */}
          </h1>
          <div className="mt-2 text-gray-600 space-y-1">
            {/* TODO: Show user email, user ID, session ID, and organization ID (if any) */}
          </div>
        </div>

        {/* TODO: Add dashboard cards: Analytics, Settings, Team */}
      </main>
    </div>
  );
}
```

**Challenge:** Add a "Session Information" section that shows the authentication status and session details.

---

### Exercise 1.6: Profile Page

**Task:** Create a user profile page.

```tsx
// app/profile/page.tsx
import { auth, currentUser } from "@clerk/nextjs/server";
import { redirect } from "next/navigation";
import { UserButton } from "@clerk/nextjs";
import Link from "next/link";

export default async function ProfilePage() {
  // TODO: Check authentication and fetch user data

  // TODO: Extract user details:
  // - Email addresses
  // - Phone numbers
  // - Full name
  // - Username
  // - Created at
  // - External accounts (OAuth)

  return (
    <div className="min-h-screen bg-gray-50">
      {/* TODO: Build navigation with links to dashboard and profile */}
      
      <main className="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
        {/* TODO: Profile header with avatar and name */}
        
        {/* TODO: Account Details section with:
          - Email addresses (with verification status)
          - Phone numbers
          - Connected accounts (OAuth providers)
          - Account information (joined date, user ID)
        */}
        
        {/* TODO: Profile Management section with UserButton */}
      </main>
    </div>
  );
}
```

**Challenge:** Display the user's full name, email, username, and account creation date. Show verification status for emails.

---

### Exercise 1.7: Component Customization

**Task:** Customize Clerk's appearance using the `appearance` prop.

```tsx
// app/layout.tsx (updated)
import { ClerkProvider } from "@clerk/nextjs";

export default function RootLayout({ children }) {
  return (
    <ClerkProvider
      appearance={{
        // TODO: Set primary color to indigo-600 (#4F46E5)
        // TODO: Set background color to white (#FFFFFF)
        // TODO: Set text color to gray-800 (#1F2937)
        // TODO: Set border radius to 0.375rem
        
        elements: {
          // TODO: Style the card with shadow, border, and rounded corners
          // TODO: Style the primary button with indigo colors
          // TODO: Style footer links with indigo colors
        },
        
        layout: {
          // TODO: Place social buttons at the bottom
          // TODO: Use block buttons (full width)
        },
      }}
    >
      {children}
    </ClerkProvider>
  );
}
```

**Challenge:** Create a dark theme for the Clerk components by setting `baseTheme: dark` from `@clerk/themes`.

---

### Part 1 - Checkpoint Quiz

**Multiple Choice:**

1. What is the primary benefit of stateless token-based authentication?
   - [ ] A) Easier to implement than session-based auth
   - [ ] B) No server-side session storage needed
   - [ ] C) Works without cookies
   - [ ] D) Automatically encrypts all data

2. Which environment variable should NEVER be exposed to the client?
   - [ ] A) NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY
   - [ ] B) CLERK_SECRET_KEY
   - [ ] C) NEXT_PUBLIC_APP_URL
   - [ ] D) NEXT_PUBLIC_CLERK_SIGN_IN_URL

3. What does `auth().protect()` do in middleware?
   - [ ] A) Encrypts the user's password
   - [ ] B) Protects against CSRF attacks
   - [ ] C) Redirects unauthenticated users to sign-in
   - [ ] D) Validates the user's email address

**Short Answer:**

4. What are the three authentication factors? Give an example of each.

_________________________________________________________________________________
_________________________________________________________________________________
_________________________________________________________________________________

5. Explain the difference between `<SignedIn>` and `<SignedOut>` components.

_________________________________________________________________________________
_________________________________________________________________________________

**Code Challenge:**

6. Write the code to protect the `/api/admin` route in middleware.

_________________________________________________________________________________
_________________________________________________________________________________
_________________________________________________________________________________

---

## Part 2: Server-Side Security

### Exercise 2.1: Custom Auth Helpers

**Task:** Create custom authentication helpers with type safety.

```tsx
// lib/auth-helpers.ts
import { auth, currentUser } from "@clerk/nextjs/server";

export type AuthContext = {
  userId: string;
  sessionId: string;
  orgId: string | null;
  role: string | null;
  permissions: string[];
  isAuthenticated: boolean;
};

export async function getAuthContext(): Promise<AuthContext> {
  // TODO: Get the raw auth data from Clerk
  
  // TODO: If no userId, throw an error
  
  // TODO: Fetch the full user to get metadata and role information
  
  // TODO: Extract role from public metadata
  
  // TODO: Extract permissions from public metadata
  
  // TODO: Return the AuthContext object
}

export async function hasRole(requiredRole: string): Promise<boolean> {
  // TODO: Check if the current user has the required role
  // TODO: Return true if the user has the role, false otherwise
}

export async function hasPermissions(requiredPermissions: string[]): Promise<boolean> {
  // TODO: Check if the current user has all required permissions
  // TODO: Return true if the user has ALL permissions, false otherwise
}
```

**Challenge:** Add a `requireAuth` helper that redirects to sign-in if not authenticated.

---

### Exercise 2.2: Permission System

**Task:** Create a centralized permission system.

```tsx
// lib/permissions.ts
export const PERMISSIONS = {
  // TODO: Define permissions for:
  // - User management (read, write, delete, list)
  // - Content management (read, write, delete, publish)
  // - Admin functions (access, settings, logs)
  // - Organization management (read, write, delete, members)
};

export const ROLE_PERMISSIONS = {
  // TODO: Define permission sets for:
  // - guest: Minimal permissions
  // - user: Standard authenticated user
  // - moderator: Content management permissions
  // - admin: All permissions
};

export function hasPermission(userRole: string, permission: string): boolean {
  // TODO: Check if a user has a specific permission
  // TODO: Return true if the user has the permission, false otherwise
}

export function canAccessRoute(userRole: string, path: string): boolean {
  // TODO: Check if a user can access a specific route
  // TODO: Return true if the user can access the route, false otherwise
}
```

**Challenge:** Add `ROUTE_PERMISSIONS` that maps routes to required permissions.

---

### Exercise 2.3: Protected API Routes

**Task:** Create a protected API route that requires authentication.

```tsx
// app/api/auth/me/route.ts
import { NextRequest, NextResponse } from "next/server";
import { auth, currentUser } from "@clerk/nextjs/server";

export async function GET(request: NextRequest) {
  try {
    // TODO: Check authentication using Clerk's auth helper
    
    // TODO: If not authenticated, return 401 with error message
    
    // TODO: Get the current user using currentUser()
    
    // TODO: If user not found, return 404
    
    // TODO: Log the access for auditing
    
    // TODO: Return user data (exclude sensitive information)
    
  } catch (error) {
    // TODO: Return 500 with error message
  }
}
```

**Challenge:** Add a POST handler that processes data from authenticated users.

---

### Exercise 2.4: Admin-Only API

**Task:** Create an admin-only API endpoint.

```tsx
// app/api/admin/route.ts
import { NextRequest, NextResponse } from "next/server";
import { getAuthContext, requireRole } from "@/lib/auth-helpers";

export async function GET(request: NextRequest) {
  try {
    // TODO: Require admin role using requireRole
    // TODO: This should throw if the user is not authenticated or not an admin
    
    // TODO: Log the admin access
    
    // TODO: Gather admin dashboard statistics
    // - Total users
    // - Active sessions
    // - Recent signups
    
    // TODO: Return dashboard data
    
  } catch (error: any) {
    // TODO: Handle different error types (401, 403, 500)
  }
}
```

**Challenge:** Add a route to list all users (admin only) using the Clerk SDK.

---

### Exercise 2.5: Server Actions with Authentication

**Task:** Create a Server Action that updates user preferences with authentication.

```tsx
// app/actions/auth-actions.ts
"use server";

import { auth, clerkClient } from "@clerk/nextjs/server";
import { revalidatePath } from "next/cache";
import { z } from "zod";

const UpdatePreferencesSchema = z.object({
  theme: z.enum(["light", "dark", "system"]),
  notifications: z.boolean(),
  language: z.string().default("en"),
});

type UpdatePreferencesData = z.infer<typeof UpdatePreferencesSchema>;

export async function updateUserPreferences(data: UpdatePreferencesData) {
  try {
    // TODO: Check authentication
    
    // TODO: If not authenticated, return error
    
    // TODO: Validate the data using Zod
    
    // TODO: Get the current user
    
    // TODO: Update user metadata with preferences
    
    // TODO: Revalidate the profile page
    
    // TODO: Return success
    
  } catch (error: any) {
    // TODO: Handle Zod validation errors
    
    // TODO: Handle other errors
  }
}
```

**Challenge:** Add a Server Action to get session information.

---

### Exercise 2.6: Profile Editor Component

**Task:** Create a client component that uses Server Actions.

```tsx
// app/components/ProfileEditor.tsx
"use client";

import { useState } from "react";
import { updateUserProfile } from "@/app/actions/auth-actions";
import { useUser } from "@clerk/nextjs";

export default function ProfileEditor({ initialData }: ProfileEditorProps) {
  const { user, isLoaded } = useUser();
  const [isLoading, setIsLoading] = useState(false);
  const [message, setMessage] = useState<{
    type: "success" | "error";
    text: string;
  } | null>(null);
  
  const [formData, setFormData] = useState(initialData);
  
  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    // TODO: Set loading state
    
    // TODO: Call the Server Action
    
    // TODO: Handle success/error responses
  };
  
  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) => {
    const { name, value } = e.target;
    setFormData(prev => ({ ...prev, [name]: value }));
  };
  
  // TODO: Check if user is loading
    
  // TODO: Check if user is authenticated
  
  return (
    <form onSubmit={handleSubmit}>
      {/* TODO: Build the form with:
        - Full Name input
        - Username input
        - Bio textarea
        - Submit button
      */}
      
      {/* TODO: Show status messages */}
    </form>
  );
}
```

**Challenge:** Add form validation and character count for the bio field.

---

### Part 2 - Checkpoint Quiz

**Multiple Choice:**

1. What does the `auth()` helper return in Next.js Server Components?
   - [ ] A) The full user object
   - [ ] B) A JWT token
   - [ ] C) An object with userId, sessionId, and orgId
   - [ ] D) The session cookie

2. How do you check if a user has the "admin" role in a Server Action?
   - [ ] A) `if (user.role === "admin")`
   - [ ] B) `if (user.publicMetadata.role === "admin")`
   - [ ] C) `if (auth().has({ role: "admin" }))`
   - [ ] D) Both A and B

3. What status code should you return when a user is authenticated but lacks permissions?
   - [ ] A) 401 Unauthorized
   - [ ] B) 403 Forbidden
   - [ ] C) 404 Not Found
   - [ ] D) 400 Bad Request

**Short Answer:**

4. Explain the difference between `auth()` and `currentUser()` in Server Components.

_________________________________________________________________________________
_________________________________________________________________________________

5. What is the principle of least privilege and how does it apply to authentication?

_________________________________________________________________________________
_________________________________________________________________________________

**Code Challenge:**

6. Write a Server Action that changes a user's password with authentication.

_________________________________________________________________________________
_________________________________________________________________________________
_________________________________________________________________________________

---

## Part 3: Multi-Tenant SaaS Architecture

### Exercise 3.1: Organization Helpers

**Task:** Create organization helper functions.

```tsx
// lib/org-helpers.ts
import { clerkClient } from "@clerk/nextjs/server";
import { OrganizationRole } from "@/lib/auth-helpers";
import { logAuthEvent } from "@/lib/auth-helpers";

export async function createOrganization(
  userId: string,
  name: string,
  slug: string,
  metadata?: Record<string, unknown>
) {
  // TODO: Create an organization using clerkClient()
  // TODO: Log the creation event
  // TODO: Return the organization
}

export async function getOrganization(orgId: string) {
  // TODO: Get an organization by ID
  // TODO: Return the organization or null if not found
}

export async function inviteUserToOrganization(
  orgId: string,
  email: string,
  role: OrganizationRole,
  inviterUserId: string
) {
  // TODO: Create an invitation using clerkClient()
  // TODO: Log the invitation event
  // TODO: Return the invitation
}

export async function removeMemberFromOrganization(orgId: string, userId: string) {
  // TODO: Remove a member from an organization
}

export async function updateMemberRole(
  orgId: string,
  userId: string,
  role: OrganizationRole
) {
  // TODO: Update a member's role in an organization
}
```

**Challenge:** Add a function to list all members of an organization.

---

### Exercise 3.2: Organization Selection Page

**Task:** Create the organization selection page.

```tsx
// app/organization/select/page.tsx
import { auth, clerkClient } from "@clerk/nextjs/server";
import { redirect } from "next/navigation";
import Link from "next/link";

export default async function OrganizationSelectPage() {
  // TODO: Check authentication
  
  // TODO: Get user's organization memberships
  
  // TODO: If user has no organizations, show create option
  
  // TODO: If user has exactly one organization, redirect to it
  
  // TODO: Show organization selection grid
}
```

**Challenge:** Add organization avatars and role badges to the selection grid.

---

### Exercise 3.3: Organization Creation Page

**Task:** Create the organization creation page.

```tsx
// app/organization/create/page.tsx
"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { useUser } from "@clerk/nextjs";
import { createOrganization } from "@/lib/org-helpers";

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
    
    // TODO: Auto-generate slug from name
  };
  
  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    // TODO: Validate form data
    // TODO: Create the organization
    // TODO: Redirect to the organization dashboard
  };
  
  // TODO: Check if user is loaded
  // TODO: Check if user is authenticated
  
  return (
    <form onSubmit={handleSubmit}>
      {/* TODO: Organization Name input */}
      {/* TODO: Organization Slug input */}
      {/* TODO: Description textarea */}
      {/* TODO: Submit button */}
    </form>
  );
}
```

**Challenge:** Add validation to ensure the slug is unique.

---

### Exercise 3.4: Organization Layout

**Task:** Create the organization layout with switcher.

```tsx
// app/organization/[orgId]/layout.tsx
import { OrganizationSwitcher, UserButton } from "@clerk/nextjs";
import { auth, clerkClient } from "@clerk/nextjs/server";
import { redirect } from "next/navigation";
import Link from "next/link";

export default async function OrganizationLayout({ children, params }) {
  // TODO: Check authentication
  
  // TODO: Get organization details
  
  // TODO: If organization not found, redirect to select
  
  // TODO: Check if user is a member of the organization
  
  // TODO: Build the layout with:
  // - Header with organization switcher and user button
  // - Navigation (Dashboard, Projects, Members, Settings)
  // - Main content area
  
  return (
    // TODO: Layout JSX
  );
}
```

**Challenge:** Show the user's role in the active organization in the header.

---

### Exercise 3.5: Member Management

**Task:** Create the member management page.

```tsx
// app/organization/[orgId]/members/page.tsx
import { auth, clerkClient } from "@clerk/nextjs/server";
import { redirect } from "next/navigation";
import { getAuthContextWithOrg, hasOrganizationRole } from "@/lib/auth-helpers";
import MemberList from "@/app/components/MemberList";
import InviteMemberForm from "@/app/components/InviteMemberForm";

export default async function OrganizationMembersPage({ params }) {
  // TODO: Check authentication
  
  // TODO: Get organization details
  
  // TODO: Get auth context with organization
  
  // TODO: Check if user can manage members (admin or moderator)
  
  // TODO: Get all members
  
  // TODO: Format members for display
  
  return (
    <div>
      {/* TODO: Page title and total member count */}
      {/* TODO: InviteMemberForm (only for admins/moderators) */}
      {/* TODO: MemberList component */}
    </div>
  );
}
```

**Challenge:** Add pagination for large member lists.

---

### Exercise 3.6: Organization Dashboard

**Task:** Create the organization dashboard.

```tsx
// app/organization/[orgId]/page.tsx
import { auth, clerkClient } from "@clerk/nextjs/server";
import { redirect } from "next/navigation";
import { getAuthContextWithOrg } from "@/lib/auth-helpers";

export default async function OrganizationDashboard({ params }) {
  // TODO: Check authentication
  
  // TODO: Get organization details
  
  // TODO: Get auth context
  
  // TODO: Get organization members count
  
  // TODO: Get projects count
  
  return (
    <div>
      {/* TODO: Welcome section with organization name and user role */}
      {/* TODO: Stats grid (Members, Projects, Your Role) */}
      {/* TODO: Quick actions (Invite Members, Create Project, Settings) */}
      {/* TODO: Recent members list */}
    </div>
  );
}
```

**Challenge:** Add a "Recent Activity" section showing recent member actions.

---

### Part 3 - Checkpoint Quiz

**Multiple Choice:**

1. What is the purpose of the `orgId` in Clerk's session token?
   - [ ] A) To identify the user's email domain
   - [ ] B) To identify the active organization
   - [ ] C) To encrypt the session cookie
   - [ ] D) To authenticate the user

2. Which role has the highest level of permissions in an organization?
   - [ ] A) Member
   - [ ] B) Moderator
   - [ ] C) Admin
   - [ ] D) Guest

3. How do you check if a user has a specific role in an organization?
   - [ ] A) `auth().has({ role: "admin" })`
   - [ ] B) `auth().orgRole === "admin"`
   - [ ] C) `orgRole()` function
   - [ ] D) Both A and B

**Short Answer:**

4. Explain the difference between `orgId` and `organizationId` in the context of Clerk and your database.

_________________________________________________________________________________
_________________________________________________________________________________

5. What is the invitation lifecycle in Clerk Organizations?

_________________________________________________________________________________
_________________________________________________________________________________

**Code Challenge:**

6. Write a Server Action that checks if a user is a member of an organization before performing an operation.

_________________________________________________________________________________
_________________________________________________________________________________
_________________________________________________________________________________

---

## Part 4: Extending Clerk

### Exercise 4.1: Prisma Schema

**Task:** Create the Prisma schema for Clerk integration.

```prisma
// prisma/schema.prisma
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

model User {
  // TODO: Add User model fields:
  // - id (String, @id, @default(cuid()))
  // - clerkId (String, @unique, @map("clerk_id"))
  // - email (String, @unique)
  // - name (String?)
  // - username (String?, @unique)
  // - avatarUrl (String?, @map("avatar_url"))
  // - role (String, @default("guest"))
  // - publicMetadata (Json?, @map("public_metadata"))
  // - privateMetadata (Json?, @map("private_metadata"))
  // - preferences (Json?, @default("{}"))
  // - bio (String?)
  // - location (String?)
  // - website (String?)
  // - organizationId (String?, @map("organization_id"))
  // - organizationRole (String?, @map("organization_role"))
  // - syncedAt (DateTime, @default(now()), @map("synced_at"))
  // - lastSignInAt (DateTime?, @map("last_sign_in_at"))
  // - createdAt (DateTime, @default(now()), @map("created_at"))
  // - updatedAt (DateTime, @updatedAt, @map("updated_at"))
  
  // TODO: Add relations (projects, auditLogs, sessions)
  
  // TODO: Add @@map("users")
  // TODO: Add @@index([clerkId], [email], [organizationId])
}

model Project {
  // TODO: Add Project model fields:
  // - id (String, @id, @default(cuid()))
  // - name (String)
  // - description (String?)
  // - status (String, @default("active"))
  // - organizationId (String, @map("organization_id"))
  // - ownerId (String, @map("owner_id"))
  // - metadata (Json?, @default("{}"))
  // - createdAt (DateTime, @default(now()), @map("created_at"))
  // - updatedAt (DateTime, @updatedAt, @map("updated_at"))
  
  // TODO: Add relations (organization, owner)
  
  // TODO: Add @@map("projects")
  // TODO: Add @@index([organizationId], [ownerId])
}
```

**Challenge:** Add an `AuditLog` model for tracking authentication events.

---

### Exercise 4.2: User Synchronization

**Task:** Create user synchronization utilities.

```tsx
// lib/sync.ts
import prisma from "@/lib/db";
import { User } from "@clerk/nextjs/server";
import { logAuthEvent } from "@/lib/auth-helpers";

export async function syncUserWithDatabase(
  clerkUser: User,
  organizationId?: string,
  organizationRole?: string
) {
  // TODO: Extract user data from Clerk
  // - email
  // - name
  // - username
  // - avatarUrl
  
  // TODO: Extract metadata
  // - publicMetadata
  // - privateMetadata
  
  // TODO: Upsert the user in the database
  
  // TODO: Log the sync event
  
  // TODO: Return the user
}

export async function getUserByClerkId(clerkId: string) {
  // TODO: Get a user from the database by Clerk ID
  // TODO: Return the user or null
}

export async function deleteUserFromDatabase(clerkId: string, hardDelete: boolean = false) {
  // TODO: Delete a user from the database
  // TODO: If hardDelete is true, permanently delete the user
  // TODO: If hardDelete is false, soft delete (mark as deleted in metadata)
}
```

**Challenge:** Add a function to update user preferences in the database.

---

### Exercise 4.3: Webhook Signature Verification

**Task:** Create webhook signature verification utilities.

```tsx
// lib/webhook-verify.ts
import { Webhook } from "svix";
import { NextRequest } from "next/server";

export async function verifyWebhookRequest(
  request: NextRequest,
  secret: string
): Promise<unknown> {
  // TODO: Get the raw payload as text
  
  // TODO: Get the signature headers
  // - svix-signature
  // - svix-timestamp
  // - svix-id
  
  // TODO: Validate required headers
  
  try {
    // TODO: Create webhook instance with secret
    
    // TODO: Verify the payload
    
    // TODO: Return the verified payload
  } catch (error) {
    // TODO: Handle verification errors
  }
}

export function parseWebhookEvent(payload: unknown) {
  // TODO: Extract event type and data
  // TODO: Return { type, data }
}

export function getWebhookSecret(): string {
  // TODO: Get the webhook secret from environment
  // TODO: Throw error if not configured
}
```

**Challenge:** Add timestamp validation to prevent replay attacks.

---

### Exercise 4.4: Webhook Endpoint

**Task:** Create the webhook endpoint.

```tsx
// app/api/webhooks/clerk/route.ts
import { NextRequest, NextResponse } from "next/server";
import { verifyWebhookRequest, parseWebhookEvent, getWebhookSecret } from "@/lib/webhook-verify";
import { syncUserWithDatabase, deleteUserFromDatabase } from "@/lib/sync";
import prisma from "@/lib/db";
import { logAuthEvent } from "@/lib/auth-helpers";

export async function POST(request: NextRequest) {
  try {
    // TODO: Get webhook secret
    
    // TODO: Verify the request
    
    // TODO: Parse event type and data
    
    // TODO: Process different event types
    // - user.created
    // - user.updated
    // - user.deleted
    // - session.created
    // - user.organization.created
    // - user.organization.updated
    // - user.organization.deleted
    
    // TODO: Return success response
  } catch (error) {
    // TODO: Return error response
  }
}

async function handleUserCreated(data: any) {
  // TODO: Sync user to database
  // TODO: Create audit log
  // TODO: Log the event
}

async function handleUserUpdated(data: any) {
  // TODO: Sync user to database
  // TODO: Create audit log
}

async function handleUserDeleted(data: any) {
  // TODO: Delete user from database
  // TODO: Create audit log
}

async function handleSessionCreated(data: any) {
  // TODO: Record session in database
  // TODO: Update last sign-in
  // TODO: Create audit log
}
```

**Challenge:** Add idempotency to prevent duplicate webhook processing.

---

### Exercise 4.5: Metadata API

**Task:** Create the metadata management API.

```tsx
// app/api/metadata/route.ts
import { NextRequest, NextResponse } from "next/server";
import { auth, clerkClient } from "@clerk/nextjs/server";
import prisma from "@/lib/db";

export async function GET(request: NextRequest) {
  try {
    // TODO: Check authentication
    
    // TODO: Get user from Clerk
    
    // TODO: Get user from database
    
    // TODO: Return metadata from Clerk and database
  } catch (error) {
    // TODO: Return error response
  }
}

export async function PUT(request: NextRequest) {
  try {
    // TODO: Check authentication
    
    // TODO: Parse request body
    
    // TODO: Validate request (metadataType, data)
    
    // TODO: Update Clerk metadata based on type
    // - public
    // - private
    // - unsafe
    // - preferences
    // - profile
    
    // TODO: Sync user with database
    
    // TODO: Return success response
  } catch (error) {
    // TODO: Return error response
  }
}
```

**Challenge:** Add validation for each metadata type.

---

### Exercise 4.6: Preferences Form

**Task:** Create the user preferences form.

```tsx
// app/components/PreferencesForm.tsx
"use client";

import { useState } from "react";

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

export default function PreferencesForm({ initialPreferences, userId }) {
  const [preferences, setPreferences] = useState<Preferences>({
    // TODO: Set default preferences
    theme: "system",
    notifications: { email: true, push: true, inApp: true },
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
    // TODO: Update preferences
  };
  
  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    // TODO: Save preferences via API
    // TODO: Handle success/error
  };
  
  return (
    <form onSubmit={handleSubmit}>
      {/* TODO: Theme selection (light, dark, system) */}
      {/* TODO: Notifications (email, push, in-app) */}
      {/* TODO: Language selection */}
      {/* TODO: Timezone selection */}
      {/* TODO: Date format selection */}
      {/* TODO: Submit button */}
    </form>
  );
}
```

**Challenge:** Add a "Reset to Defaults" button.

---

### Part 4 - Checkpoint Quiz

**Multiple Choice:**

1. What is the difference between Public and Private metadata in Clerk?
   - [ ] A) Public metadata is encrypted, Private metadata is not
   - [ ] B) Public metadata is readable by clients, Private metadata is server-side only
   - [ ] C) Public metadata is permanent, Private metadata is temporary
   - [ ] D) There is no difference

2. Why is webhook signature verification important?
   - [ ] A) To prevent replay attacks
   - [ ] B) To ensure the webhook came from Clerk
   - [ ] C) To prevent tampering with the payload
   - [ ] D) All of the above

3. Which event is triggered when a user signs up?
   - [ ] A) `user.signup`
   - [ ] B) `user.created`
   - [ ] C) `session.created`
   - [ ] D) `user.registered`

**Short Answer:**

4. What are the three types of metadata in Clerk and when would you use each?

_________________________________________________________________________________
_________________________________________________________________________________
_________________________________________________________________________________

5. Explain the process of synchronizing a user from Clerk to your database.

_________________________________________________________________________________
_________________________________________________________________________________

**Code Challenge:**

6. Write a function that processes a webhook event and handles both success and failure cases.

_________________________________________________________________________________
_________________________________________________________________________________
_________________________________________________________________________________

---

## Part 5: React 19 & Next.js 16

### Exercise 5.1: Enhanced Auth Helpers with Cache

**Task:** Create cached auth helpers using React 19's `cache()` function.

```tsx
// lib/auth-helpers.ts
import { auth, currentUser } from "@clerk/nextjs/server";
import { cache } from "react";
import { redirect } from "next/navigation";

// TODO: Create cached auth helper using cache()
export const getAuth = cache(async () => {
  // TODO: Get auth data using auth()
  // TODO: Return userId, sessionId, orgId
});

// TODO: Create cached current user helper using cache()
export const getCurrentUser = cache(async () => {
  // TODO: Get current user using currentUser()
  // TODO: Return the user
});

// TODO: Create enhanced user helper with all metadata
export const getEnhancedUser = cache(async () => {
  // TODO: Get current user using getCurrentUser()
  // TODO: If user is null, return null
  
  // TODO: Return enhanced user object with:
  // - id, email, name, avatar
  // - role (from public metadata)
  // - preferences (from public metadata)
  // - isVerified (from email verification)
  // - createdAt, lastSignInAt
});

// TODO: Create protect helper for Server Actions
export async function protect() {
  // TODO: Get userId using getAuth()
  // TODO: If not authenticated, redirect to sign-in
  // TODO: Return userId
}

// TODO: Create protectWithRole helper
export async function protectWithRole(requiredRole: string) {
  // TODO: Call protect()
  // TODO: Get enhanced user
  // TODO: Check if user has required role
  // TODO: If not, redirect to dashboard with error
  // TODO: Return userId
}
```

**Challenge:** Add a `getOrgId` helper that returns the current organization ID.

---

### Exercise 5.2: Server Actions with Zod Validation

**Task:** Create a Server Action with Zod validation.

```tsx
// app/actions/projects.ts
"use server";

import { z } from "zod";
import { revalidatePath } from "next/cache";
import prisma from "@/lib/db";
import { protect, getOrgId, getEnhancedUser } from "@/lib/auth-helpers";
import { logAuthEvent } from "@/lib/auth-helpers";

// TODO: Create Zod schema for project validation
const CreateProjectSchema = z.object({
  // TODO: Define schema:
  // - name (string, min 1, max 100)
  // - description (string, max 500, optional)
  // - status (enum: active, archived, draft, default: active)
  // - organizationId (string, optional)
});

export async function createProject(data: CreateProjectData) {
  try {
    // TODO: Protect the action (ensure user is authenticated)
    
    // TODO: Get enhanced user for additional context
    
    // TODO: Validate the data using Zod
    
    // TODO: Determine organization ID
    
    // TODO: Create the project in the database
    
    // TODO: Log the event
    
    // TODO: Revalidate the project list pages
    
    // TODO: Return success with project data
  } catch (error) {
    // TODO: Handle Zod validation errors
    
    // TODO: Handle other errors
  }
}
```

**Challenge:** Add an `updateProject` Server Action that checks ownership.

---

### Exercise 5.3: Server Component with Suspense

**Task:** Create a dashboard page with Suspense for loading states.

```tsx
// app/dashboard/page.tsx
import { Suspense } from "react";
import { getProjects } from "@/app/actions/projects";
import { getEnhancedUser, protect } from "@/lib/auth-helpers";
import { UserButton } from "@clerk/nextjs";
import Link from "next/link";
import { ProjectList } from "@/app/components/ProjectList";
import { LoadingSpinner } from "@/components/LoadingSpinner";

export default async function DashboardPage() {
  // TODO: Protect the route
  
  // TODO: Get enhanced user
  
  // TODO: Get projects (will work with Suspense)
  const projectsResult = await getProjects();
  
  return (
    <div>
      <header>
        {/* TODO: Add header with navigation */}
      </header>
      
      <main>
        {/* TODO: Welcome section with user info */}
        
        <section>
          {/* TODO: Projects section with "New Project" button */}
          
          <Suspense fallback={<LoadingSpinner />}>
            {/* TODO: Show ProjectList or empty state */}
          </Suspense>
        </section>
        
        {/* TODO: Quick stats section */}
      </main>
    </div>
  );
}
```

**Challenge:** Add a loading state that shows skeleton loaders instead of a spinner.

---

### Exercise 5.4: Client Component with useTransition

**Task:** Create a client component that uses `useTransition` for Server Actions.

```tsx
// app/components/ProjectList.tsx
"use client";

import { useState, useTransition } from "react";
import { deleteProject } from "@/app/actions/projects";
import Link from "next/link";

export function ProjectList({ projects }: { projects: Project[] }) {
  const [isPending, startTransition] = useTransition();
  const [localProjects, setLocalProjects] = useState(projects);
  const [error, setError] = useState<string | null>(null);
  
  const handleDelete = (projectId: string, projectName: string) => {
    // TODO: Show confirmation dialog
    
    // TODO: Use startTransition to call deleteProject
    
    // TODO: Update local state on success
    // TODO: Show error on failure
  };
  
  return (
    <div>
      {/* TODO: Show error if present */}
      
      <div className="grid">
        {localProjects.map((project) => (
          <div key={project.id}>
            <Link href={`/projects/${project.id}`}>
              <h3>{project.name}</h3>
            </Link>
            <p>{project.description || "No description"}</p>
            <span>{project.status}</span>
            <button
              onClick={() => handleDelete(project.id, project.name)}
              disabled={isPending}
            >
              Delete
            </button>
          </div>
        ))}
      </div>
      
      {/* TODO: Show "Updating..." when isPending */}
    </div>
  );
}
```

**Challenge:** Add optimistic updates so the UI updates immediately.

---

### Exercise 5.5: Error Boundary

**Task:** Create an error boundary for authentication errors.

```tsx
// app/components/AuthErrorBoundary.tsx
"use client";

import { ErrorBoundary } from "react-error-boundary";
import { useRouter } from "next/navigation";

function AuthErrorFallback({ error, resetErrorBoundary }: any) {
  const router = useRouter();
  
  // TODO: Check if error is authentication-related
  
  // TODO: If auth error, show sign-in prompt
  
  // TODO: Otherwise, show generic error
  
  return (
    <div className="error-container">
      {/* TODO: Error UI with retry and sign-in buttons */}
    </div>
  );
}

export function AuthErrorBoundary({ children }: { children: React.ReactNode }) {
  // TODO: Wrap children with ErrorBoundary
  
  // TODO: Use AuthErrorFallback as fallback component
}
```

**Challenge:** Add error logging to Sentry or another error tracking service.

---

### Exercise 5.6: Optimized API Route

**Task:** Create an optimized API route with caching.

```tsx
// app/api/projects/route.ts
import { NextRequest, NextResponse } from "next/server";
import { cache } from "react";
import prisma from "@/lib/db";
import { protect } from "@/lib/auth-helpers";

// TODO: Cache the database query
const getProjectsWithCache = cache(async (orgId: string) => {
  // TODO: Fetch projects from database
  // TODO: Include owner information
  // TODO: Order by createdAt desc
  // TODO: Limit results
});

export async function GET(request: NextRequest) {
  try {
    // TODO: Protect the route
    
    // TODO: Get organization ID from query params
    
    // TODO: Use cached query
    
    // TODO: Return projects with cache header
  } catch (error) {
    // TODO: Return error response
  }
}

export async function POST(request: NextRequest) {
  try {
    // TODO: Protect the route
    
    // TODO: Parse request body
    
    // TODO: Validate input
    
    // TODO: Create project in database
    
    // TODO: Return created project
  } catch (error) {
    // TODO: Return error response
  }
}
```

**Challenge:** Add pagination to the GET endpoint.

---

### Part 5 - Checkpoint Quiz

**Multiple Choice:**

1. What is the purpose of React's `cache()` function in Server Components?
   - [ ] A) To cache the entire component
   - [ ] B) To prevent duplicate async calls in the same request
   - [ ] C) To store data in the browser
   - [ ] D) To enable server-side rendering

2. What does `useTransition` do in client components?
   - [ ] A) It transitions between pages
   - [ ] B) It prevents UI blocking during async operations
   - [ ] C) It animates component changes
   - [ ] D) It caches component state

3. How do you secure a Server Action in Next.js?
   - [ ] A) Use `auth().protect()` inside the action
   - [ ] B) Wrap the action in a Protected Action component
   - [ ] C) Add `@protected` decorator
   - [ ] D) Server Actions are automatically protected

**Short Answer:**

4. Explain the difference between Server Components and Client Components in Next.js.

_________________________________________________________________________________
_________________________________________________________________________________

5. What is the benefit of using Suspense with Server Components?

_________________________________________________________________________________
_________________________________________________________________________________

**Code Challenge:**

6. Write a Server Action that creates a new project and handles validation errors.

_________________________________________________________________________________
_________________________________________________________________________________
_________________________________________________________________________________

---

## Final Project: Complete Enterprise SaaS Application

### Project Overview

Combine everything you've learned to build a complete enterprise SaaS application with:
- User authentication (email/password + social login)
- Server-side security (RBAC, permissions)
- Multi-tenancy (organizations, teams)
- Database integration (webhooks, sync)
- Modern React 19 features (Server Components, Server Actions)

### Technical Requirements

**1. Authentication (Part 1)**
- [ ] Email/password sign-up and sign-in
- [ ] Google and GitHub social login
- [ ] Protected routes with middleware
- [ ] Custom styled Clerk components

**2. Server-Side Security (Part 2)**
- [ ] Role-Based Access Control (Admin, Moderator, Member, Guest)
- [ ] Protected API routes
- [ ] Server Actions with authentication
- [ ] Audit logging

**3. Multi-Tenancy (Part 3)**
- [ ] Organization creation and management
- [ ] Member invitations
- [ ] Organization switcher
- [ ] Organization-scoped data

**4. Extending Clerk (Part 4)**
- [ ] User metadata management
- [ ] Webhook synchronization with database
- [ ] Headless authentication option
- [ ] User preferences

**5. Modern Patterns (Part 5)**
- [ ] Server Components with authentication
- [ ] Server Actions with Zod validation
- [ ] Suspense and streaming
- [ ] React 19 features (cache, useTransition)

### Deliverables

1. **Complete Application**
   - [ ] All features working
   - [ ] Clean, maintainable code
   - [ ] Proper error handling

2. **Documentation**
   - [ ] README with setup instructions
   - [ ] API documentation
   - [ ] Deployment guide

3. **Deployment**
   - [ ] Deployed to Vercel (or similar)
   - [ ] Production Clerk instance configured
   - [ ] Environment variables secured

### Grading Rubric

| Category | Weight | Criteria |
|----------|--------|----------|
| **Functionality** | 30% | All features work as expected |
| **Code Quality** | 25% | Clean, well-organized, commented code |
| **Security** | 20% | Proper auth checks, input validation |
| **UI/UX** | 15% | Polished, responsive, user-friendly |
| **Documentation** | 10% | Clear, comprehensive instructions |

---

## Reflection Questions

### After Completing the Series

1. What was the most challenging part of learning Clerk authentication? How did you overcome it?

_________________________________________________________________________________
_________________________________________________________________________________
_________________________________________________________________________________

2. Which Part of the series did you find most valuable for your specific use case? Why?

_________________________________________________________________________________
_________________________________________________________________________________
_________________________________________________________________________________

3. How has your understanding of authentication changed after completing this series?

_________________________________________________________________________________
_________________________________________________________________________________
_________________________________________________________________________________

4. What additional features would you add to your Clerk application?

_________________________________________________________________________________
_________________________________________________________________________________
_________________________________________________________________________________

5. How would you adapt the patterns you've learned to a mobile application (React Native)?

_________________________________________________________________________________
_________________________________________________________________________________
_________________________________________________________________________________

6. What are the biggest security considerations you would include for a production deployment?

_________________________________________________________________________________
_________________________________________________________________________________
_________________________________________________________________________________

7. How would you scale the authentication architecture for millions of users?

_________________________________________________________________________________
_________________________________________________________________________________
_________________________________________________________________________________

---

## Additional Resources

### Official Documentation
- [Clerk Documentation](https://clerk.com/docs)
- [Clerk API Reference](https://clerk.com/docs/reference/backend-api)
- [Next.js Documentation](https://nextjs.org/docs)
- [React Documentation](https://react.dev/)

### Community
- [Clerk Discord](https://discord.com/invite/clerk)
- [Clerk GitHub](https://github.com/clerk/clerkjs)
- [Stack Overflow (clerk tag)](https://stackoverflow.com/questions/tagged/clerk)

### Sample Projects
- [Clerk Next.js Examples](https://github.com/clerk/clerk-nextjs-examples)
- [Clerk SaaS Starter Kit](https://github.com/clerk/saas-starter)
- [Enterprise Auth with Clerk](https://github.com/clerk/enterprise-sso)

### Extensions
- [Clerk with Supabase](https://clerk.com/docs/integrations/supabase)
- [Clerk with Firebase](https://clerk.com/docs/integrations/firebase)
- [Clerk with Hasura](https://clerk.com/docs/integrations/hasura)

---

## Answer Key

### Part 1 Checkpoint Quiz

**Multiple Choice:**
1. B) No server-side session storage needed
2. B) CLERK_SECRET_KEY
3. C) Redirects unauthenticated users to sign-in

**Short Answer:**
4. Something you KNOW (password), Something you HAVE (phone, security key), Something you ARE (fingerprint, face ID)
5. `<SignedIn>` renders content only when authenticated; `<SignedOut>` renders content only when not authenticated

**Code Challenge:**
6. See `middleware.ts` with `createRouteMatcher` for `/api/admin`

### Part 2 Checkpoint Quiz

**Multiple Choice:**
1. C) An object with userId, sessionId, and orgId
2. C) `if (auth().has({ role: "admin" }))`
3. B) 403 Forbidden

**Short Answer:**
4. `auth()` returns basic auth data (userId, sessionId); `currentUser()` returns the full user profile
5. Users should have only the minimum permissions needed to perform their tasks

**Code Challenge:**
6. See Server Action with `auth()` and password update

### Part 3 Checkpoint Quiz

**Multiple Choice:**
1. B) To identify the active organization
2. C) Admin
3. D) Both A and B

**Short Answer:**
4. `orgId` is from Clerk's session token; `organizationId` is in your database
5. Pending → Accepted/Revoked/Expired

**Code Challenge:**
6. See Server Action with `getAuthContext()` and organization check

### Part 4 Checkpoint Quiz

**Multiple Choice:**
1. B) Public metadata is readable by clients, Private metadata is server-side only
2. D) All of the above
3. B) `user.created`

**Short Answer:**
4. Public (user preferences), Private (payment IDs), Unsafe (temporary UI state)
5. User signs up → Clerk sends webhook → Your server processes and stores in database

**Code Challenge:**
6. See webhook endpoint with try/catch and idempotency

### Part 5 Checkpoint Quiz

**Multiple Choice:**
1. B) To prevent duplicate async calls in the same request
2. B) It prevents UI blocking during async operations
3. A) Use `auth().protect()` inside the action

**Short Answer:**
4. Server Components run on the server only; Client Components run in the browser
5. Shows loading states while content is being streamed from the server

**Code Challenge:**
6. See Server Action with Zod validation and error handling

---

## Workbook Conclusion

**Congratulations on completing the Clerk Mastery Series Student Workbook!**

You've built a comprehensive understanding of modern authentication with Clerk, from zero-configuration auth to enterprise-grade multi-tenant SaaS applications. You now have:

- ✅ Hands-on experience with all Clerk features
- ✅ Production-ready code samples
- ✅ Understanding of authentication best practices
- ✅ Knowledge of React 19 and Next.js 16 patterns

**Next Steps:**
1. Build your own application using these patterns
2. Deploy to production with security hardening
3. Join the Clerk community to share and learn
4. Explore advanced topics (SSO, MFA, WebAuthn)

**Keep building!** 🚀
