# Part 6 — Production Patterns

## Section 26: Real-Time Applications

Real‑time features—chat, notifications, live collaboration, presence tracking—are increasingly expected in modern applications. Zustand's fine‑grained subscriptions and ability to work with WebSockets and other real‑time protocols make it an excellent choice for building reactive, live experiences. In this section, you'll learn how to build a complete real‑time system with Zustand.

---

## The Target: Production-Ready Real-Time State

By the end of this section, you'll be able to:
- Connect Zustand stores to WebSocket and Server‑Sent Event (SSE) streams
- Implement live notifications with unread counts and read states
- Build a chat system with message history, typing indicators, and online status
- Add presence tracking (who's online, what they're doing)
- Optimize real‑time updates to prevent excessive re‑renders
- Implement reconnection logic and offline message queuing

---

## The Concept: Real-Time as a Live View

Think of real‑time applications like a **live sports broadcast**:

```
┌─────────────────────────────────────────────────────────────────┐
│                    REAL-TIME ARCHITECTURE                      │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  WebSocket / SSE Connection                              │  │
│  │  • Persistent bidirectional channel                      │  │
│  │  • Reconnect logic                                      │  │
│  │  • Heartbeat / ping                                     │  │
│  └──────────────────────────────────────────────────────────┘  │
│                         │                                      │
│                         ▼                                      │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Zustand Real‑Time Store                                │  │
│  │  • Messages (chat, notifications)                       │  │
│  │  • Presence (online users, status)                     │  │
│  │  • Typing indicators                                    │  │
│  │  • Read receipts                                        │  │
│  └──────────────────────────────────────────────────────────┘  │
│                         │                                      │
│                         ▼                                      │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  React Components                                       │  │
│  │  • Message list (virtualized)                           │  │
│  │  • Notification badge                                    │  │
│  │  • Online/offline indicators                             │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

---

## The Implementation: Real-Time Stores

### Step 1: Define Types

```typescript
// src/types/realtime.types.ts
export interface Message {
  id: string;
  userId: string;
  userName: string;
  userAvatar?: string;
  text: string;
  timestamp: Date;
  readBy: string[]; // User IDs who have read this message
  type: 'text' | 'image' | 'file' | 'system';
  metadata?: any;
}

export interface Notification {
  id: string;
  type: 'info' | 'success' | 'warning' | 'error';
  title: string;
  message: string;
  read: boolean;
  timestamp: Date;
  link?: string;
  action?: { label: string; handler: () => void };
}

export interface Presence {
  userId: string;
  userName: string;
  status: 'online' | 'away' | 'busy' | 'offline';
  lastSeen: Date;
  currentRoom?: string;
  typing: boolean;
  typingRoom?: string;
}

export interface ChatRoom {
  id: string;
  name: string;
  type: 'direct' | 'group';
  participants: string[];
  lastMessage?: Message;
  unreadCount: number;
  createdAt: Date;
}

export interface RealTimeState {
  // Messages
  messages: Record<string, Message>;
  messageIds: string[];
  chatRooms: Record<string, ChatRoom>;
  chatRoomIds: string[];
  currentRoomId: string | null;
  
  // Notifications
  notifications: Record<string, Notification>;
  notificationIds: string[];
  unreadNotificationCount: number;
  
  // Presence
  presence: Record<string, Presence>;
  onlineUsers: string[];
  
  // Connection
  isConnected: boolean;
  isReconnecting: boolean;
  reconnectAttempts: number;
  lastHeartbeat: Date | null;
  
  // Typing
  typingUsers: Record<string, { userId: string; userName: string; timestamp: Date }>;
}
```

### Step 2: Create the Real-Time Store

```typescript
// src/store/realtimeStore.ts
import { create } from 'zustand';
import { immer } from 'zustand/middleware/immer';
import { 
  Message, Notification, Presence, ChatRoom, RealTimeState 
} from '../types/realtime.types';

interface RealTimeStore extends RealTimeState {
  // Message actions
  addMessage: (message: Message) => void;
  markMessageRead: (messageId: string, userId: string) => void;
  markAllMessagesRead: (roomId: string, userId: string) => void;
  
  // Room actions
  setCurrentRoom: (roomId: string) => void;
  addChatRoom: (room: ChatRoom) => void;
  updateChatRoom: (roomId: string, updates: Partial<ChatRoom>) => void;
  
  // Notification actions
  addNotification: (notification: Omit<Notification, 'id' | 'timestamp' | 'read'>) => void;
  markNotificationRead: (id: string) => void;
  markAllNotificationsRead: () => void;
  clearNotifications: () => void;
  
  // Presence actions
  updatePresence: (presence: Presence) => void;
  setUserTyping: (userId: string, userName: string, isTyping: boolean, roomId: string) => void;
  removeTypingUser: (userId: string) => void;
  clearTyping: () => void;
  
  // Connection actions
  setConnected: (connected: boolean) => void;
  setReconnecting: (reconnecting: boolean) => void;
  incrementReconnectAttempts: () => void;
  resetReconnectAttempts: () => void;
  updateHeartbeat: () => void;
  
  // WebSocket handlers (called by the WebSocket service)
  handleMessage: (data: any) => void;
  handlePresenceUpdate: (data: any) => void;
  handleNotification: (data: any) => void;
  handleTyping: (data: any) => void;
  
  // Utilities
  getUnreadCount: (roomId: string) => number;
  getRoomMessages: (roomId: string) => Message[];
  getOnlineStatus: (userId: string) => boolean;
  clearAll: () => void;
}

export const useRealTimeStore = create<RealTimeStore>()(
  immer((set, get) => ({
    // Initial state
    messages: {},
    messageIds: [],
    chatRooms: {},
    chatRoomIds: [],
    currentRoomId: null,
    notifications: {},
    notificationIds: [],
    unreadNotificationCount: 0,
    presence: {},
    onlineUsers: [],
    isConnected: false,
    isReconnecting: false,
    reconnectAttempts: 0,
    lastHeartbeat: null,
    typingUsers: {},

    // --- Message Actions ---
    addMessage: (message: Message) => {
      set((state) => {
        // Avoid duplicate messages
        if (state.messages[message.id]) return;
        
        state.messages[message.id] = message;
        state.messageIds.push(message.id);
        
        // Update room's last message
        const roomId = message.metadata?.roomId;
        if (roomId && state.chatRooms[roomId]) {
          state.chatRooms[roomId].lastMessage = message;
          // Only increment unread if not from current user
          if (message.userId !== get().getCurrentUserId?.()) {
            state.chatRooms[roomId].unreadCount += 1;
          }
        }
      });
    },

    markMessageRead: (messageId: string, userId: string) => {
      set((state) => {
        const message = state.messages[messageId];
        if (message && !message.readBy.includes(userId)) {
          message.readBy.push(userId);
        }
      });
    },

    markAllMessagesRead: (roomId: string, userId: string) => {
      set((state) => {
        const room = state.chatRooms[roomId];
        if (!room) return;
        
        // Mark all messages in this room as read by the user
        for (const id of state.messageIds) {
          const msg = state.messages[id];
          if (msg?.metadata?.roomId === roomId && !msg.readBy.includes(userId)) {
            msg.readBy.push(userId);
          }
        }
        
        room.unreadCount = 0;
      });
    },

    // --- Room Actions ---
    setCurrentRoom: (roomId: string) => {
      set((state) => {
        state.currentRoomId = roomId;
        // Mark messages as read when entering a room
        const userId = get().getCurrentUserId?.();
        if (userId) {
          get().markAllMessagesRead(roomId, userId);
        }
      });
    },

    addChatRoom: (room: ChatRoom) => {
      set((state) => {
        if (!state.chatRooms[room.id]) {
          state.chatRooms[room.id] = room;
          state.chatRoomIds.push(room.id);
        }
      });
    },

    updateChatRoom: (roomId: string, updates: Partial<ChatRoom>) => {
      set((state) => {
        if (state.chatRooms[roomId]) {
          Object.assign(state.chatRooms[roomId], updates);
        }
      });
    },

    // --- Notification Actions ---
    addNotification: (notification) => {
      set((state) => {
        const id = `notif-${Date.now()}`;
        const newNotif: Notification = {
          ...notification,
          id,
          read: false,
          timestamp: new Date(),
        };
        state.notifications[id] = newNotif;
        state.notificationIds.push(id);
        state.unreadNotificationCount += 1;
      });
    },

    markNotificationRead: (id: string) => {
      set((state) => {
        const notif = state.notifications[id];
        if (notif && !notif.read) {
          notif.read = true;
          state.unreadNotificationCount = Math.max(0, state.unreadNotificationCount - 1);
        }
      });
    },

    markAllNotificationsRead: () => {
      set((state) => {
        for (const id of state.notificationIds) {
          if (!state.notifications[id].read) {
            state.notifications[id].read = true;
          }
        }
        state.unreadNotificationCount = 0;
      });
    },

    clearNotifications: () => {
      set({ notifications: {}, notificationIds: [], unreadNotificationCount: 0 });
    },

    // --- Presence Actions ---
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
        
        // If user went offline and we're tracking typing, remove them
        if (presence.status === 'offline') {
          delete state.typingUsers[presence.userId];
        }
      });
    },

    setUserTyping: (userId: string, userName: string, isTyping: boolean, roomId: string) => {
      set((state) => {
        if (isTyping) {
          state.typingUsers[userId] = { userId, userName, timestamp: new Date() };
        } else {
          delete state.typingUsers[userId];
        }
      });
    },

    removeTypingUser: (userId: string) => {
      set((state) => {
        delete state.typingUsers[userId];
      });
    },

    clearTyping: () => {
      set({ typingUsers: {} });
    },

    // --- Connection Actions ---
    setConnected: (connected: boolean) => {
      set({ isConnected: connected });
    },

    setReconnecting: (reconnecting: boolean) => {
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
        case 'message':
          get().addMessage(data.payload);
          break;
        case 'room_update':
          get().updateChatRoom(data.payload.roomId, data.payload.updates);
          break;
        case 'presence':
          get().updatePresence(data.payload);
          break;
        case 'typing':
          get().setUserTyping(
            data.payload.userId,
            data.payload.userName,
            data.payload.isTyping,
            data.payload.roomId
          );
          break;
        case 'notification':
          get().addNotification(data.payload);
          break;
        case 'heartbeat':
          get().updateHeartbeat();
          break;
        default:
          console.log('Unknown WebSocket message type:', data.type);
      }
    },

    handlePresenceUpdate: (data: any) => {
      get().updatePresence(data);
    },

    handleNotification: (data: any) => {
      get().addNotification(data);
    },

    handleTyping: (data: any) => {
      get().setUserTyping(data.userId, data.userName, data.isTyping, data.roomId);
    },

    // --- Utilities ---
    getUnreadCount: (roomId: string) => {
      const room = get().chatRooms[roomId];
      return room?.unreadCount || 0;
    },

    getRoomMessages: (roomId: string) => {
      const state = get();
      return state.messageIds
        .map(id => state.messages[id])
        .filter(msg => msg.metadata?.roomId === roomId)
        .sort((a, b) => a.timestamp.getTime() - b.timestamp.getTime());
    },

    getOnlineStatus: (userId: string) => {
      const presence = get().presence[userId];
      return presence?.status === 'online';
    },

    clearAll: () => {
      set({
        messages: {},
        messageIds: [],
        notifications: {},
        notificationIds: [],
        unreadNotificationCount: 0,
        presence: {},
        onlineUsers: [],
        typingUsers: {},
        chatRooms: {},
        chatRoomIds: [],
        currentRoomId: null,
      });
    },
  }))
);

// Helper to get current user ID (should be set by auth store)
useRealTimeStore.getState().getCurrentUserId = () => {
  // In production, get from auth store
  return useAuthStore.getState().user?.id;
};
```

### Step 3: WebSocket Service

```typescript
// src/services/websocketService.ts
import { useRealTimeStore } from '../store/realtimeStore';

type MessageHandler = (data: any) => void;

class WebSocketService {
  private ws: WebSocket | null = null;
  private reconnectAttempts = 0;
  private maxReconnectAttempts = 10;
  private reconnectDelay = 1000;
  private pingInterval: NodeJS.Timeout | null = null;
  private url: string;
  private messageHandlers: Set<MessageHandler> = new Set();

  constructor(url: string) {
    this.url = url;
  }

  connect(): void {
    if (this.ws && this.ws.readyState === WebSocket.OPEN) {
      return;
    }

    const store = useRealTimeStore.getState();
    store.setReconnecting(true);

    try {
      this.ws = new WebSocket(this.url);
    } catch (error) {
      console.error('Failed to create WebSocket:', error);
      this.scheduleReconnect();
      return;
    }

    this.ws.onopen = () => {
      console.log('🔌 WebSocket connected');
      const store = useRealTimeStore.getState();
      store.setConnected(true);
      store.setReconnecting(false);
      store.resetReconnectAttempts();
      this.reconnectAttempts = 0;
      this.startPing();

      // Send initial presence
      this.send('presence', { status: 'online' });
    };

    this.ws.onmessage = (event) => {
      try {
        const data = JSON.parse(event.data);
        const store = useRealTimeStore.getState();
        store.handleMessage(data);

        // Also notify any custom handlers
        for (const handler of this.messageHandlers) {
          handler(data);
        }
      } catch (error) {
        console.error('Failed to parse WebSocket message:', error);
      }
    };

    this.ws.onclose = (event) => {
      console.log(`🔌 WebSocket closed: ${event.code} - ${event.reason}`);
      const store = useRealTimeStore.getState();
      store.setConnected(false);
      store.setReconnecting(false);
      this.stopPing();
      this.scheduleReconnect();
    };

    this.ws.onerror = (error) => {
      console.error('WebSocket error:', error);
      // The browser will close the connection, triggering onclose
    };
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

  private scheduleReconnect(): void {
    if (this.reconnectAttempts >= this.maxReconnectAttempts) {
      console.log('Max reconnect attempts reached');
      useRealTimeStore.getState().setReconnecting(false);
      return;
    }

    this.reconnectAttempts++;
    const delay = Math.min(this.reconnectDelay * Math.pow(2, this.reconnectAttempts - 1), 30000);
    console.log(`🔄 Reconnecting in ${delay}ms (attempt ${this.reconnectAttempts})`);
    
    setTimeout(() => {
      this.connect();
    }, delay);
  }

  send(type: string, payload: any): void {
    if (!this.ws || this.ws.readyState !== WebSocket.OPEN) {
      console.warn('WebSocket not connected, cannot send message');
      // Queue for later
      this.queueMessage({ type, payload });
      return;
    }

    this.ws.send(JSON.stringify({ type, payload }));
  }

  private messageQueue: Array<{ type: string; payload: any }> = [];

  private queueMessage(message: { type: string; payload: any }): void {
    this.messageQueue.push(message);
    // Try to send later when reconnected
    setTimeout(() => {
      if (this.ws?.readyState === WebSocket.OPEN) {
        while (this.messageQueue.length > 0) {
          const queued = this.messageQueue.shift();
          if (queued) {
            this.send(queued.type, queued.payload);
          }
        }
      }
    }, 1000);
  }

  // Subscribe to raw messages (for custom handlers)
  subscribe(handler: MessageHandler): () => void {
    this.messageHandlers.add(handler);
    return () => {
      this.messageHandlers.delete(handler);
    };
  }

  disconnect(): void {
    this.stopPing();
    if (this.ws) {
      this.ws.close();
      this.ws = null;
    }
    useRealTimeStore.getState().setConnected(false);
  }

  isConnected(): boolean {
    return this.ws?.readyState === WebSocket.OPEN;
  }
}

// Singleton instance
const WS_URL = process.env.NEXT_PUBLIC_WS_URL || 'wss://api.example.com/ws';
export const wsService = new WebSocketService(WS_URL);
```

### Step 4: Chat Component

```tsx
// src/components/Chat/ChatRoom.tsx
'use client';

import React, { useState, useEffect, useRef } from 'react';
import { useRealTimeStore } from '../../store/realtimeStore';
import { wsService } from '../../services/websocketService';
import { Message } from '../../types/realtime.types';

// Message item component (memoized for performance)
const MessageItem = React.memo(({ message, isOwnMessage }: { message: Message; isOwnMessage: boolean }) => {
  const isRead = message.readBy.length > 0;

  return (
    <div className={`flex ${isOwnMessage ? 'justify-end' : 'justify-start'} mb-2`}>
      <div
        className={`max-w-[70%] rounded-lg px-4 py-2 ${
          isOwnMessage
            ? 'bg-blue-500 text-white'
            : 'bg-gray-100 text-gray-900'
        }`}
      >
        {!isOwnMessage && (
          <div className="text-xs font-semibold text-gray-500 mb-1">
            {message.userName}
          </div>
        )}
        <div className="text-sm">{message.text}</div>
        <div className="text-xs opacity-70 mt-1 flex justify-between items-center gap-2">
          <span>{new Date(message.timestamp).toLocaleTimeString()}</span>
          {isOwnMessage && (
            <span>{isRead ? '✓✓' : '✓'}</span>
          )}
        </div>
      </div>
    </div>
  );
});

// Typing indicator
function TypingIndicator() {
  const typingUsers = useRealTimeStore((state) => state.typingUsers);
  const currentRoomId = useRealTimeStore((state) => state.currentRoomId);
  
  const typingInRoom = Object.values(typingUsers)
    .filter(t => t.typingRoom === currentRoomId)
    .map(t => t.userName);

  if (typingInRoom.length === 0) return null;

  const text = typingInRoom.length === 1
    ? `${typingInRoom[0]} is typing...`
    : `${typingInRoom.length} people are typing...`;

  return (
    <div className="text-sm text-gray-500 italic px-4 py-1">
      {text}
    </div>
  );
}

// Chat input component
function ChatInput({ roomId }: { roomId: string }) {
  const [message, setMessage] = useState('');
  const [isTyping, setIsTyping] = useState(false);
  const typingTimeoutRef = useRef<NodeJS.Timeout | null>(null);
  const { currentUserId, userName } = useRealTimeStore((state) => ({
    currentUserId: state.getCurrentUserId?.(),
    userName: state.presence[state.getCurrentUserId?.()]?.userName || 'You',
  }));

  const handleTyping = (isTypingNow: boolean) => {
    if (isTypingNow && !isTyping) {
      // User started typing
      wsService.send('typing', { userId: currentUserId, userName, isTyping: true, roomId });
      setIsTyping(true);
    }

    // Clear existing timeout
    if (typingTimeoutRef.current) {
      clearTimeout(typingTimeoutRef.current);
    }

    // Set timeout to stop typing after 2 seconds of inactivity
    typingTimeoutRef.current = setTimeout(() => {
      if (isTyping) {
        wsService.send('typing', { userId: currentUserId, userName, isTyping: false, roomId });
        setIsTyping(false);
      }
    }, 2000);
  };

  const handleSend = () => {
    if (!message.trim()) return;

    const msg = {
      id: `msg-${Date.now()}`,
      userId: currentUserId || 'unknown',
      userName: userName || 'Unknown',
      text: message.trim(),
      timestamp: new Date(),
      readBy: [],
      type: 'text',
      metadata: { roomId },
    };

    // Optimistically add to store
    useRealTimeStore.getState().addMessage(msg);

    // Send via WebSocket
    wsService.send('message', msg);

    setMessage('');
    setIsTyping(false);
    if (typingTimeoutRef.current) {
      clearTimeout(typingTimeoutRef.current);
    }
    wsService.send('typing', { userId: currentUserId, userName, isTyping: false, roomId });
  };

  const handleKeyDown = (e: React.KeyboardEvent<HTMLInputElement>) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      handleSend();
    }
  };

  return (
    <div className="border-t p-4">
      <div className="flex gap-2">
        <input
          type="text"
          value={message}
          onChange={(e) => {
            setMessage(e.target.value);
            handleTyping(e.target.value.length > 0);
          }}
          onKeyDown={handleKeyDown}
          placeholder="Type a message..."
          className="flex-1 px-4 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
        />
        <button
          onClick={handleSend}
          disabled={!message.trim()}
          className="px-6 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 disabled:opacity-50"
        >
          Send
        </button>
      </div>
    </div>
  );
}

// Main ChatRoom component
export function ChatRoom({ roomId }: { roomId: string }) {
  const { messages, currentRoomId, setCurrentRoom, getRoomMessages, isConnected } = useRealTimeStore((state) => ({
    messages: state.messages,
    currentRoomId: state.currentRoomId,
    setCurrentRoom: state.setCurrentRoom,
    getRoomMessages: state.getRoomMessages,
    isConnected: state.isConnected,
  }));

  const [messageList, setMessageList] = useState<Message[]>([]);
  const messagesEndRef = useRef<HTMLDivElement>(null);
  const containerRef = useRef<HTMLDivElement>(null);

  // Set current room on mount
  useEffect(() => {
    setCurrentRoom(roomId);
    return () => {
      // Optionally leave room
    };
  }, [roomId]);

  // Subscribe to messages for this room
  useEffect(() => {
    const unsubscribe = useRealTimeStore.subscribe((state) => {
      const roomMessages = getRoomMessages(roomId);
      setMessageList(roomMessages);
    });

    // Initial load
    const initial = getRoomMessages(roomId);
    setMessageList(initial);

    return () => unsubscribe();
  }, [roomId]);

  // Scroll to bottom on new messages
  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messageList]);

  // Connect WebSocket if not connected
  useEffect(() => {
    if (!isConnected) {
      wsService.connect();
    }
    return () => {
      // Don't disconnect globally; other components might use it
    };
  }, []);

  return (
    <div className="flex flex-col h-full border rounded-lg bg-white">
      {/* Chat header */}
      <div className="border-b p-4">
        <h3 className="font-semibold">Room #{roomId}</h3>
        <span className="text-xs text-gray-500">
          {isConnected ? '🟢 Online' : '🔴 Offline'}
        </span>
      </div>

      {/* Message list */}
      <div ref={containerRef} className="flex-1 overflow-y-auto p-4">
        {messageList.length === 0 ? (
          <div className="text-center text-gray-500 py-8">
            No messages yet. Say hello!
          </div>
        ) : (
          <>
            {messageList.map((msg) => {
              const isOwn = msg.userId === useRealTimeStore.getState().getCurrentUserId?.();
              return <MessageItem key={msg.id} message={msg} isOwnMessage={isOwn} />;
            })}
            <TypingIndicator />
            <div ref={messagesEndRef} />
          </>
        )}
      </div>

      {/* Input */}
      <ChatInput roomId={roomId} />
    </div>
  );
}
```

### Step 5: Notification Bell Component

```tsx
// src/components/Notifications/NotificationBell.tsx
'use client';

import React, { useState, useEffect } from 'react';
import { useRealTimeStore } from '../../store/realtimeStore';
import { wsService } from '../../services/websocketService';

export function NotificationBell() {
  const {
    notifications,
    notificationIds,
    unreadNotificationCount,
    markNotificationRead,
    markAllNotificationsRead,
    clearNotifications,
  } = useRealTimeStore((state) => ({
    notifications: state.notifications,
    notificationIds: state.notificationIds,
    unreadNotificationCount: state.unreadNotificationCount,
    markNotificationRead: state.markNotificationRead,
    markAllNotificationsRead: state.markAllNotificationsRead,
    clearNotifications: state.clearNotifications,
  }));

  const [isOpen, setIsOpen] = useState(false);

  // Close dropdown when clicking outside
  useEffect(() => {
    const handleClickOutside = (e: MouseEvent) => {
      const target = e.target as HTMLElement;
      if (!target.closest('.notification-dropdown')) {
        setIsOpen(false);
      }
    };
    document.addEventListener('click', handleClickOutside);
    return () => document.removeEventListener('click', handleClickOutside);
  }, []);

  const handleNotificationClick = (id: string, link?: string) => {
    markNotificationRead(id);
    if (link) {
      window.location.href = link;
    }
    setIsOpen(false);
  };

  const sortedNotifications = notificationIds
    .map(id => notifications[id])
    .sort((a, b) => b.timestamp.getTime() - a.timestamp.getTime());

  return (
    <div className="relative notification-dropdown">
      <button
        onClick={() => setIsOpen(!isOpen)}
        className="relative p-2 text-gray-600 hover:text-gray-900 focus:outline-none"
      >
        <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9" />
        </svg>
        {unreadNotificationCount > 0 && (
          <span className="absolute -top-1 -right-1 bg-red-500 text-white text-xs rounded-full w-5 h-5 flex items-center justify-center">
            {unreadNotificationCount > 99 ? '99+' : unreadNotificationCount}
          </span>
        )}
      </button>

      {isOpen && (
        <div className="absolute right-0 mt-2 w-80 bg-white rounded-lg shadow-lg border max-h-96 overflow-y-auto z-50">
          <div className="p-4 border-b flex justify-between items-center">
            <h3 className="font-semibold">Notifications</h3>
            <div className="flex gap-2">
              {unreadNotificationCount > 0 && (
                <button
                  onClick={markAllNotificationsRead}
                  className="text-xs text-blue-600 hover:text-blue-800"
                >
                  Mark all read
                </button>
              )}
              {notificationIds.length > 0 && (
                <button
                  onClick={clearNotifications}
                  className="text-xs text-red-600 hover:text-red-800"
                >
                  Clear all
                </button>
              )}
            </div>
          </div>

          {notificationIds.length === 0 ? (
            <div className="p-4 text-center text-gray-500">
              No notifications
            </div>
          ) : (
            sortedNotifications.map((notif) => (
              <div
                key={notif.id}
                onClick={() => handleNotificationClick(notif.id, notif.link)}
                className={`p-3 border-b hover:bg-gray-50 cursor-pointer transition-colors ${
                  notif.read ? 'opacity-60' : 'bg-blue-50'
                }`}
              >
                <div className="flex items-start gap-2">
                  <span className="mt-0.5">
                    {notif.type === 'info' && 'ℹ️'}
                    {notif.type === 'success' && '✅'}
                    {notif.type === 'warning' && '⚠️'}
                    {notif.type === 'error' && '❌'}
                  </span>
                  <div className="flex-1">
                    <div className="font-medium text-sm">{notif.title}</div>
                    <div className="text-sm text-gray-600">{notif.message}</div>
                    <div className="text-xs text-gray-400 mt-1">
                      {new Date(notif.timestamp).toLocaleString()}
                    </div>
                  </div>
                  {!notif.read && <div className="w-2 h-2 bg-blue-500 rounded-full mt-1.5" />}
                </div>
              </div>
            ))
          )}
        </div>
      )}
    </div>
  );
}
```

### Step 6: Presence & Online Status

```tsx
// src/components/Presence/AvatarWithStatus.tsx
'use client';

import React from 'react';
import { useRealTimeStore } from '../../store/realtimeStore';

export function AvatarWithStatus({ userId, name, avatar }: { userId: string; name: string; avatar?: string }) {
  const status = useRealTimeStore((state) => state.presence[userId]?.status || 'offline');
  const isOnline = status === 'online';

  const statusColors = {
    online: 'bg-green-500',
    away: 'bg-yellow-500',
    busy: 'bg-red-500',
    offline: 'bg-gray-400',
  };

  return (
    <div className="relative inline-block">
      <div className="w-10 h-10 rounded-full bg-gray-300 flex items-center justify-center text-sm font-medium text-gray-700">
        {avatar ? (
          <img src={avatar} alt={name} className="w-full h-full rounded-full object-cover" />
        ) : (
          name.charAt(0).toUpperCase()
        )}
      </div>
      <div
        className={`absolute -bottom-0.5 -right-0.5 w-3 h-3 rounded-full border-2 border-white ${statusColors[status]}`}
      />
    </div>
  );
}

// Online users list
export function OnlineUsersList() {
  const onlineUsers = useRealTimeStore((state) => state.onlineUsers);
  const presence = useRealTimeStore((state) => state.presence);

  return (
    <div className="p-4 border rounded-lg">
      <h4 className="font-semibold mb-2">Online ({onlineUsers.length})</h4>
      <ul className="space-y-1">
        {onlineUsers.map((userId) => {
          const user = presence[userId];
          if (!user) return null;
          return (
            <li key={userId} className="flex items-center gap-2">
              <AvatarWithStatus userId={userId} name={user.userName} />
              <span className="text-sm">{user.userName}</span>
              {user.typing && (
                <span className="text-xs text-gray-500 italic">typing...</span>
              )}
            </li>
          );
        })}
      </ul>
    </div>
  );
}
```

---

## The Verification: Testing Real-Time Features

### Step 1: Test Component

```tsx
// src/app/chat/page.tsx
'use client';

import React, { useEffect } from 'react';
import { ChatRoom } from '@/components/Chat/ChatRoom';
import { OnlineUsersList } from '@/components/Presence/AvatarWithStatus';
import { NotificationBell } from '@/components/Notifications/NotificationBell';
import { wsService } from '@/services/websocketService';
import { useRealTimeStore } from '@/store/realtimeStore';

export default function ChatPage() {
  const { isConnected, addChatRoom } = useRealTimeStore();

  useEffect(() => {
    // Connect WebSocket
    wsService.connect();

    // Add a sample room
    addChatRoom({
      id: 'room-1',
      name: 'General',
      type: 'group',
      participants: ['user-1', 'user-2'],
      unreadCount: 0,
      createdAt: new Date(),
    });

    return () => {
      // Don't disconnect globally
    };
  }, []);

  return (
    <div className="container mx-auto p-4">
      <div className="flex justify-between items-center mb-4">
        <h1 className="text-2xl font-bold">Real-Time Chat</h1>
        <div className="flex items-center gap-4">
          <NotificationBell />
          <span className="text-sm text-gray-500">
            {isConnected ? '🟢 Online' : '🔴 Offline'}
          </span>
        </div>
      </div>

      <div className="grid grid-cols-4 gap-4">
        <div className="col-span-1">
          <OnlineUsersList />
        </div>
        <div className="col-span-3 h-[600px]">
          <ChatRoom roomId="room-1" />
        </div>
      </div>
    </div>
  );
}
```

### Step 2: Manual Testing

1. **Connection**: Open page → should connect to WebSocket
2. **Sending messages**: Type and send → message appears locally and via WebSocket
3. **Receiving messages**: Open another tab → messages appear in both
4. **Typing indicators**: Start typing → "is typing..." appears
5. **Notifications**: Send/receive → notification bell updates
6. **Online status**: Presence updates appear in online list
7. **Read receipts**: Messages marked as read after viewing

### Step 3: Simulate Multiple Users

```javascript
// In two browser consoles, simulate different users
// Console 1
localStorage.setItem('userId', 'user-1');
// Console 2
localStorage.setItem('userId', 'user-2');
// Observe presence and messages appear in both
```

---

## Deep Dive: Optimizing Real-Time Updates

### Reducing Re-Renders

```tsx
// ❌ BAD: Subscribing to entire store
function MessageList() {
  const store = useRealTimeStore(); // Re-renders on ANY change
}

// ✅ GOOD: Subscribe only to what's needed
function MessageList({ roomId }: { roomId: string }) {
  const messages = useRealTimeStore((state) => state.getRoomMessages(roomId));
  // Only re-renders when messages for this room change
}
```

### Virtualized Message List

```tsx
import { FixedSizeList as List } from 'react-window';

function VirtualizedMessageList({ messages }: { messages: Message[] }) {
  const Row = ({ index, style }: { index: number; style: React.CSSProperties }) => (
    <div style={style}>
      <MessageItem message={messages[index]} />
    </div>
  );

  return (
    <List
      height={500}
      itemCount={messages.length}
      itemSize={80}
      width="100%"
    >
      {Row}
    </List>
  );
}
```

### Batched Updates

```typescript
// Batch multiple incoming messages
let messageBatch: Message[] = [];
let batchTimer: NodeJS.Timeout | null = null;

function handleBatchMessage(message: Message) {
  messageBatch.push(message);
  if (!batchTimer) {
    batchTimer = setTimeout(() => {
      for (const msg of messageBatch) {
        useRealTimeStore.getState().addMessage(msg);
      }
      messageBatch = [];
      batchTimer = null;
    }, 100);
  }
}
```

---

## Common Pitfalls and Solutions

### Pitfall 1: Not Reconnecting After Network Drop

```typescript
// ❌ BAD: No reconnect logic
ws.onclose = () => {
  console.log('Disconnected');
};

// ✅ GOOD: Implement reconnect with exponential backoff (already in service)
```

### Pitfall 2: Duplicate Messages

```typescript
// ❌ BAD: Adding duplicate messages
addMessage: (message) => {
  set((state) => {
    state.messages[message.id] = message;
  });
}

// ✅ GOOD: Check for duplicates
addMessage: (message) => {
  set((state) => {
    if (state.messages[message.id]) return;
    state.messages[message.id] = message;
  });
}
```

### Pitfall 3: Memory Leaks with Large Message History

```typescript
// ❌ BAD: Storing unlimited messages
// messages keep growing

// ✅ GOOD: Limit message history
addMessage: (message) => {
  set((state) => {
    state.messages[message.id] = message;
    state.messageIds.push(message.id);
    // Keep only last 1000 messages per room
    const roomId = message.metadata?.roomId;
    if (roomId) {
      const roomMessages = state.messageIds
        .filter(id => state.messages[id].metadata?.roomId === roomId);
      if (roomMessages.length > 1000) {
        const toRemove = roomMessages.slice(0, roomMessages.length - 1000);
        for (const id of toRemove) {
          delete state.messages[id];
        }
        state.messageIds = state.messageIds.filter(id => !toRemove.includes(id));
      }
    }
  });
}
```

### Pitfall 4: Not Handling Large Initial Load

```typescript
// ❌ BAD: Loading all messages at once
// Can cause performance issues

// ✅ GOOD: Paginate initial load
loadInitialMessages: async (roomId: string, limit: number = 50) => {
  const messages = await fetchMessages(roomId, { limit, before: Date.now() });
  set((state) => {
    for (const msg of messages) {
      state.messages[msg.id] = msg;
      state.messageIds.push(msg.id);
    }
  });
}
```

---

## Real-Time Application Checklist

- [ ] WebSocket connection with automatic reconnect
- [ ] Heartbeat/ping to detect stale connections
- [ ] Message sending and receiving
- [ ] Typing indicators (start/stop)
- [ ] Presence tracking (online/offline/away)
- [ ] Notifications with unread counts
- [ ] Read receipts
- [ ] Message history (with pagination)
- [ ] Optimistic updates for sent messages
- [ ] Offline message queue (send when reconnected)
- [ ] Performance optimizations (virtualization, batching)
- [ ] Connection status indicator

---

## Key Takeaways

1. **WebSocket service** – Manage connection lifecycle, reconnect, and queuing
2. **Real‑time store** – Keep all real‑time data in a dedicated Zustand store
3. **Optimistic updates** – Show messages immediately before server confirms
4. **Typing indicators** – Use debounced events to avoid spam
5. **Presence tracking** – Show who's online and their status
6. **Notifications** – Centralized management with unread counts
7. **Read receipts** – Track who has seen messages
8. **Performance** – Virtualize long lists and batch updates
9. **Pagination** – Load messages incrementally
10. **Testing** – Test with multiple tabs or browser consoles

---

## What's Next

You've built a complete real‑time system. Next, you'll learn how to test Zustand stores with unit tests, integration tests, and mocking.
