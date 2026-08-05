# Zustand Mastery: Student Workbook

## Complete Companion Workbook for the 5-Day Course

---

**Student Name:** ___________________

**Start Date:** ___________________

**Completion Date:** ___________________

---

## How to Use This Workbook

This workbook accompanies the "Zustand Mastery" slide deck and serves as your hands-on guide throughout the 5-day course. For each session, you'll find:

1. **Key Concepts** – Brief summaries of what you'll learn
2. **Code Exercises** – Hands-on coding challenges
3. **Note-taking Space** – Room for your own notes
4. **Checkpoints** – Verify you understand each concept
5. **Labs** – Comprehensive coding exercises
6. **Quiz Questions** – Test your understanding

**Remember:** The most effective learning happens when you code along. Don't just read—type every example yourself!

---

## Day 1: Foundations & Core Concepts

### Session 1: Welcome & Introduction

#### Key Takeaways

- Zustand is a minimal, fast, and scalable state management solution
- It eliminates Redux boilerplate and Context API performance issues
- No Provider is required — stores are global by default
- Fine-grained subscriptions prevent unnecessary re-renders

**What I'm most excited to learn:**

---

### Session 2: Understanding Zustand

#### Core Concepts

| Concept | Description | Example |
|---------|-------------|---------|
| **Store** | Container holding state and actions | `create((set) => ({ count: 0 }))` |
| **State** | Data in the store | `count: 0` |
| **Action** | Function that updates state | `increment: () => set(...)` |
| **Selector** | Function that extracts state | `(state) => state.count` |
| **Subscription** | Component listening to state | `useStore((state) => state.count)` |

**My Notes on Architecture:**

---

### Session 3: Creating Your First Store

#### Exercise 1.1: Create a Basic Counter Store

```typescript
// YOUR CODE HERE
// 1. Import create from zustand
// 2. Create a store with:
//    - count: 0
//    - increment action
//    - decrement action
//    - reset action








// Expected structure:
// const useCounterStore = create((set) => ({
//   count: 0,
//   increment: () => set((state) => ({ count: state.count + 1 })),
//   decrement: () => set((state) => ({ count: state.count - 1 })),
//   reset: () => set({ count: 0 }),
// }));
```

#### Checkpoint ✅

- [ ] I can create a store with `create`
- [ ] I understand the `set` function
- [ ] I know the difference between state and actions

---

### Session 4: Reading State Efficiently

#### Exercise 1.2: Create Selectors

```typescript
// YOUR CODE HERE
// Create a store with tasks and create selectors for:
// 1. Total task count
// 2. Completed tasks
// 3. Active tasks (not completed)

interface Task {
  id: string;
  title: string;
  completed: boolean;
}

// Store with tasks










// Write selectors








// Expected usage:
// const totalTasks = useStore((state) => state.taskIds.length);
// const completedTasks = useStore((state) => 
//   state.taskIds.filter(id => state.tasks[id].completed).length
// );
```

#### Exercise 1.3: Optimize with `useShallow`

```typescript
// YOUR CODE HERE
// 1. Import useShallow
// 2. Create a component that uses { tasks, loading } with useShallow
// 3. Explain why this prevents unnecessary re-renders










// Expected code:
// import { useShallow } from 'zustand/react/shallow';
// 
// function TaskStats() {
//   const { tasks, loading } = useStore(
//     useShallow((state) => ({
//       tasks: state.tasks,
//       loading: state.loading,
//     }))
//   );
//   return <div>...</div>;
// }
```

#### Checkpoint ✅

- [ ] I can create selectors for specific state
- [ ] I understand why selectors prevent re-renders
- [ ] I can use `useShallow` for object selectors

---

### Session 5: Updating State

#### Exercise 1.4: Immutable Updates

```typescript
// YOUR CODE HERE
// Create a store with a nested user object:
// user: { name: 'Alice', preferences: { theme: 'dark', language: 'en' } }
// 
// Write actions to:
// 1. Update user name
// 2. Update theme
// 3. Update language










// Expected code:
// updateName: (name) => set((state) => ({
//   user: { ...state.user, name }
// })),
// updateTheme: (theme) => set((state) => ({
//   user: {
//     ...state.user,
//     preferences: { ...state.user.preferences, theme }
//   }
// })),
```

#### Checkpoint ✅

- [ ] I can create immutable updates
- [ ] I know how to update nested objects
- [ ] I understand batching multiple updates

---

### Session 6: Vanilla Stores

#### Exercise 1.5: Create a Vanilla Store

```typescript
// YOUR CODE HERE
// 1. Import createStore from 'zustand/vanilla'
// 2. Create a store with count and increment
// 3. Use it in a React component with useStore
// 4. Use it in a utility function











// Expected code:
// import { createStore } from 'zustand/vanilla';
// import { useStore } from 'zustand';
// 
// const store = createStore((set) => ({
//   count: 0,
//   increment: () => set((state) => ({ count: state.count + 1 })),
// }));
// 
// function Counter() {
//   const count = useStore(store, (state) => state.count);
//   const increment = useStore(store, (state) => state.increment);
//   return <button onClick={increment}>{count}</button>;
// }
```

#### Checkpoint ✅

- [ ] I can create vanilla stores
- [ ] I can use vanilla stores in React
- [ ] I can use vanilla stores in utility modules

---

## Day 2: Advanced State Architecture

### Session 7: Structuring Large Applications

#### Exercise 2.1: Implement the Slice Pattern

```typescript
// YOUR CODE HERE
// Create three slices:
// 1. UserSlice: user, setUser
// 2. TaskSlice: tasks, addTask, toggleTask
// 3. UISlice: theme, toggleTheme
// 
// Combine them into a single store










// Expected code:
// const createUserSlice = (set) => ({
//   user: null,
//   setUser: (user) => set({ user }),
// });
// 
// const createTaskSlice = (set) => ({
//   tasks: [],
//   addTask: (task) => set((state) => ({ tasks: [...state.tasks, task] })),
//   toggleTask: (id) => set((state) => ({
//     tasks: state.tasks.map(t => t.id === id ? { ...t, completed: !t.completed } : t)
//   })),
// });
// 
// const createUISlice = (set) => ({
//   theme: 'light',
//   toggleTheme: () => set((state) => ({ theme: state.theme === 'light' ? 'dark' : 'light' })),
// });
// 
// const useStore = create((set) => ({
//   ...createUserSlice(set),
//   ...createTaskSlice(set),
//   ...createUISlice(set),
// }));
```

#### Checkpoint ✅

- [ ] I can organize stores by domain
- [ ] I can implement the slice pattern
- [ ] I understand why monolithic stores are problematic

---

### Session 8: Middleware

#### Exercise 2.2: Configure Middleware

```typescript
// YOUR CODE HERE
// Create a store with:
// 1. devtools middleware
// 2. persist middleware
// 3. immer middleware
// 
// Include count state with increment/decrement actions










// Expected code:
// import { create } from 'zustand';
// import { devtools, persist } from 'zustand/middleware';
// import { immer } from 'zustand/middleware/immer';
// 
// const useStore = create(
//   devtools(
//     persist(
//       immer((set) => ({
//         count: 0,
//         increment: () => set((state) => {
//           state.count += 1;
//         }),
//         decrement: () => set((state) => {
//           state.count -= 1;
//         }),
//       })),
//       { name: 'counter-storage' }
//     ),
//     { name: 'Counter Store' }
//   )
// );
```

#### Checkpoint ✅

- [ ] I can use devtools middleware
- [ ] I can use persist middleware
- [ ] I can use immer middleware
- [ ] I understand middleware composition order

---

### Session 9: Immutability with Immer

#### Exercise 2.3: Deep Updates with Immer

```typescript
// YOUR CODE HERE
// Create a store with deeply nested state:
// user: {
//   name: 'Alice',
//   preferences: {
//     theme: 'dark',
//     notifications: { email: true, push: true }
//   }
// }
// 
// Write actions to update:
// 1. Name
// 2. Theme
// 3. Email notifications
// using Immer (mutable syntax)










// Expected code:
// const useStore = create(
//   immer((set) => ({
//     user: {
//       name: 'Alice',
//       preferences: {
//         theme: 'dark',
//         notifications: { email: true, push: true },
//       },
//     },
//     updateName: (name) => set((state) => {
//       state.user.name = name;
//     }),
//     updateTheme: (theme) => set((state) => {
//       state.user.preferences.theme = theme;
//     }),
//     toggleEmailNotifications: () => set((state) => {
//       state.user.preferences.notifications.email = 
//         !state.user.preferences.notifications.email;
//     }),
//   }))
// );
```

#### Checkpoint ✅

- [ ] I can use Immer for deep updates
- [ ] I understand when to use Immer vs manual updates

---

### Session 10: State Persistence

#### Exercise 2.4: Advanced Persistence

```typescript
// YOUR CODE HERE
// Create a store with persistence that:
// 1. Only persists user and theme (not isLoading or error)
// 2. Has version 1
// 3. Has a migration from version 0 (old schema had 'userName')
// 4. Logs hydration success/failure










// Expected code:
// const useStore = create(
//   persist(
//     (set) => ({
//       user: null,
//       theme: 'light',
//       isLoading: false,
//       error: null,
//       setUser: (user) => set({ user }),
//       setTheme: (theme) => set({ theme }),
//     }),
//     {
//       name: 'app-storage',
//       version: 1,
//       partialize: (state) => ({
//         user: state.user,
//         theme: state.theme,
//       }),
//       migrate: (persistedState, version) => {
//         if (version === 0) {
//           return {
//             user: { name: persistedState.userName },
//             theme: persistedState.theme || 'light',
//           };
//         }
//         return persistedState;
//       },
//       onRehydrateStorage: () => (state, error) => {
//         if (error) {
//           console.error('Hydration failed:', error);
//         } else {
//           console.log('Hydration successful:', state);
//         }
//       },
//     }
//   )
// );
```

#### Checkpoint ✅

- [ ] I can implement partial persistence
- [ ] I can handle versioning and migrations
- [ ] I understand the hydration lifecycle

---

### Session 11: Debugging

#### Exercise 2.5: Setup Debugging Tools

```typescript
// YOUR CODE HERE
// Configure a store with:
// 1. devtools middleware with named actions
// 2. A logging function that logs before/after updates
// 3. A render counter component









// Expected code:
// const useStore = create(
//   devtools(
//     (set) => ({
//       count: 0,
//       increment: () => set((state) => ({ count: state.count + 1 }), false, 'increment'),
//       decrement: () => set((state) => ({ count: state.count - 1 }), false, 'decrement'),
//     }),
//     { name: 'Counter Store' }
//   )
// );
// 
// function RenderCounter({ name }) {
//   const renderCount = useRef(0);
//   renderCount.current++;
//   return <span>{name} renders: {renderCount.current}</span>;
// }
```

#### Checkpoint ✅

- [ ] I can use Redux DevTools
- [ ] I can name actions for better debugging
- [ ] I can track render counts

---

## Day 3: Asynchronous State Management

### Session 12: Async Actions

#### Exercise 3.1: Async Data Fetching

```typescript
// YOUR CODE HERE
// Create a store that:
// 1. Fetches data from an API
// 2. Shows loading state
// 3. Handles errors
// 4. Has a retry mechanism
// 5. Can cancel requests











// Expected code:
// const useStore = create((set, get) => ({
//   data: null,
//   loading: false,
//   error: null,
//   controller: null,
//   fetchData: async (url) => {
//     if (get().controller) {
//       get().controller.abort();
//     }
//     const controller = new AbortController();
//     set({ controller, loading: true, error: null });
//     
//     try {
//       const response = await fetch(url, { signal: controller.signal });
//       if (!response.ok) throw new Error(`HTTP ${response.status}`);
//       const data = await response.json();
//       set({ data, loading: false, controller: null });
//     } catch (error) {
//       if (error.name === 'AbortError') {
//         console.log('Request cancelled');
//       } else {
//         set({ error: error.message, loading: false });
//       }
//       set({ controller: null });
//     }
//   },
// }));
```

#### Checkpoint ✅

- [ ] I can handle loading states
- [ ] I can handle errors in async actions
- [ ] I can cancel requests with AbortController

---

### Session 13: Concurrency & Race Conditions

#### Exercise 3.2: Request Deduplication

```typescript
// YOUR CODE HERE
// Implement request deduplication that:
// 1. Tracks pending requests
// 2. Returns the same promise for duplicate requests
// 3. Cleans up after completion










// Expected code:
// const useStore = create((set, get) => ({
//   data: null,
//   pendingRequests: new Map(),
//   fetchData: async (id) => {
//     const key = `data-${id}`;
//     if (get().pendingRequests.has(key)) {
//       return get().pendingRequests.get(key);
//     }
//     
//     const promise = (async () => {
//       set({ loading: true });
//       const response = await fetch(`/api/data/${id}`);
//       const data = await response.json();
//       set({ data, loading: false });
//       return data;
//     })();
//     
//     set((state) => ({
//       pendingRequests: new Map(state.pendingRequests).set(key, promise),
//     }));
//     
//     try {
//       return await promise;
//     } finally {
//       set((state) => {
//         const newMap = new Map(state.pendingRequests);
//         newMap.delete(key);
//         return { pendingRequests: newMap };
//       });
//     }
//   },
// }));
```

#### Checkpoint ✅

- [ ] I can implement request deduplication
- [ ] I can handle race conditions with request IDs
- [ ] I can implement optimistic updates

---

### Session 14: Working with External APIs

#### Exercise 3.3: API Integration

```typescript
// YOUR CODE HERE
// Create a store that integrates with:
// 1. REST API (GET, POST, PUT, DELETE)
// 2. Error handling for all HTTP methods
// 3. Loading states for each operation











// Expected code:
// const useStore = create((set) => ({
//   posts: [],
//   loading: { fetch: false, create: false, update: false, delete: false },
//   error: null,
//   fetchPosts: async () => {
//     set({ loading: { ...get().loading, fetch: true } });
//     try {
//       const response = await fetch('/api/posts');
//       const data = await response.json();
//       set({ posts: data, loading: { ...get().loading, fetch: false } });
//     } catch (error) {
//       set({ error: error.message, loading: { ...get().loading, fetch: false } });
//     }
//   },
//   createPost: async (post) => {
//     set({ loading: { ...get().loading, create: true } });
//     try {
//       const response = await fetch('/api/posts', {
//         method: 'POST',
//         body: JSON.stringify(post),
//       });
//       const data = await response.json();
//       set((state) => ({
//         posts: [...state.posts, data],
//         loading: { ...state.loading, create: false },
//       }));
//     } catch (error) {
//       set({ error: error.message, loading: { ...get().loading, create: false } });
//     }
//   },
// }));
```

#### Checkpoint ✅

- [ ] I can integrate with REST APIs
- [ ] I can handle different HTTP methods
- [ ] I can manage per-operation loading states

---

### Session 15: Custom Middleware

#### Exercise 3.4: Build Custom Middleware

```typescript
// YOUR CODE HERE
// Create a custom middleware that:
// 1. Logs every update with timestamps
// 2. Tracks total update count
// 3. Detects slow updates (> 50ms)
// 4. Reports errors to a monitoring service











// Expected code:
// const createPerformanceMiddleware = (threshold = 50) => {
//   let updateCount = 0;
//   return (config) => (set, get, store) => {
//     return config(
//       (args) => {
//         updateCount++;
//         const start = performance.now();
//         try {
//           set(args);
//         } catch (error) {
//           console.error('Store update error:', error);
//           // Report to monitoring
//           Sentry.captureException(error);
//           throw error;
//         }
//         const duration = performance.now() - start;
//         console.log(`Update #${updateCount} took ${duration.toFixed(2)}ms`);
//         if (duration > threshold) {
//           console.warn(`Slow update detected: ${duration.toFixed(2)}ms`);
//         }
//       },
//       get,
//       store
//     );
//   };
// };
```

#### Checkpoint ✅

- [ ] I can build custom middleware
- [ ] I understand middleware execution order
- [ ] I can compose multiple middleware

---

## Day 4: Performance Optimization & Ecosystem

### Session 16: Rendering Optimization

#### Exercise 4.1: Optimize Component Rendering

```typescript
// YOUR CODE HERE
// Take this component and optimize it:
// 1. Use focused selectors
// 2. Add useShallow where appropriate
// 3. Add useMemo for derived data
// 4. Add React.memo for list items










// Original code:
// function TaskList() {
//   const tasks = useStore((state) => state.tasks);
//   const filter = useStore((state) => state.filter);
//   const search = useStore((state) => state.search);
//   
//   const filtered = tasks.filter(t => {
//     if (filter === 'active' && t.completed) return false;
//     if (filter === 'completed' && !t.completed) return false;
//     if (search && !t.title.includes(search)) return false;
//     return true;
//   });
//   
//   return filtered.map(task => <TaskItem key={task.id} task={task} />);
// }
//
// function TaskItem({ task }) {
//   return <div>{task.title}</div>;
// }
```

#### Checkpoint ✅

- [ ] I can optimize component subscriptions
- [ ] I can use React.memo effectively
- [ ] I can use useMemo for derived state

---

### Session 17: Store Design for Performance

#### Exercise 4.2: Normalize State

```typescript
// YOUR CODE HERE
// Normalize this denormalized state:
// tasks: Task[] where Task has assignee: User
// 
// Create normalized state with:
// tasks: Record<string, Task>
// taskIds: string[]
// users: Record<string, User>
// userIds: string[]
// userTaskIds: Record<string, string[]>








// Expected code:
// interface NormalizedState {
//   tasks: Record<string, Task>;
//   taskIds: string[];
//   users: Record<string, User>;
//   userIds: string[];
//   userTaskIds: Record<string, string[]>;
// }
// 
// // Actions to update normalized state
// addTask: (task: Task) => {
//   set((state) => ({
//     tasks: { ...state.tasks, [task.id]: task },
//     taskIds: [...state.taskIds, task.id],
//     userTaskIds: {
//       ...state.userTaskIds,
//       [task.assigneeId]: [
//         ...(state.userTaskIds[task.assigneeId] || []),
//         task.id,
//       ],
//     },
//   }));
// },
// 
// // Selector
// const getTasksForUser = (userId) => {
//   const state = get();
//   return (state.userTaskIds[userId] || []).map(id => state.tasks[id]);
// };
```

#### Checkpoint ✅

- [ ] I can normalize state
- [ ] I can create efficient lookups
- [ ] I can prevent cascading updates

---

### Session 18: Benchmarking

#### Exercise 4.3: Performance Testing

```typescript
// YOUR CODE HERE
// Write a performance test that:
// 1. Adds 1000 items
// 2. Updates 500 items
// 3. Deletes 100 items
// 4. Measures time for each operation
// 5. Logs results to console











// Expected code:
// async function performanceTest() {
//   const store = useStore.getState();
//   
//   console.time('Add 1000 items');
//   for (let i = 0; i < 1000; i++) {
//     store.addItem({ id: i, name: `Item ${i}` });
//   }
//   console.timeEnd('Add 1000 items');
//   
//   console.time('Update 500 items');
//   const ids = store.itemIds.slice(0, 500);
//   for (const id of ids) {
//     store.updateItem(id, { name: `Updated ${id}` });
//   }
//   console.timeEnd('Update 500 items');
//   
//   console.time('Delete 100 items');
//   const deleteIds = store.itemIds.slice(0, 100);
//   for (const id of deleteIds) {
//     store.deleteItem(id);
//   }
//   console.timeEnd('Delete 100 items');
//   
//   const stateSize = new Blob([JSON.stringify(store.getState())]).size;
//   console.log(`State size: ${(stateSize / 1024).toFixed(1)} KB`);
// }
```

#### Checkpoint ✅

- [ ] I can write performance tests
- [ ] I can measure state size
- [ ] I can identify performance bottlenecks

---

### Session 19: Zustand with React 19

#### Exercise 4.4: React 19 Integration

```typescript
// YOUR CODE HERE
// Create a component that:
// 1. Uses useTransition with Zustand
// 2. Uses useOptimistic with Zustand
// 3. Uses useActionState with Zustand










// Expected code:
// // useTransition
// function SearchComponent() {
//   const [query, setQuery] = useState('');
//   const [isPending, startTransition] = useTransition();
//   const search = useStore((state) => state.search);
//   
//   const handleSearch = (value) => {
//     setQuery(value);
//     startTransition(() => {
//       search(value);
//     });
//   };
// }
// 
// // useOptimistic
// function TaskList() {
//   const tasks = useStore((state) => state.tasks);
//   const addTask = useStore((state) => state.addTask);
//   const [optimisticTasks, addOptimisticTask] = useOptimistic(
//     tasks,
//     (current, newTask) => [...current, { ...newTask, optimistic: true }]
//   );
// }
// 
// // useActionState
// function TaskForm() {
//   const addTask = useStore((state) => state.addTask);
//   const [state, action, isPending] = useActionState(
//     async (prev, formData) => {
//       await addTask(formData.get('title'));
//       return { success: true };
//     },
//     { success: false }
//   );
// }
```

#### Checkpoint ✅

- [ ] I can use useTransition with Zustand
- [ ] I can use useOptimistic with Zustand
- [ ] I can use useActionState with Zustand

---

### Session 20: Zustand with React Native

#### Exercise 4.5: React Native Store

```typescript
// YOUR CODE HERE
// Create a React Native store that:
// 1. Persists with AsyncStorage
// 2. Uses MMKV for fast storage
// 3. Has offline queue
// 4. Optimizes for mobile performance










// Expected code:
// import { MMKV } from 'react-native-mmkv';
// 
// const mmkv = new MMKV({ id: 'app-storage' });
// const mmkvStorage = {
//   getItem: (key) => mmkv.getString(key) || null,
//   setItem: (key, value) => mmkv.set(key, value),
//   removeItem: (key) => mmkv.delete(key),
// };
// 
// const useStore = create(
//   persist(
//     (set) => ({
//       tasks: [],
//       offlineQueue: [],
//       addTask: (task) => {
//         set((state) => ({ tasks: [...state.tasks, task] }));
//         if (!navigator.onLine) {
//           set((state) => ({
//             offlineQueue: [...state.offlineQueue, { type: 'add', payload: task }],
//           }));
//         }
//       },
//       syncQueue: async () => {
//         const { offlineQueue } = get();
//         for (const action of offlineQueue) {
//           // Sync to server
//         }
//         set({ offlineQueue: [] });
//       },
//     }),
//     {
//       name: 'app-storage',
//       storage: createJSONStorage(() => mmkvStorage),
//     }
//   )
// );
```

#### Checkpoint ✅

- [ ] I can set up AsyncStorage persistence
- [ ] I can use MMKV for faster storage
- [ ] I can implement offline queues

---

### Session 21: Zustand with Next.js 16

#### Exercise 4.6: Next.js Integration

```typescript
// YOUR CODE HERE
// Create a Next.js 16 integration that:
// 1. Seeds Zustand from Server Components
// 2. Prevents hydration mismatches
// 3. Uses request-isolated stores
// 4. Uses 'use cache' directive










// Expected code:
// // Server Component
// export default async function Page() {
//   const tasks = await fetchTasks();
//   return <TaskListClient initialTasks={tasks} />;
// }
// 
// // Client Component
// 'use client';
// import { useEffect } from 'react';
// import { useTaskStore } from '@taskflow/shared';
// 
// export function TaskListClient({ initialTasks }) {
//   const setTasks = useTaskStore((state) => state.setTasks);
//   const tasks = useTaskStore((state) => state.tasks);
//   
//   useEffect(() => {
//     setTasks(initialTasks);
//   }, []);
//   
//   return <div>{tasks.length}</div>;
// }
// 
// // Hydration guard
// export function useHydrated() {
//   const [hydrated, setHydrated] = useState(false);
//   useEffect(() => setHydrated(true), []);
//   return hydrated;
// }
```

#### Checkpoint ✅

- [ ] I can integrate Server Components
- [ ] I can prevent hydration mismatches
- [ ] I can use request-isolated stores

---

## Day 5: Production Patterns, Testing & Enterprise

### Session 22: Authentication

#### Exercise 5.1: Auth Store

```typescript
// YOUR CODE HERE
// Create a complete authentication store with:
// 1. Login with credentials
// 2. Registration
// 3. Logout
// 4. Token refresh
// 5. Role-based access control
// 6. Persistence
// 7. Error handling










// Expected code:
// const useAuthStore = create(
//   persist(
//     (set, get) => ({
//       user: null,
//       token: null,
//       isLoading: false,
//       error: null,
//       login: async (email, password) => {
//         set({ isLoading: true, error: null });
//         try {
//           const response = await api.login(email, password);
//           set({ user: response.user, token: response.token, isLoading: false });
//         } catch (error) {
//           set({ error: error.message, isLoading: false });
//         }
//       },
//       logout: async () => {
//         await api.logout();
//         set({ user: null, token: null });
//       },
//       refreshSession: async () => {
//         const { token } = get();
//         if (!token) return;
//         try {
//           const newToken = await api.refresh(token);
//           set({ token: newToken });
//         } catch (error) {
//           set({ user: null, token: null });
//         }
//       },
//       hasRole: (role) => get().user?.role === role,
//     }),
//     { name: 'auth-storage' }
//   )
// );
```

#### Checkpoint ✅

- [ ] I can implement JWT authentication
- [ ] I can handle token refresh
- [ ] I can implement RBAC

---

### Session 23: Shopping Cart

#### Exercise 5.2: Shopping Cart Store

```typescript
// YOUR CODE HERE
// Create a shopping cart store with:
// 1. Add/remove/update quantity
// 2. Inventory validation
// 3. Subtotal/tax/total calculations
// 4. Coupon support
// 5. Offline support with queue
// 6. Persistence










// Expected code:
// const useCartStore = create(
//   persist(
//     (set, get) => ({
//       items: [],
//       subtotal: 0,
//       tax: 0,
//       total: 0,
//       coupon: null,
//       offlineQueue: [],
//       addItem: (product, quantity) => {
//         if (!get().validateInventory(product.id, quantity)) {
//           throw new Error('Not enough stock');
//         }
//         set((state) => {
//           const existing = state.items.find(i => i.productId === product.id);
//           let items;
//           if (existing) {
//             items = state.items.map(i =>
//               i.productId === product.id ? { ...i, quantity: i.quantity + quantity } : i
//             );
//           } else {
//             items = [...state.items, { productId: product.id, product, quantity }];
//           }
//           return {
//             items,
//             subtotal: items.reduce((sum, i) => sum + i.product.price * i.quantity, 0),
//             tax: items.reduce((sum, i) => sum + i.product.price * i.quantity * 0.1, 0),
//             total: items.reduce((sum, i) => sum + i.product.price * i.quantity * 1.1, 0),
//           };
//         });
//         if (!navigator.onLine) {
//           set((state) => ({
//             offlineQueue: [...state.offlineQueue, { type: 'add', product, quantity }],
//           }));
//         }
//       },
//       applyCoupon: (code) => {
//         // Validate and apply coupon
//       },
//     }),
//     { name: 'cart-storage' }
//   )
// );
```

#### Checkpoint ✅

- [ ] I can implement cart operations
- [ ] I can handle inventory validation
- [ ] I can support offline mode

---

### Session 24: Dashboards

#### Exercise 5.3: Dashboard Store

```typescript
// YOUR CODE HERE
// Create a dashboard store with:
// 1. Widget management (add/remove/update)
// 2. Filtering
// 3. User preferences (layout, refresh interval)
// 4. Data caching
// 5. Auto-refresh
// 6. Persistence










// Expected code:
// const useDashboardStore = create(
//   persist(
//     (set, get) => ({
//       widgets: [],
//       filters: {},
//       preferences: { layout: 'grid', refreshInterval: 30 },
//       cache: {},
//       addWidget: (widget) => {
//         set((state) => ({ widgets: [...state.widgets, { ...widget, id: Date.now() }] }));
//       },
//       removeWidget: (id) => {
//         set((state) => ({ widgets: state.widgets.filter(w => w.id !== id) }));
//       },
//       setFilters: (filters) => {
//         set((state) => ({ filters: { ...state.filters, ...filters } }));
//         // Clear cache when filters change
//         set({ cache: {} });
//         get().refreshAll();
//       },
//       refreshAll: async () => {
//         const widgets = get().widgets;
//         for (const widget of widgets) {
//           const key = `${widget.id}-${JSON.stringify(get().filters)}`;
//           if (get().cache[key]) continue;
//           const data = await fetchWidgetData(widget, get().filters);
//           set((state) => ({
//             cache: { ...state.cache, [key]: data },
//             widgets: state.widgets.map(w =>
//               w.id === widget.id ? { ...w, data, lastUpdated: new Date() } : w
//             ),
//           }));
//         }
//       },
//     }),
//     { name: 'dashboard-storage' }
//   )
// );
```

#### Checkpoint ✅

- [ ] I can manage widgets
- [ ] I can implement filtering
- [ ] I can cache data

---

### Session 25: Forms

#### Exercise 5.4: Form Store

```typescript
// YOUR CODE HERE
// Create a form store with:
// 1. Multi-step navigation
// 2. Field-level validation
// 3. Draft saving
// 4. Undo/redo
// 5. Submission with optimistic update
// 6. Persistence










// Expected code:
// const useFormStore = create(
//   persist(
//     (set, get) => ({
//       data: {},
//       errors: {},
//       touched: {},
//       currentStep: 0,
//       steps: [
//         { id: 'personal', title: 'Personal' },
//         { id: 'address', title: 'Address' },
//         { id: 'review', title: 'Review' },
//       ],
//       history: { past: [], present: {}, future: [] },
//       setField: (field, value) => {
//         set((state) => ({
//           data: { ...state.data, [field]: value },
//           touched: { ...state.touched, [field]: true },
//         }));
//         // Validate field
//         const error = validateField(field, value);
//         set((state) => ({
//           errors: error ? { ...state.errors, [field]: error } : (() => {
//             const { [field]: _, ...rest } = state.errors;
//             return rest;
//           })(),
//         }));
//         // Push to history
//         set((state) => ({
//           history: {
//             past: [...state.history.past, state.history.present],
//             present: { ...state.data },
//             future: [],
//           },
//         }));
//       },
//       undo: () => set((state) => {
//         if (state.history.past.length === 0) return state;
//         const past = [...state.history.past];
//         const previous = past.pop();
//         return {
//           history: {
//             past,
//             present: previous,
//             future: [state.history.present, ...state.history.future],
//           },
//           data: previous,
//         };
//       }),
//       nextStep: () => {
//         // Validate current step
//         set((state) => ({
//           currentStep: Math.min(state.currentStep + 1, state.steps.length - 1),
//         }));
//       },
//     }),
//     { name: 'form-storage' }
//   )
// );
```

#### Checkpoint ✅

- [ ] I can implement multi-step forms
- [ ] I can add field validation
- [ ] I can implement undo/redo

---

### Session 26: Real-Time Applications

#### Exercise 5.5: Real-Time Store

```typescript
// YOUR CODE HERE
// Create a real-time store with:
// 1. WebSocket connection management
// 2. Presence tracking
// 3. Typing indicators
// 4. Activity feed
// 5. Offline message queuing
// 6. Reconnection logic










// Expected code:
// const useRealtimeStore = create((set, get) => ({
//   messages: [],
//   onlineUsers: [],
//   isConnected: false,
//   typingUsers: {},
//   activities: [],
//   offlineQueue: [],
//   
//   addMessage: (message) => {
//     set((state) => ({
//       messages: [...state.messages, message],
//     }));
//     if (!get().isConnected) {
//       set((state) => ({
//         offlineQueue: [...state.offlineQueue, { type: 'message', payload: message }],
//       }));
//     }
//   },
//   
//   setOnlineUsers: (users) => set({ onlineUsers: users }),
//   setConnected: (connected) => set({ isConnected: connected }),
//   
//   setUserTyping: (userId, userName, isTyping) => {
//     set((state) => ({
//       typingUsers: isTyping
//         ? { ...state.typingUsers, [userId]: { userId, userName } }
//         : (() => {
//             const { [userId]: _, ...rest } = state.typingUsers;
//             return rest;
//           })(),
//     }));
//   },
//   
//   addActivity: (activity) => {
//     set((state) => ({
//       activities: [activity, ...state.activities].slice(0, 50),
//     }));
//   },
//   
//   syncOfflineQueue: async () => {
//     const { offlineQueue } = get();
//     for (const item of offlineQueue) {
//       // Process offline items
//     }
//     set({ offlineQueue: [] });
//   },
// }));
```

#### Checkpoint ✅

- [ ] I can implement WebSocket integration
- [ ] I can track presence
- [ ] I can handle offline queuing

---

### Session 27: Testing

#### Exercise 5.6: Testing Stores

```typescript
// YOUR CODE HERE
// Write tests for:
// 1. Unit tests for all store actions
// 2. Async action tests with mocks
// 3. Integration tests with React Testing Library
// 4. E2E tests for critical user journeys











// Expected code:
// // Unit test
// describe('Task Store', () => {
//   beforeEach(() => {
//     useTaskStore.setState({ tasks: {}, taskIds: [] });
//   });
//   
//   it('should add a task', () => {
//     const { addTask } = useTaskStore.getState();
//     addTask('Test Task');
//     const state = useTaskStore.getState();
//     expect(state.taskIds).toHaveLength(1);
//     expect(state.tasks[state.taskIds[0]].title).toBe('Test Task');
//   });
// });
// 
// // Integration test
// it('should display tasks', async () => {
//   useTaskStore.setState({
//     tasks: { '1': { id: '1', title: 'Task 1', completed: false } },
//     taskIds: ['1'],
//   });
//   render(<TaskList />);
//   expect(screen.getByText('Task 1')).toBeInTheDocument();
// });
```

#### Checkpoint ✅

- [ ] I can write unit tests
- [ ] I can write integration tests
- [ ] I can mock API calls

---

### Session 28: Enterprise Best Practices

#### Exercise 5.7: Production Configuration

```typescript
// YOUR CODE HERE
// Configure a store for production with:
// 1. Error boundaries
// 2. Logging (disabled in production)
// 3. Performance monitoring
// 4. Environment-based configuration
// 5. Feature flags











// Expected code:
// // Environment configuration
// const config = {
//   devtools: process.env.NODE_ENV === 'development',
//   logging: process.env.NODE_ENV === 'development',
//   performanceMonitoring: process.env.NODE_ENV === 'production',
// };
// 
// // Store with conditional middleware
// const useStore = create(
//   config.devtools ? devtools((set) => ({ ... })) : (set) => ({ ... })
// );
// 
// // Error boundary
// class StoreErrorBoundary extends React.Component {
//   componentDidCatch(error, errorInfo) {
//     if (process.env.NODE_ENV === 'production') {
//       Sentry.captureException(error, { extra: errorInfo });
//     }
//   }
// }
// 
// // Performance monitoring
// const performanceMonitor = (threshold = 50) => (config) => (set, get, store) => {
//   return config(
//     (args) => {
//       const start = performance.now();
//       set(args);
//       const duration = performance.now() - start;
//       if (duration > threshold) {
//         console.warn(`Slow update: ${duration}ms`);
//       }
//     },
//     get,
//     store
//   );
// };
```

#### Checkpoint ✅

- [ ] I can configure stores for production
- [ ] I can implement error boundaries
- [ ] I can add performance monitoring

---

## Appendix: Quick Reference Cards

### Zustand API Quick Reference

| API | Description | Example |
|-----|-------------|---------|
| `create` | Create a store | `create((set) => ({ count: 0 }))` |
| `set` | Update state | `set((state) => ({ count: state.count + 1 }))` |
| `get` | Get current state | `get().count` |
| `subscribe` | Listen to changes | `store.subscribe((state) => console.log(state))` |
| `useStore` | React hook | `useStore((state) => state.count)` |
| `useShallow` | Shallow comparison | `useShallow((state) => ({...}))` |

### Common Middleware

| Middleware | Purpose | Example |
|------------|---------|---------|
| `devtools` | Redux DevTools | `devtools(config, { name: 'Store' })` |
| `persist` | State persistence | `persist(config, { name: 'storage' })` |
| `immer` | Immutable updates | `immer(config)` |
| `subscribeWithSelector` | Selective subscriptions | `subscribeWithSelector(config)` |
| `combine` | Combine state/actions | `combine({ count: 0 }, (set) => ({...}))` |

### Performance Optimization Tips

1. **Use selectors** – `useStore((state) => state.count)`
2. **Use `useShallow`** for object selectors
3. **Memoize selectors** with `reselect`
4. **Use `React.memo`** for list items
5. **Normalize state** – `Record<string, T>` + `string[]`
6. **Split stores** by domain and frequency
7. **Virtualize large lists** with `react-window`

### Anti-Patterns to Avoid

| Anti-Pattern | Solution |
|--------------|----------|
| Over-subscription | Use selectors |
| Direct mutation | Use immutable updates or Immer |
| Monolithic store | Split by domain |
| No error handling | Add error boundaries |
| No persistence | Add persist middleware |
| Race conditions | Use request IDs |

---

## Glossary

| Term | Definition |
|------|------------|
| **Action** | Function in a store that updates state |
| **Async Action** | Action that performs async operations |
| **Atom** | Smallest unit of state |
| **Batching** | Grouping multiple updates into one |
| **Computed State** | State derived from other state |
| **DevTools** | Redux DevTools integration |
| **Domain-Driven Design** | Organizing code by business domains |
| **Factory Function** | Function that creates store instances |
| **Feature Flag** | Toggle features in production |
| **Hydration** | Loading persisted state into store |
| **Immutable** | Data that cannot be changed after creation |
| **Memoization** | Caching expensive computations |
| **Middleware** | Functions that wrap stores |
| **Migration** | Updating persisted state schema |
| **Normalization** | Structuring state to avoid duplication |
| **Optimistic Update** | UI updates immediately, sync in background |
| **Persistence** | Saving state to storage |
| **Provider** | React component providing context (not needed) |
| **Race Condition** | Timing-dependent bugs in async operations |
| **Request Deduplication** | Preventing duplicate concurrent requests |
| **Selector** | Function extracting specific state |
| **Server Component** | React component running on server |
| **Slice** | Modular piece of a store |
| **State** | Data in the store |
| **Store** | Container holding state and actions |
| **Time-Travel Debugging** | Jumping through state history |
| **Vanilla Store** | Store without React hooks |
| **Virtualization** | Rendering only visible items |

---

## Final Assessment

### Project: Build a Complete Application

**Objective:** Build a small application using everything you've learned.

**Requirements:**
- ✅ At least 3 stores (auth, tasks, UI)
- ✅ At least 1 slice pattern
- ✅ At least 1 middleware (persist or devtools)
- ✅ At least 1 async action with loading/error states
- ✅ At least 1 selector with `useShallow`
- ✅ At least 1 unit test
- ✅ At least 1 integration test

**Application Idea:** ___________________

**Store Structure:**
```
store/
├── authStore.ts
├── taskStore.ts
├── uiStore.ts
└── slices/
    ├── crudSlice.ts
    └── filterSlice.ts
```

**Key Features:**
1. ___________________
2. ___________________
3. ___________________

**Testing Plan:**
1. ___________________
2. ___________________
3. ___________________

---

## Course Completion Checklist

### Day 1: Foundations ✅
- [ ] Understanding Zustand
- [ ] Creating your first store
- [ ] Reading state efficiently
- [ ] Updating state
- [ ] Vanilla stores

### Day 2: Advanced Architecture ✅
- [ ] Structuring large applications
- [ ] Middleware
- [ ] Immutability with Immer
- [ ] State persistence
- [ ] Debugging

### Day 3: Async State Management ✅
- [ ] Async actions
- [ ] Concurrency & race conditions
- [ ] External APIs
- [ ] Custom middleware

### Day 4: Performance & Ecosystem ✅
- [ ] Rendering optimization
- [ ] Store design
- [ ] Benchmarking
- [ ] React 19 integration
- [ ] React Native integration
- [ ] Next.js 16 integration

### Day 5: Production & Enterprise ✅
- [ ] Authentication
- [ ] Shopping cart
- [ ] Dashboards
- [ ] Forms
- [ ] Real-time applications
- [ ] Testing
- [ ] Enterprise best practices

---

**Course Complete! 🎉**

**Student Signature:** ___________________

**Instructor Signature:** ___________________

---

[END OF STUDENT WORKBOOK]
