# Part 8 — Enterprise Best Practices

## Section 31: Error Boundaries and Logging Strategies

In production, errors are inevitable. Network failures, unexpected data shapes, user mistakes, and edge cases will occur. How you handle these errors—and how you log them—determines the reliability and maintainability of your application. In this section, you'll learn how to implement robust error boundaries, centralized logging, and monitoring strategies for Zustand applications.

---

## The Target: Resilient, Observable Applications

By the end of this section, you'll be able to:
- Implement error boundaries that catch Zustand store errors
- Build a centralized logging system for state updates and errors
- Integrate with external logging services (Sentry, Datadog, LogRocket)
- Handle errors gracefully with user-friendly fallbacks
- Implement performance and error monitoring
- Create a structured logging pipeline for debugging production issues

---

## The Concept: Error Handling as a Safety Net

Think of error handling like **airbags in a car**:

```
┌─────────────────────────────────────────────────────────────────┐
│                    ERROR HANDLING & LOGGING                    │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Error Boundaries (Airbags)                             │  │
│  │  • Catch errors in store updates                        │  │
│  │  • Prevent app crashes                                  │  │
│  │  • Show fallback UI                                     │  │
│  └──────────────────────────────────────────────────────────┘  │
│                         │                                      │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Logging System (Black Box)                             │  │
│  │  • Record all state changes                             │  │
│  │  • Capture error context                                │  │
│  │  • Send to monitoring services                          │  │
│  └──────────────────────────────────────────────────────────┘  │
│                         │                                      │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Monitoring (Dashboard)                                 │  │
│  │  • Track error rates                                     │  │
│  │  • Performance metrics                                   │  │
│  │  • User impact analysis                                 │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

---

## The Implementation: Error Handling & Logging

### Step 1: Error Boundary Middleware

Create middleware that catches errors in store updates:

```typescript
// src/shared/store/middleware/errorBoundary.ts
import { StateCreator } from 'zustand';

export interface ErrorBoundaryOptions<T> {
  onError?: (error: Error, state: T, action: string) => void;
  fallbackState?: Partial<T>;
  rethrow?: boolean;
  reportError?: (error: Error, context: any) => void;
}

export const createErrorBoundary = <T extends object>(
  options: ErrorBoundaryOptions<T> = {}
): ((config: StateCreator<T, [], []>) => StateCreator<T, [], []>) => {
  const {
    onError,
    fallbackState,
    rethrow = false,
    reportError,
  } = options;

  return (config: StateCreator<T, [], []>) => (set, get, store) => {
    const wrappedSet = (args: any) => {
      try {
        set(args);
      } catch (error) {
        const currentState = get();
        const actionName = typeof args === 'function' ? 'functional update' : 'object update';
        const errorObj = error instanceof Error ? error : new Error(String(error));

        // Create error context
        const context = {
          action: actionName,
          state: currentState,
          args,
          timestamp: new Date().toISOString(),
          storeName: store?.toString?.() || 'unknown',
        };

        // Log error
        console.error('❌ Store update error:', errorObj);
        console.error('📊 State:', currentState);
        console.error('🎯 Action:', actionName);

        // Call onError callback
        if (onError) {
          onError(errorObj, currentState, actionName);
        }

        // Report to external service
        if (reportError) {
          reportError(errorObj, context);
        }

        // Apply fallback state if provided
        if (fallbackState) {
          set(fallbackState as any);
        }

        // Optionally rethrow to let React Error Boundaries catch it
        if (rethrow) {
          throw errorObj;
        }
      }
    };

    return config(wrappedSet, get, store);
  };
};
```

### Step 2: Comprehensive Logging Middleware

```typescript
// src/shared/store/middleware/logger.ts
import { StateCreator } from 'zustand';

export interface LogLevel {
  level: 'debug' | 'info' | 'warn' | 'error' | 'fatal';
}

export interface LoggerOptions<T> {
  enabled?: boolean;
  logLevel?: LogLevel['level'];
  logActions?: boolean;
  logStateDiff?: boolean;
  logStateSnapshot?: boolean;
  logPerformance?: boolean;
  prefix?: string;
  filter?: (action: string, state: T) => boolean;
  onLog?: (logEntry: LogEntry<T>) => void;
  remoteLogging?: (entry: LogEntry<T>) => Promise<void>;
  sampleRate?: number;
}

export interface LogEntry<T> {
  level: LogLevel['level'];
  action: string;
  prevState: T;
  nextState: T;
  diff: Record<string, { from: any; to: any }>;
  duration: number;
  timestamp: number;
  sessionId?: string;
  userId?: string;
  metadata?: Record<string, any>;
}

// Simple diff function
function getDiff(prev: any, next: any): Record<string, { from: any; to: any }> {
  const diff: Record<string, { from: any; to: any }> = {};
  const allKeys = new Set([...Object.keys(prev), ...Object.keys(next)]);

  for (const key of allKeys) {
    const prevVal = prev[key];
    const nextVal = next[key];
    if (JSON.stringify(prevVal) !== JSON.stringify(nextVal)) {
      diff[key] = { from: prevVal, to: nextVal };
    }
  }

  return diff;
}

export const createLogger = <T extends object>(
  options: LoggerOptions<T> = {}
): ((config: StateCreator<T, [], []>) => StateCreator<T, [], []>) => {
  const {
    enabled = process.env.NODE_ENV === 'development',
    logLevel = 'info',
    logActions = true,
    logStateDiff = true,
    logStateSnapshot = false,
    logPerformance = true,
    prefix = '📊',
    filter,
    onLog,
    remoteLogging,
    sampleRate = 1.0,
  } = options;

  let actionCount = 0;
  let sessionId = typeof window !== 'undefined' 
    ? localStorage.getItem('sessionId') || `session-${Date.now()}`
    : 'server-session';

  return (config: StateCreator<T, [], []>) => (set, get, store) => {
    if (!enabled) {
      return config(set, get, store);
    }

    const wrappedSet = (args: any) => {
      const shouldLog = filter ? filter('setState', get()) : true;
      if (!shouldLog || Math.random() > sampleRate) {
        set(args);
        return;
      }

      const prevState = get();
      const startTime = performance.now();
      const actionName = typeof args === 'function' ? 'functional' : 'object';

      // Perform update
      set(args);

      const duration = performance.now() - startTime;
      const nextState = get();
      actionCount++;

      // Build diff
      const diff = logStateDiff ? getDiff(prevState, nextState) : {};

      // Build log entry
      const entry: LogEntry<T> = {
        level: logLevel,
        action: actionName,
        prevState,
        nextState,
        diff,
        duration,
        timestamp: Date.now(),
        sessionId,
        userId: (nextState as any).user?.id || 'anonymous',
        metadata: {
          actionCount,
          stateSize: new Blob([JSON.stringify(nextState)]).size,
          store: store?.toString?.() || 'unknown',
        },
      };

      // Console logging
      if (logActions) {
        const groupName = `${prefix} ${actionName} #${actionCount} (${duration.toFixed(2)}ms)`;
        if (logLevel === 'debug') {
          console.groupCollapsed(groupName);
        } else {
          console.group(groupName);
        }

        console.log('📝 Action:', actionName);
        if (logStateDiff && Object.keys(diff).length > 0) {
          console.log('🔄 Changes:', diff);
        }
        if (logStateSnapshot) {
          console.log('📸 Next state:', nextState);
        }
        if (logPerformance) {
          console.log(`⏱️ Duration: ${duration.toFixed(2)}ms`);
        }
        console.groupEnd();
      }

      // Custom onLog callback
      if (onLog) {
        onLog(entry);
      }

      // Remote logging (async, don't block)
      if (remoteLogging) {
        remoteLogging(entry).catch(err => {
          console.error('Failed to send remote log:', err);
        });
      }
    };

    return config(wrappedSet, get, store);
  };
};
```

### Step 3: Sentry Integration

```typescript
// src/infrastructure/logging/sentry.ts
import * as Sentry from '@sentry/react';
import { BrowserTracing } from '@sentry/tracing';
import { LogEntry } from '../../shared/store/middleware/logger';

// Initialize Sentry
export function initSentry() {
  Sentry.init({
    dsn: process.env.NEXT_PUBLIC_SENTRY_DSN,
    environment: process.env.NODE_ENV,
    integrations: [new BrowserTracing()],
    tracesSampleRate: 0.1,
    beforeSend(event) {
      // Filter sensitive data
      if (event.request?.headers) {
        delete event.request.headers['Authorization'];
      }
      return event;
    },
  });
}

// Report error to Sentry
export function reportErrorToSentry(error: Error, context: any) {
  Sentry.captureException(error, {
    extra: {
      action: context.action,
      state: context.state,
      timestamp: context.timestamp,
      args: context.args,
    },
    tags: {
      store: context.storeName || 'unknown',
    },
  });
}

// Report log entry to Sentry as breadcrumb
export function logToSentry(entry: LogEntry<any>) {
  Sentry.addBreadcrumb({
    category: 'store',
    message: `Action: ${entry.action}`,
    data: {
      diff: entry.diff,
      duration: entry.duration,
      stateSize: entry.metadata?.stateSize,
    },
    level: entry.level,
    timestamp: entry.timestamp / 1000,
  });
}
```

### Step 4: Centralized Logging Service

```typescript
// src/infrastructure/logging/logger.ts
import { LogEntry } from '../../shared/store/middleware/logger';

export interface LoggerService {
  log(entry: LogEntry<any>): void;
  error(error: Error, context?: Record<string, any>): void;
  warn(message: string, data?: any): void;
  info(message: string, data?: any): void;
  debug(message: string, data?: any): void;
}

export class CentralizedLogger implements LoggerService {
  private remoteEndpoint?: string;
  private buffer: LogEntry<any>[] = [];
  private flushInterval: number = 5000; // 5 seconds
  private flushTimer: NodeJS.Timeout | null = null;
  private enabled: boolean = true;

  constructor(options: { remoteEndpoint?: string; enabled?: boolean } = {}) {
    this.remoteEndpoint = options.remoteEndpoint;
    this.enabled = options.enabled ?? process.env.NODE_ENV === 'production';

    if (this.remoteEndpoint && this.enabled) {
      this.flushTimer = setInterval(() => this.flush(), this.flushInterval);
    }
  }

  log(entry: LogEntry<any>): void {
    if (!this.enabled) return;

    // Add timestamp if not present
    if (!entry.timestamp) {
      entry.timestamp = Date.now();
    }

    // Add session ID
    if (typeof window !== 'undefined') {
      const sessionId = localStorage.getItem('sessionId');
      if (sessionId && !entry.sessionId) {
        entry.sessionId = sessionId;
      }
    }

    // Console output for development
    if (process.env.NODE_ENV === 'development') {
      console.log(`📋 [${entry.level}] ${entry.action}`, {
        diff: entry.diff,
        duration: entry.duration,
        stateSize: entry.metadata?.stateSize,
      });
    }

    // Add to buffer for remote logging
    if (this.remoteEndpoint && this.enabled) {
      this.buffer.push(entry);
      
      // Flush if buffer is large
      if (this.buffer.length >= 50) {
        this.flush();
      }
    }
  }

  error(error: Error, context?: Record<string, any>): void {
    if (!this.enabled) return;

    const logEntry: LogEntry<any> = {
      level: 'fatal',
      action: 'error',
      prevState: {},
      nextState: {},
      diff: {},
      duration: 0,
      timestamp: Date.now(),
      metadata: {
        error: error.message,
        stack: error.stack,
        ...context,
      },
    };

    this.log(logEntry);
  }

  warn(message: string, data?: any): void {
    if (!this.enabled) return;
    console.warn(`⚠️ ${message}`, data);
  }

  info(message: string, data?: any): void {
    if (!this.enabled) return;
    console.info(`ℹ️ ${message}`, data);
  }

  debug(message: string, data?: any): void {
    if (!this.enabled) return;
    console.debug(`🔍 ${message}`, data);
  }

  private async flush(): Promise<void> {
    if (this.buffer.length === 0 || !this.remoteEndpoint) return;

    const batch = [...this.buffer];
    this.buffer = [];

    try {
      await fetch(this.remoteEndpoint, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          logs: batch,
          timestamp: Date.now(),
          environment: process.env.NODE_ENV,
        }),
      });
    } catch (error) {
      console.error('Failed to flush logs:', error);
      // Put them back in the buffer
      this.buffer = [...batch, ...this.buffer];
    }
  }

  destroy(): void {
    if (this.flushTimer) {
      clearInterval(this.flushTimer);
      this.flushTimer = null;
    }
    // Flush remaining logs
    this.flush();
  }
}

// Singleton instance
export const logger = new CentralizedLogger({
  remoteEndpoint: process.env.NEXT_PUBLIC_LOG_ENDPOINT,
  enabled: process.env.NODE_ENV === 'production',
});
```

### Step 5: React Error Boundary for Store Errors

```tsx
// src/shared/components/StoreErrorBoundary.tsx
'use client';

import React, { Component, ErrorInfo, ReactNode } from 'react';
import { logger } from '../../infrastructure/logging/logger';

interface StoreErrorBoundaryProps {
  children: ReactNode;
  fallback?: ReactNode;
  onError?: (error: Error, errorInfo: ErrorInfo) => void;
}

interface StoreErrorBoundaryState {
  hasError: boolean;
  error: Error | null;
  errorInfo: ErrorInfo | null;
}

export class StoreErrorBoundary extends Component<StoreErrorBoundaryProps, StoreErrorBoundaryState> {
  constructor(props: StoreErrorBoundaryProps) {
    super(props);
    this.state = {
      hasError: false,
      error: null,
      errorInfo: null,
    };
  }

  static getDerivedStateFromError(error: Error): Partial<StoreErrorBoundaryState> {
    return { hasError: true, error };
  }

  componentDidCatch(error: Error, errorInfo: ErrorInfo): void {
    this.setState({ errorInfo });
    
    // Log error
    logger.error(error, {
      component: 'StoreErrorBoundary',
      errorInfo: errorInfo.componentStack,
    });

    // Call custom handler
    if (this.props.onError) {
      this.props.onError(error, errorInfo);
    }
  }

  resetError = (): void => {
    this.setState({
      hasError: false,
      error: null,
      errorInfo: null,
    });
  };

  render(): ReactNode {
    if (this.state.hasError) {
      if (this.props.fallback) {
        return this.props.fallback;
      }

      return (
        <div className="error-boundary p-4 bg-red-50 border border-red-200 rounded-lg">
          <h2 className="text-red-700 font-semibold text-lg mb-2">
            Something went wrong
          </h2>
          <p className="text-red-600 text-sm mb-4">
            We've logged this error and our team will investigate.
          </p>
          {process.env.NODE_ENV === 'development' && (
            <details className="mt-2 p-2 bg-red-100 rounded text-xs text-red-800">
              <summary className="cursor-pointer font-medium">Error details</summary>
              <pre className="mt-2 whitespace-pre-wrap overflow-auto max-h-40">
                {this.state.error?.stack || this.state.error?.message}
              </pre>
              <pre className="mt-2 whitespace-pre-wrap overflow-auto max-h-40 text-gray-700">
                {this.state.errorInfo?.componentStack}
              </pre>
            </details>
          )}
          <button
            onClick={this.resetError}
            className="mt-4 px-4 py-2 bg-red-600 text-white rounded hover:bg-red-700"
          >
            Try Again
          </button>
        </div>
      );
    }

    return this.props.children;
  }
}
```

### Step 6: Integrating Error Boundary with Stores

```tsx
// src/shared/store/middleware/errorBoundaryWithUI.ts
import { createErrorBoundary } from './errorBoundary';
import { logger } from '../../../infrastructure/logging/logger';

// Create error boundary with logging
export const withErrorBoundary = <T extends object>(
  config: StateCreator<T, [], []>,
  options: {
    fallbackState?: Partial<T>;
    reportError?: boolean;
  } = {}
) => {
  const { fallbackState, reportError = true } = options;

  return createErrorBoundary<T>({
    fallbackState,
    onError: (error, state, action) => {
      console.error(`❌ Error in action "${action}":`, error);
      // Could update UI state to show error
    },
    reportError: (error, context) => {
      if (reportError) {
        logger.error(error, {
          store: 'taskStore',
          action: context.action,
          state: context.state,
          timestamp: context.timestamp,
        });
      }
    },
    rethrow: false, // Don't rethrow, handle gracefully
  })(config);
};

// Usage in store creation
import { withErrorBoundary } from '../../shared/store/middleware/errorBoundaryWithUI';

export const useTaskStore = create(
  withErrorBoundary(
    (set, get) => ({
      // ... store implementation
    }),
    {
      fallbackState: {
        tasks: {},
        taskIds: [],
        error: 'An unexpected error occurred. Please try again.',
      },
      reportError: true,
    }
  )
);
```

### Step 7: Performance Monitoring Middleware

```typescript
// src/shared/store/middleware/performanceMonitor.ts
import { StateCreator } from 'zustand';
import { logger } from '../../../infrastructure/logging/logger';

interface PerformanceMetric {
  action: string;
  duration: number;
  stateSize: number;
  timestamp: number;
}

export const createPerformanceMonitor = <T extends object>(
  options: {
    threshold?: number;
    sampleRate?: number;
    onSlowUpdate?: (metric: PerformanceMetric) => void;
    onMetric?: (metric: PerformanceMetric) => void;
  } = {}
): ((config: StateCreator<T, [], []>) => StateCreator<T, [], []>) => {
  const {
    threshold = 50,
    sampleRate = 0.1,
    onSlowUpdate,
    onMetric,
  } = options;

  return (config: StateCreator<T, [], []>) => (set, get, store) => {
    const wrappedSet = (args: any) => {
      const startTime = performance.now();
      const actionName = typeof args === 'function' ? 'functional' : 'object';
      
      // Perform update
      set(args);

      const duration = performance.now() - startTime;
      const state = get();
      const stateSize = new Blob([JSON.stringify(state)]).size;

      // Only sample some updates
      if (Math.random() > sampleRate) {
        return;
      }

      const metric: PerformanceMetric = {
        action: actionName,
        duration,
        stateSize,
        timestamp: Date.now(),
      };

      // Check for slow updates
      if (duration > threshold) {
        const warning = `🐌 Slow update: ${duration.toFixed(2)}ms (${actionName})`;
        console.warn(warning);
        logger.warn(warning, {
          action: actionName,
          duration,
          stateSize,
          state: state,
        });

        if (onSlowUpdate) {
          onSlowUpdate(metric);
        }
      }

      if (onMetric) {
        onMetric(metric);
      }
    };

    return config(wrappedSet, get, store);
  };
};
```

### Step 8: User-Friendly Error Recovery

```tsx
// src/shared/components/ErrorFallback.tsx
'use client';

import React, { useState } from 'react';

interface ErrorFallbackProps {
  error: Error;
  resetError: () => void;
  title?: string;
  message?: string;
}

export function ErrorFallback({
  error,
  resetError,
  title = 'Something went wrong',
  message = 'We apologize for the inconvenience. Our team has been notified.',
}: ErrorFallbackProps) {
  const [showDetails, setShowDetails] = useState(false);

  return (
    <div className="min-h-[200px] flex items-center justify-center p-6">
      <div className="max-w-md w-full bg-white rounded-lg shadow-lg p-6">
        <div className="flex items-center justify-center w-12 h-12 rounded-full bg-red-100 mx-auto">
          <svg className="w-6 h-6 text-red-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
          </svg>
        </div>
        
        <h2 className="mt-4 text-center text-xl font-semibold text-gray-900">
          {title}
        </h2>
        <p className="mt-2 text-center text-sm text-gray-600">
          {message}
        </p>

        {process.env.NODE_ENV === 'development' && (
          <div className="mt-4">
            <button
              onClick={() => setShowDetails(!showDetails)}
              className="text-sm text-gray-500 hover:text-gray-700"
            >
              {showDetails ? 'Hide' : 'Show'} error details
            </button>
            {showDetails && (
              <pre className="mt-2 p-2 bg-gray-100 rounded text-xs overflow-auto max-h-40 text-gray-800">
                {error.stack || error.message}
              </pre>
            )}
          </div>
        )}

        <button
          onClick={resetError}
          className="mt-4 w-full px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500"
        >
          Try Again
        </button>
      </div>
    </div>
  );
}
```

### Step 9: Global Error Handler

```typescript
// src/infrastructure/logging/globalErrorHandler.ts
import { logger } from './logger';

export function setupGlobalErrorHandlers() {
  // Handle unhandled promise rejections
  if (typeof window !== 'undefined') {
    window.addEventListener('unhandledrejection', (event) => {
      const error = event.reason instanceof Error ? event.reason : new Error(String(event.reason));
      logger.error(error, {
        type: 'unhandledrejection',
        promise: event.promise,
      });
      console.error('Unhandled Promise Rejection:', error);
    });

    // Handle global errors
    window.addEventListener('error', (event) => {
      const error = event.error || new Error(event.message);
      logger.error(error, {
        type: 'globalerror',
        filename: event.filename,
        lineno: event.lineno,
        colno: event.colno,
      });
      console.error('Global error:', error);
    });

    // Handle console errors (optional, for extra logging)
    const originalConsoleError = console.error;
    console.error = (...args: any[]) => {
      const message = args.join(' ');
      logger.error(new Error(message), {
        type: 'consoleerror',
        args,
      });
      originalConsoleError(...args);
    };
  }

  // Node.js uncaught exceptions (server-side)
  if (typeof process !== 'undefined') {
    process.on('uncaughtException', (error) => {
      logger.error(error, {
        type: 'uncaughtException',
      });
      console.error('Uncaught Exception:', error);
      // In production, you might exit after logging
      if (process.env.NODE_ENV === 'production') {
        process.exit(1);
      }
    });

    process.on('unhandledRejection', (reason) => {
      const error = reason instanceof Error ? reason : new Error(String(reason));
      logger.error(error, {
        type: 'unhandledRejection',
      });
      console.error('Unhandled Rejection:', reason);
    });
  }
}
```

---

## The Verification: Testing Error Handling

### Step 1: Test Error Boundary

```tsx
// src/features/tasks/__tests__/errorHandling.test.tsx
import { describe, it, expect, vi } from 'vitest';
import { render, screen, fireEvent } from '@testing-library/react';
import { useTaskStore } from '../store/taskStore';
import { StoreErrorBoundary } from '../../../shared/components/StoreErrorBoundary';

function ErrorComponent() {
  const addTask = useTaskStore((state) => state.addTask);
  
  const handleError = () => {
    // Simulate an error
    const fn = () => { throw new Error('Simulated store error'); };
    fn();
  };

  return <button onClick={handleError}>Trigger Error</button>;
}

describe('Error Handling', () => {
  it('should catch store errors in error boundary', () => {
    const onError = vi.fn();
    render(
      <StoreErrorBoundary onError={onError}>
        <ErrorComponent />
      </StoreErrorBoundary>
    );

    fireEvent.click(screen.getByText('Trigger Error'));
    
    expect(screen.getByText('Something went wrong')).toBeInTheDocument();
    expect(onError).toHaveBeenCalled();
  });
});
```

### Step 2: Test Logging

```typescript
// src/__tests__/logging.test.ts
import { describe, it, expect, vi, beforeEach } from 'vitest';
import { createLogger } from '../../shared/store/middleware/logger';
import { create } from 'zustand';

describe('Logger Middleware', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('should log state changes', () => {
    const consoleLogSpy = vi.spyOn(console, 'log').mockImplementation(() => {});

    const useTestStore = create(
      createLogger({
        enabled: true,
        logActions: true,
        logStateDiff: true,
        prefix: '🧪',
      })((set) => ({
        count: 0,
        increment: () => set((state) => ({ count: state.count + 1 })),
      }))
    );

    useTestStore.getState().increment();

    expect(consoleLogSpy).toHaveBeenCalled();
    expect(consoleLogSpy.mock.calls.some(call => 
      call[0]?.includes('🧪')
    )).toBe(true);

    consoleLogSpy.mockRestore();
  });

  it('should handle errors gracefully', () => {
    const errorStore = create(
      (set) => ({
        data: null,
        updateData: () => {
          throw new Error('Update failed');
        },
      })
    );

    expect(() => {
      errorStore.getState().updateData();
    }).toThrow('Update failed');
  });
});
```

---

## Deep Dive: Logging Strategies

### Strategy 1: Structured Logging

```typescript
// Use JSON-structured logs for easier parsing
export function structuredLog(level: string, message: string, data: any) {
  console.log(JSON.stringify({
    level,
    message,
    data,
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV,
    version: process.env.npm_package_version,
  }));
}
```

### Strategy 2: Sampling in Production

```typescript
// Log only a percentage of actions in production to reduce cost
const shouldSample = Math.random() < 0.1; // 10% sampling rate
if (shouldSample) {
  // Send to logging service
}
```

### Strategy 3: Error Aggregation

```typescript
// Aggregate similar errors to reduce noise
const errorCounter = new Map<string, number>();

function aggregateError(error: Error, context: any) {
  const key = `${error.message}:${context.action}`;
  const count = (errorCounter.get(key) || 0) + 1;
  errorCounter.set(key, count);
  
  if (count === 1 || count % 100 === 0) {
    // Send to logging service only first time and every 100th time
    sendErrorToService(error, context);
  }
}
```

---

## Common Pitfalls and Solutions

### Pitfall 1: Swallowing Errors Without Logging

```typescript
// ❌ BAD: Catching but not logging
try {
  set({ data: await fetchData() });
} catch {
  // Silently fail
}

// ✅ GOOD: Log and handle
try {
  set({ data: await fetchData() });
} catch (error) {
  logger.error(error, { action: 'fetchData' });
  set({ error: 'Failed to load data' });
}
```

### Pitfall 2: Not Recovering from Errors

```typescript
// ❌ BAD: No recovery mechanism
try {
  set({ data: await fetchData() });
} catch {
  // User stuck in broken state
}

// ✅ GOOD: Provide fallback state
try {
  set({ data: await fetchData() });
} catch (error) {
  set({ data: fallbackData, error: error.message });
}
```

### Pitfall 3: Over-Logging Sensitive Data

```typescript
// ❌ BAD: Logging passwords, tokens, personal info
logger.info('User logged in', { 
  email: user.email, 
  password: user.password // 🚨 Sensitive!
});

// ✅ GOOD: Redact sensitive data
function sanitizeLogData(data: any) {
  const sanitized = { ...data };
  if (sanitized.password) sanitized.password = '***';
  if (sanitized.token) sanitized.token = '***';
  return sanitized;
}

logger.info('User logged in', sanitizeLogData(user));
```

---

## Error Handling Checklist

- [ ] Error boundary middleware wraps all stores
- [ ] Centralized logging service is configured
- [ ] Remote logging integration (Sentry, Datadog, etc.)
- [ ] Fallback states defined for error scenarios
- [ ] User-friendly error UI components created
- [ ] Global error handlers (unhandled rejections, global errors)
- [ ] Performance monitoring middleware set up
- [ ] Sensitive data redacted from logs
- [ ] Log sampling configured for production
- [ ] Error recovery strategies implemented

---

## Key Takeaways

1. **Error boundaries** prevent app crashes
2. **Centralized logging** captures all errors and state changes
3. **Remote logging** enables production debugging
4. **User-friendly fallbacks** improve UX during errors
5. **Performance monitoring** catches slow updates
6. **Sensitive data** must be redacted from logs
7. **Sampling** reduces log volume in production
8. **Global handlers** catch unhandled errors
9. **Recovery strategies** restore state after errors
10. **Test error handling** to ensure resilience

---

## What's Next

You've mastered error boundaries and logging. Next, you'll learn about performance monitoring and migration strategies from Redux Toolkit and Context API.
