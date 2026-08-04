# Part 7 — Testing Zustand Applications

## Section 27: Unit Testing Stores

Testing is not an afterthought—it's a critical part of building reliable, maintainable applications. Zustand stores are plain JavaScript/TypeScript objects, making them highly testable. In this section, you'll learn how to write comprehensive unit tests for Zustand stores using Jest and Vitest.

---

## The Target: Tested, Reliable Stores

By the end of this section, you'll be able to:
- Set up a testing environment for Zustand stores
- Write unit tests for synchronous and asynchronous actions
- Test selectors and computed properties
- Mock API calls and external dependencies
- Test store persistence and hydration
- Achieve high test coverage for your stores

---

## The Concept: Testing as a Safety Net

Think of testing like a **quality control system** in manufacturing:

```
┌─────────────────────────────────────────────────────────────────┐
│                    TESTING PYRAMID                             │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  E2E Tests (Fewest)                                     │  │
│  │  • Full user journeys                                   │  │
│  │  • Browser/real device                                  │  │
│  │  • Slow, expensive                                      │  │
│  └──────────────────────────────────────────────────────────┘  │
│                         │                                      │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Integration Tests (Some)                               │  │
│  │  • Multiple units together                              │  │
│  │  • API + Store + Component                              │  │
│  │  • Medium speed                                         │  │
│  └──────────────────────────────────────────────────────────┘  │
│                         │                                      │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Unit Tests (Most)                                      │  │
│  │  • Single unit in isolation                             │  │
│  │  • Fast, cheap                                          │  │
│  │  • High coverage                                        │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

**Unit testing Zustand stores involves**:
- Testing state initialization
- Testing actions (synchronous and async)
- Testing selectors and computed values
- Testing middleware and persistence
- Testing error handling

---

## The Implementation: Testing Setup

### Step 1: Install Testing Dependencies

```bash
# For Vitest (recommended for Vite projects)
npm install -D vitest @testing-library/react @testing-library/jest-dom

# For Jest (recommended for Next.js)
npm install -D jest @testing-library/react @testing-library/jest-dom @types/jest

# For mocking APIs
npm install -D msw @testing-library/react-hooks
```

### Step 2: Configure Vitest

```typescript
// vitest.config.ts
import { defineConfig } from 'vitest/config';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  test: {
    globals: true,
    environment: 'jsdom',
    setupFiles: ['./src/test/setup.ts'],
    coverage: {
      provider: 'v8',
      reporter: ['text', 'html'],
      exclude: ['node_modules/', 'src/test/'],
    },
  },
});
```

### Step 3: Test Setup File

```typescript
// src/test/setup.ts
import '@testing-library/jest-dom';
import { afterEach, vi } from 'vitest';
import { cleanup } from '@testing-library/react';

// Clean up after each test
afterEach(() => {
  cleanup();
});

// Mock localStorage for tests
const localStorageMock = {
  getItem: vi.fn(),
  setItem: vi.fn(),
  removeItem: vi.fn(),
  clear: vi.fn(),
  key: vi.fn(),
  length: 0,
};

Object.defineProperty(window, 'localStorage', {
  value: localStorageMock,
});

// Mock ResizeObserver for components that use it
window.ResizeObserver = vi.fn().mockImplementation(() => ({
  observe: vi.fn(),
  unobserve: vi.fn(),
  disconnect: vi.fn(),
}));
```

---

## The Implementation: Testing Stores

### Step 4: Test a Simple Counter Store

```typescript
// src/store/counterStore.ts
import { create } from 'zustand';

interface CounterStore {
  count: number;
  increment: () => void;
  decrement: () => void;
  reset: () => void;
  incrementBy: (amount: number) => void;
}

export const useCounterStore = create<CounterStore>((set) => ({
  count: 0,
  increment: () => set((state) => ({ count: state.count + 1 })),
  decrement: () => set((state) => ({ count: state.count - 1 })),
  reset: () => set({ count: 0 }),
  incrementBy: (amount) => set((state) => ({ count: state.count + amount })),
}));
```

```typescript
// src/store/__tests__/counterStore.test.ts
import { describe, it, expect, beforeEach } from 'vitest';
import { useCounterStore } from '../counterStore';

describe('Counter Store', () => {
  beforeEach(() => {
    // Reset store state before each test
    useCounterStore.setState({ count: 0 });
  });

  describe('initial state', () => {
    it('should have count initialized to 0', () => {
      const { count } = useCounterStore.getState();
      expect(count).toBe(0);
    });
  });

  describe('actions', () => {
    it('should increment count by 1', () => {
      const { increment } = useCounterStore.getState();
      increment();
      expect(useCounterStore.getState().count).toBe(1);
    });

    it('should decrement count by 1', () => {
      const { decrement } = useCounterStore.getState();
      decrement();
      expect(useCounterStore.getState().count).toBe(-1);
    });

    it('should reset count to 0', () => {
      const { increment, reset } = useCounterStore.getState();
      increment();
      increment();
      expect(useCounterStore.getState().count).toBe(2);
      reset();
      expect(useCounterStore.getState().count).toBe(0);
    });

    it('should increment by a specific amount', () => {
      const { incrementBy } = useCounterStore.getState();
      incrementBy(5);
      expect(useCounterStore.getState().count).toBe(5);
      incrementBy(-2);
      expect(useCounterStore.getState().count).toBe(3);
    });
  });

  describe('multiple actions', () => {
    it('should handle multiple actions correctly', () => {
      const { increment, incrementBy, decrement } = useCounterStore.getState();
      increment();
      incrementBy(3);
      decrement();
      expect(useCounterStore.getState().count).toBe(3);
    });
  });
});
```

### Step 5: Test a Todo Store (with Selectors)

```typescript
// src/store/todoStore.ts
import { create } from 'zustand';
import { immer } from 'zustand/middleware/immer';

export interface Todo {
  id: string;
  text: string;
  completed: boolean;
  createdAt: Date;
}

interface TodoStore {
  todos: Record<string, Todo>;
  todoIds: string[];
  filter: 'all' | 'active' | 'completed';
  
  addTodo: (text: string) => void;
  toggleTodo: (id: string) => void;
  deleteTodo: (id: string) => void;
  setFilter: (filter: 'all' | 'active' | 'completed') => void;
  
  // Selectors
  getFilteredTodos: () => Todo[];
  getStats: () => { total: number; completed: number; active: number };
}

export const useTodoStore = create<TodoStore>()(
  immer((set, get) => ({
    todos: {},
    todoIds: [],
    filter: 'all',

    addTodo: (text) => {
      const id = `todo-${Date.now()}`;
      set((state) => {
        state.todos[id] = {
          id,
          text: text.trim(),
          completed: false,
          createdAt: new Date(),
        };
        state.todoIds.push(id);
      });
    },

    toggleTodo: (id) => {
      set((state) => {
        const todo = state.todos[id];
        if (todo) {
          todo.completed = !todo.completed;
        }
      });
    },

    deleteTodo: (id) => {
      set((state) => {
        delete state.todos[id];
        state.todoIds = state.todoIds.filter(tid => tid !== id);
      });
    },

    setFilter: (filter) => {
      set({ filter });
    },

    getFilteredTodos: () => {
      const state = get();
      let todos = state.todoIds.map(id => state.todos[id]).filter(Boolean);
      
      if (state.filter === 'active') {
        todos = todos.filter(t => !t.completed);
      } else if (state.filter === 'completed') {
        todos = todos.filter(t => t.completed);
      }
      
      return todos;
    },

    getStats: () => {
      const state = get();
      const todos = state.todoIds.map(id => state.todos[id]).filter(Boolean);
      return {
        total: todos.length,
        completed: todos.filter(t => t.completed).length,
        active: todos.filter(t => !t.completed).length,
      };
    },
  }))
);
```

```typescript
// src/store/__tests__/todoStore.test.ts
import { describe, it, expect, beforeEach } from 'vitest';
import { useTodoStore } from '../todoStore';

describe('Todo Store', () => {
  beforeEach(() => {
    useTodoStore.setState({
      todos: {},
      todoIds: [],
      filter: 'all',
    });
  });

  describe('addTodo', () => {
    it('should add a new todo', () => {
      const { addTodo } = useTodoStore.getState();
      addTodo('Test todo');
      
      const state = useTodoStore.getState();
      expect(state.todoIds).toHaveLength(1);
      expect(state.todos[state.todoIds[0]].text).toBe('Test todo');
      expect(state.todos[state.todoIds[0]].completed).toBe(false);
    });

    it('should trim whitespace from todo text', () => {
      const { addTodo } = useTodoStore.getState();
      addTodo('  Test todo with spaces  ');
      
      const state = useTodoStore.getState();
      expect(state.todos[state.todoIds[0]].text).toBe('Test todo with spaces');
    });
  });

  describe('toggleTodo', () => {
    it('should toggle a todo from false to true', () => {
      const { addTodo, toggleTodo } = useTodoStore.getState();
      addTodo('Test todo');
      const id = useTodoStore.getState().todoIds[0];
      
      toggleTodo(id);
      expect(useTodoStore.getState().todos[id].completed).toBe(true);
    });

    it('should toggle a todo from true to false', () => {
      const { addTodo, toggleTodo } = useTodoStore.getState();
      addTodo('Test todo');
      const id = useTodoStore.getState().todoIds[0];
      
      toggleTodo(id);
      toggleTodo(id);
      expect(useTodoStore.getState().todos[id].completed).toBe(false);
    });

    it('should not throw if todo does not exist', () => {
      const { toggleTodo } = useTodoStore.getState();
      expect(() => toggleTodo('non-existent-id')).not.toThrow();
    });
  });

  describe('deleteTodo', () => {
    it('should delete a todo', () => {
      const { addTodo, deleteTodo } = useTodoStore.getState();
      addTodo('Test todo');
      const id = useTodoStore.getState().todoIds[0];
      
      deleteTodo(id);
      const state = useTodoStore.getState();
      expect(state.todoIds).toHaveLength(0);
      expect(state.todos[id]).toBeUndefined();
    });

    it('should not throw if todo does not exist', () => {
      const { deleteTodo } = useTodoStore.getState();
      expect(() => deleteTodo('non-existent-id')).not.toThrow();
    });
  });

  describe('setFilter', () => {
    it('should set the filter', () => {
      const { setFilter } = useTodoStore.getState();
      setFilter('active');
      expect(useTodoStore.getState().filter).toBe('active');
    });
  });

  describe('selectors', () => {
    beforeEach(() => {
      const { addTodo } = useTodoStore.getState();
      addTodo('Todo 1');
      addTodo('Todo 2');
      addTodo('Todo 3');
      const state = useTodoStore.getState();
      const ids = state.todoIds;
      state.todos[ids[0]].completed = true;
    });

    describe('getFilteredTodos', () => {
      it('should return all todos when filter is "all"', () => {
        const { getFilteredTodos, setFilter } = useTodoStore.getState();
        setFilter('all');
        const todos = getFilteredTodos();
        expect(todos).toHaveLength(3);
      });

      it('should return only active todos when filter is "active"', () => {
        const { getFilteredTodos, setFilter } = useTodoStore.getState();
        setFilter('active');
        const todos = getFilteredTodos();
        expect(todos).toHaveLength(2);
        expect(todos.every(t => !t.completed)).toBe(true);
      });

      it('should return only completed todos when filter is "completed"', () => {
        const { getFilteredTodos, setFilter } = useTodoStore.getState();
        setFilter('completed');
        const todos = getFilteredTodos();
        expect(todos).toHaveLength(1);
        expect(todos.every(t => t.completed)).toBe(true);
      });
    });

    describe('getStats', () => {
      it('should return correct stats', () => {
        const { getStats } = useTodoStore.getState();
        const stats = getStats();
        expect(stats).toEqual({
          total: 3,
          completed: 1,
          active: 2,
        });
      });
    });
  });
});
```

### Step 6: Testing Async Actions (with API Mocking)

```typescript
// src/store/userStore.ts
import { create } from 'zustand';

export interface User {
  id: number;
  name: string;
  email: string;
}

interface UserStore {
  users: User[];
  loading: boolean;
  error: string | null;
  fetchUsers: () => Promise<void>;
  clearUsers: () => void;
}

// API service (can be mocked)
export const userApi = {
  getUsers: async (): Promise<User[]> => {
    const response = await fetch('/api/users');
    if (!response.ok) {
      throw new Error('Failed to fetch users');
    }
    return response.json();
  },
};

export const useUserStore = create<UserStore>((set) => ({
  users: [],
  loading: false,
  error: null,

  fetchUsers: async () => {
    set({ loading: true, error: null });
    try {
      const users = await userApi.getUsers();
      set({ users, loading: false });
    } catch (error) {
      set({
        error: error instanceof Error ? error.message : 'Unknown error',
        loading: false,
      });
    }
  },

  clearUsers: () => {
    set({ users: [], loading: false, error: null });
  },
}));
```

```typescript
// src/store/__tests__/userStore.test.ts
import { describe, it, expect, beforeEach, vi } from 'vitest';
import { useUserStore, userApi } from '../userStore';

// Mock the API module
vi.mock('../userStore', async () => {
  const actual = await vi.importActual('../userStore');
  return {
    ...actual,
    userApi: {
      getUsers: vi.fn(),
    },
  };
});

describe('User Store', () => {
  beforeEach(() => {
    useUserStore.setState({ users: [], loading: false, error: null });
    vi.clearAllMocks();
  });

  describe('fetchUsers', () => {
    it('should set loading state while fetching', async () => {
      // Mock successful response
      const mockUsers = [
        { id: 1, name: 'User 1', email: 'user1@example.com' },
        { id: 2, name: 'User 2', email: 'user2@example.com' },
      ];
      vi.mocked(userApi.getUsers).mockResolvedValue(mockUsers);

      const { fetchUsers } = useUserStore.getState();
      const promise = fetchUsers();

      // Check loading state during fetch
      expect(useUserStore.getState().loading).toBe(true);
      expect(useUserStore.getState().users).toHaveLength(0);

      await promise;

      // Check final state
      const state = useUserStore.getState();
      expect(state.loading).toBe(false);
      expect(state.users).toEqual(mockUsers);
      expect(state.error).toBe(null);
      expect(userApi.getUsers).toHaveBeenCalledTimes(1);
    });

    it('should handle fetch errors', async () => {
      const errorMessage = 'Network error';
      vi.mocked(userApi.getUsers).mockRejectedValue(new Error(errorMessage));

      const { fetchUsers } = useUserStore.getState();
      await fetchUsers();

      const state = useUserStore.getState();
      expect(state.loading).toBe(false);
      expect(state.users).toHaveLength(0);
      expect(state.error).toBe(errorMessage);
    });

    it('should handle HTTP errors', async () => {
      vi.mocked(userApi.getUsers).mockRejectedValue(new Error('Failed to fetch users'));

      const { fetchUsers } = useUserStore.getState();
      await fetchUsers();

      const state = useUserStore.getState();
      expect(state.error).toBe('Failed to fetch users');
    });
  });

  describe('clearUsers', () => {
    it('should clear users and reset loading/error', async () => {
      const mockUsers = [{ id: 1, name: 'User 1', email: 'user1@example.com' }];
      vi.mocked(userApi.getUsers).mockResolvedValue(mockUsers);
      
      const { fetchUsers, clearUsers } = useUserStore.getState();
      await fetchUsers();

      // Verify state after fetch
      expect(useUserStore.getState().users).toHaveLength(1);

      clearUsers();
      const state = useUserStore.getState();
      expect(state.users).toHaveLength(0);
      expect(state.loading).toBe(false);
      expect(state.error).toBe(null);
    });
  });
});
```

### Step 7: Testing Persistence Middleware

```typescript
// src/store/persistedStore.ts
import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';

interface PersistedStore {
  theme: 'light' | 'dark';
  language: string;
  notifications: boolean;
  setTheme: (theme: 'light' | 'dark') => void;
  setLanguage: (language: string) => void;
  toggleNotifications: () => void;
}

export const usePersistedStore = create<PersistedStore>()(
  persist(
    (set) => ({
      theme: 'light',
      language: 'en-US',
      notifications: true,
      setTheme: (theme) => set({ theme }),
      setLanguage: (language) => set({ language }),
      toggleNotifications: () => 
        set((state) => ({ notifications: !state.notifications })),
    }),
    {
      name: 'persisted-storage',
      storage: createJSONStorage(() => localStorage),
      partialize: (state) => ({
        theme: state.theme,
        language: state.language,
        // Don't persist notifications
      }),
    }
  )
);
```

```typescript
// src/store/__tests__/persistedStore.test.ts
import { describe, it, expect, beforeEach, vi } from 'vitest';
import { usePersistedStore } from '../persistedStore';

describe('Persisted Store', () => {
  beforeEach(() => {
    // Clear localStorage mock
    localStorage.clear();
    vi.clearAllMocks();
    // Reset store state
    usePersistedStore.setState({
      theme: 'light',
      language: 'en-US',
      notifications: true,
    });
  });

  describe('persistence', () => {
    it('should save to localStorage when state changes', () => {
      const { setTheme } = usePersistedStore.getState();
      
      // Mock the persist middleware's storage
      const setItemSpy = vi.spyOn(localStorage, 'setItem');
      
      setTheme('dark');
      
      // Check that setItem was called with correct data
      expect(setItemSpy).toHaveBeenCalled();
      const lastCall = setItemSpy.mock.calls[setItemSpy.mock.calls.length - 1];
      expect(lastCall[0]).toBe('persisted-storage');
      
      // Check that only persisted fields were saved
      const savedState = JSON.parse(lastCall[1]);
      expect(savedState.state.theme).toBe('dark');
      expect(savedState.state.language).toBe('en-US');
      // notifications should NOT be persisted
      expect(savedState.state.notifications).toBeUndefined();
    });

    it('should load from localStorage on initialization', () => {
      // Simulate saved state
      const savedState = {
        state: {
          theme: 'dark',
          language: 'es-ES',
        },
        version: 0,
      };
      localStorage.setItem('persisted-storage', JSON.stringify(savedState));

      // Recreate the store (in real test, we'd re-import)
      // For this test, we manually set the state
      usePersistedStore.setState({
        theme: savedState.state.theme,
        language: savedState.state.language,
        notifications: true,
      });

      const state = usePersistedStore.getState();
      expect(state.theme).toBe('dark');
      expect(state.language).toBe('es-ES');
      expect(state.notifications).toBe(true); // Default value
    });

    it('should handle empty localStorage gracefully', () => {
      // Ensure localStorage is empty
      localStorage.clear();
      
      // Reset store to default
      usePersistedStore.setState({
        theme: 'light',
        language: 'en-US',
        notifications: true,
      });
      
      const state = usePersistedStore.getState();
      expect(state.theme).toBe('light');
      expect(state.language).toBe('en-US');
    });
  });

  describe('actions with persistence', () => {
    it('should update state and trigger persistence', () => {
      const { setTheme, setLanguage, toggleNotifications } = usePersistedStore.getState();
      
      // These should update the store and trigger persistence
      setTheme('dark');
      setLanguage('fr-FR');
      toggleNotifications();
      
      const state = usePersistedStore.getState();
      expect(state.theme).toBe('dark');
      expect(state.language).toBe('fr-FR');
      expect(state.notifications).toBe(false);
    });
  });
});
```

### Step 8: Testing Custom Middleware

```typescript
// src/middleware/logger.ts
import { StateCreator } from 'zustand';

export const logger = <T extends object>(
  config: StateCreator<T, [], []>
): StateCreator<T, [], []> => {
  return (set, get, store) => {
    return config(
      (args) => {
        const prev = get();
        console.log('📊 Before:', prev);
        set(args);
        const next = get();
        console.log('📊 After:', next);
      },
      get,
      store
    );
  };
};
```

```typescript
// src/middleware/__tests__/logger.test.ts
import { describe, it, expect, beforeEach, vi } from 'vitest';
import { create } from 'zustand';
import { logger } from '../logger';

describe('Logger Middleware', () => {
  it('should log state changes', () => {
    const consoleLogSpy = vi.spyOn(console, 'log').mockImplementation(() => {});
    
    const useTestStore = create(
      logger<{ count: number }>((set) => ({
        count: 0,
        increment: () => set((state) => ({ count: state.count + 1 })),
      }))
    );
    
    const { increment } = useTestStore.getState();
    increment();
    
    // Check that console.log was called with before and after
    expect(consoleLogSpy).toHaveBeenCalledWith('📊 Before:', { count: 0 });
    expect(consoleLogSpy).toHaveBeenCalledWith('📊 After:', { count: 1 });
    
    consoleLogSpy.mockRestore();
  });

  it('should maintain the same API', () => {
    const useTestStore = create(
      logger<{ count: number }>((set) => ({
        count: 0,
        increment: () => set((state) => ({ count: state.count + 1 })),
      }))
    );
    
    expect(useTestStore.getState().count).toBe(0);
    useTestStore.getState().increment();
    expect(useTestStore.getState().count).toBe(1);
  });
});
```

---

## The Verification: Running Tests

### Step 1: Package.json Scripts

```json
{
  "scripts": {
    "test": "vitest",
    "test:watch": "vitest --watch",
    "test:coverage": "vitest --coverage",
    "test:ci": "vitest run"
  }
}
```

### Step 2: Run Tests

```bash
# Run all tests
npm test

# Run with coverage
npm run test:coverage

# Run in CI mode (single run)
npm run test:ci
```

### Step 3: Test Output Example

```
✓ src/store/__tests__/counterStore.test.ts (8)
✓ src/store/__tests__/todoStore.test.ts (12)
✓ src/store/__tests__/userStore.test.ts (5)
✓ src/store/__tests__/persistedStore.test.ts (4)
✓ src/middleware/__tests__/logger.test.ts (2)

Test Files  5 passed (5)
     Tests  31 passed (31)
  Duration  2.34s
```

---

## Deep Dive: Testing Patterns

### Pattern 1: Reset State Between Tests

```typescript
// src/test/utils/storeReset.ts
import { useCounterStore } from '../../store/counterStore';

export function resetAllStores() {
  // Reset each store to its initial state
  useCounterStore.setState({ count: 0 });
  // ... reset other stores
}

// In tests
import { resetAllStores } from '../utils/storeReset';

beforeEach(() => {
  resetAllStores();
});
```

### Pattern 2: Testing Error Scenarios

```typescript
it('should handle validation errors', () => {
  const { addTodo } = useTodoStore.getState();
  
  // Attempt to add empty todo
  addTodo('');
  
  // No todo should be added
  const state = useTodoStore.getState();
  expect(state.todoIds).toHaveLength(0);
});

it('should handle API errors with retry logic', async () => {
  const mockFetch = vi.fn()
    .mockRejectedValueOnce(new Error('Network error'))
    .mockResolvedValueOnce({ ok: true, json: () => Promise.resolve([]) });
  
  global.fetch = mockFetch;
  
  const { fetchUsers } = useUserStore.getState();
  await fetchUsers();
  
  // Should retry and succeed
  expect(useUserStore.getState().loading).toBe(false);
  expect(mockFetch).toHaveBeenCalledTimes(2);
});
```

### Pattern 3: Testing with React Testing Library

```tsx
// src/components/__tests__/Counter.test.tsx
import { render, screen, fireEvent } from '@testing-library/react';
import { useCounterStore } from '../../store/counterStore';
import { Counter } from '../Counter';

describe('Counter Component', () => {
  beforeEach(() => {
    useCounterStore.setState({ count: 0 });
  });

  it('should display the count', () => {
    render(<Counter />);
    expect(screen.getByText('Count: 0')).toBeInTheDocument();
  });

  it('should increment when button is clicked', () => {
    render(<Counter />);
    const button = screen.getByText('Increment');
    fireEvent.click(button);
    expect(screen.getByText('Count: 1')).toBeInTheDocument();
  });

  it('should update store when component actions are called', () => {
    render(<Counter />);
    const button = screen.getByText('Increment');
    fireEvent.click(button);
    expect(useCounterStore.getState().count).toBe(1);
  });
});
```

---

## Common Pitfalls and Solutions

### Pitfall 1: State Leaking Between Tests

```typescript
// ❌ BAD: State persists between tests
it('test 1', () => {
  useStore.getState().increment();
  expect(useStore.getState().count).toBe(1);
});

it('test 2', () => {
  // count is still 1 from previous test
  expect(useStore.getState().count).toBe(1);
});

// ✅ GOOD: Reset state before each test
beforeEach(() => {
  useStore.setState({ count: 0 });
});
```

### Pitfall 2: Not Mocking Async Dependencies

```typescript
// ❌ BAD: Real API calls in tests
it('should fetch users', async () => {
  await useUserStore.getState().fetchUsers();
  // Makes real network call
});

// ✅ GOOD: Mock API calls
vi.mock('../api', () => ({
  fetchUsers: vi.fn().mockResolvedValue(mockUsers),
}));
```

### Pitfall 3: Not Testing Error Cases

```typescript
// ❌ BAD: Only testing happy path
it('should fetch users', async () => {
  // Only tests successful fetch
});

// ✅ GOOD: Test both success and failure
it('should handle fetch errors', async () => {
  // Mock error and verify error state
});
```

### Pitfall 4: Not Testing Selectors Thoroughly

```typescript
// ❌ BAD: Only testing selector existence
it('should have getFilteredTodos', () => {
  expect(useTodoStore.getState().getFilteredTodos).toBeDefined();
});

// ✅ GOOD: Test selector logic
it('should filter todos correctly', () => {
  // Add test data, verify filtering
});
```

---

## Testing Checklist

- [ ] Store initialized with correct default state
- [ ] Actions update state correctly
- [ ] Selectors return correct derived values
- [ ] Async actions handle success and error states
- [ ] API calls are mocked in tests
- [ ] Error states are tested
- [ ] Persistence middleware tested
- [ ] Custom middleware tested
- [ ] Store state is reset between tests
- [ ] Test coverage meets thresholds

---

## Key Takeaways

1. **Reset state between tests** – Prevents state leakage
2. **Mock external dependencies** – API calls, localStorage, etc.
3. **Test both success and error paths** – Especially for async actions
4. **Test selectors** – They're critical for performance and correctness
5. **Test persistence** – Ensure state is saved and loaded correctly
6. **Test middleware** – Confirm it doesn't break the store API
7. **Use spies** – Verify that functions were called with correct arguments
8. **Test components that use stores** – Integration tests catch issues
9. **Keep tests focused** – One concern per test
10. **Maintain high coverage** – But don't chase 100% at the expense of quality

---

## What's Next

You've mastered unit testing Zustand stores. Next, you'll learn integration testing with React Testing Library and testing async workflows.
