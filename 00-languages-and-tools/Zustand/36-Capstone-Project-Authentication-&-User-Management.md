# Capstone Project — Phase 2: Authentication & User Management

Now that the foundation is in place, it's time to implement the authentication system. Users need to sign up, log in, and access protected resources. In this phase, you'll build a complete authentication system with JWT tokens, protected routes, role-based access control, and user profile management.

---

## The Target: Complete Authentication System

By the end of this phase, you'll have:
- Login and registration pages with form validation
- JWT token management with automatic refresh
- Protected routes with role-based access control
- User profile management
- Session persistence across page reloads
- Logout functionality with cleanup
- Comprehensive tests for auth flows

---

## Implementation: Authentication System

### Step 1: Auth Service (API Client)

```typescript
// packages/shared/src/services/authApi.ts
import { User, AuthTokens, LoginCredentials, RegisterCredentials } from '../types';

// Mock API (replace with real API calls)
const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3001/api';

// Mock user data
let mockUsers: User[] = [
  {
    id: 'user-1',
    email: 'admin@taskflow.com',
    name: 'Admin User',
    role: 'admin',
    permissions: ['*'],
    preferences: {
      theme: 'system',
      language: 'en',
      timezone: 'UTC',
      notifications: { email: true, push: true, inApp: true },
    },
    createdAt: new Date(),
    updatedAt: new Date(),
  },
  {
    id: 'user-2',
    email: 'manager@taskflow.com',
    name: 'Manager User',
    role: 'manager',
    permissions: ['read:tasks', 'write:tasks', 'manage:users'],
    preferences: {
      theme: 'light',
      language: 'en',
      timezone: 'UTC',
      notifications: { email: true, push: true, inApp: true },
    },
    createdAt: new Date(),
    updatedAt: new Date(),
  },
  {
    id: 'user-3',
    email: 'user@taskflow.com',
    name: 'Regular User',
    role: 'user',
    permissions: ['read:tasks', 'write:tasks'],
    preferences: {
      theme: 'dark',
      language: 'en',
      timezone: 'UTC',
      notifications: { email: false, push: true, inApp: true },
    },
    createdAt: new Date(),
    updatedAt: new Date(),
  },
];

// Token storage (in memory for this mock)
let refreshTokens: Record<string, { token: string; userId: string }> = {};

export const authApi = {
  login: async (credentials: LoginCredentials): Promise<{ user: User; tokens: AuthTokens }> => {
    // Simulate network delay
    await new Promise(resolve => setTimeout(resolve, 800));

    // Find user
    const user = mockUsers.find(u => u.email === credentials.email);
    if (!user) {
      throw new Error('Invalid email or password');
    }

    // In production, verify password hash
    // For mock, accept any password with length >= 6
    if (credentials.password.length < 6) {
      throw new Error('Invalid email or password');
    }

    // Generate tokens
    const accessToken = `access_${Date.now()}_${user.id}`;
    const refreshToken = `refresh_${Date.now()}_${user.id}`;

    // Store refresh token
    refreshTokens[refreshToken] = { token: refreshToken, userId: user.id };

    return {
      user,
      tokens: {
        accessToken,
        refreshToken,
        expiresIn: 3600, // 1 hour
        tokenType: 'Bearer',
      },
    };
  },

  register: async (credentials: RegisterCredentials): Promise<{ user: User; tokens: AuthTokens }> => {
    await new Promise(resolve => setTimeout(resolve, 1000));

    // Check if user exists
    if (mockUsers.some(u => u.email === credentials.email)) {
      throw new Error('User already exists');
    }

    // Create new user
    const newUser: User = {
      id: `user-${Date.now()}`,
      email: credentials.email,
      name: credentials.name,
      role: 'user',
      permissions: ['read:tasks', 'write:tasks'],
      preferences: {
        theme: 'system',
        language: 'en',
        timezone: 'UTC',
        notifications: { email: true, push: true, inApp: true },
      },
      createdAt: new Date(),
      updatedAt: new Date(),
    };

    mockUsers.push(newUser);

    // Generate tokens
    const accessToken = `access_${Date.now()}_${newUser.id}`;
    const refreshToken = `refresh_${Date.now()}_${newUser.id}`;
    refreshTokens[refreshToken] = { token: refreshToken, userId: newUser.id };

    return {
      user: newUser,
      tokens: {
        accessToken,
        refreshToken,
        expiresIn: 3600,
        tokenType: 'Bearer',
      },
    };
  },

  refreshToken: async (refreshToken: string): Promise<AuthTokens> => {
    await new Promise(resolve => setTimeout(resolve, 500));

    const stored = refreshTokens[refreshToken];
    if (!stored) {
      throw new Error('Invalid refresh token');
    }

    const user = mockUsers.find(u => u.id === stored.userId);
    if (!user) {
      throw new Error('User not found');
    }

    const newAccessToken = `access_${Date.now()}_${user.id}`;
    const newRefreshToken = `refresh_${Date.now()}_${user.id}`;

    // Replace refresh token
    delete refreshTokens[refreshToken];
    refreshTokens[newRefreshToken] = { token: newRefreshToken, userId: user.id };

    return {
      accessToken: newAccessToken,
      refreshToken: newRefreshToken,
      expiresIn: 3600,
      tokenType: 'Bearer',
    };
  },

  logout: async (refreshToken: string): Promise<void> => {
    await new Promise(resolve => setTimeout(resolve, 300));
    delete refreshTokens[refreshToken];
  },

  getCurrentUser: async (accessToken: string): Promise<User> => {
    await new Promise(resolve => setTimeout(resolve, 400));

    // Extract user ID from token (mock)
    const userId = accessToken.split('_')[2];
    const user = mockUsers.find(u => u.id === userId);
    if (!user) {
      throw new Error('User not found');
    }
    return user;
  },

  updateUser: async (userId: string, updates: Partial<User>): Promise<User> => {
    await new Promise(resolve => setTimeout(resolve, 500));

    const user = mockUsers.find(u => u.id === userId);
    if (!user) {
      throw new Error('User not found');
    }

    Object.assign(user, updates, { updatedAt: new Date() });
    return user;
  },

  // Admin endpoints
  getUsers: async (): Promise<User[]> => {
    await new Promise(resolve => setTimeout(resolve, 600));
    return mockUsers;
  },

  deleteUser: async (userId: string): Promise<void> => {
    await new Promise(resolve => setTimeout(resolve, 500));
    mockUsers = mockUsers.filter(u => u.id !== userId);
  },
};
```

### Step 2: Enhanced Auth Store with Profile Management

```typescript
// packages/shared/src/store/auth/authStore.ts (extended)
import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';
import { immer } from 'zustand/middleware/immer';
import { AuthState, User, AuthTokens, LoginCredentials, RegisterCredentials } from '../../types';
import { authApi } from '../../services/authApi';
import { eventBus } from '../../events';

interface AuthStore extends AuthState {
  // Existing actions...
  login: (credentials: LoginCredentials) => Promise<void>;
  register: (credentials: RegisterCredentials) => Promise<void>;
  logout: () => Promise<void>;
  refreshSession: () => Promise<void>;
  updateUser: (updates: Partial<User>) => Promise<void>;
  updatePreferences: (updates: Partial<User['preferences']>) => Promise<void>;
  clearError: () => void;
  reset: () => void;
  
  // Helpers
  getAccessToken: () => string | null;
  getRefreshToken: () => string | null;
  hasRole: (role: User['role']) => boolean;
  hasPermission: (permission: string) => boolean;
  
  // Admin
  fetchUsers: () => Promise<User[]>;
  deleteUser: (userId: string) => Promise<void>;
}

const initialState: AuthState = {
  user: null,
  tokens: null,
  isAuthenticated: false,
  isLoading: false,
  error: null,
};

export const useAuthStore = create<AuthStore>()(
  persist(
    immer((set, get) => ({
      ...initialState,

      // ... existing actions (login, register, logout, refreshSession) ...

      // --- Enhanced update user with API call ---
      updateUser: async (updates: Partial<User>) => {
        const { user, tokens } = get();
        if (!user || !tokens) {
          throw new Error('Not authenticated');
        }

        set({ isLoading: true, error: null });

        try {
          const updatedUser = await authApi.updateUser(user.id, updates);
          set({ user: updatedUser, isLoading: false });
          return updatedUser;
        } catch (error) {
          set({
            isLoading: false,
            error: error instanceof Error ? error.message : 'Failed to update profile',
          });
          throw error;
        }
      },

      // --- Update preferences ---
      updatePreferences: async (updates: Partial<User['preferences']>) => {
        const { user } = get();
        if (!user) {
          throw new Error('Not authenticated');
        }

        const updatedPreferences = {
          ...user.preferences,
          ...updates,
        };

        await get().updateUser({ preferences: updatedPreferences });
      },

      // --- Admin: fetch all users ---
      fetchUsers: async () => {
        const { hasRole } = get();
        if (!hasRole('admin')) {
          throw new Error('Admin access required');
        }

        set({ isLoading: true, error: null });

        try {
          const users = await authApi.getUsers();
          set({ isLoading: false });
          return users;
        } catch (error) {
          set({
            isLoading: false,
            error: error instanceof Error ? error.message : 'Failed to fetch users',
          });
          throw error;
        }
      },

      // --- Admin: delete user ---
      deleteUser: async (userId: string) => {
        const { hasRole } = get();
        if (!hasRole('admin')) {
          throw new Error('Admin access required');
        }

        set({ isLoading: true, error: null });

        try {
          await authApi.deleteUser(userId);
          set({ isLoading: false });
          eventBus.publish('user:deleted', { userId });
        } catch (error) {
          set({
            isLoading: false,
            error: error instanceof Error ? error.message : 'Failed to delete user',
          });
          throw error;
        }
      },

      // ... rest of existing actions ...
    })),
    {
      name: 'auth-storage',
      storage: createJSONStorage(() => localStorage),
      partialize: (state) => ({
        user: state.user,
        tokens: state.tokens,
        isAuthenticated: state.isAuthenticated,
      }),
    }
  )
);
```

### Step 3: Login Page

```tsx
// apps/web/app/(auth)/login/page.tsx
'use client';

import React, { useState } from 'react';
import { useRouter } from 'next/navigation';
import Link from 'next/link';
import { useAuthStore, useUIStore } from '@taskflow/shared';

export default function LoginPage() {
  const router = useRouter();
  const { login, isLoading, error, clearError } = useAuthStore();
  const { addToast } = useUIStore();

  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [rememberMe, setRememberMe] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    clearError();

    try {
      await login({ email, password });
      addToast({
        type: 'success',
        message: 'Welcome back!',
        title: 'Login Successful',
      });
      router.push('/dashboard');
    } catch (error) {
      // Error is already set in the store
      addToast({
        type: 'error',
        message: error instanceof Error ? error.message : 'Login failed',
        title: 'Error',
      });
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-50 dark:bg-gray-900 py-12 px-4 sm:px-6 lg:px-8">
      <div className="max-w-md w-full space-y-8">
        <div>
          <h2 className="mt-6 text-center text-3xl font-extrabold text-gray-900 dark:text-white">
            Sign in to TaskFlow
          </h2>
          <p className="mt-2 text-center text-sm text-gray-600 dark:text-gray-400">
            Or{' '}
            <Link
              href="/register"
              className="font-medium text-indigo-600 hover:text-indigo-500 dark:text-indigo-400 dark:hover:text-indigo-300"
            >
              create a new account
            </Link>
          </p>
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
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                className="appearance-none rounded-none relative block w-full px-3 py-2 border border-gray-300 dark:border-gray-600 placeholder-gray-500 dark:placeholder-gray-400 text-gray-900 dark:text-white bg-white dark:bg-gray-800 rounded-t-md focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 focus:z-10 sm:text-sm"
                placeholder="Email address"
                disabled={isLoading}
              />
            </div>
            <div className="relative">
              <label htmlFor="password" className="sr-only">
                Password
              </label>
              <input
                id="password"
                name="password"
                type={showPassword ? 'text' : 'password'}
                autoComplete="current-password"
                required
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                className="appearance-none rounded-none relative block w-full px-3 py-2 border border-gray-300 dark:border-gray-600 placeholder-gray-500 dark:placeholder-gray-400 text-gray-900 dark:text-white bg-white dark:bg-gray-800 rounded-b-md focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 focus:z-10 sm:text-sm"
                placeholder="Password"
                disabled={isLoading}
              />
              <button
                type="button"
                onClick={() => setShowPassword(!showPassword)}
                className="absolute inset-y-0 right-0 pr-3 flex items-center text-sm text-gray-500 dark:text-gray-400"
              >
                {showPassword ? 'Hide' : 'Show'}
              </button>
            </div>
          </div>

          <div className="flex items-center justify-between">
            <div className="flex items-center">
              <input
                id="remember-me"
                name="remember-me"
                type="checkbox"
                checked={rememberMe}
                onChange={(e) => setRememberMe(e.target.checked)}
                className="h-4 w-4 text-indigo-600 focus:ring-indigo-500 border-gray-300 rounded"
              />
              <label htmlFor="remember-me" className="ml-2 block text-sm text-gray-900 dark:text-gray-300">
                Remember me
              </label>
            </div>

            <div className="text-sm">
              <Link
                href="/forgot-password"
                className="font-medium text-indigo-600 hover:text-indigo-500 dark:text-indigo-400 dark:hover:text-indigo-300"
              >
                Forgot your password?
              </Link>
            </div>
          </div>

          {error && (
            <div className="rounded-md bg-red-50 dark:bg-red-900/20 p-4">
              <div className="flex">
                <div className="flex-shrink-0">
                  <svg className="h-5 w-5 text-red-400" viewBox="0 0 20 20" fill="currentColor">
                    <path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clipRule="evenodd" />
                  </svg>
                </div>
                <div className="ml-3">
                  <h3 className="text-sm font-medium text-red-800 dark:text-red-200">Error</h3>
                  <div className="mt-2 text-sm text-red-700 dark:text-red-300">{error}</div>
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
              {isLoading ? (
                <span className="flex items-center">
                  <svg className="animate-spin -ml-1 mr-3 h-5 w-5 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                    <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4" />
                    <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z" />
                  </svg>
                  Signing in...
                </span>
              ) : (
                'Sign in'
              )}
            </button>
          </div>
        </form>

        <div className="mt-6">
          <div className="relative">
            <div className="absolute inset-0 flex items-center">
              <div className="w-full border-t border-gray-300 dark:border-gray-600" />
            </div>
            <div className="relative flex justify-center text-sm">
              <span className="px-2 bg-gray-50 dark:bg-gray-900 text-gray-500 dark:text-gray-400">
                Demo accounts
              </span>
            </div>
          </div>
          <div className="mt-4 grid grid-cols-1 gap-2">
            <button
              type="button"
              onClick={() => {
                setEmail('admin@taskflow.com');
                setPassword('admin123');
              }}
              className="text-sm text-gray-600 dark:text-gray-400 hover:text-gray-900 dark:hover:text-white"
            >
              Admin: admin@taskflow.com
            </button>
            <button
              type="button"
              onClick={() => {
                setEmail('manager@taskflow.com');
                setPassword('manager123');
              }}
              className="text-sm text-gray-600 dark:text-gray-400 hover:text-gray-900 dark:hover:text-white"
            >
              Manager: manager@taskflow.com
            </button>
            <button
              type="button"
              onClick={() => {
                setEmail('user@taskflow.com');
                setPassword('user123');
              }}
              className="text-sm text-gray-600 dark:text-gray-400 hover:text-gray-900 dark:hover:text-white"
            >
              User: user@taskflow.com
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
```

### Step 4: Registration Page

```tsx
// apps/web/app/(auth)/register/page.tsx
'use client';

import React, { useState } from 'react';
import { useRouter } from 'next/navigation';
import Link from 'next/link';
import { useAuthStore, useUIStore } from '@taskflow/shared';

export default function RegisterPage() {
  const router = useRouter();
  const { register, isLoading, error, clearError } = useAuthStore();
  const { addToast } = useUIStore();

  const [formData, setFormData] = useState({
    name: '',
    email: '',
    password: '',
    confirmPassword: '',
  });
  const [validationErrors, setValidationErrors] = useState<Record<string, string>>({});

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const { name, value } = e.target;
    setFormData((prev) => ({ ...prev, [name]: value }));
    // Clear validation error for this field
    setValidationErrors((prev) => ({ ...prev, [name]: '' }));
  };

  const validateForm = (): boolean => {
    const errors: Record<string, string> = {};

    if (!formData.name.trim()) {
      errors.name = 'Name is required';
    } else if (formData.name.length < 2) {
      errors.name = 'Name must be at least 2 characters';
    }

    if (!formData.email.trim()) {
      errors.email = 'Email is required';
    } else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(formData.email)) {
      errors.email = 'Invalid email format';
    }

    if (!formData.password) {
      errors.password = 'Password is required';
    } else if (formData.password.length < 8) {
      errors.password = 'Password must be at least 8 characters';
    } else if (!/[A-Z]/.test(formData.password)) {
      errors.password = 'Password must contain at least one uppercase letter';
    } else if (!/[a-z]/.test(formData.password)) {
      errors.password = 'Password must contain at least one lowercase letter';
    } else if (!/[0-9]/.test(formData.password)) {
      errors.password = 'Password must contain at least one number';
    }

    if (formData.password !== formData.confirmPassword) {
      errors.confirmPassword = 'Passwords do not match';
    }

    setValidationErrors(errors);
    return Object.keys(errors).length === 0;
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    clearError();

    if (!validateForm()) {
      return;
    }

    try {
      await register({
        email: formData.email,
        password: formData.password,
        name: formData.name,
      });
      addToast({
        type: 'success',
        message: 'Welcome to TaskFlow!',
        title: 'Registration Successful',
      });
      router.push('/dashboard');
    } catch (error) {
      addToast({
        type: 'error',
        message: error instanceof Error ? error.message : 'Registration failed',
        title: 'Error',
      });
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-50 dark:bg-gray-900 py-12 px-4 sm:px-6 lg:px-8">
      <div className="max-w-md w-full space-y-8">
        <div>
          <h2 className="mt-6 text-center text-3xl font-extrabold text-gray-900 dark:text-white">
            Create your account
          </h2>
          <p className="mt-2 text-center text-sm text-gray-600 dark:text-gray-400">
            Or{' '}
            <Link
              href="/login"
              className="font-medium text-indigo-600 hover:text-indigo-500 dark:text-indigo-400 dark:hover:text-indigo-300"
            >
              sign in to your existing account
            </Link>
          </p>
        </div>

        <form className="mt-8 space-y-6" onSubmit={handleSubmit}>
          <div className="rounded-md shadow-sm -space-y-px">
            <div>
              <label htmlFor="name" className="sr-only">
                Full name
              </label>
              <input
                id="name"
                name="name"
                type="text"
                autoComplete="name"
                required
                value={formData.name}
                onChange={handleChange}
                className={`appearance-none rounded-none relative block w-full px-3 py-2 border ${
                  validationErrors.name ? 'border-red-500' : 'border-gray-300 dark:border-gray-600'
                } placeholder-gray-500 dark:placeholder-gray-400 text-gray-900 dark:text-white bg-white dark:bg-gray-800 rounded-t-md focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 focus:z-10 sm:text-sm`}
                placeholder="Full name"
                disabled={isLoading}
              />
              {validationErrors.name && (
                <p className="mt-1 text-sm text-red-600 dark:text-red-400">{validationErrors.name}</p>
              )}
            </div>
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
                value={formData.email}
                onChange={handleChange}
                className={`appearance-none rounded-none relative block w-full px-3 py-2 border ${
                  validationErrors.email ? 'border-red-500' : 'border-gray-300 dark:border-gray-600'
                } placeholder-gray-500 dark:placeholder-gray-400 text-gray-900 dark:text-white bg-white dark:bg-gray-800 focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 focus:z-10 sm:text-sm`}
                placeholder="Email address"
                disabled={isLoading}
              />
              {validationErrors.email && (
                <p className="mt-1 text-sm text-red-600 dark:text-red-400">{validationErrors.email}</p>
              )}
            </div>
            <div>
              <label htmlFor="password" className="sr-only">
                Password
              </label>
              <input
                id="password"
                name="password"
                type="password"
                autoComplete="new-password"
                required
                value={formData.password}
                onChange={handleChange}
                className={`appearance-none rounded-none relative block w-full px-3 py-2 border ${
                  validationErrors.password ? 'border-red-500' : 'border-gray-300 dark:border-gray-600'
                } placeholder-gray-500 dark:placeholder-gray-400 text-gray-900 dark:text-white bg-white dark:bg-gray-800 focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 focus:z-10 sm:text-sm`}
                placeholder="Password"
                disabled={isLoading}
              />
              {validationErrors.password && (
                <p className="mt-1 text-sm text-red-600 dark:text-red-400">{validationErrors.password}</p>
              )}
            </div>
            <div>
              <label htmlFor="confirmPassword" className="sr-only">
                Confirm password
              </label>
              <input
                id="confirmPassword"
                name="confirmPassword"
                type="password"
                autoComplete="new-password"
                required
                value={formData.confirmPassword}
                onChange={handleChange}
                className={`appearance-none rounded-none relative block w-full px-3 py-2 border ${
                  validationErrors.confirmPassword ? 'border-red-500' : 'border-gray-300 dark:border-gray-600'
                } placeholder-gray-500 dark:placeholder-gray-400 text-gray-900 dark:text-white bg-white dark:bg-gray-800 rounded-b-md focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 focus:z-10 sm:text-sm`}
                placeholder="Confirm password"
                disabled={isLoading}
              />
              {validationErrors.confirmPassword && (
                <p className="mt-1 text-sm text-red-600 dark:text-red-400">{validationErrors.confirmPassword}</p>
              )}
            </div>
          </div>

          {error && (
            <div className="rounded-md bg-red-50 dark:bg-red-900/20 p-4">
              <p className="text-sm text-red-700 dark:text-red-300">{error}</p>
            </div>
          )}

          <div>
            <button
              type="submit"
              disabled={isLoading}
              className="group relative w-full flex justify-center py-2 px-4 border border-transparent text-sm font-medium rounded-md text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 disabled:opacity-50 disabled:cursor-not-allowed"
            >
              {isLoading ? (
                <span className="flex items-center">
                  <svg className="animate-spin -ml-1 mr-3 h-5 w-5 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                    <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4" />
                    <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z" />
                  </svg>
                  Creating account...
                </span>
              ) : (
                'Create account'
              )}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
```

### Step 5: Protected Route Component

```tsx
// packages/shared/src/components/ProtectedRoute.tsx
'use client';

import React, { ReactNode, useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { useAuthStore } from '../store';

export interface ProtectedRouteProps {
  children: ReactNode;
  requiredRoles?: Array<'admin' | 'manager' | 'user'>;
  requiredPermissions?: string[];
  fallback?: ReactNode;
  redirectTo?: string;
}

export function ProtectedRoute({
  children,
  requiredRoles = [],
  requiredPermissions = [],
  fallback = <div className="flex justify-center items-center h-64">Loading...</div>,
  redirectTo = '/login',
}: ProtectedRouteProps) {
  const router = useRouter();
  const { isAuthenticated, isLoading, user, hasRole, hasPermission } = useAuthStore();
  const [isAuthorized, setIsAuthorized] = useState(false);
  const [isChecking, setIsChecking] = useState(true);

  useEffect(() => {
    // If still loading, wait
    if (isLoading) {
      return;
    }

    // Check authentication
    if (!isAuthenticated) {
      router.push(redirectTo);
      setIsChecking(false);
      return;
    }

    // Check roles
    if (requiredRoles.length > 0) {
      const hasRequiredRole = requiredRoles.some(role => hasRole(role));
      if (!hasRequiredRole) {
        router.push('/unauthorized');
        setIsChecking(false);
        return;
      }
    }

    // Check permissions
    if (requiredPermissions.length > 0) {
      const hasAllPermissions = requiredPermissions.every(perm => hasPermission(perm));
      if (!hasAllPermissions) {
        router.push('/unauthorized');
        setIsChecking(false);
        return;
      }
    }

    // Authorized
    setIsAuthorized(true);
    setIsChecking(false);
  }, [isLoading, isAuthenticated, user, router, requiredRoles, requiredPermissions]);

  if (isLoading || isChecking) {
    return <>{fallback}</>;
  }

  if (!isAuthorized) {
    return null;
  }

  return <>{children}</>;
}
```

### Step 6: Dashboard Layout with Navigation

```tsx
// apps/web/app/(dashboard)/layout.tsx
'use client';

import React, { useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { useAuthStore, useUIStore } from '@taskflow/shared';
import { ProtectedRoute } from '@taskflow/shared/components/ProtectedRoute';
import { Sidebar } from '@/components/layout/Sidebar';
import { Header } from '@/components/layout/Header';

export default function DashboardLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const { isAuthenticated, isLoading } = useAuthStore();
  const { sidebarOpen } = useUIStore();

  // Redirect to login if not authenticated
  useEffect(() => {
    if (!isLoading && !isAuthenticated) {
      // Handled by ProtectedRoute
    }
  }, [isAuthenticated, isLoading]);

  return (
    <ProtectedRoute>
      <div className="min-h-screen bg-gray-50 dark:bg-gray-900">
        <Header />
        <div className="flex">
          <Sidebar />
          <main
            className={`flex-1 transition-all duration-300 ${
              sidebarOpen ? 'ml-64' : 'ml-20'
            } p-6`}
          >
            {children}
          </main>
        </div>
      </div>
    </ProtectedRoute>
  );
}
```

```tsx
// apps/web/components/layout/Header.tsx
'use client';

import React from 'react';
import { useRouter } from 'next/navigation';
import { useAuthStore, useUIStore } from '@taskflow/shared';
import { NotificationBell } from '@/components/notifications/NotificationBell';
import { UserMenu } from '@/components/user/UserMenu';

export function Header() {
  const router = useRouter();
  const { toggleSidebar, sidebarOpen, theme, setTheme } = useUIStore();
  const { user, logout } = useAuthStore();

  const handleLogout = async () => {
    await logout();
    router.push('/login');
  };

  return (
    <header className="bg-white dark:bg-gray-800 border-b border-gray-200 dark:border-gray-700 px-4 py-3">
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-4">
          <button
            onClick={toggleSidebar}
            className="p-2 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-700"
            aria-label="Toggle sidebar"
          >
            <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 6h16M4 12h16M4 18h16" />
            </svg>
          </button>
          <h1 className="text-xl font-semibold text-gray-900 dark:text-white">TaskFlow</h1>
        </div>

        <div className="flex items-center gap-4">
          <button
            onClick={() => setTheme(theme === 'dark' ? 'light' : 'dark')}
            className="p-2 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-700"
            aria-label="Toggle theme"
          >
            {theme === 'dark' ? '🌙' : '☀️'}
          </button>
          <NotificationBell />
          <UserMenu user={user} onLogout={handleLogout} />
        </div>
      </div>
    </header>
  );
}
```

### Step 7: User Menu Component

```tsx
// apps/web/components/user/UserMenu.tsx
'use client';

import React, { useState, useRef, useEffect } from 'react';
import Link from 'next/link';
import { User } from '@taskflow/shared';

interface UserMenuProps {
  user: User | null;
  onLogout: () => void;
}

export function UserMenu({ user, onLogout }: UserMenuProps) {
  const [isOpen, setIsOpen] = useState(false);
  const menuRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (menuRef.current && !menuRef.current.contains(event.target as Node)) {
        setIsOpen(false);
      }
    };
    document.addEventListener('click', handleClickOutside);
    return () => document.removeEventListener('click', handleClickOutside);
  }, []);

  if (!user) return null;

  return (
    <div className="relative" ref={menuRef}>
      <button
        onClick={() => setIsOpen(!isOpen)}
        className="flex items-center gap-2 p-2 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-700"
      >
        <div className="w-8 h-8 rounded-full bg-indigo-500 flex items-center justify-center text-white font-medium">
          {user.name.charAt(0).toUpperCase()}
        </div>
        <span className="hidden md:inline text-sm text-gray-700 dark:text-gray-300">
          {user.name}
        </span>
      </button>

      {isOpen && (
        <div className="absolute right-0 mt-2 w-48 bg-white dark:bg-gray-800 rounded-lg shadow-lg border border-gray-200 dark:border-gray-700 py-1 z-50">
          <div className="px-4 py-2 border-b border-gray-200 dark:border-gray-700">
            <p className="text-sm font-medium text-gray-900 dark:text-white">{user.name}</p>
            <p className="text-xs text-gray-500 dark:text-gray-400">{user.email}</p>
            <span className="inline-block mt-1 px-2 py-0.5 text-xs font-medium rounded bg-indigo-100 text-indigo-700 dark:bg-indigo-900/50 dark:text-indigo-300">
              {user.role}
            </span>
          </div>

          <Link
            href="/profile"
            className="block px-4 py-2 text-sm text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-700"
            onClick={() => setIsOpen(false)}
          >
            Profile
          </Link>
          <Link
            href="/settings"
            className="block px-4 py-2 text-sm text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-700"
            onClick={() => setIsOpen(false)}
          >
            Settings
          </Link>

          {user.role === 'admin' && (
            <Link
              href="/admin"
              className="block px-4 py-2 text-sm text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-700"
              onClick={() => setIsOpen(false)}
            >
              Admin Panel
            </Link>
          )}

          <div className="border-t border-gray-200 dark:border-gray-700 mt-1 pt-1">
            <button
              onClick={() => {
                setIsOpen(false);
                onLogout();
              }}
              className="block w-full text-left px-4 py-2 text-sm text-red-600 dark:text-red-400 hover:bg-gray-100 dark:hover:bg-gray-700"
            >
              Logout
            </button>
          </div>
        </div>
      )}
    </div>
  );
}
```

### Step 8: Auth Route Guard (Middleware)

```typescript
// apps/web/middleware.ts
import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';

// This middleware protects routes on the server side
export function middleware(request: NextRequest) {
  const { pathname } = request.nextUrl;

  // Public routes
  const publicRoutes = ['/', '/login', '/register', '/forgot-password', '/unauthorized'];
  const isPublicRoute = publicRoutes.includes(pathname);

  // Check for auth token in cookies
  const authToken = request.cookies.get('auth-storage');

  // If token exists and trying to access public route, redirect to dashboard
  if (authToken && (pathname === '/login' || pathname === '/register')) {
    return NextResponse.redirect(new URL('/dashboard', request.url));
  }

  // If no token and trying to access protected route, redirect to login
  if (!authToken && !isPublicRoute) {
    return NextResponse.redirect(new URL('/login', request.url));
  }

  return NextResponse.next();
}

export const config = {
  matcher: [
    /*
     * Match all request paths except for the ones starting with:
     * - api (API routes)
     * - _next/static (static files)
     * - _next/image (image optimization files)
     * - favicon.ico (favicon file)
     */
    '/((?!api|_next/static|_next/image|favicon.ico).*)',
  ],
};
```

---

## The Verification: Testing Authentication

### Step 1: Test Auth Flow Manually

1. Start the development server:
   ```bash
   cd apps/web
   pnpm dev
   ```

2. Navigate to `http://localhost:3000`
   - You should be redirected to login

3. Login with demo account:
   - Email: `user@taskflow.com`
   - Password: `user123`
   - You should be redirected to dashboard

4. Test registration:
   - Click "create a new account"
   - Fill in the form
   - You should be registered and redirected to dashboard

5. Test logout:
   - Click user menu → Logout
   - You should be redirected to login

6. Test protected routes:
   - Try accessing `/dashboard` while logged out
   - You should be redirected to login

### Step 2: Run Tests

```typescript
// packages/shared/src/store/__tests__/auth.integration.test.ts
import { describe, it, expect, beforeEach } from 'vitest';
import { useAuthStore } from '../auth/authStore';
import { authApi } from '../../services/authApi';

describe('Auth Store Integration', () => {
  beforeEach(() => {
    useAuthStore.setState({
      user: null,
      tokens: null,
      isAuthenticated: false,
      isLoading: false,
      error: null,
    });
  });

  it('should login successfully', async () => {
    const { login } = useAuthStore.getState();
    await login({
      email: 'user@taskflow.com',
      password: 'user123',
    });

    const state = useAuthStore.getState();
    expect(state.isAuthenticated).toBe(true);
    expect(state.user).not.toBe(null);
    expect(state.user?.email).toBe('user@taskflow.com');
    expect(state.tokens).not.toBe(null);
    expect(state.error).toBe(null);
  });

  it('should fail login with invalid credentials', async () => {
    const { login } = useAuthStore.getState();

    await expect(
      login({
        email: 'invalid@example.com',
        password: 'wrong',
      })
    ).rejects.toThrow();

    const state = useAuthStore.getState();
    expect(state.isAuthenticated).toBe(false);
    expect(state.user).toBe(null);
    expect(state.error).toBe('Invalid email or password');
  });

  it('should register a new user', async () => {
    const { register } = useAuthStore.getState();
    await register({
      email: 'newuser@example.com',
      password: 'Password123',
      name: 'New User',
    });

    const state = useAuthStore.getState();
    expect(state.isAuthenticated).toBe(true);
    expect(state.user?.email).toBe('newuser@example.com');
    expect(state.user?.name).toBe('New User');
  });

  it('should logout successfully', async () => {
    // First login
    const { login, logout } = useAuthStore.getState();
    await login({
      email: 'user@taskflow.com',
      password: 'user123',
    });

    expect(useAuthStore.getState().isAuthenticated).toBe(true);

    await logout();
    expect(useAuthStore.getState().isAuthenticated).toBe(false);
    expect(useAuthStore.getState().user).toBe(null);
    expect(useAuthStore.getState().tokens).toBe(null);
  });
});
```

### Step 3: Run Tests

```bash
pnpm test
```

Expected output:
```
✓ packages/shared/src/store/__tests__/auth.integration.test.ts (4)
✓ packages/shared/src/store/__tests__/auth.store.test.ts (6)

Test Files  2 passed (2)
     Tests  10 passed (10)
  Duration  3.12s
```

---

## What's Next

You've built a complete authentication system with login, registration, protected routes, and user management. Next, you'll implement the task management features with CRUD operations, optimistic updates, and filtering.
