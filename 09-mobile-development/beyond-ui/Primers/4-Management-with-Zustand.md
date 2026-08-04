# Primer 4: State Management with Zustand

## Your Complete Guide to Simple, Powerful State Management

Welcome to the Zustand Primer! This guide covers everything you need to know about managing state in your React Native applications using Zustand. Zustand is a small, fast, and scalable state management solution that's perfect for React Native apps.

---

## Z.1 Why Zustand?

### The Concept: State Management Made Simple

Zustand is a state management library that's incredibly simple to use but powerful enough for complex applications. It's like having a global storage container that any component can access and update, with automatic re-rendering when data changes.

**Simple Analogy:** Think of Zustand like a shared whiteboard in an office. Anyone can read what's on it, anyone can write to it, and everyone automatically sees updates when someone changes something. You don't need to pass messages between people (prop drilling) - everyone just looks at the whiteboard.

### Zustand vs Other State Management

| Feature | Zustand | Redux | Context API | MobX |
|---------|---------|-------|-------------|------|
| Boilerplate | Minimal | Heavy | Moderate | Moderate |
| Learning Curve | Easy | Steep | Easy | Moderate |
| Performance | Excellent | Good | Moderate | Excellent |
| Size | Tiny (1KB) | Large (40KB) | Built-in | Large (30KB) |
| Dev Tools | ✅ | ✅ | Limited | ✅ |
| Async Support | ✅ | ✅ | Manual | ✅ |
| Persistence | ✅ | Manual | Manual | Manual |

---

## Z.2 Getting Started

### The Concept: Your First Store

A store is where you keep your application state. In Zustand, creating a store is incredibly simple.

### Complete Setup Guide

```bash
# Install Zustand
npm install zustand

# For persistence (optional)
npm install @react-native-async-storage/async-storage
npm install expo-secure-store
```

```typescript
// 1. Create Your First Store
// store/counterStore.ts
import { create } from 'zustand';

interface CounterState {
  count: number;
  increment: () => void;
  decrement: () => void;
  reset: () => void;
  setCount: (count: number) => void;
}

export const useCounterStore = create<CounterState>((set, get) => ({
  // Initial state
  count: 0,
  
  // Actions
  increment: () => set((state) => ({ count: state.count + 1 })),
  
  decrement: () => set((state) => ({ count: state.count - 1 })),
  
  reset: () => set({ count: 0 }),
  
  setCount: (count: number) => set({ count }),
}));

// 2. Use Store in Components
import { useCounterStore } from '@store/counterStore';

function Counter() {
  // Select specific state and actions
  const { count, increment, decrement, reset } = useCounterStore();
  
  return (
    <View>
      <Text>Count: {count}</Text>
      <Button title="+" onPress={increment} />
      <Button title="-" onPress={decrement} />
      <Button title="Reset" onPress={reset} />
    </View>
  );
}

// 3. Optimize Performance - Select Only What You Need
function CounterDisplay() {
  // This component only re-renders when 'count' changes
  const count = useCounterStore((state) => state.count);
  return <Text>{count}</Text>;
}

function CounterControls() {
  // This component only re-renders when actions change (never)
  const { increment, decrement } = useCounterStore((state) => ({
    increment: state.increment,
    decrement: state.decrement,
  }));
  
  return (
    <View>
      <Button title="+" onPress={increment} />
      <Button title="-" onPress={decrement} />
    </View>
  );
}
```

---

## Z.3 Store Patterns

### The Concept: Organizing Your Stores

As your app grows, you'll want to organize your stores in a maintainable way.

### Complete Store Organization Guide

```typescript
// 1. Split Stores by Domain
// store/slices/authStore.ts
import { create } from 'zustand';
import { persist } from 'zustand/middleware';

interface User {
  id: string;
  email: string;
  name: string;
}

interface AuthState {
  user: User | null;
  isAuthenticated: boolean;
  isLoading: boolean;
  error: string | null;
}

interface AuthActions {
  login: (email: string, password: string) => Promise<void>;
  logout: () => void;
  register: (email: string, password: string, name: string) => Promise<void>;
  clearError: () => void;
}

type AuthStore = AuthState & AuthActions;

export const useAuthStore = create<AuthStore>()(
  persist(
    (set, get) => ({
      // State
      user: null,
      isAuthenticated: false,
      isLoading: false,
      error: null,

      // Actions
      login: async (email, password) => {
        set({ isLoading: true, error: null });
        try {
          // API call
          const response = await loginAPI(email, password);
          set({
            user: response.user,
            isAuthenticated: true,
            isLoading: false,
          });
        } catch (error: any) {
          set({
            error: error.message,
            isLoading: false,
          });
        }
      },

      logout: () => {
        set({ user: null, isAuthenticated: false });
      },

      register: async (email, password, name) => {
        set({ isLoading: true, error: null });
        try {
          const response = await registerAPI(email, password, name);
          set({
            user: response.user,
            isAuthenticated: true,
            isLoading: false,
          });
        } catch (error: any) {
          set({
            error: error.message,
            isLoading: false,
          });
        }
      },

      clearError: () => set({ error: null }),
    }),
    {
      name: 'auth-storage',
      partialize: (state) => ({
        user: state.user,
        isAuthenticated: state.isAuthenticated,
      }),
    }
  )
);

// 2. Store with Derived State
// store/slices/formStore.ts
import { create } from 'zustand';

interface FormState {
  forms: Form[];
  currentFormId: string | null;
  isLoading: boolean;
}

interface FormActions {
  setForms: (forms: Form[]) => void;
  addForm: (form: Form) => void;
  updateForm: (id: string, data: Partial<Form>) => void;
  deleteForm: (id: string) => void;
  setCurrentForm: (id: string | null) => void;
  getCurrentForm: () => Form | undefined;
  getFormsByCategory: (category: string) => Form[];
  getRecentForms: (limit: number) => Form[];
}

type FormStore = FormState & FormActions;

export const useFormStore = create<FormStore>((set, get) => ({
  forms: [],
  currentFormId: null,
  isLoading: false,

  setForms: (forms) => set({ forms }),
  
  addForm: (form) => set((state) => ({
    forms: [...state.forms, form],
  })),
  
  updateForm: (id, data) => set((state) => ({
    forms: state.forms.map((form) =>
      form.id === id ? { ...form, ...data } : form
    ),
  })),
  
  deleteForm: (id) => set((state) => ({
    forms: state.forms.filter((form) => form.id !== id),
  })),
  
  setCurrentForm: (id) => set({ currentFormId: id }),
  
  getCurrentForm: () => {
    const { forms, currentFormId } = get();
    return forms.find((form) => form.id === currentFormId);
  },
  
  getFormsByCategory: (category) => {
    const { forms } = get();
    return forms.filter((form) => form.category === category);
  },
  
  getRecentForms: (limit) => {
    const { forms } = get();
    return forms.slice(0, limit);
  },
}));

// 3. Combine Stores
// store/index.ts
export { useAuthStore } from './slices/authStore';
export { useCounterStore } from './slices/counterStore';
export { useFormStore } from './slices/formStore';
export { useSettingsStore } from './slices/settingsStore';

// 4. Create a Unified Selector Hook
import { useAuthStore, useSettingsStore, useFormStore } from '@store';

export const useAppStore = <T>(
  selector: (state: {
    auth: ReturnType<typeof useAuthStore>;
    settings: ReturnType<typeof useSettingsStore>;
    forms: ReturnType<typeof useFormStore>;
  }) => T
): T => {
  const auth = useAuthStore();
  const settings = useSettingsStore();
  const forms = useFormStore();
  
  return selector({ auth, settings, forms });
};

// Usage
function UserProfile() {
  const { user, theme } = useAppStore((state) => ({
    user: state.auth.user,
    theme: state.settings.settings.theme,
  }));
  
  return (
    <Text style={{ color: theme === 'dark' ? '#fff' : '#000' }}>
      {user?.name}
    </Text>
  );
}
```

---

## Z.4 Persistence

### The Concept: Saving State Between Sessions

Persistence keeps your state even after the app is closed and reopened. This is crucial for things like user authentication, settings, and preferences.

### Complete Persistence Guide

```typescript
// 1. Basic Persistence with AsyncStorage
import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';
import AsyncStorage from '@react-native-async-storage/async-storage';

interface SettingsState {
  theme: 'light' | 'dark';
  notifications: boolean;
  language: string;
}

interface SettingsActions {
  setTheme: (theme: 'light' | 'dark') => void;
  toggleNotifications: () => void;
  setLanguage: (language: string) => void;
}

export const useSettingsStore = create<SettingsState & SettingsActions>()(
  persist(
    (set) => ({
      theme: 'system',
      notifications: true,
      language: 'en',

      setTheme: (theme) => set({ theme }),
      
      toggleNotifications: () => set((state) => ({
        notifications: !state.notifications,
      })),
      
      setLanguage: (language) => set({ language }),
    }),
    {
      name: 'settings-storage',
      storage: createJSONStorage(() => AsyncStorage),
    }
  )
);

// 2. Secure Storage for Sensitive Data
import { create } from 'zustand';
import { persist } from 'zustand/middleware';
import * as SecureStore from 'expo-secure-store';

// Custom secure storage
const secureStorage = {
  getItem: async (key: string) => {
    try {
      const value = await SecureStore.getItemAsync(key);
      return value ? JSON.parse(value) : null;
    } catch {
      return null;
    }
  },
  setItem: async (key: string, value: any) => {
    await SecureStore.setItemAsync(key, JSON.stringify(value));
  },
  removeItem: async (key: string) => {
    await SecureStore.deleteItemAsync(key);
  },
};

export const useSecureStore = create<AuthStore>()(
  persist(
    (set) => ({
      token: null,
      user: null,
      setToken: (token) => set({ token }),
      setUser: (user) => set({ user }),
      clear: () => set({ token: null, user: null }),
    }),
    {
      name: 'secure-storage',
      storage: createJSONStorage(() => secureStorage),
    }
  )
);

// 3. Partial Persistence - Only Save What You Need
export const useAuthStore = create<AuthStore>()(
  persist(
    (set) => ({
      user: null,
      isAuthenticated: false,
      isLoading: false,
      error: null,

      login: async (email, password) => {
        // ... login logic
      },

      logout: () => {
        set({ user: null, isAuthenticated: false });
      },
    }),
    {
      name: 'auth-storage',
      // Only persist these fields
      partialize: (state) => ({
        user: state.user,
        isAuthenticated: state.isAuthenticated,
      }),
    }
  )
);

// 4. Persistence with Migration
export const useSettingsStore = create<SettingsStore>()(
  persist(
    (set) => ({
      theme: 'system',
      notifications: true,
      language: 'en',
      // Version 2: added 'fontSize'
    }),
    {
      name: 'settings-storage',
      version: 2,
      migrate: (persistedState: any, version: number) => {
        if (version === 0) {
          // Migrate from version 0 to 1
          return {
            ...persistedState,
            notifications: true,
          };
        }
        if (version === 1) {
          // Migrate from version 1 to 2
          return {
            ...persistedState,
            fontSize: 'medium',
          };
        }
        return persistedState;
      },
    }
  )
);
```

---

## Z.5 Advanced Patterns

### The Concept: Production-Ready State Management

Advanced patterns for complex applications.

### Complete Advanced Guide

```typescript
// 1. Middleware - Logging
import { create } from 'zustand';
import { devtools } from 'zustand/middleware';

export const useStore = create<StoreState>()(
  devtools(
    (set) => ({
      // state and actions
    }),
    { name: 'AppStore' } // Name in Redux DevTools
  )
);

// 2. Custom Middleware
const logger = (config) => (set, get, api) => {
  return config(
    (args) => {
      console.log('  applying', args);
      set(args);
      console.log('  new state', get());
    },
    get,
    api
  );
};

export const useStore = create(logger((set) => ({
  count: 0,
  increment: () => set((state) => ({ count: state.count + 1 })),
})));

// 3. Async Actions with Side Effects
export const useUserStore = create<UserStore>((set, get) => ({
  user: null,
  loading: false,
  error: null,

  fetchUser: async (id: string) => {
    set({ loading: true, error: null });
    
    try {
      const response = await fetch(`/api/users/${id}`);
      const user = await response.json();
      
      // Update multiple pieces of state
      set({ 
        user, 
        loading: false,
        lastFetched: Date.now(),
      });
    } catch (error: any) {
      set({ 
        error: error.message, 
        loading: false 
      });
    }
  },

  // Action that uses get() to access current state
  refreshUser: async () => {
    const { user } = get();
    if (user) {
      await get().fetchUser(user.id);
    }
  },
}));

// 4. Store with Computed Values
import { create } from 'zustand';
import { combine } from 'zustand/middleware';

export const useShoppingCart = create(
  combine(
    {
      items: [],
      discount: 0,
      taxRate: 0.08,
    },
    (set, get) => ({
      addItem: (item) => set((state) => ({
        items: [...state.items, item],
      })),
      
      removeItem: (id) => set((state) => ({
        items: state.items.filter((item) => item.id !== id),
      })),
      
      updateQuantity: (id, quantity) => set((state) => ({
        items: state.items.map((item) =>
          item.id === id ? { ...item, quantity } : item
        ),
      })),
      
      // Computed properties as getters
      getTotalItems: () => {
        const { items } = get();
        return items.reduce((total, item) => total + item.quantity, 0);
      },
      
      getSubtotal: () => {
        const { items } = get();
        return items.reduce(
          (total, item) => total + item.price * item.quantity,
          0
        );
      },
      
      getDiscountAmount: () => {
        const { getSubtotal, discount } = get();
        return getSubtotal() * (discount / 100);
      },
      
      getTaxAmount: () => {
        const { getSubtotal, getDiscountAmount, taxRate } = get();
        return (getSubtotal() - getDiscountAmount()) * taxRate;
      },
      
      getTotal: () => {
        const { getSubtotal, getDiscountAmount, getTaxAmount } = get();
        return getSubtotal() - getDiscountAmount() + getTaxAmount();
      },
    })
  )
);

// 5. Store with Reset Method
export const useFormStore = create<FormStore>((set, get) => ({
  formData: {},
  errors: {},
  touched: {},
  isSubmitting: false,

  // Reset all state to initial values
  reset: () => set({
    formData: {},
    errors: {},
    touched: {},
    isSubmitting: false,
  }),
  
  // Reset specific fields
  resetField: (fieldName: string) => set((state) => ({
    formData: { ...state.formData, [fieldName]: undefined },
    errors: { ...state.errors, [fieldName]: undefined },
    touched: { ...state.touched, [fieldName]: false },
  })),
}));

// 6. Store with Optimistic Updates
export const useTodoStore = create<TodoStore>((set, get) => ({
  todos: [],
  isSyncing: false,

  addTodo: async (todo) => {
    // Optimistic update
    const tempId = `temp-${Date.now()}`;
    const tempTodo = { ...todo, id: tempId, synced: false };
    
    // Update UI immediately
    set((state) => ({
      todos: [...state.todos, tempTodo],
    }));

    try {
      // Actual API call
      const savedTodo = await saveTodoAPI(tempTodo);
      
      // Replace temp with saved version
      set((state) => ({
        todos: state.todos.map((t) =>
          t.id === tempId ? { ...savedTodo, synced: true } : t
        ),
      }));
    } catch (error) {
      // Rollback on error
      set((state) => ({
        todos: state.todos.filter((t) => t.id !== tempId),
        error: 'Failed to save todo',
      }));
    }
  },
}));
```

---

## Z.6 Testing Zustand Stores

### The Concept: Ensuring Store Correctness

Testing your stores ensures they work correctly and helps prevent bugs.

### Complete Testing Guide

```typescript
// 1. Testing Basic Store
// __tests__/store/counterStore.test.ts
import { useCounterStore } from '@store/counterStore';

describe('Counter Store', () => {
  beforeEach(() => {
    // Reset store before each test
    useCounterStore.setState({ count: 0 });
  });

  it('should have initial state', () => {
    const state = useCounterStore.getState();
    expect(state.count).toBe(0);
  });

  it('should increment count', () => {
    const { increment } = useCounterStore.getState();
    increment();
    const state = useCounterStore.getState();
    expect(state.count).toBe(1);
  });

  it('should decrement count', () => {
    const { decrement } = useCounterStore.getState();
    decrement();
    const state = useCounterStore.getState();
    expect(state.count).toBe(-1);
  });

  it('should reset count', () => {
    const { increment, reset } = useCounterStore.getState();
    increment();
    increment();
    reset();
    const state = useCounterStore.getState();
    expect(state.count).toBe(0);
  });
});

// 2. Testing Async Actions
// __tests__/store/authStore.test.ts
import { useAuthStore } from '@store/authStore';
import { loginAPI } from '@api/auth';

jest.mock('@api/auth');

describe('Auth Store', () => {
  const mockUser = { id: '1', email: 'test@example.com', name: 'Test User' };

  beforeEach(() => {
    useAuthStore.setState({
      user: null,
      isAuthenticated: false,
      isLoading: false,
      error: null,
    });
    jest.clearAllMocks();
  });

  it('should login successfully', async () => {
    (loginAPI as jest.Mock).mockResolvedValue({ user: mockUser });

    const { login } = useAuthStore.getState();
    await login('test@example.com', 'password');

    const state = useAuthStore.getState();
    expect(state.user).toEqual(mockUser);
    expect(state.isAuthenticated).toBe(true);
    expect(state.isLoading).toBe(false);
    expect(state.error).toBe(null);
  });

  it('should handle login error', async () => {
    const error = new Error('Invalid credentials');
    (loginAPI as jest.Mock).mockRejectedValue(error);

    const { login } = useAuthStore.getState();
    await login('test@example.com', 'wrong-password');

    const state = useAuthStore.getState();
    expect(state.user).toBe(null);
    expect(state.isAuthenticated).toBe(false);
    expect(state.isLoading).toBe(false);
    expect(state.error).toBe('Invalid credentials');
  });

  it('should logout', () => {
    // Set initial state
    useAuthStore.setState({
      user: mockUser,
      isAuthenticated: true,
    });

    const { logout } = useAuthStore.getState();
    logout();

    const state = useAuthStore.getState();
    expect(state.user).toBe(null);
    expect(state.isAuthenticated).toBe(false);
  });
});

// 3. Testing Components with Zustand
// __tests__/components/Counter.test.tsx
import React from 'react';
import { render, fireEvent, screen } from '@testing-library/react-native';
import { useCounterStore } from '@store/counterStore';
import Counter from '@components/Counter';

describe('Counter Component', () => {
  beforeEach(() => {
    useCounterStore.setState({ count: 0 });
  });

  it('should render initial count', () => {
    render(<Counter />);
    expect(screen.getByText('Count: 0')).toBeTruthy();
  });

  it('should increment count on button press', () => {
    render(<Counter />);
    const button = screen.getByText('+');
    fireEvent.press(button);
    expect(screen.getByText('Count: 1')).toBeTruthy();
  });

  it('should decrement count on button press', () => {
    render(<Counter />);
    const button = screen.getByText('-');
    fireEvent.press(button);
    expect(screen.getByText('Count: -1')).toBeTruthy();
  });
});
```

---

## Z.7 Performance Optimization

### The Concept: Keep Your App Fast

Proper state management is crucial for performance. Here's how to optimize.

### Complete Performance Guide

```typescript
// 1. Use Selectors to Prevent Re-renders
function UserProfile() {
  // ✅ Good - Only re-renders when user.name changes
  const userName = useAuthStore((state) => state.user?.name);
  
  // ❌ Bad - Re-renders whenever ANY state changes
  const state = useAuthStore((state) => state);
  
  return <Text>{userName}</Text>;
}

// 2. Combine Selectors with Shallow
import { shallow } from 'zustand/shallow';

function UserControls() {
  // ✅ Good - Only re-renders when these specific values change
  const { user, logout } = useAuthStore(
    (state) => ({
      user: state.user,
      logout: state.logout,
    }),
    shallow // Prevents re-render if values haven't changed
  );
  
  return (
    <View>
      <Text>{user?.name}</Text>
      <Button title="Logout" onPress={logout} />
    </View>
  );
}

// 3. Use Memoized Selectors
import { createSelector } from 'reselect';

const selectActiveForms = (state: FormStore) => state.forms.filter(f => f.isActive);
const selectCompletedForms = (state: FormStore) => state.forms.filter(f => f.isComplete);

function ActiveFormList() {
  // Only recomputes when forms changes
  const activeForms = useFormStore(createSelector(
    (state) => state.forms,
    (forms) => forms.filter(f => f.isActive)
  ));
  
  return <FlatList data={activeForms} renderItem={...} />;
}

// 4. Split Stores to Reduce Updates
// Instead of one large store, split by domain
const useUserStore = create(...);
const useSettingsStore = create(...);
const useFormStore = create(...);

// 5. Use Shallow for Arrays
function TodoList() {
  const todos = useTodoStore(
    (state) => state.todos,
    shallow // Compares array references
  );
  
  return <FlatList data={todos} />;
}

// 6. Avoid Creating New Objects in Selectors
function UserProfile() {
  // ❌ Bad - Creates new object every render
  const userData = useAuthStore((state) => ({
    name: state.user?.name,
    email: state.user?.email,
  }));
  
  // ✅ Good - Select individual values
  const name = useAuthStore((state) => state.user?.name);
  const email = useAuthStore((state) => state.user?.email);
  
  return <Text>{name}</Text>;
}
```

---

## Z.8 Common Pitfalls & Solutions

### The Concept: Avoiding Common Mistakes

Learn from common mistakes and how to avoid them.

### Complete Troubleshooting Guide

| Issue | Cause | Solution |
|-------|-------|----------|
| Component not updating | Not using store correctly | Use `useStore` hook with selector |
| Infinite re-renders | Creating new objects in selectors | Use shallow comparison or select primitives |
| State not persisting | Wrong storage configuration | Check storage setup and permissions |
| TypeError in store | Missing initial state | Always define initial state |
| Async state not updating | Not calling set after async | Call set after async operations |
| Store becoming large | Too much in one store | Split into multiple stores |

```typescript
// 1. Fix: Component not updating
// ❌ Bad
function BadComponent() {
  const store = useCounterStore();
  // This component won't update when count changes
  // because it's not accessing the state directly
  
  return <Text>{store.getState().count}</Text>;
}

// ✅ Good
function GoodComponent() {
  const count = useCounterStore((state) => state.count);
  return <Text>{count}</Text>;
}

// 2. Fix: Infinite re-renders
// ❌ Bad
function BadComponent() {
  const data = useStore((state) => ({
    name: state.name,
    age: state.age,
  })); // Creates new object every render
  return <Text>{data.name}</Text>;
}

// ✅ Good
function GoodComponent() {
  const name = useStore((state) => state.name);
  const age = useStore((state) => state.age);
  return <Text>{name}</Text>;
}

// Or use shallow
import { shallow } from 'zustand/shallow';

function GoodComponent() {
  const data = useStore(
    (state) => ({
      name: state.name,
      age: state.age,
    }),
    shallow
  );
  return <Text>{data.name}</Text>;
}

// 3. Fix: Async state not updating
// ❌ Bad
const useStore = create((set) => ({
  data: null,
  fetchData: async () => {
    const data = await fetchAPI();
    // Forgetting to call set
  },
}));

// ✅ Good
const useStore = create((set) => ({
  data: null,
  loading: false,
  fetchData: async () => {
    set({ loading: true });
    const data = await fetchAPI();
    set({ data, loading: false });
  },
}));

// 4. Fix: TypeError in store
// ❌ Bad
const useStore = create((set) => ({
  user: null,
  updateUser: (name) => set((state) => ({
    user: {
      ...state.user, // TypeError if user is null
      name,
    },
  })),
}));

// ✅ Good
const useStore = create((set) => ({
  user: null,
  updateUser: (name) => set((state) => ({
    user: state.user ? { ...state.user, name } : { name },
  })),
}));
```

---

## Z.9 Quick Reference

### Zustand API Reference

```typescript
// 1. create - Create a store
const useStore = create((set) => ({
  state: value,
  action: () => set((state) => ({ state: value })),
}));

// 2. set - Update state
set({ state: value });
set((state) => ({ state: state.value + 1 }));

// 3. get - Get current state
const currentState = get();

// 4. persist - Persist state
const useStore = create(
  persist((set) => ({}), { name: 'storage-key' })
);

// 5. devtools - Redux DevTools support
const useStore = create(
  devtools((set) => ({}), { name: 'StoreName' })
);

// 6. selectors - Select specific state
const value = useStore((state) => state.value);

// 7. shallow - Compare objects shallowly
import { shallow } from 'zustand/shallow';
const values = useStore((state) => ({
  a: state.a,
  b: state.b,
}), shallow);
```

---

**Ready to manage state like a pro? Let's build NexusCollect!**
