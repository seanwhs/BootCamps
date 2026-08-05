# Zustand Mastery: Complete Lab Book

## Hands-On Exercises for the 5-Day Course

---

# Table of Contents

1. [Lab 1.1: Counter Store](#lab-11-counter-store)
2. [Lab 1.2: Todo Store with Selectors](#lab-12-todo-store-with-selectors)
3. [Lab 1.3: Vanilla Store](#lab-13-vanilla-store)
4. [Lab 2.1: Slice Pattern](#lab-21-slice-pattern)
5. [Lab 2.2: Middleware Configuration](#lab-22-middleware-configuration)
6. [Lab 2.3: Persistence with Migrations](#lab-23-persistence-with-migrations)
7. [Lab 2.4: Derived State with Reselect](#lab-24-derived-state-with-reselect)
8. [Lab 3.1: Async Data Fetching](#lab-31-async-data-fetching)
9. [Lab 3.2: Request Deduplication](#lab-32-request-deduplication)
10. [Lab 3.3: API Integration](#lab-33-api-integration)
11. [Lab 3.4: Custom Middleware](#lab-34-custom-middleware)
12. [Lab 4.1: Rendering Optimization](#lab-41-rendering-optimization)
13. [Lab 4.2: State Normalization](#lab-42-state-normalization)
14. [Lab 4.3: Performance Benchmarking](#lab-43-performance-benchmarking)
15. [Lab 4.4: React 19 Integration](#lab-44-react-19-integration)
16. [Lab 5.1: Shopping Cart](#lab-51-shopping-cart)
17. [Lab 5.2: Testing Zustand Stores](#lab-52-testing-zustand-stores)
18. [Capstone Project: TaskFlow](#capstone-project-taskflow)

---

# Lab 1.1: Counter Store

## 🎯 Objective

Build a simple counter store with increment, decrement, and reset functionality.

## 📋 Prerequisites

- Node.js 20+ installed
- Basic React knowledge

## 🔧 Setup

```bash
mkdir zustand-lab-1-1
cd zustand-lab-1-1
npm init -y
npm install react react-dom zustand
npm install -D typescript @types/react @types/react-dom vite @vitejs/plugin-react
```

Create `vite.config.ts`:

```typescript
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
});
```

Create `tsconfig.json`:

```json
{
  "compilerOptions": {
    "target": "ES2020",
    "useDefineForClassFields": true,
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "skipLibCheck": true,
    "moduleResolution": "bundler",
    "allowImportingTsExtensions": true,
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": true,
    "jsx": "react-jsx",
    "strict": true
  },
  "include": ["src"]
}
```

## 📝 Task 1: Create the Counter Store

Create `src/store/counterStore.ts`:

```typescript
import { create } from 'zustand';

// TODO: Define the CounterStore interface
// It should have:
// - count: number
// - increment: () => void
// - decrement: () => void
// - reset: () => void

// TODO: Create the store using create()
// Use the functional form of set for increment and decrement
// Use the object form for reset
```

<details>
<summary>Click for Solution</summary>

```typescript
import { create } from 'zustand';

interface CounterStore {
  count: number;
  increment: () => void;
  decrement: () => void;
  reset: () => void;
}

export const useCounterStore = create<CounterStore>((set) => ({
  count: 0,
  increment: () => set((state) => ({ count: state.count + 1 })),
  decrement: () => set((state) => ({ count: state.count - 1 })),
  reset: () => set({ count: 0 }),
}));
```
</details>

## 📝 Task 2: Create the Counter Component

Create `src/components/Counter.tsx`:

```tsx
import React from 'react';
import { useCounterStore } from '../store/counterStore';

// TODO: Create a Counter component that:
// 1. Subscribes to count, increment, decrement, and reset
// 2. Displays the count
// 3. Has buttons for increment, decrement, and reset
```

<details>
<summary>Click for Solution</summary>

```tsx
import React from 'react';
import { useCounterStore } from '../store/counterStore';

export function Counter() {
  const count = useCounterStore((state) => state.count);
  const increment = useCounterStore((state) => state.increment);
  const decrement = useCounterStore((state) => state.decrement);
  const reset = useCounterStore((state) => state.reset);

  return (
    <div style={{ textAlign: 'center', padding: '40px' }}>
      <h1>Counter: {count}</h1>
      <div style={{ display: 'flex', gap: '10px', justifyContent: 'center' }}>
        <button onClick={decrement}>-</button>
        <button onClick={reset}>Reset</button>
        <button onClick={increment}>+</button>
      </div>
    </div>
  );
}
```
</details>

## 📝 Task 3: Create the App

Create `src/App.tsx`:

```tsx
import React from 'react';
import { Counter } from './components/Counter';

function App() {
  return (
    <div>
      <Counter />
    </div>
  );
}

export default App;
```

## 📝 Task 4: Create Entry Point

Create `src/main.tsx`:

```tsx
import React from 'react';
import ReactDOM from 'react-dom/client';
import App from './App';

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
);
```

Create `index.html`:

```html
<!DOCTYPE html>
<html>
  <head>
    <title>Counter Lab</title>
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.tsx"></script>
  </body>
</html>
```

## ✅ Verification Steps

1. **Run the application**:
   ```bash
   npx vite
   ```

2. **Test the counter**:
   - Click "+" → count should increase
   - Click "-" → count should decrease
   - Click "Reset" → count should return to 0

3. **Verify re-renders**:
   - Open React DevTools
   - Check that only the Counter component re-renders on state changes

## 💡 Extension Challenge

Add a `step` property to the store that controls how much the counter increments/decrements:

```typescript
interface CounterStore {
  count: number;
  step: number;
  increment: () => void;
  decrement: () => void;
  reset: () => void;
  setStep: (step: number) => void;
}
```

---

# Lab 1.2: Todo Store with Selectors

## 🎯 Objective

Build a todo store with selectors for filtered views and statistics.

## 📋 Prerequisites

- Lab 1.1 completed
- Understanding of selectors

## 📝 Task 1: Create the Todo Store

Create `src/store/todoStore.ts`:

```typescript
import { create } from 'zustand';

// TODO: Define Todo interface
// Properties: id, text, completed, createdAt

// TODO: Define TodoStore interface
// State: todos, filter
// Actions: addTodo, toggleTodo, deleteTodo, setFilter

// TODO: Create the store
// Use functional updates for addTodo, toggleTodo, deleteTodo

// TODO: Add selectors as methods:
// - getFilteredTodos: returns todos based on filter
// - getStats: returns { total, completed, active }
```

<details>
<summary>Click for Solution</summary>

```typescript
import { create } from 'zustand';

interface Todo {
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
  getFilteredTodos: () => Todo[];
  getStats: () => { total: number; completed: number; active: number };
}

export const useTodoStore = create<TodoStore>((set, get) => ({
  todos: {},
  todoIds: [],
  filter: 'all',

  addTodo: (text) => {
    const id = crypto.randomUUID();
    set((state) => ({
      todos: {
        ...state.todos,
        [id]: { id, text, completed: false, createdAt: new Date() },
      },
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
    set((state) => {
      const { [id]: removed, ...remaining } = state.todos;
      return {
        todos: remaining,
        todoIds: state.todoIds.filter((tid) => tid !== id),
      };
    });
  },

  setFilter: (filter) => set({ filter }),

  getFilteredTodos: () => {
    const state = get();
    let todos = state.todoIds.map((id) => state.todos[id]);
    if (state.filter === 'active') {
      todos = todos.filter((t) => !t.completed);
    } else if (state.filter === 'completed') {
      todos = todos.filter((t) => t.completed);
    }
    return todos;
  },

  getStats: () => {
    const state = get();
    const todos = state.todoIds.map((id) => state.todos[id]);
    const total = todos.length;
    const completed = todos.filter((t) => t.completed).length;
    return { total, completed, active: total - completed };
  },
}));
```
</details>

## 📝 Task 2: Create the Todo Components

Create `src/components/TodoList.tsx`:

```tsx
import React, { useState } from 'react';
import { useTodoStore } from '../store/todoStore';

// TODO: Create TodoList component that:
// 1. Uses getFilteredTodos and getStats
// 2. Displays stats (total, completed, active)
// 3. Displays filtered todos
// 4. Has filter buttons
// 5. Has add todo input and button
// 6. Each todo has a toggle and delete button
```

<details>
<summary>Click for Solution</summary>

```tsx
import React, { useState } from 'react';
import { useTodoStore } from '../store/todoStore';

export function TodoList() {
  const [newTodo, setNewTodo] = useState('');
  const stats = useTodoStore((state) => state.getStats());
  const filter = useTodoStore((state) => state.filter);
  const todos = useTodoStore((state) => state.getFilteredTodos());
  const addTodo = useTodoStore((state) => state.addTodo);
  const toggleTodo = useTodoStore((state) => state.toggleTodo);
  const deleteTodo = useTodoStore((state) => state.deleteTodo);
  const setFilter = useTodoStore((state) => state.setFilter);

  const handleAdd = (e: React.FormEvent) => {
    e.preventDefault();
    if (newTodo.trim()) {
      addTodo(newTodo.trim());
      setNewTodo('');
    }
  };

  return (
    <div style={{ padding: '20px', maxWidth: '500px', margin: '0 auto' }}>
      <h1>Todo List</h1>

      <div style={{ display: 'flex', gap: '20px', marginBottom: '10px' }}>
        <span>Total: {stats.total}</span>
        <span>Active: {stats.active}</span>
        <span>Completed: {stats.completed}</span>
      </div>

      <div style={{ display: 'flex', gap: '10px', marginBottom: '10px' }}>
        <button onClick={() => setFilter('all')} style={{ fontWeight: filter === 'all' ? 'bold' : 'normal' }}>
          All
        </button>
        <button onClick={() => setFilter('active')} style={{ fontWeight: filter === 'active' ? 'bold' : 'normal' }}>
          Active
        </button>
        <button onClick={() => setFilter('completed')} style={{ fontWeight: filter === 'completed' ? 'bold' : 'normal' }}>
          Completed
        </button>
      </div>

      <form onSubmit={handleAdd} style={{ display: 'flex', gap: '10px', marginBottom: '20px' }}>
        <input
          type="text"
          value={newTodo}
          onChange={(e) => setNewTodo(e.target.value)}
          placeholder="Add a todo..."
          style={{ flex: 1, padding: '8px' }}
        />
        <button type="submit">Add</button>
      </form>

      <ul style={{ listStyle: 'none', padding: 0 }}>
        {todos.map((todo) => (
          <li
            key={todo.id}
            style={{
              display: 'flex',
              alignItems: 'center',
              gap: '10px',
              padding: '8px',
              borderBottom: '1px solid #eee',
            }}
          >
            <input
              type="checkbox"
              checked={todo.completed}
              onChange={() => toggleTodo(todo.id)}
            />
            <span style={{ textDecoration: todo.completed ? 'line-through' : 'none' }}>
              {todo.text}
            </span>
            <button onClick={() => deleteTodo(todo.id)} style={{ marginLeft: 'auto' }}>
              Delete
            </button>
          </li>
        ))}
      </ul>
    </div>
  );
}
```
</details>

## ✅ Verification Steps

1. **Run the application**:
   ```bash
   npx vite
   ```

2. **Test functionality**:
   - Add todos → should appear in list
   - Toggle todos → should mark as completed
   - Delete todos → should remove from list
   - Filter buttons → should show correct filtered views
   - Stats → should update correctly

3. **Test performance**:
   - Add many todos (100+)
   - Check that UI remains responsive
   - Open React DevTools to verify re-renders

## 💡 Extension Challenge

Add a search filter to the store:

```typescript
interface TodoStore {
  // ... existing
  searchQuery: string;
  setSearchQuery: (query: string) => void;
  // getFilteredTodos should also filter by searchQuery
}
```

---

# Lab 1.3: Vanilla Store

## 🎯 Objective

Create a vanilla store that works outside React and integrate it with a React component.

## 📋 Prerequisites

- Lab 1.2 completed
- Understanding of vanilla stores

## 📝 Task 1: Create the Vanilla Store

Create `src/store/vanillaCounterStore.ts`:

```typescript
import { createStore } from 'zustand/vanilla';

// TODO: Create a vanilla store with:
// - count: number
// - increment: () => void
// - decrement: () => void
// - reset: () => void
// - getDouble: () => number (computed)
```

<details>
<summary>Click for Solution</summary>

```typescript
import { createStore } from 'zustand/vanilla';

interface VanillaCounterStore {
  count: number;
  increment: () => void;
  decrement: () => void;
  reset: () => void;
  getDouble: () => number;
}

export const vanillaCounterStore = createStore<VanillaCounterStore>((set, get) => ({
  count: 0,
  increment: () => set((state) => ({ count: state.count + 1 })),
  decrement: () => set((state) => ({ count: state.count - 1 })),
  reset: () => set({ count: 0 }),
  getDouble: () => get().count * 2,
}));
```
</details>

## 📝 Task 2: Create a Utility Function

Create `src/utils/logger.ts`:

```typescript
import { vanillaCounterStore } from '../store/vanillaCounterStore';

// TODO: Create a function that:
// 1. Subscribes to the vanilla store
// 2. Logs every state change to the console
// 3. Returns an unsubscribe function
```

<details>
<summary>Click for Solution</summary>

```typescript
import { vanillaCounterStore } from '../store/vanillaCounterStore';

export function startLogging() {
  console.log('📊 Starting vanilla store logging');

  const unsubscribe = vanillaCounterStore.subscribe((state) => {
    console.log('🔄 State changed:', {
      count: state.count,
      double: state.getDouble(),
    });
  });

  return unsubscribe;
}
```
</details>

## 📝 Task 3: Create the React Component

Create `src/components/VanillaCounter.tsx`:

```tsx
import React, { useEffect } from 'react';
import { useStore } from 'zustand';
import { vanillaCounterStore } from '../store/vanillaCounterStore';
import { startLogging } from '../utils/logger';

// TODO: Create a component that:
// 1. Uses useStore to subscribe to the vanilla store
// 2. Gets count and actions
// 3. Starts logging on mount and cleans up on unmount
// 4. Displays the count and double value
```

<details>
<summary>Click for Solution</summary>

```tsx
import React, { useEffect } from 'react';
import { useStore } from 'zustand';
import { vanillaCounterStore } from '../store/vanillaCounterStore';
import { startLogging } from '../utils/logger';

export function VanillaCounter() {
  const count = useStore(vanillaCounterStore, (state) => state.count);
  const double = useStore(vanillaCounterStore, (state) => state.getDouble());
  const increment = useStore(vanillaCounterStore, (state) => state.increment);
  const decrement = useStore(vanillaCounterStore, (state) => state.decrement);
  const reset = useStore(vanillaCounterStore, (state) => state.reset);

  useEffect(() => {
    const unsubscribe = startLogging();
    return () => unsubscribe();
  }, []);

  return (
    <div style={{ textAlign: 'center', padding: '40px', border: '2px solid #4CAF50', borderRadius: '8px' }}>
      <h2>Vanilla Store Counter</h2>
      <p>Count: {count}</p>
      <p>Double: {double}</p>
      <div style={{ display: 'flex', gap: '10px', justifyContent: 'center' }}>
        <button onClick={decrement}>-</button>
        <button onClick={reset}>Reset</button>
        <button onClick={increment}>+</button>
      </div>
    </div>
  );
}
```
</details>

## ✅ Verification Steps

1. **Run the application**:
   ```bash
   npx vite
   ```

2. **Verify logging**:
   - Open browser console
   - Click counter buttons
   - You should see logs from the vanilla store subscription

3. **Test the store**:
   - Increment/decrement works
   - Double value updates correctly
   - Reset works

## 💡 Extension Challenge

Create a second component that uses the same vanilla store. Verify that both components stay in sync.

---

# Lab 2.1: Slice Pattern

## 🎯 Objective

Structure a large application using the slice pattern with three domains: user, tasks, and UI.

## 📋 Prerequisites

- Understanding of the slice pattern
- Knowledge of domain-driven organization

## 📝 Task 1: Create the User Slice

Create `src/store/slices/userSlice.ts`:

```typescript
import { StateCreator } from 'zustand';

// TODO: Define User interface
// id, name, email, role

// TODO: Define UserSlice interface
// State: user, isLoading
// Actions: setUser, clearUser, fetchUser

// TODO: Create userSlice using StateCreator
```

<details>
<summary>Click for Solution</summary>

```typescript
import { StateCreator } from 'zustand';

export interface User {
  id: string;
  name: string;
  email: string;
  role: 'admin' | 'user';
}

export interface UserSlice {
  user: User | null;
  isLoading: boolean;
  setUser: (user: User) => void;
  clearUser: () => void;
  fetchUser: (id: string) => Promise<void>;
}

export const createUserSlice: StateCreator<UserSlice> = (set) => ({
  user: null,
  isLoading: false,
  setUser: (user) => set({ user }),
  clearUser: () => set({ user: null }),
  fetchUser: async (id: string) => {
    set({ isLoading: true });
    try {
      // Simulate API call
      await new Promise((resolve) => setTimeout(resolve, 500));
      const user: User = {
        id,
        name: `User ${id}`,
        email: `user${id}@example.com`,
        role: 'user',
      };
      set({ user, isLoading: false });
    } catch {
      set({ isLoading: false });
    }
  },
});
```
</details>

## 📝 Task 2: Create the Task Slice

Create `src/store/slices/taskSlice.ts`:

```typescript
import { StateCreator } from 'zustand';

// TODO: Define Task interface
// id, title, completed, userId

// TODO: Define TaskSlice interface
// State: tasks, taskIds, filter
// Actions: addTask, toggleTask, deleteTask, setFilter, getFilteredTasks, getStats

// TODO: Create taskSlice using StateCreator
```

<details>
<summary>Click for Solution</summary>

```typescript
import { StateCreator } from 'zustand';

export interface Task {
  id: string;
  title: string;
  completed: boolean;
  userId: string;
}

export interface TaskSlice {
  tasks: Record<string, Task>;
  taskIds: string[];
  filter: 'all' | 'active' | 'completed';
  addTask: (title: string, userId: string) => void;
  toggleTask: (id: string) => void;
  deleteTask: (id: string) => void;
  setFilter: (filter: 'all' | 'active' | 'completed') => void;
  getFilteredTasks: () => Task[];
  getStats: () => { total: number; completed: number; active: number };
}

export const createTaskSlice: StateCreator<TaskSlice> = (set, get) => ({
  tasks: {},
  taskIds: [],
  filter: 'all',

  addTask: (title: string, userId: string) => {
    const id = crypto.randomUUID();
    set((state) => ({
      tasks: {
        ...state.tasks,
        [id]: { id, title, completed: false, userId },
      },
      taskIds: [...state.taskIds, id],
    }));
  },

  toggleTask: (id: string) => {
    set((state) => ({
      tasks: {
        ...state.tasks,
        [id]: { ...state.tasks[id], completed: !state.tasks[id].completed },
      },
    }));
  },

  deleteTask: (id: string) => {
    set((state) => {
      const { [id]: removed, ...remaining } = state.tasks;
      return {
        tasks: remaining,
        taskIds: state.taskIds.filter((tid) => tid !== id),
      };
    });
  },

  setFilter: (filter) => set({ filter }),

  getFilteredTasks: () => {
    const state = get();
    let tasks = state.taskIds.map((id) => state.tasks[id]);
    if (state.filter === 'active') {
      tasks = tasks.filter((t) => !t.completed);
    } else if (state.filter === 'completed') {
      tasks = tasks.filter((t) => t.completed);
    }
    return tasks;
  },

  getStats: () => {
    const state = get();
    const tasks = state.taskIds.map((id) => state.tasks[id]);
    const total = tasks.length;
    const completed = tasks.filter((t) => t.completed).length;
    return { total, completed, active: total - completed };
  },
});
```
</details>

## 📝 Task 3: Create the UI Slice

Create `src/store/slices/uiSlice.ts`:

```typescript
import { StateCreator } from 'zustand';

// TODO: Define UISlice interface
// State: theme, sidebarOpen
// Actions: toggleTheme, toggleSidebar

// TODO: Create uiSlice using StateCreator
```

<details>
<summary>Click for Solution</summary>

```typescript
import { StateCreator } from 'zustand';

export interface UISlice {
  theme: 'light' | 'dark';
  sidebarOpen: boolean;
  toggleTheme: () => void;
  toggleSidebar: () => void;
}

export const createUISlice: StateCreator<UISlice> = (set) => ({
  theme: 'light',
  sidebarOpen: true,
  toggleTheme: () =>
    set((state) => ({
      theme: state.theme === 'light' ? 'dark' : 'light',
    })),
  toggleSidebar: () =>
    set((state) => ({
      sidebarOpen: !state.sidebarOpen,
    })),
});
```
</details>

## 📝 Task 4: Combine the Slices

Create `src/store/store.ts`:

```typescript
import { create } from 'zustand';
import { createUserSlice, UserSlice } from './slices/userSlice';
import { createTaskSlice, TaskSlice } from './slices/taskSlice';
import { createUISlice, UISlice } from './slices/uiSlice';

// TODO: Define RootStore type combining all slices

// TODO: Create the store combining all slices

// TODO: Export the store and convenience selectors
```

<details>
<summary>Click for Solution</summary>

```typescript
import { create } from 'zustand';
import { createUserSlice, UserSlice } from './slices/userSlice';
import { createTaskSlice, TaskSlice } from './slices/taskSlice';
import { createUISlice, UISlice } from './slices/uiSlice';

export type RootStore = UserSlice & TaskSlice & UISlice;

export const useStore = create<RootStore>((set, get, store) => ({
  ...createUserSlice(set, get, store),
  ...createTaskSlice(set, get, store),
  ...createUISlice(set, get, store),
}));

// Convenience hooks
export const useUser = () => {
  const user = useStore((state) => state.user);
  const isLoading = useStore((state) => state.isLoading);
  const setUser = useStore((state) => state.setUser);
  const clearUser = useStore((state) => state.clearUser);
  const fetchUser = useStore((state) => state.fetchUser);
  return { user, isLoading, setUser, clearUser, fetchUser };
};

export const useTasks = () => {
  const getFilteredTasks = useStore((state) => state.getFilteredTasks);
  const getStats = useStore((state) => state.getStats);
  const addTask = useStore((state) => state.addTask);
  const toggleTask = useStore((state) => state.toggleTask);
  const deleteTask = useStore((state) => state.deleteTask);
  const setFilter = useStore((state) => state.setFilter);
  const filter = useStore((state) => state.filter);
  return { getFilteredTasks, getStats, addTask, toggleTask, deleteTask, setFilter, filter };
};

export const useUI = () => {
  const theme = useStore((state) => state.theme);
  const sidebarOpen = useStore((state) => state.sidebarOpen);
  const toggleTheme = useStore((state) => state.toggleTheme);
  const toggleSidebar = useStore((state) => state.toggleSidebar);
  return { theme, sidebarOpen, toggleTheme, toggleSidebar };
};
```
</details>

## ✅ Verification Steps

1. **Run the application**:
   ```bash
   npx vite
   ```

2. **Test the store**:
   - Verify all slices are available
   - Test user actions
   - Test task actions
   - Test UI actions
   - Verify slices don't interfere with each other

3. **Check DevTools**:
   - Open Redux DevTools
   - Verify all actions are logged with slice names

## 💡 Extension Challenge

Add a fourth slice for notifications with `addNotification` and `clearNotifications` actions.

---

# Lab 2.2: Middleware Configuration

## 🎯 Objective

Configure and use Zustand middleware: devtools, persist, and immer.

## 📋 Prerequisites

- Lab 2.1 completed
- Understanding of middleware

## 📝 Task 1: Enhance the Store with Middleware

Update `src/store/store.ts` to include:

```typescript
import { create } from 'zustand';
import { devtools, persist, immer } from 'zustand/middleware';
import { createUserSlice, UserSlice } from './slices/userSlice';
import { createTaskSlice, TaskSlice } from './slices/taskSlice';
import { createUISlice, UISlice } from './slices/uiSlice';

export type RootStore = UserSlice & TaskSlice & UISlice;

// TODO: Create the store with all three middleware
// Order: devtools(persist(immer(...)))
// Name: 'TaskFlow Store'
// Persist key: 'taskflow-storage'
// Partialize: only persist user, tasks, and theme
```

<details>
<summary>Click for Solution</summary>

```typescript
import { create } from 'zustand';
import { devtools, persist, createJSONStorage, immer } from 'zustand/middleware';
import { createUserSlice, UserSlice } from './slices/userSlice';
import { createTaskSlice, TaskSlice } from './slices/taskSlice';
import { createUISlice, UISlice } from './slices/uiSlice';

export type RootStore = UserSlice & TaskSlice & UISlice;

export const useStore = create<RootStore>()(
  devtools(
    persist(
      immer((set, get, store) => ({
        ...createUserSlice(set, get, store),
        ...createTaskSlice(set, get, store),
        ...createUISlice(set, get, store),
      })),
      {
        name: 'taskflow-storage',
        storage: createJSONStorage(() => localStorage),
        partialize: (state) => ({
          user: state.user,
          tasks: state.tasks,
          taskIds: state.taskIds,
          theme: state.theme,
          sidebarOpen: state.sidebarOpen,
        }),
      }
    ),
    { name: 'TaskFlow Store' }
  )
);
```
</details>

## 📝 Task 2: Update Slices to Use Immer

Update `src/store/slices/userSlice.ts` to use immer syntax:

```typescript
// TODO: Convert the slice to use immer's mutable syntax
// Instead of spreading objects, mutate the state directly
```

<details>
<summary>Click for Solution</summary>

```typescript
import { StateCreator } from 'zustand';

export interface User {
  id: string;
  name: string;
  email: string;
  role: 'admin' | 'user';
}

export interface UserSlice {
  user: User | null;
  isLoading: boolean;
  setUser: (user: User) => void;
  clearUser: () => void;
  fetchUser: (id: string) => Promise<void>;
}

export const createUserSlice: StateCreator<UserSlice> = (set) => ({
  user: null,
  isLoading: false,
  setUser: (user) =>
    set((state) => {
      state.user = user;
    }),
  clearUser: () =>
    set((state) => {
      state.user = null;
    }),
  fetchUser: async (id: string) => {
    set((state) => {
      state.isLoading = true;
    });
    try {
      await new Promise((resolve) => setTimeout(resolve, 500));
      const user: User = {
        id,
        name: `User ${id}`,
        email: `user${id}@example.com`,
        role: 'user',
      };
      set((state) => {
        state.user = user;
        state.isLoading = false;
      });
    } catch {
      set((state) => {
        state.isLoading = false;
      });
    }
  },
});
```
</details>

## ✅ Verification Steps

1. **Run the application**:
   ```bash
   npx vite
   ```

2. **Test devtools**:
   - Open Redux DevTools
   - Verify "TaskFlow Store" appears
   - Actions should be logged

3. **Test persistence**:
   - Make some changes (add tasks, change theme)
   - Reload the page
   - State should be restored

4. **Test immer**:
   - Verify mutable syntax works correctly
   - State updates should be immutable

## 💡 Extension Challenge

Add a `logger` middleware (custom or built-in) to log state changes.

---

# Lab 2.3: Persistence with Migrations

## 🎯 Objective

Implement versioned persistence with migrations for schema changes.

## 📋 Prerequisites

- Lab 2.2 completed
- Understanding of versioning and migrations

## 📝 Task 1: Define Initial State Schema (v0)

In `src/store/store.ts`, modify the persist configuration:

```typescript
// TODO: Add version: 0 to the persist configuration
// The initial schema has:
// - user: { name, email } (no role)
// - tasks: array (not normalized)
// - theme: string
```

<details>
<summary>Click for Solution</summary>

```typescript
// Version 0 schema (initial)
// User: { name: string, email: string }
// Tasks: Task[] (array, not normalized)
// Theme: string

persist(
  // store config
  {
    name: 'taskflow-storage',
    version: 0, // Initial version
    // ... other options
  }
)
```
</details>

## 📝 Task 2: Update Schema to v1

Update the persist configuration to version 1 with migration:

```typescript
// TODO: Update version to 1
// Migration from v0 to v1:
// - User: add role property (default 'user')
// - Tasks: normalize from array to Record + ids
// - Theme: unchanged
```

<details>
<summary>Click for Solution</summary>

```typescript
// Version 1 schema
// User: { name: string, email: string, role: 'admin' | 'user' }
// Tasks: Record<string, Task> + taskIds: string[]
// Theme: string

persist(
  // store config
  {
    name: 'taskflow-storage',
    version: 1,
    migrate: (persistedState: any, version: number) => {
      if (version === 0) {
        // Migrate from v0 to v1
        const state = persistedState;
        
        // Add role to user
        if (state.user) {
          state.user.role = 'user';
        }

        // Normalize tasks from array to Record + ids
        if (Array.isArray(state.tasks)) {
          const tasksMap: Record<string, Task> = {};
          const taskIds: string[] = [];
          for (const task of state.tasks) {
            tasksMap[task.id] = task;
            taskIds.push(task.id);
          }
          state.tasks = tasksMap;
          state.taskIds = taskIds;
        }

        return state;
      }
      return persistedState;
    },
    // ... other options
  }
)
```
</details>

## 📝 Task 3: Handle Migration Errors

Add error handling for migration:

```typescript
// TODO: Add onRehydrateStorage to handle errors
// Log success or failure
// If migration fails, reset to default state
```

<details>
<summary>Click for Solution</summary>

```typescript
persist(
  // store config
  {
    name: 'taskflow-storage',
    version: 1,
    migrate: (persistedState: any, version: number) => {
      try {
        if (version === 0) {
          // Migration logic...
          return migratedState;
        }
        return persistedState;
      } catch (error) {
        console.error('Migration failed:', error);
        // Return default state
        return {
          user: null,
          tasks: {},
          taskIds: [],
          theme: 'light',
          sidebarOpen: true,
        };
      }
    },
    onRehydrateStorage: () => (state, error) => {
      if (error) {
        console.error('Hydration failed:', error);
      } else {
        console.log('Hydration successful:', state);
      }
    },
  }
)
```
</details>

## ✅ Verification Steps

1. **Test migration**:
   - Add data to the store (v0 schema)
   - Update the store to v1
   - Reload page
   - Verify data is migrated correctly

2. **Test error handling**:
   - Corrupt localStorage data
   - Reload page
   - Verify fallback state is used

3. **Test persistence**:
   - Make changes
   - Reload page
   - Verify state is restored

## 💡 Extension Challenge

Add a v2 migration that adds a `createdAt` field to tasks.

---

# Lab 2.4: Derived State with Reselect

## 🎯 Objective

Implement memoized selectors using Reselect for expensive computations.

## 📋 Prerequisites

- Lab 2.1 completed
- Understanding of Reselect

## 📝 Task 1: Install Reselect

```bash
npm install reselect
```

## 📝 Task 2: Create Selectors

Create `src/store/selectors/taskSelectors.ts`:

```typescript
import { createSelector } from 'reselect';
import { RootStore } from '../store';

// TODO: Create base selectors
// - selectTasks
// - selectTaskIds
// - selectFilter
// - selectSearchQuery

// TODO: Create memoized selectors
// - selectFilteredTasks: filters by status and search
// - selectTaskStats: returns { total, completed, active, highPriority }
// - selectTasksByPriority: returns { high, medium, low }
// - selectOverdueTasks: returns tasks with due date in the past
```

<details>
<summary>Click for Solution</summary>

```typescript
import { createSelector } from 'reselect';
import { RootStore } from '../store';

// Base selectors
export const selectTasks = (state: RootStore) => state.tasks;
export const selectTaskIds = (state: RootStore) => state.taskIds;
export const selectFilter = (state: RootStore) => state.filter;
export const selectSearchQuery = (state: RootStore) => state.searchQuery || '';

// Memoized selector: filtered tasks
export const selectFilteredTasks = createSelector(
  [selectTasks, selectTaskIds, selectFilter, selectSearchQuery],
  (tasks, taskIds, filter, searchQuery) => {
    let result = taskIds.map(id => tasks[id]).filter(Boolean);

    // Apply status filter
    if (filter === 'active') {
      result = result.filter(t => !t.completed);
    } else if (filter === 'completed') {
      result = result.filter(t => t.completed);
    }

    // Apply search filter
    if (searchQuery.trim()) {
      const query = searchQuery.toLowerCase().trim();
      result = result.filter(t =>
        t.title.toLowerCase().includes(query)
      );
    }

    return result;
  }
);

// Memoized selector: task stats
export const selectTaskStats = createSelector(
  [selectTasks, selectTaskIds],
  (tasks, taskIds) => {
    const allTasks = taskIds.map(id => tasks[id]).filter(Boolean);
    const total = allTasks.length;
    const completed = allTasks.filter(t => t.completed).length;
    return {
      total,
      completed,
      active: total - completed,
    };
  }
);

// Memoized selector: tasks by priority
export const selectTasksByPriority = createSelector(
  [selectTasks, selectTaskIds],
  (tasks, taskIds) => {
    const allTasks = taskIds.map(id => tasks[id]).filter(Boolean);
    const high = allTasks.filter(t => t.priority === 'high');
    const medium = allTasks.filter(t => t.priority === 'medium');
    const low = allTasks.filter(t => t.priority === 'low');
    return { high, medium, low };
  }
);

// Memoized selector: overdue tasks
export const selectOverdueTasks = createSelector(
  [selectTasks, selectTaskIds],
  (tasks, taskIds) => {
    const now = new Date();
    return taskIds
      .map(id => tasks[id])
      .filter(t =>
        t && t.dueDate && new Date(t.dueDate) < now && !t.completed
      );
  }
);
```
</details>

## 📝 Task 3: Use Selectors in Components

Create `src/components/TaskDashboard.tsx`:

```tsx
import React from 'react';
import { useStore } from '../store/store';
import {
  selectFilteredTasks,
  selectTaskStats,
  selectTasksByPriority,
  selectOverdueTasks,
} from '../store/selectors/taskSelectors';

// TODO: Create a dashboard component that:
// 1. Uses all the memoized selectors
// 2. Displays stats
// 3. Displays filtered tasks
// 4. Displays overdue tasks
// 5. Displays tasks by priority
```

<details>
<summary>Click for Solution</summary>

```tsx
import React from 'react';
import { useStore } from '../store/store';
import {
  selectFilteredTasks,
  selectTaskStats,
  selectTasksByPriority,
  selectOverdueTasks,
} from '../store/selectors/taskSelectors';

export function TaskDashboard() {
  const filteredTasks = useStore(selectFilteredTasks);
  const stats = useStore(selectTaskStats);
  const byPriority = useStore(selectTasksByPriority);
  const overdue = useStore(selectOverdueTasks);

  return (
    <div style={{ padding: '20px' }}>
      <h1>Task Dashboard</h1>

      <div style={{ display: 'flex', gap: '20px', marginBottom: '20px' }}>
        <div style={{ border: '1px solid #ddd', padding: '10px', borderRadius: '4px' }}>
          <h3>Stats</h3>
          <p>Total: {stats.total}</p>
          <p>Completed: {stats.completed}</p>
          <p>Active: {stats.active}</p>
        </div>

        <div style={{ border: '1px solid #ddd', padding: '10px', borderRadius: '4px' }}>
          <h3>By Priority</h3>
          <p>High: {byPriority.high.length}</p>
          <p>Medium: {byPriority.medium.length}</p>
          <p>Low: {byPriority.low.length}</p>
        </div>

        <div style={{ border: '1px solid #ddd', padding: '10px', borderRadius: '4px' }}>
          <h3>Overdue</h3>
          <p>{overdue.length} tasks</p>
        </div>
      </div>

      <div>
        <h3>Filtered Tasks ({filteredTasks.length})</h3>
        <ul>
          {filteredTasks.map(task => (
            <li key={task.id}>
              {task.title} - {task.priority || 'No priority'}
            </li>
          ))}
        </ul>
      </div>
    </div>
  );
}
```
</details>

## ✅ Verification Steps

1. **Run the application**:
   ```bash
   npx vite
   ```

2. **Verify memoization**:
   - Add a render counter to the component
   - Verify component only re-renders when selected data changes

3. **Test selectors**:
   - Add tasks with different priorities
   - Filter tasks
   - Verify stats update correctly

## 💡 Extension Challenge

Add a `createSelector` for tasks grouped by status (active/completed/overdue).

---

# Lab 3.1: Async Data Fetching

## 🎯 Objective

Implement asynchronous data fetching with loading, error, and retry states.

## 📋 Prerequisites

- Understanding of async/await
- Knowledge of loading/error states

## 📝 Task 1: Create the Async Store

Create `src/store/asyncStore.ts`:

```typescript
import { create } from 'zustand';

interface Post {
  id: number;
  title: string;
  body: string;
  userId: number;
}

interface AsyncStore {
  posts: Post[];
  loading: boolean;
  error: string | null;
  fetchPosts: (retries?: number) => Promise<void>;
  clearPosts: () => void;
  clearError: () => void;
}

// TODO: Create the store with:
// 1. fetchPosts: Fetches from https://jsonplaceholder.typicode.com/posts
// 2. Loading state management
// 3. Error handling
// 4. Retry logic with exponential backoff
// 5. AbortController for cancellation
```

<details>
<summary>Click for Solution</summary>

```typescript
import { create } from 'zustand';

interface Post {
  id: number;
  title: string;
  body: string;
  userId: number;
}

interface AsyncStore {
  posts: Post[];
  loading: boolean;
  error: string | null;
  controller: AbortController | null;
  fetchPosts: (retries?: number) => Promise<void>;
  clearPosts: () => void;
  clearError: () => void;
  cancelFetch: () => void;
}

const MAX_RETRIES = 3;
const BASE_DELAY = 1000;

export const useAsyncStore = create<AsyncStore>((set, get) => ({
  posts: [],
  loading: false,
  error: null,
  controller: null,

  fetchPosts: async (retries = 0) => {
    // Cancel any existing request
    const currentController = get().controller;
    if (currentController) {
      currentController.abort();
    }

    const controller = new AbortController();
    set({ controller, loading: true, error: null });

    try {
      const response = await fetch('https://jsonplaceholder.typicode.com/posts', {
        signal: controller.signal,
      });

      if (!response.ok) {
        throw new Error(`HTTP ${response.status}: ${response.statusText}`);
      }

      const data = await response.json();
      set({ posts: data, loading: false, controller: null });
    } catch (error) {
      if (error instanceof DOMException && error.name === 'AbortError') {
        console.log('Request cancelled');
        set({ controller: null });
        return;
      }

      // Retry logic
      if (retries < MAX_RETRIES) {
        const delay = BASE_DELAY * Math.pow(2, retries);
        console.log(`Retrying in ${delay}ms (attempt ${retries + 1}/${MAX_RETRIES})`);
        await new Promise(resolve => setTimeout(resolve, delay));
        await get().fetchPosts(retries + 1);
        return;
      }

      set({
        error: error instanceof Error ? error.message : 'Unknown error',
        loading: false,
        controller: null,
      });
    }
  },

  clearPosts: () => set({ posts: [], loading: false, error: null }),

  clearError: () => set({ error: null }),

  cancelFetch: () => {
    const controller = get().controller;
    if (controller) {
      controller.abort();
      set({ controller: null, loading: false });
    }
  },
}));
```
</details>

## 📝 Task 2: Create the Async Component

Create `src/components/AsyncDataFetcher.tsx`:

```tsx
import React, { useEffect } from 'react';
import { useAsyncStore } from '../store/asyncStore';

// TODO: Create a component that:
// 1. Fetches data on mount
// 2. Shows loading state
// 3. Shows error state with retry button
// 4. Shows data when loaded
// 5. Has a cancel button that cancels the request
```

<details>
<summary>Click for Solution</summary>

```tsx
import React, { useEffect } from 'react';
import { useAsyncStore } from '../store/asyncStore';

export function AsyncDataFetcher() {
  const { posts, loading, error, fetchPosts, clearPosts, clearError, cancelFetch } = useAsyncStore();

  useEffect(() => {
    fetchPosts();
    return () => {
      cancelFetch();
    };
  }, []);

  if (loading) {
    return (
      <div style={{ textAlign: 'center', padding: '40px' }}>
        <div>Loading posts...</div>
        <button onClick={cancelFetch}>Cancel</button>
      </div>
    );
  }

  if (error) {
    return (
      <div style={{ textAlign: 'center', padding: '40px', color: 'red' }}>
        <h3>Error: {error}</h3>
        <button onClick={() => { clearError(); fetchPosts(); }}>Retry</button>
        <button onClick={clearPosts}>Clear</button>
      </div>
    );
  }

  if (posts.length === 0) {
    return <div style={{ textAlign: 'center', padding: '40px' }}>No posts loaded</div>;
  }

  return (
    <div style={{ padding: '20px' }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '20px' }}>
        <h2>Posts ({posts.length})</h2>
        <button onClick={clearPosts}>Clear</button>
      </div>
      <ul>
        {posts.slice(0, 10).map(post => (
          <li key={post.id} style={{ marginBottom: '20px', padding: '10px', border: '1px solid #eee' }}>
            <h3>{post.title}</h3>
            <p>{post.body}</p>
          </li>
        ))}
      </ul>
    </div>
  );
}
```
</details>

## ✅ Verification Steps

1. **Run the application**:
   ```bash
   npx vite
   ```

2. **Test loading state**:
   - Should show loading indicator
   - Cancel button should work

3. **Test error state**:
   - Disable network in DevTools
   - Should show error after retries
   - Retry button should work

4. **Test success state**:
   - Data should display
   - Clear button should work

## 💡 Extension Challenge

Add a page parameter to fetchPosts and implement pagination.

---

# Lab 3.2: Request Deduplication

## 🎯 Objective

Implement request deduplication to prevent duplicate concurrent requests.

## 📋 Prerequisites

- Lab 3.1 completed
- Understanding of race conditions

## 📝 Task 1: Create the Deduplicated Store

Create `src/store/dedupStore.ts`:

```typescript
import { create } from 'zustand';

interface User {
  id: number;
  name: string;
  email: string;
}

interface DedupStore {
  users: Record<number, User>;
  loading: Record<number, boolean>;
  error: Record<number, string | null>;
  pendingRequests: Map<string, Promise<User>>;
  fetchUser: (id: number) => Promise<User>;
  clearUser: (id: number) => void;
}

// TODO: Create a store that:
// 1. Tracks pending requests in a Map
// 2. Returns the same promise for duplicate requests
// 3. Cleans up pending requests after completion
// 4. Handles errors
```

<details>
<summary>Click for Solution</summary>

```typescript
import { create } from 'zustand';

interface User {
  id: number;
  name: string;
  email: string;
}

interface DedupStore {
  users: Record<number, User>;
  loading: Record<number, boolean>;
  error: Record<number, string | null>;
  pendingRequests: Map<string, Promise<User>>;
  fetchUser: (id: number) => Promise<User>;
  clearUser: (id: number) => void;
}

export const useDedupStore = create<DedupStore>((set, get) => ({
  users: {},
  loading: {},
  error: {},
  pendingRequests: new Map(),

  fetchUser: async (id: number) => {
    const key = `user-${id}`;

    // Check if request is already in flight
    const pending = get().pendingRequests.get(key);
    if (pending) {
      console.log(`📡 Request already in flight for user ${id}`);
      return pending;
    }

    // Set loading state
    set((state) => ({
      loading: { ...state.loading, [id]: true },
      error: { ...state.error, [id]: null },
    }));

    // Create the request promise
    const promise = (async () => {
      try {
        const response = await fetch(`https://jsonplaceholder.typicode.com/users/${id}`);
        if (!response.ok) {
          throw new Error(`HTTP ${response.status}`);
        }
        const user = await response.json();

        // Update state with success
        set((state) => ({
          users: { ...state.users, [id]: user },
          loading: { ...state.loading, [id]: false },
          error: { ...state.error, [id]: null },
        }));

        return user;
      } catch (error) {
        // Update state with error
        set((state) => ({
          loading: { ...state.loading, [id]: false },
          error: {
            ...state.error,
            [id]: error instanceof Error ? error.message : 'Unknown error',
          },
        }));
        throw error;
      } finally {
        // Clean up pending request
        set((state) => {
          const newMap = new Map(state.pendingRequests);
          newMap.delete(key);
          return { pendingRequests: newMap };
        });
      }
    })();

    // Store the promise
    set((state) => ({
      pendingRequests: new Map(state.pendingRequests).set(key, promise),
    }));

    return promise;
  },

  clearUser: (id: number) => {
    set((state) => {
      const { [id]: removed, ...remainingUsers } = state.users;
      const { [id]: loadingRemoved, ...remainingLoading } = state.loading;
      const { [id]: errorRemoved, ...remainingError } = state.error;
      return {
        users: remainingUsers,
        loading: remainingLoading,
        error: remainingError,
      };
    });
  },
}));
```
</details>

## 📝 Task 2: Create the Test Component

Create `src/components/DedupTest.tsx`:

```tsx
import React, { useState } from 'react';
import { useDedupStore } from '../store/dedupStore';

// TODO: Create a component that:
// 1. Fetches multiple users simultaneously
// 2. Shows deduplication in action
// 3. Displays loading states per user
// 4. Shows user data when loaded
```

<details>
<summary>Click for Solution</summary>

```tsx
import React, { useState } from 'react';
import { useDedupStore } from '../store/dedupStore';

export function DedupTest() {
  const [userIds, setUserIds] = useState<number[]>([]);
  const { users, loading, error, fetchUser, clearUser } = useDedupStore();

  const handleFetch = () => {
    // Fetch users 1, 2, 3 with duplicates (1 and 3 requested twice)
    const ids = [1, 2, 3, 1, 3, 4];
    setUserIds(ids);
    for (const id of ids) {
      fetchUser(id).catch(() => {});
    }
  };

  const handleClear = () => {
    for (const id of userIds) {
      clearUser(id);
    }
    setUserIds([]);
  };

  return (
    <div style={{ padding: '20px' }}>
      <h2>Request Deduplication Test</h2>
      <p>
        <button onClick={handleFetch}>Fetch Users (with duplicates)</button>
        <button onClick={handleClear} style={{ marginLeft: '10px' }}>Clear</button>
      </p>
      <p style={{ fontSize: '14px', color: '#666' }}>
        This fetches users 1, 2, 3, 1, 3, 4. Users 1 and 3 should only be fetched once.
      </p>
      <div style={{ marginTop: '20px' }}>
        {Array.from(new Set(userIds)).map(id => (
          <div key={id} style={{ padding: '10px', marginBottom: '10px', border: '1px solid #eee' }}>
            <strong>User {id}:</strong>
            {loading[id] ? (
              <span style={{ marginLeft: '10px', color: '#ff9800' }}>Loading...</span>
            ) : error[id] ? (
              <span style={{ marginLeft: '10px', color: 'red' }}>Error: {error[id]}</span>
            ) : users[id] ? (
              <span style={{ marginLeft: '10px' }}>
                {users[id].name} ({users[id].email})
              </span>
            ) : (
              <span style={{ marginLeft: '10px', color: '#999' }}>Not fetched</span>
            )}
          </div>
        ))}
      </div>
    </div>
  );
}
```
</details>

## ✅ Verification Steps

1. **Run the application**:
   ```bash
   npx vite
   ```

2. **Test deduplication**:
   - Click "Fetch Users"
   - Open Network tab
   - Verify duplicate requests are deduplicated

3. **Test loading states**:
   - Verify per-user loading states
   - Verify users display correctly

4. **Test error handling**:
   - Disable network
   - Click fetch
   - Verify error states

## 💡 Extension Challenge

Add a `fetchAll` method that fetches multiple users with deduplication.

---

# Lab 3.3: API Integration

## 🎯 Objective

Integrate Zustand with a REST API using a service layer.

## 📋 Prerequisites

- Understanding of API integration patterns
- Knowledge of service layer architecture

## 📝 Task 1: Create the API Service

Create `src/services/apiService.ts`:

```typescript
// TODO: Create an API service with:
// 1. Base URL configuration
// 2. GET, POST, PUT, DELETE methods
// 3. Error handling
// 4. Request/response interceptors
// 5. Token injection for authenticated requests
```

<details>
<summary>Click for Solution</summary>

```typescript
// src/services/apiService.ts
const BASE_URL = 'https://jsonplaceholder.typicode.com';

export interface ApiResponse<T> {
  data: T;
  status: number;
  message?: string;
}

export class ApiError extends Error {
  status: number;
  data?: any;

  constructor(message: string, status: number, data?: any) {
    super(message);
    this.status = status;
    this.data = data;
    this.name = 'ApiError';
  }
}

class ApiService {
  private baseURL: string;
  private token: string | null = null;

  constructor(baseURL: string) {
    this.baseURL = baseURL;
  }

  setToken(token: string) {
    this.token = token;
  }

  clearToken() {
    this.token = null;
  }

  private async request<T>(
    endpoint: string,
    options: RequestInit = {}
  ): Promise<T> {
    const url = `${this.baseURL}${endpoint}`;
    const headers: Record<string, string> = {
      'Content-Type': 'application/json',
    };

    if (this.token) {
      headers['Authorization'] = `Bearer ${this.token}`;
    }

    const response = await fetch(url, {
      ...options,
      headers: { ...headers, ...(options.headers as Record<string, string>) },
    });

    const data = await response.json();

    if (!response.ok) {
      throw new ApiError(
        data.message || `Request failed with status ${response.status}`,
        response.status,
        data
      );
    }

    return data;
  }

  async get<T>(endpoint: string): Promise<T> {
    return this.request<T>(endpoint, { method: 'GET' });
  }

  async post<T>(endpoint: string, body?: any): Promise<T> {
    return this.request<T>(endpoint, {
      method: 'POST',
      body: body ? JSON.stringify(body) : undefined,
    });
  }

  async put<T>(endpoint: string, body?: any): Promise<T> {
    return this.request<T>(endpoint, {
      method: 'PUT',
      body: body ? JSON.stringify(body) : undefined,
    });
  }

  async patch<T>(endpoint: string, body?: any): Promise<T> {
    return this.request<T>(endpoint, {
      method: 'PATCH',
      body: body ? JSON.stringify(body) : undefined,
    });
  }

  async delete<T>(endpoint: string): Promise<T> {
    return this.request<T>(endpoint, { method: 'DELETE' });
  }
}

export const apiService = new ApiService(BASE_URL);
```
</details>

## 📝 Task 2: Create the Service Layer

Create `src/services/taskService.ts`:

```typescript
import { apiService, ApiError } from './apiService';

// TODO: Define Task and CreateTaskInput interfaces

// TODO: Create a task service with:
// - getAll: () => Promise<Task[]>
// - getById: (id: string) => Promise<Task>
// - create: (data: CreateTaskInput) => Promise<Task>
// - update: (id: string, data: Partial<Task>) => Promise<Task>
// - delete: (id: string) => Promise<void>
```

<details>
<summary>Click for Solution</summary>

```typescript
import { apiService, ApiError } from './apiService';

export interface Task {
  id: number;
  title: string;
  body: string;
  userId: number;
}

export interface CreateTaskInput {
  title: string;
  body: string;
  userId: number;
}

export interface UpdateTaskInput extends Partial<CreateTaskInput> {}

export class TaskService {
  private basePath = '/posts';

  async getAll(): Promise<Task[]> {
    try {
      return await apiService.get<Task[]>(this.basePath);
    } catch (error) {
      if (error instanceof ApiError) {
        console.error(`Failed to fetch tasks: ${error.message}`);
      }
      throw error;
    }
  }

  async getById(id: number): Promise<Task> {
    try {
      return await apiService.get<Task>(`${this.basePath}/${id}`);
    } catch (error) {
      if (error instanceof ApiError) {
        console.error(`Failed to fetch task ${id}: ${error.message}`);
      }
      throw error;
    }
  }

  async create(data: CreateTaskInput): Promise<Task> {
    try {
      return await apiService.post<Task>(this.basePath, data);
    } catch (error) {
      if (error instanceof ApiError) {
        console.error(`Failed to create task: ${error.message}`);
      }
      throw error;
    }
  }

  async update(id: number, data: UpdateTaskInput): Promise<Task> {
    try {
      return await apiService.put<Task>(`${this.basePath}/${id}`, data);
    } catch (error) {
      if (error instanceof ApiError) {
        console.error(`Failed to update task ${id}: ${error.message}`);
      }
      throw error;
    }
  }

  async delete(id: number): Promise<void> {
    try {
      await apiService.delete(`${this.basePath}/${id}`);
    } catch (error) {
      if (error instanceof ApiError) {
        console.error(`Failed to delete task ${id}: ${error.message}`);
      }
      throw error;
    }
  }
}

export const taskService = new TaskService();
```
</details>

## 📝 Task 3: Create the Task Store

Create `src/store/taskServiceStore.ts`:

```typescript
import { create } from 'zustand';
import { Task, taskService, CreateTaskInput } from '../services/taskService';

// TODO: Create a store that:
// 1. Uses the TaskService for API calls
// 2. Manages loading and error states
// 3. Has CRUD operations
// 4. Implements optimistic updates
```

<details>
<summary>Click for Solution</summary>

```typescript
import { create } from 'zustand';
import { Task, taskService, CreateTaskInput } from '../services/taskService';

interface TaskStore {
  tasks: Record<number, Task>;
  taskIds: number[];
  loading: {
    fetch: boolean;
    create: boolean;
    update: Record<number, boolean>;
    delete: Record<number, boolean>;
  };
  error: {
    fetch: string | null;
    create: string | null;
    update: Record<number, string | null>;
    delete: Record<number, string | null>;
  };
  fetchTasks: () => Promise<void>;
  createTask: (data: CreateTaskInput) => Promise<Task>;
  updateTask: (id: number, data: Partial<Task>) => Promise<Task>;
  deleteTask: (id: number) => Promise<void>;
  clearTasks: () => void;
  clearError: () => void;
}

export const useTaskServiceStore = create<TaskStore>((set, get) => ({
  tasks: {},
  taskIds: [],
  loading: { fetch: false, create: false, update: {}, delete: {} },
  error: { fetch: null, create: null, update: {}, delete: {} },

  fetchTasks: async () => {
    set({
      loading: { ...get().loading, fetch: true },
      error: { ...get().error, fetch: null },
    });

    try {
      const tasks = await taskService.getAll();
      const tasksMap: Record<number, Task> = {};
      const ids: number[] = [];
      for (const task of tasks) {
        tasksMap[task.id] = task;
        ids.push(task.id);
      }
      set({
        tasks: tasksMap,
        taskIds: ids,
        loading: { ...get().loading, fetch: false },
      });
    } catch (error) {
      set({
        loading: { ...get().loading, fetch: false },
        error: {
          ...get().error,
          fetch: error instanceof Error ? error.message : 'Unknown error',
        },
      });
    }
  },

  createTask: async (data: CreateTaskInput) => {
    set({
      loading: { ...get().loading, create: true },
      error: { ...get().error, create: null },
    });

    try {
      // Optimistic update with temporary ID
      const tempId = Date.now();
      const optimisticTask: Task = {
        ...data,
        id: tempId,
      };
      set((state) => ({
        tasks: { ...state.tasks, [tempId]: optimisticTask },
        taskIds: [...state.taskIds, tempId],
      }));

      const task = await taskService.create(data);

      // Replace optimistic with real
      set((state) => {
        const { [tempId]: removed, ...remaining } = state.tasks;
        return {
          tasks: { ...remaining, [task.id]: task },
          taskIds: state.taskIds.map(id => id === tempId ? task.id : id),
          loading: { ...state.loading, create: false },
        };
      });

      return task;
    } catch (error) {
      // Rollback optimistic update
      set((state) => {
        const { [Date.now()]: removed, ...remaining } = state.tasks;
        return {
          tasks: remaining,
          taskIds: state.taskIds.filter(id => id !== Date.now()),
          loading: { ...state.loading, create: false },
          error: {
            ...state.error,
            create: error instanceof Error ? error.message : 'Unknown error',
          },
        };
      });
      throw error;
    }
  },

  // ... updateTask and deleteTask similarly

  clearTasks: () => {
    set({ tasks: {}, taskIds: [] });
  },

  clearError: () => {
    set({ error: { fetch: null, create: null, update: {}, delete: {} } });
  },
}));
```
</details>

## ✅ Verification Steps

1. **Run the application**:
   ```bash
   npx vite
   ```

2. **Test CRUD operations**:
   - Fetch tasks
   - Create a task
   - Update a task
   - Delete a task

3. **Test optimistic updates**:
   - Create a task and verify it appears immediately
   - Verify rollback on error

4. **Test error handling**:
   - Disable network
   - Try operations and verify error states

## 💡 Extension Challenge

Add a GraphQL client and create a GraphQL version of the store.

---

# Lab 3.4: Custom Middleware

## 🎯 Objective

Build custom middleware for logging, validation, and performance monitoring.

## 📋 Prerequisites

- Understanding of middleware signatures
- Knowledge of higher-order functions

## 📝 Task 1: Create Logging Middleware

Create `src/middleware/logger.ts`:

```typescript
import { StateCreator } from 'zustand';

// TODO: Create a logging middleware that:
// 1. Logs the action name and args
// 2. Logs state before and after the update
// 3. Logs the time taken for the update
// 4. Has options for:
//    - enabled: boolean
//    - logActions: boolean
//    - logState: boolean
//    - collapsed: boolean
// 5. Uses colors in the console
// 6. Only logs in development mode by default
```

<details>
<summary>Click for Solution</summary>

```typescript
import { StateCreator } from 'zustand';

interface LoggerOptions {
  enabled?: boolean;
  logActions?: boolean;
  logState?: boolean;
  collapsed?: boolean;
}

export const createLogger = <T extends object>(
  options: LoggerOptions = {}
): ((config: StateCreator<T, [], []>) => StateCreator<T, [], []>) => {
  const {
    enabled = process.env.NODE_ENV === 'development',
    logActions = true,
    logState = true,
    collapsed = true,
  } = options;

  return (config: StateCreator<T, [], []>) => (set, get, store) => {
    if (!enabled) {
      return config(set, get, store);
    }

    let actionCount = 0;

    const wrappedSet = (args: any) => {
      const prevState = get();
      const actionName = typeof args === 'function' ? 'functional' : 'object';
      const startTime = performance.now();

      if (logActions) {
        const groupName = `🔍 ${actionName} #${++actionCount}`;
        if (collapsed) {
          console.groupCollapsed(groupName);
        } else {
          console.group(groupName);
        }
      }

      if (logState) {
        console.log('📊 Before:', prevState);
      }

      set(args);

      const nextState = get();
      const duration = performance.now() - startTime;

      if (logState) {
        console.log('📊 After:', nextState);
      }

      console.log(`⏱️ Duration: ${duration.toFixed(2)}ms`);

      if (logActions) {
        console.groupEnd();
      }
    };

    return config(wrappedSet, get, store);
  };
};
```
</details>

## 📝 Task 2: Create Validation Middleware

Create `src/middleware/validator.ts`:

```typescript
import { StateCreator } from 'zustand';

// TODO: Create a validation middleware that:
// 1. Validates state before updates
// 2. Accepts rules like: { field: 'email', validate: (value) => value.includes('@'), message: 'Invalid email' }
// 3. Throws an error if validation fails
// 4. Has strict mode (throw) and warning mode (log only)
```

<details>
<summary>Click for Solution</summary>

```typescript
import { StateCreator } from 'zustand';

interface ValidationRule<T> {
  field: keyof T;
  validate: (value: any, state: T) => boolean;
  message: string;
}

interface ValidatorOptions {
  strict?: boolean;
}

export const createValidator = <T extends object>(
  rules: ValidationRule<T>[],
  options: ValidatorOptions = {}
): ((config: StateCreator<T, [], []>) => StateCreator<T, [], []>) => {
  const { strict = true } = options;

  return (config: StateCreator<T, [], []>) => (set, get, store) => {
    const wrappedSet = (args: any) => {
      const currentState = get();
      const nextState = typeof args === 'function'
        ? args(currentState)
        : { ...currentState, ...args };

      const errors: string[] = [];

      for (const rule of rules) {
        const value = nextState[rule.field];
        if (!rule.validate(value, nextState)) {
          errors.push(`${String(rule.field)}: ${rule.message}`);
        }
      }

      if (errors.length > 0) {
        const message = `Validation failed:\n${errors.join('\n')}`;
        if (strict) {
          throw new Error(message);
        } else {
          console.warn('⚠️', message);
        }
      }

      set(args);
    };

    return config(wrappedSet, get, store);
  };
};
```
</details>

## 📝 Task 3: Create Performance Monitoring Middleware

Create `src/middleware/performance.ts`:

```typescript
import { StateCreator } from 'zustand';

// TODO: Create a performance monitoring middleware that:
// 1. Measures update duration
// 2. Logs slow updates (> threshold)
// 3. Tracks total update count
// 4. Sends metrics to a callback function
// 5. Has sampling to reduce overhead in production
```

<details>
<summary>Click for Solution</summary>

```typescript
import { StateCreator } from 'zustand';

interface PerformanceOptions {
  enabled?: boolean;
  slowThreshold?: number;
  sampleRate?: number;
  onMetric?: (metric: { action: string; duration: number; stateSize: number; timestamp: number }) => void;
  onSlowUpdate?: (metric: { action: string; duration: number; stateSize: number; timestamp: number }) => void;
}

export const createPerformanceMonitor = <T extends object>(
  options: PerformanceOptions = {}
): ((config: StateCreator<T, [], []>) => StateCreator<T, [], []>) => {
  const {
    enabled = process.env.NODE_ENV === 'production',
    slowThreshold = 50,
    sampleRate = 0.1,
    onMetric,
    onSlowUpdate,
  } = options;

  let updateCount = 0;

  return (config: StateCreator<T, [], []>) => (set, get, store) => {
    if (!enabled) {
      return config(set, get, store);
    }

    const wrappedSet = (args: any) => {
      const startTime = performance.now();
      const actionName = typeof args === 'function' ? 'functional' : 'object';

      set(args);

      const duration = performance.now() - startTime;
      const state = get();
      const stateSize = new Blob([JSON.stringify(state)]).size;
      updateCount++;

      // Sample
      if (Math.random() <= sampleRate) {
        const metric = {
          action: actionName,
          duration,
          stateSize,
          timestamp: Date.now(),
        };

        if (onMetric) {
          onMetric(metric);
        }

        if (duration > slowThreshold) {
          console.warn(`🐌 Slow update detected: ${duration.toFixed(2)}ms (${actionName})`);
          if (onSlowUpdate) {
            onSlowUpdate(metric);
          }
        }
      }
    };

    return config(wrappedSet, get, store);
  };
};
```
</details>

## ✅ Verification Steps

1. **Run the application**:
   ```bash
   npx vite
   ```

2. **Test logging middleware**:
   - Open console
   - Perform actions
   - Verify logs appear

3. **Test validation middleware**:
   - Add validation rules
   - Try invalid updates
   - Verify errors are thrown

4. **Test performance monitoring**:
   - Check console for slow updates
   - Check metrics callback

## 💡 Extension Challenge

Create an analytics middleware that tracks user actions and sends them to a service.

---

# Lab 4.1: Rendering Optimization

## 🎯 Objective

Optimize component rendering with fine-grained subscriptions and memoization.

## 📋 Prerequisites

- Understanding of React re-renders
- Knowledge of selectors

## 📝 Task 1: Create a Store with Multiple State Pieces

Create `src/store/optimizedStore.ts`:

```typescript
import { create } from 'zustand';

// TODO: Create a store with:
// - user: { id, name, email }
// - tasks: Task[]
// - loading: boolean
// - error: string | null
// - theme: 'light' | 'dark'
// - notifications: Notification[]
//
// The store should be inefficient so we can optimize it
```

<details>
<summary>Click for Solution</summary>

```typescript
import { create } from 'zustand';

interface User {
  id: string;
  name: string;
  email: string;
}

interface Task {
  id: string;
  title: string;
  completed: boolean;
}

interface Notification {
  id: string;
  message: string;
  read: boolean;
}

interface OptimizedStore {
  user: User | null;
  tasks: Record<string, Task>;
  taskIds: string[];
  loading: boolean;
  error: string | null;
  theme: 'light' | 'dark';
  notifications: Notification[];
  setUser: (user: User) => void;
  addTask: (task: Task) => void;
  toggleTask: (id: string) => void;
  setLoading: (loading: boolean) => void;
  setError: (error: string | null) => void;
  toggleTheme: () => void;
  addNotification: (message: string) => void;
  markNotificationRead: (id: string) => void;
}

export const useOptimizedStore = create<OptimizedStore>((set) => ({
  user: null,
  tasks: {},
  taskIds: [],
  loading: false,
  error: null,
  theme: 'light',
  notifications: [],

  setUser: (user) => set({ user }),
  addTask: (task) =>
    set((state) => ({
      tasks: { ...state.tasks, [task.id]: task },
      taskIds: [...state.taskIds, task.id],
    })),
  toggleTask: (id) =>
    set((state) => ({
      tasks: {
        ...state.tasks,
        [id]: { ...state.tasks[id], completed: !state.tasks[id].completed },
      },
    })),
  setLoading: (loading) => set({ loading }),
  setError: (error) => set({ error }),
  toggleTheme: () =>
    set((state) => ({
      theme: state.theme === 'light' ? 'dark' : 'light',
    })),
  addNotification: (message) =>
    set((state) => ({
      notifications: [
        ...state.notifications,
        { id: crypto.randomUUID(), message, read: false },
      ],
    })),
  markNotificationRead: (id) =>
    set((state) => ({
      notifications: state.notifications.map((n) =>
        n.id === id ? { ...n, read: true } : n
      ),
    })),
}));
```
</details>

## 📝 Task 2: Create Inefficient Components

Create `src/components/InefficientComponent.tsx`:

```tsx
import React from 'react';
import { useOptimizedStore } from '../store/optimizedStore';

// TODO: Create a component that subscribes to the entire store
// This should cause unnecessary re-renders
```

<details>
<summary>Click for Solution</summary>

```tsx
import React, { useRef } from 'react';
import { useOptimizedStore } from '../store/optimizedStore';

export function InefficientComponent() {
  const renderCount = useRef(0);
  renderCount.current++;

  // ❌ Subscribes to the entire store
  const state = useOptimizedStore();

  return (
    <div style={{ border: '2px solid red', padding: '20px', margin: '10px' }}>
      <h3>❌ Inefficient Component</h3>
      <p>Renders: {renderCount.current}</p>
      <p>Tasks: {state.taskIds.length}</p>
      <p>Theme: {state.theme}</p>
      <p>Notifications: {state.notifications.length}</p>
      <button onClick={() => state.addNotification('New notification')}>
        Add Notification
      </button>
    </div>
  );
}
```
</details>

## 📝 Task 3: Create Optimized Components

Create `src/components/OptimizedComponent.tsx`:

```tsx
import React from 'react';
import { useOptimizedStore } from '../store/optimizedStore';

// TODO: Create optimized components that:
// 1. Use focused selectors
// 2. Use useShallow for object selectors
// 3. Use memoized selectors
// 4. Show re-render count
```

<details>
<summary>Click for Solution</summary>

```tsx
import React, { useRef, memo } from 'react';
import { useOptimizedStore } from '../store/optimizedStore';
import { useShallow } from 'zustand/react/shallow';

// ✅ Component that only subscribes to task count
export function TaskCounter() {
  const renderCount = useRef(0);
  renderCount.current++;

  const taskCount = useOptimizedStore((state) => state.taskIds.length);

  return (
    <div style={{ border: '2px solid green', padding: '10px', margin: '5px' }}>
      <span>Tasks: {taskCount}</span>
      <span style={{ fontSize: '12px', color: '#666' }}> (renders: {renderCount.current})</span>
    </div>
  );
}

// ✅ Component with useShallow for object selectors
export function ThemeAndNotifications() {
  const renderCount = useRef(0);
  renderCount.current++;

  const { theme, notifications } = useOptimizedStore(
    useShallow((state) => ({
      theme: state.theme,
      notifications: state.notifications,
    }))
  );

  return (
    <div style={{ border: '2px solid blue', padding: '10px', margin: '5px' }}>
      <span>Theme: {theme}</span>
      <span style={{ marginLeft: '10px' }}>Notifications: {notifications.length}</span>
      <span style={{ fontSize: '12px', color: '#666', marginLeft: '10px' }}>
        (renders: {renderCount.current})
      </span>
    </div>
  );
}

// ✅ Memoized component for individual tasks
export const MemoizedTaskItem = memo(({ taskId }: { taskId: string }) => {
  const renderCount = useRef(0);
  renderCount.current++;

  const task = useOptimizedStore((state) => state.tasks[taskId]);

  if (!task) return null;

  return (
    <li style={{ padding: '5px', marginBottom: '2px', background: '#f5f5f5' }}>
      <span>{task.title}</span>
      <span style={{ fontSize: '12px', color: '#666', marginLeft: '10px' }}>
        (renders: {renderCount.current})
      </span>
    </li>
  );
});

// ✅ Component that renders tasks with memoized items
export function OptimizedTaskList() {
  const renderCount = useRef(0);
  renderCount.current++;

  const taskIds = useOptimizedStore((state) => state.taskIds);

  return (
    <div style={{ border: '2px solid purple', padding: '10px', margin: '5px' }}>
      <h4>Task List (renders: {renderCount.current})</h4>
      <ul>
        {taskIds.map((id) => (
          <MemoizedTaskItem key={id} taskId={id} />
        ))}
      </ul>
    </div>
  );
}
```
</details>

## ✅ Verification Steps

1. **Run the application**:
   ```bash
   npx vite
   ```

2. **Compare renders**:
   - Observe render counts
   - Add tasks and see which components re-render

3. **Verify optimization**:
   - Inefficient component re-renders on any change
   - Optimized components only re-render when needed

## 💡 Extension Challenge

Add React Profiler to measure and visualize render performance.

---

# Lab 4.2: State Normalization

## 🎯 Objective

Normalize nested state for efficient updates and lookups.

## 📋 Prerequisites

- Understanding of normalization
- Knowledge of performance optimization

## 📝 Task 1: Create Denormalized Store

Create `src/store/denormalizedStore.ts`:

```typescript
import { create } from 'zustand';

// TODO: Create a denormalized store with:
// - tasks: Task[] where Task has assignee: User
// - This should be inefficient for updates
```

<details>
<summary>Click for Solution</summary>

```typescript
import { create } from 'zustand';

interface User {
  id: string;
  name: string;
  email: string;
}

interface Task {
  id: string;
  title: string;
  completed: boolean;
  assignee: User; // Denormalized!
  createdAt: Date;
}

interface DenormalizedStore {
  tasks: Task[];
  addTask: (task: Task) => void;
  updateAssigneeName: (userId: string, newName: string) => void;
  toggleTask: (id: string) => void;
}

export const useDenormalizedStore = create<DenormalizedStore>((set) => ({
  tasks: [],

  addTask: (task) =>
    set((state) => ({
      tasks: [...state.tasks, task],
    })),

  // ❌ Inefficient: Must update every task
  updateAssigneeName: (userId, newName) =>
    set((state) => ({
      tasks: state.tasks.map((task) =>
        task.assignee.id === userId
          ? { ...task, assignee: { ...task.assignee, name: newName } }
          : task
      ),
    })),

  toggleTask: (id) =>
    set((state) => ({
      tasks: state.tasks.map((task) =>
        task.id === id ? { ...task, completed: !task.completed } : task
      ),
    })),
}));
```
</details>

## 📝 Task 2: Create Normalized Store

Create `src/store/normalizedStore.ts`:

```typescript
import { create } from 'zustand';

// TODO: Create a normalized store with:
// - tasks: Record<string, Task> where Task has assigneeId (reference)
// - taskIds: string[]
// - users: Record<string, User>
// - userIds: string[]
// - This should be efficient for updates
```

<details>
<summary>Click for Solution</summary>

```typescript
import { create } from 'zustand';

interface User {
  id: string;
  name: string;
  email: string;
}

interface Task {
  id: string;
  title: string;
  completed: boolean;
  assigneeId: string; // Reference, not nested
  createdAt: Date;
}

interface NormalizedStore {
  tasks: Record<string, Task>;
  taskIds: string[];
  users: Record<string, User>;
  userIds: string[];
  userTaskIds: Record<string, string[]>;

  addTask: (task: Task) => void;
  updateAssigneeName: (userId: string, newName: string) => void;
  toggleTask: (id: string) => void;
  getTasksForUser: (userId: string) => Task[];
  getStats: () => { total: number; completed: number; active: number };
}

export const useNormalizedStore = create<NormalizedStore>((set, get) => ({
  tasks: {},
  taskIds: [],
  users: {},
  userIds: [],
  userTaskIds: {},

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
  },

  // ✅ Efficient: Only update one user
  updateAssigneeName: (userId, newName) =>
    set((state) => ({
      users: {
        ...state.users,
        [userId]: { ...state.users[userId], name: newName },
      },
    })),

  // ✅ Efficient: Only update one task
  toggleTask: (id) =>
    set((state) => ({
      tasks: {
        ...state.tasks,
        [id]: { ...state.tasks[id], completed: !state.tasks[id].completed },
      },
    })),

  getTasksForUser: (userId) => {
    const state = get();
    return (state.userTaskIds[userId] || []).map(id => state.tasks[id]);
  },

  getStats: () => {
    const state = get();
    const tasks = state.taskIds.map(id => state.tasks[id]);
    const total = tasks.length;
    const completed = tasks.filter(t => t.completed).length;
    return { total, completed, active: total - completed };
  },
}));
```
</details>

## ✅ Verification Steps

1. **Run the application**:
   ```bash
   npx vite
   ```

2. **Compare performance**:
   - Add many tasks
   - Update assignee name
   - Measure performance difference

3. **Verify correctness**:
   - Tasks display correct assignee names
   - Stats update correctly

## 💡 Extension Challenge

Add a `getTasksByStatus` method that returns tasks grouped by completed status.

---

# Lab 4.3: Performance Benchmarking

## 🎯 Objective

Measure Zustand performance with benchmarks and identify bottlenecks.

## 📋 Prerequisites

- Understanding of performance measurement
- Knowledge of benchmarking techniques

## 📝 Task 1: Create Benchmark Test

Create `src/tests/performance.test.ts`:

```typescript
import { describe, it, expect, beforeEach } from 'vitest';
import { useTaskStore } from '../store/taskStore';

// TODO: Write performance tests that:
// 1. Measure add/update/delete operations
// 2. Measure state size
// 3. Measure render time
// 4. Use performance.now() for precise timing
// 5. Log results to console
```

<details>
<summary>Click for Solution</summary>

```typescript
import { describe, it, expect, beforeEach } from 'vitest';
import { useTaskStore } from '../store/taskStore';

describe('Performance Tests', () => {
  beforeEach(() => {
    useTaskStore.setState({ tasks: {}, taskIds: [] });
  });

  const measureTime = (fn: () => void, label: string): number => {
    const start = performance.now();
    fn();
    const end = performance.now();
    const duration = end - start;
    console.log(`${label}: ${duration.toFixed(2)}ms`);
    return duration;
  };

  const measureAverage = (fn: () => void, iterations: number = 100): number => {
    let total = 0;
    for (let i = 0; i < iterations; i++) {
      total += measureTime(fn, `Iteration ${i + 1}`);
      // Reset state between iterations
      if (i < iterations - 1) {
        useTaskStore.setState({ tasks: {}, taskIds: [] });
      }
    }
    return total / iterations;
  };

  it('should measure add performance', () => {
    const store = useTaskStore.getState();
    const task = { id: 'task-1', title: 'Test Task', completed: false };

    const duration = measureTime(() => {
      store.addTask(task);
    }, 'Add Task');

    expect(duration).toBeLessThan(5);
  });

  it('should measure bulk add performance (1000 items)', () => {
    const store = useTaskStore.getState();
    const tasks = Array.from({ length: 1000 }, (_, i) => ({
      id: `task-${i}`,
      title: `Task ${i}`,
      completed: false,
    }));

    const duration = measureTime(() => {
      for (const task of tasks) {
        store.addTask(task);
      }
    }, 'Add 1000 Tasks');

    expect(duration).toBeLessThan(100);
  });

  it('should measure state size', () => {
    const state = useTaskStore.getState();
    const size = new Blob([JSON.stringify(state)]).size;
    console.log(`State size: ${(size / 1024).toFixed(2)} KB`);
    expect(size).toBeLessThan(1024 * 1024);
  });

  it('should measure average add time', () => {
    const avg = measureAverage(() => {
      const store = useTaskStore.getState();
      store.addTask({ id: `task-${Date.now()}`, title: 'Test', completed: false });
    }, 100);
    console.log(`Average add time: ${avg.toFixed(2)}ms`);
    expect(avg).toBeLessThan(1);
  });
});
```
</details>

## 📝 Task 2: Create Performance Dashboard Component

Create `src/components/PerformanceDashboard.tsx`:

```tsx
import React, { useState, useEffect } from 'react';
import { useTaskStore } from '../store/taskStore';

// TODO: Create a performance dashboard that:
// 1. Shows current state size
// 2. Shows update count
// 3. Shows average update time
// 4. Shows slow updates
// 5. Auto-refreshes every second
```

<details>
<summary>Click for Solution</summary>

```tsx
import React, { useState, useEffect, useRef } from 'react';
import { useTaskStore } from '../store/taskStore';

interface PerformanceMetric {
  timestamp: number;
  updateCount: number;
  stateSize: number;
  duration: number;
}

export function PerformanceDashboard() {
  const [metrics, setMetrics] = useState<PerformanceMetric[]>([]);
  const [isVisible, setIsVisible] = useState(false);
  const updateCount = useRef(0);

  useEffect(() => {
    if (!isVisible) return;

    const interval = setInterval(() => {
      const state = useTaskStore.getState();
      const size = new Blob([JSON.stringify(state)]).size;
      
      setMetrics((prev) => [
        ...prev.slice(-50),
        {
          timestamp: Date.now(),
          updateCount: updateCount.current,
          stateSize: size,
          duration: 0,
        },
      ]);
    }, 1000);

    return () => clearInterval(interval);
  }, [isVisible]);

  // Track updates
  useEffect(() => {
    if (!isVisible) return;

    let startTime = performance.now();
    const unsubscribe = useTaskStore.subscribe(() => {
      const endTime = performance.now();
      const duration = endTime - startTime;
      updateCount.current++;

      setMetrics((prev) => {
        const last = prev[prev.length - 1];
        if (last) {
          return [
            ...prev.slice(0, -1),
            { ...last, duration },
          ];
        }
        return prev;
      });

      startTime = performance.now();
    });

    return () => unsubscribe();
  }, [isVisible]);

  if (!isVisible) {
    return (
      <button
        onClick={() => setIsVisible(true)}
        style={{ position: 'fixed', bottom: 20, right: 20, zIndex: 1000 }}
      >
        Show Performance Dashboard
      </button>
    );
  }

  const latest = metrics[metrics.length - 1];

  return (
    <div
      style={{
        position: 'fixed',
        bottom: 0,
        left: 0,
        right: 0,
        background: 'rgba(0,0,0,0.9)',
        color: '#00ff00',
        fontFamily: 'monospace',
        padding: '10px',
        zIndex: 1000,
        maxHeight: '200px',
        overflow: 'auto',
      }}
    >
      <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '10px' }}>
        <h4>Performance Dashboard</h4>
        <button onClick={() => setIsVisible(false)}>Close</button>
      </div>
      {latest ? (
        <div style={{ display: 'flex', gap: '20px', flexWrap: 'wrap' }}>
          <div>
            State Size: {(latest.stateSize / 1024).toFixed(1)} KB
          </div>
          <div>
            Updates: {latest.updateCount}
          </div>
          <div>
            Last Update: {latest.duration > 0 ? `${latest.duration.toFixed(2)}ms` : 'N/A'}
          </div>
          {latest.duration > 50 && (
            <div style={{ color: '#ff4444' }}>
              ⚠️ Slow update detected!
            </div>
          )}
        </div>
      ) : (
        <div>Waiting for metrics...</div>
      )}
      <div style={{ display: 'flex', height: '40px', gap: '2px', marginTop: '10px', alignItems: 'flex-end' }}>
        {metrics.slice(-20).map((m, i) => {
          const maxSize = Math.max(1, ...metrics.map(mm => mm.stateSize));
          const height = (m.stateSize / maxSize) * 100;
          return (
            <div
              key={i}
              style={{
                flex: 1,
                background: m.duration > 50 ? '#ff4444' : '#00ff00',
                height: `${Math.min(height, 100)}%`,
                opacity: 0.3 + (i / metrics.length) * 0.7,
              }}
              title={`${(m.stateSize / 1024).toFixed(1)} KB`}
            />
          );
        })}
      </div>
    </div>
  );
}
```
</details>

## ✅ Verification Steps

1. **Run the application**:
   ```bash
   npx vite
   ```

2. **Run performance tests**:
   ```bash
   npm test
   ```

3. **Monitor performance**:
   - Open Performance Dashboard
   - Add tasks
   - Watch metrics update

## 💡 Extension Challenge

Add a performance budget test that fails if operations exceed thresholds.

---

# Lab 4.4: React 19 Integration

## 🎯 Objective

Use React 19 features with Zustand: useTransition, useOptimistic, and useActionState.

## 📋 Prerequisites

- React 19 installed
- Understanding of React 19 hooks

## 📝 Task 1: Create Store for React 19

Create `src/store/react19Store.ts`:

```typescript
import { create } from 'zustand';

// TODO: Create a store with:
// - items: string[]
// - addItem: (item: string) => Promise<void>
// - search: (query: string) => Promise<void>
// - Items can be added with a delay to simulate async
// - Search is slow to demonstrate transitions
```

<details>
<summary>Click for Solution</summary>

```typescript
import { create } from 'zustand';

interface React19Store {
  items: string[];
  searchResults: string[];
  isLoading: boolean;
  error: string | null;
  addItem: (item: string) => Promise<void>;
  search: (query: string) => Promise<void>;
  clearSearch: () => void;
}

// Mock data
const mockItems = Array.from({ length: 1000 }, (_, i) => `Item ${i + 1}`);

export const useReact19Store = create<React19Store>((set) => ({
  items: [],
  searchResults: [],
  isLoading: false,
  error: null,

  addItem: async (item: string) => {
    set({ isLoading: true, error: null });
    try {
      await new Promise(resolve => setTimeout(resolve, 1000));
      set((state) => ({
        items: [...state.items, item],
        isLoading: false,
      }));
    } catch (error) {
      set({
        error: error instanceof Error ? error.message : 'Failed to add item',
        isLoading: false,
      });
    }
  },

  search: async (query: string) => {
    if (!query.trim()) {
      set({ searchResults: [] });
      return;
    }

    set({ isLoading: true });
    try {
      // Simulate slow search
      await new Promise(resolve => setTimeout(resolve, 500));
      const results = mockItems.filter(item =>
        item.toLowerCase().includes(query.toLowerCase())
      );
      set({ searchResults: results, isLoading: false });
    } catch (error) {
      set({
        error: error instanceof Error ? error.message : 'Search failed',
        isLoading: false,
      });
    }
  },

  clearSearch: () => set({ searchResults: [] }),
}));
```
</details>

## 📝 Task 2: Create Components with React 19 Hooks

Create `src/components/React19Demo.tsx`:

```tsx
import React, { useState, useTransition, useOptimistic, useActionState } from 'react';
import { useReact19Store } from '../store/react19Store';

// TODO: Create components that use:
// 1. useTransition for slow search
// 2. useOptimistic for add item
// 3. useActionState for form submission
```

<details>
<summary>Click for Solution</summary>

```tsx
import React, { useState, useTransition, useOptimistic, useActionState } from 'react';
import { useReact19Store } from '../store/react19Store';

// ✅ Component with useTransition
function SearchWithTransition() {
  const [query, setQuery] = useState('');
  const [isPending, startTransition] = useTransition();
  const { search, searchResults, isLoading } = useReact19Store();

  const handleSearch = (e: React.ChangeEvent<HTMLInputElement>) => {
    const value = e.target.value;
    setQuery(value);
    startTransition(() => {
      search(value);
    });
  };

  return (
    <div style={{ border: '1px solid #ddd', padding: '20px', margin: '10px' }}>
      <h3>Search (with useTransition)</h3>
      <input
        type="text"
        value={query}
        onChange={handleSearch}
        placeholder="Search items..."
        style={{ padding: '8px', width: '300px' }}
      />
      {isPending && <span style={{ marginLeft: '10px' }}>⏳ Searching...</span>}
      {isLoading && <span style={{ marginLeft: '10px' }}>Loading...</span>}
      <div style={{ marginTop: '10px' }}>
        Results: {searchResults.length} items
        {searchResults.slice(0, 10).map((item, i) => (
          <div key={i} style={{ padding: '4px 8px', background: '#f5f5f5', margin: '2px 0' }}>
            {item}
          </div>
        ))}
      </div>
    </div>
  );
}

// ✅ Component with useOptimistic
function OptimisticAddItem() {
  const [input, setInput] = useState('');
  const { addItem, items, error } = useReact19Store();

  const [optimisticItems, addOptimisticItem] = useOptimistic(
    items,
    (state, newItem: string) => [...state, `✨ ${newItem} (adding...)`]
  );

  const handleAdd = async () => {
    if (!input.trim()) return;
    const value = input.trim();
    setInput('');

    addOptimisticItem(value);
    try {
      await addItem(value);
    } catch {
      // Error handling in store
    }
  };

  return (
    <div style={{ border: '1px solid #ddd', padding: '20px', margin: '10px' }}>
      <h3>Add Item (with useOptimistic)</h3>
      <div style={{ display: 'flex', gap: '10px' }}>
        <input
          type="text"
          value={input}
          onChange={(e) => setInput(e.target.value)}
          placeholder="Add an item..."
          style={{ padding: '8px', flex: 1 }}
        />
        <button onClick={handleAdd}>Add</button>
      </div>
      {error && <div style={{ color: 'red' }}>Error: {error}</div>}
      <div style={{ marginTop: '10px' }}>
        {optimisticItems.map((item, i) => (
          <div key={i} style={{ padding: '4px 8px', background: '#f5f5f5', margin: '2px 0' }}>
            {item}
          </div>
        ))}
      </div>
    </div>
  );
}

// ✅ Component with useActionState
function ActionStateForm() {
  const addItem = useReact19Store((state) => state.addItem);

  const [state, action, isPending] = useActionState(
    async (prevState: { success: boolean; message: string }, formData: FormData) => {
      const item = formData.get('item') as string;
      if (!item.trim()) {
        return { success: false, message: 'Item cannot be empty' };
      }
      await addItem(item);
      return { success: true, message: `Added: ${item}` };
    },
    { success: false, message: '' }
  );

  return (
    <div style={{ border: '1px solid #ddd', padding: '20px', margin: '10px' }}>
      <h3>Form (with useActionState)</h3>
      <form action={action}>
        <div style={{ display: 'flex', gap: '10px' }}>
          <input
            name="item"
            placeholder="Enter item..."
            style={{ padding: '8px', flex: 1 }}
            disabled={isPending}
          />
          <button type="submit" disabled={isPending}>
            {isPending ? 'Adding...' : 'Submit'}
          </button>
        </div>
        {state.message && (
          <div style={{ marginTop: '10px', color: state.success ? 'green' : 'red' }}>
            {state.message}
          </div>
        )}
      </form>
    </div>
  );
}

export function React19Demo() {
  return (
    <div style={{ padding: '20px' }}>
      <h2>React 19 Integration Demo</h2>
      <SearchWithTransition />
      <OptimisticAddItem />
      <ActionStateForm />
    </div>
  );
}
```
</details>

## ✅ Verification Steps

1. **Run the application**:
   ```bash
   npx vite
   ```

2. **Test transitions**:
   - Type in search
   - UI should remain responsive during search

3. **Test optimistic updates**:
   - Add item
   - Should appear immediately with optimistic indicator

4. **Test action state**:
   - Submit form
   - Should show pending state
   - Should show success/error message

## 💡 Extension Challenge

Add useDeferredValue to defer rendering of search results.

---

# Lab 5.1: Shopping Cart

## 🎯 Objective

Build a shopping cart store with inventory validation, offline support, and persistence.

## 📋 Prerequisites

- Understanding of e-commerce patterns
- Knowledge of offline support

## 📝 Task 1: Create the Shopping Cart Store

Create `src/store/cartStore.ts`:

```typescript
import { create } from 'zustand';
import { persist } from 'zustand/middleware';
import { immer } from 'zustand/middleware/immer';

// TODO: Define Product, CartItem, and Cart interfaces

// TODO: Create a shopping cart store with:
// 1. Add/remove/update quantity
// 2. Inventory validation
// 3. Subtotal/tax/total calculations
// 4. Coupon support
// 5. Offline queue
// 6. Persistence
```

<details>
<summary>Click for Solution</summary>

```typescript
import { create } from 'zustand';
import { persist } from 'zustand/middleware';
import { immer } from 'zustand/middleware/immer';

interface Product {
  id: string;
  name: string;
  price: number;
  stock: number;
  maxPerOrder?: number;
}

interface CartItem {
  productId: string;
  product: Product;
  quantity: number;
}

interface Coupon {
  code: string;
  type: 'percentage' | 'fixed';
  value: number;
  minOrderAmount?: number;
}

interface OfflineAction {
  type: 'add' | 'remove' | 'update';
  productId: string;
  quantity?: number;
}

interface CartStore {
  items: CartItem[];
  coupon: Coupon | null;
  subtotal: number;
  tax: number;
  total: number;
  offlineQueue: OfflineAction[];
  isSyncing: boolean;
  error: string | null;

  // Cart operations
  addItem: (product: Product, quantity: number) => Promise<void>;
  removeItem: (productId: string) => Promise<void>;
  updateQuantity: (productId: string, quantity: number) => Promise<void>;
  clearCart: () => void;

  // Inventory validation
  validateInventory: (productId: string, quantity: number) => boolean;

  // Calculations
  calculateTotals: () => void;

  // Coupon
  applyCoupon: (code: string) => Promise<boolean>;
  removeCoupon: () => void;

  // Offline
  queueAction: (action: OfflineAction) => void;
  syncOfflineQueue: () => Promise<void>;

  // Utilities
  getItemCount: () => number;
  getItemQuantity: (productId: string) => number;
  isInCart: (productId: string) => boolean;
  clearError: () => void;
}

const TAX_RATE = 0.1;
const FREE_SHIPPING_THRESHOLD = 100;
const SHIPPING_COST = 5.99;

export const useCartStore = create<CartStore>()(
  persist(
    immer((set, get) => ({
      items: [],
      coupon: null,
      subtotal: 0,
      tax: 0,
      total: 0,
      offlineQueue: [],
      isSyncing: false,
      error: null,

      // --- Add Item ---
      addItem: async (product, quantity) => {
        if (!get().validateInventory(product.id, quantity)) {
          set({ error: `Not enough stock for ${product.name}` });
          throw new Error('Insufficient stock');
        }

        set((state) => {
          const existing = state.items.find(i => i.productId === product.id);
          if (existing) {
            existing.quantity += quantity;
          } else {
            state.items.push({ productId: product.id, product, quantity });
          }
          get().calculateTotals();
        });

        if (!navigator.onLine) {
          get().queueAction({ type: 'add', productId: product.id, quantity });
        }
      },

      // --- Remove Item ---
      removeItem: async (productId) => {
        set((state) => {
          state.items = state.items.filter(i => i.productId !== productId);
          get().calculateTotals();
        });

        if (!navigator.onLine) {
          get().queueAction({ type: 'remove', productId });
        }
      },

      // --- Update Quantity ---
      updateQuantity: async (productId, quantity) => {
        if (quantity <= 0) {
          await get().removeItem(productId);
          return;
        }

        if (!get().validateInventory(productId, quantity)) {
          set({ error: 'Insufficient stock' });
          throw new Error('Insufficient stock');
        }

        set((state) => {
          const item = state.items.find(i => i.productId === productId);
          if (item) {
            item.quantity = quantity;
            get().calculateTotals();
          }
        });

        if (!navigator.onLine) {
          get().queueAction({ type: 'update', productId, quantity });
        }
      },

      // --- Clear Cart ---
      clearCart: () => {
        set({ items: [], coupon: null, subtotal: 0, tax: 0, total: 0 });
      },

      // --- Inventory Validation ---
      validateInventory: (productId, quantity) => {
        const state = get();
        const item = state.items.find(i => i.productId === productId);
        const product = item?.product;

        if (!product) return false;
        if (quantity > product.stock) return false;
        if (product.maxPerOrder && quantity > product.maxPerOrder) return false;

        return true;
      },

      // --- Calculations ---
      calculateTotals: () => {
        set((state) => {
          const subtotal = state.items.reduce(
            (sum, item) => sum + item.product.price * item.quantity,
            0
          );
          const tax = subtotal * TAX_RATE;
          let discount = 0;

          if (state.coupon) {
            if (state.coupon.type === 'percentage') {
              discount = subtotal * (state.coupon.value / 100);
              if (state.coupon.minOrderAmount && subtotal < state.coupon.minOrderAmount) {
                discount = 0;
              }
            } else {
              discount = Math.min(state.coupon.value, subtotal);
            }
          }

          const shipping = subtotal >= FREE_SHIPPING_THRESHOLD ? 0 : SHIPPING_COST;
          const total = subtotal + tax + shipping - discount;

          state.subtotal = subtotal;
          state.tax = tax;
          state.total = total;
        });
      },

      // --- Coupon ---
      applyCoupon: async (code) => {
        // Mock coupon validation
        const validCoupons: Coupon[] = [
          { code: 'SAVE10', type: 'percentage', value: 10, minOrderAmount: 50 },
          { code: 'SAVE20', type: 'fixed', value: 20 },
        ];

        const coupon = validCoupons.find(c => c.code === code.toUpperCase());
        if (!coupon) {
          set({ error: 'Invalid coupon code' });
          return false;
        }

        set({ coupon });
        get().calculateTotals();
        return true;
      },

      removeCoupon: () => {
        set({ coupon: null });
        get().calculateTotals();
      },

      // --- Offline ---
      queueAction: (action) => {
        set((state) => {
          state.offlineQueue.push(action);
        });
      },

      syncOfflineQueue: async () => {
        const state = get();
        if (state.isSyncing || state.offlineQueue.length === 0 || !navigator.onLine) {
          return;
        }

        set({ isSyncing: true });

        while (state.offlineQueue.length > 0) {
          const action = state.offlineQueue[0];
          try {
            // Process action
            // In production, this would sync with server
            console.log('Syncing offline action:', action);
            set((state) => {
              state.offlineQueue.shift();
            });
          } catch (error) {
            console.error('Sync failed:', error);
            break;
          }
        }

        set({ isSyncing: false });
      },

      // --- Utilities ---
      getItemCount: () => {
        const state = get();
        return state.items.reduce((sum, item) => sum + item.quantity, 0);
      },

      getItemQuantity: (productId) => {
        const state = get();
        const item = state.items.find(i => i.productId === productId);
        return item?.quantity || 0;
      },

      isInCart: (productId) => {
        const state = get();
        return state.items.some(i => i.productId === productId);
      },

      clearError: () => {
        set({ error: null });
      },
    })),
    {
      name: 'cart-storage',
      partialize: (state) => ({
        items: state.items,
        coupon: state.coupon,
        subtotal: state.subtotal,
        tax: state.tax,
        total: state.total,
        offlineQueue: state.offlineQueue,
      }),
    }
  )
);
```
</details>

## ✅ Verification Steps

1. **Run the application**:
   ```bash
   npx vite
   ```

2. **Test cart operations**:
   - Add items
   - Update quantities
   - Remove items

3. **Test inventory validation**:
   - Try adding more than stock
   - Should show error

4. **Test coupon**:
   - Apply valid coupon
   - Verify discount

5. **Test offline**:
   - Disable network
   - Add items
   - Enable network
   - Verify sync

## 💡 Extension Challenge

Add persistence with migration to handle schema changes.

---

# Lab 5.2: Testing Zustand Stores

## 🎯 Objective

Write comprehensive unit and integration tests for Zustand stores.

## 📋 Prerequisites

- Understanding of Vitest/Jest
- Knowledge of testing patterns

## 📝 Task 1: Write Unit Tests

Create `src/store/__tests__/counterStore.test.ts`:

```typescript
import { describe, it, expect, beforeEach } from 'vitest';
import { useCounterStore } from '../counterStore';

// TODO: Write unit tests for:
// 1. Initial state
// 2. Increment action
// 3. Decrement action
// 4. Reset action
// 5. Multiple actions in sequence
```

<details>
<summary>Click for Solution</summary>

```typescript
import { describe, it, expect, beforeEach } from 'vitest';
import { useCounterStore } from '../counterStore';

describe('Counter Store', () => {
  beforeEach(() => {
    useCounterStore.setState({ count: 0 });
  });

  it('should have initial state', () => {
    const state = useCounterStore.getState();
    expect(state.count).toBe(0);
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

  it('should handle multiple actions', () => {
    const { increment, decrement } = useCounterStore.getState();
    increment();
    increment();
    decrement();
    expect(useCounterStore.getState().count).toBe(1);
  });
});
```
</details>

## 📝 Task 2: Write Integration Tests

Create `src/components/__tests__/Counter.integration.test.tsx`:

```tsx
import { describe, it, expect, beforeEach } from 'vitest';
import { render, screen, fireEvent } from '@testing-library/react';
import { useCounterStore } from '../../store/counterStore';
import { Counter } from '../Counter';

// TODO: Write integration tests:
// 1. Component renders initial state
// 2. Click increment updates state and UI
// 3. Click decrement updates state and UI
// 4. Multiple clicks update correctly
```

<details>
<summary>Click for Solution</summary>

```tsx
import { describe, it, expect, beforeEach } from 'vitest';
import { render, screen, fireEvent } from '@testing-library/react';
import { useCounterStore } from '../../store/counterStore';
import { Counter } from '../Counter';

describe('Counter Integration', () => {
  beforeEach(() => {
    useCounterStore.setState({ count: 0 });
  });

  it('should display initial count', () => {
    render(<Counter />);
    expect(screen.getByText(/Counter:/)).toBeInTheDocument();
    expect(screen.getByText('0')).toBeInTheDocument();
  });

  it('should increment when + button clicked', () => {
    render(<Counter />);
    const button = screen.getByText('+');
    fireEvent.click(button);
    expect(screen.getByText('1')).toBeInTheDocument();
    expect(useCounterStore.getState().count).toBe(1);
  });

  it('should decrement when - button clicked', () => {
    render(<Counter />);
    const button = screen.getByText('-');
    fireEvent.click(button);
    expect(screen.getByText('-1')).toBeInTheDocument();
    expect(useCounterStore.getState().count).toBe(-1);
  });

  it('should reset when reset button clicked', () => {
    render(<Counter />);
    const increment = screen.getByText('+');
    const reset = screen.getByText('Reset');
    fireEvent.click(increment);
    fireEvent.click(increment);
    fireEvent.click(reset);
    expect(screen.getByText('0')).toBeInTheDocument();
    expect(useCounterStore.getState().count).toBe(0);
  });

  it('should handle multiple clicks correctly', () => {
    render(<Counter />);
    const increment = screen.getByText('+');
    const decrement = screen.getByText('-');

    fireEvent.click(increment);
    fireEvent.click(increment);
    fireEvent.click(decrement);

    expect(screen.getByText('1')).toBeInTheDocument();
    expect(useCounterStore.getState().count).toBe(1);
  });
});
```
</details>

## 📝 Task 3: Write Tests for Async Actions

Create `src/store/__tests__/asyncStore.test.ts`:

```typescript
import { describe, it, expect, beforeEach, vi } from 'vitest';
import { useAsyncStore } from '../asyncStore';

// TODO: Write tests for:
// 1. Loading state during fetch
// 2. Success state after fetch
// 3. Error state on failure
// 4. Retry logic
```

<details>
<summary>Click for Solution</summary>

```typescript
import { describe, it, expect, beforeEach, vi } from 'vitest';
import { useAsyncStore } from '../asyncStore';

// Mock fetch
const mockFetch = vi.fn();

beforeEach(() => {
  useAsyncStore.setState({
    posts: [],
    loading: false,
    error: null,
    controller: null,
  });
  vi.clearAllMocks();
});

describe('Async Store', () => {
  it('should set loading state during fetch', async () => {
    mockFetch.mockResolvedValue({
      ok: true,
      json: () => Promise.resolve([{ id: 1, title: 'Test' }]),
    });
    global.fetch = mockFetch;

    const { fetchPosts } = useAsyncStore.getState();
    const promise = fetchPosts();

    expect(useAsyncStore.getState().loading).toBe(true);

    await promise;
    expect(useAsyncStore.getState().loading).toBe(false);
  });

  it('should update state on successful fetch', async () => {
    const mockData = [{ id: 1, title: 'Test Post' }];
    mockFetch.mockResolvedValue({
      ok: true,
      json: () => Promise.resolve(mockData),
    });
    global.fetch = mockFetch;

    const { fetchPosts } = useAsyncStore.getState();
    await fetchPosts();

    const state = useAsyncStore.getState();
    expect(state.posts).toEqual(mockData);
    expect(state.loading).toBe(false);
    expect(state.error).toBeNull();
  });

  it('should handle fetch errors', async () => {
    mockFetch.mockRejectedValue(new Error('Network error'));
    global.fetch = mockFetch;

    const { fetchPosts } = useAsyncStore.getState();
    await fetchPosts();

    const state = useAsyncStore.getState();
    expect(state.posts).toHaveLength(0);
    expect(state.loading).toBe(false);
    expect(state.error).toBe('Network error');
  });

  it('should clear posts', () => {
    const { clearPosts } = useAsyncStore.getState();
    useAsyncStore.setState({ posts: [{ id: 1, title: 'Test' }] });
    clearPosts();
    expect(useAsyncStore.getState().posts).toHaveLength(0);
  });

  it('should clear error', () => {
    const { clearError } = useAsyncStore.getState();
    useAsyncStore.setState({ error: 'Test error' });
    clearError();
    expect(useAsyncStore.getState().error).toBeNull();
  });
});
```
</details>

## ✅ Verification Steps

1. **Run tests**:
   ```bash
   npm test
   ```

2. **Check coverage**:
   ```bash
   npm test -- --coverage
   ```

3. **Verify all tests pass**:
   - Unit tests pass
   - Integration tests pass
   - Async tests pass

## 💡 Extension Challenge

Add tests for persistence and migration logic.

---

# Capstone Project: TaskFlow

## 🎯 Objective

Build a complete task management application using everything learned in the course.

## 📋 Requirements

### Store Architecture
- [ ] Authentication store (login, logout, persistence)
- [ ] Task store (CRUD, filters, sorting)
- [ ] UI store (theme, sidebar, modals)
- [ ] Slice pattern for organization

### Features
- [ ] User authentication with JWT
- [ ] Task CRUD operations
- [ ] Task filtering (status, priority, search)
- [ ] Task sorting
- [ ] Dark/light theme
- [ ] Responsive design

### Technical Requirements
- [ ] Zustand for state management
- [ ] TypeScript
- [ ] Persistence with localStorage
- [ ] Devtools middleware
- [ ] At least one custom middleware
- [ ] Unit tests (80%+ coverage)
- [ ] Integration tests for critical paths

### Optional Extensions
- [ ] Real-time updates with WebSockets
- [ ] Offline support
- [ ] Drag-and-drop task reordering
- [ ] Task comments
- [ ] File attachments

## 📝 Starter Code

```bash
# Create project
mkdir taskflow
cd taskflow
npm init -y
npm install react react-dom zustand immer reselect
npm install -D typescript @types/react @types/react-dom vite @vitejs/plugin-react vitest @testing-library/react
```

## 📁 Project Structure

```
taskflow/
├── src/
│   ├── store/
│   │   ├── slices/
│   │   │   ├── authSlice.ts
│   │   │   ├── taskSlice.ts
│   │   │   └── uiSlice.ts
│   │   ├── selectors/
│   │   │   └── taskSelectors.ts
│   │   └── store.ts
│   ├── components/
│   │   ├── auth/
│   │   ├── tasks/
│   │   └── ui/
│   ├── hooks/
│   ├── services/
│   ├── types/
│   ├── App.tsx
│   └── main.tsx
├── __tests__/
├── index.html
├── package.json
├── tsconfig.json
└── vite.config.ts
```

## ✅ Acceptance Criteria

- [ ] User can register and login
- [ ] User can create, read, update, delete tasks
- [ ] User can filter tasks by status and priority
- [ ] User can search tasks
- [ ] User can sort tasks
- [ ] User preferences persist across sessions
- [ ] All tests pass
- [ ] Code is well-organized and typed

## 💡 Extension Challenge Ideas

1. **Real-Time**: Add WebSocket support for multi-user collaboration
2. **Mobile**: Build a React Native companion app
3. **Analytics**: Add task completion analytics dashboard
4. **Notifications**: Add in-app notifications for task updates
5. **Drag-and-Drop**: Allow reordering tasks with drag and drop
6. **Tags**: Add tagging system for tasks
7. **Due Dates**: Add due dates and reminders
8. **Comments**: Add commenting on tasks
9. **Attachments**: Add file attachments to tasks
10. **Recurring Tasks**: Support recurring tasks

---

[END OF LAB BOOK]
