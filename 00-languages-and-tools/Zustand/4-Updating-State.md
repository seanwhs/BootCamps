# Part 1 — Foundations & Core Concepts

## Section 4: Updating State

Now that you've mastered reading state efficiently, it's time to become an expert at updating it. Zustand provides multiple patterns for updating state, each suited to different scenarios. In this section, you'll learn all of them, from simple updates to complex immutable transformations.

---

## The Target: Master State Updates

By the end of this section, you'll be able to:
- Perform functional updates safely
- Handle immutable updates correctly
- Batch multiple state mutations
- Reset state to its initial values
- Perform partial updates efficiently

---

## The Concept: State Updates as Controlled Transformations

Think of state updates like editing a document in a version control system:

- **Current State**: The latest version of your document
- **Update**: A change you want to make
- **New State**: The updated version after your change
- **Immutability**: Like Git, you never delete the old version—you create a new one

### Why Immutability Matters

Imagine you're working on a shared whiteboard. If someone erases part of it without telling anyone, chaos ensues. Immutability is like having a rule: "Never erase—always add a new layer on top." This way:
- Everyone knows what changed
- You can undo changes
- You can track history
- You avoid conflicts

In JavaScript terms:
```javascript
// ❌ MUTATION: Dangerous and unpredictable
const task = { id: 1, text: 'Buy milk', done: false };
task.done = true; // This mutates the original object
// Now ANY component using this task will see it as 'done'

// ✅ IMMUTABLE: Safe and predictable
const updatedTask = { ...task, done: true };
// Original task remains unchanged
// Components using the old task won't see the change until they update
```

---

## The Implementation: State Update Patterns

### Step 1: Functional Updates (The Preferred Approach)

Functional updates use the current state to compute the next state. This is the safest and most predictable way to update state.

```typescript
// src/store/taskStore.ts — Adding functional updates
interface TaskStore {
  tasks: Task[];
  // ... other state
  
  // Functional update example
  updateTaskText: (id: string, newText: string) => void;
  addMultipleTasks: (tasks: Task[]) => void;
  toggleAllTasks: (completed: boolean) => void;
  removeCompletedTasks: () => void;
  reorderTasks: (startIndex: number, endIndex: number) => void;
}

export const useTaskStore = create<TaskStore>((set, get) => ({
  tasks: [],
  // ... other initial state

  // 1. Simple functional update
  updateTaskText: (id: string, newText: string) => {
    set((state) => ({
      tasks: state.tasks.map((task) =>
        task.id === id
          ? { ...task, text: newText.trim() }
          : task
      ),
    }));
  },

  // 2. Adding multiple tasks
  addMultipleTasks: (newTasks: Task[]) => {
    set((state) => ({
      tasks: [...state.tasks, ...newTasks],
    }));
  },

  // 3. Toggle all tasks
  toggleAllTasks: (completed: boolean) => {
    set((state) => ({
      tasks: state.tasks.map((task) => ({
        ...task,
        completed,
      })),
    }));
  },

  // 4. Remove completed tasks
  removeCompletedTasks: () => {
    set((state) => ({
      tasks: state.tasks.filter((task) => !task.completed),
    }));
  },

  // 5. Reorder tasks (drag and drop)
  reorderTasks: (startIndex: number, endIndex: number) => {
    set((state) => {
      const tasks = [...state.tasks];
      const [removed] = tasks.splice(startIndex, 1);
      tasks.splice(endIndex, 0, removed);
      return { tasks };
    });
  },
}));
```

### Step 2: Immutable Updates Deep Dive

Immutable updates are crucial for Zustand to detect changes properly. Let's explore the patterns for different data structures:

```typescript
// src/store/immutableExamples.ts
import { create } from 'zustand';

interface ImmutableStore {
  // 1. Primitive state (easy)
  count: number;
  text: string;
  isComplete: boolean;
  
  // 2. Arrays
  numbers: number[];
  tasks: Task[];
  
  // 3. Objects
  user: { id: string; name: string; preferences: { theme: string } };
  config: Record<string, any>;
  
  // Update methods
  incrementCount: () => void;
  addNumber: (num: number) => void;
  updateUserTheme: (theme: string) => void;
  updateNestedObject: () => void;
}

export const useImmutableStore = create<ImmutableStore>((set) => ({
  // Initial state
  count: 0,
  text: 'Hello',
  isComplete: false,
  numbers: [1, 2, 3],
  tasks: [],
  user: { id: '1', name: 'Alice', preferences: { theme: 'dark' } },
  config: {},

  // PRIMITIVE UPDATES (direct assignment)
  incrementCount: () => {
    set((state) => ({ count: state.count + 1 }));
  },

  // ARRAY UPDATES (create new arrays)
  addNumber: (num: number) => {
    set((state) => ({
      numbers: [...state.numbers, num], // Spread operator
    }));
  },

  // COMPLEX OBJECT UPDATES (create new objects)
  updateUserTheme: (theme: string) => {
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

  // NESTED UPDATE (using spread at every level)
  updateNestedObject: () => {
    set((state) => ({
      config: {
        ...state.config,
        settings: {
          ...state.config?.settings,
          notifications: {
            ...state.config?.settings?.notifications,
            email: true,
          },
        },
      },
    }));
  },
}));
```

### Step 3: Multiple State Mutations (Batching)

Sometimes you need to update multiple pieces of state at once. Zustand batches these updates automatically.

```typescript
// src/store/taskStore.ts — Batching updates

// ❌ BAD: Multiple separate updates (causes multiple re-renders)
// This will trigger two separate re-renders
const badUpdate = () => {
  set({ loading: true });
  // Some async operation...
  set({ tasks: newTasks, loading: false });
};

// ✅ GOOD: Single update with all changes
const goodUpdate = (newTasks: Task[]) => {
  set({
    tasks: newTasks,
    loading: false,
    error: null,
  });
};

// ✅ BEST: Functional update for complex logic
const bestUpdate = () => {
  set((state) => ({
    tasks: state.tasks.map((task) => ({
      ...task,
      priority: 'high',
    })),
    filter: 'all',
    searchQuery: '',
    loading: false,
    error: null,
  }));
};

// Real-world example: Creating a task with loading state
export const useTaskStore = create<TaskStore>((set, get) => ({
  tasks: [],
  loading: false,
  error: null,
  filter: 'all',
  searchQuery: '',
  sortBy: 'createdAt',

  // Combined update: Add task and clear search filter
  addTaskAndClearFilter: (text: string) => {
    set((state) => ({
      tasks: [
        ...state.tasks,
        {
          id: crypto.randomUUID(),
          text: text.trim(),
          completed: false,
          createdAt: new Date(),
          priority: 'medium',
          tags: [],
        },
      ],
      filter: 'all', // Reset filter
      searchQuery: '', // Clear search
    }));
  },

  // Complex update with error handling
  fetchTasks: async (url: string) => {
    // First update: Set loading state
    set({ loading: true, error: null });

    try {
      const response = await fetch(url);
      if (!response.ok) throw new Error('Failed to fetch tasks');
      const data = await response.json();

      // Second update: All at once
      set({
        tasks: data.tasks,
        loading: false,
        error: null,
      });
    } catch (error) {
      // Error update
      set({
        loading: false,
        error: error.message,
      });
    }
  },
}));
```

### Step 4: Resetting State

Resetting state is a common pattern for forms, user sessions, and when components unmount.

```typescript
// src/store/taskStore.ts — Reset patterns

// Option 1: Define initial state as a constant
const initialState = {
  tasks: [],
  loading: false,
  error: null,
  filter: 'all' as const,
  searchQuery: '',
  sortBy: 'createdAt' as const,
};

export const useTaskStore = create<TaskStore>((set, get) => ({
  ...initialState,
  // ... actions
  
  // Reset to initial state
  resetStore: () => {
    set(initialState);
  },
  
  // Reset specific parts
  resetTasks: () => {
    set({ tasks: [] });
  },
  
  resetFilters: () => {
    set({
      filter: 'all',
      searchQuery: '',
      sortBy: 'createdAt',
    });
  },
}));

// Option 2: Reset with type safety
type TaskStoreState = Pick<TaskStore, 'tasks' | 'loading' | 'error' | 'filter' | 'searchQuery' | 'sortBy'>;

const getInitialState = (): TaskStoreState => ({
  tasks: [],
  loading: false,
  error: null,
  filter: 'all',
  searchQuery: '',
  sortBy: 'createdAt',
});

export const useTaskStore = create<TaskStore>((set, get) => ({
  ...getInitialState(),
  // ... actions
  
  resetStore: () => {
    set(getInitialState());
  },
}));
```

### Step 5: Partial Updates

Partial updates allow you to update specific fields without affecting others.

```typescript
// src/store/taskStore.ts — Partial updates

interface TaskStore {
  // ... existing state
  updateTask: (id: string, updates: Partial<Omit<Task, 'id'>>) => void;
  updateMultipleTasks: (ids: string[], updates: Partial<Omit<Task, 'id'>>) => void;
  updateTaskPriority: (id: string, priority: Task['priority']) => void;
}

export const useTaskStore = create<TaskStore>((set, get) => ({
  tasks: [],
  // ... other state

  // Generic partial update for a single task
  updateTask: (id: string, updates: Partial<Omit<Task, 'id'>>) => {
    set((state) => ({
      tasks: state.tasks.map((task) =>
        task.id === id
          ? { ...task, ...updates }
          : task
      ),
    }));
  },

  // Update multiple tasks at once
  updateMultipleTasks: (ids: string[], updates: Partial<Omit<Task, 'id'>>) => {
    set((state) => ({
      tasks: state.tasks.map((task) =>
        ids.includes(task.id)
          ? { ...task, ...updates }
          : task
      ),
    }));
  },

  // Specific update with type safety
  updateTaskPriority: (id: string, priority: Task['priority']) => {
    set((state) => ({
      tasks: state.tasks.map((task) =>
        task.id === id
          ? { ...task, priority }
          : task
      ),
    }));
  },

  // Real-world: Toggle task with partial update
  toggleTask: (id: string) => {
    set((state) => ({
      tasks: state.tasks.map((task) =>
        task.id === id
          ? { ...task, completed: !task.completed }
          : task
      ),
    }));
  },
}));
```

---

## The Verification: Testing State Updates

### Step 1: Create a Test Component

```tsx
// src/components/StateUpdateTest.tsx
import React, { useState } from 'react';
import { useTaskStore } from '../store/taskStore';
import { RenderCounter } from './RenderCounter';

function StateUpdateTest() {
  const [newTaskText, setNewTaskText] = useState('');
  const [updateText, setUpdateText] = useState('');
  const [updateId, setUpdateId] = useState('');
  
  // Subscribe to state
  const tasks = useTaskStore((state) => state.tasks);
  const loading = useTaskStore((state) => state.loading);
  const error = useTaskStore((state) => state.error);
  
  // Get actions
  const addTask = useTaskStore((state) => state.addTask);
  const updateTaskText = useTaskStore((state) => state.updateTaskText);
  const toggleAllTasks = useTaskStore((state) => state.toggleAllTasks);
  const removeCompletedTasks = useTaskStore((state) => state.removeCompletedTasks);
  const resetStore = useTaskStore((state) => state.resetStore);
  const reorderTasks = useTaskStore((state) => state.reorderTasks);

  return (
    <div style={{ padding: '20px', maxWidth: '800px', margin: '0 auto' }}>
      <h1>State Update Patterns Test</h1>
      
      {/* Render counter */}
      <RenderCounter name="StateUpdateTest" />
      
      {/* Add Task */}
      <div style={{ marginBottom: '20px' }}>
        <h3>1. Add Task (Functional Update)</h3>
        <input
          type="text"
          value={newTaskText}
          onChange={(e) => setNewTaskText(e.target.value)}
          placeholder="Task text..."
        />
        <button onClick={() => {
          if (newTaskText.trim()) {
            addTask(newTaskText);
            setNewTaskText('');
          }
        }}>
          Add Task
        </button>
      </div>

      {/* Update Task */}
      <div style={{ marginBottom: '20px' }}>
        <h3>2. Update Task Text (Functional Update)</h3>
        <input
          type="text"
          value={updateId}
          onChange={(e) => setUpdateId(e.target.value)}
          placeholder="Task ID..."
          style={{ width: '100px' }}
        />
        <input
          type="text"
          value={updateText}
          onChange={(e) => setUpdateText(e.target.value)}
          placeholder="New text..."
        />
        <button onClick={() => {
          if (updateId && updateText.trim()) {
            updateTaskText(updateId, updateText);
            setUpdateText('');
          }
        }}>
          Update Task
        </button>
      </div>

      {/* Batch Operations */}
      <div style={{ marginBottom: '20px' }}>
        <h3>3. Batch Operations</h3>
        <button onClick={() => toggleAllTasks(true)}>
          Complete All
        </button>
        <button onClick={() => toggleAllTasks(false)}>
          Uncomplete All
        </button>
        <button onClick={() => removeCompletedTasks()}>
          Remove Completed
        </button>
        <button onClick={() => resetStore()}>
          Reset Store
        </button>
      </div>

      {/* Reorder Tasks */}
      <div style={{ marginBottom: '20px' }}>
        <h3>4. Reorder Tasks</h3>
        <button onClick={() => reorderTasks(0, 1)}>
          Swap First Two Tasks
        </button>
      </div>

      {/* Task List */}
      <div>
        <h3>Tasks ({tasks.length})</h3>
        {error && <div style={{ color: 'red' }}>Error: {error}</div>}
        {loading && <div>Loading...</div>}
        <ul style={{ listStyle: 'none', padding: 0 }}>
          {tasks.map((task, index) => (
            <li key={task.id} style={{
              padding: '8px',
              marginBottom: '4px',
              backgroundColor: task.completed ? '#e8f5e9' : '#f5f5f5',
              borderLeft: `4px solid ${task.completed ? '#4caf50' : '#2196f3'}`,
            }}>
              <strong>{index + 1}.</strong> {task.text}
              {task.completed && ' ✅'}
              <span style={{ marginLeft: '10px', fontSize: '12px', color: '#666' }}>
                ID: {task.id.slice(0, 8)}
              </span>
            </li>
          ))}
        </ul>
      </div>
    </div>
  );
}

export default StateUpdateTest;
```

### Step 2: Manual Testing Checklist

Test each update pattern:

1. **Functional Updates**:
   - [ ] Add multiple tasks — each should appear correctly
   - [ ] Update a task's text — should update only that task
   - [ ] Toggle a task — should toggle only that task

2. **Batch Updates**:
   - [ ] Complete All — all tasks should show completed
   - [ ] Uncomplete All — all tasks should show not completed
   - [ ] Remove Completed — only completed tasks disappear

3. **Reset**:
   - [ ] Reset Store — all tasks should be removed, filters reset

4. **Reordering**:
   - [ ] Swap First Two — tasks should swap positions

### Step 3: Performance Verification

Add this to your browser console to verify updates are working correctly:

```javascript
// In browser console
const store = useTaskStore;

// Subscribe to changes
const unsubscribe = store.subscribe((state, prevState) => {
  console.log('State changed:', {
    tasks: state.tasks.map(t => ({ id: t.id, text: t.text, completed: t.completed })),
    tasksChanged: state.tasks !== prevState.tasks,
    filterChanged: state.filter !== prevState.filter,
  });
});

// Test updates
store.getState().addTask('Console test task');
store.getState().toggleTask(store.getState().tasks[0].id);
store.getState().resetStore();

// Clean up
unsubscribe();
```

---

## Deep Dive: Understanding State Updates

### The `set` Function Internals

Here's how Zustand's `set` function works internally:

```javascript
// Simplified internal implementation
function create(createState) {
  let state;
  const listeners = new Set();
  
  const setState = (partial, replace) => {
    // 1. Determine the next state
    const nextState = typeof partial === 'function'
      ? partial(state)  // Functional update
      : partial;        // Object update
    
    // 2. Merge or replace state
    const next = replace 
      ? (typeof nextState === 'function' ? nextState(state) : nextState)
      : Object.assign({}, state, nextState);
    
    // 3. Check if state actually changed
    if (!Object.is(next, state)) {
      const prevState = state;
      state = next;
      
      // 4. Notify all listeners
      listeners.forEach(listener => listener(state, prevState));
    }
  };
  
  // ...
}
```

### Update Patterns Comparison

| Pattern | When to Use | Example |
|---------|-------------|---------|
| **Object Update** | Simple, independent state changes | `set({ loading: true })` |
| **Functional Update** | Updates depend on current state | `set((state) => ({ count: state.count + 1 }))` |
| **Batch Update** | Multiple pieces of state change together | `set({ tasks, loading: false, error: null })` |
| **Partial Update** | Updating nested objects | `set({ user: { ...state.user, name: 'Bob' } })` |
| **Reset** | Clearing or restoring state | `set(initialState)` |

---

## Common Pitfalls and Solutions

### Pitfall 1: Direct Array Mutation

```typescript
// ❌ WRONG: Mutates the array directly
addTask: (text) => {
  set((state) => {
    state.tasks.push({ id: Date.now(), text, completed: false });
    return state;
  });
}

// ✅ CORRECT: Creates a new array
addTask: (text) => {
  set((state) => ({
    tasks: [...state.tasks, { id: Date.now(), text, completed: false }]
  }));
}
```

### Pitfall 2: Shallow Copy of Nested Objects

```typescript
// ❌ WRONG: Only shallow copies the object
updateUser: (updates) => {
  set((state) => ({
    user: { ...state.user, ...updates } // Only one level deep!
  }));
}

// ✅ CORRECT: Copies all nested objects
updateUser: (updates) => {
  set((state) => ({
    user: {
      ...state.user,
      ...updates,
      preferences: {
        ...state.user.preferences,
        ...(updates.preferences || {})
      }
    }
  }));
}
```

### Pitfall 3: Using `get()` for Every Update

```typescript
// ❌ UNNECESSARY: Using get() when not needed
addTask: (text) => {
  const state = get();
  set({ tasks: [...state.tasks, { text }] });
}

// ✅ BETTER: Use functional update
addTask: (text) => {
  set((state) => ({
    tasks: [...state.tasks, { text }]
  }));
}
```

### Pitfall 4: Not Handling Async Errors

```typescript
// ❌ DANGEROUS: No error handling
fetchTasks: async () => {
  set({ loading: true });
  const response = await fetch('/api/tasks');
  const tasks = await response.json();
  set({ tasks, loading: false });
}

// ✅ SAFE: With error handling
fetchTasks: async () => {
  set({ loading: true, error: null });
  try {
    const response = await fetch('/api/tasks');
    if (!response.ok) throw new Error('Failed to fetch');
    const tasks = await response.json();
    set({ tasks, loading: false });
  } catch (error) {
    set({ error: error.message, loading: false });
  }
}
```

---

## Advanced Pattern: Undo/Redo Functionality

Here's a taste of what's possible with immutable updates:

```typescript
// src/store/undoStore.ts
import { create } from 'zustand';

interface UndoState {
  history: any[];
  currentIndex: number;
  currentState: any;
  canUndo: boolean;
  canRedo: boolean;
  pushState: (state: any) => void;
  undo: () => void;
  redo: () => void;
}

export const useUndoStore = create<UndoState>((set, get) => ({
  history: [],
  currentIndex: -1,
  currentState: null,
  canUndo: false,
  canRedo: false,
  
  pushState: (state: any) => {
    const { history, currentIndex } = get();
    // Remove any future states (if we've undone)
    const newHistory = history.slice(0, currentIndex + 1);
    newHistory.push(state);
    
    set({
      history: newHistory,
      currentIndex: newHistory.length - 1,
      currentState: state,
      canUndo: newHistory.length > 1,
      canRedo: false,
    });
  },
  
  undo: () => {
    const { history, currentIndex } = get();
    if (currentIndex <= 0) return;
    
    const newIndex = currentIndex - 1;
    set({
      currentIndex: newIndex,
      currentState: history[newIndex],
      canUndo: newIndex > 0,
      canRedo: true,
    });
  },
  
  redo: () => {
    const { history, currentIndex } = get();
    if (currentIndex >= history.length - 1) return;
    
    const newIndex = currentIndex + 1;
    set({
      currentIndex: newIndex,
      currentState: history[newIndex],
      canUndo: true,
      canRedo: newIndex < history.length - 1,
    });
  },
}));
```

---

## Key Takeaways

1. **Never mutate state**: Always create new objects and arrays
2. **Use functional updates**: When updates depend on current state
3. **Batch related updates**: Single `set` call for multiple state changes
4. **Handle errors**: Always catch async errors and update error state
5. **Reset with initial state**: Keep initial state in a constant
6. **Partial updates**: Use spread operators to update specific fields
7. **Keep state normalized**: Avoid deep nesting for easier updates

---

## What's Next

Now that you're a master of state updates, it's time to explore the broader ecosystem. In the next section, you'll learn how to use Zustand outside React, in utility modules, and in service layers.
