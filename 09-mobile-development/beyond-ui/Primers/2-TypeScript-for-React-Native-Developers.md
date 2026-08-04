# Primer 2: TypeScript for React Native Developers

## Your Quick-Start Guide to Type-Safe Mobile Development

Welcome to the TypeScript Primer! This guide is designed to get you comfortable with TypeScript in the context of React Native development. TypeScript is a superset of JavaScript that adds static type checking. Think of it as JavaScript with a safety net - it catches errors before you even run your code.

---

## TS.1 Why TypeScript?

### The Concept: Catching Errors Before They Happen

TypeScript adds types to JavaScript, which helps you catch errors during development rather than at runtime. It's like having a proofreader who checks your code for mistakes before you ship it.

**Simple Analogy:** Imagine building with LEGO bricks. JavaScript is like having all the bricks mixed together - you can build anything, but you might accidentally use the wrong piece. TypeScript is like having labeled compartments for each brick type - you know exactly which piece fits where.

### Benefits of TypeScript

```typescript
// ❌ JavaScript - No type checking
function add(a, b) {
  return a + b;
}

add(5, '10'); // Returns '510' - bug! But no error

// ✅ TypeScript - Type checking
function add(a: number, b: number): number {
  return a + b;
}

add(5, 10); // ✅ Works
add(5, '10'); // ❌ TypeScript error: Argument of type 'string' is not assignable to parameter of type 'number'
```

---

## TS.2 Basic Types

### The Concept: The Building Blocks

TypeScript provides several basic types that you'll use constantly.

### Complete Type Guide

```typescript
// 1. Primitive Types
let name: string = 'John';              // String
let age: number = 30;                   // Number (integer or float)
let isActive: boolean = true;           // Boolean
let nothing: null = null;               // Null
let undefined: undefined = undefined;   // Undefined
let anything: any = 'hello';            // Any (use sparingly!)
let unknown: unknown = 42;              // Unknown (safer than any)

// 2. Arrays
let numbers: number[] = [1, 2, 3];      // Array of numbers
let strings: Array<string> = ['a', 'b']; // Another way
let mixed: (string | number)[] = [1, 'two']; // Union types in arrays

// 3. Tuples (fixed-length arrays)
let user: [string, number] = ['John', 30]; // Tuple
// user = [30, 'John']; ❌ - Type error

// 4. Objects
let person: { name: string; age: number } = {
  name: 'John',
  age: 30,
};

// 5. Type Aliases
type User = {
  id: string;
  name: string;
  email: string;
  age?: number; // Optional property
};

const user: User = {
  id: '123',
  name: 'John',
  email: 'john@example.com',
};

// 6. Interfaces (similar to type aliases, but with different capabilities)
interface Product {
  id: string;
  name: string;
  price: number;
  description?: string;
}

const product: Product = {
  id: 'p1',
  name: 'Laptop',
  price: 999.99,
};

// 7. Enums
enum Status {
  Pending = 'PENDING',
  Approved = 'APPROVED',
  Rejected = 'REJECTED',
}

const currentStatus: Status = Status.Approved;

// 8. Union Types
type ID = string | number;
let userId: ID = 'abc123';
userId = 123; // Works
// userId = true; ❌ - Type error

// 9. Literal Types
type Direction = 'North' | 'South' | 'East' | 'West';
let direction: Direction = 'North';
// direction = 'Up'; ❌ - Type error

// 10. Function Types
type MathOperation = (a: number, b: number) => number;

const add: MathOperation = (a, b) => a + b;
const subtract: MathOperation = (a, b) => a - b;
```

---

## TS.3 Functions in TypeScript

### The Concept: Type-Safe Functions

Functions are the building blocks of your application. TypeScript ensures they're used correctly.

### Complete Function Guide

```typescript
// 1. Basic Function with Types
function greet(name: string): string {
  return `Hello, ${name}!`;
}

// 2. Arrow Functions
const greet = (name: string): string => {
  return `Hello, ${name}!`;
};

// 3. Optional Parameters
function greetUser(firstName: string, lastName?: string): string {
  if (lastName) {
    return `Hello, ${firstName} ${lastName}!`;
  }
  return `Hello, ${firstName}!`;
}

greetUser('John'); // Works
greetUser('John', 'Doe'); // Works

// 4. Default Parameters
function greetWithTitle(
  firstName: string,
  lastName: string,
  title: string = 'Mr.'
): string {
  return `Hello, ${title} ${firstName} ${lastName}!`;
}

// 5. Rest Parameters
function sum(...numbers: number[]): number {
  return numbers.reduce((total, num) => total + num, 0);
}

sum(1, 2, 3); // Returns 6

// 6. Function Overloads
function processInput(input: string): string;
function processInput(input: number): number;
function processInput(input: any): any {
  if (typeof input === 'string') {
    return input.toUpperCase();
  }
  if (typeof input === 'number') {
    return input * 2;
  }
  return input;
}

// 7. Void and Never
function logMessage(message: string): void {
  console.log(message);
  // No return statement
}

function throwError(message: string): never {
  throw new Error(message);
  // Never returns
}

// 8. Generic Functions
function identity<T>(value: T): T {
  return value;
}

const result1 = identity<string>('hello'); // Type is string
const result2 = identity(42); // Type is inferred as number

// 9. Generic with Constraints
interface HasLength {
  length: number;
}

function logLength<T extends HasLength>(item: T): T {
  console.log(item.length);
  return item;
}

logLength('hello'); // Works
logLength([1, 2, 3]); // Works
// logLength(42); ❌ - Type error (number doesn't have length)
```

---

## TS.4 React Native with TypeScript

### The Concept: Type-Safe Components

TypeScript makes React components more predictable and easier to maintain.

### Complete Component Guide

```typescript
// 1. Component Props Interface
interface ButtonProps {
  title: string;
  onPress: () => void;
  variant?: 'primary' | 'secondary' | 'danger';
  disabled?: boolean;
  loading?: boolean;
}

// 2. Functional Component with Props
import React from 'react';
import { TouchableOpacity, Text, ActivityIndicator } from 'react-native';

const Button: React.FC<ButtonProps> = ({
  title,
  onPress,
  variant = 'primary',
  disabled = false,
  loading = false,
}) => {
  const getVariantStyles = () => {
    switch (variant) {
      case 'primary':
        return { backgroundColor: '#2196F3' };
      case 'secondary':
        return { backgroundColor: '#757575' };
      case 'danger':
        return { backgroundColor: '#E74C3C' };
      default:
        return {};
    }
  };

  return (
    <TouchableOpacity
      onPress={onPress}
      disabled={disabled || loading}
      style={[styles.button, getVariantStyles()]}
    >
      {loading ? (
        <ActivityIndicator color="#fff" />
      ) : (
        <Text style={styles.text}>{title}</Text>
      )}
    </TouchableOpacity>
  );
};

const styles = StyleSheet.create({
  button: {
    padding: 12,
    borderRadius: 8,
    alignItems: 'center',
    justifyContent: 'center',
  },
  text: {
    color: '#fff',
    fontSize: 16,
    fontWeight: '600',
  },
});

export default Button;

// 3. Component with Children
interface CardProps {
  children: React.ReactNode;
  style?: StyleProp<ViewStyle>;
  elevation?: boolean;
}

const Card: React.FC<CardProps> = ({ children, style, elevation = true }) => {
  return (
    <View
      style={[
        styles.card,
        elevation && styles.shadow,
        style,
      ]}
    >
      {children}
    </View>
  );
};

// 4. State Management with TypeScript
import { useState } from 'react';

interface User {
  id: string;
  name: string;
  email: string;
}

function UserProfile() {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState<boolean>(false);
  const [error, setError] = useState<string | null>(null);

  // TypeScript knows user is User | null
  // So you need to check before using
  if (user) {
    console.log(user.name); // TypeScript knows this is safe
  }

  return (
    <View>
      {loading && <Text>Loading...</Text>}
      {error && <Text style={{ color: 'red' }}>{error}</Text>}
      {user && (
        <View>
          <Text>{user.name}</Text>
          <Text>{user.email}</Text>
        </View>
      )}
    </View>
  );
}

// 5. Custom Hooks with TypeScript
import { useState, useEffect } from 'react';

interface UseFetchResult<T> {
  data: T | null;
  loading: boolean;
  error: string | null;
  refetch: () => void;
}

function useFetch<T>(url: string): UseFetchResult<T> {
  const [data, setData] = useState<T | null>(null);
  const [loading, setLoading] = useState<boolean>(true);
  const [error, setError] = useState<string | null>(null);

  const fetchData = async () => {
    try {
      setLoading(true);
      const response = await fetch(url);
      const json = await response.json();
      setData(json);
      setError(null);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Unknown error');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchData();
  }, [url]);

  return { data, loading, error, refetch: fetchData };
}

// Usage
interface User {
  id: number;
  name: string;
}

function UserList() {
  const { data, loading, error } = useFetch<User[]>('https://api.example.com/users');
  
  if (loading) return <Text>Loading...</Text>;
  if (error) return <Text>Error: {error}</Text>;
  
  return (
    <View>
      {data?.map(user => (
        <Text key={user.id}>{user.name}</Text>
      ))}
    </View>
  );
}
```

---

## TS.5 Navigation with TypeScript

### The Concept: Type-Safe Navigation

TypeScript makes navigation safer by ensuring you only navigate to screens that exist and pass the correct parameters.

### Complete Navigation Guide

```typescript
// 1. Define Navigation Types
// types/navigation.ts
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import { BottomTabNavigationProp } from '@react-navigation/bottom-tabs';
import { CompositeNavigationProp } from '@react-navigation/native';

// Root Stack
export type RootStackParamList = {
  Auth: undefined;
  Main: undefined;
  Splash: undefined;
};

// Auth Stack
export type AuthStackParamList = {
  Login: undefined;
  Register: undefined;
  ForgotPassword: undefined;
};

// Main Tab Navigator
export type MainTabParamList = {
  Home: undefined;
  Profile: undefined;
  Settings: undefined;
};

// Main Stack
export type MainStackParamList = {
  MainTabs: undefined;
  FormDetail: { formId: string };
  EntryDetail: { entryId: string };
};

// Navigation Props
export type AuthScreenNavigationProp = NativeStackNavigationProp<AuthStackParamList>;
export type MainScreenNavigationProp = CompositeNavigationProp<
  NativeStackNavigationProp<MainStackParamList>,
  BottomTabNavigationProp<MainTabParamList>
>;

// 2. Use Navigation with Types
import { useNavigation } from '@react-navigation/native';
import { MainScreenNavigationProp } from '@types/navigation';

function HomeScreen() {
  const navigation = useNavigation<MainScreenNavigationProp>();

  const handlePress = () => {
    navigation.navigate('FormDetail', { formId: '123' }); // ✅ Type-safe
    // navigation.navigate('NonExistent'); ❌ - Type error
  };

  return <Button title="Go to Form" onPress={handlePress} />;
}

// 3. Use Route Parameters
import { useRoute } from '@react-navigation/native';

interface FormDetailParams {
  formId: string;
}

function FormDetailScreen() {
  const route = useRoute();
  // TypeScript needs help to know route.params type
  const { formId } = route.params as FormDetailParams;
  
  // Or better - define route type
  type FormDetailRouteProp = RouteProp<MainStackParamList, 'FormDetail'>;
  const routeTyped = useRoute<FormDetailRouteProp>();
  const { formId: typedFormId } = routeTyped.params;

  return <Text>Form ID: {typedFormId}</Text>;
}

// 4. Complete Navigation Setup
// navigation/RootNavigator.tsx
import React from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { RootStackParamList } from '@types/navigation';
import { AuthStack } from './stacks/AuthStack';
import { MainTabs } from './tabs/MainTabs';
import SplashScreen from '@screens/SplashScreen';

const Stack = createNativeStackNavigator<RootStackParamList>();

export const RootNavigator = () => {
  const [isAuthenticated, setIsAuthenticated] = React.useState(false);
  const [isLoading, setIsLoading] = React.useState(true);

  // Simulate loading
  React.useEffect(() => {
    setTimeout(() => {
      setIsLoading(false);
    }, 2000);
  }, []);

  if (isLoading) {
    return <SplashScreen />;
  }

  return (
    <NavigationContainer>
      <Stack.Navigator screenOptions={{ headerShown: false }}>
        {isAuthenticated ? (
          <Stack.Screen name="Main" component={MainTabs} />
        ) : (
          <Stack.Screen name="Auth" component={AuthStack} />
        )}
      </Stack.Navigator>
    </NavigationContainer>
  );
};
```

---

## TS.6 State Management with TypeScript (Zustand)

### The Concept: Type-Safe Global State

Zustand with TypeScript provides a clean, type-safe way to manage global state.

### Complete Zustand Guide

```typescript
// 1. Define State Types
// store/slices/authSlice.ts
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
  setUser: (user: User | null) => void;
  setAuthenticated: (isAuthenticated: boolean) => void;
  setLoading: (isLoading: boolean) => void;
  setError: (error: string | null) => void;
  logout: () => void;
}

type AuthStore = AuthState & AuthActions;

// 2. Create Store
export const useAuthStore = create<AuthStore>()(
  persist(
    (set) => ({
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
      logout: () => set({ user: null, isAuthenticated: false, error: null }),
    }),
    {
      name: 'auth-storage',
      // Only persist user and isAuthenticated
      partialize: (state) => ({
        user: state.user,
        isAuthenticated: state.isAuthenticated,
      }),
    }
  )
);

// 3. Use Store in Components
function ProfileScreen() {
  const { user, isAuthenticated, logout } = useAuthStore();

  if (!isAuthenticated) {
    return <Text>Please log in</Text>;
  }

  return (
    <View>
      <Text>Welcome, {user?.name}</Text>
      <Button title="Logout" onPress={logout} />
    </View>
  );
}

// 4. Selectors - Access Specific State
function UserNameDisplay() {
  // Only re-render when user changes
  const userName = useAuthStore((state) => state.user?.name);
  
  return <Text>{userName || 'Guest'}</Text>;
}

// 5. Combine Stores
// store/index.ts
import { useAuthStore } from './slices/authSlice';
import { useSettingsStore } from './slices/settingsSlice';
import { useFormStore } from './slices/formSlice';

export { useAuthStore, useSettingsStore, useFormStore };

// 6. Custom Selector Hook
import { useMemo } from 'react';
import { useAuthStore } from '@store';

export const useCurrentUser = () => {
  return useAuthStore((state) => ({
    user: state.user,
    isAuthenticated: state.isAuthenticated,
    isLoading: state.isLoading,
  }));
};

export const useAuthActions = () => {
  return useAuthStore((state) => ({
    login: state.login,
    logout: state.logout,
    register: state.register,
  }));
};
```

---

## TS.7 API Integration with TypeScript

### The Concept: Type-Safe API Calls

TypeScript ensures your API calls and responses are properly typed.

### Complete API Guide

```typescript
// 1. Define API Types
// types/api.ts
export interface User {
  id: string;
  email: string;
  name: string;
  avatar_url?: string;
  created_at: string;
}

export interface LoginRequest {
  email: string;
  password: string;
}

export interface LoginResponse {
  user: User;
  token: string;
}

export interface ApiError {
  message: string;
  code: string;
  status: number;
}

// 2. Create API Client
// api/client.ts
import axios, { AxiosError, AxiosInstance, AxiosRequestConfig } from 'axios';
import { CONFIG } from '@constants/config';

class ApiClient {
  private client: AxiosInstance;

  constructor() {
    this.client = axios.create({
      baseURL: CONFIG.api.baseUrl,
      timeout: CONFIG.api.timeout,
      headers: {
        'Content-Type': 'application/json',
      },
    });

    // Request interceptor
    this.client.interceptors.request.use(
      (config) => {
        const token = this.getToken();
        if (token) {
          config.headers.Authorization = `Bearer ${token}`;
        }
        return config;
      },
      (error) => Promise.reject(error)
    );

    // Response interceptor
    this.client.interceptors.response.use(
      (response) => response,
      (error: AxiosError) => {
        // Handle errors
        return Promise.reject(error);
      }
    );
  }

  private getToken(): string | null {
    // Get token from storage
    return null;
  }

  async get<T>(url: string, config?: AxiosRequestConfig): Promise<T> {
    const response = await this.client.get<T>(url, config);
    return response.data;
  }

  async post<T>(url: string, data?: any, config?: AxiosRequestConfig): Promise<T> {
    const response = await this.client.post<T>(url, data, config);
    return response.data;
  }

  async put<T>(url: string, data?: any, config?: AxiosRequestConfig): Promise<T> {
    const response = await this.client.put<T>(url, data, config);
    return response.data;
  }

  async delete<T>(url: string, config?: AxiosRequestConfig): Promise<T> {
    const response = await this.client.delete<T>(url, config);
    return response.data;
  }
}

export const apiClient = new ApiClient();

// 3. Create API Services
// api/services/authService.ts
import { apiClient } from '@api/client';
import { LoginRequest, LoginResponse, User } from '@types/api';

export const authService = {
  login: async (credentials: LoginRequest): Promise<LoginResponse> => {
    return apiClient.post<LoginResponse>('/auth/login', credentials);
  },

  register: async (userData: { email: string; password: string; name: string }) => {
    return apiClient.post<User>('/auth/register', userData);
  },

  logout: async (): Promise<void> => {
    return apiClient.post('/auth/logout');
  },

  getCurrentUser: async (): Promise<User> => {
    return apiClient.get<User>('/auth/me');
  },
};

// 4. Use API Services with React Query
import { useQuery, useMutation, UseQueryOptions, UseMutationOptions } from '@tanstack/react-query';

export const useCurrentUser = (options?: UseQueryOptions<User>) => {
  return useQuery<User, ApiError>({
    queryKey: ['user', 'current'],
    queryFn: () => authService.getCurrentUser(),
    staleTime: 5 * 60 * 1000,
    ...options,
  });
};

export const useLogin = () => {
  return useMutation<LoginResponse, ApiError, LoginRequest>({
    mutationFn: (credentials) => authService.login(credentials),
    onSuccess: (data) => {
      // Store token
      console.log('Login successful', data);
    },
  });
};

// 5. Use in Components
function LoginScreen() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const loginMutation = useLogin();
  const navigation = useNavigation();

  const handleLogin = async () => {
    try {
      await loginMutation.mutateAsync({ email, password });
      // Navigate to main app
      navigation.navigate('Main');
    } catch (error) {
      // Handle error
      console.error('Login failed:', error);
    }
  };

  return (
    <View>
      <TextInput
        placeholder="Email"
        value={email}
        onChangeText={setEmail}
      />
      <TextInput
        placeholder="Password"
        secureTextEntry
        value={password}
        onChangeText={setPassword}
      />
      <Button
        title={loginMutation.isLoading ? 'Logging in...' : 'Login'}
        onPress={handleLogin}
        disabled={loginMutation.isLoading}
      />
      {loginMutation.error && (
        <Text style={{ color: 'red' }}>{loginMutation.error.message}</Text>
      )}
    </View>
  );
}
```

---

## TS.8 Utility Types

### The Concept: Powerful Type Transformations

TypeScript provides built-in utility types that transform existing types.

### Complete Utility Types Guide

```typescript
// 1. Partial<T> - Makes all properties optional
interface User {
  id: string;
  name: string;
  email: string;
  age: number;
}

type PartialUser = Partial<User>;
// Equivalent to: { id?: string; name?: string; email?: string; age?: number; }

const updateUser = (id: string, updates: Partial<User>) => {
  // Update only provided fields
};

// 2. Required<T> - Makes all properties required
type RequiredUser = Required<User>;
// All properties become required

// 3. Readonly<T> - Makes all properties readonly
type ReadonlyUser = Readonly<User>;
// Cannot modify any property

// 4. Record<K, T> - Creates an object with keys K and values T
type UserRoles = Record<string, User>;
// Equivalent to: { [key: string]: User }

const users: UserRoles = {
  'user1': { id: '1', name: 'John', email: 'john@example.com', age: 30 },
  'user2': { id: '2', name: 'Jane', email: 'jane@example.com', age: 25 },
};

// 5. Pick<T, K> - Selects specific properties
type UserSummary = Pick<User, 'id' | 'name'>;
// Equivalent to: { id: string; name: string; }

// 6. Omit<T, K> - Omits specific properties
type UserWithoutEmail = Omit<User, 'email'>;
// Equivalent to: { id: string; name: string; age: number; }

// 7. Exclude<T, U> - Excludes types from a union
type Status = 'pending' | 'approved' | 'rejected';
type ActiveStatus = Exclude<Status, 'rejected'>; // 'pending' | 'approved'

// 8. Extract<T, U> - Extracts types from a union
type InactiveStatus = Extract<Status, 'rejected'>; // 'rejected'

// 9. NonNullable<T> - Removes null and undefined
type MaybeString = string | null | undefined;
type DefinitelyString = NonNullable<MaybeString>; // string

// 10. ReturnType<T> - Gets the return type of a function
function getUser(): User {
  return { id: '1', name: 'John', email: 'john@example.com', age: 30 };
}

type UserType = ReturnType<typeof getUser>; // User

// 11. Parameters<T> - Gets the parameter types of a function
function updateUser(id: string, data: Partial<User>): void {}

type UpdateUserParams = Parameters<typeof updateUser>; // [string, Partial<User>]

// 12. Awaited<T> - Gets the resolved type of a promise
async function fetchUser(): Promise<User> {
  return { id: '1', name: 'John', email: 'john@example.com', age: 30 };
}

type UserFromPromise = Awaited<ReturnType<typeof fetchUser>>; // User

// 13. Custom Utility Types
type DeepPartial<T> = {
  [P in keyof T]?: T[P] extends object ? DeepPartial<T[P]> : T[P];
};

interface NestedUser {
  id: string;
  profile: {
    name: string;
    address: {
      street: string;
      city: string;
    };
  };
}

type DeepPartialUser = DeepPartial<NestedUser>;
// All nested properties become optional
```

---

## TS.9 Practical Examples

### The Concept: Real-World TypeScript Patterns

Here are some practical, real-world patterns you'll use regularly.

### Complete Examples

```typescript
// 1. Form Handling with TypeScript
interface FormData {
  email: string;
  password: string;
  confirmPassword: string;
}

interface FormErrors {
  email?: string;
  password?: string;
  confirmPassword?: string;
}

function useFormValidation() {
  const [errors, setErrors] = useState<FormErrors>({});

  const validate = (data: FormData): boolean => {
    const newErrors: FormErrors = {};

    if (!data.email) {
      newErrors.email = 'Email is required';
    } else if (!data.email.includes('@')) {
      newErrors.email = 'Invalid email';
    }

    if (!data.password) {
      newErrors.password = 'Password is required';
    } else if (data.password.length < 6) {
      newErrors.password = 'Password must be at least 6 characters';
    }

    if (data.password !== data.confirmPassword) {
      newErrors.confirmPassword = 'Passwords do not match';
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  return { errors, validate, setErrors };
}

// 2. Type-Safe Event Handlers
import { TextInputChangeEventData, NativeSyntheticEvent } from 'react-native';

function InputHandler() {
  const handleChange = (text: string) => {
    // TypeScript infers text is string
    console.log(text);
  };

  const handleSubmit = (e: NativeSyntheticEvent<TextInputChangeEventData>) => {
    console.log(e.nativeEvent.text);
  };

  return (
    <TextInput
      onChangeText={handleChange}
      onSubmitEditing={handleSubmit}
    />
  );
}

// 3. Type-Safe Context
import React, { createContext, useContext, useReducer } from 'react';

// State
interface AppState {
  user: User | null;
  theme: 'light' | 'dark';
  notifications: boolean;
}

// Actions
type AppAction =
  | { type: 'SET_USER'; payload: User }
  | { type: 'LOGOUT' }
  | { type: 'TOGGLE_THEME' }
  | { type: 'TOGGLE_NOTIFICATIONS' };

// Context
const AppContext = createContext<{
  state: AppState;
  dispatch: React.Dispatch<AppAction>;
} | null>(null);

// Reducer
function appReducer(state: AppState, action: AppAction): AppState {
  switch (action.type) {
    case 'SET_USER':
      return { ...state, user: action.payload };
    case 'LOGOUT':
      return { ...state, user: null };
    case 'TOGGLE_THEME':
      return { ...state, theme: state.theme === 'light' ? 'dark' : 'light' };
    case 'TOGGLE_NOTIFICATIONS':
      return { ...state, notifications: !state.notifications };
    default:
      return state;
  }
}

// Provider
function AppProvider({ children }: { children: React.ReactNode }) {
  const [state, dispatch] = useReducer(appReducer, {
    user: null,
    theme: 'light',
    notifications: true,
  });

  return (
    <AppContext.Provider value={{ state, dispatch }}>
      {children}
    </AppContext.Provider>
  );
}

// Custom hook
function useAppContext() {
  const context = useContext(AppContext);
  if (!context) {
    throw new Error('useAppContext must be used within AppProvider');
  }
  return context;
}

// Usage
function UserProfile() {
  const { state, dispatch } = useAppContext();

  const handleLogin = () => {
    dispatch({
      type: 'SET_USER',
      payload: { id: '1', name: 'John', email: 'john@example.com', age: 30 },
    });
  };

  return (
    <View>
      {state.user ? (
        <Text>Welcome, {state.user.name}</Text>
      ) : (
        <Button title="Login" onPress={handleLogin} />
      )}
    </View>
  );
}
```

---

## TS.10 TypeScript Configuration

### The Concept: Setting Up TypeScript

Here's the complete TypeScript configuration for a React Native project.

### Complete Configuration

```json
// tsconfig.json
{
  "extends": "expo/tsconfig.base",
  "compilerOptions": {
    // Strict settings
    "strict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true,
    "forceConsistentCasingInFileNames": true,
    
    // Module resolution
    "moduleResolution": "node",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "esModuleInterop": true,
    
    // JavaScript support
    "allowJs": true,
    "checkJs": false,
    "noEmit": true,
    
    // Path aliases
    "baseUrl": ".",
    "paths": {
      "@/*": ["./src/*"],
      "@components/*": ["./src/components/*"],
      "@screens/*": ["./src/screens/*"],
      "@utils/*": ["./src/utils/*"],
      "@types/*": ["./src/types/*"],
      "@hooks/*": ["./src/hooks/*"],
      "@store/*": ["./src/store/*"],
      "@api/*": ["./src/api/*"],
      "@themes/*": ["./src/themes/*"],
      "@database/*": ["./src/database/*"],
      "@services/*": ["./src/services/*"],
      "@constants/*": ["./src/constants/*"],
      "@navigation/*": ["./src/navigation/*"]
    },
    
    // Decorators (for libraries like WatermelonDB)
    "experimentalDecorators": true,
    "emitDecoratorMetadata": true,
    
    // Target
    "target": "ES2020",
    "lib": ["ES2020", "DOM"],
    "jsx": "react-native",
    
    // Types
    "types": ["react-native", "jest"]
  },
  "include": [
    "**/*.ts",
    "**/*.tsx",
    "**/*.js",
    "**/*.jsx",
    ".expo/types/**/*.ts",
    "expo-env.d.ts"
  ],
  "exclude": [
    "node_modules",
    "**/__tests__/*",
    "**/*.test.ts",
    "**/*.test.tsx",
    "**/*.spec.ts",
    "**/*.spec.tsx",
    "e2e/**/*",
    "coverage/**/*"
  ]
}
```

---

## Quick Reference: TypeScript Commands

```bash
# Type checking
npx tsc --noEmit                # Check types without emitting
npx tsc --noEmit --watch        # Watch mode

# Type checking with errors
npx tsc --noEmit --strict       # Strict type checking

# Generate declaration files
npx tsc --declaration --emitDeclarationOnly

# Debugging
npx tsc --noEmit --traceResolution # Trace module resolution
```

---

## Common TypeScript Error Messages

| Error Message | Meaning | Solution |
|---------------|---------|----------|
| `Object is possibly 'null' or 'undefined'` | You're accessing a property on something that might be null | Use optional chaining (`?.`) or null check |
| `Property 'x' does not exist on type 'Y'` | Trying to access a property that doesn't exist | Check your type definition |
| `Argument of type 'A' is not assignable to parameter of type 'B'` | Passing wrong type to function | Check the expected type |
| `Cannot find name 'x'` | Using an undefined variable | Define the variable or import it |
| `Cannot find module 'x'` | Importing a module that doesn't exist | Install the module or check path |

---

**Ready to use TypeScript in NexusCollect? Let's go!**
