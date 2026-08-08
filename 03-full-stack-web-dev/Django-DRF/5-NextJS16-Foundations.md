# Part 5: Next.js 16 Foundations

## Building Your Modern Frontend

Welcome to **Part 5** of the Django REST Framework & Next.js 16 masterclass. Now that we have a fully functional API, it's time to build the frontend that will consume it. We'll use Next.js 16 with the App Router and React 19 to create a modern, performant web application.

In this part, we'll:
- Set up Next.js 16 with the App Router
- Understand Server Components vs Client Components
- Create layouts and pages
- Set up Tailwind CSS for styling
- Build reusable UI components
- Configure environment variables

Think of this as building the **showroom** for our API. The backend is the engine, and Next.js is the elegant car body that users actually see and interact with.

---

## The Target

We'll build the foundation of our Next.js frontend:

```
frontend/
├── app/
│   ├── (auth)/                    # Authentication routes (group)
│   │   ├── login/
│   │   │   └── page.tsx
│   │   └── register/
│   │       └── page.tsx
│   ├── (dashboard)/               # Dashboard routes (group)
│   │   ├── dashboard/
│   │   │   └── page.tsx
│   │   ├── projects/
│   │   │   ├── page.tsx           # List projects
│   │   │   └── [id]/
│   │   │       ├── page.tsx       # Project details
│   │   │       └── tasks/
│   │   │           └── page.tsx   # Project tasks
│   │   └── tasks/
│   │       ├── page.tsx           # List tasks
│   │       └── [id]/
│   │           └── page.tsx       # Task details
│   ├── api/                       # API routes (for proxy)
│   ├── layout.tsx                 # Root layout
│   ├── page.tsx                   # Landing page
│   └── globals.css                # Global styles
├── components/
│   ├── ui/                        # Reusable UI components
│   │   ├── Button.tsx
│   │   ├── Card.tsx
│   │   ├── Input.tsx
│   │   ├── LoadingSpinner.tsx
│   │   └── ...
│   ├── layout/                    # Layout components
│   │   ├── Header.tsx
│   │   ├── Footer.tsx
│   │   └── Sidebar.tsx
│   └── forms/                     # Form components
│       ├── ProjectForm.tsx
│       └── TaskForm.tsx
├── lib/
│   ├── api/                       # API client
│   │   ├── client.ts
│   │   └── endpoints.ts
│   └── utils/                     # Utilities
│       ├── constants.ts
│       └── helpers.ts
├── types/                         # TypeScript types
│   ├── index.ts
│   └── api.ts
├── public/                        # Static assets
├── next.config.js
├── tailwind.config.js
├── postcss.config.js
├── package.json
└── .env.local
```

---

## The Concept

### Why Next.js?

Next.js is a React framework that provides:

1. **Server-side rendering (SSR)** - Faster initial page loads and better SEO
2. **Static site generation (SSG)** - Pre-render pages at build time
3. **API routes** - Backend endpoints within your frontend
4. **File-based routing** - Pages are created based on file structure
5. **Image optimization** - Automatic image optimization
6. **Built-in CSS and Sass support** - Easy styling

### Server Components vs Client Components

One of the most important concepts in Next.js 14+ is the distinction between Server Components and Client Components:

#### Server Components (Default)
- **Rendered on the server** - No JavaScript sent to the client
- **Can use async/await** - Directly fetch data
- **Can access server resources** - Database, file system, environment variables
- **Cannot use hooks** - No useState, useEffect, etc.
- **Cannot use browser APIs** - No window, document, etc.

```tsx
// This is a Server Component by default
export default async function Page() {
    const data = await fetchData(); // ✅ Can use async
    return <div>{data}</div>;
}
```

#### Client Components
- **Rendered on the client** - JavaScript sent to the browser
- **Can use hooks** - useState, useEffect, useContext
- **Can use browser APIs** - window, document, localStorage
- **Must use "use client" directive** at the top of the file

```tsx
'use client'; // 🔴 Required for client components

import { useState } from 'react';

export default function Counter() {
    const [count, setCount] = useState(0); // ✅ Can use hooks
    return <button onClick={() => setCount(count + 1)}>{count}</button>;
}
```

#### When to Use Which?

| Use Server Components For | Use Client Components For |
|---------------------------|---------------------------|
| Fetching data from APIs | Interactive UI elements |
| Rendering static content | Forms and user input |
| SEO-critical pages | Real-time updates |
| Accessing databases | Client-side state |
| Reading environment variables | Browser APIs |

### The App Router

Next.js 16 uses the App Router for routing:

```
app/
├── page.tsx              → /
├── about/
│   └── page.tsx          → /about
├── blog/
│   ├── page.tsx          → /blog
│   └── [slug]/
│       └── page.tsx      → /blog/my-post
├── layout.tsx            → Shared layout
└── (group)/              → Route group (doesn't affect URL)
    └── page.tsx          → /page (ignores group)
```

---

## The Implementation

### Step 1: Set Up the Next.js Project

Navigate to your project root and create the frontend:

```bash
# Go back to project root
cd ../

# Create Next.js app with TypeScript and Tailwind CSS
npx create-next-app@latest frontend --typescript --tailwind --eslint --app --use-npm

# This creates a new Next.js app with:
# - TypeScript support
# - Tailwind CSS configured
# - ESLint for code quality
# - App Router
```

Navigate into the frontend directory:

```bash
cd frontend
```

### Step 2: Install Additional Dependencies

```bash
# Install additional packages
npm install @radix-ui/react-slot class-variance-authority clsx tailwind-merge lucide-react

# Install development dependencies
npm install -D @types/node @types/react @types/react-dom
```

### Step 3: Configure Tailwind CSS

Next.js 16 with the `--tailwind` flag already sets up Tailwind, but let's customize it.

**frontend/tailwind.config.js**
```javascript
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    './pages/**/*.{js,ts,jsx,tsx,mdx}',
    './components/**/*.{js,ts,jsx,tsx,mdx}',
    './app/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    extend: {
      colors: {
        primary: {
          50: '#eff6ff',
          100: '#dbeafe',
          200: '#bfdbfe',
          300: '#93c5fd',
          400: '#60a5fa',
          500: '#3b82f6',
          600: '#2563eb',
          700: '#1d4ed8',
          800: '#1e40af',
          900: '#1e3a8a',
          950: '#172554',
        },
        secondary: {
          50: '#f8fafc',
          100: '#f1f5f9',
          200: '#e2e8f0',
          300: '#cbd5e1',
          400: '#94a3b8',
          500: '#64748b',
          600: '#475569',
          700: '#334155',
          800: '#1e293b',
          900: '#0f172a',
        },
        success: {
          50: '#f0fdf4',
          500: '#22c55e',
          600: '#16a34a',
          700: '#15803d',
        },
        warning: {
          50: '#fffbeb',
          500: '#f59e0b',
          600: '#d97706',
          700: '#b45309',
        },
        danger: {
          50: '#fef2f2',
          500: '#ef4444',
          600: '#dc2626',
          700: '#b91c1c',
        },
      },
      fontFamily: {
        sans: ['Inter', 'system-ui', 'sans-serif'],
      },
      animation: {
        'spin-slow': 'spin 3s linear infinite',
        'fade-in': 'fade-in 0.3s ease-in-out',
        'slide-in': 'slide-in 0.3s ease-out',
      },
      keyframes: {
        'fade-in': {
          '0%': { opacity: '0' },
          '100%': { opacity: '1' },
        },
        'slide-in': {
          '0%': { transform: 'translateY(-10px)', opacity: '0' },
          '100%': { transform: 'translateY(0)', opacity: '1' },
        },
      },
    },
  },
  plugins: [],
};
```

### Step 4: Update Global Styles

**frontend/app/globals.css**
```css
@tailwind base;
@tailwind components;
@tailwind utilities;

@layer base {
  /* Reset and base styles */
  * {
    @apply border-border;
  }
  
  html {
    @apply scroll-smooth;
  }
  
  body {
    @apply bg-secondary-50 text-secondary-900 antialiased;
  }
  
  /* Custom scrollbar */
  ::-webkit-scrollbar {
    @apply w-2 h-2;
  }
  
  ::-webkit-scrollbar-track {
    @apply bg-secondary-100 rounded-full;
  }
  
  ::-webkit-scrollbar-thumb {
    @apply bg-secondary-300 rounded-full hover:bg-secondary-400 transition-colors;
  }
}

@layer components {
  /* Custom component classes */
  .container-custom {
    @apply max-w-7xl mx-auto px-4 sm:px-6 lg:px-8;
  }
  
  .card-hover {
    @apply transition-all duration-200 hover:shadow-lg hover:-translate-y-1;
  }
}

@layer utilities {
  /* Custom utility classes */
  .text-balance {
    text-wrap: balance;
  }
}
```

### Step 5: Create the Root Layout

**frontend/app/layout.tsx**
```tsx
import type { Metadata } from 'next';
import { Inter } from 'next/font/google';
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
  keywords: ['task management', 'project management', 'productivity', 'team collaboration'],
  authors: [{ name: 'TaskFlow Team' }],
  openGraph: {
    title: 'TaskFlow - Task Management Platform',
    description: 'A modern task management platform built with Django and Next.js',
    type: 'website',
    locale: 'en_US',
  },
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en" className={inter.variable}>
      <body className="min-h-screen bg-secondary-50">
        {children}
      </body>
    </html>
  );
}
```

### Step 6: Create Utility Functions

**frontend/lib/utils/constants.ts**
```tsx
/**
 * Application constants
 */

export const APP_NAME = 'TaskFlow';
export const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000/api/v1';

export const TASK_STATUSES = {
  TODO: 'todo',
  IN_PROGRESS: 'in_progress',
  REVIEW: 'review',
  DONE: 'done',
} as const;

export const TASK_PRIORITIES = {
  LOW: 'low',
  MEDIUM: 'medium',
  HIGH: 'high',
  URGENT: 'urgent',
} as const;

export const TASK_STATUS_LABELS: Record<string, string> = {
  [TASK_STATUSES.TODO]: 'To Do',
  [TASK_STATUSES.IN_PROGRESS]: 'In Progress',
  [TASK_STATUSES.REVIEW]: 'In Review',
  [TASK_STATUSES.DONE]: 'Done',
};

export const TASK_PRIORITY_LABELS: Record<string, string> = {
  [TASK_PRIORITIES.LOW]: 'Low',
  [TASK_PRIORITIES.MEDIUM]: 'Medium',
  [TASK_PRIORITIES.HIGH]: 'High',
  [TASK_PRIORITIES.URGENT]: 'Urgent',
};

export const TASK_STATUS_COLORS: Record<string, string> = {
  [TASK_STATUSES.TODO]: 'bg-secondary-100 text-secondary-700',
  [TASK_STATUSES.IN_PROGRESS]: 'bg-blue-100 text-blue-700',
  [TASK_STATUSES.REVIEW]: 'bg-yellow-100 text-yellow-700',
  [TASK_STATUSES.DONE]: 'bg-green-100 text-green-700',
};

export const TASK_PRIORITY_COLORS: Record<string, string> = {
  [TASK_PRIORITIES.LOW]: 'bg-green-100 text-green-700',
  [TASK_PRIORITIES.MEDIUM]: 'bg-blue-100 text-blue-700',
  [TASK_PRIORITIES.HIGH]: 'bg-orange-100 text-orange-700',
  [TASK_PRIORITIES.URGENT]: 'bg-red-100 text-red-700',
};

export const USER_ROLES = {
  ADMIN: 'admin',
  MANAGER: 'manager',
  MEMBER: 'member',
  VIEWER: 'viewer',
} as const;

export const USER_ROLE_LABELS: Record<string, string> = {
  [USER_ROLES.ADMIN]: 'Administrator',
  [USER_ROLES.MANAGER]: 'Manager',
  [USER_ROLES.MEMBER]: 'Member',
  [USER_ROLES.VIEWER]: 'Viewer',
};
```

**frontend/lib/utils/helpers.ts**
```tsx
/**
 * Helper functions
 */

import { clsx, type ClassValue } from 'clsx';
import { twMerge } from 'tailwind-merge';

/**
 * Merge Tailwind CSS classes with clsx
 */
export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

/**
 * Format a date string
 */
export function formatDate(date: string | Date): string {
  const d = typeof date === 'string' ? new Date(date) : date;
  return d.toLocaleDateString('en-US', {
    year: 'numeric',
    month: 'short',
    day: 'numeric',
  });
}

/**
 * Format a datetime string
 */
export function formatDateTime(date: string | Date): string {
  const d = typeof date === 'string' ? new Date(date) : date;
  return d.toLocaleString('en-US', {
    year: 'numeric',
    month: 'short',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
  });
}

/**
 * Get relative time (e.g., "2 hours ago")
 */
export function getRelativeTime(date: string | Date): string {
  const d = typeof date === 'string' ? new Date(date) : date;
  const now = new Date();
  const diff = now.getTime() - d.getTime();
  
  const minutes = Math.floor(diff / 60000);
  const hours = Math.floor(diff / 3600000);
  const days = Math.floor(diff / 86400000);
  
  if (minutes < 1) return 'just now';
  if (minutes < 60) return `${minutes}m ago`;
  if (hours < 24) return `${hours}h ago`;
  if (days < 7) return `${days}d ago`;
  return formatDate(d);
}

/**
 * Truncate text with ellipsis
 */
export function truncateText(text: string, maxLength: number): string {
  if (text.length <= maxLength) return text;
  return text.slice(0, maxLength) + '...';
}

/**
 * Check if a value is empty (null, undefined, empty string, empty array)
 */
export function isEmpty(value: any): boolean {
  if (value === null || value === undefined) return true;
  if (typeof value === 'string') return value.trim() === '';
  if (Array.isArray(value)) return value.length === 0;
  if (typeof value === 'object') return Object.keys(value).length === 0;
  return false;
}

/**
 * Generate a unique ID (for temporary items)
 */
export function generateId(): string {
  return Math.random().toString(36).substring(2) + Date.now().toString(36);
}
```

### Step 7: Create the API Client

**frontend/lib/api/client.ts**
```tsx
/**
 * API client for communicating with the Django backend
 */

import { API_BASE_URL } from '@/lib/utils/constants';

export interface ApiError {
  detail?: string;
  [key: string]: any;
}

export interface ApiResponse<T = any> {
  data?: T;
  error?: ApiError;
  status: number;
}

/**
 * Make an API request
 */
export async function apiRequest<T = any>(
  endpoint: string,
  options: RequestInit = {}
): Promise<ApiResponse<T>> {
  const url = `${API_BASE_URL}${endpoint}`;
  const headers: HeadersInit = {
    'Content-Type': 'application/json',
    ...options.headers,
  };

  try {
    const response = await fetch(url, {
      ...options,
      headers,
    });

    let data;
    const contentType = response.headers.get('content-type');
    if (contentType && contentType.includes('application/json')) {
      data = await response.json();
    } else {
      data = await response.text();
    }

    if (!response.ok) {
      return {
        error: data as ApiError,
        status: response.status,
      };
    }

    return {
      data: data as T,
      status: response.status,
    };
  } catch (error) {
    console.error('API request failed:', error);
    return {
      error: {
        detail: 'Network error. Please check your connection.',
      },
      status: 0,
    };
  }
}

/**
 * GET request
 */
export async function get<T = any>(endpoint: string): Promise<ApiResponse<T>> {
  return apiRequest<T>(endpoint, { method: 'GET' });
}

/**
 * POST request
 */
export async function post<T = any>(
  endpoint: string,
  data?: any
): Promise<ApiResponse<T>> {
  return apiRequest<T>(endpoint, {
    method: 'POST',
    body: data ? JSON.stringify(data) : undefined,
  });
}

/**
 * PUT request
 */
export async function put<T = any>(
  endpoint: string,
  data?: any
): Promise<ApiResponse<T>> {
  return apiRequest<T>(endpoint, {
    method: 'PUT',
    body: data ? JSON.stringify(data) : undefined,
  });
}

/**
 * PATCH request
 */
export async function patch<T = any>(
  endpoint: string,
  data?: any
): Promise<ApiResponse<T>> {
  return apiRequest<T>(endpoint, {
    method: 'PATCH',
    body: data ? JSON.stringify(data) : undefined,
  });
}

/**
 * DELETE request
 */
export async function del<T = any>(endpoint: string): Promise<ApiResponse<T>> {
  return apiRequest<T>(endpoint, { method: 'DELETE' });
}
```

**frontend/lib/api/endpoints.ts**
```tsx
/**
 * API endpoint definitions
 */

export const ENDPOINTS = {
  // Users
  users: {
    list: '/users/',
    detail: (id: number) => `/users/${id}/`,
    profile: '/users/profile/',
  },
  
  // Projects
  projects: {
    list: '/projects/',
    detail: (id: number) => `/projects/${id}/`,
    tasks: (id: number) => `/projects/${id}/tasks/`,
  },
  
  // Tasks
  tasks: {
    list: '/tasks/',
    detail: (id: number) => `/tasks/${id}/`,
    status: (id: number) => `/tasks/${id}/status/`,
    comments: (id: number) => `/tasks/${id}/comments/`,
  },
  
  // Comments
  comments: {
    list: '/comments/',
    detail: (id: number) => `/comments/${id}/`,
    byTask: (taskId: number) => `/comments/by-task/${taskId}/`,
  },
};
```

### Step 8: Create Type Definitions

**frontend/types/index.ts**
```tsx
/**
 * Type definitions for the application
 */

export interface User {
  id: number;
  email: string;
  username: string;
  first_name: string;
  last_name: string;
  full_name: string;
  bio: string | null;
  role: 'admin' | 'manager' | 'member' | 'viewer';
  role_display: string;
  is_active: boolean;
  is_staff: boolean;
  is_superuser: boolean;
  created_at: string;
  updated_at: string;
}

export interface Project {
  id: number;
  name: string;
  description: string | null;
  created_by: number;
  created_by_username: string;
  task_count: number;
  completed_task_count: number;
  created_at: string;
  updated_at: string;
}

export interface Task {
  id: number;
  title: string;
  description: string | null;
  status: 'todo' | 'in_progress' | 'review' | 'done';
  status_display: string;
  priority: 'low' | 'medium' | 'high' | 'urgent';
  priority_display: string;
  due_date: string | null;
  is_overdue: boolean;
  project: number;
  project_name: string;
  assigned_to: number | null;
  assigned_to_username: string | null;
  created_by: number;
  created_by_username: string;
  comment_count: number;
  created_at: string;
  updated_at: string;
}

export interface Comment {
  id: number;
  content: string;
  task: number;
  task_title: string;
  author: number;
  author_username: string;
  author_email: string;
  created_at: string;
  updated_at: string;
}

export interface CreateProjectData {
  name: string;
  description?: string;
}

export interface UpdateProjectData {
  name?: string;
  description?: string;
}

export interface CreateTaskData {
  title: string;
  description?: string;
  status?: Task['status'];
  priority?: Task['priority'];
  due_date?: string | null;
  project: number;
  assigned_to?: number | null;
}

export interface UpdateTaskData {
  title?: string;
  description?: string;
  status?: Task['status'];
  priority?: Task['priority'];
  due_date?: string | null;
  assigned_to?: number | null;
}

export interface CreateCommentData {
  content: string;
  task: number;
}

export interface UpdateCommentData {
  content: string;
}
```

### Step 9: Create UI Components

**frontend/components/ui/Button.tsx**
```tsx
'use client';

import * as React from 'react';
import { Slot } from '@radix-ui/react-slot';
import { cva, type VariantProps } from 'class-variance-authority';
import { cn } from '@/lib/utils/helpers';
import { Loader2 } from 'lucide-react';

const buttonVariants = cva(
  'inline-flex items-center justify-center whitespace-nowrap rounded-md text-sm font-medium ring-offset-white transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-primary-500 focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50',
  {
    variants: {
      variant: {
        default: 'bg-primary-600 text-white hover:bg-primary-700',
        destructive: 'bg-danger-600 text-white hover:bg-danger-700',
        outline: 'border border-secondary-300 bg-white hover:bg-secondary-100',
        secondary: 'bg-secondary-200 text-secondary-900 hover:bg-secondary-300',
        ghost: 'hover:bg-secondary-100 hover:text-secondary-900',
        link: 'text-primary-600 underline-offset-4 hover:underline',
      },
      size: {
        default: 'h-10 px-4 py-2',
        sm: 'h-9 rounded-md px-3',
        lg: 'h-11 rounded-md px-8',
        icon: 'h-10 w-10',
      },
    },
    defaultVariants: {
      variant: 'default',
      size: 'default',
    },
  }
);

export interface ButtonProps
  extends React.ButtonHTMLAttributes<HTMLButtonElement>,
    VariantProps<typeof buttonVariants> {
  asChild?: boolean;
  isLoading?: boolean;
}

const Button = React.forwardRef<HTMLButtonElement, ButtonProps>(
  ({ className, variant, size, asChild = false, isLoading = false, children, disabled, ...props }, ref) => {
    const Comp = asChild ? Slot : 'button';
    return (
      <Comp
        className={cn(buttonVariants({ variant, size, className }))}
        ref={ref}
        disabled={disabled || isLoading}
        {...props}
      >
        {isLoading && <Loader2 className="mr-2 h-4 w-4 animate-spin" />}
        {children}
      </Comp>
    );
  }
);
Button.displayName = 'Button';

export { Button, buttonVariants };
```

**frontend/components/ui/Card.tsx**
```tsx
import * as React from 'react';
import { cn } from '@/lib/utils/helpers';

const Card = React.forwardRef<
  HTMLDivElement,
  React.HTMLAttributes<HTMLDivElement>
>(({ className, ...props }, ref) => (
  <div
    ref={ref}
    className={cn(
      'rounded-lg border border-secondary-200 bg-white text-secondary-900 shadow-sm',
      className
    )}
    {...props}
  />
));
Card.displayName = 'Card';

const CardHeader = React.forwardRef<
  HTMLDivElement,
  React.HTMLAttributes<HTMLDivElement>
>(({ className, ...props }, ref) => (
  <div
    ref={ref}
    className={cn('flex flex-col space-y-1.5 p-6', className)}
    {...props}
  />
));
CardHeader.displayName = 'CardHeader';

const CardTitle = React.forwardRef<
  HTMLParagraphElement,
  React.HTMLAttributes<HTMLHeadingElement>
>(({ className, ...props }, ref) => (
  <h3
    ref={ref}
    className={cn(
      'text-2xl font-semibold leading-none tracking-tight',
      className
    )}
    {...props}
  />
));
CardTitle.displayName = 'CardTitle';

const CardDescription = React.forwardRef<
  HTMLParagraphElement,
  React.HTMLAttributes<HTMLParagraphElement>
>(({ className, ...props }, ref) => (
  <p
    ref={ref}
    className={cn('text-sm text-secondary-500', className)}
    {...props}
  />
));
CardDescription.displayName = 'CardDescription';

const CardContent = React.forwardRef<
  HTMLDivElement,
  React.HTMLAttributes<HTMLDivElement>
>(({ className, ...props }, ref) => (
  <div ref={ref} className={cn('p-6 pt-0', className)} {...props} />
));
CardContent.displayName = 'CardContent';

const CardFooter = React.forwardRef<
  HTMLDivElement,
  React.HTMLAttributes<HTMLDivElement>
>(({ className, ...props }, ref) => (
  <div
    ref={ref}
    className={cn('flex items-center p-6 pt-0', className)}
    {...props}
  />
));
CardFooter.displayName = 'CardFooter';

export { Card, CardHeader, CardFooter, CardTitle, CardDescription, CardContent };
```

**frontend/components/ui/Badge.tsx**
```tsx
import * as React from 'react';
import { cva, type VariantProps } from 'class-variance-authority';
import { cn } from '@/lib/utils/helpers';

const badgeVariants = cva(
  'inline-flex items-center rounded-full border px-2.5 py-0.5 text-xs font-semibold transition-colors focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2',
  {
    variants: {
      variant: {
        default:
          'border-transparent bg-primary-100 text-primary-700 hover:bg-primary-200',
        secondary:
          'border-transparent bg-secondary-100 text-secondary-700 hover:bg-secondary-200',
        destructive:
          'border-transparent bg-danger-100 text-danger-700 hover:bg-danger-200',
        success:
          'border-transparent bg-success-100 text-success-700 hover:bg-success-200',
        warning:
          'border-transparent bg-warning-100 text-warning-700 hover:bg-warning-200',
        outline: 'text-secondary-700',
      },
    },
    defaultVariants: {
      variant: 'default',
    },
  }
);

export interface BadgeProps
  extends React.HTMLAttributes<HTMLDivElement>,
    VariantProps<typeof badgeVariants> {}

function Badge({ className, variant, ...props }: BadgeProps) {
  return (
    <div className={cn(badgeVariants({ variant }), className)} {...props} />
  );
}

export { Badge, badgeVariants };
```

**frontend/components/ui/LoadingSpinner.tsx**
```tsx
import { cn } from '@/lib/utils/helpers';

interface LoadingSpinnerProps {
  className?: string;
  size?: 'sm' | 'md' | 'lg';
}

export function LoadingSpinner({ className, size = 'md' }: LoadingSpinnerProps) {
  const sizeClasses = {
    sm: 'h-4 w-4',
    md: 'h-8 w-8',
    lg: 'h-12 w-12',
  };

  return (
    <div className="flex items-center justify-center">
      <svg
        className={cn(
          'animate-spin text-primary-600',
          sizeClasses[size],
          className
        )}
        xmlns="http://www.w3.org/2000/svg"
        fill="none"
        viewBox="0 0 24 24"
      >
        <circle
          className="opacity-25"
          cx="12"
          cy="12"
          r="10"
          stroke="currentColor"
          strokeWidth="4"
        />
        <path
          className="opacity-75"
          fill="currentColor"
          d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
        />
      </svg>
    </div>
  );
}
```

### Step 10: Create the Landing Page

**frontend/app/page.tsx**
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

### Step 11: Create the Dashboard Layout

**frontend/app/(dashboard)/layout.tsx**
```tsx
import Link from 'next/link';
import { LayoutDashboard, FolderKanban, ListTodo, Users, Settings } from 'lucide-react';
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
              return (
                <Link
                  key={item.name}
                  href={item.href}
                  className={cn(
                    'flex items-center gap-3 rounded-lg px-3 py-2 text-sm font-medium transition-colors',
                    'text-secondary-700 hover:bg-secondary-100 hover:text-secondary-900'
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
                U
              </div>
              <div className="flex-1">
                <p className="text-sm font-medium">User Name</p>
                <p className="text-xs text-secondary-500">user@example.com</p>
              </div>
            </div>
          </div>
        </div>
      </aside>

      {/* Main Content */}
      <main className="flex-1 pl-64">
        <header className="sticky top-0 z-40 border-b border-secondary-200 bg-white/80 backdrop-blur">
          <div className="flex h-16 items-center justify-between px-6">
            <h1 className="text-xl font-semibold text-secondary-900">Dashboard</h1>
          </div>
        </header>
        <div className="p-6">{children}</div>
      </main>
    </div>
  );
}
```

### Step 12: Create Dashboard Page

**frontend/app/(dashboard)/dashboard/page.tsx**
```tsx
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/Card';
import { get } from '@/lib/api/client';
import { ENDPOINTS } from '@/lib/api/endpoints';
import { Project, Task } from '@/types';

export default async function DashboardPage() {
  // Fetch data from API (Server Component)
  const projectsResponse = await get<Project[]>(ENDPOINTS.projects.list);
  const tasksResponse = await get<Task[]>(ENDPOINTS.tasks.list);

  const projects = projectsResponse.data || [];
  const tasks = tasksResponse.data || [];

  const totalTasks = tasks.length;
  const completedTasks = tasks.filter(t => t.status === 'done').length;
  const inProgressTasks = tasks.filter(t => t.status === 'in_progress').length;

  return (
    <div className="space-y-6">
      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Total Projects</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{projects.length}</div>
          </CardContent>
        </Card>
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Total Tasks</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{totalTasks}</div>
          </CardContent>
        </Card>
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">In Progress</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{inProgressTasks}</div>
          </CardContent>
        </Card>
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Completed</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{completedTasks}</div>
          </CardContent>
        </Card>
      </div>

      <div className="grid gap-4 md:grid-cols-2">
        <Card>
          <CardHeader>
            <CardTitle>Recent Projects</CardTitle>
          </CardHeader>
          <CardContent>
            {projects.length === 0 ? (
              <p className="text-secondary-500">No projects yet</p>
            ) : (
              <ul className="space-y-2">
                {projects.slice(0, 5).map((project) => (
                  <li
                    key={project.id}
                    className="flex items-center justify-between rounded-lg bg-secondary-50 p-3"
                  >
                    <span>{project.name}</span>
                    <span className="text-sm text-secondary-500">
                      {project.task_count} tasks
                    </span>
                  </li>
                ))}
              </ul>
            )}
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Recent Tasks</CardTitle>
          </CardHeader>
          <CardContent>
            {tasks.length === 0 ? (
              <p className="text-secondary-500">No tasks yet</p>
            ) : (
              <ul className="space-y-2">
                {tasks.slice(0, 5).map((task) => (
                  <li
                    key={task.id}
                    className="flex items-center justify-between rounded-lg bg-secondary-50 p-3"
                  >
                    <span>{task.title}</span>
                    <span className="text-sm text-secondary-500">
                      {task.status_display}
                    </span>
                  </li>
                ))}
              </ul>
            )}
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
```

### Step 13: Set Up Environment Variables

**frontend/.env.local**
```bash
# API Configuration
NEXT_PUBLIC_API_URL=http://localhost:8000/api/v1
```

**frontend/.env.example**
```bash
# API Configuration
NEXT_PUBLIC_API_URL=http://localhost:8000/api/v1
```

### Step 14: Update Next.js Configuration

**frontend/next.config.js**
```javascript
/** @type {import('next').NextConfig} */
const nextConfig = {
  images: {
    domains: ['localhost'],
    remotePatterns: [
      {
        protocol: 'http',
        hostname: 'localhost',
        port: '8000',
        pathname: '/media/**',
      },
    ],
  },
  async rewrites() {
    return [
      {
        source: '/api/:path*',
        destination: `${process.env.NEXT_PUBLIC_API_URL}/:path*`,
      },
    ];
  },
};

module.exports = nextConfig;
```

### Step 15: Update package.json Scripts

**frontend/package.json** (verify scripts)
```json
{
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "lint": "next lint",
    "format": "prettier --write ."
  }
}
```

---

## The Verification

### Step 1: Start the Development Server

```bash
# Make sure you're in the frontend directory
npm run dev
```

You should see output like:
```
  ▲ Next.js 16.0.0
  - Local:        http://localhost:3000
  - Network:      http://192.168.1.100:3000

  ✓ Starting...
  ✓ Ready in 2.3s
```

### Step 2: View the Landing Page

Open your browser and go to http://localhost:3000

You should see:
- The TaskFlow landing page
- Hero section with title and call-to-action
- Features section
- Navigation (in the sidebar if you go to /dashboard)

### Step 3: View the Dashboard

Go to http://localhost:3000/dashboard

You should see:
- The dashboard layout with sidebar
- Stats cards (Total Projects, Total Tasks, etc.)
- Recent projects and tasks (if your API has data)

### Step 4: Test API Integration

Check the browser console for any API errors:

```bash
# Open browser developer tools (F12)
# Go to Network tab
# Refresh the dashboard page
# You should see requests to localhost:8000/api/v1/projects/ and tasks/
```

### Step 5: Verify TypeScript Types

Run TypeScript check:

```bash
npm run build
# This will compile and check for TypeScript errors
```

### Step 6: Test API Proxy

Test the API rewrite configuration:

```bash
# The Next.js API proxy should forward requests
curl http://localhost:3000/api/v1/users/
# This should proxy to http://localhost:8000/api/v1/users/
```

---

## Key Takeaways

1. **Next.js 16 with App Router** provides a modern foundation for our frontend.

2. **Server Components** are the default - they're rendered on the server, reducing client-side JavaScript.

3. **Client Components** are used for interactive UI - use the `'use client'` directive.

4. **The App Router** uses file-based routing - files in `app/` become routes.

5. **Tailwind CSS** provides utility-first styling with custom theming.

6. **TypeScript** adds type safety to our frontend code.

7. **API client** abstracts away the fetch logic and handles errors.

8. **Environment variables** keep configuration out of code.

---

## Common Patterns

### Server Component Fetching

```tsx
// Server Component - fetches data on the server
export default async function Page() {
  const res = await fetch('http://localhost:8000/api/v1/projects/');
  const projects = await res.json();
  return <ProjectList projects={projects} />;
}
```

### Client Component with State

```tsx
'use client';

import { useState } from 'react';

export function Counter() {
  const [count, setCount] = useState(0);
  return <button onClick={() => setCount(c + 1)}>{count}</button>;
}
```

### Dynamic Routes

```tsx
// app/projects/[id]/page.tsx
export default async function ProjectPage({ params }: { params: { id: string } }) {
  const project = await getProject(params.id);
  return <ProjectDetail project={project} />;
}
```

---

## What's Next

In **Part 6**, we'll connect Next.js to our DRF API. You'll learn:

- Fetching data from the API in Server Components
- Creating forms for creating and updating resources
- Handling API errors in the frontend
- Building reusable data components
- Implementing search and filtering

We'll build the complete data layer that powers our application.

---

**End of Part 5**

*Next: Part 6 - Connecting Next.js to DRF*
