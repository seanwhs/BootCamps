# Part 2 — Advanced State Architecture

## Section 11: Derived & Computed State

You've learned how to manage raw state. But often, you need to display transformed versions of that state—filtered lists, aggregated statistics, or cross‑store calculations. Zustand makes it easy to compute derived values efficiently. In this section, you'll learn how to create derived and computed state that stays in sync with your base state, without unnecessary re‑computations.

---

## The Target: Efficient Derived State

By the end of this section, you'll be able to:
- Implement computed properties inside your Zustand stores
- Use memoized selectors to avoid expensive recalculations
- Derive collections (filtered, sorted, grouped) from raw data
- Compute cross‑store values that depend on multiple slices
- Normalize state for easier querying and updates

---

## The Concept: Derived State as a View on Data

Think of derived state like a **reporting dashboard** on top of raw data:

```
┌─────────────────────────────────────────────────────────────────┐
│                    STATE & DERIVATIONS                         │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  RAW STATE (Source of Truth)                            │  │
│  │  • tasks: [{id, text, completed, priority, dueDate}]    │  │
│  │  • filter: 'active'                                     │  │
│  │  • search: 'project'                                    │  │
│  └──────────────────────────────────────────────────────────┘  │
│                         │                                      │
│                         ▼                                      │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  DERIVED STATE (Computed on the fly)                    │  │
│  │  • filteredTasks: tasks that match filter & search      │  │
│  │  • stats: { total, completed, active, overdue }         │  │
│  │  • groupByPriority: { high: [...], medium: [...], low: [...] } │
│  └──────────────────────────────────────────────────────────┘  │
│                         │                                      │
│                         ▼                                      │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  COMPONENTS (Subscribe to derived state)                │  │
│  │  • TaskList uses filteredTasks                           │  │
│  │  • StatsDashboard uses stats                             │  │
│  │  • PriorityGroups uses groupByPriority                   │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

**Key Principle**: Derived state should be computed from raw state, never stored separately. This prevents duplication and keeps your store consistent.

---

## The Implementation: Derived State in Zustand

### Step 1: Basic Computed Properties

The simplest way to derive state is to define functions that use `get()`:

```typescript
// src/store/computedStore.ts
import { create } from 'zustand';

interface Task {
  id: string;
  text: string;
  completed: boolean;
  priority: 'low' | 'medium' | 'high';
  dueDate: Date | null;
  tags: string[];
}

interface ComputedStore {
  // Raw state
  tasks: Task[];
  filter: 'all' | 'active' | 'completed';
  searchQuery: string;
  
  // Actions
  addTask: (task: Task) => void;
  toggleTask: (id: string) => void;
  setFilter: (filter: 'all' | 'active' | 'completed') => void;
  setSearchQuery: (query: string) => void;
  
  // Computed properties (using get())
  getFilteredTasks: () => Task[];
  getStats: () => { total: number; completed: number; active: number };
  getPriorityCounts: () => Record<string, number>;
  getOverdueTasks: () => Task[];
}

export const useComputedStore = create<ComputedStore>((set, get) => ({
  tasks: [],
  filter: 'all',
  searchQuery: '',
  
  // --- Actions ---
  addTask: (task) => set((state) => ({ tasks: [...state.tasks, task] })),
  toggleTask: (id) => set((state) => ({
    tasks: state.tasks.map(t => t.id === id ? { ...t, completed: !t.completed } : t)
  })),
  setFilter: (filter) => set({ filter }),
  setSearchQuery: (searchQuery) => set({ searchQuery }),
  
  // --- Computed: Filtered tasks ---
  getFilteredTasks: () => {
    const state = get();
    let tasks = state.tasks;
    
    // Apply filter
    if (state.filter === 'active') {
      tasks = tasks.filter(t => !t.completed);
    } else if (state.filter === 'completed') {
      tasks = tasks.filter(t => t.completed);
    }
    
    // Apply search query
    if (state.searchQuery.trim()) {
      const query = state.searchQuery.toLowerCase().trim();
      tasks = tasks.filter(t => t.text.toLowerCase().includes(query));
    }
    
    return tasks;
  },
  
  // --- Computed: Stats ---
  getStats: () => {
    const tasks = get().tasks;
    return {
      total: tasks.length,
      completed: tasks.filter(t => t.completed).length,
      active: tasks.filter(t => !t.completed).length,
    };
  },
  
  // --- Computed: Priority counts ---
  getPriorityCounts: () => {
    const tasks = get().tasks;
    const counts: Record<string, number> = { low: 0, medium: 0, high: 0 };
    for (const task of tasks) {
      counts[task.priority] = (counts[task.priority] || 0) + 1;
    }
    return counts;
  },
  
  // --- Computed: Overdue tasks (dueDate in past) ---
  getOverdueTasks: () => {
    const now = new Date();
    return get().tasks.filter(t => t.dueDate && t.dueDate < now && !t.completed);
  },
}));
```

### Step 2: Memoized Selectors with `useMemo` in Components

While computed functions are fine for simple derivations, expensive calculations should be memoized:

```tsx
// src/components/TaskDashboard.tsx
import React, { useMemo } from 'react';
import { useComputedStore } from '../store/computedStore';

function TaskDashboard() {
  // Subscribe to raw state and actions
  const tasks = useComputedStore((state) => state.tasks);
  const filter = useComputedStore((state) => state.filter);
  const searchQuery = useComputedStore((state) => state.searchQuery);
  const setFilter = useComputedStore((state) => state.setFilter);
  const setSearchQuery = useComputedStore((state) => state.setSearchQuery);
  
  // Memoized derived values
  const filteredTasks = useMemo(() => {
    let result = tasks;
    if (filter === 'active') result = result.filter(t => !t.completed);
    if (filter === 'completed') result = result.filter(t => t.completed);
    if (searchQuery.trim()) {
      const query = searchQuery.toLowerCase().trim();
      result = result.filter(t => t.text.toLowerCase().includes(query));
    }
    return result;
  }, [tasks, filter, searchQuery]);
  
  const stats = useMemo(() => ({
    total: tasks.length,
    completed: tasks.filter(t => t.completed).length,
    active: tasks.filter(t => !t.completed).length,
  }), [tasks]);
  
  const priorityCounts = useMemo(() => {
    const counts = { low: 0, medium: 0, high: 0 };
    for (const task of tasks) {
      counts[task.priority] = (counts[task.priority] || 0) + 1;
    }
    return counts;
  }, [tasks]);

  return (
    <div>
      {/* Stats */}
      <div>Total: {stats.total}</div>
      <div>Completed: {stats.completed}</div>
      <div>Active: {stats.active}</div>
      <div>High Priority: {priorityCounts.high}</div>
      
      {/* Filters */}
      <button onClick={() => setFilter('all')}>All</button>
      <button onClick={() => setFilter('active')}>Active</button>
      <button onClick={() => setFilter('completed')}>Completed</button>
      <input
        type="text"
        value={searchQuery}
        onChange={(e) => setSearchQuery(e.target.value)}
        placeholder="Search..."
      />
      
      {/* Task list */}
      <ul>
        {filteredTasks.map(task => (
          <li key={task.id}>{task.text}</li>
        ))}
      </ul>
    </div>
  );
}
```

### Step 3: Memoized Selectors with `reselect` or `createSelector`

For more advanced memoization across multiple pieces of state, use `reselect`:

```typescript
// src/store/selectors.ts
import { createSelector } from 'reselect';
import { useComputedStore } from './computedStore';

// Selectors for raw state
const selectTasks = (state: ReturnType<typeof useComputedStore.getState>) => state.tasks;
const selectFilter = (state: ReturnType<typeof useComputedStore.getState>) => state.filter;
const selectSearch = (state: ReturnType<typeof useComputedStore.getState>) => state.searchQuery;

// Memoized selector: filtered tasks
export const selectFilteredTasks = createSelector(
  [selectTasks, selectFilter, selectSearch],
  (tasks, filter, search) => {
    let result = tasks;
    if (filter === 'active') result = result.filter(t => !t.completed);
    if (filter === 'completed') result = result.filter(t => t.completed);
    if (search.trim()) {
      const q = search.toLowerCase().trim();
      result = result.filter(t => t.text.toLowerCase().includes(q));
    }
    return result;
  }
);

// Memoized selector: stats
export const selectStats = createSelector(
  [selectTasks],
  (tasks) => ({
    total: tasks.length,
    completed: tasks.filter(t => t.completed).length,
    active: tasks.filter(t => !t.completed).length,
  })
);

// Memoized selector: tasks grouped by priority
export const selectTasksByPriority = createSelector(
  [selectTasks],
  (tasks) => {
    const groups: Record<string, Task[]> = { low: [], medium: [], high: [] };
    for (const task of tasks) {
      groups[task.priority].push(task);
    }
    return groups;
  }
);

// Usage in component
function TaskStats() {
  const stats = useComputedStore(selectStats);
  return <div>Completed: {stats.completed}</div>;
}
```

### Step 4: Cross‑Store Computations

When you have multiple stores, you may need to compute values that depend on both:

```typescript
// src/store/crossStore.ts
import { create } from 'zustand';

// User store
interface UserStore {
  users: Record<string, { name: string; role: string }>;
  fetchUsers: () => Promise<void>;
}
export const useUserStore = create<UserStore>((set) => ({
  users: {},
  fetchUsers: async () => {
    const response = await fetch('/api/users');
    const users = await response.json();
    set({ users });
  },
}));

// Task store (with assignee IDs)
interface TaskStore {
  tasks: Task[];
  fetchTasks: () => Promise<void>;
  // Computed: tasks with assignee names (cross-store)
  getTasksWithAssignees: () => Array<Task & { assigneeName?: string }>;
}
export const useTaskStore = create<TaskStore>((set, get) => ({
  tasks: [],
  fetchTasks: async () => {
    const response = await fetch('/api/tasks');
    const tasks = await response.json();
    set({ tasks });
  },
  getTasksWithAssignees: () => {
    const tasks = get().tasks;
    const users = useUserStore.getState().users;
    return tasks.map(task => ({
      ...task,
      assigneeName: task.assigneeId ? users[task.assigneeId]?.name : undefined,
    }));
  },
}));

// In a component, you could combine both stores:
function TaskListWithAssignees() {
  const tasksWithAssignees = useTaskStore((state) => state.getTasksWithAssignees());
  // ...
}
```

### Step 5: Normalized State for Efficient Querying

Instead of storing arrays and using `find`, `filter`, etc., you can normalize your state into a record and an array of IDs:

```typescript
// src/store/normalizedStore.ts
import { create } from 'zustand';

interface NormalizedStore {
  // Raw state (normalized)
  tasks: Record<string, Task>;
  taskIds: string[];
  filter: string;
  
  // Actions
  addTask: (task: Task) => void;
  updateTask: (id: string, updates: Partial<Task>) => void;
  deleteTask: (id: string) => void;
  
  // Computed helpers
  getTask: (id: string) => Task | undefined;
  getTasks: (ids?: string[]) => Task[];
  getFilteredIds: () => string[];
}

export const useNormalizedStore = create<NormalizedStore>((set, get) => ({
  tasks: {},
  taskIds: [],
  filter: 'all',
  
  addTask: (task) => {
    set((state) => ({
      tasks: { ...state.tasks, [task.id]: task },
      taskIds: [...state.taskIds, task.id],
    }));
  },
  
  updateTask: (id, updates) => {
    set((state) => ({
      tasks: {
        ...state.tasks,
        [id]: { ...state.tasks[id], ...updates },
      },
    }));
  },
  
  deleteTask: (id) => {
    set((state) => {
      const { [id]: removed, ...remaining } = state.tasks;
      return {
        tasks: remaining,
        taskIds: state.taskIds.filter(taskId => taskId !== id),
      };
    });
  },
  
  // Computed: get a single task by ID
  getTask: (id) => get().tasks[id],
  
  // Computed: get multiple tasks by IDs (or all if none given)
  getTasks: (ids) => {
    const state = get();
    const targetIds = ids || state.taskIds;
    return targetIds.map(id => state.tasks[id]).filter(Boolean);
  },
  
  // Computed: get filtered task IDs
  getFilteredIds: () => {
    const state = get();
    const allIds = state.taskIds;
    let filtered = allIds;
    
    if (state.filter === 'active') {
      filtered = allIds.filter(id => !state.tasks[id].completed);
    } else if (state.filter === 'completed') {
      filtered = allIds.filter(id => state.tasks[id].completed);
    }
    
    return filtered;
  },
}));

// Usage in component:
function TaskList() {
  const filteredIds = useNormalizedStore((state) => state.getFilteredIds());
  const getTasks = useNormalizedStore((state) => state.getTasks);
  const tasks = getTasks(filteredIds);
  
  return tasks.map(task => <div key={task.id}>{task.text}</div>);
}
```

### Step 6: Derived Collections (Grouping, Sorting)

Often you need to present data in different ways without storing duplicates:

```typescript
// src/store/derivedCollections.ts
import { create } from 'zustand';

interface CollectionStore {
  tasks: Task[];
  
  // Derived collections (computed functions)
  getTasksByPriority: () => Record<string, Task[]>;
  getTasksByTag: () => Record<string, Task[]>;
  getSortedByDueDate: () => Task[];
  getOverdueTasks: () => Task[];
  getTasksForToday: () => Task[];
  
  // Actions
  addTask: (task: Task) => void;
}

export const useCollectionStore = create<CollectionStore>((set, get) => ({
  tasks: [],
  
  addTask: (task) => set((state) => ({ tasks: [...state.tasks, task] })),
  
  // Group by priority
  getTasksByPriority: () => {
    const tasks = get().tasks;
    const groups: Record<string, Task[]> = { low: [], medium: [], high: [] };
    for (const task of tasks) {
      groups[task.priority].push(task);
    }
    return groups;
  },
  
  // Group by tag (each task can have multiple tags)
  getTasksByTag: () => {
    const tasks = get().tasks;
    const groups: Record<string, Task[]> = {};
    for (const task of tasks) {
      for (const tag of task.tags) {
        if (!groups[tag]) groups[tag] = [];
        groups[tag].push(task);
      }
    }
    return groups;
  },
  
  // Sort by due date (ascending)
  getSortedByDueDate: () => {
    return [...get().tasks].sort((a, b) => {
      if (!a.dueDate && !b.dueDate) return 0;
      if (!a.dueDate) return 1;
      if (!b.dueDate) return -1;
      return a.dueDate.getTime() - b.dueDate.getTime();
    });
  },
  
  // Overdue tasks (due date in past)
  getOverdueTasks: () => {
    const now = new Date();
    return get().tasks.filter(t => t.dueDate && t.dueDate < now && !t.completed);
  },
  
  // Tasks due today
  getTasksForToday: () => {
    const now = new Date();
    const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
    const tomorrow = new Date(today);
    tomorrow.setDate(tomorrow.getDate() + 1);
    return get().tasks.filter(t => 
      t.dueDate && t.dueDate >= today && t.dueDate < tomorrow
    );
  },
}));
```

### Step 7: Caching Derived State with `useMemo` in the Store

For extremely expensive computations, you might want to cache the result and only recompute when the underlying state changes. You can achieve this by using a `Map` or a simple cache:

```typescript
// src/store/cachedDerivedStore.ts
import { create } from 'zustand';

interface CachedStore {
  tasks: Task[];
  _cache: Map<string, any>;
  
  getExpensiveDerivation: () => any;
  addTask: (task: Task) => void;
  clearCache: () => void;
}

export const useCachedStore = create<CachedStore>((set, get) => ({
  tasks: [],
  _cache: new Map(),
  
  getExpensiveDerivation: () => {
    const state = get();
    const cacheKey = JSON.stringify(state.tasks.map(t => t.id));
    
    if (state._cache.has(cacheKey)) {
      return state._cache.get(cacheKey);
    }
    
    // Expensive computation (e.g., complex filtering, sorting, aggregation)
    const result = state.tasks
      .filter(t => !t.completed)
      .sort((a, b) => a.priority.localeCompare(b.priority))
      .map(t => ({ ...t, formatted: t.text.toUpperCase() }));
    
    // Store in cache
    state._cache.set(cacheKey, result);
    return result;
  },
  
  addTask: (task) => {
    set((state) => ({
      tasks: [...state.tasks, task],
      _cache: new Map(), // Invalidate cache on change
    }));
  },
  
  clearCache: () => {
    set({ _cache: new Map() });
  },
}));
```

---

## The Verification: Testing Derived State

### Step 1: Create a Test Component

```tsx
// src/components/DerivedTest.tsx
import React from 'react';
import { useComputedStore } from '../store/computedStore';

function DerivedTest() {
  const tasks = useComputedStore((state) => state.tasks);
  const filtered = useComputedStore((state) => state.getFilteredTasks());
  const stats = useComputedStore((state) => state.getStats());
  const priorityCounts = useComputedStore((state) => state.getPriorityCounts());
  const overdue = useComputedStore((state) => state.getOverdueTasks());

  return (
    <div>
      <h2>Derived State Test</h2>
      <div>
        <strong>Stats:</strong> Total: {stats.total}, Completed: {stats.completed}, Active: {stats.active}
      </div>
      <div>
        <strong>Priority:</strong> High: {priorityCounts.high}, Medium: {priorityCounts.medium}, Low: {priorityCounts.low}
      </div>
      <div>
        <strong>Overdue:</strong> {overdue.length}
      </div>
      <div>
        <strong>Filtered tasks (active):</strong> {filtered.length}
      </div>
      <pre>{JSON.stringify(filtered, null, 2)}</pre>
    </div>
  );
}
```

### Step 2: Verify Memoization

```typescript
// In browser console
import { useComputedStore } from './src/store/computedStore';

// Add some tasks
const store = useComputedStore.getState();
store.addTask({ id: '1', text: 'Task 1', completed: false, priority: 'high', dueDate: null, tags: [] });
store.addTask({ id: '2', text: 'Task 2', completed: true, priority: 'low', dueDate: null, tags: [] });

// Call derived functions
console.log(store.getFilteredTasks()); // Should log filtered tasks
console.log(store.getStats()); // Should log stats

// Update a task
store.toggleTask('1');

// Call again - should reflect updated state
console.log(store.getFilteredTasks());
console.log(store.getStats());

// With reselect, the selectors will only recompute when inputs change
```

### Step 3: Performance Testing

Create a component that renders many tasks and verify that derived state doesn't cause cascading re-renders:

```tsx
// src/components/PerformanceDerived.tsx
import React, { useEffect, useRef } from 'react';
import { useComputedStore } from '../store/computedStore';

function PerformanceDerived() {
  const renderCount = useRef(0);
  renderCount.current++;
  
  // Subscribe to filtered tasks
  const filtered = useComputedStore((state) => state.getFilteredTasks());
  
  return (
    <div>
      <div>Render count: {renderCount.current}</div>
      <div>Filtered tasks: {filtered.length}</div>
    </div>
  );
}
```

---

## Deep Dive: Normalization vs. Denormalization

### Normalized State (Recommended for complex data)

```typescript
// Normalized: tasks by ID, IDs array
const state = {
  tasks: {
    '1': { id: '1', text: 'Task 1', assigneeId: '101' },
    '2': { id: '2', text: 'Task 2', assigneeId: '102' },
  },
  taskIds: ['1', '2'],
  users: {
    '101': { id: '101', name: 'Alice' },
    '102': { id: '102', name: 'Bob' },
  },
};
// Querying: O(1) to get task by ID, easy to update
```

### Denormalized State (Simpler but harder to maintain)

```typescript
// Denormalized: tasks array with nested assignee objects
const state = {
  tasks: [
    { id: '1', text: 'Task 1', assignee: { id: '101', name: 'Alice' } },
    { id: '2', text: 'Task 2', assignee: { id: '102', name: 'Bob' } },
  ],
};
// Updating assignee name requires updating all tasks
```

**When to normalize**:
- Large datasets with many relationships
- Frequent updates to related entities
- Need for fast lookups and sorting

**When to denormalize**:
- Small datasets
- Mostly read-only data
- Simpler code preferred

---

## Common Pitfalls and Solutions

### Pitfall 1: Storing Derived State in the Store

```typescript
// ❌ WRONG: Storing computed values in state
interface BadStore {
  tasks: Task[];
  filteredTasks: Task[]; // Redundant!
  stats: { total: number; completed: number; active: number }; // Redundant!
  addTask: (task: Task) => void;
}
// Problem: Filtered tasks and stats can become out of sync.

// ✅ CORRECT: Compute on demand
interface GoodStore {
  tasks: Task[];
  getFilteredTasks: () => Task[];
  getStats: () => { total: number; completed: number; active: number };
  addTask: (task: Task) => void;
}
```

### Pitfall 2: Expensive Computations Without Memoization

```typescript
// ❌ BAD: Recalculates on every render
const filtered = useComputedStore((state) => 
  state.tasks.filter(t => t.completed).sort((a, b) => a.text.localeCompare(b.text))
);

// ✅ GOOD: Memoize
const tasks = useComputedStore((state) => state.tasks);
const filtered = useMemo(() => 
  tasks.filter(t => t.completed).sort((a, b) => a.text.localeCompare(b.text)),
  [tasks]
);
```

### Pitfall 3: Not Handling Null/Undefined in Derived Functions

```typescript
// ❌ BAD: May throw if state is not ready
getOverdueTasks: () => {
  const tasks = get().tasks;
  return tasks.filter(t => t.dueDate < new Date()); // tasks might be undefined
}

// ✅ GOOD: Safe default
getOverdueTasks: () => {
  const tasks = get().tasks || [];
  return tasks.filter(t => t.dueDate && t.dueDate < new Date());
}
```

---

## Key Takeaways

1. **Derived state should be computed, not stored** – prevents duplication and inconsistency
2. **Use get() for simple derivations** inside the store
3. **Use useMemo in components** for expensive calculations
4. **Use reselect for complex, multi‑dependency selectors**
5. **Normalize your state** for better query performance
6. **Cache expensive derivations** when appropriate
7. **Cross‑store derivations** can use multiple stores with `getState()`
8. **Derived collections** (grouping, sorting, filtering) are common patterns
9. **Memoization is key** to avoid performance issues
10. **Always handle edge cases** (empty state, null values)

---

## What's Next

Now that you've mastered derived state, you're ready to dive into asynchronous state management. In the next section, you'll learn how to handle API requests, loading states, and error handling.
