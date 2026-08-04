# Part 2 — Advanced State Architecture

## Section 10: Debugging

As applications grow, bugs become inevitable. Zustand provides powerful debugging tools that make it easy to inspect state, trace actions, and find issues quickly. In this section, you'll learn how to leverage Redux DevTools, custom logging, and advanced debugging techniques to troubleshoot your Zustand stores effectively.

---

## The Target: Masterful Debugging

By the end of this section, you'll be able to:
- Integrate Zustand with Redux DevTools for time-travel debugging
- Trace actions and state mutations with custom logging
- Debug asynchronous workflows and race conditions
- Understand and fix performance issues using DevTools
- Implement custom debugging middleware for production monitoring

---

## The Concept: Debugging as Your X-Ray Vision

Think of debugging tools like an **MRI machine for your application**:

```
┌─────────────────────────────────────────────────────────────────┐
│                    DEBUGGING TOOLKIT                           │
│                                                                 │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐    │
│  │ Redux        │    │ Action       │    │ Performance  │    │
│  │ DevTools     │    │ Tracing      │    │ Monitor      │    │
│  │              │    │              │    │              │    │
│  │ • Time travel│    │ • Every action│   │ • Slow       │    │
│  │ • State      │    │   logged      │    │   updates    │    │
│  │   inspection │    │ • Payload     │    │ • Re-render  │    │
│  │ • Diffing    │    │   inspection  │    │   count      │    │
│  │ • Skipping   │    │ • Stack traces│    │ • Memory     │    │
│  └──────────────┘    └──────────────┘    └──────────────┘    │
│                                                                 │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐    │
│  │ Async        │    │ Immutability │    │ Error        │    │
│  │ Debugging    │    │ Checker      │    │ Reporting    │    │
│  │              │    │              │    │              │    │
│  │ • Promise    │    │ • Ensure     │    │ • Catch      │    │
│  │   tracking   │    │   no         │    │   exceptions │    │
│  │ • Race       │    │   mutations  │    │ • Log to     │    │
│  │   detection  │    │ • Detect     │    │   services   │    │
│  │ • Cancellation│   │   stale      │    │ • User       │    │
│  └──────────────┘    └──────────────┘    └──────────────┘    │
└─────────────────────────────────────────────────────────────────┘
```

---

## The Implementation: Debugging Techniques

### Step 1: Setting Up Redux DevTools

The `devtools` middleware connects your Zustand store to the Redux DevTools browser extension:

```typescript
// src/store/withDevtools.ts
import { create } from 'zustand';
import { devtools } from 'zustand/middleware';

interface DebugStore {
  count: number;
  user: { name: string } | null;
  tasks: string[];
  
  increment: () => void;
  decrement: () => void;
  setUser: (name: string) => void;
  addTask: (task: string) => void;
  clearTasks: () => void;
}

// Basic devtools setup
export const useDebugStore = create<DebugStore>()(
  devtools(
    (set) => ({
      count: 0,
      user: null,
      tasks: [],
      
      increment: () => 
        set((state) => ({ count: state.count + 1 }), false, 'increment'),
      decrement: () => 
        set((state) => ({ count: state.count - 1 }), false, 'decrement'),
      setUser: (name: string) => 
        set({ user: { name } }, false, 'setUser'),
      addTask: (task: string) => 
        set((state) => ({ tasks: [...state.tasks, task] }), false, 'addTask'),
      clearTasks: () => 
        set({ tasks: [] }, false, 'clearTasks'),
    }),
    {
      name: 'Debug Store',          // Display name in DevTools
      enabled: process.env.NODE_ENV === 'development',
      anonymousActionType: 'unknown',
    }
  )
);

// Advanced devtools with action grouping
export const useAdvancedDebugStore = create<DebugStore>()(
  devtools(
    (set) => ({
      count: 0,
      user: null,
      tasks: [],
      
      // Group related actions for better visualization
      increment: () => {
        const actionName = 'counter/increment';
        set((state) => ({ count: state.count + 1 }), false, actionName);
      },
      decrement: () => {
        const actionName = 'counter/decrement';
        set((state) => ({ count: state.count - 1 }), false, actionName);
      },
      setUser: (name: string) => {
        set({ user: { name } }, false, 'user/set');
      },
      addTask: (task: string) => {
        set((state) => ({ tasks: [...state.tasks, task] }), false, 'tasks/add');
      },
      clearTasks: () => {
        set({ tasks: [] }, false, 'tasks/clear');
      },
    }),
    {
      name: 'Advanced Debug Store',
      enabled: process.env.NODE_ENV === 'development',
      // Optionally, connect to an external store
      // store: someExternalStore,
    }
  )
);
```

### Step 2: Custom Logging Middleware for Debugging

Create a comprehensive logging middleware for debugging:

```typescript
// src/middleware/logger.ts
import { StateCreator } from 'zustand';

interface LoggerOptions {
  enabled?: boolean;
  logActions?: boolean;
  logState?: boolean;
  logDiffs?: boolean;
  collapsed?: boolean;
  colors?: {
    action?: string;
    prevState?: string;
    nextState?: string;
    error?: string;
  };
}

export const createLogger = <T extends object>(
  options: LoggerOptions = {}
): ((config: StateCreator<T, [], []>) => StateCreator<T, [], []>) => {
  const {
    enabled = process.env.NODE_ENV === 'development',
    logActions = true,
    logState = true,
    logDiffs = true,
    collapsed = true,
    colors = {
      action: '#03A9F4',
      prevState: '#9E9E9E',
      nextState: '#4CAF50',
      error: '#F44336',
    },
  } = options;

  return (config: StateCreator<T, [], []>) => 
    (set, get, store) => {
      if (!enabled) {
        return config(set, get, store);
      }

      // Track action count
      let actionCount = 0;
      const actionHistory: Array<{ action: string; timestamp: number }> = [];

      const wrappedSet = (args: any) => {
        const prevState = get();
        const actionName = 
          typeof args === 'function' 
            ? 'setState (functional)' 
            : 'setState (object)';
        
        // Before update
        const startTime = performance.now();
        
        // Perform update
        set(args);
        
        const duration = performance.now() - startTime;
        const nextState = get();
        actionCount++;
        
        // Build log group
        const groupName = `🔄 ${actionName} #${actionCount} (${duration.toFixed(2)}ms)`;
        
        if (collapsed) {
          console.groupCollapsed(groupName);
        } else {
          console.group(groupName);
        }
        
        // Log action
        if (logActions) {
          console.log('%cAction:', `font-weight: bold; color: ${colors.action}`, {
            type: actionName,
            args,
            count: actionCount,
            timestamp: new Date().toISOString(),
          });
          actionHistory.push({ action: actionName, timestamp: Date.now() });
        }
        
        // Log state
        if (logState) {
          console.log('%cPrev State:', `color: ${colors.prevState}`, prevState);
          console.log('%cNext State:', `color: ${colors.nextState}`, nextState);
        }
        
        // Log diffs
        if (logDiffs) {
          const changes: Record<string, { from: any; to: any }> = {};
          const allKeys = new Set([...Object.keys(prevState), ...Object.keys(nextState)]);
          
          for (const key of allKeys) {
            const prev = (prevState as any)[key];
            const next = (nextState as any)[key];
            if (JSON.stringify(prev) !== JSON.stringify(next)) {
              changes[key] = { from: prev, to: next };
            }
          }
          
          if (Object.keys(changes).length > 0) {
            console.log('📊 Changes:', changes);
          } else {
            console.log('✅ No changes detected');
          }
        }
        
        console.groupEnd();
      };

      return config(wrappedSet, get, store);
    };
};

// Usage
import { create } from 'zustand';
import { createLogger } from '../middleware/logger';

const useLoggingStore = create(
  createLogger({
    enabled: true,
    logActions: true,
    logState: true,
    logDiffs: true,
    collapsed: true,
  })((set) => ({
    count: 0,
    increment: () => set((state) => ({ count: state.count + 1 })),
  }))
);
```

### Step 3: Debugging Asynchronous Actions

Async actions can be tricky to debug. Use logging and error tracking:

```typescript
// src/store/asyncDebugStore.ts
import { create } from 'zustand';
import { devtools } from 'zustand/middleware';

interface AsyncDebugStore {
  data: any[];
  loading: boolean;
  error: string | null;
  requestId: string | null;
  
  fetchData: (endpoint: string) => Promise<void>;
  reset: () => void;
}

export const useAsyncDebugStore = create<AsyncDebugStore>()(
  devtools(
    (set, get) => ({
      data: [],
      loading: false,
      error: null,
      requestId: null,

      fetchData: async (endpoint: string) => {
        const requestId = `req-${Date.now()}-${Math.random().toString(36).slice(2, 7)}`;
        
        // Log the start of the request
        console.log(`🚀 [${requestId}] Starting fetch:`, { endpoint });
        
        set(
          { 
            loading: true, 
            error: null, 
            requestId,
          },
          false,
          `fetchData/start: ${endpoint}`
        );

        try {
          // Simulate API call
          const response = await fetch(endpoint);
          console.log(`📡 [${requestId}] Response status:`, response.status);
          
          if (!response.ok) {
            throw new Error(`HTTP ${response.status}: ${response.statusText}`);
          }
          
          const data = await response.json();
          console.log(`📦 [${requestId}] Data received:`, data);
          
          set(
            { 
              data, 
              loading: false, 
              error: null,
              requestId: null,
            },
            false,
            `fetchData/success: ${endpoint}`
          );
          
          console.log(`✅ [${requestId}] Fetch completed successfully`);
          
        } catch (error) {
          const errorMessage = error instanceof Error ? error.message : 'Unknown error';
          console.error(`❌ [${requestId}] Fetch failed:`, errorMessage);
          
          set(
            { 
              loading: false, 
              error: errorMessage,
              requestId: null,
            },
            false,
            `fetchData/error: ${endpoint}`
          );
        }
      },

      reset: () => {
        set(
          { data: [], loading: false, error: null, requestId: null },
          false,
          'reset'
        );
      },
    }),
    {
      name: 'Async Debug Store',
    }
  )
);
```

### Step 4: Action Tracing and Profiling

Track actions and measure performance:

```typescript
// src/middleware/tracer.ts
import { StateCreator } from 'zustand';

interface TraceEvent {
  action: string;
  timestamp: number;
  duration: number;
  stateSize: number;
  error?: string;
}

export const createTracer = <T extends object>(
  options: {
    onTrace?: (event: TraceEvent) => void;
    maxEvents?: number;
    sampleRate?: number;
  } = {}
): ((config: StateCreator<T, [], []>) => StateCreator<T, [], []>) => {
  const {
    onTrace,
    maxEvents = 1000,
    sampleRate = 1.0,
  } = options;

  let events: TraceEvent[] = [];

  return (config: StateCreator<T, [], []>) => 
    (set, get, store) => {
      return config(
        (args) => {
          const startTime = performance.now();
          const actionName = typeof args === 'function' ? 'functional' : 'object';
          
          // Perform update
          try {
            set(args);
          } catch (error) {
            const event: TraceEvent = {
              action: actionName,
              timestamp: Date.now(),
              duration: performance.now() - startTime,
              stateSize: 0,
              error: error instanceof Error ? error.message : 'Unknown error',
            };
            events.push(event);
            if (onTrace) onTrace(event);
            throw error;
          }
          
          const duration = performance.now() - startTime;
          const state = get();
          const stateSize = new Blob([JSON.stringify(state)]).size;
          
          // Sample
          if (Math.random() > sampleRate) return;
          
          const event: TraceEvent = {
            action: actionName,
            timestamp: Date.now(),
            duration,
            stateSize,
          };
          
          events.push(event);
          if (events.length > maxEvents) {
            events = events.slice(-maxEvents);
          }
          
          if (onTrace) {
            onTrace(event);
          }
        },
        get,
        store
      );
    };
};

// Usage with analytics
const tracer = createTracer({
  onTrace: (event) => {
    console.log('📊 Trace:', event);
    // Send to analytics service
    if (event.duration > 100) {
      console.warn('🐌 Slow update detected:', event);
    }
  },
  sampleRate: 0.5, // Log 50% of updates
});

const useTracedStore = create(tracer((set) => ({
  count: 0,
  increment: () => set((state) => ({ count: state.count + 1 })),
})));
```

### Step 5: Immutability and Mutation Detection

Detect accidental mutations to help debug bugs:

```typescript
// src/middleware/immutabilityChecker.ts
import { StateCreator } from 'zustand';

// Deep freeze helper (for development only)
function deepFreeze<T>(obj: T): T {
  if (typeof obj !== 'object' || obj === null) return obj;
  
  // Handle arrays
  if (Array.isArray(obj)) {
    obj.forEach((item, index) => {
      obj[index] = deepFreeze(item);
    });
  } else {
    // Handle objects
    Object.keys(obj).forEach((key) => {
      (obj as any)[key] = deepFreeze((obj as any)[key]);
    });
  }
  
  return Object.freeze(obj);
}

// Detect mutations by comparing with frozen snapshots
export const createImmutabilityChecker = <T extends object>(
  options: {
    enabled?: boolean;
    onMutation?: (path: string[], value: any) => void;
  } = {}
): ((config: StateCreator<T, [], []>) => StateCreator<T, [], []>) => {
  const {
    enabled = process.env.NODE_ENV === 'development',
    onMutation = (path, value) => {
      console.error('❌ Mutation detected at path:', path.join('.'), 'value:', value);
    },
  } = options;

  return (config: StateCreator<T, [], []>) => 
    (set, get, store) => {
      if (!enabled) {
        return config(set, get, store);
      }

      // Deep freeze initial state to prevent mutations
      const initialState = config(set, get, store);
      deepFreeze(initialState);

      // Store a deep frozen snapshot for comparison
      let snapshot = deepFreeze(JSON.parse(JSON.stringify(get())));

      const wrappedSet = (args: any) => {
        // Perform update
        set(args);
        
        // Check for mutations
        const currentState = get();
        const snapshotString = JSON.stringify(snapshot);
        const currentString = JSON.stringify(currentState);
        
        if (snapshotString !== currentString) {
          // Find mutations
          const changes = findDeepChanges(snapshot, currentState, []);
          for (const change of changes) {
            onMutation(change.path, change.value);
          }
        }
        
        // Update snapshot
        snapshot = deepFreeze(JSON.parse(JSON.stringify(get())));
      };

      return config(wrappedSet, get, store);
    };
};

// Helper to find deep changes
function findDeepChanges(
  oldObj: any,
  newObj: any,
  path: string[]
): Array<{ path: string[]; value: any }> {
  const changes: Array<{ path: string[]; value: any }> = [];
  
  if (typeof oldObj !== 'object' || oldObj === null) return changes;
  if (typeof newObj !== 'object' || newObj === null) return changes;
  
  const allKeys = new Set([...Object.keys(oldObj), ...Object.keys(newObj)]);
  
  for (const key of allKeys) {
    const oldVal = oldObj[key];
    const newVal = newObj[key];
    const currentPath = [...path, key];
    
    if (JSON.stringify(oldVal) !== JSON.stringify(newVal)) {
      if (typeof oldVal === 'object' && oldVal !== null &&
          typeof newVal === 'object' && newVal !== null) {
        // Recursively find changes
        const nestedChanges = findDeepChanges(oldVal, newVal, currentPath);
        changes.push(...nestedChanges);
      } else {
        changes.push({ path: currentPath, value: newVal });
      }
    }
  }
  
  return changes;
}

// Usage
const useImmutableStore = create(
  createImmutabilityChecker({
    enabled: true,
    onMutation: (path, value) => {
      console.error('❌ Mutation detected!', path.join('.'), '=', value);
      // Could also log to an external service
    },
  })((set) => ({
    data: { items: [] },
    addItem: (item: string) => 
      set((state) => {
        // This is safe - Immer or manual immutable update
        return { data: { items: [...state.data.items, item] } };
      }),
  }))
);
```

### Step 6: Error Boundaries and Error Reporting

Catch and report errors in state updates:

```typescript
// src/middleware/errorBoundary.ts
import { StateCreator } from 'zustand';

interface ErrorReport {
  action: string;
  error: string;
  stack?: string;
  state: any;
  timestamp: number;
}

export const createErrorBoundary = <T extends object>(
  options: {
    onError?: (report: ErrorReport) => void;
    reportToService?: (report: ErrorReport) => Promise<void>;
    fallbackState?: Partial<T>;
  } = {}
): ((config: StateCreator<T, [], []>) => StateCreator<T, [], []>) => {
  const {
    onError,
    reportToService,
    fallbackState,
  } = options;

  return (config: StateCreator<T, [], []>) => 
    (set, get, store) => {
      const wrappedSet = (args: any) => {
        try {
          // Try the update
          set(args);
        } catch (error) {
          const currentState = get();
          const errorMessage = error instanceof Error ? error.message : 'Unknown error';
          const stack = error instanceof Error ? error.stack : undefined;
          
          const report: ErrorReport = {
            action: typeof args === 'function' ? 'functional update' : 'object update',
            error: errorMessage,
            stack,
            state: currentState,
            timestamp: Date.now(),
          };
          
          // Call onError
          if (onError) {
            onError(report);
          }
          
          // Report to service
          if (reportToService) {
            reportToService(report).catch(console.error);
          }
          
          // Log to console
          console.error('🔥 State update error:', error);
          console.error('📊 State at error:', currentState);
          
          // Apply fallback state if provided
          if (fallbackState) {
            set(fallbackState as any);
          }
          
          // Re-throw to let component error boundaries catch it
          throw error;
        }
      };
      
      return config(wrappedSet, get, store);
    };
};

// Usage with sentry or similar
import * as Sentry from '@sentry/react';

const useErrorBoundaryStore = create(
  createErrorBoundary({
    onError: (report) => {
      console.error('🚨 Error report:', report);
      // Could also display user-friendly error
    },
    reportToService: async (report) => {
      Sentry.captureException(new Error(report.error), {
        extra: {
          state: report.state,
          action: report.action,
          timestamp: report.timestamp,
        },
      });
    },
    fallbackState: { data: [], loading: false, error: 'An error occurred' },
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

---

## The Verification: Debugging in Action

### Step 1: Test Redux DevTools

Open your browser with Redux DevTools installed:

```typescript
// src/App.tsx
import React from 'react';
import { useDebugStore } from './store/withDevtools';

function DebugApp() {
  const { count, user, tasks, increment, decrement, setUser, addTask, clearTasks } = useDebugStore();

  const [name, setName] = React.useState('');
  const [task, setTask] = React.useState('');

  return (
    <div style={{ padding: '20px' }}>
      <h1>Debugging Demo</h1>
      <div>
        <h3>Counter: {count}</h3>
        <button onClick={increment}>+</button>
        <button onClick={decrement}>-</button>
      </div>
      
      <div>
        <h3>User</h3>
        <input value={name} onChange={(e) => setName(e.target.value)} />
        <button onClick={() => setUser(name)}>Set User</button>
        <pre>{JSON.stringify(user, null, 2)}</pre>
      </div>
      
      <div>
        <h3>Tasks ({tasks.length})</h3>
        <input value={task} onChange={(e) => setTask(e.target.value)} />
        <button onClick={() => addTask(task)}>Add Task</button>
        <button onClick={clearTasks}>Clear</button>
        <ul>
          {tasks.map((t, i) => <li key={i}>{t}</li>)}
        </ul>
      </div>
    </div>
  );
}

export default DebugApp;
```

**Verification Steps**:
1. Open browser with Redux DevTools extension installed
2. Open DevTools and go to the "Redux" tab
3. Interact with the app - see actions appear with state diffs
4. Use time-travel: click on past actions to revert state

### Step 2: Test Console Logging

With the logger middleware enabled:

```typescript
// Console output will show:
// 🔄 setState (object) #1 (12.34ms)
//   Action: { type: 'setState', args: { count: 1 } }
//   Prev State: { count: 0, user: null, tasks: [] }
//   Next State: { count: 1, user: null, tasks: [] }
//   Changes: { count: { from: 0, to: 1 } }
```

### Step 3: Test Async Debugging

```typescript
// src/components/AsyncDebug.tsx
import React, { useEffect } from 'react';
import { useAsyncDebugStore } from '../store/asyncDebugStore';

function AsyncDebug() {
  const { data, loading, error, requestId, fetchData, reset } = useAsyncDebugStore();

  useEffect(() => {
    // Simulate fetching
    fetchData('https://jsonplaceholder.typicode.com/posts');
  }, []);

  return (
    <div>
      <h2>Async Debug</h2>
      {loading && <div>Loading... (Request ID: {requestId})</div>}
      {error && <div style={{ color: 'red' }}>Error: {error}</div>}
      <button onClick={() => fetchData('https://jsonplaceholder.typicode.com/posts')}>
        Retry
      </button>
      <button onClick={reset}>Reset</button>
      <pre>{JSON.stringify(data.slice(0, 3), null, 2)}</pre>
    </div>
  );
}
```

Console should show:
```
🚀 [req-1234567890-abc] Starting fetch: { endpoint: '...' }
📡 [req-1234567890-abc] Response status: 200
📦 [req-1234567890-abc] Data received: [...]
✅ [req-1234567890-abc] Fetch completed successfully
```

---

## Deep Dive: Redux DevTools Integration

When using `devtools`, Zustand automatically sends actions to the DevTools extension. Each `set` call can be named:

```typescript
// Named actions improve readability in DevTools
set({ count: 1 }, false, 'increment');
// The action appears as 'increment' in DevTools
```

### DevTools Options

```typescript
devtools(config, {
  name: 'Store Name',                    // Display name
  enabled: process.env.NODE_ENV === 'development',
  anonymousActionType: 'unknown',        // Fallback name
  // Custom store (if you want to use your own store)
  // store: myStore,
});
```

### Time-Travel Debugging

Redux DevTools allows you to:
1. **Jump** to any state in history
2. **Skip** an action to see what would happen without it
3. **Persist** state across reloads
4. **Export/Import** state for sharing with team members

---

## Common Pitfalls and Solutions

### Pitfall 1: Not Naming Actions in DevTools

```typescript
// ❌ BAD: Action appears as 'setState (object)'
set({ count: 1 });

// ✅ GOOD: Action is named
set({ count: 1 }, false, 'counter/increment');
```

### Pitfall 2: Debugging in Production

```typescript
// ❌ BAD: DevTools enabled in production (security risk)
devtools(config, { enabled: true });

// ✅ GOOD: Only in development
devtools(config, { enabled: process.env.NODE_ENV === 'development' });
```

### Pitfall 3: Not Logging Async Errors

```typescript
// ❌ BAD: Async error swallowed
fetchData: async () => {
  const data = await fetch('/api').then(r => r.json());
  set({ data });
}

// ✅ GOOD: Proper error logging
fetchData: async () => {
  try {
    const data = await fetch('/api').then(r => r.json());
    set({ data });
  } catch (error) {
    console.error('Fetch failed:', error);
    set({ error: error.message });
  }
}
```

### Pitfall 4: Over-Logging

```typescript
// ❌ BAD: Logging every tiny update
const logger = createLogger({ logActions: true, logState: true });
// 100 updates per second = 100 logs/second

// ✅ GOOD: Sample or reduce logging
const logger = createLogger({ 
  logActions: true, 
  logState: false, 
  logDiffs: true 
});
// Only log diffs, not full state
```

---

## Production Debugging Strategies

### Strategy 1: Remote Logging

```typescript
// src/middleware/remoteLogger.ts
export const remoteLogger = <T extends object>(
  config: StateCreator<T, [], []>,
  options: { endpoint: string }
): StateCreator<T, [], []> => {
  return (set, get, store) => {
    const wrappedSet = (args: any) => {
      const prev = get();
      set(args);
      const next = get();
      
      // Send to remote endpoint (throttled)
      if (Date.now() % 10 === 0) { // Sample 10%
        navigator.sendBeacon(options.endpoint, JSON.stringify({
          action: typeof args === 'function' ? 'functional' : 'object',
          prev,
          next,
          timestamp: Date.now(),
        }));
      }
    };
    return config(wrappedSet, get, store);
  };
};
```

### Strategy 2: User-Context Debugging

```typescript
// Attach user context to logs
export const userContextLogger = <T extends object>(
  config: StateCreator<T, [], []>,
  getUserContext: () => { userId: string; sessionId: string }
): StateCreator<T, [], []> => {
  return (set, get, store) => {
    const wrappedSet = (args: any) => {
      const context = getUserContext();
      console.log(`📱 User ${context.userId} (${context.sessionId}) action:`, args);
      set(args);
    };
    return config(wrappedSet, get, store);
  };
};
```

### Strategy 3: Performance Budget Monitoring

```typescript
// src/middleware/performanceBudget.ts
export const performanceBudget = <T extends object>(
  config: StateCreator<T, [], []>,
  budget: { maxUpdateTime: number; maxStateSize: number }
): StateCreator<T, [], []> => {
  let updateCount = 0;
  return (set, get, store) => {
    const wrappedSet = (args: any) => {
      updateCount++;
      const start = performance.now();
      set(args);
      const duration = performance.now() - start;
      const stateSize = new Blob([JSON.stringify(get())]).size;
      
      if (duration > budget.maxUpdateTime) {
        console.warn(`⚠️ Performance budget exceeded: ${duration.toFixed(2)}ms`);
        // Report to monitoring service
      }
      if (stateSize > budget.maxStateSize) {
        console.warn(`⚠️ State size budget exceeded: ${stateSize} bytes`);
      }
    };
    return config(wrappedSet, get, store);
  };
};
```

---

## Key Takeaways

1. **Use Redux DevTools**: Time-travel debugging and state inspection
2. **Name your actions**: Makes debugging much easier
3. **Custom logging middleware**: Flexible debugging for your needs
4. **Trace async workflows**: Log request IDs and timestamps
5. **Detect mutations**: Prevent accidental state mutations
6. **Error boundaries**: Catch and report errors gracefully
7. **Performance monitoring**: Track slow updates and state size
8. **Only enable in development**: Avoid leaking sensitive info
9. **Use production debugging**: Remote logging and performance budgets
10. **Leverage browser tools**: Console, network, and performance tabs

---

## What's Next

Now that you're a debugging pro, you're ready to tackle derived and computed state. In the next section, you'll learn how to efficiently compute derived state and keep your store normalized.
