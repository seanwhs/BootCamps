# Part 4 — Performance Optimization

## Section 16: Rendering Optimization

You've built stores, handled async workflows, and added middleware. Now it's time to make your application fly. Performance optimization in Zustand is about being smart about what components subscribe to and when they re-render. In this section, you'll master the art of fine-grained subscriptions, selector optimization, and rendering efficiency.

---

## The Target: Lightning-Fast Rendering

By the end of this section, you'll be able to:
- Implement fine-grained subscriptions to prevent unnecessary re-renders
- Optimize selectors for maximum performance
- Use shallow equality comparisons effectively
- Implement memoization strategies for expensive computations
- Avoid common over-subscription anti-patterns
- Profile and measure render performance

---

## The Concept: Rendering as Selective Listening

Think of rendering optimization like a **smart notification system**:

```
┌─────────────────────────────────────────────────────────────────┐
│                    RENDERING OPTIMIZATION                      │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  ZUSTAND STORE                                          │  │
│  │  {                                                      │  │
│  │    user: { name: 'Alice', email: 'alice@example.com' },│  │
│  │    tasks: [ { id: 1, text: 'Task 1' }, ... ],        │  │
│  │    theme: 'dark',                                     │  │
│  │    notifications: [ ... ]                             │  │
│  │  }                                                    │  │
│  └──────────────────────────────────────────────────────────┘  │
│                         │                                      │
│            ┌────────────┼────────────┐                        │
│            │            │            │                        │
│            ▼            ▼            ▼                        │
│  ┌──────────────────┐ ┌──────────────┐ ┌──────────────────┐ │
│  │  Component A     │ │  Component B │ │  Component C     │ │
│  │  Subscribes to   │ │  Subscribes  │ │  Subscribes to   │ │
│  │  user.name       │ │  to tasks    │ │  to theme        │ │
│  │  ONLY            │ │  ONLY        │ │  ONLY            │ │
│  └──────────────────┘ └──────────────┘ └──────────────────┘ │
│         │                    │                    │         │
│         ▼                    ▼                    ▼         │
│  ✅ Re-renders when    ✅ Re-renders when    ✅ Re-renders   │
│     user.name changes     tasks change        when theme    │
│                                                 changes     │
│                                                                 │
│  ❌ BAD: Components that subscribe to everything               │
│     Re-render on ANY state change                              │
└─────────────────────────────────────────────────────────────────┘
```

**Key Principle**: Components should subscribe to the minimum amount of state they need to render. When state changes, only components that depend on the changed state should re-render.

---

## The Implementation: Rendering Optimization Techniques

### Step 1: Fine-Grained Subscriptions

The most important optimization is subscribing only to what you need:

```typescript
// ❌ BAD: Subscribing to the entire store
function BadComponent() {
  const store = useTaskStore(); // Everything!
  // Re-renders when ANY state changes
  return <div>{store.tasks.length}</div>;
}

// ✅ GOOD: Subscribe only to what you need
function GoodComponent() {
  const taskCount = useTaskStore((state) => state.tasks.length);
  // Re-renders only when tasks.length changes
  return <div>{taskCount}</div>;
}

// ✅ BEST: Multiple independent subscriptions
function BestComponent() {
  const taskCount = useTaskStore((state) => state.tasks.length);
  const completedCount = useTaskStore(
    (state) => state.tasks.filter(t => t.completed).length
  );
  // Each subscription is independent
  // taskCount re-renders only when length changes
  // completedCount re-renders only when completed count changes
  return (
    <div>
      Total: {taskCount}, Completed: {completedCount}
    </div>
  );
}
```

### Step 2: Using `shallow` for Object Selectors

When you need multiple pieces of state, use the `shallow` utility to prevent unnecessary re-renders:

```typescript
import { create } from 'zustand';
import { useShallow } from 'zustand/react/shallow';

interface UserStore {
  user: { name: string; email: string; age: number };
  settings: { theme: 'light' | 'dark'; language: string };
}

const useUserStore = create<UserStore>((set) => ({
  user: { name: 'Alice', email: 'alice@example.com', age: 30 },
  settings: { theme: 'light', language: 'en' },
  setUser: (updates) => set((state) => ({
    user: { ...state.user, ...updates }
  })),
  setSettings: (updates) => set((state) => ({
    settings: { ...state.settings, ...updates }
  })),
}));

// ❌ BAD: Creates a new object on every render
function BadProfile() {
  const { user, settings } = useUserStore((state) => ({
    user: state.user,
    settings: state.settings,
  }));
  // Re-renders when ANY state changes (user OR settings)
  // Even if user/settings haven't changed, the object reference is new
  return <div>{user.name} - {settings.theme}</div>;
}

// ✅ GOOD: Uses shallow comparison
import { useShallow } from 'zustand/react/shallow';

function GoodProfile() {
  const { user, settings } = useUserStore(
    useShallow((state) => ({
      user: state.user,
      settings: state.settings,
    }))
  );
  // Only re-renders when user OR settings actually change
  return <div>{user.name} - {settings.theme}</div>;
}

// ✅ ALTERNATIVE: Multiple selectors (most performant)
function BestProfile() {
  const name = useUserStore((state) => state.user.name);
  const theme = useUserStore((state) => state.settings.theme);
  // Each subscription is independent
  // Only re-renders when name or theme changes
  return <div>{name} - {theme}</div>;
}
```

### Step 3: Optimizing Selectors with `useMemo`

For expensive selectors, memoize the result:

```tsx
import { useMemo } from 'react';
import { useTaskStore } from '../store/taskStore';

function TaskStats() {
  // Get raw data
  const tasks = useTaskStore((state) => state.tasks);
  const filter = useTaskStore((state) => state.filter);
  const searchQuery = useTaskStore((state) => state.searchQuery);

  // Memoize expensive computations
  const filteredTasks = useMemo(() => {
    let result = tasks;
    if (filter === 'active') {
      result = result.filter(t => !t.completed);
    } else if (filter === 'completed') {
      result = result.filter(t => t.completed);
    }
    if (searchQuery.trim()) {
      const query = searchQuery.toLowerCase().trim();
      result = result.filter(t => t.text.toLowerCase().includes(query));
    }
    return result;
  }, [tasks, filter, searchQuery]);

  // Memoize computed stats
  const stats = useMemo(() => ({
    total: tasks.length,
    completed: tasks.filter(t => t.completed).length,
    active: tasks.filter(t => !t.completed).length,
    filtered: filteredTasks.length,
  }), [tasks, filteredTasks]);

  return (
    <div>
      <div>Total: {stats.total}</div>
      <div>Completed: {stats.completed}</div>
      <div>Active: {stats.active}</div>
      <div>Filtered: {stats.filtered}</div>
    </div>
  );
}
```

### Step 4: Creating Reusable Memoized Selectors

For complex applications, create reusable selectors with `reselect`:

```typescript
// src/store/selectors/taskSelectors.ts
import { createSelector } from 'reselect';
import { useTaskStore } from '../store/taskStore';

// Base selectors
const selectTasks = (state: ReturnType<typeof useTaskStore.getState>) => state.tasks;
const selectFilter = (state: ReturnType<typeof useTaskStore.getState>) => state.filter;
const selectSearch = (state: ReturnType<typeof useTaskStore.getState>) => state.searchQuery;

// Memoized selector: filtered tasks
export const selectFilteredTasks = createSelector(
  [selectTasks, selectFilter, selectSearch],
  (tasks, filter, search) => {
    console.log('Computing filtered tasks...'); // Only runs when dependencies change
    let result = tasks;
    if (filter === 'active') result = result.filter(t => !t.completed);
    if (filter === 'completed') result = result.filter(t => t.completed);
    if (search.trim()) {
      const query = search.toLowerCase().trim();
      result = result.filter(t => t.text.toLowerCase().includes(query));
    }
    return result;
  }
);

// Memoized selector: task statistics
export const selectTaskStats = createSelector(
  [selectTasks],
  (tasks) => {
    console.log('Computing task stats...');
    return {
      total: tasks.length,
      completed: tasks.filter(t => t.completed).length,
      active: tasks.filter(t => !t.completed).length,
    };
  }
);

// Memoized selector: tasks by priority
export const selectTasksByPriority = createSelector(
  [selectTasks],
  (tasks) => {
    console.log('Computing tasks by priority...');
    const groups: Record<string, Task[]> = { low: [], medium: [], high: [] };
    for (const task of tasks) {
      groups[task.priority].push(task);
    }
    return groups;
  }
);

// Usage in component
import { selectFilteredTasks } from '../store/selectors/taskSelectors';

function TaskList() {
  const filteredTasks = useTaskStore(selectFilteredTasks);
  // Only re-renders when filtered tasks change
  return (
    <ul>
      {filteredTasks.map(task => (
        <li key={task.id}>{task.text}</li>
      ))}
    </ul>
  );
}
```

### Step 5: Avoiding Over-Subscription in Lists

When rendering lists, each item should subscribe independently:

```tsx
// ❌ BAD: Parent subscribes and passes data down
function BadTaskList() {
  const tasks = useTaskStore((state) => state.tasks);
  // Every task change re-renders ALL children
  return tasks.map(task => <BadTaskItem key={task.id} task={task} />);
}
function BadTaskItem({ task }: { task: Task }) {
  return <div>{task.text}</div>;
}

// ✅ GOOD: Each item subscribes independently
function GoodTaskList() {
  const taskIds = useTaskStore((state) => state.taskIds);
  // Only re-renders when the list of IDs changes
  return taskIds.map(id => <GoodTaskItem key={id} taskId={id} />);
}
function GoodTaskItem({ taskId }: { taskId: string }) {
  // Each item subscribes ONLY to its own task
  const task = useTaskStore((state) => state.tasks[taskId]);
  // Only re-renders when THIS task changes
  return <div>{task.text}</div>;
}

// ✅ EVEN BETTER: With memoization
import React, { memo } from 'react';
const MemoizedTaskItem = memo(({ taskId }: { taskId: string }) => {
  const task = useTaskStore((state) => state.tasks[taskId]);
  return <div>{task.text}</div>;
});
```

### Step 6: Using `React.memo` with Zustand Stores

Combine `React.memo` with Zustand selectors for maximum performance:

```tsx
import React, { memo } from 'react';
import { useTaskStore } from '../store/taskStore';

// Memoized component that only re-renders when its specific data changes
const TaskItem = memo(({ taskId }: { taskId: string }) => {
  // Each component subscribes independently
  const task = useTaskStore((state) => state.tasks[taskId]);
  const toggleTask = useTaskStore((state) => state.toggleTask);
  const deleteTask = useTaskStore((state) => state.deleteTask);

  return (
    <li>
      <input
        type="checkbox"
        checked={task.completed}
        onChange={() => toggleTask(taskId)}
      />
      <span style={{ textDecoration: task.completed ? 'line-through' : 'none' }}>
        {task.text}
      </span>
      <button onClick={() => deleteTask(taskId)}>Delete</button>
    </li>
  );
});

// Parent component
function TaskList() {
  const taskIds = useTaskStore((state) => state.taskIds);
  return (
    <ul>
      {taskIds.map(id => <TaskItem key={id} taskId={id} />)}
    </ul>
  );
}
```

### Step 7: Combining Stores for Better Organization

Instead of a single large store, use multiple stores to limit subscriptions:

```typescript
// Separate stores for different domains
const useUserStore = create((set) => ({
  user: null,
  setUser: (user) => set({ user }),
}));

const useTaskStore = create((set) => ({
  tasks: [],
  addTask: (task) => set((state) => ({ tasks: [...state.tasks, task] })),
}));

const useUIStore = create((set) => ({
  theme: 'light',
  toggleTheme: () => set((state) => ({ theme: state.theme === 'light' ? 'dark' : 'light' })),
}));

// In components - only subscribe to the store they need
function UserProfile() {
  const user = useUserStore((state) => state.user);
  // Only re-renders when user changes
  return <div>{user?.name}</div>;
}

function TaskList() {
  const tasks = useTaskStore((state) => state.tasks);
  // Only re-renders when tasks change
  return tasks.map(task => <div key={task.id}>{task.text}</div>);
}
```

### Step 8: Using `subscribeWithSelector` for Side Effects

The `subscribeWithSelector` middleware enables selective subscriptions outside React:

```typescript
import { create } from 'zustand';
import { subscribeWithSelector } from 'zustand/middleware';

const useDataStore = create(
  subscribeWithSelector((set) => ({
    data: [],
    loading: false,
    error: null,
    fetchData: async () => {
      set({ loading: true });
      // ...
    },
  }))
);

// Subscribe only to loading state
const unsubscribeLoading = useDataStore.subscribe(
  (state) => state.loading,
  (loading) => {
    console.log('Loading status changed:', loading);
    if (loading) {
      // Show loading spinner
    } else {
      // Hide loading spinner
    }
  }
);

// Subscribe only to data changes
const unsubscribeData = useDataStore.subscribe(
  (state) => state.data,
  (data) => {
    console.log('Data changed, count:', data.length);
    // Update something else
  }
);

// Subscribe with equality check
const unsubscribeError = useDataStore.subscribe(
  (state) => state.error,
  (error) => {
    if (error) {
      console.error('Error occurred:', error);
    }
  },
  // Only trigger if error actually changed
  (a, b) => a === b
);

// Clean up
unsubscribeLoading();
unsubscribeData();
unsubscribeError();
```

---

## The Verification: Measuring Performance

### Step 1: Add Render Counters

Add a simple render counter to see when components re-render:

```tsx
// src/components/RenderCounter.tsx
import React, { useRef } from 'react';

export function RenderCounter({ name }: { name: string }) {
  const renderCount = useRef(0);
  renderCount.current += 1;

  return (
    <span style={{ fontSize: '12px', color: '#999' }}>
      {name}: {renderCount.current} renders
    </span>
  );
}

// Usage in components
function TaskItem({ taskId }: { taskId: string }) {
  const task = useTaskStore((state) => state.tasks[taskId]);
  return (
    <div>
      {task.text}
      <RenderCounter name="TaskItem" />
    </div>
  );
}
```

### Step 2: Use React Profiler

```tsx
// Wrap your app with Profiler
import { Profiler } from 'react';

function App() {
  return (
    <Profiler id="App" onRender={onRenderCallback}>
      <MainApp />
    </Profiler>
  );
}

function onRenderCallback(
  id: string,
  phase: 'mount' | 'update' | 'nested-update',
  actualDuration: number,
  baseDuration: number,
  startTime: number,
  commitTime: number,
  interactions: Set<any>
) {
  console.log(`${id} ${phase} took ${actualDuration.toFixed(2)}ms`);
  if (actualDuration > 5) {
    console.warn(`Slow render: ${id} took ${actualDuration.toFixed(2)}ms`);
  }
}
```

### Step 3: Create a Performance Dashboard

Build a component that shows real-time performance metrics:

```tsx
// src/components/PerformanceDashboard.tsx
import React, { useState, useEffect } from 'react';

interface Metric {
  name: string;
  renderCount: number;
  lastRenderTime: number;
}

export function PerformanceDashboard() {
  const [metrics, setMetrics] = useState<Record<string, Metric>>({});

  useEffect(() => {
    // Collect metrics from components
    const interval = setInterval(() => {
      // In real implementation, collect from a global registry
    }, 1000);
    return () => clearInterval(interval);
  }, []);

  return (
    <div style={{ position: 'fixed', bottom: 0, right: 0, background: '#333', color: '#fff', padding: '10px', fontSize: '12px' }}>
      <h4>Performance Dashboard</h4>
      {Object.entries(metrics).map(([name, metric]) => (
        <div key={name}>
          {name}: {metric.renderCount} renders (last: {metric.lastRenderTime}ms)
        </div>
      ))}
    </div>
  );
}
```

### Step 4: Performance Test Script

```typescript
// src/tests/performanceTest.ts
import { useTaskStore } from '../store/taskStore';

export function runPerformanceTest() {
  console.log('=== Running Performance Test ===');
  
  const store = useTaskStore.getState();
  
  // Add many tasks
  console.time('Add 1000 tasks');
  for (let i = 0; i < 1000; i++) {
    store.addTask({ id: `task-${i}`, text: `Task ${i}`, completed: false });
  }
  console.timeEnd('Add 1000 tasks');
  
  // Toggle all tasks
  console.time('Toggle 1000 tasks');
  const taskIds = store.taskIds;
  for (const id of taskIds) {
    store.toggleTask(id);
  }
  console.timeEnd('Toggle 1000 tasks');
  
  // Measure render counts (would need to instrument components)
  console.log('Check render counts in the console');
}
```

### Step 5: Browser DevTools Tips

1. **React DevTools**:
   - Enable "Highlight updates when components render"
   - Watch for components that render unnecessarily
   - Check the "Profiler" tab for performance flame graphs

2. **Chrome Performance Tab**:
   - Record a performance profile
   - Look for long-running JavaScript tasks
   - Check for layout thrashing

3. **Redux DevTools**:
   - Observe actions and state changes
   - Check for unnecessary state updates

---

## Deep Dive: Performance Anti-Patterns

### Anti-Pattern 1: Deriving State in Selectors Without Memoization

```typescript
// ❌ BAD: Creates new array on every render
const activeTasks = useTaskStore((state) => 
  state.tasks.filter(t => !t.completed)
);

// ✅ GOOD: Memoize the result
const tasks = useTaskStore((state) => state.tasks);
const activeTasks = useMemo(() => 
  tasks.filter(t => !t.completed),
  [tasks]
);
```

### Anti-Pattern 2: Creating New Objects in Selectors

```typescript
// ❌ BAD: New object on every render
const { tasks, loading } = useTaskStore((state) => ({
  tasks: state.tasks,
  loading: state.loading,
}));

// ✅ GOOD: Use shallow
const { tasks, loading } = useTaskStore(
  useShallow((state) => ({
    tasks: state.tasks,
    loading: state.loading,
  }))
);

// ✅ BEST: Separate selectors
const tasks = useTaskStore((state) => state.tasks);
const loading = useTaskStore((state) => state.loading);
```

### Anti-Pattern 3: Inline Functions in Selectors

```typescript
// ❌ BAD: New function on every render
const activeTasks = useTaskStore((state) => 
  state.tasks.filter(t => !t.completed).sort((a, b) => a.text.localeCompare(b.text))
);

// ✅ GOOD: Extract to memoized selector
const selectActiveTasks = createSelector(
  [(state) => state.tasks],
  (tasks) => tasks.filter(t => !t.completed).sort((a, b) => a.text.localeCompare(b.text))
);
const activeTasks = useTaskStore(selectActiveTasks);
```

### Anti-Pattern 4: Subscribing to Everything

```typescript
// ❌ BAD: Re-renders on every state change
function BadComponent() {
  const store = useTaskStore();
  return <div>{store.tasks.length}</div>;
}

// ✅ GOOD: Subscribe only to what's needed
function GoodComponent() {
  const count = useTaskStore((state) => state.tasks.length);
  return <div>{count}</div>;
}
```

---

## Performance Optimization Checklist

- [ ] Each component subscribes only to the state it needs
- [ ] List items subscribe independently (not through parent)
- [ ] `React.memo` used for expensive components
- [ ] Expensive selectors are memoized with `useMemo` or `reselect`
- [ ] `useShallow` used for object selectors
- [ ] No inline functions in selectors
- [ ] Components with multiple subscriptions use separate selectors
- [ ] Stores are split by domain to limit subscriptions
- [ ] Render counters added for performance monitoring
- [ ] React Profiler used to identify slow components
- [ ] No unnecessary state updates (batched where possible)

---

## Key Takeaways

1. **Subscribe minimally**: Components should only subscribe to the state they need
2. **Use `useShallow`**: For object selectors to prevent unnecessary re-renders
3. **Memoize selectors**: Use `useMemo` or `reselect` for expensive computations
4. **Independent list items**: Each item should subscribe to its own data
5. **Split stores**: Multiple smaller stores limit subscription scope
6. **Use `React.memo`**: For expensive components that receive props
7. **Avoid inline functions**: Extract selectors to avoid recreating them
8. **Profile regularly**: Use React DevTools and Profiler to catch issues
9. **Batch updates**: Group state changes to reduce render cycles
10. **Monitor render counts**: Track which components re-render and why

---

## What's Next

Now that you've mastered rendering optimization, the next section will dive into store design patterns for performance—normalization, splitting stores, lazy initialization, and memory management.
