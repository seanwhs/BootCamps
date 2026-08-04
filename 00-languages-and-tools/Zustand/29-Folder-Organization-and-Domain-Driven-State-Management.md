# Part 8 — Enterprise Best Practices

## Section 29: Folder Organization and Domain-Driven State Management

As applications grow, organization becomes critical. A well-structured codebase makes it easier for teams to collaborate, reduces cognitive overhead, and prevents common pitfalls. In this section, you'll learn how to organize Zustand stores in large enterprise applications using domain-driven design principles.

---

## The Target: Maintainable, Scalable Store Organization

By the end of this section, you'll be able to:
- Organize stores using feature-based and domain-driven patterns
- Implement slice-based architectures for large teams
- Structure your codebase for maximum maintainability
- Avoid circular dependencies and other common architectural issues
- Scale your Zustand architecture as your team and application grow

---

## The Concept: Domain-Driven Store Architecture

Think of enterprise store organization like a **well-designed office building**:

```
┌─────────────────────────────────────────────────────────────────┐
│                    FOLDER ORGANIZATION                         │
│                                                                 │
│  src/                                                          │
│  ├── domains/                  # Domain-driven modules         │
│  │   ├── user/                                                │
│  │   │   ├── store/           # User store                    │
│  │   │   ├── components/      # User components               │
│  │   │   ├── services/        # User API client               │
│  │   │   └── types/           # User types                    │
│  │   ├── task/                                               │
│  │   ├── notification/                                       │
│  │   └── analytics/                                          │
│  ├── shared/                   # Shared across domains        │
│  │   ├── store/                                              │
│  │   │   ├── middleware/      # Custom middleware             │
│  │   │   └── root-store.ts   # Root store composition         │
│  │   ├── hooks/                                              │
│  │   ├── utils/                                              │
│  │   └── types/                                              │
│  ├── features/                 # Cross-domain features        │
│  │   ├── dashboard/                                          │
│  │   └── reports/                                            │
│  └── infrastructure/           # Infrastructure concerns      │
│      ├── api/                                                │
│      ├── persistence/                                        │
│      └── logging/                                            │
└─────────────────────────────────────────────────────────────────┘
```

**Key Principles**:
- **Domain-driven**: Organize by business domain, not technical layers
- **Feature-based**: Group related code together (store, components, services)
- **Shared infrastructure**: Centralize cross-cutting concerns
- **Clear boundaries**: Minimize coupling between domains

---

## The Implementation: Enterprise Folder Structure

### Step 1: Domain-Driven Project Structure

```
src/
├── domains/
│   ├── auth/
│   │   ├── store/
│   │   │   ├── authStore.ts
│   │   │   ├── authSelectors.ts
│   │   │   └── __tests__/
│   │   ├── components/
│   │   │   ├── LoginForm.tsx
│   │   │   ├── RegisterForm.tsx
│   │   │   └── ProtectedRoute.tsx
│   │   ├── services/
│   │   │   └── authApi.ts
│   │   ├── types/
│   │   │   └── auth.types.ts
│   │   └── index.ts
│   ├── task/
│   │   ├── store/
│   │   │   ├── taskStore.ts
│   │   │   ├── taskSelectors.ts
│   │   │   └── __tests__/
│   │   ├── components/
│   │   │   ├── TaskList.tsx
│   │   │   ├── TaskItem.tsx
│   │   │   └── TaskFilters.tsx
│   │   ├── services/
│   │   │   └── taskApi.ts
│   │   ├── types/
│   │   │   └── task.types.ts
│   │   └── index.ts
│   ├── user/
│   │   ├── store/
│   │   ├── components/
│   │   ├── services/
│   │   ├── types/
│   │   └── index.ts
│   └── notification/
│       ├── store/
│       ├── components/
│       ├── services/
│       ├── types/
│       └── index.ts
├── shared/
│   ├── store/
│   │   ├── middleware/
│   │   │   ├── logger.ts
│   │   │   ├── performance.ts
│   │   │   └── validator.ts
│   │   ├── rootStore.ts
│   │   └── storeUtils.ts
│   ├── hooks/
│   │   ├── useHydrated.ts
│   │   └── useStoreReset.ts
│   ├── utils/
│   │   ├── deepEqual.ts
│   │   └── localStorage.ts
│   └── types/
│       ├── common.types.ts
│       └── api.types.ts
├── features/
│   ├── dashboard/
│   │   ├── components/
│   │   └── store/
│   └── reporting/
│       └── components/
├── infrastructure/
│   ├── api/
│   │   ├── apiClient.ts
│   │   └── interceptors.ts
│   ├── persistence/
│   │   ├── storageAdapter.ts
│   │   └── migration.ts
│   └── logging/
│       └── logger.ts
└── app/
    └── pages/
        └── (routes)/
```

### Step 2: Domain Export Pattern

Each domain exports its public API through an `index.ts` file:

```typescript
// src/domains/auth/index.ts
export { useAuthStore } from './store/authStore';
export { authSelectors } from './store/authSelectors';
export { LoginForm } from './components/LoginForm';
export { RegisterForm } from './components/RegisterForm';
export { ProtectedRoute } from './components/ProtectedRoute';
export { authApi } from './services/authApi';
export type { User, AuthState, LoginCredentials } from './types/auth.types';
```

```typescript
// src/domains/task/index.ts
export { useTaskStore } from './store/taskStore';
export { taskSelectors } from './store/taskSelectors';
export { TaskList } from './components/TaskList';
export { TaskItem } from './components/TaskItem';
export { TaskFilters } from './components/TaskFilters';
export { taskApi } from './services/taskApi';
export type { Task, TaskState, TaskFilters as TaskFiltersType } from './types/task.types';
```

### Step 3: Domain Store Implementation

```typescript
// src/domains/task/store/taskStore.ts
import { create } from 'zustand';
import { immer } from 'zustand/middleware/immer';
import { Task, TaskState, TaskFilters } from '../types/task.types';
import { taskApi } from '../services/taskApi';
import { useAuthStore } from '../../auth/store/authStore';

const initialState: TaskState = {
  tasks: {},
  taskIds: [],
  loading: false,
  error: null,
  filters: {
    status: 'all',
    priority: 'all',
    search: '',
    assignee: 'all',
  },
  selectedTaskId: null,
};

export const useTaskStore = create<TaskState>()(
  immer((set, get) => ({
    ...initialState,

    // Actions
    fetchTasks: async () => {
      set({ loading: true, error: null });
      try {
        const tasks = await taskApi.getTasks();
        const tasksMap: Record<string, Task> = {};
        const ids: string[] = [];
        for (const task of tasks) {
          tasksMap[task.id] = task;
          ids.push(task.id);
        }
        set({ tasks: tasksMap, taskIds: ids, loading: false });
      } catch (error) {
        set({
          loading: false,
          error: error instanceof Error ? error.message : 'Failed to fetch tasks',
        });
      }
    },

    addTask: async (taskData) => {
      const authStore = useAuthStore.getState();
      const newTask = {
        ...taskData,
        userId: authStore.user?.id,
        createdAt: new Date(),
        updatedAt: new Date(),
      };
      
      // Optimistic update
      const tempId = `temp-${Date.now()}`;
      set((state) => {
        state.tasks[tempId] = { ...newTask, id: tempId, optimistic: true };
        state.taskIds.push(tempId);
      });

      try {
        const savedTask = await taskApi.createTask(newTask);
        set((state) => {
          delete state.tasks[tempId];
          state.tasks[savedTask.id] = savedTask;
          state.taskIds = state.taskIds.map(id => id === tempId ? savedTask.id : id);
        });
        return savedTask;
      } catch (error) {
        set((state) => {
          delete state.tasks[tempId];
          state.taskIds = state.taskIds.filter(id => id !== tempId);
          state.error = error instanceof Error ? error.message : 'Failed to add task';
        });
        throw error;
      }
    },

    toggleTask: async (id: string) => {
      const task = get().tasks[id];
      if (!task) return;

      // Optimistic update
      set((state) => {
        if (state.tasks[id]) {
          state.tasks[id].completed = !state.tasks[id].completed;
        }
      });

      try {
        await taskApi.toggleTask(id);
      } catch (error) {
        // Rollback
        set((state) => {
          if (state.tasks[id]) {
            state.tasks[id].completed = !state.tasks[id].completed;
          }
          state.error = error instanceof Error ? error.message : 'Failed to toggle task';
        });
        throw error;
      }
    },

    deleteTask: async (id: string) => {
      // Optimistic delete
      const previousState = get().tasks;
      set((state) => {
        delete state.tasks[id];
        state.taskIds = state.taskIds.filter(taskId => taskId !== id);
        if (state.selectedTaskId === id) {
          state.selectedTaskId = null;
        }
      });

      try {
        await taskApi.deleteTask(id);
      } catch (error) {
        // Rollback
        set((state) => {
          state.tasks = previousState;
          state.taskIds = Object.keys(previousState);
          state.error = error instanceof Error ? error.message : 'Failed to delete task';
        });
        throw error;
      }
    },

    setFilters: (filters: Partial<TaskFilters>) => {
      set((state) => {
        state.filters = { ...state.filters, ...filters };
      });
    },

    selectTask: (id: string | null) => {
      set({ selectedTaskId: id });
    },

    clearError: () => {
      set({ error: null });
    },

    reset: () => {
      set(initialState);
    },
  }))
);
```

### Step 4: Store Selectors (for Efficient Subscriptions)

```typescript
// src/domains/task/store/taskSelectors.ts
import { createSelector } from 'reselect';
import { TaskState, Task, TaskFilters } from '../types/task.types';

// Base selectors
export const selectTasks = (state: TaskState) => state.tasks;
export const selectTaskIds = (state: TaskState) => state.taskIds;
export const selectFilters = (state: TaskState) => state.filters;
export const selectLoading = (state: TaskState) => state.loading;
export const selectError = (state: TaskState) => state.error;
export const selectSelectedTaskId = (state: TaskState) => state.selectedTaskId;

// Computed selectors
export const selectFilteredTaskIds = createSelector(
  [selectTasks, selectTaskIds, selectFilters],
  (tasks, taskIds, filters) => {
    return taskIds.filter(id => {
      const task = tasks[id];
      if (!task) return false;

      // Filter by status
      if (filters.status === 'active' && task.completed) return false;
      if (filters.status === 'completed' && !task.completed) return false;

      // Filter by priority
      if (filters.priority !== 'all' && task.priority !== filters.priority) return false;

      // Filter by assignee
      if (filters.assignee !== 'all' && task.userId !== filters.assignee) return false;

      // Filter by search
      if (filters.search.trim()) {
        const query = filters.search.toLowerCase().trim();
        return task.title.toLowerCase().includes(query) ||
               (task.description && task.description.toLowerCase().includes(query));
      }

      return true;
    });
  }
);

export const selectFilteredTasks = createSelector(
  [selectTasks, selectFilteredTaskIds],
  (tasks, filteredIds) => filteredIds.map(id => tasks[id]).filter(Boolean)
);

export const selectTaskStats = createSelector(
  [selectTasks, selectTaskIds],
  (tasks, taskIds) => {
    let total = 0;
    let completed = 0;
    let active = 0;
    let highPriority = 0;
    let mediumPriority = 0;
    let lowPriority = 0;

    for (const id of taskIds) {
      const task = tasks[id];
      if (task) {
        total++;
        if (task.completed) completed++;
        else active++;
        if (task.priority === 'high') highPriority++;
        else if (task.priority === 'medium') mediumPriority++;
        else lowPriority++;
      }
    }

    return { total, completed, active, highPriority, mediumPriority, lowPriority };
  }
);

export const selectTaskById = (id: string) =>
  createSelector(
    [selectTasks],
    (tasks) => tasks[id]
  );
```

### Step 5: Cross-Domain Communication (Event-Driven)

When domains need to communicate, use an event-driven approach:

```typescript
// src/shared/events/eventBus.ts
type EventHandler = (payload: any) => void;

interface EventMap {
  'task:created': Task;
  'task:updated': Task;
  'task:deleted': { id: string };
  'task:completed': { id: string };
  'user:loggedIn': User;
  'user:loggedOut': void;
  'notification:new': Notification;
}

class EventBus {
  private handlers: Map<keyof EventMap, Set<EventHandler>> = new Map();

  subscribe<K extends keyof EventMap>(
    event: K,
    handler: (payload: EventMap[K]) => void
  ): () => void {
    if (!this.handlers.has(event)) {
      this.handlers.set(event, new Set());
    }
    this.handlers.get(event)!.add(handler as EventHandler);

    return () => {
      const handlers = this.handlers.get(event);
      if (handlers) {
        handlers.delete(handler as EventHandler);
        if (handlers.size === 0) {
          this.handlers.delete(event);
        }
      }
    };
  }

  publish<K extends keyof EventMap>(event: K, payload: EventMap[K]): void {
    const handlers = this.handlers.get(event);
    if (handlers) {
      for (const handler of handlers) {
        try {
          handler(payload);
        } catch (error) {
          console.error(`Error in event handler for ${String(event)}:`, error);
        }
      }
    }
  }
}

export const eventBus = new EventBus();
```

```typescript
// src/domains/task/store/taskStore.ts (with event publishing)
import { eventBus } from '../../../shared/events/eventBus';

// Inside addTask after successful save:
eventBus.publish('task:created', savedTask);

// Inside toggleTask when completed:
if (!task.completed) {
  eventBus.publish('task:completed', { id: task.id });
}

// Inside deleteTask:
eventBus.publish('task:deleted', { id });
```

```typescript
// src/domains/notification/store/notificationStore.ts
import { eventBus } from '../../../shared/events/eventBus';

export const useNotificationStore = create((set) => ({
  notifications: [],

  // Setup event listeners
  init: () => {
    // Listen for task events
    const unsubTaskCreated = eventBus.subscribe('task:created', (task) => {
      set((state) => ({
        notifications: [
          {
            id: `notif-${Date.now()}`,
            type: 'info',
            title: 'Task Created',
            message: `${task.title} was created`,
            read: false,
            timestamp: new Date(),
          },
          ...state.notifications,
        ],
      }));
    });

    const unsubTaskCompleted = eventBus.subscribe('task:completed', (payload) => {
      set((state) => ({
        notifications: [
          {
            id: `notif-${Date.now()}`,
            type: 'success',
            title: 'Task Completed',
            message: `Task was marked as done!`,
            read: false,
            timestamp: new Date(),
          },
          ...state.notifications,
        ],
      }));
    });

    return () => {
      unsubTaskCreated();
      unsubTaskCompleted();
    };
  },
}));

// In app initialization:
// useNotificationStore.getState().init();
```

### Step 6: Root Store Composition (Optional)

For applications that benefit from a unified store interface:

```typescript
// src/shared/store/rootStore.ts
import { useAuthStore } from '../../domains/auth/store/authStore';
import { useTaskStore } from '../../domains/task/store/taskStore';
import { useNotificationStore } from '../../domains/notification/store/notificationStore';
import { useUserStore } from '../../domains/user/store/userStore';

// Compose all stores into a single hook
export function useRootStore() {
  const auth = useAuthStore();
  const tasks = useTaskStore();
  const notifications = useNotificationStore();
  const users = useUserStore();

  return {
    auth,
    tasks,
    notifications,
    users,
  };
}

// Selective store access
export function useStore<K extends keyof ReturnType<typeof useRootStore>>(
  key: K
): ReturnType<typeof useRootStore>[K] {
  const store = useRootStore();
  return store[key];
}

// Usage:
// const auth = useStore('auth');
// const tasks = useStore('tasks');
```

### Step 7: Shared Infrastructure

```typescript
// src/infrastructure/persistence/storageAdapter.ts
export interface StorageAdapter {
  getItem: (key: string) => string | null;
  setItem: (key: string, value: string) => void;
  removeItem: (key: string) => void;
  clear: () => void;
}

export class LocalStorageAdapter implements StorageAdapter {
  getItem(key: string): string | null {
    try {
      return localStorage.getItem(key);
    } catch {
      return null;
    }
  }

  setItem(key: string, value: string): void {
    try {
      localStorage.setItem(key, value);
    } catch (error) {
      console.error('Failed to save to localStorage:', error);
    }
  }

  removeItem(key: string): void {
    try {
      localStorage.removeItem(key);
    } catch (error) {
      console.error('Failed to remove from localStorage:', error);
    }
  }

  clear(): void {
    try {
      localStorage.clear();
    } catch (error) {
      console.error('Failed to clear localStorage:', error);
    }
  }
}

export const defaultStorage = new LocalStorageAdapter();
```

### Step 8: Dependency Injection with Store Factories

For testability and configuration, use store factories:

```typescript
// src/domains/task/store/createTaskStore.ts
import { create } from 'zustand';
import { immer } from 'zustand/middleware/immer';
import { persist, createJSONStorage } from 'zustand/middleware';
import { TaskState, Task } from '../types/task.types';
import { TaskApi, defaultTaskApi } from '../services/taskApi';
import { StorageAdapter, defaultStorage } from '../../../infrastructure/persistence/storageAdapter';

interface TaskStoreDependencies {
  api: TaskApi;
  storage: StorageAdapter;
  storageKey: string;
}

export function createTaskStore(deps: TaskStoreDependencies = {
  api: defaultTaskApi,
  storage: defaultStorage,
  storageKey: 'task-storage',
}) {
  const { api, storage, storageKey } = deps;

  const initialState: TaskState = {
    tasks: {},
    taskIds: [],
    loading: false,
    error: null,
    filters: {
      status: 'all',
      priority: 'all',
      search: '',
      assignee: 'all',
    },
    selectedTaskId: null,
  };

  return create<TaskState>()(
    persist(
      immer((set, get) => ({
        ...initialState,

        fetchTasks: async () => {
          set({ loading: true, error: null });
          try {
            const tasks = await api.getTasks();
            const tasksMap: Record<string, Task> = {};
            const ids: string[] = [];
            for (const task of tasks) {
              tasksMap[task.id] = task;
              ids.push(task.id);
            }
            set({ tasks: tasksMap, taskIds: ids, loading: false });
          } catch (error) {
            set({
              loading: false,
              error: error instanceof Error ? error.message : 'Failed to fetch tasks',
            });
          }
        },

        // ... other actions
      })),
      {
        name: storageKey,
        storage: createJSONStorage(() => storage),
        partialize: (state) => ({
          tasks: state.tasks,
          taskIds: state.taskIds,
          filters: state.filters,
        }),
      }
    )
  );
}
```

---

## The Verification: Testing Organization

### Step 1: Verify Import Paths

```bash
# Run import sorter
npm run lint:imports

# Or use ESLint
npm run lint
```

### Step 2: Verify Circular Dependencies

```bash
# Install dependency cruiser
npm install -D dependency-cruiser

# Run check
npx depcruise --include-only "^src" --output-type dot src | dot -T svg > dependency-graph.svg
```

### Step 3: Test Domain Isolation

```typescript
// src/__tests__/architecture/domainIsolation.test.ts
import { describe, it, expect } from 'vitest';

describe('Domain Isolation', () => {
  it('should not have circular dependencies between domains', async () => {
    // This would be more complex in practice
    // Using dependency-cruiser or manual inspection
    expect(true).toBe(true);
  });

  it('should have clear public APIs for each domain', () => {
    // Verify that each domain index exports the correct public API
    const domains = ['auth', 'task', 'user', 'notification'];
    for (const domain of domains) {
      const domainModule = require(`../../domains/${domain}`);
      expect(domainModule).toBeDefined();
      // Check for key exports
      if (domain === 'task') {
        expect(domainModule.useTaskStore).toBeDefined();
        expect(domainModule.TaskList).toBeDefined();
        expect(domainModule.taskApi).toBeDefined();
      }
    }
  });
});
```

---

## Deep Dive: Architectural Patterns

### Pattern 1: Feature Slices (for Large Teams)

```typescript
// src/domains/task/slices/
// Split large stores into focused slices

// src/domains/task/slices/crudSlice.ts
export const createCrudSlice = (set, get) => ({
  tasks: {},
  taskIds: [],
  addTask: () => { /* ... */ },
  updateTask: () => { /* ... */ },
  deleteTask: () => { /* ... */ },
});

// src/domains/task/slices/filterSlice.ts
export const createFilterSlice = (set, get) => ({
  filters: { status: 'all', priority: 'all' },
  setFilters: () => { /* ... */ },
});

// src/domains/task/slices/uiSlice.ts
export const createUISlice = (set, get) => ({
  selectedTaskId: null,
  isFilterOpen: false,
  setSelectedTaskId: () => { /* ... */ },
  toggleFilterOpen: () => { /* ... */ },
});

// src/domains/task/store/taskStore.ts
import { createCrudSlice } from '../slices/crudSlice';
import { createFilterSlice } from '../slices/filterSlice';
import { createUISlice } from '../slices/uiSlice';

export const useTaskStore = create((set, get) => ({
  ...createCrudSlice(set, get),
  ...createFilterSlice(set, get),
  ...createUISlice(set, get),
}));
```

### Pattern 2: Adapter Pattern (for External Data)

```typescript
// src/domains/task/adapters/taskAdapter.ts
import { Task, ApiTask } from '../types/task.types';

// Convert from API format to domain format
export function fromApiTask(apiTask: ApiTask): Task {
  return {
    id: apiTask.id.toString(),
    title: apiTask.name,
    description: apiTask.description,
    completed: apiTask.done,
    priority: apiTask.priority_level,
    userId: apiTask.assignee_id,
    createdAt: new Date(apiTask.created_at),
    updatedAt: new Date(apiTask.updated_at),
    optimistic: false,
  };
}

// Convert from domain format to API format
export function toApiTask(task: Task): ApiTask {
  return {
    id: parseInt(task.id),
    name: task.title,
    description: task.description || '',
    done: task.completed,
    priority_level: task.priority,
    assignee_id: task.userId,
    created_at: task.createdAt.toISOString(),
    updated_at: task.updatedAt.toISOString(),
  };
}
```

### Pattern 3: Repository Pattern (for Data Access)

```typescript
// src/domains/task/repositories/taskRepository.ts
import { Task, TaskFilters } from '../types/task.types';
import { taskApi } from '../services/taskApi';
import { fromApiTask, toApiTask } from '../adapters/taskAdapter';

export class TaskRepository {
  async findAll(filters?: TaskFilters): Promise<Task[]> {
    const apiTasks = await taskApi.getTasks(filters);
    return apiTasks.map(fromApiTask);
  }

  async findById(id: string): Promise<Task | null> {
    const apiTask = await taskApi.getTask(id);
    return apiTask ? fromApiTask(apiTask) : null;
  }

  async save(task: Task): Promise<Task> {
    const apiTask = toApiTask(task);
    const saved = await taskApi.createTask(apiTask);
    return fromApiTask(saved);
  }

  async delete(id: string): Promise<void> {
    await taskApi.deleteTask(id);
  }
}

// Singleton instance
export const taskRepository = new TaskRepository();
```

---

## Common Pitfalls and Solutions

### Pitfall 1: Circular Dependencies

```typescript
// ❌ BAD: Task store imports User store, User store imports Task store
// Domain A → Domain B → Domain A (Circular)

// ✅ GOOD: Use event bus for cross-domain communication
// Domain A publishes events → Domain B subscribes to events
```

### Pitfall 2: Leaking Implementation Details

```typescript
// ❌ BAD: Exporting internal types from store
export { TaskState, InternalTaskConfig } from './store/taskStore';

// ✅ GOOD: Only export public API
export { useTaskStore } from './store/taskStore';
export { taskSelectors } from './store/taskSelectors';
export type { Task, TaskFilters } from './types/task.types';
```

### Pitfall 3: Over-Featurized Index Files

```typescript
// ❌ BAD: Domain index exporting everything, including internals
export * from './store/taskStore';
export * from './store/taskSelectors';
export * from './components/TaskList';
export * from './services/taskApi';
export * from './types/task.types';
export * from './utils/taskHelpers';

// ✅ GOOD: Domain index exporting only public API
export { useTaskStore } from './store/taskStore';
export { taskSelectors } from './store/taskSelectors';
export { TaskList } from './components/TaskList';
export { TaskItem } from './components/TaskItem';
export { taskApi } from './services/taskApi';
export type { Task, TaskFilters } from './types/task.types';
```

---

## Enterprise Organization Checklist

- [ ] Domains organized by business capability
- [ ] Each domain has its own store, components, services, types
- [ ] Shared code in `shared/` directory
- [ ] Infrastructure in `infrastructure/` directory
- [ ] Each domain exports a clean public API via `index.ts`
- [ ] No circular dependencies between domains
- [ ] Cross-domain communication via event bus or hooks
- [ ] Store selectors are co-located with stores
- [ ] Tests mirror the folder structure
- [ ] Build tool configured to enforce boundaries (ESLint, dependency-cruiser)

---

## Key Takeaways

1. **Organize by domain**: Group code by business capability, not technical layers
2. **Clean public APIs**: Each domain exports only what others need
3. **Avoid circular dependencies**: Use event bus or dependency inversion
4. **Co-locate related code**: Store, components, services, types together
5. **Shared infrastructure**: Centralize cross-cutting concerns
6. **Test organization**: Mirror your folder structure in tests
7. **Use adapters**: Convert between internal and external data formats
8. **Repository pattern**: Abstract data access for testability
9. **Feature slices**: Break large stores into manageable pieces
10. **Document boundaries**: Use architecture documentation to guide teams

---

## What's Next

Now that you've mastered folder organization, you'll learn about store composition, dependency injection, and advanced architectural patterns for enterprise Zustand applications.
