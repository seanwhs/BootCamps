# Capstone Project — Phase 1: Foundation Setup

Now it's time to build the foundation of TaskFlow. In this phase, you'll set up the monorepo, create the core Zustand stores, and establish the base architecture that everything else will build upon.

---

## The Target: Working Foundation

By the end of this phase, you'll have:
- A fully configured monorepo with pnpm workspaces
- Core stores (auth, task, ui) with basic functionality
- Persistence middleware for state recovery
- Devtools middleware for debugging
- A working Next.js 16 shell application
- A working React Native shell application
- Comprehensive tests for all stores

---

## Implementation: Foundation Setup

### Step 1: Monorepo Initialization

```bash
# Create root directory
mkdir taskflow
cd taskflow

# Initialize root package.json
pnpm init -y

# Create workspace configuration
# pnpm-workspace.yaml
packages:
  - "apps/*"
  - "packages/*"
  - "infrastructure/*"
  - "tools/*"

# Update root package.json
# package.json
{
  "name": "taskflow",
  "version": "0.1.0",
  "private": true,
  "scripts": {
    "dev": "pnpm -r dev",
    "build": "pnpm -r build",
    "test": "pnpm -r test",
    "lint": "pnpm -r lint",
    "clean": "pnpm -r clean"
  },
  "devDependencies": {
    "@types/node": "^20.11.0",
    "typescript": "^5.3.3",
    "pnpm": "^8.15.0"
  },
  "engines": {
    "node": ">=18.0.0",
    "pnpm": ">=8.0.0"
  }
}
```

### Step 2: Shared Package Setup

```bash
# Create shared package
mkdir -p packages/shared/src
cd packages/shared

# Initialize shared package
pnpm init -y
```

```json
// packages/shared/package.json
{
  "name": "@taskflow/shared",
  "version": "0.1.0",
  "private": true,
  "main": "./dist/index.js",
  "types": "./dist/index.d.ts",
  "scripts": {
    "build": "tsc",
    "dev": "tsc --watch",
    "test": "vitest"
  },
  "dependencies": {
    "zustand": "^4.5.0",
    "immer": "^10.0.3",
    "reselect": "^5.0.1"
  },
  "devDependencies": {
    "typescript": "^5.3.3",
    "@types/react": "^18.2.45",
    "vitest": "^1.1.0",
    "@testing-library/react": "^14.1.2",
    "@testing-library/jest-dom": "^6.1.5"
  }
}
```

```json
// packages/shared/tsconfig.json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "ESNext",
    "moduleResolution": "bundler",
    "lib": ["ES2022", "DOM", "DOM.Iterable"],
    "jsx": "react-jsx",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "declaration": true,
    "outDir": "./dist",
    "rootDir": "./src"
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist", "**/__tests__"]
}
```

### Step 3: Shared Types

```typescript
// packages/shared/src/types/index.ts
export * from './common.types';
export * from './auth.types';
export * from './task.types';
export * from './ui.types';
export * from './notification.types';
```

```typescript
// packages/shared/src/types/common.types.ts
export type ID = string;
export type Timestamp = Date;
export type Status = 'idle' | 'loading' | 'succeeded' | 'failed';
export type Priority = 'low' | 'medium' | 'high';

export interface BaseEntity {
  id: ID;
  createdAt: Timestamp;
  updatedAt: Timestamp;
}

export interface ApiResponse<T> {
  data: T;
  status: number;
  message?: string;
  timestamp: string;
}

export interface PaginatedResponse<T> {
  data: T[];
  total: number;
  page: number;
  limit: number;
  totalPages: number;
}
```

```typescript
// packages/shared/src/types/auth.types.ts
import { ID, BaseEntity } from './common.types';

export interface User extends BaseEntity {
  email: string;
  name: string;
  avatar?: string;
  role: 'admin' | 'manager' | 'user';
  permissions: string[];
  preferences: UserPreferences;
  lastLogin?: Timestamp;
}

export interface UserPreferences {
  theme: 'light' | 'dark' | 'system';
  language: string;
  timezone: string;
  notifications: NotificationPreferences;
}

export interface NotificationPreferences {
  email: boolean;
  push: boolean;
  inApp: boolean;
}

export interface AuthTokens {
  accessToken: string;
  refreshToken: string;
  expiresIn: number;
}

export interface LoginCredentials {
  email: string;
  password: string;
}

export interface RegisterCredentials extends LoginCredentials {
  name: string;
}

export interface AuthState {
  user: User | null;
  tokens: AuthTokens | null;
  isAuthenticated: boolean;
  isLoading: boolean;
  error: string | null;
}
```

```typescript
// packages/shared/src/types/task.types.ts
import { ID, BaseEntity, Priority } from './common.types';

export interface Task extends BaseEntity {
  title: string;
  description?: string;
  completed: boolean;
  priority: Priority;
  dueDate?: Timestamp;
  assigneeId?: ID;
  createdBy: ID;
  tags: string[];
  comments: Comment[];
  attachments: Attachment[];
}

export interface Comment extends BaseEntity {
  taskId: ID;
  userId: ID;
  content: string;
}

export interface Attachment extends BaseEntity {
  taskId: ID;
  name: string;
  url: string;
  size: number;
  type: string;
  uploadedBy: ID;
}

export interface TaskFilters {
  status: 'all' | 'active' | 'completed';
  priority: Priority | 'all';
  assignee: ID | 'all' | 'unassigned';
  tags: string[];
  dueDate: 'overdue' | 'today' | 'week' | 'month' | 'all';
  searchQuery: string;
}

export interface TaskSort {
  field: 'title' | 'priority' | 'dueDate' | 'createdAt' | 'updatedAt';
  direction: 'asc' | 'desc';
}

export interface TaskState {
  tasks: Record<ID, Task>;
  taskIds: ID[];
  loading: boolean;
  error: string | null;
  filters: TaskFilters;
  sort: TaskSort;
  selectedTaskId: ID | null;
}
```

```typescript
// packages/shared/src/types/ui.types.ts
export interface ToastMessage {
  id: string;
  type: 'success' | 'error' | 'warning' | 'info';
  title?: string;
  message: string;
  duration?: number;
  createdAt: Date;
}

export interface ModalState {
  isOpen: boolean;
  content: React.ReactNode | null;
  onClose?: () => void;
  onConfirm?: () => void;
  title?: string;
}

export interface UIState {
  theme: 'light' | 'dark' | 'system';
  sidebarOpen: boolean;
  sidebarCollapsed: boolean;
  modals: Record<string, ModalState>;
  toasts: ToastMessage[];
  isLoading: Record<string, boolean>;
}
```

### Step 4: Core Stores

```typescript
// packages/shared/src/store/index.ts
export * from './auth';
export * from './task';
export * from './ui';
export * from './notification';
```

```typescript
// packages/shared/src/store/auth/authStore.ts
import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';
import { immer } from 'zustand/middleware/immer';
import { AuthState, User, AuthTokens, LoginCredentials, RegisterCredentials } from '../../types';
import { authApi } from '../../services/authApi';

interface AuthStore extends AuthState {
  // Actions
  login: (credentials: LoginCredentials) => Promise<void>;
  register: (credentials: RegisterCredentials) => Promise<void>;
  logout: () => Promise<void>;
  refreshSession: () => Promise<void>;
  updateUser: (updates: Partial<User>) => void;
  clearError: () => void;
  reset: () => void;
  
  // Helpers
  getAccessToken: () => string | null;
  getRefreshToken: () => string | null;
  hasRole: (role: User['role']) => boolean;
  hasPermission: (permission: string) => boolean;
}

const initialState: AuthState = {
  user: null,
  tokens: null,
  isAuthenticated: false,
  isLoading: false,
  error: null,
};

export const useAuthStore = create<AuthStore>()(
  persist(
    immer((set, get) => ({
      ...initialState,

      login: async (credentials: LoginCredentials) => {
        set({ isLoading: true, error: null });
        try {
          const response = await authApi.login(credentials);
          set({
            user: response.user,
            tokens: response.tokens,
            isAuthenticated: true,
            isLoading: false,
            error: null,
          });
        } catch (error) {
          set({
            isLoading: false,
            error: error instanceof Error ? error.message : 'Login failed',
          });
          throw error;
        }
      },

      register: async (credentials: RegisterCredentials) => {
        set({ isLoading: true, error: null });
        try {
          const response = await authApi.register(credentials);
          set({
            user: response.user,
            tokens: response.tokens,
            isAuthenticated: true,
            isLoading: false,
            error: null,
          });
        } catch (error) {
          set({
            isLoading: false,
            error: error instanceof Error ? error.message : 'Registration failed',
          });
          throw error;
        }
      },

      logout: async () => {
        const { tokens } = get();
        set({ isLoading: true });
        try {
          if (tokens?.refreshToken) {
            await authApi.logout(tokens.refreshToken);
          }
        } catch (error) {
          console.error('Logout error:', error);
        } finally {
          set({
            ...initialState,
            isLoading: false,
          });
        }
      },

      refreshSession: async () => {
        const { tokens } = get();
        if (!tokens?.refreshToken) {
          set({ isAuthenticated: false });
          return;
        }

        set({ isLoading: true, error: null });
        try {
          const newTokens = await authApi.refreshToken(tokens.refreshToken);
          set({ tokens: newTokens, isLoading: false });
          // Refresh user data
          try {
            const user = await authApi.getCurrentUser(newTokens.accessToken);
            set({ user });
          } catch (userError) {
            console.error('Failed to refresh user data:', userError);
          }
        } catch (error) {
          set({
            ...initialState,
            isLoading: false,
            error: error instanceof Error ? error.message : 'Session expired',
          });
          throw error;
        }
      },

      updateUser: (updates: Partial<User>) => {
        set((state) => {
          if (state.user) {
            Object.assign(state.user, updates);
          }
        });
      },

      clearError: () => {
        set({ error: null });
      },

      reset: () => {
        set(initialState);
      },

      getAccessToken: () => {
        return get().tokens?.accessToken || null;
      },

      getRefreshToken: () => {
        return get().tokens?.refreshToken || null;
      },

      hasRole: (role: User['role']) => {
        return get().user?.role === role;
      },

      hasPermission: (permission: string) => {
        return get().user?.permissions?.includes(permission) || false;
      },
    })),
    {
      name: 'auth-storage',
      storage: createJSONStorage(() => localStorage),
      partialize: (state) => ({
        user: state.user,
        tokens: state.tokens,
        isAuthenticated: state.isAuthenticated,
      }),
    }
  )
);
```

```typescript
// packages/shared/src/store/task/taskStore.ts
import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';
import { immer } from 'zustand/middleware/immer';
import { Task, TaskState, TaskFilters, TaskSort } from '../../types';
import { taskApi } from '../../services/taskApi';
import { eventBus } from '../../events';

const initialState: TaskState = {
  tasks: {},
  taskIds: [],
  loading: false,
  error: null,
  filters: {
    status: 'all',
    priority: 'all',
    assignee: 'all',
    tags: [],
    dueDate: 'all',
    searchQuery: '',
  },
  sort: {
    field: 'createdAt',
    direction: 'desc',
  },
  selectedTaskId: null,
};

export const useTaskStore = create<TaskState>()(
  persist(
    immer((set, get) => ({
      ...initialState,

      // --- CRUD Operations ---
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

      addTask: async (taskData: Omit<Task, 'id' | 'createdAt' | 'updatedAt'>) => {
        const tempId = `temp-${Date.now()}`;
        const optimisticTask: Task = {
          ...taskData,
          id: tempId,
          createdAt: new Date(),
          updatedAt: new Date(),
          comments: [],
          attachments: [],
        };

        // Optimistic add
        set((state) => {
          state.tasks[tempId] = optimisticTask;
          state.taskIds.push(tempId);
        });

        try {
          const savedTask = await taskApi.createTask(taskData);
          set((state) => {
            delete state.tasks[tempId];
            state.tasks[savedTask.id] = savedTask;
            state.taskIds = state.taskIds.map(id => id === tempId ? savedTask.id : id);
          });
          eventBus.publish('task:created', savedTask);
          return savedTask;
        } catch (error) {
          // Rollback
          set((state) => {
            delete state.tasks[tempId];
            state.taskIds = state.taskIds.filter(id => id !== tempId);
            state.error = error instanceof Error ? error.message : 'Failed to add task';
          });
          throw error;
        }
      },

      updateTask: async (id: string, updates: Partial<Task>) => {
        const currentTask = get().tasks[id];
        if (!currentTask) throw new Error('Task not found');

        // Optimistic update
        set((state) => {
          if (state.tasks[id]) {
            Object.assign(state.tasks[id], updates, { updatedAt: new Date() });
          }
        });

        try {
          const updatedTask = await taskApi.updateTask(id, updates);
          set((state) => {
            state.tasks[id] = updatedTask;
          });
          eventBus.publish('task:updated', updatedTask);
        } catch (error) {
          // Rollback
          set((state) => {
            state.tasks[id] = currentTask;
            state.error = error instanceof Error ? error.message : 'Failed to update task';
          });
          throw error;
        }
      },

      deleteTask: async (id: string) => {
        const deletedTask = get().tasks[id];
        if (!deletedTask) return;

        // Optimistic delete
        set((state) => {
          delete state.tasks[id];
          state.taskIds = state.taskIds.filter(taskId => taskId !== id);
          if (state.selectedTaskId === id) {
            state.selectedTaskId = null;
          }
        });

        try {
          await taskApi.deleteTask(id);
          eventBus.publish('task:deleted', { id });
        } catch (error) {
          // Rollback
          set((state) => {
            state.tasks[id] = deletedTask;
            state.taskIds.push(id);
            state.error = error instanceof Error ? error.message : 'Failed to delete task';
          });
          throw error;
        }
      },

      toggleTask: async (id: string) => {
        const task = get().tasks[id];
        if (!task) return;

        const newCompleted = !task.completed;
        await get().updateTask(id, { completed: newCompleted });
        if (newCompleted) {
          eventBus.publish('task:completed', { id });
        }
      },

      // --- Filters ---
      setFilters: (filters: Partial<TaskFilters>) => {
        set((state) => {
          state.filters = { ...state.filters, ...filters };
        });
      },

      setSort: (sort: Partial<TaskSort>) => {
        set((state) => {
          state.sort = { ...state.sort, ...sort };
        });
      },

      resetFilters: () => {
        set({ filters: initialState.filters });
      },

      // --- Selection ---
      selectTask: (id: string | null) => {
        set({ selectedTaskId: id });
      },

      // --- Utility ---
      clearError: () => {
        set({ error: null });
      },

      reset: () => {
        set(initialState);
      },

      // Computed selectors (implemented as methods for simplicity)
      getFilteredTasks: () => {
        const state = get();
        let taskList = state.taskIds.map(id => state.tasks[id]).filter(Boolean);
        const { filters, sort } = state;

        // Apply status filter
        if (filters.status === 'active') {
          taskList = taskList.filter(t => !t.completed);
        } else if (filters.status === 'completed') {
          taskList = taskList.filter(t => t.completed);
        }

        // Apply priority filter
        if (filters.priority !== 'all') {
          taskList = taskList.filter(t => t.priority === filters.priority);
        }

        // Apply assignee filter
        if (filters.assignee === 'unassigned') {
          taskList = taskList.filter(t => !t.assigneeId);
        } else if (filters.assignee !== 'all') {
          taskList = taskList.filter(t => t.assigneeId === filters.assignee);
        }

        // Apply search filter
        if (filters.searchQuery.trim()) {
          const query = filters.searchQuery.toLowerCase().trim();
          taskList = taskList.filter(t =>
            t.title.toLowerCase().includes(query) ||
            (t.description && t.description.toLowerCase().includes(query)) ||
            t.tags.some(tag => tag.toLowerCase().includes(query))
          );
        }

        // Apply sorting
        taskList.sort((a, b) => {
          let comparison = 0;
          const field = sort.field;
          if (field === 'title') {
            comparison = a.title.localeCompare(b.title);
          } else if (field === 'priority') {
            const order = { high: 3, medium: 2, low: 1 };
            comparison = order[b.priority] - order[a.priority];
          } else if (field === 'dueDate') {
            if (!a.dueDate && !b.dueDate) comparison = 0;
            else if (!a.dueDate) comparison = 1;
            else if (!b.dueDate) comparison = -1;
            else comparison = a.dueDate.getTime() - b.dueDate.getTime();
          } else if (field === 'createdAt' || field === 'updatedAt') {
            const aTime = field === 'createdAt' ? a.createdAt.getTime() : a.updatedAt.getTime();
            const bTime = field === 'createdAt' ? b.createdAt.getTime() : b.updatedAt.getTime();
            comparison = aTime - bTime;
          }
          return sort.direction === 'asc' ? comparison : -comparison;
        });

        return taskList;
      },

      getTaskStats: () => {
        const state = get();
        const tasks = state.taskIds.map(id => state.tasks[id]).filter(Boolean);
        return {
          total: tasks.length,
          completed: tasks.filter(t => t.completed).length,
          active: tasks.filter(t => !t.completed).length,
          highPriority: tasks.filter(t => t.priority === 'high').length,
        };
      },
    })),
    {
      name: 'task-storage',
      storage: createJSONStorage(() => localStorage),
      partialize: (state) => ({
        tasks: state.tasks,
        taskIds: state.taskIds,
        filters: state.filters,
        sort: state.sort,
      }),
    }
  )
);
```

```typescript
// packages/shared/src/store/ui/uiStore.ts
import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';
import { immer } from 'zustand/middleware/immer';
import { UIState, ToastMessage, ModalState } from '../../types';

interface UIStore extends UIState {
  // Theme
  setTheme: (theme: UIState['theme']) => void;
  
  // Sidebar
  toggleSidebar: () => void;
  setSidebarCollapsed: (collapsed: boolean) => void;
  
  // Modals
  openModal: (id: string, config: Partial<ModalState>) => void;
  closeModal: (id: string) => void;
  closeAllModals: () => void;
  
  // Toasts
  addToast: (toast: Omit<ToastMessage, 'id' | 'createdAt'>) => void;
  removeToast: (id: string) => void;
  clearToasts: () => void;
  
  // Loading
  setLoading: (id: string, loading: boolean) => void;
  clearLoading: () => void;
  
  // Reset
  reset: () => void;
}

const initialState: UIState = {
  theme: 'system',
  sidebarOpen: true,
  sidebarCollapsed: false,
  modals: {},
  toasts: [],
  isLoading: {},
};

export const useUIStore = create<UIStore>()(
  persist(
    immer((set, get) => ({
      ...initialState,

      setTheme: (theme) => {
        set({ theme });
        // Apply theme to document
        if (typeof document !== 'undefined') {
          if (theme === 'system') {
            const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
            document.documentElement.classList.toggle('dark', prefersDark);
          } else {
            document.documentElement.classList.toggle('dark', theme === 'dark');
          }
        }
      },

      toggleSidebar: () => {
        set((state) => ({ sidebarOpen: !state.sidebarOpen }));
      },

      setSidebarCollapsed: (collapsed) => {
        set({ sidebarCollapsed: collapsed });
      },

      openModal: (id, config) => {
        set((state) => {
          state.modals[id] = {
            isOpen: true,
            content: config.content || null,
            onClose: config.onClose,
            onConfirm: config.onConfirm,
            title: config.title,
          };
        });
      },

      closeModal: (id) => {
        set((state) => {
          const modal = state.modals[id];
          if (modal && modal.onClose) {
            modal.onClose();
          }
          delete state.modals[id];
        });
      },

      closeAllModals: () => {
        const modals = get().modals;
        for (const id of Object.keys(modals)) {
          get().closeModal(id);
        }
      },

      addToast: (toast) => {
        const id = `toast-${Date.now()}`;
        const newToast: ToastMessage = {
          ...toast,
          id,
          createdAt: new Date(),
        };
        set((state) => {
          state.toasts.push(newToast);
        });
        // Auto-remove
        const duration = toast.duration || 5000;
        setTimeout(() => {
          get().removeToast(id);
        }, duration);
      },

      removeToast: (id) => {
        set((state) => {
          state.toasts = state.toasts.filter(t => t.id !== id);
        });
      },

      clearToasts: () => {
        set({ toasts: [] });
      },

      setLoading: (id, loading) => {
        set((state) => {
          if (loading) {
            state.isLoading[id] = true;
          } else {
            delete state.isLoading[id];
          }
        });
      },

      clearLoading: () => {
        set({ isLoading: {} });
      },

      reset: () => {
        set(initialState);
      },
    })),
    {
      name: 'ui-storage',
      storage: createJSONStorage(() => localStorage),
      partialize: (state) => ({
        theme: state.theme,
        sidebarCollapsed: state.sidebarCollapsed,
      }),
    }
  )
);
```

### Step 5: Event Bus

```typescript
// packages/shared/src/events/index.ts
export * from './eventBus';
export * from './events';
```

```typescript
// packages/shared/src/events/eventBus.ts
type EventHandler<T = any> = (payload: T) => void;

export interface EventMap {
  'auth:login': { user: any };
  'auth:logout': void;
  'task:created': any;
  'task:updated': any;
  'task:deleted': { id: string };
  'task:completed': { id: string };
  'notification:new': any;
}

export class EventBus {
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

  clear(): void {
    this.handlers.clear();
  }

  // For debugging
  getSubscriberCount(): number {
    let count = 0;
    for (const set of this.handlers.values()) {
      count += set.size;
    }
    return count;
  }
}

export const eventBus = new EventBus();
```

### Step 6: Web Application Setup

```bash
# Create web app
cd apps
pnpm create next-app web --typescript --tailwind --app --eslint --import-alias '@/*'
cd web

# Install dependencies
pnpm add zustand immer reselect
pnpm add -D @types/node @types/react @types/react-dom

# Link shared package
pnpm add @taskflow/shared@workspace:*
```

```typescript
// apps/web/app/layout.tsx
import type { Metadata } from 'next';
import { Inter } from 'next/font/google';
import './globals.css';
import { Providers } from '@/components/providers';

const inter = Inter({ subsets: ['latin'] });

export const metadata: Metadata = {
  title: 'TaskFlow',
  description: 'Production task management application',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en" suppressHydrationWarning>
      <body className={inter.className}>
        <Providers>{children}</Providers>
      </body>
    </html>
  );
}
```

```tsx
// apps/web/app/page.tsx
import { redirect } from 'next/navigation';
import { TaskDashboard } from '@/components/dashboard/TaskDashboard';

export default function HomePage() {
  // In a real app, check authentication and redirect accordingly
  return <TaskDashboard />;
}
```

```tsx
// apps/web/components/providers/index.tsx
'use client';

import React from 'react';
import { useUIStore } from '@taskflow/shared';

export function Providers({ children }: { children: React.ReactNode }) {
  const { theme } = useUIStore();

  return (
    <div className={theme === 'dark' ? 'dark' : ''}>
      {children}
    </div>
  );
}
```

```tsx
// apps/web/components/dashboard/TaskDashboard.tsx
'use client';

import React, { useEffect } from 'react';
import { useTaskStore, useUIStore } from '@taskflow/shared';
import { TaskList } from './TaskList';
import { TaskStats } from './TaskStats';
import { TaskFilters } from './TaskFilters';
import { AddTaskForm } from './AddTaskForm';

export function TaskDashboard() {
  const { fetchTasks, loading, error } = useTaskStore();
  const { addToast } = useUIStore();

  useEffect(() => {
    fetchTasks().catch((err) => {
      addToast({
        type: 'error',
        message: 'Failed to load tasks',
        title: 'Error',
      });
    });
  }, []);

  if (loading) {
    return <div className="flex justify-center items-center h-64">Loading tasks...</div>;
  }

  if (error) {
    return (
      <div className="text-red-500 p-4">
        <h2>Error loading tasks</h2>
        <p>{error}</p>
      </div>
    );
  }

  return (
    <div className="container mx-auto p-4 max-w-6xl">
      <h1 className="text-3xl font-bold mb-6">Task Dashboard</h1>
      <TaskStats />
      <div className="grid grid-cols-1 lg:grid-cols-4 gap-6">
        <div className="lg:col-span-1">
          <TaskFilters />
        </div>
        <div className="lg:col-span-3">
          <AddTaskForm />
          <TaskList />
        </div>
      </div>
    </div>
  );
}
```

---

## The Verification: Testing Foundation

### Step 1: Run Development Server

```bash
cd apps/web
pnpm dev
```

Open `http://localhost:3000` — you should see the dashboard.

### Step 2: Test Stores

```typescript
// packages/shared/src/store/__tests__/auth.store.test.ts
import { describe, it, expect, beforeEach } from 'vitest';
import { useAuthStore } from '../auth';

describe('Auth Store', () => {
  beforeEach(() => {
    useAuthStore.setState({
      user: null,
      tokens: null,
      isAuthenticated: false,
      isLoading: false,
      error: null,
    });
  });

  it('should have initial state', () => {
    const state = useAuthStore.getState();
    expect(state.isAuthenticated).toBe(false);
    expect(state.user).toBe(null);
    expect(state.tokens).toBe(null);
  });

  it('should update user', () => {
    const { updateUser } = useAuthStore.getState();
    const user = {
      id: 'user-1',
      email: 'test@example.com',
      name: 'Test User',
      role: 'user' as const,
      permissions: [],
      preferences: {
        theme: 'system' as const,
        language: 'en',
        timezone: 'UTC',
        notifications: {
          email: true,
          push: true,
          inApp: true,
        },
      },
      createdAt: new Date(),
      updatedAt: new Date(),
    };
    useAuthStore.setState({ user });
    updateUser({ name: 'Updated Name' });
    expect(useAuthStore.getState().user?.name).toBe('Updated Name');
  });
});
```

### Step 3: Run Tests

```bash
pnpm test
```

Expected output:
```
✓ packages/shared/src/store/__tests__/auth.store.test.ts
✓ packages/shared/src/store/__tests__/task.store.test.ts
✓ packages/shared/src/store/__tests__/ui.store.test.ts

Test Files  3 passed (3)
     Tests  12 passed (12)
  Duration  2.34s
```

---

## What's Next

You've built the foundation! Next, we'll implement the authentication system with login, registration, and protected routes.
