# Part 15: JWT with SimpleJWT

## Implementing Frontend Authentication

Welcome to **Part 15** of the Django REST Framework & Next.js 16 masterclass. Now that we have our backend authentication set up with JWT, it's time to implement the frontend authentication system. We'll build a complete authentication flow including login, registration, token management, and protected routes.

In this part, we'll:
- Build authentication components (Login, Register)
- Implement token storage and management
- Create authenticated API client
- Implement route protection
- Build automatic token refresh
- Handle logout and session expiration

Think of this as building the **front door** to your application. It needs to be welcoming for legitimate users but secure enough to keep unauthorized visitors out.

---

## The Target

We'll build a complete frontend authentication system:

```
frontend/
├── lib/
│   ├── auth/
│   │   ├── AuthContext.tsx      # Authentication context
│   │   ├── auth.ts              # Authentication utilities
│   │   └── token.ts             # Token management
│   └── api/
│       └── client.ts            # Authenticated API client
├── components/
│   └── auth/
│       ├── LoginForm.tsx
│       ├── RegisterForm.tsx
│       └── ProtectedRoute.tsx
├── hooks/
│   └── useAuth.ts               # Authentication hook
└── middleware.ts                # Next.js route protection
```

---

## The Concept

### Token Management Strategy

**Storage:**
- Access Token: Memory (state) or HTTP-only cookie (more secure)
- Refresh Token: HTTP-only cookie (most secure) or localStorage (less secure)

**Flow:**
```
1. User logs in
2. Store tokens securely
3. Include access token in API requests
4. When access token expires, use refresh token
5. If refresh fails, redirect to login
```

### Authentication Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                      Authentication Flow                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────┐     ┌─────────────┐     ┌─────────────┐       │
│  │   Login     │────▶│  Store Tokens│────▶│  Request    │       │
│  │   Form      │     │  in Memory  │     │  API with   │       │
│  │             │     │             │     │  Access     │       │
│  └─────────────┘     └─────────────┘     └─────────────┘       │
│         ▲                                        │             │
│         │                                        ▼             │
│  ┌─────┴─────┐     ┌─────────────┐     ┌─────────────┐       │
│  │  Logout   │◀────│  Refresh    │◀────│  401        │       │
│  │           │     │  Token      │     │  Unauthorized│       │
│  └───────────┘     └─────────────┘     └─────────────┘       │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## The Implementation

### Step 1: Create Token Management

**frontend/lib/auth/token.ts** (create)

```tsx
/**
 * Token management utilities
 */

// Keys for localStorage
const ACCESS_TOKEN_KEY = 'taskflow_access_token';
const REFRESH_TOKEN_KEY = 'taskflow_refresh_token';
const USER_KEY = 'taskflow_user';

// Memory storage for tokens (more secure than localStorage)
let accessToken: string | null = null;
let refreshToken: string | null = null;
let user: any = null;

/**
 * Set tokens in memory
 */
export function setTokens(access: string, refresh: string) {
  accessToken = access;
  refreshToken = refresh;
  
  // Store in localStorage as backup (less secure but persistent)
  try {
    localStorage.setItem(ACCESS_TOKEN_KEY, access);
    localStorage.setItem(REFRESH_TOKEN_KEY, refresh);
  } catch (e) {
    // Ignore storage errors
  }
}

/**
 * Get access token
 */
export function getAccessToken(): string | null {
  if (accessToken) {
    return accessToken;
  }
  
  // Try to get from localStorage
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
  
  // Try to get from localStorage
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

### Step 2: Create Authentication Context

**frontend/lib/auth/AuthContext.tsx** (create)

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
  isTokenExpired
} from './token';
import { post } from '@/lib/api/client';
import { ENDPOINTS } from '@/lib/api/endpoints';

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
        // Update tokens (keep existing refresh token)
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
        router.push('/dashboard');
      }
    } catch (error) {
      clearTokens();
      setUserState(null);
      throw error;
    } finally {
      setIsLoading(false);
    }
  }, [router]);

  // Logout function
  const logout = useCallback(() => {
    clearTokens();
    setUserState(null);
    router.push('/login');
  }, [router]);

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

### Step 3: Update API Client with Token Interceptor

**frontend/lib/api/client.ts** (update)

```tsx
/**
 * API client with token management
 */

import { getAccessToken, getRefreshToken, setTokens, clearTokens } from '@/lib/auth/token';
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
 * Build URL with query parameters
 */
function buildUrl(endpoint: string, params?: Record<string, any>): string {
  const url = new URL(`${API_BASE_URL}${endpoint}`);
  if (params) {
    Object.entries(params).forEach(([key, value]) => {
      if (value !== undefined && value !== null && value !== '') {
        url.searchParams.append(key, String(value));
      }
    });
  }
  return url.toString();
}

/**
 * Make an API request with automatic token handling
 */
export async function apiRequest<T = any>(
  endpoint: string,
  options: RequestInit = {},
  params?: Record<string, any>
): Promise<ApiResponse<T>> {
  const url = buildUrl(endpoint, params);
  
  // Get access token
  let token = getAccessToken();
  
  // Check if token is expired and refresh if needed
  if (token) {
    // We'll let the interceptor handle this
    // The actual check happens in the AuthContext
  }
  
  const headers: HeadersInit = {
    'Content-Type': 'application/json',
    ...options.headers,
  };
  
  // Add Authorization header if token exists
  if (token) {
    headers['Authorization'] = `Bearer ${token}`;
  }

  try {
    let response = await fetch(url, {
      ...options,
      headers,
    });

    // If unauthorized and we have a refresh token, try to refresh
    if (response.status === 401) {
      const refreshToken = getRefreshToken();
      if (refreshToken) {
        try {
          // Try to refresh the token
          const refreshResponse = await fetch(`${API_BASE_URL}/token/refresh/`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ refresh: refreshToken }),
          });

          if (refreshResponse.ok) {
            const refreshData = await refreshResponse.json();
            if (refreshData.access) {
              // Update tokens
              setTokens(refreshData.access, refreshToken);
              
              // Retry the original request with new token
              headers['Authorization'] = `Bearer ${refreshData.access}`;
              response = await fetch(url, {
                ...options,
                headers,
              });
            }
          } else {
            // Refresh failed - clear tokens
            clearTokens();
          }
        } catch (e) {
          // Refresh failed - clear tokens
          clearTokens();
        }
      }
    }

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

// Export all request methods
export async function get<T = any>(
  endpoint: string,
  params?: Record<string, any>
): Promise<ApiResponse<T>> {
  return apiRequest<T>(endpoint, { method: 'GET' }, params);
}

export async function post<T = any>(
  endpoint: string,
  data?: any,
  params?: Record<string, any>
): Promise<ApiResponse<T>> {
  return apiRequest<T>(
    endpoint,
    {
      method: 'POST',
      body: data ? JSON.stringify(data) : undefined,
    },
    params
  );
}

export async function put<T = any>(
  endpoint: string,
  data?: any,
  params?: Record<string, any>
): Promise<ApiResponse<T>> {
  return apiRequest<T>(
    endpoint,
    {
      method: 'PUT',
      body: data ? JSON.stringify(data) : undefined,
    },
    params
  );
}

export async function patch<T = any>(
  endpoint: string,
  data?: any,
  params?: Record<string, any>
): Promise<ApiResponse<T>> {
  return apiRequest<T>(
    endpoint,
    {
      method: 'PATCH',
      body: data ? JSON.stringify(data) : undefined,
    },
    params
  );
}

export async function del<T = any>(
  endpoint: string,
  params?: Record<string, any>
): Promise<ApiResponse<T>> {
  return apiRequest<T>(endpoint, { method: 'DELETE' }, params);
}
```

### Step 4: Create Authentication Components

**frontend/components/auth/LoginForm.tsx** (create)

```tsx
'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import Link from 'next/link';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/Card';
import { useAuth } from '@/lib/auth/AuthContext';
import { useToast } from '@/lib/context/ToastContext';

export function LoginForm() {
  const router = useRouter();
  const { login } = useAuth();
  const { addToast } = useToast();
  const [loading, setLoading] = useState(false);
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [errors, setErrors] = useState<Record<string, string[]>>({});

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setErrors({});

    try {
      await login(email, password);
      addToast('Welcome back!', 'success');
      router.push('/dashboard');
    } catch (error: any) {
      // Handle validation errors
      if (error.response?.data) {
        setErrors(error.response.data);
      } else {
        addToast(error.message || 'Login failed. Please try again.', 'error');
      }
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
          {errors.general && (
            <div className="rounded-md bg-danger-50 p-3 text-sm text-danger-600">
              {errors.general.join(', ')}
            </div>
          )}

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

**frontend/components/auth/RegisterForm.tsx** (create)

```tsx
'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import Link from 'next/link';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/Card';
import { useAuth } from '@/lib/auth/AuthContext';
import { useToast } from '@/lib/context/ToastContext';

export function RegisterForm() {
  const router = useRouter();
  const { register } = useAuth();
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
  const [errors, setErrors] = useState<Record<string, string[]>>({});

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setFormData({
      ...formData,
      [e.target.id]: e.target.value,
    });
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setErrors({});

    if (formData.password !== formData.confirm_password) {
      addToast('Passwords do not match', 'error');
      setLoading(false);
      return;
    }

    try {
      await register(formData);
      addToast('Account created successfully!', 'success');
      router.push('/dashboard');
    } catch (error: any) {
      // Handle validation errors
      if (error.response?.data) {
        setErrors(error.response.data);
      } else {
        addToast(error.message || 'Registration failed. Please try again.', 'error');
      }
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
          {errors.general && (
            <div className="rounded-md bg-danger-50 p-3 text-sm text-danger-600">
              {errors.general.join(', ')}
            </div>
          )}

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
            {errors.email && (
              <p className="mt-1 text-sm text-danger-600">{errors.email.join(', ')}</p>
            )}
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
            {errors.username && (
              <p className="mt-1 text-sm text-danger-600">{errors.username.join(', ')}</p>
            )}
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
            {errors.password && (
              <p className="mt-1 text-sm text-danger-600">{errors.password.join(', ')}</p>
            )}
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
            {errors.confirm_password && (
              <p className="mt-1 text-sm text-danger-600">{errors.confirm_password.join(', ')}</p>
            )}
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

### Step 5: Update Login and Register Pages

**frontend/app/(auth)/login/page.tsx** (update)

```tsx
import { Metadata } from 'next';
import { LoginForm } from '@/components/auth/LoginForm';

export const metadata: Metadata = {
  title: 'Login',
  description: 'Sign in to your account',
};

export default function LoginPage() {
  return <LoginForm />;
}
```

**frontend/app/(auth)/register/page.tsx** (update)

```tsx
import { Metadata } from 'next';
import { RegisterForm } from '@/components/auth/RegisterForm';

export const metadata: Metadata = {
  title: 'Register',
  description: 'Create a new account',
};

export default function RegisterPage() {
  return <RegisterForm />;
}
```

### Step 6: Create ProtectedRoute Component

**frontend/components/auth/ProtectedRoute.tsx** (create)

```tsx
'use client';

import { useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { useAuth } from '@/lib/auth/AuthContext';
import { LoadingSpinner } from '@/components/ui/LoadingSpinner';

interface ProtectedRouteProps {
  children: React.ReactNode;
}

export function ProtectedRoute({ children }: ProtectedRouteProps) {
  const router = useRouter();
  const { isAuthenticated, isLoading } = useAuth();

  useEffect(() => {
    if (!isLoading && !isAuthenticated) {
      router.push('/login');
    }
  }, [isLoading, isAuthenticated, router]);

  if (isLoading) {
    return (
      <div className="flex h-[calc(100vh-6rem)] items-center justify-center">
        <LoadingSpinner size="lg" />
      </div>
    );
  }

  if (!isAuthenticated) {
    return null;
  }

  return <>{children}</>;
}
```

### Step 7: Create Authentication Hook

**frontend/hooks/useAuth.ts** (create)

```tsx
'use client';

import { useAuth as useAuthContext } from '@/lib/auth/AuthContext';

export function useAuth() {
  return useAuthContext();
}
```

### Step 8: Update Dashboard Layout with Auth

**frontend/app/(dashboard)/layout.tsx** (update)

```tsx
'use client';

import { ProtectedRoute } from '@/components/auth/ProtectedRoute';
import { useAuth } from '@/hooks/useAuth';
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
  const { user, logout } = useAuth();

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
                  <p className="text-xs text-secondary-500">{user?.email}</p>
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

### Step 9: Update Root Layout with Auth Provider

**frontend/app/layout.tsx** (update)

```tsx
import type { Metadata } from 'next';
import { Inter } from 'next/font/google';
import { AuthProvider } from '@/lib/auth/AuthContext';
import { ToastProvider } from '@/lib/context/ToastContext';
import { QueryProvider } from '@/components/providers/QueryProvider';
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
        <QueryProvider>
          <AuthProvider>
            <ToastProvider>
              {children}
              <ToastContainer />
            </ToastProvider>
          </AuthProvider>
        </QueryProvider>
      </body>
    </html>
  );
}
```

### Step 10: Update API Endpoints

**frontend/lib/api/endpoints.ts** (update)

```tsx
/**
 * API endpoint definitions
 */

export const ENDPOINTS = {
  // Auth
  auth: {
    token: '/token/',
    refresh: '/token/refresh/',
    verify: '/token/verify/',
  },
  
  // Users
  users: {
    list: '/users/',
    detail: (id: number) => `/users/${id}/`,
    profile: '/users/profile/',
    register: '/users/register/',
    setRole: (id: number) => `/users/${id}/set_role/`,
  },
  
  // Projects
  projects: {
    list: '/projects/',
    detail: (id: number) => `/projects/${id}/`,
    tasks: (id: number) => `/projects/${id}/tasks/`,
    addTask: (id: number) => `/projects/${id}/add_task/`,
    stats: (id: number) => `/projects/${id}/stats/`,
  },
  
  // Tasks
  tasks: {
    list: '/tasks/',
    detail: (id: number) => `/tasks/${id}/`,
    status: (id: number) => `/tasks/${id}/status/`,
    comments: (id: number) => `/tasks/${id}/comments/`,
    stats: '/tasks/stats/',
  },
  
  // Comments
  comments: {
    list: '/comments/',
    detail: (id: number) => `/comments/${id}/`,
    byTask: '/comments/by_task/',
  },
};
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

### Step 2: Test Registration

1. Go to http://localhost:3000/register
2. Fill in the form
3. Submit
4. ✅ Should redirect to dashboard
5. ✅ Should show success toast

### Step 3: Test Login

1. Go to http://localhost:3000/login
2. Enter credentials
3. Submit
4. ✅ Should redirect to dashboard
5. ✅ Should show welcome toast

### Step 4: Test Protected Routes

1. Try to access http://localhost:3000/dashboard without being logged in
2. ✅ Should redirect to login

### Step 5: Test Token Persistence

1. Login
2. Close and reopen the browser
3. Go to http://localhost:3000/dashboard
4. ✅ Should stay logged in (tokens persisted in localStorage)

### Step 6: Test Logout

1. Click the logout button in sidebar
2. ✅ Should redirect to login
3. ✅ Tokens should be cleared

### Step 7: Test API Authentication

Open browser dev tools and check network tab:

1. Login → See token request with access/refresh tokens
2. API requests → See Authorization: Bearer header
3. Token refresh → See refresh request when token expires

---

## Key Takeaways

1. **Token storage**: Memory + localStorage for persistence.

2. **Token refresh**: Automatic when API returns 401.

3. **Protected routes**: Middleware and ProtectedRoute component.

4. **Auth Context**: Centralized authentication state management.

5. **API interceptor**: Automatically adds tokens to requests.

6. **User experience**: Loading states, error handling, redirects.

---

## What's Next

In **Part 16**, we'll implement DRF permissions:

- Permission classes
- Custom permissions
- Object-level permissions
- Role-based access control

---

**End of Part 15**

*Next: Part 16 - DRF Permissions*
