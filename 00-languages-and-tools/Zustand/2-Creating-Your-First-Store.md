# Part 1 — Foundations & Core Concepts

## Section 2: Creating Your First Store

Now that you understand Zustand's philosophy and architecture, it's time to get your hands dirty. In this section, you'll create your first store from scratch and connect it to a React component.

---

## The Target: Your First Zustand Store

We're going to build a **Task Management Store** that handles:
- Storing a list of tasks
- Adding new tasks
- Toggling task completion
- Deleting tasks

This store will be the foundation for everything we build in this series.

---

## The Concept: Stores, State, and Actions

Think of a store as a **smart container** that holds your application's data (state) and the ways to change it (actions).

```
┌─────────────────────────────────────────────────────┐
│                    TASK STORE                       │
│                                                     │
│  ┌──────────────────────────────────────────────┐  │
│  │  STATE (The Data)                           │  │
│  │  • tasks: [{id, text, completed}]           │  │
│  │  • loading: false                           │  │
│  │  • error: null                              │  │
│  └──────────────────────────────────────────────┘  │
│                                                     │
│  ┌──────────────────────────────────────────────┐  │
│  │  ACTIONS (The Ways to Change Data)          │  │
│  │  • addTask(text) → adds new task           │  │
│  │  • toggleTask(id) → toggles completion     │  │
│  │  • deleteTask(id) → removes task           │  │
│  └──────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────┘
```

**State** is the "what" — the data your application needs.
**Actions** are the "how" — the functions that update that data.

### A Real-World Analogy

Imagine you have a physical **bulletin board** on your wall:

- **State**: The notes pinned to the board
- **Actions**: 
  - "Add Note" (pin a new note)
  - "Toggle Note" (mark a note as done with a checkmark)
  - "Remove Note" (take a note down)

Zustand's store is like having a smart bulletin board that:
1. Keeps track of all notes
2. Remembers which notes are done
3. Notifies everyone looking at it when a note changes
4. Only tells people about changes to notes they care about

---

## The Implementation: Building Your First Store

### Step 1: Project Setup

First, let's create a fresh project to work with:

```bash
# Create project directory
mkdir zustand-tutorial
cd zustand-tutorial

# Initialize npm project
npm init -y

# Install dependencies
npm install react react-dom zustand
npm install -D typescript @types/react @types/react-dom vite

# Create the project structure
mkdir -p src
```

### Step 2: Create Your Store

Create the file `src/store/taskStore.ts`:

```typescript
// src/store/taskStore.ts
import { create } from 'zustand';

// --- 1. Define the types for our state ---
// This ensures type safety throughout our application
export interface Task {
  id: string;
  text: string;
  completed: boolean;
  createdAt: Date;
}

// --- 2. Define the shape of our store ---
// This describes what data and actions our store will have
interface TaskStore {
  // State
  tasks: Task[];
  loading: boolean;
  error: string | null;
  
  // Actions
  addTask: (text: string) => void;
  toggleTask: (id: string) => void;
  deleteTask: (id: string) => void;
  clearTasks: () => void;
}

// --- 3. Create the store using Zustand's create function ---
// The create function takes a "builder" function that receives
// `set` and `get` parameters:
// - `set`: Used to update state (like React's setState)
// - `get`: Used to read current state (useful for computed values)

export const useTaskStore = create<TaskStore>((set, get) => ({
  // --- Initial State ---
  tasks: [],
  loading: false,
  error: null,

  // --- Action: Add a new task ---
  // The `set` function can receive either:
  // 1. A partial state object, OR
  // 2. A function that receives current state and returns a partial update
  addTask: (text: string) => {
    // IMPORTANT: We use the functional form of `set` to ensure
    // we're working with the latest state
    set((state) => {
      // Create a new task object
      const newTask: Task = {
        id: crypto.randomUUID(), // Generate a unique ID
        text: text.trim(),
        completed: false,
        createdAt: new Date(),
      };

      // Return the updated state
      // Note: We're creating a new array by spreading the old one
      // This is important for immutability and triggering updates
      return {
        tasks: [...state.tasks, newTask],
      };
    });
  },

  // --- Action: Toggle a task's completion status ---
  toggleTask: (id: string) => {
    set((state) => ({
      tasks: state.tasks.map((task) =>
        task.id === id
          ? { ...task, completed: !task.completed }
          : task
      ),
    }));
  },

  // --- Action: Delete a task ---
  deleteTask: (id: string) => {
    set((state) => ({
      tasks: state.tasks.filter((task) => task.id !== id),
    }));
  },

  // --- Action: Clear all tasks ---
  clearTasks: () => {
    set({ tasks: [] });
  },
}));
```

### Step 3: Understanding the Store Creation

Let's break down what's happening in the code above:

#### The `create` Function

```typescript
export const useTaskStore = create<TaskStore>((set, get) => ({
  // State and actions here
}));
```

- `create` is the main function from Zustand
- `<TaskStore>` is a TypeScript generic that defines the store's shape
- The callback receives `set` and `get` functions:
  - `set`: Used to update state (works like React's setState)
  - `get`: Retrieves the current state (useful for actions that need current state)

#### The `set` Function

```typescript
// Method 1: Direct object update
set({ tasks: [] });

// Method 2: Functional update (recommended for updates based on current state)
set((state) => ({
  tasks: [...state.tasks, newTask]
}));
```

**Why use functional updates?** When your update depends on the current state, the functional form guarantees you're working with the latest state, preventing race conditions.

#### Immutability in Zustand

**Crucial concept**: In Zustand, you MUST never mutate state directly. Instead, you create new objects/arrays.

```typescript
// ❌ WRONG: Mutating state directly
set((state) => {
  state.tasks.push(newTask); // This mutates the array!
  return state; // This won't trigger updates properly
});

// ✅ CORRECT: Creating new objects/arrays
set((state) => ({
  tasks: [...state.tasks, newTask] // Creates a new array
}));
```

**Why immutability matters:**
1. **Performance**: React uses reference equality to detect changes
2. **Predictability**: State changes are explicit and traceable
3. **Debugging**: You can see exactly what changed

---

### Step 4: Using the Store in React Components

Now let's create a React component that uses our store. Create `src/App.tsx`:

```tsx
// src/App.tsx
import React, { useState } from 'react';
import { useTaskStore } from './store/taskStore';

// --- Main App Component ---
function App() {
  return (
    <div style={{ maxWidth: '600px', margin: '0 auto', padding: '20px' }}>
      <h1>📋 Task Manager with Zustand</h1>
      <AddTaskForm />
      <TaskList />
      <TaskStats />
    </div>
  );
}

// --- Component: Add Task Form ---
function AddTaskForm() {
  // Local state for the input field (this is NOT global state)
  const [text, setText] = useState('');
  
  // Get the addTask action from our store
  const addTask = useTaskStore((state) => state.addTask);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (text.trim()) {
      addTask(text);
      setText(''); // Clear the input
    }
  };

  return (
    <form onSubmit={handleSubmit} style={{ marginBottom: '20px' }}>
      <div style={{ display: 'flex', gap: '10px' }}>
        <input
          type="text"
          value={text}
          onChange={(e) => setText(e.target.value)}
          placeholder="What needs to be done?"
          style={{
            flex: 1,
            padding: '10px',
            fontSize: '16px',
            border: '1px solid #ccc',
            borderRadius: '4px',
          }}
        />
        <button
          type="submit"
          style={{
            padding: '10px 20px',
            backgroundColor: '#007bff',
            color: 'white',
            border: 'none',
            borderRadius: '4px',
            cursor: 'pointer',
          }}
        >
          Add Task
        </button>
      </div>
    </form>
  );
}

// --- Component: Task List ---
function TaskList() {
  // CRITICAL: We're only subscribing to the tasks array
  // This component will ONLY re-render when tasks change
  const tasks = useTaskStore((state) => state.tasks);
  const toggleTask = useTaskStore((state) => state.toggleTask);
  const deleteTask = useTaskStore((state) => state.deleteTask);

  if (tasks.length === 0) {
    return (
      <div style={{ textAlign: 'center', color: '#666', padding: '40px' }}>
        No tasks yet. Add one above!
      </div>
    );
  }

  return (
    <ul style={{ listStyle: 'none', padding: 0 }}>
      {tasks.map((task) => (
        <TaskItem
          key={task.id}
          task={task}
          onToggle={toggleTask}
          onDelete={deleteTask}
        />
      ))}
    </ul>
  );
}

// --- Component: Individual Task Item ---
function TaskItem({ 
  task, 
  onToggle, 
  onDelete 
}: { 
  task: Task; 
  onToggle: (id: string) => void; 
  onDelete: (id: string) => void;
}) {
  return (
    <li
      style={{
        display: 'flex',
        alignItems: 'center',
        gap: '10px',
        padding: '10px',
        backgroundColor: '#f8f9fa',
        marginBottom: '8px',
        borderRadius: '4px',
        borderLeft: task.completed ? '4px solid #28a745' : '4px solid #007bff',
      }}
    >
      <input
        type="checkbox"
        checked={task.completed}
        onChange={() => onToggle(task.id)}
        style={{ width: '20px', height: '20px', cursor: 'pointer' }}
      />
      <span
        style={{
          flex: 1,
          textDecoration: task.completed ? 'line-through' : 'none',
          color: task.completed ? '#6c757d' : '#212529',
        }}
      >
        {task.text}
      </span>
      <span style={{ fontSize: '12px', color: '#6c757d' }}>
        {task.createdAt.toLocaleTimeString()}
      </span>
      <button
        onClick={() => onDelete(task.id)}
        style={{
          padding: '4px 8px',
          backgroundColor: '#dc3545',
          color: 'white',
          border: 'none',
          borderRadius: '4px',
          cursor: 'pointer',
        }}
      >
        Delete
      </button>
    </li>
  );
}

// --- Component: Task Statistics ---
function TaskStats() {
  // We're using multiple selectors to get different pieces of state
  // Each subscription is independent
  const tasks = useTaskStore((state) => state.tasks);
  const totalTasks = tasks.length;
  const completedTasks = tasks.filter(t => t.completed).length;
  const pendingTasks = totalTasks - completedTasks;

  return (
    <div
      style={{
        marginTop: '20px',
        padding: '15px',
        backgroundColor: '#e9ecef',
        borderRadius: '4px',
        display: 'flex',
        justifyContent: 'space-around',
      }}
    >
      <div>
        <strong>Total:</strong> {totalTasks}
      </div>
      <div>
        <strong>Completed:</strong> {completedTasks}
      </div>
      <div>
        <strong>Pending:</strong> {pendingTasks}
      </div>
    </div>
  );
}

export default App;
```

### Step 5: Entry Point

Create `src/main.tsx`:

```tsx
// src/main.tsx
import React from 'react';
import ReactDOM from 'react-dom/client';
import App from './App';

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
);
```

### Step 6: HTML Template

Create `index.html` in the project root:

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Zustand Task Manager</title>
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.tsx"></script>
  </body>
</html>
```

### Step 7: Vite Configuration

Create `vite.config.ts`:

```typescript
// vite.config.ts
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
});
```

### Step 8: TypeScript Configuration

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
    "strict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noFallthroughCasesInSwitch": true
  },
  "include": ["src"],
  "references": [{ "path": "./tsconfig.node.json" }]
}
```

Create `tsconfig.node.json`:

```json
{
  "compilerOptions": {
    "composite": true,
    "skipLibCheck": true,
    "module": "ESNext",
    "moduleResolution": "bundler",
    "allowSyntheticDefaultImports": true
  },
  "include": ["vite.config.ts"]
}
```

---

## The Verification: Testing Your Store

### Step 1: Start the Development Server

```bash
# Install Vite as a dev dependency if not already installed
npm install -D vite @vitejs/plugin-react

# Run the development server
npm run dev
```

If you haven't added the dev script yet, update your `package.json`:

```json
{
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "preview": "vite preview"
  }
}
```

Open `http://localhost:5173` in your browser.

### Step 2: Manual Testing

1. **Add a Task**: Type "Buy groceries" and click "Add Task"
   - ✅ Should appear in the list immediately
   
2. **Toggle a Task**: Click the checkbox next to a task
   - ✅ Should show a line-through and change color
   
3. **Delete a Task**: Click the "Delete" button
   - ✅ Task should disappear from the list
   
4. **Check Statistics**: The stats at the bottom should update
   - ✅ Total, Completed, and Pending counts should update

### Step 3: Console Testing

Open your browser's Developer Tools console and run:

```javascript
// Get the current store state
const state = useTaskStore.getState();
console.log('Current tasks:', state.tasks);

// Add a task programmatically
const addTask = useTaskStore.getState().addTask;
addTask('Test task from console');
// ✅ Should see the task appear in the UI
```

### Step 4: Test Performance

Add this component to test subscription behavior:

```tsx
// Add this temporarily to App.tsx
function PerformanceTest() {
  console.log('🔄 PerformanceTest component rendered');
  const taskCount = useTaskStore((state) => state.tasks.length);
  return <div>Task count: {taskCount}</div>;
}
```

**Key Observation**: The component will only re-render when `taskCount` changes, not when individual task properties change.

### Step 5: Test Type Safety

If you're using TypeScript, try adding a task with the wrong type:

```typescript
// This should cause a TypeScript error
addTask(123); // ❌ Error: Argument of type 'number' is not assignable to parameter of type 'string'
```

---

## Deep Dive: Understanding Zustand's `set` Function

### The Two Forms of `set`

Zustand's `set` function has two forms:

#### 1. **Object Form** (Simple Updates)

```typescript
// When you don't need the current state
set({ loading: true });
set({ error: null });
```

**Use when**: Updating independent pieces of state that don't depend on other state.

#### 2. **Functional Form** (Updates Based on Current State)

```typescript
// When you need the current state to compute the next state
set((state) => ({
  tasks: [...state.tasks, newTask]
}));
```

**Use when**: Your update depends on the current state.

### Why Functional Updates Matter

Consider this scenario:

```typescript
// ❌ PROBLEM: Race condition with object form
const addTask = (text) => {
  const currentTasks = get().tasks; // Get current state
  set({
    tasks: [...currentTasks, { text, id: Date.now() }]
  });
};

// If two components call addTask at the same time:
// Component A: gets currentTasks = [task1]
// Component B: gets currentTasks = [task1] (same snapshot)
// Component A: sets tasks = [task1, task2]
// Component B: sets tasks = [task1, task3] // Oops, lost task2!
```

```typescript
// ✅ SOLUTION: Functional update
const addTask = (text) => {
  set((state) => ({
    tasks: [...state.tasks, { text, id: Date.now() }]
  }));
};
// No race conditions - both updates use the latest state
```

---

## Advanced Patterns: Adding Computed Values

Sometimes you want derived values that are automatically calculated from your state. Here's how to add them:

```typescript
// src/store/taskStore.ts (extended)
import { create } from 'zustand';

interface TaskStore {
  tasks: Task[];
  // ... other state
  
  // Computed values (these are read-only)
  getCompletedTasks: () => Task[];
  getPendingTasks: () => Task[];
  getTaskCount: () => number;
  getCompletedCount: () => number;
  
  // Actions
  // ...
}

export const useTaskStore = create<TaskStore>((set, get) => ({
  tasks: [],
  // ... other state
  
  // Computed values using `get`
  getCompletedTasks: () => get().tasks.filter(t => t.completed),
  getPendingTasks: () => get().tasks.filter(t => !t.completed),
  getTaskCount: () => get().tasks.length,
  getCompletedCount: () => get().tasks.filter(t => t.completed).length,
  
  // Actions...
}));

// Usage in component
function TaskStats() {
  const total = useTaskStore((state) => state.getTaskCount());
  const completed = useTaskStore((state) => state.getCompletedCount());
  // ...
}
```

**Important**: These computed values will recalculate whenever `tasks` changes because they use `get()` to access the current state.

---

## Common Pitfalls and Solutions

### Pitfall 1: Direct Mutation

```typescript
// ❌ WRONG
addTask: (text) => {
  set((state) => {
    state.tasks.push({ id: Date.now(), text, completed: false });
    return state; // Zustand sees the same reference, doesn't update
  });
}
```

```typescript
// ✅ CORRECT
addTask: (text) => {
  set((state) => ({
    tasks: [...state.tasks, { id: Date.now(), text, completed: false }]
  }));
}
```

### Pitfall 2: Forgetting to Use `set`

```typescript
// ❌ WRONG
addTask: (text) => {
  const newTask = { id: Date.now(), text };
  // Nothing happens - state isn't updated
}
```

```typescript
// ✅ CORRECT
addTask: (text) => {
  set((state) => ({
    tasks: [...state.tasks, { id: Date.now(), text }]
  }));
}
```

### Pitfall 3: Over-Subscribing

```typescript
// ❌ BAD: Component re-renders on ANY state change
const { tasks, loading, error } = useTaskStore();

// ✅ GOOD: Only subscribe to what you need
const tasks = useTaskStore((state) => state.tasks);
const loading = useTaskStore((state) => state.loading);
// Or use multiple selectors if you need multiple pieces
const { tasks, loading } = useTaskStore((state) => ({
  tasks: state.tasks,
  loading: state.loading
}));
```

---

## Key Takeaways

1. **Stores are created with `create()`**: This is the main entry point
2. **State is immutable**: Always create new objects/arrays
3. **Use the functional form of `set`** when updates depend on current state
4. **Components subscribe with selectors**: Only re-render when selected state changes
5. **Actions are functions that call `set`**: They're the only way to modify state
6. **`get()` provides access to current state**: Useful for computed values

---

## What's Next

In the next section, we'll explore how to read state efficiently using selectors, understand shallow comparisons, and optimize performance with proper subscription patterns.
