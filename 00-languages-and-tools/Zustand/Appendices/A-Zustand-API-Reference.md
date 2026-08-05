# Appendix A: Zustand API Reference

This appendix provides a comprehensive reference for the Zustand API, including all core functions, middleware, TypeScript patterns, and common usage examples. Use this as a quick reference guide when building applications with Zustand.

---

## Quick Reference Card

| Feature | API | Description |
|---------|-----|-------------|
| Create Store | `create<T>(...)` | Creates a Zustand store |
| React Hook | `useStore<T>()` | React hook to access store |
| Vanilla Store | `createStore<T>(...)` | Creates store without React |
| Update State | `set(partial, replace?)` | Updates store state |
| Read State | `get()` | Gets current state |
| Subscribe | `subscribe(listener)` | Subscribes to state changes |
| Destroy | `destroy()` | Cleans up store |

---

## Core API

### `create<T>`

Creates a Zustand store with React hooks.

```typescript
import { create } from 'zustand';

// Basic store
const useStore = create((set) => ({
  count: 0,
  increment: () => set((state) => ({ count: state.count + 1 })),
}));

// With TypeScript
interface Store {
  count: number;
  increment: () => void;
}

const useStore = create<Store>((set) => ({
  count: 0,
  increment: () => set((state) => ({ count: state.count + 1 })),
}));

// With middleware
import { persist } from 'zustand/middleware';

const useStore = create<Store>()(
  persist(
    (set) => ({
      count: 0,
      increment: () => set((state) => ({ count: state.count + 1 })),
    }),
    { name: 'counter-storage' }
  )
);
```

### `createStore<T>`

Creates a vanilla Zustand store (without React hooks).

```typescript
import { createStore } from 'zustand/vanilla';

const store = createStore((set) => ({
  count: 0,
  increment: () => set((state) => ({ count: state.count + 1 })),
}));

// Access state
store.getState();
store.setState({ count: 5 });
store.subscribe((state) => console.log(state));
```

### `set` Function

The `set` function is the primary way to update Zustand state.

```typescript
// Object update (merges)
set({ count: 1 });

// Functional update (receives current state)
set((state) => ({ count: state.count + 1 }));

// Replace state (instead of merge)
set({ count: 1 }, true);

// Named action (for devtools)
set({ count: 1 }, false, 'increment');
```

### `get` Function

Gets the current state from within the store.

```typescript
const useStore = create((set, get) => ({
  count: 0,
  double: () => get().count * 2,
  increment: () => set((state) => ({ count: state.count + 1 })),
}));
```

### `subscribe` Function

Subscribes to store changes.

```typescript
// Basic subscription
const unsubscribe = useStore.subscribe((state) => {
  console.log('State changed:', state);
});

// With selector (prevents unnecessary updates)
const unsubscribe = useStore.subscribe(
  (state) => state.count,
  (count) => console.log('Count changed:', count)
);

// With equality check
const unsubscribe = useStore.subscribe(
  (state) => state.data,
  (data) => console.log('Data:', data),
  (a, b) => a.length === b.length
);
```

---

## Middleware API

### `persist`

Persists store state to storage.

```typescript
import { persist, createJSONStorage } from 'zustand/middleware';

const useStore = create(
  persist(
    (set) => ({
      user: null,
      setUser: (user) => set({ user }),
    }),
    {
      name: 'user-storage', // Storage key
      storage: createJSONStorage(() => localStorage), // Storage adapter
      partialize: (state) => ({ user: state.user }), // What to persist
      version: 1, // Schema version
      migrate: (state, version) => { /* Migration logic */ },
      onRehydrateStorage: () => (state) => { /* Post-hydration */ },
    }
  )
);
```

### `devtools`

Connects to Redux DevTools.

```typescript
import { devtools } from 'zustand/middleware';

const useStore = create(
  devtools(
    (set) => ({
      count: 0,
      increment: () => set((state) => ({ count: state.count + 1 }), false, 'increment'),
    }),
    {
      name: 'My Store',
      enabled: process.env.NODE_ENV === 'development',
    }
  )
);
```

### `immer`

Enables mutable updates with Immer.

```typescript
import { immer } from 'zustand/middleware/immer';

const useStore = create(
  immer((set) => ({
    user: { name: 'Alice', preferences: { theme: 'dark' } },
    updateTheme: (theme) =>
      set((state) => {
        state.user.preferences.theme = theme; // Mutable!
      }),
  }))
);
```

### `subscribeWithSelector`

Enables selective subscriptions.

```typescript
import { subscribeWithSelector } from 'zustand/middleware';

const useStore = create(
  subscribeWithSelector((set) => ({
    count: 0,
    increment: () => set((state) => ({ count: state.count + 1 })),
  }))
);

// Selective subscription
const unsubscribe = useStore.subscribe(
  (state) => state.count,
  (count) => console.log('Count:', count)
);
```

### `combine`

Combines state and actions with type inference.

```typescript
import { combine } from 'zustand/middleware';

const useStore = create(
  combine(
    { count: 0, name: '' }, // State
    (set) => ({
      increment: () => set((state) => ({ count: state.count + 1 })),
      setName: (name: string) => set({ name }),
    })
  )
);
```

---

## React API

### `useStore`

The React hook for accessing Zustand stores.

```typescript
import { useStore } from 'zustand';

// With vanilla store
import { store } from './store';

function Component() {
  const count = useStore(store, (state) => state.count);
  const increment = useStore(store, (state) => state.increment);
}
```

### `useShallow`

Optimizes object selectors to prevent unnecessary re-renders.

```typescript
import { useShallow } from 'zustand/react/shallow';

function Component() {
  const { user, settings } = useStore(
    useShallow((state) => ({
      user: state.user,
      settings: state.settings,
    }))
  );
  // Only re-renders when user OR settings change
}
```

### `create` with Provider (Scoped Stores)

```typescript
import { createStore } from 'zustand/vanilla';
import { createContext, useContext } from 'react';

const StoreContext = createContext<ReturnType<typeof createStore> | null>(null);

function StoreProvider({ children }) {
  const store = useMemo(() => createStore((set) => ({ /* ... */ })), []);
  return <StoreContext.Provider value={store}>{children}</StoreContext.Provider>;
}

function useScopedStore<T>(selector: (state: any) => T) {
  const store = useContext(StoreContext);
  if (!store) throw new Error('Missing StoreProvider');
  return useStore(store, selector);
}
```

---

## TypeScript Patterns

### Store Type Definition

```typescript
interface Store {
  // State
  count: number;
  user: User | null;

  // Actions
  increment: () => void;
  setUser: (user: User) => void;
}

const useStore = create<Store>((set) => ({
  count: 0,
  user: null,
  increment: () => set((state) => ({ count: state.count + 1 })),
  setUser: (user) => set({ user }),
}));
```

### Slice Pattern with TypeScript

```typescript
interface CounterSlice {
  count: number;
  increment: () => void;
}

interface UserSlice {
  user: User | null;
  setUser: (user: User) => void;
}

type Store = CounterSlice & UserSlice;

const createCounterSlice = (set: any): CounterSlice => ({
  count: 0,
  increment: () => set((state) => ({ count: state.count + 1 })),
});

const createUserSlice = (set: any): UserSlice => ({
  user: null,
  setUser: (user) => set({ user }),
});

const useStore = create<Store>((set) => ({
  ...createCounterSlice(set),
  ...createUserSlice(set),
}));
```

### Middleware Type Inference

```typescript
import { create } from 'zustand';
import { persist, devtools } from 'zustand/middleware';

interface Store {
  count: number;
  increment: () => void;
}

const useStore = create<Store>()(
  devtools(
    persist(
      (set) => ({
        count: 0,
        increment: () => set((state) => ({ count: state.count + 1 })),
      }),
      { name: 'count-storage' }
    ),
    { name: 'Count Store' }
  )
);
```

### Custom Middleware Types

```typescript
import { StateCreator, StoreMutatorIdentifier } from 'zustand';

// Middleware that adds logging
export type LoggerMiddleware = <
  T,
  Mps extends [StoreMutatorIdentifier, unknown][] = [],
  Mcs extends [StoreMutatorIdentifier, unknown][] = []
>(
  config: StateCreator<T, Mps, Mcs>
) => StateCreator<T, Mps, Mcs>;

export const logger: LoggerMiddleware = (config) => (set, get, store) => {
  return config(
    (args) => {
      console.log('Before:', get());
      set(args);
      console.log('After:', get());
    },
    get,
    store
  );
};
```

---

## Vanilla Store API

### Store Interface

```typescript
interface StoreApi<T> {
  getState: () => T;
  setState: (partial: Partial<T> | ((state: T) => Partial<T>), replace?: boolean) => void;
  subscribe: (listener: (state: T, prevState: T) => void) => () => void;
  destroy: () => void;
}
```

### Usage Examples

```typescript
import { createStore } from 'zustand/vanilla';

// Create store
const store = createStore<{ count: number }>((set) => ({
  count: 0,
  increment: () => set((state) => ({ count: state.count + 1 })),
}));

// Get state
const state = store.getState();

// Set state
store.setState({ count: 5 });

// Subscribe
const unsubscribe = store.subscribe((state, prevState) => {
  console.log('Changed:', prevState.count, '->', state.count);
});

// Destroy (cleanup subscriptions)
store.destroy();

// Use with React
import { useStore } from 'zustand';

function Component() {
  const count = useStore(store, (state) => state.count);
}
```

---

## Common Patterns

### Factory Pattern

```typescript
// Create store factory
export const createTaskStore = (initialTasks: Task[]) => {
  return create<Store>((set) => ({
    tasks: initialTasks,
    addTask: (task) => set((state) => ({ tasks: [...state.tasks, task] })),
  }));
};

// Use in components
const useTaskStore = createTaskStore([]);
```

### Dependency Injection

```typescript
interface StoreDeps {
  api: ApiClient;
  storage: Storage;
}

const useStore = create((set, get, store) => {
  const deps = store.deps as StoreDeps;
  // Use deps.api, deps.storage
  return {
    fetch: async () => {
      const data = await deps.api.getData();
      set({ data });
    },
  };
});

// Set dependencies
const store = useStore;
store.deps = { api: new ApiClient(), storage: localStorage };
```

### Cross-Store Communication

```typescript
// Event bus
import { create } from 'zustand';
import { immer } from 'zustand/middleware/immer';

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

// Store A
const useTaskStore = create((set) => ({
  tasks: [],
  addTask: (task) => {
    set((state) => ({ tasks: [...state.tasks, task] }));
    eventBus.publish('task:created', task);
  },
}));

// Store B
const useNotificationStore = create((set) => ({
  notifications: [],
  init: () => {
    eventBus.subscribe('task:created', (task) => {
      set((state) => ({
        notifications: [...state.notifications, `Task created: ${task.title}`],
      }));
    });
  },
}));
```

### Lazy Store Initialization

```typescript
let store: StoreApi<any> | null = null;

function getStore() {
  if (!store) {
    store = createStore((set) => ({
      data: [],
      load: async () => {
        const data = await fetchData();
        set({ data });
      },
    }));
  }
  return store;
}

// Usage
getStore().getState().load();
```

---

## Error Handling

### Safe Updates

```typescript
const useStore = create((set, get) => ({
  data: null,
  error: null,
  fetchData: async () => {
    set({ error: null });
    try {
      const data = await fetch('/api/data');
      set({ data });
    } catch (error) {
      set({ error: error.message });
    }
  },
}));
```

### Error Boundary Middleware

```typescript
const withErrorBoundary = <T extends object>(
  config: StateCreator<T, [], []>
): StateCreator<T, [], []> => {
  return (set, get, store) => {
    return config(
      (args) => {
        try {
          set(args);
        } catch (error) {
          console.error('Store update failed:', error);
          // Notify error monitoring
          Sentry.captureException(error);
          // Optionally set error state
        }
      },
      get,
      store
    );
  };
};
```

---

## Performance Optimizations

### Memoized Selectors (Reselect)

```typescript
import { createSelector } from 'reselect';

const selectTasks = (state) => state.tasks;
const selectFilter = (state) => state.filter;

const selectFilteredTasks = createSelector(
  [selectTasks, selectFilter],
  (tasks, filter) => {
    // Only recomputes when tasks or filter change
    return tasks.filter(task => task.status === filter);
  }
);

// In component
const filteredTasks = useStore(selectFilteredTasks);
```

### Shallow Equality

```typescript
import { useShallow } from 'zustand/react/shallow';

function Component() {
  const { tasks, filter } = useStore(
    useShallow((state) => ({
      tasks: state.tasks,
      filter: state.filter,
    }))
  );
  // Only re-renders when tasks or filter actually change
}
```

### Subscriptions with Selectors

```typescript
const unsubscribe = useStore.subscribe(
  (state) => state.tasks.length,
  (length) => {
    console.log('Task count:', length);
  }
);
```

---

## Testing Helpers

### Reset Store Between Tests

```typescript
import { create } from 'zustand';

// In test setup
beforeEach(() => {
  useStore.setState({ count: 0, tasks: [] });
});

// Or with a reset action
const useStore = create((set) => ({
  count: 0,
  tasks: [],
  reset: () => set({ count: 0, tasks: [] }),
}));
```

### Mock Store

```typescript
import { create } from 'zustand';

// In tests
const mockStore = create<Store>((set) => ({
  count: 0,
  increment: vi.fn(),
  tasks: [],
}));

// Use the mock store in components
// Replace real store with mock
```

---

## Appendix Summary

| Topic | Key Points |
|-------|------------|
| **Core API** | `create`, `createStore`, `set`, `get`, `subscribe` |
| **Middleware** | `persist`, `devtools`, `immer`, `subscribeWithSelector`, `combine` |
| **React Hooks** | `useStore`, `useShallow`, scoped stores via Context |
| **TypeScript** | Store interfaces, slice pattern, middleware types |
| **Patterns** | Factory, DI, cross-store communication, lazy init |
| **Performance** | Memoized selectors, shallow equality, selective subscriptions |
| **Testing** | Store reset, mocks, utilities |
