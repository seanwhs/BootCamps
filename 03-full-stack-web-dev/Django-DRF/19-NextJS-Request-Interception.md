# Part 19: Next.js Request Interception

## Building a Secure Request Interception Layer

Welcome to **Part 19** of the Django REST Framework & Next.js 16 masterclass. Now that we have authentication working across both server and client, it's time to build a robust request interception layer. This will handle token refresh, error handling, and request/response transformation automatically.

In this part, we'll:
- Implement request interception patterns in Next.js
- Build automatic token refresh with retry logic
- Create an API route proxy for server-side requests
- Implement CSRF protection
- Add security headers
- Build comprehensive error handling

Think of this as building the **security checkpoint** for all API traffic. Just as an airport has security screening for every passenger, your application needs to intercept and process every API request to ensure it's valid, authenticated, and properly handled.

---

## The Target

We'll build a complete request interception system:

```
frontend/
├── lib/
│   └── api/
│       ├── client.ts              # Enhanced API client with interceptors
│       ├── interceptors/
│       │   ├── auth-interceptor.ts # Authentication interceptor
│       │   ├── error-interceptor.ts # Error handling interceptor
│       │   └── csrf-interceptor.ts # CSRF protection interceptor
│       └── middleware.ts          # API middleware functions
├── app/
│   └── api/
│       └── proxy/
│           └── [...path]/
│               └── route.ts       # API proxy route
└── middleware.ts                  # Next.js middleware with request interception
```

---

## The Concept

### Request Interception Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                    Request Interception Flow                        │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  1. Client makes request                                           │
│     ↓                                                              │
│  2. Request passes through interceptors                           │
│     ├── Auth Interceptor: Adds token                              │
│     ├── CSRF Interceptor: Adds CSRF token                         │
│     └── Logger Interceptor: Logs request                          │
│     ↓                                                              │
│  3. Request sent to server                                        │
│     ↓                                                              │
│  4. Response received                                             │
│     ↓                                                              │
│  5. Response passes through interceptors                          │
│     ├── Error Interceptor: Handles 401/403                       │
│     ├── Refresh Interceptor: Refreshes token if needed           │
│     └── Logger Interceptor: Logs response                        │
│     ↓                                                              │
│  6. Response returned to client                                   │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### Interceptor Patterns

| Pattern | Purpose | Example |
|---------|---------|---------|
| **Auth Interceptor** | Add authentication tokens | Add Bearer token to headers |
| **Refresh Interceptor** | Handle token expiration | Refresh token on 401 |
| **Error Interceptor** | Transform errors | Convert API errors to UI errors |
| **CSRF Interceptor** | Add CSRF protection | Add CSRF token header |
| **Logger Interceptor** | Log requests/responses | Debug information |
| **Retry Interceptor** | Retry failed requests | Retry on network errors |

---

## The Implementation

### Step 1: Create Authentication Interceptor

**frontend/lib/api/interceptors/auth-interceptor.ts** (create)

```tsx
/**
 * Authentication interceptor for API requests
 */

import { getAccessToken, getRefreshToken, setTokens, clearTokens } from '@/lib/auth/token';

export interface InterceptorContext {
  request: RequestInit;
  url: string;
  retryCount: number;
}

/**
 * Add authentication headers to requests
 */
export function authInterceptor(context: InterceptorContext): InterceptorContext {
  const token = getAccessToken();
  
  if (token) {
    context.request.headers = {
      ...context.request.headers,
      'Authorization': `Bearer ${token}`,
    } as HeadersInit;
  }
  
  return context;
}

/**
 * Handle authentication errors
 */
export async function authErrorHandler(
  error: any,
  context: InterceptorContext
): Promise<InterceptorContext | null> {
  // If 401 Unauthorized and we haven't retried yet
  if (error.status === 401 && context.retryCount < 2) {
    try {
      const refreshToken = getRefreshToken();
      if (!refreshToken) {
        clearTokens();
        return null;
      }
      
      // Attempt to refresh the token
      const response = await fetch(`${process.env.NEXT_PUBLIC_API_URL}/token/refresh/`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ refresh: refreshToken }),
      });
      
      if (response.ok) {
        const data = await response.json();
        if (data.access) {
          // Update tokens
          setTokens(data.access, refreshToken);
          
          // Increment retry count and retry the request
          context.retryCount += 1;
          // Update the auth header
          context.request.headers = {
            ...context.request.headers,
            'Authorization': `Bearer ${data.access}`,
          } as HeadersInit;
          
          return context;
        }
      }
      
      // Refresh failed
      clearTokens();
      return null;
    } catch (refreshError) {
      clearTokens();
      return null;
    }
  }
  
  // If we've retried too many times or it's not an auth error
  return null;
}
```

### Step 2: Create CSRF Interceptor

**frontend/lib/api/interceptors/csrf-interceptor.ts** (create)

```tsx
/**
 * CSRF protection interceptor for API requests
 */

import { getCsrfToken } from '@/lib/auth/csrf';

/**
 * Add CSRF token to requests
 */
export function csrfInterceptor(context: InterceptorContext): InterceptorContext {
  // Only add CSRF token for modifying requests (POST, PUT, PATCH, DELETE)
  const method = context.request.method?.toUpperCase() || 'GET';
  
  if (['POST', 'PUT', 'PATCH', 'DELETE'].includes(method)) {
    const csrfToken = getCsrfToken();
    
    if (csrfToken) {
      context.request.headers = {
        ...context.request.headers,
        'X-CSRF-Token': csrfToken,
      } as HeadersInit;
    }
  }
  
  return context;
}
```

### Step 3: Create CSRF Token Utilities

**frontend/lib/auth/csrf.ts** (create)

```tsx
/**
 * CSRF token management utilities
 */

const CSRF_TOKEN_KEY = 'csrf_token';

/**
 * Get CSRF token from cookies or localStorage
 */
export function getCsrfToken(): string | null {
  // Try to get from cookie
  if (typeof document !== 'undefined') {
    const value = `; ${document.cookie}`;
    const parts = value.split(`; ${CSRF_TOKEN_KEY}=`);
    if (parts.length === 2) {
      return parts.pop()?.split(';').shift() || null;
    }
  }
  
  // Try to get from localStorage
  try {
    return localStorage.getItem(CSRF_TOKEN_KEY);
  } catch {
    return null;
  }
}

/**
 * Set CSRF token
 */
export function setCsrfToken(token: string) {
  if (typeof document !== 'undefined') {
    // Set cookie
    const expires = new Date();
    expires.setTime(expires.getTime() + 1 * 24 * 60 * 60 * 1000);
    document.cookie = `${CSRF_TOKEN_KEY}=${token};expires=${expires.toUTCString()};path=/;SameSite=Lax`;
  }
  
  try {
    localStorage.setItem(CSRF_TOKEN_KEY, token);
  } catch {
    // Ignore storage errors
  }
}

/**
 * Clear CSRF token
 */
export function clearCsrfToken() {
  if (typeof document !== 'undefined') {
    document.cookie = `${CSRF_TOKEN_KEY}=;expires=Thu, 01 Jan 1970 00:00:00 GMT;path=/`;
  }
  
  try {
    localStorage.removeItem(CSRF_TOKEN_KEY);
  } catch {
    // Ignore storage errors
  }
}
```

### Step 4: Create Error Interceptor

**frontend/lib/api/interceptors/error-interceptor.ts** (create)

```tsx
/**
 * Error handling interceptor for API requests
 */

import { ApiError, ApiResponse } from '../client';

export interface ErrorInterceptorOptions {
  onError?: (error: ApiError) => void;
  on401?: () => void;
  on403?: () => void;
  on404?: () => void;
  on500?: () => void;
}

/**
 * Handle API errors
 */
export function errorInterceptor(
  response: ApiResponse,
  options: ErrorInterceptorOptions = {}
): ApiResponse {
  if (response.error) {
    const status = response.status;
    
    switch (status) {
      case 401:
        options.on401?.();
        break;
      case 403:
        options.on403?.();
        break;
      case 404:
        options.on404?.();
        break;
      case 500:
        options.on500?.();
        break;
      default:
        break;
    }
    
    options.onError?.(response.error);
  }
  
  return response;
}
```

### Step 5: Create Enhanced API Client

**frontend/lib/api/client.ts** (update with interceptors)

```tsx
/**
 * Enhanced API client with request/response interceptors
 */

import { API_BASE_URL } from '@/lib/utils/constants';
import { authInterceptor, authErrorHandler } from './interceptors/auth-interceptor';
import { csrfInterceptor } from './interceptors/csrf-interceptor';
import { errorInterceptor } from './interceptors/error-interceptor';
import { getAccessToken } from '@/lib/auth/token';

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
 * Make an API request with interceptors
 */
export async function apiRequest<T = any>(
  endpoint: string,
  options: RequestInit = {},
  params?: Record<string, any>
): Promise<ApiResponse<T>> {
  const url = buildUrl(endpoint, params);
  
  // Initialize request context
  let context: InterceptorContext = {
    url,
    request: {
      ...options,
      headers: {
        'Content-Type': 'application/json',
        ...options.headers,
      },
    },
    retryCount: 0,
  };
  
  // Apply request interceptors
  context = authInterceptor(context);
  context = csrfInterceptor(context);
  
  try {
    let response = await fetch(context.url, context.request);
    let data;
    let status = response.status;
    
    // Parse response
    const contentType = response.headers.get('content-type');
    if (contentType && contentType.includes('application/json')) {
      data = await response.json();
    } else {
      data = await response.text();
    }
    
    // Handle response
    let apiResponse: ApiResponse<T> = {
      status,
      ...(response.ok ? { data: data as T } : { error: data as ApiError }),
    };
    
    // Check if we need to refresh token
    if (status === 401) {
      const retryContext = await authErrorHandler(
        { status, data },
        context
      );
      
      if (retryContext) {
        // Retry the request with new token
        const retryResponse = await fetch(retryContext.url, retryContext.request);
        const retryData = await retryResponse.json();
        
        apiResponse = {
          status: retryResponse.status,
          ...(retryResponse.ok 
            ? { data: retryData as T } 
            : { error: retryData as ApiError }
          ),
        };
      }
    }
    
    // Apply error interceptor
    if (apiResponse.error) {
      errorInterceptor(apiResponse);
    }
    
    return apiResponse;
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
 * GET request
 */
export async function get<T = any>(
  endpoint: string,
  params?: Record<string, any>
): Promise<ApiResponse<T>> {
  return apiRequest<T>(endpoint, { method: 'GET' }, params);
}

/**
 * POST request
 */
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

/**
 * PUT request
 */
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

/**
 * PATCH request
 */
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

/**
 * DELETE request
 */
export async function del<T = any>(
  endpoint: string,
  params?: Record<string, any>
): Promise<ApiResponse<T>> {
  return apiRequest<T>(endpoint, { method: 'DELETE' }, params);
}
```

### Step 6: Create API Proxy Route

**frontend/app/api/proxy/[...path]/route.ts** (create)

```tsx
/**
 * API proxy route for Next.js
 * This proxies requests to the Django backend
 */

import { NextRequest, NextResponse } from 'next/server';
import { getAccessToken } from '@/lib/auth/token';

const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000/api/v1';

export async function GET(
  request: NextRequest,
  { params }: { params: { path: string[] } }
) {
  return proxyRequest(request, params, 'GET');
}

export async function POST(
  request: NextRequest,
  { params }: { params: { path: string[] } }
) {
  return proxyRequest(request, params, 'POST');
}

export async function PUT(
  request: NextRequest,
  { params }: { params: { path: string[] } }
) {
  return proxyRequest(request, params, 'PUT');
}

export async function PATCH(
  request: NextRequest,
  { params }: { params: { path: string[] } }
) {
  return proxyRequest(request, params, 'PATCH');
}

export async function DELETE(
  request: NextRequest,
  { params }: { params: { path: string[] } }
) {
  return proxyRequest(request, params, 'DELETE');
}

async function proxyRequest(
  request: NextRequest,
  params: { path: string[] },
  method: string
) {
  try {
    // Build the target URL
    const path = params.path.join('/');
    const url = new URL(`${API_BASE_URL}/${path}`);
    
    // Copy query parameters
    request.nextUrl.searchParams.forEach((value, key) => {
      url.searchParams.append(key, value);
    });
    
    // Get the request body
    let body = null;
    if (request.body) {
      const reader = request.body.getReader();
      const { value } = await reader.read();
      if (value) {
        body = value;
      }
    }
    
    // Get token from cookies
    const token = request.cookies.get('access_token')?.value;
    
    // Build headers
    const headers: HeadersInit = {
      'Content-Type': 'application/json',
    };
    
    if (token) {
      headers['Authorization'] = `Bearer ${token}`;
    }
    
    // Forward the request
    const response = await fetch(url.toString(), {
      method,
      headers,
      body,
    });
    
    // Get the response data
    const data = await response.json();
    
    // Return the response
    return NextResponse.json(data, {
      status: response.status,
      headers: {
        'Cache-Control': 'no-store',
      },
    });
  } catch (error) {
    console.error('Proxy error:', error);
    return NextResponse.json(
      { detail: 'Proxy request failed' },
      { status: 500 }
    );
  }
}
```

### Step 7: Update Next.js Middleware

**frontend/middleware.ts** (update with request interception)

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
  
  // Get the token from cookies
  const token = request.cookies.get('access_token')?.value;
  
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
  
  // Add security headers
  const response = NextResponse.next();
  
  // Security headers
  response.headers.set('X-Content-Type-Options', 'nosniff');
  response.headers.set('X-Frame-Options', 'DENY');
  response.headers.set('X-XSS-Protection', '1; mode=block');
  response.headers.set('Referrer-Policy', 'strict-origin-when-cross-origin');
  
  // Content Security Policy (adjust as needed)
  response.headers.set(
    'Content-Security-Policy',
    "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval'; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:; font-src 'self' data:;"
  );
  
  return response;
}

export const config = {
  matcher: [
    '/((?!_next/static|_next/image|favicon.ico|public).*)',
  ],
};
```

### Step 8: Create Request Logger

**frontend/lib/api/interceptors/logger-interceptor.ts** (create)

```tsx
/**
 * Logger interceptor for debugging API requests
 */

const isDevelopment = process.env.NODE_ENV === 'development';

export interface LogContext {
  method?: string;
  url?: string;
  headers?: Record<string, string>;
  body?: any;
  response?: any;
  duration?: number;
}

/**
 * Log API requests and responses
 */
export function logRequest(context: LogContext) {
  if (!isDevelopment) return;
  
  console.group('🔵 API Request');
  console.log('Method:', context.method);
  console.log('URL:', context.url);
  console.log('Headers:', context.headers);
  if (context.body) {
    console.log('Body:', context.body);
  }
  console.groupEnd();
}

/**
 * Log API responses
 */
export function logResponse(context: LogContext) {
  if (!isDevelopment) return;
  
  console.group('🟢 API Response');
  console.log('URL:', context.url);
  console.log('Duration:', context.duration ? `${context.duration}ms` : 'N/A');
  if (context.response) {
    console.log('Response:', context.response);
  }
  console.groupEnd();
}

/**
 * Log API errors
 */
export function logError(context: LogContext & { error: any }) {
  if (!isDevelopment) return;
  
  console.group('🔴 API Error');
  console.log('URL:', context.url);
  console.log('Error:', context.error);
  if (context.response) {
    console.log('Response:', context.response);
  }
  console.groupEnd();
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

### Step 2: Test Authentication Interceptor

1. Login to the application
2. Open browser dev tools > Network tab
3. Make an API request
4. ✅ Should see Authorization header with Bearer token
5. ✅ Should include CSRF token for modifying requests

### Step 3: Test Token Refresh

1. Login and get a token
2. Wait for token to expire (or manually expire it in dev tools)
3. Make an API request
4. ✅ Should automatically refresh the token
5. ✅ Should retry the original request

### Step 4: Test Error Interceptor

1. Make an API request with an invalid endpoint
2. ✅ Should handle 404 error
3. Try to update a resource you don't own
4. ✅ Should handle 403 error

### Step 5: Test API Proxy

1. Make a request to `/api/proxy/tasks/`
2. ✅ Should proxy to Django backend
3. ✅ Should include authentication token from cookies

### Step 6: Test Security Headers

1. Open browser dev tools > Network tab
2. Check response headers
3. ✅ Should see security headers:
   - X-Content-Type-Options: nosniff
   - X-Frame-Options: DENY
   - X-XSS-Protection: 1; mode=block
   - Content-Security-Policy

---

## Key Takeaways

1. **Request interceptors** provide a clean way to handle authentication, CSRF, and errors.

2. **Token refresh** can be handled automatically in the interceptor.

3. **Error handling** is centralized in the API client.

4. **API proxy routes** allow server-side API calls with authentication.

5. **Security headers** protect against common web vulnerabilities.

6. **Logging interceptors** help with debugging in development.

---

## What's Next

In **Part 20**, we'll implement API security:

- Rate limiting
- CORS configuration
- Input validation
- Security best practices

---

**End of Part 19**

*Next: Part 20 - API Security*
