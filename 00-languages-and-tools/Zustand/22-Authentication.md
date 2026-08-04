# Part 6 — Production Patterns

## Section 22: Authentication

Authentication is the foundation of most production applications. Managing JWT tokens, session persistence, refresh tokens, and role-based access control can be complex. In this section, you'll learn how to build a robust authentication system using Zustand that works across web, mobile, and Next.js environments.

---

## The Target: Production-Ready Authentication

By the end of this section, you'll be able to:
- Implement JWT token management with automatic refresh
- Persist authentication state across sessions
- Build role-based access control (RBAC) for routes and features
- Handle login, logout, and session expiry gracefully
- Secure tokens with appropriate storage strategies
- Implement protected routes and API interceptors

---

## The Concept: Authentication as a Security System

Think of authentication like a **secure building access system**:

```
┌─────────────────────────────────────────────────────────────────┐
│                    AUTHENTICATION SYSTEM                       │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  User Login                                             │  │
│  │  • Username/Password                                    │  │
│  │  • Biometric (mobile)                                   │  │
│  │  • OAuth (Google, GitHub)                               │  │
│  └──────────────────────────────────────────────────────────┘  │
│                         │                                      │
│                         ▼                                      │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Token Management                                       │  │
│  │  • Access Token (short-lived)                           │  │
│  │  • Refresh Token (long-lived)                           │  │
│  │  • Secure storage                                       │  │
│  └──────────────────────────────────────────────────────────┘  │
│                         │                                      │
│                         ▼                                      │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Authorization                                          │  │
│  │  • Role-based access (RBAC)                            │  │
│  │  • Permission checks                                    │  │
│  │  • Route protection                                     │  │
│  └──────────────────────────────────────────────────────────┘  │
│                         │                                      │
│                         ▼                                      │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Session Management                                     │  │
│  │  • Persistence across reloads                           │  │
│  │  • Auto-logout on expiry                                │  │
│  │  • Multi-tab sync                                       │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

---

## The Implementation: Authentication Store

### Step 1: Define Types and API Client

First, let's set up the types and API client:

```typescript
// src/types/auth.types.ts
export interface User {
  id: string;
  email: string;
  name: string;
  role: 'admin' | 'manager' | 'user';
  avatar?: string;
  permissions: string[];
  createdAt: Date;
  updatedAt: Date;
}

export interface AuthTokens {
  accessToken: string;
  refreshToken: string;
  expiresIn: number; // seconds
  tokenType: string;
}

export interface LoginCredentials {
  email: string;
  password: string;
}

export interface RegisterCredentials {
  email: string;
  password: string;
  name: string;
}

export interface AuthState {
  user: User | null;
  tokens: AuthTokens | null;
  isAuthenticated: boolean;
  isLoading: boolean;
  error: string | null;
}
```

```typescript
// src/services/authApi.ts
import { LoginCredentials, RegisterCredentials, AuthTokens, User } from '../types/auth.types';

const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || 'https://api.example.com';

// API client with token injection
export const authApi = {
  login: async (credentials: LoginCredentials): Promise<{ user: User; tokens: AuthTokens }> => {
    const response = await fetch(`${API_BASE_URL}/auth/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(credentials),
    });

    if (!response.ok) {
      const error = await response.json();
      throw new Error(error.message || 'Login failed');
    }

    return response.json();
  },

  register: async (credentials: RegisterCredentials): Promise<{ user: User; tokens: AuthTokens }> => {
    const response = await fetch(`${API_BASE_URL}/auth/register`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(credentials),
    });

    if (!response.ok) {
      const error = await response.json();
      throw new Error(error.message || 'Registration failed');
    }

    return response.json();
  },

  refreshToken: async (refreshToken: string): Promise<AuthTokens> => {
    const response = await fetch(`${API_BASE_URL}/auth/refresh`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ refreshToken }),
    });

    if (!response.ok) {
      const error = await response.json();
      throw new Error(error.message || 'Token refresh failed');
    }

    return response.json();
  },

  logout: async (refreshToken: string): Promise<void> => {
    await fetch(`${API_BASE_URL}/auth/logout`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ refreshToken }),
    });
  },

  getCurrentUser: async (accessToken: string): Promise<User> => {
    const response = await fetch(`${API_BASE_URL}/auth/me`, {
      headers: {
        'Authorization': `Bearer ${accessToken}`,
      },
    });

    if (!response.ok) {
      throw new Error('Failed to get user data');
    }

    return response.json();
  },
};
```

### Step 2: Create the Authentication Store

Now build the auth store with all authentication logic:

```typescript
// src/store/authStore.ts
import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';
import { immer } from 'zustand/middleware/immer';
import { AuthState, User, AuthTokens, LoginCredentials, RegisterCredentials } from '../types/auth.types';
import { authApi } from '../services/authApi';

interface AuthStore extends AuthState {
  // Actions
  login: (credentials: LoginCredentials) => Promise<void>;
  register: (credentials: RegisterCredentials) => Promise<void>;
  logout: () => Promise<void>;
  refreshSession: () => Promise<void>;
  checkAuth: () => Promise<boolean>;
  updateUser: (updates: Partial<User>) => void;
  clearError: () => void;
  
  // Token helpers
  getAccessToken: () => string | null;
  getRefreshToken: () => string | null;
  isTokenValid: () => boolean;
  hasRole: (role: User['role']) => boolean;
  hasPermission: (permission: string) => boolean;
}

// Initial state
const initialState: AuthState = {
  user: null,
  tokens: null,
  isAuthenticated: false,
  isLoading: false,
  error: null,
};

// Secure storage adapter (platform-specific)
// For web, use localStorage with encryption
// For mobile, use SecureStore/Keychain
const secureStorage = {
  getItem: (key: string) => {
    try {
      // In production, use encrypted storage
      return localStorage.getItem(key);
    } catch {
      return null;
    }
  },
  setItem: (key: string, value: string) => {
    try {
      localStorage.setItem(key, value);
    } catch {
      // Handle storage full/disabled
    }
  },
  removeItem: (key: string) => {
    try {
      localStorage.removeItem(key);
    } catch {
      // Handle errors
    }
  },
};

export const useAuthStore = create<AuthStore>()(
  persist(
    immer((set, get) => ({
      ...initialState,

      // --- Login ---
      login: async (credentials: LoginCredentials) => {
        set({ isLoading: true, error: null });
        
        try {
          const { user, tokens } = await authApi.login(credentials);
          
          set({
            user,
            tokens,
            isAuthenticated: true,
            isLoading: false,
            error: null,
          });
        } catch (error) {
          set({
            isLoading: false,
            error: error instanceof Error ? error.message : 'Login failed',
          });
          throw error;
        }
      },

      // --- Register ---
      register: async (credentials: RegisterCredentials) => {
        set({ isLoading: true, error: null });
        
        try {
          const { user, tokens } = await authApi.register(credentials);
          
          set({
            user,
            tokens,
            isAuthenticated: true,
            isLoading: false,
            error: null,
          });
        } catch (error) {
          set({
            isLoading: false,
            error: error instanceof Error ? error.message : 'Registration failed',
          });
          throw error;
        }
      },

      // --- Logout ---
      logout: async () => {
        const { tokens } = get();
        
        set({ isLoading: true });
        
        try {
          if (tokens?.refreshToken) {
            await authApi.logout(tokens.refreshToken);
          }
        } catch (error) {
          // Even if server logout fails, we clear local state
          console.error('Logout error:', error);
        } finally {
          // Clear state regardless of server response
          set({
            ...initialState,
            isLoading: false,
          });
        }
      },

      // --- Refresh Session ---
      refreshSession: async () => {
        const { tokens } = get();
        
        if (!tokens?.refreshToken) {
          set({ isAuthenticated: false });
          return;
        }

        set({ isLoading: true, error: null });

        try {
          const newTokens = await authApi.refreshToken(tokens.refreshToken);
          
          // If we got new tokens, update them
          set({
            tokens: newTokens,
            isLoading: false,
          });
          
          // Optionally refresh user data
          try {
            const user = await authApi.getCurrentUser(newTokens.accessToken);
            set({ user });
          } catch (userError) {
            console.error('Failed to refresh user data:', userError);
          }
        } catch (error) {
          // Refresh failed - clear auth state
          set({
            ...initialState,
            isLoading: false,
            error: error instanceof Error ? error.message : 'Session expired',
          });
          throw error;
        }
      },

      // --- Check Authentication ---
      checkAuth: async () => {
        const { tokens, isAuthenticated } = get();
        
        if (!tokens) {
          set({ isAuthenticated: false });
          return false;
        }

        // If already authenticated, just return true
        if (isAuthenticated) {
          return true;
        }

        // Try to refresh the session
        try {
          await get().refreshSession();
          return true;
        } catch {
          return false;
        }
      },

      // --- Update User ---
      updateUser: (updates: Partial<User>) => {
        set((state) => {
          if (state.user) {
            Object.assign(state.user, updates);
          }
        });
      },

      // --- Clear Error ---
      clearError: () => {
        set({ error: null });
      },

      // --- Token Helpers ---
      getAccessToken: () => {
        return get().tokens?.accessToken || null;
      },

      getRefreshToken: () => {
        return get().tokens?.refreshToken || null;
      },

      isTokenValid: () => {
        const { tokens } = get();
        if (!tokens) return false;
        
        // Check if token is expired (with 30 second buffer)
        try {
          const payload = JSON.parse(atob(tokens.accessToken.split('.')[1]));
          const expiry = payload.exp * 1000; // Convert to milliseconds
          const now = Date.now();
          return expiry > now + 30000; // 30 second buffer
        } catch {
          return false;
        }
      },

      // --- Authorization Helpers ---
      hasRole: (role: User['role']) => {
        const { user } = get();
        return user?.role === role;
      },

      hasPermission: (permission: string) => {
        const { user } = get();
        return user?.permissions?.includes(permission) || false;
      },
    })),
    {
      name: 'auth-storage',
      storage: createJSONStorage(() => secureStorage),
      // Only persist these fields
      partialize: (state) => ({
        user: state.user,
        tokens: state.tokens,
        isAuthenticated: state.isAuthenticated,
        // Don't persist: isLoading, error
      }),
    }
  )
);
```

### Step 3: API Client with Token Interceptor

Create an API client that automatically handles token injection and refresh:

```typescript
// src/services/apiClient.ts
import { useAuthStore } from '../store/authStore';

interface FetchOptions extends RequestInit {
  requireAuth?: boolean;
  retry?: boolean;
}

export class ApiClient {
  private baseURL: string;
  private maxRetries: number;

  constructor(baseURL: string, maxRetries: number = 3) {
    this.baseURL = baseURL;
    this.maxRetries = maxRetries;
  }

  async request<T = any>(
    endpoint: string,
    options: FetchOptions = {}
  ): Promise<T> {
    const { requireAuth = true, retry = true, ...fetchOptions } = options;
    const url = `${this.baseURL}${endpoint}`;

    // Get auth state
    const authStore = useAuthStore.getState();
    let accessToken = authStore.getAccessToken();

    // Check if token is valid
    if (requireAuth && accessToken && !authStore.isTokenValid()) {
      try {
        await authStore.refreshSession();
        accessToken = authStore.getAccessToken();
      } catch (error) {
        // Refresh failed - logout
        await authStore.logout();
        throw new Error('Session expired. Please login again.');
      }
    }

    // Prepare headers
    const headers: HeadersInit = {
      'Content-Type': 'application/json',
      ...fetchOptions.headers,
    };

    if (requireAuth && accessToken) {
      headers['Authorization'] = `Bearer ${accessToken}`;
    }

    // Make request
    const response = await fetch(url, {
      ...fetchOptions,
      headers,
    });

    // Handle response
    if (!response.ok) {
      const errorData = await response.text();
      
      // Handle 401 Unauthorized
      if (response.status === 401 && retry && requireAuth) {
        try {
          // Try refresh once
          await authStore.refreshSession();
          const newToken = authStore.getAccessToken();
          
          // Retry with new token
          const retryResponse = await fetch(url, {
            ...fetchOptions,
            headers: {
              ...headers,
              'Authorization': `Bearer ${newToken}`,
            },
          });

          if (!retryResponse.ok) {
            throw new Error(errorData || 'Request failed after retry');
          }

          const retryData = await retryResponse.json();
          return retryData;
        } catch (refreshError) {
          // Refresh failed - logout
          await authStore.logout();
          throw new Error('Session expired. Please login again.');
        }
      }

      throw new Error(errorData || `Request failed: ${response.status}`);
    }

    // Parse response (if JSON)
    const contentType = response.headers.get('content-type');
    if (contentType && contentType.includes('application/json')) {
      return await response.json();
    }

    return await response.text() as unknown as T;
  }

  // Convenience methods
  get<T = any>(endpoint: string, options?: FetchOptions): Promise<T> {
    return this.request<T>(endpoint, { ...options, method: 'GET' });
  }

  post<T = any>(endpoint: string, data?: any, options?: FetchOptions): Promise<T> {
    return this.request<T>(endpoint, {
      ...options,
      method: 'POST',
      body: data ? JSON.stringify(data) : undefined,
    });
  }

  put<T = any>(endpoint: string, data?: any, options?: FetchOptions): Promise<T> {
    return this.request<T>(endpoint, {
      ...options,
      method: 'PUT',
      body: data ? JSON.stringify(data) : undefined,
    });
  }

  patch<T = any>(endpoint: string, data?: any, options?: FetchOptions): Promise<T> {
    return this.request<T>(endpoint, {
      ...options,
      method: 'PATCH',
      body: data ? JSON.stringify(data) : undefined,
    });
  }

  delete<T = any>(endpoint: string, options?: FetchOptions): Promise<T> {
    return this.request<T>(endpoint, { ...options, method: 'DELETE' });
  }
}

// Singleton instance
export const apiClient = new ApiClient(
  process.env.NEXT_PUBLIC_API_URL || 'https://api.example.com'
);
```

### Step 4: Protected Routes

Create a protected route wrapper for React:

```tsx
// src/components/ProtectedRoute.tsx
'use client';

import React, { useEffect, ReactNode } from 'react';
import { useRouter } from 'next/navigation';
import { useAuthStore } from '../store/authStore';

interface ProtectedRouteProps {
  children: ReactNode;
  requiredRoles?: Array<'admin' | 'manager' | 'user'>;
  requiredPermissions?: string[];
  fallback?: ReactNode;
}

export function ProtectedRoute({
  children,
  requiredRoles = [],
  requiredPermissions = [],
  fallback = <div>Loading...</div>,
}: ProtectedRouteProps) {
  const router = useRouter();
  const { isAuthenticated, isLoading, user, hasRole, hasPermission } = useAuthStore();

  useEffect(() => {
    // Redirect if not authenticated
    if (!isLoading && !isAuthenticated) {
      router.push('/login');
      return;
    }

    // Check roles
    if (user && requiredRoles.length > 0) {
      const hasRequiredRole = requiredRoles.some(role => hasRole(role));
      if (!hasRequiredRole) {
        router.push('/unauthorized');
        return;
      }
    }

    // Check permissions
    if (user && requiredPermissions.length > 0) {
      const hasAllPermissions = requiredPermissions.every(perm => hasPermission(perm));
      if (!hasAllPermissions) {
        router.push('/unauthorized');
        return;
      }
    }
  }, [isLoading, isAuthenticated, user, router]);

  // Show loading state while checking auth
  if (isLoading || !isAuthenticated) {
    return <>{fallback}</>;
  }

  // Verify roles/permissions
  if (requiredRoles.length > 0) {
    const hasRequiredRole = requiredRoles.some(role => hasRole(role));
    if (!hasRequiredRole) {
      return <div>Unauthorized: Insufficient role</div>;
    }
  }

  if (requiredPermissions.length > 0) {
    const hasAllPermissions = requiredPermissions.every(perm => hasPermission(perm));
    if (!hasAllPermissions) {
      return <div>Unauthorized: Missing permissions</div>;
    }
  }

  return <>{children}</>;
}
```

### Step 5: Role-Based Access Control (RBAC)

Build a comprehensive RBAC system:

```tsx
// src/components/RBAC.tsx
'use client';

import { ReactNode } from 'react';
import { useAuthStore } from '../store/authStore';

interface CanProps {
  roles?: Array<'admin' | 'manager' | 'user'>;
  permissions?: string[];
  children: ReactNode;
  fallback?: ReactNode;
}

export function Can({ roles = [], permissions = [], children, fallback = null }: CanProps) {
  const { user, hasRole, hasPermission } = useAuthStore();

  // If no requirements, allow
  if (roles.length === 0 && permissions.length === 0) {
    return <>{children}</>;
  }

  // Check roles
  if (roles.length > 0) {
    const hasRequiredRole = roles.some(role => hasRole(role));
    if (!hasRequiredRole) {
      return <>{fallback}</>;
    }
  }

  // Check permissions
  if (permissions.length > 0) {
    const hasAllPermissions = permissions.every(perm => hasPermission(perm));
    if (!hasAllPermissions) {
      return <>{fallback}</>;
    }
  }

  return <>{children}</>;
}

// Example usage in components
function AdminPanel() {
  return (
    <div>
      <h2>Admin Panel</h2>
      
      <Can roles={['admin']}>
        <button>Delete All Users</button>
      </Can>
      
      <Can permissions={['write:settings']}>
        <button>Update Settings</button>
      </Can>
      
      <Can roles={['admin', 'manager']} permissions={['read:analytics']}>
        <div>Analytics Dashboard</div>
      </Can>
    </div>
  );
}
```

### Step 6: Login Page with Zustand

Create a login page that uses the auth store:

```tsx
// src/app/login/page.tsx
'use client';

import React, { useState } from 'react';
import { useRouter } from 'next/navigation';
import { useAuthStore } from '../../store/authStore';

export default function LoginPage() {
  const router = useRouter();
  const { login, isLoading, error, clearError } = useAuthStore();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    clearError();

    try {
      await login({ email, password });
      router.push('/dashboard');
    } catch (error) {
      // Error is already set in the store
      console.error('Login failed:', error);
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-50 py-12 px-4 sm:px-6 lg:px-8">
      <div className="max-w-md w-full space-y-8">
        <div>
          <h2 className="mt-6 text-center text-3xl font-extrabold text-gray-900">
            Sign in to your account
          </h2>
        </div>
        <form className="mt-8 space-y-6" onSubmit={handleSubmit}>
          <div className="rounded-md shadow-sm -space-y-px">
            <div>
              <label htmlFor="email" className="sr-only">
                Email address
              </label>
              <input
                id="email"
                name="email"
                type="email"
                autoComplete="email"
                required
                className="appearance-none rounded-none relative block w-full px-3 py-2 border border-gray-300 placeholder-gray-500 text-gray-900 rounded-t-md focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 focus:z-10 sm:text-sm"
                placeholder="Email address"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                disabled={isLoading}
              />
            </div>
            <div>
              <label htmlFor="password" className="sr-only">
                Password
              </label>
              <input
                id="password"
                name="password"
                type={showPassword ? 'text' : 'password'}
                autoComplete="current-password"
                required
                className="appearance-none rounded-none relative block w-full px-3 py-2 border border-gray-300 placeholder-gray-500 text-gray-900 rounded-b-md focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 focus:z-10 sm:text-sm"
                placeholder="Password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                disabled={isLoading}
              />
            </div>
          </div>

          <div className="flex items-center justify-between">
            <div className="flex items-center">
              <input
                id="show-password"
                name="show-password"
                type="checkbox"
                className="h-4 w-4 text-indigo-600 focus:ring-indigo-500 border-gray-300 rounded"
                checked={showPassword}
                onChange={(e) => setShowPassword(e.target.checked)}
              />
              <label htmlFor="show-password" className="ml-2 block text-sm text-gray-900">
                Show password
              </label>
            </div>
          </div>

          {error && (
            <div className="rounded-md bg-red-50 p-4">
              <div className="flex">
                <div className="ml-3">
                  <h3 className="text-sm font-medium text-red-800">Error</h3>
                  <div className="mt-2 text-sm text-red-700">{error}</div>
                </div>
              </div>
            </div>
          )}

          <div>
            <button
              type="submit"
              disabled={isLoading}
              className="group relative w-full flex justify-center py-2 px-4 border border-transparent text-sm font-medium rounded-md text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 disabled:opacity-50 disabled:cursor-not-allowed"
            >
              {isLoading ? 'Signing in...' : 'Sign in'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
```

### Step 7: React Native Mobile Authentication

For React Native, adapt the auth store with platform-specific storage:

```typescript
// src/store/authStore.native.ts (React Native version)
import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';
import { immer } from 'zustand/middleware/immer';
import AsyncStorage from '@react-native-async-storage/async-storage';
import * as Keychain from 'react-native-keychain';

// Secure storage adapter for React Native
const secureStorage = {
  getItem: async (key: string) => {
    try {
      const credentials = await Keychain.getInternetCredentials(key);
      return credentials ? credentials.password : null;
    } catch {
      return null;
    }
  },
  setItem: async (key: string, value: string) => {
    try {
      await Keychain.setInternetCredentials(key, 'token', value);
    } catch {
      // Fallback to AsyncStorage if Keychain fails
      await AsyncStorage.setItem(key, value);
    }
  },
  removeItem: async (key: string) => {
    try {
      await Keychain.resetInternetCredentials(key);
    } catch {
      await AsyncStorage.removeItem(key);
    }
  },
};

// Same store implementation but with secure storage
export const useAuthStore = create<AuthStore>()(
  persist(
    immer((set, get) => ({
      // ... same implementation as web version
    })),
    {
      name: 'auth-storage',
      storage: createJSONStorage(() => secureStorage),
      partialize: (state) => ({
        user: state.user,
        // Don't persist tokens in AsyncStorage - use SecureStore
      }),
    }
  )
);
```

---

## The Verification: Testing Authentication

### Step 1: Create a Test Component

```tsx
// src/components/AuthTest.tsx
'use client';

import React from 'react';
import { useAuthStore } from '../store/authStore';
import { Can } from './RBAC';

export function AuthTest() {
  const { user, isAuthenticated, isLoading, logout, hasRole } = useAuthStore();

  if (isLoading) return <div>Loading...</div>;

  return (
    <div>
      <h2>Auth Test</h2>
      
      {isAuthenticated ? (
        <div>
          <p>Welcome, {user?.name}!</p>
          <p>Email: {user?.email}</p>
          <p>Role: {user?.role}</p>
          <button onClick={logout}>Logout</button>
          
          <Can roles={['admin']}>
            <div style={{ background: 'red', padding: '10px', color: 'white' }}>
              Admin Only Content
            </div>
          </Can>
          
          <Can permissions={['write:tasks']}>
            <button>Create Task</button>
          </Can>
        </div>
      ) : (
        <div>
          <p>Not authenticated. Please login.</p>
          <button onClick={() => window.location.href = '/login'}>
            Go to Login
          </button>
        </div>
      )}
    </div>
  );
}
```

### Step 2: Test Authentication Flow

```javascript
// In browser console
import { useAuthStore } from './src/store/authStore';

// Login
await useAuthStore.getState().login({ email: 'test@example.com', password: 'password' });
console.log(useAuthStore.getState().user);

// Check token
console.log(useAuthStore.getState().getAccessToken());
console.log(useAuthStore.getState().isTokenValid());

// Refresh session
await useAuthStore.getState().refreshSession();

// Logout
await useAuthStore.getState().logout();
```

### Step 3: Test Protected Routes

1. Try accessing `/dashboard` without logging in
2. ✅ Should redirect to `/login`
3. Login and try again
4. ✅ Should access the dashboard

### Step 4: Test Role-Based Access

1. Login as a user
2. Try accessing `/admin` route
3. ✅ Should redirect to `/unauthorized`

### Step 5: Test Token Expiry

1. Login and get tokens
2. Simulate token expiry by waiting or using a tool
3. Make an API request
4. ✅ Should auto-refresh token and retry

---

## Deep Dive: Security Best Practices

### Token Storage Strategy

| Token Type | Storage Location | Persistence | Security |
|------------|------------------|-------------|----------|
| Access Token | Memory (Zustand store) | Session only | Most secure |
| Access Token | localStorage | Persistent | Medium (XSS risk) |
| Refresh Token | Secure cookie (HttpOnly) | Persistent | Very secure |
| Refresh Token | SecureStore/Keychain | Persistent | Very secure |

### CSRF Protection

```typescript
// src/services/csrf.ts
export async function getCSRFToken(): Promise<string> {
  const response = await fetch('/api/csrf');
  const data = await response.json();
  return data.csrfToken;
}

// In API requests
const csrfToken = await getCSRFToken();
const response = await fetch('/api/protected', {
  headers: {
    'X-CSRF-Token': csrfToken,
  },
});
```

### Session Expiry Handling

```typescript
// src/hooks/useSessionExpiry.ts
import { useEffect } from 'react';
import { useAuthStore } from '../store/authStore';

export function useSessionExpiry() {
  const { isTokenValid, logout } = useAuthStore();

  useEffect(() => {
    // Check token validity every minute
    const interval = setInterval(() => {
      if (!isTokenValid()) {
        logout();
        // Redirect to login or show modal
      }
    }, 60000);

    return () => clearInterval(interval);
  }, []);
}
```

---

## Common Pitfalls and Solutions

### Pitfall 1: Storing Tokens in localStorage

```typescript
// ❌ BAD: Storing tokens in localStorage without encryption
localStorage.setItem('token', accessToken);

// ✅ GOOD: Use secure storage with encryption
const secureStorage = {
  setItem: (key: string, value: string) => {
    // Encrypt before storing
    const encrypted = encrypt(value, encryptionKey);
    localStorage.setItem(key, encrypted);
  },
};
```

### Pitfall 2: Not Refreshing Token on API Error

```typescript
// ❌ BAD: No refresh on 401
const response = await fetch('/api/data');
if (response.status === 401) {
  // Just redirect to login
  router.push('/login');
}

// ✅ GOOD: Auto-refresh on 401
const response = await fetch('/api/data');
if (response.status === 401) {
  await refreshSession();
  const retry = await fetch('/api/data');
  // Process retry
}
```

### Pitfall 3: Inconsistent Auth State Across Tabs

```typescript
// ❌ BAD: Different tabs have different auth state

// ✅ GOOD: Sync across tabs
import { useAuthStore } from '../store/authStore';

// In the auth store
useAuthStore.subscribe((state) => {
  // Broadcast state changes to other tabs
  const bc = new BroadcastChannel('auth');
  bc.postMessage({ type: 'AUTH_CHANGE', state });
});

// In app initialization
const bc = new BroadcastChannel('auth');
bc.onmessage = (event) => {
  if (event.data.type === 'AUTH_CHANGE') {
    useAuthStore.setState(event.data.state);
  }
};
```

---

## Authentication Checklist

- [ ] JWT tokens stored securely (not localStorage for sensitive data)
- [ ] Token auto-refresh implemented
- [ ] API client intercepts 401 and refreshes
- [ ] Protected routes with role/permission checks
- [ ] Login page with error handling
- [ ] Logout clears both local and server state
- [ ] Session expiry detection
- [ ] Multi-tab sync (if applicable)
- [ ] CSRF protection (if using cookies)
- [ ] Rate limiting on login attempts
- [ ] Secure password handling
- [ ] HTTPS only in production

---

## Key Takeaways

1. **Secure token storage**: Use secure storage (Keychain, SecureStore) for sensitive tokens
2. **Auto-refresh**: Automatically refresh tokens before they expire
3. **Role-based access**: Implement RBAC with fine-grained permissions
4. **Protected routes**: Guard routes based on authentication and authorization
5. **API interceptors**: Handle token injection and refresh centrally
6. **Error handling**: Graceful error messages and fallback flows
7. **Session management**: Detect and handle session expiry
8. **Multi-tab sync**: Keep auth state consistent across tabs
9. **Security**: HTTPS, CSRF protection, rate limiting
10. **Testing**: Comprehensive testing of auth flows

---

## What's Next

You've built a robust authentication system. Next, you'll apply Zustand to build a shopping cart with offline support, optimistic updates, and inventory management.
