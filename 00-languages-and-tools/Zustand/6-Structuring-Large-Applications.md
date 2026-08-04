# Part 2 — Advanced State Architecture

## Section 6: Structuring Large Applications

Congratulations on completing Part 1! You now have a solid foundation in Zustand's core concepts. But real-world applications are rarely simple—they grow, evolve, and become complex. In this section, you'll learn how to structure Zustand stores for large applications that remain maintainable, scalable, and understandable as they grow.

---

## The Target: Scalable Store Architecture

By the end of this section, you'll be able to:
- Organize stores by features and domains
- Implement the slice pattern for modular state
- Compose stores together for complex applications
- Avoid monolithic store anti-patterns
- Design maintainable state architectures for enterprise applications

---

## The Concept: Modular State Architecture

Think of a large application like a well-organized office building:

```
Monolithic Store (Bad):
┌─────────────────────────────────────────────────────────┐
│              ONE GIANT ROOM                            │
│  ┌────────────────────────────────────────────────┐   │
│  │  Everything together:                          │   │
│  │  - User data                                   │   │
│  │  - Tasks                                       │   │
│  │  - UI settings                                 │   │
│  │  - Notifications                               │   │
│  │  - Shopping cart                               │   │
│  │  - Analytics                                   │   │
│  │  - Comments                                    │   │
│  │  - ... and 50 more domains                     │   │
│  └────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
Problems: Hard to find anything, teams conflict, performance suffers

Modular Architecture (Good):
┌─────────────────────────────────────────────────────────┐
│              OFFICE BUILDING                           │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐           │
│  │ User     │  │ Tasks    │  │ Notifica-│           │
│  │ Floor    │  │ Floor    │  │ tions    │           │
│  │          │  │          │  │ Floor    │           │
│  └──────────┘  └──────────┘  └──────────┘           │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐           │
│  │ Settings │  │ Cart     │  │ Analytics│           │
│  │ Floor    │  │ Floor    │  │ Floor    │           │
│  └──────────┘  └──────────┘  └──────────┘           │
└─────────────────────────────────────────────────────────┘
Benefits: Clear organization, independent teams, focused changes
```

### The Slice Pattern

The **slice pattern** is the most powerful way to structure large Zustand applications. Think of slices as **independent modules** that each manage a specific domain:

```typescript
// Each slice is a self-contained module
const userSlice = (set, get) => ({
  user: null,
  login: (credentials) => { /* ... */ },
  logout: () => { /* ... */ },
});

const taskSlice = (set, get) => ({
  tasks: [],
  addTask: (task) => { /* ... */ },
  completeTask: (id) => { /* ... */ },
});

// Combine slices into a single store
const useStore = create((set, get) => ({
  ...userSlice(set, get),
  ...taskSlice(set, get),
}));
```

---

## The Implementation: Building a Modular Store Architecture

### Step 1: Project Structure

First, let's set up a scalable project structure:

```
src/
├── store/
│   ├── index.ts                 # Main store export
│   ├── slices/
│   │   ├── userSlice.ts         # User domain
│   │   ├── taskSlice.ts         # Task domain
│   │   ├── uiSlice.ts           # UI settings
│   │   ├── notificationSlice.ts # Notifications
│   │   └── analyticsSlice.ts    # Analytics
│   ├── types/
│   │   ├── user.types.ts
│   │   ├── task.types.ts
│   │   └── common.types.ts
│   └── selectors/
│       ├── userSelectors.ts
│       ├── taskSelectors.ts
│       └── uiSelectors.ts
```

### Step 2: Define Types

Let's start by defining our types:

```typescript
// src/store/types/common.types.ts
export type ID = string;
export type Timestamp = Date;
export type Priority = 'low' | 'medium' | 'high';
export type Status = 'idle' | 'loading' | 'succeeded' | 'failed';

export interface BaseEntity {
  id: ID;
  createdAt: Timestamp;
  updatedAt: Timestamp;
}
```

```typescript
// src/store/types/user.types.ts
import { ID, Timestamp } from './common.types';

export interface User {
  id: ID;
  email: string;
  name: string;
  avatar?: string;
  role: 'admin' | 'manager' | 'user';
  preferences: UserPreferences;
  createdAt: Timestamp;
  lastLogin?: Timestamp;
}

export interface UserPreferences {
  theme: 'light' | 'dark' | 'system';
  notifications: NotificationPreferences;
  language: string;
  timezone: string;
}

export interface NotificationPreferences {
  email: boolean;
  push: boolean;
  inApp: boolean;
  quietHours: QuietHours;
}

export interface QuietHours {
  enabled: boolean;
  start: string; // HH:mm
  end: string; // HH:mm
}
```

```typescript
// src/store/types/task.types.ts
import { ID, Timestamp, Priority } from './common.types';

export interface Task {
  id: ID;
  title: string;
  description?: string;
  completed: boolean;
  priority: Priority;
  dueDate?: Timestamp;
  tags: string[];
  assigneeId?: ID;
  createdBy: ID;
  createdAt: Timestamp;
  updatedAt: Timestamp;
  comments: Comment[];
  attachments: Attachment[];
}

export interface Comment {
  id: ID;
  taskId: ID;
  userId: ID;
  content: string;
  createdAt: Timestamp;
  updatedAt: Timestamp;
}

export interface Attachment {
  id: ID;
  taskId: ID;
  name: string;
  url: string;
  size: number;
  type: string;
  uploadedBy: ID;
  uploadedAt: Timestamp;
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
```

### Step 3: Create the User Slice

```typescript
// src/store/slices/userSlice.ts
import { StateCreator } from 'zustand';
import { User, UserPreferences } from '../types/user.types';
import { ID } from '../types/common.types';

// Define the user slice state
export interface UserSlice {
  // State
  user: User | null;
  isAuthenticated: boolean;
  authLoading: boolean;
  authError: string | null;
  users: Record<ID, User>; // Cache for other users
  userLoading: Record<ID, boolean>;
  userErrors: Record<ID, string | null>;
  
  // Actions
  login: (email: string, password: string) => Promise<void>;
  logout: () => void;
  updateUser: (updates: Partial<User>) => void;
  updatePreferences: (preferences: Partial<UserPreferences>) => void;
  fetchUser: (userId: ID) => Promise<void>;
  clearAuthError: () => void;
  
  // Computed
  getCurrentUser: () => User | null;
  isUserAdmin: () => boolean;
  getUserName: () => string;
}

// Create the slice
export const createUserSlice: StateCreator<UserSlice, [], [], UserSlice> = (
  set,
  get
) => ({
  // Initial state
  user: null,
  isAuthenticated: false,
  authLoading: false,
  authError: null,
  users: {},
  userLoading: {},
  userErrors: {},

  // --- Login Action ---
  login: async (email: string, password: string) => {
    // Set loading state
    set({ authLoading: true, authError: null });
    
    try {
      // Simulate API call
      await new Promise(resolve => setTimeout(resolve, 1000));
      
      // Mock successful login
      const user: User = {
        id: 'user-1',
        email,
        name: 'John Doe',
        role: 'admin',
        preferences: {
          theme: 'system',
          notifications: {
            email: true,
            push: true,
            inApp: true,
            quietHours: {
              enabled: false,
              start: '22:00',
              end: '07:00',
            },
          },
          language: 'en-US',
          timezone: 'America/New_York',
        },
        createdAt: new Date(),
        lastLogin: new Date(),
      };
      
      set({
        user,
        isAuthenticated: true,
        authLoading: false,
        authError: null,
      });
      
      // Cache the user
      set((state) => ({
        users: {
          ...state.users,
          [user.id]: user,
        },
      }));
      
    } catch (error) {
      set({
        authLoading: false,
        authError: error instanceof Error ? error.message : 'Login failed',
      });
      throw error;
    }
  },

  // --- Logout Action ---
  logout: () => {
    set({
      user: null,
      isAuthenticated: false,
      authError: null,
    });
    // Clear any cached data
    // This could also clear other slices via cross-slice communication
  },

  // --- Update User ---
  updateUser: (updates: Partial<User>) => {
    set((state) => {
      if (!state.user) return state;
      
      const updatedUser = {
        ...state.user,
        ...updates,
        updatedAt: new Date(),
      };
      
      return {
        user: updatedUser,
        users: {
          ...state.users,
          [updatedUser.id]: updatedUser,
        },
      };
    });
  },

  // --- Update Preferences ---
  updatePreferences: (preferences: Partial<UserPreferences>) => {
    set((state) => {
      if (!state.user) return state;
      
      const updatedUser = {
        ...state.user,
        preferences: {
          ...state.user.preferences,
          ...preferences,
        },
        updatedAt: new Date(),
      };
      
      return {
        user: updatedUser,
        users: {
          ...state.users,
          [updatedUser.id]: updatedUser,
        },
      };
    });
  },

  // --- Fetch Other Users ---
  fetchUser: async (userId: ID) => {
    // Skip if already loading or cached
    if (get().users[userId] || get().userLoading[userId]) {
      return;
    }
    
    set((state) => ({
      userLoading: { ...state.userLoading, [userId]: true },
      userErrors: { ...state.userErrors, [userId]: null },
    }));
    
    try {
      // Simulate API call
      await new Promise(resolve => setTimeout(resolve, 500));
      
      // Mock user data
      const user: User = {
        id: userId,
        email: `user-${userId}@example.com`,
        name: `User ${userId}`,
        role: 'user',
        preferences: {
          theme: 'system',
          notifications: {
            email: true,
            push: true,
            inApp: true,
            quietHours: {
              enabled: false,
              start: '22:00',
              end: '07:00',
            },
          },
          language: 'en-US',
          timezone: 'America/New_York',
        },
        createdAt: new Date(),
      };
      
      set((state) => ({
        users: { ...state.users, [userId]: user },
        userLoading: { ...state.userLoading, [userId]: false },
      }));
      
    } catch (error) {
      set((state) => ({
        userLoading: { ...state.userLoading, [userId]: false },
        userErrors: {
          ...state.userErrors,
          [userId]: error instanceof Error ? error.message : 'Failed to fetch user',
        },
      }));
    }
  },

  // --- Clear Auth Error ---
  clearAuthError: () => {
    set({ authError: null });
  },

  // --- Computed Values ---
  getCurrentUser: () => {
    return get().user;
  },

  isUserAdmin: () => {
    return get().user?.role === 'admin';
  },

  getUserName: () => {
    return get().user?.name || 'Guest';
  },
});
```

### Step 4: Create the Task Slice

```typescript
// src/store/slices/taskSlice.ts
import { StateCreator } from 'zustand';
import { Task, TaskFilters, TaskSort, Comment, Attachment } from '../types/task.types';
import { ID, Priority } from '../types/common.types';
import { UserSlice } from './userSlice';

// Define the task slice state
export interface TaskSlice {
  // State
  tasks: Record<ID, Task>;
  taskIds: ID[];
  taskLoading: Record<ID, boolean>;
  taskErrors: Record<ID, string | null>;
  taskListLoading: boolean;
  taskListError: string | null;
  filters: TaskFilters;
  sort: TaskSort;
  selectedTaskId: ID | null;
  
  // Actions
  fetchTasks: () => Promise<void>;
  fetchTask: (id: ID) => Promise<void>;
  createTask: (task: Omit<Task, 'id' | 'createdAt' | 'updatedAt'>) => Promise<Task>;
  updateTask: (id: ID, updates: Partial<Task>) => Promise<void>;
  deleteTask: (id: ID) => Promise<void>;
  toggleTaskComplete: (id: ID) => void;
  addComment: (taskId: ID, content: string) => void;
  deleteComment: (taskId: ID, commentId: ID) => void;
  setFilters: (filters: Partial<TaskFilters>) => void;
  setSort: (sort: Partial<TaskSort>) => void;
  selectTask: (id: ID | null) => void;
  clearTaskErrors: (id?: ID) => void;
  
  // Computed
  getFilteredTasks: () => Task[];
  getTaskById: (id: ID) => Task | undefined;
  getTaskStats: () => { total: number; completed: number; active: number };
  isTaskLoading: (id: ID) => boolean;
}

// Create the slice
export const createTaskSlice: StateCreator<
  TaskSlice & UserSlice, // Dependencies
  [],
  [],
  TaskSlice
> = (set, get) => ({
  // Initial state
  tasks: {},
  taskIds: [],
  taskLoading: {},
  taskErrors: {},
  taskListLoading: false,
  taskListError: null,
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

  // --- Fetch All Tasks ---
  fetchTasks: async () => {
    set({ taskListLoading: true, taskListError: null });
    
    try {
      // Simulate API call
      await new Promise(resolve => setTimeout(resolve, 1000));
      
      // Mock tasks
      const tasks: Task[] = [
        {
          id: 'task-1',
          title: 'Complete project proposal',
          description: 'Need to finish the Q4 proposal',
          completed: false,
          priority: 'high',
          dueDate: new Date(Date.now() + 86400000 * 2), // 2 days from now
          tags: ['work', 'important'],
          assigneeId: 'user-1',
          createdBy: 'user-1',
          createdAt: new Date(),
          updatedAt: new Date(),
          comments: [
            {
              id: 'comment-1',
              taskId: 'task-1',
              userId: 'user-1',
              content: 'Initial draft done',
              createdAt: new Date(),
              updatedAt: new Date(),
            },
          ],
          attachments: [],
        },
        {
          id: 'task-2',
          title: 'Review pull requests',
          description: 'Check team PRs',
          completed: false,
          priority: 'medium',
          dueDate: new Date(Date.now() + 86400000 * 1), // 1 day from now
          tags: ['work', 'code-review'],
          assigneeId: 'user-1',
          createdBy: 'user-1',
          createdAt: new Date(),
          updatedAt: new Date(),
          comments: [],
          attachments: [],
        },
        {
          id: 'task-3',
          title: 'Update documentation',
          description: 'API docs need updating',
          completed: true,
          priority: 'low',
          dueDate: new Date(Date.now() - 86400000 * 3), // 3 days ago
          tags: ['docs'],
          assigneeId: 'user-2',
          createdBy: 'user-1',
          createdAt: new Date(),
          updatedAt: new Date(),
          comments: [],
          attachments: [],
        },
      ];
      
      // Convert to record and extract IDs
      const tasksRecord: Record<ID, Task> = {};
      const taskIds: ID[] = [];
      
      tasks.forEach(task => {
        tasksRecord[task.id] = task;
        taskIds.push(task.id);
      });
      
      set({
        tasks: tasksRecord,
        taskIds,
        taskListLoading: false,
        taskListError: null,
      });
      
    } catch (error) {
      set({
        taskListLoading: false,
        taskListError: error instanceof Error ? error.message : 'Failed to fetch tasks',
      });
    }
  },

  // --- Fetch Single Task ---
  fetchTask: async (id: ID) => {
    // Skip if already loading or cached
    if (get().tasks[id] || get().taskLoading[id]) {
      return;
    }
    
    set((state) => ({
      taskLoading: { ...state.taskLoading, [id]: true },
      taskErrors: { ...state.taskErrors, [id]: null },
    }));
    
    try {
      // Simulate API call
      await new Promise(resolve => setTimeout(resolve, 500));
      
      // Mock task
      const task: Task = {
        id,
        title: `Task ${id}`,
        description: 'Description',
        completed: false,
        priority: 'medium',
        tags: [],
        createdBy: 'user-1',
        createdAt: new Date(),
        updatedAt: new Date(),
        comments: [],
        attachments: [],
      };
      
      set((state) => ({
        tasks: { ...state.tasks, [id]: task },
        taskLoading: { ...state.taskLoading, [id]: false },
        taskIds: state.taskIds.includes(id) ? state.taskIds : [...state.taskIds, id],
      }));
      
    } catch (error) {
      set((state) => ({
        taskLoading: { ...state.taskLoading, [id]: false },
        taskErrors: {
          ...state.taskErrors,
          [id]: error instanceof Error ? error.message : 'Failed to fetch task',
        },
      }));
    }
  },

  // --- Create Task ---
  createTask: async (taskData: Omit<Task, 'id' | 'createdAt' | 'updatedAt'>) => {
    try {
      // Simulate API call
      await new Promise(resolve => setTimeout(resolve, 500));
      
      const newTask: Task = {
        ...taskData,
        id: `task-${Date.now()}`,
        createdAt: new Date(),
        updatedAt: new Date(),
        comments: [],
        attachments: [],
      };
      
      set((state) => ({
        tasks: { ...state.tasks, [newTask.id]: newTask },
        taskIds: [newTask.id, ...state.taskIds],
      }));
      
      return newTask;
      
    } catch (error) {
      console.error('Failed to create task:', error);
      throw error;
    }
  },

  // --- Update Task ---
  updateTask: async (id: ID, updates: Partial<Task>) => {
    try {
      // Simulate API call
      await new Promise(resolve => setTimeout(resolve, 500));
      
      set((state) => {
        const existingTask = state.tasks[id];
        if (!existingTask) return state;
        
        return {
          tasks: {
            ...state.tasks,
            [id]: {
              ...existingTask,
              ...updates,
              updatedAt: new Date(),
            },
          },
        };
      });
      
    } catch (error) {
      console.error('Failed to update task:', error);
      throw error;
    }
  },

  // --- Delete Task ---
  deleteTask: async (id: ID) => {
    try {
      // Simulate API call
      await new Promise(resolve => setTimeout(resolve, 500));
      
      set((state) => {
        const { [id]: removed, ...remainingTasks } = state.tasks;
        return {
          tasks: remainingTasks,
          taskIds: state.taskIds.filter(taskId => taskId !== id),
          selectedTaskId: state.selectedTaskId === id ? null : state.selectedTaskId,
        };
      });
      
    } catch (error) {
      console.error('Failed to delete task:', error);
      throw error;
    }
  },

  // --- Toggle Task Completion ---
  toggleTaskComplete: (id: ID) => {
    set((state) => {
      const task = state.tasks[id];
      if (!task) return state;
      
      return {
        tasks: {
          ...state.tasks,
          [id]: {
            ...task,
            completed: !task.completed,
            updatedAt: new Date(),
          },
        },
      };
    });
  },

  // --- Add Comment ---
  addComment: (taskId: ID, content: string) => {
    set((state) => {
      const task = state.tasks[taskId];
      if (!task) return state;
      
      const newComment: Comment = {
        id: `comment-${Date.now()}`,
        taskId,
        userId: get().getCurrentUser()?.id || 'unknown',
        content,
        createdAt: new Date(),
        updatedAt: new Date(),
      };
      
      return {
        tasks: {
          ...state.tasks,
          [taskId]: {
            ...task,
            comments: [...task.comments, newComment],
            updatedAt: new Date(),
          },
        },
      };
    });
  },

  // --- Delete Comment ---
  deleteComment: (taskId: ID, commentId: ID) => {
    set((state) => {
      const task = state.tasks[taskId];
      if (!task) return state;
      
      return {
        tasks: {
          ...state.tasks,
          [taskId]: {
            ...task,
            comments: task.comments.filter(c => c.id !== commentId),
            updatedAt: new Date(),
          },
        },
      };
    });
  },

  // --- Set Filters ---
  setFilters: (filters: Partial<TaskFilters>) => {
    set((state) => ({
      filters: { ...state.filters, ...filters },
    }));
  },

  // --- Set Sort ---
  setSort: (sort: Partial<TaskSort>) => {
    set((state) => ({
      sort: { ...state.sort, ...sort },
    }));
  },

  // --- Select Task ---
  selectTask: (id: ID | null) => {
    set({ selectedTaskId: id });
  },

  // --- Clear Task Errors ---
  clearTaskErrors: (id?: ID) => {
    if (id) {
      set((state) => ({
        taskErrors: { ...state.taskErrors, [id]: null },
      }));
    } else {
      set({
        taskErrors: {},
        taskListError: null,
      });
    }
  },

  // --- Computed Values ---
  getFilteredTasks: () => {
    const state = get();
    const tasks = Object.values(state.tasks);
    const { filters, sort } = state;
    
    // Apply status filter
    let filtered = tasks.filter(task => {
      if (filters.status === 'active') return !task.completed;
      if (filters.status === 'completed') return task.completed;
      return true;
    });
    
    // Apply priority filter
    if (filters.priority !== 'all') {
      filtered = filtered.filter(task => task.priority === filters.priority);
    }
    
    // Apply assignee filter
    if (filters.assignee === 'unassigned') {
      filtered = filtered.filter(task => !task.assigneeId);
    } else if (filters.assignee !== 'all') {
      filtered = filtered.filter(task => task.assigneeId === filters.assignee);
    }
    
    // Apply tags filter
    if (filters.tags.length > 0) {
      filtered = filtered.filter(task =>
        filters.tags.some(tag => task.tags.includes(tag))
      );
    }
    
    // Apply due date filter
    if (filters.dueDate !== 'all') {
      const now = new Date();
      const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
      
      filtered = filtered.filter(task => {
        if (!task.dueDate) return false;
        const dueDate = new Date(task.dueDate);
        const dueDateDay = new Date(dueDate.getFullYear(), dueDate.getMonth(), dueDate.getDate());
        
        switch (filters.dueDate) {
          case 'overdue':
            return dueDateDay < today && !task.completed;
          case 'today':
            return dueDateDay.getTime() === today.getTime();
          case 'week': {
            const weekEnd = new Date(today);
            weekEnd.setDate(weekEnd.getDate() + 7);
            return dueDateDay >= today && dueDateDay <= weekEnd;
          }
          case 'month': {
            const monthEnd = new Date(today);
            monthEnd.setMonth(monthEnd.getMonth() + 1);
            return dueDateDay >= today && dueDateDay <= monthEnd;
          }
          default:
            return true;
        }
      });
    }
    
    // Apply search query
    if (filters.searchQuery.trim()) {
      const query = filters.searchQuery.toLowerCase().trim();
      filtered = filtered.filter(task =>
        task.title.toLowerCase().includes(query) ||
        task.description?.toLowerCase().includes(query) ||
        task.tags.some(tag => tag.toLowerCase().includes(query))
      );
    }
    
    // Apply sorting
    filtered.sort((a, b) => {
      let comparison = 0;
      switch (sort.field) {
        case 'title':
          comparison = a.title.localeCompare(b.title);
          break;
        case 'priority': {
          const priorityOrder = { high: 3, medium: 2, low: 1 };
          comparison = priorityOrder[b.priority] - priorityOrder[a.priority];
          break;
        }
        case 'dueDate':
          if (!a.dueDate && !b.dueDate) comparison = 0;
          else if (!a.dueDate) comparison = 1;
          else if (!b.dueDate) comparison = -1;
          else comparison = a.dueDate.getTime() - b.dueDate.getTime();
          break;
        case 'createdAt':
          comparison = a.createdAt.getTime() - b.createdAt.getTime();
          break;
        case 'updatedAt':
          comparison = a.updatedAt.getTime() - b.updatedAt.getTime();
          break;
        default:
          comparison = 0;
      }
      return sort.direction === 'asc' ? comparison : -comparison;
    });
    
    return filtered;
  },

  getTaskById: (id: ID) => {
    return get().tasks[id];
  },

  getTaskStats: () => {
    const tasks = Object.values(get().tasks);
    return {
      total: tasks.length,
      completed: tasks.filter(t => t.completed).length,
      active: tasks.filter(t => !t.completed).length,
    };
  },

  isTaskLoading: (id: ID) => {
    return get().taskLoading[id] || false;
  },
});
```

### Step 5: Create the UI Slice

```typescript
// src/store/slices/uiSlice.ts
import { StateCreator } from 'zustand';

export interface UISlice {
  // State
  theme: 'light' | 'dark' | 'system';
  sidebarOpen: boolean;
  sidebarCollapsed: boolean;
  modalOpen: Record<string, boolean>;
  toastMessages: ToastMessage[];
  isLoading: Record<string, boolean>;
  
  // Actions
  setTheme: (theme: 'light' | 'dark' | 'system') => void;
  toggleSidebar: () => void;
  setSidebarCollapsed: (collapsed: boolean) => void;
  openModal: (id: string) => void;
  closeModal: (id: string) => void;
  toggleModal: (id: string) => void;
  addToast: (message: Omit<ToastMessage, 'id' | 'createdAt'>) => void;
  removeToast: (id: string) => void;
  setLoading: (id: string, loading: boolean) => void;
  clearLoading: () => void;
}

export interface ToastMessage {
  id: string;
  type: 'success' | 'error' | 'warning' | 'info';
  title?: string;
  message: string;
  duration?: number;
  createdAt: Date;
}

export const createUISlice: StateCreator<UISlice, [], [], UISlice> = (
  set,
  get
) => ({
  // Initial state
  theme: 'system',
  sidebarOpen: true,
  sidebarCollapsed: false,
  modalOpen: {},
  toastMessages: [],
  isLoading: {},

  // --- Theme ---
  setTheme: (theme: 'light' | 'dark' | 'system') => {
    set({ theme });
    // Apply theme to document
    if (theme === 'system') {
      const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
      document.documentElement.classList.toggle('dark', prefersDark);
    } else {
      document.documentElement.classList.toggle('dark', theme === 'dark');
    }
  },

  // --- Sidebar ---
  toggleSidebar: () => {
    set((state) => ({ sidebarOpen: !state.sidebarOpen }));
  },

  setSidebarCollapsed: (collapsed: boolean) => {
    set({ sidebarCollapsed: collapsed });
  },

  // --- Modals ---
  openModal: (id: string) => {
    set((state) => ({
      modalOpen: { ...state.modalOpen, [id]: true },
    }));
  },

  closeModal: (id: string) => {
    set((state) => ({
      modalOpen: { ...state.modalOpen, [id]: false },
    }));
  },

  toggleModal: (id: string) => {
    set((state) => ({
      modalOpen: {
        ...state.modalOpen,
        [id]: !state.modalOpen[id],
      },
    }));
  },

  // --- Toast Messages ---
  addToast: (message: Omit<ToastMessage, 'id' | 'createdAt'>) => {
    const id = `toast-${Date.now()}`;
    const newToast: ToastMessage = {
      ...message,
      id,
      createdAt: new Date(),
    };
    
    set((state) => ({
      toastMessages: [...state.toastMessages, newToast],
    }));
    
    // Auto-remove after duration (default 5 seconds)
    const duration = message.duration || 5000;
    setTimeout(() => {
      get().removeToast(id);
    }, duration);
  },

  removeToast: (id: string) => {
    set((state) => ({
      toastMessages: state.toastMessages.filter(t => t.id !== id),
    }));
  },

  // --- Loading States ---
  setLoading: (id: string, loading: boolean) => {
    set((state) => ({
      isLoading: { ...state.isLoading, [id]: loading },
    }));
  },

  clearLoading: () => {
    set({ isLoading: {} });
  },
});
```

### Step 6: Combine Slices into the Main Store

```typescript
// src/store/index.ts
import { create } from 'zustand';
import { devtools, persist } from 'zustand/middleware';
import { createUserSlice, UserSlice } from './slices/userSlice';
import { createTaskSlice, TaskSlice } from './slices/taskSlice';
import { createUISlice, UISlice } from './slices/uiSlice';

// Define the root store type
export type RootStore = UserSlice & TaskSlice & UISlice;

// Create the store by combining all slices
export const useRootStore = create<RootStore>()(
  devtools(
    persist(
      (set, get, store) => ({
        ...createUserSlice(set, get, store),
        ...createTaskSlice(set, get, store),
        ...createUISlice(set, get, store),
      }),
      {
        name: 'taskflow-storage', // Storage key
        partialize: (state) => ({
          // Only persist these fields
          user: state.user,
          isAuthenticated: state.isAuthenticated,
          theme: state.theme,
          sidebarCollapsed: state.sidebarCollapsed,
          // Don't persist: tasks, loading states, errors, etc.
        }),
      }
    ),
    {
      name: 'TaskFlow App', // Name in Redux DevTools
      enabled: process.env.NODE_ENV === 'development',
    }
  )
);

// Export individual slices for selective imports
export { useRootStore as useStore };

// Convenience hooks for specific slices
export const useUserStore = () => {
  const user = useRootStore((state) => state.user);
  const login = useRootStore((state) => state.login);
  const logout = useRootStore((state) => state.logout);
  const updateUser = useRootStore((state) => state.updateUser);
  const updatePreferences = useRootStore((state) => state.updatePreferences);
  const isAuthenticated = useRootStore((state) => state.isAuthenticated);
  const authLoading = useRootStore((state) => state.authLoading);
  const authError = useRootStore((state) => state.authError);
  
  return {
    user,
    login,
    logout,
    updateUser,
    updatePreferences,
    isAuthenticated,
    authLoading,
    authError,
  };
};

export const useTaskStore = () => {
  const tasks = useRootStore((state) => state.tasks);
  const taskIds = useRootStore((state) => state.taskIds);
  const filters = useRootStore((state) => state.filters);
  const sort = useRootStore((state) => state.sort);
  const selectedTaskId = useRootStore((state) => state.selectedTaskId);
  const fetchTasks = useRootStore((state) => state.fetchTasks);
  const fetchTask = useRootStore((state) => state.fetchTask);
  const createTask = useRootStore((state) => state.createTask);
  const updateTask = useRootStore((state) => state.updateTask);
  const deleteTask = useRootStore((state) => state.deleteTask);
  const toggleTaskComplete = useRootStore((state) => state.toggleTaskComplete);
  const setFilters = useRootStore((state) => state.setFilters);
  const setSort = useRootStore((state) => state.setSort);
  const selectTask = useRootStore((state) => state.selectTask);
  const getFilteredTasks = useRootStore((state) => state.getFilteredTasks);
  const getTaskStats = useRootStore((state) => state.getTaskStats);
  const getTaskById = useRootStore((state) => state.getTaskById);
  const taskListLoading = useRootStore((state) => state.taskListLoading);
  const taskListError = useRootStore((state) => state.taskListError);
  
  return {
    tasks,
    taskIds,
    filters,
    sort,
    selectedTaskId,
    fetchTasks,
    fetchTask,
    createTask,
    updateTask,
    deleteTask,
    toggleTaskComplete,
    setFilters,
    setSort,
    selectTask,
    getFilteredTasks,
    getTaskStats,
    getTaskById,
    taskListLoading,
    taskListError,
  };
};

export const useUIStore = () => {
  const theme = useRootStore((state) => state.theme);
  const sidebarOpen = useRootStore((state) => state.sidebarOpen);
  const sidebarCollapsed = useRootStore((state) => state.sidebarCollapsed);
  const modalOpen = useRootStore((state) => state.modalOpen);
  const toastMessages = useRootStore((state) => state.toastMessages);
  const isLoading = useRootStore((state) => state.isLoading);
  const setTheme = useRootStore((state) => state.setTheme);
  const toggleSidebar = useRootStore((state) => state.toggleSidebar);
  const setSidebarCollapsed = useRootStore((state) => state.setSidebarCollapsed);
  const openModal = useRootStore((state) => state.openModal);
  const closeModal = useRootStore((state) => state.closeModal);
  const toggleModal = useRootStore((state) => state.toggleModal);
  const addToast = useRootStore((state) => state.addToast);
  const removeToast = useRootStore((state) => state.removeToast);
  const setLoading = useRootStore((state) => state.setLoading);
  
  return {
    theme,
    sidebarOpen,
    sidebarCollapsed,
    modalOpen,
    toastMessages,
    isLoading,
    setTheme,
    toggleSidebar,
    setSidebarCollapsed,
    openModal,
    closeModal,
    toggleModal,
    addToast,
    removeToast,
    setLoading,
  };
};

// Re-export types
export type { User } from './types/user.types';
export type { Task, TaskFilters, TaskSort } from './types/task.types';
export type { ToastMessage } from './slices/uiSlice';
```

---

## The Verification: Testing the Modular Architecture

### Step 1: Create a Test Component

```tsx
// src/App.tsx
import React, { useEffect } from 'react';
import { useRootStore, useUserStore, useTaskStore, useUIStore } from './store';

function App() {
  const { isAuthenticated, login, logout, user } = useUserStore();
  const { fetchTasks, getFilteredTasks, getTaskStats, taskListLoading } = useTaskStore();
  const { theme, setTheme, addToast } = useUIStore();
  
  const tasks = getFilteredTasks();
  const stats = getTaskStats();

  useEffect(() => {
    if (isAuthenticated) {
      fetchTasks();
    }
  }, [isAuthenticated]);

  const handleLogin = async () => {
    try {
      await login('test@example.com', 'password');
      addToast({
        type: 'success',
        message: 'Logged in successfully!',
      });
    } catch (error) {
      addToast({
        type: 'error',
        message: 'Login failed',
      });
    }
  };

  return (
    <div style={{ padding: '20px' }}>
      <h1>TaskFlow Dashboard</h1>
      
      <div style={{ marginBottom: '20px' }}>
        <button onClick={handleLogin}>Login</button>
        <button onClick={logout} style={{ marginLeft: '10px' }}>Logout</button>
        <button onClick={() => setTheme(theme === 'dark' ? 'light' : 'dark')}>
          Toggle Theme ({theme})
        </button>
      </div>
      
      {isAuthenticated ? (
        <>
          <div>Welcome, {user?.name}</div>
          <div style={{ marginTop: '20px' }}>
            <strong>Stats:</strong>
            <ul>
              <li>Total: {stats.total}</li>
              <li>Completed: {stats.completed}</li>
              <li>Active: {stats.active}</li>
            </ul>
          </div>
          <div>
            <strong>Tasks ({tasks.length}):</strong>
            {taskListLoading ? (
              <div>Loading...</div>
            ) : (
              <ul>
                {tasks.slice(0, 10).map(task => (
                  <li key={task.id}>
                    {task.title} - {task.priority} - {task.completed ? '✅' : '⬜'}
                  </li>
                ))}
              </ul>
            )}
          </div>
        </>
      ) : (
        <div>Please login to view your tasks</div>
      )}
    </div>
  );
}

export default App;
```

### Step 2: Verify in Browser

1. Start the dev server
2. Open console to see logs
3. Click "Login" - should see tasks load
4. Click "Toggle Theme" - should see theme change
5. Check Redux DevTools (if installed) - should see all actions

### Step 3: Performance Test

Create a performance test to verify the modular architecture:

```tsx
// src/tests/PerformanceTest.tsx
import { useRootStore } from '../store';

function PerformanceTest() {
  const renderCount = React.useRef(0);
  renderCount.current++;
  
  // Different components subscribe to different slices
  const user = useRootStore((state) => state.user);
  const tasks = useRootStore((state) => state.tasks);
  const theme = useRootStore((state) => state.theme);
  
  // This component only re-renders when any of these change
  // But other components only re-render when their specific state changes
  
  return (
    <div>
      <div>Renders: {renderCount.current}</div>
      <div>User: {user?.name}</div>
      <div>Tasks: {Object.keys(tasks).length}</div>
      <div>Theme: {theme}</div>
    </div>
  );
}
```

---

## Best Practices for Large Applications

### 1. Keep Slices Focused
Each slice should handle one domain. If a slice is growing too large, consider splitting it further.

### 2. Use Selectors for Complex Queries
```typescript
// ❌ Bad: Complex logic in component
const tasks = useRootStore((state) => 
  Object.values(state.tasks)
    .filter(t => !t.completed)
    .sort((a, b) => a.priority - b.priority)
);

// ✅ Good: Selector in the store
const activeTasks = useRootStore((state) => 
  state.getFilteredTasks()
);
```

### 3. Avoid Cross-Slice Dependencies
When slices need to communicate, use the store's `get` function, but keep it minimal:

```typescript
// In task slice
createTask: async (data) => {
  const user = get().user; // ✅ Get current user
  // Use user data...
}
```

### 4. Use TypeScript for Type Safety
Always define proper types for your slices and the root store.

### 5. Persist Only What's Necessary
```typescript
persist(
  (set, get) => ({ /* store */ }),
  {
    partialize: (state) => ({
      user: state.user,
      preferences: state.preferences,
      // Don't persist: tasks, loading states, etc.
    }),
  }
)
```

---

## Common Pitfalls and Solutions

### Pitfall 1: Slices Getting Too Large
- **Solution**: Break large slices into smaller sub-slices
- **Example**: Split `taskSlice` into `taskCrudSlice`, `taskFilterSlice`, `taskCommentsSlice`

### Pitfall 2: Circular Dependencies
- **Solution**: Use the store's `get` function instead of direct imports
- **Example**: Instead of importing another slice, use `get().otherSliceMethod()`

### Pitfall 3: Over-Persistence
- **Solution**: Use `partialize` to only persist what's needed
- **Why**: Persisting too much can lead to storage size issues and hydration mismatches

### Pitfall 4: Mixed Concerns
- **Solution**: Keep UI state separate from domain state
- **Example**: Don't put `isModalOpen` in the same slice as `tasks`

---

## Key Takeaways

1. **Use the slice pattern**: Break stores into focused, independent modules
2. **Organize by domain**: Each slice should represent a business domain
3. **Combine with `create`**: Use Zustand's `create` to combine slices
4. **Use TypeScript**: Define strict types for all slices and the root store
5. **Persist selectively**: Only persist what's necessary
6. **Use DevTools**: Enable Redux DevTools for debugging
7. **Keep slices small**: If a slice is too large, split it further
8. **Avoid circular dependencies**: Use `get()` for cross-slice communication
9. **Create convenience hooks**: Make it easy to access specific slices
10. **Test slices independently**: Each slice should be testable in isolation

---

## What's Next

Now that you've mastered structuring large applications with slices, it's time to explore middleware. In the next section, you'll learn how to extend Zustand's capabilities with built-in and custom middleware.
