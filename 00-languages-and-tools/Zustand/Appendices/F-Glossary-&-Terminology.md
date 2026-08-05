# Appendix F: Glossary & Terminology

This appendix provides a comprehensive glossary of terms used throughout the Zustand tutorial series. Use this as a quick reference when encountering unfamiliar concepts or terminology.

---

## A

### Action
A function in a Zustand store that updates the state. Actions are defined in the store and called directly by components.

```typescript
const useStore = create((set) => ({
  count: 0,
  increment: () => set((state) => ({ count: state.count + 1 })), // Action
}));
```

### App Router
The new routing system in Next.js 16 that supports Server Components, nested layouts, and advanced data fetching patterns.

### Async Action
An action that performs asynchronous operations like API calls, file uploads, or database operations.

```typescript
fetchData: async () => {
  set({ loading: true });
  const data = await fetch('/api/data');
  set({ data, loading: false });
}
```

### Atom
In state management, the smallest unit of state. In Recoil/Jotai, atoms are independent pieces of state that can be read and updated. In Zustand, the entire store is the atom.

### Atomic State Management
A pattern where state is broken into small, independent pieces that can be subscribed to individually. Zustand implements this through selectors.

---

## B

### Batching
The process of grouping multiple state updates into a single update to prevent multiple re-renders.

```typescript
// Good: Single update
set({ tasks, loading: false, error: null });

// Bad: Multiple updates (causes multiple re-renders)
set({ tasks });
set({ loading: false });
set({ error: null });
```

### Bridge (React Native)
The communication layer between JavaScript and native code in React Native. Performance optimization often focuses on reducing bridge traffic.

---

## C

### Cache
A storage layer that temporarily stores data to reduce redundant fetches. In Zustand, caching is often implemented with selectors or with libraries like React Query.

### Client Component
A React component that runs on the client. In Next.js 16, client components are marked with `'use client'` and can use hooks like `useState`, `useEffect`, and Zustand stores.

### Computed State
State derived from other state. Computed state is not stored directly but calculated when needed.

```typescript
getCompletedTasks: () => {
  return get().tasks.filter(task => task.completed);
}
```

### Concurrent Rendering
A React 19 feature that allows React to interrupt rendering to handle higher-priority updates, improving responsiveness.

### Context API
React's built-in state management system using `createContext` and `useContext`. Zustand offers a simpler alternative with better performance.

### create
The primary Zustand function used to create a store.

```typescript
const useStore = create((set) => ({ /* ... */ }));
```

### createStore
The vanilla version of `create` that creates a store without React hooks.

```typescript
const store = createStore((set) => ({ /* ... */ }));
```

---

## D

### Debouncing
A technique that limits how often a function can be called. Often used with search inputs to prevent excessive API calls.

```typescript
const debouncedSearch = debounce((query) => {
  fetchResults(query);
}, 300);
```

### Dependency Injection (DI)
A design pattern where dependencies are provided to a component rather than being created internally. In Zustand, DI is often implemented via factory functions or containers.

### Derived State
State computed from other state. See Computed State.

### DevTools
Short for Developer Tools. Zustand integrates with Redux DevTools via the `devtools` middleware for time-travel debugging.

### Domain-Driven Design (DDD)
An approach to software development where the code structure matches business domains. In Zustand, this means organizing stores by domain (auth, tasks, user, etc.).

### Draft
In Immer, a proxy object that allows mutable updates. The draft is mutated, and Immer produces an immutable copy.

---

## E

### Event Bus
A communication pattern where components publish and subscribe to events without direct dependencies.

```typescript
eventBus.subscribe('task:created', handleTaskCreated);
eventBus.publish('task:created', task);
```

### Event Source / Server-Sent Events (SSE)
A technology for receiving real-time updates from a server via HTTP. Simpler than WebSockets for one-way communication.

---

## F

### Feature Flag
A technique for enabling or disabling features in production without deploying new code. Used for gradual rollouts and A/B testing.

```typescript
if (featureFlags.useZustand) {
  return <ZustandComponent />;
}
return <LegacyComponent />;
```

### Fine-Grained Subscriptions
Zustand's ability to subscribe to only specific pieces of state, preventing unnecessary re-renders.

```typescript
// Only re-renders when count changes
const count = useStore((state) => state.count);
```

### Factory Function
A function that creates and returns a new instance of something. In Zustand, factory functions are used to create configurable store instances.

```typescript
function createTaskStore(config) {
  return create((set) => ({
    tasks: [],
    // ... use config
  }));
}
```

### Functional Update
A form of `set` that receives the current state and returns the new state. Preferred over object updates when the update depends on current state.

```typescript
set((state) => ({ count: state.count + 1 }));
```

---

## G

### get
The Zustand function that retrieves the current state from within a store.

```typescript
const useStore = create((set, get) => ({
  count: 0,
  double: () => get().count * 2,
}));
```

### Global State
State that is accessible from anywhere in the application. Zustand stores are global by default.

---

## H

### Hot Store
A store containing frequently updated state (animations, cursor position, typing indicators). Often separated from cold stores for performance.

### Hydration
The process of loading persisted state from storage (localStorage, AsyncStorage) into the store. Also refers to React's client-side rendering after server-side rendering.

```typescript
const useStore = create(
  persist(
    (set) => ({ /* ... */ }),
    { name: 'storage' }
  )
);
// The store automatically hydrates on load
```

---

## I

### Immutable
Data that cannot be changed after creation. Zustand requires immutable state updates to detect changes.

```typescript
// ❌ Mutation (bad)
state.tasks.push(newTask);

// ✅ Immutable (good)
set((state) => ({
  tasks: [...state.tasks, newTask]
}));
```

### Immer
A library that allows mutable updates while ensuring immutability. Integrated with Zustand via the `immer` middleware.

### Integration Test
A test that verifies multiple units work together correctly. In Zustand, integration tests often combine stores, components, and API calls.

---

## J

### Jotai
A lightweight React state management library using atoms. Similar to Zustand but with a different API.

---

## L

### Lazy Initialization
The practice of initializing state only when it's first needed, reducing initial load time.

```typescript
let store: StoreApi<any> | null = null;

function getStore() {
  if (!store) {
    store = createStore((set) => ({ /* ... */ }));
  }
  return store;
}
```

### Loading State
State indicating that an async operation is in progress.

```typescript
interface Store {
  loading: boolean;
  fetchData: () => Promise<void>;
}
```

### localStorage
Web storage that persists data across browser sessions. Used by the `persist` middleware.

---

## M

### Memoization
The technique of caching the result of expensive computations and returning the cached result when the inputs haven't changed.

### Middleware
Functions that wrap Zustand stores to add functionality like persistence, logging, or debugging.

```typescript
const useStore = create(
  devtools(
    persist(
      (set) => ({ /* ... */ }),
      { name: 'storage' }
    )
  )
);
```

### Migration
The process of updating persisted state from one version of a schema to another.

```typescript
persist(
  (set) => ({ /* ... */ }),
  {
    name: 'storage',
    version: 1,
    migrate: (state, version) => { /* ... */ },
  }
)
```

### MMKV
A high-performance key-value storage library for React Native. Faster than AsyncStorage.

### MobX
A reactive state management library that uses observable objects. Zustand offers a simpler, more explicit alternative.

### Monolithic Store
A single, large store that handles multiple domains. Generally considered an anti-pattern in Zustand.

---

## N

### Normalization
The process of structuring state to avoid duplication and enable efficient lookups.

```typescript
// ❌ Denormalized
tasks: Task[];

// ✅ Normalized
tasks: Record<string, Task>;
taskIds: string[];
```

### Notification
A message delivered to the user (in-app, toast, push). Zustand stores often include notification state.

---

## O

### Observer (MobX)
A component wrapped with `observer` that automatically re-renders when observable state changes. Not used in Zustand.

### Offline Queue
A queue of actions that are queued when the device is offline and executed when the device reconnects.

### Object.is
The equality comparison used by Zustand to detect changes. Similar to `===` but treats `NaN` as equal to `NaN`.

### Optimistic Update
A pattern where the UI is updated immediately, and the server is updated in the background. If the server update fails, the UI is rolled back.

```typescript
// Optimistic update
set((state) => ({ tasks: [...state.tasks, newTask] }));
// Then try to save to server
try {
  await api.save(newTask);
} catch {
  // Rollback
  set((state) => ({ tasks: state.tasks.filter(t => t.id !== newTask.id) }));
}
```

---

## P

### Partial Update
An update that changes only specific fields of the state, leaving others unchanged.

```typescript
set({ theme: 'dark' }); // Only updates theme
```

### Partialize
The `persist` middleware option that specifies which parts of the state to persist.

```typescript
partialize: (state) => ({
  user: state.user,
  theme: state.theme,
  // Don't persist isLoading, error
})
```

### Persist
The Zustand middleware that saves state to storage (localStorage, AsyncStorage, etc.).

### Presence
A real-time feature showing which users are online and what they're doing.

### Provider
A React component that provides context or state to child components. Zustand doesn't require providers.

---

## R

### Race Condition
A bug where the outcome depends on the timing of asynchronous operations. Zustand patterns like request ID tracking and AbortController prevent race conditions.

### Recoil
A React state management library using atoms and selectors. Zustand offers a simpler alternative with less boilerplate.

### Redux
A predictable state container for JavaScript apps. Zustand was created as a simpler alternative to Redux.

### Redux DevTools
A browser extension for debugging Redux applications. Zustand integrates with it via the `devtools` middleware.

### Refresh Token
A long-lived token used to obtain new access tokens without re-authenticating.

### Request Deduplication
The practice of preventing duplicate concurrent requests for the same data.

### Request ID
A unique identifier for each request, used to prevent race conditions.

```typescript
const requestId = `req-${Date.now()}`;
set({ requestId, loading: true });
// ... after request
set((state) => {
  if (state.requestId !== requestId) return state;
  return { data, loading: false };
});
```

### Reselect
A library for creating memoized selectors, often used with Zustand for performance optimization.

### Rollback
The process of reverting an optimistic update when the server operation fails.

---

## S

### Selector
A function that extracts specific pieces of state from the store. Selectors are used to subscribe to only what a component needs.

```typescript
const count = useStore((state) => state.count);
```

### Server Action
In Next.js 16, a function that runs on the server and can be called from the client. Can be combined with Zustand for optimistic updates.

### Server Component
A React component that runs on the server and cannot use hooks. Zustand stores are not used in Server Components directly.

### Server-Sent Events (SSE)
A real-time communication technology where the server pushes events to the client. Simpler than WebSockets.

### set
The Zustand function used to update store state. Called with either an object or a function.

```typescript
set({ count: 1 }); // Object update
set((state) => ({ count: state.count + 1 })); // Functional update
```

### Shallow Comparison
An equality check that compares the top-level properties of objects. Used by `useShallow` to prevent unnecessary re-renders.

### Slice Pattern
A pattern where a large store is split into smaller, focused slices (modules) that are then combined.

```typescript
const userSlice = (set) => ({
  user: null,
  setUser: (user) => set({ user }),
});

const taskSlice = (set) => ({
  tasks: [],
  addTask: (task) => set((state) => ({ tasks: [...state.tasks, task] })),
});

const useStore = create((set) => ({
  ...userSlice(set),
  ...taskSlice(set),
}));
```

### State Creator
The function passed to `create` that defines the store's state and actions.

```typescript
const stateCreator = (set) => ({
  count: 0,
  increment: () => set((state) => ({ count: state.count + 1 })),
});

const useStore = create(stateCreator);
```

### Store
The container that holds state and actions. Created with `create` or `createStore`.

### Strangler Fig Pattern
A migration pattern where legacy code is gradually replaced by new code. Used when migrating from Redux/Context to Zustand.

### Subscription
A function that listens to store changes. Created with `store.subscribe()`.

### Suspense
A React feature for declarative loading states. Can be used with Zustand for data fetching.

---

## T

### Time-Travel Debugging
A debugging feature that allows you to jump back and forth through state changes. Available in Redux DevTools.

### Transition
A React 19 feature for marking updates as non-urgent. Can be used with Zustand for performance.

```typescript
const [isPending, startTransition] = useTransition();
startTransition(() => {
  useStore.getState().heavyUpdate();
});
```

### Typing Indicator
A real-time feature showing that another user is typing. Implemented with WebSockets and Zustand.

---

## U

### Unit Test
A test that verifies a single unit in isolation. Zustand stores are easily unit testable.

### useStore
The React hook that provides access to the Zustand store.

```typescript
const count = useStore((state) => state.count);
```

### useActionState
A React 19 hook for managing form submission state. Can be used with Zustand.

### useOptimistic
A React 19 hook for optimistic UI updates. Can be combined with Zustand.

### useShallow
A Zustand utility for shallow comparison in object selectors.

```typescript
const { user, settings } = useStore(
  useShallow((state) => ({
    user: state.user,
    settings: state.settings,
  }))
);
```

---

## V

### Version (Persistence)
A number that tracks the schema version of persisted data. Used with migrations to handle schema changes.

```typescript
persist(
  (set) => ({ /* ... */ }),
  {
    name: 'storage',
    version: 1,
  }
)
```

### Vanilla Store
A Zustand store that doesn't depend on React. Created with `createStore`.

---

## W

### WebSocket
A bidirectional communication protocol for real-time applications. Used with Zustand for presence, chat, and notifications.

### Widget
A self-contained UI component on a dashboard. Zustand stores often manage widget state and preferences.

---

## Z

### Zustand
A small, fast, and scalable state management solution. German for "state". Created by the team at Poimandres.

---

## Quick Reference: Terms by Category

### State Management Fundamentals
- Action
- Atom
- Derived State
- Global State
- Immutable
- Memoization
- Normalization
- State
- Store

### Zustand-Specific Terms
- create
- createStore
- get
- set
- useStore
- useShallow
- Vanilla Store

### Zustand Middleware
- devtools
- immer
- persist
- subscribeWithSelector
- combine

### React-Specific Terms
- Client Component
- Concurrent Rendering
- Context API
- Hydration
- Server Component
- Suspense
- Transition

### Real-Time & Async
- Async Action
- Debouncing
- Event Bus
- Offline Queue
- Optimistic Update
- Presence
- Race Condition
- Request Deduplication
- WebSocket

### Performance
- Batching
- Fine-Grained Subscriptions
- Lazy Initialization
- Memoization
- Selector
- Shallow Comparison

### Architecture
- Domain-Driven Design
- Slice Pattern
- Strangler Fig Pattern

### Testing
- Integration Test
- Unit Test

### Deployment & Persistence
- Hydration
- localStorage
- Migration
- Partialize
- Persist
- Version
