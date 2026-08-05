# Zustand Mastery: Complete Student Notes

## A Comprehensive Reference for the 5‑Day Course

---

# Table of Contents

1. [Part 1: Foundations & Core Concepts](#part-1-foundations--core-concepts)
   - 1.1 Understanding Zustand
   - 1.2 Creating Your First Store
   - 1.3 Reading State Efficiently
   - 1.4 Updating State
   - 1.5 Vanilla Stores
2. [Part 2: Advanced State Architecture](#part-2-advanced-state-architecture)
   - 2.1 Structuring Large Applications
   - 2.2 Middleware
   - 2.3 Immutability with Immer
   - 2.4 State Persistence
   - 2.5 Debugging
   - 2.6 Derived & Computed State
3. [Part 3: Asynchronous State Management](#part-3-asynchronous-state-management)
   - 3.1 Async Actions
   - 3.2 Concurrency & Race Conditions
   - 3.3 Working with External APIs
   - 3.4 Custom Middleware
4. [Part 4: Performance Optimization](#part-4-performance-optimization)
   - 4.1 Rendering Optimization
   - 4.2 Store Design for Performance
   - 4.3 Benchmarking
5. [Part 5: Zustand in the Modern React Ecosystem](#part-5-zustand-in-the-modern-react-ecosystem)
   - 5.1 React 19 Integration
   - 5.2 React Native
   - 5.3 Next.js 16
6. [Part 6: Production Patterns](#part-6-production-patterns)
   - 6.1 Authentication
   - 6.2 Shopping Cart
   - 6.3 Dashboards
   - 6.4 Forms
   - 6.5 Real‑Time Applications
7. [Part 7: Testing](#part-7-testing)
   - 7.1 Unit Testing Stores
   - 7.2 Integration Testing
8. [Part 8: Enterprise Best Practices](#part-8-enterprise-best-practices)
   - 8.1 Folder Organization
   - 8.2 Dependency Injection
   - 8.3 Error Boundaries & Logging
   - 8.4 Performance Monitoring & Migration
   - 8.5 Anti‑Patterns
9. [Appendices](#appendices)
   - A. API Quick Reference
   - B. Common Middleware Summary
   - C. Troubleshooting Quick Guide
   - D. Migration Cheatsheet

---

# Part 1: Foundations & Core Concepts

## 1.1 Understanding Zustand

- **Philosophy**: Simple, predictable, performant, minimal (~1kB)
- **Core principles**:
  - No Provider needed – stores are global
  - Fine‑grained subscriptions – only re‑render what changed
  - Atomic state management – state can be broken into small pieces
  - Works outside React (vanilla stores)
- **Comparison**:
  - **Redux**: boilerplate heavy; Zustand is simpler
  - **Context API**: all consumers re‑render; Zustand uses selectors
  - **MobX**: magic proxies; Zustand is explicit
  - **Recoil/Jotai**: need Providers; Zustand does not

## 1.2 Creating Your First Store

```ts
import { create } from 'zustand';

// Basic store
const useStore = create((set) => ({
  count: 0,
  increment: () => set((state) => ({ count: state.count + 1 })),
  decrement: () => set((state) => ({ count: state.count - 1 })),
  reset: () => set({ count: 0 }),
}));
```

- `set` is the updater – works like React’s `setState`
- `get` lets you read current state inside the store (useful for computed values)
- TypeScript: define an interface and use `create<Store>()`

## 1.3 Reading State Efficiently

- **Selector**: extract a specific slice of state
- **Why**: prevents unnecessary re‑renders

```ts
const count = useStore((state) => state.count); // only re‑renders on count change
```

- **`useShallow`** for object selectors:

```ts
import { useShallow } from 'zustand/react/shallow';

const { user, settings } = useStore(
  useShallow((state) => ({ user: state.user, settings: state.settings }))
);
```

- **Memoized selectors** with `reselect` (or `createSelector`) for expensive computations

## 1.4 Updating State

- **Functional updates** (preferred) – use current state:

```ts
set((state) => ({ count: state.count + 1 }));
```

- **Immutability**: never mutate state directly; create new objects/arrays

```ts
// ❌ bad
state.tasks.push(newTask);
// ✅ good
set((state) => ({ tasks: [...state.tasks, newTask] }));
```

- **Batching**: combine multiple updates into one `set` call
- **Reset**: store initial state in a constant and call `set(initialState)`

## 1.5 Vanilla Stores

- Use `createStore` from `zustand/vanilla` – no React dependency
- Useful for service layers, utility modules, Node.js
- Connect to React with `useStore(store, selector)`

```ts
import { createStore } from 'zustand/vanilla';
import { useStore } from 'zustand';

const store = createStore((set) => ({ count: 0, increment: () => set((state) => ({ count: state.count + 1 })) }));

function Counter() {
  const count = useStore(store, (state) => state.count);
  // ...
}
```

---

# Part 2: Advanced State Architecture

## 2.1 Structuring Large Applications

- **Monolithic stores** become hard to maintain – split by domain
- **Slice pattern**: each slice is a self‑contained module

```ts
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

- **Domain‑driven organization**: each domain (auth, tasks, UI) has its own store, components, services, types.

## 2.2 Middleware

Middleware wraps the store to add functionality.

- **`devtools`**: connects to Redux DevTools
- **`persist`**: saves/restores state to storage (localStorage, AsyncStorage, etc.)
- **`immer`**: allows mutable updates while keeping immutability
- **`subscribeWithSelector`**: enables selective subscriptions outside React
- **`combine`**: combine state and actions with type inference

**Order matters**: the outer middleware executes last on updates. Typically: `devtools(persist(immer(...)))` – devtools outermost, immer innermost.

## 2.3 Immutability with Immer

- Immer creates a draft proxy; you mutate the draft, and Immer produces an immutable copy
- Best for deeply nested state, complex updates

```ts
import { immer } from 'zustand/middleware/immer';

const useStore = create(
  immer((set) => ({
    user: { name: 'Alice', preferences: { theme: 'dark' } },
    setTheme: (theme) => set((state) => {
      state.user.preferences.theme = theme;
    }),
  }))
);
```

## 2.4 State Persistence

- Use `persist` middleware with `name` (storage key)
- **`partialize`** to persist only a subset
- **`version`** and **`migrate`** for schema changes
- **`onRehydrateStorage`** to listen to hydration events

```ts
persist(
  (set) => ({ user: null, theme: 'light' }),
  {
    name: 'app-storage',
    partialize: (state) => ({ user: state.user, theme: state.theme }),
    version: 1,
    migrate: (state, version) => {
      if (version === 0) {
        // transform from old schema
      }
      return state;
    },
  }
);
```

## 2.5 Debugging

- **Redux DevTools** via `devtools` middleware – time‑travel debugging
- Name actions for better visibility: `set({ count: 1 }, false, 'increment')`
- Custom logging middleware (or use the built‑in logger)
- Render counters to track component updates

## 2.6 Derived & Computed State

- **Computed** values are derived from state; don’t store them
- Use `get()` inside the store to compute on demand
- For expensive derivations, use memoized selectors (`reselect`)

---

# Part 3: Asynchronous State Management

## 3.1 Async Actions

- Always handle `loading`, `error`, and `success` states
- Use `try/catch` to capture errors

```ts
fetchData: async () => {
  set({ loading: true, error: null });
  try {
    const data = await api.getData();
    set({ data, loading: false });
  } catch (error) {
    set({ error: error.message, loading: false });
  }
}
```

- **Retry** with exponential backoff
- **Cancellation** with `AbortController`

## 3.2 Concurrency & Race Conditions

- **Request deduplication**: track in‑flight promises to avoid duplicate requests
- **Request ID**: ignore stale responses when a newer request arrives
- **Optimistic updates**: update UI immediately, rollback on failure

```ts
const requestId = Date.now();
set({ requestId, loading: true });
// after async:
set((state) => {
  if (state.requestId !== requestId) return state;
  return { data, loading: false };
});
```

- **Debouncing** for user input (e.g., search) to reduce API calls

## 3.3 Working with External APIs

- **REST**: use `fetch` or Axios; handle HTTP errors
- **GraphQL**: use a client (Apollo) or raw `fetch`
- **WebSocket**: manage connection lifecycle, reconnect, message routing
- **SSE**: simpler one‑way real‑time
- **Polling**: periodic updates with `setInterval`

## 3.4 Custom Middleware

- Middleware signature: `(config) => (set, get, store) => config(wrappedSet, get, store)`
- Examples: logging, validation, analytics, performance monitoring, authentication

---

# Part 4: Performance Optimization

## 4.1 Rendering Optimization

- **Fine‑grained subscriptions**: use selectors to subscribe only to needed state
- **`useShallow`** for object selectors to prevent re‑renders on unchanged values
- **Memoized selectors** with `reselect`
- **`React.memo`** for list items that subscribe independently
- Avoid **inline selectors** (recreated each render) – extract them

## 4.2 Store Design for Performance

- **Normalize** state: `Record<string, T>` + `string[]` for fast lookups
- **Split stores** by update frequency (hot/cold) and domain
- **Lazy initialization**: create store only when needed
- **Memory management**: limit cache sizes, clean up subscriptions

## 4.3 Benchmarking

- Use **React Profiler** to measure component render times
- Track **state size** (`new Blob([JSON.stringify(state)]).size`)
- Write performance tests (e.g., 1000 add/update/delete operations)
- Use **Lighthouse** and **Web Vitals** for user‑centric metrics

---

# Part 5: Zustand in the Modern React Ecosystem

## 5.1 React 19 Integration

- **`useTransition`**: mark heavy updates as low priority

```ts
startTransition(() => store.fetchData(query));
```

- **`useOptimistic`**: optimistic updates with Zustand

```ts
const [optimisticTasks, addOptimistic] = useOptimistic(tasks, (current, newTask) => [...current, newTask]);
```

- **`useActionState`**: form submission with pending state
- **Server Components**: seed Zustand stores via props, use hydration guards to avoid mismatches

## 5.2 React Native

- Persistence: `AsyncStorage` or **MMKV** (faster)
- Optimize for mobile: reduce bridge traffic with selectors, memoize, virtualize lists
- Secure storage: `react-native-keychain`

## 5.3 Next.js 16

- **Server Components** fetch data and pass to client components
- **Hydration guard** to prevent mismatches
- **Request‑isolated stores** for multi‑tenant/SSR (use `createStore` per request)
- **`use cache`** for caching server data
- **Partial Pre‑rendering (PPR)**: static + dynamic parts stream

---

# Part 6: Production Patterns

## 6.1 Authentication

- Store: user, tokens, loading, error
- **JWT**: store access & refresh tokens, refresh on expiry
- **RBAC**: `hasRole`, `hasPermission` helpers
- **Protected routes** with redirects

## 6.2 Shopping Cart

- Items, subtotal, tax, total
- **Inventory validation** before adding
- **Optimistic updates** with rollback
- **Offline support**: queue actions and sync when online

## 6.3 Dashboards

- **Widgets**: add/remove, move, resize, visibility
- **Filters** and **preferences** (layout, refresh interval)
- **Data caching** with TTL, refresh on filter change

## 6.4 Forms

- Multi‑step, field‑level validation, draft saving, undo/redo
- Use a generic form store or integrate with **React Hook Form**

## 6.5 Real‑Time Applications

- **WebSocket** service with reconnect logic, heartbeat
- **Presence** tracking (online/offline, typing)
- **Activity feed** and **notifications** (in‑app, toast)

---

# Part 7: Testing

## 7.1 Unit Testing Stores

- Reset store state before each test
- Use `getState()` and `setState()` to control state
- Test actions and selectors

## 7.2 Integration Testing

- Use **React Testing Library** + **MSW** to mock API calls
- Test component‑store interactions
- Test async flows with `waitFor` and `userEvent`

---

# Part 8: Enterprise Best Practices

## 8.1 Folder Organization

- **Domain‑driven**: `domains/` (auth, tasks, UI) each with store, components, services, types
- **Shared** code (`hooks`, `utils`) in `shared/`
- **Infrastructure** (API, logging, persistence) in `infrastructure/`

## 8.2 Dependency Injection

- Use **factory functions** to inject dependencies (API client, storage)
- **Container** or **service locator** for global services

## 8.3 Error Boundaries & Logging

- **Error boundary** middleware to catch store update errors
- **Centralized logging** with remote endpoints (Sentry, Datadog)
- Redact sensitive data in logs

## 8.4 Performance Monitoring & Migration

- **Performance monitoring middleware** to track slow updates
- **Performance budgets** (state size, update time)
- **Migration strategies**:
  - **Strangler fig**: run old and new side‑by‑side with feature flags
  - **Branch by abstraction**: adapter layer
  - **Gradual rollout** with rollback capability

## 8.5 Anti‑Patterns

| Anti‑Pattern | Solution |
|--------------|----------|
| Over‑subscription | Use selectors |
| Direct mutation | Use immutable updates or Immer |
| Monolithic store | Split by domain |
| No error handling | Add error boundaries |
| No persistence | Add `persist` middleware |
| Race conditions | Request IDs or cancellation |

---

# Appendices

## A. API Quick Reference

| API | Description |
|-----|-------------|
| `create` | Create a React store |
| `createStore` | Create a vanilla store |
| `set` | Update state (object or function) |
| `get` | Get current state |
| `subscribe` | Listen to state changes |
| `useStore` | React hook with selector |
| `useShallow` | Shallow comparison for selectors |

## B. Common Middleware Summary

| Middleware | Purpose |
|------------|---------|
| `devtools` | Redux DevTools integration |
| `persist` | State persistence (localStorage, AsyncStorage, MMKV) |
| `immer` | Immutable updates with mutable syntax |
| `subscribeWithSelector` | Selective subscriptions outside React |
| `combine` | Combine state and actions with type inference |

## C. Troubleshooting Quick Guide

| Symptom | Likely Cause | Solution |
|---------|--------------|----------|
| Component doesn't update | Direct mutation | Use immutable update or Immer |
| Too many re‑renders | Over‑subscription | Use selectors |
| State resets on reload | No persistence | Add `persist` |
| State corrupt | Schema changed | Version + migrate |
| Slow renders | Expensive selectors | Memoize with `reselect` |
| Race condition | No request ID | Track request ID or use AbortController |
| Memory leak | Unsubscribed listeners | Clean up subscriptions |

## D. Migration Cheatsheet

### Redux → Zustand

| Redux | Zustand |
|-------|---------|
| `configureStore` | `create` |
| Reducer | `set` functional update |
| Action + Action creator | Store method |
| `dispatch` | Direct method call |
| `useSelector` | `useStore(selector)` |
| `useDispatch` | Not needed |
| `Provider` | Not needed |

### Context API → Zustand

| Context | Zustand |
|---------|---------|
| `createContext` + Provider | Not needed |
| `useContext` | `useStore` |
| All consumers re‑render | Fine‑grained subscriptions |
| Manual memoization | Selectors + `useShallow` |

---

*End of Student Notes*
