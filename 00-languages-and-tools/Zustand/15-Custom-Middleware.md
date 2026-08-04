# Part 3 — Asynchronous State Management

## Section 15: Custom Middleware

You've used built-in middleware like `devtools`, `persist`, and `immer`. Now it's time to build your own. Custom middleware allows you to inject cross-cutting concerns into your state management—logging, validation, analytics, authentication, performance monitoring, and more. In this section, you'll learn how to create reusable, composable middleware that can be shared across multiple stores.

---

## The Target: Building Reusable Middleware

By the end of this section, you'll be able to:
- Understand the middleware signature and execution flow
- Build custom logging middleware with configurable options
- Create validation middleware for type safety and data integrity
- Implement analytics middleware for tracking user behavior
- Build authentication middleware for permission checking
- Create error reporting middleware for production monitoring
- Compose multiple custom middleware together

---

## The Concept: Middleware as a Plugin System

Think of middleware like **security checkpoints** in a building:

```
┌─────────────────────────────────────────────────────────────────┐
│                    MIDDLEWARE PIPELINE                         │
│                                                                 │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐    │
│  │  Logger      │    │  Validator   │    │  Analytics   │    │
│  │  Middleware  │───▶│  Middleware  │───▶│  Middleware  │    │
│  │              │    │              │    │              │    │
│  │  Logs every  │    │  Validates   │    │  Tracks      │    │
│  │  state change│    │  data shape  │    │  user actions│    │
│  └──────────────┘    └──────────────┘    └──────────────┘    │
│                                                                 │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐    │
│  │  Auth        │    │  Performance │    │  Error       │    │
│  │  Middleware  │───▶│  Middleware  │───▶│  Reporting   │    │
│  │              │    │              │    │              │    │
│  │  Checks user │    │  Measures    │    │  Reports     │    │
│  │  permissions │    │  update time │    │  errors      │    │
│  └──────────────┘    └──────────────┘    └──────────────┘    │
│                                                                 │
│                         │                                      │
│                         ▼                                      │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                    FINAL STATE                           │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

**Middleware Signature**:
```typescript
type Middleware<T> = (
  config: StateCreator<T, [], []>
) => StateCreator<T, [], []>;
```

Each middleware receives a `config` function and returns a new `config` function that wraps the original `set` and `get` functions.

---

## The Implementation: Custom Middleware

### Step 1: Understanding the Middleware Signature

Let's start with the simplest custom middleware to understand the pattern:

```typescript
// src/middleware/basicMiddleware.ts
import { StateCreator } from 'zustand';

// Type definition for middleware
export type Middleware<T> = (
  config: StateCreator<T, [], []>
) => StateCreator<T, [], []>;

// Simple middleware that logs every update
export const loggerMiddleware = <T extends object>(
  config: StateCreator<T, [], []>
): StateCreator<T, [], []> => {
  // Return a new config function
  return (set, get, store) => {
    // Wrap the original set function
    const wrappedSet = (args: any) => {
      const prevState = get();
      console.log('🔍 Before update:', prevState);
      
      // Call the original set
      set(args);
      
      const nextState = get();
      console.log('🔍 After update:', nextState);
      console.log('---');
    };
    
    // Return the store with wrapped set
    return config(wrappedSet, get, store);
  };
};
```

### Step 2: Configurable Logging Middleware

Build a more sophisticated logger with options:

```typescript
// src/middleware/advancedLogger.ts
import { StateCreator } from 'zustand';

interface LoggerOptions {
  enabled?: boolean;
  logActions?: boolean;
  logStateDiff?: boolean;
  logStateSnapshot?: boolean;
  logStackTraces?: boolean;
  collapsed?: boolean;
  prefix?: string;
  filter?: (action: string, state: any) => boolean;
}

export const createLogger = <T extends object>(
  options: LoggerOptions = {}
): Middleware<T> => {
  const {
    enabled = process.env.NODE_ENV === 'development',
    logActions = true,
    logStateDiff = true,
    logStateSnapshot = false,
    logStackTraces = false,
    collapsed = true,
    prefix = '📊',
    filter,
  } = options;

  return (config: StateCreator<T, [], []>): StateCreator<T, [], []> => {
    if (!enabled) {
      return config;
    }

    return (set, get, store) => {
      let actionCount = 0;
      const actionHistory: string[] = [];

      const wrappedSet = (args: any) => {
        const prevState = get();
        const actionName = typeof args === 'function' ? 'functional' : 'object';
        const shouldLog = filter ? filter(actionName, prevState) : true;
        
        if (!shouldLog) {
          set(args);
          return;
        }

        actionCount++;
        const startTime = performance.now();

        // Log before update
        if (logActions) {
          console.group(
            collapsed ? `${prefix} ${actionName} #${actionCount}` : undefined
          );
          if (!collapsed) {
            console.log(`${prefix} Action: ${actionName} #${actionCount}`);
          }
          actionHistory.push(actionName);
        }

        // Log state diff
        if (logStateDiff) {
          // Deep compare and show changes
          const changes = getDeepChanges(prevState, args);
          if (Object.keys(changes).length > 0) {
            console.log('📝 Changes:', changes);
          }
        }

        // Log stack trace
        if (logStackTraces) {
          console.trace('📍 Stack trace');
        }

        // Call original set
        set(args);

        const nextState = get();
        const duration = performance.now() - startTime;

        // Log state snapshot
        if (logStateSnapshot) {
          console.log('📸 State snapshot:', nextState);
        }

        console.log(`⏱️ Duration: ${duration.toFixed(2)}ms`);

        if (logActions) {
          console.groupEnd();
        }
      };

      return config(wrappedSet, get, store);
    };
  };
};

// Helper to find deep changes
function getDeepChanges(prev: any, args: any): Record<string, { from: any; to: any }> {
  const changes: Record<string, { from: any; to: any }> = {};
  
  // If args is a function, we can't easily diff
  if (typeof args === 'function') {
    return { note: 'Functional update - cannot diff' };
  }

  // If args is an object, compare keys
  if (typeof args === 'object' && args !== null) {
    const keys = new Set([...Object.keys(prev), ...Object.keys(args)]);
    for (const key of keys) {
      const prevVal = prev[key];
      const nextVal = args[key];
      if (JSON.stringify(prevVal) !== JSON.stringify(nextVal)) {
        changes[key] = { from: prevVal, to: nextVal };
      }
    }
  }

  return changes;
}
```

### Step 3: Validation Middleware

Validate state updates before they're applied:

```typescript
// src/middleware/validator.ts
import { StateCreator } from 'zustand';

export interface ValidationRule<T> {
  field: keyof T;
  validate: (value: any, state: T) => boolean;
  message: string;
  severity?: 'error' | 'warning' | 'info';
}

export const createValidator = <T extends object>(
  rules: ValidationRule<T>[],
  options: {
    onValidationError?: (errors: string[]) => void;
    strict?: boolean;
  } = {}
): Middleware<T> => {
  const { onValidationError, strict = true } = options;

  return (config: StateCreator<T, [], []>): StateCreator<T, [], []> => {
    return (set, get, store) => {
      const wrappedSet = (args: any) => {
        const currentState = get();
        
        // Compute next state
        const nextState = typeof args === 'function'
          ? args(currentState)
          : { ...currentState, ...args };

        // Run validation
        const errors: string[] = [];
        for (const rule of rules) {
          const value = nextState[rule.field];
          const isValid = rule.validate(value, nextState);
          if (!isValid) {
            errors.push(`${String(rule.field)}: ${rule.message}`);
          }
        }

        // Handle validation results
        if (errors.length > 0) {
          if (onValidationError) {
            onValidationError(errors);
          }
          
          if (strict) {
            console.error('❌ Validation errors:', errors);
            // Throw error to prevent state update
            throw new Error(`Validation failed: ${errors.join(', ')}`);
          } else {
            console.warn('⚠️ Validation warnings:', errors);
            // Still allow the update
          }
        }

        // Proceed with update
        set(args);
      };

      return config(wrappedSet, get, store);
    };
  };
};

// Example usage
const useValidatedStore = create(
  createValidator<UserStore>(
    [
      {
        field: 'age',
        validate: (value) => value >= 0 && value <= 150,
        message: 'Age must be between 0 and 150',
        severity: 'error',
      },
      {
        field: 'email',
        validate: (value) => /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value),
        message: 'Invalid email format',
        severity: 'error',
      },
    ],
    { strict: true }
  )((set) => ({
    age: 0,
    email: '',
    setAge: (age) => set({ age }),
    setEmail: (email) => set({ email }),
  }))
);
```

### Step 4: Analytics Middleware

Track user actions and state changes for analytics:

```typescript
// src/middleware/analytics.ts
import { StateCreator } from 'zustand';

interface AnalyticsEvent {
  event: string;
  properties: Record<string, any>;
  timestamp: number;
  userId?: string;
  sessionId?: string;
}

export interface AnalyticsProvider {
  track: (event: AnalyticsEvent) => void;
  identify: (userId: string, traits?: Record<string, any>) => void;
}

export const createAnalytics = <T extends object>(
  provider: AnalyticsProvider,
  options: {
    sampleRate?: number;
    excludeActions?: string[];
    includeStateSnapshot?: boolean;
    getUserId?: (state: T) => string | undefined;
    getSessionId?: () => string;
  } = {}
): Middleware<T> => {
  const {
    sampleRate = 1.0,
    excludeActions = [],
    includeStateSnapshot = false,
    getUserId,
    getSessionId = () => localStorage.getItem('sessionId') || `session-${Date.now()}`,
  } = options;

  let eventCount = 0;

  return (config: StateCreator<T, [], []>): StateCreator<T, [], []> => {
    return (set, get, store) => {
      const wrappedSet = (args: any) => {
        const actionName = typeof args === 'function' ? 'functional' : 'object';
        
        // Check if this action should be excluded
        if (excludeActions.includes(actionName)) {
          set(args);
          return;
        }

        // Sample
        if (Math.random() > sampleRate) {
          set(args);
          return;
        }

        const prevState = get();
        const startTime = performance.now();

        // Perform update
        set(args);

        const duration = performance.now() - startTime;
        const nextState = get();
        eventCount++;

        // Build analytics event
        const event: AnalyticsEvent = {
          event: actionName,
          properties: {
            eventCount,
            duration: Math.round(duration),
            prevStateSize: Object.keys(prevState).length,
            nextStateSize: Object.keys(nextState).length,
            ...(includeStateSnapshot ? { stateSnapshot: nextState } : {}),
          },
          timestamp: Date.now(),
        };

        // Add user info if available
        if (getUserId) {
          const userId = getUserId(nextState);
          if (userId) {
            event.userId = userId;
            provider.identify(userId);
          }
        }

        const sessionId = getSessionId();
        if (sessionId) {
          event.properties.sessionId = sessionId;
        }

        // Track event
        provider.track(event);
      };

      return config(wrappedSet, get, store);
    };
  };
};

// Example analytics provider (e.g., Mixpanel, Segment, PostHog)
export const mixpanelProvider: AnalyticsProvider = {
  track: (event) => {
    // @ts-ignore - assuming mixpanel is available
    if (window.mixpanel) {
      window.mixpanel.track(event.event, event.properties);
    } else {
      console.log('📊 Analytics:', event);
    }
  },
  identify: (userId, traits) => {
    // @ts-ignore
    if (window.mixpanel) {
      window.mixpanel.identify(userId);
      if (traits) {
        window.mixpanel.people.set(traits);
      }
    }
  },
};
```

### Step 5: Authentication & Authorization Middleware

Check permissions before allowing state updates:

```typescript
// src/middleware/auth.ts
import { StateCreator } from 'zustand';

interface AuthContext {
  user?: {
    id: string;
    role: string;
    permissions: string[];
  };
  isAuthenticated: boolean;
}

export interface PermissionRule<T> {
  action: string; // Matches the action name (or pattern)
  check: (state: T, context: AuthContext) => boolean;
  message?: string;
}

export const createAuthMiddleware = <T extends object>(
  getContext: () => AuthContext,
  rules: PermissionRule<T>[],
  options: {
    onUnauthorized?: (action: string, message: string) => void;
    strict?: boolean;
  } = {}
): Middleware<T> => {
  const {
    onUnauthorized = (action, message) => {
      console.warn(`🔒 Unauthorized action "${action}": ${message}`);
    },
    strict = true,
  } = options;

  return (config: StateCreator<T, [], []>): StateCreator<T, [], []> => {
    return (set, get, store) => {
      const wrappedSet = (args: any) => {
        const state = get();
        const context = getContext();
        const actionName = typeof args === 'function' ? 'functional' : 'object';

        // Check permissions
        for (const rule of rules) {
          // Simple pattern matching for action names
          const actionMatch = rule.action === actionName ||
                              (rule.action.endsWith('*') && 
                               actionName.startsWith(rule.action.slice(0, -1)));

          if (actionMatch) {
            const hasPermission = rule.check(state, context);
            if (!hasPermission) {
              const message = rule.message || `Permission denied for "${actionName}"`;
              onUnauthorized(actionName, message);
              if (strict) {
                throw new Error(`Unauthorized: ${message}`);
              }
              return;
            }
          }
        }

        // Proceed with update
        set(args);
      };

      return config(wrappedSet, get, store);
    };
  };
};

// Example usage
const useAuthStore = create(
  createAuthMiddleware<{ data: any[] }>(
    () => ({
      user: {
        id: 'user-1',
        role: 'admin',
        permissions: ['read:data', 'write:data', 'delete:data'],
      },
      isAuthenticated: true,
    }),
    [
      {
        action: 'write:*', // Matches write_*, write_data, etc.
        check: (state, context) => {
          return context.user?.permissions.includes('write:data') || false;
        },
        message: 'Write permission required',
      },
      {
        action: 'delete:*',
        check: (state, context) => {
          return context.user?.role === 'admin';
        },
        message: 'Admin role required to delete',
      },
    ],
    {
      onUnauthorized: (action, message) => {
        // Show toast notification or redirect
        console.log(`🔒 ${action}: ${message}`);
      },
      strict: true,
    }
  )((set) => ({
    data: [],
    write_data: (item: any) => set((state) => ({ data: [...state.data, item] })),
    delete_data: (id: string) => set((state) => ({
      data: state.data.filter(item => item.id !== id),
    })),
  }))
);
```

### Step 6: Performance Monitoring Middleware

Track performance metrics for state updates:

```typescript
// src/middleware/performance.ts
import { StateCreator } from 'zustand';

interface PerformanceMetric {
  action: string;
  duration: number;
  stateSize: number;
  timestamp: number;
  eventCount: number;
}

export const createPerformanceMonitor = <T extends object>(
  options: {
    threshold?: number; // Slow update threshold in ms
    sampleRate?: number;
    onMetric?: (metric: PerformanceMetric) => void;
    onSlowUpdate?: (metric: PerformanceMetric) => void;
    maxMetrics?: number;
  } = {}
): Middleware<T> => {
  const {
    threshold = 100,
    sampleRate = 1.0,
    onMetric,
    onSlowUpdate,
    maxMetrics = 1000,
  } = options;

  let metrics: PerformanceMetric[] = [];
  let eventCount = 0;

  return (config: StateCreator<T, [], []>): StateCreator<T, [], []> => {
    return (set, get, store) => {
      const wrappedSet = (args: any) => {
        const startTime = performance.now();
        const actionName = typeof args === 'function' ? 'functional' : 'object';
        
        // Perform update
        set(args);

        const duration = performance.now() - startTime;
        const state = get();
        const stateSize = new Blob([JSON.stringify(state)]).size;
        eventCount++;

        // Sample
        if (Math.random() > sampleRate) {
          return;
        }

        const metric: PerformanceMetric = {
          action: actionName,
          duration,
          stateSize,
          timestamp: Date.now(),
          eventCount,
        };

        // Store metrics
        metrics.push(metric);
        if (metrics.length > maxMetrics) {
          metrics = metrics.slice(-maxMetrics);
        }

        // Callbacks
        if (onMetric) {
          onMetric(metric);
        }

        if (duration > threshold && onSlowUpdate) {
          onSlowUpdate(metric);
          console.warn(`🐌 Slow update detected: ${duration.toFixed(2)}ms`, {
            action: actionName,
            stateSize: `${stateSize} bytes`,
          });
        }
      };

      return config(wrappedSet, get, store);
    };
  };
};

// Usage with metrics collection
const usePerformanceStore = create(
  createPerformanceMonitor({
    threshold: 50,
    sampleRate: 1.0,
    onSlowUpdate: (metric) => {
      // Send to performance monitoring service
      console.warn('Slow update:', metric);
    },
    onMetric: (metric) => {
      // Log to analytics
      console.log('Performance metric:', metric);
    },
  })((set) => ({
    data: [],
    addData: (item) => set((state) => ({ data: [...state.data, item] })),
  }))
);
```

### Step 7: Error Reporting Middleware

Catch and report errors in state updates:

```typescript
// src/middleware/errorReporter.ts
import { StateCreator } from 'zustand';

interface ErrorReport {
  action: string;
  error: string;
  stack?: string;
  state: any;
  timestamp: number;
}

export const createErrorReporter = <T extends object>(
  options: {
    reportError: (report: ErrorReport) => Promise<void> | void;
    onError?: (report: ErrorReport) => void;
    fallbackState?: Partial<T>;
    includeStack?: boolean;
  }
): Middleware<T> => {
  const {
    reportError,
    onError,
    fallbackState,
    includeStack = true,
  } = options;

  return (config: StateCreator<T, [], []>): StateCreator<T, [], []> => {
    return (set, get, store) => {
      const wrappedSet = (args: any) => {
        try {
          set(args);
        } catch (error) {
          const state = get();
          const actionName = typeof args === 'function' ? 'functional' : 'object';
          
          const report: ErrorReport = {
            action: actionName,
            error: error instanceof Error ? error.message : 'Unknown error',
            stack: includeStack && error instanceof Error ? error.stack : undefined,
            state,
            timestamp: Date.now(),
          };

          // Log error
          console.error('🔥 State update error:', error);
          console.error('📊 State at error:', state);

          // Call error handler
          if (onError) {
            onError(report);
          }

          // Report error
          try {
            reportError(report);
          } catch (reportError) {
            console.error('Failed to report error:', reportError);
          }

          // Apply fallback state if provided
          if (fallbackState) {
            set(fallbackState as any);
          }

          // Re-throw for component error boundaries
          throw error;
        }
      };

      return config(wrappedSet, get, store);
    };
  };
};

// Example with Sentry
import * as Sentry from '@sentry/react';

const useErrorStore = create(
  createErrorReporter({
    reportError: async (report) => {
      Sentry.captureException(new Error(report.error), {
        extra: {
          action: report.action,
          state: report.state,
          timestamp: report.timestamp,
        },
      });
    },
    onError: (report) => {
      console.error('🚨 Error report:', report);
      // Could show user-friendly toast notification
    },
    fallbackState: { data: [], loading: false, error: 'An error occurred' },
    includeStack: true,
  })((set) => ({
    data: [],
    loading: false,
    error: null,
    fetchData: async () => {
      // This might throw
    },
  }))
);
```

### Step 8: Composing Multiple Middleware

Chain middleware together for powerful combinations:

```typescript
// src/store/composedStore.ts
import { create } from 'zustand';
import { devtools, persist } from 'zustand/middleware';
import { createLogger } from '../middleware/advancedLogger';
import { createValidator } from '../middleware/validator';
import { createAnalytics, mixpanelProvider } from '../middleware/analytics';
import { createPerformanceMonitor } from '../middleware/performance';
import { createErrorReporter } from '../middleware/errorReporter';

interface AppStore {
  user: { name: string; email: string } | null;
  tasks: string[];
  age: number;
  setUser: (user: { name: string; email: string }) => void;
  addTask: (task: string) => void;
  setAge: (age: number) => void;
}

// Compose multiple middleware
export const useAppStore = create<AppStore>()(
  // Order matters: middleware wrap from inside out
  // The innermost middleware executes first on state changes
  
  // 1. Error Reporter (innermost - catches errors first)
  createErrorReporter({
    reportError: async (report) => {
      console.error('📡 Reporting error:', report);
      // Send to error tracking service
    },
    fallbackState: { user: null, tasks: [], age: 0 },
  })(
    // 2. Performance Monitor
    createPerformanceMonitor({
      threshold: 50,
      onSlowUpdate: (metric) => {
        console.warn('🐌 Slow update:', metric);
      },
    })(
      // 3. Analytics
      createAnalytics(mixpanelProvider, {
        sampleRate: 0.5,
        excludeActions: ['functional'],
        getUserId: (state) => state.user?.email,
      })(
        // 4. Validator
        createValidator<AppStore>(
          [
            {
              field: 'age',
              validate: (value) => value >= 0 && value <= 150,
              message: 'Age must be between 0 and 150',
            },
            {
              field: 'user',
              validate: (value) => {
                if (!value) return true;
                return value.email.includes('@');
              },
              message: 'Invalid email',
            },
          ],
          { strict: true }
        )(
          // 5. Logger
          createLogger({
            enabled: process.env.NODE_ENV === 'development',
            logActions: true,
            logStateDiff: true,
            collapsed: true,
          })(
            // 6. Persist (saves state)
            persist(
              // 7. DevTools (outermost)
              devtools(
                (set, get) => ({
                  user: null,
                  tasks: [],
                  age: 0,
                  setUser: (user) => set({ user }),
                  addTask: (task) => set((state) => ({
                    tasks: [...state.tasks, task],
                  })),
                  setAge: (age) => set({ age }),
                }),
                { name: 'App Store' }
              ),
              { name: 'app-storage' }
            )
          )
        )
      )
    )
  )
);
```

**Execution Order (Inside to Outside)**:
1. Error Reporter (catches errors first)
2. Performance Monitor (measures updates)
3. Analytics (tracks actions)
4. Validator (validates data)
5. Logger (logs state changes)
6. Persist (saves state)
7. DevTools (debugging)

---

## The Verification: Testing Custom Middleware

### Step 1: Create a Test Component

```tsx
// src/components/MiddlewareTest.tsx
import React, { useState } from 'react';
import { useAppStore } from '../store/composedStore';

function MiddlewareTest() {
  const { user, tasks, age, setUser, addTask, setAge } = useAppStore();
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [task, setTask] = useState('');

  return (
    <div style={{ padding: '20px' }}>
      <h1>Middleware Test</h1>
      
      <div>
        <h3>User</h3>
        <input value={name} onChange={(e) => setName(e.target.value)} placeholder="Name" />
        <input value={email} onChange={(e) => setEmail(e.target.value)} placeholder="Email" />
        <button onClick={() => setUser({ name, email })}>Set User</button>
        <pre>{JSON.stringify(user, null, 2)}</pre>
      </div>

      <div>
        <h3>Age (0-150)</h3>
        <input 
          type="number" 
          value={age} 
          onChange={(e) => setAge(parseInt(e.target.value) || 0)} 
        />
      </div>

      <div>
        <h3>Tasks</h3>
        <input value={task} onChange={(e) => setTask(e.target.value)} />
        <button onClick={() => addTask(task)}>Add Task</button>
        <ul>{tasks.map((t, i) => <li key={i}>{t}</li>)}</ul>
      </div>
    </div>
  );
}

export default MiddlewareTest;
```

### Step 2: Verify Logging

Open the browser console and interact with the app. You should see:
- Logger output: Action name, state changes, duration
- Performance warnings for slow updates
- Validation errors for invalid data
- Analytics logs (with sampling)

### Step 3: Test Validation

Try setting an invalid age (e.g., 200) or invalid email. The validator should:
- Log an error
- Prevent the state update (if strict mode is on)

### Step 4: Test Performance

Add many items quickly and check if performance monitoring catches slow updates.

### Step 5: Test Error Handling

Add code that throws an error in a state update and verify the error reporter catches it.

---

## Deep Dive: Middleware Composition

### Execution Order Diagram

```
┌─────────────────────────────────────────────────────────────┐
│  Action Called                                              │
│         │                                                   │
│         ▼                                                   │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  DevTools Middleware (outermost)                    │   │
│  │  ┌───────────────────────────────────────────────┐ │   │
│  │  │  Persist Middleware                           │ │   │
│  │  │  ┌─────────────────────────────────────────┐ │ │   │
│  │  │  │  Logger Middleware                     │ │ │   │
│  │  │  │  ┌───────────────────────────────────┐ │ │ │   │
│  │  │  │  │  Validator Middleware            │ │ │ │   │
│  │  │  │  │  ┌─────────────────────────────┐ │ │ │ │   │
│  │  │  │  │  │  Analytics Middleware       │ │ │ │ │   │
│  │  │  │  │  │  ┌───────────────────────┐ │ │ │ │ │   │
│  │  │  │  │  │  │  Performance Monitor  │ │ │ │ │ │   │
│  │  │  │  │  │  │  ┌─────────────────┐ │ │ │ │ │ │   │
│  │  │  │  │  │  │  │  Error Reporter │ │ │ │ │ │ │   │
│  │  │  │  │  │  │  │  (innermost)    │ │ │ │ │ │ │   │
│  │  │  │  │  │  │  └─────────────────┘ │ │ │ │ │ │   │
│  │  │  │  │  │  └───────────────────────┘ │ │ │ │ │   │
│  │  │  │  │  └─────────────────────────────┘ │ │ │ │   │
│  │  │  │  └───────────────────────────────────┘ │ │ │   │
│  │  │  └─────────────────────────────────────────┘ │ │   │
│  │  └───────────────────────────────────────────────┘ │   │
│  └─────────────────────────────────────────────────────┘   │
│         │                                                   │
│         ▼                                                   │
│  State Updated                                               │
└─────────────────────────────────────────────────────────────┘
```

### Writing Type-Safe Middleware

When writing middleware with TypeScript, ensure proper typing:

```typescript
import { StateCreator, StoreMutatorIdentifier } from 'zustand';

// For middleware that doesn't add new state properties
export type LoggerMiddleware = <
  T,
  Mps extends [StoreMutatorIdentifier, unknown][] = [],
  Mcs extends [StoreMutatorIdentifier, unknown][] = []
>(
  config: StateCreator<T, Mps, Mcs>
) => StateCreator<T, Mps, Mcs>;

// For middleware that adds new state or methods
export type PersistMiddleware = <
  T,
  Mps extends [StoreMutatorIdentifier, unknown][] = [],
  Mcs extends [StoreMutatorIdentifier, unknown][] = []
>(
  config: StateCreator<T, Mps, Mcs>,
  options: { name: string }
) => StateCreator<T, Mps, Mcs>;

// Usage in store with type inference
const useStore = create<MyStore>()(
  devtools(
    persist(
      (set) => ({ /* ... */ }),
      { name: 'store' }
    )
  )
);
```

---

## Common Pitfalls and Solutions

### Pitfall 1: Middleware Order Mistakes

```typescript
// ❌ WRONG: Error reporter should be innermost (wraps set)
const badStore = create(
  devtools(
    errorReporter(
      (set) => ({ /* ... */ })
    )
  )
);
// Errors in devtools won't be caught by errorReporter

// ✅ CORRECT: Error reporter wraps set directly
const goodStore = create(
  devtools(
    (set, get) => {
      const wrappedSet = errorHandlingWrapper(set);
      return config(wrappedSet, get);
    }
  )
);
```

### Pitfall 2: Not Handling Async Errors in Middleware

```typescript
// ❌ BAD: Async error not caught
createErrorReporter({
  reportError: async (report) => {
    await fetch('/api/errors', { method: 'POST', body: JSON.stringify(report) });
    // If this fails, error is silently swallowed
  },
})

// ✅ GOOD: Async error handler with try/catch
createErrorReporter({
  reportError: async (report) => {
    try {
      await fetch('/api/errors', { method: 'POST', body: JSON.stringify(report) });
    } catch (error) {
      console.error('Failed to report error:', error);
      // Store in local queue for retry
      localStorage.setItem('pendingErrors', JSON.stringify([report]));
    }
  },
})
```

### Pitfall 3: Performance Impact of Heavy Middleware

```typescript
// ❌ BAD: Heavy serialization in every update
createLogger({
  logStateSnapshot: true, // Serializes full state on every update
})

// ✅ GOOD: Only log diffs or sample
createLogger({
  logStateDiff: true, // Only logs changes
  logStateSnapshot: false, // Don't log full state
})
```

### Pitfall 4: Middleware Side Effects in Production

```typescript
// ❌ BAD: Analytics logging in production without sampling
createAnalytics(provider, { sampleRate: 1.0 })

// ✅ GOOD: Sample in production
createAnalytics(provider, { 
  sampleRate: process.env.NODE_ENV === 'production' ? 0.1 : 1.0 
})
```

---

## Production-Ready Middleware Example

```typescript
// src/middleware/productionMiddleware.ts
import { StateCreator } from 'zustand';
import { devtools } from 'zustand/middleware';
import { createLogger } from './advancedLogger';
import { createPerformanceMonitor } from './performance';
import { createErrorReporter } from './errorReporter';

export function withProductionMiddleware<T extends object>(
  config: StateCreator<T, [], []>,
  options: {
    storeName: string;
    enableDevtools?: boolean;
    errorReporting?: {
      reportError: (report: any) => Promise<void>;
      fallbackState?: Partial<T>;
    };
    performanceThreshold?: number;
    loggingEnabled?: boolean;
  }
) {
  const {
    storeName,
    enableDevtools = process.env.NODE_ENV === 'development',
    errorReporting,
    performanceThreshold = 100,
    loggingEnabled = process.env.NODE_ENV === 'development',
  } = options;

  // Build middleware chain
  let store = config;

  // Error Reporter (innermost)
  if (errorReporting) {
    store = createErrorReporter({
      reportError: errorReporting.reportError,
      fallbackState: errorReporting.fallbackState,
    })(store);
  }

  // Performance Monitor
  if (performanceThreshold > 0) {
    store = createPerformanceMonitor({
      threshold: performanceThreshold,
      onSlowUpdate: (metric) => {
        console.warn(`🐌 Slow update in ${storeName}:`, metric);
      },
    })(store);
  }

  // Logger
  if (loggingEnabled) {
    store = createLogger({
      enabled: true,
      logActions: true,
      logStateDiff: true,
      collapsed: true,
      prefix: `📊 [${storeName}]`,
    })(store);
  }

  // DevTools (outermost)
  if (enableDevtools) {
    store = devtools(store, { name: storeName });
  }

  return store;
}
```

---

## Key Takeaways

1. **Middleware wraps `set`**: Custom middleware can intercept and enhance state updates
2. **Order matters**: Inner middleware executes first; outer middleware wraps the entire store
3. **Create reusable middleware**: Build middleware once, use it across many stores
4. **Error handling**: Always catch errors in middleware to prevent breaking the app
5. **Performance**: Be mindful of the performance impact of your middleware
6. **Type safety**: Use TypeScript generics for type-safe middleware
7. **Configuration**: Make middleware configurable with options
8. **Testing**: Test middleware thoroughly with unit and integration tests
9. **Production vs Development**: Enable logging and devtools only in development
10. **Composition**: Combine middleware for powerful, modular functionality

---

## What's Next

You've mastered custom middleware! In Part 4, you'll dive deep into performance optimization—learning how to fine-tune Zustand for maximum speed and efficiency.
