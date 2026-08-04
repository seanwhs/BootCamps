# Part 2: Project Architecture & Core Setup

## Building Your Application's Foundation

Now that we have our native development environment configured and running, it's time to build the architectural backbone of NexusCollect. Think of this phase as laying the foundation and framing for a house—we're establishing the structure that will support everything we build later.

### The Target

By the end of this part, you will have:

1. A comprehensive application architecture with clear separation of concerns
2. A complete navigation system with authentication flows and protected routes
3. Global state management using Zustand with persistence
4. A robust API client architecture with error handling and interceptors
5. The foundational UI components and theming system
6. All of this working together in a cohesive, maintainable structure

---

## Phase 2.1: Application Architecture Design

### The Concept: Separation of Concerns

Think of your application as a restaurant. You have different areas:
- **UI (The Dining Room):** What customers see and interact with
- **State Management (The Kitchen):** Where the data is prepared and managed
- **API Layer (The Suppliers):** Where raw ingredients (data) come from
- **Navigation (The Waitstaff):** How customers move through the experience

Each area has a specific job and doesn't interfere with the others. This separation makes the application easier to maintain, test, and scale.

### The Implementation: Establishing Architecture Layers

Let's set up our folder structure with clear architectural boundaries.

**Create the complete folder structure:**

```bash
# Navigate to the project root
$ cd NexusCollect

# Create the complete architecture structure
$ mkdir -p src/api/{interceptors,services}
$ mkdir -p src/components/{common,forms,navigation,layouts}
$ mkdir -p src/screens/{auth,main,settings,diagnostics}
$ mkdir -p src/navigation/{stacks,tabs}
$ mkdir -p src/store/{slices,persistence}
$ mkdir -p src/hooks
$ mkdir -p src/utils
$ mkdir -p src/types
$ mkdir -p src/constants
$ mkdir -p src/themes
$ mkdir -p src/assets/{images,fonts}
$ mkdir -p src/lib
```

**Create the architecture documentation:**

```typescript
// src/constants/architecture.ts
/**
 * ARCHITECTURE GUIDE: NexusCollect Application
 * 
 * This file documents the application architecture for reference.
 * 
 * LAYERED ARCHITECTURE:
 * 
 * 1. UI Layer (Screens + Components)
 *    - Screens: Complete pages/routes
 *    - Components: Reusable UI pieces
 *    - Layouts: Page structure templates
 * 
 * 2. State Layer (Store + Hooks)
 *    - Zustand stores for global state
 *    - Custom hooks for component-level state
 *    - Persistence for offline data
 * 
 * 3. Data Layer (API + Services)
 *    - API clients (Supabase, REST)
 *    - Service classes for business logic
 *    - Interceptors for auth/error handling
 * 
 * 4. Navigation Layer
 *    - Stack navigators (auth, main)
 *    - Tab navigators (dashboard, forms, etc.)
 *    - Deep linking configuration
 * 
 * 5. Utility Layer
 *    - Helpers, formatters, validators
 *    - Constants and configuration
 *    - Type definitions
 * 
 * DATA FLOW:
 * User Action → Component → Store/Service → API → Backend → Response → Store → Component Update
 * 
 * PERSISTENCE STRATEGY:
 * - Auth state: SecureStore (encrypted)
 * - User preferences: AsyncStorage
 * - App data: WatermelonDB (encrypted)
 * - Cache: TanStack Query
 */

export const ARCHITECTURE = {
  layers: ['UI', 'State', 'Data', 'Navigation', 'Utility'],
  dataFlow: 'Unidirectional (Action → Store → Service → API → Store → UI)',
  persistence: {
    auth: 'SecureStore',
    preferences: 'AsyncStorage',
    appData: 'WatermelonDB',
    cache: 'TanStack Query',
  },
  testing: {
    unit: 'Jest + React Native Testing Library',
    integration: 'Jest',
    e2e: 'Detox',
  },
} as const;
```

---

## Phase 2.2: Navigation System

### The Concept: Guiding Users Through the App

Navigation is like a GPS for your app—it tells users where they are and how to get where they want to go. We'll implement React Navigation with a structure that handles:

- **Authentication Flow:** Login/Register screens (unauthenticated)
- **Main App Flow:** Home, Dashboard, Forms (authenticated)
- **Nested Navigation:** Tabs within stacks for complex sections
- **Deep Linking:** Opening specific screens from external links

### The Implementation: Complete Navigation Setup

#### Step 2.2.1: Install Navigation Dependencies

```bash
# Core navigation packages
$ npm install @react-navigation/native @react-navigation/native-stack @react-navigation/bottom-tabs @react-navigation/drawer

# Native dependencies
$ npm install react-native-screens react-native-safe-area-context react-native-gesture-handler react-native-reanimated

# iOS: Install pods
$ cd ios && pod install && cd ..
```

#### Step 2.2.2: Create Navigation Types

```typescript
// src/types/navigation.ts
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import { BottomTabNavigationProp } from '@react-navigation/bottom-tabs';
import { CompositeNavigationProp } from '@react-navigation/native';

/**
 * Navigation type definitions for type-safe navigation.
 * This ensures we only navigate to screens that exist
 * and pass the correct parameters.
 */

// Authentication Stack
export type AuthStackParamList = {
  Login: undefined;
  Register: undefined;
  ForgotPassword: undefined;
  Onboarding: undefined;
};

// Main Tab Navigator
export type MainTabParamList = {
  Dashboard: undefined;
  Forms: undefined;
  Collections: undefined;
  Profile: undefined;
  Settings: undefined;
};

// Main Stack (contains tabs and other screens)
export type MainStackParamList = {
  MainTabs: undefined;
  FormDetail: { formId: string };
  CollectionDetail: { collectionId: string };
  Camera: { returnTo: string };
  Map: { entryId?: string };
  Notifications: undefined;
  Diagnostics: undefined;
};

// Root Stack (combines auth and main)
export type RootStackParamList = {
  Auth: undefined;
  Main: undefined;
  Splash: undefined;
};

// Composite navigation types for screens that need to navigate between stacks
export type AuthScreenNavigationProp = NativeStackNavigationProp<AuthStackParamList>;
export type MainScreenNavigationProp = CompositeNavigationProp<
  NativeStackNavigationProp<MainStackParamList>,
  BottomTabNavigationProp<MainTabParamList>
>;

// Navigation hooks with proper types
declare global {
  namespace ReactNavigation {
    interface RootParamList extends RootStackParamList {}
  }
}
```

#### Step 2.2.3: Implement Authentication Stack

```typescript
// src/navigation/stacks/AuthStack.tsx
import React from 'react';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { AuthStackParamList } from '@types/navigation';

// Import screens (we'll create these in Phase 2.3)
import LoginScreen from '@screens/auth/LoginScreen';
import RegisterScreen from '@screens/auth/RegisterScreen';
import ForgotPasswordScreen from '@screens/auth/ForgotPasswordScreen';
import OnboardingScreen from '@screens/auth/OnboardingScreen';

const Stack = createNativeStackNavigator<AuthStackParamList>();

/**
 * Authentication Stack Navigator
 * 
 * Handles all unauthenticated flows:
 * - Onboarding (first-time users)
 * - Login
 * - Registration
 * - Password recovery
 * 
 * Uses a card-style presentation for smooth transitions.
 */
export const AuthStack = () => {
  return (
    <Stack.Navigator
      initialRouteName="Login"
      screenOptions={{
        headerShown: false,
        animation: 'slide_from_right',
        contentStyle: {
          backgroundColor: '#ffffff',
        },
      }}
    >
      {/* Onboarding screen (shown once) */}
      <Stack.Screen 
        name="Onboarding" 
        component={OnboardingScreen}
        options={{
          animation: 'fade',
        }}
      />
      
      {/* Authentication screens */}
      <Stack.Screen 
        name="Login" 
        component={LoginScreen}
        options={{
          animation: 'slide_from_right',
        }}
      />
      
      <Stack.Screen 
        name="Register" 
        component={RegisterScreen}
        options={{
          animation: 'slide_from_right',
        }}
      />
      
      <Stack.Screen 
        name="ForgotPassword" 
        component={ForgotPasswordScreen}
        options={{
          animation: 'slide_from_bottom',
          presentation: 'modal',
        }}
      />
    </Stack.Navigator>
  );
};
```

#### Step 2.2.4: Implement Main Tab Navigator

```typescript
// src/navigation/tabs/MainTabs.tsx
import React from 'react';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { BottomTabNavigationOptions } from '@react-navigation/bottom-tabs';
import { MainTabParamList } from '@types/navigation';
import { Ionicons } from '@expo/vector-icons';
import { useTheme } from '@hooks/useTheme';

// Import screens
import DashboardScreen from '@screens/main/DashboardScreen';
import FormsScreen from '@screens/main/FormsScreen';
import CollectionsScreen from '@screens/main/CollectionsScreen';
import ProfileScreen from '@screens/main/ProfileScreen';
import SettingsScreen from '@screens/main/SettingsScreen';

const Tab = createBottomTabNavigator<MainTabParamList>();

/**
 * Main Tab Navigator
 * 
 * The primary navigation for authenticated users.
 * Uses bottom tabs with icons for quick access to key sections.
 */
export const MainTabs = () => {
  const { colors } = useTheme();

  const getTabOptions = (route: keyof MainTabParamList): BottomTabNavigationOptions => ({
    tabBarIcon: ({ focused, color, size }) => {
      let iconName: keyof typeof Ionicons.glyphMap = 'home-outline';
      
      switch (route) {
        case 'Dashboard':
          iconName = focused ? 'home' : 'home-outline';
          break;
        case 'Forms':
          iconName = focused ? 'document-text' : 'document-text-outline';
          break;
        case 'Collections':
          iconName = focused ? 'folder' : 'folder-outline';
          break;
        case 'Profile':
          iconName = focused ? 'person' : 'person-outline';
          break;
        case 'Settings':
          iconName = focused ? 'settings' : 'settings-outline';
          break;
      }
      
      return <Ionicons name={iconName} size={size} color={color} />;
    },
    tabBarActiveTintColor: colors.primary,
    tabBarInactiveTintColor: colors.gray,
    tabBarStyle: {
      backgroundColor: colors.surface,
      borderTopColor: colors.border,
      height: 60,
      paddingBottom: 8,
      paddingTop: 8,
    },
    headerStyle: {
      backgroundColor: colors.surface,
    },
    headerTitleStyle: {
      color: colors.text,
      fontWeight: '600',
    },
  });

  return (
    <Tab.Navigator
      initialRouteName="Dashboard"
      screenOptions={({ route }) => getTabOptions(route.name as keyof MainTabParamList)}
    >
      <Tab.Screen 
        name="Dashboard" 
        component={DashboardScreen}
        options={{
          title: 'Dashboard',
        }}
      />
      
      <Tab.Screen 
        name="Forms" 
        component={FormsScreen}
        options={{
          title: 'Forms',
        }}
      />
      
      <Tab.Screen 
        name="Collections" 
        component={CollectionsScreen}
        options={{
          title: 'Collections',
        }}
      />
      
      <Tab.Screen 
        name="Profile" 
        component={ProfileScreen}
        options={{
          title: 'Profile',
        }}
      />
      
      <Tab.Screen 
        name="Settings" 
        component={SettingsScreen}
        options={{
          title: 'Settings',
        }}
      />
    </Tab.Navigator>
  );
};
```

#### Step 2.2.5: Implement Root Navigator

```typescript
// src/navigation/RootNavigator.tsx
import React, { useEffect } from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { RootStackParamList } from '@types/navigation';
import { useAuth } from '@hooks/useAuth';
import { useAppState } from '@hooks/useAppState';

// Import navigators
import { AuthStack } from './stacks/AuthStack';
import { MainTabs } from './tabs/MainTabs';

// Import splash screen
import SplashScreen from '@screens/SplashScreen';

const Stack = createNativeStackNavigator<RootStackParamList>();

/**
 * Root Navigator
 * 
 * The top-level navigation that determines whether to show
 * authentication flow or the main app based on auth state.
 * 
 * Handles:
 * - Splash screen during initial load
 * - Automatic navigation based on auth state
 * - Deep linking
 * - Navigation state persistence
 */
export const RootNavigator = () => {
  const { isLoading, isAuthenticated, initializeAuth } = useAuth();
  const { isReady } = useAppState();
  const [isInitialized, setIsInitialized] = React.useState(false);

  useEffect(() => {
    const init = async () => {
      await initializeAuth();
      setIsInitialized(true);
    };
    init();
  }, []);

  // Show splash while initializing
  if (!isInitialized || isLoading || !isReady) {
    return <SplashScreen />;
  }

  return (
    <NavigationContainer
      theme={{
        colors: {
          primary: '#3498db',
          background: '#ffffff',
          card: '#ffffff',
          text: '#2c3e50',
          border: '#ecf0f1',
          notification: '#e74c3c',
        },
        dark: false,
      }}
    >
      <Stack.Navigator
        screenOptions={{
          headerShown: false,
          animation: 'fade',
        }}
      >
        {isAuthenticated ? (
          <Stack.Screen 
            name="Main" 
            component={MainTabs}
            options={{
              animation: 'slide_from_right',
            }}
          />
        ) : (
          <Stack.Screen 
            name="Auth" 
            component={AuthStack}
            options={{
              animation: 'slide_from_right',
            }}
          />
        )}
      </Stack.Navigator>
    </NavigationContainer>
  );
};
```

#### Step 2.2.6: Navigation Utilities and Hooks

```typescript
// src/navigation/utils.ts
import { NavigationProp, useNavigation } from '@react-navigation/native';
import { RootStackParamList } from '@types/navigation';

/**
 * Type-safe navigation hook for the root navigator.
 * Provides typed navigation methods throughout the app.
 */
export const useRootNavigation = () => {
  return useNavigation<NavigationProp<RootStackParamList>>();
};

/**
 * Utility to generate deep links for notifications
 */
export const generateDeepLink = (screen: string, params?: Record<string, any>) => {
  const baseUrl = 'nexuscollect://';
  const queryString = params 
    ? '?' + new URLSearchParams(params).toString()
    : '';
  return `${baseUrl}${screen}${queryString}`;
};

/**
 * Handle external deep links
 */
export const handleDeepLink = (url: string) => {
  // Parse the URL and navigate to the appropriate screen
  console.log('Deep link received:', url);
  // Implementation will be added in Phase 3 with auth context
};

// src/hooks/useDeepLinking.ts
import { useEffect } from 'react';
import { useRootNavigation } from '@navigation/utils';
import { Linking } from 'react-native';

/**
 * Hook to handle deep linking
 */
export const useDeepLinking = () => {
  const navigation = useRootNavigation();

  useEffect(() => {
    // Handle initial URL
    const handleInitialURL = async () => {
      const url = await Linking.getInitialURL();
      if (url) {
        handleDeepLink(url);
      }
    };
    handleInitialURL();

    // Listen for URL events
    const subscription = Linking.addEventListener('url', ({ url }) => {
      handleDeepLink(url);
    });

    return () => {
      subscription.remove();
    };
  }, [navigation]);
};
```

---

## Phase 2.3: State Management with Zustand

### The Concept: The App's Memory

Zustand is a lightweight state management library that acts like your app's short-term memory. It stores data that needs to be accessed by multiple components (like user information, app settings, or authentication status) and notifies components when that data changes.

Think of it as a shared whiteboard that any component can read from or write to. When someone changes something on the whiteboard, all components watching that part of the whiteboard automatically update.

### The Implementation: Complete State Store

#### Step 2.3.1: Install Zustand

```bash
$ npm install zustand
$ npm install @react-native-async-storage/async-storage
$ npm install zustand-middleware
$ npm install expo-secure-store
```

#### Step 2.3.2: Create Auth Store

```typescript
// src/store/slices/authSlice.ts
import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';
import AsyncStorage from '@react-native-async-storage/async-storage';
import * as SecureStore from 'expo-secure-store';
import { User } from '@types';
import { AuthState } from '@types';

/**
 * Authentication Store
 * 
 * Manages user authentication state including:
 * - User profile data
 * - Authentication tokens
 * - Loading and error states
 * 
 * Persists to SecureStore for encrypted storage of sensitive data.
 */
interface AuthStore extends AuthState {
  setUser: (user: User | null) => void;
  setAuthenticated: (isAuthenticated: boolean) => void;
  setLoading: (isLoading: boolean) => void;
  setError: (error: string | null) => void;
  logout: () => void;
  updateUser: (userData: Partial<User>) => void;
  clearError: () => void;
}

// Secure storage for sensitive auth data
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

export const useAuthStore = create<AuthStore>()(
  persist(
    (set, get) => ({
      // Initial state
      user: null,
      isAuthenticated: false,
      isLoading: false,
      error: null,

      // Actions
      setUser: (user) => set({ user }),
      
      setAuthenticated: (isAuthenticated) => set({ isAuthenticated }),
      
      setLoading: (isLoading) => set({ isLoading }),
      
      setError: (error) => set({ error }),
      
      clearError: () => set({ error: null }),
      
      logout: () => {
        // Clear all auth state
        set({
          user: null,
          isAuthenticated: false,
          error: null,
        });
        // Clear secure storage
        secureStorage.removeItem('auth-storage');
      },
      
      updateUser: (userData) => {
        const currentUser = get().user;
        if (currentUser) {
          set({
            user: { ...currentUser, ...userData },
          });
        }
      },
    }),
    {
      name: 'auth-storage',
      storage: createJSONStorage(() => secureStorage),
      // Only persist user and isAuthenticated
      partialize: (state) => ({
        user: state.user,
        isAuthenticated: state.isAuthenticated,
      }),
    }
  )
);
```

#### Step 2.3.3: Create Settings Store

```typescript
// src/store/slices/settingsSlice.ts
import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';
import AsyncStorage from '@react-native-async-storage/async-storage';

/**
 * App Settings Store
 * 
 * Manages application-wide settings including:
 * - Theme preferences (light/dark/system)
 * - Notification preferences
 * - Display preferences
 * - App configuration
 * 
 * Persists to AsyncStorage (non-sensitive data).
 */
interface AppSettings {
  theme: 'light' | 'dark' | 'system';
  notifications: {
    push: boolean;
    email: boolean;
    sound: boolean;
  };
  display: {
    showCompleted: boolean;
    sortBy: 'date' | 'title' | 'status';
    listView: 'grid' | 'list';
  };
  privacy: {
    biometricAuth: boolean;
    autoLock: boolean;
    lockTimeout: number; // minutes
  };
}

interface SettingsStore {
  settings: AppSettings;
  updateSettings: (newSettings: Partial<AppSettings>) => void;
  resetSettings: () => void;
  toggleTheme: (theme: AppSettings['theme']) => void;
  toggleNotifications: (type: keyof AppSettings['notifications']) => void;
  toggleDisplayOption: <K extends keyof AppSettings['display']>(
    key: K,
    value: AppSettings['display'][K]
  ) => void;
}

const defaultSettings: AppSettings = {
  theme: 'system',
  notifications: {
    push: true,
    email: true,
    sound: true,
  },
  display: {
    showCompleted: true,
    sortBy: 'date',
    listView: 'list',
  },
  privacy: {
    biometricAuth: false,
    autoLock: false,
    lockTimeout: 5,
  },
};

export const useSettingsStore = create<SettingsStore>()(
  persist(
    (set) => ({
      settings: defaultSettings,

      updateSettings: (newSettings) =>
        set((state) => ({
          settings: { ...state.settings, ...newSettings },
        })),

      resetSettings: () =>
        set({
          settings: defaultSettings,
        }),

      toggleTheme: (theme) =>
        set((state) => ({
          settings: { ...state.settings, theme },
        })),

      toggleNotifications: (type) =>
        set((state) => ({
          settings: {
            ...state.settings,
            notifications: {
              ...state.settings.notifications,
              [type]: !state.settings.notifications[type],
            },
          },
        })),

      toggleDisplayOption: (key, value) =>
        set((state) => ({
          settings: {
            ...state.settings,
            display: {
              ...state.settings.display,
              [key]: value,
            },
          },
        })),
    }),
    {
      name: 'settings-storage',
      storage: createJSONStorage(() => AsyncStorage),
    }
  )
);
```

#### Step 2.3.4: Create Form Store

```typescript
// src/store/slices/formSlice.ts
import { create } from 'zustand';
import { CollectionForm, FormField } from '@types';

/**
 * Form Management Store
 * 
 * Manages the state of forms and form entries including:
 * - Available forms
 * - Current form being filled
 * - Form submission status
 * - Cached form data for offline use
 */
interface FormStore {
  forms: CollectionForm[];
  currentForm: CollectionForm | null;
  isLoading: boolean;
  error: string | null;
  recentForms: string[]; // IDs of recently used forms

  // Actions
  setForms: (forms: CollectionForm[]) => void;
  setCurrentForm: (form: CollectionForm | null) => void;
  addForm: (form: CollectionForm) => void;
  updateForm: (formId: string, updates: Partial<CollectionForm>) => void;
  deleteForm: (formId: string) => void;
  setLoading: (isLoading: boolean) => void;
  setError: (error: string | null) => void;
  clearError: () => void;
  addRecentForm: (formId: string) => void;
  getFormById: (formId: string) => CollectionForm | undefined;
}

export const useFormStore = create<FormStore>((set, get) => ({
  forms: [],
  currentForm: null,
  isLoading: false,
  error: null,
  recentForms: [],

  setForms: (forms) => set({ forms }),
  
  setCurrentForm: (currentForm) => set({ currentForm }),
  
  addForm: (form) =>
    set((state) => ({
      forms: [...state.forms, form],
    })),
  
  updateForm: (formId, updates) =>
    set((state) => ({
      forms: state.forms.map((form) =>
        form.id === formId ? { ...form, ...updates } : form
      ),
      currentForm: state.currentForm?.id === formId
        ? { ...state.currentForm, ...updates }
        : state.currentForm,
    })),
  
  deleteForm: (formId) =>
    set((state) => ({
      forms: state.forms.filter((form) => form.id !== formId),
      currentForm: state.currentForm?.id === formId ? null : state.currentForm,
    })),
  
  setLoading: (isLoading) => set({ isLoading }),
  
  setError: (error) => set({ error }),
  
  clearError: () => set({ error: null }),
  
  addRecentForm: (formId) =>
    set((state) => ({
      recentForms: [
        formId,
        ...state.recentForms.filter((id) => id !== formId),
      ].slice(0, 10), // Keep only the 10 most recent
    })),
  
  getFormById: (formId) => {
    return get().forms.find((form) => form.id === formId);
  },
}));
```

#### Step 2.3.5: Combine Stores with a Unified Hook

```typescript
// src/store/index.ts
import { useAuthStore } from './slices/authSlice';
import { useSettingsStore } from './slices/settingsSlice';
import { useFormStore } from './slices/formSlice';

/**
 * Unified Store Exports
 * 
 * This file exports all stores and provides a convenient
 * way to access them throughout the application.
 * 
 * Usage:
 * import { useAuthStore, useSettingsStore } from '@store';
 */

export { useAuthStore, useSettingsStore, useFormStore };

// Create a combined selector for components that need multiple stores
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

// Example usage in a component:
// const { user, theme } = useAppStore((state) => ({
//   user: state.auth.user,
//   theme: state.settings.settings.theme,
// }));
```

---

## Phase 2.4: API Client Architecture

### The Concept: Communicating with the World

Your app needs to talk to the outside world (the internet). The API client is like a post office—it handles the details of sending and receiving messages, checks for delivery issues, and makes sure messages reach the right destination.

We'll build a robust API client that handles:
- Authentication tokens
- Request/response logging
- Error handling
- Retry logic
- Offline queueing

### The Implementation: Complete API Client

#### Step 2.4.1: Install API Dependencies

```bash
$ npm install @supabase/supabase-js @supabase/realtime-js
$ npm install axios
$ npm install react-query
```

#### Step 2.4.2: Create Supabase Client

```typescript
// src/api/supabase.ts
import { createClient } from '@supabase/supabase-js';
import * as SecureStore from 'expo-secure-store';
import { CONFIG } from '@constants/config';
import { Platform } from 'react-native';

/**
 * Custom SecureStore adapter for Supabase
 * Ensures session data is stored securely using Expo SecureStore
 */
const ExpoSecureStoreAdapter = {
  getItem: async (key: string) => {
    try {
      const value = await SecureStore.getItemAsync(key);
      return value ?? null;
    } catch {
      return null;
    }
  },
  setItem: async (key: string, value: string) => {
    await SecureStore.setItemAsync(key, value);
  },
  removeItem: async (key: string) => {
    await SecureStore.deleteItemAsync(key);
  },
};

/**
 * Supabase Client Configuration
 * 
 * Creates a singleton Supabase client with:
 * - Custom storage for session persistence
 * - Automatic token refresh
 * - Realtime subscriptions support
 * - Offline capabilities
 */
export const supabase = createClient(
  CONFIG.supabase.url,
  CONFIG.supabase.anonKey,
  {
    auth: {
      storage: ExpoSecureStoreAdapter,
      autoRefreshToken: true,
      persistSession: true,
      detectSessionInUrl: false,
      flowType: 'pkce', // More secure OAuth flow
    },
    realtime: {
      params: {
        eventsPerSecond: 10,
      },
    },
    db: {
      schema: 'public',
    },
  }
);

// Add request/response logging in development
if (CONFIG.isDevelopment) {
  const originalFetch = supabase.rest.fetch.bind(supabase.rest);
  supabase.rest.fetch = async (url, options) => {
    console.log(`[Supabase Request] ${url}`);
    console.log('[Supabase Options]', options);
    
    try {
      const response = await originalFetch(url, options);
      console.log('[Supabase Response]', response);
      return response;
    } catch (error) {
      console.error('[Supabase Error]', error);
      throw error;
    }
  };
}
```

#### Step 2.4.3: Create Axios Client (for external APIs)

```typescript
// src/api/axios.ts
import axios from 'axios';
import { Platform } from 'react-native';
import { CONFIG } from '@constants/config';
import { useAuthStore } from '@store';

/**
 * Axios Client Configuration
 * 
 * Handles all non-Supabase API calls with:
 * - Automatic token injection
 * - Request/response interceptors
 * - Global error handling
 * - Retry logic
 * - Network detection
 */

// Create axios instance with base configuration
export const apiClient = axios.create({
  baseURL: CONFIG.api.baseUrl,
  timeout: CONFIG.api.timeout,
  headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'X-Platform': Platform.OS,
    'X-App-Version': '1.0.0',
  },
});

// Request interceptor - adds auth token and logs
apiClient.interceptors.request.use(
  async (config) => {
    // Get auth token from store
    const authState = useAuthStore.getState();
    const token = authState.user?.id; // Will use JWT in Part 3
    
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    
    // Log request in development
    if (CONFIG.isDevelopment) {
      console.log(`[API Request] ${config.method?.toUpperCase()} ${config.url}`);
      console.log('[Request Headers]', config.headers);
      if (config.data) {
        console.log('[Request Body]', config.data);
      }
    }
    
    return config;
  },
  (error) => {
    console.error('[Request Error]', error);
    return Promise.reject(error);
  }
);

// Response interceptor - handles responses and errors
apiClient.interceptors.response.use(
  (response) => {
    // Log response in development
    if (CONFIG.isDevelopment) {
      console.log(`[API Response] ${response.status} ${response.config.url}`);
      console.log('[Response Data]', response.data);
    }
    return response;
  },
  async (error) => {
    const originalRequest = error.config;
    
    // Handle network errors
    if (!error.response) {
      console.error('[Network Error] No response from server');
      return Promise.reject({
        message: 'Network error. Please check your internet connection.',
        originalError: error,
      });
    }
    
    // Handle 401 (Unauthorized) - token expired
    if (error.response.status === 401 && !originalRequest._retry) {
      originalRequest._retry = true;
      try {
        // Attempt to refresh token (will be implemented in Part 3)
        // await refreshAuthToken();
        // Retry the original request
        return apiClient(originalRequest);
      } catch (refreshError) {
        // If refresh fails, log out the user
        useAuthStore.getState().logout();
        return Promise.reject({
          message: 'Session expired. Please log in again.',
          originalError: refreshError,
        });
      }
    }
    
    // Handle other HTTP errors
    const errorMessage = error.response.data?.message || error.message || 'An error occurred';
    console.error(`[API Error] ${error.response.status}`, errorMessage);
    
    return Promise.reject({
      status: error.response.status,
      message: errorMessage,
      data: error.response.data,
      originalError: error,
    });
  }
);

// Utility function for API calls with retry logic
export const apiCallWithRetry = async <T>(
  apiCall: () => Promise<T>,
  maxRetries: number = 3,
  delay: number = 1000
): Promise<T> => {
  let lastError: any;
  
  for (let attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      return await apiCall();
    } catch (error) {
      lastError = error;
      if (attempt < maxRetries) {
        console.log(`Retrying request (${attempt}/${maxRetries})...`);
        await new Promise(resolve => setTimeout(resolve, delay * attempt));
      }
    }
  }
  
  throw lastError;
};
```

#### Step 2.4.4: Create API Services

```typescript
// src/api/services/authService.ts
import { supabase } from '@api/supabase';
import { apiClient } from '@api/axios';
import { User } from '@types';
import { useAuthStore } from '@store';

/**
 * Authentication Service
 * 
 * Handles all authentication-related API calls:
 * - Login with email/password
 * - Registration
 * - Password reset
 * - Social login (Google, Apple)
 * - Session management
 * - Profile updates
 */

export interface LoginCredentials {
  email: string;
  password: string;
}

export interface RegisterData extends LoginCredentials {
  fullName: string;
  confirmPassword: string;
}

export interface AuthResponse {
  user: User;
  session: {
    accessToken: string;
    refreshToken: string;
    expiresAt: number;
  };
}

export const authService = {
  /**
   * Login with email and password
   */
  login: async (credentials: LoginCredentials): Promise<AuthResponse> => {
    const { data, error } = await supabase.auth.signInWithPassword({
      email: credentials.email,
      password: credentials.password,
    });

    if (error) {
      throw new Error(error.message);
    }

    if (!data.user || !data.session) {
      throw new Error('No user or session returned');
    }

    // Transform Supabase user to our User type
    const user: User = {
      id: data.user.id,
      email: data.user.email!,
      fullName: data.user.user_metadata?.full_name || '',
      avatarUrl: data.user.user_metadata?.avatar_url,
      createdAt: new Date(data.user.created_at),
      updatedAt: new Date(data.user.updated_at),
    };

    // Update auth store
    useAuthStore.getState().setUser(user);
    useAuthStore.getState().setAuthenticated(true);

    return {
      user,
      session: {
        accessToken: data.session.access_token,
        refreshToken: data.session.refresh_token,
        expiresAt: data.session.expires_at || Date.now() + 3600000,
      },
    };
  },

  /**
   * Register a new user
   */
  register: async (data: RegisterData): Promise<AuthResponse> => {
    // Validate passwords match
    if (data.password !== data.confirmPassword) {
      throw new Error('Passwords do not match');
    }

    const { data: authData, error } = await supabase.auth.signUp({
      email: data.email,
      password: data.password,
      options: {
        data: {
          full_name: data.fullName,
        },
      },
    });

    if (error) {
      throw new Error(error.message);
    }

    if (!authData.user || !authData.session) {
      throw new Error('Registration failed');
    }

    const user: User = {
      id: authData.user.id,
      email: authData.user.email!,
      fullName: data.fullName,
      createdAt: new Date(authData.user.created_at),
      updatedAt: new Date(authData.user.updated_at),
    };

    useAuthStore.getState().setUser(user);
    useAuthStore.getState().setAuthenticated(true);

    return {
      user,
      session: {
        accessToken: authData.session.access_token,
        refreshToken: authData.session.refresh_token,
        expiresAt: authData.session.expires_at || Date.now() + 3600000,
      },
    };
  },

  /**
   * Logout the current user
   */
  logout: async (): Promise<void> => {
    const { error } = await supabase.auth.signOut();
    if (error) {
      throw new Error(error.message);
    }
    useAuthStore.getState().logout();
  },

  /**
   * Reset password (send reset email)
   */
  resetPassword: async (email: string): Promise<void> => {
    const { error } = await supabase.auth.resetPasswordForEmail(email, {
      redirectTo: 'nexuscollect://reset-password',
    });
    if (error) {
      throw new Error(error.message);
    }
  },

  /**
   * Update user profile
   */
  updateProfile: async (userId: string, updates: Partial<User>): Promise<User> => {
    const { data, error } = await supabase
      .from('profiles')
      .update({
        full_name: updates.fullName,
        avatar_url: updates.avatarUrl,
        updated_at: new Date().toISOString(),
      })
      .eq('id', userId)
      .select()
      .single();

    if (error) {
      throw new Error(error.message);
    }

    const updatedUser: User = {
      id: data.id,
      email: data.email,
      fullName: data.full_name,
      avatarUrl: data.avatar_url,
      createdAt: new Date(data.created_at),
      updatedAt: new Date(data.updated_at),
    };

    useAuthStore.getState().updateUser(updatedUser);
    return updatedUser;
  },

  /**
   * Get current user session
   */
  getSession: async () => {
    const { data, error } = await supabase.auth.getSession();
    if (error) {
      throw new Error(error.message);
    }
    return data.session;
  },

  /**
   * Refresh the current session
   */
  refreshSession: async (): Promise<void> => {
    const { data, error } = await supabase.auth.refreshSession();
    if (error) {
      throw new Error(error.message);
    }
    if (data.user) {
      const user: User = {
        id: data.user.id,
        email: data.user.email!,
        fullName: data.user.user_metadata?.full_name || '',
        avatarUrl: data.user.user_metadata?.avatar_url,
        createdAt: new Date(data.user.created_at),
        updatedAt: new Date(data.user.updated_at),
      };
      useAuthStore.getState().setUser(user);
    }
  },
};
```

---

## Phase 2.5: Theme System and Styling

### The Concept: Consistent Visual Identity

A theme system is like a brand style guide for your app. It defines:
- Colors (primary, secondary, background, text)
- Typography (fonts, sizes, weights)
- Spacing (margins, paddings)
- Component styles (buttons, inputs, cards)

By centralizing these decisions, we ensure visual consistency and make it easy to update the app's appearance.

### The Implementation: Complete Theme System

#### Step 2.5.1: Create Theme Configuration

```typescript
// src/themes/colors.ts
/**
 * Color Palette
 * 
 * Defines all colors used in the application.
 * Using a consistent naming convention for maintainability.
 */

export const colors = {
  // Primary brand colors
  primary: {
    50: '#e8f4fd',
    100: '#d1e9fb',
    200: '#a3d3f7',
    300: '#75bdf3',
    400: '#47a7ef',
    500: '#2196F3', // Primary
    600: '#1a78c2',
    700: '#145a92',
    800: '#0d3c61',
    900: '#071e31',
  },
  
  // Secondary colors
  secondary: {
    50: '#fce8e6',
    100: '#f9d1cc',
    200: '#f3a399',
    300: '#ed7566',
    400: '#e74733',
    500: '#E74C3C', // Secondary
    600: '#b93d30',
    700: '#8b2e24',
    800: '#5c1e18',
    900: '#2e0f0c',
  },
  
  // Success, Warning, Error, Info
  success: '#2ECC71',
  warning: '#F39C12',
  error: '#E74C3C',
  info: '#3498DB',
  
  // Neutral colors
  gray: {
    50: '#f8f9fa',
    100: '#f1f3f5',
    200: '#e9ecef',
    300: '#dee2e6',
    400: '#ced4da',
    500: '#adb5bd',
    600: '#6c757d',
    700: '#495057',
    800: '#343a40',
    900: '#212529',
  },
  
  // Semantic colors
  background: '#ffffff',
  surface: '#f8f9fa',
  text: '#212529',
  textSecondary: '#6c757d',
  border: '#dee2e6',
  shadow: 'rgba(0, 0, 0, 0.1)',
  
  // Status colors
  status: {
    online: '#2ECC71',
    offline: '#6c757d',
    syncing: '#3498DB',
    error: '#E74C3C',
  },
} as const;

export type ColorTheme = typeof colors;
```

```typescript
// src/themes/spacing.ts
/**
 * Spacing System
 * 
 * Defines consistent spacing values following an 8px grid system.
 * Use these values for all margins, paddings, and gaps.
 */

export const spacing = {
  xs: 4,
  sm: 8,
  md: 16,
  lg: 24,
  xl: 32,
  xxl: 48,
  xxxl: 64,
  
  // Semantic spacing
  padding: {
    screen: 16,
    card: 16,
    button: 12,
    input: 12,
  },
  
  margin: {
    screen: 16,
    card: 16,
    button: 8,
    input: 8,
  },
  
  gap: {
    xs: 4,
    sm: 8,
    md: 12,
    lg: 16,
    xl: 24,
  },
} as const;

export type SpacingTheme = typeof spacing;
```

```typescript
// src/themes/typography.ts
/**
 * Typography System
 * 
 * Defines consistent typography using system fonts.
 * For production, you'd use custom fonts loaded from assets.
 */

import { Platform } from 'react-native';

// System font family
const fontFamily = Platform.select({
  ios: 'System',
  android: 'Roboto',
  default: 'System',
});

export const typography = {
  // Font families
  fontFamily,
  fontFamilyBold: Platform.select({
    ios: 'System',
    android: 'Roboto-Bold',
    default: 'System',
  }),
  
  // Font sizes
  fontSize: {
    xs: 12,
    sm: 14,
    md: 16,
    lg: 18,
    xl: 20,
    xxl: 24,
    xxxl: 32,
    huge: 40,
  },
  
  // Line heights
  lineHeight: {
    xs: 16,
    sm: 20,
    md: 24,
    lg: 28,
    xl: 32,
    xxl: 36,
    xxxl: 44,
    huge: 52,
  },
  
  // Font weights
  weight: {
    light: '300' as const,
    regular: '400' as const,
    medium: '500' as const,
    semibold: '600' as const,
    bold: '700' as const,
    extrabold: '800' as const,
  },
  
  // Predefined text variants
  variants: {
    h1: {
      fontSize: 32,
      fontWeight: 'bold' as const,
      lineHeight: 44,
    },
    h2: {
      fontSize: 24,
      fontWeight: 'bold' as const,
      lineHeight: 32,
    },
    h3: {
      fontSize: 20,
      fontWeight: '600' as const,
      lineHeight: 28,
    },
    body: {
      fontSize: 16,
      fontWeight: '400' as const,
      lineHeight: 24,
    },
    bodyLarge: {
      fontSize: 18,
      fontWeight: '400' as const,
      lineHeight: 28,
    },
    bodySmall: {
      fontSize: 14,
      fontWeight: '400' as const,
      lineHeight: 20,
    },
    caption: {
      fontSize: 12,
      fontWeight: '400' as const,
      lineHeight: 16,
    },
    button: {
      fontSize: 16,
      fontWeight: '600' as const,
      lineHeight: 24,
    },
  },
} as const;

export type TypographyTheme = typeof typography;
```

```typescript
// src/themes/index.ts
/**
 * Theme System
 * 
 * Combines all theme elements into a cohesive theme object.
 * Supports light and dark modes with easy extensibility.
 */

import { colors } from './colors';
import { spacing } from './spacing';
import { typography } from './typography';
import { StyleSheet } from 'react-native';

// Light theme (default)
export const lightTheme = {
  colors,
  spacing,
  typography,
  dark: false,
  roundness: 8,
  
  // Component-specific styles
  components: {
    button: {
      primary: {
        backgroundColor: colors.primary[500],
        textColor: '#ffffff',
        paddingVertical: spacing.md,
        paddingHorizontal: spacing.lg,
        borderRadius: 8,
      },
      secondary: {
        backgroundColor: 'transparent',
        textColor: colors.primary[500],
        borderColor: colors.primary[500],
        borderWidth: 1,
        paddingVertical: spacing.md,
        paddingHorizontal: spacing.lg,
        borderRadius: 8,
      },
      danger: {
        backgroundColor: colors.error,
        textColor: '#ffffff',
        paddingVertical: spacing.md,
        paddingHorizontal: spacing.lg,
        borderRadius: 8,
      },
    },
    card: {
      backgroundColor: '#ffffff',
      borderRadius: 12,
      padding: spacing.md,
      shadowColor: colors.shadow,
      shadowOffset: { width: 0, height: 2 },
      shadowOpacity: 0.1,
      shadowRadius: 4,
      elevation: 3,
    },
    input: {
      backgroundColor: colors.background,
      borderColor: colors.border,
      borderWidth: 1,
      borderRadius: 8,
      paddingHorizontal: spacing.md,
      paddingVertical: spacing.md,
      fontSize: typography.fontSize.md,
      color: colors.text,
    },
  },
};

// Dark theme
export const darkTheme = {
  ...lightTheme,
  dark: true,
  colors: {
    ...colors,
    background: '#121212',
    surface: '#1e1e1e',
    text: '#ffffff',
    textSecondary: '#9e9e9e',
    border: '#333333',
    shadow: 'rgba(0, 0, 0, 0.5)',
  },
  components: {
    ...lightTheme.components,
    card: {
      ...lightTheme.components.card,
      backgroundColor: '#1e1e1e',
    },
    input: {
      ...lightTheme.components.input,
      backgroundColor: '#2c2c2c',
      borderColor: '#444444',
      color: '#ffffff',
    },
  },
};

export type Theme = typeof lightTheme;

// Theme context and hook
import React, { createContext, useContext } from 'react';
import { useSettingsStore } from '@store';

const ThemeContext = createContext<Theme>(lightTheme);

export const ThemeProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const theme = useSettingsStore((state) => state.settings.theme);
  
  // Determine which theme to use
  // For now, we'll use light/dark based on setting
  // System theme would require using react-native-appearance
  const currentTheme = theme === 'dark' ? darkTheme : lightTheme;
  
  return (
    <ThemeContext.Provider value={currentTheme}>
      {children}
    </ThemeContext.Provider>
  );
};

export const useTheme = () => {
  const context = useContext(ThemeContext);
  if (!context) {
    throw new Error('useTheme must be used within a ThemeProvider');
  }
  return context;
};

// Helper to create styles with theme
export const createThemedStyles = <T extends StyleSheet.NamedStyles<T>>(
  styles: (theme: Theme) => T
) => {
  return (theme: Theme) => StyleSheet.create(styles(theme));
};
```

---

## Phase 2.6: Base Components

### The Concept: Building Blocks

Base components are the LEGO bricks of your UI. They're reusable pieces that you combine to build screens. By creating a library of base components, you ensure:
- Consistent design across the app
- Faster development (don't rebuild the same things)
- Easier maintenance (change one place, update everywhere)

### The Implementation: Core UI Components

```typescript
// src/components/common/Button.tsx
import React from 'react';
import {
  TouchableOpacity,
  Text,
  StyleSheet,
  ActivityIndicator,
  ViewStyle,
  TextStyle,
} from 'react-native';
import { useTheme } from '@themes';

interface ButtonProps {
  title: string;
  onPress: () => void;
  variant?: 'primary' | 'secondary' | 'danger' | 'outline';
  size?: 'small' | 'medium' | 'large';
  disabled?: boolean;
  loading?: boolean;
  style?: ViewStyle;
  textStyle?: TextStyle;
}

/**
 * Button Component
 * 
 * A fully customizable button with multiple variants and sizes.
 * 
 * Example:
 * <Button 
 *   title="Login" 
 *   onPress={handleLogin} 
 *   variant="primary" 
 *   size="large" 
 * />
 */
export const Button: React.FC<ButtonProps> = ({
  title,
  onPress,
  variant = 'primary',
  size = 'medium',
  disabled = false,
  loading = false,
  style,
  textStyle,
}) => {
  const theme = useTheme();
  
  const getVariantStyles = (): ViewStyle => {
    switch (variant) {
      case 'primary':
        return {
          backgroundColor: theme.colors.primary[500],
        };
      case 'secondary':
        return {
          backgroundColor: 'transparent',
          borderWidth: 1,
          borderColor: theme.colors.primary[500],
        };
      case 'danger':
        return {
          backgroundColor: theme.colors.error,
        };
      case 'outline':
        return {
          backgroundColor: 'transparent',
          borderWidth: 1,
          borderColor: theme.colors.border,
        };
      default:
        return {};
    }
  };
  
  const getSizeStyles = (): ViewStyle => {
    switch (size) {
      case 'small':
        return {
          paddingVertical: theme.spacing.sm,
          paddingHorizontal: theme.spacing.md,
        };
      case 'large':
        return {
          paddingVertical: theme.spacing.lg,
          paddingHorizontal: theme.spacing.xl,
        };
      default:
        return {
          paddingVertical: theme.spacing.md,
          paddingHorizontal: theme.spacing.lg,
        };
    }
  };
  
  const getTextColor = (): string => {
    switch (variant) {
      case 'primary':
      case 'danger':
        return '#ffffff';
      case 'secondary':
        return theme.colors.primary[500];
      default:
        return theme.colors.text;
    }
  };
  
  return (
    <TouchableOpacity
      onPress={onPress}
      disabled={disabled || loading}
      style={[
        styles.button,
        getVariantStyles(),
        getSizeStyles(),
        { borderRadius: theme.roundness },
        disabled && styles.disabled,
        style,
      ]}
      activeOpacity={0.7}
    >
      {loading ? (
        <ActivityIndicator
          color={variant === 'primary' || variant === 'danger' ? '#ffffff' : theme.colors.primary[500]}
          size="small"
        />
      ) : (
        <Text
          style={[
            styles.text,
            {
              color: getTextColor(),
              fontSize: theme.typography.variants.button.fontSize,
              fontWeight: theme.typography.variants.button.fontWeight as any,
            },
            textStyle,
          ]}
        >
          {title}
        </Text>
      )}
    </TouchableOpacity>
  );
};

const styles = StyleSheet.create({
  button: {
    alignItems: 'center',
    justifyContent: 'center',
    minHeight: 44,
  },
  text: {
    textAlign: 'center',
  },
  disabled: {
    opacity: 0.5,
  },
});
```

```typescript
// src/components/common/Input.tsx
import React, { useState } from 'react';
import {
  View,
  TextInput,
  Text,
  StyleSheet,
  TextInputProps,
  ViewStyle,
  TextStyle,
} from 'react-native';
import { useTheme } from '@themes';
import { Ionicons } from '@expo/vector-icons';

interface InputProps extends TextInputProps {
  label?: string;
  error?: string;
  touched?: boolean;
  leftIcon?: keyof typeof Ionicons.glyphMap;
  rightIcon?: keyof typeof Ionicons.glyphMap;
  onRightIconPress?: () => void;
  containerStyle?: ViewStyle;
  inputStyle?: TextStyle;
  labelStyle?: TextStyle;
}

/**
 * Input Component
 * 
 * A form input with label, error handling, and icon support.
 * 
 * Example:
 * <Input
 *   label="Email"
 *   value={email}
 *   onChangeText={setEmail}
 *   error={errors.email}
 *   touched={touched.email}
 *   leftIcon="mail-outline"
 * />
 */
export const Input: React.FC<InputProps> = ({
  label,
  error,
  touched,
  leftIcon,
  rightIcon,
  onRightIconPress,
  containerStyle,
  inputStyle,
  labelStyle,
  secureTextEntry,
  ...rest
}) => {
  const theme = useTheme();
  const [isFocused, setIsFocused] = useState(false);
  const [isSecureVisible, setIsSecureVisible] = useState(false);

  const showError = touched && error;
  const isSecure = secureTextEntry && !isSecureVisible;

  const getBorderColor = () => {
    if (showError) return theme.colors.error;
    if (isFocused) return theme.colors.primary[500];
    return theme.colors.border;
  };

  return (
    <View style={[styles.container, containerStyle]}>
      {label && (
        <Text
          style={[
            styles.label,
            {
              color: theme.colors.text,
              fontSize: theme.typography.fontSize.sm,
              fontWeight: '500',
            },
            labelStyle,
          ]}
        >
          {label}
        </Text>
      )}
      
      <View
        style={[
          styles.inputContainer,
          {
            borderColor: getBorderColor(),
            borderWidth: 1,
            borderRadius: theme.roundness,
            backgroundColor: theme.colors.background,
          },
        ]}
      >
        {leftIcon && (
          <Ionicons
            name={leftIcon}
            size={20}
            color={theme.colors.textSecondary}
            style={styles.leftIcon}
          />
        )}
        
        <TextInput
          style={[
            styles.input,
            {
              color: theme.colors.text,
              fontSize: theme.typography.fontSize.md,
              fontFamily: theme.typography.fontFamily,
            },
            inputStyle,
          ]}
          placeholderTextColor={theme.colors.textSecondary}
          onFocus={() => setIsFocused(true)}
          onBlur={() => setIsFocused(false)}
          secureTextEntry={isSecure}
          {...rest}
        />
        
        {rightIcon && (
          <Ionicons
            name={rightIcon}
            size={20}
            color={theme.colors.textSecondary}
            style={styles.rightIcon}
            onPress={onRightIconPress}
          />
        )}
        
        {secureTextEntry && (
          <Ionicons
            name={isSecureVisible ? 'eye-off-outline' : 'eye-outline'}
            size={20}
            color={theme.colors.textSecondary}
            style={styles.rightIcon}
            onPress={() => setIsSecureVisible(!isSecureVisible)}
          />
        )}
      </View>
      
      {showError && (
        <Text
          style={[
            styles.error,
            {
              color: theme.colors.error,
              fontSize: theme.typography.fontSize.sm,
            },
          ]}
        >
          {error}
        </Text>
      )}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    marginBottom: 16,
  },
  label: {
    marginBottom: 8,
  },
  inputContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 12,
    minHeight: 48,
  },
  input: {
    flex: 1,
    paddingVertical: 12,
    paddingHorizontal: 8,
  },
  leftIcon: {
    marginRight: 8,
  },
  rightIcon: {
    marginLeft: 8,
  },
  error: {
    marginTop: 4,
  },
});
```

```typescript
// src/components/common/Card.tsx
import React from 'react';
import { View, StyleSheet, ViewStyle } from 'react-native';
import { useTheme } from '@themes';

interface CardProps {
  children: React.ReactNode;
  style?: ViewStyle;
  elevation?: boolean;
  padding?: keyof typeof spacing;
}

/**
 * Card Component
 * 
 * A container for grouping related content with
 * consistent shadow and spacing.
 * 
 * Example:
 * <Card elevation padding="md">
 *   <Text>Card content</Text>
 * </Card>
 */
export const Card: React.FC<CardProps> = ({
  children,
  style,
  elevation = true,
  padding = 'md',
}) => {
  const theme = useTheme();
  const spacingValue = theme.spacing[padding] || theme.spacing.md;
  
  return (
    <View
      style={[
        styles.card,
        {
          backgroundColor: theme.components.card.backgroundColor,
          borderRadius: theme.components.card.borderRadius,
          padding: spacingValue,
        },
        elevation && {
          shadowColor: theme.components.card.shadowColor,
          shadowOffset: theme.components.card.shadowOffset,
          shadowOpacity: theme.components.card.shadowOpacity,
          shadowRadius: theme.components.card.shadowRadius,
          elevation: theme.components.card.elevation,
        },
        style,
      ]}
    >
      {children}
    </View>
  );
};

const styles = StyleSheet.create({
  card: {
    marginVertical: 4,
  },
});
```

---

## Phase 2.7: Custom Hooks

### The Concept: Reusable Logic

Custom hooks let you extract and reuse logic across multiple components. They're like utility functions for React—instead of duplicating code, you write it once and reuse it.

### The Implementation: Essential Hooks

```typescript
// src/hooks/useAuth.ts
import { useAuthStore } from '@store';
import { authService } from '@api/services/authService';
import { useState } from 'react';

/**
 * Authentication Hook
 * 
 * Provides authentication-related functionality to components.
 * Abstracts away the complexity of authentication logic.
 */
export const useAuth = () => {
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  
  const authState = useAuthStore();
  
  /**
   * Initialize authentication state
   * Check for existing session on app start
   */
  const initializeAuth = async () => {
    try {
      setIsLoading(true);
      const session = await authService.getSession();
      if (session) {
        // User is already authenticated
        const { data } = await authService.getSession();
        if (data?.user) {
          authState.setUser({
            id: data.user.id,
            email: data.user.email!,
            fullName: data.user.user_metadata?.full_name || '',
            avatarUrl: data.user.user_metadata?.avatar_url,
            createdAt: new Date(data.user.created_at),
            updatedAt: new Date(data.user.updated_at),
          });
          authState.setAuthenticated(true);
        }
      }
    } catch (err) {
      console.error('Auth initialization error:', err);
    } finally {
      setIsLoading(false);
    }
  };
  
  /**
   * Login with email and password
   */
  const login = async (email: string, password: string) => {
    try {
      setIsLoading(true);
      setError(null);
      await authService.login({ email, password });
      return { success: true };
    } catch (err: any) {
      const errorMessage = err.message || 'Login failed';
      setError(errorMessage);
      authState.setError(errorMessage);
      return { success: false, error: errorMessage };
    } finally {
      setIsLoading(false);
    }
  };
  
  /**
   * Register a new user
   */
  const register = async (email: string, password: string, fullName: string) => {
    try {
      setIsLoading(true);
      setError(null);
      await authService.register({ email, password, fullName, confirmPassword: password });
      return { success: true };
    } catch (err: any) {
      const errorMessage = err.message || 'Registration failed';
      setError(errorMessage);
      authState.setError(errorMessage);
      return { success: false, error: errorMessage };
    } finally {
      setIsLoading(false);
    }
  };
  
  /**
   * Logout the user
   */
  const logout = async () => {
    try {
      setIsLoading(true);
      await authService.logout();
      return { success: true };
    } catch (err: any) {
      const errorMessage = err.message || 'Logout failed';
      setError(errorMessage);
      return { success: false, error: errorMessage };
    } finally {
      setIsLoading(false);
    }
  };
  
  /**
   * Update user profile
   */
  const updateProfile = async (updates: { fullName?: string; avatarUrl?: string }) => {
    try {
      setIsLoading(true);
      setError(null);
      const user = authState.user;
      if (!user) throw new Error('No user logged in');
      
      const updatedUser = await authService.updateProfile(user.id, updates);
      return { success: true, user: updatedUser };
    } catch (err: any) {
      const errorMessage = err.message || 'Profile update failed';
      setError(errorMessage);
      return { success: false, error: errorMessage };
    } finally {
      setIsLoading(false);
    }
  };
  
  return {
    ...authState,
    isLoading,
    error,
    initializeAuth,
    login,
    register,
    logout,
    updateProfile,
  };
};
```

```typescript
// src/hooks/useDebounce.ts
import { useState, useEffect } from 'react';

/**
 * Debounce Hook
 * 
 * Delays the update of a value until after a specified delay.
 * Useful for search inputs to avoid excessive API calls.
 * 
 * Example:
 * const debouncedSearch = useDebounce(searchTerm, 500);
 */
export const useDebounce = <T>(value: T, delay: number = 500): T => {
  const [debouncedValue, setDebouncedValue] = useState<T>(value);

  useEffect(() => {
    const timer = setTimeout(() => {
      setDebouncedValue(value);
    }, delay);

    return () => {
      clearTimeout(timer);
    };
  }, [value, delay]);

  return debouncedValue;
};
```

```typescript
// src/hooks/useAppState.ts
import { useEffect, useState } from 'react';
import { AppState, AppStateStatus } from 'react-native';

/**
 * App State Hook
 * 
 * Tracks whether the app is in foreground, background, or inactive.
 * Useful for pausing/resuming activities when app is backgrounded.
 * 
 * Example:
 * const { appState, isActive } = useAppState();
 */
export const useAppState = () => {
  const [appState, setAppState] = useState<AppStateStatus>(AppState.currentState);
  const [isActive, setIsActive] = useState(appState === 'active');

  useEffect(() => {
    const subscription = AppState.addEventListener('change', (nextAppState) => {
      setAppState(nextAppState);
      setIsActive(nextAppState === 'active');
    });

    return () => {
      subscription.remove();
    };
  }, []);

  return { appState, isActive };
};
```

---

## Phase 2.8: Integration Testing

### The Concept: Verification

Now that we've built all the pieces, we need to verify everything works together. This is where we test the integration of all components—navigation, state, API, and UI.

### The Implementation: App Integration

```typescript
// app/index.tsx (Complete App Entry)
import React from 'react';
import { SafeAreaProvider } from 'react-native-safe-area-context';
import { ThemeProvider } from '@themes';
import { RootNavigator } from '@navigation/RootNavigator';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { ErrorBoundary } from 'react-error-boundary';

/**
 * App Entry Point
 * 
 * The root component that wraps the entire application with:
 * - SafeAreaProvider: Handles safe area insets
 * - ThemeProvider: Provides theme context
 * - QueryClientProvider: React Query for data fetching
 * - ErrorBoundary: Global error handling
 * - RootNavigator: Navigation system
 */

// Create React Query client
const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 5 * 60 * 1000, // 5 minutes
      cacheTime: 10 * 60 * 1000, // 10 minutes
      retry: 2,
      refetchOnWindowFocus: false,
    },
  },
});

// Error fallback component
const ErrorFallback = ({ error, resetErrorBoundary }: any) => (
  <SafeAreaProvider>
    <ThemeProvider>
      <RootNavigator />
    </ThemeProvider>
  </SafeAreaProvider>
);

export default function App() {
  return (
    <ErrorBoundary
      FallbackComponent={ErrorFallback}
      onReset={() => {
        // Reset the app state
        console.log('Error boundary reset');
      }}
    >
      <SafeAreaProvider>
        <QueryClientProvider client={queryClient}>
          <ThemeProvider>
            <RootNavigator />
          </ThemeProvider>
        </QueryClientProvider>
      </SafeAreaProvider>
    </ErrorBoundary>
  );
}
```

### The Verification

```bash
# Check TypeScript compilation
$ npx tsc --noEmit

# Run the application
$ npx expo start --clear

# Verify the following:
# 1. App launches without errors
# 2. Splash screen shows briefly
# 3. You see the authentication flow (Login/Register screens)
# 4. Navigation works between screens
# 5. Theme system works (colors, spacing, typography)
# 6. Zustand stores are initialized
# 7. API client is configured

# Test the app in both iOS and Android
$ npx expo run:ios
$ npx expo run:android

# Expected results:
# - Both platforms show the app consistently
# - No red screens or errors
# - Navigation transitions work smoothly
# - State persists across navigation
```

---

## Part 2 Summary

### ✅ Completed

1. **Architecture Design**
   - Clear separation of concerns
   - Documented architecture layers
   - Organized folder structure

2. **Navigation System**
   - Authentication stack
   - Main tab navigator
   - Root navigator with auth awareness
   - Deep linking preparation

3. **State Management**
   - Auth store with persistence
   - Settings store with persistence
   - Form store
   - Unified store access

4. **API Client**
   - Supabase integration
   - Axios configuration
   - Authentication service
   - Request/response interceptors

5. **Theme System**
   - Color palette
   - Spacing system
   - Typography
   - Light/dark theme support

6. **Base Components**
   - Button with variants
   - Input with validation
   - Card container

7. **Custom Hooks**
   - Authentication hook
   - Debounce hook
   - App state hook

8. **Integration**
   - All systems working together
   - Error handling
   - Type safety throughout

### Key Concepts Learned

- **Architecture Patterns:** Separation of concerns, unidirectional data flow
- **Navigation:** Stack and tab navigators, authentication flows
- **State Management:** Zustand stores, persistence, middleware
- **API Integration:** Supabase, Axios, interceptors
- **Theming:** Design systems, dark/light mode
- **Component Design:** Reusable components, props, styling
- **Custom Hooks:** Logic extraction and reuse

### What's Coming in Part 3

In **Part 3: Backend Integration & Authentication**, you'll:
- Complete the Supabase backend setup with database tables
- Implement row-level security (RLS)
- Build the complete authentication flow
- Add social login (Google, Apple)
- Implement secure session management
- Create user profile management
- Set up real-time subscriptions
- Build protected API endpoints

---

## Quick Reference: Architecture Commands

```bash
# Type Checking
$ npx tsc --noEmit          # Check types without emitting files
$ npx tsc --watch           # Watch mode for type checking

# Navigation Testing
$ npx expo start --clear    # Clear cache and start

# Store Testing
$ npm run test store        # Test store logic

# API Testing
$ npx expo start --tunnel   # For testing on physical devices
```
