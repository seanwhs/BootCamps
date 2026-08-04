# Part 3 — Asynchronous State Management

## Section 13: Concurrency & Race Conditions

In the previous section, you learned how to handle asynchronous actions. But when multiple async operations run concurrently, they can interfere with each other, leading to race conditions, stale data, and unpredictable behavior. In this section, you'll master concurrency patterns to ensure your Zustand stores behave correctly even under heavy parallel workloads.

---

## The Target: Concurrency Mastery

By the end of this section, you'll be able to:
- Detect and prevent race conditions in Zustand stores
- Implement request deduplication to avoid redundant API calls
- Use `AbortController` to cancel stale requests
- Handle concurrent updates safely with locking and queuing
- Implement optimistic UI updates with rollback on failure

---

## The Concept: Concurrency as a Traffic Management Problem

Think of concurrent async operations like a **busy intersection**:

```
┌─────────────────────────────────────────────────────────────────┐
│                    CONCURRENCY CHALLENGES                      │
│                                                                 │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐                │
│  │ Request  │    │ Request  │    │ Request  │                │
│  │    A      │    │    B      │    │    C      │                │
│  └────┬─────┘    └────┬─────┘    └────┬─────┘                │
│       │               │               │                       │
│       ▼               ▼               ▼                       │
│  ┌─────────────────────────────────────────────┐             │
│  │            SHARED STATE                     │             │
│  │  { user: null, data: [], loading: false }   │             │
│  └─────────────────────────────────────────────┘             │
│                                                                 │
│  Problems:                                                     │
│  1. Race Conditions - Who wins?                                │
│  2. Duplicate Requests - Wasting resources                      │
│  3. Stale Responses - Outdated data overwrites fresh            │
│  4. Concurrent Updates - Inconsistent state                     │
└─────────────────────────────────────────────────────────────────┘
```

**Common Concurrency Scenarios**:

1. **Fast typing in search**: Each keystroke triggers a request, but responses may arrive out of order
2. **Multiple tabs**: Same user, same store, conflicting updates
3. **Pagination**: Rapid page changes cause multiple requests
4. **Form submissions**: Double-clicking submits multiple times
5. **WebSocket messages**: Concurrent updates from server

---

## The Implementation: Race Condition Solutions

### Step 1: Request Deduplication

Prevent duplicate requests for the same resource:

```typescript
// src/store/deduplicationStore.ts
import { create } from 'zustand';

interface DeduplicationStore {
  data: any[];
  loading: boolean;
  error: string | null;
  pendingRequests: Map<string, Promise<any>>; // Track in-flight promises
  
  fetchData: (endpoint: string) => Promise<void>;
  clearCache: () => void;
}

export const useDeduplicationStore = create<DeduplicationStore>((set, get) => ({
  data: [],
  loading: false,
  error: null,
  pendingRequests: new Map(),

  fetchData: async (endpoint: string) => {
    // 1. Check if this request is already in flight
    const pending = get().pendingRequests.get(endpoint);
    if (pending) {
      console.log(`📡 Request already in flight for ${endpoint}, waiting...`);
      await pending;
      return; // The state has been updated by the original request
    }

    // 2. Create the promise for this request
    const requestPromise = (async () => {
      // Set loading only if no data is present
      const currentData = get().data;
      if (currentData.length === 0) {
        set({ loading: true, error: null });
      }

      try {
        const response = await fetch(endpoint);
        if (!response.ok) throw new Error(`HTTP ${response.status}`);
        const data = await response.json();
        
        // Update state
        set({
          data,
          loading: false,
          error: null,
        });
      } catch (error) {
        set({
          loading: false,
          error: error instanceof Error ? error.message : 'Fetch failed',
        });
        throw error;
      } finally {
        // Remove from pending requests
        set((state) => {
          const newPending = new Map(state.pendingRequests);
          newPending.delete(endpoint);
          return { pendingRequests: newPending };
        });
      }
    })();

    // Store the promise
    set((state) => ({
      pendingRequests: new Map(state.pendingRequests).set(endpoint, requestPromise),
    }));

    // Wait for the request to complete
    await requestPromise;
  },

  clearCache: () => {
    set({ data: [], pendingRequests: new Map() });
  },
}));
```

### Step 2: Aborting Stale Requests with AbortController

When requests become outdated (e.g., search results for old query), cancel them:

```typescript
// src/store/abortableStore.ts
import { create } from 'zustand';

interface AbortableStore {
  data: any[];
  loading: boolean;
  error: string | null;
  query: string;
  abortController: AbortController | null;
  
  search: (query: string) => Promise<void>;
  cancelSearch: () => void;
  clear: () => void;
}

export const useAbortableStore = create<AbortableStore>((set, get) => ({
  data: [],
  loading: false,
  error: null,
  query: '',
  abortController: null,

  search: async (query: string) => {
    // Cancel any ongoing request
    const currentController = get().abortController;
    if (currentController) {
      currentController.abort();
      console.log(`🛑 Cancelled previous search for "${get().query}"`);
    }

    // Update query
    set({ query, loading: true, error: null });

    // Create new AbortController
    const controller = new AbortController();
    set({ abortController: controller });

    try {
      const response = await fetch(
        `https://api.example.com/search?q=${encodeURIComponent(query)}`,
        { signal: controller.signal }
      );

      if (!response.ok) {
        throw new Error(`HTTP ${response.status}`);
      }

      const data = await response.json();
      
      // Only update if this request hasn't been superseded
      // (Check if the current query still matches)
      if (get().query === query) {
        set({ data, loading: false, error: null });
        console.log(`✅ Search results for "${query}" loaded`);
      } else {
        console.log(`⏭️ Search results for "${query}" are stale, ignoring`);
      }
    } catch (error) {
      // Ignore abort errors
      if (error instanceof DOMException && error.name === 'AbortError') {
        console.log(`⏹️ Search for "${query}" was cancelled`);
        set({ loading: false });
        return;
      }
      
      // Only set error if this is the current query
      if (get().query === query) {
        set({
          loading: false,
          error: error instanceof Error ? error.message : 'Search failed',
        });
      }
    } finally {
      // Clear abort controller if it's still the same one
      if (get().abortController === controller) {
        set({ abortController: null });
      }
    }
  },

  cancelSearch: () => {
    const controller = get().abortController;
    if (controller) {
      controller.abort();
      set({ abortController: null, loading: false });
    }
  },

  clear: () => {
    const controller = get().abortController;
    if (controller) {
      controller.abort();
    }
    set({
      data: [],
      loading: false,
      error: null,
      query: '',
      abortController: null,
    });
  },
}));
```

### Step 3: Race Condition Detection and Prevention

When multiple async operations update the same state, ensure the correct one wins:

```typescript
// src/store/raceConditionStore.ts
import { create } from 'zustand';

interface RaceStore {
  user: any | null;
  loading: boolean;
  error: string | null;
  lastRequestId: string | null;
  
  fetchUser: (userId: number) => Promise<void>;
  updateUser: (userId: number, updates: any) => Promise<void>;
  reset: () => void;
}

export const useRaceStore = create<RaceStore>((set, get) => ({
  user: null,
  loading: false,
  error: null,
  lastRequestId: null,

  fetchUser: async (userId: number) => {
    // Generate a unique request ID
    const requestId = `req-${userId}-${Date.now()}-${Math.random().toString(36).slice(2, 7)}`;
    set({ lastRequestId: requestId, loading: true, error: null });

    try {
      const response = await fetch(`/api/users/${userId}`);
      if (!response.ok) throw new Error(`HTTP ${response.status}`);
      const user = await response.json();

      // Only update if this is the latest request
      set((state) => {
        if (state.lastRequestId !== requestId) {
          console.log(`⏭️ Stale response for user ${userId} ignored`);
          return state;
        }
        return {
          user,
          loading: false,
          error: null,
          lastRequestId: requestId,
        };
      });
    } catch (error) {
      set((state) => {
        if (state.lastRequestId !== requestId) {
          return state;
        }
        return {
          loading: false,
          error: error instanceof Error ? error.message : 'Fetch failed',
          lastRequestId: requestId,
        };
      });
    }
  },

  // Example of concurrent updates with version checking
  updateUser: async (userId: number, updates: any) => {
    const currentUser = get().user;
    if (!currentUser || currentUser.id !== userId) {
      throw new Error('User not loaded');
    }

    // Optimistic update with version
    const version = currentUser.version || 0;
    const newVersion = version + 1;

    // Store the version we're updating from
    const updateId = `update-${userId}-${Date.now()}`;
    set({ lastRequestId: updateId });

    // Optimistic update
    set({
      user: {
        ...currentUser,
        ...updates,
        version: newVersion,
        optimistic: true,
      },
    });

    try {
      const response = await fetch(`/api/users/${userId}`, {
        method: 'PUT',
        body: JSON.stringify({ ...updates, version: version }),
        headers: { 'Content-Type': 'application/json' },
      });

      if (!response.ok) {
        if (response.status === 409) {
          // Conflict - someone else updated the user
          throw new Error('User was updated by another request');
        }
        throw new Error(`HTTP ${response.status}`);
      }

      const updatedUser = await response.json();

      // Apply server response
      set((state) => {
        if (state.lastRequestId !== updateId) {
          return state;
        }
        return {
          user: { ...updatedUser, optimistic: false },
          lastRequestId: updateId,
        };
      });
    } catch (error) {
      // Rollback on error
      set((state) => {
        if (state.lastRequestId !== updateId) {
          return state;
        }
        // Revert to the version before optimistic update
        return {
          user: currentUser,
          lastRequestId: updateId,
          error: error instanceof Error ? error.message : 'Update failed',
        };
      });
      throw error;
    }
  },

  reset: () => {
    set({ user: null, loading: false, error: null, lastRequestId: null });
  },
}));
```

### Step 4: Concurrent Updates with Queueing

When many updates arrive rapidly, queue them to process sequentially:

```typescript
// src/store/queueStore.ts
import { create } from 'zustand';

interface QueueItem {
  id: string;
  action: () => Promise<void>;
  resolve: (value: void) => void;
  reject: (error: any) => void;
}

interface QueueStore {
  data: any[];
  isProcessing: boolean;
  queue: QueueItem[];
  
  enqueueUpdate: (updateFn: () => Promise<void>) => Promise<void>;
  processQueue: () => Promise<void>;
  clear: () => void;
}

export const useQueueStore = create<QueueStore>((set, get) => ({
  data: [],
  isProcessing: false,
  queue: [],

  enqueueUpdate: (updateFn: () => Promise<void>) => {
    return new Promise((resolve, reject) => {
      const item: QueueItem = {
        id: `queue-${Date.now()}-${Math.random().toString(36).slice(2, 7)}`,
        action: updateFn,
        resolve,
        reject,
      };

      set((state) => ({
        queue: [...state.queue, item],
      }));

      // Start processing if not already
      if (!get().isProcessing) {
        get().processQueue();
      }
    });
  },

  processQueue: async () => {
    const { queue, isProcessing } = get();
    if (isProcessing || queue.length === 0) return;

    set({ isProcessing: true });

    while (get().queue.length > 0) {
      const item = get().queue[0];
      
      try {
        await item.action();
        item.resolve();
      } catch (error) {
        item.reject(error);
      }

      // Remove processed item
      set((state) => ({
        queue: state.queue.slice(1),
      }));
    }

    set({ isProcessing: false });
  },

  clear: () => {
    // Reject all pending items
    const queue = get().queue;
    queue.forEach(item => {
      item.reject(new Error('Queue cleared'));
    });
    set({ queue: [], isProcessing: false });
  },
}));

// Example usage in a component:
// const { enqueueUpdate } = useQueueStore();
// await enqueueUpdate(async () => {
//   // This update will be processed sequentially
//   set((state) => ({ data: [...state.data, newItem] }));
// });
```

### Step 5: Optimistic UI Updates with Rollback

A common pattern for a great UX:

```typescript
// src/store/optimisticStore.ts
import { create } from 'zustand';

interface OptimisticStore {
  items: any[];
  pendingActions: Map<string, { type: string; data: any }>;
  error: string | null;
  
  addItem: (item: any) => Promise<void>;
  deleteItem: (id: string) => Promise<void>;
  updateItem: (id: string, updates: any) => Promise<void>;
  rollback: (actionId: string) => void;
  clear: () => void;
}

export const useOptimisticStore = create<OptimisticStore>((set, get) => ({
  items: [],
  pendingActions: new Map(),
  error: null,

  addItem: async (item: any) => {
    const actionId = `add-${Date.now()}-${Math.random().toString(36).slice(2, 7)}`;
    
    // Optimistic: Add immediately
    set((state) => ({
      items: [...state.items, { ...item, id: actionId, optimistic: true }],
      pendingActions: new Map(state.pendingActions).set(actionId, {
        type: 'add',
        data: item,
      }),
      error: null,
    }));

    try {
      // Simulate API call
      const response = await fetch('/api/items', {
        method: 'POST',
        body: JSON.stringify(item),
      });
      
      if (!response.ok) throw new Error('Failed to save');
      
      const savedItem = await response.json();
      
      // Replace optimistic with real
      set((state) => {
        const newItems = state.items.map((i) =>
          i.id === actionId ? { ...savedItem, optimistic: false } : i
        );
        const newPending = new Map(state.pendingActions);
        newPending.delete(actionId);
        return {
          items: newItems,
          pendingActions: newPending,
        };
      });
    } catch (error) {
      // Rollback: Remove the optimistic item
      set((state) => {
        const newItems = state.items.filter((i) => i.id !== actionId);
        const newPending = new Map(state.pendingActions);
        newPending.delete(actionId);
        return {
          items: newItems,
          pendingActions: newPending,
          error: error instanceof Error ? error.message : 'Failed to add item',
        };
      });
      throw error;
    }
  },

  deleteItem: async (id: string) => {
    const actionId = `delete-${id}-${Date.now()}`;
    const itemToDelete = get().items.find((i) => i.id === id);
    if (!itemToDelete) return;

    // Optimistic: Remove immediately
    set((state) => ({
      items: state.items.filter((i) => i.id !== id),
      pendingActions: new Map(state.pendingActions).set(actionId, {
        type: 'delete',
        data: itemToDelete,
      }),
      error: null,
    }));

    try {
      const response = await fetch(`/api/items/${id}`, {
        method: 'DELETE',
      });
      
      if (!response.ok) throw new Error('Failed to delete');
      
      // Success: Remove from pending
      set((state) => {
        const newPending = new Map(state.pendingActions);
        newPending.delete(actionId);
        return { pendingActions: newPending };
      });
    } catch (error) {
      // Rollback: Restore the item
      set((state) => ({
        items: [...state.items, itemToDelete],
        pendingActions: new Map(state.pendingActions),
        error: error instanceof Error ? error.message : 'Failed to delete item',
      }));
      throw error;
    }
  },

  updateItem: async (id: string, updates: any) => {
    const actionId = `update-${id}-${Date.now()}`;
    const currentItem = get().items.find((i) => i.id === id);
    if (!currentItem) return;

    // Optimistic: Apply updates
    set((state) => ({
      items: state.items.map((i) =>
        i.id === id ? { ...i, ...updates, optimistic: true } : i
      ),
      pendingActions: new Map(state.pendingActions).set(actionId, {
        type: 'update',
        data: { ...currentItem, ...updates },
      }),
      error: null,
    }));

    try {
      const response = await fetch(`/api/items/${id}`, {
        method: 'PUT',
        body: JSON.stringify({ ...currentItem, ...updates }),
      });
      
      if (!response.ok) throw new Error('Failed to update');
      
      const updatedItem = await response.json();
      
      set((state) => {
        const newItems = state.items.map((i) =>
          i.id === id ? { ...updatedItem, optimistic: false } : i
        );
        const newPending = new Map(state.pendingActions);
        newPending.delete(actionId);
        return {
          items: newItems,
          pendingActions: newPending,
        };
      });
    } catch (error) {
      // Rollback: Revert the item
      set((state) => {
        const newItems = state.items.map((i) =>
          i.id === id ? currentItem : i
        );
        const newPending = new Map(state.pendingActions);
        newPending.delete(actionId);
        return {
          items: newItems,
          pendingActions: newPending,
          error: error instanceof Error ? error.message : 'Failed to update item',
        };
      });
      throw error;
    }
  },

  rollback: (actionId: string) => {
    const action = get().pendingActions.get(actionId);
    if (!action) return;

    // Revert based on action type
    switch (action.type) {
      case 'add':
        set((state) => ({
          items: state.items.filter((i) => i.id !== actionId),
          pendingActions: new Map(state.pendingActions),
        }));
        break;
      case 'delete':
        set((state) => ({
          items: [...state.items, action.data],
          pendingActions: new Map(state.pendingActions),
        }));
        break;
      case 'update':
        set((state) => ({
          items: state.items.map((i) =>
            i.id === actionId ? action.data : i
          ),
          pendingActions: new Map(state.pendingActions),
        }));
        break;
    }
  },

  clear: () => {
    set({ items: [], pendingActions: new Map(), error: null });
  },
}));
```

### Step 6: WebSocket Concurrency Management

Handling real-time updates from WebSockets:

```typescript
// src/store/websocketStore.ts
import { create } from 'zustand';

interface WebSocketStore {
  messages: any[];
  online: boolean;
  lastMessageId: string | null;
  pendingCount: number;
  
  connect: (url: string) => void;
  disconnect: () => void;
  sendMessage: (message: any) => void;
  handleIncomingMessage: (message: any) => void;
  setOnline: (online: boolean) => void;
  clear: () => void;
}

export const useWebSocketStore = create<WebSocketStore>((set, get) => ({
  messages: [],
  online: false,
  lastMessageId: null,
  pendingCount: 0,

  connect: (url: string) => {
    const ws = new WebSocket(url);
    
    ws.onopen = () => {
      set({ online: true });
      console.log('🔌 WebSocket connected');
    };

    ws.onmessage = (event) => {
      const message = JSON.parse(event.data);
      get().handleIncomingMessage(message);
    };

    ws.onclose = () => {
      set({ online: false });
      console.log('🔌 WebSocket disconnected');
      // Implement reconnect logic
    };

    ws.onerror = (error) => {
      console.error('WebSocket error:', error);
    };

    // Store WebSocket instance for later use
    window.__ws = ws;
  },

  disconnect: () => {
    if (window.__ws) {
      window.__ws.close();
      window.__ws = null;
      set({ online: false });
    }
  },

  sendMessage: (message: any) => {
    if (!get().online) {
      console.warn('Cannot send message: WebSocket not connected');
      return;
    }
    
    const ws = window.__ws;
    if (ws) {
      ws.send(JSON.stringify(message));
      // Optimistic: Add message locally
      set((state) => ({
        messages: [...state.messages, { ...message, local: true, optimistic: true }],
        pendingCount: state.pendingCount + 1,
      }));
    }
  },

  handleIncomingMessage: (message: any) => {
    // Validate message
    if (!message.id) {
      console.warn('Received message without ID:', message);
      return;
    }

    // Avoid duplicate messages
    set((state) => {
      const exists = state.messages.some((m) => m.id === message.id);
      if (exists) {
        console.log(`🔄 Duplicate message ${message.id} ignored`);
        return state;
      }

      // Replace optimistic local message if it exists
      const hasOptimistic = state.messages.some(
        (m) => m.local && m.id === message.id
      );

      let newMessages;
      if (hasOptimistic) {
        newMessages = state.messages.map((m) =>
          m.local && m.id === message.id
            ? { ...message, local: false, optimistic: false }
            : m
        );
      } else {
        newMessages = [...state.messages, message];
      }

      return {
        messages: newMessages,
        lastMessageId: message.id,
        pendingCount: state.pendingCount - (hasOptimistic ? 1 : 0),
      };
    });
  },

  setOnline: (online: boolean) => {
    set({ online });
  },

  clear: () => {
    set({ messages: [], online: false, lastMessageId: null, pendingCount: 0 });
    if (window.__ws) {
      window.__ws.close();
      window.__ws = null;
    }
  },
}));
```

---

## The Verification: Testing Concurrency

### Step 1: Create a Test Component for Race Conditions

```tsx
// src/components/RaceTest.tsx
import React, { useState } from 'react';
import { useAbortableStore } from '../store/abortableStore';

function RaceTest() {
  const { data, loading, error, query, search, cancelSearch, clear } = useAbortableStore();
  const [input, setInput] = useState('');

  const handleSearch = () => {
    search(input);
  };

  return (
    <div style={{ padding: '20px' }}>
      <h2>Race Condition Test</h2>
      <div>
        <input
          type="text"
          value={input}
          onChange={(e) => setInput(e.target.value)}
          placeholder="Search..."
        />
        <button onClick={handleSearch}>Search</button>
        <button onClick={cancelSearch}>Cancel</button>
        <button onClick={clear}>Clear</button>
      </div>
      <div>
        {loading && <div>Loading...</div>}
        {error && <div style={{ color: 'red' }}>Error: {error}</div>}
        {query && <div>Current query: {query}</div>}
        {data.length > 0 && (
          <div>
            <h3>Results ({data.length})</h3>
            <pre>{JSON.stringify(data.slice(0, 3), null, 2)}</pre>
          </div>
        )}
      </div>
    </div>
  );
}

export default RaceTest;
```

### Step 2: Simulate Race Conditions

```typescript
// src/tests/raceSimulation.ts
import { useAbortableStore } from '../store/abortableStore';

async function simulateRace() {
  console.log('=== Simulating Race Conditions ===');
  
  const store = useAbortableStore.getState();
  
  // Trigger multiple searches rapidly
  console.log('🔍 Searching "react"...');
  store.search('react');
  
  await new Promise(resolve => setTimeout(resolve, 100));
  
  console.log('🔍 Searching "vue"...');
  store.search('vue');
  
  await new Promise(resolve => setTimeout(resolve, 200));
  
  console.log('🔍 Searching "angular"...');
  store.search('angular');
  
  // After all requests, check final state
  await new Promise(resolve => setTimeout(resolve, 2000));
  console.log('📊 Final state:', useAbortableStore.getState());
  // Expected: Only the last search result should be stored
}

// Run the simulation
simulateRace();
```

### Step 3: Verify Request Deduplication

```typescript
// src/tests/deduplicationTest.ts
import { useDeduplicationStore } from '../store/deduplicationStore';

async function testDeduplication() {
  console.log('=== Testing Request Deduplication ===');
  
  const store = useDeduplicationStore.getState();
  
  // Trigger three identical requests almost simultaneously
  console.log('📡 Request 1');
  store.fetchData('/api/posts');
  
  await new Promise(resolve => setTimeout(resolve, 50));
  
  console.log('📡 Request 2');
  store.fetchData('/api/posts');
  
  await new Promise(resolve => setTimeout(resolve, 50));
  
  console.log('📡 Request 3');
  store.fetchData('/api/posts');
  
  // Wait for completion
  await new Promise(resolve => setTimeout(resolve, 2000));
  
  console.log('📊 Final state:', useDeduplicationStore.getState());
  // Expected: Only one actual network request, state updated once
}

testDeduplication();
```

### Step 4: Browser Console Test

Open your browser console and run:

```javascript
import { useAbortableStore } from './src/store/abortableStore';

// Simulate fast typing
const store = useAbortableStore.getState();
store.search('a');
setTimeout(() => store.search('ap'), 100);
setTimeout(() => store.search('app'), 200);
setTimeout(() => store.search('appl'), 300);
setTimeout(() => store.search('apple'), 400);

// Observe console: older requests get aborted, only "apple" completes
```

---

## Deep Dive: Concurrency Patterns

### Pattern 1: Debounced Search (Throttling)

```typescript
// src/store/debounceStore.ts
import { create } from 'zustand';

export const useDebounceStore = create((set, get) => ({
  query: '',
  results: [],
  loading: false,
  error: null,
  timer: null as ReturnType<typeof setTimeout> | null,

  setQuery: (query: string) => {
    const timer = get().timer;
    if (timer) clearTimeout(timer);

    set({ query, loading: true });

    const newTimer = setTimeout(async () => {
      try {
        const response = await fetch(`/api/search?q=${query}`);
        const data = await response.json();
        set({ results: data, loading: false });
      } catch (error) {
        set({ error: error.message, loading: false });
      }
    }, 300);

    set({ timer: newTimer });
  },
}));
```

### Pattern 2: Concurrent Request Limit (Semaphore)

```typescript
// src/store/semaphoreStore.ts
import { create } from 'zustand';

class Semaphore {
  private maxConcurrent: number;
  private currentCount: number = 0;
  private queue: Array<() => void> = [];

  constructor(maxConcurrent: number) {
    this.maxConcurrent = maxConcurrent;
  }

  async acquire(): Promise<void> {
    if (this.currentCount < this.maxConcurrent) {
      this.currentCount++;
      return;
    }
    return new Promise((resolve) => {
      this.queue.push(resolve);
    });
  }

  release(): void {
    if (this.queue.length > 0) {
      const next = this.queue.shift();
      if (next) next();
    } else {
      this.currentCount--;
    }
  }
}

// Usage in store
export const useSemaphoreStore = create((set, get) => ({
  data: [],
  loading: false,
  semaphore: new Semaphore(3), // Limit to 3 concurrent requests

  fetchItems: async (urls: string[]) => {
    const semaphore = get().semaphore;
    const results = [];

    for (const url of urls) {
      await semaphore.acquire();
      try {
        const response = await fetch(url);
        const data = await response.json();
        results.push(data);
        set((state) => ({ data: [...state.data, data] }));
      } finally {
        semaphore.release();
      }
    }
    return results;
  },
}));
```

---

## Common Pitfalls and Solutions

### Pitfall 1: Not Handling Abort Errors

```typescript
// ❌ BAD: Abort errors treated as normal errors
try {
  await fetch(url, { signal: controller.signal });
} catch (error) {
  set({ error: error.message }); // Shows "The user aborted a request"
}

// ✅ GOOD: Handle abort separately
try {
  await fetch(url, { signal: controller.signal });
} catch (error) {
  if (error instanceof DOMException && error.name === 'AbortError') {
    console.log('Request aborted');
    return;
  }
  set({ error: error.message });
}
```

### Pitfall 2: Not Checking Request Freshness

```typescript
// ❌ BAD: Updates state even if request is stale
const response = await fetch(`/user/${userId}`);
const user = await response.json();
set({ user }); // Could be stale if userId changed

// ✅ GOOD: Check request ID
const requestId = Date.now() + Math.random();
set({ requestId });
const response = await fetch(`/user/${userId}`);
const user = await response.json();
set((state) => {
  if (state.requestId !== requestId) return state;
  return { user };
});
```

### Pitfall 3: Over-Optimistic Updates

```typescript
// ❌ BAD: Optimistic updates without rollback
set({ items: [...items, newItem] });
// If API fails, item stays in UI

// ✅ GOOD: Optimistic with rollback
const newItems = [...items, newItem];
set({ items: newItems });
try {
  await saveItem(newItem);
} catch {
  set({ items }); // Rollback
}
```

---

## Key Takeaways

1. **Race conditions are common**: Always consider concurrent operations
2. **Use AbortController** to cancel stale requests
3. **Request deduplication** prevents redundant API calls
4. **Track request IDs** to ignore stale responses
5. **Queue updates** when order matters
6. **Optimistic updates** improve UX but require rollback
7. **Semaphores** limit concurrent requests
8. **Debouncing** prevents rapid-fire requests
9. **WebSocket concurrency** needs careful handling
10. **Test concurrency** scenarios thoroughly

---

## What's Next

You've mastered async actions and concurrency. Next, you'll learn how to work with external APIs including REST, GraphQL, WebSockets, and more.
