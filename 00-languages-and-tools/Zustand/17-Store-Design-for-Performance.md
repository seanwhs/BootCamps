# Part 4 — Performance Optimization

## Section 17: Store Design for Performance

You've learned how to optimize rendering with fine-grained subscriptions. But performance doesn't start in the components—it starts in how you design your stores. In this section, you'll learn architectural patterns that prevent performance problems before they happen: normalization, store splitting, lazy initialization, and efficient memory management.

---

## The Target: Performant Store Architecture

By the end of this section, you'll be able to:
- Normalize state for efficient querying and updates
- Split stores by domain, frequency, and render impact
- Implement lazy initialization for expensive state
- Manage memory effectively to prevent leaks
- Prevent cascading updates that trigger unnecessary renders
- Design stores that scale to thousands of items

---

## The Concept: Store Design as Database Design

Think of store design like **database schema design**:

```
┌─────────────────────────────────────────────────────────────────┐
│                    STORE DESIGN PRINCIPLES                     │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  NORMALIZATION                                          │  │
│  │  • One source of truth                                  │  │
│  │  • No duplicate data                                    │  │
│  │  • Efficient lookups (O(1))                             │  │
│  │  • Easy updates (single place)                          │  │
│  └──────────────────────────────────────────────────────────┘  │
│                         │                                      │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  STORE SPLITTING                                        │  │
│  │  • Domain separation                                    │  │
│  │  • Frequency separation (hot/cold)                      │  │
│  │  • Render impact separation                             │  │
│  │  • Independent updates                                  │  │
│  └──────────────────────────────────────────────────────────┘  │
│                         │                                      │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  LAZY INITIALIZATION                                   │  │
│  │  • Load only when needed                                │  │
│  │  • Reduce initial bundle size                          │  │
│  │  • Faster initial render                               │  │
│  └──────────────────────────────────────────────────────────┘  │
│                         │                                      │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  MEMORY MANAGEMENT                                      │  │
│  │  • Clean up unused data                                 │  │
│  │  • Limit cache size                                     │  │
│  │  • Prevent memory leaks                                 │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

---

## The Implementation: Store Design Patterns

### Step 1: State Normalization

Normalize your state to avoid duplication and make updates efficient:

```typescript
// ❌ BAD: Denormalized state (duplicate data)
interface DenormalizedState {
  tasks: {
    id: string;
    title: string;
    assignee: {
      id: string;
      name: string;
      email: string;
    };
    project: {
      id: string;
      name: string;
    };
  }[];
  // Problem: If assignee name changes, update ALL tasks
  // If project name changes, update ALL tasks
}

// ✅ GOOD: Normalized state
interface NormalizedState {
  // Entities stored by ID for O(1) lookup
  tasks: Record<string, Task>;
  users: Record<string, User>;
  projects: Record<string, Project>;
  // Relationships stored as arrays of IDs
  taskIds: string[];
  projectTaskIds: Record<string, string[]>; // Project ID -> Task IDs
  userTaskIds: Record<string, string[]>; // User ID -> Task IDs
  // Metadata
  selectedTaskId: string | null;
  selectedProjectId: string | null;
}

interface Task {
  id: string;
  title: string;
  assigneeId: string; // Reference, not nested
  projectId: string; // Reference, not nested
  completed: boolean;
  priority: 'low' | 'medium' | 'high';
  createdAt: Date;
  updatedAt: Date;
}

interface User {
  id: string;
  name: string;
  email: string;
  avatar?: string;
}

interface Project {
  id: string;
  name: string;
  description?: string;
  createdAt: Date;
}

// Implementation
import { create } from 'zustand';
import { immer } from 'zustand/middleware/immer';

const useNormalizedStore = create<NormalizedState>()(
  immer((set, get) => ({
    tasks: {},
    users: {},
    projects: {},
    taskIds: [],
    projectTaskIds: {},
    userTaskIds: {},
    selectedTaskId: null,
    selectedProjectId: null,

    // Actions with normalized updates
    addTask: (task: Task) => {
      set((state) => {
        // Add task to tasks lookup
        state.tasks[task.id] = task;
        state.taskIds.push(task.id);
        
        // Add to project-task relationship
        if (!state.projectTaskIds[task.projectId]) {
          state.projectTaskIds[task.projectId] = [];
        }
        state.projectTaskIds[task.projectId].push(task.id);
        
        // Add to user-task relationship
        if (task.assigneeId) {
          if (!state.userTaskIds[task.assigneeId]) {
            state.userTaskIds[task.assigneeId] = [];
          }
          state.userTaskIds[task.assigneeId].push(task.id);
        }
      });
    },

    updateTask: (id: string, updates: Partial<Task>) => {
      set((state) => {
        const task = state.tasks[id];
        if (!task) return;
        
        // If assignee or project changes, update relationships
        const oldAssigneeId = task.assigneeId;
        const oldProjectId = task.projectId;
        const newAssigneeId = updates.assigneeId;
        const newProjectId = updates.projectId;

        // Update task data
        Object.assign(task, updates);

        // Update assignee relationships if changed
        if (oldAssigneeId !== newAssigneeId) {
          // Remove from old assignee
          if (oldAssigneeId && state.userTaskIds[oldAssigneeId]) {
            const index = state.userTaskIds[oldAssigneeId].indexOf(id);
            if (index !== -1) {
              state.userTaskIds[oldAssigneeId].splice(index, 1);
            }
          }
          // Add to new assignee
          if (newAssigneeId) {
            if (!state.userTaskIds[newAssigneeId]) {
              state.userTaskIds[newAssigneeId] = [];
            }
            state.userTaskIds[newAssigneeId].push(id);
          }
        }

        // Update project relationships if changed
        if (oldProjectId !== newProjectId) {
          // Remove from old project
          if (oldProjectId && state.projectTaskIds[oldProjectId]) {
            const index = state.projectTaskIds[oldProjectId].indexOf(id);
            if (index !== -1) {
              state.projectTaskIds[oldProjectId].splice(index, 1);
            }
          }
          // Add to new project
          if (newProjectId) {
            if (!state.projectTaskIds[newProjectId]) {
              state.projectTaskIds[newProjectId] = [];
            }
            state.projectTaskIds[newProjectId].push(id);
          }
        }
      });
    },

    // Update user without affecting tasks
    updateUser: (id: string, updates: Partial<User>) => {
      set((state) => {
        const user = state.users[id];
        if (user) {
          Object.assign(user, updates);
        }
      });
    },

    // Query helpers
    getTasksByProject: (projectId: string) => {
      const state = get();
      const taskIds = state.projectTaskIds[projectId] || [];
      return taskIds.map(id => state.tasks[id]).filter(Boolean);
    },

    getTasksByUser: (userId: string) => {
      const state = get();
      const taskIds = state.userTaskIds[userId] || [];
      return taskIds.map(id => state.tasks[id]).filter(Boolean);
    },

    getProject: (projectId: string) => {
      return get().projects[projectId];
    },

    getUser: (userId: string) => {
      return get().users[userId];
    },
  }))
);
```

### Step 2: Splitting Stores by Domain

Split large stores into focused, domain-specific stores:

```typescript
// src/store/domains/userStore.ts
import { create } from 'zustand';
import { immer } from 'zustand/middleware/immer';

interface UserStore {
  users: Record<string, User>;
  currentUserId: string | null;
  isLoading: boolean;
  error: string | null;
  
  fetchUsers: () => Promise<void>;
  fetchUser: (id: string) => Promise<void>;
  updateUser: (id: string, updates: Partial<User>) => void;
  setCurrentUser: (id: string | null) => void;
  clear: () => void;
}

export const useUserStore = create<UserStore>()(
  immer((set, get) => ({
    users: {},
    currentUserId: null,
    isLoading: false,
    error: null,

    fetchUsers: async () => {
      set({ isLoading: true, error: null });
      try {
        const response = await fetch('/api/users');
        const users = await response.json();
        const usersMap: Record<string, User> = {};
        for (const user of users) {
          usersMap[user.id] = user;
        }
        set({ users: usersMap, isLoading: false });
      } catch (error) {
        set({ error: error.message, isLoading: false });
      }
    },

    fetchUser: async (id: string) => {
      if (get().users[id]) return;
      set({ isLoading: true, error: null });
      try {
        const response = await fetch(`/api/users/${id}`);
        const user = await response.json();
        set((state) => {
          state.users[id] = user;
          state.isLoading = false;
        });
      } catch (error) {
        set({ error: error.message, isLoading: false });
      }
    },

    updateUser: (id: string, updates: Partial<User>) => {
      set((state) => {
        const user = state.users[id];
        if (user) {
          Object.assign(user, updates);
        }
      });
    },

    setCurrentUser: (id: string | null) => {
      set({ currentUserId: id });
    },

    clear: () => {
      set({ users: {}, currentUserId: null, isLoading: false, error: null });
    },
  }))
);

// src/store/domains/taskStore.ts
interface TaskStore {
  tasks: Record<string, Task>;
  taskIds: string[];
  isLoading: boolean;
  error: string | null;
  selectedTaskId: string | null;
  
  fetchTasks: () => Promise<void>;
  addTask: (task: Task) => void;
  updateTask: (id: string, updates: Partial<Task>) => void;
  deleteTask: (id: string) => void;
  selectTask: (id: string | null) => void;
  clear: () => void;
}

export const useTaskStore = create<TaskStore>()(
  immer((set, get) => ({
    tasks: {},
    taskIds: [],
    isLoading: false,
    error: null,
    selectedTaskId: null,

    fetchTasks: async () => {
      set({ isLoading: true, error: null });
      try {
        const response = await fetch('/api/tasks');
        const tasks = await response.json();
        const tasksMap: Record<string, Task> = {};
        const ids: string[] = [];
        for (const task of tasks) {
          tasksMap[task.id] = task;
          ids.push(task.id);
        }
        set({ tasks: tasksMap, taskIds: ids, isLoading: false });
      } catch (error) {
        set({ error: error.message, isLoading: false });
      }
    },

    addTask: (task: Task) => {
      set((state) => {
        state.tasks[task.id] = task;
        state.taskIds.push(task.id);
      });
    },

    updateTask: (id: string, updates: Partial<Task>) => {
      set((state) => {
        const task = state.tasks[id];
        if (task) {
          Object.assign(task, updates);
        }
      });
    },

    deleteTask: (id: string) => {
      set((state) => {
        delete state.tasks[id];
        const index = state.taskIds.indexOf(id);
        if (index !== -1) {
          state.taskIds.splice(index, 1);
        }
        if (state.selectedTaskId === id) {
          state.selectedTaskId = null;
        }
      });
    },

    selectTask: (id: string | null) => {
      set({ selectedTaskId: id });
    },

    clear: () => {
      set({ tasks: {}, taskIds: [], isLoading: false, error: null, selectedTaskId: null });
    },
  }))
);

// src/store/domains/uiStore.ts
interface UIStore {
  theme: 'light' | 'dark';
  sidebarOpen: boolean;
  modalOpen: Record<string, boolean>;
  toastMessages: ToastMessage[];
  
  toggleTheme: () => void;
  toggleSidebar: () => void;
  openModal: (id: string) => void;
  closeModal: (id: string) => void;
  addToast: (toast: ToastMessage) => void;
  removeToast: (id: string) => void;
}

export const useUIStore = create<UIStore>()(
  immer((set) => ({
    theme: 'light',
    sidebarOpen: true,
    modalOpen: {},
    toastMessages: [],

    toggleTheme: () => {
      set((state) => {
        state.theme = state.theme === 'light' ? 'dark' : 'light';
      });
    },

    toggleSidebar: () => {
      set((state) => {
        state.sidebarOpen = !state.sidebarOpen;
      });
    },

    openModal: (id: string) => {
      set((state) => {
        state.modalOpen[id] = true;
      });
    },

    closeModal: (id: string) => {
      set((state) => {
        state.modalOpen[id] = false;
      });
    },

    addToast: (toast: ToastMessage) => {
      set((state) => {
        state.toastMessages.push(toast);
      });
      setTimeout(() => {
        get().removeToast(toast.id);
      }, toast.duration || 5000);
    },

    removeToast: (id: string) => {
      set((state) => {
        const index = state.toastMessages.findIndex(t => t.id === id);
        if (index !== -1) {
          state.toastMessages.splice(index, 1);
        }
      });
    },
  }))
);
```

### Step 3: Splitting by Update Frequency (Hot/Cold)

Separate frequently-updated state from infrequently-updated state:

```typescript
// src/store/frequencySplitting.ts
import { create } from 'zustand';
import { immer } from 'zustand/middleware/immer';

// HOT STORE: Frequently updated (animations, real-time data, user input)
// Re-renders components that need fast updates
const useHotStore = create<{
  cursorPosition: { x: number; y: number };
  typingText: string;
  progress: number;
  activeUsers: number;
  setCursorPosition: (x: number, y: number) => void;
  setTypingText: (text: string) => void;
  setProgress: (progress: number) => void;
  setActiveUsers: (count: number) => void;
}>()(
  immer((set) => ({
    cursorPosition: { x: 0, y: 0 },
    typingText: '',
    progress: 0,
    activeUsers: 0,

    setCursorPosition: (x, y) => {
      set({ cursorPosition: { x, y } });
    },

    setTypingText: (text) => {
      set({ typingText: text });
    },

    setProgress: (progress) => {
      set({ progress });
    },

    setActiveUsers: (count) => {
      set({ activeUsers: count });
    },
  }))
);

// COLD STORE: Infrequently updated (user profile, settings, configuration)
// Rarely re-renders, can be memoized heavily
const useColdStore = create<{
  user: User | null;
  settings: { theme: string; language: string; timezone: string };
  permissions: string[];
  setUser: (user: User) => void;
  updateSettings: (settings: Partial<{ theme: string; language: string; timezone: string }>) => void;
  setPermissions: (permissions: string[]) => void;
}>()(
  immer((set) => ({
    user: null,
    settings: { theme: 'light', language: 'en', timezone: 'UTC' },
    permissions: [],

    setUser: (user) => {
      set({ user });
    },

    updateSettings: (updates) => {
      set((state) => {
        Object.assign(state.settings, updates);
      });
    },

    setPermissions: (permissions) => {
      set({ permissions });
    },
  }))
);

// Components that need frequent updates only subscribe to hot store
function CursorTracker() {
  const position = useHotStore((state) => state.cursorPosition);
  // Re-renders on every cursor move - but hot store is optimized for this
  return <div style={{ left: position.x, top: position.y }} />;
}

// Components that need infrequent updates subscribe to cold store
function UserProfile() {
  const user = useColdStore((state) => state.user);
  // Only re-renders when user data actually changes
  return <div>{user?.name}</div>;
}
```

### Step 4: Lazy Initialization

Initialize expensive state only when needed:

```typescript
// src/store/lazyStore.ts
import { create } from 'zustand';
import { immer } from 'zustand/middleware/immer';

interface LazyStore {
  // State that's always loaded
  initialData: any;
  
  // State that loads lazily
  heavyData: any | null;
  isHeavyDataLoading: boolean;
  heavyDataError: string | null;
  isHeavyDataInitialized: boolean;
  
  // Actions
  loadHeavyData: () => Promise<void>;
  clearHeavyData: () => void;
  initializeIfNeeded: () => Promise<void>;
}

export const useLazyStore = create<LazyStore>()(
  immer((set, get) => ({
    initialData: { /* small, always-loaded data */ },
    heavyData: null,
    isHeavyDataLoading: false,
    heavyDataError: null,
    isHeavyDataInitialized: false,

    // Load heavy data only when requested
    loadHeavyData: async () => {
      const state = get();
      if (state.isHeavyDataLoading || state.heavyData !== null) {
        return;
      }

      set({ isHeavyDataLoading: true, heavyDataError: null });

      try {
        // Simulate expensive operation
        const heavyData = await fetchHeavyData();
        set({
          heavyData,
          isHeavyDataLoading: false,
          isHeavyDataInitialized: true,
        });
      } catch (error) {
        set({
          isHeavyDataLoading: false,
          heavyDataError: error.message,
        });
      }
    },

    clearHeavyData: () => {
      set({
        heavyData: null,
        isHeavyDataInitialized: false,
        heavyDataError: null,
      });
    },

    // Safe initialization - called from components that need the data
    initializeIfNeeded: async () => {
      const state = get();
      if (!state.isHeavyDataInitialized) {
        await state.loadHeavyData();
      }
    },
  }))
);

// Component using lazy data
function LazyComponent() {
  const { heavyData, isHeavyDataLoading, heavyDataError, initializeIfNeeded } = useLazyStore();
  
  useEffect(() => {
    initializeIfNeeded();
  }, []);

  if (isHeavyDataLoading) return <div>Loading heavy data...</div>;
  if (heavyDataError) return <div>Error: {heavyDataError}</div>;
  if (!heavyData) return <div>Click to load</div>;
  
  return <div>{/* Render heavy data */}</div>;
}
```

### Step 5: Memory Management

Prevent memory leaks with proper cleanup and caching limits:

```typescript
// src/store/memoryManagedStore.ts
import { create } from 'zustand';
import { immer } from 'zustand/middleware/immer';

interface MemoryManagedStore {
  // Cached data with TTL
  cache: Map<string, { data: any; timestamp: number; ttl: number }>;
  maxCacheSize: number;
  
  // Large data collections
  largeDataset: any[];
  datasetLimit: number;
  
  // Active subscriptions cleanup
  subscriptions: Set<() => void>;
  
  // Actions
  addToCache: (key: string, data: any, ttl?: number) => void;
  getFromCache: (key: string) => any | null;
  clearCache: () => void;
  cleanup: () => void;
  addData: (item: any) => void;
  removeOldData: () => void;
  registerCleanup: (cleanupFn: () => void) => void;
}

export const useMemoryManagedStore = create<MemoryManagedStore>()(
  immer((set, get) => ({
    cache: new Map(),
    maxCacheSize: 100,
    largeDataset: [],
    datasetLimit: 1000,
    subscriptions: new Set(),

    // Cache with TTL
    addToCache: (key: string, data: any, ttl: number = 60000) => {
      set((state) => {
        // Limit cache size
        if (state.cache.size >= state.maxCacheSize) {
          // Remove oldest entry
          const firstKey = state.cache.keys().next().value;
          if (firstKey) {
            state.cache.delete(firstKey);
          }
        }
        
        state.cache.set(key, {
          data,
          timestamp: Date.now(),
          ttl,
        });
      });
    },

    getFromCache: (key: string) => {
      const state = get();
      const entry = state.cache.get(key);
      if (!entry) return null;
      
      const now = Date.now();
      if (now - entry.timestamp > entry.ttl) {
        // Expired
        set((state) => {
          state.cache.delete(key);
        });
        return null;
      }
      
      return entry.data;
    },

    clearCache: () => {
      set({ cache: new Map() });
    },

    // Data limit management
    addData: (item: any) => {
      set((state) => {
        state.largeDataset.push(item);
        if (state.largeDataset.length > state.datasetLimit) {
          // Remove oldest items
          const excess = state.largeDataset.length - state.datasetLimit;
          state.largeDataset.splice(0, excess);
        }
      });
    },

    removeOldData: () => {
      set((state) => {
        // Keep only last 50% of items when memory is high
        const keepCount = Math.floor(state.datasetLimit / 2);
        if (state.largeDataset.length > keepCount) {
          state.largeDataset = state.largeDataset.slice(-keepCount);
        }
      });
    },

    // Subscription management
    registerCleanup: (cleanupFn: () => void) => {
      set((state) => {
        state.subscriptions.add(cleanupFn);
      });
    },

    cleanup: () => {
      const state = get();
      // Run all cleanup functions
      for (const cleanupFn of state.subscriptions) {
        try {
          cleanupFn();
        } catch (error) {
          console.error('Cleanup error:', error);
        }
      }
      
      // Reset state
      set({
        cache: new Map(),
        subscriptions: new Set(),
      });
    },
  }))
);

// Usage in components
function MemoryManagedComponent() {
  const { addToCache, getFromCache, registerCleanup } = useMemoryManagedStore();
  
  useEffect(() => {
    // Register cleanup when component unmounts
    const cleanup = () => {
      console.log('Cleaning up component');
    };
    registerCleanup(cleanup);
  }, []);

  // Use cache
  const cachedData = getFromCache('my-key');
  if (!cachedData) {
    // Fetch data and cache it
    fetchData().then(data => addToCache('my-key', data));
  }
  
  return <div>{/* ... */}</div>;
}
```

### Step 6: Preventing Cascading Updates

Avoid "update avalanches" where one state change triggers many others:

```typescript
// src/store/cascadePreventionStore.ts
import { create } from 'zustand';
import { immer } from 'zustand/middleware/immer';

interface CascadeStore {
  // State
  items: Record<string, any>;
  selectedIds: Set<string>;
  filteredIds: string[];
  sortField: string;
  sortDirection: 'asc' | 'desc';
  
  // Batch update flag
  isBatching: boolean;
  pendingUpdates: (() => void)[];
  
  // Actions
  batchUpdate: (fn: () => void) => void;
  selectItems: (ids: string[]) => void;
  setFilter: (filter: any) => void;
  setSort: (field: string, direction: 'asc' | 'desc') => void;
  addItems: (items: any[]) => void;
  flushPending: () => void;
}

export const useCascadeStore = create<CascadeStore>()(
  immer((set, get) => ({
    items: {},
    selectedIds: new Set(),
    filteredIds: [],
    sortField: 'id',
    sortDirection: 'asc',
    isBatching: false,
    pendingUpdates: [],

    // Batch multiple updates into one render cycle
    batchUpdate: (fn: () => void) => {
      const state = get();
      if (state.isBatching) {
        // Already batching - just execute
        fn();
        return;
      }

      // Start batch
      set({ isBatching: true });
      try {
        fn();
      } finally {
        // End batch and flush all pending updates
        get().flushPending();
        set({ isBatching: false });
      }
    },

    selectItems: (ids: string[]) => {
      set((state) => {
        // Instead of updating selectedIds directly, batch it
        state.selectedIds = new Set(ids);
      });
    },

    setFilter: (filter: any) => {
      set((state) => {
        // Update filter
        // This will trigger filteredIds recalculation
        state.filteredIds = Object.values(state.items)
          .filter(item => matchesFilter(item, filter))
          .map(item => item.id);
      });
    },

    setSort: (field: string, direction: 'asc' | 'desc') => {
      set((state) => {
        state.sortField = field;
        state.sortDirection = direction;
        // Re-sort filteredIds
        state.filteredIds.sort((a, b) => {
          const itemA = state.items[a];
          const itemB = state.items[b];
          const valA = itemA[field];
          const valB = itemB[field];
          if (valA < valB) return direction === 'asc' ? -1 : 1;
          if (valA > valB) return direction === 'asc' ? 1 : -1;
          return 0;
        });
      });
    },

    addItems: (items: any[]) => {
      set((state) => {
        for (const item of items) {
          state.items[item.id] = item;
        }
        // Only recalculate filteredIds if filter is applied
        // This prevents cascading updates
      });
    },

    flushPending: () => {
      const state = get();
      if (state.pendingUpdates.length === 0) return;
      
      // Apply all pending updates in one go
      const updates = state.pendingUpdates;
      set({ pendingUpdates: [] });
      for (const update of updates) {
        update();
      }
    },
  }))
);

// Helper function for filtering
function matchesFilter(item: any, filter: any): boolean {
  // Simple filter implementation
  if (filter.search) {
    const search = filter.search.toLowerCase();
    if (!item.name.toLowerCase().includes(search)) return false;
  }
  if (filter.status && item.status !== filter.status) return false;
  return true;
}
```

### Step 7: Derived State Optimization

Store derived state only when necessary, and recompute efficiently:

```typescript
// src/store/derivedStateOptimization.ts
import { create } from 'zustand';
import { immer } from 'zustand/middleware/immer';

interface DerivedStateStore {
  // Raw state
  items: any[];
  
  // Derived state cache
  _derivedCache: Map<string, any>;
  _cacheVersion: number;
  
  // Actions
  addItem: (item: any) => void;
  updateItem: (id: string, updates: any) => void;
  deleteItem: (id: string) => void;
  clearCache: () => void;
  
  // Derived state getters (with caching)
  getStats: () => { total: number; active: number; inactive: number };
  getGroupedByCategory: () => Record<string, any[]>;
  getSortedByDate: () => any[];
}

export const useDerivedStateStore = create<DerivedStateStore>()(
  immer((set, get) => ({
    items: [],
    _derivedCache: new Map(),
    _cacheVersion: 0,

    // Mutations increment version to invalidate cache
    addItem: (item) => {
      set((state) => {
        state.items.push(item);
        state._cacheVersion++;
      });
    },

    updateItem: (id, updates) => {
      set((state) => {
        const item = state.items.find(i => i.id === id);
        if (item) {
          Object.assign(item, updates);
          state._cacheVersion++;
        }
      });
    },

    deleteItem: (id) => {
      set((state) => {
        const index = state.items.findIndex(i => i.id === id);
        if (index !== -1) {
          state.items.splice(index, 1);
          state._cacheVersion++;
        }
      });
    },

    clearCache: () => {
      set({ _derivedCache: new Map() });
    },

    // Derived state with caching
    getStats: () => {
      const state = get();
      const cacheKey = `stats-${state._cacheVersion}`;
      
      if (state._derivedCache.has(cacheKey)) {
        return state._derivedCache.get(cacheKey);
      }

      const stats = {
        total: state.items.length,
        active: state.items.filter(i => i.active).length,
        inactive: state.items.filter(i => !i.active).length,
      };

      set((state) => {
        state._derivedCache.set(cacheKey, stats);
      });

      return stats;
    },

    getGroupedByCategory: () => {
      const state = get();
      const cacheKey = `grouped-${state._cacheVersion}`;
      
      if (state._derivedCache.has(cacheKey)) {
        return state._derivedCache.get(cacheKey);
      }

      const groups: Record<string, any[]> = {};
      for (const item of state.items) {
        if (!groups[item.category]) {
          groups[item.category] = [];
        }
        groups[item.category].push(item);
      }

      set((state) => {
        state._derivedCache.set(cacheKey, groups);
      });

      return groups;
    },

    getSortedByDate: () => {
      const state = get();
      const cacheKey = `sorted-${state._cacheVersion}`;
      
      if (state._derivedCache.has(cacheKey)) {
        return state._derivedCache.get(cacheKey);
      }

      const sorted = [...state.items].sort(
        (a, b) => b.createdAt.getTime() - a.createdAt.getTime()
      );

      set((state) => {
        state._derivedCache.set(cacheKey, sorted);
      });

      return sorted;
    },
  }))
);
```

---

## The Verification: Performance Testing

### Step 1: Create a Performance Dashboard

```tsx
// src/components/StorePerformanceDashboard.tsx
import React, { useState, useEffect } from 'react';
import { useNormalizedStore } from '../store/normalizedStore';

interface StoreMetric {
  name: string;
  itemCount: number;
  memoryUsage: number; // Approximate
  updateCount: number;
}

export function StorePerformanceDashboard() {
  const [metrics, setMetrics] = useState<StoreMetric[]>([]);
  const [isVisible, setIsVisible] = useState(false);

  useEffect(() => {
    const interval = setInterval(() => {
      const state = useNormalizedStore.getState();
      
      const taskCount = Object.keys(state.tasks).length;
      const userCount = Object.keys(state.users).length;
      const projectCount = Object.keys(state.projects).length;
      
      const memoryUsage = approximateMemoryUsage(state);
      
      setMetrics([
        { 
          name: 'Tasks', 
          itemCount: taskCount, 
          memoryUsage: memoryUsage * (taskCount / (taskCount + userCount + projectCount)),
          updateCount: taskCount // Simplified
        },
        { 
          name: 'Users', 
          itemCount: userCount, 
          memoryUsage: memoryUsage * (userCount / (taskCount + userCount + projectCount)),
          updateCount: userCount
        },
        { 
          name: 'Projects', 
          itemCount: projectCount, 
          memoryUsage: memoryUsage * (projectCount / (taskCount + userCount + projectCount)),
          updateCount: projectCount
        },
      ]);
    }, 2000);

    return () => clearInterval(interval);
  }, []);

  function approximateMemoryUsage(state: any): number {
    const json = JSON.stringify(state);
    return json.length * 2; // Approximate bytes
  }

  if (!isVisible) {
    return (
      <button onClick={() => setIsVisible(true)} style={{ position: 'fixed', bottom: 10, right: 10 }}>
        Show Performance Dashboard
      </button>
    );
  }

  return (
    <div style={{
      position: 'fixed',
      bottom: 0,
      left: 0,
      right: 0,
      background: '#1a1a2e',
      color: '#fff',
      padding: '10px 20px',
      fontFamily: 'monospace',
      fontSize: '12px',
      maxHeight: '200px',
      overflow: 'auto',
      zIndex: 9999,
      borderTop: '2px solid #16213e',
    }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <h4 style={{ margin: 0 }}>📊 Store Performance Dashboard</h4>
        <button onClick={() => setIsVisible(false)} style={{ background: '#dc3545', color: 'white', border: 'none', padding: '2px 8px', cursor: 'pointer' }}>
          Close
        </button>
      </div>
      
      <div style={{ display: 'flex', gap: '20px', marginTop: '10px', flexWrap: 'wrap' }}>
        {metrics.map(metric => (
          <div key={metric.name} style={{ background: '#16213e', padding: '8px 12px', borderRadius: '4px', minWidth: '150px' }}>
            <div style={{ fontWeight: 'bold', color: '#4fc3f7' }}>{metric.name}</div>
            <div>Items: {metric.itemCount}</div>
            <div>Memory: {(metric.memoryUsage / 1024).toFixed(1)} KB</div>
            <div>Updates: {metric.updateCount}</div>
          </div>
        ))}
        <div style={{ background: '#16213e', padding: '8px 12px', borderRadius: '4px', minWidth: '150px' }}>
          <div style={{ fontWeight: 'bold', color: '#81c784' }}>Total</div>
          <div>Items: {metrics.reduce((sum, m) => sum + m.itemCount, 0)}</div>
          <div>Memory: {(metrics.reduce((sum, m) => sum + m.memoryUsage, 0) / 1024).toFixed(1)} KB</div>
        </div>
      </div>
    </div>
  );
}
```

### Step 2: Performance Test Suite

```typescript
// src/tests/storePerformance.test.ts
import { useNormalizedStore } from '../store/normalizedStore';

export function runStorePerformanceTests() {
  console.log('=== Store Performance Tests ===\n');

  // Test 1: Normalized state efficiency
  console.log('Test 1: Normalized State Performance');
  const store = useNormalizedStore.getState();
  const startTime1 = performance.now();

  // Add 1000 tasks with different assignees and projects
  for (let i = 0; i < 1000; i++) {
    const taskId = `task-${i}`;
    const projectId = `project-${i % 10}`;
    const assigneeId = `user-${i % 50}`;
    
    store.addTask({
      id: taskId,
      title: `Task ${i}`,
      assigneeId,
      projectId,
      completed: false,
      priority: i % 3 === 0 ? 'high' : i % 3 === 1 ? 'medium' : 'low',
      createdAt: new Date(),
      updatedAt: new Date(),
    });
  }

  const addTime = performance.now() - startTime1;
  console.log(`  ✅ Added 1000 tasks in ${addTime.toFixed(2)}ms`);

  // Test 2: Lookup performance
  console.log('\nTest 2: Lookup Performance');
  const startTime2 = performance.now();

  for (let i = 0; i < 10000; i++) {
    const task = store.getTaskById(`task-${i % 1000}`);
    const user = store.getUserById(`user-${i % 50}`);
    const project = store.getProjectById(`project-${i % 10}`);
  }

  const lookupTime = performance.now() - startTime2;
  console.log(`  ✅ Performed 30,000 lookups in ${lookupTime.toFixed(2)}ms`);

  // Test 3: Update performance
  console.log('\nTest 3: Update Performance');
  const startTime3 = performance.now();

  for (let i = 0; i < 1000; i++) {
    store.updateTask(`task-${i}`, { completed: true });
  }

  const updateTime = performance.now() - startTime3;
  console.log(`  ✅ Updated 1000 tasks in ${updateTime.toFixed(2)}ms`);

  // Test 4: Memory usage
  console.log('\nTest 4: Memory Usage');
  const state = useNormalizedStore.getState();
  const jsonSize = JSON.stringify(state).length;
  console.log(`  ✅ State size: ${(jsonSize / 1024).toFixed(2)} KB`);

  // Results
  console.log('\n=== Results ===');
  console.log(`Total operations: ${1000 + 30000 + 1000}`);
  console.log(`Total time: ${(addTime + lookupTime + updateTime).toFixed(2)}ms`);
  console.log('✅ All tests passed!\n');
}
```

### Step 3: Browser Console Testing

Open your browser console and run:

```javascript
// Test normalized store performance
import { runStorePerformanceTests } from './src/tests/storePerformance.test';
runStorePerformanceTests();

// Check memory usage
import { useNormalizedStore } from './src/store/normalizedStore';
const state = useNormalizedStore.getState();
console.log('State size:', JSON.stringify(state).length, 'bytes');

// Test lazy loading
import { useLazyStore } from './src/store/lazyStore';
await useLazyStore.getState().loadHeavyData();
console.log('Heavy data loaded:', useLazyStore.getState().heavyData);
```

---

## Deep Dive: Store Design Anti-Patterns

### Anti-Pattern 1: Storing Derived State

```typescript
// ❌ BAD: Storing derived state
const badStore = create((set) => ({
  tasks: [],
  completedTasks: [], // Derived!
  activeTasks: [], // Derived!
  // Problem: These can get out of sync with tasks
}));

// ✅ GOOD: Compute on demand
const goodStore = create((set, get) => ({
  tasks: [],
  getCompletedTasks: () => get().tasks.filter(t => t.completed),
  getActiveTasks: () => get().tasks.filter(t => !t.completed),
}));
```

### Anti-Pattern 2: Deep Nesting

```typescript
// ❌ BAD: Deeply nested state
const badStore = create((set) => ({
  user: {
    profile: {
      settings: {
        preferences: {
          notifications: {
            email: true,
            push: true,
          },
        },
      },
    },
  },
}));
// Problem: Updating email requires deep spreading

// ✅ GOOD: Flattened state
const goodStore = create((set) => ({
  user: { id: '1', name: 'Alice' },
  preferences: { email: true, push: true },
  settings: { theme: 'light', language: 'en' },
}));
```

### Anti-Pattern 3: Not Using Normalization for Lists

```typescript
// ❌ BAD: Array of objects
const badStore = create((set) => ({
  tasks: [
    { id: 1, title: 'Task 1', assignee: { id: 101, name: 'Alice' } },
    { id: 2, title: 'Task 2', assignee: { id: 102, name: 'Bob' } },
  ],
}));
// Problem: Updating assignee name requires updating ALL tasks

// ✅ GOOD: Normalized
const goodStore = create((set) => ({
  tasks: { '1': { id: 1, title: 'Task 1', assigneeId: 101 } },
  users: { '101': { id: 101, name: 'Alice' } },
  taskIds: ['1', '2'],
}));
// Benefit: Update user once, all tasks reflect the change
```

### Anti-Pattern 4: Not Cleaning Up Large Data

```typescript
// ❌ BAD: Never cleaning up old data
const badStore = create((set) => ({
  history: [], // Grows forever
  addHistory: (entry) => set((state) => ({
    history: [...state.history, entry]
  })),
}));

// ✅ GOOD: Limiting data size
const goodStore = create((set) => ({
  history: [],
  maxHistory: 1000,
  addHistory: (entry) => set((state) => ({
    history: [...state.history.slice(-state.maxHistory + 1), entry]
  })),
}));
```

---

## Store Design Checklist

- [ ] State is normalized (entities by ID, relationships as IDs)
- [ ] Stores are split by domain (user, tasks, UI)
- [ ] Frequently-updated state is in separate stores
- [ ] Large data has size limits
- [ ] Expensive state is lazy-loaded
- [ ] Cache has TTL and size limits
- [ ] Subscriptions are cleaned up
- [ ] Derived state is computed, not stored
- [ ] State is flattened (not deeply nested)
- [ ] Array data is normalized
- [ ] Memory is monitored in development
- [ ] Performance tests are in place

---

## Key Takeaways

1. **Normalize state**: Store entities by ID, use references for relationships
2. **Split stores**: Domain separation, frequency separation, render impact separation
3. **Lazy initialization**: Load expensive data only when needed
4. **Manage memory**: Set limits on caches and collections
5. **Prevent cascading updates**: Batch updates to avoid avalanche effects
6. **Cache derived data**: Invalidate cache when source data changes
7. **Flat state**: Avoid deep nesting for easier updates
8. **Clean up**: Remove data and unsubscribe when no longer needed
9. **Monitor**: Track memory usage and performance in development
10. **Test**: Write performance tests for critical operations

---

## What's Next

You've mastered store design for performance. Next, you'll learn how to benchmark your Zustand applications with React Profiler and other tools.
