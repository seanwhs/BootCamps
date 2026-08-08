# Part 11: Next.js Routing & Navigation

## Building a Robust Navigation System

Welcome to **Part 11** of the Django REST Framework & Next.js 16 masterclass. Now that our API has powerful filtering and pagination capabilities, we need to build a sophisticated frontend routing and navigation system. In this part, we'll master Next.js's App Router to create a seamless user experience.

In this part, we'll:
- Master dynamic routes and nested routes
- Use route groups for organization
- Create layouts and nested layouts
- Implement loading UI and error boundaries
- Build navigation between pages
- Handle search parameters (URL state)

Think of routing as the **GPS** of your application. It determines where users can go, what they see when they get there, and how they navigate between different parts of the application.

---

## The Target

We'll build a complete routing system:

```
/
├── (auth)/                    # Authentication routes (group)
│   ├── login/
│   │   └── page.tsx
│   ├── register/
│   │   └── page.tsx
│   └── layout.tsx             # Auth layout (no sidebar)
├── (dashboard)/               # Dashboard routes (group)
│   ├── dashboard/
│   │   └── page.tsx
│   ├── projects/
│   │   ├── page.tsx           # List projects
│   │   ├── [id]/
│   │   │   ├── page.tsx       # Project detail
│   │   │   ├── edit/
│   │   │   │   └── page.tsx   # Edit project
│   │   │   └── tasks/
│   │   │       ├── create/
│   │   │       │   └── page.tsx  # Create task in project
│   │   │       └── [taskId]/
│   │   │           └── page.tsx  # Task detail within project
│   │   ├── loading.tsx        # Loading UI for projects
│   │   └── error.tsx          # Error boundary for projects
│   ├── tasks/
│   │   ├── page.tsx           # List tasks
│   │   ├── [id]/
│   │   │   ├── page.tsx       # Task detail
│   │   │   ├── edit/
│   │   │   │   └── page.tsx   # Edit task
│   │   │   └── comments/
│   │   │       └── page.tsx   # Task comments
│   │   ├── create/
│   │   │   └── page.tsx       # Create task
│   │   ├── loading.tsx
│   │   └── error.tsx
│   └── layout.tsx             # Dashboard layout (with sidebar)
├── layout.tsx                 # Root layout
├── page.tsx                   # Landing page
├── loading.tsx                # Global loading
└── error.tsx                  # Global error
```

---

## The Concept

### The App Router Structure

The App Router uses file-based routing:

```
app/
├── page.tsx          → /
├── about/
│   └── page.tsx      → /about
├── blog/
│   ├── page.tsx      → /blog
│   └── [slug]/
│       └── page.tsx  → /blog/my-post
├── (group)/          → Route group (doesn't affect URL)
│   └── page.tsx      → /page
└── layout.tsx        → Shared layout
```

### Route Groups

Route groups `(folder)` allow you to organize routes without affecting the URL path:

```
app/
├── (auth)/           → /login, /register (no /auth in URL)
│   ├── login/
│   │   └── page.tsx
│   └── register/
│       └── page.tsx
└── (dashboard)/      → /dashboard, /projects (no /dashboard in URL)
    ├── dashboard/
    │   └── page.tsx
    └── projects/
        └── page.tsx
```

### Layouts

Layouts are shared UI that wraps pages:

```tsx
// app/(dashboard)/layout.tsx
export default function DashboardLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <div>
      <Sidebar />
      <main>{children}</main>
    </div>
  );
}
```

### Dynamic Routes

Dynamic routes use `[param]` folders:

```
app/
└── projects/
    └── [id]/          → /projects/123
        └── page.tsx   → params: { id: '123' }
```

### Nested Dynamic Routes

Nested routes with multiple parameters:

```
app/
└── projects/
    └── [projectId]/
        └── tasks/
            └── [taskId]/
                └── page.tsx  → /projects/123/tasks/456
                → params: { projectId: '123', taskId: '456' }
```

### Loading UI

Loading files show while pages are loading:

```tsx
// app/projects/loading.tsx
export default function Loading() {
  return <LoadingSpinner />;
}
```

### Error Boundaries

Error files catch errors in their route segment:

```tsx
// app/projects/error.tsx
'use client';

export default function Error({
  error,
  reset,
}: {
  error: Error;
  reset: () => void;
}) {
  return (
    <div>
      <h2>Something went wrong!</h2>
      <button onClick={reset}>Try again</button>
    </div>
  );
}
```

---

## The Implementation

### Step 1: Create the Root Layout (Already Exists)

**frontend/app/layout.tsx** (verify/update)

```tsx
import type { Metadata } from 'next';
import { Inter } from 'next/font/google';
import { ToastProvider } from '@/lib/context/ToastContext';
import { ToastContainer } from '@/components/ui/Toast';
import './globals.css';

const inter = Inter({ 
  subsets: ['latin'],
  display: 'swap',
  variable: '--font-inter',
});

export const metadata: Metadata = {
  title: {
    default: 'TaskFlow - Task Management Platform',
    template: '%s | TaskFlow',
  },
  description: 'A modern task management platform built with Django and Next.js',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en" className={inter.variable}>
      <body>
        <ToastProvider>
          {children}
          <ToastContainer />
        </ToastProvider>
      </body>
    </html>
  );
}
```

### Step 2: Create the Landing Page (Already Exists)

**frontend/app/page.tsx** (verify)

```tsx
import Link from 'next/link';
import { Button } from '@/components/ui/Button';

export default function LandingPage() {
  return (
    <div className="min-h-screen">
      {/* Hero Section */}
      <section className="relative overflow-hidden bg-gradient-to-b from-primary-50 to-white">
        <div className="container-custom py-20 md:py-28">
          <div className="grid gap-12 lg:grid-cols-2 lg:gap-16 items-center">
            <div className="space-y-6">
              <div className="inline-flex items-center rounded-full border border-primary-200 bg-primary-50 px-3 py-1 text-sm text-primary-700">
                🚀 Built with Django + Next.js
              </div>
              <h1 className="text-4xl font-bold tracking-tight text-secondary-900 sm:text-5xl md:text-6xl">
                <span className="text-primary-600">TaskFlow</span>
                <br />
                <span className="text-secondary-700">Task Management</span>
              </h1>
              <p className="text-lg text-secondary-600 max-w-xl">
                A modern, open-source task management platform built with Django
                REST Framework and Next.js. Organize your projects, track tasks,
                and collaborate with your team.
              </p>
              <div className="flex flex-wrap gap-4">
                <Link href="/dashboard">
                  <Button size="lg" className="font-semibold">
                    Go to Dashboard
                  </Button>
                </Link>
                <Link href="/register">
                  <Button size="lg" variant="outline" className="font-semibold">
                    Get Started
                  </Button>
                </Link>
              </div>
            </div>
            <div className="hidden lg:block">
              <div className="rounded-lg bg-white p-6 shadow-xl">
                <div className="space-y-4">
                  <div className="flex items-center justify-between border-b border-secondary-200 pb-4">
                    <span className="font-semibold">Recent Tasks</span>
                    <span className="text-sm text-secondary-500">Today</span>
                  </div>
                  {[1, 2, 3].map((i) => (
                    <div
                      key={i}
                      className="flex items-center justify-between rounded-lg bg-secondary-50 p-4"
                    >
                      <div className="flex items-center gap-3">
                        <div className="h-2 w-2 rounded-full bg-primary-500" />
                        <span>Sample Task {i}</span>
                      </div>
                      <span className="text-sm text-secondary-500">In Progress</span>
                    </div>
                  ))}
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Features Section */}
      <section className="border-t border-secondary-200 bg-white py-16 md:py-24">
        <div className="container-custom">
          <div className="text-center">
            <h2 className="text-3xl font-bold tracking-tight text-secondary-900 sm:text-4xl">
              Everything You Need to Stay Productive
            </h2>
            <p className="mt-4 text-lg text-secondary-600">
              Modern task management with all the features you expect.
            </p>
          </div>
          <div className="mt-12 grid gap-8 md:grid-cols-3">
            <div className="rounded-lg border border-secondary-200 p-6 text-center">
              <div className="mx-auto mb-4 flex h-12 w-12 items-center justify-center rounded-full bg-primary-100 text-primary-600">
                📋
              </div>
              <h3 className="text-lg font-semibold">Project Management</h3>
              <p className="mt-2 text-sm text-secondary-600">
                Organize your work into projects with task tracking and progress monitoring.
              </p>
            </div>
            <div className="rounded-lg border border-secondary-200 p-6 text-center">
              <div className="mx-auto mb-4 flex h-12 w-12 items-center justify-center rounded-full bg-primary-100 text-primary-600">
                👥
              </div>
              <h3 className="text-lg font-semibold">Team Collaboration</h3>
              <p className="mt-2 text-sm text-secondary-600">
                Assign tasks, add comments, and collaborate with your team members.
              </p>
            </div>
            <div className="rounded-lg border border-secondary-200 p-6 text-center">
              <div className="mx-auto mb-4 flex h-12 w-12 items-center justify-center rounded-full bg-primary-100 text-primary-600">
                🔒
              </div>
              <h3 className="text-lg font-semibold">Secure & Reliable</h3>
              <p className="mt-2 text-sm text-secondary-600">
                Built with industry-standard security practices and modern architecture.
              </p>
            </div>
          </div>
        </div>
      </section>
    </div>
  );
}
```

### Step 3: Create Authentication Layout

**frontend/app/(auth)/layout.tsx** (create)

```tsx
import Link from 'next/link';

export default function AuthLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <div className="min-h-screen bg-gradient-to-br from-primary-50 via-white to-secondary-50">
      <div className="container-custom py-8">
        <div className="flex justify-center">
          <Link href="/" className="text-2xl font-bold text-primary-600">
            TaskFlow
          </Link>
        </div>
        <div className="mt-8 flex justify-center">
          <div className="w-full max-w-md">{children}</div>
        </div>
      </div>
    </div>
  );
}
```

### Step 4: Create Login Page

**frontend/app/(auth)/login/page.tsx** (create)

```tsx
'use client';

import { useState } from 'react';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/Card';
import { useToast } from '@/lib/context/ToastContext';

export default function LoginPage() {
  const router = useRouter();
  const { addToast } = useToast();
  const [loading, setLoading] = useState(false);
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);

    // For now, just redirect to dashboard (authentication will be added in Phase 3)
    try {
      // Simulate login
      await new Promise(resolve => setTimeout(resolve, 1000));
      addToast('Login successful!', 'success');
      router.push('/dashboard');
    } catch (error) {
      addToast('Login failed. Please try again.', 'error');
    } finally {
      setLoading(false);
    }
  };

  return (
    <Card>
      <CardHeader>
        <CardTitle className="text-center">Welcome Back</CardTitle>
        <p className="text-center text-sm text-secondary-500">
          Sign in to your account to continue
        </p>
      </CardHeader>
      <CardContent>
        <form onSubmit={handleSubmit} className="space-y-4">
          <div>
            <label htmlFor="email" className="block text-sm font-medium text-secondary-700">
              Email
            </label>
            <Input
              id="email"
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              required
              className="mt-1"
              placeholder="you@example.com"
            />
          </div>
          <div>
            <label htmlFor="password" className="block text-sm font-medium text-secondary-700">
              Password
            </label>
            <Input
              id="password"
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required
              className="mt-1"
              placeholder="••••••••"
            />
          </div>
          <Button type="submit" className="w-full" isLoading={loading}>
            Sign In
          </Button>
          <p className="text-center text-sm text-secondary-500">
            Don't have an account?{' '}
            <Link href="/register" className="text-primary-600 hover:underline">
              Sign up
            </Link>
          </p>
        </form>
      </CardContent>
    </Card>
  );
}
```

### Step 5: Create Register Page

**frontend/app/(auth)/register/page.tsx** (create)

```tsx
'use client';

import { useState } from 'react';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/Card';
import { useToast } from '@/lib/context/ToastContext';

export default function RegisterPage() {
  const router = useRouter();
  const { addToast } = useToast();
  const [loading, setLoading] = useState(false);
  const [formData, setFormData] = useState({
    email: '',
    username: '',
    first_name: '',
    last_name: '',
    password: '',
    confirm_password: '',
  });

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setFormData({
      ...formData,
      [e.target.id]: e.target.value,
    });
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    
    if (formData.password !== formData.confirm_password) {
      addToast('Passwords do not match', 'error');
      return;
    }

    setLoading(true);

    try {
      // Simulate registration
      await new Promise(resolve => setTimeout(resolve, 1000));
      addToast('Registration successful! Please login.', 'success');
      router.push('/login');
    } catch (error) {
      addToast('Registration failed. Please try again.', 'error');
    } finally {
      setLoading(false);
    }
  };

  return (
    <Card>
      <CardHeader>
        <CardTitle className="text-center">Create Account</CardTitle>
        <p className="text-center text-sm text-secondary-500">
          Start managing your tasks today
        </p>
      </CardHeader>
      <CardContent>
        <form onSubmit={handleSubmit} className="space-y-4">
          <div>
            <label htmlFor="email" className="block text-sm font-medium text-secondary-700">
              Email *
            </label>
            <Input
              id="email"
              type="email"
              value={formData.email}
              onChange={handleChange}
              required
              className="mt-1"
              placeholder="you@example.com"
            />
          </div>
          <div>
            <label htmlFor="username" className="block text-sm font-medium text-secondary-700">
              Username *
            </label>
            <Input
              id="username"
              type="text"
              value={formData.username}
              onChange={handleChange}
              required
              className="mt-1"
              placeholder="johndoe"
            />
          </div>
          <div className="grid gap-4 sm:grid-cols-2">
            <div>
              <label htmlFor="first_name" className="block text-sm font-medium text-secondary-700">
                First Name
              </label>
              <Input
                id="first_name"
                type="text"
                value={formData.first_name}
                onChange={handleChange}
                className="mt-1"
                placeholder="John"
              />
            </div>
            <div>
              <label htmlFor="last_name" className="block text-sm font-medium text-secondary-700">
                Last Name
              </label>
              <Input
                id="last_name"
                type="text"
                value={formData.last_name}
                onChange={handleChange}
                className="mt-1"
                placeholder="Doe"
              />
            </div>
          </div>
          <div>
            <label htmlFor="password" className="block text-sm font-medium text-secondary-700">
              Password *
            </label>
            <Input
              id="password"
              type="password"
              value={formData.password}
              onChange={handleChange}
              required
              className="mt-1"
              placeholder="••••••••"
            />
          </div>
          <div>
            <label htmlFor="confirm_password" className="block text-sm font-medium text-secondary-700">
              Confirm Password *
            </label>
            <Input
              id="confirm_password"
              type="password"
              value={formData.confirm_password}
              onChange={handleChange}
              required
              className="mt-1"
              placeholder="••••••••"
            />
          </div>
          <Button type="submit" className="w-full" isLoading={loading}>
            Create Account
          </Button>
          <p className="text-center text-sm text-secondary-500">
            Already have an account?{' '}
            <Link href="/login" className="text-primary-600 hover:underline">
              Sign in
            </Link>
          </p>
        </form>
      </CardContent>
    </Card>
  );
}
```

### Step 6: Create Dashboard Layout (Already Exists)

**frontend/app/(dashboard)/layout.tsx** (verify/update)

```tsx
'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { 
  LayoutDashboard, 
  FolderKanban, 
  ListTodo, 
  Users, 
  Settings,
  LogOut
} from 'lucide-react';
import { cn } from '@/lib/utils/helpers';

const navigation = [
  { name: 'Dashboard', href: '/dashboard', icon: LayoutDashboard },
  { name: 'Projects', href: '/projects', icon: FolderKanban },
  { name: 'Tasks', href: '/tasks', icon: ListTodo },
  { name: 'Users', href: '/users', icon: Users },
  { name: 'Settings', href: '/settings', icon: Settings },
];

export default function DashboardLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const pathname = usePathname();

  return (
    <div className="flex min-h-screen">
      {/* Sidebar */}
      <aside className="fixed inset-y-0 left-0 z-50 w-64 border-r border-secondary-200 bg-white">
        <div className="flex h-full flex-col">
          <div className="flex h-16 items-center border-b border-secondary-200 px-6">
            <Link href="/dashboard" className="text-xl font-bold text-primary-600">
              TaskFlow
            </Link>
          </div>
          <nav className="flex-1 space-y-1 p-4">
            {navigation.map((item) => {
              const Icon = item.icon;
              const isActive = pathname === item.href || pathname?.startsWith(item.href + '/');
              return (
                <Link
                  key={item.name}
                  href={item.href}
                  className={cn(
                    'flex items-center gap-3 rounded-lg px-3 py-2 text-sm font-medium transition-colors',
                    isActive
                      ? 'bg-primary-50 text-primary-700'
                      : 'text-secondary-700 hover:bg-secondary-100 hover:text-secondary-900'
                  )}
                >
                  <Icon className="h-5 w-5" />
                  {item.name}
                </Link>
              );
            })}
          </nav>
          <div className="border-t border-secondary-200 p-4">
            <div className="flex items-center gap-3">
              <div className="h-8 w-8 rounded-full bg-primary-100 text-primary-600 flex items-center justify-center">
                JD
              </div>
              <div className="flex-1">
                <p className="text-sm font-medium">John Doe</p>
                <p className="text-xs text-secondary-500">john@example.com</p>
              </div>
              <button className="rounded-md p-1 text-secondary-400 hover:bg-secondary-100 hover:text-secondary-600">
                <LogOut className="h-4 w-4" />
              </button>
            </div>
          </div>
        </div>
      </aside>

      {/* Main Content */}
      <main className="flex-1 pl-64">
        <header className="sticky top-0 z-40 border-b border-secondary-200 bg-white/80 backdrop-blur">
          <div className="flex h-16 items-center justify-between px-6">
            <h1 className="text-xl font-semibold text-secondary-900">
              {navigation.find(n => n.href === pathname)?.name || 'Dashboard'}
            </h1>
          </div>
        </header>
        <div className="p-6">{children}</div>
      </main>
    </div>
  );
}
```

### Step 7: Create Loading States

**frontend/app/(dashboard)/loading.tsx** (create)

```tsx
import { LoadingSpinner } from '@/components/ui/LoadingSpinner';

export default function Loading() {
  return (
    <div className="flex h-[calc(100vh-6rem)] items-center justify-center">
      <LoadingSpinner size="lg" />
    </div>
  );
}
```

**frontend/app/(dashboard)/projects/loading.tsx** (create)

```tsx
import { LoadingSpinner } from '@/components/ui/LoadingSpinner';
import { Card, CardContent } from '@/components/ui/Card';

export default function ProjectsLoading() {
  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <h2 className="text-2xl font-semibold">Projects</h2>
        <div className="h-10 w-32 animate-pulse rounded-md bg-secondary-200" />
      </div>
      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
        {[1, 2, 3, 4, 5, 6].map((i) => (
          <Card key={i} className="animate-pulse">
            <CardContent className="p-6">
              <div className="h-6 w-3/4 rounded bg-secondary-200" />
              <div className="mt-2 h-4 w-1/2 rounded bg-secondary-200" />
              <div className="mt-4 flex items-center gap-2">
                <div className="h-5 w-16 rounded bg-secondary-200" />
                <div className="h-5 w-20 rounded bg-secondary-200" />
              </div>
            </CardContent>
          </Card>
        ))}
      </div>
    </div>
  );
}
```

**frontend/app/(dashboard)/tasks/loading.tsx** (create)

```tsx
import { LoadingSpinner } from '@/components/ui/LoadingSpinner';
import { Card, CardContent } from '@/components/ui/Card';

export default function TasksLoading() {
  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <h2 className="text-2xl font-semibold">Tasks</h2>
        <div className="h-10 w-32 animate-pulse rounded-md bg-secondary-200" />
      </div>
      <div className="space-y-2">
        {[1, 2, 3, 4, 5].map((i) => (
          <Card key={i} className="animate-pulse">
            <CardContent className="p-4">
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-2">
                  <div className="h-5 w-48 rounded bg-secondary-200" />
                  <div className="h-5 w-16 rounded bg-secondary-200" />
                  <div className="h-5 w-16 rounded bg-secondary-200" />
                </div>
                <div className="flex items-center gap-4">
                  <div className="h-4 w-20 rounded bg-secondary-200" />
                  <div className="h-4 w-20 rounded bg-secondary-200" />
                </div>
              </div>
            </CardContent>
          </Card>
        ))}
      </div>
    </div>
  );
}
```

### Step 8: Create Error Boundaries

**frontend/app/(dashboard)/error.tsx** (create)

```tsx
'use client';

import { Button } from '@/components/ui/Button';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/Card';

export default function DashboardError({
  error,
  reset,
}: {
  error: Error & { digest?: string };
  reset: () => void;
}) {
  return (
    <div className="flex h-[calc(100vh-6rem)] items-center justify-center">
      <Card className="max-w-md">
        <CardHeader>
          <CardTitle className="text-danger-600">Something went wrong!</CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          <p className="text-secondary-600">
            {error.message || 'An unexpected error occurred'}
          </p>
          <Button onClick={reset}>Try again</Button>
        </CardContent>
      </Card>
    </div>
  );
}
```

**frontend/app/(dashboard)/projects/error.tsx** (create)

```tsx
'use client';

import { Button } from '@/components/ui/Button';
import { Card, CardContent } from '@/components/ui/Card';

export default function ProjectsError({
  error,
  reset,
}: {
  error: Error & { digest?: string };
  reset: () => void;
}) {
  return (
    <Card>
      <CardContent className="py-12 text-center">
        <p className="text-danger-600 mb-4">Failed to load projects</p>
        <Button onClick={reset}>Try again</Button>
      </CardContent>
    </Card>
  );
}
```

### Step 9: Create Not Found Pages

**frontend/app/(dashboard)/projects/[id]/not-found.tsx** (create)

```tsx
import Link from 'next/link';
import { Button } from '@/components/ui/Button';
import { Card, CardContent } from '@/components/ui/Card';

export default function ProjectNotFound() {
  return (
    <Card>
      <CardContent className="py-12 text-center">
        <div className="text-6xl mb-4">🔍</div>
        <h2 className="text-2xl font-semibold mb-2">Project Not Found</h2>
        <p className="text-secondary-500 mb-6">
          The project you're looking for doesn't exist or you don't have access to it.
        </p>
        <Link href="/projects">
          <Button>View All Projects</Button>
        </Link>
      </CardContent>
    </Card>
  );
}
```

**frontend/app/(dashboard)/tasks/[id]/not-found.tsx** (create)

```tsx
import Link from 'next/link';
import { Button } from '@/components/ui/Button';
import { Card, CardContent } from '@/components/ui/Card';

export default function TaskNotFound() {
  return (
    <Card>
      <CardContent className="py-12 text-center">
        <div className="text-6xl mb-4">🔍</div>
        <h2 className="text-2xl font-semibold mb-2">Task Not Found</h2>
        <p className="text-secondary-500 mb-6">
          The task you're looking for doesn't exist or you don't have access to it.
        </p>
        <Link href="/tasks">
          <Button>View All Tasks</Button>
        </Link>
      </CardContent>
    </Card>
  );
}
```

### Step 10: Create Settings Page

**frontend/app/(dashboard)/settings/page.tsx** (create)

```tsx
import { Metadata } from 'next';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';

export const metadata: Metadata = {
  title: 'Settings',
  description: 'Manage your account settings',
};

export default function SettingsPage() {
  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-semibold">Settings</h1>
      
      <Card>
        <CardHeader>
          <CardTitle>Profile</CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          <div>
            <label htmlFor="displayName" className="block text-sm font-medium text-secondary-700">
              Display Name
            </label>
            <Input id="displayName" value="John Doe" className="mt-1" />
          </div>
          <div>
            <label htmlFor="email" className="block text-sm font-medium text-secondary-700">
              Email
            </label>
            <Input id="email" value="john@example.com" className="mt-1" type="email" />
          </div>
          <Button>Save Changes</Button>
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle>Preferences</CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          <div>
            <label className="flex items-center gap-2">
              <input type="checkbox" className="rounded border-secondary-300" defaultChecked />
              <span className="text-sm">Email notifications</span>
            </label>
          </div>
          <div>
            <label className="flex items-center gap-2">
              <input type="checkbox" className="rounded border-secondary-300" defaultChecked />
              <span className="text-sm">Dark mode</span>
            </label>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
```

### Step 11: Create Users Page

**frontend/app/(dashboard)/users/page.tsx** (create)

```tsx
import { Metadata } from 'next';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/Card';
import { get } from '@/lib/api/client';
import { ENDPOINTS } from '@/lib/api/endpoints';
import { User } from '@/types';

export const metadata: Metadata = {
  title: 'Users',
  description: 'Manage team members',
};

export default async function UsersPage() {
  const response = await get<User[]>(ENDPOINTS.users.list);
  const users = response.data || [];

  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-semibold">Team Members</h1>
      
      <Card>
        <CardHeader>
          <CardTitle>All Users</CardTitle>
        </CardHeader>
        <CardContent>
          {users.length === 0 ? (
            <p className="text-secondary-500">No users found</p>
          ) : (
            <div className="overflow-x-auto">
              <table className="w-full">
                <thead>
                  <tr className="border-b border-secondary-200">
                    <th className="px-4 py-2 text-left text-sm font-medium text-secondary-600">Name</th>
                    <th className="px-4 py-2 text-left text-sm font-medium text-secondary-600">Email</th>
                    <th className="px-4 py-2 text-left text-sm font-medium text-secondary-600">Role</th>
                    <th className="px-4 py-2 text-left text-sm font-medium text-secondary-600">Joined</th>
                  </tr>
                </thead>
                <tbody>
                  {users.map((user) => (
                    <tr key={user.id} className="border-b border-secondary-100">
                      <td className="px-4 py-3 text-sm">{user.full_name}</td>
                      <td className="px-4 py-3 text-sm">{user.email}</td>
                      <td className="px-4 py-3 text-sm">
                        <span className="inline-flex rounded-full bg-primary-100 px-2 py-1 text-xs font-medium text-primary-700">
                          {user.role_display}
                        </span>
                      </td>
                      <td className="px-4 py-3 text-sm text-secondary-500">
                        {new Date(user.created_at).toLocaleDateString()}
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </CardContent>
      </Card>
    </div>
  );
}
```

### Step 12: Add Navigation Active State

Update the dashboard layout to show active navigation items (already done in Step 6).

---

## The Verification

### Step 1: Start the Server

```bash
cd backend
source venv/bin/activate
python manage.py runserver
```

### Step 2: Start the Frontend

```bash
cd frontend
npm run dev
```

### Step 3: Test Navigation

1. **Landing Page**: http://localhost:3000/
   - ✅ Should show hero section and features

2. **Login**: http://localhost:3000/login
   - ✅ Should show login form with minimal layout

3. **Register**: http://localhost:3000/register
   - ✅ Should show registration form

4. **Dashboard**: http://localhost:3000/dashboard
   - ✅ Should show dashboard with sidebar

5. **Projects**: http://localhost:3000/projects
   - ✅ Should show project list
   - ✅ Click project to go to detail

6. **Tasks**: http://localhost:3000/tasks
   - ✅ Should show task list with pagination

### Step 4: Test Dynamic Routes

1. **Project Detail**: http://localhost:3000/projects/1
   - ✅ Should show project details

2. **Task Detail**: http://localhost:3000/tasks/1
   - ✅ Should show task details

3. **Create Project**: http://localhost:3000/projects/create
   - ✅ Should show create form

4. **Edit Project**: http://localhost:3000/projects/1/edit
   - ✅ Should show edit form

5. **Create Task**: http://localhost:3000/tasks/create
   - ✅ Should show create task form

6. **Edit Task**: http://localhost:3000/tasks/1/edit
   - ✅ Should show edit task form

### Step 5: Test Nested Routes

1. **Project Tasks**: http://localhost:3000/projects/1/tasks
   - ✅ Should show tasks for the project

2. **Create Task in Project**: http://localhost:3000/projects/1/tasks/create
   - ✅ Should show create form with project pre-selected

### Step 6: Test Loading States

1. Navigate to Projects and observe the loading skeleton
2. Navigate to Tasks and observe the loading skeleton

### Step 7: Test Error Boundaries

1. Try to access a non-existent project: http://localhost:3000/projects/999
   - ✅ Should show not-found page

2. Try to access a non-existent task: http://localhost:3000/tasks/999
   - ✅ Should show not-found page

### Step 8: Test Route Groups

1. Auth routes don't have the "/auth" in the URL
   - ✅ /login, /register (not /auth/login)

2. Dashboard routes don't have "/dashboard" in the URL
   - ✅ /projects, /tasks (not /dashboard/projects)

---

## Key Takeaways

1. **The App Router** provides powerful file-based routing with nested layouts.

2. **Route groups** `(folder)` organize routes without affecting URL paths.

3. **Dynamic routes** `[param]` capture URL parameters for data fetching.

4. **Nested dynamic routes** handle complex URLs like `/projects/123/tasks/456`.

5. **Layouts** wrap pages and provide consistent UI.

6. **Loading UI** improves UX with skeleton screens or spinners.

7. **Error boundaries** handle errors gracefully at the route level.

8. **Not found pages** provide helpful feedback for missing resources.

9. **Active navigation** highlights the current route.

10. **URL state** (search params) can be used for filters and pagination.

---

## Common Routing Patterns

### Pattern 1: Resource CRUD Routes

```
/resources/               # List
/resources/create/        # Create form
/resources/{id}/          # Detail
/resources/{id}/edit/     # Edit form
```

### Pattern 2: Nested Resources

```
/resources/{parentId}/subresources/              # List
/resources/{parentId}/subresources/create/       # Create
/resources/{parentId}/subresources/{childId}/    # Detail
```

### Pattern 3: Route Groups

```
app/
├── (auth)/              # Public routes (login, register)
├── (dashboard)/         # Protected routes (projects, tasks)
└── (marketing)/         # Marketing pages (pricing, about)
```

### Pattern 4: Catch-all Routes

```tsx
// app/[...slug]/page.tsx
export default function CatchAllPage({ params }: { params: { slug: string[] } }) {
  return <div>Path: {params.slug.join('/')}</div>;
}
```

---

## What's Next

In **Part 12**, we'll build frontend data architecture. You'll learn:

- Server-side data fetching patterns
- Client-side data fetching
- Cache invalidation strategies
- Optimistic updates
- State management

---

**End of Part 11**

*Next: Part 12 - Frontend Data Architecture*
