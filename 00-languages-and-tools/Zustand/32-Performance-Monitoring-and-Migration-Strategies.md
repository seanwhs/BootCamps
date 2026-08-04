# Part 8 — Enterprise Best Practices

## Section 32: Performance Monitoring and Migration Strategies

As your application grows, you need to monitor its performance in production and plan for future migrations. Zustand is a lightweight library, but when used at scale, you need to track metrics, identify bottlenecks, and ensure your architecture evolves smoothly. This section covers performance monitoring strategies and practical migration paths from Redux Toolkit and Context API.

---

## The Target: Observable, Migratable State Management

By the end of this section, you'll be able to:
- Implement performance monitoring for Zustand stores in production
- Track key metrics like state size, update frequency, and render counts
- Set up performance budgets and alerts
- Migrate from Redux Toolkit to Zustand incrementally
- Migrate from Context API to Zustand without breaking existing code
- Use feature flags to test Zustand migrations incrementally

---

## The Concept: Performance Monitoring as a Dashboard

Think of performance monitoring like a **car's instrument panel**:

```
┌─────────────────────────────────────────────────────────────────┐
│                    PERFORMANCE MONITORING                       │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Metrics Dashboard                                      │  │
│  │  • State Size: 245KB                                    │  │
│  │  • Updates/sec: 12                                      │  │
│  │  • Average Update: 2.3ms                               │  │
│  │  • Slow Updates: 0.5%                                  │  │
│  │  • Memory Usage: 56MB                                  │  │
│  └──────────────────────────────────────────────────────────┘  │
│                         │                                      │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Alerts                                                │  │
│  │  ⚠️ State size exceeded 500KB                          │  │
│  │  ⚠️ Slow updates > 50ms threshold                     │  │
│  │  ✅ Performance budget OK                              │  │
│  └──────────────────────────────────────────────────────────┘  │
│                         │                                      │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Migration Status                                       │  │
│  │  • Redux: 40% migrated                                  │  │
│  │  • Context: 60% migrated                               │  │
│  │  • Feature Flags: 5 active                             │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

---

## The Implementation: Performance Monitoring

### Step 1: Performance Monitoring Middleware

```typescript
// src/shared/store/middleware/performanceMonitor.ts
import { StateCreator } from 'zustand';

export interface PerformanceMetric {
  action: string;
  duration: number;
  stateSize: number;
  timestamp: number;
  updateCount: number;
  changedKeys: string[];
}

export interface PerformanceOptions {
  enabled?: boolean;
  slowUpdateThreshold?: number;
  maxStateSize?: number;
  sampleRate?: number;
  onMetric?: (metric: PerformanceMetric) => void;
  onSlowUpdate?: (metric: PerformanceMetric) => void;
  onLargeState?: (metric: PerformanceMetric) => void;
  remoteEndpoint?: string;
}

export const createPerformanceMonitor = <T extends object>(
  options: PerformanceOptions = {}
): ((config: StateCreator<T, [], []>) => StateCreator<T, [], []>) => {
  const {
    enabled = process.env.NODE_ENV === 'production',
    slowUpdateThreshold = 50,
    maxStateSize = 500 * 1024, // 500KB
    sampleRate = 0.1,
    onMetric,
    onSlowUpdate,
    onLargeState,
    remoteEndpoint,
  } = options;

  let updateCount = 0;
  let metrics: PerformanceMetric[] = [];
  let flushTimer: NodeJS.Timeout | null = null;

  const flushMetrics = async () => {
    if (metrics.length === 0 || !remoteEndpoint) return;
    const batch = [...metrics];
    metrics = [];
    try {
      await fetch(remoteEndpoint, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ metrics: batch, timestamp: Date.now() }),
      });
    } catch (error) {
      console.error('Failed to send performance metrics:', error);
      // Put them back
      metrics = [...batch, ...metrics];
    }
  };

  if (remoteEndpoint) {
    flushTimer = setInterval(flushMetrics, 30000); // Every 30 seconds
  }

  return (config: StateCreator<T, [], []>) => (set, get, store) => {
    const wrappedSet = (args: any) => {
      const startTime = performance.now();
      const prevState = get();
      const actionName = typeof args === 'function' ? 'functional' : 'object';

      set(args);

      const duration = performance.now() - startTime;
      const state = get();
      updateCount++;

      // Sample
      if (Math.random() > sampleRate) {
        return;
      }

      const stateSize = new Blob([JSON.stringify(state)]).size;
      const changedKeys = Object.keys(state).filter(
        key => JSON.stringify(prevState[key]) !== JSON.stringify(state[key])
      );

      const metric: PerformanceMetric = {
        action: actionName,
        duration,
        stateSize,
        timestamp: Date.now(),
        updateCount,
        changedKeys,
      };

      metrics.push(metric);
      if (metrics.length > 1000) {
        metrics = metrics.slice(-1000);
      }

      if (onMetric) {
        onMetric(metric);
      }

      // Check for slow updates
      if (duration > slowUpdateThreshold && onSlowUpdate) {
        console.warn(`🐌 Slow update: ${duration.toFixed(2)}ms (${actionName})`);
        onSlowUpdate(metric);
      }

      // Check for large state
      if (stateSize > maxStateSize && onLargeState) {
        console.warn(`📦 Large state: ${(stateSize / 1024).toFixed(1)}KB`);
        onLargeState(metric);
      }
    };

    // Clean up on store destroy
    const originalDestroy = store.destroy;
    store.destroy = () => {
      if (flushTimer) {
        clearInterval(flushTimer);
        flushTimer = null;
      }
      flushMetrics();
      if (originalDestroy) {
        originalDestroy();
      }
    };

    return config(wrappedSet, get, store);
  };
};
```

### Step 2: Performance Dashboard Component

```tsx
// src/shared/components/PerformanceDashboard.tsx
'use client';

import React, { useState, useEffect, useRef } from 'react';
import { usePerformanceStore } from '../../infrastructure/performance/store';

interface PerformanceData {
  stateSize: number;
  updateCount: number;
  averageUpdateTime: number;
  slowUpdateCount: number;
  memoryUsage?: number;
  timestamp: number;
}

export function PerformanceDashboard() {
  const [isOpen, setIsOpen] = useState(false);
  const [metrics, setMetrics] = useState<PerformanceData[]>([]);
  const [currentMetrics, setCurrentMetrics] = useState<PerformanceData | null>(null);
  const containerRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    // Subscribe to performance metrics
    const unsubscribe = usePerformanceStore.subscribe((state) => {
      const data: PerformanceData = {
        stateSize: state.stateSize || 0,
        updateCount: state.updateCount || 0,
        averageUpdateTime: state.averageUpdateTime || 0,
        slowUpdateCount: state.slowUpdateCount || 0,
        memoryUsage: (performance as any).memory?.usedJSHeapSize,
        timestamp: Date.now(),
      };
      setCurrentMetrics(data);
      setMetrics(prev => [...prev.slice(-50), data]);
    });

    return () => unsubscribe();
  }, []);

  if (!isOpen) {
    return (
      <button
        onClick={() => setIsOpen(true)}
        className="fixed bottom-4 right-4 z-50 bg-gray-800 text-white px-4 py-2 rounded-lg shadow-lg hover:bg-gray-700"
      >
        📊 Performance
      </button>
    );
  }

  const latest = currentMetrics || metrics[metrics.length - 1];

  return (
    <div
      ref={containerRef}
      className="fixed bottom-0 left-0 right-0 z-50 bg-gray-900 text-white p-4 max-h-64 overflow-auto"
    >
      <div className="flex justify-between items-center mb-4">
        <h3 className="text-lg font-semibold">📊 Performance Dashboard</h3>
        <button
          onClick={() => setIsOpen(false)}
          className="text-gray-400 hover:text-white"
        >
          ✕
        </button>
      </div>

      {latest ? (
        <div className="grid grid-cols-4 gap-4">
          <div className="bg-gray-800 p-3 rounded">
            <div className="text-xs text-gray-400">State Size</div>
            <div className="text-lg font-mono">
              {(latest.stateSize / 1024).toFixed(1)} KB
            </div>
          </div>
          <div className="bg-gray-800 p-3 rounded">
            <div className="text-xs text-gray-400">Updates</div>
            <div className="text-lg font-mono">{latest.updateCount}</div>
          </div>
          <div className="bg-gray-800 p-3 rounded">
            <div className="text-xs text-gray-400">Avg Update Time</div>
            <div className="text-lg font-mono">
              {latest.averageUpdateTime.toFixed(2)} ms
            </div>
          </div>
          <div className="bg-gray-800 p-3 rounded">
            <div className="text-xs text-gray-400">Slow Updates</div>
            <div className="text-lg font-mono text-yellow-400">
              {latest.slowUpdateCount}
            </div>
          </div>
          {latest.memoryUsage && (
            <div className="bg-gray-800 p-3 rounded">
              <div className="text-xs text-gray-400">Memory</div>
              <div className="text-lg font-mono">
                {(latest.memoryUsage / 1024 / 1024).toFixed(1)} MB
              </div>
            </div>
          )}
        </div>
      ) : (
        <div className="text-gray-400">Waiting for metrics...</div>
      )}

      {/* Mini chart of state size over time */}
      {metrics.length > 1 && (
        <div className="mt-4 h-12 flex items-end gap-0.5">
          {metrics.map((m, i) => {
            const maxSize = Math.max(1, ...metrics.map(mm => mm.stateSize));
            const height = (m.stateSize / maxSize) * 100;
            const isLatest = i === metrics.length - 1;
            return (
              <div
                key={i}
                className={`flex-1 ${isLatest ? 'bg-blue-400' : 'bg-blue-600'}`}
                style={{ height: `${Math.min(height, 100)}%` }}
                title={`${(m.stateSize / 1024).toFixed(1)} KB`}
              />
            );
          })}
        </div>
      )}
    </div>
  );
}
```

### Step 3: Migration from Redux Toolkit

```typescript
// src/migrations/redux-to-zustand.ts

// === OLD REDUX CODE ===
// src/store/redux/taskSlice.ts
import { createSlice, createAsyncThunk } from '@reduxjs/toolkit';

interface Task {
  id: string;
  title: string;
  completed: boolean;
}

interface TaskState {
  tasks: Task[];
  loading: boolean;
  error: string | null;
}

const initialState: TaskState = {
  tasks: [],
  loading: false,
  error: null,
};

export const fetchTasks = createAsyncThunk('tasks/fetch', async () => {
  const response = await fetch('/api/tasks');
  return response.json();
});

const taskSlice = createSlice({
  name: 'tasks',
  initialState,
  reducers: {
    addTask: (state, action) => {
      state.tasks.push(action.payload);
    },
    toggleTask: (state, action) => {
      const task = state.tasks.find(t => t.id === action.payload);
      if (task) task.completed = !task.completed;
    },
    deleteTask: (state, action) => {
      state.tasks = state.tasks.filter(t => t.id !== action.payload);
    },
  },
  extraReducers: (builder) => {
    builder
      .addCase(fetchTasks.pending, (state) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(fetchTasks.fulfilled, (state, action) => {
        state.tasks = action.payload;
        state.loading = false;
      })
      .addCase(fetchTasks.rejected, (state, action) => {
        state.loading = false;
        state.error = action.error.message || 'Failed to fetch';
      });
  },
});

export const { addTask, toggleTask, deleteTask } = taskSlice.actions;
export default taskSlice.reducer;

// === NEW ZUSTAND CODE ===
// src/domains/task/store/taskStore.ts
import { create } from 'zustand';
import { immer } from 'zustand/middleware/immer';

interface TaskStore {
  tasks: Task[];
  loading: boolean;
  error: string | null;
  fetchTasks: () => Promise<void>;
  addTask: (task: Task) => void;
  toggleTask: (id: string) => void;
  deleteTask: (id: string) => void;
}

export const useTaskStore = create<TaskStore>()(
  immer((set, get) => ({
    tasks: [],
    loading: false,
    error: null,

    fetchTasks: async () => {
      set({ loading: true, error: null });
      try {
        const response = await fetch('/api/tasks');
        const tasks = await response.json();
        set({ tasks, loading: false });
      } catch (error) {
        set({ loading: false, error: error.message });
      }
    },

    addTask: (task) => {
      set((state) => {
        state.tasks.push(task);
      });
    },

    toggleTask: (id) => {
      set((state) => {
        const task = state.tasks.find(t => t.id === id);
        if (task) task.completed = !task.completed;
      });
    },

    deleteTask: (id) => {
      set((state) => {
        state.tasks = state.tasks.filter(t => t.id !== id);
      });
    },
  }))
);

// === MIGRATION ADAPTER ===
// src/migrations/redux-adapter.ts
import { useTaskStore } from '../domains/task/store/taskStore';

// Adapter to expose Zustand store as Redux-like API
export class ZustandReduxAdapter {
  private store = useTaskStore;

  // Redux-like selectors
  selectTasks() {
    return this.store.getState().tasks;
  }

  selectLoading() {
    return this.store.getState().loading;
  }

  selectError() {
    return this.store.getState().error;
  }

  // Redux-like dispatch
  dispatch(action: { type: string; payload?: any }) {
    const state = this.store.getState();
    switch (action.type) {
      case 'tasks/add':
        state.addTask(action.payload);
        break;
      case 'tasks/toggle':
        state.toggleTask(action.payload);
        break;
      case 'tasks/delete':
        state.deleteTask(action.payload);
        break;
      case 'tasks/fetch':
        state.fetchTasks();
        break;
    }
  }

  // Connect to Redux DevTools
  connectDevTools() {
    // Zustand already has devtools support
  }
}

// === STEP-BY-STEP MIGRATION ===
// 1. Phase 1: Run both stores side by side with feature flags
// 2. Phase 2: Redirect component imports from Redux to Zustand
// 3. Phase 3: Remove Redux store and related code
```

### Step 4: Migration from Context API

```typescript
// src/migrations/context-to-zustand.ts

// === OLD CONTEXT API CODE ===
// src/context/TaskContext.tsx
import React, { createContext, useContext, useState, ReactNode } from 'react';

interface TaskContextType {
  tasks: Task[];
  loading: boolean;
  error: string | null;
  addTask: (task: Task) => void;
  toggleTask: (id: string) => void;
  deleteTask: (id: string) => void;
  fetchTasks: () => Promise<void>;
}

const TaskContext = createContext<TaskContextType | null>(null);

export function TaskProvider({ children }: { children: ReactNode }) {
  const [tasks, setTasks] = useState<Task[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const fetchTasks = async () => {
    setLoading(true);
    try {
      const response = await fetch('/api/tasks');
      const data = await response.json();
      setTasks(data);
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  const addTask = (task: Task) => {
    setTasks(prev => [...prev, task]);
  };

  const toggleTask = (id: string) => {
    setTasks(prev => prev.map(t =>
      t.id === id ? { ...t, completed: !t.completed } : t
    ));
  };

  const deleteTask = (id: string) => {
    setTasks(prev => prev.filter(t => t.id !== id));
  };

  return (
    <TaskContext.Provider value={{
      tasks, loading, error, addTask, toggleTask, deleteTask, fetchTasks,
    }}>
      {children}
    </TaskContext.Provider>
  );
}

export function useTasks() {
  const context = useContext(TaskContext);
  if (!context) throw new Error('useTasks must be used within TaskProvider');
  return context;
}

// === MIGRATION WRAPPER ===
// src/migrations/context-wrapper.tsx
'use client';

import React, { useEffect } from 'react';
import { useTaskStore } from '../domains/task/store/taskStore';
import { TaskContext } from '../context/TaskContext';

// This wrapper provides the Context API API while using Zustand internally
export function ZustandContextWrapper({ children }: { children: ReactNode }) {
  const store = useTaskStore();

  // Sync Zustand state with Context API
  const contextValue = {
    tasks: store.tasks,
    loading: store.loading,
    error: store.error,
    addTask: store.addTask,
    toggleTask: store.toggleTask,
    deleteTask: store.deleteTask,
    fetchTasks: store.fetchTasks,
  };

  // Migrate from Context to Zustand: Replace the Provider
  return (
    <TaskContext.Provider value={contextValue}>
      {children}
    </TaskContext.Provider>
  );
}

// === GRADUAL MIGRATION STRATEGY ===
// 1. Wrap Context Provider with Zustand wrapper
// 2. Update components to use Zustand directly one by one
// 3. Remove Context wrapper when all components are migrated

// Step 1: In app layout
<ZustandContextWrapper>
  <App />
</ZustandContextWrapper>

// Step 2: Component migrated to Zustand
function MigratedTaskList() {
  const tasks = useTaskStore((state) => state.tasks);
  // ...
}

// Step 3: Remove wrapper when all components are migrated
<App />
```

### Step 5: Feature Flag Migration

```typescript
// src/infrastructure/featureFlags/index.ts

export interface FeatureFlags {
  useZustandTasks: boolean;
  useZustandAuth: boolean;
  useZustandUsers: boolean;
  enablePerformanceMonitoring: boolean;
}

// Feature flag service
class FeatureFlagService {
  private flags: FeatureFlags = {
    useZustandTasks: false,
    useZustandAuth: false,
    useZustandUsers: false,
    enablePerformanceMonitoring: false,
  };

  constructor() {
    // Load from localStorage or remote config
    this.loadFromStorage();
  }

  private loadFromStorage() {
    try {
      const saved = localStorage.getItem('featureFlags');
      if (saved) {
        this.flags = { ...this.flags, ...JSON.parse(saved) };
      }
    } catch (error) {
      console.error('Failed to load feature flags:', error);
    }
  }

  getFlag<K extends keyof FeatureFlags>(key: K): FeatureFlags[K] {
    return this.flags[key];
  }

  setFlag<K extends keyof FeatureFlags>(key: K, value: FeatureFlags[K]) {
    this.flags[key] = value;
    localStorage.setItem('featureFlags', JSON.stringify(this.flags));
    // Dispatch event for other tabs
    window.dispatchEvent(new StorageEvent('storage', {
      key: 'featureFlags',
      newValue: JSON.stringify(this.flags),
    }));
  }

  // Toggle flags from browser console
  toggleFlag(key: keyof FeatureFlags) {
    const current = this.getFlag(key);
    this.setFlag(key, !current as any);
    console.log(`Feature flag ${key} is now ${!current}`);
    return !current;
  }
}

export const featureFlags = new FeatureFlagService();

// Expose to window for debugging
if (typeof window !== 'undefined') {
  (window as any).featureFlags = featureFlags;
}
```

```tsx
// src/components/FeatureFlagged.tsx
'use client';

import React, { ReactNode } from 'react';
import { featureFlags } from '../infrastructure/featureFlags';

interface FeatureFlaggedProps {
  flag: keyof FeatureFlags;
  children: ReactNode;
  fallback?: ReactNode;
}

export function FeatureFlagged({ flag, children, fallback = null }: FeatureFlaggedProps) {
  const [enabled, setEnabled] = React.useState(() => featureFlags.getFlag(flag));

  React.useEffect(() => {
    const handleStorage = () => {
      setEnabled(featureFlags.getFlag(flag));
    };
    window.addEventListener('storage', handleStorage);
    return () => window.removeEventListener('storage', handleStorage);
  }, [flag]);

  return enabled ? <>{children}</> : <>{fallback}</>;
}

// Example usage
function TaskList() {
  // Use Redux version by default, Zustand version when flag is on
  return (
    <>
      <FeatureFlagged flag="useZustandTasks" fallback={<ReduxTaskList />}>
        <ZustandTaskList />
      </FeatureFlagged>
    </>
  );
}
```

### Step 6: Performance Budget Testing

```typescript
// src/__tests__/performance/performanceBudget.test.ts
import { describe, it, expect } from 'vitest';
import { useTaskStore } from '../../domains/task/store/taskStore';

describe('Performance Budget', () => {
  it('should stay within state size budget', async () => {
    const store = useTaskStore.getState();
    await store.fetchTasks();

    const state = useTaskStore.getState();
    const stateSize = new Blob([JSON.stringify(state)]).size;
    const budget = 500 * 1024; // 500KB

    expect(stateSize).toBeLessThan(budget);
    console.log(`📦 State size: ${(stateSize / 1024).toFixed(1)}KB / ${(budget / 1024).toFixed(0)}KB`);
  });

  it('should stay within update time budget', () => {
    const store = useTaskStore.getState();
    
    const start = performance.now();
    store.addTask({ id: 'test', title: 'Test', completed: false });
    const duration = performance.now() - start;
    const budget = 10; // 10ms

    expect(duration).toBeLessThan(budget);
    console.log(`⏱️ Update time: ${duration.toFixed(2)}ms / ${budget}ms`);
  });

  it('should measure render impact of store changes', async () => {
    // This would require React Testing Library with Profiler
    // Example approach:
    const store = useTaskStore.getState();
    
    // Perform many updates and measure
    const start = performance.now();
    for (let i = 0; i < 100; i++) {
      store.addTask({ id: `test-${i}`, title: `Task ${i}`, completed: false });
    }
    const duration = performance.now() - start;
    
    const budget = 100; // 100ms for 100 updates
    expect(duration).toBeLessThan(budget);
    console.log(`⏱️ 100 updates: ${duration.toFixed(2)}ms / ${budget}ms`);
  });
});
```

### Step 7: Migration Script

```typescript
// src/scripts/migrate-to-zustand.ts
// Run with: npx ts-node src/scripts/migrate-to-zustand.ts

import fs from 'fs';
import path from 'path';

interface MigrationStats {
  filesAnalyzed: number;
  contextsFound: number;
  reduxImportsFound: number;
  filesWithFeatureFlags: number;
  estimatedMigrationDays: number;
}

function analyzeProject(): MigrationStats {
  const srcDir = path.join(process.cwd(), 'src');
  let filesAnalyzed = 0;
  let contextsFound = 0;
  let reduxImportsFound = 0;
  let filesWithFeatureFlags = 0;

  function walkDir(dir: string) {
    const files = fs.readdirSync(dir);
    for (const file of files) {
      const fullPath = path.join(dir, file);
      const stat = fs.statSync(fullPath);
      
      if (stat.isDirectory()) {
        walkDir(fullPath);
      } else if (file.endsWith('.ts') || file.endsWith('.tsx')) {
        filesAnalyzed++;
        const content = fs.readFileSync(fullPath, 'utf-8');
        
        if (content.includes('createContext') || content.includes('useContext')) {
          contextsFound++;
        }
        if (content.includes('@reduxjs/toolkit') || content.includes('createSlice')) {
          reduxImportsFound++;
        }
        if (content.includes('featureFlags') || content.includes('useFeatureFlag')) {
          filesWithFeatureFlags++;
        }
      }
    }
  }

  walkDir(srcDir);

  // Estimate migration effort
  const estimatedMigrationDays = Math.ceil(
    (contextsFound + reduxImportsFound) / 5
  );

  return {
    filesAnalyzed,
    contextsFound,
    reduxImportsFound,
    filesWithFeatureFlags,
    estimatedMigrationDays,
  };
}

function generateMigrationPlan(stats: MigrationStats) {
  console.log('\n📊 Migration Analysis Report');
  console.log('='.repeat(50));
  console.log(`Files analyzed: ${stats.filesAnalyzed}`);
  console.log(`Context API usages found: ${stats.contextsFound}`);
  console.log(`Redux imports found: ${stats.reduxImportsFound}`);
  console.log(`Files with feature flags: ${stats.filesWithFeatureFlags}`);
  console.log(`\nEstimated migration time: ${stats.estimatedMigrationDays} days`);
  
  console.log('\n📋 Recommended Migration Plan:');
  console.log('1. Set up feature flags (done: ✅)');
  console.log('2. Create Zustand stores for each domain');
  console.log('3. Create adapter wrappers for Redux/Context');
  console.log(`4. Migrate ${Math.ceil(stats.contextsFound / 3)} components per day from Context`);
  console.log(`5. Migrate ${Math.ceil(stats.reduxImportsFound / 3)} components per day from Redux`);
  console.log('6. Remove legacy code after all flags are rolled out');
  console.log('7. Clean up feature flags');
}

const stats = analyzeProject();
generateMigrationPlan(stats);

// Export for use in CI/CD
export { MigrationStats, analyzeProject };
```

---

## The Verification: Testing Performance Monitoring

### Step 1: Add Performance Dashboard to App

```tsx
// src/app/layout.tsx
import { PerformanceDashboard } from '../shared/components/PerformanceDashboard';

export default function RootLayout({ children }: { children: ReactNode }) {
  return (
    <html>
      <body>
        {children}
        {process.env.NODE_ENV === 'production' && <PerformanceDashboard />}
      </body>
    </html>
  );
}
```

### Step 2: Test Performance Monitoring

```typescript
// src/__tests__/performance/monitoring.test.ts
import { describe, it, expect, vi } from 'vitest';
import { createPerformanceMonitor } from '../../shared/store/middleware/performanceMonitor';
import { create } from 'zustand';

describe('Performance Monitoring', () => {
  it('should track performance metrics', () => {
    const metrics: any[] = [];
    
    const useTestStore = create(
      createPerformanceMonitor({
        enabled: true,
        sampleRate: 1.0,
        onMetric: (metric) => metrics.push(metric),
        slowUpdateThreshold: 1,
        onSlowUpdate: (metric) => {
          console.log('Slow update detected');
        },
      })((set) => ({
        data: [],
        addData: (item) => set((state) => ({ data: [...state.data, item] })),
      }))
    );

    useTestStore.getState().addData('test');

    expect(metrics).toHaveLength(1);
    expect(metrics[0].action).toBe('functional');
    expect(metrics[0].stateSize).toBeGreaterThan(0);
  });
});
```

### Step 3: Verify Migration

```bash
# Run migration analysis
npx ts-node src/scripts/migrate-to-zustand.ts

# Expected output:
# 📊 Migration Analysis Report
# Files analyzed: 245
# Context API usages found: 12
# Redux imports found: 8
# Files with feature flags: 5
# Estimated migration time: 4 days
```

---

## Deep Dive: Migration Strategies

### Strategy 1: Strangler Fig Pattern

The Strangler Fig pattern replaces legacy code incrementally by intercepting calls and routing them to new implementations.

```
┌─────────────────────────────────────────────────────────────────┐
│                    STRANGLER FIG PATTERN                       │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Existing Code (Redux/Context)                          │  │
│  │  • Working but being replaced                          │  │
│  └──────────────────────────────────────────────────────────┘  │
│                         │                                      │
│                         ▼                                      │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Adapter Layer                                          │  │
│  │  • Routes to legacy or new based on feature flags       │  │
│  │  • Provides same API for both                          │  │
│  └──────────────────────────────────────────────────────────┘  │
│                         │                                      │
│            ┌────────────┼────────────┐                        │
│            │            │            │                        │
│            ▼            ▼            ▼                        │
│  ┌──────────────────┐ ┌──────────────┐ ┌──────────────────┐ │
│  │  Feature Flag A  │ │  Feature Flag│ │  Feature Flag C  │ │
│  │  (Zustand)       │ │  B (Zustand) │ │  (Redux)         │ │
│  └──────────────────┘ └──────────────┘ └──────────────────┘ │
│                                                                 │
│  Result: Incrementally replace code with zero downtime          │
└─────────────────────────────────────────────────────────────────┘
```

### Strategy 2: Branch by Abstraction

Create an abstraction layer that hides the implementation details:

```typescript
// Abstraction
interface TaskRepository {
  getTasks(): Promise<Task[]>;
  addTask(task: Task): Promise<Task>;
  updateTask(id: string, updates: Partial<Task>): Promise<Task>;
  deleteTask(id: string): Promise<void>;
}

// Redux implementation
class ReduxTaskRepository implements TaskRepository {
  async getTasks() {
    const state = store.getState();
    return state.tasks;
  }
  // ...
}

// Zustand implementation
class ZustandTaskRepository implements TaskRepository {
  async getTasks() {
    return useTaskStore.getState().tasks;
  }
  // ...
}

// Factory
class TaskRepositoryFactory {
  static create(useZustand: boolean): TaskRepository {
    return useZustand ? new ZustandTaskRepository() : new ReduxTaskRepository();
  }
}
```

### Strategy 3: Rollback Strategy

Always have a rollback plan:

```typescript
// src/infrastructure/rollback/rollbackManager.ts
export class RollbackManager {
  private snapshots: Map<string, any> = new Map();
  private currentStore: string = 'legacy';

  takeSnapshot(storeKey: string): void {
    const state = useTaskStore.getState();
    this.snapshots.set(storeKey, JSON.stringify(state));
  }

  restoreSnapshot(storeKey: string): void {
    const snapshot = this.snapshots.get(storeKey);
    if (snapshot) {
      const state = JSON.parse(snapshot);
      useTaskStore.setState(state);
    }
  }

  switchToZustand(): void {
    this.takeSnapshot('pre-migration');
    this.currentStore = 'zustand';
  }

  rollbackToLegacy(): void {
    this.restoreSnapshot('pre-migration');
    this.currentStore = 'legacy';
  }
}
```

---

## Common Pitfalls and Solutions

### Pitfall 1: No Rollback Strategy

```typescript
// ❌ BAD: No rollback if migration fails
await migrateToZustand();

// ✅ GOOD: Always have rollback capability
try {
  await migrateToZustand();
} catch (error) {
  console.error('Migration failed, rolling back:', error);
  await rollbackToLegacy();
}
```

### Pitfall 2: Not Measuring Before/After Performance

```typescript
// ❌ BAD: Migrating without measuring impact
// Just migrate and hope for the best

// ✅ GOOD: Measure before and after
// Before migration
const beforeMetrics = await runPerformanceTest();

// Run migration

// After migration
const afterMetrics = await runPerformanceTest();
console.log(`Performance change: ${((afterMetrics - beforeMetrics) / beforeMetrics * 100).toFixed(1)}%`);
```

### Pitfall 3: Migrating All at Once

```typescript
// ❌ BAD: Big bang migration
// All code changed at once → high risk

// ✅ GOOD: Incremental migration
// 1. One store at a time
// 2. One component at a time
// 3. Feature flags toggled gradually
```

---

## Performance Monitoring Checklist

- [ ] Performance monitoring middleware installed
- [ ] Slow update thresholds configured
- [ ] State size budgets defined
- [ ] Remote logging endpoint configured
- [ ] Performance dashboard component created
- [ ] Performance budgets defined in tests
- [ ] Alerts configured for threshold violations
- [ ] Memory monitoring enabled (where available)

## Migration Checklist

- [ ] Feature flags implemented for all stores
- [ ] Adapter layer created for Redux/Context
- [ ] Rollback strategy defined
- [ ] Performance measured before migration
- [ ] Migration planned incrementally
- [ ] Each domain migrated separately
- [ ] Components migrated gradually
- [ ] Feature flags rolled out in phases
- [ ] Legacy code cleaned up after successful migration
- [ ] Documentation updated for new architecture

---

## Key Takeaways

1. **Monitor performance** in production with custom middleware
2. **Set budgets** for state size and update time
3. **Feature flags** enable safe, incremental migrations
4. **Adapters** allow co-existing old and new code
5. **Strangler fig pattern** replaces code incrementally
6. **Rollback strategy** is essential for safe migrations
7. **Measure before and after** to validate improvements
8. **Incremental migration** reduces risk
9. **Documentation** helps teams understand the new architecture
10. **Testing** ensures performance budget compliance

---

## What's Next

You've mastered performance monitoring and migration strategies. Next, you'll learn about anti-patterns and common pitfalls to avoid in production Zustand applications.
