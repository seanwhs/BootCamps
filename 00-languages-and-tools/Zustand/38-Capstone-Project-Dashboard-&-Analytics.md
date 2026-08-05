# Capstone Project — Phase 4: Dashboard & Analytics

With task management in place, it's time to build the dashboard—the user's command center. The dashboard aggregates task data, displays key metrics, and provides insights through charts and widgets. Users can customize their dashboard layout and track their productivity at a glance.

---

## The Target: Insightful, Customizable Dashboard

By the end of this phase, you'll have:
- A widget-based dashboard with drag-and-drop layout
- Analytics charts (task completion trends, priority distribution)
- Key performance indicators (KPIs) for task management
- User preference persistence for dashboard layout
- Real-time updates to dashboard metrics
- Interactive filtering from dashboard to task list

---

## Implementation: Dashboard & Analytics

### Step 1: Dashboard Types and Store

```typescript
// packages/shared/src/types/dashboard.types.ts
import { ID } from './common.types';
import { Task } from './task.types';

export type WidgetType = 'stats' | 'chart' | 'list' | 'kpi' | 'calendar' | 'custom';

export interface WidgetConfig {
  chartType?: 'bar' | 'line' | 'pie' | 'doughnut';
  dataKey?: string;
  categoryKey?: string;
  metric?: string;
  maxItems?: number;
  refreshInterval?: number;
  [key: string]: any;
}

export interface Widget {
  id: ID;
  type: WidgetType;
  title: string;
  config: WidgetConfig;
  position: { x: number; y: number; w: number; h: number };
  visible: boolean;
  order: number;
  data?: any;
  loading?: boolean;
  error?: string | null;
  lastUpdated?: Date;
}

export interface DashboardPreferences {
  layout: 'grid' | 'list';
  theme: 'light' | 'dark' | 'system';
  refreshInterval: number; // seconds
  widgetOrder: ID[];
  collapsedWidgets: ID[];
  expandedWidgets: ID[];
  version: number;
}

export interface DashboardState {
  widgets: Record<ID, Widget>;
  widgetIds: ID[];
  preferences: DashboardPreferences;
  selectedWidgetId: ID | null;
  isEditing: boolean;
  isLoading: boolean;
  error: string | null;
}

export interface DashboardStats {
  totalTasks: number;
  completedTasks: number;
  activeTasks: number;
  overdueTasks: number;
  completionRate: number;
  highPriorityCount: number;
  mediumPriorityCount: number;
  lowPriorityCount: number;
  tasksByStatus: { status: string; count: number }[];
  tasksByPriority: { priority: string; count: number }[];
  tasksByDay: { date: string; created: number; completed: number }[];
  recentActivity: { taskId: ID; userId: ID; action: string; timestamp: Date }[];
}
```

```typescript
// packages/shared/src/store/dashboard/dashboardStore.ts
import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';
import { immer } from 'zustand/middleware/immer';
import { DashboardState, Widget, WidgetType, WidgetConfig, DashboardPreferences } from '../../types';
import { useTaskStore } from '../task/taskStore';
import { eventBus } from '../../events';

const DEFAULT_WIDGETS: Widget[] = [
  {
    id: 'widget-stats-1',
    type: 'stats',
    title: 'Task Overview',
    config: {},
    position: { x: 0, y: 0, w: 3, h: 2 },
    visible: true,
    order: 0,
  },
  {
    id: 'widget-chart-1',
    type: 'chart',
    title: 'Task Completion Trend',
    config: { chartType: 'line', dataKey: 'completed', categoryKey: 'date' },
    position: { x: 3, y: 0, w: 6, h: 3 },
    visible: true,
    order: 1,
  },
  {
    id: 'widget-chart-2',
    type: 'chart',
    title: 'Priority Distribution',
    config: { chartType: 'pie', dataKey: 'count', categoryKey: 'priority' },
    position: { x: 9, y: 0, w: 3, h: 3 },
    visible: true,
    order: 2,
  },
  {
    id: 'widget-list-1',
    type: 'list',
    title: 'Recent Tasks',
    config: { maxItems: 5 },
    position: { x: 0, y: 2, w: 6, h: 3 },
    visible: true,
    order: 3,
  },
  {
    id: 'widget-kpi-1',
    type: 'kpi',
    title: 'Completion Rate',
    config: { metric: 'completionRate' },
    position: { x: 6, y: 2, w: 3, h: 2 },
    visible: true,
    order: 4,
  },
  {
    id: 'widget-kpi-2',
    type: 'kpi',
    title: 'Overdue Tasks',
    config: { metric: 'overdueCount' },
    position: { x: 9, y: 2, w: 3, h: 2 },
    visible: true,
    order: 5,
  },
  {
    id: 'widget-chart-3',
    type: 'chart',
    title: 'Tasks by Status',
    config: { chartType: 'doughnut', dataKey: 'count', categoryKey: 'status' },
    position: { x: 6, y: 4, w: 3, h: 3 },
    visible: true,
    order: 6,
  },
];

const DEFAULT_PREFERENCES: DashboardPreferences = {
  layout: 'grid',
  theme: 'system',
  refreshInterval: 30,
  widgetOrder: DEFAULT_WIDGETS.map(w => w.id),
  collapsedWidgets: [],
  expandedWidgets: [],
  version: 1,
};

export interface DashboardStore extends DashboardState {
  // Widget management
  addWidget: (widget: Omit<Widget, 'id' | 'order'>) => void;
  removeWidget: (id: ID) => void;
  updateWidget: (id: ID, updates: Partial<Widget>) => void;
  toggleWidgetVisibility: (id: ID) => void;
  moveWidget: (id: ID, x: number, y: number) => void;
  resizeWidget: (id: ID, w: number, h: number) => void;
  reorderWidgets: (fromIndex: number, toIndex: number) => void;
  selectWidget: (id: ID | null) => void;
  toggleEditing: () => void;

  // Preferences
  updatePreferences: (prefs: Partial<DashboardPreferences>) => void;
  toggleWidgetCollapsed: (id: ID) => void;
  toggleWidgetExpanded: (id: ID) => void;

  // Data refresh
  refreshAllWidgets: () => Promise<void>;
  refreshWidget: (id: ID) => Promise<void>;
  setWidgetData: (id: ID, data: any) => void;
  setWidgetLoading: (id: ID, loading: boolean) => void;
  setWidgetError: (id: ID, error: string | null) => void;

  // Analytics
  getDashboardStats: () => DashboardStats;
  getWidgetData: (id: ID) => any;
  getVisibleWidgets: () => Widget[];

  // Reset
  reset: () => void;
}

const initialState: DashboardState = {
  widgets: {},
  widgetIds: [],
  preferences: DEFAULT_PREFERENCES,
  selectedWidgetId: null,
  isEditing: false,
  isLoading: false,
  error: null,
};

export const useDashboardStore = create<DashboardStore>()(
  persist(
    immer((set, get) => {
      // Initialize widgets
      const initialWidgets: Record<string, Widget> = {};
      const initialIds: string[] = [];
      for (const widget of DEFAULT_WIDGETS) {
        initialWidgets[widget.id] = widget;
        initialIds.push(widget.id);
      }

      return {
        ...initialState,
        widgets: initialWidgets,
        widgetIds: initialIds,

        // --- Widget Management ---
        addWidget: (widgetData) => {
          const id = `widget-${Date.now()}`;
          const newWidget: Widget = {
            ...widgetData,
            id,
            order: get().widgetIds.length,
          };
          set((state) => {
            state.widgets[id] = newWidget;
            state.widgetIds.push(id);
            state.preferences.widgetOrder.push(id);
          });
          // Load initial data
          get().refreshWidget(id);
        },

        removeWidget: (id) => {
          set((state) => {
            delete state.widgets[id];
            state.widgetIds = state.widgetIds.filter(wid => wid !== id);
            state.preferences.widgetOrder = state.preferences.widgetOrder.filter(wid => wid !== id);
            if (state.selectedWidgetId === id) {
              state.selectedWidgetId = null;
            }
          });
        },

        updateWidget: (id, updates) => {
          set((state) => {
            if (state.widgets[id]) {
              Object.assign(state.widgets[id], updates);
            }
          });
        },

        toggleWidgetVisibility: (id) => {
          set((state) => {
            const widget = state.widgets[id];
            if (widget) {
              widget.visible = !widget.visible;
            }
          });
        },

        moveWidget: (id, x, y) => {
          set((state) => {
            const widget = state.widgets[id];
            if (widget) {
              widget.position = { ...widget.position, x, y };
            }
          });
        },

        resizeWidget: (id, w, h) => {
          set((state) => {
            const widget = state.widgets[id];
            if (widget) {
              widget.position = { ...widget.position, w, h };
            }
          });
        },

        reorderWidgets: (fromIndex, toIndex) => {
          set((state) => {
            const order = state.preferences.widgetOrder;
            const [removed] = order.splice(fromIndex, 1);
            order.splice(toIndex, 0, removed);
          });
        },

        selectWidget: (id) => {
          set({ selectedWidgetId: id });
        },

        toggleEditing: () => {
          set((state) => ({ isEditing: !state.isEditing }));
        },

        // --- Preferences ---
        updatePreferences: (prefs) => {
          set((state) => {
            Object.assign(state.preferences, prefs);
          });
        },

        toggleWidgetCollapsed: (id) => {
          set((state) => {
            const collapsed = state.preferences.collapsedWidgets;
            const index = collapsed.indexOf(id);
            if (index === -1) {
              collapsed.push(id);
            } else {
              collapsed.splice(index, 1);
            }
          });
        },

        toggleWidgetExpanded: (id) => {
          set((state) => {
            const expanded = state.preferences.expandedWidgets;
            const index = expanded.indexOf(id);
            if (index === -1) {
              expanded.push(id);
            } else {
              expanded.splice(index, 1);
            }
          });
        },

        // --- Data Refresh ---
        refreshAllWidgets: async () => {
          const state = get();
          const promises = state.widgetIds.map(id => state.refreshWidget(id));
          await Promise.allSettled(promises);
        },

        refreshWidget: async (id) => {
          const state = get();
          const widget = state.widgets[id];
          if (!widget) return;

          set({ isLoading: true });
          set((state) => { if (state.widgets[id]) state.widgets[id].loading = true; });

          try {
            // Get fresh data based on widget type
            const data = await fetchWidgetData(widget, state);
            set((state) => {
              if (state.widgets[id]) {
                state.widgets[id].data = data;
                state.widgets[id].loading = false;
                state.widgets[id].error = null;
                state.widgets[id].lastUpdated = new Date();
              }
            });
          } catch (error) {
            set((state) => {
              if (state.widgets[id]) {
                state.widgets[id].loading = false;
                state.widgets[id].error = error instanceof Error ? error.message : 'Failed to load data';
              }
            });
          }
          set({ isLoading: false });
        },

        setWidgetData: (id, data) => {
          set((state) => {
            if (state.widgets[id]) {
              state.widgets[id].data = data;
              state.widgets[id].lastUpdated = new Date();
            }
          });
        },

        setWidgetLoading: (id, loading) => {
          set((state) => {
            if (state.widgets[id]) {
              state.widgets[id].loading = loading;
            }
          });
        },

        setWidgetError: (id, error) => {
          set((state) => {
            if (state.widgets[id]) {
              state.widgets[id].error = error;
            }
          });
        },

        // --- Analytics ---
        getDashboardStats: () => {
          const taskStore = useTaskStore.getState();
          const tasks = taskStore.taskIds.map(id => taskStore.tasks[id]).filter(Boolean);

          const totalTasks = tasks.length;
          const completedTasks = tasks.filter(t => t.completed).length;
          const activeTasks = tasks.filter(t => !t.completed).length;
          const overdueTasks = tasks.filter(t => {
            if (t.completed || !t.dueDate) return false;
            return new Date(t.dueDate) < new Date();
          }).length;
          const completionRate = totalTasks > 0 ? (completedTasks / totalTasks) * 100 : 0;

          const highPriorityCount = tasks.filter(t => t.priority === 'high').length;
          const mediumPriorityCount = tasks.filter(t => t.priority === 'medium').length;
          const lowPriorityCount = tasks.filter(t => t.priority === 'low').length;

          // Tasks by status
          const tasksByStatus = [
            { status: 'Active', count: activeTasks },
            { status: 'Completed', count: completedTasks },
            { status: 'Overdue', count: overdueTasks },
          ];

          // Tasks by priority
          const tasksByPriority = [
            { priority: 'High', count: highPriorityCount },
            { priority: 'Medium', count: mediumPriorityCount },
            { priority: 'Low', count: lowPriorityCount },
          ];

          // Tasks by day (last 7 days)
          const tasksByDay: { date: string; created: number; completed: number }[] = [];
          const today = new Date();
          for (let i = 6; i >= 0; i--) {
            const date = new Date(today);
            date.setDate(date.getDate() - i);
            const dateStr = date.toISOString().split('T')[0];
            const created = tasks.filter(t => 
              new Date(t.createdAt).toISOString().split('T')[0] === dateStr
            ).length;
            const completed = tasks.filter(t => 
              t.completed && new Date(t.updatedAt).toISOString().split('T')[0] === dateStr
            ).length;
            tasksByDay.push({ date: dateStr, created, completed });
          }

          // Recent activity (simplified)
          const recentActivity = tasks
            .slice(-5)
            .map(t => ({
              taskId: t.id,
              userId: t.assigneeId || t.createdBy,
              action: t.completed ? 'completed' : 'created',
              timestamp: t.completed ? t.updatedAt : t.createdAt,
            }));

          return {
            totalTasks,
            completedTasks,
            activeTasks,
            overdueTasks,
            completionRate,
            highPriorityCount,
            mediumPriorityCount,
            lowPriorityCount,
            tasksByStatus,
            tasksByPriority,
            tasksByDay,
            recentActivity,
          };
        },

        getWidgetData: (id) => {
          return get().widgets[id]?.data;
        },

        getVisibleWidgets: () => {
          const state = get();
          return state.widgetIds
            .map(id => state.widgets[id])
            .filter(w => w && w.visible);
        },

        // --- Reset ---
        reset: () => {
          set(initialState);
        },
      };
    }),
    {
      name: 'dashboard-storage',
      storage: createJSONStorage(() => localStorage),
      partialize: (state) => ({
        widgets: state.widgets,
        widgetIds: state.widgetIds,
        preferences: state.preferences,
        // Don't persist: selectedWidgetId, isEditing, isLoading, error
      }),
    }
  )
);

// Helper: Fetch widget data based on type
async function fetchWidgetData(widget: Widget, state: DashboardStore): Promise<any> {
  const taskStore = useTaskStore.getState();
  const tasks = taskStore.taskIds.map(id => taskStore.tasks[id]).filter(Boolean);

  switch (widget.type) {
    case 'stats':
      return state.getDashboardStats();

    case 'chart':
      return state.getDashboardStats();

    case 'list':
      const maxItems = widget.config.maxItems || 5;
      return tasks
        .sort((a, b) => new Date(b.updatedAt).getTime() - new Date(a.updatedAt).getTime())
        .slice(0, maxItems);

    case 'kpi':
      const stats = state.getDashboardStats();
      const metric = widget.config.metric || 'completionRate';
      return {
        ...stats,
        value: stats[metric as keyof typeof stats],
        metric,
      };

    case 'calendar':
      return tasks;

    default:
      return { message: 'Widget type not supported' };
  }
}

// Auto-refresh dashboard widgets
let refreshInterval: NodeJS.Timeout | null = null;

export function startDashboardAutoRefresh() {
  if (refreshInterval) return;
  refreshInterval = setInterval(() => {
    const store = useDashboardStore.getState();
    store.refreshAllWidgets();
  }, 30000); // 30 seconds
}

export function stopDashboardAutoRefresh() {
  if (refreshInterval) {
    clearInterval(refreshInterval);
    refreshInterval = null;
  }
}
```

### Step 2: Widget Renderer Component

```tsx
// apps/web/components/dashboard/WidgetRenderer.tsx
'use client';

import React, { lazy, Suspense } from 'react';
import { useDashboardStore } from '@taskflow/shared';
import { Widget } from '@taskflow/shared';

// Lazy load widget components
const StatsWidget = lazy(() => import('./widgets/StatsWidget'));
const ChartWidget = lazy(() => import('./widgets/ChartWidget'));
const ListWidget = lazy(() => import('./widgets/ListWidget'));
const KPIWidget = lazy(() => import('./widgets/KPIWidget'));
const CalendarWidget = lazy(() => import('./widgets/CalendarWidget'));

interface WidgetRendererProps {
  widgetId: string;
}

export function WidgetRenderer({ widgetId }: WidgetRendererProps) {
  const widget = useDashboardStore((state) => state.widgets[widgetId]);
  const isCollapsed = useDashboardStore((state) =>
    state.preferences.collapsedWidgets.includes(widgetId)
  );
  const isExpanded = useDashboardStore((state) =>
    state.preferences.expandedWidgets.includes(widgetId)
  );
  const toggleCollapsed = useDashboardStore((state) => state.toggleWidgetCollapsed);
  const toggleExpanded = useDashboardStore((state) => state.toggleWidgetExpanded);
  const removeWidget = useDashboardStore((state) => state.removeWidget);
  const refreshWidget = useDashboardStore((state) => state.refreshWidget);
  const isEditing = useDashboardStore((state) => state.isEditing);

  if (!widget) return null;

  const renderWidgetContent = () => {
    if (widget.loading) {
      return (
        <div className="flex items-center justify-center h-32">
          <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-indigo-600"></div>
        </div>
      );
    }

    if (widget.error) {
      return (
        <div className="text-red-500 p-4 text-center">
          <p className="font-medium">Error loading widget</p>
          <p className="text-sm">{widget.error}</p>
          <button
            onClick={() => refreshWidget(widgetId)}
            className="mt-2 text-sm text-indigo-600 hover:text-indigo-800"
          >
            Retry
          </button>
        </div>
      );
    }

    const props = {
      data: widget.data,
      config: widget.config,
      widgetId: widget.id,
    };

    switch (widget.type) {
      case 'stats':
        return (
          <Suspense fallback={<div className="animate-pulse h-32 bg-gray-100 dark:bg-gray-700 rounded" />}>
            <StatsWidget {...props} />
          </Suspense>
        );
      case 'chart':
        return (
          <Suspense fallback={<div className="animate-pulse h-48 bg-gray-100 dark:bg-gray-700 rounded" />}>
            <ChartWidget {...props} />
          </Suspense>
        );
      case 'list':
        return (
          <Suspense fallback={<div className="animate-pulse h-32 bg-gray-100 dark:bg-gray-700 rounded" />}>
            <ListWidget {...props} />
          </Suspense>
        );
      case 'kpi':
        return (
          <Suspense fallback={<div className="animate-pulse h-24 bg-gray-100 dark:bg-gray-700 rounded" />}>
            <KPIWidget {...props} />
          </Suspense>
        );
      case 'calendar':
        return (
          <Suspense fallback={<div className="animate-pulse h-48 bg-gray-100 dark:bg-gray-700 rounded" />}>
            <CalendarWidget {...props} />
          </Suspense>
        );
      default:
        return <div className="text-gray-500 p-4">Widget type not supported</div>;
    }
  };

  if (isCollapsed) {
    return (
      <div className="bg-white dark:bg-gray-800 rounded-lg shadow p-3">
        <div className="flex justify-between items-center">
          <h4 className="font-medium text-gray-900 dark:text-white">{widget.title}</h4>
          <div className="flex gap-1">
            <button
              onClick={() => toggleExpanded(widgetId)}
              className="p-1 rounded hover:bg-gray-100 dark:hover:bg-gray-700"
              aria-label="Expand widget"
            >
              <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 9l-7 7-7-7" />
              </svg>
            </button>
            {isEditing && (
              <button
                onClick={() => removeWidget(widgetId)}
                className="p-1 text-red-500 rounded hover:bg-red-100 dark:hover:bg-red-900/20"
                aria-label="Remove widget"
              >
                <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                </svg>
              </button>
            )}
          </div>
        </div>
      </div>
    );
  }

  const widgetHeight = isExpanded ? 'h-auto' : '';

  return (
    <div className="bg-white dark:bg-gray-800 rounded-lg shadow overflow-hidden">
      <div className="flex justify-between items-center p-3 border-b border-gray-200 dark:border-gray-700">
        <h4 className="font-medium text-gray-900 dark:text-white">{widget.title}</h4>
        <div className="flex gap-1">
          <button
            onClick={() => refreshWidget(widgetId)}
            className="p-1 rounded hover:bg-gray-100 dark:hover:bg-gray-700"
            aria-label="Refresh widget"
          >
            <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
            </svg>
          </button>
          <button
            onClick={() => toggleCollapsed(widgetId)}
            className="p-1 rounded hover:bg-gray-100 dark:hover:bg-gray-700"
            aria-label="Collapse widget"
          >
            <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 15l7-7 7 7" />
            </svg>
          </button>
          {isEditing && (
            <button
              onClick={() => removeWidget(widgetId)}
              className="p-1 text-red-500 rounded hover:bg-red-100 dark:hover:bg-red-900/20"
              aria-label="Remove widget"
            >
              <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
              </svg>
            </button>
          )}
        </div>
      </div>
      <div className={`p-4 ${widgetHeight}`}>
        {renderWidgetContent()}
        {widget.lastUpdated && (
          <div className="mt-2 text-xs text-gray-400">
            Updated: {new Date(widget.lastUpdated).toLocaleString()}
          </div>
        )}
      </div>
    </div>
  );
}
```

### Step 3: Widget Components

```tsx
// apps/web/components/dashboard/widgets/StatsWidget.tsx
'use client';

import React from 'react';

interface StatsWidgetProps {
  data: any;
}

export function StatsWidget({ data }: StatsWidgetProps) {
  if (!data) return null;

  const stats = [
    { label: 'Total Tasks', value: data.totalTasks, color: 'bg-blue-500' },
    { label: 'Active', value: data.activeTasks, color: 'bg-yellow-500' },
    { label: 'Completed', value: data.completedTasks, color: 'bg-green-500' },
    { label: 'Overdue', value: data.overdueTasks, color: 'bg-red-500' },
  ];

  return (
    <div className="grid grid-cols-2 gap-3">
      {stats.map((stat) => (
        <div key={stat.label} className="flex items-center gap-3">
          <div className={`w-1.5 h-8 rounded ${stat.color}`} />
          <div>
            <div className="text-2xl font-bold text-gray-900 dark:text-white">
              {stat.value}
            </div>
            <div className="text-sm text-gray-500 dark:text-gray-400">{stat.label}</div>
          </div>
        </div>
      ))}
    </div>
  );
}
```

```tsx
// apps/web/components/dashboard/widgets/ChartWidget.tsx
'use client';

import React from 'react';
import {
  BarChart, Bar, LineChart, Line, PieChart, Pie, Doughnut,
  XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer,
  Cell
} from 'recharts';

interface ChartWidgetProps {
  data: any;
  config: any;
}

const COLORS = ['#3B82F6', '#10B981', '#F59E0B', '#EF4444', '#8B5CF6', '#EC4899'];

export function ChartWidget({ data, config }: ChartWidgetProps) {
  if (!data) return <div className="text-gray-500 text-sm">No data available</div>;

  const { chartType, dataKey, categoryKey } = config;
  const chartData = getChartData(data, chartType, dataKey, categoryKey);

  if (!chartData || chartData.length === 0) {
    return <div className="text-gray-500 text-sm">No chart data available</div>;
  }

  const renderChart = () => {
    switch (chartType) {
      case 'line':
        return (
          <ResponsiveContainer width="100%" height={200}>
            <LineChart data={chartData}>
              <CartesianGrid strokeDasharray="3 3" stroke="#E5E7EB" />
              <XAxis dataKey={categoryKey || 'name'} stroke="#9CA3AF" />
              <YAxis stroke="#9CA3AF" />
              <Tooltip
                contentStyle={{
                  backgroundColor: 'white',
                  border: '1px solid #E5E7EB',
                  borderRadius: '8px',
                }}
              />
              <Legend />
              {Object.keys(chartData[0]).filter(k => k !== (categoryKey || 'name')).map((key, i) => (
                <Line
                  key={key}
                  type="monotone"
                  dataKey={key}
                  stroke={COLORS[i % COLORS.length]}
                  strokeWidth={2}
                  dot={{ r: 4 }}
                />
              ))}
            </LineChart>
          </ResponsiveContainer>
        );
      case 'bar':
        return (
          <ResponsiveContainer width="100%" height={200}>
            <BarChart data={chartData}>
              <CartesianGrid strokeDasharray="3 3" stroke="#E5E7EB" />
              <XAxis dataKey={categoryKey || 'name'} stroke="#9CA3AF" />
              <YAxis stroke="#9CA3AF" />
              <Tooltip
                contentStyle={{
                  backgroundColor: 'white',
                  border: '1px solid #E5E7EB',
                  borderRadius: '8px',
                }}
              />
              <Legend />
              {Object.keys(chartData[0]).filter(k => k !== (categoryKey || 'name')).map((key, i) => (
                <Bar key={key} dataKey={key} fill={COLORS[i % COLORS.length]} />
              ))}
            </BarChart>
          </ResponsiveContainer>
        );
      case 'pie':
      case 'doughnut':
        return (
          <ResponsiveContainer width="100%" height={200}>
            {chartType === 'pie' ? (
              <PieChart>
                <Pie
                  data={chartData}
                  dataKey={dataKey || 'value'}
                  nameKey={categoryKey || 'name'}
                  cx="50%"
                  cy="50%"
                  outerRadius={80}
                  label
                >
                  {chartData.map((entry: any, index: number) => (
                    <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                  ))}
                </Pie>
                <Tooltip />
                <Legend />
              </PieChart>
            ) : (
              <PieChart>
                <Pie
                  data={chartData}
                  dataKey={dataKey || 'value'}
                  nameKey={categoryKey || 'name'}
                  cx="50%"
                  cy="50%"
                  innerRadius={60}
                  outerRadius={80}
                  label
                >
                  {chartData.map((entry: any, index: number) => (
                    <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                  ))}
                </Pie>
                <Tooltip />
                <Legend />
              </PieChart>
            )}
          </ResponsiveContainer>
        );
      default:
        return <div className="text-gray-500 text-sm">Unsupported chart type</div>;
    }
  };

  return (
    <div className="w-full">
      {renderChart()}
    </div>
  );
}

function getChartData(data: any, chartType: string, dataKey?: string, categoryKey?: string): any[] {
  if (chartType === 'line') {
    // Use tasksByDay data
    return data.tasksByDay || [];
  }

  if (chartType === 'pie' || chartType === 'doughnut') {
    // Use appropriate data based on context
    if (data.tasksByPriority && data.tasksByPriority.length > 0) {
      return data.tasksByPriority;
    }
    if (data.tasksByStatus && data.tasksByStatus.length > 0) {
      return data.tasksByStatus;
    }
    return [];
  }

  return [];
}
```

```tsx
// apps/web/components/dashboard/widgets/KPIWidget.tsx
'use client';

import React from 'react';

interface KPIWidgetProps {
  data: any;
  config: any;
}

export function KPIWidget({ data, config }: KPIWidgetProps) {
  if (!data) return <div className="text-gray-500 text-sm">No data</div>;

  const { metric } = config;

  const getMetricDisplay = () => {
    const value = data.value !== undefined ? data.value : data[metric];

    if (metric === 'completionRate') {
      return `${(value || 0).toFixed(1)}%`;
    }

    if (metric === 'overdueCount') {
      return value || 0;
    }

    return value || 0;
  };

  const getMetricLabel = () => {
    const labels: Record<string, string> = {
      completionRate: 'Completion Rate',
      overdueCount: 'Overdue Tasks',
      totalTasks: 'Total Tasks',
      activeTasks: 'Active Tasks',
      completedTasks: 'Completed Tasks',
      highPriorityCount: 'High Priority',
      mediumPriorityCount: 'Medium Priority',
      lowPriorityCount: 'Low Priority',
    };
    return labels[metric] || metric;
  };

  const getMetricColor = () => {
    const colors: Record<string, string> = {
      completionRate: 'text-green-600 dark:text-green-400',
      overdueCount: 'text-red-600 dark:text-red-400',
      totalTasks: 'text-blue-600 dark:text-blue-400',
      activeTasks: 'text-yellow-600 dark:text-yellow-400',
      completedTasks: 'text-green-600 dark:text-green-400',
      highPriorityCount: 'text-red-600 dark:text-red-400',
      mediumPriorityCount: 'text-yellow-600 dark:text-yellow-400',
      lowPriorityCount: 'text-green-600 dark:text-green-400',
    };
    return colors[metric] || 'text-gray-600 dark:text-gray-400';
  };

  return (
    <div className="text-center">
      <div className={`text-3xl font-bold ${getMetricColor()}`}>
        {getMetricDisplay()}
      </div>
      <div className="text-sm text-gray-500 dark:text-gray-400 mt-1">
        {getMetricLabel()}
      </div>
    </div>
  );
}
```

```tsx
// apps/web/components/dashboard/widgets/ListWidget.tsx
'use client';

import React from 'react';
import { formatDistanceToNow } from 'date-fns';

interface ListWidgetProps {
  data: any;
  config: any;
}

export function ListWidget({ data, config }: ListWidgetProps) {
  if (!data || !Array.isArray(data) || data.length === 0) {
    return <div className="text-gray-500 text-sm text-center py-8">No recent activity</div>;
  }

  const maxItems = config.maxItems || 5;

  return (
    <ul className="divide-y divide-gray-200 dark:divide-gray-700">
      {data.slice(0, maxItems).map((item: any, index: number) => (
        <li key={item.id || index} className="py-3 first:pt-0 last:pb-0">
          <div className="flex justify-between items-start">
            <div className="flex-1 min-w-0">
              <p className="text-sm font-medium text-gray-900 dark:text-white truncate">
                {item.title}
              </p>
              <div className="flex gap-2 mt-0.5">
                {item.priority && (
                  <span className={`text-xs px-2 py-0.5 rounded ${
                    item.priority === 'high' ? 'bg-red-100 text-red-700 dark:bg-red-900/30 dark:text-red-300' :
                    item.priority === 'medium' ? 'bg-yellow-100 text-yellow-700 dark:bg-yellow-900/30 dark:text-yellow-300' :
                    'bg-green-100 text-green-700 dark:bg-green-900/30 dark:text-green-300'
                  }`}>
                    {item.priority}
                  </span>
                )}
                {item.completed !== undefined && (
                  <span className={`text-xs ${item.completed ? 'text-green-500' : 'text-gray-400'}`}>
                    {item.completed ? '✅ Done' : '⏳ Active'}
                  </span>
                )}
              </div>
            </div>
            <span className="text-xs text-gray-400 ml-2">
              {formatDistanceToNow(new Date(item.updatedAt || item.createdAt), { addSuffix: true })}
            </span>
          </div>
        </li>
      ))}
    </ul>
  );
}
```

```tsx
// apps/web/components/dashboard/widgets/CalendarWidget.tsx
'use client';

import React, { useState } from 'react';
import { format, startOfMonth, endOfMonth, eachDayOfInterval, isSameMonth, isToday, isSameDay } from 'date-fns';

interface CalendarWidgetProps {
  data: any;
}

export function CalendarWidget({ data }: CalendarWidgetProps) {
  const [currentDate, setCurrentDate] = useState(new Date());
  const tasks = data || [];

  const monthStart = startOfMonth(currentDate);
  const monthEnd = endOfMonth(currentDate);
  const days = eachDayOfInterval({ start: monthStart, end: monthEnd });

  const getTasksForDay = (day: Date) => {
    return tasks.filter((task: any) => {
      if (!task.dueDate) return false;
      const dueDate = new Date(task.dueDate);
      return isSameDay(dueDate, day);
    });
  };

  return (
    <div>
      <div className="flex justify-between items-center mb-4">
        <button
          onClick={() => setCurrentDate(prev => new Date(prev.getFullYear(), prev.getMonth() - 1, 1))}
          className="p-1 rounded hover:bg-gray-100 dark:hover:bg-gray-700"
        >
          ←
        </button>
        <h4 className="font-medium text-gray-900 dark:text-white">
          {format(currentDate, 'MMMM yyyy')}
        </h4>
        <button
          onClick={() => setCurrentDate(prev => new Date(prev.getFullYear(), prev.getMonth() + 1, 1))}
          className="p-1 rounded hover:bg-gray-100 dark:hover:bg-gray-700"
        >
          →
        </button>
      </div>

      <div className="grid grid-cols-7 gap-1">
        {['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'].map((day) => (
          <div key={day} className="text-center text-xs font-medium text-gray-500 dark:text-gray-400 py-1">
            {day}
          </div>
        ))}
        {days.map((day) => {
          const dayTasks = getTasksForDay(day);
          const isCurrentMonth = isSameMonth(day, currentDate);

          return (
            <div
              key={day.toISOString()}
              className={`text-center p-1 rounded ${
                isCurrentMonth ? 'bg-white dark:bg-gray-800' : 'bg-gray-50 dark:bg-gray-900/50'
              } ${isToday(day) ? 'ring-2 ring-indigo-500' : ''}`}
            >
              <div className={`text-sm font-medium ${isToday(day) ? 'text-indigo-600 dark:text-indigo-400' : ''}`}>
                {format(day, 'd')}
              </div>
              {dayTasks.length > 0 && (
                <div className="mt-0.5">
                  <span className="inline-block w-1.5 h-1.5 bg-indigo-500 rounded-full" />
                  {dayTasks.length > 1 && (
                    <span className="text-[10px] text-gray-400 ml-0.5">
                      +{dayTasks.length - 1}
                    </span>
                  )}
                </div>
              )}
            </div>
          );
        })}
      </div>
    </div>
  );
}
```

### Step 4: Dashboard Editor

```tsx
// apps/web/components/dashboard/DashboardEditor.tsx
'use client';

import React, { useState } from 'react';
import { useDashboardStore } from '@taskflow/shared';
import { WidgetType, WidgetConfig } from '@taskflow/shared';

export function DashboardEditor() {
  const {
    widgets,
    widgetIds,
    isEditing,
    toggleEditing,
    addWidget,
    removeWidget,
    updatePreferences,
    preferences,
  } = useDashboardStore();

  const [newWidgetTitle, setNewWidgetTitle] = useState('');
  const [newWidgetType, setNewWidgetType] = useState<WidgetType>('stats');

  const handleAddWidget = () => {
    if (!newWidgetTitle.trim()) return;

    const config: WidgetConfig = {};
    switch (newWidgetType) {
      case 'chart':
        config.chartType = 'line';
        config.dataKey = 'value';
        config.categoryKey = 'date';
        break;
      case 'kpi':
        config.metric = 'completionRate';
        break;
      case 'list':
        config.maxItems = 5;
        break;
    }

    addWidget({
      type: newWidgetType,
      title: newWidgetTitle.trim(),
      config,
      position: { x: 0, y: 0, w: 3, h: 2 },
      visible: true,
    });

    setNewWidgetTitle('');
  };

  if (!isEditing) {
    return (
      <button
        onClick={toggleEditing}
        className="px-4 py-2 text-sm bg-indigo-600 text-white rounded-lg hover:bg-indigo-700"
      >
        Customize Dashboard
      </button>
    );
  }

  return (
    <div className="fixed inset-0 z-50 bg-black/50 flex items-center justify-center p-4">
      <div className="bg-white dark:bg-gray-800 rounded-lg shadow-xl max-w-2xl w-full max-h-[80vh] overflow-y-auto">
        <div className="p-6">
          <div className="flex justify-between items-center mb-4">
            <h2 className="text-xl font-bold text-gray-900 dark:text-white">
              Dashboard Editor
            </h2>
            <button
              onClick={toggleEditing}
              className="text-gray-500 hover:text-gray-700 dark:text-gray-400 dark:hover:text-gray-200"
            >
              ✕
            </button>
          </div>

          {/* Add widget form */}
          <div className="mb-6 p-4 bg-gray-50 dark:bg-gray-700 rounded-lg">
            <h3 className="font-medium text-gray-900 dark:text-white mb-3">Add Widget</h3>
            <div className="flex flex-wrap gap-3">
              <input
                type="text"
                value={newWidgetTitle}
                onChange={(e) => setNewWidgetTitle(e.target.value)}
                placeholder="Widget title..."
                className="flex-1 px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-600 text-gray-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-indigo-500"
              />
              <select
                value={newWidgetType}
                onChange={(e) => setNewWidgetType(e.target.value as WidgetType)}
                className="px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-600 text-gray-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-indigo-500"
              >
                <option value="stats">Stats</option>
                <option value="chart">Chart</option>
                <option value="list">List</option>
                <option value="kpi">KPI</option>
                <option value="calendar">Calendar</option>
              </select>
              <button
                onClick={handleAddWidget}
                disabled={!newWidgetTitle.trim()}
                className="px-4 py-2 bg-indigo-600 text-white rounded-lg hover:bg-indigo-700 disabled:opacity-50 disabled:cursor-not-allowed"
              >
                Add
              </button>
            </div>
          </div>

          {/* Layout settings */}
          <div className="mb-6 p-4 bg-gray-50 dark:bg-gray-700 rounded-lg">
            <h3 className="font-medium text-gray-900 dark:text-white mb-3">Layout Settings</h3>
            <div className="flex flex-wrap gap-4">
              <div>
                <label className="block text-sm text-gray-600 dark:text-gray-400 mb-1">Layout</label>
                <select
                  value={preferences.layout}
                  onChange={(e) => updatePreferences({ layout: e.target.value as 'grid' | 'list' })}
                  className="px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-600 text-gray-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-indigo-500"
                >
                  <option value="grid">Grid</option>
                  <option value="list">List</option>
                </select>
              </div>
              <div>
                <label className="block text-sm text-gray-600 dark:text-gray-400 mb-1">Refresh Interval</label>
                <select
                  value={preferences.refreshInterval}
                  onChange={(e) => updatePreferences({ refreshInterval: parseInt(e.target.value) })}
                  className="px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-600 text-gray-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-indigo-500"
                >
                  <option value={15}>15 sec</option>
                  <option value={30}>30 sec</option>
                  <option value={60}>1 min</option>
                  <option value={300}>5 min</option>
                </select>
              </div>
            </div>
          </div>

          {/* Current widgets */}
          <div>
            <h3 className="font-medium text-gray-900 dark:text-white mb-3">
              Current Widgets ({widgetIds.length})
            </h3>
            <div className="space-y-2 max-h-40 overflow-y-auto">
              {widgetIds.map(id => {
                const widget = widgets[id];
                return (
                  <div
                    key={id}
                    className="flex justify-between items-center p-2 bg-gray-50 dark:bg-gray-700 rounded-lg"
                  >
                    <div className="flex items-center gap-2">
                      <span className="text-sm text-gray-900 dark:text-white">
                        {widget.title}
                      </span>
                      <span className="text-xs px-2 py-0.5 bg-gray-200 dark:bg-gray-600 rounded text-gray-600 dark:text-gray-400">
                        {widget.type}
                      </span>
                      {!widget.visible && (
                        <span className="text-xs text-gray-400">(hidden)</span>
                      )}
                    </div>
                    <div className="flex gap-1">
                      <button
                        onClick={() => {
                          const store = useDashboardStore.getState();
                          store.toggleWidgetVisibility(id);
                        }}
                        className={`p-1 rounded hover:bg-gray-200 dark:hover:bg-gray-600 text-xs ${
                          widget.visible ? 'text-green-500' : 'text-gray-400'
                        }`}
                      >
                        {widget.visible ? '👁️' : '👁️‍🗨️'}
                      </button>
                      <button
                        onClick={() => removeWidget(id)}
                        className="p-1 text-red-500 rounded hover:bg-red-100 dark:hover:bg-red-900/20"
                      >
                        ✕
                      </button>
                    </div>
                  </div>
                );
              })}
            </div>
            {widgetIds.length === 0 && (
              <p className="text-sm text-gray-500 dark:text-gray-400">No widgets added yet.</p>
            )}
          </div>

          <div className="mt-6 flex justify-end gap-2">
            <button
              onClick={toggleEditing}
              className="px-4 py-2 bg-indigo-600 text-white rounded-lg hover:bg-indigo-700"
            >
              Done
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
```

### Step 5: Dashboard Page

```tsx
// apps/web/app/(dashboard)/dashboard/page.tsx
'use client';

import React, { useEffect } from 'react';
import { useDashboardStore, startDashboardAutoRefresh, stopDashboardAutoRefresh } from '@taskflow/shared';
import { WidgetRenderer } from '@/components/dashboard/WidgetRenderer';
import { DashboardEditor } from '@/components/dashboard/DashboardEditor';
import { useTaskStore } from '@taskflow/shared';

export default function DashboardPage() {
  const {
    getVisibleWidgets,
    refreshAllWidgets,
    isLoading,
    error,
    preferences,
    isEditing,
  } = useDashboardStore();

  const { fetchTasks, taskIds } = useTaskStore();

  useEffect(() => {
    // Load tasks first
    fetchTasks().then(() => {
      refreshAllWidgets();
    });

    // Start auto-refresh
    startDashboardAutoRefresh();

    return () => {
      stopDashboardAutoRefresh();
    };
  }, []);

  const visibleWidgets = getVisibleWidgets();

  if (isLoading && visibleWidgets.length === 0) {
    return (
      <div className="flex justify-center items-center h-64">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-indigo-600" />
      </div>
    );
  }

  if (error) {
    return (
      <div className="text-red-500 p-4">
        <p className="font-medium">Error loading dashboard</p>
        <p className="text-sm">{error}</p>
      </div>
    );
  }

  if (visibleWidgets.length === 0) {
    return (
      <div className="text-center py-12">
        <svg className="mx-auto h-12 w-12 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 6a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2H6a2 2 0 01-2-2V6zm10 0a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2h-2a2 2 0 01-2-2V6zM4 16a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2H6a2 2 0 01-2-2v-2zm10 0a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2h-2a2 2 0 01-2-2v-2z" />
        </svg>
        <h3 className="mt-2 text-sm font-medium text-gray-900 dark:text-white">No widgets</h3>
        <p className="mt-1 text-sm text-gray-500 dark:text-gray-400">
          Click "Customize Dashboard" to add widgets.
        </p>
      </div>
    );
  }

  return (
    <div>
      <div className="flex justify-between items-center mb-6">
        <h2 className="text-2xl font-bold text-gray-900 dark:text-white">Dashboard</h2>
        <DashboardEditor />
      </div>

      {preferences.layout === 'grid' ? (
        <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-4">
          {visibleWidgets.map((widget) => (
            <div
              key={widget.id}
              className={`${isEditing ? 'ring-2 ring-indigo-500 ring-offset-2' : ''}`}
              style={{
                gridColumn: `span ${widget.position.w || 1}`,
                gridRow: `span ${widget.position.h || 1}`,
              }}
            >
              <WidgetRenderer widgetId={widget.id} />
            </div>
          ))}
        </div>
      ) : (
        <div className="space-y-4">
          {visibleWidgets.map((widget) => (
            <div key={widget.id} className={isEditing ? 'ring-2 ring-indigo-500 ring-offset-2' : ''}>
              <WidgetRenderer widgetId={widget.id} />
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
```

### Step 6: Performance Analytics

```typescript
// packages/shared/src/services/analytics.ts
import { useTaskStore } from '../store/task/taskStore';

export interface PerformanceReport {
  totalTasks: number;
  completedTasks: number;
  activeTasks: number;
  overdueTasks: number;
  averageCompletionTime: number; // in hours
  productivityScore: number; // 0-100
  completionRate: number; // percentage
  tasksByDay: Record<string, number>;
  tasksByPriority: Record<string, number>;
}

export function generatePerformanceReport(): PerformanceReport {
  const taskStore = useTaskStore.getState();
  const tasks = taskStore.taskIds.map(id => taskStore.tasks[id]).filter(Boolean);

  const totalTasks = tasks.length;
  const completedTasks = tasks.filter(t => t.completed).length;
  const activeTasks = tasks.filter(t => !t.completed).length;
  const overdueTasks = tasks.filter(t => {
    if (t.completed || !t.dueDate) return false;
    return new Date(t.dueDate) < new Date();
  }).length;

  // Average completion time for completed tasks
  const completedWithDates = tasks.filter(t => t.completed && t.createdAt);
  const totalCompletionTime = completedWithDates.reduce((sum, t) => {
    const completionTime = t.updatedAt.getTime() - t.createdAt.getTime();
    return sum + completionTime;
  }, 0);
  const averageCompletionTime = completedWithDates.length > 0
    ? totalCompletionTime / completedWithDates.length / (1000 * 60 * 60) // in hours
    : 0;

  // Productivity score
  const completionRate = totalTasks > 0 ? (completedTasks / totalTasks) * 100 : 0;
  const productivityScore = Math.min(
    100,
    (completionRate * 0.6) +
    (1 - Math.min(1, overdueTasks / Math.max(1, totalTasks))) * 0.4
  );

  // Tasks by day (last 7 days)
  const tasksByDay: Record<string, number> = {};
  const today = new Date();
  for (let i = 6; i >= 0; i--) {
    const date = new Date(today);
    date.setDate(date.getDate() - i);
    const dateStr = date.toISOString().split('T')[0];
    tasksByDay[dateStr] = tasks.filter(t =>
      new Date(t.createdAt).toISOString().split('T')[0] === dateStr
    ).length;
  }

  // Tasks by priority
  const tasksByPriority: Record<string, number> = {
    high: tasks.filter(t => t.priority === 'high').length,
    medium: tasks.filter(t => t.priority === 'medium').length,
    low: tasks.filter(t => t.priority === 'low').length,
  };

  return {
    totalTasks,
    completedTasks,
    activeTasks,
    overdueTasks,
    averageCompletionTime,
    productivityScore,
    completionRate,
    tasksByDay,
    tasksByPriority,
  };
}
```

---

## The Verification: Testing Dashboard

### Step 1: Manual Testing

1. Start development server:
   ```bash
   cd apps/web
   pnpm dev
   ```

2. Login and navigate to `/dashboard`

3. Test dashboard features:
   - **View widgets**: Stats, charts, lists should display data
   - **Refresh**: Click refresh icon on any widget
   - **Collapse/Expand**: Click collapse/expand on widgets
   - **Customize**: Click "Customize Dashboard" to enter edit mode
   - **Add widget**: Add new widgets of different types
   - **Remove widget**: Remove widgets from dashboard
   - **Toggle visibility**: Show/hide widgets
   - **Change layout**: Switch between grid and list

4. Verify dashboard data:
   - Stats match task data
   - Charts update when tasks change
   - Real-time updates reflect in dashboard

### Step 2: Run Tests

```typescript
// packages/shared/src/store/__tests__/dashboard.store.test.ts
import { describe, it, expect, beforeEach } from 'vitest';
import { useDashboardStore } from '../dashboard/dashboardStore';
import { useTaskStore } from '../task/taskStore';

describe('Dashboard Store', () => {
  beforeEach(() => {
    useDashboardStore.setState({
      widgets: {},
      widgetIds: [],
      preferences: {
        layout: 'grid',
        theme: 'system',
        refreshInterval: 30,
        widgetOrder: [],
        collapsedWidgets: [],
        expandedWidgets: [],
        version: 1,
      },
      selectedWidgetId: null,
      isEditing: false,
      isLoading: false,
      error: null,
    });
  });

  it('should add a widget', () => {
    const { addWidget } = useDashboardStore.getState();
    addWidget({
      type: 'stats',
      title: 'Test Stats',
      config: {},
      position: { x: 0, y: 0, w: 3, h: 2 },
      visible: true,
    });

    const state = useDashboardStore.getState();
    expect(state.widgetIds).toHaveLength(1);
    expect(state.widgets[state.widgetIds[0]].title).toBe('Test Stats');
  });

  it('should remove a widget', () => {
    const { addWidget, removeWidget } = useDashboardStore.getState();
    addWidget({
      type: 'stats',
      title: 'Test Stats',
      config: {},
      position: { x: 0, y: 0, w: 3, h: 2 },
      visible: true,
    });

    const widgetId = useDashboardStore.getState().widgetIds[0];
    removeWidget(widgetId);

    const state = useDashboardStore.getState();
    expect(state.widgetIds).toHaveLength(0);
    expect(state.widgets[widgetId]).toBeUndefined();
  });

  it('should get dashboard stats', () => {
    const { getDashboardStats } = useDashboardStore.getState();
    const stats = getDashboardStats();

    expect(stats).toHaveProperty('totalTasks');
    expect(stats).toHaveProperty('completedTasks');
    expect(stats).toHaveProperty('activeTasks');
    expect(stats).toHaveProperty('completionRate');
    expect(stats.tasksByStatus).toBeInstanceOf(Array);
  });
});
```

### Step 3: Run Tests

```bash
pnpm test
```

---

## What's Next

You've built a powerful, customizable dashboard with analytics, charts, and widgets. Next, you'll implement real-time features including WebSocket integration, live notifications, and user presence tracking.
