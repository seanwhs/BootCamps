# Appendix B: API Integration & Backend Setup Guide

Welcome to Appendix B! This comprehensive guide covers everything you need to know about connecting your TaskFlow app to a backend API. You'll learn how to build a production-ready API client, implement authentication, handle errors gracefully, and set up a complete backend service using Node.js, Express, and MongoDB (or PostgreSQL).

---

## Table of Contents

1. [API Architecture Overview](#api-architecture-overview)
2. [Setting Up the Backend](#setting-up-the-backend)
3. [API Client Implementation](#api-client-implementation)
4. [Authentication & Authorization](#authentication--authorization)
5. [Task API Endpoints](#task-api-endpoints)
6. [User Management API](#user-management-api)
7. [Error Handling Strategy](#error-handling-strategy)
8. [Real-time Updates with WebSockets](#real-time-updates-with-websockets)
9. [API Testing & Documentation](#api-testing--documentation)

---

## API Architecture Overview

### System Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                    CLIENT (React Native)                        │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │              API Client (Axios + React Query)          │   │
│  │  ┌────────────────────────────────────────────────────┐ │   │
│  │  │  Request Interceptor │ Response Interceptor       │ │   │
│  │  │  (Auth Token)        │ (Error Handling)           │ │   │
│  │  └────────────────────────────────────────────────────┘ │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                     API GATEWAY                                │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  Express.js Server (Port 3000)                         │   │
│  │  ┌────────────────────────────────────────────────────┐ │   │
│  │  │  Middleware: CORS, Logger, Auth, Rate Limiter    │ │   │
│  │  └────────────────────────────────────────────────────┘ │   │
│  │  ┌────────────────────────────────────────────────────┐ │   │
│  │  │  Routes: /api/auth, /api/tasks, /api/users       │ │   │
│  │  └────────────────────────────────────────────────────┘ │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                    DATA LAYER                                  │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────┐   │
│  │   MongoDB    │  │  PostgreSQL  │  │  Redis (Cache)   │   │
│  │  (Primary)   │  │   (Auth)     │  │  (Session/Queue) │   │
│  └──────────────┘  └──────────────┘  └──────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

### Data Flow

1. **Request Flow:** Client → API Gateway → Middleware → Route Handler → Database → Response
2. **Authentication Flow:** Login → JWT Generation → Token Storage → Authenticated Requests
3. **Real-time Flow:** WebSocket Connection → Event Subscription → Server → Push Updates

---

## Setting Up the Backend

### Backend Project Structure

```
backend/
├── .env                        # Environment variables
├── .env.example                # Environment template
├── .gitignore                  # Git ignore
├── package.json                # Dependencies
├── tsconfig.json               # TypeScript config
├── src/
│   ├── index.ts               # Entry point
│   ├── server.ts              # Express server setup
│   ├── app.ts                 # App configuration
│   ├── config/
│   │   ├── database.ts        # Database connection
│   │   ├── redis.ts           # Redis configuration
│   │   └── auth.ts            # Auth configuration
│   ├── models/
│   │   ├── User.ts            # User model
│   │   ├── Task.ts            # Task model
│   │   └── RefreshToken.ts    # Refresh token model
│   ├── controllers/
│   │   ├── authController.ts
│   │   ├── taskController.ts
│   │   └── userController.ts
│   ├── routes/
│   │   ├── authRoutes.ts
│   │   ├── taskRoutes.ts
│   │   └── userRoutes.ts
│   ├── middleware/
│   │   ├── auth.ts            # JWT verification
│   │   ├── validation.ts      # Request validation
│   │   ├── errorHandler.ts    # Error handling
│   │   └── rateLimiter.ts     # Rate limiting
│   ├── services/
│   │   ├── authService.ts
│   │   ├── taskService.ts
│   │   └── notificationService.ts
│   ├── utils/
│   │   ├── logger.ts          # Logging utility
│   │   ├── validation.ts      # Validation schemas
│   │   └── encryption.ts      # Encryption utilities
│   ├── types/
│   │   └── index.ts           # TypeScript types
│   └── websocket/
│       └── index.ts           # WebSocket server
├── tests/
│   ├── unit/
│   ├── integration/
│   └── e2e/
├── docker/
│   ├── Dockerfile
│   └── docker-compose.yml
└── docs/
    └── api.md                 # API documentation
```

### Backend Setup Commands

```bash
# Create backend directory
mkdir backend
cd backend

# Initialize npm
npm init -y

# Install production dependencies
npm install express cors helmet morgan compression dotenv
npm install mongoose jsonwebtoken bcryptjs
npm install socket.io @types/socket.io
npm install redis ioredis
npm install express-rate-limit express-validator
npm install multer cloudinary

# Install development dependencies
npm install --save-dev typescript @types/node
npm install --save-dev @types/express @types/cors @types/morgan
npm install --save-dev @types/jsonwebtoken @types/bcryptjs
npm install --save-dev nodemon ts-node
npm install --save-dev eslint prettier @typescript-eslint/eslint-plugin @typescript-eslint/parser

# Create TypeScript config
npx tsc --init
```

### Backend Configuration Files

#### `.env.example`
```bash
# Server
PORT=3000
NODE_ENV=development

# Database
MONGODB_URI=mongodb://localhost:27017/taskflow
POSTGRES_URI=postgresql://user:password@localhost:5432/taskflow

# Redis
REDIS_URL=redis://localhost:6379

# Auth
JWT_SECRET=your-secret-key-change-in-production
JWT_REFRESH_SECRET=your-refresh-secret-change-in-production
JWT_EXPIRES_IN=15m
JWT_REFRESH_EXPIRES_IN=7d

# Email (SMTP)
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your-email@gmail.com
SMTP_PASS=your-app-password

# Cloud Services
CLOUDINARY_CLOUD_NAME=your-cloud-name
CLOUDINARY_API_KEY=your-api-key
CLOUDINARY_API_SECRET=your-api-secret

# Security
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100
CORS_ORIGIN=http://localhost:19006

# WebSocket
WS_PORT=3001
```

#### `src/server.ts`
```typescript
import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import compression from 'compression';
import dotenv from 'dotenv';
import { createServer } from 'http';
import { Server as SocketServer } from 'socket.io';
import { connectDatabase } from './config/database';
import { connectRedis } from './config/redis';
import { errorHandler } from './middleware/errorHandler';
import { rateLimiter } from './middleware/rateLimiter';
import { authRoutes } from './routes/authRoutes';
import { taskRoutes } from './routes/taskRoutes';
import { userRoutes } from './routes/userRoutes';
import { logger } from './utils/logger';

// Load environment variables
dotenv.config();

// Create Express app
const app = express();
const httpServer = createServer(app);

// WebSocket server
const io = new SocketServer(httpServer, {
  cors: {
    origin: process.env.CORS_ORIGIN || 'http://localhost:19006',
    methods: ['GET', 'POST'],
  },
});

// Middleware
app.use(helmet());
app.use(cors({
  origin: process.env.CORS_ORIGIN || 'http://localhost:19006',
  credentials: true,
}));
app.use(compression());
app.use(morgan('combined', { stream: { write: (message) => logger.info(message.trim()) } }));
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Rate limiting
app.use('/api', rateLimiter);

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/tasks', taskRoutes);
app.use('/api/users', userRoutes);

// Health check
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'OK',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
  });
});

// Error handling
app.use(errorHandler);

// Start server
const PORT = process.env.PORT || 3000;

async function startServer() {
  try {
    // Connect to databases
    await connectDatabase();
    await connectRedis();

    // WebSocket connection handling
    io.on('connection', (socket) => {
      logger.info(`🔌 New WebSocket connection: ${socket.id}`);

      socket.on('authenticate', (token) => {
        // Authenticate socket connection
        // Store user ID on socket
      });

      socket.on('subscribe', (channel) => {
        socket.join(channel);
        logger.info(`📡 Socket ${socket.id} subscribed to ${channel}`);
      });

      socket.on('unsubscribe', (channel) => {
        socket.leave(channel);
      });

      socket.on('disconnect', () => {
        logger.info(`🔌 WebSocket disconnected: ${socket.id}`);
      });
    });

    // Start HTTP server
    httpServer.listen(PORT, () => {
      logger.info(`🚀 Server running on port ${PORT}`);
      logger.info(`📡 WebSocket running on port ${PORT}`);
      logger.info(`🌍 Environment: ${process.env.NODE_ENV}`);
    });
  } catch (error) {
    logger.error('❌ Failed to start server:', error);
    process.exit(1);
  }
}

startServer();

export { io };
```

#### `src/config/database.ts`
```typescript
import mongoose from 'mongoose';
import { logger } from '../utils/logger';

export async function connectDatabase() {
  try {
    const mongoURI = process.env.MONGODB_URI || 'mongodb://localhost:27017/taskflow';
    
    await mongoose.connect(mongoURI, {
      retryWrites: true,
      w: 'majority',
    });

    logger.info('✅ MongoDB connected successfully');
    
    // Handle connection events
    mongoose.connection.on('error', (error) => {
      logger.error('❌ MongoDB connection error:', error);
    });

    mongoose.connection.on('disconnected', () => {
      logger.warn('⚠️ MongoDB disconnected');
    });

    process.on('SIGINT', async () => {
      await mongoose.connection.close();
      logger.info('MongoDB connection closed through app termination');
      process.exit(0);
    });
  } catch (error) {
    logger.error('❌ MongoDB connection failed:', error);
    throw error;
  }
}
```

---

## API Client Implementation

### Complete API Client

```typescript
// src/services/apiClient.ts
import axios, {
  AxiosInstance,
  AxiosRequestConfig,
  AxiosResponse,
  AxiosError,
} from 'axios';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { Platform } from 'react-native';

/**
 * API Response Types
 */
export interface ApiResponse<T = any> {
  success: boolean;
  data?: T;
  error?: string;
  message?: string;
  statusCode: number;
}

export interface ApiError {
  code: string;
  message: string;
  details?: Record<string, any>;
}

/**
 * API Client Configuration
 */
class ApiClient {
  private client: AxiosInstance;
  private static instance: ApiClient;
  private refreshTokenPromise: Promise<string> | null = null;

  private constructor() {
    const baseURL = this.getBaseURL();
    
    this.client = axios.create({
      baseURL,
      timeout: 30000,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    });

    this.setupInterceptors();
  }

  /**
   * Get base URL based on environment
   */
  private getBaseURL(): string {
    if (__DEV__) {
      // Development
      if (Platform.OS === 'android') {
        return 'http://10.0.2.2:3000/api'; // Android emulator
      }
      return 'http://localhost:3000/api'; // iOS or web
    }
    
    // Production
    return process.env.EXPO_PUBLIC_API_URL || 'https://api.taskflow.app/api';
  }

  /**
   * Get singleton instance
   */
  static getInstance(): ApiClient {
    if (!ApiClient.instance) {
      ApiClient.instance = new ApiClient();
    }
    return ApiClient.instance;
  }

  /**
   * Setup request and response interceptors
   */
  private setupInterceptors() {
    // Request interceptor - Add auth token
    this.client.interceptors.request.use(
      async (config) => {
        const token = await this.getAccessToken();
        if (token) {
          config.headers.Authorization = `Bearer ${token}`;
        }
        return config;
      },
      (error) => Promise.reject(error)
    );

    // Response interceptor - Handle token refresh
    this.client.interceptors.response.use(
      (response) => response,
      async (error: AxiosError) => {
        const originalRequest = error.config as any;
        
        // If token expired and not already retrying
        if (
          error.response?.status === 401 &&
          !originalRequest._retry &&
          !originalRequest.url?.includes('/auth/refresh')
        ) {
          originalRequest._retry = true;
          
          try {
            const newToken = await this.refreshToken();
            if (newToken) {
              originalRequest.headers.Authorization = `Bearer ${newToken}`;
              return this.client(originalRequest);
            }
          } catch (refreshError) {
            // Refresh failed - logout user
            await this.clearTokens();
            // Navigate to login screen
            // navigationService.navigate('Login');
            return Promise.reject(refreshError);
          }
        }
        
        return Promise.reject(error);
      }
    );
  }

  /**
   * Get access token from storage
   */
  private async getAccessToken(): Promise<string | null> {
    try {
      return await AsyncStorage.getItem('@TaskFlow/accessToken');
    } catch (error) {
      console.error('Error getting access token:', error);
      return null;
    }
  }

  /**
   * Refresh token
   */
  private async refreshToken(): Promise<string | null> {
    // Prevent multiple refresh requests
    if (this.refreshTokenPromise) {
      return this.refreshTokenPromise;
    }

    this.refreshTokenPromise = new Promise(async (resolve, reject) => {
      try {
        const refreshToken = await AsyncStorage.getItem('@TaskFlow/refreshToken');
        if (!refreshToken) {
          reject(new Error('No refresh token'));
          return;
        }

        const response = await this.client.post('/auth/refresh', {
          refreshToken,
        });

        const { accessToken, refreshToken: newRefreshToken } = response.data.data;
        
        await AsyncStorage.setItem('@TaskFlow/accessToken', accessToken);
        await AsyncStorage.setItem('@TaskFlow/refreshToken', newRefreshToken);

        resolve(accessToken);
      } catch (error) {
        reject(error);
      } finally {
        this.refreshTokenPromise = null;
      }
    });

    return this.refreshTokenPromise;
  }

  /**
   * Clear auth tokens
   */
  private async clearTokens() {
    await AsyncStorage.removeItem('@TaskFlow/accessToken');
    await AsyncStorage.removeItem('@TaskFlow/refreshToken');
    await AsyncStorage.removeItem('@TaskFlow/userData');
  }

  /**
   * Generic request method
   */
  async request<T = any>(config: AxiosRequestConfig): Promise<ApiResponse<T>> {
    try {
      const response: AxiosResponse<ApiResponse<T>> = await this.client(config);
      return response.data;
    } catch (error) {
      if (axios.isAxiosError(error)) {
        const apiError = error.response?.data as ApiResponse;
        throw new Error(apiError?.error || error.message);
      }
      throw error;
    }
  }

  /**
   * GET request
   */
  async get<T = any>(
    url: string,
    params?: Record<string, any>
  ): Promise<ApiResponse<T>> {
    return this.request<T>({
      method: 'GET',
      url,
      params,
    });
  }

  /**
   * POST request
   */
  async post<T = any>(
    url: string,
    data?: any,
    config?: AxiosRequestConfig
  ): Promise<ApiResponse<T>> {
    return this.request<T>({
      method: 'POST',
      url,
      data,
      ...config,
    });
  }

  /**
   * PUT request
   */
  async put<T = any>(
    url: string,
    data?: any
  ): Promise<ApiResponse<T>> {
    return this.request<T>({
      method: 'PUT',
      url,
      data,
    });
  }

  /**
   * PATCH request
   */
  async patch<T = any>(
    url: string,
    data?: any
  ): Promise<ApiResponse<T>> {
    return this.request<T>({
      method: 'PATCH',
      url,
      data,
    });
  }

  /**
   * DELETE request
   */
  async delete<T = any>(
    url: string,
    params?: Record<string, any>
  ): Promise<ApiResponse<T>> {
    return this.request<T>({
      method: 'DELETE',
      url,
      params,
    });
  }

  /**
   * File upload
   */
  async upload<T = any>(
    url: string,
    formData: FormData,
    onProgress?: (progress: number) => void
  ): Promise<ApiResponse<T>> {
    return this.request<T>({
      method: 'POST',
      url,
      data: formData,
      headers: {
        'Content-Type': 'multipart/form-data',
      },
      onUploadProgress: (progressEvent) => {
        if (onProgress && progressEvent.total) {
          const progress = (progressEvent.loaded / progressEvent.total) * 100;
          onProgress(progress);
        }
      },
    });
  }
}

// Export singleton instance
export const apiClient = ApiClient.getInstance();
```

### API Service Layer

```typescript
// src/services/taskApi.ts
import { apiClient, ApiResponse } from './apiClient';
import { Task } from '../stores/taskStore';

export interface CreateTaskRequest {
  title: string;
  description?: string;
  priority: 'low' | 'medium' | 'high';
  dueDate: string;
  category?: string;
  assignedTo?: string;
}

export interface UpdateTaskRequest {
  title?: string;
  description?: string;
  priority?: 'low' | 'medium' | 'high';
  status?: 'todo' | 'in-progress' | 'done';
  dueDate?: string;
  category?: string;
  assignedTo?: string;
}

export interface TaskFilters {
  status?: 'todo' | 'in-progress' | 'done';
  priority?: 'low' | 'medium' | 'high';
  category?: string;
  assignedTo?: string;
  search?: string;
  fromDate?: string;
  toDate?: string;
  page?: number;
  limit?: number;
}

export interface TaskListResponse {
  tasks: Task[];
  total: number;
  page: number;
  totalPages: number;
}

/**
 * Task API Service
 */
export class TaskApi {
  /**
   * Get tasks with pagination and filters
   */
  static async getTasks(filters: TaskFilters = {}): Promise<ApiResponse<TaskListResponse>> {
    const queryParams = new URLSearchParams();
    
    Object.entries(filters).forEach(([key, value]) => {
      if (value !== undefined && value !== null) {
        queryParams.append(key, String(value));
      }
    });

    return apiClient.get<TaskListResponse>(`/tasks?${queryParams.toString()}`);
  }

  /**
   * Get a single task by ID
   */
  static async getTask(taskId: string): Promise<ApiResponse<Task>> {
    return apiClient.get<Task>(`/tasks/${taskId}`);
  }

  /**
   * Create a new task
   */
  static async createTask(taskData: CreateTaskRequest): Promise<ApiResponse<Task>> {
    return apiClient.post<Task>('/tasks', taskData);
  }

  /**
   * Update a task
   */
  static async updateTask(
    taskId: string,
    taskData: UpdateTaskRequest
  ): Promise<ApiResponse<Task>> {
    return apiClient.patch<Task>(`/tasks/${taskId}`, taskData);
  }

  /**
   * Delete a task
   */
  static async deleteTask(taskId: string): Promise<ApiResponse<void>> {
    return apiClient.delete(`/tasks/${taskId}`);
  }

  /**
   * Get task statistics
   */
  static async getTaskStats(): Promise<ApiResponse<{
    total: number;
    todo: number;
    inProgress: number;
    done: number;
    byPriority: Record<string, number>;
    byCategory: Record<string, number>;
  }>> {
    return apiClient.get('/tasks/stats');
  }

  /**
   * Bulk update tasks
   */
  static async bulkUpdateTasks(
    updates: Array<{ id: string; data: UpdateTaskRequest }>
  ): Promise<ApiResponse<Task[]>> {
    return apiClient.post('/tasks/bulk', { updates });
  }

  /**
   * Search tasks
   */
  static async searchTasks(query: string): Promise<ApiResponse<Task[]>> {
    return apiClient.get<Task[]>('/tasks/search', { q: query });
  }
}

// src/services/authApi.ts
export interface LoginRequest {
  email: string;
  password: string;
}

export interface RegisterRequest {
  name: string;
  email: string;
  password: string;
}

export interface AuthResponse {
  user: {
    id: string;
    name: string;
    email: string;
    avatar?: string;
    createdAt: string;
  };
  accessToken: string;
  refreshToken: string;
}

export class AuthApi {
  /**
   * Login user
   */
  static async login(credentials: LoginRequest): Promise<ApiResponse<AuthResponse>> {
    return apiClient.post<AuthResponse>('/auth/login', credentials);
  }

  /**
   * Register user
   */
  static async register(userData: RegisterRequest): Promise<ApiResponse<AuthResponse>> {
    return apiClient.post<AuthResponse>('/auth/register', userData);
  }

  /**
   * Logout user
   */
  static async logout(): Promise<ApiResponse<void>> {
    return apiClient.post('/auth/logout', {});
  }

  /**
   * Refresh token
   */
  static async refreshToken(refreshToken: string): Promise<ApiResponse<AuthResponse>> {
    return apiClient.post<AuthResponse>('/auth/refresh', { refreshToken });
  }

  /**
   * Forgot password
   */
  static async forgotPassword(email: string): Promise<ApiResponse<void>> {
    return apiClient.post('/auth/forgot-password', { email });
  }

  /**
   * Reset password
   */
  static async resetPassword(token: string, newPassword: string): Promise<ApiResponse<void>> {
    return apiClient.post('/auth/reset-password', { token, newPassword });
  }

  /**
   * Verify email
   */
  static async verifyEmail(token: string): Promise<ApiResponse<void>> {
    return apiClient.post('/auth/verify-email', { token });
  }
}

// src/services/userApi.ts
export interface UpdateUserRequest {
  name?: string;
  email?: string;
  avatar?: string;
  preferences?: Record<string, any>;
}

export interface UserResponse {
  id: string;
  name: string;
  email: string;
  avatar?: string;
  createdAt: string;
  updatedAt: string;
  preferences: Record<string, any>;
}

export class UserApi {
  /**
   * Get current user profile
   */
  static async getProfile(): Promise<ApiResponse<UserResponse>> {
    return apiClient.get<UserResponse>('/users/me');
  }

  /**
   * Update user profile
   */
  static async updateProfile(data: UpdateUserRequest): Promise<ApiResponse<UserResponse>> {
    return apiClient.patch<UserResponse>('/users/me', data);
  }

  /**
   * Get user by ID
   */
  static async getUser(userId: string): Promise<ApiResponse<UserResponse>> {
    return apiClient.get<UserResponse>(`/users/${userId}`);
  }

  /**
   * Search users
   */
  static async searchUsers(query: string): Promise<ApiResponse<UserResponse[]>> {
    return apiClient.get<UserResponse[]>('/users/search', { q: query });
  }

  /**
   * Update user preferences
   */
  static async updatePreferences(preferences: Record<string, any>): Promise<ApiResponse<void>> {
    return apiClient.patch('/users/me/preferences', { preferences });
  }

  /**
   * Upload avatar
   */
  static async uploadAvatar(avatarUri: string): Promise<ApiResponse<{ avatarUrl: string }>> {
    const formData = new FormData();
    formData.append('avatar', {
      uri: avatarUri,
      name: 'avatar.jpg',
      type: 'image/jpeg',
    } as any);
    
    return apiClient.upload<{ avatarUrl: string }>('/users/me/avatar', formData);
  }
}
```

### React Query Integration

```typescript
// src/hooks/useTasks.ts
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { TaskApi, TaskFilters, CreateTaskRequest, UpdateTaskRequest } from '../services/taskApi';
import { useAuthStore } from '../stores/authStore';

/**
 * Query keys for caching
 */
export const taskKeys = {
  all: ['tasks'] as const,
  lists: () => [...taskKeys.all, 'list'] as const,
  list: (filters: TaskFilters) => [...taskKeys.lists(), filters] as const,
  details: () => [...taskKeys.all, 'detail'] as const,
  detail: (id: string) => [...taskKeys.details(), id] as const,
  stats: () => [...taskKeys.all, 'stats'] as const,
};

/**
 * Hook for fetching tasks with filters
 */
export function useTasks(filters: TaskFilters = {}) {
  return useQuery({
    queryKey: taskKeys.list(filters),
    queryFn: () => TaskApi.getTasks(filters),
    staleTime: 5 * 60 * 1000, // 5 minutes
    cacheTime: 10 * 60 * 1000, // 10 minutes
    retry: 2,
    select: (response) => response.data,
  });
}

/**
 * Hook for fetching a single task
 */
export function useTask(taskId: string) {
  return useQuery({
    queryKey: taskKeys.detail(taskId),
    queryFn: () => TaskApi.getTask(taskId),
    enabled: !!taskId,
    retry: 1,
    select: (response) => response.data,
  });
}

/**
 * Hook for creating a task
 */
export function useCreateTask() {
  const queryClient = useQueryClient();
  const { user } = useAuthStore();

  return useMutation({
    mutationFn: (taskData: CreateTaskRequest) => TaskApi.createTask(taskData),
    onSuccess: (response) => {
      // Invalidate tasks list to refetch
      queryClient.invalidateQueries({ queryKey: taskKeys.lists() });
      
      // Invalidate stats
      queryClient.invalidateQueries({ queryKey: taskKeys.stats() });
    },
    onError: (error) => {
      console.error('Failed to create task:', error);
    },
  });
}

/**
 * Hook for updating a task
 */
export function useUpdateTask() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({ taskId, data }: { taskId: string; data: UpdateTaskRequest }) =>
      TaskApi.updateTask(taskId, data),
    onSuccess: (response, variables) => {
      // Update individual task cache
      queryClient.setQueryData(
        taskKeys.detail(variables.taskId),
        response.data
      );
      
      // Invalidate lists
      queryClient.invalidateQueries({ queryKey: taskKeys.lists() });
      queryClient.invalidateQueries({ queryKey: taskKeys.stats() });
    },
  });
}

/**
 * Hook for deleting a task
 */
export function useDeleteTask() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (taskId: string) => TaskApi.deleteTask(taskId),
    onSuccess: (_, taskId) => {
      // Remove from cache
      queryClient.removeQueries({ queryKey: taskKeys.detail(taskId) });
      
      // Invalidate lists
      queryClient.invalidateQueries({ queryKey: taskKeys.lists() });
      queryClient.invalidateQueries({ queryKey: taskKeys.stats() });
    },
  });
}

/**
 * Hook for task statistics
 */
export function useTaskStats() {
  return useQuery({
    queryKey: taskKeys.stats(),
    queryFn: () => TaskApi.getTaskStats(),
    staleTime: 2 * 60 * 1000, // 2 minutes
    select: (response) => response.data,
  });
}
```

---

## Authentication & Authorization

### JWT Authentication Implementation

```typescript
// backend/src/middleware/auth.ts
import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { User } from '../models/User';
import { logger } from '../utils/logger';

export interface AuthRequest extends Request {
  user?: any;
  token?: string;
}

/**
 * JWT Authentication Middleware
 */
export const authenticate = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
) => {
  try {
    // Get token from header
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({
        success: false,
        error: 'No token provided',
      });
    }

    const token = authHeader.split(' ')[1];
    req.token = token;

    // Verify token
    const decoded = jwt.verify(token, process.env.JWT_SECRET!) as {
      userId: string;
      email: string;
    };

    // Get user from database
    const user = await User.findById(decoded.userId).select('-password');
    if (!user) {
      return res.status(401).json({
        success: false,
        error: 'User not found',
      });
    }

    req.user = user;
    next();
  } catch (error) {
    if (error instanceof jwt.TokenExpiredError) {
      return res.status(401).json({
        success: false,
        error: 'Token expired',
        code: 'TOKEN_EXPIRED',
      });
    }

    if (error instanceof jwt.JsonWebTokenError) {
      return res.status(401).json({
        success: false,
        error: 'Invalid token',
        code: 'INVALID_TOKEN',
      });
    }

    logger.error('Auth middleware error:', error);
    return res.status(500).json({
      success: false,
      error: 'Authentication failed',
    });
  }
};

/**
 * Authorization Middleware - Check user role
 */
export const authorize = (...roles: string[]) => {
  return (req: AuthRequest, res: Response, next: NextFunction) => {
    if (!req.user) {
      return res.status(401).json({
        success: false,
        error: 'Unauthorized',
      });
    }

    if (!roles.includes(req.user.role)) {
      return res.status(403).json({
        success: false,
        error: 'Forbidden - Insufficient permissions',
      });
    }

    next();
  };
};

/**
 * Rate Limiter
 */
import rateLimit from 'express-rate-limit';

export const authRateLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 5, // 5 requests per window
  message: {
    success: false,
    error: 'Too many authentication attempts. Please try again later.',
  },
  standardHeaders: true,
  legacyHeaders: false,
});
```

### User Model with JWT Methods

```typescript
// backend/src/models/User.ts
import mongoose, { Schema, Document } from 'mongoose';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';

export interface IUser extends Document {
  name: string;
  email: string;
  password: string;
  avatar?: string;
  role: 'user' | 'admin';
  preferences: {
    theme: 'light' | 'dark' | 'system';
    notifications: boolean;
    soundEnabled: boolean;
    vibrationEnabled: boolean;
  };
  isEmailVerified: boolean;
  lastLogin: Date;
  createdAt: Date;
  updatedAt: Date;
  comparePassword(candidatePassword: string): Promise<boolean>;
  generateAuthToken(): string;
  generateRefreshToken(): string;
}

const UserSchema = new Schema<IUser>(
  {
    name: {
      type: String,
      required: [true, 'Name is required'],
      trim: true,
      minlength: [2, 'Name must be at least 2 characters'],
      maxlength: [50, 'Name cannot exceed 50 characters'],
    },
    email: {
      type: String,
      required: [true, 'Email is required'],
      unique: true,
      trim: true,
      lowercase: true,
      match: [/^\S+@\S+\.\S+$/, 'Please enter a valid email address'],
    },
    password: {
      type: String,
      required: [true, 'Password is required'],
      minlength: [6, 'Password must be at least 6 characters'],
      select: false,
    },
    avatar: {
      type: String,
      default: null,
    },
    role: {
      type: String,
      enum: ['user', 'admin'],
      default: 'user',
    },
    preferences: {
      theme: {
        type: String,
        enum: ['light', 'dark', 'system'],
        default: 'system',
      },
      notifications: {
        type: Boolean,
        default: true,
      },
      soundEnabled: {
        type: Boolean,
        default: true,
      },
      vibrationEnabled: {
        type: Boolean,
        default: true,
      },
    },
    isEmailVerified: {
      type: Boolean,
      default: false,
    },
    lastLogin: {
      type: Date,
      default: null,
    },
  },
  {
    timestamps: true,
    toJSON: {
      transform: (_, ret) => {
        delete ret.password;
        delete ret.__v;
        return ret;
      },
    },
  }
);

// Hash password before saving
UserSchema.pre('save', async function (next) {
  if (!this.isModified('password')) return next();
  
  try {
    const salt = await bcrypt.genSalt(10);
    this.password = await bcrypt.hash(this.password, salt);
    next();
  } catch (error: any) {
    next(error);
  }
});

// Compare password method
UserSchema.methods.comparePassword = async function (
  candidatePassword: string): Promise<boolean> {
  return bcrypt.compare(candidatePassword, this.password);
};

// Generate JWT access token
UserSchema.methods.generateAuthToken = function (): string {
  return jwt.sign(
    { userId: this._id, email: this.email, role: this.role },
    process.env.JWT_SECRET!,
    { expiresIn: process.env.JWT_EXPIRES_IN || '15m' }
  );
};

// Generate refresh token
UserSchema.methods.generateRefreshToken = function (): string {
  return jwt.sign(
    { userId: this._id },
    process.env.JWT_REFRESH_SECRET!,
    { expiresIn: process.env.JWT_REFRESH_EXPIRES_IN || '7d' }
  );
};

export const User = mongoose.model<IUser>('User', UserSchema);
```

---

## Task API Endpoints

### Task Controller

```typescript
// backend/src/controllers/taskController.ts
import { Request, Response } from 'express';
import { Task, ITask } from '../models/Task';
import { AuthRequest } from '../middleware/auth';
import { logger } from '../utils/logger';

export class TaskController {
  /**
   * Get all tasks with pagination and filters
   */
  static async getTasks(req: AuthRequest, res: Response) {
    try {
      const {
        status,
        priority,
        category,
        assignedTo,
        search,
        fromDate,
        toDate,
        page = 1,
        limit = 20,
      } = req.query;

      const filters: any = {};

      // Add filters if provided
      if (status) filters.status = status;
      if (priority) filters.priority = priority;
      if (category) filters.category = { $regex: category, $options: 'i' };
      if (assignedTo) filters.assignedTo = assignedTo;
      
      // Search in title and description
      if (search) {
        filters.$or = [
          { title: { $regex: search, $options: 'i' } },
          { description: { $regex: search, $options: 'i' } },
        ];
      }

      // Date range
      if (fromDate || toDate) {
        filters.dueDate = {};
        if (fromDate) filters.dueDate.$gte = new Date(fromDate as string);
        if (toDate) filters.dueDate.$lte = new Date(toDate as string);
      }

      // Only get user's tasks unless admin
      if (req.user?.role !== 'admin') {
        filters.assignedTo = req.user?._id;
      }

      const skip = (Number(page) - 1) * Number(limit);
      
      const [tasks, total] = await Promise.all([
        Task.find(filters)
          .populate('assignedTo', 'name email avatar')
          .populate('createdBy', 'name email')
          .sort({ dueDate: 1, priority: -1 })
          .skip(skip)
          .limit(Number(limit)),
        Task.countDocuments(filters),
      ]);

      res.status(200).json({
        success: true,
        data: {
          tasks,
          total,
          page: Number(page),
          totalPages: Math.ceil(total / Number(limit)),
        },
      });
    } catch (error) {
      logger.error('Error fetching tasks:', error);
      res.status(500).json({
        success: false,
        error: 'Failed to fetch tasks',
      });
    }
  }

  /**
   * Get a single task by ID
   */
  static async getTask(req: AuthRequest, res: Response) {
    try {
      const task = await Task.findOne({
        _id: req.params.id,
        $or: [
          { assignedTo: req.user?._id },
          { createdBy: req.user?._id },
          { isPublic: true },
        ],
      })
        .populate('assignedTo', 'name email avatar')
        .populate('createdBy', 'name email')
        .populate('comments.user', 'name email avatar');

      if (!task) {
        return res.status(404).json({
          success: false,
          error: 'Task not found',
        });
      }

      res.status(200).json({
        success: true,
        data: task,
      });
    } catch (error) {
      logger.error('Error fetching task:', error);
      res.status(500).json({
        success: false,
        error: 'Failed to fetch task',
      });
    }
  }

  /**
   * Create a new task
   */
  static async createTask(req: AuthRequest, res: Response) {
    try {
      const taskData = {
        ...req.body,
        createdBy: req.user?._id,
        assignedTo: req.body.assignedTo || req.user?._id,
      };

      const task = new Task(taskData);
      await task.save();

      // Populate references
      await task.populate('assignedTo', 'name email avatar');
      await task.populate('createdBy', 'name email');

      // Emit WebSocket event for real-time updates
      req.app.get('io').to('tasks').emit('taskCreated', task);

      res.status(201).json({
        success: true,
        data: task,
      });
    } catch (error) {
      logger.error('Error creating task:', error);
      res.status(500).json({
        success: false,
        error: 'Failed to create task',
      });
    }
  }

  /**
   * Update a task
   */
  static async updateTask(req: AuthRequest, res: Response) {
    try {
      const task = await Task.findById(req.params.id);
      
      if (!task) {
        return res.status(404).json({
          success: false,
          error: 'Task not found',
        });
      }

      // Check permissions
      const canEdit = 
        task.createdBy.toString() === req.user?._id.toString() ||
        task.assignedTo.toString() === req.user?._id.toString() ||
        req.user?.role === 'admin';

      if (!canEdit) {
        return res.status(403).json({
          success: false,
          error: 'You do not have permission to edit this task',
        });
      }

      // Update task
      Object.assign(task, req.body);
      task.updatedAt = new Date();
      await task.save();

      await task.populate('assignedTo', 'name email avatar');
      await task.populate('createdBy', 'name email');

      // Emit WebSocket event
      req.app.get('io').to('tasks').emit('taskUpdated', task);

      res.status(200).json({
        success: true,
        data: task,
      });
    } catch (error) {
      logger.error('Error updating task:', error);
      res.status(500).json({
        success: false,
        error: 'Failed to update task',
      });
    }
  }

  /**
   * Delete a task
   */
  static async deleteTask(req: AuthRequest, res: Response) {
    try {
      const task = await Task.findById(req.params.id);

      if (!task) {
        return res.status(404).json({
          success: false,
          error: 'Task not found',
        });
      }

      // Check permissions
      const canDelete = 
        task.createdBy.toString() === req.user?._id.toString() ||
        req.user?.role === 'admin';

      if (!canDelete) {
        return res.status(403).json({
          success: false,
          error: 'You do not have permission to delete this task',
        });
      }

      await Task.findByIdAndDelete(req.params.id);

      // Emit WebSocket event
      req.app.get('io').to('tasks').emit('taskDeleted', { id: req.params.id });

      res.status(200).json({
        success: true,
        message: 'Task deleted successfully',
      });
    } catch (error) {
      logger.error('Error deleting task:', error);
      res.status(500).json({
        success: false,
        error: 'Failed to delete task',
      });
    }
  }

  /**
   * Get task statistics
   */
  static async getTaskStats(req: AuthRequest, res: Response) {
    try {
      const filter = req.user?.role === 'admin' ? {} : { assignedTo: req.user?._id };

      const [
        total,
        todo,
        inProgress,
        done,
        byPriority,
        byCategory,
      ] = await Promise.all([
        Task.countDocuments(filter),
        Task.countDocuments({ ...filter, status: 'todo' }),
        Task.countDocuments({ ...filter, status: 'in-progress' }),
        Task.countDocuments({ ...filter, status: 'done' }),
        Task.aggregate([
          { $match: filter },
          { $group: { _id: '$priority', count: { $sum: 1 } } },
        ]),
        Task.aggregate([
          { $match: filter },
          { $group: { _id: '$category', count: { $sum: 1 } } },
        ]),
      ]);

      const priorityStats: Record<string, number> = {};
      byPriority.forEach((item) => {
        priorityStats[item._id] = item.count;
      });

      const categoryStats: Record<string, number> = {};
      byCategory.forEach((item) => {
        categoryStats[item._id] = item.count;
      });

      res.status(200).json({
        success: true,
        data: {
          total,
          todo,
          inProgress,
          done,
          byPriority: priorityStats,
          byCategory: categoryStats,
        },
      });
    } catch (error) {
      logger.error('Error fetching task stats:', error);
      res.status(500).json({
        success: false,
        error: 'Failed to fetch task statistics',
      });
    }
  }
}
```

---

## Real-time Updates with WebSockets

### WebSocket Client Implementation

```typescript
// src/services/websocket.ts
import io, { Socket } from 'socket.io-client';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { Platform } from 'react-native';

export interface WebSocketEvent {
  type: 'taskCreated' | 'taskUpdated' | 'taskDeleted' | 'commentAdded' | 'userUpdated';
  data: any;
  timestamp: string;
}

export class WebSocketService {
  private socket: Socket | null = null;
  private static instance: WebSocketService;
  private reconnectAttempts = 0;
  private maxReconnectAttempts = 5;
  private listeners: Map<string, Array<(data: any) => void>> = new Map();

  private constructor() {}

  static getInstance(): WebSocketService {
    if (!WebSocketService.instance) {
      WebSocketService.instance = new WebSocketService();
    }
    return WebSocketService.instance;
  }

  /**
   * Connect to WebSocket server
   */
  async connect(): Promise<void> {
    if (this.socket?.connected) return;

    const token = await AsyncStorage.getItem('@TaskFlow/accessToken');
    if (!token) {
      console.warn('No access token available for WebSocket connection');
      return;
    }

    const wsUrl = this.getWebSocketUrl();
    
    this.socket = io(wsUrl, {
      auth: { token },
      transports: ['websocket', 'polling'],
      reconnection: true,
      reconnectionAttempts: this.maxReconnectAttempts,
      reconnectionDelay: 1000,
      reconnectionDelayMax: 5000,
    });

    this.setupListeners();
  }

  /**
   * Get WebSocket URL
   */
  private getWebSocketUrl(): string {
    if (__DEV__) {
      if (Platform.OS === 'android') {
        return 'http://10.0.2.2:3001'; // Android emulator
      }
      return 'http://localhost:3001'; // iOS or web
    }
    return process.env.EXPO_PUBLIC_WS_URL || 'wss://api.taskflow.app';
  }

  /**
   * Setup WebSocket event listeners
   */
  private setupListeners() {
    if (!this.socket) return;

    this.socket.on('connect', () => {
      console.log('✅ WebSocket connected');
      this.reconnectAttempts = 0;
      this.emitEvent('connected', {});
    });

    this.socket.on('disconnect', (reason) => {
      console.log(`❌ WebSocket disconnected: ${reason}`);
    });

    this.socket.on('connect_error', (error) => {
      console.error('WebSocket connection error:', error);
      this.reconnectAttempts++;
      
      if (this.reconnectAttempts >= this.maxReconnectAttempts) {
        console.warn('Max reconnect attempts reached');
        this.disconnect();
      }
    });

    // Handle authentication events
    this.socket.on('authenticated', () => {
      console.log('🔐 WebSocket authenticated');
      // Join user-specific rooms
      this.joinRooms();
    });

    // Handle incoming events
    this.socket.on('event', (event: WebSocketEvent) => {
      this.handleEvent(event);
    });
  }

  /**
   * Join user-specific rooms
   */
  private async joinRooms() {
    const userData = await AsyncStorage.getItem('@TaskFlow/userData');
    if (userData) {
      const user = JSON.parse(userData);
      this.socket?.emit('join', `user_${user.id}`);
      this.socket?.emit('join', 'tasks');
    }
  }

  /**
   * Handle incoming events
   */
  private handleEvent(event: WebSocketEvent) {
    const listeners = this.listeners.get(event.type) || [];
    listeners.forEach((callback) => {
      try {
        callback(event.data);
      } catch (error) {
        console.error('Error in event listener:', error);
      }
    });
  }

  /**
   * Listen to a specific event type
   */
  on(eventType: string, callback: (data: any) => void): () => void {
    if (!this.listeners.has(eventType)) {
      this.listeners.set(eventType, []);
    }
    this.listeners.get(eventType)?.push(callback);

    // Return unsubscribe function
    return () => {
      const callbacks = this.listeners.get(eventType) || [];
      const index = callbacks.indexOf(callback);
      if (index > -1) {
        callbacks.splice(index, 1);
      }
    };
  }

  /**
   * Emit an event
   */
  emitEvent(event: string, data: any): void {
    if (this.socket?.connected) {
      this.socket.emit(event, data);
    } else {
      console.warn('Cannot emit event - WebSocket not connected');
    }
  }

  /**
   * Disconnect WebSocket
   */
  disconnect(): void {
    if (this.socket) {
      this.socket.disconnect();
      this.socket = null;
    }
    this.listeners.clear();
  }

  /**
   * Check if WebSocket is connected
   */
  isConnected(): boolean {
    return this.socket?.connected || false;
  }
}

export const wsService = WebSocketService.getInstance();
```

---

## Error Handling Strategy

### Global Error Handler

```typescript
// src/utils/errorHandler.ts
import { Alert } from 'react-native';
import { navigationService } from '../navigation/NavigationService';
import { monitoring } from './monitoring';

export enum ErrorType {
  NETWORK = 'network',
  AUTHENTICATION = 'authentication',
  AUTHORIZATION = 'authorization',
  NOT_FOUND = 'not_found',
  VALIDATION = 'validation',
  SERVER = 'server',
  UNKNOWN = 'unknown',
}

export interface AppError {
  type: ErrorType;
  message: string;
  details?: any;
  code?: string;
  shouldRedirect?: boolean;
  retryable?: boolean;
}

export class ErrorHandler {
  /**
   * Handle API errors
   */
  static handleApiError(error: any, context?: string): AppError {
    console.error(`API Error${context ? ` (${context})` : ''}:`, error);

    // Network errors
    if (!error.response) {
      return {
        type: ErrorType.NETWORK,
        message: 'Network error. Please check your internet connection.',
        retryable: true,
      };
    }

    const { status, data } = error.response;

    // Authentication errors
    if (status === 401) {
      return {
        type: ErrorType.AUTHENTICATION,
        message: data?.error || 'Your session has expired. Please login again.',
        shouldRedirect: true,
        retryable: false,
      };
    }

    // Authorization errors
    if (status === 403) {
      return {
        type: ErrorType.AUTHORIZATION,
        message: data?.error || 'You do not have permission to perform this action.',
        retryable: false,
      };
    }

    // Not found errors
    if (status === 404) {
      return {
        type: ErrorType.NOT_FOUND,
        message: data?.error || 'Resource not found.',
        retryable: false,
      };
    }

    // Validation errors
    if (status === 422) {
      return {
        type: ErrorType.VALIDATION,
        message: data?.error || 'Validation failed.',
        details: data?.details,
        retryable: false,
      };
    }

    // Server errors
    if (status >= 500) {
      return {
        type: ErrorType.SERVER,
        message: 'Server error. Please try again later.',
        retryable: true,
      };
    }

    // Unknown errors
    return {
      type: ErrorType.UNKNOWN,
      message: data?.error || 'An unexpected error occurred.',
      retryable: true,
    };
  }

  /**
   * Show error to user
   */
  static showError(error: AppError): void {
    Alert.alert(
      'Error',
      error.message,
      [
        {
          text: 'OK',
          style: 'default',
        },
        ...(error.retryable
          ? [
              {
                text: 'Retry',
                onPress: () => {
                  // Implement retry logic
                },
              },
            ]
          : []),
      ],
      { cancelable: true }
    );

    // Log error to monitoring service
    monitoring.captureError({
      message: error.message,
      context: { type: error.type, code: error.code },
      severity: 'error',
    });

    // Redirect if needed
    if (error.shouldRedirect) {
      navigationService.navigate('Login');
    }
  }

  /**
   * Handle async operations with error handling
   */
  static async withErrorHandling<T>(
    operation: () => Promise<T>,
    context?: string
  ): Promise<T | null> {
    try {
      return await operation();
    } catch (error) {
      const appError = this.handleApiError(error, context);
      this.showError(appError);
      return null;
    }
  }

  /**
   * Retry operation with exponential backoff
   */
  static async retryWithBackoff<T>(
    operation: () => Promise<T>,
    maxRetries: number = 3,
    baseDelay: number = 1000
  ): Promise<T> {
    let lastError: Error;
    
    for (let attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        return await operation();
      } catch (error) {
        lastError = error as Error;
        
        if (attempt === maxRetries) {
          throw error;
        }
        
        // Exponential backoff
        const delay = baseDelay * Math.pow(2, attempt - 1);
        await new Promise(resolve => setTimeout(resolve, delay));
      }
    }
    
    throw lastError!;
  }
}
```

---

This appendix provides everything you need to build and integrate a production-ready backend API with your React Native app. The complete code includes authentication, task management, real-time updates, and robust error handling.

