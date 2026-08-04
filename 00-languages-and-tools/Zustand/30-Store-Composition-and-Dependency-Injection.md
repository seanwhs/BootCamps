# Part 8 — Enterprise Best Practices

## Section 30: Store Composition and Dependency Injection

As your application grows, individual stores become more complex and interdependent. Managing these dependencies and composing stores together in a maintainable way is crucial for enterprise applications. In this section, you'll learn advanced patterns for store composition, dependency injection, and creating truly modular, testable state management.

---

## The Target: Composable, Testable Stores

By the end of this section, you'll be able to:
- Compose multiple stores together without creating circular dependencies
- Implement dependency injection for Zustand stores
- Build a service locator pattern for store dependencies
- Create factory functions for testable store instances
- Manage cross-store dependencies cleanly
- Implement the store registry pattern for dynamic store creation

---

## The Concept: Store Composition as a Lego System

Think of store composition like building with **Lego bricks**:

```
┌─────────────────────────────────────────────────────────────────┐
│                    STORE COMPOSITION                           │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Base Stores (Independent Bricks)                        │  │
│  │  • AuthStore          │  • TaskStore                     │  │
│  │  • UserStore          │  • NotificationStore             │  │
│  └──────────────────────────────────────────────────────────┘  │
│                         │                                      │
│                         ▼                                      │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Composed Stores (Connected Bricks)                     │  │
│  │  • DashboardStore = TaskStore + UserStore               │  │
│  │  • AdminStore = AuthStore + UserStore + AnalyticsStore  │  │
│  └──────────────────────────────────────────────────────────┘  │
│                         │                                      │
│                         ▼                                      │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Dependency Injection (Brick Connectors)                │  │
│  │  • Inject API clients                                    │  │
│  │  • Inject storage adapters                               │  │
│  │  • Inject other stores                                   │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

---

## The Implementation: Store Composition Patterns

### Step 1: Slice Pattern with Dependency Injection

Create slices that depend on injected dependencies:

```typescript
// src/domains/task/slices/crudSlice.ts
import { StateCreator } from 'zustand';
import { Task, TaskState } from '../types/task.types';
import { TaskApi } from '../services/taskApi';

// Define the slice state
export interface CrudSlice {
  tasks: Record<string, Task>;
  taskIds: string[];
  addTask: (task: Omit<Task, 'id'>) => Promise<Task>;
  updateTask: (id: string, updates: Partial<Task>) => Promise<void>;
  deleteTask: (id: string) => Promise<void>;
}

// Create the slice with dependencies injected
export const createCrudSlice = (
  api: TaskApi,
  getDependencies: () => { userId?: string }
): StateCreator<CrudSlice, [], [], CrudSlice> => {
  return (set, get) => ({
    tasks: {},
    taskIds: [],

    addTask: async (taskData) => {
      const deps = getDependencies();
      const newTask = {
        ...taskData,
        userId: deps.userId,
        createdAt: new Date(),
        updatedAt: new Date(),
      };

      // Optimistic update
      const tempId = `temp-${Date.now()}`;
      set((state) => ({
        tasks: {
          ...state.tasks,
          [tempId]: { ...newTask, id: tempId, optimistic: true },
        },
        taskIds: [...state.taskIds, tempId],
      }));

      try {
        const savedTask = await api.createTask(newTask);
        set((state) => {
          const { [tempId]: _, ...remaining } = state.tasks;
          return {
            tasks: { ...remaining, [savedTask.id]: savedTask },
            taskIds: state.taskIds.map(id => id === tempId ? savedTask.id : id),
          };
        });
        return savedTask;
      } catch (error) {
        // Rollback
        set((state) => {
          const { [tempId]: _, ...remaining } = state.tasks;
          return {
            tasks: remaining,
            taskIds: state.taskIds.filter(id => id !== tempId),
          };
        });
        throw error;
      }
    },

    updateTask: async (id, updates) => {
      const currentTask = get().tasks[id];
      if (!currentTask) return;

      // Optimistic update
      set((state) => ({
        tasks: {
          ...state.tasks,
          [id]: { ...state.tasks[id], ...updates, optimistic: true },
        },
      }));

      try {
        const updatedTask = await api.updateTask(id, updates);
        set((state) => ({
          tasks: {
            ...state.tasks,
            [id]: { ...updatedTask, optimistic: false },
          },
        }));
      } catch (error) {
        // Rollback
        set((state) => ({
          tasks: {
            ...state.tasks,
            [id]: currentTask,
          },
        }));
        throw error;
      }
    },

    deleteTask: async (id) => {
      const previousTasks = get().tasks;
      set((state) => {
        const { [id]: _, ...remaining } = state.tasks;
        return {
          tasks: remaining,
          taskIds: state.taskIds.filter(taskId => taskId !== id),
        };
      });

      try {
        await api.deleteTask(id);
      } catch (error) {
        // Rollback
        set((state) => ({
          tasks: previousTasks,
          taskIds: Object.keys(previousTasks),
        }));
        throw error;
      }
    },
  });
};
```

### Step 2: Creating the Main Store with DI

```typescript
// src/domains/task/store/createTaskStore.ts
import { create, StoreApi } from 'zustand';
import { immer } from 'zustand/middleware/immer';
import { persist, createJSONStorage } from 'zustand/middleware';
import { Task, TaskFilters } from '../types/task.types';
import { TaskApi } from '../services/taskApi';
import { StorageAdapter } from '../../../infrastructure/persistence/storageAdapter';
import { createCrudSlice, CrudSlice } from '../slices/crudSlice';
import { createFilterSlice, FilterSlice } from '../slices/filterSlice';
import { createUISlice, UISlice } from '../slices/uiSlice';

// Combined store type
export interface TaskStore extends CrudSlice, FilterSlice, UISlice {
  loading: boolean;
  error: string | null;
  fetchTasks: () => Promise<void>;
  clearError: () => void;
  reset: () => void;
}

// Dependencies interface
export interface TaskStoreDependencies {
  api: TaskApi;
  storage: StorageAdapter;
  storageKey?: string;
  getUserId?: () => string | undefined;
}

// Factory function
export function createTaskStore(deps: TaskStoreDependencies) {
  const {
    api,
    storage,
    storageKey = 'task-storage',
    getUserId = () => undefined,
  } = deps;

  // Create the store
  return create<TaskStore>()(
    persist(
      immer((set, get) => ({
        // Initial state
        loading: false,
        error: null,
        tasks: {},
        taskIds: [],
        filters: {
          status: 'all',
          priority: 'all',
          search: '',
          assignee: 'all',
        },
        selectedTaskId: null,
        isFilterOpen: false,

        // Include all slices
        ...createCrudSlice(api, { getUserId })(set, get),
        ...createFilterSlice()(set, get),
        ...createUISlice()(set, get),

        // Store-level actions
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

        clearError: () => {
          set({ error: null });
        },

        reset: () => {
          set({
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
            isFilterOpen: false,
          });
        },
      })),
      {
        name: storageKey,
        storage: createJSONStorage(() => storage),
        partialize: (state) => ({
          tasks: state.tasks,
          taskIds: state.taskIds,
          filters: state.filters,
          selectedTaskId: state.selectedTaskId,
        }),
      }
    )
  );
}

// Default instance
import { defaultTaskApi } from '../services/taskApi';
import { defaultStorage } from '../../../infrastructure/persistence/storageAdapter';

export const useTaskStore = createTaskStore({
  api: defaultTaskApi,
  storage: defaultStorage,
  getUserId: () => {
    // In production, get from auth store
    return useAuthStore?.getState?.().user?.id;
  },
});
```

### Step 3: DI Container / Service Locator

For more complex applications, implement a DI container:

```typescript
// src/infrastructure/di/container.ts
export class DependencyContainer {
  private services: Map<string, any> = new Map();
  private factories: Map<string, () => any> = new Map();
  private singletons: Map<string, any> = new Map();

  register<T>(key: string, instance: T): void {
    this.services.set(key, instance);
  }

  registerFactory<T>(key: string, factory: () => T): void {
    this.factories.set(key, factory);
  }

  registerSingleton<T>(key: string, factory: () => T): void {
    this.factories.set(key, () => {
      if (!this.singletons.has(key)) {
        this.singletons.set(key, factory());
      }
      return this.singletons.get(key);
    });
  }

  resolve<T>(key: string): T {
    // Check if we have a direct instance
    if (this.services.has(key)) {
      return this.services.get(key);
    }

    // Check if we have a factory
    if (this.factories.has(key)) {
      return this.factories.get(key)();
    }

    throw new Error(`Service ${key} not found in container`);
  }

  has(key: string): boolean {
    return this.services.has(key) || this.factories.has(key);
  }

  clear(): void {
    this.services.clear();
    this.factories.clear();
    this.singletons.clear();
  }
}

// Create global container
export const container = new DependencyContainer();

// Register services
import { defaultTaskApi } from '../../domains/task/services/taskApi';
import { defaultStorage } from '../persistence/storageAdapter';

container.register('taskApi', defaultTaskApi);
container.register('storage', defaultStorage);

// Register singleton store factories
container.registerSingleton('taskStore', () => {
  return createTaskStore({
    api: container.resolve('taskApi'),
    storage: container.resolve('storage'),
  });
});

// Helper to resolve stores
export function useStore<T>(key: string): T {
  return container.resolve<T>(key);
}

// Usage in components
function TaskList() {
  const taskStore = useStore<TaskStore>('taskStore');
  // ... use taskStore
}
```

### Step 4: Cross-Store Dependencies

When stores depend on each other, use the container:

```typescript
// src/domains/dashboard/store/dashboardStore.ts
import { create } from 'zustand';
import { immer } from 'zustand/middleware/immer';
import { container } from '../../../infrastructure/di/container';
import { TaskStore } from '../../task/store/createTaskStore';
import { UserStore } from '../../user/store/createUserStore';

export interface DashboardStore {
  stats: {
    totalTasks: number;
    completedTasks: number;
    activeUsers: number;
    completionRate: number;
  };
  refresh: () => Promise<void>;
  reset: () => void;
}

// Factory function with DI
export function createDashboardStore(
  taskStore: TaskStore,
  userStore: UserStore
) {
  return create<DashboardStore>()(
    immer((set, get) => ({
      stats: {
        totalTasks: 0,
        completedTasks: 0,
        activeUsers: 0,
        completionRate: 0,
      },

      refresh: async () => {
        // Refresh dependent stores
        await Promise.all([
          taskStore.fetchTasks(),
          userStore.fetchUsers(),
        ]);

        // Compute stats
        const taskState = taskStore.getState?.();
        const userState = userStore.getState?.();
        
        if (taskState && userState) {
          const tasks = taskState.taskIds.map(id => taskState.tasks[id]).filter(Boolean);
          const totalTasks = tasks.length;
          const completedTasks = tasks.filter(t => t.completed).length;
          const activeUsers = userState.userIds.length;
          const completionRate = totalTasks > 0 ? (completedTasks / totalTasks) * 100 : 0;

          set({
            stats: {
              totalTasks,
              completedTasks,
              activeUsers,
              completionRate,
            },
          });
        }
      },

      reset: () => {
        set({
          stats: {
            totalTasks: 0,
            completedTasks: 0,
            activeUsers: 0,
            completionRate: 0,
          },
        });
      },
    }))
  );
}

// Register in container
container.registerSingleton('dashboardStore', () => {
  const taskStore = container.resolve<TaskStore>('taskStore');
  const userStore = container.resolve<UserStore>('userStore');
  return createDashboardStore(taskStore, userStore);
});
```

### Step 5: Store Registry Pattern

For dynamic store creation and management:

```typescript
// src/infrastructure/store/storeRegistry.ts
import { StoreApi } from 'zustand';

interface StoreRegistration<T = any> {
  id: string;
  store: StoreApi<T>;
  dependencies: string[];
  initialized: boolean;
}

export class StoreRegistry {
  private stores: Map<string, StoreRegistration> = new Map();
  private initializing: Map<string, Promise<StoreApi>> = new Map();

  register<T>(
    id: string,
    factory: () => StoreApi<T>,
    dependencies: string[] = []
  ): void {
    if (this.stores.has(id)) {
      throw new Error(`Store ${id} already registered`);
    }

    this.stores.set(id, {
      id,
      store: null as any,
      dependencies,
      initialized: false,
    });

    // Defer creation until get is called
    this.stores.set(id, {
      id,
      store: null as any,
      dependencies,
      initialized: false,
    });
  }

  async get<T>(id: string): Promise<StoreApi<T>> {
    const registration = this.stores.get(id);
    if (!registration) {
      throw new Error(`Store ${id} not registered`);
    }

    // If already initializing, wait for it
    if (this.initializing.has(id)) {
      return this.initializing.get(id)! as Promise<StoreApi<T>>;
    }

    // If already initialized, return it
    if (registration.initialized && registration.store) {
      return registration.store as StoreApi<T>;
    }

    // Initialize
    const initPromise = (async () => {
      // Initialize dependencies first
      for (const depId of registration.dependencies) {
        await this.get(depId);
      }

      // Now create this store
      const factory = (this.stores.get(id) as any).factory;
      if (!factory) {
        throw new Error(`No factory for store ${id}`);
      }

      const store = factory();
      this.stores.set(id, {
        ...registration,
        store,
        initialized: true,
      });

      // Remove from initializing map
      this.initializing.delete(id);

      return store;
    })();

    this.initializing.set(id, initPromise);
    return initPromise as Promise<StoreApi<T>>;
  }

  getSync<T>(id: string): StoreApi<T> {
    const registration = this.stores.get(id);
    if (!registration || !registration.initialized) {
      throw new Error(`Store ${id} not initialized`);
    }
    return registration.store as StoreApi<T>;
  }

  has(id: string): boolean {
    return this.stores.has(id);
  }

  clear(): void {
    this.stores.clear();
    this.initializing.clear();
  }
}

// Global registry
export const storeRegistry = new StoreRegistry();

// Register stores
import { useTaskStore, createTaskStore } from '../../domains/task/store/createTaskStore';
import { useUserStore, createUserStore } from '../../domains/user/store/createUserStore';
import { container } from '../di/container';

storeRegistry.register('taskStore', () => {
  return createTaskStore({
    api: container.resolve('taskApi'),
    storage: container.resolve('storage'),
    getUserId: () => container.resolve('authStore')?.getState?.().user?.id,
  });
}, []);

storeRegistry.register('userStore', () => {
  return createUserStore({
    api: container.resolve('userApi'),
    storage: container.resolve('storage'),
  });
}, []);

storeRegistry.register('dashboardStore', () => {
  const taskStore = storeRegistry.getSync('taskStore');
  const userStore = storeRegistry.getSync('userStore');
  return createDashboardStore(taskStore, userStore);
}, ['taskStore', 'userStore']);

// Usage in components
async function App() {
  // Initialize stores
  const taskStore = await storeRegistry.get('taskStore');
  const userStore = await storeRegistry.get('userStore');
  const dashboardStore = await storeRegistry.get('dashboardStore');
  // ...
}
```

### Step 6: Factory Pattern with Configuration

Create configurable store factories:

```typescript
// src/domains/task/store/configuredTaskStore.ts
export interface StoreConfig {
  apiBaseUrl: string;
  storagePrefix: string;
  enablePersistence: boolean;
  enableDevtools: boolean;
  enableLogging: boolean;
  batchUpdates: boolean;
  cacheTTL: number;
}

const defaultConfig: StoreConfig = {
  apiBaseUrl: '/api',
  storagePrefix: 'app',
  enablePersistence: true,
  enableDevtools: process.env.NODE_ENV === 'development',
  enableLogging: process.env.NODE_ENV === 'development',
  batchUpdates: true,
  cacheTTL: 60000,
};

export function createConfiguredTaskStore(config: Partial<StoreConfig> = {}) {
  const finalConfig = { ...defaultConfig, ...config };
  
  // Create API client with config
  const api = new TaskApi({
    baseUrl: finalConfig.apiBaseUrl,
  });

  // Create storage with config
  const storage = new ConfiguredStorage({
    prefix: finalConfig.storagePrefix,
  });

  // Create store
  const store = createTaskStore({
    api,
    storage,
    storageKey: `${finalConfig.storagePrefix}-tasks`,
  });

  // Apply middleware based on config
  let wrappedStore = store;

  if (finalConfig.enableLogging) {
    wrappedStore = createLoggerMiddleware()(wrappedStore as any);
  }

  if (finalConfig.enableDevtools) {
    wrappedStore = devtools(wrappedStore as any, { name: 'TaskStore' });
  }

  if (!finalConfig.enablePersistence) {
    // Override persist to be no-op
    // This would require more complex wrapping
  }

  return wrappedStore;
}
```

### Step 7: Testing Composed Stores

```typescript
// src/domains/task/__tests__/storeComposition.test.ts
import { describe, it, expect, beforeEach } from 'vitest';
import { createTaskStore } from '../store/createTaskStore';
import { createMockTaskApi } from '../services/__mocks__/mockTaskApi';
import { createMockStorage } from '../../../infrastructure/persistence/__mocks__/mockStorage';

describe('Store Composition', () => {
  it('should compose multiple slices correctly', async () => {
    const mockApi = createMockTaskApi();
    const mockStorage = createMockStorage();
    
    const store = createTaskStore({
      api: mockApi,
      storage: mockStorage,
      getUserId: () => 'user-1',
    });

    const state = store.getState();

    // Verify all slices are present
    expect(state.addTask).toBeDefined();
    expect(state.updateTask).toBeDefined();
    expect(state.deleteTask).toBeDefined();
    expect(state.setFilters).toBeDefined();
    expect(state.selectTask).toBeDefined();
    expect(state.fetchTasks).toBeDefined();
    expect(state.clearError).toBeDefined();
    expect(state.reset).toBeDefined();

    // Test that actions work together
    await state.addTask({ title: 'Test Task', description: 'Test', priority: 'medium' });
    await state.fetchTasks();
    
    const tasks = state.taskIds.map(id => state.tasks[id]).filter(Boolean);
    expect(tasks.length).toBeGreaterThan(0);
    expect(tasks[0].title).toBe('Test Task');
  });

  it('should handle dependencies between stores', async () => {
    // This would test cross-store communication
    // using the container or registry pattern
  });
});
```

---

## Deep Dive: Dependency Injection Patterns

### Pattern 1: Constructor Injection

```typescript
// Most explicit and testable
class TaskStoreService {
  constructor(
    private api: TaskApi,
    private storage: StorageAdapter,
    private authStore: AuthStore
  ) {}

  createStore() {
    // Use dependencies to create store
  }
}
```

### Pattern 2: Method Injection

```typescript
// Inject dependencies when calling methods
const taskStore = createTaskStore();
taskStore.setDependencies(api, storage);
```

### Pattern 3: Property Injection

```typescript
// Set dependencies as properties
taskStore.api = mockApi;
taskStore.storage = mockStorage;
```

### Pattern 4: Ambient Context

```typescript
// Use React Context or global variable
const TaskStoreContext = createContext<ReturnType<typeof createTaskStore> | null>(null);

function useTaskStore() {
  const context = useContext(TaskStoreContext);
  if (!context) {
    throw new Error('useTaskStore must be used within TaskStoreProvider');
  }
  return context;
}
```

---

## Common Pitfalls and Solutions

### Pitfall 1: Circular Dependencies

```typescript
// ❌ BAD: Store A imports Store B, Store B imports Store A
// 🔄 Circular dependency

// ✅ GOOD: Use event bus or container to break cycle
export const eventBus = new EventBus();
// Store A publishes events
eventBus.publish('task:created', task);
// Store B subscribes to events
eventBus.subscribe('task:created', handleTaskCreated);
```

### Pitfall 2: Service Locator Overuse

```typescript
// ❌ BAD: Overusing service locator makes code hard to test
const taskStore = serviceLocator.get('taskStore');

// ✅ GOOD: Inject dependencies explicitly
function useTaskList(taskStore: TaskStore) {
  // ...
}

// In tests, you can pass mocks
useTaskList(mockTaskStore);
```

### Pitfall 3: Tight Coupling

```typescript
// ❌ BAD: Directly importing other stores
import { useAuthStore } from '../auth/store/authStore';

// Inside task store:
const userId = useAuthStore.getState().user?.id;

// ✅ GOOD: Inject as dependency
const userId = deps.getUserId();

// This makes testing easier and reduces coupling
```

### Pitfall 4: Leaking Internal State

```typescript
// ❌ BAD: Exposing internal state
const { tasks, taskIds, _internalState } = useTaskStore();

// ✅ GOOD: Only expose what's needed
const { tasks, addTask, fetchTasks } = useTaskStore();
```

---

## Store Composition Checklist

- [ ] Stores are created with factory functions
- [ ] Dependencies are injected (not imported directly)
- [ ] Slices are independent and reusable
- [ ] Cross-store communication uses events or container
- [ ] Circular dependencies are avoided
- [ ] Testing uses mock dependencies
- [ ] Container or registry is configured
- [ ] Configuration can be overridden
- [ ] Store composition is well-documented
- [ ] Lazy initialization works correctly

---

## Key Takeaways

1. **Factory pattern**: Create stores with factory functions for testability
2. **Dependency injection**: Inject dependencies rather than importing them
3. **Slice pattern**: Break large stores into focused, reusable slices
4. **Event bus**: Use events for cross-store communication
5. **Container**: Use DI container or service locator for complex dependencies
6. **Lazy initialization**: Initialize stores only when needed
7. **Configuration**: Make stores configurable for different environments
8. **Testing**: Mock dependencies for testing composed stores
9. **Documentation**: Document store dependencies clearly
10. **Avoid leaks**: Keep store internals private

---

## What's Next

You've mastered store composition and dependency injection. Next, you'll learn about error boundaries, logging strategies, and security considerations for production Zustand applications.
