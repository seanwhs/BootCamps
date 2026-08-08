# Part 18: Next.js Authentication

## Implementing Server-Side and Client-Side Authentication

Welcome to **Part 18** of the Django REST Framework & Next.js 16 masterclass. Now that we have a robust backend authentication system and role-based access control, it's time to implement comprehensive authentication in Next.js. We'll combine server-side and client-side authentication to create a seamless, secure experience.

In this part, we'll:
- Implement Next.js middleware for route protection
- Build server-side authentication for Server Components
- Create API route protection
- Implement authentication flows in Server Components
- Build a complete authentication system

Think of this as building the **security perimeter** around your application. Just as a building has security checkpoints at every entrance, your Next.js application needs to verify authentication at every level - from the middleware that guards routes to the server components that fetch data.

---

## The Target

We'll build a comprehensive Next.js authentication system:

```
frontend/
├── middleware.ts                # Route protection
├── lib/
│   └── auth/
│       ├── AuthContext.tsx      # Client-side auth context
│       ├── token.ts             # Token management
│       └── server-auth.ts       # Server-side auth utilities
├── app/
│   ├── api/
│   │   └── auth/
│   │       ├── [...nextauth]/
│   │       │   └── route.ts     # API routes (if needed)
│   │       └── token/
│   │           └── route.ts     # Token refresh API route
│   └── (dashboard)/
│       └── layout.tsx           # Protected layout
└── hooks/
    └── useServerAuth.ts         # Server auth hook
```

---

## The Concept

### Next.js Authentication Layers

Next.js provides multiple layers for authentication:

1. **Middleware** - Protects routes at the request level
2. **Server Components** - Authenticates on the server
3. **Client Components** - Manages client-side authentication state
4. **API Routes** - Handles authentication-related API calls

### Authentication Flow

```
┌─────────────────────────────────────────────────────────────────────┐
│                    Authentication Flow in Next.js                   │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  1. Request arrives → middleware checks token                      │
│                      ↓                                              │
│  2. If token exists & valid → redirect to dashboard               │
│     If no token → redirect to login                               │
│                      ↓                                              │
│  3. Server Component → fetches user data with token               │
│                      ↓                                              │
│  4. Client Component → manages auth state                         │
│                      ↓                                              │
│  5. API Request → token included in headers                       │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### Server-Side vs Client-Side Auth

| Aspect | Server-Side | Client-Side |
|--------|------------|-------------|
| **Where** | Next.js Server | Browser |
| **When** | Request time | After page loads |
| **How** | Middleware, Server Components | Auth Context, hooks |
| **Benefits** | Faster initial load, secure | Interactive, stateful |
| **Used for** | Route protection, data fetching | UI updates, user actions |

---

## The Implementation

### Step 1: Create Next.js Middleware

**frontend/middleware.ts** (create)

```tsx
import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';

// Paths that are accessible without authentication
const PUBLIC_PATHS = [
  '/',
  '/login',
  '/register',
  '/api/token/',
  '/api/token/refresh/',
  '/api/token/verify/',
  '/api/users/register/',
];

// Paths that are only accessible to authenticated users
const PROTECTED_PATHS = [
  '/dashboard',
  '/projects',
  '/tasks',
  '/users',
  '/admin',
  '/settings',
];

export function middleware(request: NextRequest) {
  const { pathname } = request.nextUrl;
  
  // Check if the path is public
  const isPublicPath = PUBLIC_PATHS.some(path => pathname.startsWith(path));
  
  // Check if the path is protected
  const isProtectedPath = PROTECTED_PATHS.some(path => pathname.startsWith(path));
  
  // Get the token from cookies or headers
  const token = request.cookies.get('access_token')?.value || 
                request.headers.get('Authorization')?.replace('Bearer ', '');
  
  // If accessing a protected path without a token, redirect to login
  if (isProtectedPath && !token) {
    const loginUrl = new URL('/login', request.url);
    loginUrl.searchParams.set('redirect', pathname);
    return NextResponse.redirect(loginUrl);
  }
  
  // If accessing a public path with a token, redirect to dashboard
  if (isPublicPath && token && pathname !== '/') {
    const dashboardUrl = new URL('/dashboard', request.url);
    return NextResponse.redirect(dashboardUrl);
  }
  
  // Allow the request to proceed
  return NextResponse.next();
}

// Configure which paths the middleware runs on
export const config = {
  matcher: [
    /*
     * Match all request paths except:
     * - _next/static (static files)
     * - _next/image (image optimization files)
     * - favicon.ico (favicon file)
     * - public folder
     */
    '/((?!_next/static|_next/image|favicon.ico|public).*)',
  ],
};
```

### Step 2: Create Server-Side Auth Utilities

**frontend/lib/auth/server-auth.ts** (create)

```tsx
'use server';

import { cookies } from 'next/headers';
import { redirect } from 'next/navigation';
import { get } from '@/lib/api/client';
import { ENDPOINTS } from '@/lib/api/endpoints';
import { jwtDecode } from 'jwt-decode';

/**
 * Get the current user from the server-side
 */
export async function getServerUser() {
  try {
    const cookieStore = await cookies();
    const token = cookieStore.get('access_token')?.value;
    
    if (!token) {
      return null;
    }
    
    // Verify token is valid
    const decoded = jwtDecode(token);
    if (!decoded || !decoded.exp || Date.now() >= decoded.exp * 1000) {
      return null;
    }
    
    // Get user data
    const response = await get('/users/profile/');
    if (response.error) {
      return null;
    }
    
    return response.data;
  } catch (error) {
    return null;
  }
}

/**
 * Check if user is authenticated on the server
 */
export async function isAuthenticated() {
  const user = await getServerUser();
  return !!user;
}

/**
 * Get the current user's role on the server
 */
export async function getUserRole() {
  const user = await getServerUser();
  return user?.role || null;
}

/**
 * Check if user has a specific role on the server
 */
export async function hasRole(roles: string[]) {
  const user = await getServerUser();
  if (!user) return false;
  return roles.includes(user.role);
}

/**
 * Require authentication for Server Components
 */
export async function requireAuth() {
  const isAuth = await isAuthenticated();
  if (!isAuth) {
    redirect('/login');
  }
}

/**
 * Require a specific role for Server Components
 */
export async function requireRole(roles: string[]) {
  await requireAuth();
  const userRole = await getUserRole();
  if (!roles.includes(userRole)) {
    redirect('/dashboard');
  }
}
```

### Step 3: Install jwt-decode

```bash
cd frontend
npm install jwt-decode
npm install -D @types/jwt-decode
```

### Step 4: Update Token Management with Cookies

**frontend/lib/auth/token.ts** (update)

```tsx
/**
 * Token management utilities with cookie support
 */

const ACCESS_TOKEN_KEY = 'access_token';
const REFRESH_TOKEN_KEY = 'refresh_token';
const USER_KEY = 'user';

// Memory storage for tokens
let accessToken: string | null = null;
let refreshToken: string | null = null;
let user: any = null;

/**
 * Set a cookie
 */
function setCookie(name: string, value: string, days: number = 7) {
  if (typeof document === 'undefined') return;
  
  const expires = new Date();
  expires.setTime(expires.getTime() + days * 24 * 60 * 60 * 1000);
  document.cookie = `${name}=${value};expires=${expires.toUTCString()};path=/;SameSite=Lax`;
}

/**
 * Get a cookie
 */
function getCookie(name: string): string | null {
  if (typeof document === 'undefined') return null;
  
  const value = `; ${document.cookie}`;
  const parts = value.split(`; ${name}=`);
  if (parts.length === 2) {
    return parts.pop()?.split(';').shift() || null;
  }
  return null;
}

/**
 * Delete a cookie
 */
function deleteCookie(name: string) {
  if (typeof document === 'undefined') return;
  document.cookie = `${name}=;expires=Thu, 01 Jan 1970 00:00:00 GMT;path=/`;
}

/**
 * Set tokens in memory and cookies
 */
export function setTokens(access: string, refresh: string) {
  accessToken = access;
  refreshToken = refresh;
  
  // Store in cookies for middleware
  setCookie(ACCESS_TOKEN_KEY, access, 1);
  setCookie(REFRESH_TOKEN_KEY, refresh, 7);
  
  // Store in localStorage as backup
  try {
    localStorage.setItem(ACCESS_TOKEN_KEY, access);
    localStorage.setItem(REFRESH_TOKEN_KEY, refresh);
  } catch (e) {
    // Ignore storage errors
  }
}

/**
 * Get access token from memory, cookie, or localStorage
 */
export function getAccessToken(): string | null {
  if (accessToken) {
    return accessToken;
  }
  
  // Try cookie
  const cookieToken = getCookie(ACCESS_TOKEN_KEY);
  if (cookieToken) {
    accessToken = cookieToken;
    return accessToken;
  }
  
  // Try localStorage
  try {
    const stored = localStorage.getItem(ACCESS_TOKEN_KEY);
    if (stored) {
      accessToken = stored;
      return accessToken;
    }
  } catch (e) {
    // Ignore storage errors
  }
  
  return null;
}

/**
 * Get refresh token
 */
export function getRefreshToken(): string | null {
  if (refreshToken) {
    return refreshToken;
  }
  
  // Try cookie
  const cookieToken = getCookie(REFRESH_TOKEN_KEY);
  if (cookieToken) {
    refreshToken = cookieToken;
    return refreshToken;
  }
  
  // Try localStorage
  try {
    const stored = localStorage.getItem(REFRESH_TOKEN_KEY);
    if (stored) {
      refreshToken = stored;
      return refreshToken;
    }
  } catch (e) {
    // Ignore storage errors
  }
  
  return null;
}

/**
 * Set user
 */
export function setUser(userData: any) {
  user = userData;
  try {
    localStorage.setItem(USER_KEY, JSON.stringify(userData));
  } catch (e) {
    // Ignore storage errors
  }
}

/**
 * Get user
 */
export function getUser(): any | null {
  if (user) {
    return user;
  }
  
  try {
    const stored = localStorage.getItem(USER_KEY);
    if (stored) {
      user = JSON.parse(stored);
      return user;
    }
  } catch (e) {
    // Ignore storage errors
  }
  
  return null;
}

/**
 * Clear all tokens and user data
 */
export function clearTokens() {
  accessToken = null;
  refreshToken = null;
  user = null;
  
  // Clear cookies
  deleteCookie(ACCESS_TOKEN_KEY);
  deleteCookie(REFRESH_TOKEN_KEY);
  
  // Clear localStorage
  try {
    localStorage.removeItem(ACCESS_TOKEN_KEY);
    localStorage.removeItem(REFRESH_TOKEN_KEY);
    localStorage.removeItem(USER_KEY);
  } catch (e) {
    // Ignore storage errors
  }
}

/**
 * Check if user is authenticated
 */
export function isAuthenticated(): boolean {
  return !!getAccessToken();
}

/**
 * Parse JWT token to get payload
 */
export function parseJwt(token: string): any {
  try {
    const base64Url = token.split('.')[1];
    const base64 = base64Url.replace(/-/g, '+').replace(/_/g, '/');
    const jsonPayload = decodeURIComponent(
      atob(base64)
        .split('')
        .map(c => '%' + ('00' + c.charCodeAt(0).toString(16)).slice(-2))
        .join('')
    );
    return JSON.parse(jsonPayload);
  } catch (e) {
    return null;
  }
}

/**
 * Check if token is expired
 */
export function isTokenExpired(token: string): boolean {
  const payload = parseJwt(token);
  if (!payload || !payload.exp) {
    return true;
  }
  const exp = payload.exp * 1000; // Convert to milliseconds
  return Date.now() >= exp;
}
```

### Step 5: Update Auth Context with Cookie Support

**frontend/lib/auth/AuthContext.tsx** (update)

```tsx
'use client';

import React, { createContext, useContext, useState, useCallback, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { 
  getAccessToken, 
  getRefreshToken, 
  getUser, 
  setTokens, 
  setUser, 
  clearTokens,
  isAuthenticated as checkAuth,
  isTokenExpired,
  getCookie,
  deleteCookie
} from './token';
import { post } from '@/lib/api/client';

interface AuthContextType {
  user: any | null;
  isAuthenticated: boolean;
  isLoading: boolean;
  login: (email: string, password: string) => Promise<void>;
  register: (data: any) => Promise<void>;
  logout: () => void;
  refreshToken: () => Promise<string | null>;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const router = useRouter();
  const [user, setUserState] = useState<any | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  // Initialize auth state
  useEffect(() => {
    const initAuth = async () => {
      const token = getAccessToken();
      const storedUser = getUser();
      
      if (token && !isTokenExpired(token)) {
        setUserState(storedUser);
      } else if (token && isTokenExpired(token)) {
        // Try to refresh
        try {
          await refreshTokenInternal();
        } catch {
          clearTokens();
          setUserState(null);
        }
      } else {
        clearTokens();
        setUserState(null);
      }
      
      setIsLoading(false);
    };

    initAuth();
  }, []);

  // Refresh token function
  const refreshTokenInternal = useCallback(async (): Promise<string | null> => {
    const refresh = getRefreshToken();
    if (!refresh) {
      throw new Error('No refresh token');
    }

    try {
      const response = await post<{ access: string }>(
        '/token/refresh/',
        { refresh }
      );

      if (response.error) {
        throw new Error(response.error.detail || 'Failed to refresh token');
      }

      if (response.data) {
        const newAccessToken = response.data.access;
        const existingRefresh = getRefreshToken() || '';
        setTokens(newAccessToken, existingRefresh);
        return newAccessToken;
      }

      throw new Error('No token received');
    } catch (error) {
      clearTokens();
      setUserState(null);
      throw error;
    }
  }, []);

  // Login function
  const login = useCallback(async (email: string, password: string) => {
    setIsLoading(true);
    try {
      const response = await post<{ access: string; refresh: string; user: any }>(
        '/token/',
        { email, password }
      );

      if (response.error) {
        throw new Error(response.error.detail || 'Login failed');
      }

      if (response.data) {
        const { access, refresh, user: userData } = response.data;
        setTokens(access, refresh);
        setUser(userData);
        setUserState(userData);
        
        // Refresh the page to update server-side auth state
        window.location.href = '/dashboard';
      }
    } catch (error) {
      clearTokens();
      setUserState(null);
      throw error;
    } finally {
      setIsLoading(false);
    }
  }, []);

  // Register function
  const register = useCallback(async (data: any) => {
    setIsLoading(true);
    try {
      const response = await post<{ access: string; refresh: string; user: any }>(
        '/users/register/',
        data
      );

      if (response.error) {
        throw new Error(response.error.detail || 'Registration failed');
      }

      if (response.data) {
        const { access, refresh, user: userData } = response.data;
        setTokens(access, refresh);
        setUser(userData);
        setUserState(userData);
        
        // Refresh the page to update server-side auth state
        window.location.href = '/dashboard';
      }
    } catch (error) {
      clearTokens();
      setUserState(null);
      throw error;
    } finally {
      setIsLoading(false);
    }
  }, []);

  // Logout function
  const logout = useCallback(() => {
    clearTokens();
    setUserState(null);
    // Force a reload to clear server-side state
    window.location.href = '/login';
  }, []);

  // Check if authenticated
  const isAuthenticated = checkAuth();

  const value = {
    user,
    isAuthenticated,
    isLoading,
    login,
    register,
    logout,
    refreshToken: refreshTokenInternal,
  };

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

export function useAuth() {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
}
```

### Step 6: Create Server-Side Protected Layout

**frontend/app/(dashboard)/layout.tsx** (update with server-side auth)

```tsx
'use client';

import { ProtectedRoute } from '@/components/auth/ProtectedRoute';
import { RoleGuard } from '@/components/auth/RoleGuard';
import { useAuth } from '@/hooks/useAuth';
import { usePermissions } from '@/hooks/usePermissions';
import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { 
  LayoutDashboard, 
  FolderKanban, 
  ListTodo, 
  Users, 
  Settings,
  LogOut,
  UserCog,
  Shield
} from 'lucide-react';
import { cn } from '@/lib/utils/helpers';

export default function DashboardLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const pathname = usePathname();
  const { user, logout } = useAuth();
  const { isAdmin, isManagerOrHigher } = usePermissions();

  const baseNavigation = [
    { name: 'Dashboard', href: '/dashboard', icon: LayoutDashboard },
    { name: 'Projects', href: '/projects', icon: FolderKanban },
    { name: 'Tasks', href: '/tasks', icon: ListTodo },
  ];

  // Role-based navigation items
  const adminOnly = [
    { name: 'Users', href: '/users', icon: Users },
    { name: 'Admin', href: '/admin', icon: Shield },
  ];

  const managerOnly = [
    { name: 'Users', href: '/users', icon: Users },
  ];

  let navigation = [...baseNavigation];
  
  if (isAdmin) {
    navigation = [...navigation, ...adminOnly];
  } else if (isManagerOrHigher) {
    navigation = [...navigation, ...managerOnly];
  }

  // Settings is always visible
  navigation.push({ name: 'Settings', href: '/settings', icon: Settings });

  const handleLogout = () => {
    logout();
  };

  return (
    <ProtectedRoute>
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
                  {user?.first_name?.[0] || user?.email?.[0] || 'U'}
                </div>
                <div className="flex-1">
                  <p className="text-sm font-medium">
                    {user?.first_name ? `${user.first_name} ${user.last_name || ''}` : user?.email}
                  </p>
                  <p className="text-xs text-secondary-500">
                    {user?.role_display || user?.role}
                  </p>
                </div>
                <button
                  onClick={handleLogout}
                  className="rounded-md p-1 text-secondary-400 hover:bg-secondary-100 hover:text-secondary-600"
                  aria-label="Logout"
                >
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
    </ProtectedRoute>
  );
}
```

### Step 7: Create Server-Side Auth Example Component

**frontend/app/(dashboard)/dashboard/page.tsx** (update with server data)

```tsx
'use client';

import { useEffect, useState } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/Card';
import { useAuth } from '@/hooks/useAuth';
import { get } from '@/lib/api/client';
import { ENDPOINTS } from '@/lib/api/endpoints';

export default function DashboardPage() {
  const { user } = useAuth();
  const [stats, setStats] = useState<any>(null);

  useEffect(() => {
    const fetchStats = async () => {
      const response = await get(ENDPOINTS.tasks.stats);
      if (response.data) {
        setStats(response.data);
      }
    };
    fetchStats();
  }, []);

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold">Welcome back, {user?.first_name || user?.email}!</h1>
        <p className="text-secondary-500">Here's what's happening with your tasks</p>
      </div>

      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Total Tasks</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{stats?.total || 0}</div>
          </CardContent>
        </Card>
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">In Progress</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{stats?.in_progress || 0}</div>
          </CardContent>
        </Card>
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Completed</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{stats?.done || 0}</div>
          </CardContent>
        </Card>
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Overdue</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-danger-600">{stats?.overdue || 0}</div>
          </CardContent>
        </Card>
      </div>

      <div className="grid gap-4 md:grid-cols-2">
        <Card>
          <CardHeader>
            <CardTitle>Quick Actions</CardTitle>
          </CardHeader>
          <CardContent className="space-y-2">
            <a href="/tasks/create" className="block w-full rounded-lg bg-primary-50 p-4 text-center hover:bg-primary-100 transition-colors">
              Create New Task
            </a>
            <a href="/projects/create" className="block w-full rounded-lg bg-secondary-50 p-4 text-center hover:bg-secondary-100 transition-colors">
              Create New Project
            </a>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Profile</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-2">
              <p><span className="font-medium">Name:</span> {user?.first_name} {user?.last_name}</p>
              <p><span className="font-medium">Email:</span> {user?.email}</p>
              <p><span className="font-medium">Role:</span> {user?.role_display}</p>
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
```

---

## The Verification

### Step 1: Start the Servers

```bash
# Terminal 1 - Backend
cd backend
source venv/bin/activate
python manage.py runserver

# Terminal 2 - Frontend
cd frontend
npm run dev
```

### Step 2: Test Middleware

1. Try to access /dashboard without being logged in
2. ✅ Should redirect to /login
3. Try to access /login while logged in
4. ✅ Should redirect to /dashboard

### Step 3: Test Server-Side Auth

1. Login to the application
2. Check the cookies: Should see `access_token` and `refresh_token`
3. Navigate to /dashboard - should load with user data

### Step 4: Test Client-Side Auth

1. Login → should redirect to dashboard
2. User data should be displayed in the sidebar
3. Click logout → should clear tokens and redirect to login

### Step 5: Test Token Persistence

1. Login
2. Close and reopen browser
3. Go to /dashboard
4. ✅ Should stay logged in (cookies persist)

### Step 6: Test Role-Based Middleware Protection

1. Login as member
2. Try to access /admin
3. ✅ Should redirect to dashboard (if configured)
4. Login as admin
5. Try to access /admin
6. ✅ Should be allowed

---

## Key Takeaways

1. **Next.js middleware** provides route protection at the request level.

2. **Server-side authentication** allows Server Components to access user data.

3. **Cookies** are the most secure way to store tokens in the browser.

4. **Client-side auth context** manages authentication state in the UI.

5. **Role-based route protection** can be implemented at both middleware and component levels.

6. **Token refresh** should be handled automatically in the API client.

7. **Server actions** can be used for server-side authentication checks.

---

## What's Next

In **Part 19**, we'll implement Next.js request interception:

- Request interception patterns
- API route protection
- CSRF protection
- Security headers

---

**End of Part 18**

*Next: Part 19 - Next.js Request Interception*
