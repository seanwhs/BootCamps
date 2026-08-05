# Zustand Mastery: Quiz & Test Bank

## Complete Assessment Package with Answer Keys

---

# Section 1: Multiple Choice Questions

## Part A: Fundamentals (Questions 1-20)

### 1. What is Zustand?
- A) A state management library for React
- B) A CSS framework
- C) A build tool
- D) A testing library

**Answer: A**

---

### 2. Which function is used to create a Zustand store?
- A) `useState`
- B) `createStore`
- C) `create`
- D) `useReducer`

**Answer: C**

---

### 3. How does Zustand prevent unnecessary re-renders?
- A) By using a Provider
- B) By using selectors
- C) By using React.memo automatically
- D) By caching all state

**Answer: B**

---

### 4. Which of the following is NOT required when using Zustand?
- A) Importing the library
- B) A Provider wrapper
- C) Selectors
- D) Actions

**Answer: B**

---

### 5. What is the purpose of the `set` function in Zustand?
- A) To read state
- B) To update state
- C) To delete state
- D) To log state

**Answer: B**

---

### 6. Which syntax is recommended for updates that depend on current state?
- A) Object update
- B) Functional update
- C) Direct mutation
- D) Class-based update

**Answer: B**

---

### 7. What is the purpose of `useShallow` in Zustand?
- A) To shallow copy state
- B) To prevent unnecessary re-renders with object selectors
- C) To shallow merge state updates
- D) To shallow compare component props

**Answer: B**

---

### 8. Which of the following is a valid selector?
- A) `(state) => state`
- B) `(state) => state.count`
- C) `(state, props) => state[props.id]`
- D) All of the above

**Answer: D**

---

### 9. What does the `persist` middleware do?
- A) Persists state to the server
- B) Persists state to localStorage
- C) Persists state to the URL
- D) Persists state to cookies

**Answer: B**

---

### 10. Which middleware connects Zustand to Redux DevTools?
- A) `redux`
- B) `devtools`
- C) `debugger`
- D) `logger`

**Answer: B**

---

### 11. What is the purpose of the `immer` middleware?
- A) To add TypeScript support
- B) To enable mutable updates
- C) To add logging
- D) To add persistence

**Answer: B**

---

### 12. How do you create a vanilla store (without React)?
- A) `create`
- B) `createStore` from `zustand/vanilla`
- C) `createVanilla`
- D) `useStore`

**Answer: B**

---

### 13. What is a "slice" in Zustand?
- A) A small piece of UI
- B) A modular piece of a store
- C) A type of middleware
- D) A testing utility

**Answer: B**

---

### 14. Which of the following is an anti-pattern in Zustand?
- A) Using selectors
- B) Directly mutating state
- C) Using middleware
- D) Splitting stores

**Answer: B**

---

### 15. What is the purpose of `partialize` in the `persist` middleware?
- A) To partially update state
- B) To select which parts of state to persist
- C) To partially hydrate state
- D) To partially merge state

**Answer: B**

---

### 16. How do you handle async actions in Zustand?
- A) Use redux-thunk
- B) Use async/await in actions
- C) Use sagas
- D) Use redux-promise

**Answer: B**

---

### 17. What is the recommended way to reset state in Zustand?
- A) `set(initialState)`
- B) `reset()`
- C) `reload()`
- D) `clear()`

**Answer: A**

---

### 18. Which hook is used to access a Zustand store in React?
- A) `useZustand`
- B) `useStore`
- C) `useState`
- D) `useSelector`

**Answer: B**

---

### 19. What does the `subscribe` function do?
- A) Subscribes to state changes
- B) Subscribes to DOM events
- C) Subscribes to network requests
- D) Subscribes to React events

**Answer: A**

---

### 20. What is the bundle size of Zustand?
- A) ~1KB
- B) ~10KB
- C) ~30KB
- D) ~100KB

**Answer: A**

---

## Part B: Advanced Concepts (Questions 21-40)

### 21. How do you name actions in Redux DevTools?
- A) `set({ count: 1 }, 'increment')`
- B) `set({ count: 1 }, false, 'increment')`
- C) `set({ count: 1 }, 'increment')`
- D) `set('increment', { count: 1 })`

**Answer: B**

---

### 22. Which pattern is used to compose multiple Zustand stores?
- A) Provider pattern
- B) Slice pattern
- C) Factory pattern
- D) Singleton pattern

**Answer: B**

---

### 23. How do you prevent race conditions in async Zustand actions?
- A) Use async/await
- B) Use request IDs
- C) Use try/catch
- D) Use loading states

**Answer: B**

---

### 24. What is the purpose of `useOptimistic` in React 19 with Zustand?
- A) To optimize performance
- B) To implement optimistic UI updates
- C) To optimize bundle size
- D) To optimize server rendering

**Answer: B**

---

### 25. How do you handle hydration mismatches in Next.js with Zustand?
- A) Use `useHydrated` guard
- B) Disable SSR
- C) Use `useEffect` only
- D) Use `useState` instead

**Answer: A**

---

### 26. Which of the following is a valid way to split stores?
- A) By domain
- B) By update frequency
- C) By render impact
- D) All of the above

**Answer: D**

---

### 27. What is the purpose of `useActionState` in React 19?
- A) To manage form submission states
- B) To manage action creators
- C) To manage state actions
- D) To manage async actions

**Answer: A**

---

### 28. Which storage adapter is recommended for React Native?
- A) localStorage
- B) AsyncStorage
- C) sessionStorage
- D) cookies

**Answer: B**

---

### 29. How do you implement role-based access control with Zustand?
- A) Use middleware
- B) Use `hasRole` helper in store
- C) Use React Router
- D) Use Context API

**Answer: B**

---

### 30. What is the purpose of `version` in the `persist` middleware?
- A) To version the store
- B) To handle schema migrations
- C) To version the middleware
- D) To version the app

**Answer: B**

---

### 31. How do you cancel a request in Zustand?
- A) Use `AbortController`
- B) Use `cancel()`
- C) Use `abort()`
- D) Use `stop()`

**Answer: A**

---

### 32. What is the execution order of middleware?
- A) Outer to inner
- B) Inner to outer
- C) Arbitrary
- D) Alphabetical

**Answer: B (innermost executes first)**

---

### 33. What is the purpose of `subscribeWithSelector` middleware?
- A) To add selectors
- B) To enable selective subscriptions outside React
- C) To add devtools
- D) To add persistence

**Answer: B**

---

### 34. How do you implement optimistic updates in Zustand?
- A) Update state first, sync later
- B) Sync first, update later
- C) Use `useOptimistic`
- D) Use `useTransition`

**Answer: A**

---

### 35. Which of the following is NOT a built-in Zustand middleware?
- A) `devtools`
- B) `persist`
- C) `immer`
- D) `logger`

**Answer: D** (logger is custom, not built-in)

---

### 36. What is the purpose of `combine` middleware?
- A) Combine multiple stores
- B) Combine state and actions
- C) Combine middleware
- D) Combine selectors

**Answer: B**

---

### 37. How do you test Zustand stores?
- A) Use Jest with `getState()` and `setState()`
- B) Use React Testing Library
- C) Use Enzyme
- D) Use Cypress

**Answer: A**

---

### 38. What is the Strangler Fig pattern used for?
- A) Performance optimization
- B) Gradual migration
- C) State persistence
- D) Error handling

**Answer: B**

---

### 39. Which of the following is an anti-pattern?
- A) Using selectors
- B) Storing derived state
- C) Using middleware
- D) Splitting stores

**Answer: B**

---

### 40. What is the purpose of `onRehydrateStorage`?
- A) To log hydration events
- B) To migrate state
- C) To persist state
- D) To clear state

**Answer: A**

---

# Section 2: Fill in the Blanks

### 41. The function used to create a Zustand store is ______.

**Answer: `create`**

---

### 42. To extract specific pieces of state, you use a ______.

**Answer: selector**

---

### 43. The ______ middleware connects Zustand to Redux DevTools.

**Answer: `devtools`**

---

### 44. To persist state to localStorage, use the ______ middleware.

**Answer: `persist`**

---

### 45. When updating state that depends on current state, use a ______ update.

**Answer: functional**

---

### 46. The ______ middleware enables mutable updates while maintaining immutability.

**Answer: `immer`**

---

### 47. A ______ is a modular piece of a store used to split large stores.

**Answer: slice**

---

### 48. The ______ middleware enables selective subscriptions outside React.

**Answer: `subscribeWithSelector`**

---

### 49. To prevent hydration mismatches in Next.js, use a ______ guard.

**Answer: `useHydrated`**

---

### 50. The ______ pattern is used for gradual migration from one state management solution to another.

**Answer: Strangler Fig**

---

# Section 3: Code Writing Questions

### 51. Create a counter store with increment, decrement, and reset actions.

```typescript
// Write your code here








```

**Answer:**
```typescript
import { create } from 'zustand';

const useCounterStore = create((set) => ({
  count: 0,
  increment: () => set((state) => ({ count: state.count + 1 })),
  decrement: () => set((state) => ({ count: state.count - 1 })),
  reset: () => set({ count: 0 }),
}));
```

---

### 52. Create a store with persistence that saves user preferences.

```typescript
// Write your code here








```

**Answer:**
```typescript
import { create } from 'zustand';
import { persist } from 'zustand/middleware';

const usePreferencesStore = create(
  persist(
    (set) => ({
      theme: 'light',
      language: 'en',
      setTheme: (theme) => set({ theme }),
      setLanguage: (language) => set({ language }),
    }),
    { name: 'preferences-storage' }
  )
);
```

---

### 53. Write a selector that returns filtered tasks using `useShallow`.

```typescript
// Write your code here








```

**Answer:**
```typescript
import { useShallow } from 'zustand/react/shallow';

function TaskStats() {
  const { tasks, loading } = useTaskStore(
    useShallow((state) => ({
      tasks: state.tasks,
      loading: state.loading,
    }))
  );
  
  return <div>{tasks.length} {loading && 'Loading...'}</div>;
}
```

---

### 54. Create a slice pattern for user and task stores.

```typescript
// Write your code here








```

**Answer:**
```typescript
const userSlice = (set) => ({
  user: null,
  setUser: (user) => set({ user }),
});

const taskSlice = (set) => ({
  tasks: [],
  addTask: (task) => set((state) => ({ tasks: [...state.tasks, task] })),
  removeTask: (id) => set((state) => ({ tasks: state.tasks.filter(t => t.id !== id) })),
});

const useStore = create((set) => ({
  ...userSlice(set),
  ...taskSlice(set),
}));
```

---

### 55. Write an async action that fetches data with error handling.

```typescript
// Write your code here








```

**Answer:**
```typescript
fetchData: async () => {
  set({ loading: true, error: null });
  try {
    const response = await fetch('/api/data');
    if (!response.ok) throw new Error(`HTTP ${response.status}`);
    const data = await response.json();
    set({ data, loading: false });
  } catch (error) {
    set({ error: error.message, loading: false });
  }
}
```

---

### 56. Implement request deduplication in an async action.

```typescript
// Write your code here








```

**Answer:**
```typescript
const pendingRequests = new Map();

fetchData: async (id) => {
  const key = `data-${id}`;
  if (pendingRequests.has(key)) {
    return pendingRequests.get(key);
  }
  
  const promise = (async () => {
    set({ loading: true });
    const response = await fetch(`/api/data/${id}`);
    const data = await response.json();
    set({ data, loading: false });
    return data;
  })();
  
  pendingRequests.set(key, promise);
  try {
    return await promise;
  } finally {
    pendingRequests.delete(key);
  }
}
```

---

### 57. Create a custom logging middleware.

```typescript
// Write your code here








```

**Answer:**
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

---

### 58. Write a unit test for a counter store.

```typescript
// Write your code here








```

**Answer:**
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
    reset();
    expect(useCounterStore.getState().count).toBe(0);
  });
});
```

---

### 59. Create a normalized state structure for tasks.

```typescript
// Write your code here








```

**Answer:**
```typescript
interface NormalizedState {
  tasks: Record<string, Task>;
  taskIds: string[];
  users: Record<string, User>;
  userIds: string[];
  userTaskIds: Record<string, string[]>;
}

// Actions
addTask: (task) => {
  set((state) => ({
    tasks: { ...state.tasks, [task.id]: task },
    taskIds: [...state.taskIds, task.id],
    userTaskIds: {
      ...state.userTaskIds,
      [task.assigneeId]: [
        ...(state.userTaskIds[task.assigneeId] || []),
        task.id,
      ],
    },
  }));
}
```

---

### 60. Implement optimistic update with rollback.

```typescript
// Write your code here








```

**Answer:**
```typescript
addItem: async (item) => {
  const tempId = `temp-${Date.now()}`;
  set((state) => ({
    items: [...state.items, { ...item, id: tempId, optimistic: true }],
  }));
  
  try {
    const saved = await api.save(item);
    set((state) => ({
      items: state.items.map(i =>
        i.id === tempId ? { ...saved, optimistic: false } : i
      ),
    }));
  } catch (error) {
    set((state) => ({
      items: state.items.filter(i => i.id !== tempId),
      error: error.message,
    }));
  }
}
```

---

# Section 4: True/False Questions

### 61. Zustand requires a Provider wrapper around the app.

**Answer: False**

---

### 62. Selectors in Zustand prevent unnecessary re-renders.

**Answer: True**

---

### 63. Directly mutating state is acceptable in Zustand.

**Answer: False**

---

### 64. The `persist` middleware only works with localStorage.

**Answer: False** (can use any storage adapter)

---

### 65. Zustand can be used outside of React.

**Answer: True**

---

### 66. The `immer` middleware is built into Zustand.

**Answer: True** (available as an import)

---

### 67. Race conditions cannot occur in Zustand.

**Answer: False**

---

### 68. The `devtools` middleware is only available in development mode.

**Answer: False** (can be enabled/disabled)

---

### 69. Zustand supports TypeScript out of the box.

**Answer: True**

---

### 70. You can create multiple stores in a Zustand application.

**Answer: True**

---

# Section 5: Short Answer Questions

### 71. Explain the difference between Zustand and Context API.

**Answer:** Zustand provides fine-grained subscriptions, meaning only components that depend on specific state re-render. Context API causes all consumers to re-render when any state changes. Zustand also doesn't require a Provider wrapper, making it simpler and more performant for complex state.

---

### 72. What is the slice pattern and why is it useful?

**Answer:** The slice pattern breaks a large store into smaller, modular pieces called slices. Each slice is a self-contained module with its own state and actions. This improves maintainability, reduces merge conflicts in teams, and makes the codebase more organized and scalable.

---

### 73. How do you prevent race conditions in Zustand?

**Answer:** Race conditions can be prevented by:
1. Using request IDs to track the latest request
2. Using AbortController to cancel stale requests
3. Implementing request deduplication to prevent duplicate requests
4. Using debouncing for user input

---

### 74. What is the Strangler Fig pattern and how is it used for migration?

**Answer:** The Strangler Fig pattern is a migration strategy where new code is incrementally introduced alongside existing code. Feature flags are used to route some requests to the new implementation while others continue using the old. Over time, more traffic is routed to the new implementation until the old code can be removed completely.

---

### 75. Explain optimistic updates and how to implement them in Zustand.

**Answer:** Optimistic updates update the UI immediately while the server operation runs in the background. To implement in Zustand:
1. Update the state optimistically with a temporary ID
2. Perform the async operation
3. If successful, replace the optimistic data with real data
4. If it fails, rollback (remove the optimistic data)

---

# Section 6: Comprehensive Test

## Part A: Multiple Choice (20 Questions)

### 76. Which of the following is NOT a feature of Zustand?
- A) Fine-grained subscriptions
- B) No Provider required
- C) Built-in server-side rendering
- D) TypeScript support

**Answer: C**

---

### 77. The `useShallow` hook is used to...
- A) Shallow copy state
- B) Prevent re-renders with object selectors
- C) Shallow compare component props
- D) Shallow merge state

**Answer: B**

---

### 78. Which function is used to update state in Zustand?
- A) `update`
- B) `set`
- C) `change`
- D) `modify`

**Answer: B**

---

### 79. What is the purpose of `partialize` in the `persist` middleware?
- A) To partially update state
- B) To select which parts of state to persist
- C) To partially hydrate state
- D) To partially merge state

**Answer: B**

---

### 80. Which middleware enables mutable updates in Zustand?
- A) `devtools`
- B) `persist`
- C) `immer`
- D) `combine`

**Answer: C**

---

### 81. In React 19, which hook is used with Zustand for optimistic UI updates?
- A) `useTransition`
- B) `useOptimistic`
- C) `useActionState`
- D) `useDeferredValue`

**Answer: B**

---

### 82. How do you create a vanilla store?
- A) `create`
- B) `createStore` from `zustand/vanilla`
- C) `createVanilla`
- D) `useStore`

**Answer: B**

---

### 83. What is the recommended way to split large Zustand stores?
- A) By domain
- B) By update frequency
- C) By render impact
- D) All of the above

**Answer: D**

---

### 84. Which storage adapter is recommended for React Native?
- A) localStorage
- B) AsyncStorage
- C) sessionStorage
- D) cookies

**Answer: B**

---

### 85. What is the purpose of `version` in the `persist` middleware?
- A) To version the store
- B) To handle schema migrations
- C) To version the middleware
- D) To version the app

**Answer: B**

---

### 86. How do you cancel a request in Zustand?
- A) Use `AbortController`
- B) Use `cancel()`
- C) Use `abort()`
- D) Use `stop()`

**Answer: A**

---

### 87. What is the execution order of middleware?
- A) Outer to inner
- B) Inner to outer
- C) Arbitrary
- D) Alphabetical

**Answer: B (innermost executes first)**

---

### 88. Which of the following is an anti-pattern?
- A) Using selectors
- B) Storing derived state
- C) Using middleware
- D) Splitting stores

**Answer: B**

---

### 89. How do you test Zustand stores?
- A) Use Jest with `getState()` and `setState()`
- B) Use React Testing Library
- C) Use Enzyme
- D) Use Cypress

**Answer: A**

---

### 90. What is the Strangler Fig pattern used for?
- A) Performance optimization
- B) Gradual migration
- C) State persistence
- D) Error handling

**Answer: B**

---

### 91. Which of the following is a valid selector?
- A) `(state) => state`
- B) `(state) => state.count`
- C) `(state, props) => state[props.id]`
- D) All of the above

**Answer: D**

---

### 92. What does the `subscribe` function do?
- A) Subscribes to state changes
- B) Subscribes to DOM events
- C) Subscribes to network requests
- D) Subscribes to React events

**Answer: A**

---

### 93. What is the bundle size of Zustand?
- A) ~1KB
- B) ~10KB
- C) ~30KB
- D) ~100KB

**Answer: A**

---

### 94. Which pattern is used to compose multiple Zustand stores?
- A) Provider pattern
- B) Slice pattern
- C) Factory pattern
- D) Singleton pattern

**Answer: B**

---

### 95. How do you handle hydration mismatches in Next.js with Zustand?
- A) Use `useHydrated` guard
- B) Disable SSR
- C) Use `useEffect` only
- D) Use `useState` instead

**Answer: A**

---

## Part B: Fill in the Blanks (10 Questions)

### 96. The function used to create a Zustand store is ______.

**Answer: `create`**

---

### 97. To extract specific pieces of state, you use a ______.

**Answer: selector**

---

### 98. The ______ middleware connects Zustand to Redux DevTools.

**Answer: `devtools`**

---

### 99. To persist state to localStorage, use the ______ middleware.

**Answer: `persist`**

---

### 100. When updating state that depends on current state, use a ______ update.

**Answer: functional**

---

### 101. The ______ middleware enables mutable updates while maintaining immutability.

**Answer: `immer`**

---

### 102. A ______ is a modular piece of a store used to split large stores.

**Answer: slice**

---

### 103. To prevent hydration mismatches in Next.js, use a ______ guard.

**Answer: `useHydrated`**

---

### 104. The ______ pattern is used for gradual migration from one state management solution to another.

**Answer: Strangler Fig**

---

### 105. The ______ middleware enables selective subscriptions outside React.

**Answer: `subscribeWithSelector`**

---

## Part C: Code Writing (5 Questions)

### 106. Create a todo store with add, toggle, and delete actions.

**Answer:**
```typescript
import { create } from 'zustand';

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

const useTodoStore = create<TodoStore>((set) => ({
  todos: {},
  todoIds: [],
  addTodo: (text) => {
    const id = crypto.randomUUID();
    set((state) => ({
      todos: { ...state.todos, [id]: { id, text, completed: false } },
      todoIds: [...state.todoIds, id],
    }));
  },
  toggleTodo: (id) => {
    set((state) => ({
      todos: {
        ...state.todos,
        [id]: { ...state.todos[id], completed: !state.todos[id].completed },
      },
    }));
  },
  deleteTodo: (id) => {
    const { [id]: removed, ...remaining } = state.todos;
    set({
      todos: remaining,
      todoIds: state.todoIds.filter(tid => tid !== id),
    });
  },
}));
```

---

### 107. Create a store with persistence for user authentication.

**Answer:**
```typescript
import { create } from 'zustand';
import { persist } from 'zustand/middleware';

interface AuthStore {
  user: User | null;
  token: string | null;
  isLoading: boolean;
  error: string | null;
  login: (email: string, password: string) => Promise<void>;
  logout: () => Promise<void>;
}

const useAuthStore = create<AuthStore>()(
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
    }),
    { name: 'auth-storage' }
  )
);
```

---

### 108. Write an async action with retry logic.

**Answer:**
```typescript
fetchWithRetry: async (url, maxRetries = 3) => {
  let attempt = 0;
  let lastError = null;
  
  set({ loading: true, error: null });
  
  while (attempt < maxRetries) {
    try {
      const response = await fetch(url);
      if (!response.ok) throw new Error(`HTTP ${response.status}`);
      const data = await response.json();
      set({ data, loading: false });
      return data;
    } catch (error) {
      lastError = error;
      attempt++;
      if (attempt >= maxRetries) break;
      await new Promise(resolve => setTimeout(resolve, 1000 * Math.pow(2, attempt)));
    }
  }
  
  set({ error: lastError?.message, loading: false });
}
```

---

### 109. Create a custom validation middleware.

**Answer:**
```typescript
const createValidator = (rules) => {
  return (config) => (set, get, store) => {
    return config(
      (args) => {
        const nextState = typeof args === 'function' ? args(get()) : args;
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

---

### 110. Write a unit test for an async action.

**Answer:**
```typescript
import { describe, it, expect, vi } from 'vitest';
import { useUserStore, userApi } from './userStore';

vi.mock('./api', () => ({
  userApi: { getUsers: vi.fn() },
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

---

# Section 7: Answer Keys

## Multiple Choice Answer Key

| Q# | Answer | Q# | Answer | Q# | Answer | Q# | Answer |
|----|--------|----|--------|----|--------|----|--------|
| 1 | A | 21 | B | 41 | `create` | 61 | False |
| 2 | C | 22 | B | 42 | selector | 62 | True |
| 3 | B | 23 | B | 43 | `devtools` | 63 | False |
| 4 | B | 24 | B | 44 | `persist` | 64 | False |
| 5 | B | 25 | A | 45 | functional | 65 | True |
| 6 | B | 26 | D | 46 | `immer` | 66 | True |
| 7 | B | 27 | A | 47 | slice | 67 | False |
| 8 | D | 28 | B | 48 | `subscribeWithSelector` | 68 | False |
| 9 | B | 29 | B | 49 | `useHydrated` | 69 | True |
| 10 | B | 30 | B | 50 | Strangler Fig | 70 | True |
| 11 | B | 31 | A | 51 | See Code | 71 | See Answer |
| 12 | B | 32 | B | 52 | See Code | 72 | See Answer |
| 13 | B | 33 | B | 53 | See Code | 73 | See Answer |
| 14 | B | 34 | A | 54 | See Code | 74 | See Answer |
| 15 | B | 35 | D | 55 | See Code | 75 | See Answer |
| 16 | B | 36 | B | 56 | See Code | 76 | C |
| 17 | A | 37 | A | 57 | See Code | 77 | B |
| 18 | B | 38 | B | 58 | See Code | 78 | B |
| 19 | A | 39 | B | 59 | See Code | 79 | B |
| 20 | A | 40 | A | 60 | See Code | 80 | C |

## Comprehensive Test Answer Key

| Q# | Answer | Q# | Answer | Q# | Answer | Q# | Answer |
|----|--------|----|--------|----|--------|----|--------|
| 76 | C | 81 | B | 86 | A | 91 | D |
| 77 | B | 82 | B | 87 | B | 92 | A |
| 78 | B | 83 | D | 88 | B | 93 | A |
| 79 | B | 84 | B | 89 | A | 94 | B |
| 80 | C | 85 | B | 90 | B | 95 | A |

---

## Exam Scoring Guide

| Test Type | Total Questions | Score | Grade |
|-----------|-----------------|-------|-------|
| Part A | 20 | 18-20 | A |
| Part B | 20 | 16-17 | B |
| Part C | 20 | 14-15 | C |
| Part D | 10 | 8-10 | A |
| Part E | 5 | 4-5 | A |
| Comprehensive | 35 | 30-35 | A |
| Total | 110 | 90+ | A |

---

## Bonus: Practical Assessment

### Scenario: Build a Task Management Application

**Requirements:**
1. Authentication store with login/logout
2. Task store with CRUD operations
3. Optimistic updates for task actions
4. Persistence for both stores
5. At least one custom middleware (logging or performance)
6. Unit tests for all stores
7. Integration test for task creation

### Evaluation Criteria

| Criteria | Weight | Score |
|----------|--------|-------|
| Store Design | 20% | |
| Code Quality | 20% | |
| Testing | 20% | |
| Performance Optimizations | 15% | |
| Best Practices | 15% | |
| Documentation | 10% | |
| **Total** | **100%** | |

---

[END OF QUIZ & TEST BANK]
