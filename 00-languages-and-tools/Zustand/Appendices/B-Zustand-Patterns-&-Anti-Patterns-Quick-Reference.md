# Appendix B: Zustand Patterns & Anti-Patterns Quick Reference

This appendix provides a practical, at-a-glance reference for common Zustand patterns and anti-patterns. Use this as a quick guide when designing stores, reviewing code, or troubleshooting issues in production applications.

---

## Quick Decision Flowchart

```
Need to manage state?
        │
        ▼
┌───────────────────────────┐
│ Is it client-only state?  │
└───────────────────────────┘
        │
    ┌───┴───┐
    │       │
   Yes      No
    │       │
    ▼       ▼
┌─────────┐ ┌─────────────────┐
│Zustand  │ │ Server State    │
│         │ │ (React Query,   │
│         │ │  SWR, Apollo)   │
└─────────┘ └─────────────────┘
    │
    ▼
┌───────────────────────────┐
│ How many domains?         │
└───────────────────────────┘
    │
┌───┴───┐
│       │
Single  Multiple
│       │
▼       ▼
┌─────┐ ┌─────────────────┐
│One  │ │Multiple stores  │
│store│ │(domain-driven)  │
└─────┘ └─────────────────┘
```

---

## Pattern 1: Domain-Driven Store Organization

### ✅ Good Pattern

```typescript
// domains/user/store/userStore.ts
export const useUserStore = create<UserStore>((set) => ({
  users: [],
  loading: false,
  fetchUsers: async () => { /* ... */ },
}));

// domains/task/store/taskStore.ts
export const useTaskStore = create<TaskStore>((set) => ({
  tasks: [],
  loading: false,
  fetchTasks: async () => { /* ... */ },
}));

// domains/ui/store/uiStore.ts
export const useUIStore = create<UIStore>((set) => ({
  theme: 'light',
  sidebarOpen: true,
  toggleSidebar: () => set((state) => ({ sidebarOpen: !state.sidebarOpen })),
}));
```

### ❌ Anti-Pattern

```typescript
// ❌ Monolithic store with everything mixed together
const useStore = create((set) => ({
  users: [],
  tasks: [],
  theme: 'light',
  sidebarOpen: true,
  modalOpen: false,
  notifications: [],
  // ... 50+ more fields
  // ... 100+ actions
}));
```

---

## Pattern 2: Fine-Grained Subscriptions

### ✅ Good Pattern

```typescript
function TaskCounter() {
  // Only subscribes to taskIds.length
  const count = useTaskStore((state) => state.taskIds.length);
  return <div>Total: {count}</div>;
}

function TaskItem({ id }: { id: string }) {
  // Only subscribes to this specific task
  const task = useTaskStore((state) => state.tasks[id]);
  return <div>{task.title}</div>;
}

function UserProfile() {
  // Separate subscriptions for independent state
  const name = useUserStore((state) => state.user?.name);
  const avatar = useUserStore((state) => state.user?.avatar);
  // Each is independent - changes to name don't re-render avatar
  return <div>{name} {avatar}</div>;
}
```

### ❌ Anti-Pattern

```typescript
// ❌ Subscribes to entire store
function TaskCounter() {
  const store = useTaskStore(); // EVERYTHING!
  // Re-renders on ANY state change
  return <div>Total: {store.taskIds.length}</div>;
}

// ❌ Creates new object in selector
function BadComponent() {
  const { tasks, loading } = useTaskStore((state) => ({
    tasks: state.tasks,
    loading: state.loading,
  }));
  // New object on every render → causes re-renders
  return <div>{tasks.length}</div>;
}
```

---

## Pattern 3: Immutable Updates

### ✅ Good Pattern

```typescript
// ✅ Using spread operators
set((state) => ({
  tasks: [...state.tasks, newTask], // New array
  user: { ...state.user, name: 'Bob' }, // New object
}));

// ✅ Using Immer middleware
import { immer } from 'zustand/middleware/immer';

const useStore = create(
  immer((set) => ({
    tasks: [],
    addTask: (task) => {
      set((state) => {
        state.tasks.push(task); // Mutable syntax, immutable result
      });
    },
  }))
);
```

### ❌ Anti-Pattern

```typescript
// ❌ Direct mutation
const useBadStore = create((set, get) => ({
  tasks: [],
  addTask: (task) => {
    const state = get();
    state.tasks.push(task); // Mutates existing array
    set(state); // ❌ Zustand won't detect the change!
  },
}));

// ❌ Incomplete copy
set((state) => ({
  tasks: state.tasks.map(t => {
    if (t.id === id) {
      t.completed = !t.completed; // ❌ Mutating inside map!
    }
    return t;
  }),
}));
```

---

## Pattern 4: Async Actions with Error Handling

### ✅ Good Pattern

```typescript
const useStore = create((set) => ({
  data: null,
  loading: false,
  error: null,

  fetchData: async () => {
    set({ loading: true, error: null });
    try {
      const response = await fetch('/api/data');
      if (!response.ok) throw new Error(`HTTP ${response.status}`);
      const data = await response.json();
      set({ data, loading: false });
    } catch (error) {
      set({
        error: error instanceof Error ? error.message : 'Unknown error',
        loading: false,
      });
    }
  },
}));
```

### ❌ Anti-Pattern

```typescript
// ❌ No error handling
const useBadStore = create((set) => ({
  data: null,
  fetchData: async () => {
    const response = await fetch('/api/data');
    const data = await response.json();
    set({ data }); // No loading, no error, no edge cases
  },
}));

// ❌ Swallowed errors
const useBadStore = create((set) => ({
  data: null,
  fetchData: async () => {
    try {
      const data = await fetch('/api/data').then(r => r.json());
      set({ data });
    } catch {
      // Silently fails - user sees nothing
    }
  },
}));
```

---

## Pattern 5: Persistence with Partial State

### ✅ Good Pattern

```typescript
import { persist, createJSONStorage } from 'zustand/middleware';

const useStore = create(
  persist(
    (set) => ({
      // State
      user: null,
      theme: 'light',
      isLoading: false, // ❌ Not persisted
      error: null, // ❌ Not persisted
      preferences: { language: 'en', timezone: 'UTC' },
    }),
    {
      name: 'app-storage',
      // ✅ Only persist what's needed
      partialize: (state) => ({
        user: state.user,
        theme: state.theme,
        preferences: state.preferences,
        // ❌ isLoading, error are NOT persisted
      }),
    }
  )
);
```

### ❌ Anti-Pattern

```typescript
// ❌ Persisting everything
const useBadStore = create(
  persist(
    (set) => ({
      user: null,
      isLoading: false, // ❌ Shouldn't be persisted
      error: null, // ❌ Shouldn't be persisted
      theme: 'light',
    }),
    { name: 'app-storage' } // Persists everything
  )
);

// ❌ Persisting non-serializable data
const useBadStore = create(
  persist(
    (set) => ({
      tasks: [],
      addTask: (task) => set((state) => ({
        tasks: [...state.tasks, { ...task, createdAt: new Date() }]
        // ❌ Date is not serializable!
      })),
    }),
    { name: 'task-storage' }
  )
);
```

---

## Pattern 6: Cross-Store Communication

### ✅ Good Pattern (Event Bus)

```typescript
import { create } from 'zustand';

// Event bus
const eventBus = {
  listeners: new Map(),
  subscribe: (event, callback) => {
    if (!eventBus.listeners.has(event)) {
      eventBus.listeners.set(event, new Set());
    }
    eventBus.listeners.get(event).add(callback);
    return () => eventBus.listeners.get(event).delete(callback);
  },
  publish: (event, data) => {
    const callbacks = eventBus.listeners.get(event);
    if (callbacks) {
      for (const cb of callbacks) {
        cb(data);
      }
    }
  },
};

// Store A publishes events
const useTaskStore = create((set) => ({
  tasks: [],
  addTask: (task) => {
    set((state) => ({ tasks: [...state.tasks, task] }));
    eventBus.publish('task:created', task);
  },
}));

// Store B subscribes to events
const useNotificationStore = create((set) => ({
  notifications: [],
  init: () => {
    eventBus.subscribe('task:created', (task) => {
      set((state) => ({
        notifications: [...state.notifications, `Task: ${task.title}`],
      }));
    });
  },
}));
```

### ❌ Anti-Pattern

```typescript
// ❌ Direct import causing circular dependency
// domains/task/store/taskStore.ts
import { useAuthStore } from '../../auth/store/authStore'; // ❌ Tight coupling

const useTaskStore = create((set, get) => ({
  tasks: [],
  addTask: (task) => {
    const user = useAuthStore.getState().user; // ❌ Direct dependency
    // ...
  },
}));

// domains/auth/store/authStore.ts
import { useTaskStore } from '../../task/store/taskStore'; // ❌ Circular!

const useAuthStore = create((set) => ({
  // ...
}));
```

---

## Pattern 7: Optimistic Updates

### ✅ Good Pattern

```typescript
const useStore = create((set) => ({
  items: [],
  addItem: async (item) => {
    // ✅ Optimistic: Add immediately
    const tempId = `temp-${Date.now()}`;
    set((state) => ({
      items: [...state.items, { ...item, id: tempId, optimistic: true }],
    }));

    try {
      const saved = await api.save(item);
      // ✅ Replace optimistic with real
      set((state) => ({
        items: state.items.map(i =>
          i.id === tempId ? { ...saved, optimistic: false } : i
        ),
      }));
    } catch (error) {
      // ✅ Rollback on failure
      set((state) => ({
        items: state.items.filter(i => i.id !== tempId),
        error: error.message,
      }));
    }
  },
}));
```

### ❌ Anti-Pattern

```typescript
// ❌ No rollback on failure
const useBadStore = create((set) => ({
  items: [],
  addItem: async (item) => {
    set((state) => ({ items: [...state.items, item] })); // Optimistic
    await api.save(item); // If this fails, UI is out of sync!
    // ❌ No rollback!
  },
}));

// ❌ No optimistic update at all (slow)
const useBadStore = create((set) => ({
  items: [],
  addItem: async (item) => {
    const saved = await api.save(item); // User waits...
    set((state) => ({ items: [...state.items, saved] }));
  },
}));
```

---

## Pattern 8: Request Deduplication

### ✅ Good Pattern

```typescript
const useStore = create((set, get) => ({
  data: null,
  pendingRequests: new Map(),

  fetchData: async (id) => {
    const key = `data-${id}`;
    // ✅ Check if request is already in flight
    if (get().pendingRequests.has(key)) {
      return get().pendingRequests.get(key);
    }

    const promise = (async () => {
      set({ loading: true });
      const data = await api.getData(id);
      set({ data, loading: false });
      return data;
    })();

    set((state) => ({
      pendingRequests: new Map(state.pendingRequests).set(key, promise),
    }));

    try {
      const result = await promise;
      return result;
    } finally {
      set((state) => {
        const newMap = new Map(state.pendingRequests);
        newMap.delete(key);
        return { pendingRequests: newMap };
      });
    }
  },
}));
```

### ❌ Anti-Pattern

```typescript
// ❌ No deduplication: multiple identical requests
const useBadStore = create((set) => ({
  data: null,
  fetchData: async (id) => {
    set({ loading: true });
    const data = await api.getData(id); // ⚠️ Called multiple times
    set({ data, loading: false });
  },
}));

// Component 1 calls fetchData('user-1')
// Component 2 calls fetchData('user-1')
// ❌ Two identical requests in flight!
```

---

## Pattern 9: Lazy Initialization

### ✅ Good Pattern

```typescript
let store: StoreApi<HeavyStore> | null = null;

function getHeavyStore() {
  if (!store) {
    store = createStore<HeavyStore>((set) => ({
      data: [],
      heavyCalculation: () => { /* ... */ },
      load: async () => {
        const data = await fetchHeavyData();
        set({ data });
      },
    }));
  }
  return store;
}

// Use the store lazily
const store = getHeavyStore();
store.getState().load();
```

### ❌ Anti-Pattern

```typescript
// ❌ Initialized immediately, even if never used
const useHeavyStore = create((set) => ({
  data: [],
  heavyCalculation: () => { /* ... */ }, // Always created
  load: async () => {
    const data = await fetchHeavyData(); // Runs on app load!
    set({ data });
  },
}));

// ❌ load() runs on app boot, even if user never visits the page
useHeavyStore.getState().load();
```

---

## Pattern 10: Middleware Composition Order

### ✅ Good Pattern (Correct Order)

```typescript
import { create } from 'zustand';
import { devtools, persist, subscribeWithSelector } from 'zustand/middleware';

// ✅ Correct order: devtools wraps persist
const useStore = create(
  devtools(                      // <-- Outer: debugging
    persist(                     // <-- Middle: persistence
      subscribeWithSelector(     // <-- Inner: subscription
        (set) => ({
          count: 0,
          increment: () => set((state) => ({ count: state.count + 1 })),
        })
      ),
      { name: 'app-storage' }
    ),
    { name: 'App Store' }
  )
);
```

### ❌ Anti-Pattern (Incorrect Order)

```typescript
// ❌ Persist wraps devtools - devtools won't see persistence updates
const useBadStore = create(
  persist(                       // <-- Outer: persistence
    devtools(                    // <-- Inner: debugging
      (set) => ({
        count: 0,
        increment: () => set((state) => ({ count: state.count + 1 })),
      }),
      { name: 'App Store' }
    ),
    { name: 'app-storage' }
  )
);
// ❌ DevTools won't show persistence operations
```

---

## Pattern 11: Testing Stores

### ✅ Good Pattern

```typescript
import { describe, it, expect, beforeEach } from 'vitest';
import { useStore } from './store';

describe('Store', () => {
  beforeEach(() => {
    // ✅ Reset state before each test
    useStore.setState({ count: 0 });
  });

  it('should increment count', () => {
    const { increment } = useStore.getState();
    increment();
    expect(useStore.getState().count).toBe(1);
  });

  it('should handle async actions', async () => {
    const { fetchData } = useStore.getState();
    await fetchData();
    expect(useStore.getState().loading).toBe(false);
  });
});
```

### ❌ Anti-Pattern

```typescript
// ❌ No reset between tests
describe('Store', () => {
  it('test 1', () => {
    useStore.getState().increment();
    expect(useStore.getState().count).toBe(1);
  });

  it('test 2', () => {
    // ❌ Count is still 1 from test 1!
    expect(useStore.getState().count).toBe(1);
  });
});

// ❌ Real API calls in tests
it('should fetch data', async () => {
  const { fetchData } = useStore.getState();
  await fetchData(); // ❌ Makes real network call
});
```

---

## Recipe Cards

### Recipe 1: Simple Counter Store

```typescript
const useCounterStore = create((set) => ({
  count: 0,
  increment: () => set((state) => ({ count: state.count + 1 })),
  decrement: () => set((state) => ({ count: state.count - 1 })),
  reset: () => set({ count: 0 }),
}));
```

### Recipe 2: Todo Store with Persistence

```typescript
const useTodoStore = create(
  persist(
    (set) => ({
      todos: [],
      addTodo: (text) => set((state) => ({
        todos: [...state.todos, { id: Date.now(), text, done: false }],
      })),
      toggleTodo: (id) => set((state) => ({
        todos: state.todos.map(t =>
          t.id === id ? { ...t, done: !t.done } : t
        ),
      })),
      deleteTodo: (id) => set((state) => ({
        todos: state.todos.filter(t => t.id !== id),
      })),
    }),
    { name: 'todo-storage' }
  )
);
```

### Recipe 3: Async Data Fetching

```typescript
const useDataStore = create((set) => ({
  data: null,
  loading: false,
  error: null,
  fetchData: async () => {
    set({ loading: true, error: null });
    try {
      const response = await fetch('/api/data');
      const data = await response.json();
      set({ data, loading: false });
    } catch (error) {
      set({ error: error.message, loading: false });
    }
  },
}));
```

### Recipe 4: Form State with Validation

```typescript
const useFormStore = create((set) => ({
  fields: { email: '', password: '' },
  errors: {},
  touched: {},
  setField: (field, value) => {
    set((state) => ({
      fields: { ...state.fields, [field]: value },
      touched: { ...state.touched, [field]: true },
    }));
  },
  validate: () => {
    const errors = {};
    // Validation logic...
    set({ errors });
    return Object.keys(errors).length === 0;
  },
  reset: () => set({ fields: { email: '', password: '' }, errors: {}, touched: {} }),
}));
```

---

## Troubleshooting Quick Reference

| Symptom | Likely Cause | Solution |
|---------|-------------|----------|
| Component doesn't update | Direct mutation | Use immutable updates or Immer |
| Component updates too much | Over-subscription | Use selectors or `useShallow` |
| State resets on reload | No persistence | Use `persist` middleware |
| State persists but is corrupted | Schema change without migration | Use `version` and `migrate` |
| Slow renders | Expensive selectors | Memoize with `reselect` or `useMemo` |
| Race conditions | No request deduplication | Track request IDs or use AbortController |
| Memory leak | Unsubscribed listeners | Call `unsubscribe` in cleanup |
| Circular dependency | Cross-store imports | Use event bus or DI |
| Infinite re-renders | New object in selector | Use `useShallow` or individual selectors |
| Store not initializing | Async in `create` | Move async to actions |

---

## Performance Quick Reference

| Optimization | When to Use | How |
|--------------|-------------|-----|
| Fine-grained selectors | Always | Subscribe only to needed state |
| `useShallow` | Object selectors with multiple fields | Prevents re-renders on unchanged values |
| `reselect` | Expensive computations | Memoizes complex derivations |
| `React.memo` | List items and expensive components | Prevents re-renders when props unchanged |
| `useMemo` | Derived state in components | Avoids recomputation on every render |
| Request deduplication | Identical API calls | Prevents redundant requests |
| Store splitting | Large, unrelated state | Reduces subscription scope |
| Virtualization | Long lists (100+ items) | Renders only visible items |
| Batching | Multiple updates | Combine into single `set` call |
| Lazy initialization | Expensive, rarely used state | Create store only when needed |

---

## Migration Quick Reference

### From Redux to Zustand

| Redux Concept | Zustand Equivalent |
|---------------|-------------------|
| Reducer | `set` functional update |
| Action | Store action method |
| Dispatch | Direct action call |
| Selector | Store selector / `reselect` |
| Redux DevTools | `devtools` middleware |
| Persist (redux-persist) | `persist` middleware |
| Middleware | Custom middleware or built-in |
| Thunk | Async action in store |
| Immutability | Immer middleware or spreads |

### From Context API to Zustand

| Context Concept | Zustand Equivalent |
|-----------------|-------------------|
| Provider | Not needed (global stores) |
| useContext | `useStore` hook |
| Context value | Store state + actions |
| Context updates | Selector subscriptions |
| Memoization | `useShallow` + selectors |
| Re-renders | Fine-grained subscriptions |

---

## Appendix Summary

| Topic | Key Takeaway |
|-------|--------------|
| **Domain Stores** | Split by business domain, not technical layer |
| **Subscriptions** | Subscribe only to what you need |
| **Immutability** | Never mutate directly; use Immer or spreads |
| **Async** | Always handle loading, error, and success states |
| **Persistence** | Only persist what's needed; use partialize |
| **Cross-store** | Use event bus, not direct imports |
| **Optimistic** | Show immediate UI, rollback on failure |
| **Deduplication** | Prevent redundant requests |
| **Lazy init** | Create stores only when needed |
| **Middleware** | Order matters: devtools outermost |
| **Testing** | Reset state, mock APIs |
| **Performance** | Use selectors, shallow, memoization, virtualization |
