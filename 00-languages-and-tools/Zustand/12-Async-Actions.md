# Part 3 — Asynchronous State Management

## Section 12: Async Actions

You've mastered synchronous state management. But real-world applications are asynchronous—they fetch data from APIs, handle user interactions, and perform background tasks. Zustand makes async workflows simple and predictable. In this section, you'll learn how to handle asynchronous actions with confidence.

---

## The Target: Async State Management Mastery

By the end of this section, you'll be able to:
- Implement async actions in Zustand stores
- Handle loading, success, and error states cleanly
- Manage multiple concurrent requests
- Implement retry mechanisms and cancellation
- Build real-world async features (search, infinite scroll, pagination)

---

## The Concept: Async Actions as State Transitions

Think of async actions like a **restaurant order process**:

```
┌─────────────────────────────────────────────────────────────────┐
│                    ASYNC ACTION LIFECYCLE                      │
│                                                                 │
│  1. Place Order (Start)   ───▶  State: 'loading'               │
│         │                                                      │
│         ▼                                                      │
│  2. Kitchen Prep (In Progress) ───▶  State: 'loading'          │
│         │                                                      │
│         ▼                                                      │
│  3. Order Ready (Success)   ───▶  State: 'succeeded'           │
│         │                     ───▶  Data: order details        │
│         │                                                      │
│         OR                                                     │
│         │                                                      │
│  4. Order Failed (Error)   ───▶  State: 'failed'              │
│                              ───▶  Error: 'Out of stock'      │
└─────────────────────────────────────────────────────────────────┘
```

Every async action follows this pattern:
1. **Initiate**: Set loading state to true
2. **Execute**: Perform the async operation (fetch, save, etc.)
3. **Success**: Update state with result, set loading false
4. **Failure**: Update state with error, set loading false

---

## The Implementation: Async Actions

### Step 1: Basic Async Action (Data Fetching)

Let's build a store that fetches posts from an API:

```typescript
// src/store/asyncStore.ts
import { create } from 'zustand';

// Types
interface Post {
  id: number;
  title: string;
  body: string;
  userId: number;
}

interface AsyncStore {
  // State
  posts: Post[];
  loading: boolean;
  error: string | null;
  
  // Actions
  fetchPosts: () => Promise<void>;
  clearPosts: () => void;
  clearError: () => void;
}

// Create the store
export const useAsyncStore = create<AsyncStore>((set, get) => ({
  // Initial state
  posts: [],
  loading: false,
  error: null,

  // --- Fetch Posts (Basic Async Action) ---
  fetchPosts: async () => {
    // 1. Set loading state
    set({ loading: true, error: null });
    
    try {
      // 2. Perform the async operation
      const response = await fetch('https://jsonplaceholder.typicode.com/posts');
      
      // 3. Check response
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }
      
      const data: Post[] = await response.json();
      
      // 4. Update with success
      set({
        posts: data,
        loading: false,
        error: null,
      });
    } catch (error) {
      // 5. Update with error
      set({
        loading: false,
        error: error instanceof Error ? error.message : 'Failed to fetch posts',
      });
    }
  },

  // --- Clear posts ---
  clearPosts: () => {
    set({ posts: [], error: null });
  },

  // --- Clear error ---
  clearError: () => {
    set({ error: null });
  },
}));
```

### Step 2: Async Action with Parameters

Often you need to pass parameters to your async actions:

```typescript
// src/store/parameterizedAsyncStore.ts
import { create } from 'zustand';

interface UserStore {
  // State
  users: Record<number, User>;
  userLoading: Record<number, boolean>;
  userErrors: Record<number, string | null>;
  
  // Actions
  fetchUser: (userId: number) => Promise<void>;
  fetchUsers: (userIds: number[]) => Promise<void>;
  clearUser: (userId: number) => void;
}

export const useUserStore = create<UserStore>((set, get) => ({
  users: {},
  userLoading: {},
  userErrors: {},

  // Fetch a single user
  fetchUser: async (userId: number) => {
    // Set loading for this specific user
    set((state) => ({
      userLoading: { ...state.userLoading, [userId]: true },
      userErrors: { ...state.userErrors, [userId]: null },
    }));

    try {
      const response = await fetch(
        `https://jsonplaceholder.typicode.com/users/${userId}`
      );
      
      if (!response.ok) {
        throw new Error(`HTTP ${response.status}`);
      }
      
      const user: User = await response.json();
      
      set((state) => ({
        users: { ...state.users, [userId]: user },
        userLoading: { ...state.userLoading, [userId]: false },
        userErrors: { ...state.userErrors, [userId]: null },
      }));
    } catch (error) {
      set((state) => ({
        userLoading: { ...state.userLoading, [userId]: false },
        userErrors: {
          ...state.userErrors,
          [userId]: error instanceof Error ? error.message : 'Failed to fetch user',
        },
      }));
    }
  },

  // Fetch multiple users
  fetchUsers: async (userIds: number[]) => {
    // Set loading for all
    const loadingUpdates = userIds.reduce((acc, id) => {
      acc[id] = true;
      return acc;
    }, {} as Record<number, boolean>);
    
    set((state) => ({
      userLoading: { ...state.userLoading, ...loadingUpdates },
    }));

    // Fetch in parallel
    const promises = userIds.map(id =>
      fetch(`https://jsonplaceholder.typicode.com/users/${id}`)
        .then(res => res.json())
        .catch(err => ({ error: err.message, id }))
    );

    const results = await Promise.all(promises);
    
    // Update state with results
    set((state) => {
      const newUsers = { ...state.users };
      const newLoading = { ...state.userLoading };
      const newErrors = { ...state.userErrors };

      results.forEach((result, index) => {
        const id = userIds[index];
        if (result.error) {
          newErrors[id] = result.error;
        } else {
          newUsers[id] = result;
          newErrors[id] = null;
        }
        newLoading[id] = false;
      });

      return {
        users: newUsers,
        userLoading: newLoading,
        userErrors: newErrors,
      };
    });
  },

  clearUser: (userId: number) => {
    set((state) => {
      const { [userId]: _, ...remainingUsers } = state.users;
      const { [userId]: __, ...remainingLoading } = state.userLoading;
      const { [userId]: ___, ...remainingErrors } = state.userErrors;
      
      return {
        users: remainingUsers,
        userLoading: remainingLoading,
        userErrors: remainingErrors,
      };
    });
  },
}));
```

### Step 3: Async Actions with Retry Mechanism

Networks fail. Implement retry logic:

```typescript
// src/store/retryStore.ts
import { create } from 'zustand';

interface RetryStore {
  data: any[];
  loading: boolean;
  error: string | null;
  retryCount: number;
  
  fetchWithRetry: (url: string, maxRetries?: number, delay?: number) => Promise<void>;
  reset: () => void;
}

export const useRetryStore = create<RetryStore>((set, get) => ({
  data: [],
  loading: false,
  error: null,
  retryCount: 0,

  fetchWithRetry: async (
    url: string,
    maxRetries: number = 3,
    delay: number = 1000
  ) => {
    set({ loading: true, error: null, retryCount: 0 });

    let attempt = 0;
    let lastError: Error | null = null;

    while (attempt < maxRetries) {
      try {
        const response = await fetch(url);
        
        if (!response.ok) {
          throw new Error(`HTTP ${response.status}`);
        }
        
        const data = await response.json();
        
        // Success!
        set({
          data,
          loading: false,
          error: null,
          retryCount: attempt + 1,
        });
        return;

      } catch (error) {
        lastError = error instanceof Error ? error : new Error('Unknown error');
        attempt++;
        
        // Update retry count
        set({ retryCount: attempt });
        
        // If we've exhausted retries, break
        if (attempt >= maxRetries) {
          break;
        }
        
        // Wait before retrying (with exponential backoff)
        const backoffDelay = delay * Math.pow(2, attempt - 1);
        console.warn(`Retry ${attempt} failed, retrying in ${backoffDelay}ms...`);
        await new Promise(resolve => setTimeout(resolve, backoffDelay));
      }
    }

    // All retries failed
    set({
      loading: false,
      error: lastError?.message || 'Failed after multiple retries',
      retryCount: attempt,
    });
  },

  reset: () => {
    set({ data: [], loading: false, error: null, retryCount: 0 });
  },
}));
```

### Step 4: Async Actions with Cancellation (AbortController)

Cancel in-flight requests to avoid race conditions and save bandwidth:

```typescript
// src/store/cancelableStore.ts
import { create } from 'zustand';

interface CancelableStore {
  data: any[];
  loading: boolean;
  error: string | null;
  abortController: AbortController | null;
  
  fetchWithCancel: (url: string) => Promise<void>;
  cancelFetch: () => void;
  reset: () => void;
}

export const useCancelableStore = create<CancelableStore>((set, get) => ({
  data: [],
  loading: false,
  error: null,
  abortController: null,

  fetchWithCancel: async (url: string) => {
    // Cancel any previous request
    const currentController = get().abortController;
    if (currentController) {
      currentController.abort();
    }

    // Create new AbortController
    const controller = new AbortController();
    set({ abortController: controller, loading: true, error: null });

    try {
      const response = await fetch(url, {
        signal: controller.signal,
      });

      if (!response.ok) {
        throw new Error(`HTTP ${response.status}`);
      }

      const data = await response.json();
      
      set({
        data,
        loading: false,
        error: null,
        abortController: null,
      });
    } catch (error) {
      // Check if it was aborted
      if (error instanceof DOMException && error.name === 'AbortError') {
        console.log('Request was cancelled');
        set({ loading: false, abortController: null });
        return;
      }
      
      set({
        loading: false,
        error: error instanceof Error ? error.message : 'Fetch failed',
        abortController: null,
      });
    }
  },

  cancelFetch: () => {
    const controller = get().abortController;
    if (controller) {
      controller.abort();
      set({ abortController: null, loading: false });
    }
  },

  reset: () => {
    const controller = get().abortController;
    if (controller) {
      controller.abort();
    }
    set({
      data: [],
      loading: false,
      error: null,
      abortController: null,
    });
  },
}));
```

### Step 5: Async Actions with Loading States and Progress

Show progress for long-running operations:

```typescript
// src/store/progressStore.ts
import { create } from 'zustand';

interface ProgressStore {
  data: any[];
  loading: boolean;
  progress: number; // 0-100
  error: string | null;
  
  uploadFile: (file: File, url: string) => Promise<void>;
  reset: () => void;
}

export const useProgressStore = create<ProgressStore>((set, get) => ({
  data: [],
  loading: false,
  progress: 0,
  error: null,

  uploadFile: async (file: File, url: string) => {
    set({ loading: true, progress: 0, error: null });

    try {
      const formData = new FormData();
      formData.append('file', file);

      // Use XMLHttpRequest for progress tracking
      return new Promise((resolve, reject) => {
        const xhr = new XMLHttpRequest();
        
        xhr.upload.addEventListener('progress', (event) => {
          if (event.lengthComputable) {
            const percentComplete = Math.round((event.loaded / event.total) * 100);
            set({ progress: percentComplete });
          }
        });

        xhr.addEventListener('load', () => {
          if (xhr.status >= 200 && xhr.status < 300) {
            const result = JSON.parse(xhr.responseText);
            set({
              data: [result],
              loading: false,
              progress: 100,
              error: null,
            });
            resolve(result);
          } else {
            const error = new Error(`HTTP ${xhr.status}`);
            set({
              loading: false,
              error: error.message,
            });
            reject(error);
          }
        });

        xhr.addEventListener('error', () => {
          const error = new Error('Network error');
          set({ loading: false, error: error.message });
          reject(error);
        });

        xhr.open('POST', url);
        xhr.send(formData);
      });
    } catch (error) {
      set({
        loading: false,
        error: error instanceof Error ? error.message : 'Upload failed',
      });
    }
  },

  reset: () => {
    set({ data: [], loading: false, progress: 0, error: null });
  },
}));
```

### Step 6: Async Actions in React Components

Let's connect async stores to React components:

```tsx
// src/components/AsyncComponent.tsx
import React, { useEffect, useState } from 'react';
import { useAsyncStore } from '../store/asyncStore';

function AsyncComponent() {
  const { posts, loading, error, fetchPosts, clearPosts, clearError } = useAsyncStore();
  const [refreshing, setRefreshing] = useState(false);

  // Fetch on mount
  useEffect(() => {
    fetchPosts();
    return () => {
      // Cleanup if needed
      clearPosts();
    };
  }, []);

  // Handle refresh
  const handleRefresh = async () => {
    setRefreshing(true);
    await fetchPosts();
    setRefreshing(false);
  };

  if (loading && posts.length === 0) {
    return <div>Loading posts...</div>;
  }

  if (error) {
    return (
      <div>
        <div style={{ color: 'red' }}>Error: {error}</div>
        <button onClick={fetchPosts}>Retry</button>
        <button onClick={clearError}>Clear Error</button>
      </div>
    );
  }

  return (
    <div>
      <div style={{ display: 'flex', gap: '10px', marginBottom: '20px' }}>
        <button onClick={handleRefresh} disabled={refreshing}>
          {refreshing ? 'Refreshing...' : 'Refresh'}
        </button>
        <button onClick={clearPosts}>Clear Posts</button>
      </div>
      
      <div>
        {posts.length === 0 ? (
          <p>No posts found.</p>
        ) : (
          <ul>
            {posts.slice(0, 10).map((post) => (
              <li key={post.id}>
                <h3>{post.title}</h3>
                <p>{post.body}</p>
              </li>
            ))}
          </ul>
        )}
      </div>
    </div>
  );
}

export default AsyncComponent;
```

---

## The Verification: Testing Async Actions

### Step 1: Create a Test Component

```tsx
// src/App.tsx
import React from 'react';
import AsyncComponent from './components/AsyncComponent';
import { useAsyncStore } from './store/asyncStore';

function App() {
  return (
    <div>
      <h1>Async Zustand Demo</h1>
      <AsyncComponent />
    </div>
  );
}

export default App;
```

### Step 2: Manual Testing

1. **Test Basic Fetch**:
   - Open the app
   - Should see loading, then posts
   - ✅ Posts displayed

2. **Test Error Handling**:
   - Modify the URL in `fetchPosts` to an invalid one
   - Should show error message and retry button
   - ✅ Error displayed

3. **Test Retry**:
   - Click retry after error
   - Should attempt again
   - ✅ Retry works

4. **Test Cancellation**:
   - Use the cancelable store component
   - Start a fetch, cancel mid-way
   - Should abort without error
   - ✅ Cancellation works

### Step 3: Console Debugging

```javascript
// In browser console
import { useAsyncStore } from './src/store/asyncStore';

// Subscribe to changes
const unsubscribe = useAsyncStore.subscribe((state) => {
  console.log('State changed:', {
    loading: state.loading,
    postsCount: state.posts.length,
    error: state.error,
  });
});

// Test manually
useAsyncStore.getState().fetchPosts();

// Clean up
unsubscribe();
```

### Step 4: Network Throttling Test

1. Open Chrome DevTools
2. Go to Network tab
3. Set network to "Slow 3G"
4. Trigger a fetch
5. Observe loading states, retries, etc.
6. ✅ Should handle slow networks gracefully

---

## Deep Dive: Async Action Patterns

### Pattern 1: Debounced Search

```typescript
// src/store/debouncedSearchStore.ts
import { create } from 'zustand';

export const useSearchStore = create((set, get) => ({
  query: '',
  results: [],
  loading: false,
  error: null,
  searchTimer: null as ReturnType<typeof setTimeout> | null,

  setQuery: (query: string) => {
    // Clear existing timer
    const timer = get().searchTimer;
    if (timer) {
      clearTimeout(timer);
    }

    set({ query, loading: true });

    // Debounce search
    const newTimer = setTimeout(async () => {
      try {
        const response = await fetch(
          `https://api.example.com/search?q=${encodeURIComponent(query)}`
        );
        const data = await response.json();
        set({ results: data, loading: false, error: null });
      } catch (error) {
        set({ error: error.message, loading: false });
      }
    }, 300);

    set({ searchTimer: newTimer });
  },

  clearSearch: () => {
    const timer = get().searchTimer;
    if (timer) clearTimeout(timer);
    set({ query: '', results: [], loading: false, error: null, searchTimer: null });
  },
}));
```

### Pattern 2: Pagination / Infinite Scroll

```typescript
// src/store/paginationStore.ts
import { create } from 'zustand';

export const usePaginationStore = create((set, get) => ({
  items: [],
  page: 1,
  hasMore: true,
  loading: false,
  error: null,

  fetchPage: async (page: number) => {
    set({ loading: true, error: null });
    
    try {
      const response = await fetch(
        `https://api.example.com/items?page=${page}&limit=20`
      );
      const data = await response.json();
      
      set((state) => ({
        items: page === 1 ? data.items : [...state.items, ...data.items],
        page: page,
        hasMore: data.hasMore,
        loading: false,
      }));
    } catch (error) {
      set({ error: error.message, loading: false });
    }
  },

  loadMore: async () => {
    const { page, hasMore, loading } = get();
    if (!hasMore || loading) return;
    await get().fetchPage(page + 1);
  },

  reset: () => {
    set({ items: [], page: 1, hasMore: true, loading: false, error: null });
  },
}));
```

### Pattern 3: Optimistic Updates

```typescript
// src/store/optimisticStore.ts
import { create } from 'zustand';

export const useOptimisticStore = create((set, get) => ({
  items: [],
  pendingUpdates: {} as Record<string, any>,

  addItem: async (item: any) => {
    // Optimistic: Add immediately
    set((state) => ({
      items: [...state.items, { ...item, optimistic: true }],
    }));

    try {
      // Actually save
      const response = await fetch('/api/items', {
        method: 'POST',
        body: JSON.stringify(item),
      });
      
      if (!response.ok) throw new Error('Failed to save');
      
      const savedItem = await response.json();
      
      // Replace optimistic with real
      set((state) => ({
        items: state.items.map((i) =>
          i.id === item.id ? { ...savedItem, optimistic: false } : i
        ),
      }));
    } catch (error) {
      // Rollback on failure
      set((state) => ({
        items: state.items.filter((i) => i.id !== item.id),
        error: error.message,
      }));
    }
  },
}));
```

---

## Common Pitfalls and Solutions

### Pitfall 1: Not Handling Errors

```typescript
// ❌ BAD: Swallowed errors
fetchData: async () => {
  set({ loading: true });
  const data = await fetch('/api').then(r => r.json());
  set({ data, loading: false });
}

// ✅ GOOD: Error handling
fetchData: async () => {
  set({ loading: true, error: null });
  try {
    const data = await fetch('/api').then(r => r.json());
    set({ data, loading: false });
  } catch (error) {
    set({ error: error.message, loading: false });
  }
}
```

### Pitfall 2: Race Conditions

```typescript
// ❌ BAD: Stale responses
fetchUser: async (id) => {
  const response = await fetch(`/users/${id}`);
  const user = await response.json();
  set({ user }); // If id changes mid-request, this might be stale
}

// ✅ GOOD: Track request ID
fetchUser: async (id) => {
  const requestId = Date.now() + Math.random();
  set({ loading: true, requestId });
  const response = await fetch(`/users/${id}`);
  const user = await response.json();
  // Only update if this is the latest request
  set((state) => {
    if (state.requestId !== requestId) return state;
    return { user, loading: false };
  });
}
```

### Pitfall 3: Forgetting to Cleanup

```typescript
// In component
useEffect(() => {
  fetchData();
  return () => {
    // Clean up any pending requests
    const controller = new AbortController();
    // ... use controller to abort
  };
}, []);
```

---

## Key Takeaways

1. **Async actions follow a pattern**: loading → success/error
2. **Always handle errors**: Use try/catch and update error state
3. **Cancel in-flight requests**: Use AbortController for race conditions
4. **Retry with backoff**: Handle flaky networks gracefully
5. **Show progress**: Keep users informed during long operations
6. **Debounce search**: Prevent excessive API calls
7. **Optimistic updates**: Improve perceived performance
8. **Cleanup subscriptions**: Prevent memory leaks
9. **Use request IDs**: Avoid stale responses
10. **Test edge cases**: Network errors, timeouts, etc.

---

## What's Next

You've mastered basic async actions. Next, you'll tackle concurrency and race conditions in depth.
