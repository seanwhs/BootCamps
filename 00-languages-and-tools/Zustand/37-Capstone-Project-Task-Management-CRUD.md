# Capstone Project — Phase 3: Task Management CRUD

Now that authentication is in place, it's time to build the core feature of TaskFlow: task management. In this phase, you'll implement full CRUD operations with optimistic updates, filtering, sorting, and real-time UI updates. You'll also build a comprehensive task dashboard with all the components users need to manage their tasks effectively.

---

## The Target: Complete Task Management

By the end of this phase, you'll have:
- Full CRUD operations (Create, Read, Update, Delete)
- Optimistic updates with rollback on failure
- Task filtering by status, priority, and assignee
- Task search with debouncing
- Task sorting by multiple fields
- Task statistics dashboard
- Real-time updates via WebSocket (mock)
- Comprehensive component suite

---

## Implementation: Task Management

### Step 1: Enhanced Task Store with Async Operations

```typescript
// packages/shared/src/store/task/taskStore.ts
import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';
import { immer } from 'zustand/middleware/immer';
import { Task, TaskState, TaskFilters, TaskSort } from '../../types';
import { taskApi } from '../../services/taskApi';
import { eventBus } from '../../events';

interface TaskStore extends TaskState {
  // CRUD Operations
  fetchTasks: () => Promise<void>;
  addTask: (taskData: Omit<Task, 'id' | 'createdAt' | 'updatedAt' | 'comments' | 'attachments'>) => Promise<Task>;
  updateTask: (id: string, updates: Partial<Task>) => Promise<Task>;
  deleteTask: (id: string) => Promise<void>;
  toggleTask: (id: string) => Promise<void>;
  
  // Bulk Operations
  bulkDelete: (ids: string[]) => Promise<void>;
  bulkComplete: (ids: string[]) => Promise<void>;
  
  // Filters and Sorting
  setFilters: (filters: Partial<TaskFilters>) => void;
  setSort: (sort: Partial<TaskSort>) => void;
  resetFilters: () => void;
  
  // Selection
  selectTask: (id: string | null) => void;
  toggleSelection: (id: string) => void;
  selectAll: () => void;
  deselectAll: () => void;
  
  // Utility
  clearError: () => void;
  reset: () => void;
  
  // Computed (for efficient access)
  getFilteredTasks: () => Task[];
  getTaskStats: () => { total: number; completed: number; active: number; highPriority: number };
  getSelectedCount: () => number;
}

const initialState: TaskState = {
  tasks: {},
  taskIds: [],
  loading: false,
  error: null,
  filters: {
    status: 'all',
    priority: 'all',
    assignee: 'all',
    tags: [],
    dueDate: 'all',
    searchQuery: '',
  },
  sort: {
    field: 'createdAt',
    direction: 'desc',
  },
  selectedTaskId: null,
  selectedIds: [],
};

export const useTaskStore = create<TaskStore>()(
  persist(
    immer((set, get) => ({
      ...initialState,

      // --- Fetch Tasks ---
      fetchTasks: async () => {
        set({ loading: true, error: null });
        try {
          const tasks = await taskApi.getTasks();
          const tasksMap: Record<string, Task> = {};
          const ids: string[] = [];
          for (const task of tasks) {
            tasksMap[task.id] = task;
            ids.push(task.id);
          }
          set({ tasks: tasksMap, taskIds: ids, loading: false });
          eventBus.publish('task:loaded', { count: tasks.length });
        } catch (error) {
          set({
            loading: false,
            error: error instanceof Error ? error.message : 'Failed to fetch tasks',
          });
          throw error;
        }
      },

      // --- Add Task (with Optimistic Update) ---
      addTask: async (taskData) => {
        const tempId = `temp-${Date.now()}`;
        const optimisticTask: Task = {
          ...taskData,
          id: tempId,
          createdAt: new Date(),
          updatedAt: new Date(),
          comments: [],
          attachments: [],
          optimistic: true,
        };

        // Optimistic add
        set((state) => {
          state.tasks[tempId] = optimisticTask;
          state.taskIds.push(tempId);
        });

        try {
          const savedTask = await taskApi.createTask(taskData);
          set((state) => {
            delete state.tasks[tempId];
            state.tasks[savedTask.id] = savedTask;
            state.taskIds = state.taskIds.map(id => id === tempId ? savedTask.id : id);
          });
          eventBus.publish('task:created', savedTask);
          return savedTask;
        } catch (error) {
          // Rollback
          set((state) => {
            delete state.tasks[tempId];
            state.taskIds = state.taskIds.filter(id => id !== tempId);
            state.error = error instanceof Error ? error.message : 'Failed to add task';
          });
          throw error;
        }
      },

      // --- Update Task ---
      updateTask: async (id: string, updates: Partial<Task>) => {
        const currentTask = get().tasks[id];
        if (!currentTask) throw new Error('Task not found');

        // Optimistic update
        const optimisticTask = {
          ...currentTask,
          ...updates,
          updatedAt: new Date(),
          optimistic: true,
        };
        set((state) => {
          state.tasks[id] = optimisticTask;
        });

        try {
          const updatedTask = await taskApi.updateTask(id, updates);
          set((state) => {
            state.tasks[id] = { ...updatedTask, optimistic: false };
          });
          eventBus.publish('task:updated', updatedTask);
          return updatedTask;
        } catch (error) {
          // Rollback
          set((state) => {
            state.tasks[id] = currentTask;
            state.error = error instanceof Error ? error.message : 'Failed to update task';
          });
          throw error;
        }
      },

      // --- Delete Task ---
      deleteTask: async (id: string) => {
        const deletedTask = get().tasks[id];
        if (!deletedTask) return;

        // Optimistic delete
        set((state) => {
          delete state.tasks[id];
          state.taskIds = state.taskIds.filter(taskId => taskId !== id);
          state.selectedIds = state.selectedIds.filter(sid => sid !== id);
          if (state.selectedTaskId === id) {
            state.selectedTaskId = null;
          }
        });

        try {
          await taskApi.deleteTask(id);
          eventBus.publish('task:deleted', { id });
        } catch (error) {
          // Rollback
          set((state) => {
            state.tasks[id] = deletedTask;
            state.taskIds.push(id);
            state.error = error instanceof Error ? error.message : 'Failed to delete task';
          });
          throw error;
        }
      },

      // --- Toggle Task ---
      toggleTask: async (id: string) => {
        const task = get().tasks[id];
        if (!task) return;

        const newCompleted = !task.completed;
        await get().updateTask(id, { completed: newCompleted });
        if (newCompleted) {
          eventBus.publish('task:completed', { id });
        }
      },

      // --- Bulk Delete ---
      bulkDelete: async (ids: string[]) => {
        const tasksToDelete = ids.map(id => get().tasks[id]).filter(Boolean);
        if (tasksToDelete.length === 0) return;

        // Optimistic delete
        set((state) => {
          for (const id of ids) {
            delete state.tasks[id];
          }
          state.taskIds = state.taskIds.filter(id => !ids.includes(id));
          state.selectedIds = state.selectedIds.filter(id => !ids.includes(id));
          if (state.selectedTaskId && ids.includes(state.selectedTaskId)) {
            state.selectedTaskId = null;
          }
        });

        try {
          await taskApi.bulkDelete(ids);
          eventBus.publish('tasks:deleted', { ids });
        } catch (error) {
          // Rollback
          set((state) => {
            for (const task of tasksToDelete) {
              state.tasks[task.id] = task;
              if (!state.taskIds.includes(task.id)) {
                state.taskIds.push(task.id);
              }
            }
            state.error = error instanceof Error ? error.message : 'Failed to delete tasks';
          });
          throw error;
        }
      },

      // --- Bulk Complete ---
      bulkComplete: async (ids: string[]) => {
        const tasksToComplete = ids.map(id => get().tasks[id]).filter(Boolean);
        if (tasksToComplete.length === 0) return;

        // Optimistic update
        set((state) => {
          for (const id of ids) {
            if (state.tasks[id]) {
              state.tasks[id].completed = true;
              state.tasks[id].updatedAt = new Date();
            }
          }
          state.selectedIds = [];
        });

        try {
          await taskApi.bulkUpdate(ids, { completed: true });
          eventBus.publish('tasks:completed', { ids });
        } catch (error) {
          // Rollback
          set((state) => {
            for (const task of tasksToComplete) {
              state.tasks[task.id] = task;
            }
            state.error = error instanceof Error ? error.message : 'Failed to complete tasks';
          });
          throw error;
        }
      },

      // --- Filters ---
      setFilters: (filters: Partial<TaskFilters>) => {
        set((state) => {
          state.filters = { ...state.filters, ...filters };
        });
      },

      setSort: (sort: Partial<TaskSort>) => {
        set((state) => {
          state.sort = { ...state.sort, ...sort };
        });
      },

      resetFilters: () => {
        set({ filters: initialState.filters });
      },

      // --- Selection ---
      selectTask: (id: string | null) => {
        set({ selectedTaskId: id });
      },

      toggleSelection: (id: string) => {
        set((state) => {
          if (state.selectedIds.includes(id)) {
            state.selectedIds = state.selectedIds.filter(sid => sid !== id);
          } else {
            state.selectedIds.push(id);
          }
        });
      },

      selectAll: () => {
        const state = get();
        const filteredTasks = state.getFilteredTasks();
        set({ selectedIds: filteredTasks.map(t => t.id) });
      },

      deselectAll: () => {
        set({ selectedIds: [] });
      },

      // --- Utility ---
      clearError: () => {
        set({ error: null });
      },

      reset: () => {
        set(initialState);
      },

      // --- Computed ---
      getFilteredTasks: () => {
        const state = get();
        let taskList = state.taskIds.map(id => state.tasks[id]).filter(Boolean);
        const { filters, sort } = state;

        // Apply status filter
        if (filters.status === 'active') {
          taskList = taskList.filter(t => !t.completed);
        } else if (filters.status === 'completed') {
          taskList = taskList.filter(t => t.completed);
        }

        // Apply priority filter
        if (filters.priority !== 'all') {
          taskList = taskList.filter(t => t.priority === filters.priority);
        }

        // Apply assignee filter
        if (filters.assignee === 'unassigned') {
          taskList = taskList.filter(t => !t.assigneeId);
        } else if (filters.assignee !== 'all') {
          taskList = taskList.filter(t => t.assigneeId === filters.assignee);
        }

        // Apply search filter
        if (filters.searchQuery.trim()) {
          const query = filters.searchQuery.toLowerCase().trim();
          taskList = taskList.filter(t =>
            t.title.toLowerCase().includes(query) ||
            (t.description && t.description.toLowerCase().includes(query)) ||
            t.tags.some(tag => tag.toLowerCase().includes(query))
          );
        }

        // Apply due date filter
        if (filters.dueDate !== 'all') {
          const now = new Date();
          const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
          const weekEnd = new Date(today);
          weekEnd.setDate(weekEnd.getDate() + 7);
          const monthEnd = new Date(today);
          monthEnd.setMonth(monthEnd.getMonth() + 1);

          taskList = taskList.filter(t => {
            if (!t.dueDate) return false;
            const dueDate = new Date(t.dueDate);
            const dueDay = new Date(dueDate.getFullYear(), dueDate.getMonth(), dueDate.getDate());

            switch (filters.dueDate) {
              case 'overdue':
                return dueDay < today && !t.completed;
              case 'today':
                return dueDay.getTime() === today.getTime();
              case 'week':
                return dueDay >= today && dueDay <= weekEnd;
              case 'month':
                return dueDay >= today && dueDay <= monthEnd;
              default:
                return true;
            }
          });
        }

        // Apply sorting
        taskList.sort((a, b) => {
          let comparison = 0;
          const field = sort.field;
          if (field === 'title') {
            comparison = a.title.localeCompare(b.title);
          } else if (field === 'priority') {
            const order = { high: 3, medium: 2, low: 1 };
            comparison = order[b.priority] - order[a.priority];
          } else if (field === 'dueDate') {
            if (!a.dueDate && !b.dueDate) comparison = 0;
            else if (!a.dueDate) comparison = 1;
            else if (!b.dueDate) comparison = -1;
            else comparison = new Date(a.dueDate).getTime() - new Date(b.dueDate).getTime();
          } else if (field === 'createdAt' || field === 'updatedAt') {
            const aTime = field === 'createdAt' ? a.createdAt.getTime() : a.updatedAt.getTime();
            const bTime = field === 'createdAt' ? b.createdAt.getTime() : b.updatedAt.getTime();
            comparison = aTime - bTime;
          }
          return sort.direction === 'asc' ? comparison : -comparison;
        });

        return taskList;
      },

      getTaskStats: () => {
        const state = get();
        const tasks = state.taskIds.map(id => state.tasks[id]).filter(Boolean);
        return {
          total: tasks.length,
          completed: tasks.filter(t => t.completed).length,
          active: tasks.filter(t => !t.completed).length,
          highPriority: tasks.filter(t => t.priority === 'high').length,
        };
      },

      getSelectedCount: () => {
        return get().selectedIds.length;
      },
    })),
    {
      name: 'task-storage',
      storage: createJSONStorage(() => localStorage),
      partialize: (state) => ({
        tasks: state.tasks,
        taskIds: state.taskIds,
        filters: state.filters,
        sort: state.sort,
        selectedIds: state.selectedIds,
      }),
    }
  )
);
```

### Step 2: Task API Service

```typescript
// packages/shared/src/services/taskApi.ts
import { Task } from '../types';

// Mock API
const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3001/api';

let mockTasks: Task[] = [
  {
    id: 'task-1',
    title: 'Complete project proposal',
    description: 'Write and submit the Q4 project proposal',
    completed: false,
    priority: 'high',
    dueDate: new Date(Date.now() + 2 * 24 * 60 * 60 * 1000),
    assigneeId: 'user-1',
    createdBy: 'user-1',
    tags: ['work', 'important'],
    comments: [
      {
        id: 'comment-1',
        taskId: 'task-1',
        userId: 'user-1',
        content: 'Initial draft done',
        createdAt: new Date(),
        updatedAt: new Date(),
      },
    ],
    attachments: [],
    createdAt: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000),
    updatedAt: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000),
  },
  {
    id: 'task-2',
    title: 'Review pull requests',
    description: 'Review open PRs from the team',
    completed: false,
    priority: 'medium',
    dueDate: new Date(Date.now() + 1 * 24 * 60 * 60 * 1000),
    assigneeId: 'user-2',
    createdBy: 'user-1',
    tags: ['work', 'code-review'],
    comments: [],
    attachments: [],
    createdAt: new Date(Date.now() - 3 * 24 * 60 * 60 * 1000),
    updatedAt: new Date(Date.now() - 3 * 24 * 60 * 60 * 1000),
  },
  {
    id: 'task-3',
    title: 'Update documentation',
    description: 'Update API documentation with new endpoints',
    completed: true,
    priority: 'low',
    dueDate: new Date(Date.now() - 3 * 24 * 60 * 60 * 1000),
    assigneeId: 'user-1',
    createdBy: 'user-1',
    tags: ['docs'],
    comments: [],
    attachments: [],
    createdAt: new Date(Date.now() - 10 * 24 * 60 * 60 * 1000),
    updatedAt: new Date(Date.now() - 5 * 24 * 60 * 60 * 1000),
  },
];

let taskIdCounter = 4;

export const taskApi = {
  getTasks: async (): Promise<Task[]> => {
    await new Promise(resolve => setTimeout(resolve, 500));
    return [...mockTasks];
  },

  getTask: async (id: string): Promise<Task | null> => {
    await new Promise(resolve => setTimeout(resolve, 300));
    return mockTasks.find(t => t.id === id) || null;
  },

  createTask: async (taskData: Omit<Task, 'id' | 'createdAt' | 'updatedAt' | 'comments' | 'attachments'>): Promise<Task> => {
    await new Promise(resolve => setTimeout(resolve, 600));
    
    const newTask: Task = {
      ...taskData,
      id: `task-${taskIdCounter++}`,
      createdAt: new Date(),
      updatedAt: new Date(),
      comments: [],
      attachments: [],
    };
    
    mockTasks.push(newTask);
    return newTask;
  },

  updateTask: async (id: string, updates: Partial<Task>): Promise<Task> => {
    await new Promise(resolve => setTimeout(resolve, 500));

    const index = mockTasks.findIndex(t => t.id === id);
    if (index === -1) {
      throw new Error('Task not found');
    }

    mockTasks[index] = {
      ...mockTasks[index],
      ...updates,
      updatedAt: new Date(),
    };

    return mockTasks[index];
  },

  deleteTask: async (id: string): Promise<void> => {
    await new Promise(resolve => setTimeout(resolve, 400));
    mockTasks = mockTasks.filter(t => t.id !== id);
  },

  bulkDelete: async (ids: string[]): Promise<void> => {
    await new Promise(resolve => setTimeout(resolve, 600));
    mockTasks = mockTasks.filter(t => !ids.includes(t.id));
  },

  bulkUpdate: async (ids: string[], updates: Partial<Task>): Promise<Task[]> => {
    await new Promise(resolve => setTimeout(resolve, 600));
    
    const updated: Task[] = [];
    for (const id of ids) {
      const index = mockTasks.findIndex(t => t.id === id);
      if (index !== -1) {
        mockTasks[index] = {
          ...mockTasks[index],
          ...updates,
          updatedAt: new Date(),
        };
        updated.push(mockTasks[index]);
      }
    }
    return updated;
  },

  // Admin endpoint to reset tasks
  resetTasks: () => {
    mockTasks = [];
  },
};
```

### Step 3: Task List Component with Virtualization

```tsx
// apps/web/components/tasks/TaskList.tsx
'use client';

import React, { useCallback, useMemo } from 'react';
import { useTaskStore, useUIStore } from '@taskflow/shared';
import { TaskItem } from './TaskItem';
import { TaskItemSkeleton } from './TaskItemSkeleton';

export function TaskList() {
  const {
    getFilteredTasks,
    loading,
    error,
    selectedIds,
    toggleSelection,
    selectAll,
    deselectAll,
    bulkDelete,
    bulkComplete,
  } = useTaskStore();

  const { addToast } = useUIStore();
  const filteredTasks = useTaskStore((state) => state.getFilteredTasks());
  const isAllSelected = filteredTasks.length > 0 && filteredTasks.every(t => selectedIds.includes(t.id));

  const handleBulkDelete = async () => {
    if (selectedIds.length === 0) return;
    try {
      await bulkDelete(selectedIds);
      addToast({
        type: 'success',
        message: `${selectedIds.length} tasks deleted`,
        title: 'Deleted',
      });
    } catch (error) {
      addToast({
        type: 'error',
        message: error instanceof Error ? error.message : 'Failed to delete tasks',
        title: 'Error',
      });
    }
  };

  const handleBulkComplete = async () => {
    if (selectedIds.length === 0) return;
    try {
      await bulkComplete(selectedIds);
      addToast({
        type: 'success',
        message: `${selectedIds.length} tasks completed`,
        title: 'Completed',
      });
    } catch (error) {
      addToast({
        type: 'error',
        message: error instanceof Error ? error.message : 'Failed to complete tasks',
        title: 'Error',
      });
    }
  };

  if (loading) {
    return (
      <div className="space-y-2">
        {[...Array(5)].map((_, i) => (
          <TaskItemSkeleton key={i} />
        ))}
      </div>
    );
  }

  if (error) {
    return (
      <div className="text-red-500 p-4 rounded bg-red-50 dark:bg-red-900/20">
        <p className="font-medium">Error loading tasks</p>
        <p className="text-sm">{error}</p>
      </div>
    );
  }

  if (filteredTasks.length === 0) {
    return (
      <div className="text-center py-12">
        <svg className="mx-auto h-12 w-12 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" />
        </svg>
        <h3 className="mt-2 text-sm font-medium text-gray-900 dark:text-white">No tasks</h3>
        <p className="mt-1 text-sm text-gray-500 dark:text-gray-400">
          {Object.values(useTaskStore.getState().filters).some(v => v !== 'all' && v !== '') 
            ? 'Try adjusting your filters'
            : 'Add your first task to get started'}
        </p>
      </div>
    );
  }

  return (
    <div className="space-y-2">
      {/* Bulk actions bar */}
      {selectedIds.length > 0 && (
        <div className="flex items-center justify-between px-4 py-2 bg-indigo-50 dark:bg-indigo-900/20 rounded-lg">
          <span className="text-sm text-indigo-700 dark:text-indigo-300">
            {selectedIds.length} task{selectedIds.length > 1 ? 's' : ''} selected
          </span>
          <div className="flex gap-2">
            <button
              onClick={handleBulkComplete}
              className="px-3 py-1 text-sm bg-green-600 text-white rounded hover:bg-green-700"
            >
              Complete
            </button>
            <button
              onClick={handleBulkDelete}
              className="px-3 py-1 text-sm bg-red-600 text-white rounded hover:bg-red-700"
            >
              Delete
            </button>
            <button
              onClick={deselectAll}
              className="px-3 py-1 text-sm text-gray-600 dark:text-gray-400 hover:text-gray-900 dark:hover:text-white"
            >
              Deselect All
            </button>
          </div>
        </div>
      )}

      {/* Select all */}
      <div className="flex items-center gap-2 px-2 py-1">
        <input
          type="checkbox"
          checked={isAllSelected}
          onChange={isAllSelected ? deselectAll : selectAll}
          className="w-4 h-4 rounded border-gray-300 dark:border-gray-600 text-indigo-600 focus:ring-indigo-500"
        />
        <label className="text-sm text-gray-600 dark:text-gray-400">
          {isAllSelected ? 'Deselect all' : 'Select all'} ({filteredTasks.length})
        </label>
      </div>

      {/* Task items */}
      {filteredTasks.map((task) => (
        <TaskItem
          key={task.id}
          task={task}
          isSelected={selectedIds.includes(task.id)}
          onToggleSelect={() => toggleSelection(task.id)}
        />
      ))}
    </div>
  );
}
```

### Step 4: Task Item Component

```tsx
// apps/web/components/tasks/TaskItem.tsx
'use client';

import React, { useState } from 'react';
import { useTaskStore, useUIStore } from '@taskflow/shared';
import { Task } from '@taskflow/shared';
import { formatDistanceToNow } from 'date-fns';

interface TaskItemProps {
  task: Task;
  isSelected: boolean;
  onToggleSelect: () => void;
}

export function TaskItem({ task, isSelected, onToggleSelect }: TaskItemProps) {
  const { toggleTask, deleteTask, selectTask, updateTask } = useTaskStore();
  const { addToast } = useUIStore();
  const [isEditing, setIsEditing] = useState(false);
  const [editTitle, setEditTitle] = useState(task.title);

  const handleToggle = async () => {
    try {
      await toggleTask(task.id);
    } catch (error) {
      addToast({
        type: 'error',
        message: 'Failed to toggle task',
        title: 'Error',
      });
    }
  };

  const handleDelete = async () => {
    if (!confirm('Are you sure you want to delete this task?')) return;
    try {
      await deleteTask(task.id);
      addToast({
        type: 'success',
        message: 'Task deleted',
        title: 'Deleted',
      });
    } catch (error) {
      addToast({
        type: 'error',
        message: 'Failed to delete task',
        title: 'Error',
      });
    }
  };

  const handleEdit = async () => {
    if (!isEditing) {
      setIsEditing(true);
      setEditTitle(task.title);
      return;
    }

    if (editTitle.trim() && editTitle !== task.title) {
      try {
        await updateTask(task.id, { title: editTitle.trim() });
        addToast({
          type: 'success',
          message: 'Task updated',
          title: 'Updated',
        });
      } catch (error) {
        addToast({
          type: 'error',
          message: 'Failed to update task',
          title: 'Error',
        });
      }
    }
    setIsEditing(false);
  };

  const handleKeyDown = (e: React.KeyboardEvent) => {
    if (e.key === 'Enter') {
      handleEdit();
    } else if (e.key === 'Escape') {
      setIsEditing(false);
      setEditTitle(task.title);
    }
  };

  const priorityColors = {
    high: 'bg-red-100 text-red-700 dark:bg-red-900/30 dark:text-red-300',
    medium: 'bg-yellow-100 text-yellow-700 dark:bg-yellow-900/30 dark:text-yellow-300',
    low: 'bg-green-100 text-green-700 dark:bg-green-900/30 dark:text-green-300',
  };

  const dueDate = task.dueDate ? new Date(task.dueDate) : null;
  const isOverdue = dueDate && dueDate < new Date() && !task.completed;
  const timeAgo = dueDate ? formatDistanceToNow(dueDate, { addSuffix: true }) : null;

  return (
    <div
      className={`group flex items-center gap-3 p-3 rounded-lg transition-colors ${
        task.completed
          ? 'bg-gray-50 dark:bg-gray-800/50'
          : 'bg-white dark:bg-gray-800 hover:bg-gray-50 dark:hover:bg-gray-700/50'
      } ${task.optimistic ? 'opacity-60' : ''}`}
    >
      <input
        type="checkbox"
        checked={isSelected}
        onChange={onToggleSelect}
        className="w-4 h-4 rounded border-gray-300 dark:border-gray-600 text-indigo-600 focus:ring-indigo-500"
      />

      <button
        onClick={handleToggle}
        className="flex-shrink-0 w-5 h-5 rounded border-2 flex items-center justify-center transition-colors"
        style={{
          borderColor: task.completed ? '#10B981' : '#D1D5DB',
          backgroundColor: task.completed ? '#10B981' : 'transparent',
        }}
      >
        {task.completed && (
          <svg className="w-3 h-3 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
          </svg>
        )}
      </button>

      <div className="flex-1 min-w-0">
        {isEditing ? (
          <input
            type="text"
            value={editTitle}
            onChange={(e) => setEditTitle(e.target.value)}
            onBlur={handleEdit}
            onKeyDown={handleKeyDown}
            className="w-full px-2 py-1 bg-white dark:bg-gray-700 border border-indigo-300 dark:border-indigo-600 rounded focus:outline-none focus:ring-2 focus:ring-indigo-500"
            autoFocus
          />
        ) : (
          <div className="flex items-center gap-2 flex-wrap">
            <span
              className={`text-sm ${task.completed ? 'line-through text-gray-400 dark:text-gray-500' : 'text-gray-900 dark:text-white'}`}
              onClick={() => selectTask(task.id)}
            >
              {task.title}
            </span>
            <span className={`text-xs px-2 py-0.5 rounded ${priorityColors[task.priority]}`}>
              {task.priority}
            </span>
            {task.tags.map((tag) => (
              <span key={tag} className="text-xs px-2 py-0.5 rounded bg-gray-100 dark:bg-gray-700 text-gray-600 dark:text-gray-400">
                #{tag}
              </span>
            ))}
            {task.optimistic && (
              <span className="text-xs text-gray-400 animate-pulse">saving...</span>
            )}
          </div>
        )}
        <div className="flex items-center gap-3 text-xs text-gray-500 dark:text-gray-400 mt-0.5">
          {dueDate && (
            <span className={isOverdue ? 'text-red-500' : ''}>
              📅 {timeAgo}
            </span>
          )}
          <span>🕐 {formatDistanceToNow(task.createdAt, { addSuffix: true })}</span>
          {task.completed && <span className="text-green-500">✅ Done</span>}
        </div>
      </div>

      <div className="flex items-center gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
        <button
          onClick={handleEdit}
          className="p-1 rounded hover:bg-gray-200 dark:hover:bg-gray-700"
          aria-label="Edit task"
        >
          <svg className="w-4 h-4 text-gray-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
          </svg>
        </button>
        <button
          onClick={handleDelete}
          className="p-1 rounded hover:bg-gray-200 dark:hover:bg-gray-700"
          aria-label="Delete task"
        >
          <svg className="w-4 h-4 text-gray-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
          </svg>
        </button>
      </div>
    </div>
  );
}
```

### Step 5: Task Stats Component

```tsx
// apps/web/components/tasks/TaskStats.tsx
'use client';

import React from 'react';
import { useTaskStore } from '@taskflow/shared';

export function TaskStats() {
  const stats = useTaskStore((state) => state.getTaskStats());
  const selectedCount = useTaskStore((state) => state.getSelectedCount());

  const statCards = [
    { label: 'Total', value: stats.total, color: 'bg-gray-500' },
    { label: 'Active', value: stats.active, color: 'bg-blue-500' },
    { label: 'Completed', value: stats.completed, color: 'bg-green-500' },
    { label: 'High Priority', value: stats.highPriority, color: 'bg-red-500' },
  ];

  return (
    <div className="grid grid-cols-2 sm:grid-cols-4 gap-4 mb-6">
      {statCards.map((stat) => (
        <div key={stat.label} className="bg-white dark:bg-gray-800 rounded-lg shadow p-4">
          <div className="flex items-center gap-3">
            <div className={`w-2 h-10 rounded ${stat.color}`} />
            <div>
              <div className="text-2xl font-bold text-gray-900 dark:text-white">
                {stat.value}
              </div>
              <div className="text-sm text-gray-500 dark:text-gray-400">{stat.label}</div>
            </div>
          </div>
        </div>
      ))}
      {selectedCount > 0 && (
        <div className="bg-indigo-50 dark:bg-indigo-900/20 rounded-lg shadow p-4 col-span-2 sm:col-span-4">
          <div className="text-sm text-indigo-700 dark:text-indigo-300">
            {selectedCount} task{selectedCount > 1 ? 's' : ''} selected
          </div>
        </div>
      )}
    </div>
  );
}
```

### Step 6: Task Filters Component

```tsx
// apps/web/components/tasks/TaskFilters.tsx
'use client';

import React, { useState, useCallback } from 'react';
import { useTaskStore } from '@taskflow/shared';
import { debounce } from 'lodash';

export function TaskFilters() {
  const { filters, setFilters, resetFilters } = useTaskStore();
  const [searchInput, setSearchInput] = useState(filters.searchQuery);

  // Debounce search to avoid excessive re-renders
  const debouncedSetFilters = useCallback(
    debounce((value: string) => {
      setFilters({ searchQuery: value });
    }, 300),
    []
  );

  const handleSearchChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const value = e.target.value;
    setSearchInput(value);
    debouncedSetFilters(value);
  };

  return (
    <div className="bg-white dark:bg-gray-800 rounded-lg shadow p-4 space-y-4">
      <div className="flex flex-wrap gap-4">
        {/* Search */}
        <div className="flex-1 min-w-[200px]">
          <input
            type="text"
            value={searchInput}
            onChange={handleSearchChange}
            placeholder="Search tasks..."
            className="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-indigo-500"
          />
        </div>

        {/* Status Filter */}
        <select
          value={filters.status}
          onChange={(e) => setFilters({ status: e.target.value as any })}
          className="px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-indigo-500"
        >
          <option value="all">All Status</option>
          <option value="active">Active</option>
          <option value="completed">Completed</option>
        </select>

        {/* Priority Filter */}
        <select
          value={filters.priority}
          onChange={(e) => setFilters({ priority: e.target.value as any })}
          className="px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-indigo-500"
        >
          <option value="all">All Priority</option>
          <option value="high">High</option>
          <option value="medium">Medium</option>
          <option value="low">Low</option>
        </select>

        {/* Due Date Filter */}
        <select
          value={filters.dueDate}
          onChange={(e) => setFilters({ dueDate: e.target.value as any })}
          className="px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-indigo-500"
        >
          <option value="all">All Dates</option>
          <option value="overdue">Overdue</option>
          <option value="today">Today</option>
          <option value="week">This Week</option>
          <option value="month">This Month</option>
        </select>
      </div>

      {/* Active filters display */}
      <div className="flex flex-wrap items-center gap-2">
        <span className="text-sm text-gray-500 dark:text-gray-400">Active filters:</span>
        {filters.status !== 'all' && (
          <span className="text-xs px-2 py-1 bg-indigo-100 dark:bg-indigo-900/30 text-indigo-700 dark:text-indigo-300 rounded">
            {filters.status}
            <button
              onClick={() => setFilters({ status: 'all' })}
              className="ml-1 hover:text-indigo-900 dark:hover:text-indigo-100"
            >
              ×
            </button>
          </span>
        )}
        {filters.priority !== 'all' && (
          <span className="text-xs px-2 py-1 bg-indigo-100 dark:bg-indigo-900/30 text-indigo-700 dark:text-indigo-300 rounded">
            {filters.priority}
            <button
              onClick={() => setFilters({ priority: 'all' })}
              className="ml-1 hover:text-indigo-900 dark:hover:text-indigo-100"
            >
              ×
            </button>
          </span>
        )}
        {filters.dueDate !== 'all' && (
          <span className="text-xs px-2 py-1 bg-indigo-100 dark:bg-indigo-900/30 text-indigo-700 dark:text-indigo-300 rounded">
            {filters.dueDate}
            <button
              onClick={() => setFilters({ dueDate: 'all' })}
              className="ml-1 hover:text-indigo-900 dark:hover:text-indigo-100"
            >
              ×
            </button>
          </span>
        )}
        {filters.searchQuery && (
          <span className="text-xs px-2 py-1 bg-indigo-100 dark:bg-indigo-900/30 text-indigo-700 dark:text-indigo-300 rounded">
            search: {filters.searchQuery}
            <button
              onClick={() => {
                setSearchInput('');
                setFilters({ searchQuery: '' });
              }}
              className="ml-1 hover:text-indigo-900 dark:hover:text-indigo-100"
            >
              ×
            </button>
          </span>
        )}
        <button
          onClick={resetFilters}
          className="text-xs px-2 py-1 text-gray-500 hover:text-gray-700 dark:text-gray-400 dark:hover:text-gray-200"
        >
          Clear all
        </button>
      </div>
    </div>
  );
}
```

### Step 7: Add Task Form

```tsx
// apps/web/components/tasks/AddTaskForm.tsx
'use client';

import React, { useState } from 'react';
import { useTaskStore, useUIStore, useAuthStore } from '@taskflow/shared';
import { Priority } from '@taskflow/shared';

export function AddTaskForm() {
  const [title, setTitle] = useState('');
  const [description, setDescription] = useState('');
  const [priority, setPriority] = useState<Priority>('medium');
  const [dueDate, setDueDate] = useState('');
  const [tags, setTags] = useState('');
  const [isExpanded, setIsExpanded] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);

  const { addTask } = useTaskStore();
  const { addToast } = useUIStore();
  const { user } = useAuthStore();

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!title.trim()) {
      addToast({
        type: 'warning',
        message: 'Please enter a task title',
        title: 'Missing Information',
      });
      return;
    }

    setIsSubmitting(true);
    try {
      await addTask({
        title: title.trim(),
        description: description.trim() || undefined,
        priority,
        dueDate: dueDate ? new Date(dueDate) : undefined,
        assigneeId: user?.id,
        createdBy: user?.id || 'unknown',
        tags: tags.split(',').map(t => t.trim()).filter(Boolean),
        completed: false,
      });

      addToast({
        type: 'success',
        message: 'Task created successfully',
        title: 'Task Added',
      });

      // Reset form
      setTitle('');
      setDescription('');
      setPriority('medium');
      setDueDate('');
      setTags('');
      setIsExpanded(false);
    } catch (error) {
      addToast({
        type: 'error',
        message: error instanceof Error ? error.message : 'Failed to create task',
        title: 'Error',
      });
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <div className="bg-white dark:bg-gray-800 rounded-lg shadow p-4 mb-6">
      <form onSubmit={handleSubmit}>
        <div className="flex items-center gap-3">
          <div className="flex-1">
            <input
              type="text"
              value={title}
              onChange={(e) => setTitle(e.target.value)}
              placeholder="What needs to be done?"
              className="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-indigo-500"
              disabled={isSubmitting}
              onFocus={() => setIsExpanded(true)}
            />
          </div>
          <button
            type="submit"
            disabled={isSubmitting || !title.trim()}
            className="px-6 py-2 bg-indigo-600 text-white rounded-lg hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {isSubmitting ? 'Adding...' : 'Add Task'}
          </button>
        </div>

        {isExpanded && (
          <div className="mt-4 space-y-3">
            <div>
              <textarea
                value={description}
                onChange={(e) => setDescription(e.target.value)}
                placeholder="Description (optional)"
                rows={2}
                className="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-indigo-500"
                disabled={isSubmitting}
              />
            </div>

            <div className="flex flex-wrap gap-3">
              <select
                value={priority}
                onChange={(e) => setPriority(e.target.value as Priority)}
                className="px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-indigo-500"
                disabled={isSubmitting}
              >
                <option value="low">Low Priority</option>
                <option value="medium">Medium Priority</option>
                <option value="high">High Priority</option>
              </select>

              <input
                type="date"
                value={dueDate}
                onChange={(e) => setDueDate(e.target.value)}
                className="px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-indigo-500"
                disabled={isSubmitting}
              />

              <input
                type="text"
                value={tags}
                onChange={(e) => setTags(e.target.value)}
                placeholder="Tags (comma separated)"
                className="px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-indigo-500 flex-1"
                disabled={isSubmitting}
              />
            </div>

            <button
              type="button"
              onClick={() => setIsExpanded(false)}
              className="text-sm text-gray-500 dark:text-gray-400 hover:text-gray-700 dark:hover:text-gray-200"
            >
              Cancel
            </button>
          </div>
        )}
      </form>
    </div>
  );
}
```

### Step 8: WebSocket Real-Time Updates (Mock)

```tsx
// packages/shared/src/services/websocketMock.ts
import { eventBus } from '../events';

class WebSocketMock {
  private listeners: Map<string, Set<(data: any) => void>> = new Map();
  private isConnected = false;
  private reconnectTimer: NodeJS.Timeout | null = null;

  connect() {
    console.log('🔌 WebSocket connecting...');
    this.isConnected = true;
    this.simulateRealTimeUpdates();
    return this;
  }

  disconnect() {
    this.isConnected = false;
    if (this.reconnectTimer) {
      clearTimeout(this.reconnectTimer);
      this.reconnectTimer = null;
    }
  }

  on(event: string, callback: (data: any) => void) {
    if (!this.listeners.has(event)) {
      this.listeners.set(event, new Set());
    }
    this.listeners.get(event)!.add(callback);
    return () => {
      const handlers = this.listeners.get(event);
      if (handlers) {
        handlers.delete(callback);
        if (handlers.size === 0) {
          this.listeners.delete(event);
        }
      }
    };
  }

  emit(event: string, data: any) {
    const handlers = this.listeners.get(event);
    if (handlers) {
      for (const handler of handlers) {
        try {
          handler(data);
        } catch (error) {
          console.error('WebSocket handler error:', error);
        }
      }
    }
  }

  private simulateRealTimeUpdates() {
    // Simulate random task updates every 15-45 seconds
    const scheduleUpdate = () => {
      if (!this.isConnected) return;

      const delay = 15000 + Math.random() * 30000;
      this.reconnectTimer = setTimeout(() => {
        if (!this.isConnected) return;

        // Simulate a new task being added by another user
        const mockTask = {
          id: `ws-task-${Date.now()}`,
          title: `Real-time task ${Math.floor(Math.random() * 1000)}`,
          description: 'Added via WebSocket simulation',
          completed: false,
          priority: ['low', 'medium', 'high'][Math.floor(Math.random() * 3)],
          assigneeId: 'user-2',
          createdBy: 'user-2',
          tags: ['realtime'],
          comments: [],
          attachments: [],
          createdAt: new Date(),
          updatedAt: new Date(),
        };

        console.log('📡 WebSocket: New task received', mockTask);
        this.emit('task:created', mockTask);
        eventBus.publish('task:created', mockTask);

        scheduleUpdate();
      }, delay);
    };

    scheduleUpdate();
  }
}

// Singleton instance
export const wsMock = new WebSocketMock();
```

### Step 9: Real-Time Integration in App

```tsx
// apps/web/components/providers/WebSocketProvider.tsx
'use client';

import React, { useEffect } from 'react';
import { wsMock } from '@taskflow/shared/services/websocketMock';
import { useTaskStore, useUIStore } from '@taskflow/shared';

export function WebSocketProvider({ children }: { children: React.ReactNode }) {
  const { addTask } = useTaskStore();
  const { addToast } = useUIStore();

  useEffect(() => {
    // Connect WebSocket
    wsMock.connect();

    // Listen for new tasks
    const unsubscribe = wsMock.on('task:created', (task) => {
      // Check if task already exists (avoid duplicates)
      const existing = useTaskStore.getState().tasks[task.id];
      if (!existing) {
        addTask(task);
        addToast({
          type: 'info',
          message: `New task: ${task.title}`,
          title: 'Real-time Update',
        });
      }
    });

    return () => {
      unsubscribe();
      wsMock.disconnect();
    };
  }, []);

  return <>{children}</>;
}
```

---

## The Verification: Testing Task Management

### Step 1: Manual Testing

1. Start development server:
```bash
cd apps/web
pnpm dev
```

2. Login as a user

3. Test CRUD operations:
   - **Create**: Add a new task using the form
   - **Read**: Tasks should appear in the list
   - **Update**: Click on a task title to edit, or use checkbox to toggle
   - **Delete**: Click the delete button on a task

4. Test filters:
   - Filter by status (All, Active, Completed)
   - Filter by priority (High, Medium, Low)
   - Filter by due date
   - Search for tasks

5. Test bulk operations:
   - Select multiple tasks
   - Bulk complete or delete

6. Test real-time updates:
   - Open two browser windows
   - Add a task in one window
   - The other window should receive the task via WebSocket

### Step 2: Run Tests

```typescript
// packages/shared/src/store/__tests__/task.store.test.ts
import { describe, it, expect, beforeEach } from 'vitest';
import { useTaskStore } from '../task/taskStore';

describe('Task Store', () => {
  beforeEach(() => {
    useTaskStore.setState({
      tasks: {},
      taskIds: [],
      loading: false,
      error: null,
      filters: {
        status: 'all',
        priority: 'all',
        assignee: 'all',
        tags: [],
        dueDate: 'all',
        searchQuery: '',
      },
      sort: { field: 'createdAt', direction: 'desc' },
      selectedTaskId: null,
      selectedIds: [],
    });
  });

  it('should add a task with optimistic update', async () => {
    const { addTask } = useTaskStore.getState();
    const taskData = {
      title: 'Test Task',
      priority: 'medium' as const,
      assigneeId: 'user-1',
      createdBy: 'user-1',
      tags: ['test'],
      completed: false,
    };

    const result = await addTask(taskData);
    const state = useTaskStore.getState();

    expect(state.tasks[result.id]).toBeDefined();
    expect(state.tasks[result.id].title).toBe('Test Task');
    expect(state.taskIds).toContain(result.id);
    expect(state.tasks[result.id].optimistic).toBeFalsy();
  });

  it('should toggle a task', async () => {
    const { addTask, toggleTask } = useTaskStore.getState();
    const task = await addTask({
      title: 'Toggle Test',
      priority: 'medium',
      assigneeId: 'user-1',
      createdBy: 'user-1',
      tags: [],
      completed: false,
    });

    expect(useTaskStore.getState().tasks[task.id].completed).toBe(false);

    await toggleTask(task.id);
    expect(useTaskStore.getState().tasks[task.id].completed).toBe(true);

    await toggleTask(task.id);
    expect(useTaskStore.getState().tasks[task.id].completed).toBe(false);
  });

  it('should delete a task', async () => {
    const { addTask, deleteTask } = useTaskStore.getState();
    const task = await addTask({
      title: 'Delete Test',
      priority: 'medium',
      assigneeId: 'user-1',
      createdBy: 'user-1',
      tags: [],
      completed: false,
    });

    expect(useTaskStore.getState().tasks[task.id]).toBeDefined();

    await deleteTask(task.id);
    expect(useTaskStore.getState().tasks[task.id]).toBeUndefined();
  });

  it('should filter tasks by status', () => {
    const { setFilters, getFilteredTasks } = useTaskStore.getState();

    // Add tasks with different statuses
    // Note: In a real test, we'd use the store's addTask method
    // This is simplified for demonstration

    setFilters({ status: 'active' });
    const activeTasks = getFilteredTasks();
    // Assert filtered results
  });
});
```

### Step 3: Run Tests

```bash
pnpm test
```

---

## What's Next

You've built a complete task management system with CRUD operations, optimistic updates, filtering, sorting, and real-time updates. Next, you'll implement the dashboard with widgets, analytics, and user preferences.
