# Part 2: State Management & Local Persistence
## Phase 2: Global State Management with Zustand

Welcome to global state management! As your app grows, you'll need to share state across many components—user authentication, theme preferences, task data, and more. Zustand provides a simple, scalable solution that's perfect for React Native. Think of it as a central nervous system for your app's data.

---

## Target 1: Understanding Zustand

**The Target:** Master Zustand's architecture and core concepts.

**The Concept:** Zustand (German for "state") is a small, fast, and scalable state management library. Unlike Redux, it requires minimal boilerplate and feels natural to use. Think of it as a global React hook that any component can access.

### Installation

```bash
# Install Zustand
npm install zustand

# For persistence (we'll use this later)
npm install zustand-middleware
```

### Zustand vs Other Solutions

| Feature | Zustand | Redux | Context |
|---------|---------|-------|---------|
| **Boilerplate** | Minimal | Heavy | Moderate |
| **Learning Curve** | Low | Steep | Moderate |
| **Performance** | Excellent | Good | Good (with memo) |
| **DevTools** | Yes | Excellent | Limited |
| **Middleware** | Yes | Extensive | Limited |
| **TypeScript** | Excellent | Good | Good |

### Basic Store Creation

```typescript
// src/stores/counterStore.ts
import { create } from 'zustand';

interface CounterState {
  count: number;
  increment: () => void;
  decrement: () => void;
  reset: () => void;
  incrementBy: (value: number) => void;
}

/**
 * CounterStore - Simple Zustand store example
 * 
 * This demonstrates the basic structure of a Zustand store:
 * - State definition
 * - Actions that modify state
 * - Type-safe implementation
 */
export const useCounterStore = create<CounterState>((set) => ({
  // Initial state
  count: 0,

  // Actions
  increment: () => set((state) => ({ count: state.count + 1 })),
  
  decrement: () => set((state) => ({ count: state.count - 1 })),
  
  reset: () => set({ count: 0 }),
  
  incrementBy: (value: number) => 
    set((state) => ({ count: state.count + value })),
}));
```

### Using the Store in Components

```typescript
// src/examples/ZustandBasics.tsx
import React from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  StyleSheet,
  ScrollView,
  Platform,
} from 'react-native';
import { useCounterStore } from '../stores/counterStore';

export const ZustandBasics: React.FC = () => {
  // Select specific state and actions
  const count = useCounterStore((state) => state.count);
  const increment = useCounterStore((state) => state.increment);
  const decrement = useCounterStore((state) => state.decrement);
  const reset = useCounterStore((state) => state.reset);
  const incrementBy = useCounterStore((state) => state.incrementBy);

  // Alternatively, you can get everything at once
  // const { count, increment, decrement, reset, incrementBy } = useCounterStore();

  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.content}>
      <Text style={styles.title}>Zustand Counter Example</Text>

      <View style={styles.counterCard}>
        <Text style={styles.countLabel}>Current Count</Text>
        <Text style={styles.countValue}>{count}</Text>

        <View style={styles.buttonGrid}>
          <TouchableOpacity style={[styles.button, styles.decrementButton]} onPress={decrement}>
            <Text style={styles.buttonText}>-1</Text>
          </TouchableOpacity>

          <TouchableOpacity style={[styles.button, styles.resetButton]} onPress={reset}>
            <Text style={styles.buttonText}>Reset</Text>
          </TouchableOpacity>

          <TouchableOpacity style={[styles.button, styles.incrementButton]} onPress={increment}>
            <Text style={styles.buttonText}>+1</Text>
          </TouchableOpacity>
        </View>

        <View style={styles.buttonRow}>
          <TouchableOpacity 
            style={[styles.button, styles.incrementByButton]} 
            onPress={() => incrementBy(5)}
          >
            <Text style={styles.buttonText}>+5</Text>
          </TouchableOpacity>

          <TouchableOpacity 
            style={[styles.button, styles.incrementByButton]} 
            onPress={() => incrementBy(10)}
          >
            <Text style={styles.buttonText}>+10</Text>
          </TouchableOpacity>
        </View>
      </View>

      <View style={styles.infoCard}>
        <Text style={styles.infoTitle}>Why Zustand?</Text>
        <Text style={styles.infoText}>✅ Simple API with minimal boilerplate</Text>
        <Text style={styles.infoText}>✅ No providers or wrappers needed</Text>
        <Text style={styles.infoText}>✅ TypeScript support out of the box</Text>
        <Text style={styles.infoText}>✅ Performance optimized</Text>
        <Text style={styles.infoText}>✅ Works great with React Native</Text>
      </View>
    </ScrollView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f8f9fa',
  },
  content: {
    padding: 16,
    paddingBottom: 40,
  },
  title: {
    fontSize: 28,
    fontWeight: 'bold',
    color: '#2c3e50',
    marginBottom: 24,
    textAlign: 'center',
  },
  counterCard: {
    backgroundColor: '#ffffff',
    borderRadius: 12,
    padding: 24,
    alignItems: 'center',
    marginBottom: 16,
    ...Platform.select({
      ios: {
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 2 },
        shadowOpacity: 0.1,
        shadowRadius: 8,
      },
      android: {
        elevation: 4,
      },
    }),
  },
  countLabel: {
    fontSize: 14,
    color: '#7f8c8d',
    marginBottom: 8,
  },
  countValue: {
    fontSize: 48,
    fontWeight: 'bold',
    color: '#2c3e50',
    marginBottom: 20,
  },
  buttonGrid: {
    flexDirection: 'row',
    gap: 8,
    width: '100%',
    marginBottom: 8,
  },
  buttonRow: {
    flexDirection: 'row',
    gap: 8,
    width: '100%',
  },
  button: {
    flex: 1,
    paddingVertical: 12,
    borderRadius: 8,
    alignItems: 'center',
  },
  incrementButton: {
    backgroundColor: '#2ecc71',
  },
  decrementButton: {
    backgroundColor: '#e74c3c',
  },
  resetButton: {
    backgroundColor: '#95a5a6',
  },
  incrementByButton: {
    backgroundColor: '#3498db',
  },
  buttonText: {
    color: '#ffffff',
    fontSize: 16,
    fontWeight: '600',
  },
  infoCard: {
    backgroundColor: '#ffffff',
    borderRadius: 12,
    padding: 16,
    ...Platform.select({
      ios: {
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 2 },
        shadowOpacity: 0.05,
        shadowRadius: 4,
      },
      android: {
        elevation: 2,
      },
    }),
  },
  infoTitle: {
    fontSize: 16,
    fontWeight: '600',
    color: '#2c3e50',
    marginBottom: 8,
  },
  infoText: {
    fontSize: 14,
    color: '#34495e',
    paddingVertical: 4,
  },
});
```

---

## Target 2: Building the Auth Store

**The Target:** Create a complete authentication store with async actions.

**The Concept:** Authentication is one of the most common global state needs. The auth store manages user data, tokens, and authentication status across your entire app.

### Complete Auth Store

```typescript
// src/stores/authStore.ts
import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';
import AsyncStorage from '@react-native-async-storage/async-storage';

// Types
interface User {
  id: string;
  name: string;
  email: string;
  avatar?: string;
  createdAt: string;
}

interface AuthState {
  // State
  user: User | null;
  token: string | null;
  isLoading: boolean;
  isAuthenticated: boolean;
  error: string | null;
  
  // Actions
  login: (email: string, password: string) => Promise<void>;
  register: (name: string, email: string, password: string) => Promise<void>;
  logout: () => void;
  updateUser: (userData: Partial<User>) => void;
  clearError: () => void;
  checkAuth: () => Promise<void>;
}

// Mock API functions (replace with real API calls)
const mockApi = {
  login: async (email: string, password: string): Promise<{ user: User; token: string }> => {
    // Simulate API delay
    await new Promise(resolve => setTimeout(resolve, 1000));
    
    // Mock validation
    if (email === 'demo@example.com' && password === 'password') {
      return {
        user: {
          id: '1',
          name: 'Demo User',
          email: 'demo@example.com',
          avatar: 'https://ui-avatars.com/api/?name=Demo+User&background=3498db&color=fff&size=128',
          createdAt: new Date().toISOString(),
        },
        token: 'mock-jwt-token-12345',
      };
    }
    
    throw new Error('Invalid email or password');
  },
  
  register: async (name: string, email: string, password: string): Promise<{ user: User; token: string }> => {
    await new Promise(resolve => setTimeout(resolve, 1000));
    
    // Mock registration
    return {
      user: {
        id: '1',
        name,
        email,
        avatar: `https://ui-avatars.com/api/?name=${encodeURIComponent(name)}&background=3498db&color=fff&size=128`,
        createdAt: new Date().toISOString(),
      },
      token: 'mock-jwt-token-67890',
    };
  },
  
  validateToken: async (token: string): Promise<User> => {
    await new Promise(resolve => setTimeout(resolve, 500));
    
    // Mock token validation
    if (token === 'mock-jwt-token-12345') {
      return {
        id: '1',
        name: 'Demo User',
        email: 'demo@example.com',
        avatar: 'https://ui-avatars.com/api/?name=Demo+User&background=3498db&color=fff&size=128',
        createdAt: new Date().toISOString(),
      };
    }
    
    throw new Error('Invalid token');
  },
};

/**
 * AuthStore - Complete authentication state management
 * 
 * This store handles user authentication with persistent storage,
 * async actions, and comprehensive error handling.
 */
export const useAuthStore = create<AuthState>()(
  persist(
    (set, get) => ({
      // Initial state
      user: null,
      token: null,
      isLoading: false,
      isAuthenticated: false,
      error: null,

      // Login action
      login: async (email: string, password: string) => {
        set({ isLoading: true, error: null });
        
        try {
          // Basic validation
          if (!email.trim() || !password.trim()) {
            throw new Error('Email and password are required');
          }
          
          if (!email.includes('@')) {
            throw new Error('Please enter a valid email address');
          }
          
          if (password.length < 6) {
            throw new Error('Password must be at least 6 characters');
          }
          
          // Call API
          const { user, token } = await mockApi.login(email, password);
          
          // Update store
          set({
            user,
            token,
            isAuthenticated: true,
            isLoading: false,
            error: null,
          });
          
        } catch (error) {
          set({
            isLoading: false,
            error: error instanceof Error ? error.message : 'Login failed',
            isAuthenticated: false,
          });
          throw error;
        }
      },

      // Register action
      register: async (name: string, email: string, password: string) => {
        set({ isLoading: true, error: null });
        
        try {
          // Basic validation
          if (!name.trim() || !email.trim() || !password.trim()) {
            throw new Error('All fields are required');
          }
          
          if (name.length < 2) {
            throw new Error('Name must be at least 2 characters');
          }
          
          if (!email.includes('@')) {
            throw new Error('Please enter a valid email address');
          }
          
          if (password.length < 6) {
            throw new Error('Password must be at least 6 characters');
          }
          
          // Call API
          const { user, token } = await mockApi.register(name, email, password);
          
          // Update store
          set({
            user,
            token,
            isAuthenticated: true,
            isLoading: false,
            error: null,
          });
          
        } catch (error) {
          set({
            isLoading: false,
            error: error instanceof Error ? error.message : 'Registration failed',
            isAuthenticated: false,
          });
          throw error;
        }
      },

      // Logout action
      logout: () => {
        set({
          user: null,
          token: null,
          isAuthenticated: false,
          isLoading: false,
          error: null,
        });
        
        // Clear any stored data (optional)
        // AsyncStorage.removeItem('auth-storage');
      },

      // Update user data
      updateUser: (userData: Partial<User>) => {
        const { user } = get();
        if (user) {
          set({ user: { ...user, ...userData } });
        }
      },

      // Clear error
      clearError: () => {
        set({ error: null });
      },

      // Check authentication status on app startup
      checkAuth: async () => {
        const { token } = get();
        
        if (!token) {
          set({ isAuthenticated: false });
          return;
        }
        
        try {
          set({ isLoading: true });
          const user = await mockApi.validateToken(token);
          set({
            user,
            isAuthenticated: true,
            isLoading: false,
            error: null,
          });
        } catch (error) {
          set({
            user: null,
            token: null,
            isAuthenticated: false,
            isLoading: false,
            error: 'Session expired. Please login again.',
          });
        }
      },
    }),
    {
      name: 'auth-storage', // Unique name for AsyncStorage
      storage: createJSONStorage(() => AsyncStorage),
      // Only persist these fields
      partialize: (state) => ({
        user: state.user,
        token: state.token,
        isAuthenticated: state.isAuthenticated,
      }),
    }
  )
);

// Selectors for convenience
export const selectUser = (state: AuthState) => state.user;
export const selectIsAuthenticated = (state: AuthState) => state.isAuthenticated;
export const selectAuthLoading = (state: AuthState) => state.isLoading;
export const selectAuthError = (state: AuthState) => state.error;
```

---

## Target 3: Building the Task Store

**The Target:** Create a complete task management store with CRUD operations.

**The Concept:** The task store manages all task-related data, including fetching, creating, updating, and deleting tasks with proper loading states and error handling.

### Complete Task Store

```typescript
// src/stores/taskStore.ts
import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';
import AsyncStorage from '@react-native-async-storage/async-storage';

// Types
export interface Task {
  id: string;
  title: string;
  description: string;
  priority: 'low' | 'medium' | 'high';
  status: 'todo' | 'in-progress' | 'done';
  dueDate: string;
  category: string;
  assignedTo?: string;
  createdAt: string;
  updatedAt: string;
}

interface TaskFilters {
  search: string;
  priority?: 'low' | 'medium' | 'high';
  status?: 'todo' | 'in-progress' | 'done';
  category?: string;
  assignedTo?: string;
  fromDate?: string;
  toDate?: string;
}

interface TaskState {
  // State
  tasks: Task[];
  selectedTask: Task | null;
  filters: TaskFilters;
  isLoading: boolean;
  isCreating: boolean;
  isUpdating: boolean;
  isDeleting: boolean;
  error: string | null;
  lastSync: string | null;
  
  // Actions
  fetchTasks: () => Promise<void>;
  getTask: (id: string) => Task | undefined;
  createTask: (taskData: Omit<Task, 'id' | 'createdAt' | 'updatedAt'>) => Promise<Task>;
  updateTask: (id: string, taskData: Partial<Task>) => Promise<Task>;
  deleteTask: (id: string) => Promise<void>;
  setFilters: (filters: Partial<TaskFilters>) => void;
  clearFilters: () => void;
  selectTask: (task: Task | null) => void;
  clearError: () => void;
  getFilteredTasks: () => Task[];
  getTasksByStatus: (status: Task['status']) => Task[];
  getTaskCount: () => { total: number; todo: number; inProgress: number; done: number };
}

// Mock data
const initialTasks: Task[] = [
  {
    id: '1',
    title: 'Complete project proposal',
    description: 'Write and submit the Q2 project proposal',
    priority: 'high',
    status: 'todo',
    dueDate: '2026-08-15',
    category: 'Work',
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
  },
  {
    id: '2',
    title: 'Team meeting preparation',
    description: 'Prepare agenda and slides for weekly team meeting',
    priority: 'medium',
    status: 'in-progress',
    dueDate: '2026-08-16',
    category: 'Work',
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
  },
  {
    id: '3',
    title: 'Review design mockups',
    description: 'Review and provide feedback on new UI designs',
    priority: 'low',
    status: 'done',
    dueDate: '2026-08-10',
    category: 'Design',
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
  },
];

// Mock API
const mockTaskApi = {
  fetchTasks: async (): Promise<Task[]> => {
    await new Promise(resolve => setTimeout(resolve, 800));
    return [...initialTasks];
  },
  
  createTask: async (taskData: any): Promise<Task> => {
    await new Promise(resolve => setTimeout(resolve, 600));
    const newTask: Task = {
      id: `${Date.now()}`,
      ...taskData,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    };
    return newTask;
  },
  
  updateTask: async (id: string, taskData: any): Promise<Task> => {
    await new Promise(resolve => setTimeout(resolve, 600));
    const existingTask = initialTasks.find(t => t.id === id);
    if (!existingTask) {
      throw new Error('Task not found');
    }
    return {
      ...existingTask,
      ...taskData,
      updatedAt: new Date().toISOString(),
    };
  },
  
  deleteTask: async (id: string): Promise<void> => {
    await new Promise(resolve => setTimeout(resolve, 500));
    // Check if task exists
    const existingTask = initialTasks.find(t => t.id === id);
    if (!existingTask) {
      throw new Error('Task not found');
    }
  },
};

/**
 * TaskStore - Complete task management store
 * 
 * This store handles all task-related operations with persistence,
 * filtering, and optimized selectors.
 */
export const useTaskStore = create<TaskState>()(
  persist(
    (set, get) => ({
      // Initial state
      tasks: [],
      selectedTask: null,
      filters: {
        search: '',
      },
      isLoading: false,
      isCreating: false,
      isUpdating: false,
      isDeleting: false,
      error: null,
      lastSync: null,

      // Fetch all tasks
      fetchTasks: async () => {
        set({ isLoading: true, error: null });
        
        try {
          const tasks = await mockTaskApi.fetchTasks();
          set({
            tasks,
            isLoading: false,
            lastSync: new Date().toISOString(),
          });
        } catch (error) {
          set({
            isLoading: false,
            error: error instanceof Error ? error.message : 'Failed to fetch tasks',
          });
        }
      },

      // Get a single task by ID
      getTask: (id: string) => {
        const { tasks } = get();
        return tasks.find(task => task.id === id);
      },

      // Create a new task
      createTask: async (taskData) => {
        set({ isCreating: true, error: null });
        
        try {
          const newTask = await mockTaskApi.createTask(taskData);
          
          set((state) => ({
            tasks: [newTask, ...state.tasks],
            isCreating: false,
            lastSync: new Date().toISOString(),
          }));
          
          return newTask;
        } catch (error) {
          set({
            isCreating: false,
            error: error instanceof Error ? error.message : 'Failed to create task',
          });
          throw error;
        }
      },

      // Update an existing task
      updateTask: async (id: string, taskData) => {
        set({ isUpdating: true, error: null });
        
        try {
          const updatedTask = await mockTaskApi.updateTask(id, taskData);
          
          set((state) => ({
            tasks: state.tasks.map(task => 
              task.id === id ? updatedTask : task
            ),
            selectedTask: state.selectedTask?.id === id ? updatedTask : state.selectedTask,
            isUpdating: false,
            lastSync: new Date().toISOString(),
          }));
          
          return updatedTask;
        } catch (error) {
          set({
            isUpdating: false,
            error: error instanceof Error ? error.message : 'Failed to update task',
          });
          throw error;
        }
      },

      // Delete a task
      deleteTask: async (id: string) => {
        set({ isDeleting: true, error: null });
        
        try {
          await mockTaskApi.deleteTask(id);
          
          set((state) => ({
            tasks: state.tasks.filter(task => task.id !== id),
            selectedTask: state.selectedTask?.id === id ? null : state.selectedTask,
            isDeleting: false,
            lastSync: new Date().toISOString(),
          }));
        } catch (error) {
          set({
            isDeleting: false,
            error: error instanceof Error ? error.message : 'Failed to delete task',
          });
          throw error;
        }
      },

      // Set filters
      setFilters: (filters) => {
        set((state) => ({
          filters: { ...state.filters, ...filters },
        }));
      },

      // Clear all filters
      clearFilters: () => {
        set({
          filters: { search: '' },
        });
      },

      // Select a task
      selectTask: (task) => {
        set({ selectedTask: task });
      },

      // Clear error
      clearError: () => {
        set({ error: null });
      },

      // Get filtered tasks (computed)
      getFilteredTasks: () => {
        const { tasks, filters } = get();
        
        let filtered = [...tasks];
        
        // Search filter
        if (filters.search) {
          const searchLower = filters.search.toLowerCase();
          filtered = filtered.filter(task =>
            task.title.toLowerCase().includes(searchLower) ||
            task.description.toLowerCase().includes(searchLower)
          );
        }
        
        // Priority filter
        if (filters.priority) {
          filtered = filtered.filter(task => task.priority === filters.priority);
        }
        
        // Status filter
        if (filters.status) {
          filtered = filtered.filter(task => task.status === filters.status);
        }
        
        // Category filter
        if (filters.category) {
          filtered = filtered.filter(task => 
            task.category.toLowerCase().includes(filters.category!.toLowerCase())
          );
        }
        
        // Date range filters
        if (filters.fromDate) {
          filtered = filtered.filter(task => 
            task.dueDate >= filters.fromDate!
          );
        }
        
        if (filters.toDate) {
          filtered = filtered.filter(task => 
            task.dueDate <= filters.toDate!
          );
        }
        
        // Sort by due date (closest first)
        filtered.sort((a, b) => a.dueDate.localeCompare(b.dueDate));
        
        return filtered;
      },

      // Get tasks by status
      getTasksByStatus: (status) => {
        const { tasks } = get();
        return tasks.filter(task => task.status === status);
      },

      // Get task statistics
      getTaskCount: () => {
        const { tasks } = get();
        const todo = tasks.filter(t => t.status === 'todo').length;
        const inProgress = tasks.filter(t => t.status === 'in-progress').length;
        const done = tasks.filter(t => t.status === 'done').length;
        
        return {
          total: tasks.length,
          todo,
          inProgress,
          done,
        };
      },
    }),
    {
      name: 'task-storage',
      storage: createJSONStorage(() => AsyncStorage),
      // Only persist tasks and filters
      partialize: (state) => ({
        tasks: state.tasks,
        filters: state.filters,
      }),
    }
  )
);

// Selectors
export const selectAllTasks = (state: TaskState) => state.tasks;
export const selectTaskById = (id: string) => (state: TaskState) => 
  state.tasks.find(task => task.id === id);
export const selectFilteredTasks = (state: TaskState) => state.getFilteredTasks();
export const selectTaskCount = (state: TaskState) => state.getTaskCount();
```

---

## Target 4: Building the UI Store

**The Target:** Create a store for UI state like theme, loading, and modals.

**The Concept:** UI state includes things that affect how the app looks and feels—theme preferences, modal visibility, loading indicators, and snackbar messages.

### UI Store

```typescript
// src/stores/uiStore.ts
import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';
import AsyncStorage from '@react-native-async-storage/async-storage';

interface Toast {
  id: string;
  message: string;
  type: 'success' | 'error' | 'warning' | 'info';
  duration?: number;
}

interface ModalState {
  visible: boolean;
  type: 'none' | 'taskForm' | 'taskFilter' | 'userSearch' | 'confirm';
  data?: any;
}

interface UIState {
  // Theme
  theme: 'light' | 'dark' | 'system';
  
  // Modals
  modal: ModalState;
  
  // Toasts/Snackbars
  toasts: Toast[];
  
  // Loading states
  globalLoading: boolean;
  
  // Network status
  isOnline: boolean;
  
  // Device info
  isTablet: boolean;
  orientation: 'portrait' | 'landscape';
  
  // Actions
  setTheme: (theme: 'light' | 'dark' | 'system') => void;
  toggleTheme: () => void;
  
  showModal: (type: ModalState['type'], data?: any) => void;
  hideModal: () => void;
  
  showToast: (message: string, type: Toast['type'], duration?: number) => void;
  hideToast: (id: string) => void;
  clearToasts: () => void;
  
  setGlobalLoading: (loading: boolean) => void;
  setOnlineStatus: (isOnline: boolean) => void;
  setDeviceInfo: (isTablet: boolean, orientation: 'portrait' | 'landscape') => void;
}

/**
 * UIStore - Manage UI state across the app
 * 
 * This store handles UI-related state that doesn't fit into other
 * specific stores like theme, modals, and toasts.
 */
export const useUIStore = create<UIState>()(
  persist(
    (set, get) => ({
      // Theme
      theme: 'system',
      
      // Modals
      modal: {
        visible: false,
        type: 'none',
      },
      
      // Toasts
      toasts: [],
      
      // Loading
      globalLoading: false,
      
      // Network
      isOnline: true,
      
      // Device
      isTablet: false,
      orientation: 'portrait',
      
      // Theme actions
      setTheme: (theme) => {
        set({ theme });
      },
      
      toggleTheme: () => {
        const { theme } = get();
        const newTheme = theme === 'light' ? 'dark' : 
                        theme === 'dark' ? 'system' : 'light';
        set({ theme: newTheme });
      },
      
      // Modal actions
      showModal: (type, data) => {
        set({
          modal: {
            visible: true,
            type,
            data,
          },
        });
      },
      
      hideModal: () => {
        set({
          modal: {
            visible: false,
            type: 'none',
          },
        });
      },
      
      // Toast actions
      showToast: (message, type, duration = 3000) => {
        const id = `toast-${Date.now()}`;
        const newToast: Toast = {
          id,
          message,
          type,
          duration,
        };
        
        set((state) => ({
          toasts: [...state.toasts, newToast],
        }));
        
        // Auto-remove toast after duration
        setTimeout(() => {
          get().hideToast(id);
        }, duration);
      },
      
      hideToast: (id) => {
        set((state) => ({
          toasts: state.toasts.filter(toast => toast.id !== id),
        }));
      },
      
      clearToasts: () => {
        set({ toasts: [] });
      },
      
      // Loading actions
      setGlobalLoading: (loading) => {
        set({ globalLoading: loading });
      },
      
      // Network actions
      setOnlineStatus: (isOnline) => {
        set({ isOnline });
      },
      
      // Device info
      setDeviceInfo: (isTablet, orientation) => {
        set({ isTablet, orientation });
      },
    }),
    {
      name: 'ui-storage',
      storage: createJSONStorage(() => AsyncStorage),
      partialize: (state) => ({
        theme: state.theme,
      }),
    }
  )
);

// Selectors
export const selectTheme = (state: UIState) => state.theme;
export const selectIsDarkMode = (state: UIState) => 
  state.theme === 'dark' || (state.theme === 'system' && false); // We'll detect system theme
export const selectModal = (state: UIState) => state.modal;
export const selectToasts = (state: UIState) => state.toasts;
```

---

## Target 5: Using Stores in Components

**The Target:** Demonstrate how to use Zustand stores effectively in components.

**The Concept:** Components subscribe to stores and react to changes. Zustand automatically handles re-rendering only when the selected state changes.

### Todo List with Zustand

```typescript
// src/screens/TasksScreenWithStore.tsx
import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  FlatList,
  TouchableOpacity,
  StyleSheet,
  ActivityIndicator,
  RefreshControl,
  Platform,
} from 'react-native';
import { useTaskStore } from '../stores/taskStore';
import { useAuthStore } from '../stores/authStore';
import { useUIStore } from '../stores/uiStore';
import { CustomStatusBar } from '../components/CustomStatusBar';
import { TaskForm } from '../components/TaskForm';
import { TaskCard } from '../components/TaskCard';

export const TasksScreenWithStore: React.FC = () => {
  // Select from stores
  const { 
    tasks, 
    isLoading, 
    error, 
    fetchTasks, 
    deleteTask,
    getFilteredTasks,
    getTaskCount,
    filters,
    setFilters,
    clearFilters,
  } = useTaskStore();
  
  const { user } = useAuthStore();
  const { showToast, showModal, hideModal, modal } = useUIStore();

  const [refreshing, setRefreshing] = useState(false);
  const filteredTasks = getFilteredTasks();
  const taskCount = getTaskCount();

  // Load tasks on mount
  useEffect(() => {
    fetchTasks();
  }, []);

  // Handle refresh
  const handleRefresh = async () => {
    setRefreshing(true);
    await fetchTasks();
    setRefreshing(false);
  };

  // Handle task deletion
  const handleDeleteTask = async (taskId: string) => {
    try {
      await deleteTask(taskId);
      showToast('Task deleted successfully', 'success');
    } catch (error) {
      showToast('Failed to delete task', 'error');
    }
  };

  // Handle task selection
  const handleTaskPress = (task: any) => {
    // Navigate to task detail
    console.log('Task pressed:', task);
  };

  // Render task item
  const renderTaskItem = ({ item }: { item: any }) => (
    <TaskCard
      task={item}
      onPress={() => handleTaskPress(item)}
      onDelete={() => handleDeleteTask(item.id)}
      onEdit={() => {
        // Show edit modal
        showModal('taskForm', { task: item, mode: 'edit' });
      }}
    />
  );

  // Render header
  const renderHeader = () => (
    <View style={styles.headerContainer}>
      <Text style={styles.welcomeText}>Welcome back, {user?.name || 'Guest'}!</Text>
      
      <View style={styles.statsContainer}>
        <View style={styles.statItem}>
          <Text style={styles.statValue}>{taskCount.todo}</Text>
          <Text style={styles.statLabel}>To Do</Text>
        </View>
        <View style={styles.statDivider} />
        <View style={styles.statItem}>
          <Text style={styles.statValue}>{taskCount.inProgress}</Text>
          <Text style={styles.statLabel}>In Progress</Text>
        </View>
        <View style={styles.statDivider} />
        <View style={styles.statItem}>
          <Text style={styles.statValue}>{taskCount.done}</Text>
          <Text style={styles.statLabel}>Done</Text>
        </View>
      </View>

      {/* Filter bar */}
      <View style={styles.filterContainer}>
        <TouchableOpacity
          style={[styles.filterButton, !filters.status && styles.filterButtonActive]}
          onPress={() => setFilters({ status: undefined })}
        >
          <Text style={styles.filterButtonText}>All</Text>
        </TouchableOpacity>
        <TouchableOpacity
          style={[styles.filterButton, filters.status === 'todo' && styles.filterButtonActive]}
          onPress={() => setFilters({ status: 'todo' })}
        >
          <Text style={styles.filterButtonText}>Todo</Text>
        </TouchableOpacity>
        <TouchableOpacity
          style={[styles.filterButton, filters.status === 'in-progress' && styles.filterButtonActive]}
          onPress={() => setFilters({ status: 'in-progress' })}
        >
          <Text style={styles.filterButtonText}>Progress</Text>
        </TouchableOpacity>
        <TouchableOpacity
          style={[styles.filterButton, filters.status === 'done' && styles.filterButtonActive]}
          onPress={() => setFilters({ status: 'done' })}
        >
          <Text style={styles.filterButtonText}>Done</Text>
        </TouchableOpacity>
      </View>
    </View>
  );

  if (isLoading && tasks.length === 0) {
    return (
      <View style={styles.loadingContainer}>
        <ActivityIndicator size="large" color="#3498db" />
        <Text style={styles.loadingText}>Loading tasks...</Text>
      </View>
    );
  }

  return (
    <View style={styles.container}>
      <CustomStatusBar 
        title="My Tasks"
        rightComponent={
          <TouchableOpacity onPress={() => showModal('taskForm', { mode: 'create' })}>
            <Text style={styles.addButton}>+</Text>
          </TouchableOpacity>
        }
      />

      <FlatList
        data={filteredTasks}
        renderItem={renderTaskItem}
        keyExtractor={item => item.id}
        ListHeaderComponent={renderHeader}
        ListEmptyComponent={
          <View style={styles.emptyContainer}>
            <Text style={styles.emptyEmoji}>📋</Text>
            <Text style={styles.emptyTitle}>No tasks found</Text>
            <Text style={styles.emptySubtitle}>
              Create a new task to get started
            </Text>
          </View>
        }
        refreshControl={
          <RefreshControl
            refreshing={refreshing}
            onRefresh={handleRefresh}
            colors={['#3498db']}
            tintColor="#3498db"
          />
        }
        contentContainerStyle={styles.listContent}
        showsVerticalScrollIndicator={false}
      />

      {/* Modal for task form */}
      {modal.visible && modal.type === 'taskForm' && (
        <View style={styles.modalOverlay}>
          <View style={styles.modalContent}>
            <TaskForm
              initialData={modal.data?.task}
              onSubmit={async (data) => {
                try {
                  // Handle create or update
                  hideModal();
                  showToast(
                    modal.data?.mode === 'edit' ? 'Task updated!' : 'Task created!',
                    'success'
                  );
                  await fetchTasks();
                } catch (error) {
                  showToast('Operation failed', 'error');
                }
              }}
              isLoading={false}
            />
            <TouchableOpacity style={styles.modalClose} onPress={hideModal}>
              <Text style={styles.modalCloseText}>✕</Text>
            </TouchableOpacity>
          </View>
        </View>
      )}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f8f9fa',
  },
  loadingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  loadingText: {
    fontSize: 16,
    color: '#7f8c8d',
    marginTop: 12,
  },
  listContent: {
    paddingBottom: 20,
  },
  headerContainer: {
    padding: 16,
    backgroundColor: '#ffffff',
    borderBottomWidth: 1,
    borderBottomColor: '#f0f0f0',
  },
  welcomeText: {
    fontSize: 18,
    fontWeight: '600',
    color: '#2c3e50',
    marginBottom: 12,
  },
  statsContainer: {
    flexDirection: 'row',
    backgroundColor: '#f8f9fa',
    borderRadius: 12,
    padding: 12,
    marginBottom: 12,
  },
  statItem: {
    flex: 1,
    alignItems: 'center',
  },
  statValue: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#2c3e50',
  },
  statLabel: {
    fontSize: 12,
    color: '#7f8c8d',
    marginTop: 2,
  },
  statDivider: {
    width: 1,
    backgroundColor: '#e1e8ed',
  },
  filterContainer: {
    flexDirection: 'row',
    gap: 8,
  },
  filterButton: {
    paddingHorizontal: 12,
    paddingVertical: 6,
    borderRadius: 20,
    backgroundColor: '#f1f2f6',
    borderWidth: 1,
    borderColor: 'transparent',
  },
  filterButtonActive: {
    backgroundColor: '#3498db',
    borderColor: '#3498db',
  },
  filterButtonText: {
    fontSize: 12,
    fontWeight: '500',
    color: '#2c3e50',
  },
  addButton: {
    fontSize: 28,
    color: '#3498db',
    fontWeight: '300',
    paddingHorizontal: 8,
  },
  emptyContainer: {
    alignItems: 'center',
    paddingVertical: 60,
  },
  emptyEmoji: {
    fontSize: 48,
    marginBottom: 16,
  },
  emptyTitle: {
    fontSize: 18,
    fontWeight: '600',
    color: '#2c3e50',
    marginBottom: 8,
  },
  emptySubtitle: {
    fontSize: 14,
    color: '#7f8c8d',
    textAlign: 'center',
  },
  modalOverlay: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    backgroundColor: 'rgba(0,0,0,0.5)',
    justifyContent: 'center',
    alignItems: 'center',
  },
  modalContent: {
    backgroundColor: '#ffffff',
    borderRadius: 16,
    padding: 20,
    width: '90%',
    maxHeight: '80%',
    ...Platform.select({
      ios: {
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 4 },
        shadowOpacity: 0.3,
        shadowRadius: 12,
      },
      android: {
        elevation: 8,
      },
    }),
  },
  modalClose: {
    position: 'absolute',
    top: 12,
    right: 12,
    padding: 8,
  },
  modalCloseText: {
    fontSize: 20,
    color: '#95a5a6',
  },
});
```

---

## Target 6: Store Middleware and Advanced Patterns

**The Target:** Implement middleware for logging, persistence, and development tools.

**The Concept:** Middleware sits between actions and state updates, allowing you to add cross-cutting concerns like logging, persistence, and debugging.

### Store with Middleware

```typescript
// src/stores/rootStore.ts
import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';
import { devtools } from 'zustand/middleware';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { useAuthStore } from './authStore';
import { useTaskStore } from './taskStore';

/**
 * RootStore - Combines all stores for easy access
 * 
 * This provides a unified interface to all stores in the app.
 * It's useful for cross-store actions and resetting the entire state.
 */
interface RootState {
  resetAll: () => void;
}

export const useRootStore = create<RootState>()(
  devtools(
    (set) => ({
      resetAll: () => {
        // Reset all stores
        useAuthStore.setState({
          user: null,
          token: null,
          isAuthenticated: false,
          isLoading: false,
          error: null,
        });
        
        useTaskStore.setState({
          tasks: [],
          selectedTask: null,
          isLoading: false,
          error: null,
        });
        
        // Clear all storage
        AsyncStorage.multiRemove(['auth-storage', 'task-storage', 'ui-storage']);
      },
    }),
    { name: 'RootStore' }
  )
);

// Logger middleware example
export const logger = (config: any) => (set: any, get: any, api: any) =>
  config(
    (args: any) => {
      console.log('🔄 State before update:', get());
      console.log('📝 Update with:', args);
      set(args);
      console.log('✅ State after update:', get());
    },
    get,
    api
  );

// Usage example with logger
// const useExampleStore = create(logger((set) => ({ ... })));
```

### Cross-Store Actions

```typescript
// src/stores/actions.ts
import { useAuthStore } from './authStore';
import { useTaskStore } from './taskStore';
import { useUIStore } from './uiStore';

/**
 * Cross-store actions that coordinate multiple stores
 * 
 * These actions demonstrate how to work with multiple stores
 * in a coordinated way.
 */
export const AppActions = {
  /**
   * Log out and clear all user data
   */
  logout: async () => {
    // Show loading
    useUIStore.getState().setGlobalLoading(true);
    
    try {
      // Clear auth state
      useAuthStore.getState().logout();
      
      // Clear task data (but not storage to preserve offline data)
      useTaskStore.setState({ 
        tasks: [],
        selectedTask: null,
      });
      
      // Show success message
      useUIStore.getState().showToast('Logged out successfully', 'success');
    } catch (error) {
      useUIStore.getState().showToast('Logout failed', 'error');
    } finally {
      useUIStore.getState().setGlobalLoading(false);
    }
  },

  /**
   * Sync all data (fetch tasks and user info)
   */
  syncAllData: async () => {
    useUIStore.getState().setGlobalLoading(true);
    
    try {
      // Check auth first
      const { isAuthenticated } = useAuthStore.getState();
      if (!isAuthenticated) {
        throw new Error('Not authenticated');
      }
      
      // Fetch tasks
      await useTaskStore.getState().fetchTasks();
      
      useUIStore.getState().showToast('Data synced successfully', 'success');
    } catch (error) {
      useUIStore.getState().showToast('Sync failed', 'error');
    } finally {
      useUIStore.getState().setGlobalLoading(false);
    }
  },

  /**
   * Complete a task (cross-store action)
   */
  completeTask: async (taskId: string) => {
    try {
      // Update task status
      await useTaskStore.getState().updateTask(taskId, { 
        status: 'done' 
      });
      
      // Show success
      useUIStore.getState().showToast('Task completed! 🎉', 'success');
      
      // Refresh tasks
      await useTaskStore.getState().fetchTasks();
    } catch (error) {
      useUIStore.getState().showToast('Failed to complete task', 'error');
    }
  },
};
```

---

## Target 7: Store Integration with Navigation

**The Target:** Use stores with React Navigation for authentication flows.

**The Concept:** Navigation often depends on authentication state. We'll create a navigation guard that checks authentication before allowing access to certain screens.

### Navigation Guard with Zustand

```typescript
// src/navigation/AuthGuard.tsx
import React, { useEffect } from 'react';
import { View, ActivityIndicator, StyleSheet } from 'react-native';
import { useAuthStore } from '../stores/authStore';
import { useNavigation } from '@react-navigation/native';

interface AuthGuardProps {
  children: React.ReactNode;
  fallback?: React.ReactNode;
}

/**
 * AuthGuard - Protects routes that require authentication
 * 
 * This component checks authentication status and redirects
 * to login if the user is not authenticated.
 */
export const AuthGuard: React.FC<AuthGuardProps> = ({ children, fallback }) => {
  const navigation = useNavigation();
  const { isAuthenticated, isLoading, checkAuth } = useAuthStore();

  useEffect(() => {
    // Check auth on mount
    checkAuth();
  }, []);

  useEffect(() => {
    // Redirect if not authenticated
    if (!isLoading && !isAuthenticated) {
      // @ts-ignore - Navigation type will be fixed later
      navigation.navigate('Login');
    }
  }, [isAuthenticated, isLoading, navigation]);

  // Show loading state
  if (isLoading) {
    return (
      <View style={styles.loadingContainer}>
        <ActivityIndicator size="large" color="#3498db" />
      </View>
    );
  }

  // Show fallback or children
  if (isAuthenticated) {
    return <>{children}</>;
  }

  return <>{fallback || null}</>;
};

const styles = StyleSheet.create({
  loadingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#ffffff',
  },
});
```

### App.tsx with Zustand Integration

```typescript
// App.tsx (Updated with Zustand integration)
import React, { useEffect } from 'react';
import { StatusBar } from 'expo-status-bar';
import { SafeAreaProvider } from 'react-native-safe-area-context';
import { NavigationContainer } from '@react-navigation/native';
import { Platform } from 'react-native';
import { AuthGuard } from './src/navigation/AuthGuard';
import { useAuthStore } from './src/stores/authStore';
import { useUIStore } from './src/stores/uiStore';
import { RootStackNavigator } from './src/navigation/RootStackNavigator';
import { SafeAreaWrapper } from './src/components/SafeAreaWrapper';
import { navigationService } from './src/navigation/NavigationService';

export default function App() {
  const { checkAuth } = useAuthStore();
  const { setOnlineStatus } = useUIStore();

  useEffect(() => {
    // Check authentication on startup
    checkAuth();

    // Set up network monitoring
    // In a real app, use NetInfo library
    setOnlineStatus(true);

    // Set up app state handling
    // Platform-specific setup
  }, []);

  return (
    <SafeAreaProvider>
      <NavigationContainer ref={navigationService.setTopLevelNavigator}>
        <SafeAreaWrapper>
          <AuthGuard>
            <RootStackNavigator />
          </AuthGuard>
        </SafeAreaWrapper>
        <StatusBar style={Platform.OS === 'ios' ? 'dark' : 'auto'} />
      </NavigationContainer>
    </SafeAreaProvider>
  );
}
```

---

## Target 8: Store Best Practices

**The Target:** Understand best practices for using Zustand in production apps.

**The Concept:** Like any tool, Zustand works best when used with certain patterns. These best practices ensure your app remains maintainable and performant as it grows.

### Best Practices Checklist

```typescript
// 1. Keep Stores Focused
// ❌ Bad - One giant store
// const useAppStore = create((set) => ({ 
//   user: null, tasks: [], settings: {}, ... 
// }));

// ✅ Good - Separate stores by domain
// const useAuthStore = create((set) => ({ ... }));
// const useTaskStore = create((set) => ({ ... }));
// const useSettingsStore = create((set) => ({ ... }));

// 2. Use Selectors for Performance
// ❌ Bad - Renders on any state change
// const { user, tasks, settings } = useStore();

// ✅ Good - Only re-renders when selected state changes
// const user = useStore(state => state.user);
// const tasks = useStore(state => state.tasks);

// 3. Prefer Multiple Small Actions
// ❌ Bad - One large action
// updateEverything: () => { /* updates many things */ }

// ✅ Good - Specific, focused actions
// updateUser: (user) => set({ user }),
// updateTasks: (tasks) => set({ tasks }),

// 4. Use TypeScript for Type Safety
// ✅ Always define interfaces for your stores

// 5. Handle Errors Gracefully
// ✅ Always use try/catch in async actions
// ✅ Set error state before throwing

// 6. Keep Actions Idempotent
// ✅ Actions should produce the same result given the same input

// 7. Use Middleware for Cross-Cutting Concerns
// ✅ Persistence
// ✅ Logging
// ✅ DevTools
// ✅ Analytics

// 8. Avoid Complex Computations in Stores
// ❌ compute expensive values in getters
// ✅ use selectors or useMemo in components

// 9. Reset State on Logout
// ✅ Create a reset function to clear all store data

// 10. Test Your Stores
// ✅ Write unit tests for your store actions
```

### Testing Stores

```typescript
// src/__tests__/stores/authStore.test.ts
import { useAuthStore } from '../../stores/authStore';

// Reset store before each test
beforeEach(() => {
  useAuthStore.setState({
    user: null,
    token: null,
    isAuthenticated: false,
    isLoading: false,
    error: null,
  });
});

describe('AuthStore', () => {
  it('should login successfully', async () => {
    const { login } = useAuthStore.getState();
    
    await login('demo@example.com', 'password');
    
    const state = useAuthStore.getState();
    expect(state.isAuthenticated).toBe(true);
    expect(state.user).not.toBeNull();
    expect(state.user?.email).toBe('demo@example.com');
    expect(state.error).toBeNull();
  });

  it('should fail login with invalid credentials', async () => {
    const { login } = useAuthStore.getState();
    
    try {
      await login('wrong@example.com', 'wrongpassword');
    } catch (error) {
      // Expected
    }
    
    const state = useAuthStore.getState();
    expect(state.isAuthenticated).toBe(false);
    expect(state.error).toBe('Invalid email or password');
  });

  it('should logout successfully', () => {
    const { login, logout } = useAuthStore.getState();
    
    // First login
    login('demo@example.com', 'password');
    
    // Then logout
    logout();
    
    const state = useAuthStore.getState();
    expect(state.isAuthenticated).toBe(false);
    expect(state.user).toBeNull();
    expect(state.token).toBeNull();
  });
});
```

---

## Verification: Test Zustand Integration

```bash
# Run the app
cd ~/projects/TaskFlow
expo start

# Test the following:
```

### Store Test Checklist

1. **Counter Store:**
   - [ ] Counter increments/decrements
   - [ ] State persists across component remounts

2. **Auth Store:**
   - [ ] Login with demo@example.com/password
   - [ ] Shows loading state during login
   - [ ] Stores user data and token
   - [ ] Persists auth state after app restart
   - [ ] Logout clears all auth data

3. **Task Store:**
   - [ ] Fetches tasks on component mount
   - [ ] Creates new tasks
   - [ ] Updates existing tasks
   - [ ] Deletes tasks
   - [ ] Filters tasks by status, priority, search
   - [ ] Persists tasks in AsyncStorage

4. **UI Store:**
   - [ ] Theme toggles between light/dark/system
   - [ ] Shows/hides modals
   - [ ] Displays toast notifications
   - [ ] Global loading indicator works

5. **Cross-Store Actions:**
   - [ ] Logout clears all stores
   - [ ] Sync updates all data
   - [ ] Task completion updates task and shows toast

6. **Navigation Guard:**
   - [ ] Protected routes redirect to login when unauthenticated
   - [ ] Authenticated users can access all routes

---

## What We've Accomplished

Congratulations! You've built a complete global state management system. Here's what you've achieved:

1. **Zustand Mastery:** Created stores for auth, tasks, and UI
2. **Persistence:** Data survives app restarts with AsyncStorage
3. **Middleware:** Added logging, devtools, and persistence
4. **Cross-Store Actions:** Coordinated multiple stores together
5. **Navigation Integration:** Protected routes with auth guards
6. **Best Practices:** Production-ready store patterns

### What's Next: Part 2, Phase 3 - Data Persistence

In the next phase, you'll learn:
- **AsyncStorage:** Key-value persistence
- **MMKV:** High-performance storage
- **SQLite:** Complex relational data
- **Offline-First:** Building apps that work without internet

*Your app now has a powerful state management system! Next, we'll make sure all that data survives app restarts and works offline. You'll learn multiple persistence strategies—from simple key-value storage to full SQLite databases. Your app is becoming truly production-ready!*
