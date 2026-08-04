# Part 1 — Foundations & Core Concepts

## Section 5: Working with Vanilla Stores

Throughout this series, we've been using Zustand's React hooks to manage state. But Zustand's power extends far beyond React. In this section, you'll discover how to use Zustand stores in vanilla JavaScript/TypeScript environments—without React, without hooks, and in any context where you need a simple, predictable state container.

---

## The Target: Zustand Beyond React

By the end of this section, you'll be able to:
- Create and use stores outside React components
- Integrate Zustand with utility modules and service layers
- Build event-driven architectures with Zustand
- Share state between React and non-React code seamlessly
- Use Zustand in Node.js environments

---

## The Concept: Stores as Standalone State Containers

Think of Zustand stores as **smart containers** that can exist anywhere, like a universal remote control that works with any TV, regardless of brand.

### React vs. Vanilla Stores

```
React Environment:
┌─────────────────────────────────────────┐
│  React Component                        │
│  useStore() ──► Zustand Store          │
│  (with hooks)    (state + actions)     │
└─────────────────────────────────────────┘

Vanilla Environment:
┌─────────────────────────────────────────┐
│  Node.js Module                         │
│  store.getState() ──► Zustand Store    │
│  store.setState()    (state + actions) │
│  store.subscribe()                      │
└─────────────────────────────────────────┘

Both share the SAME store instance!
```

### Real-World Analogy

Imagine you have a **smart home system**:

- **React Components**: Like light switches on your wall (UI)
- **Vanilla Code**: Like sensors and timers (background logic)
- **Zustand Store**: Like the central hub that manages all devices
- **Subscriptions**: Like sending notifications to your phone

The hub doesn't care whether a command comes from a switch (React) or a timer (vanilla)—it just manages the state.

---

## The Implementation: Vanilla Stores

### Step 1: Creating a Vanilla Store

First, let's understand the difference between `create` and `createStore`:

```typescript
// React version (with hooks)
import { create } from 'zustand';
export const useTaskStore = create<TaskStore>((set) => ({
  tasks: [],
  // ... actions
}));

// Vanilla version (no hooks)
import { createStore } from 'zustand/vanilla';
export const taskStore = createStore<TaskStore>((set) => ({
  tasks: [],
  // ... actions
}));
```

Let's create a vanilla store that will be shared across React and non-React code:

```typescript
// src/store/vanilla/taskStore.ts
import { createStore } from 'zustand/vanilla';

// --- Types ---
export interface Task {
  id: string;
  text: string;
  completed: boolean;
  createdAt: Date;
  priority: 'low' | 'medium' | 'high';
  tags: string[];
}

interface TaskStore {
  // State
  tasks: Task[];
  loading: boolean;
  error: string | null;
  filter: 'all' | 'active' | 'completed';
  searchQuery: string;
  
  // Actions
  addTask: (text: string, priority?: Task['priority']) => void;
  toggleTask: (id: string) => void;
  deleteTask: (id: string) => void;
  setFilter: (filter: 'all' | 'active' | 'completed') => void;
  setSearchQuery: (query: string) => void;
  clearTasks: () => void;
  
  // Computed values (in vanilla store)
  getStats: () => { total: number; completed: number; active: number };
  getFilteredTasks: () => Task[];
}

// --- Create the vanilla store ---
export const taskStore = createStore<TaskStore>((set, get) => ({
  // Initial state
  tasks: [],
  loading: false,
  error: null,
  filter: 'all',
  searchQuery: '',
  
  // --- Actions ---
  addTask: (text: string, priority: Task['priority'] = 'medium') => {
    set((state) => ({
      tasks: [
        ...state.tasks,
        {
          id: crypto.randomUUID(),
          text: text.trim(),
          completed: false,
          createdAt: new Date(),
          priority,
          tags: [],
        },
      ],
    }));
  },
  
  toggleTask: (id: string) => {
    set((state) => ({
      tasks: state.tasks.map((task) =>
        task.id === id ? { ...task, completed: !task.completed } : task
      ),
    }));
  },
  
  deleteTask: (id: string) => {
    set((state) => ({
      tasks: state.tasks.filter((task) => task.id !== id),
    }));
  },
  
  setFilter: (filter: 'all' | 'active' | 'completed') => {
    set({ filter });
  },
  
  setSearchQuery: (query: string) => {
    set({ searchQuery: query });
  },
  
  clearTasks: () => {
    set({ tasks: [] });
  },
  
  // --- Computed values ---
  getStats: () => {
    const state = get();
    const total = state.tasks.length;
    const completed = state.tasks.filter(t => t.completed).length;
    return {
      total,
      completed,
      active: total - completed,
    };
  },
  
  getFilteredTasks: () => {
    const state = get();
    let tasks = state.tasks;
    
    // Apply filter
    if (state.filter === 'active') {
      tasks = tasks.filter(t => !t.completed);
    } else if (state.filter === 'completed') {
      tasks = tasks.filter(t => t.completed);
    }
    
    // Apply search
    if (state.searchQuery.trim()) {
      const query = state.searchQuery.toLowerCase().trim();
      tasks = tasks.filter(t => t.text.toLowerCase().includes(query));
    }
    
    return tasks;
  },
}));

// --- Export convenience functions for common operations ---
export const taskActions = {
  addTask: (text: string, priority?: Task['priority']) => {
    taskStore.getState().addTask(text, priority);
  },
  toggleTask: (id: string) => {
    taskStore.getState().toggleTask(id);
  },
  deleteTask: (id: string) => {
    taskStore.getState().deleteTask(id);
  },
  clearTasks: () => {
    taskStore.getState().clearTasks();
  },
  getStats: () => {
    return taskStore.getState().getStats();
  },
  getFilteredTasks: () => {
    return taskStore.getState().getFilteredTasks();
  },
};
```

### Step 2: Using the Vanilla Store in React

To use a vanilla store in React components, we need to connect it:

```typescript
// src/hooks/useTaskStore.ts
import { useStore } from 'zustand';
import { taskStore } from '../store/vanilla/taskStore';

// Create a React hook that uses the vanilla store
export function useTaskStore<T>(
  selector: (state: ReturnType<typeof taskStore.getState>) => T
): T {
  return useStore(taskStore, selector);
}

// Or with default export
export const useTaskStoreHook = (selector: any) => useStore(taskStore, selector);
```

Now use it in React components:

```tsx
// src/components/VanillaTaskList.tsx
import React, { useState } from 'react';
import { useTaskStore } from '../hooks/useTaskStore';
import { taskActions } from '../store/vanilla/taskStore';
import type { Task } from '../store/vanilla/taskStore';

// Helper hook for getting filtered tasks
function useFilteredTasks() {
  return useTaskStore((state) => state.getFilteredTasks());
}

function useStats() {
  return useTaskStore((state) => state.getStats());
}

function VanillaTaskList() {
  const [newTask, setNewTask] = useState('');
  
  // Using the vanilla store through our custom hook
  const tasks = useFilteredTasks();
  const stats = useStats();
  const filter = useTaskStore((state) => state.filter);
  const searchQuery = useTaskStore((state) => state.searchQuery);
  
  // Actions from the store
  const addTask = useTaskStore((state) => state.addTask);
  const toggleTask = useTaskStore((state) => state.toggleTask);
  const deleteTask = useTaskStore((state) => state.deleteTask);
  const setFilter = useTaskStore((state) => state.setFilter);
  const setSearchQuery = useTaskStore((state) => state.setSearchQuery);
  const clearTasks = useTaskStore((state) => state.clearTasks);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (newTask.trim()) {
      addTask(newTask);
      setNewTask('');
    }
  };

  return (
    <div style={{ padding: '20px', maxWidth: '800px', margin: '0 auto' }}>
      <h1>📋 Vanilla Store Task Manager</h1>
      
      {/* Stats */}
      <div style={{ display: 'flex', gap: '20px', marginBottom: '20px' }}>
        <div>Total: {stats.total}</div>
        <div>Completed: {stats.completed}</div>
        <div>Active: {stats.active}</div>
      </div>
      
      {/* Add Task */}
      <form onSubmit={handleSubmit} style={{ marginBottom: '20px' }}>
        <input
          type="text"
          value={newTask}
          onChange={(e) => setNewTask(e.target.value)}
          placeholder="Add a task..."
          style={{ padding: '8px', marginRight: '8px', width: '300px' }}
        />
        <button type="submit" style={{ padding: '8px 16px' }}>
          Add Task
        </button>
        <button
          type="button"
          onClick={clearTasks}
          style={{ padding: '8px 16px', marginLeft: '8px', backgroundColor: '#dc3545', color: 'white' }}
        >
          Clear All
        </button>
      </form>
      
      {/* Filters */}
      <div style={{ marginBottom: '20px' }}>
        <button
          onClick={() => setFilter('all')}
          style={{ fontWeight: filter === 'all' ? 'bold' : 'normal' }}
        >
          All
        </button>
        <button
          onClick={() => setFilter('active')}
          style={{ fontWeight: filter === 'active' ? 'bold' : 'normal', marginLeft: '8px' }}
        >
          Active
        </button>
        <button
          onClick={() => setFilter('completed')}
          style={{ fontWeight: filter === 'completed' ? 'bold' : 'normal', marginLeft: '8px' }}
        >
          Completed
        </button>
        
        <input
          type="text"
          value={searchQuery}
          onChange={(e) => setSearchQuery(e.target.value)}
          placeholder="Search tasks..."
          style={{ padding: '8px', marginLeft: '20px', width: '200px' }}
        />
      </div>
      
      {/* Task List */}
      <ul style={{ listStyle: 'none', padding: 0 }}>
        {tasks.map((task) => (
          <li
            key={task.id}
            style={{
              padding: '12px',
              marginBottom: '8px',
              backgroundColor: task.completed ? '#e8f5e9' : '#f5f5f5',
              borderRadius: '4px',
              display: 'flex',
              alignItems: 'center',
            }}
          >
            <input
              type="checkbox"
              checked={task.completed}
              onChange={() => toggleTask(task.id)}
              style={{ marginRight: '12px' }}
            />
            <span
              style={{
                flex: 1,
                textDecoration: task.completed ? 'line-through' : 'none',
                color: task.completed ? '#666' : 'inherit',
              }}
            >
              {task.text}
              <span style={{ fontSize: '12px', color: '#999', marginLeft: '8px' }}>
                [{task.priority}]
              </span>
            </span>
            <span style={{ fontSize: '12px', color: '#999' }}>
              {task.createdAt.toLocaleTimeString()}
            </span>
            <button
              onClick={() => deleteTask(task.id)}
              style={{
                marginLeft: '12px',
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
        ))}
      </ul>
    </div>
  );
}

export default VanillaTaskList;
```

### Step 3: Using Vanilla Stores in Utility Modules

Here's how to use Zustand stores in utility modules and services:

```typescript
// src/services/taskService.ts
import { taskStore, taskActions } from '../store/vanilla/taskStore';

class TaskService {
  // Subscribe to store changes
  private unsubscribe: (() => void) | null = null;
  
  constructor() {
    // Log every state change
    this.unsubscribe = taskStore.subscribe((state, prevState) => {
      console.log('🔄 Task state changed:', {
        total: state.tasks.length,
        prevTotal: prevState.tasks.length,
        filter: state.filter,
        searchQuery: state.searchQuery,
      });
    });
    
    console.log('📊 TaskService initialized');
  }
  
  // Async operations
  async fetchTasksFromAPI(): Promise<void> {
    try {
      // We can use the store directly
      taskStore.setState({ loading: true, error: null });
      
      // Simulate API call
      const response = await fetch('/api/tasks');
      if (!response.ok) throw new Error('Failed to fetch tasks');
      const data = await response.json();
      
      // Update state with fetched tasks
      const currentState = taskStore.getState();
      taskStore.setState({
        tasks: [...currentState.tasks, ...data.tasks],
        loading: false,
      });
      
      console.log('✅ Tasks fetched successfully');
    } catch (error) {
      taskStore.setState({
        error: error.message,
        loading: false,
      });
      console.error('❌ Failed to fetch tasks:', error);
    }
  }
  
  // Background sync
  async syncTasks(): Promise<void> {
    const state = taskStore.getState();
    const activeTasks = state.tasks.filter(t => !t.completed);
    
    // Sync to server...
    console.log(`🔄 Syncing ${activeTasks.length} active tasks`);
  }
  
  // Clean up
  dispose(): void {
    if (this.unsubscribe) {
      this.unsubscribe();
      console.log('🧹 TaskService disposed');
    }
  }
}

// Export singleton
export const taskService = new TaskService();
```

### Step 4: Building an Event-Driven Architecture

Zustand's subscription system makes it perfect for event-driven architectures:

```typescript
// src/events/taskEvents.ts
import { taskStore } from '../store/vanilla/taskStore';

// --- Event Types ---
type TaskEvent = {
  type: 'TASK_ADDED' | 'TASK_TOGGLED' | 'TASK_DELETED' | 'TASKS_CLEARED';
  payload: any;
  timestamp: number;
};

type EventHandler = (event: TaskEvent) => void;

// --- Event System ---
class TaskEventSystem {
  private handlers: Map<string, EventHandler[]> = new Map();
  private eventHistory: TaskEvent[] = [];
  
  constructor() {
    // Subscribe to store changes and emit events
    taskStore.subscribe((state, prevState) => {
      // Detect what changed and emit appropriate events
      if (state.tasks.length !== prevState.tasks.length) {
        // Tasks were added or removed
        if (state.tasks.length > prevState.tasks.length) {
          // Find the new task
          const newTask = state.tasks.find(
            t => !prevState.tasks.some(pt => pt.id === t.id)
          );
          this.emit({
            type: 'TASK_ADDED',
            payload: newTask,
            timestamp: Date.now(),
          });
        } else {
          // Tasks were removed
          this.emit({
            type: 'TASK_DELETED',
            payload: { count: prevState.tasks.length - state.tasks.length },
            timestamp: Date.now(),
          });
        }
      }
      
      // Check if any tasks were toggled
      if (state.tasks.length > 0) {
        const toggled = state.tasks.find(
          (t) => {
            const prev = prevState.tasks.find(pt => pt.id === t.id);
            return prev && prev.completed !== t.completed;
          }
        );
        if (toggled) {
          this.emit({
            type: 'TASK_TOGGLED',
            payload: toggled,
            timestamp: Date.now(),
          });
        }
      }
    });
  }
  
  // Subscribe to events
  on(eventType: TaskEvent['type'], handler: EventHandler): () => void {
    if (!this.handlers.has(eventType)) {
      this.handlers.set(eventType, []);
    }
    this.handlers.get(eventType)!.push(handler);
    
    // Return unsubscribe function
    return () => {
      const handlers = this.handlers.get(eventType);
      if (handlers) {
        const index = handlers.indexOf(handler);
        if (index > -1) {
          handlers.splice(index, 1);
        }
      }
    };
  }
  
  // Emit an event
  private emit(event: TaskEvent): void {
    // Store history
    this.eventHistory.push(event);
    if (this.eventHistory.length > 100) {
      this.eventHistory.shift();
    }
    
    // Notify handlers
    const handlers = this.handlers.get(event.type) || [];
    handlers.forEach(handler => {
      try {
        handler(event);
      } catch (error) {
        console.error('Error in event handler:', error);
      }
    });
    
    console.log(`📢 Event emitted: ${event.type}`, event.payload);
  }
  
  // Get event history
  getHistory(): TaskEvent[] {
    return [...this.eventHistory];
  }
  
  // Clear history
  clearHistory(): void {
    this.eventHistory = [];
  }
}

// Export singleton
export const taskEvents = new TaskEventSystem();

// --- Example: Analytics Service ---
class AnalyticsService {
  private unsubscribe: () => void;
  
  constructor() {
    // Track task events for analytics
    this.unsubscribe = taskEvents.on('TASK_ADDED', (event) => {
      console.log('📊 Analytics: Task added', event.payload);
      // Send to analytics service...
    });
    
    taskEvents.on('TASK_COMPLETED', (event) => {
      console.log('📊 Analytics: Task completed', event.payload);
    });
  }
  
  dispose(): void {
    this.unsubscribe();
  }
}

// --- Example: Notification Service ---
class NotificationService {
  private unsubscribe: () => void;
  
  constructor() {
    // Show notifications for important events
    this.unsubscribe = taskEvents.on('TASK_ADDED', (event) => {
      console.log('🔔 Notification: New task added:', event.payload?.text);
    });
    
    taskEvents.on('TASKS_CLEARED', () => {
      console.log('🔔 Notification: All tasks cleared');
    });
  }
  
  dispose(): void {
    this.unsubscribe();
  }
}
```

### Step 5: Using Vanilla Stores in Node.js

Zustand works perfectly in Node.js environments:

```typescript
// src/server/taskServer.ts
import { taskStore, taskActions } from '../store/vanilla/taskStore';

// Node.js server using Zustand store
class TaskServer {
  private interval: NodeJS.Timeout | null = null;
  
  constructor() {
    console.log('🚀 Task Server Started');
    
    // Subscribe to store changes
    const unsubscribe = taskStore.subscribe((state) => {
      console.log(`📊 Server state: ${state.tasks.length} tasks`);
      // Could broadcast to connected clients via WebSocket
    });
    
    // Start background tasks
    this.startBackgroundSync();
    
    // Clean up on exit
    process.on('SIGTERM', () => {
      this.shutdown();
    });
  }
  
  private startBackgroundSync(): void {
    this.interval = setInterval(() => {
      const state = taskStore.getState();
      const activeTasks = state.tasks.filter(t => !t.completed);
      
      console.log(`🔄 Background sync: ${activeTasks.length} active tasks`);
      
      // Simulate syncing to a database
      if (activeTasks.length > 0) {
        console.log(`💾 Syncing ${activeTasks.length} tasks to database...`);
      }
    }, 30000); // Every 30 seconds
  }
  
  // API endpoints (for Express/Fastify)
  getTasks(): any {
    const state = taskStore.getState();
    return {
      tasks: state.tasks,
      stats: state.getStats(),
      filter: state.filter,
    };
  }
  
  createTask(text: string): void {
    taskActions.addTask(text);
  }
  
  completeTask(id: string): void {
    taskActions.toggleTask(id);
  }
  
  deleteTask(id: string): void {
    taskActions.deleteTask(id);
  }
  
  private shutdown(): void {
    console.log('🛑 Task Server shutting down...');
    if (this.interval) {
      clearInterval(this.interval);
      this.interval = null;
    }
  }
}

// Export singleton
export const taskServer = new TaskServer();
```

---

## The Verification: Testing Vanilla Stores

### Step 1: Create a Test Script

```typescript
// src/tests/vanillaStore.test.ts
import { taskStore, taskActions } from '../store/vanilla/taskStore';

// --- Test Suite ---
function runVanillaStoreTests() {
  console.log('🧪 Running Vanilla Store Tests...\n');
  
  // Test 1: Initial state
  console.log('Test 1: Initial state');
  const initialState = taskStore.getState();
  console.log(`  - Tasks: ${initialState.tasks.length}`);
  console.log(`  - Loading: ${initialState.loading}`);
  console.log(`  - Filter: ${initialState.filter}`);
  console.log(`  ✅ Initial state correct\n`);
  
  // Test 2: Add task
  console.log('Test 2: Add task');
  taskActions.addTask('Test task 1');
  taskActions.addTask('Test task 2', 'high');
  const stateAfterAdd = taskStore.getState();
  console.log(`  - Tasks: ${stateAfterAdd.tasks.length}`);
  console.log(`  - Tasks[0] text: ${stateAfterAdd.tasks[0].text}`);
  console.log(`  - Tasks[1] priority: ${stateAfterAdd.tasks[1].priority}`);
  console.log(`  ✅ Tasks added correctly\n`);
  
  // Test 3: Toggle task
  console.log('Test 3: Toggle task');
  const taskId = stateAfterAdd.tasks[0].id;
  taskActions.toggleTask(taskId);
  const stateAfterToggle = taskStore.getState();
  const toggledTask = stateAfterToggle.tasks.find(t => t.id === taskId);
  console.log(`  - Task completed: ${toggledTask?.completed}`);
  console.log(`  ✅ Task toggled correctly\n`);
  
  // Test 4: Filtering
  console.log('Test 4: Filtering');
  taskStore.setState({ filter: 'completed' });
  const filteredTasks = taskStore.getState().getFilteredTasks();
  console.log(`  - Completed tasks: ${filteredTasks.length}`);
  console.log(`  ✅ Filtering works correctly\n`);
  
  // Test 5: Stats
  console.log('Test 5: Stats');
  const stats = taskStore.getState().getStats();
  console.log(`  - Total: ${stats.total}`);
  console.log(`  - Completed: ${stats.completed}`);
  console.log(`  - Active: ${stats.active}`);
  console.log(`  ✅ Stats calculated correctly\n`);
  
  // Test 6: Subscription
  console.log('Test 6: Subscription');
  let subscriptionCalled = false;
  const unsubscribe = taskStore.subscribe((state) => {
    subscriptionCalled = true;
    console.log(`  📢 State changed: ${state.tasks.length} tasks`);
  });
  
  taskActions.clearTasks();
  console.log(`  - Subscription triggered: ${subscriptionCalled}`);
  console.log(`  ✅ Subscription works correctly\n`);
  
  // Clean up
  unsubscribe();
  
  console.log('✅ All tests passed!\n');
}

// Run tests
runVanillaStoreTests();
```

### Step 2: Manual Testing in Node.js

```bash
# Run the test script
npx ts-node src/tests/vanillaStore.test.ts
```

Expected output:
```
🧪 Running Vanilla Store Tests...

Test 1: Initial state
  - Tasks: 0
  - Loading: false
  - Filter: all
  ✅ Initial state correct

Test 2: Add task
  - Tasks: 2
  - Tasks[0] text: Test task 1
  - Tasks[1] priority: high
  ✅ Tasks added correctly

Test 3: Toggle task
  - Task completed: true
  ✅ Task toggled correctly

Test 4: Filtering
  - Completed tasks: 1
  ✅ Filtering works correctly

Test 5: Stats
  - Total: 2
  - Completed: 1
  - Active: 1
  ✅ Stats calculated correctly

Test 6: Subscription
  📢 State changed: 0 tasks
  - Subscription triggered: true
  ✅ Subscription works correctly

✅ All tests passed!
```

### Step 3: Browser Console Testing

Open your browser console and test the vanilla store:

```javascript
// Import the store (assuming it's exposed globally)
import { taskStore, taskActions } from './src/store/vanilla/taskStore';

// Test in console
console.log('Current state:', taskStore.getState());

// Add tasks
taskActions.addTask('Console task 1');
taskActions.addTask('Console task 2', 'high');

// Subscribe to changes
const unsubscribe = taskStore.subscribe((state) => {
  console.log('🔔 State updated:', {
    tasks: state.tasks.length,
    filter: state.filter,
  });
});

// Toggle a task
const tasks = taskStore.getState().tasks;
if (tasks.length > 0) {
  taskActions.toggleTask(tasks[0].id);
}

// Get stats
console.log('Stats:', taskStore.getState().getStats());

// Clear tasks
taskActions.clearTasks();

// Clean up
unsubscribe();
```

---

## Deep Dive: Vanilla Store API

### The `createStore` Function

```typescript
import { createStore } from 'zustand/vanilla';

// Full API
const store = createStore((set, get, store) => ({
  // State
  count: 0,
  
  // Actions
  increment: () => set((state) => ({ count: state.count + 1 })),
  
  // Computed (using get)
  getDouble: () => get().count * 2,
}));

// Store API
store.getState();        // Get current state
store.setState({ count: 5 }); // Update state
store.subscribe(callback); // Subscribe to changes
store.destroy();          // Clean up
```

### Advanced Subscription Patterns

```typescript
// src/store/vanilla/advancedSubscriptions.ts
import { createStore } from 'zustand/vanilla';

interface DataStore {
  data: any[];
  loading: boolean;
  error: string | null;
  lastUpdate: Date | null;
}

const dataStore = createStore<DataStore>((set) => ({
  data: [],
  loading: false,
  error: null,
  lastUpdate: null,
}));

// 1. Subscribe to specific state changes
const unsub1 = dataStore.subscribe((state, prevState) => {
  if (state.loading !== prevState.loading) {
    console.log('Loading state changed:', state.loading);
  }
});

// 2. Subscribe with selector (filter what you care about)
const unsub2 = dataStore.subscribe(
  // Selector: extract what you care about
  (state) => state.data.length,
  // Callback: called when selected value changes
  (length) => {
    console.log('Data length changed to:', length);
  }
);

// 3. Subscribe with equality function
const unsub3 = dataStore.subscribe(
  (state) => state.data,
  (data) => {
    console.log('Data reference changed');
  },
  // Custom equality check
  (a, b) => a.length === b.length && a.every((item, i) => item === b[i])
);

// 4. Subscribe once (get current state, then unsubscribe)
const snapshot = dataStore.getState();
console.log('Current state:', snapshot);
```

---

## Common Pitfalls and Solutions

### Pitfall 1: Mixing React and Vanilla APIs

```typescript
// ❌ WRONG: Using React hook with vanilla store
import { useTaskStore } from './store/vanilla/taskStore';
const tasks = useTaskStore((state) => state.tasks); // This won't work!

// ✅ CORRECT: Use the vanilla store correctly
import { useStore } from 'zustand';
import { taskStore } from './store/vanilla/taskStore';
const tasks = useStore(taskStore, (state) => state.tasks);
```

### Pitfall 2: Not Unsubscribing

```typescript
// ❌ DANGEROUS: Memory leak
const unsubscribe = taskStore.subscribe(handleChange);
// Never calling unsubscribe()

// ✅ SAFE: Always unsubscribe
const unsubscribe = taskStore.subscribe(handleChange);
// Later...
unsubscribe();
```

### Pitfall 3: Mutating State Outside Set

```typescript
// ❌ WRONG: Mutating state directly
const state = taskStore.getState();
state.tasks.push(newTask); // This mutates!
// Changes won't trigger updates

// ✅ CORRECT: Use setState
taskStore.setState((state) => ({
  tasks: [...state.tasks, newTask]
}));
```

---

## Key Takeaways

1. **Vanilla stores work anywhere**: React, Node.js, browsers, utilities
2. **Share state between React and non-React code**: Same store instance works everywhere
3. **Use `createStore` for vanilla**: Different from React's `create`
4. **Subscribe to changes**: Powerful event-driven patterns
5. **Clean up subscriptions**: Prevent memory leaks
6. **Use selectors for efficiency**: Subscribe to specific changes
7. **Server-side rendering compatible**: Works with Node.js
8. **Test independently**: Vanilla stores are easier to test

---

## What's Next

You've now mastered Zustand from the ground up! In Part 2, we'll dive into advanced state architecture patterns, including structuring large applications, middleware, persistence, and debugging.
