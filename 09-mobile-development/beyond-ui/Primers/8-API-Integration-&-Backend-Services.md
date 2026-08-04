# Primer 8: API Integration & Backend Services

## Your Complete Guide to Connecting Your App to the Cloud

Welcome to the API Integration Primer! This guide covers everything you need to know about connecting your React Native app to backend services, handling API calls, managing authentication, and working with real-time data. In today's mobile world, apps are only as powerful as the services they connect to.

---

## A.1 Understanding Backend Services

### The Concept: The Brain Behind Your App

Backend services power your app's functionality - storing data, handling authentication, sending notifications, and processing business logic. Your mobile app is the front-end interface that communicates with these services.

**Simple Analogy:** Think of your app like a restaurant. The mobile app is the dining room (what customers see), and the backend is the kitchen (where the real work happens). The API is the waiter that takes orders from the dining room to the kitchen and brings back the results.

### Common Backend Services

| Service Type | Examples | Purpose |
|--------------|----------|---------|
| Authentication | Supabase Auth, Firebase Auth | User login, registration, session management |
| Database | Supabase PostgreSQL, Firebase Firestore | Storing and retrieving data |
| File Storage | Supabase Storage, AWS S3 | Storing images, documents |
| Real-time | Supabase Realtime, Socket.io | Live data updates |
| Notifications | Firebase Cloud Messaging, APNs | Push notifications |
| Analytics | Mixpanel, Amplitude | User behavior tracking |

---

## A.2 Setting Up Supabase

### The Concept: Your Complete Backend Solution

Supabase is an open-source Firebase alternative that provides all the backend services you need in one place.

### Complete Supabase Setup

```bash
# 1. Create Supabase Project
# Go to https://app.supabase.com
# Click "New Project"
# Enter project name: nexuscollect
# Set database password
# Choose region

# 2. Get API Keys
# Project Settings → API
# Copy:
# - Project URL
# - anon public key

# 3. Install Supabase Client
npm install @supabase/supabase-js @supabase/realtime-js

# 4. Install Secure Storage
npm install expo-secure-store
```

### Supabase Client Configuration

```typescript
// src/api/supabase.ts
import { createClient } from '@supabase/supabase-js';
import * as SecureStore from 'expo-secure-store';
import { CONFIG } from '@constants/config';
import { Platform } from 'react-native';

/**
 * Secure storage adapter for Supabase
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
 * Initialize Supabase client
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
      flowType: 'pkce',
    },
    realtime: {
      params: {
        eventsPerSecond: 10,
      },
    },
  }
);

/**
 * Request/Response logging in development
 */
if (CONFIG.isDevelopment) {
  const originalFetch = supabase.rest.fetch.bind(supabase.rest);
  supabase.rest.fetch = async (url, options) => {
    console.log(`📤 [Supabase] ${url}`);
    console.log(`📤 [Supabase] Options:`, options);
    
    try {
      const response = await originalFetch(url, options);
      console.log(`📥 [Supabase] Response:`, response);
      return response;
    } catch (error) {
      console.error(`❌ [Supabase] Error:`, error);
      throw error;
    }
  };
}
```

---

## A.3 REST API Integration

### The Concept: Making HTTP Requests

REST APIs are the most common way to communicate with backend services. You make HTTP requests (GET, POST, PUT, DELETE) to specific endpoints.

### Complete REST API Guide

```typescript
// 1. Install Axios
npm install axios

// 2. Create API Client
// src/api/axios.ts
import axios from 'axios';
import { Platform } from 'react-native';
import { CONFIG } from '@constants/config';
import { useAuthStore } from '@store';
import * as SecureStore from 'expo-secure-store';

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

/**
 * Request interceptor - Add auth token
 */
apiClient.interceptors.request.use(
  async (config) => {
    // Get token from secure storage
    const token = await SecureStore.getItemAsync('auth_token');
    
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    
    // Log request in development
    if (CONFIG.isDevelopment) {
      console.log(`📤 [API] ${config.method?.toUpperCase()} ${config.url}`);
      console.log('📤 [API] Headers:', config.headers);
      if (config.data) {
        console.log('📤 [API] Body:', config.data);
      }
    }
    
    return config;
  },
  (error) => {
    console.error('❌ [API] Request error:', error);
    return Promise.reject(error);
  }
);

/**
 * Response interceptor - Handle errors
 */
apiClient.interceptors.response.use(
  (response) => {
    if (CONFIG.isDevelopment) {
      console.log(`📥 [API] ${response.status} ${response.config.url}`);
      console.log('📥 [API] Data:', response.data);
    }
    return response;
  },
  async (error) => {
    const originalRequest = error.config;
    
    // Network error
    if (!error.response) {
      console.error('❌ [API] Network error');
      return Promise.reject({
        message: 'Network error. Please check your connection.',
        originalError: error,
      });
    }
    
    // Token expired - Attempt refresh
    if (error.response.status === 401 && !originalRequest._retry) {
      originalRequest._retry = true;
      try {
        // Refresh token
        const refreshToken = await SecureStore.getItemAsync('refresh_token');
        const response = await apiClient.post('/auth/refresh', { refreshToken });
        const { token } = response.data;
        await SecureStore.setItemAsync('auth_token', token);
        
        // Retry original request
        originalRequest.headers.Authorization = `Bearer ${token}`;
        return apiClient(originalRequest);
      } catch (refreshError) {
        // Refresh failed - logout
        useAuthStore.getState().logout();
        return Promise.reject({
          message: 'Session expired. Please login again.',
          originalError: refreshError,
        });
      }
    }
    
    // Handle other errors
    const errorMessage = error.response.data?.message || error.message || 'Unknown error';
    console.error(`❌ [API] ${error.response.status}:`, errorMessage);
    
    return Promise.reject({
      status: error.response.status,
      message: errorMessage,
      data: error.response.data,
      originalError: error,
    });
  }
);

// 3. Create API Service
// src/api/services/userService.ts
import { apiClient } from '@api/axios';

export interface User {
  id: string;
  email: string;
  name: string;
  avatar_url?: string;
  created_at: string;
}

export const userService = {
  // Get current user
  getCurrentUser: async (): Promise<User> => {
    const response = await apiClient.get('/users/me');
    return response.data;
  },
  
  // Update user
  updateUser: async (data: Partial<User>): Promise<User> => {
    const response = await apiClient.put('/users/me', data);
    return response.data;
  },
  
  // Get user by ID
  getUserById: async (id: string): Promise<User> => {
    const response = await apiClient.get(`/users/${id}`);
    return response.data;
  },
  
  // Upload avatar
  uploadAvatar: async (file: FormData): Promise<{ url: string }> => {
    const response = await apiClient.post('/users/avatar', file, {
      headers: {
        'Content-Type': 'multipart/form-data',
      },
    });
    return response.data;
  },
  
  // Delete user
  deleteUser: async (): Promise<void> => {
    await apiClient.delete('/users/me');
  },
};

// 4. Use in Components
import { useQuery, useMutation } from '@tanstack/react-query';

function UserProfile() {
  // Fetch user data
  const { data: user, isLoading } = useQuery({
    queryKey: ['user'],
    queryFn: userService.getCurrentUser,
  });

  // Update user mutation
  const mutation = useMutation({
    mutationFn: (data: Partial<User>) => userService.updateUser(data),
    onSuccess: (updatedUser) => {
      // Update cache
      queryClient.setQueryData(['user'], updatedUser);
    },
  });

  if (isLoading) return <Text>Loading...</Text>;

  return (
    <View>
      <Text>{user?.name}</Text>
      <Text>{user?.email}</Text>
      <Button
        title="Update Name"
        onPress={() => mutation.mutate({ name: 'New Name' })}
      />
    </View>
  );
}
```

---

## A.4 Authentication Flow

### The Concept: Secure User Access

Authentication verifies who users are and gives them access to protected resources.

### Complete Authentication Guide

```typescript
// 1. Auth Service
// src/api/services/authService.ts
import { supabase } from '@api/supabase';
import { apiClient } from '@api/axios';
import * as SecureStore from 'expo-secure-store';

export interface LoginCredentials {
  email: string;
  password: string;
}

export interface RegisterData {
  email: string;
  password: string;
  name: string;
}

export interface AuthResponse {
  user: {
    id: string;
    email: string;
    name: string;
    avatar_url?: string;
  };
  session: {
    access_token: string;
    refresh_token: string;
    expires_at: number;
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

    if (error) throw new Error(error.message);
    if (!data.user || !data.session) throw new Error('Login failed');

    // Store tokens
    await SecureStore.setItemAsync('auth_token', data.session.access_token);
    await SecureStore.setItemAsync('refresh_token', data.session.refresh_token);

    return {
      user: {
        id: data.user.id,
        email: data.user.email!,
        name: data.user.user_metadata?.name || '',
        avatar_url: data.user.user_metadata?.avatar_url,
      },
      session: {
        access_token: data.session.access_token,
        refresh_token: data.session.refresh_token,
        expires_at: data.session.expires_at || Date.now() + 3600000,
      },
    };
  },

  /**
   * Register new user
   */
  register: async (data: RegisterData): Promise<AuthResponse> => {
    const { data: authData, error } = await supabase.auth.signUp({
      email: data.email,
      password: data.password,
      options: {
        data: {
          name: data.name,
        },
      },
    });

    if (error) throw new Error(error.message);
    if (!authData.user || !authData.session) throw new Error('Registration failed');

    await SecureStore.setItemAsync('auth_token', authData.session.access_token);
    await SecureStore.setItemAsync('refresh_token', authData.session.refresh_token);

    return {
      user: {
        id: authData.user.id,
        email: authData.user.email!,
        name: authData.user.user_metadata?.name || '',
        avatar_url: authData.user.user_metadata?.avatar_url,
      },
      session: {
        access_token: authData.session.access_token,
        refresh_token: authData.session.refresh_token,
        expires_at: authData.session.expires_at || Date.now() + 3600000,
      },
    };
  },

  /**
   * Logout
   */
  logout: async (): Promise<void> => {
    await supabase.auth.signOut();
    await SecureStore.deleteItemAsync('auth_token');
    await SecureStore.deleteItemAsync('refresh_token');
  },

  /**
   * Reset password
   */
  resetPassword: async (email: string): Promise<void> => {
    const { error } = await supabase.auth.resetPasswordForEmail(email, {
      redirectTo: 'nexuscollect://reset-password',
    });
    if (error) throw new Error(error.message);
  },

  /**
   * Get current session
   */
  getSession: async () => {
    const { data, error } = await supabase.auth.getSession();
    if (error) throw new Error(error.message);
    return data.session;
  },

  /**
   * Social Login - Google
   */
  loginWithGoogle: async () => {
    const { data, error } = await supabase.auth.signInWithOAuth({
      provider: 'google',
      options: {
        redirectTo: 'nexuscollect://auth-callback',
      },
    });
    if (error) throw new Error(error.message);
    return data;
  },

  /**
   * Social Login - Apple
   */
  loginWithApple: async () => {
    const { data, error } = await supabase.auth.signInWithOAuth({
      provider: 'apple',
      options: {
        redirectTo: 'nexuscollect://auth-callback',
      },
    });
    if (error) throw new Error(error.message);
    return data;
  },
};

// 2. Auth Hook
// src/hooks/useAuth.ts
import { useAuthStore } from '@store';
import { authService } from '@api/services/authService';
import { useState } from 'react';

export const useAuth = () => {
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const authState = useAuthStore();

  const login = async (email: string, password: string) => {
    try {
      setIsLoading(true);
      setError(null);
      const response = await authService.login({ email, password });
      authState.setUser(response.user);
      authState.setAuthenticated(true);
      return { success: true };
    } catch (err: any) {
      const message = err.message || 'Login failed';
      setError(message);
      return { success: false, error: message };
    } finally {
      setIsLoading(false);
    }
  };

  const register = async (email: string, password: string, name: string) => {
    try {
      setIsLoading(true);
      setError(null);
      const response = await authService.register({ email, password, name });
      authState.setUser(response.user);
      authState.setAuthenticated(true);
      return { success: true };
    } catch (err: any) {
      const message = err.message || 'Registration failed';
      setError(message);
      return { success: false, error: message };
    } finally {
      setIsLoading(false);
    }
  };

  const logout = async () => {
    try {
      setIsLoading(true);
      await authService.logout();
      authState.logout();
      return { success: true };
    } catch (err: any) {
      return { success: false, error: err.message };
    } finally {
      setIsLoading(false);
    }
  };

  const resetPassword = async (email: string) => {
    try {
      setIsLoading(true);
      await authService.resetPassword(email);
      return { success: true };
    } catch (err: any) {
      return { success: false, error: err.message };
    } finally {
      setIsLoading(false);
    }
  };

  const initializeAuth = async () => {
    try {
      const session = await authService.getSession();
      if (session) {
        // Get user data
        const { data } = await supabase.auth.getUser();
        if (data.user) {
          authState.setUser({
            id: data.user.id,
            email: data.user.email!,
            name: data.user.user_metadata?.name || '',
            avatar_url: data.user.user_metadata?.avatar_url,
          });
          authState.setAuthenticated(true);
        }
      }
    } catch (error) {
      console.error('Auth initialization error:', error);
    }
  };

  return {
    ...authState,
    isLoading,
    error,
    login,
    register,
    logout,
    resetPassword,
    initializeAuth,
  };
};
```

---

## A.5 Real-time Subscriptions

### The Concept: Live Data Updates

Real-time subscriptions allow your app to receive live updates when data changes on the server.

### Complete Real-time Guide

```typescript
// 1. Subscribe to Real-time Changes
// src/hooks/useRealtime.ts
import { useEffect, useState } from 'react';
import { supabase } from '@api/supabase';
import { useAuth } from '@hooks/useAuth';

export const useRealtime = <T extends { id: string }>(
  table: string,
  filter?: Record<string, any>
) => {
  const [data, setData] = useState<T[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);
  const { user } = useAuth();

  useEffect(() => {
    if (!user) {
      setLoading(false);
      return;
    }

    let isMounted = true;

    /**
     * Fetch initial data
     */
    const fetchInitialData = async () => {
      try {
        let query = supabase.from(table).select('*');
        
        // Apply filters
        if (filter) {
          Object.entries(filter).forEach(([key, value]) => {
            query = query.eq(key, value);
          });
        }
        
        // Apply RLS - only get user's data
        query = query.eq('user_id', user.id);
        
        const { data: initialData, error: fetchError } = await query;
        
        if (fetchError) throw fetchError;
        if (isMounted) {
          setData(initialData || []);
          setLoading(false);
        }
      } catch (err) {
        if (isMounted) {
          setError(err as Error);
          setLoading(false);
        }
      }
    };

    fetchInitialData();

    /**
     * Set up real-time subscription
     */
    const subscription = supabase
      .channel(`${table}-changes`)
      .on(
        'postgres_changes',
        {
          event: '*',
          schema: 'public',
          table: table,
          filter: filter 
            ? Object.entries(filter)
                .map(([key, value]) => `${key}=eq.${value}`)
                .join('&')
            : undefined,
        },
        async (payload) => {
          switch (payload.eventType) {
            case 'INSERT':
              setData(prev => [...prev, payload.new as T]);
              break;
            case 'UPDATE':
              setData(prev =>
                prev.map(item =>
                  item.id === payload.new.id ? payload.new as T : item
                )
              );
              break;
            case 'DELETE':
              setData(prev => prev.filter(item => item.id !== payload.old.id));
              break;
          }
        }
      )
      .subscribe((status) => {
        console.log(`Realtime subscription status for ${table}:`, status);
      });

    // Cleanup
    return () => {
      isMounted = false;
      subscription.unsubscribe();
    };
  }, [table, user?.id, JSON.stringify(filter)]);

  return { data, loading, error };
};

// 2. Use Real-time in Component
function CollectionList() {
  const { data: collections, loading } = useRealtime('collections', {
    status: 'active',
  });

  if (loading) return <Text>Loading...</Text>;

  return (
    <FlatList
      data={collections}
      renderItem={({ item }) => (
        <Text>{item.data?.name || 'Untitled'}</Text>
      )}
    />
  );
}
```

---

## A.6 File Upload & Storage

### The Concept: Storing User Files

File storage allows users to upload photos, documents, and other files.

### Complete File Upload Guide

```typescript
// 1. File Upload Service
// src/api/services/storageService.ts
import { supabase } from '@api/supabase';
import * as ImagePicker from 'expo-image-picker';
import { Platform } from 'react-native';

export const storageService = {
  /**
   * Upload image to Supabase Storage
   */
  uploadImage: async (
    uri: string,
    bucket: string,
    path: string
  ): Promise<string> => {
    try {
      // Get file extension
      const fileExt = uri.split('.').pop() || 'jpg';
      const fileName = `${path}/${Date.now()}.${fileExt}`;
      
      // Convert URI to blob
      const response = await fetch(uri);
      const blob = await response.blob();
      
      // Upload to Supabase
      const { data, error } = await supabase.storage
        .from(bucket)
        .upload(fileName, blob, {
          contentType: `image/${fileExt}`,
          upsert: false,
        });
      
      if (error) throw error;
      
      // Get public URL
      const { data: urlData } = supabase.storage
        .from(bucket)
        .getPublicUrl(fileName);
      
      return urlData.publicUrl;
    } catch (error) {
      console.error('Upload error:', error);
      throw error;
    }
  },
  
  /**
   * Pick image from gallery
   */
  pickImage: async (): Promise<{ uri: string; base64?: string } | null> => {
    const { status } = await ImagePicker.requestMediaLibraryPermissionsAsync();
    if (status !== 'granted') {
      alert('Permission required to access gallery');
      return null;
    }
    
    const result = await ImagePicker.launchImageLibraryAsync({
      mediaTypes: ImagePicker.MediaTypeOptions.Images,
      allowsEditing: true,
      quality: 0.8,
      base64: true,
    });
    
    if (result.canceled || !result.assets[0]) {
      return null;
    }
    
    return {
      uri: result.assets[0].uri,
      base64: result.assets[0].base64,
    };
  },
  
  /**
   * Capture photo with camera
   */
  capturePhoto: async (): Promise<{ uri: string; base64?: string } | null> => {
    const { status } = await ImagePicker.requestCameraPermissionsAsync();
    if (status !== 'granted') {
      alert('Permission required to use camera');
      return null;
    }
    
    const result = await ImagePicker.launchCameraAsync({
      mediaTypes: ImagePicker.MediaTypeOptions.Images,
      allowsEditing: true,
      quality: 0.8,
      base64: true,
    });
    
    if (result.canceled || !result.assets[0]) {
      return null;
    }
    
    return {
      uri: result.assets[0].uri,
      base64: result.assets[0].base64,
    };
  },
  
  /**
   * Delete file from storage
   */
  deleteFile: async (bucket: string, path: string): Promise<void> => {
    const { error } = await supabase.storage
      .from(bucket)
      .remove([path]);
    
    if (error) throw error;
  },
  
  /**
   * Get list of files
   */
  listFiles: async (bucket: string, path?: string): Promise<string[]> => {
    const { data, error } = await supabase.storage
      .from(bucket)
      .list(path || '');
    
    if (error) throw error;
    return data.map(file => file.name);
  },
};

// 2. Use in Component
function ProfileScreen() {
  const [uploading, setUploading] = useState(false);
  const { user, updateUser } = useAuth();

  const handleUploadAvatar = async () => {
    try {
      setUploading(true);
      
      // Pick image
      const image = await storageService.pickImage();
      if (!image) return;
      
      // Upload to storage
      const url = await storageService.uploadImage(
        image.uri,
        'avatars',
        `users/${user?.id}`
      );
      
      // Update user profile
      await updateUser({ avatar_url: url });
      
      Alert.alert('Success', 'Avatar updated successfully');
    } catch (error: any) {
      Alert.alert('Error', error.message || 'Failed to upload avatar');
    } finally {
      setUploading(false);
    }
  };

  return (
    <View>
      <TouchableOpacity onPress={handleUploadAvatar} disabled={uploading}>
        {user?.avatar_url ? (
          <Image source={{ uri: user.avatar_url }} style={{ width: 100, height: 100 }} />
        ) : (
          <View style={{ width: 100, height: 100, backgroundColor: '#ccc' }} />
        )}
        {uploading && <ActivityIndicator />}
      </TouchableOpacity>
    </View>
  );
}
```

---

## A.7 Error Handling

### The Concept: Graceful Failure

Proper error handling ensures your app fails gracefully and provides helpful feedback to users.

### Complete Error Handling Guide

```typescript
// 1. Error Types
// src/types/errors.ts
export class AppError extends Error {
  code: string;
  status?: number;
  details?: any;

  constructor(message: string, code: string, status?: number, details?: any) {
    super(message);
    this.name = 'AppError';
    this.code = code;
    this.status = status;
    this.details = details;
  }
}

export const ErrorCodes = {
  NETWORK_ERROR: 'NETWORK_ERROR',
  AUTH_ERROR: 'AUTH_ERROR',
  VALIDATION_ERROR: 'VALIDATION_ERROR',
  NOT_FOUND: 'NOT_FOUND',
  UNAUTHORIZED: 'UNAUTHORIZED',
  FORBIDDEN: 'FORBIDDEN',
  SERVER_ERROR: 'SERVER_ERROR',
  UNKNOWN_ERROR: 'UNKNOWN_ERROR',
};

// 2. Error Handler
// src/utils/errorHandler.ts
import { Alert, Platform } from 'react-native';
import { errorTracker } from './errorTracking';

export class ErrorHandler {
  static handle(error: any): void {
    console.error('Error:', error);

    // Log to monitoring service
    if (error instanceof Error) {
      errorTracker.captureException(error);
    }

    // Show user-friendly message
    const message = this.getUserFriendlyMessage(error);
    Alert.alert('Error', message);
  }

  static getUserFriendlyMessage(error: any): string {
    if (error instanceof AppError) {
      switch (error.code) {
        case ErrorCodes.NETWORK_ERROR:
          return 'Network error. Please check your connection.';
        case ErrorCodes.AUTH_ERROR:
          return 'Authentication failed. Please try again.';
        case ErrorCodes.VALIDATION_ERROR:
          return error.message || 'Invalid input. Please check your data.';
        case ErrorCodes.NOT_FOUND:
          return 'Resource not found.';
        case ErrorCodes.UNAUTHORIZED:
          return 'Please login to continue.';
        case ErrorCodes.FORBIDDEN:
          return 'You don\'t have permission to perform this action.';
        case ErrorCodes.SERVER_ERROR:
          return 'Server error. Please try again later.';
        default:
          return error.message || 'An unexpected error occurred.';
      }
    }

    if (error.message) {
      return error.message;
    }

    return 'An unexpected error occurred.';
  }

  static handleApiError(error: any): AppError {
    if (error.response) {
      // Server responded with error
      const status = error.response.status;
      const data = error.response.data;

      switch (status) {
        case 400:
          return new AppError(
            data.message || 'Invalid request',
            ErrorCodes.VALIDATION_ERROR,
            status,
            data
          );
        case 401:
          return new AppError(
            data.message || 'Unauthorized',
            ErrorCodes.UNAUTHORIZED,
            status,
            data
          );
        case 403:
          return new AppError(
            data.message || 'Forbidden',
            ErrorCodes.FORBIDDEN,
            status,
            data
          );
        case 404:
          return new AppError(
            data.message || 'Not found',
            ErrorCodes.NOT_FOUND,
            status,
            data
          );
        case 500:
          return new AppError(
            data.message || 'Server error',
            ErrorCodes.SERVER_ERROR,
            status,
            data
          );
        default:
          return new AppError(
            data.message || 'API error',
            ErrorCodes.UNKNOWN_ERROR,
            status,
            data
          );
      }
    }

    if (error.request) {
      // No response received
      return new AppError(
        'Network error',
        ErrorCodes.NETWORK_ERROR
      );
    }

    return new AppError(
      error.message || 'Unknown error',
      ErrorCodes.UNKNOWN_ERROR
    );
  }
}

// 3. API Error Interceptor
// src/api/axios.ts (add to response interceptor)
apiClient.interceptors.response.use(
  (response) => response,
  (error) => {
    const appError = ErrorHandler.handleApiError(error);
    return Promise.reject(appError);
  }
);

// 4. Error Boundary Component
// src/components/common/ErrorBoundary.tsx
import React from 'react';
import { View, Text, Button } from 'react-native';

interface Props {
  children: React.ReactNode;
  fallback?: React.ReactNode;
}

interface State {
  hasError: boolean;
  error: Error | null;
}

export class ErrorBoundary extends React.Component<Props, State> {
  constructor(props: Props) {
    super(props);
    this.state = { hasError: false, error: null };
  }

  static getDerivedStateFromError(error: Error): State {
    return { hasError: true, error };
  }

  componentDidCatch(error: Error, errorInfo: any) {
    console.error('ErrorBoundary caught:', error, errorInfo);
    errorTracker.captureException(error, { errorInfo });
  }

  render() {
    if (this.state.hasError) {
      if (this.props.fallback) {
        return this.props.fallback;
      }

      return (
        <View style={{ flex: 1, justifyContent: 'center', alignItems: 'center', padding: 20 }}>
          <Text style={{ fontSize: 18, marginBottom: 10 }}>Something went wrong</Text>
          <Text style={{ color: '#666', marginBottom: 20, textAlign: 'center' }}>
            {this.state.error?.message || 'An unexpected error occurred'}
          </Text>
          <Button
            title="Try Again"
            onPress={() => this.setState({ hasError: false, error: null })}
          />
        </View>
      );
    }

    return this.props.children;
  }
}
```

---

## A.8 Quick Reference

### API Commands

```bash
# Supabase
supabase start                      # Start local development
supabase db diff                    # Generate schema diff
supabase db push                    # Push schema changes

# Testing APIs
npx expo start --clear              # Clear cache
npx expo start --tunnel             # Start with tunnel (for physical devices)

# Environment
echo $SUPABASE_URL                  # Check Supabase URL
echo $SUPABASE_ANON_KEY             # Check anon key
```

### Common API Patterns

```typescript
// 1. GET Request
const response = await apiClient.get('/users');

// 2. POST Request
const response = await apiClient.post('/users', { name: 'John' });

// 3. PUT Request
const response = await apiClient.put('/users/1', { name: 'Jane' });

// 4. DELETE Request
const response = await apiClient.delete('/users/1');

// 5. Query Parameters
const response = await apiClient.get('/users', {
  params: { limit: 10, offset: 0 },
});

// 6. Form Data
const formData = new FormData();
formData.append('file', file);
const response = await apiClient.post('/upload', formData, {
  headers: { 'Content-Type': 'multipart/form-data' },
});
```

### Error Codes Reference

| Code | Description | Action |
|------|-------------|--------|
| 200 | OK | Success |
| 201 | Created | Resource created |
| 400 | Bad Request | Check request data |
| 401 | Unauthorized | Login required |
| 403 | Forbidden | Permission denied |
| 404 | Not Found | Resource doesn't exist |
| 422 | Validation Error | Check input data |
| 429 | Too Many Requests | Slow down requests |
| 500 | Server Error | Try again later |
| 503 | Service Unavailable | Try again later |

---

**Ready to connect your app to the cloud? Let's build NexusCollect!**
