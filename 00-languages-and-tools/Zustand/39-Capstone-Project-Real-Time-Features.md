# Capstone Project — Phase 5: Real-Time Features

Real-time features are what make modern applications feel alive and collaborative. In this phase, you'll add WebSocket integration for live updates, build a notification system, implement user presence tracking, and create a real-time activity feed. These features will transform TaskFlow from a static task manager into a dynamic collaboration platform.

---

## The Target: Real-Time Collaboration

By the end of this phase, you'll have:
- WebSocket integration with automatic reconnection
- Real-time notifications (in-app and toast)
- User presence tracking (online/offline status)
- Typing indicators for task comments
- Live activity feed
- Collaborative task updates
- Offline message queuing

---

## Implementation: Real-Time Features

### Step 1: Real-Time Store

```typescript
// packages/shared/src/store/realtime/realtimeStore.ts
import { create } from 'zustand';
import { immer } from 'zustand/middleware/immer';
import { eventBus } from '../../events';

export interface Presence {
  userId: string;
  userName: string;
  status: 'online' | 'away' | 'busy' | 'offline';
  lastSeen: Date;
  currentTask?: string;
  typing?: boolean;
  typingTaskId?: string;
}

export interface Activity {
  id: string;
  userId: string;
  userName: string;
  userAvatar?: string;
  action: 'created' | 'updated' | 'completed' | 'deleted' | 'commented';
  target: string; // Task ID or description
  targetType: 'task' | 'comment' | 'user';
  timestamp: Date;
  metadata?: Record<string, any>;
}

export interface RealTimeState {
  // Presence
  presence: Record<string, Presence>;
  onlineUsers: string[];
  
  // Activities
  activities: Activity[];
  maxActivities: number;
  
  // Connection
  isConnected: boolean;
  isReconnecting: boolean;
  reconnectAttempts: number;
  lastHeartbeat: Date | null;
  
  // Typing
  typingUsers: Record<string, { userId: string; userName: string; taskId: string; timestamp: Date }>;
}

interface RealTimeStore extends RealTimeState {
  // Presence actions
  updatePresence: (presence: Presence) => void;
  setUserStatus: (userId: string, status: Presence['status']) => void;
  setUserTask: (userId: string, taskId: string | undefined) => void;
  
  // Typing actions
  setUserTyping: (userId: string, userName: string, taskId: string, isTyping: boolean) => void;
  clearTyping: (userId?: string) => void;
  
  // Activity actions
  addActivity: (activity: Omit<Activity, 'id' | 'timestamp'>) => void;
  clearActivities: () => void;
  
  // Connection actions
  setConnected: (connected: boolean) => void;
  setReconnecting: (reconnecting: boolean) => void;
  incrementReconnectAttempts: () => void;
  resetReconnectAttempts: () => void;
  updateHeartbeat: () => void;
  
  // WebSocket handlers
  handleMessage: (data: any) => void;
  handlePresenceUpdate: (data: any) => void;
  handleActivity: (data: any) => void;
  handleTyping: (data: any) => void;
  
  // Utilities
  getUserStatus: (userId: string) => Presence['status'] | undefined;
  isUserOnline: (userId: string) => boolean;
  clearAll: () => void;
}

const initialState: RealTimeState = {
  presence: {},
  onlineUsers: [],
  activities: [],
  maxActivities: 100,
  isConnected: false,
  isReconnecting: false,
  reconnectAttempts: 0,
  lastHeartbeat: null,
  typingUsers: {},
};

export const useRealTimeStore = create<RealTimeStore>()(
  immer((set, get) => ({
    ...initialState,

    // --- Presence ---
    updatePresence: (presence: Presence) => {
      set((state) => {
        const existing = state.presence[presence.userId];
        state.presence[presence.userId] = presence;
        
        // Update online users list
        if (presence.status === 'online') {
          if (!state.onlineUsers.includes(presence.userId)) {
            state.onlineUsers.push(presence.userId);
          }
        } else {
          state.onlineUsers = state.onlineUsers.filter(id => id !== presence.userId);
        }
        
        // Remove typing indicator if user went offline
        if (presence.status === 'offline' && state.typingUsers[presence.userId]) {
          delete state.typingUsers[presence.userId];
        }
      });
    },

    setUserStatus: (userId: string, status: Presence['status']) => {
      set((state) => {
        if (state.presence[userId]) {
          state.presence[userId].status = status;
          state.presence[userId].lastSeen = new Date();
        }
      });
    },

    setUserTask: (userId: string, taskId: string | undefined) => {
      set((state) => {
        if (state.presence[userId]) {
          state.presence[userId].currentTask = taskId;
        }
      });
    },

    // --- Typing ---
    setUserTyping: (userId: string, userName: string, taskId: string, isTyping: boolean) => {
      set((state) => {
        if (isTyping) {
          state.typingUsers[userId] = { userId, userName, taskId, timestamp: new Date() };
        } else {
          delete state.typingUsers[userId];
        }
      });
    },

    clearTyping: (userId?: string) => {
      set((state) => {
        if (userId) {
          delete state.typingUsers[userId];
        } else {
          state.typingUsers = {};
        }
      });
    },

    // --- Activities ---
    addActivity: (activity) => {
      set((state) => {
        const newActivity: Activity = {
          ...activity,
          id: `act-${Date.now()}`,
          timestamp: new Date(),
        };
        state.activities = [newActivity, ...state.activities];
        if (state.activities.length > state.maxActivities) {
          state.activities = state.activities.slice(0, state.maxActivities);
        }
      });
    },

    clearActivities: () => {
      set({ activities: [] });
    },

    // --- Connection ---
    setConnected: (connected) => {
      set({ isConnected: connected });
    },

    setReconnecting: (reconnecting) => {
      set({ isReconnecting: reconnecting });
    },

    incrementReconnectAttempts: () => {
      set((state) => ({ reconnectAttempts: state.reconnectAttempts + 1 }));
    },

    resetReconnectAttempts: () => {
      set({ reconnectAttempts: 0 });
    },

    updateHeartbeat: () => {
      set({ lastHeartbeat: new Date() });
    },

    // --- WebSocket Handlers ---
    handleMessage: (data: any) => {
      switch (data.type) {
        case 'presence':
          get().handlePresenceUpdate(data.payload);
          break;
        case 'activity':
          get().handleActivity(data.payload);
          break;
        case 'typing':
          get().handleTyping(data.payload);
          break;
        case 'heartbeat':
          get().updateHeartbeat();
          break;
        case 'task:created':
        case 'task:updated':
        case 'task:completed':
        case 'task:deleted':
          eventBus.publish(data.type, data.payload);
          break;
        default:
          console.log('Unknown WebSocket message:', data.type);
      }
    },

    handlePresenceUpdate: (data: any) => {
      get().updatePresence(data);
    },

    handleActivity: (data: any) => {
      get().addActivity(data);
    },

    handleTyping: (data: any) => {
      get().setUserTyping(data.userId, data.userName, data.taskId, data.isTyping);
    },

    // --- Utilities ---
    getUserStatus: (userId: string) => {
      return get().presence[userId]?.status;
    },

    isUserOnline: (userId: string) => {
      return get().presence[userId]?.status === 'online';
    },

    clearAll: () => {
      set(initialState);
    },
  }))
);
```

### Step 2: WebSocket Service with Reconnection

```typescript
// packages/shared/src/services/websocket.ts
import { useRealTimeStore } from '../store/realtime/realtimeStore';
import { useAuthStore } from '../store/auth/authStore';
import { eventBus } from '../events';

interface WebSocketMessage {
  type: string;
  payload: any;
}

export class WebSocketService {
  private ws: WebSocket | null = null;
  private reconnectAttempts = 0;
  private maxReconnectAttempts = 10;
  private reconnectDelay = 1000;
  private pingInterval: NodeJS.Timeout | null = null;
  private messageQueue: WebSocketMessage[] = [];
  private isConnecting = false;
  private url: string;

  constructor(url: string) {
    this.url = url;
  }

  connect(): void {
    if (this.isConnecting || (this.ws && this.ws.readyState === WebSocket.OPEN)) {
      return;
    }

    this.isConnecting = true;
    const store = useRealTimeStore.getState();
    store.setReconnecting(this.reconnectAttempts > 0);

    try {
      // Get auth token
      const token = useAuthStore.getState().getAccessToken();
      const wsUrl = token ? `${this.url}?token=${token}` : this.url;

      this.ws = new WebSocket(wsUrl);
      this.ws.onopen = this.handleOpen.bind(this);
      this.ws.onmessage = this.handleMessage.bind(this);
      this.ws.onclose = this.handleClose.bind(this);
      this.ws.onerror = this.handleError.bind(this);
    } catch (error) {
      console.error('Failed to create WebSocket:', error);
      this.isConnecting = false;
      this.scheduleReconnect();
    }
  }

  private handleOpen(): void {
    console.log('🔌 WebSocket connected');
    const store = useRealTimeStore.getState();
    store.setConnected(true);
    store.setReconnecting(false);
    store.resetReconnectAttempts();
    this.reconnectAttempts = 0;
    this.isConnecting = false;

    // Send queued messages
    while (this.messageQueue.length > 0) {
      const message = this.messageQueue.shift();
      if (message) {
        this.send(message.type, message.payload);
      }
    }

    // Start ping interval
    this.startPing();

    // Send initial presence
    const authStore = useAuthStore.getState();
    const user = authStore.user;
    if (user) {
      this.send('presence', {
        userId: user.id,
        userName: user.name,
        status: 'online',
        lastSeen: new Date(),
      });
    }
  }

  private handleMessage(event: MessageEvent): void {
    try {
      const data = JSON.parse(event.data);
      const store = useRealTimeStore.getState();
      store.handleMessage(data);
    } catch (error) {
      console.error('Failed to parse WebSocket message:', error);
    }
  }

  private handleClose(event: CloseEvent): void {
    console.log(`🔌 WebSocket closed: ${event.code} - ${event.reason}`);
    const store = useRealTimeStore.getState();
    store.setConnected(false);
    store.setReconnecting(false);
    this.isConnecting = false;
    this.stopPing();
    this.scheduleReconnect();
  }

  private handleError(event: Event): void {
    console.error('WebSocket error:', event);
    // The browser will close the connection, triggering onclose
  }

  private scheduleReconnect(): void {
    if (this.reconnectAttempts >= this.maxReconnectAttempts) {
      console.log('Max reconnect attempts reached');
      const store = useRealTimeStore.getState();
      store.setReconnecting(false);
      return;
    }

    this.reconnectAttempts++;
    const delay = Math.min(this.reconnectDelay * Math.pow(2, this.reconnectAttempts - 1), 30000);
    console.log(`🔄 Reconnecting in ${delay}ms (attempt ${this.reconnectAttempts})`);

    setTimeout(() => {
      this.connect();
    }, delay);
  }

  private startPing(): void {
    this.pingInterval = setInterval(() => {
      if (this.ws && this.ws.readyState === WebSocket.OPEN) {
        this.send('ping', { timestamp: Date.now() });
        useRealTimeStore.getState().updateHeartbeat();
      }
    }, 30000); // 30 seconds
  }

  private stopPing(): void {
    if (this.pingInterval) {
      clearInterval(this.pingInterval);
      this.pingInterval = null;
    }
  }

  send(type: string, payload: any): void {
    const message: WebSocketMessage = { type, payload };

    if (!this.ws || this.ws.readyState !== WebSocket.OPEN) {
      // Queue message for later
      this.messageQueue.push(message);
      return;
    }

    this.ws.send(JSON.stringify(message));
  }

  disconnect(): void {
    this.stopPing();
    if (this.ws) {
      this.ws.close();
      this.ws = null;
    }
    const store = useRealTimeStore.getState();
    store.setConnected(false);
    this.isConnecting = false;
  }

  isConnected(): boolean {
    return this.ws?.readyState === WebSocket.OPEN;
  }
}

// Singleton instance
const WS_URL = process.env.NEXT_PUBLIC_WS_URL || 'wss://api.taskflow.com/ws';
export const wsService = new WebSocketService(WS_URL);
```

### Step 3: Notification Store

```typescript
// packages/shared/src/store/notification/notificationStore.ts
import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';
import { immer } from 'zustand/middleware/immer';
import { eventBus } from '../../events';

export interface Notification {
  id: string;
  type: 'info' | 'success' | 'warning' | 'error';
  title: string;
  message: string;
  read: boolean;
  timestamp: Date;
  link?: string;
  action?: { label: string; handler: () => void };
  metadata?: Record<string, any>;
}

interface NotificationStore {
  notifications: Notification[];
  unreadCount: number;
  maxNotifications: number;
  
  // Actions
  addNotification: (notification: Omit<Notification, 'id' | 'timestamp' | 'read'>) => void;
  markAsRead: (id: string) => void;
  markAllAsRead: () => void;
  removeNotification: (id: string) => void;
  clearAll: () => void;
  
  // Utilities
  getUnreadCount: () => number;
  getLatest: (limit?: number) => Notification[];
}

export const useNotificationStore = create<NotificationStore>()(
  persist(
    immer((set, get) => ({
      notifications: [],
      unreadCount: 0,
      maxNotifications: 100,

      addNotification: (notification) => {
        set((state) => {
          const id = `notif-${Date.now()}`;
          const newNotif: Notification = {
            ...notification,
            id,
            read: false,
            timestamp: new Date(),
          };
          state.notifications = [newNotif, ...state.notifications];
          state.unreadCount += 1;
          
          if (state.notifications.length > state.maxNotifications) {
            state.notifications = state.notifications.slice(0, state.maxNotifications);
          }
        });

        // Emit event for real-time
        eventBus.publish('notification:new', { notification });
      },

      markAsRead: (id: string) => {
        set((state) => {
          const notif = state.notifications.find(n => n.id === id);
          if (notif && !notif.read) {
            notif.read = true;
            state.unreadCount = Math.max(0, state.unreadCount - 1);
          }
        });
      },

      markAllAsRead: () => {
        set((state) => {
          for (const notif of state.notifications) {
            notif.read = true;
          }
          state.unreadCount = 0;
        });
      },

      removeNotification: (id: string) => {
        set((state) => {
          const notif = state.notifications.find(n => n.id === id);
          if (notif && !notif.read) {
            state.unreadCount = Math.max(0, state.unreadCount - 1);
          }
          state.notifications = state.notifications.filter(n => n.id !== id);
        });
      },

      clearAll: () => {
        set({ notifications: [], unreadCount: 0 });
      },

      getUnreadCount: () => {
        return get().unreadCount;
      },

      getLatest: (limit = 10) => {
        return get().notifications.slice(0, limit);
      },
    })),
    {
      name: 'notification-storage',
      storage: createJSONStorage(() => localStorage),
      partialize: (state) => ({
        notifications: state.notifications,
        unreadCount: state.unreadCount,
      }),
    }
  )
);

// Subscribe to task events to create notifications
export function initNotificationListeners() {
  eventBus.subscribe('task:created', (task) => {
    useNotificationStore.getState().addNotification({
      type: 'info',
      title: 'Task Created',
      message: `"${task.title}" was created`,
      link: `/tasks/${task.id}`,
    });
  });

  eventBus.subscribe('task:completed', (payload) => {
    const task = useTaskStore.getState().tasks[payload.id];
    if (task) {
      useNotificationStore.getState().addNotification({
        type: 'success',
        title: 'Task Completed',
        message: `"${task.title}" was completed`,
        link: `/tasks/${task.id}`,
      });
    }
  });

  eventBus.subscribe('task:deleted', (payload) => {
    useNotificationStore.getState().addNotification({
      type: 'warning',
      title: 'Task Deleted',
      message: 'A task was deleted',
    });
  });
}
```

### Step 4: Notification Bell Component

```tsx
// apps/web/components/notifications/NotificationBell.tsx
'use client';

import React, { useState, useRef, useEffect } from 'react';
import { useNotificationStore, useUIStore } from '@taskflow/shared';
import { formatDistanceToNow } from 'date-fns';

export function NotificationBell() {
  const { notifications, unreadCount, markAsRead, markAllAsRead, removeNotification, clearAll } = useNotificationStore();
  const [isOpen, setIsOpen] = useState(false);
  const menuRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (menuRef.current && !menuRef.current.contains(event.target as Node)) {
        setIsOpen(false);
      }
    };
    document.addEventListener('click', handleClickOutside);
    return () => document.removeEventListener('click', handleClickOutside);
  }, []);

  const handleNotificationClick = (notification: any) => {
    markAsRead(notification.id);
    if (notification.link) {
      window.location.href = notification.link;
    }
    setIsOpen(false);
  };

  const getIcon = (type: string) => {
    switch (type) {
      case 'success': return '✅';
      case 'error': return '❌';
      case 'warning': return '⚠️';
      case 'info': return 'ℹ️';
      default: return '📢';
    }
  };

  return (
    <div className="relative" ref={menuRef}>
      <button
        onClick={() => setIsOpen(!isOpen)}
        className="relative p-2 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors"
        aria-label="Notifications"
      >
        <svg className="w-6 h-6 text-gray-600 dark:text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9" />
        </svg>
        {unreadCount > 0 && (
          <span className="absolute -top-0.5 -right-0.5 bg-red-500 text-white text-xs font-bold rounded-full w-5 h-5 flex items-center justify-center">
            {unreadCount > 99 ? '99+' : unreadCount}
          </span>
        )}
      </button>

      {isOpen && (
        <div className="absolute right-0 mt-2 w-80 max-w-[calc(100vw-2rem)] bg-white dark:bg-gray-800 rounded-lg shadow-lg border border-gray-200 dark:border-gray-700 z-50 overflow-hidden">
          <div className="flex justify-between items-center p-4 border-b border-gray-200 dark:border-gray-700">
            <h3 className="font-semibold text-gray-900 dark:text-white">Notifications</h3>
            <div className="flex gap-2">
              {unreadCount > 0 && (
                <button
                  onClick={markAllAsRead}
                  className="text-xs text-indigo-600 hover:text-indigo-800 dark:text-indigo-400 dark:hover:text-indigo-300"
                >
                  Mark all read
                </button>
              )}
              {notifications.length > 0 && (
                <button
                  onClick={clearAll}
                  className="text-xs text-red-600 hover:text-red-800 dark:text-red-400 dark:hover:text-red-300"
                >
                  Clear all
                </button>
              )}
            </div>
          </div>

          <div className="max-h-96 overflow-y-auto">
            {notifications.length === 0 ? (
              <div className="p-8 text-center text-gray-500 dark:text-gray-400">
                <div className="text-4xl mb-2">🔔</div>
                <p className="text-sm">No notifications</p>
              </div>
            ) : (
              notifications.map((notif) => (
                <div
                  key={notif.id}
                  onClick={() => handleNotificationClick(notif)}
                  className={`p-4 border-b border-gray-100 dark:border-gray-700 cursor-pointer hover:bg-gray-50 dark:hover:bg-gray-700/50 transition-colors ${
                    !notif.read ? 'bg-indigo-50 dark:bg-indigo-900/20' : ''
                  }`}
                >
                  <div className="flex items-start gap-3">
                    <span className="text-lg">{getIcon(notif.type)}</span>
                    <div className="flex-1 min-w-0">
                      <div className="flex justify-between items-start gap-2">
                        <p className="text-sm font-medium text-gray-900 dark:text-white">
                          {notif.title}
                        </p>
                        <button
                          onClick={(e) => {
                            e.stopPropagation();
                            removeNotification(notif.id);
                          }}
                          className="text-gray-400 hover:text-gray-600 dark:hover:text-gray-300"
                        >
                          ✕
                        </button>
                      </div>
                      <p className="text-sm text-gray-600 dark:text-gray-400 mt-0.5">
                        {notif.message}
                      </p>
                      <p className="text-xs text-gray-400 mt-1">
                        {formatDistanceToNow(notif.timestamp, { addSuffix: true })}
                      </p>
                    </div>
                  </div>
                </div>
              ))
            )}
          </div>
        </div>
      )}
    </div>
  );
}
```

### Step 5: Activity Feed Component

```tsx
// apps/web/components/activity/ActivityFeed.tsx
'use client';

import React, { useEffect, useState } from 'react';
import { useRealTimeStore, useTaskStore } from '@taskflow/shared';
import { formatDistanceToNow } from 'date-fns';

export function ActivityFeed() {
  const { activities, isConnected } = useRealTimeStore();
  const [filter, setFilter] = useState<'all' | 'created' | 'completed' | 'commented'>('all');

  const filteredActivities = activities.filter(activity => {
    if (filter === 'all') return true;
    return activity.action === filter;
  });

  const getActivityIcon = (action: string) => {
    switch (action) {
      case 'created': return '✨';
      case 'updated': return '📝';
      case 'completed': return '✅';
      case 'deleted': return '🗑️';
      case 'commented': return '💬';
      default: return '📌';
    }
  };

  const getActivityColor = (action: string) => {
    switch (action) {
      case 'created': return 'text-blue-500';
      case 'completed': return 'text-green-500';
      case 'deleted': return 'text-red-500';
      case 'commented': return 'text-purple-500';
      default: return 'text-gray-500';
    }
  };

  if (!isConnected) {
    return (
      <div className="text-center py-8 text-gray-500 dark:text-gray-400">
        <div className="animate-pulse">🔌 Connecting to real-time feed...</div>
      </div>
    );
  }

  return (
    <div className="bg-white dark:bg-gray-800 rounded-lg shadow overflow-hidden">
      <div className="p-4 border-b border-gray-200 dark:border-gray-700">
        <div className="flex justify-between items-center">
          <h3 className="font-semibold text-gray-900 dark:text-white">Activity Feed</h3>
          <div className="flex gap-1">
            <button
              onClick={() => setFilter('all')}
              className={`px-2 py-1 text-xs rounded ${
                filter === 'all'
                  ? 'bg-indigo-100 text-indigo-700 dark:bg-indigo-900/30 dark:text-indigo-300'
                  : 'text-gray-500 hover:bg-gray-100 dark:hover:bg-gray-700'
              }`}
            >
              All
            </button>
            <button
              onClick={() => setFilter('created')}
              className={`px-2 py-1 text-xs rounded ${
                filter === 'created'
                  ? 'bg-indigo-100 text-indigo-700 dark:bg-indigo-900/30 dark:text-indigo-300'
                  : 'text-gray-500 hover:bg-gray-100 dark:hover:bg-gray-700'
              }`}
            >
              Created
            </button>
            <button
              onClick={() => setFilter('completed')}
              className={`px-2 py-1 text-xs rounded ${
                filter === 'completed'
                  ? 'bg-indigo-100 text-indigo-700 dark:bg-indigo-900/30 dark:text-indigo-300'
                  : 'text-gray-500 hover:bg-gray-100 dark:hover:bg-gray-700'
              }`}
            >
              Completed
            </button>
            <button
              onClick={() => setFilter('commented')}
              className={`px-2 py-1 text-xs rounded ${
                filter === 'commented'
                  ? 'bg-indigo-100 text-indigo-700 dark:bg-indigo-900/30 dark:text-indigo-300'
                  : 'text-gray-500 hover:bg-gray-100 dark:hover:bg-gray-700'
              }`}
            >
              Comments
            </button>
          </div>
        </div>
      </div>

      <div className="max-h-96 overflow-y-auto">
        {filteredActivities.length === 0 ? (
          <div className="p-8 text-center text-gray-500 dark:text-gray-400">
            <div className="text-3xl mb-2">📭</div>
            <p className="text-sm">No recent activity</p>
          </div>
        ) : (
          filteredActivities.slice(0, 20).map((activity) => (
            <div
              key={activity.id}
              className="flex items-start gap-3 p-3 border-b border-gray-100 dark:border-gray-700 hover:bg-gray-50 dark:hover:bg-gray-700/50 transition-colors"
            >
              <div className="flex-shrink-0 mt-0.5">
                <span className="text-xl">{getActivityIcon(activity.action)}</span>
              </div>
              <div className="flex-1 min-w-0">
                <p className="text-sm text-gray-900 dark:text-white">
                  <span className="font-medium">{activity.userName}</span>
                  <span className={`mx-1 ${getActivityColor(activity.action)}`}>
                    {activity.action}
                  </span>
                  {activity.target}
                </p>
                <p className="text-xs text-gray-400 mt-0.5">
                  {formatDistanceToNow(activity.timestamp, { addSuffix: true })}
                </p>
              </div>
            </div>
          ))
        )}
      </div>
    </div>
  );
}
```

### Step 6: User Presence Indicator

```tsx
// apps/web/components/presence/UserPresence.tsx
'use client';

import React from 'react';
import { useRealTimeStore } from '@taskflow/shared';

interface UserPresenceProps {
  userId: string;
  userName?: string;
  showName?: boolean;
  size?: 'sm' | 'md' | 'lg';
}

export function UserPresence({ userId, userName, showName = false, size = 'md' }: UserPresenceProps) {
  const status = useRealTimeStore((state) => state.getUserStatus(userId));
  const presence = useRealTimeStore((state) => state.presence[userId]);

  const sizeClasses = {
    sm: 'w-2 h-2',
    md: 'w-3 h-3',
    lg: 'w-4 h-4',
  };

  const statusColors = {
    online: 'bg-green-500',
    away: 'bg-yellow-500',
    busy: 'bg-red-500',
    offline: 'bg-gray-400',
  };

  const statusLabels = {
    online: 'Online',
    away: 'Away',
    busy: 'Busy',
    offline: 'Offline',
  };

  return (
    <div className="flex items-center gap-2">
      <div className="relative inline-flex">
        {presence?.currentTask && (
          <div className="absolute -top-1 -right-1 w-1.5 h-1.5 bg-purple-500 rounded-full animate-pulse" />
        )}
        <div
          className={`rounded-full ${sizeClasses[size]} ${statusColors[status || 'offline']}`}
          title={`${userName || userId}: ${statusLabels[status || 'offline']}`}
        />
      </div>
      {showName && userName && (
        <span className="text-sm text-gray-700 dark:text-gray-300">
          {userName}
          {presence?.typing && (
            <span className="text-xs text-gray-400 ml-1 animate-pulse">typing...</span>
          )}
        </span>
      )}
    </div>
  );
}

// Online Users List
export function OnlineUsersList() {
  const { onlineUsers, presence } = useRealTimeStore();

  if (onlineUsers.length === 0) {
    return (
      <div className="text-sm text-gray-500 dark:text-gray-400">
        No one else is online
      </div>
    );
  }

  return (
    <div className="space-y-2">
      <div className="text-xs font-medium text-gray-500 dark:text-gray-400">
        Online ({onlineUsers.length})
      </div>
      <div className="space-y-1">
        {onlineUsers.map((userId) => {
          const user = presence[userId];
          if (!user) return null;
          return (
            <UserPresence
              key={userId}
              userId={userId}
              userName={user.userName}
              showName
            />
          );
        })}
      </div>
    </div>
  );
}
```

### Step 7: Real-Time Task Comments

```tsx
// apps/web/components/tasks/TaskComments.tsx
'use client';

import React, { useState, useRef, useEffect } from 'react';
import { useTaskStore, useAuthStore, useRealTimeStore, wsService } from '@taskflow/shared';
import { formatDistanceToNow } from 'date-fns';

interface TaskCommentsProps {
  taskId: string;
}

export function TaskComments({ taskId }: TaskCommentsProps) {
  const [comment, setComment] = useState('');
  const [isTyping, setIsTyping] = useState(false);
  const task = useTaskStore((state) => state.tasks[taskId]);
  const updateTask = useTaskStore((state) => state.updateTask);
  const user = useAuthStore((state) => state.user);
  const typingUsers = useRealTimeStore((state) => state.typingUsers);
  const comments = task?.comments || [];

  const typingTimeoutRef = useRef<NodeJS.Timeout | null>(null);

  const handleTyping = (isTypingNow: boolean) => {
    if (isTypingNow && !isTyping) {
      setIsTyping(true);
      wsService.send('typing', {
        userId: user?.id,
        userName: user?.name,
        taskId,
        isTyping: true,
      });
    }

    if (typingTimeoutRef.current) {
      clearTimeout(typingTimeoutRef.current);
    }

    typingTimeoutRef.current = setTimeout(() => {
      if (isTyping) {
        setIsTyping(false);
        wsService.send('typing', {
          userId: user?.id,
          userName: user?.name,
          taskId,
          isTyping: false,
        });
      }
    }, 2000);
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!comment.trim() || !user) return;

    const newComment = {
      id: `comment-${Date.now()}`,
      taskId,
      userId: user.id,
      content: comment.trim(),
      createdAt: new Date(),
      updatedAt: new Date(),
    };

    // Optimistic update
    const currentTask = useTaskStore.getState().tasks[taskId];
    if (currentTask) {
      await updateTask(taskId, {
        comments: [...currentTask.comments, newComment],
      });
    }

    setComment('');
    setIsTyping(false);
    wsService.send('typing', {
      userId: user.id,
      userName: user.name,
      taskId,
      isTyping: false,
    });

    // Notify via WebSocket
    wsService.send('activity', {
      userId: user.id,
      userName: user.name,
      action: 'commented',
      target: task?.title || 'task',
      targetType: 'task',
      metadata: { comment: comment.trim() },
    });
  };

  const typingInTask = Object.values(typingUsers)
    .filter(t => t.taskId === taskId && t.userId !== user?.id)
    .map(t => t.userName);

  return (
    <div className="space-y-4">
      <h4 className="font-medium text-gray-900 dark:text-white">
        Comments ({comments.length})
      </h4>

      <div className="max-h-60 overflow-y-auto space-y-3">
        {comments.length === 0 ? (
          <p className="text-sm text-gray-500 dark:text-gray-400">No comments yet</p>
        ) : (
          comments.map((comment: any) => (
            <div key={comment.id} className="flex gap-3">
              <div className="flex-shrink-0 w-8 h-8 rounded-full bg-indigo-100 dark:bg-indigo-900/30 flex items-center justify-center text-indigo-600 dark:text-indigo-400 font-medium text-sm">
                {comment.userId.slice(0, 2).toUpperCase()}
              </div>
              <div className="flex-1 min-w-0">
                <div className="flex items-center gap-2">
                  <span className="text-sm font-medium text-gray-900 dark:text-white">
                    {comment.userId === user?.id ? 'You' : `User ${comment.userId.slice(0, 8)}`}
                  </span>
                  <span className="text-xs text-gray-400">
                    {formatDistanceToNow(new Date(comment.createdAt), { addSuffix: true })}
                  </span>
                </div>
                <p className="text-sm text-gray-700 dark:text-gray-300 mt-0.5">
                  {comment.content}
                </p>
              </div>
            </div>
          ))
        )}
        {typingInTask.length > 0 && (
          <p className="text-sm text-gray-400 italic animate-pulse">
            {typingInTask.length === 1
              ? `${typingInTask[0]} is typing...`
              : `${typingInTask.length} people are typing...`}
          </p>
        )}
      </div>

      <form onSubmit={handleSubmit} className="flex gap-2">
        <input
          type="text"
          value={comment}
          onChange={(e) => {
            setComment(e.target.value);
            handleTyping(e.target.value.length > 0);
          }}
          onBlur={() => handleTyping(false)}
          placeholder="Add a comment..."
          className="flex-1 px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-indigo-500 text-sm"
        />
        <button
          type="submit"
          disabled={!comment.trim()}
          className="px-4 py-2 bg-indigo-600 text-white rounded-lg hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 disabled:opacity-50 disabled:cursor-not-allowed text-sm"
        >
          Send
        </button>
      </form>
    </div>
  );
}
```

### Step 8: Real-Time Provider

```tsx
// apps/web/components/providers/RealTimeProvider.tsx
'use client';

import React, { useEffect } from 'react';
import { wsService } from '@taskflow/shared/services/websocket';
import { useRealTimeStore, useAuthStore, initNotificationListeners } from '@taskflow/shared';
import { useUIStore } from '@taskflow/shared';

export function RealTimeProvider({ children }: { children: React.ReactNode }) {
  const { isAuthenticated, user } = useAuthStore();
  const { addToast } = useUIStore();
  const { isConnected, isReconnecting } = useRealTimeStore();

  useEffect(() => {
    // Initialize notification listeners
    initNotificationListeners();
  }, []);

  useEffect(() => {
    if (isAuthenticated && user) {
      wsService.connect();
    } else {
      wsService.disconnect();
    }

    return () => {
      wsService.disconnect();
    };
  }, [isAuthenticated, user]);

  // Show connection status toasts
  useEffect(() => {
    if (isConnected) {
      addToast({
        type: 'success',
        message: 'Connected to real-time server',
        title: 'Connected',
        duration: 3000,
      });
    } else if (isReconnecting) {
      addToast({
        type: 'warning',
        message: 'Reconnecting to real-time server...',
        title: 'Reconnecting',
        duration: 3000,
      });
    }
  }, [isConnected, isReconnecting]);

  return <>{children}</>;
}
```

---

## The Verification: Testing Real-Time Features

### Step 1: Manual Testing

1. Start development server:
   ```bash
   cd apps/web
   pnpm dev
   ```

2. Login and navigate to dashboard

3. Test WebSocket connection:
   - ✅ Connection status should show "Connected"
   - ✅ Presence indicators should appear

4. Test notifications:
   - Create a task → notification should appear
   - Complete a task → notification should appear
   - Click notification → should navigate to task

5. Test activity feed:
   - Perform actions → should appear in feed
   - Filter by action type → should show relevant activities

6. Test presence:
   - Open two browsers → both should show online
   - Mark as away → status should update

7. Test typing indicators:
   - Start typing in comments → should show "typing..."
   - Stop typing → indicator should disappear

8. Test offline queuing:
   - Disconnect network
   - Perform actions
   - Reconnect → actions should sync

### Step 2: Run Tests

```typescript
// packages/shared/src/store/__tests__/realtime.test.ts
import { describe, it, expect, beforeEach } from 'vitest';
import { useRealTimeStore } from '../realtime/realtimeStore';

describe('RealTime Store', () => {
  beforeEach(() => {
    useRealTimeStore.setState({
      presence: {},
      onlineUsers: [],
      activities: [],
      maxActivities: 100,
      isConnected: false,
      isReconnecting: false,
      reconnectAttempts: 0,
      lastHeartbeat: null,
      typingUsers: {},
    });
  });

  it('should update presence', () => {
    const { updatePresence } = useRealTimeStore.getState();
    updatePresence({
      userId: 'user-1',
      userName: 'Test User',
      status: 'online',
      lastSeen: new Date(),
    });

    const state = useRealTimeStore.getState();
    expect(state.onlineUsers).toContain('user-1');
    expect(state.presence['user-1'].status).toBe('online');
  });

  it('should add activity', () => {
    const { addActivity } = useRealTimeStore.getState();
    addActivity({
      userId: 'user-1',
      userName: 'Test User',
      action: 'created',
      target: 'Test Task',
      targetType: 'task',
    });

    const state = useRealTimeStore.getState();
    expect(state.activities).toHaveLength(1);
    expect(state.activities[0].action).toBe('created');
  });

  it('should handle typing', () => {
    const { setUserTyping } = useRealTimeStore.getState();
    setUserTyping('user-1', 'Test User', 'task-1', true);

    const state = useRealTimeStore.getState();
    expect(state.typingUsers['user-1']).toBeDefined();
    expect(state.typingUsers['user-1'].taskId).toBe('task-1');
  });
});
```

---

## What's Next

You've built real-time features including WebSocket integration, notifications, presence, and activity feeds. Next, you'll implement testing strategies including unit tests, integration tests, and end-to-end tests for the entire application.
