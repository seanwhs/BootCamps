# Zustand Mastery: Complete Tutorial Series — Slide Outline

## Executive Summary

**Title:** Zustand Mastery: From Fundamentals to Production-Grade State Management

**Target Audience:** React developers, frontend engineers, technical leads, architects

**Total Duration:** 5 Days / 40 Hours

**Format:** Theory + Live Coding + Hands-on Labs

---

## Day 1: Foundations & Core Concepts (8 Hours)

### Session 1: Welcome & Introduction (30 min)
**Slide 1: Title Slide**
- "Zustand Mastery: From Fundamentals to Production-Grade State Management"
- Presenter name, date, and session information

**Slide 2: Course Overview**
- 5-day intensive training
- Hands-on, code-first approach
- Build a complete application: TaskFlow
- All code is copy-pasteable

**Slide 3: What You Will Learn**
- Zustand fundamentals and API
- Advanced state architecture patterns
- Async workflows and concurrency
- Performance optimization techniques
- Ecosystem integration (React 19, Next.js 16, React Native)
- Production patterns and enterprise best practices

**Slide 4: Target Audience**
- React developers seeking Redux alternatives
- Frontend engineers replacing Context API
- Full-stack developers building scalable apps
- React Native developers needing lightweight state management
- Technical leads and architects

**Slide 5: Prerequisites**
- Intermediate JavaScript (ES2022+)
- React Hooks familiarity
- Basic TypeScript (recommended)
- Experience building React apps
- Understanding of async programming

**Slide 6: The Problem Statement**
- State management is often the most complex part of frontend apps
- Redux: Too much boilerplate
- Context API: Performance issues with frequent updates
- MobX: Magic proxies, hard to debug
- Recoil/Jotai: Provider overhead, learning curve

**Slide 7: Why Zustand?**
- Minimal API (~1KB bundle)
- No Provider required
- Fine-grained subscriptions
- Works outside React
- Excellent TypeScript support
- Middleware ecosystem
- DevTools integration
- Simple, predictable, performant

**Slide 8: Series Overview & Capstone Project**
- Part 1: Foundations & Core Concepts
- Part 2: Advanced State Architecture
- Part 3: Asynchronous State Management
- Part 4: Performance Optimization
- Part 5: Ecosystem Integration
- Part 6: Production Patterns
- Part 7: Testing
- Part 8: Enterprise Best Practices
- Capstone: TaskFlow Application

---

### Session 2: Understanding Zustand (1 Hour)
**Slide 9: What is Zustand?**
- German for "state"
- Created by the Poimandres team
- Small, fast, and scalable
- Solves state management challenges
- Philosophy: Simple, predictable, performant

**Slide 10: Zustand's Architecture**
- Store holds state and actions
- Components subscribe via selectors
- Fine-grained updates
- No Provider needed
- Works anywhere (React, Node, browsers)

**Slide 11: The Mental Model**
```
Store → State + Actions
  ↓
Components → Subscribe via selectors
  ↓
State changes → Only affected components re-render
```
- Think of it as a smart notification system

**Slide 12: Atomic State Management**
- State is broken into small, independent pieces
- Components subscribe to only what they need
- Benefits: Performance, maintainability, scalability

**Slide 13: Comparison: Zustand vs. Redux**
```
Redux (Traditional):
  Actions → Reducers → Store → Provider → useSelector/useDispatch

Zustand:
  create → Store → useStore(selector)
```
- Redux: 30+ lines for counter
- Zustand: 5 lines for counter

**Slide 14: Comparison: Zustand vs. Context API**
```
Context API:
  createContext → Provider → useContext → All consumers re-render

Zustand:
  create → useStore(selector) → Only subscribers re-render
```
- Context: All consumers re-render on ANY state change
- Zustand: Only consumers of changed state re-render

**Slide 15: Comparison: Zustand vs. MobX**
```
MobX:
  @observable → @action → @computed → observer
  Magic proxies, hard to debug

Zustand:
  create → set/get → selectors → explicit
  Clear, predictable, debuggable
```

**Slide 16: Comparison: Zustand vs. Recoil/Jotai**
```
Recoil/Jotai:
  atom → useAtom → Provider required
  Multiple atoms to manage

Zustand:
  create → useStore → No Provider
  Single store, multiple slices
```

**Slide 17: When to Use Zustand**
- Replace Redux boilerplate
- Replace Context API for complex state
- Build React Native apps
- Build Next.js apps with SSR
- Need simple, performant state management
- Want minimal bundle size
- Need state outside React

**Slide 18: Key Concepts Preview**
- Store creation: `create()`
- State: The data in the store
- Actions: Functions that update state
- Selectors: Extract specific pieces of state
- Subscriptions: Fine-grained re-renders
- Middleware: Extend store functionality

---

### Session 3: Creating Your First Store (1 Hour)
**Slide 19: Installation**
```bash
npm install zustand
# or
yarn add zustand
# or
pnpm add zustand
```

**Slide 20: Your First Store**
```typescript
import { create } from 'zustand';

const useStore = create((set) => ({
  count: 0,
  increment: () => set((state) => ({ count: state.count + 1 })),
  decrement: () => set((state) => ({ count: state.count - 1 })),
  reset: () => set({ count: 0 }),
}));
```

**Slide 21: Understanding the `create` Function**
```typescript
create<T>((set, get, store) => ({
  // state
  // actions
}))
```
- `set`: Updates state (like `setState`)
- `get`: Reads current state
- `store`: The store instance (for middleware)

**Slide 22: Using the Store in Components**
```tsx
function Counter() {
  const count = useStore((state) => state.count);
  const increment = useStore((state) => state.increment);
  
  return <button onClick={increment}>{count}</button>;
}
```

**Slide 23: TypeScript Support**
```typescript
interface CounterStore {
  count: number;
  increment: () => void;
  decrement: () => void;
  reset: () => void;
}

const useStore = create<CounterStore>((set) => ({
  count: 0,
  increment: () => set((state) => ({ count: state.count + 1 })),
  decrement: () => set((state) => ({ count: state.count - 1 })),
  reset: () => set({ count: 0 }),
}));
```

**Slide 24: State vs. Actions**
- State: Data (e.g., `count`, `user`, `tasks`)
- Actions: Functions that update state (e.g., `increment`, `setUser`, `addTask`)

**Slide 25: Primitive and Object State**
```typescript
// Primitive state
const useStore = create((set) => ({
  count: 0,
  name: 'Alice',
  isActive: true,
}));

// Object state
const useStore = create((set) => ({
  user: { name: 'Alice', email: 'alice@example.com' },
  preferences: { theme: 'dark', language: 'en' },
}));
```

**Slide 26: Organizing Store Files**
```
src/
├── store/
│   ├── counterStore.ts
│   ├── userStore.ts
│   └── taskStore.ts
```
- One file per domain
- Export the store and its types
- Keep stores focused

**Slide 27: Live Demo: Counter Store**
- Create a counter store
- Add increment/decrement actions
- Use in React component
- Show re-render behavior

**Slide 28: Lab: Create Your First Store**
- Create a todo store
- Add/remove/toggle todos
- Display in React
- Add TypeScript types

---

### Session 4: Reading State Efficiently (1.5 Hours)
**Slide 29: The `useStore` Hook**
```typescript
// Subscribe to specific state
const count = useStore((state) => state.count);
```
- Selectors extract specific pieces of state
- Components only re-render when selected state changes

**Slide 30: Understanding Selectors**
```typescript
// ❌ Bad: Subscribes to everything
const store = useStore();

// ✅ Good: Subscribes only to what's needed
const count = useStore((state) => state.count);
```
- Selector functions are called with the current state
- They return the specific piece of state the component needs

**Slide 31: Preventing Unnecessary Re-renders**
```typescript
function TaskCounter() {
  const count = useStore((state) => state.taskIds.length);
  // Only re-renders when taskIds.length changes
  return <div>Total tasks: {count}</div>;
}

function TaskItem({ id }) {
  const task = useStore((state) => state.tasks[id]);
  // Only re-renders when this specific task changes
  return <div>{task.text}</div>;
}
```

**Slide 32: The `useShallow` Hook**
```typescript
import { useShallow } from 'zustand/react/shallow';

function Component() {
  const { user, settings } = useStore(
    useShallow((state) => ({
      user: state.user,
      settings: state.settings,
    }))
  );
  // Only re-renders when user or settings actually change
  return <div>{user.name} - {settings.theme}</div>;
}
```

**Slide 33: Why `useShallow` Matters**
```typescript
// ❌ Bad: New object every render
const { user, settings } = useStore((state) => ({
  user: state.user,
  settings: state.settings,
}));
// Even if state hasn't changed, this is a new object → re-render

// ✅ Good: Shallow comparison
const { user, settings } = useStore(
  useShallow((state) => ({
    user: state.user,
    settings: state.settings,
  }))
);
// Only re-renders when user or settings change
```

**Slide 34: Splitting Selectors for Performance**
```typescript
// ❌ Bad: One selector for multiple values
const { tasks, loading, error } = useStore((state) => ({
  tasks: state.tasks,
  loading: state.loading,
  error: state.error,
}));

// ✅ Good: Multiple focused selectors
const tasks = useStore((state) => state.tasks);
const loading = useStore((state) => state.loading);
const error = useStore((state) => state.error);
```

**Slide 35: Memoized Selectors with `reselect`**
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

const filteredTasks = useStore(selectFilteredTasks);
```

**Slide 36: Performance Anti-Patterns**
```typescript
// ❌ Inline selector function (recreated each render)
const activeTasks = useStore((state) => 
  state.tasks.filter(t => !t.completed)
);

// ✅ Extract selector
const selectActiveTasks = (state) => state.tasks.filter(t => !t.completed);
const activeTasks = useStore(selectActiveTasks);
```

**Slide 37: Live Demo: Selector Performance**
- Create a component with poor selector performance
- Show how to optimize it
- Use React DevTools to measure re-renders
- Add render counters

**Slide 38: Lab: Optimizing Component Subscriptions**
- Take a poorly optimized component
- Add focused selectors
- Use `useShallow`
- Extract and memoize selectors

---

### Session 5: Updating State (1.5 Hours)
**Slide 39: The `set` Function**
```typescript
// Object update
set({ count: 1 });

// Functional update (preferred)
set((state) => ({ count: state.count + 1 }));

// Replace state (instead of merge)
set({ count: 1 }, true);
```

**Slide 40: Functional vs. Object Updates**
```typescript
// ❌ Race condition with object update
const addTask = (text) => {
  const currentTasks = get().tasks;
  set({ tasks: [...currentTasks, { text }] });
};
// Multiple calls can overwrite each other

// ✅ Safe with functional update
const addTask = (text) => {
  set((state) => ({
    tasks: [...state.tasks, { text }]
  }));
};
// Uses latest state
```

**Slide 41: Immutable Updates**
```typescript
// ❌ Wrong: Direct mutation
set((state) => {
  state.tasks.push(newTask);
  return state;
});

// ✅ Correct: Immutable update
set((state) => ({
  tasks: [...state.tasks, newTask]
}));
```

**Slide 42: Updating Nested Objects**
```typescript
// ❌ Wrong: Shallow copy only
set((state) => ({
  user: {
    ...state.user,
    preferences: { theme: 'dark' } // Lost other preferences!
  }
}));

// ✅ Correct: Deep copy
set((state) => ({
  user: {
    ...state.user,
    preferences: {
      ...state.user.preferences,
      theme: 'dark'
    }
  }
}));
```

**Slide 43: Multiple State Mutations**
```typescript
// ❌ Bad: Multiple updates (multiple re-renders)
set({ loading: true });
set({ tasks: newTasks });
set({ loading: false });

// ✅ Good: Single update (one re-render)
set({
  tasks: newTasks,
  loading: false,
  error: null,
});
```

**Slide 44: Resetting State**
```typescript
const initialState = {
  tasks: [],
  loading: false,
  error: null,
};

const useStore = create((set) => ({
  ...initialState,
  reset: () => set(initialState),
}));
```

**Slide 45: Partial Updates**
```typescript
// Update specific fields
set({ theme: 'dark' });

// Update nested fields
set((state) => ({
  user: {
    ...state.user,
    preferences: {
      ...state.user.preferences,
      notifications: false,
    },
  },
}));
```

**Slide 46: Live Demo: Update Patterns**
- Show functional vs. object updates
- Demonstrate immutable updates with nested objects
- Batch multiple updates
- Reset state

**Slide 47: Lab: State Updates**
- Create a form store with fields
- Implement field updates
- Add validation
- Reset form

---

### Session 6: Vanilla Stores (1 Hour)
**Slide 48: What Are Vanilla Stores?**
- Zustand stores without React
- Created with `createStore`
- Use in utility modules, service layers, Node.js
- Share state between React and non-React code

**Slide 49: Creating a Vanilla Store**
```typescript
import { createStore } from 'zustand/vanilla';

const store = createStore((set) => ({
  count: 0,
  increment: () => set((state) => ({ count: state.count + 1 })),
}));
```

**Slide 50: Using Vanilla Stores**
```typescript
// Get state
store.getState();

// Update state
store.setState({ count: 5 });

// Subscribe to changes
const unsubscribe = store.subscribe((state) => {
  console.log('State changed:', state);
});

// Destroy (clean up)
store.destroy();
```

**Slide 51: Connecting Vanilla Stores to React**
```typescript
import { useStore } from 'zustand';

function Counter() {
  const count = useStore(store, (state) => state.count);
  const increment = useStore(store, (state) => state.increment);
  return <button onClick={increment}>{count}</button>;
}
```

**Slide 52: Vanilla Stores in Utility Modules**
```typescript
// utils/counter.ts
import { createStore } from 'zustand/vanilla';

export const counterStore = createStore((set) => ({
  count: 0,
  increment: () => set((state) => ({ count: state.count + 1 })),
}));

// service.ts
import { counterStore } from './counter';

export function logCount() {
  console.log('Current count:', counterStore.getState().count);
}
```

**Slide 53: Event-Driven Architectures**
```typescript
// Subscribe to changes
const unsubscribe = store.subscribe((state, prevState) => {
  if (state.count !== prevState.count) {
    console.log('Count changed from', prevState.count, 'to', state.count);
    // Trigger side effects
    updateUI();
  }
});
```

**Slide 54: Vanilla Stores in Node.js**
```typescript
// server.js
import { createStore } from 'zustand/vanilla';

const store = createStore((set) => ({
  data: [],
  addData: (item) => set((state) => ({ data: [...state.data, item] })),
}));

// Background tasks
setInterval(() => {
  const state = store.getState();
  console.log('Data length:', state.data.length);
}, 1000);
```

**Slide 55: Live Demo: Vanilla Store**
- Create a vanilla store
- Use it in a React component
- Use it in a Node.js script
- Share state between React and Node

**Slide 56: Lab: Vanilla Store Integration**
- Create a vanilla store
- Use it in React
- Use it in a utility module
- Subscribe to changes

---

## Day 2: Advanced State Architecture (8 Hours)

### Session 7: Structuring Large Applications (1.5 Hours)
**Slide 57: The Problem with Monolithic Stores**
```typescript
// ❌ Monolithic store
const useStore = create((set) => ({
  users: [],
  tasks: [],
  notifications: [],
  theme: 'light',
  sidebarOpen: true,
  // 50+ more fields...
  // 100+ actions...
}));
```
- Hard to maintain
- Team conflicts
- Performance issues

**Slide 58: Feature-Based Stores**
```
src/
├── domains/
│   ├── user/
│   │   └── store/
│   │       └── userStore.ts
│   ├── task/
│   │   └── store/
│   │       └── taskStore.ts
│   └── ui/
│       └── store/
│           └── uiStore.ts
```

**Slide 59: Domain-Driven Organization**
```
src/
├── domains/
│   ├── user/
│   │   ├── store/
│   │   ├── components/
│   │   ├── services/
│   │   └── types/
│   ├── task/
│   │   └── ...
│   └── ui/
│       └── ...
├── shared/
│   ├── store/
│   ├── hooks/
│   └── utils/
└── infrastructure/
    ├── api/
    └── logging/
```

**Slide 60: The Slice Pattern**
```typescript
// userSlice.ts
const userSlice = (set, get) => ({
  user: null,
  setUser: (user) => set({ user }),
});

// taskSlice.ts
const taskSlice = (set, get) => ({
  tasks: [],
  addTask: (task) => set((state) => ({
    tasks: [...state.tasks, task],
  })),
});

// Store combining slices
const useStore = create((set, get) => ({
  ...userSlice(set, get),
  ...taskSlice(set, get),
}));
```

**Slide 61: Store Composition**
```typescript
// Shared state can be composed
const useStore = create((set) => ({
  // Independent state
  count: 0,
  increment: () => set((state) => ({ count: state.count + 1 })),
  
  // Derived state (from other stores)
  total: 0,
  updateTotal: () => {
    const userStore = useUserStore.getState();
    const taskStore = useTaskStore.getState();
    set({ total: userStore.users.length + taskStore.tasks.length });
  },
}));
```

**Slide 62: Avoiding Monolithic Stores**
- **Signs**: Store > 50 fields, > 20 actions
- **Solution**: Split by domain, frequency, render impact
- **Pattern**: One store per domain
- **Rule**: Each store should have a single responsibility

**Slide 63: Live Demo: Store Organization**
- Show a monolithic store
- Refactor into feature-based stores
- Use slice pattern
- Show team organization benefits

**Slide 64: Lab: Refactoring to Slices**
- Take a monolithic store
- Split into feature-based stores
- Use slice pattern
- Update components

---

### Session 8: Middleware (1.5 Hours)
**Slide 65: What is Middleware?**
- Functions that wrap Zustand stores
- Add functionality without changing the store
- Plugins for your store
- Examples: Logging, persistence, devtools

**Slide 66: How Middleware Works**
```
┌─────────────────────────────────────┐
│  Middleware 1                       │
│  ┌─────────────────────────────────┐│
│  │  Middleware 2                   ││
│  │  ┌─────────────────────────────┐││
│  │  │  Store                      │││
│  │  └─────────────────────────────┘││
│  └─────────────────────────────────┘│
└─────────────────────────────────────┘
```
- Middleware wraps the store from inside out
- Each middleware can intercept `set`

**Slide 67: Built-in Middleware**
- `devtools`: Redux DevTools integration
- `persist`: Save/restore state
- `immer`: Immutable updates with mutable syntax
- `subscribeWithSelector`: Selective subscriptions
- `combine`: Combine state and actions

**Slide 68: Using `devtools` Middleware**
```typescript
import { create } from 'zustand';
import { devtools } from 'zustand/middleware';

const useStore = create(
  devtools(
    (set) => ({
      count: 0,
      increment: () => set((state) => ({ count: state.count + 1 })),
    }),
    { name: 'Counter Store' }
  )
);
```

**Slide 69: Using `persist` Middleware**
```typescript
import { create } from 'zustand';
import { persist } from 'zustand/middleware';

const useStore = create(
  persist(
    (set) => ({
      user: null,
      setUser: (user) => set({ user }),
    }),
    { name: 'user-storage' }
  )
);
// Automatically saves to localStorage
// Automatically loads on page load
```

**Slide 70: Using `immer` Middleware**
```typescript
import { create } from 'zustand';
import { immer } from 'zustand/middleware/immer';

const useStore = create(
  immer((set) => ({
    user: { name: 'Alice', preferences: { theme: 'dark' } },
    updateTheme: (theme) => {
      set((state) => {
        state.user.preferences.theme = theme; // Mutable!
      });
    },
  }))
);
```

**Slide 71: Using `subscribeWithSelector` Middleware**
```typescript
import { create } from 'zustand';
import { subscribeWithSelector } from 'zustand/middleware';

const useStore = create(
  subscribeWithSelector((set) => ({
    count: 0,
    increment: () => set((state) => ({ count: state.count + 1 })),
  }))
);

// Subscribe to a specific piece of state
const unsubscribe = useStore.subscribe(
  (state) => state.count,
  (count) => console.log('Count:', count)
);
```

**Slide 72: Middleware Composition**
```typescript
import { create } from 'zustand';
import { devtools, persist, subscribeWithSelector } from 'zustand/middleware';

const useStore = create(
  devtools(                      // Outer: debugging
    persist(                     // Middle: persistence
      subscribeWithSelector(     // Inner: subscription
        (set) => ({
          count: 0,
          increment: () => set((state) => ({ count: state.count + 1 })),
        })
      ),
      { name: 'storage' }
    ),
    { name: 'App Store' }
  )
);
```
- Order matters: devtools outermost, subscription innermost

**Slide 73: Execution Order**
```
1. Action is called
2. subscribeWithSelector intercepts
3. persist intercepts
4. devtools intercepts
5. Actual state update
6. devtools logs change
7. persist saves to storage
8. subscribeWithSelector notifies
```

**Slide 74: Live Demo: Middleware Composition**
- Set up devtools + persist + immer together
- Show execution order
- Demonstrate each middleware's effect

**Slide 75: Lab: Implementing Middleware**
- Add devtools to your store
- Add persist to persist user preferences
- Use immer for nested updates

---

### Session 9: Immutability with Immer (1 Hour)
**Slide 76: Why Immutability Matters**
- React uses reference equality to detect changes
- Zustand uses `Object.is` to detect changes
- Mutating state leads to bugs and performance issues

**Slide 77: The Problem with Nested State**
```typescript
// Without Immer: Deep nesting is painful
set((state) => ({
  user: {
    ...state.user,
    preferences: {
      ...state.user.preferences,
      notifications: {
        ...state.user.preferences.notifications,
        email: false,
      },
    },
  },
}));
```

**Slide 78: Enter Immer**
```typescript
import { immer } from 'zustand/middleware/immer';

const useStore = create(
  immer((set) => ({
    user: {
      preferences: {
        notifications: { email: true, push: true },
      },
    },
    // With Immer: Mutable syntax, immutable result
    toggleEmail: () => {
      set((state) => {
        state.user.preferences.notifications.email = 
          !state.user.preferences.notifications.email;
      });
    },
  }))
);
```

**Slide 79: How Immer Works**
```
Original State → Draft (Proxy) → Mutate Draft → Immutable Result
```
- Immer creates a draft of your state
- You mutate the draft (mutable syntax)
- Immer produces an immutable copy
- Structural sharing minimizes overhead

**Slide 80: Immer Performance**
- Immer has some overhead (proxies)
- Usually fast enough for most apps
- Use manual updates for simple state
- Use Immer for complex nested updates

**Slide 81: When to Use Immer**
- ✅ Deep nested state
- ✅ Frequent complex updates
- ✅ Collections (Set, Map)
- ❌ Simple primitive updates
- ❌ Bulk updates with no mutations

**Slide 82: Live Demo: Immer Deep Updates**
- Show deep update without Immer (painful)
- Show same update with Immer (clean)
- Show performance comparison

**Slide 83: Lab: Converting to Immer**
- Take a store with deeply nested state
- Add Immer middleware
- Convert complex updates to mutable syntax

---

### Session 10: State Persistence (1.5 Hours)
**Slide 84: Why Persist State?**
- User expects state to survive page refresh
- Common needs: User authentication, preferences, cart
- Improves user experience
- Reduces server load

**Slide 85: Using the `persist` Middleware**
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
    }
  )
);
```

**Slide 86: Partial Persistence**
```typescript
const useStore = create(
  persist(
    (set) => ({
      user: null,
      isLoading: false, // Don't persist
      error: null, // Don't persist
      theme: 'light',
    }),
    {
      name: 'app-storage',
      partialize: (state) => ({
        user: state.user,
        theme: state.theme,
        // isLoading, error are NOT persisted
      }),
    }
  )
);
```

**Slide 87: Custom Storage Adapters**
```typescript
// SessionStorage (cleared when tab closes)
const useStore = create(
  persist(
    (set) => ({ /* ... */ }),
    {
      name: 'session-storage',
      storage: createJSONStorage(() => sessionStorage),
    }
  )
);

// IndexedDB (larger storage, async)
import { get, set, del } from 'idb-keyval';

const indexedDBStorage = {
  getItem: async (key) => await get(key) || null,
  setItem: async (key, value) => await set(key, value),
  removeItem: async (key) => await del(key),
};

const useStore = create(
  persist(
    (set) => ({ /* ... */ }),
    {
      name: 'indexeddb-storage',
      storage: indexedDBStorage,
    }
  )
);
```

**Slide 88: Versioning and Migrations**
```typescript
const useStore = create(
  persist(
    (set) => ({ /* ... */ }),
    {
      name: 'app-storage',
      version: 1,
      migrate: (persistedState, version) => {
        if (version === 0) {
          // Old schema had `taskList`, new has `tasks`
          return {
            tasks: persistedState.taskList || [],
            taskIds: (persistedState.taskList || []).map(t => t.id),
          };
        }
        return persistedState;
      },
    }
  )
);
```

**Slide 89: Hydration Lifecycle**
```typescript
const useStore = create(
  persist(
    (set) => ({ /* ... */ }),
    {
      name: 'app-storage',
      onRehydrateStorage: () => (state, error) => {
        if (error) {
          console.error('Hydration failed:', error);
        } else {
          console.log('Hydration successful:', state);
          // Perform actions after hydration
        }
      },
    }
  )
);
```

**Slide 90: React Native Persistence**
```typescript
import AsyncStorage from '@react-native-async-storage/async-storage';

const useStore = create(
  persist(
    (set) => ({ /* ... */ }),
    {
      name: 'app-storage',
      storage: createJSONStorage(() => AsyncStorage),
    }
  )
);
```

**Slide 91: Live Demo: Persistence**
- Set up persist middleware
- Add partialization
- Show versioning and migrations

**Slide 92: Lab: Adding Persistence**
- Add persistence to your store
- Configure partialization
- Test page reload

---

### Session 11: Debugging (1 Hour)
**Slide 93: Redux DevTools Integration**
```typescript
import { create } from 'zustand';
import { devtools } from 'zustand/middleware';

const useStore = create(
  devtools(
    (set) => ({
      count: 0,
      increment: () => set((state) => ({ count: state.count + 1 })),
    }),
    { name: 'Counter Store' }
  )
);
```

**Slide 94: Naming Actions**
```typescript
// Without names (hard to debug)
set({ count: 1 });

// With names (clear in DevTools)
set({ count: 1 }, false, 'increment');
set({ user }, false, 'user/set');
```

**Slide 95: Time-Travel Debugging**
- Jump to any state in history
- Skip actions to see effects
- Export/import state
- Persist across reloads

**Slide 96: Custom Logging Middleware**
```typescript
const logger = (config) => (set, get, store) => {
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

**Slide 97: Debugging Async Updates**
```typescript
fetchData: async () => {
  const requestId = Date.now();
  console.log(`[${requestId}] Starting fetch`);
  set({ loading: true });
  try {
    const data = await fetch('/api/data');
    console.log(`[${requestId}] Data received`);
    set({ data, loading: false });
  } catch (error) {
    console.error(`[${requestId}] Error:`, error);
    set({ error: error.message, loading: false });
  }
}
```

**Slide 98: Debugging Performance Issues**
```typescript
// Track render counts
function RenderCounter({ name }) {
  const renderCount = useRef(0);
  renderCount.current++;
  return <span>Renders: {renderCount.current}</span>;
}

// Track state size
const stateSize = new Blob([JSON.stringify(state)]).size;
console.log(`State size: ${(stateSize / 1024).toFixed(1)} KB`);
```

**Slide 99: Live Demo: Debugging**
- Set up devtools
- Show time-travel debugging
- Add logging middleware

**Slide 100: Lab: Debugging Setup**
- Add devtools to your store
- Add logging middleware
- Debug an issue

---

## Day 3: Asynchronous State Management (8 Hours)

### Session 12: Async Actions (1.5 Hours)
**Slide 101: The Async Pattern**
```typescript
fetchData: async () => {
  // 1. Set loading state
  set({ loading: true, error: null });
  
  try {
    // 2. Perform async operation
    const data = await api.getData();
    
    // 3. Update with success
    set({ data, loading: false });
  } catch (error) {
    // 4. Update with error
    set({ error: error.message, loading: false });
  }
}
```

**Slide 102: Loading Indicators**
```typescript
interface Store {
  data: any[];
  loading: boolean;
  fetchData: () => Promise<void>;
}

function Component() {
  const { data, loading, fetchData } = useStore();
  
  if (loading) return <div>Loading...</div>;
  return <div>{data.map(item => <div key={item.id}>{item.name}</div>)}</div>;
}
```

**Slide 103: Error Handling**
```typescript
try {
  const response = await fetch('/api/data');
  if (!response.ok) {
    throw new Error(`HTTP ${response.status}: ${response.statusText}`);
  }
  const data = await response.json();
  set({ data, loading: false });
} catch (error) {
  set({
    error: error instanceof Error ? error.message : 'Unknown error',
    loading: false,
  });
}
```

**Slide 104: Retry Mechanisms**
```typescript
const fetchWithRetry = async (url, maxRetries = 3, delay = 1000) => {
  let attempt = 0;
  while (attempt < maxRetries) {
    try {
      const response = await fetch(url);
      if (response.ok) return response.json();
    } catch (error) {
      attempt++;
      if (attempt >= maxRetries) throw error;
      await new Promise(resolve => setTimeout(resolve, delay * Math.pow(2, attempt - 1)));
    }
  }
};
```

**Slide 105: Request Cancellation with AbortController**
```typescript
let controller: AbortController | null = null;

fetchData: async (query) => {
  // Cancel previous request
  if (controller) {
    controller.abort();
  }
  
  controller = new AbortController();
  set({ loading: true });
  
  try {
    const response = await fetch(`/api/search?q=${query}`, {
      signal: controller.signal,
    });
    const data = await response.json();
    set({ data, loading: false });
  } catch (error) {
    if (error.name === 'AbortError') {
      console.log('Request cancelled');
    } else {
      set({ error: error.message, loading: false });
    }
  }
};
```

**Slide 106: Live Demo: Async Actions**
- Fetch data with loading and error states
- Add retry mechanism
- Add cancellation

**Slide 107: Lab: Async Data Fetching**
- Create an async store
- Fetch data from an API
- Handle loading and error states

---

### Session 13: Concurrency & Race Conditions (1.5 Hours)
**Slide 108: The Race Condition Problem**
```typescript
// ❌ Race condition
fetchUser: async (id) => {
  const response = await fetch(`/api/users/${id}`);
  const user = await response.json();
  set({ user }); // If id changes mid-request, stale data overwrites
}
```

**Slide 109: Request Deduplication**
```typescript
const pendingRequests = new Map();

fetchUser: async (id) => {
  const key = `user-${id}`;
  if (pendingRequests.has(key)) {
    return pendingRequests.get(key);
  }
  
  const promise = (async () => {
    const response = await fetch(`/api/users/${id}`);
    const user = await response.json();
    set({ user });
    return user;
  })();
  
  pendingRequests.set(key, promise);
  try {
    return await promise;
  } finally {
    pendingRequests.delete(key);
  }
}
```

**Slide 110: Request ID Tracking**
```typescript
fetchUser: async (id) => {
  const requestId = `req-${Date.now()}`;
  set({ requestId, loading: true });
  
  try {
    const response = await fetch(`/api/users/${id}`);
    const user = await response.json();
    
    // Only update if this is the latest request
    set((state) => {
      if (state.requestId !== requestId) return state;
      return { user, loading: false };
    });
  } catch (error) {
    set((state) => {
      if (state.requestId !== requestId) return state;
      return { error: error.message, loading: false };
    });
  }
}
```

**Slide 111: Optimistic Updates with Rollback**
```typescript
addItem: async (item) => {
  // Optimistic: Add immediately
  const tempId = `temp-${Date.now()}`;
  set((state) => ({
    items: [...state.items, { ...item, id: tempId, optimistic: true }],
  }));
  
  try {
    const saved = await api.save(item);
    // Replace optimistic with real
    set((state) => ({
      items: state.items.map(i =>
        i.id === tempId ? { ...saved, optimistic: false } : i
      ),
    }));
  } catch (error) {
    // Rollback on failure
    set((state) => ({
      items: state.items.filter(i => i.id !== tempId),
      error: error.message,
    }));
  }
}
```

**Slide 112: Debounced Search**
```typescript
import { debounce } from 'lodash';

const debouncedSearch = useCallback(
  debounce((query) => {
    store.search(query);
  }, 300),
  []
);

const handleSearch = (e) => {
  const value = e.target.value;
  setQuery(value);
  debouncedSearch(value);
};
```

**Slide 113: Live Demo: Race Conditions**
- Show race condition
- Add request ID tracking
- Add optimistic updates

**Slide 114: Lab: Preventing Race Conditions**
- Add request deduplication
- Add optimistic updates

---

### Session 14: Working with External APIs (1.5 Hours)
**Slide 115: REST API Integration**
```typescript
import { create } from 'zustand';

const useStore = create((set) => ({
  posts: [],
  loading: false,
  error: null,
  fetchPosts: async () => {
    set({ loading: true, error: null });
    try {
      const response = await fetch('https://api.example.com/posts');
      const data = await response.json();
      set({ posts: data, loading: false });
    } catch (error) {
      set({ error: error.message, loading: false });
    }
  },
}));
```

**Slide 116: GraphQL Integration**
```typescript
const graphqlRequest = async (query, variables) => {
  const response = await fetch('/graphql', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ query, variables }),
  });
  const result = await response.json();
  if (result.errors) {
    throw new Error(result.errors[0].message);
  }
  return result.data;
};

const useStore = create((set) => ({
  data: null,
  fetchData: async () => {
    const query = `query { users { id name } }`;
    const data = await graphqlRequest(query);
    set({ data });
  },
}));
```

**Slide 117: WebSocket Integration**
```typescript
class WebSocketService {
  private ws: WebSocket | null = null;
  
  connect() {
    this.ws = new WebSocket('wss://api.example.com/ws');
    this.ws.onmessage = (event) => {
      const data = JSON.parse(event.data);
      useStore.getState().handleMessage(data);
    };
  }
  
  send(type, payload) {
    if (this.ws?.readyState === WebSocket.OPEN) {
      this.ws.send(JSON.stringify({ type, payload }));
    }
  }
}
```

**Slide 118: SSE (Server-Sent Events)**
```typescript
const eventSource = new EventSource('/events');

eventSource.onmessage = (event) => {
  const data = JSON.parse(event.data);
  useStore.getState().handleEvent(data);
};

eventSource.addEventListener('task_update', (event) => {
  const data = JSON.parse(event.data);
  useStore.getState().addTask(data);
});
```

**Slide 119: Polling for Periodic Updates**
```typescript
const useStore = create((set) => ({
  data: [],
  pollInterval: null,
  startPolling: (intervalMs = 30000) => {
    const id = setInterval(() => {
      get().fetchData();
    }, intervalMs);
    set({ pollInterval: id });
  },
  stopPolling: () => {
    const id = get().pollInterval;
    if (id) {
      clearInterval(id);
      set({ pollInterval: null });
    }
  },
}));
```

**Slide 120: Live Demo: API Integration**
- REST API fetch
- GraphQL query
- WebSocket connection

**Slide 121: Lab: External API Integration**
- Fetch data from a REST API
- Handle loading/error states

---

### Session 15: Custom Middleware (1.5 Hours)
**Slide 122: Understanding Middleware Structure**
```typescript
type Middleware<T> = (
  config: StateCreator<T, [], []>
) => StateCreator<T, [], []>;

const myMiddleware = <T>(config: StateCreator<T>): StateCreator<T> => {
  return (set, get, store) => {
    // Wrap set function
    const wrappedSet = (args) => {
      // Before update
      console.log('Before:', get());
      set(args);
      // After update
      console.log('After:', get());
    };
    return config(wrappedSet, get, store);
  };
};
```

**Slide 123: Logging Middleware**
```typescript
const createLogger = (options) => {
  return (config) => (set, get, store) => {
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
};
```

**Slide 124: Validation Middleware**
```typescript
const createValidator = (rules) => {
  return (config) => (set, get, store) => {
    return config(
      (args) => {
        const nextState = typeof args === 'function'
          ? args(get())
          : { ...get(), ...args };
        
        for (const rule of rules) {
          if (!rule.validate(nextState[rule.field])) {
            throw new Error(rule.message);
          }
        }
        set(args);
      },
      get,
      store
    );
  };
};
```

**Slide 125: Analytics Middleware**
```typescript
const createAnalytics = (provider) => {
  return (config) => (set, get, store) => {
    return config(
      (args) => {
        const prevState = get();
        set(args);
        const nextState = get();
        
        provider.track({
          event: 'state_update',
          properties: {
            action: typeof args === 'function' ? 'functional' : 'object',
            changes: getDiff(prevState, nextState),
          },
        });
      },
      get,
      store
    );
  };
};
```

**Slide 126: Performance Monitoring Middleware**
```typescript
const createPerformanceMonitor = (threshold = 50) => {
  return (config) => (set, get, store) => {
    return config(
      (args) => {
        const start = performance.now();
        set(args);
        const duration = performance.now() - start;
        if (duration > threshold) {
          console.warn(`Slow update: ${duration.toFixed(2)}ms`);
        }
      },
      get,
      store
    );
  };
};
```

**Slide 127: Combining Middleware**
```typescript
const useStore = create(
  devtools(
    persist(
      logger(
        validator(
          analytics(
            performanceMonitor(
              (set) => ({ /* ... */ })
            )
          )
        )
      )
    )
  )
);
```

**Slide 128: Live Demo: Custom Middleware**
- Build logging middleware
- Build validation middleware
- Compose multiple middleware

**Slide 129: Lab: Custom Middleware**
- Build a logging middleware
- Build a performance monitoring middleware

---

## Day 4: Performance Optimization & Ecosystem (8 Hours)

### Session 16: Rendering Optimization (1.5 Hours)
**Slide 130: Fine-Grained Subscriptions**
```typescript
// ✅ Good: Subscribe only to what's needed
const count = useStore((state) => state.count);
const name = useStore((state) => state.user.name);

// ❌ Bad: Subscribe to everything
const store = useStore();
```

**Slide 131: Optimizing Selectors**
```typescript
// ✅ Extract selectors
const selectTasks = (state) => state.tasks;
const selectFilter = (state) => state.filter;

const filteredTasks = useStore(selectFilteredTasks);

// ✅ Use memoized selectors
import { createSelector } from 'reselect';

const selectFilteredTasks = createSelector(
  [selectTasks, selectFilter],
  (tasks, filter) => tasks.filter(task => task.status === filter)
);
```

**Slide 132: Using `useShallow`**
```typescript
import { useShallow } from 'zustand/react/shallow';

function Component() {
  const { user, settings } = useStore(
    useShallow((state) => ({
      user: state.user,
      settings: state.settings,
    }))
  );
  // Only re-renders when user or settings change
  return <div>{user.name} - {settings.theme}</div>;
}
```

**Slide 133: Memoization Strategies**
```typescript
// ✅ useMemo for derived state
const tasks = useStore((state) => state.tasks);
const filteredTasks = useMemo(() => 
  tasks.filter(t => t.completed),
  [tasks]
);

// ✅ React.memo for components
const TaskItem = memo(({ task }) => {
  return <div>{task.title}</div>;
});
```

**Slide 134: Avoiding Over-Subscription**
```typescript
// ❌ Bad: Parent subscribes and passes down
function Parent() {
  const tasks = useStore((state) => state.tasks);
  return tasks.map(task => <Child task={task} />);
}
// Every task change re-renders ALL children

// ✅ Good: Each child subscribes independently
function Child({ taskId }) {
  const task = useStore((state) => state.tasks[taskId]);
  // Only re-renders when this task changes
  return <div>{task.title}</div>;
}
```

**Slide 135: Live Demo: Rendering Optimization**
- Show before/after optimization
- Measure render counts
- Use React DevTools Profiler

**Slide 136: Lab: Optimizing Component Rendering**
- Optimize subscriptions
- Add memoization

---

### Session 17: Store Design for Performance (1.5 Hours)
**Slide 137: State Normalization**
```typescript
// ❌ Denormalized: Hard to update
tasks: Task[];

// ✅ Normalized: Easy to update
tasks: Record<string, Task>;
taskIds: string[];
```

**Slide 138: Splitting Stores**
```typescript
// Hot store: Frequently updated
const useHotStore = create((set) => ({
  cursor: { x: 0, y: 0 },
  setCursor: (cursor) => set({ cursor }),
}));

// Cold store: Infrequently updated
const useColdStore = create((set) => ({
  user: null,
  setUser: (user) => set({ user }),
}));
```

**Slide 139: Lazy Initialization**
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

// Only created when first used
const store = getStore();
```

**Slide 140: Memory Management**
```typescript
const useStore = create((set) => ({
  history: [],
  maxHistory: 1000,
  addHistory: (entry) => {
    set((state) => ({
      history: [...state.history, entry].slice(-state.maxHistory),
    }));
  },
}));
```

**Slide 141: Preventing Cascading Updates**
```typescript
// Batch updates together
set({ tasks, loading: false, error: null });

// Use request ID to prevent stale updates
const requestId = Date.now();
set({ requestId });
// ... after async operation
set((state) => {
  if (state.requestId !== requestId) return state;
  return { data };
});
```

**Slide 142: Live Demo: Store Design**
- Show normalization
- Split stores
- Lazy initialization

**Slide 143: Lab: Store Optimization**
- Normalize state
- Split stores

---

### Session 18: Benchmarking (1.5 Hours)
**Slide 144: React Profiler**
```tsx
import { Profiler } from 'react';

function App() {
  return (
    <Profiler id="App" onRender={onRenderCallback}>
      <MainApp />
    </Profiler>
  );
}

function onRenderCallback(
  id, phase, actualDuration, baseDuration, startTime, commitTime
) {
  console.log(`${id} ${phase} took ${actualDuration}ms`);
  if (actualDuration > 5) {
    console.warn(`Slow render: ${id}`);
  }
}
```

**Slide 145: Performance Testing**
```typescript
async function measurePerformance(fn, iterations = 1000) {
  const times = [];
  // Warmup
  for (let i = 0; i < 100; i++) fn();
  // Measure
  for (let i = 0; i < iterations; i++) {
    const start = performance.now();
    fn();
    times.push(performance.now() - start);
  }
  return {
    average: times.reduce((a, b) => a + b, 0) / times.length,
    min: Math.min(...times),
    max: Math.max(...times),
  };
}
```

**Slide 146: State Size Monitoring**
```typescript
const stateSize = new Blob([JSON.stringify(state)]).size;
console.log(`State size: ${(stateSize / 1024).toFixed(1)} KB`);

// Monitor over time
setInterval(() => {
  const state = store.getState();
  const size = new Blob([JSON.stringify(state)]).size;
  console.log(`Current state size: ${(size / 1024).toFixed(1)} KB`);
}, 60000);
```

**Slide 147: DevTools Analysis**
- React DevTools: Profiler tab
- Redux DevTools: Performance tab
- Chrome DevTools: Performance tab
- Lighthouse: Performance audit

**Slide 148: Live Demo: Benchmarking**
- Use React Profiler
- Measure state size
- Identify bottlenecks

**Slide 149: Lab: Performance Testing**
- Add performance tests
- Measure state size

---

### Session 19: Zustand with React 19 (1.5 Hours)
**Slide 150: React 19 Features**
- Concurrent rendering
- Transitions (`useTransition`)
- `useActionState`
- `useOptimistic`
- Server Components

**Slide 151: Using `useTransition` with Zustand**
```tsx
function SearchComponent() {
  const [query, setQuery] = useState('');
  const [isPending, startTransition] = useTransition();
  const fetchResults = useStore((state) => state.fetchResults);
  
  const handleSearch = (e) => {
    const value = e.target.value;
    setQuery(value);
    // Mark as low priority
    startTransition(() => {
      fetchResults(value);
    });
  };
  
  return (
    <div>
      <input value={query} onChange={handleSearch} />
      {isPending && <div>Searching...</div>}
    </div>
  );
}
```

**Slide 152: Using `useOptimistic` with Zustand**
```tsx
function TaskList() {
  const tasks = useStore((state) => state.tasks);
  const addTask = useStore((state) => state.addTask);
  
  const [optimisticTasks, addOptimisticTask] = useOptimistic(
    tasks,
    (currentTasks, newTask) => [...currentTasks, { ...newTask, optimistic: true }]
  );
  
  const handleAdd = (title) => {
    const newTask = { id: Date.now(), title, completed: false };
    addOptimisticTask(newTask);
    addTask(newTask);
  };
}
```

**Slide 153: Using `useActionState` with Zustand**
```tsx
function TaskForm() {
  const addTask = useStore((state) => state.addTask);
  const [state, action, isPending] = useActionState(
    async (prevState, formData) => {
      const title = formData.get('title');
      await addTask(title);
      return { success: true };
    },
    { success: false }
  );
  
  return (
    <form action={action}>
      <input name="title" />
      <button type="submit" disabled={isPending}>
        {isPending ? 'Adding...' : 'Add Task'}
      </button>
    </form>
  );
}
```

**Slide 154: Server Components + Zustand**
```tsx
// Server Component
export default async function Page() {
  const tasks = await fetchTasks();
  return <ClientTaskList initialTasks={tasks} />;
}

// Client Component
'use client';

import { useEffect } from 'react';
import { useTaskStore } from '@taskflow/shared';

export function ClientTaskList({ initialTasks }) {
  const setTasks = useTaskStore((state) => state.setTasks);
  
  useEffect(() => {
    setTasks(initialTasks);
  }, []);
  
  const tasks = useTaskStore((state) => state.tasks);
  return <div>{tasks.length}</div>;
}
```

**Slide 155: Live Demo: React 19 Integration**
- Use `useTransition` with Zustand
- Use `useOptimistic` with Zustand

**Slide 156: Lab: React 19 Integration**
- Add `useTransition` to a search
- Add `useOptimistic` to task creation

---

### Session 20: Zustand with React Native (1.5 Hours)
**Slide 157: React Native Setup**
```bash
npx create-expo-app ZustandNative
cd ZustandNative
npx expo install zustand @react-native-async-storage/async-storage
```

**Slide 158: Mobile Store with AsyncStorage**
```typescript
import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';
import AsyncStorage from '@react-native-async-storage/async-storage';

const useStore = create(
  persist(
    (set) => ({
      tasks: [],
      addTask: (task) => set((state) => ({ tasks: [...state.tasks, task] })),
    }),
    {
      name: 'task-storage',
      storage: createJSONStorage(() => AsyncStorage),
    }
  )
);
```

**Slide 159: Fast Storage with MMKV**
```typescript
import { MMKV } from 'react-native-mmkv';

const mmkv = new MMKV({ id: 'app-storage' });

const mmkvStorage = {
  getItem: (key) => mmkv.getString(key) || null,
  setItem: (key, value) => mmkv.set(key, value),
  removeItem: (key) => mmkv.delete(key),
};

const useStore = create(
  persist(
    (set) => ({ /* ... */ }),
    {
      name: 'app-storage',
      storage: createJSONStorage(() => mmkvStorage),
    }
  )
);
```

**Slide 160: Mobile Performance Optimization**
```tsx
// ❌ Bad: Heavy selectors in animations
function AnimatedComponent() {
  const tasks = useStore((state) => 
    state.tasks.filter(t => !t.completed).sort((a, b) => a.priority - b.priority)
  );
  // Recomputes on every frame during animation
}

// ✅ Good: Memoize selectors
const selectActiveTasks = createSelector(
  [(state) => state.tasks],
  (tasks) => tasks.filter(t => !t.completed).sort((a, b) => a.priority - b.priority)
);

function AnimatedComponent() {
  const tasks = useStore(selectActiveTasks);
  // Only recomputes when tasks change
}
```

**Slide 161: Navigation State**
```typescript
const useNavStore = create((set) => ({
  currentRoute: 'Home',
  setCurrentRoute: (route) => set({ currentRoute }),
}));

// In navigation
<NavigationContainer
  onStateChange={(state) => {
    const route = state.routes[state.index];
    useNavStore.getState().setCurrentRoute(route.name);
  }}
/>
```

**Slide 162: Live Demo: React Native Integration**
- Set up store with AsyncStorage
- Create mobile component
- Show performance optimization

**Slide 163: Lab: React Native Setup**
- Set up React Native project
- Add store with persistence

---

### Session 21: Zustand with Next.js 16 (1.5 Hours)
**Slide 164: Next.js 16 Features**
- App Router
- Server Components
- Streaming
- Partial Pre-rendering (PPR)
- `use cache`

**Slide 165: Server Component Integration**
```tsx
// Server Component
import { TaskListClient } from '@/components/TaskListClient';
import { fetchTasks } from '@/lib/data';

export default async function Page() {
  const tasks = await fetchTasks();
  return <TaskListClient initialTasks={tasks} />;
}

// Client Component
'use client';

import { useEffect } from 'react';
import { useTaskStore } from '@taskflow/shared';

export function TaskListClient({ initialTasks }) {
  const setTasks = useTaskStore((state) => state.setTasks);
  
  useEffect(() => {
    setTasks(initialTasks);
  }, []);
  
  const tasks = useTaskStore((state) => state.tasks);
  return <div>{tasks.length}</div>;
}
```

**Slide 166: Preventing Hydration Mismatches**
```tsx
'use client';

import { useEffect, useState } from 'react';

export function useHydrated() {
  const [hydrated, setHydrated] = useState(false);
  useEffect(() => setHydrated(true), []);
  return hydrated;
}

function ClientComponent() {
  const hydrated = useHydrated();
  const tasks = useTaskStore((state) => state.tasks);
  if (!hydrated) return <div>Loading...</div>;
  return <div>{tasks.length}</div>;
}
```

**Slide 167: Request-Isolated Stores**
```typescript
import { createStore } from 'zustand/vanilla';

function createRequestStore(initialTasks) {
  return createStore((set) => ({
    tasks: initialTasks,
    addTask: (task) => set((state) => ({ tasks: [...state.tasks, task] })),
  }));
}

// In component
const storeRef = useRef(null);
if (!storeRef.current) {
  storeRef.current = createRequestStore(initialTasks);
}
const store = storeRef.current;
```

**Slide 168: Using `use cache` with Zustand**
```typescript
import { cache } from 'react';

export const fetchTasks = cache(async () => {
  console.log('Fetching tasks (cached)...');
  const response = await fetch('https://api.example.com/tasks');
  return response.json();
});

// Server Component
export default async function Page() {
  const tasks = await fetchTasks(); // Cached across requests
  return <ClientComponent initialTasks={tasks} />;
}
```

**Slide 169: Live Demo: Next.js Integration**
- Set up server/client components
- Add hydration guard
- Use `use cache`

**Slide 170: Lab: Next.js Integration**
- Create Next.js 16 app
- Add Zustand stores
- Use Server Components

---

## Day 5: Production Patterns, Testing & Enterprise (8 Hours)

### Session 22: Authentication (1.5 Hours)
**Slide 171: Authentication Store**
```typescript
interface AuthStore {
  user: User | null;
  token: string | null;
  isLoading: boolean;
  error: string | null;
  login: (email: string, password: string) => Promise<void>;
  logout: () => Promise<void>;
  refreshSession: () => Promise<void>;
}

const useAuthStore = create(
  persist(
    (set) => ({
      user: null,
      token: null,
      isLoading: false,
      error: null,
      login: async (email, password) => {
        set({ isLoading: true, error: null });
        try {
          const response = await api.login(email, password);
          set({ user: response.user, token: response.token, isLoading: false });
        } catch (error) {
          set({ error: error.message, isLoading: false });
        }
      },
      logout: async () => {
        await api.logout();
        set({ user: null, token: null });
      },
      refreshSession: async () => {
        const { token } = get();
        if (!token) return;
        try {
          const newToken = await api.refresh(token);
          set({ token: newToken });
        } catch (error) {
          set({ user: null, token: null });
        }
      },
    }),
    { name: 'auth-storage' }
  )
);
```

**Slide 172: Role-Based Access Control**
```typescript
const useAuthStore = create((set) => ({
  user: null,
  hasRole: (role) => {
    return get().user?.role === role;
  },
  hasPermission: (permission) => {
    return get().user?.permissions?.includes(permission) || false;
  },
}));

// In components
function AdminPanel() {
  const hasRole = useAuthStore((state) => state.hasRole);
  if (!hasRole('admin')) {
    return <div>Access Denied</div>;
  }
  return <div>Admin Panel</div>;
}
```

**Slide 173: Protected Routes**
```tsx
function ProtectedRoute({ children, requiredRole }) {
  const { user, isLoading } = useAuthStore();
  const router = useRouter();
  
  if (isLoading) return <div>Loading...</div>;
  if (!user) router.push('/login');
  if (requiredRole && user.role !== requiredRole) {
    router.push('/unauthorized');
  }
  return children;
}
```

**Slide 174: Live Demo: Authentication**
- Build auth store
- Add login/logout
- Add protected routes

**Slide 175: Lab: Authentication**
- Create auth store
- Add login form
- Add protected route

---

### Session 23: Shopping Cart (1.5 Hours)
**Slide 176: Shopping Cart Store**
```typescript
interface CartStore {
  items: CartItem[];
  subtotal: number;
  tax: number;
  total: number;
  addItem: (product: Product, quantity: number) => void;
  removeItem: (id: string) => void;
  updateQuantity: (id: string, quantity: number) => void;
  clearCart: () => void;
  validateInventory: (productId: string, quantity: number) => boolean;
}

const useCartStore = create(
  persist(
    (set, get) => ({
      items: [],
      subtotal: 0,
      tax: 0,
      total: 0,
      addItem: (product, quantity) => {
        if (!get().validateInventory(product.id, quantity)) {
          throw new Error('Not enough stock');
        }
        set((state) => {
          const existing = state.items.find(i => i.productId === product.id);
          let items;
          if (existing) {
            items = state.items.map(i =>
              i.productId === product.id
                ? { ...i, quantity: i.quantity + quantity }
                : i
            );
          } else {
            items = [...state.items, { productId: product.id, product, quantity }];
          }
          return {
            items,
            subtotal: calculateSubtotal(items),
            tax: calculateTax(items),
            total: calculateTotal(items),
          };
        });
      },
      // ... other actions
    }),
    { name: 'cart-storage' }
  )
);
```

**Slide 177: Offline Support**
```typescript
const useCartStore = create((set, get) => ({
  offlineQueue: [],
  addItem: async (product, quantity) => {
    // Optimistic update
    get().addItemOptimistic(product, quantity);
    
    if (!navigator.onLine) {
      // Queue for sync
      set((state) => ({
        offlineQueue: [
          ...state.offlineQueue,
          { type: 'add', product, quantity },
        ],
      }));
      return;
    }
    
    try {
      await api.addToCart(product.id, quantity);
    } catch (error) {
      // Rollback
      get().removeItem(product.id);
    }
  },
  syncOfflineQueue: async () => {
    const { offlineQueue } = get();
    for (const action of offlineQueue) {
      try {
        await api.addToCart(action.product.id, action.quantity);
      } catch (error) {
        console.error('Sync failed:', error);
      }
    }
    set({ offlineQueue: [] });
  },
}));
```

**Slide 178: Live Demo: Shopping Cart**
- Build cart store
- Add offline support
- Add inventory validation

**Slide 179: Lab: Shopping Cart**
- Create shopping cart store
- Add persistence
- Add offline support

---

### Session 24: Dashboards (1.5 Hours)
**Slide 180: Dashboard Store**
```typescript
interface DashboardStore {
  widgets: Widget[];
  filters: DashboardFilters;
  preferences: DashboardPreferences;
  addWidget: (widget: Widget) => void;
  removeWidget: (id: string) => void;
  updateWidget: (id: string, updates: Partial<Widget>) => void;
  setFilters: (filters: Partial<DashboardFilters>) => void;
  updatePreferences: (prefs: Partial<DashboardPreferences>) => void;
  getWidgetData: (id: string) => any;
  refreshAll: () => Promise<void>;
}

const useDashboardStore = create(
  persist(
    (set, get) => ({
      widgets: [],
      filters: {},
      preferences: { layout: 'grid', refreshInterval: 30 },
      getWidgetData: (id) => {
        const widget = get().widgets.find(w => w.id === id);
        if (!widget) return null;
        // Fetch data based on widget type
        return fetchWidgetData(widget, get().filters);
      },
      refreshAll: async () => {
        const widgets = get().widgets;
        for (const widget of widgets) {
          const data = await fetchWidgetData(widget, get().filters);
          set((state) => ({
            widgets: state.widgets.map(w =>
              w.id === widget.id ? { ...w, data, lastUpdated: new Date() } : w
            ),
          }));
        }
      },
    }),
    { name: 'dashboard-storage' }
  )
);
```

**Slide 181: Widget Architecture**
```typescript
// Widget types
type WidgetType = 'chart' | 'stats' | 'table' | 'kpi' | 'custom';

interface Widget {
  id: string;
  type: WidgetType;
  title: string;
  config: WidgetConfig;
  data?: any;
  lastUpdated?: Date;
  position: { x: number; y: number; w: number; h: number };
}

// Widget renderer
function WidgetRenderer({ widgetId }) {
  const widget = useDashboardStore((state) => 
    state.widgets.find(w => w.id === widgetId)
  );
  if (!widget) return null;
  
  switch (widget.type) {
    case 'chart':
      return <ChartWidget data={widget.data} config={widget.config} />;
    case 'stats':
      return <StatsWidget data={widget.data} />;
    // ... other types
  }
}
```

**Slide 182: Live Demo: Dashboard**
- Build dashboard store
- Add widgets
- Add data fetching

**Slide 183: Lab: Dashboard**
- Create dashboard store
- Add widgets

---

### Session 25: Forms (1 Hour)
**Slide 184: Form Store**
```typescript
interface FormStore {
  data: Record<string, any>;
  errors: Record<string, string>;
  touched: Record<string, boolean>;
  currentStep: number;
  steps: FormStep[];
  setField: (field: string, value: any) => void;
  setError: (field: string, error: string) => void;
  touchField: (field: string) => void;
  nextStep: () => void;
  prevStep: () => void;
  validate: () => boolean;
  reset: () => void;
}

const useFormStore = create((set, get) => ({
  data: {},
  errors: {},
  touched: {},
  currentStep: 0,
  steps: [],
  setField: (field, value) => {
    set((state) => ({
      data: { ...state.data, [field]: value },
      touched: { ...state.touched, [field]: true },
    }));
    // Validate on change
    const error = validateField(field, value);
    if (error) {
      set((state) => ({
        errors: { ...state.errors, [field]: error },
      }));
    } else {
      set((state) => {
        const { [field]: _, ...remaining } = state.errors;
        return { errors: remaining };
      });
    }
  },
  // ... other actions
}));
```

**Slide 185: Multi-Step Forms**
```typescript
const useFormStore = create((set, get) => ({
  currentStep: 0,
  steps: [
    { id: 'personal', title: 'Personal Information' },
    { id: 'address', title: 'Address' },
    { id: 'review', title: 'Review' },
  ],
  nextStep: () => {
    if (!get().validateCurrentStep()) return;
    set((state) => ({
      currentStep: Math.min(state.currentStep + 1, state.steps.length - 1),
    }));
  },
  prevStep: () => {
    set((state) => ({
      currentStep: Math.max(state.currentStep - 1, 0),
    }));
  },
}));
```

**Slide 186: Draft Saving**
```typescript
const useFormStore = create(
  persist(
    (set) => ({
      data: {},
      saveDraft: () => {
        // Save to localStorage automatically via persist
        console.log('Draft saved');
      },
      loadDraft: () => {
        // Load from localStorage automatically via persist
        console.log('Draft loaded');
      },
    }),
    { name: 'form-draft' }
  )
);
```

**Slide 187: Live Demo: Forms**
- Build form store
- Add validation
- Add multi-step

**Slide 188: Lab: Forms**
- Create form store
- Add validation

---

### Session 26: Real-Time Applications (1.5 Hours)
**Slide 189: WebSocket Integration**
```typescript
class WebSocketService {
  private ws: WebSocket | null = null;
  private reconnectAttempts = 0;
  private maxReconnectAttempts = 10;
  
  connect() {
    this.ws = new WebSocket('wss://api.example.com/ws');
    this.ws.onopen = () => {
      console.log('Connected');
      this.reconnectAttempts = 0;
      useStore.getState().setConnected(true);
    };
    this.ws.onmessage = (event) => {
      const data = JSON.parse(event.data);
      useStore.getState().handleMessage(data);
    };
    this.ws.onclose = () => {
      console.log('Disconnected');
      useStore.getState().setConnected(false);
      this.scheduleReconnect();
    };
  }
  
  scheduleReconnect() {
    if (this.reconnectAttempts >= this.maxReconnectAttempts) return;
    this.reconnectAttempts++;
    setTimeout(() => this.connect(), 1000 * Math.pow(2, this.reconnectAttempts - 1));
  }
}
```

**Slide 190: Real-Time Store**
```typescript
interface RealtimeStore {
  messages: Message[];
  onlineUsers: string[];
  isConnected: boolean;
  typingUsers: Record<string, { userId: string; userName: string }>;
  addMessage: (message: Message) => void;
  setOnlineUsers: (users: string[]) => void;
  setConnected: (connected: boolean) => void;
  setUserTyping: (userId: string, userName: string, isTyping: boolean) => void;
}

const useRealtimeStore = create((set) => ({
  messages: [],
  onlineUsers: [],
  isConnected: false,
  typingUsers: {},
  addMessage: (message) => {
    set((state) => ({
      messages: [...state.messages, message],
    }));
  },
  // ... other actions
}));
```

**Slide 191: Chat Component**
```tsx
function ChatRoom() {
  const messages = useRealtimeStore((state) => state.messages);
  const isConnected = useRealtimeStore((state) => state.isConnected);
  const typingUsers = useRealtimeStore((state) => state.typingUsers);
  const addMessage = useRealtimeStore((state) => state.addMessage);
  
  useEffect(() => {
    wsService.connect();
    return () => wsService.disconnect();
  }, []);
  
  const sendMessage = (text) => {
    const message = { id: Date.now(), text, userId: user.id, timestamp: new Date() };
    addMessage(message);
    wsService.send('message', message);
  };
  
  return (
    <div>
      <div className={isConnected ? 'connected' : 'disconnected'}>
        {isConnected ? '🟢 Online' : '🔴 Offline'}
      </div>
      <div className="messages">
        {messages.map(msg => <Message key={msg.id} {...msg} />)}
        {Object.values(typingUsers).map(({ userName }) => (
          <div key={userName} className="typing">{userName} is typing...</div>
        ))}
      </div>
      <MessageInput onSend={sendMessage} />
    </div>
  );
}
```

**Slide 192: Live Demo: Real-Time**
- Build WebSocket service
- Build real-time store
- Create chat component

**Slide 193: Lab: Real-Time Features**
- Add WebSocket connection
- Build real-time store

---

### Session 27: Testing (1.5 Hours)
**Slide 194: Unit Testing Stores**
```typescript
import { describe, it, expect, beforeEach } from 'vitest';
import { useCounterStore } from './counterStore';

describe('Counter Store', () => {
  beforeEach(() => {
    useCounterStore.setState({ count: 0 });
  });

  it('should increment count', () => {
    const { increment } = useCounterStore.getState();
    increment();
    expect(useCounterStore.getState().count).toBe(1);
  });

  it('should decrement count', () => {
    const { decrement } = useCounterStore.getState();
    decrement();
    expect(useCounterStore.getState().count).toBe(-1);
  });

  it('should reset count', () => {
    const { increment, reset } = useCounterStore.getState();
    increment();
    increment();
    reset();
    expect(useCounterStore.getState().count).toBe(0);
  });
});
```

**Slide 195: Testing Async Actions**
```typescript
import { describe, it, expect, vi } from 'vitest';
import { useUserStore, userApi } from './userStore';

vi.mock('./api', () => ({
  userApi: {
    getUsers: vi.fn(),
  },
}));

describe('User Store', () => {
  it('should fetch users', async () => {
    const mockUsers = [{ id: 1, name: 'Alice' }];
    userApi.getUsers.mockResolvedValue(mockUsers);
    
    const { fetchUsers } = useUserStore.getState();
    await fetchUsers();
    
    const state = useUserStore.getState();
    expect(state.users).toEqual(mockUsers);
    expect(state.loading).toBe(false);
  });
});
```

**Slide 196: Integration Testing with React Testing Library**
```tsx
import { render, screen, fireEvent } from '@testing-library/react';
import { useCounterStore } from './counterStore';
import { Counter } from './Counter';

describe('Counter Integration', () => {
  beforeEach(() => {
    useCounterStore.setState({ count: 0 });
  });

  it('should display count', () => {
    render(<Counter />);
    expect(screen.getByText('Count: 0')).toBeInTheDocument();
  });

  it('should increment when button clicked', () => {
    render(<Counter />);
    fireEvent.click(screen.getByText('Increment'));
    expect(screen.getByText('Count: 1')).toBeInTheDocument();
  });
});
```

**Slide 197: E2E Testing**
```typescript
test('user can add and complete task', async ({ page }) => {
  await page.goto('/tasks');
  await page.fill('input[placeholder="Add task"]', 'E2E Test Task');
  await page.click('button:has-text("Add")');
  await expect(page.locator('text=E2E Test Task')).toBeVisible();
  await page.click('input[type="checkbox"]');
  await expect(page.locator('text=E2E Test Task')).toHaveClass(/line-through/);
});
```

**Slide 198: Live Demo: Testing**
- Write unit tests
- Write integration tests

**Slide 199: Lab: Testing**
- Add unit tests
- Add integration tests

---

### Session 28: Enterprise Best Practices (2 Hours)
**Slide 200: Folder Organization**
```
src/
├── domains/
│   ├── auth/
│   │   ├── store/
│   │   ├── components/
│   │   ├── services/
│   │   └── types/
│   ├── task/
│   │   └── ...
│   └── ui/
│       └── ...
├── shared/
│   ├── store/
│   ├── hooks/
│   └── utils/
└── infrastructure/
    ├── api/
    └── logging/
```

**Slide 201: Domain-Driven Design**
- Organize by business domain, not technical layer
- Each domain has its own store, components, services, types
- Domains are independent and loosely coupled
- Shared code is in `shared` directory

**Slide 202: Dependency Injection**
```typescript
// Container
class Container {
  private services = new Map();
  register(key, factory) {
    this.services.set(key, factory);
  }
  resolve(key) {
    const factory = this.services.get(key);
    if (!factory) throw new Error(`Service ${key} not found`);
    return factory();
  }
}

const container = new Container();
container.register('taskApi', () => new TaskApi());
container.register('taskStore', () => createTaskStore(container.resolve('taskApi')));

// Factory pattern
function createTaskStore(api) {
  return create((set) => ({
    // Use api
  }));
}
```

**Slide 203: Error Boundaries**
```tsx
class ErrorBoundary extends React.Component {
  state = { hasError: false, error: null };
  
  static getDerivedStateFromError(error) {
    return { hasError: true, error };
  }
  
  componentDidCatch(error, errorInfo) {
    // Log error
    Sentry.captureException(error, { extra: errorInfo });
    // Reset store state
    useStore.getState().reset();
  }
  
  render() {
    if (this.state.hasError) {
      return <ErrorFallback error={this.state.error} />;
    }
    return this.props.children;
  }
}
```

**Slide 204: Logging Strategies**
```typescript
// Structured logging
const logger = {
  info: (message, data) => {
    console.log(JSON.stringify({
      level: 'info',
      message,
      data,
      timestamp: new Date().toISOString(),
    }));
  },
  error: (message, error) => {
    console.error(JSON.stringify({
      level: 'error',
      message,
      error: error.message,
      stack: error.stack,
      timestamp: new Date().toISOString(),
    }));
  },
};

// Remote logging
function reportError(error, context) {
  navigator.sendBeacon('/api/errors', JSON.stringify({
    error: error.message,
    stack: error.stack,
    context,
    timestamp: Date.now(),
  }));
}
```

**Slide 205: Performance Monitoring**
```typescript
// Track performance metrics
const metrics = [];

function trackMetric(name, value) {
  metrics.push({ name, value, timestamp: Date.now() });
  if (metrics.length > 100) {
    sendMetrics(metrics);
    metrics.length = 0;
  }
}

// In store middleware
const performanceMonitor = (config) => (set, get, store) => {
  return config(
    (args) => {
      const start = performance.now();
      set(args);
      const duration = performance.now() - start;
      trackMetric('update_duration', duration);
      if (duration > 50) {
        logger.warn('Slow update', { duration, args });
      }
    },
    get,
    store
  );
};
```

**Slide 206: Anti-Patterns**
| Anti-Pattern | Solution |
|--------------|----------|
| Over-subscription | Use selectors |
| Direct mutation | Use immutable updates |
| Monolithic store | Split by domain |
| No error handling | Add error boundaries |
| No persistence | Add persist middleware |
| Race conditions | Use request IDs |

---

## Closing & Next Steps (30 min)

**Slide 207: Recap of Key Takeaways**
- Zustand is simple, predictable, and performant
- Use selectors for fine-grained subscriptions
- Split stores by domain
- Use middleware for logging, persistence, debugging
- Handle async with proper loading/error states
- Test your stores thoroughly
- Follow enterprise best practices

**Slide 208: Resources**
- **Zustand Docs**: [docs.pmnd.rs/zustand](https://docs.pmnd.rs/zustand)
- **GitHub**: [github.com/pmndrs/zustand](https://github.com/pmndrs/zustand)
- **Examples**: [github.com/pmndrs/zustand/tree/main/examples](https://github.com/pmndrs/zustand/tree/main/examples)
- **Community**: [discord.gg/pmndrs](https://discord.gg/pmndrs)

**Slide 209: Next Steps**
- Build your own Zustand application
- Explore advanced patterns
- Contribute to the community
- Share your knowledge

**Slide 210: Thank You & Q&A**
- Thank you for participating
- Questions?
- Feedback welcome

---

## Appendix: Lab Solutions

### Lab 1: Counter Store
```typescript
import { create } from 'zustand';
import { devtools, persist } from 'zustand/middleware';

interface CounterStore {
  count: number;
  increment: () => void;
  decrement: () => void;
  reset: () => void;
}

export const useCounterStore = create<CounterStore>()(
  devtools(
    persist(
      (set) => ({
        count: 0,
        increment: () => set((state) => ({ count: state.count + 1 })),
        decrement: () => set((state) => ({ count: state.count - 1 })),
        reset: () => set({ count: 0 }),
      }),
      { name: 'counter-storage' }
    ),
    { name: 'Counter Store' }
  )
);
```

### Lab 2: Todo Store
```typescript
import { create } from 'zustand';
import { persist } from 'zustand/middleware';
import { immer } from 'zustand/middleware/immer';

interface Todo {
  id: string;
  text: string;
  completed: boolean;
}

interface TodoStore {
  todos: Record<string, Todo>;
  todoIds: string[];
  addTodo: (text: string) => void;
  toggleTodo: (id: string) => void;
  deleteTodo: (id: string) => void;
}

export const useTodoStore = create<TodoStore>()(
  persist(
    immer((set) => ({
      todos: {},
      todoIds: [],
      addTodo: (text) => {
        set((state) => {
          const id = crypto.randomUUID();
          state.todos[id] = { id, text, completed: false };
          state.todoIds.push(id);
        });
      },
      toggleTodo: (id) => {
        set((state) => {
          const todo = state.todos[id];
          if (todo) todo.completed = !todo.completed;
        });
      },
      deleteTodo: (id) => {
        set((state) => {
          delete state.todos[id];
          state.todoIds = state.todoIds.filter(tid => tid !== id);
        });
      },
    })),
    { name: 'todo-storage' }
  )
);
```

---

## Summary: Complete 5-Day Course Outline

| Day | Topics | Hours |
|-----|--------|-------|
| **Day 1** | Foundations & Core Concepts | 8 |
| **Day 2** | Advanced State Architecture | 8 |
| **Day 3** | Asynchronous State Management | 8 |
| **Day 4** | Performance & Ecosystem | 8 |
| **Day 5** | Production Patterns & Enterprise | 8 |
| **Total** | | **40 hours** |

---

[GENERATED: Complete Slide Outline for 5-Day Zustand Course]
