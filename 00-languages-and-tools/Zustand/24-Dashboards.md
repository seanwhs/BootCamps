# Part 6 — Production Patterns

## Section 24: Dashboards

Dashboards are the nerve centers of many applications—they aggregate data, display key metrics, and allow users to filter, sort, and customize views. Building a dashboard that is fast, responsive, and maintainable requires careful state management. In this section, you'll learn how to use Zustand to build a powerful dashboard with filters, user preferences, widget state, and efficient data caching.

---

## The Target: Production-Ready Dashboard State

By the end of this section, you'll be able to:
- Manage dashboard filters and user preferences
- Implement widget-based layouts with state persistence
- Cache API responses to reduce network calls
- Handle real-time updates with polling or WebSockets
- Optimize rendering for large datasets
- Allow users to customize their dashboard view

---

## The Concept: Dashboard as a Composite of Widgets

Think of a dashboard like a **control room**:

```
┌─────────────────────────────────────────────────────────────────┐
│                    DASHBOARD ARCHITECTURE                      │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Dashboard Store                                        │  │
│  │  • Widget definitions                                   │  │
│  │  • User preferences (layout, visible widgets)           │  │
│  │  • Filters (date range, categories, etc.)               │  │
│  │  • Cached data per widget                               │  │
│  └──────────────────────────────────────────────────────────┘  │
│                         │                                      │
│            ┌────────────┼────────────┐                        │
│            │            │            │                        │
│            ▼            ▼            ▼                        │
│  ┌──────────────────┐ ┌──────────────┐ ┌──────────────────┐ │
│  │  Widget A        │ │  Widget B    │ │  Widget C        │ │
│  │  (Sales Chart)   │ │  (User List) │ │  (Stats Cards)   │ │
│  └──────────────────┘ └──────────────┘ └──────────────────┘ │
│            │            │            │                        │
│            ▼            ▼            ▼                        │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Data Sources (API, WebSocket, Cache)                   │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

**Key Principles**:
- Each widget is independent but shares common filters
- Preferences (layout, visible widgets) are persisted
- Caching prevents redundant API calls
- Optimistic updates and skeleton loading improve UX

---

## The Implementation: Dashboard Store

### Step 1: Define Types

```typescript
// src/types/dashboard.types.ts
export interface Widget {
  id: string;
  type: 'chart' | 'table' | 'stats' | 'list' | 'custom';
  title: string;
  config: WidgetConfig;
  visible: boolean;
  position: { x: number; y: number; w: number; h: number };
}

export type WidgetConfig = 
  | { chartType: 'line' | 'bar' | 'pie'; dataKey: string; categoryKey: string }
  | { columns: string[]; pageSize: number }
  | { metric: 'revenue' | 'users' | 'orders' | 'conversion' }
  | { source: string; maxItems: number }
  | Record<string, any>;

export interface DashboardFilters {
  dateRange: { start: Date; end: Date };
  categories: string[];
  status: string[];
  searchQuery: string;
  sortBy: string;
  sortDirection: 'asc' | 'desc';
}

export interface DashboardPreferences {
  layout: 'grid' | 'list';
  theme: 'light' | 'dark';
  refreshInterval: number; // seconds
  widgetOrder: string[];
  collapsedWidgets: string[];
}

export interface DashboardState {
  widgets: Record<string, Widget>;
  widgetIds: string[];
  filters: DashboardFilters;
  preferences: DashboardPreferences;
  cache: Record<string, { data: any; timestamp: number; ttl: number }>;
  isLoading: Record<string, boolean>;
  errors: Record<string, string | null>;
}
```

### Step 2: Create the Dashboard Store

```typescript
// src/store/dashboardStore.ts
import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';
import { immer } from 'zustand/middleware/immer';
import { DashboardState, Widget, DashboardFilters, DashboardPreferences } from '../types/dashboard.types';

// Initial state
const defaultFilters: DashboardFilters = {
  dateRange: { start: new Date(Date.now() - 30 * 24 * 60 * 60 * 1000), end: new Date() },
  categories: [],
  status: [],
  searchQuery: '',
  sortBy: 'date',
  sortDirection: 'desc',
};

const defaultPreferences: DashboardPreferences = {
  layout: 'grid',
  theme: 'light',
  refreshInterval: 60,
  widgetOrder: [],
  collapsedWidgets: [],
};

interface DashboardStore extends DashboardState {
  // Widget management
  addWidget: (widget: Omit<Widget, 'id'>) => void;
  removeWidget: (id: string) => void;
  updateWidget: (id: string, updates: Partial<Widget>) => void;
  toggleWidgetVisibility: (id: string) => void;
  moveWidget: (id: string, x: number, y: number) => void;
  resizeWidget: (id: string, w: number, h: number) => void;
  reorderWidgets: (fromIndex: number, toIndex: number) => void;

  // Filters
  setFilters: (filters: Partial<DashboardFilters>) => void;
  resetFilters: () => void;

  // Preferences
  updatePreferences: (prefs: Partial<DashboardPreferences>) => void;
  toggleWidgetCollapsed: (id: string) => void;

  // Data fetching and caching
  fetchWidgetData: (widgetId: string) => Promise<void>;
  refreshAll: () => Promise<void>;
  clearCache: () => void;
  setLoading: (widgetId: string, loading: boolean) => void;
  setError: (widgetId: string, error: string | null) => void;

  // Utilities
  getFilteredData: (widgetId: string) => any;
  getWidget: (id: string) => Widget | undefined;
  getVisibleWidgets: () => Widget[];
}

export const useDashboardStore = create<DashboardStore>()(
  persist(
    immer((set, get) => ({
      // Initial state
      widgets: {},
      widgetIds: [],
      filters: defaultFilters,
      preferences: defaultPreferences,
      cache: {},
      isLoading: {},
      errors: {},

      // --- Widget Management ---
      addWidget: (widgetData) => {
        const id = `widget-${Date.now()}`;
        const newWidget: Widget = { ...widgetData, id, visible: true };
        set((state) => {
          state.widgets[id] = newWidget;
          state.widgetIds.push(id);
          state.preferences.widgetOrder.push(id);
        });
        // Optionally fetch initial data
        get().fetchWidgetData(id);
      },

      removeWidget: (id) => {
        set((state) => {
          delete state.widgets[id];
          state.widgetIds = state.widgetIds.filter(wid => wid !== id);
          state.preferences.widgetOrder = state.preferences.widgetOrder.filter(wid => wid !== id);
          delete state.isLoading[id];
          delete state.errors[id];
          delete state.cache[id];
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

      // --- Filters ---
      setFilters: (filters) => {
        set((state) => {
          Object.assign(state.filters, filters);
        });
        // Invalidate cache when filters change
        set({ cache: {} });
        // Refresh all widgets
        get().refreshAll();
      },

      resetFilters: () => {
        set({ filters: defaultFilters });
        set({ cache: {} });
        get().refreshAll();
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

      // --- Data Fetching & Caching ---
      fetchWidgetData: async (widgetId) => {
        const state = get();
        const widget = state.widgets[widgetId];
        if (!widget) return;

        // Check cache
        const cacheKey = `${widgetId}-${JSON.stringify(state.filters)}`;
        const cached = state.cache[cacheKey];
        if (cached && Date.now() - cached.timestamp < cached.ttl) {
          // Cache hit
          return;
        }

        set({ isLoading: { ...state.isLoading, [widgetId]: true } });

        try {
          // Build request based on widget type and filters
          const data = await fetchDataForWidget(widget, state.filters);
          const ttl = 60000; // 1 minute default
          set((state) => {
            state.cache[cacheKey] = { data, timestamp: Date.now(), ttl };
            state.isLoading[widgetId] = false;
            state.errors[widgetId] = null;
          });
        } catch (error) {
          set((state) => {
            state.isLoading[widgetId] = false;
            state.errors[widgetId] = error instanceof Error ? error.message : 'Failed to load data';
          });
        }
      },

      refreshAll: async () => {
        const state = get();
        const promises = state.widgetIds.map(id => state.fetchWidgetData(id));
        await Promise.all(promises);
      },

      clearCache: () => {
        set({ cache: {} });
      },

      setLoading: (widgetId, loading) => {
        set((state) => {
          state.isLoading[widgetId] = loading;
        });
      },

      setError: (widgetId, error) => {
        set((state) => {
          state.errors[widgetId] = error;
        });
      },

      // --- Utilities ---
      getFilteredData: (widgetId) => {
        const state = get();
        const cacheKey = `${widgetId}-${JSON.stringify(state.filters)}`;
        const cached = state.cache[cacheKey];
        return cached ? cached.data : null;
      },

      getWidget: (id) => {
        return get().widgets[id];
      },

      getVisibleWidgets: () => {
        const state = get();
        return state.widgetIds
          .map(id => state.widgets[id])
          .filter(w => w && w.visible);
      },
    })),
    {
      name: 'dashboard-storage',
      storage: createJSONStorage(() => localStorage),
      partialize: (state) => ({
        widgets: state.widgets,
        widgetIds: state.widgetIds,
        preferences: state.preferences,
        // Don't persist filters (they may be session-based) or cache
      }),
    }
  )
);

// Helper: fetch data for a widget based on its config and filters
async function fetchDataForWidget(widget: Widget, filters: DashboardFilters): Promise<any> {
  // In production, this would call an API
  // Simulate network delay
  await new Promise(resolve => setTimeout(resolve, 500 + Math.random() * 500));

  // Return mock data based on widget type
  switch (widget.type) {
    case 'chart':
      return generateChartData(widget.config, filters);
    case 'table':
      return generateTableData(widget.config, filters);
    case 'stats':
      return generateStatsData(widget.config, filters);
    case 'list':
      return generateListData(widget.config, filters);
    default:
      return { message: 'No data' };
  }
}

function generateChartData(config: any, filters: DashboardFilters) {
  // Return sample chart data
  const points = 20;
  const data = [];
  const start = filters.dateRange.start.getTime();
  const end = filters.dateRange.end.getTime();
  const step = (end - start) / points;
  for (let i = 0; i < points; i++) {
    data.push({
      date: new Date(start + i * step),
      value: Math.floor(Math.random() * 100) + 10,
    });
  }
  return data;
}

function generateTableData(config: any, filters: DashboardFilters) {
  const columns = config.columns || ['id', 'name', 'status', 'date'];
  const rows = [];
  for (let i = 0; i < 10; i++) {
    const row: any = {};
    for (const col of columns) {
      if (col === 'id') row.id = i + 1;
      else if (col === 'name') row.name = `Item ${i + 1}`;
      else if (col === 'status') row.status = ['active', 'pending', 'completed'][i % 3];
      else if (col === 'date') row.date = new Date(Date.now() - i * 86400000).toISOString();
      else row[col] = `value ${i}`;
    }
    rows.push(row);
  }
  return { columns, rows };
}

function generateStatsData(config: any, filters: DashboardFilters) {
  const metric = config.metric || 'revenue';
  return {
    metric,
    value: Math.floor(Math.random() * 10000) + 1000,
    change: (Math.random() * 20 - 10).toFixed(1),
    trend: Math.random() > 0.5 ? 'up' : 'down',
  };
}

function generateListData(config: any, filters: DashboardFilters) {
  const source = config.source || 'items';
  const maxItems = config.maxItems || 5;
  const items = [];
  for (let i = 0; i < maxItems; i++) {
    items.push({
      id: i + 1,
      title: `${source} #${i + 1}`,
      description: `Description for item ${i + 1}`,
      timestamp: new Date(Date.now() - i * 3600000).toISOString(),
    });
  }
  return items;
}
```

### Step 3: Dashboard Component with React

```tsx
// src/components/Dashboard.tsx
'use client';

import React, { useEffect, useState } from 'react';
import { useDashboardStore } from '../store/dashboardStore';
import { WidgetRenderer } from './WidgetRenderer';
import { FilterBar } from './FilterBar';
import { DashboardSettings } from './DashboardSettings';

export function Dashboard() {
  const {
    widgets,
    widgetIds,
    preferences,
    getVisibleWidgets,
    refreshAll,
    clearCache,
    fetchWidgetData,
  } = useDashboardStore();

  const [isInitialized, setIsInitialized] = useState(false);

  // Load initial data
  useEffect(() => {
    const init = async () => {
      await refreshAll();
      setIsInitialized(true);
    };
    init();

    // Set up polling based on refresh interval
    const interval = setInterval(() => {
      if (preferences.refreshInterval > 0) {
        refreshAll();
      }
    }, preferences.refreshInterval * 1000);

    return () => clearInterval(interval);
  }, []);

  const visibleWidgets = getVisibleWidgets();

  if (!isInitialized) {
    return (
      <div className="flex justify-center items-center h-64">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
      </div>
    );
  }

  return (
    <div className="container mx-auto p-4">
      <div className="flex justify-between items-center mb-6">
        <h1 className="text-3xl font-bold">Dashboard</h1>
        <div className="flex gap-2">
          <button
            onClick={refreshAll}
            className="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700"
          >
            Refresh All
          </button>
          <button
            onClick={clearCache}
            className="px-4 py-2 border border-gray-300 rounded hover:bg-gray-100"
          >
            Clear Cache
          </button>
          <DashboardSettings />
        </div>
      </div>

      <FilterBar />

      {preferences.layout === 'grid' ? (
        <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-4">
          {visibleWidgets.map((widget) => (
            <div key={widget.id} className="bg-white rounded-lg shadow p-4">
              <WidgetRenderer widgetId={widget.id} />
            </div>
          ))}
        </div>
      ) : (
        <div className="space-y-4">
          {visibleWidgets.map((widget) => (
            <div key={widget.id} className="bg-white rounded-lg shadow p-4">
              <WidgetRenderer widgetId={widget.id} />
            </div>
          ))}
        </div>
      )}

      {visibleWidgets.length === 0 && (
        <div className="text-center py-12 text-gray-500">
          No widgets visible. Add some from settings.
        </div>
      )}
    </div>
  );
}
```

### Step 4: Widget Renderer

```tsx
// src/components/WidgetRenderer.tsx
'use client';

import React from 'react';
import { useDashboardStore } from '../store/dashboardStore';
import { ChartWidget } from './widgets/ChartWidget';
import { TableWidget } from './widgets/TableWidget';
import { StatsWidget } from './widgets/StatsWidget';
import { ListWidget } from './widgets/ListWidget';
import { WidgetLoading } from './widgets/WidgetLoading';

interface WidgetRendererProps {
  widgetId: string;
}

export function WidgetRenderer({ widgetId }: WidgetRendererProps) {
  const widget = useDashboardStore((state) => state.getWidget(widgetId));
  const isLoading = useDashboardStore((state) => state.isLoading[widgetId]);
  const error = useDashboardStore((state) => state.errors[widgetId]);
  const data = useDashboardStore((state) => state.getFilteredData(widgetId));
  const toggleCollapsed = useDashboardStore((state) => state.toggleWidgetCollapsed);
  const isCollapsed = useDashboardStore((state) =>
    state.preferences.collapsedWidgets.includes(widgetId)
  );

  if (!widget) return null;

  const renderWidgetContent = () => {
    if (isLoading) return <WidgetLoading />;
    if (error) return <div className="text-red-500">Error: {error}</div>;
    if (!data) return <div className="text-gray-500">No data available</div>;

    switch (widget.type) {
      case 'chart':
        return <ChartWidget data={data} config={widget.config} />;
      case 'table':
        return <TableWidget data={data} config={widget.config} />;
      case 'stats':
        return <StatsWidget data={data} config={widget.config} />;
      case 'list':
        return <ListWidget data={data} config={widget.config} />;
      default:
        return <div>Unknown widget type</div>;
    }
  };

  return (
    <div className="widget-container">
      <div className="flex justify-between items-center mb-2">
        <h3 className="font-semibold text-lg">{widget.title}</h3>
        <div className="flex gap-2">
          <button
            onClick={() => toggleCollapsed(widgetId)}
            className="text-gray-500 hover:text-gray-700"
          >
            {isCollapsed ? 'Expand' : 'Collapse'}
          </button>
        </div>
      </div>
      {!isCollapsed && (
        <div className="widget-content min-h-[100px]">
          {renderWidgetContent()}
        </div>
      )}
    </div>
  );
}
```

### Step 5: Filter Bar Component

```tsx
// src/components/FilterBar.tsx
'use client';

import React, { useState } from 'react';
import { useDashboardStore } from '../store/dashboardStore';

export function FilterBar() {
  const { filters, setFilters, resetFilters } = useDashboardStore();
  const [dateStart, setDateStart] = useState(
    filters.dateRange.start.toISOString().split('T')[0]
  );
  const [dateEnd, setDateEnd] = useState(
    filters.dateRange.end.toISOString().split('T')[0]
  );
  const [search, setSearch] = useState(filters.searchQuery);
  const [categories, setCategories] = useState(filters.categories.join(', '));
  const [status, setStatus] = useState(filters.status.join(', '));

  const handleApply = () => {
    setFilters({
      dateRange: {
        start: new Date(dateStart),
        end: new Date(dateEnd),
      },
      searchQuery: search,
      categories: categories.split(',').map(s => s.trim()).filter(Boolean),
      status: status.split(',').map(s => s.trim()).filter(Boolean),
    });
  };

  return (
    <div className="bg-gray-50 p-4 rounded-lg mb-6">
      <div className="grid grid-cols-1 md:grid-cols-3 lg:grid-cols-5 gap-4">
        <div>
          <label className="block text-sm font-medium text-gray-700">Date From</label>
          <input
            type="date"
            value={dateStart}
            onChange={(e) => setDateStart(e.target.value)}
            className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
          />
        </div>
        <div>
          <label className="block text-sm font-medium text-gray-700">Date To</label>
          <input
            type="date"
            value={dateEnd}
            onChange={(e) => setDateEnd(e.target.value)}
            className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
          />
        </div>
        <div>
          <label className="block text-sm font-medium text-gray-700">Search</label>
          <input
            type="text"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            placeholder="Search..."
            className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
          />
        </div>
        <div>
          <label className="block text-sm font-medium text-gray-700">Categories</label>
          <input
            type="text"
            value={categories}
            onChange={(e) => setCategories(e.target.value)}
            placeholder="e.g. sales, marketing"
            className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
          />
        </div>
        <div>
          <label className="block text-sm font-medium text-gray-700">Status</label>
          <input
            type="text"
            value={status}
            onChange={(e) => setStatus(e.target.value)}
            placeholder="e.g. active, pending"
            className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
          />
        </div>
      </div>
      <div className="flex gap-2 mt-4">
        <button
          onClick={handleApply}
          className="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700"
        >
          Apply Filters
        </button>
        <button
          onClick={resetFilters}
          className="px-4 py-2 border border-gray-300 rounded hover:bg-gray-100"
        >
          Reset
        </button>
      </div>
    </div>
  );
}
```

### Step 6: Dashboard Settings (Add/Remove Widgets)

```tsx
// src/components/DashboardSettings.tsx
'use client';

import React, { useState } from 'react';
import { useDashboardStore } from '../store/dashboardStore';

export function DashboardSettings() {
  const [isOpen, setIsOpen] = useState(false);
  const { widgets, widgetIds, addWidget, removeWidget, updatePreferences, preferences } = useDashboardStore();

  const availableWidgetTypes = [
    { type: 'chart', title: 'Sales Chart', config: { chartType: 'line', dataKey: 'value', categoryKey: 'date' } },
    { type: 'table', title: 'Recent Orders', config: { columns: ['id', 'customer', 'amount', 'status'], pageSize: 5 } },
    { type: 'stats', title: 'Revenue Stats', config: { metric: 'revenue' } },
    { type: 'list', title: 'Top Products', config: { source: 'products', maxItems: 5 } },
  ];

  const handleAddWidget = (template: any) => {
    addWidget({
      type: template.type,
      title: template.title,
      config: template.config,
      position: { x: 0, y: 0, w: 4, h: 3 },
    });
  };

  const handleToggleLayout = () => {
    updatePreferences({
      layout: preferences.layout === 'grid' ? 'list' : 'grid',
    });
  };

  if (!isOpen) {
    return (
      <button
        onClick={() => setIsOpen(true)}
        className="px-4 py-2 border border-gray-300 rounded hover:bg-gray-100"
      >
        Settings
      </button>
    );
  }

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div className="bg-white rounded-lg p-6 max-w-2xl w-full max-h-[80vh] overflow-y-auto">
        <div className="flex justify-between items-center mb-4">
          <h2 className="text-2xl font-bold">Dashboard Settings</h2>
          <button onClick={() => setIsOpen(false)} className="text-gray-500 hover:text-gray-700">
            ×
          </button>
        </div>

        <div className="mb-6">
          <h3 className="font-semibold mb-2">Layout</h3>
          <div className="flex gap-2">
            <button
              onClick={handleToggleLayout}
              className={`px-4 py-2 rounded ${preferences.layout === 'grid' ? 'bg-blue-600 text-white' : 'bg-gray-200'}`}
            >
              Grid
            </button>
            <button
              onClick={handleToggleLayout}
              className={`px-4 py-2 rounded ${preferences.layout === 'list' ? 'bg-blue-600 text-white' : 'bg-gray-200'}`}
            >
              List
            </button>
          </div>
          <div className="mt-2">
            <label className="block text-sm font-medium text-gray-700">Refresh Interval (seconds)</label>
            <input
              type="number"
              value={preferences.refreshInterval}
              onChange={(e) => updatePreferences({ refreshInterval: parseInt(e.target.value) || 0 })}
              className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
            />
          </div>
        </div>

        <div className="mb-6">
          <h3 className="font-semibold mb-2">Add Widget</h3>
          <div className="flex flex-wrap gap-2">
            {availableWidgetTypes.map((template, i) => (
              <button
                key={i}
                onClick={() => handleAddWidget(template)}
                className="px-4 py-2 bg-green-600 text-white rounded hover:bg-green-700"
              >
                + {template.title}
              </button>
            ))}
          </div>
        </div>

        <div>
          <h3 className="font-semibold mb-2">Current Widgets</h3>
          <ul className="space-y-2">
            {widgetIds.map(id => {
              const w = widgets[id];
              return (
                <li key={id} className="flex justify-between items-center border-b pb-2">
                  <span>{w.title} ({w.type})</span>
                  <button
                    onClick={() => removeWidget(id)}
                    className="text-red-500 hover:text-red-700"
                  >
                    Remove
                  </button>
                </li>
              );
            })}
          </ul>
        </div>
      </div>
    </div>
  );
}
```

### Step 7: Example Widget Implementations

```tsx
// src/components/widgets/ChartWidget.tsx
'use client';

import React from 'react';
import { LineChart, Line, BarChart, Bar, PieChart, Pie, XAxis, YAxis, Tooltip, Legend, ResponsiveContainer } from 'recharts';

export function ChartWidget({ data, config }: { data: any[]; config: any }) {
  const { chartType, dataKey, categoryKey } = config;

  if (!data || data.length === 0) {
    return <div className="text-gray-500">No chart data</div>;
  }

  const renderChart = () => {
    switch (chartType) {
      case 'line':
        return (
          <ResponsiveContainer width="100%" height={200}>
            <LineChart data={data}>
              <XAxis dataKey={categoryKey} />
              <YAxis />
              <Tooltip />
              <Legend />
              <Line type="monotone" dataKey={dataKey} stroke="#8884d8" />
            </LineChart>
          </ResponsiveContainer>
        );
      case 'bar':
        return (
          <ResponsiveContainer width="100%" height={200}>
            <BarChart data={data}>
              <XAxis dataKey={categoryKey} />
              <YAxis />
              <Tooltip />
              <Legend />
              <Bar dataKey={dataKey} fill="#82ca9d" />
            </BarChart>
          </ResponsiveContainer>
        );
      case 'pie':
        return (
          <ResponsiveContainer width="100%" height={200}>
            <PieChart>
              <Pie data={data} dataKey={dataKey} nameKey={categoryKey} cx="50%" cy="50%" outerRadius={80} fill="#8884d8" label />
              <Tooltip />
            </PieChart>
          </ResponsiveContainer>
        );
      default:
        return <div>Unsupported chart type</div>;
    }
  };

  return <div className="w-full">{renderChart()}</div>;
}
```

```tsx
// src/components/widgets/TableWidget.tsx
'use client';

import React from 'react';

export function TableWidget({ data, config }: { data: any; config: any }) {
  if (!data || !data.rows || data.rows.length === 0) {
    return <div className="text-gray-500">No table data</div>;
  }

  const { columns, rows } = data;

  return (
    <div className="overflow-x-auto">
      <table className="min-w-full divide-y divide-gray-200">
        <thead className="bg-gray-50">
          <tr>
            {columns.map((col: string) => (
              <th key={col} className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                {col}
              </th>
            ))}
          </tr>
        </thead>
        <tbody className="bg-white divide-y divide-gray-200">
          {rows.slice(0, config.pageSize || 5).map((row: any, i: number) => (
            <tr key={i}>
              {columns.map((col: string) => (
                <td key={col} className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                  {row[col] !== undefined ? row[col] : ''}
                </td>
              ))}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
```

```tsx
// src/components/widgets/StatsWidget.tsx
'use client';

import React from 'react';

export function StatsWidget({ data, config }: { data: any; config: any }) {
  if (!data) return <div className="text-gray-500">No stats</div>;

  const { metric, value, change, trend } = data;

  const formattedValue = typeof value === 'number' ? value.toLocaleString() : value;
  const changeColor = trend === 'up' ? 'text-green-600' : 'text-red-600';
  const changeArrow = trend === 'up' ? '↑' : '↓';

  return (
    <div className="text-center">
      <div className="text-3xl font-bold">{formattedValue}</div>
      <div className="text-sm text-gray-600 capitalize">{metric}</div>
      {change && (
        <div className={`text-sm ${changeColor}`}>
          {changeArrow} {Math.abs(parseFloat(change))}% from last period
        </div>
      )}
    </div>
  );
}
```

```tsx
// src/components/widgets/ListWidget.tsx
'use client';

import React from 'react';

export function ListWidget({ data, config }: { data: any[]; config: any }) {
  if (!data || data.length === 0) {
    return <div className="text-gray-500">No list items</div>;
  }

  return (
    <ul className="divide-y divide-gray-200">
      {data.map((item, i) => (
        <li key={i} className="py-2">
          <div className="font-medium">{item.title}</div>
          {item.description && <div className="text-sm text-gray-500">{item.description}</div>}
          {item.timestamp && <div className="text-xs text-gray-400">{new Date(item.timestamp).toLocaleString()}</div>}
        </li>
      ))}
    </ul>
  );
}
```

---

## The Verification: Testing the Dashboard

### Step 1: Create a Test Page

```tsx
// src/app/dashboard/page.tsx
import { Dashboard } from '@/components/Dashboard';

export default function DashboardPage() {
  return <Dashboard />;
}
```

### Step 2: Add Initial Widgets (Optional)

In the store initialization, you can add default widgets:

```typescript
// In the store creation, after initial state
// You can add default widgets
const defaultWidgets = [
  {
    id: 'widget-1',
    type: 'stats',
    title: 'Total Revenue',
    config: { metric: 'revenue' },
    visible: true,
    position: { x: 0, y: 0, w: 3, h: 2 },
  },
  {
    id: 'widget-2',
    type: 'chart',
    title: 'Sales Trend',
    config: { chartType: 'line', dataKey: 'value', categoryKey: 'date' },
    visible: true,
    position: { x: 3, y: 0, w: 5, h: 3 },
  },
  // etc.
];
```

### Step 3: Manual Testing

1. Open `/dashboard` → widgets should load with mock data
2. Apply filters → data should refresh
3. Add/remove widgets → dashboard updates
4. Toggle layout → grid/list changes
5. Refresh interval → widgets auto-refresh
6. Collapse/expand → state persists
7. Reload page → preferences and widgets persist

### Step 4: Performance Testing

- Add many widgets → check rendering performance
- Use React DevTools Profiler to measure re-renders
- Verify cache hits reduce network calls

---

## Deep Dive: Caching Strategy

### Cache Invalidation

```typescript
// Invalidate cache when filters change
setFilters: (filters) => {
  set((state) => {
    Object.assign(state.filters, filters);
    state.cache = {}; // Clear all cached data
  });
  get().refreshAll();
}
```

### Stale-While-Revalidate Pattern

```typescript
// Serve cached data immediately, then refresh in background
async function fetchWidgetData(widgetId: string) {
  const cacheKey = getCacheKey(widgetId);
  const cached = get().cache[cacheKey];
  if (cached) {
    // Return cached data immediately, but refresh in background
    refreshInBackground(widgetId);
    return cached.data;
  }
  // ... fetch fresh
}
```

---

## Common Pitfalls and Solutions

### Pitfall 1: Over-Fetching on Every Filter Change

```typescript
// ❌ BAD: Refetch all widgets on every keystroke
setSearchQuery: (query) => {
  set({ searchQuery: query });
  refreshAll(); // Too frequent
}

// ✅ GOOD: Debounce or apply filters on submit
setSearchQuery: (query) => set({ searchQuery: query });
// Apply filters only when user clicks "Apply"
```

### Pitfall 2: Not Using `React.memo` for Widgets

```tsx
// ❌ BAD: All widgets re-render when one updates
function Dashboard() {
  const visibleWidgets = getVisibleWidgets();
  return visibleWidgets.map(w => <WidgetRenderer key={w.id} widgetId={w.id} />);
}

// ✅ GOOD: Memoize each widget
const MemoizedWidgetRenderer = React.memo(WidgetRenderer);
// Use in list
```

### Pitfall 3: Persisting Transient State

```typescript
// ❌ BAD: Persisting cache and loading states
persist((set) => ({ /* ... */ }), {
  name: 'dashboard',
  // Persists everything, including cache and loading
});

// ✅ GOOD: Only persist essential state
persist((set) => ({ /* ... */ }), {
  name: 'dashboard',
  partialize: (state) => ({
    widgets: state.widgets,
    preferences: state.preferences,
    // Don't persist filters, cache, loading, errors
  }),
});
```

---

## Dashboard Checklist

- [ ] Widget definitions (type, config, position)
- [ ] Filters (date range, categories, search)
- [ ] User preferences (layout, refresh interval, collapsed widgets)
- [ ] Data caching with TTL
- [ ] Loading and error states per widget
- [ ] Polling or WebSocket updates
- [ ] Persistence of preferences and widget layout
- [ ] Add/remove widgets
- [ ] Reorder and resize widgets (if using drag-and-drop)
- [ ] Performance optimization (memoization, virtualization for large data)

---

## Key Takeaways

1. **Widget‑based architecture** – Each widget is independent but shares filters
2. **Filters and preferences** – Keep them separate; filters are session‑based, preferences are persisted
3. **Caching** – Reduce network calls; invalidate cache when filters change
4. **Loading states** – Per‑widget loading indicators improve UX
5. **Polling** – Auto‑refresh at user‑defined intervals
6. **Optimistic updates** – Show cached data while fetching fresh
7. **Persistence** – Only persist non‑transient state (preferences, layout)
8. **Performance** – Memoize widgets, virtualize long lists
9. **Modularity** – Each widget type has its own renderer
10. **Testing** – Test filter changes, widget CRUD, and caching

---

## What's Next

You've built a powerful, customizable dashboard. Next, you'll tackle complex forms with multi‑step workflows, draft saving, validation, and undo/redo functionality.
