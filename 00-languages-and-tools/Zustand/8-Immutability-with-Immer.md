# Part 2 — Advanced State Architecture

## Section 8: Immutability with Immer

You've learned the importance of immutable updates throughout this series. But let's be honest—manually creating new objects and arrays for deeply nested state is tedious, error-prone, and makes your code harder to read. Enter **Immer**—a library that lets you write mutable-looking code while safely producing immutable updates behind the scenes.

---

## The Target: Simplifying Immutable Updates

By the end of this section, you'll be able to:
- Understand why Immer is a game-changer for complex state
- Integrate Immer with Zustand using the `immer` middleware
- Write cleaner, more intuitive state updates
- Handle deeply nested state with ease
- Understand when to use Immer vs. manual updates

---

## The Concept: Immutability Without the Pain

Think of Immer as a **time machine for state**:

```
Traditional Immutable Update (Painful):
┌────────────────────────────────────────────────────────────┐
│  const state = {                                          │
│    user: {                                               │
│      profile: {                                          │
│        settings: {                                      │
│          theme: 'dark',                                 │
│          preferences: { notifications: true }           │
│        }                                                │
│      }                                                  │
│    }                                                    │
│  };                                                     │
│                                                         │
│  // Changing one nested value:                         │
│  set({                                                 │
│    user: {                                             │
│      ...state.user,                                    │
│      profile: {                                        │
│        ...state.user.profile,                          │
│        settings: {                                    │
│          ...state.user.profile.settings,              │
│          theme: 'light'                               │
│        }                                              │
│      }                                                │
│    }                                                  │
│  });                                                   │
└────────────────────────────────────────────────────────────┘

Immer Update (Joyful):
┌────────────────────────────────────────────────────────────┐
│  set((state) => {                                        │
│    state.user.profile.settings.theme = 'light';          │
│  });                                                     │
│  // Immer handles all the immutability complexity!       │
└────────────────────────────────────────────────────────────┘
```

### How Immer Works

Immer uses a technique called **structural sharing**:

1. **Draft**: Immer wraps your state in a proxy (the "draft")
2. **Mutation**: You mutate the draft as if it were mutable
3. **Reconciliation**: Immer tracks all changes to the draft
4. **Production**: Immer produces a new immutable state with only the changed paths updated

```
Original State               Draft (Proxy)               New State
┌──────────────┐          ┌──────────────┐           ┌──────────────┐
│ {            │          │ {            │           │ {            │
│   user: {    │          │   user: {    │           │   user: {    │
│     name:    │ ──────▶ │     name:    │ ────────▶ │     name:    │
│     'Alice'  │          │     'Alice'  │           │     'Alice'  │
│   }          │          │   }          │           │   }          │
│ }            │          │ }            │           │ }            │
└──────────────┘          └──────────────┘           └──────────────┘
                                │                          │
                                ▼                          ▼
                          Mutate draft               New immutable
                          (mutable)                  state created
```

---

## The Implementation: Using Immer with Zustand

### Step 1: Installation

```bash
npm install immer
```

### Step 2: Basic Immer Usage

First, let's see how Immer works on its own:

```typescript
// src/examples/immerBasics.ts
import { produce } from 'immer';

// Example 1: Simple object update
const baseState = {
  user: {
    name: 'Alice',
    age: 30,
    address: {
      street: '123 Main St',
      city: 'New York',
    },
  },
  tasks: ['Buy milk', 'Write code'],
};

// Without Immer (manual)
const updatedState1 = {
  ...baseState,
  user: {
    ...baseState.user,
    age: 31,
    address: {
      ...baseState.user.address,
      city: 'Boston',
    },
  },
};

// With Immer (mutable syntax)
const updatedState2 = produce(baseState, (draft) => {
  draft.user.age = 31;
  draft.user.address.city = 'Boston';
  draft.tasks.push('Learn Immer');
});

console.log('Original:', baseState);
console.log('Updated:', updatedState2);
// Original is unchanged!
```

### Step 3: Integrating Immer with Zustand

Zustand provides the `immer` middleware for seamless integration:

```typescript
// src/store/withImmer.ts
import { create } from 'zustand';
import { immer } from 'zustand/middleware/immer';

// Define a complex state structure
interface TaskStore {
  tasks: {
    byId: Record<string, Task>;
    allIds: string[];
    filters: {
      status: 'all' | 'active' | 'completed';
      priority: 'all' | 'high' | 'medium' | 'low';
      search: string;
    };
    ui: {
      selectedId: string | null;
      expandedIds: Set<string>;
      sortOrder: 'asc' | 'desc';
    };
  };
  user: {
    id: string;
    name: string;
    preferences: {
      theme: 'light' | 'dark';
      notifications: {
        email: boolean;
        push: boolean;
      };
    };
  };
  
  // Actions
  addTask: (task: Task) => void;
  updateTask: (id: string, updates: Partial<Task>) => void;
  toggleTask: (id: string) => void;
  deleteTask: (id: string) => void;
  setFilter: (filter: Partial<TaskStore['tasks']['filters']>) => void;
  toggleExpanded: (id: string) => void;
  updateUserPreferences: (preferences: Partial<TaskStore['user']['preferences']>) => void;
  resetStore: () => void;
}

// Initial state
const initialState: Omit<TaskStore, keyof {
  addTask: any;
  updateTask: any;
  toggleTask: any;
  deleteTask: any;
  setFilter: any;
  toggleExpanded: any;
  updateUserPreferences: any;
  resetStore: any;
}> = {
  tasks: {
    byId: {},
    allIds: [],
    filters: {
      status: 'all',
      priority: 'all',
      search: '',
    },
    ui: {
      selectedId: null,
      expandedIds: new Set(),
      sortOrder: 'desc',
    },
  },
  user: {
    id: 'user-1',
    name: 'John Doe',
    preferences: {
      theme: 'dark',
      notifications: {
        email: true,
        push: false,
      },
    },
  },
};

// Create store with Immer middleware
export const useTaskStore = create<TaskStore>()(
  immer((set) => ({
    ...initialState,

    // --- Add Task (with Immer) ---
    addTask: (task: Task) => {
      set((state) => {
        // Immer allows direct mutation!
        state.tasks.byId[task.id] = task;
        state.tasks.allIds.push(task.id);
        // No need to return anything - Immer handles it
      });
    },

    // --- Update Task (with Immer) ---
    updateTask: (id: string, updates: Partial<Task>) => {
      set((state) => {
        const task = state.tasks.byId[id];
        if (task) {
          // Direct mutation of nested object
          Object.assign(task, updates);
        }
      });
    },

    // --- Toggle Task (with Immer) ---
    toggleTask: (id: string) => {
      set((state) => {
        const task = state.tasks.byId[id];
        if (task) {
          // Simple toggle
          task.completed = !task.completed;
        }
      });
    },

    // --- Delete Task (with Immer) ---
    deleteTask: (id: string) => {
      set((state) => {
        // Delete from byId
        delete state.tasks.byId[id];
        // Remove from allIds
        const index = state.tasks.allIds.indexOf(id);
        if (index !== -1) {
          state.tasks.allIds.splice(index, 1);
        }
        // Remove from expandedIds if present
        if (state.tasks.ui.expandedIds.has(id)) {
          state.tasks.ui.expandedIds.delete(id);
        }
        // Clear selected if this was selected
        if (state.tasks.ui.selectedId === id) {
          state.tasks.ui.selectedId = null;
        }
      });
    },

    // --- Set Filter (with Immer) ---
    setFilter: (filter: Partial<TaskStore['tasks']['filters']>) => {
      set((state) => {
        // Direct mutation of nested filter object
        Object.assign(state.tasks.filters, filter);
      });
    },

    // --- Toggle Expanded (with Immer) ---
    toggleExpanded: (id: string) => {
      set((state) => {
        const expandedIds = state.tasks.ui.expandedIds;
        if (expandedIds.has(id)) {
          expandedIds.delete(id);
        } else {
          expandedIds.add(id);
        }
      });
    },

    // --- Update User Preferences (with Immer) ---
    updateUserPreferences: (preferences: Partial<TaskStore['user']['preferences']>) => {
      set((state) => {
        // Deep nested update made simple
        if (preferences.theme !== undefined) {
          state.user.preferences.theme = preferences.theme;
        }
        if (preferences.notifications) {
          Object.assign(state.user.preferences.notifications, preferences.notifications);
        }
      });
    },

    // --- Reset Store (with Immer) ---
    resetStore: () => {
      set((state) => {
        // Reset to initial state using Immer
        // Note: We need to handle Set reset carefully
        state.tasks.byId = {};
        state.tasks.allIds = [];
        state.tasks.filters = initialState.tasks.filters;
        state.tasks.ui.selectedId = null;
        state.tasks.ui.expandedIds = new Set();
        state.tasks.ui.sortOrder = 'desc';
        state.user = JSON.parse(JSON.stringify(initialState.user));
      });
    },
  }))
);
```

### Step 4: Complex State Updates with Immer

Let's see how Immer handles even more complex scenarios:

```typescript
// src/store/complexImmerUpdates.ts
import { create } from 'zustand';
import { immer } from 'zustand/middleware/immer';

interface BoardStore {
  boards: Record<string, Board>;
  currentBoardId: string | null;
  
  // Actions
  addBoard: (board: Board) => void;
  addList: (boardId: string, list: List) => void;
  addCard: (boardId: string, listId: string, card: Card) => void;
  moveCard: (boardId: string, fromListId: string, toListId: string, cardId: string) => void;
  updateCard: (boardId: string, listId: string, cardId: string, updates: Partial<Card>) => void;
  deleteCard: (boardId: string, listId: string, cardId: string) => void;
  reorderLists: (boardId: string, startIndex: number, endIndex: number) => void;
}

export const useBoardStore = create<BoardStore>()(
  immer((set) => ({
    boards: {},
    currentBoardId: null,

    addBoard: (board: Board) => {
      set((state) => {
        state.boards[board.id] = board;
        if (!state.currentBoardId) {
          state.currentBoardId = board.id;
        }
      });
    },

    addList: (boardId: string, list: List) => {
      set((state) => {
        const board = state.boards[boardId];
        if (board) {
          board.lists[list.id] = list;
          board.listOrder.push(list.id);
        }
      });
    },

    addCard: (boardId: string, listId: string, card: Card) => {
      set((state) => {
        const board = state.boards[boardId];
        if (board) {
          const list = board.lists[listId];
          if (list) {
            list.cards[card.id] = card;
            list.cardOrder.push(card.id);
          }
        }
      });
    },

    moveCard: (boardId: string, fromListId: string, toListId: string, cardId: string) => {
      set((state) => {
        const board = state.boards[boardId];
        if (!board) return;

        const fromList = board.lists[fromListId];
        const toList = board.lists[toListId];
        if (!fromList || !toList) return;

        // Remove card from fromList
        const cardIndex = fromList.cardOrder.indexOf(cardId);
        if (cardIndex === -1) return;
        
        const card = fromList.cards[cardId];
        if (!card) return;

        // Remove from source
        fromList.cardOrder.splice(cardIndex, 1);
        delete fromList.cards[cardId];

        // Add to destination
        toList.cards[cardId] = card;
        toList.cardOrder.push(cardId);
      });
    },

    updateCard: (boardId: string, listId: string, cardId: string, updates: Partial<Card>) => {
      set((state) => {
        const board = state.boards[boardId];
        if (board) {
          const list = board.lists[listId];
          if (list) {
            const card = list.cards[cardId];
            if (card) {
              Object.assign(card, updates);
            }
          }
        }
      });
    },

    deleteCard: (boardId: string, listId: string, cardId: string) => {
      set((state) => {
        const board = state.boards[boardId];
        if (board) {
          const list = board.lists[listId];
          if (list) {
            // Remove from cardOrder
            const index = list.cardOrder.indexOf(cardId);
            if (index !== -1) {
              list.cardOrder.splice(index, 1);
            }
            // Delete from cards
            delete list.cards[cardId];
          }
        }
      });
    },

    reorderLists: (boardId: string, startIndex: number, endIndex: number) => {
      set((state) => {
        const board = state.boards[boardId];
        if (board) {
          const [removed] = board.listOrder.splice(startIndex, 1);
          board.listOrder.splice(endIndex, 0, removed);
        }
      });
    },
  }))
);
```

### Step 5: Immer with Async Actions

Immer works seamlessly with async actions:

```typescript
// src/store/asyncImmerStore.ts
import { create } from 'zustand';
import { immer } from 'zustand/middleware/immer';

interface AsyncStore {
  data: any[];
  loading: Record<string, boolean>;
  errors: Record<string, string | null>;
  
  fetchData: (endpoint: string) => Promise<void>;
  updateData: (id: string, updates: any) => Promise<void>;
  deleteData: (id: string) => Promise<void>;
}

export const useAsyncStore = create<AsyncStore>()(
  immer((set) => ({
    data: [],
    loading: {},
    errors: {},

    fetchData: async (endpoint: string) => {
      // Set loading state
      set((state) => {
        state.loading[endpoint] = true;
        state.errors[endpoint] = null;
      });

      try {
        const response = await fetch(endpoint);
        if (!response.ok) throw new Error('Failed to fetch');
        const data = await response.json();

        set((state) => {
          state.data = data;
          state.loading[endpoint] = false;
          state.errors[endpoint] = null;
        });
      } catch (error) {
        set((state) => {
          state.loading[endpoint] = false;
          state.errors[endpoint] = error.message;
        });
      }
    },

    updateData: async (id: string, updates: any) => {
      try {
        // Optimistic update
        set((state) => {
          const item = state.data.find((d: any) => d.id === id);
          if (item) {
            Object.assign(item, updates);
          }
        });

        const response = await fetch(`/api/data/${id}`, {
          method: 'PUT',
          body: JSON.stringify(updates),
          headers: { 'Content-Type': 'application/json' },
        });

        if (!response.ok) throw new Error('Failed to update');

        // Update with server response
        const updatedData = await response.json();
        set((state) => {
          const index = state.data.findIndex((d: any) => d.id === id);
          if (index !== -1) {
            state.data[index] = updatedData;
          }
        });
      } catch (error) {
        // Rollback optimistic update on error
        set((state) => {
          // Could fetch fresh data or handle rollback
          // In real app, you'd want a proper rollback mechanism
        });
        throw error;
      }
    },

    deleteData: async (id: string) => {
      try {
        // Optimistic delete
        set((state) => {
          const index = state.data.findIndex((d: any) => d.id === id);
          if (index !== -1) {
            state.data.splice(index, 1);
          }
        });

        const response = await fetch(`/api/data/${id}`, {
          method: 'DELETE',
        });

        if (!response.ok) throw new Error('Failed to delete');
      } catch (error) {
        // Rollback optimistic delete
        // In real app, you'd fetch fresh data
        throw error;
      }
    },
  }))
);
```

### Step 6: Immer with Set and Map

Immer handles Set and Map beautifully:

```typescript
// src/store/immerCollections.ts
import { create } from 'zustand';
import { immer } from 'zustand/middleware/immer';

interface CollectionsStore {
  selectedIds: Set<string>;
  tags: Map<string, string[]>;
  cache: Map<string, any>;
  
  toggleSelection: (id: string) => void;
  addTag: (id: string, tag: string) => void;
  removeTag: (id: string, tag: string) => void;
  updateCache: (key: string, data: any) => void;
  clearCache: () => void;
}

export const useCollectionsStore = create<CollectionsStore>()(
  immer((set) => ({
    selectedIds: new Set(),
    tags: new Map(),
    cache: new Map(),

    toggleSelection: (id: string) => {
      set((state) => {
        if (state.selectedIds.has(id)) {
          state.selectedIds.delete(id);
        } else {
          state.selectedIds.add(id);
        }
      });
    },

    addTag: (id: string, tag: string) => {
      set((state) => {
        if (!state.tags.has(id)) {
          state.tags.set(id, []);
        }
        const tags = state.tags.get(id)!;
        if (!tags.includes(tag)) {
          tags.push(tag);
        }
      });
    },

    removeTag: (id: string, tag: string) => {
      set((state) => {
        const tags = state.tags.get(id);
        if (tags) {
          const index = tags.indexOf(tag);
          if (index !== -1) {
            tags.splice(index, 1);
          }
          if (tags.length === 0) {
            state.tags.delete(id);
          }
        }
      });
    },

    updateCache: (key: string, data: any) => {
      set((state) => {
        state.cache.set(key, data);
      });
    },

    clearCache: () => {
      set((state) => {
        state.cache.clear();
      });
    },
  }))
);
```

---

## The Verification: Testing Immer Updates

### Step 1: Create a Test Component

```tsx
// src/components/ImmerTest.tsx
import React from 'react';
import { useTaskStore } from '../store/withImmer';

function ImmerTest() {
  const tasks = useTaskStore((state) => state.tasks);
  const addTask = useTaskStore((state) => state.addTask);
  const toggleTask = useTaskStore((state) => state.toggleTask);
  const deleteTask = useTaskStore((state) => state.deleteTask);
  const updateTask = useTaskStore((state) => state.updateTask);
  const setFilter = useTaskStore((state) => state.setFilter);
  const updatePreferences = useTaskStore((state) => state.updateUserPreferences);
  const resetStore = useTaskStore((state) => state.resetStore);

  const [taskText, setTaskText] = React.useState('');

  const handleAddTask = () => {
    if (taskText.trim()) {
      addTask({
        id: `task-${Date.now()}`,
        title: taskText,
        completed: false,
        priority: 'medium',
        createdAt: new Date(),
        updatedAt: new Date(),
        tags: [],
        description: '',
        comments: [],
        attachments: [],
        createdBy: 'user-1',
      });
      setTaskText('');
    }
  };

  return (
    <div style={{ padding: '20px' }}>
      <h1>🧪 Immer Test</h1>
      
      <div style={{ marginBottom: '20px' }}>
        <input
          type="text"
          value={taskText}
          onChange={(e) => setTaskText(e.target.value)}
          placeholder="New task..."
        />
        <button onClick={handleAddTask}>Add Task</button>
        <button onClick={resetStore} style={{ marginLeft: '10px' }}>
          Reset Store
        </button>
      </div>

      <div style={{ marginBottom: '20px' }}>
        <button onClick={() => setFilter({ status: 'all' })}>All</button>
        <button onClick={() => setFilter({ status: 'active' })}>Active</button>
        <button onClick={() => setFilter({ status: 'completed' })}>Completed</button>
      </div>

      <div style={{ marginBottom: '20px' }}>
        <button 
          onClick={() => updatePreferences({ 
            theme: useTaskStore.getState().user.preferences.theme === 'dark' ? 'light' : 'dark' 
          })}
        >
          Toggle Theme
        </button>
      </div>

      <ul style={{ listStyle: 'none', padding: 0 }}>
        {tasks.allIds.map((id) => {
          const task = tasks.byId[id];
          return (
            <li key={id} style={{ padding: '8px', marginBottom: '4px', backgroundColor: '#f5f5f5' }}>
              <input
                type="checkbox"
                checked={task.completed}
                onChange={() => toggleTask(id)}
              />
              <span style={{ 
                textDecoration: task.completed ? 'line-through' : 'none',
                marginLeft: '8px' 
              }}>
                {task.title}
              </span>
              <button 
                onClick={() => updateTask(id, { priority: 'high' })}
                style={{ marginLeft: '8px' }}
              >
                Set High Priority
              </button>
              <button 
                onClick={() => deleteTask(id)}
                style={{ marginLeft: '8px', color: 'red' }}
              >
                Delete
              </button>
            </li>
          );
        })}
      </ul>

      <div style={{ marginTop: '20px' }}>
        <strong>Debug Info:</strong>
        <pre style={{ background: '#f0f0f0', padding: '10px' }}>
          {JSON.stringify(
            {
              taskCount: tasks.allIds.length,
              filter: tasks.filters,
              theme: useTaskStore.getState().user.preferences.theme,
              expandedCount: tasks.ui.expandedIds.size,
            },
            null,
            2
          )}
        </pre>
      </div>
    </div>
  );
}

export default ImmerTest;
```

### Step 2: Performance Comparison

Test the performance difference between manual and Immer updates:

```typescript
// src/tests/immerPerformance.ts
import { create } from 'zustand';
import { immer } from 'zustand/middleware/immer';

// Manual updates store
const useManualStore = create<{ data: any[] }>((set) => ({
  data: Array(1000).fill(null).map((_, i) => ({ id: i, value: i })),
  updateItem: (id: number, value: number) => {
    set((state) => ({
      data: state.data.map(item =>
        item.id === id ? { ...item, value } : item
      )
    }));
  },
}));

// Immer store
const useImmerStore = create<{ data: any[] }>()(
  immer((set) => ({
    data: Array(1000).fill(null).map((_, i) => ({ id: i, value: i })),
    updateItem: (id: number, value: number) => {
      set((state) => {
        const item = state.data.find(item => item.id === id);
        if (item) {
          item.value = value;
        }
      });
    },
  }))
);

// Performance test
function performanceTest() {
  console.log('=== Performance Test ===');
  
  // Test manual updates
  console.time('Manual updates (1000 items)');
  const manualStore = useManualStore.getState();
  for (let i = 0; i < 1000; i++) {
    manualStore.updateItem(i, i * 2);
  }
  console.timeEnd('Manual updates (1000 items)');
  
  // Test Immer updates
  console.time('Immer updates (1000 items)');
  const immerStore = useImmerStore.getState();
  for (let i = 0; i < 1000; i++) {
    immerStore.updateItem(i, i * 2);
  }
  console.timeEnd('Immer updates (1000 items)');
}

performanceTest();
```

### Step 3: Verify Immutability

```typescript
// src/tests/immerImmutability.ts
import { produce } from 'immer';

const original = {
  user: {
    name: 'Alice',
    address: {
      street: '123 Main St',
      city: 'New York',
    },
  },
  tags: ['work', 'personal'],
};

// Create a copy with Immer
const updated = produce(original, (draft) => {
  draft.user.address.city = 'Boston';
  draft.tags.push('urgent');
});

// Verify original is unchanged
console.log('Original:', original);
console.log('Updated:', updated);

// Deep equality check
console.log('Original and updated are different objects:', original !== updated);
console.log('User object is different:', original.user !== updated.user);
console.log('Address object is different:', original.user.address !== updated.user.address);
console.log('Tags array is different:', original.tags !== updated.tags);

// Verify shared structure (structural sharing)
console.log('Name is shared (same reference):', original.user.name === updated.user.name);
console.log('Street is shared (same reference):', original.user.address.street === updated.user.address.street);
// Output: true (only changed paths are new)
```

---

## Deep Dive: How Immer Works

### The Proxy-Based Magic

Immer uses JavaScript Proxies to intercept all mutations:

```typescript
// Simplified Immer implementation
function createDraft(base) {
  const handlers = {
    get(target, prop) {
      // Return a draft of the nested property
      return createDraft(target[prop]);
    },
    set(target, prop, value) {
      // Track the mutation
      target[prop] = value;
      return true;
    },
  };
  
  return new Proxy(base, handlers);
}

function produce(base, producer) {
  const draft = createDraft(base);
  producer(draft);
  return reconcile(draft);
}
```

### When Not to Use Immer

While Immer is powerful, there are cases where manual updates are better:

```typescript
// ❌ NOT GOOD: Simple primitive updates
set({ count: state.count + 1 });
// Immer adds unnecessary overhead

// ✅ GOOD: Complex nested updates
set((state) => {
  state.user.profile.settings.preferences.notifications.email = false;
});
// Immer shines here

// ❌ NOT GOOD: Bulk updates with no mutations
set((state) => ({
  data: [...state.data, newItem],
  loading: false,
}));
// Manual spread is simpler

// ✅ GOOD: Updates with mutations and deletions
set((state) => {
  delete state.users[userId];
  state.tasks.push(newTask);
  state.count++;
});
// Immer handles the complexity
```

---

## Common Pitfalls and Solutions

### Pitfall 1: Returning from Immer Updates

```typescript
// ❌ WRONG: Returning from immer update
set((state) => {
  state.count++;
  return state; // Don't return!
});

// ✅ CORRECT: No return needed
set((state) => {
  state.count++;
});
```

### Pitfall 2: Mutating Outside Immer

```typescript
// ❌ WRONG: Mutating state directly
const state = useTaskStore.getState();
state.tasks.push(newTask); // This mutates!

// ✅ CORRECT: Use set with immer
set((state) => {
  state.tasks.push(newTask);
});
```

### Pitfall 3: Mixing with Other Middleware

```typescript
// ⚠️ CAUTION: Order matters
const useStore = create(
  devtools(
    persist(
      immer((set) => ({ /* store */ })),
      { name: 'storage' }
    )
  )
);
// Immer should be closest to the store config
```

---

## Key Takeaways

1. **Immer simplifies immutability**: Write mutable code, get immutable results
2. **Use the `immer` middleware**: Seamless integration with Zustand
3. **Perfect for nested state**: Eliminates deep spread hell
4. **Works with collections**: Set, Map, and arrays are fully supported
5. **Performance**: Usually fast enough for most apps
6. **When to use**: Complex nested updates, forms, collections
7. **When not to use**: Simple primitive updates, bulk updates
8. **Testing**: State remains immutable and predictable

---

## What's Next

Now that you've mastered immutable updates with Immer, you're ready to tackle state persistence. In the next section, you'll learn how to save and restore state across sessions using the `persist` middleware.
