# Part 1 — Foundations & Core Concepts

## Section 3: Reading State Efficiently

Now that you've created your first store, it's time to master the most important skill in Zustand: **reading state efficiently**. How you read state determines your application's performance, maintainability, and scalability.

---

## The Target: Optimized State Reading

By the end of this section, you'll be able to:
- Use selectors to extract specific pieces of state
- Prevent unnecessary re-renders with proper subscription patterns
- Use shallow comparisons to optimize performance
- Split selectors for maximum rendering efficiency

---

## The Concept: Selectors as Subscription Filters

Think of a selector as a **smart magnifying glass** that lets components focus on exactly what they need.

### The Problem: Over-Subscription

Imagine you're in a crowded room where everyone is talking at once. Without a way to filter out the noise, you'd be overwhelmed by every conversation happening around you. This is what happens when components subscribe to the entire store.

```typescript
// ❌ BAD: Subscribing to the entire store
const store = useTaskStore();
// This component re-renders when ANY state changes:
// - tasks change ✓
// - loading changes ✓
// - error changes ✓
// - ANYTHING changes ✓
```

### The Solution: Selective Subscriptions

Now imagine you have a special headset that only picks up the conversations you care about. This is what selectors do.

```typescript
// ✅ GOOD: Subscribe only to what you need
const tasks = useTaskStore((state) => state.tasks);
// This component only re-renders when 'tasks' changes
// Changes to 'loading' or 'error' don't trigger re-renders
```

### Real-World Analogy

Think of a restaurant kitchen:

- **Full Store**: The entire kitchen (all ingredients, all orders, all staff)
- **Selector**: A specific station (the grill station, the dessert station)
- **Component**: A server who only checks the dessert station when they need desserts

If the grill station gets busy (state changes), the dessert server doesn't care—they're not subscribed to that station. This is how Zustand's selectors prevent unnecessary re-renders.

---

## The Implementation: Selectors in Practice

### Step 1: Basic Selectors

Let's extend our task store with more state to demonstrate selectors:

```typescript
// src/store/taskStore.ts (expanded)
import { create } from 'zustand';

export interface Task {
  id: string;
  text: string;
  completed: boolean;
  createdAt: Date;
  priority: 'low' | 'medium' | 'high';
  tags: string[];
}

interface TaskStore {
  // State
  tasks: Task[];
  loading: boolean;
  error: string | null;
  filter: 'all' | 'active' | 'completed';
  searchQuery: string;
  sortBy: 'createdAt' | 'priority' | 'text';
  
  // Actions
  addTask: (text: string, priority?: Task['priority']) => void;
  toggleTask: (id: string) => void;
  deleteTask: (id: string) => void;
  setFilter: (filter: 'all' | 'active' | 'completed') => void;
  setSearchQuery: (query: string) => void;
  setSortBy: (sortBy: 'createdAt' | 'priority' | 'text') => void;
  clearTasks: () => void;
}

export const useTaskStore = create<TaskStore>((set, get) => ({
  // Initial state
  tasks: [],
  loading: false,
  error: null,
  filter: 'all',
  searchQuery: '',
  sortBy: 'createdAt',

  // Actions
  addTask: (text: string, priority: Task['priority'] = 'medium') => {
    set((state) => ({
      tasks: [
        ...state.tasks,
        {
          id: crypto.randomUUID(),
          text: text.trim(),
          completed: false,
          createdAt: new Date(),
          priority,
          tags: [],
        },
      ],
    }));
  },

  toggleTask: (id: string) => {
    set((state) => ({
      tasks: state.tasks.map((task) =>
        task.id === id ? { ...task, completed: !task.completed } : task
      ),
    }));
  },

  deleteTask: (id: string) => {
    set((state) => ({
      tasks: state.tasks.filter((task) => task.id !== id),
    }));
  },

  setFilter: (filter: 'all' | 'active' | 'completed') => {
    set({ filter });
  },

  setSearchQuery: (query: string) => {
    set({ searchQuery: query });
  },

  setSortBy: (sortBy: 'createdAt' | 'priority' | 'text') => {
    set({ sortBy });
  },

  clearTasks: () => {
    set({ tasks: [] });
  },
}));
```

Now let's create components that use selectors efficiently:

```tsx
// src/components/TaskStats.tsx
import { useTaskStore } from '../store/taskStore';

function TaskStats() {
  // ✅ Each selector subscribes independently
  // This component re-renders when ANY of these values change
  const totalTasks = useTaskStore((state) => state.tasks.length);
  const completedTasks = useTaskStore(
    (state) => state.tasks.filter((t) => t.completed).length
  );
  const highPriorityCount = useTaskStore(
    (state) => state.tasks.filter((t) => t.priority === 'high').length
  );
  
  // ❌ BAD: This would re-render when ANY state changes
  // const store = useTaskStore();

  return (
    <div className="task-stats">
      <span>Total: {totalTasks}</span>
      <span>Completed: {completedTasks}</span>
      <span>High Priority: {highPriorityCount}</span>
    </div>
  );
}
```

### Step 2: Advanced Selectors with Computed Values

Sometimes you need to compute values based on multiple pieces of state. Here's how to do it efficiently:

```tsx
// src/components/TaskList.tsx
import { useTaskStore } from '../store/taskStore';
import { useMemo } from 'react';

function TaskList() {
  // Get the raw data from the store
  const tasks = useTaskStore((state) => state.tasks);
  const filter = useTaskStore((state) => state.filter);
  const searchQuery = useTaskStore((state) => state.searchQuery);
  const sortBy = useTaskStore((state) => state.sortBy);

  // Compute filtered and sorted tasks
  // useMemo ensures this only recalculates when dependencies change
  const filteredAndSortedTasks = useMemo(() => {
    // Step 1: Filter by status
    let filtered = tasks;
    if (filter === 'active') {
      filtered = filtered.filter((t) => !t.completed);
    } else if (filter === 'completed') {
      filtered = filtered.filter((t) => t.completed);
    }

    // Step 2: Filter by search query
    if (searchQuery.trim()) {
      const query = searchQuery.toLowerCase().trim();
      filtered = filtered.filter((t) =>
        t.text.toLowerCase().includes(query)
      );
    }

    // Step 3: Sort
    const sorted = [...filtered].sort((a, b) => {
      switch (sortBy) {
        case 'createdAt':
          return b.createdAt.getTime() - a.createdAt.getTime();
        case 'priority': {
          const priorityOrder = { high: 3, medium: 2, low: 1 };
          return priorityOrder[b.priority] - priorityOrder[a.priority];
        }
        case 'text':
          return a.text.localeCompare(b.text);
        default:
          return 0;
      }
    });

    return sorted;
  }, [tasks, filter, searchQuery, sortBy]);

  return (
    <div>
      {filteredAndSortedTasks.map((task) => (
        <TaskItem key={task.id} task={task} />
      ))}
    </div>
  );
}
```

### Step 3: Creating Reusable Selectors

For complex applications, extract selectors into reusable functions:

```typescript
// src/store/taskSelectors.ts
import { useTaskStore } from './taskStore';
import { Task } from './taskStore';

// Selector creators (functions that return selectors)
export const selectTasks = (state: TaskStore) => state.tasks;
export const selectLoading = (state: TaskStore) => state.loading;
export const selectError = (state: TaskStore) => state.error;
export const selectFilter = (state: TaskStore) => state.filter;
export const selectSearchQuery = (state: TaskStore) => state.searchQuery;
export const selectSortBy = (state: TaskStore) => state.sortBy;

// Computed selectors
export const selectCompletedTasks = (state: TaskStore) =>
  state.tasks.filter((t) => t.completed);

export const selectActiveTasks = (state: TaskStore) =>
  state.tasks.filter((t) => !t.completed);

export const selectHighPriorityTasks = (state: TaskStore) =>
  state.tasks.filter((t) => t.priority === 'high');

export const selectTaskCounts = (state: TaskStore) => ({
  total: state.tasks.length,
  completed: state.tasks.filter((t) => t.completed).length,
  active: state.tasks.filter((t) => !t.completed).length,
});

// Factory function for filtered tasks
export const createSelectFilteredTasks = (
  filter: 'all' | 'active' | 'completed',
  searchQuery: string
) => {
  return (state: TaskStore) => {
    let tasks = state.tasks;
    
    if (filter === 'active') {
      tasks = tasks.filter((t) => !t.completed);
    } else if (filter === 'completed') {
      tasks = tasks.filter((t) => t.completed);
    }
    
    if (searchQuery.trim()) {
      const query = searchQuery.toLowerCase().trim();
      tasks = tasks.filter((t) =>
        t.text.toLowerCase().includes(query)
      );
    }
    
    return tasks;
  };
};
```

Usage in components:

```tsx
// src/components/TaskStats.tsx (with selectors)
import { useTaskStore } from '../store/taskStore';
import { selectTaskCounts, selectHighPriorityTasks } from '../store/taskSelectors';

function TaskStats() {
  // Using reusable selectors
  const counts = useTaskStore(selectTaskCounts);
  const highPriorityCount = useTaskStore(
    (state) => selectHighPriorityTasks(state).length
  );

  return (
    <div>
      <span>Total: {counts.total}</span>
      <span>Completed: {counts.completed}</span>
      <span>Active: {counts.active}</span>
      <span>High Priority: {highPriorityCount}</span>
    </div>
  );
}
```

---

## The Verification: Optimizing Performance

### Step 1: Add Render Tracking

Let's add render counters to see selectors in action:

```tsx
// src/components/RenderCounter.tsx
import { useEffect, useRef } from 'react';

export function RenderCounter({ name }: { name: string }) {
  const renderCount = useRef(0);
  renderCount.current += 1;

  useEffect(() => {
    console.log(`🔄 ${name} rendered ${renderCount.current} times`);
  });

  return (
    <span style={{ fontSize: '12px', color: '#666' }}>
      Renders: {renderCount.current}
    </span>
  );
}
```

### Step 2: Test Different Subscription Patterns

Create a test component to see the difference:

```tsx
// src/components/SelectorTest.tsx
import { useTaskStore } from '../store/taskStore';
import { RenderCounter } from './RenderCounter';

// ❌ BAD: Subscribes to everything
function BadComponent() {
  const state = useTaskStore();
  return (
    <div style={{ border: '2px solid red', padding: '10px', margin: '10px' }}>
      <h3>❌ Bad Component (subscribes to everything)</h3>
      <RenderCounter name="BadComponent" />
      <div>Tasks: {state.tasks.length}</div>
      <div>Loading: {String(state.loading)}</div>
      <div>Error: {state.error || 'None'}</div>
    </div>
  );
}

// ✅ GOOD: Subscribes only to what it needs
function GoodComponent() {
  const taskCount = useTaskStore((state) => state.tasks.length);
  const loading = useTaskStore((state) => state.loading);
  const error = useTaskStore((state) => state.error);

  return (
    <div style={{ border: '2px solid green', padding: '10px', margin: '10px' }}>
      <h3>✅ Good Component (selective subscription)</h3>
      <RenderCounter name="GoodComponent" />
      <div>Tasks: {taskCount}</div>
      <div>Loading: {String(loading)}</div>
      <div>Error: {error || 'None'}</div>
    </div>
  );
}

// 🚀 BEST: Only subscribes to a single value
function BestComponent() {
  const taskCount = useTaskStore((state) => state.tasks.length);

  return (
    <div style={{ border: '2px solid blue', padding: '10px', margin: '10px' }}>
      <h3>🚀 Best Component (single subscription)</h3>
      <RenderCounter name="BestComponent" />
      <div>Tasks: {taskCount}</div>
    </div>
  );
}

export function SelectorTest() {
  const addTask = useTaskStore((state) => state.addTask);
  const setLoading = useTaskStore((state) => state.setLoading); // Need to add this

  return (
    <div>
      <h2>Selector Performance Test</h2>
      <div style={{ display: 'flex', gap: '10px', marginBottom: '20px' }}>
        <button onClick={() => addTask('Test Task')}>Add Task</button>
        <button onClick={() => setLoading(!useTaskStore.getState().loading)}>
          Toggle Loading
        </button>
      </div>
      <BadComponent />
      <GoodComponent />
      <BestComponent />
    </div>
  );
}
```

Add `setLoading` to your store:

```typescript
// In taskStore.ts
interface TaskStore {
  // ... existing
  setLoading: (loading: boolean) => void;
}

// In create function
setLoading: (loading: boolean) => {
  set({ loading });
},
```

### Step 3: Run the Test

1. Start your dev server
2. Open the console
3. Click "Add Task" - observe which components re-render
4. Click "Toggle Loading" - observe which components re-render

**Expected Results**:
- `BadComponent`: Re-renders on EVERY state change
- `GoodComponent`: Re-renders when tasks, loading, or error change
- `BestComponent`: Only re-renders when task count changes

---

## Deep Dive: Shallow Comparison

### Understanding Shallow Equality

Zustand uses `Object.is` (similar to `===`) to compare values. For objects and arrays, this means it checks **reference equality**, not deep equality.

```typescript
// ❌ BAD: This will cause unnecessary re-renders
const tasks = useTaskStore((state) => {
  // Returns a NEW array on EVERY render
  return state.tasks.filter(t => !t.completed);
});
// Even if the filtered result is the same, the array reference is new
```

```typescript
// ✅ GOOD: Use memoization or stable references
const activeTasks = useTaskStore((state) => state.activeTasks);
// If the store maintains a stable reference to activeTasks,
// no unnecessary re-renders occur
```

### Using `shallow` for Object Selectors

When you want to subscribe to multiple properties without creating a new object every time:

```typescript
// src/components/UserProfile.tsx
import { useShallow } from 'zustand/react/shallow';
import { useTaskStore } from '../store/taskStore';

function UserProfile() {
  // ❌ BAD: Creates a new object on every render
  const { tasks, loading, error } = useTaskStore((state) => ({
    tasks: state.tasks,
    loading: state.loading,
    error: state.error,
  }));

  // ✅ GOOD: Uses shallow comparison to prevent unnecessary re-renders
  const { tasks, loading, error } = useTaskStore(
    useShallow((state) => ({
      tasks: state.tasks,
      loading: state.loading,
      error: state.error,
    }))
  );

  // Only re-renders when tasks, loading, or error actually change
  return (
    <div>
      <div>Tasks: {tasks.length}</div>
      <div>Loading: {String(loading)}</div>
      <div>Error: {error || 'None'}</div>
    </div>
  );
}
```

### Custom Shallow Comparison

For more control, you can create custom equality functions:

```typescript
// src/utils/shallowEqual.ts
export function shallowEqual<T extends Record<string, any>>(
  objA: T,
  objB: T
): boolean {
  if (objA === objB) return true;
  if (typeof objA !== 'object' || objA === null) return false;
  if (typeof objB !== 'object' || objB === null) return false;

  const keysA = Object.keys(objA);
  const keysB = Object.keys(objB);

  if (keysA.length !== keysB.length) return false;

  for (const key of keysA) {
    if (!objB.hasOwnProperty(key)) return false;
    if (objA[key] !== objB[key]) return false;
  }

  return true;
}

// Usage
const { tasks, loading } = useTaskStore(
  (state) => ({
    tasks: state.tasks,
    loading: state.loading,
  }),
  shallowEqual // Custom equality function
);
```

---

## Advanced Patterns: Memoized Selectors

For expensive computations, memoize selectors:

```typescript
// src/store/taskSelectors.ts (with memoization)
import { createSelector } from 'reselect';
import { useTaskStore } from './taskStore';

// Create a memoized selector for expensive operations
export const selectTasksByPriority = createSelector(
  [(state) => state.tasks],
  (tasks) => {
    // This only runs when tasks changes
    console.log('Computing tasks by priority...');
    return tasks.reduce(
      (acc, task) => {
        acc[task.priority].push(task);
        return acc;
      },
      { high: [], medium: [], low: [] } as Record<string, Task[]>
    );
  }
);

// Usage in component
function TaskPriorityGroups() {
  const tasksByPriority = useTaskStore(selectTasksByPriority);
  
  return (
    <div>
      <h3>High Priority: {tasksByPriority.high.length}</h3>
      <h3>Medium Priority: {tasksByPriority.medium.length}</h3>
      <h3>Low Priority: {tasksByPriority.low.length}</h3>
    </div>
  );
}
```

---

## Common Pitfalls and Solutions

### Pitfall 1: Creating New Objects in Selectors

```typescript
// ❌ BAD: Always creates a new object
const status = useTaskStore((state) => ({
  isComplete: state.tasks.every(t => t.completed),
  hasTasks: state.tasks.length > 0
}));

// ✅ GOOD: Use shallow comparison
const status = useTaskStore(
  (state) => ({
    isComplete: state.tasks.every(t => t.completed),
    hasTasks: state.tasks.length > 0
  }),
  shallow // Import from zustand/react/shallow
);
```

### Pitfall 2: Complex Computations in Selectors

```typescript
// ❌ BAD: Runs on every render
const expensiveValue = useTaskStore((state) => {
  // This heavy computation runs every time the component renders
  return state.tasks
    .filter(t => t.completed)
    .sort((a, b) => a.text.localeCompare(b.text))
    .map(t => t.text.toUpperCase());
});

// ✅ GOOD: Use useMemo in the component
const tasks = useTaskStore((state) => state.tasks);
const expensiveValue = useMemo(() => {
  return tasks
    .filter(t => t.completed)
    .sort((a, b) => a.text.localeCompare(b.text))
    .map(t => t.text.toUpperCase());
}, [tasks]);
```

### Pitfall 3: Over-Subscribing in Child Components

```tsx
// ❌ BAD: Parent subscribes and passes data down
function Parent() {
  const tasks = useTaskStore((state) => state.tasks);
  return tasks.map(task => <Child task={task} />);
}
// Every task change re-renders ALL children

// ✅ GOOD: Each child subscribes independently
function Child({ taskId }: { taskId: string }) {
  const task = useTaskStore((state) => 
    state.tasks.find(t => t.id === taskId)
  );
  return <div>{task?.text}</div>;
}
// Only the specific task's child re-renders when that task changes
```

---

## Key Takeaways

1. **Use selectors**: Always subscribe to specific pieces of state
2. **Memoize expensive computations**: Use `useMemo` or `createSelector`
3. **Use `shallow` for object selectors**: Prevents unnecessary re-renders
4. **Keep selectors simple**: Complex logic should be in the component
5. **Split subscriptions**: Different components should subscribe to different state
6. **Avoid creating new objects in selectors**: Use `shallow` or individual selectors

---

## What's Next

Now that you've mastered reading state efficiently, you're ready to dive deeper into updating state. In the next section, we'll explore functional updates, immutable updates, multiple state mutations, resetting state, and partial updates.
