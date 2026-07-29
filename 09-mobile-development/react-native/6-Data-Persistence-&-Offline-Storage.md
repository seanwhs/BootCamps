# Part 2: State Management & Local Persistence
## Phase 3: Data Persistence & Offline Storage

Welcome to the final phase of Part 2! Your app now has a robust state management system, but that data disappears when the app closes. In this phase, we'll implement multiple persistence strategies—from simple key-value storage to high-performance MMKV and full SQLite databases. Your TaskFlow app will become truly offline-first!

---

## Target 1: Understanding Persistence Options

**The Target:** Choose the right persistence strategy for different use cases.

**The Concept:** Think of data persistence like different types of filing systems. AsyncStorage is like a filing cabinet with labeled folders (great for small, simple data). MMKV is like a high-speed electronic filing system (perfect for performance-critical data). SQLite is like a full database management system (ideal for complex relational data).

### Persistence Options Comparison

| Feature | AsyncStorage | MMKV | SQLite | Realm |
|---------|--------------|------|--------|-------|
| **Speed** | Slow (async) | Very Fast | Moderate | Very Fast |
| **Data Type** | Key-Value | Key-Value | Relational | Object |
| **Query Support** | None | None | Full SQL | Query Language |
| **Complex Data** | JSON strings | Binary/JSON | Structured | Native Objects |
| **Sync** | Manual | Manual | Manual | Built-in |
| **Size Limit** | ~6MB | ~2GB | ~2GB | ~2GB |
| **Use Case** | Settings, Tokens | Large data, Caches | Complex data | Complex data |
| **Installation** | Built-in | Third-party | Third-party | Third-party |

### Installation

```bash
# Install AsyncStorage (already included with Expo)
npx expo install @react-native-async-storage/async-storage

# Install MMKV for high-performance storage
npx expo install react-native-mmkv

# Install SQLite for complex data
npx expo install expo-sqlite

# Install encryption (optional)
npx expo install expo-secure-store
```

---

## Target 2: AsyncStorage - Simple Key-Value Persistence

**The Target:** Master AsyncStorage for storing simple data like settings and tokens.

**The Concept:** AsyncStorage is React Native's built-in key-value storage. It's perfect for small amounts of data—user preferences, authentication tokens, and simple app state.

### AsyncStorage Utility

```typescript
// src/utils/asyncStorage.ts
import AsyncStorage from '@react-native-async-storage/async-storage';

/**
 * AsyncStorage utility with error handling and type safety
 */
export const StorageService = {
  /**
   * Store a value with automatic JSON serialization
   */
  setItem: async <T>(key: string, value: T): Promise<void> => {
    try {
      const jsonValue = JSON.stringify(value);
      await AsyncStorage.setItem(key, jsonValue);
    } catch (error) {
      console.error(`Error storing ${key}:`, error);
      throw new Error(`Failed to store ${key}`);
    }
  },

  /**
   * Retrieve a value with automatic JSON parsing
   */
  getItem: async <T>(key: string, defaultValue?: T): Promise<T | null> => {
    try {
      const jsonValue = await AsyncStorage.getItem(key);
      if (jsonValue === null) {
        return defaultValue || null;
      }
      return JSON.parse(jsonValue);
    } catch (error) {
      console.error(`Error retrieving ${key}:`, error);
      return defaultValue || null;
    }
  },

  /**
   * Remove a value
   */
  removeItem: async (key: string): Promise<void> => {
    try {
      await AsyncStorage.removeItem(key);
    } catch (error) {
      console.error(`Error removing ${key}:`, error);
      throw new Error(`Failed to remove ${key}`);
    }
  },

  /**
   * Get all keys
   */
  getAllKeys: async (): Promise<string[]> => {
    try {
      return await AsyncStorage.getAllKeys();
    } catch (error) {
      console.error('Error getting keys:', error);
      return [];
    }
  },

  /**
   * Get multiple items
   */
  multiGet: async <T>(keys: string[]): Promise<Record<string, T>> => {
    try {
      const pairs = await AsyncStorage.multiGet(keys);
      const result: Record<string, T> = {};
      pairs.forEach(([key, value]) => {
        if (value !== null) {
          result[key] = JSON.parse(value);
        }
      });
      return result;
    } catch (error) {
      console.error('Error multi-get:', error);
      return {};
    }
  },

  /**
   * Set multiple items
   */
  multiSet: async (items: Record<string, any>): Promise<void> => {
    try {
      const pairs = Object.entries(items).map(([key, value]) => [
        key,
        JSON.stringify(value),
      ]);
      await AsyncStorage.multiSet(pairs);
    } catch (error) {
      console.error('Error multi-set:', error);
      throw new Error('Failed to set multiple items');
    }
  },

  /**
   * Clear all storage
   */
  clearAll: async (): Promise<void> => {
    try {
      await AsyncStorage.clear();
    } catch (error) {
      console.error('Error clearing storage:', error);
      throw new Error('Failed to clear storage');
    }
  },
};

// Specific storage keys
export const StorageKeys = {
  AUTH_TOKEN: '@TaskFlow/authToken',
  USER_DATA: '@TaskFlow/userData',
  THEME_PREFERENCE: '@TaskFlow/themePreference',
  TASKS_CACHE: '@TaskFlow/tasksCache',
  APP_SETTINGS: '@TaskFlow/appSettings',
  ONBOARDING_COMPLETED: '@TaskFlow/onboardingCompleted',
} as const;
```

### Using AsyncStorage in Stores

```typescript
// src/stores/settingsStore.ts
import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';
import AsyncStorage from '@react-native-async-storage/async-storage';

interface SettingsState {
  notifications: boolean;
  soundEnabled: boolean;
  vibrationEnabled: boolean;
  defaultView: 'list' | 'grid';
  sorting: 'dueDate' | 'priority' | 'createdAt';
  fontSize: 'small' | 'medium' | 'large';
  
  // Actions
  updateSettings: (settings: Partial<SettingsState>) => void;
  resetSettings: () => void;
}

const defaultSettings: Omit<SettingsState, 'updateSettings' | 'resetSettings'> = {
  notifications: true,
  soundEnabled: true,
  vibrationEnabled: true,
  defaultView: 'list',
  sorting: 'dueDate',
  fontSize: 'medium',
};

export const useSettingsStore = create<SettingsState>()(
  persist(
    (set) => ({
      ...defaultSettings,

      updateSettings: (settings) => {
        set((state) => ({
          ...state,
          ...settings,
        }));
      },

      resetSettings: () => {
        set(defaultSettings);
      },
    }),
    {
      name: 'settings-storage',
      storage: createJSONStorage(() => AsyncStorage),
      // Optional: only persist certain fields
      // partialize: (state) => ({
      //   notifications: state.notifications,
      //   soundEnabled: state.soundEnabled,
      // }),
    }
  )
);
```

### Encryption with SecureStore

```typescript
// src/utils/secureStorage.ts
import * as SecureStore from 'expo-secure-store';
import { Platform } from 'react-native';

/**
 * SecureStorage - Encrypted storage for sensitive data
 * 
 * Use this for auth tokens, passwords, and other sensitive data.
 * SecureStore uses the device's secure enclave/keychain.
 */
export const SecureStorage = {
  /**
   * Store sensitive data
   */
  setItem: async (key: string, value: string): Promise<void> => {
    try {
      await SecureStore.setItemAsync(key, value, {
        keychainAccessible: SecureStore.WHEN_UNLOCKED_THIS_DEVICE_ONLY,
      });
    } catch (error) {
      console.error('Error storing secure data:', error);
      throw error;
    }
  },

  /**
   * Retrieve sensitive data
   */
  getItem: async (key: string): Promise<string | null> => {
    try {
      return await SecureStore.getItemAsync(key);
    } catch (error) {
      console.error('Error retrieving secure data:', error);
      return null;
    }
  },

  /**
   * Delete sensitive data
   */
  deleteItem: async (key: string): Promise<void> => {
    try {
      await SecureStore.deleteItemAsync(key);
    } catch (error) {
      console.error('Error deleting secure data:', error);
      throw error;
    }
  },

  /**
   * Store a JSON object
   */
  setJSONItem: async <T>(key: string, value: T): Promise<void> => {
    try {
      const jsonString = JSON.stringify(value);
      await SecureStore.setItemAsync(key, jsonString);
    } catch (error) {
      console.error('Error storing secure JSON:', error);
      throw error;
    }
  },

  /**
   * Retrieve a JSON object
   */
  getJSONItem: async <T>(key: string): Promise<T | null> => {
    try {
      const jsonString = await SecureStore.getItemAsync(key);
      if (jsonString) {
        return JSON.parse(jsonString);
      }
      return null;
    } catch (error) {
      console.error('Error retrieving secure JSON:', error);
      return null;
    }
  },
};
```

---

## Target 3: MMKV - High-Performance Storage

**The Target:** Implement MMKV for lightning-fast key-value storage.

**The Concept:** MMKV is a high-performance key-value storage library from WeChat. It's up to 100x faster than AsyncStorage and supports large data volumes. Perfect for caching, offline data, and performance-critical operations.

### MMKV Implementation

```typescript
// src/utils/mmkvStorage.ts
import { MMKV } from 'react-native-mmkv';

/**
 * Create MMKV instances for different data types
 */
export const mmkvStorage = {
  // Main storage for app data
  app: new MMKV({
    id: 'app-storage',
    encryptionKey: process.env.EXPO_PUBLIC_ENCRYPTION_KEY,
  }),

  // Cache storage (can be cleared without losing app data)
  cache: new MMKV({
    id: 'cache-storage',
  }),

  // User-specific storage (separate instances for multi-user)
  user: new MMKV({
    id: 'user-storage',
  }),
};

/**
 * MMKV wrapper with type safety
 */
export class MMKVService {
  private storage: MMKV;

  constructor(storage: MMKV) {
    this.storage = storage;
  }

  /**
   * Set a value
   */
  set = (key: string, value: any): void => {
    try {
      if (typeof value === 'string') {
        this.storage.set(key, value);
      } else if (typeof value === 'number') {
        this.storage.set(key, value);
      } else if (typeof value === 'boolean') {
        this.storage.set(key, value);
      } else {
        // JSON serialize for objects
        this.storage.set(key, JSON.stringify(value));
      }
    } catch (error) {
      console.error(`Error setting ${key}:`, error);
    }
  };

  /**
   * Get a value with type inference
   */
  get = <T = any>(key: string): T | null => {
    try {
      const value = this.storage.getString(key);
      
      if (value === undefined) {
        return null;
      }

      // Try to parse as JSON
      try {
        return JSON.parse(value);
      } catch {
        // If parsing fails, return as string
        return value as unknown as T;
      }
    } catch (error) {
      console.error(`Error getting ${key}:`, error);
      return null;
    }
  };

  /**
   * Get a number
   */
  getNumber = (key: string): number | null => {
    try {
      return this.storage.getNumber(key) ?? null;
    } catch (error) {
      console.error(`Error getting number ${key}:`, error);
      return null;
    }
  };

  /**
   * Get a boolean
   */
  getBoolean = (key: string): boolean | null => {
    try {
      return this.storage.getBoolean(key) ?? null;
    } catch (error) {
      console.error(`Error getting boolean ${key}:`, error);
      return null;
    }
  };

  /**
   * Get a string
   */
  getString = (key: string): string | null => {
    try {
      return this.storage.getString(key) ?? null;
    } catch (error) {
      console.error(`Error getting string ${key}:`, error);
      return null;
    }
  };

  /**
   * Delete a key
   */
  delete = (key: string): void => {
    try {
      this.storage.delete(key);
    } catch (error) {
      console.error(`Error deleting ${key}:`, error);
    }
  };

  /**
   * Get all keys
   */
  getAllKeys = (): string[] => {
    try {
      return this.storage.getAllKeys();
    } catch (error) {
      console.error('Error getting all keys:', error);
      return [];
    }
  };

  /**
   * Clear all data
   */
  clear = (): void => {
    try {
      this.storage.clearAll();
    } catch (error) {
      console.error('Error clearing storage:', error);
    }
  };
}

// Create service instances
export const appStorage = new MMKVService(mmkvStorage.app);
export const cacheStorage = new MMKVService(mmkvStorage.cache);
export const userStorage = new MMKVService(mmkvStorage.user);
```

### Using MMKV for Task Cache

```typescript
// src/stores/taskStoreWithMMKV.ts
import { create } from 'zustand';
import { appStorage, cacheStorage } from '../utils/mmkvStorage';
import { Task } from './taskStore';

// Key for caching tasks
const TASKS_CACHE_KEY = '@tasks';
const LAST_SYNC_KEY = '@lastSync';

/**
 * TaskStore with MMKV caching
 * 
 * This store uses MMKV for fast caching of tasks,
 * providing instant access even when offline.
 */
interface TaskState {
  tasks: Task[];
  isLoading: boolean;
  error: string | null;
  lastSync: string | null;
  
  // Actions
  loadTasks: () => void; // Synchronous (MMKV is sync)
  fetchTasks: () => Promise<void>;
  addTask: (task: Omit<Task, 'id' | 'createdAt' | 'updatedAt'>) => Promise<void>;
  updateTask: (id: string, updates: Partial<Task>) => Promise<void>;
  deleteTask: (id: string) => Promise<void>;
  clearCache: () => void;
}

export const useTaskStoreMMKV = create<TaskState>((set, get) => ({
  tasks: [],
  isLoading: false,
  error: null,
  lastSync: null,

  // Load tasks from cache (sync)
  loadTasks: () => {
    try {
      const cachedTasks = appStorage.get<Task[]>(TASKS_CACHE_KEY);
      const lastSync = appStorage.getString(LAST_SYNC_KEY);
      
      set({
        tasks: cachedTasks || [],
        lastSync: lastSync || null,
        isLoading: false,
        error: null,
      });
    } catch (error) {
      console.error('Error loading cached tasks:', error);
      set({ error: 'Failed to load cached tasks' });
    }
  },

  // Fetch tasks from API
  fetchTasks: async () => {
    set({ isLoading: true, error: null });
    
    try {
      // Simulate API call
      await new Promise(resolve => setTimeout(resolve, 1000));
      
      // Mock fetched tasks
      const fetchedTasks: Task[] = [
        {
          id: '1',
          title: 'Learn React Native',
          description: 'Complete the React Native tutorial',
          priority: 'high',
          status: 'in-progress',
          dueDate: '2026-08-20',
          category: 'Learning',
          createdAt: new Date().toISOString(),
          updatedAt: new Date().toISOString(),
        },
        {
          id: '2',
          title: 'Build TaskFlow app',
          description: 'Complete the full TaskFlow application',
          priority: 'high',
          status: 'todo',
          dueDate: '2026-08-30',
          category: 'Work',
          createdAt: new Date().toISOString(),
          updatedAt: new Date().toISOString(),
        },
      ];
      
      // Save to MMKV (sync, very fast)
      appStorage.set(TASKS_CACHE_KEY, fetchedTasks);
      appStorage.set(LAST_SYNC_KEY, new Date().toISOString());
      
      // Update state
      set({
        tasks: fetchedTasks,
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

  // Add a new task
  addTask: async (taskData) => {
    try {
      const newTask: Task = {
        id: Date.now().toString(),
        ...taskData,
        status: 'todo',
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString(),
      };
      
      // Update state
      set((state) => ({
        tasks: [newTask, ...state.tasks],
      }));
      
      // Update cache
      const currentTasks = get().tasks;
      appStorage.set(TASKS_CACHE_KEY, currentTasks);
    } catch (error) {
      console.error('Error adding task:', error);
      throw error;
    }
  },

  // Update a task
  updateTask: async (id, updates) => {
    try {
      set((state) => ({
        tasks: state.tasks.map(task =>
          task.id === id
            ? { ...task, ...updates, updatedAt: new Date().toISOString() }
            : task
        ),
      }));
      
      // Update cache
      const currentTasks = get().tasks;
      appStorage.set(TASKS_CACHE_KEY, currentTasks);
    } catch (error) {
      console.error('Error updating task:', error);
      throw error;
    }
  },

  // Delete a task
  deleteTask: async (id) => {
    try {
      set((state) => ({
        tasks: state.tasks.filter(task => task.id !== id),
      }));
      
      // Update cache
      const currentTasks = get().tasks;
      appStorage.set(TASKS_CACHE_KEY, currentTasks);
    } catch (error) {
      console.error('Error deleting task:', error);
      throw error;
    }
  },

  // Clear cache
  clearCache: () => {
    appStorage.delete(TASKS_CACHE_KEY);
    appStorage.delete(LAST_SYNC_KEY);
    set({ tasks: [], lastSync: null });
  },
}));
```

---

## Target 4: SQLite - Relational Data Storage

**The Target:** Implement SQLite for complex relational data.

**The Concept:** SQLite is a full SQL database embedded in your app. It's perfect for complex data structures with relationships—like tasks with subtasks, comments, and attachments.

### SQLite Database Setup

```typescript
// src/database/database.ts
import * as SQLite from 'expo-sqlite';

// Open database
const db = SQLite.openDatabaseSync('taskflow.db');

/**
 * Database initialization and schema creation
 */
export const initializeDatabase = async () => {
  try {
    // Create tables
    await db.execAsync(`
      -- Users table
      CREATE TABLE IF NOT EXISTS users (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        avatar TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      );

      -- Tasks table
      CREATE TABLE IF NOT EXISTS tasks (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        priority TEXT NOT NULL,
        status TEXT NOT NULL,
        due_date TEXT,
        category TEXT,
        assigned_to TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (assigned_to) REFERENCES users(id)
      );

      -- Subtasks table
      CREATE TABLE IF NOT EXISTS subtasks (
        id TEXT PRIMARY KEY,
        task_id TEXT NOT NULL,
        title TEXT NOT NULL,
        is_completed INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        FOREIGN KEY (task_id) REFERENCES tasks(id) ON DELETE CASCADE
      );

      -- Comments table
      CREATE TABLE IF NOT EXISTS comments (
        id TEXT PRIMARY KEY,
        task_id TEXT NOT NULL,
        user_id TEXT NOT NULL,
        content TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (task_id) REFERENCES tasks(id) ON DELETE CASCADE,
        FOREIGN KEY (user_id) REFERENCES users(id)
      );

      -- Tags table
      CREATE TABLE IF NOT EXISTS tags (
        id TEXT PRIMARY KEY,
        name TEXT UNIQUE NOT NULL,
        color TEXT NOT NULL
      );

      -- Task-Tags junction table
      CREATE TABLE IF NOT EXISTS task_tags (
        task_id TEXT NOT NULL,
        tag_id TEXT NOT NULL,
        PRIMARY KEY (task_id, tag_id),
        FOREIGN KEY (task_id) REFERENCES tasks(id) ON DELETE CASCADE,
        FOREIGN KEY (tag_id) REFERENCES tags(id) ON DELETE CASCADE
      );

      -- Create indexes for performance
      CREATE INDEX IF NOT EXISTS idx_tasks_status ON tasks(status);
      CREATE INDEX IF NOT EXISTS idx_tasks_priority ON tasks(priority);
      CREATE INDEX IF NOT EXISTS idx_tasks_due_date ON tasks(due_date);
      CREATE INDEX IF NOT EXISTS idx_comments_task ON comments(task_id);
      CREATE INDEX IF NOT EXISTS idx_subtasks_task ON subtasks(task_id);
    `);

    console.log('✅ Database initialized successfully');
  } catch (error) {
    console.error('❌ Database initialization failed:', error);
    throw error;
  }
};

/**
 * Database service class for CRUD operations
 */
export class DatabaseService {
  /**
   * Execute a query
   */
  static async query<T = any>(
    sql: string,
    params?: any[]
  ): Promise<T[]> {
    try {
      const result = await db.execSync(sql, params);
      return result as T[];
    } catch (error) {
      console.error('Query error:', error);
      throw error;
    }
  }

  /**
   * Get first result from query
   */
  static async queryOne<T = any>(
    sql: string,
    params?: any[]
  ): Promise<T | null> {
    try {
      const results = await this.query<T>(sql, params);
      return results.length > 0 ? results[0] : null;
    } catch (error) {
      console.error('Query one error:', error);
      return null;
    }
  }

  /**
   * Insert data
   */
  static async insert(
    table: string,
    data: Record<string, any>
  ): Promise<void> {
    const columns = Object.keys(data);
    const placeholders = columns.map(() => '?').join(', ');
    const values = Object.values(data);

    const sql = `
      INSERT INTO ${table} (${columns.join(', ')})
      VALUES (${placeholders})
    `;

    await this.query(sql, values);
  }

  /**
   * Update data
   */
  static async update(
    table: string,
    data: Record<string, any>,
    where: Record<string, any>
  ): Promise<void> {
    const setClause = Object.keys(data)
      .map(key => `${key} = ?`)
      .join(', ');
    
    const whereClause = Object.keys(where)
      .map(key => `${key} = ?`)
      .join(' AND ');
    
    const values = [...Object.values(data), ...Object.values(where)];

    const sql = `
      UPDATE ${table}
      SET ${setClause}
      WHERE ${whereClause}
    `;

    await this.query(sql, values);
  }

  /**
   * Delete data
   */
  static async delete(
    table: string,
    where: Record<string, any>
  ): Promise<void> {
    const whereClause = Object.keys(where)
      .map(key => `${key} = ?`)
      .join(' AND ');
    
    const values = Object.values(where);

    const sql = `
      DELETE FROM ${table}
      WHERE ${whereClause}
    `;

    await this.query(sql, values);
  }

  /**
   * Get tasks with all related data (JOIN query)
   */
  static async getTasksWithRelations() {
    const sql = `
      SELECT 
        t.*,
        u.name as assigned_to_name,
        u.email as assigned_to_email,
        GROUP_CONCAT(DISTINCT tags.name) as tag_names,
        COUNT(DISTINCT subtasks.id) as subtask_count,
        COUNT(DISTINCT comments.id) as comment_count
      FROM tasks t
      LEFT JOIN users u ON t.assigned_to = u.id
      LEFT JOIN task_tags tt ON t.id = tt.task_id
      LEFT JOIN tags ON tt.tag_id = tags.id
      LEFT JOIN subtasks ON t.id = subtasks.task_id
      LEFT JOIN comments ON t.id = comments.task_id
      GROUP BY t.id
      ORDER BY t.created_at DESC
    `;

    return await this.query(sql);
  }
}
```

### SQLite Integration in Components

```typescript
// src/components/TaskDetailWithSQLite.tsx
import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TextInput,
  TouchableOpacity,
  ActivityIndicator,
  Platform,
} from 'react-native';
import { DatabaseService } from '../database/database';

interface Comment {
  id: string;
  content: string;
  created_at: string;
  user_id: string;
}

interface TaskWithRelations {
  id: string;
  title: string;
  description: string;
  priority: string;
  status: string;
  due_date: string;
  category: string;
  assigned_to: string;
  assigned_to_name: string;
  assigned_to_email: string;
  tag_names: string;
  subtask_count: number;
  comment_count: number;
}

export const TaskDetailWithSQLite: React.FC<{ taskId: string }> = ({ taskId }) => {
  const [task, setTask] = useState<TaskWithRelations | null>(null);
  const [comments, setComments] = useState<Comment[]>([]);
  const [newComment, setNewComment] = useState('');
  const [loading, setLoading] = useState(true);
  const [submitting, setSubmitting] = useState(false);

  // Load task data
  useEffect(() => {
    loadTaskData();
  }, [taskId]);

  const loadTaskData = async () => {
    setLoading(true);
    try {
      // Load task with relations
      const tasks = await DatabaseService.query<TaskWithRelations>(`
        SELECT 
          t.*,
          u.name as assigned_to_name,
          u.email as assigned_to_email,
          GROUP_CONCAT(tags.name) as tag_names,
          COUNT(DISTINCT subtasks.id) as subtask_count,
          COUNT(DISTINCT comments.id) as comment_count
        FROM tasks t
        LEFT JOIN users u ON t.assigned_to = u.id
        LEFT JOIN task_tags tt ON t.id = tt.task_id
        LEFT JOIN tags ON tt.tag_id = tags.id
        LEFT JOIN subtasks ON t.id = subtasks.task_id
        LEFT JOIN comments ON t.id = comments.task_id
        WHERE t.id = ?
        GROUP BY t.id
      `, [taskId]);

      if (tasks.length > 0) {
        setTask(tasks[0]);
      }

      // Load comments
      const commentsResult = await DatabaseService.query<Comment>(`
        SELECT c.*, u.name as user_name
        FROM comments c
        JOIN users u ON c.user_id = u.id
        WHERE c.task_id = ?
        ORDER BY c.created_at DESC
      `, [taskId]);

      setComments(commentsResult);
    } catch (error) {
      console.error('Error loading task:', error);
    } finally {
      setLoading(false);
    }
  };

  const addComment = async () => {
    if (!newComment.trim() || !task) return;

    setSubmitting(true);
    try {
      const commentId = `comment-${Date.now()}`;
      const userId = '1'; // Current user ID

      await DatabaseService.insert('comments', {
        id: commentId,
        task_id: task.id,
        user_id: userId,
        content: newComment.trim(),
        created_at: new Date().toISOString(),
      });

      setNewComment('');
      await loadTaskData(); // Refresh comments
    } catch (error) {
      console.error('Error adding comment:', error);
    } finally {
      setSubmitting(false);
    }
  };

  if (loading) {
    return (
      <View style={styles.loadingContainer}>
        <ActivityIndicator size="large" color="#3498db" />
      </View>
    );
  }

  if (!task) {
    return (
      <View style={styles.errorContainer}>
        <Text style={styles.errorText}>Task not found</Text>
      </View>
    );
  }

  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.content}>
      {/* Task Details */}
      <View style={styles.taskHeader}>
        <Text style={styles.taskTitle}>{task.title}</Text>
        <View style={styles.badgeContainer}>
          <View style={[styles.badge, styles[`badge_${task.priority}`]]}>
            <Text style={styles.badgeText}>{task.priority}</Text>
          </View>
          <View style={[styles.badge, styles[`badge_${task.status}`]]}>
            <Text style={styles.badgeText}>{task.status}</Text>
          </View>
        </View>
      </View>

      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Description</Text>
        <Text style={styles.description}>{task.description || 'No description'}</Text>
      </View>

      <View style={styles.metaGrid}>
        <View style={styles.metaItem}>
          <Text style={styles.metaLabel}>Due Date</Text>
          <Text style={styles.metaValue}>{task.due_date || 'No due date'}</Text>
        </View>
        <View style={styles.metaItem}>
          <Text style={styles.metaLabel}>Category</Text>
          <Text style={styles.metaValue}>{task.category || 'Uncategorized'}</Text>
        </View>
        <View style={styles.metaItem}>
          <Text style={styles.metaLabel}>Assigned To</Text>
          <Text style={styles.metaValue}>{task.assigned_to_name || 'Unassigned'}</Text>
        </View>
        <View style={styles.metaItem}>
          <Text style={styles.metaLabel}>Tags</Text>
          <Text style={styles.metaValue}>{task.tag_names || 'No tags'}</Text>
        </View>
      </View>

      <View style={styles.statsContainer}>
        <View style={styles.statItem}>
          <Text style={styles.statValue}>{task.subtask_count}</Text>
          <Text style={styles.statLabel}>Subtasks</Text>
        </View>
        <View style={styles.statDivider} />
        <View style={styles.statItem}>
          <Text style={styles.statValue}>{task.comment_count}</Text>
          <Text style={styles.statLabel}>Comments</Text>
        </View>
      </View>

      {/* Comments */}
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Comments</Text>
        
        <View style={styles.commentInputContainer}>
          <TextInput
            style={styles.commentInput}
            placeholder="Add a comment..."
            value={newComment}
            onChangeText={setNewComment}
            multiline
            placeholderTextColor="#95a5a6"
          />
          <TouchableOpacity
            style={[styles.commentButton, submitting && styles.commentButtonDisabled]}
            onPress={addComment}
            disabled={submitting}
          >
            <Text style={styles.commentButtonText}>
              {submitting ? 'Sending...' : 'Send'}
            </Text>
          </TouchableOpacity>
        </View>

        {comments.map((comment) => (
          <View key={comment.id} style={styles.commentItem}>
            <Text style={styles.commentContent}>{comment.content}</Text>
            <Text style={styles.commentMeta}>
              {new Date(comment.created_at).toLocaleString()}
            </Text>
          </View>
        ))}

        {comments.length === 0 && (
          <Text style={styles.noComments}>No comments yet</Text>
        )}
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
  loadingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  errorContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  errorText: {
    fontSize: 16,
    color: '#e74c3c',
  },
  taskHeader: {
    marginBottom: 16,
  },
  taskTitle: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#2c3e50',
    marginBottom: 8,
  },
  badgeContainer: {
    flexDirection: 'row',
    gap: 8,
  },
  badge: {
    paddingHorizontal: 12,
    paddingVertical: 4,
    borderRadius: 20,
    alignSelf: 'flex-start',
  },
  badge_high: {
    backgroundColor: '#e74c3c',
  },
  badge_medium: {
    backgroundColor: '#f39c12',
  },
  badge_low: {
    backgroundColor: '#2ecc71',
  },
  badge_todo: {
    backgroundColor: '#95a5a6',
  },
  badge_in_progress: {
    backgroundColor: '#3498db',
  },
  badge_done: {
    backgroundColor: '#2ecc71',
  },
  badgeText: {
    color: '#ffffff',
    fontSize: 12,
    fontWeight: '600',
    textTransform: 'capitalize',
  },
  section: {
    marginBottom: 20,
  },
  sectionTitle: {
    fontSize: 16,
    fontWeight: '600',
    color: '#2c3e50',
    marginBottom: 8,
  },
  description: {
    fontSize: 14,
    color: '#34495e',
    lineHeight: 20,
  },
  metaGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 12,
    marginBottom: 16,
  },
  metaItem: {
    flex: 1,
    minWidth: '45%',
    backgroundColor: '#ffffff',
    padding: 12,
    borderRadius: 8,
    ...Platform.select({
      ios: {
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 1 },
        shadowOpacity: 0.05,
        shadowRadius: 2,
      },
      android: {
        elevation: 1,
      },
    }),
  },
  metaLabel: {
    fontSize: 12,
    color: '#7f8c8d',
    marginBottom: 4,
  },
  metaValue: {
    fontSize: 14,
    color: '#2c3e50',
    fontWeight: '500',
  },
  statsContainer: {
    flexDirection: 'row',
    backgroundColor: '#ffffff',
    borderRadius: 12,
    padding: 16,
    marginBottom: 20,
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
  commentInputContainer: {
    flexDirection: 'row',
    gap: 8,
    marginBottom: 12,
  },
  commentInput: {
    flex: 1,
    backgroundColor: '#ffffff',
    borderRadius: 8,
    paddingHorizontal: 12,
    paddingVertical: 8,
    fontSize: 14,
    color: '#2c3e50',
    borderWidth: 1,
    borderColor: '#e1e8ed',
    minHeight: 40,
  },
  commentButton: {
    backgroundColor: '#3498db',
    borderRadius: 8,
    paddingHorizontal: 16,
    justifyContent: 'center',
  },
  commentButtonDisabled: {
    opacity: 0.7,
  },
  commentButtonText: {
    color: '#ffffff',
    fontSize: 14,
    fontWeight: '600',
  },
  commentItem: {
    backgroundColor: '#ffffff',
    borderRadius: 8,
    padding: 12,
    marginBottom: 8,
    borderWidth: 1,
    borderColor: '#f0f0f0',
  },
  commentContent: {
    fontSize: 14,
    color: '#2c3e50',
    marginBottom: 4,
  },
  commentMeta: {
    fontSize: 10,
    color: '#95a5a6',
  },
  noComments: {
    fontSize: 14,
    color: '#95a5a6',
    textAlign: 'center',
    paddingVertical: 20,
  },
});
```

---

## Target 5: Offline-First Architecture

**The Target:** Build an app that works seamlessly without internet.

**The Concept:** Offline-first means your app works perfectly without an internet connection. Changes made offline are synchronized when connectivity returns. Think of it as having a local copy of your data that syncs with the server.

### Offline Sync Manager

```typescript
// src/services/offlineSync.ts
import { appStorage } from '../utils/mmkvStorage';
import { DatabaseService } from '../database/database';
import NetInfo from '@react-native-community/netinfo';

interface PendingOperation {
  id: string;
  type: 'create' | 'update' | 'delete';
  table: string;
  data: any;
  timestamp: string;
  retries: number;
}

/**
 * OfflineSyncManager - Handles offline operations and sync
 * 
 * This service queues operations when offline and syncs
 * them when connectivity is restored.
 */
export class OfflineSyncManager {
  private static instance: OfflineSyncManager;
  private isOnline: boolean = true;
  private isSyncing: boolean = false;
  private syncInterval: NodeJS.Timeout | null = null;

  private constructor() {
    this.setupNetworkListener();
    this.startPeriodicSync();
  }

  static getInstance(): OfflineSyncManager {
    if (!OfflineSyncManager.instance) {
      OfflineSyncManager.instance = new OfflineSyncManager();
    }
    return OfflineSyncManager.instance;
  }

  /**
   * Setup network connectivity listener
   */
  private setupNetworkListener() {
    NetInfo.addEventListener((state) => {
      const wasOnline = this.isOnline;
      this.isOnline = state.isConnected ?? false;

      // Trigger sync when coming back online
      if (!wasOnline && this.isOnline) {
        console.log('📡 Back online - starting sync...');
        this.syncPendingOperations();
      }
    });
  }

  /**
   * Start periodic sync (every 5 minutes)
   */
  private startPeriodicSync() {
    this.syncInterval = setInterval(() => {
      if (this.isOnline) {
        this.syncPendingOperations();
      }
    }, 5 * 60 * 1000); // 5 minutes
  }

  /**
   * Queue an operation for offline sync
   */
  async queueOperation(
    type: PendingOperation['type'],
    table: string,
    data: any
  ): Promise<void> {
    const operation: PendingOperation = {
      id: `op-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`,
      type,
      table,
      data,
      timestamp: new Date().toISOString(),
      retries: 0,
    };

    // Store in MMKV for fast access
    const operations = this.getPendingOperations();
    operations.push(operation);
    appStorage.set('pending_operations', operations);

    // If online, try to sync immediately
    if (this.isOnline) {
      await this.syncPendingOperations();
    }
  }

  /**
   * Get all pending operations
   */
  private getPendingOperations(): PendingOperation[] {
    return appStorage.get<PendingOperation[]>('pending_operations') || [];
  }

  /**
   * Sync pending operations with server
   */
  async syncPendingOperations(): Promise<void> {
    if (this.isSyncing || !this.isOnline) {
      return;
    }

    this.isSyncing = true;
    console.log('🔄 Syncing pending operations...');

    try {
      const operations = this.getPendingOperations();
      
      if (operations.length === 0) {
        console.log('✅ No pending operations');
        this.isSyncing = false;
        return;
      }

      console.log(`📦 Syncing ${operations.length} operations...`);

      // Process operations in order
      for (const operation of operations) {
        try {
          await this.processOperation(operation);
          
          // Remove successful operation
          const remaining = this.getPendingOperations();
          const updated = remaining.filter(op => op.id !== operation.id);
          appStorage.set('pending_operations', updated);
          
          console.log(`✅ Synced operation: ${operation.id}`);
        } catch (error) {
          console.error(`❌ Failed to sync operation ${operation.id}:`, error);
          
          // Increment retry count
          operation.retries += 1;
          
          // Remove if too many retries
          if (operation.retries > 5) {
            console.warn(`⚠️ Operation ${operation.id} exceeded retry limit - discarding`);
            const remaining = this.getPendingOperations();
            const updated = remaining.filter(op => op.id !== operation.id);
            appStorage.set('pending_operations', updated);
          }
        }
      }
    } catch (error) {
      console.error('❌ Sync error:', error);
    } finally {
      this.isSyncing = false;
    }
  }

  /**
   * Process a single operation
   */
  private async processOperation(operation: PendingOperation): Promise<void> {
    // Simulate API call
    await new Promise(resolve => setTimeout(resolve, 500));

    // In a real app, you'd make an API call here
    console.log(`📤 Processing ${operation.type} on ${operation.table}:`, operation.data);

    // For demo, just log success
    return;
  }

  /**
   * Get sync status
   */
  getSyncStatus(): { isOnline: boolean; isSyncing: boolean; pendingCount: number } {
    const pending = this.getPendingOperations();
    return {
      isOnline: this.isOnline,
      isSyncing: this.isSyncing,
      pendingCount: pending.length,
    };
  }

  /**
   * Clean up
   */
  destroy() {
    if (this.syncInterval) {
      clearInterval(this.syncInterval);
    }
    NetInfo.removeEventListener();
  }
}

// Export singleton instance
export const offlineSync = OfflineSyncManager.getInstance();
```

### Offline-First Task Operations

```typescript
// src/services/taskService.ts
import { offlineSync } from './offlineSync';
import { DatabaseService } from '../database/database';
import { appStorage } from '../utils/mmkvStorage';

/**
 * TaskService - Handles task operations with offline support
 * 
 * All operations are queued for sync when offline.
 */
export class TaskService {
  /**
   * Create a task (offline-first)
   */
  static async createTask(taskData: any) {
    const taskId = `task-${Date.now()}`;
    const timestamp = new Date().toISOString();

    const task = {
      id: taskId,
      ...taskData,
      created_at: timestamp,
      updated_at: timestamp,
      status: 'todo',
    };

    // Save locally
    await DatabaseService.insert('tasks', task);

    // Queue for sync
    await offlineSync.queueOperation('create', 'tasks', task);

    // Update MMKV cache
    const cachedTasks = appStorage.get<any[]>('tasks_cache') || [];
    cachedTasks.push(task);
    appStorage.set('tasks_cache', cachedTasks);

    return task;
  }

  /**
   * Update a task (offline-first)
   */
  static async updateTask(taskId: string, updates: any) {
    const updated = {
      ...updates,
      updated_at: new Date().toISOString(),
    };

    // Update locally
    await DatabaseService.update('tasks', updated, { id: taskId });

    // Queue for sync
    await offlineSync.queueOperation('update', 'tasks', { id: taskId, ...updated });

    // Update MMKV cache
    const cachedTasks = appStorage.get<any[]>('tasks_cache') || [];
    const index = cachedTasks.findIndex(t => t.id === taskId);
    if (index !== -1) {
      cachedTasks[index] = { ...cachedTasks[index], ...updated };
      appStorage.set('tasks_cache', cachedTasks);
    }

    return updated;
  }

  /**
   * Delete a task (offline-first)
   */
  static async deleteTask(taskId: string) {
    // Delete locally
    await DatabaseService.delete('tasks', { id: taskId });

    // Queue for sync
    await offlineSync.queueOperation('delete', 'tasks', { id: taskId });

    // Update MMKV cache
    const cachedTasks = appStorage.get<any[]>('tasks_cache') || [];
    const updated = cachedTasks.filter(t => t.id !== taskId);
    appStorage.set('tasks_cache', updated);
  }

  /**
   * Get tasks (from cache first, then database)
   */
  static async getTasks(): Promise<any[]> {
    // Try MMKV cache first (fastest)
    const cached = appStorage.get<any[]>('tasks_cache');
    if (cached && cached.length > 0) {
      return cached;
    }

    // Fall back to database
    const tasks = await DatabaseService.query('SELECT * FROM tasks ORDER BY created_at DESC');
    
    // Update cache
    appStorage.set('tasks_cache', tasks);
    
    return tasks;
  }

  /**
   * Get a single task with all relations
   */
  static async getTaskWithRelations(taskId: string): Promise<any> {
    const task = await DatabaseService.queryOne(`
      SELECT 
        t.*,
        u.name as assigned_to_name,
        GROUP_CONCAT(tags.name) as tag_names,
        COUNT(DISTINCT subtasks.id) as subtask_count
      FROM tasks t
      LEFT JOIN users u ON t.assigned_to = u.id
      LEFT JOIN task_tags tt ON t.id = tt.task_id
      LEFT JOIN tags ON tt.tag_id = tags.id
      LEFT JOIN subtasks ON t.id = subtasks.task_id
      WHERE t.id = ?
      GROUP BY t.id
    `, [taskId]);

    return task;
  }

  /**
   * Sync all tasks from server
   */
  static async syncTasksFromServer(): Promise<void> {
    // In a real app, fetch from API
    // For demo, simulate API call
    await new Promise(resolve => setTimeout(resolve, 1000));

    // Mock tasks from server
    const serverTasks = [
      {
        id: 'server-1',
        title: 'Server Task 1',
        description: 'Synced from server',
        priority: 'high',
        status: 'todo',
        due_date: '2026-09-01',
        category: 'Work',
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString(),
      },
    ];

    // Save to database
    for (const task of serverTasks) {
      await DatabaseService.insert('tasks', task);
    }

    // Update cache
    const allTasks = await DatabaseService.query('SELECT * FROM tasks');
    appStorage.set('tasks_cache', allTasks);
  }
}
```

### Offline Status Indicator Component

```typescript
// src/components/OfflineStatusIndicator.tsx
import React, { useState, useEffect } from 'react';
import { View, Text, StyleSheet, Animated, Platform } from 'react-native';
import { offlineSync } from '../services/offlineSync';

export const OfflineStatusIndicator: React.FC = () => {
  const [status, setStatus] = useState(offlineSync.getSyncStatus());
  const [fadeAnim] = useState(new Animated.Value(0));

  useEffect(() => {
    // Update status periodically
    const interval = setInterval(() => {
      const newStatus = offlineSync.getSyncStatus();
      setStatus(newStatus);

      // Animate visibility
      if (!newStatus.isOnline || newStatus.pendingCount > 0) {
        Animated.timing(fadeAnim, {
          toValue: 1,
          duration: 300,
          useNativeDriver: true,
        }).start();
      } else {
        Animated.timing(fadeAnim, {
          toValue: 0,
          duration: 300,
          useNativeDriver: true,
        }).start();
      }
    }, 1000);

    return () => clearInterval(interval);
  }, []);

  if (status.isOnline && status.pendingCount === 0) {
    return null;
  }

  return (
    <Animated.View style={[styles.container, { opacity: fadeAnim }]}>
      <View style={styles.content}>
        <View style={[styles.dot, { backgroundColor: status.isOnline ? '#2ecc71' : '#e74c3c' }]} />
        
        <Text style={styles.statusText}>
          {!status.isOnline 
            ? '📡 Offline - Working locally' 
            : status.isSyncing 
              ? '🔄 Syncing...' 
              : status.pendingCount > 0 
                ? `⏳ ${status.pendingCount} pending changes` 
                : '✅ All synced'}
        </Text>
      </View>
    </Animated.View>
  );
};

const styles = StyleSheet.create({
  container: {
    position: 'absolute',
    bottom: 20,
    left: 20,
    right: 20,
    alignItems: 'center',
  },
  content: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#ffffff',
    paddingHorizontal: 16,
    paddingVertical: 10,
    borderRadius: 20,
    ...Platform.select({
      ios: {
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 2 },
        shadowOpacity: 0.15,
        shadowRadius: 8,
      },
      android: {
        elevation: 4,
      },
    }),
  },
  dot: {
    width: 8,
    height: 8,
    borderRadius: 4,
    marginRight: 8,
  },
  statusText: {
    fontSize: 14,
    color: '#2c3e50',
    fontWeight: '500',
  },
});
```

---

## Target 6: Data Migration Strategy

**The Target:** Handle data migration when app schema changes.

**The Concept:** As your app evolves, your data schema will change. Migration ensures users don't lose data when you update the app.

### Migration Manager

```typescript
// src/database/migrations.ts
import { DatabaseService } from './database';

interface Migration {
  version: number;
  up: () => Promise<void>;
  down?: () => Promise<void>;
}

export const migrations: Migration[] = [
  {
    version: 1,
    up: async () => {
      console.log('📦 Running migration v1: Initial schema');
      // Initial schema is created in database initialization
    },
  },
  {
    version: 2,
    up: async () => {
      console.log('📦 Running migration v2: Add priority column');
      await DatabaseService.query(`
        ALTER TABLE tasks ADD COLUMN priority TEXT DEFAULT 'medium'
      `);
    },
  },
  {
    version: 3,
    up: async () => {
      console.log('📦 Running migration v3: Add tags table');
      await DatabaseService.query(`
        CREATE TABLE tags (
          id TEXT PRIMARY KEY,
          name TEXT UNIQUE NOT NULL,
          color TEXT NOT NULL
        );
        
        CREATE TABLE task_tags (
          task_id TEXT NOT NULL,
          tag_id TEXT NOT NULL,
          PRIMARY KEY (task_id, tag_id),
          FOREIGN KEY (task_id) REFERENCES tasks(id) ON DELETE CASCADE,
          FOREIGN KEY (tag_id) REFERENCES tags(id) ON DELETE CASCADE
        );
      `);
    },
  },
  {
    version: 4,
    up: async () => {
      console.log('📦 Running migration v4: Add attachments table');
      await DatabaseService.query(`
        CREATE TABLE attachments (
          id TEXT PRIMARY KEY,
          task_id TEXT NOT NULL,
          file_name TEXT NOT NULL,
          file_type TEXT NOT NULL,
          file_size INTEGER NOT NULL,
          file_path TEXT NOT NULL,
          created_at TEXT NOT NULL,
          FOREIGN KEY (task_id) REFERENCES tasks(id) ON DELETE CASCADE
        );
      `);
    },
  },
];

export class MigrationManager {
  private static readonly CURRENT_VERSION = 4;

  /**
   * Run all pending migrations
   */
  static async runMigrations(): Promise<void> {
    try {
      // Get current version from storage
      let currentVersion = await this.getCurrentVersion();

      console.log(`📊 Current DB version: ${currentVersion}, Target: ${this.CURRENT_VERSION}`);

      // Run migrations sequentially
      for (const migration of migrations) {
        if (migration.version > currentVersion && migration.version <= this.CURRENT_VERSION) {
          console.log(`🔄 Running migration v${migration.version}...`);
          await migration.up();
          currentVersion = migration.version;
          await this.setCurrentVersion(currentVersion);
        }
      }

      console.log('✅ All migrations completed successfully');
    } catch (error) {
      console.error('❌ Migration failed:', error);
      throw error;
    }
  }

  /**
   * Get current database version from storage
   */
  private static async getCurrentVersion(): Promise<number> {
    try {
      const result = await DatabaseService.queryOne<{ version: number }>(
        'SELECT version FROM migrations ORDER BY version DESC LIMIT 1'
      );
      return result?.version || 0;
    } catch (error) {
      // If table doesn't exist, create it
      await DatabaseService.query(`
        CREATE TABLE IF NOT EXISTS migrations (
          version INTEGER PRIMARY KEY,
          applied_at TEXT NOT NULL
        )
      `);
      return 0;
    }
  }

  /**
   * Set current database version
   */
  private static async setCurrentVersion(version: number): Promise<void> {
    await DatabaseService.insert('migrations', {
      version,
      applied_at: new Date().toISOString(),
    });
  }

  /**
   * Check if migration is needed
   */
  static async isMigrationNeeded(): Promise<boolean> {
    const currentVersion = await this.getCurrentVersion();
    return currentVersion < this.CURRENT_VERSION;
  }
}
```

### Initialize Database with Migrations

```typescript
// src/database/index.ts
import { initializeDatabase } from './database';
import { MigrationManager } from './migrations';
import { initializeSampleData } from './sampleData';

/**
 * Initialize the database with migrations
 */
export const setupDatabase = async () => {
  try {
    // 1. Initialize schema
    await initializeDatabase();

    // 2. Run migrations if needed
    const needsMigration = await MigrationManager.isMigrationNeeded();
    if (needsMigration) {
      console.log('📦 Running database migrations...');
      await MigrationManager.runMigrations();
    } else {
      console.log('✅ Database is up to date');
    }

    // 3. Initialize sample data (only for development)
    if (__DEV__) {
      await initializeSampleData();
    }

    console.log('✅ Database setup complete');
  } catch (error) {
    console.error('❌ Database setup failed:', error);
    throw error;
  }
};
```

---

## Verification: Test Data Persistence

```bash
# Run the app
cd ~/projects/TaskFlow
expo start
```

### Persistence Test Checklist

1. **AsyncStorage:**
   - [ ] Store and retrieve settings
   - [ ] Data survives app restart
   - [ ] SecureStore encrypts sensitive data

2. **MMKV:**
   - [ ] Lightning-fast read/write operations
   - [ ] Cache persists between app launches
   - [ ] Large data storage works

3. **SQLite:**
   - [ ] Database initializes with schema
   - [ ] CRUD operations work
   - [ ] Complex JOIN queries return correct data
   - [ ] Foreign key constraints work

4. **Offline-First:**
   - [ ] App works without internet connection
   - [ ] Changes are queued when offline
   - [ ] Sync happens when online restored
   - [ ] Offline indicator shows status

5. **Migrations:**
   - [ ] Migration runs on first launch
   - [ ] Version tracking works
   - [ ] Data is preserved across migrations

### Performance Test

```typescript
// src/utils/performanceTest.ts
import { appStorage } from './mmkvStorage';
import AsyncStorage from '@react-native-async-storage/async-storage';

export const testStoragePerformance = async () => {
  const testData = { test: 'data', timestamp: Date.now() };
  const iterations = 1000;

  // Test AsyncStorage
  console.log('⚡ Testing AsyncStorage...');
  const asyncStart = Date.now();
  for (let i = 0; i < iterations; i++) {
    await AsyncStorage.setItem(`test_${i}`, JSON.stringify(testData));
    await AsyncStorage.getItem(`test_${i}`);
  }
  const asyncEnd = Date.now();
  console.log(`⏱️ AsyncStorage: ${asyncEnd - asyncStart}ms for ${iterations} ops`);

  // Test MMKV
  console.log('⚡ Testing MMKV...');
  const mmkvStart = Date.now();
  for (let i = 0; i < iterations; i++) {
    appStorage.set(`test_${i}`, testData);
    appStorage.get(`test_${i}`);
  }
  const mmkvEnd = Date.now();
  console.log(`⏱️ MMKV: ${mmkvEnd - mmkvStart}ms for ${iterations} ops`);

  // Clean up
  for (let i = 0; i < iterations; i++) {
    await AsyncStorage.removeItem(`test_${i}`);
    appStorage.delete(`test_${i}`);
  }
};
```

---

## What We've Accomplished

Congratulations! You've built a complete, production-ready persistence layer. Here's what you've mastered:

1. **AsyncStorage:** Simple key-value persistence for settings and tokens
2. **SecureStore:** Encrypted storage for sensitive data
3. **MMKV:** High-performance storage for caching and large datasets
4. **SQLite:** Full relational database for complex data
5. **Offline-First:** Queue operations and sync when online
6. **Migrations:** Handle schema changes without data loss

### What's Next: Part 3 - Device Capabilities

In the next part, you'll learn:
- **Device APIs:** Camera, geolocation, notifications
- **Gestures & Animations:** Building fluid interfaces
- **Native Modules:** Custom Swift/Kotlin code
- **Forms & Validation:** Complete form handling

*Your app now has a complete state management and persistence system! Your TaskFlow app is fully functional and ready to handle real-world data. Next, we'll make your app truly mobile by accessing device hardware and building fluid, interactive interfaces. The real magic is about to begin!*
