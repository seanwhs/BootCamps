# Part 8 — Enterprise Best Practices

## Section 33: Anti-Patterns and Common Pitfalls

After building Zustand applications for years, patterns emerge—both good and bad. In this section, we'll explore the most common anti-patterns and pitfalls that teams encounter when using Zustand at scale. Understanding these mistakes will help you avoid them, leading to more maintainable, performant, and bug-free applications.

---

## The Target: Awareness and Prevention

By the end of this section, you'll be able to:
- Identify common Zustand anti-patterns in your codebase
- Recognize warning signs of architectural issues
- Apply corrective patterns to fix problematic code
- Prevent anti-patterns through proper design principles
- Review code with a critical eye for these common pitfalls

---

## The Concept: Anti-Patterns as Warning Signs

Think of anti-patterns like **traffic hazards**:

```
┌─────────────────────────────────────────────────────────────────┐
│                    ANTI-PATTERNS TO AVOID                      │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  🚦 WARNING SIGNS                                      │  │
│  │  • Slow renders                                        │  │
│  │  • Hard-to-debug bugs                                  │  │
│  │  • Code duplication                                    │  │
│  │  • Circular dependencies                               │  │
│  └──────────────────────────────────────────────────────────┘  │
│                         │                                      │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  🚫 ANTI-PATTERNS                                      │  │
│  │  • Over-subscription                                   │  │
│  │  • Direct Mutation                                     │  │
│  │  • Provider Hoarding                                   │  │
│  │  • Selector Abuse                                      │  │
│  │  • Async Anti-Patterns                                 │  │
│  │  • Monolithic Stores                                   │  │
│  └──────────────────────────────────────────────────────────┘  │
│                         │                                      │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  ✅ CORRECT PATTERNS                                   │  │
│  │  • Fine-grained subscriptions                          │  │
│  │  • Immutable updates                                    │  │
│  │  • No Provider needed                                  │  │
│  │  • Memoized selectors                                   │  │
│  │  • Proper async handling                                │  │
│  │  • Domain-driven stores                                 │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Anti-Pattern 1: Over-Subscribing to State

**The Problem**: Subscribing to the entire store when you only need a small piece.

```typescript
// ❌ ANTI-PATTERN: Subscribing to the entire store
function TaskCounter() {
  const store = useTaskStore(); // Subscribes to EVERYTHING
  // Re-renders when ANY state changes
  return <div>Total tasks: {store.tasks.length}</div>;
}

// ✅ CORRECT: Subscribe only to what you need
function TaskCounter() {
  const taskCount = useTaskStore((state) => state.taskIds.length);
  // Only re-renders when taskIds.length changes
  return <div>Total tasks: {taskCount}</div>;
}
```

**Why It Happens**:
- Laziness (it's easier to grab the whole store)
- Lack of understanding of Zustand's subscription model
- Copy-paste from tutorials

**How to Fix**:
- Always use selectors
- Use multiple selectors for multiple pieces of state
- Use `useShallow` when selecting multiple properties
- Audit your components for over-subscription

**Detection Tools**:
- React DevTools Profiler (look for components that render too often)
- Add render counters to debug re-renders

---

## Anti-Pattern 2: Direct Mutation of State

**The Problem**: Mutating state directly instead of using immutable updates.

```typescript
// ❌ ANTI-PATTERN: Direct mutation
const useBadStore = create((set, get) => ({
  tasks: [],
  addTask: (task) => {
    // Mutating state directly - WRONG!
    const state = get();
    state.tasks.push(task);
    set(state); // This won't trigger updates properly
  },
}));

// ❌ ANTI-PATTERN: Incomplete updates
const useBadStore = create((set, get) => ({
  user: { name: 'John', preferences: { theme: 'dark' } },
  updateTheme: (theme) => {
    // Only shallow copy - preferences object is mutated!
    set((state) => ({
      user: { ...state.user, preferences: { ...state.user.preferences, theme } }
    }));
  },
}));

// ✅ CORRECT: Immutable updates with proper nesting
const useGoodStore = create((set, get) => ({
  tasks: [],
  addTask: (task) => {
    set((state) => ({
      tasks: [...state.tasks, task] // Creates a new array
    }));
  },
  user: { name: 'John', preferences: { theme: 'dark' } },
  updateTheme: (theme) => {
    set((state) => ({
      user: {
        ...state.user,
        preferences: {
          ...state.user.preferences,
          theme,
        },
      },
    }));
  },
}));

// ✅ EVEN BETTER: Use Immer middleware
const useImmerStore = create(
  immer((set) => ({
    tasks: [],
    addTask: (task) => {
      set((state) => {
        state.tasks.push(task); // Immer handles immutability
      });
    },
    user: { name: 'John', preferences: { theme: 'dark' } },
    updateTheme: (theme) => {
      set((state) => {
        state.user.preferences.theme = theme;
      });
    },
  }))
);
```

**Why It Happens**:
- Confusion with mutable state patterns (common in MobX or plain JS)
- Thinking Zustand works like `useState` with object updates
- Not understanding immutability requirements

**How to Fix**:
- Always use the functional form of `set` with spread operators
- Use Immer middleware for complex nested updates
- Enable strict mode and TypeScript to catch mutations
- Use `Object.freeze()` in development to detect mutations

**Detection Tools**:
- Use immutability checker middleware in development
- Watch for bugs where state doesn't update after a change

---

## Anti-Pattern 3: Provider Hoarding (Using Providers Unnecessarily)

**The Problem**: Adding Provider wrappers when Zustand doesn't need them.

```typescript
// ❌ ANTI-PATTERN: Unnecessary Provider
const TaskContext = createContext(null);

function TaskProvider({ children }) {
  const store = useTaskStore();
  return (
    <TaskContext.Provider value={store}>
      {children}
    </TaskContext.Provider>
  );
}

function App() {
  return (
    <TaskProvider>  {/* Wrapping the whole app for no reason! */}
      <TaskList />
    </TaskProvider>
  );
}

// ✅ CORRECT: Direct store usage
function App() {
  return <TaskList />; // No provider needed!
}

// ⚠️ EXCEPTION: There ARE legitimate use cases:
// 1. You need to provide different store instances per subtree
// 2. You're using context for dependency injection
// 3. You're in a framework like Next.js with request isolation
const StoreContext = createContext<StoreApi<TaskStore> | null>(null);

function StoreProvider({ store, children }) {
  return (
    <StoreContext.Provider value={store}>
      {children}
    </StoreContext.Provider>
  );
}

function useScopedStore() {
  const store = useContext(StoreContext);
  if (!store) {
    throw new Error('useScopedStore must be used within StoreProvider');
  }
  return useStore(store);
}
```

**Why It Happens**:
- Carryover from Redux or Context API habits
- Not understanding that Zustand stores are global by default
- Over-engineering

**How to Fix**:
- Remove unnecessary Provider wrappers
- Use Zustand stores directly
- Only use context when you need scoped or request-isolated stores

---

## Anti-Pattern 4: Selector Abuse

**The Problem**: Creating expensive or unnecessary selectors.

```typescript
// ❌ ANTI-PATTERN: Creating new objects in selectors without shallow
function TaskStats() {
  const stats = useTaskStore((state) => ({
    total: state.tasks.length,
    completed: state.tasks.filter(t => t.completed).length,
    active: state.tasks.filter(t => !t.completed).length,
  }));
  // Creates a NEW object on EVERY render → causes re-renders!
  return <div>{stats.total}</div>;
}

// ❌ ANTI-PATTERN: Expensive computations in selectors
function ExpensiveList() {
  const sortedTasks = useTaskStore((state) => 
    state.tasks
      .filter(t => !t.completed)
      .sort((a, b) => a.priority - b.priority)
      .map(t => ({ ...t, formatted: t.text.toUpperCase() }))
  );
  // This runs on EVERY render, even if tasks haven't changed!
  return sortedTasks.map(task => <div key={task.id}>{task.formatted}</div>);
}

// ❌ ANTI-PATTERN: Inline functions in selectors
const activeTasks = useTaskStore((state) => 
  state.tasks.filter(t => !t.completed)
);
// The filter function is recreated on every render

// ✅ CORRECT: Use shallow for object selectors
function TaskStats() {
  const stats = useTaskStore(
    useShallow((state) => ({
      total: state.tasks.length,
      completed: state.tasks.filter(t => t.completed).length,
      active: state.tasks.filter(t => !t.completed).length,
    }))
  );
  // Only re-renders when stats actually change
  return <div>{stats.total}</div>;
}

// ✅ CORRECT: Use memoized selectors for expensive computations
import { createSelector } from 'reselect';

const selectFilteredAndSortedTasks = createSelector(
  [(state) => state.tasks],
  (tasks) => tasks
    .filter(t => !t.completed)
    .sort((a, b) => a.priority - b.priority)
    .map(t => ({ ...t, formatted: t.text.toUpperCase() }))
);

function ExpensiveList() {
  const sortedTasks = useTaskStore(selectFilteredAndSortedTasks);
  // Only recomputes when tasks change
  return sortedTasks.map(task => <div key={task.id}>{task.formatted}</div>);
}

// ✅ CORRECT: Extract selector to a constant
const selectActiveTasks = (state) => state.tasks.filter(t => !t.completed);

function TaskList() {
  const activeTasks = useTaskStore(selectActiveTasks);
  // The selector function is stable
  return activeTasks.map(task => <div key={task.id}>{task.text}</div>);
}
```

**Why It Happens**:
- Not understanding selector re-evaluation
- Prioritizing convenience over performance
- Not knowing about `useShallow` or memoization

**How to Fix**:
- Use `useShallow` for object selectors
- Use `reselect` or `useMemo` for expensive computations
- Extract selectors to constants to avoid inline recreation
- Profile your application to find expensive selectors

---

## Anti-Pattern 5: Async Anti-Patterns

**The Problem**: Improper handling of asynchronous operations.

```typescript
// ❌ ANTI-PATTERN: No loading/error states
const useBadStore = create((set) => ({
  data: [],
  fetchData: async () => {
    const response = await fetch('/api/data');
    const data = await response.json();
    set({ data }); // No loading or error handling
  },
}));

// ❌ ANTI-PATTERN: Race conditions (no cancellation)
const useRaceStore = create((set) => ({
  user: null,
  fetchUser: async (id) => {
    const response = await fetch(`/api/users/${id}`);
    const user = await response.json();
    set({ user }); // If id changes, stale response may overwrite
  },
}));

// ❌ ANTI-PATTERN: Swallowed errors
const useBadStore = create((set) => ({
  data: [],
  fetchData: async () => {
    try {
      const response = await fetch('/api/data');
      const data = await response.json();
      set({ data });
    } catch {
      // Error silently swallowed!
    }
  },
}));

// ✅ CORRECT: Proper loading and error states
const useGoodStore = create((set) => ({
  data: [],
  loading: false,
  error: null,
  fetchData: async () => {
    set({ loading: true, error: null });
    try {
      const response = await fetch('/api/data');
      if (!response.ok) {
        throw new Error(`HTTP ${response.status}`);
      }
      const data = await response.json();
      set({ data, loading: false });
    } catch (error) {
      set({ error: error.message, loading: false });
    }
  },
}));

// ✅ CORRECT: Race condition prevention
const useGoodStore = create((set) => ({
  user: null,
  requestId: null,
  fetchUser: async (id) => {
    const requestId = `req-${Date.now()}`;
    set({ requestId, loading: true, error: null });
    
    try {
      const response = await fetch(`/api/users/${id}`);
      const user = await response.json();
      
      // Only update if this is still the latest request
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
  },
}));

// ✅ CORRECT: Using AbortController for cancellation
const useCancelStore = create((set, get) => ({
  data: [],
  controller: null,
  fetchData: async (url) => {
    // Cancel previous request
    const prevController = get().controller;
    if (prevController) {
      prevController.abort();
    }
    
    const controller = new AbortController();
    set({ controller, loading: true, error: null });
    
    try {
      const response = await fetch(url, { signal: controller.signal });
      const data = await response.json();
      set({ data, loading: false, controller: null });
    } catch (error) {
      if (error.name === 'AbortError') {
        console.log('Request cancelled');
      } else {
        set({ error: error.message, loading: false });
      }
      set({ controller: null });
    }
  },
}));
```

**Why It Happens**:
- Forgetting error handling
- Not considering race conditions
- Assuming network requests always succeed

**How to Fix**:
- Always handle loading, error, and success states
- Track request IDs or use AbortController for cancellation
- Use try/catch and update error state
- Consider retry logic for flaky networks

---

## Anti-Pattern 6: Monolithic Stores

**The Problem**: Creating one giant store that manages everything.

```typescript
// ❌ ANTI-PATTERN: Monolithic store
const useMonolithicStore = create((set) => ({
  // Users
  users: [],
  currentUser: null,
  userLoading: false,
  userError: null,
  
  // Tasks
  tasks: [],
  taskLoading: false,
  taskError: null,
  
  // UI
  theme: 'light',
  sidebarOpen: true,
  modalOpen: false,
  
  // Notifications
  notifications: [],
  unreadCount: 0,
  
  // Analytics
  analyticsData: [],
  
  // 50+ more fields...
  
  // 100+ actions...
}));

// ✅ CORRECT: Split into focused stores
// src/domains/user/store/userStore.ts
export const useUserStore = create((set) => ({
  users: [],
  currentUser: null,
  loading: false,
  error: null,
  // User-specific actions
}));

// src/domains/task/store/taskStore.ts
export const useTaskStore = create((set) => ({
  tasks: [],
  loading: false,
  error: null,
  // Task-specific actions
}));

// src/domains/ui/store/uiStore.ts
export const useUIStore = create((set) => ({
  theme: 'light',
  sidebarOpen: true,
  modalOpen: false,
  // UI-specific actions
}));

// src/domains/notification/store/notificationStore.ts
export const useNotificationStore = create((set) => ({
  notifications: [],
  unreadCount: 0,
  // Notification-specific actions
}));
```

**Why It Happens**:
- Starting small and growing without refactoring
- Convenience (everything in one place)
- Not seeing the need to split until too late

**How to Fix**:
- Split by domain (user, tasks, UI, notifications)
- Split by update frequency (hot vs cold state)
- Split by render impact (frequently vs rarely used)
- Use the slice pattern for related state

---

## Anti-Pattern 7: Not Using Persist Correctly

**The Problem**: Misusing the persist middleware.

```typescript
// ❌ ANTI-PATTERN: Persisting everything (including transient state)
const useBadStore = create(
  persist(
    (set) => ({
      data: [],
      isLoading: false, // ❌ Shouldn't be persisted
      error: null, // ❌ Shouldn't be persisted
      selectedItem: null, // ✅ Should be persisted
      theme: 'dark', // ✅ Should be persisted
    }),
    { name: 'storage' }
  )
);

// ❌ ANTI-PATTERN: Persisting non-serializable data
const useBadStore = create(
  persist(
    (set) => ({
      tasks: [],
      addTask: (task) => set((state) => ({
        tasks: [...state.tasks, { ...task, createdAt: new Date() }]
      })), // Date is not serializable!
    }),
    { name: 'storage' }
  )
);

// ❌ ANTI-PATTERN: No versioning for schema changes
const useBadStore = create(
  persist(
    (set) => ({
      // Changed from `taskList` to `tasks` - breaks existing users!
      tasks: [],
    }),
    { name: 'storage' }
  )
);

// ✅ CORRECT: Partialize to persist only what's needed
const useGoodStore = create(
  persist(
    (set) => ({
      tasks: {},
      taskIds: [],
      isLoading: false,
      error: null,
      selectedTaskId: null,
      theme: 'dark',
      preferences: { language: 'en' },
    }),
    {
      name: 'storage',
      partialize: (state) => ({
        tasks: state.tasks,
        taskIds: state.taskIds,
        selectedTaskId: state.selectedTaskId,
        theme: state.theme,
        preferences: state.preferences,
        // Don't persist: isLoading, error
      }),
    }
  )
);

// ✅ CORRECT: Handle non-serializable data
const useGoodStore = create(
  persist(
    (set) => ({
      tasks: [],
      addTask: (task) => set((state) => ({
        tasks: [...state.tasks, { 
          ...task, 
          createdAt: task.createdAt instanceof Date 
            ? task.createdAt.toISOString() 
            : new Date().toISOString() 
        }]
      })),
    }),
    {
      name: 'storage',
      serialize: (state) => JSON.stringify(state),
      deserialize: (str) => {
        const state = JSON.parse(str);
        // Convert date strings back to Date objects
        if (state.tasks) {
          state.tasks = state.tasks.map(task => ({
            ...task,
            createdAt: new Date(task.createdAt),
          }));
        }
        return state;
      },
    }
  )
);

// ✅ CORRECT: Version and migrate
const useGoodStore = create(
  persist(
    (set) => ({
      tasks: [],
      taskIds: [],
    }),
    {
      name: 'storage',
      version: 1,
      migrate: (persistedState, version) => {
        if (version === 0) {
          // Old version had `taskList` instead of `tasks`
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

**Why It Happens**:
- Not understanding what should be persisted
- Not handling schema changes
- Overlooking serialization issues

**How to Fix**:
- Use `partialize` to select only persistent state
- Version your storage and provide migrations
- Convert non-serializable data (Date, Map, Set, etc.)
- Only persist what users expect to survive page reloads

---

## Anti-Pattern 8: Not Cleaning Up Subscriptions

**The Problem**: Creating subscriptions without cleaning them up.

```typescript
// ❌ ANTI-PATTERN: Subscription leak in component
function TaskListener() {
  useEffect(() => {
    const unsubscribe = useTaskStore.subscribe((state) => {
      console.log('Tasks changed:', state.tasks);
    });
    // ❌ Missing cleanup!
  }, []);
  
  return null;
}

// ❌ ANTI-PATTERN: Global subscription never cleaned up
const unsubscribe = useTaskStore.subscribe(handleChange);
// ❌ unsubscribe never called

// ❌ ANTI-PATTERN: Multiple subscriptions accumulating
function addListeners() {
  useTaskStore.subscribe(handleTaskChange);
  useUserStore.subscribe(handleUserChange);
  useUIStore.subscribe(handleUIChange);
  // ❌ No cleanup, subscriptions accumulate on each call
}

// ✅ CORRECT: Always clean up subscriptions
function TaskListener() {
  useEffect(() => {
    const unsubscribe = useTaskStore.subscribe((state) => {
      console.log('Tasks changed:', state.tasks);
    });
    
    return () => {
      unsubscribe(); // ✅ Clean up!
    };
  }, []);
  
  return null;
}

// ✅ CORRECT: Single manager for subscriptions
class SubscriptionManager {
  private subscriptions: (() => void)[] = [];
  
  add(subscription: () => void) {
    this.subscriptions.push(subscription);
    return subscription;
  }
  
  cleanup() {
    for (const unsub of this.subscriptions) {
      unsub();
    }
    this.subscriptions = [];
  }
}

// Usage
const subscriptions = new SubscriptionManager();
subscriptions.add(useTaskStore.subscribe(handleTaskChange));
subscriptions.add(useUserStore.subscribe(handleUserChange));
// Later...
subscriptions.cleanup();

// ✅ CORRECT: Track subscriptions in store
const useStoreWithCleanup = create((set, get) => ({
  subscriptions: new Set<() => void>(),
  registerSubscription: (unsub: () => void) => {
    get().subscriptions.add(unsub);
    return () => {
      unsub();
      get().subscriptions.delete(unsub);
    };
  },
  cleanup: () => {
    for (const unsub of get().subscriptions) {
      unsub();
    }
    get().subscriptions.clear();
  },
}));
```

**Why It Happens**:
- Forgetting to clean up
- Not realizing subscriptions need cleanup
- Complex component lifecycles

**How to Fix**:
- Always return a cleanup function in `useEffect`
- Use a subscription manager for complex scenarios
- Consider using `subscribeWithSelector` middleware
- Use the store's `destroy` method when available

---

## Anti-Pattern 9: Sharing State Between Different Domains Improperly

**The Problem**: Tight coupling between stores.

```typescript
// ❌ ANTI-PATTERN: Direct import from another domain
// src/domains/task/store/taskStore.ts
import { useAuthStore } from '../../auth/store/authStore';

export const useTaskStore = create((set, get) => ({
  tasks: [],
  addTask: (task) => {
    const user = useAuthStore.getState().user; // ❌ Tight coupling!
    // ...
  },
}));

// ❌ ANTI-PATTERN: Duplicating state across stores
const useTaskStore = create((set) => ({
  tasks: [],
  currentUser: null, // ❌ Duplicated from auth store
}));

// ❌ ANTI-PATTERN: Multiple stores modifying the same data
// Task store modifies user state, Auth store modifies user state
// Leads to inconsistencies

// ✅ CORRECT: Use selectors or event bus for cross-domain communication
// src/domains/task/store/taskStore.ts
export const createTaskStore = (deps: { getUserId: () => string | undefined }) => 
  create((set, get) => ({
    tasks: [],
    addTask: (task) => {
      const userId = deps.getUserId(); // ✅ Injected dependency
      // ...
    },
  }));

// ✅ CORRECT: Use event bus for loose coupling
import { eventBus } from '../../../shared/events/eventBus';

export const useTaskStore = create((set) => ({
  tasks: [],
  addTask: async (task) => {
    // ... add task
    eventBus.publish('task:created', task); // ✅ Communicate via events
  },
}));

// ✅ CORRECT: Use shared selectors
// src/shared/selectors/userSelectors.ts
export const selectCurrentUserId = (state) => state.user?.id;

// In task store
const userId = useAuthStore(selectCurrentUserId);
```

**Why It Happens**:
- Not thinking about domain boundaries
- Taking shortcuts for convenience
- Lack of architectural guidance

**How to Fix**:
- Enforce domain boundaries
- Use dependency injection
- Use event bus for cross-domain communication
- Create shared selectors for commonly accessed state

---

## Anti-Pattern 10: Not Using TypeScript Correctly

**The Problem**: Weak or incorrect TypeScript usage.

```typescript
// ❌ ANTI-PATTERN: No types at all
const useNoTypes = create((set) => ({
  // No types = no safety
  data: [],
  addData: (item) => set((state) => ({ data: [...state.data, item] })),
}));

// ❌ ANTI-PATTERN: Using `any` everywhere
const useAnyStore = create<any>((set) => ({
  data: [],
  addData: (item: any) => set((state: any) => ({ data: [...state.data, item] })),
}));

// ❌ ANTI-PATTERN: Incorrect types (missing fields)
interface TaskStore {
  tasks: Task[];
  addTask: (task: Task) => void;
  // Missing: deleteTask, toggleTask
}

// ❌ ANTI-PATTERN: Overly complex types
interface ComplexStore {
  data: Record<string, { 
    nested: Array<{ 
      deep: Map<string, Set<number>> 
    }> 
  }>;
}

// ✅ CORRECT: Properly typed store
interface Task {
  id: string;
  title: string;
  completed: boolean;
}

interface TaskStore {
  tasks: Record<string, Task>;
  taskIds: string[];
  addTask: (task: Omit<Task, 'id'>) => void;
  toggleTask: (id: string) => void;
  deleteTask: (id: string) => void;
}

const useTaskStore = create<TaskStore>()(
  immer((set) => ({
    tasks: {},
    taskIds: [],
    addTask: (taskData) => {
      set((state) => {
        const id = `task-${Date.now()}`;
        state.tasks[id] = { ...taskData, id };
        state.taskIds.push(id);
      });
    },
    toggleTask: (id) => {
      set((state) => {
        const task = state.tasks[id];
        if (task) {
          task.completed = !task.completed;
        }
      });
    },
    deleteTask: (id) => {
      set((state) => {
        delete state.tasks[id];
        state.taskIds = state.taskIds.filter(tid => tid !== id);
      });
    },
  }))
);

// ✅ CORRECT: Use type inference for selectors
const selectTaskCount = (state: TaskStore) => state.taskIds.length;
const taskCount = useTaskStore(selectTaskCount);
```

**Why It Happens**:
- Rushing to get things working
- Not understanding TypeScript benefits
- Legacy code migration

**How to Fix**:
- Define clear interfaces for all stores
- Use TypeScript strict mode
- Use `create<T>()` for type safety
- Use type inference for selectors

---

## Anti-Pattern 11: Over-Optimizing Prematurely

**The Problem**: Adding complexity before it's needed.

```typescript
// ❌ ANTI-PATTERN: Premature optimization
function TaskList() {
  // Memoizing EVERYTHING with React.memo
  return tasks.map(task => <MemoizedTaskItem key={task.id} task={task} />);
}

const MemoizedTaskItem = React.memo(({ task }) => {
  // Even for 10 tasks where no re-renders happen
  return <div>{task.title}</div>;
});

// ❌ ANTI-PATTERN: Complex selectors for simple data
const selectTaskTitle = createSelector(
  [(state) => state.tasks, (state, id) => id],
  (tasks, id) => tasks[id]?.title
);

function TaskTitle({ id }) {
  const title = useTaskStore(selectTaskTitle);
  // For a simple field lookup, this is overkill
  return <div>{title}</div>;
}

// ✅ CORRECT: Simple first, optimize when needed
function TaskList() {
  // Start simple
  return tasks.map(task => <TaskItem key={task.id} task={task} />);
}

function TaskItem({ task }) {
  return <div>{task.title}</div>;
}

// Only optimize when profiling shows it's needed
// Use React.memo when you have hundreds of items updating individually
```

**Why It Happens**:
- Over-engineering from the start
- Following patterns without understanding why
- Premature performance anxiety

**How to Fix**:
- Start simple
- Profile before optimizing
- Add optimization only when you can measure the benefit

---

## Anti-Pattern 12: Mixing Server and Client State

**The Problem**: Not distinguishing between server state and client state.

```typescript
// ❌ ANTI-PATTERN: Storing server state in Zustand
function UserProfile() {
  const user = useTaskStore((state) => state.user); // Server state in Zustand
  
  // But user data should be cached by React Query, SWR, etc.
  // Zustand should manage client-only state
}

// ❌ ANTI-PATTERN: Managing server cache in Zustand
const useServerStore = create((set) => ({
  users: [], // 1000 users from server
  posts: [], // 5000 posts from server
  // Zustand wasn't designed for this!
}));

// ✅ CORRECT: Zustand for client state, React Query for server state
// src/domains/task/store/taskStore.ts (client state)
export const useTaskStore = create((set) => ({
  selectedTaskId: null,
  filter: 'all',
  searchQuery: '',
  // Client-only state
}));

// hooks/useTasks.ts (server state with React Query)
import { useQuery } from '@tanstack/react-query';

export function useTasks() {
  return useQuery({
    queryKey: ['tasks'],
    queryFn: () => fetch('/api/tasks').then(res => res.json()),
  });
}

// In component
function TaskList() {
  const { data: tasks, isLoading } = useTasks();
  const selectedTaskId = useTaskStore((state) => state.selectedTaskId);
  const filter = useTaskStore((state) => state.filter);
  // React Query manages cache, Zustand manages UI state
}
```

**Why It Happens**:
- Using Zustand for everything
- Not knowing about specialized server-state libraries

**How to Fix**:
- Use Zustand for client-only state
- Use React Query, SWR, or Apollo for server state
- Keep Zustand stores focused on UI and local state

---

## Detection Tools and Techniques

### 1. ESLint Plugins

```bash
npm install -D eslint-plugin-zustand
```

```javascript
// .eslintrc.js
module.exports = {
  plugins: ['zustand'],
  rules: {
    'zustand/no-imports-from-store': 'error',
    'zustand/use-shallow': 'warn',
    'zustand/no-mutating-state': 'error',
  },
};
```

### 2. Custom Lint Rules

```typescript
// tools/eslint-rules/no-over-subscription.ts
export default {
  meta: { type: 'suggestion' },
  create(context) {
    return {
      CallExpression(node) {
        if (node.callee.name === 'useStore' && node.arguments.length === 0) {
          context.report({
            node,
            message: 'Avoid subscribing to the entire store. Use selectors.',
          });
        }
      },
    };
  },
};
```

### 3. Runtime Detection

```typescript
// tools/detect-anti-patterns.ts
export function detectAntiPatterns(store: any) {
  // Check for large stores
  const stateSize = new Blob([JSON.stringify(store.getState())]).size;
  if (stateSize > 500 * 1024) {
    console.warn('⚠️ Store is large (>500KB). Consider splitting.');
  }

  // Check for subscription count
  const listenerCount = store._listeners?.size || 0;
  if (listenerCount > 100) {
    console.warn('⚠️ Many subscriptions. Check for over-subscription.');
  }
}
```

---

## Anti-Pattern Quick Reference

| Anti-Pattern | Symptom | Fix |
|--------------|---------|-----|
| Over-Subscription | Too many re-renders | Use selectors |
| Direct Mutation | State not updating | Use immutable updates or Immer |
| Provider Hoarding | Unnecessary Provider wrappers | Use stores directly |
| Selector Abuse | Slow rendering | Use `useShallow`, memoize, or `reselect` |
| Async Anti-Patterns | Race conditions, no error handling | Track request IDs, handle errors |
| Monolithic Stores | Huge store with 50+ fields | Split by domain |
| Incorrect Persist | Broken schema, data loss | Use `partialize`, version, migrate |
| No Cleanup | Memory leaks | Clean up subscriptions |
| Improper Sharing | Tight coupling | Use events or DI |
| Weak Types | TypeScript errors | Define proper interfaces |
| Premature Optimization | Over-engineered code | Start simple, profile |
| Mixing Server/Client | Bloated stores | Use React Query for server state |

---

## Key Takeaways

1. **Over-subscription** is the most common and impactful anti-pattern
2. **Direct mutation** causes subtle bugs and should never be done
3. **Zustand doesn't need Providers**—they're often unnecessary
4. **Selectors** should be simple; use `useShallow` and `reselect` for complex ones
5. **Async actions** need proper loading, error, and cancellation handling
6. **Split stores** by domain, frequency, and render impact
7. **Persist** only what's needed; version your storage
8. **Clean up** all subscriptions to prevent memory leaks
9. **Cross-domain communication** should use events or DI
10. **TypeScript** makes Zustand safer and more maintainable

---

## What's Next

You've now completed the entire Zustand tutorial series! From fundamentals to enterprise best practices, you have the knowledge to build production-ready applications with Zustand. The Capstone Project will bring everything together.
