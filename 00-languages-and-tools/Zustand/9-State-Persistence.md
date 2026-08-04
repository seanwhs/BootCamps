# Part 2 — Advanced State Architecture

## Section 9: State Persistence

You've built a powerful application with Zustand. But what happens when a user refreshes the page or closes the browser? Everything resets. That's where **state persistence** comes in. Persistence allows you to save application state to storage (like `localStorage` or `IndexedDB`) and restore it when the user returns, creating a seamless experience.

---

## The Target: Reliable State Persistence

By the end of this section, you'll be able to:
- Use the `persist` middleware to save and restore state
- Implement custom storage adapters for different environments
- Control what gets persisted with partial persistence
- Handle versioning and data migrations
- Understand the hydration lifecycle
- Manage persistence in React Native and Next.js

---

## The Concept: Persistence as a Time Capsule

Think of persistence like a **save game** system in a video game:

```
┌─────────────────────────────────────────────────────────────────┐
│                    PERSISTENCE LIFECYCLE                       │
│                                                                 │
│  1. User opens app   ───▶   Check saved state                  │
│         │                        │                             │
│         ▼                        ▼                             │
│  2. Zustand store    ───▶   Hydrate (load) saved state         │
│     initializes                                               │
│         │                        │                             │
│         ▼                        ▼                             │
│  3. User interacts   ───▶   State updates                     │
│     with app                                                  │
│         │                        │                             │
│         ▼                        ▼                             │
│  4. Zustand state   ───▶   Persist (save) to storage          │
│     changes                                                   │
│         │                        │                             │
│         ▼                        ▼                             │
│  5. User closes   ───▶   State safely saved                   │
│     browser                                                   │
│                                                                 │
│  Next visit: User returns, state is restored exactly where     │
│  they left off!                                               │
└─────────────────────────────────────────────────────────────────┘
```

### Key Concepts

1. **Persistence**: Saving state to a storage medium
2. **Hydration**: Loading saved state back into the store
3. **Storage Adapter**: The interface between Zustand and the storage medium
4. **Migration**: Transforming old state formats to new ones when the schema changes
5. **Partial Persistence**: Persisting only specific parts of the state

---

## The Implementation: Persist Middleware

### Step 1: Basic Persistence

Let's start with the simplest persistence setup:

```typescript
// src/store/basicPersist.ts
import { create } from 'zustand';
import { persist } from 'zustand/middleware';

interface SettingsStore {
  theme: 'light' | 'dark';
  language: string;
  notifications: boolean;
  setTheme: (theme: 'light' | 'dark') => void;
  setLanguage: (language: string) => void;
  toggleNotifications: () => void;
}

export const useSettingsStore = create<SettingsStore>()(
  persist(
    (set) => ({
      theme: 'light',
      language: 'en-US',
      notifications: true,
      setTheme: (theme) => set({ theme }),
      setLanguage: (language) => set({ language }),
      toggleNotifications: () => 
        set((state) => ({ notifications: !state.notifications })),
    }),
    {
      name: 'settings-storage', // Unique key in localStorage
    }
  )
);

// Usage: Settings will automatically be saved and restored
// Refresh the page - your theme and language persist!
```

### Step 2: Advanced Persistence with Partial State

Not all state should be persisted. For example, transient state (loading, errors, ephemeral UI state) should not be saved:

```typescript
// src/store/partialPersist.ts
import { create } from 'zustand';
import { persist } from 'zustand/middleware';

interface AppStore {
  // Persisted state
  user: { id: string; name: string } | null;
  theme: 'light' | 'dark';
  preferences: { language: string; timezone: string };
  
  // Non-persisted state
  isLoading: boolean;
  error: string | null;
  selectedTaskId: string | null;
  
  // Actions
  login: (user: { id: string; name: string }) => void;
  logout: () => void;
  setTheme: (theme: 'light' | 'dark') => void;
  setPreferences: (prefs: Partial<{ language: string; timezone: string }>) => void;
  setLoading: (loading: boolean) => void;
  setError: (error: string | null) => void;
  selectTask: (id: string | null) => void;
}

export const useAppStore = create<AppStore>()(
  persist(
    (set) => ({
      // Initial state
      user: null,
      theme: 'light',
      preferences: { language: 'en-US', timezone: 'UTC' },
      isLoading: false,
      error: null,
      selectedTaskId: null,

      // Actions
      login: (user) => set({ user }),
      logout: () => set({ user: null }),
      setTheme: (theme) => set({ theme }),
      setPreferences: (prefs) => 
        set((state) => ({ 
          preferences: { ...state.preferences, ...prefs } 
        })),
      setLoading: (isLoading) => set({ isLoading }),
      setError: (error) => set({ error }),
      selectTask: (selectedTaskId) => set({ selectedTaskId }),
    }),
    {
      name: 'app-storage',
      // Only persist these fields
      partialize: (state) => ({
        user: state.user,
        theme: state.theme,
        preferences: state.preferences,
        // isLoading, error, selectedTaskId are NOT persisted
      }),
    }
  )
);
```

### Step 3: Custom Storage Adapters

Zustand supports different storage backends through adapters:

```typescript
// src/store/customStorage.ts
import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';

// 1. Session Storage (cleared when tab is closed)
export const useSessionStore = create<any>()(
  persist(
    (set) => ({
      data: {},
      setData: (data) => set({ data }),
    }),
    {
      name: 'session-storage',
      storage: createJSONStorage(() => sessionStorage),
    }
  )
);

// 2. Custom storage adapter for IndexedDB
import { get, set, del } from 'idb-keyval';

const indexedDBStorage = {
  getItem: async (key: string) => {
    const value = await get(key);
    return value || null;
  },
  setItem: async (key: string, value: any) => {
    await set(key, value);
  },
  removeItem: async (key: string) => {
    await del(key);
  },
};

export const useIndexedDBStore = create<any>()(
  persist(
    (set) => ({
      data: {},
      setData: (data) => set({ data }),
    }),
    {
      name: 'indexeddb-storage',
      storage: indexedDBStorage,
    }
  )
);

// 3. Cookie storage (for server-side compatibility)
// Note: Cookies have size limits (~4KB)
const cookieStorage = {
  getItem: (key: string) => {
    const cookies = document.cookie.split('; ').reduce((acc, cookie) => {
      const [name, value] = cookie.split('=');
      acc[name] = value;
      return acc;
    }, {} as Record<string, string>);
    return cookies[key] || null;
  },
  setItem: (key: string, value: string) => {
    document.cookie = `${key}=${value}; path=/; max-age=31536000`; // 1 year
  },
  removeItem: (key: string) => {
    document.cookie = `${key}=; path=/; max-age=0`;
  },
};

export const useCookieStore = create<any>()(
  persist(
    (set) => ({
      data: {},
      setData: (data) => set({ data }),
    }),
    {
      name: 'cookie-storage',
      storage: cookieStorage,
    }
  )
);
```

### Step 4: Versioning and Migrations

When your app evolves, your state schema will change. Versioning and migrations ensure smooth transitions:

```typescript
// src/store/migrations.ts
import { create } from 'zustand';
import { persist } from 'zustand/middleware';

interface V0State {
  tasks: string[];
  theme: string;
  user: { name: string };
}

interface V1State {
  tasks: { id: string; text: string; completed: boolean }[];
  theme: 'light' | 'dark';
  user: { name: string; email: string };
}

interface V2State {
  tasks: { id: string; text: string; completed: boolean; priority: 'low' | 'high' }[];
  theme: 'light' | 'dark';
  user: { name: string; email: string; preferences: { notifications: boolean } };
}

const useMigratedStore = create<any>()(
  persist(
    (set) => ({
      tasks: [],
      theme: 'light',
      user: { name: '', email: '', preferences: { notifications: true } },
      // ... actions
    }),
    {
      name: 'migrated-storage',
      version: 2, // Current version
      migrate: (persistedState, version) => {
        // Version 0 -> Version 1
        if (version === 0) {
          const oldState = persistedState as V0State;
          return {
            tasks: oldState.tasks.map((text, index) => ({
              id: `task-${index}`,
              text,
              completed: false,
            })),
            theme: oldState.theme === 'dark' ? 'dark' : 'light',
            user: { ...oldState.user, email: '' },
          };
        }
        
        // Version 1 -> Version 2
        if (version === 1) {
          const oldState = persistedState as V1State;
          return {
            ...oldState,
            tasks: oldState.tasks.map((task) => ({
              ...task,
              priority: 'low' as const,
            })),
            user: {
              ...oldState.user,
              preferences: { notifications: true },
            },
          };
        }
        
        return persistedState as V2State;
      },
    }
  )
);
```

### Step 5: Handling Hydration

Hydration is the process of loading persisted state into the store. You can listen to hydration events:

```typescript
// src/store/hydration.ts
import { create } from 'zustand';
import { persist } from 'zustand/middleware';

interface HydrationStore {
  data: any[];
  isHydrated: boolean;
  setData: (data: any[]) => void;
  markHydrated: () => void;
}

export const useHydrationStore = create<HydrationStore>()(
  persist(
    (set) => ({
      data: [],
      isHydrated: false,
      setData: (data) => set({ data }),
      markHydrated: () => set({ isHydrated: true }),
    }),
    {
      name: 'hydration-storage',
      onRehydrateStorage: () => (state, error) => {
        if (error) {
          console.error('❌ Hydration failed:', error);
        } else {
          console.log('✅ Hydration successful:', state);
          // Optionally, perform actions after hydration
          if (state) {
            // We can call a method to mark hydration complete
            // But we can't use the store's actions directly here
            // Instead, we can use a separate mechanism
          }
        }
      },
    }
  )
);

// React component to check hydration status
// In your app, you can use: const isHydrated = useHydrationStore((state) => state.isHydrated);
// But note: `isHydrated` won't be set automatically; you need to set it yourself.
// Better approach: Use a custom hook that checks hydration
```

### Step 6: Hydration-Aware Components

In React, you often want to wait for hydration before rendering:

```tsx
// src/components/HydrationAware.tsx
import React, { useEffect, useState } from 'react';
import { useHydrationStore } from '../store/hydration';

// Custom hook to check if store has hydrated
function useStoreHydration() {
  const [hydrated, setHydrated] = useState(false);
  
  useEffect(() => {
    // Check if store has state
    const state = useHydrationStore.getState();
    // If data exists, consider hydrated
    if (state.data.length > 0) {
      setHydrated(true);
    }
    
    // Subscribe to future hydration
    const unsubscribe = useHydrationStore.subscribe((state) => {
      if (state.data.length > 0) {
        setHydrated(true);
      }
    });
    
    return unsubscribe;
  }, []);
  
  return hydrated;
}

// Component that waits for hydration
function HydrationAwareComponent() {
  const isHydrated = useStoreHydration();
  const data = useHydrationStore((state) => state.data);
  
  if (!isHydrated) {
    return <div>Loading saved state...</div>;
  }
  
  return (
    <div>
      <h2>Hydrated State</h2>
      <pre>{JSON.stringify(data, null, 2)}</pre>
    </div>
  );
}

export default HydrationAwareComponent;
```

### Step 7: Persistence with React Native

In React Native, you'll use `AsyncStorage` or `MMKV`:

```typescript
// src/store/reactNativePersist.ts
import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';
import AsyncStorage from '@react-native-async-storage/async-storage';

// For React Native
export const useNativeStore = create<any>()(
  persist(
    (set) => ({
      user: null,
      tasks: [],
      setUser: (user) => set({ user }),
      addTask: (task) => set((state) => ({ tasks: [...state.tasks, task] })),
    }),
    {
      name: 'app-storage',
      storage: createJSONStorage(() => AsyncStorage),
    }
  )
);

// For MMKV (faster, synchronous)
// import { MMKV } from 'react-native-mmkv';
// const mmkv = new MMKV();
// 
// const mmkvStorage = {
//   getItem: (key: string) => {
//     const value = mmkv.getString(key);
//     return value || null;
//   },
//   setItem: (key: string, value: string) => {
//     mmkv.set(key, value);
//   },
//   removeItem: (key: string) => {
//     mmkv.delete(key);
//   },
// };
// 
// export const useMMKVStore = create<any>()(
//   persist(
//     (set) => ({ /* ... */ }),
//     {
//       name: 'mmkv-storage',
//       storage: mmkvStorage,
//     }
//   )
// );
```

### Step 8: Persistence in Next.js (Server-Side Rendering)

In Next.js, hydration must be handled carefully because the server and client have different environments:

```typescript
// src/store/nextjsPersist.ts
import { create } from 'zustand';
import { persist } from 'zustand/middleware';

// Since localStorage is not available on the server,
// we need to conditionally use it only on the client
const isClient = typeof window !== 'undefined';

export const useNextJsStore = create<any>()(
  persist(
    (set) => ({
      data: [],
      setData: (data) => set({ data }),
    }),
    {
      name: 'nextjs-storage',
      // Only use storage on the client
      storage: isClient 
        ? localStorage 
        : {
            getItem: () => null,
            setItem: () => {},
            removeItem: () => {},
          },
    }
  )
);

// In Next.js, you may also use a custom hook that prevents hydration mismatch
export function useNextJsStoreHydrated() {
  const [hydrated, setHydrated] = React.useState(false);
  
  React.useEffect(() => {
    setHydrated(true);
  }, []);
  
  const store = useNextJsStore((state) => state);
  
  // On server, return empty state
  // On client, return hydrated state
  return hydrated ? store : { data: [], setData: () => {} };
}
```

---

## The Verification: Testing Persistence

### Step 1: Test Basic Persistence

```typescript
// src/tests/persistence.test.ts
import { useSettingsStore } from '../store/basicPersist';

function testPersistence() {
  console.log('=== Testing Persistence ===');
  
  // Set some values
  const store = useSettingsStore.getState();
  store.setTheme('dark');
  store.setLanguage('es-ES');
  store.toggleNotifications();
  
  console.log('State set:', useSettingsStore.getState());
  
  // Simulate page reload by clearing and rehydrating
  localStorage.removeItem('settings-storage');
  // Re-initialize store - would normally happen on reload
  // In a real test, we'd re-import the store
}

// To test persistence manually:
// 1. Open the app, change settings
// 2. Refresh the page
// 3. Check if settings persist
```

### Step 2: Test Migrations

```typescript
// src/tests/migration.test.ts
import { useMigratedStore } from '../store/migrations';

function testMigration() {
  // Simulate old version 0 state
  const oldState = {
    tasks: ['Task 1', 'Task 2'],
    theme: 'dark',
    user: { name: 'Alice' },
  };
  
  // Manually set old state in storage
  localStorage.setItem('migrated-storage', JSON.stringify({
    state: oldState,
    version: 0,
  }));
  
  // Re-initialize store - migration should run
  // In a real test, we'd re-import the store and check the state
  
  console.log('Migration test: Old state should be migrated to version 2');
  // Expected: tasks become objects with id, text, completed, priority
  // Expected: theme becomes 'dark' (string)
  // Expected: user gets email and preferences
}
```

### Step 3: Browser Console Test

Open your browser console and run:

```javascript
// Test persistence manually
import { useSettingsStore } from './src/store/basicPersist';

// Set values
useSettingsStore.getState().setTheme('dark');
useSettingsStore.getState().setLanguage('fr-FR');
console.log('State saved:', useSettingsStore.getState());

// Check localStorage
console.log('localStorage entry:', localStorage.getItem('settings-storage'));

// Refresh the page, then check if state is restored
console.log('After refresh:', useSettingsStore.getState());
```

---

## Deep Dive: Persist Middleware Internals

```typescript
// Simplified persist middleware implementation
function persist(config, options) {
  const { name, storage, partialize, version, migrate, onRehydrateStorage } = options;
  
  return (set, get, store) => {
    // Load initial state from storage
    const persistedState = storage.getItem(name);
    
    let initialState = config(set, get, store);
    
    if (persistedState) {
      try {
        let state = JSON.parse(persistedState);
        // Apply migration if needed
        if (state.version !== version) {
          state = migrate(state.state, state.version);
        }
        // Merge with initial state (partial persistence)
        initialState = { ...initialState, ...partialize?.(state) };
      } catch (error) {
        console.error('Failed to hydrate state:', error);
        onRehydrateStorage?.()(null, error);
      }
    }
    
    const wrappedSet = (args) => {
      set(args);
      // Persist on every update
      const currentState = get();
      const toPersist = partialize ? partialize(currentState) : currentState;
      storage.setItem(name, JSON.stringify({
        state: toPersist,
        version,
      }));
    };
    
    // Return store with wrapped set
    return config(wrappedSet, get, store);
  };
}
```

---

## Common Pitfalls and Solutions

### Pitfall 1: Persisting Non-Serializable Data

```typescript
// ❌ WRONG: Persisting Date objects
persist(
  (set) => ({
    createdAt: new Date(), // Not serializable
  }),
  { name: 'storage' }
);
// Error: Data cloning issue

// ✅ CORRECT: Store timestamp and convert
persist(
  (set) => ({
    createdAt: Date.now(), // Number (serializable)
    // Or use ISO string
    createdAtISO: new Date().toISOString(),
  }),
  { name: 'storage' }
);
```

### Pitfall 2: Persisting Too Much Data

```typescript
// ❌ BAD: Persisting everything (including large data)
const store = create(persist(
  (set) => ({
    user: { ... },
    tasks: [1000 tasks],
    largeCache: { /* huge object */ },
    // All persisted -> performance issues, storage limit
  }),
  { name: 'storage' }
));

// ✅ GOOD: Persist only what's needed
const store = create(persist(
  (set) => ({ /* state */ }),
  {
    name: 'storage',
    partialize: (state) => ({
      user: state.user,
      preferences: state.preferences,
      // tasks: not persisted (fetched fresh)
      // largeCache: not persisted
    }),
  }
));
```

### Pitfall 3: Not Handling Hydration Mismatch in SSR

```typescript
// ❌ WRONG: Using persisted store directly in SSR
const data = useStore.getState().data; // Might be empty on server

// ✅ CORRECT: Use hydration-aware patterns
function MyComponent() {
  const [hydrated, setHydrated] = useState(false);
  useEffect(() => setHydrated(true), []);
  const data = useStore((state) => state.data);
  return hydrated ? <div>{data}</div> : <div>Loading...</div>;
}
```

### Pitfall 4: Forgetting to Version on Breaking Changes

```typescript
// ❌ BAD: Changing state shape without version
persist(
  (set) => ({
    tasks: [], // Changed from taskList to tasks
  }),
  { name: 'storage' }
);
// Old users with 'taskList' will break

// ✅ GOOD: Use version and migration
persist(
  (set) => ({ tasks: [] }),
  {
    name: 'storage',
    version: 1,
    migrate: (state, version) => {
      if (version === 0) {
        return { tasks: state.taskList };
      }
      return state;
    },
  }
);
```

---

## Production Patterns

### Pattern 1: Encrypted Persistence

```typescript
// src/store/encryptedPersist.ts
import { persist } from 'zustand/middleware';
import CryptoJS from 'crypto-js';

const encryptionKey = process.env.STORAGE_ENCRYPTION_KEY || 'default-key';

const encryptedStorage = {
  getItem: (key: string) => {
    const encrypted = localStorage.getItem(key);
    if (!encrypted) return null;
    const bytes = CryptoJS.AES.decrypt(encrypted, encryptionKey);
    return bytes.toString(CryptoJS.enc.Utf8);
  },
  setItem: (key: string, value: string) => {
    const encrypted = CryptoJS.AES.encrypt(value, encryptionKey).toString();
    localStorage.setItem(key, encrypted);
  },
  removeItem: (key: string) => {
    localStorage.removeItem(key);
  },
};

export const useEncryptedStore = create<any>()(
  persist(
    (set) => ({
      user: null,
      token: null,
      // sensitive data
    }),
    {
      name: 'encrypted-storage',
      storage: encryptedStorage,
    }
  )
);
```

### Pattern 2: Multi-Tab Sync

```typescript
// src/store/multiTabPersist.ts
import { create } from 'zustand';
import { persist } from 'zustand/middleware';

export const useMultiTabStore = create<any>()(
  persist(
    (set) => ({
      data: [],
      setData: (data) => set({ data }),
    }),
    {
      name: 'multi-tab-storage',
      // Zustand's persist middleware already supports multi-tab sync
      // via 'storage' events. Ensure you're using the default localStorage
      // which emits 'storage' events across tabs.
    }
  )
);

// In your app, you can also listen to storage events manually
if (typeof window !== 'undefined') {
  window.addEventListener('storage', (event) => {
    if (event.key === 'multi-tab-storage') {
      // Force refresh the store
      useMultiTabStore.persist.rehydrate();
    }
  });
}
```

### Pattern 3: Conditional Persistence (User Session)

```typescript
// src/store/sessionAwarePersist.ts
import { create } from 'zustand';
import { persist } from 'zustand/middleware';

interface SessionStore {
  user: { id: string } | null;
  shouldPersist: boolean;
  setUser: (user: { id: string } | null) => void;
  setShouldPersist: (should: boolean) => void;
}

export const useSessionStore = create<SessionStore>()(
  persist(
    (set) => ({
      user: null,
      shouldPersist: false,
      setUser: (user) => set({ user }),
      setShouldPersist: (shouldPersist) => set({ shouldPersist }),
    }),
    {
      name: 'session-storage',
      // Only persist if shouldPersist is true
      partialize: (state) => {
        if (!state.shouldPersist) {
          return { user: null };
        }
        return { user: state.user };
      },
    }
  )
);
```

---

## Key Takeaways

1. **Use the `persist` middleware** for automatic saving and loading
2. **Choose the right storage**: localStorage, sessionStorage, IndexedDB, AsyncStorage, MMKV
3. **Partialize** to persist only what's needed
4. **Version and migrate** for schema changes
5. **Handle hydration** carefully in SSR environments
6. **Be aware of serialization**: Avoid non-serializable data (Dates, Functions, Symbols)
7. **Security**: Consider encrypting sensitive data
8. **Multi-tab**: Zustand handles sync across tabs via storage events
9. **Testing**: Write tests for persistence and migrations
10. **Performance**: Don't persist large datasets unnecessarily

---

## What's Next

Now that you've mastered persistence, you're ready to dive into debugging. In the next section, you'll learn how to use Redux DevTools, time-travel debugging, and other techniques to inspect and debug your Zustand stores.
