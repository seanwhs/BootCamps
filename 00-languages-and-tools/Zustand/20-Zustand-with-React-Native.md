# Part 5 — Zustand in the Modern React Ecosystem

## Section 20: Zustand with React Native

Mobile applications present unique challenges for state management: limited resources, offline scenarios, navigation state, and smooth animations. Zustand's lightweight footprint and flexible architecture make it an ideal choice for React Native applications. In this section, you'll learn how to build performant, offline‑capable mobile apps with Zustand.

---

## The Target: Mobile‑Ready Zustand Stores

By the end of this section, you'll be able to:
- Set up Zustand in a React Native project
- Persist state using AsyncStorage and MMKV
- Optimize for mobile performance (reducing bridge traffic)
- Integrate with React Navigation for tab/window state
- Implement offline‑first patterns with background sync
- Handle secure storage for authentication tokens
- Build smooth animations that sync with Zustand state

---

## The Concept: Zustand as a Mobile State Manager

Think of Zustand in React Native like a **central command center** for your mobile app:

```
┌─────────────────────────────────────────────────────────────────┐
│                    REACT NATIVE + ZUSTAND                      │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Zustand Store                                          │  │
│  │  • Global app state                                     │  │
│  │  • User authentication                                  │  │
│  │  • Navigation state                                     │  │
│  │  • Offline queue                                        │  │
│  │  • Theme & preferences                                  │  │
│  └──────────────────────────────────────────────────────────┘  │
│                         │                                      │
│            ┌────────────┼────────────┐                        │
│            │            │            │                        │
│            ▼            ▼            ▼                        │
│  ┌──────────────────┐ ┌──────────────┐ ┌──────────────────┐ │
│  │  AsyncStorage    │ │  MMKV        │ │  SecureStore     │ │
│  │  (persistence)   │ │  (fast)      │ │  (sensitive)     │ │
│  └──────────────────┘ └──────────────┘ └──────────────────┘ │
│            │            │            │                        │
│            ▼            ▼            ▼                        │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  React Native Features                                  │  │
│  │  • Navigation (React Navigation)                       │  │
│  │  • Animations (Reanimated)                             │  │
│  │  • Background tasks                                    │  │
│  │  • Push notifications                                  │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

---

## The Implementation: React Native Integration

### Step 1: Setting Up the Project

```bash
# Create a new React Native project
npx react-native init ZustandNativeApp --template react-native-template-typescript

# Navigate to project
cd ZustandNativeApp

# Install Zustand and dependencies
npm install zustand
npm install @react-native-async-storage/async-storage
npm install react-native-mmkv
npm install react-native-keychain
npm install @react-navigation/native @react-navigation/native-stack
npm install react-native-safe-area-context react-native-screens

# For iOS (if needed)
cd ios && pod install && cd ..

# For Expo (if using Expo)
npx create-expo-app ZustandNativeApp --template
cd ZustandNativeApp
npx expo install zustand @react-native-async-storage/async-storage react-native-mmkv
```

### Step 2: Basic Store with AsyncStorage Persistence

Create a store with persistence using AsyncStorage:

```typescript
// src/store/mobileStore.ts
import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { immer } from 'zustand/middleware/immer';

// Types
interface Task {
  id: string;
  title: string;
  completed: boolean;
  createdAt: Date;
}

interface User {
  id: string;
  name: string;
  email: string;
  avatar?: string;
}

interface MobileStore {
  // State
  user: User | null;
  tasks: Record<string, Task>;
  taskIds: string[];
  isLoading: boolean;
  error: string | null;
  isAuthenticated: boolean;
  theme: 'light' | 'dark';
  
  // Actions
  login: (email: string, password: string) => Promise<void>;
  logout: () => void;
  addTask: (title: string) => void;
  toggleTask: (id: string) => void;
  deleteTask: (id: string) => void;
  clearTasks: () => void;
  setTheme: (theme: 'light' | 'dark') => void;
  setError: (error: string | null) => void;
  clearError: () => void;
}

// Create the store with persistence
export const useMobileStore = create<MobileStore>()(
  persist(
    immer((set, get) => ({
      // Initial state
      user: null,
      tasks: {},
      taskIds: [],
      isLoading: false,
      error: null,
      isAuthenticated: false,
      theme: 'light',

      // --- Authentication ---
      login: async (email: string, password: string) => {
        set({ isLoading: true, error: null });
        try {
          // Simulate API call
          await new Promise(resolve => setTimeout(resolve, 1000));
          
          // Mock user
          const user: User = {
            id: 'user-1',
            name: 'John Doe',
            email,
          };
          
          set({
            user,
            isAuthenticated: true,
            isLoading: false,
          });
        } catch (error) {
          set({
            isLoading: false,
            error: error instanceof Error ? error.message : 'Login failed',
          });
        }
      },

      logout: () => {
        set({
          user: null,
          isAuthenticated: false,
          tasks: {},
          taskIds: [],
        });
      },

      // --- Task Operations ---
      addTask: (title: string) => {
        set((state) => {
          const id = `task-${Date.now()}`;
          state.tasks[id] = {
            id,
            title,
            completed: false,
            createdAt: new Date(),
          };
          state.taskIds.push(id);
        });
      },

      toggleTask: (id: string) => {
        set((state) => {
          const task = state.tasks[id];
          if (task) {
            task.completed = !task.completed;
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
        });
      },

      clearTasks: () => {
        set({ tasks: {}, taskIds: [] });
      },

      // --- UI Settings ---
      setTheme: (theme: 'light' | 'dark') => {
        set({ theme });
      },

      setError: (error: string | null) => {
        set({ error });
      },

      clearError: () => {
        set({ error: null });
      },
    })),
    {
      name: 'mobile-storage',
      storage: createJSONStorage(() => AsyncStorage),
      // Only persist these fields
      partialize: (state) => ({
        user: state.user,
        isAuthenticated: state.isAuthenticated,
        theme: state.theme,
        tasks: state.tasks,
        taskIds: state.taskIds,
        // Don't persist: isLoading, error
      }),
    }
  )
);
```

### Step 3: Fast Storage with MMKV

For better performance, use MMKV instead of AsyncStorage:

```typescript
// src/store/mmkvStore.ts
import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';
import { MMKV } from 'react-native-mmkv';
import { immer } from 'zustand/middleware/immer';

// Create MMKV instance
const mmkv = new MMKV({
  id: 'zustand-storage',
  encryptionKey: 'your-encryption-key', // Optional
});

// Custom storage adapter for MMKV
const mmkvStorage = {
  getItem: (key: string) => {
    const value = mmkv.getString(key);
    return value || null;
  },
  setItem: (key: string, value: string) => {
    mmkv.set(key, value);
  },
  removeItem: (key: string) => {
    mmkv.delete(key);
  },
};

// Store with MMKV persistence
export const useMMKVStore = create<any>()(
  persist(
    immer((set) => ({
      // ... same state as above
    })),
    {
      name: 'mmkv-storage',
      storage: createJSONStorage(() => mmkvStorage),
    }
  )
);
```

### Step 4: Secure Storage for Tokens

Store sensitive data (tokens, passwords) securely:

```typescript
// src/store/secureStore.ts
import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';
import * as Keychain from 'react-native-keychain';
import { immer } from 'zustand/middleware/immer';

// Secure storage adapter using Keychain
const secureStorage = {
  getItem: async (key: string) => {
    try {
      const credentials = await Keychain.getInternetCredentials(key);
      return credentials ? credentials.password : null;
    } catch (error) {
      console.error('Secure storage read error:', error);
      return null;
    }
  },
  setItem: async (key: string, value: string) => {
    try {
      await Keychain.setInternetCredentials(key, 'token', value);
    } catch (error) {
      console.error('Secure storage write error:', error);
    }
  },
  removeItem: async (key: string) => {
    try {
      await Keychain.resetInternetCredentials(key);
    } catch (error) {
      console.error('Secure storage delete error:', error);
    }
  },
};

interface SecureStore {
  token: string | null;
  refreshToken: string | null;
  userId: string | null;
  
  setTokens: (token: string, refreshToken: string, userId: string) => void;
  clearTokens: () => void;
  getToken: () => string | null;
}

export const useSecureStore = create<SecureStore>()(
  persist(
    immer((set, get) => ({
      token: null,
      refreshToken: null,
      userId: null,

      setTokens: (token: string, refreshToken: string, userId: string) => {
        set({ token, refreshToken, userId });
      },

      clearTokens: () => {
        set({ token: null, refreshToken: null, userId: null });
      },

      getToken: () => {
        return get().token;
      },
    })),
    {
      name: 'secure-storage',
      storage: createJSONStorage(() => secureStorage),
    }
  )
);
```

### Step 5: Integrating with React Navigation

Sync navigation state with Zustand for tab/window state management:

```typescript
// src/navigation/NavigationState.ts
import { create } from 'zustand';
import { immer } from 'zustand/middleware/immer';
import { NavigationState } from '@react-navigation/native';

interface NavStore {
  currentRoute: string;
  previousRoute: string | null;
  navigationState: NavigationState | null;
  isReady: boolean;
  
  setCurrentRoute: (route: string) => void;
  setNavigationState: (state: NavigationState) => void;
  setReady: (ready: boolean) => void;
  goBack: () => void;
}

export const useNavStore = create<NavStore>()(
  immer((set, get) => ({
    currentRoute: 'Home',
    previousRoute: null,
    navigationState: null,
    isReady: false,

    setCurrentRoute: (route: string) => {
      set((state) => {
        state.previousRoute = state.currentRoute;
        state.currentRoute = route;
      });
    },

    setNavigationState: (state: NavigationState) => {
      set({ navigationState: state });
    },

    setReady: (isReady: boolean) => {
      set({ isReady });
    },

    goBack: () => {
      const previous = get().previousRoute;
      if (previous) {
        set({ currentRoute: previous });
        // In a real app, you'd navigate back
      }
    },
  }))
);

// In your navigation container
import { NavigationContainer } from '@react-navigation/native';
import { useNavStore } from '../store/NavigationState';

function AppNavigator() {
  const setCurrentRoute = useNavStore((state) => state.setCurrentRoute);
  const setNavigationState = useNavStore((state) => state.setNavigationState);
  const setReady = useNavStore((state) => state.setReady);

  return (
    <NavigationContainer
      onStateChange={(state) => {
        if (state) {
          setNavigationState(state);
          const route = state.routes[state.index];
          if (route) {
            setCurrentRoute(route.name);
          }
        }
      }}
      onReady={() => setReady(true)}
    >
      {/* Your navigators */}
    </NavigationContainer>
  );
}
```

### Step 6: Offline‑First Patterns

Implement offline queue and background sync:

```typescript
// src/store/offlineStore.ts
import { create } from 'zustand';
import { immer } from 'zustand/middleware/immer';
import AsyncStorage from '@react-native-async-storage/async-storage';
import NetInfo from '@react-native-community/netinfo';

interface QueuedAction {
  id: string;
  type: 'add' | 'update' | 'delete';
  payload: any;
  timestamp: number;
  retries: number;
}

interface OfflineStore {
  isOnline: boolean;
  queue: QueuedAction[];
  isSyncing: boolean;
  lastSync: Date | null;
  
  setOnlineStatus: (online: boolean) => void;
  queueAction: (action: Omit<QueuedAction, 'id' | 'timestamp' | 'retries'>) => void;
  syncQueue: () => Promise<void>;
  clearQueue: () => void;
  retryAction: (id: string) => void;
}

export const useOfflineStore = create<OfflineStore>()(
  immer((set, get) => ({
    isOnline: true,
    queue: [],
    isSyncing: false,
    lastSync: null,

    setOnlineStatus: (isOnline: boolean) => {
      set({ isOnline });
      // If we come back online, sync
      if (isOnline && get().queue.length > 0) {
        get().syncQueue();
      }
    },

    queueAction: (action) => {
      set((state) => {
        state.queue.push({
          ...action,
          id: `action-${Date.now()}-${Math.random().toString(36).slice(2, 7)}`,
          timestamp: Date.now(),
          retries: 0,
        });
      });
      
      // If online, sync immediately
      if (get().isOnline) {
        get().syncQueue();
      }
    },

    syncQueue: async () => {
      const state = get();
      if (state.isSyncing || state.queue.length === 0 || !state.isOnline) {
        return;
      }

      set({ isSyncing: true });

      let failedActions: QueuedAction[] = [];

      for (const action of state.queue) {
        try {
          // Execute action
          switch (action.type) {
            case 'add':
              await fetch('/api/tasks', {
                method: 'POST',
                body: JSON.stringify(action.payload),
              });
              break;
            case 'update':
              await fetch(`/api/tasks/${action.payload.id}`, {
                method: 'PUT',
                body: JSON.stringify(action.payload),
              });
              break;
            case 'delete':
              await fetch(`/api/tasks/${action.payload.id}`, {
                method: 'DELETE',
              });
              break;
          }
        } catch (error) {
          console.error('Sync failed:', error);
          action.retries++;
          if (action.retries < 3) {
            failedActions.push(action);
          }
          // If retries exceeded, drop the action
        }
      }

      set((state) => {
        // Keep failed actions for retry
        state.queue = failedActions;
        state.isSyncing = false;
        state.lastSync = new Date();
      });

      // If there are still items, try again later
      if (failedActions.length > 0) {
        setTimeout(() => {
          get().syncQueue();
        }, 5000);
      }
    },

    clearQueue: () => {
      set({ queue: [] });
    },

    retryAction: (id: string) => {
      set((state) => {
        const action = state.queue.find(a => a.id === id);
        if (action) {
          action.retries = 0;
        }
      });
      get().syncQueue();
    },
  }))
);

// Setup network listener
NetInfo.addEventListener((state) => {
  useOfflineStore.getState().setOnlineStatus(state.isConnected ?? false);
});
```

### Step 7: Performance Optimization for Mobile

Reduce re-renders and optimize for mobile:

```tsx
// src/components/TaskItem.tsx
import React, { memo } from 'react';
import { View, Text, TouchableOpacity, StyleSheet } from 'react-native';
import { useMobileStore } from '../store/mobileStore';

// Memoized component - only re-renders when THIS task changes
const TaskItem = memo(({ taskId }: { taskId: string }) => {
  // Subscribe only to this task
  const task = useMobileStore((state) => state.tasks[taskId]);
  const toggleTask = useMobileStore((state) => state.toggleTask);
  const deleteTask = useMobileStore((state) => state.deleteTask);

  if (!task) return null;

  return (
    <View style={styles.container}>
      <TouchableOpacity
        onPress={() => toggleTask(task.id)}
        style={styles.checkbox}
      >
        <View style={[styles.checkboxInner, task.completed && styles.checked]} />
      </TouchableOpacity>
      <Text style={[styles.title, task.completed && styles.completed]}>
        {task.title}
      </Text>
      <TouchableOpacity onPress={() => deleteTask(task.id)} style={styles.delete}>
        <Text>×</Text>
      </TouchableOpacity>
    </View>
  );
});

const styles = StyleSheet.create({
  container: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: 12,
    backgroundColor: '#fff',
    marginBottom: 8,
    borderRadius: 8,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.1,
    shadowRadius: 2,
    elevation: 2,
  },
  checkbox: {
    width: 24,
    height: 24,
    borderRadius: 12,
    borderWidth: 2,
    borderColor: '#007AFF',
    justifyContent: 'center',
    alignItems: 'center',
  },
  checkboxInner: {
    width: 12,
    height: 12,
    borderRadius: 6,
    backgroundColor: 'transparent',
  },
  checked: {
    backgroundColor: '#007AFF',
  },
  title: {
    flex: 1,
    marginLeft: 12,
    fontSize: 16,
    color: '#000',
  },
  completed: {
    textDecorationLine: 'line-through',
    color: '#999',
  },
  delete: {
    padding: 8,
    marginLeft: 8,
  },
});

export default TaskItem;
```

### Step 8: Animations with Zustand and Reanimated

Sync Zustand state with Reanimated animations:

```tsx
// src/components/AnimatedTaskItem.tsx
import React, { useMemo } from 'react';
import { View, Text, TouchableOpacity, StyleSheet } from 'react-native';
import Animated, {
  useAnimatedStyle,
  useSharedValue,
  withSpring,
  withTiming,
  runOnJS,
} from 'react-native-reanimated';
import { useMobileStore } from '../store/mobileStore';

const AnimatedTaskItem = ({ taskId }: { taskId: string }) => {
  const task = useMobileStore((state) => state.tasks[taskId]);
  const toggleTask = useMobileStore((state) => state.toggleTask);
  const deleteTask = useMobileStore((state) => state.deleteTask);

  // Animation values
  const opacity = useSharedValue(1);
  const scale = useSharedValue(1);
  const rotate = useSharedValue('0deg');

  // Animated styles
  const animatedStyle = useAnimatedStyle(() => ({
    opacity: opacity.value,
    transform: [{ scale: scale.value }, { rotate: rotate.value }],
  }));

  const handleDelete = () => {
    // Animate out
    scale.value = withSpring(0);
    opacity.value = withTiming(0, { duration: 300 });
    
    // Delete after animation
    setTimeout(() => {
      deleteTask(taskId);
    }, 300);
  };

  const handleToggle = () => {
    // Animate toggle
    rotate.value = withSpring('360deg');
    toggleTask(taskId);
    // Reset rotation after animation
    setTimeout(() => {
      rotate.value = withTiming('0deg');
    }, 500);
  };

  if (!task) return null;

  return (
    <Animated.View style={[styles.container, animatedStyle]}>
      <TouchableOpacity onPress={handleToggle} style={styles.checkbox}>
        <View style={[styles.checkboxInner, task.completed && styles.checked]} />
      </TouchableOpacity>
      <Text style={[styles.title, task.completed && styles.completed]}>
        {task.title}
      </Text>
      <TouchableOpacity onPress={handleDelete} style={styles.delete}>
        <Text style={styles.deleteText}>×</Text>
      </TouchableOpacity>
    </Animated.View>
  );
};

const styles = StyleSheet.create({
  container: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: 12,
    backgroundColor: '#fff',
    marginBottom: 8,
    borderRadius: 8,
  },
  // ... same styles as above
});

export default AnimatedTaskItem;
```

### Step 9: Error Handling with Toast Messages

Implement toast notifications for mobile:

```tsx
// src/components/ToastManager.tsx
import React, { useEffect } from 'react';
import { View, Text, StyleSheet, TouchableOpacity } from 'react-native';
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withSpring,
  withTiming,
} from 'react-native-reanimated';
import { useMobileStore } from '../store/mobileStore';

interface Toast {
  id: string;
  message: string;
  type: 'success' | 'error' | 'warning';
  duration?: number;
}

interface ToastStore {
  toasts: Toast[];
  addToast: (toast: Omit<Toast, 'id'>) => void;
  removeToast: (id: string) => void;
}

export const useToastStore = create<ToastStore>()(
  immer((set) => ({
    toasts: [],
    addToast: (toast) => {
      const id = `toast-${Date.now()}`;
      set((state) => {
        state.toasts.push({ ...toast, id });
      });
      setTimeout(() => {
        set((state) => {
          const index = state.toasts.findIndex(t => t.id === id);
          if (index !== -1) {
            state.toasts.splice(index, 1);
          }
        });
      }, toast.duration || 3000);
    },
    removeToast: (id) => {
      set((state) => {
        const index = state.toasts.findIndex(t => t.id === id);
        if (index !== -1) {
          state.toasts.splice(index, 1);
        }
      });
    },
  }))
);

// Toast component
function ToastMessage({ toast, onDismiss }: { toast: Toast; onDismiss: () => void }) {
  const translateY = useSharedValue(-100);
  const opacity = useSharedValue(0);

  useEffect(() => {
    translateY.value = withSpring(0);
    opacity.value = withTiming(1);
    
    const timer = setTimeout(() => {
      translateY.value = withSpring(-100);
      opacity.value = withTiming(0, { duration: 300 }, () => {
        runOnJS(onDismiss)();
      });
    }, toast.duration || 3000);

    return () => clearTimeout(timer);
  }, []);

  const animatedStyle = useAnimatedStyle(() => ({
    transform: [{ translateY: translateY.value }],
    opacity: opacity.value,
  }));

  const getColor = () => {
    switch (toast.type) {
      case 'success': return '#4CAF50';
      case 'error': return '#F44336';
      case 'warning': return '#FF9800';
      default: return '#2196F3';
    }
  };

  return (
    <Animated.View style={[styles.toastContainer, animatedStyle]}>
      <View style={[styles.toastContent, { borderLeftColor: getColor() }]}>
        <Text style={styles.toastMessage}>{toast.message}</Text>
        <TouchableOpacity onPress={onDismiss} style={styles.toastDismiss}>
          <Text style={styles.dismissText}>×</Text>
        </TouchableOpacity>
      </View>
    </Animated.View>
  );
}

export function ToastManager() {
  const toasts = useToastStore((state) => state.toasts);
  const removeToast = useToastStore((state) => state.removeToast);

  if (toasts.length === 0) return null;

  return (
    <View style={styles.container}>
      {toasts.map(toast => (
        <ToastMessage
          key={toast.id}
          toast={toast}
          onDismiss={() => removeToast(toast.id)}
        />
      ))}
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    position: 'absolute',
    top: 50,
    left: 16,
    right: 16,
    zIndex: 1000,
  },
  toastContainer: {
    marginBottom: 8,
  },
  toastContent: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#fff',
    padding: 12,
    borderRadius: 8,
    borderLeftWidth: 4,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 4,
  },
  toastMessage: {
    flex: 1,
    fontSize: 14,
    color: '#333',
  },
  toastDismiss: {
    padding: 4,
    marginLeft: 8,
  },
  dismissText: {
    fontSize: 20,
    color: '#999',
    fontWeight: 'bold',
  },
});
```

---

## The Verification: Testing React Native Integration

### Step 1: Run the App

```bash
# iOS
npx react-native run-ios

# Android
npx react-native run-android

# Expo
npx expo start
```

### Step 2: Test Persistence

1. Add a task
2. Close and reopen the app
3. Task should still be there ✅

### Step 3: Test Offline Mode

1. Disable internet (Airplane mode)
2. Add a task (should be queued)
3. Re-enable internet
4. Queue should sync ✅

### Step 4: Test Navigation

1. Navigate between screens
2. Check that nav store updates correctly
3. Go back and verify previous route ✅

### Step 5: Test Secure Storage

1. Login (stores token securely)
2. Close and reopen app
3. User should still be logged in ✅

### Step 6: Performance Test

1. Add 1000 tasks
2. Open React DevTools (via Flipper)
3. Check render count and performance
4. Should be smooth ✅

---

## Deep Dive: Mobile Performance

### Reducing Bridge Traffic

Zustand's fine‑grained subscriptions minimize JavaScript-Native bridge traffic:

```tsx
// ✅ GOOD: Minimal bridge traffic
const taskCount = useMobileStore((state) => state.taskIds.length);
// Only sends updates when task count changes

// ❌ BAD: Heavy bridge traffic
const store = useMobileStore();
// Sends the entire store across the bridge on every change
```

### Animations and State

Use Reanimated's `useAnimatedReaction` to sync Zustand state with animations:

```tsx
import { useAnimatedReaction } from 'react-native-reanimated';

function AnimatedCounter() {
  const count = useMobileStore((state) => state.taskIds.length);
  const animatedCount = useSharedValue(count);

  useAnimatedReaction(
    () => count,
    (next, previous) => {
      if (next !== previous) {
        animatedCount.value = withSpring(next);
      }
    }
  );

  // Use animatedCount.value in your animations
}
```

---

## Common Pitfalls and Solutions

### Pitfall 1: Using AsyncStorage Synchronously

```typescript
// ❌ BAD: AsyncStorage is async
const store = create((set) => ({
  data: AsyncStorage.getItem('data'), // ❌ Returns Promise
}));

// ✅ GOOD: Use persist middleware
const store = create(persist((set) => ({
  data: [],
}), { name: 'data' }));
```

### Pitfall 2: Not Handling Offline Gracefully

```typescript
// ❌ BAD: No offline handling
const addTask = (title) => {
  fetch('/api/tasks', { ... }); // Fails offline
  set((state) => ({ tasks: [...state.tasks, newTask] }));
};

// ✅ GOOD: Offline-aware
const addTask = (title) => {
  set((state) => ({ tasks: [...state.tasks, newTask] }));
  if (isOnline) {
    // Sync online
  } else {
    // Queue for later
    queueAction({ type: 'add', payload: { title } });
  }
};
```

### Pitfall 3: Not Memoizing List Items

```tsx
// ❌ BAD: Every item re-renders on any change
function TaskList() {
  const tasks = useMobileStore((state) => state.taskIds);
  return tasks.map(id => <TaskItem key={id} taskId={id} />);
}

// ✅ GOOD: Memoize items
const MemoizedTaskItem = memo(TaskItem);
function TaskList() {
  const tasks = useMobileStore((state) => state.taskIds);
  return tasks.map(id => <MemoizedTaskItem key={id} taskId={id} />);
}
```

---

## Key Takeaways

1. **AsyncStorage** is the default persistence for React Native
2. **MMKV** provides faster performance for large datasets
3. **SecureStore** (Keychain) for tokens and sensitive data
4. **Offline queue** enables offline‑first experiences
5. **Navigation state** can be managed with Zustand
6. **Memoization** is critical for list performance on mobile
7. **Reanimated** integrates seamlessly with Zustand for smooth animations
8. **Toast/error handling** improves user experience
9. **Bridge traffic** should be minimized by using selectors
10. **Testing** should include offline and online scenarios

---

## What's Next

You've built mobile‑ready Zustand stores. Next, you'll learn how to use Zustand with Next.js 16 for server‑side rendering and advanced routing.
