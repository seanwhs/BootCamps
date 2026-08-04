# Part 3 — Asynchronous State Management

## Section 14: Working with External APIs

In the previous sections, you learned how to handle async actions and concurrency. Now it's time to connect your Zustand stores to real external APIs—REST, GraphQL, WebSockets, and more. This section will give you battle-tested patterns for integrating with any data source, handling errors, caching, and keeping your UI in sync.

---

## The Target: Seamless API Integration

By the end of this section, you'll be able to:
- Connect Zustand stores to REST APIs with robust error handling
- Integrate GraphQL queries and mutations using Apollo Client or raw fetch
- Build real‑time features with WebSockets and Server‑Sent Events (SSE)
- Implement polling for periodic data updates
- Set up background synchronization with service workers and offline queues
- Apply caching, retry, and optimistic update patterns for all API types

---

## The Concept: APIs as State Suppliers

Think of external APIs like **delivery services** for your application:

```
┌─────────────────────────────────────────────────────────────────┐
│                    API INTEGRATION LAYER                       │
│                                                                 │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐    │
│  │  REST API    │    │  GraphQL     │    │  WebSocket   │    │
│  │  (HTTP)      │    │  (GraphQL)   │    │  (WS)        │    │
│  └──────┬───────┘    └──────┬───────┘    └──────┬───────┘    │
│         │                   │                   │             │
│         ▼                   ▼                   ▼             │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                    API CLIENT LAYER                      │  │
│  │  • Fetch / Axios                                        │  │
│  │  • Apollo Client                                        │  │
│  │  • WebSocket / Socket.io                                │  │
│  │  • EventSource                                          │  │
│  └──────────────────────────────────────────────────────────┘  │
│                         │                                      │
│                         ▼                                      │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                    ZUSTAND STORE                         │  │
│  │  • Normalized state                                      │  │
│  │  • Loading/error status                                  │  │
│  │  • Cache invalidation                                    │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

**Key Principles**:
- **Separation of concerns**: API logic in services/clients, state management in stores
- **Error handling**: Every API interaction must handle failures gracefully
- **Caching**: Avoid redundant network calls with smart caching strategies
- **Offline support**: Queue mutations when offline and sync later

---

## The Implementation: API Integrations

### Step 1: REST API with Axios Client

First, set up a robust HTTP client with interceptors, retries, and authentication:

```typescript
// src/services/apiClient.ts
import axios, { AxiosInstance, AxiosRequestConfig, AxiosResponse } from 'axios';
import { useAuthStore } from '../store/authStore';

// Configuration
const API_BASE_URL = process.env.REACT_APP_API_URL || 'https://api.example.com';

// Create Axios instance
export const apiClient: AxiosInstance = axios.create({
  baseURL: API_BASE_URL,
  timeout: 30000,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Request interceptor: add auth token
apiClient.interceptors.request.use(
  (config) => {
    const token = useAuthStore.getState().token;
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => Promise.reject(error)
);

// Response interceptor: handle errors globally
apiClient.interceptors.response.use(
  (response) => response,
  async (error) => {
    const originalRequest = error.config;
    
    // Handle 401 Unauthorized - attempt refresh token
    if (error.response?.status === 401 && !originalRequest._retry) {
      originalRequest._retry = true;
      try {
        const refreshToken = useAuthStore.getState().refreshToken;
        if (!refreshToken) throw new Error('No refresh token');
        
        const response = await axios.post(`${API_BASE_URL}/auth/refresh`, {
          refreshToken,
        });
        const { token, refreshToken: newRefreshToken } = response.data;
        
        useAuthStore.getState().setTokens(token, newRefreshToken);
        originalRequest.headers.Authorization = `Bearer ${token}`;
        return apiClient(originalRequest);
      } catch (refreshError) {
        // Refresh failed - logout
        useAuthStore.getState().logout();
        return Promise.reject(refreshError);
      }
    }
    
    // Log errors for debugging
    console.error(`API Error [${error.response?.status}]:`, error.response?.data || error.message);
    return Promise.reject(error);
  }
);

// Helper functions for common HTTP methods
export const api = {
  get: <T = any>(url: string, config?: AxiosRequestConfig): Promise<T> =>
    apiClient.get(url, config).then((res: AxiosResponse) => res.data),
  
  post: <T = any>(url: string, data?: any, config?: AxiosRequestConfig): Promise<T> =>
    apiClient.post(url, data, config).then((res: AxiosResponse) => res.data),
  
  put: <T = any>(url: string, data?: any, config?: AxiosRequestConfig): Promise<T> =>
    apiClient.put(url, data, config).then((res: AxiosResponse) => res.data),
  
  patch: <T = any>(url: string, data?: any, config?: AxiosRequestConfig): Promise<T> =>
    apiClient.patch(url, data, config).then((res: AxiosResponse) => res.data),
  
  delete: <T = any>(url: string, config?: AxiosRequestConfig): Promise<T> =>
    apiClient.delete(url, config).then((res: AxiosResponse) => res.data),
};
```

### Step 2: REST API Store with CRUD Operations

Now build a store that uses the API client:

```typescript
// src/store/restStore.ts
import { create } from 'zustand';
import { api } from '../services/apiClient';
import { devtools } from 'zustand/middleware';

interface Post {
  id: number;
  title: string;
  body: string;
  userId: number;
}

interface RestStore {
  // State
  posts: Record<number, Post>;
  postIds: number[];
  loading: boolean;
  error: string | null;
  selectedPostId: number | null;
  
  // CRUD actions
  fetchPosts: () => Promise<void>;
  fetchPost: (id: number) => Promise<void>;
  createPost: (post: Omit<Post, 'id'>) => Promise<Post>;
  updatePost: (id: number, updates: Partial<Post>) => Promise<void>;
  deletePost: (id: number) => Promise<void>;
  
  // Selection
  selectPost: (id: number | null) => void;
  
  // Reset
  clear: () => void;
}

export const useRestStore = create<RestStore>()(
  devtools(
    (set, get) => ({
      // Initial state
      posts: {},
      postIds: [],
      loading: false,
      error: null,
      selectedPostId: null,

      // --- Fetch all posts ---
      fetchPosts: async () => {
        set({ loading: true, error: null });
        try {
          const posts: Post[] = await api.get('/posts');
          const postsMap: Record<number, Post> = {};
          const ids: number[] = [];
          for (const post of posts) {
            postsMap[post.id] = post;
            ids.push(post.id);
          }
          set({ posts: postsMap, postIds: ids, loading: false });
        } catch (error) {
          set({
            loading: false,
            error: error instanceof Error ? error.message : 'Failed to fetch posts',
          });
        }
      },

      // --- Fetch single post ---
      fetchPost: async (id: number) => {
        // If we already have it, skip
        if (get().posts[id]) return;
        
        set({ loading: true, error: null });
        try {
          const post: Post = await api.get(`/posts/${id}`);
          set((state) => ({
            posts: { ...state.posts, [id]: post },
            postIds: state.postIds.includes(id) ? state.postIds : [...state.postIds, id],
            loading: false,
          }));
        } catch (error) {
          set({
            loading: false,
            error: error instanceof Error ? error.message : `Failed to fetch post ${id}`,
          });
        }
      },

      // --- Create post ---
      createPost: async (post: Omit<Post, 'id'>) => {
        set({ loading: true, error: null });
        try {
          const newPost: Post = await api.post('/posts', post);
          set((state) => ({
            posts: { ...state.posts, [newPost.id]: newPost },
            postIds: [...state.postIds, newPost.id],
            loading: false,
          }));
          return newPost;
        } catch (error) {
          set({
            loading: false,
            error: error instanceof Error ? error.message : 'Failed to create post',
          });
          throw error;
        }
      },

      // --- Update post ---
      updatePost: async (id: number, updates: Partial<Post>) => {
        // Optimistic update
        const previousPost = get().posts[id];
        set((state) => ({
          posts: {
            ...state.posts,
            [id]: { ...state.posts[id], ...updates },
          },
        }));

        try {
          const updated: Post = await api.patch(`/posts/${id}`, updates);
          set((state) => ({
            posts: { ...state.posts, [id]: updated },
          }));
        } catch (error) {
          // Rollback on failure
          if (previousPost) {
            set((state) => ({
              posts: { ...state.posts, [id]: previousPost },
              error: error instanceof Error ? error.message : 'Failed to update post',
            }));
          }
          throw error;
        }
      },

      // --- Delete post ---
      deletePost: async (id: number) => {
        // Optimistic delete
        const previousPosts = get().posts;
        const previousIds = get().postIds;
        set((state) => {
          const { [id]: removed, ...remaining } = state.posts;
          return {
            posts: remaining,
            postIds: state.postIds.filter(pid => pid !== id),
          };
        });

        try {
          await api.delete(`/posts/${id}`);
        } catch (error) {
          // Rollback
          set({
            posts: previousPosts,
            postIds: previousIds,
            error: error instanceof Error ? error.message : 'Failed to delete post',
          });
          throw error;
        }
      },

      // --- Selection ---
      selectPost: (id) => set({ selectedPostId: id }),

      // --- Clear ---
      clear: () => set({ posts: {}, postIds: [], loading: false, error: null }),
    }),
    { name: 'REST Store' }
  )
);
```

### Step 3: GraphQL Integration

For GraphQL, we'll create a lightweight client using `fetch` (you can also use Apollo Client):

```typescript
// src/services/graphqlClient.ts
const GRAPHQL_URL = process.env.REACT_APP_GRAPHQL_URL || 'https://api.example.com/graphql';

export async function graphqlRequest<T = any>(
  query: string,
  variables?: Record<string, any>,
  token?: string
): Promise<T> {
  const headers: Record<string, string> = {
    'Content-Type': 'application/json',
  };
  if (token) {
    headers.Authorization = `Bearer ${token}`;
  }

  const response = await fetch(GRAPHQL_URL, {
    method: 'POST',
    headers,
    body: JSON.stringify({ query, variables }),
  });

  if (!response.ok) {
    const errorText = await response.text();
    throw new Error(`GraphQL HTTP error ${response.status}: ${errorText}`);
  }

  const result = await response.json();
  if (result.errors) {
    throw new Error(result.errors.map((e: any) => e.message).join(', '));
  }
  return result.data;
}
```

Now a GraphQL store:

```typescript
// src/store/graphqlStore.ts
import { create } from 'zustand';
import { graphqlRequest } from '../services/graphqlClient';
import { devtools } from 'zustand/middleware';

// GraphQL queries
const GET_USERS = `
  query GetUsers {
    users {
      id
      name
      email
    }
  }
`;

const GET_USER = `
  query GetUser($id: ID!) {
    user(id: $id) {
      id
      name
      email
      posts {
        id
        title
      }
    }
  }
`;

const CREATE_POST = `
  mutation CreatePost($input: PostInput!) {
    createPost(input: $input) {
      id
      title
      body
    }
  }
`;

interface User {
  id: string;
  name: string;
  email: string;
  posts?: Post[];
}

interface GraphqlStore {
  users: Record<string, User>;
  userIds: string[];
  loading: boolean;
  error: string | null;
  
  fetchUsers: () => Promise<void>;
  fetchUser: (id: string) => Promise<void>;
  createPost: (title: string, body: string, userId: string) => Promise<void>;
  clear: () => void;
}

export const useGraphqlStore = create<GraphqlStore>()(
  devtools(
    (set, get) => ({
      users: {},
      userIds: [],
      loading: false,
      error: null,

      fetchUsers: async () => {
        set({ loading: true, error: null });
        try {
          const data = await graphqlRequest<{ users: User[] }>(GET_USERS);
          const usersMap: Record<string, User> = {};
          const ids: string[] = [];
          for (const user of data.users) {
            usersMap[user.id] = user;
            ids.push(user.id);
          }
          set({ users: usersMap, userIds: ids, loading: false });
        } catch (error) {
          set({
            loading: false,
            error: error instanceof Error ? error.message : 'Failed to fetch users',
          });
        }
      },

      fetchUser: async (id: string) => {
        if (get().users[id]) return;
        set({ loading: true, error: null });
        try {
          const data = await graphqlRequest<{ user: User }>(GET_USER, { id });
          const user = data.user;
          set((state) => ({
            users: { ...state.users, [id]: user },
            userIds: state.userIds.includes(id) ? state.userIds : [...state.userIds, id],
            loading: false,
          }));
        } catch (error) {
          set({
            loading: false,
            error: error instanceof Error ? error.message : `Failed to fetch user ${id}`,
          });
        }
      },

      createPost: async (title: string, body: string, userId: string) => {
        set({ loading: true, error: null });
        try {
          const input = { title, body, userId };
          const data = await graphqlRequest<{ createPost: Post }>(CREATE_POST, { input });
          // Optionally update local cache
          const newPost = data.createPost;
          // Could add to user's posts if we wanted
          set({ loading: false });
        } catch (error) {
          set({
            loading: false,
            error: error instanceof Error ? error.message : 'Failed to create post',
          });
          throw error;
        }
      },

      clear: () => set({ users: {}, userIds: [], loading: false, error: null }),
    }),
    { name: 'GraphQL Store' }
  )
);
```

### Step 4: WebSocket Integration

Real‑time data via WebSockets (using native WebSocket or Socket.io):

```typescript
// src/services/websocketService.ts
type MessageHandler = (data: any) => void;

class WebSocketService {
  private ws: WebSocket | null = null;
  private reconnectAttempts = 0;
  private maxReconnectAttempts = 5;
  private reconnectDelay = 2000;
  private handlers: Map<string, Set<MessageHandler>> = new Map();
  private pingInterval: NodeJS.Timeout | null = null;

  constructor(private url: string) {}

  connect(): void {
    if (this.ws && this.ws.readyState === WebSocket.OPEN) return;
    
    this.ws = new WebSocket(this.url);
    
    this.ws.onopen = () => {
      console.log('🔌 WebSocket connected');
      this.reconnectAttempts = 0;
      this.startPing();
    };

    this.ws.onmessage = (event) => {
      try {
        const message = JSON.parse(event.data);
        const { type, payload } = message;
        this.notifyHandlers(type, payload);
      } catch (error) {
        console.error('Invalid WebSocket message:', event.data);
      }
    };

    this.ws.onclose = (event) => {
      console.log(`🔌 WebSocket closed: ${event.code} - ${event.reason}`);
      this.stopPing();
      this.attemptReconnect();
    };

    this.ws.onerror = (error) => {
      console.error('WebSocket error:', error);
    };
  }

  private startPing(): void {
    this.pingInterval = setInterval(() => {
      if (this.ws && this.ws.readyState === WebSocket.OPEN) {
        this.ws.send(JSON.stringify({ type: 'ping' }));
      }
    }, 30000); // 30 seconds
  }

  private stopPing(): void {
    if (this.pingInterval) {
      clearInterval(this.pingInterval);
      this.pingInterval = null;
    }
  }

  private attemptReconnect(): void {
    if (this.reconnectAttempts >= this.maxReconnectAttempts) {
      console.log('Max reconnect attempts reached');
      return;
    }
    this.reconnectAttempts++;
    const delay = this.reconnectDelay * Math.pow(2, this.reconnectAttempts - 1);
    console.log(`Reconnecting in ${delay}ms (attempt ${this.reconnectAttempts})`);
    setTimeout(() => this.connect(), delay);
  }

  // Subscribe to message types
  subscribe(type: string, handler: MessageHandler): () => void {
    if (!this.handlers.has(type)) {
      this.handlers.set(type, new Set());
    }
    this.handlers.get(type)!.add(handler);
    return () => {
      const set = this.handlers.get(type);
      if (set) {
        set.delete(handler);
        if (set.size === 0) {
          this.handlers.delete(type);
        }
      }
    };
  }

  // Send a message
  send(type: string, payload: any): void {
    if (this.ws && this.ws.readyState === WebSocket.OPEN) {
      this.ws.send(JSON.stringify({ type, payload }));
    } else {
      console.warn('WebSocket not connected, cannot send message');
    }
  }

  private notifyHandlers(type: string, payload: any): void {
    const handlers = this.handlers.get(type);
    if (handlers) {
      for (const handler of handlers) {
        try {
          handler(payload);
        } catch (error) {
          console.error(`Error in WebSocket handler for ${type}:`, error);
        }
      }
    }
  }

  disconnect(): void {
    if (this.ws) {
      this.ws.close();
      this.ws = null;
    }
    this.stopPing();
  }
}

// Create singleton instance
export const wsService = new WebSocketService(
  process.env.REACT_APP_WS_URL || 'wss://api.example.com/ws'
);
```

Now a store that listens to WebSocket messages:

```typescript
// src/store/websocketStore.ts
import { create } from 'zustand';
import { wsService } from '../services/websocketService';
import { devtools } from 'zustand/middleware';

interface Notification {
  id: string;
  message: string;
  read: boolean;
  timestamp: Date;
}

interface WebSocketStore {
  notifications: Notification[];
  online: boolean;
  unreadCount: number;
  
  connect: () => void;
  disconnect: () => void;
  markAsRead: (id: string) => void;
  clear: () => void;
}

export const useWebSocketStore = create<WebSocketStore>()(
  devtools(
    (set, get) => ({
      notifications: [],
      online: false,
      unreadCount: 0,

      connect: () => {
        wsService.connect();
        // Subscribe to incoming notifications
        const unsubscribe = wsService.subscribe('notification', (payload) => {
          const notification: Notification = {
            id: payload.id || `notif-${Date.now()}`,
            message: payload.message,
            read: false,
            timestamp: new Date(payload.timestamp || Date.now()),
          };
          set((state) => ({
            notifications: [notification, ...state.notifications],
            unreadCount: state.unreadCount + 1,
          }));
        });

        // Subscribe to connection status
        const unsubStatus = wsService.subscribe('connection_status', (payload) => {
          set({ online: payload.online });
        });

        // Store unsubscribe functions for cleanup
        (get() as any)._unsubscribe = unsubscribe;
        (get() as any)._unsubStatus = unsubStatus;
      },

      disconnect: () => {
        wsService.disconnect();
        if ((get() as any)._unsubscribe) {
          (get() as any)._unsubscribe();
        }
        if ((get() as any)._unsubStatus) {
          (get() as any)._unsubStatus();
        }
        set({ online: false });
      },

      markAsRead: (id: string) => {
        set((state) => {
          const notifications = state.notifications.map(n =>
            n.id === id ? { ...n, read: true } : n
          );
          return {
            notifications,
            unreadCount: notifications.filter(n => !n.read).length,
          };
        });
        // Optionally send acknowledgment to server
        wsService.send('mark_read', { id });
      },

      clear: () => set({ notifications: [], unreadCount: 0 }),
    }),
    { name: 'WebSocket Store' }
  )
);
```

### Step 5: Server-Sent Events (SSE)

SSE is a simpler real‑time alternative to WebSockets (one-way, server to client):

```typescript
// src/services/sseService.ts
type SSEHandler = (data: any) => void;

class SSEService {
  private eventSource: EventSource | null = null;
  private handlers: Map<string, Set<SSEHandler>> = new Map();
  private url: string;

  constructor(url: string) {
    this.url = url;
  }

  connect(): void {
    if (this.eventSource) return;
    
    this.eventSource = new EventSource(this.url);
    
    this.eventSource.onopen = () => {
      console.log('📡 SSE connection opened');
    };

    this.eventSource.onerror = (error) => {
      console.error('SSE error:', error);
      this.eventSource?.close();
      this.eventSource = null;
      // Optionally reconnect after delay
      setTimeout(() => this.connect(), 5000);
    };

    this.eventSource.onmessage = (event) => {
      // Handle generic messages
      try {
        const data = JSON.parse(event.data);
        this.notifyHandlers('message', data);
      } catch (e) {
        console.error('Invalid SSE message:', event.data);
      }
    };
  }

  // Listen for specific event types (e.g., "task_update")
  on(eventType: string, handler: SSEHandler): () => void {
    if (!this.handlers.has(eventType)) {
      this.handlers.set(eventType, new Set());
    }
    this.handlers.get(eventType)!.add(handler);

    // If we have an EventSource, attach listener
    if (this.eventSource) {
      this.eventSource.addEventListener(eventType, (event: MessageEvent) => {
        try {
          const data = JSON.parse(event.data);
          handler(data);
        } catch (e) {
          console.error(`Error parsing SSE ${eventType}:`, event.data);
        }
      });
    }

    return () => {
      const set = this.handlers.get(eventType);
      if (set) {
        set.delete(handler);
        if (set.size === 0) {
          this.handlers.delete(eventType);
        }
      }
    };
  }

  private notifyHandlers(eventType: string, data: any): void {
    const handlers = this.handlers.get(eventType);
    if (handlers) {
      for (const handler of handlers) {
        try {
          handler(data);
        } catch (error) {
          console.error(`Error in SSE handler for ${eventType}:`, error);
        }
      }
    }
  }

  disconnect(): void {
    if (this.eventSource) {
      this.eventSource.close();
      this.eventSource = null;
    }
  }
}

export const sseService = new SSEService(
  process.env.REACT_APP_SSE_URL || 'https://api.example.com/events'
);
```

SSE store:

```typescript
// src/store/sseStore.ts
import { create } from 'zustand';
import { sseService } from '../services/sseService';
import { devtools } from 'zustand/middleware';

interface SSEStore {
  taskUpdates: any[];
  liveUsers: number;
  
  connect: () => void;
  disconnect: () => void;
  clear: () => void;
}

export const useSSEStore = create<SSEStore>()(
  devtools(
    (set, get) => ({
      taskUpdates: [],
      liveUsers: 0,

      connect: () => {
        sseService.connect();
        
        // Listen for task update events
        const unsubTask = sseService.on('task_update', (data) => {
          set((state) => ({
            taskUpdates: [...state.taskUpdates, data],
          }));
        });

        // Listen for user presence updates
        const unsubUsers = sseService.on('user_presence', (data) => {
          set({ liveUsers: data.count });
        });

        (get() as any)._unsubTask = unsubTask;
        (get() as any)._unsubUsers = unsubUsers;
      },

      disconnect: () => {
        sseService.disconnect();
        if ((get() as any)._unsubTask) {
          (get() as any)._unsubTask();
        }
        if ((get() as any)._unsubUsers) {
          (get() as any)._unsubUsers();
        }
      },

      clear: () => set({ taskUpdates: [], liveUsers: 0 }),
    }),
    { name: 'SSE Store' }
  )
);
```

### Step 6: Polling for Periodic Updates

When real‑time isn't required, polling is simple and effective:

```typescript
// src/store/pollingStore.ts
import { create } from 'zustand';
import { api } from '../services/apiClient';
import { devtools } from 'zustand/middleware';

interface PollingStore {
  data: any[];
  loading: boolean;
  error: string | null;
  lastUpdated: Date | null;
  pollInterval: number | null;
  intervalId: NodeJS.Timeout | null;
  
  startPolling: (intervalMs: number) => void;
  stopPolling: () => void;
  fetchData: () => Promise<void>;
  clear: () => void;
}

export const usePollingStore = create<PollingStore>()(
  devtools(
    (set, get) => ({
      data: [],
      loading: false,
      error: null,
      lastUpdated: null,
      pollInterval: null,
      intervalId: null,

      fetchData: async () => {
        set({ loading: true, error: null });
        try {
          const data = await api.get('/status');
          set({
            data,
            loading: false,
            error: null,
            lastUpdated: new Date(),
          });
        } catch (error) {
          set({
            loading: false,
            error: error instanceof Error ? error.message : 'Polling failed',
          });
        }
      },

      startPolling: (intervalMs: number) => {
        // Stop any existing polling
        get().stopPolling();
        
        // Fetch immediately
        get().fetchData();
        
        // Set up interval
        const id = setInterval(() => {
          get().fetchData();
        }, intervalMs);
        
        set({ pollInterval: intervalMs, intervalId: id });
      },

      stopPolling: () => {
        const id = get().intervalId;
        if (id) {
          clearInterval(id);
          set({ intervalId: null, pollInterval: null });
        }
      },

      clear: () => {
        get().stopPolling();
        set({ data: [], loading: false, error: null, lastUpdated: null });
      },
    }),
    { name: 'Polling Store' }
  )
);

// In a component:
// useEffect(() => {
//   usePollingStore.getState().startPolling(30000); // poll every 30s
//   return () => usePollingStore.getState().stopPolling();
// }, []);
```

### Step 7: Background Synchronization (Offline Support)

For offline-first applications, queue mutations and sync when online:

```typescript
// src/services/offlineQueue.ts
import { useNetworkStore } from '../store/networkStore';

interface QueuedAction {
  id: string;
  type: 'create' | 'update' | 'delete';
  endpoint: string;
  payload: any;
  timestamp: number;
  retryCount: number;
}

class OfflineQueue {
  private queue: QueuedAction[] = [];
  private isProcessing = false;
  private maxRetries = 3;

  constructor() {
    // Load persisted queue from localStorage
    const saved = localStorage.getItem('offlineQueue');
    if (saved) {
      try {
        this.queue = JSON.parse(saved);
      } catch (e) {
        this.queue = [];
      }
    }

    // Listen for online events
    window.addEventListener('online', () => {
      this.processQueue();
    });
  }

  private persist(): void {
    localStorage.setItem('offlineQueue', JSON.stringify(this.queue));
  }

  addAction(action: Omit<QueuedAction, 'id' | 'timestamp' | 'retryCount'>): void {
    const queuedAction: QueuedAction = {
      ...action,
      id: `q-${Date.now()}-${Math.random().toString(36).slice(2, 7)}`,
      timestamp: Date.now(),
      retryCount: 0,
    };
    this.queue.push(queuedAction);
    this.persist();

    // If online, process immediately
    if (navigator.onLine) {
      this.processQueue();
    }
  }

  async processQueue(): Promise<void> {
    if (this.isProcessing || this.queue.length === 0 || !navigator.onLine) {
      return;
    }

    this.isProcessing = true;

    // Process in order (FIFO)
    while (this.queue.length > 0) {
      const action = this.queue[0];
      try {
        await this.executeAction(action);
        // Remove from queue on success
        this.queue.shift();
        this.persist();
      } catch (error) {
        // Retry logic
        if (action.retryCount < this.maxRetries) {
          action.retryCount++;
          // Move to end of queue for later retry
          this.queue.shift();
          this.queue.push(action);
          this.persist();
          // Wait before next retry
          await new Promise(resolve => setTimeout(resolve, 5000));
        } else {
          // Failed after max retries - move to failed queue or log
          console.error('Offline action failed permanently:', action);
          this.queue.shift();
          this.persist();
        }
      }
    }

    this.isProcessing = false;
  }

  private async executeAction(action: QueuedAction): Promise<void> {
    const { type, endpoint, payload } = action;
    const url = `${process.env.REACT_APP_API_URL}${endpoint}`;
    
    // Use fetch directly (or axios) with authentication
    const token = localStorage.getItem('authToken');
    const options: RequestInit = {
      method: type === 'create' ? 'POST' : type === 'update' ? 'PUT' : 'DELETE',
      headers: {
        'Content-Type': 'application/json',
        ...(token ? { Authorization: `Bearer ${token}` } : {}),
      },
      ...(payload ? { body: JSON.stringify(payload) } : {}),
    };

    const response = await fetch(url, options);
    if (!response.ok) {
      throw new Error(`HTTP ${response.status}`);
    }
    // Success - optionally handle response
  }

  clear(): void {
    this.queue = [];
    this.persist();
  }
}

export const offlineQueue = new OfflineQueue();
```

Now a store that uses offline queue:

```typescript
// src/store/offlineStore.ts
import { create } from 'zustand';
import { offlineQueue } from '../services/offlineQueue';
import { api } from '../services/apiClient';
import { devtools } from 'zustand/middleware';

interface OfflineStore {
  items: any[];
  loading: boolean;
  error: string | null;
  
  createItem: (data: any) => Promise<void>;
  updateItem: (id: string, data: any) => Promise<void>;
  deleteItem: (id: string) => Promise<void>;
  syncNow: () => Promise<void>;
  clear: () => void;
}

export const useOfflineStore = create<OfflineStore>()(
  devtools(
    (set, get) => ({
      items: [],
      loading: false,
      error: null,

      createItem: async (data: any) => {
        // Optimistically add to local state
        const tempId = `temp-${Date.now()}`;
        const newItem = { ...data, id: tempId, pending: true };
        set((state) => ({ items: [...state.items, newItem] }));

        // If offline, queue the action
        if (!navigator.onLine) {
          offlineQueue.addAction({
            type: 'create',
            endpoint: '/items',
            payload: data,
          });
          return;
        }

        // If online, attempt immediately
        try {
          const result = await api.post('/items', data);
          // Replace temp with real item
          set((state) => ({
            items: state.items.map(item =>
              item.id === tempId ? { ...result, pending: false } : item
            ),
          }));
        } catch (error) {
          // Rollback optimistic item
          set((state) => ({
            items: state.items.filter(item => item.id !== tempId),
            error: error instanceof Error ? error.message : 'Create failed',
          }));
          // Queue for retry
          offlineQueue.addAction({
            type: 'create',
            endpoint: '/items',
            payload: data,
          });
        }
      },

      // Similar for update, delete...

      syncNow: async () => {
        await offlineQueue.processQueue();
      },

      clear: () => set({ items: [], loading: false, error: null }),
    }),
    { name: 'Offline Store' }
  )
);
```

---

## The Verification: Testing API Integrations

### Step 1: Test REST API with Mock Server

Use `json-server` or `msw` (Mock Service Worker) for testing:

```bash
npm install -g json-server
json-server --watch db.json --port 3001
```

Then in your component:

```tsx
// src/components/RestTest.tsx
import React, { useEffect } from 'react';
import { useRestStore } from '../store/restStore';

function RestTest() {
  const { posts, postIds, loading, error, fetchPosts, createPost, deletePost } = useRestStore();

  useEffect(() => {
    fetchPosts();
  }, []);

  if (loading) return <div>Loading...</div>;
  if (error) return <div>Error: {error}</div>;

  return (
    <div>
      <button onClick={() => createPost({ title: 'New Post', body: 'Body', userId: 1 })}>
        Create Post
      </button>
      <ul>
        {postIds.map(id => (
          <li key={id}>
            {posts[id].title}
            <button onClick={() => deletePost(id)}>Delete</button>
          </li>
        ))}
      </ul>
    </div>
  );
}
```

### Step 2: Test GraphQL with Apollo Sandbox

Use a public GraphQL endpoint like `https://countries.trevorblades.com/graphql` for testing:

```typescript
// Example test
async function testGraphQL() {
  const query = `
    query {
      countries {
        name
        code
      }
    }
  `;
  const data = await graphqlRequest(query);
  console.log(data);
}
```

### Step 3: Test WebSocket with a Local Server

Use a simple WebSocket server (Node.js with `ws` library):

```bash
npm install ws
```

```javascript
// server.js
const WebSocket = require('ws');
const wss = new WebSocket.Server({ port: 8080 });

wss.on('connection', (ws) => {
  ws.send(JSON.stringify({ type: 'connection_status', payload: { online: true } }));
  setInterval(() => {
    ws.send(JSON.stringify({ type: 'notification', payload: { message: 'New update!' } }));
  }, 5000);
});
```

Then run `node server.js` and connect your store.

### Step 4: Test Offline Mode

1. Open your app
2. Go to DevTools → Network → Offline
3. Perform a mutation (create/update/delete)
4. Observe that the action is queued
5. Turn network back online
6. Queue should process automatically

---

## Deep Dive: Caching Strategies

### In-Memory Cache with TTL

```typescript
// src/services/cache.ts
class Cache {
  private store = new Map<string, { data: any; expires: number }>();

  set(key: string, data: any, ttlMs: number = 60000): void {
    this.store.set(key, { data, expires: Date.now() + ttlMs });
  }

  get(key: string): any | null {
    const entry = this.store.get(key);
    if (!entry) return null;
    if (entry.expires < Date.now()) {
      this.store.delete(key);
      return null;
    }
    return entry.data;
  }

  clear(): void {
    this.store.clear();
  }
}

export const cache = new Cache();

// In your store:
fetchPosts: async () => {
  const cached = cache.get('posts');
  if (cached) {
    set({ posts: cached, loading: false });
    return;
  }
  // ... fetch and then cache.set('posts', posts, 60000);
}
```

### Request Deduplication with Cache

Combine with the deduplication pattern from Section 13 to avoid redundant requests.

---

## Common Pitfalls and Solutions

### Pitfall 1: Not Handling Authentication Expiry

```typescript
// ❌ BAD: Token expires, all requests fail
fetchData: async () => {
  const token = get().token;
  const response = await fetch(url, { headers: { Authorization: token } });
  // ...
}

// ✅ GOOD: Use interceptor to refresh token automatically (as in apiClient)
```

### Pitfall 2: Mixing API Logic with UI Logic

```typescript
// ❌ BAD: API calls in components
const handleSubmit = async () => {
  const response = await fetch('/api/posts', { ... });
  // ...
}

// ✅ GOOD: API calls in stores/services
const createPost = useStore((state) => state.createPost);
const handleSubmit = () => createPost(data);
```

### Pitfall 3: Not Handling Slow Networks Gracefully

```typescript
// ❌ BAD: No timeout
const response = await fetch(url);

// ✅ GOOD: Timeout and retry
const controller = new AbortController();
const timeout = setTimeout(() => controller.abort(), 30000);
try {
  const response = await fetch(url, { signal: controller.signal });
} finally {
  clearTimeout(timeout);
}
```

### Pitfall 4: Forgetting to Clean Up WebSocket/SSE

```typescript
// In component
useEffect(() => {
  useWebSocketStore.getState().connect();
  return () => useWebSocketStore.getState().disconnect();
}, []);
```

---

## Key Takeaways

1. **REST**: Use a robust HTTP client (Axios) with interceptors for auth, retries, errors
2. **GraphQL**: Use a lightweight client or Apollo; handle errors and normalize responses
3. **WebSockets**: Manage connection lifecycle, reconnect logic, and message routing
4. **SSE**: Simpler than WebSockets for one‑way server push; reconnect on failure
5. **Polling**: Simple fallback for real‑time when SSE/WebSockets aren't available
6. **Offline Support**: Queue mutations and sync when online; use optimistic updates
7. **Caching**: In‑memory cache with TTL to reduce redundant network calls
8. **Error Handling**: Graceful fallbacks, user feedback, and retry mechanisms
9. **Cleanup**: Always disconnect WebSockets, stop polling, and clear intervals
10. **Testing**: Use mock servers, public APIs, and offline simulation

---

## What's Next

You've mastered external API integration. Next, you'll learn how to build custom middleware to extend Zustand for logging, validation, analytics, and more.
