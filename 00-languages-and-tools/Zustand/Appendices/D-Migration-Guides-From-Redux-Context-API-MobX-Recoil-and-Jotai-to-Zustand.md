# Appendix D: Migration Guides — From Redux, Context API, MobX, Recoil, and Jotai to Zustand

This appendix provides comprehensive migration guides for moving from other state management solutions to Zustand. Each guide includes a concept comparison, step-by-step migration strategy, code examples (before/after), common pitfalls, and a checklist for each migration path.

---

## Quick Comparison Table

| Feature | Redux | Context API | MobX | Recoil | Jotai | Zustand |
|---------|-------|-------------|------|--------|-------|---------|
| **Boilerplate** | High | Low | Medium | Medium | Low | **Low** |
| **Provider Required** | Yes | Yes | No | Yes | Yes | **No** |
| **Fine-grained Updates** | Yes | No | Yes | Yes | Yes | **Yes** |
| **DevTools** | Yes | No | Yes | Yes | Yes | **Yes** |
| **Learning Curve** | Steep | Easy | Medium | Medium | Easy | **Easy** |
| **Async Support** | Middleware | Manual | Built-in | Built-in | Built-in | **Built-in** |
| **TypeScript** | Good | Good | Good | Good | Good | **Excellent** |
| **Bundle Size** | Large | Small | Large | Medium | Small | **Tiny** |
| **Framework Agnostic** | Yes | No | Yes | No | No | **Yes** |

---

## Migration 1: From Redux (Redux Toolkit) to Zustand

### Concept Comparison

| Redux Concept | Zustand Equivalent |
|---------------|-------------------|
| Store (configureStore) | `create()` |
| Reducer | `set` functional update |
| Action | Store method |
| Action Creator | Not needed (method does it) |
| Dispatch | Direct method call |
| Selector | `useStore(selector)` |
| Middleware | Built-in or custom middleware |
| Thunk/Saga | Async action directly in store |
| Redux DevTools | `devtools` middleware |
| Persist (redux-persist) | `persist` middleware |
| combineReducers | Not needed (multiple stores) |
| Provider | Not needed |
| useSelector | `useStore(selector)` |
| useDispatch | Not needed (direct method call) |

### Before: Redux Toolkit Code

```typescript
// counterSlice.ts
import { createSlice, PayloadAction } from '@reduxjs/toolkit';

interface CounterState {
  value: number;
  loading: boolean;
}

const initialState: CounterState = {
  value: 0,
  loading: false,
};

const counterSlice = createSlice({
  name: 'counter',
  initialState,
  reducers: {
    increment: (state) => {
      state.value += 1;
    },
    decrement: (state) => {
      state.value -= 1;
    },
    setLoading: (state, action: PayloadAction<boolean>) => {
      state.loading = action.payload;
    },
  },
});

export const { increment, decrement, setLoading } = counterSlice.actions;
export default counterSlice.reducer;

// store.ts
import { configureStore } from '@reduxjs/toolkit';
import counterReducer from './counterSlice';

export const store = configureStore({
  reducer: {
    counter: counterReducer,
  },
});

export type RootState = ReturnType<typeof store.getState>;
export type AppDispatch = typeof store.dispatch;

// Component
import { useSelector, useDispatch } from 'react-redux';

function Counter() {
  const count = useSelector((state: RootState) => state.counter.value);
  const loading = useSelector((state: RootState) => state.counter.loading);
  const dispatch = useDispatch();

  return (
    <div>
      <span>{count}</span>
      <button onClick={() => dispatch(increment())}>+</button>
      <button onClick={() => dispatch(decrement())}>-</button>
    </div>
  );
}

// App.tsx
import { Provider } from 'react-redux';
import { store } from './store';

function App() {
  return (
    <Provider store={store}>
      <Counter />
    </Provider>
  );
}
```

### After: Zustand Equivalent

```typescript
// counterStore.ts
import { create } from 'zustand';
import { devtools } from 'zustand/middleware';

interface CounterStore {
  value: number;
  loading: boolean;
  increment: () => void;
  decrement: () => void;
  setLoading: (loading: boolean) => void;
}

export const useCounterStore = create<CounterStore>()(
  devtools(
    (set) => ({
      value: 0,
      loading: false,
      increment: () => set((state) => ({ value: state.value + 1 })),
      decrement: () => set((state) => ({ value: state.value - 1 })),
      setLoading: (loading) => set({ loading }),
    }),
    { name: 'Counter Store' }
  )
);

// Component
function Counter() {
  const value = useCounterStore((state) => state.value);
  const loading = useCounterStore((state) => state.loading);
  const { increment, decrement } = useCounterStore();

  return (
    <div>
      <span>{value}</span>
      <button onClick={increment}>+</button>
      <button onClick={decrement}>-</button>
    </div>
  );
}

// App.tsx (No Provider needed!)
function App() {
  return <Counter />;
}
```

### Step-by-Step Migration

#### Step 1: Install Zustand
```bash
npm install zustand
```

#### Step 2: Create Zustand Store (Side by Side)
```typescript
// store/zustand/counterStore.ts
import { create } from 'zustand';
import { devtools } from 'zustand/middleware';

export const useCounterStore = create((set) => ({
  value: 0,
  increment: () => set((state) => ({ value: state.value + 1 })),
  decrement: () => set((state) => ({ value: state.value - 1 })),
}));
```

#### Step 3: Migrate Components One at a Time
```tsx
// Before: Redux component
function OldCounter() {
  const value = useSelector((state) => state.counter.value);
  const dispatch = useDispatch();
  return <button onClick={() => dispatch(increment())}>{value}</button>;
}

// After: Zustand component
function NewCounter() {
  const value = useCounterStore((state) => state.value);
  const increment = useCounterStore((state) => state.increment);
  return <button onClick={increment}>{value}</button>;
}
```

#### Step 4: Use Feature Flags
```tsx
// Use feature flags to test migration
function Counter() {
  const useZustand = featureFlags.useZustandCounter;
  return useZustand ? <NewCounter /> : <OldCounter />;
}
```

#### Step 5: Remove Redux When Complete
- Delete Redux slices
- Remove Redux Provider
- Remove redux packages from package.json

### Migration Checklist

- [ ] Install Zustand
- [ ] Create Zustand store version of each Redux slice
- [ ] Enable both stores side by side
- [ ] Migrate components one by one to Zustand
- [ ] Use feature flags for gradual rollout
- [ ] Remove Redux store and Provider
- [ ] Remove redux packages
- [ ] Update tests to use Zustand

---

## Migration 2: From Context API to Zustand

### Concept Comparison

| Context API | Zustand |
|-------------|---------|
| `createContext` | Not needed |
| `<Provider>` | Not needed |
| `useContext` | `useStore` |
| State + setter in provider | Store state + actions |
| All consumers re-render | Fine-grained subscriptions |
| Manual memoization | Automatic with selectors |
| Wraps component tree | Direct usage anywhere |

### Before: Context API Code

```typescript
// TaskContext.tsx
import React, { createContext, useContext, useState, ReactNode } from 'react';

interface Task {
  id: string;
  text: string;
  completed: boolean;
}

interface TaskContextType {
  tasks: Task[];
  addTask: (text: string) => void;
  toggleTask: (id: string) => void;
  deleteTask: (id: string) => void;
}

const TaskContext = createContext<TaskContextType | null>(null);

export function TaskProvider({ children }: { children: ReactNode }) {
  const [tasks, setTasks] = useState<Task[]>([]);

  const addTask = (text: string) => {
    setTasks((prev) => [
      ...prev,
      { id: crypto.randomUUID(), text, completed: false },
    ]);
  };

  const toggleTask = (id: string) => {
    setTasks((prev) =>
      prev.map((t) => (t.id === id ? { ...t, completed: !t.completed } : t))
    );
  };

  const deleteTask = (id: string) => {
    setTasks((prev) => prev.filter((t) => t.id !== id));
  };

  return (
    <TaskContext.Provider value={{ tasks, addTask, toggleTask, deleteTask }}>
      {children}
    </TaskContext.Provider>
  );
}

export function useTasks() {
  const context = useContext(TaskContext);
  if (!context) throw new Error('useTasks must be used within TaskProvider');
  return context;
}

// Component
function TaskList() {
  const { tasks, toggleTask } = useTasks(); // ❌ Re-renders on ANY change
  return tasks.map((task) => (
    <div key={task.id} onClick={() => toggleTask(task.id)}>
      {task.text}
    </div>
  ));
}

// App.tsx
function App() {
  return (
    <TaskProvider>
      <TaskList />
    </TaskProvider>
  );
}
```

### After: Zustand Equivalent

```typescript
// taskStore.ts
import { create } from 'zustand';

interface Task {
  id: string;
  text: string;
  completed: boolean;
}

interface TaskStore {
  tasks: Record<string, Task>;
  taskIds: string[];
  addTask: (text: string) => void;
  toggleTask: (id: string) => void;
  deleteTask: (id: string) => void;
}

export const useTaskStore = create<TaskStore>((set) => ({
  tasks: {},
  taskIds: [],
  addTask: (text) => {
    const id = crypto.randomUUID();
    set((state) => ({
      tasks: { ...state.tasks, [id]: { id, text, completed: false } },
      taskIds: [...state.taskIds, id],
    }));
  },
  toggleTask: (id) => {
    set((state) => ({
      tasks: {
        ...state.tasks,
        [id]: { ...state.tasks[id], completed: !state.tasks[id].completed },
      },
    }));
  },
  deleteTask: (id) => {
    const { [id]: removed, ...remaining } = state.tasks;
    set({
      tasks: remaining,
      taskIds: state.taskIds.filter((tid) => tid !== id),
    });
  },
}));

// Component
function TaskList() {
  const tasks = useTaskStore((state) => state.tasks);
  const taskIds = useTaskStore((state) => state.taskIds);
  const toggleTask = useTaskStore((state) => state.toggleTask);

  return taskIds.map((id) => (
    <div key={id} onClick={() => toggleTask(id)}>
      {tasks[id].text}
    </div>
  ));
}

// App.tsx (No Provider needed!)
function App() {
  return <TaskList />;
}
```

### Step-by-Step Migration

#### Step 1: Install Zustand
```bash
npm install zustand
```

#### Step 2: Create Zustand Store with Same API
```typescript
// store/taskStore.ts
import { create } from 'zustand';

// Same interface as context
export const useTaskStore = create((set) => ({
  tasks: [],
  addTask: (text) => set((state) => ({ tasks: [...state.tasks, { id: crypto.randomUUID(), text, completed: false }] })),
  toggleTask: (id) => set((state) => ({ tasks: state.tasks.map(t => t.id === id ? { ...t, completed: !t.completed } : t) })),
  deleteTask: (id) => set((state) => ({ tasks: state.tasks.filter(t => t.id !== id) })),
}));
```

#### Step 3: Create Adapter to Keep Context API
```tsx
// context/adapters.tsx
'use client';

import React, { useEffect } from 'react';
import { useTaskStore } from '../store/taskStore';
import { TaskContext } from './TaskContext';

export function ZustandContextAdapter({ children }) {
  const store = useTaskStore();
  const contextValue = {
    tasks: store.tasks,
    addTask: store.addTask,
    toggleTask: store.toggleTask,
    deleteTask: store.deleteTask,
  };
  
  return (
    <TaskContext.Provider value={contextValue}>
      {children}
    </TaskContext.Provider>
  );
}

// Step 4: Replace Provider with Adapter
// Before: <TaskProvider><App /></TaskProvider>
// After: <ZustandContextAdapter><App /></ZustandContextAdapter>
```

#### Step 5: Migrate Components One by One
```tsx
// Before: const { tasks } = useTasks();
// After: const tasks = useTaskStore((state) => state.tasks);
```

#### Step 6: Remove Adapter When Done

### Migration Checklist

- [ ] Install Zustand
- [ ] Create Zustand store
- [ ] Create adapter to keep context API working
- [ ] Replace Provider with adapter
- [ ] Migrate components one by one
- [ ] Remove adapter when all components migrated
- [ ] Delete context files

---

## Migration 3: From MobX to Zustand

### Concept Comparison

| MobX | Zustand |
|------|---------|
| `@observable` | State in store |
| `@action` | Store method |
| `@computed` | Selector or computed method |
| `makeObservable` | Not needed |
| `mobx-react` Provider | Not needed |
| `observer` HOC | `useStore` hook |
| Reactive | Reactive |
| Magic proxies | Explicit updates |

### Before: MobX Code

```typescript
// store.ts
import { makeObservable, observable, action, computed } from 'mobx';

class TodoStore {
  todos: Todo[] = [];

  constructor() {
    makeObservable(this, {
      todos: observable,
      addTodo: action,
      toggleTodo: action,
      deleteTodo: action,
      completedTodos: computed,
      activeTodos: computed,
    });
  }

  addTodo(text: string) {
    this.todos.push({ id: Date.now(), text, completed: false });
  }

  toggleTodo(id: number) {
    const todo = this.todos.find(t => t.id === id);
    if (todo) todo.completed = !todo.completed;
  }

  deleteTodo(id: number) {
    this.todos = this.todos.filter(t => t.id !== id);
  }

  get completedTodos() {
    return this.todos.filter(t => t.completed);
  }

  get activeTodos() {
    return this.todos.filter(t => !t.completed);
  }
}

const todoStore = new TodoStore();

// Component
import { observer } from 'mobx-react';

const TodoList = observer(() => {
  return (
    <div>
      {todoStore.todos.map(todo => (
        <div key={todo.id} onClick={() => todoStore.toggleTodo(todo.id)}>
          {todo.text} {todo.completed && '✓'}
        </div>
      ))}
    </div>
  );
});

// App.tsx
function App() {
  return <TodoList />;
}
```

### After: Zustand Equivalent

```typescript
// store.ts
import { create } from 'zustand';

interface Todo {
  id: number;
  text: string;
  completed: boolean;
}

interface TodoStore {
  todos: Todo[];
  addTodo: (text: string) => void;
  toggleTodo: (id: number) => void;
  deleteTodo: (id: number) => void;
  // Computed as store methods
  getCompletedTodos: () => Todo[];
  getActiveTodos: () => Todo[];
}

export const useTodoStore = create<TodoStore>((set, get) => ({
  todos: [],
  addTodo: (text) => set((state) => ({
    todos: [...state.todos, { id: Date.now(), text, completed: false }],
  })),
  toggleTodo: (id) => set((state) => ({
    todos: state.todos.map(t => t.id === id ? { ...t, completed: !t.completed } : t),
  })),
  deleteTodo: (id) => set((state) => ({
    todos: state.todos.filter(t => t.id !== id),
  })),
  getCompletedTodos: () => get().todos.filter(t => t.completed),
  getActiveTodos: () => get().todos.filter(t => !t.completed),
}));

// Component (No observer needed!)
function TodoList() {
  const todos = useTodoStore((state) => state.todos);
  const toggleTodo = useTodoStore((state) => state.toggleTodo);

  return (
    <div>
      {todos.map(todo => (
        <div key={todo.id} onClick={() => toggleTodo(todo.id)}>
          {todo.text} {todo.completed && '✓'}
        </div>
      ))}
    </div>
  );
}
```

### Step-by-Step Migration

#### Step 1: Install Zustand
```bash
npm install zustand
```

#### Step 2: Convert MobX Store to Zustand
```typescript
// Move from class-based to functional store
```

#### Step 3: Migrate Components
```tsx
// Before: const store = todoStore; (global)
// After: const todos = useTodoStore((state) => state.todos);
```

#### Step 4: Remove observer HOC
```tsx
// Before: export default observer(TodoList);
// After: export default TodoList;
```

#### Step 5: Remove MobX Packages

### Migration Checklist

- [ ] Install Zustand
- [ ] Convert MobX store to Zustand store
- [ ] Convert class-based actions to functions
- [ ] Convert computed values to methods or selectors
- [ ] Migrate components to use `useStore`
- [ ] Remove `observer` HOC
- [ ] Remove mobx and mobx-react packages

---

## Migration 4: From Recoil to Zustand

### Concept Comparison

| Recoil | Zustand |
|--------|---------|
| `atom` | Store state |
| `selector` | Selector or computed method |
| `useRecoilState` | `useStore` |
| `useRecoilValue` | `useStore(selector)` |
| `useSetRecoilState` | `useStore(selector)` with action |
| `RecoilRoot` Provider | Not needed |

### Before: Recoil Code

```typescript
// atoms.ts
import { atom, selector } from 'recoil';

export const todoState = atom({
  key: 'todoState',
  default: [] as Todo[],
});

export const activeTodoCount = selector({
  key: 'activeTodoCount',
  get: ({ get }) => {
    const todos = get(todoState);
    return todos.filter(t => !t.completed).length;
  },
});

// Component
import { useRecoilState, useRecoilValue } from 'recoil';

function TodoList() {
  const [todos, setTodos] = useRecoilState(todoState);
  const activeCount = useRecoilValue(activeTodoCount);

  const addTodo = (text: string) => {
    setTodos(prev => [...prev, { id: Date.now(), text, completed: false }]);
  };

  // ...
}

// App.tsx
import { RecoilRoot } from 'recoil';

function App() {
  return (
    <RecoilRoot>
      <TodoList />
    </RecoilRoot>
  );
}
```

### After: Zustand Equivalent

```typescript
// store.ts
import { create } from 'zustand';

interface Todo {
  id: number;
  text: string;
  completed: boolean;
}

interface TodoStore {
  todos: Todo[];
  addTodo: (text: string) => void;
  toggleTodo: (id: number) => void;
  deleteTodo: (id: number) => void;
  getActiveCount: () => number;
}

export const useTodoStore = create<TodoStore>((set, get) => ({
  todos: [],
  addTodo: (text) => set((state) => ({
    todos: [...state.todos, { id: Date.now(), text, completed: false }],
  })),
  toggleTodo: (id) => set((state) => ({
    todos: state.todos.map(t => t.id === id ? { ...t, completed: !t.completed } : t),
  })),
  deleteTodo: (id) => set((state) => ({
    todos: state.todos.filter(t => t.id !== id),
  })),
  getActiveCount: () => get().todos.filter(t => !t.completed).length,
}));

// Component
function TodoList() {
  const todos = useTodoStore((state) => state.todos);
  const activeCount = useTodoStore((state) => state.getActiveCount());
  const addTodo = useTodoStore((state) => state.addTodo);

  // ...
}

// App.tsx (No Provider needed!)
function App() {
  return <TodoList />;
}
```

### Step-by-Step Migration

#### Step 1: Install Zustand
```bash
npm install zustand
```

#### Step 2: Convert Recoil Atoms/Selectors to Zustand
```typescript
// Move from atom/selector to store
export const useTodoStore = create((set, get) => ({
  // state from atom
  todos: [],
  // actions
  // computed from selector
  getActiveCount: () => get().todos.filter(t => !t.completed).length,
}));
```

#### Step 3: Replace Recoil Hooks
```tsx
// Before: const [todos, setTodos] = useRecoilState(todoState);
// After: const todos = useTodoStore((state) => state.todos);

// Before: const activeCount = useRecoilValue(activeTodoCount);
// After: const activeCount = useTodoStore((state) => state.getActiveCount());
```

#### Step 4: Remove RecoilRoot Provider
```tsx
// Before: <RecoilRoot><App /></RecoilRoot>
// After: <App />
```

#### Step 5: Remove Recoil Packages

### Migration Checklist

- [ ] Install Zustand
- [ ] Convert atoms to store state
- [ ] Convert selectors to store methods or selectors
- [ ] Replace useRecoilState with useStore
- [ ] Replace useRecoilValue with useStore selector
- [ ] Replace useSetRecoilState with useStore action
- [ ] Remove RecoilRoot
- [ ] Remove recoil packages

---

## Migration 5: From Jotai to Zustand

### Concept Comparison

| Jotai | Zustand |
|-------|---------|
| `atom` | Store state |
| `useAtom` | `useStore` |
| `useAtomValue` | `useStore(selector)` |
| `useSetAtom` | `useStore(selector)` with action |
| `Provider` | Not needed |

### Before: Jotai Code

```typescript
// atoms.ts
import { atom } from 'jotai';

export const todoAtom = atom<Todo[]>([]);

export const addTodoAtom = atom(
  null,
  (get, set, text: string) => {
    const todos = get(todoAtom);
    set(todoAtom, [...todos, { id: Date.now(), text, completed: false }]);
  }
);

export const toggleTodoAtom = atom(
  null,
  (get, set, id: number) => {
    const todos = get(todoAtom);
    set(todoAtom, todos.map(t => t.id === id ? { ...t, completed: !t.completed } : t));
  }
);

export const activeCountAtom = atom((get) => {
  const todos = get(todoAtom);
  return todos.filter(t => !t.completed).length;
});

// Component
import { useAtom, useAtomValue, useSetAtom } from 'jotai';

function TodoList() {
  const [todos, setTodos] = useAtom(todoAtom);
  const addTodo = useSetAtom(addTodoAtom);
  const activeCount = useAtomValue(activeCountAtom);
  // ...
}

// App.tsx
import { Provider } from 'jotai';

function App() {
  return (
    <Provider>
      <TodoList />
    </Provider>
  );
}
```

### After: Zustand Equivalent

```typescript
// store.ts
import { create } from 'zustand';

interface Todo {
  id: number;
  text: string;
  completed: boolean;
}

interface TodoStore {
  todos: Todo[];
  addTodo: (text: string) => void;
  toggleTodo: (id: number) => void;
  getActiveCount: () => number;
}

export const useTodoStore = create<TodoStore>((set, get) => ({
  todos: [],
  addTodo: (text) => set((state) => ({
    todos: [...state.todos, { id: Date.now(), text, completed: false }],
  })),
  toggleTodo: (id) => set((state) => ({
    todos: state.todos.map(t => t.id === id ? { ...t, completed: !t.completed } : t),
  })),
  getActiveCount: () => get().todos.filter(t => !t.completed).length,
}));

// Component
function TodoList() {
  const todos = useTodoStore((state) => state.todos);
  const activeCount = useTodoStore((state) => state.getActiveCount());
  const addTodo = useTodoStore((state) => state.addTodo);
  const toggleTodo = useTodoStore((state) => state.toggleTodo);
  // ...
}
```

### Step-by-Step Migration

#### Step 1: Install Zustand
```bash
npm install zustand
```

#### Step 2: Convert Jotai Atoms
```typescript
// Convert atoms to Zustand store
// Read atom → state
// Write atom → action
// Read-only atom → computed method
```

#### Step 3: Replace Jotai Hooks
```tsx
// Before: const [todos] = useAtom(todoAtom);
// After: const todos = useTodoStore((state) => state.todos);

// Before: const addTodo = useSetAtom(addTodoAtom);
// After: const addTodo = useTodoStore((state) => state.addTodo);

// Before: const activeCount = useAtomValue(activeCountAtom);
// After: const activeCount = useTodoStore((state) => state.getActiveCount());
```

#### Step 4: Remove Jotai Provider
```tsx
// Before: <Provider><App /></Provider>
// After: <App />
```

### Migration Checklist

- [ ] Install Zustand
- [ ] Convert atoms to store state/actions
- [ ] Convert write atoms to store actions
- [ ] Convert read atoms to computed methods
- [ ] Replace useAtom with useStore
- [ ] Replace useAtomValue with useStore selector
- [ ] Replace useSetAtom with useStore action
- [ ] Remove Jotai Provider
- [ ] Remove jotai packages

---

## Comparison: Migration Effort

| Source | Effort Level | Difficulty | Time Estimate | Key Challenge |
|--------|--------------|------------|---------------|---------------|
| Redux (RTK) | Medium | Medium | 2-4 weeks | Boilerplate reduction |
| Context API | Low | Easy | 1-2 weeks | Performance improvement |
| MobX | Medium | Medium | 2-3 weeks | Reactive paradigm shift |
| Recoil | Low | Easy | 1-2 weeks | Provider removal |
| Jotai | Low | Easy | 1-2 weeks | Similar API |

---

## Common Migration Pitfalls

### Pitfall 1: Trying to Migrate Everything at Once
```typescript
// ❌ Big bang migration
// Migrate all stores and components at once → high risk, hard to debug

// ✅ Incremental migration
// Migrate one store at a time, one component at a time
// Use feature flags for gradual rollout
```

### Pitfall 2: Not Testing During Migration
```typescript
// ❌ Migrate → deploy → test (too late)

// ✅ Write tests first, then migrate
// Ensure all tests pass after each step
```

### Pitfall 3: Not Using Feature Flags
```typescript
// ❌ Hard cutover
// Users immediately see new version

// ✅ Feature flags
// Roll out to internal users first, then a percentage, then all
```

### Pitfall 4: Not Cleaning Up
```typescript
// ❌ Leaving old code
// Dead code, confusion, bundle size

// ✅ Clean up when done
// Delete old stores, components, packages
```

---

## Feature Flag Migration Template

```typescript
// featureFlags.ts
export const features = {
  useZustandTodos: false,
  useZustandAuth: false,
  useZustandUI: false,
};

// Load from localStorage or remote config
if (typeof window !== 'undefined') {
  const saved = localStorage.getItem('featureFlags');
  if (saved) {
    Object.assign(features, JSON.parse(saved));
  }
}

export function toggleFeature(name: keyof typeof features) {
  features[name] = !features[name];
  localStorage.setItem('featureFlags', JSON.stringify(features));
}

// Component using feature flag
function Todos() {
  if (features.useZustandTodos) {
    return <ZustandTodoList />;
  }
  return <ReduxTodoList />;
}
```

---

## Summary

| Migration Path | Best For | Key Steps |
|----------------|----------|-----------|
| **Redux → Zustand** | Large projects with complex state | Reduce boilerplate, keep middleware |
| **Context → Zustand** | Apps with performance issues | Remove Providers, add selectors |
| **MobX → Zustand** | Projects wanting simpler reactivity | Convert classes to functions |
| **Recoil → Zustand** | Apps with many atoms | Simplify atoms, remove Provider |
| **Jotai → Zustand** | Projects wanting unified API | Convert atoms to store |
